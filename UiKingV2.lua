-- Worming Billboard Scanner
-- Made for Delta

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- الواجهة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WormingBillboard"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- الإطار الرئيسي
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 140, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Worming Billboard"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- زر Research
local ResearchBtn = Instance.new("TextButton")
ResearchBtn.Size = UDim2.new(0.5, -15, 0, 40)
ResearchBtn.Position = UDim2.new(0, 10, 0, 40)
ResearchBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
ResearchBtn.Text = "Research"
ResearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResearchBtn.TextScaled = true
ResearchBtn.Font = Enum.Font.GothamBold
ResearchBtn.Parent = MainFrame

local RCorner = Instance.new("UICorner")
RCorner.CornerRadius = UDim.new(0, 8)
RCorner.Parent = ResearchBtn

-- زر GMP
local GMPBtn = Instance.new("TextButton")
GMPBtn.Size = UDim2.new(0.5, -15, 0, 40)
GMPBtn.Position = UDim2.new(0.5, 5, 0, 40)
GMPBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
GMPBtn.Text = "GMP"
GMPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GMPBtn.TextScaled = true
GMPBtn.Font = Enum.Font.GothamBold
GMPBtn.Parent = MainFrame

local GCorner = Instance.new("UICorner")
GCorner.CornerRadius = UDim.new(0, 8)
GCorner.Parent = GMPBtn

-- منطقة التمرير
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -100)
ScrollFrame.Position = UDim2.new(0, 10, 0, 90)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ScrollFrame.BackgroundTransparency = 0.3
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local SCorner = Instance.new("UICorner")
SCorner.CornerRadius = UDim.new(0, 8)
SCorner.Parent = ScrollFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- دالة المسار الكامل
local function getFullPath(instance)
    local path = instance.Name
    local parent = instance.Parent
    while parent and parent ~= game do
        path = parent.Name .. "." .. path
        parent = parent.Parent
    end
    return "game." .. path
end

-- دالة مسح القائمة
local function clearList()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

-- دالة إنشاء عنصر
local function createItem(billboard)
    local ItemFrame = Instance.new("Frame")
    ItemFrame.Size = UDim2.new(1, -10, 0, 55)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ItemFrame.BackgroundTransparency = 0.2
    ItemFrame.BorderSizePixel = 0
    ItemFrame.Parent = ScrollFrame

    local ICorner = Instance.new("UICorner")
    ICorner.CornerRadius = UDim.new(0, 6)
    ICorner.Parent = ItemFrame

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -60, 0, 22)
    NameLabel.Position = UDim2.new(0, 5, 0, 2)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = billboard.Name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextScaled = true
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = ItemFrame

    local PathLabel = Instance.new("TextLabel")
    PathLabel.Size = UDim2.new(1, -60, 0, 20)
    PathLabel.Position = UDim2.new(0, 5, 0, 28)
    PathLabel.BackgroundTransparency = 1
    PathLabel.Text = getFullPath(billboard)
    PathLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    PathLabel.TextScaled = true
    PathLabel.Font = Enum.Font.Gotham
    PathLabel.TextXAlignment = Enum.TextXAlignment.Left
    PathLabel.Parent = ItemFrame

    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(0, 50, 0, 45)
    CopyBtn.Position = UDim2.new(1, -55, 0, 5)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    CopyBtn.Text = "Copy"
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.TextScaled = true
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.Parent = ItemFrame

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 6)
    CCorner.Parent = CopyBtn

    CopyBtn.MouseButton1Click:Connect(function()
        local path = getFullPath(billboard)
        if setclipboard then
            setclipboard(path)
            CopyBtn.Text = "OK!"
            wait(1)
            CopyBtn.Text = "Copy"
        else
            CopyBtn.Text = "No"
        end
    end)
end

-- دالة البحث في كل اللعبة
local function scanBillboards()
    clearList()
    local found = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("BillboardGui") then
            table.insert(found, obj)
        end
    end
    for _, bb in pairs(found) do
        createItem(bb)
    end
    return #found
end

-- دالة البحث عن الظاهرة قدامك
local function scanVisibleBillboards()
    clearList()
    local found = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("BillboardGui") and obj.Enabled then
            local adornee = obj.Adornee
            if adornee and adornee:IsA("BasePart") then
                local distance = (adornee.Position - Camera.CFrame.Position).Magnitude
                if distance < 150 then
                    table.insert(found, obj)
                end
            else
                table.insert(found, obj)
            end
        end
    end
    for _, bb in pairs(found) do
        createItem(bb)
    end
    return #found
end

-- زر Research
ResearchBtn.MouseButton1Click:Connect(function()
    ResearchBtn.Text = "..."
    local count = scanVisibleBillboards()
    ResearchBtn.Text = "Research (" .. count .. ")"
end)

-- زر GMP
GMPBtn.MouseButton1Click:Connect(function()
    GMPBtn.Text = "..."
    local count = scanBillboards()
    GMPBtn.Text = "GMP (" .. count .. ")"
end)
