-- [[ GGEZ HUB V3 - RIVALS EDITION ]]
repeat task.wait() until game:IsLoaded()

local gameId = game.PlaceId
local gameName = game:GetService("MarketplaceService"):GetProductInfo(gameId).Name

print("🎮 Game Detected: " .. gameName)
print("🆔 Place ID: " .. gameId)

if not string.find(string.lower(gameName), "rival") then
	warn("⚠️ This script is designed for Rivals!")
	warn("❌ Current game: " .. gameName)
	warn("🚫 Script will not load.")
	return
end

print("✅ Rivals detected! Loading GGEZ Hub V3...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ Config ]]
local Config = {
	-- Combat
	Aimbot = false,
	KillCheck = true,
	WallCheck = false,
	TeamCheck = false,
	FOV = 200,
	LockSpeed = 15,
	-- Visual
	ESP = false,
	ESPDistance = false,
	ESPHealthBar = false,
	Tracer = false,
	Chams = false,
	-- Movement
	SpeedHack = false,
	SpeedValue = 32,
	InfiniteJump = false,
	NoClip = false,
}

-- สีหลัก Yellow-Black Theme
local YELLOW = Color3.fromRGB(255, 220, 0)
local YELLOW_BRIGHT = Color3.fromRGB(255, 235, 50)
local YELLOW_DARK = Color3.fromRGB(200, 160, 0)
local BLACK = Color3.fromRGB(10, 10, 10)
local DARK = Color3.fromRGB(18, 18, 18)
local DARK2 = Color3.fromRGB(25, 25, 25)
local DARK3 = Color3.fromRGB(32, 32, 32)

-- [[ Animation Helper ]]
local function Tween(obj, props, duration)
	TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

-- [[ Notification System ]]
local function Notify(title, msg, color)
	local notifGui = Instance.new("ScreenGui")
	notifGui.Name = "GGEZ_Notif"
	notifGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	notifGui.ResetOnSpawn = false

	local notifFrame = Instance.new("Frame", notifGui)
	notifFrame.Size = UDim2.new(0, 260, 0, 65)
	notifFrame.Position = UDim2.new(1, 10, 1, -80)
	notifFrame.BackgroundColor3 = DARK2
	notifFrame.BorderSizePixel = 0
	Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 12)

	local notifStroke = Instance.new("UIStroke", notifFrame)
	notifStroke.Color = color or YELLOW
	notifStroke.Thickness = 2
	notifStroke.Transparency = 0.3

	local bar = Instance.new("Frame", notifFrame)
	bar.Size = UDim2.new(0, 4, 1, -10)
	bar.Position = UDim2.new(0, 8, 0, 5)
	bar.BackgroundColor3 = color or YELLOW
	bar.BorderSizePixel = 0
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

	local titleLabel = Instance.new("TextLabel", notifFrame)
	titleLabel.Size = UDim2.new(1, -25, 0, 25)
	titleLabel.Position = UDim2.new(0, 20, 0, 8)
	titleLabel.Text = title
	titleLabel.TextColor3 = color or YELLOW
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 13
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1

	local msgLabel = Instance.new("TextLabel", notifFrame)
	msgLabel.Size = UDim2.new(1, -25, 0, 20)
	msgLabel.Position = UDim2.new(0, 20, 0, 34)
	msgLabel.Text = msg
	msgLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	msgLabel.Font = Enum.Font.Gotham
	msgLabel.TextSize = 11
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.BackgroundTransparency = 1

	Tween(notifFrame, {Position = UDim2.new(1, -275, 1, -80)}, 0.4)
	task.wait(3)
	Tween(notifFrame, {Position = UDim2.new(1, 10, 1, -80)}, 0.4)
	task.wait(0.5)
	notifGui:Destroy()
end

-- [[ UI Setup ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GGEZ_Ultimate"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local BlurEffect = Instance.new("BlurEffect", game:GetService("Lighting"))
BlurEffect.Size = 0
BlurEffect.Name = "GGEZ_Blur"

-- FOV Circle
local FOVCircle = Instance.new("Frame", ScreenGui)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.ZIndex = 5
FOVCircle.Visible = false

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
FOVGradient.Rotation = 0

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
Crosshair.Visible = false
Instance.new("UICorner", Crosshair).CornerRadius = UDim.new(1, 0)

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 390, 0, 680)
MainFrame.Position = UDim2.new(0.5, -195, 0.5, -340)
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

local HeaderGradient = Instance.new("UIGradient", Header)
HeaderGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, YELLOW),
	ColorSequenceKeypoint.new(0.5, YELLOW_BRIGHT),
	ColorSequenceKeypoint.new(1, YELLOW_DARK)
}
HeaderGradient.Rotation = 45

local Logo = Instance.new("TextLabel", Header)
Logo.Size = UDim2.new(0, 60, 0, 60)
Logo.Position = UDim2.new(0, 15, 0.5, -30)
Logo.Text = "GG"
Logo.TextColor3 = YELLOW
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 28
Logo.BackgroundColor3 = BLACK
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 15)
local logoStroke = Instance.new("UIStroke", Logo)
logoStroke.Thickness = 2
logoStroke.Color = YELLOW
logoStroke.Transparency = 0.3

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
StatusPanel.Size = UDim2.new(0.92, 0, 0, 65)
StatusPanel.Position = UDim2.new(0.04, 0, 0, 95)
StatusPanel.BackgroundColor3 = DARK3
Instance.new("UICorner", StatusPanel).CornerRadius = UDim.new(0, 12)
local StatusStroke = Instance.new("UIStroke", StatusPanel)
StatusStroke.Color = YELLOW
StatusStroke.Thickness = 1
StatusStroke.Transparency = 0.6

local StatusLabel = Instance.new("TextLabel", StatusPanel)
StatusLabel.Size = UDim2.new(1, -20, 1, -10)
StatusLabel.Position = UDim2.new(0, 10, 0, 5)
StatusLabel.Text = "🔍 Initializing..."
StatusLabel.TextColor3 = YELLOW
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 12
StatusLabel.TextWrapped = true
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.BackgroundTransparency = 1

-- Container
local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -180)
Container.Position = UDim2.new(0, 10, 0, 173)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 5
Container.ScrollBarImageColor3 = YELLOW
Container.BorderSizePixel = 0

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
end)

-- [[ UI Components ]]
local function AddCategory(name, icon)
	local cat = Instance.new("TextLabel", Container)
	cat.Size = UDim2.new(0.95, 0, 0, 30)
	cat.Text = icon .. "  " .. name
	cat.TextColor3 = YELLOW
	cat.Font = Enum.Font.GothamBold
	cat.TextSize = 13
	cat.TextXAlignment = Enum.TextXAlignment.Left
	cat.BackgroundTransparency = 1
	local underline = Instance.new("Frame", cat)
	underline.Size = UDim2.new(0, 3, 0, 16)
	underline.Position = UDim2.new(0, 0, 0.5, -8)
	underline.BackgroundColor3 = YELLOW
	Instance.new("UICorner", underline).CornerRadius = UDim.new(1, 0)
end

local function CreateToggle(name, key, desc, icon)
	local frame = Instance.new("Frame", Container)
	frame.Size = UDim2.new(0.95, 0, 0, 70)
	frame.BackgroundColor3 = DARK2
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

	local frameStroke = Instance.new("UIStroke", frame)
	frameStroke.Color = Config[key] and YELLOW or Color3.fromRGB(50, 50, 50)
	frameStroke.Thickness = 1.5
	frameStroke.Transparency = 0.6

	local iconLabel = Instance.new("TextLabel", frame)
	iconLabel.Size = UDim2.new(0, 42, 0, 42)
	iconLabel.Position = UDim2.new(0, 12, 0.5, -21)
	iconLabel.Text = icon
	iconLabel.TextColor3 = Config[key] and YELLOW or Color3.fromRGB(100, 100, 100)
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 19
	iconLabel.BackgroundColor3 = BLACK
	Instance.new("UICorner", iconLabel).CornerRadius = UDim.new(0, 10)

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, -130, 0, 24)
	label.Position = UDim2.new(0, 62, 0, 11)
	label.Text = name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1

	local descLabel = Instance.new("TextLabel", frame)
	descLabel.Size = UDim2.new(1, -130, 0, 20)
	descLabel.Position = UDim2.new(0, 62, 0, 37)
	descLabel.Text = desc
	descLabel.TextColor3 = Color3.fromRGB(110, 110, 110)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 10
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.BackgroundTransparency = 1

	local switchBG = Instance.new("Frame", frame)
	switchBG.Size = UDim2.new(0, 52, 0, 26)
	switchBG.Position = UDim2.new(1, -63, 0.5, -13)
	switchBG.BackgroundColor3 = Config[key] and YELLOW or Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", switchBG).CornerRadius = UDim.new(1, 0)

	local switchKnob = Instance.new("Frame", switchBG)
	switchKnob.Size = UDim2.new(0, 20, 0, 20)
	switchKnob.Position = Config[key] and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
	switchKnob.BackgroundColor3 = Config[key] and BLACK or Color3.new(0.8, 0.8, 0.8)
	Instance.new("UICorner", switchKnob).CornerRadius = UDim.new(1, 0)

	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""

	btn.MouseButton1Click:Connect(function()
		Config[key] = not Config[key]
		Tween(switchBG, {BackgroundColor3 = Config[key] and YELLOW or Color3.fromRGB(40, 40, 40)})
		Tween(switchKnob, {
			Position = Config[key] and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
			BackgroundColor3 = Config[key] and BLACK or Color3.new(0.8, 0.8, 0.8)
		})
		Tween(frameStroke, {Color = Config[key] and YELLOW or Color3.fromRGB(50, 50, 50)})
		Tween(iconLabel, {TextColor3 = Config[key] and YELLOW or Color3.fromRGB(100, 100, 100)})
		Tween(frame, {Size = UDim2.new(0.95, 0, 0, 66)}, 0.1)
		task.wait(0.1)
		Tween(frame, {Size = UDim2.new(0.95, 0, 0, 70)}, 0.1)
		spawn(function()
			Notify(name, Config[key] and "✅ เปิดแล้ว" or "❌ ปิดแล้ว", Config[key] and YELLOW or Color3.fromRGB(150,150,150))
		end)
	end)

	btn.MouseEnter:Connect(function() Tween(frameStroke, {Transparency = 0.3}) Tween(frame, {BackgroundColor3 = DARK3}) end)
	btn.MouseLeave:Connect(function() Tween(frameStroke, {Transparency = 0.6}) Tween(frame, {BackgroundColor3 = DARK2}) end)
end

local function CreateSlider(name, key, min, max, default, icon)
	local frame = Instance.new("Frame", Container)
	frame.Size = UDim2.new(0.95, 0, 0, 65)
	frame.BackgroundColor3 = DARK2
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

	local frameStroke = Instance.new("UIStroke", frame)
	frameStroke.Color = Color3.fromRGB(50, 50, 50)
	frameStroke.Thickness = 1.5
	frameStroke.Transparency = 0.6

	local iconLabel = Instance.new("TextLabel", frame)
	iconLabel.Size = UDim2.new(0, 38, 0, 38)
	iconLabel.Position = UDim2.new(0, 12, 0, 8)
	iconLabel.Text = icon
	iconLabel.TextColor3 = YELLOW
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 17
	iconLabel.BackgroundColor3 = BLACK
	Instance.new("UICorner", iconLabel).CornerRadius = UDim.new(0, 10)

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, -140, 0, 22)
	label.Position = UDim2.new(0, 58, 0, 10)
	label.Text = name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1

	local valueLabel = Instance.new("TextLabel", frame)
	valueLabel.Size = UDim2.new(0, 65, 0, 22)
	valueLabel.Position = UDim2.new(1, -75, 0, 10)
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = YELLOW
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 15
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.BackgroundTransparency = 1

	local sliderBG = Instance.new("Frame", frame)
	sliderBG.Size = UDim2.new(0.85, 0, 0, 7)
	sliderBG.Position = UDim2.new(0.075, 0, 1, -16)
	sliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", sliderBG).CornerRadius = UDim.new(1, 0)

	local sliderFill = Instance.new("Frame", sliderBG)
	sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	sliderFill.BackgroundColor3 = YELLOW
	Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
	local sg = Instance.new("UIGradient", sliderFill)
	sg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, YELLOW_DARK), ColorSequenceKeypoint.new(1, YELLOW_BRIGHT)}

	local sliderKnob = Instance.new("Frame", sliderBG)
	sliderKnob.Size = UDim2.new(0, 18, 0, 18)
	sliderKnob.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
	sliderKnob.BackgroundColor3 = YELLOW
	sliderKnob.ZIndex = 3
	Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

	local sliderButton = Instance.new("TextButton", sliderBG)
	sliderButton.Size = UDim2.new(1, 20, 1, 20)
	sliderButton.Position = UDim2.new(0, -10, 0, -10)
	sliderButton.BackgroundTransparency = 1
	sliderButton.Text = ""
	sliderButton.ZIndex = 4

	local dragging = false

	local function updateSlider()
		local mouseX = UserInputService:GetMouseLocation().X
		local rel = math.clamp((mouseX - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (rel * (max - min)))
		sliderFill.Size = UDim2.new(rel, 0, 1, 0)
		sliderKnob.Position = UDim2.new(rel, -9, 0.5, -9)
		valueLabel.Text = tostring(value)
		Config[key] = value
		if key == "FOV" then FOVCircle.Size = UDim2.new(0, value * 2, 0, value * 2) end
	end

	sliderButton.MouseButton1Down:Connect(function()
		dragging = true
		updateSlider()
		Tween(frameStroke, {Transparency = 0.3, Color = YELLOW})
		Tween(sliderKnob, {Size = UDim2.new(0, 22, 0, 22)}, 0.1)
	end)
	RunService.RenderStepped:Connect(function()
		if dragging then updateSlider() end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			Tween(frameStroke, {Transparency = 0.6, Color = Color3.fromRGB(50, 50, 50)})
			Tween(sliderKnob, {Size = UDim2.new(0, 18, 0, 18)}, 0.1)
		end
	end)
	frame.MouseEnter:Connect(function() Tween(frame, {BackgroundColor3 = DARK3}) end)
	frame.MouseLeave:Connect(function() Tween(frame, {BackgroundColor3 = DARK2}) end)
end

-- [[ Build UI ]]
AddCategory("COMBAT FEATURES", "⚔️")
CreateToggle("Aimbot", "Aimbot", "Auto-aim at nearest enemy", "🎯")
CreateToggle("Kill Detection", "KillCheck", "Skip eliminated players", "💀")
CreateToggle("Wall Check", "WallCheck", "Only target visible enemies", "🧱")
CreateToggle("Team Check", "TeamCheck", "Ignore your teammates", "👥")
CreateSlider("FOV Circle", "FOV", 50, 500, Config.FOV, "⭕")
CreateSlider("Lock Smoothness", "LockSpeed", 1, 50, Config.LockSpeed, "⚡")

AddCategory("VISUAL FEATURES", "👁️")
CreateToggle("ESP Overlay", "ESP", "Highlight players through walls", "✨")
CreateToggle("ESP Distance", "ESPDistance", "Show distance to each player", "📏")
CreateToggle("ESP Health Bar", "ESPHealthBar", "Show enemy HP above head", "❤️")
CreateToggle("Tracer Lines", "Tracer", "Draw lines to all enemies", "📡")
CreateToggle("Chams", "Chams", "Make enemies glow bright", "🌟")

AddCategory("MOVEMENT FEATURES", "🏃")
CreateToggle("Speed Hack", "SpeedHack", "Move faster than normal", "⚡")
CreateSlider("Speed Value", "SpeedValue", 16, 150, Config.SpeedValue, "💨")
CreateToggle("Infinite Jump", "InfiniteJump", "Jump unlimited times", "🦘")
CreateToggle("No Clip", "NoClip", "Walk through walls", "👻")

-- [[ Draggable ]]
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = input.Position; startPos = MainFrame.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		Tween(MainFrame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- [[ Toggle Button ]]
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 70, 0, 70)
ToggleBtn.Position = UDim2.new(0.5, -35, 0, 30)
ToggleBtn.Text = ""
ToggleBtn.BackgroundColor3 = BLACK
ToggleBtn.BorderSizePixel = 0
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local ToggleBtnStroke = Instance.new("UIStroke", ToggleBtn)
ToggleBtnStroke.Color = YELLOW
ToggleBtnStroke.Thickness = 3

local ToggleBtnGradient = Instance.new("UIGradient", ToggleBtn)
ToggleBtnGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, YELLOW_DARK),
	ColorSequenceKeypoint.new(1, YELLOW_BRIGHT)
}
ToggleBtnGradient.Rotation = 45

local BtnLabel = Instance.new("TextLabel", ToggleBtn)
BtnLabel.Size = UDim2.new(1, 0, 1, 0)
BtnLabel.Text = "GG"
BtnLabel.TextColor3 = BLACK
BtnLabel.Font = Enum.Font.GothamBold
BtnLabel.TextSize = 22
BtnLabel.BackgroundTransparency = 1

local btnDragging, btnDragInput, btnDragStart, btnStartPos
ToggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		btnDragging = true; btnDragStart = input.Position; btnStartPos = ToggleBtn.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then btnDragInput = input end
	if input == btnDragInput and btnDragging then
		local delta = input.Position - btnDragStart
		Tween(ToggleBtn, {Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)}, 0.1)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then btnDragging = false end
end)

ToggleBtn.MouseEnter:Connect(function() Tween(ToggleBtn, {Size = UDim2.new(0, 80, 0, 80)}) Tween(BtnLabel, {TextSize = 26}) end)
ToggleBtn.MouseLeave:Connect(function() Tween(ToggleBtn, {Size = UDim2.new(0, 70, 0, 70)}) Tween(BtnLabel, {TextSize = 22}) end)
ToggleBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
	if MainFrame.Visible then
		MainFrame.Size = UDim2.new(0, 0, 0, 0)
		Tween(MainFrame, {Size = UDim2.new(0, 390, 0, 680)})
		Tween(BlurEffect, {Size = 5})
	else
		Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)})
		Tween(BlurEffect, {Size = 0})
		task.wait(0.3)
	end
end)

-- [[ AIMBOT ]]
local function GetNearestPlayer()
	local nearestPlayer = nil
	local shortestDistance = Config.FOV
	local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	for _, player in pairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		local character = player.Character
		if not character then continue end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then continue end
		if Config.KillCheck and humanoid.Health <= 0 then continue end
		if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
		local targetPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
		if not targetPart then continue end
		local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
		if not onScreen then continue end
		local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
		if distance > Config.FOV then continue end
		if Config.WallCheck then
			local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position))
			local part = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, character})
			if part and not part:IsDescendantOf(character) then continue end
		end
		if distance < shortestDistance then
			nearestPlayer = targetPart
			shortestDistance = distance
		end
	end
	return nearestPlayer
end

-- [[ MOVEMENT ]]
RunService.Heartbeat:Connect(function()
	local character = LocalPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	if Config.SpeedHack then
		humanoid.WalkSpeed = Config.SpeedValue
	else
		if humanoid.WalkSpeed ~= 16 then
			humanoid.WalkSpeed = 16
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if Config.InfiniteJump then
		local character = LocalPlayer.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

RunService.Stepped:Connect(function()
	if Config.NoClip then
		local character = LocalPlayer.Character
		if not character then return end
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end
end)

-- [[ MAIN RENDER LOOP ]]
local TracerLines = {}
local targetLocked = false
local lastUpdate = tick()
local playerCount = 0

RunService.RenderStepped:Connect(function()
	FOVCircle.Visible = Config.Aimbot
	Crosshair.Visible = Config.Aimbot

	-- Status
	if tick() - lastUpdate > 0.5 then
		lastUpdate = tick()
		playerCount = 0
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
				playerCount = playerCount + 1
			end
		end
		local statusParts = {}
		if Config.Aimbot then table.insert(statusParts, "🎯 AIMBOT") end
		if Config.ESP then table.insert(statusParts, "👁️ ESP") end
		if Config.SpeedHack then table.insert(statusParts, "⚡ SPEED x" .. Config.SpeedValue) end
		if Config.InfiniteJump then table.insert(statusParts, "🦘 INF JUMP") end
		if Config.NoClip then table.insert(statusParts, "👻 NOCLIP") end
		if #statusParts > 0 then
			StatusLabel.Text = table.concat(statusParts, " • ") .. "\n👥 " .. playerCount .. " players" .. (targetLocked and " | 🔒 LOCKED" or "")
		else
			StatusLabel.Text = "⏸️ All features OFF\n👥 Players in game: " .. playerCount
		end
	end

	-- Aimbot
	targetLocked = false
	if Config.Aimbot then
		local target = GetNearestPlayer()
		if target then
			targetLocked = true
			local aimCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
			Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, 1 - (Config.LockSpeed / 100))
			FOVStroke.Transparency = 0.2
			Crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
		else
			FOVStroke.Transparency = 0.4
			Crosshair.BackgroundColor3 = YELLOW
		end
	end

	-- Clear old tracers
	for _, line in pairs(TracerLines) do
		if line and line.Parent then line:Destroy() end
	end
	TracerLines = {}

	-- Per-player visual
	for _, player in pairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		local character = player.Character
		if not character then continue end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart or not humanoid then continue end

		local isEnemy = not Config.TeamCheck or player.Team ~= LocalPlayer.Team
		local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

		-- ESP Highlight
		local highlight = character:FindFirstChild("GGEZ_ESP")
		if Config.ESP then
			if not highlight then
				highlight = Instance.new("Highlight")
				highlight.Name = "GGEZ_ESP"
				highlight.Parent = character
			end
			highlight.Enabled = true
			highlight.FillTransparency = 0.6
			highlight.OutlineTransparency = 0
			highlight.FillColor = isEnemy and YELLOW or Color3.fromRGB(0, 220, 100)
			highlight.OutlineColor = isEnemy and YELLOW_BRIGHT or Color3.fromRGB(0, 220, 100)
		else
			if highlight then highlight:Destroy() end
		end

		-- Chams
		if Config.Chams then
			for _, part in pairs(character:GetDescendants()) do
				if (part:IsA("BasePart") or part:IsA("MeshPart")) and not part:FindFirstChild("GGEZ_Chams") then
					local selBox = Instance.new("SelectionBox")
					selBox.Name = "GGEZ_Chams"
					selBox.Adornee = part
					selBox.Color3 = YELLOW_BRIGHT
					selBox.LineThickness = 0.05
					selBox.SurfaceTransparency = 0.7
					selBox.SurfaceColor3 = YELLOW
					selBox.Parent = part
				end
			end
		else
			for _, part in pairs(character:GetDescendants()) do
				local chams = part:FindFirstChild("GGEZ_Chams")
				if chams then chams:Destroy() end
			end
		end

		if not onScreen then continue end

		-- ESP Distance
		if Config.ESPDistance then
			local dist = math.floor((Camera.CFrame.Position - rootPart.Position).Magnitude)
			local distGui = character:FindFirstChild("GGEZ_Dist")
			if not distGui then
				distGui = Instance.new("BillboardGui")
				distGui.Name = "GGEZ_Dist"
				distGui.Size = UDim2.new(0, 80, 0, 20)
				distGui.StudsOffset = Vector3.new(0, 3.5, 0)
				distGui.AlwaysOnTop = true
				distGui.Parent = rootPart
				local lbl = Instance.new("TextLabel", distGui)
				lbl.Name = "Label"
				lbl.Size = UDim2.new(1, 0, 1, 0)
				lbl.BackgroundTransparency = 1
				lbl.TextColor3 = YELLOW
				lbl.Font = Enum.Font.GothamBold
				lbl.TextSize = 12
			end
			local lbl = distGui:FindFirstChild("Label")
			if lbl then lbl.Text = dist .. " studs" end
		else
			local distGui = character:FindFirstChild("GGEZ_Dist")
			if distGui then distGui:Destroy() end
		end

		-- ESP Health Bar
		if Config.ESPHealthBar then
			local hpGui = character:FindFirstChild("GGEZ_HP")
			if not hpGui then
				hpGui = Instance.new("BillboardGui")
				hpGui.Name = "GGEZ_HP"
				hpGui.Size = UDim2.new(0, 60, 0, 8)
				hpGui.StudsOffset = Vector3.new(0, 2.5, 0)
				hpGui.AlwaysOnTop = true
				hpGui.Parent = rootPart
				local bgBar = Instance.new("Frame", hpGui)
				bgBar.Name = "BG"
				bgBar.Size = UDim2.new(1, 0, 1, 0)
				bgBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				Instance.new("UICorner", bgBar).CornerRadius = UDim.new(1, 0)
				local fillBar = Instance.new("Frame", bgBar)
				fillBar.Name = "Fill"
				fillBar.Size = UDim2.new(1, 0, 1, 0)
				fillBar.BackgroundColor3 = YELLOW
				Instance.new("UICorner", fillBar).CornerRadius = UDim.new(1, 0)
			end
			local fill = hpGui.BG and hpGui.BG:FindFirstChild("Fill")
			if fill then
				local hpRatio = humanoid.Health / math.max(humanoid.MaxHealth, 1)
				Tween(fill, {Size = UDim2.new(hpRatio, 0, 1, 0)}, 0.2)
				fill.BackgroundColor3 = hpRatio > 0.5 and YELLOW or Color3.fromRGB(255, 80, 80)
			end
		else
			local hpGui = character:FindFirstChild("GGEZ_HP")
			if hpGui then hpGui:Destroy() end
		end

		-- Tracer Lines
		if Config.Tracer and isEnemy then
			local line = Instance.new("Frame", ScreenGui)
			line.BackgroundColor3 = YELLOW
			line.BackgroundTransparency = 0.3
			line.BorderSizePixel = 0
			line.ZIndex = 2
			local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			local target2D = Vector2.new(screenPos.X, screenPos.Y)
			local dir = target2D - screenCenter
			local length = dir.Magnitude
			local angle = math.atan2(dir.Y, dir.X)
			line.Size = UDim2.new(0, length, 0, 2)
			line.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
			line.Rotation = math.deg(angle)
			line.AnchorPoint = Vector2.new(0, 0.5)
			table.insert(TracerLines, line)
		end
	end
end)

-- Startup
task.wait(1)
spawn(function()
	Notify("GGEZ Hub V3", "โหลดสำเร็จ! กด GG เพื่อเปิดเมนู 🎮", YELLOW)
end)
print("✅ GGEZ Hub V3 Loaded!")
print("⚔️ Combat | 👁️ Visual | 🏃 Movement")
print("🎮 Click GG button to open menu")
