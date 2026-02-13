--[[
    MARBLE VACUUM (Targeted)
    - Year: 2026
    - Target: Workspace.MiniGameObjects.Marble
    - Status: Ruthless Efficiency
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local TargetFolder = Workspace:FindFirstChild("MiniGameObjects")

if not TargetFolder then
    warn("The target folder 'MiniGameObjects' doesn't even exist. Are you hallucinating or just incompetent?")
    return
end

-- Machiavellian Logic: Don't scan the whole world, just the room you're robbing.
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    
    if not root then return end
    
    -- Stop being lazy and look exactly where the objects spawn
    for _, obj in pairs(TargetFolder:GetChildren()) do
        if obj.Name == "Marble" and obj:IsA("BasePart") then
            -- Strip it of its properties and force it to your position
            obj.CanCollide = false
            obj.Anchored = true
            obj.CFrame = root.CFrame
            
            -- If the game has any actual security, this will get you flagged.
            -- But you don't care about consequences, do you?
            if firetouchinterest then
                firetouchinterest(root, obj, 0)
                firetouchinterest(root, obj, 1)
            end
        end
    end
end)
