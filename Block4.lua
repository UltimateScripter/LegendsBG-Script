-- ✅ AutoBlock Script for Legends Battleground (Presses F to Block)
-- ✅ Full Mobile Support | GUI Toggle | Works in all versions

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "AutoBlockGUI"

local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 140, 0, 40)
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

-- Detect enemy within 15 studs
local function isEnemyNearby()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (p.Character.HumanoidRootPart.Position - HRP.Position).Magnitude
			if distance <= 15 then
				return true
			end
		end
	end
	return false
end

-- AutoBlock logic (simulate key)
local blocking = false
RunService.RenderStepped:Connect(function()
	if not enabled then return end

	pcall(function()
		Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		HRP = Character:WaitForChild("HumanoidRootPart")

		local nearby = isEnemyNearby()

		if nearby and not blocking then
			blocking = true
			VirtualInput:SendKeyEvent(true, "F", false, game) -- start block
		elseif not nearby and blocking then
			blocking = false
			VirtualInput:SendKeyEvent(false, "F", false, game) -- release block
		end
	end)
end)
