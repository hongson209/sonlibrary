--!nocheck

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
    if ok and res and #res > 1000 then
        local lOk, lib = pcall(function() return loadstring(res)() end)
        if lOk and lib then return lib end
    end

    error("Failed to load SonLibrary")
end)()

local Window = SonLibrary:CreateWindow({
    Title = "SonHUB V2",
    SubTitle = "Titan Edition",
    Logo = "rbxassetid://10723346959",
    AccentColor = Color3.fromRGB(0, 166, 255),
    FontPreset = "Inter",
    ToggleKey = Enum.KeyCode.RightControl,
    DefaultTab = "Tổng quan",
    Profile = {
        Enabled = true,
        Title = "SonHUB VIP",
        Subtitle = "Lifetime Member",
    }
})

SonLibrary:Notify({
    Title = "SonHUB",
    Content = "Khởi chạy thành công SonLibrary v2.5.0",
    Icon = "rbxassetid://10723346959",
    Duration = 3,
    Type = "Success"
})

local MainTab = Window:CreateTab({
    Title = "Tổng quan",
    Icon = "rbxassetid://10723407389"
})

MainTab:CreateSection("THÔNG TIN")

MainTab:CreateParagraph({
    Title = "SonHUB Interface",
    Content = "Giao diện Glassmorphism chuẩn quốc tế, font WindUI Inter sắc nét hỗ trợ tiếng Việt đầy đủ dấu và tối ưu 144 FPS."
})

MainTab:CreateSection("ĐIỀU KHIỂN")

MainTab:CreateButton({
    Name = "Thực thi tác vụ",
    Description = "Chạy chức năng trực tiếp",
    Callback = function()
        SonLibrary:Notify({
            Title = "Thành công",
            Content = "Đã thực thi tác vụ",
            Type = "Success",
            Duration = 2
        })
    end
})

local autoFarmToggle = MainTab:CreateToggle({
    Name = "Tự động thu thập (Auto Farm)",
    Description = "Chạy vòng lặp an toàn ở chế độ nền",
    Default = false,
    Callback = function(enabled)
        SonLibrary:Notify({
            Title = "Auto Farm",
            Content = enabled and "Đã bật tự động thu thập" or "Đã tắt tự động thu thập",
            Type = enabled and "Success" or "Warning",
            Duration = 2
        })
    end
})

MainTab:CreateSlider({
    Name = "Tốc độ di chuyển",
    Description = "WalkSpeed nhân vật",
    Min = 16,
    Max = 250,
    Default = 50,
    Suffix = " studs/s",
    Callback = function(val)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = val
        end
    end
})

local progressBar = MainTab:CreateProgress({
    Name = "Tiến độ nhiệm vụ",
    Description = "Theo dõi phần trăm hoàn thành",
    Default = 45
})

MainTab:CreateButton({
    Name = "Tăng tiến độ +15%",
    Callback = function()
        local current = progressBar.Value or 45
        local newPct = math.min(current + 15, 100)
        progressBar:Set(newPct, "Đang xử lý dữ liệu...")
    end
})

local FontTab = Window:CreateTab({
    Title = "Cài đặt Font",
    Icon = "rbxassetid://10734950309"
})

FontTab:CreateSection("BỘ CHUYỂN FONT")

local fontList = {
    "Inter",
    "PressStart2P",
    "PaytoneOne",
    "Cutepunch",
    "Chubby",
    "Playful",
    "Rounded",
    "Gotham",
    "Tech",
    "Code",
    "Elegant"
}

FontTab:CreateDropdown({
    Name = "Preset Font Chữ",
    Description = "Đổi font của toàn bộ Window theo thời gian thực",
    Options = fontList,
    Default = "Inter",
    Searchable = true,
    Callback = function(selectedFont)
        Window:SetFont(selectedFont)
        SonLibrary:Notify({
            Title = "Đã cập nhật Font",
            Content = "Đang sử dụng: " .. selectedFont,
            Duration = 2,
            Type = "Info"
        })
    end
})

FontTab:CreateSection("MẪU THỬ TIẾNG VIỆT")

FontTab:CreateParagraph({
    Title = "Typography Preview",
    Content = "Hà Nội nghìn năm văn hiến, non sông gấm vóc rạng ngời.\n0123456789 - [SonHUB] - (v2.5.0) - !@#$%^&*()_+"
})

local ConfigTab = Window:CreateTab({
    Title = "Cấu hình",
    Icon = "rbxassetid://10747373176"
})

ConfigTab:CreateSection("TÙY CHỌN")

ConfigTab:CreateInput({
    Name = "Mã kích hoạt VIP",
    Description = "Nhập mã quà tặng hoặc lệnh tùy chỉnh",
    Placeholder = "Nhập code tại đây...",
    Default = "",
    Callback = function(text, enterPressed)
        if enterPressed and #text > 0 then
            SonLibrary:Notify({
                Title = "Nhập mã thành công",
                Content = "Mã: " .. text,
                Duration = 2,
                Type = "Success"
            })
        end
    end
})

ConfigTab:CreateMultiDropdown({
    Name = "Khu vực hoạt động",
    Description = "Chọn một hoặc nhiều địa điểm",
    Options = {"Thành phố chính", "Hang băng", "Rừng nguyên sinh", "Sa mạc lửa", "Đảo trên không"},
    Default = {"Thành phố chính"},
    Searchable = true,
    Callback = function(selectedList)
        print("[SonHUB] Khu vực:", table.concat(selectedList, ", "))
    end
})

ConfigTab:CreateKeybind({
    Name = "Phím kích hoạt nhanh",
    Description = "Gán phím tắt nhanh trên bàn phím",
    Default = Enum.KeyCode.F,
    Callback = function(key)
        SonLibrary:Notify({
            Title = "Đổi phím tắt",
            Content = "Phím mới: " .. key.Name,
            Duration = 2,
            Type = "Info"
        })
    end
})

ConfigTab:CreateColorPicker({
    Name = "Màu hiển thị ESP",
    Default = Color3.fromRGB(0, 166, 255),
    Callback = function(newColor)
        print("[SonHUB] Color:", math.floor(newColor.R*255), math.floor(newColor.G*255), math.floor(newColor.B*255))
    end
})

ConfigTab:CreateButton({
    Name = "Xác nhận cài lại thiết lập",
    Description = "Mở hộp thoại Modal Popup",
    Callback = function()
        Window:CreateDialog({
            Title = "Xác nhận tác vụ",
            Content = "Bạn có chắc chắn muốn cài lại toàn bộ thiết lập về mặc định ban đầu không?",
            Buttons = {
                {
                    Title = "Đồng ý",
                    Style = "Primary",
                    Callback = function()
                        SonLibrary:Notify({ Title = "Đã đặt lại", Content = "Cài đặt đã trở về mặc định", Type = "Success", Duration = 2 })
                    end
                },
                {
                    Title = "Hủy bỏ",
                    Style = "Danger"
                }
            }
        })
    end
})

return Window
