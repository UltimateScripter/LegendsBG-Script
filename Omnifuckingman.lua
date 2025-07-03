local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- Velocity + Trail
local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(1,1,1) * 1e6
bv.P = 10000
bv.Velocity = Vector3.zero

local a1 = Instance.new("Attachment", hrp)
local a2 = Instance.new("Attachment", hrp)
a1.Position = Vector3.new(0,1,0)
a2.Position = Vector3.new(0,-1,0)
local trail = Instance.new("Trail", hrp)
trail.Attachment0 = a1
trail.Attachment1 = a2
trail.Color = ColorSequence.new(Color3.new(1,1,1))
trail.Lifetime = 0.1
trail.Enabled = false

-- GUI Panel
local gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 220, 0, 230)
panel.Position = UDim2.new(0.7, 0, 0.65, 0)
panel.BackgroundColor3 = Color3.fromRGB(30,30,30)
panel.BackgroundTransparency = 0.3

-- Movement State
local flying = false
local inputStates = {}
local moveDir = Vector3.zero

-- Fly Toggle Button ("Fly: ON/OFF")
local flyBtn = Instance.new("TextButton", panel)
flyBtn.Size = UDim2.new(0, 100, 0, 40)
flyBtn.Position = UDim2.new(0.25, 0, 0.82, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
flyBtn.TextColor3 = Color3.new(1, 1, 1)
flyBtn.TextScaled = true
flyBtn.Font = Enum.Font.GothamBold
flyBtn.Text = "Fly: OFF"

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = flying and "Fly: ON" or "Fly: OFF"
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

-- Utility button creator
local function makeBtn(txt, pos, callback)
    local btn = Instance.new("TextButton", panel)
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = pos
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = true
    btn.MouseButton1Down:Connect(function() callback(true) end)
    btn.MouseButton1Up:Connect(function() callback(false) end)
end

-- Movement keys
local directions = {
    W = Vector3.new(0,0,-1),
    S = Vector3.new(0,0,1),
    A = Vector3.new(-1,0,0),
    D = Vector3.new(1,0,0),
    U = Vector3.new(0,1,0),
    J = Vector3.new(0,-1,0),
}
local positions = {
    W = UDim2.new(0.4, 0, 0.05, 0),
    A = UDim2.new(0.1, 0, 0.35, 0),
    S = UDim2.new(0.4, 0, 0.35, 0),
    D = UDim2.new(0.7, 0, 0.35, 0),
    U = UDim2.new(0.1, 0, 0.65, 0),
    J = UDim2.new(0.7, 0, 0.65, 0),
}
for key, dir in pairs(directions) do
    makeBtn(key, positions[key], function(state)
        inputStates[key] = state
    end)
end

-- Pose logic
local function applyPose(direction)
    local torso = char:FindFirstChild("Torso")
    if not torso then return end
    for _, joint in ipairs(torso:GetChildren()) do
        if joint:IsA("Motor6D") then joint.Transform = CFrame.new() end
    end
    if direction == "up" then
        torso["Right Shoulder"].Transform = CFrame.Angles(-1.5,0,0)
        torso["Left Shoulder"].Transform = CFrame.Angles(-1.5,0,0)
    elseif direction == "down" then
        torso["Right Shoulder"].Transform = CFrame.Angles(-1.5,0,0)
        torso["Left Shoulder"].Transform = CFrame.Angles(-1.5,0,0)
    elseif direction == "forward" then
        torso["Right Shoulder"].Transform = CFrame.Angles(-1.5,0,0)
        torso["Left Shoulder"].Transform = CFrame.Angles(1.2,0,0)
    elseif direction == "idle" then
        torso["Right Shoulder"].Transform = CFrame.Angles(0.2,0,0)
        torso["Left Shoulder"].Transform = CFrame.Angles(0.2,0,0)
    end
end

-- Main flight loop
RunService.RenderStepped:Connect(function()
    if not flying then return end
    local cam = workspace.CurrentCamera
    moveDir = Vector3.zero
    for k, pressed in pairs(inputStates) do
        if pressed and directions[k] then
            moveDir += directions[k]
        end
    end

    if moveDir.Magnitude > 0 then
        local worldDir = cam.CFrame:VectorToWorldSpace(moveDir.Unit)
        bv.Velocity = worldDir * 100
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + worldDir)

        if moveDir.Y > 0.5 then
            applyPose("up")
        elseif moveDir.Y < -0.5 then
            applyPose("down")
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(tick() * 500 % 360), 0)
        else
            applyPose("forward")
        end
    else
        applyPose("idle")
        bv.Velocity = Vector3.zero
    end
end)
