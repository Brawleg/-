-- Touch Fling + Anti-Ragdoll + GodMode (Враги отталкиваются сильно)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local hiddenfling = false
local flingThread
local touchConnections = {}

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

    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("Motor6D") or obj:IsA("BallSocketConstraint") then
            obj.Enabled = true
        end
        if obj:IsA("BasePart") then
            obj.CanCollide = true
        end
    end
end

local antiRagdollLoop = RunService.Heartbeat:Connect(function()
    if lp.Character then
        fixCharacter(lp.Character)
    end
end)

lp.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    fixCharacter(char)
end)

if lp.Character then
    task.wait(0.5)
    fixCharacter(lp.Character)
end

-- ==================== TOUCH FLING (только другие улетают) ====================
local function flingOther(root)
    if not root then return end
    for i = 1, 20 do
        root.AssemblyLinearVelocity = Vector3.new(math.random(-350,350), 450 + math.random(100,300), math.random(-350,350))
        root.Velocity = root.AssemblyLinearVelocity
        RunService.Heartbeat:Wait()
    end
end

local function onTouched(hit)
    if not hiddenfling then return end
    local otherChar = hit.Parent
    if not otherChar or otherChar == lp.Character then return end
    
    local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
    if otherRoot then
        flingOther(otherRoot)
    end
end

local function attachTouchFling()
    local char = lp.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not touchConnections[part] then
            local conn = part.Touched:Connect(onTouched)
            touchConnections[part] = conn
        end
    end
end

local function removeTouchFling()
    for _, conn in pairs(touchConnections) do
        conn:Disconnect()
    end
    touchConnections = {}
end

-- ==================== КНОПКА ====================
TextButton.MouseButton1Click:Connect(function()
    hiddenfling = not hiddenfling
    TextButton.Text = hiddenfling and "ON" or "OFF"

    if hiddenfling then
        attachTouchFling()
        -- Дополнительно обновляем прикрепление при респавне
        lp.CharacterAdded:Connect(function()
            task.wait(1)
            attachTouchFling()
        end)
    else
        removeTouchFling()
    end
end)

-- Детект
if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
    local detection = Instance.new("Decal")
    detection.Name = "juisdfj0i32i0eidsuf0iok"
    detection.Parent = ReplicatedStorage
end

print("✅ Touch Fling исправлен! Враги снова сильно отталкиваются.")
