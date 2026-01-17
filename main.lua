local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "AlphaControls | MM2 V12 ULTRA",
   LoadingTitle = "Загрузка боевых систем...",
   LoadingSubtitle = "by sasapanov011",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- СОЗДАНИЕ КНОПОК НА ЭКРАНЕ
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AlphaMobileButtons"

local function CreateMobileBtn(name, pos, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.fromOffset(90, 40)
    Btn.Position = pos
    Btn.BackgroundColor3 = color
    Btn.Text = name
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Visible = false
    Btn.Draggable = true 
    local Corner = Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- Логика кнопок
local function DoShoot()
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

local ScreenShot = CreateMobileBtn("SHOT M", UDim2.new(0.5, -100, 0.85, 0), Color3.fromRGB(0, 100, 255), DoShoot)
local ScreenKill = CreateMobileBtn("KILL ALL", UDim2.new(0.5, 10, 0.85, 0), Color3.fromRGB(200, 0, 0), function()
    -- Kill All Logic
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
end)

-- ВКЛАДКИ
local TabCombat = Window:CreateTab("Бой & Аим", 4483362458)
local TabFarm = Window:CreateTab("Автофарм", 4483362458)
local TabEmotes = Window:CreateTab("Эмоции", 4483362458)
local TabVisuals = Window:CreateTab("SCP ESP", 4483362458)
local TabMisc = Window:CreateTab("Разное", 4483362458)

--- --- --- НОВОЕ: KILL AURA & MURDER LOCK --- --- ---

local KillAuraEnabled = false
TabCombat:CreateToggle({
   Name = "Авто-удар (Kill Aura)",
   CurrentValue = false,
   Callback = function(v) KillAuraEnabled = v end
})

task.spawn(function()
    while task.wait(0.1) do
        if KillAuraEnabled then
            local knife = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
            if knife then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 15 then
                            LP.Character.Humanoid:EquipTool(knife)
                            knife:Activate()
                        end
                    end
                end
            end
        end
    end
end)

local MurderLock = false
TabCombat:CreateToggle({
   Name = "Слежка за Убийцей (Cam Lock)",
   CurrentValue = false,
   Callback = function(v) 
       MurderLock = v 
       -- Включаем ShiftLock эффект
       LP.DevEnableMouseLock = v
   end
})

RS.RenderStepped:Connect(function()
    if MurderLock then
        local target = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                target = p.Character:FindFirstChild("HumanoidRootPart")
                break
            end
        end
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

TabCombat:CreateToggle({Name = "SHOT M на экране", CurrentValue = false, Callback = function(v) ScreenShot.Visible = v end})
TabCombat:CreateToggle({Name = "KILL ALL на экране", CurrentValue = false, Callback = function(v) ScreenKill.Visible = v end})

--- --- --- АВТОФАРМ (ИСПРАВЛЕННЫЙ) --- --- ---
_G.FarmSpeed = 30
TabFarm:CreateToggle({
   Name = "Fly Autofarm",
   CurrentValue = false,
   Callback = function(v) 
       _G.Farming = v 
       task.spawn(function()
           while _G.Farming do
               local coins = workspace:FindFirstChild("CoinContainer", true)
               if coins then
                   for _, c in pairs(coins:GetChildren()) do
                       if not _G.Farming then break end
                       if c:IsA("BasePart") then
                           local hrp = LP.Character.HumanoidRootPart
                           LP.Character.Humanoid:ChangeState(11)
                           local duration = (hrp.Position - c.Position).Magnitude / _G.FarmSpeed
                           TS:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = c.CFrame}):Play()
                           task.wait(duration + 0.1)
                       end
                   end
               end
               task.wait(0.2)
           end
       end)
   end
})

TabFarm:CreateSlider({
   Name = "Скорость полета",
   Range = {10, 250},
   Increment = 10,
   CurrentValue = 30,
   Callback = function(v) _G.FarmSpeed = v end
})

--- --- --- ЭМОЦИИ --- --- ---
local function PlayEm(id)
    local a = Instance.new("Animation")
    a.AnimationId = "rbxassetid://"..id
    LP.Character.Humanoid:LoadAnimation(a):Play()
end
TabEmotes:CreateButton({Name = "Дзен", Callback = function() PlayEm("3189777795") end})
TabEmotes:CreateButton({Name = "Сидеть", Callback = function() PlayEm("3189776528") end})
TabEmotes:CreateButton({Name = "Флос", Callback = function() PlayEm("3189778954") end})
TabEmotes:CreateButton({Name = "Зомби", Callback = function() PlayEm("3189780444") end})

--- --- --- ОСТАЛЬНОЕ --- --- ---
TabVisuals:CreateToggle({Name = "SCP ESP", CurrentValue = false, Callback = function(v) _G.ESP = v end})
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
    _G.AF = v
    RS.Heartbeat:Connect(function() if _G.AF and LP.Character then for _,pt in pairs(LP.Character:GetChildren()) do if pt:IsA("BasePart") then pt.CanCollide = false end end end end)
end})

Rayfield:Notify({Title = "V12 Ultra Loaded", Content = "Килаура и Cam Lock добавлены!", Duration = 5})
