# Implementation Plan: Close PriorComposition Sorry via Standalone nvar_transfer Lemma

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [IN PROGRESS] (Phases 1-7 completed, Phase 8 completed, Phases 9-10 not started)
- **Effort**: 14 hours (4-6 dispatch sessions)
- **Dependencies**: None (k=0 infrastructure is sorry-free, KampBypass.lean is sorry-free)
- **Research Inputs**: reports/09_interval-splitting-mapping.md, reports/11_vea-negation-closure-design.md, reports/12_fraisse-game-analysis.md, reports/13_literature-grounded-proof-strategy.md, reports/15_charpart-threading-design.md, reports/16_strong-d-induction-research.md, reports/18_literature-alignment-analysis.md, reports/19_rabinovich-proof-extraction.md
- **Artifacts**: plans/18_nvar-transfer-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v18 replaces the blocked Phases 9-10 from plan v17 with three new phases (8-10) that implement a fundamentally different approach aligned with Rabinovich 2014 Prop 4.3. The v17 blocker was definitive: the zone-3 existential transfer has an irreducible depth gap. ih_strong gives depth-K 3-var agreement but the goal needs depth-(K+1) 3-var agreement. The Phase 8 infrastructure (reconstruction_depth_agree, exist_transfer_from_full_agree) operates at fixed arity and cannot bridge this gap.

The root cause: Rabinovich's proof covers ALL arities at each depth step. The Lean outer induction only covers arity 2, so arity 3 at depth K+1 is not available from the IH. The fix is a standalone lemma `nvar_transfer_from_1var` that proves r-var agreement at any depth d from 1-var agreements at all environment components, order matching, CharPart, and Prior axioms -- by induction on d with all arities at each step.

Current state (after Phase 8): KampBypass.lean is sorry-free (0 sorry). PriorComposition.lean has 4 sorry at lines 449, 454, 505, 509 (zone-3 quantifier parts of `prior_nonconstenv_2var_agree_until/since` under strong induction). NfCharFormula.lean critical path is sorry-free (1 sorry remains in deprecated dead-code `nf_2var_exist_formula_prior`). Phase 8 infrastructure (reconstruction_depth_agree, exist_transfer_from_full_agree, depth0_agree_from_higher) is proved and sorry-free.

### Research Integration

- Report 18 (literature-alignment-analysis.md): Confirmed depth-based induction is aligned but INCOMPLETE. Identified the depth gap is irreducible at fixed arity. The correct fix is to cover all arities simultaneously at each depth step, matching Rabinovich's proof structure.
- Report 19 (rabinovich-proof-extraction.md): Extracted Rabinovich's full proof architecture. Prop 4.3 proves every FO formula is V-exists-forall by structural induction covering all arities. The standalone lemma reinterprets this in the NF framework.
- Phase 8/9 blocker analysis (return-meta.json): reconstruction_depth_agree operates at FIXED arity; exist_transfer_from_full_agree gives d<=K only; 5 approaches exhausted. The arity cascade (depth K -> K-1 -> ... -> 0 with increasing arity) is the correct structure but needs a SELF-CONTAINED induction that does not depend on ih_strong.
- Report 16 (strong-d-induction-research.md): Confirmed strong D-induction necessary. NfCharFormula.lean:651 independent fix completed in Phase 6.
- Report 15 (charpart-threading-design.md): Established CharPart-threading architecture (Phase 5 completed).
- Reports 09, 11, 12, 13: Established GeneralExistPartOrdered and BetweenZoneExistPart are FALSE; zone decomposition + Prior-UZ/SZ is the correct approach.

## Goals & Non-Goals

**Goals**:
- Implement standalone `nvar_transfer_from_1var` lemma covering all arities at each depth step
- Close all 4 sorry in PriorComposition.lean (lines 449, 454, 505, 509)
- Verify completeness chain through completeness_discrete
- Match Rabinovich 2014 Prop 4.3 proof structure faithfully

**Non-Goals**:
- Modifying KampBypass.lean (already sorry-free)
- Modifying KampMutualInduction.lean (CharPart flows through existing param chain)
- Modifying k=0 infrastructure (KampBypassCore/Until/Since, ~4400 lines, all sorry-free)
- Proving GeneralExistPartOrdered or BetweenZoneExistPart (both FALSE)
- Proving nonconstenv_exist_transfer_general (FALSE)
- Using simple K-induction (circular)
- Using Prior-UZ/SZ for top-level witness placement
- Using ih_strong for zone-3 closure (the standalone lemma replaces this need)
- Using reconstruction_depth_agree to bridge the depth gap (it operates at fixed arity)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Depth-0 base case of nvar_transfer is harder than expected for arbitrary arity | H | M | At depth 0, NF evaluation is purely atomic (order + predicate checks). 1-var agreements at all components + order matching should transfer these directly. If tricky, prototype at arity 3 first (sufficient for the zone-3 use case). |
| Quantifier step needs witness matching via CharPart + Prior-UZ/SZ | H | M | CharPart is already proved in kamp_mutual_induction. Prior-UZ/SZ infrastructure exists in PriorDefs.lean. The witness matching follows the same pattern as the k=0 case but at arbitrary depth. |
| Fin/env management complexity at arbitrary arity r | M | M | Use explicit Fin.cons constructions matching existing patterns. Factor out env-manipulation helpers. Use Fin.cast with omega if Fin arithmetic creates type errors. |
| Heartbeat limits exceeded by combined inductions | M | H | Factor the proof into 3+ private helpers (base case, temporal step, quantifier step). Use `set_option maxHeartbeats 800000` per helper. Split large proofs across multiple lemmas. |
| Applying the standalone lemma to close zone-3 sorry requires delicate hypothesis assembly | M | L | The hypotheses (1-var agreements, order matching, CharPart, Prior) are all available in the zone-3 proof context. The assembly is straightforward once the lemma exists. |

## Approaches Ruled Out

The following approaches have been confirmed FALSE, unprovable, or circular across 15+ dispatch sessions. DO NOT re-attempt any of these:

- **GeneralExistPartOrdered**: FALSE at all depths (report 09, confirmed by counterexample)
- **BetweenZoneExistPart**: FALSE (report 09)
- **nonconstenv_exist_transfer_general**: FALSE (Phase 6 v15 blocker)
- **depth0_3var_exist_transfer_until/since**: Unprovable as standalone lemma
- **exist_transfer_3var_nonconstenv**: Unprovable without inner cascade
- **zone_compatible_witness_bwd/fwd**: Unprovable (no zone guarantee from nf_extend alone without atom preservation argument)
- **Simple K-induction**: Circular (zone-3 at depth D requires theorem at D-1, not provided by simple induction)
- **Prior-UZ/SZ for top-level zone-3 witness placement**: WRONG (reports 18-19). Witness comes from ih_strong quantifier unfolding. Prior-UZ gives correct zone but wrong NF type.
- **Direct cross_extend_bwd_1var as zone-3 witness**: Gives single-bound (w > t' or w < x'), not dual-bound (t' < w < x')
- **Depth induction with arity explosion without inner cascade**: Arity grows unboundedly without termination at depth 0
- **generalExistPart_from_classical at the needed depth**: Circular -- requires depth-(K+1) 3-var agreement as precondition
- **reconstruction_depth_agree for bridging depth gap**: Operates at FIXED arity, cannot cross arity boundaries (Phase 9 v17 blocker)
- **reconstruction_depth_transfer (v17 Phase 9)**: Same depth gap it claims to bridge -- inner IH at arity n+1 cannot provide arity n+2 (confirmed blocked)
- **exist_transfer_from_full_agree with ih_strong for zone-3**: Gives d<=K only from depth-(K+1) 2-var hypothesis
- **ih_strong for zone-3 closure**: The standalone lemma replaces this need entirely
- **Phase 8 v17 depth-0 density lemma as standalone**: The general form is FALSE
- **Any approach that increases arity at each depth step without covering all arities in the IH**: Leads to unbounded arity explosion

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4, 5 | -- (all completed) |
| 2 | 6 | 5 (completed) |
| 3 | 7 | 6 (completed) |
| 4 | 8 | 7 (completed) |
| 5 | 9 | 8 (completed) |
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

**Completed**: 2026-06-18

**Depends on**: 5 (completed)

---

### Phase 7: Strong D-Induction Scaffolding [COMPLETED]

**Goal**: Replace simple `induction K` with `Nat.strong_induction_on D` (where D=K+2) in PriorComposition.lean. Restructure the main theorems to be parametric in D. The IH provides the theorem at all depths < D.

**Completed**: 2026-06-19

**Depends on**: 6

---

### Phase 8: Reconstruction Depth Infrastructure [COMPLETED]

**Goal**: Prove the reconstruction depth induction lemma and existential transfer from full agreement. These provide the algebraic machinery for closing the zone-3 sorry.

*(deviation: altered -- the planned "depth-0 Prior density lemma" was discovered to be FALSE as a standalone lemma. Instead, the correct mechanism is `exist_transfer_from_full_agree`: from depth-(K+1) full agreement at arity n+1, extract depth-d (n+2)-var existential transfer via the quantifier condition + monotonicity.)*

**Completed**: 2026-06-19

**Depends on**: 7 (completed)

**Key infrastructure delivered**:
| Name | Location | Purpose |
|------|----------|---------|
| `exist_transfer_from_full_agree` | PriorComposition.lean | Existential transfer at depth d <= k from depth-(k+1) full agreement |
| `depth0_agree_from_higher` | PriorComposition.lean | Depth-0 agreement from higher-depth (monotonicity wrapper) |
| `reconstruction_depth_agree` | PriorComposition.lean | Full reconstruction induction: depth-d agreement for d <= K+1 from depth-(K+1) |

**Blocker discovered**: reconstruction_depth_agree operates at FIXED arity. It cannot bridge the zone-3 gap (need depth-(K+1) 3-var, have depth-K 3-var from ih_strong). The 4 sorry remain.

---

### Phase 9: Standalone nvar_transfer_from_1var Lemma [BLOCKED]

**Goal**: Prove a standalone helper lemma that, given 1-var NF agreements at all environment components plus order matching plus CharPart plus Prior axioms, establishes r-var NF agreement at any depth d for any arity r. This lemma is proved by induction on d with ALL arities covered at each step, eliminating the depth/arity gap entirely.

**Literature Fidelity**: This phase implements Rabinovich 2014 Prop 4.3 reinterpreted in the NF framework. The key principle: induction on depth with ALL arities covered at each step eliminates the arity explosion.

DO NOT DEVIATE:
- DO NOT try to bridge the depth gap with reconstruction_depth_agree (it operates at fixed arity)
- DO NOT use ih_strong for the zone-3 closure (use nvar_transfer_from_1var instead)
- DO NOT induct on arity or witness count -- induct on DEPTH with forall r
- The standalone lemma is SELF-CONTAINED -- it uses CharPart + Prior, not ih_strong
- If any step fails, RE-READ Rabinovich Prop 4.3 and reports 18-19

**Tasks**:

**Task 9.1: Statement and depth-0 base case (~80-120 lines)**
- [ ] Define `nvar_transfer_from_1var` with the following signature (or a close variant):
  ```lean
  theorem nvar_transfer_from_1var
    (M N : OrderedMonadicStructure sig)
    (d r : Nat) (envM : Fin r -> carrier M) (envN : Fin r -> carrier N)
    -- 1-var agreements: each component matches at depth d (or higher)
    (h_1var : forall i : Fin r,
      forall nf : NormalForm sig d 1,
        nf_eval_nf M d 1 (fun _ => envM i) nf <->
        nf_eval_nf N d 1 (fun _ => envN i) nf)
    -- Order matching: order relations between env components match
    (h_order : forall i j : Fin r,
      M.lt (envM i) (envM j) <-> N.lt (envN i) (envN j))
    -- CharPart: characterization property at depths <= d
    (h_char : <CharPart hypotheses from kamp_mutual_induction>)
    -- Prior axioms: UZ/SZ for witness existence
    (h_prior_M : semantic_prior_UZ M /\ semantic_prior_SZ M)
    (h_prior_N : semantic_prior_UZ N /\ semantic_prior_SZ N)
    : forall nf : NormalForm sig d r,
        nf_eval_nf M d r envM nf <-> nf_eval_nf N d r envN nf
  ```
  The exact signature will depend on what CharPart and Prior hypotheses look like in context. Read the existing PriorComposition.lean proofs to determine the precise types.
- [ ] Implement the d=0 base case: at depth 0, NF evaluation is purely atomic (order + predicate checks). Transfer from 1-var agreements + order matching. This should be straightforward since depth-0 NFs contain no temporal or quantifier parts.
- [ ] Verify: `lean_verify nvar_transfer_from_1var` at the d=0 case (with sorry for inductive step)

**Task 9.2: Inductive step -- atom and temporal parts (~80-120 lines)**
- [ ] Implement the atom part of the d+1 case: atoms are depth-independent, transfer from h_order and predicate matching (which follows from 1-var agreements)
- [ ] Implement the temporal part of the d+1 case: depth-d formulas evaluated along the timeline. These transfer by the IH at depth d (which covers all arities).
  - G/H modalities: transfer global/historical quantifiers using IH at depth d
  - Until/Since: transfer binary temporal using IH at depth d for intermediate points
- [ ] Verify partial progress: atom and temporal sorry-free, quantifier still sorry

**Task 9.3: Inductive step -- quantifier part (~100-200 lines)**
- [ ] Implement the quantifier part of the d+1 case:
  - Given v in M satisfying a depth-d (r+1)-var sub-NF chi
  - Characterize v via CharPart at depth d: v has a unique depth-d 1-var NF type
  - Find v' in N with matching 1-var type using Prior-UZ/SZ + CharPart:
    - Use Prior-UZ to find element in N between appropriate bounds
    - Use CharPart to verify the 1-var NF type matches
  - Build extended environment: [v, envM] and [v', envN] both have matching 1-var types at all components (v/v' match by construction, envM(i)/envN(i) match by h_1var)
  - Order matching for extended env: v'/envN order follows from zone placement
  - Apply IH at depth d, arity r+1: get nf_eval transfer for chi
  - Conclude: existential transfer at depth d+1
- [ ] Handle the reverse direction (from N to M) symmetrically using semantic_prior_SZ
- [ ] Factor into private helpers if heartbeat limits require it

**Task 9.4: Verification and cleanup (~20-40 lines)**
- [ ] Verify: `lean_verify nvar_transfer_from_1var` -- no sorryAx
- [ ] Verify: `lake build PriorComposition` succeeds
- [ ] Verify: `lake build KampBypass` still succeeds with 0 sorry
- [ ] Verify: sorry count in PriorComposition.lean unchanged (4 -- not yet closed)
- [ ] Clean up any unused lemmas or imports

**Sorry budget**: 0 for this phase. The standalone lemma must be completely sorry-free.

**Timing**: 4-6 hours (2-3 dispatch sessions)

**Depends on**: 8 (completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- new standalone lemma section, placed before the main theorems

**Key infrastructure used**:
| Name | Location | Purpose |
|------|----------|---------|
| `CharPart` / `charPart_succ` | KampMutualInduction.lean | Characterization property for 1-var types |
| `semantic_prior_UZ` / `semantic_prior_SZ` | PriorDefs.lean | Prior axioms for witness existence |
| `nf_eval_nf` | NormalForm.lean | NF evaluation function |
| `nf_characteristic_satisfies` | NormalForm.lean | M satisfies its own characteristic NF |
| `nf_agreement_from_shared_nf` | NormalForm.lean | Shared NF implies agreement |
| `nf_agreement_monotone` | NormalForm.lean | Depth weakening for NF agreement |

**Verification**:
- `lean_verify nvar_transfer_from_1var` -- no sorryAx
- `lake build PriorComposition` succeeds
- `lake build KampBypass` still succeeds with 0 sorry
- `grep -c sorry PriorComposition.lean` still returns 4 (sorry not yet closed)

---

### Phase 10: Zone-3 Assembly + Sorry Closure + End-to-End Verification [NOT STARTED]

**Goal**: Close all 4 sorry in PriorComposition.lean by applying `nvar_transfer_from_1var` to the zone-3 proof, then verify the full completeness chain end-to-end.

**Literature Fidelity**: This phase completes the Rabinovich Prop 4.3 reinterpretation in the NF framework. The standalone lemma from Phase 9 provides the multi-arity transfer. This phase assembles the hypotheses and applies it.

DO NOT DEVIATE:
- DO NOT try to bridge the depth gap with reconstruction_depth_agree (it operates at fixed arity)
- DO NOT use ih_strong for the zone-3 closure (use nvar_transfer_from_1var instead)
- DO NOT induct on arity or witness count -- the standalone lemma handles this
- The standalone lemma is SELF-CONTAINED -- it uses CharPart + Prior, not ih_strong
- If any step fails, RE-READ Rabinovich Prop 4.3 and reports 18-19

**Tasks**:

**Task 10.1: Zone-3 proof assembly for Until forward (~40-60 lines)**
- [ ] At the sorry site (line ~449 in `prior_nonconstenv_2var_agree_until`):
  1. **Find w' via Prior-UZ**: Given w in M with t < w < x (zone 3), use Prior-UZ to find w' in N with t' < w' < x' and matching depth-(K+1) 1-var type as w.
  2. **Assemble nvar_transfer hypotheses**:
     - 1-var agreements: w/w' match by construction (Prior-UZ + CharPart), x/x' match from h_x, t/t' match from h_t
     - Order matching: t' < w' < x' from Prior-UZ zone placement; other orders from h_x, h_t ordering hypotheses
     - CharPart: from kamp_mutual_induction (already available in context)
     - Prior: from the Prior structure hypotheses (already available)
  3. **Apply nvar_transfer_from_1var** at d=K+1, r=3, env=[w,x,t], env'=[w',x',t']
  4. **Get**: nf_eval M (K+1) 3 [w,x,t] sub_nf <-> nf_eval N (K+1) 3 [w',x',t'] sub_nf. Since M side holds, N side holds.
  5. **Close the sorry** with `exact <w', h_zone, h_eval>`

**Task 10.2: Until backward + Since mirror (~40-60 lines)**
- [ ] Mirror the zone-3 proof for Until backward (line ~454):
  - Same structure as forward, but finding w in M from w' in N
  - Use symmetric Prior-SZ or reverse direction of Prior-UZ
- [ ] Mirror for `prior_nonconstenv_2var_agree_since` forward (line ~505):
  - Same structure with reversed order relations (x < w < t becomes x' < w' < t')
  - Use `semantic_prior_SZ` instead of `semantic_prior_UZ` for zone placement
- [ ] Mirror for `prior_nonconstenv_2var_agree_since` backward (line ~509):
  - Symmetric to Since forward

**Task 10.3: End-to-end verification**
- [ ] Run `lean_verify prior_nonconstenv_2var_agree_until` -- confirm no sorryAx
- [ ] Run `lean_verify prior_nonconstenv_2var_agree_since` -- confirm no sorryAx
- [ ] Run `lean_verify kamp_mutual_induction` -- confirm no sorryAx
- [ ] Run `lean_verify completeness_discrete` -- confirm no sorryAx
- [ ] Run full `lake build` -- confirm no regressions
- [ ] Verify sorry count across entire Kamp directory: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` -- 0 results (excluding comments and dead-code `nf_2var_exist_formula_prior`)
- [ ] Remove any dead imports or unused helper lemmas
- [ ] Update module docstring in PriorComposition.lean to reflect final proof strategy

**Sorry budget**: 0. Target: reduce from 4 to 0.

**Timing**: 2-3 hours (1-2 dispatch sessions)

**Depends on**: 9

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- zone-3 assembly + sorry closure + cleanup

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
- [x] After Phase 8: `lake build PriorComposition` succeeds; `lean_verify exist_transfer_from_full_agree` clean; `lean_verify reconstruction_depth_agree` clean; sorry count = 4 (re-expanded after blocker discovery)
- [ ] After Phase 9: `lake build PriorComposition` succeeds; `lean_verify nvar_transfer_from_1var` clean; sorry count still = 4
- [ ] After Phase 10: `lean_verify completeness_discrete` clean; `lake build` succeeds; no sorry in Kamp directory (excluding dead-code)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- sorry at line 651 fixed [Phase 6]
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- strong D-induction + reconstruction infrastructure + standalone nvar_transfer + zone-3 assembly [Phases 7, 8, 9, 10]
- `specs/303_k_gt_0_depth_induction/plans/18_nvar-transfer-plan.md` -- this plan
- `specs/303_k_gt_0_depth_induction/reports/16_strong-d-induction-research.md` -- key research input
- `specs/303_k_gt_0_depth_induction/reports/18_literature-alignment-analysis.md` -- key research input
- `specs/303_k_gt_0_depth_induction/reports/19_rabinovich-proof-extraction.md` -- key research input

## Rollback/Contingency

1. **Phase 9 quantifier step fails at arbitrary arity**: Prototype at arity 3 first (sufficient for zone-3 which needs exactly arity 3). If arity-3 works, implement the general version later. The zone-3 sorry can be closed with the arity-3 special case.

2. **Phase 9 CharPart hypotheses are hard to thread**: CharPart is already available in the PriorComposition.lean proof context from kamp_mutual_induction. If threading is complex, create a wrapper that packages the needed CharPart hypotheses into a structure.

3. **Phase 9 Prior-UZ/SZ witness matching fails**: The witness matching at the quantifier step is the most novel part. If direct Prior-UZ/SZ application is difficult, try: (a) Use cross_extend_bwd_1var for single-bound witnesses, then chain UZ+SZ for dual-bound. (b) Use the existing k=0 infrastructure patterns as a template. (c) Prototype the witness matching in a standalone test file first.

4. **Phase 9 heartbeat exceeded**: Factor the proof into 4+ private helpers: `nvar_transfer_base` (depth 0), `nvar_transfer_atom` (atom part), `nvar_transfer_temporal` (temporal part), `nvar_transfer_quant` (quantifier part). Use `set_option maxHeartbeats 800000` per helper.

5. **Phase 10 hypothesis assembly fails**: The main difficulty is assembling the 1-var agreement and order matching hypotheses at the zone-3 sorry sites. If direct assembly is hard, create an intermediate lemma that packages the zone-3 context into the nvar_transfer hypotheses.

6. **Any phase**: `git revert` to restore pre-attempt state. Do NOT re-attempt any approach in the "Approaches Ruled Out" section.
