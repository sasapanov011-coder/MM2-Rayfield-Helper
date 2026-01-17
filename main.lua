local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "AlphaControls | MM2 ULTIMATE V14",
   LoadingTitle = "Восстановление всех систем...",
   LoadingSubtitle = "by sasapanov011",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- ГИБКИЕ КНОПКИ НА ЭКРАНЕ
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AlphaUltraButtons"

local function CreateBtn(name, pos, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.fromOffset(90, 40)
    Btn.Position = pos
    Btn.BackgroundColor3 = color
    Btn.Text = name
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Visible = false
    Btn.Draggable = true
    Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- Логика для кнопок
local function ShootM()
    local m = nil
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then m = p break end
    end
    local gun = LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")
    if m and gun then
        LP.Character.Humanoid:EquipTool(gun)
        game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", 1, m.Character.HumanoidRootPart.Position, "Main")
    end
end

local function KAll()
    local k = LP.Backpack:FindFirstChild("Knife") or LP.Character:FindFirstChild("Knife")
    if k then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.Humanoid:EquipTool(k)
                LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                task.wait(0.1)
                k:Activate()
            end
        end
    end
end

local ScreenShot = CreateBtn("SHOT M", UDim2.new(0.5, -100, 0.8, 0), Color3.fromRGB(0, 120, 255), ShootM)
local ScreenKill = CreateBtn("KILL ALL", UDim2.new(0.5, 10, 0.8, 0), Color3.fromRGB(255, 0, 0), KAll)

-- ВКЛАДКИ
local TabFarm = Window:CreateTab("Автофарм", 4483362458)
local TabCombat = Window:CreateTab("Бой & Аим", 4483362458)
local TabFling = Window:CreateTab("Fling (Выкинуть)", 4483362458)
local TabEmotes = Window:CreateTab("Эмоции", 4483362458)
local TabVisuals = Window:CreateTab("SCP ESP", 4483362458)
local TabMisc = Window:CreateTab("Разное", 4483362458)

--- --- --- АВТОФАРМ --- --- ---
_G.FarmSpeed = 30
TabFarm:CreateToggle({
   Name = "Fly Autofarm",
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
                           LP.Character.Humanoid:ChangeState(11)
                           local dur = (hrp.Position - coin.Position).Magnitude / _G.FarmSpeed
                           TS:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = coin.CFrame}):Play()
                           task.wait(dur + 0.1)
                       end
                   end
               end
               task.wait(0.5)
           end
       end)
   end
})

TabFarm:CreateSlider({
   Name = "Скорость (больше = быстрее)",
   Range = {10, 250},
   Increment = 10,
   CurrentValue = 30,
   Callback = function(v) _G.FarmSpeed = v end
})

--- --- --- БОЙ & SHIFT LOCK --- --- ---
local SL_Lock = false
TabCombat:CreateToggle({
    Name = "Shift Lock на Murderer",
    CurrentValue = false,
    Callback = function(v) SL_Lock = v end
})

RS.RenderStepped:Connect(function()
    if SL_Lock then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

TabCombat:CreateToggle({Name = "SHOT на экране", CurrentValue = false, Callback = function(v) ScreenShot.Visible = v end})
TabCombat:CreateToggle({Name = "KILL ALL на экране", CurrentValue = false, Callback = function(v) ScreenKill.Visible = v end})

--- --- --- FLING --- --- ---
local function FlingAction(Target)
    if Target and Target.Character then
        local hrp = LP.Character.HumanoidRootPart
        local old = hrp.CFrame
        local s = tick()
        while tick() - s < 3 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame
            hrp.Velocity = Vector3.new(0, 100000, 0)
            hrp.RotVelocity = Vector3.new(0, 100000, 0)
        end
        hrp.Velocity = Vector3.new(0,0,0); hrp.CFrame = old
    end
end

TabFling:CreateButton({Name = "Выкинуть Убийцу (Fling)", Callback = function()
    for _,p in pairs(game.Players:GetPlayers()) do if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then FlingAction(p) end end
end})

TabFling:CreateButton({Name = "Выкинуть Шерифа (Fling)", Callback = function()
    for _,p in pairs(game.Players:GetPlayers()) do if p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then FlingAction(p) end end
end})

local SelName = ""
local Drop = TabFling:CreateDropdown({
    Name = "Выбрать игрока",
    Options = {"Загрузка..."},
    Callback = function(v) SelName = v[1] end
})

task.spawn(function()
    while task.wait(5) do
        local pl = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(pl, p.Name) end
        Drop:Refresh(pl)
    end
end)

TabFling:CreateButton({Name = "Flight (Fling Выбранного)", Callback = function() FlingAction(game.Players:FindFirstChild(SelName)) end})

--- --- --- ЭМОЦИИ --- --- ---
local function Play(id)
    local a = Instance.new("Animation")
    a.AnimationId = "rbxassetid://"..id
    LP.Character.Humanoid:LoadAnimation(a):Play()
end
TabEmotes:CreateButton({Name = "Дзен", Callback = function() Play("3189777795") end})
TabEmotes:CreateButton({Name = "Сидеть", Callback = function() Play("3189776528") end})
TabEmotes:CreateButton({Name = "Флос", Callback = function() Play("3189778954") end})
TabEmotes:CreateButton({Name = "Зомби", Callback = function() Play("3189780444") end})

--- --- --- РАЗНОЕ --- --- ---
TabMisc:CreateButton({Name = "💰 +1M Монет (Визуал)", Callback = function() LP.PlayerGui.MainGui.Game.Coins.Text = "1,000,000" end})
TabMisc:CreateButton({Name = "📦 Открыть Chroma Box (Визуал)", Callback = function() Rayfield:Notify({Title = "BOX", Content = "Вы выбили Chroma Luger!"}) end})

TabMisc:CreateToggle({Name = "Anti-Fling", CurrentValue = true, Callback = function(v) _G.AF = v end})
RS.Heartbeat:Connect(function() if _G.AF and LP.Character then for _,p in pairs(LP.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)

TabVisuals:CreateToggle({Name = "ESP", CurrentValue = false, Callback = function(v) _G.ESP = v end})
task.spawn(function()
    while task.wait(1) do
        if _G.ESP then
            for _,p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("H") or Instance.new("Highlight", p.Character)
                    h.Name = "H"
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    h.FillColor = isM and Color3.new(1,0,0) or isS and Color3.new(0,0,1) or Color3.new(0,1,0)
                end
            end
        end
    end
end)

Rayfield:Notify({Title = "Alpha V14", Content = "Скрипт полностью восстановлен!", Duration = 5})
