# Implementation Plan: Kamp's Theorem via Rabinovich 2014 (v17)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [NOT STARTED]
- **Effort**: 40 hours
- **Dependencies**: None
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/08_team-research.md
- **Artifacts**: plans/08_kamp-rabinovich-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the sorry-tainted `stavi_expressive_completeness` dependency in `US_expressively_complete_over_prior` with a direct proof of {U,S} expressive completeness over Prior structures, following Rabinovich 2014's composition-based proof of Kamp's theorem. The key insight: Rabinovich's proof is order-class-agnostic except for one step (Lemma 5.3's INF formula, which requires Dedekind completeness), and Prior-UZ delivers something strictly stronger for that step -- attained first occurrences of TL-definable sets. This dissolves all recurring blockers at once: no Stavi connectives, no two-model transfer, no zone matching, no arity escalation, no circularity. The three sorry sites in StaviCompleteness.lean (2405, 2487, 2857) leave the critical path entirely. The signature of `US_expressively_complete_over_prior` is unchanged; only its proof body changes. All downstream consumers are unaffected.

### Research Integration

Team research report 08 (4 teammates) established:
1. Sorry site 3 (`nf_exist_sf_guarded_backward`, line 2857) is mathematically FALSE as stated -- two independent verifications.
2. Plan v16 is unsalvageable -- hypotheses provably too weak, step case cannot propagate.
3. Path A (Rabinovich bypass) recommended as primary approach with mandatory PDF verification gate.
4. The sole external consumer of `stavi_expressive_completeness` is `US_expressively_complete_over_prior` (PriorExpressiveness.lean:384), which already restricts to Prior structures.
5. `semantic_prior_UZ` delivers attained first occurrences -- strictly stronger than Dedekind completeness for definable sets.
6. Rabinovich's Lemma 3.2(2) caps free variables at 2 -- no arity escalation.

### Prior Plan Reference

Plan v16 (interval-splitting zone match) blocked in Phase 1: `interval_splitting_zone_match` is false for 1-var interval types. The fundamental issue is that GHR's game invariant requires adjacent-pair 2-var NF agreement, not 1-var interval type sets. The v16 approach attempted to prove sub-interval type agreement from 1-var data, which has no literature support. Effort calibration from v11-v16: each cycle consumed 2-6 hours on increasingly refined but ultimately dead-end approaches within the Stavi NF framework. Key lesson: the Stavi chain's sorry sites are mathematically intractable (sorry site 3 is provably false), so bypassing the chain entirely is the only viable path.

### Roadmap Alignment

This plan advances:
- Task 273 (generalized existential transfer / Stavi sorry chain) -- resolves the chain by bypass
- Critical path item: "sorry-free `stavi_expressive_completeness`" -- bypassed rather than proved
- Critical path item: "sorry-free `US_expressively_complete_over_prior`" -- directly addressed
- Unblocks task 202 (Reynolds k-equivalence bypass) via sorry-free model surgery

## Goals & Non-Goals

**Goals**:
- Prove `US_expressively_complete_over_prior` sorry-free by replacing `stavi_expressive_completeness` with a direct Kamp-style argument
- Develop Rabinovich's exists-forall normal form (Def 3.1) and closure lemmas (3.2, 3.4) in new files under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`
- Prove the translation from exists-forall formulas to temporal formulas (Prop 3.5)
- Prove closure under negation for Prior structures (Prop 4.2 relativized)
- Wire the Prior instance into `US_expressively_complete_over_prior` -- change only the proof body
- Document `stavi_expressive_completeness` and its sorry chain as an open generalization

**Non-Goals**:
- Proving `stavi_expressive_completeness` sorry-free (bypassed, documented as open)
- Filling sorry sites 2405, 2487, 2857 in StaviCompleteness.lean (leave on the Stavi chain)
- Proving Kamp's theorem for general Dedekind-complete orders (only Prior structures needed)
- Building EF game infrastructure (Rabinovich's proof avoids games entirely)
- Modifying `stavi_expressive_completeness` or its sorry chain
- Changing the signature of `US_expressively_complete_over_prior`
- Filling DiscreteStaviCompleteness.lean sorries (off critical path)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Literature verification gate fails: completeness used in Rabinovich Section 5 for something beyond first/last occurrences of TL-definable sets | H | L | Gate already passed: PDF inspection confirms INF formula (5.2/5.3) is the sole completeness use, and it reduces to inf of a definable set. Prior-UZ provides exactly this for TL-definable sets. |
| Exists-forall normal form requires more Lean infrastructure than estimated | M | M | The normal form is a finite data structure (list of point types + interval types). Reuse existing `NormalForm` from the EF games framework where possible. Start with concrete Lean types, not abstract categorical constructions. |
| Negation closure proof (Lemma 5.1) is combinatorially complex -- 3 cases, nested induction on n | H | M | Follow the paper's proof structure faithfully. The 3 cases decompose cleanly. Use `Fintype` enumeration for the finite case splits. The induction on n (number of interval segments) is well-founded. |
| Prior-UZ relativization of the INF formula is subtler than expected | M | L | Prior-UZ gives `inf` as an attained minimum (actual first occurrence), which is simpler than the general Dedekind case (where inf may be a limit point, requiring the K+ disjunct in formula 5.2). The Prior case eliminates the limit-point sub-case entirely. |
| Connecting Rabinovich's FOMLO formulas to the existing `MonadicFormula sig` type | M | M | Both represent monadic first-order formulas over a linear order. The translation is syntactic. Use `SemanticBridge.lean` patterns from the existing Separation infrastructure. |
| Large code volume (estimated 3000-5000 lines) exceeds single-phase capacity | H | H | Decompose into 7 phases of 1-2 hours each. Each phase produces independently verifiable artifacts. Use `sorry` stubs at phase boundaries and fill in subsequent phases. |
| Existing `KampTranslation.lean` and Separation infrastructure are incomplete / blocked | L | L | Those files address a different approach (separation theorem). This plan creates new files under `Kamp/` that are independent. Reuse only formula-list helpers (`formula_conjList`, `formula_disjList`, `atom_literal`). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2, 3 | 1 |
| 4 | 4 | 2, 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 0: Literature Verification Gate [NOT STARTED]

**Goal**: Confirm that every use of Dedekind completeness in Rabinovich 2014 Section 5 reduces to computing first/last occurrences of TL-definable sets, and that `semantic_prior_UZ` provides a suitable replacement.

**Tasks**:
- [ ] Read Rabinovich PDF pages 7-11 (Section 5) systematically, marking every invocation of chain completeness
- [ ] Verify that Lemma 5.3's INF formula (equation 5.2) is the sole completeness use: `INF(z_0, r_0, z_1, P_1) := z_0 < r_0 < z_1 AND (forall y)_{>z_0}^{<r_0} not P_1(y) AND (P_1(r_0) OR K+(P_1)(r_0))`
- [ ] Verify that `K+(P_1)(r_0)` (= "P_1 holds at the next occurrence from above") is TL-definable as `not(True Until (not P_1))(r_0)` -- this is the Box/Henceforth operator
- [ ] Confirm that for Prior structures, `semantic_prior_UZ` with `psi = P_1` gives: if P_1 holds somewhere above z_0, then the first P_1 point r_0 exists, P_1(r_0) holds (not just K+), and not-P_1 holds on (z_0, r_0). This eliminates the K+ disjunct -- the Prior case is simpler.
- [ ] Confirm that Corollary 5.4 and the full Lemma 5.1 proof use completeness only via Lemma 5.3 (transitively through the INF formula)
- [ ] Document the verification result in the plan file as a status annotation on this phase

**HARD GATE**: If any completeness use in Section 5 does NOT reduce to first/last occurrences of a TL-definable set, this plan is [BLOCKED]. Fall back to Path B (documented in research report 08).

**Timing**: 1 hour

**Depends on**: none

**Files to modify**: None (read-only verification)

**Verification**:
- A written confirmation (as a phase status update in this plan) that the gate passes
- If the gate fails, the plan status changes to [BLOCKED] with a documented reason

---

### Phase 1: Exists-Forall Normal Form Types and Core Lemmas [NOT STARTED]

**Goal**: Define the exists-forall normal form (Rabinovich Def 3.1), prove closure under conjunction, variable projection (Lemma 3.2), and existential quantification (Lemma 3.4).

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean`
- [ ] Define `PointType` as a quantifier-free monadic formula (or reuse `NormalForm sig 0 1` as the depth-0 NF type from existing infrastructure)
- [ ] Define `IntervalType` as a quantifier-free monadic formula (the "beta" in Rabinovich: what holds along every point in an interval)
- [ ] Define `ExistsForallFormula` (Def 3.1): a structure containing
  - `n : Nat` -- number of existentially chosen witness points
  - `k : Nat` -- index of the free variable among z_0, ..., z_m (m = number of free variables)
  - `point_types : Fin (n + 1) -> PointType` -- alpha_j at each witness point
  - `interval_types : Fin (n + 2) -> IntervalType` -- beta_j along each interval
  - `ordering : ...` -- ordering constraints on witness points relative to free variables
- [ ] Define semantic evaluation `ef_eval` for exists-forall formulas on `OrderedMonadicStructure sig`
- [ ] Define `VExistsForall` as "equivalent to a disjunction of exists-forall formulas"
- [ ] Prove Lemma 3.2(1): conjunction of two exists-forall formulas is V-exists-forall (by merging witness sequences and taking the product of constraints)
- [ ] Prove Lemma 3.2(2): every exists-forall formula is equivalent to a conjunction of exists-forall formulas with at most 2 free variables. This is the key variable-capping result -- no arity escalation.
- [ ] Prove Lemma 3.2(3): existential quantification of an exists-forall formula is exists-forall (trivial: fold the quantified variable into the witness sequence)
- [ ] Prove Lemma 3.4: V-exists-forall formulas are closed under disjunction, conjunction, and existential quantification (follows from 3.2)
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF`

**Timing**: 2 hours (estimated 400-600 lines)

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean` -- create new

**Verification**:
- `lake build` succeeds on the new file
- `lean_verify` on key lemmas shows no sorryAx

---

### Phase 2: Translation to Temporal Logic (Proposition 3.5) [NOT STARTED]

**Goal**: Prove that every V-exists-forall formula with one free variable is equivalent to a TL(Until, Since) formula. This is the core translation from interval decompositions to nested Until/Since.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Translation.lean`
- [ ] Import `ExistsForallNF.lean` and the existing `Formula` type infrastructure
- [ ] Define the translation function `ef_to_temporal`: given an exists-forall formula with the free variable at position k among n witness points:
  - Right part: `A_k AND (B_{k+1} Until (A_{k+1} AND (B_{k+2} Until ... (A_n AND Box B_{n+1})...)))`
  - Left part: `A_k AND (B_k Since (A_{k-1} AND (B_{k-1} Since ... (A_0 AND Henceforth-past B_0)...)))`
  - Result: conjunction of right and left parts
- [ ] Reuse `formula_conjList`, `formula_disjList` from `KampTranslation.lean`
- [ ] Prove `ef_to_temporal_correct`: semantic correctness of the translation on any `OrderedMonadicStructure sig`
  - Forward: if the exists-forall formula holds (with witnesses x_0 < ... < x_n), then the temporal formula holds (Until witnesses are exactly x_{k+1}, ..., x_n; Since witnesses are x_{k-1}, ..., x_0)
  - Backward: if the temporal formula holds, extract the Until/Since witnesses and verify they satisfy the exists-forall constraints
- [ ] For V-exists-forall formulas: the translation is the disjunction of translations of each disjunct. Prove correctness.
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.Translation`

**Timing**: 2 hours (estimated 400-600 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Translation.lean` -- create new

**Verification**:
- `lake build` succeeds
- `lean_verify ef_to_temporal_correct` shows no sorryAx

---

### Phase 3: Prior INF Formula and First-Occurrence Lemma [NOT STARTED]

**Goal**: Prove that on Prior structures, the INF formula (Rabinovich 5.2) is V-exists-forall, replacing Dedekind completeness with `semantic_prior_UZ`. This is the single point where the Prior restriction matters.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean`
- [ ] Import `ExistsForallNF.lean` and `PriorExpressiveness.lean` (for `semantic_prior_UZ`)
- [ ] State and prove the Prior INF lemma: on structures satisfying `semantic_prior_UZ`, if a TL-definable predicate P_1 holds somewhere in (z_0, z_1), then the first occurrence r_0 exists with:
  - `z_0 < r_0 < z_1` (or `r_0 = z_0` if P_1 holds at z_0)
  - `P_1(r_0)` holds (NOT just K+(P_1) -- the Prior case gives actual attainment)
  - `not P_1(y)` for all y in (z_0, r_0)
- [ ] Show that the Prior INF formula is definable as a V-exists-forall formula (in the expansion by TL predicates)
  - On Prior structures, `INF(z_0, r_0, z_1, P_1)` simplifies to: `z_0 < r_0 < z_1 AND (forall y)_{>z_0}^{<r_0} not P_1(y) AND P_1(r_0)` -- no K+ disjunct needed
  - This is already in exists-forall form (r_0 is the single witness point, not-P_1 is the interval type, P_1 is the point type)
- [ ] Prove the dual: last-occurrence (sup) for `semantic_prior_SZ`
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF`

**Timing**: 1.5 hours (estimated 200-400 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean` -- create new

**Verification**:
- `lake build` succeeds
- `lean_verify` on the Prior INF lemma shows no sorryAx

---

### Phase 4: Negation Closure on Prior Structures (Prop 4.2 Relativized) [NOT STARTED]

**Goal**: Prove that the negation of 2-variable exists-forall formulas is V-exists-forall over Prior structures. This is Rabinovich's Proposition 4.2 relativized from Dedekind completeness to `semantic_prior_UZ/SZ`.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean`
- [ ] Import `ExistsForallNF.lean`, `PriorINF.lean`
- [ ] Prove Lemma 5.3 (base case, all beta_i = True) relativized to Prior structures:
  - `not (exists x_1 ... x_n in (z_0, z_1)) AND P_i(x_i)` is V-exists-forall on Prior structures
  - By induction on n:
    - Base: `not (exists x_1)_{>z_0}^{<z_1} P_1(x_1)` is `(forall y)_{>z_0}^{<z_1} not P_1(y)` -- already exists-forall
    - Step: if P_1 occurs in (z_0, z_1), use Prior INF to find the first P_1 point r_0. Split into sub-cases on whether r_0 = z_0 or r_0 in (z_0, z_1). In each sub-case, reduce to a negation with fewer predicates (induction).
- [ ] Prove Corollary 5.4 relativized: `not (exists z)_{>z_0}^{<z_1} [alpha_0, ..., alpha_n](z_0, z)` is V-exists-forall on Prior structures
  - Define F_n := alpha_n, F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)
  - Use: [alpha_0, ..., alpha_n](z_0, z) holds iff F_0(z_0) holds and witnesses exist in (z_0, z_1) with F_i at each
  - Apply Lemma 5.3 to the negation
- [ ] Prove Lemma 5.1 (full negation closure) relativized:
  - `not [alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1)` is V-exists-forall on Prior structures
  - By induction on n (number of interval segments):
    - 3 cases per Rabinovich's proof structure (pp. 9-11):
      - Case 1: `not alpha_0(z_0)` or `K+(not beta_1)(z_0)` -- endpoint failure
      - Case 2: `alpha_0(z_0)` and `beta_1` holds along (z_0, z_1) -- guard succeeds but no witness
      - Case 3: splitting at a definable infimum point, using Prior INF
    - For each case, construct V-exists-forall formulas using the A_i^-, A_i^+ decomposition
    - The inductive hypothesis gives V-exists-forall for negations of shorter formulas
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure`

**Timing**: 2 hours (estimated 600-1000 lines)

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- create new

**Verification**:
- `lake build` succeeds
- `lean_verify` on Lemma 5.1 relativized shows no sorryAx

---

### Phase 5: FO-to-Temporal Theorem for Prior Structures [NOT STARTED]

**Goal**: Prove Proposition 4.3 relativized (every FO formula is V-exists-forall on Prior structures) and Theorem 4.4 relativized (every FO formula with one free variable has a TL(U,S) equivalent on Prior structures). Wire this into `US_expressively_complete_over_prior`.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
- [ ] Import `NegationClosure.lean`, `Translation.lean`, and `PriorExpressiveness.lean`
- [ ] Prove Proposition 4.3 relativized: every `MonadicFormula sig n` is equivalent to a V-exists-forall formula over Prior structures
  - By structural induction on the formula:
    - Atomic (P(x_i), x_i < x_j, x_i = x_j): immediate -- these are exists-forall
    - Disjunction: V-exists-forall is closed under disjunction (Lemma 3.4)
    - Negation: Reduce to 2-variable case by Lemma 3.2(2), then apply Prop 4.2 relativized (Phase 4)
    - Existential: Lemma 3.4 closure under existential quantification
- [ ] Prove Theorem 4.4 relativized: for every `MonadicFormula sig 1` (one free variable), there exists a `Formula` using only U and S that is equivalent on Prior structures
  - By Prop 4.3, the formula is V-exists-forall
  - By Prop 3.5 (Phase 2), the V-exists-forall formula translates to TL(U,S)
- [ ] Define `kamp_prior_expressive_completeness` with the same type signature as `US_expressively_complete_over_prior`:
  ```lean
  noncomputable def kamp_prior_expressive_completeness
      {sig : MonadicSignature}
      (atomMap : Formula -> sig.preds)
      (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p)
      (psi : MonadicFormula sig 1) :
      { A : Formula //
        forall (M : OrderedMonadicStructure sig)
          (_h_prior_UZ : semantic_prior_UZ M atomMap)
          (_h_prior_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          eval M (fun _ => t) psi <->
          temporal_truth M atomMap t A }
  ```
- [ ] Prove this theorem by composing Prop 4.3 + Prop 3.5
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior`

**Timing**: 1.5 hours (estimated 300-500 lines)

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- create new

**Verification**:
- `lake build` succeeds
- `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- The type signature matches `US_expressively_complete_over_prior` exactly

---

### Phase 6: Wire into PriorExpressiveness and Final Verification [NOT STARTED]

**Goal**: Replace the proof body of `US_expressively_complete_over_prior` with a call to `kamp_prior_expressive_completeness`, making it sorry-free. Verify the full build. Update ROADMAP.

**Tasks**:
- [ ] Add import `import Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` to `PriorExpressiveness.lean`
- [ ] Replace the proof body of `US_expressively_complete_over_prior` (lines 382-393):
  - OLD: calls `stavi_expressive_completeness` then `flatten_stavi_correct_prior`
  - NEW: calls `kamp_prior_expressive_completeness` directly
  - The type signature remains unchanged -- downstream consumers unaffected
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.PriorExpressiveness` to verify the wiring
- [ ] Run `lake build` (full project) to verify no downstream breakage
- [ ] Verify with `#print axioms US_expressively_complete_over_prior` that it no longer depends on `sorryAx` (via `lean_verify` or `lake env lean` + `#print axioms`)
- [ ] Verify that `gap_prior_UZ_contradiction` (GoodStructuresModelSurgery.lean) is now sorry-free down to its own direct sorries (not the Stavi chain)
- [ ] Add a docstring to `US_expressively_complete_over_prior` noting the proof now uses Kamp/Rabinovich 2014 rather than Stavi connectives
- [ ] Add a comment block at the top of `StaviCompleteness.lean` documenting the 3 sorry sites as an open generalization:
  ```
  /-! ## Open Generalization: Stavi Expressive Completeness
  
  The three sorry sites at lines 2405, 2487, 2857 block `stavi_expressive_completeness`
  (GHR93 Theorem 9.3.1: {U,S,U',S'} is expressively complete for ALL linear orders).
  
  For the completeness chain, this general result is bypassed by
  `kamp_prior_expressive_completeness` (Kamp/Rabinovich 2014), which proves {U,S}
  expressive completeness directly for Prior structures. The general Stavi result
  remains a documented open formalization target.
  
  Known blockers:
  - Sorry site 3 (line 2857, `nf_exist_sf_guarded_backward`) is mathematically FALSE
    as stated (independent verification by 2 research teammates, report 08).
  - Sorry sites 1-2 (lines 2405, 2487) require n-variable existential transfer which
    has no tractable formalization path within the current NF framework.
  -/
  ```
- [ ] Update ROADMAP.md: mark the Stavi sorry chain as bypassed, note that `US_expressively_complete_over_prior` is sorry-free via Kamp/Rabinovich

**Timing**: 1 hour

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` -- modify proof body + add import
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- add documentation comment
- `specs/ROADMAP.md` -- update status of Stavi chain and US_expressively_complete_over_prior

**Verification**:
- `lake build` succeeds (full project, clean)
- `#print axioms US_expressively_complete_over_prior` shows no `sorryAx`
- `#print axioms gap_prior_UZ_contradiction` -- verify the Stavi chain dependency is eliminated (remaining sorries, if any, are from the model surgery chain, not the Stavi chain)
- No changes to the type signature of `US_expressively_complete_over_prior`

---

## Testing & Validation

- [ ] Phase 0 gate: documented verification that Rabinovich Section 5 uses completeness only via the INF formula
- [ ] Each phase: `lake build` on the new/modified module succeeds
- [ ] Phase 5: `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- [ ] Phase 6: `lake build` (full project) succeeds
- [ ] Phase 6: `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- [ ] Phase 6: type signature of `US_expressively_complete_over_prior` unchanged (diff shows only proof body + import changes)
- [ ] Phase 6: downstream consumers (`gap_prior_UZ_contradiction`, `no_gaps_discrete_model_surgery`, etc.) still compile and their sorry status is unchanged or improved

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean` -- exists-forall normal form types and closure lemmas (~400-600 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Translation.lean` -- translation to temporal logic (~400-600 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean` -- Prior first-occurrence lemma (~200-400 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- negation closure on Prior structures (~600-1000 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- main theorem + wiring (~300-500 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` -- modified proof body
- `specs/ROADMAP.md` -- updated status

**Estimated total new Lean code**: 1900-3100 lines across 5 new files

## Rollback/Contingency

**If the approach fails**:
1. Delete the `Kamp/` directory entirely -- it is self-contained with no external consumers until Phase 6
2. Revert the `PriorExpressiveness.lean` change (one-line proof body swap)
3. Fall back to Path B (GHR-faithful in-architecture): projection lemma + master lemma `nf_tuple_agreement_from_adjacent_pairs` + decomposition-style formula replacement, as documented in research report 08

**If individual phases block**:
- Phases 1-4 are independent of the existing sorry chain. If blocked, mark the specific lemma with `sorry` and document the blocker. Subsequent phases can proceed with sorry stubs.
- Phase 5 requires all of Phases 1-4 to be sorry-free for the final theorem to be sorry-free.
- Phase 6 can be executed partially: the import and proof body change can be made even if some intermediate sorry remains, producing a cleaner sorry chain (Kamp sorry instead of Stavi sorry).

**Partial progress value**:
Even if the plan only completes Phases 0-4, the infrastructure is valuable:
- The exists-forall normal form and translation are reusable for the Dedekind-complete instance (canonical Kamp's theorem for CSLib)
- The Prior INF lemma is independently useful
- The negation closure proof is the hardest component and has value as a standalone result
