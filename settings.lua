local _, ChatUtils = ...
local chutSetup = CreateFrame("FRAME", "chutSetup")
ChatUtils:RegisterEvent(chutSetup, "PLAYER_LOGIN")
chutSetup:SetScript(
    "OnEvent",
    function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            CHUT = CHUT or {}
            ChatUtils:SetVersion(133457, "0.3.33")
            ChatUtils:AddSlash("chut", ChatUtils.ToggleSettings)
            ChatUtils:AddSlash("ChatUtils", ChatUtils.ToggleSettings)
            local mmbtn = nil
            ChatUtils:CreateMinimapButton(
                {
                    ["name"] = "ChatUtils",
                    ["icon"] = 133457,
                    ["var"] = mmbtn,
                    ["dbtab"] = CHUT,
                    ["vTT"] = {{"|T133457:16:16:0:0|t C|cff3FC7EBhat|rU|cff3FC7EBtils|r", "v|cff3FC7EB" .. ChatUtils:GetVersion()}, {ChatUtils:Trans("LID_LEFTCLICK"), ChatUtils:Trans("LID_OPENSETTINGS")}, {ChatUtils:Trans("LID_RIGHTCLICK"), ChatUtils:Trans("LID_HIDEMINIMAPBUTTON")}},
                    ["funcL"] = function()
                        ChatUtils:ToggleSettings()
                    end,
                    ["funcR"] = function()
                        ChatUtils:SV(CHUT, "SHOWMINIMAPBUTTON", false)
                        ChatUtils:HideMMBtn("ChatUtils")
                        ChatUtils:MSG("Minimap Button is now hidden.")
                    end,
                    ["dbkey"] = "SHOWMINIMAPBUTTON"
                }
            )

            ChatUtils:InitSettings()
            ChatUtils:Init()
        end
    end
)

local cu_settings = nil
function ChatUtils:ToggleSettings()
    if cu_settings then
        if cu_settings:IsShown() then
            cu_settings:Hide()
        else
            cu_settings:Show()
        end
    end
end

function ChatUtils:InitSettings()
    CHUT = CHUT or {}
    cu_settings = ChatUtils:CreateWindow(
        {
            ["name"] = "ChatUtils",
            ["pTab"] = {"CENTER"},
            ["sw"] = 520,
            ["sh"] = 520,
            ["title"] = format("|T133457:16:16:0:0|t C|cff3FC7EBhat|rU|cff3FC7EBtils|r v|cff3FC7EB%s", ChatUtils:GetVersion())
        }
    )

    local x = 15
    local y = 10
    ChatUtils:SetAppendX(x)
    ChatUtils:SetAppendY(y)
    ChatUtils:SetAppendParent(cu_settings)
    ChatUtils:SetAppendTab(CHUT)
    ChatUtils:AppendCategory("GENERAL")
    ChatUtils:AppendCheckbox(
        "SHOWMINIMAPBUTTON",
        ChatUtils:GetWoWBuild() ~= "RETAIL",
        function()
            if ChatUtils:GV(CHUT, "SHOWMINIMAPBUTTON", ChatUtils:GetWoWBuild() ~= "RETAIL") then
                ChatUtils:ShowMMBtn("ChatUtils")
            else
                ChatUtils:HideMMBtn("ChatUtils")
            end
        end
    )

    ChatUtils:AppendCategory("CHAT")
    if UnitGroupRolesAssigned then
        ChatUtils:AppendCheckbox("SHOWROLEICON", true)
    end

    ChatUtils:AppendCheckbox("SHOWCLASSICON", false)
    ChatUtils:AppendCheckbox("SHOWRACEICON", false)
    ChatUtils:AppendCheckbox("SHOWITEMICON", true)
    ChatUtils:AppendCheckbox("SHOWPLAYERLEVEL", true)
    --ChatUtils:AppendCheckbox("SHOWPLAYERLEVELMAX", true)
    ChatUtils:AppendCheckbox("USESMALLCHANNELNAMES", true)
end
