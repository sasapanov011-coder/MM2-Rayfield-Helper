= 5})
--[[ 
    InbiScript V27 - ГИПЕР-ОБНОВЛЕНИЕ
    ФИКС ТАРГЕТА, КРУТИЛКИ И ДОБАВЛЕН KILL ALL
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 V27 (NEW)",
   LoadingTitle = "Проверка версии V27...",
   LoadingSubtitle = "By sasapanov011",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- --- --- СПИН-ФЛИНГ ПОД НОГАМИ (ФИКС) --- --- ---
local function GlobalSpin(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        
        -- Отключаем физику ног, чтобы не прыгать
        LP.Character.Humanoid.PlatformStand = true 
        
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.P = 1e6
        bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bav.AngularVelocity = Vector3.new(0, 4000000, 0) -- МЕГА ВРАЩЕНИЕ

        local s = tick()
        while tick() - s < 3.5 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            -- ПОД НОГАМИ ЦЕЛИ
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.7, 0)
        end
        
        bav:Destroy(); bv:Destroy()
        LP.Character.Humanoid.PlatformStand = false
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = oldPos
    end
end

-- --- --- ВКЛАДКИ --- --- ---
local TabCombat = Window:CreateTab("БОЙ & KILL ALL", 4483362458)
local TabFling = Window:CreateTab("FLING КРУТИЛКА", 4483362458)
local TabFarm = Window:CreateTab("АВТОФАРМ FLY", 4483362458)
local TabVisuals = Window:CreateTab("SCP ESP", 4483362458)
local TabMisc = Window:CreateTab("РАЗНОЕ", 4483362458)

--- --- --- БОЙ (KILL ALL ТУТ) --- --- ---
TabCombat:CreateButton({
    Name = "💀 KILL ALL (Убить всех)",
    Callback = function()
        local k = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
        if not k then 
            Rayfield:Notify({Title = "Ошибка", Content = "Возьми НОЖ в руки!"})
            return 
        end
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                LP.Character.Humanoid:EquipTool(k)
                LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                task.wait(0.1)
                k:Activate()
                task.wait(0.1)
            end
        end
    end
})

_G.CameraLock = false
TabCombat:CreateToggle({
    Name = "Target Camera Lock (Слежка)",
    CurrentValue = false,
    Callback = function(v) _G.CameraLock = v end
})

RS.RenderStepped:Connect(function()
    if _G.CameraLock then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, p.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

--- --- --- FLING --- --- ---
TabFling:CreateButton({
    Name = "Fling Murderer (Крутилка под ногами)",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                GlobalSpin(p)
            end
        end
    end
})

local SelName = ""
local DropF = TabFling:CreateDropdown({
    Name = "Выбрать жертву",
    Options = {"Загрузка..."},
    Callback = function(v) SelName = v[1] end
})

TabFling:CreateButton({Name = "Flight (Крутиться под ним)", Callback = function() GlobalSpin(game.Players:FindFirstChild(SelName)) end})

--- --- --- FLY FARM --- --- ---
_G.FSpeed = 60
TabFarm:CreateSlider({Name = "Скорость полета", Range = {10, 450}, Increment = 5, CurrentValue = 60, Callback = function(v) _G.FSpeed = v end})
TabFarm:CreateToggle({Name = "Автофарм (Fly + NoClip)", CurrentValue = false, Callback = function(v) 
    _G.FarmActive = v
    task.spawn(function()
        while _G.FarmActive do
            local cc = workspace:FindFirstChild("CoinContainer", true)
            if cc then
                for _, coin in pairs(cc:GetChildren()) do
                    if not _G.FarmActive then break end
                    LP.Character.Humanoid:ChangeState(11)
                    local dist = (LP.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                    local d = dist / _G.FSpeed
                    TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(d, Enum.EasingStyle.Linear), {CFrame = coin.CFrame}):Play()
                    task.wait(d + 0.1)
                end
            end
            task.wait(0.2)
        end
    end)
end})

--- --- --- ESP & ANTI-FLING --- --- ---
TabVisuals:CreateToggle({Name = "SCP ESP", CurrentValue = false, Callback = function(v) _G.EspAct = v end})
task.spawn(function()
    while task.wait(1) do
        if _G.EspAct then
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

TabMisc:CreateToggle({Name = "Anti-Fling", CurrentValue = true, Callback = function(v) _G.AFActive = v end})
RS.Heartbeat:Connect(function() 
    if _G.AFActive and LP.Character then 
        for _,p in pairs(LP.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end 
    end 
end)

-- Обновление списка
task.spawn(function()
    while task.wait(5) do
        local ppp = {}
        for _,p in pairs(game.Players:GetPlayers()) do table.insert(ppp, p.Name) end
        DropF:Refresh(ppp)
    end
end)

Rayfield:Notify({Title = "InbiScript V27", Content = "ЗАГРУЖЕНА НОВАЯ ВЕРСИЯ!", Duration = 5})
