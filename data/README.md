# Dataset preparation

Benchmark images are **not redistributed** in this repository. Please obtain
each dataset from its original project or official release page and follow the
corresponding provider terms.

## LOL-v1

Project page / dataset release:

- https://daooshee.github.io/BMVC2018website/

Reference implementation:

- https://github.com/weichen582/RetinexNet

For reproducing the LOL-v1 `eval15` experiments in this repository, use the
following layout:

```text
data/
└── LOL-v1/
    └── eval15/
        ├── low/
        └── high/
```

Each low-light image in `low/` must have a paired normal-exposure reference
image with the same filename in `high/`.

## LOL-v2

Dataset release / project repository:

- https://github.com/flyywh/CVPR-2020-Semi-Low-Light

Associated publication:

- https://doi.org/10.1109/TIP.2021.3050850

The LOL-v2 release contains real-captured and synthetic subsets. A convenient
layout is:

```text
data/
└── LOL-v2/
    ├── Real_captured/
    │   ├── Train/
    │   └── Test/
    └── Synthetic/
        ├── Train/
        └── Test/
```

Keep the original low-light / normal-light pairing and filenames provided by
the dataset release.

## ExDark

Official repository:

- https://github.com/cs-chan/Exclusively-Dark-Image-Dataset

Suggested local layout:

```text
data/
└── ExDark/
    └── ...
```

Keep the original dataset organization. ExDark is released for research use;
please follow the usage terms stated by the dataset provider.

## LIME

Official project page:

- https://sites.google.com/view/xjguo/lime

Suggested local layout:

```text
data/
└── LIME/
    └── ...
```

Keep the downloaded image names unchanged.

## Single-image demo

For the included single-image demonstration, place an input image at:

```text
data/demo/input.png
```

and run:

```matlab
run('experiments/demo_single_image.m')
```

## Notes

- Do not commit benchmark images to this repository.
- The current `run_ablation_lolv1.m` script directly expects only the LOL-v1
  `eval15` layout shown above.
- LOL-v2, ExDark, and LIME are listed here to document the datasets used in
  the manuscript and their acquisition sources.
