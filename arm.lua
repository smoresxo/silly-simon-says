--[[
    XP GRINDER v3 (The "Toddler Proof" Edition)
    - STRICT Visual Feedback: Only highlights when hovering in Select Mode.
    - INSTANT Cleanup: Highlight is destroyed the microsecond you click.
    - No lingering effects. No confusion.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- CLEANUP OLD TRASH
if CoreGui:FindFirstChild("XPGrindUI_v3") then CoreGui.XPGrindUI_v3:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XPGrindUI_v3"
screenGui.Parent = CoreGui

-- State variables
local armPart = nil
local floorCFrame = nil
local active = false
local selectionType = nil -- "ARM" or "FLOOR"

-- The Highlight Instance (We reuse one container to stop lag)
local hoverHighlight = Instance.new("Highlight")
hoverHighlight.Name = "HoverGlow"
hoverHighlight.FillColor = Color3.fromRGB(0, 80, 255) -- Deep Blue
hoverHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
hoverHighlight.FillTransparency = 0.5
hoverHighlight.OutlineTransparency = 0
hoverHighlight.Parent = nil -- Hidden by default

-- UI Construction
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 200)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, 130)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Aggressive Red Border
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "XP GRINDER v3"
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.Font = Enum.Font.RobotoMono
title.TextSize = 20
title.Parent = mainFrame

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, 0, 0, 20)
statusLbl.Position = UDim2.new(0, 0, 0, 30)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "WAITING FOR INPUT..."
statusLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLbl.TextSize = 14
statusLbl.Parent = mainFrame

-- BUTTONS
local btnArm = Instance.new("TextButton")
btnArm.Size = UDim2.new(1, -20, 0, 35)
btnArm.Position = UDim2.new(0, 10, 0, 60)
btnArm.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnArm.Text = "SELECT ARM"
btnArm.TextColor3 = Color3.fromRGB(255, 255, 255)
btnArm.Font = Enum.Font.SourceSansBold
btnArm.TextSize = 18
btnArm.Parent = mainFrame

local btnFloor = Instance.new("TextButton")
btnFloor.Size = UDim2.new(1, -20, 0, 35)
btnFloor.Position = UDim2.new(0, 10, 0, 100)
btnFloor.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnFloor.Text = "SELECT FLOOR"
btnFloor.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFloor.Font = Enum.Font.SourceSansBold
btnFloor.TextSize = 18
btnFloor.Parent = mainFrame

local btnStart = Instance.new("TextButton")
btnStart.Size = UDim2.new(1, -20, 0, 45)
btnStart.Position = UDim2.new(0, 10, 0, 145)
btnStart.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
btnStart.Text = "START LOOP"
btnStart.TextColor3 = Color3.fromRGB(255, 255, 255)
btnStart.Font = Enum.Font.SourceSansBold
btnStart.TextSize = 24
btnStart.Parent = mainFrame

-------------------------------------------------------------------------
-- LOGIC: VISUAL CRUTCH (The Highlight Loop)
-------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- STRICT CHECK: Only highlight if we are ACTIVELY selecting
    if selectionType then
        local target = Mouse.Target
        
        -- Only highlight BaseParts (not sky, not nothing)
        if target and target:IsA("BasePart") then
            hoverHighlight.Adornee = target
            hoverHighlight.Parent = CoreGui -- Force it to render safely
        else
            hoverHighlight.Adornee = nil
            hoverHighlight.Parent = nil
        end
    else
        -- IF NOT SELECTING, DESTROY HIGHLIGHT VISUALS INSTANTLY
        hoverHighlight.Adornee = nil
        hoverHighlight.Parent = nil
    end
end)

-------------------------------------------------------------------------
-- INPUT HANDLING
-------------------------------------------------------------------------

-- 1. Click Arm Button
btnArm.MouseButton1Click:Connect(function()
    selectionType = "ARM"
    statusLbl.Text = "HOVER OVER ARM (BLUE)"
    statusLbl.TextColor3 = Color3.fromRGB(0, 150, 255)
end)

-- 2. Click Floor Button
btnFloor.MouseButton1Click:Connect(function()
    selectionType = "FLOOR"
    statusLbl.Text = "HOVER OVER FLOOR (BLUE)"
    statusLbl.TextColor3 = Color3.fromRGB(0, 150, 255)
end)

-- 3. Confirm Selection (Mouse Click)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Don't click through UI
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if selectionType then
            local target = Mouse.Target
            
            if target then
                if selectionType == "ARM" then
                    armPart = target
                    btnArm.Text = "ARM: " .. target.Name
                    btnArm.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                elseif selectionType == "FLOOR" then
                    -- Save the position exactly where mouse hit
                    floorCFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
                    btnFloor.Text = "FLOOR SET"
                    btnFloor.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                end
                
                -- RESET STATE IMMEDIATELY
                selectionType = nil
                statusLbl.Text = "SELECTION SAVED."
                statusLbl.TextColor3 = Color3.fromRGB(0, 255, 0)
                
                -- Force visual cleanup right now
                hoverHighlight.Adornee = nil
                hoverHighlight.Parent = nil
            end
        end
    end
end)

-------------------------------------------------------------------------
-- THE GRIND LOOP (The Epilepsy Part)
-------------------------------------------------------------------------
btnStart.MouseButton1Click:Connect(function()
    if not armPart or not floorCFrame then
        btnStart.Text = "MISSING SELECTION"
        task.wait(1)
        btnStart.Text = "START LOOP"
        return
    end
    
    active = not active
    btnStart.Text = active and "STOP LOOP" or "START LOOP"
    btnStart.BackgroundColor3 = active and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(60, 0, 0)
    
    if active then
        task.spawn(function()
            while active do
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root and armPart and armPart.Parent then
                    -- 1. Teleport UP (Dodge)
                    root.CFrame = armPart.CFrame * CFrame.new(0, 18, 0)
                    root.Velocity = Vector3.zero 
                    
                    RunService.Heartbeat:Wait() -- Fast wait
                    if not active then break end

                    -- 2. Teleport DOWN (Land)
                    root.CFrame = floorCFrame
                    root.Velocity = Vector3.zero
                    
                    RunService.Heartbeat:Wait() -- Fast wait
                else
                    active = false
                    btnStart.Text = "ERROR: LOST TARGET"
                    break
                end
            end
        end)
    end
end)

-- Cleanup on close
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 20, 0, 20)
close.Position = UDim2.new(1, -20, 0, 0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
close.Parent = mainFrame
close.MouseButton1Click:Connect(function() 
    active = false 
    hoverHighlight:Destroy()
    screenGui:Destroy() 
end)
