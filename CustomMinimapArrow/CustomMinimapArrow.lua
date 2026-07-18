-- Load saved variable
CustomMinimapArrowDB = CustomMinimapArrowDB or {}
CustomMinimapArrowDB.lastArrow = CustomMinimapArrowDB.lastArrow or "Teardrop Green"
CustomMinimapArrowDB.scaleFactor = CustomMinimapArrowDB.scaleFactor or 1
CustomMinimapArrowDB.facingScale = CustomMinimapArrowDB.facingScale or 1
CustomMinimapArrowDB.showFacing = CustomMinimapArrowDB.showFacing or false
CustomMinimapArrowDB.facingXPos = CustomMinimapArrowDB.facingXPos or -34
CustomMinimapArrowDB.facingYPos = CustomMinimapArrowDB.facingYPos or -31
if CustomMinimapArrowDB.showDial == nil then CustomMinimapArrowDB.showDial = true end
if CustomMinimapArrowDB.showNeedle == nil then CustomMinimapArrowDB.showNeedle = true end
CustomMinimapArrowDB.dialLength = CustomMinimapArrowDB.dialLength or 9
CustomMinimapArrowDB.dialThickness = CustomMinimapArrowDB.dialThickness or 1
CustomMinimapArrowDB.dialColor = CustomMinimapArrowDB.dialColor or {0, 0, 0, 1}
CustomMinimapArrowDB.needleLength = CustomMinimapArrowDB.needleLength or 9
CustomMinimapArrowDB.needleThickness = CustomMinimapArrowDB.needleThickness or 1
CustomMinimapArrowDB.needleColor = CustomMinimapArrowDB.needleColor or {0, 1, 0, 1}
if CustomMinimapArrowDB.showWorldMap == nil then CustomMinimapArrowDB.showWorldMap = false end

-- Migration of old defaults to new defaults
if CustomMinimapArrowDB.dialLength == 8 then CustomMinimapArrowDB.dialLength = 9 end
if CustomMinimapArrowDB.dialThickness == 1.5 then CustomMinimapArrowDB.dialThickness = 1 end
if CustomMinimapArrowDB.dialColor and CustomMinimapArrowDB.dialColor[1] == 1 and CustomMinimapArrowDB.dialColor[2] == 1 and CustomMinimapArrowDB.dialColor[3] == 1 then
    CustomMinimapArrowDB.dialColor = {0, 0, 0, 1}
end
if CustomMinimapArrowDB.needleLength == 45 then CustomMinimapArrowDB.needleLength = 9 end
if CustomMinimapArrowDB.needleThickness == 2 then CustomMinimapArrowDB.needleThickness = 1 end
if CustomMinimapArrowDB.needleColor and CustomMinimapArrowDB.needleColor[1] == 1 and CustomMinimapArrowDB.needleColor[2] == 0 and CustomMinimapArrowDB.needleColor[3] == 0 then
    CustomMinimapArrowDB.needleColor = {0, 1, 0, 1}
end

-- Path to the arrow textures
ArrowDirectory = "Interface\\AddOns\\CustomMinimapArrow\\Arrows\\"

-- Slash command to open the configuration panel
SLASH_CUSTOMMINIMAPARROW1 = "/cma"
SlashCmdList["CUSTOMMINIMAPARROW"] = function(msg)
    ConfigPanel:Show()
end

-- Event handling
LoadedFrame = CreateFrame("Frame")
LoadedFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "CustomMinimapArrow" then
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

            -- Show/hide world map arrow
            if CustomMinimapArrowDB.showWorldMap then
                WorldMapArrowFrame:Show()
            else
                WorldMapArrowFrame:Hide()
            end
        end
    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        UpdateArrowTexture(ArrowDirectory .. CustomMinimapArrowDB.lastArrow)
    elseif event == "CVAR_UPDATE" then
        local cvarName, cvarValue = ...
        if cvarName == "rotateMinimap" or cvarName == "ROTATE_MINIMAP" then
            UpdateArrowTexture(ArrowDirectory .. CustomMinimapArrowDB.lastArrow)
        end
    end
end)
LoadedFrame:RegisterEvent("ADDON_LOADED")
LoadedFrame:RegisterEvent("PLAYER_LOGIN")
LoadedFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
LoadedFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
LoadedFrame:RegisterEvent("CVAR_UPDATE")

-- Detect loading screen enabled
local loadingScreen = CreateFrame("Frame")
loadingScreen:RegisterEvent("LOADING_SCREEN_DISABLED")
loadingScreen:SetScript("OnEvent", function(self, event)
    UpdateArrowTexture(ArrowDirectory .. CustomMinimapArrowDB.lastArrow)
end)

-- Create a world map arrow frame
---@class WorldMapArrowFrame : Frame
WorldMapArrowFrame = CreateFrame("Frame", "CustomMinimapArrowWorldMapFrame", UIParent)
WorldMapArrowFrame:SetSize(32, 32)
WorldMapArrowFrame:SetFrameStrata("TOOLTIP")
WorldMapArrowFrame:SetFrameLevel(9999)
WorldMapArrowFrame:EnableMouse(false)
WorldMapArrowFrame:Hide()
WorldMapArrowFrame.texture = WorldMapArrowFrame:CreateTexture(nil, "OVERLAY", nil, 7)
WorldMapArrowFrame.texture:SetAllPoints(WorldMapArrowFrame)

-- Helper: hide the default Blizzard player arrow pin on the world map
local function HideDefaultPlayerArrow()
    if not WorldMapFrame or not WorldMapFrame.dataProviders then return end
    for provider in pairs(WorldMapFrame.dataProviders) do
        if type(provider) == "table" and provider.ShouldShowUnit then
            if provider:ShouldShowUnit("player") and provider.pin then
                provider.pin:SetAlpha(0)
            end
        end
    end
end

-- Helper: restore the default Blizzard player arrow pin
local function ShowDefaultPlayerArrow()
    if not WorldMapFrame or not WorldMapFrame.dataProviders then return end
    for provider in pairs(WorldMapFrame.dataProviders) do
        if type(provider) == "table" and provider.ShouldShowUnit then
            if provider:ShouldShowUnit("player") and provider.pin then
                provider.pin:SetAlpha(1)
            end
        end
    end
end

WorldMapArrowFrame:SetScript("OnUpdate", function(self, elapsed)
    if not self:IsVisible() then return end
    if not WorldMapFrame or not WorldMapFrame:IsVisible() then
        self:Hide()
        return
    end

    -- Safeguard for older clients or versions without C_Map API
    if not C_Map or not C_Map.GetBestMapForUnit or not C_Map.GetPlayerMapPosition then
        self.texture:Hide()
        ShowDefaultPlayerArrow()
        return
    end

    -- Get mapID of the currently viewed map area
    local mapID = WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
    local pos = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
    local px, py = nil, nil
    if pos then
        if pos.GetXY then
            px, py = pos:GetXY()
        elseif pos.x and pos.y then
            px, py = pos.x, pos.y
        end
    end

    if not px or (px == 0 and py == 0) then
        -- In a dungeon, or viewing a map area the player is not currently on
        self.texture:Hide()
        ShowDefaultPlayerArrow()
        return
    end

    -- Convert normalized map coords to screen coords via ScrollContainer.Child
    local scrollChild = WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child
    if not scrollChild or not scrollChild:IsVisible() then
        self.texture:Hide()
        ShowDefaultPlayerArrow()
        return
    end

    local mapWidth  = scrollChild:GetWidth()
    local mapHeight = scrollChild:GetHeight()
    local scale = scrollChild:GetEffectiveScale()
    local left, top = scrollChild:GetLeft(), scrollChild:GetTop()
    if not left or not top or not mapWidth or not mapHeight or not scale then
        self.texture:Hide()
        ShowDefaultPlayerArrow()
        return
    end

    -- Hide the default Blizzard player arrow
    HideDefaultPlayerArrow()

    -- Compute screen-space position
    local myScale = UIParent:GetEffectiveScale()
    local screenX = (left + px * mapWidth) * scale / (myScale or 1)
    local screenY = (top - py * mapHeight) * scale / (myScale or 1)

    -- Update size based on arrow scale setting
    local sz = 32 * (CustomMinimapArrowDB.scaleFactor or 1)
    self:SetSize(sz, sz)

    -- Position on screen
    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", screenX, screenY)

    -- Rotate to match player facing
    local facing = GetPlayerFacing()
    if facing then
        self.texture:SetRotation(facing)
    end

    -- Keep texture in sync with selected arrow
    self.texture:SetTexture(ArrowDirectory .. CustomMinimapArrowDB.lastArrow)
    self.texture:Show()
end)

WorldMapArrowFrame:SetScript("OnHide", function(self)
    ShowDefaultPlayerArrow()
end)

-- Hook WorldMapFrame show/hide to automatically manage our arrow
if WorldMapFrame then
    WorldMapFrame:HookScript("OnShow", function()
        if CustomMinimapArrowDB.showWorldMap then
            WorldMapArrowFrame:Show()
        end
    end)
    WorldMapFrame:HookScript("OnHide", function()
        WorldMapArrowFrame:Hide()
    end)
end

-- Create a custom arrow frame
---@class CustomArrowFrame : Frame
CustomArrowFrame = CreateFrame("Frame", nil, Minimap)
CustomArrowFrame:SetSize(32, 32)
CustomArrowFrame:SetPoint("CENTER")
CustomArrowFrame:Hide()
CustomArrowFrame:SetFrameStrata("TOOLTIP")
CustomArrowFrame:SetFrameLevel(1000)
CustomArrowFrame.texture = CustomArrowFrame:CreateTexture(nil, "OVERLAY", nil, 7)
CustomArrowFrame.texture:SetAllPoints(CustomArrowFrame)
CustomArrowFrame:SetScript("OnUpdate", function(self, elapsed)
    local inInstance = IsInInstance()
    local isRotating = GetCVar("rotateMinimap") == "1"

    if inInstance and isRotating then
        -- In a dungeon with rotating minimap, the player arrow always points straight up (rotation 0)
        if self.facing ~= 0 then
            self.texture:SetRotation(0)
            self.facing = 0
        end
        return
    end

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
DialFrame = CreateFrame("Frame", nil, Minimap)
DialFrame:SetSize(128, 128)
DialFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
DialFrame:SetFrameStrata("TOOLTIP")
DialFrame:SetFrameLevel(900)

-- Create a needle frame that will overlay on the inner portion of the minimap
---@class NeedleFrame : Frame
NeedleFrame = CreateFrame("Frame", nil, Minimap)
NeedleFrame:SetSize(128, 128)
NeedleFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
NeedleFrame:SetFrameStrata("TOOLTIP")
NeedleFrame:SetFrameLevel(910)

-- Helper function to open the Color Picker
function OpenColorPicker(r, g, b, callback)
    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r,
            g = g,
            b = b,
            hasOpacity = false,
            swatchFunc = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                callback(nr, ng, nb)
            end,
            cancelFunc = function(previousValues)
                if previousValues then
                    callback(previousValues.r, previousValues.g, previousValues.b)
                else
                    callback(r, g, b)
                end
            end
        })
    else
        ColorPickerFrame.func = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            callback(nr, ng, nb)
        end
        ColorPickerFrame.cancelFunc = function()
            callback(r, g, b)
        end
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame:Show()
    end
end

-- Programmatic Dial Drawing
function RedrawDial()
    DialFrame.ticks = DialFrame.ticks or {}
    for _, line in ipairs(DialFrame.ticks) do
        line:Hide()
    end

    local radius = 56
    local color = CustomMinimapArrowDB.dialColor or {1, 1, 1, 1}
    local thickness = CustomMinimapArrowDB.dialThickness or 1.5
    local length = CustomMinimapArrowDB.dialLength or 8

    local idx = 1
    for i = 1, 36 do
        local angle = (i - 1) * (2 * math.pi / 36)
        local isMajor = (i - 1) % 3 == 0
        
        local currentLength = isMajor and length or (length * 0.6)
        local currentThickness = isMajor and thickness or (thickness * 0.7)
        
        local line = DialFrame.ticks[idx]
        if not line then
            line = DialFrame:CreateLine()
            DialFrame.ticks[idx] = line
        end
        
        local startX = (radius - currentLength) * math.cos(angle)
        local startY = (radius - currentLength) * math.sin(angle)
        local endX = radius * math.cos(angle)
        local endY = radius * math.sin(angle)
        
        line:SetStartPoint("CENTER", DialFrame, startX, startY)
        line:SetEndPoint("CENTER", DialFrame, endX, endY)
        line:SetThickness(currentThickness)
        line:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
        line:Show()
        
        idx = idx + 1
    end
end

-- Programmatic Needle Drawing
function RedrawNeedle()
    NeedleFrame.lines = NeedleFrame.lines or {}
    for _, line in ipairs(NeedleFrame.lines) do
        line:Hide()
    end

    local thickness = CustomMinimapArrowDB.needleThickness or 1
    local color = CustomMinimapArrowDB.needleColor or {1, 0, 0, 1}

    -- We only need 1 line now (representing the dial tick style needle)
    local line = NeedleFrame.lines[1]
    if not line then
        line = NeedleFrame:CreateLine()
        NeedleFrame.lines[1] = line
    end
    line:SetThickness(thickness)
    line:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
    line:Show()
end

-- Rotate and scale the needle lines programmatically on update
NeedleFrame:SetScript("OnUpdate", function(self, elapsed)
    local playerFacing = GetPlayerFacing()
    if playerFacing == nil then
        return
    end

    local angle = math.pi/2 + playerFacing
    local length = CustomMinimapArrowDB.needleLength or 9
    local radius = 56

    local startX = (radius - length) * math.cos(angle)
    local startY = (radius - length) * math.sin(angle)
    local endX = radius * math.cos(angle)
    local endY = radius * math.sin(angle)

    local line = self.lines and self.lines[1]
    if line then
        line:SetStartPoint("CENTER", self, startX, startY)
        line:SetEndPoint("CENTER", self, endX, endY)
    end
end)

-- Function to update the arrow texture
function UpdateArrowTexture(arrowTexturePath)
    -- Detect if in dungeon and if rotating minimap is enabled
    local inInstance, instanceType = IsInInstance()
    local isRotating = GetCVar("rotateMinimap") == "1"

    -- If in a dungeon and NOT rotating minimap, we must use fallback (cannot get player facing)
    if inInstance and not isRotating then
        CustomArrowFrame:Hide()
        FacingFrame:Hide()
        DialFrame:Hide()
        NeedleFrame:Hide()
        -- change the minimap arrow to the last saved arrow
        Minimap:SetPlayerTexture(arrowTexturePath)
        return
    end

    -- Otherwise, we can use the custom overlay frame!
    if type(CustomMinimapArrowDB.scaleFactor) == "number" then
        CustomArrowFrame.texture:SetTexture(arrowTexturePath)
        CustomArrowFrame:SetSize(32 * CustomMinimapArrowDB.scaleFactor, 32 * CustomMinimapArrowDB.scaleFactor)
        CustomArrowFrame:Show()
        -- Hide the default minimap arrow
        Minimap:SetPlayerTexture(ArrowDirectory .. "Empty")
    else
        print("Error: scaleFactor is not set properly.")
    end

    if inInstance then
        -- In instance, facing/dial/needle won't work correctly or might be restricted, hide them
        FacingFrame:Hide()
        DialFrame:Hide()
        NeedleFrame:Hide()
    else
        -- Show the facing display if enabled
        if CustomMinimapArrowDB.showFacing then
            FacingFrame:Show()
        else
            FacingFrame:Hide()
        end

        -- Show/hide the dial if enabled
        if CustomMinimapArrowDB.showDial then
            DialFrame:Show()
            RedrawDial()
        else
            DialFrame:Hide()
        end

        -- Show/hide the needle if enabled
        if CustomMinimapArrowDB.showNeedle then
            NeedleFrame:Show()
            RedrawNeedle()
        else
            NeedleFrame:Hide()
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
    self.Panel:SetSize(432, 386)
    self.Panel:SetPoint("CENTER")
    self.Panel:SetMovable(true)
    self.Panel:EnableMouse(true)
    self.Panel:RegisterForDrag("LeftButton")
    self.Panel:SetScript("OnDragStart", self.Panel.StartMoving)
    self.Panel:SetScript("OnDragStop", self.Panel.StopMovingOrSizing)
    self.Panel.TitleText:SetText("Custom Minimap Arrow")
    self.Panel:Hide()

    -- Check and initialize missing database variables
    if CustomMinimapArrowDB.lastArrow == nil then CustomMinimapArrowDB.lastArrow = "Teardrop Green" end
    if CustomMinimapArrowDB.scaleFactor == nil then CustomMinimapArrowDB.scaleFactor = 1 end
    if CustomMinimapArrowDB.facingScale == nil then CustomMinimapArrowDB.facingScale = 1 end
    if CustomMinimapArrowDB.showFacing == nil then CustomMinimapArrowDB.showFacing = false end
    if CustomMinimapArrowDB.facingXPos == nil then CustomMinimapArrowDB.facingXPos = -34 end
    if CustomMinimapArrowDB.facingYPos == nil then CustomMinimapArrowDB.facingYPos = -31 end
    if CustomMinimapArrowDB.showDial == nil then CustomMinimapArrowDB.showDial = true end
    if CustomMinimapArrowDB.showNeedle == nil then CustomMinimapArrowDB.showNeedle = true end
    if CustomMinimapArrowDB.dialLength == nil then CustomMinimapArrowDB.dialLength = 9 end
    if CustomMinimapArrowDB.dialThickness == nil then CustomMinimapArrowDB.dialThickness = 1 end
    if CustomMinimapArrowDB.dialColor == nil then CustomMinimapArrowDB.dialColor = {0, 0, 0, 1} end
    if CustomMinimapArrowDB.needleLength == nil then CustomMinimapArrowDB.needleLength = 9 end
    if CustomMinimapArrowDB.needleThickness == nil then CustomMinimapArrowDB.needleThickness = 1 end
    if CustomMinimapArrowDB.needleColor == nil then CustomMinimapArrowDB.needleColor = {0, 1, 0, 1} end
    if CustomMinimapArrowDB.showWorldMap == nil then CustomMinimapArrowDB.showWorldMap = false end

    -- Helper to create sliders
    local function CreateSliderHelper(name, title, minVal, maxVal, stepVal, value, onValueChanged)
        local slider = CreateFrame("Slider", name, self.Panel, "OptionsSliderTemplate")
        slider:SetMinMaxValues(minVal, maxVal)
        slider:SetValueStep(stepVal)
        slider:SetValue(value)
        slider:SetWidth(180)
        
        local nameStr = slider:GetName()
        _G[nameStr .. "Low"]:SetText(string.format("%.1f", minVal))
        _G[nameStr .. "High"]:SetText(string.format("%.1f", maxVal))
        _G[nameStr .. "Text"]:SetText(title .. ": " .. string.format("%.2f", value))
        
        slider:SetScript("OnValueChanged", function(self, val)
            local roundedVal = math.floor(val / stepVal + 0.5) * stepVal
            _G[nameStr .. "Text"]:SetText(title .. ": " .. string.format("%.2f", roundedVal))
            onValueChanged(roundedVal)
        end)
        
        return slider
    end

    -- ROW 1: Arrow Style (Left) and Show Facing Display (Right)

    -- Left Column: Select Arrow Style Label & Dropdown
    local ArrowLabel = self.Panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ArrowLabel:SetPoint("LEFT", self.Panel, "TOPLEFT", 24, -52)
    ArrowLabel:SetText("Select Arrow Style:")

    local ArrowDropdown = CreateFrame("Frame", "CustomMinimapArrowDropdown", self.Panel, "UIDropDownMenuTemplate")
    ArrowDropdown:SetPoint("LEFT", self.Panel, "TOPLEFT", 9, -96)

    local function UpdateArrowDropdownText()
        UIDropDownMenu_SetText(ArrowDropdown, CustomMinimapArrowDB.lastArrow)
    end

    local function OnDropdownClick(self)
        UIDropDownMenu_SetSelectedID(ArrowDropdown, self:GetID())
        CustomMinimapArrowDB.lastArrow = self.value
        UpdateArrowTexture(ArrowDirectory .. CustomMinimapArrowDB.lastArrow)
        UpdateArrowDropdownText()
    end

    local function DropdownInitialize(self, level)
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
            info.func = OnDropdownClick
            info.checked = (CustomMinimapArrowDB.lastArrow == value)
            
            -- Add tiny preview of the arrow texture and rotate it 30 degrees
            info.icon = ArrowDirectory .. value
            info.tSizeX = 14
            info.tSizeY = 14
            
            UIDropDownMenu_AddButton(info, level)

            -- Rotate the icon texture inside the dropdown menu button by 30 degrees
            local listFrame = _G["DropDownList"..(level or 1)]
            if listFrame then
                local index = listFrame.numButtons
                local iconTex = _G["DropDownList"..(level or 1).."Button"..index.."Icon"]
                if iconTex then
                    iconTex:SetRotation(math.rad(30))
                end
            end
        end
    end

    UIDropDownMenu_Initialize(ArrowDropdown, DropdownInitialize)
    UIDropDownMenu_SetWidth(ArrowDropdown, 165)
    UIDropDownMenu_SetButtonWidth(ArrowDropdown, 145)
    UIDropDownMenu_JustifyText(ArrowDropdown, "LEFT")
    self.Panel:SetScript("OnShow", UpdateArrowDropdownText)

    -- Right Column: Show on World Map Checkbox
    local ShowWorldMapCheckbox = CreateFrame("CheckButton", "CustomMinimapArrowShowWorldMapCheckbox", self.Panel, "UICheckButtonTemplate")
    ShowWorldMapCheckbox:SetPoint("LEFT", self.Panel, "TOPLEFT", 228, -52)
    ShowWorldMapCheckbox.text = ShowWorldMapCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ShowWorldMapCheckbox.text:SetPoint("LEFT", ShowWorldMapCheckbox, "RIGHT", 8, 0)
    ShowWorldMapCheckbox.text:SetText("Show on World Map")
    ShowWorldMapCheckbox:SetChecked(CustomMinimapArrowDB.showWorldMap)
    ShowWorldMapCheckbox:SetScript("OnClick", function(self)
        CustomMinimapArrowDB.showWorldMap = self:GetChecked()
        if CustomMinimapArrowDB.showWorldMap then
            WorldMapArrowFrame:Show()
        else
            WorldMapArrowFrame:Hide()
        end
    end)

    -- Right Column: Show Facing Display Checkbox (below Show on World Map, aligned vertically with the dropdown menu)
    local ShowFacingCheckbox = CreateFrame("CheckButton", "CustomMinimapArrowShowFacingCheckbox", self.Panel, "UICheckButtonTemplate")
    ShowFacingCheckbox:SetPoint("LEFT", self.Panel, "TOPLEFT", 228, -96)
    ShowFacingCheckbox.text = ShowFacingCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ShowFacingCheckbox.text:SetPoint("LEFT", ShowFacingCheckbox, "RIGHT", 8, 0)
    ShowFacingCheckbox.text:SetText("Show Facing Display")
    ShowFacingCheckbox:SetChecked(CustomMinimapArrowDB.showFacing)
    ShowFacingCheckbox:SetScript("OnClick", function(self)
        CustomMinimapArrowDB.showFacing = self:GetChecked()
        if CustomMinimapArrowDB.showFacing then
            FacingFrame:Show()
        else
            FacingFrame:Hide()
        end
    end)


    -- ROW 2: Arrow Scale (Left) and Facing Text Scale (Right)

    -- Left Column: Arrow Scale Slider
    local ScaleSlider = CreateSliderHelper("CustomMinimapArrowScaleSlider", "Arrow Scale", 0.5, 2.0, 0.1, CustomMinimapArrowDB.scaleFactor, function(val)
        CustomMinimapArrowDB.scaleFactor = val
        UpdateArrowTexture(ArrowDirectory .. CustomMinimapArrowDB.lastArrow)
    end)
    ScaleSlider:SetPoint("TOPLEFT", self.Panel, "TOPLEFT", 24, -142)

    -- Right Column: Facing Text Scale Slider
    local FacingScaleSlider = CreateSliderHelper("CustomMinimapArrowFacingScaleSlider", "Facing Text Scale", 0.5, 2.0, 0.1, CustomMinimapArrowDB.facingScale, function(val)
        CustomMinimapArrowDB.facingScale = val
        FacingFrame:SetScale(val)
    end)
    FacingScaleSlider:SetPoint("TOPLEFT", self.Panel, "TOPLEFT", 228, -142)


    -- ROW 3: Show Dial Checkbox (Left) and Show Needle Checkbox (Right)

    -- Left Column: Show Dial Checkbox
    local ShowDialCheckbox = CreateFrame("CheckButton", "CustomMinimapArrowShowDialCheckbox", self.Panel, "UICheckButtonTemplate")
    ShowDialCheckbox:SetPoint("TOPLEFT", self.Panel, "TOPLEFT", 24, -175)
    ShowDialCheckbox.text = ShowDialCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ShowDialCheckbox.text:SetPoint("LEFT", ShowDialCheckbox, "RIGHT", 8, 0)
    ShowDialCheckbox.text:SetText("Show Dial")
    ShowDialCheckbox:SetChecked(CustomMinimapArrowDB.showDial)
    ShowDialCheckbox:SetScript("OnClick", function(self)
        CustomMinimapArrowDB.showDial = self:GetChecked()
        if CustomMinimapArrowDB.showDial then
            DialFrame:Show()
            RedrawDial()
        else
            DialFrame:Hide()
        end
    end)

    -- Right Column: Show Needle Checkbox
    local ShowNeedleCheckbox = CreateFrame("CheckButton", "CustomMinimapArrowShowNeedleCheckbox", self.Panel, "UICheckButtonTemplate")
    ShowNeedleCheckbox:SetPoint("TOPLEFT", self.Panel, "TOPLEFT", 228, -175)
    ShowNeedleCheckbox.text = ShowNeedleCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ShowNeedleCheckbox.text:SetPoint("LEFT", ShowNeedleCheckbox, "RIGHT", 8, 0)
    ShowNeedleCheckbox.text:SetText("Show Needle")
    ShowNeedleCheckbox:SetChecked(CustomMinimapArrowDB.showNeedle)
    ShowNeedleCheckbox:SetScript("OnClick", function(self)
        CustomMinimapArrowDB.showNeedle = self:GetChecked()
        if CustomMinimapArrowDB.showNeedle then
            NeedleFrame:Show()
            RedrawNeedle()
        else
            NeedleFrame:Hide()
        end
    end)


    -- ROW 4: Dial Tick Length (Left) and Needle Length (Right)

    -- Left Column: Dial Tick Length Slider
    local DialLengthSlider = CreateSliderHelper("CustomMinimapArrowDialLengthSlider", "Dial Tick Length", 2, 20, 0.5, CustomMinimapArrowDB.dialLength, function(val)
        CustomMinimapArrowDB.dialLength = val
        if CustomMinimapArrowDB.showDial then RedrawDial() end
    end)
    DialLengthSlider:SetPoint("TOPLEFT", self.Panel, "TOPLEFT", 24, -231)

    -- Right Column: Needle Length Slider
    local NeedleLengthSlider = CreateSliderHelper("CustomMinimapArrowNeedleLengthSlider", "Needle Length", 2, 20, 0.5, CustomMinimapArrowDB.needleLength, function(val)
        CustomMinimapArrowDB.needleLength = val
        if CustomMinimapArrowDB.showNeedle then RedrawNeedle() end
    end)
    NeedleLengthSlider:SetPoint("TOPLEFT", self.Panel, "TOPLEFT", 228, -231)


    -- ROW 5: Dial Thickness (Left) and Needle Thickness (Right)

    -- Left Column: Dial Thickness Slider
    local DialThicknessSlider = CreateSliderHelper("CustomMinimapArrowDialThicknessSlider", "Dial Thickness", 0.5, 5.0, 0.1, CustomMinimapArrowDB.dialThickness, function(val)
        CustomMinimapArrowDB.dialThickness = val
        if CustomMinimapArrowDB.showDial then RedrawDial() end
    end)
    DialThicknessSlider:SetPoint("TOPLEFT", self.Panel, "TOPLEFT", 24, -279)

    -- Right Column: Needle Thickness Slider
    local NeedleThicknessSlider = CreateSliderHelper("CustomMinimapArrowNeedleThicknessSlider", "Needle Thickness", 0.5, 5.0, 0.1, CustomMinimapArrowDB.needleThickness, function(val)
        CustomMinimapArrowDB.needleThickness = val
        if CustomMinimapArrowDB.showNeedle then RedrawNeedle() end
    end)
    NeedleThicknessSlider:SetPoint("TOPLEFT", self.Panel, "TOPLEFT", 228, -279)


    -- ROW 6: Dial Color (Left) and Needle Color (Right)

    -- Left Column: Dial Color
    local DialColorBorder = CreateFrame("Frame", nil, self.Panel)
    DialColorBorder:SetSize(22, 22)
    DialColorBorder:SetPoint("TOPLEFT", self.Panel, "TOPLEFT", 24, -312)
    local dialBorderTex = DialColorBorder:CreateTexture(nil, "BACKGROUND")
    dialBorderTex:SetAllPoints()
    dialBorderTex:SetColorTexture(0.6, 0.6, 0.6, 1)

    local DialColorLabel = self.Panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    DialColorLabel:SetPoint("LEFT", DialColorBorder, "RIGHT", 10, 0)
    DialColorLabel:SetText("Dial Color")

    local DialColorButton = CreateFrame("Button", nil, DialColorBorder)
    DialColorButton:SetSize(18, 18)
    DialColorButton:SetPoint("CENTER", DialColorBorder, "CENTER", 0, 0)
    DialColorButton:SetNormalTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
    local dialSwatch = DialColorButton:GetNormalTexture()
    dialSwatch:SetVertexColor(unpack(CustomMinimapArrowDB.dialColor))

    DialColorButton:SetScript("OnClick", function()
        local color = CustomMinimapArrowDB.dialColor
        OpenColorPicker(color[1], color[2], color[3], function(r, g, b)
            CustomMinimapArrowDB.dialColor = {r, g, b, 1}
            dialSwatch:SetVertexColor(r, g, b)
            if CustomMinimapArrowDB.showDial then RedrawDial() end
        end)
    end)

    -- Right Column: Needle Color
    local NeedleColorBorder = CreateFrame("Frame", nil, self.Panel)
    NeedleColorBorder:SetSize(22, 22)
    NeedleColorBorder:SetPoint("TOPLEFT", self.Panel, "TOPLEFT", 228, -312)
    local needleBorderTex = NeedleColorBorder:CreateTexture(nil, "BACKGROUND")
    needleBorderTex:SetAllPoints()
    needleBorderTex:SetColorTexture(0.6, 0.6, 0.6, 1)

    local NeedleColorLabel = self.Panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    NeedleColorLabel:SetPoint("LEFT", NeedleColorBorder, "RIGHT", 10, 0)
    NeedleColorLabel:SetText("Needle Color")

    local NeedleColorButton = CreateFrame("Button", nil, NeedleColorBorder)
    NeedleColorButton:SetSize(18, 18)
    NeedleColorButton:SetPoint("CENTER", NeedleColorBorder, "CENTER", 0, 0)
    NeedleColorButton:SetNormalTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
    local needleSwatch = NeedleColorButton:GetNormalTexture()
    needleSwatch:SetVertexColor(unpack(CustomMinimapArrowDB.needleColor))

    NeedleColorButton:SetScript("OnClick", function()
        local color = CustomMinimapArrowDB.needleColor
        OpenColorPicker(color[1], color[2], color[3], function(r, g, b)
            CustomMinimapArrowDB.needleColor = {r, g, b, 1}
            needleSwatch:SetVertexColor(r, g, b)
            if CustomMinimapArrowDB.showNeedle then RedrawNeedle() end
        end)
    end)


    -- RESET AND CLOSE BUTTONS

    -- Global Reset Button next to ArrowLabel
    local ResetButton = CreateFrame("Button", nil, self.Panel, "UIPanelButtonTemplate")
    ResetButton:SetSize(60, 18)
    ResetButton:SetPoint("LEFT", ArrowLabel, "RIGHT", 10, 0)
    ResetButton:SetText("Reset")
    ResetButton:SetScript("OnClick", function()
        CustomMinimapArrowDB.lastArrow = "Teardrop Green"
        CustomMinimapArrowDB.scaleFactor = 1
        CustomMinimapArrowDB.facingScale = 1
        CustomMinimapArrowDB.showFacing = false
        CustomMinimapArrowDB.facingXPos = -34
        CustomMinimapArrowDB.facingYPos = -31
        CustomMinimapArrowDB.showDial = true
        CustomMinimapArrowDB.showNeedle = true
        CustomMinimapArrowDB.dialLength = 9
        CustomMinimapArrowDB.dialThickness = 1
        CustomMinimapArrowDB.dialColor = {0, 0, 0, 1}
        CustomMinimapArrowDB.needleLength = 9
        CustomMinimapArrowDB.needleThickness = 1
        CustomMinimapArrowDB.needleColor = {0, 1, 0, 1}
        CustomMinimapArrowDB.showWorldMap = false

        -- Reset Sliders
        CustomMinimapArrowScaleSlider:SetValue(1)
        CustomMinimapArrowFacingScaleSlider:SetValue(1)
        CustomMinimapArrowDialLengthSlider:SetValue(9)
        CustomMinimapArrowDialThicknessSlider:SetValue(1)
        CustomMinimapArrowNeedleLengthSlider:SetValue(9)
        CustomMinimapArrowNeedleThicknessSlider:SetValue(1)

        -- Reset Checkboxes
        CustomMinimapArrowShowFacingCheckbox:SetChecked(false)
        CustomMinimapArrowShowDialCheckbox:SetChecked(true)
        CustomMinimapArrowShowNeedleCheckbox:SetChecked(true)
        CustomMinimapArrowShowWorldMapCheckbox:SetChecked(false)

        -- Reset Color Swatches
        dialSwatch:SetVertexColor(0, 0, 0)
        needleSwatch:SetVertexColor(0, 1, 0)

        -- Update dropdown selection text
        UpdateArrowDropdownText()

        -- Reset facing frame positioning/scale
        FacingFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -34, -31)
        FacingFrame:SetScale(1)
        FacingFrame:Hide()
        WorldMapArrowFrame:Hide()

        DialFrame:Show()
        NeedleFrame:Show()

        -- Reapply texture and redraw dial/needle
        UpdateArrowTexture(ArrowDirectory .. CustomMinimapArrowDB.lastArrow)
        RedrawDial()
        RedrawNeedle()
    end)

    -- Close button
    local CloseButton = CreateFrame("Button", nil, self.Panel, "UIPanelButtonTemplate")
    CloseButton:SetSize(80, 22)
    CloseButton:SetPoint("BOTTOMRIGHT", self.Panel, "BOTTOMRIGHT", -24, 15)
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