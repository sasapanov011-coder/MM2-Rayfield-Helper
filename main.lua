local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 GOD MODE V17",
   LoadingTitle = "Восстановление всех систем...",
   LoadingSubtitle = "by sasapanov011",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- ЭКРАННЫЕ КНОПКИ (ДВИГАЕМЫЕ)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local function CreateBtn(name, pos, color, callback)
    local Btn = Instance.new("TextButton", ScreenGui)
    Btn.Size = UDim2.fromOffset(90, 40); Btn.Position = pos; Btn.BackgroundColor3 = color
    Btn.Text = name; Btn.TextColor3 = Color3.new(1,1,1); Btn.Visible = false; Btn.Draggable = true
    Instance.new("UICorner", Btn); Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local ShotBtn = CreateBtn("SHOT M", UDim2.new(0.5, -100, 0.8, 0), Color3.fromRGB(0, 120, 255), function()
    local m = nil
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then m = p break end
    end
    local g = LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")
    if m and g then LP.Character.Humanoid:EquipTool(g); game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", 1, m.Character.HumanoidRootPart.Position, "Main") end
end)

local KillBtn = CreateBtn("KILL ALL", UDim2.new(0.5, 10, 0.8, 0), Color3.fromRGB(255, 0, 0), function()
    local k = LP.Backpack:FindFirstChild("Knife") or LP.Character:FindFirstChild("Knife")
    if k then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LP and p.Character then
                LP.Character.Humanoid:EquipTool(k); LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                task.wait(0.1); k:Activate()
            end
        end
    end
end)

-- ВКЛАДКИ
local TabCombat = Window:CreateTab("Бой & Таргет", 4483362458)
local TabFling = Window:CreateTab("Мясорубка", 4483362458)
local TabFarm = Window:CreateTab("Автофарм", 4483362458)
local TabTP = Window:CreateTab("Телепорты", 4483362458)
local TabEmotes = Window:CreateTab("Эмоции", 4483362458)
local TabMisc = Window:CreateTab("Разное", 4483362458)

--- --- --- БОЕВОЙ МОДУЛЬ (НОВОЕ) --- --- ---
_G.KillAura = false
TabCombat:CreateToggle({
    Name = "Kill Aura (Авто-удар)",
    CurrentValue = false,
    Callback = function(v) _G.KillAura = v end
})

task.spawn(function()
    while task.wait(0.1) do
        if _G.KillAura then
            local knife = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
            if knife then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= LP and p.Character and (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 15 then
                        LP.Character.Humanoid:EquipTool(knife); knife:Activate()
                    end
                end
            end
        end
    end
end)

_G.AttackM = false
TabCombat:CreateToggle({
    Name = "Нападение на Убийцу",
    CurrentValue = false,
    Callback = function(v) _G.AttackM = v end
})

task.spawn(function()
    while task.wait(0.1) do
        if _G.AttackM then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                    LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                    LP.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
                end
            end
        end
    end
end)

TabCombat:CreateToggle({Name = "SHOT на экране", CurrentValue = false, Callback = function(v) ShotBtn.Visible = v end})
TabCombat:CreateToggle({Name = "KILL ALL на экране", CurrentValue = false, Callback = function(v) KillBtn.Visible = v end})

--- --- --- УЛЬТРА FLING (МЯСОРУБКА) --- --- ---
local function PowerFling(T)
    if T and T.Character then
        local hrp = LP.Character.HumanoidRootPart; local old = hrp.CFrame; local s = tick()
        while tick() - s < 3.5 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            hrp.CFrame = T.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(tick()*10000), 0)
            hrp.Velocity = Vector3.new(500000, 500000, 500000); hrp.RotVelocity = Vector3.new(0, 500000, 0)
        end
        hrp.Velocity = Vector3.new(0,0,0); hrp.CFrame = old
    end
end

TabFling:CreateButton({Name = "Fling Murderer", Callback = function()
    for _, p in pairs(game.Players:GetPlayers()) do if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then PowerFling(p) end end
end})

local SelP = ""
TabFling:CreateDropdown({Name = "Выбрать жертву", Options = {"Загрузка..."}, Callback = function(v) SelP = v[1] end})
TabFling:CreateButton({Name = "Запустить Игрока (Flight)", Callback = function() PowerFling(game.Players:FindFirstChild(SelP)) end})

--- --- --- ТЕЛЕПОРТЫ --- --- ---
TabTP:CreateButton({Name = "Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})
TabTP:CreateButton({Name = "ТП на Карту", Callback = function()
    local m = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
    if m then LP.Character.HumanoidRootPart.CFrame = m:FindFirstChildOfClass("Part", true).CFrame end
end})

--- --- --- ЭМОЦИИ --- --- ---
local function Play(id)
    local a = Instance.new("Animation"); a.AnimationId = "rbxassetid://"..id
    LP.Character.Humanoid:LoadAnimation(a):Play()
end
TabEmotes:CreateButton({Name = "Дзен", Callback = function() Play("3189777795") end})
TabEmotes:CreateButton({Name = "Сидеть", Callback = function() Play("3189776528") end})
TabEmotes:CreateButton({Name = "Флос", Callback = function() Play("3189778954") end})

--- --- --- АВТОФАРМ --- --- ---
_G.Spd = 40
TabFarm:CreateSlider({Name = "Скорость фарма", Range = {10, 300}, Increment = 10, CurrentValue = 40, Callback = function(v) _G.Spd = v end})
TabFarm:CreateToggle({Name = "Auto-Farm", CurrentValue = false, Callback = function(v)
    _G.Farm = v
    task.spawn(function()
        while _G.Farm do
            local c = workspace:FindFirstChild("CoinContainer", true)
            if c and c:FindFirstChildOfClass("Part") then
                local coin = c:FindFirstChildOfClass("Part")
                local d = (LP.Character.HumanoidRootPart.Position - coin.Position).Magnitude / _G.Spd
                TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(d, Enum.EasingStyle.Linear), {CFrame = coin.CFrame}):Play()
                task.wait(d + 0.1)
            end
            task.wait(0.5)
        end
    end)
end})

--- --- --- РАЗНОЕ --- --- ---
TabMisc:CreateToggle({Name = "Anti-Fling", CurrentValue = true, Callback = function(v) _G.AF = v end})
RS.Heartbeat:Connect(function() if _G.AF and LP.Character then for _,p in pairs(LP.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)

task.spawn(function()
    while task.wait(5) do
        local plrs = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(plrs, p.Name) end
        -- Обновление списка
    end
end)

Rayfield:Notify({Title = "InbiScript V17", Content = "Все функции восстановлены!", Duration = 5})
