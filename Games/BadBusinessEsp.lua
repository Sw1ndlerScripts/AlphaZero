-- Made because obfuscuating destroyed fps

function InitEsp(EspTab, Characters, util)

local camera = workspace.CurrentCamera
local uis = game:GetService("UserInputService")

getgenv().ESP_ENABLED = false
getgenv().esp_config = {
    Text = {
        Outline = true,
        Color = Color3.new(1,1,1),
        Size = 16,
        Enabled = false
    },
    Box = {
        Color = Color3.new(1,1,1),
        Thickness = 2,
        Enabled = false
    },
    Healthbar = {
        Enabled = false
    },
    Corners = {
        Enabled = false,
        Color = Color3.new(1,1,1)
    },
    Fill = {
        Enabled = false,
        Color = Color3.new(1,1,1),
        Transparency = 0.3
    },
    Tracer = {
        Enabled = false,
        Color = Color3.new(1,1,1),
        Thickness = 1,
        Origin = "Mouse" -- Center, Mouse, Bottom
    },
    TeamCheck = false,
    TeamColor = false,
}

local espObjects = {}

do

function addBox(player)
    local box = Drawing.new("Square")
    box.Color = Color3.new(0, 0, 0)
    box.Thickness = 1

    local function update()
        local hrp = Characters[player].Body.Chest

        local vector, onScreen = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, -0.5, 0))
        local depth = vector.Z

        box.Size =  Vector2.new(3000 / depth, 4200 / depth)
        box.Position = Vector2.new(vector.X - (box.Size.X / 2), vector.Y - (box.Size.Y / 2))
    end

    table.insert(espObjects, {
        Update = update,
        Drawings = {box},
        Player = player,
        Type = 'Box'
    })
end

function addFill(player)
    local box = Drawing.new("Square")
    box.Filled = true
    box.Color = Color3.new(0.611764, 0.062745, 0.062745)
    box.Thickness = 0

    local function update()
        local hrp = Characters[player].Body.Chest

        local vector, _ = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, -0.5, 0))
        local depth = vector.Z

        box.Size =  Vector2.new(3000 / depth, 4200 / depth)
        box.Position = Vector2.new(vector.X - (box.Size.X / 2), vector.Y - (box.Size.Y / 2))
    end

    table.insert(espObjects, {
        Update = update,
        Drawings = {box},
        Player = player,
        Type = 'Fill'
    })
end

function addNametag(player)
    local text = Drawing.new("Text")
    text.Color = Color3.new(1, 1, 1)
    text.Center = false
    text.Outline = true
    text.Size = 16
    text.Text = player.Name

    local function update()
        local head = Characters[player].Body.Head

        local vector, _ = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))

        local center = Vector2.new(vector.X, vector.Y)
        local top = Vector2.new(center.X, center.Y)

        text.Position = Vector2.new(top.X - (text.TextBounds.X / 2), top.Y - (text.TextBounds.Y * 1.25));
    end


    table.insert(espObjects, {
        Update = update,
        Drawings = {text},
        Player = player,
        Type = "Text"
    })

end

function addHealthbar(player)
    return
end

function addCorners(player)
    local lines = {}
    for i=1, 8 do
        local line = Drawing.new("Line")
        line.Transparency = 1
        line.Visible = true
        line.Thickness = 2
        line.Color = Color3.new(1,1,1)
        table.insert(lines, line)
    end

    local function update()
        local hrp = Characters[player].Body.Chest

        local vector, _ = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, -0.5, 0))
        local depth = vector.Z

        local size = Vector2.new(3000 / depth, 4200 / depth)
        local center = Vector2.new(vector.X, vector.Y)

        local positions = {
            {
                Vector2.new(center.X - (size.X / 2), center.Y - (size.Y / 2)),
                Vector2.new(center.X - (size.X / 2), center.Y - (size.Y / 2.6))
            },
            {
                Vector2.new(center.X - (size.X / 2), center.Y - (size.Y / 2)),
                Vector2.new(center.X - (size.X / 3), center.Y - (size.Y / 2))
            },
            {
                Vector2.new(center.X + (size.X / 2), center.Y - (size.Y / 2)),
                Vector2.new(center.X + (size.X / 2), center.Y - (size.Y / 2.6))
            },
            {
                Vector2.new(center.X + (size.X / 2), center.Y - (size.Y / 2)),
                Vector2.new(center.X + (size.X / 3), center.Y - (size.Y / 2))
            },
            {
                Vector2.new(center.X - (size.X / 2), center.Y + (size.Y / 2)),
                Vector2.new(center.X - (size.X / 2), center.Y + (size.Y / 2.6))
            },
            {
                Vector2.new(center.X - (size.X / 2), center.Y + (size.Y / 2)),
                Vector2.new(center.X - (size.X / 3), center.Y + (size.Y / 2))
            },
            {
                Vector2.new(center.X + (size.X / 2), center.Y + (size.Y / 2)),
                Vector2.new(center.X + (size.X / 2), center.Y + (size.Y / 2.6))
            },
            {
                Vector2.new(center.X + (size.X / 2), center.Y + (size.Y / 2)),
                Vector2.new(center.X + (size.X / 3), center.Y + (size.Y / 2))
            }
        }


        for i,v in pairs(lines) do
            v.From = positions[i][1]
            v.To = positions[i][2]
        end
    end

    table.insert(espObjects, {
        Update = update,
        Drawings = lines,
        Player = player,
        Type = "Corners"
    })
end

function addTracer(player)
    local tracer = Drawing.new("Line")
    tracer.Transparency = 1
    tracer.Thickness = 3
    tracer.Color = Color3.new(255, 0, 0)


    local function update()
        local hrp = Characters[player].Body.Chest

        local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

        local from
        if esp_config.Tracer.Origin == 'Center' then
            from = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        end

        if esp_config.Tracer.Origin == 'Bottom' then
            from = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
        end

        if esp_config.Tracer.Origin == 'Mouse' then
            local mousePos = uis:GetMouseLocation()
            from = Vector2.new(mousePos.X, mousePos.Y)
        end

        tracer.To = Vector2.new(vector.X, vector.Y)
        tracer.From = from
    end

    table.insert(espObjects, {
        Update = update,
        Drawings = {tracer},
        Player = player,
        Type = "Tracer"
    })
end

function isvalidplayer(player)
    local char = Characters[player]
    return char and char:FindFirstChild("Body") and char.Body:FindFirstChild("Head") and char.Body:FindFirstChild("Chest")
end

function isvalidcharacter(char)
    return char and char:FindFirstChild("Body") and char.Body:FindFirstChild("Head") and char.Body:FindFirstChild("Chest")
end

function initPlayer(player)
    task.spawn(function()
        repeat
            task.wait()
        until isvalidplayer(player)

        addBox(player)
        addNametag(player)
        addHealthbar(player)
        addCorners(player)
        addFill(player)
        addTracer(player)
    end)
end

-- for i,v in pairs(game.Players:GetChildren()) do
--     if v ~= game.Players.LocalPlayer then
--         initPlayer(v)
--     end
-- end

-- game.Players.PlayerAdded:Connect(function(player)
--     initPlayer(player)
-- end)

local playersHaveEsp = {}
task.spawn(function()
    while task.wait() do
        if ESP_ENABLED then
            for i,v in pairs(game.Players:GetChildren()) do
                if v ~= game.Players.LocalPlayer and table.find(playersHaveEsp, v) == nil then
                    initPlayer(v)
                    table.insert(playersHaveEsp, v)
                end
            end
        end
    end
end)

--[[
function playerHasEsp(player)
    for i,v in pairs(espObjects) do
        if v.Player == player then
            return true
        end
    end
    return false
end

task.spawn(function()
    while task.wait() do
        if ESP_ENABLED then
            for i,v in pairs(game:GetService("Players"):GetChildren()) do
                if playerHasEsp(v) == false then
                    initPlayer(v)
                end
            end
        end
    end
end)
--]]


game.Players.PlayerRemoving:Connect(function(player)
    for i,v in pairs(espObjects) do
        if v.Player == player then
            v.Remove = true
        end
    end
end)

end

local teamColors = {
    ['Infected'] = Color3.fromRGB(0, 255, 0),
    ['FFA'] = Color3.fromRGB(255, 255, 255),
    ['Survivors'] = Color3.fromRGB(0, 0, 255),
    ['Omega'] = Color3.fromRGB(255, 0, 0),
    ['Beta'] = Color3.fromRGB(0, 0, 255)
}

game:GetService("RunService").RenderStepped:Connect(function()
    for i, object in pairs(espObjects) do
        local esp_config = esp_config
        local showDrawings = true


        if ESP_ENABLED and isvalidplayer(object.Player) then -- and 

            local _, onscreen =  camera:WorldToViewportPoint(Characters[object.Player].Body.Chest.Position)
            if onscreen then
                object.Update()
            else
                showDrawings = false
            end

        else
            showDrawings = false
        end

        if ESP_ENABLED then

            for _, drawing in pairs(object.Drawings) do
                do

                
                local team = util:getPlayerTeam(object.Player)
                local teamColor = team

                if teamColor then
                    teamColor = teamColors[tostring(teamColor)]
                end

                if teamColor == nil then
                    teamColor = Color3.fromRGB(255, 255, 255)
                end

                if esp_config[object.Type].Enabled == false then
                    showDrawings = false
                end

                if showDrawings == false then -- showDrawings == false
                    drawing.Visible = false
                    drawing.Transparency = 0
                else
                    drawing.Visible = true

                    if esp_config[object.Type].Transparency == nil then
                        drawing.Transparency = 1
                    else
                        drawing.Transparency = esp_config[object.Type].Transparency
                    end
                end

                if object.Type == 'Text' then
                    drawing.Outline = esp_config.Text.Outline
                    drawing.Color = esp_config.Text.Color
                    drawing.Size = esp_config.Text.Size
                end

                if object.Type == 'Box' then
                    drawing.Color = esp_config.Box.Color
                    drawing.Thickness = esp_config.Box.Thickness

                    if esp_config.TeamColor then
                        drawing.Color = teamColor or Color3.new(1,1,1)
                    end
                end

                if object.Type == 'Fill' then
                    drawing.Color = esp_config.Fill.Color
                    drawing.Transparency = esp_config.Fill.Transparency

                    if esp_config.TeamColor then
                        drawing.Color = teamColor or Color3.new(1,1,1)
                    end
                end


                if object.Type == 'Tracer' then
                    drawing.Color = esp_config.Tracer.Color or Color3.new(1,1,1)
                    drawing.Thickness = esp_config.Tracer.Thickness

                    if esp_config.TeamColor then
                        drawing.Color = teamColor or Color3.new(1,1,1)
                    end
                end

                if esp_config.TeamCheck and util:getPlayerTeam(game.Players.LocalPlayer) == team then
                    drawing.Transparency = 0
                end

            end

            if object.Remove then
                for _, drawing in pairs(object.Drawings) do
                    drawing:Remove()
                end
                table.remove(espObjects, i)
            end


            end
        end
    end
end)


local MainEspTab = EspTab:AddLeftGroupbox('Enabled')
local TextTab = EspTab:AddLeftGroupbox('Text Settings')
local BoxTab = EspTab:AddRightGroupbox('Box Settings')
local FillTab = EspTab:AddRightGroupbox('Fill Settings')
local TracerTab = EspTab:AddRightGroupbox('Tracer Settings')

--- main tab
do

MainEspTab:AddToggle('EspEnabled', {
    Text = 'Esp Enabled',
    Default = false,
    Tooltip = 'Toggles the esp',
    Callback = function(value)
        ESP_ENABLED = value
    end
})

MainEspTab:AddToggle('BoxEnabled', {
    Text = 'Boxes',
    Default = false,
    Tooltip = 'Toggles boxes',
    Callback = function(value)
        esp_config.Box.Enabled = value
    end
})

MainEspTab:AddToggle('FillEnabled', {
    Text = 'Fill',
    Default = false,
    Tooltip = 'Toggles fill',
    Callback = function(value)
        esp_config.Fill.Enabled = value
    end
})

MainEspTab:AddToggle('CornersEnabled', {
    Text = 'Corners',
    Default = false,
    Tooltip = 'Toggles corners',
    Callback = function(value)
        esp_config.Corners.Enabled = value
    end
})

MainEspTab:AddToggle('NametagsEnabled', {
    Text = 'Nametags',
    Default = false,
    Tooltip = 'Toggles nametags',
    Callback = function(value)
        esp_config.Text.Enabled = value
    end
})

MainEspTab:AddToggle('TracersEnabled', {
    Text = 'Tracers',
    Default = false,
    Tooltip = 'Toggles tracers',
    Callback = function(value)
        esp_config.Tracer.Enabled = value
    end
})

MainEspTab:AddToggle('TeamCheck', {
    Text = 'Team Check',
    Default = false,
    Tooltip = 'Dont show players on your team',
    Callback = function(value)
        esp_config.TeamCheck = value
    end
})

MainEspTab:AddToggle('UseTeamColor', {
    Text = 'Use Team Color',
    Default = false,
    Tooltip = 'Assigns color based on team',
    Callback = function(value)
        esp_config.TeamColor = value
    end
})


end
---- nametags
do

TextTab:AddToggle('OutlineText', {
    Text = 'Outline Text',
    Default = true,
    Tooltip = 'Outline the text around nametags',
    Callback = function(value)
        esp_config.Text.Outline = value
    end,
})

TextTab:AddLabel('Color'):AddColorPicker('TextColor', {
    Default = Color3.new(1, 1, 1),
    Callback = function(value)
        esp_config.Text.Color = value
    end,
})

TextTab:AddSlider('TextSize', {
    Text = 'Text Size',
    Default = 16,
    Min = 0,
    Max = 30,
    Rounding = 1,
    Callback = function(value)
        esp_config.Text.Size = value
    end,
})


end
------ boxes
do

BoxTab:AddLabel('Box Color'):AddColorPicker('BoxColor', {
    Text = 'Box Color',
    Default = Color3.new(1, 1, 1),
    Callback = function(value)
        esp_config.Box.Color = value
    end
})

BoxTab:AddSlider('BoxThickness', {
    Text = 'Box Thickness',
    Default = 2,
    Min = 0,
    Max = 5,
    Rounding = 0,
    Callback = function(value)
        esp_config.Box.Thickness = value
    end
})


end
-- fill
do

FillTab:AddLabel('Box Color'):AddColorPicker('BoxColor', {
    Text = 'Fill Color',
    Default = Color3.new(1, 1, 1),
    Callback = function(value)
        esp_config.Fill.Color = value
    end
})

FillTab:AddSlider('FillTransparency', {
    Text = 'Fill Transparency',
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Callback = function(value)
        esp_config.Fill.Transparency = value
    end
})


end
-- tracers
do

TracerTab:AddLabel('Tracer Color'):AddColorPicker('TracerColor', {
    Default = Color3.new(1, 1, 1),
    Callback = function(value)
        esp_config.Tracer.Color = value
    end,
})

TracerTab:AddSlider('TracerThickness', {
    Text = 'Tracer Thickness',
    Default = 1,
    Min = 0,
    Max = 5,
    Rounding = 0,
    Callback = function(value)
        esp_config.Tracer.Thickness = value
    end,
})

TracerTab:AddDropdown('TracerOrigin', {
    Values = {'Center', 'Mouse', 'Bottom'},
    Default = 1,
    Multi = false,
    Text = 'Tracer Origin',
    Tooltip = 'From where the tracer starts',
    Callback = function(value)
        esp_config.Tracer.Origin = value
    end,
})
end

end

return InitEsp
