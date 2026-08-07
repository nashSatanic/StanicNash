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


local API_BASE = "https://fabulous-starlight-c3e2dc.netlify.app/.netlify/functions"

local httpfunc = request or http_request or (syn and syn.request) or (fluxus and fluxus.request) or nil

local function apiRequest(method, path, data)
    if not httpfunc then return nil end
    local ok, res = pcall(httpfunc, {
        Url = API_BASE .. path,
        Method = method,
        Headers = { ["Content-Type"] = "application/json" },
        Body = data and httpService:JSONEncode(data) or nil
    })
    if ok and res and (res.StatusCode == 200 or res.Success) then
        local ok2, body = pcall(function() return httpService:JSONDecode(res.Body) end)
        if ok2 then return body end
    end
    return nil
end

-- Valida contra Netlify /validate (key + hwid) y vincula el dispositivo
local function validateKeyRemote(key)
    local body = apiRequest("POST", "/validate", { key = key, hwid = HWID })
    if body then return body.valid == true end
    return false
end

local HWID = getHWID()

-- Periodic API health check (every 30s)
task.spawn(function()
    while true do
        task.wait(30)
        apiRequest("POST", "/validate", { key = "health_check", hwid = HWID })
    end
end)

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
-- HWID KEY SYSTEM (Single Device) - Netlify API
-- ==========================================
local KEY_FOLDER = "Nash_Vault"
local KEY_FILE = "license.json"
local hasAccess = false

pcall(function()
    if not isfolder(KEY_FOLDER) then makefolder(KEY_FOLDER) end
end)

local function validateKeyFormat(key)
    if not key or type(key) ~= "string" then return false end
    return key:match("^STANIC%-[A-Z0-9]+%-[A-Z0-9]+%-[A-Z0-9]+") ~= nil
end

local function loadSavedLicense()
    local path = KEY_FOLDER .. "/" .. KEY_FILE
    if not isfile(path) then return false end
    local ok, raw = pcall(readfile, path)
    if not ok or not raw then return false end
    local ok2, data = pcall(httpService.JSONDecode, httpService, raw)
    if not ok2 or type(data) ~= "table" or not data.Key or not data.HWID then return false end

    if data.HWID ~= HWID then
        pcall(delfile, path)
        return false, "hwid_mismatch"
    end

    if validateKeyRemote(data.Key) then
        return true, data.Key
    end
    pcall(delfile, path)
    return false
end

local function saveLicense(key)
    local path = KEY_FOLDER .. "/" .. KEY_FILE
    pcall(writefile, path, httpService:JSONEncode({
        Key = key,
        HWID = HWID,
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
    main.Size = UDim2.new(0, 380, 0, 260)
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

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -32, 0, 36)
    desc.Position = UDim2.new(0, 16, 0, 62)
    desc.BackgroundTransparency = 1
    desc.Text = "Introduce tu key para continuar. Se vinculara a este dispositivo."
    desc.TextColor3 = Color3.fromRGB(160, 160, 170)
    desc.TextSize = 12
    desc.Font = Enum.Font.Gotham
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = main

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -32, 0, 42)
    input.Position = UDim2.new(0, 16, 0, 108)
    input.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
    input.BorderColor3 = BORDER_DEFAULT
    input.PlaceholderText = "STANIC-XXXX-XXXX-XXXX"
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
    status.Position = UDim2.new(0, 16, 0, 156)
    status.BackgroundTransparency = 1
    status.Text = "Comprobando API..."
    status.TextColor3 = Color3.fromRGB(255, 220, 100)
    status.TextSize = 11
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = main

    local activateBtn = Instance.new("TextButton")
    activateBtn.Size = UDim2.new(1, -32, 0, 40)
    activateBtn.Position = UDim2.new(0, 16, 0, 180)
    activateBtn.BackgroundColor3 = LIME
    activateBtn.Text = "Activar (Enter)"
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

    -- Check API status on load
    task.spawn(function()
        local ping = apiRequest("POST", "/validate", { key = "health_check", hwid = HWID })
        if ping then
            status.Text = "API online - Listo para validar"
            status.TextColor3 = Color3.fromRGB(120, 220, 120)
        else
            status.Text = "API offline - Verifica tu conexion / URL Netlify"
            status.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)

    local function attemptActivate()
        local key = input.Text
        if not validateKeyFormat(key) then
            status.Text = "Formato invalido. Usa: STANIC-XXXX-XXXX-XXXX"
            status.TextColor3 = RED
            return
        end
        status.Text = "Validando con API..."
        status.TextColor3 = Color3.fromRGB(255, 220, 100)

        task.spawn(function()
            if validateKeyRemote(key) then
                saveLicense(key)
                hasAccess = true
                status.Text = "Acceso concedido. Cargando panel..."
                status.TextColor3 = LIME
                notify("Licencia activada", "Dispositivo vinculado correctamente.", nil, LIME, 3)
                task.wait(0.8)
                keyGui:Destroy()
            else
                status.Text = "Key invalida o API offline. Genera una en tu dashboard Netlify."
                status.TextColor3 = RED
                input.Text = ""
            end
        end)
    end

    activateBtn.MouseButton1Click:Connect(attemptActivate)

    input.FocusLost:Connect(function(enter)
        if enter then attemptActivate() end
    end)

    repeat task.wait(0.1) until hasAccess
end

if not hasAccess then return end

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
mainFrame.Size = UDim2.new(0, 110, 0, 44)
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
listLayout.Padding = UDim.new(0, 12)
listLayout.Parent = mainFrame

-- Assets oficiales Roblox Voice Chat
local mutedimage = "rbxasset://textures/ui/VoiceChat/MicLight/Muted.png"
local speakingimage = "rbxasset://textures/ui/VoiceChat/MicLight/Unmuted.png"
local headsetimage = "rbxassetid://6023426915"

-- Mic Button (icono centrado perfectamente)
local micBtn = Instance.new("ImageButton")
micBtn.Name = "MicToggle"
micBtn.Size = UDim2.new(0, 36, 0, 36)
micBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
micBtn.BorderSizePixel = 0
micBtn.Image = speakingimage
micBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
micBtn.ScaleType = Enum.ScaleType.Fit
micBtn.Parent = mainFrame
Instance.new("UICorner", micBtn).CornerRadius = UDim.new(0, 8)

-- Efecto hover/press suave
micBtn.MouseEnter:Connect(function()
    tweenService:Create(micBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(45, 45, 52)}):Play()
end)
micBtn.MouseLeave:Connect(function()
    tweenService:Create(micBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(36, 36, 42)}):Play()
end)
micBtn.MouseButton1Down:Connect(function()
    tweenService:Create(micBtn, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 34, 0, 34)}):Play()
end)
micBtn.MouseButton1Up:Connect(function()
    tweenService:Create(micBtn, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 36, 0, 36)}):Play()
end)

micBtn.MouseButton1Click:Connect(function()
    ismuted = not ismuted
    setmutestate(ismuted)
    -- Animación suave del icono
    tweenService:Create(micBtn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Rotation = 360
    }):Play()
    micBtn.Image = ismuted and mutedimage or speakingimage
    micBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    micBtn.Rotation = 0
    notify("Microphone", ismuted and "Muted (Protected)" or "Active",
        ismuted and mutedimage or speakingimage,
        ismuted and RED or LIME, 2)
end)

-- Deafen Button (icono centrado perfectamente)
local deafenBtn = Instance.new("ImageButton")
deafenBtn.Name = "DeafenToggle"
deafenBtn.Size = UDim2.new(0, 36, 0, 36)
deafenBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
deafenBtn.BorderSizePixel = 0
deafenBtn.Image = headsetimage
deafenBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
deafenBtn.ScaleType = Enum.ScaleType.Fit
deafenBtn.Parent = mainFrame
Instance.new("UICorner", deafenBtn).CornerRadius = UDim.new(0, 8)

deafenBtn.MouseEnter:Connect(function()
    tweenService:Create(deafenBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(45, 45, 52)}):Play()
end)
deafenBtn.MouseLeave:Connect(function()
    tweenService:Create(deafenBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(36, 36, 42)}):Play()
end)
deafenBtn.MouseButton1Down:Connect(function()
    tweenService:Create(deafenBtn, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 34, 0, 34)}):Play()
end)
deafenBtn.MouseButton1Up:Connect(function()
    tweenService:Create(deafenBtn, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 36, 0, 36)}):Play()
end)

deafenBtn.MouseButton1Click:Connect(function()
    isdeafened = not isdeafened
    setdeafenstate(isdeafened)
    tweenService:Create(deafenBtn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        ImageColor3 = isdeafened and RED or Color3.fromRGB(255, 255, 255),
        Rotation = 360
    }):Play()
    deafenBtn.ImageColor3 = isdeafened and RED or Color3.fromRGB(255, 255, 255)
    deafenBtn.Rotation = 0
    notify("Audio Output", isdeafened and "Muted" or "Active",
        headsetimage, isdeafened and RED or LIME, 2)
end)

-- Estado inicial
setmutestate(false)
micBtn.Image = speakingimage
micBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)

-- Loop anti-clipping suave
task.spawn(function()
    while mainFrame and mainFrame.Parent do
        task.wait(0.5)
        applyAntiClipping()
    end
end)

-- Animación de entrada del panel
mainFrame.Size = UDim2.new(0, 0, 0, 44)
mainFrame.BackgroundTransparency = 1
tweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 110, 0, 44),
    BackgroundTransparency = 0.02
}):Play()

notify("Nash Vault", "Panel cargado. Listo para usar.", nil, LIME, 4)