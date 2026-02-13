--[[
    MARBLE VACUUM v3 (The "Monkey See, Monkey Click" Edition)
    - Manual Selection: Highlight objects in BLUE.
    - Targeted Vacuum: Sucks everything with that NAME into you.
    - Optimized for: Workspace.MiniGameObjects
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- CLEANUP OLD TRASH
if CoreGui:FindFirstChild("MarbleMonkeyUI") then CoreGui.MarbleMonkeyUI:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MarbleMonkeyUI"
screenGui.Parent = CoreGui

-- State
local targetName = nil
local active = false
local selecting = false

-- Highlight Visual (Your blue safety blanket)
local hoverHighlight = Instance.new("Highlight")
hoverHighlight.FillColor = Color3.fromRGB(0, 100, 255)
hoverHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
hoverHighlight.FillTransparency = 0.4
hoverHighlight.Parent = nil

-- UI Setup
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 120)
mainFrame.Position = UDim2.new(0.5, 150, 0.5, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 100, 255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "MARBLE SELECTOR"
title.TextColor3 = Color3.fromRGB(0, 150, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

local selectBtn = Instance.new("TextButton")
selectBtn.Size = UDim2.new(1, -20, 0, 35)
selectBtn.Position = UDim2.new(0, 10, 0, 30)
selectBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
selectBtn.Text = "1. CLICK TO SELECT"
selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
selectBtn.Font = Enum.Font.SourceSansBold
selectBtn.TextSize = 16
selectBtn.Parent = mainFrame

local vacuumBtn = Instance.new("TextButton")
vacuumBtn.Size = UDim2.new(1, -20, 0, 35)
vacuumBtn.Position = UDim2.new(0, 10, 0, 70)
vacuumBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
vacuumBtn.Text = "2. VACUUM: OFF"
vacuumBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
vacuumBtn.Font = Enum.Font.SourceSansBold
vacuumBtn.TextSize = 18
vacuumBtn.Parent = mainFrame

------------------------------------------------------
-- THE "SHINY BLUE" LOGIC
------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if selecting then
        local target = Mouse.Target
        if target and target:IsA("BasePart") then
            hoverHighlight.Adornee = target
            hoverHighlight.Parent = CoreGui
        else
            hoverHighlight.Adornee = nil
            hoverHighlight.Parent = nil
        end
    else
        hoverHighlight.Adornee = nil
        hoverHighlight.Parent = nil
    end
end)

------------------------------------------------------
-- SELECTION & VACUUM
------------------------------------------------------
selectBtn.MouseButton1Click:Connect(function()
    selecting = true
    selectBtn.Text = "HOVER & CLICK MARBLE"
    selectBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not selecting then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local t = Mouse.Target
        if t then
            targetName = t.Name
            selecting = false
            selectBtn.Text = "SELECTED: " .. targetName
            selectBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        end
    end
end)

vacuumBtn.MouseButton1Click:Connect(function()
    if not targetName then
        vacuumBtn.Text = "SELECT FIRST!"
        task.wait(1)
        vacuumBtn.Text = "2. VACUUM: OFF"
        return
    end
    active = not active
    vacuumBtn.Text = active and "VACUUM: ON" or "VACUUM: OFF"
    vacuumBtn.BackgroundColor3 = active and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 0, 0)
end)

RunService.Heartbeat:Connect(function()
    if not active or not targetName then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Look in the specific folder you mentioned
    local folder = Workspace:FindFirstChild("MiniGameObjects")
    local source = folder and folder:GetChildren() or Workspace:GetChildren()

    for _, obj in pairs(source) do
        if obj.Name == targetName and obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.Anchored = true
            obj.CFrame = root.CFrame
            
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
