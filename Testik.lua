-- === KILL MENU (Explosion Knockback) для Executor Roblox ===
-- Включи/выключи "Kills" — вокруг тебя взрыв и всех откидывает ОЧЕНЬ далеко
-- Работает на большинстве executors (Synapse, Fluxus, Wave и т.д.)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local enabled = false
local loopConnection = nil

-- === Создаём красивое меню ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 160)
MainFrame.Position = UDim2.new(0.5, -140, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
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
Title.Text = "KILL MENU"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 50)
ToggleButton.Position = UDim2.new(0.075, 0, 0.45, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
ToggleButton.Text = "Kills: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0.85, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Выключено"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- === Логика взрыва ===
local function createBigExplosion()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local root = player.Character.HumanoidRootPart
    local explosion = Instance.new("Explosion")
    
    explosion.Position = root.Position + Vector3.new(0, 5, 0)  -- немного выше, чтобы лучше разлетались
    explosion.BlastRadius = 80
    explosion.BlastPressure = 5000000  -- очень сильный отлет
    explosion.Visible = true
    explosion.Parent = workspace
    
    -- Дополнительный импульс (на случай если обычный взрыв не сильно откидывает)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local otherRoot = plr.Character.HumanoidRootPart
            local distance = (otherRoot.Position - root.Position).Magnitude
            if distance < 70 and distance > 3 then
                local direction = (otherRoot.Position - root.Position).Unit
                local force = direction * (120000 / math.max(distance, 10))
                
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Velocity = force + Vector3.new(0, 80000, 0)  -- сильный вверх
                bv.Parent = otherRoot
                
                game:GetService("Debris"):AddItem(bv, 0.6)
            end
        end
    end
end

-- === Тоггл ===
local function toggleKills()
    enabled = not enabled
    
    if enabled then
        ToggleButton.Text = "Kills: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        StatusLabel.Text = "Статус: ВКЛЮЧЕНО (взрывы)"
        StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        
        -- Запускаем цикл
        if loopConnection then loopConnection:Disconnect() end
        loopConnection = RunService.Heartbeat:Connect(function()
            if enabled then
                createBigExplosion()
                wait(0.35)  -- частота взрывов (можно менять)
            end
        end)
    else
        ToggleButton.Text = "Kills: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        StatusLabel.Text = "Статус: Выключено"
        StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
    end
end

ToggleButton.MouseButton1Click:Connect(toggleKills)

-- Закрытие меню на Insert
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Авто-обновление персонажа
player.CharacterAdded:Connect(function(newChar)
    -- ничего не делаем, просто продолжаем работать
end)

print("Kill Menu загружен! Нажми на кнопку для включения. Insert — скрыть/показать меню.")
