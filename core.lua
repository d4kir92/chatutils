local _, ChatUtils = ...
local rightWasDown = false
local rightWasDownTs = 0
local midWasDown = false
local midWasDownTs = 0
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

ChatUtils:ThinkClicks()
function ChatUtils:SetHyperlink(link)
    local poi = string.find(link, ":", 0, true)
    local typ = string.sub(link, 1, poi - 1)
    if typ == "url" then
        local url = string.sub(link, 5)
        local tab = {}
        tab.url = url
        StaticPopup_Show("CLICK_LINK_URL", "", "", tab)

        return true
    elseif typ == "invite" or typ == "inv" or typ == "einladen" then
        local name = string.sub(link, poi + 1)
        if rightWasDown then
            if GuildInvite then
                GuildInvite(name)
            end

            return true
        else
            if midWasDown then
                CommunitiesFrame:Show()
                print("Currently only open the Window, later you can enter invitelink in settings to send the link directly to the player")
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

function ChatUtils:ConvertMessage(typ, msg, ...)
    for i, p in pairs({"[htps:/]*%w+%.%w[%w%.%/%+%-%_%#%?%=]*"}) do
        local s1 = string.find(msg, "|")
        local s2 = string.find(msg, p)
        if s1 == nil and s2 ~= nil then
            msg = string.gsub(msg, p, ChatUtils:FormatURL("%1"))
        end
    end

    if string.find(msg, "invite", 0, true) then
        local name = select(1, ...)
        if name then
            msg = string.gsub(msg, "invite", "|cff" .. "FFFF00" .. "|Hinvite:" .. name .. "|h" .. "[invite]" .. "|h|r")
        end
    elseif string.find(msg, "inv", 0, true) then
        local name = select(1, ...)
        if name then
            msg = string.gsub(msg, "inv", "|cff" .. "FFFF00" .. "|Hinv:" .. name .. "|h" .. "inv" .. "|h|r")
        end
    elseif string.find(msg, "einladen", 0, true) then
        local name = select(1, ...)
        if name then
            msg = string.gsub(msg, "einladen", "|cff" .. "FFFF00" .. "|Heinladen:" .. name .. "|h" .. "einladen" .. "|h|r")
        end
    end

    return false, msg, ...
end

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
    ChatFrame_AddMessageEventFilter(typ, ChatUtils.ConvertMessage)
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
