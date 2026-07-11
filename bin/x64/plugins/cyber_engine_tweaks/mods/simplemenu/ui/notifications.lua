Notifications = {
    showNote = false,
    counterNote = 0,
    stringNote = "",
    varNote = "",
    nt = nil,
    resume = false
}

local Config = require("config/util")

function SetNotification(s, v)
    if not Config.configuration.popupsEnabled then return end
    Notifications.stringNote = s
    Notifications.varNote = tostring(v)
    if (Notifications.varNote == "true") then
        Notifications.varNote = UILabels.universalelements.returnTrue
    elseif (Notifications.varNote == "false") then
        Notifications.varNote = UILabels.universalelements.returnFalse
    end
    Notifications.counterNote = 0
    Notifications.showNote = true
    Cron.Resume(Notifications.nt)
    Notifications.resume = true
end

function CreateNotification()
    if not Config.configuration.popupsEnabled then return end
    ImGui.SetNextWindowPos(0, 0)
    ImGui.Begin("Notification", true, ImGuiWindowFlags.AlwaysAutoResize + ImGuiWindowFlags.NoMove + ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.NoScrollbar)
    ImGui.Text(Notifications.stringNote)
    if (Notifications.varNote == UILabels.universalelements.returnTrue or Notifications.varNote == UILabels.hotkeys.noteDone) then
        ImGui.TextColored(0.33, 1, 0.33, 1, Notifications.varNote)
    elseif (Notifications.varNote == UILabels.universalelements.returnFalse) then
        ImGui.TextColored(1, 0.33, 0.33, 1, Notifications.varNote)
    else
        ImGui.Text(Notifications.varNote)
    end
    ImGui.End()
end

function UpdateNotification(timer)
    if Notifications.resume then
        timer.s = 0
        Notifications.resume = false
    end

    if (Notifications.showNote) then
        timer.s = timer.s + 1
        if (timer.s > 3) then
            timer.s = 0
            Notifications.showNote = false
        end
    else
        Cron.Pause(Notifications.nt)
        timer.s = 0
    end
end