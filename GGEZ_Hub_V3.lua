-- [[ GGEZ HUB V3 - RIVALS EDITION ]]
repeat task.wait() until game:IsLoaded()

-- เช็คว่าอยู่ในเกม Rivals หรือไม่
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

print("✅ Rivals detected! Loading GGEZ Hub...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ Config ]]
local Config = {
	Aimbot = false,
	ESP = false,
	WallCheck = false,
	TeamCheck = false,
	KillCheck = true,
	FOV = 200,
	LockSpeed = 15
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

-- [[ UI Setup ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GGEZ_Ultimate"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Background Blur
local BlurEffect = Instance.new("BlurEffect", game:GetService("Lighting"))
BlurEffect.Size = 0
BlurEffect.Name = "GGEZ_Blur"

-- FOV Circle (Yellow Theme)
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

-- Animated gradient for FOV
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

-- Crosshair Dot
local Crosshair = Instance.new("Frame", ScreenGui)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
Crosshair.Size = UDim2.new(0, 4, 0, 4)
Crosshair.BackgroundColor3 = YELLOW
Crosshair.ZIndex = 10
Instance.new("UICorner", Crosshair).CornerRadius = UDim.new(1, 0)

-- Main Frame (Yellow-Black Design)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 580)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -290)
MainFrame.BackgroundColor3 = DARK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = false

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 20)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = YELLOW
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3

local MainGradient = Instance.new("UIGradient", MainFrame)
MainGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, DARK),
	ColorSequenceKeypoint.new(1, DARK2)
}
MainGradient.Rotation = 135

-- Glow Effect
local Glow = Instance.new("ImageLabel", MainFrame)
Glow.Size = UDim2.new(1, 40, 1, 40)
Glow.Position = UDim2.new(0.5, -20, 0.5, -20)
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
Glow.ImageColor3 = YELLOW
Glow.ImageTransparency = 0.9
Glow.ZIndex = 0

-- Header (Yellow-Black)
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 80)
Header.BackgroundColor3 = YELLOW
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 20)

local HeaderGradient = Instance.new("UIGradient", Header)
HeaderGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, YELLOW),
	ColorSequenceKeypoint.new(0.5, YELLOW_BRIGHT),
	ColorSequenceKeypoint.new(1, YELLOW_DARK)
}
HeaderGradient.Rotation = 45

-- Logo/Icon
local Logo = Instance.new("TextLabel", Header)
Logo.Size = UDim2.new(0, 60, 0, 60)
Logo.Position = UDim2.new(0, 15, 0.5, -30)
Logo.Text = "GG"
Logo.TextColor3 = YELLOW
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 28
Logo.BackgroundColor3 = BLACK
Logo.BackgroundTransparency = 0
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 15)
local logoStroke = Instance.new("UIStroke", Logo)
logoStroke.Thickness = 2
logoStroke.Color = YELLOW
logoStroke.Transparency = 0.3

-- Title
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

-- Close Button
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

local CloseBtnCorner = Instance.new("UICorner", CloseBtn)
CloseBtnCorner.CornerRadius = UDim.new(0, 12)

CloseBtn.MouseEnter:Connect(function()
	Tween(CloseBtn, {BackgroundTransparency = 0, Rotation = 90})
end)

CloseBtn.MouseLeave:Connect(function()
	Tween(CloseBtn, {BackgroundTransparency = 0.2, Rotation = 0})
end)

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

local StatusStroke = Instance.new("UIStroke", StatusPanel)
StatusStroke.Color = YELLOW
StatusStroke.Thickness = 1
StatusStroke.Transparency = 0.6

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

-- Category Label
local function AddCategory(name, icon)
	local cat = Instance.new("TextLabel", Container)
	cat.Size = UDim2.new(0.95, 0, 0, 35)
	cat.Text = icon .. "  " .. name
	cat.TextColor3 = YELLOW
	cat.Font = Enum.Font.GothamBold
	cat.TextSize = 15
	cat.TextXAlignment = Enum.TextXAlignment.Left
	cat.BackgroundTransparency = 1
	
	local underline = Instance.new("Frame", cat)
	underline.Size = UDim2.new(0, 3, 0, 20)
	underline.Position = UDim2.new(0, 0, 0.5, -10)
	underline.BackgroundColor3 = YELLOW
	Instance.new("UICorner", underline).CornerRadius = UDim.new(1, 0)
end

-- Toggle Function (Yellow-Black Theme)
local function CreateToggle(name, key, desc, icon)
	local frame = Instance.new("Frame", Container)
	frame.Size = UDim2.new(0.95, 0, 0, 75)
	frame.BackgroundColor3 = DARK2

	local frameCorner = Instance.new("UICorner", frame)
	frameCorner.CornerRadius = UDim.new(0, 12)

	local frameStroke = Instance.new("UIStroke", frame)
	frameStroke.Color = Config[key] and YELLOW or Color3.fromRGB(50, 50, 50)
	frameStroke.Thickness = 1.5
	frameStroke.Transparency = 0.6

	-- Icon
	local iconLabel = Instance.new("TextLabel", frame)
	iconLabel.Size = UDim2.new(0, 45, 0, 45)
	iconLabel.Position = UDim2.new(0, 12, 0.5, -22.5)
	iconLabel.Text = icon
	iconLabel.TextColor3 = Config[key] and YELLOW or Color3.fromRGB(100, 100, 100)
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 20
	iconLabel.BackgroundColor3 = BLACK
	Instance.new("UICorner", iconLabel).CornerRadius = UDim.new(0, 10)

	-- Label
	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, -130, 0, 25)
	label.Position = UDim2.new(0, 65, 0, 12)
	label.Text = name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1

	-- Description
	local descLabel = Instance.new("TextLabel", frame)
	descLabel.Size = UDim2.new(1, -130, 0, 25)
	descLabel.Position = UDim2.new(0, 65, 0, 40)
	descLabel.Text = desc
	descLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.BackgroundTransparency = 1

	-- Toggle Switch (Yellow-Black Modern)
	local switchBG = Instance.new("Frame", frame)
	switchBG.Size = UDim2.new(0, 55, 0, 28)
	switchBG.Position = UDim2.new(1, -65, 0.5, -14)
	switchBG.BackgroundColor3 = Config[key] and YELLOW or Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", switchBG).CornerRadius = UDim.new(1, 0)

	local switchKnob = Instance.new("Frame", switchBG)
	switchKnob.Size = UDim2.new(0, 22, 0, 22)
	switchKnob.Position = Config[key] and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
	switchKnob.BackgroundColor3 = Config[key] and BLACK or Color3.new(0.8, 0.8, 0.8)
	Instance.new("UICorner", switchKnob).CornerRadius = UDim.new(1, 0)

	local knobShadow = Instance.new("UIStroke", switchKnob)
	knobShadow.Thickness = 3
	knobShadow.Color = Color3.fromRGB(0, 0, 0)
	knobShadow.Transparency = 0.8

	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""

	btn.MouseButton1Click:Connect(function()
		Config[key] = not Config[key]

		Tween(switchBG, {BackgroundColor3 = Config[key] and YELLOW or Color3.fromRGB(40, 40, 40)})
		Tween(switchKnob, {
			Position = Config[key] and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11),
			BackgroundColor3 = Config[key] and BLACK or Color3.new(0.8, 0.8, 0.8)
		})
		Tween(frameStroke, {Color = Config[key] and YELLOW or Color3.fromRGB(50, 50, 50)})
		Tween(iconLabel, {TextColor3 = Config[key] and YELLOW or Color3.fromRGB(100, 100, 100)})

		-- Bounce effect
		Tween(frame, {Size = UDim2.new(0.95, 0, 0, 70)}, 0.1)
		task.wait(0.1)
		Tween(frame, {Size = UDim2.new(0.95, 0, 0, 75)}, 0.1)

		print("🔧 " .. name .. ": " .. (Config[key] and "ON" or "OFF"))
	end)

	btn.MouseEnter:Connect(function()
		Tween(frameStroke, {Transparency = 0.3})
		Tween(frame, {BackgroundColor3 = DARK3})
	end)

	btn.MouseLeave:Connect(function()
		Tween(frameStroke, {Transparency = 0.6})
		Tween(frame, {BackgroundColor3 = DARK2})
	end)
end

-- Slider Function (Yellow-Black Theme)
local function CreateSlider(name, key, min, max, default, icon)
	local frame = Instance.new("Frame", Container)
	frame.Size = UDim2.new(0.95, 0, 0, 70)
	frame.BackgroundColor3 = DARK2

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

	local frameStroke = Instance.new("UIStroke", frame)
	frameStroke.Color = Color3.fromRGB(50, 50, 50)
	frameStroke.Thickness = 1.5
	frameStroke.Transparency = 0.6

	-- Icon
	local iconLabel = Instance.new("TextLabel", frame)
	iconLabel.Size = UDim2.new(0, 40, 0, 40)
	iconLabel.Position = UDim2.new(0, 12, 0, 10)
	iconLabel.Text = icon
	iconLabel.TextColor3 = YELLOW
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 18
	iconLabel.BackgroundColor3 = BLACK
	Instance.new("UICorner", iconLabel).CornerRadius = UDim.new(0, 10)

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, -140, 0, 25)
	label.Position = UDim2.new(0, 60, 0, 12)
	label.Text = name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1

	local valueLabel = Instance.new("TextLabel", frame)
	valueLabel.Size = UDim2.new(0, 70, 0, 25)
	valueLabel.Position = UDim2.new(1, -80, 0, 12)
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = YELLOW
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 16
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.BackgroundTransparency = 1

	local sliderBG = Instance.new("Frame", frame)
	sliderBG.Size = UDim2.new(0.85, 0, 0, 8)
	sliderBG.Position = UDim2.new(0.075, 0, 1, -20)
	sliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", sliderBG).CornerRadius = UDim.new(1, 0)

	local sliderFill = Instance.new("Frame", sliderBG)
	sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	sliderFill.BackgroundColor3 = YELLOW
	Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

	local sliderGradient = Instance.new("UIGradient", sliderFill)
	sliderGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, YELLOW_DARK),
		ColorSequenceKeypoint.new(1, YELLOW_BRIGHT)
	}

	-- ลูกบอล
	local sliderKnob = Instance.new("Frame", sliderBG)
	sliderKnob.Size = UDim2.new(0, 20, 0, 20)
	sliderKnob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
	sliderKnob.BackgroundColor3 = YELLOW
	sliderKnob.BorderSizePixel = 0
	sliderKnob.ZIndex = 3
	Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

	local knobShadow = Instance.new("UIStroke", sliderKnob)
	knobShadow.Thickness = 3
	knobShadow.Color = Color3.fromRGB(0, 0, 0)
	knobShadow.Transparency = 0.6

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
		sliderKnob.Position = UDim2.new(rel, -10, 0.5, -10)
		valueLabel.Text = tostring(value)
		Config[key] = value

		if key == "FOV" then
			FOVCircle.Size = UDim2.new(0, value * 2, 0, value * 2)
		end
	end

	sliderButton.MouseButton1Down:Connect(function()
		dragging = true
		updateSlider()
		Tween(frameStroke, {Transparency = 0.3, Color = YELLOW})
		Tween(sliderKnob, {Size = UDim2.new(0, 24, 0, 24)}, 0.1)
	end)

	game:GetService("RunService").RenderStepped:Connect(function()
		if dragging then
			updateSlider()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			Tween(frameStroke, {Transparency = 0.6, Color = Color3.fromRGB(50, 50, 50)})
			Tween(sliderKnob, {Size = UDim2.new(0, 20, 0, 20)}, 0.1)
		end
	end)

	frame.MouseEnter:Connect(function()
		Tween(frame, {BackgroundColor3 = DARK3})
	end)

	frame.MouseLeave:Connect(function()
		Tween(frame, {BackgroundColor3 = DARK2})
	end)
end

-- Create UI Elements
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

-- Draggable
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		Tween(MainFrame, {Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)}, 0.1)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Toggle Button (Yellow-Black Premium)
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

-- Button Draggable
local btnDragging, btnDragInput, btnDragStart, btnStartPos

ToggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		btnDragging = true
		btnDragStart = input.Position
		btnStartPos = ToggleBtn.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		btnDragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == btnDragInput and btnDragging then
		local delta = input.Position - btnDragStart
		Tween(ToggleBtn, {Position = UDim2.new(
			btnStartPos.X.Scale,
			btnStartPos.X.Offset + delta.X,
			btnStartPos.Y.Scale,
			btnStartPos.Y.Offset + delta.Y
		)}, 0.1)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		btnDragging = false
	end
end)

ToggleBtn.MouseEnter:Connect(function()
	Tween(ToggleBtn, {Size = UDim2.new(0, 80, 0, 80)})
	Tween(BtnLabel, {TextSize = 26})
end)

ToggleBtn.MouseLeave:Connect(function()
	Tween(ToggleBtn, {Size = UDim2.new(0, 70, 0, 70)})
	Tween(BtnLabel, {TextSize = 22})
end)

ToggleBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible

	if MainFrame.Visible then
		MainFrame.Size = UDim2.new(0, 0, 0, 0)
		Tween(MainFrame, {Size = UDim2.new(0, 380, 0, 580)})
		Tween(BlurEffect, {Size = 5})
	else
		Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)})
		Tween(BlurEffect, {Size = 0})
		task.wait(0.3)
	end

	print("🎮 Menu " .. (MainFrame.Visible and "OPENED" or "CLOSED"))
end)

-- [[ AIMBOT LOGIC ]]
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

		local targetPart = character:FindFirstChild("Head")
		if not targetPart then
			targetPart = character:FindFirstChild("HumanoidRootPart")
		end
		if not targetPart then continue end

		local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
		if not onScreen then continue end

		local screenPosVector = Vector2.new(screenPos.X, screenPos.Y)
		local distance = (screenPosVector - screenCenter).Magnitude

		if distance > Config.FOV then continue end

		if Config.WallCheck then
			local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position))
			local ignoreList = {LocalPlayer.Character, character}
			local part, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)

			if part then
				if not part:IsDescendantOf(character) then
					continue
				end
			end
		end

		if distance < shortestDistance then
			nearestPlayer = targetPart
			shortestDistance = distance
		end
	end

	return nearestPlayer
end

-- [[ MAIN LOOP ]]
local targetLocked = false
local lastUpdate = tick()
local playerCount = 0

RunService.RenderStepped:Connect(function()
	FOVCircle.Visible = Config.Aimbot
	FOVCircle.Size = UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
	Crosshair.Visible = Config.Aimbot

	if tick() - lastUpdate > 0.5 then
		lastUpdate = tick()
		playerCount = 0

		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
				playerCount = playerCount + 1
			end
		end

		if Config.Aimbot then
			local statusText = "🎯 AIMBOT ACTIVE\n"
			statusText = statusText .. "👥 Players: " .. playerCount .. " | FOV: " .. Config.FOV .. "\n"
			statusText = statusText .. (targetLocked and "🔒 TARGET LOCKED" or "🔍 SEARCHING...")
			StatusLabel.Text = statusText
		else
			StatusLabel.Text = "⏸️ AIMBOT DISABLED\n👥 Players: " .. playerCount
		end
	end

	targetLocked = false
	if Config.Aimbot then
		local target = GetNearestPlayer()
		if target then
			targetLocked = true
			local targetPos = target.Position
			local aimCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
			local smoothness = 1 - (Config.LockSpeed / 100)
			Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, smoothness)

			FOVStroke.Transparency = 0.2
			Crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 0)  -- Yellow เมื่อ lock
		else
			FOVStroke.Transparency = 0.4
			Crosshair.BackgroundColor3 = YELLOW
		end
	end

	if Config.ESP then
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local highlight = player.Character:FindFirstChild("GGEZ_ESP")
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "GGEZ_ESP"
					highlight.Parent = player.Character
				end

				highlight.Enabled = true
				highlight.FillTransparency = 0.5
				highlight.OutlineTransparency = 0

				if Config.TeamCheck and player.Team == LocalPlayer.Team then
					highlight.FillColor = Color3.fromRGB(0, 220, 100)
					highlight.OutlineColor = Color3.fromRGB(0, 220, 100)
				else
					highlight.FillColor = YELLOW
					highlight.OutlineColor = YELLOW_BRIGHT
				end
			end
		end
	else
		for _, player in pairs(Players:GetPlayers()) do
			if player.Character then
				local highlight = player.Character:FindFirstChild("GGEZ_ESP")
				if highlight then
					highlight:Destroy()
				end
			end
		end
	end
end)

-- Startup notification
task.wait(1)
print("✅ GGEZ Hub V3 Loaded Successfully!")
print("🎯 Optimized for Rivals")
print("📌 Press F9 to see console")
print("🎮 Click 'GG' button to open menu")
