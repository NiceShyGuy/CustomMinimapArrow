-- Load saved variable
CustomMinimapArrowDB = CustomMinimapArrowDB or {}
CustomMinimapArrowDB.lastArrow = CustomMinimapArrowDB.lastArrow or "Teardrop Green"
CustomMinimapArrowDB.scaleFactor = CustomMinimapArrowDB.scaleFactor or 1
CustomMinimapArrowDB.facingScale = CustomMinimapArrowDB.facingScale or 1
CustomMinimapArrowDB.showFacing = CustomMinimapArrowDB.showFacing or false
CustomMinimapArrowDB.facingXPos = CustomMinimapArrowDB.facingXPos or -34
CustomMinimapArrowDB.facingYPos = CustomMinimapArrowDB.facingYPos or -31

-- Path to the arrow textures
ArrowDirectory = "Interface\\AddOns\\CustomMinimapArrow\\Arrows\\"

-- Slash command to open the configuration panel
SLASH_CUSTOMMINIMAPARROW1 = "/cma"
SlashCmdList["CUSTOMMINIMAPARROW"] = function(msg)
    ConfigPanel:Show()
end

-- Event handling
LoadedFrame = CreateFrame("Frame")
LoadedFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "CustomMinimapArrow" then
        ConfigPanel:Create()
        UpdateArrowTexture(ArrowDirectory .. CustomMinimapArrowDB.lastArrow)

        -- Set the position of FacingFrame based on saved data or default
        if CustomMinimapArrowDB.showFacing then
            local xPos = CustomMinimapArrowDB.facingXPos
            local yPos = CustomMinimapArrowDB.facingYPos
            FacingFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", xPos, yPos)
            FacingFrame:SetScale(CustomMinimapArrowDB.facingScale)
            FacingFrame:Show()
        else
            FacingFrame:Hide()
        end

        if CustomMinimapArrowDB.showDial then
            DialFrame:Show()
            NeedleFrame:Show()
        else
            DialFrame:Hide()
            NeedleFrame:Hide()
        end
    end
end)
LoadedFrame:RegisterEvent("ADDON_LOADED")
LoadedFrame:RegisterEvent("PLAYER_LOGIN")

-- Detect loading screen enabled
local loadingScreen = CreateFrame("Frame")
loadingScreen:RegisterEvent("LOADING_SCREEN_DISABLED")
loadingScreen:SetScript("OnEvent", function(self, event)
    UpdateArrowTexture(ArrowDirectory .. CustomMinimapArrowDB.lastArrow)
end)

-- Create a custom arrow frame
---@class CustomArrowFrame : Frame
CustomArrowFrame = CreateFrame("Frame", nil, Minimap)
CustomArrowFrame:SetSize(32, 32)
CustomArrowFrame:SetPoint("CENTER")
CustomArrowFrame:Hide()
CustomArrowFrame.texture = CustomArrowFrame:CreateTexture(nil, "OVERLAY")
CustomArrowFrame.texture:SetAllPoints(CustomArrowFrame)
CustomArrowFrame:SetScript("OnUpdate", function(self, elapsed)
    -- Update the arrow's facing direction
    local playerFacing = GetPlayerFacing()
    if playerFacing == nil then
        return
    end
    if playerFacing ~= self.facing then
        -- if minimap texture is not set to spacer, then set it to spacer
        self.texture:SetRotation(playerFacing)
        self.facing = playerFacing
    end
end)

-- Create a facing display frame
---@class FaceFrame : Frame
FacingFrame = CreateFrame("Frame", nil, UIParent)
FacingFrame:SetSize(100, 30)
FacingFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -20, -10)
FacingFrame:EnableMouse(true)
FacingFrame:SetMovable(true)
FacingFrame:RegisterForDrag("LeftButton")
FacingFrame:SetScript("OnDragStart", FacingFrame.StartMoving)
FacingFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local _, _, _, xPos, yPos = self:GetPoint()
    CustomMinimapArrowDB.facingXPos, CustomMinimapArrowDB.facingYPos = xPos, yPos
end)

FacingFrame.text = FacingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
FacingFrame.text:SetPoint("CENTER")
FacingFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
FacingFrame.text:SetTextColor(1, 1, 1)
FacingFrame.text:SetText("0.0")
FacingFrame.background = FacingFrame:CreateTexture(nil, "BACKGROUND")
FacingFrame.background:SetTexture("Interface\\AddOns\\CustomMinimapArrow\\UI\\Background")
FacingFrame.background:SetSize(45, 15)
FacingFrame.background:SetPoint("CENTER")
FacingFrame:SetScript("OnUpdate", function(self, elapsed)
    UpdateFacingText()
end)

-- Create a dial frame that will overlay on the inner portion of the minimap
---@class DialFrame : Frame
DialFrame = CreateFrame("Frame", nil, UIParent)
DialFrame:SetSize(128, 128)
DialFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
DialFrame.texture = DialFrame:CreateTexture(nil, "OVERLAY")
DialFrame.texture:SetTexture("Interface\\AddOns\\CustomMinimapArrow\\UI\\Dial")
DialFrame.texture:SetAllPoints(DialFrame)

-- Create a needle frame that will overlay on the inner portion of the minimap
---@class NeedleFrame : Frame
NeedleFrame = CreateFrame("Frame", nil, UIParent)
NeedleFrame:SetSize(128, 128)
NeedleFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
NeedleFrame.texture = NeedleFrame:CreateTexture(nil, "OVERLAY")
NeedleFrame.texture:SetTexture("Interface\\AddOns\\CustomMinimapArrow\\UI\\Needle")
NeedleFrame.texture:SetAllPoints(NeedleFrame)

-- Rotate the needle frame to match the player's facing direction
NeedleFrame:SetScript("OnUpdate", function(self, elapsed)
    local playerFacing = GetPlayerFacing()
    if playerFacing == nil then
        return
    end
    self.texture:SetRotation(playerFacing)
end)

-- Function to update the arrow texture
function UpdateArrowTexture(arrowTexturePath)
    -- Detect if in dungeon
    local inInstance, instanceType = IsInInstance()
    -- If in a dungeon, hide all frames
    if inInstance then
        CustomArrowFrame:Hide()
        FacingFrame:Hide()
        DialFrame:Hide()
        NeedleFrame:Hide()
        -- change the minimap arrow to the last saved arrow
        Minimap:SetPlayerTexture(arrowTexturePath)
        return
    else
        if type(CustomMinimapArrowDB.scaleFactor) == "number" then
            CustomArrowFrame.texture:SetTexture(arrowTexturePath)
            CustomArrowFrame:SetSize(32 * CustomMinimapArrowDB.scaleFactor, 32 * CustomMinimapArrowDB.scaleFactor)
            CustomArrowFrame:Show()
            -- Hide the default minimap arrow
            -- Minimap:SetPlayerTexture("[[Interface\\Common\\Spacer]]")
            Minimap:SetPlayerTexture(ArrowDirectory .. "Empty")
        else
            print("Error: scaleFactor is not set properly.")
            -- Handle the error case, e.g., set a default scaleFactor or log an error
        end

        -- Show the facing display if enabled
        if CustomMinimapArrowDB.showFacing then
            FacingFrame:Show()
        end

        -- Show the dial and needle if enabled
        if CustomMinimapArrowDB.showDial then
            DialFrame:Show()
            NeedleFrame:Show()
        end
    end
end

-- Update the facing text
function UpdateFacingText()
    local playerFacing = GetPlayerFacing()
    if playerFacing == nil then
        return
    end
    -- Convert radians to degrees and adjust to make it behave like a compass
    local facingDegrees = (1 - playerFacing / (2 * math.pi)) * 360
    -- Ensure the value is between 0 and 360
    facingDegrees = facingDegrees % 360
    FacingFrame.text:SetText(string.format("%.1f°", facingDegrees))
end

-- Configuration Panel
ConfigPanel = {}
function ConfigPanel:Create()
    -- Create the panel
    ---@class ConfigPanel : Frame
    self.Panel = CreateFrame("Frame", "CustomMinimapArrowConfigPanel", UIParent, "BasicFrameTemplateWithInset")
    self.Panel:SetSize(260, 320)
    self.Panel:SetPoint("CENTER")
    self.Panel:SetMovable(true)
    self.Panel:EnableMouse(true)
    self.Panel:RegisterForDrag("LeftButton")
    self.Panel:SetScript("OnDragStart", self.Panel.StartMoving)
    self.Panel:SetScript("OnDragStop", self.Panel.StopMovingOrSizing)
    self.Panel.TitleText:SetText("Custom Minimap Arrow")
    self.Panel:Hide()

    -- Check Values
    if CustomMinimapArrowDB.lastArrow == nil then
        CustomMinimapArrowDB.lastArrow = "Teardrop Green"
    end
    if CustomMinimapArrowDB.scaleFactor == nil then
        CustomMinimapArrowDB.scaleFactor = 1 -- Set a default value if it's nil
    end
    if CustomMinimapArrowDB.facingScale == nil then
        CustomMinimapArrowDB.facingScale = 1 -- Set a default value if it's nil
    end
    if CustomMinimapArrowDB.showFacing == nil then
        CustomMinimapArrowDB.showFacing = false -- Set a default value if it's nil
    end
    if CustomMinimapArrowDB.facingXPos == nil then
        CustomMinimapArrowDB.facingXPos = -34 -- Set a default value if it's nil
    end
    if CustomMinimapArrowDB.facingYPos == nil then
        CustomMinimapArrowDB.facingYPos = -31 -- Set a default value if it's nil
    end
    if CustomMinimapArrowDB.showDial == nil then
        CustomMinimapArrowDB.showDial = true -- Set a default value if it's nil
    end

    -- Scale factor slider
    ---@class ScaleSlider : Slider
    local ScaleSlider = CreateFrame("Slider", "CustomMinimapArrowScaleSlider", self.Panel, "OptionsSliderTemplate")
    ScaleSlider:SetMinMaxValues(0.5, 2)
    ScaleSlider:SetValueStep(0.1)
    ScaleSlider:SetPoint("TOP", self.Panel, "TOP", 0, -60)
    ScaleSlider:SetWidth(160)
    
    -- Initialize slider with saved scale factor
    ScaleSlider:SetValue(CustomMinimapArrowDB.scaleFactor)
    getglobal(ScaleSlider:GetName() .. 'Low'):SetText('0.5')
    getglobal(ScaleSlider:GetName() .. 'High'):SetText('2')
    getglobal(ScaleSlider:GetName() .. 'Text'):SetText('Scale Factor: ' .. string.format("%.2f", CustomMinimapArrowDB.scaleFactor) .. '\n\n')

    ScaleSlider:SetScript("OnValueChanged", function(self, value)
        CustomMinimapArrowDB.scaleFactor = value
        local formattedValue = string.format("%.2f", value)  -- Format to two decimal places
        getglobal(self:GetName() .. 'Text'):SetText('Scale Factor: ' .. formattedValue)
        UpdateArrowTexture(ArrowDirectory .. CustomMinimapArrowDB.lastArrow)
    end)

    -- Create a scale slider for FacingFrame
    ---@class FacingScaleSlider : Slider
    local FacingScaleSlider = CreateFrame("Slider", "CustomMinimapArrowFacingScaleSlider", self.Panel, "OptionsSliderTemplate")
    FacingScaleSlider:SetMinMaxValues(0.5, 2) -- Set min and max values for the scale
    FacingScaleSlider:SetValueStep(0.1)
    FacingScaleSlider:SetPoint("TOP", ScaleSlider, "BOTTOM", 0, -30)
    FacingScaleSlider:SetWidth(160)
    FacingScaleSlider:SetValue(CustomMinimapArrowDB.facingScale)
    getglobal(FacingScaleSlider:GetName() .. 'Low'):SetText('0.5')
    getglobal(FacingScaleSlider:GetName() .. 'High'):SetText('2')
    getglobal(FacingScaleSlider:GetName() .. 'Text'):SetText('Facing Scale: ' .. string.format("%.2f", CustomMinimapArrowDB.facingScale))

    FacingScaleSlider:SetScript("OnValueChanged", function(self, value)
        CustomMinimapArrowDB.facingScale = value
        FacingFrame:SetScale(value) -- Apply the scale to FacingFrame
        local formattedValue = string.format("%.2f", value)
        getglobal(self:GetName() .. 'Text'):SetText('Facing Scale: ' .. formattedValue)
    end)

    -- Reset FacingFrame position button
    ---@class ResetFacingButton : Button
    local ResetFacingButton = CreateFrame("Button", nil, self.Panel, "UIPanelButtonTemplate")
    ResetFacingButton:SetSize(100, 22)
    ResetFacingButton:SetPoint("TOP", FacingScaleSlider, "BOTTOM", 0, -20)
    ResetFacingButton:SetText("Reset Facing")
    ResetFacingButton:SetScript("OnClick", function()
        FacingFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -34, -31)
        CustomMinimapArrowDB.facingXPos, CustomMinimapArrowDB.facingYPos = -34, -31
        -- Reset the scale to 1
        FacingScaleSlider:SetValue(1)
        CustomMinimapArrowDB.facingScale = 1
    end)

    -- Arrow menu label
    ---@class ArrowLabel : FontString
    local ArrowLabel = self.Panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ArrowLabel:SetPoint("TOP", ResetFacingButton, "BOTTOM", -90, -20)
    ArrowLabel:SetText("Arrow:")
    -- Arrow Dropdown menu
    ---@class ArrowDropdown : Frame
    local ArrowDropdown = CreateFrame("Frame", "CustomMinimapArrowDropdown", self.Panel, "UIDropDownMenuTemplate")
    ArrowDropdown:SetPoint("LEFT", ArrowLabel, "RIGHT", 0, 0)

    function UpdateArrowDropdownText()
        -- Update the dropdown text to show the current selection
        UIDropDownMenu_SetText(ArrowDropdown, CustomMinimapArrowDB.lastArrow)
    end

    function OnClick(self)
        UIDropDownMenu_SetSelectedID(ArrowDropdown, self:GetID())
        CustomMinimapArrowDB.lastArrow = self.value
        UpdateArrowTexture(ArrowDirectory .. CustomMinimapArrowDB.lastArrow)
        UpdateArrowDropdownText()
    end

    function Initialize(self, level)
        local info = UIDropDownMenu_CreateInfo()
        local arrows = {
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

    UIDropDownMenu_Initialize(ArrowDropdown, Initialize)
    UIDropDownMenu_SetWidth(ArrowDropdown, 150)
    UIDropDownMenu_SetButtonWidth(ArrowDropdown, 124)
    UIDropDownMenu_JustifyText(ArrowDropdown, "LEFT")

    -- Update dropdown text when the panel is shown
    self.Panel:SetScript("OnShow", UpdateArrowDropdownText)

    -- Show/Hide Facing Display Checkbox
    ---@class ShowFacingCheckbox : CheckButton
    local ShowFacingCheckbox = CreateFrame("CheckButton", "CustomMinimapArrowShowFacingCheckbox", self.Panel, "UICheckButtonTemplate")
    ShowFacingCheckbox:SetPoint("TOP", ArrowDropdown, -100, -40)  -- Adjusted position
    ShowFacingCheckbox.text = ShowFacingCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ShowFacingCheckbox.text:SetPoint("LEFT", ShowFacingCheckbox, "RIGHT", 8, 0)
    ShowFacingCheckbox.text:SetText("Show Facing Display")
    ShowFacingCheckbox:SetChecked(CustomMinimapArrowDB.showFacing)
    ShowFacingCheckbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            CustomMinimapArrowDB.showFacing = true
            FacingFrame:Show()
        else
            CustomMinimapArrowDB.showFacing = false
            FacingFrame:Hide()
        end
    end)

    -- Show/Hide Dial and Needle Checkbox
    ---@class ShowDialCheckbox : CheckButton
    local ShowDialCheckbox = CreateFrame("CheckButton", "CustomMinimapArrowShowDialCheckbox", self.Panel, "UICheckButtonTemplate")
    ShowDialCheckbox:SetPoint("TOP", ShowFacingCheckbox, "TOP", 0, -30)
    ShowDialCheckbox.text = ShowDialCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ShowDialCheckbox.text:SetPoint("LEFT", ShowDialCheckbox, "RIGHT", 8, 0)
    ShowDialCheckbox.text:SetText("Show Dial and Needle")
    ShowDialCheckbox:SetChecked(CustomMinimapArrowDB.showDial)
    ShowDialCheckbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            CustomMinimapArrowDB.showDial = true
            DialFrame:Show()
            NeedleFrame:Show()
        else
            CustomMinimapArrowDB.showDial = false
            DialFrame:Hide()
            NeedleFrame:Hide()
        end
    end)

    -- Close button
    ---@class CloseButton : Button
    local CloseButton = CreateFrame("Button", nil, self.Panel, "UIPanelButtonTemplate")
    CloseButton:SetSize(80, 22)
    CloseButton:SetPoint("BOTTOMRIGHT", -15, 10)
    CloseButton:SetText("Close")
    CloseButton:SetScript("OnClick", function()
        self.Panel:Hide()
    end)
end

function ConfigPanel:Show()
    if not self.Panel then
        self:Create()
    end
    self.Panel:Show()
end