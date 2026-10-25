# 🌟 SonLibrary (v3.2) — Universal UI Framework

<p align="center">
  <img src="https://cdn.discordapp.com/attachments/1317065294736265248/1555222187378475029/sonhub.png?backend=b2&ex=6adf6108&is=6ade0f88&hm=6382d2a99fef77485f1e4a6fc43a5093dc9cad400abfd586191115ea1e7f7e50" width="128" height="128" alt="SonLibrary Logo" />
</p>

<p align="center">
  <strong>Một thư viện UI Roblox cao cấp, chuẩn hóa Design System hiện đại với hiệu ứng Acrylic Frosted Glass, hỗ trợ mượt mà cả PC lẫn Mobile.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Version-3.2.0-00d2ff.svg?style=for-the-badge" alt="Version 3.2.0" />
  <img src="https://img.shields.io/badge/Language-Luau-00A2FF.svg?style=for-the-badge&logo=lua" alt="Luau" />
  <img src="https://img.shields.io/badge/Platform-Roblox-white.svg?style=for-the-badge&logo=roblox" alt="Roblox" />
  <img src="https://img.shields.io/badge/Mobile-Optimized-10B981.svg?style=for-the-badge" alt="Mobile Optimized" />
  <img src="https://img.shields.io/badge/License-MIT-F59E0B.svg?style=for-the-badge" alt="MIT License" />
</p>

---

## 📑 Mục Lục (Table of Contents)
1. [Điểm Nổi Bật (Key Features)](#-điểm-nổi-bật-key-features)
2. [Cài Đặt Nhanh (Quickstart)](#-cài-đặt-nhanh-quickstart)
3. [Tài Liệu API Chi Tiết (API Reference)](#-tài-liệu-api-chi-tiết-api-reference)
   - [Khởi Tạo Cửa Sổ (`SonUI:CreateWindow`)](#1-khởi-tạo-cửa-sổ-sonuicreatewindow)
   - [Tạo Tab (`Window:CreateTab`)](#2-tạo-tab-windowcreatetab)
   - [Nút Bấm Thao Tác (`Tab:CreateButton`)](#3-nút-bấm-thao-tác-tabcreatebutton)
   - [Công Tắc (`Tab:CreateToggle`)](#4-công-tắc-tabcreatetoggle)
   - [Thanh Trượt (`Tab:CreateSlider`)](#5-thanh-trượt-tabcreateslider)
   - [Menu Thả Xuống Đa Chế Độ (`Tab:CreateDropdown`)](#6-menu-thả-xuống-đa-chế-độ-tabcreatedropdown)
   - [Lắng Nghe Phím Tắt (`Tab:CreateKeybind`)](#7-lắng-nghe-phím-tắt-tabcreatekeybind)
   - [Bảng Chọn Màu Sắc (`Tab:CreateColorPicker`)](#8-bảng-chọn-màu-sắc-tabcreatecolorpicker)
   - [Khung Nhập Liệu (`Tab:CreateInput`)](#9-khung-nhập-liệu-tabcreateinput)
   - [Đoạn Văn Bản (`Tab:CreateParagraph`)](#10-đoạn-văn-bản-tabcreateparagraph)
   - [Hệ Thống Thông Báo (`Window:Notify`)](#11-hệ-thống-thông-báo-windownotify)
   - [Hộp Thoại Xác Nhận (`Window:Dialog`)](#12-hộp-thoại-xác-nhận-windowdialog)
4. [Hệ Thống Phong Cách Giao Diện (Theme Presets)](#-hệ-thống-phong-cách-giao-diện-theme-presets)
5. [Tối Ưu Cảm Ứng Mobile (Mobile Touch Engine)](#-tối-ưu-cảm-ứng-mobile-mobile-touch-engine)
6. [Danh Mục Biểu Tượng (Lucide SVG Icons)](#-danh-mục-biểu-tượng-lucide-svg-icons)

---

## 💎 Điểm Nổi Bật (Key Features)

- 🪟 **Acrylic Frosted Glassmorphism**: Bề mặt kính mờ sang trọng, viền phát sáng dịu mắt (soft border glow) chuẩn tương phản cao WCAG AAA.
- 📱 **100% Mobile Touch Friendly**: Vùng chạm >= 48px theo chuẩn Apple HIG, hỗ trợ kéo vuốt êm ái, chống văng cửa sổ ra khỏi màn hình cảm ứng.
- 📐 **Dual-Layout Architecture**: Tự do chuyển đổi giữa bố cục **Sidebar** (Dock điều hướng dọc bên trái) và **Top Tabs** (Thanh tab phía trên).
- 🔽 **Triple Dropdown System**:
  - `Mode = "Popup"`: Popover thả nổi chuẩn WindUI, neo trực tiếp dưới nút bấm.
  - `Mode = "Inline"`: Mở rộng cuộn mượt mà ngay trong lòng thẻ card.
  - `Multi = true`: Tick chọn cùng lúc nhiều tùy chọn với huy hiệu số lượng động.
- 🔔 **Sonner / Island Pill Notifications**: Hệ thống thông báo viên thuốc Acrylic 2 tầng chống giật lag, tự động reflow trượt dồn lên êm dịu khi đóng.
- 🎨 **HSV & RGB ColorPicker**: Trực quan hóa quang phổ màu với thanh trượt Hue, mã hex và bảng màu preset.
- ⌨️ **Smart Keybind Listener**: Nhận diện phím bấm thông minh, tự động lưu và gọi callback tức thì.
- 🛡️ **Zero-Conflict Native Execution**: Tương thích hoàn hảo với CoreGui / HiddenUI (`gethui`), không để lại rác bộ nhớ.

---

## 🚀 Cài Đặt Nhanh (Quickstart)

Chỉ cần một dòng `loadstring` duy nhất trong script của bạn:

```lua
local SonUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/hongson209/sonlibrary/refs/heads/main/sonlibrary.lua"))()

local Window = SonUI:CreateWindow({
    Title = "SonLibrary",
    Subtitle = "Universal Executive Suite v3.2",
    Icon = "https://cdn.discordapp.com/attachments/1317065294736265248/1555222187378475029/sonhub.png?backend=b2&ex=6adf6108&is=6ade0f88&hm=6382d2a99fef77485f1e4a6fc43a5093dc9cad400abfd586191115ea1e7f7e50",
    Layout = "Sidebar", -- "Sidebar" hoặc "Top"
    Style = "Acrylic Frosted",
    Size = UDim2.fromOffset(700, 530),
})
```

---

## 📖 Tài Liệu API Chi Tiết (API Reference)

### 1. Khởi Tạo Cửa Sổ (`SonUI:CreateWindow`)

```lua
local Window = SonUI:CreateWindow({
    Name = "MyHub",                           -- Tên định danh (Tùy chọn)
    Title = "SonLibrary",                     -- Tiêu đề lớn
    Subtitle = "Universal Suite v3.2",        -- Phụ đề
    Icon = "sonhub.png",                      -- URL hoặc đường dẫn logo (Mặc định logo SonHub)
    Layout = "Sidebar",                       -- "Sidebar" (Mặc định) hoặc "Top"
    Style = "Acrylic Frosted",                -- Tên phong cách mặc định
    Size = UDim2.fromOffset(700, 530),        -- Kích thước cửa sổ (Tự động thích ứng trên Mobile)
    ToggleKey = Enum.KeyCode.RightControl,    -- Phím tắt ẩn/hiện menu
    Closable = true,                          -- Cho phép nút [X] đóng cửa sổ
})
```

#### Các Phương Thức Của Cửa Sổ (`Window Methods`):
| Phương thức | Tham số | Mô tả |
| :--- | :--- | :--- |
| `Window:Toggle()` | Không | Đảo trạng thái Ẩn/Hiện của cửa sổ |
| `Window:SetVisible(bool)` | `boolean` | Đặt trực tiếp trạng thái hiển thị |
| `Window:SetLayout(mode)` | `"Sidebar"` / `"Top"` | Đổi bố cục thanh Tab tức thì |
| `Window:SetStyle(name)` | `string` / `table` | Chuyển đổi theme phong cách giao diện |
| `Window:SetAccentColor(col)` | `Color3` | Đổi màu đèn Neon / Accent glow |
| `Window:SetBackgroundTransparency(t)` | `number (0 - 1)` | Đổi độ trong suốt của cửa sổ chính |
| `Window:SetSidebarTransparency(t)` | `number (0 - 1)` | Đổi độ trong suốt của dock Sidebar |
| `Window:SetToggleKey(keyCode)` | `Enum.KeyCode` | Đổi phím tắt ẩn/hiện |
| `Window:Destroy()` | Không | Hủy toàn bộ UI khỏi bộ nhớ game |

---

### 2. Tạo Tab (`Window:CreateTab`)

```lua
local Tab = Window:CreateTab({
    Name = "Combat",                          -- Tên Tab
    Icon = "Combat",                          -- Tên icon Lucide (Combat, Movement, Visuals, Settings...)
    Description = "Targeting & Aim Assist",   -- Mô tả ngắn hiển thị ở chế độ Top Tab
})
```

---

### 3. Nút Bấm Thao Tác (`Tab:CreateButton`)

Hỗ trợ 3 biến thể màu sắc cao cấp:
- `"Primary"`: Thẻ kính phát sáng màu Accent kèm huy hiệu mũi tên `>` nổi bật.
- `"Danger"`: Thẻ kính cảnh báo màu đỏ Ruby phát sáng kèm huy hiệu `>`.
- `"Secondary"`: Thẻ chuẩn kính mờ tối giản.

```lua
local MyButton = Tab:CreateButton({
    Name = "Trigger Instant Calibration",
    Description = "Recalculates bullet velocity drop tables",
    Variant = "Primary",                      -- "Primary", "Danger", hoặc "Secondary" (Mặc định)
    Callback = function()
        print("Nút đã được bấm!")
    end,
})

MyButton:SetText("Tên nút mới")
```

---

### 4. Công Tắc (`Tab:CreateToggle`)

```lua
local MyToggle = Tab:CreateToggle({
    Name = "Silent Aimbot",
    Description = "Redirects hitscan projectiles towards target",
    Default = true,                           -- Trạng thái ban đầu
    Callback = function(state)
        print("Aimbot:", state)
    end,
})

MyToggle:Set(false)                           -- Đặt trạng thái qua code
local isEnabled = MyToggle:Get()              -- Lấy giá trị hiện tại
```

---

### 5. Thanh Trượt (`Tab:CreateSlider`)

Hỗ trợ chạm vuốt mượt mà trên Mobile và click kéo chuột trên PC.

```lua
local MySlider = Tab:CreateSlider({
    Name = "Field of View",
    Min = 30,
    Max = 600,
    Default = 160,
    Step = 5,
    Suffix = " px",                           -- Hậu tố đơn vị (px, studs, %, v.v.)
    Callback = function(val)
        print("FOV:", val)
    end,
})

MySlider:Set(200)                             -- Đặt giá trị
local val = MySlider:Get()                    -- Đọc giá trị
```

---

### 6. Menu Thả Xuống Đa Chế Độ (`Tab:CreateDropdown`)

#### Chế độ 1: Menu Nổi (`Mode = "Popup"`)
Menu popover nổi trực tiếp dưới nút bấm với bo góc và viền mờ tinh tế:

```lua
Tab:CreateDropdown({
    Name = "Aim Bone Priority",
    Description = "Select target hitscan bone",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    Default = "Head",
    Mode = "Popup",
    Callback = function(choice)
        print("Đã chọn:", choice)
    end,
})
```

#### Chế độ 2: Thả Dài Trong Thẻ (`Mode = "Inline"`)
Thẻ card tự động mở rộng chiều cao theo chuyển động lò xo và cuộn mượt mà:

```lua
Tab:CreateDropdown({
    Name = "Game Configurations",
    Options = {"Config 1", "Config 2", "Config 3", "Config 4"},
    Default = "Config 1",
    Mode = "Inline",
    Callback = function(choice) end,
})
```

#### Chế độ 3: Chọn Nhiều Mục (`Multi = true`)

```lua
local MultiDrop = Tab:CreateDropdown({
    Name = "Target Filters",
    Description = "Select multiple filters simultaneously",
    Options = {"Enemy Team", "Visible Only", "Ignore Shields", "Priority Boss"},
    Default = {"Enemy Team", "Visible Only"},
    Mode = "Popup",
    Multi = true,
    Callback = function(selectedMap)
        -- selectedMap = { ["Enemy Team"] = true, ["Visible Only"] = true, ... }
    end,
})

MultiDrop:Refresh({"Tùy chọn mới 1", "Tùy chọn mới 2"}) -- Cập nhật danh sách tùy chọn
```

---

### 7. Lắng Nghe Phím Tắt (`Tab:CreateKeybind`)

```lua
local MyBind = Tab:CreateKeybind({
    Name = "Super Sprint Key",
    Description = "Press key to toggle super sprint mode",
    Default = Enum.KeyCode.LeftShift,
    Callback = function()
        print("Phím tắt vừa được ấn!")
    end,
    OnChanged = function(newKey)
        print("Người dùng đã đổi phím sang:", newKey.Name)
    end,
})

MyBind:Set(Enum.KeyCode.F)                    -- Đặt lại phím tắt qua code
```

---

### 8. Bảng Chọn Màu Sắc (`Tab:CreateColorPicker`)

Bảng màu popup đầy đủ bảng quang phổ HSV, thanh chỉnh Hue và các ô màu preset:

```lua
local MyColor = Tab:CreateColorPicker({
    Name = "Chams ESP Color",
    Description = "Color used for enemy highlighting",
    Default = Color3.fromRGB(0, 210, 255),
    Callback = function(color)
        print("Màu mới:", color)
    end,
})

MyColor:Set(Color3.fromRGB(255, 100, 100))    -- Đổi màu qua code
```

---

### 9. Khung Nhập Liệu (`Tab:CreateInput`)

```lua
local MyInput = Tab:CreateInput({
    Name = "Custom Webhook URL",
    Description = "Enter Discord webhook URL for logging",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(text)
        print("Đã nhập:", text)
    end,
})

MyInput:Set("Giá trị mới")
```

---

### 10. Đoạn Văn Bản (`Tab:CreateParagraph`)

```lua
local Paragraph = Tab:CreateParagraph({
    Title = "Lưu Ý Quan Trọng",
    Content = "Hãy đảm bảo cấu hình đúng phím tắt và không chia sẻ webhook cá nhân.",
})

Paragraph:SetTitle("Tiêu đề mới")
Paragraph:SetContent("Nội dung mới")
```

---

### 11. Hệ Thống Thông Báo (`Window:Notify`)

Thông báo dạng viên thuốc Acrylic Island trượt ngang từ mép phải với thanh đếm ngược thời gian và hiệu ứng reflow tự động dồn lên khi đóng:

```lua
Window:Notify({
    Title = "Thông Báo Thành Công",
    Content = "Dữ liệu đã được lưu trữ thành công vào bộ nhớ đám mây.",
    Type = "Success",                         -- "Success", "Info", "Warning", "Danger"
    Duration = 3.5,                           -- Thời gian tồn tại (giây)
})
```

---

### 12. Hộp Thoại Xác Nhận (`Window:Dialog`)

Hộp thoại Modal làm mờ phông nền trung tâm:

```lua
Window:Dialog({
    Title = "Xác nhận khôi phục cài đặt?",
    Content = "Tất cả các cấu hình tùy biến sẽ bị xóa và đưa về mặc định.",
    Buttons = {
        {
            Title = "Hủy bỏ",
            Variant = "Secondary",
            Callback = function()
                print("Đã hủy")
            end,
        },
        {
            Title = "Xác nhận",
            Variant = "Danger",
            Callback = function()
                print("Đã xác nhận")
            end,
        },
    },
})
```

---

## 🎨 Hệ Thống Phong Cách Giao Diện (Theme Presets)

SonLibrary tích hợp sẵn 6 phong cách thẩm mỹ dịu mắt, chuyển đổi nhanh qua `Window:SetStyle(name)`:

| Tên Preset | Mô Tả Thẩm Mỹ | Màu Nền Chính |
| :--- | :--- | :--- |
| **`"Acrylic Frosted"`** | Kính mờ hiện đại, dịu mắt, độ hòa quyện cao | `#0D1018` (Trans: 0.28) |
| **`"Midnight Velvet"`** | Tím đêm sang trọng huyền bí | `#100E1C` (Trans: 0.25) |
| **`"Obsidian Slate"`** | Đá đen than chì tối giản độ tương phản cao | `#0A0D12` (Trans: 0.12) |
| **`"Emerald Oasis"`** | Xanh ngọc lục bảo tươi mát | `#081412` (Trans: 0.22) |
| **`"Sunset Amber"`** | Hoàng hôn cam hổ phách ấm áp | `#160F0C` (Trans: 0.25) |
| **`"Rose Quartz"`** | Hồng thạch anh quý phái | `#180D15` (Trans: 0.25) |

---

## 📱 Tối Ưu Cảm Ứng Mobile (Mobile Touch Engine)

SonLibrary được kiểm định kỹ lưỡng trên màn hình điện thoại và máy tính bảng:
- **Tự Động Tính Toán Hình Học**: Hàm `CalculateWindowGeometry` tự động nhận biết chiều rộng màn hình:
  - Dưới 768px: Tự động chuyển sang chế độ Compact Mobile với dock sidebar 60px.
  - Dưới 600px: Tự động co chữ và padding, chống tràn viền.
- **Kéo Thả Chống Văng (Zero-Jerk Dragging)**: Tính toán theo offset tuyệt đối, không bị giật vị trí khi bắt đầu chạm ngón tay.
- **Scrolling Mượt Mà**: Canvas cuộn với độ trễ thấp, không nuốt sự kiện bấm của thẻ con.

---

## 🏷️ Danh Mục Biểu Tượng (Lucide SVG Icons)

Thư viện sử dụng 100% biểu tượng vector sắc nét từ bộ icon chuẩn Lucide (không dùng Emoji hay font dễ lỗi):

`"Dashboard"`, `"Combat"`, `"Visuals"`, `"Movement"`, `"Settings"`, `"Check"`, `"Close"`, `"Minimize"`, `"Maximize"`, `"ChevronDown"`, `"ChevronRight"`, `"Search"`, `"Sliders"`, `"Save"`, `"Key"`, `"Color"`, `"Info"`

---

## 📄 Bản Quyền (License)

Dự án được phân phối dưới giấy phép **MIT License**. Bạn có toàn quyền sử dụng, sửa đổi và tích hợp vào các script cá nhân hoặc thương mại.

<p align="center">
  Được phát triển với sự tỉ mỉ bởi <strong>hongson209</strong> • 2026
</p>
