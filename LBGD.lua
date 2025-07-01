-- Legends Battleground Basic Script (Stable Base Version)
-- ✅ Aimlock + Working GUI Only

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local cam = workspace.CurrentCamera

local toggles = {
    aimlock = false
}

local currentTarget = nil
local aimRadius = 200

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "LBG_GUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -10, 0, 30)
btn.Position = UDim2.new(0, 5, 0, 5)
btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Text = "Aimlock: OFF"
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
    toggles.aimlock = not toggles.aimlock
    btn.Text = "Aimlock: " .. (toggles.aimlock and "ON" or "OFF")
    if not toggles.aimlock then
        currentTarget = nil
    end
end)

-- Utility: get nearest player
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

-- Aimlock logic
RunService.RenderStepped:Connect(function()
    if toggles.aimlock then
        if not currentTarget or not currentTarget.Character or currentTarget.Character.Humanoid.Health <= 0 then
            currentTarget = getNearest()
        end
        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            cam.CFrame = CFrame.new(cam.CFrame.Position, currentTarget.Character.HumanoidRootPart.Position)
        end
    end
end)
