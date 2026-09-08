# Calibration utilities

`generate_calibration_samples.m` implements the controlled value-channel scaling procedure used for brightness calibration. `fit_brightness_mapping.m` performs entropy-based screening of `a` on `[0,8]` with a step of `0.1` and fits linear/quadratic mappings.

For exact refitting of the coefficients reported in the paper, the manifest must list the exact non-test source images and scaling factors used for the 70 calibration samples. That exact 70-entry manifest was not present in the source files used to assemble this package and must be supplied before claiming exact coefficient-level reproduction.
