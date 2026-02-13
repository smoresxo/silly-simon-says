--[[
    MARBLE VACUUM (STANDALONE REPAIR)
    - Target: Workspace.MiniGameObjects.Marble
    - Features: Auto-Scan, Physics Override, UI Toggle.
    - Year: 2026
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Cleanup old garbage
if CoreGui:FindFirstChild("MarbleFixUI") then CoreGui.MarbleFixUI:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MarbleFixUI"
screenGui.Parent = CoreGui

local active = false

-- UI Construction
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 80)
mainFrame.Position = UDim2.new(0.5, 150, 0.5, -40) -- Offset from center
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 0) -- Yellow for "Marbles"
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundTransparency = 1
title.Text = "MARBLE VACUUM"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.Text = "VACUUM: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 20
toggleBtn.Parent = mainFrame

toggleBtn.MouseButton1Click:Connect(function()
    active = not active
    toggleBtn.Text = active and "VACUUM: ON" or "VACUUM: OFF"
    toggleBtn.BackgroundColor3 = active and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

-- The Logic
RunService.Heartbeat:Connect(function()
    if not active then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Dynamically find the folder so we don't crash when it despawns
    local targetFolder = Workspace:FindFirstChild("MiniGameObjects")
    if not targetFolder then return end
    
    for _, obj in pairs(targetFolder:GetChildren()) do
        if obj.Name == "Marble" and obj:IsA("BasePart") then
            -- Ruthless redirection of object physics
            obj.CanCollide = false
            obj.Anchored = true
            obj.CFrame = root.CFrame -- Bring them directly to you
            
            -- Interaction bypass
            if firetouchinterest then
                firetouchinterest(root, obj, 0)
                firetouchinterest(root, obj, 1)
            end
        end
    end
end)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 20, 0, 20)
close.Position = UDim2.new(1, -20, 0, 0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
close.Parent = mainFrame
close.MouseButton1Click:Connect(function() screenGui:Destroy() end)
