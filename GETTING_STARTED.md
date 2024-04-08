## Getting Started with DiffDet4SAR



### Installation

The codebases are built on top of [Detectron2](https://github.com/facebookresearch/detectron2), [Sparse R-CNN](https://github.com/PeizeSun/SparseR-CNN), and [denoising-diffusion-pytorch](https://github.com/lucidrains/denoising-diffusion-pytorch).
Thanks very much.

#### Requirements
- Linux or macOS with Python ≥ 3.6
- PyTorch ≥ 1.9.0 and [torchvision](https://github.com/pytorch/vision/) that matches the PyTorch installation.
  You can install them together at [pytorch.org](https://pytorch.org) to make sure of this
- OpenCV is optional and needed by demo and visualization

#### Steps
1. Install Detectron2 following https://github.com/facebookresearch/detectron2/blob/main/INSTALL.md#installation.

2. Prepare datasets
```
mkdir -p datasets/coco


ln -s /path_to_coco_dataset/annotations datasets/coco/annotations
ln -s /path_to_coco_dataset/train2017 datasets/coco/train2017
ln -s /path_to_coco_dataset/val2017 datasets/coco/val2017

```

3. Prepare pretrain models

DiffDet uses three backbones  ResNet-50 The pretrained ResNet-50 model can be
downloaded automatically by Detectron2. 

```bash
mkdir models
cd models

cd ..
```

4. Train DiffDet4SAR
```
python train_net.py --num-gpus 8 \
    --config-file configs/diffdet.coco.res50.yaml
```

5. Evaluate DiffDet4SAR
```
python train_net.py --num-gpus 8 \
    --config-file configs/diffdet.coco.res50.yaml \
    --eval-only MODEL.WEIGHTS path/to/model.pth
```

* Evaluate with arbitrary number (e.g 300) of boxes by setting `MODEL.DiffusionDet.NUM_PROPOSALS 300`.
* Evaluate with 4 refinement steps by setting `MODEL.DiffusionDet.SAMPLE_STEP 4`.



### Inference Demo with Pre-trained Models

```bash
python demo.py --config-file configs/diffdet.coco.res50.yaml \
    --input image.jpg --opts MODEL.WEIGHTS diffdet_coco_res50.pth
```

We need to specify `MODEL.WEIGHTS` to a model from model zoo for evaluation.
This command will run the inference and show visualizations in an OpenCV window.

For details of the command line arguments, see `demo.py -h` or look at its source code
to understand its behavior. Some common arguments are:
* To run __on your webcam__, replace `--input files` with `--webcam`.
* To run __on a video__, replace `--input files` with `--video-input video.mp4`.
* To run __on cpu__, add `MODEL.DEVICE cpu` after `--opts`.
* To save outputs to a directory (for images) or a file (for webcam or video), use `--output`.
