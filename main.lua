local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- СОЗДАНИЕ КНОПКИ "OPEN" ПРИ ЗАКРЫТИИ
local OpenGui = Instance.new("ScreenGui")
local OpenButton = Instance.new("TextButton")

OpenGui.Name = "OpenGui"
OpenGui.Parent = game.CoreGui
OpenGui.Enabled = false

OpenButton.Name = "OpenButton"
OpenButton.Parent = OpenGui
OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenButton.Position = UDim2.new(0.5, -25, 0, 10)
OpenButton.Size = UDim2.new(0, 50, 0, 25)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Text = "OPEN"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 14:

OpenButton.MouseButton1Click:Connect(function()
    Fluent:Toggle()
end)

local Window = Fluent:CreateWindow({
    Title = "TMS VCL UI | MM2 MEGA MOD",
    SubTitle = "by sasapanov011-coder",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

-- Отслеживание состояния окна для кнопки
task.spawn(function()
    while task.wait(0.5) do
        OpenGui.Enabled = not Fluent.Visible
    end
end)

local Tabs = {
    Main = Window:AddTab({ Title = "Автофарм", Icon = "car" }),
    Combat = Window:AddTab({ Title = "Fling / Бой", Icon = "shield" }),
    Visuals = Window:AddTab({ Title = "ESP (SCP)", Icon = "eye" }),
    World = Window:AddTab({ Title = "Мир", Icon = "map" })
}

local Options = Fluent.Options
local LP = game.Players.LocalPlayer

--- --- --- ЛОГИКА FLING (ВЫШИБАНИЕ) --- --- ---

local function PowerFling(Target)
    if not Target or not Target.Character then return end
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local trp = Target.Character:FindFirstChild("HumanoidRootPart")
    
    if hrp and trp then
        local oldPos = hrp.CFrame
        local timer = 0
        
        -- Делаем персонажа невидимым/прозрачным для флинга
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end

        repeat
            timer = timer + 1
            hrp.CFrame = trp.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(math.random(), math.random(), math.random())
            hrp.Velocity = Vector3.new(1000000, 1000000, 1000000) -- Огромная скорость
            task.wait(0.01)
        until timer >= 60 or not trp.Parent
        
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = oldPos
    end
end

--- --- --- АВТОПОДБОР ПИСТОЛЕТА --- --- ---

task.spawn(function()
    while task.wait(0.1) do
        if Options.AutoPickGun and Options.AutoPickGun.Value then
            local gunDrop = workspace:FindFirstChild("GunDrop")
            if gunDrop and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local oldPos = LP.Character.HumanoidRootPart.CFrame
                LP.Character.HumanoidRootPart.CFrame = gunDrop.CFrame
                task.wait(0.3)
                LP.Character.HumanoidRootPart.CFrame = oldPos
            end
        end
    end
end)

--- --- --- ВКЛАДКА: АВТОФАРМ --- --- ---

Tabs.Main:AddToggle("FarmToggle", {Title = "Включить Автофарм", Default = false})
Tabs.Main:AddToggle("UnderToggle", {Title = "Скрытый режим (Под полом)", Default = true})

task.spawn(function()
    while task.wait(0.1) do
        if Options.FarmToggle and Options.FarmToggle.Value then
            local container = workspace:FindFirstChild("CoinContainer", true)
            if container then
                for _, coin in pairs(container:GetChildren()) do
                    if not Options.FarmToggle.Value then break end
                    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and coin:IsA("BasePart") then
                        LP.Character.Humanoid:ChangeState(11) -- Noclip
                        local yOff = Options.UnderToggle.Value and -7 or 0
                        hrp.CFrame = coin.CFrame * CFrame.new(0, yOff, 0)
                        task.wait(1.5)
                    end
                end
            end
        end
    end
end)

--- --- --- ВКЛАДКА: COMBAT --- --- ---

local PlayerDrop = Tabs.Combat:AddDropdown("PSelect", {
    Title = "Выбрать жертву",
    Values = {"..."},
    Callback = function(v) _G.Target = game.Players:FindFirstChild(v) end
})

task.spawn(function()
    while task.wait(3) do
        local names = {}
        for _, p in pairs(game.Players:GetPlayers()) do table.insert(names, p.Name) end
        PlayerDrop:SetValues(names)
    end
end)

Tabs.Combat:AddButton({Title = "ВЫКИНУТЬ ЦЕЛЬ (Fling)", Callback = function() PowerFling(_G.Target) end})

Tabs.Combat:AddButton({
    Title = "ВЫКИНУТЬ ШЕРИФА",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then
                PowerFling(p)
            end
        end
    end
})

Tabs.Combat:AddToggle("AutoPickGun", {Title = "Автоподбор пистолета", Default = false})
Tabs.Combat:AddToggle("AntiFling", {Title = "Анти-Флинг Защита", Default = true})

--- --- --- ВКЛАДКА: VISUALS (ПОЛНЫЙ ESP) --- --- ---

local function ApplyESP()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local h = char:FindFirstChild("TMS_ESP") or Instance.new("Highlight", char)
            h.Name = "TMS_ESP"
            h.Enabled = Options.ESPToggle.Value
            
            local isM = p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
            local isS = p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Revolver") or char:FindFirstChild("Revolver")
            
            if isM then
                h.FillColor = Color3.fromRGB(255, 0, 0) -- Красный
            elseif isS then
                h.FillColor = Color3.fromRGB(0, 0, 255) -- Синий
            else
                h.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый
            end
        end
    end
end

Tabs.Visuals:AddToggle("ESPToggle", {Title = "Включить ESP (Все роли)", Default = false})

task.spawn(function()
    while task.wait(0.5) do
        if Options.ESPToggle and Options.ESPToggle.Value then ApplyESP() end
    end
end)

--- --- --- ВКЛАДКА: ТЕЛЕПОРТЫ --- --- ---

Tabs.World:AddButton({Title = "Телепорт в Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})

Fluent:Notify({Title = "TMS VCL UI", Content = "Скрипт загружен! Кнопка OPEN сверху.", Duration = 5})
