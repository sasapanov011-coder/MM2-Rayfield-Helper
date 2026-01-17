local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local CorrectKey = "InbKey-2014nivembbdfv34553jdf"
local LP = game.Players.LocalPlayer

local Window = Fluent:CreateWindow({
    Title = "AlphaControls | MM2 ULTIMATE",
    SubTitle = "Verification Required",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local AuthTab = Window:AddTab({ Title = "Ключ", Icon = "key" })

local KeyInput = AuthTab:AddInput("KeyInput", {
    Title = "Введите ключ",
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
    local CombatTab = Window:AddTab({ Title = "Бой / Fling", Icon = "swords" })
    local VisualsTab = Window:AddTab({ Title = "SCP ESP", Icon = "eye" })
    local TeleportTab = Window:AddTab({ Title = "Телепорты", Icon = "map" })

    -- ФУНКЦИЯ УБИТЬ ВСЕХ
    CombatTab:AddButton({
        Title = "УБИТЬ ВСЕХ (Kill All)",
        Description = "Требуется роль Убийцы",
        Callback = function()
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
            else
                Fluent:Notify({Title = "Ошибка", Content = "Нож не найден!"})
            end
        end
    })

    -- ФУНКЦИЯ ВЫСТРЕЛ В УБИЙЦУ
    CombatTab:AddButton({
        Title = "ВЫСТРЕЛ В УБИЙЦУ (Shot Murderer)",
        Description = "Требуется роль Шерифа",
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

    -- ОСТАЛЬНЫЕ ФУНКЦИИ (ESP, FARMS, TELEPORTS...)
    -- [Код функций автофарма и ESP остается как в прошлой версии]
end
