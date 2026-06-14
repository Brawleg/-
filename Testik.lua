local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local lp = Players.LocalPlayer
local enabled = false
local connections = {}
local flingLoop

local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function clearSelfForces()
    local char = lp.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyForce") or v:IsA("LinearVelocity") then
            v:Destroy()
        end
    end
end

local function flingPlayer(otherChar)
    if not otherChar or otherChar == lp.Character then return end
    
    local theirRoot = getRoot(otherChar)
    local myRoot = getRoot(lp.Character)
    if not theirRoot or not myRoot then return end
    
    -- Более мощный и стабильный fling
    local bv = Instance.new("BodyVelocity")
    bv.Name = "TouchFlingBV"
    bv.MaxForce = Vector3.new(40000, 40000, 40000)  -- чуть меньше, чтобы не лагало
    bv.Velocity = (theirRoot.Position - myRoot.Position).Unit * 250 + Vector3.new(0, 120, 0)
    bv.Parent = theirRoot
    
    Debris:AddItem(bv, 0.7)
end

-- Основной цикл проверки касаний (более надёжно чем Touched)
local function startFlingLoop()
    if flingLoop then return end
    
    flingLoop = RunService.Heartbeat:Connect(function()
        if not enabled then return end
        
        local myChar = lp.Character
        local myRoot = getRoot(myChar)
        if not myRoot then return end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp then
                local theirChar = player.Character
                if theirChar then
                    local theirRoot = getRoot(theirChar)
                    if theirRoot then
                        local distance = (theirRoot.Position - myRoot.Position).Magnitude
                        if distance < 8 then  -- расстояние касания
                            flingPlayer(theirChar)
                        end
                    end
                end
            end
        end
    end)
end

local function stopFlingLoop()
    if flingLoop then
        flingLoop:Disconnect()
        flingLoop = nil
    end
    clearSelfForces()
end

local function setupCharacter(char)
    if not char then return end
    task.wait(1.5)
    
    clearSelfForces()
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 170)
Frame.Position = UDim2.new(0.4, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Touch Fling (Reverse)"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0.85, 0, 0, 60)
Toggle.Position = UDim2.new(0.075, 0, 0.42, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.TextScaled = true
Toggle.Font = Enum.Font.SourceSansBold
Toggle.Parent = Frame

Toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    Toggle.Text = enabled and "ON" or "OFF"
    Toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    
    if enabled then
        startFlingLoop()
    else
        stopFlingLoop()
    end
end)

-- Респавн
lp.CharacterAdded:Connect(function(char)
    stopFlingLoop()
    setupCharacter(char)
end)

if lp.Character then
    setupCharacter(lp.Character)
end

print("✅ Touch Fling (Reverse) улучшен! Теперь должен работать стабильнее.")
