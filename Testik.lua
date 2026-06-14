-- Touch Fling + Бессмертие + Anti-Ragdoll (Не умираешь и не рассыпаешься)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local hiddenfling = false
local flingThread

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

-- ==================== БЕССМЕРТИЕ + ANTI-RAGDOLL ====================
local function fixCharacter(character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    
    if humanoid then
        humanoid.MaxHealth = 1e9
        humanoid.Health = 1e9
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        humanoid.PlatformStand = false
    end

    -- Восстанавливаем суставы, чтобы не рассыпаться
    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("Motor6D") or v:IsA("BallSocketConstraint") then
            v.Enabled = true
        end
        if v:IsA("BasePart") then
            v.CanCollide = true
        end
    end
end

-- Постоянная защита
local antiRagdollLoop = RunService.Heartbeat:Connect(function()
    if lp.Character then
        fixCharacter(lp.Character)
    end
end)

lp.CharacterAdded:Connect(function(char)
    task.wait(0.6)
    fixCharacter(char)
end)

if lp.Character then
    task.wait(0.6)
    fixCharacter(lp.Character)
end

-- ==================== TOUCH FLING ====================
local function fling()
    while hiddenfling do
        RunService.Heartbeat:Wait()
        local c = lp.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            local vel = hrp.Velocity
            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
            RunService.Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, 0.1, 0)
        end
    end
end

local function stopFlingSafely()
    hiddenfling = false
    local c = lp.Character
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
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

print("✅ Touch Fling + Бессмертие + Anti-Ragdoll загружен!")
print("Теперь ты не должен рассыпаться и умирать при выключении.")
