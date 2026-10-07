local _, ChatUtils = ...
local ICON = 133457
local VERSION = "0.4.13"
local DEFAULT_WIDTH = 460
local DEFAULT_HEIGHT = 520
local cu_settings = nil
local function ShowMinimapButtonDefault()
    return ChatUtils:GetWoWBuild() ~= "RETAIL"
end

local function ApplyDefaults()
    CHUT = CHUT or {}
    if CHUT["BLOCKWORDS"] == nil and IATAB and IATAB["VALUES"] then CHUT["BLOCKWORDS"] = IATAB["VALUES"]["BLOCKWORDS"] end
    ChatUtils:SV(CHUT, "BLOCKWORDS", ChatUtils:GV(CHUT, "BLOCKWORDS", ""))
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
        ["label"] = "LID_FILTER",
        ["key"] = "FILTER"
    })

    local blockwords = CreateFrame("Frame", nil, cu_settings.content)
    blockwords:SetSize(300, 58)
    blockwords.words = {}
    blockwords.rows = {}
    local savedWords = ChatUtils:GV(CHUT, "BLOCKWORDS", "")
    if type(savedWords) == "table" then
        for _, word in ipairs(savedWords) do
            if type(word) == "string" then table.insert(blockwords.words, word) end
        end
    elseif type(savedWords) == "string" then
        for word in string.gmatch(savedWords, "[^,]+") do
            table.insert(blockwords.words, word)
        end
    end

    blockwords.Label = blockwords:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    blockwords.Label:SetPoint("TOPLEFT", 0, 0)
    local buttonTemplate = GameMenuFrame and GameMenuFrame.buttonTemplate or "GameMenuButtonTemplate"
    blockwords.help = CreateFrame("Button", nil, blockwords)
    blockwords.help:SetSize(22, 22)
    blockwords.help:SetPoint("LEFT", blockwords.Label, "RIGHT", 6, 0)
    blockwords.help:SetNormalTexture("Interface\\FriendsFrame\\InformationIcon")
    blockwords.help:SetHighlightTexture("Interface\\FriendsFrame\\InformationIcon-Highlight", "ADD")
    blockwords.help:GetHighlightTexture():SetAlpha(0.4)
    blockwords.help:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(ChatUtils:Trans("LID_BLOCKWORDS"))
        GameTooltip:AddLine(ChatUtils:Trans("LID_BLOCKWORDS_HELP"), 1, 1, 1, true)
        GameTooltip:Show()
    end)

    blockwords.help:SetScript("OnLeave", function() GameTooltip:Hide() end)
    blockwords.help:SetScript("OnHide", function(button) if GameTooltip:IsOwned(button) then GameTooltip:Hide() end end)
    blockwords.add = CreateFrame("Button", nil, blockwords, buttonTemplate)
    blockwords.add:SetSize(120, 22)
    blockwords.add:SetPoint("TOPRIGHT", 0, -20)
    blockwords.add:SetText(ChatUtils:Trans("LID_BLOCKWORDS_ADD"))
    blockwords.hint = blockwords:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    blockwords.hint:SetPoint("TOPLEFT", 0, -25)
    blockwords.hint:SetPoint("RIGHT", blockwords.add, "LEFT", -8, 0)
    blockwords.hint:SetJustifyH("LEFT")
    blockwords.hint:SetText(ChatUtils:Trans("LID_BLOCKWORDS_HINT"))
    function blockwords:Save()
        local words = {}
        for _, word in ipairs(self.words) do
            table.insert(words, word)
        end

        ChatUtils:SV(CHUT, "BLOCKWORDS", words)
    end

    function blockwords:Refresh()
        self.Label:SetText(ChatUtils:Trans("LID_BLOCKWORDS") .. " (" .. #self.words .. "/100)")
        self.add:SetEnabled(#self.words < 100)
        for index, word in ipairs(self.words) do
            local row = self.rows[index]
            if not row then
                row = CreateFrame("Frame", nil, self)
                row:SetHeight(28)
                row:SetPoint("LEFT", self, "LEFT", 0, 0)
                row:SetPoint("RIGHT", self, "RIGHT", 0, 0)
                row.number = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                row.number:SetPoint("LEFT", 0, 0)
                row.number:SetWidth(28)
                row.number:SetText(index .. ".")
                row.delete = CreateFrame("Button", nil, row, buttonTemplate)
                row.delete:SetSize(90, 22)
                row.delete:SetPoint("RIGHT", 0, 0)
                row.delete:SetText(ChatUtils:Trans("LID_BLOCKWORDS_DELETE"))
                row.box = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
                row.box:SetHeight(22)
                row.box:SetPoint("LEFT", 34, 0)
                row.box:SetPoint("RIGHT", row.delete, "LEFT", -12, 0)
                row.box:SetAutoFocus(false)
                row.box:SetScript("OnTextChanged", function(box)
                    if self.refreshing then return end
                    self.words[index] = box:GetText()
                    self:Save()
                end)

                row.box:SetScript("OnEscapePressed", function(box) box:ClearFocus() end)
                row.box:SetScript("OnEnterPressed", function(box) box:ClearFocus() end)
                row.delete:SetScript("OnClick", function()
                    for _, entry in ipairs(self.rows) do
                        entry.box:ClearFocus()
                    end

                    table.remove(self.words, index)
                    self:Save()
                    self:Refresh()
                end)

                self.rows[index] = row
            end

            row:SetPoint("TOP", self, "TOP", 0, -50 - (index - 1) * 28)
            self.refreshing = true
            row.box:SetText(word)
            self.refreshing = false
            row:Show()
        end

        for index = #self.words + 1, #self.rows do
            self.rows[index].box:ClearFocus()
            self.rows[index]:Hide()
        end

        local height = 50 + #self.words * 28
        self:SetHeight(height)
        if self.uiElement then
            self.uiElement.height = height
            cu_settings:Layout()
        end
    end

    blockwords.add:SetScript("OnClick", function()
        if #blockwords.words >= 100 then return end
        table.insert(blockwords.words, "")
        blockwords:Save()
        blockwords:Refresh()
        blockwords.rows[#blockwords.words].box:SetFocus()
    end)

    blockwords:Refresh()
    ChatUtils.UI:Add(cu_settings, blockwords, blockwords:GetHeight(), ChatUtils:Trans("LID_BLOCKWORDS"), true, "BLOCKWORDS")
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
