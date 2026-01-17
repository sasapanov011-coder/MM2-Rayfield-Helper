local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 Rayfield Ultra | No Key",
   LoadingTitle = "Загрузка скрипта...",
   LoadingSubtitle = "by sasapanov011",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "MM2_Rayfield",
      FileName = "Manager"
   },
   KeySystem = false -- Ключ отключен
})

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")

-- ВКЛАДКИ
local FarmTab = Window:CreateTab("Автофарм", 4483362458)
local CombatTab = Window:CreateTab("Бой & Fling", 4483362458)
local VisualsTab = Window:CreateTab("ESP (ВХ)", 4483362458)
local TeleportTab = Window:CreateTab("Телепорты", 4483362458)

--- --- --- АВТОФАРМ (ПОЛЕТ) --- --- ---

local Farming = false

FarmTab:CreateToggle({
   Name = "Включить Fly Autofarm",
   CurrentValue = false,
   Flag = "FarmEnabled",
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
                              -- Включаем Noclip (проход сквозь стены)
                              if LP.Character:FindFirstChild("Humanoid") then
                                  LP.Character.Humanoid:ChangeState(11) 
                              end
                              
                              -- Телепортируемся прямо в монету
                              hrp.CFrame = coin.CFrame
                              
                              task.wait(1.5) -- Время на сбор
                          end
                      end
                  end
                  task.wait(0.5)
              end
          end)
      end
   end,
})

--- --- --- БОЙ (KILL ALL & SHOT) --- --- ---

CombatTab:CreateSection("Убийство")

CombatTab:CreateButton({
   Name = "🔪 Kill All (Убить всех)",
   Callback = function()
       local knife = LP.Backpack:FindFirstChild("Knife") or LP.Character:FindFirstChild("Knife")
       if knife then
           for _, p in pairs(game.Players:GetPlayers()) do
               if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                   LP.Character.Humanoid:EquipTool(knife)
                   -- ТП за спину и удар
                   LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
                   task.wait(0.1)
                   knife:Activate()
               end
           end
       else
           Rayfield:Notify({Title = "Ошибка", Content = "Возьми нож в руки!", Duration = 3})
       end
   end,
})

CombatTab:CreateButton({
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
           Rayfield:Notify({Title = "Успех", Content = "Выстрел отправлен!", Duration = 3})
       else
           Rayfield:Notify({Title = "Ошибка", Content = "Ты не шериф или убийца не найден", Duration = 3})
       end
   end,
})

CombatTab:CreateSection("Fling (Выкидывание)")

local TargetPlayer = nil
local PlayerNames = {}

-- Обновление списка для выпадающего меню
for _, p in pairs(game.Players:GetPlayers()) do table.insert(PlayerNames, p.Name) end

local Dropdown = CombatTab:CreateDropdown({
   Name = "Выбрать жертву",
   Options = PlayerNames,
   CurrentOption = "",
   Callback = function(Option)
       TargetPlayer = game.Players:FindFirstChild(Option[1]) -- Rayfield возвращает таблицу
   end,
})

-- Автообновление списка игроков каждые 10 сек
task.spawn(function()
    while task.wait(10) do
        local newNames = {}
        for _, p in pairs(game.Players:GetPlayers()) do table.insert(newNames, p.Name) end
        Dropdown:Refresh(newNames)
    end
end)

CombatTab:CreateButton({
   Name = "🌪 Fling Target (Выкинуть)",
   Callback = function()
       if TargetPlayer and TargetPlayer.Character then
           local hrp = LP.Character.HumanoidRootPart
           local trp = TargetPlayer.Character.HumanoidRootPart
           local oldPos = hrp.CFrame
           local s = tick()
           
           Rayfield:Notify({Title = "Fling", Content = "Выкидываем " .. TargetPlayer.Name, Duration = 2})
           
           while tick() - s < 3.5 do
               RS.Heartbeat:Wait()
               hrp.CanCollide = false
               hrp.CFrame = trp.CFrame 
               hrp.Velocity = Vector3.new(0, 0, 0)
               hrp.RotVelocity = Vector3.new(0, 15000, 0)
           end
           
           hrp.Velocity = Vector3.new(0,0,0)
           hrp.CFrame = oldPos
       end
   end,
})

--- --- --- VISUALS (ESP) --- --- ---

local ESP_Enabled = false

VisualsTab:CreateToggle({
   Name = "Включить ESP (Все роли)",
   CurrentValue = false,
   Callback = function(Value)
      ESP_Enabled = Value
   end,
})

task.spawn(function()
    while task.wait(1) do
        if ESP_Enabled then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("RayESP") or Instance.new("Highlight", p.Character)
                    h.Name = "RayESP"
                    
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
                if p.Character and p.Character:FindFirstChild("RayESP") then
                    p.Character.RayESP:Destroy()
                end
            end
        end
    end
end)

--- --- --- TELEPORTS --- --- ---

TeleportTab:CreateButton({
   Name = "🏠 Телепорт в Лобби",
   Callback = function()
       LP.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 140, 10)
   end,
})

TeleportTab:CreateButton({
   Name = "🗺 Телепорт на Карту",
   Callback = function()
       local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("ActiveMap")
       if map then
           local spawn = map:FindFirstChild("Spawn", true) or map:FindFirstChildOfClass("Part")
           if spawn then
                LP.Character.HumanoidRootPart.CFrame = spawn.CFrame * CFrame.new(0, 5, 0)
           end
       else
           Rayfield:Notify({Title = "Ошибка", Content = "Карта не найдена!", Duration = 3})
       end
   end,
})

Rayfield:Notify({Title = "Готово!", Content = "Скрипт загружен. Ключ не нужен.", Duration = 5})
