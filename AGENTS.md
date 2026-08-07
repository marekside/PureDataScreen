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
