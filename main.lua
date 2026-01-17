local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Твой ключ
local CorrectKey = "InbKey-2014nivembbdfv34553jdf"
local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")

local Window = Fluent:CreateWindow({
    Title = "AlphaControls | MM2 COMPLETE",
    SubTitle = "Verification Required",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

-- Вкладка Ключа (Видна сразу)
local AuthTab = Window:AddTab({ Title = "Ключ", Icon = "key" })

local KeyInput = AuthTab:AddInput("KeyInput", {
    Title = "Введите ключ доступа",
    Default = "",
    Placeholder = "InbKey-...",
})

AuthTab:AddButton({
    Title = "Проверить и Загрузить",
    Callback = function()
        if Fluent.Options.KeyInput.Value == CorrectKey then
            Fluent:Notify({Title = "Успех", Content = "Ключ принят! Загрузка всех функций...", Duration = 3})
            LoadFullScript() -- Загружаем весь чит
        else
            Fluent:Notify({Title = "Ошибка", Content = "Неверный ключ!", Duration = 5})
        end
    end
})

-- Функция, содержащая ВЕСЬ функционал
function LoadFullScript()
    -- Создаем вкладки
    local FarmTab = Window:AddTab({ Title = "Автофарм", Icon = "car" })
    local CombatTab = Window:AddTab({ Title = "Бой / Fling", Icon = "swords" })
    local OpTab = Window:AddTab({ Title = "Kill All & Shot", Icon = "skull" }) -- НОВАЯ ВКЛАДКА
    local VisualsTab = Window:AddTab({ Title = "SCP ESP", Icon = "eye" })
    local TeleportTab = Window:AddTab({ Title = "Телепорты", Icon = "map" })

    --- --- --- 1. НОВЫЕ ФУНКЦИИ (Shot Murder & Kill All) --- --- ---

    OpTab:AddButton({
        Title = "УБИТЬ ВСЕХ (Kill All)",
        Description = "Требуется нож. Телепортирует к каждому и убивает.",
        Callback = function()
            local knife = LP.Backpack:FindFirstChild("Knife") or LP.Character:FindFirstChild("Knife")
            if knife then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        LP.Character.Humanoid:EquipTool(knife)
                        -- Телепорт за спину жертвы
                        LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.2)
                        task.wait(0.1)
                        knife:Activate()
                    end
                end
            else
                Fluent:Notify({Title = "Ошибка", Content = "Возьмите нож (Вы не убийца)!"})
            end
        end
    })

    OpTab:AddButton({
        Title = "SHOT MURDER (Выстрел в убийцу)",
        Description = "Требуется пистолет. Авто-выстрел.",
        Callback = function()
            local murderer = nil
            -- Ищем убийцу
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                    murderer = p
                    break
                end
            end
            
            local gun = LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")
            
            if murderer and gun then
                LP.Character.Humanoid:EquipTool(gun)
                -- Отправляем событие выстрела
                local args = {
                    [1] = 1,
                    [2] = murderer.Character.HumanoidRootPart.Position,
                    [3] = "Main"
                }
                game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", unpack(args))
                Fluent:Notify({Title = "Успех", Content = "Выстрел отправлен в " .. murderer.Name})
            else
                Fluent:Notify({Title = "Ошибка", Content = "Убийца не найден или у вас нет пистолета"})
            end
        end
    })

    --- --- --- 2. FLING (ВЫКИДЫВАНИЕ) --- --- ---

    local PlayerDrop = CombatTab:AddDropdown("PSelect", {
        Title = "Выбрать игрока для Fling",
        Values = {"Обновление..."},
        Callback = function(v) _G.TargetP = game.Players:FindFirstChild(v) end
    })

    -- Авто-обновление списка игроков
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
                
                -- Жесткий спин-бот для выкидывания
                while tick() - s < 3 do
                    RS.Heartbeat:Wait()
                    hrp.CanCollide = false
                    hrp.CFrame = trp.CFrame -- Телепорт в игрока
                    hrp.Velocity = Vector3.new(0, 0, 0) 
                    hrp.RotVelocity = Vector3.new(0, 15000, 0) -- Бешеное вращение
                end
                
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.RotVelocity = Vector3.new(0,0,0)
                hrp.CFrame = oldPos -- Возврат назад
            else
                Fluent:Notify({Title = "Ошибка", Content = "Игрок не выбран или вышел"})
            end
        end
    })

    CombatTab:AddToggle("AntiFling", {Title = "Anti-Fling (Защита)", Default = true})

    --- --- --- 3. АВТОФАРМ (Скрытый) --- --- ---

    FarmTab:AddToggle("FarmToggle", {Title = "Включить Автофарм", Default = false})
    FarmTab:AddParagraph({Title = "Инфо", Content = "Фарм работает под картой (безопасно)."})

    task.spawn(function()
        while task.wait(0.1) do
            if Fluent.Options.FarmToggle.Value then
                local coins = workspace:FindFirstChild("CoinContainer", true)
                if coins then
                    for _, coin in pairs(coins:GetChildren()) do
                        if not Fluent.Options.FarmToggle.Value then break end
                        if coin:IsA("BasePart") and LP.Character:FindFirstChild("HumanoidRootPart") then
                            LP.Character.Humanoid:ChangeState(11) -- Noclip
                            -- Телепорт на 7 студов ниже монеты
                            LP.Character.HumanoidRootPart.CFrame = coin.CFrame * CFrame.new(0, -7, 0)
                            task.wait(1.2) -- Время на сбор
                        end
                    end
                end
            end
        end
    end)

    --- --- --- 4. SCP ESP (Визуалы) --- --- ---

    VisualsTab:AddToggle("EspOn", {Title = "Включить ESP", Default = false})
    VisualsTab:AddToggle("ShowM", {Title = "Убийца (Красный)", Default = true})
    VisualsTab:AddToggle("ShowS", {Title = "Шериф (Синий)", Default = true})
    VisualsTab:AddToggle("ShowI", {Title = "Невиновные (Зеленый)", Default = true})

    task.spawn(function()
        while task.wait(1) do
            if Fluent.Options.EspOn.Value then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local h = p.Character:FindFirstChild("AlphaESP") or Instance.new("Highlight", p.Character)
                        h.Name = "AlphaESP"
                        h.Enabled = true
                        
                        local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                        local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                        
                        if isM and Fluent.Options.ShowM.Value then 
                            h.FillColor = Color3.fromRGB(255, 0, 0)
                        elseif isS and Fluent.Options.ShowS.Value then 
                            h.FillColor = Color3.fromRGB(0, 0, 255)
                        elseif not isM and not isS and Fluent.Options.ShowI.Value then 
                            h.FillColor = Color3.fromRGB(0, 255, 0)
                        else
                            h.Enabled = false
                        end
                    end
                end
            else
                -- Очистка если выключено
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("AlphaESP") then
                        p.Character.AlphaESP:Destroy()
                    end
                end
            end
        end
    end)

    --- --- --- 5. ТЕЛЕПОРТЫ --- --- ---

    TeleportTab:AddButton({
        Title = "Телепорт в Лобби",
        Callback = function()
            LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10)
        end
    })

    TeleportTab:AddButton({
        Title = "Телепорт на Карту",
        Callback = function()
            local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
            if map then
                -- Ищем точку спавна или любую деталь карты
                local spawn = map:FindFirstChild("Spawn", true) or map:FindFirstChildOfClass("Part")
                if spawn then
                    LP.Character.HumanoidRootPart.CFrame = spawn.CFrame * CFrame.new(0, 5, 0)
                end
            else
                Fluent:Notify({Title = "Ошибка", Content = "Карта не найдена (вы в лобби?)"})
            end
        end
    })
end

Fluent:Notify({Title = "AlphaControls", Content = "Введите ключ доступа", Duration = 5})
