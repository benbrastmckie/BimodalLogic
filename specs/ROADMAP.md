# Roadmap: BX Completeness and Publication

## Overview

TM is a bimodal logic combining S5 modality with irreflexive linear temporal logic,
axiomatized via the **Burgess-Xu (BX) system**. This roadmap describes the current
state of the completeness effort as of 2026-04-25 (C4 definition fix, g_ordered eliminated).

**Architecture**: The proof system has 35 BX axioms (propositional, S5 modal,
Burgess-Xu temporal, and modal-temporal interaction). The temporal semantics is
**irreflexive**: G/H quantify over `t < s` / `s < t` (strict inequality), and
Until/Since require strictly future/past witnesses. There are two active
completeness paths:

1. **BXCanonical** (`Theories/Bimodal/Metalogic/BXCanonical/`): Canonical frame
   of maximally consistent sets ordered by `g_content` inclusion. The 5 critical-path
   sorries in `RootScopedChain.lean` are blocked by Lindenbaum opacity (see dead ends
   #34-#36). Task 109 tracks these.
2. **Chronicle** (`Theories/Bimodal/Metalogic/BXCanonical/Chronicle/`): Burgess 1982
   chronicle construction using controlled PointInsertion to escape Lindenbaum opacity.
   Task 107 (active) identified a C4 definition error (arguments swapped relative to
   Burgess 1982) that was the root cause of 25 research rounds. C4 now fixed, g_ordered
   deleted (unnecessary with correct C4). 13 sorry sites remain across 4 files.
   This is the primary completeness path.

**Sorry summary**: The BXCanonical module has **19 sorry proofs** across 7 files,
plus the Chronicle sub-module has **12 sorry proofs** across 3 files.

BXCanonical sorries (task 109 Phase 1 removed 4 dead-code sorries from CanonicalModel):

| Category | Count | Files | Status |
|----------|-------|-------|--------|
| **Critical path** (blocking `bx_completeness`) | 5 | `RootScopedChain.lean` | **OPEN** (task 109) |
| **Irreflexive-consequence** (BX1 removal artifacts) | 14 | Frame, TruthLemma, CanonicalModel, Construction, Realization, SigmaOrdering | **OPEN** (task 109) |
| **Total BXCanonical** | **19** | 7 files | |
| Oracle replacement (qm_bfmcs) | 6 | archived to Boneyard/OracleCoherence.lean | **ARCHIVED** (2026-04-18) |
| Legacy strict-semantics files | 107 | archived to Boneyard/StrictSemanticsLegacy/ | **DONE** (task 94, 2026-04-12) |

The 5 critical-path sorries in `RootScopedChain.lean` (lines 1065, 1092, 1099, 1107, 1114)
block `dd_countermodel`, which `Completeness.lean` delegates to for the completeness proof.
The 18 irreflexive-consequence sorries are artifacts of the BX1 removal (e.g., `bx_le_refl`,
`g_content_subset_self`, `refl_intro_until_mcs`, `sigma_le_refl`) that need redesign under
irreflexive semantics.

**BXCanonical dependency chain**: `fwd_chain_forward_F` -> `restricted_tc` -> `restricted_buc` -> `restricted_fuc`.

Chronicle sorries (task 107, updated 2026-04-25):

| Category | Count | Files | Status |
|----------|-------|-------|--------|
| **forward_G/backward_H** (limit temporal propagation) | 2 | `ChronicleConstruction.lean` | **IN PROGRESS** (C4+C0 proof) |
| **C4 hard cases** (counterexample elimination) | 2 | `CounterexampleElimination.lean` | **OPEN** |
| **Lemma 2.6 full** (three-way decomposition) | 1 | `PointInsertion.lean` | **OPEN** |
| **Countermodel wiring** (FMCS coherence) | 8 | `ChronicleToCountermodel.lean` | **OPEN** |
| **Total Chronicle** | **13** | 4 files | |

**Key finding (task 107 report 25, 2026-04-25)**: The codebase's C4 definition had its arguments
SWAPPED relative to Burgess 1982 C4a. Burgess checks the EVENT (first arg of U) at f(y) and
negates the GUARD (second arg) at f(z). The codebase was checking the GUARD and negating the EVENT.
This caused forward_G to be unprovable from C4+C0 (producing φ.neg.neg instead of ⊥), leading to
25 rounds of workaround attempts involving g_ordered, two-sided seeds, and duality arguments.

With the corrected C4: G(φ) = ¬(⊤ U ¬φ). C4 checks ¬φ (EVENT) at f(y), gives ⊤.neg = ⊥ at f(z).
⊥ in MCS contradicts C0. **One-step proof of forward_G.** g_ordered is unnecessary and has been
deleted from ChronicleInvariant. The `g_content_chain_property` blocker (report 17) is resolved.

**Key finding -- density axiom** (task 107 report 11): Dense domains (e.g., Q) are WRONG for
general completeness. GGp->Gp is valid on Q but not derivable in BX. Burgess uses sparse
X ⊂ Q. The representation theorem goal (D=Rat, totally ordered abelian groups) accepts GGp->Gp
as valid for that specific frame class. General completeness (all strict linear orders) requires
sparse X where GGp->Gp may fail.

See sections below for the axiom system, irreflexive semantics, canonical
construction, sorry inventory, and the Burgess-Xu Until-induction proof strategy.

---

## BX Axiom System

`Theories/Bimodal/ProofSystem/Axioms.lean` defines 35 axiom constructors in
four layers (see `Axioms.lean:46-49` for Burgess 1982/84, Xu 1988, Venema 1993
references). Under irreflexive semantics (strict `<` for G/H, strict witness
for U/S), the axiom set replaces BX1/BX1' (reflexive T) with seriality axioms
and removes BX8/BX8' (not sound under irreflexive Until/Since).

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

### Layer 3: BX Temporal (24)

| Axiom | File:Line | Statement (future direction) | Role |
|-------|-----------|------------------------------|------|
| `temp_k_dist` | Axioms.lean:107 | `G(φ → ψ) → (Gφ → Gψ)` | K for G |
| `temp_4` | Axioms.lean:112 | `Gφ → GGφ` | Transitivity; needed for `bx_le_trans` |
| BX1 `serial_future` | Axioms.lean:117 | `T → F(T)` | Seriality (replaces reflexive T) |
| BX1' `serial_past` | Axioms.lean:122 | `T → P(T)` | Mirror seriality |
| BX2 `left_mono_until` | Axioms.lean:127 | `(φ→χ) ∧ G(φ→χ) → ((φUψ)→(χUψ))` | Left monotonicity |
| BX2' `left_mono_since` | Axioms.lean:133 | mirror for S | |
| BX3 `right_mono_until` | Axioms.lean:139 | `G(φ→ψ) → ((χUφ)→(χUψ))` | Right monotonicity |
| BX3' `right_mono_since` | Axioms.lean:143 | mirror for S | |
| BX4 `connect_future` | Axioms.lean:150 | `φ → G(P(φ))` | Temporal connectedness |
| BX4' `connect_past` | Axioms.lean:155 | `φ → H(F(φ))` | Mirror |
| BX5 `self_accum_until` | Axioms.lean:161 | `(φUψ) → ((φ ∧ (φUψ))Uψ)` | **Key eventuality axiom** |
| BX5' `self_accum_since` | Axioms.lean:166 | mirror for S | |
| BX6 `absorb_until` | Axioms.lean:173 | `(φU(φ ∧ (φUψ))) → (φUψ)` | Prevents infinite deferral |
| BX6' `absorb_since` | Axioms.lean:177 | mirror for S | |
| BX7 `linear_until` | Axioms.lean:184 | four-formula linearity disjunction | Linearity of U witnesses |
| BX7' `linear_since` | Axioms.lean:194 | mirror for S | |
| BX10 `until_F` | Axioms.lean:211 | `(φUψ) → F(ψ)` | Eventuality extraction |
| BX10' `since_P` | Axioms.lean:216 | mirror for S | |
| BX11 `temp_linearity` | Axioms.lean:225 | F-witness linearity disjunction | Linear order on F witnesses |
| BX11' `temp_linearity_past` | Axioms.lean:234 | mirror for P | |
| BX12 `F_until_equiv` | Axioms.lean:243 | `F(φ) → (⊤Uφ)` | Bridges F to U |
| BX12' `P_since_equiv` | Axioms.lean:248 | `P(φ) → (⊤Sφ)` | Mirror |

*Note: BX8/BX8' (until_step/since_step) removed -- not sound under irreflexive semantics.*
*Note: BX9/BX9' (until_elim/since_elim) and until_guard/since_guard removed -- not sound under open guard `(t,s)` semantics (task 113).*

### Layer 4: Modal-Temporal Interaction (2)

| Axiom | File:Line | Statement |
|-------|-----------|-----------|
| `modal_future` | Axioms.lean:263 | `□φ → □(Gφ)` |
| `temp_future` | Axioms.lean:266 | `□φ → G(□φ)` |

### Irreflexive semantics and the seriality switch

Under the irreflexive semantics switch (task 93), BX1/BX1' (`Gφ → φ` / `Hφ → φ`)
were replaced by seriality axioms (`T → F(T)` / `T → P(T)`). This means:

- `bx_le` is no longer reflexive (g_content(w) is NOT a subset of w)
- `g_content_set_consistent` uses seriality instead of BX1: if G(bot) in MCS,
  seriality gives F(T) = not G(neg T), and G(bot) implies G(neg T) by ex falso,
  contradiction
- BX8/BX8' (until_step/since_step) were removed entirely -- not sound under irreflexive semantics
- `φ → F(φ)` is NOT derivable -- this is the KEY insight for completeness:
  resolved defects do not re-enter as F-obligations

The critical architectural consequence: under irreflexive semantics, the
active defect count strictly decreases at each chain step, because resolved
formulas φ in M' do NOT generate F(φ) in M'. This unblocks the 5 remaining
sorry sites in RootScopedChain.lean.

---

## Irreflexive Truth Semantics

All four temporal operators in TM use strict (irreflexive) ordering. The current
point is EXCLUDED for G and H (`<`), and Until/Since witnesses must be strictly
future/past (`t < s` / `s < t`) with open guards.

From `Theories/Bimodal/Semantics/Truth.lean:120-131`:

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M Omega τ t φ → truth_at M Omega τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
  | Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ
  | Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
      ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
      ∀ r : D, s < r → r < t → truth_at M Omega τ r φ
```

- **G (`all_future`)**: `∀ s, t < s → ...` — strict future (excludes `t`).
- **H (`all_past`)**: `∀ s, s < t → ...` — strict past (excludes `t`).
- **U (`untl`)**: `∃ s, t < s ∧ ψ@s ∧ ∀ r, t < r < s → φ@r` — strict witness,
  open guard `(t, s)`.
- **S (`snce`)**: `∃ s, s < t ∧ ψ@s ∧ ∀ r, s < r < t → φ@r` — mirror.

Under irreflexive semantics, `Gφ → φ` is NOT valid (BX1 removed), and
`φ → F(φ)` is NOT derivable. Seriality axioms (`T → F(T)`, `T → P(T)`)
ensure the temporal order has no maximum/minimum elements.

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

Unfolding `Formula.next φ = Formula.untl Formula.bot φ` against the irreflexive
Until clause (`Truth.lean:128-129`):

```
truth_at (⊥ U φ) at t  ↔  ∃ s, t < s ∧ truth_at φ s ��� ∀ r, t < r → r < s �� truth_at ⊥ r
                       ↔  ∃ s, t < s ∧ truth_at φ s ∧ ∀ r, t < r → r < s → False
                       ↔  ∃ s, t < s ∧ truth_at φ s ∧ (∀ r, ¬(t < r ∧ r < s))
                       ↔  ∃ s, t < s ∧ truth_at φ s ∧ (t, s) = ∅
```

Under irreflexive semantics, `⊥ U φ` at `t` requires a strictly future witness
`s > t` with `φ(s)` and an empty open interval `(t, s)`. The behavior depends
on the order structure:

- **Discrete order** (e.g., `ℤ`): The interval `(t, s)` is empty iff `s = t + 1`.
  So `X(φ)` at `t` means `φ` holds at the immediate successor `t + 1`. This is
  a genuine next-step operator, matching the docstring's "discrete strict semantics."
  Similarly, `Y(φ)` at `t` means `φ` holds at `t - 1`.

- **Dense order** (e.g., `ℚ` or `ℝ`): The interval `(t, s)` is never empty for
  `s > t`. So `⊥ U φ` is unsatisfiable on dense orders, and `X(φ)` is always
  false. Similarly, `Y(φ)` is always false on dense orders.

Under the current irreflexive semantics, `X`/`Y` have genuine semantic content
on discrete orders (they are true next/previous-step operators). On dense orders,
they are vacuously false. **They are not currently used in proofs**, but they
are no longer trivially equivalent to their argument as they were under the
former reflexive semantics.

---

## Active Metalogic Paths

Two completeness paths are active. The **Chronicle** path (task 107) is the primary
path and is under active development. The **BXCanonical** path (task 109) is secondary;
its 5 critical-path sorries are blocked by Lindenbaum opacity (dead ends #34-#36) and
will become dead code once the chronicle path succeeds.

### Path 1: Chronicle Construction (Task 107, PRIMARY)

The Burgess 1982 chronicle construction builds a countermodel via controlled
PointInsertion, escaping the Lindenbaum opacity that blocks BXCanonical. The
construction lives in `Metalogic/BXCanonical/Chronicle/` (6 files, ~2990 lines).

**Current state**: 12 sorry sites. The critical bottleneck is `g_content_chain_property`
in `ChronicleConstruction.lean`, caused by an architecturally wrong unary g function.
Task 107 is rebuilding with Burgess's binary g(x,y) interval function.

**Chronicle module structure**:
- `ChronicleTypes.lean` (354 lines) -- Chronicle structure, ChronicleProperty invariant
- `PointInsertion.lean` (450 lines) -- Lemma 2.4/2.6 controlled MCS insertion (sorry-free)
- `RRelation.lean` (345 lines) -- R-relation infrastructure (sorry-free)
- `CounterexampleElimination.lean` (561 lines) -- C4/C5 elimination (2 sorries)
- `ChronicleConstruction.lean` (857 lines) -- Omega-chain, limit construction (1 sorry)
- `ChronicleToCountermodel.lean` (423 lines) -- BFMCS wiring (9 sorries)

**Key insight (report 17)**: The hybrid Int-chain + enriched seed approach is definitively
dead (dead ends #7, #13, #23, #31). The chronicle construction is NOT a dead end -- all
gaps are engineering problems, not mathematical impossibilities (report 16).

### Path 2: BXCanonical (Task 109, SECONDARY)

The BXCanonical path flows through `Metalogic/BXCanonical/`. The
legacy `UltrafilterChain`, `FrameConditions/Completeness`, and `SuccChainFMCS`
modules are still built via top-level aggregation in `Metalogic.lean:1-4` but
are **not imported** by `BXCanonical`.

### Module Import Graph

```
Metalogic/BXCanonical/BXCanonical.lean (28 lines, aggregator)
  ├── Frame.lean (726 lines, 1 sorry: bx_le_refl)
  │     ├── Core/MaximalConsistent
  │     ├── Core/MCSProperties
  │     ├── Bundle/TemporalContent
  │     ├── Bundle/WitnessSeed
  │     ├── Bundle/CanonicalFrame
  │     ├── Syntax/Formula
  │     └── Theorems/GeneralizedNecessitation
  │
  ├── TruthLemma.lean (319 lines, 2 sorries: until/since_backward_refl_mcs)
  │     ├── Frame
  │     ├── Semantics/Truth
  │     └── Semantics/Validity
  │
  ├── Completeness.lean (152 lines, sorry-free -- delegates to RootScopedChain)
  │     ├── RootScopedChain
  │     └── Semantics/Validity
  │
  ├── CanonicalChain.lean (160 lines, sorry-free)
  │     ├── Frame
  │     ├── Quasimodel/Construction
  │     └── Filtration/DefectChain
  │
  ├── OrderedSeedConsistency.lean (255 lines, sorry-free)
  │     ├── Frame
  │     └── CanonicalChain
  │
  ├── CanonicalModel.lean (~440 lines, 2 sorries: g/h_content_subset; dead-code removed in task 109 Phase 1)
  │     ├── CanonicalChain
  │     ├── TruthLemma
  │     └── Bundle/FMCSDef
  │
  ├── RootScopedChain.lean (1,487 lines, 5 sorries -- task 109)
  │     ├── OrderedSeedConsistency
  │     ├── CanonicalModel
  │     ├── Bundle/UntilSinceCoherence
  │     ├── Algebraic/ParametricRepresentation
  │     └── Algebraic/RestrictedParametricTruthLemma
  │
  ├── Quasimodel/
  │     ├── SubformulaClosure.lean (114 lines, sorry-free)
  │     │     └── Syntax/Formula
  │     ├── HintikkaPoint.lean (144 lines, sorry-free)
  │     │     ├── SubformulaClosure
  │     │     └── Frame
  │     ├── EnrichedClosure.lean (158 lines, sorry-free)
  │     │     ├── Syntax/BigConj
  │     │     ├── SubformulaClosure
  │     │     └── Mathlib.Data.Finset.Powerset
  │     ├── Construction.lean (885 lines, 2 sorries: refl_intro_until/since_mcs)
  │     │     ├── HintikkaPoint
  │     │     └── Mathlib.Data.List.Chain
  │     ├── Realization.lean (576 lines, 4 sorries: F/P_of_mem, g/h_content in seed)
  │     │     ├── Construction
  │     │     ├── Syntax/BigConj
  │     │     ├── Theorems/Combinators
  │     │     └── Theorems/Propositional
  │     └── LocusControl.lean (47 lines, sorry-free)
  │           └── Realization
  │
  └── Filtration/
        ├── SigmaOrdering.lean (167 lines, 3 sorries: sigma_le_refl, sigma_strict_irrefl, not_sigma_equiv)
        │     ├── Frame
        │     └── Quasimodel/EnrichedClosure
        └── DefectChain.lean (137 lines, sorry-free)
              ├── SigmaOrdering
              └── Quasimodel/Construction
```

**Total BXCanonical module: ~5,795 lines across 16 files, 19 sorries (5 critical-path + 14 irreflexive-consequence). Task 109 Phase 1 removed 4 dead-code sorries from CanonicalModel.lean.**

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

- **Reflexivity** (`bx_le_refl`): NOT valid under irreflexive semantics (BX1 removed).
  Without BX1, `g_content w ⊆ w` fails. `bx_le_refl` is sorry'd (intentionally invalid).
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
- `g_content_set_consistent` (Frame.lean:122-162): `g_content` of an MCS is
  consistent; uses seriality (`T → F(T)`) to contradict `G(⊥) ∈ S` via
  `G(⊥) → G(¬⊤)` and `F(⊤) = ¬G(¬⊤)`. Sorry-free.
- `bx_forward_witness` / `bx_backward_witness`: Lindenbaum extension producing
  G/H canonical witnesses.
- `bx_modal_witness` (Frame.lean): constructs the modal-direction witness.
  Sorry-free (closed by task 102).

### Truth Lemma (TruthLemma.lean:27-36)

Proved by formula induction. The core cases (`atom`, `bot`, `imp`, `box`, `G`, `H`,
`U` forward, `S` forward) are **sorry-free**. The `U` and `S` forward cases delegate
to `bx_until_eventuality_resolution` / `bx_since_eventuality_resolution` in
`Frame.lean`, closed by tasks 98+102. Two auxiliary lemmas
(`until_backward_refl_mcs`, `since_backward_refl_mcs`) are sorry'd as
irreflexive-consequence artifacts -- they assumed reflexive Until/Since introduction
which is invalid under irreflexive semantics.

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

Step 4 is handled by `dd_countermodel` (in `RootScopedChain.lean`), which
`Completeness.lean` calls directly. `Completeness.lean` itself is sorry-free;
the remaining sorries are in the chain construction that `dd_countermodel`
depends on (see Sorry Inventory above).

---

## Quasimodel/Filtration Infrastructure

Nine files (2,228 lines) under `BXCanonical/` implement a Hintikka-set
quasimodel with defect-discharge to close the Until/Since eventuality
obligations. Under irreflexive semantics, 9 of these sorries are
irreflexive-consequence artifacts (Construction 2, Realization 4,
SigmaOrdering 3); the remaining files are sorry-free.

### Quasimodel/ (Hintikka-set quasimodel construction)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `SubformulaClosure.lean` | 114 | Finite subformula closure (Sigma-closure) | `subformulas`, `SubformulaClosure`, `ghEnrichment` |
| `HintikkaPoint.lean` | 144 | Hintikka point definition and sigma-signature | `HintikkaPoint`, `sigma_signature`, `sigma_signature_consistent`, `sigma_signature_maximal` |
| `EnrichedClosure.lean` | 158 | Fisher-Ladner enriched closure with G/H negation formulas | `enrichedGNegBigconj`, `enrichedHNegBigconj`, `enrichedClosure` |
| `Construction.lean` | 885 | BX axiom lemmas at MCS level with defect-discharge (2 sorries) | `hintikka_step`, `UntilDefect`, `defect_count`, `QuasimodelChain` |
| `Realization.lean` | 576 | Realization lifting from Hintikka chains to BXPoint chains (4 sorries) | `until_forward_seed`, `since_backward_seed`, `until_eventuality_resolution`, `since_eventuality_resolution` |
| `LocusControl.lean` | 47 | Delegation layer (primed variants) | `bx_until_eventuality_resolution'`, `bx_since_eventuality_resolution'` |

### Filtration/ (Sigma-restricted ordering)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `SigmaOrdering.lean` | 167 | Sigma-restricted ordering on BXPoints (3 sorries) | `sigma_le`, `sigma_strict`, `sigma_equiv`, `bx_le_implies_sigma_le` |
| `DefectChain.lean` | 137 | Defect-discharge chain via well-founded recursion | `sigma_defect_count`, `until_defect`, `defect_step_phi` |

### CanonicalChain.lean (top-level bridge)

| File | Lines | Purpose | Key Definitions |
|------|-------|---------|-----------------|
| `CanonicalChain.lean` | 160 | MCS-level BX axiom lemmas and delegation bridges (sorry-free) | `psi_imp_until_mcs`, `psi_imp_since_mcs`, `F_imp_top_until_mcs`, `left_mono_until_mcs` |

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

## Sorry Inventory

The BXCanonical module has **23 sorry proofs** in three categories.

### Critical Path (5 sorries in RootScopedChain.lean)

`Completeness.lean` is sorry-free but delegates to `dd_countermodel` in
`RootScopedChain.lean`, which depends on these 5 sorry sites:

| # | File:Line | Definition | Goal Summary | Owning Task |
|---|-----------|------------|--------------|-------------|
| 1 | RootScopedChain.lean:1065 | `fwd_chain_forward_F` | F-resolution for preserving chain | **Task 109** |
| 2 | RootScopedChain.lean:1092 | `dd_bfmcs_restricted_tc` (fwd, backward chain case) | Restricted temporal coherence (backward chain F-case) | **Task 109** |
| 3 | RootScopedChain.lean:1099 | `dd_bfmcs_restricted_tc` (backward direction) | Backward temporal coherence (P-resolution) | **Task 109** |
| 4 | RootScopedChain.lean:1107 | `dd_bfmcs_restricted_buc` | Backward Until/Since coherence | **Task 109** |
| 5 | RootScopedChain.lean:1114 | `dd_bfmcs_restricted_fuc` | Forward Until/Since coherence | **Task 109** |

### Irreflexive-Consequence (18 sorries across 6 files)

These are artifacts of the BX1/BX1' removal (task 93). Under the former reflexive
semantics, `G(φ) → φ` (BX1) made these provable; under irreflexive semantics,
they are either mathematically false (e.g., `bx_le_refl`) or require redesign.

| File | Sorries | Key Definitions |
|------|---------|-----------------|
| Frame.lean | 1 | `bx_le_refl` (intentionally invalid) |
| TruthLemma.lean | 2 | `until_backward_refl_mcs`, `since_backward_refl_mcs` |
| CanonicalModel.lean | 2 | `g_content_subset_self`, `h_content_subset_self` (4 dead-code sorries removed in task 109 Phase 1) |
| Construction.lean | 2 | `refl_intro_until_mcs`, `refl_intro_since_mcs` |
| Realization.lean | 4 | `F_of_mem`, `P_of_mem`, g/h_content subset in seed proofs |
| SigmaOrdering.lean | 3 | `sigma_le_refl`, `sigma_strict_irrefl`, `not_sigma_equiv_of_sigma_strict` |

### Irreflexive Semantics Strategy (Plan v48, 2026-04-19)

The irreflexive semantics switch (task 93, plan v48) resolves the fundamental
obstruction that blocked all previous approaches: under reflexive semantics,
`phi -> F(phi)` is derivable (from BX1), so resolving a defect phi creates
F(phi) which regenerates the defect. This "defect oscillation" blocked
pigeonhole arguments, oracle chains, and quasimodel approaches.

Under irreflexive semantics, `phi -> F(phi)` is NOT derivable because
`G(neg phi) -> neg phi` (BX1) is removed. This means:

- At each chain step, `defect_step_early` gives: for each defect chi,
  either `chi in M'` (resolved) or `F(chi) in M'` (still pending)
- Resolved defects do NOT re-enter as F-obligations
- Active defects (chi with F(chi) in M) strictly decrease at each step
- After at most |sigma_list| steps, all defects are resolved

**Key structural changes:**
- `defect_step_early` weakened from `F(chi) in M'` to `chi in M' OR F(chi) in M'`
- `fwd_chain_F_persistent` replaced by `fwd_chain_defect_one_step` (single-step)
- `defect_step_from_earliest` output weakened to disjunctive form
- `g_content_set_consistent` proved via seriality (not BX1)
- `h_content_set_consistent` proved via seriality (not BX1')
- `enriched_seed_consistent` bypassed (fwd_succ uses g_content alone)

**Phase 3-4 remaining work:** Build finite descent argument on active_defects
to close the 5 sorry sites. The defect step infrastructure is in place; the
proof requires showing that |active_defects(chain(n+1))| < |active_defects(chain(n))|
when defects are present.

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

Frame.lean has **1 sorry** (`bx_le_refl`, intentionally invalid under irreflexive semantics).
The key consistency proofs (`g_content_set_consistent`, `h_content_set_consistent`,
`bx_H_backward`) are all sorry-free using seriality. See "How Until/Since Were Closed"
below for the approach that resolved the eventuality sorries.

---

## Legacy Code Inventory

The following files were written under earlier architectural iterations and are
**not imported by `BXCanonical`** and are not on the active completeness path.
**Task 94** archived them to `Boneyard/StrictSemanticsLegacy/` (completed 2026-04-12).
This dropped approximately **~20 sorries** from the active (non-Boneyard,
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
the Since-Until tense logic over **all linear orderings**. The BX axioms
BX1-BX12 in `Axioms.lean` are modeled on this axiomatization, adapted for
irreflexive semantics (BX1/BX1' replaced by seriality, BX8/BX8' removed).

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
6. **BX9 (`until_elim`)**: REMOVED (task 113). Was `(φUψ) → (φ ∨ ψ)`.
   Under open guard `(t,s)`, `t ∉ (t,s)` so `φ(t)` is not guaranteed.
   Not sound under open guard semantics.
7. **BX4 (`connect_future`)**: `φ → G(P(φ))` is used in the backward direction
   to propagate `¬(φUψ)` forward and derive a contradiction with the guard.
8. **BX1 (`serial_future`)**: `T → F(T)` (seriality). Replaces the former
   reflexive `Gφ → φ`. Consistency of `g_content` uses seriality to show
   `G(bot)` contradicts `F(T)`.

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

36. **Path B: Quasimodel-derived BFMCS blocked by same Lindenbaum opacity**
    (task 93, plan v44 Phase 6): Replacing dd_bfmcs entirely with a
    palindromic quasimodel chain faces the same irreducible obstruction.
    Two independent blockers:
    (a) **F/P eventuality resolution**: ANY Int-indexed MCS chain based on
    iterated Lindenbaum extensions via `Classical.choose` makes the
    chain(n+1) MCS opaque. The proved lemma "alpha in chain(n+1) implies
    F(alpha) in chain(n)" (contrapositive of g_content propagation) goes
    the WRONG direction -- it gives F-membership at the PREDECESSOR, not
    a WITNESS at a successor. F(phi) in chain(n) requires finding m > n
    with phi in chain(m), which requires controlling what `set_lindenbaum`
    chooses, regardless of whether the chain uses preserving_fwd_step,
    oracle_step, or any other Lindenbaum-based construction.
    (b) **Until/Since step transfer**: Backward Until coherence requires
    the step transfer `(phi U psi) in chain(r+1) AND phi in chain(r)
    implies (phi U psi) in chain(r)`. This requires pulling Until from a
    successor into the current step. The only known mechanism is the
    deterministic chain's bot-Until linking `(bot U alpha) in chain(r)
    iff alpha in chain(r+1)`, which is NOT available for Lindenbaum-based
    chains. The F-membership lemma gives `F(phi U psi) in chain(r)` from
    `(phi U psi) in chain(r+1)`, but there is NO BX axiom
    `phi AND F(phi U psi) -> phi U psi` (this would require a "next"
    operator). Under reflexive semantics, `or_until_in_mcs` gives
    `psi OR (phi AND (phi U psi)) -> phi U psi`, but this requires
    `(phi U psi)` at the SAME time step, not a future step.
    **Root cause**: The irreducible obstruction is the gap between
    SEMANTIC temporal reasoning (which can freely reference future/past
    states) and SYNTACTIC MCS membership (which is local to one MCS).
    Lindenbaum extensions are non-constructive (axiom of choice) and
    provide no inter-step structural guarantees. This obstruction applies
    to ALL three paths (C, A, B) equally.

37. **Chronicle construction is NOT a dead end** (task 107, report 16):
    Assessment confirmed that all chronicle gaps are engineering problems, not
    mathematical impossibilities. The PointInsertion lemmas (2.4, 2.6) are
    sorry-free. The g_content_chain_property blocker was traced to an
    architecturally wrong unary g function (report 17), not a fundamental
    obstruction. Binary g(x,y) with C3 decomposition resolves the root cause.
    **This is an anti-assessment, not a dead end**: the chronicle path is viable
    and is the primary completeness strategy.

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

### Current Strategy: Chronicle Construction (Task 107)

**Status**: The chronicle construction (task 107) is the active completeness strategy.
All three BXCanonical paths (C, A, B) from plan v44 are BLOCKED by Lindenbaum opacity
(dead ends #34-#36). The chronicle escapes this obstruction via controlled PointInsertion.

**BXCanonical obstruction (for reference)**: The gap between SEMANTIC temporal reasoning
(which can reference future/past states freely) and SYNTACTIC MCS membership (which is
local to one MCS). Lindenbaum extensions via `Classical.choose` are non-constructive
and provide no inter-step structural guarantees. The chronicle avoids this by building
MCS via PointInsertion with explicit control over the seed content.

**Chronicle approach (task 107, plan v11 — C4 fix)**:
1. **C4 definition fix**: C4/C4' swapped to match Burgess 1982 (check EVENT, negate GUARD). DONE.
2. **g_ordered eliminated**: Deleted from ChronicleInvariant. Unnecessary with correct C4. DONE.
3. **forward_G from C4+C0**: One-step proof at the limit via generalized C4. IN PROGRESS.
4. **C4 hard case rewrite**: Counterexample elimination with correct argument roles. TODO.
5. **Lemma 2.6 full seed**: Burgess's two-sided seed for C4 hard case. TODO.
6. **Countermodel wiring**: Close 8 ChronicleToCountermodel sorry sites. TODO.
7. **Representation theorem**: sorry-free `dd_countermodel_chronicle` over D=Rat.

**The hybrid Int-chain + enriched seed approach should NOT be revisited** (dead ends
#7, #13, #23, #31). The chronicle construction is confirmed to be the right path
(report 16: all gaps are engineering, not mathematical impossibilities).

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
- Backward Until/Since from step transfer (`backward_until_from_step`, sorry-free)
- Deterministic chain with bot-Until linking (Boneyard, sorry-free for backward Until)

**Archived code**:
- `DRMChain.lean` and proof sketch sections 1-30 in `Boneyard/RoundRobinChain/`
- Oracle coherence (qm_bfmcs) in `Boneyard/OracleCoherence.lean`

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

This is the stated ROADMAP goal. Since totally ordered abelian groups (e.g., Rat)
are dense, GGp->Gp is valid for this frame class. The chronicle construction
achieves this as **Path B** (D=Rat completeness, task 107 Phase 4).

**General completeness** (all strict linear orders) is a stretch goal achieved by
**Path A** (task 107 Phase 5). On sparse domains, GGp->Gp may fail (it is not
derivable in BX), which is correct -- BX is complete for ALL strict linear orders,
not just dense ones. The density axiom finding (report 11) established that dense
domains are wrong for general completeness.

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

### Critical Path: Chronicle (primary completeness strategy)

1. **Task 107** (ACTIVE): Rebuild chronicle with binary g(x,y), close 12 sorry sites.
   Phases: binary g rebuild -> guard resolution -> C4 sub-cases -> Rat completeness -> general completeness.
   This is the primary path to both the representation theorem (D=Rat) and general completeness
   (all strict linear orders).
2. **Task 112**: Systematic literature study supporting task 107 (Burgess 1982b, Venema 1993, etc.).
3. **Task 95**: `#print axioms` audit on completeness theorem. Depends on task 107 or 109.

### Secondary Path: BXCanonical (blocked, low priority)

4. **Task 109**: Close 23 BXCanonical sorries (5 critical-path + 18 irreflexive-consequence).
   Blocked by Lindenbaum opacity (dead ends #34-#36). The 5 critical-path sorries in
   `RootScopedChain.lean` become dead code once task 107 succeeds. The 18
   irreflexive-consequence sorries remain independently valuable for cleanup.

### Documentation/Cleanup (parallelizable)

5. **Task 104**: Clean up superseded tasks in state.json (abandon 89,
   update 60/87/998).
6. **Task 105**: Update stale sorry-blocker comments in BXCanonical code.

### Independent Tracks

7. **Task 68**: Dense completeness via Q canonical model (independent).
8. **Task 82**: FMP Truth Preservation -- may need reassessment (sorries
   archived to Boneyard, 0 remain in active tree).
9. **Task 60**: Remove `discrete_Icc_finite_axiom` (may already be gone).

---

## Task Cross-Reference

> **Updated 2026-04-24 (task 107: chronicle binary g rebuild, ROADMAP update)**

| Task | Status | Description | Depends On |
|------|--------|-------------|------------|
| 91 | **[COMPLETED]** | Rewrite ROAD_MAP.md for BX reflexive semantics | — |
| 90 | **[COMPLETED]** | Research Option A vs Option B for Until/Since closure | — |
| 92 | **[COMPLETED]** | Implement Until/Since truth lemma approach | 90 |
| 98 | **[COMPLETED]** | Implement eventuality resolution (Frame.lean:653, 690) | 92 |
| 102 | **[COMPLETED]** | Close remaining Frame.lean sorries (675, 704, 440) | 98 |
| 93 | **[COMPLETED]** | Irreflexive semantics switch: seriality axioms, BX8 removal, defect step redesign | 102 |
| 95 | [NOT STARTED] | `#print axioms` audit on completeness theorem | 107 or 109 |
| 103 | **[COMPLETED]** | Comprehensive ROAD_MAP.md rewrite for post-Until/Since state | — |
| 94 | **[COMPLETED]** | Archive strict-semantics legacy files to Boneyard | 103 |
| 104 | [NOT STARTED] | Clean up superseded tasks + fix state.json | — |
| 105 | [NOT STARTED] | Update stale sorry-blocker comments in BXCanonical | — |
| 106 | [IMPLEMENTING] | Rewrite ROADMAP.md for irreflexive semantics | 93 |
| 107 | **[IMPLEMENTING]** | Burgess chronicle construction: binary g rebuild, close 12 sorry sites, representation theorem | — |
| 109 | [NOT STARTED] | Close 23 BXCanonical sorries (5 critical-path + 18 irreflexive-consequence) | 93 |
| 112 | **[RESEARCHED]** | Systematic literature study for task 107 representation theorem | — |
| 82 | [NOT STARTED] | FMP Truth Preservation (weak completeness, independent) | — |
| 68 | [RESEARCHED] | Dense completeness via Q canonical model | — (independent) |
| 60 | [NOT STARTED] | Remove `discrete_Icc_finite_axiom` (may already be gone) | — |

---

*Last updated: 2026-04-24 (task 107: chronicle binary g rebuild -- added Chronicle path, binary g finding, density axiom finding, dead end #37, updated priority order and sorry inventory)*
