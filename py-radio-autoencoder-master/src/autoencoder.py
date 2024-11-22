# File:   autoencoder.py
# Brief:  Neural network autoencoded radio link over AWGN channel 
# Author: Vidit Saxena
#
# Usage:  import autoencoder
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

import tensorflow as tf
import numpy as np

def block_error_ratio_autoencoder_awgn(snrs_db, block_size, channel_use, batch_size, nrof_steps):
    
    print('block_size %d'%(block_size))
    print('channel_use %d'%(channel_use))
    
    rate = float(block_size)/float(channel_use)
    print('rate %0.2f'%(rate))
    
    '''The input is one-hot encoded vector for each codeword'''
    alphabet_size = pow(2, block_size)
    '''np.eye生成一个对角阵，以二维列表的形式呈现，见blog代码后解释,可以完美理解one hot'''
    alphabet = np.eye(alphabet_size, dtype='float32') # One-hot encoded values
    
    '''Repeat the alphabet to create training and test datasets'''
    '''np.transpose: 转置'''
    '''np.tile: 将数组沿各个方向复制，默认向右拓展'''
    '''先向右拓展再转置，等于是扩充列向量（每一个alphabet矩阵都是一串编码）'''
    '''这个train_dataset拥有 batch_size串编码，仍然可以看成是一维的数据集'''
    train_dataset = np.transpose(np.tile(alphabet, int(batch_size)))
    test_dataset = np.transpose(np.tile(alphabet, int(batch_size * 1000)))
    
    print('--Setting up autoencoder graph--')
    input, output, noise_std_dev, h_norm = _implement_autoencoder(alphabet_size, channel_use)
    
    print( '--Setting up training scheme--')
    train_step = _implement_training(output, input)
    
    print('--Setting up accuracy--')
    accuracy = _implement_accuracy(output, input)

    print('--Starting the tensorflow session--')
    sess = _setup_interactive_tf_session()
    _init_and_start_tf_session(sess)
    
    print('--Training the autoencoder over awgn channel--')
    _train(train_step, input, noise_std_dev, nrof_steps, train_dataset, snrs_db, rate, accuracy)
    
    print('--Evaluating autoencoder performance--')
    bler = _evaluate(input, noise_std_dev, test_dataset, snrs_db, rate, accuracy)
    
    print('--Closing the session--')
    _close_tf_session(sess)
    
    return bler


def block_error_ratio_autoencoder_awgn_RTN(snrs_db, block_size, channel_use, batch_size, nrof_steps):
    print('block_size %d' % (block_size))
    print('channel_use %d' % (channel_use))
    
    rate = float(block_size) / float(channel_use)
    print('rate %0.2f' % (rate))
    
    '''The input is one-hot encoded vector for each codeword'''
    alphabet_size = pow(2, block_size)
    '''np.eye生成一个对角阵，以二维列表的形式呈现，见blog代码后解释,可以完美理解one hot'''
    alphabet = np.eye(alphabet_size, dtype='float32')  # One-hot encoded values
    
    '''Repeat the alphabet to create training and test datasets'''
    '''np.transpose: 转置'''
    '''np.tile: 将数组沿各个方向复制，默认向右拓展'''
    '''先向右拓展再转置，等于是扩充列向量（每一个alphabet矩阵都是一串编码）'''
    '''这个train_dataset拥有 batch_size串编码，仍然可以看成是一维的数据集'''
    train_dataset = np.transpose(np.tile(alphabet, int(batch_size)))
    test_dataset = np.transpose(np.tile(alphabet, int(batch_size * 1000)))
    
    print('--Setting up autoencoder graph--')
    input, output, noise_std_dev, h_norm = _implement_autoencoder_RTN(alphabet_size, channel_use)
    
    print('--Setting up training scheme--')
    train_step = _implement_training(output, input)
    
    print('--Setting up accuracy--')
    accuracy = _implement_accuracy(output, input)
    
    print('--Starting the tensorflow session--')
    sess = _setup_interactive_tf_session()
    _init_and_start_tf_session(sess)
    
    print('--Training the autoencoder over awgn channel--')
    _train(train_step, input, noise_std_dev, nrof_steps, train_dataset, snrs_db, rate, accuracy)
    
    print('--Evaluating autoencoder performance--')
    bler = _evaluate(input, noise_std_dev, test_dataset, snrs_db, rate, accuracy)
    
    print('--Closing the session--')
    _close_tf_session(sess)
    
    return bler
    
    
def _setup_tf_session():
    return tf.Session()


def _setup_interactive_tf_session():
    return tf.compat.v1.InteractiveSession()


def _init_and_start_tf_session():
    init = tf.compat.v1.global_variables_initializer()
    sess = tf.Session()
    sess.run(init)
    return sess


def _init_and_start_tf_session(sess):
    sess.run(tf.compat.v1.global_variables_initializer())
   
    
def _close_tf_session(sess):
    sess.close
    
    
def _weight_variable(shape):
    initial = tf.random.truncated_normal(shape, stddev=0.01)
    return tf.Variable(initial)


def _bias_variable(shape):
    initial = tf.constant(0.01, shape=shape)
    return tf.Variable(initial)


def _implement_autoencoder(input_dimension, encoder_dimension):
    '''为即将输入的张量插入占位符，[None, input_dimension]为输入张量的shape, None表示batch_size数量未知'''
    input = tf.compat.v1.placeholder(tf.float32, [None, input_dimension])
    
    '''Densely connected encoder layer'''
    W_enc1 = _weight_variable([input_dimension, input_dimension])
    b_enc1 = _bias_variable([input_dimension])
    
    '''matuml是矩阵乘法'''
    '''矩阵乘法前提，左列右行相等，结果为一个纬度为左行右列的矩阵'''
    '''从tensor的角度看，这是两个二维tensor在相乘'''
    '''h_enc1 的 shape 为[input_dimension, input_dimension]'''
    h_enc1 = tf.nn.relu(tf.matmul(input, W_enc1) + b_enc1)
    
    '''Densely connected encoder layer'''
    '''这一层类比编码器'''
    W_enc2 = _weight_variable([input_dimension, encoder_dimension])
    b_enc2 = _bias_variable([encoder_dimension])
    
    '''这里shape转变为[input_dimension, encoder_dimension]'''
    h_enc2 = tf.matmul(h_enc1, W_enc2) + b_enc2
    
    '''Normalization layer'''
    '''tf.math.reciprocal用于计算倒数'''
    '''tf.reduce_sum压缩求和，用于降纬， https://blog.csdn.net/arjick/article/details/78415675'''
    '''tf.expand_dims 令tensor在指定轴上扩充纬度，参考 https://blog.csdn.net/TeFuirnever/article/details/88797810'''
    '''一缩一扩，shape 保持在[input_dimension, encoder_dimension]'''
    normalization_factor = tf.math.reciprocal(tf.sqrt(tf.reduce_sum(tf.square(h_enc2), 1))) * np.sqrt(encoder_dimension)
    h_norm = tf.multiply(tf.tile(tf.expand_dims(normalization_factor, 1), [1, encoder_dimension]), h_enc2)

    '''AWGN noise layer'''
    noise_std_dev = tf.compat.v1.placeholder(tf.float32)
    channel = tf.random.normal(tf.shape(h_norm), stddev=noise_std_dev)
    h_noisy = tf.add(h_norm, channel)
    
    '''Densely connected decoder layer'''
    '''这一层类比解码器'''
    '''shape 变回 [input_dimension, input_dimension]'''
    W_dec1 = _weight_variable([encoder_dimension, input_dimension])
    b_dec1 = _bias_variable([input_dimension])
    
    h_dec1 = tf.nn.relu(tf.matmul(h_noisy, W_dec1) + b_dec1)

    '''Output layer'''
    W_out = _weight_variable([input_dimension, input_dimension])
    b_out = _bias_variable([input_dimension])
     
    output = tf.nn.softmax(tf.matmul(h_dec1, W_out) + b_out)
    
    '''input 是一个二维tensor [input_dimension, input_dimension]'''
    '''output 也是一个二维tensor,shape与input一摸一样 [input_dimension, input_dimension]'''
    '''noise_std_dev是一个浮点数，表示噪声标准差'''
    '''h_norm shape 为 [input_dimension, encoder_dimension]'''
    return (input, output, noise_std_dev, h_norm)


def _implement_autoencoder_RTN(input_dimension, encoder_dimension):
    '''为即将输入的张量插入占位符，[None, input_dimension]为输入张量的shape, None表示batch_size数量未知'''
    input = tf.compat.v1.placeholder(tf.float32, [None, input_dimension])
    
    '''Densely connected encoder layer'''
    W_enc1 = _weight_variable([input_dimension, input_dimension])
    b_enc1 = _bias_variable([input_dimension])
    
    '''matuml是矩阵乘法'''
    '''矩阵乘法前提，左列右行相等，结果为一个纬度为左行右列的矩阵'''
    '''从tensor的角度看，这是两个二维tensor在相乘'''
    '''h_enc1 的 shape 为[input_dimension, input_dimension]'''
    h_enc1 = tf.nn.relu(tf.matmul(input, W_enc1) + b_enc1)
    
    '''Densely connected encoder layer'''
    '''这一层类比编码器'''
    W_enc2 = _weight_variable([input_dimension, encoder_dimension])
    b_enc2 = _bias_variable([encoder_dimension])
    
    '''这里shape转变为[input_dimension, encoder_dimension]'''
    h_enc2 = tf.matmul(h_enc1, W_enc2) + b_enc2
    
    '''Normalization layer'''
    '''tf.math.reciprocal用于计算倒数'''
    '''tf.reduce_sum压缩求和，用于降纬， https://blog.csdn.net/arjick/article/details/78415675'''
    '''tf.expand_dims 令tensor在指定轴上扩充纬度，参考 https://blog.csdn.net/TeFuirnever/article/details/88797810'''
    '''一缩一扩，shape 保持在[input_dimension, encoder_dimension]'''
    normalization_factor = tf.math.reciprocal(tf.sqrt(tf.reduce_sum(tf.square(h_enc2), 1))) * np.sqrt(encoder_dimension)
    h_norm = tf.multiply(tf.tile(tf.expand_dims(normalization_factor, 1), [1, encoder_dimension]), h_enc2)
    
    '''AWGN noise layer'''
    noise_std_dev = tf.compat.v1.placeholder(tf.float32)
    channel = tf.random.normal(tf.shape(h_norm), stddev=noise_std_dev)
    h_noisy = tf.add(h_norm, channel)
    
    '''Densely connected decoder layer'''
    '''这一层类比解码器'''
    '''shape 变回 [input_dimension, input_dimension]'''
    W_dec1 = _weight_variable([encoder_dimension, input_dimension])
    b_dec1 = _bias_variable([input_dimension])
    
    h_dec1 = tf.nn.relu(tf.matmul(h_noisy, W_dec1) + b_dec1)

    W_dec2 = _weight_variable([input_dimension, input_dimension])
    b_dec2 = _bias_variable([input_dimension])

    h_dec2 = tf.nn.relu(tf.matmul(h_dec1, W_dec2) + b_dec2)
    
    '''这就当作是transform layer了'''
    h_dec3 = tf.add(h_noisy, h_dec2)
    
    '''在softmax之前再经过两层'''
    W_dec4 = _weight_variable([input_dimension, input_dimension])
    b_dec4 = _bias_variable([input_dimension])

    h_dec4 = tf.nn.relu(tf.matmul(h_dec3, W_dec4) + b_dec4)

    W_dec5 = _weight_variable([input_dimension, input_dimension])
    b_dec5 = _bias_variable([input_dimension])

    h_dec5 = tf.nn.relu(tf.matmul(h_dec4, W_dec5) + b_dec5)
    
    '''Output layer'''
    W_out = _weight_variable([input_dimension, input_dimension])
    b_out = _bias_variable([input_dimension])
    
    output = tf.nn.softmax(tf.matmul(h_dec5, W_out) + b_out)
    
    '''input 是一个二维tensor [input_dimension, input_dimension]'''
    '''output 也是一个二维tensor,shape与input一摸一样 [input_dimension, input_dimension]'''
    '''noise_std_dev是一个浮点数，表示噪声标准差'''
    '''h_norm shape 为 [input_dimension, encoder_dimension]'''
    return (input, output, noise_std_dev, h_norm)
    
    
def _implement_training(output, input):
    cross_entropy = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits_v2(logits = output, labels = input))
    
#     train_step = tf.train.GradientDescentOptimizer(1e-2).minimize(cross_entropy) 
    train_step = tf.compat.v1.train.AdamOptimizer(1e-3).minimize(cross_entropy)
    
    return train_step


def _implement_accuracy(output, input):
    correct_prediction = tf.equal(tf.argmax(output, 1), tf.argmax(input, 1))
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
    return accuracy


def _train(train_step, input, noise_std_dev, nrof_steps, training_dataset, snrs_db, rate, accuracy):
    print('--Training--')
    print('number of steps %d'%(nrof_steps))
    snr = max(snrs_db)
    snrs_rev = snrs_db[::-1]
    for snr in snrs_rev[0:1]: # Train with higher SNRs first
        print('training snr %0.2f db'%(snr))
        noise = np.sqrt(1.0 / (2 * rate * pow(10, 0.1 * snr)))
        for i in range(int(nrof_steps)):
            batch = training_dataset
            np.random.shuffle(batch)
            if (i + 1) % (nrof_steps/10) == 0: # i = 0 is the first step
                print('training step %d'%(i + 1))
            train_step.run(feed_dict={input: batch, noise_std_dev: noise})
        print('training accuracy %0.4f'%(accuracy.eval(feed_dict={input: batch, noise_std_dev: noise})))


def _evaluate(input, noise_std_dev, test_dataset, snrs_db, rate, accuracy):
    print('--Evaluating NN performance on test dataset--')
    bler = []
    for snr in snrs_db:
        noise = np.sqrt(1.0 / (2 * rate * pow(10, 0.1 * snr)))
        acc = accuracy.eval(feed_dict={input: test_dataset, noise_std_dev: noise})
        bler.append(1.0 - acc)
    return bler

