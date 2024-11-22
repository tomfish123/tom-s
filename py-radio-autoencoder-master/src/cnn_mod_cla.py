import tensorflow as tf
from tensorflow.keras import layers, Model, Sequential


def cnn_mod_cla_2d(in_shape, class_num):
    '''2是（mod, snr）'''
    input_tensor = layers.Input(shape=in_shape, dtype='float32')
    
    x = layers.Conv2D(filters=128, kernel_size=8, padding='valid')(input_tensor)
    x = layers.ReLU()(x)
    
    x = layers.MaxPooling2D(pool_size=2, strides=2, padding='valid')(x)

    x = layers.Conv2D(filters=64, kernel_size=16, padding='valid')(x)
    x = layers.ReLU()(x)

    x = layers.MaxPooling2D(pool_size=2, strides=2, padding='valid')(x)
    
    x = layers.Flatten()(x)

    x = layers.Dense(units=128)(x)
    x = layers.ReLU()(x)

    x = layers.Dense(units=64)(x)
    x = layers.ReLU()(x)

    x = layers.Dense(units=32)(x)
    x = layers.ReLU()(x)

    x = layers.Dense(units=class_num)(x)
    output = layers.Softmax()(x)
    
    # 定义完 layers 后还要调用 Model 才算真正建立了模型
    model = Model(inputs=input_tensor, outputs=output)
    return model


def cnn_mod_cla_1d(in_shape, class_num):
    '''2是（mod, snr）'''
    input_tensor = layers.Input(shape=in_shape, dtype='float32')
    
    x = layers.Conv1D(filters=128, kernel_size=8, padding='valid')(input_tensor)
    x = layers.ReLU()(x)
    
    x = layers.MaxPooling1D(pool_size=2, strides=2, padding='valid')(x)
    
    x = layers.Conv1D(filters=64, kernel_size=16, padding='valid')(x)
    x = layers.ReLU()(x)
    
    x = layers.MaxPooling1D(pool_size=2, strides=2, padding='valid')(x)
    
    x = layers.Flatten()(x)
    
    x = layers.Dense(units=128)(x)
    x = layers.ReLU()(x)
    
    x = layers.Dense(units=64)(x)
    x = layers.ReLU()(x)
    
    x = layers.Dense(units=32)(x)
    x = layers.ReLU()(x)
    
    x = layers.Dense(units=class_num)(x)
    output = layers.Softmax()(x)
    
    # 定义完 layers 后还要调用 Model 才算真正建立了模型
    model = Model(inputs=input_tensor, outputs=output)
    return model


if __name__ == '__main__':
    model = cnn_mod_cla_1d(in_shape=(128, 2), class_num=11)
    model.summary()
