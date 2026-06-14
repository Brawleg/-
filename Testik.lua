-- SUPERMAN FLY ДЛЯ ТЕЛЕФОНА (LocalScript)
-- Помести в StarterPlayer → StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flying = false
local touchTeleport = true
local speed = 120

local bodyVelocity = nil
local bodyGyro = nil
local flyConnection = nil

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SupermanMobileMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 420)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(0, 140, 255)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundColor3 = Color3.fromRGB(0, 90, 220)
title.Text = "🦸 SUPERMAN FLY"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 10)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 0.2, 0.2)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame

-- Большая кнопка полёта
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0.9, 0, 0, 70)
flyBtn.Position = UDim2.new(0.05, 0, 0, 80)
flyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
flyBtn.Text = "🛫 ВКЛЮЧИТЬ ПОЛЁТ"
flyBtn.TextColor3 = Color3.new(1,1,1)
flyBtn.TextScaled = true
flyBtn.Font = Enum.Font.GothamBold
flyBtn.Parent = mainFrame
Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 12)

-- Телепорт
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.9, 0, 0, 55)
tpBtn.Position = UDim2.new(0.05, 0, 0, 160)
tpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
tpBtn.Text = "📍 Телепорт при касании: ВКЛ"
tpBtn.TextColor3 = Color3.new(1,1,1)
tpBtn.TextScaled = true
tpBtn.Font = Enum.Font.GothamSemibold
tpBtn.Parent = mainFrame
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 12)

-- Скорость
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 40)
speedLabel.Position = UDim2.new(0.05, 0, 0, 225)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость: 120"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.TextScaled = true
speedLabel.Parent = mainFrame

local speedSlider = Instance.new("TextButton")
speedSlider.Size = UDim2.new(0.9, 0, 0, 35)
speedSlider.Position = UDim2.new(0.05, 0, 0, 270)
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedSlider.Text = "Ползунок скорости"
speedSlider.TextColor3 = Color3.new(1,1,1)
speedSlider.TextScaled = true
speedSlider.Parent = mainFrame
Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0, 10)

-- Инструкция
local info = Instance.new("TextLabel")
info.Size = UDim2.new(0.9, 0, 0, 70)
info.Position = UDim2.new(0.05, 0, 0, 320)
info.BackgroundTransparency = 1
info.Text = "Касайся игроков — они прилетят к тебе\nДвигай камеру пальцем"
info.TextColor3 = Color3.fromRGB(200,200,200)
info.TextScaled = true
info.TextWrapped = true
info.Parent = mainFrame

-- ==================== ЛОГИКА ====================
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function setupFly(char)
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Parent = root
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.P = 3000
    bodyGyro.Parent = root
    
    hum.PlatformStand = true
end

local function endFly(char)
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end
end

local function toggleFly()
    local char = getCharacter()
    if flying then
        setupFly(char)
        flyBtn.Text = "🛬 ВЫКЛЮЧИТЬ ПОЛЁТ"
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    else
        endFly(char)
        flyBtn.Text = "🛫 ВКЛЮЧИТЬ ПОЛЁТ"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    end
end

-- Управление полётом (для телефона — по направлению камеры)
local moveDirection = Vector3.new(0,0,0)

local function updateFly()
    if not flying or not bodyVelocity then return end
    local char = getCharacter()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    
    local vel = (forward * moveDirection.Z + right * moveDirection.X + Vector3.new(0, moveDirection.Y, 0)) * speed
    bodyVelocity.Velocity = vel
    bodyGyro.CFrame = camera.CFrame
end

-- Touch Teleport
local function onTouch(hit, char)
    if not flying or not touchTeleport then return end
    local hitChar = hit.Parent
    if hitChar == char or not hitChar:FindFirstChild("Humanoid") then return end
    
    local hitRoot = hitChar:FindFirstChild("HumanoidRootPart")
    local root = char:FindFirstChild("HumanoidRootPart")
    if hitRoot and root then
        hitRoot.CFrame = root.CFrame * CFrame.new(0, 5, 8)
    end
end

local function setupTouch(char)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                onTouch(hit, char)
            end)
        end
    end
end

-- ==================== КНОПКИ ====================
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    toggleFly()
end)

tpBtn.MouseButton1Click:Connect(function()
    touchTeleport = not touchTeleport
    tpBtn.Text = "📍 Телепорт при касании: " .. (touchTeleport and "ВКЛ" or "ВЫКЛ")
    tpBtn.BackgroundColor3 = touchTeleport and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Слайдер скорости (работает пальцем)
speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local conn = RunService.RenderStepped:Connect(function()
            local pos = UserInputService:GetMouseLocation()
            local sliderPos = speedSlider.AbsolutePosition
            local sliderSize = speedSlider.AbsoluteSize
            local percent = math.clamp((pos.X - sliderPos.X) / sliderSize.X, 0, 1)
            speed = 60 + percent * 240
            speedLabel.Text = "Скорость: " .. math.floor(speed)
        end)
        
        local release
        release = UserInputService.InputEnded:Connect(function()
            conn:Disconnect()
            release:Disconnect()
        end)
    end
end)

-- Кнопки движения для телефона
local function createMoveButton(text, pos, dir)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = screenGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 50)
    
    btn.InputBegan:Connect(function()
        moveDirection = moveDirection + dir
    end)
    btn.InputEnded:Connect(function()
        moveDirection = moveDirection - dir
    end)
    return btn
end

createMoveButton("↑", UDim2.new(0.75, 0, 0.6, 0), Vector3.new(0, 1, 0))   -- Вверх
createMoveButton("↓", UDim2.new(0.75, 0, 0.8, 0), Vector3.new(0, -1, 0))  -- Вниз
createMoveButton("←", UDim2.new(0.6, 0, 0.8, 0), Vector3.new(-1, 0, 0))   -- Влево
createMoveButton("→", UDim2.new(0.9, 0, 0.8, 0), Vector3.new(1, 0, 0))    -- Вправо
createMoveButton("Вперёд", UDim2.new(0.75, 0, 0.4, 0), Vector3.new(0, 0, 1))

-- ==================== ИНИЦИАЛИЗАЦИЯ ====================
player.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    setupTouch(char)
    if flying then setupFly(char) end
end)

if player.Character then
    task.wait(1.5)
    setupTouch(player.Character)
end

flyConnection = RunService.RenderStepped:Connect(updateFly)

print("✅ Superman Fly для ТЕЛЕФОНА загружен! Нажми большую кнопку для полёта.")
