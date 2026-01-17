local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "TMS VCL UI | MM2 ULTIMATE",
    SubTitle = "by sasapanov011-coder",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, 
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Автофарм", Icon = "car" }),
    Combat = Window:AddTab({ Title = "Утилиты/Fling", Icon = "shield" }),
    Visuals = Window:AddTab({ Title = "ESP (SCP)", Icon = "eye" }),
    Teleport = Window:AddTab({ Title = "Телепорты", Icon = "map" })
}

local Options = Fluent.Options
local LP = game.Players.LocalPlayer

-- Настройки
local Config = {
    Underground = true,
    FarmSpeed = 50,
    AntiFling = false,
    SelectedPlayer = nil
}

--- --- --- УТИЛИТЫ --- --- ---

-- Функция Флинга (Fling)
local function Fling(TargetPlayer)
    if not TargetPlayer or not TargetPlayer.Character then return end
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local targetHrp = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if hrp and targetHrp then
        local pos = hrp.CFrame
        local th = 0
        repeat
            th = th + 1
            hrp.CFrame = targetHrp.CFrame * CFrame.Angles(math.rad(math.random(0,360)), math.rad(math.random(0,360)), math.rad(math.random(0,360)))
            hrp.Velocity = Vector3.new(99999, 99999, 99999)
            task.wait(0.01)
        until th >= 100 or not targetHrp.Parent
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = pos
    end
end

-- Anti-Fling логика
task.spawn(function()
    while task.wait() do
        if Config.AntiFling and LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

--- --- --- ВКЛАДКА: АВТОФАРМ --- --- ---

Tabs.Main:AddToggle("FarmToggle", {Title = "Включить Автофарм", Default = false})
Tabs.Main:AddToggle("UnderToggle", {Title = "Летать под картой (Скрытно)", Default = true, Callback = function(v) Config.Underground = v end})

task.spawn(function()
    while task.wait(0.1) do
        if Options.FarmToggle.Value then
            local coinContainer = workspace:FindFirstChild("CoinContainer", true)
            if coinContainer then
                for _, coin in pairs(coinContainer:GetChildren()) do
                    if not Options.FarmToggle.Value then break end
                    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and coin:IsA("BasePart") then
                        LP.Character.Humanoid:ChangeState(11) -- Noclip
                        local offset = Config.Underground and Vector3.new(0, -7, 0) or Vector3.new(0, 0, 0)
                        hrp.CFrame = coin.CFrame * CFrame.new(offset)
                        task.wait(2) -- Задержка сбора
                    end
                end
            end
        end
    end
end)

--- --- --- ВКЛАДКА: COMBAT / FLING --- --- ---

local PlayerDrop = Tabs.Combat:AddDropdown("PSelect", {
    Title = "Выбрать игрока",
    Values = {"Загрузка..."},
    Callback = function(v) Config.SelectedPlayer = game.Players:FindFirstChild(v) end
})

task.spawn(function()
    while task.wait(3) do
        local tbl = {}
        for _, p in pairs(game.Players:GetPlayers()) do table.insert(tbl, p.Name) end
        PlayerDrop:SetValues(tbl)
    end
end)

Tabs.Combat:AddButton({Title = "Выкинуть (Fling) цель", Callback = function() Fling(Config.SelectedPlayer) end})

Tabs.Combat:AddButton({
    Title = "Выкинуть Убийцу (Fling Murderer)",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife")) then
                Fling(p)
            end
        end
    end
})

Tabs.Combat:AddToggle("AntiFling", {Title = "Анти-Флинг (Защита)", Default = false, Callback = function(v) Config.AntiFling = v end})

--- --- --- ВКЛАДКА: VISUALS (ПОЛНЫЙ ESP) --- --- ---

local function UpdateESP()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local highlight = char:FindFirstChild("TMS_ESP") or Instance.new("Highlight", char)
            highlight.Name = "TMS_ESP"
            highlight.Enabled = Options.ESPToggle.Value
            
            local hasKnife = p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
            local hasGun = p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Revolver") or char:FindFirstChild("Revolver")
            
            if hasKnife then
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный (Убийца)
            elseif hasGun then
                highlight.FillColor = Color3.fromRGB(0, 0, 255) -- Синий (Шериф)
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый (Мирный)
            end
        end
    end
end

Tabs.Visuals:AddToggle("ESPToggle", {Title = "SCP ESP (Все роли)", Default = false})

task.spawn(function()
    while task.wait(1) do
        if Options.ESPToggle.Value then UpdateESP() end
    end
end)

--- --- --- ВКЛАДКА: ТЕЛЕПОРТЫ --- --- ---

Tabs.Teleport:AddButton({
    Title = "Телепорт в Лобби",
    Callback = function()
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) -- Стандартное лобби MM2
    end
})

Tabs.Teleport:AddButton({
    Title = "Телепорт на Карту",
    Callback = function()
        local map = workspace:FindFirstChild("Map")
        if map then
            local spawn = map:FindFirstChild("Spawn", true) or map:FindFirstChildOfClass("Part")
            LP.Character.HumanoidRootPart.CFrame = spawn.CFrame * CFrame.new(0, 5, 0)
        end
    end
})

Fluent:Notify({Title = "TMS VCL UI", Content = "Скрипт готов. Anti-Fling активен.", Duration = 5})
