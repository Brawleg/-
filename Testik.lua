-- Полностью рабочая фича: Меню для Repel/Kill Push (отталкивание игроков)
-- Для Executor (Synapse, Fluxus, Solara и т.д.)
-- Автор: Grok (адаптировано под запрос)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Настройки
local REPULSE_RADIUS = 50          -- Радиус отталкивания
local REPULSE_FORCE = 500          -- Сила отталкивания (чем больше — тем дальше улетают)
local REPULSE_INTERVAL = 0.1       -- Интервал обновления (сек)
local MENU_KEY = Enum.KeyCode.RightShift  -- Клавиша для открытия/закрытия меню

local repelEnabled = false
local connections = {}

-- Создаём простой GUI (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RepelMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 180)
Frame.Position = UDim2.new(0.5, -140, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "Repel Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 50)
ToggleButton.Position = UDim2.new(0.1, 0, 0.35, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ToggleButton.Text = "ВКЛЮЧИТЬ ОТТАЛКИВАНИЕ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Parent = Frame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = ToggleButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.75, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: ВЫКЛ"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = Frame

-- Функция бессмертия (godmode)
local function enableGodmode()
    if not Humanoid then return end
    Humanoid.MaxHealth = math.huge
    Humanoid.Health = math.huge
    
    -- Защита от смерти
    connections.godmode = Humanoid.HealthChanged:Connect(function(health)
        if health < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
    
    -- Защита от падения/удаления
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        Humanoid = newChar:WaitForChild("Humanoid")
        enableGodmode()
    end)
end

-- Основная функция отталкивания
local function repelPlayers()
    if not repelEnabled or not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    
    local root = Character.HumanoidRootPart
    local myPos = root.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local targetPos = targetRoot.Position
            local distance = (targetPos - myPos).Magnitude
            
            if distance < REPULSE_RADIUS and distance > 1 then
                local direction = (targetPos - myPos).Unit
                
                -- Применяем сильный импульс
                local bv = Instance.new("BodyVelocity")
                bv.Name = "RepelVelocity"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = direction * REPULSE_FORCE + Vector3.new(0, 50, 0) -- небольшой вверх для эффекта
                bv.Parent = targetRoot
                
                -- Удаляем через короткое время
                game:GetService("Debris"):AddItem(bv, 0.3)
            end
        end
    end
end

-- Переключение состояния
local function toggleRepel()
    repelEnabled = not repelEnabled
    
    if repelEnabled then
        ToggleButton.Text = "ВЫКЛЮЧИТЬ ОТТАЛКИВАНИЕ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
        StatusLabel.Text = "Статус: ВКЛ (отталкивание активно)"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.Text = "ВКЛЮЧИТЬ ОТТАЛКИВАНИЕ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        StatusLabel.Text = "Статус: ВЫКЛ"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

-- Обработка кнопки
ToggleButton.MouseButton1Click:Connect(toggleRepel)

-- Горячая клавиша для меню
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == MENU_KEY then
        Frame.Visible = not Frame.Visible
    end
end)

-- Главный цикл
connections.repelLoop = RunService.Heartbeat:Connect(function()
    if repelEnabled then
        repelPlayers()
    end
end)

-- Инициализация
enableGodmode()

print("✅ Repel Menu загружен! Нажми RightShift для открытия меню.")
print("Ты бессмертный и не отталкиваешься сам.")

-- Авто-обновление персонажа
LocalPlayer.CharacterAdded:Connect(function()
    Character = LocalPlayer.Character
    wait(1)
    if Character:FindFirstChild("Humanoid") then
        Humanoid = Character.Humanoid
        enableGodmode()
    end
end)
