-- AimLock --
_G.AimLock = false
_G.Prediction = 0.162
_G.LockBind = "E"
_G.Smoothness = 0.2

local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local camera = workspace.CurrentCamera
local localPlayer = players.LocalPlayer

local aimBotEnabled = false
local currentTarget = nil

local function GetNearestToMouse()
    local closest = nil
    local shortestDistance = math.huge
    local mousePos = userInputService:GetMouseLocation()

    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos = camera:WorldToViewportPoint(head.Position)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

            if distance < shortestDistance then
                shortestDistance = distance
                closest = head
            end
        end
    end

    return closest
end

local function SmoothAimAt(targetPart)
    if targetPart then
        local targetPosition = camera:WorldToViewportPoint(targetPart.Position + targetPart.Velocity * _G.Prediction)
        local mousePos = userInputService:GetMouseLocation()

        local deltaX = targetPosition.X - mousePos.X
        local deltaY = targetPosition.Y - mousePos.Y

        deltaX = deltaX * _G.Smoothness
        deltaY = deltaY * _G.Smoothness

        if math.abs(deltaX) > 0.5 or math.abs(deltaY) > 0.5 then
            mousemoverel(deltaX, deltaY)
        end
    end
end

local function ToggleAimBot()
    if aimBotEnabled then
        aimBotEnabled = false
        currentTarget = nil
    else
        if not currentTarget then
            currentTarget = GetNearestToMouse()
        end
        aimBotEnabled = currentTarget ~= nil
    end
end

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if _G.AimLock and input.KeyCode == Enum.KeyCode[_G.LockBind] then
        ToggleAimBot()
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if aimBotEnabled and _G.AimLock and currentTarget then
        SmoothAimAt(currentTarget)
    end
end)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Library.CreateLib("AYoo WTF?🤑🥵", "DarkTheme")

local Tab = Window:NewTab("Combat")
local Section = Tab:NewSection("AimLock")

Section:NewToggle("Enable AimLock", "Toggle AimLock On/Off", function(state)
    _G.AimLock = state
end)

Section:NewSlider("Prediction", "Set Target Prediction", 50, 0, function(value)
    _G.Prediction = value / 100
end)

Section:NewSlider("Smoothness", "Set Mouse Smoothness", 50, 0, function(value)
    _G.Smoothness = value / 100
end)

Section:NewKeybind("Change Keybind", "Set the Lock Keybind", Enum.KeyCode.E, function() end, function(key)
    _G.LockBind = key.Name
end)

local Tab = Window:NewTab("Settings")
local Section = Tab:NewSection("Customize")

Section:NewKeybind("Toggle Menu", "Press to Toggle the Menu", Enum.KeyCode.F, function()
	Library:ToggleUI()
end)

Section:NewColorPicker("Menu Background", "Change the background color of the menu", Color3.fromRGB(0, 0, 0), function(color)
    Library:ChangeColor("SchemeColor", color)
end)
