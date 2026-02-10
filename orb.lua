-- Settings
local ORB_NAME = "ScoreOrb" -- The name you provided
local MAGNET_RANGE = 500 -- How far away it looks for orbs
local MAGNET_SPEED = 0.1 -- Refresh rate

-- UI Library Logic
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local Content = Instance.new("Frame")
local MagnetToggle = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")

-- Properties
ScreenGui.Name = "OrbMagnetGui"
ScreenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TopBar.Size = UDim2.new(1, 0, 0, 30)

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "ORB MAGNET"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = TopBar
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 18

Content.Name = "Content"
Content.Parent = MainFrame
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 30)
Content.Size = UDim2.new(1, 0, 1, -30)

MagnetToggle.Name = "MagnetToggle"
MagnetToggle.Parent = Content
MagnetToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MagnetToggle.Position = UDim2.new(0, 10, 0, 20)
MagnetToggle.Size = UDim2.new(1, -20, 0, 40)
MagnetToggle.Font = Enum.Font.GothamSemibold
MagnetToggle.Text = "Enable Magnet"
MagnetToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MagnetToggle.TextSize = 14

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = MagnetToggle

StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = Content
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0, 70)
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12

-- Functional Logic
local MagnetEnabled = false
local Player = game:GetService("Players").LocalPlayer

local function getRoot()
    return Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
end

-- Close Button logic
CloseBtn.MouseButton1Click:Connect(function()
    MagnetEnabled = false
    ScreenGui:Destroy()
end)

-- Toggle logic
MagnetToggle.MouseButton1Click:Connect(function()
    MagnetEnabled = not MagnetEnabled
    if MagnetEnabled then
        MagnetToggle.Text = "Magnet: ON"
        MagnetToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        StatusLabel.Text = "Status: Pulling Orbs..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        MagnetToggle.Text = "Enable Magnet"
        MagnetToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        StatusLabel.Text = "Status: Idle"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

-- The Magnet Loop (Teleports orbs to you)
task.spawn(function()
    while true do
        task.wait(MAGNET_SPEED)
        if MagnetEnabled then
            local root = getRoot()
            if root then
                -- Look through Workspace for ScoreOrb
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name == ORB_NAME and obj:IsA("BasePart") then
                        -- Optional distance check to prevent lag
                        local dist = (obj.Position - root.Position).Magnitude
                        if dist < MAGNET_RANGE then
                            -- Bring it directly to your character's position
                            obj.CFrame = root.CFrame
                        end
                    end
                end
            end
        end
    end
end)

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Magnet Loaded",
    Text = "Ready to collect orbs!",
    Duration = 5
})
