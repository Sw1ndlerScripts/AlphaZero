-- << Yield Until Game Loaded >> --
local PreLoadTick = tick();

if not game:IsLoaded() then
    game.Loaded:Wait();
end

-- << Load Handler >> --
local ESP = loadstring(game:HttpGet('https://scripts.luawl.com/hosted/1933/17507/ESP.lua'))();

-- << Library >> --
local Library = loadstring(game:HttpGet(("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/Library.lua")))();
local ThemeManager = loadstring(game:HttpGet(("https://raw.githubusercontent.com/Uvxtq/Project-AlphaZero/main/AlphaZero/Theme%20Manager.lua")))();
local SaveManager = loadstring(game:HttpGet(("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/addons/SaveManager.lua")))();

local Window = Library:CreateWindow({
    Title = "AlphaZero: Universal",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    ["Aimbot"] = Window:AddTab("Aimbot"),
    ["ESP"] = Window:AddTab("ESP"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
};

local Settings = ESP.Settings;
local Color = nil;

local NonRainbowColors = {
    NameColor = Settings.NameColor,
    BoxColor = Settings.BoxColor,
    BoxFillColor = Settings.BoxFillColor,
    OofArrowsColor = Settings.OofArrowsColor,
    DistanceColor = Settings.DistanceColor,
};

-- << Variables >> --
local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;

local Mouse = LocalPlayer:GetMouse();
local Camera = workspace.CurrentCamera;
local UIS = game:GetService("UserInputService");

-- << Aimbot >> --
local AimbotTab = Tabs["Aimbot"]:AddLeftGroupbox("Enabled");
local AimbotSettingsTab = Tabs["Aimbot"]:AddRightGroupbox("Settings");

local function GrabAllKeyEnums()
    local KeyEnums = {};

    table.insert(KeyEnums, "MouseButton1");
    table.insert(KeyEnums, "MouseButton2");

    for _, Enum in next, Enum.KeyCode:GetEnumItems() do
        if #Enum.Name > 1 then continue; end

        table.insert(KeyEnums, Enum.Name);
    end

    return KeyEnums;
end

local function IsAlive(Player)
    if not Player then return false, "No player provided" end
    if not Player.Character then return false, "Player has no character" end

    if Player.Character:FindFirstChild("Humanoid") then
        if Player.Character:FindFirstChild("HumanoidRootPart") then
            local Status = Player.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead;

            return Status, Status and "Player is alive" or "Player is dead";
        end

        return false, "Player has no humanoidrootpart";
    end

    return false, "Player has no humanoid";
end


local TeamCheckEnabled = false;
local function TeamCheck(Player)
    if #game:GetService("Teams"):GetTeams() ~= 0 then
        return TeamCheckEnabled and Player.Team ~= LocalPlayer.Team;
    end

    return true;
end

local function IsOnScreen(Player)
    if not IsAlive(Player) then return false, "Player is not alive" end

    local Character = Player.Character or Player.CharacterAdded:Wait();
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");

    return Camera:WorldToViewportPoint(HumanoidRootPart.Position).Z > 0;
end

local function IsVisible(Player)
    if not IsAlive(Player) then return false, "Player is not alive" end

    local Character = Player.Character or Player.CharacterAdded:Wait();
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");

    local Ray = Ray.new(Camera.CFrame.Position, HumanoidRootPart.Position - Camera.CFrame.Position);
    local Part, Position = workspace:FindPartOnRayWithIgnoreList(Ray, {LocalPlayer.Character, Camera});

    if Part and Part:IsDescendantOf(Player.Character) then
        return true, "Player is visible";
    else
        return false, "Player is not visible";
    end
end

local MouseType = "Camera";
local function AimAt(Player, Part, Smoothness)
    assert(Player, "Player is nil");

    Smoothness = Smoothness or 1;
    Part = Part or "Head";

    if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter and IsAlive(Player) then
        local Character = Player.Character or Player.CharacterAdded:Wait();
        local TargetPart = Character:WaitForChild(Part);

        if MouseType == "Camera" then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPart.Position), Smoothness);
        elseif MouseType == "Mouse" then
            local Vector = Camera:WorldToViewportPoint(TargetPart.Position);
            local RelativePosition = Vector2.new(Vector.X, Vector.Y) - UIS:GetMouseLocation();

            mousemoverel(RelativePosition.X * Smoothness, RelativePosition.Y * Smoothness);
        end
    end
end

local function GetClosestToMouse()
    local ClosestPlayer, ClosestDistance = nil, math.huge;

    for _, Player in next, Players:GetPlayers() do
        if Player ~= LocalPlayer and IsAlive(Player) and IsAlive(LocalPlayer) and IsVisible(Player) and TeamCheck(Player) then
            local Character = Player.Character or Player.CharacterAdded:Wait();
            local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");

            local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Camera:WorldToViewportPoint(HumanoidRootPart.Position).X, Camera:WorldToViewportPoint(HumanoidRootPart.Position).Y)).Magnitude;

            if Distance < ClosestDistance and IsOnScreen then
                ClosestDistance = Distance;
                ClosestPlayer = Player;
            end
        end
    end

    return ClosestPlayer, ClosestDistance;
end

local function IsDown(Type)
    if Type:match("MouseButton") then
        return UIS:IsMouseButtonPressed(Enum.UserInputType[Type]);
    else
        return UIS:IsKeyDown(Enum.KeyCode[Type]);
    end
end

local AimbotEnabled = false;
local TargetPart = "Head";
local Smoothness = 0.1;
local Hold = false;
local HoldButton = "MouseButton2";

AimbotTab:AddToggle("Enable Aimbot", {
    Text = "Enable Aimbot",
    Default = false,
    Tooltip = "Enable the Aimbot",
    Callback = function(Value)
        AimbotEnabled = Value;

        task.spawn(function()
            while AimbotEnabled do task.wait()
                if not AimbotEnabled then break; end
                if Library.Unloaded then break; end

                local ClosestPlayer, ClosestDistance = GetClosestToMouse();

                if ClosestPlayer and (not Hold or IsDown(HoldButton)) then
                    AimAt(ClosestPlayer, TargetPart, Smoothness);
                end
            end
        end)
    end
})

AimbotSettingsTab:AddDropdown("Aimbot Type", {
    Values = {"Camera", "Mouse"},
    Default = 1,
    Multi = false,

    Text = "Aimbot Type",
    Tooltip = "The type of Aimbot to use",

    Callback = function(Value)
        MouseType = Value;
    end
})

AimbotSettingsTab:AddDropdown("Target Part", {
    Values = {"Head", "HumanoidRootPart"},
    Default = 1,
    Multi = false,

    Text = "Target Part",
    Tooltip = "The part to aim at",

    Callback = function(Value)
        TargetPart = Value;
    end
})

AimbotSettingsTab:AddSlider("Smoothness", {
    Text = "Smoothness",

    Default = 0.1,
    Min = 0,
    Max = 1,

    Rounding = 2,
    Compact = false,

    Callback = function(Value)
        Smoothness = Value;
    end
})

AimbotSettingsTab:AddToggle("Hold", {
    Text = "Hold",
    Tooltip = "Hold a key to aim",

    Default = false,
    Callback = function(Value)
        Hold = Value;
    end
})

AimbotSettingsTab:AddDropdown("Hold Button", {
    Values = GrabAllKeyEnums(),
    Default = 2,
    Multi = false,

    Text = "Hold Button",
    Tooltip = "The button to hold to aim",

    Callback = function(Value)
        HoldButton = Value;
    end
})

AimbotSettingsTab:AddToggle("Ignore Teammates", {
    Text = "Ignore Teammates",
    Tooltip = "Ignore teammates",

    Default = false,
    Callback = function(Value)
        TeamCheckEnabled = Value;
    end
})

-- << ESP >> --
local ESPTab = Tabs["ESP"]:AddLeftGroupbox("Enabled");
local ESPSettingsTab = Tabs["ESP"]:AddRightGroupbox("Settings");

-- << ESP >> --
ESPTab:AddToggle("Enable ESP", {
    Text = "Enable ESP",
    Default = false,
    Tooltip = "Enable the ESP",
})

ESPTab:AddToggle("Enable Boxes", {
    Text = "Enable Boxes",
    Default = false,
    Tooltip = "Enable the Boxes",
})

ESPTab:AddToggle("Enable Names", {
    Text = "Enable Names",
    Default = false,
    Tooltip = "Enable the Names",
})

ESPTab:AddToggle("Enable Healthbars", {
    Text = "Enable Healthbars",
    Default = false,
    Tooltip = "Enable the Healthbars",
})

ESPTab:AddToggle("Enable Arrow", {
    Text = "Enable Arrow",
    Default = false,
    Tooltip = "Enable the Arrow",
})

ESPTab:AddDivider();

ESPTab:AddToggle("Team Check", {
    Text = "Team Check",
    Default = false,
    Tooltip = "Team Check",
})

Toggles["Enable Healthbars"]:OnChanged(function()
    Settings.Healthbar = Toggles["Enable Healthbars"].Value;
end);

Toggles["Enable Arrow"]:OnChanged(function()
    Settings.OofArrows = Toggles["Enable Arrow"].Value;
end);

Toggles["Enable Names"]:OnChanged(function()
    Settings.Names = Toggles["Enable Names"].Value;
end);

Toggles["Enable Boxes"]:OnChanged(function()
    Settings.Boxes = Toggles["Enable Boxes"].Value;
end);

Toggles["Enable ESP"]:OnChanged(function()
    if Toggles["Enable ESP"].Value then
        ESP:Load();
    else
        ESP:Unload();
    end
end);

Toggles["Team Check"]:OnChanged(function()
    Settings.TeamCheck = Toggles["Team Check"].Value;
end);

-- << ESP Settings >> --
ESPSettingsTab:AddLabel("Name Color"):AddColorPicker("Name Color", {
    Default = Color3.new(1, 1, 1),
    Title = "Name Color",
    Callback = function(ColorValue)
        Settings.NameColor = ColorValue;

        NonRainbowColors.NameColor = ColorValue;
    end
})

ESPSettingsTab:AddDivider();

ESPSettingsTab:AddDropdown("Box Type", {
    Values = {"Static", "Dynamic"},
    Default = 1,
    Multi = false,

    Text = "Box Type",
    Tooltip = "Changes the Box Type",

    Callback = function(TypeValue)
        Settings.BoxType = TypeValue;
    end
})

ESPSettingsTab:AddLabel("Box Color"):AddColorPicker("Box Color", {
    Default = Color3.new(1, 1, 1),
    Title = "Box Color",
    Callback = function(ColorValue)
        Settings.BoxColor = ColorValue;

        NonRainbowColors.BoxColor = ColorValue;
    end
})

ESPSettingsTab:AddToggle("Enable Box Fill", {
    Text = "Enable Box Fill",
    Default = false,
    Tooltip = "Enable the Box Fill",
})

ESPSettingsTab:AddLabel("Box Fill Color"):AddColorPicker("Box Fill Color", {
    Default = Color3.new(1, 1, 1),
    Title = "Box Fill Color",
    Callback = function(ColorValue)
        Settings.BoxFillColor = ColorValue;

        NonRainbowColors.BoxFillColor = ColorValue;
    end
})

ESPSettingsTab:AddSlider("Box Fill Transparency", {
    Text = "Box Fill Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(TransparencyValue)
        Settings.BoxFillTransparency = TransparencyValue;
    end
})

ESPSettingsTab:AddDivider();

ESPSettingsTab:AddLabel("Arrow Color"):AddColorPicker("Arrow Color", {
    Default = Color3.new(1, 1, 1),
    Title = "Arrow Color",
    Callback = function(ColorValue)
        Settings.OofArrowsColor = ColorValue;

        NonRainbowColors.OofArrowsColor = ColorValue;
    end
})

ESPSettingsTab:AddSlider("Arrow Size", {
    Text = "Arrow Size",
    Default = 20,
    Min = 20,
    Max = 50,
    Rounding = 0,
    Compact = false,
    Callback = function(ArrowSizeValue)
        Settings.OofArrowsSize = ArrowSizeValue;
    end
})

ESPSettingsTab:AddSlider("Arrow Radius", {
    Text = "Arrow Radius",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(ArrowRadiusValue)
        Settings.OofArrowsRadius = ArrowRadiusValue;
    end
})

ESPSettingsTab:AddDivider();

ESPSettingsTab:AddToggle("Rainbow ESP", {
    Text = "Rainbow ESP",
    Default = false,
    Tooltip = "Rainbow ESP",
})

repeat task.wait() until Toggles;

Toggles["Enable Box Fill"]:OnChanged(function()
    Settings.BoxFill = Toggles["Enable Box Fill"].Value;
end);

Toggles["Rainbow ESP"]:OnChanged(function()
    task.defer(function()
        while Toggles["Rainbow ESP"].Value do task.wait()
            Color = Color3.fromHSV(tick() / 10 % 1, 1, 1)

            if Color then
                Settings.NameColor = Color;
                Settings.BoxColor = Color;
                Settings.BoxFillColor = Color;
                Settings.OofArrowsColor = Color;
            end
        end

        if not Toggles["Rainbow ESP"].Value then
            Settings.NameColor = NonRainbowColors.NameColor;
            Settings.BoxColor = NonRainbowColors.BoxColor;
            Settings.BoxFillColor = NonRainbowColors.BoxFillColor;
            Settings.OofArrowsColor = NonRainbowColors.OofArrowsColor;
        end
    end)
end);

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
