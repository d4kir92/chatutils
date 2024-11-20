local _, ChatUtils = ...
local chutSetup = CreateFrame("FRAME", "chutSetup")
ChatUtils:RegisterEvent(chutSetup, "PLAYER_LOGIN")
chutSetup:SetScript(
    "OnEvent",
    function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            CHUT = CHUT or {}
            ChatUtils:AddSlash("chut", ChatUtils.ToggleSettings)
            ChatUtils:AddSlash("ChatUtils", ChatUtils.ToggleSettings)
            local mmbtn = nil
            ChatUtils:CreateMinimapButton(
                {
                    ["name"] = "ChatUtils",
                    ["icon"] = 133457,
                    ["var"] = mmbtn,
                    ["dbtab"] = CHUT,
                    ["vTT"] = {{"ChatUtils |T133457:16:16:0:0|t", "v|cff3FC7EB0.11.22"}, {"Leftclick", "Open Settings"}, {"Rightclick", "Hide Minimap Icon"}},
                    ["funcL"] = function()
                        ChatUtils:ToggleSettings()
                    end,
                    ["funcR"] = function()
                        ChatUtils:SV(CHUT, "SHOWMINIMAPBUTTON", false)
                        ChatUtils:HideMMBtn("ChatUtils")
                        ChatUtils:MSG("Minimap Button is now hidden.")
                    end,
                }
            )

            if ChatUtils:GV(CHUT, "SHOWMINIMAPBUTTON", ChatUtils:GetWoWBuild() ~= "RETAIL") then
                ChatUtils:ShowMMBtn("ChatUtils")
            else
                ChatUtils:HideMMBtn("ChatUtils")
            end

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
    ChatUtils:SetVersion("ChatUtils", 133457, "0.2.3")
    cu_settings = ChatUtils:CreateFrame(
        {
            ["name"] = "ChatUtils",
            ["pTab"] = {"CENTER"},
            ["sw"] = 520,
            ["sh"] = 520,
            ["title"] = format("ChatUtils |T133457:16:16:0:0|t v|cff3FC7EB%s", "0.2.3")
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
    ChatUtils:AppendCheckbox("SHOWROLEICON", true)
    ChatUtils:AppendCheckbox("SHOWCLASSICON", false)
    ChatUtils:AppendCheckbox("SHOWRACEICON", false)
    ChatUtils:AppendCheckbox("SHOWITEMICON", true)
    ChatUtils:AppendCheckbox("SHOWPLAYERLEVEL", true)
    --ChatUtils:AppendCheckbox("SHOWPLAYERLEVELMAX", true)
    ChatUtils:AppendCheckbox("USESMALLCHANNELNAMES", true)
end
