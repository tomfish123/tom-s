import tensorflow as tf
import numpy as np
import pickle
from cnn_mod_cla import cnn_mod_cla_1d
import os
import datetime
import matplotlib.pyplot as plt


batch_size = 64
epochs = 20
num_classes = 11

path = '/mnt/data_set/RML2016.10a_dict.pkl'
weights_name = 'mod_cla_test2'


gpu_device = 0
gpus = tf.config.list_physical_devices('GPU')
print("Num GPUs Available: ", len(gpus))
if gpus:
    # Restrict TensorFlow to only use the first GPU
    try:
        tf.config.experimental.set_visible_devices(gpus[gpu_device], 'GPU')
        tf.config.experimental.set_memory_growth(gpus[gpu_device], True)
        logical_gpus = tf.config.experimental.list_logical_devices('GPU')
        print(len(gpus), "Physical GPUs,", len(logical_gpus), "Logical GPU")
    except RuntimeError as e:
        # Visible devices must be set before GPUs have been initialized
        print(e)


def to_onehot(yy):
    yy1 = np.zeros([len(yy), max(yy)+1])
    yy1[np.arange(len(yy)),yy] = 1
    return yy1


def data_load(load_path):
    f = open(load_path, 'rb')
    Xd = pickle.load(f, encoding='latin1')
    
    snrs, mods = map(lambda j: sorted(list(set(map(lambda x: x[j], Xd.keys())))), [1, 0])
    X = []
    lbl = []
    for mod in mods:
        for snr in snrs:
            X.append(Xd[(mod, snr)])
            for i in range(Xd[(mod, snr)].shape[0]): lbl.append((mod, snr))
    X = np.vstack(X)
    
    # Partition the data
    #  into training and test sets of the form we can train/test on
    #  while keeping SNR and Mod labels handy for each
    np.random.seed(2016)
    n_examples = X.shape[0]
    n_train = int(n_examples * 0.5)
    train_idx = np.random.choice(range(0, n_examples), size=n_train, replace=False)
    test_idx = list(set(range(0, n_examples))-set(train_idx))
    X_train = X[train_idx]
    X_test = X[test_idx]
    Y_train = to_onehot(list(map(lambda x: mods.index(lbl[x][0]), train_idx)))
    Y_test = to_onehot(list(map(lambda x: mods.index(lbl[x][0]), test_idx)))

    X_train = np.reshape(X_train, newshape=(list(X_train.shape)[0], list(X_train.shape)[2], list(X_train.shape)[1]))
    X_test = np.reshape(X_test, newshape=(list(X_test.shape)[0], list(X_test.shape)[2], list(X_test.shape)[1]))
    
    in_shp = list(X_train.shape)
    in_shp = in_shp[1:]
    in_shp = tuple(in_shp)
    
    return X_train, X_test, Y_train, Y_test, in_shp


def plot_confusion_matrix(cm, title='Confusion matrix', cmap=plt.cm.Blues, labels=[]):
    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.title(title)
    plt.colorbar()
    tick_marks = np.arange(len(labels))
    plt.xticks(tick_marks, labels, rotation=45)
    plt.yticks(tick_marks, labels)
    plt.tight_layout()
    plt.ylabel('True label')
    plt.xlabel('Predicted label')
    

def train():
    X_train, X_test, Y_train, Y_test, in_shape = data_load(load_path=path)

    model = cnn_mod_cla_1d(in_shape=in_shape, class_num=num_classes)

    model.trainable = True

    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-6),
                  loss=tf.keras.losses.CategoricalCrossentropy(),
                  metrics=['accuracy'])

    model.summary()

    weights_dir_name = "{}_{}".format(weights_name, datetime.datetime.now().strftime("%Y%m%d-%H%M%S"))
    weights_export_path = os.path.join(os.getcwd(), 'weights', weights_dir_name, weights_dir_name + '.ckpt')
    checkpoint_callback = tf.keras.callbacks.ModelCheckpoint(filepath=weights_export_path,
                                                             monitor='val_accuracy',
                                                             verbose=1,
                                                             save_best_only=True,
                                                             save_weights_only=True,
                                                             mode='max')

    # 为 tensorboard 准备目录
    current_time = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    # 在win10下，为tensorboard准备的路径不能含有斜杆，必须用os.path.join进行拼接
    log_dir = os.path.join(os.getcwd(), 'train_log', weights_name + '_' + current_time)
    tensorboard_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)

    callbacks_list = [checkpoint_callback, tensorboard_callback]

    # 是数据集的话只需要将数据集赋给x, 如果是图像序列的话x核y分别赋 图像序列 和 标签序列
    # 如果传入数据集，不能自定义 batch_size 和 validation_rate
    # 必须定义 steps_per_epoch
    model.fit(x=X_train,
              y=Y_train,
              batch_size=batch_size,
              epochs=epochs,
              verbose=1,
              callbacks=callbacks_list,
              validation_data=(X_test, Y_test))
    

if __name__ == '__main__':
    train()
