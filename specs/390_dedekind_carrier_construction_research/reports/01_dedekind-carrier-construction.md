# Research Report: Task #390 — Dedekind-Complete Carrier Construction

**Task**: 390 — `dedekind_carrier_construction_research`
**Type**: lean4 | **Topic**: completeness | **Effort**: large
**Mode**: hard (H2 anti-analysis, H3 reference grounding Tier 1, H4 adversarial verification)
**Session**: `sess_1785167491_0e2961`
**Date**: 2026-07-27

---

## Executive Summary

**VERDICT: GO on the carrier question — the carrier requires no construction at all.**
**The umbrella Dedekind-completeness effort is CONDITIONAL on three missing axioms and a
substantial new transfer development, all enumerated below.**

The premise of the task description — that a Dedekind-complete carrier must be *produced*, and
that the countability of the chronicle limit domain `X` obstructs this — is **incorrect**, and
the literature is unambiguous about why. Reynolds 1992 achieves weak completeness over real flow
**without ever completing anything**: the carrier `ℝ` is fixed in advance, and a countable
rational-flowed model is transferred onto it by a bounded-quantifier-depth (Doets) argument.

Three findings carry the verdict:

1. **The cardinality obstruction is real but not binding.** It correctly shows `X` cannot itself
   be Dedekind-complete and dense. But `X` was never the carrier — the ROADMAP's own
   natural-inclusion approach already has `X ⊂ ℚ` with the carrier being `ℚ`, strictly larger
   than `X`. Substituting `ℝ` for `ℚ` is the same move.

2. **The live scaffolding already instantiates at `ℝ` with zero modifications** — compile-verified,
   not asserted. `ParametricCanonicalTaskFrame` and `ParametricCanonicalTaskModel` take exactly
   `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`, which `ℝ` satisfies. There is no
   carrier-construction work item.

3. **Dedekind completeness is not modally definable, and Reynolds says so explicitly.** No axiom
   characterizes it. The Prior-U/Prior-S axioms enforce a *definably* Dedekind-complete model —
   Reynolds, printed p.169: *"there may be gaps in the order but ... you wouldn't know that just
   looking at the behaviour of temporal formulas."* This resolves Q4 and simultaneously explains
   why the completion route (Q2) is unsound without those axioms.

**Two stale anchors in the task description** materially affected navigation and are corrected in
Finding 0; neither changes the verdict, but one (`MCSMixedCase.lean`) is at a different path than
stated and all `Theories/Bimodal/` paths are wrong.

---

## Finding 0: Anchor Discrepancies (report-first, per instruction 1)

Every path in the task description prefixed `Theories/Bimodal/` **does not exist**. The library
root is `FormalSystem/` (consistent with `CLAUDE.md`, which the description contradicts). Line
numbers have also drifted. Corrected table:

| Description anchor | Actual location | Status |
|---|---|---|
| `Theories/Bimodal/Semantics/Validity.lean:73` (`valid`) | `FormalSystem/Semantics/Validity.lean:79` | Content confirmed, line +6 |
| `...Validity.lean:162` (`valid_dense`) | `FormalSystem/Semantics/Validity.lean:169`, named **`ValidDense`** | Confirmed; name differs from description's `valid_dense` |
| `...Validity.lean:180` (`valid_discrete`) | `FormalSystem/Semantics/Validity.lean:187`, named **`ValidDiscrete`** | Confirmed; name differs |
| `...Kamp/DedekindINF.lean:44` | `FormalSystem/Metalogic/WeakCanonical/Kamp/DedekindINF.lean:~50` | Claim confirmed verbatim |
| `...BXCanonical/Completeness.lean:66` (`neg_consistent_of_not_derivable`) | `FormalSystem/Metalogic/BXCanonical/Completeness.lean:72` | Confirmed, generic in `fc` |
| `...BXCanonical/Completeness.lean:168-179` | `FormalSystem/Metalogic/BXCanonical/Completeness.lean:173-193` | Claim confirmed |
| `...Chronicle/MCSMixedCase.lean:34` | `FormalSystem/Metalogic/**BXCanonical**/Chronicle/MCSMixedCase.lean:42` | **Different directory** than stated |
| `Metalogic/WeakCanonical/EFGames/Defs.lean:230` (`structure Gap`) | `FormalSystem/Metalogic/WeakCanonical/EFGames/Defs.lean:248` | Confirmed |

ROADMAP anchors verified as accurate in substance: lines 317-320 (dense domains wrong for general
completeness; Burgess uses sparse `X ⊂ ℚ`), ~1414 (Representation Theorem Goal enumerates
`D' = ℚ`/`ℚ`/`ℤ`, no reals row), ~1477 (limit domain `X` countable).

`DedekindINF.lean`'s claim that no `ℝ` `OrderedMonadicStructure` exists anywhere in the tree is
**confirmed by grep**: every `ℝ` occurrence in `FormalSystem/` outside `Boneyard/` is either a
docstring counterexample (`Lemma53.lean:274-276`, `Section5Correspondence.lean:129-139`,
`Prop42Faithful.lean:93-94,271`) or an unrelated topology import
(`ChronicleToCountermodelBasic.lean:16-17`). No `ℝ`-carried structure is constructed.

---

## Finding 1 (Q1): The Binder List — semantics quantify over duration **groups**

`valid` (`FormalSystem/Semantics/Validity.lean:79`) binds:

```lean
∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
  (F : TaskFrame D) (M : TaskModel F)
  (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
  (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D), TruthAt M Omega τ t φ
```

`ValidDense` (:169) adds `[DenselyOrdered D]`. `ValidDiscrete` (:187) adds
`[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D]`.

**Answer to Q1: the semantics quantify over Dedekind-complete orders arising as duration groups**,
not over bare Dedekind-complete orders. `AddCommGroup D` is present in every one of the three
predicates. This is decisive and is the single most consequential fact in this report, because a
Dedekind-complete linearly ordered abelian group is extremely rigid: it is order-isomorphic to
`ℤ` or to `ℝ` and nothing else. (Sketch: conditional completeness forces the Archimedean property —
if `n·a < b` for all `n`, then `sup {n·a}` exists, call it `s`; `s − a` is not an upper bound, so
`n·a > s − a` for some `n`, so `(n+1)·a > s`, contradiction. Archimedean linearly ordered abelian
groups embed in `ℝ`; a subgroup of `ℝ` is cyclic or dense; a complete cyclic one is `≅ ℤ`, a
complete dense one is all of `ℝ`.)

### Proposed binder list — both variants compile-verified

Two forms were written and **elaborated against the live tree with no errors** (probe file
`scratchpad/Ded.lean`, run under `lake env lean`; a deliberate bogus-identifier control was used
to confirm the harness actually reports errors — see H4 note (c) below).

**Variant A — type-class binder** (`ConditionallyCompleteLinearOrder` *replaces* `LinearOrder`;
no instance diamond arises, since `ConditionallyCompleteLinearOrder.toLinearOrder` is an instance):

```lean
def ValidDedekind (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [ConditionallyCompleteLinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    TruthAt M Omega τ t φ
```

**Variant B — Prop-valued hypothesis** (keeps the tree's existing `LinearOrder` binder, so every
downstream `[LinearOrder D]`-indexed lemma applies without instance-unification risk):

```lean
def ValidDedekind (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    TruthAt M Omega τ t φ
```

**Recommendation: Variant B.** It is strictly less invasive, and `DenselyOrdered` should be
*omitted* from the binder list (see Finding 5): including it silently commits the frame class to
`ℝ` alone and excludes `ℤ`, which is also Dedekind-complete.

The soundness-direction lemma the analogue must admit was **proved sorry-free** during this
research (satisfying the H2 formal-proof-line bar):

```lean
theorem valid_implies_validDedekind {φ : Formula} (h : valid φ) : ValidDedekind φ :=
  fun D _ _ _ _ _ F M Omega hO τ hτ t => h D F M Omega hO τ hτ t
```

This mirrors `valid_implies_valid_dense` (`Validity.lean:200`) and
`valid_implies_valid_discrete` (:207) exactly.

---

## Finding 2 (Q2): Is Dedekind completion sound for the truth lemma? — **No, and the failure is precisely a definable gap**

**Answer: completion does not automatically preserve the coherence conditions. The condition that
breaks is `ForwardUntilSinceCoherent` (dually `BackwardUntilSinceCoherent`), and it breaks at
exactly the points a definable gap would occupy.**

The truth lemma's shape forces this. `parametric_canonical_truth_lemma`
(`ParametricTruthLemma.lean:240`) is stated as

```lean
(fam : FMCS D) (hfam : fam ∈ B.families) (t : D) (phi : Formula) :
  phi ∈ fam.mcs t ↔ TruthAt (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B)
                      (parametricToHistory fam) t phi
```

`t` ranges over **all** of `D`, and `fam.mcs t` must be an MCS at every such `t`. So a completion
`X ↪ X̂` does not merely add order-points: it obliges the bundle to supply a *maximal consistent
set* at each new limit point, cohering with its neighbours under `B.TemporallyCoherent`,
`B.BackwardUntilSinceCoherent`, `B.ForwardUntilSinceCoherent`.

**The precise obstruction.** Let `r ∈ X̂ \ X` be a new limit point, and suppose `B` holds
throughout `(z, r)` for every `z < r` while `¬B` is true arbitrarily soon after `r`. Then any MCS
assigned at `r` must decide `U(A, B)`. Both choices are refutable against the neighbourhood:

- If `U(A, B) ∈ mcs r`, forward coherence demands an `A`-witness `s > r` with `B` throughout
  `(r, s)`; but `¬B` occurs arbitrarily soon after `r`, so no such `s` exists.
- If `U(A, B) ∉ mcs r`, backward coherence against points `z < r` (where `U(A,B)` does hold, since
  `B` runs to `r`) fails to propagate.

This configuration is exactly Reynolds' `γ⁺`/definable-gap pattern (§5, printed p.176:
*"`γ⁺(A)` holds exactly when `A` remains true for a while after now but only up until a gap after
which `A` is arbitrarily soon false"*). It is *not* a cardinality phenomenon and would arise even
completing a finite order.

**What survives.** The condition is repaired not by strengthening the completion but by
constraining the *source model*: if the pre-completion model satisfies Prior-U/Prior-S, no such
configuration exists (Reynolds §5, printed p.176, proof of Theorem 3: *"By Prior-U applied to `B`
we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction"*). Hence:

> Dedekind completion of the chronicle limit domain is sound for the truth lemma **iff** the
> chronicle model already validates Prior-U and Prior-S. Absent those axioms it is unsound, with
> the counterexample above.

**But this route should not be taken anyway** — Finding 3 shows the literature avoids completion
entirely, and the completion route additionally has to invent MCS assignments at limit points,
which the transfer route never does.

---

## Finding 3 (Q3): What the literature actually does — **transfer, not completion**

### Reynolds 1992 — a representation/transfer argument

`~/Projects/Literature/sources/reynolds_1992/Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf`

**Theorem 7** (§9, **printed p.189**, PDF index 24): *"The system US/R is sound and weakly complete
for the semantics over structures with real flow."* The proof is five steps and contains **no
completion**:

1. `A₀` is US/R-consistent. **Burgess–Xu Corollary 1** furnishes `M₀` with flow **the rationals**,
   `M₀ ⊨ A₀(0)`, and all substitution instances of Prior-U, Prior-S, Sep valid in `M₀`.
2. Discard atoms not in `A₀` → `M`, a model over a **finite** language, still `⊨ A₀`.
3. Flow of `M` is countable, dense, without endpoints; conditions **D1** and **D2** follow from
   Reynolds' Theorems 4 and 5.
4. Apply **Doets' theorem** (Theorem 6, §8, printed pp.184-188) with
   `k = 1 + qdepth(table of A₀)`: obtain `ℛ` with **flow of time the real numbers** satisfying the
   same monadic sentences of quantifier depth `≤ k` as `M`.
5. `ℛ ⊨ ∃t α(t)`, so `ℛ ⊨ A₀(b)` for some `b ∈ ℛ`. ∎

**Classification: representation argument.** `ℝ` is a *fixed target*, never constructed and never
obtained by completing `M`. The construction is a bounded-quantifier-depth equivalence between a
countable model and a pre-existing real-flowed one.

**Doets' theorem (Reynolds Theorem 6, printed p.184)**, stated verbatim in structure:

> Suppose `M` is a temporal structure in a **finite** language whose flow of time is countable,
> dense and without end points. Suppose further that for any contemporaneous equivalence relation
> `∼` on `M`:
> **D1)** the `∼` classes do not end in gaps, and
> **D2)** if `M/∼` is densely ordered, then `M/∼` has a dense set of singletons.
> Then for all `k < ω`, there is a temporal structure with flow of time **the real numbers**
> satisfying the same monadic first-order sentences of quantifier depth at most `k` as `M` does.

### GHR94 Chapter 10 §10.3 — Dedekind completeness as a **hypothesis**

`~/Projects/Literature/sources/gabbay_1994/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.pdf`

§10.3.1 (PDF index 8) and §10.3.2 (PDF indices 11-14) are a **separation / expressive-completeness**
development, not a completeness construction. Dedekind completeness appears only as a standing
assumption on given flows: *"Lemma 10.3.5 The following hold over Dedekind complete flows of
time"*, *"Lemma 10.3.7 ... over Dedekind complete flows"*, *"Lemma 10.3.8 Over Dedekind complete
time we have the following equivalences"*.

Where completeness is actually *used*, it is used to take a supremum — §10.3.2, proof of Lemma
10.3.6 part 2: *"Let `y = sup{z' ∈ (z, t₁) | for all u ∈ (z, z'), ‖B‖ᵤ = 1}`. Since `‖¬K⁺(¬B)‖_z = 1`
we know that `y` exists and is `> z`."* That is the entire role of the hypothesis.

**Classification: neither completion nor construction — an assumed frame condition.**

GHR94 §10.3.1 also supplies the `K±` and `Γ±` connectives the tree already mirrors:
`K⁺q = ¬U(⊤, ¬q)`, `K⁻q = ¬S(⊤, ¬q)`, `Γ⁺(B) = ¬K⁺(¬B) ∧ K⁻(¬B)`, `Γ⁻(B) = ¬K⁻(¬B) ∧ K⁺(¬B)`.
Note §10.3.1's remark that *"In integer time, these connectives are not very interesting for
`K⁺q = K⁻q = ⊤`"* — relevant to Finding 5.

### Summary answer to Q3

| Source | Carrier treatment | Anchor |
|---|---|---|
| Reynolds 1992 §9 | **Representation/transfer** onto pre-existing `ℝ` via Doets | printed p.189 |
| Reynolds 1992 §8 | Doets' theorem: countable+dense+D1+D2 ⟹ real-flowed `k`-equivalent | printed pp.184-188 |
| GHR94 §10.3 | Dedekind completeness **assumed** as frame condition | PDF idx 8-14 |

**Neither source performs a Dedekind completion. Neither constructs a Dedekind-complete carrier.**

---

## Finding 4 (Q4): The characterizing axiom — **none exists; Prior-U/Prior-S is the definable proxy**

Reynolds, **printed p.169** (PDF index 4), is explicit and settles this question:

> *"The Prior axioms enforce a **definably** Dedekind complete model. This means that there may be
> gaps in the order but that, as we make precise later, you wouldn't know that just looking at the
> behaviour of temporal formulas. The axioms are valid in structures over the reals because there
> are no gaps at all so no definable ones."*

**Answer to Q4: Dedekind completeness is not modally/temporally definable, so no axiom
characterizes it.** The strongest available axiomatic proxy is definable gap-freeness, given by
Reynolds' three axioms (**printed p.168**, PDF index 3):

```
Prior-U:  U(⊤, p) ∧ F¬p → U(¬p ∨ K⁺(¬p), p)
Prior-S:  S(⊤, p) ∧ P¬p → S(¬p ∨ K⁻(¬p), p)
Sep:      K⁺p ∧ ¬K⁺(p ∧ U(p, ¬p)) → K⁺(K⁺p ∧ K⁻p)
```

Reynolds notes (printed p.176) that a linear temporal structure satisfying all substitution
instances of Prior-U and Prior-S — a **Prior structure** — has no definable gaps, and Theorem 3
gives `U, S` expressive completeness over that class. `Sep` is separately associated with the
*separability* of `ℝ` (countable dense suborder), and Reynolds observes (§7) that it does **not**
characterize separability either — the 'long line' also satisfies it.

### Where these slot into the tree

`FormalSystem/ProofSystem/Axioms.lean:84` (`inductive Axiom`) currently has **42 constructors** in
three frame classes (`Axiom.minFrameClass`, :410-418): Base (37), Dense (2: `density`,
`dense_indicator`), Discrete (3: `prior_UZ`, `prior_SZ`, `z1`).

**Critical distinction that must not be missed.** The tree's existing `prior_UZ`/`prior_SZ`
(:315, :320) are the **integer/well-ordering** Prior axioms, *not* Reynolds' gap axioms:

| | Tree (`Axioms.lean:315,320`) | Reynolds (printed p.168) |
|---|---|---|
| Form | `F(φ) → U(φ, ¬φ)` | `U(⊤, p) ∧ F¬p → U(¬p ∨ K⁺(¬p), p)` |
| Meaning | nearest future `φ`-point exists (well-ordering) | no *definable* gap |
| Frame class | `.Discrete` | Dedekind / real |
| Tree docstring | *"Valid on all discrete well-founded-upward orders. Equivalent to Venema's axiom (W)"* | — |

They are **different axioms with confusingly similar names**. Reynolds' Prior-U is *not* in the
tree. Neither is `Sep`.

**Required additions**, in the order a plan should sequence them:

1. Three new `Axiom` constructors: `prior_U_gap`, `prior_S_gap`, `sep` (names chosen to avoid
   collision with the existing `prior_UZ`/`prior_SZ`). `K⁺`/`K⁻` are definable from `U`/`S` per
   GHR94 §10.3.1, so no new `Formula` constructors are needed.
2. A fourth `FrameClass` constructor, `.Dedekind`. This is the widest-blast-radius edit: it
   touches `Axiom.minFrameClass` (:410), the `LE` instance (:383), `DecidableRel` (:391),
   `PartialOrder` (:395), and every `cases fc` / `match fc` in the tree. Mechanical but broad.
3. `Dedekind` must sit **above** `Dense` in the `FrameClass` order (real flow is dense), unlike
   `Dense` and `Discrete` which are incomparable. The current `LE` instance is a flat
   three-case match with no `Base < Dense < Dedekind` chain; it needs genuine restructuring, not
   just a new arm.

---

## Finding 5: `ℤ` is also Dedekind-complete — the frame class is not `ℝ`-only

`ConditionallyCompleteLinearOrder ℤ` **exists in Mathlib** (verified;
`Mathlib/Data/Int/ConditionallyCompleteOrder.lean:29`, noncomputable). Every nonempty bounded
subset of `ℤ` has a supremum. So "Dedekind-complete duration group" admits `ℤ` as well as `ℝ`.

Consequences:

- Adding `[DenselyOrdered D]` to the `ValidDedekind` binder list **silently narrows the frame
  class to `ℝ` alone**. If the intent is "Dedekind-complete", omit it; if the intent is "real
  flow", include it and say so in the docstring.
- GHR94 §10.3.1's remark that `K⁺q = K⁻q = ⊤` in integer time means the `K±` machinery
  **degenerates on `ℤ`**. A single `ValidDedekind` covering both `ℤ` and `ℝ` will therefore have
  two structurally unrelated proof branches — precisely the situation that produced the
  `completeness` sorryAx debt documented at `Completeness.lean:173-193`.
- **Recommendation**: define `ValidDedekind` *without* `DenselyOrdered` for faithfulness to the
  name, but target `ValidDedekindDense` (with it) as the theorem to prove, mirroring the existing
  `ValidDense`/`ValidDiscrete` split rather than fighting it.

---

## Finding 6: Mathlib Survey (all claims compile-verified or source-read; absences stated plainly)

Verification method note: `mcp__lean-lsp__lean_run_code` was found **unreliable in this
environment** — it returned `success: true, diagnostics: []` for a deliberately bogus identifier.
All results below were obtained instead via `lake env lean` on probe files, with a bogus-identifier
control confirming the harness does report `unknownIdentifier`. See H4 note (c).

### Present and verified

| Declaration | Verified signature / fact | Source |
|---|---|---|
| `ConditionallyCompleteLinearOrder` | `Type u_1 → Type u_1` | `#check`, clean |
| `DenselyOrdered` | `(α : Type u_1) → [LT α] → Prop` | `#check`, clean |
| `IsLUB` | `{α : Type u_1} → [LE α] → Set α → α → Prop` | `#check`, clean |
| `BddAbove` | `{α : Type u_1} → [LE α] → Set α → Prop` | `#check`, clean |
| `Order.iso_of_countable_dense` | `∀ (α β) [LinearOrder α] [LinearOrder β] [Countable α] [DenselyOrdered α] [NoMinOrder α] [NoMaxOrder α] [Nonempty α] [Countable β] [DenselyOrdered β] [NoMinOrder β] [NoMaxOrder β] [Nonempty β], Nonempty (α ≃o β)` | `#check`, clean — **Cantor's theorem** |
| `ConditionallyCompleteLinearOrder ℝ` | instance synthesizes (noncomputable) | `Mathlib/Algebra/Order/Archimedean/Real/Basic.lean:140` |
| `ConditionallyCompleteLinearOrder ℤ` | instance synthesizes (noncomputable) | `Mathlib/Data/Int/ConditionallyCompleteOrder.lean:29` |

### Dedekind completion — **Mathlib HAS one**, with a caveat that matters

`Mathlib/Order/Completion.lean` (Violeta Hernández Palacios, 2025) provides the
**Dedekind–MacNeille completion**. Source-read (this module is **not in this project's built
Mathlib cache**, so it was not compile-verified):

- `abbrev DedekindCut [Preorder α] := Concept α α (· ≤ ·)` (:52)
- `def principalEmbedding : α ↪o DedekindCut α` (:137)
- `noncomputable instance : LinearOrder (DedekindCut α)` (:218)
- `noncomputable instance : CompleteLinearOrder (DedekindCut α)` (:238)
- `instance [DenselyOrdered α] : DenselyOrdered (DedekindCut α)` (:243)
- `theorem principalEmbedding_trans_factorEmbedding` (:188) — universal property

**Do not reach for it.** Two disqualifying caveats:

1. It yields a **`CompleteLinearOrder`, i.e. it adds endpoints `⊥`/`⊤`.** The file's own Todo says
   *"Build the order isomorphism `DedekindCut ℚ ≃o EReal`"* — so completing `ℚ` gives
   `[-∞, +∞]`, **not `ℝ`**. Temporal flows need `NoMinOrder`/`NoMaxOrder`; endpoints would have to
   be excised.
2. **`DedekindCut` carries no group structure.** Grep for `AddCommGroup`/`Add` in
   `Order/Completion.lean` returns nothing. Since `valid`'s binder list requires
   `[AddCommGroup D]` (Finding 1), the order-theoretic completion is type-incorrect for this
   semantics as it stands.

### Absences (searched and not found — plainly stated)

- **No theorem characterizing a Dedekind-complete ordered abelian group as `≃o ℝ`.** Grep for
  `≃o ℝ` / `≃o Real` across Mathlib returns only analysis-specific isomorphisms
  (`Real.sqrt`, `sinhOrderIso`, `tanOrderIso`, circle-rotation lifts) — no abstract
  characterization.
- **No Hölder theorem** (archimedean linearly ordered group embeds in `ℝ`) under
  `Mathlib/Algebra/Order/`.
- **No `AddCommGroup` instance on `DedekindCut`**, as above.

**Cost impact: none of these absences is on the critical path**, because the recommended
construction never needs them — it takes `ℝ` off the shelf. Had the completion route been chosen,
all three would have been large line-items.

---

## Finding 7: Scaffolding Inventory — verified sorry-free and verified to instantiate at `ℝ`

`grep -c sorry` results (file-level, then per-declaration inspection):

| Declaration | Location | `sorry` in file | Binders on `D` / `fc` |
|---|---|---|---|
| `ParametricCanonicalTaskFrame` | `Metalogic/Algebraic/ParametricCanonical.lean:207` | **0** | `(D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`; `fc` implicit via `{fc}` |
| `ParametricCanonicalTaskModel` | `Metalogic/Algebraic/ParametricTruthLemma.lean:108` | **0** | same |
| `parametric_canonical_truth_lemma` | `.../ParametricTruthLemma.lean:240` | **0** | `(B : BFMCS D)`, coherence hyps, `(t : D)` universally quantified |
| `restricted_parametric_shifted_truth_lemma` | `.../RestrictedParametricTruthLemma.lean:119` | **0** | `(B : BFMCS (fc := fc) D)`, `root`, `h_sub : φ ∈ subformulaClosure root` |
| `fully_restricted_parametric_completeness_from_neg_membership` | `.../RestrictedParametricTruthLemma.lean:417` | **0** | as above + `h_neg_in : φ.neg ∈ fam.mcs t` |
| `neg_consistent_of_not_derivable` | `Metalogic/BXCanonical/Completeness.lean:72` | file has 18 `sorry` **string** hits, all in prose/docstrings | `{fc : FrameClass}` — generic, as described |
| `mcs_mixed_case_absurd` | `Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean:42` | **0** | `(fc : FrameClass)` explicit, as described |
| `structure Gap` | `Metalogic/WeakCanonical/EFGames/Defs.lean:248` | **0** | `(T : Type) [LinearOrder T]` |

Note on `Completeness.lean`: all 18 `sorry` matches are **documentation text**, not tactics — the
file documents its own sorryAx status at :40-49 and :173-193. The description's claim that
`neg_consistent_of_not_derivable` is sorry-free is confirmed.

`structure Gap` (:248) has exactly the right shape for "no Dedekind gaps" as a frame condition:
fields `cut`, `nonempty`, `proper`, `downward_closed`, `no_sup`, `complement_no_min`. The frame
condition would be `IsEmpty (Gap D)`.

### The decisive verification

**Compile-verified with zero errors** (probe `scratchpad/RealInst.lean`, `lake env lean`):

```lean
noncomputable example (fc : FrameClass) : TaskFrame ℝ :=
  ParametricCanonicalTaskFrame (fc := fc) ℝ

noncomputable example (fc : FrameClass) :
    TaskModel (ParametricCanonicalTaskFrame (fc := fc) ℝ) :=
  ParametricCanonicalTaskModel (fc := fc) ℝ

noncomputable example : ConditionallyCompleteLinearOrder ℝ := inferInstance
```

**The entire live parametric canonical scaffolding instantiates at `ℝ` with no modification
whatsoever.** There is no carrier-construction work item. This is the empirical core of the GO
verdict.

---

## VERDICT

### GO — on the carrier question as posed

The task asks how a Dedekind-complete carrier can be produced for the canonical-model
construction. **The answer is that it does not need to be produced.** The carrier is Mathlib's
`Real`; it already satisfies every binder the live scaffolding requires; and the literature
(Reynolds 1992 Theorem 7) obtains its real-flowed model by transfer from a countable rational
model rather than by any completion.

### The obstruction, corrected

The task description's obstruction conflates two distinct objects:

- the **chronicle limit domain `X`** — countable, and correctly cannot be Dedekind-complete-and-dense;
- the **model's time domain `D`** — already `ℚ` in the base construction per ROADMAP ~1477
  (*"`X ⊂ ℚ` regardless, and the natural inclusion works for any countable sub-order of `ℚ`"*),
  and therefore already strictly larger than `X`.

Setting `D = ℝ` is the same move that already sets `D = ℚ`. The cardinality argument is sound but
attacks a claim the construction never makes.

### CONDITIONAL — on the umbrella completeness effort

Three named preconditions, none of which concerns the carrier:

1. **Three axioms are missing** from `Axiom` (`Axioms.lean:84`): Reynolds' Prior-U, Prior-S, Sep.
   The existing `prior_UZ`/`prior_SZ` are the *integer* Prior axioms and are not substitutes
   (Finding 4).
2. **The input model does not exist.** Reynolds step 1 needs a `ℚ`-flowed model validating
   Prior-U/Prior-S/Sep. The tree's `countermodel_dense_enriched` produces a `ℚ` model for
   `FrameClass.Dense` (`density` + `dense_indicator`), which is a different axiom set.
3. **The Doets machinery in the tree is `ℤ`-specialized.** `Metalogic/WeakCanonical/IntegerModel/`
   has the right primitives — `good` (`GoodStructures.lean:78`), `VeryGood` (:86), `ContempEquiv`
   (:729), `k_equiv_of_iso` (:97), `KEquiv` (`NEquivalence.lean:81`), `orderedSumPt` (:155) — but
   its engine is `subinterval_finite_of_succ_archimedean` (:253), a **finiteness** argument with
   no dense analogue. The real route replaces it with Reynolds Theorems 4 and 5 (D1 and D2).

**Additionally**: Reynolds Theorem 7 is explicitly **weak** completeness (*"sound and weakly
complete"*, printed p.189). If the target theorem is strong completeness, this route does not
reach it and the verdict changes.

**And**: Reynolds works with plain temporal structures; this tree is bimodal (S5 ⊗ temporal) with
`TaskFrame`/`WorldHistory`/`Omega`/`ShiftClosed`. Grafting a monadic-FO transfer argument onto the
history-indexed semantics is genuinely new work not present in any source read here.

### Warning from the existing tree — confirmed as applying

`Completeness.lean:173-193` documents that general `completeness` carries sorryAx because a
Base-MCS is not automatically Discrete-consistent. **A Dedekind variant hits the structurally
identical problem**: a Base-MCS is not automatically Dedekind-consistent (it need not validate
Prior-U/Prior-S/Sep). The Dedekind countermodel must therefore be built from an MCS of its own
class, exactly as the description warns. Precondition 2 above is this warning made concrete.

---

## Proposed Phase Decomposition

Sized per H8 (~100-500 lines of output per phase, one agent run each).

| Phase | Deliverable | New declarations | Risk |
|---|---|---|---|
| 1 | `FrameClass.Dedekind` + order restructuring | `FrameClass` 4th ctor; rework `LE`/`DecidableRel`/`PartialOrder` (`Axioms.lean:383-405`); `Base < Dense < Dedekind` chain | **High blast radius** — every `cases fc` in tree |
| 2 | Three axiom constructors | `Axiom.prior_U_gap`, `.prior_S_gap`, `.sep`; extend `Axiom.minFrameClass` (:410); update `AxiomNames.lean` | Low |
| 3 | `ValidDedekind` + soundness-direction lemmas | `ValidDedekind` (Variant B, Finding 1); `valid_implies_validDedekind` (**already proved**, this report) | Low — verified to elaborate |
| 4 | Semantic soundness of the three new axioms over `ℝ` | `sound_prior_U_gap`, `sound_prior_S_gap`, `sound_sep` | Medium — `Sep` is Reynolds' lemma 10, deferred to §7 in the source |
| 5 | Gap-freeness frame condition | `IsEmpty (Gap D)` bridge lemmas against `Gap` (`EFGames/Defs.lean:248`); `Gap`-free ⟺ conditionally complete | Low-Medium |
| 6 | `ℚ`-flowed Prior/Sep model (precondition 2) | Dedekind-class analogue of `countermodel_dense_enriched` | **High** — new chronicle work |
| 7a-c | Reynolds Theorem 4 (D1), Theorem 5 (D2) | dense-flow analogues of `ReynoldsNoGaps.lean`; contemporaneity classes don't end in gaps; dense set of singletons | **High** — new mathematics, ~3 phases |
| 8a-c | Doets' theorem for real flow (Reynolds Thm 6) | dense analogue of `GoodStructures.lean`; replaces `subinterval_finite_of_succ_archimedean` | **Highest** — Reynolds §8 pp.184-188, lemmas 11-13 |
| 9 | Assembly: `completeness_dedekind` | wire Burgess–Xu → finite language → D1/D2 → Doets → `A₀` at `b` | Medium |

**Phases 1-5 are low-risk and immediately actionable.** Phases 6-8 are the real cost and should be
re-scoped after Phase 5 lands. Phase 8 is the single largest item and is where a NO-GO could still
emerge on effort grounds.

### Standing anti-patterns — compliance confirmed

- No direct `IsSuccArchimedean` proof bypassing `chronicle_gap_contradiction` is proposed.
- No "discrete bypass" is proposed; Finding 5 explicitly warns against collapsing `ℤ` and `ℝ`
  branches.
- No decidability-based route is proposed; the recommended route is a model-transfer argument.
- **Zero-debt**: no phase above is designed to land a `sorry`. Phase 8 is flagged as the
  re-scope/possible-`[BLOCKED]` point rather than a sorry-deferral point.

---

## H3 Reference Grounding — Tier 1 Lemma Mapping Table

Tier 1 (literature-backed). Citations are **stable PDF page anchors**, not `md:NN` line numbers.

| Source | Prop / Location | Lean Identifier (intended) | Type Signature / Statement | Status |
|---|---|---|---|---|
| Reynolds 1992 | Prior-U, printed **p.168** (PDF idx 3) | `Axiom.prior_U_gap` | `U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p), p)` | **ABSENT** — tree's `prior_UZ` (`Axioms.lean:315`) is the *integer* axiom `F(φ) → U(φ,¬φ)`, not this |
| Reynolds 1992 | Prior-S, printed **p.168** | `Axiom.prior_S_gap` | `S(⊤,p) ∧ P¬p → S(¬p ∨ K⁻(¬p), p)` | **ABSENT** — tree's `prior_SZ` (:320) is the integer dual |
| Reynolds 1992 | Sep, printed **p.168** | `Axiom.sep` | `K⁺p ∧ ¬K⁺(p ∧ U(p,¬p)) → K⁺(K⁺p ∧ K⁻p)` | **ABSENT** entirely |
| Reynolds 1992 | "definably Dedekind complete", printed **p.169** | (docstring for `ValidDedekind`) | Prose: gaps may exist but are temporally invisible | To be transcribed |
| Reynolds 1992 | Theorem 2, printed **p.176** | — | `{U,S,U',S'}` expressively complete over linear flows | Background only |
| Reynolds 1992 | Theorem 3, printed **p.176** | — | `{U,S}` expressively complete over **Prior structures** | Background; motivates Phase 2 |
| Reynolds 1992 | Theorem 4 (D1), §6 printed **pp.180-183** | `contemp_classes_no_gaps` | `∼`-classes do not end in gaps | **ABSENT** — Phase 7 |
| Reynolds 1992 | Theorem 5 (D2), §7 printed **p.184** | `dense_singleton_classes` | `M/∼` dense ⟹ `M/∼` has dense set of singletons | **ABSENT** — Phase 7 |
| Reynolds 1992 | Theorem 6 (Doets), §8 printed **pp.184-188** | `doets_real_transfer` | countable+dense+no-endpoints+D1+D2 ⟹ ∀k, ∃ real-flowed `k`-equivalent structure | **ABSENT** — Phase 8; `ℤ` analogue exists in `IntegerModel/` |
| Reynolds 1992 | Theorem 7, §9 printed **p.189** | `completeness_dedekind` | US/R sound + **weakly** complete over real flow | **ABSENT** — Phase 9 (target) |
| GHR94 ch10 | `K⁺`/`K⁻` defs, §10.3.1 **PDF idx 8** | `kplus` (exists) | `K⁺q = ¬U(⊤,¬q)`, `K⁻q = ¬S(⊤,¬q)` | **PRESENT** — `kplus` used in `Kamp/DedekindINF.lean`, `Lemma53.lean:282` |
| GHR94 ch10 | `Γ±`, Def 10.3.1 **PDF idx 8** | `gammaPlus`/`gammaMinus` | `Γ⁺(B) = ¬K⁺(¬B) ∧ K⁻(¬B)` | Not located in tree |
| GHR94 ch10 | Lemma 10.3.2, **PDF idx 8** | — | Over Dedekind-complete time with `c` rel. dense: `K⁺(A) ↔ ¬U(c,¬A)` | Background |
| GHR94 ch10 | Lemma 10.3.5, §10.3.2 **PDF idx 11** | — | negation lemma for `¬U(A,B)` over Dedekind-complete flows | Background |
| GHR94 ch10 | Lemma 10.3.6 (Q lemma), **PDF idx 11-12** | — | uses `y = sup{...}` — the sole use of Dedekind completeness | Background; evidence for Finding 3 |
| GHR94 ch9 | Def 8.3 (gaps) | `Gap` | `structure Gap (T) [LinearOrder T]` | **PRESENT, sorry-free** — `EFGames/Defs.lean:248` |
| Mathlib | — | `ConditionallyCompleteLinearOrder` | `Type u_1 → Type u_1` | **PRESENT, verified** |
| Mathlib | — | `Order.iso_of_countable_dense` | Cantor; full sig in Finding 6 | **PRESENT, verified** |
| Mathlib | — | `DedekindCut` | `Concept α α (· ≤ ·)`; `CompleteLinearOrder` | **PRESENT but unsuitable** (endpoints, no group structure); not in built cache |

---

## Adversarial Self-Verification (H4)

An explicit adversarial pass was run against the draft conclusions. **It changed the verdict
direction once and corrected two claims.**

### (a) Attack on the cardinality argument

**Challenge**: is "Dedekind-complete + dense + unbounded ⟹ `≅ ℝ` ⟹ uncountable" decisive?

**Result — the argument is valid but not decisive, and this inverted the draft verdict.** The
first draft of this report accepted the obstruction and was heading to NO-GO. The attack that
broke it: *the argument constrains `X`, but the construction's carrier is not `X`.* ROADMAP ~1477
already states the carrier is `ℚ` with `X ⊂ ℚ` a proper countable sub-order and `limit_f` extended
to all of `ℚ`. Once that separation is noticed, the cardinality of `X` is simply irrelevant to the
cardinality of `D`, and Reynolds' Theorem 7 confirms the literature does exactly this.

**Does the frame class dodge it by not requiring density?** Partially, and this is a real finding
rather than a dodge: `ConditionallyCompleteLinearOrder ℤ` exists (verified), so Dedekind-complete
duration groups need not be dense. Recorded as Finding 5.

**Does it dodge by requiring completeness only of a definable subset?** Yes — and this is what the
literature actually does. Reynolds p.169's *"definably Dedekind complete"* is exactly
completeness-as-far-as-formulas-can-see. Recorded as Finding 4.

### (b) Strongest case for the opposite verdict (NO-GO)

Constructed and evaluated:

1. *No axiom for Dedekind completeness exists, so the target theorem may be unstatable.* —
   **Fails**: the target is stated semantically (`ValidDedekind`, a binder-list restriction),
   exactly as `ValidDense`/`ValidDiscrete` are. Compile-verified to elaborate. Axioms are needed
   for the *proof*, not the *statement*.
2. *The tree's Doets machinery is `ℤ`-only, so the transfer is unavailable.* — **Partially
   succeeds.** This is the strongest surviving objection and is why the umbrella verdict is
   CONDITIONAL rather than plain GO. Recorded as precondition 3 and Phase 8, flagged highest-risk.
3. *Only weak completeness is achievable.* — **Succeeds if the target is strong completeness.**
   Recorded explicitly in the verdict; it is a genuine scope limit, not a defect in the route.
4. *The bimodal setting has no counterpart in Reynolds.* — **Succeeds as a cost objection**,
   recorded in the verdict.

**Why NO-GO nonetheless fails as the answer to *this task*.** The task asks specifically how a
Dedekind-complete carrier can be produced. That question is settled affirmatively and cheaply, and
the compile check in Finding 7 is decisive evidence. Objections 2-4 are about downstream phases,
not the carrier. Reporting NO-GO would misattribute downstream cost to a carrier problem that does
not exist — which is precisely the error the original obstruction makes.

### (c) Attack on every Mathlib existence claim

**This attack found a live tooling defect and two wrong claims.**

- **`mcp__lean-lsp__lean_run_code` is unreliable in this environment.** It returned
  `success: true, diagnostics: []` for `#check @Order.iso_of_countable_dense_BOGUS_CONTROL`. An
  earlier batch of "verified" Mathlib declarations rested on it and was **discarded**. All
  surviving claims were re-verified through `lake env lean` with a bogus-identifier control that
  does correctly produce `unknownIdentifier`. Downstream agents should not trust
  `lean_run_code` here.
- **Draft claim "Mathlib has no Dedekind-completion functor for linear orders" — FALSE, corrected.**
  `Mathlib/Order/Completion.lean` provides `DedekindCut` with `CompleteLinearOrder`,
  `principalEmbedding`, and a universal property. The corrected claim (Finding 6) is that it exists
  but is *unsuitable* — it adds endpoints (its own Todo targets `DedekindCut ℚ ≃o EReal`, not `ℝ`)
  and carries no group structure. Had this gone unchecked, the report would have booked a large
  phantom formalization line-item.
- **Draft claim `ConditionallyCompleteLinearOrder ℝ`/`ℤ` are computable instances — FALSE,
  corrected.** Both are `noncomputable`; the probe needed `noncomputable example`.
- Absence claims (`≃o ℝ` characterization, Hölder, `AddCommGroup` on `DedekindCut`) were each
  backed by an explicit grep rather than asserted, and are reported as searched-and-not-found
  rather than as proven absent.

### Claim Verification Table

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `valid` binders are `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` | `Validity.lean:79-84` | Direct file read | **High** |
| `ValidDedekind` Variants A and B both elaborate | probe `scratchpad/Ded.lean` | `lake env lean`, clean, with bogus control | **High** |
| `valid_implies_validDedekind` proves sorry-free | probe, one-line forgetful term | `lake env lean`, clean | **High** |
| Parametric scaffolding instantiates at `ℝ` unmodified | probe `scratchpad/RealInst.lean` | `lake env lean`, clean | **High** |
| `ConditionallyCompleteLinearOrder ℝ` exists (noncomputable) | `Archimedean/Real/Basic.lean:140` | `lake env lean` `inferInstance`, clean | **High** |
| `ConditionallyCompleteLinearOrder ℤ` exists (noncomputable) | `Data/Int/ConditionallyCompleteOrder.lean:29` | `lake env lean` `inferInstance`, clean | **High** |
| `Order.iso_of_countable_dense` signature | Mathlib | `#check` output captured verbatim | **High** |
| `DedekindCut` exists with `CompleteLinearOrder` | `Order/Completion.lean:52,218,238` | **Source read only** — module not in built cache | **Medium** |
| `DedekindCut` has no group structure | `Order/Completion.lean` | grep for `AddCommGroup`/`Add ` → empty | **Medium-High** |
| No `≃o ℝ` abstract characterization in Mathlib | grep across Mathlib | Negative grep; not exhaustive | **Medium** |
| No Hölder theorem in `Mathlib/Algebra/Order/` | grep | Negative grep; may exist elsewhere | **Medium** |
| Reynolds Thm 7 is a transfer, not a completion | printed p.189 | Primary-source chunk read verbatim | **High** |
| Reynolds Prior-U/Prior-S/Sep statements | printed p.168 | Chunk read + PyMuPDF page confirmation | **High** |
| "definably Dedekind complete" quotation | printed p.169 | Chunk read + PyMuPDF page confirmation | **High** |
| Doets' theorem (Reynolds Thm 6) statement | printed p.184 | Chunk read verbatim | **High** |
| GHR94 §10.3 assumes rather than constructs completeness | PDF idx 8-14 | Chunk read; lemma statements quoted | **High** |
| Tree's `prior_UZ` ≠ Reynolds' Prior-U | `Axioms.lean:305-320` vs Reynolds p.168 | Both read side by side | **High** |
| Listed scaffolding is sorry-free | 6 files | `grep -c sorry` = 0, except `Completeness.lean` where all 18 hits are prose (inspected individually) | **High** |
| `MCSMixedCase.lean` is under `BXCanonical/`, not `Chronicle/` directly | `find` + `grep` | Filesystem | **High** |
| Dedekind-complete LOAG `≅ ℤ` or `ℝ` | Finding 1 sketch | **Hand proof, not formalized** — standard result, not verified in Lean | **Medium** |
| Coherence failure at completion points | Finding 2 | **Reasoned argument**, not formalized; grounded in Reynolds' `γ⁺` pattern p.176 | **Medium** |

### Contradiction Log

**Task description vs. filesystem — RESOLVED.** Description places sources under
`Theories/Bimodal/`; filesystem and `CLAUDE.md` both say `FormalSystem/`. Precedence: filesystem
over description. Resolved in favour of the filesystem; full correction table in Finding 0.

**Task description vs. literature — RESOLVED against the description.** The description asserts the
chronicle/canonical route "cannot directly yield a Dedekind-complete carrier" and frames this as
the crux. Reynolds Theorem 7 (primary source, p.189) shows the carrier is never yielded by the
construction at all. Precedence: primary source over task framing. Resolved in Findings 3 and the
verdict.

**No unresolved contradictions.**

### Recommendations modified after verification

1. Verdict inverted from NO-GO to GO-on-carrier / CONDITIONAL-overall (attack (a)).
2. "Mathlib lacks a Dedekind completion" removed as false; replaced with the accurate
   exists-but-unsuitable analysis (attack (c)).
3. `DenselyOrdered` removed from the recommended binder list, after `ℤ` was found to be
   conditionally complete (Finding 5).
4. Variant B promoted over Variant A as the recommendation, on invasiveness grounds.
5. An earlier Mathlib verification batch was discarded wholesale after the `lean_run_code` control
   failed, and redone under `lake env lean`.

---

## References

- Reynolds, M. (1992). *An Axiomatization for Until and Since over the Reals without the IRR Rule*.
  `~/Projects/Literature/sources/reynolds_1992/Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf`
  — printed pp.168 (axioms), 169 (definable completeness), 176 (Prior structures, Thm 3),
  180-188 (§6-§8, Thms 4-6), 189 (§9, Thm 7).
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and
  Computational Aspects, Vol. 1*, Chapter 10 §10.3.
  `~/Projects/Literature/sources/gabbay_1994/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.pdf`
  — PDF indices 8 (§10.3.1), 11-14 (§10.3.2).
- Rabinovich, A. (2014). *A Proof of Kamp's Theorem*. PDF p.8 (eq. 5.2) — as cited by
  `Kamp/DedekindINF.lean`; the `.md` conversion is corrupt and is never ground truth.
- Doets, K. (1989) — via Reynolds Theorem 6; tree references at `WeakCanonical/Transfer.lean:44`,
  `Metalogic/README.md:302`.
- Burgess, J. P. (1984), §1 — chronicle construction; Burgess–Xu Corollary 1 as invoked by
  Reynolds p.189.

## Probe Artifacts

Verification probes (scratchpad, not part of the tree; no `.lean` file in `FormalSystem/` was
modified during this research):

- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/1a95ab5c-421d-4221-8060-85cb05c516c8/scratchpad/Ded.lean`
  — `ValidDedekind` Variants A/B, `valid_implies_validDedekind`, `ℝ`/`ℤ` instance checks.
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/1a95ab5c-421d-4221-8060-85cb05c516c8/scratchpad/RealInst.lean`
  — parametric scaffolding instantiated at `ℝ`.
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/1a95ab5c-421d-4221-8060-85cb05c516c8/scratchpad/MlCheck.lean`
  — Mathlib signature checks with bogus-identifier control.
