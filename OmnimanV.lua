-- ✅ Superman/Omni-Man Style R6 Flying Script (With Directional Pose) -- ✅ Pose, Rotation, Particle Trail, Omni Movement, Directional Limb Anim

--// SERVICES local Players = game:GetService("Players") local RunService = game:GetService("RunService")

--// VARIABLES local player = Players.LocalPlayer local character = player.Character or player.CharacterAdded:Wait() local humanoid = character:WaitForChild("Humanoid") local hrp = character:WaitForChild("HumanoidRootPart")

local flying = false local flyLoop = nil local speed = 60 local idleTimer = 0 local idleThreshold = 0.2

--// GUI SETUP local gui = Instance.new("ScreenGui") gui.Name = "SupermanFlyR6" gui.Parent = game.CoreGui

local flyButton = Instance.new("TextButton") flyButton.Size = UDim2.new(0, 200, 0, 50) flyButton.Position = UDim2.new(0, 20, 0.5, -25) flyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255) flyButton.Text = "Fly" flyButton.Font = Enum.Font.GothamBold flyButton.TextScaled = true flyButton.TextColor3 = Color3.new(0, 0, 0) flyButton.Draggable = true flyButton.Parent = gui

--// DIRECTIONAL POSE FUNCTION local function setDirectionalPose(direction) local RS = character:FindFirstChild("Right Shoulder", true) local LS = character:FindFirstChild("Left Shoulder", true) local RH = character:FindFirstChild("Right Hip", true) local LH = character:FindFirstChild("Left Hip", true) if not (RS and LS and RH and LH) then return end

if direction == "up" or direction == "down" then
	RS.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(-math.rad(85), 0, 0)
	LS.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(-math.rad(85), 0, 0)
	RH.C0 = CFrame.new(1, -1, 0.2)
	LH.C0 = CFrame.new(-1, -1, 0.2)
elseif direction == "forward" or direction == "backward" or direction == "left" or direction == "right" then
	RS.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(-math.rad(85), math.rad(10), 0)
	LS.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(math.rad(30), 0, 0)
	RH.C0 = CFrame.new(1, -1, 0.2)
	LH.C0 = CFrame.new(-1, -1, 0.2)
else
	RS.C0 = CFrame.new(1, 0.5, 0)
	LS.C0 = CFrame.new(-1, 0.5, 0)
	RH.C0 = CFrame.new(1, -1, 0)
	LH.C0 = CFrame.new(-1, -1, 0)
end

end

--// START FLYING local function startFly() flying = true

local gyro = Instance.new("BodyGyro", hrp)
gyro.P = 90000
gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
gyro.CFrame = hrp.CFrame

local vel = Instance.new("BodyVelocity", hrp)
vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
vel.Velocity = Vector3.new(0, 0, 0)

local trailPart = Instance.new("Part")
trailPart.Size = Vector3.new(0.2, 0.2, 0.2)
trailPart.Transparency = 1
trailPart.Anchored = false
trailPart.CanCollide = false
trailPart.Name = "WindTrail"
trailPart.CFrame = hrp.CFrame
trailPart.Parent = character

local weld = Instance.new("WeldConstraint")
weld.Part0 = trailPart
weld.Part1 = hrp
weld.Parent = trailPart

local wind = Instance.new("ParticleEmitter", trailPart)
wind.Texture = "rbxassetid://483135117"
wind.Rate = 200
wind.Lifetime = NumberRange.new(0.15)
wind.Speed = NumberRange.new(25)
wind.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
wind.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.3), NumberSequenceKeypoint.new(1,1)})
wind.LightEmission = 0.8
wind.LockedToPart = true
wind.Enabled = true

character:SetAttribute("FlyGyro", gyro)
character:SetAttribute("FlyVel", vel)
character:SetAttribute("FlyTrail", trailPart)

flyLoop = RunService.Stepped:Connect(function(_, dt)
	if not flying then return end
	local cam = workspace.CurrentCamera
	local move = humanoid.MoveDirection
	gyro.CFrame = cam.CFrame
	
	if move.Magnitude > 0.1 then
		vel.Velocity = cam.CFrame.LookVector * speed
		hrppos = hrp.Position
		hrptarget = hrppos + cam.CFrame.LookVector
		hrp.CFrame = CFrame.lookAt(hrppos, hrptarget)

		local dir = cam.CFrame.LookVector
		if math.abs(dir.Y) > math.abs(dir.X) and math.abs(dir.Y) > math.abs(dir.Z) then
			if dir.Y > 0.5 then setDirectionalPose("up")
			elseif dir.Y < -0.5 then setDirectionalPose("down") end
		elseif math.abs(dir.X) > math.abs(dir.Z) then
			if dir.X > 0 then setDirectionalPose("right") else setDirectionalPose("left") end
		else
			if dir.Z > 0 then setDirectionalPose("forward") else setDirectionalPose("backward") end
		end
		idleTimer = 0
	else
		vel.Velocity = Vector3.new(0, 0.5, 0)
		idleTimer += dt
		if idleTimer >= idleThreshold then
			setDirectionalPose("idle")
		end
	end
end)

end

--// STOP FLYING local function stopFly() flying = false if flyLoop then flyLoop:Disconnect() end

local gyro = character:GetAttribute("FlyGyro")
local vel = character:GetAttribute("FlyVel")
local trail = character:GetAttribute("FlyTrail")

if typeof(gyro) == "Instance" then gyro:Destroy() end
if typeof(vel) == "Instance" then vel:Destroy() end
if typeof(trail) == "Instance" then trail:Destroy() end

end

--// BUTTON CONTROL flyButton.MouseButton1Click:Connect(function() flying = not flying if flying then startFly() flyButton.Text = "Stop Flying" flyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100) else stopFly() flyButton.Text = "Fly" flyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255) end end)

