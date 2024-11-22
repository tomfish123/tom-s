import pickle
import numpy as np

path = '/mnt/data_set/RML2016.10a_dict.pkl'


def to_onehot(yy):
    yy1 = np.zeros([len(yy), max(yy)+1])
    yy1[np.arange(len(yy)),yy] = 1
    return yy1


f = open(path, 'rb')
Xd = pickle.load(f, encoding='latin1')

snrs, mods = map(lambda j: sorted(list(set(map(lambda x: x[j], Xd.keys())))), [1, 0])
print('num of mods: {}'.format(len(mods)))
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
# in_shp.insert(3, 1)
in_shp = in_shp[1:]
# in_shp = [in_shp[1], in_shp[0]]
print(in_shp)
in_shp = tuple(in_shp)
print(in_shp)
print(type(in_shp))
# in_shp = list(X_train.shape[1:])

