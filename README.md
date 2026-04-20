# clear-atp

A small DCS World shader mod that sharpens the F-16C Block 50's AN/AAQ-33 **Sniper XR Advanced Targeting Pod** (ATP) FLIR image. Stock DCS renders it much blurrier than its real-world counterpart; this mod replaces two post-processing shaders with tuned versions that ease the blur and keep the heat-map / contrast behavior intact.

The mod touches only `Bazar/shaders/PostEffects/AdjustFLIR.fx` and `Bazar/shaders/PostEffects/ir.fx`. All tunable knobs live in a single shared header (`clear_flir_config.hlsl`), so you can tweak the look without reading shader code.

## What it changes

| Value | Stock DCS | clear-atp default |
|-------|-----------|-------------------|
| `KERNEL` (Gaussian blur samples, AdjustFLIR.fx) | 10 | 6 |
| `BLUR_STRENGTH` (blur sigma multiplier) | 1024 | 512 |
| `BLUR_RADIUS` (box blur in ir.fx) | 10 (21×21 samples) | 2 (5×5 samples) |
| `FOCUS_AMPLIFICATION` (defocus swing) | 20.0 | 4.6 |
| `PRECLAMP_KNEE` | — | 0.70 |
| `PRECLAMP_STRENGTH` | — | 1.00 |

`PRECLAMP_*` is new: it pulls very hot pixels (like cold/uncontrolled static aircraft sprites that the TGP renders near full-white) down just before the gain stage so they read as a bright gray rather than clamping to pure white. Terrain is unaffected because pixels below the knee pass through unchanged.

## Install

### With a mod manager (recommended)

Works with **OVGME** ([download](https://forum.dcs.world/topic/123565-ovgme-generic-mod-enabler-2020/)) or **JSGME**. Both overlay files from a mod folder onto the DCS install and can cleanly roll the mod back when disabled.

1. Download `clear-atp-vN.zip` from the [Releases page](../../releases).
2. Extract it into your OVGME/JSGME mods directory. You should end up with a `clear-atp/` folder containing `Bazar/shaders/...`.
3. Launch OVGME, select your DCS install as the target, tick `clear-atp`, apply.
4. **Clear the DCS shader cache** before your next launch (see below).

### Manual install

1. Close DCS.
2. Copy the three files from `clear-atp/Bazar/shaders/PostEffects/` in the zip into your DCS install at the same path (`<DCS install>/Bazar/shaders/PostEffects/`). You're replacing `AdjustFLIR.fx` and `ir.fx` and adding `clear_flir_config.hlsl`.
3. **Back up the originals first** if you want an easy manual uninstall.
4. Clear the DCS shader cache (see below).

## Clear the shader cache

DCS caches compiled shaders. Any time you install, uninstall, or edit the config, delete these folders (DCS recreates them on next launch — first load will be slower than usual):

```
%USERPROFILE%\Saved Games\DCS\fxo\
%USERPROFILE%\Saved Games\DCS\metashaders2\
%USERPROFILE%\Saved Games\DCS\metashaders3\     (if present)
```

## Tweak the look

Open `clear_flir_config.hlsl` in any text editor. It has six defines with comments explaining what each one does. Change a value, save, clear the shader cache, relaunch DCS. That's the entire workflow — both shaders pick up the new values automatically.

| Knob | What it does |
|------|--------------|
| `KERNEL` | Gaussian blur samples per direction in AdjustFLIR.fx. Smaller = sharper. Below ~4 the blur effectively no-ops because the Gaussian weights for non-center samples drop to near-zero. |
| `BLUR_STRENGTH` | Scales the Gaussian's sigma (width). Biggest single knob for sharpness. |
| `BLUR_RADIUS` | Half-width of ir.fx's upstream box blur. Compounds with the Gaussian. Stock is 10; `clear-atp` uses 2. |
| `FOCUS_AMPLIFICATION` | How much blur widens when the TGP is defocused. Lower = less dramatic defocus swing. |
| `PRECLAMP_KNEE` | Raw IR value above which highlight compression engages. Lower engages sooner (affects more mid-tones). |
| `PRECLAMP_STRENGTH` | How hard to compress bright pixels. `0` disables pre-clamp entirely. |

## Uninstall

- **OVGME / JSGME:** untick the mod and apply. It restores the original files.
- **Manual:** restore the originals from your backup, or run DCS's own `bin/DCS_updater.exe repair` to re-download the stock shaders. Then clear the shader cache.

## Compatibility & caveats

- Tested against DCS World as of April 2026. ED occasionally updates `AdjustFLIR.fx` / `ir.fx` — after a DCS update, you may need to reinstall or update the mod, and potentially rebase the changes against the new stock files if they diverge.
- Doesn't touch any game logic, only screen-space post-processing. Does not affect multiplayer integrity checks as far as I'm aware, but DCS's integrity-check policy can change — use at your own risk on integrity-checked servers.
- Only affects FLIR-based pods (F-16C Sniper, A-10C/Litening, AH-64 TADS, etc.) that share the `AdjustFLIR.fx` / `ir.fx` pipeline. The tuning here was dialed in against the F-16 Sniper specifically.

## How it works (short version)

DCS's FLIR rendering runs two post-processing shaders back to back: `ir.fx` converts the rendered scene into a grayscale thermal representation and does a 21×21 box blur, then `AdjustFLIR.fx` does a 2D Gaussian blur plus gain/level/mode passes to produce the final TGP image. Both shaders contribute to the stock "blobby" look. This mod reduces the blur width in both passes, and adds a soft highlight knee before the gain stage to prevent hot sprites from saturating to pure white when the blur is reduced.

<img width="2085" height="1233" alt="image" src="https://github.com/user-attachments/assets/e07772ec-9aec-4368-bf4a-a45d55153efc" />
<img width="2085" height="1233" alt="image" src="https://github.com/user-attachments/assets/67758061-79bb-4ec8-ad7b-00b7fcf26e61" />
<img width="2085" height="1233" alt="image" src="https://github.com/user-attachments/assets/e9850ecc-3a24-4e26-a2c2-4d43bc2317fd" />
<img width="2085" height="1233" alt="image" src="https://github.com/user-attachments/assets/a925dfb3-66fd-4c51-902f-7ef2baa94a08" />
<img width="2085" height="1233" alt="image" src="https://github.com/user-attachments/assets/9ae601fc-7fa5-4443-920b-e05dd1d29ce8" />
<img width="2085" height="1233" alt="image" src="https://github.com/user-attachments/assets/5fc1ecd9-ea3e-4f1e-b368-7c89a89daf8e" />
<img width="2085" height="1233" alt="image" src="https://github.com/user-attachments/assets/9ede2852-cc1b-40ff-8404-6745737c24f4" />
<img width="2085" height="1233" alt="image" src="https://github.com/user-attachments/assets/b632a9dd-e735-42fd-96a3-fa6d595b887e" />

Narrow XR
<img width="2085" height="1233" alt="image" src="https://github.com/user-attachments/assets/44122078-7a95-4951-a94e-a0ca0176cd83" />





## License

MIT. Shader code includes excerpts from the stock DCS World shaders for the TGP FLIR pipeline (© Eagle Dynamics). Those fragments are included purely as the tuning target and are reproduced under fair use for interoperability.
