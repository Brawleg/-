-- Touch Fling (Toggle, без смерти при выкл) by Grok
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local hiddenfling = false
local flingThread = nil
local cleanupDone = true

-- GUI (простая, можно перетаскивать)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TouchFlingGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 120)
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

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 50)
ToggleButton.Position = UDim2.new(0.1, 0, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextScaled = true
ToggleButton.Parent = Frame

-- Основная функция fling
local function startFling()
    cleanupDone = false
    local c, hrp, vel, movel = nil, nil, nil, 0.1
    
    while hiddenfling do
        RunService.Heartbeat:Wait()
        
        c = lp.Character
        hrp = c and c:FindFirstChild("HumanoidRootPart")
        
        if hrp and hrp.Parent then
            vel = hrp.Velocity
            
            -- Основной fling импульс
            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            
            if hrp and hrp.Parent then
                hrp.Velocity = vel
            end
            
            RunService.Stepped:Wait()
            
            if hrp and hrp.Parent then
                hrp.Velocity = vel + Vector3.new(0, movel, 0)
                movel = -movel
            end
        end
    end
    
    -- Очистка при выключении
    if c and c.Parent then
        hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            task.wait(0.1) -- небольшая пауза для стабилизации
            if hrp and hrp.Parent then
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
    cleanupDone = true
end

-- Тоггл
ToggleButton.MouseButton1Click:Connect(function()
    hiddenfling = not hiddenfling
    
    if hiddenfling then
        ToggleButton.Text = "ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        if flingThread then
            pcall(function() coroutine.close(flingThread) end)
        end
        flingThread = coroutine.create(startFling)
        coroutine.resume(flingThread)
    else
        ToggleButton.Text = "OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        -- Флаг выключен, функция сама сделает cleanup
    end
end)

print("Touch Fling загружен! Нажми кнопку для включения/выключения.")
