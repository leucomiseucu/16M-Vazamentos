local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

repeat wait() until LocalPlayer:FindFirstChild("PlayerGui")

-- Variáveis globais
local ESP_ENABLED = false
local AIMBOT_ENABLED = false
local SNOW_FOV = false
local ESP_COLOR = Color3.fromRGB(0, 255, 255)
local ESP_OBJECTS = {}
local FOV_RADIUS = 80  -- Tamanho inicial do FOV
local noclip = false
local noclipButton -- Para o botão do NoFly

-- Funções auxiliares
local function getClosestPlayer()
    local closest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mouse = LocalPlayer:GetMouse()
                local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if distance < dist and distance <= FOV_RADIUS then  -- Verificar se está dentro do FOV
                    closest = player
                    dist = distance
                end
            end
        end
    end
    return closest
end

-- Aimbot
RunService.RenderStepped:Connect(function()
    if AIMBOT_ENABLED then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            -- Verificar se o jogador está no mesmo time
            if target.Team ~= LocalPlayer.Team then
                -- Mirar na cabeça do jogador (Head)
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
            end
        end
    end
end)

-- ESP
local function createESP(player)
    local box = Drawing.new("Square")
    box.Color = ESP_COLOR
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false
    ESP_OBJECTS[player] = box
end

local function removeESP(player)
    if ESP_OBJECTS[player] then
        ESP_OBJECTS[player]:Remove()
        ESP_OBJECTS[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED then
        for _, box in pairs(ESP_OBJECTS) do box.Visible = false end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if not ESP_OBJECTS[player] then createESP(player) end
            local head = player.Character.Head
            local pos, visible = camera:WorldToViewportPoint(head.Position)
            local size = (camera:WorldToViewportPoint(head.Position + Vector3.new(2, 3, 0)) - camera:WorldToViewportPoint(head.Position - Vector3.new(2, 3, 0))).Magnitude
            local box = ESP_OBJECTS[player]
            box.Size = Vector2.new(size, size * 1.5)
            box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
            box.Color = ESP_COLOR
            box.Visible = visible
        else
            removeESP(player)
        end
    end
end)

-- Snow FOV
local snowCircle
RunService.RenderStepped:Connect(function()
    if SNOW_FOV then
        if not snowCircle then
            snowCircle = Drawing.new("Circle")
            snowCircle.Color = Color3.fromRGB(200, 200, 255)
            snowCircle.Thickness = 1.5
            snowCircle.Radius = FOV_RADIUS
            snowCircle.Transparency = 0.6
            snowCircle.Filled = false
        end
        local mouse = LocalPlayer:GetMouse()
        snowCircle.Position = Vector2.new(mouse.X, mouse.Y)
        snowCircle.Radius = FOV_RADIUS
        snowCircle.Visible = true
    elseif snowCircle then
        snowCircle.Visible = false
    end
end)

-- Função principal do NoClip
game:GetService("RunService").Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- Criação do menu futurista
local colorOptions = {
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 100),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(255, 0, 255)
}
local espColorIndex = 1

local function createMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FuturisticMenu"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 300, 0, 420)
    panel.Position = UDim2.new(0, 20, 0, 20)
    panel.BackgroundTransparency = 0.25
    panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    panel.BorderSizePixel = 0
    panel.Parent = screenGui

    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)
    Instance.new("UIStroke", panel).Color = Color3.fromRGB(0, 255, 255)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "☣ CEIFADOR GUI ☣"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.TextStrokeTransparency = 0.6
    title.Font = Enum.Font.SciFi
    title.TextSize = 28
    title.Parent = panel

    local dragging, dragStart, startPos
    panel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
        end
    end)
    panel.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    panel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local function addButton(name, yPos, refVar, onClick)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 260, 0, 50)
        btn.Position = UDim2.new(0, 20, 0, yPos)
        btn.Text = name .. ": OFF"
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = Color3.fromRGB(0, 255, 255)
        btn.Font = Enum.Font.SciFi
        btn.TextSize = 22
        btn.AutoButtonColor = false
        btn.Parent = panel

        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(255, 50, 50)
        stroke.Thickness = 1.5

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        btn.MouseButton1Click:Connect(function()
            refVar = not refVar
            btn.Text = name .. ": " .. (refVar and "ON" or "OFF")
            stroke.Color = refVar and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
            onClick(refVar)
        end)
    end

    addButton("ESP", 60, ESP_ENABLED, function(v) ESP_ENABLED = v end)
    addButton("AIMBOT", 120, AIMBOT_ENABLED, function(v) AIMBOT_ENABLED = v end)
    addButton("SNOW FOV", 180, SNOW_FOV, function(v) SNOW_FOV = v end)

    -- NoFly Button
    noclipButton = Instance.new("TextButton")
    noclipButton.Size = UDim2.new(0, 260, 0, 50)
    noclipButton.Position = UDim2.new(0, 20, 0, 300)
    noclipButton.Text = "☠️ NoFly (Atravessar)"
    noclipButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    noclipButton.TextColor3 = Color3.new(1, 1, 1)
    noclipButton.Font = Enum.Font.GothamBlack
    noclipButton.TextSize = 18
    noclipButton.Parent = panel

    noclipButton.MouseButton1Click:Connect(function()
        noclip = not noclip
        noclipButton.Text = noclip and "✅ NoFly ATIVADO" or "☠️ NoFly (Atravessar)"
    end)

    -- Slider para o FOV
    local fovSlider = Instance.new("TextButton")
    fovSlider.Size = UDim2.new(0, 260, 0, 50)
    fovSlider.Position = UDim2.new(0, 20, 0, 370)
    fovSlider.Text = "Ajustar FOV"
    fovSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    fovSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovSlider.Font = Enum.Font.GothamBlack
    fovSlider.TextSize = 18
    fovSlider.Parent = panel

    fovSlider.MouseButton1Click:Connect(function()
        -- Ajustar FOV (esse código depende de um slider, mas é um ponto de partida)
        FOV_RADIUS = FOV_RADIUS + 10
    end)
end

createMenu()
