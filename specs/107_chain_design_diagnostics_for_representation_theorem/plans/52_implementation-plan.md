# Implementation Plan: Task #107 -- Burgess Chronicle Construction (v52)

- **Task**: 107 - Chain design diagnostics for representation theorem
- **Status**: [IN PROGRESS]
- **Effort**: 20 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/52_phase2-research.md], [reports/51_team-research.md], [reports/50_sorry-architecture-audit.md], handoffs/49_phase3-seed-analysis.md
- **Artifacts**: plans/52_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Plan Version**: 52

## Overview

Plan v52 supersedes plan v51, incorporating critical research findings from Phase 2 blocker analysis. The key discovery (Report 52): the Since condition for `dc_delta_B_burgessR3` is **not provable** from BX axioms because monotonicity requires `⊢ beta → (beta ∧ β)` which is false. The solution: bypass `dc_delta_B_burgessR3` entirely and use Burgess's direct seed construction approach. This is not a workaround but the mathematically correct strategy per Burgess 1982.

The architectural changes from v51 remain valid: (1) extend g during point insertion so g is a first-class mathematical object at every finite stage, and (2) close FUC/FSC via Burgess Claim 2.11 with proper g-values. The key difference is in Phase 2: instead of trying to prove `burgessR3` for `DC({β} ∪ B)`, we construct the splitting seed directly using BX5+BX14+BX10 and bypass the Since condition entirely.

Definition of done: `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Current Sorry Census (2026-05-02)

| # | Line | Theorem | Phase | Difficulty | Status |
|---|------|---------|-------|-----------|--------|
| 1 | ~1126 | `burgess_D0_finite_subset_consistent` | 2 | HARD (Burgess compression) | OPEN |
| 2 | ~1150 | `burgess_D0_finite_subset_consistent_incons` | 2 | MEDIUM (same as #1 but simpler) | OPEN |
| 3 | ~1586 | `lemma_2_7_seed_consistent` | 3 | HARD (same pattern as #1) | OPEN |
| 4 | ~1659 | `h_eta_B'` in `lemma_2_7` | 3 | MEDIUM (BX7 + maximality) | **CLOSED** (2026-05-02) |

**Total**: 3 sorry sites remain. Build passes. Site 4 closed via DC({eta}) Zorn restructure.

---

## AGENT INSTRUCTIONS: Closing the 3 Remaining Sorry Sites

**READ THIS FIRST.** All 3 remaining sorry sites require the same proof. Previous agents wasted time on dead-end approaches. This section gives the EXACT correct argument. Do not deviate.

### The Goal

Prove `SetConsistent (burgess_D0_seed A B C β)` where:
```
burgess_D0_seed A B C β = B ∪ {β.neg} ∪ {untl(β',γ) : β'∈B, γ∈C} ∪ {snce(β',α) : β'∈B, α∈A}
```

`SetConsistent S` means: `∀ L : List Formula, (∀ φ ∈ L, φ ∈ S) → ¬Nonempty (DerivationTree L Formula.bot)`.

### Dead Ends (DO NOT ATTEMPT)

1. ❌ Show D₀ ⊆ single MCS (impossible: B⊄A, snce∈C not A)
2. ❌ Show D₀ ⊆ {β.neg}∪g_content(A) (B⊄g_content(A) without density)
3. ❌ Filter L into subsets and derive ⊥ from each (weakening goes wrong direction)
4. ❌ D₀ ⊆ {β.neg}∪g_content(A)∪h_content(C) (seed can be genuinely inconsistent)
5. ❌ Deduction theorem separation without the event construction (gives nothing useful)

### The Correct Proof (Burgess 1982, p.370-371)

**Structure**: Given finite `L ⊆ D₀` and `d : DerivationTree L ⊥`, derive `False`.

**Step 1: Classify L elements.** Each φ∈L is one of:
- (a) φ∈B (a B-element, call these b₁,...,bₖ)
- (b) φ = β.neg
- (c) φ = untl(β'ᵢ, γᵢ) with β'ᵢ∈B, γᵢ∈C (these are in A by burgessR3)
- (d) φ = snce(β'ⱼ, αⱼ) with β'ⱼ∈B, αⱼ∈A (these are in C by burgessR3)

**Step 2: Form the compressed conjunction.** Define:
- `b = β₀ ∧ b₁ ∧ ... ∧ bₖ ∧ β'₁ ∧ ... ∧ β'ₘ` (conjunction of ALL B-guards from L, plus β₀ from maximality). Since B is DCS (closed under ∧): b∈B.
- `γ̂ = γ₀ ∧ γ₁ ∧ ... ∧ γₙ` (conjunction of all C-events from Until formulas, plus γ₀ from maximality). Since C is MCS: γ̂∈C.
- α₁,...,αₘ: the A-events from Since formulas (each αⱼ∈A).

**Step 3: BX chain produces F(event)∈A.** Starting from:
- `untl(b, γ̂) ∈ A` (from burgessR3: h_r3.1 b hb γ̂ hγ̂)
- `¬untl(b∧β, γ̂) ∈ A` (from maximality, via left_mono contrapositive from ¬untl(β₀∧β, γ₀)∈A)

Apply in sequence:
1. **BX5** (`self_accum_until_mcs`): `untl(b∧untl(b,γ̂), γ̂) ∈ A`
2. **BX14** (`separation_until_mcs`): `untl(q, q∧(b∧β).neg) ∈ A` where `q = b∧untl(b,γ̂)`
3. **BX13** (`enrichment_until_mcs`) applied m times, once per αⱼ∈A:
   - First: `untl(q, (q∧(b∧β).neg) ∧ snce(q, α₁)) ∈ A` (uses α₁∈A ← THIS IS THE KEY: p=αⱼ∈A, NOT snce(...)∈C)
   - Second: `untl(q, event₁ ∧ snce(q, α₂)) ∈ A` (uses α₂∈A)
   - ... repeat for each αⱼ
4. **BX10** (`until_implies_F_mcs`): `F(big_event) ∈ A` where big_event = q∧(b∧β).neg∧snce(q,α₁)∧...∧snce(q,αₘ)

### CRITICAL: Why BX13 Works Here

BX13 (A3a): `p ∧ untl(guard, event) → untl(guard, event ∧ snce(guard, p))`

The operand `p` is **α∈A** (the Since-event argument), NOT the snce-formula itself.
- The snce-formula `snce(β',α)` lives in C
- But the operand for BX13 is `α` which lives in A ✓
- BX13 PRODUCES `snce(guard, α)` as part of the enriched event

Previous agents confused "snce(β',α)∈C" with "p=snce(β',α) needs to be in A". WRONG. p=α∈A.

**Step 4: big_event implies each element of L.** For each φ∈L, construct `DerivationTree [big_event] φ`:

- **For bᵢ∈B**: big_event contains q = b∧untl(b,γ̂). Conjunction elimination: big_event⊢q⊢b⊢bᵢ (since b=∧...∧bᵢ∧...).
- **For β.neg**: big_event contains (b∧β).neg. Combined with b (from q): big_event⊢β.neg. (Already proved as `h_event_implies_beta_neg` in the file!)
- **For untl(β'ᵢ, γᵢ)**: big_event⊢q⊢untl(b,γ̂). Then:
  - `left_mono` with ⊢b→β'ᵢ (conjunction elimination since b includes β'ᵢ): `untl(b,γ̂)→untl(β'ᵢ,γ̂)` 
  - `right_mono` with ⊢γ̂→γᵢ (conjunction elimination since γ̂ includes γᵢ): `untl(β'ᵢ,γ̂)→untl(β'ᵢ,γᵢ)`
  - Combined: big_event⊢untl(β'ᵢ,γᵢ) ✓
- **For snce(β'ⱼ, αⱼ)**: big_event contains snce(q, αⱼ) (from BX13 step j). Then:
  - `snce_left_mono` with ⊢q→β'ⱼ (q contains b which contains β'ⱼ): `snce(q,αⱼ)→snce(β'ⱼ,αⱼ)`
  - Combined: big_event⊢snce(β'ⱼ,αⱼ) ✓

**Step 5: Derive contradiction.**
- From Step 4: `∀φ∈L, DerivationTree [big_event] φ`
- Apply `derivation_from_implied [big_event] L ⊥ h_derives d` to get `DerivationTree [big_event] ⊥`
- But `F(big_event)∈A` (Step 3), so big_event is consistent:
  - If `⊢¬big_event` then `G(¬big_event)∈A` by TG, so `¬F(big_event)∈A`, contradicting `F(big_event)∈A`
  - So `{big_event}` is consistent, meaning `¬Nonempty(DerivationTree [big_event] ⊥)`
- Contradiction with `DerivationTree [big_event] ⊥`. QED.

### Implementation Notes

**Handling the finite list L**: The proof is parametric in L. You DON'T need to literally construct b, γ̂ from L at the term level. Instead:

1. Use `Classical.choice` or `Finset` operations to extract the relevant guards/events from L
2. Or: use the EXISTING β₀, γ₀ from the BX chain (already extracted in the file at lines ~1219-1232) and show they suffice. The key insight: β₀ is from maximality and γ₀∈C. For arbitrary L, we need b to include ALL B-guards. The simplest approach: take b = β₀ (already in B) and show the existing BX chain's event implies everything. This WON'T work for arbitrary B-elements in L.

**Practical approach**: The proof needs to be parametric in L. Define helper:
```lean
private noncomputable def list_conj : List Formula → Formula
  | [] => Formula.bot.imp Formula.bot  -- top (identity for ∧)
  | [φ] => φ
  | (φ :: rest) => Formula.and φ (list_conj rest)
```

Then prove:
- `list_conj_mem_dcs`: If B is DCS and ∀φ∈L, φ∈B, then list_conj L ∈ B
- `list_conj_implies_elem`: ∀φ∈L, DerivationTree [list_conj L] φ
- `list_conj_mem_mcs`: If A is MCS and ∀φ∈L, φ∈A, then list_conj L ∈ A

These are straightforward inductions on List.

**For the inconsistent case** (site 2, β.neg∈B): Same proof but SIMPLER:
- β.neg∈B means β.neg is just another B-element. No BX14 step needed.
- Use untl(b, γ̂)∈A directly with BX5+BX13+BX10 (skip BX14).
- The event is simpler: q∧snce(q,α₁)∧...∧snce(q,αₘ) where q=b∧untl(b,γ̂).
- big_event⊢β.neg because β.neg∈B so β.neg is part of b (conjunction elimination).

**For lemma_2_7_seed_consistent** (site 3): Same pattern but seed has 5th component `{snce(β∧eta, α) : β∈B, α∈A}`:
- Additional snce formulas with guard β∧eta
- Use BX13 with p=α∈A as before (same as sites 1-2)
- The enriched event gets `snce(q, α)` which implies `snce(β∧eta, α)` via left_mono with ⊢q→(β∧eta) (since q contains b which contains β, and... wait, q may not contain eta)
- For the 5th component: need snce(q, α)→snce(β∧eta, α). This requires ⊢q→(β∧eta). Since q=b∧untl(b,γ̂) and b includes β... but NOT eta. So need eta in q somehow.
- Resolution: for lemma_2_7_seed, include xi (which is in the seed) and use the fact that untl(xi,eta)∈A to get F(eta)∈A, then include eta in the event via a slightly different chain. OR: include eta in b (but eta may not be in B).
- Actually: the lemma_2_7 seed includes {xi} directly. And from untl(xi,eta)∈A + BX5+BX10: F(eta)∈A. Build a different event that includes eta. Alternatively: the left_mono for the 5th component uses ⊢q→β (not ⊢q→(β∧eta)), giving snce(q,α)→snce(β,α) but NOT snce(β∧eta,α).
- CORRECT handling: Apply BX13 with p=α∈A TWICE for the 4th and 5th components, using different Until formulas. For the 5th component, start from `untl(xi∧b, eta∧γ̂)∈A` (derivable from BX7 on untl(xi,eta) and untl(b,γ̂)), then enrich from THAT chain. This gives snce(xi∧b, α) in the event, and ⊢(xi∧b)→(β∧eta) might not hold.
- SIMPLEST correct handling: the 5th component formulas snce(β∧eta, α) can be derived from snce(q', α) where q' is a guard containing β∧eta. Build a SECOND BX13 chain from untl(xi∧b∧eta_stuff, ...) that produces snce with the right guard. This is complex but follows the same pattern.
- For the FIRST implementation pass: handle sites 1 and 2 first (they don't have the 5th component issue). Site 3 can be deferred or handled similarly with appropriate guard choice.

### Required Helper Lemmas (implement these FIRST)

```lean
-- 1. List conjunction (already may exist, search first)
private noncomputable def list_conj : List Formula → Formula

-- 2. Conjunction implies each element
private theorem list_conj_implies_elem (L : List Formula) (φ : Formula) (h : φ ∈ L) :
    DerivationTree [list_conj L] φ

-- 3. DCS conjunction closure
private theorem list_conj_mem_dcs {B : Set Formula} (h_dcs : SetDeductivelyClosed B)
    (L : List Formula) (h : ∀ φ ∈ L, φ ∈ B) : list_conj L ∈ B

-- 4. MCS conjunction closure
private theorem list_conj_mem_mcs {A : Set Formula} (h_mcs : SetMaximalConsistent A)
    (L : List Formula) (h : ∀ φ ∈ L, φ ∈ A) : list_conj L ∈ A

-- 5. F(φ)∈A means {φ} is consistent (from seriality)
private theorem consistent_of_F_mem {A : Set Formula} (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (h : Formula.some_future φ ∈ A) : ¬Nonempty (DerivationTree [φ] Formula.bot)

-- 6. Bridge: consistent event + event implies all L elements → L consistent
-- (This is derivation_from_implied + consistent_of_F_mem combined)
```

### Execution Order

1. Implement helper lemmas 1-5 above
2. Close sorry site 2 (inconsistent case — simpler, no BX14)
3. Close sorry site 1 (consistent case — full BX chain)
4. Close sorry site 3 (lemma_2_7 — same as site 1 with 5th component handling)

---

### Research Inputs

Reports 50-52, Handoff 49. Key finding: Since condition for DC({β}∪B) is unprovable; use Burgess's direct D₀ construction instead. g_content ordering was a persistent distraction — proven wrong and archived.

## Goals

- Sorry-free `dd_countermodel_chronicle` (`#print axioms` clean)
- Maintain `lake build` at each phase boundary
- Follow Burgess 1982 faithfully (not simplifications that break)

## Implementation Phases

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0, 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 4, 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |

---

### Phase 0: Clean Non-Burgess Cruft [COMPLETED]

Deleted ~150 lines of dead helpers (g_content_sub_B, h_content_sub_B, splitting_seed_consistent, etc.).

---

### Phase 1: Verify BX Axiom Sufficiency [COMPLETED]

Confirmed BX5/BX13/BX14/BX10 map to Burgess's A5a/A3a/A4a/Lemma 2.2.

---

### Phase 2: Burgess D₀ Seed Construction [PARTIAL]

**Status**: [PARTIAL] — Architecture complete. 2 sorry sites remain (seed consistency).

**Completed**: `burgess_D0_seed` defined, `lemma_2_6_splitting` body sorry-free (Lindenbaum + Lemma 2.3 + Zorn), g_content dead code archived, BX5+BX14+BX10 chain proved, `derivation_from_implied` proved, `{β.neg}∪B` consistent proved.

**Remaining**: `burgess_D0_finite_subset_consistent` (line ~1126) and `burgess_D0_finite_subset_consistent_incons` (line ~1150). **See AGENT INSTRUCTIONS section above for the exact proof.**

---

### Phase 3: Implement lemma_2_7 (Until-Formula Splitting) [PARTIAL]

**Status**: [PARTIAL] — 1 sorry site remains (`lemma_2_7_seed_consistent`, line ~1586).

**Completed**: `lemma_2_7` body sorry-free (memberships, r-relations, Zorn, eta∈B' via DC({eta}) restructure). `h_eta_B'` **CLOSED** 2026-05-02.

**Remaining**: `lemma_2_7_seed_consistent` — same Burgess compression as Phase 2 (see AGENT INSTRUCTIONS). Additional subtlety: 5th seed component `{snce(β∧eta, α)}` needs guard containing eta. See AGENT INSTRUCTIONS "For lemma_2_7_seed_consistent" subsection.

**Tasks**:
- [ ] Define `burgess_D0_until` computing D0 for Lemma 2.7
- [ ] Prove maximality extraction: from eta not in B, obtain beta0, gamma0, neg-U(gamma0, beta0 AND eta) in A
- [ ] Prove BX5+BX7 three-way disjunction and D1/D2 elimination
- [ ] Prove seed consistency using the surviving D3 case
- [ ] Implement lemma_2_7 body using D0 pattern from Phase 2 as template
- [ ] Prove eta in B' from the U(xi, beta AND eta) membership and maximality
- [ ] Verify lemma_2_7 compiles sorry-free
- [ ] Run `lake build`

**Timing**: 4 hours

**Depends on**: 1 (BX axiom sufficiency confirmed; shares same BX axiom infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- implement lemma_2_7 body (~250 lines, replacing sorry at line 1052)

**Verification**:
- `lemma_2_7` sorry-free
- PointInsertion.lean sorry count reduced (depends on Phase 2 completion)
- `lake build` succeeds

---

### Phase 4: Extend g During Point Insertion + Thread c2' Through omega_chain [NOT STARTED]

**Status**: Architectural design documented but NO implementation done. Previous attempt added documentation-only comments to `EliminationResult` which caused syntax errors (now reverted). Actual implementation of c2' field, g-value tracking, and threading through omega_chain is pending.

**Prerequisites**: Phases 2 and 3 must be complete (lemma_2_6_splitting and lemma_2_7 sorry-free)

**Required Changes**:
1. **EliminationResult**: Add c2' field to track BurgessR3Maximal invariant
2. **g_value tracking**: Track g-values for new adjacent pairs
3. **c2'_preservation**: Prove old adjacent pairs maintain c2'
4. **omega_chain**: Thread c0 AND c2' as joint invariant (currently only c0)

**Goal**: Make g a first-class mathematical object by modifying EliminationResult to carry new g-values and updating each elimination function to assign proper B, B', B'' values. Thread c0+c2' as a joint omega_chain invariant.

This is the core architectural change of v52. Currently, elimination functions set `chi'.g = chi.g` for all pairs (CE.lean:177, line 189), and the omega_chain carries only c0 as an invariant (ChronicleConstruction.lean:253-260). After this phase, each elimination function properly assigns g-values for new adjacent pairs, and the omega_chain carries both c0 and c2'.

**Burgess context**: In Burgess 1982, g is a first-class object of the chronicle (f, g, dom). At each point insertion:
- Lemma 2.4 (C5 elimination) produces B as g'(x,y) for the new pair (x,y)
- Lemma 2.6 (C4 elimination) produces B', B'' as g'(x,z) and g'(z,y) for the split pair
- Lemma 2.7 (C5 n>0, Until-formula splitting) similarly produces B', B''
- C3 determines g'(w,z) for non-adjacent pairs

**Sub-tasks**:

**4a: Refactor EliminationResult to carry c2'**:
- [ ] Add `c2' : val.c2'` field to `EliminationResult` structure (ChronicleTypes.lean or CounterexampleElimination.lean)
- [ ] Add hypothesis `h_c2' : chi.c2'` to `eliminate_potential_counterexample` signature (alongside existing `h_c0`)
- [ ] Update all call sites that construct EliminationResult to provide c2' proof

**4b: Modify C5/C5' elimination to assign g-values**:
- [ ] In `eliminate_C5_counterexample` (CE.lean:167): capture `_B` from `lemma_2_4` output (currently discarded at line 182)
- [ ] Change the chronicle construction (line 187) from `chi.g` to a new g' that assigns B to the new adjacent pair (x, y) where y is the inserted point
- [ ] For pairs not involving the new point, g' = chi.g
- [ ] Prove c2' for the new chronicle: old adjacent pairs have unchanged g (from h_c2'), the new adjacent pair (x,y) has g(x,y) = B from lemma_2_4 which gives BurgessR3Maximal by construction
- [ ] Mirror for `eliminate_C5'_counterexample` (Since direction)

**4c: Modify C4/C4' elimination to assign g-values**:
- [ ] In `eliminate_C4_counterexample` (CE.lean, hard case at line 412): when inserting z between w and w_next, call `lemma_2_6_splitting` (now available from Phase 2) to get B', D, B''
- [ ] Assign g'(w, z) = B' and g'(z, w_next) = B'' in the new chronicle
- [ ] Prove c2': old adjacent pairs unchanged, new pairs (w,z) and (z,w_next) have BurgessR3Maximal from lemma_2_6_splitting output
- [ ] This simultaneously closes the sorry at line 412 (C4 hard case) -- the splitting point D has neg-gamma in D
- [ ] Mirror for C4' (Since direction, sorry at line 510)

**4d: Modify density elimination to assign g-values**:
- [ ] When inserting midpoint z between x and y, split g(x,y) into g'(x,z) and g'(z,y) using BurgessR3Maximal from lemma_2_6_splitting (with the trivial case where delta is arbitrary)
- [ ] Prove c2' for new adjacent pairs

**4e: Thread c2' through omega_chain**:
- [ ] Change `omega_chain` return type from `{ chi : Chronicle // chi.c0 }` to `{ chi : Chronicle // chi.c0 AND chi.c2' }` (ChronicleConstruction.lean:253)
- [ ] Update `omega_chain` base case: singleton_chronicle satisfies c2' vacuously (already proved as `singleton_c2'`)
- [ ] Update `omega_chain` step case: use the c2' field of EliminationResult
- [ ] Update `omega_chain_c0` and add `omega_chain_c2'` accessor
- [ ] Add g-agreement theorem: for old adjacent pairs, g is preserved across steps

**Timing**: 5 hours

**Depends on**: 2, 3 (lemma_2_6_splitting and lemma_2_7 sorry-free, needed for C4/C4' g-value construction)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- refactor EliminationResult, update all elimination functions to assign g-values and prove c2' (~200 lines of changes)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- thread c2' through omega_chain, add g-agreement theorems (~80 lines of changes)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- EliminationResult c2' field if structure is defined there

**Verification**:
- C4/C4' sorry sites (CE.lean lines 412, 510) closed as a byproduct of g-value assignment
- CounterexampleElimination.lean sorry count: 0
- omega_chain carries c0+c2' joint invariant
- `lake build` succeeds

---

### Phase 5: Close C4/C4' via Burgess Lemma 2.9 with Proper c2' [NOT STARTED]

**Goal**: Verify that the C4/C4' sorry sites were closed in Phase 4 as a byproduct of g-value assignment, or complete any remaining work.

**Context**: Phase 4c modifies the C4 hard case (CE.lean line 412) to call lemma_2_6_splitting for g-value construction. The splitting point D has neg-gamma in D by construction. This should simultaneously close the sorry. Phase 5 is a verification/cleanup phase.

**If Phase 4c fully closed the sorries**:
- [ ] Verify both C4 (line 412) and C4' (line 510) sorry sites are eliminated
- [ ] Run `lake build` to confirm

**If Phase 4c left residual work** (e.g., the c2' hypothesis for lemma_2_6_splitting at the sorry site):
- [ ] The c2' invariant from the omega_chain provides BurgessR3Maximal(f(w), g(w,w_next), f(w_next)) for the adjacent pair
- [ ] Apply lemma_2_6_splitting directly: given BurgessR3Maximal and gamma not in g(w,w_next) (from maximality), get D with neg-gamma in D
- [ ] Close the sorry using D as the splitting witness

**Timing**: 1 hour

**Depends on**: 4 (c2' available from omega_chain)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- if residual work remains

**Verification**:
- CounterexampleElimination.lean sorry count: 0
- `lake build` succeeds

---

### Phase 6: Implement Full Lemma 2.10 (C5 with Guard) + Prove limit_satisfies_c5_full [NOT STARTED]

**Goal**: Strengthen C5 elimination to include the guard (xi in f(z) for intermediate z) and prove this propagates to the limit. This is the mathematical core that enables FUC/FSC.

**Burgess Lemma 2.10**: When U(xi, eta) in f(x) and no witness exists, add y with eta in f(y). The guard must hold at all intermediate points z with x < z < y.

**Base case (n=0)**: The inserted point y is beyond all domain points, so there are no intermediate domain points. Guard is vacuously satisfied. The current `eliminate_C5_counterexample` already handles this (CE.lean:167). With Phase 4's g-value assignment, B = g'(x,y) from Lemma 2.4 carries the guard info implicitly.

**Inductive case (n>0)**: When there are domain points between x and the endpoint, use Lemma 2.7 (Until-formula splitting) to insert a point that maintains the guard. Specifically:
- If there exists z in dom with x < z < y and xi not in f(z), the guard fails
- Apply Lemma 2.7 to get D with xi in D and eta in B' (the interval from x to D)
- The new point D restores the guard locally
- Iterate until all intermediate points satisfy the guard

**What this changes in EliminationResult**:
- Strengthen `c5_forward_witness` to include: `forall z in val.dom, pc.x < z -> z < y -> pc.xi in val.f z AND Formula.untl pc.xi pc.eta in val.f z`
- This matches the full C5 definition in ChronicleTypes.lean:427-433

**Proving limit_satisfies_c5_full**: With proper g-values at finite stages:
1. C5 at finite stage n gives: y in dom(n) with eta in f(y) and guard (xi in f(z)) for all z in dom(n) between x and y
2. At the limit, the guard must hold for ALL limit_dom points between x and y
3. Key argument: xi in limit_g(x, y) because C5 elimination places xi in g_n(x,y) at the finite stage, and g-values are preserved at later stages. Then limit_g(x,y) subset limit_f(z) for intermediate z by C3 at the limit (already proved as `limit_c3_interval_subset_point`).
4. Additionally, U(xi,eta) in limit_g(x,y) ensures the Until propagation at intermediate points.

**Tasks**:
- [ ] Strengthen `c5_forward_witness` in EliminationResult to include full guard info
- [ ] Update `eliminate_C5_counterexample` to prove the strengthened witness:
  - Base case (no intermediate points): guard vacuously true
  - If intermediate points exist with guard failure: apply lemma_2_7 to fix
- [ ] Mirror strengthening for `c5_backward_witness` (Since direction)
- [ ] Add g-value propagation lemma: at finite stage n, if C5 elimination at step k (k <= n) placed xi in g_k(x,y), then xi in g_n(x,y) for all subsequent stages where (x,y) remains adjacent
- [ ] Prove `limit_satisfies_c5_full`: for U(xi,eta) in limit_f(x), there exists y in limit_dom with eta in limit_f(y) AND xi in limit_f(z) for all z in limit_dom between x and y
  - Use: xi in limit_g(x,y) from finite stage g-values
  - Use: limit_c3_interval_subset_point gives limit_g(x,y) subset limit_f(z) for intermediate z
- [ ] Run `lake build`

**Timing**: 3 hours

**Depends on**: 4 (g-values in EliminationResult), 5 (C4/C4' confirmed closed, so limit construction is sound)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- strengthen C5 witness fields (~60 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- prove limit_satisfies_c5_full with g-value propagation (~120 lines)

**Verification**:
- `limit_satisfies_c5_full` proved (sorry-free)
- Full C5 guard info available at the limit
- `lake build` succeeds

---

### Phase 7: Close FUC/FSC via Claim 2.11 [NOT STARTED]

**Goal**: Close the 2 sorry sites in ChronicleToCountermodel.lean (lines 615, 619) for forward Until and forward Since coherence, using Burgess's Claim 2.11.

**Burgess Claim 2.11**: The limit chronicle satisfies Until/Since coherence:
- For U(phi, psi) in f(t): C5 at the limit gives witness y > t with psi in f(y) and the guard phi in f(z) for all intermediate z
- The guard follows from: C5 elimination gives phi in g(t,y), and C3 at the limit gives g(t,y) subset f(z) for intermediate z

**Concretely at the sorry sites**:
- `cantor_bfmcs_restricted_fuc` (line 604) needs: given U(phi,psi) in the Cantor-mapped MCS at index t, produce witness s > t with psi at s and guard phi at all intermediate indices
- This follows from `limit_satisfies_c5_full` (Phase 6) composed with the Cantor isomorphism

**Tasks**:
- [ ] Inspect FUC sorry at line 615 with `lean_goal` to understand exact proof obligation
- [ ] Connect `limit_satisfies_c5_full` to the Cantor-based BFMCS structure
- [ ] Map the limit C5 witness through the Cantor isomorphism to get the BFMCS witness
- [ ] Close FUC sorry site (forward Until coherence)
- [ ] Inspect FSC sorry at line 619 with `lean_goal`
- [ ] Close FSC sorry site (forward Since coherence, mirror of FUC using limit_satisfies_c5'_full)
- [ ] Run `lake build`

**Timing**: 2 hours

**Depends on**: 6 (limit_satisfies_c5_full provides the witnesses)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorry sites (~80 lines each)

**Verification**:
- ChronicleToCountermodel.lean sorry count: 0
- `lake build` succeeds

---

### Phase 8: Final Audit, Validation, and ROADMAP Update [NOT STARTED]

**Goal**: Comprehensive verification that the chronicle construction is sorry-free, plus ROADMAP update to reflect completion.

**Tasks**:
- [ ] Run `#print axioms dd_countermodel_chronicle` -- verify no `sorryAx`
- [ ] Run `lake build` on full project -- verify no regressions
- [ ] Grep for sorry in all Chronicle/ files -- verify no active sorry sites remain
- [ ] Grep for sorry in all BXCanonical/ files -- verify no new sorry sites introduced
- [ ] Verify all previously sorry-free lemmas remain sorry-free (no regressions)
- [ ] Update module docstrings in Chronicle/ files to reflect final proof structure
- [ ] Update ROADMAP.md:
  - Mark chronicle sorry sites as closed (update from "4 sorry sites" to "0 sorry sites")
  - Update "Current state" in Chronicle Construction section
  - Update sorry census tables
  - Add completion annotation: `*(Completed: Task 107, 2026-05-01)*` to relevant items
  - Update task 107 status in cross-reference table
  - Update "Last updated" timestamp

**Timing**: 0.5 hours

**Depends on**: 7

**Files to modify**:
- Documentation updates across Chronicle/ files (docstrings only)
- `specs/ROADMAP.md` -- update chronicle status, sorry counts, completion annotations

**Verification**:
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments/docstrings
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- Full `lake build` clean
- ROADMAP.md reflects 0 chronicle sorry sites with completion annotation

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] Phase 0: no references to deleted helpers in active code
- [ ] Phase 1: BX13/BX14 axiom roles confirmed for D0 seed
- [ ] Phase 2: `lemma_2_6_splitting` sorry-free with REVISED direct seed construction (Report 52 approach)
- [ ] Phase 3: `lemma_2_7` sorry-free (Burgess Until-formula splitting)
- [ ] Phase 4: EliminationResult carries c2', g-values properly assigned, C4/C4' sorry sites closed as byproduct
- [ ] Phase 5: C4/C4' confirmed closed, CounterexampleElimination sorry count = 0
- [ ] Phase 6: `limit_satisfies_c5_full` proved, full C5 guard at limit
- [ ] Phase 7: FUC/FSC sorry sites (lines 615, 619) closed via Claim 2.11
- [ ] Phase 8: `grep -rn "sorry" Chronicle/` returns no active sorry usages
- [ ] Phase 8: `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)

## Artifacts & Outputs

- `plans/52_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (cruft cleanup + REVISED Burgess D0 seed for 2.6 and 2.7)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (EliminationResult refactor, g-value assignment, C4/C4' sorry closure, C5 guard strengthening)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (c2' omega_chain invariant, g-agreement, limit_satisfies_c5_full)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (FUC/FSC closure via Claim 2.11)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (EliminationResult c2' field, if structure defined there)
- Updated `specs/ROADMAP.md` (chronicle completion)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- **Phase 0 (cruft cleanup)**: Revert via git if any breakage. All deleted code is non-Burgess helpers with sorry bodies -- no functional loss.
- **Phase 2 (D0 seed direct construction)**: If BX5+BX14+BX10 chain translation is problematic, the handoff 49 Approach 3 (weakened output without g_content conditions) is a viable interim target. This defers full BurgessR3Maximal output but may unblock later phases.
- **Phase 3 (lemma_2_7 BX7 chain fails)**: If D1/D2 elimination via neg-U(gamma0, beta0 AND eta) does not work, the two-step BX7 derivation chain (from prior handoff) can substitute for A7a in the seed consistency proof.
- **Phase 4 (g-value assignment breaks existing proofs)**: The refactor is additive (new fields), not destructive. If `g_agrees` changes break downstream, temporarily maintain both old and new g-agreement fields and migrate incrementally.
- **Phase 4e (c2' threading too complex)**: If threading c2' through all elimination branches is prohibitive, thread it through only C5/C5' and C4/C4' branches (the ones that need it), and have density/G-propagation branches use a trivial c2' proof.
- **Phase 6 (full Lemma 2.10 n>0 case too complex)**: If the inductive argument is too involved, a weaker version using only the base case (n=0) plus the limit_g C3 property may suffice for many formulas. Stub the n>0 case with sorry and document.
- **Phase 7 (FUC/FSC blocked by limit_satisfies_c5_full weakness)**: If the g-value chain from finite to limit is insufficient, a direct argument via the definition of limit_g (which is exactly the set of formulas in all intermediate limit_f values) may bypass the need for finite-stage g tracking. This is a fallback that works because limit_g is defined as the intersection, not as a limit of finite g-values.
- Git history preserves all prior states; each phase is independently committable.

## Research Summary (Report 52 Integration)

### Critical Finding: Since Condition Blocker

**Problem**: The Since condition for `dc_delta_B_burgessR3` is **NOT provable** from BX axioms.

**Root Cause Analysis**:
- To derive `snce(beta ∧ β, alpha)` from `snce(beta, alpha)`, we need `⊢ beta → (beta ∧ β)`
- This is **false** in general (conjunction introduction requires both conjuncts, not just one)
- No BX axiom provides the needed strengthening property without being semantically unsound

**Why This Matters**:
- The old Phase 2 approach tried to prove `burgessR3` for `DC({β} ∪ B)` as an intermediate step
- This required both Until and Since conditions for the deductive closure
- The Since condition was the blocker

**The Solution** (per Burgess 1982):
- **Do NOT** prove `burgessR3` for `DC({β} ∪ B)`
- **DO** construct D₀ directly: {S(α,β) : α∈A, β∈B} ∪ {¬δ} ∪ {U(γ,β) : γ∈C, β∈B}
- Prove D₀ consistent via BX5+BX14+BX10 chain (Until formula in A)
- Extend to MCS D via Lindenbaum
- Extract B', B'' AFTER D exists via Zorn (BurgessR3Maximal)

**Impact on Plan**:
- Phase 2 is now **viable** with the revised approach
- No dependency on impossible Since condition proof
- Direct seed construction is actually **simpler** than the blocked inductive approach
- All downstream phases (3-8) remain unchanged

### Axiom Chain for REVISED Phase 2

| Step | Axiom | Formula | Purpose |
|------|-------|---------|---------|
| 1 | BX5 (self_accum_until) | U(γ, β) → U(γ ∧ U(γ,β), β) | Guard enrichment |
| 2 | BX14 (separation_until) | U(γ ∧ U(γ,β), β) ∧ ¬U(γ, β ∧ δ) → U(β ∧ U(γ,β) ∧ ¬δ, β) | Extract event with ¬δ |
| 3 | BX10 (until_F) | U(φ, ψ) → F(ψ) | Eventuality |
| 4 | Lindenbaum | D₀ consistent → D exists | Extension to MCS |
| 5 | Zorn | D exists → B', B'' exist | Maximality extraction |

**Key Insight**: The Since formulas in D₀ (h_content C) don't need individual proof—their consistency follows from duality with the Until side, and they're included in the seed directly.

(End of file - total ~700 lines)
