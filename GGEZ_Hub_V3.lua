-- [[ GGEZ HUB V3 - RIVALS EDITION ]]
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- สีหลัก Yellow-Black Theme
local YELLOW = Color3.fromRGB(255, 220, 0)
local YELLOW_BRIGHT = Color3.fromRGB(255, 235, 50)
local YELLOW_DARK = Color3.fromRGB(200, 160, 0)
local BLACK = Color3.fromRGB(10, 10, 10)
local DARK = Color3.fromRGB(18, 18, 18)
local DARK2 = Color3.fromRGB(25, 25, 25)
local DARK3 = Color3.fromRGB(32, 32, 32)

local function Tween(obj, props, duration)
	TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local gameId = game.PlaceId
local gameName = game:GetService("MarketplaceService"):GetProductInfo(gameId).Name

print("🎮 Game Detected: " .. gameName)
if not string.find(string.lower(gameName), "rival") then
	warn("⚠️ This script is designed for Rivals!")
	return
end
print("✅ Rivals detected! Loading GGEZ Hub V3...")

-- [[ Config ]]
local Config = {
	Aimbot = false,
	ESP = false,
	WallCheck = false,
	TeamCheck = false,
	KillCheck = true,
	FOV = 200,
	LockSpeed = 15,
	NoShadows = false,
	NoFog = false,
	NoParticles = false,
	LowGraphics = false,
	NoDecorations = false,
}

local OriginalLighting = {
	GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd,
	FogStart = Lighting.FogStart,
}

-- [[ Main UI ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GGEZ_Ultimate"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local BlurEffect = Instance.new("BlurEffect", Lighting)
BlurEffect.Size = 0
BlurEffect.Name = "GGEZ_Blur"

-- FOV Circle
local FOVCircle = Instance.new("Frame", ScreenGui)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.ZIndex = 5
local FOVStroke = Instance.new("UIStroke", FOVCircle)
FOVStroke.Color = YELLOW
FOVStroke.Thickness = 2.5
FOVStroke.Transparency = 0.4
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)
local FOVGradient = Instance.new("UIGradient", FOVCircle)
FOVGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, YELLOW),
	ColorSequenceKeypoint.new(0.5, YELLOW_BRIGHT),
	ColorSequenceKeypoint.new(1, YELLOW)
}
spawn(function()
	while true do
		for i = 0, 360, 3 do
			if not FOVCircle or not FOVCircle.Parent then break end
			FOVGradient.Rotation = i
			task.wait(0.02)
		end
	end
end)

-- Crosshair
local Crosshair = Instance.new("Frame", ScreenGui)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
Crosshair.Size = UDim2.new(0, 4, 0, 4)
Crosshair.BackgroundColor3 = YELLOW
Crosshair.ZIndex = 10
Instance.new("UICorner", Crosshair).CornerRadius = UDim.new(1, 0)

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 640)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -320)
MainFrame.BackgroundColor3 = DARK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 20)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = YELLOW
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 80)
Header.BackgroundColor3 = YELLOW
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 20)
local HG = Instance.new("UIGradient", Header)
HG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, YELLOW), ColorSequenceKeypoint.new(0.5, YELLOW_BRIGHT), ColorSequenceKeypoint.new(1, YELLOW_DARK)}
HG.Rotation = 45

local Logo = Instance.new("TextLabel", Header)
Logo.Size = UDim2.new(0, 60, 0, 60)
Logo.Position = UDim2.new(0, 15, 0.5, -30)
Logo.Text = "GG"
Logo.TextColor3 = YELLOW
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 28
Logo.BackgroundColor3 = BLACK
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -160, 0, 35)
Title.Position = UDim2.new(0, 85, 0, 15)
Title.Text = "GGEZ HUB V3"
Title.TextColor3 = BLACK
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local Subtitle = Instance.new("TextLabel", Header)
Subtitle.Size = UDim2.new(1, -160, 0, 20)
Subtitle.Position = UDim2.new(0, 85, 0, 50)
Subtitle.Text = "RIVALS EDITION • ULTIMATE"
Subtitle.TextColor3 = BLACK
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.BackgroundTransparency = 1
Subtitle.TextTransparency = 0.3

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 45, 0, 45)
CloseBtn.Position = UDim2.new(1, -60, 0.5, -22.5)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = YELLOW
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.BackgroundColor3 = BLACK
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 12)
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundTransparency = 0, Rotation = 90}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundTransparency = 0.2, Rotation = 0}) end)
CloseBtn.MouseButton1Click:Connect(function()
	Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)})
	Tween(BlurEffect, {Size = 0})
	task.wait(0.3)
	MainFrame.Visible = false
end)

-- Status Panel
local StatusPanel = Instance.new("Frame", MainFrame)
StatusPanel.Size = UDim2.new(0.92, 0, 0, 90)
StatusPanel.Position = UDim2.new(0.04, 0, 0, 95)
StatusPanel.BackgroundColor3 = DARK3
Instance.new("UICorner", StatusPanel).CornerRadius = UDim.new(0, 12)
local SS = Instance.new("UIStroke", StatusPanel)
SS.Color = YELLOW; SS.Thickness = 1; SS.Transparency = 0.6

local StatusLabel = Instance.new("TextLabel", StatusPanel)
StatusLabel.Size = UDim2.new(1, -20, 1, -20)
StatusLabel.Position = UDim2.new(0, 10, 0, 10)
StatusLabel.Text = "🔍 Initializing..."
StatusLabel.TextColor3 = YELLOW
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 13
StatusLabel.TextWrapped = true
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.BackgroundTransparency = 1

-- Container
local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -210)
Container.Position = UDim2.new(0, 10, 0, 200)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 6
Container.ScrollBarImageColor3 = YELLOW
Container.BorderSizePixel = 0
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 12)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
end)

local function AddCategory(name, icon)
	local cat = Instance.new("TextLabel", Container)
	cat.Size = UDim2.new(0.95, 0, 0, 35)
	cat.Text = icon .. "  " .. name
	cat.TextColor3 = YELLOW
	cat.Font = Enum.Font.GothamBold
	cat.TextSize = 15
	cat.TextXAlignment = Enum.TextXAlignment.Left
	cat.BackgroundTransparency = 1
	local ul = Instance.new("Frame", cat)
	ul.Size = UDim2.new(0, 3, 0, 20)
	ul.Position = UDim2.new(0, 0, 0.5, -10)
	ul.BackgroundColor3 = YELLOW
	Instance.new("UICorner", ul).CornerRadius = UDim.new(1, 0)
end

local function CreateToggle(name, key, desc, icon)
	local frame = Instance.new("Frame", Container)
	frame.Size = UDim2.new(0.95, 0, 0, 75)
	frame.BackgroundColor3 = DARK2
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
	local fs = Instance.new("UIStroke", frame)
	fs.Color = Config[key] and YELLOW or Color3.fromRGB(50,50,50)
	fs.Thickness = 1.5; fs.Transparency = 0.6
	local il = Instance.new("TextLabel", frame)
	il.Size = UDim2.new(0,45,0,45); il.Position = UDim2.new(0,12,0.5,-22.5)
	il.Text = icon; il.TextColor3 = Config[key] and YELLOW or Color3.fromRGB(150,150,150)
	il.Font = Enum.Font.GothamBold; il.TextSize = 20
	il.BackgroundColor3 = BLACK
	Instance.new("UICorner", il).CornerRadius = UDim.new(0, 10)
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1,-130,0,25); lbl.Position = UDim2.new(0,65,0,12)
	lbl.Text = name; lbl.TextColor3 = Color3.new(1,1,1)
	lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.BackgroundTransparency = 1
	local dl = Instance.new("TextLabel", frame)
	dl.Size = UDim2.new(1,-130,0,25); dl.Position = UDim2.new(0,65,0,40)
	dl.Text = desc; dl.TextColor3 = Color3.fromRGB(120,120,120)
	dl.Font = Enum.Font.Gotham; dl.TextSize = 11
	dl.TextXAlignment = Enum.TextXAlignment.Left; dl.BackgroundTransparency = 1
	local sbg = Instance.new("Frame", frame)
	sbg.Size = UDim2.new(0,55,0,28); sbg.Position = UDim2.new(1,-65,0.5,-14)
	sbg.BackgroundColor3 = Config[key] and YELLOW or Color3.fromRGB(40,40,40)
	Instance.new("UICorner", sbg).CornerRadius = UDim.new(1, 0)
	local sk = Instance.new("Frame", sbg)
	sk.Size = UDim2.new(0,22,0,22)
	sk.Position = Config[key] and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,3,0.5,-11)
	sk.BackgroundColor3 = Config[key] and BLACK or Color3.new(0.8,0.8,0.8)
	Instance.new("UICorner", sk).CornerRadius = UDim.new(1, 0)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
	btn.MouseButton1Click:Connect(function()
		Config[key] = not Config[key]
		Tween(sbg, {BackgroundColor3 = Config[key] and YELLOW or Color3.fromRGB(40,40,40)})
		Tween(sk, {Position = Config[key] and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,3,0.5,-11), BackgroundColor3 = Config[key] and BLACK or Color3.new(0.8,0.8,0.8)})
		Tween(fs, {Color = Config[key] and YELLOW or Color3.fromRGB(50,50,50)})
		Tween(il, {TextColor3 = Config[key] and YELLOW or Color3.fromRGB(150,150,150)})
		Tween(frame, {Size = UDim2.new(0.95,0,0,70)}, 0.1)
		task.wait(0.1)
		Tween(frame, {Size = UDim2.new(0.95,0,0,75)}, 0.1)
	end)
	btn.MouseEnter:Connect(function() Tween(fs,{Transparency=0.3}) Tween(frame,{BackgroundColor3=DARK3}) end)
	btn.MouseLeave:Connect(function() Tween(fs,{Transparency=0.6}) Tween(frame,{BackgroundColor3=DARK2}) end)
end

local function CreateSlider(name, key, min, max, default, icon)
	local frame = Instance.new("Frame", Container)
	frame.Size = UDim2.new(0.95,0,0,70); frame.BackgroundColor3 = DARK2
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
	local fs = Instance.new("UIStroke", frame)
	fs.Color = Color3.fromRGB(50,50,50); fs.Thickness = 1.5; fs.Transparency = 0.6
	local il = Instance.new("TextLabel", frame)
	il.Size = UDim2.new(0,40,0,40); il.Position = UDim2.new(0,12,0,10)
	il.Text = icon; il.TextColor3 = YELLOW
	il.Font = Enum.Font.GothamBold; il.TextSize = 18
	il.BackgroundColor3 = BLACK
	Instance.new("UICorner", il).CornerRadius = UDim.new(0, 10)
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1,-140,0,25); lbl.Position = UDim2.new(0,60,0,12)
	lbl.Text = name; lbl.TextColor3 = Color3.new(1,1,1)
	lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.BackgroundTransparency = 1
	local vl = Instance.new("TextLabel", frame)
	vl.Size = UDim2.new(0,70,0,25); vl.Position = UDim2.new(1,-80,0,12)
	vl.Text = tostring(default); vl.TextColor3 = YELLOW
	vl.Font = Enum.Font.GothamBold; vl.TextSize = 16
	vl.TextXAlignment = Enum.TextXAlignment.Right; vl.BackgroundTransparency = 1
	local sbg = Instance.new("Frame", frame)
	sbg.Size = UDim2.new(0.85,0,0,8); sbg.Position = UDim2.new(0.075,0,1,-20)
	sbg.BackgroundColor3 = Color3.fromRGB(35,35,35)
	Instance.new("UICorner", sbg).CornerRadius = UDim.new(1, 0)
	local sf = Instance.new("Frame", sbg)
	sf.Size = UDim2.new((default-min)/(max-min),0,1,0); sf.BackgroundColor3 = YELLOW
	Instance.new("UICorner", sf).CornerRadius = UDim.new(1, 0)
	local sg = Instance.new("UIGradient", sf)
	sg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,YELLOW_DARK), ColorSequenceKeypoint.new(1,YELLOW_BRIGHT)}
	local sk = Instance.new("Frame", sbg)
	sk.Size = UDim2.new(0,20,0,20); sk.Position = UDim2.new((default-min)/(max-min),-10,0.5,-10)
	sk.BackgroundColor3 = YELLOW; sk.ZIndex = 3
	Instance.new("UICorner", sk).CornerRadius = UDim.new(1, 0)
	local sBtn = Instance.new("TextButton", sbg)
	sBtn.Size = UDim2.new(1,20,1,20); sBtn.Position = UDim2.new(0,-10,0,-10)
	sBtn.BackgroundTransparency = 1; sBtn.Text = ""; sBtn.ZIndex = 4
	local dragging = false
	local function updateSlider()
		local rel = math.clamp((UserInputService:GetMouseLocation().X - sbg.AbsolutePosition.X) / sbg.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (rel*(max-min)))
		sf.Size = UDim2.new(rel,0,1,0); sk.Position = UDim2.new(rel,-10,0.5,-10)
		vl.Text = tostring(value); Config[key] = value
		if key == "FOV" then FOVCircle.Size = UDim2.new(0,value*2,0,value*2) end
	end
	sBtn.MouseButton1Down:Connect(function() dragging=true updateSlider() Tween(fs,{Transparency=0.3,Color=YELLOW}) end)
	RunService.RenderStepped:Connect(function() if dragging then updateSlider() end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false Tween(fs,{Transparency=0.6,Color=Color3.fromRGB(50,50,50)}) end end)
	frame.MouseEnter:Connect(function() Tween(frame,{BackgroundColor3=DARK3}) end)
	frame.MouseLeave:Connect(function() Tween(frame,{BackgroundColor3=DARK2}) end)
end

-- Build UI
AddCategory("VISUAL SETTINGS", "🎨")
CreateSlider("FOV Circle", "FOV", 50, 500, Config.FOV, "⭕")
CreateSlider("Lock Smoothness", "LockSpeed", 1, 50, Config.LockSpeed, "⚡")
AddCategory("COMBAT FEATURES", "⚔️")
CreateToggle("Aimbot", "Aimbot", "Auto-aim at nearest enemy", "🎯")
CreateToggle("Kill Detection", "KillCheck", "Skip eliminated players", "💀")
CreateToggle("Wall Check", "WallCheck", "Only target visible enemies", "🧱")
CreateToggle("Team Check", "TeamCheck", "Ignore your teammates", "👥")
AddCategory("VISUAL FEATURES", "👁️")
CreateToggle("ESP Overlay", "ESP", "Highlight players through walls", "✨")
AddCategory("FPS BOOST", "🚀")
CreateToggle("No Shadows", "NoShadows", "ปิด Shadow ลด GPU load", "🌑")
CreateToggle("No Fog", "NoFog", "ปิด Fog เห็นไกลขึ้น", "🌫️")
CreateToggle("No Particles", "NoParticles", "ปิด Effect/ควัน/ไฟ", "✨")
CreateToggle("Low Graphics", "LowGraphics", "ลด Quality ทุกอย่าง", "📉")
CreateToggle("No Decorations", "NoDecorations", "ลบ Accessory ผู้เล่นอื่น", "🗑️")

-- Draggable
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging=true; dragStart=input.Position; startPos=MainFrame.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
	if input==dragInput and dragging then
		local d=input.Position-dragStart
		Tween(MainFrame,{Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)},0.1)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,70,0,70); ToggleBtn.Position = UDim2.new(0.5,-35,0,30)
ToggleBtn.Text = ""; ToggleBtn.BackgroundColor3 = BLACK; ToggleBtn.BorderSizePixel = 0
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)
local TBS = Instance.new("UIStroke", ToggleBtn); TBS.Color=YELLOW; TBS.Thickness=3
local TBG = Instance.new("UIGradient", ToggleBtn)
TBG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,YELLOW_DARK),ColorSequenceKeypoint.new(1,YELLOW_BRIGHT)}
TBG.Rotation=45
local BtnLabel = Instance.new("TextLabel", ToggleBtn)
BtnLabel.Size=UDim2.new(1,0,1,0); BtnLabel.Text="GG"; BtnLabel.TextColor3=BLACK
BtnLabel.Font=Enum.Font.GothamBold; BtnLabel.TextSize=22; BtnLabel.BackgroundTransparency=1
ToggleBtn.MouseEnter:Connect(function() Tween(ToggleBtn,{Size=UDim2.new(0,80,0,80)}) Tween(BtnLabel,{TextSize=26}) end)
ToggleBtn.MouseLeave:Connect(function() Tween(ToggleBtn,{Size=UDim2.new(0,70,0,70)}) Tween(BtnLabel,{TextSize=22}) end)
ToggleBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
	if MainFrame.Visible then
		MainFrame.Size = UDim2.new(0,0,0,0)
		Tween(MainFrame,{Size=UDim2.new(0,380,0,640)})
		Tween(BlurEffect,{Size=5})
	else
		Tween(MainFrame,{Size=UDim2.new(0,0,0,0)})
		Tween(BlurEffect,{Size=0})
	end
end)

-- Aimbot
local function GetNearestPlayer()
	local nearest, shortest = nil, Config.FOV
	local sc = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	for _,player in pairs(Players:GetPlayers()) do
		if player==LocalPlayer then continue end
		local char=player.Character; if not char then continue end
		local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then continue end
		if Config.KillCheck and hum.Health<=0 then continue end
		if Config.TeamCheck and player.Team==LocalPlayer.Team then continue end
		local tp=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"); if not tp then continue end
		local sp,os=Camera:WorldToViewportPoint(tp.Position); if not os then continue end
		local dist=(Vector2.new(sp.X,sp.Y)-sc).Magnitude
		if dist>Config.FOV then continue end
		if Config.WallCheck then
			local ray=Ray.new(Camera.CFrame.Position,(tp.Position-Camera.CFrame.Position))
			local part=workspace:FindPartOnRayWithIgnoreList(ray,{LocalPlayer.Character,char})
			if part and not part:IsDescendantOf(char) then continue end
		end
		if dist<shortest then nearest=tp; shortest=dist end
	end
	return nearest
end

-- FPS Boost
RunService.Heartbeat:Connect(function()
	Lighting.GlobalShadows = not Config.NoShadows and OriginalLighting.GlobalShadows or false
	if Config.NoFog then Lighting.FogEnd=100000; Lighting.FogStart=99999
	else Lighting.FogEnd=OriginalLighting.FogEnd; Lighting.FogStart=OriginalLighting.FogStart end
	if Config.NoParticles then
		for _,obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
				obj.Enabled=false
			end
		end
	end
	if Config.LowGraphics then settings().Rendering.QualityLevel=1
	else settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic end
	if Config.NoDecorations then
		for _,player in pairs(Players:GetPlayers()) do
			if player~=LocalPlayer and player.Character then
				for _,obj in pairs(player.Character:GetDescendants()) do
					if obj:IsA("Accessory") or obj:IsA("Hat") then obj:Destroy() end
				end
			end
		end
	end
end)

-- Main Loop
local targetLocked=false; local lastUpdate=tick(); local playerCount=0
RunService.RenderStepped:Connect(function()
	FOVCircle.Visible=Config.Aimbot
	FOVCircle.Size=UDim2.new(0,Config.FOV*2,0,Config.FOV*2)
	Crosshair.Visible=Config.Aimbot
	if tick()-lastUpdate>0.5 then
		lastUpdate=tick(); playerCount=0
		for _,p in pairs(Players:GetPlayers()) do
			if p~=LocalPlayer and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then playerCount=playerCount+1 end
		end
		local boostCount=0
		for _,k in pairs({"NoShadows","NoFog","NoParticles","LowGraphics","NoDecorations"}) do
			if Config[k] then boostCount=boostCount+1 end
		end
		local st = Config.Aimbot and ("🎯 AIMBOT ACTIVE | 👥 "..playerCount.."\n"..(targetLocked and "🔒 LOCKED" or "🔍 SEARCHING...")) or ("⏸️ AIMBOT OFF | 👥 Players: "..playerCount)
		if boostCount>0 then st=st.."\n🚀 FPS BOOST: "..boostCount.." active" end
		StatusLabel.Text=st
	end
	targetLocked=false
	if Config.Aimbot then
		local target=GetNearestPlayer()
		if target then
			targetLocked=true
			Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,target.Position),1-(Config.LockSpeed/100))
			FOVStroke.Transparency=0.2; Crosshair.BackgroundColor3=Color3.fromRGB(255,255,0)
		else
			FOVStroke.Transparency=0.4; Crosshair.BackgroundColor3=YELLOW
		end
	end
	if Config.ESP then
		for _,player in pairs(Players:GetPlayers()) do
			if player~=LocalPlayer and player.Character then
				local hl=player.Character:FindFirstChild("GGEZ_ESP")
				if not hl then hl=Instance.new("Highlight"); hl.Name="GGEZ_ESP"; hl.Parent=player.Character end
				hl.Enabled=true; hl.FillTransparency=0.5; hl.OutlineTransparency=0
				if Config.TeamCheck and player.Team==LocalPlayer.Team then
					hl.FillColor=Color3.fromRGB(0,220,100); hl.OutlineColor=Color3.fromRGB(0,220,100)
				else hl.FillColor=YELLOW; hl.OutlineColor=YELLOW_BRIGHT end
			end
		end
	else
		for _,player in pairs(Players:GetPlayers()) do
			if player.Character then
				local hl=player.Character:FindFirstChild("GGEZ_ESP")
				if hl then hl:Destroy() end
			end
		end
	end
end)

print("✅ GGEZ Hub V3 Loaded!")
print("⚔️ Combat | 👁️ ESP | 🚀 FPS Boost")
print("🎮 Click GG button to open menu")
