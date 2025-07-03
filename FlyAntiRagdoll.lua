-- ✅ Fly + Anti Ragdoll GUI | Mobile-Compatible | Delta & Arceus X
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local mouse = plr:GetMouse()
local UIS = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FlyAntiRagdollGUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0, 20, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 8)

local flyButton = Instance.new("TextButton", frame)
flyButton.Size = UDim2.new(0, 230, 0, 40)
flyButton.Position = UDim2.new(0, 10, 0, 10)
flyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
flyButton.Text = "Toggle Fly"
flyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
flyButton.Font = Enum.Font.GothamBold
flyButton.TextScaled = true

local ragdollButton = Instance.new("TextButton", frame)
ragdollButton.Size = UDim2.new(0, 230, 0, 40)
ragdollButton.Position = UDim2.new(0, 10, 0, 65)
ragdollButton.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
ragdollButton.Text = "Anti Ragdoll: OFF"
ragdollButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ragdollButton.Font = Enum.Font.GothamBold
ragdollButton.TextScaled = true

-- 🛩️ Fly Script
local flying = false
local flySpeed = 50
local bodyGyro, bodyVelocity

local function startFly()
	local hrp = char:WaitForChild("HumanoidRootPart")
	bodyGyro = Instance.new("BodyGyro", hrp)
	bodyGyro.P = 9e4
	bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.cframe = hrp.CFrame

	bodyVelocity = Instance.new("BodyVelocity", hrp)
	bodyVelocity.velocity = Vector3.new(0, 0, 0)
	bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)

	RunServiceStepped = game:GetService("RunService").Stepped:Connect(function()
		local moveDir = plr:GetMouse().Hit.Position - hrp.Position
		bodyVelocity.velocity = (plr.Character.Humanoid.MoveDirection) * flySpeed
		bodyGyro.CFrame = workspace.CurrentCamera.CFrame
	end)
end

local function stopFly()
	if bodyGyro then bodyGyro:Destroy() end
	if bodyVelocity then bodyVelocity:Destroy() end
	if RunServiceStepped then RunServiceStepped:Disconnect() end
end

flyButton.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		startFly()
		flyButton.Text = "Toggle Fly (ON)"
		flyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
	else
		stopFly()
		flyButton.Text = "Toggle Fly"
		flyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
	end
end)

-- 🧱 Anti-Ragdoll Toggle
local antiRagdoll = false
ragdollButton.MouseButton1Click:Connect(function()
	antiRagdoll = not antiRagdoll
	local function toggleRagdoll(state)
		local ragdolls = {"Falling down", "Swimming", "StartRagdoll", "Pushed", "RagdollMe"}
		for _, r in pairs(ragdolls) do
			local rscript = char:FindFirstChild(r)
			if rscript then
				rscript.Disabled = state
			end
		end
	end

	toggleRagdoll(antiRagdoll)

	if antiRagdoll then
		ragdollButton.Text = "Anti Ragdoll: ON"
		ragdollButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
	else
		ragdollButton.Text = "Anti Ragdoll: OFF"
		ragdollButton.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
	end
end)
