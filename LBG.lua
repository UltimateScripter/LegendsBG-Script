-- Legends Battleground Helper (LBG.lua)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Settings
local aimRadius = 200
local blockDist = 14
local lowHP = 50

local toggles = {
    aimlock = true,
    autoblock = true,
    autofly = true,
    invicombat = true
}

-- Utility: find nearest target
local function getNearest()
    local closest, dist = nil, aimRadius
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local part = p.Character.HumanoidRootPart
            local d = (part.Position - cam.CFrame.p).Magnitude
            if d < dist then
                dist = d; closest = part
            end
        end
    end
    return closest, dist
end

-- Aimlock
RunService:BindToRenderStep("Aimlock", Enum.RenderPriority.Camera.Value, function()
    if toggles.aimlock then
        local target = getNearest()
        if target then
            cam.CFrame = CFrame.new(cam.CFrame.p, target.Position)
        end
    end
end)

-- Auto Block & Auto Fly & Invincibility
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    -- Auto block
    if toggles.autoblock then
        local target, dist = getNearest()
        if target and dist <= blockDist then
            fireclickdetector(hrp.ClickDetector) -- adjust if block is a tool GUI
        end
    end

    -- Auto fly
    if toggles.autofly and hum.Health <= lowHP then
        local bg = hrp:FindFirstChild("BodyGyro") or Instance.new("BodyGyro", hrp)
        local bv = hrp:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity", hrp)
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.new(0, 50, 0)
    end

    -- Invincibility (auto reset safe)
    if toggles.invicombat and hum.Health <= 0 then
        hum.Health = hum.MaxHealth
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
    end
end)

-- Toggle GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0, 10, 0, 50)

local function addToggle(name, index)
    local cb = Instance.new("TextButton", Frame)
    cb.Size = UDim2.new(1, -10, 0, 30)
    cb.Position = UDim2.new(0, 5, 0, 5 + 35*index)
    cb.Text = name .. ": ON"
    cb.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    cb.TextColor3 = Color3.new(1,1,1)
    cb.MouseButton1Click:Connect(function()
        toggles[name:lower()] = not toggles[name:lower()]
        cb.Text = name .. (toggles[name:lower()] and ": ON" or ": OFF")
    end)
end

addToggle("Aimlock", 0)
addToggle("AutoBlock", 1)
addToggle("AutoFly", 2)
addToggle("Invicombat", 3)
