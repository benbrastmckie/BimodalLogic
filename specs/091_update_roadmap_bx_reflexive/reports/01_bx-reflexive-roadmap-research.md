---
task: 91
type: research
session: sess_1776000000_research91
date: 2026-04-10
status: complete
---

# Research Report: Task 91 — BX Reflexive-Semantics Roadmap Rewrite

**Task**: 91 — update ROAD_MAP.md to reflect BX reflexive-semantics architecture
**Started**: 2026-04-10
**Completed**: 2026-04-10
**Effort**: 2-4 hours (research only)
**Dependencies**: None
**Sources/Inputs**: Codebase (Theories/Bimodal/**), specs/ROAD_MAP.md, specs/TODO.md, Burgess 1982 / Xu 1988 literature
**Artifacts**: specs/091_update_roadmap_bx_reflexive/reports/01_bx-reflexive-roadmap-research.md
**Standards**: report-format.md, artifact-formats.md

## Executive Summary

- The current `specs/ROAD_MAP.md` is historically accurate as of task 81 (March-April 2026 strict-semantics migration) but does not match the code. The codebase has since been reverted/refactored to an **all-reflexive Burgess-Xu (BX)** axiom system, and the entire "UltrafilterChain / restricted coherence / SuccChainFMCS" architecture described in the roadmap is legacy code that is no longer on the active completeness path.
- The active path is `Metalogic.lean → Metalogic/BXCanonical/{BXCanonical,Frame,TruthLemma,Completeness}.lean`. `BXCanonical` does not import `UltrafilterChain.lean`, `SuccChainFMCS.lean`, or `FrameConditions/Completeness.lean`.
- `Axioms.lean` now contains the **BX** axiom set with 37 constructors including `temp_t_future`/`temp_t_past` (BX1/BX1') at lines 117-122. The T-axiom was NOT removed; it is required for reflexive `bx_le`.
- `Truth.lean:126-131` uses reflexive `≤`/`≥` for G, H, Until, and Since. Under this semantics the definitional abbreviations `next φ := ⊥ U φ` and `prev φ := ⊥ S φ` (Formula.lean:328-334) are effectively useless: reflexive Until with a ⊥-guard trivially requires the witness at `s = t`, collapsing X to `φ ∨ ⊥ = φ`.
- There are exactly **6 sorries** on the active path, all inside `Theories/Bimodal/Metalogic/BXCanonical/`: 4 Until/Since sorries in `Frame.lean` (lines 653, 675, 690, 704), 1 Box modal-equivalence sorry at `Frame.lean:440`, and 1 TaskModel embedding sorry at `Completeness.lean:154`. The Burgess-Xu Until-induction technique ([Burgess 1982](https://www.researchgate.net/publication/38355634_Axioms_for_tense_logic_I_Since''_and_until''), [Xu 1988](https://seop.illc.uva.nl/entries/logic-temporal/burgess-xu.html)) is the intended path for the 4 U/S sorries.

## Context & Scope

The task is to gather ground-truth facts that a downstream implementer will use to rewrite `specs/ROAD_MAP.md`. This report does NOT rewrite the roadmap; it inventories every claim the current roadmap makes that is inconsistent with the code, documents the actual BX architecture, enumerates the remaining sorries with file:line evidence, and identifies legacy code that should be archived under task 94.

## Current ROAD_MAP.md Discrepancies

Each row cites the false claim in `specs/ROAD_MAP.md` and the code evidence refuting it.

| # | Claim in ROAD_MAP.md | Line(s) | Reality | Evidence |
|---|----------------------|---------|---------|----------|
| 1 | "Task 81 migrated from reflexive to strict temporal semantics" | 172-173 | Code is fully reflexive (`≤`/`≥` on all four temporal operators) | `Theories/Bimodal/Semantics/Truth.lean:126-131` |
| 2 | "T-axiom removal: `temp_t_future` and `temp_t_past` axioms removed" | 174 | Both axioms are present as BX1/BX1' | `Theories/Bimodal/ProofSystem/Axioms.lean:115-122` |
| 3 | "X/Y-based Until/Since: Replaced reflexive Until/Since with X-based (next-step) variants" | 175 | Until/Since remain primitive reflexive formulas (`Formula.untl`, `Formula.snce`); X/Y are dead defs | `Theories/Bimodal/Syntax/Formula.lean:328-334`, `Theories/Bimodal/Semantics/Truth.lean:128-131` |
| 4 | "UltrafilterChain.lean — CRITICAL PATH" | 14 | `UltrafilterChain.lean` is not imported by `BXCanonical` or `Metalogic.lean`; it is legacy strict-semantics code | `Theories/Bimodal/Metalogic/Metalogic.lean:4`, `Theories/Bimodal/Metalogic/BXCanonical/*.lean` import graph |
| 5 | "Path B: Restricted Coherence — ACTIVE" | 49 | No "restricted coherence" infrastructure is on the active path; `BXCanonical` uses direct `g_content ⊆` ordering | `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:56-62` |
| 6 | "Only remaining sorries: `succ_chain_restricted_forward_F`/`backward_P` (UltrafilterChain.lean:3762, 3772)" | 66-67 | Active path has 6 sorries, all in `BXCanonical/` | `Frame.lean:440, 653, 675, 690, 704`; `Completeness.lean:154` |
| 7 | "SuccChainFMCS working infrastructure (sorry-free forward_G/backward_H)" | 161-164 | `SuccChainFMCS` is legacy; `BXCanonical` proves G/H forward/backward directly via `g_content` | `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` and `TruthLemma.lean` |
| 8 | "Task 83 is the active track for closing the gap" | 223-228 | Task 83 is superseded; current in-flight work is tasks 90, 92, 93, 94, 95 targeting BX | `specs/TODO.md:95-170` |
| 9 | "Completeness gap: forward_F/backward_P within deferralClosure" | 65-70 | Current gap is Until/Since eventuality resolution via BX5/BX6/BX7/BX10 | `Frame.lean:600-704` module docstring and sorry sites |
| 10 | "Constant-history CanonicalEmbedding rejected (task 88)" | 157 | Still accurate as an anti-pattern; should be preserved in rewrite | `Completeness.lean:143-148` references this anti-pattern |

## Current BX Axiom System

`Theories/Bimodal/ProofSystem/Axioms.lean` defines 37 axiom constructors in four layers. All axioms are sound on all linear temporal orders (frame class `Base`).

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
| BX7 `linear_until` | Axioms.lean:180 | four-formula linearity | Linearity of U witnesses |
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

BX8 (`ψ → (φUψ)`) and BX9 (`(φUψ) → (φ ∨ ψ)`) are **only sound under reflexive Until semantics** (witness `s = t` allowed). Under strict `<` semantics, BX8 would require `ψ` to force a strict future witness, which is false in general. This is the single clearest code-level proof that the current codebase is reflexive.

## Reflexive Truth Semantics

`Theories/Bimodal/Semantics/Truth.lean:120-131`:

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

- **G (all_future)** and **H (all_past)** use `≤` / `≤` — reflexive (include the current point).
- **U (untl)** uses `t ≤ s` for the witness and half-open guard `[t, s)` (`t ≤ r < s`).
- **S (snce)** uses `s ≤ t` for the witness and half-open guard `(s, t]` (`s < r ≤ t`).

The guard is half-open (strict on the witness side), which makes the `s = t` case vacuous for the guard and forces `ψ` at `t` — i.e. BX8 is sound.

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

**Why they are useless under the current reflexive semantics**:

Unfolding `Formula.next φ = Formula.untl Formula.bot φ` against `truth_at` Until clause (Truth.lean:128-129):

```
truth_at (⊥ U φ) at t  ↔  ∃ s, t ≤ s ∧ truth_at φ s ∧ ∀ r, t ≤ r < s → truth_at ⊥ r
                       ↔  ∃ s, t ≤ s ∧ truth_at φ s ∧ ∀ r, t ≤ r < s → False
                       ↔  ∃ s, t ≤ s ∧ truth_at φ s ∧ (∀ r, ¬(t ≤ r < s))
                       ↔  ∃ s, s = t ∧ truth_at φ s                [empty half-open interval]
                       ↔  truth_at φ t
```

So `next φ ≡ φ` semantically under reflexive Until with a half-open guard (the only s with empty guard is `s = t`). Symmetrically `prev φ ≡ φ`. The docstrings (which reference "discrete strict semantics") are stale — they describe a semantics that was never committed with these definitions, or was reverted. These defs should be marked deprecated or deleted.

## Active Metalogic Path

Module graph (verified by `import` statements):

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

`Metalogic.lean` also imports `Metalogic/Completeness.lean`, `Metalogic/Bundle/CanonicalConstruction.lean`, `Metalogic/Soundness.lean`, `Metalogic/Decidability.lean`. The legacy modules are still built for backward-compatibility aggregation, but the **active completeness theorem** flows through `BXCanonical`, not the Bundle/SuccChain code.

Crucially: `grep -r "import.*UltrafilterChain\|import.*FrameConditions\.Completeness" BXCanonical/` returns nothing. These files are **not** on the active path.

## Canonical Model Construction (BXCanonical)

### BXPoint (Frame.lean:46-53)

```lean
structure BXPoint where
  formulas : Set Formula
  is_mcs : SetMaximalConsistent formulas
```

A canonical frame point is an MCS of formulas.

### Canonical Temporal Ordering (Frame.lean:56-62)

```lean
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas
```

Equivalently: `w ≤ v ↔ ∀ φ, G(φ) ∈ w → φ ∈ v`.

- **Reflexivity** (`bx_le_refl`): requires `Gφ → φ` = BX1 `temp_t_future`. Without the T-axiom this fails.
- **Transitivity** (`bx_le_trans`): requires `Gφ → GGφ` = `temp_4`.

### Modal Equivalence (Frame.lean:65-68)

```lean
def bx_modal_equiv (w v : BXPoint) : Prop :=
  ∀ φ : Formula, Formula.box φ ∈ w.formulas ↔ Formula.box φ ∈ v.formulas
```

### Key Infrastructure Lemmas (Frame.lean:70+)

- `g_content_closed_derivation`: if `L ⊆ g_content(S)` and `L ⊢ φ`, then `Gφ ∈ S`. Uses `generalized_temporal_k`. (Frame.lean:79-94)
- `h_content_closed_derivation`: dual for H.
- `bx_forward_witness` / `bx_backward_witness`: Lindenbaum extension producing G/H witnesses.
- `bx_modal_witness`: constructs the modal-direction witness (contains the `sorry` at line 440).

### Truth Lemma (TruthLemma.lean:27-36 docstring)

The truth lemma is proved by formula induction. Cases `atom`, `bot`, `imp`, `box`, `G`, `H` are fully sorry-free. `U` and `S` delegate to the four `Frame.lean` helper lemmas (`bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward`).

### Completeness Theorem (Completeness.lean:124-154)

```lean
theorem bx_completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree [] φ)
```

Contrapositive proof: if not derivable, `{¬φ}` is consistent (proved sorry-free in `neg_consistent_of_not_derivable`), extended to MCS `M` via Lindenbaum. The remaining step — constructing a `TaskModel` from the BXPoint canonical frame and applying the truth lemma at `M` — is the `sorry` at line 154.

## Remaining Sorries (Active Path)

Total: **6 sorries**, all in `Theories/Bimodal/Metalogic/BXCanonical/`.

| # | File:Line | Definition | Goal Summary | Blocker | Strategy |
|---|-----------|------------|--------------|---------|----------|
| 1 | Frame.lean:440 | `bx_modal_witness` (Box direction of truth lemma) | Produce MCS `M` with `bx_modal_equiv w M` and `ψ ∈ M`, given `◇ψ ∈ w` (i.e., `¬□¬ψ ∈ w`) | Standard S5 argument needs modal-5 closure of `box_content` across the equivalence class | Task 93. Use `modal_5_collapse` + `modal_b` + Lindenbaum to show `box_content(w) = box_content(M)` |
| 2 | Frame.lean:653 | `bx_until_eventuality_resolution` | `φ U ψ ∈ w, ψ ∉ w  ⊢  ∃ v, bx_le w v ∧ ψ ∈ v ∧ (∀ u in [w,v), φ ∈ u)` | X-vs-G mismatch: `φUψ ∈ w` does not imply `G(φUψ) ∈ w`, so the eventuality does not propagate through the `g_content`-based `bx_le` ordering | Tasks 90+92. Burgess-Xu Until-induction via BX5+BX6+BX7+BX10, or Option A (redefine `bx_le` via Until witnesses) vs Option B (Henkin closure) |
| 3 | Frame.lean:675 | `bx_until_backward` | `bx_le w v, ψ ∈ v, guard φ on [w,v), ψ ∉ w  ⊢  φ U ψ ∈ w` | Same as #2 — needs linearity of `bx_le` on the interval | Tasks 90+92. Contrapositive: assume `¬(φUψ) ∈ w`, use BX4 to propagate `G(P(¬(φUψ)))`, derive contradiction |
| 4 | Frame.lean:690 | `bx_since_eventuality_resolution` | Mirror of #2 for S and `h_content` | Same as #2 | Mirror of #2 using BX5', BX9', BX10' |
| 5 | Frame.lean:704 | `bx_since_backward` | Mirror of #3 for S | Same as #3 | Mirror of #3 using BX8' + BX4' |
| 6 | Completeness.lean:154 | `bx_completeness` final step | Convert a BXPoint canonical frame into a `TaskModel F` over some `D` with `¬φ` false at `w₀` | Embedding a discrete canonical frame into `TaskFrame D` requires choosing `D = Int` (or a linearization) and defining histories that visit each BXPoint | Task 93. Standard canonical-model-to-Kripke-model construction; key difficulty is handling both the temporal dimension (linear) and the modal dimension (S5 equivalence classes) simultaneously. Cannot use constant histories (rejected in task 88 — see Completeness.lean:143-148) |

The `bx_until_*` and `bx_since_*` sorries at lines 653/675/690/704 are all commented with detailed analysis of why `bx_le` linearity is needed and why approaches (A) via BX7 bridging and (B) via Henkin closure are the two viable paths forward. See Frame.lean:596-622 for the module-level analysis.

## Legacy Code Inventory

The following files were written under a strict-semantics architecture and are **not imported by the active `BXCanonical` completeness path**. Task 94 will archive them to `Boneyard/StrictSemanticsLegacy/`.

| File | Approx sorries | Architecture | Imported by BXCanonical? |
|------|---------------|--------------|---------------------------|
| `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` | ~67 | strict G/H + SuccChain F/P witnesses | No |
| `Theories/Bimodal/FrameConditions/Completeness.lean` | ~54 | Original full-coherence completeness | No |
| `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` | ~29 | Dovetailed Z-chain construction | No |
| `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` | ~61 | SuccChain FMCS + restricted coherence | No |

Additional legacy code (still imported by `Metalogic.lean` at top-level for aggregation but not required for BX completeness):
- `Theories/Bimodal/Metalogic/Completeness.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

Verification: `grep -r "import.*\(UltrafilterChain\|SuccChainFMCS\|FrameConditions\.Completeness\)" Theories/Bimodal/Metalogic/BXCanonical/` returns nothing.

## Burgess-Xu Until-Induction Technique

### Historical Context

The BX system is named after John P. Burgess and Ming Xu. The active references are:

- **Burgess, J. P. (1982)**. "Axioms for tense logic. I. 'Since' and 'until'." *Notre Dame Journal of Formal Logic* 23(4), 367-374. [ResearchGate link](https://www.researchgate.net/publication/38355634_Axioms_for_tense_logic_I_Since''_and_until'').
- **Xu, M. (1988)**. "On some U, S-tense logics." *Journal of Philosophical Logic* 17, 181-202. Simplifies Burgess's axiomatization.

See also the [Stanford Encyclopedia of Philosophy: Burgess-Xu Axiomatic System for Since and Until](https://seop.illc.uva.nl/entries/logic-temporal/burgess-xu.html) supplementary entry and the main [Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/) article.

### Key Result

Burgess (1982), simplified by Xu (1988), gives a complete axiomatization of the Since-Until tense logic over **all reflexive linear orderings**. The BX axioms BX1-BX12 in `Axioms.lean` are modeled on this axiomatization (the comments in `Axioms.lean:46-49` cite Burgess 1982/84, Xu 1988, and Venema 1993).

### Until-Induction Technique (as applied to Frame.lean sorries)

The proof of the Until case of the truth lemma in the Burgess-Xu canonical model construction proceeds by **induction on the Until-structure** of formulas, using the following axioms:

1. **BX10 (`until_F`)**: `(φUψ) → Fψ` extracts an F-witness, giving some `v ≥ w` with `ψ ∈ v`.
2. **BX7 (`linear_until`)**: Linearity of Until witnesses — given two Until formulas holding simultaneously, their witnesses are comparable. This provides the linear-order structure on witnesses needed to choose a minimal / first witness.
3. **BX11 (`temp_linearity`)**: F-witness linearity — F(φ) ∧ F(ψ) → three-way disjunction, giving comparability of F-witnesses.
4. **BX5 (`self_accum_until`)**: `(φUψ) → ((φ ∧ (φUψ))Uψ)` — the eventuality enriches its own guard, so at every intermediate point `u ∈ [w, v)`, both `φ` and `φUψ` hold. This is the key axiom for guard propagation.
5. **BX6 (`absorb_until`)**: `(φU(φ ∧ (φUψ))) → (φUψ)` — prevents the self-accumulation from producing nested deferrals; the two-step resolution collapses.
6. **BX9 (`until_elim`)**: `(φUψ) → (φ ∨ ψ)` handles the `s = t` (current-time) case under reflexive semantics.
7. **BX4 (`connect_future`)**: `φ → G(P(φ))` is used in the backward direction to propagate `¬(φUψ)` forward and derive a contradiction with the guard.
8. **BX1 (`temp_t_future`)**: `Gφ → φ` provides reflexivity of `bx_le` and is used at the final witness to extract the current-time satisfaction of `ψ`.

In Burgess's original construction, the canonical frame is enriched by **Henkin witnesses** for each Until/Since formula in each MCS — i.e., explicitly adding MCS points that witness the eventualities. This is "Option B" in task 90's research framing.

The alternative "Option A" explored by task 90 is to **redefine `bx_le`** from `g_content ⊆` to an Until-witness-based ordering and prove the two definitions equivalent using BX10 + BX12 + BX4 + BX1. This avoids Henkin closure but requires a more intricate `bx_le_refl`/`bx_le_trans` proof.

## Relationship to Tasks 90, 92, 93, 94, 95

Task 91 (this task) is the **roadmap-accuracy prerequisite** for the entire BX completion track. The downstream tasks are:

- **Task 90** [NOT STARTED]: Research Option A (redefine `bx_le`) vs Option B (Henkin closure) for closing the 4 `bx_until_*` / `bx_since_*` sorries. Depends on task 91 for an accurate baseline.
- **Task 92** [NOT STARTED]: Implement the chosen approach in `BXCanonical/Frame.lean`. Depends on task 90's decision.
- **Task 93** [NOT STARTED]: Close the remaining two sorries — Box direction at Frame.lean:440 and TaskModel embedding at Completeness.lean:154. Depends on task 92.
- **Task 94** [NOT STARTED]: Archive strict-semantics legacy code (`UltrafilterChain.lean`, `FrameConditions/Completeness.lean`, `DovetailedChain.lean`, `SuccChainFMCS.lean`) to `Boneyard/StrictSemanticsLegacy/`. Depends on task 91 so the Boneyard README can cite the new authoritative roadmap. Mechanically drops ~210 sorries.
- **Task 95** [NOT STARTED]: `#print axioms` audit on `BXCanonical.bx_completeness` and `discrete_completeness_fc`; expected output is exactly `{propext, Classical.choice, Quot.sound}`. Depends on task 93.

The roadmap rewrite must NOT describe tasks 90/92/93/94/95 as the "new plan" — those are downstream in-flight tasks that will update the roadmap themselves as they close. Instead, the rewrite should describe the **architecture** (BX, reflexive, BXCanonical path) and the **current gap** (6 sorries in BXCanonical), and reference tasks 90-95 only as the active work items closing the gap.

## Recommendations for Implementer

1. **Replace the "Overview" sorry-count table** with a table counting sorries in the active path (6 in `BXCanonical`) vs legacy path (~210 in legacy files to be archived in task 94). Avoid repeating the bloated total of ~220 without this distinction.
2. **Delete the "Path A vs Path B / restricted coherence" section entirely.** It describes a completeness architecture that no longer exists in the code.
3. **Add a "BX Axiom System" section** summarizing the 37 axioms grouped by layer (4 propositional, 5 S5, 26 BX temporal, 2 interaction), citing `ProofSystem/Axioms.lean`. Highlight that BX1/BX1' (`temp_t_future`/`temp_t_past`) are present and necessary.
4. **Add a "Reflexive Semantics" section** quoting `Semantics/Truth.lean:120-131` verbatim to make the reflexive `≤`/`≥` unambiguous.
5. **Add an "Active Completeness Path: BXCanonical" section** with the module graph `Metalogic → BXCanonical/{BXCanonical,Frame,TruthLemma,Completeness}`.
6. **Replace the "Closing the Gap (Task 83)" section** with a "Closing the Gap (Tasks 90-95)" section, describing: 6 sorries in BXCanonical, the Until-induction technique, Option A vs Option B framing, and the task chain.
7. **Add a "Legacy Code (To Be Archived)" section** listing the 4 files slated for Boneyard archival in task 94, with the rationale that they were written under strict semantics and are architecturally incompatible with the current reflexive BX system.
8. **Preserve the "Dead Ends (Archived)" section** — items 1-12 remain valid anti-patterns regardless of the semantic change, especially item 12 (constant-history CanonicalEmbedding), which is still referenced by `BXCanonical/Completeness.lean:143-148`.
9. **Update the "X/Y Operator Status"** note: `Formula.next`/`Formula.prev` exist as definitional abbreviations at `Formula.lean:328-334` but are semantically equivalent to their arguments under reflexive U/S, so they are effectively dead code. The docstrings reference "discrete strict semantics" which is stale.
10. **Preserve the "Dense Completeness" and "Decidability/FMP" sections** — these are independent tracks not affected by the BX migration.
11. **Update "Recommended Priority Order"**: (1) Task 91 [self], (2) Task 94 (archive legacy — immediate sorry-count win), (3) Task 90 (research Option A vs B), (4) Task 92 (implement U/S), (5) Task 93 (close Box + TaskModel), (6) Task 95 (audit).

## Decisions

- **Report scope**: This report covers only the factual inventory needed for the rewrite. It intentionally does NOT prescribe the exact text of the rewritten ROAD_MAP.md — that is the implementation task.
- **Web search depth**: One search was sufficient to confirm the Burgess/Xu citations already present in the code comments. No deeper literature review is needed because the axiom set is already implemented; the research question is about strategy, not the axiomatization.

## Risks & Mitigations

- **Risk**: The rewriter may copy stale claims from the old roadmap. **Mitigation**: The "Discrepancies" table above enumerates every such claim with line numbers.
- **Risk**: The rewriter may conflate the BX axiom system with the canonical-model strategy. **Mitigation**: The "BX Axiom System" and "Canonical Model Construction" sections are kept separate.
- **Risk**: Future readers may not understand why X/Y are "useless". **Mitigation**: The explicit unfolding calculation in "X/Y Operator Status" is included.
- **Risk**: Tasks 90-95 may evolve before the roadmap rewrite lands. **Mitigation**: The rewrite should describe current status as of 2026-04-10 and leave the task chain as the source of truth for ongoing work.

## Context Extension Recommendations

This is a meta task; Context Extension Recommendations: none.

## Appendix

### Search Queries

- WebSearch: "Burgess 1982 Xu 1988 Until Since completeness linear temporal logic induction"
- Grep: `def\s+X\b|def\s+Y\b|untl.*bot|bot.*untl` on `Theories/Bimodal/`
- Grep: `sorry` on `Theories/Bimodal/Metalogic/BXCanonical/`
- Grep: `import.*UltrafilterChain|import.*SuccChainFMCS|import.*FrameConditions\.Completeness` on BXCanonical

### Key Files (Absolute Paths)

- `/home/benjamin/Projects/ProofChecker/specs/ROAD_MAP.md`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Formula.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Metalogic.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`

### External References

- [Burgess (1982) "Axioms for tense logic. I. 'Since' and 'until'"](https://www.researchgate.net/publication/38355634_Axioms_for_tense_logic_I_Since''_and_until'') — Notre Dame Journal of Formal Logic 23(4), 367-374.
- [Stanford Encyclopedia: Burgess-Xu Axiomatic System](https://seop.illc.uva.nl/entries/logic-temporal/burgess-xu.html) — supplementary entry to the Temporal Logic article.
- [Stanford Encyclopedia: Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/) — main reference.
- Xu (1988). "On some U, S-tense logics." Journal of Philosophical Logic 17, 181-202.
- Venema (1993). Temporal logic survey (cited in `Axioms.lean:48`).
