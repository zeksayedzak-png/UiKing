-- On-Screen Visible Tracker (BillboardGui ESP + Copy Path)
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. الشاشة والشريط العلوي البسيط (زرين فقط)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VisibleTracker_GUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(0, 210, 0, 38)
TopBar.Position = UDim2.new(0.5, -105, 0, 15)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Draggable = true
TopBar.Parent = ScreenGui

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 8)
BarCorner.Parent = TopBar

local ResearchBtn = Instance.new("TextButton")
ResearchBtn.Size = UDim2.new(0, 90, 0, 26)
ResearchBtn.Position = UDim2.new(0, 8, 0.5, -13)
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
GMPBtn.Size = UDim2.new(0, 90, 0, 26)
GMPBtn.Position = UDim2.new(1, -98, 0.5, -13)
GMPBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 210)
GMPBtn.Text = "⚡ GMP"
GMPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GMPBtn.TextSize = 10
GMPBtn.Font = Enum.Font.GothamBold
GMPBtn.Parent = TopBar

local GCorner = Instance.new("UICorner")
GCorner.CornerRadius = UDim.new(0, 5)
GCorner.Parent = GMPBtn

-- مجلد علامات الـ BillboardGui الشفافة
local BillboardHolder = Instance.new("Folder")
BillboardHolder.Name = "Visible_Billboards"
BillboardHolder.Parent = ScreenGui

-- 2. دالة استخراج المسار الكامل
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

-- 3. إنشاء BillboardGui مائي شفاف فوق المجسم المرئي مباشرة
local function createBillboard(targetPart, sourceObj)
    local fullPath = getFullPath(sourceObj)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BBG_" .. sourceObj.Name
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 150, 0, 48)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = BillboardHolder

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

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -6, 0, 20)
    nameLabel.Position = UDim2.new(0, 3, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "👁️ " .. sourceObj.Name
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 220)
    nameLabel.TextSize = 10
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = mainFrame

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(1, -10, 0, 18)
    copyBtn.Position = UDim2.new(0, 5, 1, -21)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
    copyBtn.Text = "Copy Path"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.TextSize = 9
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = copyBtn

    copyBtn.MouseButton1Click:Connect(function()
        copyPath(fullPath)
        copyBtn.Text = "Copied!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
        task.wait(0.8)
        copyBtn.Text = "Copy Path"
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
    end)
end

-- 4. جلب العناصر الظاهرة داخل نطاق الشاشة/العين فقط
local function getVisibleOnScreenTargets()
    local visibleTargets = {}

    for _, desc in pairs(Workspace:GetChildren()) do
        if desc ~= Camera and not desc:IsA("Terrain") and desc ~= LocalPlayer.Character then
            local part = desc:IsA("BasePart") and desc or desc:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and screenPos.Z > 0 then
                    table.insert(visibleTargets, {Object = desc, Part = part})
                end
            end
        end
    end

    return visibleTargets
end

local knownVisible = {}

ResearchBtn.MouseButton1Click:Connect(function()
    BillboardHolder:ClearAllChildren()
    knownVisible = {}

    local visible = getVisibleOnScreenTargets()
    for _, item in pairs(visible) do
        knownVisible[item.Object] = true
        createBillboard(item.Part, item.Object)
    end
end)

GMPBtn.MouseButton1Click:Connect(function()
    BillboardHolder:ClearAllChildren()

    local visible = getVisibleOnScreenTargets()
    local newlyVisible = {}

    for _, item in pairs(visible) do
        if not knownVisible[item.Object] then
            table.insert(newlyVisible, item)
        end
    end

    knownVisible = {}
    for _, item in pairs(visible) do
        knownVisible[item.Object] = true
    end

    for _, item in pairs(newlyVisible) do
        createBillboard(item.Part, item.Object)
    end
end)
