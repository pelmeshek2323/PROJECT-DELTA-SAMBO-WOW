print("Скрипт запущен! Шаг 1/5")
local function CreateMovableMenu()
    print("Создание интерфейса... Шаг 2/5")
    -- ... остальной код ...
    print("Интерфейс создан!")
    return ScreenGui
end
UIS.InputBegan:Connect(function(input)
    print("Нажата клавиша:", input.KeyCode)
    if input.KeyCode == SETTINGS.MenuKey then
        GUI.Main.Visible = not GUI.Main.Visible
        print("Меню видимости:", GUI.Main.Visible)
    end
end)
local function TestFeatures()
    print("Тест функций...")
    -- ESP
    UpdateESP()
    print("ESP:", #ESPCache > 0 and "Работает" or "Не работает")
    
    -- Аимбот
    SmartAimbot()
    print("Аимбот:", SETTINGS.Features.Aimbot.Enabled and "Активен" or "Выключен")
    
    -- Характеристики
    if LP.Character then
        local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
        print("Скорость:", humanoid.WalkSpeed)
    end
end

RS.Heartbeat:Connect(TestFeatures)
-- Project Delta Ultimate Hack v6.2 (DEBUG)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Camera = WS.CurrentCamera

print("Инициализация... Шаг 1/5")

-- Конфигурация
local SETTINGS = {
    MenuKey = Enum.KeyCode.RightShift,
    ThemeColor = Color3.fromRGB(0, 170, 255),
    Features = {
        Aimbot = {Enabled = false},
        ESP = {Players = true},
        Player = {Speed = 24},
        World = {Fullbright = true}
    }
}

-- Глобальные переменные
local GUI = {Main = nil}
local ESPCache = {}

print("Создание меню... Шаг 2/5")
local function CreateMovableMenu()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    local Button = Instance.new("TextButton")
    Button.Text = "Тестовая кнопка"
    Button.Size = UDim2.new(0.9, 0, 0, 40)
    Button.Position = UDim2.new(0.05, 0, 0.1, 0)
    Button.Parent = MainFrame

    GUI.Main = MainFrame
    print("Меню создано!")
    return ScreenGui
end

print("Инициализация функций... Шаг 3/5")
local interface = CreateMovableMenu()

UIS.InputBegan:Connect(function(input)
    print("Нажата клавиша:", input.KeyCode)
    if input.KeyCode == SETTINGS.MenuKey then
        GUI.Main.Visible = not GUI.Main.Visible
        print("Меню видимости:", GUI.Main.Visible)
    end
end)

print("Запуск основного цикла... Шаг 4/5")
RS.Heartbeat:Connect(function()
    pcall(function()
        -- Базовая функциональность
        if LP.Character then
            local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = SETTINGS.Features.Player.Speed
            end
        end
    end)
end)

print("Скрипт успешно загружен! Шаг 5/5")
