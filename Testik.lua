-- Superman Fly GUI Menu (LocalScript)
-- Помести в StarterPlayer → StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flying = false
local touchTeleport = true
local speed = 120

local bodyVelocity, bodyGyro, flyConnection = nil, nil, nil

-- === GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SupermanMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 380)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Углы и обводка
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(0, 120, 255)
uiStroke.Thickness = 2
uiStroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
title.Text = "🦸 SUPERMAN FLY"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 10)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 0.3, 0.3)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame

-- Кнопки
local function createToggle(text, positionY, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.Position = UDim2.new(0.05, 0, 0, positionY)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        defaultState = not defaultState
        btn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
        callback(defaultState)
    end)
    return btn
end

local flyBtn = createToggle("ПОЛЁТ: ВЫКЛ", 70, false, function(state)
    flying = state
    flyBtn.Text = "ПОЛЁТ: " .. (state and "ВКЛ" or "ВЫКЛ")
    toggleFly()
end)

local tpBtn = createToggle("ТЕЛЕПОРТ ПРИ КАСАНИИ: ВКЛ", 130, true, function(state)
    touchTeleport = state
end)

-- Скорость
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 30)
speedLabel.Position = UDim2.new(0.05, 0, 0, 195)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость полёта: " .. speed
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.Gotham
speedLabel.Parent = mainFrame

local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(0.9, 0, 0, 20)
speedSlider.Position = UDim2.new(0.05, 0, 0, 230)
speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedSlider.Parent = mainFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 10)
sliderCorner.Parent = speedSlider

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0.4, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
fill.Parent = speedSlider
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 10)
fillCorner.Parent = fill

local function updateSlider()
    local percent = (speed - 50) / 250
    fill.Size = UDim2.new(percent, 0, 1, 0)
    speedLabel.Text = "Скорость полёта: " .. math.floor(speed)
end

speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local mouseX = UserInputService:GetMouseLocation().X
            local sliderX = speedSlider.AbsolutePosition.X
            local sliderWidth = speedSlider.AbsoluteSize.X
            local percent = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
            speed = 50 + percent * 250
            updateSlider()
        end)
        
        local release
        release = UserInputService.InputEnded:Connect(function()
            conn:Disconnect()
            release:Disconnect()
        end)
    end
end)

updateSlider()

-- Дополнительная информация
local info = Instance.new("TextLabel")
info.Size = UDim2.new(0.9, 0, 0, 60)
info.Position = UDim2.new(0.05, 0, 0, 265)
info.BackgroundTransparency = 1
info.Text = "F — Вкл/Выкл полёт\nM — Показать/Скрыть меню\nКасайся игроков когда полёт включён"
info.TextColor3 = Color3.fromRGB(180, 180, 180)
info.TextScaled = true
info.Font = Enum.Font.Gotham
info.TextWrapped = true
info.Parent = mainFrame

-- === ЛОГИКА ===
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function setupFly(char)
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4e5, 4e5, 4e5)
    bodyVelocity.Parent = root
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(4e5, 4e5, 4e5)
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

function toggleFly()
    local char = getCharacter()
    if flying then
        setupFly(char)
    else
        endFly(char)
    end
end

local function updateFly()
    if not flying then return end
    local char = getCharacter()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or not bodyVelocity or not bodyGyro then return end
    
    local dir = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
    
    if dir.Magnitude > 0 then dir = dir.Unit end
    bodyVelocity.Velocity = dir * speed
    bodyGyro.CFrame = camera.CFrame
end

-- Touch Teleport
local function handleTouch(hit, char)
    if not flying or not touchTeleport then return end
    local hitChar = hit.Parent
    if hitChar == char then return end
    
    local hitRoot = hitChar:FindFirstChild("HumanoidRootPart")
    local root = char:FindFirstChild("HumanoidRootPart")
    if hitRoot and root then
        hitRoot.CFrame = root.CFrame * CFrame.new(0, 4, 6)
    end
end

local function setupTouches(char)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                handleTouch(hit, char)
            end)
        end
    end
end

-- Управление
closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.M then
        screenGui.Enabled = not screenGui.Enabled
    elseif input.KeyCode == Enum.KeyCode.F then
        flying = not flying
        flyBtn.Text = "ПОЛЁТ: " .. (flying and "ВКЛ" or "ВЫКЛ")
        flyBtn.BackgroundColor3 = flying and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
        toggleFly()
    end
end)

-- Инициализация
player.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    setupTouches(char)
    if flying then setupFly(char) end
end)

if player.Character then
    task.wait(1.5)
    setupTouches(player.Character)
end

flyConnection = RunService.RenderStepped:Connect(updateFly)

print("✅ Красивое Superman Fly GUI меню загружено! Нажми M")
