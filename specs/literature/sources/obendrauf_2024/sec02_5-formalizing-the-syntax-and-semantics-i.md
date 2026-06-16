## 5 Formalizing the Syntax and Semantics in Lean

To formalize the syntax of CLC in Lean, we use a deep embedding, which allows us to prove metatheoretical results about the logic such as soundness and completeness [14, 19]. Thus, in Lean, the language of CLC formulas is defined as an inductive type, meaning the smallest type closed under the operators `bot`, `var`, `and`, `imp`, `eff`, `K` and `C`.

```lean
inductive formCLC (agents : Type) : Type
  | bot                                           : formCLC agents
  | var   (n     : Nat)                           : formCLC agents
  | and   (φ ψ   : formCLC agents)                : formCLC agents
  | imp   (φ ψ   : formCLC agents)                : formCLC agents
  | eff   (G     : Set agents) (φ : formCLC agents) : formCLC agents
  | K     (a     : agents)     (φ : formCLC agents) : formCLC agents
  | C     (G     : Set agents) (φ : formCLC agents) : formCLC agents
```

The inductive type is parameterized over an arbitrary type `agents`. At this point we do not require that only finitely many agents appear in the formula. Instead, we will apply this assumption only to those theorems whose proofs require it, guided by the automated proof checking done by Lean.

To define the semantics, we first define effectivity structures:

```lean
def effectivity_struct (agents states : Type) :=
  states → Set agents → Set (Set states)
```

To represent a playable effectivity structure, we create a 6-tuple to link the effectivity function itself to the 5 playability requirements. Thus, we need to store tuples of a certain shape, which in Lean we do using a `structure` data type:

```lean
structure truly_playable_effectivity_struct (agents states : Type) :=
  (E                   : effectivity_struct agents states)
  (liveness            : ∀ s : states, ∀ G : Set agents, ∅ ∉ E s G)
  (safety              : ∀ s : states, ∀ G : Set agents, univ ∈ E s G)
  (N_max               : ∀ s : states, ∀ X : Set states, Xᶜ ∉ E s ∅ → X ∈ E s univ)
  (mono                : ∀ s : states, ∀ G : Set agents, ∀ X Y : Set states,
                           X ⊆ Y → X ∈ E s G → Y ∈ E s G)
  (superadd            : ∀ s : states, ∀ G F : Set agents, ∀ X Y : Set states,
                           X ∈ E s G → Y ∈ E s F → G ∩ F = ∅ →
                           X ∩ Y ∈ E s (G ∪ F))
  (principal_E_s_empty : ∀ s, ∃ X, X ∈ E s ∅ ∧ ∀ Y, Y ∈ E s ∅ → X ⊆ Y)
```

Comparing the semantics defined in Section 4, we can see a particular difference in the treatment of sets: where informally we write $X \in E(s)(N)$, Lean writes `X ∈ E s univ`. Since Lean is based on type theory, it distinguishes `agents : Type` from its universal set `univ : Set agents`. Apart from this distinction, the conditions translate straightforwardly.

Epistemic coalition frames and models are then defined as follows:

```lean
structure frameECL (agents : Type) :=
  (states : Type)
  (hs     : Nonempty states)
  (E      : truly_playable_effectivity_struct agents states)
  (rel    : agents → states → Set states)
  (rfl    : ∀ i s, s ∈ rel i s)
  (sym    : ∀ i s t, t ∈ rel i s → s ∈ rel i t)
  (trans  : ∀ i s t u, t ∈ rel i s → u ∈ rel i t → u ∈ rel i s)

structure modelECL (agents : Type) :=
  (f : frameECL agents)
  (v : N → Set f.states)
```

To encode semantic entailment, we first formalize the common knowledge path as a recursively defined predicate that we call a `C_path`.

```lean
inductive C_path {agents : Type} {m : modelECL agents} (G : Set agents) :
    m.f.states → m.f.states → Prop
  | done (hi : i ∈ G) (hst : t ∈ m.f.rel i s) : C_path G s t
  | next (hi : i ∈ G) (hsu : u ∈ m.f.rel i s) (ih : C_path G u t) :
      C_path G s t
```

Intuitively, we say given a coalition $G$ that there is a path from state $s$ to state $t$ if we can give, for some $n \geq 1$, some list $i_0, i_1, \ldots, i_n$ of agents in $G$, as well as some list $u_1, u_2, \ldots, u_n$ of states, such that $s \sim_{i_0} u_1$, $u_1 \sim_{i_1} u_2$, $\ldots$, $u_n \sim_{i_n} t$. $s \approx_G t$ then means that there is a `C_path` from $s$ to $t$, where every agent in the list of agents is also in $G$. From here, defining semantic entailment is straightforward, so we show only the non-propositional cases:

```lean
def s_entails_CLC {agents : Type} (m : modelECL agents) (s : m.f.states) :
    formCLC agents → Prop
  ...
  | (_[G] φ)  => {t : m.f.states | s_entails_CLC m t φ} ∈ m.f.E.E s G
  | (.K i φ)  => ∀ t : m.f.states, t ∈ m.f.rel i s → s_entails_CLC m t φ
  | (.C G φ)  => ∀ t : m.f.states, C_path G s t → s_entails_CLC m t φ
```

## 6 Formalizing Soundness

The axiomatization of CLC (Table 1) is defined as an inductive predicate, that is, as an inductively defined proposition [4]. An inductive predicate is defined as the smallest predicate closed under a set of proof steps. Thus, an inductive predicate contains all proofs constructed from a finite tree of proof steps. This mirrors how the set of formulas provable in an axiomatic system is the smallest set closed under rule applications. The translation to Lean is thus very straightforward and omitted here. Before we come to the more challenging proof of completeness of this system, we prove its soundness.

**Theorem 4 (Soundness of CLC [1, Lemma 1]).** $\forall \varphi,\; \vdash \varphi \Rightarrow\; \models \varphi$

Despite the proof itself being simple, translating it into Lean is not entirely straightforward. We prove this theorem by structural induction on the proof of $\vdash \varphi$. Most of the cases can be proven directly from the given axiom. Note that axioms ($\bot$), ($\top$), (N), (M) and (S) relate directly to the first five true playability requirements, and axioms (T), (4) and (5) relate to the fact that epistemic relations are equivalence relations.

The cases (C) and (RC) are a little more complex, as they involve the $C_G$ operator. To show that a formula of the form $C_G\varphi$ is true, we need to reason about the common knowledge relation $\approx_G$. More specifically, in Lean we have to look for `C_path`s between states. To illustrate how this is done, we look closer at the case for Axiom (C). Given $M, s \models C_G\varphi$, we need to show $M, s \models E_G(\varphi \wedge C_G\varphi)$, which gives the following goal after simplifying:

```lean
h   : M, s ⊨ C G φ
hi  : i ∈ G
hts : t ∈ M.f.rel i s
⊢ M, t ⊨ φ ∧ C G φ
```

For the first half of the conjunction, we apply the hypothesis `h`, so it remains to prove that `C_path G s t` holds. In this case the path will have length one, so that the constructor `C_path.done` applies, and our existing hypothesis `hts : t ∈ M.f.rel i s` concludes this case.

For the second half of the conjunction, we get the following goal after simplification:

```lean
h   : M, s ⊨ C G φ
hi  : i ∈ G
hts : t ∈ M.f.rel i s
htu : C_path G t u
⊢ M, u ⊨ φ
```

Intuitively for any state $u$ such that $t \approx_G u$, we must show $M, u \models \varphi$. Again we apply `h`, leaving us to show `C_path G s u` which must hold when we extend `C_path G t u` by first using agent $i$ to pass from $s$ to $t$. This corresponds to the `C_path.next` constructor of `C_path`, using the hypotheses `hts` and `htu` to discharge the remaining goals.

## 7 Creating Reusable Definitions in Lean

Before tackling the completeness proof for CLC, we note that the proof relies in large part on lemmas and definitions taken from Pauly's completeness for CL [22]. In paper proofs such reuse is trivial, but in Lean lemmas and definitions only apply to the syntax they are defined on, since the syntax and proof system for each logic form a distinct inductive type. Our formalization therefore gives special attention to reusability using the typeclass system of Lean, to limit the need for redundant copies of code for each logic. Specifically, we make use of the fact that one logic commonly extends another by adding new operators and axioms. In Lean we define a class for some logic in such a way that all extensions of that logic are an instance of that class. We can then construct definitions and proofs in Lean that apply to any logic that is an instance of that class. Doing so allows our Lean results to be reused across different logics.

We start by creating a typeclass for logics whose syntax extends that of propositional logic. More precisely, an instance of `Pformula form`:

```lean
class Pformula (form : Type) :=
  (bot : form)
  (var : N → form)
  (and : form → form → form)
  (imp : form → form → form)
```

We also introduce notation for formulas: `⊥'`, `∧'`, `→'`, `⊤'`, `¬'`, `∨'`, `⇔'`. Next, we demonstrate that the language of CLC formulas `formCLC` extends propositional logic by registering an instance.

```lean
instance formulaCLC {agents : Type} : Pformula (formCLC agents) :=
  { bot := formCLC.bot,
    var := formCLC.var,
    and := formCLC.and,
    imp := formCLC.imp, }
```

We can then make our formula constructions generic over all syntaxes that have a `Pformula` instance, and Lean will automatically infer this instance when applying these constructions. For instance, the following definition gives the conjunction of a finite list of formulas.

```lean
def finite_conjunction {form : Type} [Pformula form] : List form → form
  | []       := ⊤'
  | (f :: fs) := f ∧' finite_conjunction fs
```

Since all provable propositional formulas are also provable in logics that extend propositional logic, we also introduce a class `Pformula_ax (form : Type) [Pformula form]` that denotes the existence of a provability predicate `⊢'` such that `⊢' φ` holds for all formulas $\varphi$ provable by the axioms of propositional logic.

We create three more typeclasses relevant to CLC. Logics (extending) CL are instances of `class CLformula (agents : outParam Type) (form : Type) [Pformula_ax form]`, which specifies the additional operator and axioms associated with CL. Note that this typeclass inherits from `Pformula_ax` as CL extends propositional logic. Similarly we introduce `class Kformula (agents : outParam Type) (form : Type) [Pformula_ax form]` representing logics that extend propositional logic with individual knowledge. Lastly we create a typeclass for logics with common knowledge, which must therefore also contain individual knowledge. This typeclass must therefore inherit from both `Pformula_ax` and `Kformula`:

```lean
Cformula (agents : outParam Type) [hN : Fintype agents] (form : Type)
  [pf : Pformula_ax form] [kf : Kformula agents form]
```

## 8 Formalizing Completeness

We begin by sketching the completeness proof for CLC [1, Corollary 1], which is based on a canonical model construction. For each consistent formula, we create a finite model for which that formula is true at some state. We focus on finite models because the 6th true playability condition, that $E(s)(\emptyset)$ is principal, is always met in finite models [12]. Doing so simplifies the proof that the effectivity structure in these models is truly playable. In the process we demonstrate that CLC has the finite model property.

We create such a finite model by first creating a single infinite canonical coalition model where every consistent formula is true in some state. This canonical coalition model is defined analogously to an epistemic coalition model, but without epistemic relations, and where the effectivity structure only meets the first 5 true playability conditions. Then, given some consistent formula $\varphi$, we filter the canonical coalition model and add epistemic relations to form a finite epistemic coalition model for which $\varphi$ is true in some state.

### 8.1 Formalizing the Canonical Coalition Model

We start by building the canonical coalition model. We define $M^C := (F^C, V^C)$, where $F^C := (S^C, E^C)$ as follows:

- $S^C$ is the set of all maximal CLC-consistent sets of formulas.
- $E^C$ is the playable effectivity structure:
  - $X \in E^C(s)(N)$ iff $\forall \varphi,\; \widetilde{\varphi} \subseteq X^c \to [\emptyset]\varphi \notin s$, where $\widetilde{\varphi} := \{t \in S^C \mid \varphi \in t\}$
  - $X \in E^C(s)(G)$ iff $\exists \varphi,\; \widetilde{\varphi} \subseteq X \wedge [G]\varphi \in s$, when $G \neq N$
- $V^C$ is the usual valuation function: $s \in V^C(p)$ iff $p \in s$.

A playable effectivity structure must meet the first 5 true playability conditions. A set $\Sigma$ of formulas is consistent iff there are no $\sigma_1, \ldots, \sigma_n \in \Sigma$ such that $\vdash (\sigma_1 \wedge \ldots \wedge \sigma_n) \to \bot$. The proof that $M^C$ is indeed a coalition model is analogous to the proof by Pauly [22, Lemma 5.2] for CL. In Lean, we use our generic classes for propositional logic and CL to define a canonical coalition model for any logic that extends CL, so long as that logic's axiomatic system is consistent (as required by the hypothesis `hnpr : ¬ ⊢ (⊥ : form)`):

```lean
def canonical_model_CL [Nonempty agents]
    [Pformula_ax form] [CLformula agents form]
    (hnpr : ¬ ⊢ (⊥ : form)) : modelCL agents
```

Note that this definition includes the proof that the defined effectivity structure is playable.
