--!nocheck
--[[
    ====================================================================
    SonLibrary UI v2.5.0 - Production Example & Template Script
    Repository: https://github.com/hongson209/sonlibrary
    Raw Library: https://raw.githubusercontent.com/hongson209/sonlibrary/refs/heads/main/sonlibrary.lua
    ====================================================================
    Dùng template này để tích hợp SonLibrary vào bất kỳ Script / Hub nào:
      - Tương thích 100% PC, Điện thoại (Mobile), Máy tính bảng (Tablet)
      - Hỗ trợ đầy đủ components: Button, Toggle, Slider, Dropdown (Searchable),
        MultiDropdown (Searchable), Input, Keybind, ColorPicker, Progress Bar,
        Modal Dialog, Toast Notifications, Native Roblox Topbar Icon
      - Smooth Thu gọn (Minimize) co lại 1 nửa chiều ngang mượt mà 144 FPS
]]

-- [1] TẢI THƯ VIỆN (Loadstring từ GitHub hoặc file cục bộ)
local SonLibrary = (function()
    if _G.SonLibrary and _G.SonLibrary.CreateWindow then
        return _G.SonLibrary
    end
    if typeof(getgenv) == "function" and getgenv().SonLibrary and getgenv().SonLibrary.CreateWindow then
        return getgenv().SonLibrary
    end

    -- Thử load từ file nội bộ nếu có
    local localFiles = {"sonlibrary.lua", "Library/sonlibrary.lua", "sonlibrary.luau", "Library/sonlibrary.luau"}
    for _, path in ipairs(localFiles) do
        if typeof(isfile) == "function" and isfile(path) and typeof(readfile) == "function" then
            local ok, lib = pcall(function() return loadstring(readfile(path))() end)
            if ok and lib and typeof(lib.CreateWindow) == "function" then
                return lib
            end
        end
    end

    -- Tải trực tiếp từ Raw GitHub URL
    local githubUrl = "https://raw.githubusercontent.com/hongson209/sonlibrary/refs/heads/main/sonlibrary.lua"
    local rawCode = game:HttpGet(githubUrl)
    return loadstring(rawCode)()
end)()

-- [2] KHỞI TẠO CỬA SỔ CHÍNH (CreateWindow)
local Window = SonLibrary:CreateWindow({
    Title = "SonHUB",
    SubTitle = "Titan Edition",
    AccentColor = Color3.fromRGB(0, 166, 255),       -- Màu chủ đề chính (RGB)
    ToggleKey = Enum.KeyCode.RightControl,            -- Phím tắt bật/tắt menu trên PC
    TopbarButton = true,                              -- Hiển thị nút tròn logo SonHUB trên Topbar Roblox
    Profile = {
        Enabled = true,                               -- Bật/tắt thẻ người dùng ở góc dưới Sidebar (false nếu muốn ẩn)
        -- Title = "SonHUB Admin",                    -- Tùy chỉnh tên (mặc định lấy Tên hiển thị Roblox)
        -- Subtitle = "VIP Lifetime",                 -- Tùy chỉnh dòng phụ (mặc định hiển thị bộ đếm giờ dùng)
        -- Avatar = "rbxthumb://...",                -- Tùy chỉnh ảnh đại diện (mặc định avatar Roblox của bạn)
    }
})

-- [3] TẠO CÁC TAB NỘI DUNG (CreateTab)
local MainTab = Window:CreateTab({
    Title = "Tổng quan",
    Icon = "rbxassetid://10723407389" -- Icon Lucide Home
})

local ConfigTab = Window:CreateTab({
    Title = "Cấu hình",
    Icon = "rbxassetid://10747373176" -- Icon Lucide Sliders
})

-- ====================================================================
-- TAB 1: TỔNG QUAN (Main Tab)
-- ====================================================================
MainTab:CreateSection("Tính năng tự động")

-- TOGGLE
local autoFarmToggle = MainTab:CreateToggle({
    Name = "Tự động kích hoạt",
    Description = "Bật tính năng tự động chạy theo chu kỳ lặp lại",
    Default = true,
    Callback = function(state: boolean)
        print("[SonHUB] Tự động kích hoạt:", state)
    end
})

-- SLIDER
local walkSpeedSlider = MainTab:CreateSlider({
    Name = "Tốc độ di chuyển",
    Description = "Tùy chỉnh tốc độ di chuyển nhân vật",
    Min = 16,
    Max = 250,
    Default = 32,
    Precision = 0,
    Suffix = " studs",
    Callback = function(val: number)
        local character = game:GetService("Players").LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = val
        end
    end
})

MainTab:CreateSection("Chọn chế độ & đối tượng")

-- DROPDOWN (Có ô tìm kiếm nhỏ tùy chọn Searchable = true)
local targetModeDrop = MainTab:CreateDropdown({
    Name = "Chế độ nhắm",
    Description = "Lựa chọn chế độ khóa mục tiêu",
    Options = {"Mục tiêu gần nhất", "Máu thấp nhất", "Vị trí con trỏ", "Ngẫu nhiên"},
    Default = "Mục tiêu gần nhất",
    Searchable = true, -- Ô tìm kiếm nhỏ gọn lọc thời gian thực
    Callback = function(chosen: string)
        print("[SonHUB] Chế độ nhắm hiện tại:", chosen)
    end
})

-- MULTI-DROPDOWN (Chọn nhiều mục, có Searchable = true)
local priorityTargets = MainTab:CreateMultiDropdown({
    Name = "Mục tiêu ưu tiên",
    Description = "Chọn một hoặc nhiều loại mục tiêu cần lọc",
    Options = {"Người chơi", "Quái vật", "Boss", "Vật phẩm rơi", "NPC"},
    Default = {"Người chơi", "Boss"},
    Searchable = true,
    Callback = function(list: {string})
        print("[SonHUB] Danh sách ưu tiên:", table.concat(list, ", "))
    end
})

-- PROGRESS BAR
local dataProgress = MainTab:CreateProgress({
    Name = "Tiến độ tải dữ liệu",
    Description = "Trạng thái nạp cấu hình hệ thống",
    Default = 75
})

MainTab:CreateSection("Tương tác & Thông báo")

-- BUTTON: Mở Modal Confirmation Dialog (Hộp thoại xác nhận)
MainTab:CreateButton({
    Name = "Mở hộp thoại xác nhận",
    Description = "Kiểm tra popup xác nhận trước khi thực thi",
    Callback = function()
        Window:CreateDialog({
            Title = "Xác nhận hành động",
            Content = "Bạn có chắc chắn muốn áp dụng các thiết lập này cho SonHUB?",
            Buttons = {
                {
                    Title = "Hủy bỏ",
                    Style = "CardHover"
                },
                {
                    Title = "Xác nhận",
                    Style = "Primary",
                    Callback = function()
                        SonLibrary:Notify({
                            Title = "SonHUB",
                            Content = "Thao tác đã được xác nhận thành công!",
                            Duration = 3,
                            Type = "Success"
                        })
                    end
                }
            }
        })
    end
})

-- BUTTON: Thử nghiệm Toast Notification
MainTab:CreateButton({
    Name = "Thử nghiệm thông báo Toast",
    Description = "Bấm để kiểm tra thông báo Toast glassmorphic",
    Callback = function()
        SonLibrary:Notify({
            Title = "SonHUB",
            Content = "Thao tác thông báo đã được kích hoạt!",
            Duration = 3.5,
            Type = "Success" -- Hỗ trợ: "Info", "Success", "Warning", "Danger"
        })
    end
})

-- ====================================================================
-- TAB 2: CẤU HÌNH (Config Tab)
-- ====================================================================
ConfigTab:CreateSection("Cấu hình nâng cao")

-- INPUT (Text box)
ConfigTab:CreateInput({
    Name = "Tên mục tiêu cụ thể",
    Description = "Nhập tên người chơi muốn ưu tiên",
    Placeholder = "Nhập tên người chơi...",
    Default = "",
    Callback = function(text: string, enterPressed: boolean)
        print("[SonHUB] Tên mục tiêu nhập vào:", text, "(Enter:", enterPressed, ")")
    end
})

-- KEYBIND
ConfigTab:CreateKeybind({
    Name = "Phím tắt nhanh",
    Description = "Nhấn để gán phím kích hoạt chức năng",
    Default = Enum.KeyCode.E,
    Callback = function(key: Enum.KeyCode)
        print("[SonHUB] Phím tắt đã đổi sang:", key.Name)
    end
})

-- COLOR PICKER
ConfigTab:CreateColorPicker({
    Name = "Màu chủ đề ESP",
    Default = Color3.fromRGB(0, 166, 255),
    Callback = function(color: Color3)
        print("[SonHUB] Màu đã chọn (R, G, B):", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
    end
})

-- PARAGRAPH
ConfigTab:CreateParagraph({
    Title = "Thông tin hệ thống",
    Content = "SonLibrary v2.5.0 - Tối ưu hoàn hảo cho Điện thoại, Máy tính bảng và PC. Hỗ trợ tự động co giãn theo tỉ lệ màn hình và thu nhỏ 1/2 chiều ngang mượt mà."
})

-- ====================================================================
-- TAB 3: CÀI ĐẶT HỆ THỐNG (Settings Tab)
-- ====================================================================
local SettingsTab = Window:CreateSettingsTab()
SettingsTab:CreateSection("Cài đặt chung")

SettingsTab:CreateKeybind({
    Name = "Phím mở / ẩn Menu",
    Default = Enum.KeyCode.RightControl,
    Callback = function(k: Enum.KeyCode)
        print("[SonHUB] Toggle Menu Key:", k.Name)
    end
})

SettingsTab:CreateButton({
    Name = "Sao chép link Discord",
    Description = "Tham gia server cộng đồng hỗ trợ SonHUB",
    Callback = function()
        if typeof(setclipboard) == "function" then
            setclipboard("https://discord.gg/htBURFNyhV")
        end
        SonLibrary:Notify({
            Title = "SonHUB",
            Content = "Đã sao chép link Discord vào bộ nhớ tạm!",
            Duration = 2.8,
            Type = "Success"
        })
    end
})

-- [4] GỬI THÔNG BÁO CHÀO MỪNG KHI LOAD XONG
SonLibrary:Notify({
    Title = "SonHUB",
    Content = "Giao diện đã tải thành công!",
    Duration = 3.2,
    Type = "Success"
})

return {
    Window = Window,
    MainTab = MainTab,
    ConfigTab = ConfigTab,
    SettingsTab = SettingsTab,
    SonLibrary = SonLibrary
}
