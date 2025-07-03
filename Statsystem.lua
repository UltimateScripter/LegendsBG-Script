--[[ Legends Battlegrounds GUI Stats Bar (Mobile Friendly) Bars: Damage (Left), WalkSpeed (Middle), JumpPower (Right) Each bar is draggable to adjust the percentage (1% - 100%) Tested for Delta and Arceus X executors ]]--

local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() local Humanoid = Character:WaitForChild("Humanoid")

local screenGui = Instance.new("ScreenGui", game.CoreGui) screenGui.Name = "StatBarsGUI"

local stats = { {name = "Damage", icon = "rbxassetid://<icon1>", color = Color3.fromRGB(0, 132, 255), effect = function(pct) -- You can replace this with your damage code logic _G.DamageMultiplier = pct end}, {name = "Speed", icon = "rbxassetid://<icon2>", color = Color3.fromRGB(0, 132, 255), effect = function(pct) Humanoid.WalkSpeed = math.clamp(16 * pct, 1, 150) end}, {name = "Jump", icon = "rbxassetid://<icon3>", color = Color3.fromRGB(0, 132, 255), effect = function(pct) Humanoid.JumpPower = math.clamp(50 * pct, 1, 200) end}, }

for i, stat in ipairs(stats) do local frame = Instance.new("Frame") frame.Size = UDim2.new(0, 60, 0, 200) frame.Position = UDim2.new(0, 20 + (i - 1) * 80, 0.5, -100) frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) frame.BorderSizePixel = 0 frame.Parent = screenGui

local bar = Instance.new("Frame")
bar.Name = "Bar"
bar.Size = UDim2.new(1, 0, 1, 0)
bar.Position = UDim2.new(0, 0, 0, 0)
bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bar.BorderSizePixel = 0
bar.Parent = frame

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.new(1, 0, 0.25, 0)
fill.Position = UDim2.new(0, 0, 0.75, 0)
fill.BackgroundColor3 = stat.color
fill.BorderSizePixel = 0
fill.Parent = bar

local percentText = Instance.new("TextLabel")
percentText.Size = UDim2.new(1, 0, 0, 20)
percentText.Position = UDim2.new(0, 0, 0, 0)
percentText.BackgroundTransparency = 1
percentText.TextColor3 = Color3.new(1, 1, 1)
percentText.Font = Enum.Font.GothamBold
percentText.TextSize = 14
percentText.Text = "25%"
percentText.Parent = frame

local dragging = false
local inputY = 0

bar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        inputY = input.Position.Y
    end
end)

bar.InputEnded:Connect(function()
    dragging = false
end)

bar.InputChanged:Connect(function(input)
    if dragging then
        local relY = input.Position.Y - bar.AbsolutePosition.Y
        local pct = 1 - math.clamp(relY / bar.AbsoluteSize.Y, 0.01, 1)
        fill.Size = UDim2.new(1, 0, pct, 0)
        fill.Position = UDim2.new(0, 0, 1 - pct, 0)
        percentText.Text = tostring(math.floor(pct * 100)) .. "%"
        stat.effect(pct)
    end
end)

end

-- Optional: Default apply on load for _, stat in ipairs(stats) do stat.effect(0.25) -- 25% average default end

