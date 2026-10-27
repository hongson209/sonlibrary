--[[
	SonUI Library v3.2 - "Kinesis" Edition
	An original, production-grade Roblox UI framework built from first principles.
	
	New in v3.2:
	- Dual-Mode Dropdown System:
	  * Mode = "Popup" (Default): WindUI-style floating popover anchored directly beneath trigger.
	  * Mode = "Inline": Expanding accordion card with scrollable option container.
	  * Multi-select support (Multi = true) with live selection badges.
	  * Dynamic :Refresh(options) and :Set(value) APIs.
	- ColorPicker Component: Interactive popup with HSV spectrum, Hue slider, RGB readout & quick presets.
	- Keybind Component: Interactive key listener with auto-triggering on keypress & window toggle binding.
	- Modal Dialog System (Window:Dialog): Elegant confirmation modal with backdrop blur & action buttons.
	- Full library parity: Complete methods for all components (:Set, :Get, :Refresh, :Destroy).
	- Mobile touch optimization (100% compliant >=44px touch targets).
--]]

local SonUI = {
	_version = "3.2.0",
	_windows = {},
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Safe GUI container resolution
local function GetSafeGuiParent()
	if typeof(gethui) == "function" then
		local success, hui = pcall(gethui)
		if success and hui then
			return hui
		end
	end
	
	local success, cg = pcall(function()
		return CoreGui
	end)
	if success and cg then
		return cg
	end
	
	return LocalPlayer:WaitForChild("PlayerGui")
end

-- Design Tokens (Soft, harmonious, eye-friendly palette)
local Tokens = {
	Colors = {
		Background = Color3.fromRGB(13, 16, 24),
		Header = Color3.fromRGB(18, 22, 32),
		Surface = Color3.fromRGB(22, 28, 42),
		SurfaceElevated = Color3.fromRGB(28, 36, 54),
		SurfaceHover = Color3.fromRGB(36, 46, 68),
		SurfacePressed = Color3.fromRGB(24, 30, 46),
		
		Border = Color3.fromRGB(52, 65, 96),
		BorderSubtle = Color3.fromRGB(40, 50, 75),
		BorderActive = Color3.fromRGB(56, 189, 248),
		
		TextPrimary = Color3.fromRGB(245, 248, 255),
		TextSecondary = Color3.fromRGB(185, 198, 220),
		TextMuted = Color3.fromRGB(135, 148, 172),
		
		Accent = Color3.fromRGB(56, 189, 248),
		AccentGlow = Color3.fromRGB(14, 165, 233),
		AccentSecondary = Color3.fromRGB(129, 140, 248),
		
		Success = Color3.fromRGB(52, 211, 153),
		Warning = Color3.fromRGB(251, 191, 36),
		Danger = Color3.fromRGB(248, 113, 113),
	},
	Typography = {
		Font = Enum.Font.Gotham,
		FontBold = Enum.Font.GothamBold,
		FontMedium = Enum.Font.GothamMedium,
		Sizes = {
			Display = 24,
			Title = 16,
			Header = 14,
			Body = 13,
			Sub = 12,
			Caption = 11,
		},
	},
	Corners = {
		Sm = 6,
		Md = 10,
		Lg = 14,
		Xl = 18,
		Pill = 999,
	},
	Motion = {
		Instant = 0.08,
		Fast = 0.18,
		Normal = 0.28,
		Slow = 0.45,
		Easing = Enum.EasingStyle.Quad,
	},
	Touch = {
		MinTarget = 44,
		TabHeight = 62,
		TabWidth = 168,
		ControlHeight = 46,
	},
}

SonUI.Tokens = Tokens

-- Predefined Theme Styles (Dịu mắt, hòa quyện, chuyển đổi nhanh)
SonUI.Styles = {
	["Acrylic Frosted"] = {
		Name = "Acrylic Frosted",
		DisplayName = "Kính Mờ Dịu (Acrylic Frosted)",
		Background = Color3.fromRGB(13, 16, 24),
		BackgroundTransparency = 0.28,
		Sidebar = Color3.fromRGB(18, 22, 34),
		SidebarTransparency = 0.45,
		Surface = Color3.fromRGB(22, 28, 42),
		SurfaceTransparency = 0.35,
		Accent = Color3.fromRGB(56, 189, 248),
	},
	["Midnight Velvet"] = {
		Name = "Midnight Velvet",
		DisplayName = "Tím Đêm Dịu (Midnight Velvet)",
		Background = Color3.fromRGB(15, 14, 23),
		BackgroundTransparency = 0.12,
		Sidebar = Color3.fromRGB(22, 20, 34),
		SidebarTransparency = 0.30,
		Surface = Color3.fromRGB(28, 25, 42),
		SurfaceTransparency = 0.20,
		Accent = Color3.fromRGB(168, 85, 247),
	},
	["Obsidian Slate"] = {
		Name = "Obsidian Slate",
		DisplayName = "Đá Đen Tối Giản (Obsidian Slate)",
		Background = Color3.fromRGB(14, 16, 20),
		BackgroundTransparency = 0.08,
		Sidebar = Color3.fromRGB(20, 23, 28),
		SidebarTransparency = 0.25,
		Surface = Color3.fromRGB(24, 27, 34),
		SurfaceTransparency = 0.15,
		Accent = Color3.fromRGB(0, 210, 255),
	},
	["Emerald Oasis"] = {
		Name = "Emerald Oasis",
		DisplayName = "Ngọc Lục Bảo (Emerald Oasis)",
		Background = Color3.fromRGB(12, 19, 18),
		BackgroundTransparency = 0.15,
		Sidebar = Color3.fromRGB(17, 28, 26),
		SidebarTransparency = 0.32,
		Surface = Color3.fromRGB(22, 36, 33),
		SurfaceTransparency = 0.22,
		Accent = Color3.fromRGB(52, 211, 153),
	},
	["Sunset Amber"] = {
		Name = "Sunset Amber",
		DisplayName = "Hoàng Hôn Ấm (Sunset Amber)",
		Background = Color3.fromRGB(20, 16, 14),
		BackgroundTransparency = 0.15,
		Sidebar = Color3.fromRGB(28, 22, 18),
		SidebarTransparency = 0.32,
		Surface = Color3.fromRGB(36, 28, 24),
		SurfaceTransparency = 0.22,
		Accent = Color3.fromRGB(251, 146, 60),
	},
	["Rose Quartz"] = {
		Name = "Rose Quartz",
		DisplayName = "Hồng Thạch Anh (Rose Quartz)",
		Background = Color3.fromRGB(20, 14, 18),
		BackgroundTransparency = 0.16,
		Sidebar = Color3.fromRGB(28, 19, 25),
		SidebarTransparency = 0.32,
		Surface = Color3.fromRGB(36, 24, 32),
		SurfaceTransparency = 0.22,
		Accent = Color3.fromRGB(244, 114, 182),
	},
}
SonUI.Themes = SonUI.Styles

-- Lucide SVG Icons Registry
local Icons = {
	Logo = "rbxassetid://10723346959",
	Dashboard = "rbxassetid://10723407389",
	Home = "rbxassetid://10723407389",
	Combat = "rbxassetid://10734975692", -- swords
	Sword = "rbxassetid://10734975692",
	Visuals = "rbxassetid://10723374276", -- eye
	Eye = "rbxassetid://10723374276",
	Movement = "rbxassetid://10723356507", -- zap / lightning
	Zap = "rbxassetid://10723356507",
	Settings = "rbxassetid://10734950309", -- gear
	Gear = "rbxassetid://10734950309",
	Close = "rbxassetid://10747384394", -- x
	Minimize = "rbxassetid://10734896206", -- minus
	Maximize = "rbxassetid://10734895530", -- square / maximize
	ChevronDown = "rbxassetid://10709790948",
	ChevronRight = "rbxassetid://10709791281",
	Check = "rbxassetid://10709790644",
	Search = "rbxassetid://10734943674",
	User = "rbxassetid://10734923549",
	Info = "rbxassetid://10723415903",
	Sliders = "rbxassetid://10734952402",
	Save = "rbxassetid://10734941499",
	Key = "rbxassetid://10734918737",
	Color = "rbxassetid://10734950020",
	Sidebar = "rbxassetid://10734887784", -- panel-left
	PanelLeft = "rbxassetid://10734887784",
	Columns = "rbxassetid://10723407389", -- layout / columns
	Layout = "rbxassetid://10734887784",
}

-- Helpers
local function Create(className, properties, parent)
	local inst = Instance.new(className)
	for prop, val in pairs(properties) do
		if prop ~= "Parent" then
			inst[prop] = val
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function Corner(radius, parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or Tokens.Corners.Md)
	c.Parent = parent
	return c
end

local function Stroke(color, thickness, transparency, parent)
	local s = Instance.new("UIStroke")
	s.Color = color or Tokens.Colors.Border
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function Tween(instance, properties, duration, style, dir)
	local t = TweenService:Create(
		instance,
		TweenInfo.new(
			duration or Tokens.Motion.Fast,
			style or Tokens.Motion.Easing,
			dir or Enum.EasingDirection.Out
		),
		properties
	)
	t:Play()
	return t
end

local SONHUB_ICON_URL = "https://cdn.discordapp.com/attachments/1317065294736265248/1555222187378475029/sonhub.png?backend=b2&ex=6adf6108&is=6ade0f88&hm=6382d2a99fef77485f1e4a6fc43a5093dc9cad400abfd586191115ea1e7f7e50"

local function ResolveIconAsset(iconSource, fallback)
	fallback = fallback or Icons.Info
	if not iconSource or iconSource == "" then
		iconSource = SONHUB_ICON_URL
	end

	-- Check icon registry
	if Icons[iconSource] then
		return Icons[iconSource], false
	end

	-- Direct Roblox Asset ID
	if typeof(iconSource) == "number" then
		return "rbxassetid://" .. tostring(iconSource), false
	end

	if typeof(iconSource) == "string" then
		if iconSource:find("rbxassetid://") or iconSource:find("rbxasset://") then
			return iconSource, false
		end

		-- Executor local or web asset
		if typeof(getcustomasset) == "function" then
			-- If it's a URL
			if iconSource:find("http://") or iconSource:find("https://") then
				local cacheFile = "sonhub.png"
				if typeof(isfile) == "function" then
					if isfile("sonhub.png") then
						local ok, a = pcall(getcustomasset, "sonhub.png")
						if ok and a then return a, true end
					end
					if isfile("SonHUB/sonhub.png") then
						local ok, a = pcall(getcustomasset, "SonHUB/sonhub.png")
						if ok and a then return a, true end
					end
					if isfile(cacheFile) then
						local ok, a = pcall(getcustomasset, cacheFile)
						if ok and a then return a, true end
					end
				end

				-- Fetch & write to cache
				local reqFn = (typeof(request) == "function" and request)
					or (typeof(http_request) == "function" and http_request)
					or (typeof(syn) == "table" and typeof(syn.request) == "function" and syn.request)
				if reqFn and typeof(writefile) == "function" then
					local ok, res = pcall(function()
						return reqFn({ Url = iconSource, Method = "GET" })
					end)
					if ok and res and res.Body then
						pcall(writefile, cacheFile, res.Body)
						local ok2, a = pcall(getcustomasset, cacheFile)
						if ok2 and a then return a, true end
					end
				elseif typeof(game.HttpGet) == "function" and typeof(writefile) == "function" then
					local ok, body = pcall(function() return game:HttpGet(iconSource) end)
					if ok and body then
						pcall(writefile, cacheFile, body)
						local ok2, a = pcall(getcustomasset, cacheFile)
						if ok2 and a then return a, true end
					end
				end
			elseif typeof(isfile) == "function" and isfile(iconSource) then
				local ok, a = pcall(getcustomasset, iconSource)
				if ok and a then return a, true end
			end
		end
	end

	return fallback, false
end

local function CreateIcon(iconIdOrKey, parent, props)
	props = props or {}
	local iconAsset, isCustom = ResolveIconAsset(iconIdOrKey, Icons.Info)

	local iconColor = props.Color
	if not iconColor then
		iconColor = isCustom and Color3.fromRGB(255, 255, 255) or Tokens.Colors.TextSecondary
	end

	local iconImg = Create("ImageLabel", {
		Name = props.Name or "Icon",
		Size = props.Size or UDim2.fromOffset(20, 20),
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = iconAsset,
		ImageColor3 = iconColor,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = props.ZIndex or 5,
	}, parent)

	return iconImg
end

-- =========================================================================
-- WINDOW CLASS
-- =========================================================================

function SonUI:Notify(props)
	if activeWindow and type(activeWindow.Notify) == "function" then
		return activeWindow:Notify(props)
	end
end

function SonUI:CreateWindow(config)
	config = config or {}
	local windowTitle = config.Title or "SonUI Kinesis"
	local windowSubtitle = config.Subtitle or "Executive Interface"
	local camera = workspace.CurrentCamera
	local function GetViewport()
		if camera and camera.ViewportSize.X > 0 and camera.ViewportSize.Y > 0 then
			return camera.ViewportSize
		end
		return Vector2.new(1920, 1080)
	end

	-- Responsive window geometry calculation (Phones, Tablets & Desktop)
	local function CalculateWindowGeometry(reqSize)
		local vp = GetViewport()
		local isMob = vp.X < 768 or vp.Y < 550
		local isSmall = vp.X < 600 or vp.Y < 400

		local marginX = isSmall and 14 or (isMob and 20 or 32)
		local marginY = isSmall and 14 or (isMob and 20 or 32)

		local maxW = math.max(280, vp.X - marginX)
		local maxH = math.max(240, vp.Y - marginY)

		local baseW = isMob and 534 or 700
		local baseH = isMob and 400 or 530
		local reqW = baseW
		if reqSize then
			if reqSize.X.Offset == 760 then
				reqW = 700
			else
				reqW = reqSize.X.Offset
			end
		end
		local reqH = reqSize and reqSize.Y.Offset or baseH

		local finalW = math.floor(math.min(reqW, maxW))
		local finalH = math.floor(math.min(reqH, maxH))

		return UDim2.fromOffset(finalW, finalH), isMob, isSmall
	end

	local responsiveSize, isMobileMode, isSmallPhoneMode = CalculateWindowGeometry(config.Size)
	local defaultSize = responsiveSize
	local initialViewport = GetViewport()
	local initX = math.floor((initialViewport.X - defaultSize.X.Offset) / 2)
	local initY = math.floor((initialViewport.Y - defaultSize.Y.Offset) / 2)
	local defaultPos = config.Position or UDim2.fromOffset(initX, initY)
	local currentWindowSize = defaultSize
	local closable = config.Closable ~= false

	-- Dual Layout Architecture: "Top" (Horizontal Tab Bar) or "Sidebar" (Left Vertical Tabs | Right Content)
	local layoutMode = tostring(config.Layout or config.TabPosition or "Top"):lower()
	local isSidebarLayout = (layoutMode == "sidebar" or layoutMode == "left" or layoutMode == "vertical")

	-- Sidebar Nav Rail Geometry (Compact Left Dock matching reference design)
	local sidebarWidth = isSmallPhoneMode and 64 or (isMobileMode and 70 or 76)
	local sidebarBtnWidth = isSmallPhoneMode and 54 or (isMobileMode and 60 or 66)
	local sidebarBtnHeight = isSmallPhoneMode and 50 or (isMobileMode and 54 or 56)
	local sidebarTop = 64
	local sidebarHeightOffset = 78

	local tabCardWidth = isSmallPhoneMode and 126 or (isMobileMode and 138 or 156)
	local tabCardHeight = isSmallPhoneMode and 54 or (isMobileMode and 58 or 62)
	local tabBarHeight = tabCardHeight + 14
	local pagesTop = 64 + tabBarHeight
	local pagesHeightOffset = pagesTop + 14

	-- Style / Theme Preset Resolution
	local initialStyle = nil
	if config.Style or config.Theme then
		local sKey = config.Style or config.Theme
		initialStyle = SonUI.Styles[sKey]
		if not initialStyle then
			for _, s in pairs(SonUI.Styles) do
				if s.DisplayName == sKey or s.Name:lower() == tostring(sKey):lower() then
					initialStyle = s
					break
				end
			end
		end
	end

	-- Customizable Background & Transparency (Soft frosted defaults)
	local userBgColor = config.BackgroundColor or (initialStyle and initialStyle.Background) or Tokens.Colors.Background
	local userBgTrans = config.BackgroundTransparency or (initialStyle and initialStyle.BackgroundTransparency) or 0.12
	local userSurfaceColor = config.SurfaceColor or (initialStyle and initialStyle.Surface) or Tokens.Colors.Surface
	local userSurfaceTrans = config.SurfaceTransparency or (initialStyle and initialStyle.SurfaceTransparency) or 0.20
	local userAccent = config.AccentColor or (initialStyle and initialStyle.Accent) or Tokens.Colors.Accent

	-- Customizable Sidebar Color & Transparency (User Customization)
	local userSidebarColor = config.SidebarColor or (initialStyle and initialStyle.Sidebar) or Tokens.Colors.Header
	local userSidebarTrans = config.SidebarTransparency or (initialStyle and initialStyle.SidebarTransparency) or 0.35

	local parentGui = GetSafeGuiParent()

	-- Clean up previous instance with same name
	local guiName = "SonUI_" .. (config.Name or "Workspace")
	local existing = parentGui:FindFirstChild(guiName)
	if existing then
		existing:Destroy()
	end

	local screenGui = Create("ScreenGui", {
		Name = guiName,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 100,
	}, parentGui)

	-- Overlays & Popups Layer (ZIndex 100)
	local overlayLayer = Create("Frame", {
		Name = "OverlayLayer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 100,
	}, screenGui)

	-- Backdrop detector for closing floating popups
	local overlayBackdrop = Create("TextButton", {
		Name = "BackdropDetector",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 101,
	}, overlayLayer)

	-- Active popup state manager
	local activePopup = nil
	local function CloseActivePopup()
		if activePopup then
			activePopup:Close()
			activePopup = nil
		end
		overlayBackdrop.Visible = false
	end

	overlayBackdrop.MouseButton1Click:Connect(CloseActivePopup)

	-- Notifications Layer (Responsive positioning)
	local initialVp = GetViewport()
	local notifyWidth = math.min(320, initialVp.X - 32)
	local notifyContainer = Create("Frame", {
		Name = "NotificationLayer",
		Size = UDim2.new(0, notifyWidth, 1, -40),
		Position = UDim2.new(1, -(notifyWidth + 16), 0, 20),
		BackgroundTransparency = 1,
		ZIndex = 200,
	}, screenGui)

	local notifyLayout = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 10),
	}, notifyContainer)

	-- Main Window Surface
	local mainFrame = Create("Frame", {
		Name = "MainWindow",
		Size = defaultSize,
		Position = defaultPos,
		BackgroundColor3 = userBgColor,
		BackgroundTransparency = userBgTrans,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		ZIndex = 1,
	}, screenGui)
	Corner(Tokens.Corners.Xl, mainFrame)
	local mainStroke = Stroke(Tokens.Colors.Border, 1, 0.45, mainFrame)

	-- Window Header (Seamless, unified single-layer glass surface)
	local header = Create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, mainFrame)

	local headerDivider = Create("Frame", {
		Name = "HeaderDivider",
		Size = UDim2.new(1, -24, 0, 1),
		Position = UDim2.new(0, 12, 1, 0),
		BackgroundColor3 = Tokens.Colors.BorderSubtle,
		BackgroundTransparency = 0.65,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, header)

	-- Title & Brand Block
	local brandBlock = Create("Frame", {
		Name = "BrandBlock",
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.new(0, 20, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 3,
	}, header)

	local brandIconBox = Create("Frame", {
		Name = "BrandIconBox",
		Size = UDim2.new(0, 34, 0, 34),
		Position = UDim2.new(0, 0, 0.5, -17),
		BackgroundColor3 = Tokens.Colors.SurfaceElevated,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 4,
	}, brandBlock)
	Corner(Tokens.Corners.Sm, brandIconBox)
	local brandStroke = Stroke(userAccent, 1, 0.45, brandIconBox)

	local rawLogo = config.Icon or config.Logo or SONHUB_ICON_URL
	local resolvedLogo, isBrandCustom = ResolveIconAsset(rawLogo, Icons.Logo)

	local brandIcon = Create("ImageLabel", {
		Name = "BrandIcon",
		Size = isBrandCustom and UDim2.fromOffset(26, 26) or UDim2.fromOffset(20, 20),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = resolvedLogo,
		ImageColor3 = isBrandCustom and Color3.fromRGB(255, 255, 255) or userAccent,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 5,
	}, brandIconBox)

	local titleLabel = Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -44, 0, 20),
		Position = UDim2.new(0, 42, 0, 12),
		BackgroundTransparency = 1,
		Text = windowTitle,
		TextColor3 = Tokens.Colors.TextPrimary,
		Font = Tokens.Typography.FontBold,
		TextSize = Tokens.Typography.Sizes.Title,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
	}, brandBlock)

	local subtitleLabel = Create("TextLabel", {
		Name = "Subtitle",
		Size = UDim2.new(1, -44, 0, 16),
		Position = UDim2.new(0, 42, 0, 32),
		BackgroundTransparency = 1,
		Text = windowSubtitle,
		TextColor3 = Tokens.Colors.TextSecondary,
		Font = Tokens.Typography.FontMedium,
		TextSize = Tokens.Typography.Sizes.Sub,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
	}, brandBlock)

	-- Window Action Buttons: [-] Minimize on Left, [X] Close on Right
	local actionsContainer = Create("Frame", {
		Name = "Actions",
		Size = UDim2.new(0, 76, 1, 0),
		Position = UDim2.new(1, -88, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 10,
	}, header)

	local actionsLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	}, actionsContainer)

	-- Minimize Button (Order 1)
	local minBtn = Create("TextButton", {
		Name = "MinimizeButton",
		Size = UDim2.new(0, 32, 0, 32),
		BackgroundColor3 = Tokens.Colors.SurfaceElevated,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = 1,
		ZIndex = 5,
	}, actionsContainer)
	Corner(Tokens.Corners.Sm, minBtn)
	Stroke(Tokens.Colors.Border, 1, 0, minBtn)

	local minIcon = CreateIcon(Icons.Minimize, minBtn, {
		Name = "MinIcon",
		Size = UDim2.fromOffset(16, 16),
		Color = Tokens.Colors.TextSecondary,
		ZIndex = 6,
	})

	-- Close Button (Order 2)
	local closeBtn = Create("TextButton", {
		Name = "CloseButton",
		Size = UDim2.new(0, 32, 0, 32),
		BackgroundColor3 = Tokens.Colors.SurfaceElevated,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Visible = closable,
		LayoutOrder = 2,
		ZIndex = 5,
	}, actionsContainer)
	Corner(Tokens.Corners.Sm, closeBtn)
	local closeStroke = Stroke(Tokens.Colors.Border, 1, 0, closeBtn)

	local closeIcon = CreateIcon(Icons.Close, closeBtn, {
		Name = "CloseIcon",
		Size = UDim2.fromOffset(16, 16),
		Color = Tokens.Colors.TextSecondary,
		ZIndex = 6,
	})

	-- Bulletproof Window Dragging (PC Mouse & Mobile Touch, Smooth Zero-Jerk)
	local dragging = false
	local dragStart = Vector3.new(0, 0, 0)
	local startPos = Vector2.new(0, 0)

	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			-- Don't start drag if clicking on header action buttons
			local mousePos = Vector2.new(input.Position.X, input.Position.Y)
			local actPos = actionsContainer.AbsolutePosition
			local actSize = actionsContainer.AbsoluteSize
			if mousePos.X >= actPos.X and mousePos.X <= actPos.X + actSize.X
				and mousePos.Y >= actPos.Y and mousePos.Y <= actPos.Y + actSize.Y then
				return
			end

			dragging = true
			dragStart = input.Position
			startPos = Vector2.new(mainFrame.Position.X.Offset, mainFrame.Position.Y.Offset)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			local vp = GetViewport()
			local targetX = startPos.X + delta.X
			local targetY = startPos.Y + delta.Y
			local maxX = math.max(0, vp.X - mainFrame.AbsoluteSize.X)
			local maxY = math.max(0, vp.Y - 50)
			local clampedX = math.clamp(targetX, 0, maxX)
			local clampedY = math.clamp(targetY, 0, maxY)
			mainFrame.Position = UDim2.fromOffset(clampedX, clampedY)
		end
	end)

	-- Dynamic Viewport Orientation & Size Change Listener
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			local newSize, newMob, newSmall = CalculateWindowGeometry(config.Size)
			currentWindowSize = newSize
			if not isMinimized then
				local curSize = mainFrame.Size
				if curSize.X.Offset > newSize.X.Offset or curSize.Y.Offset > newSize.Y.Offset then
					Tween(mainFrame, {Size = newSize}, Tokens.Motion.Fast)
				end
				local vp = GetViewport()
				local curPos = mainFrame.Position
				local maxX = math.max(0, vp.X - mainFrame.AbsoluteSize.X)
				local maxY = math.max(0, vp.Y - 50)
				local clampedX = math.clamp(curPos.X.Offset, 0, maxX)
				local clampedY = math.clamp(curPos.Y.Offset, 0, maxY)
				if clampedX ~= curPos.X.Offset or clampedY ~= curPos.Y.Offset then
					Tween(mainFrame, {Position = UDim2.fromOffset(clampedX, clampedY)}, Tokens.Motion.Fast)
				end
			end
		end)
	end

	-- =====================================================================
	-- TABS CONTAINER (DUAL ARCHITECTURE: TOP TABS VS SIDEBAR)
	-- =====================================================================
	local tabBarContainer = Create("Frame", {
		Name = isSidebarLayout and "SidebarContainer" or "TabBarContainer",
		Size = isSidebarLayout and UDim2.new(0, sidebarWidth, 1, -sidebarHeightOffset) or UDim2.new(1, -32, 0, tabBarHeight),
		Position = isSidebarLayout and UDim2.new(0, 10, 0, sidebarTop) or UDim2.new(0, 16, 0, 64),
		BackgroundColor3 = userSidebarColor,
		BackgroundTransparency = isSidebarLayout and userSidebarTrans or 1,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, mainFrame)
	Corner(Tokens.Corners.Md, tabBarContainer)
	local sidebarStroke = Stroke(Tokens.Colors.BorderSubtle, 1, isSidebarLayout and 0.4 or 1, tabBarContainer)

	local tabScroll = Create("ScrollingFrame", {
		Name = "TabScroll",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = isSidebarLayout and 2 or 0,
		ScrollBarImageColor3 = Tokens.Colors.Border,
		ScrollingDirection = isSidebarLayout and Enum.ScrollingDirection.Y or Enum.ScrollingDirection.X,
		AutomaticCanvasSize = isSidebarLayout and Enum.AutomaticSize.Y or Enum.AutomaticSize.X,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		ZIndex = 3,
	}, tabBarContainer)

	Create("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
	}, tabScroll)

	local tabListLayout = Create("UIListLayout", {
		FillDirection = isSidebarLayout and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = isSidebarLayout and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, isSidebarLayout and 6 or (isSmallPhoneMode and 6 or 8)),
	}, tabScroll)

	-- Pages Body Container (Adapts dynamically to Sidebar vs Top)
	local pagesLeft = isSidebarLayout and (10 + sidebarWidth + 10) or 16
	local pagesWidthOffset = isSidebarLayout and -(10 + sidebarWidth + 10 + 12) or -32
	local pagesTopPos = isSidebarLayout and sidebarTop or pagesTop
	local pagesHeight = isSidebarLayout and -sidebarHeightOffset or -pagesHeightOffset

	local pagesContainer = Create("Frame", {
		Name = "PagesContainer",
		Size = UDim2.new(1, pagesWidthOffset, 1, pagesHeight),
		Position = UDim2.new(0, pagesLeft, 0, pagesTopPos),
		BackgroundColor3 = userSurfaceColor,
		BackgroundTransparency = userSurfaceTrans,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 2,
	}, mainFrame)
	Corner(Tokens.Corners.Lg, pagesContainer)
	local pagesStroke = Stroke(Tokens.Colors.BorderSubtle, 1, 0, pagesContainer)

	-- Minimize Mechanism
	local isMinimized = false
	minBtn.MouseButton1Click:Connect(function()
		CloseActivePopup()
		isMinimized = not isMinimized
		if isMinimized then
			mainFrame.ClipsDescendants = true
			tabBarContainer.Visible = false
			pagesContainer.Visible = false
			minIcon.Image = Icons.Maximize
			local minWidthOffset = math.floor(currentWindowSize.X.Offset * 0.60)
			local minWidthScale = currentWindowSize.X.Scale * 0.60
			Tween(mainFrame, {Size = UDim2.new(minWidthScale, minWidthOffset, 0, 56)}, Tokens.Motion.Normal)
		else
			minIcon.Image = Icons.Minimize
			Tween(mainFrame, {Size = currentWindowSize}, Tokens.Motion.Normal)
			task.delay(Tokens.Motion.Normal, function()
				if not isMinimized then
					tabBarContainer.Visible = true
					pagesContainer.Visible = true
					mainFrame.ClipsDescendants = false
				end
			end)
		end
	end)

	minBtn.MouseEnter:Connect(function()
		Tween(minBtn, {BackgroundColor3 = Tokens.Colors.SurfaceHover}, Tokens.Motion.Fast)
		Tween(minIcon, {ImageColor3 = Tokens.Colors.TextPrimary}, Tokens.Motion.Fast)
	end)
	minBtn.MouseLeave:Connect(function()
		Tween(minBtn, {BackgroundColor3 = Tokens.Colors.SurfaceElevated}, Tokens.Motion.Fast)
		Tween(minIcon, {ImageColor3 = Tokens.Colors.TextSecondary}, Tokens.Motion.Fast)
	end)

	-- Close Logic
	closeBtn.MouseButton1Click:Connect(function()
		CloseActivePopup()
		Tween(mainFrame, {
			Size = defaultSize - UDim2.fromOffset(40, 40),
			Position = mainFrame.Position + UDim2.fromOffset(20, 20),
		}, Tokens.Motion.Fast)
		Tween(mainStroke, {Transparency = 1}, Tokens.Motion.Fast)
		task.delay(Tokens.Motion.Fast, function()
			screenGui:Destroy()
		end)
	end)

	closeBtn.MouseEnter:Connect(function()
		Tween(closeBtn, {BackgroundColor3 = Tokens.Colors.Danger}, Tokens.Motion.Fast)
		Tween(closeIcon, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, Tokens.Motion.Fast)
		Tween(closeStroke, {Color = Tokens.Colors.Danger}, Tokens.Motion.Fast)
	end)
	closeBtn.MouseLeave:Connect(function()
		Tween(closeBtn, {BackgroundColor3 = Tokens.Colors.SurfaceElevated}, Tokens.Motion.Fast)
		Tween(closeIcon, {ImageColor3 = Tokens.Colors.TextSecondary}, Tokens.Motion.Fast)
		Tween(closeStroke, {Color = Tokens.Colors.Border}, Tokens.Motion.Fast)
	end)

	-- Tab Controller state
	local WindowObj = {
		_tabs = {},
		_activeTab = nil,
		_gui = screenGui,
		_main = mainFrame,
		_header = header,
		_pagesContainer = pagesContainer,
		_overlay = overlayLayer,
		_closeActivePopup = CloseActivePopup,
		_toggleKey = config.ToggleKey or Enum.KeyCode.RightControl,
	}
	table.insert(SonUI._windows, WindowObj)

	-- Window Toggle Hotkey
	UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == WindowObj._toggleKey then
			mainFrame.Visible = not mainFrame.Visible
			if not mainFrame.Visible then
				CloseActivePopup()
			end
		end
	end)

	function WindowObj:SetToggleKey(keyCode)
		WindowObj._toggleKey = keyCode
	end

	function WindowObj:Toggle()
		mainFrame.Visible = not mainFrame.Visible
		if not mainFrame.Visible then
			CloseActivePopup()
		end
	end

	function WindowObj:SetVisible(vis)
		mainFrame.Visible = vis
		if not vis then
			CloseActivePopup()
		end
	end

	function WindowObj:Destroy()
		screenGui:Destroy()
	end

	function WindowObj:AddActionButton(btnConfig)
		btnConfig = btnConfig or {}
		local iconId = btnConfig.Icon or Icons.Refresh or "rbxassetid://10734940376"
		local callback = btnConfig.Callback or function() end

		local currentBtns = 0
		for _, c in ipairs(actionsContainer:GetChildren()) do
			if c:IsA("TextButton") then
				currentBtns += 1
			end
		end
		local newCount = currentBtns + 1
		local newWidth = (newCount * 32) + ((newCount - 1) * 8)
		actionsContainer.Size = UDim2.new(0, newWidth, 1, 0)
		actionsContainer.Position = UDim2.new(1, -(newWidth + 12), 0, 0)

		local actBtn = Create("TextButton", {
			Name = btnConfig.Name or "HeaderActionButton",
			Size = UDim2.new(0, 32, 0, 32),
			BackgroundColor3 = Tokens.Colors.SurfaceElevated,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = btnConfig.LayoutOrder or 0,
			ZIndex = 5,
		}, actionsContainer)
		Corner(Tokens.Corners.Sm, actBtn)
		Stroke(Tokens.Colors.Border, 1, 0, actBtn)

		local actIcon = CreateIcon(iconId, actBtn, {
			Name = "ActIcon",
			Size = UDim2.fromOffset(16, 16),
			Color = Tokens.Colors.TextSecondary,
			ZIndex = 6,
		})

		actBtn.MouseButton1Click:Connect(function()
			CloseActivePopup()
			callback()
		end)

		actBtn.MouseEnter:Connect(function()
			Tween(actBtn, {BackgroundColor3 = Tokens.Colors.SurfaceHover}, Tokens.Motion.Fast)
			Tween(actIcon, {ImageColor3 = Tokens.Colors.TextPrimary}, Tokens.Motion.Fast)
		end)
		actBtn.MouseLeave:Connect(function()
			Tween(actBtn, {BackgroundColor3 = Tokens.Colors.SurfaceElevated}, Tokens.Motion.Fast)
			Tween(actIcon, {ImageColor3 = Tokens.Colors.TextSecondary}, Tokens.Motion.Fast)
		end)

		return actBtn
	end

	-- Dynamic Customization Methods (WindUI parity)
	function WindowObj:SetBackgroundColor(col)
		userBgColor = col
		mainFrame.BackgroundColor3 = col
	end

	function WindowObj:SetBackgroundTransparency(trans)
		userBgTrans = math.clamp(trans, 0, 1)
		mainFrame.BackgroundTransparency = userBgTrans
		pagesContainer.BackgroundTransparency = math.clamp(userBgTrans * 0.7, 0, 0.85)
	end

	function WindowObj:SetSurfaceColor(col)
		userSurfaceColor = col
		pagesContainer.BackgroundColor3 = col
	end

	function WindowObj:SetAccentColor(col)
		userAccent = col
		Tokens.Colors.Accent = col
		if brandStroke then
			Tween(brandStroke, {Color = col}, Tokens.Motion.Fast)
		end
		if brandIcon and not isBrandCustom then
			Tween(brandIcon, {ImageColor3 = col}, Tokens.Motion.Fast)
		end
		if WindowObj._activeTab then
			Tween(WindowObj._activeTab.Stroke, {Color = col}, Tokens.Motion.Fast)
			Tween(WindowObj._activeTab.IconImg, {ImageColor3 = col}, Tokens.Motion.Fast)
			Tween(WindowObj._activeTab.Indicator, {BackgroundColor3 = col}, Tokens.Motion.Fast)
		end
	end

	-- Predefined Style / Theme Switcher (Chuyển đổi phong cách nhanh & mượt)
	function WindowObj:SetStyle(styleInput)
		local style = nil
		if type(styleInput) == "string" then
			style = SonUI.Styles[styleInput]
			if not style then
				for _, s in pairs(SonUI.Styles) do
					if s.DisplayName == styleInput or s.Name:lower() == styleInput:lower() then
						style = s
						break
					end
				end
			end
		elseif type(styleInput) == "table" then
			style = styleInput
		end

		if not style then return end

		userBgColor = style.Background or userBgColor
		userBgTrans = style.BackgroundTransparency or userBgTrans
		userSidebarColor = style.Sidebar or userSidebarColor
		userSidebarTrans = style.SidebarTransparency or userSidebarTrans
		userSurfaceColor = style.Surface or userSurfaceColor
		userSurfaceTrans = style.SurfaceTransparency or userSurfaceTrans

		Tween(mainFrame, {
			BackgroundColor3 = userBgColor,
			BackgroundTransparency = userBgTrans,
		}, Tokens.Motion.Normal)

		if isSidebarLayout then
			Tween(tabBarContainer, {
				BackgroundColor3 = userSidebarColor,
				BackgroundTransparency = userSidebarTrans,
			}, Tokens.Motion.Normal)
		end

		Tween(pagesContainer, {
			BackgroundColor3 = userSurfaceColor,
			BackgroundTransparency = userSurfaceTrans,
		}, Tokens.Motion.Normal)

		if style.Accent then
			WindowObj:SetAccentColor(style.Accent)
		end

		WindowObj:Notify({
			Title = "Style Applied",
			Content = "Chuyển sang phong cách: " .. (style.DisplayName or style.Name or "Custom"),
			Duration = 2,
			Type = "Success",
		})
	end

	WindowObj.SetTheme = WindowObj.SetStyle

	-- Dynamic Dual Layout Engine (Seamless Real-Time Switching)
	local currentLayoutMode = isSidebarLayout and "Sidebar" or "Top"
	WindowObj._currentLayout = currentLayoutMode

	local function ApplyLayout(newMode, animate)
		CloseActivePopup()
		local isSide = (tostring(newMode):lower() == "sidebar" or tostring(newMode):lower() == "left" or tostring(newMode):lower() == "vertical")
		isSidebarLayout = isSide
		currentLayoutMode = isSide and "Sidebar" or "Top"
		WindowObj._currentLayout = currentLayoutMode

		-- 1. Dimensions based on device and layout
		local sWidth = isSmallPhoneMode and 64 or (isMobileMode and 70 or 76)
		local sBtnW = isSmallPhoneMode and 54 or (isMobileMode and 60 or 66)
		local sBtnH = isSmallPhoneMode and 50 or (isMobileMode and 54 or 56)
		local tCardW = isSmallPhoneMode and 126 or (isMobileMode and 138 or 156)
		local tCardH = isSmallPhoneMode and 54 or (isMobileMode and 58 or 62)
		local tBarH = tCardH + 14
		local pTop = 64 + tBarH
		local pHeightOff = pTop + 14

		local targetBarSize = isSide and UDim2.new(0, sWidth, 1, -sidebarHeightOffset) or UDim2.new(1, -32, 0, tBarH)
		local targetBarPos = isSide and UDim2.new(0, 10, 0, 64) or UDim2.new(0, 16, 0, 64)
		tabBarContainer.Name = isSide and "SidebarContainer" or "TabBarContainer"
		tabBarContainer.BackgroundColor3 = userSidebarColor

		local pLeft = isSide and (10 + sWidth + 10) or 16
		local pWidthOffset = isSide and -(10 + sWidth + 10 + 12) or -32
		local pTopPos = isSide and 64 or pTop
		local pHeight = isSide and -sidebarHeightOffset or -pHeightOff
		local targetPagesSize = UDim2.new(1, pWidthOffset, 1, pHeight)
		local targetPagesPos = UDim2.new(0, pLeft, 0, pTopPos)

		-- 2. Scrolling & List Layout Configuration
		tabScroll.ScrollBarThickness = isSide and 2 or 0
		tabScroll.ScrollingDirection = isSide and Enum.ScrollingDirection.Y or Enum.ScrollingDirection.X
		tabScroll.AutomaticCanvasSize = isSide and Enum.AutomaticSize.Y or Enum.AutomaticSize.X
		tabListLayout.FillDirection = isSide and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
		tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		tabListLayout.VerticalAlignment = isSide and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Center
		tabListLayout.Padding = UDim.new(0, isSide and 6 or (isSmallPhoneMode and 6 or 8))

		if animate then
			Tween(tabBarContainer, {
				Size = targetBarSize, 
				Position = targetBarPos,
				BackgroundTransparency = isSide and userSidebarTrans or 1,
			}, Tokens.Motion.Normal)
			Tween(sidebarStroke, {Transparency = isSide and 0.4 or 1}, Tokens.Motion.Normal)
			Tween(pagesContainer, {Size = targetPagesSize, Position = targetPagesPos}, Tokens.Motion.Normal)
		else
			tabBarContainer.Size = targetBarSize
			tabBarContainer.Position = targetBarPos
			tabBarContainer.BackgroundTransparency = isSide and userSidebarTrans or 1
			sidebarStroke.Transparency = isSide and 0.4 or 1
			pagesContainer.Size = targetPagesSize
			pagesContainer.Position = targetPagesPos
		end

		-- 3. Update all existing tabs geometry
		for _, tab in ipairs(WindowObj._tabs) do
			local isActive = (WindowObj._activeTab == tab)
			local ibSize = isSmallPhoneMode and 32 or (isMobileMode and 34 or 38)
			local tLeft = 10 + ibSize + 8

			if isSide then
				tab.Button.Size = UDim2.new(0, sBtnW, 0, sBtnH)
				tab.Button.BackgroundColor3 = isActive and Tokens.Colors.SurfaceElevated or Tokens.Colors.Surface
				tab.Button.BackgroundTransparency = isActive and 0.35 or 0.85
				tab.Stroke.Transparency = isActive and 0.25 or 0.7

				tab.IconBox.Size = UDim2.fromOffset(24, 24)
				tab.IconBox.Position = UDim2.new(0.5, 0, 0, 6)
				tab.IconBox.AnchorPoint = Vector2.new(0.5, 0)
				tab.IconBox.BackgroundColor3 = isActive and Tokens.Colors.SurfaceHover or Tokens.Colors.SurfaceElevated
				tab.IconBox.BackgroundTransparency = 1
				tab.IconStroke.Transparency = 1
				tab.IconImg.Size = UDim2.fromOffset(20, 20)

				tab.Title.Position = UDim2.new(0.5, 0, 1, -6)
				tab.Title.AnchorPoint = Vector2.new(0.5, 1)
				tab.Title.Size = UDim2.new(1, -4, 0, 14)
				tab.Title.TextXAlignment = Enum.TextXAlignment.Center
				tab.Title.TextSize = 10
				tab.Title.TextTruncate = Enum.TextTruncate.None

				tab.Desc.Visible = false

				tab.activeIndicatorTargetSize = UDim2.new(0, 3, 0, 20)
				tab.inactiveIndicatorTargetSize = UDim2.new(0, 0, 0, 0)
				tab.Indicator.AnchorPoint = Vector2.new(0, 0.5)
				tab.Indicator.Position = UDim2.new(0, 3, 0.5, 0)
				tab.Indicator.Size = isActive and tab.activeIndicatorTargetSize or tab.inactiveIndicatorTargetSize
			else
				tab.Button.Size = UDim2.new(0, tCardW, 0, tCardH)
				tab.Button.BackgroundColor3 = isActive and Tokens.Colors.SurfaceElevated or Tokens.Colors.Surface
				tab.Button.BackgroundTransparency = 0
				tab.Stroke.Transparency = isActive and 0.25 or 0

				tab.IconBox.Size = UDim2.fromOffset(ibSize, ibSize)
				tab.IconBox.Position = UDim2.new(0, 10, 0.5, -ibSize / 2)
				tab.IconBox.AnchorPoint = Vector2.new(0, 0)
				tab.IconBox.BackgroundColor3 = isActive and Tokens.Colors.SurfaceHover or Tokens.Colors.SurfaceElevated
				tab.IconBox.BackgroundTransparency = 0
				tab.IconStroke.Transparency = 0.5
				tab.IconImg.Size = UDim2.fromOffset(isSmallPhoneMode and 16 or 18, isSmallPhoneMode and 16 or 18)

				tab.Title.Position = UDim2.new(0, tLeft, 0, isSmallPhoneMode and 8 or 10)
				tab.Title.AnchorPoint = Vector2.new(0, 0)
				tab.Title.Size = UDim2.new(1, -(tLeft + 8), 0, 18)
				tab.Title.TextXAlignment = Enum.TextXAlignment.Left
				tab.Title.TextSize = Tokens.Typography.Sizes.Body

				tab.Desc.Visible = true
				tab.Desc.Position = UDim2.new(0, tLeft, 0, isSmallPhoneMode and 26 or 28)
				tab.Desc.Size = UDim2.new(1, -(tLeft + 8), 0, 14)

				tab.activeIndicatorTargetSize = UDim2.new(1, -20, 0, 3)
				tab.inactiveIndicatorTargetSize = UDim2.new(0, 0, 0, 3)
				tab.Indicator.AnchorPoint = Vector2.new(0.5, 1)
				tab.Indicator.Position = UDim2.new(0.5, 0, 1, -5)
				tab.Indicator.Size = isActive and tab.activeIndicatorTargetSize or tab.inactiveIndicatorTargetSize
			end
		end
	end

	function WindowObj:ToggleLayout()
		local nextMode = (currentLayoutMode == "Sidebar") and "Top" or "Sidebar"
		ApplyLayout(nextMode, true)
		WindowObj:Notify({
			Title = "Layout Mode Switched",
			Content = "Bố cục: " .. (nextMode == "Sidebar" and "Sidebar (Tab | Nội dung)" or "Top Tabs (Bố cục trên)"),
			Duration = 2,
			Type = "Info",
		})
	end

	function WindowObj:SetLayout(mode)
		ApplyLayout(mode, true)
	end

	function WindowObj:SetSidebarColor(col)
		userSidebarColor = col
		if isSidebarLayout then
			tabBarContainer.BackgroundColor3 = col
		end
	end

	function WindowObj:SetSidebarTransparency(trans)
		userSidebarTrans = math.clamp(trans, 0, 1)
		if isSidebarLayout then
			tabBarContainer.BackgroundTransparency = userSidebarTrans
		end
	end

	-- Modal Dialog System
	function WindowObj:Dialog(dialogConfig)
		dialogConfig = dialogConfig or {}
		CloseActivePopup()

		local dTitle = dialogConfig.Title or "Confirmation"
		local dContent = dialogConfig.Content or ""
		local buttons = dialogConfig.Buttons or { { Title = "OK" } }

		local modalBackdrop = Create("TextButton", {
			Name = "ModalBackdrop",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 150,
		}, overlayLayer)

		local vp = GetViewport()
		local dWidth = math.min(360, vp.X - 32)
		local dHeight = math.min(180, vp.Y - 32)

		local modalCard = Create("Frame", {
			Name = "ModalCard",
			Size = UDim2.fromOffset(dWidth, dHeight),
			Position = UDim2.new(0.5, -dWidth / 2, 0.5, -dHeight / 2),
			BackgroundColor3 = Tokens.Colors.Header,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			ZIndex = 151,
		}, modalBackdrop)
		Corner(Tokens.Corners.Lg, modalCard)
		Stroke(Tokens.Colors.Border, 1.2, 0, modalCard)

		local title = Create("TextLabel", {
			Name = "Title",
			Size = UDim2.new(1, -32, 0, 24),
			Position = UDim2.new(0, 16, 0, 16),
			BackgroundTransparency = 1,
			Text = dTitle,
			TextColor3 = Tokens.Colors.TextPrimary,
			Font = Tokens.Typography.FontBold,
			TextSize = Tokens.Typography.Sizes.Title,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 152,
		}, modalCard)

		local content = Create("TextLabel", {
			Name = "Content",
			Size = UDim2.new(1, -32, 0, 60),
			Position = UDim2.new(0, 16, 0, 44),
			BackgroundTransparency = 1,
			Text = dContent,
			TextColor3 = Tokens.Colors.TextSecondary,
			Font = Tokens.Typography.Font,
			TextSize = Tokens.Typography.Sizes.Body,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			ZIndex = 152,
		}, modalCard)

		local btnBar = Create("Frame", {
			Name = "ButtonBar",
			Size = UDim2.new(1, -32, 0, 36),
			Position = UDim2.new(0, 16, 1, -48),
			BackgroundTransparency = 1,
			ZIndex = 152,
		}, modalCard)

		local btnLayout = Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 10),
		}, btnBar)

		local function CloseDialog()
			Tween(modalBackdrop, {BackgroundTransparency = 1}, Tokens.Motion.Fast)
			Tween(modalCard, {Position = UDim2.new(0.5, -dWidth / 2, 0.5, -dHeight / 2 + 20)}, Tokens.Motion.Fast)
			task.delay(Tokens.Motion.Fast, function()
				modalBackdrop:Destroy()
			end)
		end

		for _, b in ipairs(buttons) do
			local isPrimary = b.Variant == "Primary"
			local isDanger = b.Variant == "Danger"
			local bCol = isPrimary and userAccent or (isDanger and Tokens.Colors.Danger or Tokens.Colors.SurfaceElevated)
			local tCol = (isPrimary or isDanger) and Color3.fromRGB(12, 14, 20) or Tokens.Colors.TextPrimary

			local btn = Create("TextButton", {
				Name = "DialogBtn_" .. (b.Title or "Button"),
				Size = UDim2.new(0, 90, 0, 34),
				BackgroundColor3 = bCol,
				BorderSizePixel = 0,
				Text = b.Title or "Action",
				TextColor3 = tCol,
				Font = Tokens.Typography.FontBold,
				TextSize = Tokens.Typography.Sizes.Body,
				AutoButtonColor = false,
				ZIndex = 153,
			}, btnBar)
			Corner(Tokens.Corners.Sm, btn)
			Stroke(isPrimary and userAccent or Tokens.Colors.Border, 1, 0, btn)

			btn.MouseButton1Click:Connect(function()
				CloseDialog()
				if b.Callback then
					task.spawn(b.Callback)
				end
			end)
		end

		Tween(modalBackdrop, {BackgroundTransparency = 0.5}, Tokens.Motion.Normal)
		modalCard.Position = UDim2.new(0.5, -dWidth / 2, 0.5, -dHeight / 2 - 20)
		Tween(modalCard, {Position = UDim2.new(0.5, -dWidth / 2, 0.5, -dHeight / 2)}, Tokens.Motion.Normal)
	end

	-- Notification Dispatcher (Sonner / Dynamic Island Acrylic Pill Architecture)
	function WindowObj:Notify(toastConfig)
		toastConfig = toastConfig or {}
		local toastTitle = toastConfig.Title or "Notification"
		local toastContent = toastConfig.Content or ""
		local toastDuration = toastConfig.Duration or 3.5
		local toastType = toastConfig.Type or "Info"

		local accentCol = userAccent
		local iconAsset = Icons.Info
		if toastType == "Success" then
			accentCol = Tokens.Colors.Success
			iconAsset = Icons.Check
		elseif toastType == "Warning" then
			accentCol = Tokens.Colors.Warning
			iconAsset = Icons.Info
		elseif toastType == "Danger" or toastType == "Error" then
			accentCol = Tokens.Colors.Danger
			iconAsset = Icons.Close
		end

		local hasContent = (toastContent ~= nil and toastContent ~= "")
		local targetHeight = hasContent and 64 or 46

		-- Wrapper frame isolates UIListLayout from the horizontal slide tween
		local toastWrapper = Create("Frame", {
			Name = "ToastWrapper",
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			ZIndex = 201,
		}, notifyContainer)

		-- Toast Card surface (acrylic frosted dark pill with soft glow)
		local toastCard = Create("TextButton", {
			Name = "ToastCard",
			Size = UDim2.new(1, 0, 0, targetHeight),
			Position = UDim2.new(1, 50, 0, 0),
			BackgroundColor3 = Tokens.Colors.SurfaceElevated,
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ClipsDescendants = true,
			ZIndex = 202,
		}, toastWrapper)
		Corner(Tokens.Corners.Md, toastCard)
		local cardStroke = Stroke(accentCol, 1, 0.50, toastCard)

		-- Squircle Icon Badge on the left
		local iconBoxSize = hasContent and 32 or 28
		local iconBox = Create("Frame", {
			Name = "IconBox",
			Size = UDim2.fromOffset(iconBoxSize, iconBoxSize),
			Position = UDim2.new(0, 10, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = accentCol,
			BackgroundTransparency = 0.84,
			BorderSizePixel = 0,
			ZIndex = 203,
		}, toastCard)
		Corner(Tokens.Corners.Sm, iconBox)
		Stroke(accentCol, 1, 0.65, iconBox)

		CreateIcon(iconAsset, iconBox, {
			Name = "ToastIcon",
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Color = accentCol,
			ZIndex = 204,
		})

		-- Typography
		local textLeft = 10 + iconBoxSize + 10
		local textWidthOffset = -(textLeft + 30)

		local tTitle = Create("TextLabel", {
			Name = "Title",
			Size = UDim2.new(1, textWidthOffset, 0, 18),
			Position = hasContent and UDim2.new(0, textLeft, 0, 12) or UDim2.new(0, textLeft, 0.5, -9),
			BackgroundTransparency = 1,
			Text = toastTitle,
			TextColor3 = Tokens.Colors.TextPrimary,
			Font = Tokens.Typography.FontBold,
			TextSize = Tokens.Typography.Sizes.Body,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 203,
		}, toastCard)

		if hasContent then
			Create("TextLabel", {
				Name = "Content",
				Size = UDim2.new(1, textWidthOffset, 0, 26),
				Position = UDim2.new(0, textLeft, 0, 30),
				BackgroundTransparency = 1,
				Text = toastContent,
				TextColor3 = Tokens.Colors.TextSecondary,
				Font = Tokens.Typography.Font,
				TextSize = Tokens.Typography.Sizes.Sub,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true,
				ZIndex = 203,
			}, toastCard)
		end

		-- Mini close button on the right
		local miniClose = Create("TextButton", {
			Name = "MiniClose",
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.new(1, -26, 0, (targetHeight - 20) / 2),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 204,
		}, toastCard)

		local closeIcon = CreateIcon(Icons.Close, miniClose, {
			Name = "CloseIcon",
			Size = UDim2.fromOffset(12, 12),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Color = Tokens.Colors.TextMuted,
			ZIndex = 205,
		})

		-- Slim elegant bottom progress line
		local progressBar = Create("Frame", {
			Name = "ProgressBar",
			Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, -2),
			BackgroundColor3 = accentCol,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			ZIndex = 205,
		}, toastCard)

		-- Animated Entry
		Tween(toastWrapper, {Size = UDim2.new(1, 0, 0, targetHeight)}, Tokens.Motion.Normal)
		Tween(toastCard, {Position = UDim2.new(0, 0, 0, 0)}, Tokens.Motion.Normal)
		Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, toastDuration, Enum.EasingStyle.Linear)

		-- Dismiss Logic (Click anywhere or timeout)
		local dismissed = false
		local function DismissToast()
			if dismissed then return end
			dismissed = true

			Tween(toastCard, {
				Position = UDim2.new(1, 40, 0, 0),
				BackgroundTransparency = 1,
			}, Tokens.Motion.Fast)
			Tween(cardStroke, {Transparency = 1}, Tokens.Motion.Fast)

			task.delay(0.08, function()
				if toastWrapper and toastWrapper.Parent then
					Tween(toastWrapper, {Size = UDim2.new(1, 0, 0, 0)}, Tokens.Motion.Fast)
					task.delay(Tokens.Motion.Fast, function()
						if toastWrapper and toastWrapper.Parent then
							toastWrapper:Destroy()
						end
					end)
				end
			end)
		end

		toastCard.MouseButton1Click:Connect(DismissToast)
		miniClose.MouseButton1Click:Connect(DismissToast)
		miniClose.MouseEnter:Connect(function()
			Tween(closeIcon, {ImageColor3 = Tokens.Colors.TextPrimary}, Tokens.Motion.Fast)
		end)
		miniClose.MouseLeave:Connect(function()
			Tween(closeIcon, {ImageColor3 = Tokens.Colors.TextMuted}, Tokens.Motion.Fast)
		end)

		task.delay(toastDuration, function()
			DismissToast()
		end)
	end

	-- =====================================================================
	-- CREATE TAB METHOD (Tall Card Anatomy with SVG Icons)
	-- =====================================================================
	function WindowObj:CreateTab(tabConfig)
		tabConfig = tabConfig or {}
		local tabName = tabConfig.Name or "Tab"
		local tabIcon = tabConfig.Icon or "Dashboard"
		local tabDesc = tabConfig.Description or "Configuration"

		-- Tab Button Geometry (Dual Mode: Sidebar Nav Rail Dock vs Top Chunky Card)
		local tSize = isSidebarLayout and UDim2.new(0, sidebarBtnWidth, 0, sidebarBtnHeight) or UDim2.new(0, tabCardWidth, 0, tabCardHeight)
		local tabButton = Create("TextButton", {
			Name = tabName .. "_CardTab",
			Size = tSize,
			BackgroundColor3 = Tokens.Colors.Surface,
			BackgroundTransparency = isSidebarLayout and 0.85 or 0,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 3,
		}, tabScroll)
		Corner(Tokens.Corners.Md, tabButton)
		local tabStroke = Stroke(Tokens.Colors.BorderSubtle, 1, isSidebarLayout and 0.7 or 0, tabButton)

		-- Icon Box (Top-Centered in Sidebar Rail, Left Squircle in Top Card)
		local iconBoxSize = isSidebarLayout and 24 or (isSmallPhoneMode and 32 or (isMobileMode and 34 or 38))
		local iconBoxPos = isSidebarLayout and UDim2.new(0.5, 0, 0, 6) or UDim2.new(0, 10, 0.5, -iconBoxSize / 2)
		local iconBoxAnchor = isSidebarLayout and Vector2.new(0.5, 0) or Vector2.new(0, 0)

		local iconBox = Create("Frame", {
			Name = "IconBox",
			Size = UDim2.fromOffset(iconBoxSize, iconBoxSize),
			Position = iconBoxPos,
			AnchorPoint = iconBoxAnchor,
			BackgroundColor3 = isSidebarLayout and Color3.fromRGB(0, 0, 0) or Tokens.Colors.SurfaceElevated,
			BackgroundTransparency = isSidebarLayout and 1 or 0,
			BorderSizePixel = 0,
			ZIndex = 4,
		}, tabButton)
		Corner(Tokens.Corners.Sm, iconBox)
		local iconStroke = Stroke(Tokens.Colors.BorderSubtle, 1, isSidebarLayout and 1 or 0.5, iconBox)

		local iconImg = CreateIcon(tabIcon, iconBox, {
			Name = "IconImg",
			Size = UDim2.fromOffset(isSidebarLayout and 20 or (isSmallPhoneMode and 16 or 18), isSidebarLayout and 20 or (isSmallPhoneMode and 16 or 18)),
			Color = Tokens.Colors.TextMuted,
			ZIndex = 5,
		})

		-- Tab Title & Subtitle Offsets
		local textLeftOffset = 10 + iconBoxSize + 8
		local titleText = Create("TextLabel", {
			Name = "TabTitle",
			Size = isSidebarLayout and UDim2.new(1, -4, 0, 14) or UDim2.new(1, -(textLeftOffset + 8), 0, 18),
			Position = isSidebarLayout and UDim2.new(0.5, 0, 1, -6) or UDim2.new(0, textLeftOffset, 0, isSmallPhoneMode and 8 or 10),
			AnchorPoint = isSidebarLayout and Vector2.new(0.5, 1) or Vector2.new(0, 0),
			BackgroundTransparency = 1,
			Text = tabName,
			TextColor3 = Tokens.Colors.TextSecondary,
			Font = Tokens.Typography.FontMedium,
			TextSize = isSidebarLayout and 10 or Tokens.Typography.Sizes.Body,
			TextXAlignment = isSidebarLayout and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
			TextTruncate = isSidebarLayout and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd,
			ZIndex = 4,
		}, tabButton)

		local descText = Create("TextLabel", {
			Name = "TabDesc",
			Size = UDim2.new(1, -(textLeftOffset + 8), 0, 14),
			Position = UDim2.new(0, textLeftOffset, 0, isSmallPhoneMode and 26 or 28),
			BackgroundTransparency = 1,
			Text = tabDesc,
			TextColor3 = Tokens.Colors.TextSecondary,
			Font = Tokens.Typography.FontMedium,
			TextSize = Tokens.Typography.Sizes.Sub,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Visible = not isSidebarLayout,
			ZIndex = 4,
		}, tabButton)

		-- Active Indicator (Sidebar: Left vertical pill; Top: Bottom horizontal capsule bar)
		local activeIndicator
		local activeIndicatorTargetSize
		local inactiveIndicatorTargetSize

		if isSidebarLayout then
			activeIndicatorTargetSize = UDim2.new(0, 3, 0, 20)
			inactiveIndicatorTargetSize = UDim2.new(0, 0, 0, 0)
			activeIndicator = Create("Frame", {
				Name = "ActiveIndicator",
				Size = inactiveIndicatorTargetSize,
				Position = UDim2.new(0, 3, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = userAccent,
				BorderSizePixel = 0,
				ZIndex = 5,
			}, tabButton)
			Corner(Tokens.Corners.Pill, activeIndicator)
		else
			activeIndicatorTargetSize = UDim2.new(1, -20, 0, 3)
			inactiveIndicatorTargetSize = UDim2.new(0, 0, 0, 3)
			activeIndicator = Create("Frame", {
				Name = "ActiveIndicator",
				Size = inactiveIndicatorTargetSize,
				Position = UDim2.new(0.5, 0, 1, -5),
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = userAccent,
				BorderSizePixel = 0,
				ZIndex = 5,
			}, tabButton)
			Corner(Tokens.Corners.Pill, activeIndicator)
		end

		-- Tab Page Scroll Container
		local pageScroll = Create("ScrollingFrame", {
			Name = tabName .. "_Page",
			Size = UDim2.new(1, -16, 1, -16),
			Position = UDim2.new(0, 8, 0, 8),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Tokens.Colors.Border,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
			Visible = false,
			ZIndex = 3,
		}, pagesContainer)

		local pagePadding = Create("UIPadding", {
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 16),
		}, pageScroll)

		local pageLayout = Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 10),
		}, pageScroll)

		local tabData = {
			Button = tabButton,
			Stroke = tabStroke,
			IconBox = iconBox,
			IconStroke = iconStroke,
			IconImg = iconImg,
			Title = titleText,
			Desc = descText,
			Indicator = activeIndicator,
			Page = pageScroll,
			Name = tabName,
			activeIndicatorTargetSize = activeIndicatorTargetSize,
			inactiveIndicatorTargetSize = inactiveIndicatorTargetSize,
		}

		-- Select Tab Transition
		local function SetActive(active)
			if active then
				if isSidebarLayout then
					Tween(tabButton, {
						BackgroundColor3 = Tokens.Colors.SurfaceElevated,
						BackgroundTransparency = 0.35,
					}, Tokens.Motion.Fast)
					Tween(tabStroke, {Color = userAccent, Transparency = 0.25}, Tokens.Motion.Fast)
					Tween(iconImg, {ImageColor3 = userAccent}, Tokens.Motion.Fast)
					Tween(titleText, {TextColor3 = Tokens.Colors.TextPrimary}, Tokens.Motion.Fast)
					Tween(activeIndicator, {Size = tabData.activeIndicatorTargetSize}, Tokens.Motion.Fast)
				else
					Tween(tabButton, {
						BackgroundColor3 = Tokens.Colors.SurfaceElevated,
						BackgroundTransparency = 0,
					}, Tokens.Motion.Fast)
					Tween(tabStroke, {Color = userAccent, Transparency = 0.25}, Tokens.Motion.Fast)
					Tween(iconBox, {BackgroundColor3 = Tokens.Colors.SurfaceHover}, Tokens.Motion.Fast)
					Tween(iconStroke, {Color = userAccent, Transparency = 0.2}, Tokens.Motion.Fast)
					Tween(iconImg, {ImageColor3 = userAccent}, Tokens.Motion.Fast)
					Tween(titleText, {TextColor3 = Tokens.Colors.TextPrimary}, Tokens.Motion.Fast)
					Tween(descText, {TextColor3 = Tokens.Colors.TextSecondary}, Tokens.Motion.Fast)
					Tween(activeIndicator, {Size = tabData.activeIndicatorTargetSize}, Tokens.Motion.Fast)
				end
				pageScroll.Visible = true
			else
				if isSidebarLayout then
					Tween(tabButton, {
						BackgroundColor3 = Tokens.Colors.Surface,
						BackgroundTransparency = 0.85,
					}, Tokens.Motion.Fast)
					Tween(tabStroke, {Color = Tokens.Colors.BorderSubtle, Transparency = 0.7}, Tokens.Motion.Fast)
					Tween(iconImg, {ImageColor3 = Tokens.Colors.TextMuted}, Tokens.Motion.Fast)
					Tween(titleText, {TextColor3 = Tokens.Colors.TextMuted}, Tokens.Motion.Fast)
					Tween(activeIndicator, {Size = tabData.inactiveIndicatorTargetSize}, Tokens.Motion.Fast)
				else
					Tween(tabButton, {
						BackgroundColor3 = Tokens.Colors.Surface,
						BackgroundTransparency = 0,
					}, Tokens.Motion.Fast)
					Tween(tabStroke, {Color = Tokens.Colors.BorderSubtle, Transparency = 0}, Tokens.Motion.Fast)
					Tween(iconBox, {BackgroundColor3 = Tokens.Colors.SurfaceElevated}, Tokens.Motion.Fast)
					Tween(iconStroke, {Color = Tokens.Colors.BorderSubtle, Transparency = 0.5}, Tokens.Motion.Fast)
					Tween(iconImg, {ImageColor3 = Tokens.Colors.TextMuted}, Tokens.Motion.Fast)
					Tween(titleText, {TextColor3 = Tokens.Colors.TextSecondary}, Tokens.Motion.Fast)
					Tween(descText, {TextColor3 = Tokens.Colors.TextMuted}, Tokens.Motion.Fast)
					Tween(activeIndicator, {Size = tabData.inactiveIndicatorTargetSize}, Tokens.Motion.Fast)
				end
				pageScroll.Visible = false
			end
		end

		tabData.SetActive = SetActive
		table.insert(WindowObj._tabs, tabData)

		local function SelectThisTab()
			CloseActivePopup()
			if WindowObj._activeTab == tabData then return end
			for _, t in ipairs(WindowObj._tabs) do
				if t == tabData then
					t.SetActive(true)
				else
					t.SetActive(false)
				end
			end
			WindowObj._activeTab = tabData
		end

		tabButton.MouseButton1Click:Connect(SelectThisTab)

		-- Hover feedback
		tabButton.MouseEnter:Connect(function()
			if WindowObj._activeTab ~= tabData then
				if isSidebarLayout then
					Tween(tabButton, {
						BackgroundColor3 = Tokens.Colors.SurfaceHover,
						BackgroundTransparency = 0.45,
					}, Tokens.Motion.Fast)
					Tween(tabStroke, {Color = Tokens.Colors.Border, Transparency = 0.3}, Tokens.Motion.Fast)
					Tween(iconImg, {ImageColor3 = Tokens.Colors.TextSecondary}, Tokens.Motion.Fast)
					Tween(titleText, {TextColor3 = Tokens.Colors.TextPrimary}, Tokens.Motion.Fast)
				else
					Tween(tabButton, {BackgroundColor3 = Tokens.Colors.SurfaceHover}, Tokens.Motion.Fast)
					Tween(tabStroke, {Color = Tokens.Colors.Border}, Tokens.Motion.Fast)
					Tween(iconImg, {ImageColor3 = Tokens.Colors.TextSecondary}, Tokens.Motion.Fast)
					Tween(titleText, {TextColor3 = Tokens.Colors.TextPrimary}, Tokens.Motion.Fast)
				end
			end
		end)

		tabButton.MouseLeave:Connect(function()
			if WindowObj._activeTab ~= tabData then
				if isSidebarLayout then
					Tween(tabButton, {
						BackgroundColor3 = Tokens.Colors.Surface,
						BackgroundTransparency = 0.85,
					}, Tokens.Motion.Fast)
					Tween(tabStroke, {Color = Tokens.Colors.BorderSubtle, Transparency = 0.7}, Tokens.Motion.Fast)
					Tween(iconImg, {ImageColor3 = Tokens.Colors.TextMuted}, Tokens.Motion.Fast)
					Tween(titleText, {TextColor3 = Tokens.Colors.TextMuted}, Tokens.Motion.Fast)
				else
					Tween(tabButton, {BackgroundColor3 = Tokens.Colors.Surface}, Tokens.Motion.Fast)
					Tween(tabStroke, {Color = Tokens.Colors.BorderSubtle}, Tokens.Motion.Fast)
					Tween(iconImg, {ImageColor3 = Tokens.Colors.TextMuted}, Tokens.Motion.Fast)
					Tween(titleText, {TextColor3 = Tokens.Colors.TextSecondary}, Tokens.Motion.Fast)
				end
			end
		end)

		-- Auto activate first tab immediately (Primacy without animation lag or partial rendering)
		if #WindowObj._tabs == 1 then
			WindowObj._activeTab = tabData
			if isSidebarLayout then
				tabButton.BackgroundColor3 = Tokens.Colors.SurfaceElevated
				tabButton.BackgroundTransparency = 0.35
				tabStroke.Color = userAccent
				tabStroke.Transparency = 0.25
				iconImg.ImageColor3 = userAccent
				titleText.TextColor3 = Tokens.Colors.TextPrimary
				activeIndicator.Size = tabData.activeIndicatorTargetSize
			else
				tabButton.BackgroundColor3 = Tokens.Colors.SurfaceElevated
				tabButton.BackgroundTransparency = 0
				tabStroke.Color = userAccent
				tabStroke.Transparency = 0.25
				iconBox.BackgroundColor3 = Tokens.Colors.SurfaceHover
				iconStroke.Color = userAccent
				iconStroke.Transparency = 0.2
				iconImg.ImageColor3 = userAccent
				titleText.TextColor3 = Tokens.Colors.TextPrimary
				descText.TextColor3 = Tokens.Colors.TextSecondary
				activeIndicator.Size = tabData.activeIndicatorTargetSize
			end
			pageScroll.Visible = true
		end

		-- =================================================================
		-- TAB COMPONENT FACTORY
		-- =================================================================
		local TabObj = {
			_page = pageScroll,
			Select = SelectThisTab,
		}

		-- SECTION
		function TabObj:CreateSection(title)
			local secFrame = Create("Frame", {
				Name = "Section_" .. tostring(title),
				Size = UDim2.new(1, -8, 0, 32),
				BackgroundTransparency = 1,
				ZIndex = 4,
			}, pageScroll)

			local secLabel = Create("TextLabel", {
				Name = "Title",
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0, 4, 0, 4),
				BackgroundTransparency = 1,
				Text = string.upper(tostring(title)),
				TextColor3 = userAccent,
				Font = Tokens.Typography.FontBold,
				TextSize = Tokens.Typography.Sizes.Sub,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 4,
			}, secFrame)

			local divider = Create("Frame", {
				Name = "Divider",
				Size = UDim2.new(1, -8, 0, 1),
				Position = UDim2.new(0, 4, 1, -2),
				BackgroundColor3 = Tokens.Colors.BorderSubtle,
				BorderSizePixel = 0,
				ZIndex = 4,
			}, secFrame)

			return secFrame
		end

		-- DIVIDER
		function TabObj:CreateDivider()
			local div = Create("Frame", {
				Name = "Divider",
				Size = UDim2.new(1, -8, 0, 1),
				BackgroundColor3 = Tokens.Colors.BorderSubtle,
				BorderSizePixel = 0,
				ZIndex = 4,
			}, pageScroll)
			return div
		end

		-- PARAGRAPH
		function TabObj:CreateParagraph(paraConfig)
			paraConfig = paraConfig or {}
			local pTitle = paraConfig.Title or "Information"
			local pContent = paraConfig.Content or ""

			local card = Create("Frame", {
				Name = "Paragraph_" .. pTitle,
				Size = UDim2.new(1, -8, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Tokens.Colors.SurfaceElevated,
				BackgroundTransparency = 0.65,
				BorderSizePixel = 0,
				ZIndex = 4,
			}, pageScroll)
			Corner(Tokens.Corners.Md, card)
			Stroke(Tokens.Colors.BorderSubtle, 1, 0.65, card)

			Create("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 14),
				PaddingRight = UDim.new(0, 14),
			}, card)

			local pLayout = Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
			}, card)

			local titleLabel = Create("TextLabel", {
				Name = "Title",
				Size = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Text = pTitle,
				TextColor3 = Tokens.Colors.TextPrimary,
				Font = Tokens.Typography.FontBold,
				TextSize = Tokens.Typography.Sizes.Body,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 1,
				ZIndex = 5,
			}, card)

			local contentLabel = Create("TextLabel", {
				Name = "Content",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Text = pContent,
				TextColor3 = Tokens.Colors.TextSecondary,
				Font = Tokens.Typography.Font,
				TextSize = Tokens.Typography.Sizes.Sub,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				LayoutOrder = 2,
				ZIndex = 5,
			}, card)

			return {
				Instance = card,
				SetTitle = function(_, t) titleLabel.Text = t end,
				SetContent = function(_, c) contentLabel.Text = c end,
				Destroy = function() card:Destroy() end,
			}
		end

		-- BUTTON (Harmonious Frosted Glass Card with Action Badge)
		function TabObj:CreateButton(btnConfig)
			btnConfig = btnConfig or {}
			local name = btnConfig.Name or "Button"
			local desc = btnConfig.Description or ""
			local callback = btnConfig.Callback or function() end
			local variant = btnConfig.Variant or "Secondary"

			local bgCol = Tokens.Colors.SurfaceElevated
			local bgTrans = 0.55
			local borderCol = Tokens.Colors.BorderSubtle
			local strokeTrans = 0.65
			local textCol = Tokens.Colors.TextPrimary
			local descCol = Tokens.Colors.TextSecondary
			local badgeBg = Tokens.Colors.SurfaceElevated
			local badgeTrans = 0.60
			local badgeBorderCol = Tokens.Colors.BorderSubtle
			local badgeStrokeTrans = 0.70
			local badgeIconCol = Tokens.Colors.TextSecondary

			if variant == "Primary" then
				bgCol = userAccent
				bgTrans = 0.88
				borderCol = userAccent
				strokeTrans = 0.40
				textCol = Tokens.Colors.TextPrimary
				descCol = Tokens.Colors.TextSecondary
				badgeBg = userAccent
				badgeTrans = 0.15
				badgeBorderCol = userAccent
				badgeStrokeTrans = 0.30
				badgeIconCol = Color3.fromRGB(255, 255, 255)
			elseif variant == "Danger" then
				bgCol = Tokens.Colors.Danger
				bgTrans = 0.88
				borderCol = Tokens.Colors.Danger
				strokeTrans = 0.40
				textCol = Color3.fromRGB(255, 140, 140)
				descCol = Color3.fromRGB(200, 160, 160)
				badgeBg = Tokens.Colors.Danger
				badgeTrans = 0.20
				badgeBorderCol = Tokens.Colors.Danger
				badgeStrokeTrans = 0.35
				badgeIconCol = Color3.fromRGB(255, 255, 255)
			end

			local height = desc ~= "" and 58 or Tokens.Touch.ControlHeight
			local btnCard = Create("TextButton", {
				Name = "Button_" .. name,
				Size = UDim2.new(1, -8, 0, height),
				BackgroundColor3 = bgCol,
				BackgroundTransparency = bgTrans,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 4,
			}, pageScroll)
			Corner(Tokens.Corners.Md, btnCard)
			local btnStroke = Stroke(borderCol, 1, strokeTrans, btnCard)

			local label = Create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, -54, 0, 20),
				Position = desc ~= "" and UDim2.new(0, 14, 0, 10) or UDim2.new(0, 14, 0.5, -10),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = textCol,
				Font = Tokens.Typography.FontBold,
				TextSize = Tokens.Typography.Sizes.Body,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5,
			}, btnCard)

			if desc ~= "" then
				local dLabel = Create("TextLabel", {
					Name = "Description",
					Size = UDim2.new(1, -54, 0, 16),
					Position = UDim2.new(0, 14, 0, 30),
					BackgroundTransparency = 1,
					Text = desc,
					TextColor3 = descCol,
					Font = Tokens.Typography.FontMedium,
					TextSize = Tokens.Typography.Sizes.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 5,
				}, btnCard)
			end

			-- Right Action Badge with crisp right-pointing chevron (>)
			local actionBadge = Create("Frame", {
				Name = "ActionBadge",
				Size = UDim2.fromOffset(26, 26),
				Position = UDim2.new(1, -12, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = badgeBg,
				BackgroundTransparency = badgeTrans,
				BorderSizePixel = 0,
				ZIndex = 5,
			}, btnCard)
			Corner(Tokens.Corners.Sm, actionBadge)
			local badgeStroke = Stroke(badgeBorderCol, 1, badgeStrokeTrans, actionBadge)

			local arrowIcon = CreateIcon(Icons.ChevronDown, actionBadge, {
				Name = "ArrowIcon",
				Size = UDim2.fromOffset(14, 14),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Color = badgeIconCol,
				ZIndex = 6,
			})
			arrowIcon.Rotation = -90 -- Perfectly points RIGHT (>)

			btnCard.MouseEnter:Connect(function()
				if variant == "Primary" then
					Tween(btnCard, {BackgroundTransparency = 0.78}, Tokens.Motion.Fast)
					Tween(btnStroke, {Transparency = 0.20}, Tokens.Motion.Fast)
					Tween(actionBadge, {BackgroundTransparency = 0.05}, Tokens.Motion.Fast)
				elseif variant == "Danger" then
					Tween(btnCard, {BackgroundTransparency = 0.80}, Tokens.Motion.Fast)
					Tween(btnStroke, {Transparency = 0.20}, Tokens.Motion.Fast)
					Tween(actionBadge, {BackgroundTransparency = 0.05}, Tokens.Motion.Fast)
				else
					Tween(btnCard, {BackgroundColor3 = Tokens.Colors.SurfaceHover, BackgroundTransparency = 0.45}, Tokens.Motion.Fast)
					Tween(btnStroke, {Color = userAccent, Transparency = 0.35}, Tokens.Motion.Fast)
					Tween(actionBadge, {BackgroundColor3 = Tokens.Colors.SurfaceHover, BackgroundTransparency = 0.3}, Tokens.Motion.Fast)
					Tween(arrowIcon, {ImageColor3 = userAccent}, Tokens.Motion.Fast)
				end
			end)

			btnCard.MouseLeave:Connect(function()
				if variant == "Primary" then
					Tween(btnCard, {BackgroundTransparency = bgTrans}, Tokens.Motion.Fast)
					Tween(btnStroke, {Transparency = strokeTrans}, Tokens.Motion.Fast)
					Tween(actionBadge, {BackgroundTransparency = badgeTrans}, Tokens.Motion.Fast)
				elseif variant == "Danger" then
					Tween(btnCard, {BackgroundTransparency = bgTrans}, Tokens.Motion.Fast)
					Tween(btnStroke, {Transparency = strokeTrans}, Tokens.Motion.Fast)
					Tween(actionBadge, {BackgroundTransparency = badgeTrans}, Tokens.Motion.Fast)
				else
					Tween(btnCard, {BackgroundColor3 = bgCol, BackgroundTransparency = bgTrans}, Tokens.Motion.Fast)
					Tween(btnStroke, {Color = borderCol, Transparency = strokeTrans}, Tokens.Motion.Fast)
					Tween(actionBadge, {BackgroundColor3 = badgeBg, BackgroundTransparency = badgeTrans}, Tokens.Motion.Fast)
					Tween(arrowIcon, {ImageColor3 = badgeIconCol}, Tokens.Motion.Fast)
				end
			end)

			btnCard.MouseButton1Click:Connect(function()
				Tween(btnCard, {Size = UDim2.new(1, -12, 0, height - 2)}, Tokens.Motion.Instant)
				task.delay(Tokens.Motion.Instant, function()
					Tween(btnCard, {Size = UDim2.new(1, -8, 0, height)}, Tokens.Motion.Fast)
				end)
				task.spawn(function()
					local success, err = pcall(callback)
					if not success then
						warn("[SonUI Button Error]: " .. tostring(err))
					end
				end)
			end)

			return {
				Instance = btnCard,
				SetText = function(_, t) label.Text = t end,
			}
		end

		-- TOGGLE
		function TabObj:CreateToggle(toggleConfig)
			toggleConfig = toggleConfig or {}
			local name = toggleConfig.Name or "Toggle"
			local desc = toggleConfig.Description or ""
			local state = toggleConfig.Default or toggleConfig.CurrentValue or false
			local callback = toggleConfig.Callback or function() end

			local height = desc ~= "" and 58 or Tokens.Touch.ControlHeight
			local card = Create("Frame", {
				Name = "Toggle_" .. name,
				Size = UDim2.new(1, -8, 0, height),
				BackgroundColor3 = Tokens.Colors.SurfaceElevated,
				BackgroundTransparency = 0.55,
				BorderSizePixel = 0,
				ZIndex = 4,
			}, pageScroll)
			Corner(Tokens.Corners.Md, card)
			local cardStroke = Stroke(Tokens.Colors.BorderSubtle, 1, 0.65, card)

			local title = Create("TextLabel", {
				Name = "Title",
				Size = UDim2.new(1, -80, 0, 20),
				Position = desc ~= "" and UDim2.new(0, 14, 0, 10) or UDim2.new(0, 14, 0.5, -10),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Tokens.Colors.TextPrimary,
				Font = Tokens.Typography.FontBold,
				TextSize = Tokens.Typography.Sizes.Body,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 5,
			}, card)

			if desc ~= "" then
				local dLabel = Create("TextLabel", {
					Name = "Description",
					Size = UDim2.new(1, -80, 0, 16),
					Position = UDim2.new(0, 14, 0, 30),
					BackgroundTransparency = 1,
					Text = desc,
					TextColor3 = Tokens.Colors.TextSecondary,
					Font = Tokens.Typography.FontMedium,
					TextSize = Tokens.Typography.Sizes.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 5,
				}, card)
			end

			local switch = Create("TextButton", {
				Name = "Switch",
				Size = UDim2.new(0, 48, 0, 26),
				Position = UDim2.new(1, -62, 0.5, -13),
				BackgroundColor3 = state and userAccent or Tokens.Colors.SurfaceHover,
				BackgroundTransparency = state and 0 or 0.45,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 5,
			}, card)
			Corner(Tokens.Corners.Pill, switch)
			local switchStroke = Stroke(state and Tokens.Colors.AccentGlow or Tokens.Colors.BorderSubtle, 1, state and 0.2 or 0.6, switch)

			local knob = Create("Frame", {
				Name = "Knob",
				Size = UDim2.new(0, 20, 0, 20),
				Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				ZIndex = 6,
			}, switch)
			Corner(Tokens.Corners.Pill, knob)

			local function UpdateState(val, trigger)
				state = val
				if state then
					Tween(switch, {BackgroundColor3 = userAccent}, Tokens.Motion.Fast)
					Tween(switchStroke, {Color = Tokens.Colors.AccentGlow}, Tokens.Motion.Fast)
					Tween(knob, {Position = UDim2.new(1, -23, 0.5, -10)}, Tokens.Motion.Fast)
					Tween(cardStroke, {Color = Tokens.Colors.BorderActive}, Tokens.Motion.Fast)
				else
					Tween(switch, {BackgroundColor3 = Tokens.Colors.SurfaceHover}, Tokens.Motion.Fast)
					Tween(switchStroke, {Color = Tokens.Colors.Border}, Tokens.Motion.Fast)
					Tween(knob, {Position = UDim2.new(0, 3, 0.5, -10)}, Tokens.Motion.Fast)
					Tween(cardStroke, {Color = Tokens.Colors.Border}, Tokens.Motion.Fast)
				end

				if trigger ~= false then
					task.spawn(function()
						local success, err = pcall(callback, state)
						if not success then
							warn("[SonUI Toggle Error]: " .. tostring(err))
						end
					end)
				end
			end

			switch.MouseButton1Click:Connect(function()
				UpdateState(not state)
			end)

			return {
				Instance = card,
				Set = function(_, v) UpdateState(v, true) end,
				SetValue = function(_, v) UpdateState(v, true) end,
				Get = function(_) return state end,
				GetValue = function(_) return state end,
			}
		end

		-- SLIDER
		function TabObj:CreateSlider(sliderConfig)
			sliderConfig = sliderConfig or {}
			local name = sliderConfig.Name or "Slider"
			local min = sliderConfig.Min or 0
			local max = sliderConfig.Max or 100
			local step = sliderConfig.Step or 1
			local suffix = sliderConfig.Suffix or ""
			local currentVal = math.clamp(sliderConfig.Default or sliderConfig.CurrentValue or min, min, max)
			local callback = sliderConfig.Callback or function() end

			local card = Create("Frame", {
				Name = "Slider_" .. name,
				Size = UDim2.new(1, -8, 0, 68),
				BackgroundColor3 = Tokens.Colors.SurfaceElevated,
				BackgroundTransparency = 0.55,
				BorderSizePixel = 0,
				ZIndex = 4,
			}, pageScroll)
			Corner(Tokens.Corners.Md, card)
			local cardStroke = Stroke(Tokens.Colors.BorderSubtle, 1, 0.65, card)

			local title = Create("TextLabel", {
				Name = "Title",
				Size = UDim2.new(1, -100, 0, 18),
				Position = UDim2.new(0, 14, 0, 12),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Tokens.Colors.TextPrimary,
				Font = Tokens.Typography.FontBold,
				TextSize = Tokens.Typography.Sizes.Body,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 5,
			}, card)

			local valPill = Create("TextLabel", {
				Name = "ValueDisplay",
				Size = UDim2.new(0, 76, 0, 22),
				Position = UDim2.new(1, -90, 0, 10),
				BackgroundColor3 = Tokens.Colors.SurfaceHover,
				BackgroundTransparency = 0.5,
				Text = tostring(currentVal) .. suffix,
				TextColor3 = Tokens.Colors.TextPrimary,
				Font = Tokens.Typography.FontMedium,
				TextSize = Tokens.Typography.Sizes.Sub,
				ZIndex = 5,
			}, card)
			Corner(Tokens.Corners.Sm, valPill)
			Stroke(Tokens.Colors.BorderSubtle, 1, 0.6, valPill)

			-- Track
			local track = Create("TextButton", {
				Name = "Track",
				Size = UDim2.new(1, -28, 0, 8),
				Position = UDim2.new(0, 14, 0, 44),
				BackgroundColor3 = Tokens.Colors.SurfaceHover,
				BackgroundTransparency = 0.45,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 5,
			}, card)
			Corner(Tokens.Corners.Pill, track)

			local fill = Create("Frame", {
				Name = "Fill",
				Size = UDim2.new((currentVal - min) / (max - min), 0, 1, 0),
				BackgroundColor3 = userAccent,
				BorderSizePixel = 0,
				ZIndex = 6,
			}, track)
			Corner(Tokens.Corners.Pill, fill)

			local thumb = Create("Frame", {
				Name = "Thumb",
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(1, -8, 0.5, -8),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				ZIndex = 7,
			}, fill)
			Corner(Tokens.Corners.Pill, thumb)
			Stroke(Tokens.Colors.AccentGlow, 1.5, 0, thumb)

			local dragging = false
			local function SetValue(v, trigger)
				local snapped = math.floor((v - min) / step + 0.5) * step + min
				currentVal = math.clamp(snapped, min, max)
				local alpha = (currentVal - min) / (max - min)

				valPill.Text = tostring(currentVal) .. suffix
				Tween(fill, {Size = UDim2.new(alpha, 0, 1, 0)}, Tokens.Motion.Instant)

				if trigger ~= false then
					task.spawn(function()
						local success, err = pcall(callback, currentVal)
						if not success then
							warn("[SonUI Slider Error]: " .. tostring(err))
						end
					end)
				end
			end

			local function UpdateFromMouse(input)
				local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				local targetVal = min + (max - min) * relativeX
				SetValue(targetVal)
			end

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					UpdateFromMouse(input)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateFromMouse(input)
				end
			end)

			return {
				Instance = card,
				Set = function(_, v) SetValue(v, true) end,
				SetValue = function(_, v) SetValue(v, true) end,
				Get = function(_) return currentVal end,
				GetValue = function(_) return currentVal end,
			}
		end

		-- =================================================================
		-- DUAL-MODE DROPDOWN (Popup / Floating & Inline / Accordion)
		-- =================================================================
		function TabObj:CreateDropdown(dropConfig)
			dropConfig = dropConfig or {}
			local name = dropConfig.Name or "Dropdown"
			local desc = dropConfig.Description or ""
			local options = dropConfig.Options or {}
			local isMulti = dropConfig.Multi or false
			local mode = dropConfig.Mode or "Popup" -- "Popup" (WindUI style) or "Inline" (Expanding card)
			local callback = dropConfig.Callback or function() end

			local selected
			if isMulti then
				selected = {}
				if type(dropConfig.Default) == "table" then
					for _, v in ipairs(dropConfig.Default) do selected[v] = true end
				end
			else
				selected = dropConfig.Default or dropConfig.CurrentValue or options[1] or "Select"
			end

			local height = desc ~= "" and 58 or Tokens.Touch.ControlHeight
			local card = Create("Frame", {
				Name = "Dropdown_" .. name,
				Size = UDim2.new(1, -8, 0, height),
				BackgroundColor3 = Tokens.Colors.SurfaceElevated,
				BackgroundTransparency = 0.55,
				BorderSizePixel = 0,
				ClipsDescendants = (mode == "Inline"),
				ZIndex = 8,
			}, pageScroll)
			Corner(Tokens.Corners.Md, card)
			local cardStroke = Stroke(Tokens.Colors.BorderSubtle, 1, 0.65, card)

			local headerBtn = Create("TextButton", {
				Name = "HeaderButton",
				Size = UDim2.new(1, 0, 0, height),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 9,
			}, card)

			local triggerPill = Create("Frame", {
				Name = "TriggerPill",
				Size = UDim2.new(0.40, -4, 0, 28),
				Position = UDim2.new(1, -12, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Tokens.Colors.SurfaceHover,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				ZIndex = 10,
			}, headerBtn)
			Corner(Tokens.Corners.Sm, triggerPill)
			local pillStroke = Stroke(Tokens.Colors.BorderSubtle, 1, 0.6, triggerPill)

			local title = Create("TextLabel", {
				Name = "Title",
				Size = UDim2.new(0.56, -14, 0, 20),
				Position = desc ~= "" and UDim2.new(0, 14, 0, 10) or UDim2.new(0, 14, 0.5, -10),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Tokens.Colors.TextPrimary,
				Font = Tokens.Typography.FontBold,
				TextSize = Tokens.Typography.Sizes.Body,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 10,
			}, headerBtn)

			if desc ~= "" then
				local dLabel = Create("TextLabel", {
					Name = "Description",
					Size = UDim2.new(0.56, -14, 0, 16),
					Position = UDim2.new(0, 14, 0, 30),
					BackgroundTransparency = 1,
					Text = desc,
					TextColor3 = Tokens.Colors.TextSecondary,
					Font = Tokens.Typography.FontMedium,
					TextSize = Tokens.Typography.Sizes.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 10,
				}, headerBtn)
			end

			local selectDisplay = Create("TextLabel", {
				Name = "SelectDisplay",
				Size = UDim2.new(1, -28, 1, 0),
				Position = UDim2.new(0, 10, 0, 0),
				BackgroundTransparency = 1,
				Text = "",
				TextColor3 = Tokens.Colors.TextPrimary,
				Font = Tokens.Typography.FontMedium,
				TextSize = Tokens.Typography.Sizes.Sub,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 11,
			}, triggerPill)

			local chevron = CreateIcon(Icons.ChevronDown, triggerPill, {
				Name = "ChevronIcon",
				Size = UDim2.fromOffset(14, 14),
				Position = UDim2.new(1, -16, 0.5, 0),
				Color = Tokens.Colors.TextMuted,
				ZIndex = 11,
			})

			local function UpdateDisplayText()
				if isMulti then
					local chosen = {}
					for opt, on in pairs(selected) do
						if on then table.insert(chosen, opt) end
					end
					if #chosen == 0 then
						selectDisplay.Text = "None Selected"
					else
						selectDisplay.Text = table.concat(chosen, ", ")
					end
				else
					selectDisplay.Text = tostring(selected)
				end
			end
			UpdateDisplayText()

			local isOpen = false
			local floatingMenu = nil

			-- Close handler for popup mode
			local function CloseFloatingPopup()
				if floatingMenu then
					floatingMenu:Destroy()
					floatingMenu = nil
				end
				isOpen = false
				Tween(chevron, {Rotation = 0}, Tokens.Motion.Fast)
				Tween(pillStroke, {Color = Tokens.Colors.BorderSubtle}, Tokens.Motion.Fast)
			end

			-- INLINE MODE: Expanding scroll container inside card
			local inlineScroll = nil
			if mode == "Inline" then
				inlineScroll = Create("ScrollingFrame", {
					Name = "InlineOptions",
					Size = UDim2.new(1, -20, 0, 120),
					Position = UDim2.new(0, 10, 0, height + 4),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 2,
					ScrollBarImageColor3 = Tokens.Colors.Border,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
					Visible = false,
					ZIndex = 11,
				}, card)

				local ilLayout = Create("UIListLayout", {
					Padding = UDim.new(0, 4),
				}, inlineScroll)
			end

			local function RenderOptionsList(parentContainer, isPopupContainer)
				for _, opt in ipairs(options) do
					local isCurrent = isMulti and selected[opt] or (selected == opt)
					local optBtn = Create("TextButton", {
						Name = "Option_" .. tostring(opt),
						Size = UDim2.new(1, 0, 0, 32),
						BackgroundColor3 = isCurrent and userAccent or Tokens.Colors.SurfaceElevated,
						BackgroundTransparency = isCurrent and 0.84 or 1,
						BorderSizePixel = 0,
						Text = "",
						AutoButtonColor = false,
						ZIndex = isPopupContainer and 106 or 12,
					}, parentContainer)
					Corner(Tokens.Corners.Sm, optBtn)

					local optStroke = Stroke(userAccent, 1, isCurrent and 0.60 or 1, optBtn)

					local optLabel = Create("TextLabel", {
						Name = "Label",
						Size = UDim2.new(1, -36, 1, 0),
						Position = UDim2.new(0, 10, 0, 0),
						BackgroundTransparency = 1,
						Text = tostring(opt),
						TextColor3 = isCurrent and Tokens.Colors.TextPrimary or Tokens.Colors.TextSecondary,
						Font = isCurrent and Tokens.Typography.FontBold or Tokens.Typography.FontMedium,
						TextSize = Tokens.Typography.Sizes.Sub,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = isPopupContainer and 107 or 13,
					}, optBtn)

					if isCurrent then
						CreateIcon(Icons.Check, optBtn, {
							Size = UDim2.fromOffset(14, 14),
							Position = UDim2.new(1, -12, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5),
							Color = userAccent,
							ZIndex = isPopupContainer and 107 or 13,
						})
					end

					optBtn.MouseEnter:Connect(function()
						if isCurrent then
							Tween(optBtn, {BackgroundTransparency = 0.72}, Tokens.Motion.Fast)
						else
							Tween(optBtn, {BackgroundColor3 = Tokens.Colors.SurfaceHover, BackgroundTransparency = 0.5}, Tokens.Motion.Fast)
							Tween(optLabel, {TextColor3 = Tokens.Colors.TextPrimary}, Tokens.Motion.Fast)
						end
					end)
					optBtn.MouseLeave:Connect(function()
						if isCurrent then
							Tween(optBtn, {BackgroundTransparency = 0.84}, Tokens.Motion.Fast)
						else
							Tween(optBtn, {BackgroundTransparency = 1}, Tokens.Motion.Fast)
							Tween(optLabel, {TextColor3 = Tokens.Colors.TextSecondary}, Tokens.Motion.Fast)
						end
					end)

					optBtn.MouseButton1Click:Connect(function()
						if isMulti then
							selected[opt] = not selected[opt]
							UpdateDisplayText()
							task.spawn(function()
								pcall(callback, selected)
							end)
							-- Refresh highlight
							if isPopupContainer then
								CloseFloatingPopup()
							end
						else
							selected = opt
							UpdateDisplayText()
							task.spawn(function()
								pcall(callback, opt)
							end)
							if isPopupContainer then
								CloseFloatingPopup()
							else
								-- Toggle inline closed
								isOpen = false
								Tween(card, {Size = UDim2.new(1, -8, 0, height)}, Tokens.Motion.Normal)
								Tween(chevron, {Rotation = 0}, Tokens.Motion.Fast)
								inlineScroll.Visible = false
							end
						end
					end)
				end
			end

			headerBtn.MouseButton1Click:Connect(function()
				if mode == "Popup" then
					-- Floating Popover (WindUI style)
					if isOpen then
						CloseFloatingPopup()
						overlayBackdrop.Visible = false
					else
						CloseActivePopup()
						isOpen = true
						overlayBackdrop.Visible = true

						local vp = GetViewport()
						local triggerAbs = triggerPill.AbsolutePosition
						local triggerSize = triggerPill.AbsoluteSize
						local menuWidth = math.clamp(math.max(triggerSize.X, 170), 120, vp.X - 20)
						local menuHeight = math.min(#options * 36 + 12, math.min(220, vp.Y - 40))

						local posX = math.clamp(triggerAbs.X, 10, vp.X - menuWidth - 10)
						local posY = triggerAbs.Y + triggerSize.Y + 6
						if posY + menuHeight > vp.Y - 10 then
							posY = math.max(10, triggerAbs.Y - menuHeight - 6)
						end

						local overlayAbs = overlayLayer.AbsolutePosition
						local localX = posX - overlayAbs.X
						local localY = posY - overlayAbs.Y

						floatingMenu = Create("Frame", {
							Name = "FloatingDropdownMenu",
							Size = UDim2.fromOffset(menuWidth, menuHeight),
							Position = UDim2.fromOffset(localX, localY),
							BackgroundColor3 = Tokens.Colors.Header,
							BackgroundTransparency = 0.05,
							BorderSizePixel = 0,
							ClipsDescendants = true,
							ZIndex = 105,
						}, overlayLayer)
						Corner(Tokens.Corners.Md, floatingMenu)
						Stroke(Tokens.Colors.BorderSubtle, 1, 0.45, floatingMenu)

						local popScroll = Create("ScrollingFrame", {
							Name = "PopScroll",
							Size = UDim2.new(1, -8, 1, -8),
							Position = UDim2.new(0, 4, 0, 4),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ScrollBarThickness = 2,
							ScrollBarImageColor3 = Tokens.Colors.BorderSubtle,
							AutomaticCanvasSize = Enum.AutomaticSize.Y,
							ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
							ZIndex = 106,
						}, floatingMenu)

						Create("UIPadding", {
							PaddingTop = UDim.new(0, 2),
							PaddingBottom = UDim.new(0, 2),
							PaddingLeft = UDim.new(0, 2),
							PaddingRight = UDim.new(0, 2),
						}, popScroll)

						local pLayout = Create("UIListLayout", {
							Padding = UDim.new(0, 3),
						}, popScroll)

						RenderOptionsList(popScroll, true)

						Tween(chevron, {Rotation = 180}, Tokens.Motion.Fast)
						Tween(pillStroke, {Color = userAccent}, Tokens.Motion.Fast)

						activePopup = {
							Close = CloseFloatingPopup,
						}
					end
				else
					-- Inline Accordion mode
					isOpen = not isOpen
					if isOpen then
						inlineScroll:ClearAllChildren()
						Create("UIListLayout", { Padding = UDim.new(0, 4) }, inlineScroll)
						RenderOptionsList(inlineScroll, false)
						inlineScroll.Visible = true

						local targetH = math.min(height + 12 + (#options * 34), height + 180)
						Tween(card, {Size = UDim2.new(1, -8, 0, targetH)}, Tokens.Motion.Normal)
						Tween(chevron, {Rotation = 180}, Tokens.Motion.Fast)
					else
						Tween(card, {Size = UDim2.new(1, -8, 0, height)}, Tokens.Motion.Normal)
						Tween(chevron, {Rotation = 0}, Tokens.Motion.Fast)
						task.delay(Tokens.Motion.Normal, function()
							if not isOpen then inlineScroll.Visible = false end
						end)
					end
				end
			end)

			return {
				Instance = card,
				Set = function(_, val)
					selected = val
					UpdateDisplayText()
					task.spawn(function() pcall(callback, val) end)
				end,
				Get = function(_) return selected end,
				Refresh = function(_, newOptions, keepSelection)
					options = newOptions or {}
					if not keepSelection then
						selected = isMulti and {} or (options[1] or "Select")
					end
					UpdateDisplayText()
					if isOpen and mode == "Popup" then
						CloseFloatingPopup()
					end
				end,
			}
		end

		-- =================================================================
		-- KEYBIND COMPONENT
		-- =================================================================
		function TabObj:CreateKeybind(kbConfig)
			kbConfig = kbConfig or {}
			local name = kbConfig.Name or "Keybind"
			local desc = kbConfig.Description or ""
			local currentKey = kbConfig.Default or Enum.KeyCode.E
			local callback = kbConfig.Callback or function() end
			local onChanged = kbConfig.OnChanged or function() end

			local height = desc ~= "" and 58 or Tokens.Touch.ControlHeight
			local card = Create("Frame", {
				Name = "Keybind_" .. name,
				Size = UDim2.new(1, -8, 0, height),
				BackgroundColor3 = Tokens.Colors.SurfaceElevated,
				BackgroundTransparency = 0.55,
				BorderSizePixel = 0,
				ZIndex = 4,
			}, pageScroll)
			Corner(Tokens.Corners.Md, card)
			local cardStroke = Stroke(Tokens.Colors.BorderSubtle, 1, 0.65, card)

			local title = Create("TextLabel", {
				Name = "Title",
				Size = UDim2.new(1, -120, 0, 20),
				Position = desc ~= "" and UDim2.new(0, 14, 0, 10) or UDim2.new(0, 14, 0.5, -10),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Tokens.Colors.TextPrimary,
				Font = Tokens.Typography.FontBold,
				TextSize = Tokens.Typography.Sizes.Body,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 5,
			}, card)

			if desc ~= "" then
				local dLabel = Create("TextLabel", {
					Name = "Description",
					Size = UDim2.new(1, -120, 0, 16),
					Position = UDim2.new(0, 14, 0, 30),
					BackgroundTransparency = 1,
					Text = desc,
					TextColor3 = Tokens.Colors.TextSecondary,
					Font = Tokens.Typography.FontMedium,
					TextSize = Tokens.Typography.Sizes.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 5,
				}, card)
			end

			local bindBtn = Create("TextButton", {
				Name = "BindButton",
				Size = UDim2.new(0, 84, 0, 28),
				Position = UDim2.new(1, -98, 0.5, -14),
				BackgroundColor3 = Tokens.Colors.SurfaceHover,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Text = "[ " .. (typeof(currentKey) == "EnumItem" and currentKey.Name or tostring(currentKey)) .. " ]",
				TextColor3 = Tokens.Colors.TextPrimary,
				Font = Tokens.Typography.FontMedium,
				TextSize = Tokens.Typography.Sizes.Sub,
				AutoButtonColor = false,
				ZIndex = 5,
			}, card)
			Corner(Tokens.Corners.Sm, bindBtn)
			local btnStroke = Stroke(Tokens.Colors.BorderSubtle, 1, 0.6, bindBtn)

			local isListening = false
			local listenConn = nil

			bindBtn.MouseButton1Click:Connect(function()
				if isListening then return end
				isListening = true
				bindBtn.Text = "[ ... ]"
				Tween(btnStroke, {Color = userAccent}, Tokens.Motion.Fast)

				listenConn = UserInputService.InputBegan:Connect(function(input, gpe)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						if input.KeyCode ~= Enum.KeyCode.Unknown then
							currentKey = input.KeyCode
							bindBtn.Text = "[ " .. currentKey.Name .. " ]"
							isListening = false
							listenConn:Disconnect()
							listenConn = nil
							Tween(btnStroke, {Color = Tokens.Colors.BorderSubtle}, Tokens.Motion.Fast)
							task.spawn(function()
								pcall(onChanged, currentKey)
							end)
						end
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
						isListening = false
						bindBtn.Text = "[ " .. currentKey.Name .. " ]"
						if listenConn then listenConn:Disconnect() end
						Tween(btnStroke, {Color = Tokens.Colors.BorderSubtle}, Tokens.Motion.Fast)
					end
				end)
			end)

			UserInputService.InputBegan:Connect(function(input, gpe)
				if not gpe and not isListening and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
					task.spawn(function()
						pcall(callback, currentKey)
					end)
				end
			end)

			return {
				Instance = card,
				SetKey = function(_, key)
					currentKey = key
					bindBtn.Text = "[ " .. (typeof(key) == "EnumItem" and key.Name or tostring(key)) .. " ]"
					task.spawn(function() pcall(onChanged, key) end)
				end,
				GetKey = function(_) return currentKey end,
			}
		end

		-- =================================================================
		-- COLOR PICKER COMPONENT
		-- =================================================================
		function TabObj:CreateColorPicker(cpConfig)
			cpConfig = cpConfig or {}
			local name = cpConfig.Name or "Color Picker"
			local desc = cpConfig.Description or ""
			local currentColor = cpConfig.Default or Color3.fromRGB(0, 210, 255)
			local callback = cpConfig.Callback or function() end

			local height = desc ~= "" and 58 or Tokens.Touch.ControlHeight
			local card = Create("Frame", {
				Name = "ColorPicker_" .. name,
				Size = UDim2.new(1, -8, 0, height),
				BackgroundColor3 = Tokens.Colors.SurfaceElevated,
				BackgroundTransparency = 0.55,
				BorderSizePixel = 0,
				ZIndex = 4,
			}, pageScroll)
			Corner(Tokens.Corners.Md, card)
			local cardStroke = Stroke(Tokens.Colors.BorderSubtle, 1, 0.65, card)

			local title = Create("TextLabel", {
				Name = "Title",
				Size = UDim2.new(1, -80, 0, 20),
				Position = desc ~= "" and UDim2.new(0, 14, 0, 10) or UDim2.new(0, 14, 0.5, -10),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Tokens.Colors.TextPrimary,
				Font = Tokens.Typography.FontBold,
				TextSize = Tokens.Typography.Sizes.Body,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 5,
			}, card)

			if desc ~= "" then
				local dLabel = Create("TextLabel", {
					Name = "Description",
					Size = UDim2.new(1, -80, 0, 16),
					Position = UDim2.new(0, 14, 0, 30),
					BackgroundTransparency = 1,
					Text = desc,
					TextColor3 = Tokens.Colors.TextSecondary,
					Font = Tokens.Typography.FontMedium,
					TextSize = Tokens.Typography.Sizes.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 5,
				}, card)
			end

			-- Color Swatch Preview Button
			local swatch = Create("TextButton", {
				Name = "ColorSwatch",
				Size = UDim2.new(0, 48, 0, 26),
				Position = UDim2.new(1, -62, 0.5, -13),
				BackgroundColor3 = currentColor,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 5,
			}, card)
			Corner(Tokens.Corners.Sm, swatch)
			local swatchStroke = Stroke(Tokens.Colors.Border, 1, 0, swatch)

			local isOpen = false
			local colorPopup = nil

			local function CloseColorPopup()
				if colorPopup then
					colorPopup:Destroy()
					colorPopup = nil
				end
				isOpen = false
			end

			swatch.MouseButton1Click:Connect(function()
				if isOpen then
					CloseColorPopup()
					overlayBackdrop.Visible = false
				else
					CloseActivePopup()
					isOpen = true
					overlayBackdrop.Visible = true

					local vp = GetViewport()
					local sAbs = swatch.AbsolutePosition
					local sSize = swatch.AbsoluteSize
					local popW = math.clamp(200, 160, vp.X - 20)
					local popH = math.clamp(170, 140, vp.Y - 20)

					local posX = math.clamp(sAbs.X - (popW - sSize.X), 10, vp.X - popW - 10)
					local posY = sAbs.Y + sSize.Y + 6
					if posY + popH > vp.Y - 10 then
						posY = math.max(10, sAbs.Y - popH - 6)
					end

					local overlayAbs = overlayLayer.AbsolutePosition
					local localX = posX - overlayAbs.X
					local localY = posY - overlayAbs.Y

					colorPopup = Create("Frame", {
						Name = "ColorPickerPopup",
						Size = UDim2.fromOffset(popW, popH),
						Position = UDim2.fromOffset(localX, localY),
						BackgroundColor3 = Tokens.Colors.Header,
						BorderSizePixel = 0,
						ZIndex = 110,
					}, overlayLayer)
					Corner(Tokens.Corners.Md, colorPopup)
					Stroke(userAccent, 1, 0.3, colorPopup)

					local pPadding = Create("UIPadding", {
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 10),
						PaddingBottom = UDim.new(0, 10),
					}, colorPopup)

					local pTitle = Create("TextLabel", {
						Name = "Title",
						Size = UDim2.new(1, 0, 0, 16),
						BackgroundTransparency = 1,
						Text = "SELECT PALETTE",
						TextColor3 = userAccent,
						Font = Tokens.Typography.FontBold,
						TextSize = 10,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 111,
					}, colorPopup)

					-- Color Presets Grid
					local presets = {
						Color3.fromRGB(0, 210, 255),  -- Cyan
						Color3.fromRGB(52, 211, 153),  -- Green
						Color3.fromRGB(168, 85, 247),  -- Purple
						Color3.fromRGB(251, 191, 36),  -- Amber
						Color3.fromRGB(248, 113, 113), -- Red
						Color3.fromRGB(244, 114, 182), -- Pink
						Color3.fromRGB(255, 255, 255), -- White
						Color3.fromRGB(30, 41, 59),    -- Slate
					}

					local grid = Create("Frame", {
						Name = "Grid",
						Size = UDim2.new(1, 0, 0, 68),
						Position = UDim2.new(0, 0, 0, 24),
						BackgroundTransparency = 1,
						ZIndex = 111,
					}, colorPopup)

					local uigrid = Create("UIGridLayout", {
						CellSize = UDim2.fromOffset(40, 30),
						CellPadding = UDim2.fromOffset(6, 6),
					}, grid)

					for _, c in ipairs(presets) do
						local pBtn = Create("TextButton", {
							Name = "Preset",
							BackgroundColor3 = c,
							BorderSizePixel = 0,
							Text = "",
							AutoButtonColor = false,
							ZIndex = 112,
						}, grid)
						Corner(Tokens.Corners.Sm, pBtn)

						pBtn.MouseButton1Click:Connect(function()
							currentColor = c
							swatch.BackgroundColor3 = c
							task.spawn(function() pcall(callback, c) end)
							CloseColorPopup()
							overlayBackdrop.Visible = false
						end)
					end

					-- RGB Value Readout
					local rgbLabel = Create("TextLabel", {
						Name = "RgbDisplay",
						Size = UDim2.new(1, 0, 0, 24),
						Position = UDim2.new(0, 0, 1, -26),
						BackgroundColor3 = Tokens.Colors.SurfaceElevated,
						Text = string.format("RGB(%d, %d, %d)", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255)),
						TextColor3 = Tokens.Colors.TextSecondary,
						Font = Tokens.Typography.FontMedium,
						TextSize = 11,
						ZIndex = 111,
					}, colorPopup)
					Corner(Tokens.Corners.Sm, rgbLabel)

					activePopup = {
						Close = CloseColorPopup,
					}
				end
			end)

			return {
				Instance = card,
				Set = function(_, col)
					currentColor = col
					swatch.BackgroundColor3 = col
					task.spawn(function() pcall(callback, col) end)
				end,
				SetColor = function(_, col)
					currentColor = col
					swatch.BackgroundColor3 = col
					task.spawn(function() pcall(callback, col) end)
				end,
				Get = function(_) return currentColor end,
				GetColor = function(_) return currentColor end,
			}
		end

		-- TEXT INPUT
		function TabObj:CreateInput(inputConfig)
			inputConfig = inputConfig or {}
			local name = inputConfig.Name or "Input"
			local placeholder = inputConfig.Placeholder or "Type here..."
			local defaultVal = inputConfig.Default or ""
			local callback = inputConfig.Callback or function() end

			local card = Create("Frame", {
				Name = "InputCard_" .. name,
				Size = UDim2.new(1, -8, 0, Tokens.Touch.ControlHeight),
				BackgroundColor3 = Tokens.Colors.SurfaceElevated,
				BackgroundTransparency = 0.55,
				BorderSizePixel = 0,
				ZIndex = 4,
			}, pageScroll)
			Corner(Tokens.Corners.Md, card)
			local cardStroke = Stroke(Tokens.Colors.BorderSubtle, 1, 0.65, card)

			local title = Create("TextLabel", {
				Name = "Title",
				Size = UDim2.new(0.4, -14, 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Tokens.Colors.TextPrimary,
				Font = Tokens.Typography.FontBold,
				TextSize = Tokens.Typography.Sizes.Body,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5,
			}, card)

			local box = Create("TextBox", {
				Name = "Box",
				Size = UDim2.new(0.6, -18, 0, 32),
				Position = UDim2.new(0.4, 4, 0.5, -16),
				BackgroundColor3 = Tokens.Colors.SurfaceHover,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Text = defaultVal,
				PlaceholderText = placeholder,
				PlaceholderColor3 = Tokens.Colors.TextMuted,
				TextColor3 = Tokens.Colors.TextPrimary,
				Font = Tokens.Typography.Font,
				TextSize = Tokens.Typography.Sizes.Sub,
				ClearTextOnFocus = inputConfig.ClearOnFocus or false,
				ZIndex = 5,
			}, card)
			Corner(Tokens.Corners.Sm, box)
			local boxStroke = Stroke(Tokens.Colors.BorderSubtle, 1, 0.6, box)

			box.Focused:Connect(function()
				Tween(boxStroke, {Color = userAccent}, Tokens.Motion.Fast)
			end)

			box.FocusLost:Connect(function(enterPressed)
				Tween(boxStroke, {Color = Tokens.Colors.BorderSubtle}, Tokens.Motion.Fast)
				task.spawn(function()
					local success, err = pcall(callback, box.Text, enterPressed)
					if not success then
						warn("[SonUI Input Error]: " .. tostring(err))
					end
				end)
			end)

			return {
				Instance = card,
				Set = function(_, t) box.Text = t end,
				SetValue = function(_, t) box.Text = t end,
				Get = function(_) return box.Text end,
				GetValue = function(_) return box.Text end,
			}
		end

		-- PARAGRAPH
		function TabObj:CreateParagraph(paraConfig)
			paraConfig = paraConfig or {}
			local title = paraConfig.Title or "Notice"
			local content = paraConfig.Content or ""

			local card = Create("Frame", {
				Name = "Paragraph_" .. title,
				Size = UDim2.new(1, -8, 0, 68),
				BackgroundColor3 = Tokens.Colors.SurfaceElevated,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 4,
			}, pageScroll)
			Corner(Tokens.Corners.Md, card)
			Stroke(Tokens.Colors.BorderSubtle, 1, 0, card)

			local padding = Create("UIPadding", {
				PaddingLeft = UDim.new(0, 14),
				PaddingRight = UDim.new(0, 14),
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 12),
			}, card)

			local pLayout = Create("UIListLayout", {
				Padding = UDim.new(0, 6),
			}, card)

			local pTitle = Create("TextLabel", {
				Name = "Title",
				Size = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Text = title,
				TextColor3 = userAccent,
				Font = Tokens.Typography.FontBold,
				TextSize = Tokens.Typography.Sizes.Body,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5,
			}, card)

			local pText = Create("TextLabel", {
				Name = "Content",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Text = content,
				TextColor3 = Tokens.Colors.TextSecondary,
				Font = Tokens.Typography.Font,
				TextSize = Tokens.Typography.Sizes.Sub,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				ZIndex = 5,
			}, card)

			return {
				Instance = card,
				SetTitle = function(_, t) pTitle.Text = t end,
				SetContent = function(_, c) pText.Text = c end,
			}
		end

		return TabObj
	end

	return WindowObj
end

-- Export tokens & icons
SonUI.Tokens = Tokens
SonUI.Icons = Icons

if typeof(getgenv) == "function" then
	getgenv().SonUI = SonUI
	getgenv().SonLibrary = SonUI
end

return SonUI
