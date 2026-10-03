-- UI Path Finder & Scanner Tool
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. إنشاء الواجهة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UI_PathFinder_GUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 400)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -200) -- منتصف الشاشة
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18) -- واجهة سوداء
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- شريط العنوان (قابل للتحريك بالأصبع)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "UI Scanner (0 Found)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- زر التحديث Refresh
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 70, 0, 28)
RefreshBtn.Position = UDim2.new(1, -78, 0.5, -14)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
RefreshBtn.Text = "Refresh"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.TextSize = 11
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.Parent = TitleBar

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = RefreshBtn

-- قائمة التمرير (Scroll Frame)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- 2. تحريك الواجهة بالسحب بالأصبع أو الماوس
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- 3. دالة استخراج المسار الكامل للعنصر (Get Full Path)
local function getFullPath(instance)
    local path = instance.Name
    local current = instance.Parent

    while current and current ~= game do
        path = current.Name .. "." .. path
        current = current.Parent
    end

    return path
end

-- 4. دالة نسخ النص إلى الحافظة (Clipboard)
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    else
        print("Full Path: " .. text)
    end
end

-- 5. دالة فحص وتجميد الـ UI الظاهرة
local function scanUI()
    -- مسح القائمة القديمة
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local foundUIs = {}

    -- فحص PlayerGui
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui ~= ScreenGui then
            table.insert(foundUIs, gui)
        end
    end

    -- فحص CoreGui إن أمكن
    pcall(function()
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                table.insert(foundUIs, gui)
            end
        end
    end)

    -- تحديث العداد من فوق
    TitleLabel.Text = "UI Scanner (" .. tostring(#foundUIs) .. " Found)"

    -- إدراج العناصر في القائمة
    for _, gui in pairs(foundUIs) do
        local fullPath = getFullPath(gui)

        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(1, 0, 0, 52)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        ItemFrame.BorderSizePixel = 0
        ItemFrame.Parent = ScrollFrame

        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 6)
        ItemCorner.Parent = ItemFrame

        -- اسم الـ UI
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, -75, 0, 20)
        NameLabel.Position = UDim2.new(0, 10, 0, 6)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = gui.Name
        NameLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        NameLabel.TextSize = 12
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = ItemFrame

        -- المسار الكامل
        local PathLabel = Instance.new("TextLabel")
        PathLabel.Size = UDim2.new(1, -75, 0, 20)
        PathLabel.Position = UDim2.new(0, 10, 0, 26)
        PathLabel.BackgroundTransparency = 1
        PathLabel.Text = fullPath
        PathLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
        PathLabel.TextSize = 10
        PathLabel.Font = Enum.Font.Gotham
        PathLabel.TextXAlignment = Enum.TextXAlignment.Left
        PathLabel.TextTruncate = Enum.TextTruncate.AtEnd
        PathLabel.Parent = ItemFrame

        -- زر النسخ
        local CopyBtn = Instance.new("TextButton")
        CopyBtn.Size = UDim2.new(0, 55, 0, 32)
        CopyBtn.Position = UDim2.new(1, -62, 0.5, -16)
        CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        CopyBtn.Text = "Copy"
        CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CopyBtn.TextSize = 11
        CopyBtn.Font = Enum.Font.GothamBold
        CopyBtn.Parent = ItemFrame

        local CopyCorner = Instance.new("UICorner")
        CopyCorner.CornerRadius = UDim.new(0, 6)
        CopyCorner.Parent = CopyBtn

        CopyBtn.MouseButton1Click:Connect(function()
            copyToClipboard(fullPath)
            CopyBtn.Text = "Copied!"
            CopyBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
            task.wait(1)
            CopyBtn.Text = "Copy"
            CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        end)
    end
end

RefreshBtn.MouseButton1Click:Connect(scanUI)

-- إجراء الفحص الأول التلقائي عند التشغيل
scanUI()
