# Teammate C (Critic) Findings: Task 93 Round 47

**Role**: Critic — critical analysis of proposed approaches, attempt ordering, and rollback strategy
**Date**: 2026-04-19
**Session**: sess_1776700000_c47critic

---

## Key Findings

### Finding 1: The "IRR Rule" Proposal Contains a Critical Category Error

The round 46 synthesis recommends adding the IRR rule to the base `DerivationTree`.
However, the codebase already has a bifurcated proof system:

- **Base system** (`Derivation.lean`): `DerivationTree` — 7 rules, NO IRR
- **Extended system** (`ConservativeExtension/ExtDerivation.lean`): `ExtDerivationTree` — includes density, discreteness_forward, seriality, etc., but also NO IRR rule currently

The IRR rule in the GHR literature is an **admissible rule** that says:
> If `⊢ phi[p/bot] -> phi[p/top]` for fresh propositional variable `p`, then `⊢ phi`

This rule is ALREADY used in the conservative extension infrastructure (see `Lifting.lean`
comments about `freshAtom` and `Sum.inr ()`). The `ConservativeExtension/` directory was
BUILT for exactly this purpose: to formalize conservative extension arguments using fresh atoms.

**Critical question**: What exactly does the round 47 proposal mean by "IRR rule"?
- Option A: Add a new constructor to `DerivationTree` (extends the proof system — NOT admissible)
- Option B: Use the existing conservative extension infrastructure to discharge the pending sorries
- Option C: Use IRR as a META-ARGUMENT to show the sorries follow from the existing proof system

Only Option B/C preserves admissibility. Option A would require re-proving soundness for
the extended system. The round 46 synthesis conflates "admissible rule" with "extend the proof
system." These are categorically different.

**Current state of ConservativeExtension**: `ExtDerivation.lean` mentions IRR in comments
but the `ExtDerivationTree` inductive does NOT have an IRR constructor. The `Lifting.lean`
handles the `freshAtom` case by observing `embedFormula phi = phi` when `freshAtom ∉ phi.atoms`.
This is conservative extension infrastructure but is NOT connected to the sorry sites.

### Finding 2: BX1 Reflexivity Is Deeply Embedded — Semantic Switch Has High Blast Radius

Searching for uses of `temp_t_future`/`temp_t_past` (BX1/BX1') across the codebase:

- **93 occurrences** in Metalogic/ alone
- Reflexivity (`bx_le_refl`) is the FIRST proven theorem in `Frame.lean` (line 140)
- The `g_content(w) ⊆ w.formulas` property (used everywhere) REQUIRES BX1
- `sigma_le_refl` in `Filtration/SigmaOrdering.lean` requires BX1
- `Realization.lean` (sorry-free Quasimodel infrastructure) uses BX1 at 8 points

If we switch to irreflexive semantics, BX1 (`G(phi) -> phi`) is REMOVED from the axiom set.
This immediately breaks:
1. `bx_le_refl` — the canonical temporal relation is no longer reflexive
2. `g_content_subset` — G-content is no longer a subset of the MCS itself
3. `Filtration/SigmaOrdering.lean` — sigma_le_refl fails
4. `Quasimodel/Realization.lean` — 8 sorry-free theorems break
5. `Soundness.lean` — `temp_t_future_valid` and `temp_t_past_valid` need to be removed
6. `Theorems/TemporalDerived.lean` — `G_bot_absurd`, `density_derivable` fail
7. `Bundle/SuccRelation.lean` — `g_content_subset` and `h_content_subset` fail
8. **All proofs using BX8/BX8' (reflexive Until/Since intro)** — these require `psi -> phi U psi`
   which is valid on reflexive (≤) but NOT on strict (<) semantics

**Estimated blast radius**: 150-200+ sorry sites or compilation failures across the codebase.
Irreflexive semantics is NOT a "drop-in" change.

### Finding 3: The Proposed Attempt Order Has a Hidden Risk Inversion

Round 46 recommends: IRR rule → quasimodel concatenation → Goldblatt restructure

This ordering optimizes for "lowest cost first." But it fails to account for **rollback risk**:

- **IRR rule attempt**: If we add a constructor to `DerivationTree`, all proofs by cases/induction on derivation trees need updating. Rollback requires reverting a structural change to a core type. This is HIGH rollback complexity.
- **Quasimodel concatenation**: This is purely ADDITIVE — building on sorry-free infrastructure already in `Construction.lean`. Rollback is trivial: just don't wire the new chain into `dd_bfmcs`.
- **Goldblatt restructure**: Requires rewriting the canonical model architecture. High rollback complexity.

**Corrected ordering by (success probability × rollback ease)**:
1. Quasimodel concatenation (medium probability, EASY rollback — purely additive)
2. IRR rule as meta-argument only (no codebase change needed to attempt)
3. IRR rule adding constructor to DerivationTree (higher cost, harder rollback)
4. Goldblatt restructure (lowest probability per unit effort, hardest rollback)

### Finding 4: Five Sorry Sites Have THREE Distinct Root Causes, Not Two

The round 46 synthesis identifies two blockers: "F/P eventuality" and "Until step transfer."
More precisely, the 5 sorry sites in `RootScopedChain.lean` break into three categories:

**Category A: F-eventuality resolution (1 site)**
- `fwd_chain_forward_F` (line 1111): `F(psi) in chain(n) → ∃ m > n, psi in chain(m)`
- Root cause: BX11 fold in `resolving_enriched_fwd_exists` cannot guarantee direct resolution

**Category B: Backward temporal coherence (2 sites)**
- `dd_bfmcs_restricted_tc` backward direction (line 1138): `F(phi) in backward chain → witness`
- `dd_bfmcs_restricted_tc` P-direction (line 1145): `P(phi) in chain → past witness`
- Root cause: No `preserving_bwd_step` exists; backward chain uses bare `bwd_pred`

**Category C: Until/Since step transfer (2 sites)**
- `dd_bfmcs_restricted_buc` (line 1153): backward Until/Since coherence
- `dd_bfmcs_restricted_fuc` (line 1160): forward Until/Since coherence
- Root cause: BX1-BX12 lack `phi AND F(phi U psi) → phi U psi`; no step-backward transfer

The IRR rule (if applicable) addresses Category A and potentially C, but NOT Category B
(backward chain has no symmetric infrastructure regardless of IRR).

The quasimodel concatenation approach addresses Categories A and C simultaneously (quasimodel
has proven defect discharge). It does NOT directly address Category B either, unless the
backward chain is also rebuilt using quasimodel infrastructure.

### Finding 5: The "Irreflexive Semantics" Switch Is Preferred by User — Critical Constraint

The user states: "switching to irreflexive semantics is even preferred as it is more expressive."

**Is this claim correct?** Under irreflexive (strict `<`) semantics:
- `G(phi) = ∀ s > t, phi(s)` (strictly future)
- `H(phi) = ∀ s < t, phi(s)` (strictly past)
- `phi U psi` has witness `s > t` with `psi(s)` and `phi(r)` for all `t < r < s`

Under reflexive (`≤`) semantics:
- `G(phi) = ∀ s ≥ t, phi(s)` (includes present)
- `phi U psi` has witness `s ≥ t` with `psi(s)` and `phi(r)` for all `t ≤ r < s`

**Expressiveness claim**: Irreflexive semantics distinguishes `G(phi)` from `phi ∧ G(phi)`.
In reflexive semantics, `G(phi) → phi` (BX1), so these are equivalent. In irreflexive
semantics, they are genuinely different. This IS a real expressiveness gain.

**However**: "More expressive" means the SEMANTICS validates fewer formulas (fewer tautologies).
The reflexive logic (with BX1) is an EXTENSION of the irreflexive logic. Switching to
irreflexive semantics means the completeness proof proves a WEAKER system — one where BX1
is an optional extra axiom, not built in.

**Net assessment**: The user's preference is mathematically sound, but the implementation
cost of switching semantics is HIGH (see Finding 2). The question is: does the switch
resolve the sorry sites? Partially yes — without BX1, the "defect count never decreases"
obstruction changes character because `phi_imp_F_phi` (derived from BX1 via `G(phi) → phi`
instantiated at `phi` itself) no longer applies. F-defects can genuinely resolve under
irreflexive semantics.

---

## Recommended Approach

### The Correct First Attempt: Quasimodel Concatenation (NOT IRR Rule)

**Why not IRR first**: The IRR rule is a meta-rule for COMPLETENESS proofs. Using it requires
either (a) modifying `DerivationTree` (high rollback risk) or (b) using conservative extension
machinery (already exists, not connected to sorry sites). Neither approach has a clear path
to closing the 5 sorry sites. The round 46 discussion of IRR is mathematically reasonable
but implementation-underspecified.

**Why quasimodel concatenation first**:
1. Infrastructure is 100% sorry-free (887 lines in Construction.lean)
2. Purely additive — no existing proofs break
3. Rollback is trivial (just revert the new chain wiring in `dd_bfmcs`)
4. Addresses the root mathematical problem directly (Until-defect discharge)
5. The periodic extension to Int has been identified as feasible (finite state space)

**Concrete steps**:
1. Define `qm_int_chain`: an Int-indexed chain built by sigma-signature cycling from quasimodel
2. Prove restricted_tc for qm_int_chain (using sorry-free quasimodel discharge)
3. Prove restricted_buc/fuc for qm_int_chain (using hintikka_step properties)
4. Wire qm_int_chain into `dd_bfmcs` replacing `fwd_chain_of_sigma`/`bwd_chain_of_sigma`

**Rollback plan**: If step 1-3 cannot be completed, revert by NOT modifying `dd_bfmcs`.
The quasimodel infrastructure remains available for other uses.

### Second Attempt: Irreflexive Semantics Switch (If User Explicitly Authorizes Scope)

The semantic switch SHOULD resolve the F-eventuality obstruction (since without BX1,
defects genuinely decrease). However:
- Requires updating the axiom system (remove `temp_t_future`, `temp_t_past`)
- Requires updating all soundness proofs
- Requires updating the canonical frame construction
- Requires updating `g_content_subset` (fundamental lemma)
- **Estimated scope**: 400-600 lines changed, plus ~100 new compilation errors to fix

This should be done on a SEPARATE BRANCH with comprehensive testing before merge.

**Git branch strategy**: `feat/irreflexive-semantics` from current `until` branch.
The rollback is simply not merging this branch.

### Third Attempt: Goldblatt Full Canonical Frame

Only if both above fail. Requires 800-1500 LOC rewrite of the canonical model architecture.

---

## Evidence/Examples

### Evidence for Finding 1 (ConservativeExtension exists but not connected):

From `ConservativeExtension/ExtDerivation.lean` lines 82-84:
```
Includes all inference rules from the base system plus the IRR rule
with `ExtAtom` (allowing `Sum.inr ()` as the fresh atom).
```
But the actual `ExtDerivationTree` inductive (lines 85-101) has NO IRR constructor.
The comment is aspirational, not actual. The conservative extension machinery for IRR
has NOT been implemented.

### Evidence for Finding 2 (BX1 blast radius):

- `bx_le_refl` (Frame.lean:140): First theorem, fundamental to all ordering proofs
- `g_content_subset` pattern appears in ~30 sorry-free theorems in Frame.lean
- `Quasimodel/Realization.lean` at lines 51, 65, 202, 210, 255, 265: 8 sorry-free uses of BX1
- `sigma_le_refl` (SigmaOrdering.lean:77): Filtration ordering requires reflexivity

### Evidence for Finding 3 (rollback risk comparison):

- Quasimodel approach: adds new definitions and theorems only; `dd_bfmcs` still compiles
  if new chain fails to satisfy all coherence properties (just don't connect them)
- IRR constructor approach: `DerivationTree` has 7-case pattern matches throughout the codebase;
  adding an 8th constructor breaks ALL pattern matches (dozens of files)
- Search: `grep -rn "DerivationTree" Theories/ --include="*.lean"` shows 40+ files use it

### Evidence for Finding 4 (three distinct root causes):

From `RootScopedChain.lean` comments:
- Line 1099-1110: Category A — "The resolved w satisfies w ∈ chain(n+1). If w = φ, take m = n+1."
- Line 1134-1138: Category B — "The backward chain doesn't have F-preservation"
- Line 1151-1153: Category C — "blocked for Lindenbaum-based chains under reflexive semantics"

### Evidence for Finding 5 (irreflexive semantics expressiveness):

Under irreflexive semantics, `G(p) → p` is NOT valid (consider: `p` is true at all future
strictly-greater times but false at the current time). Under reflexive semantics, it IS valid.
So removing BX1 makes the logic strictly weaker (fewer tautologies), meaning FEWER formulas
provable in the system. The completeness proof then needs to prove fewer things. This is
why the obstruction changes character: without BX1, `phi → F(phi)` is NOT derivable, so
resolved defects genuinely cannot re-emerge as F-obligations.

---

## Confidence Level

| Claim | Confidence |
|-------|-----------|
| IRR rule proposal has a category error (admissible vs. extension) | HIGH (85%) |
| BX1 blast radius is 150+ failures if removed | HIGH (90%) |
| Quasimodel concatenation is lower rollback risk than IRR constructor | HIGH (95%) |
| Five sorry sites have three distinct root causes | HIGH (90%) |
| Irreflexive semantics resolves F-eventuality obstruction | MEDIUM (65%) |
| Quasimodel concatenation approach succeeds | MEDIUM (50%) |
| IRR rule (correctly applied) would close sorry sites | LOW-MEDIUM (40%) |

## Rollback Strategy Summary

| Approach | Rollback Complexity | Trigger for Rollback |
|----------|--------------------|--------------------|
| Quasimodel concatenation | LOW — additive only, don't wire | Cannot prove periodic extension to Int |
| Irreflexive semantics (own branch) | MEDIUM — revert branch | Too many cascade failures |
| IRR constructor to DerivationTree | HIGH — all pattern matches break | After fixing all breaks, soundness fails |
| Goldblatt restructure | HIGH — rewrites canonical model | Cannot close truth lemma in new architecture |

## Recommended Git Branch Strategy

```
until (current)
  ├── feat/qm-int-chain        # Attempt 1: quasimodel concatenation
  │   (additive only, purely forward)
  ├── feat/irreflexive-semantics  # Attempt 2: semantic switch (if authorized)
  │   (from until, NOT from feat/qm-int-chain)
  └── feat/goldblatt-restructure  # Attempt 3: last resort
      (from until, independent)
```

Each branch is created from `until`, not from each other. If Attempt 1 succeeds,
merge to `until` and close the task. If it fails, abandon the branch and try Attempt 2.
Attempts 2 and 3 do NOT depend on Attempt 1 succeeding.

## Blind Spots Other Teammates May Miss

1. **The IRR constructor vs. admissibility confusion**: Other teammates may not realize
   that adding a constructor to `DerivationTree` is NOT the same as an admissible rule.

2. **Category B backward chain is independently broken**: Even if IRR closes F-eventuality
   (Category A), the backward chain (Category B) still has NO `preserving_bwd_step` and
   is symmetric only by wishful thinking.

3. **The 887-line quasimodel is sorry-free and untapped**: `Construction.lean` has the
   entire defect-discharge machinery built and proven. This is the obvious first path,
   not IRR.

4. **Semantic switch breaks BX8/BX8'**: Reflexive Until introduction (`psi → phi U psi`,
   axiom BX8) is INVALID under strict `<` semantics. If the goal is NOT just to remove BX1
   but to switch all semantics to irreflexive, BX8 and BX9 (`phi U psi → phi ∨ psi`) also
   change character. The axiom system needs a complete audit, not just removing BX1.
