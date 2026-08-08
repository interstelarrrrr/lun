local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false 
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
  Title = "getlunality.win",
  Footer = "*"
})

local Tabs = {
  Rage = Window:AddTab("Rage", "angry"),
  Legit = Window:AddTab("Legit", "crosshair"),
  Misc = Window:AddTab("Misc", "wrench"),
  Visuals = Window:AddTab("Visuals", "eye"),
  Skins = Window:AddTab("Skins", "gun"),
  Settings = Window:AddTab("Settings", "settings")
}

local Miscenalleous = Tabs.Misc:AddLeftGroupbox("Miscenalleous")
local Aimbot = Tabs.Legit:AddLeftGroupbox("Aimbot")
local SilentAim = Tabs.Rage:AddRightGroupbox("Silent Aim")
local Movement = Tabs.Misc:AddRightGroupbox("Movement")
local Effects = Tabs.Visuals:AddLeftGroupbox("Effects")

local MovementFunctions = {
  FastWalk = false,
  Speed = 16,
  HighJump = false,
  Height = 7.2,
  Noclip = false,
  Fly = false,
  FlySpeed = 100,
  SlowMotion = false,
  Intensity = 5
}

local MiscFunctions = {
  PreventAFKKick = false,
  AutomaticWeapons = false,
  HitSound = false,
  Sounds = "Minecraft",
  NoFallDamage = false,
  AutoBlock = false,
  InstantEquip = false,
  InstantReload = false,
  AutoStomp = false
}

local EffectsFunctions = {
  RemoveFlashbang = false,
  RemoveSmoke = false,
  RemoveHelmet = false,
  RemoveSkybox = false,
  VisualRecoilAdjustment = "Off",
  TransparentWalls = 100,
  BrightnessAdjustment = "Off",
  BulletTracer = false,
  TracerColor = Color3.fromRGB(255, 255, 255)
}

local SilentAimFunctions = {
  Enabled = false,
  FOVSize = 10,
  DrawFOV = false,
  FOVColor = Color3.fromRGB(255, 255, 255),
  MissChance = 10,
  Distance = 300,
  TargetBone = "Head",
  TeamCheck = false,
  DownedCheck = false,
  WallCheck = false
}

local AimbotFunctions = {
  Enabled = false,
  FOV = 315,
  DrawFOV = false,
  FOVColor = Color3.fromRGB(255, 255, 255),
  Dynamic = false,
  Smoothness = 80,
  Distance = 100,
  TargetBone = {"Head"},
  TargetPriority = {"Closest to Crosshair", "Lowest Health", "Highest Health", "Closest Distance", "Farthest Distance", "Random"},
  TargetVisibleOnly = false,
  IgnoreDownedTarget = false
}

local RuntimeState = { Data = {} }
local function GetCharacter(Player) return Player.Character end

RunService.Heartbeat:Connect(function()
  local Character = LocalPlayer.Character
  if not Character then return end
  local Humanoid = Character:FindFirstChild("Humanoid")
  local RootPart = Character:FindFirstChild("HumanoidRootPart")
  if MovementFunctions.Noclip and Character then
    for _, v in ipairs(Character:GetDescendants()) do
      if v:IsA("BasePart") then
        v.CanCollide = false
      end
    end
  end
  if MovementFunctions.FastWalk and not MovementFunctions.SlowMotion and RootPart then
    local Direction = Humanoid and Humanoid.MoveDirection or Vector3.zero
    RootPart.AssemblyLinearVelocity = Vector3.new(Direction.X * MovementFunctions.Speed, RootPart.AssemblyLinearVelocity.Y, Direction.Z * MovementFunctions.Speed)
  end
  if MovementFunctions.HighJump then
    Humanoid.UseJumpPower = false
    Humanoid.JumpHeight = MovementFunctions.Height
  end
  if MovementFunctions.SlowMotion and RootPart then
    local Direction = Humanoid and Humanoid.MoveDirection or Vector3.zero
    local CurrentSpeed = MovementFunctions.FastWalk and MovementFunctions.Speed or 10
    RootPart.AssemblyLinearVelocity = Vector3.new(Direction.X * CurrentSpeed / MovementFunctions.Intensity, RootPart.AssemblyLinearVelocity.Y, Direction.Z * CurrentSpeed / MovementFunctions.Intensity)
  end
end)

local FlyConnection
local function StartFlying()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end
    
    local RagdollEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("__RZDONL")
    
    for _, Child in ipairs(Character:GetDescendants()) do 
        if Child:IsA("Motor6D") then Child.Enabled = false end 
    end
    
    Humanoid.PlatformStand = true
    Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    
    local FlyMotors = {}
    for _, Part in ipairs(Character:GetDescendants()) do
        if Part:IsA("BasePart") and Part ~= RootPart then
            local Motor = Instance.new("Motor6D")
            Motor.Name = "FlyMotor"
            Motor.Part0 = RootPart
            Motor.Part1 = Part
            Motor.C1 = CFrame.new()
            Motor.C0 = RootPart.CFrame:ToObjectSpace(Part.CFrame)
            Motor.Parent = Part
            table.insert(FlyMotors, Motor)
        end
    end
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not MovementFunctions.Fly then
            if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
            Humanoid.PlatformStand = false
            RootPart.Velocity = Vector3.new(0,0,0)
            Humanoid:ChangeState(Enum.HumanoidStateType.Running)
            
            for _, Motor in ipairs(FlyMotors) do Motor:Destroy() end
            for _, Child in ipairs(Character:GetDescendants()) do 
                if Child:IsA("Motor6D") and Child.Name ~= "FlyMotor" then Child.Enabled = true end 
            end
            return
        end
      
        local CameraLook = Camera.CFrame.LookVector
        local IsMoving = Humanoid.MoveDirection.Magnitude > 0
        local TargetLook = Vector3.new(CameraLook.X, CameraLook.Y, CameraLook.Z)
        
        if TargetLook.Magnitude > 0 then 
            TargetLook = TargetLook.Unit 
            RootPart.CFrame = CFrame.new(RootPart.Position, RootPart.Position + TargetLook) 
        end
        
        if IsMoving then
            local MoveVector = Vector3.new(CameraLook.X, CameraLook.Y, CameraLook.Z).Unit
            RootPart.Velocity = MoveVector * MovementFunctions.FlySpeed
            RagdollEvent:FireServer("__---r",Vector3.zero,CFrame.new(-4574,3,-443,0,0,1,0,1,0,-1,0,0),true)
        else 
            RootPart.Velocity = Vector3.new(0,0,0) 
        end
    end)
end

local function DisableFlying()
    MovementFunctions.Fly = false
    if FlyConnection then 
        FlyConnection:Disconnect() 
        FlyConnection = nil 
    end
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    
    if Humanoid then
        Humanoid.PlatformStand = false
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    
    if RootPart then
        RootPart.Velocity = Vector3.new(0,0,0)
    end
    
    for _, Part in ipairs(Character:GetDescendants()) do
        local Motor = Part:FindFirstChild("FlyMotor")
        if Motor then
            Motor:Destroy()
        end
    end
    
    for _, Child in ipairs(Character:GetDescendants()) do 
        if Child:IsA("Motor6D") and Child.Name ~= "FlyMotor" then 
            Child.Enabled = true 
        end 
    end
end

local BulletBeamStyles = {}
local function CreateBulletBeam(CurrentValues2, SecondaryValue)
    local Ter = workspace:FindFirstChildOfClass("Terrain")
    if not Ter then
        return 
    end
    local InstanceObject2 = Instance.new("Attachment")
    local InstanceObject3 = Instance.new("Attachment")
    InstanceObject2.Position = CurrentValues2
    InstanceObject3.Position = SecondaryValue
    InstanceObject2.Parent = Ter
    InstanceObject3.Parent = Ter
    local Beam = Instance.new("Beam")
    local LocalValue4 = BulletBeamStyles.Classic
    Beam.Attachment0 = InstanceObject2
    Beam.Attachment1 = InstanceObject3
    Beam.Color = ColorSequence.new(EffectsFunctions.TracerColor)
    Beam.Width0 = 1.2
    Beam.Width1 = 1.2
    Beam.Texture = "rbxassetid://7151778302"
    Beam.TextureLength = 1
    Beam.TextureSpeed = 1
    Beam.TextureMode = Enum.TextureMode.Stretch
    Beam.Transparency = NumberSequence.new(0.45)
    Beam.FaceCamera = true
    Beam.LightEmission = 1
    Beam.LightInfluence = 0
    Beam.Parent = Ter
    
    task.spawn(function()
        local startTime = os.clock()
        local duration = 4
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local elapsed = os.clock() - startTime
            if elapsed >= duration then
                connection:Disconnect()
                pcall(function() Beam:Destroy() end)
                pcall(function() InstanceObject2:Destroy() end)
                pcall(function() InstanceObject3:Destroy() end)
            else
                if Beam.Parent then
                    Beam.Transparency = NumberSequence.new(0.45 + (0.55 * (elapsed / duration)))
                else
                    connection:Disconnect()
                end
            end
        end)
    end)
end

RuntimeState.Data.ClearBulletTracerConnections = function()
    local Connections = RuntimeState.Data.BulletTracerConnections or {}
    for _, Connection in ipairs(Connections) do
        pcall(Connection.Disconnect, Connection)
    end
    RuntimeState.Data.BulletTracerConnections = {}
end

RuntimeState.Data.TraceBulletDirections = function(Tool, Directions, FallbackOrigin)
    if not EffectsFunctions.BulletTracer or type(Directions) ~= "table" then
        return
    end
    local Character = GetCharacter(LocalPlayer)
    if not Character or Character:FindFirstChildOfClass("Tool") ~= Tool then
        return
    end
    local Muzzle = Tool and (Tool:FindFirstChild("Muzzle", true) or Tool:FindFirstChild("FirePoint", true))
    if not Muzzle then
        local WeaponHandle = Tool and Tool:FindFirstChild("WeaponHandle", true)
        Muzzle = WeaponHandle and (WeaponHandle:FindFirstChild("Muzzle", true) or WeaponHandle:FindFirstChild("FirePoint", true))
    end
    local Origin
    if Muzzle then
        if Muzzle:IsA("Attachment") then
            Origin = Muzzle.WorldPosition
        elseif Muzzle:IsA("BasePart") then
            Origin = Muzzle.Position
        end
    end
    if not Origin and typeof(FallbackOrigin) == "Vector3" then
        Origin = FallbackOrigin
    end
    Origin = Origin or Camera.CFrame.Position
    for _, Direction in pairs(Directions) do
        if typeof(Direction) == "Vector3" and Direction.Magnitude > 0 then
            local RaycastParameters = RaycastParams.new()
            RaycastParameters.FilterType = Enum.RaycastFilterType.Exclude
            RaycastParameters.FilterDescendantsInstances = {Camera, Character, Tool}
            RaycastParameters.IgnoreWater = true
            local Result = workspace:Raycast(Origin, Direction.Unit * 1000, RaycastParameters)
            CreateBulletBeam(Origin, Result and Result.Position or Origin + Direction.Unit * 500)
        end
    end
end

RuntimeState.Data.SetupBulletTracerConnections = function()
    RuntimeState.Data.ClearBulletTracerConnections()
    local Connections = RuntimeState.Data.BulletTracerConnections
    local Events2 = ReplicatedStorage:FindFirstChild("Events2")
    local Visualize = Events2 and Events2:FindFirstChild("Visualize")
    if Visualize and Visualize.Event then
        Connections[#Connections + 1] = Visualize.Event:Connect(function(Arg1, Arg2, Arg3, Tool, Arg5, Origin, Directions)
            RuntimeState.Data.TraceBulletDirections(Tool, Directions, Origin)
        end)
    end
    local Events = ReplicatedStorage:FindFirstChild("Events")
    if Events then
        local function AttachRemote(Remote)
            if not Remote:IsA("RemoteEvent") or Remote.Name == "ZFKLF__H" then
                return
            end
            Connections[#Connections + 1] = Remote.OnClientEvent:Connect(function(...)
                local Args = {...}
                local Tool = Args[3]
                local Directions = Args[6]
                if typeof(Tool) == "Instance" and Tool:IsA("Tool") and type(Directions) == "table" then
                    RuntimeState.Data.TraceBulletDirections(Tool, Directions, Args[5])
                end
            end)
        end
        for _, Remote in ipairs(Events:GetChildren()) do
            AttachRemote(Remote)
        end
        Connections[#Connections + 1] = Events.ChildAdded:Connect(AttachRemote)
    end
end
RuntimeState.Data.SetupBulletTracerConnections()

local LatestHitSoundIds = {
    ["Minecraft"] = "rbxassetid://7151570575",
    ["Neverlose"] = "rbxassetid://6607204501",
    ["Bonk"] = "rbxassetid://3765689841",
    ["Bat"] = "rbxassetid://3333907347",
    ["Laser Beam"] = "rbxassetid://130791043",
    ["Gamesense"] = "rbxassetid://5633695679",
    ["Fatality"] = "rbxassetid://6607142036",
    ["Rust"] = "rbxassetid://5043539486",
    ["Bow"] = "rbxassetid://93158957747276"
}

local function LatestPlaySound(Id)
    if not Id then
        return
    end
    local Sound = Instance.new("Sound")
    Sound.SoundId = Id
    Sound.Volume = 2
    Sound.Parent = game:GetService("SoundService")
    Sound:Play()
    game:GetService("Debris"):AddItem(Sound, 5)
end

local LatestHitmarkerConnections = setmetatable({}, {__mode = "k"})
local function LatestBindHitmarker(Tool)
    if not Tool or not Tool:IsA("Tool") or LatestHitmarkerConnections[Tool] then
        return
    end
    local Marker = Tool:FindFirstChild("Hitmarker", true)
    if not Marker then
        return
    end
    local Signal
    pcall(function()
        Signal = Marker.Event
    end)
    if not Signal or not Signal.Connect then
        return
    end
    LatestHitmarkerConnections[Tool] = Signal:Connect(function(Target)
        if MiscFunctions.HitSound then
            LatestPlaySound(LatestHitSoundIds[MiscFunctions.Sounds])
        end
    end)
end

local function LatestScanHitmarkers()
    local Character = LocalPlayer.Character
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    for _, Container in ipairs({Character, Backpack}) do
        if Container then
            for _, Object in ipairs(Container:GetChildren()) do
                if Object:IsA("Tool") then
                    LatestBindHitmarker(Object)
                end
            end
        end
    end
end
task.spawn(function()
    while task.wait(1) do
        LatestScanHitmarkers()
    end
end)

local function IsPlayerDowned(Player)
    if not Player or not Player.Character then return false end
    local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid.Health <= 15 then return true end
    
    local CharStats = Player.Character:FindFirstChild("CharStats")
    if CharStats then
        local Downed = CharStats:FindFirstChild("Downed")
        if Downed and typeof(Downed.Value) == "boolean" then
            return Downed.Value
        end
    end
    return false
end

local function SetupSilentAim()
    local SilentAimCircle = Drawing.new("Circle")
    SilentAimCircle.Color = SilentAimFunctions.FOVColor
    SilentAimCircle.Thickness = 1
    SilentAimCircle.NumSides = 50
    SilentAimCircle.Radius = SilentAimFunctions.FOVSize
    SilentAimCircle.Filled = false
    SilentAimCircle.Visible = false

    local Target = nil
    local VisualizeEvent = ReplicatedStorage:WaitForChild("Events2"):WaitForChild("Visualize")
    local ZFKLF__H = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ZFKLF__H")

    local function GetClosest()
        Target = nil
        local Shortest = SilentAimFunctions.DrawFOV and SilentAimFunctions.FOVSize or math.huge
        local Center = UserInputService:GetMouseLocation()

        for _, A in pairs(Players:GetPlayers()) do
            if A ~= LocalPlayer and A.Character and A.Character:FindFirstChild("HumanoidRootPart") then
                if SilentAimFunctions.DownedCheck and IsPlayerDowned(A) then continue end
                if SilentAimFunctions.TeamCheck and A.Team == LocalPlayer.Team then continue end

                local Hrp = A.Character.HumanoidRootPart
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Hrp.Position)

                if OnScreen then
                    local Dist = (Center - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                    if Dist > SilentAimFunctions.Distance then return end
                    if Dist < Shortest then
                        Shortest = Dist
                        Target = A
                    end
                end
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        if SilentAimCircle then
            local Pos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            SilentAimCircle.Visible = SilentAimFunctions.Enabled and SilentAimFunctions.DrawFOV
            SilentAimCircle.Radius = SilentAimFunctions.FOVSize
            SilentAimCircle.Thickness = 1
            SilentAimCircle.Filled = false
            SilentAimCircle.Color = SilentAimFunctions.FOVColor
            SilentAimCircle.Position = Pos
        end
        if SilentAimFunctions.Enabled then
            GetClosest()
        end
    end)

    VisualizeEvent.Event:Connect(function(_, ShotCode, _, Gun, _, StartPos, BulletsPerShot)
        if not SilentAimFunctions.Enabled or not Target or not Target.Character then return end
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChildOfClass("Tool") then return end
      
        if math.random(1, 100) > SilentAimFunctions.MissChance then return end

        local PossibleParts = SilentAimFunctions.TargetBone
        local PartsName = PossibleParts[1] or "Head"
        local TargetPart = Target.Character:FindFirstChild(PartsName)
        
        if TargetPart then
            local PartPos = TargetPart.Position
            local BulletCount = type(BulletsPerShot) == "table" and #BulletsPerShot or 1
            
            task.wait(0.005)
            for I = 1, math.clamp(BulletCount, 1, 100) do
                local Dir = (PartPos - StartPos).Unit
                ZFKLF__H:FireServer("🧈", Gun, ShotCode, I, TargetPart, PartPos, Dir)
            end

            if Gun:FindFirstChild("Hitmarker") then
                Gun.Hitmarker:Fire(TargetPart)
            end
        end
    end)
end

local function AimbotFunction()
  while true do
    if AimbotFunctions.Enabled then
      local Character = LocalPlayer.Character
      if Character and Character:FindFirstChild("Head") then
        local Target = nil
        local BestScore = math.huge
        local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local CurrentTargets = {}
        for _, Player in pairs(Players:GetPlayers()) do
          if AimbotFunctions.IgnoreDownedTarget and IsPlayerDowned(Player) then continue end
          local TargetBone = AimbotFunctions.TargetBone and AimbotFunctions.TargetBone[1] or "Head"
          if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(TargetBone) then
            local PartToAim = Player.Character[TargetBone]
            local Pos, OnScreen = Camera:WorldToViewportPoint(PartToAim.Position)
            if OnScreen then
              local MouseDistance = (Vector2.new(Pos.X, Pos.Y) - Center).Magnitude
              local WorldDistance = (Camera.CFrame.Position - PartToAim.Position).Magnitude
              if MouseDistance <= AimbotFunctions.FOV and WorldDistance <= AimbotFunctions.Distance then
                local CanSee = true
                if AimbotFunctions.TargetVisibleOnly then
                  local RayParams = RaycastParams.new()
                  RayParams.FilterDescendantsInstances = {Character, Camera}
                  RayParams.FilterType = Enum.RaycastFilterType.Exclude
                  local RayResult = Workspace:Raycast(Camera.CFrame.Position, (PartToAim.Position - Camera.CFrame.Position), RayParams)
                  if RayResult and not RayResult.Instance:IsDescendantOf(Player.Character) then CanSee = false end
                end
                if CanSee then
                  local Health = Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health or 100
                  table.insert(CurrentTargets, {Part = PartToAim, MouseDist = MouseDistance, WorldDist = WorldDistance, Health = Health, Player = Player})
                end
              end
            end
          end
        end
        if #CurrentTargets > 0 then
          local PriorityType = AimbotFunctions.TargetPriority[1] or "Closest to Crosshair"
          local SelectedTarget = CurrentTargets[1]
          if PriorityType == "Closest to Crosshair" then
            local CrosshairCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            for _, v in pairs(CurrentTargets) do
              local TargetScreenPos, IsOnScreen = Camera:WorldToViewportPoint(v.Part.Position)
              if IsOnScreen then
                local DistanceFromCrosshair = (Vector2.new(TargetScreenPos.X, TargetScreenPos.Y) - CrosshairCenter).Magnitude
                local CurrentDistance = (Vector2.new(Camera:WorldToViewportPoint(SelectedTarget.Part.Position).X, Camera:WorldToViewportPoint(SelectedTarget.Part.Position).Y) - CrosshairCenter).Magnitude
                if DistanceFromCrosshair < CurrentDistance then
                  SelectedTarget = v
                end
              end
            end
          elseif PriorityType == "Lowest Health" then
            for _, v in pairs(CurrentTargets) do
              if v.Health < SelectedTarget.Health then SelectedTarget = v end
            end
          elseif PriorityType == "Highest Health" then
            for _, v in pairs(CurrentTargets) do
              if v.Health > SelectedTarget.Health then SelectedTarget = v end
            end
          elseif PriorityType == "Closest Distance" then
            for _, v in pairs(CurrentTargets) do
              if v.WorldDist < SelectedTarget.WorldDist then SelectedTarget = v end
            end
          elseif PriorityType == "Farthest Distance" then
            for _, v in pairs(CurrentTargets) do
              if v.WorldDist > SelectedTarget.WorldDist then SelectedTarget = v end
            end
          elseif PriorityType == "Random" then
            SelectedTarget = CurrentTargets[math.random(1, #CurrentTargets)]
          end
          Target = SelectedTarget.Part
        end
      end
    end
    if Target then
      local Goal = CFrame.new(Camera.CFrame.Position, Target.Position)
      Camera.CFrame = AimbotFunctions.Smoothness and Camera.CFrame:Lerp(Goal, AimbotFunctions.Smoothness / 100) or Goal
    end
    task.wait()
  end
end
task.spawn(AimbotFunction)

local FastWalkSlider
Movement:AddToggle(".", {
  Text = "Fast Walk",
  Default = false,
  Disabled = false, 
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    MovementFunctions.FastWalk = Value
    if FastWalkSlider then
      FastWalkSlider:SetVisible(Value)
    end
  end,
})

FastWalkSlider = Movement:AddSlider(".", {
  Text = "Speed",
  Default = 16,
  Min = 0,
  Max = 100,
  Rounding = 2,
  Compact = false,
  Visible = false,
  Callback = function(Value)
    MovementFunctions.Speed = Value
  end,
})

local HighJumpSlider
Movement:AddToggle(".", {
  Text = "High Jump",
  Default = false,
  Disabled = false, 
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    MovementFunctions.HighJump = Value
    if HighJumpSlider then
      HighJumpSlider:SetVisible(Value)
    end
  end,
})

HighJumpSlider = Movement:AddSlider(".", {
  Text = "Height",
  Default = 7.2,
  Min = 0,
  Max = 50,
  Rounding = 1,
  Compact = false,
  Visible = false,
  Callback = function(Value)
    MovementFunctions.Height = Value
  end,
})

local FlySlider
Movement:AddToggle(".", {
  Text = "Fly",
  Default = false,
  Disabled = false, 
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    MovementFunctions.Fly = Value
    if Value then StartFlying() else DisableFlying() end
    if FlySlider then
      FlySlider:SetVisible(Value)
    end
  end,
})

FlySlider = Movement:AddSlider(".", {
  Text = "Speed",
  Default = 100,
  Min = 0,
  Max = 100,
  Rounding = 2,
  Compact = false,
  Visible = false,
  Callback = function(Value)
    MovementFunctions.FlySpeed = Value
  end,
})

local SlowMotionSlider
Movement:AddToggle(".", {
  Text = "Slow Motion",
  Default = false,
  Disabled = false, 
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    MovementFunctions.SlowMotion = Value
    if SlowMotionSlider then
      SlowMotionSlider:SetVisible(Value)
    end
  end,
})

SlowMotionSlider = Movement:AddSlider(".", {
  Text = "Intensity",
  Default = 100,
  Min = 0,
  Max = 100,
  Rounding = 2,
  Compact = false,
  Visible = false,
  Callback = function(Value)
    MovementFunctions.Intensity = Value
  end,
})

Movement:AddToggle(".", {
  Text = "Noclip",
  Default = false,
  Disabled = false, 
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    MovementFunctions.Noclip = Value
  end,
})

Effects:AddToggle(".", {
  Text = "Remove Flashbang Effects", 
  Default = false,
  Disabled = false, 
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    EffectsFunctions.RemoveFlashbang = Value
    local Path = ReplicatedStorage:WaitForChild("Storage"):WaitForChild("FrameworkStuff")
    local FlashbangEffect = Path:WaitForChild("FlashbangEffect")
    if Value then
      FlashbangEffect.Parent = nil
    else
      FlashbangEffect.Parent = Path
    end
  end,
})

Miscenalleous:AddToggle(".", {
  Text = "Hit Sound",
  Default = false,
  Disabled = false,  
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    MiscFunctions.HitSound = Value
  end,
})

Aimbot:AddToggle(".", {
  Text = "Enabled",
  Default = false,
  Disabled = false,  
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    AimbotFunctions.Enabled = Value
  end,
})

Aimbot:AddSlider(".", {
  Text = "FOV",
  Default = 315,
  Min = 1,
  Max = 900,
  Rounding = 2,
  Compact = false,
  Visible = true,
  Callback = function(Value)
    AimbotFunctions.FOV = Value
  end,
})

Aimbot:AddToggle(".", {
  Text = "Draw FOV",
  Default = false,
  Disabled = false,  
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    AimbotFunctions.DrawFOV = Value
  end,
}):AddColorPicker(".", {
  Title = "FOV Color",
  Default = Color3.fromRGB(255, 255, 255),
  Callback = function(Value)
    AimbotFunctions.FOVColor = Value
  end,
})

Aimbot:AddToggle(".", {
  Text = "Dynamic",
  Default = false,
  Disabled = false,  
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    AimbotFunctions.Dynamic = Value
  end,
})

Aimbot:AddSlider(".", {
  Text = "Smoothness",
  Default = 80,
  Min = 0,
  Max = 100,
  Rounding = 1,
  Compact = false,
  Visible = true,
  Callback = function(Value)
    SilentAimFunctions.MissChance = Value
  end,
})

Aimbot:AddSlider(".", {
  Text = "Distance",
  Default = 315,
  Min = 10,
  Max = 1000,
  Rounding = 2,
  Compact = false,
  Visible = true,
  Callback = function(Value)
    AimbotFunctions.Distance = Value
  end,
})

Aimbot:AddDropdown(".", {
  Text = "Target Bone",
  Default = "Head",
  Values = {"Head", "Torso", "Left Leg", "Right Leg", "Left Arm", "Right Arm"},
  Multi = false,
  Visible = true,
  Callback = function(Value)
    AimbotFunctions.TargetBone = Value
  end,
})

Aimbot:AddDropdown(".", {
  Text = "Target Priority",
  Default = "Closest to Crosshair",
  Values = {"Closest to Crosshair", "Lowest Health", "Highest Health", "Farthest Distance", "Closest Distance", "Random"},
  Multi = false,
  Visible = true,
  Callback = function(Value)
    AimbotFunctions.TargetPriority = Value
  end,
})

Aimbot:AddToggle(".", {
  Text = "Target Visible Only",
  Default = false,
  Disabled = false,  
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    AimbotFunctions.TargetVisibleOnly = Value
  end,
})

Aimbot:AddToggle(".", {
  Text = "Ignore Downed Target",
  Default = false,
  Disabled = false,  
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    AimbotFunctions.IgnoreDownedTarget = Value
  end,
})

Miscenalleous:AddToggle(".", {
  Text = "Hit Sound",
  Default = false,
  Disabled = false,  
  Visible = true, 
  Risky = false,
  Callback = function(Value)
    MiscFunctions.HitSound = Value
  end,
})
