-- Complete Script Hub Template (Fixed)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ป้องกันเปิดซ้ำ
pcall(function()
	if CoreGui:FindFirstChild("CompleteScriptHub") then
		CoreGui.CompleteScriptHub:Destroy()
	end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CompleteScriptHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
	screenGui.Parent = CoreGui
end)
if not screenGui.Parent then
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

local C = {
	BG = Color3.fromRGB(18, 20, 26),
	Sidebar = Color3.fromRGB(24, 27, 36),
	Card = Color3.fromRGB(30, 34, 45),
	Accent = Color3.fromRGB(235, 65, 85),
	Text = Color3.fromRGB(240, 243, 250),
	Muted = Color3.fromRGB(140, 150, 170),
	Border = Color3.fromRGB(45, 50, 65),
}

local function create(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		obj[k] = v
	end
	obj.Parent = parent
	return obj
end

local function corner(obj, radius)
	create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, obj)
end

-- หน้าต่างหลัก
local window = create("Frame", {
	Size = UDim2.fromOffset(560, 340),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = C.BG,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, screenGui)
corner(window, 12)

create("UIStroke", { Color = C.Border, Thickness = 1 }, window)
local scale = create("UIScale", { Scale = 1 }, window)

-- ปรับสเกลหน้าจออัตโนมัติ
local function updateScale()
	local size = screenGui.AbsoluteSize
	if size.X > 0 and size.Y > 0 then
		scale.Scale = math.clamp(math.min((size.X - 20) / 560, (size.Y - 20) / 340), 0.5, 1)
	end
end
screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale)
task.defer(updateScale)

-- ส่วนหัว (ใช้สำหรับลากหน้าต่าง)
local header = create("TextLabel", {
	Size = UDim2.new(1, -60, 0, 45),
	Position = UDim2.fromOffset(15, 0),
	BackgroundTransparency = 1,
	Text = "BLOX FRUITS  /  HUB SCRIPT",
	TextColor3 = C.Accent,
	TextSize = 16,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
}, window)
header.Active = true

-- ปุ่มย่อเมนู (—)
local minimizeBtn = create("TextButton", {
	Size = UDim2.fromOffset(32, 28),
	Position = UDim2.new(1, -42, 0, 8),
	BackgroundColor3 = C.Card,
	BorderSizePixel = 0,
	Text = "—",
	TextColor3 = C.Text,
	TextSize = 16,
	Font = Enum.Font.GothamBold,
}, window)
corner(minimizeBtn, 6)

create("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.fromOffset(0, 45),
	BackgroundColor3 = C.Border,
	BorderSizePixel = 0,
}, window)

-- แถบสถานะด้านล่าง
local statusLabel = create("TextLabel", {
	Size = UDim2.new(1, -30, 0, 25),
	Position = UDim2.new(0, 15, 1, -28),
	BackgroundTransparency = 1,
	Text = "สถานะ: พร้อมใช้งาน",
	TextColor3 = C.Muted,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
}, window)

-- ปุ่มเปิดเมนูสำรอง (ตอนย่อหน้าต่าง)
local openBtn = create("TextButton", {
	Size = UDim2.fromOffset(100, 36),
	Position = UDim2.fromOffset(15, 15),
	BackgroundColor3 = C.Accent,
	BorderSizePixel = 0,
	Text = "เปิดเมนู",
	TextColor3 = C.Text,
	TextSize = 14,
	Font = Enum.Font.GothamBold,
	Visible = false,
}, screenGui)
corner(openBtn, 8)

local function setVisible(state)
	window.Visible = state
	openBtn.Visible = not state
end

minimizeBtn.Activated:Connect(function() setVisible(false) end)
openBtn.Activated:Connect(function() setVisible(true) end)

-- ระบบแท็บและหน้าเนื้อหา
local sidebar = create("Frame", {
	Size = UDim2.new(0, 130, 1, -85),
	Position = UDim2.fromOffset(12, 56),
	BackgroundColor3 = C.Sidebar,
	BorderSizePixel = 0,
}, window)
corner(sidebar, 8)

local container = create("Frame", {
	Size = UDim2.new(1, -162, 1, -85),
	Position = UDim2.fromOffset(152, 56),
	BackgroundTransparency = 1,
}, window)

local pages = {}
local tabButtons = {}

local function selectTab(name)
	for k, page in pairs(pages) do
		local active = (k == name)
		page.Visible = active
		tabButtons[k].BackgroundColor3 = active and C.Accent or C.Card
		tabButtons[k].TextColor3 = active and C.Text or C.Muted -- แก้ไขจุดที่ตกหล่นตรงนี้แล้ว
	end
end

local function addTab(name, index)
	local btn = create("TextButton", {
		Size = UDim2.new(1, -12, 0, 36),
		Position = UDim2.fromOffset(6, 6 + (index - 1) * 42),
		BackgroundColor3 = C.Card,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = C.Muted,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
	}, sidebar)
	corner(btn, 6)

	local page = create("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
	}, container)

	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, page)

	pages[name] = page
	tabButtons[name] = btn

	btn.Activated:Connect(function() selectTab(name) end)
	return page
end

-- สร้างหน้าต่างๆ
local pHome = addTab("หน้าหลัก", 1)
local pFarm = addTab("ระบบฟาร์ม", 2)
local pSetting = addTab("ตั้งค่า", 3)

local function addLabel(parent, text)
	return create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = C.Text,
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, parent)
end

local function addButton(parent, text, callback)
	local btn = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = C.Card,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = C.Text,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
	}, parent)
	corner(btn, 6)
	btn.Activated:Connect(callback)
	return btn
end

-- เติมเนื้อหาตัวอย่าง
addLabel(pHome, "ยินดีต้อนรับคุณ: " .. player.Name)
addButton(pHome, "พิมพ์ข้อความทักทาย", function()
	statusLabel.Text = "สวัสดีครับ ขอให้สนุกกับการพัฒนาแมพ!"
end)

addLabel(pFarm, "ตั้งค่าระบบออโต้ฟาร์ม")
addButton(pFarm, "เปิดใช้งาน Auto Clicker", function()
	statusLabel.Text = "เปิดระบบ Auto Clicker แล้ว (ตัวอย่าง)"
end)

addLabel(pSetting, "ตั้งค่าระบบเมนู")
addButton(pSetting, "รีเซ็ตตำแหน่งหน้าต่าง", function()
	window.Position = UDim2.fromScale(0.5, 0.5)
	statusLabel.Text = "รีเซ็ตหน้าจอเรียบร้อย"
end)

selectTab("หน้าหลัก")

-- ระบบลากหน้าต่าง (Drag) รองรับทั้งเมาส์และมือถือ
local dragging, dragStart, startPos

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = window.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		window.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

print("Script Hub Loaded Successfully!")
