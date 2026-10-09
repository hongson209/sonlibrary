local SonLibrary = (function()
    if _G.SonLibrary and _G.SonLibrary.CreateWindow then
        return _G.SonLibrary
    end
    if typeof(getgenv) == "function" and getgenv().SonLibrary and getgenv().SonLibrary.CreateWindow then
        return getgenv().SonLibrary
    end

    local localFiles = {
        "Library/sonlibrary.lua",
        "sonlibrary.lua",
        "SonHUB/Library/sonlibrary.lua",
    }
    for _, path in ipairs(localFiles) do
        if typeof(isfile) == "function" and isfile(path) and typeof(readfile) == "function" then
            local ok, lib = pcall(function() return loadstring(readfile(path))() end)
            if ok and lib and typeof(lib.CreateWindow) == "function" then
                return lib
            end
        end
    end

    local githubUrl = "https://raw.githubusercontent.com/hongson209/sonlibrary/refs/heads/main/sonlibrary.lua"
    local ok, res = pcall(function() return game:HttpGet(githubUrl) end)
    if ok and res and #res > 500 then
        local lOk, lib = pcall(function() return loadstring(res)() end)
        if lOk and lib then return lib end
    end

    error("Failed to load SonLibrary!")
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
        Title = string.lower(game:GetService("Players").LocalPlayer.Name),
        Subtitle = "SonHUB Edition"
    }
})

Window:CreateCategory("Features")

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
    Columns = 1
})

local moveCard = MovementTab:CreateSection("Locomotion (Full Width)", 1)
moveCard:CreateSlider({
    Name = "WalkSpeed",
    Description = "Adjust character movement velocity",
    Min = 16,
    Max = 150,
    Default = 16,
    Suffix = " studs/s",
    Increment = 1,
    Flag = "WalkSpeed",
    Callback = function(v)
        local char = game:GetService("Players").LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end
})

moveCard:CreateSlider({
    Name = "JumpPower",
    Description = "Vertical impulse strength",
    Min = 50,
    Max = 350,
    Default = 50,
    Suffix = " power",
    Increment = 5,
    Flag = "JumpPower",
    Callback = function(v)
        local char = game:GetService("Players").LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").JumpPower = v
        end
    end
})

moveCard:CreateDropdown({
    Name = "Movement Mode",
    Description = "Select physics override method",
    Options = {"Default", "Bhop", "Flight", "Spider"},
    Default = "Default",
    Flag = "MovementMode",
    Callback = function(selected)
        print("Movement Mode:", selected)
    end
})

moveCard:CreateButton({
    Name = "Reset Movement Defaults",
    Description = "Restore standard character physics",
    Callback = function()
        local char = game:GetService("Players").LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            char:FindFirstChildOfClass("Humanoid").JumpPower = 50
        end
        SonLibrary:Notify({
            Title = "Movement",
            Content = "Physics reset to default",
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
        print("Overlays:", table.concat(list, ", "))
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
        workspace.CurrentCamera.FieldOfView = v
    end
})

worldCard:CreateToggle({
    Name = "Fullbright",
    Description = "Eliminate world shadows and fog",
    Default = false,
    Flag = "Fullbright",
    Callback = function(v)
        game:GetService("Lighting").Brightness = v and 2 or 1
        game:GetService("Lighting").ClockTime = v and 14 or 12
    end
})

local PlayerTab = Window:CreateTab({
    Title = "Player",
    Icon = "rbxassetid://7733954760",
    Columns = 2
})

local charCard = PlayerTab:CreateSection("Character", 1)
charCard:CreateToggle({
    Name = "Infinite Jump",
    Default = false,
    Flag = "InfJump",
    Callback = function(v)
        print("Inf Jump:", v)
    end
})

charCard:CreateToggle({
    Name = "Noclip",
    Default = false,
    Flag = "Noclip",
    Callback = function(v)
        print("Noclip:", v)
    end
})

charCard:CreateKeybind({
    Name = "Quick Teleport Key",
    Description = "Press key to teleport forward",
    Default = Enum.KeyCode.E,
    Flag = "TPKey",
    Callback = function(key)
        print("Bound key:", key.Name)
    end
})

local infoCard = PlayerTab:CreateSection("Info & Clipboard", 2)
infoCard:CreateInput({
    Name = "Custom Display Tag",
    Description = "Tag displayed on HUD Watermark",
    Placeholder = "Enter tag...",
    Default = "",
    Flag = "CustomTag",
    Callback = function(text, enter)
        if enter then
            SonLibrary:Notify({
                Title = "Tag Updated",
                Content = "Set to: " .. text,
                Duration = 2
            })
        end
    end
})

infoCard:CreateButton({
    Name = "Copy Player Position",
    Description = "Copy Vector3 coordinates to clipboard",
    Callback = function()
        local char = game:GetService("Players").LocalPlayer.Character
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
    Columns = 1
})

local miscCard = MiscTab:CreateSection("Utility & Actions", 1)
miscCard:CreateParagraph({
    Title = "About SonHUB",
    Content = "Clean, responsive, high-performance Luau library with zero frame drops, native touch dragging, and unified JSON configuration management."
})

miscCard:CreateToggle({
    Name = "Smooth Animations",
    Description = "Enable or disable UI tween transitions (disable for potato/laggy devices)",
    Default = true,
    Callback = function(val)
        SonLibrary:SetAnimations(val)
    end
})

miscCard:CreateToggle({
    Name = "Single Column Mode",
    Description = "Shrink width 30% and scale components to clean 1-column layout",
    Default = false,
    Callback = function(val)
        Window:SetColumns(val and 1 or 2)
    end
})

miscCard:CreateButton({
    Name = "Toggle Full Zoom",
    Description = "Expand UI to prominent large canvas (960x600)",
    Callback = function()
        Window:ToggleZoom()
    end
})

miscCard:CreateProgress({
    Name = "System Memory Usage",
    Description = "Client memory footprint indicator",
    Default = 42
})

miscCard:CreateButton({
    Name = "Show Confirmation Modal",
    Description = "Open interactive dialog overlay",
    Callback = function()
        Window:CreateDialog({
            Title = "Confirm Action",
            Content = "Are you sure you want to trigger this test routine?",
            Buttons = {
                {
                    Title = "Yes",
                    Style = "Primary",
                    Callback = function()
                        SonLibrary:Notify({Title = "Confirmed", Content = "Action executed successfully!"})
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

Window:CreateCategory("Manager")

local PresetsTab = Window:CreateTab({
    Title = "Presets",
    Icon = "rbxassetid://7733964719",
    Columns = 2
})

PresetsTab:BuildConfigSection(1)

local manageCard = PresetsTab:CreateSection("Cloud & Backup", 2)
manageCard:CreateButton({
    Name = "Export All Flags to Console",
    Description = "Dump current flag table to developer console",
    Callback = function()
        print("=== SONHUB GLOBAL FLAGS DUMP ===")
        for flag, val in pairs(SonLibrary.Flags) do
            print(string.format("[%s] = %s", tostring(flag), tostring(val)))
        end
        SonLibrary:Notify({Title = "Flags Dumped", Content = "Check F9 Console for details"})
    end
})

local AutoBuyTab = Window:CreateTab({
    Title = "Auto Buy",
    Icon = "rbxassetid://7733942651",
    Columns = 1
})

local buyCard = AutoBuyTab:CreateSection("Shop Automation", 1)
buyCard:CreateToggle({
    Name = "Auto Buy Sword Upgrades",
    Default = false,
    Flag = "AutoBuySwords"
})
buyCard:CreateToggle({
    Name = "Auto Buy Stat Potions",
    Default = false,
    Flag = "AutoBuyPotions"
})

local AccountsTab = Window:CreateTab({
    Title = "Accounts",
    Icon = "rbxassetid://7733765307",
    Columns = 1
})

local accCard = AccountsTab:CreateSection("Account Management", 1)
accCard:CreateParagraph({
    Title = "Logged in User",
    Content = "Current session: " .. game:GetService("Players").LocalPlayer.Name .. " (" .. game:GetService("Players").LocalPlayer.UserId .. ")"
})

SonLibrary:Notify({
    Title = "pasta",
    Content = "Loaded successfully! Press RightShift to toggle UI.",
    Duration = 3
})
