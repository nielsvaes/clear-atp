// =============================================================================
// clear-flir shader config — tweak these values to adjust the F-16 Sniper
// TGP FLIR image. Both AdjustFLIR.fx and ir.fx include this file, so you
// only need to edit in ONE place.
//
// After editing, clear DCS's shader cache so the shaders recompile next launch:
//   %USERPROFILE%\Saved Games\DCS\fxo\
//   %USERPROFILE%\Saved Games\DCS\metashaders2\
//   %USERPROFILE%\Saved Games\DCS\metashaders3\  (if present)
// =============================================================================

#ifndef CLEAR_FLIR_CONFIG_HLSL
#define CLEAR_FLIR_CONFIG_HLSL

// ---- AdjustFLIR.fx: Gaussian blur -------------------------------------------

// Samples per direction in the Gaussian blur kernel.
// Stock DCS: 10 | Clear-FLIR: 6 | Lower = sharper, but small values (<4) pair
// poorly with BLUR_STRENGTH because the Gaussian weights for non-center
// samples drop to near-zero and the blur effectively no-ops.
#define KERNEL 6

// Multiplier for the blur's sigma (Gaussian width). The biggest knob for
// overall image sharpness. Scales directly with the blur falloff.
// Stock DCS: 1024 | Clear-FLIR: 512 | Lower = sharper image.
#define BLUR_STRENGTH 512

// ---- AdjustFLIR.fx: pre-gain highlight compression --------------------------

// Below this raw IR value, no highlight compression (linear passthrough so
// terrain behaves exactly like stock). Above, a smoothstep ramp engages.
// Range 0.5 - 0.85. Lower engages sooner (affects mid-tones).
#define PRECLAMP_KNEE 0.70

// Pull-down strength above the knee. 0 = disabled (stock behavior; bright
// pixels saturate to pure white after gain). 1.0 = raw 1.0 maps to the knee
// before gain, which post-gain lands near a bright gray instead of clamping.
// Prevents uncontrolled/cold planes from appearing as hard white silhouettes.
#define PRECLAMP_STRENGTH 1.00

// ---- ir.fx: upstream box blur -----------------------------------------------

// Half-width of ir.fx's box blur. Samples are (2*R+1) x (2*R+1).
// Stock DCS: 10 (21x21 = 441 samples) | Clear-FLIR: 2 (5x5 = 25).
// Lower = sharper. Compounds with AdjustFLIR.fx's Gaussian.
#define BLUR_RADIUS 2

// Per-sample weight for ir.fx's box blur. Auto-computed from BLUR_RADIUS so
// brightness stays consistent when BLUR_RADIUS changes. No need to edit.
#define SAMPLE_WEIGHT (1.0 / ((BLUR_RADIUS * 2 + 1) * (BLUR_RADIUS * 2 + 1)))

// ---- Shared between AdjustFLIR.fx and ir.fx ---------------------------------

// Multiplier on how much the blur widens when the TGP is defocused (focus
// factor 0 -> 1). Both shaders read this. Stock DCS: 20.0 | Clear-FLIR: 4.6.
// Lower = less extreme defocus swing when the pod is refocusing.
#define FOCUS_AMPLIFICATION 4.6

#endif // CLEAR_FLIR_CONFIG_HLSL
