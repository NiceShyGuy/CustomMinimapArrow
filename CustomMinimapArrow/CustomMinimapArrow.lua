-- Ensure the saved variable table exists
CustomMinimapArrowDB = CustomMinimapArrowDB or {}
CustomMinimapArrowDB.lastArrow = CustomMinimapArrowDB.lastArrow or "Teardrop Green"
CustomMinimapArrowDB.scaleFactor = CustomMinimapArrowDB.scaleFactor or 1
CustomMinimapArrowDB.showFacing = CustomMinimapArrowDB.showFacing or false
CustomMinimapArrowDB.facingXPos = CustomMinimapArrowDB.facingXPos or -34
CustomMinimapArrowDB.facingYPos = CustomMinimapArrowDB.facingYPos or 31
CustomMinimapArrowDB.showDialog = CustomMinimapArrowDB.showDialog or true

-- Slash command to open the configuration panel
SLASH_CUSTOMMINIMAPARROW1 = "/cma"
SlashCmdList["CUSTOMMINIMAPARROW"] = function(msg)
    CustomMinimapArrowConfigPanel:Show()
end

-- Detect loading screen enabled
local loadingScreen = CreateFrame("Frame")
loadingScreen:RegisterEvent("LOADING_SCREEN_DISABLED")
loadingScreen:SetScript("OnEvent", function(self, event)
    UpdateCustomArrowTexture(customArrowFrame.texture:GetTexture())
end)

-- Create a custom arrow frame
customArrowFrame = CreateFrame("Frame", nil, Minimap)
customArrowFrame:SetSize(32, 32)
customArrowFrame:SetPoint("CENTER")
customArrowFrame:Hide()
customArrowFrame.texture = customArrowFrame:CreateTexture(nil, "OVERLAY")
customArrowFrame.texture:SetAllPoints(customArrowFrame)
customArrowFrame:SetScript("OnUpdate", function(self, elapsed)
    -- Update the arrow's facing direction
    playerFacing = GetPlayerFacing()
    if playerFacing == nil then
        return
    end
    if playerFacing ~= self.facing then
        -- if minimap texture is not set to spacer, then set it to spacer
        self.texture:SetRotation(playerFacing)
        self.facing = playerFacing
    end
end)

-- Function to update the arrow texture
function UpdateCustomArrowTexture(arrowTexturePath)
    -- Detect if in dungeon
    inInstance, instanceType = IsInInstance()
    print(inInstance)
    -- If in a dungeon, hide all frames
    if inInstance then
        customArrowFrame:Hide()
        facingFrame:Hide()
        dialFrame:Hide()
        needleFrame:Hide()
        -- change the minimap arrow to the last saved arrow
        Minimap:SetPlayerTexture(arrowTexturePath)
        return
    else
        if type(CustomMinimapArrowDB.scaleFactor) == "number" then
            customArrowFrame.texture:SetTexture(arrowTexturePath)
            customArrowFrame:SetSize(32 * CustomMinimapArrowDB.scaleFactor, 32 * CustomMinimapArrowDB.scaleFactor)
            customArrowFrame:Show()
            -- Hide the default minimap arrow
            Minimap:SetPlayerTexture("[[Interface\\Common\\Spacer]]")
        else
            print("Error: scaleFactor is not set properly.")
            -- Handle the error case, e.g., set a default scaleFactor or log an error
        end

        -- Show the facing display if enabled
        if CustomMinimapArrowDB.showFacing then
            facingFrame:Show()
        end

        -- Show the dial and needle if enabled
        if CustomMinimapArrowDB.showDial then
            dialFrame:Show()
            needleFrame:Show()
        end
    end
end

-- Load the saved or default arrow texture
function LoadSavedArrow()
    arrowDirectory = "Interface\\AddOns\\CustomMinimapArrow\\Arrows\\"
    arrowTexturePath = arrowDirectory .. CustomMinimapArrowDB.lastArrow
    UpdateCustomArrowTexture(arrowTexturePath)
end

-- Create a facing display frame
facingFrame = CreateFrame("Frame", nil, UIParent)
facingFrame:SetSize(100, 30)
facingFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -20, -10)

facingFrame.text = facingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
facingFrame.text:SetPoint("CENTER")
facingFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 10)
facingFrame.text:SetTextColor(1, 1, 1)
facingFrame.text:SetText("0.0")
facingFrame.background = facingFrame:CreateTexture(nil, "BACKGROUND")
facingFrame.background:SetTexture("Interface\\AddOns\\CustomMinimapArrow\\UI\\Background")
facingFrame.background:SetSize(45, 15)
facingFrame.background:SetPoint("CENTER")

-- Create a dial frame that will overlay on the inner portion of the minimap
dialFrame = CreateFrame("Frame", nil, UIParent)
dialFrame:SetSize(128, 128)
dialFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
dialFrame.texture = dialFrame:CreateTexture(nil, "OVERLAY")
dialFrame.texture:SetTexture("Interface\\AddOns\\CustomMinimapArrow\\UI\\Dial")
dialFrame.texture:SetAllPoints(dialFrame)

-- Create a needle frame that will overlay on the inner portion of the minimap
needleFrame = CreateFrame("Frame", nil, UIParent)
needleFrame:SetSize(128, 128)
needleFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
needleFrame.texture = needleFrame:CreateTexture(nil, "OVERLAY")
needleFrame.texture:SetTexture("Interface\\AddOns\\CustomMinimapArrow\\UI\\Needle")
needleFrame.texture:SetAllPoints(needleFrame)

-- rotate the needle frame to match the player's facing direction
needleFrame:SetScript("OnUpdate", function(self, elapsed)
    playerFacing = GetPlayerFacing()
    if playerFacing == nil then
        return
    end
    self.texture:SetRotation(playerFacing)
end)

-- Update the facing text
function UpdateFacingText()
    playerFacing = GetPlayerFacing()
    if playerFacing == nil then
        return
    end
    -- Convert radians to degrees and adjust to make it behave like a compass
    facingDegrees = (1 - playerFacing / (2 * math.pi)) * 360
    -- Ensure the value is between 0 and 360
    facingDegrees = facingDegrees % 360
    facingFrame.text:SetText(string.format("%.1f°", facingDegrees))
end

facingFrame:SetScript("OnUpdate", function(self, elapsed)
    UpdateFacingText()
end)

-- Configuration panel
function CreateConfigPanel()
    panel = CreateFrame("Frame", "CustomMinimapArrowConfigPanel", UIParent, "BasicFrameTemplateWithInset")
    panel:SetSize(260, 360)
    panel:SetPoint("CENTER")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel.TitleText:SetText("Custom Minimap Arrow")
    panel:Hide()

    -- Scale factor slider
    scaleSlider = CreateFrame("Slider", "CustomMinimapArrowScaleSlider", panel, "OptionsSliderTemplate")
    scaleSlider:SetMinMaxValues(0.5, 2)
    scaleSlider:SetValueStep(0.1)
    scaleSlider:SetPoint("TOP", panel, "TOP", 0, -60)
    scaleSlider:SetWidth(160)
    
    -- Initialize slider with saved scale factor
    scaleSlider:SetValue(CustomMinimapArrowDB.scaleFactor)
    getglobal(scaleSlider:GetName() .. 'Low'):SetText('0.5')
    getglobal(scaleSlider:GetName() .. 'High'):SetText('2')
    getglobal(scaleSlider:GetName() .. 'Text'):SetText('Scale Factor: ' .. string.format("%.2f", CustomMinimapArrowDB.scaleFactor) .. '\n\n')

    scaleSlider:SetScript("OnValueChanged", function(self, value)
        CustomMinimapArrowDB.scaleFactor = value
        formattedValue = string.format("%.2f", value)  -- Format to two decimal places
        getglobal(self:GetName() .. 'Text'):SetText('Scale Factor: ' .. formattedValue)
        UpdateCustomArrowTexture(customArrowFrame.texture:GetTexture())
    end)

    -- Dropdown menu label
    dropdownLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropdownLabel:SetPoint("TOP", -90, -110)
    dropdownLabel:SetText("Arrow:")
    -- Dropdown menu
    dropdown = CreateFrame("Frame", "CustomMinimapArrowDropdown", panel, "UIDropDownMenuTemplate")
    dropdown:SetPoint("LEFT", dropdownLabel, "RIGHT", 0, 0)

    function UpdateDropdownText()
        -- Update the dropdown text to show the current selection
        UIDropDownMenu_SetText(dropdown, CustomMinimapArrowDB.lastArrow)
    end

    function OnClick(self)
        UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
        CustomMinimapArrowDB.lastArrow = self.value
        LoadSavedArrow()
        UpdateDropdownText()
    end

    function Initialize(self, level)
        info = UIDropDownMenu_CreateInfo()
        arrows = {
            "Default",
            "Arrow Gold", "Arrow Stone","Arrowhead Amber",
            "Arrowhead Fire & Ice", "Arrowhead Ivory",
            "Arrowhead Leaf", "Arrowhead Rune","Arrowhead Teal", "Dagger Azure",
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

    -- Show/Hide Facing Display Checkbox
    showFacingCheckbox = CreateFrame("CheckButton", "CustomMinimapArrowShowFacingCheckbox", panel, "UICheckButtonTemplate")
    showFacingCheckbox:SetPoint("TOP", -80, -140)  -- Adjusted position
    showFacingCheckbox.text = showFacingCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    showFacingCheckbox.text:SetPoint("LEFT", showFacingCheckbox, "RIGHT", 8, 0)
    showFacingCheckbox.text:SetText("Show Facing Display")
    showFacingCheckbox:SetChecked(CustomMinimapArrowDB.showFacing)
    showFacingCheckbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            CustomMinimapArrowDB.showFacing = true
            facingFrame:Show()
        else
            CustomMinimapArrowDB.showFacing = false
            facingFrame:Hide()
        end
    end)

    -- X Position Slider
    xPosSlider = CreateFrame("Slider", "CustomMinimapArrowXPosSlider", panel, "OptionsSliderTemplate")
    xPosSlider:SetPoint("TOP", showFacingCheckbox, "BOTTOM", 100, -20)
    xPosSlider:SetWidth(200)
    xPosSlider:SetMinMaxValues(-400, 400)
    xPosSlider:SetValue(CustomMinimapArrowDB.facingXPos)
    xPosSlider:SetValueStep(1)
    xPosSlider:SetWidth(150)
    getglobal(xPosSlider:GetName() .. 'Text'):SetText(string.format("X Position: %d", CustomMinimapArrowDB.facingXPos))
    getglobal(xPosSlider:GetName() .. 'Low'):SetText('-400')
    getglobal(xPosSlider:GetName() .. 'High'):SetText('400')

    -- Y Position Slider
    yPosSlider = CreateFrame("Slider", "CustomMinimapArrowYPosSlider", panel, "OptionsSliderTemplate")
    yPosSlider:SetPoint("TOP", xPosSlider, "TOP", 0, -50)
    yPosSlider:SetWidth(200)
    yPosSlider:SetMinMaxValues(-400, 400)
    yPosSlider:SetValue(CustomMinimapArrowDB.facingYPos)
    yPosSlider:SetValueStep(1)
    yPosSlider:SetWidth(150)
    getglobal(yPosSlider:GetName() .. 'Text'):SetText(string.format("Y Position: %d", CustomMinimapArrowDB.facingYPos))
    getglobal(yPosSlider:GetName() .. 'Low'):SetText('-400')
    getglobal(yPosSlider:GetName() .. 'High'):SetText('400')

    -- X Position Slider Update Script
    xPosSlider:SetScript("OnValueChanged", function(self, value)
        currentYPos = -CustomMinimapArrowDB.facingYPos -- Get the current Y position from CustomMinimapArrowDB
        facingFrame:SetPoint("TOP", UIParent, "TOP", value, currentYPos)
        getglobal(self:GetName() .. 'Text'):SetText("X Position: " .. math.floor(value))
        CustomMinimapArrowDB.facingXPos = value -- Save the new X position to CustomMinimapArrowDB
    end)

    -- Y Position Slider Update Script
    yPosSlider:SetScript("OnValueChanged", function(self, value)
        currentXPos = -CustomMinimapArrowDB.facingXPos -- Get the current X position from CustomMinimapArrowDB
        facingFrame:SetPoint("TOP", UIParent, "TOP", currentXPos, -value)
        getglobal(self:GetName() .. 'Text'):SetText("Y Position: " .. math.floor(value))
        CustomMinimapArrowDB.facingYPos = value -- Save the new Y position to CustomMinimapArrowDB
    end)

    -- Show/Hide Dial and Needle Checkbox
    showDialCheckbox = CreateFrame("CheckButton", "CustomMinimapArrowShowDialCheckbox", panel, "UICheckButtonTemplate")
    showDialCheckbox:SetPoint("TOP", yPosSlider, "TOP", -100, -50)
    showDialCheckbox.text = showDialCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    showDialCheckbox.text:SetPoint("LEFT", showDialCheckbox, "RIGHT", 8, 0)
    showDialCheckbox.text:SetText("Show Dial and Needle")
    showDialCheckbox:SetChecked(CustomMinimapArrowDB.showDial)
    showDialCheckbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            CustomMinimapArrowDB.showDial = true
            dialFrame:Show()
            needleFrame:Show()
        else
            CustomMinimapArrowDB.showDial = false
            dialFrame:Hide()
            needleFrame:Hide()
        end
    end)

    -- Close button
    closeButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 22)
    closeButton:SetPoint("BOTTOMRIGHT", -15, 10)
    closeButton:SetText("Close")
    closeButton:SetScript("OnClick", function()
        panel:Hide()
    end)
end

-- Event handling
frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "CustomMinimapArrow" then
        LoadSavedArrow()
        CreateConfigPanel()
        if CustomMinimapArrowDB.showFacing then
            facingFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", CustomMinimapArrowDB.facingXPos, -CustomMinimapArrowDB.facingYPos)
            facingFrame:Show()
        else
            facingFrame:Hide()
        end
        if CustomMinimapArrowDB.showDial then
            dialFrame:Show()
            needleFrame:Show()
        else
            dialFrame:Hide()
            needleFrame:Hide()
        end
    end
end)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")