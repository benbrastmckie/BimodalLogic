# Roadmap: BX Completeness and Publication

## Overview

TM is a bimodal logic combining S5 modality with reflexive linear temporal logic,
axiomatized via the **Burgess-Xu (BX) system**. This roadmap describes the current
state of the completeness effort as of 2026-04-19 (plan v44: three-path strategy for DD-BFMCS coherence).

**Architecture**: The proof system has 37 BX axioms (propositional, S5 modal,
Burgess-Xu temporal, and modal-temporal interaction). The temporal semantics is
**fully reflexive**: G/H quantify over `t ≤ s` / `s ≤ t`, and Until/Since admit
the current point `s = t` as a witness under a half-open guard. The active
completeness path flows through `Theories/Bimodal/Metalogic/BXCanonical/`,
which constructs a canonical frame of maximally consistent sets ordered by
`g_content` inclusion.

**Active-path sorry summary**: There are **5 sorries** blocking
`bx_completeness`, all in `RootScopedChain.lean` (task 93). The sorry at
`Completeness.lean:154` was resolved via `dd_countermodel`, which depends on
the 5 sorry sites below. The oracle replacement approach (qm_bfmcs, 6 additional
sorries) was archived to `Boneyard/OracleCoherence.lean` on 2026-04-18 after
hitting a backward coherence obstruction.

| Category | Count | Location | Status |
|----------|-------|----------|--------|
| `fwd_chain_forward_F` | 1 | `RootScopedChain.lean:1111` | **OPEN** -- F-resolution for preserving chain |
| `dd_bfmcs_restricted_tc` (forward, backward chain case) | 1 | `RootScopedChain.lean:1138` | **OPEN** -- restricted temporal coherence (backward chain F-case) |
| `dd_bfmcs_restricted_tc` (backward direction) | 1 | `RootScopedChain.lean:1145` | **OPEN** -- restricted temporal coherence (P-resolution) |
| `dd_bfmcs_restricted_buc` | 1 | `RootScopedChain.lean:1153` | **OPEN** -- backward Until/Since coherence |
| `dd_bfmcs_restricted_fuc` | 1 | `RootScopedChain.lean:1160` | **OPEN** -- forward Until/Since coherence |
| **Active-path total** | **5** | | |
| Oracle replacement (qm_bfmcs) | 6 | archived to Boneyard/OracleCoherence.lean | **ARCHIVED** (2026-04-18) |
| Legacy strict-semantics files | 107 | archived to Boneyard/StrictSemanticsLegacy/ | **DONE** (task 94, 2026-04-12) |

**Dependency chain**: `fwd_chain_forward_F` -> `restricted_tc` -> `restricted_buc` -> `restricted_fuc`.

See sections below for the axiom system, reflexive semantics, canonical
construction, sorry inventory, and the Burgess-Xu Until-induction proof strategy.

---

## BX Axiom System

`Theories/Bimodal/ProofSystem/Axioms.lean` defines 37 axiom constructors in
four layers (see `Axioms.lean:46-49` for Burgess 1982/84, Xu 1988, Venema 1993
references). All axioms are sound on the frame class `Base` (linear temporal
orders with S5 modal equivalence).

### Layer 1: Propositional (4)

| Axiom | File:Line | Statement | Role |
|-------|-----------|-----------|------|
| `prop_k` | Axioms.lean:71 | `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` | Intuitionistic K |
| `prop_s` | Axioms.lean:75 | `φ → (ψ → φ)` | Weakening |
| `ex_falso` | Axioms.lean:78 | `⊥ → φ` | Ex falso |
| `peirce` | Axioms.lean:81 | `((φ → ψ) → φ) → φ` | Classical |

### Layer 2: S5 Modal (5)

| Axiom | File:Line | Statement | Role |
|-------|-----------|-----------|------|
| `modal_t` | Axioms.lean:86 | `□φ → φ` | Reflexivity |
| `modal_4` | Axioms.lean:89 | `□φ → □□φ` | Transitivity |
| `modal_b` | Axioms.lean:92 | `φ → □◇φ` | Symmetry |
| `modal_5_collapse` | Axioms.lean:95 | `◇□φ → □φ` | S5 characteristic |
| `modal_k_dist` | Axioms.lean:98 | `□(φ → ψ) → (□φ → □ψ)` | Normal modality |

### Layer 3: BX Temporal (26)

| Axiom | File:Line | Statement (future direction) | Role |
|-------|-----------|------------------------------|------|
| `temp_k_dist` | Axioms.lean:107 | `G(φ → ψ) → (Gφ → Gψ)` | K for G |
| `temp_4` | Axioms.lean:112 | `Gφ → GGφ` | Transitivity; needed for `bx_le_trans` |
| **BX1** `temp_t_future` | **Axioms.lean:117** | **`Gφ → φ`** | **Reflexive T; needed for `bx_le_refl`** |
| **BX1'** `temp_t_past` | **Axioms.lean:121** | **`Hφ → φ`** | **Mirror reflexive T** |
| BX2 `left_mono_until` | Axioms.lean:126 | `G(φ→χ) → ((φUψ)→(χUψ))` | Left monotonicity |
| BX2' `left_mono_since` | Axioms.lean:130 | mirror for S | |
| BX3 `right_mono_until` | Axioms.lean:135 | `G(φ→ψ) → ((χUφ)→(χUψ))` | Right monotonicity |
| BX3' `right_mono_since` | Axioms.lean:139 | mirror for S | |
| BX4 `connect_future` | Axioms.lean:146 | `φ → G(P(φ))` | Temporal connectedness |
| BX4' `connect_past` | Axioms.lean:151 | `φ → H(F(φ))` | Mirror |
| BX5 `self_accum_until` | Axioms.lean:157 | `(φUψ) → ((φ ∧ (φUψ))Uψ)` | **Key eventuality axiom** |
| BX5' `self_accum_since` | Axioms.lean:162 | mirror for S | |
| BX6 `absorb_until` | Axioms.lean:169 | `(φU(φ ∧ (φUψ))) → (φUψ)` | Prevents infinite deferral |
| BX6' `absorb_since` | Axioms.lean:173 | mirror for S | |
| BX7 `linear_until` | Axioms.lean:180 | four-formula linearity disjunction | Linearity of U witnesses |
| BX7' `linear_since` | Axioms.lean:190 | mirror for S | |
| BX8 `refl_intro_until` | Axioms.lean:202 | `ψ → (φUψ)` | **Reflexive Until witness at s=t** |
| BX8' `refl_intro_since` | Axioms.lean:207 | `ψ → (φSψ)` | Mirror |
| BX9 `until_elim` | Axioms.lean:214 | `(φUψ) → (φ ∨ ψ)` | Current-time elim |
| BX9' `since_elim` | Axioms.lean:219 | mirror for S | |
| BX10 `until_F` | Axioms.lean:226 | `(φUψ) → F(ψ)` | Eventuality extraction |
| BX10' `since_P` | Axioms.lean:231 | mirror for S | |
| BX11 `temp_linearity` | Axioms.lean:240 | F-witness linearity disjunction | Linear order on F witnesses |
| BX11' `temp_linearity_past` | Axioms.lean:249 | mirror for P | |
| BX12 `F_until_equiv` | Axioms.lean:258 | `F(φ) → (⊤Uφ)` | Bridges F to U |
| BX12' `P_since_equiv` | Axioms.lean:263 | `P(φ) → (⊤Sφ)` | Mirror |

### Layer 4: Modal-Temporal Interaction (2)

| Axiom | File:Line | Statement |
|-------|-----------|-----------|
| `modal_future` | Axioms.lean:269 | `□φ → □(Gφ)` |
| `temp_future` | Axioms.lean:272 | `□φ → G(□φ)` |

### Why the axioms prove reflexive semantics

BX1/BX1' (`temp_t_future` / `temp_t_past`) are present and necessary — the
"T-axiom removal" claim from the pre-2026-04-10 roadmap was stale. Without BX1,
reflexivity of `bx_le` (`g_content w ⊆ w`) fails; see `Frame.lean:120-132`
(`g_content_set_consistent`) where BX1 is invoked to derive a contradiction
from `G(⊥) ∈ S`.

BX8 (`ψ → (φUψ)`) and BX9 (`(φUψ) → (φ ∨ ψ)`) are **only sound under
reflexive Until semantics** where the witness `s = t` is allowed. Under strict
`<` semantics, BX8 would require `ψ` to force a strict future witness, which
is false in general. These two axioms are the clearest code-level evidence
that the codebase is fully reflexive.

---

## Reflexive Truth Semantics

All four temporal operators in TM use reflexive ordering. The current point is
included for G and H (`≤`), and Until/Since witnesses can be the current point
(`t ≤ s` / `s ≤ t`) with a half-open guard.

From `Theories/Bimodal/Semantics/Truth.lean:120-131`:

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M Omega τ t φ → truth_at M Omega τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
  | Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
  | Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
  | Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
      ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
  | Formula.snce φ ψ => ∃ s : D, s ≤ t ∧ truth_at M Omega τ s ψ ∧
      ∀ r : D, s < r → r ≤ t → truth_at M Omega τ r φ
```

- **G (`all_future`)**: `∀ s, t ≤ s → ...` — reflexive future (includes `t`).
- **H (`all_past`)**: `∀ s, s ≤ t → ...` — reflexive past (includes `t`).
- **U (`untl`)**: `∃ s, t ≤ s ∧ ψ@s ∧ ∀ r, t ≤ r < s → φ@r` — reflexive witness,
  half-open guard `[t, s)`.
- **S (`snce`)**: `∃ s, s ≤ t ∧ ψ@s ∧ ∀ r, s < r ≤ t → φ@r` — mirror.

The half-open guard (strict on the witness side) makes the `s = t` case
vacuous for the guard and forces `ψ` at `t` — i.e. BX8 (`ψ → (φUψ)`) is sound.

---

## X/Y Operator Status

From `Theories/Bimodal/Syntax/Formula.lean:328-334`:

```lean
/-- Next-step operator: X(phi) = bot U phi.
    Under discrete strict semantics, X(phi) at t means phi holds at t+1. -/
def next (φ : Formula) : Formula := Formula.untl Formula.bot φ

/-- Previous-step operator: Y(phi) = bot S phi.
    Under discrete strict semantics, Y(phi) at t means phi holds at t-1. -/
def prev (φ : Formula) : Formula := Formula.snce Formula.bot φ
```

Unfolding `Formula.next φ = Formula.untl Formula.bot φ` against the reflexive
Until clause (`Truth.lean:128-129`):

```
truth_at (⊥ U φ) at t  ↔  ∃ s, t ≤ s ∧ truth_at φ s ∧ ∀ r, t ≤ r < s → truth_at ⊥ r
                       ↔  ∃ s, t ≤ s ∧ truth_at φ s ∧ ∀ r, t ≤ r < s → False
                       ↔  ∃ s, t ≤ s ∧ truth_at φ s ∧ (∀ r, ¬(t ≤ r < s))
                       ↔  ∃ s, s = t ∧ truth_at φ s    [empty half-open interval forces s=t]
                       ↔  truth_at φ t
```

Under the current reflexive semantics with half-open guard, `next φ ≡ φ` and
`prev φ ≡ φ` semantically. `X`/`Y` are definitional dead code: their docstrings
reference "discrete strict semantics" which is stale (that semantics was
reverted). **They should not be used in proofs.** Task 94 may archive or
delete these definitions.

---

## Active Metalogic Path: BXCanonical

The active completeness path flows through `Metalogic/BXCanonical/`. The
legacy `UltrafilterChain`, `FrameConditions/Completeness`, and `SuccChainFMCS`
modules are still built via top-level aggregation in `Metalogic.lean:1-4` but
are **not imported** by `BXCanonical`.

### Module Import Graph

```
Metalogic/BXCanonical/BXCanonical.lean (28 lines, aggregator)
  ├── Frame.lean (673 lines, sorry-free)
  │     ├── Core/MaximalConsistent
  │     ├── Core/MCSProperties
  │     ├── Bundle/TemporalContent
  │     ├── Bundle/WitnessSeed
  │     ├── Bundle/CanonicalFrame
  │     ├── Syntax/Formula
  │     └── Theorems/GeneralizedNecessitation
  │
  ├── TruthLemma.lean (320 lines, sorry-free)
  │     ├── Frame
  │     ├── Semantics/Truth
  │     └── Semantics/Validity
  │
  ├── Completeness.lean (152 lines, sorry-free -- delegates to RootScopedChain)
  │     ├── RootScopedChain
  │     └── Semantics/Validity
  │
  ├── CanonicalChain.lean (157 lines, sorry-free)
  │     ├── Frame
  │     ├── Quasimodel/Construction
  │     └── Filtration/DefectChain
  │
  ├── OrderedSeedConsistency.lean (255 lines, sorry-free)
  │     ├── Frame
  │     └── CanonicalChain
  │
  ├── CanonicalModel.lean (498 lines, sorry-free)
  │     ├── CanonicalChain
  │     ├── TruthLemma
  │     └── Bundle/FMCSDef
  │
  ├── RootScopedChain.lean (1,681 lines, 5 sorries -- task 93)
  │     ├── OrderedSeedConsistency
  │     ├── CanonicalModel
  │     ├── Bundle/UntilSinceCoherence
  │     ├── Algebraic/ParametricRepresentation
  │     └── Algebraic/RestrictedParametricTruthLemma
  │
  ├── Quasimodel/
  │     ├── SubformulaClosure.lean (114 lines)
  │     │     └── Syntax/Formula
  │     ├── HintikkaPoint.lean (166 lines)
  │     │     ├── SubformulaClosure
  │     │     └── Frame
  │     ├── EnrichedClosure.lean (158 lines)
  │     │     ├── Syntax/BigConj
  │     │     ├── SubformulaClosure
  │     │     └── Mathlib.Data.Finset.Powerset
  │     ├── Construction.lean (887 lines)
  │     │     ├── HintikkaPoint
  │     │     └── Mathlib.Data.List.Chain
  │     ├── Realization.lean (444 lines)
  │     │     ├── Construction
  │     │     ├── Syntax/BigConj
  │     │     ├── Theorems/Combinators
  │     │     └── Theorems/Propositional
  │     └── LocusControl.lean (47 lines)
  │           └── Realization
  │
  └── Filtration/
        ├── SigmaOrdering.lean (179 lines)
        │     ├── Frame
        │     └── Quasimodel/EnrichedClosure
        └── DefectChain.lean (137 lines)
              ├── SigmaOrdering
              └── Quasimodel/Construction
```

**Total BXCanonical module: 5,791 lines across 16 files, 5 sorries (all in RootScopedChain.lean).**

Legacy files (`UltrafilterChain`, `SuccChainFMCS`, `FrameConditions/Completeness`)
are still built via top-level aggregation in `Metalogic.lean` but are **not
imported** by `BXCanonical`.

---

## Canonical Model Construction (BXCanonical)

### BXPoint (Frame.lean:46-53)

```lean
structure BXPoint where
  formulas : Set Formula
  is_mcs : SetMaximalConsistent formulas
```

A canonical frame point is a maximally consistent set (MCS) of formulas.

### Canonical Temporal Ordering (Frame.lean:56-62)

```lean
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas
```

Equivalently: `w ≤ v ↔ ∀ φ, G(φ) ∈ w → φ ∈ v`.

- **Reflexivity** (`bx_le_refl`): requires `Gφ → φ` = BX1 `temp_t_future`.
  Without BX1, `g_content w ⊆ w` would fail; see `g_content_set_consistent`
  (`Frame.lean:122-133`) for the BX1 invocation.
- **Transitivity** (`bx_le_trans`): requires `Gφ → GGφ` = `temp_4`.

### Canonical Modal Equivalence (Frame.lean:65-68)

```lean
def bx_modal_equiv (w v : BXPoint) : Prop :=
  ∀ φ : Formula, Formula.box φ ∈ w.formulas ↔ Formula.box φ ∈ v.formulas
```

### Key Infrastructure Lemmas (Frame.lean:79+)

- `g_content_closed_derivation` (Frame.lean:79-94): if `L ⊆ g_content(S)` and
  `L ⊢ φ`, then `Gφ ∈ S`. Uses `generalized_temporal_k`.
- `h_content_closed_derivation` (Frame.lean:101-114): dual for H.
- `g_content_set_consistent` (Frame.lean:122-133): `g_content` of an MCS is
  consistent; uses BX1 to contradict `G(⊥) ∈ S`.
- `bx_forward_witness` / `bx_backward_witness`: Lindenbaum extension producing
  G/H canonical witnesses.
- `bx_modal_witness` (Frame.lean): constructs the modal-direction witness.
  Sorry-free (closed by task 102).

### Truth Lemma (TruthLemma.lean:27-36)

Proved by formula induction. All cases (`atom`, `bot`, `imp`, `box`, `G`, `H`,
`U`, `S`) are **sorry-free**. The `U` and `S` cases delegate to the four
`Frame.lean` helper lemmas (`bx_until_eventuality_resolution`,
`bx_until_backward`, `bx_since_eventuality_resolution`,
`bx_since_backward`), all of which were closed by tasks 98+102 via the
quasimodel/filtration infrastructure.

### Completeness Theorem (Completeness.lean:124-154)

```lean
theorem bx_completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree [] φ)
```

Contrapositive proof flow:

1. Assume `valid φ` and `¬derivable φ`.
2. By `neg_consistent_of_not_derivable` (sorry-free): `{¬φ}` is consistent.
3. By `set_lindenbaum`: extend to an MCS `M` with `¬φ ∈ M`.
4. Build a canonical `TaskModel` from the BXPoint canonical frame.
5. By the truth lemma: `φ` is false at `M` in the model.
6. Contradiction with `valid φ`.

Step 4 (the TaskModel embedding) is the `sorry` at `Completeness.lean:154`.
`Completeness.lean:143-148` documents the rejected **constant-history approach**
(task 88 anti-pattern): on constant histories, `G(α) ≡ α` semantically, so the
temporal truth bridge fails. The TaskModel embedding must use non-constant
histories that visit multiple BXPoints.

---

## Quasimodel/Filtration Infrastructure

Nine new files (2,289 lines, all sorry-free) were added under `BXCanonical/`
between tasks 90 and 102, implementing a Hintikka-set quasimodel with
defect-discharge to close the Until/Since eventuality obligations.

### Quasimodel/ (Hintikka-set quasimodel construction)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `SubformulaClosure.lean` | 114 | Finite subformula closure (Sigma-closure) | `subformulas`, `SubformulaClosure`, `ghEnrichment` |
| `HintikkaPoint.lean` | 166 | Hintikka point definition and sigma-signature | `HintikkaPoint`, `sigma_signature`, `sigma_signature_consistent`, `sigma_signature_maximal` |
| `EnrichedClosure.lean` | 158 | Fisher-Ladner enriched closure with G/H negation formulas | `enrichedGNegBigconj`, `enrichedHNegBigconj`, `enrichedClosure` |
| `Construction.lean` | 887 | BX axiom lemmas at MCS level with defect-discharge | `hintikka_step`, `UntilDefect`, `defect_count`, `QuasimodelChain` |
| `Realization.lean` | 444 | Realization lifting from Hintikka chains to BXPoint chains | `until_forward_seed`, `since_backward_seed`, `until_eventuality_resolution`, `since_eventuality_resolution` |
| `LocusControl.lean` | 47 | Delegation layer (primed variants) | `bx_until_eventuality_resolution'`, `bx_since_eventuality_resolution'` |

### Filtration/ (Sigma-restricted ordering)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `SigmaOrdering.lean` | 179 | Sigma-restricted ordering on BXPoints | `sigma_le`, `sigma_strict`, `sigma_equiv`, `bx_le_implies_sigma_le` |
| `DefectChain.lean` | 137 | Defect-discharge chain via well-founded recursion | `sigma_defect_count`, `until_defect`, `defect_step_phi` |

### CanonicalChain.lean (top-level bridge)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `CanonicalChain.lean` | 157 | MCS-level BX axiom lemmas and delegation bridges | `psi_imp_until_mcs`, `psi_imp_since_mcs`, `F_imp_top_until_mcs`, `left_mono_until_mcs` |

---

## How Until/Since Were Closed

The four Until/Since eventuality and backward sorries in `Frame.lean` were
the hardest part of the BX completeness proof. They were closed between
2026-04-10 and 2026-04-12 through tasks 90, 92, 98, and 102.

### The Problem

The original canonical model construction used `bx_le` (defined as
`g_content w ⊆ v`) for the temporal ordering. The Until/Since eventuality
obligations require finding a witness point where the eventuality formula
is discharged. The core difficulty was the **X-vs-G mismatch**: `φ U ψ ∈ w`
does not imply `G(φ U ψ) ∈ w`, so the formula does not propagate forward
through the `g_content`-based ordering.

### The Solution: Hintikka-Set Quasimodel with Defect-Discharge

**Research (task 90)** identified two strategies. **Option A** -- a quasimodel
approach using Hintikka points with defect-discharge -- was chosen for its
proof-theoretic elegance and avoidance of Henkin witness closure machinery.

The approach works as follows:

1. **Subformula closure** (`SubformulaClosure.lean`): Define a finite
   sigma-closure of the target formula, restricting attention to a bounded
   set of subformulas.

2. **Hintikka points** (`HintikkaPoint.lean`): Define Hintikka points as
   MCS sets restricted to the sigma-closure, with sigma-signatures encoding
   consistency and maximality within the closure.

3. **Enriched closure** (`EnrichedClosure.lean`): Extend the closure with
   Fisher-Ladner enrichment formulas (G/H-negation big conjunctions) that
   ensure the finite model property.

4. **Defect-discharge construction** (`Construction.lean`, 887 lines): Build
   `QuasimodelChain`s where each step discharges an `UntilDefect` --
   a formula `φ U ψ` held at a point but not yet witnessed. The
   `defect_count` decreases at each step, ensuring termination via
   well-founded recursion on the finite sigma-closure.

5. **Realization** (`Realization.lean`): Lift the Hintikka chain construction
   back to BXPoint chains, producing the eventuality resolution and backward
   witnesses that `Frame.lean` needs.

6. **Sigma-restricted ordering** (`Filtration/`): Define `sigma_le` as a
   sigma-restricted variant of `bx_le` that respects the finite closure.
   `DefectChain.lean` uses well-founded recursion on `sigma_defect_count`
   to discharge all defects.

**Implementation (task 92)** built the initial infrastructure. **Task 98**
closed `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution`.
**Task 102** closed the remaining three sorries: `bx_until_backward`,
`bx_since_backward`, and `bx_modal_witness`.

---

## Active-Path Sorry Inventory

There are **5 sorries** on the active completeness path, all in
`Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean`.
`Completeness.lean` is now sorry-free (delegates to `dd_countermodel` in
`RootScopedChain.lean`, which depends on the 5 sorry sites below).

| # | File:Line | Definition | Goal Summary | Owning Task |
|---|-----------|------------|--------------|-------------|
| 1 | RootScopedChain.lean:1111 | `fwd_chain_forward_F` | F(phi) in chain(n) implies phi in chain(m) for some m > n | **Task 93** |
| 2 | RootScopedChain.lean:1138 | `dd_bfmcs_restricted_tc` (fwd, bwd chain) | Forward temporal coherence for backward chain case (F-resolution on negative side) | **Task 93** |
| 3 | RootScopedChain.lean:1145 | `dd_bfmcs_restricted_tc` (backward) | Backward temporal coherence: P(phi) resolution | **Task 93** |
| 4 | RootScopedChain.lean:1153 | `dd_bfmcs_restricted_buc` | Backward Until/Since coherence | **Task 93** |
| 5 | RootScopedChain.lean:1160 | `dd_bfmcs_restricted_fuc` | Forward Until/Since coherence | **Task 93** |

All 5 sorries target the `dd_bfmcs` scheduling chain's restricted coherence
properties. The dependency chain is: `fwd_chain_forward_F` -> `restricted_tc`
(forward, positive side) -> remaining `restricted_tc` cases -> `restricted_buc`
-> `restricted_fuc`. The oracle replacement approach (qm_bfmcs) was archived to
`Boneyard/OracleCoherence.lean` on 2026-04-18 after hitting a backward
coherence obstruction (`phi /\ F(phi U psi) -> phi U psi` is semantically
invalid).

### Three-Path Strategy (Plan v44, 2026-04-19)

After 44 rounds of research and planning, the current approach attempts three
architecture paths (C, then A, then B) to close all 5 sorries:

| Path | Strategy | Confidence | LOC Est. | Key Requirement |
|------|----------|------------|----------|-----------------|
| **C** | Pigeonhole fix for `fwd_chain_forward_F` | 35% | 100-200 | F-persistence + finite sigma_list -> pigeonhole on defect resolution |
| **A** | Oracle-based chain replacement | 50% | 500-800 | Sorry-free `hintikka_step_for_sigma_sig` provides sigma-specific oracle |
| **B** | Full quasimodel-derived BFMCS | 55% | 400-600 | Palindromic cycling avoids wraparound; BFMCS is parametric |

**Irreducible core**: All paths require defect-count monotonicity across
Lindenbaum extension. The `.choose` in `set_lindenbaum` is unconstrained, making
the resolved defect non-deterministic. The BX11 fold provides only a disjunctive
guarantee (target in M' OR F(target) in M'), not a definite resolution.

**Key research findings from rounds 43-44**:
- The enriched seed approach is definitively dead (counterexample from report 43)
- OracleStep.lean has 7-8 sorry sites (previously claimed sorry-free); but the
  sigma-specific oracle (`hintikka_step_for_sigma_sig`) IS sorry-free
- Reynolds induction on `defects.length` fails due to defect oscillation
  (resolving phi creates F(phi) which regenerates the defect)
- The `preserving_fwd_step` with `defect_step_choice_early` correctly preserves
  ALL F-obligations and resolves at least one defect per step
- `fwd_chain_F_persistent` is proved sorry-free

### Closed Sorries (Tasks 90+92+98+102)

The following 5 sorries in `Frame.lean` were closed between 2026-04-10 and
2026-04-12 via the quasimodel/filtration infrastructure:

| Former sorry | Definition | Closed by |
|-------------|------------|-----------|
| Frame.lean (formerly :440) | `bx_modal_witness` | Task 102 |
| Frame.lean (formerly :653) | `bx_until_eventuality_resolution` | Task 98 |
| Frame.lean (formerly :675) | `bx_until_backward` | Task 102 |
| Frame.lean (formerly :690) | `bx_since_eventuality_resolution` | Task 98 |
| Frame.lean (formerly :704) | `bx_since_backward` | Task 102 |

Frame.lean is now **completely sorry-free** (673 lines). See "How Until/Since
Were Closed" below for the approach that resolved these.

---

## Legacy Code Inventory

The following files were written under a strict-semantics architecture that
has since been reverted to the all-reflexive BX system. They are **not
imported by `BXCanonical`** and are not on the active completeness path.
**Task 94** will archive them to `Boneyard/StrictSemanticsLegacy/`. Archiving
these files drops approximately **~20 sorries** from the active (non-Boneyard,
non-Example) tree.

| File | Approx sorries | Category | Imported by BXCanonical? |
|------|---------------|----------|---------------------------|
| `Metalogic/Algebraic/UltrafilterChain.lean` | 4 | Legacy strict-semantics | No |
| `Metalogic/Algebraic/DovetailedChain.lean` | 6 | Deprecated (X-vs-G mismatch) | No |
| `Metalogic/Algebraic/LindenbaumQuotient.lean` | 2 | temp_k_dist derivable from BX | No |
| `Metalogic/Algebraic/InteriorOperators.lean` | 1 | temp_k_dist derivable from BX | No |
| `Metalogic/Bundle/SuccChainFMCS.lean` | 3 | Legacy strict-semantics | No |
| `Metalogic/Bundle/SuccRelation.lean` | 1 | Legacy | No |
| `Metalogic/Bundle/CanonicalFrame.lean` | 1 | BX derivability | No |
| `FrameConditions/Completeness.lean` | 2 | Wiring (temporal coherence + dense) | No |

Additional legacy code still imported by `Metalogic.lean` at top-level for
aggregation but not required for BX completeness:

- `Theories/Bimodal/Metalogic/Completeness.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

**Verification**:
```
grep -r "import.*\(UltrafilterChain\|SuccChainFMCS\|FrameConditions\.Completeness\)" \
  Theories/Bimodal/Metalogic/BXCanonical/
```
returns nothing.

Note: the `X`/`Y` operator definitions in `Syntax/Formula.lean:328-334` are
also candidates for archival or deletion (see "X/Y Operator Status" section) —
task 94 should decide their fate.

---

## Burgess-Xu Until-Induction Technique

### Historical Context

The BX system is named after John P. Burgess and Ming Xu. Active references
(cited in the `Axioms.lean:46-49` comment block):

- **Burgess, J. P. (1982)**. "Axioms for tense logic. I. 'Since' and 'until'."
  *Notre Dame Journal of Formal Logic* 23(4), 367-374.
  [ResearchGate](https://www.researchgate.net/publication/38355634_Axioms_for_tense_logic_I_Since''_and_until'').
- **Xu, M. (1988)**. "On some U, S-tense logics."
  *Journal of Philosophical Logic* 17, 181-202. Simplifies Burgess's axiomatization.
- **Venema, Y. (1993)**. Temporal logic survey (cited in `Axioms.lean:48`).

See also the Stanford Encyclopedia of Philosophy:

- [Burgess-Xu Axiomatic System for Since and Until](https://seop.illc.uva.nl/entries/logic-temporal/burgess-xu.html) — supplementary entry.
- [Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/) — main article.

### Key Result

Burgess (1982), simplified by Xu (1988), gives a complete axiomatization of
the Since-Until tense logic over **all reflexive linear orderings**. The BX
axioms BX1-BX12 in `Axioms.lean` are modeled on this axiomatization.

### Axiom Roles in the Until-Induction Proof

The proof of the Until case of the truth lemma proceeds by induction on the
Until-structure of formulas, using the following axioms:

1. **BX10 (`until_F`)**: `(φUψ) → Fψ` extracts an F-witness, giving some
   `v ≥ w` with `ψ ∈ v`.
2. **BX7 (`linear_until`)**: Linearity of Until witnesses — given two Until
   formulas holding simultaneously, their witnesses are comparable. Provides
   the linear-order structure on witnesses needed to choose a minimal / first
   witness.
3. **BX11 (`temp_linearity`)**: F-witness linearity — three-way disjunction
   giving comparability of F-witnesses.
4. **BX5 (`self_accum_until`)**: `(φUψ) → ((φ ∧ (φUψ))Uψ)` — the eventuality
   enriches its own guard, so at every intermediate point `u ∈ [w, v)` both
   `φ` and `φUψ` hold. This is the key guard-propagation axiom.
5. **BX6 (`absorb_until`)**: `(φU(φ ∧ (φUψ))) → (φUψ)` — prevents the
   self-accumulation from producing nested deferrals; the two-step resolution
   collapses.
6. **BX9 (`until_elim`)**: `(φUψ) → (φ ∨ ψ)` handles the `s = t` (current-time)
   case under reflexive semantics.
7. **BX4 (`connect_future`)**: `φ → G(P(φ))` is used in the backward direction
   to propagate `¬(φUψ)` forward and derive a contradiction with the guard.
8. **BX1 (`temp_t_future`)**: `Gφ → φ` provides reflexivity of `bx_le` and is
   used at the final witness to extract the current-time satisfaction of `ψ`.

### Resolution: Option A (Quasimodel with Defect-Discharge)

Task 90 (research) identified two strategies for closing the 4 `bx_until_*` /
`bx_since_*` sorries:

- **Option A: Quasimodel with defect-discharge** -- Build a Hintikka-set
  quasimodel with sigma-restricted filtration ordering. Avoids Henkin closure
  machinery; uses well-founded recursion on defect count.
- **Option B: Henkin witness closure** -- Explicitly enrich the canonical frame
  with witness MCS points. Classical Burgess construction but adds machinery
  to the BXPoint type.

**Option A was chosen and implemented successfully** through tasks 92, 98,
and 102. The implementation added 2,289 lines of sorry-free infrastructure
across 9 files (see "Quasimodel/Filtration Infrastructure" and "How
Until/Since Were Closed" above). All 5 Frame.lean sorries are closed.

---

## Dead Ends (Archived)

These anti-patterns are preserved across the BX migration — they remain valid
warnings regardless of the semantic change.

1. **CoherentZChain**: Forward chain preserves G but not H; backward preserves
   H but not G. Unfixable.

2. **`f_preserving_seed_consistent` sub-case A**: Mathematically unprovable.
   Vacuous implication yields no contradiction.

3. **`omega_true_dovetailed_forward_F_resolution`**: Unfixable. Lindenbaum
   extension can add `G(¬φ)` when `F(φ)` was present.

4. **Bundle-level temporal coherence**: Insufficient for truth lemma. G/H
   operators are intrinsically single-history.

5. **Fuel-based bounded witness recursion** (tasks 48, 67, 81 plan v13):
   Repeatedly failed. Fuel conflates F-nesting depth (bounded) with
   persistence count (unbounded).

6. **Bidirectional Temporal Witness** (plan v4): BLOCKED. H_theory elements
   are not G-liftable.

7. **Combined F-seed chain construction** (task 86 plans v4-v6): The
   multi-target seed `{ψ | F(ψ) ∈ w} ∪ g_content(w)` is inconsistent in
   general. G does not distribute over disjunction — the compactness step
   in the multi-target argument is mathematically false.

8. **Constant-history canonical models for G/H** (task 86): On a constant
   history (all times map to same world), `G(α)` is semantically identical
   to `α`. It is structurally impossible to build a constant-history
   countermodel that distinguishes formulas containing G/H from their
   temporal-free flattening. This blocks backward truth lemma for G on
   constant histories.

9. **Flatten reduction** (task 86): `flatten(χ) ∈ w` does not imply `χ ∈ w`
   when χ contains G/H, because `α` does not imply `G(α)` for non-theorems.

10. **FMP bridge to completeness** (task 86): The sorry-free
    `fmp_contrapositive` cannot bridge to `valid φ → provable φ` without a
    truth lemma connecting validity to closure MCS membership. This truth
    lemma faces the same branching-vs-linear mismatch as the direct canonical
    model construction. The FMP module is valuable for decidability but does
    NOT provide a shortcut to completeness.

11. **Proof-theoretic Case B for usf_completeness** (task 86, plan v7): 8
    approaches explored to derive `⊢ ψ → χ` directly from `valid(ψ → χ)`
    without countermodel construction, all blocked by the **contextual
    necessitation gap**: temporal necessitation `⊢ α → ⊢ G(α)` requires
    empty context, so `[ψ] ⊢ α` does not give `[ψ] ⊢ G(α)`. Approaches
    tried: flatten + fragment_completeness, constant-model validity transfer,
    unflatten theorem, well-founded induction on size, FMP contrapositive,
    contextual strong completeness, case analysis on χ's structure, normal
    form reduction. Novel result: validity transfer `valid φ → valid(flatten φ)`
    for USF φ is sound but insufficient (unflatten `⊢ flatten(φ) → φ` is
    not derivable).

12. **Constant-history CanonicalEmbedding fragment completeness** (task 88):
    The entire `CanonicalEmbedding.lean` module (434 lines) attempted to
    prove fragment completeness for `{atom, bot, imp, box, G, H}` using
    constant histories (all times map to a single BXPoint). This is
    permanently impossible: on constant histories, `G(α)` is semantically
    identical to `α`, so the truth bridge for `imp` Case B
    (`valid(ψ → χ)` with χ containing G) cannot distinguish χ from its
    temporal-free flattening. File deleted in task 88; validity reduction
    lemmas (`valid_of_valid_all_future`, `valid_of_valid_all_past`,
    `valid_of_valid_box`) relocated to `Semantics/Validity.lean`. Still
    referenced as an anti-pattern at `Completeness.lean:143-148`.

13. **f_carry seed for enriched forward step** (task 93, plans v8-v14):
    `{target} union g_content(M) union f_carry(M)` is inconsistent in general.
    Counterexample: `G(F(alpha) -> neg psi) in M`, `F(alpha) in M`, `F(psi) in M`.
    The G-formula forces `F(alpha) -> neg psi` into any Lindenbaum extension
    containing g_content(M), while f_carry requires both F(alpha) and F(psi)
    to be present. No G-lift argument avoids this.

14. **Fuel-based F-nesting recursion** (task 93, plans v5-v7): Conflates
    F-nesting depth (bounded by subformula closure) with visit count
    (unbounded). F(psi) can persist through arbitrarily many round-robin
    cycles without resolution.

15. **BX11 acyclicity gate check** (task 93, plan v16 Strategy A): 3-cycle
    semantic counterexample. Three formulas psi1, psi2, psi3 with
    bx11_earlier forming a cycle in different MCS contexts. BX11 is not
    transitive and does not induce a well-order.

16. **Strategy C: direct witness contradiction on existing chain** (task 93,
    plans v16-v17): Permanent BX11 displacement is syntactically consistent.
    The `.choose` in `set_lindenbaum` is unconstrained. All three attack
    vectors (visit-step analysis, pigeonhole, discharge_single_step) fail.
    Confidence: 10-15%.

17. **Approach A: target-prioritized fold** (task 93, report 18): Reduces
    multi-step fold Case 3 to single BX11 application, but the final BX11
    between target and compound can still fire Case 3.

18. **Approach B: iterative refinement** (task 93, report 18):
    Mathematically sound but requires chain redefinition -- subsumed by the
    ordered-discharge approach.

19. **Approach C: discharge_single_step at chain level** (task 93, report 18):
    Fatal F-propagation gap at non-target resolving steps.

20. **Approach 21: Until reformulation via BX12** (task 93, report 18):
    `F(psi) -> top U psi` by BX12, then `bx_until_eventuality_resolution`.
    Produces abstract BXPoints not chain indices; `top U psi` may not be in
    `deferralClosure(root)`.

21. **Strategy C fold-order variant** (task 93, report 18 synthesis):
    Processing target last in the BX11 fold. Investigated but fold outcome
    depends on MCS content which is itself determined by `.choose`.

22. **Defect re-entry in enriched chain** (task 93, report 26): Perpetual
    deferral is semantically consistent. The BX11 ordering can permanently
    favor one formula over another, so `enriched_fwd_step` can resolve
    target psi but have F(psi) re-enter at the very next step via
    Lindenbaum extension. No termination argument exists for the enriched
    chain with round-robin scheduling.

23. **G(F(chi)) non-derivability blocking persistent-carry seed** (task 93,
    reports 22, 26): `F(chi) in M` does NOT imply `G(F(chi)) in M`. The
    persistent-carry seed `{psi} union f_carry(M) union g_content(M)` is
    inconsistent when `G(F(alpha) -> neg psi) in M` and both `F(alpha)`
    and `F(psi)` are in `f_carry(M)`. This blocks all enriched seed
    approaches that try to carry F-obligations through g_content.

24. **Non-enriched chain F-obligation loss** (task 93, report 26 Section 7.2):
    The simple `fwd_succ` step uses seed `{target} union g_content(M)` at
    resolving steps, which does NOT include `f_carry`. F-obligations for
    non-target formulas are lost at resolving steps. Round-robin scheduling
    with `fwd_succ` cannot maintain F-obligation constancy.

25. **Quasimodel BXPoint-to-Int bridging gap** (task 93, report 25):
    The sorry-free quasimodel infrastructure produces abstract BXPoint
    chains (Hintikka chains over sigma-closures), but these cannot be
    directly wired into the Int-indexed FMCS/BFMCS families required by
    the parametric representation theorem. The BXPoint chain indices are
    not ordered by `bx_le` in a way compatible with Int's linear order.

26. **Semantic coherence circularity** (task 93, report 26 Section 6.6):
    The truth lemma requires `forward_F` (to resolve F-witnesses in the
    canonical model), but proving `forward_F` on the canonical chain
    requires the truth lemma (to establish that F(psi) in an MCS means
    psi holds at some future point in the model). Standard completeness
    proofs (Burgess 1984, Goldblatt 1992) handle this semantically via
    well-founded induction on formula depth, not syntactically on the
    chain.

27. **DRM bounded_witness via single_step_forcing** (task 93, report 29):
    Negation completeness gap -- the DRM bounded witness approach fails
    because `single_step_forcing` cannot guarantee negation-complete
    intermediate states, breaking the MCS chain invariant.

28. **Full MCS bounded_witness** (task 93, report 29):
    F-reflexivity blocks the exit condition. When the bounded witness
    encounters F(psi) with psi already present, it cannot distinguish
    between "resolved" and "still pending" states, leading to infinite
    loops in the termination argument.

29. **DRM chain preventing perpetual deferral** (task 93, report 29):
    Relocates non-determinism rather than eliminating it. The DRM chain
    construction moves the `.choose` problem from the Lindenbaum extension
    to the defect-resolution oracle, without solving the core issue.

30. **Per-formula witness wired into same-family membership** (task 93,
    report 30): `restricted_temporally_coherent` requires witnesses ON the
    chain (same FMCS family), but `bx_forward_witness` produces BXPoints
    outside the chain family. Bridging BXPoint witnesses back to chain
    membership is blocked by the Lindenbaum non-determinism gap.

31. **Enriched seed approach definitively dead** (task 93, report 43):
    Counterexample: `G(F(alpha) -> neg psi) in M` with both `F(alpha)` and
    `F(psi)` in `f_carry`. The G-formula forces `F(alpha) -> neg psi` into
    any Lindenbaum extension containing `g_content(M)`, while `f_carry`
    requires both `F(alpha)` and `F(psi)` to be present, creating an
    inconsistency. No variant of the enriched seed approach can avoid this.

32. **"Sorry-free oracle" claim at OracleStep.lean is false** (task 93,
    report 44, teammate C): OracleStep.lean contains 7-8 sorry sites in the
    universal oracle infrastructure. The sigma-specific oracle
    (`hintikka_step_for_sigma_sig`, lines 188-222) IS sorry-free, but the
    universal oracle used by `qm_oracle_step` is not. Any path relying on
    the universal oracle inherits these sorries.

33. **Reynolds induction on defects.length fails** (task 93, report 44):
    Defects can oscillate: resolving phi (placing it in M') causes
    `phi in M'`, but `F(phi)` persists (F-preservation), so at the next
    step, the defect condition `F(phi) in M' AND phi in sigma_list` still
    holds. The defect count does not decrease because resolved formulas
    remain "active defects" under the current `active_defects` definition
    (which checks `F(chi) in M`, not `chi not in M`). This blocks the
    Reynolds induction approach from plan v42.

34. **Path C: Pigeonhole fix for fwd_chain_forward_F** (task 93, plan v44
    Phase 2): The BX11 fold in `resolving_enriched_fwd_exists` resolves
    SOME defect w via Lindenbaum `.choose`, but the resolved w is opaque
    and cannot be forced to equal a specific target phi. Three sub-approaches
    all fail:
    (a) **Pigeonhole on active_defects**: Active defects never shrink (F-
    persistence keeps all defects active forever), so no counting argument
    works.
    (b) **bx11_earlier minimum**: BX11 ordering is non-transitive (dead end
    #15), so no global minimum exists among defects. `target_stays_direct_in_fold`
    requires target to beat ALL others, which can't be guaranteed.
    (c) **Self-resolving chain redesign**: `self_resolving_fwd_step` resolves
    a specific target AND preserves its own F-obligation, but does NOT preserve
    F-obligations for other formulas (f_carry inclusion leads to dead end #13
    inconsistency). Round-robin targeting with `self_resolving_fwd_step` loses
    F(phi) at resolving steps for other formulas, so F(phi) may not survive
    to phi's round-robin turn. Similarly, `fwd_succ` at resolving steps kills
    f_carry (dead end #24).
    **Root cause**: Fundamental tension between target resolution and
    F-obligation preservation in Lindenbaum-based chains. Any seed that includes
    both target and f_carry is potentially inconsistent (dead end #13), and any
    seed without f_carry loses F-obligations at resolving steps.

35. **Path A: Oracle-based chain replacement partially viable but blocked by
    defect-count sorry** (task 93, plan v44 Phase 4): The oracle infrastructure
    (`hintikka_step_for_sigma_sig`) provides G-propagation, H-backward, and
    Until-propagation, all sorry-free. The strategy: F(φ) → (⊤ U φ) by BX12,
    then oracle defect-discharge resolves (⊤ U φ). Two blockers:
    (a) **Defect-count decrease sorry** (`OracleStep.lean:452`): Lindenbaum
    extension may introduce new Until-defects not present in the original MCS,
    so `defect_count(sigma_sig(oracle_step)) < defect_count(sigma_sig(w))`
    is not proven. This sorry exists in the "fully sorry-free oracle"
    `hintikka_step_oracle_for_sigma_sig`.
    (b) **Enhanced oracle seed F-preservation**: Adding `{F(φ) | F(φ) ∈ w,
    φ ∈ Sigma}` to the oracle seed IS consistent (it's a subset of w.formulas),
    which would give F-preservation. But this is novel infrastructure not yet
    built, and the defect-count sorry (a) blocks the termination argument
    regardless.
    **Positive finding**: The enhanced oracle seed approach avoids dead end #13
    because the additional F-formulas are already in the MCS (subset
    consistency), unlike the f_carry approach which adds formulas to a seed
    that may conflict with g_content.

### Task 93: Progress and Infrastructure

Six sorry-free helper lemmas proved during v17 Phase 1 (all in
`RootScopedChain.lean`):
- `discharge_single_step`: Given F(psi) in MCS M, exists M' with psi in M'
  and g_content(M) subset M'.
- `discharge_two_step`: Two-target version using BX11 ordering.
- `enriched_resolving_seed_consistent`: Seed {psi, alpha} union g_content(M)
  is consistent when F(psi and alpha) in M.
- `bx11_earlier_resolving_seed_strong`: When target is bx11_earlier than chi,
  produces a resolving alpha from the BX11 compound.
- `rr_fwd_chain_F_obligation_forward`: F-obligation constancy (forward).
- `rr_fwd_chain_F_obligation_backward`: F-obligation constancy (backward).

F-obligation constancy infrastructure: `rr_fwd_chain_F_propagate` reduces
forward_F to "F(psi) cannot persist at every future step". The
`enriched_fwd_step_preserves` gives disjunctive F-preservation at each step.

The core finding: the `.choose` in `set_lindenbaum` (called via
`resolving_enriched_fwd_exists`) is the root cause of the forward_F gap.
Controlling this choice is the only viable path. Standard completeness proofs
(Burgess 1984, Goldblatt 1992, GHR 1994) handle forward_F semantically, not
syntactically.

### Current Strategy: Three-Path DD-BFMCS Coherence (Plan v44)

After 44 rounds of research and planning, the strategy attempts three
architecture paths (C, A, B) to close the 5 remaining sorry sites in
`RootScopedChain.lean`. Plan v42's Reynolds induction approach was found to be
blocked by defect oscillation (dead end #33). The oracle replacement approach
(qm_bfmcs, plan v40 phases 3-4) was archived after hitting a backward coherence
obstruction.

**Path C (pigeonhole fix)**: Target `fwd_chain_forward_F` directly. Since
`fwd_chain_F_persistent` proves F(phi) persists at all future steps, and
`defect_step_choice_early_spec` resolves at least one defect per step,
the argument is: with a finite sigma_list of k formulas, at each step some
defect w is placed directly in the next MCS. The pigeonhole argument on the
finite defect set should eventually force phi to be the resolved formula.

**Path A (oracle-based chains)**: Replace `fwd_chain_of_sigma` /
`bwd_chain_of_sigma` with oracle-based variants using the sorry-free
`hintikka_step_for_sigma_sig` infrastructure. Defect resolution is built
into the oracle step.

**Path B (quasimodel BFMCS)**: Replace `dd_bfmcs` entirely with a new BFMCS
built from palindromic cycling of the quasimodel HintikkaPoint chain.
`dd_countermodel` is fully parametric over BFMCS, so any BFMCS satisfying the
three restricted coherence properties can be substituted.

**Infrastructure already in place** (all sorry-free):
- `deferralClosure`: finite set of formulas reachable by F/P-nesting from root
- `fwd_succ` / `bwd_pred`: sorry-free successor/predecessor step constructions
- `defect_step_choice_early` / `defect_step_choice_early_spec`: F-persistence + resolution
- `fwd_chain_F_persistent`: F(chi) persists across all forward chain steps
- `preserving_fwd_step_F_preserved`: F-obligations preserved at each step
- `target_stays_direct_in_fold`: target guaranteed in M' when bx11_earlier than all others
- Quasimodel infrastructure (1,816 lines across 6 files in `Quasimodel/`)
- Oracle infrastructure in `OracleStep.lean` (sigma-specific oracle sorry-free)
- Restricted parametric truth lemma (sorry-free)

**Archived code**:
- `DRMChain.lean` and proof sketch sections 1-30 in `Boneyard/RoundRobinChain/`
- Oracle coherence (qm_bfmcs) in `Boneyard/OracleCoherence.lean`

**Plan**: 7 phases (12 hours estimated). Phase 1 updates ROAD_MAP.md.
Phase 2 attempts Path C (pigeonhole). Phase 3 evaluates.
Phases 4-7 (conditional) attempt Paths A and B if earlier paths fail.

---

## Other Open Items

### Dense Completeness (task 68, 1 sorry)

- `dense_completeness_fc` needs a separate proof using a dense canonical model
  (e.g., over `ℚ`).
- Cannot reduce to `completeness_over_Int` since `Int` is not densely ordered.
- Independent of the BX canonical construction.

### FMP Truth Preservation (task 82, 0 sorries in active tree)

- The sorries previously in `TruthPreservation.lean` (`mcs_all_future_closure`
  and `mcs_all_past_closure`) have been **archived to Boneyard**. The FMP module
  is currently sorry-free in the active source tree.
- Task 82's description may need reassessment: the original sorries are gone,
  so the task may already be complete or may need a new description.
- **Decidability track only** -- not a path to the completeness representation
  theorem.
- Independent of BXCanonical.

### Soundness (sorry-free)

- `Soundness.lean`, `DenseSoundness.lean`, and `DiscreteSoundness.lean` are
  all **entirely sorry-free**. Confirmed 2026-04-13.

### Examples / Pedagogical (~57 sorries)

- `Demo.lean`, `ModalProofs.lean`, `ModalProofStrategies.lean`,
  `TemporalProofs.lean`, and others.
- Expected and intentional (exercises, demonstrations).

### Boneyard (~14 sorries)

- Archived dead code across `Boneyard/` subdirectories. Expected.

---

## Investigated Dead Ends: Logic Weakening (Task 77)

**Conclusion**: Weakening TM by using a preorder (instead of linear order)
for `D` does NOT provide a viable path to completeness. The F/P witness
blocker is independent of the order structure on `D`.

---

## Representation Theorem Goal

> "TM is complete with respect to TaskFrames over totally ordered abelian groups."

**Only the algebraic/canonical model approach is pursued for completeness.**
The representation theorem characterizes TM by showing that every consistent
formula has a model built from the logic's own proof-theoretic structure
(MCS ↔ worlds, truth lemma connecting membership and semantic truth). This
structural correspondence is the scientific contribution — it tells us what
TM *is*, not merely that it is complete.

**Decidability-based completeness is explicitly excluded as a path to the
representation theorem.** A decision procedure can establish
`valid(φ) → provable(φ)` as a bare fact, but it provides no canonical model
construction, no truth lemma, no structural correspondence between
proof-theoretic and semantic notions, and no template for extensions of the
logic. Decidability is of independent interest (see task 82, FMP track) and
may yield a follow-up result, but it does not serve the goal of frame class
characterization.

---

## Recommended Priority Order

### Critical Path (sequential)

1. **Task 93**: Close 5 remaining sorry sites in `RootScopedChain.lean`. The
   **sole remaining active-path sorry cluster**. Requires `fwd_chain_forward_F`
   (F-resolution), restricted temporal coherence (forward + backward),
   backward Until/Since, and forward Until/Since coherence.
   **Current approach**: Three-path strategy (Plan v44, 7 phases).
2. **Task 95**: `#print axioms` audit on `bx_completeness`; expected output
   is exactly `{propext, Classical.choice, Quot.sound}`. Depends on task 93.

### Documentation/Cleanup (parallelizable)

3. **Task 94**: Archive legacy strict-semantics files to
   `Boneyard/StrictSemanticsLegacy/`. Drops ~20 sorries from active tree.
4. **Task 104**: Clean up superseded tasks in state.json (abandon 89,
   update 60/87/998).
5. **Task 105**: Update stale sorry-blocker comments in BXCanonical code.

### Independent Tracks

6. **Task 68**: Dense completeness via `ℚ` canonical model (independent).
7. **Task 82**: FMP Truth Preservation -- may need reassessment (sorries
   archived to Boneyard, 0 remain in active tree).
8. **Task 60**: Remove `discrete_Icc_finite_axiom` (may already be gone).

---

## Task Cross-Reference

> **Updated 2026-04-19 (task 93 plan v44: three-path strategy for DD-BFMCS coherence)**

| Task | Status | Description | Depends On |
|------|--------|-------------|------------|
| 91 | **[COMPLETED]** | Rewrite ROAD_MAP.md for BX reflexive semantics | — |
| 90 | **[COMPLETED]** | Research Option A vs Option B for Until/Since closure | — |
| 92 | **[COMPLETED]** | Implement Until/Since truth lemma approach | 90 |
| 98 | **[COMPLETED]** | Implement eventuality resolution (Frame.lean:653, 690) | 92 |
| 102 | **[COMPLETED]** | Close remaining Frame.lean sorries (675, 704, 440) | 98 |
| 93 | [IMPLEMENTING] | Close RootScopedChain.lean 5 sorries (three-path strategy, plan v44) -- **5 active-path sorries** | 102 |
| 95 | [NOT STARTED] | `#print axioms` audit on `bx_completeness` | 93 |
| 103 | **[COMPLETED]** | Comprehensive ROAD_MAP.md rewrite for post-Until/Since state | — |
| 94 | **[COMPLETED]** | Archive strict-semantics legacy files to Boneyard | 103 |
| 104 | [NOT STARTED] | Clean up superseded tasks + fix state.json | — |
| 105 | [NOT STARTED] | Update stale sorry-blocker comments in BXCanonical | — |
| 82 | [NOT STARTED] | FMP Truth Preservation (weak completeness, independent) | — |
| 68 | [RESEARCHED] | Dense completeness via ℚ canonical model | — (independent) |
| 60 | [NOT STARTED] | Remove `discrete_Icc_finite_axiom` (may already be gone) | — |

---

*Last updated: 2026-04-19 (task 93 plan v44: three-path strategy for DD-BFMCS coherence, sorry inventory updated to 5 sites with correct line numbers)*
