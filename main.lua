local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 | AlphaControls V5",
   LoadingTitle = "Загрузка системы Rayfield...",
   LoadingSubtitle = "by sasapanov011",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false -- Ключ полностью убран
})

local LP = game.Players.LocalPlayer
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")

-- ВКЛАДКИ
local TabFarm = Window:CreateTab("Автофарм (Fly)", 4483362458)
local TabCombat = Window:CreateTab("Бой & Fling", 4483362458)
local TabVisuals = Window:CreateTab("SCP ESP", 4483362458)
local TabTP = Window:CreateTab("Телепорты", 4483362458)

--- --- --- АВТОФАРМ С ПОЛЗУНКОМ СКОРОСТИ --- --- ---

_G.Farming = false
_G.FarmSpeed = 0.5 -- Значение по умолчанию

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
                          local coin = coins[i]
                          if not _G.Farming then break end
                          
                          if coin:IsA("BasePart") and coin:FindFirstChild("TouchInterest") then
                              local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                              if hrp then
                                  LP.Character.Humanoid:ChangeState(11) -- Noclip
                                  
                                  -- ПОЛЕТ С ИСПОЛЬЗОВАНИЕМ ПОЛЗУНКА
                                  local tween = TS:Create(hrp, TweenInfo.new(_G.FarmSpeed, Enum.EasingStyle.Linear), {CFrame = coin.CFrame})
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
   Name = "Скорость сбора (меньше = быстрее)",
   Range = {0.1, 2},
   Increment = 0.1,
   Suffix = " сек",
   CurrentValue = 0.5,
   Flag = "FarmSpeedSlider",
   Callback = function(Value)
      _G.FarmSpeed = Value
   end,
})

--- --- --- БОЙ (SHOT MURDER & KILL ALL) --- --- ---

TabCombat:CreateSection("Убийство")

TabCombat:CreateButton({
   Name = "🔪 Kill All (Убить всех)",
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
       else
           Rayfield:Notify({Title = "Ошибка", Content = "Нож не найден!", Duration = 3})
       end
   end,
})

TabCombat:CreateButton({
   Name = "🔫 Shot Murderer (Авто-выстрел)",
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
           Rayfield:Notify({Title = "Ошибка", Content = "Вы не шериф или М нет", Duration = 3})
       end
   end,
})

TabCombat:CreateSection("Fling")

local TargetName = ""
local Dropdown = TabCombat:CreateDropdown({
   Name = "Выбрать цель",
   Options = {"Обновление..."},
   CurrentOption = "",
   Callback = function(Option) TargetName = Option[1] end,
})

task.spawn(function()
    while task.wait(5) do
        local plrs = {}
        for _, p in pairs(game.Players:GetPlayers()) do table.insert(plrs, p.Name) end
        Dropdown:Refresh(plrs)
    end
end)

TabCombat:CreateButton({
   Name = "🌪 Fling Target",
   Callback = function()
       local target = game.Players:FindFirstChild(TargetName)
       if target and target.Character then
           local hrp = LP.Character.HumanoidRootPart
           local oldPos = hrp.CFrame
           local s = tick()
           while tick() - s < 3.5 do
               RS.Heartbeat:Wait()
               hrp.CanCollide = false
               hrp.CFrame = target.Character.HumanoidRootPart.CFrame
               hrp.Velocity = Vector3.new(0,0,0)
               hrp.RotVelocity = Vector3.new(0, 15000, 0)
           end
           hrp.Velocity = Vector3.new(0,0,0); hrp.CFrame = oldPos
       end
   end,
})

--- --- --- SCP ESP --- --- ---

local ESP_On = false
TabVisuals:CreateToggle({
   Name = "Включить ESP",
   CurrentValue = false,
   Callback = function(Value) ESP_On = Value end,
})

task.spawn(function()
    while task.wait(1) do
        if ESP_On then
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
        else
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("RayHighlight") then p.Character.RayHighlight:Destroy() end
            end
        end
    end
end)

--- --- --- ТЕЛЕПОРТЫ --- --- ---

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

Rayfield:Notify({Title = "AlphaControls", Content = "Скрипт готов и обновлен!", Duration = 3})
