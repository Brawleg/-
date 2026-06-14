-- === KILL MENU (Мощный Knockback + Godmode) для Executor Roblox ===
-- Все вокруг очень сильно отлетают от тебя
-- Ты бессмертный и не отлетаешь сам

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local enabled = false
local loopConnection = nil
local godmodeConnection = nil

-- === Godmode (Бессмертие) ===
local function enableGodmode()
    if godmodeConnection then return end
    
    godmodeConnection = RunService.Heartbeat:Connect(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local hum = player.Character.Humanoid
            hum.MaxHealth = 1e9
            hum.Health = 1e9
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end
    end)
end

local function disableGodmode()
    if godmodeConnection then
        godmodeConnection:Disconnect()
        godmodeConnection = nil
    end
end

-- === Создаём меню ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KnockbackMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
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
Title.Text = "KNOCKBACK MENU"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 50)
ToggleButton.Position = UDim2.new(0.075, 0, 0.45, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
ToggleButton.Text = "Knockback: OFF"
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

-- === Мощный Knockback (без взрыва) ===
local function applyKnockback()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local root = player.Character.HumanoidRootPart
    local myPos = root.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local otherRoot = plr.Character.HumanoidRootPart
            local distance = (otherRoot.Position - myPos).Magnitude
            
            if distance < 100 and distance > 4 then
                local direction = (otherRoot.Position - myPos).Unit
                
                -- Очень сильный отлет
                local bv = Instance.new("BodyVelocity")
                bv.Name = "KnockbackForce"
                bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bv.Velocity = direction * 350 + Vector3.new(0, 180, 0)  -- сильно в стороны + вверх
                bv.Parent = otherRoot
                
                game:GetService("Debris"):AddItem(bv, 1.2)  -- долго летят
            end
        end
    end
end

-- === Тоггл ===
local function toggleKnockback()
    enabled = not enabled
    
    if enabled then
        ToggleButton.Text = "Knockback: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        StatusLabel.Text = "Статус: ВКЛЮЧЕНО (мощный отлет)"
        StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        
        enableGodmode()
        
        if loopConnection then loopConnection:Disconnect() end
        loopConnection = RunService.Heartbeat:Connect(function()
            if enabled then
                applyKnockback()
                task.wait(0.25)  -- частота (можно уменьшить для ещё большего эффекта)
            end
        end)
    else
        ToggleButton.Text = "Knockback: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        StatusLabel.Text = "Статус: Выключено"
        StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        
        disableGodmode()
        
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
    end
end

ToggleButton.MouseButton1Click:Connect(toggleKnockback)

-- Скрыть/показать меню на Insert
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Авто godmode при респавне
player.CharacterAdded:Connect(function()
    task.wait(1)
    if enabled then
        enableGodmode()
    end
end)

print("Knockback Menu загружен! Ты теперь бессмертный.")
print("Нажми кнопку для включения. Insert — скрыть/показать меню.")
