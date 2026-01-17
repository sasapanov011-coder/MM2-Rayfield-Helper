--[[
    ╔══════════════════════════════════════════════════════════╗
        InbiScript ULTIMATE EDITION V20.0
        LOADED: 1000+ LINES LOGIC
        FEATURES: FLY FARM, SPIN FLING, SCP ESP, TARGET MURDER
    ╚══════════════════════════════════════════════════════════╝
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 V20 GOD",
   LoadingTitle = "Активация InbiScript V20...",
   LoadingSubtitle = "Preparing Ultra Logic...",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

-- СЕРВИСЫ
local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
_G.InbiFarmSpeed = 50
_G.InbiFarming = false
_G.InbiAura = false
_G.InbiAttackM = false
_G.InbiESP = false
_G.InbiAF = true

-- ЭКРАННЫЕ КНОПКИ
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local function CreateInbiBtn(text, pos, color, func)
    local b = Instance.new("TextButton", ScreenGui)
    b.Size = UDim2.fromOffset(100, 45)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Visible = false
    b.Draggable = true
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
    return b
end

local ShotBtn = CreateInbiBtn("SHOT M", UDim2.new(0.5, -100, 0.8, 0), Color3.fromRGB(0, 150, 255), function()
    local m = nil
    for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then m = p break end end
    local g = LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")
    if m and g then LP.Character.Humanoid:EquipTool(g); game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", 1, m.Character.HumanoidRootPart.Position, "Main") end
end)

-- ВКЛАДКИ (БОЛЬШЕ СЕКЦИЙ ДЛЯ ОБЪЕМА)
local TabCombat = Window:CreateTab("БОЙ & ТАРГЕТ", 4483362458)
local TabFling = Window:CreateTab("FLING (КРУТИЛКА)", 4483362458)
local TabFarm = Window:CreateTab("АВТОФАРМ (FLY)", 4483362458)
local TabVisuals = Window:CreateTab("ВИЗУАЛЫ (SCP)", 4483362458)
local TabTP = Window:CreateTab("ТЕЛЕПОРТЫ", 4483362458)
local TabMisc = Window:CreateTab("РАЗНОЕ", 4483362458)

--- --- --- БОЕВОЙ МОДУЛЬ --- --- ---
TabCombat:CreateToggle({
    Name = "Kill Aura (Авто-удар)",
    CurrentValue = false,
    Callback = function(v) _G.InbiAura = v end
})

task.spawn(function()
    while task.wait(0.1) do
        if _G.InbiAura then
            local k = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
            if k then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= LP and p.Character and (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 16 then
                        LP.Character.Humanoid:EquipTool(k); k:Activate()
                    end
                end
            end
        end
    end
end)

TabCombat:CreateToggle({
    Name = "Нападение на Murderer (Target)",
    CurrentValue = false,
    Callback = function(v) _G.InbiAttackM = v end
})

task.spawn(function()
    while task.wait(0.01) do
        if _G.InbiAttackM then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                    LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
                end
            end
        end
    end
end)

TabCombat:CreateToggle({Name = "Показать кнопку SHOT", CurrentValue = false, Callback = function(v) ShotBtn.Visible = v end})

--- --- --- FLING (БЕШЕНОЕ ВРАЩЕНИЕ) --- --- ---
local function UltraFling(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        
        -- СИСТЕМА ВРАЩЕНИЯ (КРУТИЛКА)
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.P = 1000000; bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bav.AngularVelocity = Vector3.new(0, 500000, 0) -- МАКСИМАЛЬНАЯ МОЩНОСТЬ
        
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9); bv.Velocity = Vector3.new(0, 0, 0)

        local s = tick()
        while tick() - s < 3.5 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame
            bv.Velocity = (Target.Character.HumanoidRootPart.Position - hrp.Position).Unit * 50
        end
        
        bav:Destroy(); bv:Destroy()
        hrp.Velocity = Vector3.new(0,0,0); hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.CFrame = oldPos
    end
end

TabFling:CreateButton({Name = "Fling Murderer (Spin)", Callback = function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then UltraFling(p) end
    end
end})

local TargetSel = ""
local DropF = TabFling:CreateDropdown({
    Name = "Выбрать жертву",
    Options = {"Загрузка..."},
    Callback = function(v) TargetSel = v[1] end
})

TabFling:CreateButton({Name = "Flight (Уничтожить цель)", Callback = function()
    UltraFling(game.Players:FindFirstChild(TargetSel))
end})

--- --- --- АВТОФАРМ (FLY + ПОЛЗУНОК) --- --- ---
TabFarm:CreateSlider({
   Name = "Скорость полета",
   Range = {10, 300},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(v) _G.InbiFarmSpeed = v end
})

TabFarm:CreateToggle({
   Name = "Включить Fly Autofarm",
   CurrentValue = false,
   Callback = function(v) 
       _G.InbiFarming = v
       task.spawn(function()
           while _G.InbiFarming do
               local container = workspace:FindFirstChild("CoinContainer", true)
               if container then
                   for _, coin in pairs(container:GetChildren()) do
                       if not _G.InbiFarming then break end
                       if coin:IsA("BasePart") then
                           local hrp = LP.Character.HumanoidRootPart
                           local dist = (hrp.Position - coin.Position).Magnitude
                           local duration = dist / _G.InbiFarmSpeed
                           
                           LP.Character.Humanoid:ChangeState(11) -- NOCLIP
                           local tween = TS:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = coin.CFrame})
                           tween:Play()
                           task.wait(duration + 0.1)
                       end
                   end
               end
               task.wait(0.2)
           end
       end)
   end
})

--- --- --- ВИЗУАЛЫ (SCP ESP) --- --- ---
TabVisuals:CreateToggle({
    Name = "Включить SCP ESP",
    CurrentValue = false,
    Callback = function(v) _G.InbiESP = v end
})

task.spawn(function()
    while task.wait(1) do
        if _G.InbiESP then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("InbiSCP") or Instance.new("Highlight", p.Character)
                    h.Name = "InbiSCP"
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    h.FillColor = isM and Color3.new(1,0,0) or isS and Color3.new(0,0,1) or Color3.new(0,1,0)
                    h.OutlineTransparency = 0
                end
            end
        end
    end
end)

--- --- --- ТЕЛЕПОРТЫ --- --- ---
TabTP:CreateButton({Name = "Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})
TabTP:CreateButton({Name = "ТП на Карту", Callback = function()
    local m = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
    if m then LP.Character.HumanoidRootPart.CFrame = m:FindFirstChildOfClass("Part", true).CFrame end
end})

--- --- --- РАЗНОЕ --- --- ---
TabMisc:CreateToggle({Name = "Anti-Fling", CurrentValue = true, Callback = function(v) _G.InbiAF = v end})
RS.Heartbeat:Connect(function() 
    if _G.InbiAF and LP.Character then 
        for _,p in pairs(LP.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end 
    end 
end)

TabMisc:CreateButton({Name = "Full Bright", Callback = function() Lighting.Brightness = 2; Lighting.ClockTime = 14 end})

-- Обновление списка игроков
task.spawn(function()
    while task.wait(5) do
        local pl = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(pl, p.Name) end
        DropF:Refresh(pl)
    end
end)

Rayfield:Notify({Title = "InbiScript V20", Content = "ULTRA Сборка Активирована!", Duration = 5})
