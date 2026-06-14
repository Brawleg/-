-- Репел-Меню для ТЕЛЕФОНА (всегда видно)
-- Для мобильных Executors (Fluxus, Delta, Solara и т.д.)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Настройки
local REPULSE_RADIUS = 50
local REPULSE_FORCE = 650        -- Сделал чуть сильнее для мобильной версии
local REPULSE_INTERVAL = 0.1

local repelEnabled = true        -- По умолчанию ВКЛЮЧЕНО

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileRepelMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Главное окно
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Visible = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "📱 Repel Menu (Мобильная)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 55)
ToggleButton.Position = UDim2.new(0.075, 0, 0.35, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
ToggleButton.Text = "ВЫКЛЮЧИТЬ ОТТАЛКИВАНИЕ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Parent = Frame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 10)
UICorner2.Parent = ToggleButton

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 35)
Status.Position = UDim2.new(0, 0, 0.72, 0)
Status.BackgroundTransparency = 1
Status.Text = "Статус: ВКЛ"
Status.TextColor3 = Color3.fromRGB(0, 255, 0)
Status.TextSize = 15
Status.Font = Enum.Font.Gotham
Status.Parent = Frame

-- Плавающая кнопка (для быстрого открытия/закрытия)
local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 60, 0, 60)
FloatButton.Position = UDim2.new(0.9, -70, 0.5, -30)
FloatButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FloatButton.Text = "🔄"
FloatButton.TextSize = 30
FloatButton.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatButton

-- Сделаем главное окно перетаскиваемым
local dragging = false
local dragInput
local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

Title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        updateDrag(input)
    end
end)

-- Функции
local function enableGodmode()
    if not Humanoid then return end
    Humanoid.MaxHealth = math.huge
    Humanoid.Health = math.huge
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        Humanoid = newChar:WaitForChild("Humanoid")
        enableGodmode()
    end)
end

local function repelPlayers()
    if not repelEnabled or not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Character.HumanoidRootPart
    local myPos = root.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = plr.Character.HumanoidRootPart
            local dist = (tRoot.Position - myPos).Magnitude
            if dist < REPULSE_RADIUS and dist > 2 then
                local dir = (tRoot.Position - myPos).Unit
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Velocity = dir * REPULSE_FORCE + Vector3.new(0, 80, 0)
                bv.Parent = tRoot
                game:GetService("Debris"):AddItem(bv, 0.35)
            end
        end
    end
end

local function toggleRepel()
    repelEnabled = not repelEnabled
    if repelEnabled then
        ToggleButton.Text = "ВЫКЛЮЧИТЬ ОТТАЛКИВАНИЕ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        Status.Text = "Статус: ВКЛ"
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.Text = "ВКЛЮЧИТЬ ОТТАЛКИВАНИЕ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        Status.Text = "Статус: ВЫКЛ"
        Status.TextColor3 = Color3.fromRGB(255, 100, 100)
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

print("✅ Мобильное Repel Menu загружено!")
print("Ты бессмертный • Отталкивание включено по умолчанию")
