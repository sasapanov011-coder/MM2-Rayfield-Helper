local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 V19 ULTRA",
   LoadingTitle = "Активация InbiScript...",
   LoadingSubtitle = "Fly Farm & Spin Fling Ready",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- СОЗДАНИЕ КНОПОК
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

-- ВКЛАДКИ
local TabCombat = Window:CreateTab("Бой & Таргет", 4483362458)
local TabFling = Window:CreateTab("Fling (Крутилка)", 4483362458)
local TabFarm = Window:CreateTab("Автофарм (Fly)", 4483362458)
local TabVisuals = Window:CreateTab("Визуалы (SCP)", 4483362458)
local TabTP = Window:CreateTab("Телепорты", 4483362458)
local TabMisc = Window:CreateTab("Разное", 4483362458)

--- --- --- НОВЫЙ FLING (БЕШЕНОЕ ВРАЩЕНИЕ) --- --- ---
local function SpinFling(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        
        -- Создаем вращение
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.P = 1000000
        bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bav.AngularVelocity = Vector3.new(0, 100000, 0) -- Скорость вращения
        
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0, 0, 0)

        local s = tick()
        while tick() - s < 3.5 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame
            bv.Velocity = (Target.Character.HumanoidRootPart.Position - hrp.Position).Unit * 50
        end
        
        bav:Destroy(); bv:Destroy()
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.CFrame = oldPos
        Rayfield:Notify({Title = "InbiScript", Content = "Цель уничтожена!"})
    end
end

TabFling:CreateButton({Name = "Fling Убийцу (Spin)", Callback = function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then SpinFling(p) end
    end
end})

local SelectedTarget = ""
local DropF = TabFling:CreateDropdown({
    Name = "Выбрать жертву",
    Options = {"Загрузка..."},
    Callback = function(v) SelectedTarget = v[1] end
})

TabFling:CreateButton({Name = "Запустить выбранного", Callback = function()
    SpinFling(game.Players:FindFirstChild(SelectedTarget))
end})

--- --- --- АВТОФАРМ (FLY + NOCLIP + ПОЛЗУНОК) --- --- ---
_G.FarmSpeed = 40
TabFarm:CreateSlider({
   Name = "Скорость полета",
   Range = {10, 300},
   Increment = 5,
   CurrentValue = 40,
   Callback = function(v) _G.FarmSpeed = v end
})

TabFarm:CreateToggle({
   Name = "Включить Fly Farm",
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
                           -- Плавный полет через Tween
                           local dist = (hrp.Position - coin.Position).Magnitude
                           local duration = dist / _G.FarmSpeed
                           
                           LP.Character.Humanoid:ChangeState(11) -- NoClip State
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

--- --- --- БОЙ & ТАРГЕТ --- --- ---
_G.KillAura = false
TabCombat:CreateToggle({Name = "Kill Aura (Авто-удар)", CurrentValue = false, Callback = function(v) _G.KillAura = v end})

task.spawn(function()
    while task.wait(0.1) do
        if _G.KillAura then
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

_G.AttackM = false
TabCombat:CreateToggle({Name = "Нападение на Убийцу (Прилипание)", CurrentValue = false, Callback = function(v) _G.AttackM = v end})
task.spawn(function()
    while task.wait(0.1) do
        if _G.AttackM then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                    LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.2)
                end
            end
        end
    end
end)

TabCombat:CreateToggle({Name = "SHOT на экране", CurrentValue = false, Callback = function(v) ShotBtn.Visible = v end})

--- --- --- SCP ESP --- --- ---
TabVisuals:CreateToggle({Name = "SCP ESP (Цветной)", CurrentValue = false, Callback = function(v) _G.SCP = v end})
task.spawn(function()
    while task.wait(1) do
        if _G.SCP then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("InbiSCP") or Instance.new("Highlight", p.Character)
                    h.Name = "InbiSCP"
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    h.FillColor = isM and Color3.new(1,0,0) or isS and Color3.new(0,0,1) or Color3.new(0,1,0)
                end
            end
        end
    end
end)

--- --- --- ТЕЛЕПОРТЫ --- --- ---
TabTP:CreateButton({Name = "Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})
TabTP:CreateButton({Name = "Карта", Callback = function() 
    local m = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
    if m then LP.Character.HumanoidRootPart.CFrame = m:FindFirstChildOfClass("Part", true).CFrame end
end})

--- --- --- РАЗНОЕ --- --- ---
TabMisc:CreateToggle({Name = "Anti-Fling", CurrentValue = true, Callback = function(v) _G.AF = v end})
RS.Heartbeat:Connect(function() 
    if _G.AF and LP.Character then 
        for _,p in pairs(LP.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end 
    end 
end)

task.spawn(function()
    while task.wait(5) do
        local pl = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(pl, p.Name) end
        DropF:Refresh(pl)
    end
end)

Rayfield:Notify({Title = "InbiScript V19", Content = "Автофарм Fly и Spin Fling готовы!", Duration = 5})
