# Implementation Plan: VecEA Path B -- Formula-Level NF-to-EA Bridge (v28)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Plans v17-v22 (phases 1-4 COMPLETED), plan v23 (Phase 0 COMPLETED), plan v24 (Phases 1-2 COMPLETED), plan v26 (Phases 1-2 COMPLETED, Phase 3 all options blocked). Rabinovich infrastructure (4 files, 1349+ lines, sorry-free core). NfToVecEA.lean (634 lines, depth-0 sorry-free).
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/26_literature-proof-walkthrough.md (round 26, Path B recommendation)
  - specs/273_chronicle_gap_contradiction_proof/reports/25_formula-construction-research.md (round 25, formula construction)
  - specs/273_chronicle_gap_contradiction_proof/reports/24_blocker-research.md (round 24, root blocker)
  - specs/273_chronicle_gap_contradiction_proof/reports/23_team-research.md (round 23, VecEADecomposition dead code)
  - specs/273_chronicle_gap_contradiction_proof/reports/13_team-research.md (round 13, nf_to_formula bridge)
  - specs/273_chronicle_gap_contradiction_proof/reports/11_divergence-audit.md (postmortem constraints)
  - specs/273_chronicle_gap_contradiction_proof/reports/10_literature-transcription.md (literature grounding)
  - specs/literature/Rabinovich_2014_Proof_of_Kamps_Theorem.md (Section 5 -- primary reference)
- **Artifacts**: plans/28_vecEA-path-b-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v27 phases 1-2 are COMPLETED (Lemma 5.3 / Lemma 5.1 / Prop 4.2 were already sorry-free; no new code needed). Plan v27 phase 3 is BLOCKED because the wiring from Prop 4.2 into ExistPart requires encoding NF evaluation as VecEA2, which itself needs the composition theorem -- the same fundamental blocker.

Report 26 discovered that Prop 4.2 (`neg_2var_vec_ea`) is already sorry-free. The actual gap is converting NF evaluation into the VecEA2 representation that feeds the sorry-free pipeline. Report 26 recommends Path B: fix the Since-direction VecEA translation, build the NF-to-EA bridge at depth k+1, and wire through the sorry-free VecEA2 translation to close the sorry chain.

Plan v28 replaces v27 phases 3-4 with a 3-phase strategy that works at the VecEA2 formula level rather than the NF level, avoiding the proven-false composition lemma entirely.

### Research Integration

**Reports integrated in this plan version**:
- `26_literature-proof-walkthrough.md`: Path A (GHR94 separation) at 2000-4000 lines NOT recommended. Path B (Rabinovich VecEA pipeline) at 500-800 lines RECOMMENDED. Path C (direct NF fix) fundamentally blocked by false composition theorem. Key finding: `neg_2var_vec_ea` is already sorry-free; only `bracketBuildLeft_correct` (2 sorries at n>0) and the NF-to-EA bridge at depth k+1 are needed.
- `25_formula-construction-research.md`: All three bridge options (A/B/C) reduce to Prop 4.2 or composition. generalized_composition proved FALSE with clean counterexample.

### Prior Plan Reference

Plans v17-v22: Phases 1-4 COMPLETED (~2700 lines sorry-free vec-EA infrastructure). Plan v23: Phase 0 COMPLETED (quarantine). Plan v24: Phases 1-2 COMPLETED (Separation module, sorry-free). Plan v26: Phases 1-2 COMPLETED (existPart_zero all n, existPart_succ factored). Plan v27: Phases 1-2 COMPLETED (confirmed Prop 4.2 sorry-free, no new code needed); Phase 3 BLOCKED (wiring requires composition theorem).

This plan replaces v27 phases 3-4 with a formula-level approach that avoids the composition theorem entirely.

### Roadmap Alignment

- **Kamp chain**: Close `kamp_prior_expressive_completeness` via NF-to-VecEA2 bridge + sorry-free VecEA2 translation
- **Chronicle gap**: Fill `chronicle_gap_contradiction` via sorry-free model surgery pipeline
- **Critical path**: Closes two of the remaining sorry chains for `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Fix `bracketBuildLeft_correct` (NfToVecEA.lean:472-475): fill 2 sorries for Since-direction VecEA2 translation at n>0 by mirroring the sorry-free `bracketBuildRight_correct` pattern in VecEATranslation.lean
- Build the NF-to-EA bridge at depth k+1: convert `exists x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf` into a VVecEA2 formula, using existing sorry-free infrastructure (Prop 4.2 for negation, Lemma 3.4(3) for existential closure)
- Wire the VVecEA2 through `translateLeft` to get a TL(U,S) formula and fill `nf_2var_exist_formula_prior` (NfCharFormula.lean:597)
- Verify `kamp_prior_expressive_completeness` and `completeness_discrete` sorry chains improve
- Fill `chronicle_gap_contradiction` if unblocked by the Kamp chain closure

**Non-Goals**:
- Filling NegationClosure.lean:1716 (`nf_exist_formula_nested_backward`) -- this approach bypasses it entirely via the VecEA2 path
- Filling NegationClosure.lean:1327 (zone compatibility `all_goals sorry`) -- not on critical path
- Modifying existing sorry-free infrastructure (VecEATranslation, NegationClosureProp42, VecEAClosure, etc.)
- Proving the GHR94 separation property (Path A -- rejected as too expensive)
- Filling ChronicleToCountermodel.lean:224 (dead code)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| bracketBuildLeft_correct Since direction has structural differences from Until direction | M | L | The `bracketBuildRight_correct` proof uses `bracket_prepend_witness` and `bracket_extract_first_witness`. The Since direction needs the mirror operations. VecEATranslation.lean already has the pattern. If private helpers cannot be imported, inline the construction. |
| NF-to-EA bridge at depth k+1 hits the same composition obstacle in a different form | H | M | The VecEA2 framework natively handles 2-free-variable formulas. The key insight: VecEA2 has TWO free variables (z0, z1) which map to (t, x). The quantifier conditions (exists y with 3-var NF) decompose by zone relative to x and t. For positive conditions (sub_nf.2 ssn = true): build an EA witness. For negative conditions (sub_nf.2 ssn = false): use neg_2var_vec_ea (Prop 4.2, sorry-free). The VecEA2 framework bypasses composition by working at the formula level. If the bridge does face composition issues, mark PARTIAL with specific blocker. |
| translateLeft correctness depends on bracketBuildLeft_correct at general n | H | L | Phase 1 fixes bracketBuildLeft_correct first. If it cannot be fixed, use translateLeft_correct_zero (sorry-free at n=0) and restructure the bridge to produce n=0 VecEA2 formulas via disjunction. |
| Chronicle gap Case B (constant MCS) non-trivial | M | M | Orthogonal to Phases 1-2. If non-trivial, mark as sub-sorry with follow-up task. |

## Postmortem Constraints (from Report 11, Section 5)

These remain binding:
1. **DO NOT attempt NF-to-formula backward proofs by extracting NF data from formula truth** (Deflection 1)
2. **DO NOT use depth-k characteristic formulas where depth-(k+1) is needed** (Deflection 2)
3. **DO NOT encode negative interval conditions as guards that block legitimate witnesses** (Deflection 3)
4. **DO NOT attempt to prove nf_3var_from_1var_nfs at fixed arity** (Deflection 4)
5. **DO NOT cycle between formula-level and NF-level fixes** (Deflection 5)

## Sorry Inventory (Current State)

| File | Line | Statement | Status | This Plan |
|------|------|-----------|--------|-----------|
| NfToVecEA.lean | 472 | bracketBuildLeft_correct forward (Since, n>0) | FILLED | Phase 1 completed |
| NfToVecEA.lean | 475 | bracketBuildLeft_correct backward (Since, n>0) | FILLED | Phase 1 completed |
| NfCharFormula.lean | 597 | nf_2var_exist_formula_prior (k+1 case) | SORRY | Phase 3 fills via VecEA2 bridge |
| RabinovichGeneralized.lean | 446 | existPart_succ n=1 | SORRY | Phase 3 resolves (may bypass) |
| RabinovichGeneralized.lean | 474 | existPart_succ n>=2 | SORRY | Phase 3 resolves (depends on n=1) |
| NegationClosure.lean | 1716 | nf_exist_formula_nested_backward | SORRY | BYPASSED (not on critical path if NfCharFormula filled directly) |
| NegationClosure.lean | 1327 | zone compatibility all_goals sorry | SORRY | NOT on critical path (preserved) |
| ChronicleToCountermodel.lean | 224 | succ_reaches_dom_N boundary | SORRY | Dead code (NOT filled) |

### Existing Infrastructure (sorry-free, DO NOT TOUCH)

| File | Lines | Content |
|------|-------|---------|
| VecEAFormula.lean | -- | VecEA2 types |
| VecEATranslation.lean | 302 | Prop 3.5: ExistsForallSpec -> TL(U,S), bracketBuildRight_correct |
| NegationClosureProp42.lean | -- | Prop 4.2: neg_2var_vec_ea |
| PriorINF.lean | -- | Prior INF/SUP |
| VecEAClosure.lean | -- | VecEA closure |
| NfToVecEA.lean (depth 0) | 634 | NF-to-VecEA depth 0 (bracketBuildLeft_correct at n=0 OK) |
| RabinovichGeneralized.lean | ~470 | ExistPart(0) all n, forward direction |
| NegationClosure.lean | -- | Forward direction all k |
| RabinovichTranslation.lean | 302 | Prop 3.5 translate_correct |
| RabinovichNegation.lean | 297 | Backward k=0 |
| NfComposition.lean | 267 | intra_structure_extend |
| SeparationBridge.lean | ~199 | neg_until_equiv_prior, neg_since_equiv_prior |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases are fully sequential. Each phase builds on the prior.

---

### Phase 1: Fix bracketBuildLeft_correct (Since direction, n>0) [COMPLETED]

**Goal**: Fill the 2 sorries at NfToVecEA.lean:472 and :475. These are the Since-direction analog of the sorry-free `bracketBuildRight_correct` in VecEATranslation.lean. The Until direction uses `bracket_prepend_witness` and `bracket_extract_first_witness`; the Since direction needs the symmetric operations for the left endpoint.

**Mathematical Content**:

The `bracketBuildLeft` function constructs a Since-chain: `S(pt /\ bracketBuildLeft(rest), guard)`. At n+1, correctness means:
- Forward: given `bf.holds z0 t` (bracket holds on (z0, t)), extract a Since witness x < t with the right point type and a truncated bracket on (z0, x), then apply IH.
- Backward: given z0 < t with `bf.holds z0 t`, produce a Since witness x satisfying the point type at x and the truncated bracket on (z0, x) via IH, then combine.

The `bracketBuildRight_correct` proof (VecEATranslation.lean:164-200) factors through `chainHolds` and uses:
- `bracket_prepend_witness`: given first witness x with point type + remaining bracket on (x, z1), construct full bracket on (z0, z1)
- `bracket_extract_first_witness`: given full bracket on (z0, z1), extract first witness x

The Since direction needs the mirror: extract/prepend the LAST witness instead of the first.

**Tasks**:
- [x] **Task 1.1**: Read `bracketBuildRight_correct` proof structure in VecEATranslation.lean (lines 164-241). Identified helper lemmas: `bracket_prepend_witness`, `bracket_extract_first_witness`, `chainHolds_iff_holds`. Since-direction analogs did not exist; created.
- [x] **Task 1.2**: Created `bracket_append_witness` and `bracket_extract_last_witness` in NfToVecEA.lean (lines 431-560). These mirror the Until helpers but operate on the last witness instead of the first. (~130 lines total)
- [x] **Task 1.3**: Filled the forward sorry. Uses `bracket_append_witness` to combine truncated bracket on (z0, x) with witness x to get full bracket on (z0, t). (~2 lines)
- [x] **Task 1.4**: Filled the backward sorry. Uses `bracket_extract_last_witness` to extract last witness x from bf.holds z0 t, then applies IH on truncated bracket. (~5 lines)
- [x] **Task 1.5**: Verified: `lean_verify bracketBuildLeft_correct` shows only standard axioms (propext, Classical.choice, Quot.sound), no sorryAx. `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA` succeeds. Also verified: `VecEA2.translateRight_correct` and `VVecEA2.translateRight_correct` both sorry-free.

**Timing**: 1.5 hours (~100-150 lines)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA.lean` -- fill sorries at :472 and :475, possibly add helper lemmas

**Verification**:
- `lean_verify` on `bracketBuildLeft_correct` shows no sorryAx
- `lean_verify` on `VecEA2.translateRight_correct` shows no sorryAx (depends on bracketBuildLeft_correct)
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA` succeeds

---

### Phase 2: Build NF-to-EA bridge at depth k+1 [IN PROGRESS]

**Goal**: Convert `exists x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf` into a VVecEA2 formula whose `holdsLeft`/`holdsRight` is equivalent to the NF existential on Prior structures. This is the core new code.

**Mathematical Content**:

The NF existential at depth k+1 decomposes into:
1. **Atom conditions**: predicates at x and t, order between x and t. These determine the zone (x < t, x = t, x > t) and the endpoint types (TemporalPred). Same as depth 0 -- already handled by `nfPred` and related functions in NfToVecEA.lean.

2. **Quantifier conditions**: for each depth-k 3-var NF ssn, whether `exists y, nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn` holds. The profile `sub_nf.2 : NormalForm sig k 3 -> Bool` partitions these into:
   - Positive (sub_nf.2 ssn = true): `exists y` with the 3-var NF ssn holds. This IS an exists-forall formula with 2 free variables (x, t) = (z1, z0). By Lemma 3.4(3), adding the existential over y is structurally trivial.
   - Negative (sub_nf.2 ssn = false): `not (exists y)` with the 3-var NF ssn. By Prop 4.2 (`neg_2var_vec_ea`, sorry-free), the negation of an EA formula with <=2 free variables is V-EA.

3. **Assembly**: The full NF existential is a disjunction over zones. For each zone:
   - Conjunction of endpoint type (atom conditions)
   - Conjunction of all positive quantifier VecEA2 formulas
   - Conjunction of all negative quantifier VecEA2 formulas (via Prop 4.2)
   - The conjunction of VVecEA2 formulas is VVecEA2 (via VecEA closure)
   - Translate via `translateLeft`/`translateRight` to get TL formula

**Key design**: Work entirely at the VecEA2 level. The depth-k 3-var NF existentials are themselves convertible to VecEA2 by the induction hypothesis (this is P2(k) -- the existential part at depth k). At depth 0, the conversion is already sorry-free in NfToVecEA.lean. At depth k+1, we use the IH.

**The critical realization**: The NF-to-VecEA2 conversion at depth k+1 does NOT require the composition theorem because it works at the FORMULA level. Instead of reconstructing NF evaluation from formula truth (the NF-level approach that needs composition), it CONSTRUCTS the formula from NF evaluation data. The correctness proof is:
- Forward: given x with nf_eval, the atom conditions give endpoint types (VecEA2 endpoints), the positive quantifier conditions give EA witnesses, the negative quantifier conditions are satisfied (sub_nf.2 ssn = false means no y exists). All together: VecEA2.holdsLeft holds.
- Backward: given VecEA2.holdsLeft, the endpoint types give atom conditions at x, the positive quantifier witnesses give exists y claims, and crucially the negative quantifier conditions (from Prop 4.2 negation) give sub_nf.2 ssn = false. Reconstructing `nf_eval_nf M (k+1) 2 (x, t) sub_nf` requires both atoms AND quantifiers, which the VecEA2 formula explicitly encodes.

**Tasks**:
- [ ] **Task 2.1**: Define `nf_quant_to_vecEA2`: for a single depth-k 3-var NF ssn with sub_nf.2 ssn = true, convert `exists y, nf_eval_nf M k 3 (y, x, t) ssn` into a VecEA2 formula. This uses the IH (the depth-k version of the bridge) plus Lemma 3.4(3) for the existential. At depth 0, delegate to existing NfToVecEA depth-0 code. (~60-80 lines)
- [ ] **Task 2.2**: For negative conditions (sub_nf.2 ssn = false), construct the negation VecEA2 using `neg_2var_vec_ea` (Prop 4.2, sorry-free). The input is the VecEA2 from Task 2.1; the output is a VVecEA2 (disjunction of VecEA2). (~40-60 lines)
- [ ] **Task 2.3**: Combine all positive and negative quantifier conditions for a given zone into a single VVecEA2. Use VecEA closure (conjunction of VVecEA2 is VVecEA2). Combine with endpoint conditions. (~60-80 lines)
- [ ] **Task 2.4**: Assemble the full NF-to-VecEA2 conversion at depth k+1: disjunction over zones and atom profiles. Each disjunct is a VVecEA2 from Task 2.3. The disjunction of VVecEA2 is VVecEA2 (trivial). (~40-60 lines)
- [ ] **Task 2.5**: Prove correctness of the conversion (both directions). Forward: nf_eval -> holdsLeft via component matching. Backward: holdsLeft -> nf_eval via VecEA2 endpoint/bracket extraction. (~80-120 lines)
- [ ] **Task 2.6**: Verify with `lean_verify` on the main bridge lemma. Run `lake build` on the module.

**Timing**: 3 hours (~300-400 lines)

**Depends on**: 1

**Files to create or modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA.lean` (extend with depth k+1 section) OR
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEASuc.lean` (new file if NfToVecEA grows too large)

**Verification**:
- `lean_verify` on the bridge lemma shows no sorryAx
- `lake build` on the module succeeds

---

### Phase 3: Wire into NfCharFormula + chronicle gap + verify [NOT STARTED]

**Goal**: Use the VVecEA2 from Phase 2 plus `VVecEA2.translateLeft` to get a TL formula, fill NfCharFormula.lean:597 (k+1 case), and verify the sorry chain closure. Then fill `chronicle_gap_contradiction` if unblocked.

**Mathematical Argument**:

The proof at NfCharFormula.lean:597 needs: given `char_k` (depth-k characteristic formulas) and the depth-k+1 NF with 2 variables, construct a temporal formula A and prove:
```
temporal_truth M atomMap t A <-> exists x, nf_eval_nf M (k+1) 2 (x, t) sub_nf
```

Using Phase 2's bridge:
1. Convert the NF existential to a VVecEA2 v (using the bridge, which uses char_k as the IH)
2. Set A = v.translateLeft (or disjunction of translateLeft over the VVecEA2 disjuncts)
3. Forward: nf_eval -> v.holdsLeft (Phase 2 correctness) -> temporal_truth (translateLeft_correct, sorry-free after Phase 1)
4. Backward: temporal_truth -> v.holdsLeft (translateLeft_correct) -> nf_eval (Phase 2 correctness)

**Two wiring strategies**:

(a) Fill NfCharFormula.lean:597 directly with the VecEA2-based proof. This bypasses the master_induction in NegationClosure.lean entirely.

(b) Fill existPart_succ in RabinovichGeneralized.lean using the VecEA2 bridge, which then flows through kamp_mutual_induction -> nf_2var_exist_formula_prior_fill -> NfCharFormula.

Strategy (a) is more direct and avoids touching the complicated master_induction chain. Strategy (b) preserves the existing architecture but requires more wiring. The implementer should attempt (a) first.

**Tasks**:
- [ ] **Task 3.1**: Fill NfCharFormula.lean:597 with a VecEA2-based proof. Construct the VVecEA2 from the NF data (Phase 2 bridge), translate to TL formula, prove the biconditional. Import NfToVecEA (or NfToVecEASuc) if needed. (~60-80 lines)
- [ ] **Task 3.2**: Verify the Kamp chain: `nf_characterizable_temporal_prior`, `kamp_prior_expressive_completeness`, `US_expressively_complete_over_prior` all compile with reduced sorry count.
- [ ] **Task 3.3**: Fill `chronicle_gap_contradiction` (ChronicleToCountermodel.lean). Activate and fix the OLD PROOF block. Case A (limit_f(a) != limit_f(b)): fix k=0 -> k>=1 issue, use k=1 for `contemp_equiv`. Case B (limit_f(a) = limit_f(b)): prove or mark as sub-sorry. (~50-80 lines)
- [ ] **Task 3.4**: Run `lake build` (full project) -- must succeed with 0 errors.
- [ ] **Task 3.5**: Verify axiom checks:
  - `lean_verify chronicle_gap_contradiction` -- no sorryAx (or reduced)
  - `lean_verify completeness_discrete` -- remaining sorryAx should trace ONLY through Task 202 chain (succ_cofinal)
  - `lean_verify kamp_prior_expressive_completeness` -- no sorryAx
- [ ] **Task 3.6**: Update README.md if sorry obligations improve.

**Timing**: 1.5 hours (~100-150 lines + verification)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill sorry at :597
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fill chronicle_gap_contradiction (if unblocked)

**Verification**:
- `lean_verify nf_characterizable_temporal_prior` shows no sorryAx
- `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- `lean_verify chronicle_gap_contradiction` shows no sorryAx (or identifies remaining sub-sorry)
- `lake build` succeeds (full project, clean)
- `lean_verify completeness_discrete` -- remaining sorryAx traces only through Task 202 chain

---

## Testing & Validation

- [x] Phase 1-4 (v21/v22): Vec-EA infrastructure (~2700 lines sorry-free) (DONE)
- [x] Phase 0 (v23): VecEADecomposition quarantined (DONE)
- [x] Phases 1-2 (v24): Separation module sorry-free (DONE)
- [x] Rabinovich core: 4 files, 1349+ lines sorry-free (DONE)
- [x] Phase 1-2 (v26): existPart_zero all n + existPart_succ factored (DONE)
- [x] Phase 1-2 (v27): Lemma 5.3 + Prop 4.2 confirmed sorry-free (DONE, no new code)
- [ ] Phase 1 (v28): bracketBuildLeft_correct Since-direction sorry-free
- [ ] Phase 2 (v28): NF-to-VecEA2 bridge at depth k+1
- [ ] Phase 3 (v28): NfCharFormula:597 filled; Kamp chain sorry-free; chronicle_gap_contradiction filled

## Artifacts & Outputs

**Existing (sorry-free, preserved)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean` (302 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichTranslation.lean` (302 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichWiring.lean` (365 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichNegation.lean` (297 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` (~470 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` (267 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/SeparationBridge.lean` (~199 lines)

**Modified (v28)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA.lean` -- fix bracketBuildLeft_correct + depth k+1 bridge (~400-500 lines added)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill sorry at :597 (~60-80 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fill chronicle_gap_contradiction (~50-80 lines)

**Possibly new (v28)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEASuc.lean` -- if NfToVecEA grows too large, the depth k+1 bridge may be split into a separate file

**Estimated new Lean code**: ~500-700 lines across all files

## Rollback/Contingency

**If bracketBuildLeft_correct is harder than expected (Phase 1)**:
- The Since direction should mirror the Until direction structurally. If the bracket helpers are private in VecEATranslation.lean and cannot be reused, inline the construction. If Lean's Fin bookkeeping creates issues, try `Fin.last` / `Fin.castSucc` patterns.
- Fallback: use `translateRight_correct_zero` (sorry-free at n=0) and restructure Phase 2 to produce only n=0 VecEA2 formulas, paying with a larger disjunction.

**If the NF-to-EA bridge at depth k+1 faces unexpected issues (Phase 2)**:
- The bridge depends on the IH (depth-k conversion). If the IH is not available in the right form, the bridge may need to be restructured as a simultaneous induction with the main Kamp induction.
- If the quantifier condition encoding hits type mismatches between NF evaluation and VecEA2.holds, try adjusting the VecEA2 construction to match the NF evaluation exactly rather than going through BracketFormula.
- Fallback: mark [PARTIAL] with handoff, document the specific type mismatch.

**If NfCharFormula wiring has import cycle issues (Phase 3)**:
- NfCharFormula.lean is imported by NegationClosure.lean, which is imported by RabinovichGeneralized.lean. If the VecEA2 bridge needs NegationClosure imports, there may be a cycle.
- Solution: place the bridge in a separate file (NfToVecEASuc.lean) that imports NfToVecEA + NegationClosureProp42 but NOT NegationClosure. Then NfCharFormula imports NfToVecEASuc.

**If chronicle_gap_contradiction Case B is non-trivial (Phase 3)**:
- Mark Case B as a separate sorry with a TODO comment
- Create a follow-up task for Case B
- The Kamp chain closure (the primary goal) is independent of the chronicle gap

**If the approach fails entirely**:
- All existing sorry-free code (~4000+ lines) remains valid
- The NegationClosure.lean:1716 path remains as an alternative approach (requires the composition theorem)
- Consider the GHR94 separation approach (Path A) as a last resort
