--!strict
--!optimize 2
--!native
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function NewGui(labels: {}): ScreenGui
	local cmdGui = Instance.new("ScreenGui")
	cmdGui.Name = "CMDSGUI"

	local mainButton = Instance.new("TextButton", cmdGui)
	mainButton.AutoButtonColor = false
	mainButton.Size = UDim2.new(0, 385, 0, 20)
	mainButton.BackgroundTransparency = 1
	mainButton.Text = ""
    mainButton.Draggable = true
	mainButton.Position = UDim2.new(0.5, -200, 0.5, -200)

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

    for i,v in pairs(labels) do
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

if not _G.yem then
    _G.yem = {}
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

-- TODO: implement ranks (for whitelist cmd or smth)
if not GetEnv().tempwhitelist then
    GetEnv().tempwhitelist = {
        ["SnowClan_8342"] = {}
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

local commands: {Command} = {}

type Command = {
    Name: string,
    Description: string,
    Arguments: string,
    OnCalled: (... any)->()
}

print'initializing'
local AddCommand = function(name: string, desc: string, args: string, onCalled: (... any)->())
	local tmpTbl: Command = {
		["Name"] = name,
		["Description"] = desc,
		["Arguments"] = args,
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
        return -- TODO: ranks(?)
    end

    local prefix = GetEnv().config.prefix
	if string.sub(msg, 1, #prefix) == prefix then
        IssueCommand(plyr, msg)
    end
end

table.insert(connections, Players.PlayerAdded:Connect(function(plyr: Player)
    _G.BindPlayerChatted(plyr):Connect(function(msg: string)
        onPlayerChatted(plyr, msg)
    end)

    if GetEnv().tempbans[plyr.Name] then
        plyr:Kick(GetEnv().tempbans[plyr.Name])
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

for i,plyr in pairs(Players:GetPlayers()) do
    _G.BindPlayerChatted(plyr):Connect(function(msg: string)
        onPlayerChatted(plyr, msg)
    end)
end

--cmds
AddCommand("cmds", "Display a list of basic commands", "<>", function(caller: Player)
    local output: {string} = {}

    local prefix = GetEnv().config.prefix
    for i,cmd in ipairs(commands) do
		local cmdName = cmd["Name"]
        local cmdArgs = C(E(cmd["Arguments"]), Color3.fromHex("#919191"))
        local cmdDescr = cmd["Description"]

        table.insert(output, `{C(prefix, Color3.fromHex("#738e99"))}{cmdName} {cmdArgs} - {cmdDescr}`)
	end

    NewGui(output).Parent = caller.PlayerGui
end)

AddCommand("clr", "Clear everything from workspace", "<>", ClearWorkspace)

AddCommand("kick", "Kick a player with a reason", "<plyr1, ...>", function(calller: Player, plyr1: string, ...)
    local target = getPlyr(plyr1)
    assert(target, "Player not found")

    local reason = table.concat({...}, " ")
    target:Kick(reason)
end)

AddCommand("ban", "Ban a player with a reason", "<plyr1, ...>", function(calller: Player, plyr1: string, ...)
    local target = getPlyr(plyr1)
    assert(target, "Player not found")

    local reason = `\n\n[YemAdmin]\nYou have been banned for:\n{table.concat({...}, " ")}`
    target:Kick(reason)
    GetEnv().tempbans[target.Name] = reason
end)

AddCommand("unban", "Unban a player (Username only)", "<plyr1>", function(calller: Player, plyr1: string)
    for i,v in pairs(GetEnv().tempbans) do
        if string.find(string.lower(i), plyr1, 1, true) then
            GetEnv().tempbans[i] = nil
            return
        end
    end
    error("User not found")
end)

AddCommand("blacklist", "Erase a players admin", "<plyr1>", function(calller: Player, plyr1: string)
    local target = getPlyr(plyr1)
    assert(target, "Player not found")
    
    GetEnv().tempblacklist[target.Name] = {}
end)

AddCommand("unblacklist", "Unblacklists a player (Username only)", "<plyr1>", function(calller: Player, plyr1: string)
    for i,v in pairs(GetEnv().tempblacklist) do
        if string.find(string.lower(i), plyr1, 1, true) then
            GetEnv().tempblacklist[i] = nil
            return
        end
    end
    error("User not found")
end)
print'commands initialized'
