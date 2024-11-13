_G.AutoFarmSettings = {
    CoinDetectRadius = 500,   -- Radius to detect coins (default: 500)
    StepDistance = 10,        -- Distance between each teleportation step (use caution)
    TeleportSmoothness = 0.35, -- Lower value is faster but riskier Higher is Slower And Safer
    ScanInterval = 0.1        -- checker for coins every 0.1 seconds
}

------------- Don't Touch the stuff below lol
local function Notify(message)
    game.StarterGui:SetCore("SendNotification", {
        Title = "AutoFarm Status",
        Text = message,
        Duration = 5
    })
end

local function MoveTo(target)
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRoot = character:WaitForChild("HumanoidRootPart", 5)
    local currentPos = humanoidRoot.Position
    local distance = (target.Position - currentPos).Magnitude
    local steps = math.ceil(distance / _G.AutoFarmSettings.StepDistance)
    local direction = (target.Position - currentPos).Unit

    for i = 1, steps do
        local nextPosition = currentPos + direction * _G.AutoFarmSettings.StepDistance
        local initialCFrame = humanoidRoot.CFrame
        local startTime = tick()

        while tick() - startTime < _G.AutoFarmSettings.TeleportSmoothness do
            local progress = (tick() - startTime) / _G.AutoFarmSettings.TeleportSmoothness
            humanoidRoot.CFrame = CFrame.new(initialCFrame.Position:Lerp(nextPosition, progress), target.Position)
            task.wait(0.005)
        end

        currentPos = nextPosition
    end

    humanoidRoot.CFrame = target
end

local function AutoFarmLoop()
    Notify("AutoFarm Initialized")

    game:GetService("Players").LocalPlayer.Idled:connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)

    while true do
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRoot = character:FindFirstChild("HumanoidRootPart")

        if not character or not humanoidRoot then
            task.wait(0.1)
            continue
        end

        local closestCoin, closestDistance = nil, math.huge

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and obj.Name == "Coin_Server" and obj.Material == Enum.Material.Plastic then
                local coinVisual = obj:FindFirstChild("CoinVisual")
                if coinVisual and coinVisual:IsA("BasePart") and coinVisual.Transparency == 0 then
                    local dist = (humanoidRoot.Position - obj.Position).Magnitude
                    if dist < _G.AutoFarmSettings.CoinDetectRadius and dist < closestDistance then
                        closestDistance = dist
                        closestCoin = obj
                    end
                end
            end
        end

        if closestCoin then
            local coinVisual = closestCoin:FindFirstChild("CoinVisual")
            if coinVisual and coinVisual:IsA("BasePart") and coinVisual.Transparency == 0 then
                local adjustedTarget = closestCoin.CFrame * CFrame.Angles(math.rad(-90), 0, 0) * CFrame.new(0, -1.5, 0)
                MoveTo(adjustedTarget)
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
