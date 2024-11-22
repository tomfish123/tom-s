# Study-of-On-Deep-Learning-Based-Channel-Decoding
This project is a school study of the article On Deep Learning-Based Channel Decoding writed by Tobias Gruber, Sebastian Cammerer, Jakob Hoydis, and Stephan ten Brink

**Channel Coding and Complexity Reduction in Digital Communication Chains Using Neural Networks**

## Overview

This project introduces channel coding for digital communication chains and leverages neural networks to reduce complexity in the reception chain. The work draws significant inspiration from the following article:

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

## Requirements

- Python 3.x
- Libraries:
  - `numpy`
  - `matplotlib`
  - `tensorflow`
  - `keras`

## Installation

Install the required packages with:

```bash
pip install numpy matplotlib tensorflow keras
```

## Project Structure

- **Modulation and Noise Addition**: The notebook begins by defining functions to modulate signals (BPSK modulation) and to add noise.
- **Neural Network Model**: A neural network model is defined to simulate the reception chain and reduce complexity in channel decoding.
- **Performance Evaluation**: The model's performance is assessed by calculating the Bit Error Rate (BER).

## Usage

1. Clone the repository and open the notebook.
2. Run each cell to load the necessary functions, train the model, and evaluate its performance.
3. Modify parameters in the code as necessary to experiment with different configurations.

## Project Goals

The ultimate objective is to explore ways in which neural networks can simplify and improve the accuracy of digital communication decoding processes, especially by reducing the traditional complexity in the reception chain.
