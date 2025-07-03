-- ✅ AutoBlock with Dash Buttons (Left/Right) for Mobile

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- GUI Setup
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "AutoBlockGUI"
gui.ResetOnSpawn = false

-- Toggle Button
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 160, 0, 40)
toggleButton.Position = UDim2.new(0, 20, 0, 100)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "AutoBlock: OFF"
toggleButton.TextScaled = true
toggleButton.BorderSizePixel = 2

local enabled = false
local blocking = false
local isDashing = false

toggleButton.MouseButton1Click:Connect(function()
	enabled = not enabled
	toggleButton.Text = enabled and "AutoBlock: ON" or "AutoBlock: OFF"
	toggleButton.BackgroundColor3 = enabled and Color3.fromRGB(30, 170, 30) or Color3.fromRGB(30, 30, 30)
end)

-- Detect nearby enemies
local function isEnemyNearby()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (p.Character.HumanoidRootPart.Position - HRP.Position).Magnitude
			if dist <= 15 then
				return true
			end
		end
	end
	return false
end

-- Simulate keypress
local function pressKey(key)
	isDashing = true
	VirtualInput:SendKeyEvent(false, "F", false, game) -- stop block
	VirtualInput:SendKeyEvent(true, key, false, game)
	task.wait(0.12)
	VirtualInput:SendKeyEvent(false, key, false, game)
	task.delay(0.25, function()
		isDashing = false
	end)
end

-- AutoBlock Logic
RunService.RenderStepped:Connect(function()
	if not enabled then return end
	pcall(function()
		Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		HRP = Character:WaitForChild("HumanoidRootPart")
		local near = isEnemyNearby()

		if near and not blocking and not isDashing then
			blocking = true
			VirtualInput:SendKeyEvent(true, "F", false, game)
		elseif (not near or isDashing) and blocking then
			blocking = false
			VirtualInput:SendKeyEvent(false, "F", false, game)
		end
	end)
end)

-- Left Dash Button
local leftDash = Instance.new("TextButton", gui)
leftDash.Size = UDim2.new(0, 60, 0, 60)
leftDash.Position = UDim2.new(1, -160, 1, -180)
leftDash.AnchorPoint = Vector2.new(0.5, 0.5)
leftDash.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
leftDash.TextColor3 = Color3.new(1, 1, 1)
leftDash.Text = "⬅️"
leftDash.TextScaled = true
leftDash.BorderSizePixel = 2

leftDash.MouseButton1Click:Connect(function()
	if enabled then
		pressKey("Q")
	end
end)

-- Right Dash Button
local rightDash = Instance.new("TextButton", gui)
rightDash.Size = UDim2.new(0, 60, 0, 60)
rightDash.Position = UDim2.new(1, -80, 1, -180)
rightDash.AnchorPoint = Vector2.new(0.5, 0.5)
rightDash.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
rightDash.TextColor3 = Color3.new(1, 1, 1)
rightDash.Text = "➡️"
rightDash.TextScaled = true
rightDash.BorderSizePixel = 2

rightDash.MouseButton1Click:Connect(function()
	if enabled then
		pressKey("E")
	end
end)
