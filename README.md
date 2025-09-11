# Fish --  A simple Bayesion inference workflow for quantifying the NK cell killing efficiency

This mini-project investigates ***NK cell–mediated cytotoxicity*** through a Bayesian inference workflow. Our goal is to quantitatively characterise NK cell killing efficiency by fitting a mathematical model to experimental data. Specifically, we model the number of tumour cells killed per NK cell under varying conditions—such as treatment with antibodies or drugs—and use the posterior distribution to infer differences in cytotoxic activity. This approach not only enables statistical comparison across conditions but also allows us to evaluate the adequacy of the proposed mathematical model by comparing posterior predictions with experimental observations. Ultimately, this modelling framework serves both as a tool for hypothesis testing and as a means to uncover potential biological mechanisms underlying NK cell function. 

The project is named *Fish* as a nod to the **Poisson distribution** used in the model—*Poisson* being French for "fish"—and metaphorically, to represent the process of "fishing out" hidden mechanisms from biological data using mathematical insight.

---

## Mathematical Model

<span style="color:blue;"> We model NK cell–mediated cytotoxicity as a Poisson process, under the assumption that each NK cell kills tumour cells independently at a constant rate $r$ (kills per unit time). This implies that, over a fixed observation window of duration $T$, the number of target cells killed by an individual NK cell follows a Poisson distribution with mean $\lambda = r \cdot T$. </span>

That is, for each cell, the number of kills $N$ satisfies:

$$
N \sim \mathrm{Poisson}(\lambda), \qquad
\Pr(N = k \mid \lambda) = e^{-\lambda} \frac{\lambda^k}{k!}
$$

In a single experimental replicate, suppose we observe $M$ NK cells. Let $K_k$ denote the number of cells that killed exactly $k$ targets. Then the histogram of kill counts across the population, $\mathbf{K} = (K_0, K_1, \dots)$, follows a **Multinomial distribution** with total count $M$ and category probabilities $\mathbf{p}(\lambda) = (p_0(\lambda), p_1(\lambda), \dots)$, where:

$$
p_k(\lambda) = \Pr(N = k \mid \lambda) = e^{-\lambda} \frac{\lambda^k}{k!}
$$

To make the model computationally practical, we truncate the histogram at a cutoff $K_\star$. Instead of modelling an infinite number of categories, we consider explicit bins for $k = 0, 1, \dots, K_\star - 1$, and pool all higher counts into a single **tail bin**. The probability mass of this tail is given by:

$$
p_{\ge K_\star}(\lambda) = 1 - \sum_{k = 0}^{K_\star - 1} p_k(\lambda)
$$

We then define the truncated histogram as $\tilde{\mathbf{K}} = (K_0, \dots, K_{K_\star - 1}, K_{\ge K_\star})$, with corresponding probabilities $\tilde{\mathbf{p}} = (p_0(\lambda), \dots, p_{K_\star - 1}(\lambda), p_{\ge K_\star}(\lambda))$, and model:

$$
\tilde{\mathbf{K}} \sim \mathrm{Multinomial}(M, \tilde{\mathbf{p}})
$$

> **Why a Multinomial rather than separate Binomials?**  
> The counts $K_k$ are not independent across $k$. Given the total number of observed NK cells $M$, the joint distribution of all category counts is Multinomial. Modelling them as independent Binomial distributions would overestimate the information content and violate the constraint that $\sum_k K_k = M$.


