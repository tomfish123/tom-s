import math
import random
import numpy as np


# 先生成一个随机的信源                                                                                        
def random_sources():
    random_sources = random.randint(0, 16)
    print('这个随机数是', random_sources)
    return hanming(random_sources)
    # return bin(int(random_sources))


# 进行编码，使用异或规则生成有校验位的(7,4)汉明码字
# def hanming(code_0):
#     # 把十进制的数字转变成二进制
#     code1 = bin(int(code_0))
#     code = str(code1)[2:]
#     print('{0}变成二进制'.format(code_0), code)
#     # #	判断待验证位数是否达到4位，不足位数前面补0
#     while len(code) < 4:
#         code = '0' + code
#         # 将码字转变成列表格式，方便后面进行操作
#     # print '补齐4位之后',code
#     code_list = list(code)
#     #  编码结构即码字，对于（7，4）线性分组码汉明码而言
#     code_1 = int(code_list[0]) ^ int(code_list[2]) ^ int(code_list[3])
#     code_2 = int(code_list[0]) ^ int(code_list[1]) ^ int(code_list[2])
#     code_4 = int(code_list[1]) ^ int(code_list[2]) ^ int(code_list[3])
#     code_list.insert(0, str(code_1))
#     code_list.insert(1, str(code_2))
#     code_list.insert(2, str(code_4))
#     hanming_code = ''.join(code_list)
#     print('生成的（7，4）汉明码字：' + hanming_code)
#     return code_list

def hanming(code_0):
    # 把十进制的数字转变成二进制
    code1 = bin(int(code_0))
    code = str(code1)[2:]
    print('{0}变成二进制'.format(code_0), code)
    # #	判断待验证位数是否达到4位，不足位数前面补0
    while len(code) < 4:
        code = '0' + code
        # 将码字转变成列表格式，方便后面进行操作
    # print '补齐4位之后',code
    code_list = list(code)
    #  编码结构即码字，对于（7，4）线性分组码汉明码而言
    code_1 = int(code_list[0]) ^ int(code_list[1]) ^ int(code_list[3]) ^ 1
    code_2 = int(code_list[0]) ^ int(code_list[2]) ^ int(code_list[3]) ^ 1
    code_4 = int(code_list[1]) ^ int(code_list[2]) ^ int(code_list[3]) ^ 1
    code_list.insert(0, str(code_1))
    code_list.insert(1, str(code_2))
    code_list.insert(3, str(code_4))
    hanming_code = ''.join(code_list)
    print('生成的（7，4）汉明码字：' + hanming_code)
    return code_list


if __name__ == '__main__':
    # x是原始信号,生成的（7，4）汉明码  
    # x1 = random_sources()
    x1 = hanming(3)
    print(x1)
