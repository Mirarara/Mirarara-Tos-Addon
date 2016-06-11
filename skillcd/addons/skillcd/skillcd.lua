local addonName = "SKILLCD";
local author = 'MIRARARA';

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {};
local g = _G['ADDONS'][author][addonName];
local acutil = require('acutil');

g['TIMER'] = g['TIMER'] or {};

g.settingsFileLoc = "../addons/skillcd/skillcd.json";

if not g.loaded then
	g.settings = {
		showmsg = 0;
		indicatorcd = 1;
		oldshowmsg = 1;
		defaultswitch = true;
		skillswitch = {};
		alias = {};
	}
	g.clock = {};
	g.lastusedskill = 'dummy';
	
end

if not g.loaded then
	local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
	if err then
		acutil.saveJSON(g.settingsFileLoc, g.settings);
	else
		g.settings = t;
	end
	g.loaded = true;
end



function QUICKSLOTNEXPBAR_SLOT_USE_CD(frame, slot, argStr, argNum)

	local g = _G['ADDONS']['MIRARARA']['SKILLCD'];
	local acutil = require('acutil');
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	
	
	
	if iconInfo.category == 'Skill' then
		
		local totalTime = 0;
		local curTime = 0;
		
		local skillInfo = session.GetSkill(iconInfo.type);
		local sklObj = GetIES(skillInfo:GetObject());
		
		local realname = dictionary.ReplaceDicIDInCompStr(sklObj.Name)
		g.lastusedskill = realname;

		if skillInfo ~= nil then
			local remainRefresh = skillInfo:GetRemainRefreshTimeMS();
			if remainRefresh > 0 then
				curTime = remainRefresh; 
				totalTime = skillInfo:GetMaxRefreshTimeMS();
			else
				curTime = skillInfo:GetCurrentCoolDownTime();
				totalTime = skillInfo:GetTotalCoolDownTime();
			end
		end
		
		local indicatorok = g.settings.defaultswitch;
		if g.settings.skillswitch[realname] == 1 then
			indicatorok = true;
		elseif g.settings.skillswitch[realname] == 2 then
			indicatorok = false;
		end
		
		if curTime ~= 0 and indicatorok then
			local timeinsec = string.format("%." .. (1) .. "f", curTime/1000);
			g.clock[realname] = g.clock[realname] or 0;
			local cooldownpass = os.clock()-g.clock[realname];
			
			local skillname = g.settings.alias[realname] or sklObj.Name;
			
			if cooldownpass > g.settings.indicatorcd then
				if math.floor(g.settings.showmsg) == 1 then
					ui.Chat(skillname..' in '..timeinsec..' seconds.');
				elseif math.floor(g.settings.showmsg) == 2 then
					ui.Chat('/p '..skillname..' in '..timeinsec..' seconds.');
				elseif math.floor(g.settings.showmsg) == 3 then
					ui.Chat('/g '..skillname..' in '..timeinsec..' seconds.');
				elseif math.floor(g.settings.showmsg) == 4 then
					ui.Chat('!!'..skillname..' in '..timeinsec..' seconds.');
				end
			g.clock[realname] = os.clock();
			end	
		else
			g.clock[realname] = os.clock();
		end
	end
	
	QUICKSLOTNEXPBAR_SLOT_USE_OLD_CD(frame, slot, argStr, argNum);
end

function g.cdmsgsetting(arg)
	local num = table.remove(arg,1);
	local g = _G['ADDONS']['MIRARARA']['SKILLCD'];
	local acutil = require('acutil');
	
	num = tonumber(num);
	if num == 1 then
		ui.SysMsg('[SkillCD] CD Indicator is announced to normal chat');
		g.settings.showmsg = num;
		g.settings.oldshowmsg = num;
	elseif num == 2 then
		ui.SysMsg('[SkillCD] CD Indicator is announced to party chat');
		g.settings.showmsg = num;
		g.settings.oldshowmsg = num;
	elseif num == 3 then
		ui.SysMsg('[SkillCD] CD Indicator is announced to guild chat');
		g.settings.showmsg = num;
		g.settings.oldshowmsg = num;
	elseif num == 4 then
		ui.SysMsg('[SkillCD] CD Indicator is announced on head');
		g.settings.showmsg = num;
		g.settings.oldshowmsg = num;
	else
		if g.settings.showmsg == 0 then
			g.settings.showmsg = g.settings.oldshowmsg;
			ui.SysMsg('[SkillCD] toggled on.');
		else
			g.settings.showmsg = 0;
			ui.SysMsg('[SkillCD] toggled off.');
		end
	end
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function g.setcdtime(arg)
	local num = table.remove(arg,1);
	local g = _G['ADDONS']['MIRARARA']['SKILLCD'];
	local acutil = require('acutil');
	
	g.settings.indicatorcd = tonumber(num);
	ui.SysMsg('[SkillCD] Message cooldown is set to '..g.settings.indicatorcd..' seconds.');
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function g.showcdhelp()
	CHAT_SYSTEM('[SkillCD]');
	CHAT_SYSTEM('/cdset - Toggle On/Off the indicator');
	CHAT_SYSTEM('/cdset 1 - Report in Normal chat');
	CHAT_SYSTEM('/cdset 2 - Report in Party chat');
	CHAT_SYSTEM('/cdset 3 - Report in Guild chat');
	CHAT_SYSTEM('/cdset 4 - Report on Head');
	CHAT_SYSTEM('/cdtime [num] - Set the cooldown of indicator to num seconds');
	CHAT_SYSTEM('/cdtoggle - Toggle the indicator On/Off for the last used skill');
	CHAT_SYSTEM('/cdreset - Reset all individual toggle for indicator');
	CHAT_SYSTEM("/cddefault [on/off] - All skill will/won't be reported by default");
	CHAT_SYSTEM("/cdalias [name] - Change the Skill Name, leave blank to reset");
end

function g.reloadcd()
	dofile('../addons/skillcd/skillcd.lua');
	ui.SysMsg('[SkillCD] Reloaded');
end

function g.cdtoggle()
	local g = _G['ADDONS']['MIRARARA']['SKILLCD'];
	local acutil = require('acutil');
	
	local skill = g.lastusedskill;
	if not g.settings.skillswitch[skill] then
		if g.settings.defaultswitch then
			g.settings.skillswitch[skill] = 1;
		else
			g.settings.skillswitch[skill] = 2;
		end
	end
	
	if g.settings.skillswitch[skill] == 1 then
		g.settings.skillswitch[skill] = 2;
		CHAT_SYSTEM(skill.."'s cooldown will not be reported.");
	else
		g.settings.skillswitch[skill] = 1;
		CHAT_SYSTEM(skill.."'s cooldown will be reported.");
	end
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function g.cdreset()
	local g = _G['ADDONS']['MIRARARA']['SKILLCD'];
	local acutil = require('acutil');
	
	g.settings.skillswitch = {};
	
	CHAT_SYSTEM('All individual skill indicator toggle resetted.');
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function g.cddefault(arg)
	local g = _G['ADDONS']['MIRARARA']['SKILLCD'];
	local acutil = require('acutil');
	
	local cmd = table.remove(arg,1);
	if cmd == 'on' then
		g.settings.defaultswitch = true;
		CHAT_SYSTEM('Skill Announcer is on by default.');
	elseif cmd == 'off' then
		g.settings.defaultswitch = false;
		CHAT_SYSTEM('Skill Announcer is off by default.');
	end
	
	
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function g.cdalias(arg)
	local g = _G['ADDONS']['MIRARARA']['SKILLCD'];
	local acutil = require('acutil');
	
	local words = '';
	
	for i,v in pairs(arg) do
		words = words..' '..v;
	end
	
	local skill = g.lastusedskill;
	
	if words ~= '' then
		g.settings.alias[skill] = words;
		CHAT_SYSTEM(skill..' will be alias to '..words..'.');
	else
		g.settings.alias[skill] = nil;
		CHAT_SYSTEM(skill.."'s alias resetted.");
	end
	
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end


function g.cdshow(arg)
	local g = _G['ADDONS']['MIRARARA']['SKILLCD'];
	local acutil = require('acutil');
	
	local words = '';
	
	for i,v in pairs(arg) do
		words = words..' '..v;
	end
	
	CHAT_SYSTEM(words);
end

function g.setupHook(newFunction, hookedFunctionStr, name)
	name = name or "";
	local storeOldFunc = hookedFunctionStr .. "_OLD".."_"..name;
	if _G[storeOldFunc] == nil then
		_G[storeOldFunc] = _G[hookedFunctionStr];
		_G[hookedFunctionStr] = newFunction;
	else
		_G[hookedFunctionStr] = newFunction;
	end
end

function g.firstload()
	
end

acutil.slashCommand('/cdset', g.cdmsgsetting);
acutil.slashCommand('/cdtime', g.setcdtime);
acutil.slashCommand('/cdhelp', g.showcdhelp);
acutil.slashCommand('/cdreload', g.reloadcd);
acutil.slashCommand('/cdtoggle', g.cdtoggle);
acutil.slashCommand('/cdreset', g.cdreset);
acutil.slashCommand('/cddefault', g.cddefault);
acutil.slashCommand('/cddef', g.cddefault);
acutil.slashCommand('/cdalias', g.cdalias);
acutil.slashCommand('/cdshow', g.cdshow);
g.setupHook(QUICKSLOTNEXPBAR_SLOT_USE_CD,'QUICKSLOTNEXPBAR_SLOT_USE','CD');

CHAT_SYSTEM('[SkillCD] loaded. /cdhelp for command list. t.Comfy');