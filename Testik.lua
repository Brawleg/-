-- Touch Fling + GodMode (Ты не улетаешь | Другие улетают очень далеко)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local hiddenfling = false
local connections = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
Frame.Position = UDim2.new(0.3885, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 190, 0, 190)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.Sarpanch
Title.Text = "Touch Fling + GodMode"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 18

local FlingButton = Instance.new("TextButton")
FlingButton.Parent = Frame
FlingButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
FlingButton.Position = UDim2.new(0.1, 0, 0.28, 0)
FlingButton.Size = UDim2.new(0.8, 0, 0, 50)
FlingButton.Font = Enum.Font.SourceSansBold
FlingButton.Text = "FLING: OFF"
FlingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingButton.TextSize = 18

local GodLabel = Instance.new("TextLabel")
GodLabel.Parent = Frame
GodLabel.BackgroundTransparency = 1
GodLabel.Position = UDim2.new(0.1, 0, 0.65, 0)
GodLabel.Size = UDim2.new(0.8, 0, 0, 40)
GodLabel.Font = Enum.Font.SourceSans
GodLabel.Text = "GodMode: АКТИВЕН"
GodLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
GodLabel.TextSize = 18

-- ==================== БЕССМЕРТИЕ ====================
local function applyGodMode(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.MaxHealth = 1e9
        hum.Health = 1e9
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        
        task.spawn(function()
            while char.Parent do
                hum.Health = 1e9
                RunService.Heartbeat:Wait()
            end
        end)
    end
end

if lp.Character then applyGodMode(lp.Character) end
lp.CharacterAdded:Connect(applyGodMode)

-- ==================== TOUCH FLING (только другие улетают) ====================
local function flingOther(otherRoot)
    if not otherRoot then return end
    for i = 1, 25 do
        otherRoot.AssemblyLinearVelocity = Vector3.new(math.random(-400,400), 500 + math.random(0,300), math.random(-400,400))
        otherRoot.Velocity = otherRoot.AssemblyLinearVelocity
        RunService.Heartbeat:Wait()
    end
end

local function onTouch(part)
    if not hiddenfling then return end
    
    local character = part.Parent
    if not character or character == lp.Character then return end -- Защита от себя
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        flingOther(root)
    end
end

local function attachFlingToCharacter(char)
    if char == lp.Character then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Удаляем старые соединения
                if connections[part] then
                    connections[part]:Disconnect()
                end
                
                local conn = part.Touched:Connect(onTouch)
                connections[part] = conn
            end
        end
    end
end

local function startFling()
    local char = lp.Character
    if char then
        attachFlingToCharacter(char)
    end
    
    -- Следим за респавном
    lp.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        attachFlingToCharacter(newChar)
    end)
end

local function stopFling()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    connections = {}
end

FlingButton.MouseButton1Click:Connect(function()
    hiddenfling = not hiddenfling
    
    if hiddenfling then
        FlingButton.Text = "FLING: ON"
        FlingButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
        startFling()
    else
        FlingButton.Text = "FLING: OFF"
        FlingButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        stopFling()
    end
end)

-- Детект
if not ReplicatedStorage:FindFirstChild("FlingDetect2026") then
    local folder = Instance.new("Folder")
    folder.Name = "FlingDetect2026"
    folder.Parent = ReplicatedStorage
end

print("✅ Touch Fling исправлен! Ты почти не двигаешься, другие улетают очень далеко.")
