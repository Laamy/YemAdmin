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
        searchBox:GetPropertyChangedSignal("Text"):Connect(function(input: InputObject)
            -- TODO: strip function for richtext format
            for i, v: TextLabel in pairs(innerFrame:GetChildren()) do
                v.Visible = string.find(v.Text:lower(), searchBox.Text:lower()) ~= nil
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

NewGui({
    `I want the <font color="#FF7800">orange</font> candy.`,
    `I want the <font color="#0078FF">blue</font> candy.`
}, {
    SearchBar = true
}).Parent = game.Players.SnowClan_8342.PlayerGui
