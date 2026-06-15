# Lean Formalization of Completeness Proof for Coalition Logic with Common Knowledge

**Kai Obendrauf**, **Anne Baanen**, **Patrick Koopmann**, **Vera Stebletsova**

Department of Computer Science, Vrije Universiteit Amsterdam, The Netherlands

*15th International Conference on Interactive Theorem Proving (ITP 2024)*
Article No. 28; pp. 28:1--28:18

DOI: [10.4230/LIPIcs.ITP.2024.28](https://doi.org/10.4230/LIPIcs.ITP.2024.28)

Related Version: [Extended Version](https://zenodo.org/records/12582709)

Source Code: [https://github.com/kaiobendrauf/cl-lean](https://github.com/kaiobendrauf/cl-lean)

Funding: Anne Baanen: NWO Vidi grant No. 016.Vidi.189.037, Lean Forward.

---

## Abstract

Coalition Logic (CL) is a well-known formalism for reasoning about the strategic abilities of groups of agents in multi-agent systems. Coalition Logic with Common Knowledge (CLC) extends CL with operators from epistemic logics, and thus with the ability to model the individual and common knowledge of agents. We have formalized the syntax and semantics of both logics in the interactive theorem prover Lean 4, and used it to prove soundness and completeness of its axiomatization. Our formalization uses the type class system to generalize over different aspects of CLC, thus allowing us to reuse some of it to prove properties in related logics such as CL and CLK (CL with individual knowledge).

**Keywords:** Multi-agent systems, Coalition Logic, Epistemic Logic, common knowledge, completeness, formal methods, Lean prover

---

## 1 Introduction

Computers rarely work in isolation, rather they constantly interact with both human users and other devices. Such interconnected systems can range from household Internet of Things (IoT) devices, working towards creating a useful digital home for a user [2], to safety-critical systems for metros that need to account for multiple trains [15]. Correctly designing and verifying such systems is an important goal of research in Artificial Intelligence, specifically in the field of Multi Agent Systems (MAS) [11, 13, 27]. The large number of agents and simultaneous goals involved in these interactions make them highly complex. Furthermore, computers in such systems must often operate with imperfect information [26], for instance because they have limited input about the external environment [13]. It can therefore be difficult to maintain an overview of whether a system has been correctly programmed to always meet its requirements, highlighting the need for formal modelling and programmatic verification [27].

In this paper we focus on Coalition Logic with Common Knowledge (CLC) to model such systems and their requirements. Coalition Logic (CL) was introduced by Marc Pauly in 2002 [22] for reasoning about abilities of agents, and is a popular logic in MAS research [1]. CL introduces an effectivity operator, which describes whether some group of agents is effective for ensuring some outcome, regardless of the actions of other agents. CL was later extended by Agotnes and Alechina [1] into CLC by adding operators from epistemic logic for individual and common knowledge.

The current paper aims to build a foundation for CLC formalizations for MAS by investigating how CLC can be defined and reasoned over using the Lean prover [8]. Lean is an interactive proof assistant based on dependent type theory, and its mathematical library Mathlib [25] is a rapidly growing community-driven project that we made thankful use of. In this work, we use Lean to formalize the syntax and semantics of CLC and formalize the soundness and completeness theorem together with the finite model property of CLC as given by Agotnes and Alechina [1]. Formalizing these proofs allows us to check that the syntax and semantics of CLC defined in Lean relate to one another as expected. Additionally, doing so demonstrates that these definitions can be used in nontrivial proofs about CLC.

Since we closely follow the Agotnes and Alechina proof in our formalization, we will focus on the larger scale proof engineering aspects and show only relevant excerpts of these proofs. A full, sorry-free, version of our code is available online at [https://github.com/kaiobendrauf/cl-lean](https://github.com/kaiobendrauf/cl-lean). The formalization of CLC is part of a larger work [21], where the entire proofs and their formalization are given in as much detail as possible. This larger work [21] also formalizes soundness and completeness of CL. Although the current paper focuses on CLC, we give special attention to lemmas and definitions that are also used in the completeness proof for CL. Thus we illustrate the ways in which we prioritize generalizability and reusability in our Lean implementation. The intention of this design choice is to make our formalization easier for future work to extend.

In the following sections we give a brief overview of existing work formalizing logics related to CLC in Section 2 and an overview of the Lean prover and its mathematical library in Section 3. We give a detailed description of the syntax, semantics and axiomatic system of CLC in Section 4. We describe our definition of CLC in Lean in Section 5. Our formalization of the soundness of CLC is described in some detail in Section 6. Section 7 notes a method of making our formalization reusable for other logics. Finally, using these definitions we will prove in Lean that CLC is complete in Section 8.

## 2 Related Work

The formalization of modal logics in proof assistants is an active area of research. To our knowledge, CLC has not yet been formalized in any proof assistant, however our work builds on related work on formalizing Epistemic Logics (EL) and CL. We start by describing work on CL. Nalon et al. [18] present a prototype automated reasoning tool for CL, based on a sound, complete, and terminating resolution-based calculus for CL in SWI-Prolog. On the other hand, Baston and Capretta [5] propose how to formalize the relation between strategic games and the effectivity operator in CL. These works provide support that CL can be defined and reasoned with in proof assistants. However, to the best of our knowledge, at this point in time there are no current works that formalize completeness of CL in any proof assistant, nor has any project formalized CL in Lean.

In contrast there are several existing formalizations of EL both in Lean [6, 17, 19] and other proof assistants [7, 9, 16]. In Lean, the first of these is the completeness proof of EL (S5) by Bentzen [6]. Following this, both Neeley [19] and Li [17] formalized completeness again, but with different approaches, showing how flexibly such proofs can be implemented in Lean. We will, when possible, defer to these existing works on formalizing EL in Lean for guidance on implementation choices. Most often, we use ideas by Neeley [19] as she uses the same type of proof as Agotnes and Alechina [1] while being particularly detailed about her design decisions. Furthermore, this work formalizes several logics, thus we know the design decisions generalize to multiple types of logic.

## 3 The Lean Prover and Mathlib

We used the Lean theorem prover [8] in our formalization. Lean is an interactive theorem prover based on the Calculus of Inductive Constructions, featuring proof irrelevance, quotient types and classical reasoning. These features are used ubiquitously throughout the flagship mathematical library for Lean, Mathlib [25], which we used as a starting point for our own formalization. An introduction to Lean can be found at [3].

A characteristic aspect of Mathlib is its use of typeclasses to organize mathematical theories. Lean's typeclass system extends the class mechanism introduced for operator overloading in Haskell [28], and are used to associate types with both operators and axioms about these operators. Moreover, the typeclass system permits extending structures, so that, for example, any theorem declared for a `Monoid M` will automatically apply to a type `G` for which a `Group G` instance exists. The typeclass system is invoked by placing parameters to declarations between square brackets. An instance synthesis algorithm is used to supply values for these parameters automatically, through a variation on depth-first search [23].

In 2023, Mathlib was ported from Lean 3 to the newly released Lean 4, a port that required substantial changes in notation and design choices. Our project was originally written for Lean 3 and after the proofs were completed, we ported it to Lean 4. The code we present in our paper is an abridged version of the Lean 4-compatible source code, using Lean version 4.4.0-rc1 and Mathlib commit 98fe17fd. Although this paper omits many proof steps for presentational purposes, in our accompanying formalization all proofs are complete and sorry-free.

## 4 Coalition Logic with Common Knowledge

We recall the syntax and semantics of CLC, as well as the axiomatization, following Agotnes and Alechina [1], in their work extending CL [22].

Based on a finite, non-empty set $N$ of agents, and a set $\Phi_0$ of atomic propositions, CLC formulas are constructed using the usual propositional logic operators, the CL effectivity operator $[G]$, where $G \subseteq N$, and two epistemic operators: $K_i$ for individual knowledge, where $i \in N$, and $C_G$ for common knowledge. Formally, CLC formulas are defined by the following BNF grammar:

$$\varphi := \bot \mid p \mid \varphi \wedge \varphi \mid \varphi \to \varphi \mid [G]\varphi \mid K_i\varphi \mid C_G\varphi$$

where $p \in \Phi_0$, $G \subseteq N$ and $i \in N$. We note that our syntax here is slightly different from that of Agotnes and Alechina [1], as we allow the case when $G = \emptyset$ for the $C_G\varphi$ operator. Additionally, based on Neeley [19], we use a non-minimal set of propositional operators as this simplifies our proofs in Lean.

$[G]\varphi$ expresses the effectivity of a coalition to achieve $\varphi$. Intuitively, $[G]\varphi$ can be read as "coalition group $G$ can ensure $\varphi$, regardless of the actions of agents not in the coalition". $K_i$ expresses the knowledge of an agent $i \in N$. Thus, $K_i\varphi$ can be intuitively read as "agent $i$ knows $\varphi$". This individual knowledge can be extended to groups via the derived operator $E_G$, using the conjunction of individual knowledge. Specifically, for $G \subseteq N$, the notation $E_G\varphi$ is defined as $E_G\varphi := \bigwedge_{i \in G} K_i\varphi$ and reads as "everyone in group $G$ knows $\varphi$". $C_G\varphi$ expresses that group $G$ has common knowledge of $\varphi$. Intuitively this can be read as "everyone in group $G$ knows $\varphi$, and they all know that they all know $\varphi$, and they all know that they all know that they all know $\varphi$ and so on".

The semantics of CLC is based on epistemic coalition frames and models. An epistemic coalition model contains an epistemic accessibility relation $\sim_i$ for each agent $i \in N$. These are equivalence relations that model what each agent knows. Specifically, if $(s, t) \in {\sim_i}$ for some agent $i$, written as $s \sim_i t$, then agent $i$ cannot differentiate state $s$ and state $t$.

Additionally epistemic coalition frames and models contain an effectivity structure $E$ which represents the effectivity of coalitions. Given a non-empty set $S$ of states, $E$ maps a state and subset of $N$ to a set of subsets of $S$, i.e. $E : S \to \mathcal{P}(N) \to \mathcal{P}(\mathcal{P}(S))$. Note that, given some state $s \in S$ and set of agents $G \subseteq N$, $E(s)(G)$ denotes a set of sets of states. Intuitively, if $X \in E(s)(G)$, the coalition $G$ must have some joint strategy in state $s$ such that, no matter the strategy of agents not in the coalition, we are guaranteed to end up in some $t \in X$. In this way the effectivity structure models the ability of coalitions to ensure some (sets of) outcomes while abstracting away specific actions and strategies. In order to adequately model a coalition's effectivity we require specific properties to hold, which are collectively defined by the concept of true playability.

**Definition 1 (True Playability).** A truly playable effectivity structure is an effectivity structure $E$ such that for any state $s$, $E(s)$ meets the following 6 conditions [1, Section 2.1].

1. $E(s)$ is **live**: for every $G \subseteq N$, $\emptyset \notin E(s)(G)$
2. $E(s)$ is **safe**: for every $G \subseteq N$, $S \in E(s)(G)$
3. $E(s)$ is **$N$-maximal**: for every $X \subseteq S$, if $(S \setminus X) \notin E(s)(\emptyset)$, then $X \in E(s)(N)$
4. $E(s)$ is **outcome monotonic**: for every $G \subseteq N$ and $X, Y \subseteq S$, if $X \in E(s)(G)$ and $X \subseteq Y$, then also $Y \in E(s)(G)$
5. $E(s)$ is **superadditive**: for all $C, D \subseteq N$ where $C \cap D = \emptyset$, and all $X, Y \subseteq S$, if $X \in E(s)(C)$ and $Y \in E(s)(D)$, then $X \cap Y \in E(s)(C \cup D)$
6. $E(s)(\emptyset)$ is **principal**: there exists an $X \in E(s)(\emptyset)$ such that for every $Y \in E(s)(\emptyset)$, we have $X \subseteq Y$.

We have now everything to define epistemic coalition frames and models formally.

**Definition 2.** An epistemic coalition frame is a tuple $F = (S, E, \{\sim_i : i \in N\})$, where
- $S$ is a non-empty set of states,
- $E : S \to (\mathcal{P}(N) \to \mathcal{P}(\mathcal{P}(S)))$ is a truly playable effectivity structure, and
- $\sim_i \subseteq S \times S$ is an equivalence relation, the epistemic accessibility relation over $S$ for agent $i$.

**Definition 3.** An epistemic coalition model is a tuple $M = (F, V)$, where:
- $F$ is an epistemic coalition frame, and
- $V : \Phi_0 \to \mathcal{P}(S)$ is the usual valuation function, assigning to each $p \in \Phi_0$ some set of states $V(p) \subseteq S$.

Based on an epistemic coalition model $M = (F, V)$, where $F = (S, E, \{\sim_i : i \in N\})$, and some state $s \in S$, we can now define what it means for a CLC formula $\varphi$ to be true in $s$ (written as $M, s \models \varphi$). Truth of $[G]\varphi$ relates to the effectivity structure: if in state $s$ group $G$ is effective in bringing about $\varphi$, then $G$ must be able to restrict the possible next states to some set containing only states where $\varphi$ is true. $K_i\varphi$ relates intuitively to the $\sim_i$ relation: if agent $i$ knows $\varphi$ in state $s$, then $\varphi$ must be true in all states that $i$ cannot distinguish from $s$. The operator $C_G\varphi$ is a little more complex, as here we need to consider paths through epistemic relations. For readability, we write $(s, t) \in (\bigcup_{i \in G} {\sim_i})^*$ as $s \approx_G t$. If group $G$ has common knowledge of $\varphi$ in state $s$, then $\varphi$ must be true in all states $t$ such that $s \approx_G t$.

Truth in $M, s$ is now defined as follows:

$$M, s \not\models \bot$$

$$M, s \models p \quad \text{iff} \quad p \in \Phi_0 \text{ and } s \in V(p)$$

$$M, s \models \varphi \wedge \psi \quad \text{iff} \quad M, s \models \varphi \text{ and } M, s \models \psi$$

$$M, s \models \varphi \to \psi \quad \text{iff} \quad M, s \models \varphi \Rightarrow M, s \models \psi$$

$$M, s \models [G]\varphi \quad \text{iff} \quad \{s \in S \mid M, s \models \varphi\} \in E(s)(G)$$

$$M, s \models K_i\varphi \quad \text{iff} \quad \forall t \in S,\; s \sim_i t \Rightarrow M, t \models \varphi$$

$$M, s \models C_G\varphi \quad \text{iff} \quad \forall t \in S,\; s \approx_G t \Rightarrow M, t \models \varphi$$

As usual, $\varphi$ is valid in a model ($M \models \varphi$) if it is true in every state of the model and is globally valid ($\models \varphi$) if it is valid in all models.

### Axiomatization of CLC

The axiomatization of CLC is given in Table 1.

| Axiom | Statement |
|-------|-----------|
| (Prop) | Propositional tautologies |
| (K)   | $\vdash K_i(\varphi \to \psi) \to (K_i\varphi \to K_i\psi)$ |
| (T)   | $\vdash K_i\varphi \to \varphi$ |
| (4)   | $\vdash K_i\varphi \to K_iK_i\varphi$ |
| (5)   | $\vdash \neg K_i\varphi \to K_i\neg K_i\varphi$ |
| (C)   | $\vdash C_G\varphi \to E_G(\varphi \wedge C_G\varphi)$ |
| ($\bot$) | $\vdash \neg[G]\bot$ |
| ($\top$) | $\vdash [G]\top$ |
| (N)   | $\vdash (\neg[\emptyset]\neg\varphi) \to [N]\varphi$ |
| (M)   | $\vdash [G](\varphi \wedge \psi) \to [G]\varphi$ |
| (S)   | $\vdash ([G]\varphi \wedge [F]\psi) \to [G \cup F](\varphi \wedge \psi)$, if $G \cap F = \emptyset$ |
| (MP)  | $\vdash \varphi$, $\varphi \to \psi \Rightarrow \vdash \psi$ |
| (RN)  | $\vdash \varphi \Rightarrow \vdash K_i\varphi$ |
| (Eq)  | $\vdash \varphi \leftrightarrow \psi \Rightarrow \vdash [G]\varphi \leftrightarrow [G]\psi$ |
| (RC)  | $\vdash \psi \to E_G(\varphi \wedge \psi) \Rightarrow \vdash \psi \to C_G\varphi$ |
