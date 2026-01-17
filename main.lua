local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "AlphaControls | MM2 Orion V10", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionMM2", IntroEnabled = false})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

-- СОЗДАНИЕ GUI ДЛЯ КНОПОК НА ЭКРАНЕ
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AlphaMobileButtons"

local function CreateMobileBtn(name, pos, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.fromOffset(90, 40)
    Btn.Position = pos
    Btn.BackgroundColor3 = color
    Btn.Text = name
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Visible = false
    Btn.Active = true
    Btn.Draggable = true 
    local Corner = Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- Логика кнопок
local function ShootMurderer()
    local murderer = nil
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
            murderer = p break
        end
    end
    local gun = LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")
    if murderer and gun then
        LP.Character.Humanoid:EquipTool(gun)
        game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", 1, murderer.Character.HumanoidRootPart.Position, "Main")
    end
end

local function KillAll()
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
    end
end

local ScreenShot = CreateMobileBtn("SHOT M", UDim2.new(0.5, -100, 0.85, 0), Color3.fromRGB(0, 100, 255), ShootMurderer)
local ScreenKill = CreateMobileBtn("KILL ALL", UDim2.new(0.5, 10, 0.85, 0), Color3.fromRGB(200, 0, 0), KillAll)

-- ВКЛАДКИ
local TabFarm = Window:MakeTab({Name = "Автофарм", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabCombat = Window:MakeTab({Name = "Бой & Кнопки", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabEmotes = Window:MakeTab({Name = "Эмоции", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabVisuals = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabTP = Window:MakeTab({Name = "Телепорты", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabMisc = Window:MakeTab({Name = "Разное", Icon = "rbxassetid://4483345998", PremiumOnly = false})

--- --- --- АВТОФАРМ --- --- ---
_G.Farming = false
_G.FarmSpeed = 20

TabFarm:AddToggle({
	Name = "Включить Fly Autofarm",
	Default = false,
	Callback = function(Value)
		_G.Farming = Value
        if Value then
            task.spawn(function()
                while _G.Farming do
                    local coins = workspace:FindFirstChild("CoinContainer", true)
                    if coins then
                        for _, c in pairs(coins:GetChildren()) do
                            if not _G.Farming then break end
                            if c:IsA("BasePart") and c:FindFirstChild("TouchInterest") then
                                local hrp = LP.Character.HumanoidRootPart
                                LP.Character.Humanoid:ChangeState(11)
                                local duration = (hrp.Position - c.Position).Magnitude / _G.FarmSpeed
                                TS:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = c.CFrame}):Play()
                                task.wait(duration + 0.1)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
	end    
})

TabFarm:AddSlider({
	Name = "Скорость полета",
	Min = 10,
	Max = 200,
	Default = 20,
	Color = Color3.fromRGB(255,255,255),
	Increment = 5,
	ValueName = "Скор.",
	Callback = function(Value)
		_G.FarmSpeed = Value
	end    
})

--- --- --- БОЙ & ЭКРАННЫЕ КНОПКИ --- --- ---
TabCombat:AddToggle({
	Name = "Показать SHOT на экране",
	Default = false,
	Callback = function(Value) ScreenShot.Visible = Value end
})

TabCombat:AddToggle({
	Name = "Показать KILL ALL на экране",
	Default = false,
	Callback = function(Value) ScreenKill.Visible = Value end
})

TabCombat:AddSection({Name = "Fling"})

local function FastFling(target)
    if target and target.Character then
        local hrp = LP.Character.HumanoidRootPart
        local old = hrp.CFrame
        local s = tick()
        while tick() - s < 3 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            hrp.CFrame = target.Character.HumanoidRootPart.CFrame
            hrp.RotVelocity = Vector3.new(0, 15000, 0)
        end
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = old
    end
end

TabCombat:AddButton({
	Name = "Выкинуть Убийцу",
	Callback = function()
        for _,p in pairs(game.Players:GetPlayers()) do 
            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then FastFling(p) end 
        end
    end    
})

--- --- --- ЭМОЦИИ --- --- ---
local function PlayEm(id)
    local a = Instance.new("Animation")
    a.AnimationId = "rbxassetid://"..id
    LP.Character.Humanoid:LoadAnimation(a):Play()
end

TabEmotes:AddButton({Name = "Дзен", Callback = function() PlayEm("3189777795") end})
TabEmotes:AddButton({Name = "Сидеть", Callback = function() PlayEm("3189776528") end})
TabEmotes:AddButton({Name = "Флос", Callback = function() PlayEm("3189778954") end})
TabEmotes:AddButton({Name = "Зомби", Callback = function() PlayEm("3189780444") end})

--- --- --- ВИЗУАЛЫ & РАЗНОЕ --- --- ---
_G.ESP = false
TabVisuals:AddToggle({
	Name = "ESP Роли",
	Default = false,
	Callback = function(Value) _G.ESP = Value end
})

task.spawn(function()
    while task.wait(1) do
        if _G.ESP then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("OrionH") or Instance.new("Highlight", p.Character)
                    h.Name = "OrionH"
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    h.FillColor = isM and Color3.new(1,0,0) or isS and Color3.new(0,0,1) or Color3.new(0,1,0)
                end
            end
        end
    end
end)

TabMisc:AddToggle({
	Name = "Anti-Fling",
	Default = true,
	Callback = function(Value)
        _G.AF = Value
        RS.Heartbeat:Connect(function() 
            if _G.AF and LP.Character then 
                for _,pt in pairs(LP.Character:GetChildren()) do if pt:IsA("BasePart") then pt.CanCollide = false end end 
            end 
        end)
    end
})

--- --- --- ТЕЛЕПОРТЫ --- --- ---
TabTP:AddButton({Name = "Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end})
TabTP:AddButton({Name = "Карта", Callback = function() 
    local m = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap") 
    if m then LP.Character.HumanoidRootPart.CFrame = m:FindFirstChildOfClass("Part", true).CFrame end 
end})

OrionLib:Init()
