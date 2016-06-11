local acutil = {};
local json = require('json')

function acutil.addThousandsSeparator(amount)
	local formatted = amount

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k == 0) then
			break
		end
	end

	return formatted
end

function acutil.leftPad(str, len, char)
	if char == nil then
		char = ' '
	end

	return string.rep(char, len - #str) .. str
end

function acutil.rightPad(str, len, char)
	if char == nil then
		char = ' '
	end

	return str .. string.rep(char, len - #str)
end

function acutil.getStatPropertyFromPC(typeStr, statStr, pc)
    local errorText = "Param was nil";

    if typeStr ~= nil and statStr ~= nil and pc ~= nil then

        if typeStr == "JOB" then
            if statStr == "STR" then
                return pc.STR_JOB;
            elseif statStr == "DEX" then
                return pc.DEX_JOB;
            elseif statStr == "CON" then
                return pc.CON_JOB;
            elseif statStr == "INT" then
                return pc.INT_JOB;
            elseif statStr == "MNA" then
                return pc.MNA_JOB;
            elseif statStr == "LUCK" then
                return pc.LUCK_JOB;
            else
                errorText = "Could not find stat "..statStr.." for type "..typeStr;
            end

        elseif typeStr == "STAT" then
            if statStr == "STR" then
                return pc.STR_STAT;
            elseif statStr == "DEX" then
                return pc.DEX_STAT;
            elseif statStr == "CON" then
                return pc.CON_STAT;
            elseif statStr == "INT" then
                return pc.INT_STAT;
            elseif statStr == "MNA" then
                return pc.MNA_STAT;
            elseif statStr == "LUCK" then
                return pc.LUCK_STAT;
            else
                errorText = "Could not find stat "..statStr.." for type "..typeStr;
            end

        elseif typeStr == "BONUS" then
            if statStr == "STR" then
                return pc.STR_Bonus;
            elseif statStr == "DEX" then
                return pc.DEX_Bonus;
            elseif statStr == "CON" then
                return pc.CON_Bonus;
            elseif statStr == "INT" then
                return pc.INT_Bonus;
            elseif statStr == "MNA" then
                return pc.MNA_Bonus;
            else
                errorText = "Could not find stat "..statStr.." for type "..typeStr;
            end

        elseif typeStr == "ADD" then
            if statStr == "STR" then
                return pc.STR_ADD;
            elseif statStr == "DEX" then
                return pc.DEX_ADD;
            elseif statStr == "CON" then
                return pc.CON_ADD;
            elseif statStr == "INT" then
                return pc.INT_ADD;
            elseif statStr == "MNA" then
                return pc.MNA_ADD;
            elseif statStr == "LUCK" then
                return pc.LUCK_ADD;
            else
                errorText = "Could not find stat "..statStr.." for type "..typeStr;
            end

        elseif typeStr == "BM" then
            if statStr == "STR" then
                return pc.STR_BM;
            elseif statStr == "DEX" then
                return pc.DEX_BM;
            elseif statStr == "CON" then
                return pc.CON_BM;
            elseif statStr == "INT" then
                return pc.INT_BM;
            elseif statStr == "MNA" then
                return pc.MNA_BM;
            elseif statStr == "LUCK" then
                return pc.LUCK_BM;
            else
                errorText = "Could not find stat "..statStr.." for type "..typeStr;
            end

        else
            errorText = "Could not find a property for type "..typeStr;
        end
    end

    ui.SysMsg(errorText);
    return 0;
end

function acutil.isValidStat(statStr, includeLuck)
    if statStr == "LUCK" then
        return includeLuck;
    elseif statStr == "STR" or
           statStr == "DEX" or
           statStr == "CON" or
           statStr == "INT" or
           statStr == "MNA" then
        return true;
    end

    return false;
end

function acutil.textControlFactory(attributeName, isMainSection)
    local text = "";

    if attributeName == "MNA" then
        attributeName = "SPR"
    elseif attributeName == "MountDEF" then
        attributeName = "physical defense"
    elseif attributeName == "MountDR" then
        attributeName = "evasion"
    elseif attributeName == "MountMHP" then
        attributeName = "max HP"
    end

    if isMainSection then
        text = "Points invested in " .. attributeName;
    else
        text = "Mounted " .. attributeName .. " bonus";
    end
    return text;
end

function acutil.getItemRarityColor(itemObj)
    local itemProp = geItemTable.GetProp(itemObj.ClassID);
    local grade = itemObj.ItemGrade;

    if (itemObj.ItemType == "Recipe") then
        local recipeGrade = tonumber(itemObj.Icon:match("misc(%d)")) - 1;
        if (recipeGrade <= 0) then recipeGrade = 1 end;
        grade = recipeGrade;
    end

    if (itemProp.setInfo ~= nil) then return "00FF00"; -- set piece
    elseif (grade == 0) then return "FFBF33"; -- premium
    elseif (grade == 1) then return "FFFFFF"; -- common
    elseif (grade == 2) then return "108CFF"; -- rare
    elseif (grade == 3) then return "9F30FF"; -- epic
    elseif (grade == 4) then return "FF4F00"; -- legendary
    else return "E1E1E1"; -- no grade (non-equipment items)
    end
end

function acutil.setupHook(newFunction, hookedFunctionStr)
	local storeOldFunc = hookedFunctionStr .. "_OLD";
	if _G[storeOldFunc] == nil then
		_G[storeOldFunc] = _G[hookedFunctionStr];
		_G[hookedFunctionStr] = newFunction;
	else
		_G[hookedFunctionStr] = newFunction;
	end
end

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['EVENTS'] = _G['ADDONS']['EVENTS'] or {};
_G['ADDONS']['EVENTS']['ARGS'] = _G['ADDONS']['EVENTS']['ARGS'] or {};

function acutil.setupEvent(myAddon, functionNameAbs, myFunctionName)
	local functionName = string.gsub(functionNameAbs, "%.", "");

	if _G['ADDONS']['EVENTS'][functionName .. "_OLD"] == nil then
		_G['ADDONS']['EVENTS'][functionName .. "_OLD"] = loadstring("return " .. functionNameAbs)();
	end

	local hookedFuncString = functionNameAbs ..[[ = function(...)
		local function pack2(...) return {n=select('#', ...), ...} end
		local thisFuncName = "]]..functionName..[[";
		local result = pack2(pcall(_G['ADDONS']['EVENTS'][thisFuncName .. '_OLD'], ...));
		_G['ADDONS']['EVENTS']['ARGS'][thisFuncName] = {...};
		imcAddOn.BroadMsg(thisFuncName);
		return unpack(result, 2, result.n);
	end
	]];

	pcall(loadstring(hookedFuncString));

	myAddon:RegisterMsg(functionName, myFunctionName);
end

-- usage:
-- function myFunc(addonFrame, eventMsg)
--     local arg1, arg2, arg3 = acutils.getEventArgs(eventMsg);
-- end
function acutil.getEventArgs(eventMsg)
	return unpack(_G['ADDONS']['EVENTS']['ARGS'][eventMsg]);
end

function acutil.saveJSON(path, tbl)
	file,err = io.open(path, "w")
	if err then return _,err end

	local s = json.encode(tbl);
	file:write(s);
	file:close();
end

-- tblMerge is optional, use this to merge new pairs from tblMerge while
-- preserving the pairs set in the pre-existing config file
function acutil.loadJSON(path, tblMerge)
	local file, err=io.open(path,"r")
	if err then return _,err end

	local t = file:read("*all");
	file:close();

	t = json.decode(t);
	if tblMerge then
		t = acutil.mergeLeft(tblMerge, t)
		acutil.saveJSON(path, t);
	end
	return t;
end

-- merge left
function acutil.mergeLeft(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			acutil.mergeLeft(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end

-- credits to fiote for some code https://github.com/fiote/
acutil.slashCommands = acutil.slashCommands or {};

function acutil.slashCommand(cmd, fn)
	if cmd:sub(1,1) ~= "/" then cmd = "/" .. cmd end
	acutil.slashCommands[cmd] = fn;
end

function acutil.onUIChat(msg)
	acutil.uiChat_OLD(msg);

	local words = {};
	for word in msg:gmatch('%S+') do
		table.insert(words, word)
	end

	local cmd = table.remove(words,1);
	for i,v in ipairs({"/r","/w","/p","/y","/s","/g"}) do
		if (tostring(cmd) == tostring(v)) then
			cmd = table.remove(words,1);
			break;
		end
	end

	local fn = acutil.slashCommands[cmd];
	if (fn ~= nil) then
		acutil.closeChat();
		return fn(words);
	end
end

function acutil.closeChat()
	local chatFrame = GET_CHATFRAME();
	local edit = chatFrame:GetChild('mainchat');

	chatFrame:ShowWindow(0);
	edit:ShowWindow(0);

	ui.CloseFrame("chat_option");
	ui.CloseFrame("chat_emoticon");
end

-- alternate chat hook to avoid conflict with cwapi and lkchat
if not acutil.uiChat_OLD then
	acutil.uiChat_OLD = ui.Chat;
end
ui.Chat = acutil.onUIChat;

return acutil;
