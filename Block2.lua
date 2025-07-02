-- Legends Battleground Mobile AutoBlock Script w/ Toggle GUI
-- 15 Stud Range |  No Stun |  Fully Mobile-Compatible

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "AutoBlockGUI"

local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0, 100)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "AutoBlock: OFF"
ToggleButton.TextScaled = true
ToggleButton.BorderSizePixel = 2
ToggleButton.BorderColor3 = Color3.new(1, 1, 1)

-- State
local autoblockEnabled = false

-- Toggle Button Function
ToggleButton.MouseButton1Click:Connect(function()
    autoblockEnabled = not autoblockEnabled
    ToggleButton.Text = autoblockEnabled and "AutoBlock: ON" or "AutoBlock: OFF"
    ToggleButton.BackgroundColor3 = autoblockEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(30, 30, 30)
end)

-- Function to get nearest enemy within 15 studs
local function getNearestEnemy()
    local closest, distance = nil, 15
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local mag = (plr.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
            if mag <= distance then
                distance = mag
                closest = plr
            end
        end
    end
    return closest
end

-- Detect and trigger block without key (NO STUN)
RunService.RenderStepped:Connect(function()
    if autoblockEnabled then
        pcall(function()
            Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            
            local enemy = getNearestEnemy()
            local blocking = Character:FindFirstChild("Blocking")
            
            if enemy and not blocking then
                local remote = ReplicatedStorage:FindFirstChild("Block")
                if remote then
                    remote:FireServer(true) -- start block
                    task.wait(0.2)
                    remote:FireServer(false) -- end block
                end
            end
        end)
    end
end)
