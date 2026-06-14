-- ✅ ИСПРАВЛЕННАЯ ВЕРСИЯ ДЛЯ ТЕЛЕФОНА (PlayerGui)
-- Меню должно появиться сразу

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Настройки
local REPULSE_RADIUS = 50
local REPULSE_FORCE = 700
local repelEnabled = true

-- Создаём GUI в PlayerGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileRepelMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 220)
Frame.Position = UDim2.new(0.5, -160, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Visible = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Title.Text = "📱 Repel Menu (ФИКС)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 60)
ToggleButton.Position = UDim2.new(0.075, 0, 0.32, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
ToggleButton.Text = "ВЫКЛЮЧИТЬ ОТТАЛКИВАНИЕ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 17
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Parent = Frame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 10)
UICorner2.Parent = ToggleButton

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 40)
Status.Position = UDim2.new(0, 0, 0.68, 0)
Status.BackgroundTransparency = 1
Status.Text = "✅ Статус: ВКЛ"
Status.TextColor3 = Color3.fromRGB(0, 255, 0)
Status.TextSize = 16
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

-- Плавающая кнопка
local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 70, 0, 70)
FloatButton.Position = UDim2.new(1, -90, 0.5, -35)
FloatButton.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
FloatButton.Text = "🔄"
FloatButton.TextSize = 32
FloatButton.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatButton

-- Перетаскивание
local dragging = false
local dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

Title.InputEnded:Connect(function()
    dragging = false
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Функции
local function enableGodmode()
    if Humanoid then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end
end

local function repelPlayers()
    if not repelEnabled or not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Character.HumanoidRootPart
    local myPos = root.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = plr.Character.HumanoidRootPart
            local dist = (tRoot.Position - myPos).Magnitude
            if dist < REPULSE_RADIUS and dist > 3 then
                local dir = (tRoot.Position - myPos).Unit
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bv.Velocity = dir * REPULSE_FORCE + Vector3.new(0, 100, 0)
                bv.Parent = tRoot
                game:GetService("Debris"):AddItem(bv, 0.4)
            end
        end
    end
end

local function toggleRepel()
    repelEnabled = not repelEnabled
    if repelEnabled then
        ToggleButton.Text = "ВЫКЛЮЧИТЬ ОТТАЛКИВАНИЕ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        Status.Text = "✅ Статус: ВКЛ"
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.Text = "ВКЛЮЧИТЬ ОТТАЛКИВАНИЕ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        Status.Text = "❌ Статус: ВЫКЛ"
        Status.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

-- Подключения
ToggleButton.MouseButton1Click:Connect(toggleRepel)
FloatButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

RunService.Heartbeat:Connect(repelPlayers)

-- Инициализация
enableGodmode()

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    enableGodmode()
end)

print("✅ МЕНЮ ДОЛЖНО ПОЯВИТЬСЯ! (PlayerGui версия)")
print("Если не видно — попробуй перезапустить скрипт после полного захода в игру.")
