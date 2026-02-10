--[[
    ORB VACUUM (Brute Force)
    - Select orb.
    - Sucks everything into your HumanoidRootPart.
    - No offsets, no lines, just straight to the middle.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if CoreGui:FindFirstChild("OrbVacuumUI") then CoreGui.OrbVacuumUI:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OrbVacuumUI"
screenGui.Parent = CoreGui

-- State
local orbName = nil
local active = false
local selecting = false

-- UI Setup
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 100)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
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
actionBtn.TextSize = 20
actionBtn.Parent = mainFrame

-- Logic
Mouse.Button1Down:Connect(function()
    if not selecting then return end
    local t = Mouse.Target
    if t then
        orbName = t.Name
        selecting = false
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

RunService.Heartbeat:Connect(function()
    if not active or not orbName then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local targetPos = root.Position
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == orbName and obj:IsA("BasePart") then
            -- Force them into your center
            obj.CanCollide = false
            obj.Anchored = true
            obj.CFrame = CFrame.new(targetPos)
            
            -- Optional: If the game requires a 'touch' event, this helps
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
