-- Stat GUI for Legends Battleground (Damage / Speed / Jump)
local p = game:GetService("Players").LocalPlayer
local h = p.Character or p.CharacterAdded:Wait():WaitForChild("Humanoid")
local g = Instance.new("ScreenGui", game.CoreGui)
g.Name = "StatBars"

local stats = {
    {n="DMG",c=Color3.fromRGB(0,132,255),f=function(v)_G.DMG=v end},
    {n="SPD",c=Color3.fromRGB(0,132,255),f=function(v)h.WalkSpeed=16*v end},
    {n="JMP",c=Color3.fromRGB(0,132,255),f=function(v)h.JumpPower=50*v end}
}

local bars = {}
for i,v in pairs(stats) do
    local f = Instance.new("Frame", g)
    f.Size = UDim2.new(0,60,0,200)
    f.Position = UDim2.new(0,20+(i-1)*80,0.5,-100)
    f.BackgroundColor3 = Color3.fromRGB(20,20,20)

    local b = Instance.new("Frame", f)
    b.Size = UDim2.new(1,0,1,0)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)

    local fill = Instance.new("Frame", b)
    fill.Size = UDim2.new(1,0,0.25,0)
    fill.Position = UDim2.new(0,0,0.75,0)
    fill.BackgroundColor3 = v.c

    local txt = Instance.new("TextLabel", f)
    txt.Size = UDim2.new(1,0,0,20)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1,1,1)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 14
    txt.Text = "25%"

    local drag = false
    b.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag = true
        end
    end)
    b.InputEnded:Connect(function() drag = false end)
    b.InputChanged:Connect(function(i)
        if drag then
            local y = i.Position.Y - b.AbsolutePosition.Y
            local pct = math.clamp(1 - y / b.AbsoluteSize.Y, 0.01, 1)
            fill.Size = UDim2.new(1,0,pct,0)
            fill.Position = UDim2.new(0,0,1 - pct,0)
            txt.Text = math.floor(pct*100).."%"
            v.f(pct)
        end
    end)
    v.f(0.25)
    table.insert(bars,{f=fill,t=txt,e=v.f})
end

local r = Instance.new("TextButton", g)
r.Size = UDim2.new(0,180,0,40)
r.Position = UDim2.new(0,20,1,-60)
r.BackgroundColor3 = Color3.fromRGB(25,25,25)
r.TextColor3 = Color3.new(1,1,1)
r.Font = Enum.Font.GothamBold
r.TextSize = 14
r.Text = "Reset to 25%"
r.MouseButton1Click:Connect(function()
    for _,v in pairs(bars) do
        v.f.Size = UDim2.new(1,0,0.25,0)
        v.f.Position = UDim2.new(0,0,0.75,0)
        v.t.Text = "25%"
        v.e(0.25)
    end
end)
