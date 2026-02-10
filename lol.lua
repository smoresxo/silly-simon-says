-- Configuration
local CLICK_TARGET_PATH = "Workspace.MiniGameObjects" -- The folder to search in
local TARGET_NAME = "Pimple" -- The parent name
local DETECTOR_NAME = "ClickDetector"

-- UI Creation
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local ClickAllBtn = Instance.new("TextButton")
local RefreshBtn = Instance.new("TextButton")

-- Properties
ScreenGui.Name = "PimpleClickerGui"
ScreenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true -- Legacy drag

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Pimple Clicker"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

ClickAllBtn.Name = "ClickAllBtn"
ClickAllBtn.Parent = MainFrame
ClickAllBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ClickAllBtn.Position = UDim2.new(0, 5, 0, 35)
ClickAllBtn.Size = UDim2.new(0, 115, 0, 30)
ClickAllBtn.Font = Enum.Font.SourceSans
ClickAllBtn.Text = "Click All"
ClickAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickAllBtn.TextSize = 16

RefreshBtn.Name = "RefreshBtn"
RefreshBtn.Parent = MainFrame
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
RefreshBtn.Position = UDim2.new(0, 130, 0, 35)
RefreshBtn.Size = UDim2.new(0, 115, 0, 30)
RefreshBtn.Font = Enum.Font.SourceSans
RefreshBtn.Text = "Refresh List"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.TextSize = 16

ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ScrollFrame.Position = UDim2.new(0, 5, 0, 70)
ScrollFrame.Size = UDim2.new(1, -10, 1, -75)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 5

UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Functions
local function getTargets()
    local found = {}
    -- Search through Workspace.MiniGameObjects
    local folder = workspace:FindFirstChild("MiniGameObjects")
    if folder then
        for _, item in pairs(folder:GetDescendants()) do
            if item:IsA("ClickDetector") and item.Parent.Name == "Pimple" then
                table.insert(found, item)
            end
        end
    end
    return found
end

local function refreshList()
    -- Clear current list
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local targets = getTargets()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #targets * 35)

    for i, detector in pairs(targets) do
        local ItemFrame = Instance.new("Frame")
        local ItemName = Instance.new("TextLabel")
        local ItemBtn = Instance.new("TextButton")

        ItemFrame.Size = UDim2.new(1, -5, 0, 30)
        ItemFrame.BackgroundTransparency = 0.8
        ItemFrame.Parent = ScrollFrame

        ItemName.Size = UDim2.new(0.6, 0, 1, 0)
        ItemName.Text = "Pimple [" .. i .. "]"
        ItemName.TextColor3 = Color3.new(1,1,1)
        ItemName.BackgroundTransparency = 1
        ItemName.Parent = ItemFrame

        ItemBtn.Size = UDim2.new(0.35, 0, 0.8, 0)
        ItemBtn.Position = UDim2.new(0.6, 0, 0.1, 0)
        ItemBtn.Text = "Click"
        ItemBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ItemBtn.TextColor3 = Color3.new(1,1,1)
        ItemBtn.Parent = ItemFrame

        ItemBtn.MouseButton1Click:Connect(function()
            if fireclickdetector then
                fireclickdetector(detector)
            else
                warn("Your executor does not support fireclickdetector")
            end
        end)
    end
end

ClickAllBtn.MouseButton1Click:Connect(function()
    local targets = getTargets()
    for _, detector in pairs(targets) do
        if fireclickdetector then
            fireclickdetector(detector)
        end
    end
end)

RefreshBtn.MouseButton1Click:Connect(refreshList)

-- Initial Load
refreshList()
