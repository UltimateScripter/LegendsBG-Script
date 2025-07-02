-- Helper.lua - Utility Module for Legends Battleground GUI

local Players = game:GetService("Players") local RunService = game:GetService("RunService") local LocalPlayer = Players.LocalPlayer local Camera = workspace.CurrentCamera

local Helper = {}

function Helper.GetNearestTarget() local closestPlayer = nil local shortestDistance = math.huge

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if distance < shortestDistance and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            shortestDistance = distance
            closestPlayer = player
        end
    end
end

return closestPlayer

end

function Helper.AimAt(target) if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position) end end

function Helper.AutoBlock() for _, player in ipairs(Players:GetPlayers()) do if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude if dist <= 14 then local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Seated) end end end end end

function Helper.InstantReset() local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if hrp then local pos = hrp.Position LocalPlayer:LoadCharacter() task.delay(0.3, function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos) end end) end end

return Helper

