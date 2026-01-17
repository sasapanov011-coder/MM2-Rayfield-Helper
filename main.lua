local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 | AlphaControls V7 ULTIMATE",
   LoadingTitle = "Загрузка систем боя и защиты...",
   LoadingSubtitle = "by sasapanov011",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")

-- ВКЛАДКИ
local TabFarm = Window:CreateTab("Автофарм", 4483362458)
local TabCombat = Window:CreateTab("Бой & Fling", 4483362458)
local TabEmotes = Window:CreateTab("Эмоции", 4483362458)
local TabVisuals = Window:CreateTab("Визуалы", 4483362458)
local TabMisc = Window:CreateTab("Разное", 4483362458)

--- --- --- АВТОФАРМ (ИСПРАВЛЕННЫЙ) --- --- ---

_G.Farming = false
_G.FarmSpeedValue = 20

TabFarm:CreateToggle({
   Name = "Включить Fly Autofarm",
   CurrentValue = false,
   Callback = function(Value)
      _G.Farming = Value
      if Value then
          task.spawn(function()
              while _G.Farming do
                  local container = workspace:FindFirstChild("CoinContainer", true)
                  if container then
                      for _, coin in pairs(container:GetChildren()) do
                          if not _G.Farming then break end
                          if coin:IsA("BasePart") and coin:FindFirstChild("TouchInterest") then
                              local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                              if hrp then
                                  LP.Character.Humanoid:ChangeState(11)
                                  local dist = (hrp.Position - coin.Position).Magnitude
                                  local duration = dist / _G.FarmSpeedValue
                                  TS:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = coin.CFrame}):Play()
                                  task.wait(duration + 0.1)
                              end
                          end
                      end
                  end
                  task.wait(0.5)
              end
          end)
      end
   end,
})

TabFarm:CreateSlider({
   Name = "Скорость полета",
   Range = {10, 150},
   Increment = 5,
   CurrentValue = 20,
   Callback = function(v) _G.FarmSpeedValue = v end,
})

--- --- --- БОЙ И FLING (УЛУЧШЕННЫЙ) --- --- ---

local function Fling(Target)
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local trp = Target.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        local s = tick()
        Rayfield:Notify({Title = "Fling", Content = "Атака на: " .. Target.Name})
        while tick() - s < 3 do
            RS.Heartbeat:Wait()
            hrp.CanCollide = false
            hrp.CFrame = trp.CFrame
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 20000, 0)
        end
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.CFrame = oldPos
    end
end

TabCombat:CreateSection("Быстрый Fling")

TabCombat:CreateButton({
    Name = "🌪 ВЫКИНУТЬ УБИЙЦУ",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                Fling(p) break
            end
        end
    end
})

TabCombat:CreateButton({
    Name = "🌪 ВЫКИНУТЬ ШЕРИФА",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")) then
                Fling(p) break
            end
        end
    end
})

TabCombat:CreateSection("Выбор игрока")
local TargetName = ""
local Drop = TabCombat:CreateDropdown({
    Name = "Выбрать игрока",
    Options = {"Загрузка..."},
    Callback = function(Option) TargetName = Option[1] end,
})

task.spawn(function()
    while task.wait(5) do
        local plrs = {}
        for _, p in pairs(game.Players:GetPlayers()) do table.insert(plrs, p.Name) end
        Drop:Refresh(plrs)
    end
end)

TabCombat:CreateButton({ Name = "Выкинуть выбранного", Callback = function() Fling(game.Players:FindFirstChild(TargetName)) end })

--- --- --- ЭМОЦИИ (РАБОЧИЕ) --- --- ---

local function Play(id)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. id
    local load = LP.Character.Humanoid:LoadAnimation(anim)
    load:Play()
end

TabEmotes:CreateButton({Name = "Дзен", Callback = function() Play("3189777795") end})
TabEmotes:CreateButton({Name = "Сидеть", Callback = function() Play("3189776528") end})
TabEmotes:CreateButton({Name = "Флос", Callback = function() Play("3189778954") end})
TabEmotes:CreateButton({Name = "Зомби", Callback = function() Play("3189780444") end})

--- --- --- ЗАЩИТА --- --- ---

TabMisc:CreateToggle({
    Name = "Анти-Флинг (Защита)",
    CurrentValue = true,
    Callback = function(v)
        _G.AntiFling = v
        task.spawn(function()
            while _G.AntiFling do
                RS.Heartbeat:Wait()
                if LP.Character then
                    for _, part in pairs(LP.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
    end
})

--- --- --- ВИЗУАЛЫ (ESP) --- --- ---

TabVisuals:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Callback = function(v) _G.ESP = v end
})

task.spawn(function()
    while task.wait(1) do
        if _G.ESP then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("RayH") or Instance.new("Highlight", p.Character)
                    h.Name = "RayH"
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    h.FillColor = isM and Color3.fromRGB(255,0,0) or isS and Color3.fromRGB(0,0,255) or Color3.fromRGB(0,255,0)
                end
            end
        end
    end
end)

Rayfield:Notify({Title = "V7 Загружена", Content = "Все функции исправлены!", Duration = 5})
