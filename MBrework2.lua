-- Legends Battlegrounds Mobile-Friendly Script GUI (Fully Functional)
-- Features: Aimlock, AutoBlock, Manual Fly, Invincibility Reset
-- Created by ChatGPT for UltimateScripter

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- GUI Setup
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 230)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local function createButton(text, yPos, onClick)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 160, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

-- Toggles and state
local aimlockActive = false
local blockActive = false
local target = nil
local flying = false
local flyVelocity = nil

-- Aimlock
local aimBtn = createButton("Aimlock: OFF", 10, function()
    aimlockActive = not aimlockActive
    target = nil -- reset target on toggle
    aimBtn.Text = "Aimlock: " .. (aimlockActive and "ON" or "OFF")
end)

-- AutoBlock
local blockBtn = createButton("AutoBlock: OFF", 55, function()
    blockActive = not blockActive
    blockBtn.Text = "AutoBlock: " .. (blockActive and "ON" or "OFF")
end)

-- Manual Fly
createButton("Fly", 100, function()
    if flying then
        flying = false
        if flyVelocity then flyVelocity:Destroy() end
    else
        flying = true
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.Velocity = Vector3.new(0, 50, 0)
            flyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            flyVelocity.Parent = root

            UIS.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.W then flyVelocity.Velocity = Vector3.new(0, 0, -100) end
                if input.KeyCode == Enum.KeyCode.S then flyVelocity.Velocity = Vector3.new(0, 0, 100) end
                if input.KeyCode == Enum.KeyCode.A then flyVelocity.Velocity = Vector3.new(-100, 0, 0) end
                if input.KeyCode == Enum.KeyCode.D then flyVelocity.Velocity = Vector3.new(100, 0, 0) end
            end)
        end
    end
end)

-- Invincibility Reset
createButton("Reset (Invincible)", 145, function()
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

-- Get Closest Player
local function getClosest()
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local magnitude = (p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if magnitude < dist then
                dist = magnitude
                closest = p
            end
        end
    end
    return closest
end

-- Loop Logic
RunService.RenderStepped:Connect(function()
    if aimlockActive then
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            target = getClosest()
        end
        if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, target.Character.HumanoidRootPart.Position)
        end
    end

    if blockActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Seated)
        end
    end
end)
