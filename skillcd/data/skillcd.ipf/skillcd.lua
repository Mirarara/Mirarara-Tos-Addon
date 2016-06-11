local addonName = "SKILLCD";
local author = 'MIRARARA';

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {};
local g = _G['ADDONS'][author][addonName];
local acutil = require('acutil');


if not g.loadlua then
	g.loadlua = false;
end


function SKILLCD_ON_INIT(addon, frame)
	local g = _G['ADDONS']['MIRARARA']['SKILLCD'];
	if not g.loadlua then
		dofile("../addons/skillcd/skillcd.lua");
		g.firstload();
		g.loadlua = true;
	end
end