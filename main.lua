local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "MM2 ALPHA CONTROLS",
    SubTitle = "by sasapanov011",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Автофарм", Icon = "home" }),
    Combat = Window:AddTab({ Title = "Бой", Icon = "swords" }),
    Visuals = Window:AddTab({ Title = "ESP (Визуалы)", Icon = "eye" })
}

local Options = Fluent.Options

-- Переменные
local AutofarmDelay = 2
local ESPEnabled = false

--- --- --- ФУНКЦИИ --- --- ---

-- Поиск монет (Снежинок)
local function GetCoin()
    local container = workspace:FindFirstChild("CoinContainer", true) or workspace:FindFirstChild("Coins", true)
    if container then
        for _, v in pairs(container:GetChildren()) do
            if v:IsA("BasePart") or v:FindFirstChild("TouchInterest") then
                return v
            end
        end
    end
    return nil
end

-- Логика Автофарма
task.spawn(function()
    while true do
        if Options.AutofarmToggle and Options.AutofarmToggle.Value then
            local coin = GetCoin()
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if coin and hrp then
                hrp.Parent.Humanoid:ChangeState(11) -- Noclip
                hrp.CFrame = coin.CFrame
                task.wait(AutofarmDelay)
            end
        end
        task.wait(0.1)
    end
end)

--- --- --- ВКЛАДКА: ГЛАВНАЯ (АВТОФАРМ) --- --- ---

Tabs.Main:AddToggle("AutofarmToggle", {Title = "Включить Автофарм", Default = false})

Tabs.Main:AddSlider("DelaySlider", {
    Title = "Задержка телепорта",
    Description = "Через сколько секунд прыгать к новой монете",
    Default = 2,
    Min = 0.5,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        AutofarmDelay = Value
    end
})

--- --- --- ВКЛАДКА: БОЙ --- --- ---

local PlayerDropdown = Tabs.Combat:AddDropdown("PlayerSelect", {
    Title = "Выбрать цель",
    Values = {},
    Multi = false,
    Default = 1,
})

-- Обновление списка игроков
task.spawn(function()
    while true do
        local pNames = {}
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer then table.insert(pNames, p.Name) end
        end
        PlayerDropdown:SetValues(pNames)
        task.wait(5)
    end
end)

Tabs.Combat:AddButton({
    Title = "ТП к цели (Убить)",
    Callback = function()
        local target = game.Players:FindFirstChild(Options.PlayerSelect.Value)
        if target and target.Character then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
})

Tabs.Combat:AddButton({
    Title = "Выстрел в Убийцу (Шериф)",
    Callback = function()
        local murderer = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                murderer = p
                break
            end
        end
        
        if murderer then
            local args = {
                [1] = 1,
                [2] = murderer.Character.HumanoidRootPart.Position,
                [3] = "Main"
            }
            game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", unpack(args))
        end
    end
})

--- --- --- ВКЛАДКА: ВИЗУАЛЫ (ESP) --- --- ---

local function CreateESP()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            local char = p.Character
            local highlight = char:FindFirstChild("AlphaESP") or Instance.new("Highlight", char)
            highlight.Name = "AlphaESP"
            highlight.Enabled = ESPEnabled
            highlight.FillOpacity = 0.5
            
            -- Определение роли
            local isMurderer = p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
            local isSheriff = p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Revolver") or char:FindFirstChild("Revolver")
            
            if isMurderer then
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный
            elseif isSheriff then
                highlight.FillColor = Color3.fromRGB(0, 0, 255) -- Синий
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый
            end
        end
    end
end

Tabs.Visuals:AddToggle("ESPToggle", {
    Title = "Включить ESP Ролей",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if not Value then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("AlphaESP") then
                    p.Character.AlphaESP:Destroy()
                end
            end
        end
    end
})

task.spawn(function()
    while true do
        if ESPEnabled then CreateESP() end
        task.wait(1)
    end
end)

Fluent:Notify({ Title = "Система запущена", Content = "Скрипт AlphaControls готов к работе!", Duration = 5 })
