-- Legends GUI Rework: Full Mobile Support + All Features

local Players = game:GetService("Players") local RunService = game:GetService("RunService") local UserInputService = game:GetService("UserInputService") local LocalPlayer = Players.LocalPlayer local cam = workspace.CurrentCamera

local toggles = { aimlock = false, autoblock = false }

local currentTarget = nil local aimRadius = 200 local flying = false local flyVelocity = nil local rootPart = nil

-- GUI Setup local function createGui() pcall(function() if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("LBG_GUI") then LocalPlayer.PlayerGui.LBG_GUI:Destroy() end

local gui = Instance.new("ScreenGui")
    gui.Name = "LBG_GUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 240)
    frame.Position = UDim2.new(0, 10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = gui

    local function makeToggle(name, posY)
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

    makeToggle("Aimlock", 5)
    makeToggle("AutoBlock", 40)

    local flyBtn = Instance.new("TextButton")
    flyBtn.Size = UDim2.new(1, -10, 0, 30)
    flyBtn.Position = UDim2.new(0, 5, 0, 75)
    flyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    flyBtn.TextColor3 = Color3.new(1, 1, 1)
    flyBtn.Text = "AutoFly: OFF"
    flyBtn.Parent = frame

    local flyEnabled = false
    flyBtn.MouseButton1Click:Connect(function()
        flyEnabled = not flyEnabled
        flyBtn.Text = "AutoFly: " .. (flyEnabled and "ON" or "OFF")

        if flyEnabled then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            flying = true
            rootPart = root
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyVelocity.P = 12500
            flyVelocity.Velocity = Vector3.zero
            flyVelocity.Name = "FlyVelocity"
            flyVelocity.Parent = rootPart
        else
            flying = false
            if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
        end
    end)

    local flyUpBtn = Instance.new("TextButton")
    flyUpBtn.Size = UDim2.new(0.48, 0, 0, 25)
    flyUpBtn.Position = UDim2.new(0.02, 5, 0, 110)
    flyUpBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    flyUpBtn.TextColor3 = Color3.new(1, 1, 1)
    flyUpBtn.Text = "Fly Up"
    flyUpBtn.Parent = frame

    local flyDownBtn = Instance.new("TextButton")
    flyDownBtn.Size = UDim2.new(0.48, 0, 0, 25)
    flyDownBtn.Position = UDim2.new(0.5, -5, 0, 110)
    flyDownBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    flyDownBtn.TextColor3 = Color3.new(1, 1, 1)
    flyDownBtn.Text = "Fly Down"
    flyDownBtn.Parent = frame

    flyUpBtn.MouseButton1Click:Connect(function()
        if flying and flyVelocity then
            flyVelocity.Velocity = Vector3.new(0, 75, 0)
        end
    end)

    flyDownBtn.MouseButton1Click:Connect(function()
        if flying and flyVelocity then
            flyVelocity.Velocity = Vector3.new(0, -75, 0)
        end
    end)

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, -10, 0, 30)
    resetBtn.Position = UDim2.new(0, 5, 0, 145)
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
end)

end

-- Utility local function getNearest() local closest, dist = nil, aimRadius for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then local d = (p.Character.HumanoidRootPart.Position - cam.CFrame.Position).Magnitude if d < dist then dist = d closest = p end end end return closest end

-- Main Loop RunService.RenderStepped:Connect(function() if toggles.aimlock then if not currentTarget or not currentTarget.Character or currentTarget.Character.Humanoid.Health <= 0 then currentTarget = getNearest() end if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then cam.CFrame = CFrame.new(cam.CFrame.Position, currentTarget.Character.HumanoidRootPart.Position) end end

if toggles.autoblock and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
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

-- Init if LocalPlayer.Character then createGui() else LocalPlayer.CharacterAdded:Connect(createGui) end

