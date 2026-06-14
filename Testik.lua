-- Touch Fling + GodMode (Исправлено: ты не улетаешь, другие — очень далеко)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local immortalityEnabled = true
local hiddenfling = false
local flingConnection

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

-- ==================== УЛУЧШЕННОЕ БЕССМЕРТИЕ ====================
local function applyGodMode(char)
    if not char or not immortalityEnabled then return end
    local hum = char:WaitForChild("Humanoid", 8)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    
    if hum then
        hum.MaxHealth = 1e9
        hum.Health = 1e9
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        
        task.spawn(function()
            while immortalityEnabled and char.Parent do
                hum.Health = 1e9
                RunService.Heartbeat:Wait()
            end
        end)
    end
end

if lp.Character then applyGodMode(lp.Character) end
lp.CharacterAdded:Connect(applyGodMode)

-- ==================== TOUCH FLING (только другие улетают) ====================
local function onTouch(part)
    if not hiddenfling then return end
    local character = part.Parent
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and root and character ~= lp.Character then
        -- Сильный fling только для другого игрока
        for i = 1, 15 do
            root.AssemblyLinearVelocity = Vector3.new(math.random(-200,200), 300, math.random(-200,200))
            root.Velocity = Vector3.new(math.random(-200,200), 300, math.random(-200,200))
            RunService.Heartbeat:Wait()
        end
    end
end

local function startFling()
    if flingConnection then return end
    
    flingConnection = RunService.Heartbeat:Connect(function()
        local char = lp.Character
        if not char then return end
        
        -- Прикрепляем Touched к частям персонажа
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and not part:FindFirstChild("FlingTouch") then
                local touchConn = part.Touched:Connect(onTouch)
                local tag = Instance.new("BoolValue")
                tag.Name = "FlingTouch"
                tag.Parent = part
                
                -- Очистка при смерти
                part.AncestryChanged:Connect(function()
                    if touchConn then touchConn:Disconnect() end
                end)
            end
        end
    end)
end

local function stopFling()
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
end

-- Детект
if not ReplicatedStorage:FindFirstChild("FlingDetect") then
    local folder = Instance.new("Folder")
    folder.Name = "FlingDetect"
    folder.Parent = ReplicatedStorage
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

print("✅ Touch Fling исправлен! Только те, кто тебя касается — улетают очень далеко.")
