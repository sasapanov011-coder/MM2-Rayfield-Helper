local VoidWare = loadstring(game:HttpGet("https://raw.githubusercontent.com/VoidWareOfficial/VoidWare-UI/main/Source.lua"))()

local Window = VoidWare:CreateWindow({
    Name = "MM2 VOIDWARE | PRIVATE",
    LoadingTitle = "Загрузка систем...",
    LoadingSubtitle = "by sasapanov011-coder"
})

-- Переменные
local _G = {
    FarmDelay = 2,
    Autofarm = false,
    ESP = false,
    SelectedPlayer = nil,
    AutoShoot = false
}

local MainTab = Window:CreateTab("Главная")
local CombatTab = Window:CreateTab("Бой/Таргет")
local VisualsTab = Window:CreateTab("Визуалы")

--- --- --- ГЛАВНАЯ (АВТОФАРМ) --- --- ---

MainTab:CreateToggle({
    Name = "Автофарм Монет/Снежинок",
    CurrentValue = false,
    Callback = function(Value)
        _G.Autofarm = Value
        if Value then
            task.spawn(function()
                while _G.Autofarm do
                    local coins = workspace:FindFirstChild("CoinContainer", true)
                    if coins then
                        for _, coin in pairs(coins:GetChildren()) do
                            if not _G.Autofarm then break end
                            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and coin:IsA("BasePart") then
                                hrp.Parent.Humanoid:ChangeState(11) -- Noclip
                                hrp.CFrame = coin.CFrame
                                task.wait(_G.FarmDelay)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

MainTab:CreateSlider({
    Name = "Задержка телепорта (сек)",
    Range = {0.5, 5},
    Increment = 0.5,
    CurrentValue = 2,
    Callback = function(Value)
        _G.FarmDelay = Value
    end
})

--- --- --- БОЙ (TARGET / KILL ALL) --- --- ---

local PlayerList = {}
for _, v in pairs(game.Players:GetPlayers()) do table.insert(PlayerList, v.Name) end

CombatTab:CreateDropdown({
    Name = "Выбрать цель (Target)",
    Options = PlayerList,
    CurrentOption = "Никто",
    Callback = function(Option)
        _G.SelectedPlayer = game.Players:FindFirstChild(Option)
    end
})

CombatTab:CreateButton({
    Name = "Убить цель (Нужен нож)",
    Callback = function()
        if _G.SelectedPlayer and game.Players.LocalPlayer.Character:FindFirstChild("Knife") then
            local targetHRP = _G.SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = game.Players.LocalPlayer.Character.HumanoidRootPart
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1)
            -- Код для удара ножом
            game:GetService("ReplicatedStorage").MainEvent:FireServer("Attack")
        end
    end
})

CombatTab:CreateButton({
    Name = "Kill All (Убить всех)",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                local myHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    myHRP.CFrame = p.Character.HumanoidRootPart.CFrame
                    game:GetService("ReplicatedStorage").MainEvent:FireServer("Attack")
                    task.wait(0.2)
                end
            end
        end
    end
})

CombatTab:CreateButton({
    Name = "Выстрелить в Убийцу (Для шерифа)",
    Callback = function()
        local murderer = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife")) then
                murderer = p
                break
            end
        end
        
        if murderer and game.Players.LocalPlayer.Character:FindFirstChild("Gun") then
            local root = murderer.Character.HumanoidRootPart
            local args = {
                [1] = 1,
                [2] = root.Position,
                [3] = "Main"
            }
            game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", unpack(args))
        end
    end
})

--- --- --- ВИЗУАЛЫ (ESP) --- --- ---

local function UpdateESP()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            local char = p.Character
            local highlight = char:FindFirstChild("VoidESP") or Instance.new("Highlight", char)
            highlight.Name = "VoidESP"
            highlight.Enabled = _G.ESP
            
            if p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") then
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Убийца
            elseif p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Revolver") or char:FindFirstChild("Revolver") then
                highlight.FillColor = Color3.fromRGB(0, 0, 255) -- Шериф
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Невиновный
            end
        end
    end
end

VisualsTab:CreateToggle({
    Name = "Включить ESP Ролей",
    CurrentValue = false,
    Callback = function(Value)
        _G.ESP = Value
        task.spawn(function()
            while _G.ESP do
                UpdateESP()
                task.wait(1)
            end
        end)
    end
})
