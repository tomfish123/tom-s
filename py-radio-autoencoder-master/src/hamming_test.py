# File:   hamming.py
# Brief:  Simulates a Hamming coded radio link over AWGN channel
# Author: Vidit Saxena
#
# Usage:  import hamming
#
# -------------------------------------------------------------------------
#
# Copyright (C) 2016 CC0 1.0 Universal (CC0 1.0) 
#
# The person who associated a work with this deed has dedicated the work to
# the public domain by waiving all of his or her rights to the work 
# worldwide under copyright law, including all related and neighboring 
# rights, to the extent allowed by law.
#
# You can copy, modify, distribute and perform the work, even for commercial 
# purposes, all without asking permission.
#
# See the complete legal text at 
# <https://creativecommons.org/publicdomain/zero/1.0/legalcode>
#
# -------------------------------------------------------------------------

import itpp


def block_error_ratio_hamming_awgn(snr_db, block_size):
    """
    snr_db: 信噪比
    block_size: 一个码字包含的有效信息bit数, 目前只能为4，可以修改mapping_k_m来增加可输入的block_size
    """

    # Mapping from k (block size) to m. m = 3 implies (7,4) code
    # 添加冗杂位
    mapping_k_m = {4: 3}
    m = mapping_k_m[block_size]
     
    '''Hamming encoder and decoder instance'''
    # 这里只是实例化一个对象，没有任何实际效果
    hamm = itpp.comm.Hamming_Code(m)
    # 返回pow(2, m) 返回 2^m
    # channel use
    n = pow(2, m) - 1
    # 计算码率：有效位数/码字总位数
    rate = float(block_size)/float(n)
    
    '''Generate random bits'''
    # 假设信源发送 10000 个码字
    nrof_bits = 10000 * block_size
    source_bits = itpp.randb(nrof_bits)
    # print('soruce_type: {}, source_bits: {}'.format(type(source_bits), source_bits))
    
    '''Encode the bits'''
    encoded_bits = hamm.encode(source_bits)
    # print('encoded_type: {}, encoded_bits: {}'.format(type(encoded_bits), encoded_bits))
    
    '''Modulate the bits'''
    modulator_ = itpp.comm.modulator_2d()
    constellation = itpp.cvec('-1+0i, 1+0i')
    symbols = itpp.ivec('0, 1')
    modulator_.set(constellation, symbols)
    tx_signal = modulator_.modulate_bits(encoded_bits)
    # print('tx_signal_type: {}, tx_signal: {}'.format(type(tx_signal), tx_signal))
    
    '''Add the effect of channel to the signal'''
    noise_variance = 1.0 / (rate * pow(10, 0.1 * snr_db))
    noise = itpp.randn_c(tx_signal.length())
    noise *= itpp.math.sqrt(noise_variance)
    # print('noise_type: {}, noise: {}'.format(type(noise), noise))
    rx_signal = tx_signal + noise
    # print('rx_signal_type: {}, rx_signal: {}'.format(type(rx_signal), rx_signal))
    
    
    
    '''Demodulate the signal'''
    demodulated_bits = modulator_.demodulate_bits(rx_signal)
    # print('demodulated_bits_type: {}, demodulated_bits: {}'.format(type(demodulated_bits), demodulated_bits))
    
    '''Decode the received bits'''
    decoded_bits = hamm.decode(demodulated_bits)
    # print('decoded_bits_type: {}, decoded_bits: {}'.format(type(decoded_bits), decoded_bits))
    
    '''Calculate the block error ratio'''
    # 查看传送的 10000 个码字中有多少个出错了
    blerc = itpp.comm.BLERC(block_size)
    blerc.count(source_bits, decoded_bits)
    return blerc.get_errorrate()


if __name__ == '__main__':
    errorRate = block_error_ratio_hamming_awgn(-10, 4)
    print('errorRate:{}'.format(errorRate*100))
