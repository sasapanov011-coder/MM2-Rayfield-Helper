--[[ 
    INBISCRIPT V28 - ULTIMATE REPAIR
    FIXED: KILL ALL, CAMERA LOCK, SPIN FLING
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 V28 (FINAL FIX)",
   LoadingTitle = "Загрузка V28...",
   LoadingSubtitle = "Анти-кэш система активна",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- --- --- МОЩНЫЙ ФЛИНГ ПОД НОГАМИ --- --- ---
local function PowerFling(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        LP.Character.Humanoid.PlatformStand = true

        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9); bv.Velocity = Vector3.new(0, 0, 0)
        
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.P = 1e6; bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bav.AngularVelocity = Vector3.new(0, 5000000, 0) -- МАКСИМАЛЬНЫЙ СПИН

        local s = tick()
        while tick() - s < 3.5 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.7, 0)
        end
        
        bav:Destroy(); bv:Destroy()
        LP.Character.Humanoid.PlatformStand = false
        hrp.Velocity = Vector3.new(0,0,0); hrp.CFrame = oldPos
    end
end

-- --- --- ВКЛАДКИ --- --- ---
local TabCombat = Window:CreateTab("БОЙ & KILL ALL", 4483362458)
local TabFling = Window:CreateTab("FLING (КРУТИЛКА)", 4483362458)
local TabFarm = Window:CreateTab("АВТОФАРМ", 4483362458)
local TabVisuals = Window:CreateTab("SCP ESP", 4483362458)

--- --- --- БОЕВОЙ МОДУЛЬ --- --- ---
TabCombat:CreateButton({
    Name = "⚡ KILL ALL (УБИТЬ ВСЕХ)",
    Callback = function()
        local k = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
        if not k then return end
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                LP.Character.Humanoid:EquipTool(k)
                LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                task.wait(0.15)
                k:Activate()
                task.wait(0.1)
            end
        end
    end
})

_G.CamLock = false
TabCombat:CreateToggle({
    Name = "Target Camera Lock (Слежка)",
    CurrentValue = false,
    Callback = function(v) _G.CamLock = v end
})

RS.RenderStepped:Connect(function()
    if _G.CamLock then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, p.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

--- --- --- FLING --- --- ---
TabFling:CreateButton({
    Name = "Fling Murderer (Spin Under Feet)",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then PowerFling(p) end
        end
    end
})

local TargetSel = ""
local DropF = TabFling:CreateDropdown({
    Name = "Выбрать жертву",
    Options = {"Загрузка..."},
    Callback = function(v) TargetSel = v[1] end
})

TabFling:CreateButton({Name = "Крутиться под целью", Callback = function() PowerFling(game.Players:FindFirstChild(TargetSel)) end})

--- --- --- АВТОФАРМ FLY --- --- ---
_G.FSpeed = 60
TabFarm:CreateSlider({Name = "Скорость", Range = {10, 450}, Increment = 5, CurrentValue = 60, Callback = function(v) _G.FSpeed = v end})
TabFarm:CreateToggle({Name = "Fly Farm (NoClip)", CurrentValue = false, Callback = function(v) 
    _G.FarmActive = v
    task.spawn(function()
        while _G.FarmActive do
            local cc = workspace:FindFirstChild("CoinContainer", true)
            if cc then
                for _, coin in pairs(cc:GetChildren()) do
                    if not _G.FarmActive then break end
                    LP.Character.Humanoid:ChangeState(11)
                    local d = (LP.Character.HumanoidRootPart.Position - coin.Position).Magnitude / _G.FSpeed
                    TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(d, Enum.EasingStyle.Linear), {CFrame = coin.CFrame}):Play()
                    task.wait(d + 0.1)
                end
            end
            task.wait(0.2)
        end
    end)
end})

--- --- --- VISUALS --- --- ---
TabVisuals:CreateToggle({Name = "SCP ESP", CurrentValue = false, Callback = function(v) _G.EspA = v end})
task.spawn(function()
    while task.wait(1) do
        if _G.EspA then
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

-- Обновление списка
task.spawn(function()
    while task.wait(5) do
        local pl = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(pl, p.Name) end
        DropF:Refresh(pl)
    end
end)

print("InbiScript V28 Loaded Successfully!")
Rayfield:Notify({Title = "V28 LOADED", Content = "Всё исправлено!", Duration = 5})

