local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- КОНФИГУРАЦИЯ КЛЮЧА
local CorrectKey = "InbKey-2014nivembbdfv34553jdf"

local Window = Fluent:CreateWindow({
    Title = "AlphaControls | MM2 Private",
    SubTitle = "Key System Active",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = {
    Key = Window:AddTab({ Title = "Ключ", Icon = "key" }),
    Main = Window:AddTab({ Title = "Автофарм", Icon = "home" }),
    Combat = Window:AddTab({ Title = "Fling / Бой", Icon = "swords" }),
    Visuals = Window:AddTab({ Title = "SCP ESP", Icon = "eye" }),
    Teleport = Window:AddTab({ Title = "Телепорты", Icon = "map" })
}

local Options = Fluent.Options
local LP = game.Players.LocalPlayer

--- --- --- СИСТЕМА КЛЮЧА --- --- ---

local KeyInput = Tabs.Key:AddInput("KeyInput", {
    Title = "Введите ключ",
    Default = "",
    Placeholder = "Вставьте ключ сюда...",
    Callback = function(Value) end
})

Tabs.Key:AddButton({
    Title = "Проверить ключ",
    Callback = function()
        if Options.KeyInput.Value == CorrectKey then
            Fluent:Notify({Title = "Доступ разрешен", Content = "Добро пожаловать в AlphaControls!", Duration = 5})
            -- Здесь можно разблокировать остальные вкладки, если нужно, 
            -- но для удобства они открыты, просто уведомляем об успехе.
        else
            Fluent:Notify({Title = "Ошибка", Content = "Неверный ключ!", Duration = 5})
        end
    end
})

--- --- --- ЛОГИКА FLING (УЛУЧШЕННЫЙ) --- --- ---

local function BetterFling(Target)
    if Options.KeyInput.Value ~= CorrectKey then return Fluent:Notify({Title="Ошибка", Content="Введите ключ!"}) end
    if not Target or not Target.Character then return end
    
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local trp = Target.Character:FindFirstChild("HumanoidRootPart")
    
    if hrp and trp then
        local oldPos = hrp.CFrame
        local start = tick()
        
        task.spawn(function()
            while tick() - start < 4 and trp.Parent do
                game:GetService("RunService").Heartbeat:Wait()
                hrp.CanCollide = false
                hrp.CFrame = trp.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
                hrp.Velocity = Vector3.new(5000, 5000, 5000)
                hrp.RotVelocity = Vector3.new(0, 15000, 0)
            end
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.RotVelocity = Vector3.new(0,0,0)
            hrp.CFrame = oldPos
        end)
    end
end

--- --- --- ВКЛАДКА: АВТОФАРМ --- --- ---

Tabs.Main:AddToggle("FarmToggle", {Title = "Включить Автофарм (Under)", Default = false})

task.spawn(function()
    while task.wait(0.1) do
        if Options.FarmToggle and Options.FarmToggle.Value and Options.KeyInput.Value == CorrectKey then
            local coins = workspace:FindFirstChild("CoinContainer", true)
            if coins then
                for _, coin in pairs(coins:GetChildren()) do
                    if not Options.FarmToggle.Value then break end
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

--- --- --- ВКЛАДКА: COMBAT --- --- ---

local PlayerDrop = Tabs.Combat:AddDropdown("PSelect", {
    Title = "Выбрать игрока",
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

Tabs.Combat:AddButton({Title = "ВЫКИНУТЬ ЦЕЛЬ (Fling)", Callback = function() BetterFling(_G.TargetP) end})

Tabs.Combat:AddButton({
    Title = "ВЫКИНУТЬ ШЕРИФА",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then
                BetterFling(p)
            end
        end
    end
})

--- --- --- ВКЛАДКА: VISUALS (ПОЛНЫЙ ESP) --- --- ---

Tabs.Visuals:AddToggle("ShowM", {Title = "Подсветка Убийцы (Красный)", Default = false})
Tabs.Visuals:AddToggle("ShowS", {Title = "Подсветка Шерифа (Синий)", Default = false})
Tabs.Visuals:AddToggle("ShowI", {Title = "Подсветка Мирных (Зеленый)", Default = false})

task.spawn(function()
    while task.wait(1) do
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local h = p.Character:FindFirstChild("AlphaESP") or Instance.new("Highlight", p.Character)
                h.Name = "AlphaESP"
                h.Enabled = false
                
                local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                
                if isM and Options.ShowM.Value then
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                    h.Enabled = true
                elseif isS and Options.ShowS.Value then
                    h.FillColor = Color3.fromRGB(0, 0, 255)
                    h.Enabled = true
                elseif not isM and not isS and Options.ShowI.Value then
                    h.FillColor = Color3.fromRGB(0, 255, 0)
                    h.Enabled = true
                end
            end
        end
    end
end)

--- --- --- ВКЛАДКА: ТЕЛЕПОРТЫ --- --- ---

Tabs.Teleport:AddButton({
    Title = "Мгновенно в Лобби",
    Callback = function()
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10)
    end
})

Fluent:Notify({Title = "AlphaControls", Content = "Скрипт загружен. Введите ключ!", Duration = 5})
