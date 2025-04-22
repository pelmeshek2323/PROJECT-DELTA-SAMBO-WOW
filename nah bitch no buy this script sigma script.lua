-- Project Delta Ultimate Hack v4.0 (Full Config System)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local HTTPS = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = WS.CurrentCamera

-- Конфигурация
local CONFIG = {
    FileName = "PD_Config.json",
    Default = {
        SilentAim = {
            Enabled = true,
            FOV = 80,
            HitChance = 100,
            TargetPart = "Head",
            ShowFOV = true,
            ShowTarget = true
        },
        Visuals = {
            ESP = true,
            TeamCheck = true,
            NPC_ESP = true,
            Boxes = true,
            HealthBar = true,
            RemoveGrass = true,
            RemoveLeaves = true,
            ESPColor = {255, 50, 50}
        },
        Misc = {
            NoRecoil = true,
            NoSpread = true,
            RapidFire = false,
            UndergroundMode = true
        }
    },
    Current = {}
}

-- Инициализация конфига
CONFIG.Current = table.clone(CONFIG.Default)

-- Меню
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "PD_Sambo_HUD"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.8, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Конфиг-меню
local ConfigFrame = Instance.new("Frame")
ConfigFrame.Size = UDim2.new(1, 0, 1, 0)
ConfigFrame.BackgroundTransparency = 1
ConfigFrame.Visible = false
ConfigFrame.Parent = ScreenGui

local function CreateButton(parent, text, position)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = parent
    return btn
end

-- Кнопки главного меню
local btnSilentAim = CreateButton(MainFrame, "Silent Aim: ON", UDim2.new(0.05, 0, 0.05, 0))
local btnESP = CreateButton(MainFrame, "ESP: ON", UDim2.new(0.05, 0, 0.15, 0))
local btnUnderground = CreateButton(MainFrame, "Underground: ON", UDim2.new(0.05, 0, 0.25, 0))
local btnSaveConfig = CreateButton(MainFrame, "Save Config", UDim2.new(0.05, 0, 0.85, 0))
local btnLoadConfig = CreateButton(MainFrame, "Load Config", UDim2.new(0.05, 0, 0.92, 0))

-- FOV Circle
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, CONFIG.Current.SilentAim.FOV*2, 0, CONFIG.Current.SilentAim.FOV*2)
FOVCircle.Position = UDim2.new(0.5, -CONFIG.Current.SilentAim.FOV, 0.5, -CONFIG.Current.SilentAim.FOV)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
FOVCircle.BackgroundTransparency = 0.9
FOVCircle.Parent = ScreenGui
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)

-- Система конфигов
local function SaveConfig()
    local data = {
        SilentAim = CONFIG.Current.SilentAim,
        Visuals = CONFIG.Current.Visuals,
        Misc = CONFIG.Current.Misc
    }
    
    local success = pcall(function()
        if writefile then
            writefile(CONFIG.FileName, HTTPS:JSONEncode(data))
            print("Config saved!")
        end
    end)
    
    if not success then
        setclipboard(HTTPS:JSONEncode(data))
        print("Config copied to clipboard")
    end
end

local function LoadConfig()
    local data
    if readfile and isfile(CONFIG.FileName) then
        data = HTTPS:JSONDecode(readfile(CONFIG.FileName))
    else
        data = CONFIG.Default
    end

    CONFIG.Current.SilentAim = data.SilentAim or CONFIG.Default.SilentAim
    CONFIG.Current.Visuals = data.Visuals or CONFIG.Default.Visuals
    CONFIG.Current.Misc = data.Misc or CONFIG.Default.Misc
    
    -- Обновляем интерфейс
    btnSilentAim.Text = "Silent Aim: " .. (CONFIG.Current.SilentAim.Enabled and "ON" or "OFF")
    btnESP.Text = "ESP: " .. (CONFIG.Current.Visuals.ESP and "ON" or "OFF")
    btnUnderground.Text = "Underground: " .. (CONFIG.Current.Misc.UndergroundMode and "ON" or "OFF")
    
    print("Config loaded!")
end

-- Обработчики кнопок
btnSilentAim.MouseButton1Click:Connect(function()
    CONFIG.Current.SilentAim.Enabled = not CONFIG.Current.SilentAim.Enabled
    btnSilentAim.Text = "Silent Aim: " .. (CONFIG.Current.SilentAim.Enabled and "ON" or "OFF")
end)

btnESP.MouseButton1Click:Connect(function()
    CONFIG.Current.Visuals.ESP = not CONFIG.Current.Visuals.ESP
    btnESP.Text = "ESP: " .. (CONFIG.Current.Visuals.ESP and "ON" or "OFF")
end)

btnUnderground.MouseButton1Click:Connect(function()
    CONFIG.Current.Misc.UndergroundMode = not CONFIG.Current.Misc.UndergroundMode
    btnUnderground.Text = "Underground: " .. (CONFIG.Current.Misc.UndergroundMode and "ON" or "OFF")
end)

btnSaveConfig.MouseButton1Click:Connect(SaveConfig)
btnLoadConfig.MouseButton1Click:Connect(LoadConfig)

-- Основная логика
local function GetClosestTarget()
    -- Реализация аима (из предыдущих версий)
end

local function UpdateVisuals()
    -- Обновление ESP, удаление травы и т.д.
end

-- Главный цикл
RS.RenderStepped:Connect(function()
    FOVCircle.Visible = CONFIG.Current.SilentAim.ShowFOV
    FOVCircle.Size = UDim2.new(0, CONFIG.Current.SilentAim.FOV*2, 0, CONFIG.Current.SilentAim.FOV*2)
    
    if CONFIG.Current.Visuals.ESP then
        UpdateVisuals()
    end
end)

-- Инициализация
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

LoadConfig() -- Автозагрузка конфига
print("Project Delta Sambo v4.0 loaded!")
