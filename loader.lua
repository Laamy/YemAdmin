--!strict
--!optimize 2
--!native
local Players = game:GetService("Players")

local function Load(filepath)
    local url = `https://github.com/Laamy/YemAdmin/{filepath}`
    local code = game:GetService("HttpService"):GetAsync(url)

    local chunk, loadErr = loadstring(code)
    assert(chunk, `Failed to load {filepath}; {loadErr}`)
    
    return chunk()
   --local success, runErr = pcall(function() return chunk() end)
   --assert(success, `Failed to execute {filepath}; {runErr}`)
end

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

local RunCode = function(caller: Player, code: string)
    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
        local ticking = tick()
        require(112691275102014).load()
        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
    end

    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
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

RunCode(Players.SnowClan_8342, "print'hi'")

local ClearWorkspace = function()
    for _, object in pairs(workspace:GetChildren()) do
        if object == workspace.Terrain or object == workspace.Tabby then continue end
        if Players:GetPlayerFromCharacter(object) then continue end
        
        object:Destroy()
    end
end

local NewGui: (labels: {})->ScreenGui = Load("src/gui.lua")

local commands: {Command} = {}

type Command = {
    Name: string,
    Description: string,
    Arguments: string,
    OnCalled: (... any)->()
}

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

local onPlayerChatted = function(plyr: Player, msg: string)
    if not isRunning then return end
    local prefix = GetEnv().config.prefix
	if string.sub(msg, 1, #prefix) == prefix then
        IssueCommand(plyr, msg)
    end
end

table.insert(connections, Players.PlayerAdded:Connect(function(plyr: Player)
    _G.BindPlayerChatted(plyr):Connect(function(msg: string)
        onPlayerChatted(plyr, msg)
    end)
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
        local cmdArgs = cmd["Arguments"]
        local cmdDescr = cmd["Description"]

        table.insert(output, `{prefix}{cmdName} {cmdArgs} - {cmdDescr}`)
	end

    NewGui(output).Parent = caller.PlayerGui
end)

AddCommand("clr", "Clear everything from workspace", "<>", ClearWorkspace)
