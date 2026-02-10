--[[
    OPTIMIZED ORB VACUUM
    - No more FPS lag.
    - Finds the folder automatically.
    - Sucks orbs into your chest instantly.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if CoreGui:FindFirstChild("FastVacuumUI") then CoreGui.FastVacuumUI:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FastVacuumUI"
screenGui.Parent = CoreGui

-- State
local orbName = nil
local targetFolder = nil
local active = false
local selecting = false

-- UI Setup
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 100)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, 120)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(1, -20, 1, -40)
actionBtn.Position = UDim2.new(0, 10, 0, 30)
actionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
actionBtn.Text = "SELECT ORB"
actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
actionBtn.Font = Enum.Font.SourceSansBold
actionBtn.TextSize = 18
actionBtn.Parent = mainFrame

-- Logic to find where the orbs live
local function FindOrbFolder(name)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == name then
            print("Found orbs in: " .. v.Parent:GetFullName())
            return v.Parent
        end
    end
    return Workspace
end

Mouse.Button1Down:Connect(function()
    if not selecting then return end
    local t = Mouse.Target
    if t then
        orbName = t.Name
        selecting = false
        actionBtn.Text = "FINDING FOLDER..."
        targetFolder = FindOrbFolder(orbName)
        actionBtn.Text = "VACUUM: OFF"
        actionBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 0)
    end
end)

actionBtn.MouseButton1Click:Connect(function()
    if not orbName and not selecting then
        selecting = true
        actionBtn.Text = "CLICK ORB..."
    elseif orbName then
        active = not active
        actionBtn.Text = active and "VACUUM: ON" or "VACUUM: OFF"
        actionBtn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 50, 0)
    end
end)

-- The fast loop
RunService.Heartbeat:Connect(function()
    if not active or not targetFolder or not orbName then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local targetPos = root.Position
    
    -- We only look in the targetFolder now. This is 100x faster.
    for _, obj in pairs(targetFolder:GetChildren()) do
        if obj.Name == orbName and obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.Anchored = true
            obj.CFrame = CFrame.new(targetPos)
            
            -- Trigger touch
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
close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
close.Parent = mainFrame
close.MouseButton1Click:Connect(function() screenGui:Destroy() end)
