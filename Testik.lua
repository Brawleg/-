-- Touch Fling + Immortality (God Mode) только для тебя
-- Полностью рабочий

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Frame_2 = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local FlingButton = Instance.new("TextButton")
local ImmortalityLabel = Instance.new("TextLabel")

ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
Frame.Position = UDim2.new(0.3885, 0, 0.35, 0)
Frame.Size = UDim2.new(0, 170, 0, 160)
Frame.Active = true
Frame.Draggable = true

Frame_2.Parent = Frame
Frame_2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame_2.Size = UDim2.new(1, 0, 0, 30)

Title.Parent = Frame_2
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Font = Enum.Font.Sarpanch
Title.Text = "Touch Fling + GodMode"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 18

FlingButton.Parent = Frame
FlingButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlingButton.Position = UDim2.new(0.1, 0, 0.35, 0)
FlingButton.Size = UDim2.new(0.8, 0, 0, 40)
FlingButton.Font = Enum.Font.SourceSansBold
FlingButton.Text = "Fling: OFF"
FlingButton.TextColor3 = Color3.fromRGB(0, 0, 0)
FlingButton.TextSize = 18

ImmortalityLabel.Parent = Frame
ImmortalityLabel.BackgroundTransparency = 1
ImmortalityLabel.Position = UDim2.new(0.1, 0, 0.7, 0)
ImmortalityLabel.Size = UDim2.new(0.8, 0, 0, 30)
ImmortalityLabel.Font = Enum.Font.SourceSans
ImmortalityLabel.Text = "GodMode: ON"
ImmortalityLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
ImmortalityLabel.TextSize = 18

-- ==================== БЕССМЕРТИЕ ====================
local immortalityEnabled = true

local function applyImmortality(character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        
        -- Дополнительная защита
        spawn(function()
            while immortalityEnabled and character.Parent do
                if humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = math.huge
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end
end

-- Применяем бессмертие при респавне
lp.CharacterAdded:Connect(applyImmortality)

-- Применяем на текущий персонаж
if lp.Character then
    applyImmortality(lp.Character)
end

-- ==================== TOUCH FLING ====================
local hiddenfling = false
local flingThread

local function fling()
    local c, hrp, vel, movel = nil, nil, nil, 0.1
    while hiddenfling do
        RunService.Heartbeat:Wait()
        c = lp.Character
        hrp = c and c:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            vel = hrp.Velocity
            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
            RunService.Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, movel, 0)
            movel = -movel
        end
    end
end

-- Детект
if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
    local d = Instance.new("Decal")
    d.Name = "juisdfj0i32i0eidsuf0iok"
    d.Parent = ReplicatedStorage
end

FlingButton.MouseButton1Click:Connect(function()
    hiddenfling = not hiddenfling
    FlingButton.Text = "Fling: " .. (hiddenfling and "ON" or "OFF")
    
    if hiddenfling then
        flingThread = coroutine.create(fling)
        coroutine.resume(flingThread)
    end
end)

print("✅ Touch Fling + GodMode загружен!")
print("Бессмертие работает только для тебя.")
