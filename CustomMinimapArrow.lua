-- Ensure the saved variable table exists
CustomMinimapArrowDB = CustomMinimapArrowDB or {}
CustomMinimapArrowDB.lastArrow = CustomMinimapArrowDB.lastArrow or "Teardrop Green"

local function ReplaceMinimapArrow(arrowTexture)
    -- Check if Minimap is loaded
    if not Minimap then
        return
    end

    -- Replace the minimap arrow texture
    Minimap:SetPlayerTexture(arrowTexture)
end

-- Load the saved or default arrow texture
local function LoadSavedArrow()
    local arrowDirectory = "Interface\\AddOns\\CustomMinimapArrow\\Arrows\\"
    ReplaceMinimapArrow(arrowDirectory .. CustomMinimapArrowDB.lastArrow)
end

-- Slash command to open the configuration panel
SLASH_CUSTOMMINIMAPARROW1 = "/cma"
SlashCmdList["CUSTOMMINIMAPARROW"] = function(msg)
    CustomMinimapArrowConfigPanel:Show()
end

-- Configuration panel
local function CreateConfigPanel()
    local panel = CreateFrame("Frame", "CustomMinimapArrowConfigPanel", UIParent, "BasicFrameTemplateWithInset")
    panel:SetSize(260, 100)
    panel:SetPoint("CENTER")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel.TitleText:SetText("Custom Minimap Arrow")
    panel:Hide()

    -- Dropdown menu label
    local dropdownLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropdownLabel:SetPoint("TOPLEFT", 20, -40) -- Adjusted for empty space above
    dropdownLabel:SetText("Arrow:")
    -- Dropdown menu
    local dropdown = CreateFrame("Frame", "CustomMinimapArrowDropdown", panel, "UIDropDownMenuTemplate")
    dropdown:SetPoint("LEFT", dropdownLabel, "RIGHT", 0, 0)

    local function UpdateDropdownText()
        -- Update the dropdown text to show the current selection
        UIDropDownMenu_SetText(dropdown, CustomMinimapArrowDB.lastArrow)
    end

    local function OnClick(self)
        UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
        CustomMinimapArrowDB.lastArrow = self.value
        LoadSavedArrow()
        UpdateDropdownText()
    end

    local function Initialize(self, level)
        local info = UIDropDownMenu_CreateInfo()
        local arrows = {
            "Arrowhead Amber", "Arrowhead Fire & Ice", "Arrowhead Ivory",
            "Arrowhead Leaf", "Arrowhead Rune", "Dagger Azure",
            "Dagger Black", "Dagger Bronze", "Dagger Ceremonial",
            "Dagger Gold", "Sword Azure", "Sword Black",
            "Sword Bronze", "Sword Feather", "Sword Leaf",
            "Sword Red", "Sword Spiked", "Teardrop Azure",
            "Teardrop Bronze", "Teardrop Gold", "Teardrop Green"
        }
        
        for key, value in pairs(arrows) do
            info.text = value
            info.value = value
            info.func = OnClick
            -- Set the selected ID based on the current value
            if CustomMinimapArrowDB.lastArrow == value then
                info.checked = true
            else
                info.checked = nil
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(dropdown, Initialize)
    UIDropDownMenu_SetWidth(dropdown, 150)
    UIDropDownMenu_SetButtonWidth(dropdown, 124)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")

    -- Update dropdown text when the panel is shown
    panel:SetScript("OnShow", UpdateDropdownText)

    -- Close button
    local closeButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 22)
    closeButton:SetPoint("BOTTOMRIGHT", -15, 10)
    closeButton:SetText("Close")
    closeButton:SetScript("OnClick", function()
        panel:Hide()
    end)
end

CreateConfigPanel()

-- Event handling
local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "CustomMinimapArrow" then
        LoadSavedArrow()
    end
end)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
