-- Legends Battleground Script (Rebuild v2) -- ✅ Aimlock + GUI + Invincibility + Auto Fly + Auto Block (Clean Rework)

local Players = game:GetService("Players") local RunService = game:GetService("RunService") local UserInputService = game:GetService("UserInputService") local StarterGui = game:GetService("StarterGui") local LocalPlayer = Players.LocalPlayer local cam = workspace.CurrentCamera

local toggles = { aimlock = false, autofly = false, autoblock = false }

local currentTarget = nil local aimRadius = 200 local flying = false local flyVelocity local rootPart

-- GUI Setup local function createGui() if LocalPlayer.PlayerGui:FindFirstChild("LBG_GUI") then LocalPlayer.PlayerGui.LBG_GUI:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "LBG_GUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 160)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui

local function makeButton(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = name .. ": OFF"
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        toggles[name:lower()] = not toggles[name:lower()]
        btn.Text = name .. ": " .. (toggles[name:lower()] and "ON" or "OFF")
        if name == "Aimlock" and not toggles.aimlock then currentTarget = nil end
    end)
end

makeButton("Aimlock", 5)
makeButton("AutoFly", 40)
makeButton("AutoBlock", 75)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -10, 0, 30)
resetBtn.Position = UDim2.new(0, 5, 0, 110)
resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.Text = "Invincibility Reset"
resetBtn.Parent = frame

resetBtn.MouseButton1Click:Connect(function()
    local pos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    LocalPlayer:LoadCharacter()
    task.wait(0.25)
    if pos then
        local hrp = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(pos)
    end
end)

end

-- Utilities local function getNearest() local closest, dist = nil, aimRadius for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then local d = (p.Character.HumanoidRootPart.Position - cam.CFrame.Position).Magnitude if d < dist then dist = d closest = p end end end return closest end

-- Flight logic local function startFlying() if flying then return end rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if not rootPart then return end

flying = true
flyVelocity = Instance.new("BodyVelocity")
flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
flyVelocity.P = 12500
flyVelocity.Velocity = Vector3.zero
flyVelocity.Parent = rootPart

end

local function stopFlying() flying = false if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end end

-- Main Loop RunService.RenderStepped:Connect(function() -- Aimlock if toggles.aimlock then if not currentTarget or not currentTarget.Character or currentTarget.Character.Humanoid.Health <= 0 then currentTarget = getNearest() end if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then cam.CFrame = CFrame.new(cam.CFrame.Position, currentTarget.Character.HumanoidRootPart.Position) end end

-- AutoFly
if toggles.autofly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    local hp = LocalPlayer.Character.Humanoid.Health
    if hp <= 20 and not flying then
        startFlying()
    elseif hp > 20 and flying then
        stopFlying()
    end
    if flying and flyVelocity and rootPart then
        local direction = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += cam.CFrame.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= cam.CFrame.UpVector end
        flyVelocity.Velocity = direction.Unit * 75
    end
elseif flying then
    stopFlying()
end

-- AutoBlock (basic proximity check)
if toggles.autoblock and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local dist = (p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist <= 14 then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Seated) -- fake block effect
                end
            end
        end
    end
end

end)

-- Init createGui() LocalPlayer.CharacterAdded:Connect(createGui)

