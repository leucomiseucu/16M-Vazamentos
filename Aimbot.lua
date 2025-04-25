local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- CONFIGURAÇÃO
local ESP_ENABLED = true
local AIMBOT_ENABLED = true
local FOV_RADIUS = 65
local AIM_RADIUS = 350
local SILENT_FOV = 78
local TOGGLE_KEY = Enum.KeyCode.P
local SMOOTH_AIM = true
local ESP_COLOR = Color3.fromRGB(0, 255, 0)
local SNOW_FOV = true

local guiVisible = true
local isAiming = false
local killColor = Color3.fromRGB(255, 0, 0)

local espColorIndex = 1
local colorOptions = {
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(255, 0, 255)
}

local function createMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Menu"
    screenGui.Parent = game.Players.LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 250, 0, 360)
    panel.Position = UDim2.new(0, 10, 0, 10)
    panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    panel.BackgroundTransparency = 0.5
    panel.Parent = screenGui

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    panel.InputBegan:Connect(function(input, gameProcessed)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local espButton = Instance.new("TextButton")
    espButton.Size = UDim2.new(0, 200, 0, 50)
    espButton.Position = UDim2.new(0, 10, 0, 10)
    espButton.Text = "ESP: ON"
    espButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    espButton.Parent = panel

    espButton.MouseButton1Click:Connect(function()
        ESP_ENABLED = not ESP_ENABLED
        espButton.Text = ESP_ENABLED and "ESP: ON" or "ESP: OFF"
        espButton.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    local aimbotButton = Instance.new("TextButton")
    aimbotButton.Size = UDim2.new(0, 200, 0, 50)
    aimbotButton.Position = UDim2.new(0, 10, 0, 70)
    aimbotButton.Text = "AIMBOT: ON"
    aimbotButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    aimbotButton.Parent = panel

    aimbotButton.MouseButton1Click:Connect(function()
        AIMBOT_ENABLED = not AIMBOT_ENABLED
        aimbotButton.Text = AIMBOT_ENABLED and "AIMBOT: ON" or "AIMBOT: OFF"
        aimbotButton.BackgroundColor3 = AIMBOT_ENABLED and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    local snowFovButton = Instance.new("TextButton")
    snowFovButton.Size = UDim2.new(0, 200, 0, 50)
    snowFovButton.Position = UDim2.new(0, 10, 0, 130)
    snowFovButton.Text = "SNOW FOV: ON"
    snowFovButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    snowFovButton.Parent = panel

    snowFovButton.MouseButton1Click:Connect(function()
        SNOW_FOV = not SNOW_FOV
        snowFovButton.Text = SNOW_FOV and "SNOW FOV: ON" or "SNOW FOV: OFF"
        snowFovButton.BackgroundColor3 = SNOW_FOV and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0, 200, 0, 50)
    colorButton.Position = UDim2.new(0, 10, 0, 190)
    colorButton.Text = "COR ESP"
    colorButton.BackgroundColor3 = ESP_COLOR
    colorButton.TextColor3 = Color3.new(0, 0, 0)
    colorButton.Parent = panel

    colorButton.MouseButton1Click:Connect(function()
        espColorIndex = (espColorIndex % #colorOptions) + 1
        ESP_COLOR = colorOptions[espColorIndex]
        colorButton.BackgroundColor3 = ESP_COLOR
    end)
end

createMenu()

local function createESP(player)
    if player == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Transparency = 1
    box.Visible = false

    local text = Drawing.new("Text")
    text.Size = 16
    text.Center = true
    text.Outline = true
    text.Color = Color3.new(1, 1, 1)
    text.Visible = false

    local function update()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen and ESP_ENABLED then
                local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                box.Size = Vector2.new(60 / (distance / 50), 100 / (distance / 50))
                box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                box.Color = ESP_COLOR
                box.Visible = true

                text.Position = Vector2.new(pos.X, pos.Y - box.Size.Y / 2 - 15)
                text.Text = string.format("%s | %.0f HP | %.0f m", player.Name, player.Character.Humanoid.Health, distance)
                text.Visible = true
            else
                box.Visible = false
                text.Visible = false
            end
        else
            box.Visible = false
            text.Visible = false
        end
    end

    RunService.RenderStepped:Connect(update)
end

for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end
Players.PlayerAdded:Connect(createESP)

local function aimbot()
    local closestPlayer = nil
    local closestDistance = FOV_RADIUS

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local character = player.Character
        if character and character:FindFirstChild("Head") then
            local head = character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local distance = (Camera.CFrame.Position - head.Position).Magnitude
                if distance < closestDistance then
                    closestPlayer = player
                    closestDistance = distance
                end
            end
        end
    end

    if closestPlayer then
        local targetHead = closestPlayer.Character and closestPlayer.Character.Head
        if targetHead then
            local targetPos = targetHead.Position
            local direction = (targetPos - Camera.CFrame.Position).unit

            if SNOW_FOV then
                local ray = Ray.new(Camera.CFrame.Position, direction * AIM_RADIUS)
                local hitPart = workspace:FindPartOnRay(ray, LocalPlayer.Character)

                if hitPart and hitPart.Parent == closestPlayer.Character then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                end
            end
        end
    end
end

local function silentAim()
    local closestPlayer = nil
    local shortestDistance = SILENT_FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if distance <= SILENT_FOV then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end

    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.Head.Position)
        closestPlayer.Character.Humanoid.Health = 0
    end
end

RunService.RenderStepped:Connect(function()
    if AIMBOT_ENABLED then
        aimbot()
        silentAim()
    end
end)
