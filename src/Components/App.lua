local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

local Plugin = script.Parent.Parent
local Constants = require(Plugin.Constants)

local Roact = require(Plugin.Vendor.Roact)
local StudioComponents = require(Plugin.Vendor.StudioComponents)

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

function App:init()
	local groups = PhysicsService:GetCollisionGroups()
	self:setState({
		View = "List",
		Groups = groups,
		SelectedGroupId = groups[1].id,
		CreatingGroup = false,
		RenamingGroup = false,
		DeletingGroup = false,
	})
	self.setGroupsCollidable = function(id0, id1, collidable)
		local success, response = pcall(function()
			local name0 = PhysicsService:GetCollisionGroupName(id0)
			local name1 = PhysicsService:GetCollisionGroupName(id1)
			return PhysicsService:CollisionGroupSetCollidable(name0, name1, collidable)
		end)
		if not success then
			warn(response)
		end
		self:updateGroups()
	end
	self.batchSetCollisionGroup = function(instances, id)
		local success, response = pcall(function()
			local name = PhysicsService:GetCollisionGroupName(id)
			for _, instance in ipairs(instances) do
				PhysicsService:SetPartCollisionGroup(instance, name)
			end
		end)
		if not success then
			warn(response)
		end
		self:updateGroups()
	end
	self.createCollisionGroup = function(name)
		local success, response = pcall(function()
			return PhysicsService:CreateCollisionGroup(name)
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
		self:updateGroups()
	end
	self.deleteCollisionGroup = function(name)
		local success, response = pcall(function()
			return PhysicsService:RemoveCollisionGroup(name)
		end)
		if not success then
			warn(response)
		end
		self:updateGroups()
	end
end

function App:updateGroups()
	local groups = PhysicsService:GetCollisionGroups()
	local prevSelectedGroupId = self.state.SelectedGroupId
	local nextSelectedGroupId
	for _, group in ipairs(groups) do
		if group.id == prevSelectedGroupId then
			nextSelectedGroupId = prevSelectedGroupId
			break
		end
	end
	self:setState({
		Groups = groups,
		SelectedGroupId = nextSelectedGroupId or groups[1].id,
	})
end

local function areGroupsDifferent(groups0, groups1)
	if #groups0 ~= #groups1 then
		return true
	end
	for i = 1, #groups0 do
		local item0 = groups0[i]
		local item1 = groups1[i]
		if item0.id ~= item1.id then
			return true
		elseif item0.name ~= item1.name then
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
			local nextGroups = PhysicsService:GetCollisionGroups()
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

	local selectedGroupName = nil
	if self.state.SelectedGroupId then
		selectedGroupName = PhysicsService:GetCollisionGroupName(self.state.SelectedGroupId)
	end

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
					SelectedGroupId = self.state.SelectedGroupId,
					SetSelectedGroupId = function(id)
						self:setState({ SelectedGroupId = id })
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
					SelectedGroupId = self.state.SelectedGroupId,
					Disabled = isModalActive,
				}),
				Rename = self.state.View == "List" and Roact.createElement(Button, {
					LayoutOrder = 2,
					Size = UDim2.new(0.32, -18, 1, 0),
					Text = "Rename",
					OnActivated = function()
						self:setState({ RenamingGroup = true })
					end,
					Disabled = self.state.SelectedGroupId == 0 or isModalActive,
				}),
				Delete = self.state.View == "List" and Roact.createElement(Button, {
					LayoutOrder = 3,
					Size = UDim2.new(0.3, -18, 1, 0),
					Text = "Delete",
					OnActivated = function()
						self:setState({ DeletingGroup = true })
					end,
					Disabled = self.state.SelectedGroupId == 0 or isModalActive,
				}),
			}),
		}),
	})
end

return App
