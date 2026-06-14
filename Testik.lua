local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local FlyButton = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local HideButton = Instance.new("TextButton")
local PowerLabel = Instance.new("TextLabel")
local PowerSlider = Instance.new("TextButton")
local PowerBar = Instance.new("Frame")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Position = UDim2.new(0.35, 0, 0.35, 0)
Frame.Size = UDim2.new(0, 220, 0, 210)
Frame.Active = true
Frame.Draggable = true
UICorner.Parent = Frame

TextLabel.Parent = Frame
TextLabel.BackgroundTransparency = 1
TextLabel.Size = UDim2.new(1, 0, 0.14, 0)
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.Text = "Fuck Fling + Fixed Fly"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 20

ToggleButton.Parent = Frame
ToggleButton.Position = UDim2.new(0.1, 0, 0.18, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0.16, 0)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "FLING OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleButton.TextSize = 20
UICorner:Clone().Parent = ToggleButton

FlyButton.Parent = Frame
FlyButton.Position = UDim2.new(0.1, 0, 0.37, 0)
FlyButton.Size = UDim2.new(0.8, 0, 0.16, 0)
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.Text = "FLY OFF"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
FlyButton.TextSize = 20
UICorner:Clone().Parent = FlyButton

PowerLabel.Parent = Frame
PowerLabel.BackgroundTransparency = 1
PowerLabel.Position = UDim2.new(0.1, 0, 0.57, 0)
PowerLabel.Size = UDim2.new(0.8, 0, 0.11, 0)
PowerLabel.Font = Enum.Font.SourceSansBold
PowerLabel.Text = "Fling Power: 10000"
PowerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PowerLabel.TextSize = 18

PowerBar.Parent = Frame
PowerBar.Position = UDim2.new(0.1, 0, 0.7, 0)
PowerBar.Size = UDim2.new(0.8, 0, 0.08, 0)
PowerBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
UICorner:Clone().Parent = PowerBar

PowerSlider.Parent = PowerBar
PowerSlider.Size = UDim2.new(0.1, 0, 1, 0)
PowerSlider.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
UICorner:Clone().Parent = PowerSlider

HideButton.Parent = ScreenGui
HideButton.Position = UDim2.new(0.05, 0, 0.9, 0)
HideButton.Size = UDim2.new(0, 50, 0, 30)
HideButton.Font = Enum.Font.SourceSansBold
HideButton.Text = "x"
HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HideButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
UICorner:Clone().Parent = HideButton

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local hiddenfling = false
local flying = false
local flingPower = 10000
local lp = Players.LocalPlayer
local dragging = false
local flySpeed = 70

-- Anti-detection
if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
	local detection = Instance.new("Decal")
	detection.Name = "juisdfj0i32i0eidsuf0iok"
	detection.Parent = ReplicatedStorage
end

-- ==================== FIXED FLY ====================
local bv, bg = nil, nil

local function startFly()
	if flying then return end
	local character = lp.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	
	local hrp = character.HumanoidRootPart
	local humanoid = character:FindFirstChild("Humanoid")
	
	bv = Instance.new("BodyVelocity")
	bv.Name = "FlyVelocity"
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.Velocity = Vector3.new(0,0,0)
	bv.Parent = hrp
	
	bg = Instance.new("BodyGyro")
	bg.Name = "FlyGyro"
	bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bg.P = 15000
	bg.D = 500
	bg.Parent = hrp
	
	if humanoid then humanoid.PlatformStand = true end
	
	flying = true
	FlyButton.Text = "FLY ON"
	FlyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
end

local function stopFly()
	if bv then bv:Destroy() bv = nil end
	if bg then bg:Destroy() bg = nil end
	if lp.Character and lp.Character:FindFirstChild("Humanoid") then
		lp.Character.Humanoid.PlatformStand = false
	end
	flying = false
	FlyButton.Text = "FLY OFF"
	FlyButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
end

-- Исправленный цикл полёта
RunService.RenderStepped:Connect(function()
	if not flying or not bv or not bg then return end
	
	local character = lp.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	
	local camera = workspace.CurrentCamera
	local humanoid = character:FindFirstChild("Humanoid")
	local moveDir = Vector3.new(0, 0, 0)
	
	-- Клавиши (ПК)
	if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
		moveDir += camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
		moveDir -= camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then
		moveDir -= camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then
		moveDir += camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		moveDir += Vector3.new(0, 1, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		moveDir -= Vector3.new(0, 1, 0)
	end
	
	-- Мобильный джойстик (исправлено)
	if humanoid and humanoid.MoveDirection.Magnitude > 0 then
		local camRight = camera.CFrame.RightVector
		local camLook = camera.CFrame.LookVector
		
		moveDir += (camLook * humanoid.MoveDirection.Z * -1)   -- Z отрицательный = вперёд
		moveDir += (camRight * humanoid.MoveDirection.X)
	end
	
	-- Применяем движение
	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit
	end
	
	bv.Velocity = moveDir * flySpeed
	bg.CFrame = camera.CFrame
end)

-- ==================== FLING ====================
local function fling()
	local hrp, c, vel, movel = nil, nil, nil, 0.1
	
	while true do
		RunService.Heartbeat:Wait()
		if hiddenfling then
			while hiddenfling and not (c and c.Parent and hrp and hrp.Parent) do
				RunService.Heartbeat:Wait()
				c = lp.Character
				hrp = c and c:FindFirstChild("HumanoidRootPart")
			end

			if hiddenfling and hrp then
				vel = hrp.Velocity
				hrp.Velocity = vel * flingPower + Vector3.new(0, flingPower, 0)
				RunService.RenderStepped:Wait()
				if hrp and hrp.Parent then hrp.Velocity = vel end
				RunService.Stepped:Wait()
				if hrp and hrp.Parent then
					hrp.Velocity = vel + Vector3.new(0, movel, 0)
					movel = movel * -1
				end
			end
		end
	end
end

-- Buttons
ToggleButton.MouseButton1Click:Connect(function()
	hiddenfling = not hiddenfling
	if hiddenfling then
		ToggleButton.Text = "FLING ON"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	else
		ToggleButton.Text = "FLING OFF"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	end
end)

FlyButton.MouseButton1Click:Connect(function()
	if flying then stopFly() else startFly() end
end)

HideButton.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
end)

-- Power Slider
PowerSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
	end
end)

PowerSlider.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local mousePos = input.Position.X
		local barPos = PowerBar.AbsolutePosition.X
		local barSize = PowerBar.AbsoluteSize.X
		local newPos = math.clamp((mousePos - barPos) / barSize, 0, 1)
		
		PowerSlider.Position = UDim2.new(newPos, 0, 0, 0)
		flingPower = math.floor(newPos * 50000) + 5000
		PowerLabel.Text = "Fling Power: " .. flingPower
	end
end)

lp.CharacterAdded:Connect(function()
	task.wait(1)
	if flying then
		stopFly()
		task.wait(0.3)
		startFly()
	end
end)

fling()

print("Fuck Fling + Fixed Fly загружен! Управление исправлено.")
