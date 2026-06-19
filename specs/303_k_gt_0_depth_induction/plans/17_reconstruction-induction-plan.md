# Implementation Plan: Close PriorComposition Sorry via Reconstruction-Depth Induction

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [IN PROGRESS] (Phases 1-7 completed, Phases 8-10 not started)
- **Effort**: 22 hours (7-9 dispatch sessions)
- **Dependencies**: None (k=0 infrastructure is sorry-free, KampBypass.lean is sorry-free)
- **Research Inputs**: reports/09_interval-splitting-mapping.md, reports/11_vea-negation-closure-design.md, reports/12_fraisse-game-analysis.md, reports/13_literature-grounded-proof-strategy.md, reports/15_charpart-threading-design.md, reports/16_strong-d-induction-research.md, reports/18_literature-alignment-analysis.md, reports/19_rabinovich-proof-extraction.md
- **Artifacts**: plans/17_reconstruction-induction-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v17 replaces the blocked Phases 8-9 from plan v16 with three new phases (8-10) grounded in the literature-aligned inner depth cascade strategy identified by reports 18 and 19. The v16 blocker was definitive: the zone-3 proof strategy was misaligned with the literature. Prior-UZ/SZ was incorrectly proposed for top-level witness PLACEMENT. Reports 18-19 show the correct approach: the witness w_nf comes directly from ih_strong quantifier unfolding, and the depth gap from K to K+1 is bridged by a secondary "reconstruction depth" induction descending from K+1 to 0 inside the quantifier part.

Current state (after Phases 6-7): KampBypass.lean is sorry-free (0 sorry). PriorComposition.lean has 2 sorry at lines 312, 317 (zone-3 quantifier parts of `prior_nonconstenv_2var_agree_until/since` under strong induction -- unified from 4 sorry). NfCharFormula.lean critical path is sorry-free (1 sorry remains in deprecated dead-code `nf_2var_exist_formula_prior`).

### Research Integration

- Report 18 (literature-alignment-analysis.md): Confirmed depth-based induction is aligned but INCOMPLETE. Identified that ih_strong quantifier unfolding directly provides w_nf with depth-K 3-var full agreement, placing w_nf in zone 3 via atom preservation of order relations. Identified the depth gap cascade: K -> K-1 -> ... -> 0, terminating at purely atomic. Estimated ~1200-1800 lines for full resolution.
- Report 19 (rabinovich-proof-extraction.md): Extracted Rabinovich's full proof architecture. Confirmed the Lean formalization's depth induction is compatible with Rabinovich's witness-count induction. Identified that the secondary "reconstruction depth" induction on d (from 0 up to K+1) inside the quantifier part is the correct mechanism, corresponding to Rabinovich's recursive interval-splitting reinterpreted as depth descent.
- Report 16 (strong-d-induction-research.md): Confirmed strong D-induction necessary. Identified NfCharFormula.lean:651 independent fix (completed in Phase 6).
- Report 15 (charpart-threading-design.md): Established CharPart-threading architecture (Phase 5 completed).
- Reports 09, 11, 12, 13: Established GeneralExistPartOrdered and BetweenZoneExistPart are FALSE; zone decomposition + Prior-UZ/SZ is the correct approach (for the base case only).

## Goals & Non-Goals

**Goals**:
- Implement depth-0 Prior density lemma for multi-variable atomic existential transfer
- Make `nf_extend_bwd` accessible from PriorComposition.lean
- Implement the inner reconstruction-depth induction helper lemma
- Close all 2 sorry in PriorComposition.lean (lines 312, 317)
- Verify completeness chain through completeness_discrete

**Non-Goals**:
- Modifying KampBypass.lean (already sorry-free)
- Modifying KampMutualInduction.lean (CharPart flows through existing param chain)
- Modifying k=0 infrastructure (KampBypassCore/Until/Since, ~4400 lines, all sorry-free)
- Proving GeneralExistPartOrdered or BetweenZoneExistPart (both FALSE)
- Proving nonconstenv_exist_transfer_general (FALSE)
- Using simple K-induction (circular)
- Using Prior-UZ/SZ for top-level witness placement (witness comes from ih_strong)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Depth-0 atomic existential density on Prior structures is harder than expected | H | M | Prototype at fixed arity (n=4) first. Use Prior-UZ/SZ zone decomposition to place witness in each zone separately. Factor into helper lemmas per zone. |
| Inner reconstruction induction has Fin/env management complexity at arbitrary arity | H | M | Use explicit Fin.cons constructions matching existing patterns. Factor out env-manipulation helpers. May need lemmas for Fin.cons associativity. |
| nf_extend_bwd reproduction introduces type mismatches | L | L | The theorem is 8 lines. Can use `protected` visibility change instead of reproduction if simpler. |
| Heartbeat limits exceeded by combined outer+inner induction | M | H | Factor zone-3 proof into 3+ private helpers. Use `set_option maxHeartbeats 800000` per helper. Split large proofs across multiple lemmas. |
| K=0 base case for outer induction needs separate treatment | M | M | At K=0: depth-1 3-var quantifier part is depth-0 4-var (purely atomic). Prior density lemma from Phase 8 handles this directly. |
| Atom preservation of order relations through NF agreement may require explicit lemma | L | M | Extract `atom_agree_implies_order` helper from existing `nf_agreement_from_shared_nf`. The depth-K 3-var agreement preserves all atoms including order atoms. |

## Approaches Ruled Out

The following approaches have been confirmed FALSE, unprovable, or circular across 10+ dispatch sessions. DO NOT re-attempt any of these:

- **GeneralExistPartOrdered**: FALSE at all depths (report 09, confirmed by counterexample)
- **BetweenZoneExistPart**: FALSE (report 09)
- **nonconstenv_exist_transfer_general**: FALSE (Phase 6 v15 blocker)
- **depth0_3var_exist_transfer_until/since**: Unprovable as standalone lemma
- **exist_transfer_3var_nonconstenv**: Unprovable without inner cascade
- **zone_compatible_witness_bwd/fwd**: Unprovable (no zone guarantee from nf_extend alone without atom preservation argument)
- **Simple K-induction**: Circular (zone-3 at depth D requires theorem at D-1, not provided by simple induction)
- **Prior-UZ/SZ for top-level zone-3 witness placement**: WRONG (reports 18-19). Witness comes from ih_strong quantifier unfolding. Prior-UZ gives correct zone but wrong NF type; nf_extend gives correct NF type AND correct zone (via atom preservation).
- **Direct cross_extend_bwd_1var as zone-3 witness**: Gives single-bound (w > t' or w < x'), not dual-bound (t' < w < x')
- **Depth induction with arity explosion without inner cascade**: Arity grows unboundedly without the reconstruction induction to terminate at depth 0
- **generalExistPart_from_classical at the needed depth**: Circular -- requires depth-(K+1) 3-var agreement as precondition, which is the conclusion

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4, 5 | -- (all completed) |
| 2 | 6 | 5 (completed) |
| 3 | 7 | 6 (completed) |
| 4 | 8 | 7 (completed) |
| 5 | 9 | 8 |
| 6 | 10 | 9 |

Phases within the same wave can execute in parallel.

### Phase 1: Remove GeneralExistPartOrdered and Simplify Mutual Induction [COMPLETED]

**Goal**: Delete the false GeneralExistPartOrdered definition, its sorry proofs, and revert kamp_mutual_induction to a 2-conjunct form (CharPart + ExistPart).

**Completed**: 2026-06-17

---

### Phase 2: Remove ih_general_exist from existPart_succ_n1_bypass [COMPLETED]

**Goal**: Remove the ih_general_exist parameter and restructure k>0 Until/Since zones to encode quantifier conditions without it.

**Completed**: 2026-06-17

---

### Phase 3: Research and Design V-EA Negation Closure [COMPLETED]

**Goal**: Research Rabinovich's V-EA negation closure (Lemma 5.1) and design the Lean formalization needed to close the between-zone sorry from Phase 2.

**Completed**: 2026-06-17

---

### Phase 4: Implement Enriched Bracket-Formula Encoding [COMPLETED]

**Goal**: Replace top/bot quant_conj encoding with Prior composition transfer. Make KampBypass.lean sorry-free.

**Completed**: 2026-06-17

---

### Phase 5: Delete FALSE Lemmas, Add CharPart Parameters, Update Call Sites [COMPLETED]

**Goal**: Restructure PriorComposition.lean by deleting 3 FALSE/unprovable lemmas, adding CharPart parameters, updating call sites.

**Completed**: 2026-06-17

---

### Phase 6: NfCharFormula Quick Fix [COMPLETED]

**Goal**: Fix the 3 sorry in NfCharFormula.lean:651 by restructuring argument passing to use `nf_2var_exist_formula_prior_filled` instead of passing `sorry` as `ih_char`, `ih_exist`, and `ih_all_char` arguments.

**Tasks**:
- [x] Read NfCharFormula.lean around line 651 to understand the current sorry structure
- [x] Identify the call to `existPart_succ_n1_bypass` with 3 sorry arguments
- [x] Restructure `nf_characterizable_temporal_prior_classical` (or the surrounding context) to:
  - Extract ExistPart from `kamp_mutual_induction` via `nf_2var_exist_formula_prior_filled` (KampMutualInduction.lean:425)
  - Pass the extracted ExistPart as the correct argument instead of sorry
  - OR restructure `nf_2var_exist_formula_prior` to take ih_char/ih_exist/ih_all_char as additional parameters
  *(deviation: altered -- added `ih_exist_2var` param to `nf_characterizable_temporal_prior_classical` instead of modifying `nf_2var_exist_formula_prior`; also inlined `nf_2var_exist_depth0_tl` in `existPart_zero` to break sorry propagation)*
- [x] Verify: `lake build NfCharFormula` succeeds *(deviation: 1 sorry remains in dead-code `nf_2var_exist_formula_prior` k+2 branch, but `nf_characterizable_temporal_prior_classical` is sorry-free)*
- [x] Verify: `lake build KampBypass` still succeeds with 0 sorry

**Sorry budget**: Reduced 3 sorry from critical path. `nf_characterizable_temporal_prior_classical`, `charPart_succ`, `existPart_zero` are now sorry-free. `nf_2var_exist_formula_prior` retains 1 sorry in dead-code k+2 branch (not reachable from completeness chain).

**Timing**: 1 hour (1 dispatch session)

**Completed**: 2026-06-18

**Depends on**: 5 (completed)

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- added `ih_exist_2var` param, removed call to sorry'd function
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- updated `charPart_succ` call, inlined `nf_2var_exist_depth0_tl` in `existPart_zero`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- added import, provided `ih_exist_2var` from `nf_2var_exist_formula_prior_filled`

**Verification (completed)**:
- `lake build` succeeds (full project, 1759 jobs)
- `lean_verify charPart_succ`: no sorryAx
- `lean_verify existPart_zero`: no sorryAx
- `lean_verify nf_characterizable_temporal_prior_classical`: no sorryAx
- `lake build KampBypass` succeeds with 0 sorry

---

### Phase 7: Strong D-Induction Scaffolding [COMPLETED]

**Goal**: Replace simple `induction K` with `Nat.strong_induction_on D` (where D=K+2) in PriorComposition.lean. Restructure the main theorems to be parametric in D. The IH provides the theorem at all depths < D.

**Tasks**:
- [x] Factor out `strong_prior_nonconstenv_2var_agree_until_aux` with explicit D parameter: *(deviation: skipped -- separate aux theorem unnecessary; `Nat.strong_induction_on K` applied directly inside the existing theorem body is cleaner and type-checks without wrapper)*
- [x] Implement the outer wrapper using `Nat.strong_induction_on`:
  ```lean
  theorem prior_nonconstenv_2var_agree_until ... := by
    exact Nat.strong_induction_on K (fun K ih_strong nf => by ...)
  ```
  *(deviation: altered -- used strong induction on K directly rather than on D=K+2; this is equivalent since `ih_strong : forall m < K, theorem_at_(m+2)` covers all depths 2..K+1)*
- [x] Inside the aux theorem, split into atom part (reuse existing `nonconstenv_atom_agree_until` -- sorry-free) and quantifier part (sorry placeholder for Phase 8)
- [x] Apply IH at D-1 to get depth-(D-1) 2-var at [x,t]/[x',t'] (from `nf_agreement_monotone` weakening h_x, h_t from depth D to D-1) *(deviation: deferred to task Phase 8 -- IH is now available in context via ih_strong; actual application happens when closing sorry)*
- [x] Mirror all restructuring for `prior_nonconstenv_2var_agree_since`
- [x] Verify: `lake build PriorComposition` succeeds (2 sorry remain -- consolidated from 4 because strong induction unifies K=0/K=succ cases)
- [x] Verify: `lake build KampBypass` still succeeds with 0 sorry

**Sorry budget**: 2 (reduced from 4; strong induction unifies K=0 and K=succ K' into single case per theorem, consolidating 2 sorry per theorem into 1).

**Timing**: 30 minutes (1 dispatch session)

**Completed**: 2026-06-19

**Depends on**: 6

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- restructured induction from simple `induction K` to `Nat.strong_induction_on K`

**Key patterns used**:
- `Nat.strong_induction_on` usage: matches KampMutualInduction.lean:410 pattern
- Lambda absorbs the nf quantifier: `fun K ih_strong nf => by` avoids variable shadowing
- `nf_agreement_monotone` not needed in scaffolding phase (will be used in Phase 8 to invoke IH)
- char_correct bound: `d <= K+1 = D-1` covers all needed depths

**Verification (completed)**:
- `lake build PriorComposition` succeeds (988 jobs, warnings only)
- `lake build KampBypass` succeeds (1247 jobs) with 0 sorry
- `grep -c sorry PriorComposition.lean` returns exactly 2 (one per main theorem, inside strong induction)
- Both sorry positions have `ih_strong : forall m < K, ...` available in context

---

### Phase 8: Depth-0 Prior Density Lemma [NOT STARTED]

**Goal**: Prove that on Prior structures, depth-0 multi-variable atomic existential transfer holds. This is the base case for the reconstruction induction. At depth 0, NF evaluation is purely atomic (order relations + predicate values). Given 1-var agreements at all relevant points, existential witnesses can be found using Prior-UZ/SZ density.

**Literature Fidelity**: This phase follows the proof strategy from:
- Report 18 (literature-alignment-analysis.md): Section 11 (the cascade terminates at depth 0)
- Report 19 (rabinovich-proof-extraction.md): Part 4 (Lemma 5.3 -- the base case)
- Rabinovich 2014, Lemma 5.3 (base case: all beta_i = True)

DO NOT DEVIATE from the literature-aligned strategy. Specifically:
- DO NOT use Prior-UZ/SZ for top-level witness placement (witness comes from ih_strong)
- DO NOT attempt depth-based induction with arity explosion
- DO NOT introduce novel proof techniques not grounded in reports 18-19
- If a step fails, RE-READ the reports before trying alternatives
- Any deviation must be flagged with *(deviation: ...)* annotation

**Tasks**:
- [ ] Define the depth-0 atomic existential transfer statement:
  ```lean
  /-- At depth 0, NF evaluation is purely atomic. Given matched atom profiles
      at all env components (from 1-var NF agreements) and Prior-UZ/SZ density,
      existential witnesses with matching atoms can be found in each zone. -/
  private theorem depth0_exist_transfer
      (h_UZ : semantic_prior_UZ M) (h_SZ : semantic_prior_SZ M)
      (h_UZ' : semantic_prior_UZ N) (h_SZ' : semantic_prior_SZ N)
      (h_1var : forall i, depth-(K+2) 1-var agreement at envM i / envN i)
      (h_orders : atom agreement on order atoms between envM / envN)
      (chi : NormalForm sig 0 (n+1)) :
      (exists v, nf_eval_nf M 0 (n+1) (Fin.cons v envM) chi)
      <-> (exists v', nf_eval_nf N 0 (n+1) (Fin.cons v' envN) chi)
  ```
- [ ] Implement zone decomposition for the depth-0 witness:
  - Zone analysis: classify where the M-witness v sits relative to env components
  - For each zone: use `semantic_prior_UZ` or `semantic_prior_SZ` to find v' in N with matching predicates in the same zone
  - Atom part: predicates at v' match because 1-var NF agreements give predicate agreement; order atoms match because v' is in the same zone
- [ ] Factor out `pred_agree_from_1var_agree` helper: extract from depth-K 1-var NF agreement that predicates match at the two points
- [ ] Factor out `depth0_nf_eval_iff_atoms` helper: at depth 0, `nf_eval_nf` is determined entirely by atom evaluation (no quantifier part)
- [ ] Implement `nf_agreement_monotone` weakening from depth K+2 to depth 0 for 1-var agreements
- [ ] Verify: the depth-0 lemma compiles and is usable inside PriorComposition.lean

**Sorry budget**: 0 for this phase (self-contained lemma, must be sorry-free).

**Timing**: 4-5 hours (2 dispatch sessions)

**Depends on**: 7 (completed)

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- new section for depth-0 density lemma (or new file `PriorDensity.lean` if the lemma exceeds ~200 lines)

**Key infrastructure**:
| Name | Location | Purpose |
|------|----------|---------|
| `semantic_prior_UZ` | PriorDefs.lean:22 | First occurrence above t |
| `semantic_prior_SZ` | PriorDefs.lean:33 | Last occurrence below t |
| `nf_agreement_monotone` | NormalForm.lean:339 | Depth weakening |
| `nf_eval_nf` at depth 0 | NormalForm.lean:198 | Purely atomic: atoms only, no quantifiers |
| `pred_agree_cross` | (may need extraction) | Predicate agreement from 1-var NF agreement |
| `char_fn` | PriorComposition.lean | Temporal formula characterizing a 1-var NF type |

**Verification**:
- `lake build PriorComposition` (or `lake build PriorDensity`) succeeds
- `lean_verify depth0_exist_transfer` -- no sorryAx
- `lake build KampBypass` still succeeds with 0 sorry

---

### Phase 9: nf_extend_bwd Accessibility + Inner Cascade Infrastructure [NOT STARTED]

**Goal**: (1) Make `nf_extend_bwd` accessible from PriorComposition.lean. (2) Implement the inner reconstruction-depth induction as a helper lemma that bridges the depth gap from K to K+1 in the zone-3 quantifier part.

**Literature Fidelity**: This phase follows the proof strategy from:
- Report 18 (literature-alignment-analysis.md): Sections 4-5 (inner depth induction), Section 7 (recommended approach)
- Report 19 (rabinovich-proof-extraction.md): Section 7.5-7.9 (breaking circularity via secondary induction)
- Rabinovich 2014, Lemma 5.1 proof (recursive interval splitting)

DO NOT DEVIATE from the literature-aligned strategy. Specifically:
- DO NOT use Prior-UZ/SZ for top-level witness placement (witness comes from ih_strong)
- DO NOT attempt depth-based induction with arity explosion
- DO NOT introduce novel proof techniques not grounded in reports 18-19
- If a step fails, RE-READ the reports before trying alternatives
- Any deviation must be flagged with *(deviation: ...)* annotation

**Tasks**:

**Task 9.1: nf_extend_bwd accessibility (~15 lines)**
- [ ] Make `nf_extend_bwd` from KampBypass.lean accessible. Options:
  - (a) Change visibility from `private` to `protected` in KampBypass.lean (~3 line change)
  - (b) Reproduce the key step locally in PriorComposition.lean (~15 lines). The theorem follows from `nf_characteristic_satisfies` + `nf_agreement_from_shared_nf` and is trivially reproducible.
- [ ] Verify the exposed/reproduced theorem is callable from PriorComposition.lean

**Task 9.2: Cascade infrastructure -- env construction helpers (~50 lines)**
- [ ] Implement `Fin.cons` manipulation helpers for building extended envs:
  - Given env : Fin n -> carrier, build extended env : Fin (n+1) -> carrier by prepending a witness
  - Prove that atom evaluation commutes with Fin.cons extension
  - Prove that order atoms in the extended env decompose into: orders among original components (preserved) + orders involving the new component (from zone placement)

**Task 9.3: Inner reconstruction induction (~250 lines)**
- [ ] Implement the inner reconstruction-depth induction lemma:
  ```lean
  /-- Given depth-K (n+1)-var full agreement at envM/envN (from the cascade
      of nf_extend_bwd from ih_strong), prove depth-(K+1) (n+1)-var agreement
      by building up from depth 0.
      
      The induction on d from 0 to K+1:
      - Base (d=0): purely atomic. From depth0_exist_transfer (Phase 8).
      - Step (d+1 from d): atoms from NF agreement (independent of depth).
        Quantifiers: for each chi at depth d and arity n+2,
        the existential transfer follows from the inner IH at d
        combined with nf_extend_bwd providing matched witnesses. -/
  private theorem reconstruction_depth_transfer
      {K : Nat} {n : Nat}
      (M : OrderedMonadicStructure sig) (envM : Fin (n+1) -> M.carrier)
      (N : OrderedMonadicStructure sig) (envN : Fin (n+1) -> N.carrier)
      (h_UZ : semantic_prior_UZ M) (h_SZ : semantic_prior_SZ M)
      (h_UZ' : semantic_prior_UZ N) (h_SZ' : semantic_prior_SZ N)
      -- 1-var agreements at all env components (depth K+2 or higher)
      (h_1var : forall i, nf_agreement M 1 (fun _ => envM i) N 1 (fun _ => envN i) (K+2))
      -- depth-K (n+1)-var full agreement (from nf_extend_bwd cascade)
      (h_K_agree : forall nf : NormalForm sig K (n+1),
        nf_eval_nf M K (n+1) envM nf <-> nf_eval_nf N K (n+1) envN nf)
      -- atoms match (from depth-K agreement, always holds)
      (h_atoms : forall a : AtomKind sig (n+1),
        atom_eval M envM a <-> atom_eval N envN a)
      (d : Nat) (hd : d <= K + 1) :
      forall nf : NormalForm sig d (n+1),
        nf_eval_nf M d (n+1) envM nf <-> nf_eval_nf N d (n+1) envN nf
  ```
- [ ] Implement the base case (d=0): invoke `depth0_exist_transfer` from Phase 8
- [ ] Implement the inductive step (d+1 from d):
  - Atoms: from h_atoms (independent of depth)
  - Quantifiers at depth d, arity n+2: need `(exists v, nf_eval M d (n+2) [v, envM] chi) <-> (exists v', nf_eval N d (n+2) [v', envN] chi)`
  - From h_K_agree at arity n+1 and nf_extend_bwd: for any v in M, exists v' in N with depth-(K-1) (n+2)-var agreement. The inner IH at d (d <= K) gives the upgrade from depth-(K-1) to depth-d at arity n+2.
  - At d = K+1: this gives depth-(K+1) (n+1)-var agreement, which is the target.
- [ ] Factor into private helpers if heartbeat limits require it

**Sorry budget**: 0 for this phase (the inner induction must be sorry-free).

**Timing**: 6-8 hours (2-3 dispatch sessions)

**Depends on**: 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- visibility change for nf_extend_bwd (if option a)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- inner cascade infrastructure

**Key infrastructure**:
| Name | Location | Purpose |
|------|----------|---------|
| `nf_extend_bwd` | KampBypass.lean:57 | General arity extension (private, needs exposure) |
| `nf_characteristic_satisfies` | NormalForm.lean:224 | M satisfies its own characteristic |
| `nf_agreement_from_shared_nf` | NormalForm.lean:291 | Unique NF implies agreement |
| `nf_agreement_monotone` | NormalForm.lean:339 | Depth weakening |
| `depth0_exist_transfer` | Phase 8 output | Base case for reconstruction induction |
| `Nat.strong_induction_on` | Lean core | Strong induction (for inner d induction) |

**Verification**:
- `lake build PriorComposition` succeeds
- `lean_verify reconstruction_depth_transfer` -- no sorryAx
- `lake build KampBypass` still succeeds with 0 sorry
- `grep -c sorry PriorComposition.lean` still returns exactly 2 (sorry not yet closed)

---

### Phase 10: Zone-3 Assembly + Since Mirror + End-to-End Verification [NOT STARTED]

**Goal**: Close both sorry in PriorComposition.lean by assembling the zone-3 proof from the infrastructure built in Phases 8-9, mirror for Since direction, and verify the full completeness chain end-to-end.

**Literature Fidelity**: This phase follows the proof strategy from:
- Report 18 (literature-alignment-analysis.md): Sections 7, 9, 11 (w_nf approach, concrete recommendation, summary)
- Report 19 (rabinovich-proof-extraction.md): Sections 7.7-7.8 (the corrected proof strategy)
- Rabinovich 2014, Lemma 5.1 / Proposition 4.2

DO NOT DEVIATE from the literature-aligned strategy. Specifically:
- DO NOT use Prior-UZ/SZ for top-level witness placement (witness comes from ih_strong)
- DO NOT attempt depth-based induction with arity explosion
- DO NOT introduce novel proof techniques not grounded in reports 18-19
- If a step fails, RE-READ the reports before trying alternatives
- Any deviation must be flagged with *(deviation: ...)* annotation

**Tasks**:

**Task 10.1: Zone-3 proof assembly for Until (~60 lines)**
- [ ] In `prior_nonconstenv_2var_agree_until`, at the sorry site (line 312):
  1. **Obtain w_nf from ih_strong**: At m=K-1 (when K >= 1), ih_strong gives depth-(K+1) 2-var agreement at [x,t]/[x',t']. Unfold its quantifier condition with chi3 = nf_characteristic M K 3 [w,x,t]. The M-side is witnessed by w. Get w_nf in N with nf_eval N K 3 [w_nf, x', t'] (nf_char M K 3 [w,x,t]). By `nf_agreement_from_shared_nf`: FULL depth-K 3-var agreement at [w,x,t]/[w_nf,x',t'].
  2. **Verify w_nf is in zone 3**: From depth-K 3-var agreement, atom preservation gives: order atom `w > t` in M implies `w_nf > t'` in N; order atom `w < x` in M implies `w_nf < x'` in N. So t' < w_nf < x'.
  3. **Prove nf_eval N (K+1) 3 [w_nf,x',t'] sub_nf**:
     - Atom part: from depth-K 3-var atom agreement + M's satisfaction of sub_nf. Done (atoms are depth-independent).
     - Quantifier part: apply `reconstruction_depth_transfer` from Phase 9 at d=K+1, n=3, with:
       - h_K_agree = the depth-K 3-var agreement at [w,x,t]/[w_nf,x',t']
       - h_1var = depth-(K+2) 1-var agreements at w/w_nf, x/x', t/t' (from h_x, h_t, and depth-K 3-var projections + nf_agreement_monotone)
       - The reconstruction induction bridges the gap from depth-K to depth-(K+1)
  4. **Close the sorry** with `exact ⟨w_nf, proof⟩`
- [ ] Handle the K=0 edge case: when K=0, ih_strong has no m < 0. At K=0, depth-1 3-var NF has purely atomic quantifier part (depth-0 4-var). The depth-0 density lemma from Phase 8 handles this directly.

**Task 10.2: Since mirror (~40 lines)**
- [ ] Mirror the zone-3 proof for `prior_nonconstenv_2var_agree_since` (line 317):
  - Same structure as Until with reversed order relations
  - Use `semantic_prior_SZ` instead of `semantic_prior_UZ` at depth-0 base case
  - Reverse zone definitions: x < w < t becomes x' < w_nf < t'
  - Apply same `reconstruction_depth_transfer` infrastructure

**Task 10.3: End-to-end verification**
- [ ] Run `lean_verify prior_nonconstenv_2var_agree_until` -- confirm no sorryAx
- [ ] Run `lean_verify prior_nonconstenv_2var_agree_since` -- confirm no sorryAx
- [ ] Run `lean_verify kamp_mutual_induction` -- confirm no sorryAx
- [ ] Run `lean_verify completeness_discrete` -- confirm no sorryAx
- [ ] Run full `lake build` -- confirm no regressions
- [ ] Verify sorry count across entire Kamp directory: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` -- 0 results (excluding comments and dead-code `nf_2var_exist_formula_prior`)
- [ ] Remove any dead imports or unused helper lemmas
- [ ] Update module docstring in PriorComposition.lean to reflect final proof strategy

**Sorry budget**: 0. Target: reduce from 2 to 0.

**Timing**: 3-4 hours (1-2 dispatch sessions)

**Depends on**: 9

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- zone-3 assembly + Since mirror + cleanup

**Verification**:
- `lake build` succeeds
- `lean_verify completeness_discrete` clean (no sorryAx, only standard axioms)
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` returns 0 results (excluding comments and dead-code)

## Testing & Validation

- [x] After Phase 1: `lake build GeneralExistPart` succeeds; no sorry in remaining code
- [x] After Phase 2: `lake build KampBypass` succeeds; sorry count = 2 (at between-zone sites only)
- [x] After Phase 3: Research report written with actionable design
- [x] After Phase 4 (4a-4c): KampBypass.lean sorry-free; PriorComposition.lean reduced to 4 sorry
- [x] After Phase 5: `lake build PriorComposition` + `lake build KampBypass` succeed; sorry count in PriorComposition = 4; KampBypass sorry = 0
- [x] After Phase 6: `lake build NfCharFormula` succeeds; sorry at line 651 eliminated from critical path (dead-code sorry remains)
- [x] After Phase 7: `lake build PriorComposition` succeeds; sorry count = 2 (reduced from 4 by strong induction unifying K=0/K=succ cases)
- [ ] After Phase 8: `lake build PriorComposition` succeeds; `lean_verify depth0_exist_transfer` clean
- [ ] After Phase 9: `lake build PriorComposition` succeeds; `lean_verify reconstruction_depth_transfer` clean; sorry count still = 2
- [ ] After Phase 10: `lean_verify completeness_discrete` clean; `lake build` succeeds; no sorry in Kamp directory (excluding dead-code)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- sorry at line 651 fixed [Phase 6]
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- strong D-induction + depth-0 density + reconstruction cascade + zone-3 assembly [Phases 7, 8, 9, 10]
- `specs/303_k_gt_0_depth_induction/plans/17_reconstruction-induction-plan.md` -- this plan
- `specs/303_k_gt_0_depth_induction/reports/16_strong-d-induction-research.md` -- key research input
- `specs/303_k_gt_0_depth_induction/reports/18_literature-alignment-analysis.md` -- key research input
- `specs/303_k_gt_0_depth_induction/reports/19_rabinovich-proof-extraction.md` -- key research input

## Rollback/Contingency

1. **Phase 8 depth-0 density is harder than expected at high arity**: Prototype at arity 4 (n=3) first. If general arity is intractable, implement for n=3 specifically (sufficient for the zone-3 case which needs arity 4 existential transfer). The general lemma can be proved later for cleanup.

2. **Phase 9 inner induction has env management issues**: Use explicit Fin.cons/Fin.tail decompositions matching existing PriorComposition.lean patterns. If Fin arithmetic creates type errors, use `Fin.cast` with omega proofs.

3. **Phase 9 heartbeat exceeded**: Factor the reconstruction induction into 3+ private helpers (base case, inductive step atom part, inductive step quantifier part). Use `set_option maxHeartbeats 800000` per helper.

4. **Phase 10 K=0 edge case fails**: At K=0, the strong induction has no ih_strong applications. The depth-0 density lemma should handle this directly. If not, add a separate `K=0` branch using the existing sorry-free k=0 infrastructure from KampBypassCore.

5. **Phase 10 w_nf zone placement fails**: The atom-preservation argument (depth-K 3-var agreement preserves order atoms) should be straightforward. If `nf_agreement_from_shared_nf` does not directly expose order atom preservation, extract a helper lemma `atom_agree_implies_order_preserved` from the atom agreement.

6. **Any phase**: `git revert` to restore pre-attempt state. Do NOT re-attempt: GeneralExistPartOrdered, BetweenZoneExistPart, `depth0_3var_exist_transfer_until/since`, `exist_transfer_3var_nonconstenv`, `nonconstenv_exist_transfer_general`, `zone_compatible_witness_bwd/fwd`, Prior-UZ/SZ for top-level witness placement (all confirmed FALSE, unprovable, or misaligned across 10+ dispatch sessions).
