-- 1. Rensa gamla rester ur minnet
for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
    if gui.Name == "LinoriaLib" then gui:Destroy() end
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

---------------------------------------------------------
-- RIVALS BYPASS - Made by West (Inlagd vid start)
---------------------------------------------------------
pcall(function()
    local a, b, c = Players, ReplicatedStorage, CoreGui
    local d = a.LocalPlayer
    local e = {"Kick", "Ban", "AC", "AntiCheat", "Memer", "Report", "Flag"}
    
    for _, f in pairs(b:GetDescendants()) do
        if f:IsA("RemoteEvent") then
            for _, g in pairs(e) do
                if f.Name:find(g) then
                    pcall(function() f.FireServer = function() return end end)
                    print("Blocked: " .. f.Name)
                    break
                end
            end
        elseif f:IsA("RemoteFunction") then
            for _, g in pairs(e) do
                if f.Name:find(g) then
                    pcall(function() f.InvokeServer = function() return end end)
                    print("Blocked: " .. f.Name)
                    break
                end
            end
        end
    end

    if c then
        for _, f in pairs(c:GetDescendants()) do
            if f.Name and f.Name:lower():find("anticheat") then
                pcall(function() f:Destroy() end)
                print("Removed: " .. f.Name)
            end
        end
    end

    pcall(function() game.Kick = function() return end end)
    pcall(function() if d then d.Kick = function() return end end end)
    pcall(function()
        d.CharacterAdded:Connect(function()
            task.wait(0.5)
            for _, f in pairs(b:GetDescendants()) do
                if f:IsA("RemoteEvent") then
                    for _, g in pairs(e) do
                        if f.Name:find(g) then
                            pcall(function() f.FireServer = function() return end end)
                            break
                        end
                    end
                end
            end
            print("Bypass reapplied")
        end)
    end)
    print("Bypass loaded - Made by West")
end)

-- 2. Ladda LinoriaLib asynkront
local Library, ThemeManager, SaveManager
pcall(function()
    local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
    Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
    ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
    SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
end)

if not Library then
    return warn("[Menduware]: Kunde inte ladda UI-biblioteket.")
end

-- 3. Skapa fönster
local Window = Library:CreateWindow({
    Title = 'Menduware - Ultimate Edition v7 (Rivals Bypass)',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        Library:Toggle()
    end
end)

-- 4. Skapa Flikar
local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Skins = Window:AddTab('Skins'),
    Movement = Window:AddTab('Movement'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local RagebotGroup = Tabs.Combat:AddLeftGroupbox('Ragebot / Enhanced Aimbot')
local SilentAimGroup = Tabs.Combat:AddRightGroupbox('Silent Aim & FOV')
local WeaponModsGroup = Tabs.Combat:AddRightGroupbox('No Recoil & No Spread')
local AntiAimGroup = Tabs.Combat:AddRightGroupbox('Avancerad Anti-Aim & Desync')
local CombatMiscGroup = Tabs.Combat:AddRightGroupbox('Antikatana & Melee Mods')
local VisualsGroup = Tabs.Visuals:AddLeftGroupbox('Player ESP Settings')

local SkinchangerGroup = Tabs.Skins:AddLeftGroupbox('Vapen & Material Skin Changer')
local SkinColorGroup = Tabs.Skins:AddRightGroupbox('Färg & Finish Anpassning')

local MovementGroup = Tabs.Movement:AddLeftGroupbox('Movement Mods (Speed & Noclip)')
local FlyGroup = Tabs.Movement:AddRightGroupbox('Fly Inställningar')
local OrbitTeleportGroup = Tabs.Movement:AddRightGroupbox('Hyper-Advanced Orbit')
local VoidSpamGroup = Tabs.Movement:AddRightGroupbox('Ultimate Voidspam & Chaos')
local MiscGroup = Tabs.Misc:AddLeftGroupbox('Hitsounds & Hit Messages')

---------------------------------------------------------
-- LJUD & HIT MESSAGES LOGIK (DEFINIERAS FÖRST)
---------------------------------------------------------
local hitSounds = {
    ['Rust'] = "rbxassetid://313386004",
    ['Neverlose'] = "rbxassetid://6607204111",
    ['Bell'] = "rbxassetid://6534947240",
    ['Pop'] = "rbxassetid://198598717",
    ['OSU'] = "rbxassetid://4638424036"
}

local function playHitSound()
    pcall(function()
        if not (Toggles.HitSoundToggle and Toggles.HitSoundToggle.Value) then return end
        local soundName = Options.HitSoundDropdown and Options.HitSoundDropdown.Value or 'Rust'
        local soundId = hitSounds[soundName] or hitSounds['Rust']

        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = Options.HitSoundVolume and Options.HitSoundVolume.Value or 1
        sound.Parent = SoundService
        sound:Play()
        
        task.delay(3, function()
            if sound then sound:Destroy() end
        end)
    end)
end

local function sendHitMessage(victimName, damageNum)
    pcall(function()
        if not (Toggles.HitMessageToggle and Toggles.HitMessageToggle.Value) then return end
        
        local msgType = Options.HitMessageType.Value
        local text = string.format("[Menduware]: Träffade %s! (-%d HP)", victimName, damageNum or 0)

        if msgType == 'Chat' then
            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(text)
        elseif msgType == 'Notification' then
            StarterGui:SetCore("SendNotification", {
                Title = "Hit!",
                Text = text,
                Duration = 2
            })
        elseif msgType == 'Console' then
            print(text)
        end
    end)
end

---------------------------------------------------------
-- SILENT AIM & FOV LOGIK (MED INTEGRERAT HITSOUND)
---------------------------------------------------------
local utilityFound, Utility = pcall(function()
    return require(ReplicatedStorage:WaitForChild("Modules", 2):WaitForChild("Utility", 2))
end)

local OriginalRaycast = utilityFound and Utility and Utility.Raycast or nil

local SilentSettings = {
    Enabled = false,
    HitChance = 100,
    HitPart = "Head",
    WallCheck = true,
    FOVCircleEnabled = true,
    FOVRadius = 150,
    FOVColor = Color3.fromRGB(255, 255, 255),
    FOVTransparency = 0.7,
    FOVThickness = 1,
}

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = SilentSettings.FOVRadius
fovCircle.Color = SilentSettings.FOVColor
fovCircle.Transparency = SilentSettings.FOVTransparency
fovCircle.Thickness = SilentSettings.FOVThickness
fovCircle.Filled = false
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

RunService.RenderStepped:Connect(function()
    local isSilentActive = SilentSettings.Enabled and (Toggles.SilentAimToggle and Toggles.SilentAimToggle.Value)
    fovCircle.Visible = isSilentActive and SilentSettings.FOVCircleEnabled
    fovCircle.Radius = SilentSettings.FOVRadius
    fovCircle.Color = SilentSettings.FOVColor
    fovCircle.Transparency = SilentSettings.FOVTransparency
    fovCircle.Thickness = SilentSettings.FOVThickness
    fovCircle.Position = UserInputService:GetMouseLocation()
end)

local function getSilentTargetPart(player)
    local character = player.Character
    if not character then return nil end
    local part = character:FindFirstChild(SilentSettings.HitPart)
    if not part then
        part = character:FindFirstChild("Head")
    end
    return part
end

local function isPlayerAlive(player)
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

local function isVisibleForSilent(origin, targetPart, originalIgnore)
    if not SilentSettings.WallCheck then
        return true
    end
    local direction = targetPart.Position - origin
    local distance = direction.Magnitude
    if distance <= 0 then return false end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local ignoreList = {}

    local localChar = LocalPlayer.Character
    if localChar then table.insert(ignoreList, localChar) end

    local targetChar = targetPart.Parent
    if targetChar then table.insert(ignoreList, targetChar) end

    if originalIgnore then
        if type(originalIgnore) == "table" then
            for _, v in ipairs(originalIgnore) do table.insert(ignoreList, v) end
        else
            table.insert(ignoreList, originalIgnore)
        end
    end

    raycastParams.FilterDescendantsInstances = ignoreList

    local result = Workspace:Raycast(origin, direction, raycastParams)
    if not result then return true end

    local hitInstance = result.Instance
    if hitInstance == targetPart or (targetChar and hitInstance:IsDescendantOf(targetChar)) then
        return true
    end

    return false
end

local function getNearestLivingPlayerInFOV()
    local mousePos = UserInputService:GetMouseLocation()
    local closest = nil
    local shortestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isPlayerAlive(player) then
            local targetPart = getSilentTargetPart(player)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local screenVector = Vector2.new(screenPos.X, screenPos.Y)
                    local distToMouse = (screenVector - mousePos).Magnitude

                    if distToMouse <= SilentSettings.FOVRadius then
                        if distToMouse < shortestDist then
                            shortestDist = distToMouse
                            closest = player
                        end
                    end
                end
            end
        end
    end
    return closest
end

if Utility and OriginalRaycast then
    Utility.Raycast = function(self, from, to, range, ignore, mode, debug)
        local isSilentActive = SilentSettings.Enabled and (Toggles.SilentAimToggle and Toggles.SilentAimToggle.Value)
        if not isSilentActive then
            return OriginalRaycast(self, from, to, range, ignore, mode, debug)
        end

        if math.random(1, 100) > SilentSettings.HitChance then
            return OriginalRaycast(self, from, to, range, ignore, mode, debug)
        end

        local target = getNearestLivingPlayerInFOV()
        if not target then
            return OriginalRaycast(self, from, to, range, ignore, mode, debug)
        end

        local hitPart = getSilentTargetPart(target)
        if not hitPart then
            return OriginalRaycast(self, from, to, range, ignore, mode, debug)
        end

        if not isVisibleForSilent(from, hitPart, ignore) then
            return OriginalRaycast(self, from, to, range, ignore, mode, debug)
        end

        playHitSound()
        sendHitMessage(target.Name, 25)

        local hitPosition = hitPart.Position
        local direction = (hitPosition - from).Unit
        local distance = (hitPosition - from).Magnitude

        if distance > range then
            distance = range
            hitPosition = from + direction * range
        end

        return {
            Position = hitPosition,
            Distance = distance,
            Instance = hitPart,
            Material = hitPart.Material,
            Normal = -direction,
        }
    end
end

---------------------------------------------------------
-- NO RECOIL & NO SPREAD LOGIK
---------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local noRecoilActive = Toggles.NoRecoilToggle and Toggles.NoRecoilToggle.Value
    local noSpreadActive = Toggles.NoSpreadToggle and Toggles.NoSpreadToggle.Value

    if not (noRecoilActive or noSpreadActive) then return end

    local char = LocalPlayer.Character
    if not char then return end

    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            pcall(function()
                if noRecoilActive then
                    if item:GetAttribute("Recoil") then item:SetAttribute("Recoil", 0) end
                    if item:GetAttribute("CameraShake") then item:SetAttribute("CameraShake", 0) end
                end
                if noSpreadActive then
                    if item:GetAttribute("Spread") then item:SetAttribute("Spread", 0) end
                    if item:GetAttribute("Inaccuracy") then item:SetAttribute("Inaccuracy", 0) end
                end
            end)
        end
    end
end)

---------------------------------------------------------
-- SKIN CHANGER LOGIK
---------------------------------------------------------
local function applySkinChanger()
    if not (Toggles.SkinChangerToggle and Toggles.SkinChangerToggle.Value) then return end
    local char = LocalPlayer.Character
    if not char then return end

    local containers = {char, LocalPlayer:FindFirstChild("Backpack")}
    local materialChoice = Options.SkinMaterialDropdown.Value
    local chosenColor = Options.SkinColorPicker.Value
    local chosenReflectance = Options.SkinReflectance.Value
    local useTexture = Toggles.SkinTextureToggle and Toggles.SkinTextureToggle.Value
    local textureId = Options.SkinTextureInput.Value

    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    for _, part in ipairs(item:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if materialChoice == 'Neon' then
                                part.Material = Enum.Material.Neon
                            elseif materialChoice == 'Glass' then
                                part.Material = Enum.Material.Glass
                            elseif materialChoice == 'SmoothPlastic' then
                                part.Material = Enum.Material.SmoothPlastic
                            elseif materialChoice == 'Metal' then
                                part.Material = Enum.Material.Metal
                            elseif materialChoice == 'Wood' then
                                part.Material = Enum.Material.Wood
                            elseif materialChoice == 'ForceField' then
                                part.Material = Enum.Material.ForceField
                            elseif materialChoice == 'CorrodedMetal' then
                                part.Material = Enum.Material.CorrodedMetal
                            end

                            part.Color = chosenColor
                            part.Reflectance = chosenReflectance

                            if useTexture and textureId ~= "" then
                                local existingDecal = part:FindFirstChild("MenduwareSkinDecal")
                                if not existingDecal then
                                    local decal = Instance.new("Decal")
                                    decal.Name = "MenduwareSkinDecal"
                                    decal.Texture = "rbxassetid://" .. tostring(textureId)
                                    decal.Face = Enum.NormalId.Front
                                    decal.Parent = part
                                end
                            else
                                local existingDecal = part:FindFirstChild("MenduwareSkinDecal")
                                if existingDecal then existingDecal:Destroy() end
                            end
                        end
                    end
                end
            end
        end
    end
end

---------------------------------------------------------
-- MÅLSÖKNING & RAGEBOT
---------------------------------------------------------
local function getBestTarget()
    local bestTargetPart = nil
    local shortestDist = math.huge
    local targetPartName = Options.RageTarget and Options.RageTarget.Value or "Head"

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = player.Character:FindFirstChild(targetPartName)

            if humanoid and humanoid.Health > 0 and targetPart then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                    local dist = (targetPart.Position - myPos).Magnitude
                    
                    if dist < shortestDist then
                        shortestDist = dist
                        
                        local predictedPosition = targetPart.Position
                        if Toggles.RagePrediction and Toggles.RagePrediction.Value then
                            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                            if rootPart then
                                local pingFactor = 0.05
                                predictedPosition = predictedPosition + (rootPart.AssemblyLinearVelocity * pingFactor)
                            end
                        end

                        bestTargetPart = {
                            Part = targetPart,
                            Position = predictedPosition
                        }
                    end
                end
            end
        end
    end
    return bestTargetPart
end

local function getClosestTargetPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
        return nil
    end

    local myPos = LocalPlayer.Character.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

---------------------------------------------------------
-- ANTIKATANA LOGIK
---------------------------------------------------------
local function antiKatanaStep()
    if not (Toggles.AntiKatanaToggle and Toggles.AntiKatanaToggle.Value) then return end
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local triggerDist = Options.AntiKatanaDist and Options.AntiKatanaDist.Value or 12

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool and (string.find(string.lower(tool.Name), "katana") or string.find(string.lower(tool.Name), "sword") or string.find(string.lower(tool.Name), "blade")) then
                    local dist = (rootPart.Position - enemyRoot.Position).Magnitude
                    if dist <= triggerDist then
                        local escapeDir = (rootPart.Position - enemyRoot.Position).Unit
                        rootPart.CFrame = rootPart.CFrame + (escapeDir * 8) + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
    end
end

---------------------------------------------------------
-- ORBIT & VOIDSPAM LOGIK
---------------------------------------------------------
local function getPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    if #list == 0 then
        table.insert(list, "Inga spelare")
    end
    return list
end

local orbitAngle = 0
local voidTickAccumulator = 0
local spiralTimer = 0

local function orbitTargetStep(deltaTime)
    if not (Toggles.OrbitToggle and Toggles.OrbitToggle.Value) then return end
    local targetName = Options.OrbitTpPlayerDropdown.Value
    local targetPlayer = Players:FindFirstChild(targetName)
    if not targetPlayer then return end

    local char = LocalPlayer.Character
    local targetChar = targetPlayer.Character

    if char and targetChar then
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")

        if rootPart and targetRoot then
            local speed = Options.OrbitSpeed and Options.OrbitSpeed.Value or 90
            orbitAngle = (orbitAngle + speed * deltaTime) % 360

            local targetPos = targetRoot.Position
            local angleRad = math.rad(orbitAngle)
            local baseRadius = Options.OrbitTpRadius.Value
            local baseHeight = Options.OrbitTpHeight.Value
            local mode = Options.OrbitMode.Value

            local finalPos = Vector3.zero

            if mode == 'Standard Cirkel' then
                local offsetX = math.cos(angleRad) * baseRadius
                local offsetZ = math.sin(angleRad) * baseRadius
                finalPos = Vector3.new(targetPos.X + offsetX, targetPos.Y + baseHeight, targetPos.Z + offsetZ)

            elseif mode == 'Elliptisk (Oval)' then
                local stretchX = Options.OrbitEllipticX.Value
                local stretchZ = Options.OrbitEllipticZ.Value
                local offsetX = math.cos(angleRad) * (baseRadius * stretchX)
                local offsetZ = math.sin(angleRad) * (baseRadius * stretchZ)
                finalPos = Vector3.new(targetPos.X + offsetX, targetPos.Y + baseHeight, targetPos.Z + offsetZ)

            elseif mode == 'Vertikal / Vågrät Looping' then
                spiralTimer = spiralTimer + deltaTime * (speed / 30)
                local vHeight = math.sin(spiralTimer) * (baseHeight + 10)
                local offsetX = math.cos(angleRad) * baseRadius
                local offsetZ = math.sin(angleRad) * baseRadius
                finalPos = Vector3.new(targetPos.X + offsetX, targetPos.Y + vHeight, targetPos.Z + offsetZ)

            elseif mode == 'Helix / Spiral Uppåt' then
                spiralTimer = (spiralTimer + deltaTime * 2) % 15
                local currentH = baseHeight + (spiralTimer * 3) - 7
                local offsetX = math.cos(angleRad) * baseRadius
                local offsetZ = math.sin(angleRad) * baseRadius
                finalPos = Vector3.new(targetPos.X + offsetX, targetPos.Y + currentH, targetPos.Z + offsetZ)

            elseif mode == 'Kaotisk / Oförutsägbar' then
                local randOffset = Vector3.new(math.random(-5, 5), math.random(-2, 5), math.random(-5, 5))
                local offsetX = math.cos(angleRad) * baseRadius
                local offsetZ = math.sin(angleRad) * baseRadius
                finalPos = Vector3.new(targetPos.X + offsetX, targetPos.Y + baseHeight, targetPos.Z + offsetZ) + randOffset
            end

            if Toggles.OrbitLookAtTarget and Toggles.OrbitLookAtTarget.Value then
                rootPart.CFrame = CFrame.new(finalPos, targetPos)
            else
                rootPart.CFrame = CFrame.new(finalPos) * rootPart.CFrame.Rotation
            end
        end
    end
end

local function voidSpamStep(deltaTime)
    if not (Toggles.VoidSpamToggle and Toggles.VoidSpamToggle.Value) then return end
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local speedVal = Options.VoidSpamSpeed and Options.VoidSpamSpeed.Value or 35
    voidTickAccumulator = voidTickAccumulator + deltaTime
    if voidTickAccumulator < (1 / speedVal) then return end
    voidTickAccumulator = 0

    local mode = Options.VoidSpamMode and Options.VoidSpamMode.Value or 'Full 3D Chaos (Explosiv)'
    local xRange = Options.VoidSpamX and Options.VoidSpamX.Value or 20
    local yRange = Options.VoidSpamY and Options.VoidSpamY.Value or 20
    local zRange = Options.VoidSpamZ and Options.VoidSpamZ.Value or 20
    local offset = Vector3.zero

    if mode == 'Full 3D Chaos (Explosiv)' then
        offset = Vector3.new(math.random(-xRange, xRange), math.random(-yRange, yRange), math.random(-zRange, zRange))
    elseif mode == 'Sfärisk / Kulan' then
        local phi = math.random() * math.pi * 2
        local costheta = math.random() * 2 - 1
        local theta = math.acos(costheta)
        local r = math.random() * xRange
        offset = Vector3.new(r * math.sin(theta) * math.cos(phi), r * math.sin(theta) * math.sin(phi), r * math.cos(theta))
    elseif mode == 'Endast Höjd (Y-Axis Glitch)' then
        offset = Vector3.new(0, math.random(-yRange, yRange), 0)
    elseif mode == 'Horisontell Hyper-Jitter' then
        offset = Vector3.new(math.random(-xRange, xRange), 0, math.random(-zRange, zRange))
    elseif mode == 'Mikro-Darrning (Stealth Shake)' then
        offset = Vector3.new(math.random(-4, 4), math.random(-2, 2), math.random(-4, 4))
    elseif mode == 'Cylindrisk Pisk-snurr' then
        local angle = math.random() * math.pi * 2
        local r = math.random() * xRange
        offset = Vector3.new(math.cos(angle) * r, math.random(-yRange, yRange), math.sin(angle) * r)
    end

    if Toggles.VoidSpamAnchor and Toggles.VoidSpamAnchor.Value then
        if not _G.VoidOriginalPos then
            _G.VoidOriginalPos = rootPart.Position
        end
        rootPart.CFrame = CFrame.new(_G.VoidOriginalPos + offset)
    else
        _G.VoidOriginalPos = nil
        rootPart.CFrame = rootPart.CFrame + offset
    end
end

---------------------------------------------------------
-- ANTI-AIM & DESYNC LOGIK
---------------------------------------------------------
local spinAngle = 0
local jitterToggle = false
local desyncTick = 0

RunService.Heartbeat:Connect(function(deltaTime)
    orbitTargetStep(deltaTime)
    voidSpamStep(deltaTime)
    antiKatanaStep()
    applySkinChanger()

    if Toggles.AntiAimToggle and Toggles.AntiAimToggle.Value then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myRoot = LocalPlayer.Character.HumanoidRootPart
            local mode = Options.AntiAimMode.Value
            local speed = Options.AntiAimSpeed.Value

            if mode == 'Spinbot' then
                spinAngle = spinAngle + math.rad(speed * 2)
                myRoot.CFrame = CFrame.new(myRoot.Position) * CFrame.Angles(0, spinAngle, 0)
            elseif mode == 'Jitter' then
                jitterToggle = not jitterToggle
                local angle = jitterToggle and math.rad(speed) or math.rad(-speed)
                myRoot.CFrame = CFrame.new(myRoot.Position) * CFrame.Angles(0, myRoot.Orientation.Y + angle, 0)
            elseif mode == 'Desync' then
                desyncTick = desyncTick + 1
                local fakeOffset = (desyncTick % 2 == 0) and math.rad(90) or math.rad(-90)
                myRoot.CFrame = CFrame.new(myRoot.Position) * CFrame.Angles(0, Camera.CFrame.Rotation.Y.Y + fakeOffset, 0)
            elseif mode == 'Backward' then
                local camLook = Camera.CFrame.LookVector
                local backVector = Vector3.new(-camLook.X, 0, -camLook.Z)
                myRoot.CFrame = CFrame.new(myRoot.Position, myRoot.Position + backVector)
            elseif mode == 'Freestand' then
                local target = getClosestTargetPlayer()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = target.Character.HumanoidRootPart.Position
                    local lookAtTarget = CFrame.new(myRoot.Position, Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z))
                    local randomJitter = math.rad(math.random(-180, 180))
                    myRoot.CFrame = lookAtTarget * CFrame.Angles(0, randomJitter, 0)
                end
            end
        end
    end
end)

---------------------------------------------------------
-- ESP LOGIK
---------------------------------------------------------
local function removeESP(char)
    if not char then return end
    pcall(function()
        if char:FindFirstChild("StandardESP_Highlight") then char.StandardESP_Highlight:Destroy() end
        if char:FindFirstChild("StandardESP_Name") then char.StandardESP_Name:Destroy() end
    end)
end

local function applyESP(player)
    if player == LocalPlayer then return end

    local function setupCharacter(char)
        if not char then return end
        removeESP(char)
        if not (Toggles.ESPToggle and Toggles.ESPToggle.Value) then return end

        pcall(function()
            if Toggles.ESPBoxes.Value then
                local highlight = Instance.new("Highlight")
                highlight.Name = "StandardESP_Highlight"
                highlight.FillColor = Options.ESPFillColor.Value
                highlight.FillTransparency = Options.ESPFillTrans.Value / 100
                highlight.OutlineColor = Options.ESPOutlineColor.Value
                highlight.OutlineTransparency = Options.ESPOutlineTrans.Value / 100
                highlight.Adornee = char
                highlight.Parent = char
            end

            if Toggles.ESPNames.Value then
                local head = char:FindFirstChild("Head")
                if head then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "StandardESP_Name"
                    billboard.Adornee = head
                    billboard.Size = UDim2.new(0, 100, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = player.Name
                    label.TextColor3 = Options.ESPTextColor.Value
                    label.TextStrokeTransparency = 0
                    label.TextSize = 14
                    label.Font = Enum.Font.SourceSansBold
                    label.Parent = billboard

                    billboard.Parent = char
                end
            end
        end)
    end

    if player.Character then setupCharacter(player.Character) end
    player.CharacterAdded:Connect(setupCharacter)
end

local function updateAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if Toggles.ESPToggle and Toggles.ESPToggle.Value then
                applyESP(plr)
            else
                removeESP(plr.Character)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if Toggles.ESPToggle and Toggles.ESPToggle.Value then
        applyESP(plr)
    end
end)

---------------------------------------------------------
-- HUVUDLOOP (FLY, MOVEMENT, AIMBOT / RAGEBOT)
---------------------------------------------------------
local lastTriggerTick = 0
local lastTargetHealth = {}

RunService.RenderStepped:Connect(function(deltaTime)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = LocalPlayer.Character.HumanoidRootPart
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

        if humanoid and Camera.CameraSubject ~= humanoid then
            Camera.CameraSubject = humanoid
            Camera.CameraType = Enum.CameraType.Custom
        end

        if Toggles.NoclipToggle and Toggles.NoclipToggle.Value then
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end

        if humanoid then
            if Toggles.SpeedToggle and Toggles.SpeedToggle.Value then
                humanoid.WalkSpeed = Options.WalkSpeedValue.Value
            else
                humanoid.WalkSpeed = 16
            end
        end

        local isFlyActive = Toggles.FlyToggle and Toggles.FlyToggle.Value
        if isFlyActive then
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero

            local flySpeed = Options.FlySpeed.Value
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
            myRoot.CFrame = myRoot.CFrame + (moveDir * flySpeed * deltaTime)
        end
    end

    -- Befintlig Ragebot / Enhanced Aimbot Logik
    if Toggles.RagebotToggle and Toggles.RagebotToggle.Value then
        pcall(function()
            local targetData = getBestTarget()
            if targetData then
                local targetPart = targetData.Part
                local targetPosition = targetData.Position
                local targetCharacter = targetPart.Parent
                local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)

                if humanoid and targetPlayer then
                    local currentHealth = humanoid.Health
                    local lastHealth = lastTargetHealth[targetPlayer] or currentHealth

                    if currentHealth < lastHealth then
                        local damage = math.abs(currentHealth - lastHealth)
                        playHitSound()
                        sendHitMessage(targetPlayer.Name, damage)
                    end
                    lastTargetHealth[targetPlayer] = currentHealth
                end

                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
                local smoothness = Options.RageSmooth and Options.RageSmooth.Value or 1
                
                if smoothness <= 1 then
                    Camera.CFrame = targetCFrame
                else
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, math.clamp(deltaTime * smoothness, 0, 1))
                end

                if Toggles.RageTriggerToggle and Toggles.RageTriggerToggle.Value then
                    local currentTime = tick()
                    if currentTime - lastTriggerTick > 0.03 then 
                        lastTriggerTick = currentTime
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            end
        end)
    end
end)

---------------------------------------------------------
-- UI ELEMENT (MENYN)
---------------------------------------------------------
RagebotGroup:AddToggle('RagebotToggle', { Text = 'Aktivera Enhanced Aimbot (Alltid På)', Default = false })
RagebotGroup:AddToggle('RageTriggerToggle', { Text = 'Aktivera Inbyggd Triggerbot', Default = false })
RagebotGroup:AddToggle('RagePrediction', { Text = 'Aktivera Hastighets-Prediktion', Default = true })
RagebotGroup:AddDropdown('RageTarget', { Values = { 'Head', 'HumanoidRootPart' }, Default = 1, Multi = false, Text = 'Sikta På' })
RagebotGroup:AddSlider('RageSmooth', { Text = 'Sikte Mjukhet (1 = Direkt Snap)', Default = 1, Min = 1, Max = 20, Rounding = 1 })

SilentAimGroup:AddToggle('SilentAimToggle', { Text = 'Aktivera Silent Aim', Default = false, Callback = function(v) SilentSettings.Enabled = v end })
SilentAimGroup:AddToggle('SilentWallCheck', { Text = 'Silent Wall Check', Default = true, Callback = function(v) SilentSettings.WallCheck = v end })
SilentAimGroup:AddSlider('SilentHitChance', { Text = 'Hit Chance %', Default = 100, Min = 1, Max = 100, Rounding = 0, Callback = function(v) SilentSettings.HitChance = v end })
SilentAimGroup:AddDropdown('SilentHitPart', { Values = { 'Head', 'HumanoidRootPart' }, Default = 1, Multi = false, Text = 'Silent Hit Part', Callback = function(v) SilentSettings.HitPart = v end })
SilentAimGroup:AddToggle('FOVCircleEnabled', { Text = 'Visa FOV-cirkel', Default = true, Callback = function(v) SilentSettings.FOVCircleEnabled = v end })
SilentAimGroup:AddSlider('FOVRadius', { Text = 'FOV Radie', Default = 150, Min = 20, Max = 600, Rounding = 0, Callback = function(v) SilentSettings.FOVRadius = v end })
SilentAimGroup:AddLabel('FOV Cirkel Färg'):AddColorPicker('FOVColorPicker', { Default = Color3.fromRGB(255, 255, 255), Title = 'Välj FOV Färg', Callback = function(v) SilentSettings.FOVColor = v end })

WeaponModsGroup:AddToggle('NoRecoilToggle', { Text = 'Aktivera No Recoil', Default = false })
WeaponModsGroup:AddToggle('NoSpreadToggle', { Text = 'Aktivera No Spread', Default = false })

AntiAimGroup:AddToggle('AntiAimToggle', { Text = 'Aktivera Avancerad Anti-Aim', Default = false })
AntiAimGroup:AddDropdown('AntiAimMode', { Values = { 'Spinbot', 'Jitter', 'Desync', 'Backward', 'Freestand' }, Default = 3, Multi = false, Text = 'Anti-Aim Läge' })
AntiAimGroup:AddSlider('AntiAimSpeed', { Text = 'Snurr / Skak-Hastighet', Default = 50, Min = 10, Max = 150, Rounding = 0 })

CombatMiscGroup:AddToggle('AntiKatanaToggle', { Text = 'Aktivera Antikatana (Auto-Dodge)', Default = false })
CombatMiscGroup:AddSlider('AntiKatanaDist', { Text = 'Reaktionsavstånd (Studs)', Default = 12, Min = 5, Max = 30, Rounding = 0 })

VisualsGroup:AddToggle('ESPToggle', { Text = 'Aktivera Master ESP', Default = false, Callback = function() updateAllESP() end })
VisualsGroup:AddToggle('ESPBoxes', { Text = 'Visa Boxes / Highlight', Default = true, Callback = function() updateAllESP() end })
VisualsGroup:AddToggle('ESPNames', { Text = 'Visa Spelarnamn', Default = true, Callback = function() updateAllESP() end })
VisualsGroup:AddLabel('Fyllningsfärg (Box)'):AddColorPicker('ESPFillColor', { Default = Color3.fromRGB(255, 0, 0), Title = 'Välj Fyllningsfärg', Callback = function() updateAllESP() end })
VisualsGroup:AddSlider('ESPFillTrans', { Text = 'Fyllning Genomskinlighet %', Default = 50, Min = 0, Max = 100, Rounding = 0, Callback = function() updateAllESP() end })
VisualsGroup:AddLabel('Ramfärg (Outline)'):AddColorPicker('ESPOutlineColor', { Default = Color3.fromRGB(255, 255, 255), Title = 'Välj Ramfärg', Callback = function() updateAllESP() end })
VisualsGroup:AddSlider('ESPOutlineTrans', { Text = 'Ram Genomskinlighet %', Default = 0, Min = 0, Max = 100, Rounding = 0, Callback = function() updateAllESP() end })
VisualsGroup:AddLabel('Namnfärg'):AddColorPicker('ESPTextColor', { Default = Color3.fromRGB(255, 255, 255), Title = 'Välj Namnfärg', Callback = function() updateAllESP() end })

SkinchangerGroup:AddToggle('SkinChangerToggle', { Text = 'Aktivera Vapen Skin Changer', Default = false })
SkinchangerGroup:AddDropdown('SkinMaterialDropdown', { Values = { 'Neon', 'Glass', 'SmoothPlastic', 'Metal', 'Wood', 'ForceField', 'CorrodedMetal' }, Default = 1, Multi = false, Text = 'Vapen Material' })
SkinchangerGroup:AddToggle('SkinTextureToggle', { Text = 'Använd Custom Textur ID', Default = false })
SkinchangerGroup:AddInput('SkinTextureInput', { Default = '', Numeric = false, Finished = true, Text = 'Decal Asset ID (Siffror)', Placeholder = 'T.ex. 60795324' })

SkinColorGroup:AddLabel('Vapen Färg'):AddColorPicker('SkinColorPicker', { Default = Color3.fromRGB(0, 255, 255), Title = 'Välj Skin Färg' })
SkinColorGroup:AddSlider('SkinReflectance', { Text = 'Glans / Reflektion', Default = 0, Min = 0, Max = 1, Rounding = 2 })

MovementGroup:AddToggle('NoclipToggle', { Text = 'Aktivera Noclip', Default = false })
MovementGroup:AddToggle('SpeedToggle', { Text = 'Aktivera Speedhack', Default = false })
MovementGroup:AddSlider('WalkSpeedValue', { Text = 'Springhastighet (Speed)', Default = 32, Min = 16, Max = 250, Rounding = 0 })

FlyGroup:AddToggle('FlyToggle', { Text = 'Aktivera Fly', Default = false })
FlyGroup:AddSlider('FlySpeed', { Text = 'Flyghastighet', Default = 50, Min = 10, Max = 200, Rounding = 0 })

OrbitTeleportGroup:AddToggle('OrbitToggle', { Text = 'Aktivera Hyper-Orbit', Default = false })
OrbitTeleportGroup:AddDropdown('OrbitTpPlayerDropdown', { Values = getPlayerList(), Default = 1, Multi = false, Text = 'Välj Målspelare' })
OrbitTeleportGroup:AddDropdown('OrbitMode', { Values = { 'Standard Cirkel', 'Elliptisk (Oval)', 'Vertikal / Vågrät Looping', 'Helix / Spiral Uppåt', 'Kaotisk / Oförutsägbar' }, Default = 1, Multi = false, Text = 'Orbit Mönster' })
OrbitTeleportGroup:AddToggle('OrbitLookAtTarget', { Text = 'Fixera Kamera/Blick mot Målet', Default = true })
OrbitTeleportGroup:AddSlider('OrbitTpRadius', { Text = 'Orbit Radie / Avstånd', Default = 10, Min = 1, Max = 100, Rounding = 0 })
OrbitTeleportGroup:AddSlider('OrbitEllipticX', { Text = 'Ellips X-Sträckning (Bredd)', Default = 1, Min = 0.2, Max = 4, Rounding = 1 })
OrbitEllipticZ = OrbitTeleportGroup:AddSlider('OrbitEllipticZ', { Text = 'Ellips Z-Sträckning (Djup)', Default = 1, Min = 0.2, Max = 4, Rounding = 1 })
OrbitTeleportGroup:AddSlider('OrbitTpHeight', { Text = 'Orbit Höjd (Offset)', Default = 0, Min = -30, Max = 50, Rounding = 0 })
OrbitTeleportGroup:AddSlider('OrbitSpeed', { Text = 'Orbit Hastighet (Varv/s)', Default = 90, Min = 10, Max = 500, Rounding = 0 })
OrbitTeleportGroup:AddButton('Uppdatera spelarlista', function()
    Options.OrbitTpPlayerDropdown:SetValues(getPlayerList())
end)

VoidSpamGroup:AddToggle('VoidSpamToggle', { Text = 'Aktivera Ultimate Voidspam', Default = false })
VoidSpamGroup:AddToggle('VoidSpamAnchor', { Text = 'Lås Centrumposition (Boosta på plats)', Default = false })
VoidSpamGroup:AddDropdown('VoidSpamMode', { Values = { 'Full 3D Chaos (Explosiv)', 'Sfärisk / Kulan', 'Endast Höjd (Y-Axis Glitch)', 'Horisontell Hyper-Jitter', 'Mikro-Darrning (Stealth Shake)', 'Cylindrisk Pisk-snurr' }, Default = 1, Multi = false, Text = 'Voidspam / Chaos Läge' })
VoidSpamGroup:AddSlider('VoidSpamSpeed', { Text = 'Spam-Frekvens (Tills/Sek)', Default = 35, Min = 5, Max = 120, Rounding = 0 })
VoidSpamGroup:AddSlider('VoidSpamX', { Text = 'X-Axel Spridning', Default = 20, Min = 1, Max = 150, Rounding = 0 })
VoidSpeedY = VoidSpamGroup:AddSlider('VoidSpamY', { Text = 'Y-Axel (Höjd) Spridning', Default = 20, Min = 1, Max = 150, Rounding = 0 })
VoidSpamGroup:AddSlider('VoidSpamZ', { Text = 'Z-Axel Spridning', Default = 20, Min = 1, Max = 150, Rounding = 0 })

MiscGroup:AddToggle('HitSoundToggle', { Text = 'Aktivera Hit Sound', Default = true })
MiscGroup:AddDropdown('HitSoundDropdown', { Values = { 'Rust', 'Neverlose', 'Bell', 'Pop', 'OSU' }, Default = 1, Multi = false, Text = 'Välj Hit Sound' })
MiscGroup:AddSlider('HitSoundVolume', { Text = 'Volym', Default = 1, Min = 0.1, Max = 2, Rounding = 1 })

MiscGroup:AddToggle('HitMessageToggle', { Text = 'Aktivera Hit Messages', Default = true })
MiscGroup:AddDropdown('HitMessageType', { Values = { 'Notification', 'Console', 'Chat' }, Default = 1, Multi = false, Text = 'Meddelandetyp' })

---------------------------------------------------------
-- CONFIG & THEME MANAGER SETUP
---------------------------------------------------------
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

ThemeManager:SetFolder('Menduware')
SaveManager:SetFolder('Menduware/configs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()
