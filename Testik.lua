-- Touch Fling для Delta (Safe, с GUI)
-- Просто вставь в Delta Executor и выполни

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local hiddenfling = false
local flingThread

-- Создаём GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TouchFlingGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.4, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Touch Fling"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 50)
ToggleButton.Position = UDim2.new(0.1, 0, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = Frame

-- Защита от анти-читов (detection)
if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
    local detection = Instance.new("Decal")
    detection.Name = "juisdfj0i32i0eidsuf0iok"
    detection.Parent = ReplicatedStorage
end

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

ToggleButton.MouseButton1Click:Connect(function()
    hiddenfling = not hiddenfling
    ToggleButton.Text = hiddenfling and "ON" or "OFF"
    ToggleButton.BackgroundColor3 = hiddenfling and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    
    if hiddenfling then
        if flingThread then coroutine.close(flingThread) end
        flingThread = coroutine.create(fling)
        coroutine.resume(flingThread)
    else
        if flingThread then
            coroutine.close(flingThread)
            flingThread = nil
        end
    end
end)

print("✅ Touch Fling загружен! Включи в GUI. Работает при касании других игроков.")
