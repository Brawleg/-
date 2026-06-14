-- Superman Fly Menu (LocalScript)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flying = false
local touchTeleportEnabled = true
local speed = 100

local bodyVelocity = nil
local bodyGyro = nil
local connection = nil

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SupermanFlyMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 280)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.Text = "🦸 SUPERMAN FLY"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 10)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,0,0)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame

-- Функции
local function createButton(text, yOffset, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = UDim2.new(0.05, 0, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = mainFrame
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local flyButton = createButton("ВКЛЮЧИТЬ ПОЛЁТ (F)", 60, function()
    flying = not flying
    if flying then
        flyButton.Text = "ВЫКЛЮЧИТЬ ПОЛЁТ"
        flyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        flyButton.Text = "ВКЛЮЧИТЬ ПОЛЁТ (F)"
        flyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
    toggleFly()
end)

local teleportButton = createButton("Телепорт при касании: ВКЛ", 115, function()
    touchTeleportEnabled = not touchTeleportEnabled
    teleportButton.Text = "Телепорт при касании: " .. (touchTeleportEnabled and "ВКЛ" or "ВЫКЛ")
    teleportButton.BackgroundColor3 = touchTeleportEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- Скорость
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 30)
speedLabel.Position = UDim2.new(0.05, 0, 0, 170)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость: " .. speed
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.Gotham
speedLabel.Parent = mainFrame

local speedSlider = Instance.new("TextButton")
speedSlider.Size = UDim2.new(0.9, 0, 0, 25)
speedSlider.Position = UDim2.new(0.05, 0, 0, 205)
speedSlider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
speedSlider.Text = ""
speedSlider.Parent = mainFrame

local function updateSpeed(newSpeed)
    speed = math.clamp(newSpeed, 50, 300)
    speedLabel.Text = "Скорость: " .. math.floor(speed)
end

speedSlider.MouseButton1Down:Connect(function()
    local mouseMove = game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = speedSlider.AbsolutePosition
            local sliderSize = speedSlider.AbsoluteSize
            local percent = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            updateSpeed(50 + percent * 250)
        end
    end)
    
    local releaseConn
    releaseConn = UserInputService.InputEnded:Connect(function()
        mouseMove:Disconnect()
        releaseConn:Disconnect()
    end)
end)

-- Закрытие меню
closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Горячая клавиша для открытия меню (M)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.M then
        screenGui.Enabled = not screenGui.Enabled
    end
    if input.KeyCode == Enum.KeyCode.F then
        flying = not flying
        flyButton.Text = flying and "ВЫКЛЮЧИТЬ ПОЛЁТ" or "ВКЛЮЧИТЬ ПОЛЁТ (F)"
        flyButton.BackgroundColor3 = flying and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
        toggleFly()
    end
end)

-- ==================== ЛОГИКА ПОЛЁТА ====================
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function setupFly(character)
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.Parent = root
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(400000,400000,400000)
    bodyGyro.P = 3000
    bodyGyro.Parent = root
    
    humanoid.PlatformStand = true
end

local function endFly(character)
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    local hum = character:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end
end

function toggleFly()
    local character = getCharacter()
    if flying then
        setupFly(character)
    else
        endFly(character)
    end
end

local function updateFly()
    if not flying then return end
    local character = getCharacter()
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root or not bodyVelocity or not bodyGyro then return end
    
    local move = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
    
    if move.Magnitude > 0 then
        move = move.Unit
    end
    
    bodyVelocity.Velocity = move * speed
    bodyGyro.CFrame = camera.CFrame
end

-- Touch Teleport
local function onTouch(hit, character)
    if not flying or not touchTeleportEnabled then return end
    local hitChar = hit.Parent
    if hitChar == character then return end
    
    local hitRoot = hitChar:FindFirstChild("HumanoidRootPart")
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if hitRoot and root then
        local offset = root.CFrame.LookVector * 6 + Vector3.new(0, 4, 0)
        hitRoot.CFrame = root.CFrame * CFrame.new(offset)
    end
end

local function setupTouch(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                onTouch(hit, character)
            end)
        end
    end
end

-- Инициализация
player.CharacterAdded:Connect(function(char)
    task.wait(1)
    setupTouch(char)
    if flying then setupFly(char) end
end)

if player.Character then
    task.wait(1)
    setupTouch(player.Character)
end

connection = RunService.RenderStepped:Connect(updateFly)

print("Superman Fly Menu загружен! Нажми M - открыть меню | F - полёт")
