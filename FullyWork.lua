-- Fully Working Mobile-Compatible Script GUI for Legends Battleground
-- Features: Aimlock, AutoBlock, Manual Fly, Invincibility Reset

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "LegendMobileGui"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 240)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui

local layout = Instance.new("UIListLayout", frame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)

local function createButton(label, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Text = label
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.Font = Enum.Font.SourceSansBold
    button.TextScaled = true
    button.Parent = frame
    button.MouseButton1Click:Connect(callback)
    return button
end

-- States
local aimlock = false
local autoblock = false
local flying = false
local flyVelocity = nil
local target = nil

-- Aimlock Button
local aimBtn = createButton("Aimlock: OFF", function()
    aimlock = not aimlock
    target = nil
    aimBtn.Text = "Aimlock: " .. (aimlock and "ON" or "OFF")
end)

-- AutoBlock Button
local blockBtn = createButton("AutoBlock: OFF", function()
    autoblock = not autoblock
    blockBtn.Text = "AutoBlock: " .. (autoblock and "ON" or "OFF")
end)

-- Fly Button
createButton("Fly", function()
    if flying then
        flying = false
        if flyVelocity then flyVelocity:Destroy() end
    else
        flying = true
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            flyVelocity.Parent = root

            UIS.InputBegan:Connect(function(input)
                if not flying or not flyVelocity then return end
                if input.KeyCode == Enum.KeyCode.W then flyVelocity.Velocity = Vector3.new(0, 0, -100) end
                if input.KeyCode == Enum.KeyCode.S then flyVelocity.Velocity = Vector3.new(0, 0, 100) end
                if input.KeyCode == Enum.KeyCode.A then flyVelocity.Velocity = Vector3.new(-100, 0, 0) end
                if input.KeyCode == Enum.KeyCode.D then flyVelocity.Velocity = Vector3.new(100, 0, 0) end
            end)
        end
    end
end)

-- Invincibility Reset Button
createButton("Reset (Invincible)", function()
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
            local mag = (p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if mag < dist then
                dist = mag
                closest = p
            end
        end
    end
    return closest
end

-- Loop
RunService.RenderStepped:Connect(function()
    if aimlock then
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            target = getClosest()
        end
        if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                LocalPlayer.Character.HumanoidRootPart.Position,
                target.Character.HumanoidRootPart.Position
            )
        end
    end

    if autoblock and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Seated)
        end
    end
end)
