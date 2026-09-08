# Brightness-Prior-Guided Bistable SR for Low-Light Image Enhancement

MATLAB reproducibility code for the paper **“Efficient adaptive bistable stochastic resonance for low-light image enhancement guided by a global brightness prior.”**

## Repository contents

- `src/` — bistable RK4 solver, brightness-prior-guided PSO, enhancement, and evaluation utilities.
- `experiments/` — LOL-v1 eval15 ablation reproduction and a single-image demonstration.
- `calibration/` — released brightness–parameter calibration pairs, controlled brightness-sample generation, and regression fitting utilities.
- `data/` — expected dataset directory structure; benchmark images are not redistributed.
- `results/` — reference values reported in the manuscript and generated experiment outputs.

## Main configuration

The default configuration is defined in `config_default.m`.

| Parameter | Value |
|---|---:|
| admissible `a` range | `[0, 8]` |
| fixed `b` | `1` |
| fixed-SR `a` | `2` |
| local search radius `delta` | `0.5` |
| local PSO | `8 particles × 8 iterations` |
| global PSO | `30 particles × 50 iterations` |
| inertia weight | `0.9 → 0.4` |
| `c1`, `c2` | `2.0`, `2.0` |
| RK4 step `h` | `0.01` |
| terminal time | `1.0` |
| perturbation intensity `D` | `0` |
| parameter-evaluation image size | `100` |
| random seed | `1` |

The brightness prior predicts

```text
a_pred = 20.992 * L_avg^2 - 17.682 * L_avg + 5.121
```

and the proposed local search interval is clipped to the admissible domain:

```text
[max(0, a_pred - 0.5), min(8, a_pred + 0.5)]
```

## Requirements

The MATLAB release, operating system, required toolbox, and experimental hardware configuration are provided in `environment.txt`.

Required software:

- MATLAB R2024a
- Image Processing Toolbox

## Dataset preparation

This repository does not redistribute benchmark images.

For reproducing the LOL-v1 eval15 experiments, place the dataset as:

```text
data/LOL-v1/eval15/low/
data/LOL-v1/eval15/high/
```

Each low-light image must have a paired normal-exposure reference image with the same filename.

## Run the LOL-v1 ablation experiment

From the repository root in MATLAB:

```matlab
run('experiments/run_ablation_lolv1.m')
```

The script evaluates:

1. Fixed SR (`a = 2`)
2. Prediction only
3. Local PSO without brightness prior (`[3.5, 4.5]`)
4. Proposed brightness-prior-guided local PSO
5. Global PSO-SR (`[0, 8]`)

Generated results are written to:

```text
results/lolv1_ablation/
```

The output includes per-image results and averaged PSNR, SSIM, gray-level entropy, runtime, selected parameter values, and fitness-evaluation counts.

## Single-image demonstration

Place a low-light RGB image at:

```text
data/demo/input.png
```

and run:

```matlab
run('experiments/demo_single_image.m')
```

The enhanced result is written to the `results/` directory.

## Entropy definitions

Two entropy quantities are used for different purposes:

- **PSO fitness:** entropy of the enhanced HSV value component. This is used as the reference-free parameter-selection objective.
- **Reported evaluation entropy:** gray-level entropy computed after converting the final enhanced RGB output to grayscale.

These two definitions are intentionally kept separate in the implementation.

## Calibration utilities

The `calibration/` directory contains:

- `brightness_calibration_pairs.csv` — the 70 `(L_avg, a_opt)` calibration pairs used for regression fitting.
- `generate_brightness_samples.m` — implementation of the controlled brightness-scaling procedure described in the manuscript.
- `fit_brightness_mapping.m` — quadratic regression utility for reproducing the reported brightness–parameter mapping.

The released `brightness_calibration_pairs.csv` allows direct reproduction of the fitted quadratic mapping reported in the manuscript. The brightness-sample generation utility implements the controlled value-channel scaling procedure. The original source-image manifest used to construct the calibration samples is not redistributed.

## Reproducibility notes

The default PSO random seed is fixed to `1`.

One particle is initialized at the designated search-center value, while the remaining particles are initialized uniformly within the active search interval.

Including the initial population evaluation:

- Local PSO uses `8 × (8 + 1) = 72` fitness evaluations.
- Global PSO uses `30 × (50 + 1) = 1530` fitness evaluations.

Minor numerical and runtime variations may occur across MATLAB versions, operating systems, and computing environments, particularly for stochastic PSO-based methods.

## Reference results

The `results/paper_reported_table6.csv` file contains the reference values reported in the manuscript for the LOL-v1 eval15 ablation experiment. These values are provided for convenient comparison with reproduced results.
