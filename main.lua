local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 V25 FINAL",
   LoadingTitle = "InbiScript: СИСТЕМА ЗАХВАТА ЦЕЛИ",
   LoadingSubtitle = "Camera Lock & Mega Spin",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- ПЕРЕМЕННЫЕ УПРАВЛЕНИЯ
_G.TargetLock = false
_G.InbiFarmSpeed = 60

-- --- --- СИСТЕМА FLING (КРУТИЛКА ПОД НОГАМИ) --- --- ---
local function PowerSpin(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        
        -- Сила для удержания на месте (чтобы не прыгал)
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        
        -- Бешеное вращение
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.P = 1e6
        bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bav.AngularVelocity = Vector3.new(0, 3000000, 0)

        local s = tick()
        while tick() - s < 3.5 do
            RS.RenderStepped:Wait()
            hrp.CanCollide = false
            -- ФИКСАЦИЯ ПОД НОГАМИ
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.6, 0)
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

--- --- --- TARGET LOCK (СЛЕДЖЕНИЕ КАМЕРЫ) --- --- ---
TabCombat:CreateToggle({
    Name = "Target Lock (Следить за Murderer)",
    CurrentValue = false,
    Callback = function(v) _G.TargetLock = v end
})

-- Цикл слежения камеры (БЕЗ ПОЛЕТА)
RS.RenderStepped:Connect(function()
    if _G.TargetLock then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                -- Камера смотрит на голову или туловище убийцы
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, p.Character.HumanoidRootPart.Position)
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
            if k then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= LP and p.Character and (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 15 then
                        LP.Character.Humanoid:EquipTool(k); k:Activate()
                    end
                end
            end
        end
    end
end)

--- --- --- FLING (КРУТИЛКА) --- --- ---
TabFling:CreateButton({
    Name = "Fling Murderer (Spin Under Feet)",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                PowerSpin(p)
            end
        end
    end
})

local SelectedTarget = ""
local DropF = TabFling:CreateDropdown({
    Name = "Выбрать цель",
    Options = {"Загрузка..."},
    Callback = function(v) SelectedTarget = v[1] end
})

TabFling:CreateButton({
    Name = "Крутиться под ногами выбранного",
    Callback = function()
        PowerSpin(game.Players:FindFirstChild(SelectedTarget))
    end
})

--- --- --- АВТОФАРМ (FLY + ПОЛЗУНОК) --- --- ---
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
TabVisuals:CreateToggle({Name = "SCP ESP", CurrentValue = false, Callback = function(v) _G.SCPESP = v end})
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
                    h.OutlineTransparency = 0
                end
            end
        end
    end
end)

--- --- --- РАЗНОЕ --- --- ---
TabMisc:CreateToggle({Name = "Anti-Fling", CurrentValue = true, Callback = function(v) _G.AF = v end})
RS.Heartbeat:Connect(function() 
    if _G.AF and LP.Character then 
        for _,p in pairs(LP.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end 
    end 
end)

TabTP:CreateButton({Name = "Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})

-- Обновление списка игроков
task.spawn(function()
    while task.wait(5) do
        local pl = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(pl, p.Name) end
        DropF:Refresh(pl)
    end
end)

Rayfield:Notify({Title = "InbiScript V25", Content = "Target Lock и Spin Fling готовы!", Duration = 5})
