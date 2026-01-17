local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 | AlphaControls V6",
   LoadingTitle = "Загрузка системы анимаций...",
   LoadingSubtitle = "by sasapanov011",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local LP = game.Players.LocalPlayer
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")

-- ВКЛАДКИ
local TabFarm = Window:CreateTab("Автофарм (Fly)", 4483362458)
local TabCombat = Window:CreateTab("Бой & Fling", 4483362458)
local TabEmotes = Window:CreateTab("Эмоции", 4483362458) -- НОВАЯ ВКЛАДКА
local TabVisuals = Window:CreateTab("SCP ESP", 4483362458)
local TabTP = Window:CreateTab("Телепорты", 4483362458)

--- --- --- ИСПРАВЛЕННЫЙ АВТОФАРМ --- --- ---

_G.Farming = false
_G.FarmSpeedValue = 15 -- Скорость (теперь чем выше, тем быстрее)

TabFarm:CreateToggle({
   Name = "Включить Fly Autofarm",
   CurrentValue = false,
   Flag = "FarmToggle",
   Callback = function(Value)
      _G.Farming = Value
      if Value then
          task.spawn(function()
              while _G.Farming do
                  local container = workspace:FindFirstChild("CoinContainer", true)
                  if container then
                      local coins = container:GetChildren()
                      for i = 1, #coins do
                          if not _G.Farming then break end
                          local coin = coins[i]
                          if coin:IsA("BasePart") and coin:FindFirstChild("TouchInterest") then
                              local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                              if hrp then
                                  LP.Character.Humanoid:ChangeState(11)
                                  
                                  -- РАСЧЕТ СКОРОСТИ (теперь логичный)
                                  local distance = (hrp.Position - coin.Position).Magnitude
                                  local duration = distance / _G.FarmSpeedValue
                                  
                                  local tween = TS:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = coin.CFrame})
                                  tween:Play()
                                  tween.Completed:Wait()
                                  task.wait(0.05)
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
   Range = {5, 100},
   Increment = 5,
   Suffix = " Скор.",
   CurrentValue = 15,
   Flag = "FarmSpeedSlider",
   Callback = function(Value)
      _G.FarmSpeedValue = Value
   end,
})

--- --- --- ВКЛАДКА: ЭМОЦИИ --- --- ---

local function PlayEmote(emoteName)
    game:GetService("ReplicatedStorage").MainEvent:FireServer("PlayEmote", emoteName)
end

TabEmotes:CreateButton({Name = "Дзен (Zen)", Callback = function() PlayEmote("zen") end})
TabEmotes:CreateButton({Name = "Сидеть (Sit)", Callback = function() PlayEmote("sit") end})
TabEmotes:CreateButton({Name = "Флос (Floss)", Callback = function() PlayEmote("floss") end})
TabEmotes:CreateButton({Name = "Зомби (Zombie)", Callback = function() PlayEmote("zombie") end})
TabEmotes:CreateSection("Инфо: Эмоции работают, если они у вас куплены/экипированы")

--- --- --- ОСТАЛЬНОЙ ФУНКЦИОНАЛ (БОЙ / ESP / ТП) --- --- ---

TabCombat:CreateButton({
   Name = "🔪 Kill All",
   Callback = function()
       local knife = LP.Backpack:FindFirstChild("Knife") or LP.Character:FindFirstChild("Knife")
       if knife then
           for _, p in pairs(game.Players:GetPlayers()) do
               if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                   LP.Character.Humanoid:EquipTool(knife)
                   LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.2)
                   task.wait(0.1)
                   knife:Activate()
               end
           end
       end
   end,
})

TabCombat:CreateButton({
   Name = "🔫 Shot Murderer",
   Callback = function()
       local murderer = nil
       for _, p in pairs(game.Players:GetPlayers()) do
           if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
               murderer = p; break
           end
       end
       local gun = LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")
       if murderer and gun then
           LP.Character.Humanoid:EquipTool(gun)
           game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", 1, murderer.Character.HumanoidRootPart.Position, "Main")
       end
   end,
})

TabVisuals:CreateToggle({
   Name = "Включить ESP",
   CurrentValue = false,
   Callback = function(Value) _G.ESP_Enabled = Value end,
})

task.spawn(function()
    while task.wait(1) do
        if _G.ESP_Enabled then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("RayHighlight") or Instance.new("Highlight", p.Character)
                    h.Name = "RayHighlight"
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    if isM then h.FillColor = Color3.fromRGB(255,0,0)
                    elseif isS then h.FillColor = Color3.fromRGB(0,0,255)
                    else h.FillColor = Color3.fromRGB(0,255,0) end
                end
            end
        end
    end
end)

TabTP:CreateButton({ Name = "🏠 Лобби", Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end })
TabTP:CreateButton({ 
    Name = "🗺 Карта", 
    Callback = function()
        local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
        if map then
            local sp = map:FindFirstChild("Spawn", true) or map:FindFirstChildOfClass("Part")
            if sp then LP.Character.HumanoidRootPart.CFrame = sp.CFrame end
        end
    end 
})

Rayfield:Notify({Title = "V6 Обновлена", Content = "Эмоции добавлены, скорость исправлена!", Duration = 3})
