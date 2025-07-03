-- ⚡ Omni-Man / Superman R6 Flying System (Mobile)
-- ✅ Directional Fly | ✅ Rolling Dive | ✅ Wind Trail | ✅ R6 Animations

local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Setup Trail
local trail = Instance.new("Trail", hrp)
trail.Attachment0 = Instance.new("Attachment", hrp)
trail.Attachment1 = Instance.new("Attachment", hrp)
trail.Color = ColorSequence.new(Color3.new(1,1,1))
trail.Transparency = NumberSequence.new(0.2)
trail.Lifetime = 0.15
trail.Enabled = false

-- Mobile Fly Button
local gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false
local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 100, 0, 40)
btn.Position = UDim2.new(0.85, 0, 0.8, 0)
btn.Text = "Fly"
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.TextScaled = true
btn.BorderSizePixel = 0
btn.BackgroundTransparency = 0.2
btn.AutoButtonColor = false
btn.Font = Enum.Font.GothamBlack
btn.Active = true

-- State
local flying = false
local speed = 100
local lastInput = Vector3.new(0,0,0)

-- Animations
function updatePose(direction)
	for _, limb in pairs(char:GetChildren()) do
		if limb:IsA("Motor6D") and limb.Name:find("Shoulder") or limb.Name:find("Hip") then
			limb.Transform = CFrame.new()
		end
	end

	local rightArm = char:FindFirstChild("Right Arm")
	local leftArm = char:FindFirstChild("Left Arm")
	local rightLeg = char:FindFirstChild("Right Leg")
	local leftLeg = char:FindFirstChild("Left Leg")

	if direction == "up" or direction == "down" then
		char.Torso["Right Shoulder"].Transform = CFrame.Angles(-1.5, 0, 0)
		char.Torso["Left Shoulder"].Transform = CFrame.Angles(-1.5, 0, 0)
		char.Torso["Right Hip"].Transform = CFrame.new(0, 0, 0)
		char.Torso["Left Hip"].Transform = CFrame.new(0, 0, 0)
	elseif direction == "forward" or direction == "left" or direction == "right" or direction == "back" then
		char.Torso["Right Shoulder"].Transform = CFrame.Angles(-1.5, 0, 0)
		char.Torso["Left Shoulder"].Transform = CFrame.Angles(1.5, 0, 0)
		char.Torso["Right Hip"].Transform = CFrame.Angles(0, 0, 0)
		char.Torso["Left Hip"].Transform = CFrame.Angles(0, 0, 0)
	end
end

-- Toggle Fly
btn.MouseButton1Click:Connect(function()
	flying = not flying
	hum.PlatformStand = flying
	trail.Enabled = flying
end)

-- Flying loop
rs.RenderStepped:Connect(function()
	if not flying then return end

	local cam = workspace.CurrentCamera
	local moveDir = Vector3.new()
	if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
	if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
	if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
	if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
	if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
	if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end

	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit
		hrp.Velocity = moveDir * speed
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + moveDir)

		lastInput = moveDir

		-- Pose Control
		if moveDir.Y > 0.5 then updatePose("up")
		elseif moveDir.Y < -0.5 then
			updatePose("down")
			-- Roll when diving
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, tick() * 3 % (2*math.pi))
		elseif math.abs(moveDir.X) > 0.5 then updatePose("left")
		elseif math.abs(moveDir.Z) > 0.5 then updatePose("forward")
		end
	else
		-- Idle Hover
		hrp.Velocity = Vector3.zero
	end

	-- Auto-landing pose
	if flying and moveDir.Y < 0 and hrp.Position.Y <= workspace.FallenPartsDestroyHeight + 10 then
		flying = false
		hum.PlatformStand = false
		trail.Enabled = false
	end
end)
