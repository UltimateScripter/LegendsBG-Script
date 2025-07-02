-- Legends Battleground AutoBlock Script (14 Studs)
-- Mobile-Compatible | Auto-Blocks when enemy is near (14 studs)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Block key simulation
local function pressBlockKey()
    local virtualInput = game:GetService("VirtualInputManager")
    virtualInput:SendKeyEvent(true, "F", false, game)
    task.wait(0.3) -- hold block briefly
    virtualInput:SendKeyEvent(false, "F", false, game)
end

-- Function to detect nearest enemy
local function getNearestEnemy()
    local nearest, shortest = nil, 14 -- max range 14 studs
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
            if dist <= shortest then
                shortest = dist
                nearest = player
            end
        end
    end
    return nearest
end

-- Loop: Auto-block when enemy is close
RunService.RenderStepped:Connect(function()
    pcall(function()
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        local enemy = getNearestEnemy()
        if enemy then
            pressBlockKey()
        end
    end)
end)
