-- Universal BillboardGui Path Sniper (Full Game Coverage)
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. إنشاء شريط التحكم العُلوي (زر Research وزر GMP)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalPathSniper_GUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local ControlsBar = Instance.new("Frame")
ControlsBar.Size = UDim2.new(0, 260, 0, 45)
ControlsBar.Position = UDim2.new(0.5, -130, 0, 15) -- منتصف أعلى الشاشة
ControlsBar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
ControlsBar.BorderSizePixel = 0
ControlsBar.Active = true
ControlsBar.Parent = ScreenGui

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 8)
BarCorner.Parent = ControlsBar

-- زر Research / Refresh (البحث في كل مسارات اللعبة)
local ResearchBtn = Instance.new("TextButton")
ResearchBtn.Size = UDim2.new(0, 115, 0, 31)
ResearchBtn.Position = UDim2.new(0, 10, 0.5, -15)
ResearchBtn.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
ResearchBtn.Text = "🔍 Research All"
ResearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResearchBtn.TextSize = 11
ResearchBtn.Font = Enum.Font.GothamBold
ResearchBtn.Parent = ControlsBar

local ResearchCorner = Instance.new("UICorner")
ResearchCorner.CornerRadius = UDim.new(0, 6)
ResearchCorner.Parent = ResearchBtn

-- زر GMP (Get Modified/New Parts - جلب الجديد ومسح القديم)
local GMPBtn = Instance.new("TextButton")
GMPBtn.Size = UDim2.new(0, 115, 0, 31)
GMPBtn.Position = UDim2.new(1, -125, 0.5, -15)
GMPBtn.BackgroundColor3 = Color3.fromRGB(170, 40, 220)
GMPBtn.Text = "⚡ GMP (New Only)"
GMPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GMPBtn.TextSize = 11
GMPBtn.Font = Enum.Font.GothamBold
GMPBtn.Parent = ControlsBar

local GMPCorner = Instance.new("UICorner")
GMPCorner.CornerRadius = UDim.new(0, 6)
GMPCorner.Parent = GMPBtn

-- مجلد حصر جميع الـ BillboardGuis المعلقة باللعبة
local BillboardContainer = Instance.new("Folder")
BillboardContainer.Name = "Active_Path_Billboards"
BillboardContainer.Parent = ScreenGui

-- 2. دالة استخراج المسار الكامل المباشر لأي عنصر (Full Game Path)
local function getFullPath(instance)
    local path = instance.Name
    local current = instance.Parent

    while current and current ~= game do
        -- التعامل مع الأسماء التي تحتوي على مسافات أو رموز خاصة
        if string.match(current.Name, "[^%w_]") then
            path = '["' .. current.Name .. '"].' .. path
        else
            path = current.Name .. "." .. path
        end
        current = current.Parent
    end

    return "game." .. path
end

-- دالة نسخ النص للحافظة
local function copyPath(text)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    else
        print("Path: " .. text)
    end
end

-- 3. دالة إنشاء BillboardGui الشفاف والملتصق بكل مجسم
local function attachBillboardToPart(targetPart, sourceObject)
    local fullPath = getFullPath(sourceObject)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BBG_" .. sourceObject.Name
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 160, 0, 52)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true -- يظهر دائماً فوق كل شيء
    billboard.Parent = BillboardContainer

    -- كادر شفاف مائي أزرق
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(0, 230, 255)
    frame.Parent = billboard

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame

    -- عنوان واسم العنصر
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -8, 0, 22)
    nameLabel.Position = UDim2.new(0, 4, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "💎 " .. sourceObject.Name
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 220)
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = frame

    -- زر Copy Path داخل الـ BillboardGui نفسه
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(1, -10, 0, 20)
    copyBtn.Position = UDim2.new(0, 5, 1, -23)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
    copyBtn.Text = "📋 Copy Path"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.TextSize = 10
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = copyBtn

    copyBtn.MouseButton1Click:Connect(function()
        copyPath(fullPath)
        copyBtn.Text = "✅ Copied!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
        task.wait(1)
        copyBtn.Text = "📋 Copy Path"
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
    end)
end

-- 4. إدارة المسح والتسجيل الشامل لكل مسارات اللعبة
local registeredObjects = {}

local function clearAllBillboards()
    BillboardContainer:ClearAllChildren()
end

-- دالة الفحص والبحث الشامل في كل المسارات (Get All Descendants)
local function getAllPhysicalGameObjects()
    local foundList = {}

    -- الفحص داخل Workspace بالكامل وكل شجرات المسارات المتفرعة
    for _, descendant in pairs(Workspace:GetDescendants()) do
        if descendant ~= Workspace.CurrentCamera and not descendant:IsA("Terrain") then
            -- التأكد أنه مجسم أو يحتوي على مجسم في مساره ليتم تعليق الـ BillboardGui عليه
            local targetPart = nil
            if descendant:IsA("BasePart") then
                targetPart = descendant
            elseif descendant:IsA("Model") then
                targetPart = descendant.PrimaryPart or descendant:FindFirstChildWhichIsA("BasePart", true)
            end

            if targetPart and descendant ~= LocalPlayer.Character and not descendant:IsDescendantOf(LocalPlayer.Character) then
                table.insert(foundList, {Object = descendant, Part = targetPart})
            end
        end
    end

    return foundList
end

-- تنفيذ زر Research All (إعادة المسح الشامل لكل اللعبة)
ResearchBtn.MouseButton1Click:Connect(function()
    clearAllBillboards()
    registeredObjects = {}

    local allObjects = getAllPhysicalGameObjects()
    for _, item in pairs(allObjects) do
        registeredObjects[item.Object] = true
        attachBillboardToPart(item.Part, item.Object)
    end
end)

-- تنفيذ زر GMP (إزالة القديم وتحديد العناصر/المسارات الجديدة فقط)
GMPBtn.MouseButton1Click:Connect(function()
    clearAllBillboards()

    local currentObjects = getAllPhysicalGameObjects()
    local newObjects = {}

    for _, item in pairs(currentObjects) do
        -- إذا كان مسار/عنصر جديد لم يتم رصده بالمسح السابق
        if not registeredObjects[item.Object] then
            table.insert(newObjects, item)
        end
    end

    -- تحديث السجل بالمسارات الحالية كاملة
    registeredObjects = {}
    for _, item in pairs(currentObjects) do
        registeredObjects[item.Object] = true
    end

    -- تعليق BillboardGui فقط على المسارات الجديدة الظاهرة
    for _, item in pairs(newObjects) do
        attachBillboardToPart(item.Part, item.Object)
    end
end)

-- التشغيل الأولي الشامل عند بداية السكريبت
ResearchBtn:Activate()
