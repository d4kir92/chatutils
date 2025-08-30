local _, ChatUtils = ...
local GuildInvite = getglobal("GuildInvite")
local InviteUnit = getglobal("InviteUnit")
local GetNumPartyMembers = getglobal("GetNumPartyMembers")
local GetNumRaidMembers = getglobal("GetNumRaidMembers")
local gold = "|TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:0:0|t"
local silver = "|TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:0:0|t"
local copper = "|TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:0:0|t"
local rightWasDown = false
local rightWasDownTs = 0
local midWasDown = false
local midWasDownTs = 0
local moneyTab = {
    ["gold"] = {},
    ["silver"] = {},
    ["copper"] = {}
}

local function AddMoneyLang(lang, wg, ws, wc)
    if moneyTab["gold"] and not tContains(moneyTab["gold"], wg) then
        tinsert(moneyTab["gold"], wg)
    end

    if moneyTab["silver"] and not tContains(moneyTab["silver"], ws) then
        tinsert(moneyTab["silver"], ws)
    end

    if moneyTab["copper"] and not tContains(moneyTab["copper"], wc) then
        tinsert(moneyTab["copper"], wc)
    end

    if false then
        print(lang)
    end
end

AddMoneyLang("enUS", "Gold", "Silver", "Copper")
AddMoneyLang("deDE", "Gold", "Silber", "Kupfer")
local moneyTabIcons = {
    ["gold"] = gold,
    ["silver"] = silver,
    ["copper"] = copper
}

local gShort = "g"
local gLong = "Gold"
local sShort = "s"
local sLong = "Silver"
local cShort = "c"
local cLong = "Copper"
function ChatUtils:GetMoney()
    if GOLD_AMOUNT_SYMBOL then
        local sGold = string.gsub(GOLD_AMOUNT_SYMBOL, "%%d", "")
        sGold = string.gsub(sGold, " ", "")
        gShort = sGold
    end

    if GOLD_AMOUNT then
        local sGold = string.gsub(GOLD_AMOUNT, "%%d", "")
        sGold = string.gsub(sGold, " ", "")
        gLong = sGold
    end

    if SILVER_AMOUNT_SYMBOL then
        local sSilver = string.gsub(SILVER_AMOUNT_SYMBOL, "%%d", "")
        sSilver = string.gsub(sSilver, " ", "")
        sShort = sSilver
    end

    if SILVER_AMOUNT then
        local sSilver = string.gsub(SILVER_AMOUNT, "%%d", "")
        sSilver = string.gsub(sSilver, " ", "")
        sLong = sSilver
    end

    if COPPER_AMOUNT_SYMBOL then
        local sCopper = string.gsub(COPPER_AMOUNT_SYMBOL, "%%d", "")
        sCopper = string.gsub(sCopper, " ", "")
        cShort = sCopper
    end

    if COPPER_AMOUNT then
        local sCopper = string.gsub(COPPER_AMOUNT, "%%d", "")
        sCopper = string.gsub(sCopper, " ", "")
        cLong = sCopper
    end
end

ChatUtils:GetMoney()
function ChatUtils:ReplaceMoneyStart(message, word, rIcon)
    return message:gsub("^(%d+)%s*" .. word, "%1" .. rIcon)
end

function ChatUtils:ReplaceMoneyMid(message, word, rIcon)
    return message:gsub("(%s%d+)%s*" .. word, "%1" .. rIcon)
end

function ChatUtils:ReplaceMoney(message, sWord, lWord, icon)
    local _, fs = ChatFrame1:GetFont()
    if fs then
        fs = fs - 2
        if moneyTab[strlower(lWord)] then
            local rIcon = format(moneyTabIcons[strlower(lWord)], fs, fs)
            if rIcon then
                for i, word in pairs(moneyTab[strlower(lWord)]) do
                    message = ChatUtils:ReplaceMoneyStart(message, word, rIcon)
                    message = ChatUtils:ReplaceMoneyMid(message, word, rIcon)
                    message = ChatUtils:ReplaceMoneyStart(message, strlower(word), rIcon)
                    message = ChatUtils:ReplaceMoneyMid(message, strlower(word), rIcon)
                    message = ChatUtils:ReplaceMoneyStart(message, strupper(word), rIcon)
                    message = ChatUtils:ReplaceMoneyMid(message, strupper(word), rIcon)
                end
            end
        else
            local rIcon = format(icon, fs, fs)
            if rIcon then
                message = ChatUtils:ReplaceMoneyStart(message, lWord, rIcon)
                message = ChatUtils:ReplaceMoneyMid(message, lWord, rIcon)
                message = ChatUtils:ReplaceMoneyStart(message, strlower(lWord), rIcon)
                message = ChatUtils:ReplaceMoneyMid(message, strlower(lWord), rIcon)
                message = ChatUtils:ReplaceMoneyStart(message, strupper(lWord), rIcon)
                message = ChatUtils:ReplaceMoneyMid(message, strupper(lWord), rIcon)
            end
        end

        local rIcon = format(icon, fs, fs)
        if rIcon then
            message = ChatUtils:ReplaceMoneyStart(message, sWord, rIcon)
            message = ChatUtils:ReplaceMoneyMid(message, sWord, rIcon)
        end
    end

    return message
end

local function stringToTable(str)
    local t = {}
    for value in str:gmatch("%S+") do
        table.insert(t, value)
    end

    return t
end

function ChatUtils:ConvertMessage(typ, msg, name, ...)
    msg = ChatUtils:CheckWords(msg, name, "invite", "inv")
    msg = ChatUtils:CheckWords(msg, name, "einladen")
    msg = ChatUtils:CheckWords(msg, name, "layer")
    msg = ChatUtils:ReplaceMoney(msg, gShort, gLong, gold)
    msg = ChatUtils:ReplaceMoney(msg, sShort, sLong, silver)
    msg = ChatUtils:ReplaceMoney(msg, cShort, cLong, copper)

    return false, msg, name, ...
end

function ChatUtils:ChatOnlyBig(str, imax)
    if str == nil then return nil end
    local smax = imax or 3
    local res = string.gsub(str, "[^%u-]", "")
    -- shorten
    if #res > smax then
        res = string.sub(res, 1, smax)
    end

    -- 1-3 => upper
    if #str <= smax then
        res = string.upper(res)
    end

    -- no upper?
    if #res <= 0 then
        if #str <= smax then
            res = string.upper(str)
        else
            res = string.gsub(str, "[^%l-]", "")
            res = string.sub(res, 1, smax)
            res = string.upper(res)
        end
    end

    if string.find(res, "-", string.len(res), true) then
        res = string.gsub(str, "[^%u]", "")
    end

    return res
end

function ChatUtils:ThinkClicks()
    if IsMouseButtonDown("RightButton") then
        rightWasDown = true
        rightWasDownTs = time()
    end

    if rightWasDownTs < time() - 0.1 then
        rightWasDown = false
    end

    if IsMouseButtonDown("MiddleButton") then
        midWasDown = true
        midWasDownTs = time()
    end

    if midWasDownTs < time() - 0.1 then
        midWasDown = false
    end

    C_Timer.After(0.01, ChatUtils.ThinkClicks)
end

function ChatUtils:CheckWord(msg, name, word)
    if name == nil then return msg end
    local words = stringToTable(msg)
    local res = ""
    for i, v in pairs(words) do
        if i > 0 then
            res = res .. " "
        end

        local isWholeWord = v:len() == word:len()
        local w = string.gsub(v, word, "|cff" .. "FFFF00" .. "|H" .. word .. ":" .. name .. "|h" .. "[" .. word .. "]" .. "|h|r")
        if isWholeWord then
            res = res .. w
        else
            res = res .. v
        end
    end

    return res
end

function ChatUtils:CheckWords(msg, name, word, word2)
    if name == nil then return msg end
    if word and string.find(msg, word, 0, true) then
        return ChatUtils:CheckWord(msg, name, word)
    elseif word2 and string.find(msg, word2, 0, true) then
        return ChatUtils:CheckWord(msg, name, word2)
    end

    return msg
end

function ChatUtils:SetHyperlink(link)
    local poi = string.find(link, ":", 0, true)
    local typ = string.sub(link, 1, poi - 1)
    if typ == "url" then
        local url = string.sub(link, 5)
        local tab = {}
        tab.url = url
        StaticPopup_Show("CLICK_LINK_URL", "", "", tab)

        return true
    elseif typ == "invite" or typ == "inv" or typ == "einladen" or typ == "layer" then
        local name = string.sub(link, poi + 1)
        if rightWasDown then
            if C_GuildInfo then
                C_GuildInfo.Invite(name)
            elseif GuildInvite then
                GuildInvite(name)
            end

            return true
        else
            if midWasDown then
                CommunitiesFrame:Show()
                ChatUtils:MSG("Currently only open the Window, later you can enter invitelink in settings to send the link directly to the player")
            elseif C_PartyInfo and C_PartyInfo.InviteUnit then
                C_PartyInfo.InviteUnit(name)
            elseif InviteUnit then
                InviteUnit(name)
            end
        end

        return true
    end

    return false
end

function GetColoredName(event, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12)
    if not a2 then return a2 end
    local chatType = strsub(event, 10)
    if strsub(chatType, 1, 7) == "WHISPER" then
        chatType = "WHISPER"
    elseif strsub(chatType, 1, 7) == "CHANNEL" then
        chatType = "CHANNEL" .. a8
    end

    if chatType == "GUILD" then
        a2 = Ambiguate(a2, "guild")
    else
        a2 = Ambiguate(a2, "none")
    end

    local info = ChatTypeInfo[chatType]
    if info and info.colorNameByClass and a12 and a12 ~= "" and a12 ~= 0 then
        local _, class = GetPlayerInfoByGUID(a12)
        if class then
            local _, _, _, str = ChatUtils:GetClassColor(class)
            if str then return format("|c%s%s|r", str, a2) end
        end
    end

    return a2
end

local PLYCache = {}
function ChatUtils:GetGUID(name)
    return PLYCache[name]
end

function ChatUtils:FixName(name, realm)
    if name and realm == nil or realm == "" then
        local s1 = string.find(name, "-", 0, true)
        if name and s1 then
            realm = string.sub(name, s1 + 1)
            name = string.sub(name, 1, s1 - 1)
        else
            realm = GetRealmName()
        end
    end

    realm = string.gsub(realm, "-", "")
    realm = string.gsub(realm, " ", "")

    return name, realm
end

local levelTab = {}
function ChatUtils:GetLevel(name, realm)
    name, realm = ChatUtils:FixName(name, realm)

    return levelTab[name .. "-" .. realm]
end

function ChatUtils:SetLevel(name, realm, level, from)
    name, realm = ChatUtils:FixName(name, realm)
    if name and realm then
        levelTab[name .. "-" .. realm] = level
    end
end

function ChatUtils:WhoScan()
    for i = 1, C_FriendList.GetNumWhoResults() do
        local info = C_FriendList.GetWhoInfo(i)
        if info and info.fullName and info.level then
            ChatUtils:SetLevel(info.fullName, nil, info.level, "WhoScan")
        end
    end
end

function ChatUtils:FriendScan()
    for i = 1, C_FriendList.GetNumFriends() do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and info.name and info.level then
            ChatUtils:SetLevel(info.name, nil, info.level, "FriendScan")
        end
    end
end

function ChatUtils:PartyScan()
    local max = GetNumSubgroupMembers or GetNumPartyMembers
    local success = true
    for i = 1, max() do
        local name, realm = UnitName("party" .. i)
        if name then
            if UnitLevel("party" .. i) == 0 then
                success = false
            else
                ChatUtils:SetLevel(name, realm, UnitLevel("party" .. i), "PartyScan")
            end
        end
    end

    if not success then
        C_Timer.After(0.1, ChatUtils.PartyScan)
    end
end

function ChatUtils:RaidScan()
    local max = GetNumGroupMembers or GetNumRaidMembers
    for i = 1, max() do
        local _, _, _, Level = GetRaidRosterInfo(i)
        local Name, Server = UnitName("raid" .. i)
        if Name then
            ChatUtils:SetLevel(Name, Server, Level, "RaidScan")
        end
    end
end

function ChatUtils:GuildScan()
    if IsInGuild() then
        C_GuildInfo.GuildRoster()
        local max = GetNumGuildMembers()
        for i = 1, max do
            local Name, _, _, Level = GetGuildRosterInfo(i)
            local name, realm = Name:match("([^%-]+)%-?(.*)")
            if name then
                ChatUtils:SetLevel(name, realm, Level, "GuildScan")
            end
        end
    end
end

function ChatUtils:Init()
    ChatUtils:ThinkClicks()
    local chatTypes = {}
    for i, v in pairs(_G) do
        if string.find(i, "CHAT_MSG_") and not tContains(chatTypes, i) then
            tinsert(chatTypes, i)
        end
    end

    for typ in next, getmetatable(ChatTypeInfo).__index do
        if not tContains(chatTypes, "CHAT_MSG_" .. typ) then
            tinsert(chatTypes, "CHAT_MSG_" .. typ)
        end
    end

    for i, typ in pairs(chatTypes) do
        if not string.find(i, "BOSS") then
            ChatFrame_AddMessageEventFilter(typ, ChatUtils.ConvertMessage)
        end
    end

    if ChatUtils:GetWoWBuild() == "RETAIL" then
        hooksecurefunc(
            ItemRefTooltip,
            "SetHyperlink",
            function(sel, link)
                ChatUtils:SetHyperlink(link)
            end
        )
    else
        ItemRefTooltip.OldSetHyperlink = ItemRefTooltip.SetHyperlink
        function ItemRefTooltip:SetHyperlink(link)
            local worked = ChatUtils:SetHyperlink(link)
            if not worked then
                ItemRefTooltip:OldSetHyperlink(link)
            end
        end
    end

    local function LOCALChatAddItemIcons(msg)
        msg = string.gsub(
            msg,
            "(|H.-|h.-|h)",
            function(itemString)
                local typ, id = string.match(itemString, "|H(.-):(.-)|h")
                if typ == "item" then
                    id = string.match(id, "(%d+)")
                    local itemName, _, _, _, _, _, _, _, _, itemTexture = ChatUtils:GetItemInfo(id)
                    if itemName and itemTexture then
                        if CHUT["USESMALLCHANNELNAMES"] then
                            return "|T" .. itemTexture .. ":0|t" .. itemString
                        else
                            return itemString
                        end
                    else
                        return itemString
                    end
                else
                    return itemString
                end
            end
        )

        return msg
    end

    local allowedTyp = {}
    allowedTyp["player"] = true
    allowedTyp["playerCommunity"] = true
    allowedTyp["playerGM"] = true
    local function LOCALChatAddPlayerIcons(msg, author, c)
        local links = {}
        for i = 1, string.len(msg) do
            local _, _, itemString = strfind(msg, "|H(.+)|h", i)
            if not tContains(links, itemString) then
                table.insert(links, itemString)
            end
        end

        for i, itemString in ipairs(links) do
            local typ, id = string.split(":", itemString)
            if allowedTyp[typ] then
                local guid = ChatUtils:GetGUID(id)
                if guid then
                    local _, engClass, _, engRace, gender, name, realm = GetPlayerInfoByGUID(guid)
                    if engClass and engRace and gender then
                        if CHUT["SHOWCLASSICON"] and ChatUtils:GetClassIcon(engClass) then
                            msg = ChatUtils:GetClassIcon(engClass, 0) .. msg
                        end

                        if CHUT["SHOWRACEICON"] and ChatUtils:GetRaceIcon(engRace, gender) then
                            msg = ChatUtils:GetRaceIcon(engRace, gender) .. msg
                        end
                    end

                    if CHUT["SHOWROLEICON"] and UnitGroupRolesAssigned and guid then
                        local role = ChatUtils:GetRoleByGuid(guid)
                        if role and role ~= "" and role ~= "NONE" then
                            msg = "|A:" .. ChatUtils:GetRoleIcon(role) .. ":16:16:0:0|a" .. msg
                        end
                    end

                    local level = ChatUtils:GetLevel(name, realm)
                    if CHUT["SHOWPLAYERLEVEL"] and level and level > 0 then
                        if string.find(msg, name .. "|r%]") then
                            msg = string.gsub(msg, name .. "|r%]", level .. ":" .. name .. "|r%]", 1)
                        elseif string.find(msg, name .. "%]") then
                            msg = string.gsub(msg, name .. "%]", level .. ":" .. name .. "%]", 1)
                        else
                            local _, e1 = string.find(msg, name)
                            if e1 then
                                local s2 = string.find(msg, name, e1)
                                if s2 then
                                    msg = msg:sub(1, s2 - 1) .. level .. ":" .. msg:sub(s2)
                                end
                            end
                        end
                    end
                end
            end
        end

        return msg, author
    end

    local function removeTimestamp(message)
        local result = string.gsub(message, "^[:%d%d]+[%s][AM]*[PM]*[%s]*", "")
        if GetChatTimestampFormat() then
            local timestamp = BetterDate(GetChatTimestampFormat(), time())
            timestamp = string.sub(timestamp, 1, #timestamp - 1)

            return result, "[" .. timestamp .. "]"
        end

        return result
    end

    local hooks = {}
    local function AddMessage(sel, message, author, ...)
        local chanName = nil
        local timestamp = nil
        message, timestamp = removeTimestamp(message)
        local sear = message:gsub("|", ""):gsub("h%[", ":"):gsub("%]h", ":")
        local _, channel, _, channelName, chanIndex = string.split(":", sear)
        if channel and channel == "channel" and channelName then
            local s1, s2 = channelName:find("%[(.-)%]")
            if s1 and s2 then
                chanName = channelName:sub(s1 + 1, s2 - 1)
            else
                chanName = channelName
            end
        end

        if channel then
            chanName = chanName or _G["CHAT_MSG_" .. channel]
            local chanFormat = _G["CHAT_" .. channel .. "_GET"]
            if chanFormat == nil and channelName then
                chanFormat = _G["CHAT_" .. channelName .. "_GET"]
            end

            if chanFormat == nil and chanIndex then
                chanFormat = _G["CHAT_" .. chanIndex .. "_GET"]
            end

            if chanFormat then
                chanFormat = chanFormat:gsub("%s", "")
                if channelName and channelName == "EMOTE" then
                    message = message:gsub(chanFormat, " ", 1)
                else
                    message = message:gsub(chanFormat, ":", 1)
                end
            end

            if CHUT["USESMALLCHANNELNAMES"] then
                local leaderChannel = _G["CHAT_MSG_" .. channel .. "_LEADER"]
                if leaderChannel == nil then
                    leaderChannel = _G[channel .. "_LEADER"]
                end

                if leaderChannel then
                    message = ChatUtils:ReplaceStr(message, leaderChannel, ChatUtils:ChatOnlyBig(leaderChannel))
                end

                if chanName then
                    message = ChatUtils:ReplaceStr(message, chanName, ChatUtils:ChatOnlyBig(chanName))
                elseif channelName then
                    chanName = _G["CHAT_MSG_" .. channelName]
                    if chanName then
                        message = "[" .. ChatUtils:ChatOnlyBig(chanName, 1) .. "] " .. message
                    end
                end
            end

            message, author = LOCALChatAddPlayerIcons(message, author, 1)
        end

        if timestamp then
            message = timestamp .. message
        end

        return hooks[sel](sel, message, author, ...)
    end

    for index = 1, NUM_CHAT_WINDOWS do
        if index ~= 2 then
            local frame = _G["ChatFrame" .. index]
            if frame then
                hooks[frame] = frame.AddMessage
                frame.AddMessage = AddMessage
            end
        end
    end

    -- Item Icons
    local function LOCALIconsFilter(sel, typ, msg, author, ...)
        local guid = select(10, ...)
        if author and guid then
            PLYCache[author] = guid
        end

        return false, LOCALChatAddItemIcons(msg), author, ...
    end

    for i, typ in pairs(chatTypes) do
        ChatFrame_AddMessageEventFilter(typ, LOCALIconsFilter)
    end

    ChatUtils:SetLevel(UnitName("player"), nil, UnitLevel("player"))
    local delay = 0.6
    local lf = CreateFrame("Frame", "IALevelFrame")
    lf:RegisterEvent("GROUP_ROSTER_UPDATE")
    lf:RegisterEvent("CHAT_MSG_RAID")
    lf:RegisterEvent("CHAT_MSG_GUILD")
    lf:RegisterEvent("CHAT_MSG_OFFICER")
    lf:RegisterEvent("FRIENDLIST_UPDATE")
    lf:RegisterEvent("GUILD_ROSTER_UPDATE")
    lf:RegisterEvent("RAID_ROSTER_UPDATE")
    lf:RegisterEvent("WHO_LIST_UPDATE")
    lf:RegisterEvent("PLAYER_LEVEL_UP")
    lf:SetScript(
        "OnEvent",
        function(sel, event, ...)
            if event == "GUILD_ROSTER_UPDATE" or event == "CHAT_MSG_GUILD" or event == "CHAT_MSG_OFFICER" then
                C_Timer.After(delay, ChatUtils.GuildScan)
            elseif event == "PLAYER_LEVEL_UP" then
                C_Timer.After(
                    delay,
                    function()
                        ChatUtils:SetLevel(UnitName("player"), GetRealmName(), UnitLevel("player"))
                    end
                )
            elseif event == "WHO_LIST_UPDATE" then
                C_Timer.After(delay, ChatUtils.WhoScan)
            elseif event == "FRIENDLIST_UPDATE" then
                C_Timer.After(delay, ChatUtils.FriendScan)
            elseif event == "RAID_ROSTER_UPDATE" or event == "CHAT_MSG_RAID" then
                C_Timer.After(delay, ChatUtils.RaidScan)
            elseif event == "GROUP_ROSTER_UPDATE" then
                C_Timer.After(delay, ChatUtils.PartyScan)
            else
                ChatUtils:MSG("Missing Event: " .. event)
            end
        end
    )

    ChatUtils:WhoScan()
    ChatUtils:FriendScan()
    ChatUtils:PartyScan()
    ChatUtils:RaidScan()
    ChatUtils:GuildScan()
    if SetChatColorNameByClass then
        for _, v in ipairs({"SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER"}) do
            SetChatColorNameByClass(v, true)
        end

        for i = 1, 20 do
            SetChatColorNameByClass("CHANNEL" .. i, true)
        end
    end
end
