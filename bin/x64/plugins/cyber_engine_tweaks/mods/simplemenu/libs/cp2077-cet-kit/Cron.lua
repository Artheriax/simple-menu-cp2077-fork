--[[
Cron.lua
Timed Tasks Manager

Copyright (c) 2021 psiberx
]]

local Cron = { version = '1.0.4' }

local timers = {}
local counter = 0

---@param timeout number
---@param recurring boolean
---@param callback function
---@param args any?
---@return any
local function addTimer(timeout, recurring, callback, args)
	if type(timeout) ~= 'number' then
		return
	end

	if timeout < 0 then
		return
	end

	if type(recurring) ~= 'boolean' then
		return
	end

	if type(callback) ~= 'function' then
		if type(args) == 'function' then
			callback, args = args, callback
		else
			return
		end
	end

	if type(args) ~= 'table' then
		args = { arg = args }
	end

	counter = counter + 1

	local timer = {
		id = counter,
		callback = callback,
		recurring = recurring,
		timeout = timeout,
		active = true,
		halted = false,
		delay = timeout,
		args = args,
	}

	if args.id == nil then
		args.id = timer.id
	end

	if args.interval == nil then
		args.interval = timer.timeout
	end

	if args.Halt == nil then
		args.Halt = Cron.Halt
	end

	if args.Pause == nil then
		args.Pause = Cron.Pause
	end

	if args.Resume == nil then
		args.Resume = Cron.Resume
	end

	table.insert(timers, timer)

	return timer.id
end

---@param timeout number
---@param callback function
---@param data any
---@return any
function Cron.After(timeout, callback, data)
	return addTimer(timeout, false, callback, data)
end

---@param timeout number
---@param callback function
---@param data any
---@return any
function Cron.Every(timeout, callback, data)
	return addTimer(timeout, true, callback, data)
end

---@param callback function
---@param data any
---@return any
function Cron.NextTick(callback, data)
	return addTimer(0, false, callback, data)
end

---@param timerId any
---@return void?
function Cron.Halt(timerId)
	if type(timerId) == 'table' then
		timerId = timerId.id
	end

	-- Defer the actual removal to Cron.Update. Removing from `timers` here
	-- would shift the array while Cron.Update is iterating it (timers are
	-- commonly halted from inside their own or another timer's callback),
	-- which invalidates any pending removal indices and can make the update
	-- loop skip timers or remove the wrong one. Marking is idempotent and
	-- safe to call from within a timer callback.
	for _, timer in ipairs(timers) do
		if timer.id == timerId then
			timer.halted = true
			timer.active = false
			break
		end
	end
end

---@param timerId any
---@return void?
function Cron.Pause(timerId)
	if type(timerId) == 'table' then
		timerId = timerId.id
	end

	for _, timer in ipairs(timers) do
		if timer.id == timerId then
			timer.active = false
			break
		end
	end
end

---@param timerId any
---@return void?
function Cron.Resume(timerId)
	if type(timerId) == 'table' then
		timerId = timerId.id
	end

	for _, timer in ipairs(timers) do
		if timer.id == timerId then
			timer.active = true
			break
		end
	end
end

---@param delta number
---@return void?
function Cron.Update(delta)
	if #timers > 0 then
		for i, timer in ipairs(timers) do
			if timer.active and not timer.halted then
				timer.delay = timer.delay - delta

				if timer.delay <= 0 then
					if timer.recurring then
						timer.delay = timer.delay + timer.timeout
					else
						-- Mark the one-shot for removal before invoking its
						-- callback, so it can never fire twice (e.g. if the
						-- callback throws, or halts another timer).
						timer.halted = true
					end

					timer.callback(timer.args)
				end
			end
		end

		-- Remove finished/halted timers AFTER the iteration loop, by value
		-- rather than by pre-captured index. Callbacks may have appended new
		-- timers or halted existing ones while we iterated; removing here
		-- with a backwards sweep keeps every index valid.
		for i = #timers, 1, -1 do
			if timers[i].halted then
				table.remove(timers, i)
			end
		end
	end
end

return Cron
