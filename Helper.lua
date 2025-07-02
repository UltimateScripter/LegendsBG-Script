-- Mobile-Supported Legends Battleground GUI (Full Rework + GUI Fix)

local Players = game:GetService("Players") local RunService = game:GetService("RunService") local StarterGui = game:GetService("StarterGui") local LocalPlayer = Players.LocalPlayer local Camera = workspace.CurrentCamera

local toggles = { Aimlock = false, AutoBlock = false, }

local target = nil local flying = false local flyVelocity = nil

-- GUI Setup local function createGUI() if LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("LegendsGUI") then LocalPlayer.PlayerGui.LegendsGUI:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "LegendsGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 280)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local function createButton(text, yPosition, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, yPosition)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.Text = text
    button.Parent = frame
    button.MouseButton1Click:Connect(callback)
    return button
end

local aimlockBtn = createButton("Aimlock: OFF", 5, function()
    toggles.Aimlock = not toggles.Aimlock
    aimlockBtn.Text = "Aimlock: " .. (toggles.Aimlock and "ON" or "OFF")
    if not toggles.Aimlock then target = nil end
end)

local blockBtn = createButton("AutoBlock: OFF", 40, function()
    toggles.AutoBlock = not toggles.AutoBlock
    blockBtn.Text = "AutoBlock: " .. (toggles.AutoBlock and "ON" or "OFF")
end)

local flyBtn = createButton("Fly", 75, function()
    if flying then
        flying = false
        if flyVelocity then flyVelocity:Destroy() end
        flyVelocity = nil
    else
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            flying = true
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.Velocity = Vector3.zero
            flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyVelocity.P = 12500
            flyVelocity.Name = "FlyVelocity"
            flyVelocity.Parent = root
        end
    end
end)

local upBtn = createButton("Fly Up", 110, function()
    if flying and flyVelocity then
        flyVelocity.Velocity = Vector3.new(0, 100, 0)
    end
end)

local downBtn = createButton("Fly Down", 145, function()
    if flying and flyVelocity then
        flyVelocity.Velocity = Vector3.new(0, -100, 0)
    end
end)

local resetBtn = createButton("Invincibility Reset", 180, function()
    local pos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    LocalPlayer:LoadCharacter()
    task.wait(0.25)
    if pos then
        local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        root.CFrame = CFrame.new(pos)
    end
end)

end

-- Logic local function getNearestTarget() local closest, closestDist = nil, math.huge for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then local dist = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude if dist < closestDist and p.Character.Humanoid.Health > 0 then closestDist = dist closest = p end end end return closest end

RunService.RenderStepped:Connect(function() if toggles.Aimlock then if not target or not target.Character or target.Character.Humanoid.Health <= 0 then target = getNearestTarget() end if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position) end end

if toggles.AutoBlock and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist <= 14 then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Seated)
                end
            end
        end
    end
end

end)

if LocalPlayer.Character then createGUI() else LocalPlayer.CharacterAdded:Connect(createGUI) end

