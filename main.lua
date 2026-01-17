local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 V26 GOD MODE",
   LoadingTitle = "InbiScript: ПОЛНЫЙ ГИПЕР-ФИКС",
   LoadingSubtitle = "Kill All & Camera Lock Ready",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- --- --- ФУНКЦИЯ МОЩНОГО СПИНА (БЕЗ ВЫЛЕТОВ) --- --- ---
local function PowerSpin(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        LP.Character.Humanoid.PlatformStand = true -- Отключаем физику гуманоида, чтобы не прыгал

        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9); bv.Velocity = Vector3.new(0, 0, 0)
        
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.P = 1e6; bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bav.AngularVelocity = Vector3.new(0, 2500000, 0) -- Оптимальная скорость для вылета

        local s = tick()
        while tick() - s < 3.2 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            -- ЧЕТКО ПОД НОГАМИ
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
        end
        
        bav:Destroy(); bv:Destroy()
        LP.Character.Humanoid.PlatformStand = false
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = oldPos
    end
end

-- --- --- ВКЛАДКИ --- --- ---
local TabCombat = Window:CreateTab("Бой & Таргет", 4483362458)
local TabFling = Window:CreateTab("Fling (Крутилка)", 4483362458)
local TabFarm = Window:CreateTab("Автофарм (Fly)", 4483362458)
local TabVisuals = Window:CreateTab("Визуалы (SCP)", 4483362458)
local TabMisc = Window:CreateTab("Разное", 4483362458)

--- --- --- БОЕВОЙ МОДУЛЬ (KILL ALL ТУТ) --- --- ---
TabCombat:CreateButton({
    Name = "⚡ KILL ALL (Для Убийцы)",
    Callback = function()
        local knife = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
        if not knife then 
            Rayfield:Notify({Title = "Ошибка", Content = "Возьми нож в руки!"})
            return 
        end
        
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                LP.Character.Humanoid:EquipTool(knife)
                LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                task.wait(0.1)
                knife:Activate()
                task.wait(0.1)
            end
        end
    end
})

_G.CamLock = false
TabCombat:CreateToggle({
    Name = "Target Lock (Камера на Мардера)",
    CurrentValue = false,
    Callback = function(v) _G.CamLock = v end
})

RS.RenderStepped:Connect(function()
    if _G.CamLock then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, p.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

_G.Aura = false
TabCombat:CreateToggle({Name = "Kill Aura", CurrentValue = false, Callback = function(v) _G.Aura = v end})
task.spawn(function()
    while task.wait(0.1) do
        if _G.Aura then
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
    Name = "Fling Murderer (Spin Under)",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                PowerSpin(p)
            end
        end
    end
})

local TargetName = ""
local DropF = TabFling:CreateDropdown({
    Name = "Выбрать цель",
    Options = {"Загрузка..."},
    Callback = function(v) TargetName = v[1] end
})

TabFling:CreateButton({
    Name = "Крутиться под выбранным",
    Callback = function()
        PowerSpin(game.Players:FindFirstChild(TargetName))
    end
})

--- --- --- АВТОФАРМ (FLY) --- --- ---
_G.FarmSpeed = 60
TabFarm:CreateSlider({Name = "Скорость фарма", Range = {10, 400}, Increment = 5, CurrentValue = 60, Callback = function(v) _G.FarmSpeed = v end})
TabFarm:CreateToggle({Name = "Fly Farm (NoClip)", CurrentValue = false, Callback = function(v) 
    _G.Farm = v
    task.spawn(function()
        while _G.Farm do
            local coins = workspace:FindFirstChild("CoinContainer", true)
            if coins then
                for _, coin in pairs(coins:GetChildren()) do
                    if not _G.Farm then break end
                    LP.Character.Humanoid:ChangeState(11)
                    local dist = (LP.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                    local duration = dist / _G.FarmSpeed
                    TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = coin.CFrame}):Play()
                    task.wait(duration + 0.1)
                end
            end
            task.wait(0.2)
        end
    end)
end})

--- --- --- ВИЗУАЛЫ & ANTI-FLING --- --- ---
TabVisuals:CreateToggle({Name = "SCP ESP", CurrentValue = false, Callback = function(v) _G.ESP = v end})
task.spawn(function()
    while task.wait(1) do
        if _G.ESP then
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

TabMisc:CreateToggle({Name = "Anti-Fling (Мощный)", CurrentValue = true, Callback = function(v) _G.AF = v end})
RS.Heartbeat:Connect(function() 
    if _G.AF and LP.Character then 
        for _,p in pairs(LP.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end 
    end 
end)

-- Обновление списка
task.spawn(function()
    while task.wait(5) do
        local pl = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(pl, p.Name) end
        DropF:Refresh(pl)
    end
end)

Rayfield:Notify({Title = "InbiScript V26", Content = "Kill All и фикс Target Lock добавлены!", Duration = 5})
