--!nocheck
--[[
    SonLibrary UI v2.5.0 - Ultra Responsive & Glassmorphic UI Library
    Crafted for SonHUB (Full Mobile, Tablet & PC Screen Optimization)
    GitHub: https://github.com/hongson209/sonlibrary
    Raw: https://raw.githubusercontent.com/hongson209/sonlibrary/refs/heads/main/sonlibrary.lua
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local SonLibrary = {
    Version = "2.5.0",
    ActiveWindows = {},
    FontPresets = {
        Modern = {
            Font = (pcall(function() return Enum.Font.BuilderSans end) and Enum.Font.BuilderSans) or Enum.Font.SourceSans,
            FontMedium = (pcall(function() return Enum.Font.BuilderSansMedium end) and Enum.Font.BuilderSansMedium) or Enum.Font.SourceSansSemibold,
            FontBold = (pcall(function() return Enum.Font.BuilderSansBold end) and Enum.Font.BuilderSansBold) or Enum.Font.SourceSansBold,
        },
        Playful = { -- Cutepunch / Fredoka / Cartoon Rounded style
            Font = Enum.Font.FredokaOne,
            FontMedium = Enum.Font.FredokaOne,
            FontBold = Enum.Font.FredokaOne,
        },
        Cutepunch = {
            Font = Enum.Font.FredokaOne,
            FontMedium = Enum.Font.FredokaOne,
            FontBold = Enum.Font.LuckiestGuy,
        },
        Cartoon = {
            Font = Enum.Font.Kalam,
            FontMedium = Enum.Font.Kalam,
            FontBold = Enum.Font.LuckiestGuy,
        },
        Handwritten = {
            Font = Enum.Font.PatrickHand,
            FontMedium = Enum.Font.PatrickHand,
            FontBold = Enum.Font.PatrickHand,
        },
        Clean = {
            Font = Enum.Font.SourceSans,
            FontMedium = Enum.Font.SourceSansSemibold,
            FontBold = Enum.Font.SourceSansBold,
        },
        Code = {
            Font = Enum.Font.Code,
            FontMedium = Enum.Font.Code,
            FontBold = Enum.Font.RobotoMono,
        },
        SciFi = {
            Font = Enum.Font.Highway,
            FontMedium = Enum.Font.Highway,
            FontBold = Enum.Font.SciFi,
        },
        Elegant = {
            Font = Enum.Font.Merriweather,
            FontMedium = Enum.Font.Merriweather,
            FontBold = Enum.Font.Bodoni,
        },
    },
    DefaultTheme = {
        Background = Color3.fromRGB(15, 17, 24),
        BackgroundTransparency = 0.12,
        Sidebar = Color3.fromRGB(20, 23, 32),
        SidebarTransparency = 0.15,
        Card = Color3.fromRGB(25, 29, 41),
        CardTransparency = 0.25,
        CardHover = Color3.fromRGB(34, 40, 58),
        CardActive = Color3.fromRGB(40, 48, 70),
        Border = Color3.fromRGB(48, 55, 78),
        BorderActive = Color3.fromRGB(0, 166, 255),
        Accent = Color3.fromRGB(0, 166, 255),
        AccentGlow = Color3.fromRGB(0, 166, 255),
        Text = Color3.fromRGB(245, 247, 252),
        TextMuted = Color3.fromRGB(160, 170, 195),
        TextDark = Color3.fromRGB(115, 125, 145),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Danger = Color3.fromRGB(231, 76, 60),
        Font = (pcall(function() return Enum.Font.BuilderSans end) and Enum.Font.BuilderSans) or Enum.Font.SourceSans,
        FontMedium = (pcall(function() return Enum.Font.BuilderSansMedium end) and Enum.Font.BuilderSansMedium) or Enum.Font.SourceSansSemibold,
        FontBold = (pcall(function() return Enum.Font.BuilderSansBold end) and Enum.Font.BuilderSansBold) or Enum.Font.SourceSansBold,
    }
}

-- Safe Parent Resolver (CoreGui -> gethui() -> PlayerGui)
local function getSafeGuiParent(): Instance
    local success, parent = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
        if syn and typeof(syn.protect_gui) == "function" then
            local g = Instance.new("Folder")
            syn.protect_gui(g)
            g.Parent = CoreGui
            return g
        end
        return CoreGui
    end)
    if success and parent then
        return parent
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Download and Cache Custom Logo Asset
local function getSonHubLogoAsset(): string?
    local logoUrl = "https://cdn.discordapp.com/attachments/1317065294736265248/1555222187378475029/sonhub.png?backend=b2&ex=6ac5abc8&is=6ac45a48&hm=72c664d8d6b5380d66424a8368e3ec83e26bd7b1fa3d558da74240b4b5bdf57f"
    local fileName = "sonhub_icon.png"

    local ok, asset = pcall(function()
        if typeof(isfile) == "function" and typeof(writefile) == "function" and typeof(getcustomasset) == "function" then
            if not isfile(fileName) then
                local data = game:HttpGet(logoUrl)
                if data and #data > 500 then
                    writefile(fileName, data)
                end
            end
            return getcustomasset(fileName)
        end
        return nil
    end)

    if ok and asset then
        return asset
    end
    return "rbxassetid://10723346959"
end

-- Fast Tween Utility
local function tween(instance: Instance, duration: number, properties: {[string]: any}, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?): Tween
    local info = TweenInfo.new(
        duration or 0.2,
        easingStyle or Enum.EasingStyle.Quart,
        easingDirection or Enum.EasingDirection.Out
    )
    local anim = TweenService:Create(instance, info, properties)
    anim:Play()
    return anim
end

-- REDESIGNED RESPONSIVE & FLAWLESS TOAST NOTIFICATIONS
local NotificationGui = nil
local NotificationContainer = nil

local function getNotificationMetrics()
    local camera = workspace.CurrentCamera
    local vp = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local isSmall = vp.X < 760 or vp.Y < 520
    local targetWidth = math.clamp(vp.X - 24, 300, (isSmall or isMobile) and 340 or 385)
    return vp, isMobile, isSmall, targetWidth
end

local function setupNotificationGui()
    if NotificationGui and NotificationGui.Parent then return end

    local parent = getSafeGuiParent()
    pcall(function()
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ScreenGui") and child.Name == "SonLibrary_Notifications" then
                child:Destroy()
            end
        end
    end)

    NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "SonLibrary_Notifications"
    NotificationGui.ResetOnSpawn = false
    NotificationGui.DisplayOrder = 999999
    NotificationGui.Parent = parent

    local vp, isMobile, isSmall, cWidth = getNotificationMetrics()

    NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name = "Container"
    if isMobile or isSmall then
        NotificationContainer.Size = UDim2.new(0, cWidth, 1, -70)
        NotificationContainer.Position = UDim2.new(1, -cWidth - 14, 0, 52)
    else
        NotificationContainer.Size = UDim2.new(0, cWidth, 1, -50)
        NotificationContainer.Position = UDim2.new(1, -cWidth - 20, 0, 25)
    end
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.Parent = NotificationGui

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = (isMobile or isSmall) and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom
    layout.Padding = UDim.new(0, 12)
    layout.Parent = NotificationContainer

    local camera = workspace.CurrentCamera
    if camera then
        camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            local curVp, curMob, curSm, newWidth = getNotificationMetrics()
            if curMob or curSm then
                NotificationContainer.Size = UDim2.new(0, newWidth, 1, -70)
                NotificationContainer.Position = UDim2.new(1, -newWidth - 14, 0, 52)
                layout.VerticalAlignment = Enum.VerticalAlignment.Top
            else
                NotificationContainer.Size = UDim2.new(0, newWidth, 1, -50)
                NotificationContainer.Position = UDim2.new(1, -newWidth - 20, 0, 25)
                layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            end
        end)
    end
end

function SonLibrary:Notify(config: {Title: string?, Content: string?, Message: string?, Duration: number?, Type: string?})
    setupNotificationGui()
    config = config or {}
    local title = config.Title or "SonHUB"
    local message = config.Content or config.Message or ""
    local duration = config.Duration or 3.2
    local nType = config.Type or "Info"

    local theme = SonLibrary.DefaultTheme
    local typeColor = theme.Accent
    if nType == "Success" then typeColor = theme.Success
    elseif nType == "Warning" then typeColor = theme.Warning
    elseif nType == "Danger" then typeColor = theme.Danger end

    local _, isMobile, isSmall = getNotificationMetrics()

    local card = Instance.new("Frame")
    card.Name = "NoticeCard"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    card.BackgroundTransparency = 0.16
    card.BorderSizePixel = 0
    card.Parent = NotificationContainer

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 14)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(54, 62, 84)
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.5
    cardStroke.Parent = card

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 0, 0)
    ContentFrame.AutomaticSize = Enum.AutomaticSize.Y
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 16)
    pad.PaddingRight = UDim.new(0, 16)
    pad.PaddingTop = UDim.new(0, 14)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.Parent = ContentFrame

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 12)
    list.Parent = ContentFrame

    -- Body Row: [ Logo ]  [ Text Column ]  [ Close Button ]
    local BodyRow = Instance.new("Frame")
    BodyRow.Name = "BodyRow"
    BodyRow.Size = UDim2.new(1, 0, 0, 0)
    BodyRow.AutomaticSize = Enum.AutomaticSize.Y
    BodyRow.BackgroundTransparency = 1
    BodyRow.LayoutOrder = 1
    BodyRow.Parent = ContentFrame

    local iconAsset = config.Icon or getSonHubLogoAsset() or "rbxassetid://10723346959"

    local LogoImg = Instance.new("ImageLabel")
    LogoImg.Name = "Logo"
    LogoImg.Size = UDim2.fromOffset(40, 40)
    LogoImg.Position = UDim2.new(0, 0, 0, 0)
    LogoImg.BackgroundTransparency = 1
    LogoImg.Image = iconAsset
    LogoImg.Parent = BodyRow

    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 9)
    logoCorner.Parent = LogoImg

    local TextCol = Instance.new("Frame")
    TextCol.Name = "TextCol"
    TextCol.Size = UDim2.new(1, -74, 0, 0)
    TextCol.Position = UDim2.new(0, 50, 0, 0)
    TextCol.AutomaticSize = Enum.AutomaticSize.Y
    TextCol.BackgroundTransparency = 1
    TextCol.Parent = BodyRow

    local textList = Instance.new("UIListLayout")
    textList.SortOrder = Enum.SortOrder.LayoutOrder
    textList.Padding = UDim.new(0, 4)
    textList.Parent = TextCol

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "Title"
    titleLbl.Size = UDim2.new(1, 0, 0, 20)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = theme.FontBold or Enum.Font.BuilderSansBold
    titleLbl.Text = title
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextSize = (isSmall or isMobile) and 14 or 15
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.LayoutOrder = 1
    titleLbl.Parent = TextCol

    local contentLbl = Instance.new("TextLabel")
    contentLbl.Name = "Message"
    contentLbl.Size = UDim2.new(1, 0, 0, 0)
    contentLbl.AutomaticSize = Enum.AutomaticSize.Y
    contentLbl.BackgroundTransparency = 1
    contentLbl.Font = theme.FontMedium or Enum.Font.BuilderSansMedium
    contentLbl.Text = message
    contentLbl.TextColor3 = theme.TextMuted
    contentLbl.TextSize = (isSmall or isMobile) and 13 or 13.5
    contentLbl.TextWrapped = true
    contentLbl.TextXAlignment = Enum.TextXAlignment.Left
    contentLbl.LayoutOrder = 2
    contentLbl.Parent = TextCol

    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.fromOffset(20, 20)
    CloseBtn.Position = UDim2.new(1, -20, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Image = "rbxassetid://10747384394"
    CloseBtn.ImageColor3 = Color3.fromRGB(125, 135, 160)
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = BodyRow

    CloseBtn.MouseEnter:Connect(function()
        tween(CloseBtn, 0.15, {ImageColor3 = Color3.fromRGB(245, 248, 255)})
    end)
    CloseBtn.MouseLeave:Connect(function()
        tween(CloseBtn, 0.15, {ImageColor3 = Color3.fromRGB(125, 135, 160)})
    end)

    local ProgressTrack = Instance.new("Frame")
    ProgressTrack.Name = "ProgressTrack"
    ProgressTrack.Size = UDim2.new(1, 0, 0, 3)
    ProgressTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ProgressTrack.BackgroundTransparency = 0.94
    ProgressTrack.BorderSizePixel = 0
    ProgressTrack.ClipsDescendants = true
    ProgressTrack.LayoutOrder = 2
    ProgressTrack.Parent = ContentFrame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = ProgressTrack

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Size = UDim2.new(1, 0, 1, 0)
    ProgressBar.BackgroundColor3 = typeColor
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = ProgressTrack

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = ProgressBar

    local isClosed = false
    local function dismiss()
        if isClosed then return end
        isClosed = true
        local closeAnim = tween(card, 0.22, {Position = UDim2.new(1, 380, 0, 0), BackgroundTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        closeAnim.Completed:Connect(function()
            card:Destroy()
        end)
    end

    CloseBtn.Activated:Connect(dismiss)

    card.Position = UDim2.new(1, 380, 0, 0)
    tween(card, 0.32, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quart)
    tween(ProgressBar, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)

    task.delay(duration, dismiss)
end

-- MAIN WINDOW CONSTRUCTOR (Adaptive Mobile, Tablet & PC)
function SonLibrary:CreateWindow(config: {
    Title: string?,
    SubTitle: string?,
    Size: UDim2?,
    AccentColor: Color3?,
    ToggleKey: Enum.KeyCode?,
    TopbarButton: boolean?,
    DefaultTab: string?,
    Profile: ({
        Enabled: boolean?,
        Avatar: string?,
        Title: string?,
        Subtitle: string?,
    } | boolean)?,
})
    config = config or {}
    local titleText = config.Title or "SonHUB"
    local subTitleText = config.SubTitle or "Titan Edition"
    local accent = config.AccentColor or SonLibrary.DefaultTheme.Accent
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    local enableTopbarButton = config.TopbarButton ~= false

    local profileCfg = config.Profile
    local profileEnabled = true
    if profileCfg == false or (type(profileCfg) == "table" and profileCfg.Enabled == false) then
        profileEnabled = false
    end

    local theme = {}
    for k, v in pairs(SonLibrary.DefaultTheme) do
        theme[k] = v
    end
    theme.Accent = accent
    theme.AccentGlow = accent

    local fontCfg = config.FontFamily or config.FontPreset
    if fontCfg and SonLibrary.FontPresets[fontCfg] then
        local p = SonLibrary.FontPresets[fontCfg]
        theme.Font = p.Font
        theme.FontMedium = p.FontMedium
        theme.FontBold = p.FontBold
    elseif config.Font then
        theme.Font = config.Font
        theme.FontMedium = config.FontMedium or config.Font
        theme.FontBold = config.FontBold or config.Font
    end

    -- Responsive Viewport Calculations
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local isSmallScreen = (viewport.X < 760 or viewport.Y < 520)

    -- Dynamic sizing: Adapts to phone landscape, portrait, and desktop
    local defaultWidth = 630
    local defaultHeight = 410
    local targetWidth = math.min(defaultWidth, math.max(300, viewport.X - 20))
    local targetHeight = math.min(defaultHeight, math.max(250, viewport.Y - 50))
    local windowSize = config.Size or UDim2.fromOffset(targetWidth, targetHeight)

    -- Dynamic sidebar width based on screen width
    local SidebarWidth = 168
    if viewport.X < 520 then
        SidebarWidth = 116
    elseif viewport.X < 760 then
        SidebarWidth = 140
    end

    -- Cleanup existing instances to avoid ghost duplicates
    pcall(function()
        local parent = getSafeGuiParent()
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ScreenGui") and string.find(child.Name, "SonLibrary") and child.Name ~= "SonLibrary_Notifications" then
                child:Destroy()
            end
        end
        local p = Players.LocalPlayer
        local tbStandard = p and p:FindFirstChild("PlayerGui") and p.PlayerGui:FindFirstChild("TopbarStandard", true)
        if tbStandard then
            local existing = tbStandard:FindFirstChild("SonHubTopbarIcon", true)
            if existing then existing:Destroy() end
        end
    end)

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SonLibrary_" .. titleText
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 100000
    ScreenGui.Parent = getSafeGuiParent()

    -- UNIFIED GLASSMORPHIC WINDOW
    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name = "MainFrame"
    WindowFrame.Size = windowSize
    WindowFrame.Position = UDim2.new(0.5, -targetWidth / 2, 0.5, -targetHeight / 2)
    WindowFrame.BackgroundColor3 = theme.Background
    WindowFrame.BackgroundTransparency = theme.BackgroundTransparency
    WindowFrame.BorderSizePixel = 0
    WindowFrame.ClipsDescendants = true
    WindowFrame.Parent = ScreenGui

    local ContentContainer = nil
    local Window = nil

    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 11)
    windowCorner.Parent = WindowFrame

    local windowStroke = Instance.new("UIStroke")
    windowStroke.Color = theme.Border
    windowStroke.Thickness = 1
    windowStroke.Transparency = 0.35
    windowStroke.Parent = WindowFrame

    -- GPU-Accelerated Smooth Scaling & Window Animation
    local WindowScale = Instance.new("UIScale")
    WindowScale.Scale = 1
    WindowScale.Parent = WindowFrame

    -- SIDEBAR
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, SidebarWidth, 1, 0)
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.BackgroundColor3 = theme.Sidebar
    Sidebar.BackgroundTransparency = theme.SidebarTransparency
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = WindowFrame

    local sidebarBorder = Instance.new("Frame")
    sidebarBorder.Name = "BorderLine"
    sidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    sidebarBorder.Position = UDim2.new(1, -1, 0, 0)
    sidebarBorder.BackgroundColor3 = theme.Border
    sidebarBorder.BackgroundTransparency = 0.5
    sidebarBorder.BorderSizePixel = 0
    sidebarBorder.Parent = Sidebar

    -- Brand Header in Sidebar
    local BrandContainer = Instance.new("Frame")
    BrandContainer.Name = "BrandContainer"
    BrandContainer.Size = UDim2.new(1, 0, 0, 52)
    BrandContainer.BackgroundTransparency = 1
    BrandContainer.Parent = Sidebar

    local brandPad = Instance.new("UIPadding")
    brandPad.PaddingLeft = UDim.new(0, isSmallScreen and 10 or 14)
    brandPad.PaddingRight = UDim.new(0, 8)
    brandPad.PaddingTop = UDim.new(0, 10)
    brandPad.Parent = BrandContainer

    local BrandTitle = Instance.new("TextLabel")
    BrandTitle.Name = "BrandTitle"
    BrandTitle.Size = UDim2.new(1, 0, 0, 18)
    BrandTitle.BackgroundTransparency = 1
    BrandTitle.Font = theme.FontBold or Enum.Font.BuilderSansBold
    BrandTitle.Text = titleText
    BrandTitle.TextColor3 = theme.Text
    BrandTitle.TextSize = isSmallScreen and 15 or 16
    BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
    BrandTitle.Parent = BrandContainer

    local BrandSub = Instance.new("TextLabel")
    BrandSub.Name = "BrandSub"
    BrandSub.Size = UDim2.new(1, 0, 0, 14)
    BrandSub.Position = UDim2.new(0, 0, 0, 18)
    BrandSub.BackgroundTransparency = 1
    BrandSub.Font = theme.Font or Enum.Font.BuilderSans
    BrandSub.Text = subTitleText
    BrandSub.TextColor3 = theme.Accent
    BrandSub.TextSize = isSmallScreen and 11 or 12
    BrandSub.TextXAlignment = Enum.TextXAlignment.Left
    BrandSub.Parent = BrandContainer

    -- TAB LIST (Scrollable middle container)
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = profileEnabled and UDim2.new(1, -12, 1, -126) or UDim2.new(1, -12, 1, -58)
    TabList.Position = UDim2.new(0, 6, 0, 54)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 2
    TabList.ScrollBarImageColor3 = theme.Border
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabList.Parent = Sidebar

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.Parent = TabList

    -- USER PROFILE & SESSION PLAYTIME CARD (Pinned bottom of Sidebar - purely decorative, customizable)
    local PinnedContainer = Instance.new("Frame")
    PinnedContainer.Name = "PinnedProfile"
    PinnedContainer.Size = UDim2.new(1, -12, 0, 56)
    PinnedContainer.Position = UDim2.new(0, 6, 1, -62)
    PinnedContainer.BackgroundTransparency = 1
    PinnedContainer.Visible = profileEnabled
    PinnedContainer.Parent = Sidebar

    local pinnedDivider = Instance.new("Frame")
    pinnedDivider.Name = "Divider"
    pinnedDivider.Size = UDim2.new(1, 0, 0, 1)
    pinnedDivider.Position = UDim2.new(0, 0, 0, -4)
    pinnedDivider.BackgroundColor3 = theme.Border
    pinnedDivider.BackgroundTransparency = 0.6
    pinnedDivider.BorderSizePixel = 0
    pinnedDivider.Parent = PinnedContainer

    local ProfileCard = Instance.new("Frame")
    ProfileCard.Name = "ProfileCard"
    ProfileCard.Size = UDim2.new(1, 0, 1, 0)
    ProfileCard.BackgroundColor3 = theme.Card
    ProfileCard.BackgroundTransparency = 0.8
    ProfileCard.BorderSizePixel = 0
    ProfileCard.Parent = PinnedContainer

    local profCorner = Instance.new("UICorner")
    profCorner.CornerRadius = UDim.new(0, 8)
    profCorner.Parent = ProfileCard

    local profStroke = Instance.new("UIStroke")
    profStroke.Color = theme.Border
    profStroke.Thickness = 1
    profStroke.Transparency = 0.8
    profStroke.Parent = ProfileCard

    local avatarSize = (SidebarWidth < 125) and 28 or 34
    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.Name = "Avatar"
    AvatarImg.Size = UDim2.fromOffset(avatarSize, avatarSize)
    AvatarImg.AnchorPoint = Vector2.new(0, 0.5)
    AvatarImg.Position = UDim2.new(0, 6, 0.5, 0)
    AvatarImg.BackgroundColor3 = theme.Card
    AvatarImg.BackgroundTransparency = 0.4
    
    local defaultAvatar = "rbxthumb://type=AvatarHeadShot&id=" .. (LocalPlayer and LocalPlayer.UserId or 1) .. "&w=150&h=150"
    local profileAvatar = (type(profileCfg) == "table" and profileCfg.Avatar) or defaultAvatar
    AvatarImg.Image = profileAvatar
    AvatarImg.Parent = ProfileCard

    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(1, 0)
    avCorner.Parent = AvatarImg

    local avStroke = Instance.new("UIStroke")
    avStroke.Color = theme.Border
    avStroke.Thickness = 1
    avStroke.Transparency = 0.5
    avStroke.Parent = AvatarImg

    local UserInfoCol = Instance.new("Frame")
    UserInfoCol.Name = "Info"
    UserInfoCol.AnchorPoint = Vector2.new(0, 0.5)
    UserInfoCol.Size = UDim2.new(1, -avatarSize - 16, 0, 32)
    UserInfoCol.Position = UDim2.new(0, avatarSize + 12, 0.5, 0)
    UserInfoCol.BackgroundTransparency = 1
    UserInfoCol.Parent = ProfileCard

    local infoList = Instance.new("UIListLayout")
    infoList.SortOrder = Enum.SortOrder.LayoutOrder
    infoList.VerticalAlignment = Enum.VerticalAlignment.Center
    infoList.Padding = UDim.new(0, 2)
    infoList.Parent = UserInfoCol

    local defaultName = (LocalPlayer and (LocalPlayer.DisplayName ~= "" and LocalPlayer.DisplayName or LocalPlayer.Name)) or "Player"
    local profileTitle = defaultName
    if type(profileCfg) == "table" and profileCfg.Title ~= nil then
        profileTitle = tostring(profileCfg.Title)
    end

    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "Username"
    UsernameLabel.Size = UDim2.new(1, 0, 0, 16)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Font = theme.FontBold or Enum.Font.BuilderSansBold
    UsernameLabel.Text = profileTitle
    UsernameLabel.TextColor3 = theme.Text
    UsernameLabel.TextSize = (SidebarWidth < 125) and 12 or 13
    UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.Parent = UserInfoCol

    local PlaytimeLabel = Instance.new("TextLabel")
    PlaytimeLabel.Name = "Playtime"
    PlaytimeLabel.Size = UDim2.new(1, 0, 0, 14)
    PlaytimeLabel.BackgroundTransparency = 1
    PlaytimeLabel.Font = theme.FontMedium or Enum.Font.BuilderSansMedium
    PlaytimeLabel.TextColor3 = theme.Accent
    PlaytimeLabel.TextSize = (SidebarWidth < 125) and 11 or 12
    PlaytimeLabel.TextTruncate = Enum.TextTruncate.AtEnd
    PlaytimeLabel.TextXAlignment = Enum.TextXAlignment.Left
    PlaytimeLabel.Parent = UserInfoCol

    local customSubtitle = (type(profileCfg) == "table" and profileCfg.Subtitle ~= nil) and tostring(profileCfg.Subtitle) or nil
    if customSubtitle then
        PlaytimeLabel.Text = customSubtitle
    else
        PlaytimeLabel.Text = "Đã dùng: 00:00:00"
        local sessionStartTime = os.time()
        task.spawn(function()
            while ProfileCard and ProfileCard.Parent and profileEnabled do
                local elapsed = os.time() - sessionStartTime
                local h = math.floor(elapsed / 3600)
                local m = math.floor((elapsed % 3600) / 60)
                local s = elapsed % 60
                PlaytimeLabel.Text = string.format("Đã dùng: %02d:%02d:%02d", h, m, s)
                task.wait(1)
            end
        end)
    end

    -- TOPBAR
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, -SidebarWidth, 0, 44)
    Topbar.Position = UDim2.new(0, SidebarWidth, 0, 0)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = WindowFrame

    local topbarDivider = Instance.new("Frame")
    topbarDivider.Name = "Divider"
    topbarDivider.Size = UDim2.new(1, 0, 0, 1)
    topbarDivider.Position = UDim2.new(0, 0, 1, -1)
    topbarDivider.BackgroundColor3 = theme.Border
    topbarDivider.BackgroundTransparency = 0.6
    topbarDivider.BorderSizePixel = 0
    topbarDivider.Parent = Topbar

    local CurrentTabTitle = Instance.new("TextLabel")
    CurrentTabTitle.Name = "CurrentTabTitle"
    CurrentTabTitle.Size = UDim2.new(1, -95, 1, 0)
    CurrentTabTitle.Position = UDim2.new(0, 16, 0, 0)
    CurrentTabTitle.BackgroundTransparency = 1
    CurrentTabTitle.Font = theme.FontBold or Enum.Font.BuilderSansBold
    CurrentTabTitle.Text = "Home"
    CurrentTabTitle.TextColor3 = theme.Text
    CurrentTabTitle.TextSize = 15
    CurrentTabTitle.TextXAlignment = Enum.TextXAlignment.Left
    CurrentTabTitle.Parent = Topbar

    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.Size = UDim2.new(0, 70, 1, 0)
    Controls.Position = UDim2.new(1, -80, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Topbar

    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    controlsLayout.Padding = UDim.new(0, 6)
    controlsLayout.Parent = Controls

    local function createControlButton(name: string, iconAsset: string, order: number, isClose: boolean, callback: () -> ())
        local btn = Instance.new("ImageButton")
        btn.Name = name
        btn.Size = UDim2.fromOffset(26, 26)
        btn.BackgroundColor3 = theme.Card
        btn.BackgroundTransparency = theme.CardTransparency
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        btn.Parent = Controls

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 7)
        btnCorner.Parent = btn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = theme.Border
        btnStroke.Thickness = 1
        btnStroke.Transparency = 0.5
        btnStroke.Parent = btn

        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.fromOffset(13, 13)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromScale(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = iconAsset
        icon.ImageColor3 = isClose and Color3.fromRGB(255, 110, 110) or theme.TextMuted
        icon.Parent = btn

        btn.MouseEnter:Connect(function()
            if isClose then
                tween(btn, 0.15, {BackgroundColor3 = Color3.fromRGB(231, 76, 60), BackgroundTransparency = 0})
                tween(icon, 0.15, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
            else
                tween(btn, 0.15, {BackgroundColor3 = theme.CardHover, BackgroundTransparency = 0.15})
                tween(icon, 0.15, {ImageColor3 = theme.Accent})
            end
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, 0.15, {BackgroundColor3 = theme.Card, BackgroundTransparency = theme.CardTransparency})
            tween(icon, 0.15, {ImageColor3 = isClose and Color3.fromRGB(255, 110, 110) or theme.TextMuted})
        end)
        btn.Activated:Connect(callback)
        return btn
    end

    local isMinimized = false
    local originalHeight = targetHeight
    local originalWidth = targetWidth

    local function toggleMinimize()
        isMinimized = not isMinimized
        if isMinimized then
            originalHeight = WindowFrame.AbsoluteSize.Y
            originalWidth = WindowFrame.AbsoluteSize.X
            Sidebar.Visible = false
            if ContentContainer then
                ContentContainer.Visible = false
            end
            topbarDivider.Visible = false

            -- Hide all dialog overlays and popups during minimize
            for _, child in ipairs(WindowFrame:GetChildren()) do
                if child.Name == "DialogOverlay" then
                    child.Visible = false
                end
            end

            Topbar.Size = UDim2.new(1, 0, 0, 44)
            Topbar.Position = UDim2.new(0, 0, 0, 0)
            CurrentTabTitle.Position = UDim2.new(0, 14, 0, 0)
            CurrentTabTitle.Size = UDim2.new(1, -78, 1, 0)
            CurrentTabTitle.TextTruncate = Enum.TextTruncate.AtEnd
            CurrentTabTitle.Text = titleText .. "  •  " .. (Window and Window.CurrentTab and Window.CurrentTab.Title or "Thu nhỏ")

            local minWidth = math.clamp(math.floor(originalWidth * 0.5), 240, 320)
            tween(WindowFrame, 0.24, {Size = UDim2.fromOffset(minWidth, 44)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        else
            Sidebar.Visible = true
            if ContentContainer then
                ContentContainer.Visible = true
            end
            topbarDivider.Visible = true

            -- Restore dialog overlays if open
            for _, child in ipairs(WindowFrame:GetChildren()) do
                if child.Name == "DialogOverlay" then
                    child.Visible = true
                end
            end

            Topbar.Size = UDim2.new(1, -SidebarWidth, 0, 44)
            Topbar.Position = UDim2.new(0, SidebarWidth, 0, 0)
            CurrentTabTitle.Position = UDim2.new(0, 16, 0, 0)
            CurrentTabTitle.Size = UDim2.new(1, -95, 1, 0)
            CurrentTabTitle.Text = (Window and Window.CurrentTab and Window.CurrentTab.Title) or "Home"
            local restoreH = math.max(originalHeight or targetHeight, 250)
            local restoreW = math.max(originalWidth or targetWidth, 320)
            local curCamera = workspace.CurrentCamera
            local curVp = curCamera and curCamera.ViewportSize or Vector2.new(1920, 1080)
            local curX = WindowFrame.AbsolutePosition.X
            local curY = WindowFrame.AbsolutePosition.Y
            if curX + restoreW > curVp.X - 10 then
                local adjustedX = math.max(10, curVp.X - restoreW - 20)
                tween(WindowFrame, 0.24, {Position = UDim2.fromOffset(adjustedX, curY)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            end
            tween(WindowFrame, 0.24, {Size = UDim2.fromOffset(restoreW, restoreH)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end
    end

    -- Order: [-] on the left (1), [X] on the right (2)
    createControlButton("MinBtn", "rbxassetid://10734896206", 1, false, toggleMinimize)

    local isVisible = true

    local function setWindowVisible(vis: boolean)
        if vis then
            isVisible = true
            WindowFrame.Visible = true
            tween(WindowScale, 0.16, {Scale = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tween(WindowFrame, 0.14, {BackgroundTransparency = theme.BackgroundTransparency})
        else
            isVisible = false
            tween(WindowScale, 0.14, {Scale = 0.95}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            local fade = tween(WindowFrame, 0.14, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.15, function()
                if not isVisible then
                    WindowFrame.Visible = false
                    WindowScale.Scale = 1
                    WindowFrame.BackgroundTransparency = theme.BackgroundTransparency
                end
            end)
        end
    end

    createControlButton("CloseBtn", "rbxassetid://10747384394", 2, true, function()
        setWindowVisible(false)
        SonLibrary:Notify({
            Title = titleText,
            Content = "Menu đã ẩn. Nhấn icon trên thanh Topbar để mở lại.",
            Duration = 2.5,
            Type = "Info"
        })
    end)

    -- Toggle Hotkey (Keyboard)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            setWindowVisible(not isVisible)
        end
    end)

    -- NATIVE-STYLE TOPBAR BUTTON (Pure Icon circle, no text, matches game's topbar exactly)
    local TopbarIconBtn = nil
    if enableTopbarButton then
        local logoAsset = getSonHubLogoAsset()
        local topbarContainer = nil

        pcall(function()
            local p = Players.LocalPlayer
            local tbStandard = p and p:FindFirstChild("PlayerGui") and p.PlayerGui:FindFirstChild("TopbarStandard", true)
            if tbStandard and tbStandard:FindFirstChild("Holders") and tbStandard.Holders:FindFirstChild("Left") then
                topbarContainer = tbStandard.Holders.Left
            end
        end)

        local IconWidget = Instance.new("Frame")
        IconWidget.Name = "SonHubTopbarIcon"
        IconWidget.Size = UDim2.fromOffset(44, 44)
        IconWidget.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
        IconWidget.BackgroundTransparency = 0.08
        IconWidget.BorderSizePixel = 0
        IconWidget.LayoutOrder = 105

        local widgetCorner = Instance.new("UICorner")
        widgetCorner.CornerRadius = UDim.new(1, 0)
        widgetCorner.Parent = IconWidget

        local ClickBtn = Instance.new("ImageButton")
        ClickBtn.Name = "ClickRegion"
        ClickBtn.Size = UDim2.fromScale(1, 1)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.AutoButtonColor = false
        ClickBtn.Parent = IconWidget

        local LogoImg = Instance.new("ImageLabel")
        LogoImg.Name = "Logo"
        LogoImg.Size = UDim2.fromOffset(26, 26)
        LogoImg.AnchorPoint = Vector2.new(0.5, 0.5)
        LogoImg.Position = UDim2.fromScale(0.5, 0.5)
        LogoImg.BackgroundTransparency = 1
        LogoImg.Image = logoAsset or "rbxassetid://10723346959"
        LogoImg.Parent = ClickBtn

        local imgCorner = Instance.new("UICorner")
        imgCorner.CornerRadius = UDim.new(0.3, 0)
        imgCorner.Parent = LogoImg

        ClickBtn.MouseEnter:Connect(function()
            tween(IconWidget, 0.15, {BackgroundColor3 = Color3.fromRGB(36, 38, 48), BackgroundTransparency = 0})
            tween(LogoImg, 0.15, {Size = UDim2.fromOffset(28, 28)})
        end)

        ClickBtn.MouseLeave:Connect(function()
            tween(IconWidget, 0.15, {BackgroundColor3 = Color3.fromRGB(18, 18, 21), BackgroundTransparency = 0.08})
            tween(LogoImg, 0.15, {Size = UDim2.fromOffset(26, 26)})
        end)

        ClickBtn.Activated:Connect(function()
            setWindowVisible(not isVisible)
            tween(LogoImg, 0.1, {Size = UDim2.fromOffset(22, 22)}).Completed:Connect(function()
                tween(LogoImg, 0.1, {Size = UDim2.fromOffset(26, 26)})
            end)
        end)

        if topbarContainer then
            IconWidget.Parent = topbarContainer
        else
            IconWidget.Position = UDim2.new(0, 380, 0, 4)
            IconWidget.Parent = ScreenGui
        end

        TopbarIconBtn = IconWidget
    end

    -- HIGH-PERFORMANCE ZERO-LAG DRAGGING
    local isDragging = false
    local dragStart = Vector2.zero
    local startPos = Vector2.zero
    local dragMoveConn = nil

    local function setupDragOn(frame)
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                dragStart = Vector2.new(input.Position.X, input.Position.Y)
                startPos = Vector2.new(WindowFrame.AbsolutePosition.X, WindowFrame.AbsolutePosition.Y)

                if dragMoveConn then dragMoveConn:Disconnect() end
                dragMoveConn = UserInputService.InputChanged:Connect(function(moveInput)
                    if not isDragging then return end
                    if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                        local delta = Vector2.new(moveInput.Position.X, moveInput.Position.Y) - dragStart
                        local curCamera = workspace.CurrentCamera
                        local curVp = curCamera and curCamera.ViewportSize or Vector2.new(1920, 1080)
                        local winW = WindowFrame.AbsoluteSize.X
                        local nx = math.clamp(startPos.X + delta.X, -winW + 80, curVp.X - 80)
                        local ny = math.clamp(startPos.Y + delta.Y, 0, curVp.Y - 40)
                        WindowFrame.Position = UDim2.fromOffset(nx, ny)
                    end
                end)

                local endConn
                endConn = UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        isDragging = false
                        if dragMoveConn then
                            dragMoveConn:Disconnect()
                            dragMoveConn = nil
                        end
                        if endConn then
                            endConn:Disconnect()
                        end
                    end
                end)
            end
        end)
    end

    setupDragOn(Topbar)
    setupDragOn(BrandContainer)

    -- Dynamic Screen Boundary Guard & Adaptive Resizing (Rotation / Window resize)
    if camera then
        camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            local vp = camera.ViewportSize
            local maxAllowedW = math.clamp(vp.X - 16, 280, defaultWidth)
            local maxAllowedH = math.clamp(vp.Y - 48, 230, defaultHeight)

            if not isMinimized then
                local curW = WindowFrame.AbsoluteSize.X
                local curH = WindowFrame.AbsoluteSize.Y
                local newW = math.min(curW, maxAllowedW)
                local newH = math.min(curH, maxAllowedH)
                if newW ~= curW or newH ~= curH then
                    WindowFrame.Size = UDim2.fromOffset(newW, newH)
                end
            end

            local curX = WindowFrame.AbsolutePosition.X
            local curY = WindowFrame.AbsolutePosition.Y
            local winW = WindowFrame.AbsoluteSize.X
            local clampedX = math.clamp(curX, -winW + 80, math.max(4, vp.X - 80))
            local clampedY = math.clamp(curY, 0, math.max(4, vp.Y - 40))
            if clampedX ~= curX or clampedY ~= curY then
                WindowFrame.Position = UDim2.fromOffset(clampedX, clampedY)
            end
        end)
    end

    -- CONTENT CONTAINER (Scrollable tab pages)
    ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -SidebarWidth - 16, 1, -54)
    ContentContainer.Position = UDim2.new(0, SidebarWidth + 8, 0, 48)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = WindowFrame

    Window = {
        ScreenGui = ScreenGui,
        Frame = WindowFrame,
        TopbarButton = TopbarIconBtn,
        Theme = theme,
        Tabs = {},
        CurrentTab = nil,
    }

    local function selectTab(tab)
        if not tab then return end
        if Window.CurrentTab == tab and tab.Page and tab.Page.Visible then return end

        for _, t in ipairs(Window.Tabs) do
            if t.Page and t.Page.Parent then
                t.Page.Visible = (t == tab)
            end
            if t.Button then
                tween(t.Button, 0.15, {BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1})
                if t.Button:FindFirstChild("Title") then
                    tween(t.Button.Title, 0.15, {TextColor3 = theme.TextMuted})
                end
                if t.Button:FindFirstChild("TabIcon") then
                    tween(t.Button.TabIcon, 0.15, {ImageColor3 = theme.TextMuted})
                end
                if t.Button:FindFirstChild("Indicator") then
                    tween(t.Button.Indicator, 0.15, {BackgroundTransparency = 1, Size = UDim2.new(0, 3, 0, 0)})
                end
            end
        end

        Window.CurrentTab = tab
        if CurrentTabTitle then
            CurrentTabTitle.Text = tab.Title
        end

        if tab.Button then
            tween(tab.Button, 0.15, {BackgroundColor3 = theme.CardHover, BackgroundTransparency = 0.4})
            if tab.Button:FindFirstChild("Title") then
                tween(tab.Button.Title, 0.15, {TextColor3 = theme.Text})
            end
            if tab.Button:FindFirstChild("TabIcon") then
                tween(tab.Button.TabIcon, 0.15, {ImageColor3 = theme.Text})
            end
            if tab.Button:FindFirstChild("Indicator") then
                tween(tab.Button.Indicator, 0.15, {BackgroundTransparency = 0, Size = UDim2.new(0, 3, 0, 18)})
            end
        end

        if tab.Page then
            tab.Page.Visible = true
            tab.Page.Position = UDim2.new(0, 0, 0, 0)
            local layout = tab.Page:FindFirstChildOfClass("UIListLayout")
            if layout then
                tab.Page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 28)
            end
            task.defer(function()
                if tab.Page and tab.Page.Parent and layout then
                    tab.Page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 28)
                end
            end)
        end
    end

    function Window:CreateTab(tabConfig: {Title: string, Icon: string?}): any
        local tabTitle = tabConfig.Title or "Tab"
        local tabIconAsset = tabConfig.Icon

        local Page = Instance.new("ScrollingFrame")
        Page.Name = "Page_" .. tabTitle
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Position = UDim2.new(0, 0, 0, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = theme.Border
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.None
        Page.Visible = false
        Page.Parent = ContentContainer

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.Parent = Page

        local function updateCanvas()
            if Page and Page.Parent and pageLayout then
                Page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 28)
            end
        end
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

        local pagePadding = Instance.new("UIPadding")
        pagePadding.PaddingRight = UDim.new(0, 8)
        pagePadding.PaddingLeft = UDim.new(0, 2)
        pagePadding.PaddingTop = UDim.new(0, 2)
        pagePadding.PaddingBottom = UDim.new(0, 12)
        pagePadding.Parent = Page

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "TabBtn_" .. tabTitle
        TabBtn.Size = UDim2.new(1, 0, 0, 34)
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.AutoButtonColor = false
        TabBtn.Text = ""
        TabBtn.Parent = TabList

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 7)
        tabCorner.Parent = TabBtn

        local activeIndicator = Instance.new("Frame")
        activeIndicator.Name = "Indicator"
        activeIndicator.Size = UDim2.new(0, 3, 0, 0)
        activeIndicator.Position = UDim2.new(0, 2, 0.5, -9)
        activeIndicator.BackgroundColor3 = theme.Accent
        activeIndicator.BorderSizePixel = 0
        activeIndicator.BackgroundTransparency = 1
        activeIndicator.Parent = TabBtn

        local indCorner = Instance.new("UICorner")
        indCorner.CornerRadius = UDim.new(1, 0)
        indCorner.Parent = activeIndicator

        local TabIcon = nil
        if tabIconAsset then
            TabIcon = Instance.new("ImageLabel")
            TabIcon.Name = "TabIcon"
            TabIcon.Size = UDim2.fromOffset(16, 16)
            TabIcon.Position = UDim2.new(0, 10, 0.5, -8)
            TabIcon.BackgroundTransparency = 1
            TabIcon.Image = tabIconAsset
            TabIcon.ImageColor3 = theme.TextMuted
            TabIcon.Parent = TabBtn
        end

        local tabTitleLbl = Instance.new("TextLabel")
        tabTitleLbl.Name = "Title"
        tabTitleLbl.Size = TabIcon and UDim2.new(1, -34, 1, 0) or UDim2.new(1, -24, 1, 0)
        tabTitleLbl.Position = TabIcon and UDim2.new(0, 32, 0, 0) or UDim2.new(0, 14, 0, 0)
        tabTitleLbl.BackgroundTransparency = 1
        tabTitleLbl.Font = theme.FontMedium or Enum.Font.BuilderSansMedium
        tabTitleLbl.Text = tabTitle
        tabTitleLbl.TextColor3 = theme.TextMuted
        tabTitleLbl.TextSize = 13.5
        tabTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        tabTitleLbl.Parent = TabBtn

        local Tab = {
            Title = tabTitle,
            Button = TabBtn,
            Page = Page,
            Container = Page,
            GetContainer = function() return Page end,
            GetPage = function() return Page end,
            Select = function(self) selectTab(self) end,
        }

        TabBtn.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                tween(TabBtn, 0.15, {BackgroundTransparency = 0.8, BackgroundColor3 = theme.CardHover})
                tween(tabTitleLbl, 0.15, {TextColor3 = theme.Text})
                if TabIcon then tween(TabIcon, 0.15, {ImageColor3 = theme.Text}) end
            end
        end)

        TabBtn.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                tween(TabBtn, 0.15, {BackgroundTransparency = 1})
                tween(tabTitleLbl, 0.15, {TextColor3 = theme.TextMuted})
                if TabIcon then tween(TabIcon, 0.15, {ImageColor3 = theme.TextMuted}) end
            end
        end)

        TabBtn.Activated:Connect(function()
            selectTab(Tab)
        end)

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 or (config.DefaultTab and config.DefaultTab == tabTitle) then
            selectTab(Tab)
        end

        -- SECTION
        function Tab:CreateSection(secTitle: string)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "Section_" .. secTitle
            SectionFrame.Size = UDim2.new(1, 0, 0, 26)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Parent = Page

            local SecText = Instance.new("TextLabel")
            SecText.Name = "Title"
            SecText.Size = UDim2.new(0, 0, 1, 0)
            SecText.AutomaticSize = Enum.AutomaticSize.X
            SecText.BackgroundTransparency = 1
            SecText.Font = theme.FontBold or Enum.Font.BuilderSansBold
            SecText.Text = string.upper(secTitle)
            SecText.TextColor3 = theme.Accent
            SecText.TextSize = 12
            SecText.TextXAlignment = Enum.TextXAlignment.Left
            SecText.Parent = SectionFrame

            local SecLine = Instance.new("Frame")
            SecLine.Name = "Line"
            SecLine.Size = UDim2.new(1, -SecText.TextBounds.X - 14, 0, 1)
            SecLine.Position = UDim2.new(0, SecText.TextBounds.X + 12, 0.5, 0)
            SecLine.BackgroundColor3 = theme.Border
            SecLine.BackgroundTransparency = 0.5
            SecLine.BorderSizePixel = 0
            SecLine.Parent = SectionFrame

            SecText:GetPropertyChangedSignal("TextBounds"):Connect(function()
                SecLine.Size = UDim2.new(1, -SecText.TextBounds.X - 14, 0, 1)
                SecLine.Position = UDim2.new(0, SecText.TextBounds.X + 12, 0.5, 0)
            end)

            return SectionFrame
        end

        -- DIVIDER
        function Tab:CreateDivider()
            local Div = Instance.new("Frame")
            Div.Name = "Divider"
            Div.Size = UDim2.new(1, 0, 0, 1)
            Div.BackgroundColor3 = theme.Border
            Div.BackgroundTransparency = 0.6
            Div.BorderSizePixel = 0
            Div.Parent = Page
            return Div
        end

        -- BUTTON
        function Tab:CreateButton(btnConfig: {Name: string, Description: string?, Callback: () -> ()})
            local name = btnConfig.Name or "Button"
            local desc = btnConfig.Description
            local callback = btnConfig.Callback or function() end

            local Card = Instance.new("TextButton")
            Card.Name = "Btn_" .. name
            Card.Size = UDim2.new(1, 0, 0, desc and 48 or 38)
            Card.BackgroundColor3 = theme.Card
            Card.BackgroundTransparency = theme.CardTransparency
            Card.BorderSizePixel = 0
            Card.AutoButtonColor = false
            Card.Text = ""
            Card.Parent = Page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = Card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = theme.Border
            cardStroke.Thickness = 1
            cardStroke.Transparency = 0.6
            cardStroke.Parent = Card

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Name = "Title"
            titleLbl.Size = UDim2.new(1, -40, 0, 18)
            titleLbl.Position = UDim2.new(0, 12, 0, desc and 6 or 10)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Font = theme.FontMedium or Enum.Font.BuilderSansMedium
            titleLbl.Text = name
            titleLbl.TextColor3 = theme.Text
            titleLbl.TextSize = 14
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = Card

            if desc then
                local descLbl = Instance.new("TextLabel")
                descLbl.Name = "Desc"
                descLbl.Size = UDim2.new(1, -40, 0, 15)
                descLbl.Position = UDim2.new(0, 12, 0, 26)
                descLbl.BackgroundTransparency = 1
                descLbl.Font = theme.Font or Enum.Font.BuilderSans
                descLbl.Text = desc
                descLbl.TextColor3 = theme.TextMuted
                descLbl.TextSize = 12
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.Parent = Card
            end

            local actionIcon = Instance.new("TextLabel")
            actionIcon.Name = "ActionIcon"
            actionIcon.Size = UDim2.fromOffset(20, 20)
            actionIcon.Position = UDim2.new(1, -30, 0.5, -10)
            actionIcon.BackgroundTransparency = 1
            actionIcon.Font = theme.FontBold or Enum.Font.BuilderSansBold
            actionIcon.Text = ">"
            actionIcon.TextColor3 = theme.TextDark
            actionIcon.TextSize = 13
            actionIcon.Parent = Card

            Card.MouseEnter:Connect(function()
                tween(Card, 0.15, {BackgroundColor3 = theme.CardHover, BackgroundTransparency = 0.15})
                tween(cardStroke, 0.15, {Color = theme.BorderActive})
                tween(actionIcon, 0.15, {TextColor3 = theme.Accent})
            end)

            Card.MouseLeave:Connect(function()
                tween(Card, 0.15, {BackgroundColor3 = theme.Card, BackgroundTransparency = theme.CardTransparency})
                tween(cardStroke, 0.15, {Color = theme.Border})
                tween(actionIcon, 0.15, {TextColor3 = theme.TextDark})
            end)

            Card.Activated:Connect(function()
                tween(Card, 0.08, {BackgroundColor3 = theme.CardActive}).Completed:Connect(function()
                    tween(Card, 0.12, {BackgroundColor3 = theme.CardHover})
                end)
                pcall(callback)
            end)

            return Card
        end

        -- TOGGLE
        function Tab:CreateToggle(toggleConfig: {Name: string, Description: string?, Default: boolean?, Callback: (boolean) -> ()})
            local name = toggleConfig.Name or "Toggle"
            local desc = toggleConfig.Description
            local state = toggleConfig.Default or false
            local callback = toggleConfig.Callback or function() end

            local Card = Instance.new("TextButton")
            Card.Name = "Toggle_" .. name
            Card.Size = UDim2.new(1, 0, 0, desc and 48 or 40)
            Card.BackgroundColor3 = theme.Card
            Card.BackgroundTransparency = theme.CardTransparency
            Card.BorderSizePixel = 0
            Card.AutoButtonColor = false
            Card.Text = ""
            Card.Parent = Page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = Card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = theme.Border
            cardStroke.Thickness = 1
            cardStroke.Transparency = 0.6
            cardStroke.Parent = Card

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Name = "Title"
            titleLbl.Size = UDim2.new(1, -64, 0, 18)
            titleLbl.Position = UDim2.new(0, 12, 0, desc and 6 or 11)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Font = theme.FontMedium or Enum.Font.BuilderSansMedium
            titleLbl.Text = name
            titleLbl.TextColor3 = theme.Text
            titleLbl.TextSize = 14
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = Card

            if desc then
                local descLbl = Instance.new("TextLabel")
                descLbl.Name = "Desc"
                descLbl.Size = UDim2.new(1, -64, 0, 15)
                descLbl.Position = UDim2.new(0, 12, 0, 26)
                descLbl.BackgroundTransparency = 1
                descLbl.Font = theme.Font or Enum.Font.BuilderSans
                descLbl.Text = desc
                descLbl.TextColor3 = theme.TextMuted
                descLbl.TextSize = 12
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.Parent = Card
            end

            local Track = Instance.new("Frame")
            Track.Name = "Track"
            Track.Size = UDim2.fromOffset(38, 20)
            Track.Position = UDim2.new(1, -50, 0.5, -10)
            Track.BackgroundColor3 = state and theme.Accent or Color3.fromRGB(42, 47, 63)
            Track.BorderSizePixel = 0
            Track.Parent = Card

            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = Track

            local Knob = Instance.new("Frame")
            Knob.Name = "Knob"
            Knob.Size = UDim2.fromOffset(14, 14)
            Knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel = 0
            Knob.Parent = Track

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = Knob

            local function updateToggle(val: boolean, fireCallback: boolean)
                state = val
                local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                local targetColor = state and theme.Accent or Color3.fromRGB(42, 47, 63)

                tween(Knob, 0.2, {Position = targetPos})
                tween(Track, 0.2, {BackgroundColor3 = targetColor})

                if fireCallback then
                    pcall(callback, state)
                end
            end

            Card.MouseEnter:Connect(function()
                tween(Card, 0.15, {BackgroundColor3 = theme.CardHover, BackgroundTransparency = 0.15})
                tween(cardStroke, 0.15, {Color = theme.BorderActive})
            end)

            Card.MouseLeave:Connect(function()
                tween(Card, 0.15, {BackgroundColor3 = theme.Card, BackgroundTransparency = theme.CardTransparency})
                tween(cardStroke, 0.15, {Color = theme.Border})
            end)

            Card.Activated:Connect(function()
                updateToggle(not state, true)
            end)

            local ToggleObj = {
                Value = state,
                Set = function(_, val) updateToggle(val, true) end,
                SilentSet = function(_, val) updateToggle(val, false) end,
            }
            return ToggleObj
        end

        -- SLIDER
        function Tab:CreateSlider(sliderConfig: {
            Name: string,
            Description: string?,
            Min: number,
            Max: number,
            Default: number?,
            Precision: number?,
            Suffix: string?,
            Callback: (number) -> ()
        })
            local name = sliderConfig.Name or "Slider"
            local desc = sliderConfig.Description
            local min = sliderConfig.Min or 0
            local max = sliderConfig.Max or 100
            local default = math.clamp(sliderConfig.Default or min, min, max)
            local precision = sliderConfig.Precision or 0
            local suffix = sliderConfig.Suffix or ""
            local callback = sliderConfig.Callback or function() end

            local currentVal = default

            local Card = Instance.new("Frame")
            Card.Name = "Slider_" .. name
            Card.Size = UDim2.new(1, 0, 0, desc and 54 or 46)
            Card.BackgroundColor3 = theme.Card
            Card.BackgroundTransparency = theme.CardTransparency
            Card.BorderSizePixel = 0
            Card.Parent = Page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = Card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = theme.Border
            cardStroke.Thickness = 1
            cardStroke.Transparency = 0.6
            cardStroke.Parent = Card

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Name = "Title"
            titleLbl.Size = UDim2.new(1, -90, 0, 16)
            titleLbl.Position = UDim2.new(0, 12, 0, 6)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Font = theme.FontMedium or Enum.Font.BuilderSansMedium
            titleLbl.Text = name
            titleLbl.TextColor3 = theme.Text
            titleLbl.TextSize = 13.5
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = Card

            local valueLbl = Instance.new("TextLabel")
            valueLbl.Name = "Value"
            valueLbl.Size = UDim2.new(0, 70, 0, 16)
            valueLbl.Position = UDim2.new(1, -82, 0, 6)
            valueLbl.BackgroundTransparency = 1
            valueLbl.Font = theme.FontBold or Enum.Font.BuilderSansBold
            valueLbl.Text = tostring(currentVal) .. suffix
            valueLbl.TextColor3 = theme.Accent
            valueLbl.TextSize = 12.5
            valueLbl.TextXAlignment = Enum.TextXAlignment.Right
            valueLbl.Parent = Card

            local Track = Instance.new("TextButton")
            Track.Name = "Track"
            Track.Size = UDim2.new(1, -24, 0, 6)
            Track.Position = UDim2.new(0, 12, 1, -14)
            Track.BackgroundColor3 = Color3.fromRGB(38, 43, 58)
            Track.BorderSizePixel = 0
            Track.AutoButtonColor = false
            Track.Text = ""
            Track.Parent = Card

            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = Track

            local Fill = Instance.new("Frame")
            Fill.Name = "Fill"
            local initialAlpha = (currentVal - min) / (max - min)
            Fill.Size = UDim2.new(initialAlpha, 0, 1, 0)
            Fill.BackgroundColor3 = theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Track

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = Fill

            local Knob = Instance.new("Frame")
            Knob.Name = "Knob"
            Knob.Size = UDim2.fromOffset(12, 12)
            Knob.Position = UDim2.new(1, -6, 0.5, -6)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel = 0
            Knob.Parent = Fill

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = Knob

            local sliding = false
            local moveConn = nil
            local endConn = nil

            local function updateSlider(inputX: number)
                local trackAbsolutePos = Track.AbsolutePosition.X
                local trackAbsoluteSize = Track.AbsoluteSize.X
                local alpha = math.clamp((inputX - trackAbsolutePos) / trackAbsoluteSize, 0, 1)

                local rawVal = min + (alpha * (max - min))
                local factor = 10 ^ precision
                local steppedVal = math.floor(rawVal * factor + 0.5) / factor

                currentVal = steppedVal
                valueLbl.Text = tostring(steppedVal) .. suffix
                tween(Fill, 0.05, {Size = UDim2.new(alpha, 0, 1, 0)})

                pcall(callback, steppedVal)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    updateSlider(input.Position.X)

                    if moveConn then moveConn:Disconnect() end
                    if endConn then endConn:Disconnect() end

                    moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                        if sliding and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
                            updateSlider(moveInput.Position.X)
                        end
                    end)

                    endConn = UserInputService.InputEnded:Connect(function(endInput)
                        if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                            sliding = false
                            if moveConn then moveConn:Disconnect() moveConn = nil end
                            if endConn then endConn:Disconnect() endConn = nil end
                        end
                    end)
                end
            end)

            local SliderObj = {
                Value = currentVal,
                Set = function(_, val)
                    val = math.clamp(val, min, max)
                    local alpha = (val - min) / (max - min)
                    currentVal = val
                    valueLbl.Text = tostring(val) .. suffix
                    tween(Fill, 0.15, {Size = UDim2.new(alpha, 0, 1, 0)})
                    pcall(callback, val)
                end
            }
            return SliderObj
        end

        -- DROPDOWN (Accurate Selection Sync, Option Highlighting & Optional Search)
        function Tab:CreateDropdown(dropConfig: {
            Name: string,
            Description: string?,
            Options: {string},
            Default: string?,
            Searchable: boolean?,
            Callback: (string) -> ()
        })
            local name = dropConfig.Name or "Dropdown"
            local desc = dropConfig.Description
            local options = dropConfig.Options or {}
            local current = dropConfig.Default or options[1] or "Select..."
            local isSearchable = dropConfig.Searchable == true
            local callback = dropConfig.Callback or function() end

            local isOpen = false
            local optionButtons = {}
            local filterQuery = ""

            local Card = Instance.new("Frame")
            Card.Name = "Drop_" .. name
            Card.Size = UDim2.new(1, 0, 0, 42)
            Card.BackgroundColor3 = theme.Card
            Card.BackgroundTransparency = theme.CardTransparency
            Card.BorderSizePixel = 0
            Card.ClipsDescendants = true
            Card.Parent = Page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = Card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = theme.Border
            cardStroke.Thickness = 1
            cardStroke.Transparency = 0.6
            cardStroke.Parent = Card

            local HeaderBtn = Instance.new("TextButton")
            HeaderBtn.Name = "Header"
            HeaderBtn.Size = UDim2.new(1, 0, 0, 42)
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.AutoButtonColor = false
            HeaderBtn.Text = ""
            HeaderBtn.Parent = Card

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Name = "Title"
            titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
            titleLbl.Position = UDim2.new(0, 12, 0, 0)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Font = theme.FontMedium or Enum.Font.BuilderSansMedium
            titleLbl.Text = name
            titleLbl.TextColor3 = theme.Text
            titleLbl.TextSize = 13.5
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = HeaderBtn

            local selectedLbl = Instance.new("TextLabel")
            selectedLbl.Name = "SelectedLabel"
            selectedLbl.Size = UDim2.new(0.5, -42, 1, 0)
            selectedLbl.Position = UDim2.new(0.5, 0, 0, 0)
            selectedLbl.BackgroundTransparency = 1
            selectedLbl.Font = theme.Font or Enum.Font.BuilderSans
            selectedLbl.Text = current
            selectedLbl.TextColor3 = theme.Accent
            selectedLbl.TextSize = 12.5
            selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
            selectedLbl.Parent = HeaderBtn

            local arrowIcon = Instance.new("TextLabel")
            arrowIcon.Name = "Arrow"
            arrowIcon.Size = UDim2.fromOffset(20, 20)
            arrowIcon.Position = UDim2.new(1, -28, 0.5, -10)
            arrowIcon.BackgroundTransparency = 1
            arrowIcon.Font = theme.FontBold or Enum.Font.BuilderSansBold
            arrowIcon.Text = "v"
            arrowIcon.TextColor3 = theme.TextDark
            arrowIcon.TextSize = 12
            arrowIcon.Parent = HeaderBtn

            local SearchBox = nil
            local SearchInput = nil
            if isSearchable then
                SearchBox = Instance.new("Frame")
                SearchBox.Name = "SearchBox"
                SearchBox.Size = UDim2.new(1, -16, 0, 26)
                SearchBox.Position = UDim2.new(0, 8, 0, 44)
                SearchBox.BackgroundColor3 = Color3.fromRGB(20, 23, 33)
                SearchBox.BorderSizePixel = 0
                SearchBox.Parent = Card

                local sCorner = Instance.new("UICorner")
                sCorner.CornerRadius = UDim.new(0, 6)
                sCorner.Parent = SearchBox

                local sStroke = Instance.new("UIStroke")
                sStroke.Color = theme.Border
                sStroke.Thickness = 1
                sStroke.Transparency = 0.55
                sStroke.Parent = SearchBox

                local searchIcon = Instance.new("ImageLabel")
                searchIcon.Name = "Icon"
                searchIcon.Size = UDim2.fromOffset(13, 13)
                searchIcon.Position = UDim2.new(0, 7, 0.5, -6)
                searchIcon.BackgroundTransparency = 1
                searchIcon.Image = "rbxassetid://10734886676"
                searchIcon.ImageColor3 = theme.TextDark
                searchIcon.Parent = SearchBox

                SearchInput = Instance.new("TextBox")
                SearchInput.Name = "Input"
                SearchInput.Size = UDim2.new(1, -28, 1, 0)
                SearchInput.Position = UDim2.new(0, 24, 0, 0)
                SearchInput.BackgroundTransparency = 1
                SearchInput.Font = theme.Font or Enum.Font.BuilderSans
                SearchInput.PlaceholderText = "Tìm kiếm..."
                SearchInput.PlaceholderColor3 = theme.TextDark
                SearchInput.Text = ""
                SearchInput.TextColor3 = theme.Text
                SearchInput.TextSize = 12
                SearchInput.TextXAlignment = Enum.TextXAlignment.Left
                SearchInput.ClearTextOnFocus = false
                SearchInput.Parent = SearchBox
            end

            local OptionList = Instance.new("Frame")
            OptionList.Name = "OptionList"
            OptionList.Size = UDim2.new(1, -16, 0, #options * 28 + 4)
            OptionList.Position = isSearchable and UDim2.new(0, 8, 0, 76) or UDim2.new(0, 8, 0, 42)
            OptionList.BackgroundTransparency = 1
            OptionList.Parent = Card

            local optionListLayout = Instance.new("UIListLayout")
            optionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionListLayout.Padding = UDim.new(0, 3)
            optionListLayout.Parent = OptionList

            local function getVisibleCount(): number
                local count = 0
                local q = string.lower(filterQuery)
                for _, opt in ipairs(options) do
                    local matches = (q == "") or (string.find(string.lower(opt), q, 1, true) ~= nil)
                    if optionButtons[opt] then
                        optionButtons[opt].Visible = matches
                    end
                    if matches then count = count + 1 end
                end
                return count
            end

            local function recalculateHeight()
                if not isOpen then
                    tween(Card, 0.22, {Size = UDim2.new(1, 0, 0, 42)})
                    return
                end
                local visibleCount = getVisibleCount()
                local topOffset = isSearchable and 76 or 44
                local listH = math.max(visibleCount, 1) * 29
                OptionList.Size = UDim2.new(1, -16, 0, listH)
                local targetHeight = topOffset + listH + 6
                tween(Card, 0.22, {Size = UDim2.new(1, 0, 0, targetHeight)})
            end

            if SearchInput then
                SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
                    filterQuery = SearchInput.Text
                    recalculateHeight()
                end)
            end

            local function updateOptionHighlights()
                for optVal, btn in pairs(optionButtons) do
                    if btn and btn.Parent then
                        local isSelected = (optVal == current)
                        if isSelected then
                            btn.BackgroundColor3 = theme.CardActive
                            btn.BackgroundTransparency = 0.15
                            btn.TextColor3 = theme.Accent
                        else
                            btn.BackgroundColor3 = Color3.fromRGB(32, 36, 50)
                            btn.BackgroundTransparency = 0.55
                            btn.TextColor3 = theme.TextMuted
                        end
                    end
                end
            end

            local function refreshOptions()
                table.clear(optionButtons)
                for _, child in ipairs(OptionList:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end

                for i, opt in ipairs(options) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Name = "Opt_" .. opt
                    optBtn.Size = UDim2.new(1, 0, 0, 26)
                    optBtn.BorderSizePixel = 0
                    optBtn.AutoButtonColor = false
                    optBtn.Font = theme.Font or Enum.Font.BuilderSans
                    optBtn.Text = "   " .. opt
                    optBtn.TextSize = 12.5
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    optBtn.Parent = OptionList

                    local optCorner = Instance.new("UICorner")
                    optCorner.CornerRadius = UDim.new(0, 5)
                    optCorner.Parent = optBtn

                    optionButtons[opt] = optBtn

                    optBtn.MouseEnter:Connect(function()
                        if opt ~= current then
                            tween(optBtn, 0.15, {BackgroundTransparency = 0.3, TextColor3 = theme.Text})
                        end
                    end)

                    optBtn.MouseLeave:Connect(function()
                        if opt ~= current then
                            tween(optBtn, 0.15, {BackgroundTransparency = 0.55, TextColor3 = theme.TextMuted})
                        end
                    end)

                    optBtn.Activated:Connect(function()
                        current = opt
                        selectedLbl.Text = current
                        updateOptionHighlights()
                        isOpen = false
                        if SearchInput then
                            SearchInput.Text = ""
                            filterQuery = ""
                        end
                        tween(arrowIcon, 0.2, {Rotation = 0})
                        tween(Card, 0.2, {Size = UDim2.new(1, 0, 0, 42)})
                        pcall(callback, current)
                    end)
                end
                updateOptionHighlights()
            end
            refreshOptions()

            HeaderBtn.Activated:Connect(function()
                isOpen = not isOpen
                tween(arrowIcon, 0.2, {Rotation = isOpen and 180 or 0})
                if not isOpen and SearchInput then
                    SearchInput.Text = ""
                    filterQuery = ""
                end
                recalculateHeight()
            end)

            local DropObj = {
                Value = current,
                Refresh = function(_, newOptions, newDefault)
                    options = newOptions or options
                    if newDefault then current = newDefault end
                    selectedLbl.Text = current
                    refreshOptions()
                    if isOpen then recalculateHeight() end
                end,
                Set = function(_, val)
                    current = val
                    selectedLbl.Text = val
                    updateOptionHighlights()
                    pcall(callback, val)
                end
            }
            return DropObj
        end

        -- MULTI-DROPDOWN (Multi-Select with checkmark sync & Optional Search)
        function Tab:CreateMultiDropdown(multiConfig: {
            Name: string,
            Description: string?,
            Options: {string},
            Default: {string}?,
            Searchable: boolean?,
            Callback: ({string}) -> ()
        })
            local name = multiConfig.Name or "MultiDropdown"
            local desc = multiConfig.Description
            local options = multiConfig.Options or {}
            local isSearchable = multiConfig.Searchable == true
            local selectedMap = {}
            if multiConfig.Default then
                for _, v in ipairs(multiConfig.Default) do
                    selectedMap[v] = true
                end
            end
            local callback = multiConfig.Callback or function() end

            local isOpen = false
            local optionButtons = {}
            local filterQuery = ""

            local Card = Instance.new("Frame")
            Card.Name = "MultiDrop_" .. name
            Card.Size = UDim2.new(1, 0, 0, 42)
            Card.BackgroundColor3 = theme.Card
            Card.BackgroundTransparency = theme.CardTransparency
            Card.BorderSizePixel = 0
            Card.ClipsDescendants = true
            Card.Parent = Page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = Card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = theme.Border
            cardStroke.Thickness = 1
            cardStroke.Transparency = 0.6
            cardStroke.Parent = Card

            local HeaderBtn = Instance.new("TextButton")
            HeaderBtn.Name = "Header"
            HeaderBtn.Size = UDim2.new(1, 0, 0, 42)
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.AutoButtonColor = false
            HeaderBtn.Text = ""
            HeaderBtn.Parent = Card

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Name = "Title"
            titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
            titleLbl.Position = UDim2.new(0, 12, 0, 0)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Font = theme.FontMedium or Enum.Font.BuilderSansMedium
            titleLbl.Text = name
            titleLbl.TextColor3 = theme.Text
            titleLbl.TextSize = 13.5
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = HeaderBtn

            local selectedLbl = Instance.new("TextLabel")
            selectedLbl.Name = "SelectedLabel"
            selectedLbl.Size = UDim2.new(0.5, -42, 1, 0)
            selectedLbl.Position = UDim2.new(0.5, 0, 0, 0)
            selectedLbl.BackgroundTransparency = 1
            selectedLbl.Font = theme.Font or Enum.Font.BuilderSans
            selectedLbl.TextColor3 = theme.Accent
            selectedLbl.TextSize = 12.5
            selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
            selectedLbl.Parent = HeaderBtn

            local arrowIcon = Instance.new("TextLabel")
            arrowIcon.Name = "Arrow"
            arrowIcon.Size = UDim2.fromOffset(20, 20)
            arrowIcon.Position = UDim2.new(1, -28, 0.5, -10)
            arrowIcon.BackgroundTransparency = 1
            arrowIcon.Font = theme.FontBold or Enum.Font.BuilderSansBold
            arrowIcon.Text = "v"
            arrowIcon.TextColor3 = theme.TextDark
            arrowIcon.TextSize = 12
            arrowIcon.Parent = HeaderBtn

            local SearchBox = nil
            local SearchInput = nil
            if isSearchable then
                SearchBox = Instance.new("Frame")
                SearchBox.Name = "SearchBox"
                SearchBox.Size = UDim2.new(1, -16, 0, 26)
                SearchBox.Position = UDim2.new(0, 8, 0, 44)
                SearchBox.BackgroundColor3 = Color3.fromRGB(20, 23, 33)
                SearchBox.BorderSizePixel = 0
                SearchBox.Parent = Card

                local sCorner = Instance.new("UICorner")
                sCorner.CornerRadius = UDim.new(0, 6)
                sCorner.Parent = SearchBox

                local sStroke = Instance.new("UIStroke")
                sStroke.Color = theme.Border
                sStroke.Thickness = 1
                sStroke.Transparency = 0.55
                sStroke.Parent = SearchBox

                local searchIcon = Instance.new("ImageLabel")
                searchIcon.Name = "Icon"
                searchIcon.Size = UDim2.fromOffset(13, 13)
                searchIcon.Position = UDim2.new(0, 7, 0.5, -6)
                searchIcon.BackgroundTransparency = 1
                searchIcon.Image = "rbxassetid://10734886676"
                searchIcon.ImageColor3 = theme.TextDark
                searchIcon.Parent = SearchBox

                SearchInput = Instance.new("TextBox")
                SearchInput.Name = "Input"
                SearchInput.Size = UDim2.new(1, -28, 1, 0)
                SearchInput.Position = UDim2.new(0, 24, 0, 0)
                SearchInput.BackgroundTransparency = 1
                SearchInput.Font = theme.Font or Enum.Font.BuilderSans
                SearchInput.PlaceholderText = "Tìm kiếm..."
                SearchInput.PlaceholderColor3 = theme.TextDark
                SearchInput.Text = ""
                SearchInput.TextColor3 = theme.Text
                SearchInput.TextSize = 12
                SearchInput.TextXAlignment = Enum.TextXAlignment.Left
                SearchInput.ClearTextOnFocus = false
                SearchInput.Parent = SearchBox
            end

            local OptionList = Instance.new("Frame")
            OptionList.Name = "OptionList"
            OptionList.Size = UDim2.new(1, -16, 0, #options * 28 + 4)
            OptionList.Position = isSearchable and UDim2.new(0, 8, 0, 76) or UDim2.new(0, 8, 0, 42)
            OptionList.BackgroundTransparency = 1
            OptionList.Parent = Card

            local optionListLayout = Instance.new("UIListLayout")
            optionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionListLayout.Padding = UDim.new(0, 3)
            optionListLayout.Parent = OptionList

            local function getSelectedList(): {string}
                local list = {}
                for _, opt in ipairs(options) do
                    if selectedMap[opt] then table.insert(list, opt) end
                end
                return list
            end

            local function updateHeaderSummary()
                local count = 0
                for _, opt in ipairs(options) do
                    if selectedMap[opt] then count = count + 1 end
                end
                if count == 0 then
                    selectedLbl.Text = "Chưa chọn"
                elseif count == 1 then
                    local s = getSelectedList()
                    selectedLbl.Text = s[1] or ""
                else
                    selectedLbl.Text = count .. " đã chọn"
                end
            end

            local function updateOptionHighlights()
                for optVal, btn in pairs(optionButtons) do
                    if btn and btn.Parent then
                        local isSel = selectedMap[optVal] == true
                        if isSel then
                            btn.BackgroundColor3 = theme.CardActive
                            btn.BackgroundTransparency = 0.15
                            btn.TextColor3 = theme.Accent
                            btn.Text = "   ✓ " .. optVal
                        else
                            btn.BackgroundColor3 = Color3.fromRGB(32, 36, 50)
                            btn.BackgroundTransparency = 0.55
                            btn.TextColor3 = theme.TextMuted
                            btn.Text = "      " .. optVal
                        end
                    end
                end
                updateHeaderSummary()
            end

            local function getVisibleCount(): number
                local count = 0
                local q = string.lower(filterQuery)
                for _, opt in ipairs(options) do
                    local matches = (q == "") or (string.find(string.lower(opt), q, 1, true) ~= nil)
                    if optionButtons[opt] then
                        optionButtons[opt].Visible = matches
                    end
                    if matches then count = count + 1 end
                end
                return count
            end

            local function recalculateHeight()
                if not isOpen then
                    tween(Card, 0.22, {Size = UDim2.new(1, 0, 0, 42)})
                    return
                end
                local visibleCount = getVisibleCount()
                local topOffset = isSearchable and 76 or 44
                local listH = math.max(visibleCount, 1) * 29
                OptionList.Size = UDim2.new(1, -16, 0, listH)
                local targetHeight = topOffset + listH + 6
                tween(Card, 0.22, {Size = UDim2.new(1, 0, 0, targetHeight)})
            end

            if SearchInput then
                SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
                    filterQuery = SearchInput.Text
                    recalculateHeight()
                end)
            end

            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Name = "Opt_" .. opt
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.BorderSizePixel = 0
                optBtn.AutoButtonColor = false
                optBtn.Font = theme.Font or Enum.Font.BuilderSans
                optBtn.TextSize = 12.5
                optBtn.TextXAlignment = Enum.TextXAlignment.Left
                optBtn.Parent = OptionList

                local optCorner = Instance.new("UICorner")
                optCorner.CornerRadius = UDim.new(0, 5)
                optCorner.Parent = optBtn

                optionButtons[opt] = optBtn

                optBtn.Activated:Connect(function()
                    selectedMap[opt] = not selectedMap[opt]
                    updateOptionHighlights()
                    pcall(callback, getSelectedList())
                end)
            end
            updateOptionHighlights()

            HeaderBtn.Activated:Connect(function()
                isOpen = not isOpen
                tween(arrowIcon, 0.2, {Rotation = isOpen and 180 or 0})
                if not isOpen and SearchInput then
                    SearchInput.Text = ""
                    filterQuery = ""
                end
                recalculateHeight()
            end)

            local MultiDropObj = {
                Get = getSelectedList,
                Set = function(_, newSelected)
                    table.clear(selectedMap)
                    for _, v in ipairs(newSelected or {}) do
                        selectedMap[v] = true
                    end
                    updateOptionHighlights()
                    pcall(callback, getSelectedList())
                end
            }
            return MultiDropObj
        end

        -- PROGRESS BAR COMPONENT
        function Tab:CreateProgress(progConfig: {Name: string, Description: string?, Default: number?})
            local name = progConfig.Name or "Progress"
            local desc = progConfig.Description
            local current = math.clamp(progConfig.Default or 0, 0, 100)

            local Card = Instance.new("Frame")
            Card.Name = "Prog_" .. name
            Card.Size = UDim2.new(1, 0, 0, desc and 52 or 44)
            Card.BackgroundColor3 = theme.Card
            Card.BackgroundTransparency = theme.CardTransparency
            Card.BorderSizePixel = 0
            Card.Parent = Page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = Card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = theme.Border
            cardStroke.Thickness = 1
            cardStroke.Transparency = 0.6
            cardStroke.Parent = Card

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Name = "Title"
            titleLbl.Size = UDim2.new(1, -80, 0, 16)
            titleLbl.Position = UDim2.new(0, 12, 0, 6)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Font = theme.FontMedium or Enum.Font.BuilderSansMedium
            titleLbl.Text = name
            titleLbl.TextColor3 = theme.Text
            titleLbl.TextSize = 13.5
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = Card

            local percentLbl = Instance.new("TextLabel")
            percentLbl.Name = "Percent"
            percentLbl.Size = UDim2.new(0, 70, 0, 16)
            percentLbl.Position = UDim2.new(1, -82, 0, 6)
            percentLbl.BackgroundTransparency = 1
            percentLbl.Font = theme.FontBold or Enum.Font.BuilderSansBold
            percentLbl.Text = math.floor(current) .. "%"
            percentLbl.TextColor3 = theme.Accent
            percentLbl.TextSize = 12.5
            percentLbl.TextXAlignment = Enum.TextXAlignment.Right
            percentLbl.Parent = Card

            local Track = Instance.new("Frame")
            Track.Name = "Track"
            Track.Size = UDim2.new(1, -24, 0, 6)
            Track.Position = UDim2.new(0, 12, 1, -14)
            Track.BackgroundColor3 = Color3.fromRGB(38, 43, 58)
            Track.BorderSizePixel = 0
            Track.Parent = Card

            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = Track

            local Fill = Instance.new("Frame")
            Fill.Name = "Fill"
            Fill.Size = UDim2.new(current / 100, 0, 1, 0)
            Fill.BackgroundColor3 = theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Track

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = Fill

            local ProgObj = {
                Value = current,
                Set = function(_, newPct: number, statusText: string?)
                    current = math.clamp(newPct or 0, 0, 100)
                    percentLbl.Text = (statusText and (statusText .. " (" .. math.floor(current) .. "%)")) or (math.floor(current) .. "%")
                    tween(Fill, 0.2, {Size = UDim2.new(current / 100, 0, 1, 0)})
                end
            }
            return ProgObj
        end

        -- INPUT
        function Tab:CreateInput(inputConfig: {
            Name: string,
            Description: string?,
            Placeholder: string?,
            Default: string?,
            Callback: (string, boolean) -> ()
        })
            local name = inputConfig.Name or "Input"
            local desc = inputConfig.Description
            local placeholder = inputConfig.Placeholder or "Type here..."
            local default = inputConfig.Default or ""
            local callback = inputConfig.Callback or function() end

            local Card = Instance.new("Frame")
            Card.Name = "Input_" .. name
            Card.Size = UDim2.new(1, 0, 0, desc and 48 or 40)
            Card.BackgroundColor3 = theme.Card
            Card.BackgroundTransparency = theme.CardTransparency
            Card.BorderSizePixel = 0
            Card.Parent = Page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = Card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = theme.Border
            cardStroke.Thickness = 1
            cardStroke.Transparency = 0.6
            cardStroke.Parent = Card

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Name = "Title"
            titleLbl.Size = UDim2.new(0.5, 0, 0, 18)
            titleLbl.Position = UDim2.new(0, 12, 0, desc and 6 or 11)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Font = theme.FontMedium or Enum.Font.BuilderSansMedium
            titleLbl.Text = name
            titleLbl.TextColor3 = theme.Text
            titleLbl.TextSize = 13.5
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = Card

            if desc then
                local descLbl = Instance.new("TextLabel")
                descLbl.Name = "Desc"
                descLbl.Size = UDim2.new(0.5, 0, 0, 14)
                descLbl.Position = UDim2.new(0, 12, 0, 24)
                descLbl.BackgroundTransparency = 1
                descLbl.Font = theme.Font or Enum.Font.BuilderSans
                descLbl.Text = desc
                descLbl.TextColor3 = theme.TextMuted
                descLbl.TextSize = 12
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.Parent = Card
            end

            local BoxFrame = Instance.new("Frame")
            BoxFrame.Name = "BoxFrame"
            BoxFrame.Size = UDim2.new(0.42, 0, 0, 26)
            BoxFrame.Position = UDim2.new(0.58, -10, 0.5, -13)
            BoxFrame.BackgroundColor3 = Color3.fromRGB(34, 38, 52)
            BoxFrame.BorderSizePixel = 0
            BoxFrame.Parent = Card

            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 6)
            boxCorner.Parent = BoxFrame

            local boxStroke = Instance.new("UIStroke")
            boxStroke.Color = theme.Border
            boxStroke.Thickness = 1
            boxStroke.Transparency = 0.6
            boxStroke.Parent = BoxFrame

            local TextBox = Instance.new("TextBox")
            TextBox.Name = "Box"
            TextBox.Size = UDim2.new(1, -12, 1, 0)
            TextBox.Position = UDim2.new(0, 6, 0, 0)
            TextBox.BackgroundTransparency = 1
            TextBox.Font = theme.Font or Enum.Font.BuilderSans
            TextBox.Text = default
            TextBox.PlaceholderText = placeholder
            TextBox.PlaceholderColor3 = theme.TextDark
            TextBox.TextColor3 = theme.Text
            TextBox.TextSize = 12.5
            TextBox.ClearTextOnFocus = false
            TextBox.Parent = BoxFrame

            TextBox.Focused:Connect(function()
                tween(boxStroke, 0.15, {Color = theme.Accent, Transparency = 0})
            end)

            TextBox.FocusLost:Connect(function(enterPressed)
                tween(boxStroke, 0.15, {Color = theme.Border, Transparency = 0.6})
                pcall(callback, TextBox.Text, enterPressed)
            end)

            return TextBox
        end

        -- KEYBIND
        function Tab:CreateKeybind(keyConfig: {
            Name: string,
            Description: string?,
            Default: Enum.KeyCode?,
            Callback: (Enum.KeyCode) -> ()
        })
            local name = keyConfig.Name or "Keybind"
            local desc = keyConfig.Description
            local currentKey = keyConfig.Default or Enum.KeyCode.E
            local callback = keyConfig.Callback or function() end

            local listening = false

            local Card = Instance.new("Frame")
            Card.Name = "Key_" .. name
            Card.Size = UDim2.new(1, 0, 0, desc and 46 or 38)
            Card.BackgroundColor3 = theme.Card
            Card.BackgroundTransparency = theme.CardTransparency
            Card.BorderSizePixel = 0
            Card.Parent = Page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = Card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = theme.Border
            cardStroke.Thickness = 1
            cardStroke.Transparency = 0.6
            cardStroke.Parent = Card

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Name = "Title"
            titleLbl.Size = UDim2.new(1, -100, 0, 18)
            titleLbl.Position = UDim2.new(0, 12, 0, desc and 6 or 10)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Font = theme.FontMedium or Enum.Font.BuilderSansMedium
            titleLbl.Text = name
            titleLbl.TextColor3 = theme.Text
            titleLbl.TextSize = 13.5
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = Card

            if desc then
                local descLbl = Instance.new("TextLabel")
                descLbl.Name = "Desc"
                descLbl.Size = UDim2.new(1, -100, 0, 14)
                descLbl.Position = UDim2.new(0, 12, 0, 24)
                descLbl.BackgroundTransparency = 1
                descLbl.Font = theme.Font or Enum.Font.BuilderSans
                descLbl.Text = desc
                descLbl.TextColor3 = theme.TextMuted
                descLbl.TextSize = 12
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.Parent = Card
            end

            local BindBtn = Instance.new("TextButton")
            BindBtn.Name = "BindBtn"
            BindBtn.Size = UDim2.fromOffset(72, 24)
            BindBtn.Position = UDim2.new(1, -84, 0.5, -12)
            BindBtn.BackgroundColor3 = Color3.fromRGB(34, 38, 52)
            BindBtn.BorderSizePixel = 0
            BindBtn.AutoButtonColor = false
            BindBtn.Font = theme.FontBold or Enum.Font.BuilderSansBold
            BindBtn.Text = currentKey.Name
            BindBtn.TextColor3 = theme.Accent
            BindBtn.TextSize = 12
            BindBtn.Parent = Card

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = BindBtn

            local btnStroke = Instance.new("UIStroke")
            btnStroke.Color = theme.Border
            btnStroke.Thickness = 1
            btnStroke.Transparency = 0.6
            btnStroke.Parent = BindBtn

            BindBtn.Activated:Connect(function()
                listening = true
                BindBtn.Text = "..."
                tween(btnStroke, 0.15, {Color = theme.Accent, Transparency = 0})

                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        conn:Disconnect()
                        listening = false
                        currentKey = input.KeyCode
                        BindBtn.Text = currentKey.Name
                        tween(btnStroke, 0.15, {Color = theme.Border, Transparency = 0.6})
                        pcall(callback, currentKey)
                    end
                end)
            end)

            return BindBtn
        end

        -- COLOR PICKER
        function Tab:CreateColorPicker(colorConfig: {
            Name: string,
            Default: Color3?,
            Callback: (Color3) -> ()
        })
            local name = colorConfig.Name or "Color"
            local currentColor = colorConfig.Default or Color3.fromRGB(0, 166, 255)
            local callback = colorConfig.Callback or function() end

            local isOpen = false

            local Card = Instance.new("Frame")
            Card.Name = "Color_" .. name
            Card.Size = UDim2.new(1, 0, 0, 42)
            Card.BackgroundColor3 = theme.Card
            Card.BackgroundTransparency = theme.CardTransparency
            Card.BorderSizePixel = 0
            Card.ClipsDescendants = true
            Card.Parent = Page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = Card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = theme.Border
            cardStroke.Thickness = 1
            cardStroke.Transparency = 0.6
            cardStroke.Parent = Card

            local HeaderBtn = Instance.new("TextButton")
            HeaderBtn.Name = "Header"
            HeaderBtn.Size = UDim2.new(1, 0, 0, 42)
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.AutoButtonColor = false
            HeaderBtn.Text = ""
            HeaderBtn.Parent = Card

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Name = "Title"
            titleLbl.Size = UDim2.new(1, -70, 1, 0)
            titleLbl.Position = UDim2.new(0, 12, 0, 0)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Font = theme.FontMedium or Enum.Font.BuilderSansMedium
            titleLbl.Text = name
            titleLbl.TextColor3 = theme.Text
            titleLbl.TextSize = 13.5
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = HeaderBtn

            local Preview = Instance.new("Frame")
            Preview.Name = "Preview"
            Preview.Size = UDim2.fromOffset(36, 20)
            Preview.Position = UDim2.new(1, -48, 0.5, -10)
            Preview.BackgroundColor3 = currentColor
            Preview.BorderSizePixel = 0
            Preview.Parent = HeaderBtn

            local prevCorner = Instance.new("UICorner")
            prevCorner.CornerRadius = UDim.new(0, 5)
            prevCorner.Parent = Preview

            local prevStroke = Instance.new("UIStroke")
            prevStroke.Color = theme.Border
            prevStroke.Thickness = 1
            prevStroke.Parent = Preview

            local ColorControls = Instance.new("Frame")
            ColorControls.Name = "Controls"
            ColorControls.Size = UDim2.new(1, -24, 0, 90)
            ColorControls.Position = UDim2.new(0, 12, 0, 44)
            ColorControls.BackgroundTransparency = 1
            ColorControls.Parent = Card

            local ccLayout = Instance.new("UIListLayout")
            ccLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ccLayout.Padding = UDim.new(0, 6)
            ccLayout.Parent = ColorControls

            local function createChannelSlider(chName: string, initialVal: number, chColor: Color3, onChange: (number) -> ())
                local chFrame = Instance.new("Frame")
                chFrame.Name = chName
                chFrame.Size = UDim2.new(1, 0, 0, 22)
                chFrame.BackgroundTransparency = 1
                chFrame.Parent = ColorControls

                local chLbl = Instance.new("TextLabel")
                chLbl.Size = UDim2.fromOffset(20, 22)
                chLbl.BackgroundTransparency = 1
                chLbl.Font = theme.FontBold or Enum.Font.BuilderSansBold
                chLbl.Text = chName
                chLbl.TextColor3 = chColor
                chLbl.TextSize = 12
                chLbl.Parent = chFrame

                local track = Instance.new("TextButton")
                track.Size = UDim2.new(1, -30, 0, 6)
                track.Position = UDim2.new(0, 26, 0.5, -3)
                track.BackgroundColor3 = Color3.fromRGB(38, 43, 58)
                track.BorderSizePixel = 0
                track.AutoButtonColor = false
                track.Text = ""
                track.Parent = chFrame

                local tCorner = Instance.new("UICorner")
                tCorner.CornerRadius = UDim.new(1, 0)
                tCorner.Parent = track

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(initialVal / 255, 0, 1, 0)
                fill.BackgroundColor3 = chColor
                fill.BorderSizePixel = 0
                fill.Parent = track

                local fCorner = Instance.new("UICorner")
                fCorner.CornerRadius = UDim.new(1, 0)
                fCorner.Parent = fill

                local isSliding = false
                local moveConn = nil
                local endConn = nil

                local function updateVal(xPos: number)
                    local alpha = math.clamp((xPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local val = math.floor(alpha * 255)
                    fill.Size = UDim2.new(alpha, 0, 1, 0)
                    onChange(val)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isSliding = true
                        updateVal(input.Position.X)

                        if moveConn then moveConn:Disconnect() end
                        if endConn then endConn:Disconnect() end

                        moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                            if isSliding and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
                                updateVal(moveInput.Position.X)
                            end
                        end)

                        endConn = UserInputService.InputEnded:Connect(function(endInput)
                            if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                                isSliding = false
                                if moveConn then moveConn:Disconnect() moveConn = nil end
                                if endConn then endConn:Disconnect() endConn = nil end
                            end
                        end)
                    end
                end)
            end

            local curR = math.floor(currentColor.R * 255)
            local curG = math.floor(currentColor.G * 255)
            local curB = math.floor(currentColor.B * 255)

            local function syncColor()
                currentColor = Color3.fromRGB(curR, curG, curB)
                Preview.BackgroundColor3 = currentColor
                pcall(callback, currentColor)
            end

            createChannelSlider("R", curR, Color3.fromRGB(255, 75, 75), function(v) curR = v syncColor() end)
            createChannelSlider("G", curG, Color3.fromRGB(75, 255, 120), function(v) curG = v syncColor() end)
            createChannelSlider("B", curB, Color3.fromRGB(75, 150, 255), function(v) curB = v syncColor() end)

            HeaderBtn.Activated:Connect(function()
                isOpen = not isOpen
                tween(Card, 0.25, {Size = isOpen and UDim2.new(1, 0, 0, 140) or UDim2.new(1, 0, 0, 42)})
            end)

            return Card
        end

        -- PARAGRAPH
        function Tab:CreateParagraph(pConfig: {Title: string?, Content: string?, Desc: string?})
            local title = pConfig.Title or "Notice"
            local content = pConfig.Content or pConfig.Desc or ""

            local Card = Instance.new("Frame")
            Card.Name = "Para_" .. title
            Card.Size = UDim2.new(1, 0, 0, 0)
            Card.AutomaticSize = Enum.AutomaticSize.Y
            Card.BackgroundColor3 = theme.Card
            Card.BackgroundTransparency = theme.CardTransparency
            Card.BorderSizePixel = 0
            Card.Parent = Page

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = Card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = theme.Border
            cardStroke.Thickness = 1
            cardStroke.Transparency = 0.6
            cardStroke.Parent = Card

            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 12)
            pad.PaddingRight = UDim.new(0, 12)
            pad.PaddingTop = UDim.new(0, 10)
            pad.PaddingBottom = UDim.new(0, 10)
            pad.Parent = Card

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Name = "Title"
            titleLbl.Size = UDim2.new(1, 0, 0, 16)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Font = theme.FontBold or Enum.Font.BuilderSansBold
            titleLbl.Text = title
            titleLbl.TextColor3 = theme.Text
            titleLbl.TextSize = 14
            titleLbl.RichText = true
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = Card

            local contentLbl = Instance.new("TextLabel")
            contentLbl.Name = "Content"
            contentLbl.Size = UDim2.new(1, 0, 0, 0)
            contentLbl.AutomaticSize = Enum.AutomaticSize.Y
            contentLbl.Position = UDim2.new(0, 0, 0, 18)
            contentLbl.BackgroundTransparency = 1
            contentLbl.Font = theme.Font or Enum.Font.BuilderSans
            contentLbl.Text = content
            contentLbl.TextColor3 = theme.TextMuted
            contentLbl.TextSize = 13
            contentLbl.RichText = true
            contentLbl.TextWrapped = true
            contentLbl.TextXAlignment = Enum.TextXAlignment.Left
            contentLbl.Parent = Card

            local ParaObj = {
                Card = Card,
                ElementFrame = Card,
                Instance = Card,
                SetTitle = function(_, newTitle: string)
                    titleLbl.Text = tostring(newTitle or "")
                end,
                SetContent = function(_, newContent: string)
                    contentLbl.Text = tostring(newContent or "")
                end,
                SetDesc = function(_, newDesc: string)
                    contentLbl.Text = tostring(newDesc or "")
                end,
                Set = function(self, newTitleOrCfg: any, newContent: string?)
                    if type(newTitleOrCfg) == "table" then
                        if newTitleOrCfg.Title ~= nil then titleLbl.Text = tostring(newTitleOrCfg.Title) end
                        local c = newTitleOrCfg.Content or newTitleOrCfg.Desc
                        if c ~= nil then contentLbl.Text = tostring(c) end
                    else
                        if newTitleOrCfg ~= nil then titleLbl.Text = tostring(newTitleOrCfg) end
                        if newContent ~= nil then contentLbl.Text = tostring(newContent) end
                    end
                end,
            }

            return setmetatable(ParaObj, {
                __index = Card,
                __newindex = Card,
            })
        end

        Tab.Paragraph = Tab.CreateParagraph
        Tab.Toggle = Tab.CreateToggle
        Tab.Slider = Tab.CreateSlider
        Tab.Dropdown = Tab.CreateDropdown
        Tab.MultiDropdown = Tab.CreateMultiDropdown
        Tab.Button = Tab.CreateButton
        Tab.Keybind = Tab.CreateKeybind
        Tab.Input = Tab.CreateInput
        Tab.Progress = Tab.CreateProgress
        Tab.Section = Tab.CreateSection
        Tab.Divider = Tab.CreateDivider
        Tab.ColorPicker = Tab.CreateColorPicker

        return Tab
    end

    -- MODAL POPUP DIALOG
    function Window:CreateDialog(dConfig: {
        Title: string?,
        Content: string?,
        Buttons: {{Title: string, Style: string?, Callback: (() -> ())?}}
    })
        local dTitle = dConfig.Title or "Thông báo"
        local dContent = dConfig.Content or ""
        local btns = dConfig.Buttons or {{Title = "OK", Style = "Primary"}}

        if isMinimized then
            toggleMinimize()
        end

        local Overlay = Instance.new("TextButton")
        Overlay.Name = "DialogOverlay"
        Overlay.Size = UDim2.fromScale(1, 1)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 1
        Overlay.AutoButtonColor = false
        Overlay.Text = ""
        Overlay.ZIndex = 50
        Overlay.Parent = WindowFrame

        local DialogBox = Instance.new("Frame")
        DialogBox.Name = "DialogBox"
        DialogBox.Size = UDim2.fromOffset(320, 150)
        DialogBox.AnchorPoint = Vector2.new(0.5, 0.5)
        DialogBox.Position = UDim2.fromScale(0.5, 0.5)
        DialogBox.BackgroundColor3 = Color3.fromRGB(22, 25, 35)
        DialogBox.BackgroundTransparency = 0.05
        DialogBox.BorderSizePixel = 0
        DialogBox.ZIndex = 51
        DialogBox.Parent = Overlay

        local dCorner = Instance.new("UICorner")
        dCorner.CornerRadius = UDim.new(0, 12)
        dCorner.Parent = DialogBox

        local dStroke = Instance.new("UIStroke")
        dStroke.Color = theme.Border
        dStroke.Thickness = 1
        dStroke.Transparency = 0.4
        dStroke.Parent = DialogBox

        local dScale = Instance.new("UIScale")
        dScale.Scale = 0.88
        dScale.Parent = DialogBox

        local titleL = Instance.new("TextLabel")
        titleL.Size = UDim2.new(1, -24, 0, 22)
        titleL.Position = UDim2.new(0, 14, 0, 12)
        titleL.BackgroundTransparency = 1
        titleL.Font = theme.FontBold or Enum.Font.BuilderSansBold
        titleL.Text = dTitle
        titleL.TextColor3 = theme.Text
        titleL.TextSize = 15
        titleL.TextXAlignment = Enum.TextXAlignment.Left
        titleL.ZIndex = 52
        titleL.Parent = DialogBox

        local msgL = Instance.new("TextLabel")
        msgL.Size = UDim2.new(1, -28, 0, 52)
        msgL.Position = UDim2.new(0, 14, 0, 36)
        msgL.BackgroundTransparency = 1
        msgL.Font = theme.Font or Enum.Font.BuilderSans
        msgL.Text = dContent
        msgL.TextColor3 = theme.TextMuted
        msgL.TextSize = 13
        msgL.TextWrapped = true
        msgL.TextXAlignment = Enum.TextXAlignment.Left
        msgL.ZIndex = 52
        msgL.Parent = DialogBox

        local BtnRow = Instance.new("Frame")
        BtnRow.Size = UDim2.new(1, -24, 0, 32)
        BtnRow.Position = UDim2.new(0, 12, 1, -44)
        BtnRow.BackgroundTransparency = 1
        BtnRow.ZIndex = 52
        BtnRow.Parent = DialogBox

        local btnLayout = Instance.new("UIListLayout")
        btnLayout.FillDirection = Enum.FillDirection.Horizontal
        btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        btnLayout.Padding = UDim.new(0, 8)
        btnLayout.Parent = BtnRow

        local isClosed = false
        local function closeDialog()
            if isClosed then return end
            isClosed = true
            tween(dScale, 0.15, {Scale = 0.88})
            local f = tween(Overlay, 0.15, {BackgroundTransparency = 1})
            f.Completed:Connect(function() Overlay:Destroy() end)
        end

        for _, b in ipairs(btns) do
            local actBtn = Instance.new("TextButton")
            actBtn.Size = UDim2.fromOffset(80, 30)
            actBtn.BackgroundColor3 = (b.Style == "Danger" and theme.Danger) or (b.Style == "Primary" and theme.Accent) or theme.CardHover
            actBtn.Font = theme.FontBold or Enum.Font.BuilderSansBold
            actBtn.Text = b.Title
            actBtn.TextColor3 = theme.Text
            actBtn.TextSize = 13
            actBtn.AutoButtonColor = false
            actBtn.ZIndex = 53
            actBtn.Parent = BtnRow

            local bCorn = Instance.new("UICorner")
            bCorn.CornerRadius = UDim.new(0, 6)
            bCorn.Parent = actBtn

            actBtn.Activated:Connect(function()
                closeDialog()
                if b.Callback then pcall(b.Callback) end
            end)
        end

        tween(Overlay, 0.2, {BackgroundTransparency = 0.4})
        tween(dScale, 0.22, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end

    function Window:CreateSettingsTab(settingsConfig: {Title: string?, Icon: string?}?): any
        settingsConfig = settingsConfig or {}
        local SettingsTab = Window:CreateTab({
            Title = settingsConfig.Title or "Cài đặt",
            Icon = settingsConfig.Icon or "rbxassetid://10734950309",
        })
        return SettingsTab
    end

    function Window:SelectTab(target: any)
        if typeof(target) == "string" then
            for _, t in ipairs(Window.Tabs) do
                if t.Title == target then
                    selectTab(t)
                    return t
                end
            end
        elseif typeof(target) == "table" and target.Page then
            selectTab(target)
            return target
        end
    end

    function Window:Toggle(visibleState: boolean?)
        if visibleState ~= nil then
            setWindowVisible(visibleState)
        else
            setWindowVisible(not isVisible)
        end
    end

    function Window:ToggleMinimize()
        toggleMinimize()
    end

    function Window:Destroy()
        if ScreenGui then
            ScreenGui:Destroy()
        end
    end

    function Window:SetToggleKey(newKey: Enum.KeyCode)
        toggleKey = newKey
    end

    function Window:SetSubTitle(newSub: string)
        if BrandSub then
            BrandSub.Text = newSub
        end
    end

    function Window:SetAuthor(newAuthor: string)
        Window:SetSubTitle(newAuthor)
    end

    function Window:Close()
        setWindowVisible(false)
    end

    function Window:Open()
        setWindowVisible(true)
    end

    function Window:SetFont(presetOrFontTable: any)
        local f = (type(presetOrFontTable) == "string" and SonLibrary.FontPresets[presetOrFontTable]) or presetOrFontTable
        if type(f) == "table" and f.Font then
            theme.Font = f.Font
            theme.FontMedium = f.FontMedium or f.Font
            theme.FontBold = f.FontBold or f.Font
        end
    end

    Window.Tab = Window.CreateTab

    table.insert(SonLibrary.ActiveWindows, Window)
    return Window
end

-- BLANK / CUSTOM WINDOW CONSTRUCTOR (Custom Glassmorphic Canvas GUI)
function SonLibrary:CreateBlankWindow(config: {
    Title: string?,
    SubTitle: string?,
    Size: UDim2?,
    Position: UDim2?,
    Scrollable: boolean?,
    Draggable: boolean?,
    Topbar: boolean?,
    CloseButton: boolean?,
    MinimizeButton: boolean?,
    AccentColor: Color3?,
    FontFamily: string?,
    FontPreset: string?,
    ToggleKey: Enum.KeyCode?,
})
    config = config or {}
    local titleText = config.Title or "Blank Window"
    local subTitleText = config.SubTitle or "SonLibrary Canvas"
    local accent = config.AccentColor or SonLibrary.DefaultTheme.Accent
    local isScrollable = config.Scrollable == true
    local hasTopbar = config.Topbar ~= false
    local hasClose = config.CloseButton ~= false
    local hasMin = config.MinimizeButton ~= false
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    local theme = {}
    for k, v in pairs(SonLibrary.DefaultTheme) do
        theme[k] = v
    end
    theme.Accent = accent
    theme.AccentGlow = accent

    local fontCfg = config.FontFamily or config.FontPreset
    if fontCfg and SonLibrary.FontPresets[fontCfg] then
        local p = SonLibrary.FontPresets[fontCfg]
        theme.Font = p.Font
        theme.FontMedium = p.FontMedium
        theme.FontBold = p.FontBold
    elseif config.Font then
        theme.Font = config.Font
        theme.FontMedium = config.FontMedium or config.Font
        theme.FontBold = config.FontBold or config.Font
    end

    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    local defW = math.clamp(math.floor(viewport.X * 0.42), 320, 560)
    local defH = math.clamp(math.floor(viewport.Y * 0.45), 240, 420)
    local winSize = config.Size or UDim2.fromOffset(defW, defH)
    local winPos = config.Position or UDim2.new(0.5, -defW / 2, 0.5, -defH / 2)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SonLibrary_Blank_" .. titleText
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 100000
    ScreenGui.Parent = getSafeGuiParent()

    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name = "MainFrame"
    WindowFrame.Size = winSize
    WindowFrame.Position = winPos
    WindowFrame.BackgroundColor3 = theme.Background
    WindowFrame.BackgroundTransparency = theme.BackgroundTransparency
    WindowFrame.BorderSizePixel = 0
    WindowFrame.ClipsDescendants = true
    WindowFrame.Parent = ScreenGui

    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 11)
    windowCorner.Parent = WindowFrame

    local windowStroke = Instance.new("UIStroke")
    windowStroke.Color = theme.Border
    windowStroke.Thickness = 1
    windowStroke.Transparency = 0.35
    windowStroke.Parent = WindowFrame

    local WindowScale = Instance.new("UIScale")
    WindowScale.Scale = 1
    WindowScale.Parent = WindowFrame

    local headerHeight = hasTopbar and 42 or 0
    local Topbar = nil
    local BrandTitle = nil
    local BrandSub = nil

    if hasTopbar then
        Topbar = Instance.new("Frame")
        Topbar.Name = "Topbar"
        Topbar.Size = UDim2.new(1, 0, 0, headerHeight)
        Topbar.BackgroundTransparency = 1
        Topbar.Parent = WindowFrame

        local topbarDivider = Instance.new("Frame")
        topbarDivider.Name = "Divider"
        topbarDivider.Size = UDim2.new(1, 0, 0, 1)
        topbarDivider.Position = UDim2.new(0, 0, 1, -1)
        topbarDivider.BackgroundColor3 = theme.Border
        topbarDivider.BackgroundTransparency = 0.6
        topbarDivider.BorderSizePixel = 0
        topbarDivider.Parent = Topbar

        BrandTitle = Instance.new("TextLabel")
        BrandTitle.Name = "Title"
        BrandTitle.Size = UDim2.new(1, -90, 0, 18)
        BrandTitle.Position = UDim2.new(0, 14, 0, 5)
        BrandTitle.BackgroundTransparency = 1
        BrandTitle.Font = theme.FontBold or Enum.Font.BuilderSansBold
        BrandTitle.Text = titleText
        BrandTitle.TextColor3 = theme.Text
        BrandTitle.TextSize = 14
        BrandTitle.RichText = true
        BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
        BrandTitle.Parent = Topbar

        BrandSub = Instance.new("TextLabel")
        BrandSub.Name = "SubTitle"
        BrandSub.Size = UDim2.new(1, -90, 0, 14)
        BrandSub.Position = UDim2.new(0, 14, 0, 23)
        BrandSub.BackgroundTransparency = 1
        BrandSub.Font = theme.Font or Enum.Font.BuilderSans
        BrandSub.Text = subTitleText
        BrandSub.TextColor3 = theme.Accent
        BrandSub.TextSize = 11
        BrandSub.RichText = true
        BrandSub.TextXAlignment = Enum.TextXAlignment.Left
        BrandSub.Parent = Topbar

        local Controls = Instance.new("Frame")
        Controls.Name = "Controls"
        Controls.Size = UDim2.new(0, 70, 1, 0)
        Controls.Position = UDim2.new(1, -78, 0, 0)
        Controls.BackgroundTransparency = 1
        Controls.Parent = Topbar

        local controlsLayout = Instance.new("UIListLayout")
        controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        controlsLayout.FillDirection = Enum.FillDirection.Horizontal
        controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        controlsLayout.Padding = UDim.new(0, 6)
        controlsLayout.Parent = Controls

        local isMinimized = false
        if hasMin then
            local MinBtn = Instance.new("TextButton")
            MinBtn.Name = "MinBtn"
            MinBtn.Size = UDim2.fromOffset(26, 26)
            MinBtn.BackgroundColor3 = theme.Card
            MinBtn.BackgroundTransparency = 0.6
            MinBtn.AutoButtonColor = false
            MinBtn.Font = theme.FontBold or Enum.Font.BuilderSansBold
            MinBtn.Text = "—"
            MinBtn.TextColor3 = theme.TextMuted
            MinBtn.TextSize = 11
            MinBtn.LayoutOrder = 1
            MinBtn.Parent = Controls

            local minCorner = Instance.new("UICorner")
            minCorner.CornerRadius = UDim.new(0, 6)
            minCorner.Parent = MinBtn

            MinBtn.Activated:Connect(function()
                isMinimized = not isMinimized
                if isMinimized then
                    tween(WindowFrame, 0.25, {Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, headerHeight)})
                else
                    tween(WindowFrame, 0.25, {Size = winSize})
                end
            end)
        end

        if hasClose then
            local CloseBtn = Instance.new("TextButton")
            CloseBtn.Name = "CloseBtn"
            CloseBtn.Size = UDim2.fromOffset(26, 26)
            CloseBtn.BackgroundColor3 = theme.Card
            CloseBtn.BackgroundTransparency = 0.6
            CloseBtn.AutoButtonColor = false
            CloseBtn.Font = theme.FontBold or Enum.Font.BuilderSansBold
            CloseBtn.Text = "✕"
            CloseBtn.TextColor3 = theme.Danger
            CloseBtn.TextSize = 11
            CloseBtn.LayoutOrder = 2
            CloseBtn.Parent = Controls

            local closeCorner = Instance.new("UICorner")
            closeCorner.CornerRadius = UDim.new(0, 6)
            closeCorner.Parent = CloseBtn

            CloseBtn.Activated:Connect(function()
                ScreenGui:Destroy()
            end)
        end
    end

    -- CONTENT CONTAINER
    local Container
    if isScrollable then
        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "ScrollContainer"
        scroll.Size = UDim2.new(1, -16, 1, -(headerHeight + 16))
        scroll.Position = UDim2.new(0, 8, 0, headerHeight + 8)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = theme.Border
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
        scroll.ClipsDescendants = true
        scroll.Parent = WindowFrame

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = scroll

        local function updateCanvas()
            if scroll and scroll.Parent and layout then
                scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            end
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        Container = scroll
    else
        local frame = Instance.new("Frame")
        frame.Name = "Container"
        frame.Size = UDim2.new(1, -16, 1, -(headerHeight + 16))
        frame.Position = UDim2.new(0, 8, 0, headerHeight + 8)
        frame.BackgroundTransparency = 1
        frame.ClipsDescendants = true
        frame.Parent = WindowFrame
        Container = frame
    end

    -- Zero-Lag Dragging
    if config.Draggable ~= false and Topbar then
        local isDragging = false
        local dragStart = Vector2.zero
        local startPos = Vector2.zero
        local dragMoveConn = nil

        Topbar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                dragStart = Vector2.new(input.Position.X, input.Position.Y)
                startPos = Vector2.new(WindowFrame.AbsolutePosition.X, WindowFrame.AbsolutePosition.Y)

                if dragMoveConn then dragMoveConn:Disconnect() end
                dragMoveConn = UserInputService.InputChanged:Connect(function(moveInput)
                    if not isDragging then return end
                    if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                        local delta = Vector2.new(moveInput.Position.X, moveInput.Position.Y) - dragStart
                        local curCamera = workspace.CurrentCamera
                        local curVp = curCamera and curCamera.ViewportSize or Vector2.new(1920, 1080)
                        local winW = WindowFrame.AbsoluteSize.X
                        local nx = math.clamp(startPos.X + delta.X, -winW + 80, curVp.X - 80)
                        local ny = math.clamp(startPos.Y + delta.Y, 0, curVp.Y - 40)
                        WindowFrame.Position = UDim2.fromOffset(nx, ny)
                    end
                end)

                local endConn
                endConn = UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        isDragging = false
                        if dragMoveConn then dragMoveConn:Disconnect() dragMoveConn = nil end
                        if endConn then endConn:Disconnect() endConn = nil end
                    end
                end)
            end
        end)
    end

    local isVisible = true
    local function setVis(state: boolean)
        isVisible = state
        if isVisible then
            WindowFrame.Visible = true
            tween(WindowScale, 0.2, {Scale = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tween(WindowFrame, 0.2, {BackgroundTransparency = theme.BackgroundTransparency})
        else
            local a = tween(WindowScale, 0.15, {Scale = 0.94}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            tween(WindowFrame, 0.15, {BackgroundTransparency = 1})
            a.Completed:Connect(function()
                if not isVisible then WindowFrame.Visible = false end
            end)
        end
    end

    if toggleKey then
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == toggleKey then
                setVis(not isVisible)
            end
        end)
    end

    local BlankObj = {
        ScreenGui = ScreenGui,
        Frame = WindowFrame,
        Container = Container,
        Theme = theme,
        GetContainer = function() return Container end,
        GetFrame = function() return WindowFrame end,
        SetTitle = function(_, t) if BrandTitle then BrandTitle.Text = tostring(t) end end,
        SetSubTitle = function(_, s) if BrandSub then BrandSub.Text = tostring(s) end end,
        Toggle = function(_, v) if v ~= nil then setVis(v) else setVis(not isVisible) end end,
        Open = function() setVis(true) end,
        Close = function() setVis(false) end,
        Destroy = function() ScreenGui:Destroy() end,
    }

    table.insert(SonLibrary.ActiveWindows, BlankObj)
    return BlankObj
end

SonLibrary.CreateCustomWindow = SonLibrary.CreateBlankWindow

if getgenv then
    getgenv().SonLibrary = SonLibrary
end
_G.SonLibrary = SonLibrary

return SonLibrary
