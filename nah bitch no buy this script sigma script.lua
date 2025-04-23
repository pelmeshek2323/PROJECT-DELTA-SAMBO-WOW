-- Project Delta Swift Edition v4.1
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local HTTPS = game:GetService("HttpService")
local LP = Players.LocalPlayer
local Camera = WS.CurrentCamera

-- Конфигурация (исправлено для Swift)
local CONFIG = {
    FileName = "PD_Config.json",
    Default = {
        SilentAim = {
            Enabled = false,  -- По умолчанию выключено для безопасности
            FOV = 60,
            HitChance = 95,
            TargetPart = "Head",
            ShowFOV = true
        },
        Visuals = {
            ESP = false,
            TeamCheck = true,
            NPC_ESP = false,
            Boxes = true,
            HealthBar = true
        }
    },
    Current = {}
}

-- Инициализация с проверкой Swift
local function IsSwift()
    return identifyexecutor and string.find(identifyexecutor(), "Swift") ~= nil
end

if not IsSwift() then
    warn("Рекомендуется использовать Swift Executor!")
end

-- Безопасное создание GUI
local function SafeCreateGUI()
    local success, result = pcall(function()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "PD_Sambo_HUD"
        ScreenGui.Parent = game:GetService("CoreGui")

        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 300, 0, 200)
        MainFrame.Position = UDim2.new(0.8, 0, 0.3, 0)
        MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        MainFrame.Visible = false
        MainFrame.Parent = ScreenGui

        return ScreenGui, MainFrame
    end)
    return success and result or nil
end

-- Загрузка конфига с альтернативами для Swift
local function LoadConfig()
    local jsonData = nil
    if readfile and isfile(CONFIG.FileName) then
        jsonData = HTTPS:JSONDecode(readfile(CONFIG.FileName))
    elseif syn and syn.request then
        -- Альтернатива через веб-сервер
        local response = syn.request({
            Url = "https://your-config-server.com/pd_config",
            Method = "GET"
        })
        jsonData = HTTPS:JSONDecode(response.Body)
    else
        jsonData = CONFIG.Default
    end

    CONFIG.Current = jsonData or CONFIG.Default
end

-- Обновлённый ESP с оптимизацией
local ESPCache = {}
local function UpdateESP()
    if not CONFIG.Current.Visuals.ESP then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            if not ESPCache[player] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SWIFT_ESP"
                highlight.FillColor = Color3.fromRGB(255, 50, 50)
                highlight.Parent = player.Character
                ESPCache[player] = highlight
            end
        end
    end
end

-- Безопасный аимбот для Swift
local function GetClosestTarget()
    local closest, distance = nil, CONFIG.Current.SilentAim.FOV
    local mousePos = UIS:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos = Camera:WorldToViewportPoint(root.Position)
                local diff = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                
                if diff < distance then
                    closest = root
                    distance = diff
                end
            end
        end
    end
    return closest
end

-- Основной цикл с защитой
RS.RenderStepped:Connect(function()
    pcall(function()
        if CONFIG.Current.SilentAim.Enabled then
            local target = GetClosestTarget()
            if target then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
        end

        UpdateESP()
    end)
end)

-- Инициализация
LoadConfig()
local success, gui = SafeCreateGUI()
if success then
    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            gui.MainFrame.Visible = not gui.MainFrame.Visible
        end
    end)
end

print("Project Delta Swift Edition успешно запущен!")
