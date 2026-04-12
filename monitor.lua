if _G.PevGui then _G.PevGui:Destroy() end

local player = game.Players.LocalPlayer
local char   = player.Character or player.CharacterAdded:Wait()
local hrp    = char:WaitForChild("HumanoidRootPart")
local hum    = char:WaitForChild("Humanoid")

if _G.FarmRunning     == nil then _G.FarmRunning     = false end
if _G.EscapeRunning   == nil then _G.EscapeRunning   = false end
if _G.ReviveRunning   == nil then _G.ReviveRunning   = false end
if _G.KillRunning     == nil then _G.KillRunning     = false end
if _G.SelfReviveRunning == nil then _G.SelfReviveRunning = false end
if _G.KillerSafeOn   == nil then _G.KillerSafeOn   = false end
if _G.EscapeDelay     == nil then _G.EscapeDelay     = 270  end
if _G.WebhookURL      == nil then _G.WebhookURL      = ""   end
if _G.WhEv_Loot       == nil then _G.WhEv_Loot       = false end
if _G.WhEv_Batch      == nil then _G.WhEv_Batch      = false end
if _G.WhEv_Timer      == nil then _G.WhEv_Timer      = false end
if _G.SpeedHackOn     == nil then _G.SpeedHackOn     = false end
if _G.SpeedValue      == nil then _G.SpeedValue      = 32   end
if _G.JumpHackOn      == nil then _G.JumpHackOn      = false end
if _G.JumpValue       == nil then _G.JumpValue       = 100  end
if _G.DoubleJumpOn    == nil then _G.DoubleJumpOn    = false end

local running         = false
local escapeRunning   = false
local reviveRunning   = false
local killRunning     = false
local selfReviveRunning = false
local totalCollected  = 0

-- ══════════════════════════════════════════════
--  SAVE / LOAD CONFIG (writefile/readfile Delta)
-- ══════════════════════════════════════════════
local CONFIG_FILE = "pev_stk_config.json"

local function saveConfig()
    pcall(function()
        local data = {
            FarmRunning      = _G.FarmRunning,
            EscapeRunning    = _G.EscapeRunning,
            ReviveRunning    = _G.ReviveRunning,
            KillRunning      = _G.KillRunning,
            SelfReviveRunning= _G.SelfReviveRunning,
            KillerSafeOn     = _G.KillerSafeOn,
            EscapeDelay      = _G.EscapeDelay,
            WebhookURL       = _G.WebhookURL,
            WhEv_Loot        = _G.WhEv_Loot,
            WhEv_Batch       = _G.WhEv_Batch,
            WhEv_Timer       = _G.WhEv_Timer,
            SpeedValue       = _G.SpeedValue,
            JumpValue        = _G.JumpValue,
            SpeedHackOn      = _G.SpeedHackOn,
            JumpHackOn       = _G.JumpHackOn,
            DoubleJumpOn     = _G.DoubleJumpOn,
        }
        writefile(CONFIG_FILE, game:GetService("HttpService"):JSONEncode(data))
    end)
end

local function loadConfig()
    pcall(function()
        if isfile(CONFIG_FILE) then
            local raw = readfile(CONFIG_FILE)
            local data = game:GetService("HttpService"):JSONDecode(raw)
            if data.FarmRunning       ~= nil then _G.FarmRunning       = data.FarmRunning       end
            if data.EscapeRunning     ~= nil then _G.EscapeRunning     = data.EscapeRunning     end
            if data.ReviveRunning     ~= nil then _G.ReviveRunning     = data.ReviveRunning     end
            if data.KillRunning       ~= nil then _G.KillRunning       = data.KillRunning       end
            if data.SelfReviveRunning ~= nil then _G.SelfReviveRunning = data.SelfReviveRunning end
            if data.KillerSafeOn      ~= nil then _G.KillerSafeOn      = data.KillerSafeOn      end
            if data.EscapeDelay       ~= nil then _G.EscapeDelay       = data.EscapeDelay       end
            if data.WebhookURL        ~= nil then _G.WebhookURL        = data.WebhookURL        end
            if data.WhEv_Loot         ~= nil then _G.WhEv_Loot         = data.WhEv_Loot         end
            if data.WhEv_Batch        ~= nil then _G.WhEv_Batch        = data.WhEv_Batch        end
            if data.WhEv_Timer        ~= nil then _G.WhEv_Timer        = data.WhEv_Timer        end
            if data.SpeedValue        ~= nil then _G.SpeedValue        = data.SpeedValue        end
            if data.JumpValue         ~= nil then _G.JumpValue         = data.JumpValue         end
            if data.SpeedHackOn       ~= nil then _G.SpeedHackOn       = data.SpeedHackOn       end
            if data.JumpHackOn        ~= nil then _G.JumpHackOn        = data.JumpHackOn        end
            if data.DoubleJumpOn      ~= nil then _G.DoubleJumpOn      = data.DoubleJumpOn      end
        end
    end)
end

-- Load config sebelum GUI dibuat biar nilai awal sudah benar
loadConfig()

-- forward declarations (diisi setelah UI dibuat)
local setStatus = function() end
local GUIPrint  = function() end
local updateStats = function() end

-- ══════════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
_G.PevGui = sg
sg.Name = "PevSTK"
sg.Parent = player.PlayerGui
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true

-- ══════════════════════════════════════════════
--  PALETTE — Pink/Rose dari HTML
-- ══════════════════════════════════════════════
local C = {
    bg      = Color3.fromRGB(15,  8, 12),
    panel   = Color3.fromRGB(26, 14, 21),
    sidebar = Color3.fromRGB(21, 11, 17),
    card    = Color3.fromRGB(34, 16, 24),
    card2   = Color3.fromRGB(42, 20, 32),
    accent  = Color3.fromRGB(232,121,154),
    accLt   = Color3.fromRGB(244,167,190),
    accDim  = Color3.fromRGB(61,  21, 40),
    green   = Color3.fromRGB(244,143,177),
    red     = Color3.fromRGB(240, 98,146),
    yellow  = Color3.fromRGB(255,205,210),
    cyan    = Color3.fromRGB(206,147,216),
    text    = Color3.fromRGB(253,232,239),
    sub     = Color3.fromRGB(160,112,128),
    muted   = Color3.fromRGB(92,  48, 69),
    border  = Color3.fromRGB(60,  24, 42),
}

-- ══════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════
local function stroke(p, col, th)
    local s = Instance.new("UIStroke", p)
    s.Color = col or C.border
    s.Thickness = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

local function corner(p, r)
    Instance.new("UICorner", p).CornerRadius = UDim.new(0, r or 10)
end

local function newLabel(parent, text, size, color, bold, xalign)
    local l = Instance.new("TextLabel")
    l.Parent = parent
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size or 12
    l.TextColor3 = color or C.text
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment = xalign or Enum.TextXAlignment.Center
    return l
end

-- ══════════════════════════════════════════════
--  TOUCH-SAFE CLICK (MouseButton1Click + Touch fallback)
-- ══════════════════════════════════════════════
local function onTap(btn, fn)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or
           i.UserInputType == Enum.UserInputType.MouseButton1 then
            fn()
        end
    end)
end

local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = i.Position
            startPos  = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then dragInput = i end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(i)
        if i == dragInput and dragging then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

-- ══════════════════════════════════════════════
--  TOGGLE SWITCH FACTORY
-- ══════════════════════════════════════════════
local function makeToggle(parent, xOff, activeColor)
    local TW, TH = 38, 22
    local KS = 16

    local track = Instance.new("TextButton")
    track.Parent = parent
    track.Size = UDim2.new(0, TW, 0, TH)
    track.Position = UDim2.new(1, xOff or -(TW + 10), 0.5, -TH/2)
    track.BackgroundColor3 = C.muted
    track.Text = ""
    track.BorderSizePixel = 0
    corner(track, 99)

    local knob = Instance.new("Frame")
    knob.Parent = track
    knob.Size = UDim2.new(0, KS, 0, KS)
    knob.Position = UDim2.new(0, 3, 0.5, -KS/2)
    knob.BackgroundColor3 = C.text
    knob.BorderSizePixel = 0
    corner(knob, 99)

    local state = false

    local function setState(val)
        state = val
        local col = activeColor or C.green
        track.BackgroundColor3 = val and col or C.muted
        knob.Position = val
            and UDim2.new(1, -(KS+3), 0.5, -KS/2)
            or  UDim2.new(0, 3, 0.5, -KS/2)
    end

    local function getState() return state end

    return track, setState, getState
end

-- ══════════════════════════════════════════════
--  MAIN WINDOW — 500 x 400
-- ══════════════════════════════════════════════
local WIN_W = 500
local WIN_H = 400

local win = Instance.new("Frame")
win.Name = "PevWin"
win.Parent = sg
win.Size = UDim2.new(0, WIN_W, 0, WIN_H)
win.Position = UDim2.new(0.02, 0, 0.03, 0)
win.BackgroundColor3 = C.panel
win.BorderSizePixel = 0
corner(win, 14)
stroke(win, C.border, 1)

-- ══════════════════════════════════════════════
--  TITLE BAR (44px) — mirip HTML
-- ══════════════════════════════════════════════
local titlebar = Instance.new("Frame")
titlebar.Parent = win
titlebar.Size = UDim2.new(1, 0, 0, 44)
titlebar.BackgroundColor3 = C.sidebar
titlebar.BorderSizePixel = 0
corner(titlebar, 14)

local tbFix = Instance.new("Frame")
tbFix.Parent = win
tbFix.Size = UDim2.new(1, 0, 0, 10)
tbFix.Position = UDim2.new(0, 0, 0, 34)
tbFix.BackgroundColor3 = C.sidebar
tbFix.BorderSizePixel = 0

local tbBorderLine = Instance.new("Frame")
tbBorderLine.Parent = win
tbBorderLine.Size = UDim2.new(1, 0, 0, 1)
tbBorderLine.Position = UDim2.new(0, 0, 0, 44)
tbBorderLine.BackgroundColor3 = C.border
tbBorderLine.BorderSizePixel = 0

-- brand icon (circle)
local avatarF = Instance.new("Frame")
avatarF.Parent = titlebar
avatarF.Size = UDim2.new(0, 26, 0, 26)
avatarF.Position = UDim2.new(0, 12, 0.5, -13)
avatarF.BackgroundColor3 = Color3.fromRGB(42, 15, 26)
avatarF.BorderSizePixel = 0
corner(avatarF, 99)
stroke(avatarF, Color3.fromRGB(122, 37, 69), 1.5)
local avatarLbl = newLabel(avatarF, "P", 10, C.accLt, true)
avatarLbl.Size = UDim2.new(1,0,1,0)

-- brand name
local brandName = newLabel(titlebar, "pev | STK", 13, C.text, true, Enum.TextXAlignment.Left)
brandName.Size = UDim2.new(0, 80, 1, 0)
brandName.Position = UDim2.new(0, 46, 0, 0)

-- version badge
local badgeF = Instance.new("Frame")
badgeF.Parent = titlebar
badgeF.Size = UDim2.new(0, 66, 0, 20)
badgeF.Position = UDim2.new(0, 134, 0.5, -10)
badgeF.BackgroundColor3 = C.accDim
badgeF.BorderSizePixel = 0
corner(badgeF, 20)
stroke(badgeF, Color3.fromRGB(122, 37, 69), 1)
local badgeTxt = newLabel(badgeF, "v3.0", 10, C.accLt, true)
badgeTxt.Size = UDim2.new(1,0,1,0)

-- status dot + text
local tbDotF = Instance.new("Frame")
tbDotF.Name = "TbDotF"
tbDotF.Parent = titlebar
tbDotF.Size = UDim2.new(0, 7, 0, 7)
tbDotF.Position = UDim2.new(1, -90, 0.5, -3)
tbDotF.BackgroundColor3 = C.red
tbDotF.BorderSizePixel = 0
corner(tbDotF, 99)

local tbDotTxt = newLabel(titlebar, "Idle", 10, C.sub, false, Enum.TextXAlignment.Left)
tbDotTxt.Name = "TbDotTxt"
tbDotTxt.Size = UDim2.new(0, 50, 1, 0)
tbDotTxt.Position = UDim2.new(1, -80, 0, 0)

-- minimize button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Parent = titlebar
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -62, 0.5, -12)
minimizeBtn.BackgroundColor3 = C.accDim
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = C.sub
minimizeBtn.TextSize = 11
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
corner(minimizeBtn, 7)
stroke(minimizeBtn, C.border, 1)

-- close button
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titlebar
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0.5, -12)
closeBtn.BackgroundColor3 = C.accDim
closeBtn.Text = "✕"
closeBtn.TextColor3 = C.sub
closeBtn.TextSize = 11
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
corner(closeBtn, 7)
stroke(closeBtn, C.border, 1)

-- ── FLOATING BUBBLE (muncul saat minimize/hide) ──
local bubble = Instance.new("TextButton")
bubble.Parent = sg
bubble.Size = UDim2.new(0, 52, 0, 52)
bubble.Position = UDim2.new(0, 16, 0.5, -26)
bubble.BackgroundColor3 = C.accDim
bubble.Text = "P"
bubble.TextColor3 = C.accLt
bubble.TextSize = 20
bubble.Font = Enum.Font.GothamBold
bubble.BorderSizePixel = 0
bubble.Visible = false
bubble.ZIndex = 10
corner(bubble, 99)
stroke(bubble, C.accent, 2)

makeDraggable(bubble, bubble)

makeDraggable(win, titlebar)

-- ══════════════════════════════════════════════
--  BODY = SIDEBAR + CONTENT
-- ══════════════════════════════════════════════
local bodyF = Instance.new("Frame")
bodyF.Parent = win
bodyF.Size = UDim2.new(1, 0, 1, -45)
bodyF.Position = UDim2.new(0, 0, 0, 45)
bodyF.BackgroundTransparency = 1

-- ── SIDEBAR (118px) ──────────────────────────
local SIDEBAR_W = 118

local sidebar = Instance.new("Frame")
sidebar.Parent = bodyF
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, 0)
sidebar.BackgroundColor3 = C.sidebar
sidebar.BorderSizePixel = 0

local sbRoundFix = Instance.new("Frame")
sbRoundFix.Parent = bodyF
sbRoundFix.Size = UDim2.new(0, SIDEBAR_W, 0, 14)
sbRoundFix.Position = UDim2.new(0, 0, 1, -14)
sbRoundFix.BackgroundColor3 = C.sidebar
sbRoundFix.BorderSizePixel = 0
corner(sbRoundFix, 14)

local sbBorderLine = Instance.new("Frame")
sbBorderLine.Parent = bodyF
sbBorderLine.Size = UDim2.new(0, 1, 1, 0)
sbBorderLine.Position = UDim2.new(0, SIDEBAR_W, 0, 0)
sbBorderLine.BackgroundColor3 = C.border
sbBorderLine.BorderSizePixel = 0

local sbNavList = Instance.new("Frame")
sbNavList.Parent = sidebar
sbNavList.Size = UDim2.new(1, -16, 1, -56)
sbNavList.Position = UDim2.new(0, 8, 0, 8)
sbNavList.BackgroundTransparency = 1

local sbListLayout = Instance.new("UIListLayout", sbNavList)
sbListLayout.SortOrder = Enum.SortOrder.LayoutOrder
sbListLayout.Padding = UDim.new(0, 1)

-- sidebar bottom status card
local sbBottom = Instance.new("Frame")
sbBottom.Parent = sidebar
sbBottom.Size = UDim2.new(1, -16, 0, 36)
sbBottom.Position = UDim2.new(0, 8, 1, -44)
sbBottom.BackgroundColor3 = C.card
sbBottom.BorderSizePixel = 0
corner(sbBottom, 8)
stroke(sbBottom, C.border, 1)

local sbDot = Instance.new("Frame")
sbDot.Name = "SbDot"
sbDot.Parent = sbBottom
sbDot.Size = UDim2.new(0, 7, 0, 7)
sbDot.Position = UDim2.new(0, 10, 0.5, -3)
sbDot.BackgroundColor3 = C.red
sbDot.BorderSizePixel = 0
corner(sbDot, 99)

local sbTxt = newLabel(sbBottom, "Idle", 11, C.sub, false, Enum.TextXAlignment.Left)
sbTxt.Name = "SbTxt"
sbTxt.Size = UDim2.new(1, -26, 1, 0)
sbTxt.Position = UDim2.new(0, 22, 0, 0)

-- ── CONTENT AREA ────────────────────────────
local contentArea = Instance.new("Frame")
contentArea.Parent = bodyF
contentArea.Size = UDim2.new(1, -(SIDEBAR_W+1), 1, 0)
contentArea.Position = UDim2.new(0, SIDEBAR_W+1, 0, 0)
contentArea.BackgroundTransparency = 1

-- panel header
local panelHdr = Instance.new("Frame")
panelHdr.Parent = contentArea
panelHdr.Size = UDim2.new(1, -20, 0, 38)
panelHdr.Position = UDim2.new(0, 10, 0, 6)
panelHdr.BackgroundTransparency = 1

local panelTitle = newLabel(panelHdr, "Main", 14, C.text, true, Enum.TextXAlignment.Left)
panelTitle.Name = "PanelTitle"
panelTitle.Size = UDim2.new(1, 0, 0.5, 0)

local panelSub = newLabel(panelHdr, "Auto Farm & core features", 10, C.sub, false, Enum.TextXAlignment.Left)
panelSub.Name = "PanelSub"
panelSub.Size = UDim2.new(1, 0, 0.5, 0)
panelSub.Position = UDim2.new(0, 0, 0.5, 0)

local phDivLine = Instance.new("Frame")
phDivLine.Parent = contentArea
phDivLine.Size = UDim2.new(1, -20, 0, 1)
phDivLine.Position = UDim2.new(0, 10, 0, 45)
phDivLine.BackgroundColor3 = C.border
phDivLine.BorderSizePixel = 0

local pageScroll = Instance.new("ScrollingFrame")
pageScroll.Parent = contentArea
pageScroll.Size = UDim2.new(1, -10, 1, -52)
pageScroll.Position = UDim2.new(0, 5, 0, 50)
pageScroll.BackgroundTransparency = 1
pageScroll.BorderSizePixel = 0
pageScroll.ScrollBarThickness = 2
pageScroll.ScrollBarImageColor3 = C.accent
pageScroll.CanvasSize = UDim2.new(0, 0, 0, 900)

-- ══════════════════════════════════════════════
--  NAV ITEM FACTORY
-- ══════════════════════════════════════════════
local navItems = {}
local TAB_DATA = {
    { id = "Main",   sym = "AF", label = "Main"   },
    { id = "Player", sym = "PL", label = "Player" },
    { id = "Visual", sym = "VS", label = "Visual" },
    { id = "Misc",   sym = "MX", label = "Misc"   },
}
local TAB_INFO = {
    Main   = { title = "Main",   sub = "Auto Farm & core features"        },
    Player = { title = "Player", sub = "Speed · Jump · Double Jump"       },
    Visual = { title = "Visual", sub = "ESP highlight & world scan"       },
    Misc   = { title = "Misc",   sub = "AFK · Timing Escape · Webhook"    },
}

for i, td in ipairs(TAB_DATA) do
    local navBtn = Instance.new("TextButton")
    navBtn.Parent = sbNavList
    navBtn.Size = UDim2.new(1, 0, 0, 38)
    navBtn.LayoutOrder = i
    navBtn.BackgroundTransparency = 1
    navBtn.Text = ""
    navBtn.BorderSizePixel = 0
    corner(navBtn, 9)

    -- active indicator bar (left side — sama kayak HTML)
    local indBar = Instance.new("Frame")
    indBar.Parent = navBtn
    indBar.Size = UDim2.new(0, 2.5, 0.5, 0)
    indBar.Position = UDim2.new(0, 0, 0.25, 0)
    indBar.BackgroundColor3 = C.accent
    indBar.BorderSizePixel = 0
    corner(indBar, 3)
    indBar.Visible = false

    -- sym box (mirip .nav-sym di HTML)
    local symL = newLabel(navBtn, td.sym, 9, C.accent, true)
    symL.Size = UDim2.new(0, 22, 1, 0)
    symL.Position = UDim2.new(0, 9, 0, 0)

    local labelL = newLabel(navBtn, td.label, 12, C.sub, true, Enum.TextXAlignment.Left)
    labelL.Size = UDim2.new(1, -36, 1, 0)
    labelL.Position = UDim2.new(0, 34, 0, 0)

    navItems[td.id] = { btn=navBtn, indBar=indBar, symL=symL, labelL=labelL }
end

-- ══════════════════════════════════════════════
--  PAGES
-- ══════════════════════════════════════════════
local pages = {}
local function makePage()
    local f = Instance.new("Frame")
    f.Parent = pageScroll
    f.Size = UDim2.new(1, 0, 0, 700)
    f.Position = UDim2.new(10, 0, 0, 0) -- mulai di luar layar
    f.BackgroundTransparency = 1
    f.Visible = true
    return f
end

-- ══════════════════════════════════════════════
--  FEATURE ROW FACTORY (card style — mirip .row di HTML)
-- ══════════════════════════════════════════════
local function makeFeatureRow(parent, yOff, sym, symColor, title, sub, comingSoon, toggleColor)
    local ROW_H = 50
    local row = Instance.new("Frame")
    row.Parent = parent
    row.Size = UDim2.new(1, -10, 0, ROW_H)
    row.Position = UDim2.new(0, 5, 0, yOff)
    row.BackgroundColor3 = C.card
    row.BorderSizePixel = 0
    corner(row, 9)
    stroke(row, C.border, 1)

    -- icon box (mirip .row-icon di HTML)
    local iconF = Instance.new("Frame")
    iconF.Parent = row
    iconF.Size = UDim2.new(0, 28, 0, 28)
    iconF.Position = UDim2.new(0, 8, 0.5, -14)
    iconF.BackgroundColor3 = C.accDim
    iconF.BorderSizePixel = 0
    corner(iconF, 7)
    local iconL = newLabel(iconF, sym, 9, symColor or C.accLt, true)
    iconL.Size = UDim2.new(1,0,1,0)

    local titleL = newLabel(row, title, 12, C.text, true, Enum.TextXAlignment.Left)
    titleL.Size = UDim2.new(0, 160, 0, 18)
    titleL.Position = UDim2.new(0, 44, 0, 8)

    local subL = newLabel(row, sub, 10, C.sub, false, Enum.TextXAlignment.Left)
    subL.Size = UDim2.new(0, 170, 0, 14)
    subL.Position = UDim2.new(0, 44, 0, 27)

    if comingSoon then
        local csF = Instance.new("Frame")
        csF.Parent = row
        csF.Size = UDim2.new(0, 72, 0, 22)
        csF.Position = UDim2.new(1, -80, 0.5, -11)
        csF.BackgroundColor3 = C.accDim
        csF.BorderSizePixel = 0
        corner(csF, 20)
        stroke(csF, C.border, 1)
        local csL = newLabel(csF, "Soon", 10, C.sub, true)
        csL.Size = UDim2.new(1,0,1,0)
        return row, nil, nil, nil
    else
        local tgl, setState, getState = makeToggle(row, -(38 + 8), toggleColor)
        return row, tgl, setState, getState
    end
end

-- ══════════════════════════════════════════════
--  PAGE: MAIN
-- ══════════════════════════════════════════════
pages.Main = makePage()

local statusPill = Instance.new("Frame")
statusPill.Parent = pages.Main
statusPill.Size = UDim2.new(1, -10, 0, 28)
statusPill.Position = UDim2.new(0, 5, 0, 0)
statusPill.BackgroundColor3 = C.bg
statusPill.BorderSizePixel = 0
corner(statusPill, 8)
stroke(statusPill, C.border, 1)

local sDot = Instance.new("Frame")
sDot.Parent = statusPill
sDot.Size = UDim2.new(0, 7, 0, 7)
sDot.Position = UDim2.new(0, 10, 0.5, -3)
sDot.BackgroundColor3 = C.red
sDot.BorderSizePixel = 0
corner(sDot, 99)

local statusLbl = newLabel(statusPill, "Idle — menunggu", 11, C.sub, false, Enum.TextXAlignment.Left)
statusLbl.Size = UDim2.new(1, -26, 1, 0)
statusLbl.Position = UDim2.new(0, 22, 0, 0)

-- stats row
local statsRow = Instance.new("Frame")
statsRow.Parent = pages.Main
statsRow.Size = UDim2.new(1, -10, 0, 42)
statsRow.Position = UDim2.new(0, 5, 0, 34)
statsRow.BackgroundTransparency = 1

local function makeStatCard(parent, xScale, xOff, valCol, lbl)
    local f = Instance.new("Frame")
    f.Parent = parent
    f.Size = UDim2.new(0.5, -4, 1, 0)
    f.Position = UDim2.new(xScale, xOff, 0, 0)
    f.BackgroundColor3 = C.bg
    f.BorderSizePixel = 0
    corner(f, 8)
    stroke(f, C.border, 1)
    local v = newLabel(f, "0", 15, valCol, true)
    v.Size = UDim2.new(1, 0, 0.55, 0)
    local l2 = newLabel(f, lbl, 10, C.sub, false)
    l2.Size = UDim2.new(1, 0, 0.45, 0)
    l2.Position = UDim2.new(0, 0, 0.55, 0)
    return v
end

local s1val = makeStatCard(statsRow, 0,   0, C.green,  "Collected")
local s2val = makeStatCard(statsRow, 0.5, 4, C.yellow, "Di Area")

-- ── Section Helper: label pembatas ─────────────
local function makeSectionLabel(parent, yOff, labelText, col)
    local lineL = Instance.new("Frame")
    lineL.Parent = parent
    lineL.Size = UDim2.new(0, 18, 0, 1)
    lineL.Position = UDim2.new(0, 5, 0, yOff + 8)
    lineL.BackgroundColor3 = col or C.muted
    lineL.BorderSizePixel = 0

    local lbl = newLabel(parent, labelText, 9, col or C.muted, true, Enum.TextXAlignment.Left)
    lbl.Size = UDim2.new(0, 80, 0, 16)
    lbl.Position = UDim2.new(0, 26, 0, yOff)

    local lineR = Instance.new("Frame")
    lineR.Parent = parent
    lineR.Size = UDim2.new(1, -114, 0, 1)
    lineR.Position = UDim2.new(0, 108, 0, yOff + 8)
    lineR.BackgroundColor3 = col or C.muted
    lineR.BorderSizePixel = 0
end

-- ── SECTION: SURVIVOR ───────────────────────
makeSectionLabel(pages.Main, 82, "— SURVIVOR —", C.cyan)

local _, farmTgl,       setFarmCb,       getFarmCb       = makeFeatureRow(pages.Main, 100, "AF", C.green,  "Auto Farm",        "Max 50 loot/batch · CD 2s",     false, C.green)
local _, escapeTgl,     setEscapeCb,     getEscapeCb     = makeFeatureRow(pages.Main, 156, "AE", C.cyan,   "Auto Escape",      "Teleport ke ExitGateway",       false, C.cyan)
local _, reviveTgl,     setReviveCb,     getReviveCb     = makeFeatureRow(pages.Main, 212, "RV", C.yellow, "Auto Revive",      "TP ke teman yang knocked",      false, C.yellow)
local _, selfReviveTgl, setSelfReviveCb, getSelfReviveCb = makeFeatureRow(pages.Main, 268, "SR", C.cyan,   "Auto Self-Revive", "Cek killer sebelum revive",     false, C.cyan)

-- ── SECTION: KILLER ─────────────────────────
makeSectionLabel(pages.Main, 332, "— KILLER —", C.red)

local _, killTgl,       setKillCb,       getKillCb       = makeFeatureRow(pages.Main, 350, "AK", C.red,    "Auto Kill",        "Tarik player saat jadi killer", false, C.red)
local _, killerSafeTgl, setKillerSafeCb, getKillerSafeCb = makeFeatureRow(pages.Main, 406, "KS", C.red,    "Killer Safe",      "TP jauh jika killer < 20 studs",false, C.red)

-- ══════════════════════════════════════════════
--  PAGE: PLAYER  (Speed / Jump / Double Jump)
-- ══════════════════════════════════════════════
pages.Player = makePage()

-- ── Speed Hack ──────────────────────────────
local _, speedTgl, setSpeedCb, getSpeedCb = makeFeatureRow(
    pages.Player, 0, "SP", C.green, "Speed Hack", "Ubah WalkSpeed karakter", false, C.green
)

local speedCard = Instance.new("Frame")
speedCard.Parent = pages.Player
speedCard.Size = UDim2.new(1, -10, 0, 52)
speedCard.Position = UDim2.new(0, 5, 0, 56)
speedCard.BackgroundColor3 = C.card
speedCard.BorderSizePixel = 0
corner(speedCard, 9)
stroke(speedCard, C.border, 1)

local spLbl = newLabel(speedCard, "WalkSpeed", 11, C.sub, false, Enum.TextXAlignment.Left)
spLbl.Size = UDim2.new(0, 100, 0.5, 0)
spLbl.Position = UDim2.new(0, 12, 0, 0)

local spValLbl = newLabel(speedCard, tostring(_G.SpeedValue), 13, C.accent, true, Enum.TextXAlignment.Right)
spValLbl.Size = UDim2.new(0, 40, 0.5, 0)
spValLbl.Position = UDim2.new(1, -52, 0, 0)

-- minus / plus buttons
local spMinus = Instance.new("TextButton")
spMinus.Parent = speedCard
spMinus.Size = UDim2.new(0, 30, 0, 26)
spMinus.Position = UDim2.new(0, 10, 0.5, 0)
spMinus.BackgroundColor3 = C.accDim
spMinus.Text = "−"
spMinus.TextColor3 = C.accLt
spMinus.TextSize = 14
spMinus.Font = Enum.Font.GothamBold
spMinus.BorderSizePixel = 0
corner(spMinus, 7)

local spPlus = Instance.new("TextButton")
spPlus.Parent = speedCard
spPlus.Size = UDim2.new(0, 30, 0, 26)
spPlus.Position = UDim2.new(0, 46, 0.5, 0)
spPlus.BackgroundColor3 = C.accDim
spPlus.Text = "+"
spPlus.TextColor3 = C.accLt
spPlus.TextSize = 14
spPlus.Font = Enum.Font.GothamBold
spPlus.BorderSizePixel = 0
corner(spPlus, 7)

local spSlider = Instance.new("Frame")
spSlider.Parent = speedCard
spSlider.Size = UDim2.new(1, -96, 0, 8)
spSlider.Position = UDim2.new(0, 86, 0.5, -4)
spSlider.BackgroundColor3 = C.muted
spSlider.BorderSizePixel = 0
corner(spSlider, 4)
stroke(spSlider, C.border, 1)

local spFill = Instance.new("Frame")
spFill.Parent = spSlider
spFill.Size = UDim2.new(_G.SpeedValue / 100, 0, 1, 0)
spFill.BackgroundColor3 = C.accent
spFill.BorderSizePixel = 0
corner(spFill, 4)

local function applySpeed()
    local c = player.Character
    if not c then return end
    local h = c:FindFirstChild("Humanoid")
    if h then h.WalkSpeed = _G.SpeedValue end
end

local function updateSpeedUI()
    spValLbl.Text = tostring(_G.SpeedValue)
    spFill.Size = UDim2.new(math.clamp(_G.SpeedValue / 100, 0, 1), 0, 1, 0)
    if getSpeedCb() then applySpeed() end
end

onTap(spMinus, function()
    _G.SpeedValue = math.max(16, _G.SpeedValue - 8)
    updateSpeedUI()
    saveConfig()
end)
onTap(spPlus, function()
    _G.SpeedValue = math.min(200, _G.SpeedValue + 8)
    updateSpeedUI()
    saveConfig()
end)

onTap(speedTgl, function()
    local val = not getSpeedCb()
    setSpeedCb(val)
    _G.SpeedHackOn = val
    if val then
        applySpeed()
        GUIPrint("⚡ Speed Hack ON — WalkSpeed ".._G.SpeedValue, C.green)
    else
        local c = player.Character
        if c then
            local h = c:FindFirstChild("Humanoid")
            if h then h.WalkSpeed = 16 end
        end
        GUIPrint("⚡ Speed Hack OFF", C.sub)
    end
    saveConfig()
end)

-- ── Jump Hack ───────────────────────────────
local _, jumpTgl, setJumpCb, getJumpCb = makeFeatureRow(
    pages.Player, 114, "JH", C.yellow, "Jump Hack", "Ubah JumpPower karakter", false, C.yellow
)

local jumpCard = Instance.new("Frame")
jumpCard.Parent = pages.Player
jumpCard.Size = UDim2.new(1, -10, 0, 52)
jumpCard.Position = UDim2.new(0, 5, 0, 170)
jumpCard.BackgroundColor3 = C.card
jumpCard.BorderSizePixel = 0
corner(jumpCard, 9)
stroke(jumpCard, C.border, 1)

local jpLbl = newLabel(jumpCard, "JumpPower", 11, C.sub, false, Enum.TextXAlignment.Left)
jpLbl.Size = UDim2.new(0, 100, 0.5, 0)
jpLbl.Position = UDim2.new(0, 12, 0, 0)

local jpValLbl = newLabel(jumpCard, tostring(_G.JumpValue), 13, C.yellow, true, Enum.TextXAlignment.Right)
jpValLbl.Size = UDim2.new(0, 40, 0.5, 0)
jpValLbl.Position = UDim2.new(1, -52, 0, 0)

local jpMinus = Instance.new("TextButton")
jpMinus.Parent = jumpCard
jpMinus.Size = UDim2.new(0, 30, 0, 26)
jpMinus.Position = UDim2.new(0, 10, 0.5, 0)
jpMinus.BackgroundColor3 = C.accDim
jpMinus.Text = "−"
jpMinus.TextColor3 = C.accLt
jpMinus.TextSize = 14
jpMinus.Font = Enum.Font.GothamBold
jpMinus.BorderSizePixel = 0
corner(jpMinus, 7)

local jpPlus = Instance.new("TextButton")
jpPlus.Parent = jumpCard
jpPlus.Size = UDim2.new(0, 30, 0, 26)
jpPlus.Position = UDim2.new(0, 46, 0.5, 0)
jpPlus.BackgroundColor3 = C.accDim
jpPlus.Text = "+"
jpPlus.TextColor3 = C.accLt
jpPlus.TextSize = 14
jpPlus.Font = Enum.Font.GothamBold
jpPlus.BorderSizePixel = 0
corner(jpPlus, 7)

local jpSlider = Instance.new("Frame")
jpSlider.Parent = jumpCard
jpSlider.Size = UDim2.new(1, -96, 0, 8)
jpSlider.Position = UDim2.new(0, 86, 0.5, -4)
jpSlider.BackgroundColor3 = C.muted
jpSlider.BorderSizePixel = 0
corner(jpSlider, 4)
stroke(jpSlider, C.border, 1)

local jpFill = Instance.new("Frame")
jpFill.Parent = jpSlider
jpFill.Size = UDim2.new(_G.JumpValue / 300, 0, 1, 0)
jpFill.BackgroundColor3 = C.yellow
jpFill.BorderSizePixel = 0
corner(jpFill, 4)

local function applyJump()
    local c = player.Character
    if not c then return end
    local h = c:FindFirstChild("Humanoid")
    if h then h.JumpPower = _G.JumpValue end
end

local function updateJumpUI()
    jpValLbl.Text = tostring(_G.JumpValue)
    jpFill.Size = UDim2.new(math.clamp(_G.JumpValue / 300, 0, 1), 0, 1, 0)
    if getJumpCb() then applyJump() end
end

onTap(jpMinus, function()
    _G.JumpValue = math.max(7, _G.JumpValue - 10)
    updateJumpUI()
    saveConfig()
end)
onTap(jpPlus, function()
    _G.JumpValue = math.min(300, _G.JumpValue + 10)
    updateJumpUI()
    saveConfig()
end)

onTap(jumpTgl, function()
    local val = not getJumpCb()
    setJumpCb(val)
    _G.JumpHackOn = val
    if val then
        applyJump()
        GUIPrint("🦘 Jump Hack ON — JumpPower ".._G.JumpValue, C.yellow)
    else
        local c = player.Character
        if c then
            local h = c:FindFirstChild("Humanoid")
            if h then h.JumpPower = 7.2 end
        end
        GUIPrint("🦘 Jump Hack OFF", C.sub)
    end
    saveConfig()
end)

-- ── Double Jump ─────────────────────────────
local _, djTgl, setDjCb, getDjCb = makeFeatureRow(
    pages.Player, 228, "DJ", C.cyan, "Double Jump", "Tekan jump lagi saat di udara", false, C.cyan
)

local djConn
local djCanJump = false

local function enableDoubleJump()
    local UIS = game:GetService("UserInputService")
    djConn = UIS.JumpRequest:Connect(function()
        local c = player.Character
        if not c then return end
        local h = c:FindFirstChild("Humanoid")
        local hrpC = c:FindFirstChild("HumanoidRootPart")
        if not h or not hrpC then return end
        if h:GetState() == Enum.HumanoidStateType.Freefall and djCanJump then
            djCanJump = false
            hrpC.Velocity = Vector3.new(hrpC.Velocity.X, _G.JumpValue * 0.6, hrpC.Velocity.Z)
            GUIPrint("🌀 Double Jump!", C.cyan)
        end
    end)
    -- reset djCanJump saat landing atau jumping
    game:GetService("RunService").Heartbeat:Connect(function()
        if not getDjCb() then return end
        local c = player.Character
        if not c then return end
        local h = c:FindFirstChild("Humanoid")
        if not h then return end
        local st = h:GetState()
        if st == Enum.HumanoidStateType.Jumping then
            djCanJump = true
        elseif st == Enum.HumanoidStateType.Landed then
            djCanJump = true
        end
    end)
end

onTap(djTgl, function()
    local val = not getDjCb()
    setDjCb(val)
    _G.DoubleJumpOn = val
    if val then
        djCanJump = true
        enableDoubleJump()
        GUIPrint("🌀 Double Jump ON", C.cyan)
    else
        if djConn then djConn:Disconnect() djConn = nil end
        GUIPrint("🌀 Double Jump OFF", C.sub)
    end
    saveConfig()
end)

if _G.DoubleJumpOn then
    setDjCb(true)
    djCanJump = true
    enableDoubleJump()
end

if _G.SpeedHackOn then
    setSpeedCb(true)
    applySpeed()
end

if _G.JumpHackOn then
    setJumpCb(true)
    applyJump()
end

-- ══════════════════════════════════════════════
--  PAGE: VISUAL — ESP
-- ══════════════════════════════════════════════
pages.Visual = makePage()

local espHighlights = { Killer={}, Loot={}, Survivor={} }
local espActive     = { Killer=false, Loot=false, Survivor=false }

local espColors = {
    Killer   = { fill = Color3.fromRGB(240,98,146),   outline = Color3.fromRGB(255,140,170) },
    Loot     = { fill = Color3.fromRGB(255,205,210),  outline = Color3.fromRGB(255,230,235) },
    Survivor = { fill = Color3.fromRGB(206,147,216),  outline = Color3.fromRGB(220,180,235) },
}

local function isLootModel(obj)
    if not obj:IsA("Model") then return false end
    local p = obj.Parent
    if not p then return false end
    return p.Name:match("^%d+$") ~= nil
end

local function getTargets(espType)
    local targets = {}
    if espType == "Killer" then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                local name = obj.Name:lower()
                if name:find("killer") or name:find("monster") or name:find("enemy") then
                    table.insert(targets, obj)
                end
            end
        end
    elseif espType == "Loot" then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if isLootModel(obj) then table.insert(targets, obj) end
        end
    elseif espType == "Survivor" then
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                table.insert(targets, p.Character)
            end
        end
    end
    return targets
end

local function clearESP(espType)
    for _, hl in ipairs(espHighlights[espType]) do
        pcall(function() hl:Destroy() end)
    end
    espHighlights[espType] = {}
end

local function applyESP(espType)
    clearESP(espType)
    local col = espColors[espType]
    task.spawn(function()
        while espActive[espType] do
            local keep = {}
            for _, hl in ipairs(espHighlights[espType]) do
                if hl and hl.Parent then table.insert(keep, hl) end
            end
            espHighlights[espType] = keep
            local existing = {}
            for _, hl in ipairs(espHighlights[espType]) do
                if hl.Adornee then existing[hl.Adornee] = true end
            end
            for _, target in ipairs(getTargets(espType)) do
                if not existing[target] then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = target
                    hl.FillColor = col.fill
                    hl.OutlineColor = col.outline
                    hl.FillTransparency = 0.45
                    hl.OutlineTransparency = 0
                    hl.Parent = target
                    table.insert(espHighlights[espType], hl)
                end
            end
            task.wait(2)
        end
    end)
end

local espSectionLbl = newLabel(pages.Visual, "ESP Highlight", 9.5, C.muted, true, Enum.TextXAlignment.Left)
espSectionLbl.Size = UDim2.new(1, -10, 0, 20)
espSectionLbl.Position = UDim2.new(0, 5, 0, 2)

local espDefs = {
    {"KL", C.red,    "ESP Killer",   "Red highlight killer di map",   "Killer"},
    {"LT", C.yellow, "ESP Loot",     "Yellow highlight semua loot",   "Loot"},
    {"SV", C.cyan,   "ESP Survivor", "Cyan highlight semua survivor", "Survivor"},
}

for i, def in ipairs(espDefs) do
    local sym, col, title, sub, espType = def[1], def[2], def[3], def[4], def[5]
    local _, tgl, setCb, getCb = makeFeatureRow(pages.Visual, 22 + (i-1)*56, sym, col, title, sub, false, col)
    onTap(tgl, function()
        local val = not getCb()
        setCb(val)
        espActive[espType] = val
        if val then
            applyESP(espType)
            GUIPrint("👁 "..title.." ON", col)
        else
            clearESP(espType)
            GUIPrint("👁 "..title.." OFF", C.sub)
        end
    end)
end

-- ══════════════════════════════════════════════
--  PAGE: MISC
-- ══════════════════════════════════════════════
pages.Misc = makePage()

-- AFK Mode
local _, afkTgl, setAfkCb, getAfkCb = makeFeatureRow(
    pages.Misc, 0, "AK", C.cyan, "AFK Mode", "Anti-kick saat idle", false, C.cyan
)
local afkConn
onTap(afkTgl, function()
    local val = not getAfkCb()
    setAfkCb(val)
    if val then
        -- Gerakin karakter micro-movement tiap 25 detik biar ga ke-kick idle
        -- Cara yang beneran works: listen Idled event lalu simulate input via VirtualUser
        local VU = game:GetService("VirtualUser")
        afkConn = game:GetService("Players").LocalPlayer.Idled:Connect(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new(0, 0))
        end)
        GUIPrint("🌙 AFK Mode ON", C.cyan)
    else
        if afkConn then afkConn:Disconnect() afkConn = nil end
        GUIPrint("🌙 AFK Mode OFF", C.sub)
    end
end)

-- Escape Timing Card
local escCard = Instance.new("Frame")
escCard.Parent = pages.Misc
escCard.Size = UDim2.new(1, -10, 0, 86)
escCard.Position = UDim2.new(0, 5, 0, 56)
escCard.BackgroundColor3 = C.card
escCard.BorderSizePixel = 0
corner(escCard, 9)
stroke(escCard, C.border, 1)

local escCardTitle = newLabel(escCard, "⏱  Timing Escape (detik)", 12, C.text, true, Enum.TextXAlignment.Left)
escCardTitle.Size = UDim2.new(1,-12, 0, 24)
escCardTitle.Position = UDim2.new(0, 12, 0, 4)

local escSubL = newLabel(escCard, "Default: 270 (= 4.5 menit). Total ronde 5 menit.", 10, C.sub, false, Enum.TextXAlignment.Left)
escSubL.Size = UDim2.new(1,-24, 0, 14)
escSubL.Position = UDim2.new(0, 12, 0, 26)

local escInputBg = Instance.new("Frame")
escInputBg.Parent = escCard
escInputBg.Size = UDim2.new(0.55, -8, 0, 26)
escInputBg.Position = UDim2.new(0, 12, 0, 46)
escInputBg.BackgroundColor3 = C.bg
escInputBg.BorderSizePixel = 0
corner(escInputBg, 7)
stroke(escInputBg, C.border, 1)

local escTimingBox = Instance.new("TextBox")
escTimingBox.Parent = escInputBg
escTimingBox.Size = UDim2.new(1,-10, 1, 0)
escTimingBox.Position = UDim2.new(0, 8, 0, 0)
escTimingBox.BackgroundTransparency = 1
escTimingBox.PlaceholderText = "270"
escTimingBox.Text = tostring(_G.EscapeDelay)
escTimingBox.TextColor3 = C.text
escTimingBox.PlaceholderColor3 = C.sub
escTimingBox.TextSize = 12
escTimingBox.Font = Enum.Font.GothamBold
escTimingBox.TextXAlignment = Enum.TextXAlignment.Left
escTimingBox.ClearTextOnFocus = false

local escSaveBtn = Instance.new("TextButton")
escSaveBtn.Parent = escCard
escSaveBtn.Size = UDim2.new(0.45, -8, 0, 26)
escSaveBtn.Position = UDim2.new(0.55, 4, 0, 46)
escSaveBtn.BackgroundColor3 = C.accent
escSaveBtn.Text = "💾 Simpan"
escSaveBtn.TextColor3 = C.text
escSaveBtn.TextSize = 11
escSaveBtn.Font = Enum.Font.GothamBold
escSaveBtn.BorderSizePixel = 0
corner(escSaveBtn, 7)

onTap(escSaveBtn, function()
    local val = tonumber(escTimingBox.Text)
    if val and val > 0 and val < 300 then
        _G.EscapeDelay = val
        saveConfig()
        escSaveBtn.Text = "✅ Tersimpan!"
        task.delay(2, function()
            if escSaveBtn and escSaveBtn.Parent then escSaveBtn.Text = "💾 Simpan" end
        end)
    else
        escSaveBtn.Text = "❌ 1-299 aja"
        task.delay(2, function()
            if escSaveBtn and escSaveBtn.Parent then escSaveBtn.Text = "💾 Simpan" end
        end)
    end
end)

-- Webhook Card
if _G.WebhookURL  == nil then _G.WebhookURL  = "" end

local whCard = Instance.new("Frame")
whCard.Parent = pages.Misc
whCard.Size = UDim2.new(1, -10, 0, 192)
whCard.Position = UDim2.new(0, 5, 0, 150)
whCard.BackgroundColor3 = C.card
whCard.BorderSizePixel = 0
corner(whCard, 9)
stroke(whCard, C.border, 1)

local whTitleL = newLabel(whCard, "🔔  Webhook Notif", 12, C.text, true, Enum.TextXAlignment.Left)
whTitleL.Size = UDim2.new(1,-12, 0, 24)
whTitleL.Position = UDim2.new(0, 12, 0, 6)

local whSubL = newLabel(whCard, "Kirim notif ke Discord webhook URL", 10, C.sub, false, Enum.TextXAlignment.Left)
whSubL.Size = UDim2.new(1,-24, 0, 14)
whSubL.Position = UDim2.new(0, 12, 0, 28)

local whInputBg = Instance.new("Frame")
whInputBg.Parent = whCard
whInputBg.Size = UDim2.new(1, -24, 0, 26)
whInputBg.Position = UDim2.new(0, 12, 0, 46)
whInputBg.BackgroundColor3 = C.bg
whInputBg.BorderSizePixel = 0
corner(whInputBg, 7)
stroke(whInputBg, C.border, 1)

local webhookBox = Instance.new("TextBox")
webhookBox.Parent = whInputBg
webhookBox.Size = UDim2.new(1,-10, 1, 0)
webhookBox.Position = UDim2.new(0, 8, 0, 0)
webhookBox.BackgroundTransparency = 1
webhookBox.PlaceholderText = "https://discord.com/api/webhooks/..."
webhookBox.Text = _G.WebhookURL or ""
webhookBox.TextColor3 = C.text
webhookBox.PlaceholderColor3 = C.sub
webhookBox.TextSize = 10
webhookBox.Font = Enum.Font.Gotham
webhookBox.TextXAlignment = Enum.TextXAlignment.Left
webhookBox.ClearTextOnFocus = false

local evLabel = newLabel(whCard, "Kirim webhook saat:", 10, C.sub, false, Enum.TextXAlignment.Left)
evLabel.Size = UDim2.new(1,-24, 0, 16)
evLabel.Position = UDim2.new(0, 12, 0, 78)

local chipsF = Instance.new("Frame")
chipsF.Parent = whCard
chipsF.Size = UDim2.new(1, -24, 0, 28)
chipsF.Position = UDim2.new(0, 12, 0, 96)
chipsF.BackgroundTransparency = 1

local chipLayout = Instance.new("UIListLayout", chipsF)
chipLayout.FillDirection = Enum.FillDirection.Horizontal
chipLayout.Padding = UDim.new(0, 6)
chipLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function makeChip(parent, label, acol, initState)
    local chip = Instance.new("TextButton")
    chip.Parent = parent
    chip.Size = UDim2.new(0, 82, 0, 24)
    chip.BackgroundColor3 = initState and C.accDim or C.bg
    chip.Text = (initState and "✓ " or "") .. label
    chip.TextColor3 = initState and acol or C.sub
    chip.TextSize = 10
    chip.Font = Enum.Font.GothamBold
    chip.BorderSizePixel = 0
    corner(chip, 20)
    stroke(chip, initState and acol or C.border, 1)
    local state = initState or false
    onTap(chip, function()
        state = not state
        chip.BackgroundColor3 = state and C.accDim or C.bg
        chip.TextColor3 = state and acol or C.sub
        chip.Text = (state and "✓ " or "") .. label
        for _, ch in ipairs(chip:GetChildren()) do
            if ch:IsA("UIStroke") then ch:Destroy() end
        end
        stroke(chip, state and acol or C.border, 1)
    end)
    local function getState() return state end
    return chip, getState
end

local evLootChip, getEvLoot   = makeChip(chipsF, "Per Loot",  C.green,  _G.WhEv_Loot)
local evBatchChip, getEvBatch = makeChip(chipsF, "Per Batch", C.yellow, _G.WhEv_Batch)
local evTimerChip, getEvTimer = makeChip(chipsF, "Timer 5m",  C.cyan,   _G.WhEv_Timer)

onTap(evLootChip, function() _G.WhEv_Loot  = getEvLoot()  saveConfig() end)
onTap(evBatchChip, function() _G.WhEv_Batch = getEvBatch() saveConfig() end)
onTap(evTimerChip, function() _G.WhEv_Timer = getEvTimer() saveConfig() end)

local saveWhBtn = Instance.new("TextButton")
saveWhBtn.Parent = whCard
saveWhBtn.Size = UDim2.new(1, -24, 0, 28)
saveWhBtn.Position = UDim2.new(0, 12, 0, 132)
saveWhBtn.BackgroundColor3 = C.accent
saveWhBtn.Text = "💾  Simpan Webhook"
saveWhBtn.TextColor3 = C.text
saveWhBtn.TextSize = 12
saveWhBtn.Font = Enum.Font.GothamBold
saveWhBtn.BorderSizePixel = 0
corner(saveWhBtn, 8)

onTap(saveWhBtn, function()
    _G.WebhookURL = webhookBox.Text
    saveConfig()
    saveWhBtn.Text = "✅  Tersimpan!"
    task.delay(2, function()
        if saveWhBtn and saveWhBtn.Parent then saveWhBtn.Text = "💾  Simpan Webhook" end
    end)
end)

task.spawn(function()
    while true do
        task.wait(300)
        if _G.WhEv_Timer and _G.WebhookURL and _G.WebhookURL ~= "" then
            pcall(function()
                game:GetService("HttpService"):PostAsync(
                    _G.WebhookURL,
                    game:GetService("HttpService"):JSONEncode({
                        content = "⏱ **5 menit update** | Total loot: "..totalCollected.." | Farm: "..(running and "ON" or "OFF")
                    }),
                    Enum.HttpContentType.ApplicationJson
                )
            end)
        end
    end
end)

-- ══════════════════════════════════════════════
--  TAB NAVIGATION
-- ══════════════════════════════════════════════
local function switchTab(name)
    for id, ni in pairs(navItems) do
        local on = id == name
        ni.btn.BackgroundColor3 = on and C.accDim or Color3.new(0,0,0)
        ni.btn.BackgroundTransparency = on and 0 or 1
        ni.indBar.Visible = on
        ni.labelL.TextColor3 = on and C.text or C.sub
        ni.symL.TextColor3   = on and C.accent or C.accent
        if on then
            stroke(ni.btn, C.border, 1)
        else
            for _, ch in ipairs(ni.btn:GetChildren()) do
                if ch:IsA("UIStroke") then ch:Destroy() end
            end
        end
    end
    for n, page in pairs(pages) do
        -- geser ke dalam layar kalau aktif, ke luar kalau tidak
        page.Position = (n == name)
            and UDim2.new(0, 0, 0, 0)
            or  UDim2.new(10, 0, 0, 0)
    end
    local info = TAB_INFO[name]
    if info then
        panelTitle.Text = info.title
        panelSub.Text   = info.sub
    end
    pageScroll.CanvasPosition = Vector2.new(0, 0)
end

for id, ni in pairs(navItems) do
    onTap(ni.btn, function() switchTab(id) end)
end
-- switchTab dipanggil di akhir setelah semua pages selesai dibuat

-- ══════════════════════════════════════════════
--  STATUS HELPERS
-- ══════════════════════════════════════════════
setStatus = function(text, active)
    statusLbl.Text        = text
    sDot.BackgroundColor3 = active and C.green or C.red
    statusLbl.TextColor3  = active and C.green or C.sub
    tbDotF.BackgroundColor3 = active and C.green or C.red
    tbDotTxt.Text           = active and "ON"    or "Idle"
    tbDotTxt.TextColor3     = active and C.green or C.sub
    sbDot.BackgroundColor3  = active and C.green or C.red
    sbTxt.Text              = active and "Farming" or "Idle"
    sbTxt.TextColor3        = active and C.green or C.sub
end

updateStats = function(col, found)
    s1val.Text = tostring(col)
    s2val.Text = tostring(found or 0)
end

GUIPrint = function(text, color)
    -- log dinonaktifkan
end

-- ══════════════════════════════════════════════
--  FARM LOGIC
-- ══════════════════════════════════════════════
local function getLootObjects()
    local results, seen = {}, {}
    local myY = hrp and hrp.Position.Y or 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isLootModel(obj) then
            -- cek loot belum diambil: billboard masih ada
            local hasBillboard = false
            pcall(function()
                for _, d in ipairs(obj:GetDescendants()) do
                    if d.Name == "LootCoinBillboard" then
                        hasBillboard = true
                        break
                    end
                end
            end)
            if not hasBillboard then continue end

            local pos
            if obj.PrimaryPart then
                pos = obj.PrimaryPart.Position
            else
                local ok, cf = pcall(function() return obj:GetModelCFrame() end)
                if ok then pos = cf.Position end
            end
            if pos and math.abs(pos.Y - myY) < 150 then
                local key = math.floor(pos.X)..math.floor(pos.Y)..math.floor(pos.Z)
                if not seen[key] then
                    seen[key] = true
                    table.insert(results, {name = obj.Name, pos = pos})
                end
            end
        end
    end
    -- shuffle biar pattern random tiap round
    for i = #results, 2, -1 do
        local j = math.random(1, i)
        results[i], results[j] = results[j], results[i]
    end
    return results
end

local KILLER_SAFE_RADIUS = 40

local function getKillerPositions()
    local positions = {}

    -- Method 1: Scan via nama model workspace (cara lama)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local name = obj.Name:lower()
            if name:find("killer") or name:find("monster") or name:find("enemy") then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                if root then table.insert(positions, root.Position) end
            end
        end
    end

    -- Method 2: Scan via Team "Killer" di semua player (lebih reliable di STK)
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p == player then continue end
        local isKiller = false

        -- Cek team
        if p.Team then
            local tn = p.Team.Name:lower()
            if tn:find("killer") or tn:find("monster") or tn:find("enemy") then
                isKiller = true
            end
        end
        -- Cek attribute
        if not isKiller and p:GetAttribute("IsKiller") == true then isKiller = true end
        if not isKiller and p:GetAttribute("Role") then
            local r = tostring(p:GetAttribute("Role")):lower()
            if r:find("killer") or r:find("monster") then isKiller = true end
        end
        -- Cek KillerGui di PlayerGui
        if not isKiller then
            local ok, kg = pcall(function()
                return p.PlayerGui:FindFirstChild("KillerGui", true)
                    or p.PlayerGui:FindFirstChild("KillerHUD", true)
                    or p.PlayerGui:FindFirstChild("MonsterGui", true)
            end)
            if ok and kg and kg.Enabled then isKiller = true end
        end

        if isKiller then
            local pChar = p.Character
            if pChar then
                local pHrp = pChar:FindFirstChild("HumanoidRootPart")
                if pHrp then
                    -- Hindari duplikat dengan method 1
                    local isDup = false
                    for _, existing in ipairs(positions) do
                        if (existing - pHrp.Position).Magnitude < 1 then isDup = true; break end
                    end
                    if not isDup then table.insert(positions, pHrp.Position) end
                end
            end
        end
    end

    return positions
end

local function isNearKiller()
    if not hrp then return false end
    for _, kpos in ipairs(getKillerPositions()) do
        if (hrp.Position - kpos).Magnitude <= KILLER_SAFE_RADIUS then
            return true, kpos
        end
    end
    return false, nil
end

local function teleportAwayFromKiller(killerPos)
    if not hrp then return end
    local myPos = hrp.Position
    local awayDir = (myPos - killerPos).Unit
    local randAngle = math.rad(math.random(-45, 45))
    local rotated = Vector3.new(
        awayDir.X * math.cos(randAngle) - awayDir.Z * math.sin(randAngle),
        0,
        awayDir.X * math.sin(randAngle) + awayDir.Z * math.cos(randAngle)
    )
    local dist = math.random(40, 80)
    local targetPos = myPos + rotated * dist + Vector3.new(0, 3, 0)
    hrp.CFrame = CFrame.new(targetPos)
    GUIPrint("🛡️ Killer Safe! TP jauh "..math.floor(dist).." studs", C.red)
end

local MAX_BATCH = 50
local CD_SECS   = 2

-- Raycast ke bawah dari posisi loot, return Y aman atau nil kalau void
local function getSafeY(pos)
    local ray = workspace:Raycast(
        pos + Vector3.new(0, 10, 0),
        Vector3.new(0, -100, 0)
    )
    if ray then
        return ray.Position.Y + 3
    end
    return nil
end

local function farmLoop()
    while running do
        char = player.Character
        if not char then
            setStatus("⏳ Nunggu karakter...", true)
            task.wait(1)
        else
            hrp = char:FindFirstChild("HumanoidRootPart")
            hum = char:FindFirstChild("Humanoid")
            if not hrp or not hum then
                setStatus("⏳ Nunggu karakter...", true)
                task.wait(1)
            elseif hum.Health <= 0 then
                setStatus("💀 Mati, nunggu respawn...", true)
                local newChar = player.CharacterAdded:Wait()
                char = newChar
                hrp  = newChar:WaitForChild("HumanoidRootPart")
                hum  = newChar:WaitForChild("Humanoid")
                -- tunggu health > 0 beneran siap
                while hum.Health <= 0 do task.wait(0.5) end
                task.wait(3)
            else
                local all   = getLootObjects()
                local batch = {}
                for i = 1, math.min(MAX_BATCH, #all) do batch[i] = all[i] end
                updateStats(totalCollected, #batch)

                if #batch == 0 then
                    -- fallback: coba lewat ESP loot
                    local espTargets = getTargets("Loot")
                    if #espTargets > 0 then
                        GUIPrint("🔍 Fallback ESP loot ("..#espTargets.." found)", C.cyan)
                        for _, obj in ipairs(espTargets) do
                            local pos
                            if obj.PrimaryPart then
                                pos = obj.PrimaryPart.Position
                            else
                                pcall(function() pos = obj:GetModelCFrame().Position end)
                            end
                            if pos then
                                table.insert(batch, {name = obj.Name, pos = pos})
                            end
                        end
                    end
                end

                if #batch == 0 then
                    -- semua loot habis, diem di tempat sambil nunggu respawn
                    setStatus("⌛ Loot habis, nunggu respawn...", true)
                    while running do
                        task.wait(3)
                        local check = getLootObjects()
                        if #check > 0 then
                            GUIPrint("🔄 Loot respawn! Lanjut farm", C.green)
                            break
                        end
                        -- coba fallback ESP juga
                        local espCheck = getTargets("Loot")
                        if #espCheck > 0 then
                            GUIPrint("🔍 ESP detect loot! Lanjut farm", C.cyan)
                            break
                        end
                        -- sambil nunggu, kabur kalau killer deket
                        if getKillerSafeCb() then
                            local nearKiller, kpos = isNearKiller()
                            if nearKiller then
                                teleportAwayFromKiller(kpos)
                            end
                        end
                    end
                else
                    for i, loot in ipairs(batch) do
                        if not running then break end
                        char = player.Character
                        if not char then break end
                        hrp = char:FindFirstChild("HumanoidRootPart")
                        hum = char:FindFirstChild("Humanoid")
                        if not hrp or not hum then break end
                        if hum.Health <= 0 then break end

                        if getKillerSafeCb() then
                            local tooClose = false
                            for _, kpos in ipairs(getKillerPositions()) do
                                if (loot.pos - kpos).Magnitude <= KILLER_SAFE_RADIUS then
                                    tooClose = true
                                    break
                                end
                            end
                            local nearKiller, kpos = isNearKiller()
                            if nearKiller then
                                teleportAwayFromKiller(kpos)
                                task.wait(0.5)
                                break
                            end
                            if tooClose then task.wait(0.3); continue end
                        end

                        setStatus("🔄 "..i.."/"..#batch.." — "..loot.name, true)
                        local safeY = getSafeY(loot.pos)
                        if not safeY then continue end  -- void zone, skip loot ini
                        hrp.CFrame = CFrame.new(Vector3.new(loot.pos.X, safeY, loot.pos.Z))

                        if getKillerSafeCb() then
                            task.wait(0.05)
                            local nearKiller, kpos = isNearKiller()
                            if nearKiller then
                                teleportAwayFromKiller(kpos)
                                task.wait(0.5)
                                break
                            end
                        end

                        totalCollected = totalCollected + 1
                        updateStats(totalCollected, #batch - i)
                        GUIPrint("✅ "..loot.name, C.green)

                        if _G.WhEv_Loot and _G.WebhookURL and _G.WebhookURL ~= "" then
                            pcall(function()
                                game:GetService("HttpService"):PostAsync(
                                    _G.WebhookURL,
                                    game:GetService("HttpService"):JSONEncode({
                                        content = "✅ **Loot collected:** `"..loot.name.."` | Total: "..totalCollected
                                    }),
                                    Enum.HttpContentType.ApplicationJson
                                )
                            end)
                        end
                        -- jeda random biar pattern susah ketebak
                        task.wait(math.random(5, 15) * 0.1)
                    end

                    if not running then break end

                    if _G.WhEv_Batch and _G.WebhookURL and _G.WebhookURL ~= "" then
                        pcall(function()
                            game:GetService("HttpService"):PostAsync(
                                _G.WebhookURL,
                                game:GetService("HttpService"):JSONEncode({
                                    content = "📦 **Batch selesai!** Total: "..totalCollected
                                }),
                                Enum.HttpContentType.ApplicationJson
                            )
                        end)
                    end

                    for t = CD_SECS, 1, -1 do
                        if not running then break end
                        setStatus("⏳ Cooldown "..t.."s", true)
                        task.wait(1)
                    end
                end
            end
        end
    end
    setStatus("Idle — menunggu", false)
end

onTap(farmTgl, function()
    local newVal = not getFarmCb()
    setFarmCb(newVal)
    running = newVal
    _G.FarmRunning = newVal
    if newVal then
        GUIPrint("▶ Farm aktif!", C.green)
        task.spawn(farmLoop)
    else
        GUIPrint("⏹ Farm dimatikan. Total: "..totalCollected, C.red)
        setStatus("Idle — menunggu", false)
    end
    saveConfig()
end)

onTap(killerSafeTgl, function()
    local val = not getKillerSafeCb()
    setKillerSafeCb(val)
    _G.KillerSafeOn = val
    GUIPrint(val and "🛡️ Killer Safe ON" or "🛡️ Killer Safe OFF", val and C.red or C.sub)
    saveConfig()
end)

if _G.KillerSafeOn then setKillerSafeCb(true) end

-- ══════════════════════════════════════════════
--  AUTO ESCAPE LOGIC
-- ══════════════════════════════════════════════
local function getActiveExits()
    local exits = {}
    for _, folder in ipairs(workspace:GetDescendants()) do
        if folder.Name == "Exits" and folder:IsA("Folder") then
            for _, child in ipairs(folder:GetChildren()) do
                if child.Name == "ExitGateway" and child:IsA("Model") then
                    local pos
                    if child.PrimaryPart then
                        pos = child.PrimaryPart.Position
                    else
                        local ok, cf = pcall(function() return child:GetModelCFrame() end)
                        if ok then pos = cf.Position end
                    end
                    if pos then table.insert(exits, {model = child, pos = pos}) end
                end
            end
        end
    end
    return exits
end

-- ══════════════════════════════════════════════
--  SMART ESCAPE CONSTANTS
-- ══════════════════════════════════════════════
local ESCAPE_SAFE_RADIUS   = 40   -- studs — kalau killer < ini dari exit, tunda dulu
local ESCAPE_KILLER_BAIT   = 5    -- detik — kalau killer nunggu di exit > ini, skip exit itu
local ESCAPE_RECHECK_CD    = 3    -- detik — cooldown keputusan (anti flip-flop)
local ESCAPE_RETRY_WAIT    = 3    -- detik — tunggu sebelum coba escape lagi saat killer deket

local function isKillerNearPos(pos, radius)
    for _, kpos in ipairs(getKillerPositions()) do
        if (pos - kpos).Magnitude <= radius then
            return true
        end
    end
    return false
end

-- ── HELPER: cek exit open via ReplicatedStorage (path resmi game) ──
local function isExitOpen()
    -- Method 1: ReplicatedStorage.MatchInfo.ExitsOpen (paling reliable)
    local ok1, val = pcall(function()
        return game:GetService("ReplicatedStorage").MatchInfo.ExitsOpen.Value
    end)
    if ok1 and val == true then return true end

    -- Method 2: ExitsOpen via FindFirstChild (fallback)
    local ok2, mi = pcall(function()
        return game:GetService("ReplicatedStorage"):FindFirstChild("MatchInfo")
    end)
    if ok2 and mi then
        local eo = mi:FindFirstChild("ExitsOpen")
        if eo and eo.Value == true then return true end
    end

    return false
end

-- ── HELPER: dapatkan posisi pintu exit (ExitDoor di CurrentMap) ──
local function getExitDoorPos()
    -- Method 1: scan CurrentMap cari nama yang mengandung "exit" atau "door"
    local ok2, cm = pcall(function() return workspace.CurrentMap end)
    if ok2 and cm then
        for _, obj in ipairs(cm:GetDescendants()) do
            local name = obj.Name:lower()
            if name:find("exit") or name:find("exitdoor") then
                if obj:IsA("BasePart") then return obj.Position end
                local ok3, cf = pcall(function() return obj:GetModelCFrame() end)
                if ok3 then return cf.Position end
            end
        end
    end

    -- Method 2: scan seluruh workspace cari ExitGateway / ExitDoor
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name == "exitdoor" or name == "exitgateway" or name == "exit" then
            if obj:IsA("BasePart") then return obj.Position end
            local ok4, cf = pcall(function() return obj:GetModelCFrame() end)
            if ok4 then return cf.Position end
        end
    end

    -- Method 3: fallback ke getActiveExits() lama
    local exits = getActiveExits()
    if #exits > 0 then return exits[1].pos end

    return nil
end

local function escapeLoop()
    local hasEscaped   = false
    local lastDecision = 0
    local killerBaitTimer = {}

    -- ── tunggu round mulai ───────────────────────
    while escapeRunning do
        task.wait(1)
        -- Cek MatchInfo ada di ReplicatedStorage
        local mi = game:GetService("ReplicatedStorage"):FindFirstChild("MatchInfo")
        if mi then break end
        -- Fallback: tunggu CurrentMap ada
        if workspace:FindFirstChild("CurrentMap") then break end
    end

    GUIPrint("🚪 Auto Escape aktif, nunggu exit kebuka...", C.cyan)

    -- ── LOOP UTAMA ───────────────────────────────
    while escapeRunning do
        task.wait(0.5)
        char = player.Character
        if not char then continue end
        hrp = char:FindFirstChild("HumanoidRootPart")
        hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end
        if hasEscaped then continue end

        -- CEK EXIT OPEN via ReplicatedStorage (reliable!)
        if not isExitOpen() then
            setStatus("🚪 Nunggu exit kebuka...", true)
            continue
        end

        -- Cooldown keputusan
        local now = tick()
        if now - lastDecision < ESCAPE_RECHECK_CD then continue end
        lastDecision = now

        -- Dapatkan posisi pintu
        local exitPos = getExitDoorPos()
        if not exitPos then
            setStatus("🚪 Exit open tapi pintu ga ketemu...", true)
            continue
        end

        -- Killer check sebelum escape
        if isKillerNearPos(exitPos, ESCAPE_SAFE_RADIUS) then
            local eKey = math.floor(exitPos.X)..","..math.floor(exitPos.Z)
            if not killerBaitTimer[eKey] then
                killerBaitTimer[eKey] = tick()
                GUIPrint("⚠️ Killer di depan exit, nunggu aman...", C.yellow)
            end
            local waitDur = tick() - (killerBaitTimer[eKey] or tick())
            if waitDur > REVIVE_BAIT_LIMIT then
                -- Killer bait terlalu lama, tetap escape (risiko sendiri)
                GUIPrint("⚠️ Killer bait lama, nekat escape!", C.red)
            else
                setStatus("⚠️ Killer nunggu di exit, farming dulu...", true)
                task.wait(ESCAPE_RETRY_WAIT)
                continue
            end
        else
            killerBaitTimer = {}
        end

        -- Double check sebelum TP
        if not isExitOpen() then continue end

        local dist = (exitPos - hrp.Position).Magnitude
        setStatus("🏃 Escape! ("..math.floor(dist).." studs)", true)
        GUIPrint("🏃 Escape ke ExitDoor ("..math.floor(dist).." studs)", C.cyan)

        hrp.CFrame = CFrame.new(exitPos + Vector3.new(0, 3, 0))
        hasEscaped = true
        killerBaitTimer = {}
        GUIPrint("✅ Escaped!", C.green)
        setStatus("✅ Escaped — tunggu round berikut", false)

        -- ── Tunggu exit tutup lagi (round selesai) ──
        while escapeRunning do
            task.wait(1)
            local stillOpen = isExitOpen()
            if not stillOpen then break end
        end

        -- ── Reset untuk round berikutnya ────────
        hasEscaped = false
        killerBaitTimer = {}
        GUIPrint("⏱️ Round baru, siap escape!", C.accent)
        while escapeRunning do
            task.wait(1)
            local ok3, amt3 = pcall(function()
                return game.Players.LocalPlayer.PlayerGui
                    .GameHUD.PlayerHUD.XP_OLD.RoundInfo.PlayersAlive.Amount.Text
            end)
            if ok3 and tonumber(amt3) and tonumber(amt3) > 0 then
                GUIPrint("⏱️ Round baru, siap escape!", C.accent)
                break
            end
        end
    end
end

onTap(escapeTgl, function()
    local val = not getEscapeCb()
    setEscapeCb(val)
    escapeRunning = val
    _G.EscapeRunning = val
    if val then task.spawn(escapeLoop) end
    saveConfig()
end)

if _G.EscapeRunning then
    escapeRunning = true
    setEscapeCb(true)
    task.spawn(escapeLoop)
end

-- ══════════════════════════════════════════════
--  AUTO KILL LOGIC
-- ══════════════════════════════════════════════
local function isPlayerKiller(p)
    -- Cek via Team
    if p.Team then
        local tn = p.Team.Name:lower()
        if tn:find("killer") or tn:find("monster") or tn:find("enemy") then return true end
    end
    -- Cek via Attribute
    if p:GetAttribute("IsKiller") == true then return true end
    if p:GetAttribute("Role") then
        local r = tostring(p:GetAttribute("Role")):lower()
        if r:find("killer") or r:find("monster") then return true end
    end
    -- Cek via nama karakter
    local pChar = p.Character
    if pChar then
        local cname = pChar.Name:lower()
        if cname:find("killer") or cname:find("monster") or cname:find("enemy") then return true end
        -- Cek KillerGui di PlayerGui target (kalau bisa diakses)
        local ok, kg = pcall(function()
            return p.PlayerGui:FindFirstChild("KillerGui", true)
                or p.PlayerGui:FindFirstChild("KillerHUD", true)
                or p.PlayerGui:FindFirstChild("MonsterGui", true)
        end)
        if ok and kg and kg.Enabled then return true end
    end
    return false
end

local function getAlivePlayers()
    local list = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player and not isPlayerKiller(p) then
            local pChar = p.Character
            if pChar then
                local pHum = pChar:FindFirstChild("Humanoid")
                local pHrp = pChar:FindFirstChild("HumanoidRootPart")
                if pHum and pHrp and pHum.Health > 0 then
                    table.insert(list, { plr = p, pHrp = pHrp })
                end
            end
        end
    end
    return list
end

-- Cek apakah player lagi jadi killer berdasarkan tag/team/nilai di game
local function isKillerRole()
    -- Cek via Team (biasanya killer punya team berbeda)
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("killer") or teamName:find("monster") or teamName:find("enemy") then
            return true
        end
    end
    -- Cek via attribute/tag di karakter atau player
    if player:GetAttribute("IsKiller") == true then return true end
    if player:GetAttribute("Role") then
        local role = tostring(player:GetAttribute("Role")):lower()
        if role:find("killer") or role:find("monster") then return true end
    end
    -- Cek via karakter: kalau nama karakter lo ada di daftar killer workspace
    char = player.Character
    if char then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj == char then
                local name = obj.Name:lower()
                if name:find("killer") or name:find("monster") then return true end
            end
        end
    end
    -- Cek via PlayerGui: biasanya ada UI khusus killer
    local ok, killerGui = pcall(function()
        return player.PlayerGui:FindFirstChild("KillerGui", true)
            or player.PlayerGui:FindFirstChild("KillerHUD", true)
            or player.PlayerGui:FindFirstChild("MonsterGui", true)
    end)
    if ok and killerGui and killerGui.Enabled then return true end
    return false
end

local function killLoop()
    while killRunning do
        task.wait(0.5)
        char = player.Character
        if not char then task.wait(1); continue end
        hrp = char:FindFirstChild("HumanoidRootPart")
        hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then task.wait(1); continue end

        -- Hanya aktif saat lo jadi killer, bukan survivor
        if not isKillerRole() then
            task.wait(1)
            continue
        end

        local targets = getAlivePlayers()
        if #targets == 0 then task.wait(2); continue end

        -- Tarik semua player ke depan lo secara sejajar (bukan numpuk)
        -- Susun dalam baris horizontal tegak lurus arah hadap lo
        local myLook = hrp.CFrame.LookVector
        -- Semua numpuk di satu titik persis depan killer
        local stackPos = hrp.Position + myLook * 1.5 + Vector3.new(0, 0.5, 0)

        for _, t in ipairs(targets) do
            pcall(function()
                t.pHrp.CFrame = CFrame.new(stackPos, stackPos + myLook)
            end)
        end

        task.wait(0.3)
    end
end

onTap(killTgl, function()
    local val = not getKillCb()
    setKillCb(val)
    killRunning = val
    _G.KillRunning = val
    if val then task.spawn(killLoop)
    else GUIPrint("🗡️ Auto Kill OFF", C.sub) end
    saveConfig()
end)

if _G.KillRunning then
    killRunning = true
    setKillCb(true)
    task.spawn(killLoop)
end

-- ══════════════════════════════════════════════
--  AUTO SELF-REVIVE
-- ══════════════════════════════════════════════
-- ══════════════════════════════════════════════
--  SMART REVIVE / SELF-REVIVE CONSTANTS (harus di atas semua fungsi yang pakai)
-- ══════════════════════════════════════════════
local REVIVE_SAFE_RADIUS  = 35   -- studs — killer harus lebih jauh dari ini ke target
local REVIVE_DECISION_CD  = 3    -- detik — cooldown keputusan (anti flip-flop)
local REVIVE_BAIT_LIMIT   = 5    -- detik — kalau killer stay deket target > ini, skip target itu
local REVIVE_WAIT_DANGER  = 2    -- detik — tunggu saat kondisi bahaya sebelum cek ulang
local SELF_REVIVE_SAFE_RADIUS = 25  -- studs, radius killer check untuk self-revive

local function isSelfKnocked()
    char = player.Character
    if not char then return false end

    -- Cek 1: Humanoid health = 0
    local myHum = char:FindFirstChild("Humanoid")
    if myHum and myHum.Health <= 0 then return true end

    -- Cek 2: BleedOutHealth di HumanoidRootPart
    local myHrp = char:FindFirstChild("HumanoidRootPart")
    if myHrp then
        local bleed = myHrp:FindFirstChild("BleedOutHealth")
        if bleed then
            if (bleed:IsA("BillboardGui") or bleed:IsA("ScreenGui") or bleed:IsA("Frame")) and bleed.Enabled then return true end
            if bleed:IsA("BoolValue") and bleed.Value then return true end
        end
    end

    -- Cek 3: BleedOutHealth di seluruh char (recursive)
    local bleed2 = char:FindFirstChild("BleedOutHealth", true)
    if bleed2 then
        if (bleed2:IsA("BillboardGui") or bleed2:IsA("ScreenGui")) and bleed2.Enabled then return true end
        if bleed2:IsA("BoolValue") and bleed2.Value then return true end
    end

    -- Cek 4: GUI knocked di PlayerGui (BleedOutGui / BleedOut / KnockedGui)
    local ok, bleedGui = pcall(function()
        return player.PlayerGui:FindFirstChild("BleedOutGui", true)
            or player.PlayerGui:FindFirstChild("BleedOut", true)
            or player.PlayerGui:FindFirstChild("KnockedGui", true)
    end)
    if ok and bleedGui and bleedGui.Enabled then return true end

    -- Cek 5: Attribute "Knocked" atau "IsKnocked" di player/char
    if player:GetAttribute("Knocked") == true then return true end
    if player:GetAttribute("IsKnocked") == true then return true end
    if char:GetAttribute("Knocked") == true then return true end

    -- Cek 6: Humanoid StateType = Dead atau Physics (knocked biasanya Physics)
    if myHum then
        local state = myHum:GetState()
        if state == Enum.HumanoidStateType.Dead then return true end
    end

    return false
end

local function isKillerNearTarget(targetHrp)
    if not targetHrp or not targetHrp.Parent then return false end
    for _, kpos in ipairs(getKillerPositions()) do
        if (targetHrp.Position - kpos).Magnitude <= SELF_REVIVE_SAFE_RADIUS then
            return true
        end
    end
    return false
end

local function getSafeReviveTarget(aliveList)
    -- Cari target yang killer jauh darinya
    for _, t in ipairs(aliveList) do
        if not isKillerNearTarget(t.pHrp) then
            return t
        end
    end
    return nil  -- semua target dekat killer, skip dulu
end

local function selfReviveLoop()
    local lastDecision = 0

    while selfReviveRunning do
        task.wait(0.5)
        if not isSelfKnocked() then
            continue
        end

        -- Cooldown keputusan (anti flip-flop)
        local now = tick()
        if now - lastDecision < REVIVE_DECISION_CD then
            task.wait(0.3)
            continue
        end
        lastDecision = now

        local alive = getAlivePlayers()
        if #alive == 0 then continue end

        -- Pilih target aman (killer jauh)
        local safeTarget = nil
        for _, t in ipairs(alive) do
            if not isKillerNearTarget(t.pHrp) then
                safeTarget = t
                break
            end
        end

        if not safeTarget then
            GUIPrint("⚠️ Semua teman dekat killer, nunggu...", C.yellow)
            task.wait(REVIVE_WAIT_DANGER)
            continue
        end

        char = player.Character
        if not char then continue end
        local myHrp = char:FindFirstChild("HumanoidRootPart")
        if not myHrp then continue end

        -- Ikutin target sampai revive selesai
        while selfReviveRunning and isSelfKnocked() do
            local targetHrp = safeTarget.pHrp

            -- Cek ulang: kalau killer deket target, ganti
            if isKillerNearTarget(targetHrp) then
                GUIPrint("⚠️ Killer deket target, cari yang lain...", C.yellow)
                local newAlive = getAlivePlayers()
                local newSafe = nil
                for _, t in ipairs(newAlive) do
                    if not isKillerNearTarget(t.pHrp) then
                        newSafe = t
                        break
                    end
                end
                if newSafe then
                    safeTarget = newSafe
                    GUIPrint("🔄 Ganti target revive ke aman", C.cyan)
                else
                    task.wait(REVIVE_WAIT_DANGER)
                end
            elseif targetHrp and targetHrp.Parent then
                myHrp.CFrame = CFrame.new(targetHrp.Position)
            else
                -- target disconnect/mati
                local newAlive = getAlivePlayers()
                local newSafe = nil
                for _, t in ipairs(newAlive) do
                    if not isKillerNearTarget(t.pHrp) then
                        newSafe = t
                        break
                    end
                end
                if newSafe then safeTarget = newSafe else break end
            end
            task.wait(0.3)
        end
    end
end

onTap(selfReviveTgl, function()
    local val = not getSelfReviveCb()
    setSelfReviveCb(val)
    selfReviveRunning = val
    _G.SelfReviveRunning = val
    if val then task.spawn(selfReviveLoop)
    else GUIPrint("🩹 Self-Revive OFF", C.sub) end
    saveConfig()
end)

if _G.SelfReviveRunning then
    selfReviveRunning = true
    setSelfReviveCb(true)
    task.spawn(selfReviveLoop)
end

-- ══════════════════════════════════════════════
--  AUTO REVIVE
-- ══════════════════════════════════════════════
-- killerStayTimer[playerName] = tick() pertama kali killer ketahuan deket target itu
local killerStayTimers = {}

local function isKillerNearReviveTarget(targetHrp)
    if not targetHrp or not targetHrp.Parent then return false end
    for _, kpos in ipairs(getKillerPositions()) do
        if (targetHrp.Position - kpos).Magnitude <= REVIVE_SAFE_RADIUS then
            return true
        end
    end
    return false
end

local function getKnockedPlayers()
    local list = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p == player then continue end
        if isPlayerKiller(p) then continue end  -- skip killer
        local pChar = p.Character
        if not pChar then continue end
        local pHrp = pChar:FindFirstChild("HumanoidRootPart")
        if not pHrp then continue end

        local isKnocked = false

        -- Cek 1: BleedOutHealth di HRP
        local bleed = pHrp:FindFirstChild("BleedOutHealth")
        if bleed and bleed.Enabled then isKnocked = true end

        -- Cek 2: BleedOutHealth recursive di char
        if not isKnocked then
            local bleed2 = pChar:FindFirstChild("BleedOutHealth", true)
            if bleed2 then
                if (bleed2:IsA("BillboardGui") or bleed2:IsA("ScreenGui")) and bleed2.Enabled then isKnocked = true end
                if bleed2:IsA("BoolValue") and bleed2.Value then isKnocked = true end
            end
        end

        -- Cek 3: Humanoid health = 0 tapi char masih ada (knocked state)
        if not isKnocked then
            local pHum = pChar:FindFirstChild("Humanoid")
            if pHum and pHum.Health <= 0 then isKnocked = true end
        end

        -- Cek 4: Attribute Knocked
        if not isKnocked then
            if p:GetAttribute("Knocked") == true then isKnocked = true end
            if p:GetAttribute("IsKnocked") == true then isKnocked = true end
            if pChar:GetAttribute("Knocked") == true then isKnocked = true end
        end

        if isKnocked then
            table.insert(list, { plr = p, pHrp = pHrp })
        end
    end
    return list
end

local function reviveLoop()
    local lastDecision = 0

    while reviveRunning do
        task.wait(0.5)
        char = player.Character
        if not char then task.wait(1); continue end
        hrp = char:FindFirstChild("HumanoidRootPart")
        hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then task.wait(1); continue end

        -- Cooldown keputusan (anti flip-flop)
        local now = tick()
        if now - lastDecision < REVIVE_DECISION_CD then
            task.wait(0.5)
            continue
        end
        lastDecision = now

        local knocked = getKnockedPlayers()
        if #knocked == 0 then
            killerStayTimers = {}  -- reset semua timer kalau ga ada yang knocked
            continue
        end

        -- ── Pilih target yang aman ───────────────
        local safeTarget = nil
        for _, t in ipairs(knocked) do
            local tName = t.plr.Name
            local killerNear = isKillerNearReviveTarget(t.pHrp)

            if killerNear then
                -- Mulai timer bait untuk target ini
                if not killerStayTimers[tName] then
                    killerStayTimers[tName] = tick()
                end

                local stayDur = tick() - killerStayTimers[tName]
                if stayDur > REVIVE_BAIT_LIMIT then
                    -- Killer udah nunggu lama di target ini → skip selamanya round ini
                    GUIPrint("🪤 Killer bait di "..tName..", skip!", C.red)
                end
                -- Target ini berbahaya, coba yang lain
            else
                -- Killer jauh dari target ini → aman
                killerStayTimers[tName] = nil  -- reset timer bait kalau killer pergi
                safeTarget = t
                break
            end
        end

        -- Kalau semua target berbahaya → farming dulu
        if not safeTarget then
            setStatus("⚠️ Semua teman dijaga killer, farming dulu...", true)
            task.wait(REVIVE_WAIT_DANGER)
            continue
        end

        -- ── Eksekusi revive ke target aman ───────
        local targetHrp = safeTarget.pHrp
        if not targetHrp or not targetHrp.Parent then continue end

        -- Double-check sebelum teleport
        if isKillerNearReviveTarget(targetHrp) then
            setStatus("⚠️ Killer muncul, batal revive!", true)
            task.wait(REVIVE_WAIT_DANGER)
            continue
        end

        local dist = (hrp.Position - targetHrp.Position).Magnitude
        if dist > 5 then
            setStatus("💉 Revive "..safeTarget.plr.Name.." ("..math.floor(dist).." studs)", true)
            GUIPrint("💉 Revive "..safeTarget.plr.Name, C.yellow)
            hrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(2, 0, 0))
        end
    end
end

onTap(reviveTgl, function()
    local val = not getReviveCb()
    setReviveCb(val)
    reviveRunning = val
    _G.ReviveRunning = val
    if val then task.spawn(reviveLoop)
    else GUIPrint("💉 Auto Revive OFF", C.sub) end
    saveConfig()
end)

if _G.ReviveRunning then
    reviveRunning = true
    setReviveCb(true)
    task.spawn(reviveLoop)
end

-- ══════════════════════════════════════════════
--  CHARACTER RE-APPLY (speed/jump persist saat respawn)
-- ══════════════════════════════════════════════
player.CharacterAdded:Connect(function(c)
    char = c
    hrp  = c:WaitForChild("HumanoidRootPart")
    hum  = c:WaitForChild("Humanoid")
    if getSpeedCb() then task.wait(0.5); hum.WalkSpeed = _G.SpeedValue end
    if getJumpCb()  then task.wait(0.5); hum.JumpPower = _G.JumpValue  end
end)

-- ══════════════════════════════════════════════
--  MINIMIZE & BUBBLE
-- ══════════════════════════════════════════════
onTap(minimizeBtn, function()
    win.Visible = false
    bubble.Visible = true
end)

onTap(bubble, function()
    bubble.Visible = false
    win.Visible = true
end)

-- ══════════════════════════════════════════════
--  CLOSE
-- ══════════════════════════════════════════════
onTap(closeBtn, function()
    running           = false
    escapeRunning     = false
    reviveRunning     = false
    killRunning       = false
    selfReviveRunning = false
    _G.FarmRunning     = false
    _G.EscapeRunning   = false
    _G.ReviveRunning   = false
    _G.KillRunning     = false
    _G.SelfReviveRunning = false
    local c = player.Character
    if c then
        local h = c:FindFirstChild("Humanoid")
        if h then
            if getSpeedCb() then h.WalkSpeed = 16 end
            if getJumpCb()  then h.JumpPower = 7.2 end
        end
    end
    if djConn then djConn:Disconnect() djConn = nil end
    if afkConn then afkConn:Disconnect() afkConn = nil end
    for espType in pairs(espActive) do
        espActive[espType] = false
        clearESP(espType)
    end
    sg:Destroy()
    _G.PevGui = nil
end)

-- ══════════════════════════════════════════════
--  INIT — semua pages udah dibuat, baru switchTab
-- ══════════════════════════════════════════════
switchTab("Main")
setStatus("Idle — menunggu", false)

if _G.FarmRunning then
    running = true
    setFarmCb(true)
    task.spawn(farmLoop)
end
