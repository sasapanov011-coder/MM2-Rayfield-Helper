local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local CorrectKey = "InbKey-2014nivembbdfv34553jdf"
local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")

local Window = Fluent:CreateWindow({
    Title = "AlphaControls | MM2 ULTIMATE V3",
    SubTitle = "Verification Required",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

-- ВКЛАДКА АВТОРИЗАЦИИ
local AuthTab = Window:AddTab({ Title = "Ключ", Icon = "key" })

local KeyInput = AuthTab:AddInput("KeyInput", {
    Title = "Введите ключ доступа",
    Default = "",
    Placeholder = "InbKey-...",
})

AuthTab:AddButton({
    Title = "Проверить ключ",
    Callback = function()
        if Fluent.Options.KeyInput.Value == CorrectKey then
            Fluent:Notify({Title = "Успех", Content = "Доступ разрешен!", Duration = 3})
            LoadFullScript()
        else
            Fluent:Notify({Title = "Ошибка", Content = "Неверный ключ!", Duration = 5})
        end
    end
})

function LoadFullScript()
    local MainTab = Window:AddTab({ Title = "Автофарм", Icon = "car" })
    local CombatTab = Window:AddTab({ Title = "Fling / Бой", Icon = "shield" })
    local NewCombatTab = Window:AddTab({ Title = "Shot & Kill All", Icon = "skull" }) -- НОВАЯ ВКЛАДКА
    local VisualsTab = Window:AddTab({ Title = "SCP ESP", Icon = "eye" })
    local TeleportTab = Window:AddTab({ Title = "Телепорты", Icon = "map" })

    --- --- --- НОВАЯ ВКЛАДКА: SHOT & KILL ALL --- --- ---

    NewCombatTab:AddButton({
        Title = "УБИТЬ ВСЕХ (Kill All)",
        Description = "Телепорт к каждому и удар ножом",
        Callback = function()
            local knife = LP.Backpack:FindFirstChild("Knife") or LP.Character:FindFirstChild("Knife")
            if knife then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        LP.Character.Humanoid:EquipTool(knife)
                        LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.2)
                        task.wait(0.1)
                        knife:Activate()
                    end
                end
            else
                Fluent:Notify({Title = "Ошибка", Content = "Нож не найден!"})
            end
        end
    })

    NewCombatTab:AddButton({
        Title = "ВЫСТРЕЛ В УБИЙЦУ (Shot Murderer)",
        Description = "Авто-наводка и выстрел (для шерифа)",
        Callback = function()
            local murderer = nil
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                    murderer = p
                    break
                end
            end
            local gun = LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")
            if murderer and gun then
                LP.Character.Humanoid:EquipTool(gun)
                local args = {[1] = 1, [2] = murderer.Character.HumanoidRootPart.Position, [3] = "Main"}
                game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", unpack(args))
            else
                Fluent:Notify({Title = "Ошибка", Content = "Цель не найдена или вы не шериф"})
            end
        end
    })

    --- --- --- FLING СИСТЕМА (ИСПРАВЛЕННАЯ) --- --- ---

    local PlayerDrop = CombatTab:AddDropdown("PSelect", {
        Title = "Выбрать цель для Fling",
        Values = {"..."},
        Callback = function(v) _G.TargetP = game.Players:FindFirstChild(v) end
    })

    task.spawn(function()
        while task.wait(3) do
            local names = {}
            for _, p in pairs(game.Players:GetPlayers()) do table.insert(names, p.Name) end
            PlayerDrop:SetValues(names)
        end
    end)

    CombatTab:AddButton({
        Title = "ВЫКИНУТЬ ЦЕЛЬ (Fling)",
        Callback = function()
            if _G.TargetP and _G.TargetP.Character then
                local hrp = LP.Character.HumanoidRootPart
                local trp = _G.TargetP.Character.HumanoidRootPart
                local oldPos = hrp.CFrame
                local s = tick()
                while tick() - s < 3 do
                    RS.Heartbeat:Wait()
                    hrp.CFrame = trp.CFrame
                    hrp.Velocity = Vector3.new(9999, 9999, 9999)
                    hrp.RotVelocity = Vector3.new(0, 15000, 0)
                end
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.CFrame = oldPos
            end
        end
    })

    CombatTab:AddToggle("AntiFling", {Title = "Анти-Флинг Защита", Default = true})

    --- --- --- АВТОФАРМ (UNDERGROUND) --- --- ---

    MainTab:AddToggle("FarmToggle", {Title = "Включить Автофарм", Default = false})
    
    task.spawn(function()
        while task.wait(0.1) do
            if Fluent.Options.FarmToggle.Value then
                local coins = workspace:FindFirstChild("CoinContainer", true)
                if coins then
                    for _, coin in pairs(coins:GetChildren()) do
                        if not Fluent.Options.FarmToggle.Value then break end
                        if coin:IsA("BasePart") and LP.Character:FindFirstChild("HumanoidRootPart") then
                            LP.Character.Humanoid:ChangeState(11)
                            LP.Character.HumanoidRootPart.CFrame = coin.CFrame * CFrame.new(0, -7, 0)
                            task.wait(1.5)
                        end
                    end
                end
            end
        end
    end)

    --- --- --- SCP ESP (УПРАВЛЯЕМЫЙ) --- --- ---

    VisualsTab:AddToggle("EspOn", {Title = "Включить ESP", Default = false})
    VisualsTab:AddToggle("ShowM", {Title = "Подсветка Убийцы", Default = true})
    VisualsTab:AddToggle("ShowS", {Title = "Подсветка Шерифа", Default = true})
    VisualsTab:AddToggle("ShowI", {Title = "Подсветка Мирных", Default = true})

    task.spawn(function()
        while task.wait(1) do
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("AlphaESP") or Instance.new("Highlight", p.Character)
                    h.Name = "AlphaESP"
                    h.Enabled = Fluent.Options.EspOn.Value
                    
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    
                    if isM and Fluent.Options.ShowM.Value then h.FillColor = Color3.fromRGB(255, 0, 0) h.Enabled = Fluent.Options.EspOn.Value
                    elseif isS and Fluent.Options.ShowS.Value then h.FillColor = Color3.fromRGB(0, 0, 255) h.Enabled = Fluent.Options.EspOn.Value
                    elseif not isM and not isS and Fluent.Options.ShowI.Value then h.FillColor = Color3.fromRGB(0, 255, 0) h.Enabled = Fluent.Options.EspOn.Value
                    else h.Enabled = false end
                end
            end
        end
    end)

    --- --- --- ТЕЛЕПОРТЫ --- --- ---

    TeleportTab:AddButton({Title = "Мгновенно в Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})
    TeleportTab:AddButton({Title = "Мгновенно на Карту", Callback = function() 
        local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
        if map then LP.Character.HumanoidRootPart.CFrame = map:FindFirstChildOfClass("Part", true).CFrame end
    end})
end

Fluent:Notify({Title = "AlphaControls", Content = "Введите ключ доступа", Duration = 5})
