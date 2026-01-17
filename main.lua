--[[ 
    InbiScript ULTIMATE V23 - FULL RESTORE
    Everything you asked for is HERE.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 V23 (FULL VERSION)",
   LoadingTitle = "InbiScript: Восстановление проекта...",
   LoadingSubtitle = "Anti-Fling, Fly Farm, Spin Fling Active",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- --- --- ЭКРАННЫЕ КНОПКИ --- --- ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local function CreateInbiBtn(text, pos, color, func)
    local b = Instance.new("TextButton", ScreenGui)
    b.Size = UDim2.fromOffset(90, 40); b.Position = pos; b.BackgroundColor3 = color
    b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.Visible = false; b.Draggable = true
    Instance.new("UICorner", b); b.MouseButton1Click:Connect(func)
    return b
end

local ShotBtn = CreateInbiBtn("SHOT M", UDim2.new(0.5, -100, 0.85, 0), Color3.fromRGB(0, 120, 255), function()
    local m = nil
    for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then m = p break end end
    local g = LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")
    if m and g then LP.Character.Humanoid:EquipTool(g); game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", 1, m.Character.HumanoidRootPart.Position, "Main") end
end)

-- --- --- ВКЛАДКИ --- --- ---
local TabCombat = Window:CreateTab("Бой & Таргет", 4483362458)
local TabFling = Window:CreateTab("Fling (Крутилка)", 4483362458)
local TabFarm = Window:CreateTab("Автофарм (Fly)", 4483362458)
local TabTP = Window:CreateTab("Телепорты", 4483362458)
local TabVisuals = Window:CreateTab("Визуалы (SCP)", 4483362458)
local TabEmotes = Window:CreateTab("Эмоции", 4483362458)
local TabMisc = Window:CreateTab("Разное", 4483362458)

--- --- --- БОЕВОЙ МОДУЛЬ --- --- ---
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

_G.InbiAttackM = false
TabCombat:CreateToggle({Name = "Нападение на Murderer (Stick)", CurrentValue = false, Callback = function(v) _G.InbiAttackM = v end})
task.spawn(function()
    while task.wait(0.01) do
        if _G.InbiAttackM then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                    LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.3)
                end
            end
        end
    end
end)

TabCombat:CreateToggle({Name = "Кнопка SHOT на экране", CurrentValue = false, Callback = function(v) ShotBtn.Visible = v end})

--- --- --- FLING (БЕШЕНОЕ ВРАЩЕНИЕ ПОД НОГАМИ) --- --- ---
local function UltraFling(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart; local oldPos = hrp.CFrame
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.P = 1e6; bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9); bav.AngularVelocity = Vector3.new(0, 2000000, 0)
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9); bv.Velocity = Vector3.new(0, 0, 0)

        local s = tick()
        while tick() - s < 3.5 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            -- ПОЗИЦИЯ: ПОД НОГАМИ (Y -3.5)
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
            hrp.Velocity = Vector3.new(math.random(-100,100), 100, math.random(-100,100))
        end
        bav:Destroy(); bv:Destroy(); hrp.Velocity = Vector3.new(0,0,0); hrp.CFrame = oldPos
    end
end

TabFling:CreateButton({Name = "Fling Murderer", Callback = function()
    for _, p in pairs(game.Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Knife") then UltraFling(p) end end
end})
local TargetSel = ""
local DropF = TabFling:CreateDropdown({Name = "Выбрать жертву", Options = {"Загрузка..."}, Callback = function(v) TargetSel = v[1] end})
TabFling:CreateButton({Name = "Крутиться под ногами цели", Callback = function() UltraFling(game.Players:FindFirstChild(TargetSel)) end})

--- --- --- АВТОФАРМ (FLY + NOCLIP + ПОЛЗУНОК) --- --- ---
_G.InbiFarmSpeed = 50
TabFarm:CreateSlider({Name = "Скорость полета", Range = {10, 350}, Increment = 5, CurrentValue = 50, Callback = function(v) _G.InbiFarmSpeed = v end})
TabFarm:CreateToggle({Name = "Включить Fly Farm", CurrentValue = false, Callback = function(v) 
    _G.InbiFarm = v
    task.spawn(function()
        while _G.InbiFarm do
            local c = workspace:FindFirstChild("CoinContainer", true)
            if c and c:FindFirstChildOfClass("Part") then
                for _, coin in pairs(c:GetChildren()) do
                    if not _G.InbiFarm then break end
                    LP.Character.Humanoid:ChangeState(11)
                    local dist = (LP.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                    local duration = dist / _G.InbiFarmSpeed
                    local t = TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = coin.CFrame})
                    t:Play(); task.wait(duration + 0.1)
                end
            end
            task.wait(0.2)
        end
    end)
end})

--- --- --- ТЕЛЕПОРТЫ --- --- ---
TabTP:CreateButton({Name = "Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})
TabTP:CreateButton({Name = "Карта", Callback = function() 
    local m = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
    if m then LP.Character.HumanoidRootPart.CFrame = m:FindFirstChildOfClass("Part", true).CFrame end
end})

--- --- --- ВИЗУАЛЫ (SCP ESP) --- --- ---
TabVisuals:CreateToggle({Name = "SCP ESP (Роли)", CurrentValue = false, Callback = function(v) _G.SCPESP = v end})
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

--- --- --- ЭМОЦИИ --- --- ---
local function Play(id)
    local a = Instance.new("Animation"); a.AnimationId = "rbxassetid://"..id
    LP.Character.Humanoid:LoadAnimation(a):Play()
end
TabEmotes:CreateButton({Name = "Дзен", Callback = function() Play("3189777795") end})
TabEmotes:CreateButton({Name = "Сидеть", Callback = function() Play("3189776528") end})

--- --- --- РАЗНОЕ --- --- ---
TabMisc:CreateToggle({Name = "Anti-Fling", CurrentValue = true, Callback = function(v) _G.AF = v end})
RS.Heartbeat:Connect(function() 
    if _G.AF and LP.Character then 
        for _,p in pairs(LP.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end 
    end 
end)
TabMisc:CreateButton({Name = "Full Bright", Callback = function() Lighting.Brightness = 2; Lighting.ClockTime = 14 end})

-- Обновление списка игроков
task.spawn(function()
    while task.wait(5) do
        local pl = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(pl, p.Name) end
        DropF:Refresh(pl)
    end
end)

Rayfield:Notify({Title = "InbiScript V23", Content = "Всё восстановлено: Anti-Fling, Farm, Target!", Duration = 5})
