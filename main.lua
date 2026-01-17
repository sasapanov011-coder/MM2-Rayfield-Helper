local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 V24 GOD",
   LoadingTitle = "InbiScript: ГИПЕР-КРУТИЛКА",
   LoadingSubtitle = "Spin Mode & Target Lock Ready",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- --- --- СИСТЕМА ФЛИНГА (БЕЗ ПРЫЖКОВ, ТОЛЬКО СПИН) --- --- ---
local function PerfectSpinFling(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        
        -- Выключаем гравитацию и прыжки для себя на время флинга
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0, 0, 0) -- МЫ НЕ ПРЫГАЕМ
        
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.P = 1e6
        bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bav.AngularVelocity = Vector3.new(0, 3000000, 0) -- БЕШЕНОЕ ВРАЩЕНИЕ

        local s = tick()
        while tick() - s < 3.5 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            -- ЖЕСТКАЯ ФИКСАЦИЯ ПОД НОГАМИ (ниже на 3.6 блока)
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.6, 0) * CFrame.Angles(0, 0, 0)
        end
        
        bav:Destroy(); bv:Destroy()
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.CFrame = oldPos
    end
end

-- --- --- ВКЛАДКИ --- --- ---
local TabCombat = Window:CreateTab("Бой & Таргет", 4483362458)
local TabFling = Window:CreateTab("Fling (Крутилка)", 4483362458)
local TabFarm = Window:CreateTab("Автофарм (Fly)", 4483362458)
local TabVisuals = Window:CreateTab("Визуалы (SCP)", 4483362458)
local TabTP = Window:CreateTab("Телепорты", 4483362458)
local TabMisc = Window:CreateTab("Разное", 4483362458)

--- --- --- БОЙ & SHIFT LOCK --- --- ---
_G.InbiAttackM = false
TabCombat:CreateToggle({
    Name = "Нападение на Murderer (Shift Lock)",
    CurrentValue = false,
    Callback = function(v) _G.InbiAttackM = v end
})

-- Цикл для Shift Lock и Прилипания
task.spawn(function()
    while task.wait() do
        if _G.InbiAttackM then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                    -- Прилипаем
                    LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.3)
                    -- Shift Lock (Камера смотрит на мардера)
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Character.HumanoidRootPart.Position)
                end
            end
        end
    end
end)

_G.InbiAura = false
TabCombat:CreateToggle({Name = "Kill Aura", CurrentValue = false, Callback = function(v) _G.InbiAura = v end})
task.spawn(function()
    while task.wait(0.1) do
        if _G.InbiAura then
            local k = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
            if k and _G.InbiAura then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= LP and p.Character and (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 15 then
                        LP.Character.Humanoid:EquipTool(k); k:Activate()
                    end
                end
            end
        end
    end
end)

--- --- --- FLING (ГИПЕР-КРУТИЛКА) --- --- ---
TabFling:CreateButton({
    Name = "Fling Murderer (Spin Under Feet)",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                PerfectSpinFling(p)
            end
        end
    end
})

local TargetPlayer = ""
local DropF = TabFling:CreateDropdown({
    Name = "Выбрать цель",
    Options = {"Загрузка..."},
    Callback = function(v) TargetPlayer = v[1] end
})

TabFling:CreateButton({
    Name = "Крутиться под ногами выбранного",
    Callback = function()
        PerfectSpinFling(game.Players:FindFirstChild(TargetPlayer))
    end
})

--- --- --- АВТОФАРМ (FLY + ПОЛЗУНОК) --- --- ---
_G.InbiFarmSpeed = 60
TabFarm:CreateSlider({Name = "Скорость полета", Range = {10, 400}, Increment = 5, CurrentValue = 60, Callback = function(v) _G.InbiFarmSpeed = v end})
TabFarm:CreateToggle({Name = "Fly Farm (NoClip)", CurrentValue = false, Callback = function(v) 
    _G.InbiFarm = v
    task.spawn(function()
        while _G.InbiFarm do
            local c = workspace:FindFirstChild("CoinContainer", true)
            if c then
                for _, coin in pairs(c:GetChildren()) do
                    if not _G.InbiFarm then break end
                    LP.Character.Humanoid:ChangeState(11)
                    local dist = (LP.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                    local duration = dist / _G.InbiFarmSpeed
                    TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = coin.CFrame}):Play()
                    task.wait(duration + 0.1)
                end
            end
            task.wait(0.2)
        end
    end)
end})

--- --- --- ВИЗУАЛЫ (SCP ESP) --- --- ---
TabVisuals:CreateToggle({Name = "SCP ESP (Highlight)", CurrentValue = false, Callback = function(v) _G.SCPESP = v end})
task.spawn(function()
    while task.wait(1) do
        if _G.SCPESP then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("InbiH") or Instance.new("Highlight", p.Character)
                    h.Name = "InbiH"
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    h.FillColor = isM and Color3.new(1,0,0) or isS and Color3.new(0,0,1) or Color3.new(0,1,0)
                end
            end
        end
    end
end)

--- --- --- РАЗНОЕ & ANTI-FLING --- --- ---
TabMisc:CreateToggle({Name = "Anti-Fling", CurrentValue = true, Callback = function(v) _G.AF = v end})
RS.Heartbeat:Connect(function() 
    if _G.AF and LP.Character then 
        for _,p in pairs(LP.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end 
    end 
end)

TabTP:CreateButton({Name = "Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})
TabTP:CreateButton({Name = "Карта", Callback = function() 
    local m = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
    if m then LP.Character.HumanoidRootPart.CFrame = m:FindFirstChildOfClass("Part", true).CFrame end
end})

-- Обновление списка
task.spawn(function()
    while task.wait(5) do
        local pl = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(pl, p.Name) end
        DropF:Refresh(pl)
    end
end)

Rayfield:Notify({Title = "InbiScript V24", Content = "Spin Fling и Shift Lock активированы!", Duration = 5})
