local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'AlphaControls | MM2 LINORIA V9',
    Center = true,
    AutoShow = true,
    TabWidth = 160,
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

-- СОЗДАНИЕ GUI ДЛЯ КНОПОК НА ЭКРАНЕ
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AlphaMobileButtons"

local function CreateMobileBtn(name, pos, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.fromOffset(90, 40)
    Btn.Position = pos
    Btn.BackgroundColor3 = color
    Btn.Text = name
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Visible = false
    Btn.Active = true
    Btn.Draggable = true 
    local Corner = Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- Логика кнопок
local function ShootMurderer()
    local murderer = nil
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
            murderer = p break
        end
    end
    local gun = LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")
    if murderer and gun then
        LP.Character.Humanoid:EquipTool(gun)
        game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", 1, murderer.Character.HumanoidRootPart.Position, "Main")
    end
end

local function KillAll()
    local knife = LP.Backpack:FindFirstChild("Knife") or LP.Character:FindFirstChild("Knife")
    if knife then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.Humanoid:EquipTool(knife)
                LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                task.wait(0.1)
                knife:Activate()
            end
        end
    end
end

local ScreenShot = CreateMobileBtn("SHOT M", UDim2.new(0.5, -100, 0.85, 0), Color3.fromRGB(0, 100, 255), ShootMurderer)
local ScreenKill = CreateMobileBtn("KILL ALL", UDim2.new(0.5, 10, 0.85, 0), Color3.fromRGB(200, 0, 0), KillAll)

-- ВКЛАДКИ
local Tabs = {
    Main = Window:AddTab('Автофарм'),
    Combat = Window:AddTab('Бой & Кнопки'),
    Visuals = Window:AddTab('Визуалы'),
    Emotes = Window:AddTab('Эмоции'),
    Teleport = Window:AddTab('Телепорты'),
    ['UI Settings'] = Window:AddTab('Настройки'),
}

--- --- --- АВТОФАРМ --- --- ---
local FarmGroup = Tabs.Main:AddLeftGroupbox('Fly Autofarm')

FarmGroup:AddToggle('FarmToggle', {
    Text = 'Включить Автофарм',
    Default = false,
    Callback = function(Value)
        _G.Farming = Value
        if Value then
            task.spawn(function()
                while _G.Farming do
                    local coins = workspace:FindFirstChild("CoinContainer", true)
                    if coins then
                        for _, c in pairs(coins:GetChildren()) do
                            if not _G.Farming then break end
                            if c:IsA("BasePart") and c:FindFirstChild("TouchInterest") then
                                local hrp = LP.Character.HumanoidRootPart
                                LP.Character.Humanoid:ChangeState(11)
                                local duration = (hrp.Position - c.Position).Magnitude / (Toggles.FarmSpeed and Options.FarmSpeed.Value or 20)
                                TS:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = c.CFrame}):Play()
                                task.wait(duration + 0.1)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

FarmGroup:AddSlider('FarmSpeed', {
    Text = 'Скорость полета',
    Default = 20,
    Min = 10,
    Max = 200,
    Rounding = 0,
})

--- --- --- БОЙ & КНОПКИ --- --- ---
local CombatGroup = Tabs.Combat:AddLeftGroupbox('Экранные Кнопки')

CombatGroup:AddToggle('ShowShotBtn', {
    Text = 'Показать кнопку SHOT',
    Default = false,
    Callback = function(v) ScreenShot.Visible = v end
})

CombatGroup:AddToggle('ShowKillBtn', {
    Text = 'Показать кнопку KILL ALL',
    Default = false,
    Callback = function(v) ScreenKill.Visible = v end
})

local FlingGroup = Tabs.Combat:AddRightGroupbox('Fling / Выкидывание')

FlingGroup:AddDropdown('FlingTarget', {
    Values = {},
    Text = 'Выбрать игрока',
    Multi = false,
})

task.spawn(function()
    while task.wait(5) do
        local plrs = {}
        for _, p in pairs(game.Players:GetPlayers()) do table.insert(plrs, p.Name) end
        Options.FlingTarget:SetValues(plrs)
    end
end)

local function FastFling(target)
    if target and target.Character then
        local hrp = LP.Character.HumanoidRootPart
        local old = hrp.CFrame
        local s = tick()
        while tick() - s < 3 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            hrp.CFrame = target.Character.HumanoidRootPart.CFrame
            hrp.RotVelocity = Vector3.new(0, 15000, 0)
        end
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = old
    end
end

FlingGroup:AddButton('Выкинуть выбранного', function() FastFling(game.Players:FindFirstChild(Options.FlingTarget.Value)) end)
FlingGroup:AddButton('Выкинуть Убийцу', function() 
    for _,p in pairs(game.Players:GetPlayers()) do 
        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then FastFling(p) end 
    end 
end)

--- --- --- ЭМОЦИИ --- --- ---
local EmoteGroup = Tabs.Emotes:AddLeftGroupbox('Анимации')

local function PlayEm(id)
    local a = Instance.new("Animation")
    a.AnimationId = "rbxassetid://"..id
    LP.Character.Humanoid:LoadAnimation(a):Play()
end

EmoteGroup:AddButton('Дзен', function() PlayEm("3189777795") end)
EmoteGroup:AddButton('Сидеть', function() PlayEm("3189776528") end)
EmoteGroup:AddButton('Флос', function() PlayEm("3189778954") end)
EmoteGroup:AddButton('Зомби', function() PlayEm("3189780444") end)

--- --- --- ВИЗУАЛЫ & РАЗНОЕ --- --- ---
local VisGroup = Tabs.Visuals:AddLeftGroupbox('ESP')
VisGroup:AddToggle('EspToggle', { Text = 'ESP Роли', Default = false })

task.spawn(function()
    while task.wait(1) do
        if Toggles.EspToggle.Value then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("LinHighlight") or Instance.new("Highlight", p.Character)
                    h.Name = "LinHighlight"
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    h.FillColor = isM and Color3.new(1,0,0) or isS and Color3.new(0,0,1) or Color3.new(0,1,0)
                end
            end
        end
    end
end)

local MiscGroup = Tabs['UI Settings']:AddLeftGroupbox('Защита')
MiscGroup:AddToggle('AntiFling', {
    Text = 'Anti-Fling',
    Default = true,
    Callback = function(v)
        RS.Heartbeat:Connect(function() 
            if Toggles.AntiFling.Value and LP.Character then 
                for _,pt in pairs(LP.Character:GetChildren()) do if pt:IsA("BasePart") then pt.CanCollide = false end end 
            end 
        end)
    end
})

--- --- --- ТЕЛЕПОРТЫ --- --- ---
local TPGroup = Tabs.Teleport:AddLeftGroupbox('Мгновенные ТП')
TPGroup:AddButton('Лобби', function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end)
TPGroup:AddButton('Карта', function() 
    local m = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap") 
    if m then LP.Character.HumanoidRootPart.CFrame = m:FindFirstChildOfClass("Part", true).CFrame end 
end)

Library:Notify('AlphaControls V9 Linoria Загружена!')
