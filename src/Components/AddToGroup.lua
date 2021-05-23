local SelectionService = game:GetService("Selection")

local Plugin = script.Parent.Parent

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

local Button = StudioComponents.Button

local AddToGroup = Roact.Component:extend("AddToGroup")

function AddToGroup:init()
	self:setState({ Selection = SelectionService:Get() })
	self.onActivated = function()
		local targets = {}
		local targetId = self.props.SelectedGroupId
		for _, instance in ipairs(self.state.Selection) do
			if instance:IsA("BasePart") and instance.CollisionGroupId ~= targetId then
				table.insert(targets, instance)
			end
		end
		self.props.BatchSetCollisionGroup(targets, targetId)
	end
end

function AddToGroup:didMount()
	self.selectionChanged = SelectionService.SelectionChanged:Connect(function()
		self:setState({ Selection = SelectionService:Get() })
	end)
end

function AddToGroup:willUnmount()
	self.selectionChanged:Disconnect()
end

function AddToGroup:render()
	local valid = false
	local targetId = self.props.SelectedGroupId
	for _, instance in ipairs(self.state.Selection) do
		if not instance:IsA("BasePart") then
			continue
		elseif instance.CollisionGroupId ~= targetId then
			valid = true
			break
		end
	end
	return Roact.createElement(Button, {
		LayoutOrder = 1,
		Size = UDim2.new(0.38, -4, 1, 0),
		Text = "Add to Group",
		Disabled = self.props.Disabled or not valid,
		OnActivated = self.onActivated,
	})
end

return AddToGroup
