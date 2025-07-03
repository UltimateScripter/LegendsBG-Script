-- ✅ R6 Flying Script | Superman Style | Mobile-Friendly | Fake Animations Included

local plr = game:GetService("Players").LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local flying = false
local flyLoop = nil
local idleTimer = 0
local idleThreshold = 0.2
local speed = 60

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SupermanFlyR6"

local flyButton = Instance.new("TextButton", gui)
flyButton.Size = UDim2.new(0, 200, 0, 50)
flyButton.Position = UDim2.new(0, 20, 0.5, -25)
flyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
flyButton.Text = "Fly"
flyButton.TextScaled = true
flyButton.Font = Enum.Font.GothamBold
flyButton.TextColor3 = Color3.new(0, 0, 0)
flyButton.Active = true
flyButton.Draggable = true

-- Helper: Animate limbs using Motor6D
local function setLimbPose(state)
	local function tweenLimb(motor, goalC0)
		if motor then
			motor.C0 = goalC0
		end
	end

	local RS = char:FindFirstChild("Right Shoulder", true)
	local LS = char:FindFirstChild("Left Shoulder", true)
	local RH = char:FindFirstChild("Right Hip", true)
	local LH = char:FindFirstChild("Left Hip", true)

	if state == "fly" then
		tweenLimb(RS, CFrame.new(1, 0.5, 0) * CFrame.Angles(-math.pi/2, 0, 0))
		tweenLimb(LS, CFrame.new(-1, 0.5, 0) * CFrame.Angles(-math.pi/2, 0, 0))
		tweenLimb(RH, CFrame.new(1, -1, 0) * CFrame.Angles(0.4, 0, 0))
		tweenLimb(LH, CFrame.new(-1, -1, 0) * CFrame.Angles(0.4, 0, 0))
	elseif state == "idle" then
		tweenLimb(RS, CFrame.new(1, 0.5, 0) * CFrame.Angles(-0.3, 0, 0))
		tweenLimb(LS, CFrame.new(-1, 0.5, 0) * CFrame.Angles(-0.3, 0, 0))
		tweenLimb(RH, CFrame.new(1, -1, 0))
		tweenLimb(LH, CFrame.new(-1, -1, 0))
	elseif state == "land" then
		tweenLimb(RS, CFrame.new(1, 0.5, 0))
		tweenLimb(LS, CFrame.new(-1, 0.5, 0))
		tweenLimb(RH, CFrame.new(1, -1, 0))
		tweenLimb(LH, CFrame.new(-1, -1, 0))
	end
end

-- Start Flying
local function startFly()
	flying = true
	local bodyGyro = Instance.new("BodyGyro", hrp)
	bodyGyro.P = 9e4
	bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.CFrame = hrp.CFrame

	local bodyVel = Instance.new("BodyVelocity", hrp)
	bodyVel.velocity = Vector3.new(0, 0, 0)
	bodyVel.maxForce = Vector3.new(9e9, 9e9, 9e9)

	setLimbPose("fly")

	flyLoop = game:GetService("RunService").Stepped:Connect(function(_, dt)
		if not flying then return end

		local moveDir = hum.MoveDirection
		local cam = workspace.CurrentCamera
		bodyGyro.CFrame = cam.CFrame

		if moveDir.Magnitude > 0.1 then
			bodyVel.Velocity = cam.CFrame.LookVector * speed
			idleTimer = 0
			setLimbPose("fly")
		else
			bodyVel.Velocity = Vector3.new(0, 0.5, 0)
			idleTimer += dt
			if idleTimer >= idleThreshold then
				setLimbPose("idle")
			end
		end
	end)

	-- Store so we can clean later
	char:SetAttribute("FlyGyro", bodyGyro)
	char:SetAttribute("FlyVel", bodyVel)
end

-- Stop Flying
local function stopFly()
	flying = false

	if flyLoop then flyLoop:Disconnect() end

	local bodyGyro = char:GetAttribute("FlyGyro")
	local bodyVel = char:GetAttribute("FlyVel")

	if typeof(bodyGyro) == "Instance" then bodyGyro:Destroy() end
	if typeof(bodyVel) == "Instance" then bodyVel:Destroy() end

	setLimbPose("land")
end

-- Button Click
flyButton.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		startFly()
		flyButton.Text = "Stop Flying"
		flyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
	else
		stopFly()
		flyButton.Text = "Fly"
		flyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
	end
end)
