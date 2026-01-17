local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 ULTIMATE V22",
   LoadingTitle = "Восстановление InbiScript...",
   LoadingSubtitle = "Версия: Super Spin & SCP ESP",
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
        
        -- Силы вращения
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.P = 1e6
        bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bav.AngularVelocity = Vector3.new(0, 1500000, 0) -- МАКСИМУМ
        
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0, 0, 0)

        local s = tick()
        while tick() - s < 3.8 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            -- МЫ ПОД НОГАМИ (смещение на 3.8 блока вниз)
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.8, 0)
            hrp.Velocity = Vector3.new(math.random(-50,50), 50, math.random(-50,50))
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
local TabTP = Window:CreateTab("Телепорты", 4483362458)
local TabMisc = Window:CreateTab("Разное", 4483362458)

--- --- --- БОЙ --- --- ---
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

--- --- --- FLING --- --- ---
TabFling:CreateButton({Name = "Fling Murderer (Spin Under)", Callback = function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then UltraSpinFling(p) end
    end
end})

local SelP = ""
TabFling:CreateDropdown({Name = "Выбрать цель", Options = {"Загрузка..."}, Callback = function(v) SelP = v[1] end})
TabFling:CreateButton({Name = "Flight (Крутиться под ногами)", Callback = function() UltraSpinFling(game.Players:FindFirstChild(SelP)) end})

--- --- --- АВТОФАРМ --- --- ---
_G.InbiSpeed = 50
TabFarm:CreateSlider({Name = "Скорость полета", Range = {10, 300}, Increment = 5, CurrentValue = 50, Callback = function(v) _G.InbiSpeed = v end})
TabFarm:CreateToggle({Name = "Fly Farm (NoClip)", CurrentValue = false, Callback = function(v) 
    _G.InbiFarm = v
    task.spawn(function()
        while _G.InbiFarm do
            local c = workspace:FindFirstChild("CoinContainer", true)
            if c then
                for _, coin in pairs(c:GetChildren()) do
                    if not _G.InbiFarm then break end
                    LP.Character.Humanoid:ChangeState(11)
                    local dur = (LP.Character.HumanoidRootPart.Position - coin.Position).Magnitude / _G.InbiSpeed
                    TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = coin.CFrame}):Play()
                    task.wait(dur + 0.1)
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
                end
            end
        end
    end
end)

Rayfield:Notify({Title = "InbiScript V22", Content = "Всё восстановлено!", Duration = 5})
