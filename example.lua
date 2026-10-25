--[[
	========================================================================
	SonLibrary (v3.2) — Official Example & Showcase Script
	Repository: https://github.com/hongson209/sonlibrary
	Raw Link:   https://raw.githubusercontent.com/hongson209/sonlibrary/refs/heads/main/sonlibrary.lua
	
	Features Demonstrated:
	- Dual-Layout Engine: Sidebar (Dock Left) vs Top Tabs
	- Dynamic Styling System: 6 Built-in Presets (Acrylic, Velvet, Slate, etc.)
	- Triple Dropdown Architecture: Mode="Popup", Mode="Inline", Multi=true
	- RGB & HSV ColorPicker with real-time swatch preview
	- Adaptive Keybind Listener (PC & Mobile Touch)
	- Tactile Buttons: Primary (Accent Glow), Danger (Ruby Glow), Secondary
	- Island Acrylic Pill Notification Engine with progress bar
	- Modal Confirmation Dialog (Window:Dialog)
	- WCAG High-Contrast Readability & Mobile Touch Optimization
	========================================================================
--]]

-- 1. Load SonLibrary from GitHub (with offline local fallback for development)
local SonUI = nil
local RAW_URL = "https://raw.githubusercontent.com/hongson209/sonlibrary/refs/heads/main/sonlibrary.lua"

local ok, res = pcall(function()
	if typeof(game) == "Instance" and typeof(game.HttpGet) == "function" then
		return loadstring(game:HttpGet(RAW_URL))()
	end
end)

if ok and typeof(res) == "table" and res.CreateWindow then
	SonUI = res
else
	-- Local offline fallback for testing & development
	local localPaths = { "sonlibrary.lua", "SonHUB/sonlibrary.lua", "SonHUB/SonUI.lua", "Library/SonUI.lua", "SonUI.lua" }
	for _, path in ipairs(localPaths) do
		if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile(path) then
			local lOk, lRes = pcall(function() return loadstring(readfile(path))() end)
			if lOk and typeof(lRes) == "table" and lRes.CreateWindow then
				SonUI = lRes
				break
			end
		end
	end
end

if not SonUI and typeof(getgenv) == "function" then
	SonUI = getgenv().SonLibrary or getgenv().SonUI
end

assert(SonUI, "[SonLibrary Error]: Could not load SonLibrary. Please verify internet connection or local files.")

-- 2. Initialize Main Window
local Window = SonUI:CreateWindow({
	Name = "SonLibraryShowcase",
	Title = "SonLibrary",
	Subtitle = "Universal Executive Framework v3.2",
	Icon = "https://cdn.discordapp.com/attachments/1317065294736265248/1555222187378475029/sonhub.png?backend=b2&ex=6adf6108&is=6ade0f88&hm=6382d2a99fef77485f1e4a6fc43a5093dc9cad400abfd586191115ea1e7f7e50",
	Layout = "Sidebar", -- "Sidebar" (Tab | Content) or "Top" (Horizontal Header Tabs)
	Style = "Acrylic Frosted", -- "Acrylic Frosted", "Midnight Velvet", "Obsidian Slate", "Emerald Oasis", "Sunset Amber", "Rose Quartz"
	Size = UDim2.fromOffset(700, 530),
	ToggleKey = Enum.KeyCode.RightControl,
	Closable = true,
})

-- Welcome Notification
Window:Notify({
	Title = "SonLibrary v3.2 Active",
	Content = "Khung giao diện cao cấp đã tải thành công. Bấm RightControl để ẩn/hiện.",
	Type = "Success",
	Duration = 4,
})

-- =========================================================================
-- TAB 1: DASHBOARD
-- =========================================================================
local DashTab = Window:CreateTab({
	Name = "Dashboard",
	Icon = "Dashboard",
	Description = "Tổng quan & Trạng thái",
})

DashTab:CreateSection("Chào mừng đến với SonLibrary")

DashTab:CreateParagraph({
	Title = "Kiến Trúc UI Hiện Đại & Tối Ưu Cao",
	Content = "SonLibrary được xây dựng theo chuẩn Design System cao cấp với viền kính phát sáng (Glow border), hỗ trợ vuốt chạm cảm ứng mượt mà trên Mobile và co giãn đa màn hình tự động.",
})

DashTab:CreateSection("Thao Tác Nhanh")

DashTab:CreateButton({
	Name = "Gửi Thông Báo Mẫu (Window:Notify)",
	Description = "Thử nghiệm hệ thống thông báo Acrylic Pill với thanh tiến trình",
	Variant = "Primary",
	Callback = function()
		Window:Notify({
			Title = "Thao tác thành công",
			Content = "Hệ thống thông báo hoạt động mượt mà không xung đột layout!",
			Type = "Success",
			Duration = 3.5,
		})
	end,
})

DashTab:CreateButton({
	Name = "Mở Hộp Thoại Xác Nhận (Window:Dialog)",
	Description = "Hộp thoại Modal làm mờ trung tâm với các nút thao tác",
	Variant = "Secondary",
	Callback = function()
		Window:Dialog({
			Title = "Xác nhận tác vụ",
			Content = "Bạn có chắc chắn muốn tiến hành tác vụ này không? Hành động này sẽ được ghi nhận vào nhật ký.",
			Buttons = {
				{
					Title = "Hủy bỏ",
					Variant = "Secondary",
					Callback = function()
						Window:Notify({ Title = "Đã hủy", Content = "Thao tác đã được hủy bỏ an toàn.", Type = "Info", Duration = 2 })
					end,
				},
				{
					Title = "Tiến hành",
					Variant = "Primary",
					Callback = function()
						Window:Notify({ Title = "Thành công", Content = "Tác vụ đã được thực thi!", Type = "Success", Duration = 2 })
					end,
				},
			},
		})
	end,
})

-- =========================================================================
-- TAB 2: COMBAT (Tính năng ngắm bắn & Dropdown Đa Chế Độ)
-- =========================================================================
local CombatTab = Window:CreateTab({
	Name = "Combat",
	Icon = "Combat",
	Description = "Ngắm bắn & Hỏa lực",
})

CombatTab:CreateSection("Chế Độ Dropdown Tiên Tiến (Triple Architecture)")

-- Mode 1: POPUP (Floating Popover - Chuẩn WindUI)
CombatTab:CreateDropdown({
	Name = "Menu Thả Nổi (Mode = 'Popup')",
	Description = "Menu nổi trực tiếp bên dưới nút trigger với viền kính dịu mắt",
	Options = {"Mặc định (Default)", "Bộ sưu tập Sứ", "Bộ sưu tập Rồng Vàng", "Bộ sưu tập Thạch Anh", "Bộ sưu tập Pha Lê"},
	Default = "Mặc định (Default)",
	Mode = "Popup",
	Callback = function(choice)
		Window:Notify({
			Title = "Tùy chọn được chọn",
			Content = "Đã chọn: " .. tostring(choice),
			Type = "Info",
			Duration = 2,
		})
	end,
})

-- Mode 2: INLINE (Accordion Card)
CombatTab:CreateDropdown({
	Name = "Menu Thả Dài Trong Thẻ (Mode = 'Inline')",
	Description = "Menu mở rộng cuộn trực tiếp bên trong thẻ card",
	Options = {"Đầu (Head)", "Thân (UpperTorso)", "Gốc Nhân Vật (HumanoidRootPart)", "Ngẫu Nhiên"},
	Default = "Đầu (Head)",
	Mode = "Inline",
	Callback = function(choice)
		Window:Notify({
			Title = "Bộ phận mục tiêu",
			Content = "Bộ phận ưu tiên: " .. tostring(choice),
			Type = "Info",
			Duration = 2,
		})
	end,
})

-- Mode 3: MULTI-SELECT (Chọn nhiều mục đồng thời)
CombatTab:CreateDropdown({
	Name = "Lọc Mục Tiêu (Multi = true)",
	Description = "Cho phép tick chọn đồng thời nhiều tiêu chí lọc",
	Options = {"Đội Đối Thủ (Enemy)", "Chỉ Mục Tiêu Nhìn Thấy", "Bỏ Qua Khiên", "Ưu Tiên Boss"},
	Default = {"Đội Đối Thủ (Enemy)", "Chỉ Mục Tiêu Nhìn Thấy"},
	Mode = "Popup",
	Multi = true,
	Callback = function(selectedMap)
		-- selectedMap là bảng [TênTùyChọn] = true/false
	end,
})

CombatTab:CreateSection("Điều Khiển Hỏa Lực")

CombatTab:CreateToggle({
	Name = "Silent Aimbot",
	Description = "Tự động điều hướng đường đạn tới mục tiêu ưu tiên",
	Default = true,
	Callback = function(val)
		Window:Notify({
			Title = "Trạng thái Aimbot",
			Content = "Silent Aimbot: " .. (val and "BẬT" or "TẮT"),
			Type = val and "Success" or "Warning",
			Duration = 2,
		})
	end,
})

CombatTab:CreateSlider({
	Name = "Góc Nhìn Khóa Mục Tiêu (FOV)",
	Min = 30,
	Max = 600,
	Default = 160,
	Step = 5,
	Suffix = " px",
	Callback = function(val)
		-- Cập nhật bán kính FOV
	end,
})

CombatTab:CreateButton({
	Name = "Hiệu Chuẩn Đường Đạn Tức Thì",
	Description = "Đồng bộ hóa bảng tính toán độ rơi và vận tốc đạn",
	Variant = "Primary",
	Callback = function()
		Window:Notify({
			Title = "Hiệu chuẩn hoàn tất",
			Content = "Đã đồng bộ hóa bảng tính vận tốc đạn thành công.",
			Type = "Success",
			Duration = 3,
		})
	end,
})

-- =========================================================================
-- TAB 3: MOVEMENT (Tốc độ, Bay & Phím tắt)
-- =========================================================================
local MoveTab = Window:CreateTab({
	Name = "Movement",
	Icon = "Movement",
	Description = "Di chuyển & Vận động",
})

MoveTab:CreateSection("Tùy Biến Vận Tốc")

MoveTab:CreateToggle({
	Name = "Ghi Đè Tốc Độ Đi Bộ (WalkSpeed)",
	Description = "Duy trì tốc độ di chuyển không đổi ngay cả khi bị làm chậm",
	Default = false,
	Callback = function(state)
		-- Kích hoạt WalkSpeed
	end,
})

MoveTab:CreateSlider({
	Name = "Tốc Độ Di Chuyển",
	Min = 16,
	Max = 250,
	Default = 48,
	Step = 2,
	Suffix = " studs/s",
	Callback = function(speed)
		-- Đặt tốc độ
	end,
})

MoveTab:CreateKeybind({
	Name = "Phím Tắt Chạy Nhanh (Sprint)",
	Description = "Bấm phím này để kích hoạt trạng thái siêu tốc độ",
	Default = Enum.KeyCode.LeftShift,
	Callback = function()
		Window:Notify({
			Title = "Phím tắt kích hoạt",
			Content = "Đã bấm phím kích hoạt Super Sprint!",
			Type = "Success",
			Duration = 2,
		})
	end,
})

MoveTab:CreateButton({
	Name = "Dịch Chuyển Khẩn Cấp Về Spawn",
	Description = "Đưa nhân vật an toàn trở về tọa độ điểm xuất phát",
	Variant = "Danger",
	Callback = function()
		Window:Notify({
			Title = "Khẩn cấp",
			Content = "Đang đưa nhân vật về vị trí an toàn...",
			Type = "Danger",
			Duration = 3,
		})
	end,
})

-- =========================================================================
-- TAB 4: VISUALS (Hình ảnh & ESP)
-- =========================================================================
local VisTab = Window:CreateTab({
	Name = "Visuals",
	Icon = "Visuals",
	Description = "Hiển thị & ESP",
})

VisTab:CreateSection("ESP Địch")

VisTab:CreateToggle({
	Name = "Hiển Thị Khung ESP (Box ESP)",
	Description = "Vẽ hộp 2D bao quanh nhân vật đối thủ",
	Default = true,
	Callback = function(val)
		-- Bật/tắt ESP
	end,
})

VisTab:CreateColorPicker({
	Name = "Màu Sắc Viền ESP",
	Description = "Tùy chọn màu sắc hiển thị của khung nhìn xuyên tường",
	Default = Color3.fromRGB(0, 210, 255),
	Callback = function(color)
		-- Đổi màu ESP
	end,
})

VisTab:CreateSlider({
	Name = "Tầm Xa Hiển Thị ESP",
	Min = 50,
	Max = 3000,
	Default = 1000,
	Step = 50,
	Suffix = " m",
	Callback = function(dist)
		-- Cập nhật tầm xa
	end,
})

-- =========================================================================
-- TAB 5: SETTINGS (Giao diện & Cấu hình phong cách)
-- =========================================================================
local SettingsTab = Window:CreateTab({
	Name = "Settings",
	Icon = "Settings",
	Description = "Cấu hình & Giao diện",
})

SettingsTab:CreateSection("Tùy Biến Thẩm Mỹ (Styling & Themes)")

SettingsTab:CreateDropdown({
	Name = "UI Style Preset",
	Description = "Chọn nhanh phong cách thẩm mỹ giao diện",
	Options = {
		"Kính Mờ Dịu (Acrylic Frosted)",
		"Tím Đêm Dịu (Midnight Velvet)",
		"Đá Đen Tối Giản (Obsidian Slate)",
		"Ngọc Lục Bảo (Emerald Oasis)",
		"Hoàng Hôn Ấm (Sunset Amber)",
		"Hồng Thạch Anh (Rose Quartz)",
	},
	Default = "Kính Mờ Dịu (Acrylic Frosted)",
	Mode = "Popup",
	Callback = function(choice)
		Window:SetStyle(choice)
	end,
})

SettingsTab:CreateSlider({
	Name = "Độ Mờ Nền Cửa Sổ (Transparency)",
	Min = 0,
	Max = 0.9,
	Default = 0.12,
	Step = 0.02,
	Callback = function(trans)
		Window:SetBackgroundTransparency(trans)
	end,
})

SettingsTab:CreateSlider({
	Name = "Độ Mờ Sidebar Navigation",
	Min = 0,
	Max = 0.9,
	Default = 0.35,
	Step = 0.05,
	Callback = function(trans)
		Window:SetSidebarTransparency(trans)
	end,
})

SettingsTab:CreateColorPicker({
	Name = "Màu Sắc Điểm Nhấn (Accent Glow)",
	Description = "Thay đổi màu đèn Neon, viền hoạt họa và hiệu ứng ánh sáng",
	Default = Color3.fromRGB(0, 210, 255),
	Callback = function(color)
		Window:SetAccentColor(color)
	end,
})

SettingsTab:CreateColorPicker({
	Name = "Màu Nền Thanh Sidebar",
	Description = "Màu nền của thanh điều hướng dọc bên trái",
	Default = Color3.fromRGB(18, 22, 32),
	Callback = function(color)
		Window:SetSidebarColor(color)
	end,
})

SettingsTab:CreateSection("Hệ Thống")

SettingsTab:CreateKeybind({
	Name = "Phím Ẩn/Hiện Menu",
	Description = "Bấm phím để ẩn hoặc hiển thị lại toàn bộ giao diện",
	Default = Enum.KeyCode.RightControl,
	OnChanged = function(newKey)
		Window:SetToggleKey(newKey)
		Window:Notify({
			Title = "Đã đổi phím tắt",
			Content = "Phím mở menu mới: " .. newKey.Name,
			Type = "Info",
			Duration = 2,
		})
	end,
})

SettingsTab:CreateButton({
	Name = "Đóng & Hủy Thư Viện (Window:Destroy)",
	Description = "Gỡ bỏ hoàn toàn giao diện khỏi bộ nhớ ScreenGui",
	Variant = "Danger",
	Callback = function()
		Window:Dialog({
			Title = "Gỡ bỏ giao diện?",
			Content = "Bạn có chắc chắn muốn đóng và hủy thư viện khỏi bộ nhớ không?",
			Buttons = {
				{ Title = "Hủy", Variant = "Secondary" },
				{
					Title = "Gỡ bỏ",
					Variant = "Danger",
					Callback = function()
						Window:Destroy()
					end,
				},
			},
		})
	end,
})
