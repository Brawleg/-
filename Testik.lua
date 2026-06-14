-- ✅ Touch Fling (Другие отлетают при касании ТЕБЯ) для Delta Executor
-- Ты стоишь стабильно, а кто тебя коснётся — улетает

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local enabled = false
local connections = {}

local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function flingPlayer(otherChar)
    if not otherChar or otherChar == lp.Character then return end
    local root = getRoot(otherChar)
    if not root then return end
    
    -- Мощный fling на другого игрока
    local bv = Instance.new("BodyVelocity")
    bv.Name = "TouchFlingBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = (root.Position - lp.Character.HumanoidRootPart.Position).Unit * 300 + Vector3.new(0, 100, 0)
    bv.Parent = root
    
    game.Debris:AddItem(bv, 0.6) -- Убираем через время
end

local function setupCharacter(char)
    if not char then return end
    task.wait(1) -- Ждём прогрузки
    
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local conn = part.Touched:Connect(function(hit)
                if not enabled then return end
                local otherChar = hit.Parent
                if otherChar and otherChar:FindFirstChild("Humanoid") and otherChar ~= char then
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
end)

-- Переподключение при респавне
lp.CharacterAdded:Connect(function(char)
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
    setupCharacter(char)
end)

if lp.Character then
    setupCharacter(lp.Character)
end

print("✅ Touch Fling (Reverse) загружен! Теперь другие отлетают, когда касаются тебя.")
