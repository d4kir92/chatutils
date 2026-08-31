local _, ChatUtils = ...
local ICON = 133457
local VERSION = "0.4.0"
local DEFAULT_WIDTH = 460
local DEFAULT_HEIGHT = 520
local cu_settings = nil
local function ShowMinimapButtonDefault()
    return ChatUtils:GetWoWBuild() ~= "RETAIL"
end

local function ApplyDefaults()
    CHUT = CHUT or {}
    ChatUtils:SV(CHUT, "SHOWMINIMAPBUTTON", ChatUtils:GV(CHUT, "SHOWMINIMAPBUTTON", ShowMinimapButtonDefault()))
    if UnitGroupRolesAssigned then ChatUtils:SV(CHUT, "SHOWROLEICON", ChatUtils:GV(CHUT, "SHOWROLEICON", true)) end
    ChatUtils:SV(CHUT, "SHOWCLASSICON", ChatUtils:GV(CHUT, "SHOWCLASSICON", false))
    ChatUtils:SV(CHUT, "SHOWRACEICON", ChatUtils:GV(CHUT, "SHOWRACEICON", false))
    ChatUtils:SV(CHUT, "SHOWITEMICON", ChatUtils:GV(CHUT, "SHOWITEMICON", true))
    ChatUtils:SV(CHUT, "SHOWGOLDICON", ChatUtils:GV(CHUT, "SHOWGOLDICON", true))
    ChatUtils:SV(CHUT, "SHOWSILVERICON", ChatUtils:GV(CHUT, "SHOWSILVERICON", false))
    ChatUtils:SV(CHUT, "SHOWCOPPERICON", ChatUtils:GV(CHUT, "SHOWCOPPERICON", false))
    ChatUtils:SV(CHUT, "SHOWPLAYERLEVEL", ChatUtils:GV(CHUT, "SHOWPLAYERLEVEL", true))
    ChatUtils:SV(CHUT, "SHOWREALMNAME", ChatUtils:GV(CHUT, "SHOWREALMNAME", true))
    ChatUtils:SV(CHUT, "USESMALLCHANNELNAMES", ChatUtils:GV(CHUT, "USESMALLCHANNELNAMES", true))
end

local function GetCollapsed(key)
    if key == nil then return nil end
    if type(CHUT) ~= "table" then return nil end
    if type(CHUT["COLLAPSED"]) ~= "table" then return nil end
    return CHUT["COLLAPSED"][key]
end

local function SetCollapsed(key, collapsed)
    if key == nil then return end
    if type(CHUT) ~= "table" then return end
    if type(CHUT["COLLAPSED"]) ~= "table" then CHUT["COLLAPSED"] = {} end
    if collapsed then
        CHUT["COLLAPSED"][key] = true
    else
        CHUT["COLLAPSED"][key] = nil
    end
end

function ChatUtils:ToggleSettings()
    if cu_settings then cu_settings:Toggle() end
end

function ChatUtils:InitSettings()
    ApplyDefaults()
    cu_settings = ChatUtils:CreateUIWindow({
        ["name"] = "ChatUtilsSettings",
        ["pTab"] = {"CENTER"},
        ["width"] = ChatUtils:GV(CHUT, "WINDOWWIDTH", DEFAULT_WIDTH),
        ["height"] = ChatUtils:GV(CHUT, "WINDOWHEIGHT", DEFAULT_HEIGHT),
        ["minWidth"] = 360,
        ["minHeight"] = 240,
        ["onResize"] = function(width, height)
            ChatUtils:SV(CHUT, "WINDOWWIDTH", width)
            ChatUtils:SV(CHUT, "WINDOWHEIGHT", height)
        end,
        ["getCollapsed"] = function(key) return GetCollapsed(key) end,
        ["setCollapsed"] = function(key, collapsed) SetCollapsed(key, collapsed) end,
        ["title"] = format("|T%d:16:16:0:0|t ChatUtils v%s", ICON, ChatUtils:GetVersion())
    })

    cu_settings:SuspendLayout()
    cu_settings:AddSearch()
    cu_settings:AddCategory({
        ["label"] = "LID_GENERAL",
        ["key"] = "GENERAL"
    })

    cu_settings:AddCheckbox({
        ["label"] = "LID_SHOWMINIMAPBUTTON",
        ["search"] = "SHOWMINIMAPBUTTON",
        ["value"] = ChatUtils:GV(CHUT, "SHOWMINIMAPBUTTON", ShowMinimapButtonDefault()),
        ["func"] = function(value)
            ChatUtils:SV(CHUT, "SHOWMINIMAPBUTTON", value)
            if value then
                ChatUtils:ShowMMBtn("ChatUtils")
            else
                ChatUtils:HideMMBtn("ChatUtils")
            end
        end
    })

    cu_settings:AddCategory({
        ["label"] = "LID_CHAT",
        ["key"] = "CHAT"
    })

    cu_settings:AddCheckbox({
        ["label"] = "LID_SHOWITEMICON",
        ["search"] = "SHOWITEMICON",
        ["value"] = ChatUtils:GV(CHUT, "SHOWITEMICON", true),
        ["func"] = function(value) ChatUtils:SV(CHUT, "SHOWITEMICON", value) end
    })

    cu_settings:AddCategory({
        ["label"] = "LID_CHARACTER",
        ["key"] = "CHARACTER",
        ["sub"] = true
    })

    if UnitGroupRolesAssigned then
        cu_settings:AddCheckbox({
            ["label"] = "LID_SHOWROLEICON",
            ["search"] = "SHOWROLEICON",
            ["value"] = ChatUtils:GV(CHUT, "SHOWROLEICON", true),
            ["func"] = function(value) ChatUtils:SV(CHUT, "SHOWROLEICON", value) end
        })
    end

    cu_settings:AddCheckbox({
        ["label"] = "LID_SHOWCLASSICON",
        ["search"] = "SHOWCLASSICON",
        ["value"] = ChatUtils:GV(CHUT, "SHOWCLASSICON", false),
        ["func"] = function(value) ChatUtils:SV(CHUT, "SHOWCLASSICON", value) end
    })

    cu_settings:AddCheckbox({
        ["label"] = "LID_SHOWRACEICON",
        ["search"] = "SHOWRACEICON",
        ["value"] = ChatUtils:GV(CHUT, "SHOWRACEICON", false),
        ["func"] = function(value) ChatUtils:SV(CHUT, "SHOWRACEICON", value) end
    })

    cu_settings:AddCheckbox({
        ["label"] = "LID_SHOWPLAYERLEVEL",
        ["search"] = "SHOWPLAYERLEVEL",
        ["value"] = ChatUtils:GV(CHUT, "SHOWPLAYERLEVEL", true),
        ["func"] = function(value) ChatUtils:SV(CHUT, "SHOWPLAYERLEVEL", value) end
    })

    cu_settings:AddCheckbox({
        ["label"] = "LID_SHOWREALMNAME",
        ["search"] = "SHOWREALMNAME",
        ["value"] = ChatUtils:GV(CHUT, "SHOWREALMNAME", true),
        ["func"] = function(value) ChatUtils:SV(CHUT, "SHOWREALMNAME", value) end
    })

    cu_settings:AddCategory({
        ["label"] = "LID_CHATCHANNEL",
        ["key"] = "CHATCHANNEL",
        ["sub"] = true
    })

    cu_settings:AddCheckbox({
        ["label"] = "LID_USESMALLCHANNELNAMES",
        ["search"] = "USESMALLCHANNELNAMES",
        ["value"] = ChatUtils:GV(CHUT, "USESMALLCHANNELNAMES", true),
        ["func"] = function(value) ChatUtils:SV(CHUT, "USESMALLCHANNELNAMES", value) end
    })

    cu_settings:AddCategory({
        ["label"] = "LID_GOLD",
        ["key"] = "GOLD",
        ["sub"] = true
    })

    cu_settings:AddCheckbox({
        ["label"] = "LID_SHOWGOLDICON",
        ["search"] = "SHOWGOLDICON",
        ["value"] = ChatUtils:GV(CHUT, "SHOWGOLDICON", true),
        ["func"] = function(value) ChatUtils:SV(CHUT, "SHOWGOLDICON", value) end
    })

    cu_settings:AddCheckbox({
        ["label"] = "LID_SHOWSILVERICON",
        ["search"] = "SHOWSILVERICON",
        ["value"] = ChatUtils:GV(CHUT, "SHOWSILVERICON", false),
        ["func"] = function(value) ChatUtils:SV(CHUT, "SHOWSILVERICON", value) end
    })

    cu_settings:AddCheckbox({
        ["label"] = "LID_SHOWCOPPERICON",
        ["search"] = "SHOWCOPPERICON",
        ["value"] = ChatUtils:GV(CHUT, "SHOWCOPPERICON", false),
        ["func"] = function(value) ChatUtils:SV(CHUT, "SHOWCOPPERICON", value) end
    })

    cu_settings:ResumeLayout()
end

local chutSetup = CreateFrame("FRAME", "chutSetup")
ChatUtils:RegisterEvent(chutSetup, "PLAYER_LOGIN")
chutSetup:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        CHUT = CHUT or {}
        ChatUtils:SetVersion(ICON, VERSION)
        ChatUtils:AddSlash("chut", ChatUtils.ToggleSettings)
        ChatUtils:AddSlash("chatutils", ChatUtils.ToggleSettings)
        ChatUtils:SetAddonOutput("ChatUtils", ICON)
        ChatUtils:CreateMinimapButton({
            ["name"] = "ChatUtils",
            ["icon"] = ICON,
            ["dbtab"] = CHUT,
            ["dbkey"] = "SHOWMINIMAPBUTTON",
            ["vTT"] = {{format("|T%d:16:16:0:0|t ChatUtils", ICON), "v" .. ChatUtils:GetVersion()}, {ChatUtils:Trans("LID_LEFTCLICK"), ChatUtils:Trans("LID_OPENSETTINGS")}, {ChatUtils:Trans("LID_RIGHTCLICK"), ChatUtils:Trans("LID_HIDEMINIMAPBUTTON")}},
            ["funcL"] = function() ChatUtils:ToggleSettings() end,
            ["funcR"] = function()
                ChatUtils:SV(CHUT, "SHOWMINIMAPBUTTON", false)
                ChatUtils:HideMMBtn("ChatUtils")
                ChatUtils:MSG("Minimap Button is now hidden.")
            end
        })

        ChatUtils:InitSettings()
        ChatUtils:Init()
    end
end)
