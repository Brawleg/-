-- Superman Fly + Touch Teleport Script (LocalScript)
-- Помести этот LocalScript в StarterPlayer > StarterPlayerScripts
-- Клавиши: F - включить/выключить полёт
-- Когда полёт включён, при касании другого игрока он телепортируется к тебе

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flying = false
local speed = 100  -- Скорость полёта (можно менять)
local connection = nil
local bodyVelocity = nil
local bodyGyro = nil

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function setupFly(character)
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Убираем старые
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "SupermanFlyVelocity"
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "SupermanFlyGyro"
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.P = 3000
    bodyGyro.Parent = root
    
    humanoid.PlatformStand = true
end

local function endFly(character)
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
    end
end

local function updateFly()
    if not flying then return end
    
    local character = getCharacter()
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root or not bodyVelocity or not bodyGyro then return end
    
    local moveDirection = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        moveDirection = moveDirection - Vector3.new(0, 1, 0)
    end
    
    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit
    end
    
    bodyVelocity.Velocity = moveDirection * speed
    bodyGyro.CFrame = camera.CFrame
end

-- Touch Teleport (при касании других игроков)
local function setupTouchTeleport(character)
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                if not flying then return end
                
                local hitChar = hit.Parent
                local hitHumanoid = hitChar:FindFirstChild("Humanoid")
                local hitRoot = hitChar:FindFirstChild("HumanoidRootPart")
                
                if hitHumanoid and hitRoot and hitChar ~= character then
                    -- Телепортируем игрока к себе (немного выше и спереди)
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local offset = root.CFrame.LookVector * 5 + Vector3.new(0, 3, 0)
                        hitRoot.CFrame = root.CFrame * CFrame.new(offset)
                    end
                end
            end)
        end
    end
end

-- Toggle Fly
local function toggleFly()
    flying = not flying
    local character = getCharacter()
    
    if flying then
        setupFly(character)
        print("Superman Fly ВКЛЮЧЁН! Касайся игроков - они прилетят к тебе.")
    else
        endFly(character)
        print("Superman Fly ВЫКЛЮЧЕН")
    end
end

-- Основной цикл
player.CharacterAdded:Connect(function(character)
    wait(1) -- Ждём загрузки
    if flying then
        setupFly(character)
    end
    setupTouchTeleport(character)
end)

-- Input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    end
end)

-- RenderStepped для плавного полёта
connection = RunService.RenderStepped:Connect(updateFly)

-- Инициализация
if player.Character then
    wait(1)
    setupTouchTeleport(player.Character)
end

print("Superman Fly скрипт загружен! Нажми F для включения.")
