--[[
    UNIVERSAL OBJECT SELECTOR (Any Object/Any Item)
    
    1. Click "Toggle Select Mode" (Turns Green).
    2. Click ANY object in the game world.
    3. The tool finds its unique path (even without ClickDetectors).
    4. Click "Copy to Clipboard" to get the list for the AI.
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Cleanup old UI
if CoreGui:FindFirstChild("UniversalSelector_V3") then
    CoreGui.UniversalSelector_V3:Destroy()
end

-- ====================================================================================
-- || STATE                                                                          ||
-- ====================================================================================

local selectionModeEnabled = false
local selectedPaths = {} 
local visualHighlights = {} 

-- ====================================================================================
-- || UI CREATION                                                                    ||
-- ====================================================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalSelector_V3"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 180)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "  Universal Object Selector"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 160, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 50)
toggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
toggleButton.Text = "Select Mode: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = mainFrame

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0, 150, 0, 40)
copyButton.Position = UDim2.new(1, -160, 0, 50)
copyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
copyButton.Text = "Copy Paths"
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.Font = Enum.Font.GothamBold
copyButton.TextSize = 14
copyButton.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 60)
statusLabel.Position = UDim2.new(0, 10, 0, 100)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Text = "Status: Idle\nSelected: 0"
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- ====================================================================================
-- || CORE LOGIC                                                                     ||
-- ====================================================================================

-- Highlights the object visually
local function highlightObject(obj)
    -- Remove old highlight if it exists on this object
    if obj:FindFirstChild("SelectionHighlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "SelectionHighlight"
    highlight.Adornee = obj
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = obj
    
    table.insert(visualHighlights, highlight)
end

-- Tries to find the most "useful" parent (e.g., the Model instead of just the handle)
local function getBestTarget(target)
    if not target then return nil end
    
    -- If it's part of a model that isn't the workspace or a folder, select the model
    local model = target:FindFirstAncestorOfClass("Model")
    if model and model ~= workspace then
        return model
    end
    
    return target
end

Mouse.Button1Down:Connect(function()
    if not selectionModeEnabled then return end
    
    local target = Mouse.Target
    if target then
        -- Find the specific object or its parent model
        local finalTarget = getBestTarget(target)
        local path = finalTarget:GetFullName()
        
        -- Prevent duplicates
        local alreadyExists = false
        for _, p in pairs(selectedPaths) do
            if p == path then alreadyExists = true end
        end
        
        if not alreadyExists then
            table.insert(selectedPaths, path)
            highlightObject(finalTarget)
            statusLabel.Text = "Added: " .. finalTarget.Name .. "\nTotal Selected: " .. #selectedPaths
        else
            statusLabel.Text = "Already in list!\nTotal Selected: " .. #selectedPaths
        end
    end
end)

-- ====================================================================================
-- || BUTTON CLICKS                                                                  ||
-- ====================================================================================

toggleButton.MouseButton1Click:Connect(function()
    selectionModeEnabled = not selectionModeEnabled
    if selectionModeEnabled then
        toggleButton.Text = "Select Mode: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        statusLabel.Text = "Ready! Click any item in the world."
    else
        toggleButton.Text = "Select Mode: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        statusLabel.Text = "Selection Paused."
    end
end)

copyButton.MouseButton1Click:Connect(function()
    if #selectedPaths == 0 then
        statusLabel.Text = "Nothing to copy!"
        return
    end

    local output = "-- UNIQUE OBJECT LIST --\nlocal OBJECTS = {\n"
    for _, path in ipairs(selectedPaths) do
        output = output .. '    "' .. path .. '",\n'
    end
    output = output .. "}"

    if setclipboard then
        setclipboard(output)
        statusLabel.Text = "COPIED TO CLIPBOARD!\nPaste this to the AI."
    else
        print(output)
        statusLabel.Text = "Clipboard fail! Paths printed to F9 Console."
    end
end)

closeButton.MouseButton1Click:Connect(function()
    for _, h in pairs(visualHighlights) do 
        if h then h:Destroy() end 
    end
    screenGui:Destroy()
end)
