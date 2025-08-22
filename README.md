# MCMC-KillingRates

A minimal, end-to-end Bayesian workflow for quantifying **NK cell–mediated cytotoxicity**.  
We posit a simple Poisson killing model per NK cell, then infer killing **rates** with MCMC (PyMC).  
Two likelihoods are implemented:

1) **Per-cell Poisson** (uses raw per-cell kill counts).  
2) **Histogram/Multinomial** (uses a single replicate-level histogram with a tail bin).

Both yield posteriors for the **per-time rate** \( r \) for each experimental condition.

---

## Mathematical model

Over an observation window of duration $$T$$, each NK cell kills targets at rate $$r$$ (kills per unit time).  
Let $$\lambda = r\,T$$ be the expected number of kills **per cell** during $$T$$.

Per cell,

$$
N \sim \mathrm{Poisson}(\lambda), \qquad
\Pr(N=k \mid \lambda) = e^{-\lambda}\frac{\lambda^k}{k!}
$$

### Replicate as a histogram (Multinomial likelihood)

In one replicate, suppose we observe **$$M$$** NK cells.  
Let $$K_k$$ be the number of NK cells that killed exactly $$k$$ targets. Then:

$$
\sum_{k=0}^{\infty} K_k = M, \qquad
\mathbf{K} = (K_0,K_1,\dots) \sim \mathrm{Multinomial}\left(M,\, \mathbf{p}(\lambda)\right)
$$

with category probabilities

$$
p_k(\lambda) = \Pr(N=k\mid\lambda) = e^{-\lambda}\frac{\lambda^k}{k!}
$$

**Practical truncation (tail bin).**  
To avoid infinite categories, choose a cutoff $$K_\star$$.  
Model the explicit categories $$k=0,1,\dots,K_\star-1$$ and collect all higher counts in a **tail**:

$$
p_{\ge K_\star}(\lambda) = 1 - \sum_{k=0}^{K_\star-1} p_k(\lambda)
$$

Define

$$
\tilde{\mathbf{K}} = (K_0, \dots, K_{K_\star - 1}, K_{\ge K_\star}), \quad
\tilde{\mathbf{p}} = \left(p_0(\lambda), \dots, p_{K_\star - 1}(\lambda), p_{\ge K_\star}(\lambda)\right)
$$

Then

$$
\tilde{\mathbf{K}} \sim \mathrm{Multinomial}(M, \tilde{\mathbf{p}})
$$

> **Why Multinomial, not many Binomials?**  
> The counts $$K_k$$ are **not independent** across $$k$$; they are jointly Multinomial given $$M$$ and $$\lambda$$.  
> Fitting separate Binomials would double-count information.

---

## Prior

We put a weakly informative prior on $$\lambda$$ via its log-10:

$$
\eta = \log_{10}\lambda \sim \mathrm{Uniform}(a, b)
\quad\Rightarrow\quad \lambda = 10^{\eta},\quad r = \frac{\lambda}{T}
$$

---
