local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⚔️ Operation One Script",
   Icon = 0,
   LoadingTitle = "⚔️ Operation One Scripts ⚔️",
   LoadingSubtitle = "By WillyBoy",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "operation one scripts"
   },
})

local MainTab = Window:CreateTab("🏠home", nil)
local MainSection = MainTab:CreateSection("Main")

Rayfield:Notify({
   Title = "Operation One Script Loaded! ",
   Content = "All systems ready",
   Duration = 5,
})


local AimBotToggle = MainTab:CreateToggle({
   Name = "AimBot",
   CurrentValue = false,
   Callback = function(Value)
      _G.aimbotEnabled = Value
   end,
})

local WallCheckToggle = MainTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = false,
   Callback = function(Value)
      _G.wallCheckEnabled = Value
   end,
})


local FOVSlider = MainTab:CreateSlider({
   Name = "FOV Slider ",
   Range = {0, 200},
   Increment = 1,
   Suffix = "FOV",
   CurrentValue = 80,
   Callback = function(Value)
        _G.FOV_RADIUS = Value
   end,
})

-- FOV Circle Visualization
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = 80
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 1
fovCircle.Transparency = 0.5

local CircleRunService = game:GetService("RunService")
local CircleUIS = game:GetService("UserInputService")

CircleRunService.RenderStepped:Connect(function()
   if _G.aimbotEnabled then
      fovCircle.Visible = true
      fovCircle.Radius = _G.FOV_RADIUS or 80
      local camera = workspace.CurrentCamera
      fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
   else
      fovCircle.Visible = false
   end
end)

local function TitanAimBot()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    _G.wallCheckEnabled = _G.wallCheckEnabled or false
    if not _G.FOV_RADIUS then _G.FOV_RADIUS = 80 end

    RunService.RenderStepped:Connect(function()
        if _G.aimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target, dist = nil, _G.FOV_RADIUS
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local head = p.Character.Head
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local mag = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if mag < dist then
                            if not _G.wallCheckEnabled or true then
                                local rayOrigin = Camera.CFrame.Position
                                local rayDirection = (head.Position - rayOrigin).Unit * 1000
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                                rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                                local rayResult = workspace:Raycast(rayOrigin, rayDirection, rayParams)
                                if not rayResult or rayResult.Instance:IsDescendantOf(p.Character) then
                                    dist = mag
                                    target = head
                                end
                            else
                                dist = mag
                                target = head
                            end
                        end
                    end
                end
            end
            if target then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            end
        end
    end)
end

TitanAimBot()

-- NO RECOIL SYSTEM
run_on_actor(getactors()[1], [==[

local recoil_x = 0  
local recoil_y = 0
    local old_tweenInfo_new = clonefunction(TweenInfo.new)
    hookfunction(TweenInfo.new, newcclosure(function(...)
        if debug.info(3, "n") == "recoil_function" then
            setstack(3, 5, getstack(3, 5) * recoil_x)
            setstack(3, 6, getstack(3, 6) * recoil_y)
        end
        return old_tweenInfo_new(...)
    end))
]==])

local NoRecoilToggle = MainTab:CreateToggle({
   Name = "No Recoil ON/OFF",
   CurrentValue = false,
   Callback = function(Value)
      NoRecoilSettings.Enabled = Value
      if Value then
         syncCamera()
      end
      print("No Recoil is now " .. (Value and "Enabled" or "Disabled"))
   end,
})

local SensSlider = MainTab:CreateSlider({
   Name = "No Recoil Sensitivity",
   Range = {0.1, 2.0},
   Increment = 0.1,
   Suffix = "x",
   CurrentValue = 1.0,
   Callback = function(Value)
        NoRecoilSettings.Sens = Value
   end,
})

local SmoothSlider = MainTab:CreateSlider({
   Name = "No Recoil Smoothness",
   Range = {0.01, 0.5},
   Increment = 0.01,
   Suffix = "s",
   CurrentValue = 0.12,
   Callback = function(Value)
        NoRecoilSettings.Smoothness = Value
   end,
})

local otherTab = Window:CreateTab("👁️ Esp", nil)
local Section = otherTab:CreateSection("Main")

local ViewmodelSection = otherTab:CreateSection("Viewmodel ESP")

local BoxesToggle = otherTab:CreateToggle({
   Name = "Boxes",
   CurrentValue = true,
   Callback = function(Value)
      _G.espBoxes = Value
   end,
})

local SkeletonsToggle = otherTab:CreateToggle({
   Name = "Skeletons",
   CurrentValue = false,
   Callback = function(Value)
      _G.espSkeletons = Value
   end,
})


_G.ESP_ENABLED = false
_G.ESPInitialized = false

_G.espBoxes = true
_G.espSkeletons = false

_G.ESP_Table = {}
_G.destroyESP = function()
   for _,ui in pairs(_G.ESP_Table) do
      pcall(function() if ui.Box then ui.Box:Remove() end end)
      pcall(function() if ui.Tracer then ui.Tracer:Remove() end end)
      pcall(function() if ui.Health then ui.Health:Remove() end end)
      pcall(function() if ui.Name then ui.Name:Remove() end end)
   end
   table.clear(_G.ESP_Table)
   _G.ESP_ENABLED = false
end

local function setupESP()
   if _G.ESPInitialized then return end
   _G.ESPInitialized = true

   local Players = game:GetService("Players")
   local RunService = game:GetService("RunService")
   local UserInputService = game:GetService("UserInputService")
   local Camera = workspace.CurrentCamera
   local LocalPlayer = Players.LocalPlayer

   local ESP = _G.ESP_Table

   local TEAM_CHECK = true
   local MAX_STUCK_TIME = 1.5
   local TOGGLE_KEY = Enum.KeyCode.RightAlt

   local function newDrawing(type, props)
      local obj = Drawing.new(type)
      for k,v in pairs(props) do
         obj[k] = v
      end
      return obj
   end

   local function hide(ui)
      ui.Box.Visible = false
      ui.Tracer.Visible = false
      ui.Health.Visible = false
      ui.Name.Visible = false
   end

   local function hideAll()
      for _,ui in pairs(ESP) do
         hide(ui)
      end
   end

   UserInputService.InputBegan:Connect(function(input, gameProcessed)
      if input.KeyCode == TOGGLE_KEY then
         _G.ESP_ENABLED = not _G.ESP_ENABLED
         
         if not _G.ESP_ENABLED then
            hideAll()
            print("ESP Disabled")
         else
            print("ESP Enabled")
         end
      end
   end)

   local function createESP(player)
      if player == LocalPlayer then return end
      if ESP[player] then return end
      
      ESP[player] = {
         Player = player,
         Box = newDrawing("Square", {
            Thickness = 1,
            Filled = false,
            Color = Color3.new(1,1,1),
            Visible = false
         }),
         Tracer = newDrawing("Line", {
            Thickness = 1,
            Color = Color3.new(1,1,1),
            Visible = false
         }),
         Health = newDrawing("Line", {
            Thickness = 3,
            Visible = false
         }),
         Name = newDrawing("Text", {
            Size = 13,
            Center = true,
            Outline = true,
            Font = 2,
            Visible = false
         }),
         LastPosition = nil,
         StuckTime = 0
      }
   end

   for _,player in ipairs(Players:GetPlayers()) do
      createESP(player)
   end

   Players.PlayerAdded:Connect(createESP)

   local function findCharacter(player)
      for _,model in ipairs(workspace:GetChildren()) do
         if model:IsA("Model") and model.Name == player.Name then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            if hum and root then
               return model, hum, root
            end
         end
      end
      return nil
   end

   local function getBox(character)
      local cf, size = character:GetBoundingBox()
      local top = cf.Position + Vector3.new(0, size.Y/2, 0)
      local bottom = cf.Position - Vector3.new(0, size.Y/2, 0)

      local topPos, vis1 = Camera:WorldToViewportPoint(top)
      local bottomPos, vis2 = Camera:WorldToViewportPoint(bottom)

      if not vis1 or not vis2 then
         return nil
      end

      local height = math.abs(topPos.Y - bottomPos.Y)
      local width = height / 2
      
      return Vector2.new(topPos.X - width/2, topPos.Y), width, height
   end

   RunService.RenderStepped:Connect(function(dt)
      if not _G.ESP_ENABLED then return end
      
      for player,ui in pairs(ESP) do
         pcall(function()
            if TEAM_CHECK and player.Team == LocalPlayer.Team then
               hide(ui)
               return
            end
            
            local character, humanoid, root = findCharacter(player)
            
            if not character or not humanoid or humanoid.Health <= 0 then
               hide(ui)
               ui.LastPosition = nil
               ui.StuckTime = 0
               return
            end
            
            local pos, width, height = getBox(character)
            if not pos then
               hide(ui)
               ui.LastPosition = nil
               ui.StuckTime = 0
               return
            end
            
            if ui.LastPosition then
               if (ui.LastPosition - pos).Magnitude < 1 then
ui.StuckTime = ui.StuckTime + dt
               else
                  ui.StuckTime = 0
               end
               
               if ui.StuckTime >= MAX_STUCK_TIME then
                  hide(ui)
                  ui.LastPosition = nil
                  ui.StuckTime = 0
                  return
               end
            end
            
            ui.LastPosition = pos
            
            ui.Box.Size = Vector2.new(width, height)
            ui.Box.Position = pos
            ui.Box.Visible = true
            
            local hp = humanoid.Health / humanoid.MaxHealth
            local healthHeight = height * hp
            
            ui.Health.From = Vector2.new(pos.X - 5, pos.Y + height)
            ui.Health.To = Vector2.new(pos.X - 5, pos.Y + height - healthHeight)
            ui.Health.Color = Color3.fromRGB(
               255 - (255*hp),
               255*hp,
               0
            )
            ui.Health.Visible = true
            
            ui.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            ui.Tracer.To = Vector2.new(pos.X + width/2, pos.Y)
            ui.Tracer.Visible = true
            
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
               local dist = (myRoot.Position - root.Position).Magnitude
               ui.Name.Text = player.Name .. " [" .. math.floor(dist) .. "m]"
            else
               ui.Name.Text = player.Name
            end
            
            ui.Name.Position = Vector2.new(pos.X + width/2, pos.Y - 15)
            ui.Name.Visible = true
         end)
      end
   end)
end

local Toggle = otherTab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
      if Value then
         setupESP()
      else
         _G.destroyESP()
         _G.ESPInitialized = false
      end
      _G.ESP_ENABLED = Value
   print("ESP is now " .. (Value and "Enabled" or "Disabled"))
   end,
})

-- Viewmodel ESP (Rayfield integrated)
local pi = math.pi

local cloneref_support = cloneref ~= nil
local gethui_support = gethui ~= nil

local runservice = cloneref_support and cloneref(game:GetService("RunService")) or game:GetService("RunService")

local bones = {
    { "torso", "head" },
    { "torso", "shoulder1" }, { "torso", "shoulder2" },
    { "shoulder1", "arm1" }, { "shoulder2", "arm2" },
    { "torso", "hip1" }, { "torso", "hip2" },
    { "hip1", "leg1" }, { "hip2", "leg2" },
}

local required_bones = { "torso", "head", "shoulder1", "shoulder2", "arm1", "arm2", "hip1", "hip2", "leg1", "leg2" }
local esp_list = {}
local skeleton_list = {}
local viewmodels = workspace:FindFirstChild("Viewmodels")
local camera = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    camera = workspace.CurrentCamera
end)

local teammate_highlights = {}

workspace.ChildAdded:Connect(function(child)
    if child:IsA("Highlight") then
        teammate_highlights[child] = true
    end
end)

workspace.ChildRemoved:Connect(function(child)
    if child:IsA("Highlight") then
        teammate_highlights[child] = nil
    end
end)

for _, child in ipairs(workspace:GetChildren()) do
    if child:IsA("Highlight") then
        teammate_highlights[child] = true
    end
end

local function is_teammate(model)
    for highlight in pairs(teammate_highlights) do
        if highlight.Adornee == model then return true end
    end
    return false
end

local function is_valid(model)
    if not model or not model.Parent then return false end
    if model.Name == "LocalViewmodel" then return false end
    if not viewmodels or model.Parent ~= viewmodels then return false end
    local torso = model:FindFirstChild("torso")
    return torso and torso:IsA("BasePart")
end

local function rand_str(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = {}
    for i = 1, len do result[i] = chars:sub(math.random(1, #chars), math.random(1, #chars)) end
    return table.concat(result)
end

local screen_gui = Instance.new("ScreenGui")
screen_gui.Name = rand_str(12)
screen_gui.Parent = gethui_support and gethui() or game:GetService("CoreGui")

local function remove_skeleton(character)
    local data = skeleton_list[character]
    if not data then return end
    for _, line in ipairs(data.lines) do line:Remove() end
    skeleton_list[character] = nil
end

local function create_skeleton(character)
    if not character or skeleton_list[character] or not is_valid(character) then return end

    local char_bones = {}
    for _, name in ipairs(required_bones) do
        local b = character:FindFirstChild(name)
        if not b or not b:IsA("BasePart") then return end
        char_bones[name] = b
    end

    local lines = {}
    for i = 1, #bones do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.new(1, 1, 1)
        line.Thickness = 1
        line.Transparency = 1
        lines[i] = line
    end

    skeleton_list[character] = { lines = lines, bones = char_bones }
end

local function create_esp(character)
    if not character or not is_valid(character) or esp_list[character] then return end

    local folder = Instance.new("Folder", screen_gui)
    local box = Instance.new("Frame", folder)
    local stroke = Instance.new("UIStroke", box)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 1
    esp_list[character] = { folder = folder, box = box }
end

runservice.RenderStepped:Connect(function()
    for character, data in pairs(esp_list) do
        local box = data.box
        local folder = data.folder

        if not character or not character.Parent or not is_valid(character) then
            box.Visible = false
            folder:Destroy()
            esp_list[character] = nil
            remove_skeleton(character)
            continue
        end

        local torso = character:FindFirstChild("torso")
        if not torso or torso.Transparency >= 1 or is_teammate(character) then
            box.Visible = false
            continue
        end

        local pos, on_screen = camera:WorldToScreenPoint(torso.Position)

        if on_screen and (camera.CFrame.Position - torso.Position).Magnitude <= 3571.4 then
            if _G.espSkeletons then
                if not skeleton_list[character] then create_skeleton(character) end
                local skel = skeleton_list[character]
                if skel then
                    local min_x, min_y = math.huge, math.huge
                    local max_x, max_y = -math.huge, -math.huge

                    for i, conn in ipairs(bones) do
                        local b1, b2 = skel.bones[conn[1]], skel.bones[conn[2]]
                        if b1 and b2 then
                            local p1, on1 = camera:WorldToViewportPoint(b1.Position)
                            local p2, on2 = camera:WorldToViewportPoint(b2.Position)
                            local s1, son1 = camera:WorldToScreenPoint(b1.Position)
                            local s2, son2 = camera:WorldToScreenPoint(b2.Position)
                            if son1 then
                                if s1.X < min_x then min_x = s1.X end
                                if s1.X > max_x then max_x = s1.X end
                                if s1.Y < min_y then min_y = s1.Y end
                                if s1.Y > max_y then max_y = s1.Y end
                            end
                            if son2 then
                                if s2.X < min_x then min_x = s2.X end
                                if s2.X > max_x then max_x = s2.X end
                                if s2.Y < min_y then min_y = s2.Y end
                                if s2.Y > max_y then max_y = s2.Y end
                            end
                            if on1 and on2 then
                                skel.lines[i].From = Vector2.new(p1.X, p1.Y)
                                skel.lines[i].To = Vector2.new(p2.X, p2.Y)
                                skel.lines[i].Visible = true
                            else
                                skel.lines[i].Visible = false
                            end
                        else
                            skel.lines[i].Visible = false
                        end
                    end

                    if _G.espBoxes and min_x ~= math.huge then
                        local pad = 4
                        box.Visible = true
                        box.Position = UDim2.fromOffset(min_x - pad, min_y - pad)
                        box.Size = UDim2.fromOffset(max_x - min_x + pad * 2, max_y - min_y + pad * 2)
                    else
                        box.Visible = false
                    end
                end
            else
                remove_skeleton(character)
                box.Visible = false
            end
        else
            box.Visible = false
            remove_skeleton(character)
        end
    end
end)

if viewmodels then
    for _, v in ipairs(viewmodels:GetChildren()) do
        if v:IsA("Model") then task.delay(0.1, create_esp, v) end
    end
    viewmodels.ChildAdded:Connect(function(v)
        if v:IsA("Model") then task.delay(0.2, create_esp, v) end
    end)
    viewmodels.ChildRemoved:Connect(function(v)
        if esp_list[v] then esp_list[v].folder:Destroy(); esp_list[v] = nil end
        remove_skeleton(v)
    end)
end

