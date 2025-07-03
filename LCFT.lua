-- 🔥 R6 Superman Fly Script with Full Mobile Controls
-- ✅ True fly | ✅ Mobile UI | ✅ Poses | ✅ Trail | ✅ Rolling dive

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

-- Wind Trail
local a1 = Instance.new("Attachment", hrp)
local a2 = Instance.new("Attachment", hrp)
a1.Position = Vector3.new(0, 0.5, 0)
a2.Position = Vector3.new(0, -0.5, 0)
local trail = Instance.new("Trail", hrp)
trail.Attachment0 = a1
trail.Attachment1 = a2
trail.Color = ColorSequence.new(Color3.new(1, 1, 1))
trail.Lifetime = 0.1
trail.Enabled = false

-- GUI
local gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

-- Fly Toggle
local flyBtn = Instance.new("TextButton", gui)
flyBtn.Size = UDim2.new(0, 80, 0, 40)
flyBtn.Position = UDim2.new(0.85, 0, 0.75, 0)
flyBtn.Text = "Fly"
flyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
flyBtn.TextColor3 = Color3.new(1,1,1)
flyBtn.TextScaled = true
flyBtn.Font = Enum.Font.GothamBlack

-- Movement Buttons
local dir = {
	F = Vector3.new(0, 0, -1),
	B = Vector3.new(0, 0, 1),
	L = Vector3.new(-1, 0, 0),
	R = Vector3.new(1, 0, 0),
	U = Vector3.new(0, 1, 0),
	D = Vector3.new(0, -1, 0)
}
local buttons = {}
local layout = {
	F = {0.85, 0.65},
	B = {0.85, 0.85},
	L = {0.78, 0.75},
	R = {0.92, 0.75},
	U = {0.75, 0.6},
	D = {0.75, 0.85}
}
for key, pos in pairs(layout) do
	local b = Instance.new("TextButton", gui)
	b.Size = UDim2.new(0, 35, 0, 35)
	b.Position = UDim2.new(pos[1], 0, pos[2], 0)
	b.Text = key
	b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	b.TextColor3 = Color3.new(1,1,1)
	b.TextScaled = true
	b.Font = Enum.Font.GothamBold
	buttons[key] = {btn = b, pressed = false}
	b.MouseButton1Down:Connect(function() buttons[key].pressed = true end)
	b.MouseButton1Up:Connect(function() buttons[key].pressed = false end)
end

-- State
local flying = false
local speed = 100
local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(1,1,1) * 1e6
bv.P = 10000
bv.Velocity = Vector3.zero

-- Posing (R6)
local function setPose(direction)
	local torso = char:FindFirstChild("Torso")
	if not torso then return end
	for _, joint in ipairs(torso:GetChildren()) do
		if joint:IsA("Motor6D") then
			joint.Transform = CFrame.new()
		end
	end
	if direction == "up" or direction == "down" then
		torso["Right Shoulder"].Transform = CFrame.Angles(-1.5, 0, 0)
		torso["Left Shoulder"].Transform = CFrame.Angles(-1.5, 0, 0)
	elseif direction == "forward" then
		torso["Right Shoulder"].Transform = CFrame.Angles(-1.5, 0, 0)
		torso["Left Shoulder"].Transform = CFrame.Angles(1.2, 0, 0)
	end
end

-- Fly Toggle Logic
flyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		bv.Parent = hrp
		hum.PlatformStand = true
		trail.Enabled = true
	else
		bv.Parent = nil
		hum.PlatformStand = false
		trail.Enabled = false
	end
end)

-- Fly loop
rs.RenderStepped:Connect(function()
	if not flying then return end

	local cam = workspace.CurrentCamera
	local move = Vector3.new()

	for k, data in pairs(buttons) do
		if data.pressed then
			move += dir[k]
		end
	end

	if move.Magnitude > 0 then
		move = cam.CFrame:VectorToWorldSpace(move.Unit)
		bv.Velocity = move * speed
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + move)

		if move.Y > 0.5 then setPose("up")
		elseif move.Y < -0.5 then
			setPose("down")
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, tick() % math.pi * 2)
		else
			setPose("forward")
		end
	else
		bv.Velocity = Vector3.zero
	end

	-- Auto-land
	if hrp.Position.Y - workspace.FallenPartsDestroyHeight < 10 and move.Y < 0 then
		flying = false
		bv.Parent = nil
		hum.PlatformStand = false
		trail.Enabled = false
	end
end)
