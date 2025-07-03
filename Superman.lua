-- ✅ Fixed & Formatted Superman/Omni-Man Flying Script (Shorter Lines, Mobile Friendly) -- Includes: Directional Poses, Trail, Body Facing, GUI Toggle

--// SERVICES local Players = game:GetService("Players") local RunService = game:GetService("RunService")

--// VARIABLES local player = Players.LocalPlayer local char = player.Character or player.CharacterAdded:Wait() local humanoid = char:WaitForChild("Humanoid") local hrp = char:WaitForChild("HumanoidRootPart")

local flying = false local flyLoop = nil local speed = 60

--// GUI SETUP local gui = Instance.new("ScreenGui") gui.Name = "FlyGui" gui.ResetOnSpawn = false gui.Parent = game.CoreGui

local flyBtn = Instance.new("TextButton") flyBtn.Size = UDim2.new(0, 180, 0, 45) flyBtn.Position = UDim2.new(0, 20, 0.5, -22) flyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255) flyBtn.Text = "Fly" flyBtn.Font = Enum.Font.GothamBold flyBtn.TextScaled = true flyBtn.TextColor3 = Color3.new(0, 0, 0) flyBtn.Draggable = true flyBtn.Parent = gui

--// LIMB POSES FUNCTION local function pose(dir) local RS = char:FindFirstChild("Right Shoulder", true) local LS = char:FindFirstChild("Left Shoulder", true) local RH = char:FindFirstChild("Right Hip", true) local LH = char:FindFirstChild("Left Hip", true) if not (RS and LS and RH and LH) then return end

if dir == "up" or dir == "down" then
	RS.C0 = CFrame.new(1,0.5,0)*CFrame.Angles(-1.5,0,0)
	LS.C0 = CFrame.new(-1,0.5,0)*CFrame.Angles(-1.5,0,0)
	RH.C0 = CFrame.new(1,-1,0.2)
	LH.C0 = CFrame.new(-1,-1,0.2)
elseif dir == "forward" or dir == "left" or dir == "right" then
	RS.C0 = CFrame.new(1,0.5,0)*CFrame.Angles(-1.5,0.2,0)
	LS.C0 = CFrame.new(-1,0.5,0)*CFrame.Angles(0.5,0,0)
	RH.C0 = CFrame.new(1,-1,0.2)
	LH.C0 = CFrame.new(-1,-1,0.2)
else
	RS.C0 = CFrame.new(1,0.5,0)
	LS.C0 = CFrame.new(-1,0.5,0)
	RH.C0 = CFrame.new(1,-1,0)
	LH.C0 = CFrame.new(-1,-1,0)
end

end

--// FLY FUNCTION local function startFly() flying = true

local gyro = Instance.new("BodyGyro")
gyro.MaxTorque = Vector3.new(1e6,1e6,1e6)
gyro.P = 15000
gyro.CFrame = hrp.CFrame
gyro.Parent = hrp

local vel = Instance.new("BodyVelocity")
vel.MaxForce = Vector3.new(1e6,1e6,1e6)
vel.Velocity = Vector3.new(0,0,0)
vel.Parent = hrp

local trailPart = Instance.new("Part")
trailPart.Size = Vector3.new(0.2,0.2,0.2)
trailPart.Transparency = 1
trailPart.Anchored = false
trailPart.CanCollide = false
trailPart.Name = "WindTrail"
trailPart.CFrame = hrp.CFrame
trailPart.Parent = char

local weld = Instance.new("WeldConstraint")
weld.Part0 = trailPart
weld.Part1 = hrp
weld.Parent = trailPart

local particle = Instance.new("ParticleEmitter")
particle.Texture = "rbxassetid://483135117"
particle.Rate = 200
particle.Lifetime = NumberRange.new(0.15)
particle.Speed = NumberRange.new(25)
particle.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0,1),
	NumberSequenceKeypoint.new(1,0)
})
particle.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0,0.3),
	NumberSequenceKeypoint.new(1,1)
})
particle.LightEmission = 0.8
particle.LockedToPart = true
particle.Parent = trailPart

flyLoop = RunService.RenderStepped:Connect(function()
	if not flying then return end
	local cam = workspace.CurrentCamera
	local move = humanoid.MoveDirection
	gyro.CFrame = cam.CFrame
	if move.Magnitude > 0.1 then
		vel.Velocity = cam.CFrame.LookVector * speed
		hrppos = hrp.Position
		hrptarget = hrppos + cam.CFrame.LookVector
		hrpo = CFrame.lookAt(hrppos, hrptarget)
		hrpo = hrpo * CFrame.Angles(0, 0, 0)
		hrpo = hrpo.Rotation + Vector3.new(0, 0, 0)
		local dir = cam.CFrame.LookVector
		if math.abs(dir.Y) > math.abs(dir.X) and math.abs(dir.Y) > math.abs(dir.Z) then
			if dir.Y > 0 then pose("up") else pose("down") end
		elseif math.abs(dir.X) > math.abs(dir.Z) then
			if dir.X > 0 then pose("right") else pose("left") end
		else
			if dir.Z > 0 then pose("forward") else pose("backward") end
		end
	else
		vel.Velocity = Vector3.new(0,0.2,0)
		pose("idle")
	end
end)

end

--// STOP FLY FUNCTION local function stopFly() flying = false if flyLoop then flyLoop:Disconnect() end if hrp:FindFirstChild("BodyGyro") then hrp.BodyGyro:Destroy() end if hrp:FindFirstChild("BodyVelocity") then hrp.BodyVelocity:Destroy() end if char:FindFirstChild("WindTrail") then char.WindTrail:Destroy() end end

--// BUTTON TOGGLE flyBtn.MouseButton1Click:Connect(function() if not flying then startFly() flyBtn.Text = "Stop Fly" flyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100) else stopFly() flyBtn.Text = "Fly" flyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255) end end)

