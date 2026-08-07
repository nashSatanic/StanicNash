-- [[ Nash.exe — M7 Style Voice Panel + HWID Key System + Animated Notifications (FIXED v2) ]] --

local identifyexecutorname = (identifyexecutor and identifyexecutor()) or "Unknown"
local clonereference = cloneref or function(...) return ... end
local clonefunction = clonefunction or function(...) return ... end

local voicechatservice = clonereference(game:GetService("VoiceChatService"))
local voicechatinternal = clonereference(game:GetService("VoiceChatInternal"))
local coregui = game:GetService("CoreGui")
local startergui = game:GetService("StarterGui")
local players = game:GetService("Players")
local localplayer = players.LocalPlayer
local runservice = game:GetService("RunService")
local marketingservice = game:GetService("MarketplaceService")
local httpService = game:GetService("HttpService")
local tweenService = game:GetService("TweenService")

local getconnectionsfunc = clonefunction(getconnections)

-- ==========================================
-- UTILS
-- ==========================================
local function getHWID()
    local hwid = ""
    pcall(function()
        if type(gethwid) == "function" then
            hwid = gethwid()
        else
            hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        end
    end)
    return hwid
end

local LIME = Color3.fromRGB(163, 255, 51)
local RED = Color3.fromRGB(255, 60, 60)
local DARK_BG = Color3.fromRGB(12, 12, 14)
local CARD_BG = Color3.fromRGB(18, 18, 22)
local BORDER_DEFAULT = Color3.fromRGB(45, 45, 52)

-- ==========================================
-- ANIMATED NOTIFICATION SYSTEM (M7 Style)
-- ==========================================
local notifyGui = Instance.new("ScreenGui")
notifyGui.Name = "NashNotifySystem"
notifyGui.ResetOnSpawn = false
notifyGui.IgnoreGuiInset = true
notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notifyGui.DisplayOrder = 999999
notifyGui.Parent = coregui

local notifyContainer = Instance.new("Frame")
notifyContainer.Name = "NotifyContainer"
notifyContainer.Size = UDim2.new(0, 360, 1, -80)
notifyContainer.Position = UDim2.new(0.5, -180, 0, 40)
notifyContainer.BackgroundTransparency = 1
notifyContainer.Parent = notifyGui

local notifyListLayout = Instance.new("UIListLayout")
notifyListLayout.Padding = UDim.new(0, 10)
notifyListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
notifyListLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyListLayout.Parent = notifyContainer

local notifyCount = 0

local function notify(title, message, icon, accentColor, duration)
    duration = duration or 3.5
    accentColor = accentColor or LIME
    notifyCount = notifyCount + 1

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 340, 0, 0)
    holder.BackgroundTransparency = 1
    holder.ClipsDescendants = true
    holder.LayoutOrder = notifyCount
    holder.Parent = notifyContainer

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(0, 340, 0, 72)
    card.Position = UDim2.new(0, 100, 0, 0)
    card.BackgroundColor3 = CARD_BG
    card.BorderSizePixel = 0
    card.Parent = holder

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = accentColor
    cardStroke.Transparency = 0.5
    cardStroke.Thickness = 1.2
    cardStroke.Parent = card

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -20, 0, 2)
    topBar.Position = UDim2.new(0, 10, 0, 0)
    topBar.BackgroundColor3 = accentColor
    topBar.BorderSizePixel = 0
    topBar.Parent = card

    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 38, 0, 38)
    iconFrame.Position = UDim2.new(0, 12, 0.5, -19)
    iconFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = card
    Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0, 10)

    if icon then
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(0, 24, 0, 24)
        img.Position = UDim2.new(0.5, -12, 0.5, -12)
        img.BackgroundTransparency = 1
        img.Image = icon
        img.ImageColor3 = Color3.fromRGB(255, 255, 255)
        img.ScaleType = Enum.ScaleType.Fit
        img.Parent = iconFrame
    else
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 10, 0, 10)
        dot.Position = UDim2.new(0.5, -5, 0.5, -5)
        dot.BackgroundColor3 = accentColor
        dot.BorderSizePixel = 0
        dot.Parent = iconFrame
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    end

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -110, 0, 20)
    titleLabel.Position = UDim2.new(0, 60, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = card

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -110, 0, 30)
    msgLabel.Position = UDim2.new(0, 60, 0, 32)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
    msgLabel.TextSize = 11
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextYAlignment = Enum.TextYAlignment.Top
    msgLabel.TextWrapped = true
    msgLabel.Parent = card

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0, 8)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = card

    -- Animación de entrada
    tweenService:Create(holder, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 340, 0, 72)}):Play()
    tweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        tweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(0, 120, 0, 0)}):Play()
        task.wait(0.08)
        tweenService:Create(holder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 340, 0, 0)}):Play()
        task.wait(0.35)
        if holder and holder.Parent then holder:Destroy() end
    end

    closeBtn.MouseButton1Click:Connect(dismiss)
    task.delay(duration, dismiss)
end

-- ==========================================
-- LOADING SCREEN
-- ==========================================
local loadScreen = Instance.new("ScreenGui")
loadScreen.Name = "NashLoader"
loadScreen.ResetOnSpawn = false
loadScreen.IgnoreGuiInset = true
loadScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadScreen.DisplayOrder = 999998
loadScreen.Parent = coregui

local loadOverlay = Instance.new("Frame")
loadOverlay.Size = UDim2.new(1, 0, 1, 0)
loadOverlay.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
loadOverlay.BackgroundTransparency = 0.05
loadOverlay.BorderSizePixel = 0
loadOverlay.Parent = loadScreen

local loadCenter = Instance.new("Frame")
loadCenter.Size = UDim2.new(0, 420, 0, 220)
loadCenter.AnchorPoint = Vector2.new(0.5, 0.5)
loadCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
loadCenter.BackgroundTransparency = 1
loadCenter.Parent = loadOverlay

-- Anillos animados
for i = 1, 3 do
    local ring = Instance.new("Frame")
    ring.Size = UDim2.new(0, 100 + (i * 60), 0, 100 + (i * 60))
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.new(0.5, 0, 0.5, -20)
    ring.BackgroundTransparency = 1
    ring.Parent = loadCenter
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke")
    stroke.Color = LIME
    stroke.Transparency = 0.8 - (i * 0.2)
    stroke.Thickness = 1.5
    stroke.Parent = ring
end

local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(1, 0, 0, 40)
loadTitle.Position = UDim2.new(0, 0, 0.5, -30)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "Nash.exe"
loadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadTitle.TextSize = 26
loadTitle.Font = Enum.Font.GothamBold
loadTitle.Parent = loadCenter

local loadStatus = Instance.new("TextLabel")
loadStatus.Size = UDim2.new(1, 0, 0, 20)
loadStatus.Position = UDim2.new(0, 0, 0.5, 10)
loadStatus.BackgroundTransparency = 1
loadStatus.Text = "Inicializando..."
loadStatus.TextColor3 = Color3.fromRGB(160, 160, 170)
loadStatus.TextSize = 12
loadStatus.Font = Enum.Font.Gotham
loadStatus.Parent = loadCenter

local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0, 280, 0, 5)
loadBarBg.Position = UDim2.new(0.5, -140, 0.5, 45)
loadBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
loadBarBg.BorderSizePixel = 0
loadBarBg.Parent = loadCenter
Instance.new("UICorner", loadBarBg).CornerRadius = UDim.new(1, 0)

local loadBarFill = Instance.new("Frame")
loadBarFill.Size = UDim2.new(0, 0, 1, 0)
loadBarFill.BackgroundColor3 = LIME
loadBarFill.BorderSizePixel = 0
loadBarFill.Parent = loadBarBg
Instance.new("UICorner", loadBarFill).CornerRadius = UDim.new(1, 0)

local loaderDone = false

task.spawn(function()
    local ok = pcall(function()
        tweenService:Create(loadBarFill, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        task.wait(2.2)
        loadStatus.Text = "Verificando licencia..."
        task.wait(0.8)

        tweenService:Create(loadOverlay, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        for _, d in ipairs(loadCenter:GetDescendants()) do
            if d:IsA("TextLabel") then
                tweenService:Create(d, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            elseif d:IsA("UIStroke") then
                tweenService:Create(d, TweenInfo.new(0.4), {Transparency = 1}):Play()
            elseif d:IsA("Frame") and d ~= loadOverlay then
                tweenService:Create(d, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            end
        end
        task.wait(0.6)
        loadScreen:Destroy()
    end)
    if not ok then
        pcall(function() loadScreen:Destroy() end)
    end
    loaderDone = true
end)

task.delay(6, function()
    if not loaderDone then
        loaderDone = true
        pcall(function() loadScreen:Destroy() end)
    end
end)

repeat task.wait(0.1) until loaderDone

-- ==========================================
-- HWID KEY SYSTEM (Single Device)
-- ==========================================
local KEY_FOLDER = "Nash_Vault"
local KEY_FILE = "license.json"
local hasAccess = false
local currentHWID = getHWID()

pcall(function()
    if not isfolder(KEY_FOLDER) then makefolder(KEY_FOLDER) end
end)

    local DEFAULT_KEY = "NashSatanic"

    local function validateKeyFormat(key)
        if not key or type(key) ~= "string" then return false end
        if key == DEFAULT_KEY then return true end
        return key:match("^STANIC%-[A-Z0-9]+%-[A-Z0-9]+%-[A-Z0-9]+") ~= nil
    end

local function loadSavedLicense()
    local path = KEY_FOLDER .. "/" .. KEY_FILE
    if not isfile(path) then return false end
    local ok, raw = pcall(readfile, path)
    if not ok or not raw then return false end
    local ok2, data = pcall(httpService.JSONDecode, httpService, raw)
    if not ok2 or type(data) ~= "table" or not data.Key or not data.HWID then return false end

    if data.HWID ~= currentHWID then
        pcall(delfile, path)
        return false, "hwid_mismatch"
    end

    if validateKeyFormat(data.Key) then
        return true, data.Key
    end
    pcall(delfile, path)
    return false
end

local function saveLicense(key)
    local path = KEY_FOLDER .. "/" .. KEY_FILE
    pcall(writefile, path, httpService:JSONEncode({
        Key = key,
        HWID = currentHWID,
        Time = os.time(),
        Executor = identifyexecutorname
    }))
end

local savedOk, savedKeyOrReason = loadSavedLicense()

if savedOk then
    hasAccess = true
    notify("Licencia", "Bienvenido de vuelta. Dispositivo verificado.", nil, LIME, 3)
else
    if savedKeyOrReason == "hwid_mismatch" then
        notify("Seguridad", "Licencia vinculada a otro dispositivo. Requiere nueva key.", nil, RED, 4)
    end

    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "NashKeySystem"
    keyGui.ResetOnSpawn = false
    keyGui.IgnoreGuiInset = true
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    keyGui.DisplayOrder = 999997
    keyGui.Parent = coregui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    bg.BackgroundTransparency = 0.1
    bg.BorderSizePixel = 0
    bg.Parent = keyGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 320)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = CARD_BG
    main.BorderColor3 = Color3.fromRGB(60, 60, 70)
    main.BorderSizePixel = 1
    main.Parent = keyGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    header.BorderSizePixel = 0
    header.Parent = main
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

    local fix = Instance.new("Frame")
    fix.Size = UDim2.new(1, 0, 0, 12)
    fix.Position = UDim2.new(0, 0, 1, -12)
    fix.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    fix.BorderSizePixel = 0
    fix.Parent = header

    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, -20, 1, 0)
    headerTitle.Position = UDim2.new(0, 16, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "Nash Vault — Acceso requerido"
    headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerTitle.TextSize = 15
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header

    local hwidLabel = Instance.new("TextLabel")
    hwidLabel.Size = UDim2.new(1, -32, 0, 16)
    hwidLabel.Position = UDim2.new(0, 16, 0, 60)
    hwidLabel.BackgroundTransparency = 1
    hwidLabel.Text = "HWID: " .. string.sub(currentHWID, 1, 16) .. "..."
    hwidLabel.TextColor3 = Color3.fromRGB(100, 100, 110)
    hwidLabel.TextSize = 10
    hwidLabel.Font = Enum.Font.Code
    hwidLabel.TextXAlignment = Enum.TextXAlignment.Left
    hwidLabel.Parent = main

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -32, 0, 36)
    desc.Position = UDim2.new(0, 16, 0, 82)
    desc.BackgroundTransparency = 1
         desc.Text = "Key por defecto: NashSatanic — Se vinculara a este dispositivo."
    desc.TextColor3 = Color3.fromRGB(160, 160, 170)
    desc.TextSize = 12
    desc.Font = Enum.Font.Gotham
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = main

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -32, 0, 42)
    input.Position = UDim2.new(0, 16, 0, 128)
    input.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
    input.BorderColor3 = BORDER_DEFAULT
     input.PlaceholderText = "NashSatanic"
    input.PlaceholderColor3 = Color3.fromRGB(80, 80, 90)
    input.Text = ""
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 13
    input.Font = Enum.Font.Code
    input.ClearTextOnFocus = false
    input.Parent = main
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -32, 0, 18)
    status.Position = UDim2.new(0, 16, 0, 174)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = RED
    status.TextSize = 11
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = main

     local activateBtn = Instance.new("TextButton")
     activateBtn.Size = UDim2.new(1, -32, 0, 40)
     activateBtn.Position = UDim2.new(0, 16, 0, 210)
     activateBtn.BackgroundColor3 = LIME
     activateBtn.Text = "Login"
     activateBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
     activateBtn.TextSize = 13
     activateBtn.Font = Enum.Font.GothamBold
     activateBtn.AutoButtonColor = true
     activateBtn.Parent = main
     Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 8)

    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -32, 0, 16)
    footer.Position = UDim2.new(0, 16, 1, -26)
    footer.BackgroundTransparency = 1
    footer.Text = "Ejecutor: " .. identifyexecutorname .. "  |  Single-Device License"
    footer.TextColor3 = Color3.fromRGB(80, 80, 90)
    footer.TextSize = 10
    footer.Font = Enum.Font.Gotham
    footer.TextXAlignment = Enum.TextXAlignment.Left
    footer.Parent = main

     activateBtn.MouseButton1Click:Connect(function()
        local key = input.Text
        if not validateKeyFormat(key) then
            status.Text = "Formato invalido. Usa: STANIC-XXXX-XXXX-XXXX"
            status.TextColor3 = RED
            return
        end
        status.Text = "Validando y vinculando a dispositivo..."
        status.TextColor3 = Color3.fromRGB(255, 220, 100)

        task.spawn(function()
            task.wait(0.6)
            saveLicense(key)
            hasAccess = true
            status.Text = "Licencia activada y vinculada."
            status.TextColor3 = LIME
            notify("Licencia activada", "Dispositivo vinculado correctamente.", nil, LIME, 3)
            task.wait(0.8)
            keyGui:Destroy()
        end)
    end)

    input.FocusLost:Connect(function(enter)
        if enter then activateBtn.MouseButton1Click:Fire() end
    end)

    repeat task.wait(0.1) until hasAccess
end

if not hasAccess then return end

-- ==========================================
-- CORREGIDOS: ASSETS DE MICROFONO
-- ==========================================
local mutedimage = "rbxasset://textures/ui/VoiceChat/MicLight/Muted.png"
local speakingimage = "rbxasset://textures/ui/VoiceChat/MicLight/Unmuted.png"
local headsetimage = "rbxassetid://6023426915"

-- ==========================================
-- ANTI-REPORT SAFE
-- ==========================================
local function enableReportEvade()
    pcall(function()
        local old = hookfunction(marketingservice.PromptPurchase, function(...)
            return old(...)
        end)
    end)
end
enableReportEvade()

-- ==========================================
-- LÓGICA DE VOZ
-- ==========================================
local ismuted = false
local isdeafened = false

local hiddenfolder = Instance.new("Folder", game:GetService("RobloxReplicatedStorage"))
hiddenfolder.Name = "VoiceChatHidden"

-- Búsqueda robusta del botón de micrófono en el TopBar
local function findMicButtonRobust()
    local topbarapp = coregui:FindFirstChild("TopBarApp")
    if not topbarapp then return nil end

    -- Buscar en todo el topbar recursivamente por nombre
    local function search(parent, name)
        for _, child in ipairs(parent:GetDescendants()) do
            if child.Name == name then return child end
        end
        return nil
    end

    local btn = search(topbarapp, "toggle_mic_mute")
    if btn then return btn end

    -- Fallback: buscar cualquier ImageButton con imagen de micrófono
    for _, child in ipairs(topbarapp:GetDescendants()) do
        if child:IsA("ImageButton") or child:IsA("TextButton") then
            local img = child:FindFirstChildWhichIsA("ImageLabel", true)
            if img and img:IsA("ImageLabel") then
                local imgStr = tostring(img.Image)
                if imgStr:find("MicLight") or imgStr:find("mic") then
                    return child
                end
            end
        end
    end

    return nil
end

local function geticonlabel(button)
    if not button then return nil end
    local integrationFrame = button:FindFirstChild("IntegrationIconFrame", true)
    if integrationFrame then
        local integrationIcon = integrationFrame:FindFirstChild("IntegrationIcon", true)
        if integrationIcon then
            return integrationIcon:FindFirstChild("1", true) or integrationIcon:FindFirstChildWhichIsA("ImageLabel", true)
        end
    end
    return button:FindFirstChildWhichIsA("ImageLabel", true)
end

local function applyAntiClipping()
    pcall(function()
        local audioDeviceInput = localplayer:FindFirstChildWhichIsA("AudioDeviceInput", true)
        if audioDeviceInput then
            audioDeviceInput.Volume = 0.85
            audioDeviceInput.Muted = ismuted
        end
        if voicechatinternal and voicechatinternal.PublishPause then
            voicechatinternal:PublishPause(ismuted)
        end
    end)
end

local function setmutestate(state)
    ismuted = state
    applyAntiClipping()
    pcall(function()
        local adi = localplayer:FindFirstChildWhichIsA("AudioDeviceInput", true)
        if adi then
            adi.Active = not state
        else
            voicechatinternal:PublishPause(state)
        end
    end)
end

local function setdeafenstate(state)
    isdeafened = state
    pcall(function()
        for _, plr in ipairs(players:GetPlayers()) do
            if plr ~= localplayer and plr.Character then
                local out = plr.Character:FindFirstChildWhichIsA("AudioDeviceOutput", true)
                if out then out.Volume = state and 0 or 1 end
            end
        end
    end)
end

-- Intentar encontrar el botón del mic
local micmutebutton = findMicButtonRobust()

-- Si no lo encuentra, intentar unirse a voice chat y buscar de nuevo
if not micmutebutton then
    pcall(function() voicechatservice:joinVoice() end)
    task.wait(2.5)
    micmutebutton = findMicButtonRobust()
end

local iconLabel = nil
if micmutebutton then
    iconLabel = geticonlabel(micmutebutton)
end

-- Si encontramos el botón, sincronizar con él
if micmutebutton and iconLabel then
    notify("Configuracion", "Activa el microfono para sincronizar el panel.", speakingimage, LIME, 5)

    task.spawn(function()
        local t0 = tick()
        while iconLabel and iconLabel.Parent and iconLabel.Image == mutedimage and (tick() - t0) < 30 do
            task.wait(0.5)
        end
        if not iconLabel or not iconLabel.Parent then return end
        if iconLabel.Image == mutedimage then
            notify("Timeout", "No se detecto activacion del mic. Activalo manualmente.", nil, RED, 4)
            return
        end

        voicechatservice:leaveVoice()
        task.wait(2)

        for _, event in ipairs({voicechatinternal.StateChanged, voicechatinternal.ParticipantsStateChanged}) do
            local ok, conns = pcall(getconnectionsfunc, event)
            if ok and conns then
                for _, conn in ipairs(conns) do
                    pcall(function() conn:Disable() end)
                end
            end
        end

        task.wait(1)
        voicechatservice:joinVoice()
        task.wait(2)
    end)
else
    -- Fallback: no se encontró el botón, pero igual creamos el panel funcional
    notify("Advertencia", "No se encontro el boton nativo del mic. Panel funcionando en modo independiente.", nil, Color3.fromRGB(255, 180, 60), 5)
end

-- ==========================================
-- UI PANEL PRINCIPAL
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NashTopVoicePanel"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = coregui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Container"
mainFrame.Size = UDim2.new(0, 120, 0, 44)
mainFrame.Position = UDim2.new(0.5, -140, 0, 12)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
mainFrame.BackgroundTransparency = 0.02
mainFrame.BorderColor3 = BORDER_DEFAULT
mainFrame.BorderSizePixel = 1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = mainFrame

-- Mic Button
local micBtn = Instance.new("ImageButton")
micBtn.Name = "MicToggle"
micBtn.Size = UDim2.new(0, 38, 0, 34)
micBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
micBtn.BorderSizePixel = 0
micBtn.Image = speakingimage
micBtn.Parent = mainFrame
Instance.new("UICorner", micBtn).CornerRadius = UDim.new(0, 8)

micBtn.MouseButton1Click:Connect(function()
    ismuted = not ismuted
    setmutestate(ismuted)
    micBtn.Image = ismuted and mutedimage or speakingimage
    micBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    notify("Microphone", ismuted and "Muted (Protected)" or "Active",
        ismuted and mutedimage or speakingimage,
        ismuted and RED or LIME, 2)
end)

-- Deafen Button
local deafenBtn = Instance.new("ImageButton")
deafenBtn.Name = "DeafenToggle"
deafenBtn.Size = UDim2.new(0, 38, 0, 34)
deafenBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
deafenBtn.BorderSizePixel = 0
deafenBtn.Image = headsetimage
deafenBtn.Parent = mainFrame
Instance.new("UICorner", deafenBtn).CornerRadius = UDim.new(0, 8)

deafenBtn.MouseButton1Click:Connect(function()
    isdeafened = not isdeafened
    setdeafenstate(isdeafened)
    deafenBtn.ImageColor3 = isdeafened and RED or Color3.fromRGB(255, 255, 255)
    notify("Audio Output", isdeafened and "Muted" or "Active",
        headsetimage, isdeafened and RED or LIME, 2)
end)

setmutestate(false)
micBtn.Image = speakingimage
micBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)

-- Loop anti-clipping
task.spawn(function()
    while mainFrame and mainFrame.Parent do
        task.wait(0.5)
        applyAntiClipping()
    end
end)

notify("Nash Vault", "Panel cargado. Listo para usar.", nil, LIME, 4)
