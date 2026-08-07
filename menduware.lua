-- 1. Rensa gamla rester ur minnet
for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
    if gui.Name == "ObsidianLib" or gui.Name == "LinoriaLib" then gui:Destroy() end
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

---------------------------------------------------------
-- RIVALS BYPASS - Made by West
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
                    break
                end
            end
        elseif f:IsA("RemoteFunction") then
            for _, g in pairs(e) do
                if f.Name:find(g) then
                    pcall(function() f.InvokeServer = function() return end end)
                    break
                end
            end
        end
    end

    if c then
        for _, f in pairs(c:GetDescendants()) do
            if f.Name and f.Name:lower():find("anticheat") then
                pcall(function() f:Destroy() end)
            end
        end
    end

    pcall(function() game.Kick = function() return end end)
    pcall(function() if d then d.Kick = function() return end end end)
end)

-- 2. Ladda Obsidian Library
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

-- 3. Skapa fönster med Obsidian Tema
local Window = Library:CreateWindow({
    Title = 'Menduware - Obsidian Edition (Advanced Rage & Combat)',
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

local RagebotGroup = Tabs.Combat:AddLeftGroupbox('Ragebot & Advanced Combat Modes')
local RageExtrasGroup = Tabs.Combat:AddLeftGroupbox('Ragebot Targeting & Spells')
local SilentAimGroup = Tabs.Combat:AddRightGroupbox('Silent Aim & FOV')
local WeaponModsGroup = Tabs.Combat:AddRightGroupbox('No Recoil & No Spread')
local AntiAimGroup = Tabs.Combat:AddRightGroupbox('Avancerad Anti-Aim & Desync')
local CombatMiscGroup = Tabs.Combat:AddRightGroupbox('Antikatana & Melee Mods')

-- ESP Grupper
local VisualsGeneralGroup = Tabs.Visuals:AddLeftGroupbox('ESP Allmänt & Inställningar')
local VisualsBoxesGroup = Tabs.Visuals:AddLeftGroupbox('Box ESP & Outlines')
local VisualsBarsGroup = Tabs.Visuals:AddRightGroupbox('Hälsobar & Extra Info')
local VisualsExtrasGroup = Tabs.Visuals:AddRightGroupbox('Tracers, Skelett & Siktlinjer')

local SkinchangerGroup = Tabs.Skins:AddLeftGroupbox('Vapen & Material Skin Changer')
local SkinColorGroup = Tabs.Skins:AddRightGroupbox('Färg & Finish Anpassning')

local MovementGroup = Tabs.Movement:AddLeftGroupbox('Movement Mods (Speed & Noclip)')
local FlyGroup = Tabs.Movement:AddRightGroupbox('Fly Inställningar')
local OrbitTeleportGroup = Tabs.Movement:AddRightGroupbox('Hyper-Advanced Orbit')
local VoidSpamGroup = Tabs.Movement:AddRightGroupbox('Ultimate Voidspam & Chaos')
local MiscGroup = Tabs.Misc:AddLeftGroupbox('Hitsounds & Hit Messages')

---------------------------------------------------------
-- LJUD & HIT MESSAGES LOGIK
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
-- SILENT AIM & FOV LOGIK
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
    if not SilentSettings.WallCheck then return true end
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

                    if distToMouse <= SilentSettings.FOVRadius and distToMouse < shortestDist then
                        shortestDist = distToMouse
                        closest = player
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
        if not hitPart or not isVisibleForSilent(from, hitPart, ignore) then
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
                            pcall(function()
                                part.Material = Enum.Material[materialChoice] or Enum.Material.Neon
                            end)
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
-- AVANCERAD RAGEBOT (MED ORBIT, VOIDSPAM & TELEPORT MODES)
---------------------------------------------------------
local function getClosestPlayerForRage()
    local closestPlayer = nil
    local shortestDist = math.huge
    if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then return nil end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isPlayerAlive(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

local rageOrbitAngle = 0
local function ragebotModesStep(deltaTime)
    if not (Toggles.RagebotToggle and Toggles.RagebotToggle.Value) then return end
    local mode = Options.RageModeDropdown.Value
    local targetPlayer = getClosestPlayerForRage()
    if not targetPlayer or not targetPlayer.Character then return end

    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart or not targetRoot then return end

    if mode == 'Rage Snap / Lock' then
        -- Snäpper kameran direkt mot målet
        local targetPos = targetRoot.Position
        if Toggles.RagePrediction and Toggles.RagePrediction.Value then
            targetPos = targetPos + (targetRoot.AssemblyLinearVelocity * 0.04)
        end
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)

    elseif mode == 'Rage Orbit Target' then
        -- Cirkulerar automatiskt runt närmaste fiende i Ragebot
        local speed = Options.RageOrbitSpeed.Value or 120
        rageOrbitAngle = (rageOrbitAngle + speed * deltaTime) % 360
        local radAngle = math.rad(rageOrbitAngle)
        local radius = Options.RageOrbitRadius.Value or 12
        local height = Options.RageOrbitHeight.Value or 2

        local tPos = targetRoot.Position
        local newPos = Vector3.new(tPos.X + math.cos(radAngle) * radius, tPos.Y + height, tPos.Z + math.sin(radAngle) * radius)
        rootPart.CFrame = CFrame.new(newPos, tPos)

    elseif mode == 'Rage Teleport Behind' then
        -- Teleporterar automatiskt direkt bakom fienden
        local behindOffset = targetRoot.CFrame.LookVector * -5 + Vector3.new(0, 1, 0)
        rootPart.CFrame = CFrame.new(targetRoot.Position + behindOffset, targetRoot.Position)

    elseif mode == 'Rage Voidspam Chaos' then
        -- Skapar intensivt kaos och teleport-glitch runt fiendens position
        local rx = math.random(-15, 15)
        local ry = math.random(0, 10)
        local rz = math.random(-15, 15)
        rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(rx, ry, rz), targetRoot.Position)
    end
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
                if tool and (string.find(string.lower(tool.Name), "katana") or string.find(string.lower(tool.Name), "sword")) then
                    if (rootPart.Position - enemyRoot.Position).Magnitude <= triggerDist then
                        local escapeDir = (rootPart.Position - enemyRoot.Position).Unit
                        rootPart.CFrame = rootPart.CFrame + (escapeDir * 8) + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
    end
end

---------------------------------------------------------
-- ORBIT & VOIDSPAM LOGIK (FRISTÅENDE)
---------------------------------------------------------
local function getPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then table.insert(list, player.Name) end
    end
    if #list == 0 then table.insert(list, "Inga spelare") end
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
                finalPos = Vector3.new(targetPos.X + math.cos(angleRad) * baseRadius, targetPos.Y + baseHeight, targetPos.Z + math.sin(angleRad) * baseRadius)
            elseif mode == 'Elliptisk (Oval)' then
                finalPos = Vector3.new(targetPos.X + math.cos(angleRad) * (baseRadius * Options.OrbitEllipticX.Value), targetPos.Y + baseHeight, targetPos.Z + math.sin(angleRad) * (baseRadius * Options.OrbitEllipticZ.Value))
            elseif mode == 'Helix / Spiral Uppåt' then
                spiralTimer = (spiralTimer + deltaTime * 2) % 15
                finalPos = Vector3.new(targetPos.X + math.cos(angleRad) * baseRadius, targetPos.Y + baseHeight + (spiralTimer * 3) - 7, targetPos.Z + math.sin(angleRad) * baseRadius)
            else
                finalPos = Vector3.new(targetPos.X + math.cos(angleRad) * baseRadius, targetPos.Y + baseHeight, targetPos.Z + math.sin(angleRad) * baseRadius)
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

    local xRange = Options.VoidSpamX.Value
    local yRange = Options.VoidSpamY.Value
    local zRange = Options.VoidSpamZ.Value
    local offset = Vector3.new(math.random(-xRange, xRange), math.random(-yRange, yRange), math.random(-zRange, zRange))

    if Toggles.VoidSpamAnchor and Toggles.VoidSpamAnchor.Value then
        if not _G.VoidOriginalPos then _G.VoidOriginalPos = rootPart.Position end
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
    ragebotModesStep(deltaTime)
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
                myRoot.CFrame = CFrame.new(myRoot.Position) * CFrame.Angles(0, Camera.CFrame.Rotation.Y.Y + ((desyncTick % 2 == 0) and math.rad(90) or math.rad(-90)), 0)
            end
        end
    end
end)

---------------------------------------------------------
-- ADVANCED ESP SYSTEM
---------------------------------------------------------
local activeDrawings = {}

local function createDrawing(objType, properties)
    local obj = Drawing.new(objType)
    for k, v in pairs(properties) do obj[k] = v end
    return obj
end

local function removePlayerESP(player)
    if activeDrawings[player] then
        for _, drawing in pairs(activeDrawings[player]) do
            pcall(function() drawing:Remove() end)
        end
        activeDrawings[player] = nil
    end
end

local function initPlayerESP(player)
    if activeDrawings[player] then removePlayerESP(player) end
    local espTable = {
        BoxOutline = createDrawing("Square", { Visible = false, Filled = false, Thickness = 3, Color = Color3.new(0, 0, 0) }),
        Box = createDrawing("Square", { Visible = false, Filled = false, Thickness = 1, Color = Color3.new(1, 1, 1) }),
        BoxFilled = createDrawing("Square", { Visible = false, Filled = true, Color = Color3.new(0, 0, 0), Transparency = 0.5 }),
        HealthBarOutline = createDrawing("Line", { Visible = false, Thickness = 3, Color = Color3.new(0, 0, 0) }),
        HealthBar = createDrawing("Line", { Visible = false, Thickness = 1, Color = Color3.new(0, 1, 0) }),
        NameText = createDrawing("Text", { Visible = false, Size = 13, Center = true, Outline = true, Color = Color3.new(1, 1, 1) }),
        InfoText = createDrawing("Text", { Visible = false, Size = 12, Center = true, Outline = true, Color = Color3.new(0.8, 0.8, 0.8) }),
        Tracer = createDrawing("Line", { Visible = false, Thickness = 1, Color = Color3.new(1, 1, 1) }),
        HeadDot = createDrawing("Circle", { Visible = false, Filled = true, Radius = 4, NumSides = 12, Color = Color3.new(1, 1, 1) }),
        Skeleton = {}
    }
    for i = 1, 12 do
        table.insert(espTable.Skeleton, createDrawing("Line", { Visible = false, Thickness = 1, Color = Color3.new(1, 1, 1) }))
    end
    activeDrawings[player] = espTable
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then initPlayerESP(p) end end
Players.PlayerAdded:Connect(initPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

RunService.RenderStepped:Connect(function()
    local espEnabled = Toggles.ESPToggle and Toggles.ESPToggle.Value

    for player, drawings in pairs(activeDrawings) do
        local shouldShow = false
        local char = player.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")

        if espEnabled and char and rootPart and humanoid and humanoid.Health > 0 then
            local head = char:FindFirstChild("Head")
            local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if head and localRoot then
                local _, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                local _, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)

                if headOnScreen or rootOnScreen then
                    local distance = (localRoot.Position - rootPart.Position).Magnitude
                    if distance <= (Options.ESPDistance.Value or 2000) then
                        local topValid, topValidCheck = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
                        local botValid, botValidCheck = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

                        if topValidCheck and botValidCheck then
                            local height = math.abs(topValid.Y - botValid.Y)
                            local width = height / 2
                            local boxX = topValid.X - (width / 2)
                            local boxY = topValid.Y

                            -- Box
                            if Toggles.ESPBoxes and Toggles.ESPBoxes.Value then
                                drawings.BoxOutline.Visible = true
                                drawings.BoxOutline.Position = Vector2.new(boxX, boxY)
                                drawings.BoxOutline.Size = Vector2.new(width, height)
                                drawings.BoxOutline.Color = Options.ESPOutlineColor.Value

                                drawings.Box.Visible = true
                                drawings.Box.Position = Vector2.new(boxX, boxY)
                                drawings.Box.Size = Vector2.new(width, height)
                                drawings.Box.Color = Options.ESPBoxColor.Value

                                if Toggles.ESPBoxFilled and Toggles.ESPBoxFilled.Value then
                                    drawings.BoxFilled.Visible = true
                                    drawings.BoxFilled.Position = Vector2.new(boxX, boxY)
                                    drawings.BoxFilled.Size = Vector2.new(width, height)
                                    drawings.BoxFilled.Color = Options.ESPBoxFillColor.Value
                                    drawings.BoxFilled.Transparency = Options.ESPBoxFillTrans.Value / 100
                                else
                                    drawings.BoxFilled.Visible = false
                                end
                            else
                                drawings.BoxOutline.Visible = false
                                drawings.Box.Visible = false
                                drawings.BoxFilled.Visible = false
                            end

                            -- Health Bar
                            if Toggles.ESPHealthBar and Toggles.ESPHealthBar.Value then
                                local hpPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                                local barH = height * hpPct
                                drawings.HealthBarOutline.Visible = true
                                drawings.HealthBarOutline.From = Vector2.new(boxX - 6, boxY - 1)
                                drawings.HealthBarOutline.To = Vector2.new(boxX - 6, boxY + height + 1)

                                drawings.HealthBar.Visible = true
                                drawings.HealthBar.From = Vector2.new(boxX - 6, boxY + height)
                                drawings.HealthBar.To = Vector2.new(boxX - 6, boxY + (height - barH))
                                drawings.HealthBar.Color = Color3.fromRGB(255 * (1 - hpPct), 255 * hpPct, 0)
                            else
                                drawings.HealthBarOutline.Visible = false
                                drawings.HealthBar.Visible = false
                            end

                            -- Namn & Text
                            if Toggles.ESPNames and Toggles.ESPNames.Value then
                                drawings.NameText.Visible = true
                                drawings.NameText.Text = player.Name
                                drawings.NameText.Position = Vector2.new(boxX + (width / 2), boxY - 18)
                                drawings.NameText.Color = Options.ESPNameColor.Value
                            else
                                drawings.NameText.Visible = false
                            end

                            -- Tracers
                            if Toggles.ESPTracers and Toggles.ESPTracers.Value then
                                drawings.Tracer.Visible = true
                                drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                local rootPos = Camera:WorldToViewportPoint(rootPart.Position)
                                drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                                drawings.Tracer.Color = Options.ESPTracerColor.Value
                            else
                                drawings.Tracer.Visible = false
                            end

                            goto continueESP
                        end
                    end
                end
            end
        end

        drawings.BoxOutline.Visible = false
        drawings.Box.Visible = false
        drawings.BoxFilled.Visible = false
        drawings.HealthBarOutline.Visible = false
        drawings.HealthBar.Visible = false
        drawings.NameText.Visible = false
        drawings.InfoText.Visible = false
        drawings.Tracer.Visible = false
        drawings.HeadDot.Visible = false
        for _, line in ipairs(drawings.Skeleton) do line.Visible = false end
        ::continueESP::
    end
end)

---------------------------------------------------------
-- HUVUDLOOP (FLY & SPEED)
---------------------------------------------------------
RunService.RenderStepped:Connect(function(deltaTime)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = LocalPlayer.Character.HumanoidRootPart
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

        if Toggles.NoclipToggle and Toggles.NoclipToggle.Value then
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end

        if humanoid and Toggles.SpeedToggle and Toggles.SpeedToggle.Value then
            humanoid.WalkSpeed = Options.WalkSpeedValue.Value
        end

        if Toggles.FlyToggle and Toggles.FlyToggle.Value then
            myRoot.AssemblyLinearVelocity = Vector3.zero
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            myRoot.CFrame = myRoot.CFrame + (moveDir * Options.FlySpeed.Value * deltaTime)
        end
    end
end)

---------------------------------------------------------
-- UI ELEMENT (OBSIDIAN / DARK THEME CONFIG)
---------------------------------------------------------
RagebotGroup:AddToggle('RagebotToggle', { Text = 'Aktivera Ragebot / Automatisk Läge', Default = false })
RagebotGroup:AddDropdown('RageModeDropdown', { Values = { 'Rage Snap / Lock', 'Rage Orbit Target', 'Rage Teleport Behind', 'Rage Voidspam Chaos' }, Default = 1, Multi = false, Text = 'Ragebot Stridsläge' })
RagebotGroup:AddSlider('RageOrbitRadius', { Text = 'Rage Orbit Radie', Default = 12, Min = 2, Max = 40, Rounding = 0 })
RagebotGroup:AddSlider('RageOrbitHeight', { Text = 'Rage Orbit Höjd', Default = 2, Min = -10, Max = 20, Rounding = 0 })
RagebotGroup:AddSlider('RageOrbitSpeed', { Text = 'Rage Orbit Snurrhastighet', Default = 120, Min = 30, Max = 350, Rounding = 0 })

RageExtrasGroup:AddToggle('RageTriggerToggle', { Text = 'Aktivera Inbyggd Triggerbot', Default = false })
RageExtrasGroup:AddToggle('RagePrediction', { Text = 'Aktivera Hastighets-Prediktion', Default = true })
RageExtrasGroup:AddDropdown('RageTarget', { Values = { 'Head', 'HumanoidRootPart' }, Default = 1, Multi = false, Text = 'Sikta På' })
RageExtrasGroup:AddSlider('RageSmooth', { Text = 'Sikte Mjukhet', Default = 1, Min = 1, Max = 20, Rounding = 1 })

SilentAimGroup:AddToggle('SilentAimToggle', { Text = 'Aktivera Silent Aim', Default = false, Callback = function(v) SilentSettings.Enabled = v end })
SilentAimGroup:AddSlider('SilentHitChance', { Text = 'Hit Chance %', Default = 100, Min = 1, Max = 100, Rounding = 0 })
SilentAimGroup:AddToggle('FOVCircleEnabled', { Text = 'Visa FOV-cirkel', Default = true })
SilentAimGroup:AddSlider('FOVRadius', { Text = 'FOV Radie', Default = 150, Min = 20, Max = 600, Rounding = 0 })

WeaponModsGroup:AddToggle('NoRecoilToggle', { Text = 'Aktivera No Recoil', Default = false })
WeaponModsGroup:AddToggle('NoSpreadToggle', { Text = 'Aktivera No Spread', Default = false })

AntiAimGroup:AddToggle('AntiAimToggle', { Text = 'Aktivera Avancerad Anti-Aim', Default = false })
AntiAimGroup:AddDropdown('AntiAimMode', { Values = { 'Spinbot', 'Jitter', 'Desync' }, Default = 3, Multi = false, Text = 'Anti-Aim Läge' })
AntiAimGroup:AddSlider('AntiAimSpeed', { Text = 'Snurr / Skak-Hastighet', Default = 50, Min = 10, Max = 150, Rounding = 0 })

CombatMiscGroup:AddToggle('AntiKatanaToggle', { Text = 'Aktivera Antikatana (Auto-Dodge)', Default = false })
CombatMiscGroup:AddSlider('AntiKatanaDist', { Text = 'Reaktionsavstånd', Default = 12, Min = 5, Max = 30, Rounding = 0 })

VisualsGeneralGroup:AddToggle('ESPToggle', { Text = 'Aktivera Advanced ESP', Default = false })
VisualsGeneralGroup:AddSlider('ESPDistance', { Text = 'Max Avstånd', Default = 2000, Min = 100, Max = 5000, Rounding = 0 })

VisualsBoxesGroup:AddToggle('ESPBoxes', { Text = 'Aktivera 2D Box ESP', Default = false })
VisualsBoxesGroup:AddToggle('ESPBoxFilled', { Text = 'Fyll Box med Färg', Default = false })
VisualsBoxesGroup:AddLabel('Box Ramfärg'):AddColorPicker('ESPBoxColor', { Default = Color3.fromRGB(255, 255, 255), Title = 'Box Färg' })
VisualsBoxesGroup:AddLabel('Box Fyllningsfärg'):AddColorPicker('ESPBoxFillColor', { Default = Color3.fromRGB(255, 0, 0), Title = 'Fyllningsfärg' })
VisualsBoxesGroup:AddSlider('ESPBoxFillTrans', { Text = 'Fyllning Genomskinlighet %', Default = 50, Min = 0, Max = 100, Rounding = 0 })
VisualsBoxesGroup:AddLabel('Outline Färg'):AddColorPicker('ESPOutlineColor', { Default = Color3.fromRGB(0, 0, 0), Title = 'Outline Färg' })

VisualsBarsGroup:AddToggle('ESPHealthBar', { Text = 'Aktivera Hälsobar', Default = false })
VisualsBarsGroup:AddToggle('ESPNames', { Text = 'Visa Spelarnamn', Default = false })
VisualsBarsGroup:AddLabel('Namnfärg'):AddColorPicker('ESPNameColor', { Default = Color3.fromRGB(255, 255, 255), Title = 'Namnfärg' })

VisualsExtrasGroup:AddToggle('ESPTracers', { Text = 'Aktivera Siktlinjer (Tracers)', Default = false })
VisualsExtrasGroup:AddLabel('Tracer Färg'):AddColorPicker('ESPTracerColor', { Default = Color3.fromRGB(255, 255, 255), Title = 'Tracer Färg' })

SkinchangerGroup:AddToggle('SkinChangerToggle', { Text = 'Aktivera Vapen Skin Changer', Default = false })
SkinchangerGroup:AddDropdown('SkinMaterialDropdown', { Values = { 'Neon', 'Glass', 'SmoothPlastic', 'Metal', 'Wood', 'ForceField', 'CorrodedMetal' }, Default = 1, Multi = false, Text = 'Vapen Material' })
SkinchangerGroup:AddToggle('SkinTextureToggle', { Text = 'Använd Custom Textur ID', Default = false })
SkinchangerGroup:AddInput('SkinTextureInput', { Default = '', Numeric = false, Finished = true, Text = 'Decal Asset ID' })

SkinColorGroup:AddLabel('Vapen Färg'):AddColorPicker('SkinColorPicker', { Default = Color3.fromRGB(0, 255, 255), Title = 'Välj Skin Färg' })
SkinColorGroup:AddSlider('SkinReflectance', { Text = 'Glans / Reflektion', Default = 0, Min = 0, Max = 1, Rounding = 2 })

MovementGroup:AddToggle('NoclipToggle', { Text = 'Aktivera Noclip', Default = false })
MovementGroup:AddToggle('SpeedToggle', { Text = 'Aktivera Speedhack', Default = false })
MovementGroup:AddSlider('WalkSpeedValue', { Text = 'Springhastighet', Default = 32, Min = 16, Max = 250, Rounding = 0 })

FlyGroup:AddToggle('FlyToggle', { Text = 'Aktivera Fly', Default = false })
FlyGroup:AddSlider('FlySpeed', { Text = 'Flyghastighet', Default = 50, Min = 10, Max = 200, Rounding = 0 })

OrbitTeleportGroup:AddToggle('OrbitToggle', { Text = 'Aktivera Hyper-Orbit', Default = false })
OrbitTeleportGroup:AddDropdown('OrbitTpPlayerDropdown', { Values = getPlayerList(), Default = 1, Multi = false, Text = 'Välj Målspelare' })
OrbitTeleportGroup:AddDropdown('OrbitMode', { Values = { 'Standard Cirkel', 'Elliptisk (Oval)', 'Helix / Spiral Uppåt' }, Default = 1, Multi = false, Text = 'Orbit Mönster' })
OrbitTeleportGroup:AddToggle('OrbitLookAtTarget', { Text = 'Fixera Blick mot Målet', Default = true })
OrbitTeleportGroup:AddSlider('OrbitTpRadius', { Text = 'Orbit Radie', Default = 10, Min = 1, Max = 100, Rounding = 0 })
OrbitTeleportGroup:AddSlider('OrbitEllipticX', { Text = 'Ellips X-Sträckning', Default = 1, Min = 0.2, Max = 4, Rounding = 1 })
OrbitTeleportGroup:AddSlider('OrbitEllipticZ', { Text = 'Ellips Z-Sträckning', Default = 1, Min = 0.2, Max = 4, Rounding = 1 })
OrbitTeleportGroup:AddSlider('OrbitTpHeight', { Text = 'Orbit Höjd', Default = 0, Min = -30, Max = 50, Rounding = 0 })
OrbitTeleportGroup:AddSlider('OrbitSpeed', { Text = 'Orbit Hastighet', Default = 90, Min = 10, Max = 500, Rounding = 0 })

VoidSpamGroup:AddToggle('VoidSpamToggle', { Text = 'Aktivera Ultimate Voidspam', Default = false })
VoidSpamGroup:AddToggle('VoidSpamAnchor', { Text = 'Lås Centrumposition', Default = false })
VoidSpamGroup:AddSlider('VoidSpamSpeed', { Text = 'Spam-Frekvens', Default = 35, Min = 5, Max = 120, Rounding = 0 })
VoidSpamGroup:AddSlider('VoidSpamX', { Text = 'X-Axel Spridning', Default = 20, Min = 1, Max = 150, Rounding = 0 })
VoidSpamGroup:AddSlider('VoidSpamY', { Text = 'Y-Axel Spridning', Default = 20, Min = 1, Max = 150, Rounding = 0 })
VoidSpamGroup:AddSlider('VoidSpamZ', { Text = 'Z-Axel Spridning', Default = 20, Min = 1, Max = 150, Rounding = 0 })

MiscGroup:AddToggle('HitSoundToggle', { Text = 'Aktivera Hit Sound', Default = true })
MiscGroup:AddDropdown('HitSoundDropdown', { Values = { 'Rust', 'Neverlose', 'Bell', 'Pop', 'OSU' }, Default = 1, Multi = false, Text = 'Välj Hit Sound' })
MiscGroup:AddSlider('HitSoundVolume', { Text = 'Volym', Default = 1, Min = 0.1, Max = 2, Rounding = 1 })
MiscGroup:AddToggle('HitMessageToggle', { Text = 'Aktivera Hit Messages', Default = true })
MiscGroup:AddDropdown('HitMessageType', { Values = { 'Notification', 'Console', 'Chat' }, Default = 1, Multi = false, Text = 'Meddelandetyp' })

---------------------------------------------------------
-- CONFIG & THEME MANAGER
---------------------------------------------------------
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder('Menduware_Obsidian')
ThemeManager:SetFolder('Menduware_Obsidian')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
