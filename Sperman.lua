local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

-- Replace with a working fly animation ID (since yours was a model, not raw anim)
local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://507771019" -- R15 flying pose (can replace later)
local track = hum:LoadAnimation(anim)

local flying = false
local flyDir = Vector3.new(0, 0, 0)

-- GUI setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 120, 0, 40)
toggleBtn.Position = UDim2.new(0.5, -60, 0.8, 0)
toggleBtn.Text = "Fly: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.SourceSansBold

-- Up/Down buttons
local upBtn = Instance.new("TextButton", gui)
upBtn.Size = UDim2.new(0, 60, 0, 40)
upBtn.Position = UDim2.new(0.5, -125, 0.85, 0)
upBtn.Text = "↑"
upBtn.BackgroundColor3 = Color3.fromRGB(100,200,255)
upBtn.TextColor3 = Color3.new(1,1,1)
upBtn.TextScaled = true

local downBtn = Instance.new("TextButton", gui)
downBtn.Size = UDim2.new(0, 60, 0, 40)
downBtn.Position = UDim2.new(0.5, 65, 0.85, 0)
downBtn.Text = "↓"
downBtn.BackgroundColor3 = Color3.fromRGB(100,200,255)
downBtn.TextColor3 = Color3.new(1,1,1)
downBtn.TextScaled = true

-- Toggle fly
toggleBtn.MouseButton1Click:Connect(function()
    flying = not flying
    toggleBtn.Text = flying and "Fly: ON" or "Fly: OFF"
    if flying then
        track:Play()
    else
        track:Stop()
        hrp.Velocity = Vector3.zero
    end
end)

-- Button input
upBtn.MouseButton1Click:Connect(function()
    flyDir = Vector3.new(0, 1, 0)
end)
downBtn.MouseButton1Click:Connect(function()
    flyDir = Vector3.new(0, -1, 0)
end)

-- Fly logic
rs.RenderStepped:Connect(function()
    if flying then
        local camDir = workspace.CurrentCamera.CFrame.LookVector
        local moveVec = Vector3.new(camDir.X, flyDir.Y, camDir.Z).Unit * 60
        hrp.Velocity = moveVec
    end
end)
