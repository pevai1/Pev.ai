local p = game.Players.LocalPlayer
local URL = "https://doqxklmdtmadmjfhxlsd.supabase.co"
local KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvcXhrbG1kdG1hZG1qZmh4bHNkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ1OTQ5OTEsImV4cCI6MjA5MDE3MDk5MX0.WKNN-RtyXSGEztIzsxgR6lds9ZKIXis81A6DA2POTmE"
local INT = 15
local HS = game:GetService("HttpService")

local sg = Instance.new("ScreenGui",p.PlayerGui)
sg.Name,sg.ResetOnSpawn = "StatusGui",false
local lbl = Instance.new("TextLabel",sg)
lbl.Size,lbl.Position = UDim2.new(0.95,0,0,42),UDim2.new(0.025,0,0.05,0)
lbl.BackgroundColor3,lbl.BackgroundTransparency = Color3.fromRGB(10,15,25),0.2
lbl.TextColor3,lbl.TextScaled,lbl.Font,lbl.Text,lbl.ZIndex = Color3.fromRGB(100,255,150),true,Enum.Font.Code,"⏳",999
Instance.new("UICorner",lbl).CornerRadius = UDim.new(0,8)

local function st(m,c) lbl.Text=m; lbl.TextColor3=c or Color3.fromRGB(100,255,150) end
local function num(t) local r={} for n in tostring(t):gmatch("%d+") do r[#r+1]=n end; return tonumber(table.concat(r)) or 0 end
local function getCoins() local v=0; pcall(function() v=num(p.PlayerGui.TopBar.CurrencyTop.Coins.Amount.Text) end); return v end
local function getGems()  local v=0; pcall(function() v=num(p.PlayerGui.TopBar.CurrencyTop.Gems.Amount.Text) end); return v end
local function getLevel() local v=0; pcall(function() v=tonumber(p.PlayerGui.GameHUD.PlayerHUD.XP.Level.Text:match("%d+")) or 0 end); return v end
local function isInMatch() local v=false; pcall(function() v=p.PlayerGui.TopBar.RoundTimer.Visible==true end); return v end
local function getToday() local t=os.date("*t"); return string.format("%04d-%02d-%02d",t.year,t.month,t.day) end
local function getUTC() return os.date("!%Y-%m-%dT%H:%M:%SZ") end

-- Anti AFK
task.spawn(function()
    while true do
        task.wait(10)
        pcall(function()
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Jump = true end
        end)
    end
end)

-- Fetch mod list
local modList = {}
local function fetchModList()
    pcall(function()
        local res = request({Url=URL.."/rest/v1/moderator_list?select=username",Method="GET",Headers={["apikey"]=KEY,["Authorization"]="Bearer "..KEY}})
        local data = HS:JSONDecode(res.Body)
        for _, m in ipairs(data) do
            if m.username then modList[m.username:lower()] = true end
        end
        st("✅ "..#data.." mod loaded")
    end)
end

-- Kirim mod event
local reportedMods = {}
local function sendModEvent(modName)
    local jobId = tostring(game.JobId)
    local key = modName.."|"..jobId
    if reportedMods[key] then return end
    reportedMods[key] = true
    local body = '{"player_id":"'..tostring(p.UserId)..'","job_id":"'..jobId..'","moderator_name":"'..modName..'"}'
    pcall(function()
        request({Url=URL.."/rest/v1/moderator_events",Method="POST",Headers={["Content-Type"]="application/json",["apikey"]=KEY,["Authorization"]="Bearer "..KEY,["Prefer"]="return=minimal"},Body=body})
    end)
    st("🚨 MOD: "..modName, Color3.fromRGB(255,80,80))
    task.wait(3)
end

local function checkMod(player)
    if player == p then return end
    if modList[player.Name:lower()] then sendModEvent(player.Name) end
end

-- Activity log
local function logActivity(event, c, g, l, dE, mC)
    local jobId = tostring(game.JobId)
    local body = '{"player_id":"'..tostring(p.UserId)..'","player_name":"'..tostring(p.Name)..'","event":"'..event..'","coins":'..tostring(c)..',"gems":'..tostring(g)..',"level":'..tostring(l)..',"daily_earned":'..tostring(dE)..',"match_count":'..tostring(mC)..',"job_id":"'..jobId..'"}'
    pcall(function()
        request({Url=URL.."/rest/v1/activity_log",Method="POST",Headers={["Content-Type"]="application/json",["apikey"]=KEY,["Authorization"]="Bearer "..KEY,["Prefer"]="return=minimal"},Body=body})
    end)
end

fetchModList()
for _, player in ipairs(game.Players:GetPlayers()) do checkMod(player) end
game.Players.PlayerAdded:Connect(function(player) task.wait(1); checkMod(player) end)

local cS,cM,lE,mC,iP = 0,0,0,0,false
local dS,dE,dD = 0,0,""

pcall(function() p.PlayerGui:WaitForChild("TopBar",60):WaitForChild("CurrencyTop",30):WaitForChild("Coins",30):WaitForChild("Amount",30) end)
local tries=0; repeat tries=tries+1; st("⏳ "..tries); task.wait(2)
local ok,txt=pcall(function() return p.PlayerGui.TopBar.CurrencyTop.Coins.Amount.Text end)
if ok and txt and txt~="Loading..." and txt~="" then break end until tries>=30

local ic=getCoins(); cS,dS,dD=ic,ic,getToday()
st("✅ Ready | "..ic.." | "..dD)
logActivity("online", ic, getGems(), getLevel(), 0, 0)

while true do
    local c,g,l,im,td = getCoins(),getGems(),getLevel(),isInMatch(),getToday()
    if td~=dD then dD,dS,dE=td,c,0; st("🌅 Hari baru!",Color3.fromRGB(0,200,255))
    else dE=math.max(0,c-dS) end
    if im and not iP then cS,cM,mC=c,0,mC+1; st("🎮 Match #"..mC,Color3.fromRGB(0,200,255)) end
    if im then cM=math.max(0,c-cS) end
    if not im and iP then
        lE=cM; cM=0
        st("🏁 +"..lE.." | Harian:+"..dE,Color3.fromRGB(255,204,0))
        logActivity("match_end", c, g, l, dE, mC)
    end
    iP=im
    local b='{"player_id":"'..p.UserId..'","player_name":"'..p.Name..'","coins":'..c..',"gems":'..g..',"level":'..l..',"coins_start":'..cS..',"coins_match":'..cM..',"last_earned":'..lE..',"match_count":'..mC..',"coins_daily_start":'..dS..',"coins_daily_earned":'..dE..',"daily_date":"'..dD..'","updated_at":"'..getUTC()..'","event_type":"join","game_name":"Survive the Killer","job_id":"'..tostring(game.JobId)..'"}'
    local ok2=pcall(function()
        request({Url=URL.."/rest/v1/game_events",Method="POST",Headers={["Content-Type"]="application/json",["apikey"]=KEY,["Authorization"]="Bearer "..KEY,["Prefer"]="resolution=merge-duplicates"},Body=b})
    end)
    if ok2 then st("✅ 🪙"..c.." 💎"..g.." ⭐"..l.." | Harian:+"..dE)
    else st("❌ Error",Color3.fromRGB(255,80,80)) end
    task.wait(INT)
end
