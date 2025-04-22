-- Project Delta Ultimate Hack
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = WS.CurrentCamera

-- Anti-Detect System
local function SafeHook(obj, method, hook)
    local original
    original = hookfunction(obj[method], function(...)
        if checkcaller() then return original(...) end
        return hook(...)
    end)
end

-- Настройки
local SETTINGS = {
    SilentAim = {
        Enabled = true,
        HitChance = 100,
        TargetPart = "Head",  -- Head, UpperTorso, HumanoidRootPart
        FOV = 60
    },
    TriggerBot = {
        Enabled = true,
        Delay = 0.1
    },
    ESP = {
        Enabled = true,
        TeamCheck = true,
        Color = Color3.fromRGB(255, 50, 50),
        Boxes = true,
        HealthBar = true
    },
    Misc = {
        NoRecoil = true,
        NoSpread = true,
        InstantReload = false,
        RapidFire = false
    }
}

-- Undeground Protection
local fakeMeta = {}
setmetatable(_G, {
    __index = function(t, k)
        if fakeMeta[k] then return fakeMeta[k] end
        return rawget(t, k)
    end,
    __newindex = function(t, k, v)
        if string.find(k, "Hack") or string.find(k, "Aim") then
            fakeMeta[k] = v
            return
        end
        rawset(t, k, v)
    end
})

-- Silent Aim Logic
local function GetClosestTarget()
    local closest = nil
    local minDist = SETTINGS.SilentAim.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(SETTINGS.SilentAim.TargetPart)
            
            if humanoid and humanoid.Health > 0 and part then
                if SETTINGS.ESP.TeamCheck and player.Team == LocalPlayer.Team then continue end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - UIS:GetMouseLocation().Magnitude
                    if dist < minDist and math.random(1,100) <= SETTINGS.SilentAim.HitChance then
                        minDist = dist
                        closest = part
                    end
                end
            end
        end
    end
    
    return closest
end

-- TriggerBot System
local function AutoShoot()
    if not SETTINGS.TriggerBot.Enabled then return end
    
    local target = GetClosestTarget()
    if target then
        keypress(0x01) -- Left mouse button
        wait(SETTINGS.TriggerBot.Delay)
        keyrelease(0x01)
    end
end

-- Weapon Modifications
local function ModifyWeapon(tool)
    if SETTINGS.Misc.NoRecoil then
        for _, v in pairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") and string.find(v.Name:lower(), "recoil") then
                v.Value = 0
            end
        end
    end
    
    if SETTINGS.Misc.NoSpread then
        for _, v in pairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") and string.find(v.Name:lower(), "spread") then
                v.Value = 0
            end
        end
    end
end

-- ESP System
local function CreateESP(player)
    if not SETTINGS.ESP.Enabled then return end
    
    local char = player.Character
    if not char then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PD_ESP"
    highlight.Adornee = char
    highlight.FillColor = SETTINGS.ESP.Color
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.FillTransparency = 0.7
    highlight.Parent = char
    
    if SETTINGS.ESP.Boxes then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "PD_Box"
        box.Adornee = char:WaitForChild("HumanoidRootPart")
        box.Size = char:GetExtentsSize()
        box.Color3 = SETTINGS.ESP.Color
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Parent = char
    end
end

-- Hooks
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    -- Silent Aim
    if SETTINGS.SilentAim.Enabled and not checkcaller() then
        if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
            local target = GetClosestTarget()
            if target then
                local args = {...}
                local ray = Ray.new(args[1].Origin, (target.Position - args[1].Origin).Unit * 1000)
                return oldNamecall(self, ray, unpack(args, 2))
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Main Loop
RS.RenderStepped:Connect(function()
    -- AutoShoot when firing
    if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        AutoShoot()
    end
    
    -- Weapon Mods
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then ModifyWeapon(tool) end
    
    -- ESP Updates
    if SETTINGS.ESP.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                CreateESP(player)
            end
        end
    end
end)

print("Project Delta Ultimate Hack loaded!")
