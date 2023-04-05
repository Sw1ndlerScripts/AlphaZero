repeat task.wait() until game.Players.LocalPlayer and  game.Players.LocalPlayer.Character
loadstring(game:HttpGet("https://raw.githubusercontent.com/Sw1ndlerScripts/RobloxScripts/main/funcs/utils.lua"))()

getgenv().config = {
    disableKillParts = false,
    autofarm = false,
    autofarmWait = 7,
    mutators = {} -- defined in getMutators function
}

local plr = game.Players.LocalPlayer

-- // disable anticheat
local old
old = hookmetamethod(game, '__namecall', function(self, ...)
    if getnamecallmethod() == 'Kick' then
        return task.wait(math.huge)
    end
    return old(self, ...)
end)

plr.PlayerScripts.LocalScript.Disabled = true


function getKillParts()
    local parts = {}
    for _, part in pairs(workspace.tower:GetDescendants()) do
        if part.Name == 'killwall' or part.Name == 'killPart' then
            table.insert(parts, part)
        end
    end
    return parts
end

function disableKillParts()
    for i,v in pairs(getKillParts()) do
        if config.disableKillParts then
            v.CanTouch = false
            v.CanQuery = false
        else
            v.CanTouch = true
            v.CanQuery = true
        end
    end
end


function getMutators()
    local mutators = {}
    for _, v in pairs(game:GetService("ReplicatedStorage").Mutators:GetChildren()) do
        local success, mutate = pcall(require, v)
        if success then
            mutators[v.Name] = {
                Enabled = false,
                Enable = mutate.mutate,
                Disable = mutate.revert
            }
        end
    end
    return mutators
end

function getFinish()
    for _, win in pairs(game:GetService("Workspace").tower.finishes:GetChildren()) do
        local ray1 = Workspace:Raycast(win.Position + Vector3.new(-10, 0, 0), Vector3.new(0, -100, 0))
        local ray2 = Workspace:Raycast(win.Position + Vector3.new(0, -10, 0), Vector3.new(0, -100, 0))
        local ray3 = Workspace:Raycast(win.Position, Vector3.new(0, -100, 0))
        if ray1 or ray2 or ray3 then
            return win
        end
    end
end

function getMinLeft()
    local time = plr.PlayerGui.timer.timeLeft.Text:split(":")
    return tonumber(time[1])
end

function winGame()
    local oldPos = plr.Character.HumanoidRootPart.CFrame
    local win = getFinish()


    -- teleportTo(win.CFrame * CFrame.new(1, -500, 0))
    -- tweenTo(win.CFrame * CFrame.new(1, -5, 0), 50)


    local start = tick()
    while tick() - start < 1.5 do
        teleportTo(win.CFrame * CFrame.new(1, -5, 0))
        task.wait() 
    end


    if plr.Character == nil or (plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") == nil) then
        return
    end

    for i,v in pairs(plr.Character:GetChildren()) do
        if v:IsA("BasePart") then
            firetouchinterest(v, win, 0)
        end
    end

    teleportTo(oldPos)
end

function teleportToWin()
    local win = getFinish()
    if win then
        teleportTo(win.CFrame * CFrame.new(-5, 0, 0))
    end
end

function autofarm()
    task.spawn(function()
        while config.autofarm do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")  then

                if game:GetService("Workspace").tower:FindFirstChild("finishes") and 

                plr.PlayerGui.timer.timeLeft.TextColor3 ~= Color3.fromRGB(0, 255, 0) and 

                getMinLeft() < config.autofarmWait and getMinLeft() >= 0 then
                    winGame()
                    task.wait(10)
                end
            end

            task.wait()
        end 
    end)
end

config.mutators = getMutators()

-- // Ui

local LoadHandler = loadstring(game:HttpGet(("https://github.com/Sw1ndlerScripts/AlphaZero/blob/main/Handlers/Load%20Handler.lua?raw=true")))();
local CreateUI = LoadHandler("CreateUI");

local Library = CreateUI.Library;
local ThemeManager = CreateUI.ThemeManager;
local SaveManager = CreateUI. SaveManager;


local Window = Library:CreateWindow({
    Title = 'AlphaZero | Tower of Hell',
    Center = true,
    AutoShow = true
})


local Main = Window:AddTab('Main')

local MainToggles = Main:AddLeftGroupbox("Toggles") 
local Mutators = Main:AddRightGroupbox("Mutators") 
local Tools = Main:AddLeftGroupbox("Tools") 
local UISettings = Window:AddTab("UI Settings")

local box = UISettings:AddLeftGroupbox("Unload UI")
box:AddButton("Unload UI", function() Library:Unload() end);

ThemeManager:SetLibrary(Library);
SaveManager:SetLibrary(Library);

SaveManager:BuildConfigSection(UISettings);
ThemeManager:BuildThemeSection(UISettings);

MainToggles:AddToggle('Autofarm', {
    Text = 'Autofarm (Use at own risk)',
    Default = false,
    Tooltip = 'Auto completes the obby',
    Callback = function(value)
        config.autofarm = value
        autofarm()
    end
})

MainToggles:AddSlider('waitamount', {
    Text = 'Wait until mins left',
    Default = 7,
    Min = 0,
    Max = 10,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        config.autofarmWait = value
    end,
})

MainToggles:AddButton({
    Text = 'Teleport To Win',
    DoubleClick = false,
    Tooltip = 'Teleport to the win part',
    Func = function()
        teleportToWin()
    end
})

MainToggles:AddToggle('DisableKillBricks', {
    Text = 'Disable Kill Parts',
    Default = false,
    Tooltip = 'Disables the kill parts',
    Callback = function(value)
        config.disableKillParts = value
        if value then
            config.mutators.invincibility.Enable()
        else
            config.mutators.invincibility.Disable()
        end
    end
})

Mutators:AddLabel("These mutators are client sided\nand wont affect other players", true)

local blacklist = {'fluffy', 'lengthen', 'double coins', 'time', 'invisibility', 'checkpoints', 'invincibility'}


for name, mutator in pairs(config.mutators) do
    if table.find(blacklist, name) == nil then
        Mutators:AddToggle(name, {
            Text = 'Toggle ' .. name .. ' mutator',
            Default = false,
            Tooltip = 'Toggles the ' .. name .. ' mutator',
            Callback = function(value)
                mutator.Enabled = value
                if value then
                    mutator.Enable()
                else
                    mutator.Disable()
                end
            end
        })
    end
end

local toolBlacklist = {'yxterminator', 'cola', 'bomb', 'killpart'}


Tools:AddLabel("These tools are client sided\nand other players wont see them", true)

for _, tool in pairs(game:GetService("ReplicatedStorage").Gear:GetChildren()) do
    if table.find(toolBlacklist, tool.Name) == nil then
        Tools:AddButton("Give the " .. tool.Name .. " tool", function()
            local x = tool:Clone()
            x.Parent = plr.Backpack
        end)
    end
end

Tools:AddButton("Clear tools", function()
    for _, tool in pairs(plr.Backpack:GetChildren()) do
        tool:Destroy()
    end
end)
