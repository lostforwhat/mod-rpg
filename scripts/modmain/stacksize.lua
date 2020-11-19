local _G = GLOBAL
local require = _G.require
local stackable_replica = require "components/stackable_replica"

local TUNING = _G.TUNING
TUNING.STACK_SIZE_LARGEITEM = 99
TUNING.STACK_SIZE_MEDITEM = 99
TUNING.STACK_SIZE_SMALLITEM = 99 
TUNING.STACK_SIZE_TINYITEM = 199

function stackable_replica._ctor(self, inst)
    self.inst = inst

    self._stacksize = _G.net_byte(inst.GUID, "stackable._stacksize", "stacksizedirty")
    self._maxsize = _G.net_byte(inst.GUID, "stackable._maxsize")
end

function stackable_replica:SetMaxSize(maxsize)
	self._maxsize:set(maxsize)
end

function stackable_replica:MaxSize()
	return self._maxsize:value()
end