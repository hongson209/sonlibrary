local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CoreGui = game:GetService("CoreGui")
pcall(function()
    local safeP = (typeof(gethui) == "function" and gethui()) or CoreGui
    if safeP:FindFirstChild("PastaCompleteUI") then
        safeP.PastaCompleteUI:Destroy()
    end
end)

local SonLibrary = (function()
    local localPaths = {
        "Library/sonlibrary.lua",
        "sonlibrary.lua",
        "SonHUB/Library/sonlibrary.lua",
    }
    for _, path in ipairs(localPaths) do
        if typeof(isfile) == "function" and isfile(path) and typeof(readfile) == "function" then
            local ok, res = pcall(function() return loadstring(readfile(path))() end)
            if ok and res and typeof(res.CreateWindow) == "function" then
                return res
            end
        end
    end

    local remoteUrl = "https://raw.githubusercontent.com/hongson209/sonlibrary/refs/heads/main/sonlibrary.lua?t=" .. tostring(tick())
    local s, content = pcall(function() return game:HttpGet(remoteUrl) end)
    if s and content and #content > 500 then
        local ok, res = pcall(function() return loadstring(content)() end)
        if ok and res and typeof(res.CreateWindow) == "function" then
            return res
        end
    end

    if _G.SonLibrary and typeof(_G.SonLibrary.CreateWindow) == "function" then
        return _G.SonLibrary
    end
    if typeof(getgenv) == "function" and getgenv().SonLibrary and typeof(getgenv().SonLibrary.CreateWindow) == "function" then
        return getgenv().SonLibrary
    end

    error("[SonHUB] Failed to initialize SonLibrary!")
end)()

local Window = SonLibrary:CreateWindow({
    Title = "SonHUB",
    SubTitle = "Premium Edition",
    AccentColor = Color3.fromRGB(246, 92, 82),
    ToggleKey = Enum.KeyCode.RightShift,
    Watermark = true,
    DefaultColumns = 2,
    DefaultTab = "Combat",
    Footer = {
        Title = string.lower(LocalPlayer.Name),
        Subtitle = "SonHUB Edition"
    }
})

Window:CreateCategory("FEATURES")

local CombatTab = Window:CreateTab({
    Title = "Combat",
    Icon = "rbxassetid://7734053426",
    Columns = 2
})

local cardFighting = CombatTab:CreateSection("Fighting", 1)
cardFighting:CreateToggle({
    Name = "Attack Aura",
    Default = false,
    Flag = "AttackAura",
    Callback = function(val)
        print("Attack Aura:", val)
    end
})

cardFighting:CreateToggle({
    Name = "No Velocity",
    Default = false,
    Flag = "NoVelocity",
    Callback = function(val)
        print("No Velocity:", val)
    end
})

cardFighting:CreateToggle({
    Name = "Trigger Bot",
    Default = false,
    Flag = "TriggerBot",
    Callback = function(val)
        print("Trigger Bot:", val)
    end
})

cardFighting:CreateToggle({
    Name = "Aim Assist",
    Default = false,
    Keybind = "F1",
    Flag = "AimAssist",
    Callback = function(val)
        print("Aim Assist:", val)
    end
})

cardFighting:CreateToggle({
    Name = "Auto Explosion",
    Default = false,
    Flag = "AutoExplosion",
    Callback = function(val)
        print("Auto Explosion:", val)
    end
})

local cardBase = CombatTab:CreateSection("Base", 1)
cardBase:CreateToggle({
    Name = "Auto Swap",
    Default = true,
    Flag = "AutoSwap",
    Callback = function(val)
        print("Auto Swap:", val)
    end
})

cardBase:CreateToggle({
    Name = "Item Release",
    Default = false,
    Flag = "ItemRelease",
    Callback = function(val)
        print("Item Release:", val)
    end
})

local cardTools = CombatTab:CreateSection("Tools", 2)
cardTools:CreateToggle({
    Name = "Sprint Reset",
    Default = false,
    Flag = "SprintReset",
    Callback = function(val)
        print("Sprint Reset:", val)
    end
})

cardTools:CreateToggle({
    Name = "Tape Mouse",
    Default = false,
    Flag = "TapeMouse",
    Callback = function(val)
        print("Tape Mouse:", val)
    end
})

cardTools:CreateToggle({
    Name = "Aim Assist",
    Description = "Helps to Focus on Entities",
    Default = false,
    Flag = "AimAssistTool",
    Callback = function(val)
        print("Aim Assist Tool:", val)
    end
})

cardTools:CreateToggle({
    Name = "Web Trap",
    Default = false,
    Flag = "WebTrap",
    Callback = function(val)
        print("Web Trap:", val)
    end
})

local cardOther = CombatTab:CreateSection("Other", 2)
cardOther:CreateToggle({
    Name = "No Slot Change",
    Default = false,
    Flag = "NoSlotChange",
    Callback = function(val)
        print("No Slot Change:", val)
    end
})

cardOther:CreateToggle({
    Name = "Anti Bot",
    Default = false,
    Flag = "AntiBot",
    Callback = function(val)
        print("Anti Bot:", val)
    end
})

cardOther:CreateToggle({
    Name = "No Friend Damage",
    Default = true,
    Flag = "NoFriendDamage",
    Callback = function(val)
        print("No Friend Damage:", val)
    end
})

local MovementTab = Window:CreateTab({
    Title = "Movement",
    Icon = "rbxassetid://7733799901",
    Columns = 2
})

local cardMovement = MovementTab:CreateSection("Locomotion", 1)
cardMovement:CreateSlider({
    Name = "WalkSpeed",
    Description = "Adjust character movement velocity",
    Min = 16,
    Max = 150,
    Default = 16,
    Suffix = " studs/s",
    Increment = 1,
    Flag = "WalkSpeed",
    Callback = function(v)
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end
})

cardMovement:CreateSlider({
    Name = "JumpPower",
    Description = "Vertical impulse strength",
    Min = 50,
    Max = 350,
    Default = 50,
    Suffix = " power",
    Increment = 5,
    Flag = "JumpPower",
    Callback = function(v)
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").JumpPower = v
        end
    end
})

cardMovement:CreateDropdown({
    Name = "Movement Mode",
    Description = "Select physics override method",
    Options = {"Default", "Bhop", "Flight", "Spider"},
    Default = "Default",
    Flag = "MovementMode",
    Callback = function(selected)
        print("Movement Mode:", selected)
    end
})

local cardPhysics = MovementTab:CreateSection("Physics Tweaks", 2)
cardPhysics:CreateToggle({
    Name = "Infinite Jump",
    Description = "Jump continuously mid-air",
    Default = false,
    Flag = "InfiniteJump",
    Callback = function(v)
        print("Infinite Jump:", v)
    end
})

cardPhysics:CreateToggle({
    Name = "Noclip",
    Description = "Walk through solid barriers",
    Default = false,
    Flag = "Noclip",
    Callback = function(v)
        print("Noclip:", v)
    end
})

cardPhysics:CreateButton({
    Name = "Reset Defaults",
    Description = "Restore default character physics",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            char:FindFirstChildOfClass("Humanoid").JumpPower = 50
        end
        SonLibrary:Notify({
            Title = "Movement",
            Content = "Physics reset to default values",
            Duration = 2
        })
    end
})

local VisualsTab = Window:CreateTab({
    Title = "Visuals",
    Icon = "rbxassetid://7733774602",
    Columns = 2
})

local espCard = VisualsTab:CreateSection("ESP Settings", 1)
espCard:CreateToggle({
    Name = "Player ESP",
    Description = "Render highlights around players",
    Default = false,
    Flag = "PlayerESP",
    Callback = function(v)
        print("Player ESP:", v)
    end
})

espCard:CreateColorPicker({
    Name = "Highlight Color",
    Description = "Target outline accent color",
    Default = Color3.fromRGB(246, 92, 82),
    Flag = "ESPColor",
    Callback = function(col)
        print("ESP Color:", col)
    end
})

espCard:CreateMultiDropdown({
    Name = "ESP Overlays",
    Description = "Additional rendering info tags",
    Options = {"Box", "Names", "Tracers", "Health Bar", "Distance"},
    Default = {"Box", "Names"},
    Flag = "ESPOverlays",
    Callback = function(list)
        print("ESP Overlays:", table.concat(list, ", "))
    end
})

local worldCard = VisualsTab:CreateSection("World & Ambience", 2)
worldCard:CreateSlider({
    Name = "Field of View",
    Min = 60,
    Max = 120,
    Default = 70,
    Increment = 1,
    Flag = "CameraFOV",
    Callback = function(v)
        if workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = v
        end
    end
})

worldCard:CreateToggle({
    Name = "Fullbright",
    Description = "Eliminate world shadows and fog",
    Default = false,
    Flag = "Fullbright",
    Callback = function(v)
        local lighting = game:GetService("Lighting")
        lighting.Brightness = v and 2 or 1
        lighting.ClockTime = v and 14 or 12
    end
})

local PlayerTab = Window:CreateTab({
    Title = "Player",
    Icon = "rbxassetid://7733954760",
    Columns = 2
})

local charCard = PlayerTab:CreateSection("Character", 1)
charCard:CreateToggle({
    Name = "God Mode (Desync)",
    Default = false,
    Flag = "GodMode",
    Callback = function(v)
        print("God Mode:", v)
    end
})

charCard:CreateKeybind({
    Name = "Quick Teleport Key",
    Description = "Press bound key to warp forward",
    Default = Enum.KeyCode.E,
    Flag = "QuickTPKey",
    Callback = function(key)
        print("Bound key:", key.Name)
    end
})

local infoCard = PlayerTab:CreateSection("Clipboard & Tags", 2)
infoCard:CreateInput({
    Name = "Custom Tag",
    Description = "Displayed on watermark HUD",
    Placeholder = "Enter custom tag...",
    Default = "",
    Flag = "CustomTag",
    Callback = function(text, enter)
        if enter then
            SonLibrary:Notify({
                Title = "Tag Updated",
                Content = "Custom tag set to: " .. text,
                Duration = 2
            })
        end
    end
})

infoCard:CreateButton({
    Name = "Copy Position",
    Description = "Copy Vector3 coordinates to clipboard",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            local str = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
            if setclipboard then setclipboard(str) end
            SonLibrary:Notify({
                Title = "Clipboard",
                Content = "Copied: " .. str,
                Duration = 2
            })
        end
    end
})

local MiscTab = Window:CreateTab({
    Title = "Misc",
    Icon = "rbxassetid://7734056411",
    Columns = 2
})

local layoutCard = MiscTab:CreateSection("UI & Controls", 1)
layoutCard:CreateToggle({
    Name = "Single Column Mode",
    Description = "Shrink width by 30% and expand components",
    Default = false,
    Callback = function(val)
        Window:SetColumns(val and 1 or 2)
    end
})

layoutCard:CreateToggle({
    Name = "Smooth Animations",
    Description = "Enable or disable tween animations (disable for low-end)",
    Default = true,
    Callback = function(val)
        SonLibrary:SetAnimations(val)
    end
})

layoutCard:CreateButton({
    Name = "Toggle Full Zoom",
    Description = "Expand UI to prominent 960x600 canvas",
    Callback = function()
        Window:ToggleZoom()
    end
})

layoutCard:CreateColorPicker({
    Name = "Theme Accent",
    Description = "Live update library accent theme",
    Default = Color3.fromRGB(246, 92, 82),
    Callback = function(color)
        Window:SetTheme(color)
    end
})

local utilCard = MiscTab:CreateSection("System & Info", 2)
utilCard:CreateParagraph({
    Title = "SonHUB Framework",
    Content = "Production-ready Luau library with 1-column / 2-column switcher, native touch dragging, global flags, and JSON config persistence.",
    Copyable = true
})

utilCard:CreateProgress({
    Name = "Client Memory",
    Description = "Estimated client memory usage",
    Default = 42
})

utilCard:CreateButton({
    Name = "Open Confirm Dialog",
    Description = "Show modal confirmation dialog",
    Callback = function()
        Window:CreateDialog({
            Title = "Confirm Action",
            Content = "Are you sure you want to trigger this test routine?",
            Buttons = {
                {
                    Title = "Confirm",
                    Style = "Primary",
                    Callback = function()
                        SonLibrary:Notify({
                            Title = "Executed",
                            Content = "Action completed successfully!",
                            Duration = 2
                        })
                    end
                },
                {
                    Title = "Cancel",
                    Style = "Danger"
                }
            }
        })
    end
})

Window:CreateCategory("MANAGER")

local PresetsTab = Window:CreateTab({
    Title = "Presets",
    Icon = "rbxassetid://7733964719",
    Columns = 2
})

PresetsTab:BuildConfigSection(1)

local manageCard = PresetsTab:CreateSection("Cloud & Backup", 2)
manageCard:CreateButton({
    Name = "Export All Flags",
    Description = "Dump all stored flags to console",
    Callback = function()
        print("=== SONHUB FLAGS DUMP ===")
        for flag, val in pairs(SonLibrary.Flags) do
            print(string.format("[%s] = %s", tostring(flag), tostring(val)))
        end
        SonLibrary:Notify({
            Title = "Flags Exported",
            Content = "All flags dumped to console (F9)",
            Duration = 2
        })
    end
})

manageCard:CreateButton({
    Name = "Unload UI",
    Description = "Completely remove SonLibrary from CoreGui",
    Callback = function()
        SonLibrary:Unload()
    end
})

SonLibrary:Notify({
    Title = "SonHUB",
    Content = "Loaded successfully! RightShift or use Floating Button to toggle.",
    Duration = 3
})
