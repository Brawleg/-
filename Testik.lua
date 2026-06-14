-- ✅ Полностью рабочая Kill On Touch с меню для Roblox Executor
-- Вставляй в executor (Synapse, Krnl, Fluxus и т.д.)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local enabled = false
local connections = {}

-- Создаём красивую менюшку
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillOnTouchMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 180)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Kill On Touch"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 50)
ToggleButton.Position = UDim2.new(0.1, 0, 0.45, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.Text = "ВКЛЮЧИТЬ KILL"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.8, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: ВЫКЛ"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Функция обновления вида кнопки
local function updateUI()
    if enabled then
        ToggleButton.Text = "ВЫКЛЮЧИТЬ KILL"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        StatusLabel.Text = "Статус: ВКЛЮЧЕНО"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.Text = "ВКЛЮЧИТЬ KILL"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        StatusLabel.Text = "Статус: ВЫКЛ"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end

-- Основная функция убийства
local function killPlayerOnTouch(hit)
    if not enabled then return end
    
    local character = hit.Parent
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local otherPlayer = Players:GetPlayerFromCharacter(character)
    
    if humanoid and otherPlayer and otherPlayer ~= player then
        -- Убиваем игрока
        humanoid.Health = 0
        -- Дополнительно (на случай анти-читов)
        pcall(function()
            humanoid:TakeDamage(100)
        end)
    end
end

-- Подключение Touched ко всем частям персонажа
local function setupCharacter(char)
    -- Очищаем старые соединения
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    
    task.wait(1) -- Ждём пока персонаж полностью загрузится
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local conn = part.Touched:Connect(killPlayerOnTouch)
            table.insert(connections, conn)
        end
    end
    
    -- Подключаем на новые части (если респавн)
    local descConn = char.DescendantAdded:Connect(function(desc)
        if desc:IsA("BasePart") then
            local conn = desc.Touched:Connect(killPlayerOnTouch)
            table.insert(connections, conn)
        end
    end)
    table.insert(connections, descConn)
end

-- Переключение
ToggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    updateUI()
end)

-- Обработка респавна персонажа
player.CharacterAdded:Connect(function(char)
    setupCharacter(char)
end)

-- Если персонаж уже есть
if player.Character then
    setupCharacter(player.Character)
end

-- Горячая клавиша (F4)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        enabled = not enabled
        updateUI()
    end
end)

updateUI()

print("Kill On Touch меню загружено! Нажми F4 для быстрого переключения.")
