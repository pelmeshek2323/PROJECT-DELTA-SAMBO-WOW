-- PD Sambo v6.1 (FIXED)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Camera = WS.CurrentCamera


local SETTINGS = {
    MenuKey = Enum.KeyCode.RightShift,
    ThemeColor = Color3.fromRGB(0, 170, 255),
    Features = {
        Aimbot = {
            Enabled = false,
            FOV = 90,
            Smoothness = 0.25,
            TargetPart = "Head",
            VisibleCheck = true
        },
        ESP = {
            Players = true,
            Boxes = true,
            Tracers = true,
            HealthBar = true,
            Distance = 1500,
            NPC = false,
            Color = Color3.new(1, 0.2, 0.2)
        },
        Player = {
            Speed = 17,
            JumpPower = 5,
            Noclip = false,
            Fly = false,
            GodMode = false
        },
        World = {
            Fullbright = true,
            NoFog = true,
            Time = 14
        }
    }
}


local GUI = {
    Main = nil,
    Dragging = false,
    DragStart = Vector2.new(),
    StartPos = UDim2.new()
}

local ESPCache = {}


local function CreateMovableMenu()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PD Sambo Hub"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainFrame.Visible = false
    MainFrame.Active = true
    MainFrame.Selectable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Text = "PD SAMBO HUB (Drag)"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = SETTINGS.ThemeColor
    TitleBar.TextColor3 = Color3.new(1, 1, 1)
    TitleBar.Font = Enum.Font.GothamBold
    TitleBar.Parent = MainFrame

    
    local Tabs = {"Combat", "Visuals", "Player", "World"}
    local TabFrames = {}

    for i, tabName in ipairs(Tabs) do
        
        local TabButton = Instance.new("TextButton")
        TabButton.Text = tabName
        TabButton.Size = UDim2.new(0.24, 0, 0, 30)
        TabButton.Position = UDim2.new(0.01 + (i-1)*0.25, 0, 0.08, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        TabButton.TextColor3 = Color3.new(1, 1, 1)
        TabButton.Parent = MainFrame

        
        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Size = UDim2.new(1, -10, 0.8, 0)
        TabFrame.Position = UDim2.new(0, 5, 0.15, 35)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = (i == 1)
        TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabFrame.ScrollBarThickness = 5
        TabFrame.Parent = MainFrame
        TabFrames[tabName] = TabFrame

       
        TabButton.MouseButton1Click:Connect(function()
            for _, frame in pairs(TabFrames) do
                frame.Visible = false
            end
            TabFrame.Visible = true
        end)
    end


  
    local AimbotToggle = Instance.new("TextButton")
    AimbotToggle.Text = "Aimbot: OFF"
    AimbotToggle.Size = UDim2.new(0.9, 0, 0, 30)
    AimbotToggle.Position = UDim2.new(0.05, 0, 0.05, 0)
    AimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    AimbotToggle.Parent = TabFrames.Combat

    
    local ESPToggle = Instance.new("TextButton")
    ESPToggle.Text = "ESP: OFF"
    ESPToggle.Size = UDim2.new(0.9, 0, 0, 30)
    ESPToggle.Position = UDim2.new(0.05, 0, 0.05, 0)
    ESPToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    ESPToggle.Parent = TabFrames.Visuals

  
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            GUI.Dragging = true
            GUI.DragStart = input.Position
            GUI.StartPos = MainFrame.Position
        end
    end)

    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            GUI.Dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if GUI.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - GUI.DragStart
            MainFrame.Position = UDim2.new(
                GUI.StartPos.X.Scale,
                GUI.StartPos.X.Offset + delta.X,
                GUI.StartPos.Y.Scale,
                GUI.StartPos.Y.Offset + delta.Y
            )
        end
    end)

    GUI.Main = MainFrame
    return ScreenGui
end


local function UpdateESP()
    if not SETTINGS.Features.ESP.Players then
        for _, obj in pairs(ESPCache) do
            obj:Destroy()
        end
        ESPCache = {}
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local char = player.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")

            if humanoid and humanoid.Health > 0 and root then
                if not ESPCache[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "PD_ESP"
                    highlight.FillColor = SETTINGS.Features.ESP.Color
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = char
                    ESPCache[player] = highlight
                end
            end
        end
    end
end


local function SmartAimbot()
    if not SETTINGS.Features.Aimbot.Enabled then return end

    local closest, minDist = nil, SETTINGS.Features.Aimbot.FOV
    local mousePos = UIS:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local targetPart = player.Character:FindFirstChild(SETTINGS.Features.Aimbot.TargetPart)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < minDist then
                        closest = targetPart
                        minDist = dist
                    end
                end
            end
        end
    end

    if closest then
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position, closest.Position),
            SETTINGS.Features.Aimbot.Smoothness
        )
    end
end


RS.Heartbeat:Connect(function()
    pcall(function()
        UpdateESP()
        SmartAimbot()

        if LP.Character then
            local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = SETTINGS.Features.Player.Speed
                humanoid.JumpPower = SETTINGS.Features.Player.JumpPower
                
                if SETTINGS.Features.Player.GodMode then
                    humanoid.Health = 100
                end
            end
        end

        if SETTINGS.Features.World.Fullbright then
            game.Lighting.GlobalShadows = false
            game.Lighting.Brightness = 2
        end
    end)
end
  

  local interface = CreateMovableMenu()


UIS.InputBegan:Connect(function(input)
    if input.KeyCode == SETTINGS.MenuKey then
        GUI.Main.Visible = not GUI.Main.Visible
    end
end)


interface:FindFirstChild("Combat"):FindFirstChildWhichIsA("TextButton").MouseButton1Click:Connect(function()
    SETTINGS.Features.Aimbot.Enabled = not SETTINGS.Features.Aimbot.Enabled
    interface:FindFirstChild("Combat"):FindFirstChildWhichIsA("TextButton").Text = 
        "Aimbot: " .. (SETTINGS.Features.Aimbot.Enabled and "ON" or "OFF")
end)

interface:FindFirstChild("Visuals"):FindFirstChildWhichIsA("TextButton").MouseButton1Click:Connect(function()
    SETTINGS.Features.ESP.Players = not SETTINGS.Features.ESP.Players
    interface:FindFirstChild("Visuals"):FindFirstChildWhichIsA("TextButton").Text = 
        "ESP: " .. (SETTINGS.Features.ESP.Players and "ON" or "OFF")
end)

print("loaded")
