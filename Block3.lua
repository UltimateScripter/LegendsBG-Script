-- 🛡️ Legends Battleground AutoBlock w/ Walk + Dash (Exploit Version)
-- ✅ AutoBlock + Walk while Blocking + Dash Enabled
-- ✅ Mobile-Compatible | GUI Toggle

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local blockRemote = ReplicatedStorage:FindFirstChild("Block") or
    (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Blocking"))

-- GUI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "AutoBlockGUI"

local button = Instance.new("TextButton", gui)
button.Size = UDim2.new(0, 150, 0, 40)
button.Position = UDim2.new(0, 20, 0, 100)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.TextColor3 = Color3.new(1, 1, 1)
button.Text = "AutoBlock: OFF"
button.TextScaled = true
button.BorderSizePixel = 2

local enabled = false
button.MouseButton1Click:Connect(function()
	enabled = not enabled
	button.Text = enabled and "AutoBlock: ON" or "AutoBlock: OFF"
	button.BackgroundColor3 = enabled and Color3.fromRGB(30, 170, 30) or Color3.fromRGB(30, 30, 30)
end)

-- Enemy detection
local function isEnemyNear()
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

-- Block + Movement Override
local isBlocking = false
RunService.RenderStepped:Connect(function()
	if not enabled or not blockRemote then return end
	pcall(function()
		Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid")
		HRP = Character:WaitForChild("HumanoidRootPart")

		local enemyClose = isEnemyNear()
		local blockingFlag = Character:FindFirstChild("Blocking")

		if enemyClose and not isBlocking then
			isBlocking = true
			blockRemote:FireServer(true)
			Humanoid.WalkSpeed = 6 -- slow walk
		elseif not enemyClose and isBlocking then
			isBlocking = false
			blockRemote:FireServer(false)
			Humanoid.WalkSpeed = 16 -- reset
		end

		-- Force override walk speed if needed
		if isBlocking and Humanoid.WalkSpeed < 6 then
			Humanoid.WalkSpeed = 6
		end
	end)
end)

-- Manual Dash Trigger (exploit bypass)
UIS.InputBegan:Connect(function(input, gpe)
	if gpe or not enabled or not isBlocking then return end
	if input.KeyCode == Enum.KeyCode.Q then -- sidestep left
		HRP.Velocity = HRP.CFrame.RightVector * -100
	elseif input.KeyCode == Enum.KeyCode.E then -- sidestep right
		HRP.Velocity = HRP.CFrame.RightVector * 100
	elseif input.KeyCode == Enum.KeyCode.S then -- backdash
		HRP.Velocity = HRP.CFrame.LookVector * -100
	elseif input.KeyCode == Enum.KeyCode.W then -- front dash
		HRP.Velocity = HRP.CFrame.LookVector * 100
	end
end)
