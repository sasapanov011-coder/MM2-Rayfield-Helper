local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 | Rayfield Ultimate V4",
   LoadingTitle = "Загрузка скрипта...",
   LoadingSubtitle = "by sasapanov011",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false, 
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

-- ВКЛАДКИ
local TabFarm = Window:CreateTab("Автофарм (Fly)", 4483362458)
local TabCombat = Window:CreateTab("Бой & Fling", 4483362458)
local TabVisuals = Window:CreateTab("SCP ESP", 4483362458)
local TabTP = Window:CreateTab("Телепорты", 4483362458)

--- --- --- АВТОФАРМ С НАСТРОЙКОЙ СКОРОСТИ --- --- ---

local Farming = false
local FarmSpeed = 1 -- Скорость по умолчанию (1 секунда на полет)

TabFarm:CreateToggle({
   Name = "Включить Fly Autofarm",
   CurrentValue = false,
   Flag = "FarmFly",
   Callback = function(Value)
      Farming = Value
      if Value then
          task.spawn(function()
              while Farming do
                  local container = workspace:FindFirstChild("CoinContainer", true)
                  if container then
                      local coins = container:GetChildren()
                      for i = 1, #coins do
                          local coin = coins[i]
                          if not Farming then break end
                          
                          local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                          if hrp and coin:IsA("BasePart") and coin:FindFirstChild("TouchInterest") then
                              LP.Character.Humanoid:ChangeState(11) -- Noclip
                              
                              -- Полет с настраиваемой скоростью
                              local tween = TS:Create(hrp, TweenInfo.new(FarmSpeed, Enum.EasingStyle.Linear), {CFrame = coin.CFrame})
                              tween:Play()
                              tween.Completed:Wait()
                              
                              task.wait(0.1) -- Короткая пауза для сбора
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
   Name = "Скорость полета (меньше = быстрее)",
   Range = {0.1, 3},
   Increment = 0.1,
   Suffix = " сек",
   CurrentValue = 1,
   Flag = "FarmSpeedSlider",
   Callback = function(Value)
      FarmSpeed = Value
   end,
})

--- --- --- БОЙ (KILL ALL & SHOT) --- --- ---

TabCombat:CreateSection("Убийство")

TabCombat:CreateButton({
   Name = "☠️ Kill All (Убить всех)",
   Callback = function()
       local knife = LP.Backpack:FindFirstChild("Knife") or LP.Character:FindFirstChild("Knife")
       if knife then
           for _, p in pairs(game.Players:GetPlayers()) do
               if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                   LP.Character.Humanoid:EquipTool(knife)
                   LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.2)
                   task.wait(0.15)
                   knife:Activate()
               end
           end
       else
           Rayfield:Notify({Title = "Ошибка", Content = "Нужен нож в руках!", Duration = 2})
       end
   end,
})

TabCombat:CreateButton({
   Name = "🔫 Shot Murderer (Выстрел)",
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
           local args = {[1] = 1, [2] = murderer.Character.HumanoidRootPart.Position, [3] = "Main"}
           game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", unpack(args))
       else
           Rayfield:Notify({Title = "Ошибка", Content = "Вы не шериф или М нет", Duration = 2})
       end
   end,
})

--- --- --- FLING --- --- ---

TabCombat:CreateSection("Fling (Выкидывание)")

local TargetName = ""
local PlayersList = {}
for _, p in pairs(game.Players:GetPlayers()) do table.insert(PlayersList, p.Name) end

local Dropdown = TabCombat:CreateDropdown({
   Name = "Выбрать игрока",
   Options = PlayersList,
   CurrentOption = "",
   Callback = function(Option) TargetName = Option[1] end,
})

TabCombat:CreateButton({
   Name = "🌪 Fling Target",
   Callback = function()
       local target = game.Players:FindFirstChild(TargetName)
       if target and target.Character then
           local hrp = LP.Character.HumanoidRootPart
           local oldPos = hrp.CFrame
           local s = tick()
           while tick() - s < 3.5 do
               if not target.Character then break end
               RS.Heartbeat:Wait()
               hrp.CanCollide = false
               hrp.CFrame = target.Character.HumanoidRootPart.CFrame
               hrp.Velocity = Vector3.new(0,0,0)
               hrp.RotVelocity = Vector3.new(0, 15555, 0)
           end
           hrp.Velocity = Vector3.new(0,0,0); hrp.CFrame = oldPos
       end
   end,
})

--- --- --- SCP ESP --- --- ---

local ESP_On = false
TabVisuals:CreateToggle({
   Name = "Включить SCP ESP",
   CurrentValue = false,
   Callback = function(Value) ESP_On = Value end,
})

task.spawn(function()
    while task.wait(1) do
        if ESP_On then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("RayHighlight") or Instance.new("Highlight", p.Character)
                    h.Name = "RayHighlight"; h.Enabled = true
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    if isM then h.FillColor = Color3.fromRGB(255, 0, 0)
                    elseif isS then h.FillColor = Color3.fromRGB(0, 0, 255)
                    else h.FillColor = Color3.fromRGB(0, 255, 0) end
                end
            end
        else
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("RayHighlight") then p.Character.RayHighlight:Destroy() end
            end
        end
    end
end)

--- --- --- ТЕЛЕПОРТЫ --- --- ---

TabTP:CreateButton({
   Name = "В Лобби",
   Callback = function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10) end,
})

TabTP:CreateButton({
   Name = "На Карту",
   Callback = function()
       local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
       if map then
            local sp = map:FindFirstChild("Spawn", true) or map:FindFirstChildOfClass("Part")
            if sp then LP.Character.HumanoidRootPart.CFrame = sp.CFrame end
       end
   end,
})

Rayfield:Notify({Title = "Ready", Content = "Скрипт обновлен!", Duration = 3})
