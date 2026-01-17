local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 V30 FINAL",
   LoadingTitle = "InbiScript: ПОЛНЫЙ ФИКС",
   LoadingSubtitle = "By sasapanov011-coder",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- --- --- УЛЬТРА КРУТИЛКА (ПОД НОГАМИ) --- --- ---
local function PowerFling(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        
        -- Убираем прыжки и физику
        LP.Character.Humanoid.PlatformStand = true 
        
        -- Силы вращения
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.P = 1e6
        bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bav.AngularVelocity = Vector3.new(0, 4000000, 0) 

        local s = tick()
        while tick() - s < 3.5 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            -- МЫ ПОД НОГАМИ
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.8, 0)
        end
        
        bav:Destroy(); bv:Destroy()
        LP.Character.Humanoid.PlatformStand = false
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = oldPos
    end
end

-- --- --- ВКЛАДКИ --- --- ---
local TabCombat = Window:CreateTab("Бой & Kill All", 4483362458)
local TabFling = Window:CreateTab("Fling", 4483362458)
local TabFarm = Window:CreateTab("Fly Farm", 4483362458)
local TabVisuals = Window:CreateTab("SCP ESP", 4483362458)

--- --- --- БОЙ --- --- ---
TabCombat:CreateButton({
    Name = "💀 KILL ALL (Для Мурдера)",
    Callback = function()
        local k = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
        if not k then return end
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.Humanoid:EquipTool(k)
                LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                task.wait(0.1)
                k:Activate()
            end
        end
    end
})

_G.LockCam = false
TabCombat:CreateToggle({
    Name = "Target Lock (Слежка камеры)",
    CurrentValue = false,
    Callback = function(v) _G.LockCam = v end
})

RS.RenderStepped:Connect(function()
    if _G.LockCam then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                -- КАМЕРА СМОТРИТ НА МУРДЕРА, ТЫ БЕГАЕШЬ САМ
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, p.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

--- --- --- FLING --- --- ---
TabFling:CreateButton({
    Name = "Fling Murderer (Spin)",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                PowerFling(p)
            end
        end
    end
})

local Sel = ""
local Drop = TabFling:CreateDropdown({
    Name = "Выбрать цель",
    Options = {"Загрузка..."},
    Callback = function(v) Sel = v[1] end
})

TabFling:CreateButton({Name = "Крутиться под ним", Callback = function() PowerFling(game.Players:FindFirstChild(Sel)) end})

--- --- --- FARM --- --- ---
_G.Speed = 60
TabFarm:CreateSlider({Name = "Скорость полета", Range = {10, 400}, Increment = 5, CurrentValue = 60, Callback = function(v) _G.Speed = v end})
TabFarm:CreateToggle({Name = "Fly Farm", CurrentValue = false, Callback = function(v) 
    _G.Farming = v
    task.spawn(function()
        while _G.Farming do
            local cc = workspace:FindFirstChild("CoinContainer", true)
            if cc then
                for _, coin in pairs(cc:GetChildren()) do
                    if not _G.Farming then break end
                    LP.Character.Humanoid:ChangeState(11)
                    local dist = (LP.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                    local d = dist / _G.Speed
                    TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(d, Enum.EasingStyle.Linear), {CFrame = coin.CFrame}):Play()
                    task.wait(d + 0.1)
                end
            end
            task.wait(0.2)
        end
    end)
end})

--- --- --- ESP --- --- ---
TabVisuals:CreateToggle({Name = "SCP ESP", CurrentValue = false, Callback = function(v) _G.Esp = v end})
task.spawn(function()
    while task.wait(1) do
        if _G.Esp then
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
        Drop:Refresh(pl)
    end
end)

Rayfield:Notify({Title = "V30 Loaded", Content = "Всё исправлено!", Duration = 5})
