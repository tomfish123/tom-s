import numpy as np

block_size = 2
alphabet_size = pow(2, block_size)
'''生成边长为alphabet_size 的二维矩阵'''
alphabet = np.eye(alphabet_size, dtype='float32') # One-hot encoded values
print(alphabet)