## DiffDet4SAR: Diffusion-based Aircraft Target Detection Network for SAR Images

👑**DiffDet4SAR is the first work of diffusion model for SAR image aircraft target detection.**




> [**DiffDet4SAR: Diffusion-based Aircraft Target Detection Network for SAR Images**](https://arxiv.org/abs/2404.03595)               
published by GRSL DOI: 10.1109/LGRS.2024.3386020

## 🛠️ Updates
- (04/2024) Code is released.

## 🕸️ Dataset
SAR-AIRcraft1.0 (doi: 10.12000/JR23043)



## 📽️ Getting Started

The installation instruction and usage are in [Getting Started with DiffusionDet](GETTING_STARTED.md).

## 🚉 Train/Evalution:
1. modifying the weight in DiffusionDet-main/configs/Base-DiffusionDet.yaml (use pre-train res50)
2.  modifying the weight in DiffusionDet-main/configs/diffdet.coco.res50.300boxes.yaml
3.  modifying  DiffusionDet-main/detectron2/engine/defaults.py  and the 98-122 line to your root.
4.  As for other configs and their meaning,  [DifffusionDet](https://github.com/ShoufaChen/DiffusionDet) is introduced in detail.
5.  ATTENTION：In order to use the code directly and reduce the complexity of the code, I changed the images and annotations of the aircraft dataset into the coco format, and put them in the folder named coco.
6.  ![image](https://github.com/JoyeZLearning/DiffDet4SAR/assets/164322321/8ea8c3f3-d17c-453d-832a-b906dd5e4003)




## 🏝️ Quantative Results:
Quantitative results of different models evaluated by AP@50. 


*The overall repository style is highly borrowed from [DifffusionDet](https://github.com/ShoufaChen/DiffusionDet). Thanks to Shoufa Chen.

## License

This project is under the CC-BY-NC 4.0 license. See [LICENSE](LICENSE) for details.


## 🍭 GOOD NEW!!!
DiffDet4SAR has entered the top 1% of ESI highly cited papers and obtained her life trophy on May, 08, 2025 🎉🎉🎉
![8ace4a5b0d061265d1f6c869093c0e0c](https://github.com/user-attachments/assets/2975bff2-8151-4042-a799-42cbef994ec2)


## 💡 Citing DiffDet4SAR

If you find DiffDet4SAR helpful to your research or wish to refer to the baseline results published here, please use the following BibTeX entry.

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
Please light up the STAR⭐⭐⭐⭐⭐  to encourage more and more opensource on SAR image interpretations!

🥰🥳🥂
