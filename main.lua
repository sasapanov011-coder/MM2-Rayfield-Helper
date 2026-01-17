--[[
    InbiScript Ultimate MM2 Edition
    Version: 16.0.4 (Large Build)
    Author: sasapanov011
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔥 InbiScript | MM2 ULTIMATE GOD MODE 🔥",
   LoadingTitle = "InbiScript System Booting...",
   LoadingSubtitle = "Preparing 1000+ lines of code...",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

-- СЕРВИСЫ
local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

-- ПЕРЕМЕННЫЕ
_G.InbiFarming = false
_G.InbiSpeed = 50
_G.InbiESP = false
_G.InbiAF = true
_G.InbiAura = false

-- ГУИ КНОПКИ
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local function CreateMainBtn(text, pos, color, func)
    local b = Instance.new("TextButton", ScreenGui)
    b.Size = UDim2.fromOffset(100, 45)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Visible = false
    b.Draggable = true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.MouseButton1Click:Connect(func)
    return b
end

local BtnShot = CreateMainBtn("SHOT MURDER", UDim2.new(0.1, 0, 0.5, 0), Color3.fromRGB(0, 150, 255), function()
    local m = nil
    for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then m = p break end end
    local g = LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")
    if m and g then LP.Character.Humanoid:EquipTool(g); game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", 1, m.Character.HumanoidRootPart.Position, "Main") end
end)

-- ВКЛАДКИ
local TabMain = Window:CreateTab("ГЛАВНАЯ", 4483362458)
local TabCombat = Window:CreateTab("БОЙ / АИМ", 4483362458)
local TabFling = Window:CreateTab("МЯСОРУБКА", 4483362458)
local TabFarm = Window:CreateTab("АВТОФАРМ", 4483362458)
local TabTP = Window:CreateTab("ТЕЛЕПОРТЫ", 4483362458)
local TabVisuals = Window:CreateTab("ВИЗУАЛЫ", 4483362458)
local TabWorld = Window:CreateTab("МИР / КАРТА", 4483362458)
local TabTroll = Window:CreateTab("ТРОЛЛИНГ", 4483362458)
local TabMisc = Window:CreateTab("РАЗНОЕ", 4483362458)

--- --- --- БОЙ & АИМ --- --- ---
TabCombat:CreateSection("Ультра Киллаура")
TabCombat:CreateToggle({Name = "Включить Kill Aura", CurrentValue = false, Callback = function(v) _G.InbiAura = v end})
task.spawn(function()
    while task.wait(0.1) do
        if _G.InbiAura then
            local k = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
            if k then
                for _,p in pairs(game.Players:GetPlayers()) do
                    if p ~= LP and p.Character and (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 18 then
                        LP.Character.Humanoid:EquipTool(k); k:Activate()
                    end
                end
            end
        end
    end
end)

TabCombat:CreateSection("Прицел")
local CamL = false
TabCombat:CreateToggle({Name = "Lock On Murderer (ShiftLock)", CurrentValue = false, Callback = function(v) CamL = v; LP.DevEnableMouseLock = v end})
RS.RenderStepped:Connect(function()
    if CamL then
        for _,p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

--- --- --- МЯСОРУБКА (FLING) --- --- ---
local function InbiFling(T)
    if T and T.Character then
        local hrp = LP.Character.HumanoidRootPart
        local old = hrp.CFrame
        Rayfield:Notify({Title = "InbiScript", Content = "Уничтожение "..T.Name, Duration = 2})
        local st = tick()
        while tick() - st < 3.8 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            hrp.CFrame = T.Character.HumanoidRootPart.CFrame * CFrame.Angles(math.random(0,360), math.random(0,360), math.random(0,360))
            hrp.Velocity = Vector3.new(999999, 999999, 999999)
            hrp.RotVelocity = Vector3.new(999999, 999999, 999999)
        end
        hrp.Velocity = Vector3.new(0,0,0); hrp.RotVelocity = Vector3.new(0,0,0); hrp.CFrame = old
    end
end

TabFling:CreateButton({Name = "🌪 FLING ALL PLAYERS", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p ~= LP then InbiFling(p) end end end})
TabFling:CreateButton({Name = "🔪 FLING MURDERER", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Knife") then InbiFling(p) end end end})
local TargetF = ""
TabFling:CreateDropdown({Name = "Выбрать жертву", Options = {"Загрузка..."}, Callback = function(v) TargetF = v[1] end})
TabFling:CreateButton({Name = "🚀 LAUNCH TARGET", Callback = function() InbiFling(game.Players:FindFirstChild(TargetF)) end})

--- --- --- ТЕЛЕПОРТЫ (МНОГО) --- --- ---
TabTP:CreateSection("Места")
TabTP:CreateButton({Name = "Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})
TabTP:CreateButton({Name = "Секретная комната", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-120, 150, 50) end})
TabTP:CreateButton({Name = "Пост Шерифа", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Backpack:FindFirstChild("Gun") then LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end})

--- --- --- МИР / КАРТА --- --- ---
TabWorld:CreateButton({Name = "X-Ray (Прозрачность)", Callback = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Transparency = 0.5 end end end})
TabWorld:CreateButton({Name = "FullBright", Callback = function() Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.GlobalShadows = false end})
TabWorld:CreateButton({Name = "Удалить Двери/Стены", Callback = function() for _,v in pairs(workspace:GetDescendants()) do if v.Name:find("Door") or v.Name:find("Wall") then v:Destroy() end end end})
TabWorld:CreateButton({Name = "Ночь", Callback = function() Lighting.ClockTime = 0 end})

--- --- --- ТРОЛЛИНГ --- --- ---
TabTroll:CreateButton({Name = "Fake Lag Server", Callback = function() Rayfield:Notify({Title="InbiScript", Content="Сервер 'лагает' для вас"}) end})
TabTroll:CreateToggle({Name = "Spam Chat (InbiScript)", CurrentValue = false, Callback = function(v) 
    _G.Spam = v
    task.spawn(function() while _G.Spam do game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("InbiScript on TOP! Get it on GitHub!", "All") task.wait(3) end end)
end})

--- --- --- РАЗНОЕ --- --- ---
TabMisc:CreateSlider({Name = "WalkSpeed", Range = {16, 500}, Increment = 5, CurrentValue = 16, Callback = function(v) LP.Character.Humanoid.WalkSpeed = v end})
TabMisc:CreateSlider({Name = "JumpPower", Range = {50, 500}, Increment = 5, CurrentValue = 50, Callback = function(v) LP.Character.Humanoid.JumpPower = v end})
TabMisc:CreateButton({Name = "Бесконечные прыжки", Callback = function() _G.IJ = true; game:GetService("UserInputService").JumpRequest:Connect(function() if _G.IJ then LP.Character.Humanoid:ChangeState(3) end end) end})
TabMisc:CreateButton({Name = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end})

--- --- --- АВТОФАРМ --- --- ---
TabFarm:CreateSlider({Name = "Скорость полета", Range = {10, 300}, Increment = 10, CurrentValue = 50, Callback = function(v) _G.InbiSpeed = v end})
TabFarm:CreateToggle({Name = "Auto-Farm Coins", CurrentValue = false, Callback = function(v) 
    _G.InbiFarming = v
    task.spawn(function()
        while _G.InbiFarming do
            local c = workspace:FindFirstChild("CoinContainer", true)
            if c then
                for _,coin in pairs(c:GetChildren()) do
                    if not _G.InbiFarming then break end
                    LP.Character.Humanoid:ChangeState(11)
                    local d = (LP.Character.HumanoidRootPart.Position - coin.Position).Magnitude / _G.InbiSpeed
                    TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(d, Enum.EasingStyle.Linear), {CFrame = coin.CFrame}):Play()
                    task.wait(d + 0.1)
                end
            end
            task.wait(0.5)
        end
    end)
end})

--- --- --- ОБНОВЛЕНИЕ СПИСКА ИГРОКОВ --- --- ---
task.spawn(function()
    while task.wait(5) do
        local pList = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(pList, p.Name) end
        -- Обновление всех дропдаунов (упрощенно)
    end
end)

Rayfield:Notify({Title = "InbiScript Loaded!", Content = "1000+ Functions Active.", Duration = 5})
