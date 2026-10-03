-- World 3D Tracker & Path Finder
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. إنشاء الواجهة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WorldPathTrackerGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 380)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -190) -- منتصف الشاشة
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18) -- سوداء
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- شريط العنوان (سحب بالأصبع أو الماوس)
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
TitleLabel.Text = "World Tracker (0 Found)"
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

-- قائمة العناصر
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

-- 2. تحريك الواجهة بالسحب
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

-- 3. دالة استخراج المسار الكامل
local function getFullPath(instance)
    local path = instance.Name
    local current = instance.Parent

    while current and current ~= game do
        path = current.Name .. "." .. path
        current = current.Parent
    end

    return path
end

-- 4. نسخ النص
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    else
        print("Path: " .. text)
    end
end

-- 5. إدارة الـ Highlights والعلامات الشفافة المتتبعة
local activeTrackers = {}

local function removeTracker(target)
    if activeTrackers[target] then
        if activeTrackers[target].Highlight then activeTrackers[target].Highlight:Destroy() end
        if activeTrackers[target].Billboard then activeTrackers[target].Billboard:Destroy() end
        activeTrackers[target] = nil
    end
end

local function addTracker(target)
    if activeTrackers[target] then
        removeTracker(target)
        return false
    end

    -- 1) التظليل الشفاف
    local highlight = Instance.new("Highlight")
    highlight.Adornee = target
    highlight.FillColor = Color3.fromRGB(0, 255, 150)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = target

    -- 2) النص الشفاف المتحرك عبر الكاميرا
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = target:IsA("BasePart") and target or (target:FindFirstChildWhichIsA("BasePart", true) or target)
    billboard.Size = UDim2.new(0, 150, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 150)
    label.TextStrokeTransparency = 0
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.Text = target.Name
    label.Parent = billboard

    activeTrackers[target] = {
        Highlight = highlight,
        Billboard = billboard
    }
    return true
end

-- 6. التحديث وفحص المسار الحالي
local function updateList()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local items = Workspace:GetChildren()
    TitleLabel.Text = "World Tracker (" .. tostring(#items) .. ")"

    for _, item in pairs(items) do
        if item ~= Workspace.CurrentCamera and not item:IsA("Terrain") then
            local fullPath = getFullPath(item)

            local ItemFrame = Instance.new("Frame")
            ItemFrame.Size = UDim2.new(1, 0, 0, 50)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
            ItemFrame.BorderSizePixel = 0
            ItemFrame.Parent = ScrollFrame

            local ItemCorner = Instance.new("UICorner")
            ItemCorner.CornerRadius = UDim.new(0, 6)
            ItemCorner.Parent = ItemFrame

            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -120, 0, 20)
            NameLabel.Position = UDim2.new(0, 10, 0, 5)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = item.Name
            NameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            NameLabel.TextSize = 12
            NameLabel.Font = Enum.Font.GothamBold
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = ItemFrame

            local PathLabel = Instance.new("TextLabel")
            PathLabel.Size = UDim2.new(1, -120, 0, 18)
            PathLabel.Position = UDim2.new(0, 10, 0, 25)
            PathLabel.BackgroundTransparency = 1
            PathLabel.Text = fullPath
            PathLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            PathLabel.TextSize = 10
            PathLabel.Font = Enum.Font.Gotham
            PathLabel.TextXAlignment = Enum.TextXAlignment.Left
            PathLabel.TextTruncate = Enum.TextTruncate.AtEnd
            PathLabel.Parent = ItemFrame

            -- زر التتبع الشفاف (Track)
            local TrackBtn = Instance.new("TextButton")
            TrackBtn.Size = UDim2.new(0, 50, 0, 28)
            TrackBtn.Position = UDim2.new(1, -112, 0.5, -14)
            TrackBtn.Text = "Track"
            TrackBtn.TextSize = 11
            TrackBtn.Font = Enum.Font.GothamBold
            TrackBtn.Parent = ItemFrame

            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(0, 6)
            TrackCorner.Parent = TrackBtn

            if activeTrackers[item] then
                TrackBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                TrackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                TrackBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                TrackBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end

            TrackBtn.MouseButton1Click:Connect(function()
                local active = addTracker(item)
                if active then
                    TrackBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    TrackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    TrackBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                    TrackBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end)

            -- زر النسخ (Copy)
            local CopyBtn = Instance.new("TextButton")
            CopyBtn.Size = UDim2.new(0, 50, 0, 28)
            CopyBtn.Position = UDim2.new(1, -56, 0.5, -14)
            CopyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
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
                CopyBtn.Text = "Done"
                task.wait(1)
                CopyBtn.Text = "Copy"
            end)
        end
    end
end

RefreshBtn.MouseButton1Click:Connect(updateList)

-- أول فحص
updateList()
