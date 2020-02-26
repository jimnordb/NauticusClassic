﻿
-- declare colour codes for console messages
local RED     = "|cffff0000"
local GREEN   = "|cff00ff00"
local YELLOW  = "|cffffff00"
local WHITE   = "|cffffffff"
local GREY    = "|cffbababa"

-- constants
local NONE = -1
local ARTWORK_PATH = "Interface\\AddOns\\NauticusClassic\\Artwork\\"
local ARTWORK_ZONING = ARTWORK_PATH.."MapIcon_Zoning"
local ARTWORK_DEPARTING = ARTWORK_PATH.."Departing"
local ARTWORK_IN_TRANSIT = ARTWORK_PATH.."Transit"
local ARTWORK_DOCKED = ARTWORK_PATH.."Docked"
local MAX_FORMATTED_TIME = 297 -- the longest route minus 60
local ICON_DEFAULT_SIZE = 18

NauticusClassic = LibStub("AceAddon-3.0"):NewAddon("NauticusClassic", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0")
local NauticusClassic = NauticusClassic
local L = LibStub("AceLocale-3.0"):GetLocale("NauticusClassic")
local HBD = LibStub("HereBeDragons-2.0")
local Pins = LibStub("HereBeDragons-Pins-2.0")
local ldbicon = LibStub("LibDBIcon-1.0")

-- object variables
NauticusClassic.DEFAULT_PREFIX = "NauticSync" -- do not change!
NauticusClassic.versionNum = 106 -- for comparison
NauticusClassic.lowestNameTime = "--"
NauticusClassic.tempText = ""
NauticusClassic.tempTextCount = 0
NauticusClassic.debug = false
NauticusClassic.iconRenderTimer = nil

-- local variables
local lastcheck_timeout = 30

local alarmOffset
local alarmSet = false
local alarmDinged = false
local alarmCountdown = 0

local transports
local transitData = {}
local triggers = {}
local zonings = {}
local autoSelect, showMiniIcons, worldIconSize, factionOnlyIcons

local defaults = {
	profile = {
		factionSpecific = true,
		zoneSpecific = false,
		alarmOffset = 20,
		miniIconSize = 1,
		worldIconSize = 1.25,
		iconFramerate = 30,
		showMiniIcons = true,
		showWorldIcons = true,
		factionOnlyIcons = false,
		minimap = {
			hide = false,
		},
	},
	global = {
		knownCycles = {},
		debug = false,
	},
	char = {
		activeTransit = NONE,
		autoSelect = true,
	},
}

local _options = {
	showminimapicon = {
		type = 'toggle',
		name = L["Show on Mini-Map"],
		desc = L["Toggle display of icons on the Mini-Map."],
		order = 600,
		get = function()
			return NauticusClassic.db.profile.showMiniIcons
		end,
		set = function(info, val)
			NauticusClassic.db.profile.showMiniIcons = val
			showMiniIcons = val
			if not val then
				for _, t in pairs(transports) do
					Pins:RemoveMinimapIcon(self, t.minimap_icon)
					t.minimap_icon:Hide()
				end
			end
		end,
	},
	showworldmapicon = {
		type = 'toggle',
		name = L["Show on World Map"],
		desc = L["Toggle display of icons on the World Map."],
		order = 650,
		get = function()
			return NauticusClassic.db.profile.showWorldIcons
		end,
		set = function(info, val)
			NauticusClassic.db.profile.showWorldIcons = val
			showWorldIcons = val
			if not val then
				for _, t in pairs(transports) do
					Pins:RemoveWorldMapIcon(self, t.worldmap_icon)
					t.worldmap_icon:Hide()
				end
			end
		end,
	},
	iconminisize = {
		type = 'range',
		name = L["Mini-Map icon size"],
		desc = L["Change the size of the Mini-Map icons."],
		order = 400,
		get = function()
			return NauticusClassic.db.profile.miniIconSize
		end,
		set = function(info, val)
			NauticusClassic.db.profile.miniIconSize = val
			val = val * ICON_DEFAULT_SIZE
			for _, t in pairs(transports) do
				t.minimap_icon:SetSize(val, val)
				t.minimap_icon.texture:SetSize(val * math.sqrt(2), val * math.sqrt(2))
			end
		end,
		isPercent = true,
		min = .5, max = 2, step = .01,
	},
	iconworldsize = {
		type = 'range',
		name = L["World Map icon size"],
		desc = L["Change the size of the World Map icons."],
		order = 500,
		get = function()
			return NauticusClassic.db.profile.worldIconSize
		end,
		set = function(info, val)
			NauticusClassic.db.profile.worldIconSize = val
			val = val * ICON_DEFAULT_SIZE
			for _, t in pairs(transports) do
				t.worldmap_icon:SetSize(val, val)
				t.worldmap_icon.texture:SetHeight(val * math.sqrt(2), val * math.sqrt(2))
			end
		end,
		isPercent = true,
		min = .5, max = 2, step = .01,
	},
	iconframerate = {
		type = 'range',
		name = L["Icon framerate"],
		desc = L["Change the framerate of the World Map/Mini-Map icons (lower this value if you are seeing performance issues with the map open)."],
		order = 600,
		get = function()
			return NauticusClassic.db.profile.iconFramerate
		end,
		set = function(info, val)
			NauticusClassic.db.profile.iconFramerate = val
			iconFramerate = val
			if NauticusClassic.iconRenderTimer then
				NauticusClassic:CancelTimer(NauticusClassic.iconRenderTimer)
			end
			NauticusClassic.iconRenderTimer = NauticusClassic:ScheduleRepeatingTimer("DrawMapIcons", 1.0 / val)
		end,
		min = 1, max = 60, step = 1,
	},
	factiononly = {
		type = 'toggle',
		name = L["Faction only"],
		desc = L["Hide transports of opposite faction from the map, showing only neutral and those of your faction."],
		order = 675,
		get = function()
			return NauticusClassic.db.profile.factionOnlyIcons
		end,
		set = function(info, val)
			NauticusClassic.db.profile.factionOnlyIcons = val
			factionOnlyIcons = val
		end,
	},
	autoselect = {
		type = 'toggle',
		name = L["Auto select transport"],
		desc = L["Automatically select nearest transport when standing at platform."],
		order = 150,
		get = function()
			return NauticusClassic.db.char.autoSelect
		end,
		set = function(info, val)
			NauticusClassic.db.char.autoSelect = val
			autoSelect = val
		end,
	},
	alarm = {
		type = 'range',
		name = L["Alarm delay"],
		desc = L["Change the alarm delay (in seconds)."],
		order = 300,
		get = function()
			return NauticusClassic.db.profile.alarmOffset
		end,
		set = function(info, val)
			NauticusClassic.db.profile.alarmOffset = val
			alarmOffset = val
		end,
		min = 0, max = 90, step = 5,
	},
	minibutton = {
		type = 'toggle',
		name = L["Mini-Map button"],
		desc = L["Toggle the Mini-Map button."],
		order = 100,
		get = function()
			return not NauticusClassic.db.profile.minimap.hide
		end,
		set = function(info, val)
			NauticusClassic.db.profile.minimap.hide = not val
			if val then
				ldbicon:Show("NauticusClassic")
			else
				ldbicon:Hide("NauticusClassic")
			end
		end,
	},
}
local options = { type = "group", args = {
	GUI = {
		type = 'group',
		name = "NauticusClassic",
		args = {
			nautdesc = {
				type = 'description',
				name = L["Tracks the precise arrival & departure schedules of boats and Zeppelins around Azeroth and displays them on the Mini-Map and World Map in real-time."].."\n",
				order = 1,
			},
			header1 = {
				type = 'header',
				name = L["General Settings"],
				order = 99,
			},
			minibutton = _options.minibutton,
			autoselect = _options.autoselect,
			alarm = _options.alarm,
			header2 = {
				type = 'header',
				name = L["Map Icons"],
				order = 398,
			},
			iconsdesc = {
				type = 'description',
				name = L["Options for displaying transports as icons on the Mini-Map and World Map."].."\n",
				order = 399,
			},
			iconminisize = _options.iconminisize,
			iconworldsize = _options.iconworldsize,
			iconframerate = _options.iconframerate,
			showminimapicon = _options.showminimapicon,
			showworldmapicon = _options.showworldmapicon,
			factiononly = _options.factiononly,
		},
	},
} }
local optionsSlash = { type = 'group', name = "NauticusClassic", args = {
	[ L["icons"] ] = {
		type = 'group',
		name = L["Map Icons"],
		desc = L["Options for displaying transports as icons on the Mini-Map and World Map."],
		order = 399,
		args = {
			[ L["minishow"] ] = _options.showminimapicon,
			[ L["worldshow"] ] = _options.showworldmapicon,
			[ L["minisize"] ] = _options.iconminisize,
			[ L["worldsize"] ] = _options.iconworldsize,
			[ L["framerate"] ] = _options.iconframerate,
			[ L["faction"] ] = _options.factiononly,
		},
	},
	[ L["minibutton"] ] = _options.minibutton,
	[ L["autoselect"] ] = _options.autoselect,
	[ L["alarm"] ] = _options.alarm,
} }
NauticusClassic.optionsSlash = optionsSlash

function NauticusClassic:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("NauticusClassic4DB", defaults)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("NauticusClassic", options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("NauticusClassicSlashCommand", optionsSlash, { "nauticus", "naut" })
	options.args.NauticusClassicSlashCommand = optionsSlash
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("NauticusClassic", nil, nil, "GUI")
	ldbicon:Register("NauticusClassic", self.dataobj, self.db.profile.minimap)

	local f = CreateFrame("Frame", "Naut_TransportSelectFrame", nil, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(f, function(frame, level) NauticusClassic:TransportSelectInitialise(frame, level); end, "MENU")

	self:InitialiseConfig()
end

function NauticusClassic:OnEnable()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterComm(self.DEFAULT_PREFIX)

	NauticusClassic.iconRenderTimer = self:ScheduleRepeatingTimer("DrawMapIcons", 1 / iconFramerate)
	self:ScheduleRepeatingTimer("Clock_OnUpdate", 1) -- every second (clock tick)
	self:ScheduleRepeatingTimer("CheckTriggers_OnUpdate", 0.8) -- every 4/5th of a second
	--self:ScheduleRepeatingTimer("UpdateChannel", 60)

	-- local frameEvent = CreateFrame('Frame')
	-- frameEvent:SetScript("OnUpdate", self.OnUpdate)

	--self:RegisterEvent("WORLD_MAP_UPDATE")

	self:UpdateChannel(10) -- wait 10 seconds before sending to any comms channels
	self.currentZone = GetRealZoneText()
	self.currentZoneTransports = self.transitZones[self.currentZone]

	--self:DebugMessage("enabled: "..self.currentZone)
	self:SetTransport()
end

local prevx = 0
local prevy = 0
local prevdx = 0
local prevdy = 0
local lastNonZeroDxDyTime = 0

function NauticusClassic:OnUpdate()
	local x, y = HBD:GetPlayerWorldPosition()
	local ddx = abs(x - prevx)
	local ddy = abs(y - prevy)
	if prevdx == 0 and prevdy == 0 and (ddx > 0 or ddy > 0) and GetTime() - lastNonZeroDxDyTime > 10 then
		NauticusClassic:DebugMessage(format("MOVED: %.3f", GetTime()))
	end
	if ddx > 0 or ddy > 0 then
		lastNonZeroDxDyTime = GetTime()
	end
	prevdx = ddx
	prevdy = ddy
	prevx = x
	prevy = y
end

local isDrawing

function NauticusClassic:DrawMapIcons(worldOnly)
	if isDrawing then return; end; isDrawing = true

	local liveData, cycle, index, offsets, x, y, wzone, xw, yw, xm, ym, angle, transit_data, fraction,
		isZoning, isZoneInteresting, isFactionInteresting, buttonMini, buttonWorld

	local WorldMapVisible = WorldMapFrame:IsVisible()
	local px, py, instanceID = HBD:GetPlayerWorldPosition()

	for id, transport in pairs(transports) do
		if self:HasKnownCycle(id) then
			transit_data = transitData[id]
			liveData = self.liveData[id]
			cycle = math.fmod(self:GetKnownCycle(id), self.rtts[id])
			offsets = transit_data.offset
			index = liveData.index

			if index > #(offsets) or (index > 1 and offsets[index-1] > cycle) then
				index = 1
			end

			for i = index, #(offsets) do
				if offsets[i] > cycle then
					index = i
					break
				end
			end

			liveData.cycle, liveData.index = cycle, index

			if showMiniIcons or showWorldIcons then
				isZoneInteresting = (self.currentZoneTransports) and self.currentZoneTransports[id]
				isFactionInteresting = (not factionOnlyIcons) or transport.faction == UnitFactionGroup("player") or transport.faction == "Neutral"
				buttonMini, buttonWorld = transport.minimap_icon, transport.worldmap_icon

				if isZoneInteresting or WorldMapVisible then
					if index == 1 then
						x, y, angle, isZoning =
							transit_data.x[index], transit_data.y[index], transit_data.dir[index], false
					else
						fraction = (cycle - transit_data.offset[index-1]) / transit_data.dt[index]

						x, y, angle, isZoning =
							transit_data.x[index-1] + transit_data.dx[index] * fraction,
							transit_data.y[index-1] + transit_data.dy[index] * fraction,
							transit_data.dir[index-1] + transit_data.d_dir[index] * fraction,
							zonings[id][index] == true
					end

					if x < 0.5 then
						xw, yw = HBD:GetWorldCoordinatesFromAzerothWorldMap(x, y, 1)
						wzone = 1
					else
						xw, yw = HBD:GetWorldCoordinatesFromAzerothWorldMap(x, y, 0)
						wzone = 0
					end
					xm, ym = HBD:GetWorldCoordinatesFromAzerothWorldMap(x, y, instanceID)

					if xw and yw and xm and ym then
						if WorldMapVisible and showWorldIcons and isFactionInteresting then
							if isZoning ~= transport.status then
								buttonWorld.texture:SetTexture(isZoning and ARTWORK_ZONING or transport.texture_name)
								transport.status = isZoning
							end
							Pins:RemoveWorldMapIcon(self, buttonWorld)
							Pins:AddWorldMapIconWorld(self, buttonWorld, wzone, xw, yw, HBD_PINS_WORLDMAP_SHOW_WORLD)
							buttonWorld.texture:SetRotation(angle)
							buttonWorld:Show()
						elseif buttonWorld:IsVisible() then
							Pins:RemoveWorldMapIcon(self, buttonWorld)
							buttonWorld:Hide()
						end

						if isZoneInteresting and showMiniIcons and isFactionInteresting then
							if not worldOnly then
								Pins:RemoveMinimapIcon(self, buttonMini)
								Pins:AddMinimapIconWorld(self, buttonMini, instanceID, xm, ym, true)
								buttonMini.texture:SetRotation(angle - (GetCVar("rotateMinimap") == "1" and GetPlayerFacing() or 0))
								buttonMini:SetAlpha(Pins:IsMinimapIconOnEdge(buttonMini) and 0.6 or 0.9)
								buttonMini:Show()
							end
						elseif buttonMini:IsVisible() then
							Pins:RemoveMinimapIcon(self, buttonMini)
							buttonMini:Hide()
						end
					end
				else
					if buttonMini:IsVisible() then
						Pins:RemoveMinimapIcon(self, buttonMini)
						buttonMini:Hide()
					end
					if buttonWorld:IsVisible() then
						Pins:RemoveWorldMapIcon(self, buttonWorld)
						buttonWorld:Hide()
					end
				end
			end
		end
	end

	isDrawing = false
end

function NauticusClassic:Clock_OnUpdate()
	if alarmDinged then
		alarmCountdown = alarmCountdown - 1

		if 0 > alarmCountdown then
			alarmSet, alarmDinged = false, false
			PlaySound("AuctionWindowClose")
		end
	end

	local transit = self.activeTransit

	if self:HasKnownCycle(transit) then
		local liveData = self.liveData[transit]
		local cycle, index = liveData.cycle, liveData.index
		local lowestTime = math.huge
		local plat_time, colour

		for _, data in pairs(self.platforms[transit]) do
			if data.index == index then
				-- we're at a platform and waiting to depart
				plat_time = self:GetCycleByIndex(transit, index) - cycle

				if alarmSet and not alarmDinged and plat_time < alarmOffset then
					alarmDinged = true
					alarmCountdown = plat_time
					PlaySoundFile("Sound\\Spells\\PVPFlagTakenHorde.wav")
				end

				if 30 < plat_time then
					colour = YELLOW
					self.icon = ARTWORK_DOCKED
				else
					colour = RED
					self.icon = ARTWORK_DEPARTING
				end

				lowestTime = -math.huge
				self.lowestNameTime = data.ebv.." "..colour..self:GetFormattedTime(plat_time)
			else
				plat_time = self:GetCycleByIndex(transit, data.index-1) - cycle

				if 0 > plat_time then
					plat_time = plat_time + self.rtts[transit]
				end

				if plat_time < lowestTime then
					lowestTime = plat_time
					self.lowestNameTime = data.ebv.." "..GREEN..self:GetFormattedTime(plat_time)
					self.icon = ARTWORK_IN_TRANSIT
				end
			end
		end
	end

	if self.tempTextCount > 0 then
		self.tempTextCount = self.tempTextCount - 1
	end

	self:UpdateDisplay()
end

local x, y, ax, ay, dax, day, tx, ty, instanceID, dist, post, last_trig, keep_time
local old_x, old_y, old_ax, old_ay -- old player coords
local prev_time = 0
local prev_rot = 0

function NauticusClassic:CheckTriggers_OnUpdate()
	-- remember if we've already triggered a set of coords within the last 30 secs
	if last_trig and GetTime() > 30.0 + last_trig then last_trig = nil; end
	if not self.currentZoneTransports or self.currentZoneTransports.virtual then return; end

	old_x, old_y = x, y
	old_ax, old_ay = ax, ay
	x, y, instanceID = HBD:GetPlayerWorldPosition()
	ax, ay = HBD:GetAzerothWorldMapCoordinatesFromWorld(x, y, instanceID)
	if not x or not old_x or not ax or not old_ax then return; end

	-- start calculate data
	-- dax = ax - old_ax
	-- day = ay - old_ay
	-- local now = GetTime()
	-- dt = now - prev_time
	-- prev_time = now
	-- local rot = GetPlayerFacing()
	-- local drot = deg(rot - prev_rot)
	-- if drot < -180 then
	-- 	drot = 360 + drot
	-- end
	-- if drot > 180 then
	-- 	drot = drot - 360
	-- end
	-- self:DebugMessage(format("%.14f:%.14f:%.14f:%.14f:%.3f:0:%.4f:%.4f", ax, ay, dax, day, dt, drot, deg(rot)))
	-- prev_rot = rot
	-- end calculate data


	dist = HBD:GetWorldDistance(instanceID, x, y, old_x, old_y)
	-- have we moved by at least 6.16 game yards since the last check? this equates to >~110% movement speed
	if 6.16 < dist then
		if IsSwimming() or UnitOnTaxi("player") then return; end
		--check X/Y coords against all triggers for all transports in current zone
		for transit in pairs(self.currentZoneTransports) do
			for _, index in pairs(triggers[transit]) do
				post = 0 > index; if post then index = -index; end
				-- within 20 game yards of trigger coords?
				--if 20.0 > Astrolabe:ComputeDistance(0, 0, x, y,
				--	0, 0, transitData[transit].x[index], transitData[transit].y[index]) then
				tx, ty = HBD:GetWorldCoordinatesFromAzerothWorldMap(transitData[transit].x[index], transitData[transit].y[index], instanceID)
				local tdist = HBD:GetWorldDistance(instanceID, x, y, tx, ty)
				if tdist and 20.0 > tdist then
					if post then
						if last_trig and keep_time then
							self:SetKnownCycle(transit, GetTime() - last_trig + keep_time, 0, 0)
							self:RequestTransport(transit, "ALL")
							self:DoRequest(10 + math.random() * 10, "ALL")
							keep_time = nil
							last_trig = GetTime()
						end
					else
						if not last_trig then
							self:SetKnownTime(instanceID, transit, index, x, y, 17.0 < dist)
							last_trig = GetTime()
						end
					end
					return
				end
			end
		end
	elseif autoSelect and 0 == dist and not IsSwimming() then
		--check X/Y coords against all platforms in current zone
		for transit in pairs(self.currentZoneTransports) do
			if transit ~= self.activeTransit then
				for _, data in pairs(self.platforms[transit]) do
					-- within 25 game yards of platform coords?
					--if 25.0 > Astrolabe:ComputeDistance(0, 0, x, y,
					--	0, 0, transitData[transit].x[data.index], transitData[transit].y[data.index]) then
					tx, ty = HBD:GetWorldCoordinatesFromAzerothWorldMap(transitData[transit].x[data.index], transitData[transit].y[data.index], instanceID)
					local tdist = HBD:GetWorldDistance(instanceID, x, y, tx, ty)
					if tdist and 20.0 > tdist then
						self:DebugMessage("near: "..transit)
						self:SetTransport(transit)
						return
					end
				end
			end
		end
	end
end

function NauticusClassic:SetKnownTime(instanceID, transit, index, x, y, set)
	local transitData = transitData[transit]
	local ix, iy = HBD:GetWorldCoordinatesFromAzerothWorldMap(transitData.x[index-1], transitData.y[index-1], instanceID)
	local ix2, iy2 = HBD:GetWorldCoordinatesFromAzerothWorldMap(transitData.x[index], transitData.y[index], instanceID)
	--local extrapolate = -transitData.dt[index] + transitData.dt[index] *
	--	(Astrolabe:ComputeDistance(0, 0, x, y, 0, 0, ix, iy) /
	--	Astrolabe:ComputeDistance(0, 0, transitData.x[index], transitData.y[index], 0, 0, ix, iy) )
	local extrapolate = -transitData.dt[index] + transitData.dt[index] *
		(HBD:GetWorldDistance(instanceID, x, y, ix, iy) /
		HBD:GetWorldDistance(instanceID, ix2, iy2, ix, iy) )

	--self:DebugMessage("extrapolate: "..extrapolate)
	local sum_time = self:GetCycleByIndex(transit, index) + extrapolate

	--[===[@debug@
	if self.debug then
		if self:HasKnownCycle(transit) then
			local old_time = self:GetKnownCycle(transit)
			local oldCycle = math.fmod(old_time, self.rtts[transit])
			local diff = oldCycle-sum_time
			local drift = format("%0.6f", diff / ((old_time-sum_time) / self.rtts[transit]))
			self.db.global.knownCycles[transit].drift = drift
			self:DebugMessage(transit..", cycle time: "..sum_time
				.." ; old: "..format("%0.3f", oldCycle)
				.." ; diff: "..format("%0.3f", diff)
				.." ; drift: "..drift)
		else
			self:DebugMessage(transit..", cycle time: "..sum_time)
		end
	end
	--@end-debug@]===]

	if set then
		self:SetKnownCycle(transit, sum_time, 0, 0)
		self:RequestTransport(transit, "ALL")
		self:DoRequest(10 + math.random() * 10, "ALL")
	else
		keep_time = sum_time
	end
end

function NauticusClassic:GetCycleByIndex(transit, index)
	return transitData[transit].offset[index]
end

-- initialise saved variables and data
function NauticusClassic:InitialiseConfig()
	--self:DebugMessage("init config...")
	transports = self.transports
	self.debug = self.db.global.debug

	do
		local version
		--@non-debug@
		version = "1.0.6"
		--@end-non-debug@
		local title = "NauticusClassic"
		if version then
			self.version = version
			title = title.." "..version
		end
		self.title = title
	end

	if self.db.global.newerVersion then
		--self:DebugMessage("new version: "..self.db.global.newerVersion.." vs our "..self.versionNum)
		if self.db.global.newerVersion > self.versionNum then
			-- major update released and running old version longer than 7 days?
			if math.floor(self.db.global.newerVersion/10) > math.floor(self.versionNum/10) and
				604800.0 < (time() - self.db.global.newerVerAge) then

				self.comm_disable = true
				self.update_available = true
			else
				self.update_available = 30
			end
		else
			self.db.global.newerVersion = nil
			self.db.global.newerVerAge = nil
		end
	end

	alarmOffset = self.db.profile.alarmOffset
	autoSelect = self.db.char.autoSelect
	showMiniIcons = self.db.profile.showMiniIcons
	showWorldIcons = self.db.profile.showWorldIcons
	iconFramerate = self.db.profile.iconFramerate
	factionOnlyIcons = self.db.profile.factionOnlyIcons

	self.activeTransit = self.db.char.activeTransit
	-- make sure our saved active transport is still valid...
	if self.activeTransit ~= NONE and not transports[self.activeTransit] then
		self.activeTransit = NONE
		self.db.char.activeTransit = NONE
	end

	local now = GetTime()
	local the_time = time()
	if self.db.global.uptime then
		-- calculate potential drift time in ms between sessions
		local drift = (the_time - now) - (self.db.global.timestamp - self.db.global.uptime)
		self:DebugMessage(format("boot drift: %0.3f", drift))
		-- if more than 3 mins drift, that means reboot occured. we need to adjust ms timers
		if 180 < math.abs(drift) then
			local since
			-- adjust all available transport times by drift
			for transport, data in pairs(self.db.global.knownCycles) do
				since = data.since
				if since then
					since = since - drift
					if 0 > now-since then
						self.db.global.knownCycles[transport] = nil
					else
						data.since = since
						data.boots = data.boots + 1
					end
				end
			end
			self:DebugMessage("reboot must have occured")
		end
	end
	-- record uptime and 'when' (relative to local system clock) this was made
	self.db.global.uptime = now
	self.db.global.timestamp = the_time

	--local worldMapOverlay = CreateFrame("Frame", "NauticusClassicWorldMapOverlay", WorldMapButton)
	--tinsert(WorldMapDisplayFrames, worldMapOverlay)

	-- unpack transport data
	local packedData = self.packedData
	local args = {}
	local j, oldX, oldY, oldOffset, oldDir, d_dir, transit_data, texture_name, frame, texture
	local miniIconSize = self.db.profile.miniIconSize * ICON_DEFAULT_SIZE
	local worldIconSize = self.db.profile.worldIconSize * ICON_DEFAULT_SIZE
	local liveData = {}
	self.liveData = liveData

	for id, data in pairs(transports) do
		oldX, oldY, oldOffset, oldDir = 0, 0, 0, 0

		transitData[id] = { ['x'] = {}, ['y'] = {}, ['offset'] = {},
			['dx'] = {}, ['dy'] = {}, ['dt'] = {}, ['dir'] = {}, ['d_dir'] = {}, }

		zonings[id] = {}
		triggers[id] = {}
		transit_data = transitData[id]

		for i = 1, #(packedData[id]) do
			j = 0; args[6] = nil
			-- search for seperators in the string and return the separated data
			for value in string.gmatch(packedData[id][i], "[^:]+") do
				j = j + 1; args[j] = value
			end

			transit_data.x[i] = args[1]+oldX
			transit_data.y[i] = args[2]+oldY
			transit_data.offset[i] = args[3]+oldOffset
			transit_data.dx[i] = tonumber(args[1])
			transit_data.dy[i] = tonumber(args[2])
			transit_data.dt[i] = tonumber(args[3])
			d_dir = rad(args[5])
			transit_data.dir[i] = d_dir+oldDir
			transit_data.d_dir[i] = d_dir

			if args[6] then
				local comment = strsub(args[6], 1, 4)
				if comment == "plat" then
					local index = tonumber(strsub(args[6], 5))
					self.platforms[id][index].index = i
				elseif comment == "trig" then
					local index = tonumber(strsub(args[6], 5)) == 0 and -i or i
					tinsert(triggers[id], index)
				elseif comment == "zone" then
					zonings[id][i] = true
				end
			end

			oldX, oldY = transit_data.x[i], transit_data.y[i]
			oldOffset = transit_data.offset[i]
			oldDir = transit_data.dir[i]
		end

		transit_data.offset[0] = 0
		transit_data.offset[#(packedData[id])] = self.rtts[id]

		liveData[id] = { cycle = 0, index = 1, }

		texture_name = ARTWORK_PATH.."MapIcon_"..data.ship_type
		data.texture_name = texture_name

		frame = CreateFrame("Button", "NauticusClassicMiniIcon", Minimap)
		data.minimap_icon = frame
		frame:SetSize(miniIconSize, miniIconSize)
		texture = frame:CreateTexture(nil, "ARTWORK")
		frame.texture = texture
		texture:SetTexture(texture_name)
		texture:SetPoint("CENTER")
		texture:SetSize(miniIconSize * math.sqrt(2), miniIconSize * math.sqrt(2))
		frame:SetScript("OnEnter", function(self) NauticusClassic:MapIcon_OnEnter(self) end)
		frame:SetScript("OnLeave", function(self) NauticusClassic:MapIcon_OnLeave(self) end)
		frame:SetID(id)
		frame:Hide()

		frame = CreateFrame("Button", "NauticusClassicWorldIcon")
		data.worldmap_icon = frame
		frame:SetSize(worldIconSize, worldIconSize)
		texture = frame:CreateTexture(nil, "ARTWORK")
		frame.texture = texture
		texture:SetTexture(texture_name)
		texture:SetPoint("CENTER")
		texture:SetSize(worldIconSize * math.sqrt(2), worldIconSize * math.sqrt(2))
		frame:SetScript("OnEnter", function(self) NauticusClassic:MapIcon_OnEnter(self) end)
		frame:SetScript("OnLeave", function(self) NauticusClassic:MapIcon_OnLeave(self) end)
		frame:SetID(id)
		frame:Hide()
	end

	self.packedData = nil -- free some memory (too many indexes to recycle)
end

function NauticusClassic:PLAYER_ENTERING_WORLD()
	self:UpdateChannel(10)

	if GetRealZoneText() ~= "" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.currentZoneTransports = self.transitZones[GetRealZoneText()]
		--self:DebugMessage("enter: "..GetRealZoneText())
	end
end

local zoneChanged

function NauticusClassic:ZONE_CHANGED_NEW_AREA(loopback)
	if zoneChanged then self:CancelTimer(zoneChanged, true); zoneChanged = nil; end

	if not loopback and self.currentZone == GetRealZoneText() then
		zoneChanged = self:ScheduleTimer("ZONE_CHANGED_NEW_AREA", 1, true)
		return
	end

	--self:DebugMessage("zoned: "..GetRealZoneText())
	self:SetZone(GetRealZoneText())
end

function NauticusClassic:SetZone(zone)
	-- special case; don't acknowledge zone change when brushing certain zones, keeping map icons
	if	(self.currentZone == L["The Barrens"] and zone == L["Durotar"]) then return; end

	self.currentZone = zone
	self.currentZoneTransports = self.transitZones[zone]
	if self.db.profile.zoneSpecific then self:RefreshMenu(); end
end

-- function NauticusClassic:WORLD_MAP_UPDATE()
-- 	self:DrawMapIcons(true)
-- end

function NauticusClassic:ToggleAlarm()
	alarmSet = not alarmSet
	if not alarmSet then alarmDinged = false end
	DEFAULT_CHAT_FRAME:AddMessage(YELLOW.."NauticusClassic|r - "..WHITE..
		L["Alarm is now: "]..(alarmSet and RED..L["ON"] or GREEN..L["OFF"]).."|r")
	PlaySound("AuctionWindowOpen")
end

function NauticusClassic:IsAlarmSet()
	return alarmSet or alarmDinged
end

function NauticusClassic:GetKnownCycle(transport)
	local knownCycle = self.db.global.knownCycles[transport]
	if knownCycle and knownCycle.since then
		return GetTime()-knownCycle.since, knownCycle.boots, knownCycle.swaps
	end
end

function NauticusClassic:SetKnownCycle(transport, since, boots, swaps)
	if self.db.global.freeze then return; end
	local knownCycle = self.db.global.knownCycles[transport]
	if not knownCycle then
		knownCycle = {}
		self.db.global.knownCycles[transport] = knownCycle
	end
	knownCycle.since, knownCycle.boots, knownCycle.swaps = GetTime()-since, boots, swaps
	self.db.global.uptime = GetTime()
	self.db.global.timestamp = time()
end

function NauticusClassic:HasKnownCycle(transport)
	local knownCycle = self.db.global.knownCycles[transport]
	if transport ~= NONE then
		return knownCycle ~= nil and knownCycle.since ~= nil
	end
end

local formattedTimeCache = {}

-- build cache of formatted times
do
	for i = 0, 59 do
		formattedTimeCache[i] = format("%ds", i)
	end
	for i = 60, MAX_FORMATTED_TIME do
		formattedTimeCache[i] = format("%dm %02ds", i/60, math.fmod(i, 60))
	end
end

function NauticusClassic:GetFormattedTime(t)
	return formattedTimeCache[floor(t)]
end

function NauticusClassic:IsTransportListed(transport)
	local addtrans = false
	transport = transports[transport]
	if self.db.profile.factionSpecific then
		if transport.faction == UnitFactionGroup("player") or
			transport.faction == "Neutral" then

			addtrans = true
		end
	else
		addtrans = true
	end
	if addtrans and self.db.profile.zoneSpecific then
		if not string.find(string.lower(transport.name),
			string.lower(GetRealZoneText())) then

			addtrans = false
		end
	end
	return addtrans
end

function NauticusClassic:NextTransportInList()
	local isNotEmpty, isFound, addtrans, first
	for i = 1, #(transports), 1 do
		addtrans = self:IsTransportListed(i)
		isNotEmpty = isNotEmpty or addtrans
		if not first and addtrans then first = i; end
		if not isFound then
			if self.activeTransit == i then
				isFound = true
			end
		else
			if addtrans then
				addtrans = i
				break
			end
		end
	end
	if not isNotEmpty then
		addtrans = NONE
	elseif type(addtrans) ~= "number" then
		addtrans = first
	end
	return addtrans
end

function NauticusClassic:SetTransport(transport)
	if transport then
		self.activeTransit = transport
		self.db.char.activeTransit = self.activeTransit
	end

	local has = self:HasKnownCycle(self.activeTransit)

	if has then
		self.tempText = GREEN..transports[self.activeTransit].short_name
		self.tempTextCount = 3
	else
		self.lowestNameTime = (has == false) and L["N/A"] or "--"
		self.tempTextCount = 0
		self.icon = nil
	end

	self:UpdateDisplay()
end

local lastDebug = GetTime()

function NauticusClassic:DebugMessage(msg)
	if self.debug then
		local now = GetTime()
		DEFAULT_CHAT_FRAME:AddMessage(format("[Naut] ["..YELLOW.."%0.3f|r]: %s", now-lastDebug, msg))
		--ChatFrame3:AddMessage(format("[Naut] ["..YELLOW.."%0.3f|r]: %s", now-lastDebug, msg))
		lastDebug = now
	end
end
