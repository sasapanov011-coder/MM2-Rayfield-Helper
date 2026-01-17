local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "AlphaControls | MM2 GOD MODE",
   LoadingTitle = "Загрузка всех систем...",
   LoadingSubtitle = "by sasapanov011",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

-- СОЗДАНИЕ GUI ДЛЯ КНОПОК НА ЭКРАНЕ
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AlphaButtons"

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

-- Логика для кнопок
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
local TabFarm = Window:CreateTab("Автофарм", 4483362458)
local TabCombat = Window:CreateTab("Бой & Кнопки", 4483362458)
local TabEmotes = Window:CreateTab("Эмоции", 4483362458)
local TabVisuals = Window:CreateTab("Визуалы", 4483362458)
local TabTP = Window:CreateTab("Телепорты", 4483362458)
local TabMisc = Window:CreateTab("Разное", 4483362458)

--- --- --- АВТОФАРМ С ПРАВИЛЬНОЙ СКОРОСТЬЮ --- --- ---
_G.FarmSpeed = 20
TabFarm:CreateToggle({
   Name = "Включить Fly Autofarm",
   CurrentValue = false,
   Callback = function(v) 
       _G.Farming = v 
       task.spawn(function()
           while _G.Farming do
               local coins = workspace:FindFirstChild("CoinContainer", true)
               if coins then
                   for _, c in pairs(coins:GetChildren()) do
                       if not _G.Farming then break end
                       if c:IsA("BasePart") and c:FindFirstChild("TouchInterest") then
                           local hrp = LP.Character.HumanoidRootPart
                           LP.Character.Humanoid:ChangeState(11)
                           local duration = (hrp.Position - c.Position).Magnitude / _G.FarmSpeed
                           TS:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = c.CFrame}):Play()
                           task.wait(duration + 0.1)
                       end
                   end
               end
               task.wait(0.1)
           end
       end)
   end
})

TabFarm:CreateSlider({
   Name = "Скорость полета",
   Range = {10, 200},
   Increment = 5,
   CurrentValue = 20,
   Callback = function(v) _G.FarmSpeed = v end
})

--- --- --- БОЙ & ЭКРАННЫЕ КНОПКИ --- --- ---
TabCombat:CreateToggle({Name = "Показать SHOT на экране", CurrentValue = false, Callback = function(v) ScreenShot.Visible = v end})
TabCombat:CreateToggle({Name = "Показать KILL ALL на экране", CurrentValue = false, Callback = function(v) ScreenKill.Visible = v end})

TabCombat:CreateSection("Fling")
local TargetName = ""
local Drop = TabCombat:CreateDropdown({
    Name = "Выбрать игрока",
    Options = {"Загрузка..."},
    Callback = function(v) TargetName = v[1] end
})

task.spawn(function()
    while task.wait(5) do
        local pNames = {}
        for _, p in pairs(game.Players:GetPlayers()) do table.insert(pNames, p.Name) end
        Drop:Refresh(pNames)
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

TabCombat:CreateButton({Name = "Выкинуть Убийцу", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then FastFling(p) end end end})
TabCombat:CreateButton({Name = "Выкинуть выбранного", Callback = function() FastFling(game.Players:FindFirstChild(TargetName)) end})

--- --- --- ЭМОЦИИ --- --- ---
local function PlayEm(id)
    local a = Instance.new("Animation")
    a.AnimationId = "rbxassetid://"..id
    LP.Character.Humanoid:LoadAnimation(a):Play()
end
TabEmotes:CreateButton({Name = "Дзен", Callback = function() PlayEm("3189777795") end})
TabEmotes:CreateButton({Name = "Сидеть", Callback = function() PlayEm("3189776528") end})
TabEmotes:CreateButton({Name = "Флос", Callback = function() PlayEm("3189778954") end})
TabEmotes:CreateButton({Name = "Зомби", Callback = function() PlayEmEm("3189780444") end})

--- --- --- ВИЗУАЛЫ & РАЗНОЕ --- --- ---
TabVisuals:CreateToggle({Name = "ESP Роли", CurrentValue = false, Callback = function(v) _G.ESP = v end})
task.spawn(function()
    while task.wait(1) do
        if _G.ESP then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("RayH") or Instance.new("Highlight", p.Character)
                    h.Name = "RayH"
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    h.FillColor = isM and Color3.new(1,0,0) or isS and Color3.new(0,0,1) or Color3.new(0,1,0)
                end
            end
        end
    end
end)

TabMisc:CreateToggle({Name = "Anti-Fling", CurrentValue = true, Callback = function(v)
    RS.Heartbeat:Connect(function() if v and LP.Character then for _,pt in pairs(LP.Character:GetChildren()) do if pt:IsA("BasePart") then pt.CanCollide = false end end end end)
end})

TabTP:CreateButton({Name = "Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})
TabTP:CreateButton({Name = "Карта", Callback = function() local m = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap") if m then LP.Character.HumanoidRootPart.CFrame = m:FindFirstChildOfClass("Part", true).CFrame end end})

Rayfield:Notify({Title = "AlphaControls V8", Content = "Скрипт полностью восстановлен и обновлен!", Duration = 5})
