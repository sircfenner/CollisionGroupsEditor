local PhysicsService = game:GetService("PhysicsService")
local TextService = game:GetService("TextService")

local Plugin = script.Parent.Parent
local Constants = require(Plugin.Constants)

local Roact = require(Plugin.Packages.Roact)
local StudioComponents = require(Plugin.Packages.StudioComponents)

local withTheme = StudioComponents.withTheme
local ScrollFrame = StudioComponents.ScrollFrame
local Label = StudioComponents.Label
local GridItem = require(script.GridItem)

local MARGIN_MIN_LEFT = 40
local MARGIN_MIN_TOP = 30

local MARGIN_PADDING_LEFT = 5
local MARGIN_PADDING_TOP = 1

local DIAGONAL_ANGLE = 35
local CELL_SIZE = Constants.GridCellSize

local function getTextSize(text)
	local frameSize = Vector2.new(1e5, 1e5)
	return TextService:GetTextSize(text, 14, Enum.Font.SourceSansBold, frameSize)
end

local GridView = Roact.Component:extend("GridView")

function GridView:init()
	self.scrollPosition, self.setScrollPosition = Roact.createBinding(Vector2.new(0, 0))
	self:setState({
		HoveredGroupName0 = "",
		HoveredGroupName1 = "",
	})
end

function GridView:render()
	local groups = self.props.Groups
	local hoveredName0 = self.state.HoveredGroupName0
	local hoveredName1 = self.state.HoveredGroupName1

	local leftMargin = MARGIN_MIN_LEFT
	for _, group in ipairs(groups) do
		local width = getTextSize(group.name).x + 1
		if width > leftMargin then
			leftMargin = width
		end
	end

	local topMargin = MARGIN_MIN_TOP
	local angle = math.rad(DIAGONAL_ANGLE)
	for _, group in ipairs(groups) do
		local aabb = getTextSize(group.name) * Vector2.new(1, 0.5)
		local height = math.ceil(3 + aabb.x * math.sin(angle) + aabb.y * math.cos(angle))
		if height > topMargin then
			topMargin = height
		end
	end

	local nameOrder = {}
	for i, group in groups do
		nameOrder[group.name] = i
	end

	local gridContent = {}
	for i, group0 in ipairs(groups) do
		local items = {}
		for j = i, #groups do
			local group1 = groups[j]
			local collidable = PhysicsService:CollisionGroupsAreCollidable(group0.name, group1.name)
			local highlighted = (group0.name == hoveredName0 and nameOrder[group1.name] >= nameOrder[hoveredName1])
				or (group1.name == hoveredName1 and nameOrder[group0.name] <= nameOrder[hoveredName0])

			items[j] = Roact.createElement(GridItem, {
				Disabled = self.props.Disabled,
				LayoutOrder = #groups - j,
				Highlighted = highlighted,
				Collidable = collidable,
				OnActivated = function()
					self.props.SetGroupsCollidable(group0.name, group1.name, not collidable)
				end,
				OnHoverBegan = function()
					self:setState({
						HoveredGroupName0 = group0.name,
						HoveredGroupName1 = group1.name,
					})
				end,
				OnHoverEnded = function()
					if hoveredName0 == group0.name and hoveredName1 == group1.name then
						self:setState({
							HoveredGroupName0 = "",
							HoveredGroupName1 = "",
						})
					end
				end,
			})
		end
		gridContent[i] = Roact.createElement("Frame", {
			LayoutOrder = i,
			Size = UDim2.fromOffset(CELL_SIZE.x * #groups, CELL_SIZE.y),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
			}),
			Content = Roact.createFragment(items),
		})
	end

	local headerContent0 = {}
	for i, group in ipairs(groups) do
		local highlighted = group.name == hoveredName1
		headerContent0[i] = Roact.createElement("Frame", {
			LayoutOrder = #groups - i,
			Size = UDim2.new(0, CELL_SIZE.x, 1, 0),
			BackgroundTransparency = 1,
		}, {
			Label = Roact.createElement(Label, {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 3, 1, 0),
				Rotation = DIAGONAL_ANGLE,
				Size = UDim2.fromOffset(0, 14),
				Text = group.name,
				Font = highlighted and Enum.Font.SourceSansBold or Enum.Font.SourceSans,
				TextColorStyle = highlighted and Enum.StudioStyleGuideColor.BrightText
					or Enum.StudioStyleGuideColor.MainText,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				Disabled = self.props.Disabled,
			}),
		})
	end

	local headerContent1 = {}
	for i, group in ipairs(groups) do
		local highlighted = group.name == hoveredName0
		headerContent1[i] = Roact.createElement(Label, {
			LayoutOrder = i,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, CELL_SIZE.y),
			Text = group.name,
			Font = highlighted and Enum.Font.SourceSansBold or Enum.Font.SourceSans,
			TextColorStyle = highlighted and Enum.StudioStyleGuideColor.BrightText
				or Enum.StudioStyleGuideColor.MainText,
			TextXAlignment = Enum.TextXAlignment.Right,
			Disabled = self.props.Disabled,
		})
	end

	return Roact.createFragment({
		Main = Roact.createElement(ScrollFrame, {
			AnchorPoint = Vector2.new(1, 1),
			Size = UDim2.new(1, -leftMargin - MARGIN_PADDING_LEFT, 1, -topMargin - MARGIN_PADDING_TOP),
			Position = UDim2.fromScale(1, 1),
			ScrollingDirection = Enum.ScrollingDirection.XY,
			OnScrolled = self.setScrollPosition,
			Disabled = self.props.Disabled,
		}, gridContent),
		Header0 = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(1, -leftMargin - MARGIN_PADDING_LEFT, 0, topMargin),
			ClipsDescendants = true,
		}, {
			Holder = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, #groups * CELL_SIZE.x, 1, 0),
				Position = self.scrollPosition:map(function(pos)
					return UDim2.fromOffset(-pos.x, 0)
				end),
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
				}),
				Content = Roact.createFragment(headerContent0),
			}),
		}),
		Header0Triangle = withTheme(function(theme)
			return Roact.createElement("ImageLabel", {
				ZIndex = 2,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.fromOffset(leftMargin, topMargin),
				Size = UDim2.fromOffset(leftMargin, topMargin),
				Image = "rbxassetid://6851894143",
				ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			})
		end),
		Header1 = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, leftMargin, 1, -topMargin - MARGIN_PADDING_TOP),
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			ClipsDescendants = true,
		}, {
			Holder = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, #groups * CELL_SIZE.y),
				Position = self.scrollPosition:map(function(pos)
					return UDim2.fromOffset(0, -pos.y)
				end),
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Content = Roact.createFragment(headerContent1),
			}),
		}),
	})
end

return GridView
