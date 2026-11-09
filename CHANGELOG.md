# Changelog

## Unreleased

- Upscaled all arrow textures to 128x128.
- Added high-resolution default-style arrows based on WoW: Forever's native minimap arrow, recreated as addon art.
- Adjusted the Drip, Sword, and Dagger arrow artwork to cover WoW: Forever's native minimap marker, which addons cannot hide; Sword arrows are thicker for coverage.

## 2.0.3

- Reworked the arrow selector into a multi-column menu with arrow previews and a visible selection indicator.
- Added color variants of the default arrow and expanded the high-visibility and Okabe-Ito colorblind-friendly options.
- Set the minimum arrow scale to 1.0 and normalize saved values below that limit.
- Improved the configuration panel's display priority and Escape-key closing behavior.
- Documented that WoW: Forever does not expose an addon API or accessible FrameXML object for its native minimap player marker; custom arrows can only be overlaid, not used to replace or hide the native marker.
- Updated the world-map player-arrow handling to synchronize pin size changes.
- Consolidated expansion-specific TOC metadata and updated interface versioning for broader client compatibility.

## 2.0.2

- Polished existing arrows and added high-visibility and Okabe-Ito palette colorblind-safe arrows.
- Added the MN pointer to the TOC file.

## 2.0.1

- Updated TOC files to improve interface compatibility across expansions.

## 2.0

- Fixed world-map player-arrow hiding by using `provider:SetUnitPinSize("player", 0)` and `provider.pin:SynchronizePinSizes()`.

## 1.9

- Fixed an issue where hiding a shared Blizzard world-map pin could also hide party or raid members. The addon now targets the player's own world-map pin instead of mutating a shared pin, preserving group-member visibility while showing the custom arrow.

## 1.8

- Added icon texture and category metadata to the TOC files for improved addon organization.

## 1.7

- Added a compatibility helper for `Minimap:SetPlayerTexture` and updated arrow texture handling for Retail.

## 1.6

- Fixed a World Map bug.

## 1.5

- Redesigned the configuration panel for a cleaner, more consistent experience.
- Reorganized controls into a symmetrical two-column grid with consistent spacing and margins; removed old column headers and redundant buttons.
- Added a global Reset button that restores all settings and immediately refreshes the UI and on-screen elements.
- Added rotated 14×14 arrow previews to the arrow-style dropdown.
- Added World Map support:
  - Added a custom `WorldMapArrowFrame` that renders above other UI elements and hides the default Blizzard player arrow.
  - Added dungeon and cross-version handling (Classic through Retail).
  - Made the custom arrow respect the Arrow Scale setting and player facing.

## 1.4

- Improved overlay layering and depth so the custom minimap arrow renders above other minimap elements:
  - Set `CustomArrowFrame` to the `TOOLTIP` frame strata and frame level 1000.
  - Set the arrow texture to the `OVERLAY` draw layer with sub-level 7.
- Added dungeon scaling integrated with the Rotate Minimap setting:
  - When Rotate Minimap is enabled, the arrow points straight up (rotation 0).
  - In dungeons with Rotate Minimap enabled, hides the default arrow and shows the custom scaled overlay.
  - In dungeons with Rotate Minimap disabled, falls back to the engine arrow using `Minimap:SetPlayerTexture`, allowing the engine to rotate it.
- Replaced static dial and needle textures with customizable vector lines:
  - Draws 36 dial ticks programmatically, with major ticks every 30 degrees and minor ticks every 10 degrees.
  - Draws a rotating needle from a radial tick that follows the player's heading.
  - Re-parented the dial and needle frames to the Minimap so they scale and move with it.
- Redesigned the interactive configuration panel:
  - Expanded the `/cma` panel to 480×500 and organized controls into two columns.
  - Added independent Show Dial and Show Needle checkboxes, sliders for dial and needle dimensions, and color swatches.
  - Added gray borders around color swatches so dark colors remain visible against the Blizzard panel.
  - Added a unified color-picker callback supporting modern and legacy pickers across Retail and Classic, with a live color preview.
- Updated TOC interface versions for the supported game clients:
  - Retail: `120100`, `120000`, `120001`, `120002` (Retail 12.1.0).
  - Mists of Pandaria Classic: `50504`, `50500` (5.5.4).
  - Cataclysm Classic: `40402`, `40403`, `40404`, `50504` (4.4.2).
  - Wrath Classic / Wrath Titan Reforged: `38001`, `30405`, `30403`, `40403`, `40404` (3.80.1 and 3.4.5).
  - Classic Era: `11509`, `11508` (1.15.9).
  - Burning Crusade Classic: `20506`, `20504` (2.5.6).

## 1.3

- Updated the facing display.

## 1.2

- Added an Empty texture to address a Retail bug.

## 1.1

- Dungeon Bug Fix

## 1.0

- Removed debug print