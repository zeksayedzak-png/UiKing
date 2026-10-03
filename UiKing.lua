-- Path Sniper with Smooth Scrollable List & Quick Tools
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. إنشاء الشاشة الأساسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PathSniper_ScrollGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- 2. المربع الأسود الرئيسي (القائمة)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.02, 0, 0.25, 0) -- يسار الشاشة
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- يمكنك تحريك القائمة بأي مكان
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = MainFrame

-- العنوان العلوي
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
Title.Text = " 🎯 PATH SNIPER"
Title.TextColor3 = Color3.fromRGB(0, 230, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- زر Research / Refresh
local ResearchBtn = Instance.new("TextButton")
ResearchBtn.Size = UDim2.new(0, 100, 0, 26)
ResearchBtn.Position = UDim2.new(1, -210, 0, 4.5)
ResearchBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 240)
ResearchBtn.Text = "🔍 Research"
ResearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResearchBtn.TextSize = 10
ResearchBtn.Font = Enum.Font.GothamBold
ResearchBtn.Parent = Title

local RCorner = Instance.new("UICorner")
RCorner.CornerRadius = UDim.new(0, 5)
RCorner.Parent = ResearchBtn

-- زر GMP (الجديد فقط)
local GMPBtn = Instance.new("TextButton")
GMPBtn.Size = UDim2.new(0, 95, 0, 26)
GMPBtn.Position = UDim2.new(1, -102, 0, 4.5)
GMPBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 210)
GMPBtn.Text = "⚡ GMP"
GMPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GMPBtn.TextSize = 10
GMPBtn.Font = Enum.Font.GothamBold
GMPBtn.Parent = Title

local GCorner = Instance.new("UICorner")
GCorner.CornerRadius = UDim.new(0, 5)
GCorner.Parent = GMPBtn

-- 3. مربع التمرير (ScrollingFrame) معالجة مشكلة الثبات
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -16, 1, -50)
ScrollList.Position = UDim2.new(0, 8, 0, 42)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0) -- سيتعدل تلقائياً
ScrollList.ScrollBarThickness = 6
ScrollList.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollList

-- تحديث حجم التمرير تلقائياً عند إضافة أي عنصر عشان ترفع وتنزل براحتك
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- 4. الدوال والخدمات
local function getFullPath(obj)
    local path = obj.Name
    local parent = obj.Parent
    while parent and parent ~= game do
        if string.match(parent.Name, "[^%w_]") then
            path = '["' .. parent.Name .. '"].' .. path
        else
            path = parent.Name .. "." .. path
        end
        parent = parent.Parent
    end
    return "game." .. path
end

local function copyPath(text)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    else
        print("Path: " .. text)
    end
end

local registeredObjects = {}

-- دالة إضافة عنصر داخل القائمة السوداء
local function addEntryToList(obj)
    local fullPath = getFullPath(obj)

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 32)
    row.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    row.BorderSizePixel = 0
    row.Parent = ScrollList

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 5)
    rowCorner.Parent = row

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -85, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = obj.Name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = row

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 70, 0, 22)
    copyBtn.Position = UDim2.new(1, -74, 0.5, -11)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
    copyBtn.Text = "Copy Path"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.TextSize = 9
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.Parent = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = copyBtn

    copyBtn.MouseButton1Click:Connect(function()
        copyPath(fullPath)
        copyBtn.Text = "Copied!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
        task.wait(0.8)
        copyBtn.Text = "Copy Path"
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
    end)
end

local function clearList()
    for _, child in pairs(ScrollList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

-- جلب العناصر
local function getAllObjects()
    local list = {}
    for _, desc in pairs(Workspace:GetDescendants()) do
        if desc ~= Workspace.CurrentCamera and not desc:IsA("Terrain") and desc ~= LocalPlayer.Character and not desc:IsDescendantOf(LocalPlayer.Character) then
            table.insert(list, desc)
        end
    end
    return list
end

-- زر Research
ResearchBtn.MouseButton1Click:Connect(function()
    clearList()
    registeredObjects = {}

    local objects = getAllObjects()
    for _, obj in pairs(objects) do
        registeredObjects[obj] = true
        addEntryToList(obj)
    end

    -- نزول التمرير لآسفل القائمة لرؤية أحدث الأشياء تلقائياً
    task.wait(0.1)
    ScrollList.CanvasPosition = Vector2.new(0, ScrollList.CanvasSize.Y.Offset)
end)

-- زر GMP (الجديد فقط)
GMPBtn.MouseButton1Click:Connect(function()
    clearList()

    local currentObjects = getAllObjects()
    local newObjects = {}

    for _, obj in pairs(currentObjects) do
        if not registeredObjects[obj] then
            table.insert(newObjects, obj)
        end
    end

    registeredObjects = {}
    for _, obj in pairs(currentObjects) do
        registeredObjects[obj] = true
    end

    for _, obj in pairs(newObjects) do
        addEntryToList(obj)
    end

    -- الانقاذ للأسفل لرؤية الجديد
    task.wait(0.1)
    ScrollList.CanvasPosition = Vector2.new(0, ScrollList.CanvasSize.Y.Offset)
end)
