--[[
    SIMPLIFIED JITTER MAGNET
    1. Select Target (One click).
    2. Enable (Magnet + Jitter).
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- UI Cleanup
if CoreGui:FindFirstChild("SimpleJitterUI") then CoreGui.SimpleJitterUI:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleJitterUI"
screenGui.Parent = CoreGui

-- State
local targetName = nil
local active = false
local selecting = false

-- UI Setup (Dark Mode)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 100)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -50)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Text = "JITTER MAGNET"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.Parent = mainFrame

local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(1, -20, 0, 50)
actionBtn.Position = UDim2.new(0, 10, 0, 35)
actionBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
actionBtn.Text = "SELECT TARGET"
actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
actionBtn.Font = Enum.Font.SourceSansBold
actionBtn.TextSize = 18
actionBtn.Parent = mainFrame

-- Logic
Mouse.Button1Down:Connect(function()
    if not selecting then return end
    local t = Mouse.Target
    if t then
        targetName = t.Name
        selecting = false
        actionBtn.Text = "ENABLE"
        actionBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    end
end)

actionBtn.MouseButton1Click:Connect(function()
    if not targetName and not selecting then
        selecting = true
        actionBtn.Text = "CLICK A PIMPLE..."
        actionBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    elseif targetName then
        active = not active
        actionBtn.Text = active and "STOP" or "ENABLE"
        actionBtn.BackgroundColor3 = active and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 120, 0)
    end
end)

RunService.RenderStepped:Connect(function()
    if not active or not targetName then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local baseCF = root.CFrame * CFrame.new(0, 0, -4)
    local speed = 20
    local radius = 2.5
    
    local i = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == targetName and obj:IsA("BasePart") then
            i = i + 1
            local angle = (tick() * speed) + (i * 0.7)
            obj.CanCollide = false
            obj.Anchored = true
            obj.CFrame = baseCF * CFrame.new(math.cos(angle) * radius, math.sin(angle) * radius, 0)
        end
    end
end)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -25, 0, 0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Parent = mainFrame
close.MouseButton1Click:Connect(function() screenGui:Destroy() end)
