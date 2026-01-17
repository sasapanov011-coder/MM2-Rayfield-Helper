local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "DevExpress VCL | MM2 PREMIUM",
    SubTitle = "by sasapanov011-coder",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Автофарм (Fly)", Icon = "send" }),
    Combat = Window:AddTab({ Title = "Target & Fling", Icon = "target" }),
    Visuals = Window:AddTab({ Title = "SCP ESP", Icon = "eye" }),
    Misc = Window:AddTab({ Title = "Настройки", Icon = "settings" })
}

local Options = Fluent.Options

-- Переменные управления
local FlySpeed = 50
local ESPEnabled = false
local SelectedPlayer = nil

--- --- --- ЛОГИКА ПОЛЕТА И ФАРМА --- --- ---

local function GetCoin()
    local container = workspace:FindFirstChild("CoinContainer", true) or workspace:FindFirstChild("Coins", true)
    if container then
        for _, v in pairs(container:GetChildren()) do
            if v:IsA("BasePart") then return v end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        if Options.FlyFarm and Options.FlyFarm.Value then
            local coin = GetCoin()
            local char = game.Players.LocalPlayer.Character
            if coin and char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                char.Humanoid:ChangeState(11) -- Noclip
                
                -- Плавный полет (Lerp) к монетке со скоростью
                local dist = (hrp.Position - coin.Position).Magnitude
                local waitTime = dist / FlySpeed
                
                local tween = game:GetService("TweenService"):Create(hrp, TweenInfo.new(waitTime, Enum.EasingStyle.Linear), {CFrame = coin.CFrame})
                tween:Play()
                tween.Completed:Wait()
            end
        end
        task.wait(0.1)
    end
end)

--- --- --- ЛОГИКА FLING (ВЫШИБАНИЕ) --- --- ---

local function FlingPlayer(target)
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    local targetHrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if targetHrp then
        local oldCFrame = hrp.CFrame
        local th = 0
        while targetHrp and targetHrp.Parent and th < 50 do -- 5 секунд попыток
            th = th + 1
            hrp.CFrame = targetHrp.CFrame * CFrame.Angles(math.random(), math.random(), math.random())
            hrp.Velocity = Vector3.new(5000, 5000, 5000) -- Бешеная скорость для флинга
            task.wait(0.01)
        end
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = oldCFrame
    end
end

--- --- --- ВКЛАДКА: АВТОФАРМ --- --- ---

Tabs.Main:AddToggle("FlyFarm", {Title = "Включить Fly Autofarm", Default = false})

Tabs.Main:AddSlider("FlySpeed", {
    Title = "Скорость полета",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        FlySpeed = Value
    end
})

--- --- --- ВКЛАДКА: TARGET --- --- ---

local PlayerDropdown = Tabs.Combat:AddDropdown("PlayerSelect", {
    Title = "Выбрать жертву",
    Values = {},
    Callback = function(Value) SelectedPlayer = game.Players:FindFirstChild(Value) end
})

task.spawn(function()
    while true do
        local names = {}
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer then table.insert(names, p.Name) end
        end
        PlayerDropdown:SetValues(names)
        task.wait(3)
    end
end)

Tabs.Combat:AddButton({
    Title = "Fling (Выкинуть игрока)",
    Callback = function()
        if SelectedPlayer then
            FlingPlayer(SelectedPlayer)
        else
            Fluent:Notify({Title = "Ошибка", Content = "Сначала выбери игрока!"})
        end
    end
})

--- --- --- ВКЛАДКА: ВИЗУАЛЫ (SCP ESP) --- --- ---

local function ApplyESP()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            local char = p.Character
            local high = char:FindFirstChild("PremiumESP") or Instance.new("Highlight", char)
            high.Name = "PremiumESP"
            high.Enabled = ESPEnabled
            high.FillOpacity = 0.4
            
            local isM = p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
            local isS = p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Revolver") or char:FindFirstChild("Revolver")
            
            if isM then
                high.FillColor = Color3.fromRGB(255, 0, 0) -- Убийца КРАСНЫЙ
                high.OutlineColor = Color3.fromRGB(255, 255, 255)
            elseif isS then
                high.FillColor = Color3.fromRGB(0, 0, 255) -- Шериф СИНИЙ
                high.OutlineColor = Color3.fromRGB(255, 255, 255)
            else
                high.FillColor = Color3.fromRGB(0, 255, 0) -- Невинный ЗЕЛЕНЫЙ
                high.OutlineColor = Color3.fromRGB(0, 0, 0)
            end
        end
    end
end

Tabs.Visuals:AddToggle("ESPToggle", {
    Title = "Включить SCP ESP (Все роли)",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
    end
})

task.spawn(function()
    while true do
        if ESPEnabled then ApplyESP() end
        task.wait(0.5)
    end
end)

--- --- --- ВКЛАДКА: НАСТРОЙКИ --- --- ---

Tabs.Misc:AddButton({
    Title = "Бесконечный прыжок",
    Callback = function()
        game:GetService("UserInputService").JumpRequest:Connect(function()
            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end)
    end
})

Fluent:Notify({ Title = "DevExpress VCL", Content = "Скрипт успешно активирован!", Duration = 5 })
