### Validity and Definability

Temporal logicians are generally not so much interested in the truth or falsity of formulas in specific models, but rather in those formulas that remain true throughout the flow of time even if we change the valuation. It is felt that such formulas provide essential information concerning the structure of the underlying flow of time. Formally, we say that a formula $\varphi$ is *valid* on a flow of time $\mathcal{T}$, notation: $\mathcal{T} \Vdash \varphi$, if for every valuation $\pi$ on $\mathcal{T}$, and every point of $\mathcal{T}$, we have $(\mathcal{T}, \pi), t \Vdash \varphi$. A formula is valid in a class of flows of time if it is valid on each member of the class. The notion of satisfiability is defined dually: we say that a formula $\varphi$ is *satisfiable* in a flow of time (a class of flows of time) if its negation is not valid on the flow of time (in the class of flows of time, respectively).

As an example, we show that the formula $Fq \to FFq$ is valid on the class of dense linear orderings. Assume that $\mathcal{T}$ is a dense linear flow of time; in order to show that $Fq \to FFq$ holds on it, consider an arbitrary valuation $\pi$ on $\mathcal{T}$, and an arbitrary point $t$ in $\mathcal{T}$ such that $(\mathcal{T}, \pi), t \Vdash Fq$. By the truth definition, there is a later point $s$ where $q$ holds. But by density, there must be some point $u$ between $t$ and $s$; from $u < s$ we derive that $Fq$ holds at $u$; but then from $t < u$ we may infer that $FFq$ holds at $t$; since $t$ and $\pi$ were arbitrary, this suffices to show that $\mathcal{T} \Vdash Fq \to FFq$.

On the other hand, it is easy to see that the formula $Fq \to FFq$ is not valid on the ordering of the integers. For, take the points 0 and 1 and consider the valuation $\pi$ that makes $q$ true *only* at 1; then obviously, $Fq$ is true at 0; but since there is no integer number between 0 and 1, the formula $FFq$ cannot be true at 0. This shows that indeed $\mathcal{Z} \nVdash Fq \to FFq$. We can in fact generalize this argument to show that the formula $Fq \to FFq$ can be falsified on *every* non-dense frame. For, any non-dense frame must contain two points $s < t$ without intermediate points; so the valuation making $q$ true only at $t$ will make the formula $Fq \to FFq$ false at $s$. Hence, the formula $Fq \to FFq$ is very informative; it is a reliable witness of the density of a flow of time.

In general, we say that a Priorean formula $\varphi$ *defines* a class $\mathsf{C}$ of flows of time within a class $\mathsf{K}$ if for every flow of time $\mathcal{T}$ in $\mathsf{K}$, $\mathcal{T} \Vdash \varphi$ iff $\mathcal{T}$ belongs to $\mathsf{C}$. If $\mathsf{C}$ is given as the class of frames satisfying some first order property $\alpha$, we also say that $\varphi$ *corresponds* to $\alpha$ (within $\mathsf{K}$). For instance, we have just seen that the formula $Fq \to FFq$ corresponds to density.

Not every property of flows of time is definable; for instance, we can prove that there is no Priorean formula that defines the class of branching flows of time. On the other hand, there is a formula defining the flows of time that are *not* branching; for, the formula $PFq \to (Pq \lor q \lor Fq)$ corresponds to non-branchingness to the future. Hence, the conjunction of this formula and its mirror image defines the flows of time that are not branching.

Especially if we confine ourselves to linear orderings, many interesting properties of flows of time *can* be defined in the Priorean language. The following table lists a number of such correspondences holding for linear flows of time; here $\Diamond\varphi$ abbreviates $P\varphi \lor \varphi \lor F\varphi$, and $\Box\varphi \equiv H\varphi \land \varphi \land G\varphi$. For future reference, we have given names to the modal formulas.

| Property | Formula | Label |
|---|---|---|
| having a first point | $H\bot \lor PH\bot$ | (A1) |
| left-seriality | $P\top$ | (A2) |
| having a final point | $G\bot \lor FG\bot$ | (A3) |
| right-seriality | $F\top$ | (A4) |
| discreteness | $(F\top \land q \land Hq) \to FHq$ | (A5) |
| density | $Fq \to FFq$ | (A6) |
| continuity | $(Fq \land \Diamond\lnot q \land \Box(q \to Hq)) \to \Diamond((q \land G\lnot q) \lor (\lnot q \land Hq))$ | (A7) |
| having finite intervals | $G(Gq \to q) \to (FGq \to Gq) \land H(Hq \to q) \to (PHq \to Hq)$ | (A8) |

Finally, since Priorean formulas may be interpreted on *all* frames (also ones that are not strictly partial orders), the question naturally arises whether the class of flows of time itself is definable. Since, analogous to the case of ordinary modal logic, transitivity may be defined by the formula $Gp \to GGp$, this boils down to the problem of finding a correspondent for irreflexivity (within the class of transitive frames). Unfortunately, there is *no* such formula.

### Axiomatics

As we mentioned already, temporal logic starts with flows of time; but obviously, this does not diminish the interest in finding complete calculi for various classes of flows of time. Obviously, there are close connections with the axiomatics of alethic modal logic as discussed in Chapter 7. In particular, analogous to $\mathbf{K}$, there is a *minimal tense logic* for the Priorean language as well; it is called $\mathbf{K}_t$ and defined as the smallest class of Priorean formulas that is closed under the following axioms and derivation rules:

| Label | Axiom/Rule |
|---|---|
| $(CT)$ | all classical propositional tautologies |
| $(DB)$ | $G(q \to r) \to (Gq \to Gr)$ |
| | $H(q \to r) \to (Hq \to Hr)$ &emsp; (Distribution) |
| $(CV)$ | $q \to GPq$ |
| | $q \to HFq$ &emsp; (Converse) |
| $(4)$ | $Gq \to GGq$ &emsp; (Transitivity) |
| $(US)$ | if $\varphi$ is a theorem, then so is $\varphi[\psi/q]$ &emsp; (Uniform Substitution) |
| $(MP)$ | if $\varphi$ and $\varphi \to \psi$ are theorems, then so is $\psi$ &emsp; (Modus Ponens) |
| $(TG)$ | if $\varphi$ is a theorem, then so are $G\varphi$ and $H\varphi$ &emsp; (Temporal Generalization) |

Here $\varphi[\psi/q]$ denotes the result of substituting the formula $\psi$ for the propositional variable $q$, uniformly throughout $\varphi$.

Most of these axioms and all of these rules are, perhaps under different names, familiar from ordinary modal logic. The exception is the Converse axiom (CV); as we will see, this axiom is needed to ensure that the accessibility relations for the operators $G$ and $H$ are each other's converse. In the chapter on Modal Logic it is discussed in detail that the formula (4) reflects the transitivity of the intended accessibility relation of a modal operator; thus, our constraints on flows of time explain the presence of (4) as an axiom. Recall that in the previous section we already saw that the property of being irreflexive is not definable in the Priorean language; now we see that irreflexivity does not even yield any extra validities. (This is not the rule in modal logics: frame conditions that are not definable in the modal language may nevertheless *imply* the validity of modal formulas.)

**Theorem 3.1** *The logic $K_t$ is sound and complete with respect to the class of all flows of time.*

For lack of space, we omit the proof of Theorem 3.1. Instead, we concentrate on completeness for the class of linear flows of time. Let **Lin** be the extension of $\mathbf{K}_t$ with the axiom $(NB)$, which is the conjunction of the axiom $PFq \to (Pq \lor q \lor Fq)$ (defining non-branching to the future) and its mirror image $FPq \to (Fq \lor q \lor Pq)$.

**Theorem 3.2** *The logic* **Lin** *is sound and complete with respect to the class of linear flows of time.*

PROOF. Just as the completeness proofs of Chapter 7, our proof method will make use of canonical models. Hence, let $W^c$ be the set of maximal **Lin**-consistent sets of formulas (for unexplained terminology we refer to the modal completeness proof), and define the relation $R^c$ on $W^c$ by $R^c wv$ iff $\varphi \in v$ for all $G\varphi \in w$. The structure $\mathcal{F} = (W^c, R^c)$ is called the *canonical frame*; on it, we define the *canonical valuation* $\pi^c$ so that $\pi^c(q)(w) = 1$ iff $p \in w$.

Our first aim is to prove a Truth Lemma for this model, stating that for all Priorean formulas and every point $w$ of the *canonical model* $\mathcal{M}^c = (\mathcal{F}^c, \pi^c)$ we have that 'truth coincides with membership':

$$
\mathcal{M}^c, w \Vdash \varphi \text{ iff } \varphi \in w.
\tag{2}
$$

Analogous to the proof of Theorem 4 in Chapter 7, (2) is proved by formula induction. There is only one minor problem, caused by the fact that we now have two modal operators, and only one accessibility relation. This is precisely where the Converse axioms come in: they enable us to show that the canonical accessibility relation does not only work well for $G$ but also for $H$. For, we can prove (details are left to the reader) that $R^c wv$ iff $\varphi \in w$ for all $H\varphi \in v$.

Now it follows easily from (2) that every **Lin**-consistent set of formulas is satisfiable in the canonical model, but unlike the case of modal logics like **S4** we are not finished here. We need to satisfy our **Lin**-consistent set of formulas in a linear flow of time. Now it is easy to verify that the canonical accessibility relation is transitive (use the axiom (4), as in the modal completeness proofs); it is not very difficult to show that $R^c$ is not branching (but we leave the details of this proof to the reader --- use the axiom $(NB)$); but it is impossible to prove that $R^c$ is a linear ordering, because in general this will not be true! The main problem is that nothing guarantees irreflexivity of canonical accessibility relation. The difficult part of the proof consists in showing that we can *transform* the canonical frame into a strict linear order, while truth of formulas is preserved.

Let us agree to call a frame $\mathcal{F} = (W, R)$ a *pseudo-line* if $R$ is transitive and strongly connected (that is, satisfying $\forall xy(Rxy \lor x = y \lor Ryx)$). Now given any maximal **Lin**-consistent set $\Sigma$, we may restrict ourselves to the part of the canonical frame that is connected (via $R^c$) to $\Sigma$ and still prove the analogue of the Truth Lemma (2). It thus follows that every consistent formula is satisfiable in a pseudo-line. But then the missing link in the proof of the completeness theorem for **Lin** is the following claim.

(3) If $\varphi$ is satisfiable on a pseudo-line, then also on a linear flow of time.

In order to prove claims like (3), several methods of 'frame surgery' have been developed; in order to give the reader an idea of such techniques, we briefly sketch the *bulldozing* method here. Assume that $\varphi$ is satisfiable in the model $\mathcal{M} = (\mathcal{F}, \pi)$ based on the pseudo-line $\mathcal{F} = (W, R)$. The first observation is that $\mathcal{F}$ may be represented as a linear ordering $\prec$ of so-called *clusters* which are special subsets of $W$. Each point $s$ of $W$ belongs to a unique cluster $C_s$ which is either *degenerate* (consisting of a single irreflexive point) or *proper* (if $R$ is universal on it). The relation $\prec$ is defined such that $C_s \prec C_t$ if and only if $C_s \neq C_t$ and $Rst$.

The key idea is now to 'bulldoze' each proper cluster into a special linear ordering $\mathcal{L}_C$ and to replace each $C$ with $\mathcal{L}_C$. Obviously, replacing each proper cluster with a linearly ordered model yields a linear order; but is $\varphi$ still satisfiable in the new model? To understand the positive answer to this question, note that any proper cluster introduces a infinity of information recurrence in both the forward and backward directions: we can follow paths within $C$, moving either forwards and backwards along $R$, for as long as we please. Thus, when we replace a cluster $C$ with a linear ordering, we must ensure that the linear ordering duplicates all the information in $C$ infinitely often, and in both directions. Bulldozing does precisely this, in the most straightforward way possible. For instance, suppose that the cluster $C$ has three elements only: $s_0$, $s_1$ and $s_2$, with associated classical valuations $\sigma_0$, $\sigma_1$ and $\sigma_2$. Then $\mathcal{L}_C$ is given as the model $(\mathcal{Z}, \pi_C)$; here $\pi_C$ is given by $\pi_C(z) = \sigma_{z \bmod 3}$; that is, $\mathcal{L}_C$ consists of an unbounded (in both directions) series of points with associated classical valuations $\sigma_0$, $\sigma_1$ and $\sigma_2$; as in $\cdots \sigma_1 \sigma_2 \sigma_0 \sigma_1 \sigma_2 \sigma_0 \cdots$.

There is thus an obvious relation linking points in the new, transformed model to points in the old one; using this we may prove that $\varphi$ is indeed satisfiable in the new model. This finishes the proof sketch of (3). QED

Turning to the axiomatics of specific structures, let us define the following logics:

| Logic | Definition |
|---|---|
| **Lin.N** | **Lin** + A1 + A4 + A8 |
| **Lin.Z** | **Lin** + A2 + A4 + A8 |
| **Lin.Q** | **Lin** + A2 + A4 + A6 |
| **Lin.R** | **Lin** + A2 + A4 + A6 + A7 |

For these logics we have the following result.

**Theorem 3.3** *The logics* **Lin.N**, **Lin.Z**, **Lin.Q** *and* **Lin.R** *are sound and complete axiomatizations of the set of validities of the flows of time $\mathcal{N}$, $\mathcal{Z}$, $\mathcal{Q}$ and $\mathcal{R}$, respectively.*

We may conclude that temporal logicians have been rather successful in axiomatizing the standard flows of times and the most natural classes of flows of time. Nevertheless, it would be wrong to conclude that conversely, (axiomatically defined) tense logics are always characterized by a class of flows of time. As in modal logic, incompleteness is the rule; in fact, the very first example of an incomplete (poly-)modal logic was found in tense logic.

### Decidability and Complexity

The completeness theorems that we mentioned in the previous subsection are all very nice, but of course, if one wants to do actual reasoning in one of these logics, further properties are required. Minimally, one wants the logic to be decidable; that is, the existence is required of a terminating algorithm separating the logic's theorems from its non-theorems. Fortunately, all the complete logics defined in the previous subsection have this property. We mention only the following results explicitly.

**Theorem 3.4** *The Priorean tense logics of the classes of all flows of time, and of all linear flows of time, are decidable.*

This follows from the fact that these logics are finitely axiomatizable and have the *finite model property*. The latter may be proved through the method of *filtrations* or the method of minimal models of Chapter 7, with allowance for complexities analogous to the proof of completeness for **Lin**.

For practical purposes decidability is not enough, however; one would like to have an efficient calculus. A more fine-grained analysis is needed to reveal the *computational complexity* of temporal logics. There is not enough space to go into details here; we only mention the result that the satisfiability problem for linear time is in NP. To be more precise, one can devise a non-deterministic Turing machine algorithm that correctly tells whether a Priorean formula $\varphi$ is satisfiable in a linear frame or not, while coming up with this answer within $f(\varphi)$ computation steps. Here $f$ is a linear function that grows at the same rate as the length of the formula $\varphi$.

## 4 Extending the Language
