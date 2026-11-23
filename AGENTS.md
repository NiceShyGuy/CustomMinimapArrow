# Custom Minimap Arrow

WoW addon replacing the default minimap and world-map player arrow. Single Lua file,
no libraries, no build step.

## Layout

- `CustomMinimapArrow/CustomMinimapArrow.toc` — metadata, interface versions, saved
  variables (`CustomMinimapArrowDB`)
- `CustomMinimapArrow/CustomMinimapArrow.lua` — entire addon (~1050 lines)
- `CustomMinimapArrow/Arrows/*.tga` — 128×128 arrow styles, selected by name
- `CustomMinimapArrow/UI/`, `icon.tga` — panel art
- `Artwork/`, `imgs/` — source art and store screenshots (not shipped)
- `README*.md`, `CHANGELOG*.md` — root and per-store variants; keep them in sync
- `.gitignore` excludes the docs variants, `Artwork/`, and release zips

## Work

- Use the `wow-addon` skill and the `wow` MCP server to verify every Blizzard API,
  event, and enum; check both retail and forever (WoW: Forever) for shared code.
  Classic-era clients (Mists/Cata/Wrath/Classic in the TOC) are not in the dataset —
  guard at runtime and say it is unverified.
- New arrow style: drop a 128×128 TGA in `Arrows/`, add the name to the arrow list
  used by the selector, display name = file name without extension.
- Keep the `## Interface` / `## Interface-<Flavor>` list and `## Version` in the TOC as
  the release source of truth; add a CHANGELOG entry per version.
- Supported behavior lives entirely in Lua 5.1; guard APIs that are not on all clients
  (`if Minimap and Minimap.SetPlayerTexture then ... end`, `if C_Map and ... then`).
- WoW: Forever cannot hide its native minimap marker; custom arrows overlay it. Do not
  promise replacement there.
