-- Touch Fling (Safe Version) - Просто ходи и касайся людей
-- Защита: не умираешь, не улетаешь сильно сам

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local hiddenfling = false
local flingThread

-- Защита от смерти и сильного отлёта (anti-ragdoll / velocity reset)
local function protectLocalPlayer()
    if lp.Character then
        local humanoid = lp.Character:FindFirstChild("Humanoid")
        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0) -- сбрасываем лишнюю скорость
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Основная функция fling
local function fling()
    local c, hrp, vel, movel = nil, nil, nil, 0.1
    
    while hiddenfling do
        RunService.Heartbeat:Wait()
        
        protectLocalPlayer() -- защита каждый тик
        
        c = lp.Character
        hrp = c and c:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            vel = hrp.Velocity
            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)  -- мощный импульс
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
            RunService.Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, movel, 0)
            movel = -movel
        end
    end
end

-- Простая GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 120)
Frame.Position = UDim2.new(0.4, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "Touch Fling"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextScaled = true
Title.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0.8, 0, 0, 50)
Toggle.Position = UDim2.new(0.1, 0, 0.4, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.TextScaled = true
Toggle.Parent = Frame

-- Детект для некоторых анти-читов
if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
    local decal = Instance.new("Decal")
    decal.Name = "juisdfj0i32i0eidsuf0iok"
    decal.Parent = ReplicatedStorage
end

Toggle.MouseButton1Click:Connect(function()
    hiddenfling = not hiddenfling
    Toggle.Text = hiddenfling and "ON" or "OFF"
    Toggle.BackgroundColor3 = hiddenfling and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    if hiddenfling then
        flingThread = coroutine.create(fling)
        coroutine.resume(flingThread)
    else
        hiddenfling = false
        protectLocalPlayer()
    end
end)

-- Авто-защита при респавне
lp.CharacterAdded:Connect(function()
    wait(1)
    protectLocalPlayer()
end)

print("Touch Fling загружен! Включи и просто ходи в людей.")
