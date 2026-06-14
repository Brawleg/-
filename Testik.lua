-- ✅ Улучшенная версия: Kill Menu + ВЗРЫВ при нажатии кнопки
-- Всех разбрасывает и убивает + крутой визуал взрыва

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local enabled = false
local connections = {}

-- === СОЗДАНИЕ МЕНЮ ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExplosionKillMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "💥 EXPLOSION KILL"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 60)
ToggleButton.Position = UDim2.new(0.075, 0, 0.35, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
ToggleButton.Text = "💥 АКТИВИРОВАТЬ ВЗРЫВ"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = MainFrame

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 12)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 35)
Status.Position = UDim2.new(0, 0, 0.75, 0)
Status.BackgroundTransparency = 1
Status.Text = "Статус: ВЫКЛ"
Status.TextColor3 = Color3.fromRGB(180, 180, 180)
Status.TextScaled = true
Status.Font = Enum.Font.Gotham
Status.Parent = MainFrame

-- === ФУНКЦИЯ ВЗРЫВА ===
local function createExplosion()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local root = player.Character.HumanoidRootPart
    local explosionPos = root.Position + Vector3.new(0, 5, 0)
    
    -- Визуальный Explosion
    local explosion = Instance.new("Explosion")
    explosion.Position = explosionPos
    explosion.BlastRadius = 150
    explosion.BlastPressure = 500000
    explosion.Parent = workspace
    
    -- Дополнительные эффекты
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://138081500" -- Большой взрыв
    sound.Volume = 1.5
    sound.Parent = root
    sound:Play()
    Debris:AddItem(sound, 5)
    
    -- Частицы
    local attachment = Instance.new("Attachment", root)
    local particle = Instance.new("ParticleEmitter")
    particle.Texture = "rbxassetid://243098098"
    particle.Lifetime = NumberRange.new(1.5, 3)
    particle.Rate = 800
    particle.Speed = NumberRange.new(30, 80)
    particle.SpreadAngle = Vector2.new(360, 360)
    particle.Size = NumberSequence.new(4, 0)
    particle.Transparency = NumberSequence.new(0.3, 1)
    particle.Parent = attachment
    Debris:AddItem(attachment, 3)
    
    -- Убийство и отбрасывание всех игроков
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChild("Humanoid")
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            
            if hum and rootPart then
                -- Отбрасывание
                local direction = (rootPart.Position - explosionPos).Unit * 120 + Vector3.new(0, 50, 0)
                rootPart.Velocity = direction
                
                -- Убийство
                hum.Health = 0
                task.delay(0.1, function()
                    if hum then hum:TakeDamage(100) end
                end)
            end
        end
    end
end

-- === ТОГГЛ ===
local function updateUI()
    if enabled then
        ToggleButton.Text = "💥 ВЗРЫВ АКТИВЕН (F4)"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        Status.Text = "Статус: ВКЛЮЧЕНО"
        Status.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        ToggleButton.Text = "💥 АКТИВИРОВАТЬ ВЗРЫВ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
        Status.Text = "Статус: ВЫКЛ"
        Status.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    updateUI()
    
    if enabled then
        createExplosion() -- Взрыв сразу при включении
    end
end)

-- Горячая клавиша F4
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        enabled = not enabled
        updateUI()
        if enabled then
            createExplosion()
        end
    end
end)

-- Kill On Touch (оставил как доп. возможность)
local function killOnTouch(hit)
    if not enabled then return end
    local char = hit.Parent
    local hum = char:FindFirstChild("Humanoid")
    local otherPlr = Players:GetPlayerFromCharacter(char)
    if hum and otherPlr and otherPlr ~= player then
        hum.Health = 0
    end
end

local function setupCharacter(char)
    for _, conn in pairs(connections) do conn:Disconnect() end
    connections = {}
    
    task.wait(0.5)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(connections, part.Touched:Connect(killOnTouch))
        end
    end
end

player.CharacterAdded:Connect(setupCharacter)
if player.Character then setupCharacter(player.Character) end

updateUI()

print("💥 Explosion Kill Menu загружено! Нажми кнопку или F4")
