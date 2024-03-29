local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

local Plugin = script.Parent.Parent
local Constants = require(Plugin.Constants)

local Roact = require(Plugin.Packages.Roact)
local StudioComponents = require(Plugin.Packages.StudioComponents)

local Button = StudioComponents.Button
local MainButton = StudioComponents.MainButton
local ListView = require(script.Parent.ListView)
local GridView = require(script.Parent.GridView)
local TabButton = require(script.Parent.TabButton)
local DeleteGroupWidget = require(script.Parent.DeleteGroupWidget)
local GroupNameWidget = require(script.Parent.GroupNameWidget)
local AddToGroup = require(script.Parent.AddToGroup)

local MAX_GROUPS = PhysicsService:GetMaxCollisionGroups()
local POLL_INTERVAL = Constants.PollInterval

local App = Roact.Component:extend("App")

local renameTargetAncestors = {
	game:GetService("Workspace"),
	game:GetService("Lighting"),
	game:GetService("MaterialService"),
	game:GetService("ReplicatedFirst"),
	game:GetService("ReplicatedStorage"),
	game:GetService("ServerScriptService"),
	game:GetService("ServerStorage"),
	game:GetService("StarterGui"),
	game:GetService("StarterPack"),
	game:GetService("StarterPlayer"),
	game:GetService("SoundService"),
}

function App:init()
	local groups = PhysicsService:GetRegisteredCollisionGroups()
	self:setState({
		View = "List",
		Groups = groups,
		SelectedGroupName = groups[1].name,
		CreatingGroup = false,
		RenamingGroup = false,
		DeletingGroup = false,
	})
	self.setGroupsCollidable = function(name0, name1, collidable)
		local success, response = pcall(function()
			return PhysicsService:CollisionGroupSetCollidable(name0, name1, collidable)
		end)
		if not success then
			warn(response)
		end
		self:updateGroups()
	end
	self.batchSetCollisionGroup = function(instances, name)
		local success, response = pcall(function()
			for _, instance in ipairs(instances) do
				instance.CollisionGroup = name
			end
		end)
		if not success then
			warn(response)
		end
		self:updateGroups()
	end
	self.createCollisionGroup = function(name)
		local success, response = pcall(function()
			return PhysicsService:RegisterCollisionGroup(name)
		end)
		if not success then
			warn(response)
		end
		self:updateGroups()
	end
	self.renameCollisionGroup = function(oldName, newName)
		local success, response = pcall(function()
			return PhysicsService:RenameCollisionGroup(oldName, newName)
		end)
		if not success then
			warn(response)
		end
		for _, ancestor in renameTargetAncestors do
			for _, descendant in ancestor:GetDescendants() do
				if descendant:IsA("BasePart") and descendant.CollisionGroup == oldName then
					descendant.CollisionGroup = newName
				end
			end
		end
		if self.state.SelectedGroupName == oldName then
			self:setState({ SelectedGroupName = newName })
		end
		self:updateGroups()
	end
	self.deleteCollisionGroup = function(name)
		local success, response = pcall(function()
			return PhysicsService:UnregisterCollisionGroup(name)
		end)
		if not success then
			warn(response)
		end
		for _, ancestor in renameTargetAncestors do
			for _, descendant in ancestor:GetDescendants() do
				if descendant:IsA("BasePart") and descendant.CollisionGroup == name then
					descendant.CollisionGroup = "Default"
				end
			end
		end
		self:updateGroups()
	end
end

function App:updateGroups()
	local groups = PhysicsService:GetRegisteredCollisionGroups()
	local prevSelectedGroupName = self.state.SelectedGroupName
	local nextSelectedGroupName
	for _, group in ipairs(groups) do
		if group.name == prevSelectedGroupName then
			nextSelectedGroupName = prevSelectedGroupName
			break
		end
	end
	self:setState({
		Groups = groups,
		SelectedGroupName = nextSelectedGroupName or groups[1].name,
	})
end

local function areGroupsDifferent(groups0, groups1)
	if #groups0 ~= #groups1 then
		return true
	end
	for i = 1, #groups0 do
		local item0 = groups0[i]
		local item1 = groups1[i]
		if item0.name ~= item1.name then
			return true
		elseif item0.mask ~= item1.mask then
			return true
		end
	end
	return false
end

function App:didMount()
	local nextCheck = os.clock() + POLL_INTERVAL
	self.pollConnection = RunService.Heartbeat:Connect(function()
		if os.clock() >= nextCheck then
			local lastGroups = self.state.Groups
			local nextGroups = PhysicsService:GetRegisteredCollisionGroups()
			if areGroupsDifferent(lastGroups, nextGroups) then
				self:updateGroups()
			end
			nextCheck += POLL_INTERVAL
		end
	end)
end

function App:willUnmount()
	self.pollConnection:Disconnect()
end

function App:render()
	local isMaxGroups = #self.state.Groups >= MAX_GROUPS
	local isModalActive = self.state.CreatingGroup or self.state.RenamingGroup or self.state.DeletingGroup
	local selectedGroupName = self.state.SelectedGroupName

	return Roact.createFragment({
		CreateWidget = self.state.CreatingGroup and Roact.createElement(GroupNameWidget, {
			Title = "Create Group",
			Action = "Create",
			OnClosed = function()
				self:setState({ CreatingGroup = false })
			end,
			OnSubmitted = function(name)
				self.createCollisionGroup(name)
				self:setState({ CreatingGroup = false })
			end,
		}),
		RenameWidget = self.state.RenamingGroup and Roact.createElement(GroupNameWidget, {
			Title = string.format("Rename Group (%s)", selectedGroupName),
			Action = "Rename",
			OnClosed = function()
				self:setState({ RenamingGroup = false })
			end,
			OnSubmitted = function(name)
				self.renameCollisionGroup(selectedGroupName, name)
				self:setState({ RenamingGroup = false })
			end,
		}),
		DeleteWidget = self.state.DeletingGroup and Roact.createElement(DeleteGroupWidget, {
			Title = string.format("Delete Group (%s)", selectedGroupName),
			GroupName = selectedGroupName,
			OnClosed = function()
				self:setState({ DeletingGroup = false })
			end,
			OnActivated = function()
				self.deleteCollisionGroup(selectedGroupName)
				self:setState({ DeletingGroup = false })
			end,
		}),
		Tabs = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
			}),
			ListViewButton = Roact.createElement(TabButton, {
				LayoutOrder = 0,
				Size = UDim2.fromScale(0.5, 1),
				Text = "List View",
				Selected = self.state.View == "List",
				OnActivated = function()
					self:updateGroups()
					self:setState({ View = "List" })
				end,
				Disabled = isModalActive,
			}),
			GridViewButton = Roact.createElement(TabButton, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.5, 1),
				Text = "Grid View",
				Selected = self.state.View == "Grid",
				OnActivated = function()
					self:updateGroups()
					self:setState({ View = "Grid" })
				end,
				Disabled = isModalActive,
			}),
		}),
		Inner = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 1, -31),
			BackgroundTransparency = 1,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
			}),
			Views = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, -32),
				BackgroundTransparency = 1,
			}, {
				List = self.state.View == "List" and Roact.createElement(ListView, {
					Groups = self.state.Groups,
					SelectedGroupName = self.state.SelectedGroupName,
					SetSelectedGroupName = function(name)
						self:setState({ SelectedGroupName = name })
					end,
					SetGroupsCollidable = self.setGroupsCollidable,
					Disabled = isModalActive,
				}),
				Grid = self.state.View == "Grid" and Roact.createElement(GridView, {
					Groups = self.state.Groups,
					SetGroupsCollidable = self.setGroupsCollidable,
					Disabled = isModalActive,
				}),
			}),
			Actions = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 4),
				}),
				Create = Roact.createElement(MainButton, {
					LayoutOrder = 0,
					Size = UDim2.new(0, 28, 1, 0),
					Text = "",
					OnActivated = function()
						self:setState({ CreatingGroup = true })
					end,
					Disabled = isModalActive or isMaxGroups,
				}, {
					Icon = Roact.createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(16, 16),
						BackgroundTransparency = 1,
						Image = "rbxassetid://6688839343",
						ImageTransparency = (isModalActive or isMaxGroups) and 0.75 or 0,
					}),
				}),
				AddTo = self.state.View == "List" and Roact.createElement(AddToGroup, {
					BatchSetCollisionGroup = self.batchSetCollisionGroup,
					SelectedGroupName = self.state.SelectedGroupName,
					Disabled = isModalActive,
				}),
				Rename = self.state.View == "List" and Roact.createElement(Button, {
					LayoutOrder = 2,
					Size = UDim2.new(0.32, -18, 1, 0),
					Text = "Rename",
					OnActivated = function()
						self:setState({ RenamingGroup = true })
					end,
					Disabled = self.state.SelectedGroupName == "Default" or isModalActive,
				}),
				Delete = self.state.View == "List" and Roact.createElement(Button, {
					LayoutOrder = 3,
					Size = UDim2.new(0.3, -18, 1, 0),
					Text = "Delete",
					OnActivated = function()
						self:setState({ DeletingGroup = true })
					end,
					Disabled = self.state.SelectedGroupName == "Default" or isModalActive,
				}),
			}),
		}),
	})
end

return App
