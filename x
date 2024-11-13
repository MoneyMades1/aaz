------------- Dont Touch the stuff below lol
local function NotifyUser(message)
    game.StarterGui:SetCore("SendNotification", {
        Title = "AutoFarm Status",
        Text = message,
        Duration = 5
    })
end

local function MoveToPosition(targetPosition)
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    local startPosition = rootPart.Position
    local distance = (targetPosition.Position - startPosition).Magnitude
    local stepCount = math.ceil(distance / _G.AutoFarmSettings.StepDistance)
    local direction = (targetPosition.Position - startPosition).Unit

    for step = 1, stepCount do
        local nextPosition = startPosition + direction * _G.AutoFarmSettings.StepDistance
        local initialCFrame = rootPart.CFrame
        local startTime = tick()

        while tick() - startTime < _G.AutoFarmSettings.TeleportSmoothness do
            local progress = (tick() - startTime) / _G.AutoFarmSettings.TeleportSmoothness
            rootPart.CFrame = CFrame.new(initialCFrame.Position:Lerp(nextPosition, progress), targetPosition.Position)
            task.wait(0.005)
        end

        startPosition = nextPosition
    end

    rootPart.CFrame = targetPosition
end

local function AutoFarmLoop()
    NotifyUser("AutoFarm Initialized")

    game:GetService("Players").LocalPlayer.Idled:connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)

    while true do
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:FindFirstChild("HumanoidRootPart")

        if not character or not rootPart then
            task.wait(0.1) 
            continue
        end

        local closestCoin, closestDistance = nil, math.huge

            if obj:IsA("Part") and obj.Name == "Coin_Server" and obj.Material == Enum.Material.Plastic then
                local coinVisual = obj:FindFirstChild("CoinVisual")
                if coinVisual and coinVisual:IsA("BasePart") and coinVisual.Transparency == 0 then
                    local distance = (rootPart.Position - obj.Position).Magnitude
                    if distance < _G.AutoFarmSettings.CoinDetectRadius and distance < closestDistance then
                        closestDistance = distance
                        closestCoin = obj
                    end
                end
            end
        end

        if closestCoin then
            local coinVisual = closestCoin:FindFirstChild("CoinVisual")
            if coinVisual and coinVisual:IsA("BasePart") and coinVisual.Transparency == 0 then
                local adjustedTarget = closestCoin.CFrame * CFrame.Angles(math.rad(-90), 0, 0) * CFrame.new(0, -1.5, 0)
                MoveToPosition(adjustedTarget)
                coinVisual.Transparency = 1
                task.wait(0.1)
            end
        else
            task.wait(5)
        end

        local candyBagFull = player:WaitForChild("PlayerGui"):WaitForChild("MainGUI"):WaitForChild("Game"):WaitForChild("CoinBags"):WaitForChild("Container"):WaitForChild("Candy"):WaitForChild("Full")
        if candyBagFull and candyBagFull.Visible then
            character.Humanoid.Health = 0
        end

        task.wait(_G.AutoFarmSettings.ScanInterval)
    end
end

local function StartAutoFarm()
    while true do
        AutoFarmLoop()
        task.wait(5) 
    end
end

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(StartAutoFarm)
StartAutoFarm()
