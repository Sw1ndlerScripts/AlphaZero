plr = game:GetService("Players").LocalPlayer

getgenv().settings = {
    autoPlay = {
        enabled = false
    }
}

function getSide()
    local side = plr.File.CurrentPlayer.Value
    if tostring(side) == 'Player2' then
        return '2'
    elseif tostring(side) == 'Player1' then
        return '1'
    end
    return nil
end

arrowNotes = {
    ["Arrow1"] = 'A',
    ["Arrow2"] = 'S',
    ["Arrow3"] = 'W',
    ["Arrow4"] = 'D'
}

playedNotes = {}

function autoPlay()
    task.spawn(function()
        while settings.autoPlay.enabled and task.wait() do
            playedNotes = {}
            while plr.File.CurrentPlayer.Value and task.wait() do 
                local side = getSide()
                if side then
                    for _,v in pairs(plr.PlayerGui.Main.MatchFrame['KeySync' .. side]:GetChildren()) do
                        local frame = v.Notes
                        for _, note in pairs(frame:GetChildren()) do
                            local distance = (note.AbsolutePosition - v.AbsolutePosition).magnitude
                            if distance < 30 then
                                local curParent = note.Parent
                                game.VirtualInputManager:SendKeyEvent(1, arrowNotes[v.Name], 0, game)
                                repeat task.wait() until curParent ~= note.Parent
                                game.VirtualInputManager:SendKeyEvent(0, arrowNotes[v.Name], 0, game)
                                
                            end
                        end
                    end
                end
                if settings.autoPlay.enabled == false then break end;
            end
        end
    end)
end

local LoadHandler = loadstring(game:HttpGet(("https://github.com/Sw1ndlerScripts/AlphaZero/blob/main/Handlers/Load%20Handler.lua?raw=true")))();
local CreateUI = LoadHandler("CreateUI");

local Library = CreateUI.Library;
local ThemeManager = CreateUI.ThemeManager;
local SaveManager = CreateUI.SaveManager;


local Window = Library:CreateWindow({
    Title = 'Basically FNF',
    Center = true,
    AutoShow = true
})


local Main = Window:AddTab('Main')

local Toggles = Main:AddLeftGroupbox("Toggles") 
local UISettings = Window:AddTab("UI Settings")

local box = UISettings:AddLeftGroupbox("Unload UI")
box:AddButton("Unload UI", function() Library:Unload() end);

ThemeManager:SetLibrary(Library);
SaveManager:SetLibrary(Library);

SaveManager:BuildConfigSection(UISettings);
ThemeManager:BuildThemeSection(UISettings);



Toggles:AddToggle('autoplay', {
    Text = 'Auto Play',
    Default = false,
    Tooltip = 'Toggles the auto play',
    Callback = function(Value)
        settings.autoPlay.enabled = Value
        if Value then
            autoPlay()
        end
    end,
})
