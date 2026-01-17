-- TMS VCL UI Pack Style Implementation
local TMS = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua"))()

local Window = TMS:CreateWindow({
    Title = "TMS VCL UI Pack | MM2",
    SubTitle = "v2.0 Professional",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Автофарм", Icon = "settings" }),
    Combat = Window:AddTab({ Title = "Флинг/Бой", Icon = "swords" }),
    Visuals = Window:AddTab({ Title = "SCP ESP", Icon = "eye" }),
    Teleport = Window:AddTab({ Title = "Телепорты", Icon = "map" })
}

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")

-- Переменные конфигурации
local Config = {
    Flinging = false,
    AntiFling = true,
    ShowInnocents = true,
    ShowSheriff = true,
    ShowMurderer = true
}

--- --- --- ЖЕСТКИЙ FLING (FIXED) --- --- ---

local function SecureFling(Target)
    if not Target or not Target.Character then return end
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    local trp = Target.Character:FindFirstChild("HumanoidRootPart")
    
    if hrp and trp then
        local oldPos = hrp.CFrame
        Config.Flinging = true
        
        -- Чтобы не улететь самому, отключаем столкновения
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end

        local start = tick()
        while tick() - start < 3 and trp.Parent do
            RS.Heartbeat:Wait()
            hrp.CFrame = trp.CFrame * CFrame.new(0, 0, 0)
            -- Вращение для выбивания (Spin)
            hrp.Velocity = Vector3.new(0, 5000, 0) 
            hrp.RotVelocity = Vector3.new(0, 10000, 0)
        end
        
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.CFrame = oldPos
        Config.Flinging = false
    end
end

--- --- --- ВКЛАДКА: АВТОФАРМ --- --- ---

Tabs.Main:AddToggle("FarmUnder", {Title = "Скрытый Автофарм (Under)", Default = false})

task.spawn(function()
    while task.wait(0.1) do
        if TMS.Options.FarmUnder.Value then
            local coins = workspace:FindFirstChild("CoinContainer", true)
            if coins then
                for _, coin in pairs(coins:GetChildren()) do
                    if not TMS.Options.FarmUnder.Value then break end
                    if coin:IsA("BasePart") and LP.Character:FindFirstChild("HumanoidRootPart") then
                        LP.Character.Humanoid:ChangeState(11)
                        LP.Character.HumanoidRootPart.CFrame = coin.CFrame * CFrame.new(0, -7, 0)
                        task.wait(1.2)
                    end
                end
            end
        end
    end
end)

--- --- --- ВКЛАДКА: БОЙ --- --- ---

local PlayerList = Tabs.Combat:AddDropdown("TargetList", {
    Title = "Выбрать игрока",
    Values = {"..."},
    Callback = function(v) _G.ToFling = game.Players:FindFirstChild(v) end
})

task.spawn(function()
    while task.wait(2) do
        local names = {}
        for _, p in pairs(game.Players:GetPlayers()) do table.insert(names, p.Name) end
        PlayerList:SetValues(names)
    end
end)

Tabs.Combat:AddButton({
    Title = "Выбросить игрока (FLING)",
    Callback = function() SecureFling(_G.ToFling) end
})

Tabs.Combat:AddButton({
    Title = "Выбросить ШЕРИФА",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then
                SecureFling(p)
            end
        end
    end
})

Tabs.Combat:AddToggle("AntiFling", {Title = "Анти-Флинг (Защита)", Default = true})

--- --- --- ВКЛАДКА: ESP (УПРАВЛЯЕМЫЙ) --- --- ---

Tabs.Visuals:AddToggle("EspGlobal", {Title = "Включить ESP", Default = false})
Tabs.Visuals:AddToggle("ShowM", {Title = "Показывать Убийцу", Default = true, Callback = function(v) Config.ShowMurderer = v end})
Tabs.Visuals:AddToggle("ShowS", {Title = "Показывать Шерифа", Default = true, Callback = function(v) Config.ShowSheriff = v end})
Tabs.Visuals:AddToggle("ShowI", {Title = "Показывать Мирных", Default = true, Callback = function(v) Config.ShowInnocents = v end})

local function ApplyESP()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local h = char:FindFirstChild("TMS_VCL_ESP") or Instance.new("Highlight", char)
            h.Name = "TMS_VCL_ESP"
            
            local isM = p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
            local isS = p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun")
            
            h.Enabled = false
            if TMS.Options.EspGlobal.Value then
                if isM and Config.ShowMurderer then
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                    h.Enabled = true
                elseif isS and Config.ShowSheriff then
                    h.FillColor = Color3.fromRGB(0, 0, 255)
                    h.Enabled = true
                elseif not isM and not isS and Config.ShowInnocents then
                    h.FillColor = Color3.fromRGB(0, 255, 0)
                    h.Enabled = true
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do ApplyESP() end
end)

--- --- --- ВКЛАДКА: ТЕЛЕПОРТЫ (МГНОВЕННЫЕ) --- --- ---

Tabs.Teleport:AddButton({
    Title = "Мгновенно в Лобби",
    Callback = function()
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10)
    end
})

Tabs.Teleport:AddButton({
    Title = "Мгновенно на Карту",
    Callback = function()
        local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
        if map then
            local sp = map:FindFirstChild("Spawn", true) or map:FindFirstChildOfClass("Part")
            LP.Character.HumanoidRootPart.CFrame = sp.CFrame
        end
    end
})

TMS:Notify({Title = "TMS VCL UI Pack", Content = "Скрипт готов к работе!", Duration = 3})
