## Index

```@index
```

## Layers

### Operator convolutional layer

```math
F(s) = \mathcal{F} \{ v(x) \} \\
F'(s) = g(F(s)) \\
v'(x) = \mathcal{F}^{-1} \{ F'(s) \}
```

where ``v(x)`` and ``v'(x)`` denotes input and output function,
``\mathcal{F} \{ \cdot \}``, ``\mathcal{F}^{-1} \{ \cdot \}`` are Fourier transform, inverse Fourier transform, respectively.
Function ``g`` is a linear transform for lowering Fouier modes.

```@docs
OperatorConv
```

Reference: [Fourier Neural Operator for Parametric Partial Differential Equations](https://arxiv.org/abs/2010.08895)

---

### Operator kernel layer

```math
v_{t+1}(x) = \sigma(W v_t(x) + \mathcal{K} \{ v_t(x) \} )
```

where ``v_t(x)`` is the input function for ``t``-th layer and ``\mathcal{K} \{ \cdot \}`` denotes spectral convolutional layer.
Activation function ``\sigma`` can be arbitrary non-linear function.

```@docs
OperatorKernel
```

Reference: [Fourier Neural Operator for Parametric Partial Differential Equations](https://arxiv.org/abs/2010.08895)

## Models

### Fourier neural operator

```@docs
FourierNeuralOperator
```

Reference: [Fourier Neural Operator for Parametric Partial Differential Equations](https://arxiv.org/abs/2010.08895)

---

### Markov neural operator

```@docs
MarkovNeuralOperator
```

Reference: [Markov Neural Operators for Learning Chaotic Systems](https://arxiv.org/abs/2106.06898)
