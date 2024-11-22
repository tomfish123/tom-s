#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May 28 17:41:08 2024

@author: bouboujr
"""
"""
@article{nn-decoding,
      title={On Deep Learning-Based Channel Decoding},
      author={Tobias Gruber and
              Sebastian Cammerer and
              Jakob Hoydis and
              Stephan ten Brink}
      journal={CoRR}
      year={2017}
      url= {http://arxiv.org/abs/1701.07738}
    }
"""
#%% Bibliotheques

import numpy as np
import tensorflow as tf
from keras.models import Sequential
from keras.layers import Dense, Lambda
from tensorflow.keras import backend as K
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import itertools
import time
from scipy.special import erfc


#%% Fonctions

def modulateBPSK(x):
    return -2*x +1;

def addNoise(x, sigma):
    w = K.random_normal(K.shape(x), mean=0.0, stddev=sigma)
    return x + w

def ber(y_true, y_pred):
    y_true = K.cast(y_true, 'float32')  # Cast y_true to float32
    return K.mean(K.not_equal(y_true, K.round(y_pred)))

def return_output_shape(input_shape):  
    return input_shape

def compose_model(layers):
    model = Sequential()
    for layer in layers:
        model.add(layer)
    return model

def log_likelihood_ratio(x, sigma):
    return 2*x/np.float32(sigma**2)

def errors(y_true, y_pred):
    #print(y_true)
    #print(y_pred)
    y_true = K.cast(y_true, 'float32')  # Cast y_true to int32
    #print(y_true)
    y_pred = K.cast(K.round(y_pred), 'float32')  # Ensure y_pred is rounded and cast to int32
    #print(y_pred)
    out = K.not_equal(y_true, y_pred)
    out = K.sum(K.cast(out,'float32'))
    return out

def half_adder(a,b):
    s = a ^ b
    c = a & b
    return s,c

def full_adder(a,b,c):
    s = (a ^ b) ^ c
    c = (a & b) | (c & (a ^ b))
    return s,c

def add_bool(a,b):
    if len(a) != len(b):
        raise ValueError('arrays with different length')
    k = len(a)
    s = np.zeros(k,dtype=bool)
    c = False
    for i in reversed(range(0,k)):
        s[i], c = full_adder(a[i],b[i],c)    
    if c:
        warnings.warn("Addition overflow!")
    return s

def inc_bool(a):
    k = len(a)
    increment = np.hstack((np.zeros(k-1,dtype=bool), np.ones(1,dtype=bool)))
    a = add_bool(a,increment)
    return a

def bitrevorder(x):
    m = np.amax(x)
    n = np.ceil(np.log2(m)).astype(int)
    for i in range(0,len(x)):
        x[i] = int('{:0{n}b}'.format(x[i],n=n)[::-1],2)  
    return x

def int2bin(x,N):
    if isinstance(x, list) or isinstance(x, np.ndarray):
        binary = np.zeros((len(x),N),dtype='bool')
        for i in range(0,len(x)):
            binary[i] = np.array([int(j) for j in bin(x[i])[2:].zfill(N)])
    else:
        binary = np.array([int(j) for j in bin(x)[2:].zfill(N)],dtype=bool)
    
    return binary

def bin2int(b):
    if isinstance(b[0], list):
        integer = np.zeros((len(b),),dtype=int)
        for i in range(0,len(b)):
            out = 0
            for bit in b[i]:
                out = (out << 1) | bit
            integer[i] = out
    elif isinstance(b, np.ndarray):
        if len(b.shape) == 1:
            out = 0
            for bit in b:
                out = (out << 1) | bit
            integer = out     
        else:
            integer = np.zeros((b.shape[0],),dtype=int)
            for i in range(0,b.shape[0]):
                out = 0
                for bit in b[i]:
                    out = (out << 1) | bit
                integer[i] = out
        
    return integer

def polar_design_awgn(N, k, design_snr_dB):  
        
    S = 10**(design_snr_dB/10)
    z0 = np.zeros(N)

    z0[0] = np.exp(-S)
    for j in range(1,int(np.log2(N))+1):
        u = 2**j
        for t in range(0,int(u/2)):
            T = z0[t]
            z0[t] = 2*T - T**2     # upper channel
            z0[int(u/2)+t] = T**2  # lower channel
        
    # sort into increasing order
    idx = np.argsort(z0)
        
    # select k best channels
    idx = np.sort(bitrevorder(idx[0:k]))
    
    A = np.zeros(N, dtype=bool)
    A[idx] = True
        
    return A

def polar_transform_iter(u):

    N = len(u)
    n = 1
    x = np.copy(u)
    stages = np.log2(N).astype(int)
    for s in range(0,stages):
        i = 0
        while i < N:
            for j in range(0,n):
                idx = i+j
                x[idx] = x[idx] ^ x[idx+n]
            i=i+2*n
        n=2*n
    return x

#%% Main NN

def main(k,N,nb_epoch,code,design,batch_size,LLR,optimizer,loss,train_sigma):
    
    # Define modulator
    modulator_layers = [Lambda(modulateBPSK, 
                              input_shape=(N,), output_shape=return_output_shape, name="modulator")]
    modulator = compose_model(modulator_layers)
    modulator.compile(optimizer=optimizer, loss=loss)
    
    # Define noise
    noise_layers = [Lambda(addNoise, arguments={'sigma':train_sigma}, 
                           input_shape=(N,), output_shape=return_output_shape, name="noise")]
    noise = compose_model(noise_layers)
    noise.compile(optimizer=optimizer, loss=loss)
    
    # Define LLR
    llr_layers = [Lambda(log_likelihood_ratio, arguments={'sigma':train_sigma}, 
                         input_shape=(N,), output_shape=return_output_shape, name="LLR")]
    llr = compose_model(llr_layers)
    llr.compile(optimizer=optimizer, loss=loss)
    
    # Define decoder 
    decoder_layers = [Dense(design[0], activation='relu', input_shape=(N,))]
    for i in range(1,len(design)):
        decoder_layers.append(Dense(design[i], activation='relu'))
    decoder_layers.append(Dense(k, activation='sigmoid'))
    decoder = compose_model(decoder_layers)
    decoder.compile(optimizer=optimizer, loss=loss, metrics=[errors])
    
    # Define model
    if LLR:
        model_layers = modulator_layers + noise_layers + llr_layers + decoder_layers
    else:
        model_layers = modulator_layers + noise_layers + decoder_layers
    model = compose_model(model_layers)
    model.compile(optimizer=optimizer, loss=loss, metrics=[ber])
    
    
    #
    
    # Create all possible information words
    d = np.zeros((2**k,k),dtype=bool)
    for i in range(1,2**k):
        d[i]= inc_bool(d[i-1])
    
    # Create sets of all possible codewords (codebook)
    if code == 'polar':   
        
        A = polar_design_awgn(N, k, design_snr_dB=0)  # logical vector indicating the nonfrozen bit locations 
        x = np.zeros((2**k, N),dtype=bool)
        u = np.zeros((2**k, N),dtype=bool)
        u[:,A] = d
    
        for i in range(0,2**k):
            x[i] = polar_transform_iter(u[i])
    
    elif code == 'random':
        
        np.random.seed(4267)   # for a 16bit Random Code (r=0.5) with Hamming distance >= 2
        x = np.random.randint(0,2,size=(2**k,N), dtype=bool)
    
    #   
    model.summary()
    history = model.fit(x, d, batch_size=batch_size, epochs=nb_epoch, verbose=1, shuffle=True)
    
    # 
    
    test_batch = 1000  
    num_words = 100000      # multiple of test_batch
    
    SNR_dB_start_Eb = 0
    SNR_dB_stop_Eb = 7
    SNR_points = 8
    
    # BER calcul
    
    SNR_dB_start_Es = SNR_dB_start_Eb + 10*np.log10(k/N)
    SNR_dB_stop_Es = SNR_dB_stop_Eb + 10*np.log10(k/N)
    
    sigma_start = np.sqrt(1/(2*10**(SNR_dB_start_Es/10)))
    sigma_stop = np.sqrt(1/(2*10**(SNR_dB_stop_Es/10)))
    
    sigmas = np.linspace(sigma_start, sigma_stop, SNR_points)
    
    nb_errors = np.zeros(len(sigmas),dtype=int)
    nb_bits = np.zeros(len(sigmas),dtype=int)
    
    for i in range(0,len(sigmas)):
    
        for ii in range(0,np.round(num_words/test_batch).astype(int)):
            
            # Source
            np.random.seed(0)
            d_test = np.random.randint(0,2,size=(test_batch,k),dtype = bool) 
            # # Assuming d_test is initially boolean
            # d_test = d_test.astype(np.float32)  # Convert boolean labels to float32 before evaluation
    
            # Encoder
            if code == 'polar':
                x_test = np.zeros((test_batch, N),dtype=bool)
                u_test = np.zeros((test_batch, N),dtype=bool)
                u_test[:,A] = d_test
    
                for iii in range(0,test_batch):
                    x_test[iii] = polar_transform_iter(u_test[iii])
    
            elif code == 'random':
                x_test = np.zeros((test_batch, N),dtype=bool)
                for iii in range(0,test_batch):
                    x_test[iii] = x[bin2int(d_test[iii])]
    
            # Modulator (BPSK)
            s_test = -2*x_test + 1
    
            # Channel (AWGN)
            y_test = s_test + sigmas[i]*np.random.standard_normal(s_test.shape)
    
            if LLR:
                y_test = 2*y_test/(sigmas[i]**2)
                
            # Decoder
            nb_errors[i] += decoder.evaluate(y_test, d_test, batch_size=test_batch, verbose=0)[1]
            nb_bits[i] += d_test.size
            
            #print(i, '/', len(sigmas)-1)
            #print(ii, '/', np.round(num_words/test_batch).astype(int)-1)
    return sigmas, nb_errors, nb_bits

#%% MAP

Eb_N0_dB = np.arange(0, 9, 1) 
Eb_N0_lin = 10**(Eb_N0_dB / 10)  

def simulate_awgn_ber(Eb_N0):
    
    N = 1000000 # nbr bits
    bits = np.random.randint(0, 2, N) # random bits
    symbols = 2 * bits - 1 # mapping: 0 -> -1, 1 -> 1
    
    ber_simulated = np.zeros(len(Eb_N0))
    
    for i, Eb_N0_element in enumerate(Eb_N0):
        
        sigma = np.sqrt(1 / (2 * Eb_N0_element)) #variance
        
        noise = np.random.normal(0, sigma, N) #Génération de AWGN 
        
        signal_bruit = symbols + noise # signal reçu
        
        signal_bruit_det = np.where(signal_bruit >= 0, 1, 0) # threshold at 0
        
        errors = np.sum(bits != signal_bruit_det) # Mise à jour du compteur
        
        ber_simulated[i] = errors / N # Calcul BER

    return ber_simulated

def theoretical_ber(Eb_N0_lin):
    return 0.5 * erfc(np.sqrt(Eb_N0_lin))

#%% MAP coding polar

k = 8
N = 16
G = np.array([[1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
              [1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
              [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
              [1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0],
              [1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0],
              [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
              [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
              [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]])

Eb_N0_dB = np.arange(0, 8, 1)  # Eb/N0 en dB
Eb_N0_lin = 10**(Eb_N0_dB / 10)  # Eb/N0 en linéaire

# Fonction pour encoder les bits selon la matrice G
def encode_bits(bits, G):
    
    encodebits = np.dot(bits, G) % 2
    return encodebits

def decode_bits(decoded, G, k, all_possible_bits, symbols_codewords):

    # Calcul de la distance de Hamming depuis les bits décodés reçus
    distance = np.sum(((decoded-symbols_codewords)**2),axis=1)**(1/2)
        
    closest_codeword = all_possible_bits[np.argmin(distance)]
    return closest_codeword

# Fonction to simulate the BER for the given coding scheme
def simulate_coded_ber(Eb_N0_lin, k, N, G):  
     
    ber_simulated = np.zeros_like(Eb_N0_dB, dtype=float)
    
    # Génération de tous les codewords possible
    all_possible_bits = np.array(list(itertools.product([0, 1], repeat=k)))
    all_possible_codewords = encode_bits(all_possible_bits, G)
    symbols_codewords = 2 * all_possible_codewords - 1
    
    for idx in range(len(Eb_N0_lin)):
        
        sigma = np.sqrt(1 / (Eb_N0_lin[idx])) # Variance
        total_errors = 0
        compteur = 0
        
        while total_errors<700:
            
            # Generation de bits randoms
            bits = np.random.randint(0, 2, k)
            
            # Encodage des bits
            encoded_bits = encode_bits(bits, G)
            
            # BPSK modulation
            symbols = 2 * encoded_bits - 1 # mapping: 0 -> -1, 1 -> 1
            
            # AWGN channel
            noise = np.random.normal(0, sigma, N)
            received = symbols + noise
            
            # hard-decision decoding
            estimated_bits = decode_bits(received, G, k, all_possible_bits, symbols_codewords)  
            
            # Update du compteur d'erreur
            total_errors += np.sum(bits != estimated_bits)
            compteur+=1
            print(total_errors)
            print(idx+1, "/",8)
            
        # Calcul du BER 
        ber_simulated[idx] = total_errors / (compteur*k)
        
        print(idx+1, "/",8)
    
    return ber_simulated

start = time.time()

ber_results = simulate_coded_ber(Eb_N0_lin, k, N, G)

end = time.time()
print('durée ',end-start)

ber_simulated = simulate_awgn_ber(Eb_N0_lin)
ber_theoretical = theoretical_ber(Eb_N0_lin)

#%% Initialisation

k = 8                       # number of information bits
N = 16                      # code length
train_SNR_Eb = 1            # training-Eb/No

nb_epoch = np.array([2**10,2**12,2**14,2**16,2**18])         # number of learning epochs
code = 'polar'              # type of code ('random' or 'polar')
design = [128, 64, 32]      # each list entry defines the number of nodes in a layer
batch_size = 256            # size of batches for calculation the gradient
LLR = False                 # 'True' enables the log-likelihood-ratio layer
optimizer = 'adam'           
loss = 'mse'                # or 'binary_crossentropy'

train_SNR_Es = train_SNR_Eb + 10*np.log10(k/N)
train_sigma = np.sqrt(1/(2*10**(train_SNR_Es/10)))

sigmas_history_mse_direct = np.zeros((k,np.size(nb_epoch,0)))
nb_errors_history_mse_direct = np.zeros((k,np.size(nb_epoch,0)))
nb_bits_history_mse_direct = np.zeros((k,np.size(nb_epoch,0)))

sigmas_history_mse_LLR = np.zeros((k,np.size(nb_epoch,0)))
nb_errors_history_mse_LLR = np.zeros((k,np.size(nb_epoch,0)))
nb_bits_history_mse_LLR = np.zeros((k,np.size(nb_epoch,0)))

sigmas_history_bc_direct = np.zeros((k,np.size(nb_epoch,0)))
nb_errors_history_bc_direct = np.zeros((k,np.size(nb_epoch,0)))
nb_bits_history_bc_direct = np.zeros((k,np.size(nb_epoch,0)))

sigmas_history_bc_LLR = np.zeros((k,np.size(nb_epoch,0)))
nb_errors_history_bc_LLR = np.zeros((k,np.size(nb_epoch,0)))
nb_bits_history_bc_LLR = np.zeros((k,np.size(nb_epoch,0)))

NVE_history_mse_direct = np.zeros((k,np.size(nb_epoch,0)))
NVE_history_mse_LLR = np.zeros((k,np.size(nb_epoch,0)))
NVE_history_bc_direct = np.zeros((k,np.size(nb_epoch,0)))
NVE_history_bc_LLR = np.zeros((k,np.size(nb_epoch,0)))

sigmas_history_mse_direct_design_2 = np.zeros((k,np.size(nb_epoch,0)))
nb_errors_history_mse_direct_design_2 = np.zeros((k,np.size(nb_epoch,0)))
nb_bits_history_mse_direct_design_2 = np.zeros((k,np.size(nb_epoch,0)))

sigmas_history_mse_direct_design_3 = np.zeros((k,np.size(nb_epoch,0)))
nb_errors_history_mse_direct_design_3 = np.zeros((k,np.size(nb_epoch,0)))
nb_bits_history_mse_direct_design_3 = np.zeros((k,np.size(nb_epoch,0)))

sigmas_history_mse_direct_design_4 = np.zeros((k,np.size(nb_epoch,0)))
nb_errors_history_mse_direct_design_4 = np.zeros((k,np.size(nb_epoch,0)))
nb_bits_history_mse_direct_design_4 = np.zeros((k,np.size(nb_epoch,0)))

NVE_history_design_2 = np.zeros((k,np.size(nb_epoch,0)))
NVE_history_design_3 = np.zeros((k,np.size(nb_epoch,0)))
NVE_history_design_4 = np.zeros((k,np.size(nb_epoch,0)))

#%% Graphiques
#%%% BER 

for i in range(np.size(nb_epoch,0)):
    
    sigmas_history_mse_direct[:,i], nb_errors_history_mse_direct[:,i], nb_bits_history_mse_direct[:,i] = main(k,N,nb_epoch[i],code,design,batch_size,LLR,optimizer,loss,train_sigma)
    sigmas_history_mse_direct_design_2[:,i], nb_errors_history_mse_direct_design_2[:,i], nb_bits_history_mse_direct_design_2[:,i] = main(k,N,nb_epoch[i],code,[256,128,64],batch_size,LLR,optimizer,loss,train_sigma)
    sigmas_history_mse_direct_design_3[:,i], nb_errors_history_mse_direct_design_3[:,i], nb_bits_history_mse_direct_design_3[:,i] = main(k,N,nb_epoch[i],code,[512,256,128],batch_size,LLR,optimizer,loss,train_sigma)
    sigmas_history_mse_direct_design_4[:,i], nb_errors_history_mse_direct_design_4[:,i], nb_bits_history_mse_direct_design_4[:,i] = main(k,N,nb_epoch[i],code,[1024,512,256],batch_size,LLR,optimizer,loss,train_sigma)

    sigmas_history_mse_LLR[:,i], nb_errors_history_mse_LLR[:,i], nb_bits_history_mse_LLR[:,i] = main(k,N,nb_epoch[i],code,design,batch_size,True,optimizer,loss,train_sigma)
    
    sigmas_history_bc_direct[:,i], nb_errors_history_bc_direct[:,i], nb_bits_history_bc_direct[:,i] = main(k,N,nb_epoch[i],code,design,batch_size,LLR,optimizer,'binary_crossentropy',train_sigma)

    sigmas_history_bc_LLR[:,i], nb_errors_history_bc_LLR[:,i], nb_bits_history_bc_LLR[:,i] = main(k,N,nb_epoch[i],code,design,batch_size,True,optimizer,'binary_crossentropy',train_sigma)
    
    
#%%%% BER polar mse direct channel

plt.figure(figsize=(10, 6))

for i in range(np.size(nb_epoch,0)):
    plt.plot(10*np.log10(1/(2*sigmas_history_mse_direct[:,i]**2)) - 10*np.log10(k/N), nb_errors_history_mse_direct[:,i]/nb_bits_history_mse_direct[:,i],'o-', label=r'$M_{{ep}} = 2^{{{}}}$'.format(int(np.log2(nb_epoch[i]))))
    
plt.plot(Eb_N0_dB, ber_simulated, 'o-', label='Simulated BER')
plt.plot(Eb_N0_dB, ber_theoretical, 'o-', label='Theoretical BER')
plt.plot(Eb_N0_dB, ber_results, '--', label='Simulated BER with Coding')
plt.yscale('log')
plt.xlabel('Eb/N0 (dB)')
plt.ylabel('Bit Error Rate')
plt.title('Influence of the number of epochs Mep on the BER of a 128-64-32 NN, MSE, direct channel for 16 bit-length codes with code rate r = 0.5 and polar code.')
plt.legend()
plt.grid(True)
plt.show()

#%%%% BER polar mse LLR

plt.figure(figsize=(10, 6))

for i in range(np.size(nb_epoch,0)):
    plt.plot(10*np.log10(1/(2*sigmas_history_mse_LLR[:,i]**2)) - 10*np.log10(k/N), nb_errors_history_mse_LLR[:,i]/nb_bits_history_mse_LLR[:,i],'o-', label=r'$M_{{ep}} = 2^{{{}}}$'.format(int(np.log2(nb_epoch[i]))))
    
plt.plot(Eb_N0_dB, ber_simulated, 'o-', label='Simulated BER')
plt.plot(Eb_N0_dB, ber_theoretical, 'o-', label='Theoretical BER')
plt.plot(Eb_N0_dB, ber_results, '--', label='Simulated BER with Coding')
plt.yscale('log')
plt.xlabel('Eb/N0 (dB)')
plt.ylabel('Bit Error Rate')
plt.title('Influence of the number of epochs Mep on the BER of a 128-64-32 NN, MSE, LLR channel for 16 bit-length codes with code rate r = 0.5 and polar code.')
plt.legend()
plt.grid(True)
plt.show()

#%%%% BER polar binary crossentropy direct channel

plt.figure(figsize=(10, 6))

for i in range(np.size(nb_epoch,0)):
    plt.plot(10*np.log10(1/(2*sigmas_history_bc_direct[:,i]**2)) - 10*np.log10(k/N), nb_errors_history_bc_direct[:,i]/nb_bits_history_bc_direct[:,i],'o-', label=r'$M_{{ep}} = 2^{{{}}}$'.format(int(np.log2(nb_epoch[i]))))
    
plt.plot(Eb_N0_dB, ber_simulated, 'o-', label='Simulated BER')
plt.plot(Eb_N0_dB, ber_theoretical, 'o-', label='Theoretical BER')
plt.plot(Eb_N0_dB, ber_results, '--', label='Simulated BER with Coding')
plt.yscale('log')
plt.xlabel('Eb/N0 (dB)')
plt.ylabel('Bit Error Rate')
plt.title('Influence of the number of epochs Mep on the BER of a 128-64-32 NN, BCE, direct channel for 16 bit-length codes with code rate r = 0.5 and polar code.')
plt.legend()
plt.grid(True)
plt.show()

#%%%% BER polar binary crossentropy LLR

plt.figure(figsize=(10, 6))

for i in range(np.size(nb_epoch,0)):
    plt.plot(10*np.log10(1/(2*sigmas_history_bc_LLR[:,i]**2)) - 10*np.log10(k/N), nb_errors_history_bc_LLR[:,i]/nb_bits_history_bc_LLR[:,i],'o-', label=r'$M_{{ep}} = 2^{{{}}}$'.format(int(np.log2(nb_epoch[i]))))
    
plt.plot(Eb_N0_dB, ber_simulated, 'o-', label='Simulated BER')
plt.plot(Eb_N0_dB, ber_theoretical, 'o-', label='Theoretical BER')
plt.plot(Eb_N0_dB, ber_results, '--', label='Simulated BER with Coding')
plt.yscale('log')
plt.xlabel('Eb/N0 (dB)')
plt.ylabel('Bit Error Rate')
plt.title('Influence of the number of epochs Mep on the BER of a 128-64-32 NN, BCE, LLR channel for 16 bit-length codes with code rate r = 0.5 and polar code.')
plt.legend()
plt.grid(True)
plt.show()

#%%% NVE

NVE_history_mse_direct = np.zeros((k,np.size(nb_epoch,0)))
NVE_history_mse_LLR = np.zeros((k,np.size(nb_epoch,0)))
NVE_history_bc_direct = np.zeros((k,np.size(nb_epoch,0)))
NVE_history_bc_LLR = np.zeros((k,np.size(nb_epoch,0)))

NVE_history_design_2 = np.zeros((k,np.size(nb_epoch,0)))
NVE_history_design_3 = np.zeros((k,np.size(nb_epoch,0)))
NVE_history_design_4 = np.zeros((k,np.size(nb_epoch,0)))

for i in range(np.size(nb_epoch,0)):
    
    NVE_history_mse_direct[:,i] = (nb_errors_history_mse_direct[:,i]/nb_bits_history_mse_direct[:,i])/ber_results
    NVE_history_design_2[:,i] = (nb_errors_history_mse_direct_design_2[:,i]/nb_bits_history_mse_direct_design_2[:,i])/ber_results
    NVE_history_design_3[:,i] = (nb_errors_history_mse_direct_design_3[:,i]/nb_bits_history_mse_direct_design_3[:,i])/ber_results
    NVE_history_design_4[:,i] = (nb_errors_history_mse_direct_design_4[:,i]/nb_bits_history_mse_direct_design_4[:,i])/ber_results

    NVE_history_mse_LLR[:,i] = (nb_errors_history_mse_LLR[:,i]/nb_bits_history_mse_LLR[:,i])/ber_results
    
    NVE_history_bc_direct[:,i] = (nb_errors_history_bc_direct[:,i]/nb_bits_history_bc_direct[:,i])/ber_results
    
    NVE_history_bc_LLR[:,i] = (nb_errors_history_bc_LLR[:,i]/nb_bits_history_bc_LLR[:,i])/ber_results

NVE_history_mse_direct = np.sum(NVE_history_mse_direct,axis=0)

NVE_history_design_2 = np.sum(NVE_history_design_2,axis = 0)
NVE_history_design_3 = np.sum(NVE_history_design_3,axis = 0)
NVE_history_design_4 = np.sum(NVE_history_design_4,axis = 0)

NVE_history_mse_LLR = np.sum(NVE_history_mse_LLR, axis = 0)
NVE_history_bc_direct = np.sum(NVE_history_bc_direct, axis = 0)
NVE_history_bc_LLR = np.sum(NVE_history_bc_LLR, axis = 0)

#%%%% NVE MSE Vs BCE and direct Vs LLR 

plt.figure(figsize=(10, 6))

legend_lines = [
    Line2D([0], [0], color='g', label='Direct channel'),
    Line2D([0], [0], color='b', label='Channel LLR'),
    Line2D([0], [0], color='k', linestyle='-', label='MSE'),
    Line2D([0], [0], color='k', linestyle='--', label='BCE')
]

plt.plot(nb_epoch, NVE_history_mse_direct, 'go-')
plt.plot(nb_epoch, NVE_history_mse_LLR, 'bo-')
plt.plot(nb_epoch, NVE_history_bc_direct, 'go--')
plt.plot(nb_epoch, NVE_history_bc_LLR, 'bo--')
plt.xscale('log', base = 2)
plt.xlabel(r'Training epochs $M_{{ep}}$')
plt.ylabel('NVE')
plt.title('Learning curve for 16 bit-length codes with code rat r = 0.5 and polar code for a 128-64-32 NN')
plt.legend(handles=legend_lines, loc='best')

#%%%% NVE MSE design analysis

plt.figure(figsize=(10, 6))

legend_lines = [
    Line2D([0], [0], color='g', linestyle='-', marker='o', label='128-64-32'),
    Line2D([0], [0], color='b', linestyle='-', marker='d', label='256-128-64'),
    Line2D([0], [0], color='m', linestyle='-', marker='^', label='512-256-128'),
    Line2D([0], [0], color='r', linestyle='-', marker='s', label='1024-512-256'),
]

plt.plot(nb_epoch, NVE_history_mse_direct, 'go-')
plt.plot(nb_epoch, NVE_history_design_2, 'bd-')
plt.plot(nb_epoch, NVE_history_design_3, 'm^-')
plt.plot(nb_epoch, NVE_history_design_4, 'rs-')
plt.xscale('log', base = 2)
plt.xlabel(r'Training epochs $M_{{ep}}$')
plt.ylabel('NVE')
plt.title('Learning curve for different NN sizes for 16 bit-length Training epochs Mep codes with code rate r = 0.5 and polar code')
plt.legend(handles=legend_lines, loc='best')
