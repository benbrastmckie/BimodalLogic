# Roadmap: BX Completeness and Publication

## Overview

TM is a bimodal logic combining S5 modality with reflexive linear temporal logic,
axiomatized via the **Burgess-Xu (BX) system**. This roadmap describes the current
state of the completeness effort as of 2026-04-10.

**Architecture**: The proof system has 37 BX axioms (propositional, S5 modal,
Burgess-Xu temporal, and modal-temporal interaction). The temporal semantics is
**fully reflexive**: G/H quantify over `t ≤ s` / `s ≤ t`, and Until/Since admit
the current point `s = t` as a witness under a half-open guard. The active
completeness path flows through `Theories/Bimodal/Metalogic/BXCanonical/`,
which constructs a canonical frame of maximally consistent sets ordered by
`g_content` inclusion.

**Active-path sorry summary** (the only sorries blocking `bx_completeness`):

> **⚠ STALE (2026-04-12 review)**: This table was accurate at task 91 (2026-04-10).
> Since then, tasks 90+92+98+102 closed all Frame.lean sorries.
> **Actual state**: 1 sorry remains (Completeness.lean:154). See task 103 for full rewrite.

| Category | Count | Location | Status (2026-04-12) |
|----------|-------|----------|---------------------|
| Until/Since eventuality + backward | ~~4~~ 0 | `Frame.lean:653, 675, 690, 704` | **CLOSED** (tasks 98+102) |
| Box modal-equivalence witness | ~~1~~ 0 | `Frame.lean:440` | **CLOSED** (task 102) |
| TaskModel embedding (final step) | 1 | `Completeness.lean:154` | **OPEN** (task 93) |
| **Active-path total** | **1** | `BXCanonical/Completeness.lean:154` | |
| Legacy strict-semantics files | ~210 | various (to be archived by task 94) | Pending archival |

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
Metalogic.lean (aggregator; see Theories/Bimodal/Metalogic/Metalogic.lean:4)
  └── Metalogic/BXCanonical/BXCanonical.lean
        ├── Metalogic/BXCanonical/Frame.lean
        │     ├── Metalogic/Core/MaximalConsistent
        │     ├── Metalogic/Core/MCSProperties
        │     ├── Metalogic/Bundle/TemporalContent
        │     ├── Metalogic/Bundle/WitnessSeed
        │     ├── Metalogic/Bundle/CanonicalFrame
        │     └── Theorems/GeneralizedNecessitation
        ├── Metalogic/BXCanonical/TruthLemma.lean
        │     ├── Metalogic/BXCanonical/Frame
        │     ├── Semantics/Truth
        │     └── Semantics/Validity
        └── Metalogic/BXCanonical/Completeness.lean
              ├── Metalogic/BXCanonical/TruthLemma
              └── Semantics/Validity
```

**Verification**:
```
grep -r "import.*\(UltrafilterChain\|SuccChainFMCS\|FrameConditions\.Completeness\)" \
  Theories/Bimodal/Metalogic/BXCanonical/
```
returns nothing. These legacy files are not on the active path.

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
- `bx_modal_witness` (Frame.lean ~423+): constructs the modal-direction witness.
  Contains the `sorry` at line 440 (see Sorry Inventory below).

### Truth Lemma (TruthLemma.lean:27-36)

Proved by formula induction. Cases `atom`, `bot`, `imp`, `box`, `G`, `H` are
sorry-free. The `U` and `S` cases delegate to the four `Frame.lean` helper
lemmas (`bx_until_eventuality_resolution`, `bx_until_backward`,
`bx_since_eventuality_resolution`, `bx_since_backward`).

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

## Active-Path Sorry Inventory

There are exactly **6 sorries** on the active completeness path, all inside
`Theories/Bimodal/Metalogic/BXCanonical/`. They fall into three groups:
Until/Since eventuality resolution (4), Box modal-witness (1), and TaskModel
embedding (1).

| # | File:Line | Definition | Goal Summary | Blocker | Strategy / Owning Task |
|---|-----------|------------|--------------|---------|------------------------|
| 1 | Frame.lean:440 | `bx_modal_witness` (Box direction of truth lemma) | Produce MCS `M` with `bx_modal_equiv w M` and `ψ ∈ M`, given `◇ψ ∈ w` | S5 argument needs modal-5 closure of `box_content` across the equivalence class | **Task 93**. Use `modal_5_collapse` + `modal_b` + Lindenbaum to show `box_content(w) = box_content(M)` |
| 2 | Frame.lean:653 | `bx_until_eventuality_resolution` | `φUψ ∈ w, ψ ∉ w  ⊢  ∃ v, bx_le w v ∧ ψ ∈ v ∧ (∀ u ∈ [w,v), φ ∈ u)` | X-vs-G mismatch: `φUψ ∈ w` does not imply `G(φUψ) ∈ w`, so the eventuality does not propagate through the `g_content`-based `bx_le` ordering | **Tasks 90+92**. Burgess-Xu Until-induction via BX5+BX6+BX7+BX10 (Option A), or Henkin witness closure (Option B) |
| 3 | Frame.lean:675 | `bx_until_backward` | `bx_le w v, ψ ∈ v, guard φ on [w,v), ψ ∉ w  ⊢  φUψ ∈ w` | Needs linearity of `bx_le` on the interval | **Tasks 90+92**. Contrapositive: assume `¬(φUψ) ∈ w`, use BX4 to propagate `G(P(¬(φUψ)))`, derive contradiction |
| 4 | Frame.lean:690 | `bx_since_eventuality_resolution` | Mirror of #2 for S and `h_content` | Same as #2 | **Tasks 90+92**. Mirror using BX5', BX9', BX10' |
| 5 | Frame.lean:704 | `bx_since_backward` | Mirror of #3 for S | Same as #3 | **Tasks 90+92**. Mirror using BX8' + BX4' |
| 6 | Completeness.lean:154 | `bx_completeness` final step | Convert a BXPoint canonical frame into a `TaskModel F` over some `D` with `¬φ` false at `w₀` | Embedding a discrete canonical frame into `TaskFrame D` requires choosing `D` (e.g. `Int`) and defining non-constant histories. Constant histories rejected (task 88) | **Task 93**. Standard canonical-model-to-Kripke-model construction handling both the temporal dimension (linear) and the modal dimension (S5 equivalence classes) simultaneously |

### Current Gap Summary

`Frame.lean:590-622` contains a module-level analysis of why the four
Until/Since sorries are hard:

- (A) An Until-induction axiom was removed in an earlier refactoring. Not
  currently available as a direct axiom, but the BX axiom set is sufficient
  to derive the needed induction via BX5+BX6+BX7+BX10.
- (B) Global `bx_le` linearity is FALSE. BX7 constrains Until-witness
  ordering, not `g_content` inclusion.
- (C) A chain-specific construction is blocked by the X-vs-G mismatch:
  `φ U ψ ∈ w` does not imply `G(φ U ψ) ∈ w`, so the formula does not
  propagate forward through `g_content`.

The Burgess-Xu Until-induction technique (next section) is the intended
path forward: it closes the gap through proof-theoretic manipulation of the
BX axioms rather than through a chain construction.

---

## Legacy Code Inventory

The following files were written under a strict-semantics architecture that
has since been reverted to the all-reflexive BX system. They are **not
imported by `BXCanonical`** and are not on the active completeness path.
**Task 94** will archive them to `Boneyard/StrictSemanticsLegacy/`. Archiving
these files mechanically drops approximately **210 sorries** from the
codebase total.

| File | Approx sorries | Architecture | Imported by BXCanonical? |
|------|---------------|--------------|---------------------------|
| `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` | ~67 | strict G/H + SuccChain F/P witnesses | No |
| `Theories/Bimodal/FrameConditions/Completeness.lean` | ~54 | Original full-coherence completeness | No |
| `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` | ~29 | Dovetailed Z-chain construction | No |
| `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` | ~61 | SuccChain FMCS + restricted coherence | No |

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

### Option A vs Option B (Task 90's research framing)

Two strategies are open for closing the 4 `bx_until_*` / `bx_since_*` sorries:

- **Option A: Redefine `bx_le`**. Change `bx_le` from `g_content ⊆` to an
  Until-witness-based ordering, then prove the two definitions equivalent
  using BX10 + BX12 + BX4 + BX1. Avoids Henkin closure but requires more
  intricate reflexivity/transitivity proofs for the new ordering.
- **Option B: Henkin witness closure**. Explicitly enrich the canonical frame
  with witness MCS points for each Until/Since formula — the classical
  Burgess construction. Standard but adds machinery to the BXPoint type.

Task 90 is the research task that will choose between Option A and Option B;
task 92 will implement the chosen approach. See `Frame.lean:590-622` for the
in-code analysis these tasks will build on.

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

---

## Other Open Items

### Dense Completeness (task 68, 1 sorry)

- `dense_completeness_fc` needs a separate proof using a dense canonical model
  (e.g., over `ℚ`).
- Cannot reduce to `completeness_over_Int` since `Int` is not densely ordered.
- Independent of the BX canonical construction.

### FMP Truth Preservation (task 82, 2 sorries)

- `mcs_all_future_closure` and `mcs_all_past_closure` in
  `TruthPreservation.lean`.
- Filtration-based truth preservation for the finite model property.
- **Decidability track only** — not a path to the completeness representation
  theorem.
- Independent of BXCanonical.

### Soundness Extensions (1 sorry in Soundness.lean)

- `density`: requires `DenselyOrdered D`.
- Frame-condition-dependent; architecture is sound.

### Examples / Pedagogical (~14 sorries)

- `Demo.lean`, `ModalProofs.lean`, `ModalProofStrategies.lean`,
  `TemporalProofs.lean`.
- Expected and intentional (exercises, demonstrations).

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

1. **Task 91** [this task]: Rewrite `specs/ROAD_MAP.md` to reflect the BX
   reflexive-semantics architecture.
2. **Task 94**: Archive legacy strict-semantics code
   (`UltrafilterChain.lean`, `FrameConditions/Completeness.lean`,
   `DovetailedChain.lean`, `SuccChainFMCS.lean`) to
   `Boneyard/StrictSemanticsLegacy/`. Immediate ~210 sorry drop.
3. **Task 90**: Research Option A (redefine `bx_le` via Until witnesses) vs
   Option B (Henkin closure) for the 4 Until/Since sorries.
4. **Task 92**: Implement the chosen approach in `BXCanonical/Frame.lean`.
   Closes the 4 Until/Since sorries (Frame.lean:653, 675, 690, 704).
5. **Task 93**: Close the Box direction (`Frame.lean:440`) via the S5
   argument, and the final TaskModel embedding
   (`Completeness.lean:154`) using non-constant histories.
6. **Task 95**: `#print axioms` audit on `BXCanonical.bx_completeness` and
   `discrete_completeness_fc`; expected output is exactly
   `{propext, Classical.choice, Quot.sound}`.
7. **Task 68**: Dense completeness via `ℚ` canonical model (independent track).
8. **Task 82**: FMP Truth Preservation (independent, decidability track).
9. **Task 60**: Remove `discrete_Icc_finite_axiom` custom axiom (independent).

---

## Task Cross-Reference

> **Updated 2026-04-12 (review task 103 pending full rewrite)**

| Task | Status | Description | Depends On |
|------|--------|-------------|------------|
| 91 | **[COMPLETED]** | Rewrite ROAD_MAP.md for BX reflexive semantics | — |
| 90 | **[COMPLETED]** | Research Option A vs Option B for Until/Since closure | — |
| 92 | **[COMPLETED]** | Implement Until/Since truth lemma approach | 90 |
| 98 | **[COMPLETED]** | Implement eventuality resolution (Frame.lean:653, 690) | 92 |
| 102 | **[COMPLETED]** | Close remaining Frame.lean sorries (675, 704, 440) | 98 |
| 93 | [NOT STARTED] | Close Completeness.lean:154 (TaskModel embedding) — **sole remaining sorry** | 102 |
| 95 | [NOT STARTED] | `#print axioms` audit on `bx_completeness` | 93 |
| 103 | [NOT STARTED] | Comprehensive ROAD_MAP.md rewrite for post-Until/Since state | — |
| 94 | [NOT STARTED] | Archive strict-semantics legacy files to Boneyard | 103 |
| 104 | [NOT STARTED] | Clean up superseded tasks + fix state.json | — |
| 105 | [NOT STARTED] | Update stale sorry-blocker comments in BXCanonical | — |
| 82 | [NOT STARTED] | FMP Truth Preservation (weak completeness, independent) | — |
| 68 | [RESEARCHED] | Dense completeness via ℚ canonical model | — (independent) |
| 60 | [NOT STARTED] | Remove `discrete_Icc_finite_axiom` (may already be gone) | — |

---

*Last updated: 2026-04-12 (review)*
