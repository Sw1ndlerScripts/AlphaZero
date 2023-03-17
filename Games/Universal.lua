-- << Yield Until Game Loaded >> --
local PreLoadTick = tick();

if not game:IsLoaded() then
    game.Loaded:Wait();
end

-- << Load Handler >> --
local ESP = loadstring(game:HttpGet('https://scripts.luawl.com/17507/ESP.lua'))();
local LoadHandler = loadstring(game:HttpGet(("https://github.com/Sw1ndlerScripts/AlphaZero/blob/main/Handlers/Load%20Handler.lua?raw=true")))();
local CreateUI = LoadHandler("CreateUI");

-- << Library >> --
local Library = CreateUI.Library;
local ThemeManager = CreateUI.ThemeManager;
local SaveManager = CreateUI. SaveManager;

local Window = Library:CreateWindow({
    Title = "AlphaZero: Universal",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    ["ESP"] = LoadHandler("EspTab")(),
    ["UI Settings"] = Window:AddTab("UI Settings"),
};

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
  end

warn("AlphaZero loaded in " .. round(tick()-  PreLoadTick, 2) .. ' seconds')