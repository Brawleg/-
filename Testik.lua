-- Touch Fling + СУПЕР БЕССМЕРТИЕ (Исправлено специально для Выживания в стихийных бедствиях)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local hiddenfling = false
local flingThread
local immortalityEnabled = true

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Frame_2 = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local TextButton = Instance.new("TextButton")

ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.3885, 0, 0.4278, 0)
Frame.Size = UDim2.new(0, 158, 0, 140)

Frame_2.Parent = Frame
Frame_2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame_2.BorderSizePixel = 0
Frame_2.Size = UDim2.new(0, 158, 0, 25)

TextLabel.Parent = Frame_2
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0.1128, 0, -0.0152, 0)
TextLabel.Size = UDim2.new(0, 121, 0, 26)
TextLabel.Font = Enum.Font.Sarpanch
TextLabel.Text = "Touch Fling"
TextLabel.TextColor3 = Color3.fromRGB(0, 0, 255)
TextLabel.TextSize = 25

TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.Position = UDim2.new(0.1139, 0, 0.35, 0)
TextButton.Size = UDim2.new(0, 121, 0, 37)
TextButton.Font = Enum.Font.SourceSansItalic
TextButton.Text = "OFF"
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextSize = 20

-- ==================== СУПЕР БЕССМЕРТИЕ ====================
local godLoop

local function applySuperGodMode(character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        humanoid.MaxHealth = 1e9
        humanoid.Health = 1e9
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        
        if root then
            root.CanCollide = true
        end
    end
end

-- Постоянный защитный цикл (очень агрессивный)
local function startGodLoop()
    if godLoop then return end
    godLoop = RunService.Heartbeat:Connect(function()
        local character = lp.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid then
            humanoid.MaxHealth = 1e9
            humanoid.Health = 1e9
            
            -- Защита от всех состояний смерти
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        end
        
        if root and root.Position.Y < -500 then
            -- Если сильно упал — возвращаем наверх
            root.CFrame = root.CFrame + Vector3.new(0, 100, 0)
        end
    end)
end

-- Применяем при респавне и смене карты
lp.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    applySuperGodMode(char)
end)

if lp.Character then
    applySuperGodMode(lp.Character)
end
startGodLoop()

-- ==================== TOUCH FLING ====================
local function fling()
    while hiddenfling and task.wait() do
        local character = lp.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local vel = hrp.Velocity
        hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
        RunService.RenderStepped:Wait()
        hrp.Velocity = vel
        RunService.Stepped:Wait()
        hrp.Velocity = vel + Vector3.new(0, 0.1, 0)
    end
end

local function stopFlingSafely()
    hiddenfling = false
    local character = lp.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Детект
if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
    local detection = Instance.new("Decal")
    detection.Name = "juisdfj0i32i0eidsuf0iok"
    detection.Parent = ReplicatedStorage
end

TextButton.MouseButton1Click:Connect(function()
    hiddenfling = not hiddenfling
    TextButton.Text = hiddenfling and "ON" or "OFF"

    if hiddenfling then
        flingThread = coroutine.create(fling)
        coroutine.resume(flingThread)
    else
        stopFlingSafely()
    end
end)

Frame.Active = true
Frame.Draggable = true

print("✅ Touch Fling + СУПЕР БЕССМЕРТИЕ загружен!")
print("Теперь ты не должен умирать даже при смене карты и выключении fling.")
