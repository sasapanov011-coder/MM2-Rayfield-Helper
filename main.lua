local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "InbiScript | MM2 ULTIMATE GOD",
   LoadingTitle = "Загрузка InbiScript V15...",
   LoadingSubtitle = "by sasapanov011",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- ЭКРАННЫЕ КНОПКИ
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local function CreateMobileBtn(name, pos, color, callback)
    local Btn = Instance.new("TextButton", ScreenGui)
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

local ScreenShot = CreateMobileBtn("SHOT M", UDim2.new(0.5, -100, 0.85, 0), Color3.fromRGB(0, 100, 255), function()
    local m = nil
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then m = p break end
    end
    if m and (LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")) then
        local gun = LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")
        LP.Character.Humanoid:EquipTool(gun)
        game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", 1, m.Character.HumanoidRootPart.Position, "Main")
    end
end)

-- ВКЛАДКИ
local TabCombat = Window:CreateTab("Бой & Аим", 4483362458)
local TabFling = Window:CreateTab("МЯСОРУБКА (Fling)", 4483362458)
local TabFarm = Window:CreateTab("Автофарм", 4483362458)
local TabTP = Window:CreateTab("Телепорты", 4483362458)
local TabVisuals = Window:CreateTab("Визуалы/ESP", 4483362458)
local TabMisc = Window:CreateTab("Разное (МНОГО)", 4483362458)

--- --- --- УЛЬТРА FLING (МЯСОРУБКА) --- --- ---
local function PowerFling(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        local s = tick()
        
        Rayfield:Notify({Title = "InbiScript", Content = "Уничтожаем: "..Target.Name})
        
        while tick() - s < 4 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            hrp.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(tick()*5000), 0)
            hrp.Velocity = Vector3.new(500000, 500000, 500000)
            hrp.RotVelocity = Vector3.new(0, 500000, 0)
        end
        
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.CFrame = oldPos
    end
end

TabFling:CreateButton({Name = "🌪 УБИТЬ ВСЕХ (FLING ALL)", Callback = function()
    for _, p in pairs(game.Players:GetPlayers()) do if p ~= LP then PowerFling(p) end end
end})

TabFling:CreateButton({Name = "🔪 FLING MURDERER", Callback = function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then PowerFling(p) end
    end
end})

local TargetPlayer = ""
TabFling:CreateDropdown({
    Name = "Выбрать жертву",
    Options = {"Загрузка..."},
    Callback = function(v) TargetPlayer = v[1] end
})

TabFling:CreateButton({Name = "🚀 ЗАПУСТИТЬ В КОСМОС", Callback = function()
    PowerFling(game.Players:FindFirstChild(TargetPlayer))
end})

--- --- --- ТЕЛЕПОРТЫ --- --- ---
TabTP:CreateButton({Name = "Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})
TabTP:CreateButton({Name = "Центр карты", Callback = function() 
    local m = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
    if m then LP.Character.HumanoidRootPart.CFrame = m:FindFirstChildOfClass("Part", true).CFrame end
end})
TabTP:CreateButton({Name = "ТП к Шерифу", Callback = function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
            LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
        end
    end
end})

--- --- --- РАЗНОЕ (МНОГО ФУНКЦИЙ) --- --- ---
TabMisc:CreateToggle({Name = "Бесконечный прыжок", CurrentValue = false, Callback = function(v) _G.InfJump = v end})
game:GetService("UserInputService").JumpRequest:Connect(function() if _G.InfJump then LP.Character.Humanoid:ChangeState(3) end end)

TabMisc:CreateButton({Name = "Full Bright (Свет)", Callback = function() game.Lighting.Brightness = 2; game.Lighting.ClockTime = 14; game.Lighting.OutdoorAmbient = Color3.new(1,1,1) end})
TabMisc:CreateButton({Name = "Убрать двери (Map)", Callback = function() for _,v in pairs(workspace:GetDescendants()) do if v.Name == "Door" or v.Name == "Glass" then v:Destroy() end end end})
TabMisc:CreateSlider({Name = "WalkSpeed (Бег)", Range = {16, 250}, Increment = 1, CurrentValue = 16, Callback = function(v) LP.Character.Humanoid.WalkSpeed = v end})
TabMisc:CreateSlider({Name = "JumpPower (Прыжок)", Range = {50, 300}, Increment = 1, CurrentValue = 50, Callback = function(v) LP.Character.Humanoid.JumpPower = v end})

TabMisc:CreateSection("Визуал")
TabMisc:CreateButton({Name = "💰 Fake 10M Coins", Callback = function() LP.PlayerGui.MainGui.Game.Coins.Text = "10,000,000" end})
TabMisc:CreateButton({Name = "🎁 Open All Boxes (Fake)", Callback = function() Rayfield:Notify({Title="InbiScript", Content="Все скины разблокированы (Visual)!"}) end})

--- --- --- БОЙ & АИМ --- --- ---
local M_Lock = false
TabCombat:CreateToggle({Name = "Shift Lock на Убийцу", CurrentValue = false, Callback = function(v) M_Lock = v; LP.DevEnableMouseLock = v end})
RS.RenderStepped:Connect(function()
    if M_Lock then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

TabCombat:CreateToggle({Name = "SHOT на экране", CurrentValue = false, Callback = function(v) ScreenShot.Visible = v end})

--- --- --- АВТОФАРМ & ESP --- --- ---
_G.FS = 40
TabFarm:CreateSlider({Name = "Скорость фарма", Range = {10, 300}, Increment = 10, CurrentValue = 40, Callback = function(v) _G.FS = v end})
TabFarm:CreateToggle({Name = "Auto-Farm Coins", CurrentValue = false, Callback = function(v)
    _G.Farm = v
    task.spawn(function()
        while _G.Farm do
            local c = workspace:FindFirstChild("CoinContainer", true)
            if c then
                for _, coin in pairs(c:GetChildren()) do
                    if not _G.Farm then break end
                    if coin:IsA("BasePart") then
                        LP.Character.Humanoid:ChangeState(11)
                        local d = (LP.Character.HumanoidRootPart.Position - coin.Position).Magnitude / _G.FS
                        TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(d, Enum.EasingStyle.Linear), {CFrame = coin.CFrame}):Play()
                        task.wait(d + 0.1)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end})

TabVisuals:CreateToggle({Name = "ESP", CurrentValue = false, Callback = function(v) _G.ESP = v end})
task.spawn(function()
    while task.wait(1) do
        if _G.ESP then
            for _,p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("InbiH") or Instance.new("Highlight", p.Character)
                    h.Name = "InbiH"
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    h.FillColor = isM and Color3.new(1,0,0) or isS and Color3.new(0,0,1) or Color3.new(0,1,0)
                end
            end6
        end
    end
end)

Rayfield:Notify({Title = "InbiScript V15", Content = "Скрипт загружен! Удачи в игре.", Duration = 5})
