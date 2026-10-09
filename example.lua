--!nocheck
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")

local setclipboardFn = setclipboard or toclipboard or (syn and syn.write_clipboard) or function() end

local isfileFn = isfile or (getgenv and getgenv().isfile)
local readfileFn = readfile or (getgenv and getgenv().readfile)
local writefileFn = writefile or (getgenv and getgenv().writefile)
local delfileFn = delfile or (getgenv and getgenv().delfile)
local isfolderFn = isfolder or (getgenv and getgenv().isfolder)
local makefolderFn = makefolder or (getgenv and getgenv().makefolder)
local listfilesFn = listfiles or (getgenv and getgenv().listfiles)
local getcustomassetFn = getcustomasset or (getgenv and getgenv().getcustomasset)

local CUSTOM_LOGO_ID = "rbxassetid://139568612294283"
local CachedLogoAsset = CUSTOM_LOGO_ID

local function getResolvedLogo()
    return CachedLogoAsset or CUSTOM_LOGO_ID
end

local THEME = {
    Background    = Color3.fromRGB(12, 9, 11),
    CardBg        = Color3.fromRGB(18, 13, 16),
    PillBg        = Color3.fromRGB(16, 12, 14),
    SidebarActive = Color3.fromRGB(27, 16, 19),
    Border        = Color3.fromRGB(36, 24, 28),
    BorderActive  = Color3.fromRGB(90, 36, 42),
    Accent        = Color3.fromRGB(246, 92, 82),
    AccentSoft    = Color3.fromRGB(255, 165, 155),
    AccentDark    = Color3.fromRGB(130, 40, 42),
    TextPrimary   = Color3.fromRGB(235, 235, 235),
    TextMuted     = Color3.fromRGB(120, 110, 115),
    TextDim       = Color3.fromRGB(72, 64, 68),
    Divider       = Color3.fromRGB(48, 36, 40),
    BadgeBg       = Color3.fromRGB(25, 18, 22),
    ToggleOff     = Color3.fromRGB(36, 28, 32),
    KnobOff       = Color3.fromRGB(78, 68, 73),
    KnobOn        = Color3.fromRGB(255, 255, 255)
}

local ICONS = {
    Search   = "rbxassetid://7733911828",
    Chevron  = "rbxassetid://7733717447",
    More     = "rbxassetid://7734021300",
    Menu     = "rbxassetid://7733993211",
    Combat   = "rbxassetid://7734053426",
    Movement = "rbxassetid://7733799901",
    Visuals  = "rbxassetid://7733774602",
    Player   = "rbxassetid://7733954760",
    Misc     = "rbxassetid://7734056411",
    Presets  = "rbxassetid://7733964719",
    AutoBuy  = "rbxassetid://7733942651",
    Accounts = "rbxassetid://7733765307",
    User     = "rbxassetid://7733954760",
    Chart    = "rbxassetid://7733749837",
    Clock    = "rbxassetid://7733734762",
    Compass  = "rbxassetid://7733720755",
    Signal   = "rbxassetid://7734058495",
    Radar    = "rbxassetid://7734053426",
    Speed    = "rbxassetid://7733799901"
}

local TWEEN_FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SLOW = TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

local SonLibrary = {
    Version = "4.0.0",
    ActiveWindows = {},
    NotificationGui = nil,
    NotificationContainer = nil,
    Flags = {},
    Registry = {},
    ConfigFolder = "SonHUB/Configs",
    SmoothAnimations = true,
}

local function safeTween(instance, info, props)
    if not SonLibrary.SmoothAnimations then
        for k, v in pairs(props) do
            pcall(function() instance[k] = v end)
        end
        return {
            Play = function() end,
            Cancel = function() end,
            Completed = {
                Connect = function(_, fn)
                    task.spawn(fn)
                    return {Disconnect = function() end}
                end
            }
        }
    end
    local tw = TweenService:Create(instance, info, props)
    tw:Play()
    return tw
end

function SonLibrary:SetAnimations(enabled: boolean)
    self.SmoothAnimations = (enabled == true)
end

local function getSafeGuiParent()
    local ok, parent = pcall(function()
        if typeof(gethui) == "function" then return gethui() end
        if syn and typeof(syn.protect_gui) == "function" then
            local g = Instance.new("Folder")
            syn.protect_gui(g)
            g.Parent = CoreGui
            return g
        end
        return CoreGui
    end)
    return (ok and parent) or LocalPlayer:WaitForChild("PlayerGui")
end

local function checkIsMobile()
    return (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) or false
end

local function ensureConfigFolder()
    pcall(function()
        if type(isfolderFn) == "function" and type(makefolderFn) == "function" then
            if not isfolderFn("SonHUB") then makefolderFn("SonHUB") end
            if not isfolderFn(SonLibrary.ConfigFolder) then makefolderFn(SonLibrary.ConfigFolder) end
        end
    end)
end
ensureConfigFolder()

function SonLibrary:SaveConfig(configName: string)
    ensureConfigFolder()
    configName = configName or "default"
    local safeName = string.gsub(configName, "[^%w_%-]", "")
    local path = SonLibrary.ConfigFolder .. "/" .. safeName .. ".json"

    local dataToSave = {}
    for flag, value in pairs(self.Flags) do
        if typeof(value) == "Color3" then
            dataToSave[flag] = {__type = "Color3", R = value.R, G = value.G, B = value.B}
        elseif typeof(value) == "EnumItem" then
            dataToSave[flag] = {__type = "KeyCode", Name = value.Name}
        else
            dataToSave[flag] = value
        end
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(dataToSave)
    end)

    if ok and encoded and type(writefileFn) == "function" then
        writefileFn(path, encoded)
        self:Notify({
            Title = "Config",
            Content = "Saved [" .. safeName .. "] successfully!",
            Duration = 2.5
        })
        return true
    end
    return false
end

function SonLibrary:LoadConfig(configName: string)
    configName = configName or "default"
    local safeName = string.gsub(configName, "[^%w_%-]", "")
    local path = SonLibrary.ConfigFolder .. "/" .. safeName .. ".json"

    if type(isfileFn) ~= "function" or not isfileFn(path) or type(readfileFn) ~= "function" then
        self:Notify({
            Title = "Config",
            Content = "Config [" .. safeName .. "] not found!",
            Duration = 2.5
        })
        return false
    end

    local raw = readfileFn(path)
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if ok and type(decoded) == "table" then
        for flag, val in pairs(decoded) do
            local finalVal = val
            if type(val) == "table" and val.__type then
                if val.__type == "Color3" then
                    finalVal = Color3.new(val.R, val.G, val.B)
                elseif val.__type == "KeyCode" then
                    finalVal = Enum.KeyCode[val.Name] or Enum.KeyCode.F
                end
            end

            self.Flags[flag] = finalVal
            local comp = self.Registry[flag]
            if comp and comp.Set then
                pcall(function() comp.Set(comp, finalVal) end)
            end
        end

        self:Notify({
            Title = "Config",
            Content = "Loaded [" .. safeName .. "] successfully!",
            Duration = 2.5
        })
        return true
    end
    return false
end

function SonLibrary:DeleteConfig(configName: string)
    configName = configName or "default"
    local safeName = string.gsub(configName, "[^%w_%-]", "")
    local path = SonLibrary.ConfigFolder .. "/" .. safeName .. ".json"

    if type(isfileFn) == "function" and isfileFn(path) and type(delfileFn) == "function" then
        delfileFn(path)
        self:Notify({
            Title = "Config",
            Content = "Deleted [" .. safeName .. "]!",
            Duration = 2.5
        })
        return true
    end
    return false
end

function SonLibrary:GetConfigs()
    local list = {}
    pcall(function()
        if type(listfilesFn) == "function" and type(isfolderFn) == "function" and isfolderFn(SonLibrary.ConfigFolder) then
            for _, fPath in ipairs(listfilesFn(SonLibrary.ConfigFolder)) do
                local name = string.match(fPath, "([^\\/]+)%.json$")
                if name then table.insert(list, name) end
            end
        end
    end)
    if #list == 0 then table.insert(list, "default") end
    return list
end

function SonLibrary:Notify(config: {Title: string?, Content: string?, Message: string?, Duration: number?})
    config = config or {}
    local title = config.Title or "pasta"
    local message = config.Content or config.Message or ""
    local duration = config.Duration or 2.8

    if not self.NotificationGui or not self.NotificationGui.Parent then
        local safeParent = getSafeGuiParent()
        local sg = Instance.new("ScreenGui")
        sg.Name = "PastaNotifications"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 999999
        sg.Parent = safeParent
        self.NotificationGui = sg

        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(0, 260, 1, -50)
        container.Position = UDim2.new(1, -276, 0, 48)
        container.BackgroundTransparency = 1
        container.Parent = sg

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Padding = UDim.new(0, 6)
        layout.Parent = container
        self.NotificationContainer = container
    end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = THEME.CardBg
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = self.NotificationContainer

    local cCor = Instance.new("UICorner")
    cCor.CornerRadius = UDim.new(0, 6)
    cCor.Parent = card

    local cStr = Instance.new("UIStroke")
    cStr.Color = THEME.Border
    cStr.Thickness = 1
    cStr.Parent = card

    local cPad = Instance.new("UIPadding")
    cPad.PaddingTop = UDim.new(0, 8)
    cPad.PaddingBottom = UDim.new(0, 8)
    cPad.PaddingLeft = UDim.new(0, 10)
    cPad.PaddingRight = UDim.new(0, 10)
    cPad.Parent = card

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -8)
    bar.Position = UDim2.new(0, -6, 0, 4)
    bar.BackgroundColor3 = THEME.Accent
    bar.BorderSizePixel = 0
    bar.Parent = card

    local bCor = Instance.new("UICorner")
    bCor.CornerRadius = UDim.new(0, 2)
    bCor.Parent = bar

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 14)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextColor3 = THEME.TextPrimary
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, 0, 0, 0)
    descLbl.AutomaticSize = Enum.AutomaticSize.Y
    descLbl.Position = UDim2.new(0, 0, 0, 16)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = message
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 9.5
    descLbl.TextColor3 = THEME.TextMuted
    descLbl.TextWrapped = true
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = card

    card.Position = UDim2.new(1, 30, 0, 0)
    TweenService:Create(card, TWEEN_FAST, {Position = UDim2.new(0, 0, 0, 0)}):Play()

    task.delay(duration, function()
        if card and card.Parent then
            local tw = TweenService:Create(card, TWEEN_FAST, {Position = UDim2.new(1, 30, 0, 0), BackgroundTransparency = 1})
            tw:Play()
            tw.Completed:Connect(function() card:Destroy() end)
        end
    end)
end

function SonLibrary:Unload()
    for _, win in ipairs(self.ActiveWindows) do
        pcall(function()
            if win.ScreenGui then win.ScreenGui:Destroy() end
        end)
    end
    self.ActiveWindows = {}
    if self.NotificationGui then
        pcall(function() self.NotificationGui:Destroy() end)
        self.NotificationGui = nil
        self.NotificationContainer = nil
    end
end

function SonLibrary:CreateWindow(config: {
    Title: string?,
    SubTitle: string?,
    Logo: string?,
    AccentColor: Color3?,
    ToggleKey: Enum.KeyCode?,
    DefaultColumns: number?,
    DefaultTab: string?,
    Watermark: boolean?,
    Footer: {Title: string?, Subtitle: string?}?,
    KeySystem: {Title: string?, Note: string?, Key: any, SaveKey: boolean?, DiscordLink: string?}?,
})
    config = config or {}
    local Title = config.Title or "SonHUB"
    local SubTitle = config.SubTitle or "Premium Edition"
    local LogoId = config.Logo or getResolvedLogo()
    local Accent = config.AccentColor or THEME.Accent
    local ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    local WindowDefaultColumns = config.DefaultColumns or 2
    local ShowWatermark = (config.Watermark ~= false)
    local initialDefaultTab = config.DefaultTab
    local keySystemConfig = config.KeySystem

    THEME.Accent = Accent
    THEME.AccentSoft = Color3.fromRGB(
        math.clamp(math.floor(Accent.R * 255 + 20), 0, 255),
        math.clamp(math.floor(Accent.G * 255 + 73), 0, 255),
        math.clamp(math.floor(Accent.B * 255 + 73), 0, 255)
    )
    THEME.AccentDark = Color3.fromRGB(
        math.clamp(math.floor(Accent.R * 255 - 116), 0, 255),
        math.clamp(math.floor(Accent.G * 255 - 52), 0, 255),
        math.clamp(math.floor(Accent.B * 255 - 40), 0, 255)
    )

    local safeParent = getSafeGuiParent()
    pcall(function()
        if safeParent:FindFirstChild("PastaCompleteUI") then
            safeParent.PastaCompleteUI:Destroy()
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PastaCompleteUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = safeParent

    local KeyPassed = true
    if keySystemConfig then
        KeyPassed = false
        local savedKeyPath = "SonHUB/saved_key.txt"
        local validKeys = {}
        if type(keySystemConfig.Key) == "table" then
            for _, k in ipairs(keySystemConfig.Key) do validKeys[tostring(k)] = true end
        else
            validKeys[tostring(keySystemConfig.Key)] = true
        end

        if keySystemConfig.SaveKey and type(isfileFn) == "function" and isfileFn(savedKeyPath) and type(readfileFn) == "function" then
            local saved = string.gsub(readfileFn(savedKeyPath), "%s+", "")
            if validKeys[saved] then KeyPassed = true end
        end

        if not KeyPassed then
            local KeyModal = Instance.new("Frame")
            KeyModal.Name = "KeyModal"
            KeyModal.Size = UDim2.new(0, 340, 0, 220)
            KeyModal.Position = UDim2.new(0.5, -170, 0.5, -110)
            KeyModal.BackgroundColor3 = THEME.Background
            KeyModal.BorderSizePixel = 0
            KeyModal.ZIndex = 80
            KeyModal.Parent = ScreenGui

            local kmc = Instance.new("UICorner")
            kmc.CornerRadius = UDim.new(0, 10)
            kmc.Parent = KeyModal

            local kms = Instance.new("UIStroke")
            kms.Color = THEME.BorderActive
            kms.Thickness = 1.2
            kms.Parent = KeyModal

            local kmPad = Instance.new("UIPadding")
            kmPad.PaddingTop = UDim.new(0, 16)
            kmPad.PaddingBottom = UDim.new(0, 16)
            kmPad.PaddingLeft = UDim.new(0, 16)
            kmPad.PaddingRight = UDim.new(0, 16)
            kmPad.Parent = KeyModal

            local kmLay = Instance.new("UIListLayout")
            kmLay.Padding = UDim.new(0, 10)
            kmLay.Parent = KeyModal

            local kTitle = Instance.new("TextLabel")
            kTitle.Size = UDim2.new(1, 0, 0, 20)
            kTitle.BackgroundTransparency = 1
            kTitle.Text = keySystemConfig.Title or "Key Verification"
            kTitle.Font = Enum.Font.GothamBold
            kTitle.TextSize = 13
            kTitle.TextColor3 = THEME.TextPrimary
            kTitle.TextXAlignment = Enum.TextXAlignment.Left
            kTitle.ZIndex = 81
            kTitle.Parent = KeyModal

            local kNote = Instance.new("TextLabel")
            kNote.Size = UDim2.new(1, 0, 0, 26)
            kNote.BackgroundTransparency = 1
            kNote.Text = keySystemConfig.Note or "Enter your key to access the hub."
            kNote.Font = Enum.Font.Gotham
            kNote.TextSize = 9.5
            kNote.TextColor3 = THEME.TextMuted
            kNote.TextWrapped = true
            kNote.TextXAlignment = Enum.TextXAlignment.Left
            kNote.ZIndex = 81
            kNote.Parent = KeyModal

            local kInputHolder = Instance.new("Frame")
            kInputHolder.Size = UDim2.new(1, 0, 0, 32)
            kInputHolder.BackgroundColor3 = THEME.CardBg
            kInputHolder.BorderSizePixel = 0
            kInputHolder.ZIndex = 81
            kInputHolder.Parent = KeyModal

            local kic = Instance.new("UICorner")
            kic.CornerRadius = UDim.new(0, 6)
            kic.Parent = kInputHolder

            local kis = Instance.new("UIStroke")
            kis.Color = THEME.Border
            kis.Thickness = 0.8
            kis.Parent = kInputHolder

            local kBox = Instance.new("TextBox")
            kBox.Size = UDim2.new(1, -16, 1, 0)
            kBox.Position = UDim2.new(0, 8, 0, 0)
            kBox.BackgroundTransparency = 1
            kBox.PlaceholderText = "Enter key here..."
            kBox.PlaceholderColor3 = THEME.TextDim
            kBox.TextColor3 = THEME.TextPrimary
            kBox.Font = Enum.Font.Gotham
            kBox.TextSize = 10.5
            kBox.ClearTextOnFocus = false
            kBox.ZIndex = 82
            kBox.Parent = kInputHolder

            local kBtnRow = Instance.new("Frame")
            kBtnRow.Size = UDim2.new(1, 0, 0, 30)
            kBtnRow.BackgroundTransparency = 1
            kBtnRow.ZIndex = 81
            kBtnRow.Parent = KeyModal

            local kbl = Instance.new("UIListLayout")
            kbl.FillDirection = Enum.FillDirection.Horizontal
            kbl.Padding = UDim.new(0, 8)
            kbl.Parent = kBtnRow

            local btnSubmit = Instance.new("TextButton")
            btnSubmit.Size = UDim2.new(0.5, -4, 1, 0)
            btnSubmit.BackgroundColor3 = THEME.Accent
            btnSubmit.Text = "Check Key"
            btnSubmit.Font = Enum.Font.GothamBold
            btnSubmit.TextSize = 10.5
            btnSubmit.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnSubmit.AutoButtonColor = false
            btnSubmit.ZIndex = 82
            btnSubmit.Parent = kBtnRow

            local bsCor = Instance.new("UICorner")
            bsCor.CornerRadius = UDim.new(0, 6)
            bsCor.Parent = btnSubmit

            local btnGetKey = Instance.new("TextButton")
            btnGetKey.Size = UDim2.new(0.5, -4, 1, 0)
            btnGetKey.BackgroundColor3 = THEME.CardBg
            btnGetKey.Text = "Copy Key Link"
            btnGetKey.Font = Enum.Font.GothamMedium
            btnGetKey.TextSize = 10.5
            btnGetKey.TextColor3 = THEME.TextMuted
            btnGetKey.AutoButtonColor = false
            btnGetKey.ZIndex = 82
            btnGetKey.Parent = kBtnRow

            local bgkCor = Instance.new("UICorner")
            bgkCor.CornerRadius = UDim.new(0, 6)
            bgkCor.Parent = btnGetKey

            btnGetKey.MouseButton1Click:Connect(function()
                local link = keySystemConfig.DiscordLink or "https://discord.gg/sonhub"
                setclipboardFn(link)
                SonLibrary:Notify({Title = "Key System", Content = "Copied link to clipboard!"})
            end)

            btnSubmit.MouseButton1Click:Connect(function()
                local entered = string.gsub(kBox.Text, "%s+", "")
                if validKeys[entered] then
                    KeyPassed = true
                    if keySystemConfig.SaveKey and type(writefileFn) == "function" then
                        pcall(function() writefileFn(savedKeyPath, entered) end)
                    end
                    SonLibrary:Notify({Title = "Success", Content = "Welcome to SonHUB!"})
                    KeyModal:Destroy()
                else
                    SonLibrary:Notify({Title = "Error", Content = "Invalid key entered!"})
                end
            end)
        end
    end

    local HudContainer = nil
    if ShowWatermark then
        HudContainer = Instance.new("Frame")
        HudContainer.Name = "HudContainer"
        HudContainer.Size = UDim2.new(0, 600, 0, 50)
        HudContainer.Position = UDim2.new(0, 16, 0, 48)
        HudContainer.BackgroundTransparency = 1
        HudContainer.Parent = ScreenGui

        local HudVerticalLayout = Instance.new("UIListLayout")
        HudVerticalLayout.SortOrder = Enum.SortOrder.LayoutOrder
        HudVerticalLayout.Padding = UDim.new(0, 4)
        HudVerticalLayout.Parent = HudContainer

        local function createHudRow(name, height, order)
            local row = Instance.new("Frame")
            row.Name = name
            row.Size = UDim2.new(1, 0, 0, height)
            row.BackgroundTransparency = 1
            row.LayoutOrder = order
            row.Parent = HudContainer

            local hLayout = Instance.new("UIListLayout")
            hLayout.FillDirection = Enum.FillDirection.Horizontal
            hLayout.SortOrder = Enum.SortOrder.LayoutOrder
            hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            hLayout.Padding = UDim.new(0, 5)
            hLayout.Parent = row
            return row
        end

        local TopHudRow = createHudRow("TopRow", 22, 1)
        local BottomHudRow = createHudRow("BottomRow", 22, 2)

        local function createHudPill(parent, order)
            local pill = Instance.new("Frame")
            pill.AutomaticSize = Enum.AutomaticSize.X
            pill.Size = UDim2.new(0, 0, 1, 0)
            pill.BackgroundColor3 = THEME.PillBg
            pill.BorderSizePixel = 0
            pill.LayoutOrder = order
            pill.Parent = parent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = pill

            local stroke = Instance.new("UIStroke")
            stroke.Color = THEME.Border
            stroke.Thickness = 1
            stroke.Parent = pill

            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 6)
            pad.PaddingRight = UDim.new(0, 6)
            pad.Parent = pill

            local layout = Instance.new("UIListLayout")
            layout.FillDirection = Enum.FillDirection.Horizontal
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.VerticalAlignment = Enum.VerticalAlignment.Center
            layout.Padding = UDim.new(0, 5)
            layout.Parent = pill
            return pill
        end

        local function addHudDivider(parent, order)
            local div = Instance.new("Frame")
            div.Size = UDim2.new(0, 1, 0, 10)
            div.BackgroundColor3 = THEME.Divider
            div.BorderSizePixel = 0
            div.LayoutOrder = order
            div.Parent = parent
        end

        local function addHudText(parent, text, isMuted, order)
            local lbl = Instance.new("TextLabel")
            lbl.AutomaticSize = Enum.AutomaticSize.X
            lbl.Size = UDim2.new(0, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 10.5
            lbl.TextColor3 = isMuted and THEME.TextMuted or THEME.TextPrimary
            lbl.LayoutOrder = order
            lbl.Parent = parent
            return lbl
        end

        local function addHudSmallIcon(parent, iconId, order)
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 11, 0, 11)
            icon.BackgroundTransparency = 1
            icon.Image = iconId
            icon.ScaleType = Enum.ScaleType.Fit
            icon.ImageColor3 = THEME.Accent
            icon.LayoutOrder = order
            icon.Parent = parent
            return icon
        end

        local BrandPill = createHudPill(TopHudRow, 1)

        local HudLogoWrap = Instance.new("Frame")
        HudLogoWrap.Size = UDim2.new(0, 20, 0, 20)
        HudLogoWrap.BackgroundTransparency = 1
        HudLogoWrap.LayoutOrder = 1
        HudLogoWrap.Parent = BrandPill

        local HudLogoGlow = Instance.new("ImageLabel")
        HudLogoGlow.Size = UDim2.new(2, 0, 2, 0)
        HudLogoGlow.Position = UDim2.new(-0.5, 0, -0.5, 0)
        HudLogoGlow.BackgroundTransparency = 1
        HudLogoGlow.Image = "rbxassetid://5028857084"
        HudLogoGlow.ImageColor3 = THEME.Accent
        HudLogoGlow.ImageTransparency = 0.65
        HudLogoGlow.ZIndex = 1
        HudLogoGlow.Parent = HudLogoWrap

        local HudBrandLogo = Instance.new("ImageLabel")
        HudBrandLogo.Size = UDim2.new(1.35, 0, 1.35, 0)
        HudBrandLogo.Position = UDim2.new(-0.175, 0, -0.175, 0)
        HudBrandLogo.BackgroundTransparency = 1
        HudBrandLogo.Image = LogoId
        HudBrandLogo.ScaleType = Enum.ScaleType.Fit
        HudBrandLogo.ImageColor3 = Color3.fromRGB(255, 255, 255)
        HudBrandLogo.ZIndex = 2
        HudBrandLogo.Parent = HudLogoWrap

        local HudLogoGrad = Instance.new("UIGradient")
        HudLogoGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, THEME.AccentSoft),
            ColorSequenceKeypoint.new(0.45, THEME.Accent),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(165, 32, 42))
        })
        HudLogoGrad.Rotation = -35
        HudLogoGrad.Parent = HudBrandLogo

        addHudDivider(BrandPill, 2)
        local HudBrandText = addHudText(BrandPill, Title, false, 3)

        local HudBrandGrad = Instance.new("UIGradient")
        HudBrandGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, THEME.AccentSoft),
            ColorSequenceKeypoint.new(1.0, THEME.Accent)
        })
        HudBrandGrad.Parent = HudBrandText

        local StatsPill = createHudPill(TopHudRow, 2)
        addHudSmallIcon(StatsPill, ICONS.User, 1)
        addHudText(StatsPill, string.lower(LocalPlayer.Name), false, 2)
        addHudDivider(StatsPill, 3)

        addHudSmallIcon(StatsPill, ICONS.Chart, 4)
        local FpsLabel = addHudText(StatsPill, "0 Fps", false, 5)
        addHudDivider(StatsPill, 6)

        addHudSmallIcon(StatsPill, ICONS.Clock, 7)
        local TimeLabel = addHudText(StatsPill, "00:00:00", false, 8)

        local PosPill = createHudPill(BottomHudRow, 1)
        addHudSmallIcon(PosPill, ICONS.Compass, 1)
        addHudDivider(PosPill, 2)
        local PosLabel = addHudText(PosPill, "0, 0, 0", false, 3)

        local PingPill = createHudPill(BottomHudRow, 2)
        addHudSmallIcon(PingPill, ICONS.Signal, 1)
        addHudDivider(PingPill, 2)
        local PingLabel = addHudText(PingPill, "0 Ping", false, 3)

        local TickPill = createHudPill(BottomHudRow, 3)
        addHudSmallIcon(TickPill, ICONS.Radar, 1)
        addHudDivider(TickPill, 2)
        local TickLabel = addHudText(TickPill, "20.0 Ticks", false, 3)

        local SpeedPill = createHudPill(BottomHudRow, 4)
        addHudSmallIcon(SpeedPill, ICONS.Speed, 1)
        addHudDivider(SpeedPill, 2)
        local SpeedLabel = addHudText(SpeedPill, "0.0 Bps", false, 3)

        local fpsCounter, lastFpsCheck = 0, os.clock()
        local lastPosition = Vector3.zero
        local lastPosTime = os.clock()

        RunService.RenderStepped:Connect(function()
            if not ScreenGui.Parent then return end
            fpsCounter = fpsCounter + 1
            local now = os.clock()

            if now - lastFpsCheck >= 1 then
                FpsLabel.Text = string.format("%d Fps", fpsCounter)
                fpsCounter = 0
                lastFpsCheck = now
            end

            TimeLabel.Text = os.date("%H:%M:%S")

            pcall(function()
                local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                PingLabel.Text = string.format("%d Ping", ping)
            end)

            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local currentPos = hrp.Position
                PosLabel.Text = string.format("%d, %d, %d", math.floor(currentPos.X), math.floor(currentPos.Y), math.floor(currentPos.Z))

                local deltaTime = now - lastPosTime
                if deltaTime >= 0.1 then
                    local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(lastPosition.X, 0, lastPosition.Z)).Magnitude
                    local bps = dist / deltaTime
                    SpeedLabel.Text = string.format("%.1f Bps", bps)

                    lastPosition = currentPos
                    lastPosTime = now
                end
            else
                PosLabel.Text = "0, 0, 0"
                SpeedLabel.Text = "0.0 Bps"
            end
        end)
    end

    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 790, 0, 490)
    Main.Position = UDim2.new(0.5, -395, 0.5, -245)
    Main.BackgroundColor3 = THEME.Background
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = false
    Main.Visible = (KeyPassed == true)
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = THEME.Border
    MainStroke.Thickness = 1.2
    MainStroke.Parent = Main

    local GlowBackdrop = Instance.new("ImageLabel")
    GlowBackdrop.Name = "GlowBackdrop"
    GlowBackdrop.BackgroundTransparency = 1
    GlowBackdrop.Position = UDim2.new(0, -45, 0, -45)
    GlowBackdrop.Size = UDim2.new(1, 90, 1, 90)
    GlowBackdrop.ZIndex = 0
    GlowBackdrop.Image = "rbxassetid://5028857084"
    GlowBackdrop.ImageColor3 = THEME.AccentDark
    GlowBackdrop.ImageTransparency = 0.83
    GlowBackdrop.ScaleType = Enum.ScaleType.Slice
    GlowBackdrop.SliceCenter = Rect.new(24, 24, 276, 276)
    GlowBackdrop.Parent = Main

    local FloatingBtn = Instance.new("Frame")
    FloatingBtn.Name = "SonHubFloatingToggle"
    FloatingBtn.Size = UDim2.new(0, 46, 0, 46)
    FloatingBtn.Position = UDim2.new(0, 20, 0, 110)
    FloatingBtn.BackgroundColor3 = Color3.fromRGB(18, 14, 16)
    FloatingBtn.BackgroundTransparency = 0.25
    FloatingBtn.BorderSizePixel = 0
    FloatingBtn.ZIndex = 990
    FloatingBtn.Parent = ScreenGui

    local fbCorner = Instance.new("UICorner")
    fbCorner.CornerRadius = UDim.new(0, 10)
    fbCorner.Parent = FloatingBtn

    local fbStroke = Instance.new("UIStroke")
    fbStroke.Color = THEME.Accent
    fbStroke.Thickness = 1.4
    fbStroke.Parent = FloatingBtn

    local fbLogo = Instance.new("ImageLabel")
    fbLogo.Size = UDim2.new(0, 30, 0, 30)
    fbLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
    fbLogo.AnchorPoint = Vector2.new(0.5, 0.5)
    fbLogo.BackgroundTransparency = 1
    fbLogo.Image = LogoId
    fbLogo.ScaleType = Enum.ScaleType.Fit
    fbLogo.ImageColor3 = Color3.fromRGB(255, 255, 255)
    fbLogo.ZIndex = 991
    fbLogo.Parent = FloatingBtn

    local fbClick = Instance.new("TextButton")
    fbClick.Size = UDim2.new(1, 0, 1, 0)
    fbClick.BackgroundTransparency = 1
    fbClick.Text = ""
    fbClick.ZIndex = 992
    fbClick.Parent = FloatingBtn

    do
        local fbDragging, fbDragStart, fbStartPos
        fbClick.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fbDragging = true
                fbDragStart = input.Position
                fbStartPos = FloatingBtn.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if fbDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - fbDragStart
                FloatingBtn.Position = UDim2.new(fbStartPos.X.Scale, fbStartPos.X.Offset + delta.X, fbStartPos.Y.Scale, fbStartPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if fbDragging then
                    fbDragging = false
                    local delta = (input.Position - fbDragStart).Magnitude
                    if delta < 6 then
                        WindowObj:Toggle()
                    end
                end
            end
        end)
    end

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 56)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Main

    do
        local dragging, dragStart, startPos
        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if input.Target and (input.Target:IsA("TextBox") or input.Target:IsA("TextButton") or input.Target:IsA("ImageButton")) then
                    return
                end
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local MainLogoHolder = Instance.new("Frame")
    MainLogoHolder.Name = "LogoHolder"
    MainLogoHolder.Size = UDim2.new(0, 56, 0, 56)
    MainLogoHolder.Position = UDim2.new(0, 24, 0, 0)
    MainLogoHolder.BackgroundTransparency = 1
    MainLogoHolder.Parent = TopBar

    local MainLogoHalo = Instance.new("ImageLabel")
    MainLogoHalo.Name = "Halo"
    MainLogoHalo.Size = UDim2.new(2.1, 0, 2.1, 0)
    MainLogoHalo.Position = UDim2.new(-0.55, 0, -0.55, 0)
    MainLogoHalo.BackgroundTransparency = 1
    MainLogoHalo.Image = "rbxassetid://5028857084"
    MainLogoHalo.ImageColor3 = THEME.Accent
    MainLogoHalo.ImageTransparency = 0.58
    MainLogoHalo.ZIndex = 1
    MainLogoHalo.Parent = MainLogoHolder

    local MainLogoShadow = Instance.new("ImageLabel")
    MainLogoShadow.Name = "LogoShadow"
    MainLogoShadow.Size = UDim2.new(1, 0, 1, 0)
    MainLogoShadow.Position = UDim2.new(0, 2, 0, 2)
    MainLogoShadow.BackgroundTransparency = 1
    MainLogoShadow.Image = LogoId
    MainLogoShadow.ScaleType = Enum.ScaleType.Fit
    MainLogoShadow.ImageColor3 = Color3.fromRGB(50, 10, 14)
    MainLogoShadow.ImageTransparency = 0.2
    MainLogoShadow.ZIndex = 2
    MainLogoShadow.Parent = MainLogoHolder

    local MainLogoImg = Instance.new("ImageLabel")
    MainLogoImg.Name = "LogoMain"
    MainLogoImg.Size = UDim2.new(1, 0, 1, 0)
    MainLogoImg.Position = UDim2.new(0, 0, 0, 0)
    MainLogoImg.BackgroundTransparency = 1
    MainLogoImg.Image = LogoId
    MainLogoImg.ScaleType = Enum.ScaleType.Fit
    MainLogoImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
    MainLogoImg.ZIndex = 3
    MainLogoImg.Parent = MainLogoHolder

    local MainLogoGrad = Instance.new("UIGradient")
    MainLogoGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, THEME.AccentSoft),
        ColorSequenceKeypoint.new(0.45, THEME.Accent),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(165, 32, 42))
    })
    MainLogoGrad.Rotation = -35
    MainLogoGrad.Parent = MainLogoImg

    local SearchBox = Instance.new("Frame")
    SearchBox.Size = UDim2.new(0, 160, 0, 26)
    SearchBox.Position = UDim2.new(0, 88, 0.5, -13)
    SearchBox.BackgroundColor3 = THEME.CardBg
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = TopBar

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBox

    local SearchStroke = Instance.new("UIStroke")
    SearchStroke.Color = THEME.Border
    SearchStroke.Thickness = 0.8
    SearchStroke.Parent = SearchBox

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Size = UDim2.new(0, 13, 0, 13)
    SearchIcon.Position = UDim2.new(0, 9, 0.5, -6.5)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = ICONS.Search
    SearchIcon.ImageColor3 = THEME.TextMuted
    SearchIcon.Parent = SearchBox

    local SearchInput = Instance.new("TextBox")
    SearchInput.PlaceholderText = "Search..."
    SearchInput.PlaceholderColor3 = THEME.TextMuted
    SearchInput.TextColor3 = THEME.TextPrimary
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.TextSize = 11
    SearchInput.Position = UDim2.new(0, 28, 0, 0)
    SearchInput.Size = UDim2.new(1, -32, 1, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.Parent = SearchBox

    local CenterTitle = Instance.new("TextLabel")
    CenterTitle.Name = "CenterTitle"
    CenterTitle.Size = UDim2.new(0, 240, 1, 0)
    CenterTitle.Position = UDim2.new(0.5, 0, 0.5, 0)
    CenterTitle.AnchorPoint = Vector2.new(0.5, 0.5)
    CenterTitle.BackgroundTransparency = 1
    CenterTitle.Text = config.Title or "SonHUB"
    CenterTitle.Font = Enum.Font.GothamBold
    CenterTitle.TextSize = 20
    CenterTitle.TextColor3 = THEME.TextPrimary
    CenterTitle.TextXAlignment = Enum.TextXAlignment.Center
    CenterTitle.Parent = TopBar

    local CenterTitleGrad = Instance.new("UIGradient")
    CenterTitleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 235, 238)),
        ColorSequenceKeypoint.new(1.0, THEME.AccentSoft)
    })
    CenterTitleGrad.Parent = CenterTitle

    local WindowControls = Instance.new("Frame")
    WindowControls.Name = "WindowControls"
    WindowControls.Size = UDim2.new(0, 104, 0, 24)
    WindowControls.Position = UDim2.new(1, -14, 0.5, 0)
    WindowControls.AnchorPoint = Vector2.new(1, 0.5)
    WindowControls.BackgroundTransparency = 1
    WindowControls.Parent = TopBar

    local wcList = Instance.new("UIListLayout")
    wcList.FillDirection = Enum.FillDirection.Horizontal
    wcList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    wcList.VerticalAlignment = Enum.VerticalAlignment.Center
    wcList.Padding = UDim.new(0, 3)
    wcList.Parent = WindowControls

    local ModeBtn = Instance.new("TextButton")
    ModeBtn.Name = "ModeBtn"
    ModeBtn.Size = UDim2.new(0, 24, 0, 24)
    ModeBtn.BackgroundTransparency = 1
    ModeBtn.Text = "◫"
    ModeBtn.Font = Enum.Font.GothamBold
    ModeBtn.TextSize = 13
    ModeBtn.TextColor3 = THEME.TextDim
    ModeBtn.AutoButtonColor = false
    ModeBtn.Parent = WindowControls

    local ZoomBtn = Instance.new("TextButton")
    ZoomBtn.Name = "ZoomBtn"
    ZoomBtn.Size = UDim2.new(0, 24, 0, 24)
    ZoomBtn.BackgroundTransparency = 1
    ZoomBtn.Text = "⛶"
    ZoomBtn.Font = Enum.Font.GothamBold
    ZoomBtn.TextSize = 12
    ZoomBtn.TextColor3 = THEME.TextDim
    ZoomBtn.AutoButtonColor = false
    ZoomBtn.Parent = WindowControls

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 24, 0, 24)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "—"
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 12
    MinBtn.TextColor3 = THEME.TextDim
    MinBtn.AutoButtonColor = false
    MinBtn.Parent = WindowControls

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.TextColor3 = THEME.TextDim
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = WindowControls

    for _, b in ipairs({ModeBtn, ZoomBtn, MinBtn}) do
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TWEEN_FAST, {TextColor3 = THEME.TextPrimary}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TWEEN_FAST, {TextColor3 = THEME.TextDim}):Play()
        end)
    end
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TWEEN_FAST, {TextColor3 = THEME.Accent}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TWEEN_FAST, {TextColor3 = THEME.TextDim}):Play()
    end)
    MinBtn.MouseButton1Click:Connect(function()
        WindowObj:Toggle()
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        WindowObj:Toggle(false)
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 155, 1, -58)
    Sidebar.Position = UDim2.new(0, 14, 0, 54)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = Main

    local SideScroll = Instance.new("ScrollingFrame")
    SideScroll.Size = UDim2.new(1, 0, 1, -34)
    SideScroll.BackgroundTransparency = 1
    SideScroll.ScrollBarThickness = 0
    SideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    SideScroll.Parent = Sidebar

    local SideList = Instance.new("UIListLayout")
    SideList.Padding = UDim.new(0, 2)
    SideList.SortOrder = Enum.SortOrder.LayoutOrder
    SideList.Parent = SideScroll

    local Footer = Instance.new("Frame")
    Footer.Size = UDim2.new(0, 160, 0, 28)
    Footer.Position = UDim2.new(0, 18, 1, -38)
    Footer.BackgroundTransparency = 1
    Footer.Parent = Main

    local UserLabel = Instance.new("TextLabel")
    UserLabel.Size = UDim2.new(1, 0, 0, 13)
    UserLabel.BackgroundTransparency = 1
    UserLabel.Text = (config.Footer and config.Footer.Title) or string.lower(LocalPlayer.Name)
    UserLabel.Font = Enum.Font.GothamBold
    UserLabel.TextSize = 10
    UserLabel.TextColor3 = THEME.TextMuted
    UserLabel.TextXAlignment = Enum.TextXAlignment.Left
    UserLabel.Parent = Footer

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(1, 0, 0, 11)
    SubLabel.Position = UDim2.new(0, 0, 0, 13)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = (config.Footer and config.Footer.Subtitle) or SubTitle
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextSize = 7.5
    SubLabel.TextColor3 = THEME.TextDim
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = Footer

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -188, 1, -58)
    ContentArea.Position = UDim2.new(0, 176, 0, 52)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Main

    local DialogOverlay = Instance.new("Frame")
    DialogOverlay.Name = "DialogOverlay"
    DialogOverlay.Size = UDim2.new(1, 0, 1, 0)
    DialogOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    DialogOverlay.BackgroundTransparency = 1
    DialogOverlay.Visible = false
    DialogOverlay.ZIndex = 60
    DialogOverlay.Parent = Main

    local dOverlayCorner = Instance.new("UICorner")
    dOverlayCorner.CornerRadius = UDim.new(0, 12)
    dOverlayCorner.Parent = DialogOverlay

    local WindowObj = {
        MainFrame = Main,
        ScreenGui = ScreenGui,
        Tabs = {},
        ActiveTab = nil,
        RegisteredRows = {},
        IsVisible = (KeyPassed == true),
        CurrentColumns = WindowDefaultColumns or 2,
        IsZoomed = false,
        NormalSize = UDim2.new(0, 790, 0, 490),
        SingleColSize = UDim2.new(0, 550, 0, 520),
        ZoomedSize = UDim2.new(0, 960, 0, 600),
    }

    local isUIVisible = (KeyPassed == true)
    local function setWindowVisible(state)
        isUIVisible = state
        WindowObj.IsVisible = state
        if isUIVisible then
            Main.Visible = true
            local targetSize = WindowObj.IsZoomed and WindowObj.ZoomedSize or ((WindowObj.CurrentColumns == 1) and WindowObj.SingleColSize or WindowObj.NormalSize)
            safeTween(Main, TWEEN_SLOW, {
                Position = UDim2.new(0.5, -targetSize.X.Offset / 2, 0.5, -targetSize.Y.Offset / 2),
                BackgroundTransparency = 0
            })
            safeTween(GlowBackdrop, TWEEN_SLOW, {ImageTransparency = 0.83})
        else
            local targetSize = WindowObj.IsZoomed and WindowObj.ZoomedSize or ((WindowObj.CurrentColumns == 1) and WindowObj.SingleColSize or WindowObj.NormalSize)
            local hideTween = safeTween(Main, TWEEN_SLOW, {
                Position = UDim2.new(0.5, -targetSize.X.Offset / 2, 0.5, -targetSize.Y.Offset / 2 + 30),
                BackgroundTransparency = 1
            })
            safeTween(GlowBackdrop, TWEEN_SLOW, {ImageTransparency = 1})
            hideTween.Completed:Connect(function()
                if not isUIVisible then Main.Visible = false end
            end)
        end
    end

    function WindowObj:Toggle(state)
        if state ~= nil then
            setWindowVisible(state)
        else
            setWindowVisible(not isUIVisible)
        end
    end

    function WindowObj:SetColumns(cols)
        cols = (cols == 1) and 1 or 2
        WindowObj.CurrentColumns = cols
        ModeBtn.Text = (cols == 1) and "⚌" or "◫"

        local targetSize = (cols == 1) and WindowObj.SingleColSize or WindowObj.NormalSize
        if not WindowObj.IsZoomed then
            safeTween(Main, TWEEN_FAST, {
                Size = targetSize,
                Position = UDim2.new(0.5, -targetSize.X.Offset / 2, 0.5, -targetSize.Y.Offset / 2)
            })
        end

        if cols == 1 then
            ContentArea.Size = UDim2.new(1, -165, 1, -58)
            Sidebar.Size = UDim2.new(0, 135, 1, -58)
            SearchBox.Size = UDim2.new(0, 120, 0, 26)
            CenterTitle.Size = UDim2.new(0, 180, 1, 0)
        else
            ContentArea.Size = UDim2.new(1, -188, 1, -58)
            Sidebar.Size = UDim2.new(0, 155, 1, -58)
            SearchBox.Size = UDim2.new(0, 160, 0, 26)
            CenterTitle.Size = UDim2.new(0, 240, 1, 0)
        end

        for _, tab in ipairs(WindowObj.Tabs) do
            if tab.SetColumns then
                tab:SetColumns(cols)
            end
        end
    end

    function WindowObj:ToggleColumns()
        local nextCols = (WindowObj.CurrentColumns == 1) and 2 or 1
        WindowObj:SetColumns(nextCols)
    end

    function WindowObj:ToggleZoom()
        WindowObj.IsZoomed = not WindowObj.IsZoomed
        ZoomBtn.Text = WindowObj.IsZoomed and "🗗" or "⛶"
        if WindowObj.IsZoomed then
            safeTween(Main, TWEEN_FAST, {
                Size = WindowObj.ZoomedSize,
                Position = UDim2.new(0.5, -480, 0.5, -300)
            })
        else
            local baseSize = (WindowObj.CurrentColumns == 1) and WindowObj.SingleColSize or WindowObj.NormalSize
            safeTween(Main, TWEEN_FAST, {
                Size = baseSize,
                Position = UDim2.new(0.5, -baseSize.X.Offset / 2, 0.5, -baseSize.Y.Offset / 2)
            })
        end
    end

    ModeBtn.MouseButton1Click:Connect(function()
        WindowObj:ToggleColumns()
    end)

    ZoomBtn.MouseButton1Click:Connect(function()
        WindowObj:ToggleZoom()
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == ToggleKey then
            WindowObj:Toggle()
        end
    end)

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        for _, item in ipairs(WindowObj.RegisteredRows) do
            if query == "" or string.find(item.Name, query, 1, true) then
                item.Frame.Visible = true
            else
                item.Frame.Visible = false
            end
        end
    end)

    function WindowObj:SetWatermark(state: boolean)
        if HudContainer then HudContainer.Visible = state end
    end

    function WindowObj:Notify(c) SonLibrary:Notify(c) end

    function WindowObj:Destroy()
        pcall(function() ScreenGui:Destroy() end)
    end

    function WindowObj:CreateDialog(dConfig: {
        Title: string?,
        Content: string?,
        Buttons: {{Title: string, Style: string?, Callback: (() -> ())?}}?
    })
        dConfig = dConfig or {}
        local dTitle = dConfig.Title or "Confirm"
        local dContent = dConfig.Content or "Are you sure?"
        local buttons = dConfig.Buttons or {{Title = "Yes", Style = "Primary"}, {Title = "No", Style = "Danger"}}

        DialogOverlay.Visible = true
        TweenService:Create(DialogOverlay, TWEEN_FAST, {BackgroundTransparency = 0.45}):Play()

        local dCard = Instance.new("Frame")
        dCard.Size = UDim2.new(0, 320, 0, 0)
        dCard.AutomaticSize = Enum.AutomaticSize.Y
        dCard.Position = UDim2.new(0.5, -160, 0.5, -60)
        dCard.BackgroundColor3 = THEME.CardBg
        dCard.BorderSizePixel = 0
        dCard.ZIndex = 62
        dCard.Parent = DialogOverlay

        local dcCor = Instance.new("UICorner")
        dcCor.CornerRadius = UDim.new(0, 8)
        dcCor.Parent = dCard

        local dcStr = Instance.new("UIStroke")
        dcStr.Color = THEME.BorderActive
        dcStr.Thickness = 1
        dcStr.Parent = dCard

        local dcPad = Instance.new("UIPadding")
        dcPad.PaddingTop = UDim.new(0, 12)
        dcPad.PaddingBottom = UDim.new(0, 12)
        dcPad.PaddingLeft = UDim.new(0, 14)
        dcPad.PaddingRight = UDim.new(0, 14)
        dcPad.Parent = dCard

        local dcLay = Instance.new("UIListLayout")
        dcLay.Padding = UDim.new(0, 8)
        dcLay.Parent = dCard

        local hTitle = Instance.new("TextLabel")
        hTitle.Size = UDim2.new(1, 0, 0, 16)
        hTitle.BackgroundTransparency = 1
        hTitle.Text = dTitle
        hTitle.Font = Enum.Font.GothamBold
        hTitle.TextSize = 12
        hTitle.TextColor3 = THEME.TextPrimary
        hTitle.TextXAlignment = Enum.TextXAlignment.Left
        hTitle.ZIndex = 63
        hTitle.Parent = dCard

        local bText = Instance.new("TextLabel")
        bText.Size = UDim2.new(1, 0, 0, 0)
        bText.AutomaticSize = Enum.AutomaticSize.Y
        bText.BackgroundTransparency = 1
        bText.Text = dContent
        bText.Font = Enum.Font.Gotham
        bText.TextSize = 10
        bText.TextColor3 = THEME.TextMuted
        bText.TextWrapped = true
        bText.TextXAlignment = Enum.TextXAlignment.Left
        bText.ZIndex = 63
        bText.Parent = dCard

        local bRow = Instance.new("Frame")
        bRow.Size = UDim2.new(1, 0, 0, 26)
        bRow.BackgroundTransparency = 1
        bRow.ZIndex = 63
        bRow.Parent = dCard

        local bList = Instance.new("UIListLayout")
        bList.FillDirection = Enum.FillDirection.Horizontal
        bList.HorizontalAlignment = Enum.HorizontalAlignment.Right
        bList.Padding = UDim.new(0, 6)
        bList.Parent = bRow

        local function closeD()
            local tw = TweenService:Create(DialogOverlay, TWEEN_FAST, {BackgroundTransparency = 1})
            tw:Play()
            tw.Completed:Connect(function()
                dCard:Destroy()
                DialogOverlay.Visible = false
            end)
        end

        for _, bData in ipairs(buttons) do
            local isPrim = (bData.Style == "Primary")
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 75, 0, 24)
            btn.BackgroundColor3 = isPrim and THEME.Accent or THEME.BadgeBg
            btn.Text = bData.Title
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 10
            btn.TextColor3 = isPrim and Color3.fromRGB(255, 255, 255) or THEME.TextMuted
            btn.AutoButtonColor = false
            btn.ZIndex = 64
            btn.Parent = bRow

            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 5)
            bc.Parent = btn

            btn.MouseButton1Click:Connect(function()
                closeD()
                if bData.Callback then pcall(bData.Callback) end
            end)
        end
    end

    local sbOrder = 1
    function WindowObj:CreateCategory(catName: string)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.LayoutOrder = sbOrder
        sbOrder = sbOrder + 1
        lbl.BackgroundTransparency = 1
        lbl.Text = "   " .. catName:upper()
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 9
        lbl.TextColor3 = THEME.TextDim
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = SideScroll
    end

    function WindowObj:SelectTab(target: any)
        for _, tab in ipairs(WindowObj.Tabs) do
            if tab == target or string.lower(tab.Name) == string.lower(tostring(target)) then
                tab:Select()
                break
            end
        end
    end

    function WindowObj:CreateTab(tabConfig: {Title: string?, Name: string?, Icon: string?, Columns: number?})
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Title or tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or ICONS.Combat
        local autoCols = (tabConfig.Columns or WindowDefaultColumns)

        local TabContainer = Instance.new("Frame")
        TabContainer.Name = "Tab_" .. tabName
        TabContainer.Size = UDim2.new(1, 0, 1, 0)
        TabContainer.BackgroundTransparency = 1
        TabContainer.Visible = false
        TabContainer.Parent = ContentArea

        local Col1 = Instance.new("ScrollingFrame")
        Col1.Name = "Column_Left"
        Col1.Size = (WindowObj.CurrentColumns == 1) and UDim2.new(1, 0, 1, 0) or UDim2.new(0.485, 0, 1, 0)
        Col1.BackgroundTransparency = 1
        Col1.ScrollBarThickness = 0
        Col1.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Col1.CanvasSize = UDim2.new(0, 0, 0, 0)
        Col1.Parent = TabContainer

        local Col2 = Instance.new("ScrollingFrame")
        Col2.Name = "Column_Right"
        Col2.Size = UDim2.new(0.485, 0, 1, 0)
        Col2.Position = UDim2.new(0.515, 0, 0, 0)
        Col2.BackgroundTransparency = 1
        Col2.ScrollBarThickness = 0
        Col2.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Col2.CanvasSize = UDim2.new(0, 0, 0, 0)
        Col2.Visible = (WindowObj.CurrentColumns ~= 1)
        Col2.Parent = TabContainer

        for _, c in ipairs({Col1, Col2}) do
            local l = Instance.new("UIListLayout")
            l.Padding = UDim.new(0, 14)
            l.SortOrder = Enum.SortOrder.LayoutOrder
            l.Parent = c
        end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 29)
        btn.LayoutOrder = sbOrder
        sbOrder = sbOrder + 1
        btn.BackgroundColor3 = THEME.Background
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = SideScroll

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 0, 0)
        stroke.Transparency = 1
        stroke.Thickness = 1
        stroke.Parent = btn

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 14, 0, 14)
        icon.Position = UDim2.new(0, 9, 0.5, -7)
        icon.BackgroundTransparency = 1
        icon.Image = tabIcon
        icon.ImageColor3 = THEME.TextMuted
        icon.Parent = btn

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -32, 1, 0)
        title.Position = UDim2.new(0, 30, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = tabName
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 11
        title.TextColor3 = THEME.TextMuted
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = btn

        local TabObj = {
            Name = tabName,
            Columns = autoCols,
            Container = TabContainer,
            Button = btn,
            Icon = icon,
            Title = title,
            Stroke = stroke,
            Cards = {},
            CardOrder1 = 1,
            CardOrder2 = 1,
        }

        function TabObj:SetColumns(colCount)
            if colCount == 1 then
                Col1.Size = UDim2.new(1, 0, 1, 0)
                Col2.Visible = false
                for _, cData in ipairs(TabObj.Cards) do
                    cData.Card.Parent = Col1
                    cData.Card.LayoutOrder = cData.SingleOrder
                end
            else
                Col1.Size = UDim2.new(0.485, 0, 1, 0)
                Col2.Visible = true
                for _, cData in ipairs(TabObj.Cards) do
                    if cData.OriginalCol == 2 then
                        cData.Card.Parent = Col2
                        cData.Card.LayoutOrder = cData.ColOrder
                    else
                        cData.Card.Parent = Col1
                        cData.Card.LayoutOrder = cData.ColOrder
                    end
                end
            end
        end

        function TabObj:Select()
            if WindowObj.ActiveTab == TabObj then return end

            if WindowObj.ActiveTab then
                local prev = WindowObj.ActiveTab
                prev.Container.Visible = false
                TweenService:Create(prev.Button, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
                TweenService:Create(prev.Stroke, TWEEN_FAST, {Transparency = 1}):Play()
                TweenService:Create(prev.Icon, TWEEN_FAST, {ImageColor3 = THEME.TextMuted}):Play()
                TweenService:Create(prev.Title, TWEEN_FAST, {TextColor3 = THEME.TextMuted}):Play()
            end

            WindowObj.ActiveTab = TabObj
            TabContainer.Visible = true
            TweenService:Create(btn, TWEEN_FAST, {BackgroundTransparency = 0, BackgroundColor3 = THEME.SidebarActive}):Play()
            TweenService:Create(stroke, TWEEN_FAST, {Transparency = 0, Color = THEME.BorderActive}):Play()
            TweenService:Create(icon, TWEEN_FAST, {ImageColor3 = THEME.Accent}):Play()
            TweenService:Create(title, TWEEN_FAST, {TextColor3 = THEME.TextPrimary}):Play()
        end

        btn.MouseEnter:Connect(function()
            if WindowObj.ActiveTab ~= TabObj then
                TweenService:Create(title, TWEEN_FAST, {TextColor3 = THEME.TextPrimary}):Play()
                TweenService:Create(icon, TWEEN_FAST, {ImageColor3 = THEME.TextPrimary}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if WindowObj.ActiveTab ~= TabObj then
                TweenService:Create(title, TWEEN_FAST, {TextColor3 = THEME.TextMuted}):Play()
                TweenService:Create(icon, TWEEN_FAST, {ImageColor3 = THEME.TextMuted}):Play()
            end
        end)

        btn.MouseButton1Click:Connect(function()
            TabObj:Select()
        end)

        table.insert(WindowObj.Tabs, TabObj)

        if initialDefaultTab and (string.lower(initialDefaultTab) == string.lower(tabName)) then
            TabObj:Select()
        elseif #WindowObj.Tabs == 1 then
            TabObj:Select()
        end

        function TabObj:CreateSection(secConfig: any, targetCol: number?)
            local secTitle = "Section"
            local isCollapsible = false
            local defaultOpen = true

            if type(secConfig) == "table" then
                secTitle = secConfig.Title or secConfig.Name or "Section"
                isCollapsible = (secConfig.Collapsible == true)
                defaultOpen = (secConfig.DefaultOpen ~= false)
            else
                secTitle = tostring(secConfig or "Section")
            end

            local chosen = targetCol or 1
            local order = 1
            if chosen == 2 then
                order = TabObj.CardOrder2
                TabObj.CardOrder2 = TabObj.CardOrder2 + 1
            else
                order = TabObj.CardOrder1
                TabObj.CardOrder1 = TabObj.CardOrder1 + 1
            end

            local parentCol
            if WindowObj.CurrentColumns == 1 then
                parentCol = Col1
            else
                parentCol = (chosen == 2) and Col2 or Col1
            end

            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 0)
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.BackgroundColor3 = THEME.CardBg
            card.BorderSizePixel = 0
            card.LayoutOrder = order
            card.Parent = parentCol

            table.insert(TabObj.Cards, {
                Card = card,
                OriginalCol = chosen,
                ColOrder = order,
                SingleOrder = #TabObj.Cards + 1
            })

            local cCor = Instance.new("UICorner")
            cCor.CornerRadius = UDim.new(0, 8)
            cCor.Parent = card

            local s = Instance.new("UIStroke")
            s.Color = THEME.Border
            s.Thickness = 0.8
            s.Parent = card

            local p = Instance.new("UIPadding")
            p.PaddingTop = UDim.new(0, 11)
            p.PaddingBottom = UDim.new(0, 13)
            p.PaddingLeft = UDim.new(0, 12)
            p.PaddingRight = UDim.new(0, 12)
            p.Parent = card

            local list = Instance.new("UIListLayout")
            list.Padding = UDim.new(0, 8)
            list.SortOrder = Enum.SortOrder.LayoutOrder
            list.Parent = card

            local header = Instance.new("Frame")
            header.Size = UDim2.new(1, 0, 0, 20)
            header.BackgroundTransparency = 1
            header.LayoutOrder = 0
            header.Parent = card

            local accentPill = Instance.new("Frame")
            accentPill.Size = UDim2.new(0, 3, 0, 13)
            accentPill.Position = UDim2.new(0, 0, 0.5, -6.5)
            accentPill.BackgroundColor3 = THEME.Accent
            accentPill.BorderSizePixel = 0
            accentPill.Parent = header

            local apCor = Instance.new("UICorner")
            apCor.CornerRadius = UDim.new(1, 0)
            apCor.Parent = accentPill

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -30, 1, 0)
            title.Position = UDim2.new(0, 9, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = secTitle
            title.Font = Enum.Font.GothamBold
            title.TextSize = 12.5
            title.TextColor3 = THEME.TextPrimary
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Parent = header

            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 12, 0, 12)
            icon.Position = UDim2.new(1, -12, 0.5, -6)
            icon.BackgroundTransparency = 1
            icon.Image = ICONS.Chevron
            icon.ImageColor3 = THEME.Accent
            icon.Parent = header

            local BodyContainer = Instance.new("Frame")
            BodyContainer.Size = UDim2.new(1, 0, 0, 0)
            BodyContainer.AutomaticSize = Enum.AutomaticSize.Y
            BodyContainer.BackgroundTransparency = 1
            BodyContainer.LayoutOrder = 1
            BodyContainer.ClipsDescendants = true
            BodyContainer.Visible = defaultOpen
            BodyContainer.Parent = card

            local bList = Instance.new("UIListLayout")
            bList.Padding = UDim.new(0, 6)
            bList.SortOrder = Enum.SortOrder.LayoutOrder
            bList.Parent = BodyContainer

            if isCollapsible then
                local isCollapsed = not defaultOpen
                local headClick = Instance.new("TextButton")
                headClick.Size = UDim2.new(1, 0, 1, 0)
                headClick.BackgroundTransparency = 1
                headClick.Text = ""
                headClick.Parent = header

                headClick.MouseButton1Click:Connect(function()
                    isCollapsed = not isCollapsed
                    BodyContainer.Visible = not isCollapsed
                    TweenService:Create(icon, TWEEN_FAST, {Rotation = isCollapsed and 0 or 90}):Play()
                end)
            end

            local ActiveDropdown = nil
            local KeybindListening = nil

            local function openKeybindModal(targetBadge, onKeySelected)
                if KeybindListening then KeybindListening:Disconnect() end
                targetBadge.Text = "..."
                targetBadge.TextColor3 = THEME.Accent

                KeybindListening = UserInputService.InputBegan:Connect(function(inp, proc)
                    if proc then return end
                    if inp.UserInputType == Enum.UserInputType.Keyboard then
                        local keyName = inp.KeyCode.Name
                        targetBadge.Text = (keyName == "Escape") and "-" or keyName
                        targetBadge.TextColor3 = THEME.TextMuted
                        KeybindListening:Disconnect()
                        KeybindListening = nil
                        if onKeySelected then onKeySelected(inp.KeyCode) end
                    end
                end)
            end

            local function toggleDropdown(parentRow, badgeLabel, onReset)
                if ActiveDropdown then
                    ActiveDropdown:Destroy()
                    ActiveDropdown = nil
                    return
                end

                local drop = Instance.new("Frame")
                drop.Name = "Dropdown"
                drop.Size = UDim2.new(0, 115, 0, 58)
                drop.Position = UDim2.new(1, -120, 1, 3)
                drop.BackgroundColor3 = Color3.fromRGB(24, 18, 20)
                drop.ZIndex = 30
                drop.Parent = parentRow

                local dc = Instance.new("UICorner")
                dc.CornerRadius = UDim.new(0, 6)
                dc.Parent = drop

                local ds = Instance.new("UIStroke")
                ds.Color = THEME.Border
                ds.Thickness = 1
                ds.Parent = drop

                local dList = Instance.new("UIListLayout")
                dList.Padding = UDim.new(0, 1)
                dList.Parent = drop

                local dPad = Instance.new("UIPadding")
                dPad.PaddingTop = UDim.new(0, 3)
                dPad.PaddingBottom = UDim.new(0, 3)
                dPad.PaddingLeft = UDim.new(0, 5)
                dPad.PaddingRight = UDim.new(0, 5)
                dPad.Parent = drop

                local function addOption(name, onClick)
                    local oBtn = Instance.new("TextButton")
                    oBtn.Size = UDim2.new(1, 0, 0, 24)
                    oBtn.BackgroundTransparency = 1
                    oBtn.Text = " " .. name
                    oBtn.Font = Enum.Font.GothamMedium
                    oBtn.TextSize = 10.5
                    oBtn.TextColor3 = THEME.TextPrimary
                    oBtn.TextXAlignment = Enum.TextXAlignment.Left
                    oBtn.ZIndex = 31
                    oBtn.Parent = drop

                    oBtn.MouseEnter:Connect(function() oBtn.TextColor3 = THEME.Accent end)
                    oBtn.MouseLeave:Connect(function() oBtn.TextColor3 = THEME.TextPrimary end)
                    oBtn.MouseButton1Click:Connect(function()
                        drop:Destroy()
                        ActiveDropdown = nil
                        if onClick then onClick() end
                    end)
                end

                addOption("Bind Key", function()
                    openKeybindModal(badgeLabel)
                end)
                addOption("Reset Value", function()
                    badgeLabel.Text = "-"
                    if onReset then onReset() end
                end)

                ActiveDropdown = drop
            end

            local SectionObj = {Card = card, Body = BodyContainer}

            function SectionObj:CreateToggle(opts: {
                Name: string,
                Description: string?,
                Default: boolean?,
                Flag: string?,
                Keybind: string?,
                Callback: ((boolean) -> ())?
            })
                opts = opts or {}
                local name = opts.Name or "Toggle"
                local desc = opts.Description
                local state = opts.Default or false
                local flag = opts.Flag
                local keybind = opts.Keybind
                local callback = opts.Callback

                if flag then SonLibrary.Flags[flag] = state end

                local row = Instance.new("Frame")
                row.Name = name
                row.Size = UDim2.new(1, 0, 0, desc and 48 or 36)
                row.BackgroundColor3 = THEME.PillBg
                row.BorderSizePixel = 0
                row.Parent = BodyContainer

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local rs = Instance.new("UIStroke")
                rs.Color = THEME.Border
                rs.Thickness = 0.8
                rs.Parent = row

                row.MouseEnter:Connect(function()
                    TweenService:Create(row, TWEEN_FAST, {BackgroundColor3 = THEME.SidebarActive}):Play()
                end)
                row.MouseLeave:Connect(function()
                    TweenService:Create(row, TWEEN_FAST, {BackgroundColor3 = THEME.PillBg}):Play()
                end)

                table.insert(WindowObj.RegisteredRows, {Frame = row, Name = name:lower()})

                local textContainer = Instance.new("Frame")
                textContainer.Size = UDim2.new(1, -90, 1, 0)
                textContainer.Position = UDim2.new(0, 12, 0, 0)
                textContainer.BackgroundTransparency = 1
                textContainer.Parent = row

                local rowTitle = Instance.new("TextLabel")
                rowTitle.Size = UDim2.new(1, 0, 0, 15)
                rowTitle.Position = UDim2.new(0, 0, 0, desc and 7 or 10)
                rowTitle.BackgroundTransparency = 1
                rowTitle.Text = name
                rowTitle.Font = Enum.Font.GothamMedium
                rowTitle.TextSize = 12.5
                rowTitle.TextColor3 = THEME.TextPrimary
                rowTitle.TextXAlignment = Enum.TextXAlignment.Left
                rowTitle.Parent = textContainer

                if desc then
                    local rowDesc = Instance.new("TextLabel")
                    rowDesc.Size = UDim2.new(1, 0, 0, 13)
                    rowDesc.Position = UDim2.new(0, 0, 0, 25)
                    rowDesc.BackgroundTransparency = 1
                    rowDesc.Text = desc
                    rowDesc.Font = Enum.Font.Gotham
                    rowDesc.TextSize = 9.5
                    rowDesc.TextColor3 = THEME.TextMuted
                    rowDesc.TextXAlignment = Enum.TextXAlignment.Left
                    rowDesc.Parent = textContainer
                end

                local badge = Instance.new("TextLabel")
                badge.Size = UDim2.new(0, 26, 0, 18)
                badge.Position = UDim2.new(1, -82, 0.5, -9)
                badge.BackgroundColor3 = THEME.BadgeBg
                badge.Text = keybind or ""
                badge.Visible = (keybind ~= nil)
                badge.Font = Enum.Font.GothamBold
                badge.TextSize = 9.5
                badge.TextColor3 = THEME.TextMuted
                badge.Parent = row

                local bc = Instance.new("UICorner")
                bc.CornerRadius = UDim.new(0, 4)
                bc.Parent = badge

                local bs = Instance.new("UIStroke")
                bs.Color = THEME.Border
                bs.Thickness = 0.8
                bs.Parent = badge

                local switch = Instance.new("TextButton")
                switch.Size = UDim2.new(0, 38, 0, 20)
                switch.Position = UDim2.new(1, -48, 0.5, -10)
                switch.BackgroundColor3 = state and THEME.Accent or THEME.ToggleOff
                switch.Text = ""
                switch.AutoButtonColor = false
                switch.Parent = row

                local sCorner = Instance.new("UICorner")
                sCorner.CornerRadius = UDim.new(1, 0)
                sCorner.Parent = switch

                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 16, 0, 16)
                knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                knob.BackgroundColor3 = state and THEME.KnobOn or THEME.KnobOff
                knob.BorderSizePixel = 0
                knob.Parent = switch

                local kCorner = Instance.new("UICorner")
                kCorner.CornerRadius = UDim.new(1, 0)
                kCorner.Parent = knob

                local function setToggle(val)
                    state = val
                    if flag then SonLibrary.Flags[flag] = state end
                    local targetColor = state and THEME.Accent or THEME.ToggleOff
                    local targetKnobColor = state and THEME.KnobOn or THEME.KnobOff
                    local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)

                    safeTween(switch, TWEEN_FAST, {BackgroundColor3 = targetColor})
                    safeTween(knob, TWEEN_FAST, {BackgroundColor3 = targetKnobColor, Position = targetPos})

                    if callback then callback(state) end
                end

                local rowBtn = Instance.new("TextButton")
                rowBtn.Size = UDim2.new(1, 0, 1, 0)
                rowBtn.BackgroundTransparency = 1
                rowBtn.Text = ""
                rowBtn.ZIndex = 4
                rowBtn.Parent = row

                rowBtn.MouseButton1Click:Connect(function()
                    setToggle(not state)
                end)

                switch.ZIndex = 5
                switch.MouseButton1Click:Connect(function()
                    setToggle(not state)
                end)

                local compObj = {
                    Set = function(_, v) setToggle(v) end,
                    Get = function() return state end,
                }
                if flag then SonLibrary.Registry[flag] = compObj end
                return compObj
            end

            function SectionObj:CreateButton(opts: {
                Name: string,
                Description: string?,
                Callback: (() -> ())?
            })
                opts = opts or {}
                local name = opts.Name or "Button"
                local desc = opts.Description
                local callback = opts.Callback

                local row = Instance.new("Frame")
                row.Name = name
                row.Size = UDim2.new(1, 0, 0, desc and 48 or 36)
                row.BackgroundColor3 = THEME.PillBg
                row.BorderSizePixel = 0
                row.Parent = BodyContainer

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local rs = Instance.new("UIStroke")
                rs.Color = THEME.Border
                rs.Thickness = 0.8
                rs.Parent = row

                table.insert(WindowObj.RegisteredRows, {Frame = row, Name = name:lower()})

                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.AutoButtonColor = false
                btn.Parent = row

                local rowTitle = Instance.new("TextLabel")
                rowTitle.Size = UDim2.new(1, -34, 0, 15)
                rowTitle.Position = UDim2.new(0, 12, 0, desc and 7 or 10)
                rowTitle.BackgroundTransparency = 1
                rowTitle.Text = name
                rowTitle.Font = Enum.Font.GothamMedium
                rowTitle.TextSize = 12.5
                rowTitle.TextColor3 = THEME.TextPrimary
                rowTitle.TextXAlignment = Enum.TextXAlignment.Left
                rowTitle.Parent = row

                if desc then
                    local rowDesc = Instance.new("TextLabel")
                    rowDesc.Size = UDim2.new(1, -34, 0, 13)
                    rowDesc.Position = UDim2.new(0, 12, 0, 25)
                    rowDesc.BackgroundTransparency = 1
                    rowDesc.Text = desc
                    rowDesc.Font = Enum.Font.Gotham
                    rowDesc.TextSize = 9.5
                    rowDesc.TextColor3 = THEME.TextMuted
                    rowDesc.TextXAlignment = Enum.TextXAlignment.Left
                    rowDesc.Parent = row
                end

                local actionIcon = Instance.new("ImageLabel")
                actionIcon.Size = UDim2.new(0, 12, 0, 12)
                actionIcon.Position = UDim2.new(1, -22, 0.5, -6)
                actionIcon.BackgroundTransparency = 1
                actionIcon.Image = ICONS.Chevron
                actionIcon.ImageColor3 = THEME.TextMuted
                actionIcon.Parent = row

                btn.MouseEnter:Connect(function()
                    TweenService:Create(row, TWEEN_FAST, {BackgroundColor3 = THEME.SidebarActive}):Play()
                    TweenService:Create(rowTitle, TWEEN_FAST, {TextColor3 = THEME.Accent}):Play()
                    TweenService:Create(actionIcon, TWEEN_FAST, {ImageColor3 = THEME.Accent}):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(row, TWEEN_FAST, {BackgroundColor3 = THEME.PillBg}):Play()
                    TweenService:Create(rowTitle, TWEEN_FAST, {TextColor3 = THEME.TextPrimary}):Play()
                    TweenService:Create(actionIcon, TWEEN_FAST, {ImageColor3 = THEME.TextMuted}):Play()
                end)
                btn.MouseButton1Click:Connect(function()
                    if callback then pcall(callback) end
                end)

                return {
                    SetTitle = function(_, n) rowTitle.Text = n end,
                    SetCallback = function(_, cb) callback = cb end,
                }
            end

            function SectionObj:CreateSlider(opts: {
                Name: string,
                Description: string?,
                Min: number?,
                Max: number?,
                Default: number?,
                Suffix: string?,
                Increment: number?,
                Flag: string?,
                Callback: ((number) -> ())?
            })
                opts = opts or {}
                local name = opts.Name or "Slider"
                local desc = opts.Description
                local minVal = opts.Min or 0
                local maxVal = opts.Max or 100
                local curVal = opts.Default or minVal
                local suffix = opts.Suffix or ""
                local increment = opts.Increment or 1
                local flag = opts.Flag
                local callback = opts.Callback

                if flag then SonLibrary.Flags[flag] = curVal end

                local row = Instance.new("Frame")
                row.Name = name
                row.Size = UDim2.new(1, 0, 0, desc and 58 or 46)
                row.BackgroundColor3 = THEME.PillBg
                row.BorderSizePixel = 0
                row.Parent = BodyContainer

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local rs = Instance.new("UIStroke")
                rs.Color = THEME.Border
                rs.Thickness = 0.8
                rs.Parent = row

                row.MouseEnter:Connect(function()
                    TweenService:Create(row, TWEEN_FAST, {BackgroundColor3 = THEME.SidebarActive}):Play()
                end)
                row.MouseLeave:Connect(function()
                    TweenService:Create(row, TWEEN_FAST, {BackgroundColor3 = THEME.PillBg}):Play()
                end)

                table.insert(WindowObj.RegisteredRows, {Frame = row, Name = name:lower()})

                local rowTitle = Instance.new("TextLabel")
                rowTitle.Size = UDim2.new(1, -70, 0, 15)
                rowTitle.Position = UDim2.new(0, 12, 0, 7)
                rowTitle.BackgroundTransparency = 1
                rowTitle.Text = name
                rowTitle.Font = Enum.Font.GothamMedium
                rowTitle.TextSize = 12.5
                rowTitle.TextColor3 = THEME.TextPrimary
                rowTitle.TextXAlignment = Enum.TextXAlignment.Left
                rowTitle.Parent = row

                local valLabel = Instance.new("TextLabel")
                valLabel.Size = UDim2.new(0, 60, 0, 15)
                valLabel.Position = UDim2.new(1, -72, 0, 7)
                valLabel.BackgroundTransparency = 1
                valLabel.Text = tostring(curVal) .. suffix
                valLabel.Font = Enum.Font.GothamBold
                valLabel.TextSize = 11.5
                valLabel.TextColor3 = THEME.Accent
                valLabel.TextXAlignment = Enum.TextXAlignment.Right
                valLabel.Parent = row

                if desc then
                    local rowDesc = Instance.new("TextLabel")
                    rowDesc.Size = UDim2.new(1, -24, 0, 13)
                    rowDesc.Position = UDim2.new(0, 12, 0, 23)
                    rowDesc.BackgroundTransparency = 1
                    rowDesc.Text = desc
                    rowDesc.Font = Enum.Font.Gotham
                    rowDesc.TextSize = 9.5
                    rowDesc.TextColor3 = THEME.TextMuted
                    rowDesc.TextXAlignment = Enum.TextXAlignment.Left
                    rowDesc.Parent = row
                end

                local trackPos = desc and 40 or 29
                local track = Instance.new("Frame")
                track.Size = UDim2.new(1, -24, 0, 6)
                track.Position = UDim2.new(0, 12, 0, trackPos)
                track.BackgroundColor3 = THEME.ToggleOff
                track.BorderSizePixel = 0
                track.Parent = row

                local tc = Instance.new("UICorner")
                tc.CornerRadius = UDim.new(1, 0)
                tc.Parent = track

                local fill = Instance.new("Frame")
                local initPct = math.clamp((curVal - minVal) / (maxVal - minVal), 0, 1)
                fill.Size = UDim2.new(initPct, 0, 1, 0)
                fill.BackgroundColor3 = THEME.Accent
                fill.BorderSizePixel = 0
                fill.Parent = track

                local fc = Instance.new("UICorner")
                fc.CornerRadius = UDim.new(1, 0)
                fc.Parent = fill

                local dragging = false
                local function updateSlider(input)
                    local trackAbsX = track.AbsolutePosition.X
                    local trackWidth = track.AbsoluteSize.X
                    local pct = math.clamp((input.Position.X - trackAbsX) / trackWidth, 0, 1)
                    local rawVal = minVal + (maxVal - minVal) * pct
                    local stepped = math.floor((rawVal / increment) + 0.5) * increment
                    curVal = math.clamp(stepped, minVal, maxVal)
                    if flag then SonLibrary.Flags[flag] = curVal end

                    valLabel.Text = tostring(curVal) .. suffix
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    if callback then pcall(callback, curVal) end
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateSlider(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                local compObj = {
                    Set = function(_, v)
                        curVal = math.clamp(v, minVal, maxVal)
                        if flag then SonLibrary.Flags[flag] = curVal end
                        local pct = (curVal - minVal) / (maxVal - minVal)
                        valLabel.Text = tostring(curVal) .. suffix
                        fill.Size = UDim2.new(pct, 0, 1, 0)
                        if callback then pcall(callback, curVal) end
                    end,
                    Get = function() return curVal end,
                }
                if flag then SonLibrary.Registry[flag] = compObj end
                return compObj
            end

            function SectionObj:CreateDropdown(opts: {
                Name: string,
                Description: string?,
                Options: {string}?,
                Default: string?,
                Flag: string?,
                Callback: ((string) -> ())?
            })
                opts = opts or {}
                local name = opts.Name or "Dropdown"
                local desc = opts.Description
                local options = opts.Options or {"Option 1", "Option 2"}
                local selected = opts.Default or options[1] or ""
                local flag = opts.Flag
                local callback = opts.Callback

                if flag then SonLibrary.Flags[flag] = selected end

                local row = Instance.new("Frame")
                row.Name = name
                row.Size = UDim2.new(1, 0, 0, desc and 48 or 36)
                row.BackgroundColor3 = THEME.PillBg
                row.BorderSizePixel = 0
                row.ClipsDescendants = false
                row.Parent = BodyContainer

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local rs = Instance.new("UIStroke")
                rs.Color = THEME.Border
                rs.Thickness = 0.8
                rs.Parent = row

                table.insert(WindowObj.RegisteredRows, {Frame = row, Name = name:lower()})

                local rowTitle = Instance.new("TextLabel")
                rowTitle.Size = UDim2.new(0.48, 0, 0, 15)
                rowTitle.Position = UDim2.new(0, 12, 0, desc and 7 or 10)
                rowTitle.BackgroundTransparency = 1
                rowTitle.Text = name
                rowTitle.Font = Enum.Font.GothamMedium
                rowTitle.TextSize = 12.5
                rowTitle.TextColor3 = THEME.TextPrimary
                rowTitle.TextXAlignment = Enum.TextXAlignment.Left
                rowTitle.Parent = row

                if desc then
                    local rowDesc = Instance.new("TextLabel")
                    rowDesc.Size = UDim2.new(0.48, 0, 0, 13)
                    rowDesc.Position = UDim2.new(0, 12, 0, 25)
                    rowDesc.BackgroundTransparency = 1
                    rowDesc.Text = desc
                    rowDesc.Font = Enum.Font.Gotham
                    rowDesc.TextSize = 9.5
                    rowDesc.TextColor3 = THEME.TextMuted
                    rowDesc.TextXAlignment = Enum.TextXAlignment.Left
                    rowDesc.Parent = row
                end

                local dropBtn = Instance.new("TextButton")
                dropBtn.Size = UDim2.new(0.48, 0, 0, 26)
                dropBtn.Position = UDim2.new(0.5, 0, 0.5, -13)
                dropBtn.BackgroundColor3 = THEME.BadgeBg
                dropBtn.Text = ""
                dropBtn.AutoButtonColor = false
                dropBtn.Parent = row

                local dc = Instance.new("UICorner")
                dc.CornerRadius = UDim.new(0, 5)
                dc.Parent = dropBtn

                local ds = Instance.new("UIStroke")
                ds.Color = THEME.Border
                ds.Thickness = 0.8
                ds.Parent = dropBtn

                local curLabel = Instance.new("TextLabel")
                curLabel.Size = UDim2.new(1, -24, 1, 0)
                curLabel.Position = UDim2.new(0, 8, 0, 0)
                curLabel.BackgroundTransparency = 1
                curLabel.Text = selected
                curLabel.Font = Enum.Font.Gotham
                curLabel.TextSize = 10.5
                curLabel.TextColor3 = THEME.TextPrimary
                curLabel.TextXAlignment = Enum.TextXAlignment.Left
                curLabel.TextTruncate = Enum.TextTruncate.AtEnd
                curLabel.Parent = dropBtn

                local arrow = Instance.new("ImageLabel")
                arrow.Size = UDim2.new(0, 10, 0, 10)
                arrow.Position = UDim2.new(1, -16, 0.5, -5)
                arrow.BackgroundTransparency = 1
                arrow.Image = ICONS.Chevron
                arrow.ImageColor3 = THEME.TextMuted
                arrow.Parent = dropBtn

                local popover = nil
                local outsideConn = nil
                local function closePop()
                    if outsideConn then outsideConn:Disconnect(); outsideConn = nil end
                    if popover then
                        popover:Destroy()
                        popover = nil
                    end
                end

                dropBtn.MouseButton1Click:Connect(function()
                    if popover then closePop(); return end

                    local absPos = dropBtn.AbsolutePosition
                    local absSize = dropBtn.AbsoluteSize
                    local mainPos = Main.AbsolutePosition

                    popover = Instance.new("Frame")
                    popover.Size = UDim2.new(0, absSize.X, 0, math.min(#options * 25 + 6, 135))
                    popover.Position = UDim2.new(0, absPos.X - mainPos.X, 0, absPos.Y - mainPos.Y + absSize.Y + 3)
                    popover.BackgroundColor3 = THEME.CardBg
                    popover.ZIndex = 500
                    popover.Parent = Main

                    local pc = Instance.new("UICorner")
                    pc.CornerRadius = UDim.new(0, 6)
                    pc.Parent = popover

                    local ps = Instance.new("UIStroke")
                    ps.Color = THEME.BorderActive
                    ps.Thickness = 1
                    ps.Parent = popover

                    local scroll = Instance.new("ScrollingFrame")
                    scroll.Size = UDim2.new(1, 0, 1, 0)
                    scroll.BackgroundTransparency = 1
                    scroll.ScrollBarThickness = 2
                    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                    scroll.ZIndex = 501
                    scroll.Parent = popover

                    local sList = Instance.new("UIListLayout")
                    sList.Padding = UDim.new(0, 1)
                    sList.Parent = scroll

                    for _, opt in ipairs(options) do
                        local optBtn = Instance.new("TextButton")
                        optBtn.Size = UDim2.new(1, 0, 0, 24)
                        optBtn.BackgroundTransparency = 1
                        optBtn.Text = "  " .. opt
                        optBtn.Font = Enum.Font.GothamMedium
                        optBtn.TextSize = 10.5
                        optBtn.TextColor3 = (opt == selected) and THEME.Accent or THEME.TextPrimary
                        optBtn.TextXAlignment = Enum.TextXAlignment.Left
                        optBtn.ZIndex = 502
                        optBtn.Parent = scroll

                        optBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            if flag then SonLibrary.Flags[flag] = selected end
                            curLabel.Text = opt
                            closePop()
                            if callback then pcall(callback, opt) end
                        end)
                    end

                    outsideConn = UserInputService.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            task.defer(function()
                                if popover then
                                    local pPos = popover.AbsolutePosition
                                    local pSize = popover.AbsoluteSize
                                    local mX, mY = inp.Position.X, inp.Position.Y
                                    local inP = (mX >= pPos.X and mX <= pPos.X + pSize.X and mY >= pPos.Y and mY <= pPos.Y + pSize.Y)
                                    local inB = (mX >= absPos.X and mX <= absPos.X + absSize.X and mY >= absPos.Y and mY <= absPos.Y + absSize.Y)
                                    if not inP and not inB then
                                        closePop()
                                    end
                                end
                            end)
                        end
                    end)
                end)

                local compObj = {
                    Set = function(_, v)
                        selected = v
                        if flag then SonLibrary.Flags[flag] = selected end
                        curLabel.Text = v
                        if callback then pcall(callback, v) end
                    end,
                    Refresh = function(_, newOpts)
                        options = newOpts or {}
                        selected = options[1] or ""
                        if flag then SonLibrary.Flags[flag] = selected end
                        curLabel.Text = selected
                    end,
                    Get = function() return selected end,
                }
                if flag then SonLibrary.Registry[flag] = compObj end
                return compObj
            end

            function SectionObj:CreateMultiDropdown(opts: {
                Name: string,
                Description: string?,
                Options: {string}?,
                Default: {string}?,
                Flag: string?,
                Callback: (({string}) -> ())?
            })
                opts = opts or {}
                local name = opts.Name or "Multi Dropdown"
                local desc = opts.Description
                local options = opts.Options or {"Option 1", "Option 2"}
                local flag = opts.Flag
                local selectedMap = {}
                for _, def in ipairs(opts.Default or {}) do selectedMap[def] = true end
                local callback = opts.Callback

                local function getList()
                    local l = {}
                    for opt, isSel in pairs(selectedMap) do if isSel then table.insert(l, opt) end end
                    return l
                end

                if flag then SonLibrary.Flags[flag] = getList() end

                local row = Instance.new("Frame")
                row.Name = name
                row.Size = UDim2.new(1, 0, 0, desc and 48 or 36)
                row.BackgroundColor3 = THEME.PillBg
                row.BorderSizePixel = 0
                row.ClipsDescendants = false
                row.Parent = BodyContainer

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local rs = Instance.new("UIStroke")
                rs.Color = THEME.Border
                rs.Thickness = 0.8
                rs.Parent = row

                table.insert(WindowObj.RegisteredRows, {Frame = row, Name = name:lower()})

                local rowTitle = Instance.new("TextLabel")
                rowTitle.Size = UDim2.new(0.48, 0, 0, 15)
                rowTitle.Position = UDim2.new(0, 12, 0, desc and 7 or 10)
                rowTitle.BackgroundTransparency = 1
                rowTitle.Text = name
                rowTitle.Font = Enum.Font.GothamMedium
                rowTitle.TextSize = 12.5
                rowTitle.TextColor3 = THEME.TextPrimary
                rowTitle.TextXAlignment = Enum.TextXAlignment.Left
                rowTitle.Parent = row

                if desc then
                    local rowDesc = Instance.new("TextLabel")
                    rowDesc.Size = UDim2.new(0.48, 0, 0, 13)
                    rowDesc.Position = UDim2.new(0, 12, 0, 25)
                    rowDesc.BackgroundTransparency = 1
                    rowDesc.Text = desc
                    rowDesc.Font = Enum.Font.Gotham
                    rowDesc.TextSize = 9.5
                    rowDesc.TextColor3 = THEME.TextMuted
                    rowDesc.TextXAlignment = Enum.TextXAlignment.Left
                    rowDesc.Parent = row
                end

                local dropBtn = Instance.new("TextButton")
                dropBtn.Size = UDim2.new(0.48, 0, 0, 26)
                dropBtn.Position = UDim2.new(0.5, 0, 0.5, -13)
                dropBtn.BackgroundColor3 = THEME.BadgeBg
                dropBtn.Text = ""
                dropBtn.AutoButtonColor = false
                dropBtn.Parent = row

                local dc = Instance.new("UICorner")
                dc.CornerRadius = UDim.new(0, 5)
                dc.Parent = dropBtn

                local ds = Instance.new("UIStroke")
                ds.Color = THEME.Border
                ds.Thickness = 0.8
                ds.Parent = dropBtn

                local curLabel = Instance.new("TextLabel")
                curLabel.Size = UDim2.new(1, -24, 1, 0)
                curLabel.Position = UDim2.new(0, 8, 0, 0)
                curLabel.BackgroundTransparency = 1
                curLabel.Font = Enum.Font.Gotham
                curLabel.TextSize = 10.5
                curLabel.TextXAlignment = Enum.TextXAlignment.Left
                curLabel.TextTruncate = Enum.TextTruncate.AtEnd
                curLabel.Parent = dropBtn

                local function updateLabel()
                    local l = getList()
                    curLabel.Text = (#l == 0) and "None" or table.concat(l, ", ")
                    curLabel.TextColor3 = (#l == 0) and THEME.TextDim or THEME.TextPrimary
                end
                updateLabel()

                local arrow = Instance.new("ImageLabel")
                arrow.Size = UDim2.new(0, 10, 0, 10)
                arrow.Position = UDim2.new(1, -16, 0.5, -5)
                arrow.BackgroundTransparency = 1
                arrow.Image = ICONS.Chevron
                arrow.ImageColor3 = THEME.TextMuted
                arrow.Parent = dropBtn

                local popover = nil
                local popover = nil
                local outsideConn = nil
                local function closePop()
                    if outsideConn then outsideConn:Disconnect(); outsideConn = nil end
                    if popover then
                        popover:Destroy()
                        popover = nil
                    end
                end

                dropBtn.MouseButton1Click:Connect(function()
                    if popover then closePop(); return end

                    local absPos = dropBtn.AbsolutePosition
                    local absSize = dropBtn.AbsoluteSize
                    local mainPos = Main.AbsolutePosition

                    popover = Instance.new("Frame")
                    popover.Size = UDim2.new(0, absSize.X, 0, math.min(#options * 25 + 6, 135))
                    popover.Position = UDim2.new(0, absPos.X - mainPos.X, 0, absPos.Y - mainPos.Y + absSize.Y + 3)
                    popover.BackgroundColor3 = THEME.CardBg
                    popover.ZIndex = 500
                    popover.Parent = Main

                    local pc = Instance.new("UICorner")
                    pc.CornerRadius = UDim.new(0, 6)
                    pc.Parent = popover

                    local ps = Instance.new("UIStroke")
                    ps.Color = THEME.BorderActive
                    ps.Thickness = 1
                    ps.Parent = popover

                    local scroll = Instance.new("ScrollingFrame")
                    scroll.Size = UDim2.new(1, 0, 1, 0)
                    scroll.BackgroundTransparency = 1
                    scroll.ScrollBarThickness = 2
                    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                    scroll.ZIndex = 501
                    scroll.Parent = popover

                    local sList = Instance.new("UIListLayout")
                    sList.Padding = UDim.new(0, 1)
                    sList.Parent = scroll

                    for _, opt in ipairs(options) do
                        local isSel = selectedMap[opt] == true
                        local optBtn = Instance.new("TextButton")
                        optBtn.Size = UDim2.new(1, 0, 0, 24)
                        optBtn.BackgroundTransparency = 1
                        optBtn.Text = (isSel and " [x] " or " [ ] ") .. opt
                        optBtn.Font = Enum.Font.GothamMedium
                        optBtn.TextSize = 10.5
                        optBtn.TextColor3 = isSel and THEME.Accent or THEME.TextPrimary
                        optBtn.TextXAlignment = Enum.TextXAlignment.Left
                        optBtn.ZIndex = 502
                        optBtn.Parent = scroll

                        optBtn.MouseButton1Click:Connect(function()
                            selectedMap[opt] = not selectedMap[opt]
                            optBtn.Text = (selectedMap[opt] and " [x] " or " [ ] ") .. opt
                            optBtn.TextColor3 = selectedMap[opt] and THEME.Accent or THEME.TextPrimary
                            updateLabel()
                            local currentList = getList()
                            if flag then SonLibrary.Flags[flag] = currentList end
                            if callback then pcall(callback, currentList) end
                        end)
                    end

                    outsideConn = UserInputService.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            task.defer(function()
                                if popover then
                                    local pPos = popover.AbsolutePosition
                                    local pSize = popover.AbsoluteSize
                                    local mX, mY = inp.Position.X, inp.Position.Y
                                    local inP = (mX >= pPos.X and mX <= pPos.X + pSize.X and mY >= pPos.Y and mY <= pPos.Y + pSize.Y)
                                    local inB = (mX >= absPos.X and mX <= absPos.X + absSize.X and mY >= absPos.Y and mY <= absPos.Y + absSize.Y)
                                    if not inP and not inB then
                                        closePop()
                                    end
                                end
                            end)
                        end
                    end)
                end)

                local compObj = {
                    Set = function(_, list)
                        selectedMap = {}
                        for _, it in ipairs(list or {}) do selectedMap[it] = true end
                        updateLabel()
                        local currentList = getList()
                        if flag then SonLibrary.Flags[flag] = currentList end
                        if callback then pcall(callback, currentList) end
                    end,
                    Get = getList,
                }
                if flag then SonLibrary.Registry[flag] = compObj end
                return compObj
            end

            function SectionObj:CreateInput(opts: {
                Name: string,
                Description: string?,
                Placeholder: string?,
                Default: string?,
                Flag: string?,
                Callback: ((string, boolean) -> ())?
            })
                opts = opts or {}
                local name = opts.Name or "Input"
                local desc = opts.Description
                local placeholder = opts.Placeholder or "Type here..."
                local defaultText = opts.Default or ""
                local flag = opts.Flag
                local callback = opts.Callback

                if flag then SonLibrary.Flags[flag] = defaultText end

                local row = Instance.new("Frame")
                row.Name = name
                row.Size = UDim2.new(1, 0, 0, desc and 48 or 36)
                row.BackgroundColor3 = THEME.PillBg
                row.BorderSizePixel = 0
                row.Parent = BodyContainer

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local rs = Instance.new("UIStroke")
                rs.Color = THEME.Border
                rs.Thickness = 0.8
                rs.Parent = row

                table.insert(WindowObj.RegisteredRows, {Frame = row, Name = name:lower()})

                local rowTitle = Instance.new("TextLabel")
                rowTitle.Size = UDim2.new(0.48, 0, 0, 15)
                rowTitle.Position = UDim2.new(0, 12, 0, desc and 7 or 10)
                rowTitle.BackgroundTransparency = 1
                rowTitle.Text = name
                rowTitle.Font = Enum.Font.GothamMedium
                rowTitle.TextSize = 12.5
                rowTitle.TextColor3 = THEME.TextPrimary
                rowTitle.TextXAlignment = Enum.TextXAlignment.Left
                rowTitle.Parent = row

                if desc then
                    local rowDesc = Instance.new("TextLabel")
                    rowDesc.Size = UDim2.new(0.48, 0, 0, 13)
                    rowDesc.Position = UDim2.new(0, 12, 0, 25)
                    rowDesc.BackgroundTransparency = 1
                    rowDesc.Text = desc
                    rowDesc.Font = Enum.Font.Gotham
                    rowDesc.TextSize = 9.5
                    rowDesc.TextColor3 = THEME.TextMuted
                    rowDesc.TextXAlignment = Enum.TextXAlignment.Left
                    rowDesc.Parent = row
                end

                local boxHolder = Instance.new("Frame")
                boxHolder.Size = UDim2.new(0.48, 0, 0, 26)
                boxHolder.Position = UDim2.new(0.5, 0, 0.5, -13)
                boxHolder.BackgroundColor3 = THEME.BadgeBg
                boxHolder.BorderSizePixel = 0
                boxHolder.Parent = row

                local bc = Instance.new("UICorner")
                bc.CornerRadius = UDim.new(0, 5)
                bc.Parent = boxHolder

                local bs = Instance.new("UIStroke")
                bs.Color = THEME.Border
                bs.Thickness = 0.8
                bs.Parent = boxHolder

                local box = Instance.new("TextBox")
                box.Size = UDim2.new(1, -12, 1, 0)
                box.Position = UDim2.new(0, 6, 0, 0)
                box.BackgroundTransparency = 1
                box.PlaceholderText = placeholder
                box.PlaceholderColor3 = THEME.TextDim
                box.Text = defaultText
                box.TextColor3 = THEME.TextPrimary
                box.Font = Enum.Font.Gotham
                box.TextSize = 10.5
                box.TextXAlignment = Enum.TextXAlignment.Left
                box.ClearTextOnFocus = false
                box.Parent = boxHolder

                box.FocusLost:Connect(function(enter)
                    if flag then SonLibrary.Flags[flag] = box.Text end
                    if callback then pcall(callback, box.Text, enter) end
                end)

                local compObj = {
                    Set = function(_, val)
                        box.Text = tostring(val)
                        if flag then SonLibrary.Flags[flag] = box.Text end
                    end,
                    Get = function() return box.Text end,
                }
                if flag then SonLibrary.Registry[flag] = compObj end
                return compObj
            end

            function SectionObj:CreateKeybind(opts: {
                Name: string,
                Description: string?,
                Default: Enum.KeyCode?,
                Flag: string?,
                Callback: ((Enum.KeyCode) -> ())?
            })
                opts = opts or {}
                local name = opts.Name or "Keybind"
                local desc = opts.Description
                local currentKey = opts.Default or Enum.KeyCode.F
                local flag = opts.Flag
                local callback = opts.Callback

                if flag then SonLibrary.Flags[flag] = currentKey end

                local row = Instance.new("Frame")
                row.Name = name
                row.Size = UDim2.new(1, 0, 0, desc and 48 or 36)
                row.BackgroundColor3 = THEME.PillBg
                row.BorderSizePixel = 0
                row.Parent = BodyContainer

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local rs = Instance.new("UIStroke")
                rs.Color = THEME.Border
                rs.Thickness = 0.8
                rs.Parent = row

                table.insert(WindowObj.RegisteredRows, {Frame = row, Name = name:lower()})

                local rowTitle = Instance.new("TextLabel")
                rowTitle.Size = UDim2.new(1, -64, 0, 15)
                rowTitle.Position = UDim2.new(0, 12, 0, desc and 7 or 10)
                rowTitle.BackgroundTransparency = 1
                rowTitle.Text = name
                rowTitle.Font = Enum.Font.GothamMedium
                rowTitle.TextSize = 12.5
                rowTitle.TextColor3 = THEME.TextPrimary
                rowTitle.TextXAlignment = Enum.TextXAlignment.Left
                rowTitle.Parent = row

                if desc then
                    local rowDesc = Instance.new("TextLabel")
                    rowDesc.Size = UDim2.new(1, -64, 0, 13)
                    rowDesc.Position = UDim2.new(0, 12, 0, 25)
                    rowDesc.BackgroundTransparency = 1
                    rowDesc.Text = desc
                    rowDesc.Font = Enum.Font.Gotham
                    rowDesc.TextSize = 9.5
                    rowDesc.TextColor3 = THEME.TextMuted
                    rowDesc.TextXAlignment = Enum.TextXAlignment.Left
                    rowDesc.Parent = row
                end

                local badge = Instance.new("TextLabel")
                badge.Size = UDim2.new(0, 48, 0, 22)
                badge.Position = UDim2.new(1, -58, 0.5, -11)
                badge.BackgroundColor3 = THEME.BadgeBg
                badge.Text = currentKey.Name
                badge.Font = Enum.Font.GothamBold
                badge.TextSize = 10
                badge.TextColor3 = THEME.TextMuted
                badge.Parent = row

                local bc = Instance.new("UICorner")
                bc.CornerRadius = UDim.new(0, 4)
                bc.Parent = badge

                local bs = Instance.new("UIStroke")
                bs.Color = THEME.Border
                bs.Thickness = 0.8
                bs.Parent = badge

                local clickBtn = Instance.new("TextButton")
                clickBtn.Size = UDim2.new(1, 0, 1, 0)
                clickBtn.BackgroundTransparency = 1
                clickBtn.Text = ""
                clickBtn.Parent = badge

                clickBtn.MouseButton1Click:Connect(function()
                    openKeybindModal(badge, function(newKey)
                        currentKey = newKey
                        if flag then SonLibrary.Flags[flag] = currentKey end
                        if callback then pcall(callback, currentKey) end
                    end)
                end)

                local compObj = {
                    Set = function(_, k)
                        currentKey = k
                        if flag then SonLibrary.Flags[flag] = currentKey end
                        badge.Text = currentKey.Name
                    end,
                    Get = function() return currentKey end,
                }
                if flag then SonLibrary.Registry[flag] = compObj end
                return compObj
            end

            function SectionObj:CreateColorPicker(opts: {
                Name: string,
                Description: string?,
                Default: Color3?,
                Flag: string?,
                Callback: ((Color3) -> ())?
            })
                opts = opts or {}
                local name = opts.Name or "Color Picker"
                local desc = opts.Description
                local curColor = opts.Default or THEME.Accent
                local flag = opts.Flag
                local callback = opts.Callback

                if flag then SonLibrary.Flags[flag] = curColor end

                local row = Instance.new("Frame")
                row.Name = name
                row.Size = UDim2.new(1, 0, 0, desc and 48 or 36)
                row.BackgroundColor3 = THEME.PillBg
                row.BorderSizePixel = 0
                row.Parent = BodyContainer

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local rs = Instance.new("UIStroke")
                rs.Color = THEME.Border
                rs.Thickness = 0.8
                rs.Parent = row

                table.insert(WindowObj.RegisteredRows, {Frame = row, Name = name:lower()})

                local rowTitle = Instance.new("TextLabel")
                rowTitle.Size = UDim2.new(1, -54, 0, 15)
                rowTitle.Position = UDim2.new(0, 12, 0, desc and 7 or 10)
                rowTitle.BackgroundTransparency = 1
                rowTitle.Text = name
                rowTitle.Font = Enum.Font.GothamMedium
                rowTitle.TextSize = 12.5
                rowTitle.TextColor3 = THEME.TextPrimary
                rowTitle.TextXAlignment = Enum.TextXAlignment.Left
                rowTitle.Parent = row

                if desc then
                    local rowDesc = Instance.new("TextLabel")
                    rowDesc.Size = UDim2.new(1, -54, 0, 13)
                    rowDesc.Position = UDim2.new(0, 12, 0, 25)
                    rowDesc.BackgroundTransparency = 1
                    rowDesc.Text = desc
                    rowDesc.Font = Enum.Font.Gotham
                    rowDesc.TextSize = 9.5
                    rowDesc.TextColor3 = THEME.TextMuted
                    rowDesc.TextXAlignment = Enum.TextXAlignment.Left
                    rowDesc.Parent = row
                end

                local preview = Instance.new("TextButton")
                preview.Size = UDim2.new(0, 32, 0, 20)
                preview.Position = UDim2.new(1, -44, 0.5, -10)
                preview.BackgroundColor3 = curColor
                preview.Text = ""
                preview.AutoButtonColor = false
                preview.Parent = row

                local pc = Instance.new("UICorner")
                pc.CornerRadius = UDim.new(0, 4)
                pc.Parent = preview

                local ps = Instance.new("UIStroke")
                ps.Color = THEME.Border
                ps.Thickness = 0.8
                ps.Parent = preview

                local pal = {
                    Color3.fromRGB(246, 92, 82),
                    Color3.fromRGB(0, 166, 255),
                    Color3.fromRGB(46, 204, 113),
                    Color3.fromRGB(241, 196, 15),
                    Color3.fromRGB(155, 89, 182),
                    Color3.fromRGB(255, 255, 255),
                }
                local pIdx = 1

                preview.MouseButton1Click:Connect(function()
                    pIdx = (pIdx % #pal) + 1
                    curColor = pal[pIdx]
                    if flag then SonLibrary.Flags[flag] = curColor end
                    preview.BackgroundColor3 = curColor
                    if callback then pcall(callback, curColor) end
                end)

                local compObj = {
                    Set = function(_, col)
                        curColor = col
                        if flag then SonLibrary.Flags[flag] = curColor end
                        preview.BackgroundColor3 = curColor
                    end,
                    Get = function() return curColor end,
                }
                if flag then SonLibrary.Registry[flag] = compObj end
                return compObj
            end

            function SectionObj:CreateProgress(opts: {
                Name: string,
                Description: string?,
                Default: number?,
            })
                opts = opts or {}
                local name = opts.Name or "Progress"
                local desc = opts.Description
                local pct = math.clamp(opts.Default or 0, 0, 100)

                local row = Instance.new("Frame")
                row.Name = name
                row.Size = UDim2.new(1, 0, 0, desc and 58 or 46)
                row.BackgroundColor3 = THEME.PillBg
                row.BorderSizePixel = 0
                row.Parent = BodyContainer

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local rs = Instance.new("UIStroke")
                rs.Color = THEME.Border
                rs.Thickness = 0.8
                rs.Parent = row

                table.insert(WindowObj.RegisteredRows, {Frame = row, Name = string.lower(name)})

                local rowTitle = Instance.new("TextLabel")
                rowTitle.Size = UDim2.new(1, -70, 0, 15)
                rowTitle.Position = UDim2.new(0, 12, 0, 7)
                rowTitle.BackgroundTransparency = 1
                rowTitle.Text = name
                rowTitle.Font = Enum.Font.GothamMedium
                rowTitle.TextSize = 12.5
                rowTitle.TextColor3 = THEME.TextPrimary
                rowTitle.TextXAlignment = Enum.TextXAlignment.Left
                rowTitle.Parent = row

                local valLabel = Instance.new("TextLabel")
                valLabel.Size = UDim2.new(0, 60, 0, 15)
                valLabel.Position = UDim2.new(1, -72, 0, 7)
                valLabel.BackgroundTransparency = 1
                valLabel.Text = tostring(math.floor(pct)) .. "%"
                valLabel.Font = Enum.Font.GothamBold
                valLabel.TextSize = 11.5
                valLabel.TextColor3 = THEME.Accent
                valLabel.TextXAlignment = Enum.TextXAlignment.Right
                valLabel.Parent = row

                if desc then
                    local rowDesc = Instance.new("TextLabel")
                    rowDesc.Size = UDim2.new(1, -24, 0, 13)
                    rowDesc.Position = UDim2.new(0, 12, 0, 23)
                    rowDesc.BackgroundTransparency = 1
                    rowDesc.Text = desc
                    rowDesc.Font = Enum.Font.Gotham
                    rowDesc.TextSize = 9.5
                    rowDesc.TextColor3 = THEME.TextMuted
                    rowDesc.TextXAlignment = Enum.TextXAlignment.Left
                    rowDesc.Parent = row
                end

                local trackPos = desc and 40 or 29
                local track = Instance.new("Frame")
                track.Size = UDim2.new(1, -24, 0, 6)
                track.Position = UDim2.new(0, 12, 0, trackPos)
                track.BackgroundColor3 = THEME.ToggleOff
                track.BorderSizePixel = 0
                track.Parent = row

                local tc = Instance.new("UICorner")
                tc.CornerRadius = UDim.new(1, 0)
                tc.Parent = track

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(pct / 100, 0, 1, 0)
                fill.BackgroundColor3 = THEME.Accent
                fill.BorderSizePixel = 0
                fill.Parent = track

                local fc = Instance.new("UICorner")
                fc.CornerRadius = UDim.new(1, 0)
                fc.Parent = fill

                return {
                    Set = function(_, newPct)
                        pct = math.clamp(newPct or 0, 0, 100)
                        valLabel.Text = tostring(math.floor(pct)) .. "%"
                        TweenService:Create(fill, TWEEN_FAST, {Size = UDim2.new(pct / 100, 0, 1, 0)}):Play()
                    end,
                    Get = function() return pct end,
                }
            end

            function SectionObj:CreateParagraph(opts: {
                Title: string,
                Content: string,
                Copyable: boolean?,
            })
                opts = opts or {}
                local ptitle = opts.Title or "Notice"
                local content = opts.Content or ""
                local isCopyable = (opts.Copyable == true)

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 0)
                row.AutomaticSize = Enum.AutomaticSize.Y
                row.BackgroundColor3 = THEME.PillBg
                row.BorderSizePixel = 0
                row.Parent = BodyContainer

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local rs = Instance.new("UIStroke")
                rs.Color = THEME.Border
                rs.Thickness = 0.8
                rs.Parent = row

                local rPad = Instance.new("UIPadding")
                rPad.PaddingTop = UDim.new(0, 10)
                rPad.PaddingBottom = UDim.new(0, 10)
                rPad.PaddingLeft = UDim.new(0, 12)
                rPad.PaddingRight = UDim.new(0, 12)
                rPad.Parent = row

                local pTitle = Instance.new("TextLabel")
                pTitle.Size = UDim2.new(1, isCopyable and -24 or 0, 0, 16)
                pTitle.BackgroundTransparency = 1
                pTitle.Text = ptitle
                pTitle.Font = Enum.Font.GothamBold
                pTitle.TextSize = 12
                pTitle.TextColor3 = THEME.TextPrimary
                pTitle.TextXAlignment = Enum.TextXAlignment.Left
                pTitle.Parent = row

                local pDesc = Instance.new("TextLabel")
                pDesc.Size = UDim2.new(1, isCopyable and -24 or 0, 0, 0)
                pDesc.Position = UDim2.new(0, 0, 0, 18)
                pDesc.AutomaticSize = Enum.AutomaticSize.Y
                pDesc.BackgroundTransparency = 1
                pDesc.Text = content
                pDesc.Font = Enum.Font.Gotham
                pDesc.TextSize = 10
                pDesc.TextColor3 = THEME.TextMuted
                pDesc.TextWrapped = true
                pDesc.TextXAlignment = Enum.TextXAlignment.Left
                pDesc.Parent = row

                if isCopyable then
                    local copyBtn = Instance.new("ImageButton")
                    copyBtn.Size = UDim2.new(0, 14, 0, 14)
                    copyBtn.Position = UDim2.new(1, -14, 0, 1)
                    copyBtn.BackgroundTransparency = 1
                    copyBtn.Image = ICONS.Accounts
                    copyBtn.ImageColor3 = THEME.TextMuted
                    copyBtn.Parent = row

                    copyBtn.MouseButton1Click:Connect(function()
                        setclipboardFn(pDesc.Text)
                        SonLibrary:Notify({Title = "Copied", Content = "Copied to clipboard!"})
                    end)
                end

                return {
                    Set = function(_, nT, nC)
                        pTitle.Text = nT or pTitle.Text
                        pDesc.Text = nC or pDesc.Text
                    end
                }
            end

            function SectionObj:CreateDivider()
                local div = Instance.new("Frame")
                div.Size = UDim2.new(1, 0, 0, 1)
                div.BackgroundColor3 = THEME.Divider
                div.BorderSizePixel = 0
                div.Parent = BodyContainer
            end

            function SectionObj:BuildConfigSection()
                local configNameInput = "default"
                local configDropdown

                SectionObj:CreateInput({
                    Name = "Config Name",
                    Placeholder = "Enter name...",
                    Default = "default",
                    Callback = function(val)
                        if val and #val > 0 then configNameInput = val end
                    end
                })

                configDropdown = SectionObj:CreateDropdown({
                    Name = "Select Config",
                    Options = SonLibrary:GetConfigs(),
                    Default = "default",
                    Callback = function(val)
                        configNameInput = val
                    end
                })

                SectionObj:CreateButton({
                    Name = "Save Config",
                    Description = "Save current flags to json",
                    Callback = function()
                        SonLibrary:SaveConfig(configNameInput)
                        configDropdown:Refresh(SonLibrary:GetConfigs())
                    end
                })

                SectionObj:CreateButton({
                    Name = "Load Config",
                    Description = "Restore flags from json",
                    Callback = function()
                        SonLibrary:LoadConfig(configNameInput)
                    end
                })

                SectionObj:CreateButton({
                    Name = "Delete Config",
                    Description = "Remove selected json file",
                    Callback = function()
                        SonLibrary:DeleteConfig(configNameInput)
                        configDropdown:Refresh(SonLibrary:GetConfigs())
                    end
                })
            end

            return SectionObj
        end

        TabObj.CreateCard = TabObj.CreateSection
        return TabObj
    end

    table.insert(SonLibrary.ActiveWindows, WindowObj)
    return WindowObj
end

if _G then _G.SonLibrary = SonLibrary end
if typeof(getgenv) == "function" then pcall(function() getgenv().SonLibrary = SonLibrary end) end

return SonLibrary
