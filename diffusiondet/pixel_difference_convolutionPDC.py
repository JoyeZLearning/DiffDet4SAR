
'''
先用CPDC,然后APDC,然后RPDC，再然后普通的卷积
'''
import math

import torch
import torch.nn as nn
import torch.nn.functional as F


class Conv2d(nn.Module):
    def __init__(self, pdc, in_channels, out_channels, kernel_size, stride=1, padding=0, dilation=1, groups=1, bias=False):
        super(Conv2d, self).__init__()
        if in_channels % groups != 0:
            raise ValueError('in_channels must be divisible by groups')
        if out_channels % groups != 0:
            raise ValueError('out_channels must be divisible by groups')
        self.in_channels = in_channels
        self.out_channels = out_channels
        self.kernel_size = kernel_size
        self.stride = stride
        self.padding = padding
        self.dilation = dilation
        self.groups = groups
        self.weight = nn.Parameter(torch.Tensor(out_channels, in_channels // groups, kernel_size, kernel_size))
        if bias:
            self.bias = nn.Parameter(torch.Tensor(out_channels))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()
        self.pdc = pdc

    def reset_parameters(self):
        nn.init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = nn.init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            nn.init.uniform_(self.bias, -bound, bound)

    def forward(self, input):

        return self.pdc(input, self.weight, self.bias, self.stride, self.padding, self.dilation, self.groups)



def CPDC(x, weights, bias=None, stride=1, padding=0, dilation=1, groups=1):
    '''
    四周与中心
    '''
    assert dilation in [1, 2], 'dilation for cd_conv should be in 1 or 2'
    assert weights.size(2) == 3 and weights.size(3) == 3, 'kernel size for cd_conv should be 3x3'
    assert padding == dilation, 'padding for cd_conv set wrong'

    weights_c = weights.sum(dim=[2, 3], keepdim=True) #B,C,3,3 -> B,C,1,1
    yc = F.conv2d(x, weights_c, stride=stride, padding=0, groups=groups)
    y = F.conv2d(x, weights, bias, stride=stride, padding=padding, dilation=dilation, groups=groups)
    return y - yc

def APDC(x, weights, bias=None, stride=1, padding=0, dilation=1, groups=1):
    '''
    四周循环
    '''
    assert dilation in [1, 2], 'dilation for ad_conv should be in 1 or 2'
    assert weights.size(2) == 3 and weights.size(3) == 3, 'kernel size for ad_conv should be 3x3'
    assert padding == dilation, 'padding for ad_conv set wrong'

    shape = weights.shape
    weights = weights.view(shape[0], shape[1], -1) #B,C,3,3 -> B,C,9
    weights_conv = (weights - weights[:, :, [3, 0, 1, 6, 4, 2, 7, 8, 5]]).view(shape) # clock-wise
    y = F.conv2d(x, weights_conv, bias, stride=stride, padding=padding, dilation=dilation, groups=groups)
    return y



def RPDC(x, weights, bias=None, stride=1, padding=0, dilation=1, groups=1):
    '''
    径向方向
    '''
    assert dilation in [1, 2], 'dilation for rd_conv should be in 1 or 2'
    assert weights.size(2) == 3 and weights.size(3) == 3, 'kernel size for rd_conv should be 3x3'
    padding = 2 * dilation

    shape = weights.shape
    if weights.is_cuda:
        buffer = torch.cuda.FloatTensor(shape[0], shape[1], 5 * 5).fill_(0)
    else:
        buffer = torch.zeros(shape[0], shape[1], 5 * 5)
    weights = weights.view(shape[0], shape[1], -1) #B,C,5,5 -> B,C,25
    buffer[:, :, [0, 2, 4, 10, 14, 20, 22, 24]] = weights[:, :, 1:]
    buffer[:, :, [6, 7, 8, 11, 13, 16, 17, 18]] = -weights[:, :, 1:]
    buffer[:, :, 12] = 0
    buffer = buffer.view(shape[0], shape[1], 5, 5)
    y = F.conv2d(x, buffer, bias, stride=stride, padding=padding, dilation=dilation, groups=groups)
    return y
