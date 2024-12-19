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

-- ESP --
_G.ESP = false
_G.ESPColor = Color3.fromRGB(255, 0, 0)

local Space = game:GetService("Workspace")
local Player = game:GetService("Players").LocalPlayer
local Camera = Space.CurrentCamera

local function NewLine(color, thickness)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function Vis(lib, state)
    for i, v in pairs(lib) do
        v.Visible = state
    end
end

local function Colorize(lib, color)
    for i, v in pairs(lib) do
        v.Color = color
    end
end

local Black = Color3.fromRGB(0, 0, 0)

local function Rainbow(lib, delay)
    for hue = 0, 1, 1/30 do
        local color = Color3.fromHSV(hue, 0.6, 1)
        Colorize(lib, color)
        wait(delay)
    end
    Rainbow(lib)
end

local function Main(plr)
    repeat wait() until plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil
    local R15
    if plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
        R15 = true
    else 
        R15 = false
    end
    local Library = {
        TL1 = NewLine(_G.ESPColor, 2),
        TL2 = NewLine(_G.ESPColor, 2),

        TR1 = NewLine(_G.ESPColor, 2),
        TR2 = NewLine(_G.ESPColor, 2),

        BL1 = NewLine(_G.ESPColor, 2),
        BL2 = NewLine(_G.ESPColor, 2),

        BR1 = NewLine(_G.ESPColor, 2),
        BR2 = NewLine(_G.ESPColor, 2)
    }
    local oripart = Instance.new("Part")
    oripart.Parent = Space
    oripart.Transparency = 1
    oripart.CanCollide = false
    oripart.Size = Vector3.new(1, 1, 1)
    oripart.Position = Vector3.new(0, 0, 0)

    local function Updater()
        local c 
        c = game:GetService("RunService").RenderStepped:Connect(function()
            if _G.ESP then
                if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("Head") ~= nil then
                    local Hum = plr.Character
                    local HumPos, vis = Camera:WorldToViewportPoint(Hum.HumanoidRootPart.Position)
                    if vis then
                        oripart.Size = Vector3.new(Hum.HumanoidRootPart.Size.X, Hum.HumanoidRootPart.Size.Y*1.5, Hum.HumanoidRootPart.Size.Z)
                        oripart.CFrame = CFrame.new(Hum.HumanoidRootPart.CFrame.Position, Camera.CFrame.Position)
                        local SizeX = oripart.Size.X
                        local SizeY = oripart.Size.Y
                        local TL = Camera:WorldToViewportPoint((oripart.CFrame * CFrame.new(SizeX, SizeY, 0)).p)
                        local TR = Camera:WorldToViewportPoint((oripart.CFrame * CFrame.new(-SizeX, SizeY, 0)).p)
                        local BL = Camera:WorldToViewportPoint((oripart.CFrame * CFrame.new(SizeX, -SizeY, 0)).p)
                        local BR = Camera:WorldToViewportPoint((oripart.CFrame * CFrame.new(-SizeX, -SizeY, 0)).p)

                        Colorize(Library, _G.ESPColor)

                        local ratio = (Camera.CFrame.p - Hum.HumanoidRootPart.Position).magnitude
                        local offset = math.clamp(1/ratio*750, 2, 300)

                        Library.TL1.From = Vector2.new(TL.X, TL.Y)
                        Library.TL1.To = Vector2.new(TL.X + offset, TL.Y)
                        Library.TL2.From = Vector2.new(TL.X, TL.Y)
                        Library.TL2.To = Vector2.new(TL.X, TL.Y + offset)

                        Library.TR1.From = Vector2.new(TR.X, TR.Y)
                        Library.TR1.To = Vector2.new(TR.X - offset, TR.Y)
                        Library.TR2.From = Vector2.new(TR.X, TR.Y)
                        Library.TR2.To = Vector2.new(TR.X, TR.Y + offset)

                        Library.BL1.From = Vector2.new(BL.X, BL.Y)
                        Library.BL1.To = Vector2.new(BL.X + offset, BL.Y)
                        Library.BL2.From = Vector2.new(BL.X, BL.Y)
                        Library.BL2.To = Vector2.new(BL.X, BL.Y - offset)

                        Library.BR1.From = Vector2.new(BR.X, BR.Y)
                        Library.BR1.To = Vector2.new(BR.X - offset, BR.Y)
                        Library.BR2.From = Vector2.new(BR.X, BR.Y)
                        Library.BR2.To = Vector2.new(BR.X, BR.Y - offset)

                        Vis(Library, true)
                    else 
                        Vis(Library, false)
                    end
                else 
                    Vis(Library, false)
                    if game:GetService("Players"):FindFirstChild(plr.Name) == nil then
                        for i, v in pairs(Library) do
                            v:Remove()
                            oripart:Destroy()
                        end
                        c:Disconnect()
                    end
                end
            else
                Vis(Library, false)
            end
        end)
    end
    coroutine.wrap(Updater)()
end

for i, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v.Name ~= Player.Name then
        coroutine.wrap(Main)(v)
    end
end

game:GetService("Players").PlayerAdded:Connect(function(newplr)
    coroutine.wrap(Main)(newplr)
end)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Library.CreateLib("Night Ware", "DarkTheme")

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

local Tab = Window:NewTab("Visuals")
local Section = Tab:NewSection("ESP")

Section:NewToggle("Enable ESP", "Toggle ESP On/Off", function(state)
    _G.ESP = state
end)

Section:NewColorPicker("Color", "Change the background color of ESP boxes", Color3.fromRGB(255, 0, 0), function(color)
    _G.ESPColor = color
end)

local Tab = Window:NewTab("Settings")
local Section = Tab:NewSection("Customize")

Section:NewKeybind("Toggle Menu", "Press to Toggle the Menu", Enum.KeyCode.F3, function()
	Library:ToggleUI()
end)

Section:NewColorPicker("Menu Background", "Change the background color of the menu", Color3.fromRGB(255, 0, 0), function(color)
    Library:ChangeColor("SchemeColor", color)
end)
