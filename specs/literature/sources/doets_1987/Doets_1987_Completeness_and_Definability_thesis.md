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

## 6.9 Lemma

*If $a, b$ are elements of finite Kripke models in $K$ and $[\![a]\!]^{2\rho a + 1} = [\![b]\!]^{2\rho a + 1}$ then $[\![a]\!]^n = [\![b]\!]^n$ for all $n \in \mathbb{N}$.*

*Proof.* Induction on $\rho a$. First, if $\rho a = 0$, $a$ is maximal and the result is obvious. Next, assume $\rho a = n > 0$, $[\![a]\!]^{2n+1} = [\![b]\!]^{2n+1}$ and $m$ is minimal such that $[\![a]\!]^m \neq [\![b]\!]^m$. Let $I$ use a winning strategy in the $m$-game on $(a, b)$ which always picks elements of minimal possible rank. If, using this strategy, $I$ starts picking $a'$ or $b'$, $II$ answers $b'$ resp. $a'$ and $I$ "looses a tempo": there are $m - 1$ moves left for either player and so $II$ can win by choice of $m$. If $I$ starts with $a' > a$, $II$ picks $b' \geq b$ with $[\![b']\!]^{2n} = [\![a']\!]^{2n}$ and wins by the inductive hypothesis. If $I$ starts with $b' > b$, $II$ picks $a' \geq a$ such that $[\![a']\!]^{2n} = [\![b']\!]^{2n}$. There are two cases to distinguish.

(i) $a' \neq a$. Then $\rho a' < \rho a$ and $II$ wins by the inductive hypothesis.

(ii) $a' = a$. Consider the second move of $I$. This cannot be $a'$ or $b'$ for tempo-loss will result. Also, it cannot be $b'' > b'$ since $I$'s strategy picks elements of least rank, so it would have chosen $b''$ as a first move already. Therefore, it will be some $a'' > a'$ and $II$ wins by the inductive hypothesis. $\boxtimes$

## 6.10 Problem

For each $k \in U$, we know by 6.9 that $[\![k]\!]^{2\rho k + 1}$ defines $k$ in the sense that $k$ is the only element of $U$ at which the formula is forced. Determine for each $k \in U$ the *least* $n$ such that $[\![k]\!]^n$ defines $k$ (and give a more manageable equivalent of $[\![k]\!]^n$). A special case of this problem has a simple answer, cf. chapter 9 below.

## 6.11 Lemma

*For all $k \in U$ and $n \in \mathbb{N}$ there is an $l \in U$ such that*

1. *$[\![l]\!]^n = [\![k]\!]^n$;*
2. *$\rho l \leq n$.*

*Proof.* Similar to the one of 6.7. Induction on $n$. For $n = 0$, this is clear. Next, let $C$ be the set of $l \in \bigcup_{i \leq n} U_i$ such that for some $k' > k$, $[\![l]\!]^n = [\![k']\!]^n$. Let $A$ be the set of minimal elements of $C$. The required $l$ is constructed from $A$ and $\sigma k$. $\boxtimes$

## 6.12 On Normal Forms

*Let $\varphi$ be a formula of modal rank $n$. On Kripke models in $K$, $\varphi$ is equivalent with $\bigvee\{[\![k]\!]^n \mid \rho k \leq n \wedge k \Vdash \varphi\}$.*

---

# Chapter 3: Monadic $\Pi^1_1$-Theories of $\Pi^1_1$-Properties: Linear Orderings (pp. 36--57)

## Part II: Completeness

## 3.1 Introduction: $\omega$ and finite orderings

Natural axioms of a number of theories are of the second-order ($\Pi^1_1$-) form $\forall R\,\varphi(R)$, where $\varphi$ is first-order and $R$ is a second-order variable. For instance, the induction principle of arithmetic, completeness of the reals, Zermelo's Aussonderungsaxiom and the Fraenkel-Skolem replacement axiom in set theory are of this type.

As to first-order versions of these principles, the natural option is to require $\varphi(R)$ not for all $R$ but for parametrically first-order definable $R$ only, thus replacing the second-order axiom by its corresponding first-order schema.

Obviously, the new theory will have models not allowed by the old one (by the Löwenheim-Skolem-Tarski theorem for instance) and hence it may turn out to be strictly weaker than its second-order companion. For instance, second-order arithmetic is categorical, hence it implies first-order sentences beyond the scope of the first-order induction schema.

On the other hand, if the language is restricted sufficiently, conservation may occur. This chapter contains a number of examples. They all concern theories of linear orderings (but see chapter 4 below where one of our examples is generalized to trees); conservation is proved with respect to monadic $\Pi^1_1$-sentences.

The method of proof consists in showing how to transfer counter-examples to a $\Pi^1_1$-sentence on a "non-standard" model to a standard model.

**3.1.1 Theorem.** *If 1. $(M, <) \equiv^n (\omega, <)$ and 2. $\mathbf{M} = (M, <, X_1, \ldots, X_k)$ satisfies definable induction, then $\mathbf{M}$ has $n$-equivalents of order type $\omega$ for every $n$.*

*Proof.* By the Löwenheim-Skolem theorem, we may assume $\mathbf{M}$ to be countable. Define $X = \{a \in M \mid \forall b < a\,([b, a) \text{ has a finite } n\text{-equivalent})\}$.

Now, $X$ is a definable set: $[b, a)$ has a finite $n$-equivalent iff it satisfies an $n$-characteristic belonging to a finite model; and of these, there are only finitely many (see 1.7.1). Hence, $X$ is defined by the formula $\forall y < x\,\bigvee\{\tau^{[y,x)} \mid \tau \in Z\}$, where $Z$ is the set of such characteristics and $\tau^{[y,x)}$ denotes relativisation of quantifiers in $\tau$ to the interval $[y, x)$. Trivially, $X$ contains the least element of $M$. Also, $X$ is closed under immediate successors: if $S$ is a finite $n$-equivalent of $[b, a)$ and $c$ is the immediate successor of $a$ then it is clear that the ordered sum $S + \{a\}$ is the required finite $n$-equivalent of $[b, c)$. By definable induction then, $X = M$. Let $a_0$ be the least element of $\mathbf{M}$ and choose $a_0 < a_1 < a_2 < \cdots$ cofinal in $M$ (which we have assumed to be countable!). Choose a finite $n$-equivalent $S_i$ of $[a_i, a_{i+1})$ for each $i$. Then $S = \sum_i S_i$ is the required $n$-equivalent of order type $\omega$. (For the handling of ordered sums, cf. below, in particular 3.1.7.) $\boxtimes$

**3.1.2 Theorem.** *If the linearly ordered model $\mathbf{M}$: 1. has least and greatest element and every non-maximal element has an immediate successor; 2. satisfies definable restricted induction; then $\mathbf{M}$ has finite $n$-equivalents for all $n$.*

### Key Tools: Condensations and Ordered Sums

**3.1.6 Lemma.** *Let $R$ be any transitive binary relation on the ordered model $M$. Define $\sim = \sim_R$ by: $a \sim b$ iff one of the following holds: (i) $a = b$; (ii) $a < b$ and for all $c, d$ such that $a < c < d < b$: $cRd$; (iii) $b < a$ and for all $c, d$ such that $b < c < d < a$: $cRd$. Then $\sim$ induces a condensation.*

**3.1.7 Lemma.** *If for all $i \in I$, $m(i) \equiv^n m'(i)$, then $\sum_{i \in I} m(i) \equiv^n \sum_{i \in I} m'(i)$.*

**3.1.8 Lemma.** *Suppose that $I$ and $J$ are ordered sets and that $m$ and $m'$ associate ordered models $m(i)$ resp. $m'(j)$ to each $i \in I$ resp. $j \in J$ such that: $(I, \{i \mid m(i) \models \sigma\})_{\sigma \in Z} \equiv^n (J, \{j \mid m'(j) \models \sigma\})_{\sigma \in Z}$, where $Z$ is the set of $n$-characteristics. Then $\sum_{i \in I} m(i) \equiv^n \sum_{j \in J} m'(j)$.*

### The Conservation Theorem

**3.1.5 Theorem.** *The following two conditions are equivalent:*

*(i) for each first-order formula $\varphi = \psi(X_1, \ldots, X_k)$ in the language $L_k$: if $\Sigma + \forall R\,\varphi(R) \models \forall X_1 \cdots \forall X_k\,\psi$, then $\Sigma + L_k\text{-definably-}\varphi \models \psi(X_1, \ldots, X_k)$;*

*(ii) each model $(M, U_1, \ldots, U_k)$ of $\Sigma + L_k\text{-definably-}\varphi$ has an $n$-equivalent satisfying $\Sigma + \forall R\,\varphi(R)$ for each $n$.*

## 3.2 Monadic $\Pi^1_1$-theory of scattered orderings

A linear ordering $M = (M, <)$ is called **scattered** if it does not embed the ordering $(\mathbb{Q}, <)$ of the rationals.

**3.2.3 Lemma.** *An ordering is scattered iff it has no densely ordered condensation.*

**3.2.4 Theorem.** *If $\mathbf{M}$ is definably scattered, then it has scattered $n$-equivalents for each $n$.*

*Proof.* Define $\sim$ in the fashion of 3.1.6 with $aRb$ meaning that $(a, b)$ has a scattered $n$-equivalent (if $a < b$). By 3.2.1, $R$ is transitive. Hence, $\sim$ induces a condensation by 3.1.6. Also, $\sim$ is definable.

*Claim 1:* each equivalence class has a scattered $n$-equivalent.

*Claim 2:* the induced ordering of the equivalence classes is dense.

Since $\mathbf{M}$ is definably scattered, $\sim$ cannot have more than one equivalence class: $M$ itself. Consequently, $\mathbf{M}$ must have a scattered $n$-equivalent by the first claim. $\boxtimes$

## 3.3 Monadic $\Pi^1_1$-theory of complete orderings, well-orderings and of the reals

The ordering $(M, <)$ is **complete** if each non-empty set with an upper bound has a least upper bound (a sup). Hence, $\mathbf{M}$ is called **definably complete** if this holds for definable sets.

**3.3.1 Theorem.** *If $\mathbf{M}$ is definably complete, it has complete $n$-equivalents for each $n$.*

*Proof.* Define $\sim$ in the fashion of 3.1.6 with $aRb$ meaning: $a < b$ and $(a, b)$ has a complete $n$-equivalent. Notice that $R$ is transitive. Hence, $\sim$ induces a condensation by 3.1.6. Furthermore, $\sim$ is definable.

*Claim 1:* each equivalence class with an upper (lower) bound has a greatest (resp. least) element and each equivalence class has a complete $n$-equivalent.

*Claim 2:* the induced ordering on the class $M/{\sim}$ of equivalence classes is dense.

*Claim 3:* there is a proper (open) interval $D$ of $M/{\sim}$ and a set $Z \subseteq T$ such that (i) every $I \in D$ has $\tau(I) \in Z$, and (ii) if $\sigma \in Z$ then $\{I \in D \mid \tau(I) = \sigma\}$ is dense in $D$.

*Claim 4:* $D$ has but one element.

The contradiction follows by constructing a complete $n$-equivalent $N$ of the submodel $\bigcup E$ as $N = \sum_{x \in \mathbb{R}} h(x)$, where $h\colon \mathbb{R} \to Z$ is any partition of $\mathbb{R}$ into $|Z|$ classes each of which is dense in $\mathbb{R}$. $\boxtimes$

**3.3.3 Lemma.** *$\mathbf{M}$ is (definably) well-ordered iff it is (definably) complete, has a least element, and every non-maximal element has an immediate successor.*

**3.3.4 Corollary.** *If $\mathbf{M}$ is definably well-ordered, it has well-ordered $n$-equivalents for each $n$.*

### The Suslin Property and $\mathbb{R}$

**3.3.7 Definition.** $\mathbf{M}$ has **property $\mathcal{I}$** if each densely ordered condensation of $\mathbf{M}$ has a dense set of singletons.

**3.3.8 Lemma.** *Models of order type $\lambda$ and, more generally, all complete orderings with the Suslin property have property $\mathcal{I}$.*

**3.3.9 Theorem.** *If $\mathbf{M}$ is definably-$\mathcal{I}$, definably complete and densely ordered without endpoints, then it has $n$-equivalents of order type $\lambda$ for each $n$.*

**3.3.10 Corollary.** *Every ordering which has $\mathcal{I}$, is complete and is densely ordered without endpoints satisfies the monadic $\Pi^1_1$-theory of $\mathbb{R}$.*

## 3.4 Appendix: Strengthening 3.2.4 and 3.3.4

Let $\mathcal{M}_0$ be the smallest class of order types such that (1) $1 \in \mathcal{M}_0$; (2) $\alpha, \beta \in \mathcal{M}_0 \Rightarrow \alpha + \beta \in \mathcal{M}_0$; (3) $\alpha \in \mathcal{M}_0 \Rightarrow \alpha \cdot \omega, \alpha \cdot \omega^* \in \mathcal{M}_0$.

**3.2.4' Theorem.** *If $\mathbf{M}$ is definably scattered, it has (scattered) $n$-equivalents with order type in $\mathcal{M}_0$ for each $n$.*

Let $K$ be the smallest class of order types such that (1) $1 \in K$; (2) $\alpha, \beta \in K \Rightarrow \alpha + \beta \in K$; (3) $\alpha \in K \Rightarrow \alpha \cdot \omega \in K$. Clearly, $K \subseteq \mathcal{M}_0$. All types in $K$ are well-ordered and it is easy to see that $\alpha \in K$ iff $0 < \alpha < \omega^\omega$.

**3.3.4' Theorem.** *If $\mathbf{M}$ is definably well-ordered, it has (well-ordered) $n$-equivalents with order-type in $K$ for each $n$.*

**3.4.1 Corollary.** *(Ehrenfeucht) $\omega \equiv^\infty (\text{OR}, <)$ (where OR is the class of all ordinals).*

---

# Chapter 1: Fraissé-Ehrenfeucht Theory for $L_{\infty\omega}$ and Some of Its Fragments (pp. 1--22)

## Part I: Definability

> *It were not best that we should all think alike; it is difference of opinion that makes horse-races.* — Pudd'nhead Wilson's Calendar

## 1.0 Introduction

This chapter introduces five guises of $\alpha$-equivalence between models, where $\alpha$ is an arbitrary ordinal.

For $\alpha = \omega$, this relation (called *elementary equivalence* and denoted by $\equiv$) is a basic one in model theory. For models of the same finite similarity-type, $\mathbf{A} \equiv \mathbf{B}$ just means that $\mathbf{A}$ and $\mathbf{B}$ have the same true (first-order) sentences. However, there are some uses for refinements, as is argued below.

$\alpha$-Equivalence for *finite* $\alpha$ is explained game-theoretically as follows. Suppose $\mathbf{A}$ and $\mathbf{B}$ are models (of the same similarity type) and $n \in \mathbb{N}$. The *$n$-game* on $\mathbf{A}$ and $\mathbf{B}$, $G(\mathbf{A}, \mathbf{B}, n)$, has two players, $I$ and $II$. They move alternately. $I$ is allowed the first move; each player is allowed $n$ moves. A **move** consists of an element in either $A$ or $B$. However, if player $I$ chooses an element in $A$ (resp. $B$) then player $II$ has to counter in $B$ (resp. $A$). Therefore, a move of player $I$ and the following counter-move of player $II$ form an ordered pair in $A \times B$ (where $A$ and $B$ are the *universes* of $\mathbf{A}$ and $\mathbf{B}$ respectively).

When the game is over, the set of ordered pairs of moves is an at most $n$-element relation $h \subseteq A \times B$. $II$ has **won** the play by definition if $h$ is a **partial isomorphism** between $\mathbf{A}$ and $\mathbf{B}$, that is, if $h$ is an injection on its domain which preserves the structure of the models. Of course, the larger $n$, the better $I$'s chances to defeat $II$.

Finally, $\mathbf{A}$ and $\mathbf{B}$ are called **$n$-equivalent** if $II$ has a **winning strategy** for $G(\mathbf{A}, \mathbf{B}, n)$, that is, a method by which he can beat $I$ no matter the choice of moves by $I$. So, in the example above, $(\mathbb{Z}, R)$ and $(\mathbb{Z}, R)/(9)$ are 3-equivalent but not 4-equivalent.

**1.0.1 Proposition.** *Finite linear orderings $\mathbf{A}$ and $\mathbf{B}$ are $n$-equivalent iff $|A| = |B|$ or $|A|, |B| \geq 2^n - 1$.*

**1.0.2 Lemma.** *Suppose that $\mathbf{A} = (A, <)$ and $\mathbf{B} = (B, <)$ are linear orderings. Then $\mathbf{A} \equiv^{n+1} \mathbf{B}$ iff ("back") for all $b \in B$ there exists $a \in A$ such that $a{\downarrow} \equiv^n b{\downarrow}$ and $a{\uparrow} \equiv^n b{\uparrow}$ and ("forth") for all $a \in A$ there exists $b \in B$ such that $a{\downarrow} \equiv^n b{\downarrow}$ and $a{\uparrow} \equiv^n b{\uparrow}$.*

**1.0.3 Example.** (i) If $m \geq 2^n - 1$, then $m \equiv^n \omega + \omega^*$. (ii) For all $n$: $\omega \equiv^n \omega + \zeta$.

## 1.1 Notation and Terminology

A **model** is a complex $\mathbf{A} = (A, \ldots)$ consisting of a set $A$ (which, contrary to usual logical convention, often is allowed to be empty) together with any number of ("finitary") relations. Thus, functions (and, often, constants as well) are excluded from models.

A **language** (or **similarity-type**) is a set of relation-symbols, together with a specification of the number of arguments (the **arity**) for each symbol in the set.

$h\colon A \to B$ is an **isomorphism** between the $L$-models $\mathbf{A} = (A, {}^*)$ and $\mathbf{B} = (B, {}^\circ)$ if it is bijective and preserves corresponding relations.

## 1.2 $\alpha$-Equivalence

$h\colon A \to B$ is a **partial isomorphism** between the $L$-models $\mathbf{A} = (A, {}^*)$ and $\mathbf{B} = (B, {}^\circ)$ if $\text{Dom}\,h$ is finite and $h$ is an isomorphism between $\mathbf{A}|\text{Dom}\,h$ and $\mathbf{B}|\text{Ran}\,h$.

**1.2.1 Definition.** For $L$-models $\mathbf{A}$, $\mathbf{B}$ and ordinals $\alpha$, $I_\alpha(\mathbf{A}, \mathbf{B})$ is a set of partial isomorphisms between $\mathbf{A}$ and $\mathbf{B}$ defined as follows:

- (i) $I_0(\mathbf{A}, \mathbf{B})$ consists of all partial isomorphisms between $\mathbf{A}$ and $\mathbf{B}$;
- (ii) $h \in I_{\alpha+1}(\mathbf{A}, \mathbf{B})$ iff ("back") for all $b \in B$ there is an $a \in A$ such that $h \cup \{(a, b)\} \in I_\alpha(\mathbf{A}, \mathbf{B})$ and ("forth") for all $a \in A$ there is a $b \in B$ such that $h \cup \{(a, b)\} \in I_\alpha(\mathbf{A}, \mathbf{B})$;
- (iii) for $\alpha$ a limit: $I_\alpha(\mathbf{A}, \mathbf{B}) = \bigcap_{\xi < \alpha} I_\xi(\mathbf{A}, \mathbf{B})$.

$\mathbf{a} = (a_0, \ldots, a_{k-1}) \in A^k$ and $\mathbf{b} = (b_0, \ldots, b_{k-1}) \in B^k$ are called **$\alpha$-equivalent** (notation: $\mathbf{a} \equiv^\alpha \mathbf{b}$) iff the correspondence $(\mathbf{a}, \mathbf{b}) = \{(a_i, b_i) \mid i < k\}$ is in $I_\alpha(\mathbf{A}, \mathbf{B})$. ($\omega$-equivalence usually is called elementary equivalence.)

**1.2.2 Lemma.** *If $\alpha < \beta$ then $I_\beta(\mathbf{A}, \mathbf{B}) \subseteq I_\alpha(\mathbf{A}, \mathbf{B})$.*

## 1.3 Ordinal-bounded Ehrenfeucht Games

Suppose that $\mathbf{A}$ and $\mathbf{B}$ are models for the same language, that $h \in I_0(\mathbf{A}, \mathbf{B})$ and that $\alpha$ is some ordinal. $G(\mathbf{A}, \mathbf{B}, h, \alpha)$ is the following game for two players $I$ and $II$: $I$ and $II$ make moves alternately as follows. $I$ begins. His first move consists of three things: (i) an ordinal $\alpha_0 < \alpha$; (ii) one of the models $\mathbf{A}$, $\mathbf{B}$; (iii) one element of the model chosen under (ii). $II$ now is allowed, as a counter-move, to choose one element from the model not chosen by $I$. This goes on with the proviso that the sequence of ordinals picked by $I$ must be strictly descending. After a finite number of moves, player $I$ must pick the ordinal 0 eventually.

**1.3.2 Theorem.** *In each game $G(\mathbf{A}, \mathbf{B}, h, \alpha)$, one of the players has a winning strategy.*

**1.3.3 Theorem.** *For $h \in I_0(\mathbf{A}, \mathbf{B})$ and $\alpha$ an ordinal the following are equivalent:*

- *(i) $h \in I_\alpha(\mathbf{A}, \mathbf{B})$;*
- *(ii) $II$ has a winning strategy for $G(\mathbf{A}, \mathbf{B}, h, \alpha)$.*

## 1.4 Fraissé-Karp Sequences

A **Karp sequence** for $\mathbf{A}, \mathbf{B}, h, \alpha$ is a sequence $\langle I_\xi \mid \xi \leq \alpha \rangle$ of length $\alpha + 1$ such that:

1. (i) $I_\xi \subseteq I_0(\mathbf{A}, \mathbf{B})$ for all $\xi \leq \alpha$; (ii) $\xi < \delta \leq \alpha \Rightarrow I_\delta \subseteq I_\xi$; (iii) $h \in I_\alpha$;
2. for all $\xi < \alpha$ and $g \in I_{\xi+1}$: ("back") for all $b \in B$ there exists $a \in A$ such that $g \cup \{(a, b)\} \in I_\xi$; ("forth") for all $a \in A$ there exists $b \in B$ such that $g \cup \{(a, b)\} \in I_\xi$.

**1.4.1 Theorem.** *$h \in I_\alpha(\mathbf{A}, \mathbf{B})$ iff there is a Karp sequence for $\mathbf{A}, \mathbf{B}, h, \alpha$.*

## 1.5 Logic

The set $L_{\infty\omega}$ of (infinitary) formulas of $L$ is the least one such that:

1. all atomic formulas are in $L_{\infty\omega}$;
2. if $\varphi \in L_{\infty\omega}$ then $\neg\varphi \in L_{\infty\omega}$;
3. if $\Phi \subseteq L_{\infty\omega}$ is any set then $\bigwedge\Phi$ and $\bigvee\Phi$ are in $L_{\infty\omega}$;
4. if $\varphi \in L_{\infty\omega}$ and $x$ is a variable then $\forall x\,\varphi$ and $\exists x\,\varphi$ are in $L_{\infty\omega}$.

The **quantifier rank** $\text{qr}(\varphi)$ of $\varphi \in L_{\infty\omega}$ is an ordinal recursively defined as follows:

1. $\text{qr}(\varphi) = 0$ if $\varphi$ is atomic;
2. $\text{qr}(\neg\varphi) = \text{qr}(\varphi)$;
3. $\text{qr}(\bigwedge\Phi) = \text{qr}(\bigvee\Phi) = \sup\{\text{qr}(\varphi) \mid \varphi \in \Phi\}$;
4. $\text{qr}(\forall x\,\varphi) = \text{qr}(\exists x\,\varphi) = \text{qr}(\varphi) + 1$.

**1.5.1 Theorem.** *$h \in I_\alpha(\mathbf{A}, \mathbf{B})$ iff for every $\varphi \in L_{\infty\omega}$ with $\text{qr}(\varphi) < \alpha$ and every valuation $f$ of the free variables of $\varphi$ into $\text{Dom}\,h$: $\mathbf{A} \models \varphi[f]$ iff $\mathbf{B} \models \varphi[h \circ f]$ (i.e., $h$ preserves satisfaction of quantifier-rank $< \alpha$-formulas).*

## 1.6 Scott-Sentences

**1.6.1 Definition.** Fix an enumeration $v_0, v_1, v_2, \ldots$ of all variables. For $\mathbf{A} = (A, \ldots)$, $\mathbf{a} = (a_0, \ldots, a_{k-1}) \in A^k$ and $\alpha$ an ordinal, define the formula $[\![\mathbf{a}]\!]^\alpha = [\![(\mathbf{A}, \mathbf{a})]\!]^\alpha$ (the **$\alpha$-characteristic** of $\mathbf{a}$ in $\mathbf{A}$) as follows:

1. $[\![\mathbf{a}]\!]^0$ is the conjunction of all atomic or negated atomic formulas in $v_0, \ldots, v_{k-1}$ satisfied by $\mathbf{a}$ in $\mathbf{A}$;
2. $[\![\mathbf{a}]\!]^{\alpha+1} = \bigwedge_{a \in A} \exists v_k\, [\![\mathbf{a}a]\!]^\alpha \wedge \forall v_k \bigvee_{a \in A} [\![\mathbf{a}a]\!]^\alpha$;
3. $[\![\mathbf{a}]\!]^\alpha = \bigwedge_{\xi < \alpha} [\![\mathbf{a}]\!]^\xi$ when $\alpha$ is a limit.

**1.6.3 Theorem.** *For $\mathbf{a} \in A^k$ and $\mathbf{b} \in B^k$ the following are equivalent:*

1. *$\mathbf{a} \equiv^\alpha \mathbf{b}$;*
2. *$\mathbf{B} \models [\![\mathbf{a}]\!]^\alpha[\mathbf{b}]$;*
3. *$[\![\mathbf{b}]\!]^\alpha = [\![\mathbf{a}]\!]^\alpha$.*

## 1.7 The Finite Case

**1.7.1 Lemma.** *If the language of $\mathbf{A}$ is finite then, for all $k, n \in \mathbb{N}$, there are only finitely many $n$-characteristics belonging to sequences of length $k$.*

**1.7.2 Theorem.** *For models $\mathbf{A}$, $\mathbf{B}$ of the same finite language, when $\mathbf{a} \in A^k$, $\mathbf{b} \in B^k$, $n \in \omega$, the following are equivalent:*

1. *$\mathbf{a} \equiv^n \mathbf{b}$;*
2. *for all finite formulas $\varphi$ of quantifier-rank $\leq n$ in the appropriate number of free variables: $\mathbf{A} \models \varphi[\mathbf{a}] \Leftrightarrow \mathbf{B} \models \varphi[\mathbf{b}]$.*

## 1.8 The Unbounded Case

$\mathbf{A}$ and $\mathbf{B}$ are called **partially isomorphic** if a non-empty set $I$ of partial isomorphisms exists with the back-and-forth property.

**1.8.1 Theorem.** *The following are equivalent:*

1. *$I_\alpha(\mathbf{A}, \mathbf{B}) = I_{\alpha+1}(\mathbf{A}, \mathbf{B}) \neq \varnothing$;*
2. *$II$ has a winning strategy for $G(\mathbf{A}, \mathbf{B}, \varnothing)$;*
3. *$\mathbf{A}$ and $\mathbf{B}$ are partially isomorphic;*
4. *$\mathbf{A} \equiv^{\infty} \mathbf{B}$ (i.e., they have the same $L_{\infty\omega}$-theory).*

**1.8.2 Corollary.** *(Barwise [1973]) Countable partially isomorphic models are isomorphic.*

## 1.9 Basis Results

**1.9.1 Theorem.**

1. *If $|A| = n < \omega$ then $\mathbf{A} \equiv^\infty \mathbf{B}$ iff $\mathbf{A} \cong \mathbf{B}$ iff $\mathbf{A} \equiv^{n+1} \mathbf{B}$;*
2. *If $\mathbf{A}$ and $\mathbf{B}$ are infinite then $\mathbf{A} \equiv^\infty \mathbf{B}$ iff $\mathbf{A} \equiv^\alpha \mathbf{B}$, where $\alpha$ is the least ordinal of power $> |A|, |B|$.*

**1.9.2 Theorem.** *Let $\mathcal{A}$ be an admissible set such that $L, \mathbf{A}, \mathbf{B} \in \mathcal{A}$ and let $\alpha = \mathcal{A} \cap \text{OR}$ be the set of ordinals in $\mathcal{A}$. If $\mathbf{A} \equiv^\alpha \mathbf{B}$ then $\mathbf{A} \equiv^\infty \mathbf{B}$.*

The **Scott-rank** $\text{sr}(\mathbf{A})$ of $\mathbf{A}$ is the least ordinal $\alpha$ such that for all $k$ and $\mathbf{a}, \mathbf{b} \in A^k$: if $\mathbf{a} \equiv^\alpha \mathbf{b}$ then $\mathbf{a} \equiv^{\alpha+1} \mathbf{b}$.

**1.9.3 Theorem.** *If $\mathcal{A}$ is admissible and $\mathbf{A} \in \mathcal{A}$ then $\text{sr}(\mathbf{A}) < \mathcal{A} \cap \text{OR}$.*

For $\alpha = \text{sr}(\mathbf{A})$, the **Scott-sentence** of $\mathbf{A}$ is

$$\sigma_{\mathbf{A}} = [\![\varnothing]\!]^\alpha \wedge \bigwedge_a \forall x\,([\![\mathbf{a}]\!]^\alpha \to [\![\mathbf{a}]\!]^{\alpha+1}).$$

**1.9.4 Theorem.**

1. *$\text{qr}(\sigma_{\mathbf{A}}) = \text{sr}(\mathbf{A}) + \omega$;*
2. *$\mathbf{A} \models \sigma_{\mathbf{A}}$;*
3. *$\mathbf{B} \models \sigma_{\mathbf{A}}$ iff $\mathbf{B} \cong^{\omega} \mathbf{A}$.*

---

## References (from thesis bibliography, selected)

- Barwise, K.J. [1973]. Back and forth through infinitary logic. In *Studies in Model Theory*, MAA Studies in Math. vol. 8.
- Barwise, K.J. [1975]. *Admissible Sets and Structures.* Springer.
- van Benthem, J.F.A.K. [1983]. *Modal Logic and Classical Logic.* Bibliopolis.
- Chang, C.C. [1968]. Some remarks on the model theory of infinitary languages. In *The Syntax and Semantics of Infinitary Languages*, Springer LNM 72.
- de Jongh, D.H.J., R. Verbrugge, and A. Visser [1986]. A completeness result for Z. Preprint, University of Amsterdam.
- Ehrenfeucht, A. [1961]. An application of games to the completeness problem for formalized theories. *Fund. Math.* 49, pp. 129--141.
- Fraissé, R. [1955]. Sur quelques classifications des relations, basées sur des isomorphismes restreints. *Publ. Sci. Univ. Alger*, Sér. A, 2, pp. 15--60.
- Karp, C.R. [1965]. Finite-quantifier equivalence. In *The Theory of Models*, North-Holland.
- Rosenstein, J.G. [1982]. *Linear Orderings.* Academic Press.
- Scott, D. [1965]. Logic with denumerably long formulas and finite strings of quantifiers. In *The Theory of Models*, North-Holland.
- Segerberg, K. [1970]. Modal logics with linear alternative relations. *Theoria* 36, pp. 301--322.
- Sehtman (Shehtman), V.B. [1978]. On some two-dimensional modal logics. In *Proc. 8th Internat. Congress of Logic, Methodology and Philos. of Science*, Moscow.
- Shelah, S. [1975]. The monadic theory of order. *Annals of Math.* 102, pp. 379--419.
