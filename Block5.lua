-- ✅ AutoBlock + Dash Support While Blocking (Mobile + All Versions)
-- ✅ Works on all games using "F" to block and "Q" to dash

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

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

-- Enemy detection (within 15 studs)
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

-- AutoBlock logic
local blocking = false
RunService.RenderStepped:Connect(function()
	if not enabled then return end
	pcall(function()
		Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		HRP = Character:WaitForChild("HumanoidRootPart")

		local near = isEnemyNearby()

		if near and not blocking then
			blocking = true
			VirtualInput:SendKeyEvent(true, "F", false, game) -- press F
		elseif not near and blocking then
			blocking = false
			VirtualInput:SendKeyEvent(false, "F", false, game) -- release F
		end
	end)
end)

-- Dash override while blocking
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not enabled or not blocking then return end
	if gameProcessed then return end

	local dir = input.KeyCode
	if dir == Enum.KeyCode.Q then
		HRP.Velocity = HRP.CFrame.RightVector * -100 -- dash left
	elseif dir == Enum.KeyCode.E then
		HRP.Velocity = HRP.CFrame.RightVector * 100 -- dash right
	elseif dir == Enum.KeyCode.S then
		HRP.Velocity = HRP.CFrame.LookVector * -100 -- backdash
	elseif dir == Enum.KeyCode.W then
		HRP.Velocity = HRP.CFrame.LookVector * 100 -- front dash
	end
end)
