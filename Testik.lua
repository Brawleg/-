-- Touch Fling + Улучшенное Бессмертие (только для тебя)
-- Исправлено: смерть при выключении fling и при начале раунда

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
Frame.Size = UDim2.new(0, 180, 0, 180)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.Sarpanch
Title.Text = "Fling + GodMode"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 18

local FlingButton = Instance.new("TextButton")
FlingButton.Parent = Frame
FlingButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
FlingButton.Position = UDim2.new(0.1, 0, 0.3, 0)
FlingButton.Size = UDim2.new(0.8, 0, 0, 45)
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
local function applyGodMode(character)
    if not character or not immortalityEnabled then return end
    
    local humanoid = character:WaitForChild("Humanoid", 8)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    
    if humanoid then
        humanoid.MaxHealth = 1e9
        humanoid.Health = 1e9
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid.PlatformStand = false
        
        -- Постоянная защита
        task.spawn(function()
            while immortalityEnabled and character.Parent and humanoid.Parent do
                if humanoid.Health < 1e9 then
                    humanoid.Health = 1e9
                end
                -- Дополнительно защищаем от падения/катастроф
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                RunService.Heartbeat:Wait()
            end
        end)
    end
end

-- Применяем на текущий и все будущие персонажи
if lp.Character then
    applyGodMode(lp.Character)
end
lp.CharacterAdded:Connect(applyGodMode)

-- ==================== TOUCH FLING ====================
local function startFling()
    if flingConnection then return end
    
    flingConnection = RunService.Heartbeat:Connect(function()
        local character = lp.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local vel = hrp.Velocity
        hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
        
        task.wait() -- RenderStepped эквивалент
        hrp.Velocity = vel
        
        task.wait()
        hrp.Velocity = vel + Vector3.new(0, 0.1, 0)
    end)
end

local function stopFling()
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
    
    -- Очистка velocity, чтобы не умирать
    local character = lp.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

-- Детект
if not ReplicatedStorage:FindFirstChild("AntiFlingDetect") then
    local detect = Instance.new("Folder")
    detect.Name = "AntiFlingDetect"
    detect.Parent = ReplicatedStorage
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

print("✅ Touch Fling + GodMode исправлен!")
print("Бессмертие должно держаться при выключении fling и в Natural Disaster Survival.")
