local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 | Rayfield Ultimate",
   LoadingTitle = "Загрузка скрипта...",
   LoadingSubtitle = "by sasapanov011",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false, -- КЛЮЧ УБРАН
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")

-- ВКЛАДКИ
local TabFarm = Window:CreateTab("Автофарм (Fly)", 4483362458)
local TabCombat = Window:CreateTab("Бой & Fling", 4483362458)
local TabVisuals = Window:CreateTab("SCP ESP", 4483362458)
local TabTP = Window:CreateTab("Телепорты", 4483362458)

--- --- --- АВТОФАРМ (FLY / ПОЛЕТ) --- --- ---

local Farming = false
local FlySpeed = 0

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
                      for _, coin in pairs(container:GetChildren()) do
                          if not Farming then break end
                          
                          local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                          if hrp and coin:IsA("BasePart") then
                              LP.Character.Humanoid:ChangeState(11) -- Noclip (сквозь стены)
                              
                              -- Полет к монетке
                              local tween = game:GetService("TweenService"):Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {CFrame = coin.CFrame})
                              tween:Play()
                              tween.Completed:Wait()
                              
                              task.wait(0.2) -- Собираем
                          end
                      end
                  end
                  task.wait(1)
              end
          end)
      end
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
                   -- ТП за спину
                   LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.2)
                   task.wait(0.15)
                   knife:Activate()
               end
           end
       else
           Rayfield:Notify({Title = "Ошибка", Content = "Нужен нож (Ты не убийца)", Duration = 2})
       end
   end,
})

TabCombat:CreateButton({
   Name = "🔫 Shot Murderer (Выстрел в убийцу)",
   Callback = function()
       local murderer = nil
       for _, p in pairs(game.Players:GetPlayers()) do
           if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
               murderer = p
               break
           end
       end
       
       local gun = LP.Backpack:FindFirstChild("Gun") or LP.Character:FindFirstChild("Gun")
       
       if murderer and gun then
           LP.Character.Humanoid:EquipTool(gun)
           local args = {
               [1] = 1,
               [2] = murderer.Character.HumanoidRootPart.Position,
               [3] = "Main"
           }
           game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", unpack(args))
           Rayfield:Notify({Title = "Успех", Content = "Выстрел произведен!", Duration = 2})
       else
           Rayfield:Notify({Title = "Ошибка", Content = "Нет пистолета или убийца не найден", Duration = 2})
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
   Callback = function(Option)
       TargetName = Option[1]
   end,
})

-- Обновление списка игроков
task.spawn(function()
    while task.wait(5) do
        local newNames = {}
        for _, p in pairs(game.Players:GetPlayers()) do table.insert(newNames, p.Name) end
        Dropdown:Refresh(newNames)
    end
end)

TabCombat:CreateButton({
   Name = "🌪 Fling Target",
   Callback = function()
       local target = game.Players:FindFirstChild(TargetName)
       if target and target.Character then
           local hrp = LP.Character.HumanoidRootPart
           local oldPos = hrp.CFrame
           
           Rayfield:Notify({Title = "Fling", Content = "Атака на " .. target.Name, Duration = 2})
           
           local s = tick()
           while tick() - s < 4 do
               if not target.Character then break end
               RS.Heartbeat:Wait()
               hrp.CanCollide = false
               hrp.CFrame = target.Character.HumanoidRootPart.CFrame
               hrp.Velocity = Vector3.new(0,0,0)
               hrp.RotVelocity = Vector3.new(0, 15000, 0) -- Вращение
           end
           
           hrp.Velocity = Vector3.new(0,0,0)
           hrp.CFrame = oldPos
       else
           Rayfield:Notify({Title = "Ошибка", Content = "Игрок не выбран", Duration = 2})
       end
   end,
})

--- --- --- SCP ESP --- --- ---

local ESP_On = false

TabVisuals:CreateToggle({
   Name = "Включить SCP ESP",
   CurrentValue = false,
   Callback = function(Value)
      ESP_On = Value
   end,
})

task.spawn(function()
    while task.wait(1) do
        if ESP_On then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("RayHighlight") or Instance.new("Highlight", p.Character)
                    h.Name = "RayHighlight"
                    h.Enabled = true
                    
                    local isM = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isS = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    
                    if isM then
                        h.FillColor = Color3.fromRGB(255, 0, 0) -- Красный
                    elseif isS then
                        h.FillColor = Color3.fromRGB(0, 0, 255) -- Синий
                    else
                        h.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый
                    end
                end
            end
        else
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("RayHighlight") then
                    p.Character.RayHighlight:Destroy()
                end
            end
        end
    end
end)

--- --- --- ТЕЛЕПОРТЫ --- --- ---

TabTP:CreateButton({
   Name = "В Лобби",
   Callback = function()
       LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10)
   end,
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

Rayfield:Notify({Title = "Rayfield Loaded", Content = "Скрипт готов! Ключа нет.", Duration = 3})
