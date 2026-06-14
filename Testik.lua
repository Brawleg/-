-- ✅ ТЕЛЕФОН ВЕРСИЯ — Отталкивание ПРИ КАСАНИИ
-- Кто касается тебя — улетает очень далеко

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local REPULSE_FORCE = 1200        -- Очень сильный отлёт
local repelEnabled = true
local debounce = {}               -- Защита от спама

-- GUI (PlayerGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TouchRepelMenu"
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
Title.Text = "📱 Touch Repel"
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
Status.Text = "✅ Статус: ВКЛ (при касании)"
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

Title.InputEnded:Connect(function() dragging = false end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Бессмертие
local function enableGodmode()
    if Humanoid then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end
end

-- Функция отталкивания при касании
local function onTouch(hit)
    if not repelEnabled then return end
    
    local humanoid = hit.Parent:FindFirstChild("Humanoid")
    local root = hit.Parent:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end
    
    local player = Players:GetPlayerFromCharacter(hit.Parent)
    if not player or player == LocalPlayer then return end
    
    -- Защита от спама
    if debounce[player] then return end
    debounce[player] = true
    delay(0.3, function() debounce[player] = nil end)
    
    local myRoot = Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local direction = (root.Position - myRoot.Position).Unit
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "TouchRepel"
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = direction * REPULSE_FORCE + Vector3.new(0, 150, 0) -- сильно вверх + назад
    bv.Parent = root
    game:GetService("Debris"):AddItem(bv, 0.6)
end

-- Подключаем Touch ко всем частям персонажа
local function connectTouch()
    for _, part in ipairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(onTouch)
        end
    end
end

-- Переключатель
local function toggleRepel()
    repelEnabled = not repelEnabled
    if repelEnabled then
        ToggleButton.Text = "ВЫКЛЮЧИТЬ ОТТАЛКИВАНИЕ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        Status.Text = "✅ Статус: ВКЛ (при касании)"
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.Text = "ВКЛЮЧИТЬ ОТТАЛКИВАНИЕ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        Status.Text = "❌ Статус: ВЫКЛ"
        Status.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

ToggleButton.MouseButton1Click:Connect(toggleRepel)
FloatButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

-- Инициализация
enableGodmode()
connectTouch()

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    enableGodmode()
    wait(1)
    connectTouch()
end)

print("✅ Touch Repel загружен! Теперь отталкивает ТОЛЬКО при касании.")
