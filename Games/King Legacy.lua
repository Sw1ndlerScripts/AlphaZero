-- << Yield Until Game Loaded >> --
local PreLoadTick = tick();
local ScriptLoaded = false;

if not game:IsLoaded() then
    game.Loaded:Wait();
end

-- << Services >> --
local Players = cloneref(game:GetService("Players"));
local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"));
local ReplicatedFirst = cloneref(game:GetService("ReplicatedFirst"));

-- << Variables >> --
local SkillAction = ReplicatedStorage.Remotes.Functions.SkillAction;

-- << Functions >> --
local function ExtractFromBrackets(Text)
    return Text:match("%[(.-)%]");
end

local function GetMobs()
    local Mobs = {};

    for _, Mob in next, workspace.Monster.Mon:GetChildren() do
        if Mob:FindFirstChild("Humanoid") and Mob:FindFirstChild("HumanoidRootPart") then
            if Mob.Humanoid.Health > 0 then
                table.insert(Mobs, {
                    Mob = Mob,
                    Level = tonumber(ExtractFromBrackets(Mob.Name):match("%d+")),
                })
            end
        end
    end

    return Mobs;
end

local function GetClosestMobByName(Name)
    local ClosestMob = nil;
    local ClosestDistance = math.huge;

    for _, Mob in next, GetMobs() do
        if Mob.Mob.Name:find(Name) then
            local Distance = (Character.HumanoidRootPart.Position - Mob.Mob.HumanoidRootPart.Position).Magnitude;

            if Distance < ClosestDistance then
                ClosestDistance = Distance;
                ClosestMob = Mob;
            end
        end
    end

    return ClosestMob;
end

local function GetClosestMobByLevel()
    local CurrentLevel = LocalPlayer.PlayerStats.lvl.Value;
    local ClosestMob, ClosestLevel = nil, math.huge;

    for _, Mob in next, GetMobs() do
        local Level = tonumber(Mob.Level);

        if Level then
            local Difference = math.abs(CurrentLevel - Level);

            if Difference < ClosestLevel then
                ClosestLevel = Difference;
                ClosestMob = Mob;
            end
        end
    end

    return ClosestMob;
end

-- << Connections >> --
LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter;
end)

-- << Handlers >> --
local LoadHandler = loadstring(game:HttpGet(("https://github.com/Uvxtq/AlphaZero/blob/main/Handlers/Load%20Handler.lua?raw=true")))();
local CreateUI = LoadHandler("CreateUI");

-- << Library >> --
local Library = CreateUI.Library;
local ThemeManager = CreateUI.ThemeManager;
local SaveManager = CreateUI. SaveManager;

if not ScriptLoaded then
    Library:Notify("Loading Script...");
end

local Window = Library:CreateWindow({
    Title = "AlphaZero: King Legacy",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    ["Main"] = Window:AddTab("Main"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
};

local FarmingTab = Tabs["Main"]:AddLeftGroupbox("Farming");

local FarmMobs = false;
FarmingTab:AddToggle("Farm Mobs", {
    Text = "Level Farm",
    Default = false,
    Callback = function(Value)
        FarmMobs = Value;

        task.spawn(function()
            while FarmMobs do task.wait()
                if Library.Unloaded then break; end
                local Mob = GetClosestMobByLevel();

                if Mob and Mob.Mob.Humanoid.Health > 0 and Character:FindFirstChild("HumanoidRootPart") then
                    local MobCFrame, Size = Mob.Mob:GetBoundingBox();
                    local Top = MobCFrame + Vector3.new(0, Size.Y / 2 + 4, 0);

                    Character.HumanoidRootPart.CFrame = Top * CFrame.Angles(math.rad(-90), 0, 0);

                    task.defer(function()
                        SkillAction:InvokeServer("FS_None_M1");
                    end)
                end
            end
        end)
    end,
})

Library:SetWatermarkVisibility(true)

Library.KeybindFrame.Visible = false;

Library:OnUnload(function()
    Library.Unloaded = true;
    ScriptLoaded = false;
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu");

MenuGroup:AddButton("Unload UI", function() Library:Unload() end);
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {Default = "RightControl", NoUI = true, Text = "Menu keybind"});

Library.ToggleKeybind = Options.MenuKeybind;

ThemeManager:SetLibrary(Library);
SaveManager:SetLibrary(Library);

SaveManager:IgnoreThemeSettings();

SaveManager:SetIgnoreIndexes({"MenuKeybind"});

ThemeManager:SetFolder("ESP");
SaveManager:SetFolder("ESP");

SaveManager:BuildConfigSection(Tabs["UI Settings"]);

ThemeManager:ApplyToTab(Tabs["UI Settings"]);

task.spawn(function()
    while game:GetService("RunService").RenderStepped:Wait() do
        if Library.Unloaded then break; end

        if Toggles.Rainbow and Toggles.Rainbow.Value then
            local Registry = Window.Holder.Visible and Library.Registry or Library.HudRegistry;

            for _, Object in next, Registry do
                for Property, ColorIdx in next, Object.Properties do
                    if ColorIdx == 'AccentColor' or ColorIdx == 'AccentColorDark' then
                        local Instance = Object.Instance;
                        local yPos = Instance.AbsolutePosition.Y;

                        local Mapped = Library:MapValue(yPos, 0, 1080, 0, 0.5) * 1.5;
                        local Color = Color3.fromHSV((Library.CurrentRainbowHue - Mapped) % 1, 0.8, 1);

                        if ColorIdx == 'AccentColorDark' then
                            Color = Library:GetDarkerColor(Color);
                        end

                        Instance[Property] = Color;
                    end
                end
            end
        end
    end
end)

Toggles.Rainbow:OnChanged(function()
    if not Toggles.Rainbow.Value then
        ThemeManager:ThemeUpdate()
    end
end)

local function GetLocalTime()
    local Time = os.date("*t")
    local Hour = Time.hour;
    local Minute = Time.min;
    local Second = Time.sec;

    local AmPm = nil;
    if Hour >= 12 then
        Hour = Hour - 12;
        AmPm = "PM";
    else
        Hour = Hour == 0 and 12 or Hour;
        AmPm = "AM";
    end

    return string.format("%s:%02d:%02d %s", Hour, Minute, Second, AmPm);
end

local DayMap = {"st", "nd", "rd", "th"};
local function FormatDay(Day)
    local LastDigit = Day % 10;
    if LastDigit >= 1 and LastDigit <= 3 then
        return string.format("%s%s", Day, DayMap[LastDigit]);
    end

    return string.format("%s%s", Day, DayMap[4]);
end

local MonthMap = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
local function GetLocalDate()
    local Time = os.date("*t")
    local Day = Time.day;

    local Month = nil;
    if Time.month >= 1 and Time.month <= 12 then
        Month = MonthMap[Time.month];
    end

    return string.format("%s %s", Month, FormatDay(Day));
end

local function GetLocalDateTime()
    return GetLocalDate() .. " " .. GetLocalTime();
end

Toggles.Rainbow:SetValue(true);

Library:Notify(string.format("Loaded script in %.2f second(s)!", tick() - PreLoadTick), 5);

task.spawn(function()
    while true do task.wait(0.1)
        if Library.Unloaded then break; end

        local Ping = string.split(string.split(game.Stats.Network.ServerStatsItem["Data Ping"]:GetValueString(), " ")[1], ".")[1];
        local Fps = string.split(game.Stats.Workspace.Heartbeat:GetValueString(), ".")[1];
        local AccountName = LocalPlayer.Name;

        Library:SetWatermark(string.format("%s | %s | %s FPS | %s Ping", GetLocalDateTime(), AccountName, Fps, Ping));
    end
end)

