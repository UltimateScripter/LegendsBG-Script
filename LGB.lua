-- Legends Battleground Enhanced Helper Script -- Updated by ChatGPT

local Players = game:GetService("Players") local RunService = game:GetService("RunService") local UIS = game:GetService("UserInputService") local LocalPlayer = Players.LocalPlayer local cam = workspace.CurrentCamera

-- Settings local aimRadius = 200 local blockDist = 20 -- for predicting incoming attacks local flyHealthThreshold = 20 -- percent local toggles = { aimlock = false, autoblock = false, autofly = false }

-- Runtime variables local currentTarget = nil local flying = false local lastPosition = nil

-- Get Closest Target local function getNearest() local closest, dist = nil, aimRadius for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then local d = (p.Character.HumanoidRootPart.Position - cam.CFrame.p).Magnitude if d < dist then dist = d closest = p end end end return closest end

-- Aimlock Handler RunService.RenderStepped:Connect(function() if toggles.aimlock then if not currentTarget or not currentTarget.Character or currentTarget.Character.Humanoid.Health <= 0 then currentTarget = getNearest() end if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then cam.CFrame = CFrame.new(cam.CFrame.Position, currentTarget.Character.HumanoidRootPart.Position) end else currentTarget = nil end end)

-- Auto Block & Auto Fly RunService.Heartbeat:Connect(function() local char = LocalPlayer.Character if not char then return end local hrp = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChild("Humanoid") if not hrp or not hum then return end

-- Auto Block (simplified, blocking always when close opponents)
if toggles.autoblock then
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local enemyHRP = p.Character.HumanoidRootPart
            local dist = (enemyHRP.Position - hrp.Position).Magnitude
            if dist <= blockDist then
                if char:FindFirstChild("Blocking") == nil then
                    local blockTool = char:FindFirstChildOfClass("Tool")
                    if blockTool and blockTool:FindFirstChild("RemoteEvent") then
                        blockTool.RemoteEvent:FireServer("Block")
                    end
                end
            end
        end
    end
end

-- Auto Fly (controllable)
if toggles.autofly and not flying and (hum.Health / hum.MaxHealth * 100) <= flyHealthThreshold then
    flying = true
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Name = "FlyControl"

    RunService.RenderStepped:Connect(function()
        if flying and bv and bv.Parent then
            local moveVec = Vector3.new()
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec = moveVec - Vector3.new(0, 1, 0) end
            bv.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * 50 or Vector3.zero
        end
    end)
end

end)

-- GUI Setup local function createGui() if LocalPlayer.PlayerGui:FindFirstChild("LBG_GUI") then LocalPlayer.PlayerGui.LBG_GUI:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "LBG_GUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.Size = UDim2.new(0, 200, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local function addToggle(name, index, toggleKey)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, 5 + index * 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = name .. ": OFF"
    btn.MouseButton1Click:Connect(function()
        toggles[toggleKey] = not toggles[toggleKey]
        btn.Text = name .. (toggles[toggleKey] and ": ON" or ": OFF")
    end)
end

local function addButton(name, index, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, 5 + index * 35)
    btn.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = name
    btn.MouseButton1Click:Connect(callback)
end

addToggle("Aimlock", 0, "aimlock")
addToggle("AutoBlock", 1, "autoblock")
addToggle("AutoFly", 2, "autofly")
addButton("Invincibility Reset", 3, function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        lastPosition = char.HumanoidRootPart.Position
        char:BreakJoints()
        task.wait(1)
        LocalPlayer:LoadCharacter()
        task.wait(1)
        local newChar = LocalPlayer.Character
        if newChar and newChar:FindFirstChild("HumanoidRootPart") then
            newChar:MoveTo(lastPosition)
            createGui()
        end
    end
end)

end

-- Initial GUI spawn createGui()

-- Recreate GUI if character respawns LocalPlayer.CharacterAdded:Connect(function() task.wait(2) createGui() end)

