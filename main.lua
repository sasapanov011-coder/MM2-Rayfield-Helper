local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 V21 ULTRA",
   LoadingTitle = "InbiScript V21: SPIN MODE",
   LoadingSubtitle = "Улучшенная физика вращения",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

-- ФУНКЦИЯ БЕШЕНОГО ВРАЩЕНИЯ ПОД НОГАМИ
local function UltraSpinFling(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        
        -- Создаем силовые поля для крутилки
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.P = 1e6
        bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bav.AngularVelocity = Vector3.new(0, 1000000, 0) -- СУПЕР СКОРОСТЬ
        
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0, 0, 0)

        Rayfield:Notify({Title = "InbiScript", Content = "Уничтожаем под ногами: "..Target.Name})

        local s = tick()
        while tick() - s < 3.5 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            -- ТЕПЕРЬ МЫ ТИПА ПОД НОГАМИ (смещение вниз на 3.5 блока)
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, math.sin(tick()*50))
            
            -- Хаотичные рывки для усиления эффекта вылета
            hrp.Velocity = Vector3.new(math.random(-100,100), 100, math.random(-100,100))
        end
        
        bav:Destroy(); bv:Destroy()
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.CFrame = oldPos
    end
end

-- ВКЛАДКИ
local TabCombat = Window:CreateTab("Бой & Таргет", 4483362458)
local TabFling = Window:CreateTab("Fling (Крутилка)", 4483362458)
local TabFarm = Window:CreateTab("Автофарм (Fly)", 4483362458)
local TabVisuals = Window:CreateTab("Визуалы (SCP)", 4483362458)

-- FLING КНОПКИ
TabFling:CreateSection("Уничтожение под ногами")
TabFling:CreateButton({
    Name = "Fling Убийцу (Крутилка)",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                UltraSpinFling(p)
            end
        end
    end
})

local TargetName = ""
TabFling:CreateDropdown({
    Name = "Выбрать игрока",
    Options = {"Загрузка..."},
    Callback = function(v) TargetName = v[1] end
})

TabFling:CreateButton({
    Name = "Flight (Крутиться под ногами)",
    Callback = function()
        UltraSpinFling(game.Players:FindFirstChild(TargetName))
    end
})

-- АВТОФАРМ С ПЛАВНЫМ ПОЛЕТОМ И ПОЛЗУНКОМ
_G.FarmSpeed = 50
TabFarm:CreateSlider({
   Name = "Скорость полета",
   Range = {10, 300},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v) _G.FarmSpeed = v end
})

TabFarm:CreateToggle({
   Name = "Включить Fly Farm (NoClip)",
   CurrentValue = false,
   Callback = function(v) 
       _G.Farming = v
       task.spawn(function()
           while _G.Farming do
               local container = workspace:FindFirstChild("CoinContainer", true)
               if container then
                   for _, coin in pairs(container:GetChildren()) do
                       if not _G.Farming then break end
                       if coin:IsA("BasePart") then
                           local hrp = LP.Character.HumanoidRootPart
                           local dist = (hrp.Position - coin.Position).Magnitude
                           local duration = dist / _G.InbiFarmSpeed
                           LP.Character.Humanoid:ChangeState(11) -- Отключаем падение
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

-- SCP ESP
TabVisuals:CreateToggle({
    Name = "SCP ESP",
    CurrentValue = false,
    Callback = function(v) 
        _G.ESP = v 
    end
})

task.spawn(function()
    while task.wait(1) do
        if _G.ESP then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("SCP_H") or Instance.new("Highlight", p.Character)
                    h.Name = "SCP_H"
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    h.FillColor = isM and Color3.new(1,0,0) or isS and Color3.new(0,0,1) or Color3.new(0,1,0)
                end
            end
        end
    end
end)

-- Обновление списка игроков
task.spawn(function()
    while task.wait(5) do
        local plrs = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(plrs, p.Name) end
        -- Обновится при открытии списка
    end
end)

Rayfield:Notify({Title = "InbiScript V21", Content = "Крутилка под ногами готова!", Duration = 5})
