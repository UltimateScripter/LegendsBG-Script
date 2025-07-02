-- Remote Spy Lite: See what RemoteEvent is triggered when you block
local ReplicatedStorage = game:GetService("ReplicatedStorage")

for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local old = v.FireServer
        hookfunction(old, function(self, ...)
            print("📡 RemoteEvent Called:", self:GetFullName(), ...)
            return old(self, ...)
        end)
    end
end
