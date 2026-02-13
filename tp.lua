-- Settings
local TOGGLE_KEY = Enum.KeyCode.X
local DISTANCE_IN_FRONT = 1.5 -- Extremely close to fill the screen
local ENABLED = false

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer

local connection = nil

local function toggleFreeze()
    ENABLED = not ENABLED
    
    if ENABLED then
        -- Start the 0ms Loop
        connection = RunService.RenderStepped:Connect(function()
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local camera = workspace.CurrentCamera
            
            if root and camera then
                -- Position logic: Camera position + forward offset + 180 degree flip to face you
                root.CFrame = camera.CFrame * CFrame.new(0, 0, -DISTANCE_IN_FRONT) * CFrame.Angles(0, math.pi, 0)
                
                -- Physics Freeze: Stops character from falling or shaking
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end)
        print("Camera Lock: ENABLED (Press X to stop)")
    else
        -- Stop the loop
        if connection then
            connection:Disconnect()
            connection = nil
        end
        print("Camera Lock: DISABLED")
    end
end

-- Key Listener
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == TOGGLE_KEY then
        toggleFreeze()
    end
end)

print("Script Loaded. Press 'X' to lock character to camera lens.")
