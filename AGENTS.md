# PureDataScreen — Agent Notes

## Connect IQ SDK

Path: `$env:APPDATA\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.2.0-2026-06-09-92a1605b2\bin`
(`monkeyc.bat`, `monkeydo.bat`, `simulator.exe`, `connectiq.bat`)

## Build (all Edge targets)

Run from project root `D:\Learning\Garmin\DataScreen\PureDataScreen\PureDataScreen`:

```powershell
$sdkBin = "$env:APPDATA\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.2.0-2026-06-09-92a1605b2\bin"
foreach ($d in @("edge540","edge550","edge840","edge850","edge1040","edge1050")) {
  & "$sdkBin\monkeyc.bat" -d $d -f monkey.jungle -o "bin\PureDataScreen-$d.prg" -y developer_key -w
}
```

Use `developer_key` (no extension) from the project root as the signing key.

## Simulator workflow (data fields)

Data fields do NOT auto-render when launched via `connectiq` — they appear as an empty window. Use this two-step sequence instead:

1. Launch the simulator with the device (and optional layout):
   ```powershell
   $sdkBin = "$env:APPDATA\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.2.0-2026-06-09-92a1605b2\bin"
   Start-Process -FilePath "$sdkBin\simulator.exe" -ArgumentList "--device","edge850"
   ```
2. Push the .prg so it runs in the simulator (must be run from project root):
   ```powershell
   & "$sdkBin\monkeydo.bat" "bin\PureDataScreen-edge850.prg" "edge850"
   ```

Without `monkeydo`, the simulator window stays blank even though the .prg is loaded.

## Field conventions

- New fields: file under `source/Fields/<Name>Field.mc`, extend `BaseField`, implement
  `computeField(info, layoutKey, dataField) as Field`. Return `new Field(layoutKey, "N/A", "")`
  when data is missing.
- Register in `source/Fields/FieldTypes.mc` (enum + `getFieldByType` switch) and
  `source/FieldController.mc` (`fieldStrategyMap`). Add a label to
  `resources/strings/strings.xml` and a `<listEntry>` to each of the 7 `field1`…`field7`
  blocks in `resources/settings/settings.xml`.
- Custom drawing: extend `Field`, override `hasCustomDrawing()` + `draw(dc, cx, cy, size, fg)`
  (see the removed `NavigationFieldValue` for the prior pattern — to be reworked).
- State across `computeField` calls is preserved on the strategy instance (used by
  `GradeField`'s rolling alt/distance buffer). It resets on layout/setting change.

## Layouts

- `resources/layouts/layouts.xml` (default) plus per-device copies:
  `resources-edge550/`, `resources-edge850/`, `resources-edge1050/`, etc.
- Two layouts available: `WahooLayout16` (1 big + 6 small) and `WahooLayout14` (1 big + 4 small).
- For each `FIELDn` the layout defines three labels: `FIELDn` (label), `FIELDn_value` (number),
  `FIELDn_decimal` (decimal/small).
- Each layout also declares a `<text-area id="FIELDn_bg" ... background="Graphics.COLOR_TRANSPARENT" />`
  per field, covering the full field quadrant. The controller sets its color via
  `bgDrawable.setColor(...)` for alert states (HR zones, BikeRadar threat).

## Alert background pattern

- **`Field.mc`** — exposes `BackgroundColor` (default `COLOR_TRANSPARENT`) and `TextColor`,
  with `setBackgroundColor(color)` / `setTextColor(color)` setters and
  `hasCustomBackground()` predicate.
- **`FieldController.paintFieldBackgrounds(dc)`** — for every field with a non-transparent
  `BackgroundColor`, computes the field rectangle from layout percentages (the same grid
  used by `drawables.xml` for the grid lines: 1 big top + 2x3 cells for WahooLayout16,
  1 big + 2x2 for WahooLayout14), fills it with `dc.fillRectangle`, then re-draws the
  field's label/value/decimal drawables on top via `drawable.draw(dc)`. Must run AFTER
  `View.onUpdate(dc)` so the layout's full-screen `Background` drawable doesn't cover it.
- **`FieldController.redrawField(...)`** — honors `field.TextColor` when not
  `COLOR_TRANSPARENT`; otherwise uses black/white based on the datafield bg color.
- **HR zones** (HeartRateField): pulled from `UserProfile.getHeartRateZones(getCurrentSport())` returning `[minZ1, maxZ1, maxZ2, maxZ3, maxZ4, maxZ5]`. Five-color palette (Blue/Green/Yellow/Orange/Red), fallback to hardcoded 130/160 if zones unavailable.
- **Power zones** (PowerField): same pattern via `UserProfile.getPowerZones(SPORT_CYCLING)`, fallback to 200/300 W thresholds.
- **Stamina field** (StaminaField): rolling-window W'bal-lite via EWMA-smoothed ratio of effort (power preferred, HR fallback) vs threshold (FTP from `getFunctionalThresholdPower`, or LTHR from top of HR zone 4). Trend arrow via custom-draw hook. Color coding: >50 green, 20-50 yellow, <20 red. Empty state shows ASCII `-` (Bebas has no glyph for `—`). Trend arrows use ASCII `+`/`-` for the same reason.
- **Drawables don't render Unicode glyphs** — Bebas_* fonts only ship ASCII + digits. Use `+`/`-` for up/down trends and `-` for empty values. `dc.drawText(x, y, font, text, justification)` is the correct 5-arg signature; `FONT_MEDIUM` doesn't guarantee arrow glyphs on Edge either, so ASCII is the safer choice.

## Future ideas (not yet implemented)

- **Body Battery clamp for Stamina**: `Toybox.SensorHistory.getBodyBatteryHistory({:period => 1})` returns a `SensorHistoryIterator` whose `sample.data` is the 0-100 value. Use as upper bound: `displayed = min(myComputedStamina, bodyBattery)`. Gate via `Toybox has :SensorHistory` and `Toybox.SensorHistory has :getBodyBatteryHistory` so older devices fail gracefully. Body Battery is supported on Edge 1040/850/1050 but not Edge 540/550/840.
