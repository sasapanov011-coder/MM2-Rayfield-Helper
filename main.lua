local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 V18",
   LoadingTitle = "Загрузка InbiScript...",
   LoadingSubtitle = "by sasapanov011",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- Кнопки на экране
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
local TabFling = Window:CreateTab("Fling Система", 4483362458)
local TabFarm = Window:CreateTab("Автофарм", 4483362458)
local TabTP = Window:CreateTab("Телепорты", 4483362458)
local TabVisuals = Window:CreateTab("Визуалы (SCP)", 4483362458)
local TabMisc = Window:CreateTab("Разное", 4483362458)

--- --- --- УЛУЧШЕННЫЙ FLING (НЕ ВЫЛЕТАЕШЬ САМ) --- --- ---
local function SafeFling(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        local s = tick()
        
        -- Делаем себя временно неуязвимым к коллизии
        local bodyVel = Instance.new("BodyVelocity", hrp)
        bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVel.Velocity = Vector3.new(0, 0, 0)
        
        local bodyAng = Instance.new("BodyAngularVelocity", hrp)
        bodyAng.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyAng.P = 1e6
        
        while tick() - s < 3 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            bodyVel.Velocity = (Target.Character.HumanoidRootPart.Position - hrp.Position).Unit * 100
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame
            bodyAng.AngularVelocity = Vector3.new(0, 50000, 0)
        end
        
        bodyVel:Destroy()
        bodyAng:Destroy()
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.CFrame = oldPos
        Rayfield:Notify({Title = "InbiScript", Content = "Игрок "..Target.Name.." выбит!"})
    end
end

TabFling:CreateButton({Name = "Fling Убийцу", Callback = function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then SafeFling(p) end
    end
end})

TabFling:CreateButton({Name = "Fling Шерифа", Callback = function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then SafeFling(p) end
    end
end})

local TargetSel = ""
local FlingDrop = TabFling:CreateDropdown({
    Name = "Выбрать цель",
    Options = {"Загрузка..."},
    Callback = function(v) TargetSel = v[1] end
})

TabFling:CreateButton({Name = "Выкинуть выбранного", Callback = function()
    SafeFling(game.Players:FindFirstChild(TargetSel))
end})

--- --- --- БОЙ: НАПАДЕНИЕ И КИЛАУРА --- --- ---
_G.KillAura = false
TabCombat:CreateToggle({Name = "Kill Aura", CurrentValue = false, Callback = function(v) _G.KillAura = v end})

task.spawn(function()
    while task.wait(0.1) do
        if _G.KillAura then
            local k = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
            if k then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= LP and p.Character and (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 18 then
                        LP.Character.Humanoid:EquipTool(k); k:Activate()
                    end
                end
            end
        end
    end
end)

_G.AttackM = false
TabCombat:CreateToggle({Name = "Нападение на Murderer", CurrentValue = false, Callback = function(v) _G.AttackM = v end})

task.spawn(function()
    while task.wait(0.1) do
        if _G.AttackM then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                    LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
                end
            end
        end
    end
end)

TabCombat:CreateToggle({Name = "SHOT на экране", CurrentValue = false, Callback = function(v) ShotBtn.Visible = v end})

--- --- --- ВИЗУАЛЫ (SCP ESP) --- --- ---
TabVisuals:CreateToggle({Name = "Включить ESP (SCP Style)", CurrentValue = false, Callback = function(v) _G.SCP_ESP = v end})

task.spawn(function()
    while task.wait(1) do
        if _G.SCP_ESP then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("SCPHighlight") or Instance.new("Highlight", p.Character)
                    h.Name = "SCPHighlight"
                    h.OutlineTransparency = 0
                    h.FillTransparency = 0.5
                    
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    
                    if isM then
                        h.FillColor = Color3.fromRGB(255, 0, 0) -- Красный (SCP-Murder)
                    elseif isS then
                        h.FillColor = Color3.fromRGB(0, 0, 255) -- Синий (SCP-Sheriff)
                    else
                        h.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый (SCP-Innocent)
                    end
                end
            end
        end
    end
end)

--- --- --- ТЕЛЕПОРТЫ & ФАРМ --- --- ---
TabTP:CreateButton({Name = "Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})
TabTP:CreateButton({Name = "Карта", Callback = function() 
    local m = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
    if m then LP.Character.HumanoidRootPart.CFrame = m:FindFirstChildOfClass("Part", true).CFrame end
end})

TabFarm:CreateToggle({Name = "Auto-Farm Coins", CurrentValue = false, Callback = function(v)
    _G.AFarm = v
    task.spawn(function()
        while _G.AFarm do
            local c = workspace:FindFirstChild("CoinContainer", true)
            if c and c:FindFirstChildOfClass("Part") then
                local coin = c:FindFirstChildOfClass("Part")
                LP.Character.HumanoidRootPart.CFrame = coin.CFrame
            end
            task.wait(0.3)
        end
    end)
end})

--- --- --- РАЗНОЕ --- --- ---
TabMisc:CreateToggle({Name = "Anti-Fling", CurrentValue = true, Callback = function(v) _G.AntiF = v end})
RS.Heartbeat:Connect(function() 
    if _G.AntiF and LP.Character then 
        for _,p in pairs(LP.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end 
    end 
end)

-- Обновление списка игроков для дропдауна
task.spawn(function()
    while task.wait(5) do
        local plrs = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(plrs, p.Name) end
        FlingDrop:Refresh(plrs)
    end
end)

Rayfield:Notify({Title = "InbiScript V18", Content = "SCP ESP и Новый Fling активированы!", Duration = 5})
