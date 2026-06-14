-- Touch Fling (отлетает ТОТ, кто коснулся ТЕБЯ)
-- Для Roblox Executor

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local enabled = false
local currentCharacter = nil
local humanoidRootPart = nil
local touchConnection = nil

-- --- Функция: отбрасываем ТОГО, кто коснулся ---
local function flingToucher(hit)
    if not enabled then return end
    
    -- Находим игрока, которому принадлежит задетый объект
    local hitParent = hit.Parent
    if not hitParent then return end
    
    local humanoid = hitParent:FindFirstChild("Humanoid")
    local rootPart = hitParent:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    -- НЕ отбрасываем себя
    if hitParent == currentCharacter then return end
    
    -- Отключаем гравитацию на момент удара
    local originalGravity = workspace.Gravity
    workspace.Gravity = 0
    
    -- Создаём мощный импульс
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    
    -- Вектор ОТ тебя (от твоего центра)
    local direction = (rootPart.Position - humanoidRootPart.Position).unit
    bv.Velocity = direction * 10000 + Vector3.new(0, 600, 0)
    bv.Parent = rootPart
    
    -- Добавляем вращение для эффекта
    local bav = Instance.new("BodyAngularVelocity")
    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bav.AngularVelocity = Vector3.new(80, 80, 80)
    bav.Parent = rootPart
    
    -- Держим силу 0.3 секунды
    task.wait(0.3)
    bv:Destroy()
    bav:Destroy()
    
    -- Возвращаем гравитацию
    workspace.Gravity = originalGravity
    
    -- Временно отключаем коллизии чтобы не застревал
    task.wait(0.1)
    if rootPart and rootPart.Parent then
        rootPart.CanCollide = false
        task.wait(2)
        if rootPart and rootPart.Parent then
            rootPart.CanCollide = true
        end
    end
end

-- --- Настройка отслеживания касаний ТЕБЯ ---
local function setupCharacter(newChar)
    currentCharacter = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    
    if touchConnection then touchConnection:Disconnect() end
    -- ВАЖНО: отслеживаем КАСАНИЯ ТВОЕГО персонажа
    touchConnection = humanoidRootPart.Touched:Connect(flingToucher)
end

-- --- Создание GUI ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TouchFlingMenu"
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0.5, -100, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Touch Fling"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 160, 0, 35)
toggleButton.Position = UDim2.new(0.5, -80, 0, 40)
toggleButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
toggleButton.Text = "ВЫКЛ"
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.TextSize = 16
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 5)
buttonCorner.Parent = toggleButton

-- Анимации
toggleButton.MouseEnter:Connect(function()
    TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100,100,100)}):Play()
end)
toggleButton.MouseLeave:Connect(function()
    if enabled then
        TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0,150,0)}):Play()
    else
        TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70,70,70)}):Play()
    end
end)

-- Логика вкл/выкл
toggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        toggleButton.Text = "ВКЛ"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0,150,0)
        local char = player.Character
        if char then setupCharacter(char) end
        print("[TouchFling] ВКЛ. Теперь кто коснётся ТЕБЯ — улетит. Ты остаёшься на месте.")
    else
        toggleButton.Text = "ВЫКЛ"
        toggleButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
        if touchConnection then touchConnection:Disconnect() end
        touchConnection = nil
        print("[TouchFling] ВЫКЛ.")
    end
end)

-- Обновление при респавне
player.CharacterAdded:Connect(function(newChar)
    if enabled then
        setupCharacter(newChar)
    else
        currentCharacter = newChar
        humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    end
end)

if player.Character then
    currentCharacter = player.Character
    humanoidRootPart = currentCharacter:WaitForChild("HumanoidRootPart")
end

print("Меню загружено. Нажми ВКЛ. Теперь кто коснётся тебя — улетит на сотни метров.")
