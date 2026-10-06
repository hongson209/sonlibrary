# ⚡ SonLibrary UI v2.5.0 — Premium Roblox Script UI Library

<div align="center">

![SonLibrary Banner](https://cdn.discordapp.com/attachments/1317065294736265248/1555222187378475029/sonhub.png)

[![Release](https://img.shields.io/badge/Release-v2.5.0-00A6FF.svg?style=for-the-badge&logo=roblox)](https://github.com/hongson209/sonlibrary)
[![Language](https://img.shields.io/badge/Language-Luau%20%2F%20Lua-blue.svg?style=for-the-badge&logo=lua)](https://github.com/hongson209/sonlibrary)
[![FPS](https://img.shields.io/badge/Performance-144%20FPS%20GPU-00C853.svg?style=for-the-badge)](https://github.com/hongson209/sonlibrary)
[![Cross-Platform](https://img.shields.io/badge/Platform-PC%20%7C%20Mobile%20%7C%20Tablet-FFA000.svg?style=for-the-badge)](https://github.com/hongson209/sonlibrary)
[![License](https://img.shields.io/badge/License-MIT-gray.svg?style=for-the-badge)](https://github.com/hongson209/sonlibrary)

**Thư viện UI Script hiện đại, đẳng cấp, tối ưu hóa phần cứng GPU cực nhẹ, tương thích hoàn hảo 100% Mobile, Máy tính bảng và PC.**

[Cài đặt nhanh](#-cài-đặt-nhanh-quick-start) • [Khởi tạo cửa sổ](#-khởi-tạo-cửa-sổ-createwindow) • [Quản lý Tab](#-quản-lý-tab-createtab) • [Danh sách Components](#-thành-phần-giao-diện-components) • [Mã nguồn mẫu](#-mã-nguồn-mẫu-hoàn-chỉnh-examplelua)

</div>

---

## 🌟 Điểm nổi bật & Tính năng vượt trội

- 💎 **Thiết kế Glassmorphism chuẩn quốc tế:** Nền tối sâu (Deep Dark), hiệu ứng làm mờ acrylic tinh tế, viền phát sáng động theo màu chủ đề.
- 📱 **Hỗ trợ đa nền tảng (Cross-Platform Responsive):** Tự động phát hiện và co giãn theo kích thước màn hình điện thoại (Landscape / Portrait) và máy tính, không lo vỡ layout.
- 🪟 **Smooth Minimize (Thu gọn 1/2 chiều ngang):** Khi bấm nút thu gọn `[-]`, giao diện co lại một nửa chiều ngang mượt mà ở tần số quét cao (144 FPS) mà không che khuất màn hình chơi game.
- 🎮 **Roblox Native Topbar Icon:** Tích hợp nút icon tròn logo SonHUB trực tiếp vào thanh điều khiển Topbar gốc của Roblox, mở/tắt menu chỉ với 1 chạm trên điện thoại.
- 👤 **Thẻ Profile tùy biến:** Hiển thị Avatar, Tên người dùng và bộ đếm thời gian chơi game trực tiếp (Playtime Live Tracker). Có thể tùy chỉnh chữ hoặc ẩn hoàn toàn.
- 🔍 **Tìm kiếm tức thì (Searchable Dropdown):** Hỗ trợ tìm kiếm theo từ khóa trong danh sách chọn (Dropdown & MultiDropdown) với danh sách cuộn mượt mà.
- 🎨 **Color Picker & Keybind chuyên nghiệp:** Bảng chọn màu HSV + thanh Hue mượt mà, bộ gán phím hỗ trợ cả bàn phím PC và chạm cảm ứng.
- 🔔 **Toast Notification & Modal Dialog:** Thông báo góc phải dạng popup kính mờ không đè lên thanh chat cùng hộp thoại xác nhận (Dialog) an toàn.

---

## 🚀 Cài đặt nhanh (Quick Start)

Dán đoạn mã sau vào đầu script của bạn để tải thư viện từ GitHub:

```lua
local SonLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/hongson209/sonlibrary/refs/heads/main/sonlibrary.lua"))()
```

---

## 🪟 Khởi tạo cửa sổ (CreateWindow)

```lua
local Window = SonLibrary:CreateWindow({
    Title = "SonHUB",                                 -- Tên tiêu đề lớn của menu
    SubTitle = "Titan Edition",                       -- Dòng tiêu đề phụ (phiên bản / tác giả)
    AccentColor = Color3.fromRGB(0, 166, 255),        -- Màu chủ đề chính (RGB)
    ToggleKey = Enum.KeyCode.RightControl,             -- Phím tắt ẩn/hiện menu trên PC
    TopbarButton = true,                               -- Hiển thị icon SonHUB trên thanh Topbar Roblox
    DefaultTab = "Tổng quan",                         -- Tab mở mặc định khi script khởi động
    Profile = {
        Enabled = true,                                -- Bật/tắt thẻ thông tin người dùng ở góc dưới Sidebar
        Title = nil,                                   -- (Tùy chọn) Tên hiển thị (nil = tự lấy tên Roblox)
        Subtitle = nil,                                -- (Tùy chọn) Chữ phụ (nil = bộ đếm thời gian chơi live)
        Avatar = nil,                                  -- (Tùy chọn) Ảnh avatar (nil = avatar Roblox của bạn)
    }
})
```

### Chi tiết các tùy chọn `Profile`:
| Tham số | Kiểu dữ liệu | Mặc định | Mô tả |
| :--- | :--- | :--- | :--- |
| `Enabled` | `boolean` | `true` | Đặt `false` để ẩn hoàn toàn thẻ profile, danh sách Tab sẽ tự động kéo dài xuống đáy sidebar. |
| `Title` | `string?` | `DisplayName` | Tên hiển thị trên thẻ (VD: `"VIP Admin"`). |
| `Subtitle` | `string?` | Live Timer | Chữ mô tả dưới tên (VD: `"VIP Lifetime"`). Nếu để trống sẽ tự động hiển thị `"Đã dùng: hh:mm:ss"`. |
| `Avatar` | `string?` | Roblox Headshot | Asset ID hình ảnh đại diện (VD: `"rbxassetid://12345678"`). |

---

## 📑 Quản lý Tab (CreateTab)

### 1. Tạo Tab nội dung thông thường
```lua
local MainTab = Window:CreateTab({
    Title = "Tổng quan",
    Icon = "rbxassetid://10723407389" -- Icon Lucide Home
})
```

### 2. Tạo Tab Cài đặt (Settings Tab)
Tab cài đặt sẽ được xếp ngay ngắn trong danh sách Tab của thanh Sidebar:
```lua
local SettingsTab = Window:CreateSettingsTab({
    Title = "Cài đặt",                               -- (Tùy chọn) Mặc định: "Cài đặt"
    Icon = "rbxassetid://10734950309"                -- Icon Lucide Settings gear
})
```

### 3. Các phương thức điều khiển Cửa sổ (Window Methods)
- `Window:SelectTab(TabObject | "Tên Tab")` — Chuyển tab bằng code.
- `Window:Toggle(visibleState?)` — Ẩn hoặc hiện cửa sổ có hiệu ứng zoom mượt.
- `Window:ToggleMinimize()` — Thu gọn hoặc mở rộng cửa sổ (1/2 chiều ngang).
- `Window:Notify(Config)` — Gửi thông báo Toast.
- `Window:Dialog(Config)` — Mở hộp thoại xác nhận Dialog.
- `Window:Destroy()` — Hủy hoàn toàn GUI và dọn dẹp bộ nhớ.

---

## 🧩 Thành phần giao diện (Components)

### 1. Section (Phân nhóm danh mục)
Tạo thanh tiêu đề phân nhóm chữ in hoa kèm đường kẻ chia ranh giới tinh tế:
```lua
Tab:CreateSection("Tính năng tự động")
```

### 2. Divider (Đường kẻ phân cách)
Đường kẻ mờ phân tách giữa các cụm thành phần:
```lua
Tab:CreateDivider()
```

---

### 3. Button (Nút bấm)
Thẻ nút bấm bo góc với hiệu ứng đổi màu hover và mũi tên hành động:
```lua
Tab:CreateButton({
    Name = "Nhận quà hàng ngày",
    Description = "Bấm để nhận toàn bộ phần thưởng hiện có", -- (Tùy chọn)
    Callback = function()
        print("Đã bấm nút!")
    end
})
```

---

### 4. Toggle (Công tắc bật / tắt)
Công tắc trượt mượt mà có trạng thái màu chủ đề và nhãn trạng thái:
```lua
local myToggle = Tab:CreateToggle({
    Name = "Tự động đánh quái",
    Description = "Tự động tìm kiếm và tấn công mục tiêu gần nhất",
    Default = false,
    Callback = function(state: boolean)
        print("Trạng thái:", state)
    end
})

-- Phương thức:
myToggle:Set(true)            -- Đổi trạng thái bằng code
local val = myToggle:GetValue() -- Lấy giá trị hiện tại (true / false)
```

---

### 5. Slider (Thanh trượt giá trị)
Thanh trượt hỗ trợ kéo chuột hoặc chạm tay mượt mà, tùy chỉnh bước nhảy (Precision) và đơn vị (Unit):
```lua
local mySlider = Tab:CreateSlider({
    Name = "Tốc độ di chuyển",
    Description = "Điều chỉnh WalkSpeed của nhân vật",
    Min = 16,
    Max = 250,
    Default = 32,
    Precision = 1,              -- Bước nhảy (1 = số nguyên, 0.1 = số thập phân)
    Unit = " studs",            -- Đơn vị hiển thị sau số
    Callback = function(val: number)
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end
})

-- Phương thức:
mySlider:Set(50)              -- Đặt giá trị bằng code
local currentSpeed = mySlider:GetValue()
```

---

### 6. Dropdown (Menu chọn đơn - Có ô tìm kiếm)
Hỗ trợ tìm kiếm theo từ khóa tức thì và tự động cuộn danh sách:
```lua
local myDropdown = Tab:CreateDropdown({
    Name = "Chọn chế độ nhắm",
    Description = "Lựa chọn mục tiêu ưu tiên cho hệ thống",
    Options = {"Mục tiêu gần nhất", "Máu thấp nhất", "Boss thế giới", "Người chơi"},
    Default = "Mục tiêu gần nhất",
    Searchable = true,          -- Bật thanh tìm kiếm bên trong danh sách
    MaxItemsVisible = 5,        -- Số mục tối đa hiển thị cùng lúc
    Callback = function(selected: string)
        print("Đã chọn:", selected)
    end
})

-- Phương thức:
myDropdown:Set("Boss thế giới")
myDropdown:Refresh({"Mục 1", "Mục 2", "Mục 3"}, "Mục 1") -- Cập nhật danh sách mới
local selected = myDropdown:GetValue()
```

---

### 7. MultiDropdown (Menu chọn nhiều mục - Có ô tìm kiếm)
Cho phép tích chọn nhiều mục cùng lúc, hiển thị số lượng mục đã chọn:
```lua
local myMultiDrop = Tab:CreateMultiDropdown({
    Name = "Mục tiêu cần lọc ESP",
    Description = "Tích chọn các đối tượng cần hiển thị xuyên tường",
    Options = {"Người chơi", "Quái vật", "Vật phẩm rơi", "Rương báu", "Boss"},
    Default = {"Người chơi", "Boss"},
    Searchable = true,
    Callback = function(selectedList: {string})
        for _, item in ipairs(selectedList) do
            print("Đang bật ESP cho:", item)
        end
    end
})

-- Phương thức:
myMultiDrop:Set({"Người chơi", "Rương báu"})
local list = myMultiDrop:GetValue()
```

---

### 8. Progress Bar (Thanh tiến trình)
Thanh tiến trình bo góc phát sáng màu chủ đề với nhãn phần trăm tự động:
```lua
local myProgress = Tab:CreateProgress({
    Name = "Tiến độ tải dữ liệu",
    Description = "Trạng thái nạp cấu hình hệ thống",
    Default = 45 -- Phần trăm từ 0 đến 100
})

-- Phương thức:
myProgress:Set(80)              -- Cập nhật phần trăm (0 - 100)
local currentPercent = myProgress:GetValue()
```

---

### 9. Input (Ô nhập văn bản)
Ô nhập văn bản phong cách kính mờ, hỗ trợ chế độ chỉ nhập số và sự kiện Enter/Clear:
```lua
local myInput = Tab:CreateInput({
    Name = "Dịch chuyển đến Tọa độ X",
    Placeholder = "Nhập số tọa độ...",
    Default = "100",
    NumericOnly = true,         -- Chỉ cho phép nhập số
    ClearOnFocus = false,       -- Không xóa chữ khi click vào ô
    Finished = true,            -- Chỉ gọi Callback khi ấn Enter hoặc bấm ra ngoài
    Callback = function(text: string)
        print("Tọa độ đã nhập:", text)
    end
})

-- Phương thức:
myInput:Set("250")
local text = myInput:GetValue()
```

---

### 10. Keybind (Gán phím tắt)
Hỗ trợ lắng nghe sự kiện phím với chế độ bấm (Click) hoặc chuyển trạng thái (Toggle):
```lua
local myKeybind = Tab:CreateKeybind({
    Name = "Phím kích hoạt Fly",
    Description = "Nhấn vào ô để gán phím mới trên bàn phím",
    Default = Enum.KeyCode.F,
    Mode = "Toggle",            -- "Toggle" hoặc "Click"
    Callback = function(key: Enum.KeyCode)
        print("Đã nhấn phím:", key.Name)
    end
})

-- Phương thức:
myKeybind:Set(Enum.KeyCode.G)
local currentKey = myKeybind:GetValue()
```

---

### 11. ColorPicker (Bảng chọn màu HSV)
Bảng chọn màu cao cấp gồm ô màu chính (Saturation / Value) và dải màu (Hue Slider) mượt mà:
```lua
local myColorPicker = Tab:CreateColorPicker({
    Name = "Màu chủ đề Highlight",
    Description = "Chọn màu hiển thị cho khung viền đối tượng",
    Default = Color3.fromRGB(0, 166, 255),
    Callback = function(color: Color3)
        print("Mã màu đã chọn:", color)
    end
})

-- Phương thức:
myColorPicker:Set(Color3.fromRGB(255, 0, 100))
local col = myColorPicker:GetValue()
```

---

### 12. Paragraph (Đoạn văn bản thông tin)
Thẻ ghi chú làm nổi bật thông báo, hướng dẫn sử dụng hoặc mô tả bản cập nhật:
```lua
local myPara = Tab:CreateParagraph({
    Title = "Lưu ý quan trọng",
    Content = "Hãy bật chế độ chống văng game (Anti-AFK) trước khi treo máy ban đêm để tránh bị mất kết nối."
})

-- Phương thức:
myPara:SetTitle("Tiêu đề mới")
myPara:SetContent("Nội dung mới đã được cập nhật.")
```

---

### 13. Dialog (Hộp thoại xác nhận Modal)
Hộp thoại thông báo phủ mờ toàn màn hình, yêu cầu người dùng xác nhận hành động nguy hiểm:
```lua
Window:CreateDialog({
    Title = "Xác nhận khôi phục cài đặt",
    Content = "Bạn có chắc chắn muốn xóa toàn bộ cấu hình đã lưu và trở về mặc định không?",
    Buttons = {
        {
            Title = "Hủy bỏ",
            Style = "Secondary",
            Callback = function()
                print("Đã bấm Hủy")
            end
        },
        {
            Title = "Đồng ý",
            Style = "Danger",   -- "Primary" | "Danger" | "Secondary"
            Callback = function()
                print("Đã khôi phục cài đặt gốc!")
            end
        }
    }
})
```

---

### 14. Toast Notification (Thông báo góc màn hình)
Thông báo dạng pop-up kính mờ không che khuất màn hình chơi game, có thanh đếm thời gian tự tắt:
```lua
SonLibrary:Notify({
    Title = "SonHUB Thông báo",
    Content = "Đã lưu cấu hình tự động thành công!",
    Duration = 3.5,             -- Thời gian hiển thị (giây)
    Type = "Success"            -- "Info" | "Success" | "Warning" | "Error"
})
```

---

## 📜 Mã nguồn mẫu hoàn chỉnh (example.lua)

Dưới đây là mã nguồn template hoàn chỉnh được tổ chức khoa học, bạn có thể sao chép và chỉnh sửa theo nhu cầu của script:

```lua
--!nocheck
local SonLibrary = (function()
    if _G.SonLibrary and _G.SonLibrary.CreateWindow then
        return _G.SonLibrary
    end
    local raw = game:HttpGet("https://raw.githubusercontent.com/hongson209/sonlibrary/refs/heads/main/sonlibrary.lua")
    return loadstring(raw)()
end)()

-- Tạo cửa sổ
local Window = SonLibrary:CreateWindow({
    Title = "SonHUB",
    SubTitle = "Titan Edition",
    AccentColor = Color3.fromRGB(0, 166, 255),
    ToggleKey = Enum.KeyCode.RightControl,
    TopbarButton = true,
    Profile = {
        Enabled = true,
    }
})

-- Tab 1: Tính năng
local MainTab = Window:CreateTab({
    Title = "Tổng quan",
    Icon = "rbxassetid://10723407389"
})

MainTab:CreateSection("Tự động")

MainTab:CreateToggle({
    Name = "Tự động đánh quái",
    Default = true,
    Callback = function(v)
        print("Auto farm:", v)
    end
})

MainTab:CreateSlider({
    Name = "Tốc độ di chuyển",
    Min = 16,
    Max = 200,
    Default = 32,
    Unit = " studs",
    Callback = function(v)
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

MainTab:CreateDropdown({
    Name = "Chế độ săn",
    Options = {"Quái thường", "Tinh anh", "Boss"},
    Default = "Boss",
    Searchable = true,
    Callback = function(opt)
        print("Săn:", opt)
    end
})

-- Tab 2: Cài đặt
local SettingsTab = Window:CreateSettingsTab({
    Title = "Cài đặt"
})

SettingsTab:CreateKeybind({
    Name = "Phím bật/tắt Menu",
    Default = Enum.KeyCode.RightControl,
    Callback = function(k)
        print("Phím menu:", k.Name)
    end
})

SettingsTab:CreateButton({
    Name = "Sao chép link Discord",
    Description = "Tham gia cộng đồng để nhận bản cập nhật mới nhất",
    Callback = function()
        if typeof(setclipboard) == "function" then
            setclipboard("https://discord.gg/htBURFNyhV")
        end
        SonLibrary:Notify({
            Title = "SonHUB",
            Content = "Đã sao chép link Discord vào bộ nhớ tạm!",
            Duration = 3,
            Type = "Success"
        })
    end
})

-- Thông báo chào mừng
SonLibrary:Notify({
    Title = "SonHUB",
    Content = "Giao diện đã khởi động thành công!",
    Duration = 3,
    Type = "Success"
})
```

---

## 💡 Giấy phép & Hỗ trợ (License & Support)

- **Tác giả:** [hongson209](https://github.com/hongson209)
- **Kho lưu trữ:** [github.com/hongson209/sonlibrary](https://github.com/hongson209/sonlibrary)
- **Discord:** [discord.gg/htBURFNyhV](https://discord.gg/htBURFNyhV)
- **Giấy phép:** [MIT License](https://opensource.org/licenses/MIT) — Tự do tích hợp vào bất kỳ Script / Hub nào.
