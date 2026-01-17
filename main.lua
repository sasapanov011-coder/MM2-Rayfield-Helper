local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 Helper | Rayfield Edition",
   LoadingTitle = "Загрузка скрипта...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "MM2_Configs",
      FileName = "MainConfig"
   }
})

-- Переменные для работы функций
local ESP_Enabled = false
local Autofarm_Enabled = false

-- Создание вкладок
local MainTab = Window:CreateTab("Главная", 4483362458) -- Иконка
local ESPTab = Window:CreateTab("Визуалы (ESP)", 4483362458)

--- --- --- ЛОГИКА ESP --- --- ---

local function CreateHighlight(player)
    if player == game.Players.LocalPlayer then return end
    
    local char = player.Character or player.CharacterAdded:Wait()
    local highlight = char:FindFirstChild("ESPHighlight") or Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.Parent = char
    highlight.Adornee = char
    highlight.FillOpacity = 0.5
    highlight.OutlineTransparency = 0
    
    -- Обновление цвета в зависимости от роли
    task.spawn(function()
        while char and char.Parent and ESP_Enabled do
            local role = "Innocent"
            if player.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") then
                role = "Murderer"
            elseif player.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Revolver") or char:FindFirstChild("Revolver") then
                role = "Sheriff"
            end
            
            if role == "Murderer" then
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный
            elseif role == "Sheriff" then
                highlight.FillColor = Color3.fromRGB(0, 0, 255) -- Синий
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый
            end
            task.wait(1)
        end
        highlight:Destroy()
    end)
end

ESPTab:CreateToggle({
   Name = "Включить ESP (Роли)",
   CurrentValue = false,
   Flag = "ESP_Toggle",
   Callback = function(Value)
      ESP_Enabled = Value
      if Value then
          for _, player in pairs(game.Players:GetPlayers()) do
              CreateHighlight(player)
          end
      end
   end,
})

--- --- --- ЛОГИКА АВТОФАРМА --- --- ---

MainTab:CreateToggle({
   Name = "Автофарм снежинок (3 сек)",
   CurrentValue = false,
   Flag = "Autofarm_Toggle",
   Callback = function(Value)
      Autofarm_Enabled = Value
      
      if Value then
          task.spawn(function()
              while Autofarm_Enabled do
                  -- Ищем монетки/снежинки в Workspace
                  -- В MM2 они обычно лежат в папке "CoinContainer"
                  local coinContainer = workspace:FindFirstChild("CoinContainer", true)
                  if coinContainer then
                      for _, coin in pairs(coinContainer:GetChildren()) do
                          if not Autofarm_Enabled then break end
                          
                          if coin:IsA("BasePart") or coin:FindFirstChild("TouchInterest") then
                              local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                              if hrp then
                                  -- Включаем Noclip перед телепортом
                                  hrp.Parent.Humanoid:ChangeState(11) 
                                  
                                  -- Телепортация
                                  hrp.CFrame = coin.CFrame
                                  
                                  task.wait(3) -- Задержка 3 секунды по твоему запросу
                              end
                          end
                      end
                  else
                      Rayfield:Notify({Title = "Ошибка", Content = "Снежинки не найдены на карте", Duration = 3})
                      task.wait(5)
                  end
                  task.wait(0.1)
              end
          end)
      end
   end,
})

Rayfield:Notify({Title = "Готово!", Content = "Скрипт успешно запущен", Duration = 5})

