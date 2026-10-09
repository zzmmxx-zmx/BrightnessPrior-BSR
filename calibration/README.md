# Calibration utilities

The `calibration/` directory contains the brightness-calibration materials used for the brightness–parameter mapping described in the manuscript:

- `brightness_calibration_pairs.csv` provides the 70 released `(Lavg, a_opt)` calibration pairs.
- `generate_brightness_samples.m` implements controlled brightness scaling in the HSV value channel.
- `fit_brightness_mapping.m` performs entropy-based screening of the bistable parameter `a` over `[0, 8]` with a step of `0.1` and fits linear and quadratic brightness–parameter models.

## Calibration source images

The following ten source-image identifiers are recorded for the calibration set. Filenames are preserved as provided in the original dataset folders.

| Dataset subset | Source-image filenames | Count |
| --- | --- | ---: |
| LOL-v1 `our485` | `40.png`, `157.png`, `574.png`, `710.png` | 4 |
| LOL-v2-real `Train` | `normal00083.png`, `normal00157.png`, `normal00375.png` | 3 |
| LOL-v2-synthetic `Train` | `r0a64ce0bt.png`, `r1a7e4791t.png`, `r04a210b3t.png` | 3 |
| **Total** | | **10** |

The images should be obtained from the official dataset releases and kept under their original filenames. This repository does not redistribute the benchmark images. See `data/README.md` for dataset access information.

## Brightness-calibration procedure

Each source image is converted from RGB to HSV. The hue (`H`) and saturation (`S`) components are retained, while the value component (`V`) is scaled as

```text
V_alpha(x, y) = alpha * V(x, y)
```

The calibration uses brightness-scaling factors in the range `0.01–0.70`. The resulting sample brightness is characterized by `Lavg`, the mean value of the scaled HSV value component. For parameter screening, `b = 1` and `D = 0`; candidate values of `a` are evaluated from `0` to `8` in steps of `0.1`, with entropy of the enhanced value component as the fitness criterion. The selected `(Lavg, a_opt)` pairs are used to fit the brightness–parameter mapping.

The reported calibration set consists of 70 brightness-controlled samples. The released `brightness_calibration_pairs.csv` contains the corresponding 70 `(Lavg, a_opt)` pairs.

## Reproducibility notes

The calibration scripts provide a straightforward workflow for constructing brightness-controlled samples and fitting the brightness–parameter model. `generate_brightness_samples.m` applies the specified brightness-scaling factors to the source images, and `fit_brightness_mapping.m` performs parameter screening and regression fitting using the generated sample information.

The accompanying calibration pairs, source-image identifiers, and MATLAB scripts provide supporting materials for examining the brightness–parameter relationship and the associated model-fitting procedure.