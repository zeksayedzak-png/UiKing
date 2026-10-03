-- Path Sniper GUI (Full Working Interface)
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. الشاشة الأساسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PathSniperMaster_GUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- 2. المربع الأسود الرئيسي (الواجهة الكاملة)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 400)
MainFrame.Position = UDim2.new(0.5, -170, 0.3, 0) -- منتصف الشاشة
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- تحريك المربع الأسود بأي مكان
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- الشريط العلوي والعنوان
local TopTitle = Instance.new("TextLabel")
TopTitle.Size = UDim2.new(1, 0, 0, 40)
TopTitle.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
TopTitle.Text = "  🎯 Path Sniper & Tracker"
TopTitle.TextColor3 = Color3.fromRGB(0, 230, 255)
TopTitle.TextSize = 13
TopTitle.Font = Enum.Font.GothamBold
TopTitle.TextXAlignment = Enum.TextXAlignment.Left
TopTitle.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TopTitle

-- زر Research (داخل المربع الأسود)
local ResearchBtn = Instance.new("TextButton")
ResearchBtn.Size = UDim2.new(0, 90, 0, 28)
ResearchBtn.Position = UDim2.new(1, -195, 0, 6)
ResearchBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 240)
ResearchBtn.Text = "🔍 Research"
ResearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResearchBtn.TextSize = 10
ResearchBtn.Font = Enum.Font.GothamBold
ResearchBtn.Parent = TopTitle

local RCorner = Instance.new("UICorner")
RCorner.CornerRadius = UDim.new(0, 5)
RCorner.Parent = ResearchBtn

-- زر GMP (داخل المربع الأسود)
local GMPBtn = Instance.new("TextButton")
GMPBtn.Size = UDim2.new(0, 90, 0, 28)
GMPBtn.Position = UDim2.new(1, -98, 0, 6)
GMPBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 210)
GMPBtn.Text = "⚡ GMP"
GMPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GMPBtn.TextSize = 10
GMPBtn.Font = Enum.Font.GothamBold
GMPBtn.Parent = TopTitle

local GCorner = Instance.new("UICorner")
GCorner.CornerRadius = UDim.new(0, 5)
GCorner.Parent = GMPBtn

-- 3. قائمة التمرير والرفع داخل المربع الأسود
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -16, 1, -50)
ScrollList.Position = UDim2.new(0, 8, 0, 45)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollList.ScrollBarThickness = 6
ScrollList.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollList

-- تعديل التمرير التلقائي للأسفل والأعلى
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

local function addEntryToList(obj)
    local fullPath = getFullPath(obj)

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 32)
    row.BackgroundColor3 = Color3.fromRGB(25, 25, 36)
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
    copyBtn.Size = UDim2.new(0, 72, 0, 22)
    copyBtn.Position = UDim2.new(1, -76, 0.5, -11)
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

local function getAllObjects()
    local list = {}
    for _, desc in pairs(Workspace:GetDescendants()) do
        if desc ~= Workspace.CurrentCamera and not desc:IsA("Terrain") and desc ~= LocalPlayer.Character and not desc:IsDescendantOf(LocalPlayer.Character) then
            table.insert(list, desc)
        end
    end
    return list
end

-- تشغيل زر Research
ResearchBtn.MouseButton1Click:Connect(function()
    clearList()
    registeredObjects = {}

    local objects = getAllObjects()
    for _, obj in pairs(objects) do
        registeredObjects[obj] = true
        addEntryToList(obj)
    end
end)

-- تشغيل زر GMP
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
end)
