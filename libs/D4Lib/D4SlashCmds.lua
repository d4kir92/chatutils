local _, D4 = ...
local function GetImportAllListsToHash()
    if type(ChatFrameUtil) == "table" and type(ChatFrameUtil.ImportAllListsToHash) == "function" then return ChatFrameUtil.ImportAllListsToHash end
    if type(ChatFrame_ImportAllListsToHash) == "function" then return ChatFrame_ImportAllListsToHash end

    return nil
end

local function FlushSlashCmdList()
    local import = GetImportAllListsToHash()
    if not import then return end
    if type(securecallfunction) == "function" then
        pcall(securecallfunction, import)
    else
        pcall(import)
    end
end

function D4:AddSlash(name, func)
    local cmdName = string.upper(name)
    if not _G["SlashCmdList"] then return end
    if _G["SlashCmdList"][cmdName] then return end
    SlashCmdList[cmdName] = function(msg) func(msg) end
    local i = 1
    while _G["SLASH_" .. cmdName .. i] ~= nil do
        i = i + 1
    end

    local key = "SLASH_" .. cmdName .. i
    _G[key] = "/" .. name
    FlushSlashCmdList()
    if rawget(SlashCmdList, cmdName) == nil then _G[key] = nil end
end
