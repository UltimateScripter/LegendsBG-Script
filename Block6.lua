-- ✅ AutoBlock + Dash While Blocking (BodyVelocity Override)
-- ✅ Mobile-compatible | F to block | Q/E/S/W to dash even while blocking

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "AutoBlockGUI"

local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 160, 0, 40)
toggleButton.Position = UDim2.new(0, 20, 0, 100)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "AutoBlock: OFF"
toggleButton.TextScaled = true
toggleButton.BorderSizePixel = 2

local enabled = false
toggleButton.MouseButton1Click:Connect(function()
	enabled = not enabled
	toggleButton.Text = enabled and "AutoBlock: ON" or "AutoBlock: OFF"
	toggleButton.BackgroundColor3 = enabled and Color3.fromRGB(30, 170, 30) or Color3.fromRGB(30, 30, 30)
end)

-- Check if enemy is close
local function isEnemyNearby()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (plr.Character.HumanoidRootPart.Position - HRP.Position).Magnitude
			if dist <= 15 then
				return true
			end
		end
	end
	return false
end

-- AutoBlock Logic
local blocking = false
RunService.RenderStepped:Connect(function()
	if not enabled then return end
	pcall(function()
		Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		HRP = Character:WaitForChild("HumanoidRootPart")

		local near = isEnemyNearby()

		if near and not blocking then
			blocking = true
			VirtualInput:SendKeyEvent(true, "F", false, game)
		elseif not near and blocking then
			blocking = false
			VirtualInput:SendKeyEvent(false, "F", false, game)
		end
	end)
end)

-- DASH FUNCTION (using BodyVelocity)
local function dash(directionVector)
	local bv = Instance.new("BodyVelocity")
	bv.Velocity = directionVector.Unit * 90
	bv.MaxForce = Vector3.new(1e5, 0, 1e5)
	bv.P = 1e5
	bv.Parent = HRP
	game.Debris:AddItem(bv, 0.15)
end

-- Dash Controls While Blocking
UserInputService.InputBegan:Connect(function(input, gp)
	if not enabled or not blocking or gp then return end

	if input.KeyCode == Enum.KeyCode.Q then
		dash(HRP.CFrame.RightVector * -1)
	elseif input.KeyCode == Enum.KeyCode.E then
		dash(HRP.CFrame.RightVector)
	elseif input.KeyCode == Enum.KeyCode.S then
		dash(-HRP.CFrame.LookVector)
	elseif input.KeyCode == Enum.KeyCode.W then
		dash(HRP.CFrame.LookVector)
	end
end)
