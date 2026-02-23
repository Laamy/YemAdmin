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
	baseLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
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

return NewGui