local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local lp = Players.LocalPlayer
local enabled = false
local connections = {}

local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function clearSelfForces()
    local char = lp.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BodyVelocity") or part:IsA("BodyAngularVelocity") or part:IsA("BodyForce") then
            part:Destroy()
        end
    end
end

local function flingPlayer(otherChar)
    if not otherChar or otherChar == lp.Character then return end
    
    local root = getRoot(otherChar)
    local myRoot = getRoot(lp.Character)
    if not root or not myRoot then return end
    
    -- Мощный fling на другого
    local bv = Instance.new("BodyVelocity")
    bv.Name = "TouchFlingBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = (root.Position - myRoot.Position).Unit * 300 + Vector3.new(0, 80, 0) -- чуть слабее вверх
    bv.Parent = root
    
    Debris:AddItem(bv, 0.5)
end

local function setupCharacter(char)
    if not char then return end
    task.wait(1)
    
    -- Удаляем старые соединения
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
    
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local conn = part.Touched:Connect(function(hit)
                if not enabled then return end
                
                -- Более надёжная проверка персонажа
                local otherChar = hit:FindFirstAncestorWhichIsA("Model")
                if not otherChar then 
                    otherChar = hit.Parent 
                end
                
                if otherChar and otherChar:FindFirstChild("Humanoid") and otherChar ~= lp.Character then
                    flingPlayer(otherChar)
                end
            end)
            table.insert(connections, conn)
        end
    end
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 160)
Frame.Position = UDim2.new(0.4, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Touch Fling (Reverse)"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0.85, 0, 0, 55)
Toggle.Position = UDim2.new(0.075, 0, 0.45, 0)
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
    
    -- При выключении сразу очищаем все силы с себя
    if not enabled then
        clearSelfForces()
    end
end)

-- Переподключение при респавне
lp.CharacterAdded:Connect(function(char)
    clearSelfForces()
    setupCharacter(char)
end)

if lp.Character then
    setupCharacter(lp.Character)
end

print("✅ Touch Fling (Reverse) загружен и исправлен! Теперь ты не должен отлетать при выключении.")
