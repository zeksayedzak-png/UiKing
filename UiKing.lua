-- BillboardGui Target Path Tracker (Clean & Pure)
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. الواجهة الرئيسية نفسها عبارة عن BillboardGui على الشاشة
local ControlAnchor = Instance.new("Part")
ControlAnchor.Name = "Tracker_Anchor"
ControlAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
ControlAnchor.Transparency = 1
ControlAnchor.CanCollide = false
ControlAnchor.Anchored = true
ControlAnchor.Parent = Workspace

task.spawn(function()
    while task.wait() do
        ControlAnchor.CFrame = Camera.CFrame * CFrame.new(0, 0, -3)
    end
end)

local MainBillboard = Instance.new("BillboardGui")
MainBillboard.Name = "MainPathTracker_BBG"
MainBillboard.Adornee = ControlAnchor
MainBillboard.Size = UDim2.new(0, 310, 0, 350)
MainBillboard.AlwaysOnTop = true
MainBillboard.Parent = PlayerGui

-- النافذة الشفافة القابلة للتحريك
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 15, 22)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 220, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = MainBillboard

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- الأزرار العلوية (Research & GMP)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
Header.BackgroundTransparency = 0.2
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local ResearchBtn = Instance.new("TextButton")
ResearchBtn.Size = UDim2.new(0, 95, 0, 26)
ResearchBtn.Position = UDim2.new(0, 8, 0.5, -13)
ResearchBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 240)
ResearchBtn.Text = "🔍 Research"
ResearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResearchBtn.TextSize = 10
ResearchBtn.Font = Enum.Font.GothamBold
ResearchBtn.Parent = Header

local RCorner = Instance.new("UICorner")
RCorner.CornerRadius = UDim.new(0, 4)
RCorner.Parent = ResearchBtn

local GMPBtn = Instance.new("TextButton")
GMPBtn.Size = UDim2.new(0, 95, 0, 26)
GMPBtn.Position = UDim2.new(1, -103, 0.5, -13)
GMPBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 210)
GMPBtn.Text = "⚡ GMP"
GMPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GMPBtn.TextSize = 10
GMPBtn.Font = Enum.Font.GothamBold
GMPBtn.Parent = Header

local GCorner = Instance.new("UICorner")
GCorner.CornerRadius = UDim.new(0, 4)
GCorner.Parent = GMPBtn

-- قائمة استعراض أسماء الـ BillboardGuis المرئية
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -16, 1, -50)
ScrollList.Position = UDim2.new(0, 8, 0, 44)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollList.ScrollBarThickness = 4
ScrollList.ScrollBarImageColor3 = Color3.fromRGB(0, 220, 255)
ScrollList.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 5)
UIList.Parent = ScrollList

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

-- 2. دالة استخراج المسار الكامل الكود
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
        print("PATH: " .. text)
    end
end

-- إضافة عنصر القائمة داخل الـ BillboardGui
local function addBillboardToList(targetBBG)
    local fullPath = getFullPath(targetBBG)

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 30)
    row.BackgroundColor3 = Color3.fromRGB(22, 28, 40)
    row.BackgroundTransparency = 0.2
    row.BorderSizePixel = 0
    row.Parent = ScrollList

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 4)
    rCorner.Parent = row

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -85, 1, 0)
    nameLabel.Position = UDim2.new(0, 6, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = targetBBG.Name
    nameLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
    nameLabel.TextSize = 10
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = row

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 72, 0, 20)
    copyBtn.Position = UDim2.new(1, -76, 0.5, -10)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
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
        copyBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        task.wait(0.8)
        copyBtn.Text = "Copy Path"
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
    end)
end

-- 3. جلب الـ BillboardGui الموجودة باللعبة والظاهرة في الشاشة أمام الكاميرا
local function getVisibleGameBillboards()
    local visibleList = {}

    for _, desc in pairs(game:GetDescendants()) do
        if desc:IsA("BillboardGui") and desc ~= MainBillboard then
            local adornee = desc.Adornee or desc.Parent
            if adornee and adornee:IsA("BasePart") then
                local screenPos, onScreen = Camera:WorldToViewportPoint(adornee.Position)
                if onScreen and screenPos.Z > 0 then
                    table.insert(visibleList, desc)
                end
            end
        end
    end

    return visibleList
end

local function clearList()
    for _, child in pairs(ScrollList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local knownBillboards = {}

-- زر Research: إحضار الـ BillboardGui الظاهرة أمامك باللعبة حالياً
ResearchBtn.MouseButton1Click:Connect(function()
    clearList()
    knownBillboards = {}

    local visible = getVisibleGameBillboards()
    for _, bbg in pairs(visible) do
        knownBillboards[bbg] = true
        addBillboardToList(bbg)
    end
end)

-- زر GMP: إحضار الـ BillboardGui الجديدة التي ظهرت توّاً على الشاشة
GMPBtn.MouseButton1Click:Connect(function()
    clearList()

    local visible = getVisibleGameBillboards()
    local newBBGs = {}

    for _, bbg in pairs(visible) do
        if not knownBillboards[bbg] then
            table.insert(newBBGs, bbg)
        end
    end

    knownBillboards = {}
    for _, bbg in pairs(visible) do
        knownBillboards[bbg] = true
    end

    for _, bbg in pairs(newBBGs) do
        addBillboardToList(bbg)
    end
end)
