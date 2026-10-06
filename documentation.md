# WMacLib Documentation


## Setup

```lua
local SonLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/hongson209/sonlibrary/refs/heads/main/sonlibrary.lua"))()
```

---

## Window

```lua
local Window = WMacLib:Window({
    Title = "My Script",
    Subtitle = "subtitle text",
    Size = UDim2.fromOffset(868, 650),
    AcrylicBlur = true,
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightControl,
    Theme = "Dark",  -- "Dark" | "Light" | "Midnight"
    DisabledWindowControls = {},  -- {"Exit"} | {"Minimize"}
})
```

**Methods:**

```lua
Window:SetState(bool)           -- show / hide window
Window:GetState()               -- returns bool
Window:SetSize(UDim2)
Window:SetScale(number)
Window:SetKeybind(Enum.KeyCode)
Window:SetTitle(text)
Window:SetSubtitle(text)
Window:SetUserInfoState(bool)   -- true | false | "redact"
Window:SetAcrylicBlurState(bool)
Window:GetAcrylicBlurState()
Window:SetNotificationsState(bool)
Window:Unload()
Window.onUnloaded(function() end)
```

---

## Tab

```lua
local tab = Window:Tab({
    Name = "Main",
    Icon = "category/icon",  -- optional
})

tab:Select()
tab:SetName("New Name")
tab:SetVisibility(bool)
tab:Destroy()
tab:InsertConfigSection()  -- adds save/load config UI to this tab
```

---

## Section

```lua
local section = tab:Section({
    Side = "Left",   -- "Left" | "Right"
})

section:SetVisible(bool)
section:Destroy()
```

---

## Button

```lua
section:Button({
    Name = "Click Me",
    Bold = false,
    Callback = function() end,
}, "FlagName")
```

**Methods:**

```lua
button:SetName(text)
button:SetVisibility(bool)
button:Lock()
button:Unlock()
button:Destroy()
```

---

## Toggle

```lua
local toggle = section:Toggle({
    Name = "Enable",
    Default = false,
    Bold = false,
    Callback = function(value) end,
}, "FlagName")
```

**Methods:**

```lua
toggle:Toggle()
toggle:UpdateState(bool)
toggle:GetState()             -- returns bool
toggle:SetName(text)
toggle:SetVisibility(bool)
toggle:Lock()
toggle:Unlock()
toggle:Destroy()
```

---

## Slider

```lua
local slider = section:Slider({
    Name = "Speed",
    Default = 50,
    Minimum = 0,
    Maximum = 100,
    Precision = 0,
    DisplayMethod = "Value",  -- "Value" | "Percent" | "Round" | "Tenths" | "Hundredths" | "Degrees"
    Prefix = "",
    Suffix = "",
    Callback = function(value) end,
    onInputComplete = function(value) end,
}, "FlagName")
```

**Methods:**

```lua
slider:UpdateValue(number)
slider:GetValue()
slider:SetName(text)
slider:SetVisibility(bool)
slider:Lock()
slider:Unlock()
slider:Destroy()
```

---

## Input

```lua
local input = section:Input({
    Name = "Label",
    Default = "",
    Placeholder = "type here...",
    AcceptedCharacters = "All",  -- "All" | "Numeric" | "Alphabetic" | "AlphaNumeric" | function
    CharacterLimit = 50,         -- optional
    Bold = false,
    Callback = function(text) end,
    onChanged = function(text) end,
}, "FlagName")
```

**Methods:**

```lua
input:GetInput()
input:UpdateText(text)
input:UpdatePlaceholder(text)
input:SetName(text)
input:SetVisibility(bool)
input:Lock()
input:Unlock()
input:Destroy()
```

---

## Keybind

```lua
local keybind = section:Keybind({
    Name = "Toggle ESP",
    Default = Enum.KeyCode.E,   -- optional
    Blacklist = false,
    Callback = function(key) end,
    onBinded = function(key) end,
    onBindHeld = function(held, key) end,
}, "FlagName")
```

**Methods:**

```lua
keybind:Bind(Enum.KeyCode.X)
keybind:Unbind()
keybind:GetBind()
keybind:SetName(text)
keybind:SetVisibility(bool)
keybind:Lock()
keybind:Unlock()
keybind:Destroy()
```

---

## Dropdown

```lua
local dropdown = section:Dropdown({
    Name = "Select",
    Options = {"Option A", "Option B"},
    Default = 1,           -- index or value
    Multi = false,
    Required = true,
    Search = false,
    Callback = function(value) end,
}, "FlagName")
```

Multi dropdown callback receives a table `{["Option"] = true/false}`.

**Methods:**

```lua
dropdown:UpdateSelection("Option A")          -- single
dropdown:UpdateSelection({"A", "B"})          -- multi
dropdown:ClearOptions()
dropdown:InsertOptions({"New 1", "New 2"})
dropdown:SetName(text)
dropdown:SetVisibility(bool)
dropdown:Lock()
dropdown:Unlock()
dropdown:Destroy()
```

---

## Colorpicker

```lua
local picker = section:Colorpicker({
    Name = "Color",
    Default = Color3.fromRGB(255, 0, 0),
    Alpha = 0,         -- set to enable transparency (0-1)
    Callback = function(color, alpha) end,
}, "FlagName")
```

**Methods:**

```lua
picker:SetColor(Color3)
picker:SetAlpha(number)
picker:SetName(text)
picker:SetVisibility(bool)
picker:Lock()
picker:Unlock()
picker:Destroy()
```

---

## Label

```lua
local label = section:Label({
    Text = "Hello",
    Bold = false,
}, "FlagName")
```

**Methods:**

```lua
label:SetName(text)
label:SetVisibility(bool)
label:Destroy()
```

---

## SubLabel

```lua
section:SubLabel({
    Text = "small gray text",
    Bold = false,
})
```

**Methods:** `SetName`, `SetVisibility`, `Destroy`

---

## Header

```lua
section:Header({
    Text = "Section Title",
})
```

**Methods:** `SetName`, `SetVisibility`, `Destroy`

---

## Paragraph

```lua
section:Paragraph({
    Header = "Title",
    Body = "Body text here.",
    Bold = false,
})
```

**Methods:**

```lua
paragraph:UpdateHeader(text)
paragraph:UpdateBody(text)
paragraph:SetVisibility(bool)
paragraph:Destroy()
```

---

## Divider

```lua
section:Divider()
```

**Methods:** `SetVisibility`, `Destroy`

---

## Spacer

```lua
section:Spacer()
```

**Methods:** `SetVisibility`, `Destroy`

---

## GlobalSetting

A toggle shown in the window header area, not inside tabs.

```lua
Window:GlobalSetting({
    Name = "Notifications",
    Default = true,
    Callback = function(bool) end,
})
```

---

## Watermark

```lua
local watermark = WMacLib:Watermark({
    Name = "My Script",
    Version = "v1.0.0",
})
```

**Methods:**

```lua
watermark:Set("FPS", "120 fps")   -- add or update a stat label
watermark:SetVisible(bool)
watermark:Destroy()
```

---

## Notify

```lua
Window:Notify({
    Title = "Alert",
    Description = "Something happened.",
    Lifetime = 3,   -- seconds, default 5
})
```

---

## Dialog

```lua
Window:Dialog({
    Title = "Confirm",
    Description = "Are you sure?",
    Buttons = {
        {
            Name = "Yes",
            Callback = function() end,
        },
        {
            Name = "No",
        },
    },
})
```

---

## Themes

Built-in themes: `"Dark"`, `"Light"`, `"Midnight"`

**Create a custom theme:**

```lua
WMacLib:AddTheme({
    Name = "MyTheme",
    Accent      = Color3.fromRGB(24, 24, 27),
    Background  = Color3.fromRGB(15, 15, 15),
    Surface     = Color3.fromRGB(255, 255, 255),
    Outline     = Color3.fromRGB(255, 255, 255),
    Text        = Color3.fromRGB(255, 255, 255),
    Placeholder = Color3.fromRGB(122, 122, 122),
    Button      = Color3.fromRGB(87, 86, 86),
    Icon        = Color3.fromRGB(180, 180, 180),
})
```

**Switch theme:**

```lua
WMacLib:SetTheme("MyTheme")
WMacLib:GetThemes()   -- returns list of theme names
```

---

## Configs

```lua
WMacLib:SetFolder("FolderName")     -- set save folder, default "Maclib"
WMacLib:SaveConfig("config name")
WMacLib:LoadConfig("config name")
WMacLib:RefreshConfigList()         -- returns list of saved config names
WMacLib:LoadAutoLoadConfig()        -- loads config marked as autoload
```

Add a config UI automatically with:

```lua
tab:InsertConfigSection()
```

---

## Utilities

**Gradient text (RichText):**

```lua
local text = WMacLib:Gradient("Hello", Color3.fromRGB(255,0,0), Color3.fromRGB(0,0,255))
-- or multiple colors:
local text = WMacLib:Gradient("Hello", {Color3.fromRGB(...), Color3.fromRGB(...), Color3.fromRGB(...)})
```

**Flag access:**

Any element created with a Flag can be accessed globally:

```lua
WMacLib.Options["FlagName"]:UpdateState(true)
WMacLib.Options["FlagName"]:GetValue()
```
