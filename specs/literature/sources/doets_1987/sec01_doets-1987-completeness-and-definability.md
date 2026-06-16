# Doets (1987) — Completeness and Definability: Applications of the Ehrenfeucht Game in Second-Order and Intensional Logic

> **Selective conversion** of the PhD thesis by Hans Cornelis (Kees) Doets, University of Amsterdam, 1987.
> Promotor: Prof. Dr J.F.A.K. van Benthem; Co-promotor: Prof. Dr A.S. Troelstra.
>
> **Chapters included**: 7 (Completeness for $\mathbb{Z}$-time), 6 (Game theory for intensional logics), 3 (Monadic $\Pi^1_1$-theories of linear orderings), 1 (Fraissé-Ehrenfeucht theory).
> Converted from scanned PDF with OCR corrections. Page numbers refer to the original thesis pagination.

---

## Table of Contents

### Part I: Definability

- **Chapter 1.** Fraissé-Ehrenfeucht theory for $L_{\infty\omega}$ and some of its fragments (p. 1)
- **Chapter 2.** On $n$-equivalence of binary trees (p. 23)

### Part II: Completeness

- **Chapter 3.** Monadic $\Pi^1_1$-theories of $\Pi^1_1$-properties: linear orderings (p. 36)
- **Chapter 4.** Monadic $\Pi^1_1$-theory of well-founded trees (p. 58)

### Part III: Applications to Intensional and Intuitionistic Logic

- **Chapter 5.** Fine structure of modal correspondence theory (p. 66)
- **Chapter 6.** Game theory for intensional logics, exact-universal Kripke models and normal forms (p. 82)
- **Chapter 7.** Completeness for $\mathbb{Z}$-time (p. 89)
- **Chapter 8.** Rodenburg's tree-problem (p. 94)
- **Chapter 9.** First-order definability of one-variable intuitionistic formulas on finite partial orderings (p. 98)

---

# Chapter 7: Completeness for $\mathbb{Z}$-time (pp. 89--93)

*This is the key chapter for our project. It proves that a certain axiom system for tense logic is complete with respect to integer time $\mathbb{Z}$.*

The theorem of this chapter, asserting completeness of a certain system of tense logic with respect to $\mathbb{Z}$-time, is due to Segerberg [1970]. A different proof is in van Benthem [1983] (cf. II.2.3.15) and another, relatively simple one is in de Jongh et al. [1986]. Our proof is related to the method of chapter 3; however, the relationship is not that exact, due to the fact that the tense logical formalism lacks first-order possibilities such as quantifier relativization. This weakness also is responsible for the fact that the Suslin property of $\mathbb{R}$ has no influence on the theory of $\mathbb{R}$-time; contrast this with 3.3.6/9. Nevertheless, we shall put to good use tense logical versions of $n$-characteristics.

The logic of time has operators $G$ and $F$ with the same semantics as the modal ones $\Box$ and $\Diamond$. Next to these, there is a dual pair: $H$ ($t \Vdash H\varphi$ iff $\forall t' < t$: $t' \Vdash \varphi$) and $P$ ($t \Vdash P\varphi$ iff $\exists t' < t$: $t' \Vdash \varphi$). Of course, there is the tense logical version of the Ehrenfeucht game: player $I$ now is allowed to move downward as well as upward in the ordering (which represents the time structure) and $II$ has to follow $I$ in this respect. Also, there are the $n$-characteristics $[\![a]\!]^n$ coding the game-theoretic behaviour of $a$ in the $n$-game with respect to a finite set of variables.

**Theorem.** *The tense logical theory of $\mathbb{Z}$ (integer time) is axiomatized by the following principles:*

| Axiom | Formula |
|-------|---------|
| **trans** | $Gp \to GGp$ |
| **succ** | $FT$; $PT$ ($T$ the constant for true) |
| **r-lin** | $Fp \to G(Fp \vee p \vee Pp)$ |
| **l-lin** | $Pp \to H(Pp \vee p \vee Fp)$ |
| **modified Löb** | $G(Gp \to p) \to (FGp \to Gp)$ |
|  | $H(Hp \to p) \to (PHp \to Hp)$ |

For a precise definition of tense logical derivability, cf. van Benthem l.c. pp. 167/8.

*Proof.* Suppose that the formula $\chi$ cannot be derived using these principles. I shall show how to construct a valuation $V$ on $\mathbb{Z}$ such that $(\mathbb{Z}, <, V) \models \neg\chi[n]$ for some $n \in \mathbb{Z}$.

As a first step, we need the Henkin construction for tense logic (cf. van Benthem l.c. pp. 170--173). This produces a model $(M, R, V)$ such that

1. *the axioms given all hold (universally) in the model;*
2. *for some $m \in M$, $(M, R, V) \models \neg\chi[m]$.*

In fact, $M$ consists of all sets of formulas maximal consistent with the given axioms, and $R$ is defined by

3. $xRy$ iff for all $\varphi$, if $G\varphi \in x$ then $\varphi \in y$.

The basic tense logical axioms now allow one to prove the following truth lemma:

4. $(M, R, V) \models \varphi[x]$ iff $\varphi \in x$

on the basis of the following definition of $V$:

5. $x \in V(p)$ iff $p \in x$.

By assumption, $\neg\chi$ will be in some $m \in M$, so 2. follows from 4. Also, 1. follows; as substitution is one of the derivation rules, substitution instances of the axioms are satisfied as well. 6--8 now investigate the effect the axioms **trans** up to **l-lin** have on the structure of $(M, R)$; this is standard procedure.

**6.** *$R$ is transitive.*

*Proof:* suppose $xRyRz$. If $G\varphi \in x$ then by 4., $x$ satisfies $G\varphi$ and hence $GG\varphi$ (use **trans**). Hence, $GG\varphi \in x$ by 4. again. Applying 3. twice, this gives $G\varphi \in y$ and $\varphi \in z$. Therefore, $xRz$ by 3. $\boxtimes$

**7.** *$M$ has no $R$-minimum or $R$-maximum.*

*Proof:* immediate from **succ**. $\boxtimes$

**8.** *Every two elements with a common upper bound (resp. lower bound) are comparable.*

*Proof:* suppose that $x, yRz$, $x \neq y$, $\neg xRy$, $\neg yRx$. For instance, $\varphi \in x \setminus y$, $G\psi \in x$, $\varphi \notin y$, $G\eta \in y$, $\eta \notin x$. Now, $z$ satisfies $P(\varphi \wedge G\psi \wedge \neg\eta)$. Hence, by **l-lin**, it satisfies $H[F(\varphi \wedge G\psi \wedge \neg\eta) \vee (\varphi \wedge G\psi \wedge \neg\eta) \vee P(\varphi \wedge G\psi \wedge \neg\eta)]$ as well. Therefore, $y$ satisfies one of $F(\varphi \wedge G\psi \wedge \neg\eta)$, $\varphi \wedge G\psi \wedge \neg\eta$, $P(\varphi \wedge G\psi \wedge \neg\eta)$. But the first alternative contradicts $y$ satisfying $G\eta$, the second $\varphi \notin y$ and the third $\psi \notin y$. $\boxtimes$

Define $\sim$ on $M$ by

$$x \sim y \quad\text{iff}\quad x = y \text{ or: both } xRy \text{ and } yRx.$$

By 6., $\sim$ is an equivalence.

$R$ induces a partial ordering $M/{\sim}$ on the set of equivalence classes by

$$|x| R/{\sim}\, |y| \quad\text{iff}\quad xRy.$$

Let $m$ be the $\chi$-falsifying element (2.) then restricting to equivalence classes $|x|$ with $xRm$ or $x = m$ or $mRx$ produces a *linear* ordering by 8.; since $R$ is transitive, the model-theoretic properties of $(M, R, V)$ won't change by restricting to such $x$ — hence we may assume $xRm$ or $x = m$ or $mRx$ for all $x \in M$ to begin with.

Let $\text{VAR}_\chi$ be the (finite) set of variables in $\chi$. $\mathcal{P}(\text{VAR}_\chi)$ is the set of **shapes**; $x$ has $S \subseteq \text{VAR}_\chi$ ($S$ **occurs at** $x$) iff $S = x \cap \text{VAR}_\chi$.

Let $A$ be an equivalence class of $M$ under $\sim$. If $A = \{a\}$ and $\neg aRa$ then $A^* = A$. In all other cases, $A^*$ denotes a model $(\mathbb{Z}, <, V_A)$ of order-type $\zeta$ such that

- (i) each shape occurring in it occurs in $A$;
- (ii) if $S$ occurs in $A$ then the set $\{n \in \mathbb{Z} \mid n \text{ has } S\}$ has neither lower nor upper bound.

Now, define $N = \sum_{A \in M/\sim} A^*$.

**9.** *Suppose that $x \in A \in M/{\sim}$ and $n \in A^*$ have the same shape. Then for all formulas $\varphi$ over $\text{VAR}_\chi$: $M \models \varphi[x]$ iff $N \models \varphi[n]$.*

*Proof.* Use the Ehrenfeucht game appropriate to tense logic. Notice that $II$ can always take care to leave a position $(y, m)$ for $I$ for which (i) for all $A \in M/{\sim}$: $y \in A$ iff $m \in A^*$ and (ii) $y$ and $m$ have the same shape. $\boxtimes$

Therefore, we now have a counter-model to $\chi$ of an order type which is a sum of $\zeta$'s and 1's. To finally transform this into a counter-model of type $\zeta$, I use the **modified Löb-axioms**.

**10.** *Suppose that $\varphi$ is a formula over $\text{VAR}_\chi$ such that $\varphi^N = \{n \in N \mid N \models \varphi[n]\}$ is non-empty and upward (downward) bounded. Then $\varphi^N$ has a maximum (minimum).*

*Proof.* Let $N \models \varphi[n]$ and $m < n$. Then $m$ satisfies $F\varphi$ and $FG\neg\varphi$. Since $F\varphi$ amounts to $\neg G\neg\varphi$, by the first **modified Löb-axiom** (with $\neg\varphi$ substituted for $p$): $N \models \neg G(G\neg\varphi \to \neg\varphi)\,[m]$. Choose $k > m$ such that $k$ satisfies $G\neg\varphi$ and $\varphi$; $k$ is the required maximum. $\boxtimes$

Let $k$ be the rank of $\chi$. Put $T = \{[\![x]\!]^k \mid x \in N\}$ ($[\![x]\!]^k$ codes the "behaviour" of $x$ in the game of length $k$). Define $T^+ = \{\tau \in T \mid \{x \in N \mid \tau = [\![x]\!]^k\} \text{ has an upper bound}\}$ and $T^- = \{\tau \in T \mid \{x \in N \mid \tau = [\![x]\!]^k\} \text{ has a lower bound}\}$. By 10., to each $\tau \in T^+$ there is a maximal $x = x_\tau$ with $[\![x]\!]^k = \tau$ and similarly for $T^-$. Let $A_0$ be the set $\{x_\tau \mid \tau \in T^+ \cup T^-\}$. Choose $A^+ \subset N$ of order type $\omega$ such that $A_0 < A^+$ and such that for all $\tau \in T \setminus T^+$, $\{x \in A^+ \mid [\![x]\!]^k = \tau\}$ is infinite. Similarly, choose $A^- \subset N$ of order type $\omega^*$ such that $A^- < A_0$ and each $\{x \in A^- \mid [\![x]\!]^k = \tau\}$ for $\tau \in T \setminus T^-$ is infinite. Finally, $A$ is the submodel of $N$ obtained by restricting to $A^- \cup A_0 \cup A^+$.

So, $A$ has order type $\zeta$; it suffices to prove

**11.** *If the formula $\psi$ over $\text{VAR}_\chi$ has rank $\leq k$ and $x \in A$ then $A \models \psi[x]$ iff $N \models \psi[x]$.*

*Proof.* Induction on $\psi$. There is but one interesting case. Suppose that $N \models F\psi[x]$. Then $y > x$ exists such that $N \models \psi[y]$. Let $\tau = [\![y]\!]^k$. By construction, there is a $z > x$ in $A$ such that $[\![z]\!]^k = \tau$. But then, $N \models \psi[z]$ as well. By induction hypothesis $A \models \psi[z]$. Hence, $A \models F\psi[x]$. $\boxtimes$

---

# Chapter 6: Game Theory for Intensional Logics, Exact-Universal Kripke Models and Normal Forms (pp. 82--88)

The Ehrenfeucht game technique can be modified for use in investigations of intensional logics. Here, the case of modal logic is considered only; the modifications needed for tense and intuitionistic logic below are then more or less clear. Using the game characterization, exact-universal models are built which can be used to construct normal forms. This will be used extensively in a comparatively simple case in chapter 9.

## 6.1. Standard Interpretation

Suppose then that $\mathbf{A} = (A, R)$ ($R \subseteq A^2$) is any frame and $V\colon \text{VAR} \to \mathcal{P}(A)$ is a valuation mapping the set VAR of propositional variables onto subsets of $A$. The pair $(\mathbf{A}, V)$ is called a **Kripke model**. For a modal formula $\varphi$ and $a \in A$, $\varphi$ is **forced** at $a$ ($a \Vdash \varphi$) iff $a$ satisfies the **standard interpretation** $\text{ST}(\varphi)$ of $\varphi$ in the associated model $(\mathbf{A}, V(p))_{p \in \text{VAR}}$, where $\text{ST}(\varphi)$ is defined by the following clauses:

1. $\text{ST}(p) = p(v_0)$

   (here, $p \in \text{VAR}$ on the right-hand side of this equation is used as a unary relation-symbol interpreted by $V(p)$ in $(\mathbf{A}, V(p))_{p \in \text{VAR}}$)

2. (i) $\text{ST}(\neg\varphi) = \neg\text{ST}(\varphi)$
   (ii) $\text{ST}(\varphi \wedge \psi) = \text{ST}(\varphi) \wedge \text{ST}(\psi)$

   (and similarly for the other connectives if present)

3. (i) $\text{ST}(\Box\varphi) = \forall v_1\,(R(v_0, v_1) \to \text{ST}(\varphi)^+)$
   (ii) $\text{ST}(\Diamond\varphi) = \exists v_1\,(R(v_0, v_1) \wedge \text{ST}(\varphi)^+)$

Here, $\psi^+$ is obtained from $\psi$ by raising indices of all variables in $\psi$ by 1. Clearly, if the modal formula $\varphi$ has modal rank $n$ (defined in the obvious way) then $\text{ST}(\varphi)$ is an $R$-restricted first-order formula with $v_0$ as only free variable which has quantifier rank $n$.

## 6.2. The Restricted Ehrenfeucht Game

The **restricted Ehrenfeucht game of length $n$** on Kripke models $(\mathbf{A}, V)$ and $(\mathbf{B}, W)$ ($\mathbf{A} = (A, R)$, $\mathbf{B} = (B, S)$) with **initial position** $(a_0, b_0) \in A \times B$ is played by $I$ and $II$ as follows. First, $I$ chooses either $a_1 \in A$ such that $a_0Ra_1$ or $b_1 \in B$ such that $b_0Sb_1$. In the first case, $II$ answers with some $b_1 \in B$ such that $b_0Sb_1$. In the second, $II$ chooses $a_1 \in A$ such that $a_0Ra_1$. A position $(a_1, b_1) \in A \times B$ results and the procedure is repeated until each player has had $n$ moves. In so doing, they have set up an $n$-element sequence $\langle(a_i, b_i) \mid i < n\rangle$ in $A \times B$; and we shall say that $II$ has **won** the play iff for each $i < n$ and $p \in \text{VAR}$: $a_i \in V(p)$ iff $b_i \in W(p)$ — otherwise $I$ has **won**.

Of course, this game has its ordinal-bounded version. But somehow, intensional logic never is considered in the context of an infinitary language. (But see *dynamic logic*.)

## 6.3. $n$-Characteristics for Modal Logic

Suppose now that VAR is *finite*.

For $(\mathbf{A}, V)$ a Kripke model, $a \in A$ and $n \in \mathbb{N}$, define the modal formula $[\![a]\!]^n = [\![(\mathbf{A}, V, a)]\!]^n$ as follows:

1. $[\![a]\!]^0 = \bigwedge(\{p \in \text{VAR} \mid a \in V(p)\} \cup \{\neg p \mid p \in \text{VAR} \wedge a \notin V(p)\})$;
2. $[\![a]\!]^{n+1} = [\![a]\!]^0 \wedge \Box\bigvee_{aRa'} [\![a']\!]^n \wedge \bigwedge_{aRa'} \Diamond[\![a']\!]^n$.

Clearly, $[\![a]\!]^n$ is a formula of modal rank $n$ forced at $a$ in $(\mathbf{A}, V)$. A modification of the proofs of 1.5.1/1.6.3 will show that

**6.4 Theorem.** *For $(\mathbf{B}, W)$ a Kripke model, $b \in B$ and $[\![b]\!]^n = [\![(\mathbf{B}, W, b)]\!]^n$, the following are equivalent:*

1. *$II$ has a winning strategy for the restricted Ehrenfeucht game of length $n$ on $(\mathbf{A}, V)$, $(\mathbf{B}, W)$ with initial position $(a, b)$;*
2. *for each modal formula $\varphi$ of rank $\leq n$: $a \Vdash \varphi$ iff $b \Vdash \varphi$;*
3. *$b \Vdash [\![a]\!]^n$;*
4. *$[\![b]\!]^n = [\![a]\!]^n$.*

## 6.5 Definition (Universal and Exact Models)

Suppose now that $K$ is a class of Kripke models. The Kripke model $(\mathbf{A}, V)$ is called

- (i) **$K$-universal** if for each $(\mathbf{B}, W) \in K$ and $b \in B$ there is an $a \in A$ such that for all $n \in \mathbb{N}$: $[\![a]\!]^n = [\![b]\!]^n$.
- (ii) **exact** if for all $a_1, a_2 \in A$: if for all $n \in \mathbb{N}$, $[\![a_1]\!]^n = [\![a_2]\!]^n$, then $a_1 = a_2$.

## 6.6 Theorem (Existence of Exact-Universal Model)

*There exists an (obviously: unique within isomorphism) exact Kripke model which is universal with respect to all Kripke models over finite (reflexive) partial orderings.*

*Proof.* Let us denote the model to be constructed by $(U, \leqslant, V)$. It will turn out that $>$ is well-founded. Let $\rho k$ be the **rank** of $k \in U$ relative to $>$ (i.e., $\rho k = \sup\{\rho l + 1 \mid l > k\}$). It will turn out that all ranks are finite. Define $U_n = \{k \in U \mid \rho k = n\}$ ($n \in \omega$) and $\sigma k = \{p \in \text{VAR} \mid k \in V(p)\}$. It is now easy to build the $U_n$ one after the other explicitly by recursion on $n$, defining $\leqslant$ and $\sigma$ along the way, by simply imagining what possibilities may occur in a finite Kripke model over a partially ordered set.

First, $U_0 = \mathcal{P}(\text{VAR})$; $\sigma|U_0$ is defined by: $\sigma k = k$.

Next, assume the $U_i$ constructed up to and including $U_n$; $\sigma$ and $\leqslant$ defined on $\bigcup_{i \leq n} U_i$. $U_{n+1}$ now consists of the following two types of objects:

1. Each $k \in U_n$ has **predecessors** $(k, j) \in U_{n+1}$ for each $j \in U_0$ such that $j \neq \sigma k$; $\sigma$ is defined on these by $\sigma(k, j) = j$.

2. For each **anti-chain** $A \subseteq \bigcup_{i \leq n} U_i$ which intersects $U_n$ and has at least two elements and each $j \in U_0$ there is an element $(A, j) \in U_{n+1}$ which precedes every $k \in A$; $\sigma$ is defined on these by $\sigma(A, j) = j$.

(Sehtman [1978] has a picture of this model with all 30 elements of $U_2$ shown.)

## 6.7 Theorem (Canonical Map)

*For each $(\mathbf{B}, W) \in K$, there is a canonical map $h\colon B \to U$ such that*

- *(i) $a \leqslant b \Rightarrow ha \leqslant hb$*
- *(ii) $ha \leqslant k \Rightarrow \exists b \geqslant a\,(hb = k)$*
  *($h$ is a p-morphism)*
- *(iii) for all $b \in B$, $n \in \mathbb{N}$: $[\![b]\!]^n = [\![hb]\!]^n$.*
  *(hence, $(U, V)$ is $K$-universal)*

*Proof.* $hb$ is defined by recursion on $\rho b$, the rank of $b \in B$ with respect to the relation $>$, where $\mathbf{B} = (B, <)$.

If $\rho b = 0$, $hb = \sigma b$ ($= \{p \mid b \in W(p)\}$).

If $\rho b > 0$, let $C = \{hb' \mid b < b'\}$; let $A$ be the set of minimal elements of $C$. Then $A$ is an anti-chain with at least one element of rank $\rho b - 1$. Distinguish three possibilities:

1. $A = \{k\}$, $\sigma b = \sigma k$. Put $hb = k$.
2. $A = \{k\}$, $\sigma b \neq \sigma k$. Put $hb = (k, \sigma b)$.
3. $|A| \geq 2$. Put $hb = (A, \sigma b)$.

Now, (i)--(iii) are clear. $\boxtimes$

## 6.8 Lemma

*(U, V) is exact.*

*Proof.* Suppose that $k, l \in U$ and for all $n \in \mathbb{N}$, $[\![k]\!]^n = [\![l]\!]^n$. Apply induction on $\rho k$. Let $A = \{x \in U \mid k < x\}$ and $B = \{x \in U \mid l < x\}$. By induction hypothesis and 6.9 below, it follows that $A = B$. Now, $k = l$ is clear. $\boxtimes$
