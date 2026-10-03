-- Transparent Path Tracker & Billboard ESP Sniper
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. شاشات التحكم العُلوية البسيطة (Research & GMP)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PathTracker_Billboard_GUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(0, 220, 0, 40)
TopBar.Position = UDim2.new(0.5, -110, 0, 15)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Draggable = true
TopBar.Parent = ScreenGui

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 8)
BarCorner.Parent = TopBar

local ResearchBtn = Instance.new("TextButton")
ResearchBtn.Size = UDim2.new(0, 95, 0, 28)
ResearchBtn.Position = UDim2.new(0, 8, 0.5, -14)
ResearchBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
ResearchBtn.Text = "🔍 Research"
ResearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResearchBtn.TextSize = 10
ResearchBtn.Font = Enum.Font.GothamBold
ResearchBtn.Parent = TopBar

local RCorner = Instance.new("UICorner")
RCorner.CornerRadius = UDim.new(0, 5)
RCorner.Parent = ResearchBtn

local GMPBtn = Instance.new("TextButton")
GMPBtn.Size = UDim2.new(0, 95, 0, 28)
GMPBtn.Position = UDim2.new(1, -103, 0.5, -14)
GMPBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 210)
GMPBtn.Text = "⚡ GMP"
GMPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GMPBtn.TextSize = 10
GMPBtn.Font = Enum.Font.GothamBold
GMPBtn.Parent = TopBar

local GCorner = Instance.new("UICorner")
GCorner.CornerRadius = UDim.new(0, 5)
GCorner.Parent = GMPBtn

-- مجلد يحتوي كل الـ BillboardGuis الشفافة لتسهيل الحذف والإنشاء
local BillboardHolder = Instance.new("Folder")
BillboardHolder.Name = "Active_Billboards"
BillboardHolder.Parent = ScreenGui

-- 2. دالة جلب المسار الكامل الكود
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

-- 3. دالة تعليق الـ BillboardGui الشفاف المائي لتتبعه والمشي وراءه
local function createTrackerBillboard(targetPart, sourceObj)
    local fullPath = getFullPath(sourceObj)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BBG_" .. sourceObj.Name
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 170, 0, 55)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true -- يظهر وراء الجدران لتقدر تمشي وراه
    billboard.Parent = BillboardHolder

    -- الإطار الشفاف المائي
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    mainFrame.BackgroundTransparency = 0.35 -- مائي شفاف
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(0, 230, 255)
    mainFrame.Parent = billboard

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = mainFrame

    -- اسم العنصر الشفاف
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -6, 0, 22)
    nameLabel.Position = UDim2.new(0, 3, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "📍 " .. sourceObj.Name
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 220)
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = mainFrame

    -- زر النسخ المعلق في الهواء على الشيء نفسه
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(1, -10, 0, 20)
    copyBtn.Position = UDim2.new(0, 5, 1, -23)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
    copyBtn.Text = "📋 Copy Path"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.TextSize = 10
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = copyBtn

    copyBtn.MouseButton1Click:Connect(function()
        copyPath(fullPath)
        copyBtn.Text = "✅ Copied!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
        task.wait(0.8)
        copyBtn.Text = "📋 Copy Path"
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
    end)
end

-- 4. إدارات المسح الشامل والتتبع المباشر
local registeredObjects = {}

local function clearAllBillboards()
    BillboardHolder:ClearAllChildren()
end

local function getValidGameTargets()
    local targets = {}
    for _, desc in pairs(Workspace:GetDescendants()) do
        if desc ~= Workspace.CurrentCamera and not desc:IsA("Terrain") and desc ~= LocalPlayer.Character and not desc:IsDescendantOf(LocalPlayer.Character) then
            local part = nil
            if desc:IsA("BasePart") then
                part = desc
            elseif desc:IsA("Model") then
                part = desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart", true)
            end

            if part then
                table.insert(targets, {Object = desc, Part = part})
            end
        end
    end
    return targets
end

-- زر Research: إظهار الـ BillboardGui الشفاف فوق كل شيء باللعبة لتمشي وراه
ResearchBtn.MouseButton1Click:Connect(function()
    clearAllBillboards()
    registeredObjects = {}

    local list = getValidGameTargets()
    for _, item in pairs(list) do
        registeredObjects[item.Object] = true
        createTrackerBillboard(item.Part, item.Object)
    end
end)

-- زر GMP: حذف القديم وإبقاء الـ BillboardGui الشفاف فقط على الشيء الجديد لللحاق به وتتبعه
GMPBtn.MouseButton1Click:Connect(function()
    clearAllBillboards()

    local currentList = getValidGameTargets()
    local newList = {}

    for _, item in pairs(currentList) do
        if not registeredObjects[item.Object] then
            table.insert(newList, item)
        end
    end

    registeredObjects = {}
    for _, item in pairs(currentList) do
        registeredObjects[item.Object] = true
    end

    for _, item in pairs(newList) do
        createTrackerBillboard(item.Part, item.Object)
    end
end)
