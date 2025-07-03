-- Legends Battleground Combined GUI Script
-- ✅ Aimlock, Fly, Invincibility Reset, AutoBlock + Dash (Mobile-compatible)
-- Created by Juring978 for UltimateScripter

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- States
local toggles = {
	aimlock = false,
	flying = false,
	autoblock = false
}
local currentTarget = nil
local aimRadius = 200
local flyVelocity = nil
local blocking = false

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "LBG_ComboGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 230)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui

local function createButton(text, yPos, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 180, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	btn.Parent = frame
	btn.MouseButton1Click:Connect(onClick)
	return btn
end

-- Aimlock Button
local aimBtn = createButton("Aimlock: OFF", 10, function()
	toggles.aimlock = not toggles.aimlock
	aimBtn.Text = "Aimlock: " .. (toggles.aimlock and "ON" or "OFF")
	if not toggles.aimlock then currentTarget = nil end
end)

-- Fly Button
createButton("Fly (Manual)", 60, function()
	toggles.flying = not toggles.flying
	if not toggles.flying then
		if flyVelocity then flyVelocity:Destroy() end
	else
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then
			flyVelocity = Instance.new("BodyVelocity")
			flyVelocity.Velocity = Vector3.new(0, 50, 0)
			flyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
			flyVelocity.Parent = root
			UIS.InputBegan:Connect(function(input)
				if not toggles.flying then return end
				if input.KeyCode == Enum.KeyCode.W then flyVelocity.Velocity = Vector3.new(0, 0, -100) end
				if input.KeyCode == Enum.KeyCode.S then flyVelocity.Velocity = Vector3.new(0, 0, 100) end
				if input.KeyCode == Enum.KeyCode.A then flyVelocity.Velocity = Vector3.new(-100, 0, 0) end
				if input.KeyCode == Enum.KeyCode.D then flyVelocity.Velocity = Vector3.new(100, 0, 0) end
			end)
		end
	end
end)

-- Invincibility Reset Button
createButton("Reset (Invincible)", 110, function()
	local char = LocalPlayer.Character
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local pos = hrp.Position
			char:BreakJoints()
			LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart").CFrame = CFrame.new(pos)
		end
	end
end)

-- AutoBlock Button
local abBtn = createButton("AutoBlock: OFF", 160, function()
	toggles.autoblock = not toggles.autoblock
	abBtn.Text = "AutoBlock: " .. (toggles.autoblock and "ON" or "OFF")
	abBtn.BackgroundColor3 = toggles.autoblock and Color3.fromRGB(30, 170, 30) or Color3.fromRGB(50, 50, 50)
end)

-- Utility: Get nearest player to camera
local function getNearest()
	local closest, dist = nil, aimRadius
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
			local d = (p.Character.HumanoidRootPart.Position - cam.CFrame.Position).Magnitude
			if d < dist then
				dist = d
				closest = p
			end
		end
	end
	return closest
end

-- Dash Function (works even while blocking)
local function dash(directionVector)
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local HRP = char:WaitForChild("HumanoidRootPart")
	local bv = Instance.new("BodyVelocity")
	bv.Velocity = directionVector.Unit * 90
	bv.MaxForce = Vector3.new(1e5, 0, 1e5)
	bv.P = 1e5
	bv.Parent = HRP
	Debris:AddItem(bv, 0.15)
end

-- Dash while blocking
UIS.InputBegan:Connect(function(input, gp)
	if not toggles.autoblock or not blocking or gp then return end
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local HRP = char:WaitForChild("HumanoidRootPart")
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

-- Check nearby enemies
local function isEnemyNearby()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local HRP = char:WaitForChild("HumanoidRootPart")
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

-- Main Loop
RunService.RenderStepped:Connect(function()
	-- Smooth Aimlock
	if toggles.aimlock then
		if not currentTarget or not currentTarget.Character or currentTarget.Character.Humanoid.Health <= 0 then
			currentTarget = getNearest()
		end
		if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
			cam.CFrame = CFrame.new(cam.CFrame.Position, currentTarget.Character.HumanoidRootPart.Position)
		end
	end

	-- AutoBlock
	if toggles.autoblock then
		pcall(function()
			local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local HRP = char:WaitForChild("HumanoidRootPart")
			local near = isEnemyNearby()
			if near and not blocking then
				blocking = true
				VirtualInput:SendKeyEvent(true, "F", false, game)
			elseif not near and blocking then
				blocking = false
				VirtualInput:SendKeyEvent(false, "F", false, game)
			end
		end)
	end
end)
