## DiffDet4SAR: Diffusion-based Aircraft Target Detection Network for SAR Images

**DiffDet4SAR is the first work of diffusion model for SAR image aircraft target detection.**




> [**DiffDet4SAR: Diffusion-based Aircraft Target Detection Network for SAR Images**](https://arxiv.org/abs/2404.03595)               
accepted by GRSL DOI: 10.1109/LGRS.2024.3386020

## Updates
- (04/2024) Code is released.

## Dataset
SAR-AIRcraft1.0 (doi: 10.12000/JR23043)



## Getting Started

The installation instruction and usage are in [Getting Started with DiffusionDet](GETTING_STARTED.md).

## Train:
1. modeifying the weight in DiffusionDet-main/configs/Base-DiffusionDet.yaml (use pre-train res50)
2.  modeifying the weight in DiffusionDet-main/configs/diffdet.coco.res50.300boxes.yaml (can also ues pre-train res50, for at presen)

## Quantative Results:
Quantitative results of different models evaluated by AP@50. The model weights are available at  You can down load the model weights and put it to the checkpoints folder and modify the weight in DiffusionDet-main/configs/diffdet.coco.res50.300boxes.yaml


*The overall repository style is highly borrowed from [DifffusionDet](https://github.com/ShoufaChen/DiffusionDet). Thanks to Shoufa Chen.

## License

This project is under the CC-BY-NC 4.0 license. See [LICENSE](LICENSE) for details.


## Citing DiffDet4SAR

If you use DiffDet4SAR in your research or wish to refer to the baseline results published here, please use the following BibTeX entry.

```BibTeX
@ARTICLE{10494361,
  author={Zhou, Jie and Xiao, Chao and Peng, Bo and Liu, Zhen and Liu, Li and Liu, Yongxiang and Li, Xiang},
  journal={IEEE Geoscience and Remote Sensing Letters}, 
  title={DiffDet4SAR: Diffusion-Based Aircraft Target Detection Network for SAR Images}, 
  year={2024},
  volume={21},
  number={},
  pages={1-5},
  keywords={Aircraft;Object detection;Radar polarimetry;Feature extraction;Scattering;Noise;Convolution;Aircraft target detection;diffusion model;synthetic aperture radar (SAR)},
  doi={10.1109/LGRS.2024.3386020}}

```
