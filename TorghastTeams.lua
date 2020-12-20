local TorghastTeams = LibStub("AceAddon-3.0"):NewAddon("TorghastTeams", "AceConsole-3.0", "AceEvent-3.0")
local TorghastTeamsLDB = LibStub("LibDataBroker-1.1"):NewDataObject("TorghastTeams", {
	type = "String",
	text = "TorghastTeams",
	icon = "Interface\\ICONS\\INV_Torghast",
	OnClick = function()
		TorghastTeams:ToggleInterface()
	end
})

-- Commands that users can type for interaction
local options = {
    name = "TorghastTeams",
    handler = TorghastTeams,
    type = "group",
    args = {
        minimap = {
            type = "execute",
            name = "Minimap Button Toggle",
            desc = "Toggles the display of the minimap button.",
            func = "MinimapButtonToggle",
		}, show = {
			type = "execute",
			name = "Show Interface",
			desc = "Shows the TorghastTeams Interface.",
			func = "ShowInterface"
		}, hide = {
			type = "execute",
			name = "Hide Interface",
			desc = "Hides the TorghastTeams Interface.",
			func = "HideInterface"
		}
	}
}

-- Minimap Icon Constructor
local icon = LibStub("LibDBIcon-1.0")

-- Frame Setup for Anima Powers
local TGT_Container = CreateFrame("Frame", "TGT_Container", UIParent, "TGTTorghastLevelPickerFrame")
TGT_Container:SetSize(928, 654)
TGT_Container:SetPoint("CENTER", UIParent, "CENTER")
local AnimaPowersList = {}

-----------------------------------------------------------------------------
-- Ace3 Intialization
function TorghastTeams:OnInitialize()
	-- Initial Variables

	-- Registering Commands with prefixes
	LibStub("AceConfig-3.0"):RegisterOptionsTable("TorghastTeams", options, {"torghastteams", "tgt"})

	-- Databroker things, still trying to really figure this out
	self.db = LibStub("AceDB-3.0"):New("TorghastTeamsDB", {
		profile = {
			minimap = {
				hide = false,
			}
		}
	})
	icon:Register("TorghastTeamsIcon", TorghastTeamsLDB, self.db.profile.minimap)
	self:RegisterChatCommand("bunnies", "ToggleInterface")
end

function TorghastTeams:OnEnable()
	-- Registering for events
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	-- self:RegisterUnitEvent("UNIT_AURA", "player")
	self:RegisterEvent("UNIT_AURA")
end

-----------------------------------------------------------------------------
-- Slash Commands Functions

-- Toggles the minimap button on or off with /tgt minimap
function TorghastTeams:MinimapButtonToggle(info)
	if self.db.profile.minimap.hide then
		print("TorghastTeams minimap button is now shown.")
		self.db.profile.minimap.hide = false
		icon:Show("TorghastTeamsIcon")
	else
		print("TorghastTeams minimap button is now hidden.")
		self.db.profile.minimap.hide = true
		icon:Hide("TorghastTeamsIcon")
	end
end

-- Shows the UI with /tgt show
function TorghastTeams:ShowInterface(info)
	TGT_Container:Show()
end

-- Hides the UI with /tgt hide
function TorghastTeams:HideInterface(info)
	TGT_Container:Hide()
end

-- Toggles between the UI, not a command, used for minimap button
function TorghastTeams:ToggleInterface()
	if (TGT_Container:IsVisible()) then
		TGT_Container:Hide()
	elseif (not TGT_Container:IsVisible()) then
		TGT_Container:Show()
	end
end

-----------------------------------------------------------------------------
-- Main Addon Functions

-- Creates the frames inside our main TGT_Container holder and
-- sets their positions based on number of party members in the group.
function TorghastTeams:CreateAnimaPowerFrames(partyMemberCount)
	for count = 0, partyMemberCount - 1, 1 do
		AnimaPowersList["PMC" .. count] = CreateFrame("Button", "TGT_AnimaPowersContainerPM" .. count, TGT_Container, "TGTMawBuffsContainer")
		AnimaPowersList["PMC" .. count]:SetSize(220, 50)

		-- This is probably really stupid but it's used to differentiate between containers later
		-- in the TCG_MawBuffs.lua file in the MaxBuffMixin:RefreshTooltip() function
		-- It was 'necessary' because otherwise the tooltips would overlap because there was no
		-- other easy way to differentiate between frames
		local magicNumber = 5554654
		AnimaPowersList["PMC" .. count]:SetID(magicNumber + count)
		AnimaPowersList["PMC" .. count]:Update()
	end
	TorghastTeams:PositionFramesByPartySize(partyMemberCount)
end

-- Make sure that our Anima Power displays are up to date, going through
-- all available party members' powers.
function TorghastTeams:UpdateAnimaPowers(partyMemberCount)
	for currentMember = 0, partyMemberCount - 1, 1 do
		if currentMember == 0 then
			AnimaPowersList["PMC" .. currentMember]:Update(currentMember)
		else
			AnimaPowersList["PMC" .. currentMember]:UpdatePartyMember(currentMember)
		end
	end
end

-- Manually setting the layouts of the containers, depending on party size.
function TorghastTeams:PositionFramesByPartySize(partyMemberCount)
	if (partyMemberCount == 1) then
		-- Looks like:
		-- [ 1 ]
		AnimaPowersList["PMC0"]:SetPoint("CENTER", TGT_Container, "CENTER", 0, 75)
	elseif (partyMemberCount == 2) then
		-- Looks like:
		-- [ 1 2 ]
		AnimaPowersList["PMC0"]:SetPoint("CENTER", TGT_Container, "CENTER", -160, 75)
		AnimaPowersList["PMC1"]:SetPoint("CENTER", TGT_Container, "CENTER", 160, 75)
	elseif (partyMemberCount == 3) then
		-- Looks like:
		-- [ 1 2 ]
		-- [  3  ]
		AnimaPowersList["PMC0"]:SetPoint("CENTER", TGT_Container, "CENTER", -240, 75)
		AnimaPowersList["PMC1"]:SetPoint("CENTER", TGT_Container, "CENTER", 0, 75)
		AnimaPowersList["PMC2"]:SetPoint("CENTER", TGT_Container, "CENTER", 240, 75)
	elseif (partyMemberCount == 4) then
		-- Looks like:
		-- [ 1 2 ]
		-- [ 3 4 ]
		AnimaPowersList["PMC0"]:SetPoint("CENTER", TGT_Container, "CENTER", -160, 165)
		AnimaPowersList["PMC1"]:SetPoint("CENTER", TGT_Container, "CENTER", 160, -65)
		AnimaPowersList["PMC2"]:SetPoint("CENTER", TGT_Container, "CENTER", -160, -65)
		AnimaPowersList["PMC3"]:SetPoint("CENTER", TGT_Container, "CENTER", 160, 165)
	elseif (partyMemberCount == 5) then
		-- Looks like:
		-- [1 2 3]
		-- [ 4 5 ]
		AnimaPowersList["PMC0"]:SetPoint("CENTER", TGT_Container, "CENTER", -230, 165)
		AnimaPowersList["PMC1"]:SetPoint("CENTER", TGT_Container, "CENTER", 0, 165)
		AnimaPowersList["PMC2"]:SetPoint("CENTER", TGT_Container, "CENTER", 230, 165)
		AnimaPowersList["PMC3"]:SetPoint("CENTER", TGT_Container, "CENTER", -115, -65)
		AnimaPowersList["PMC4"]:SetPoint("CENTER", TGT_Container, "CENTER", 115, -65)
	end
end

-----------------------------------------------------------------------------
-- Event Listeners and Scripts

-- Mostly some setup whenever the player enters the world.
function TorghastTeams:PLAYER_ENTERING_WORLD()
	local partyMembers = 0
	if (IsInJailersTower()) then
		print("Welcome to TorghastTeams! Type '/tgt' to see available commands.")
		partyMembers = GetNumGroupMembers()
		TorghastTeams:CreateAnimaPowerFrames(partyMembers)
	else
		partyMembers = GetNumGroupMembers()
		TorghastTeams:UpdateAnimaPowers(partyMembers)
	end
end

-- TODO: update the lists if group members change during a torghast run
function TorghastTeams:GROUP_ROSTER_UPDATE()
	-- To be implemented
end

-- This is the most important event, it triggers every time a player
-- selects a new anima power.
function TorghastTeams:UNIT_AURA()
	local partyMembers = 0
	if (IsInJailersTower()) then
		partyMembers = GetNumGroupMembers()
		TorghastTeams:UpdateAnimaPowers(partyMembers)
	end
end