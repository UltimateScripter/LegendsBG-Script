local ANIM_ID = "rbxassetid://11228653710"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local flying = false
local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(1, 1, 1) * 1e9
bv.Velocity = Vector3.zero
bv.Parent = hrp

-- Setup animation for R15
local anim = Instance.new("Animation")
anim.AnimationId = ANIM_ID
local animTrack = hum:LoadAnimation(anim)

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 120, 0, 50)
btn.Position = UDim2.new(0.5, -60, 0.85, 0)
btn.Text = "Fly: OFF"
btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.TextScaled = true
btn.Font = Enum.Font.SourceSansBold
btn.Parent = gui

-- Toggle Fly
btn.MouseButton1Click:Connect(function()
    flying = not flying
    btn.Text = flying and "Fly: ON" or "Fly: OFF"
    if flying then
        animTrack:Play()
    else
        animTrack:Stop()
        bv.Velocity = Vector3.zero
    end
end)

-- Fly logic (camera direction)
RunService.RenderStepped:Connect(function()
    if flying then
        local cam = workspace.CurrentCamera
        local dir = cam.CFrame.LookVector * 60
        bv.Velocity = Vector3.new(dir.X, 0, dir.Z)
    end
end)
