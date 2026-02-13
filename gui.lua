--[[
    MEGA HUB: ALL-IN-ONE
    Consolidated: Object Selector, XP Grinder, Orb/Marble Vacuums, Jitter Magnet, Infinite Yield
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Cleanup old Hub
if CoreGui:FindFirstChild("DarkMegaHub") then 
    CoreGui.DarkMegaHub:Destroy() 
end

-- ==========================================
-- || STATE MANAGEMENT                     ||
-- ==========================================
local AppState = {
    -- Universal Selector
    SelectModeEnabled = false,
    SelectedPaths = {},
    VisualHighlights = {},
    
    -- XP Grinder
    GrinderArm = nil,
    GrinderFloor = nil,
    GrinderActive = false,
    GrinderSelecting = nil, -- "ARM" or "FLOOR"
    
    -- Vacuums & Magnets
    OrbName = nil,
    OrbActive = false,
    OrbSelecting = false,
    
    MarbleName = nil,
    MarbleActive = false,
    MarbleSelecting = false,
    
    JitterName = nil,
    JitterActive = false,
    JitterSelecting = false
}

-- Shared Highlight Instance
local sharedHighlight = Instance.new("Highlight")
sharedHighlight.Name = "MegaHubHighlight"
sharedHighlight.FillColor = Color3.fromRGB(0, 150, 255)
sharedHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
sharedHighlight.FillTransparency = 0.5
sharedHighlight.Parent = nil

-- ==========================================
-- || UI CREATION                          ||
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkMegaHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 300)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "OMNI-HUB v1.0"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = titleBar

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -30)
sidebar.Position = UDim2.new(0, 0, 0, 30)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -140, 1, -40)
tabContainer.Position = UDim2.new(0, 135, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local function createTabButton(name, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = sidebar
    return btn
end

local tabBtns = {
    Tools = createTabButton("Tools & Utils", 0),
    Grind = createTabButton("XP Grinder", 35),
    Vacuums = createTabButton("Vacuums", 70),
    Magnets = createTabButton("Magnets", 105)
}

local tabs = {}
local function createTab(name)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = tabContainer
    tabs[name] = frame
    return frame
end

createTab("Tools")
createTab("Grind")
createTab("Vacuums")
createTab("Magnets")

local function switchTab(tabName)
    for name, frame in pairs(tabs) do frame.Visible = (name == tabName) end
    for name, btn in pairs(tabBtns) do
        btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(25, 25, 25)
        btn.TextColor3 = (name == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
    end
end
for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end
switchTab("Tools") -- Default

local function createGenericButton(parent, text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 4)
    uic.Parent = btn
    btn.Parent = parent
    return btn
end

-- ==========================================
-- || TAB 1: TOOLS & UTILS                 ||
-- ==========================================
local btnIY = createGenericButton(tabs.Tools, "Load Infinite Yield", UDim2.new(0, 5, 0, 5), Color3.fromRGB(100, 50, 150))
local btnToggleSelect = createGenericButton(tabs.Tools, "Universal Select: OFF", UDim2.new(0, 5, 0, 45), Color3.fromRGB(180, 50, 50))
local btnCopyPaths = createGenericButton(tabs.Tools, "Copy Selected Paths", UDim2.new(0, 5, 0, 85), Color3.fromRGB(0, 120, 215))

local utilStatus = Instance.new("TextLabel")
utilStatus.Size = UDim2.new(1, -10, 0, 40)
utilStatus.Position = UDim2.new(0, 5, 0, 125)
utilStatus.BackgroundTransparency = 1
utilStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
utilStatus.Text = "Universal Selector Idle"
utilStatus.TextXAlignment = Enum.TextXAlignment.Left
utilStatus.Font = Enum.Font.Gotham
utilStatus.Parent = tabs.Tools

btnIY.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

btnToggleSelect.MouseButton1Click:Connect(function()
    AppState.SelectModeEnabled = not AppState.SelectModeEnabled
    if AppState.SelectModeEnabled then
        btnToggleSelect.Text = "Universal Select: ON"
        btnToggleSelect.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        utilStatus.Text = "Click any item in the world."
    else
        btnToggleSelect.Text = "Universal Select: OFF"
        btnToggleSelect.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        utilStatus.Text = "Selection Paused."
    end
end)

btnCopyPaths.MouseButton1Click:Connect(function()
    if #AppState.SelectedPaths == 0 then
        utilStatus.Text = "Nothing to copy!"
        return
    end
    local out = "local OBJECTS = {\n"
    for _, path in ipairs(AppState.SelectedPaths) do out = out .. '    "' .. path .. '",\n' end
    out = out .. "}"
    if setclipboard then
        setclipboard(out)
        utilStatus.Text = "Copied " .. #AppState.SelectedPaths .. " paths!"
    else
        print(out)
        utilStatus.Text = "Check F9 Console."
    end
end)

-- ==========================================
-- || TAB 2: XP GRINDER                    ||
-- ==========================================
local btnArm = createGenericButton(tabs.Grind, "1. SELECT ARM", UDim2.new(0, 5, 0, 5))
local btnFloor = createGenericButton(tabs.Grind, "2. SELECT FLOOR", UDim2.new(0, 5, 0, 45))
local btnGrindStart = createGenericButton(tabs.Grind, "START GRIND LOOP", UDim2.new(0, 5, 0, 100), Color3.fromRGB(60, 0, 0))

btnArm.MouseButton1Click:Connect(function()
    AppState.GrinderSelecting = "ARM"
    btnArm.Text = "HOVER & CLICK ARM"
    btnArm.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
end)

btnFloor.MouseButton1Click:Connect(function()
    AppState.GrinderSelecting = "FLOOR"
    btnFloor.Text = "HOVER & CLICK FLOOR"
    btnFloor.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
end)

btnGrindStart.MouseButton1Click:Connect(function()
    if not AppState.GrinderArm or not AppState.GrinderFloor then
        btnGrindStart.Text = "MISSING SELECTIONS"
        task.wait(1)
        btnGrindStart.Text = "START GRIND LOOP"
        return
    end
    AppState.GrinderActive = not AppState.GrinderActive
    btnGrindStart.Text = AppState.GrinderActive and "STOP GRIND LOOP" or "START GRIND LOOP"
    btnGrindStart.BackgroundColor3 = AppState.GrinderActive and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(60, 0, 0)
end)

-- ==========================================
-- || TAB 3: VACUUMS                       ||
-- ==========================================
local btnSelOrb = createGenericButton(tabs.Vacuums, "Select Orb Target", UDim2.new(0, 5, 0, 5))
local btnVacOrb = createGenericButton(tabs.Vacuums, "ORB VACUUM: OFF", UDim2.new(0, 5, 0, 45), Color3.fromRGB(100, 50, 0))

local btnSelMarb = createGenericButton(tabs.Vacuums, "Select Marble Target", UDim2.new(0, 5, 0, 100))
local btnVacMarb = createGenericButton(tabs.Vacuums, "MARBLE VACUUM: OFF", UDim2.new(0, 5, 0, 140), Color3.fromRGB(100, 50, 0))

btnSelOrb.MouseButton1Click:Connect(function()
    AppState.OrbSelecting = true
    btnSelOrb.Text = "Click an Orb..."
    btnSelOrb.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
end)

btnVacOrb.MouseButton1Click:Connect(function()
    if not AppState.OrbName then return end
    AppState.OrbActive = not AppState.OrbActive
    btnVacOrb.Text = AppState.OrbActive and "ORB VACUUM: ON" or "ORB VACUUM: OFF"
    btnVacOrb.BackgroundColor3 = AppState.OrbActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 50, 0)
end)

btnSelMarb.MouseButton1Click:Connect(function()
    AppState.MarbleSelecting = true
    btnSelMarb.Text = "Click a Marble..."
    btnSelMarb.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
end)

btnVacMarb.MouseButton1Click:Connect(function()
    if not AppState.MarbleName then return end
    AppState.MarbleActive = not AppState.MarbleActive
    btnVacMarb.Text = AppState.MarbleActive and "MARBLE VACUUM: ON" or "MARBLE VACUUM: OFF"
    btnVacMarb.BackgroundColor3 = AppState.MarbleActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 50, 0)
end)

-- ==========================================
-- || TAB 4: MAGNETS                       ||
-- ==========================================
local btnSelJitter = createGenericButton(tabs.Magnets, "Select Jitter Target", UDim2.new(0, 5, 0, 5))
local btnJitter = createGenericButton(tabs.Magnets, "JITTER MAGNET: OFF", UDim2.new(0, 5, 0, 45), Color3.fromRGB(100, 50, 0))

btnSelJitter.MouseButton1Click:Connect(function()
    AppState.JitterSelecting = true
    btnSelJitter.Text = "Click target..."
    btnSelJitter.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
end)

btnJitter.MouseButton1Click:Connect(function()
    if not AppState.JitterName then return end
    AppState.JitterActive = not AppState.JitterActive
    btnJitter.Text = AppState.JitterActive and "JITTER MAGNET: ON" or "JITTER MAGNET: OFF"
    btnJitter.BackgroundColor3 = AppState.JitterActive and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(100, 50, 0)
end)

-- ==========================================
-- || INPUT & LOGIC LOOPS                  ||
-- ==========================================

local function getBestTarget(target)
    if not target then return nil end
    local model = target:FindFirstAncestorOfClass("Model")
    if model and model ~= workspace then return model end
    return target
end

-- Highlight Manager
RunService.RenderStepped:Connect(function()
    local needsHighlight = AppState.GrinderSelecting or AppState.OrbSelecting or AppState.MarbleSelecting or AppState.JitterSelecting
    if needsHighlight then
        local t = Mouse.Target
        if t and t:IsA("BasePart") then
            sharedHighlight.Adornee = t
            sharedHighlight.Parent = CoreGui
        else
            sharedHighlight.Adornee = nil
            sharedHighlight.Parent = nil
        end
    else
        sharedHighlight.Adornee = nil
        sharedHighlight.Parent = nil
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    
    local target = Mouse.Target
    if not target then return end

    -- 1. Universal Selector
    if AppState.SelectModeEnabled then
        local finalTarget = getBestTarget(target)
        local path = finalTarget:GetFullName()
        local exists = false
        for _, p in pairs(AppState.SelectedPaths) do if p == path then exists = true end end
        if not exists then
            table.insert(AppState.SelectedPaths, path)
            
            -- Keep individual highlights for Universal Selector
            local hl = Instance.new("Highlight")
            hl.Adornee = finalTarget
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.FillTransparency = 0.5
            hl.Parent = finalTarget
            table.insert(AppState.VisualHighlights, hl)
            
            utilStatus.Text = "Added: " .. finalTarget.Name .. " (" .. #AppState.SelectedPaths .. ")"
        end
    end

    -- 2. XP Grinder
    if AppState.GrinderSelecting == "ARM" then
        AppState.GrinderArm = target
        btnArm.Text = "ARM: " .. target.Name
        btnArm.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        AppState.GrinderSelecting = nil
    elseif AppState.GrinderSelecting == "FLOOR" then
        AppState.GrinderFloor = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        btnFloor.Text = "FLOOR SET"
        btnFloor.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        AppState.GrinderSelecting = nil
    end

    -- 3. Vacuums & Magnets
    if AppState.OrbSelecting then
        AppState.OrbName = target.Name
        btnSelOrb.Text = "Target: " .. AppState.OrbName
        btnSelOrb.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        AppState.OrbSelecting = false
    end
    
    if AppState.MarbleSelecting then
        AppState.MarbleName = target.Name
        btnSelMarb.Text = "Target: " .. AppState.MarbleName
        btnSelMarb.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        AppState.MarbleSelecting = false
    end
    
    if AppState.JitterSelecting then
        AppState.JitterName = target.Name
        btnSelJitter.Text = "Target: " .. AppState.JitterName
        btnSelJitter.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        AppState.JitterSelecting = false
    end
end)

-- Main Execution Loop (Heartbeat)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Orb Vacuum
    if AppState.OrbActive and AppState.OrbName then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == AppState.OrbName and obj:IsA("BasePart") then
                obj.CanCollide = false
                obj.Anchored = true
                obj.CFrame = root.CFrame
                if firetouchinterest then
                    firetouchinterest(root, obj, 0)
                    firetouchinterest(root, obj, 1)
                end
            end
        end
    end

    -- Marble Vacuum
    if AppState.MarbleActive and AppState.MarbleName then
        local folder = Workspace:FindFirstChild("MiniGameObjects")
        local source = folder and folder:GetChildren() or Workspace:GetChildren()
        for _, obj in pairs(source) do
            if obj.Name == AppState.MarbleName and obj:IsA("BasePart") then
                obj.CanCollide = false
                obj.Anchored = true
                obj.CFrame = root.CFrame
                if firetouchinterest then
                    firetouchinterest(root, obj, 0)
                    firetouchinterest(root, obj, 1)
                end
            end
        end
    end

    -- Jitter Magnet
    if AppState.JitterActive and AppState.JitterName then
        local baseCF = root.CFrame * CFrame.new(0, 0, -4)
        local i = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == AppState.JitterName and obj:IsA("BasePart") then
                i = i + 1
                local angle = (tick() * 20) + (i * 0.7)
                obj.CanCollide = false
                obj.Anchored = true
                obj.CFrame = baseCF * CFrame.new(math.cos(angle) * 2.5, math.sin(angle) * 2.5, 0)
            end
        end
    end
end)

-- XP Grinder Loop
task.spawn(function()
    while task.wait() do
        if AppState.GrinderActive and AppState.GrinderArm and AppState.GrinderFloor then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and AppState.GrinderArm.Parent then
                root.CFrame = AppState.GrinderArm.CFrame * CFrame.new(0, 18, 0)
                root.Velocity = Vector3.zero 
                RunService.Heartbeat:Wait()
                
                if not AppState.GrinderActive then continue end
                
                root.CFrame = AppState.GrinderFloor
                root.Velocity = Vector3.zero
                RunService.Heartbeat:Wait()
            else
                AppState.GrinderActive = false
                btnGrindStart.Text = "ERROR: LOST TARGET"
                btnGrindStart.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
            end
        end
    end
end)

-- Cleanup
closeBtn.MouseButton1Click:Connect(function()
    AppState.GrinderActive = false
    AppState.OrbActive = false
    AppState.MarbleActive = false
    AppState.JitterActive = false
    sharedHighlight:Destroy()
    for _, h in pairs(AppState.VisualHighlights) do if h then h:Destroy() end end
    screenGui:Destroy()
end)
