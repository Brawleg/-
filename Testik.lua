-- Touch Fling + Anti-Ragdoll + GodMode (Исправлено рассыпание)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local hiddenfling = false
local flingThread
local connections = {}

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
Frame.Position = UDim2.new(0.3885, 0, 0.4278, 0)
Frame.Size = UDim2.new(0, 158, 0, 140)
Frame.Active = true
Frame.Draggable = true

Frame_2.Parent = Frame
Frame_2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame_2.Size = UDim2.new(1, 0, 0, 25)

TextLabel.Parent = Frame_2
TextLabel.BackgroundTransparency = 1
TextLabel.Size = UDim2.new(1, 0, 1, 0)
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

-- ==================== ANTI-RAGDOLL + GODMODE ====================
local function antiRagdoll(character)
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
        humanoid.AutoRotate = true
    end

    -- Восстанавливаем все Motor6D и BallSocket (чтобы не рассыпался)
    for _, joint in ipairs(character:GetDescendants()) do
        if joint:IsA("Motor6D") or joint:IsA("BallSocketConstraint") or joint:IsA("HingeConstraint") then
            joint.Enabled = true
        end
        if joint:IsA("BasePart") then
            joint.CanCollide = true
            joint.AssemblyLinearVelocity = Vector3.new(0,0,0)
            joint.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end
    end
end

-- Постоянная защита от рассыпания
local godConnection = RunService.Heartbeat:Connect(function()
    local char = lp.Character
    if char then
        antiRagdoll(char)
    end
end)

lp.CharacterAdded:Connect(function(char)
    task.wait(0.6)
    antiRagdoll(char)
end)

if lp.Character then
    task.wait(0.6)
    antiRagdoll(lp.Character)
end

-- ==================== TOUCH FLING ====================
local function fling()
    while hiddenfling do
        RunService.Heartbeat:Wait()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = vel * 8000 + Vector3.new(0, 8000, 0)
            
            RunService.RenderStepped:Wait()
            hrp.AssemblyLinearVelocity = vel
            
            RunService.Stepped:Wait()
            hrp.AssemblyLinearVelocity = vel + Vector3.new(0, 0.1, 0)
        end
    end
end

local function stopFlingSafely()
    hiddenfling = false
    local char = lp.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
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

print("✅ Touch Fling + Anti-Ragdoll загружен!")
print("Рассывание должно исчезнуть.")
