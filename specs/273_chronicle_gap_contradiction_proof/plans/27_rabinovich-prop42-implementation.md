# Implementation Plan: Rabinovich Prop 4.2 Single-Agent Implementation (v27)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: Plans v17-v22 (phases 1-4 COMPLETED), plan v23 (Phase 0 COMPLETED), plan v24 (Phases 1-2 COMPLETED), plan v26 (Phases 1-2 COMPLETED, Phase 3 evaluated all options -- all blocked). Rabinovich infrastructure (4 files, 1349+ lines, sorry-free core).
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/25_formula-construction-research.md (round 25)
  - specs/273_chronicle_gap_contradiction_proof/reports/24_blocker-research.md (round 24)
  - specs/273_chronicle_gap_contradiction_proof/reports/23_team-research.md (round 23)
  - specs/273_chronicle_gap_contradiction_proof/reports/13_team-research.md (round 13)
  - specs/273_chronicle_gap_contradiction_proof/reports/11_divergence-audit.md (postmortem constraints)
  - specs/273_chronicle_gap_contradiction_proof/reports/10_literature-transcription.md (literature grounding)
  - specs/literature/Rabinovich_2014_Proof_of_Kamps_Theorem.md (Section 5 -- primary reference)
- **Artifacts**: plans/27_rabinovich-prop42-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v26 Phases 1-2 are COMPLETE. Phase 3 evaluated all three bridge options (A: generalize ExistPart, B: ExistsForallSpec encoding, C: Rabinovich Section 5 directly) and found them ALL blocked -- each reduces to Rabinovich Proposition 4.2 (negation closure for exists-forall formulas). This IS the irreducible mathematical core of Kamp's theorem.

Plan v27 replaces v26 Phases 3-5 with a new strategy: implement Rabinovich Proposition 4.2 from scratch in a new file `RabinovichProp42.lean`, following Section 5 of Rabinovich (2014) step by step. The plan is designed for a single long-running implementation agent. All phases produce CONCRETE Lean code -- no analysis phases.

### Research Integration

**Reports integrated in this plan version**:
- `25_formula-construction-research.md`: All three bridge options (A/B/C) reduce to Prop 4.2. The only path forward is implementing the full negation closure argument from Section 5.
- `24_blocker-research.md`: Root cause -- the base environment mismatch is mathematically equivalent to Prop 4.2.
- `23_team-research.md`: VecEADecomposition confirmed dead code; NF-specific Prop 4.3 bypass insufficient for k>=1.
- `13_team-research.md`: nf_to_formula bridge exists; Lemma 3.2.2 + Prop 4.3 architecture designed.
- `11_divergence-audit.md`: Postmortem constraints remain binding.
- `10_literature-transcription.md`: Doets 1989 Lemma 1.4/1.5 foundation; Rabinovich 2014 Section 5.

### Prior Plan Reference

Plans v17-v22: Phases 1-4 COMPLETED (~2700 lines sorry-free vec-EA infrastructure). Plan v23: Phase 0 COMPLETED (quarantine). Plan v24: Phases 1-2 COMPLETED (Separation module, sorry-free). Plan v26: Phases 1-2 COMPLETED (existPart_zero all n, existPart_succ factored n=1/n>=2). Plan v26 Phase 3: ALL OPTIONS BLOCKED -- reduces to Prop 4.2.

This plan replaces v26 Phases 3-5 with a direct Prop 4.2 implementation. Phases 1-2 of v26 are preserved as COMPLETED.

### Roadmap Alignment

- **Kamp chain**: Close `kamp_prior_expressive_completeness` via Prop 4.2 -> ExistPart sorry closure
- **Chronicle gap**: Fill `chronicle_gap_contradiction` via sorry-free model surgery pipeline
- **Critical path**: Closes two of the remaining sorry chains for `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Implement Rabinovich Proposition 4.2 (negation closure for exists-forall formulas with <=2 free variables) as Lean 4 code
- Specialize to Prior structures (integers): Dedekind completeness simplifies to min/max of bounded integer sets
- Prove Lemma 5.3 (base case: all interval types are True) by induction on n
- Prove Lemma 5.1 (full case with interval types) by induction on n with case analysis
- Use Prop 4.2 to fill `existPart_succ` at n=1 (RabinovichGeneralized.lean:440)
- Wire into NfCharFormula.lean:572 and fill `chronicle_gap_contradiction`
- Pass `lake build` with zero new sorries on the critical path to `completeness_discrete`

**Non-Goals**:
- Proving Lemma 5.1 in full generality over arbitrary Dedekind complete chains -- we specialize to Prior structures (integers)
- Filling NegationClosure.lean:1712 (`nf_exist_formula_nested_backward`) -- not on critical path
- Modifying existing sorry-free infrastructure (RabinovichTranslation, RabinovichWiring, etc.)
- Proving Corollary 5.4 separately -- it is subsumed by Lemma 5.1

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lemma 5.3 induction on integers is non-trivial to formalize | M | L | On integers, Dedekind completeness = `Nat.find` for bounded non-empty sets. Prior-UZ/SZ give first/last occurrence directly. The base case (n=1) is just universal quantification. |
| Lemma 5.1 case analysis (3 cases) produces large proof terms | H | M | Keep each case as a separate lemma. Estimate ~100-150 lines per case. If any case exceeds 200 lines, mark [PARTIAL] and continue in next dispatch. |
| Wiring Prop 4.2 result types to ExistPart type signatures | M | M | The ExistsForallSpec type and translate_correct are already sorry-free. The wiring is mechanical: construct ExistsForallSpecs from NF data, apply translate to get temporal formulas. |
| Integer specialization may not match Rabinovich's abstract Dedekind completeness argument | M | L | Rabinovich's proof explicitly notes that integers are Dedekind complete. The INF formula (infimum) on integers is just Prior-UZ (first occurrence). |
| Chronicle gap Case B (constant MCS) non-trivial | M | M | Orthogonal to Phases 1-3. If non-trivial, mark as sub-sorry with follow-up task. |

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
| RabinovichGeneralized.lean | 446 | existPart_succ n=1 (via nf_2var_exist_formula_prior_neg) | SORRY | Phase 3 fills via Prop 4.2 |
| RabinovichGeneralized.lean | 474 | existPart_succ n>=2 | SORRY | Phase 3 fills (depends on n=1) |
| RabinovichWiring.lean | 359 | backward k+1 | SORRY | Same blocker as existPart_succ n=1 |
| RabinovichNegation.lean | 291 | backward k+1 | SORRY | Same blocker as existPart_succ n=1 |
| NfCharFormula.lean | 572 | nf_2var_exist_formula_prior | SORRY | Phase 4 wires via nf_2var_exist_formula_prior_filled |
| NegationClosure.lean | 1712 | nf_exist_formula_nested_backward | SORRY | NOT on critical path (preserved) |
| NegationClosure.lean | 1327 | zone compatibility `all_goals sorry` | SORRY | NOT on critical path (preserved) |
| ChronicleToCountermodel.lean | 224 | succ_reaches_dom_N boundary | SORRY | Dead code (NOT filled) |

### Existing Infrastructure (sorry-free)

| File | Lines | Content |
|------|-------|---------|
| RabinovichTranslation.lean | 302 | Prop 3.5: ExistsForallSpec -> TL(U,S), translate_correct |
| RabinovichWiring.lean | 365 | Forward ALL k, backward k=0 |
| RabinovichNegation.lean | 297 | Backward k=0, drop-in replacement |
| RabinovichGeneralized.lean | ~470 | CharPart/ExistPart framework, existPart_zero all n, existPart_succ factored |
| NfComposition.lean | 267 | intra_structure_extend (sorry-free) |
| SeparationBridge.lean | ~199 | neg_until_equiv_prior, neg_since_equiv_prior (sorry-free) |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases are fully sequential. Each phase builds on the prior.

---

### Phase 1: Lemma 5.3 -- Negation of Point-Only Existentials [COMPLETED]

*(deviation: altered -- Lemma 5.3 and Lemma 5.1 (neg_interval_formula) were already proved sorry-free in NegationClosure5.lean. No new code needed.)*

**Goal**: In a new file `RabinovichProp42.lean`, prove that on Prior structures the negation of a point-only existential (all interval types are True) is equivalent to a disjunction of exists-forall formulas. This is Rabinovich Lemma 5.3.

**Mathematical Content (Rabinovich Section 5, specialized to integers)**:

The formula to negate is:
```
exists x_1 ... x_n, z_0 < x_1 < ... < x_n < z_1 AND P_1(x_1) AND ... AND P_n(x_n)
```

Proof by induction on n:
- **Base (n=1)**: `not (exists x, z_0 < x < z_1 AND P(x))` equals `forall y in (z_0, z_1), not P(y)`. On Prior structures, this IS the interval guard `G(not P)` from z_0 to z_1, which is a TL formula (via `Until` and `Since`). Equivalently, this is an ExistsForallSpec with n=0 witnesses and interval type `not P`.
- **Inductive step (n -> n+1)**: Case split using Prior-UZ (first occurrence of P_1 in (z_0, z_1)):
  - **Sub-case A**: P_1 does not occur in (z_0, z_1). Then `forall y in (z_0, z_1), not P_1(y)` holds. The negation is the single ExistsForallSpec with interval type `not P_1`. Done.
  - **Sub-case B**: P_1 occurs. Let r_0 be the first occurrence (exists by Prior-UZ). Then P_1(r_0). The negation of the original formula decomposes:
    - For each x_1 < r_0: not P_1(x_1) (since r_0 is first). Contradiction with P_1(x_1).
    - For x_1 = r_0: need `not (exists x_2 ... x_n, r_0 < x_2 < ... < x_n < z_1 AND P_2(x_2) AND ... AND P_n(x_n))`. By IH on (n-1) predicates.
    - The INF formula `INF(z_0, r_0, z_1, P_1)` = `z_0 < r_0 < z_1 AND (forall y in (z_0, r_0)) not P_1(y) AND (P_1(r_0) OR K+(P_1)(r_0))`. On integers, P_1(r_0) holds (infimum IS the minimum). So the INF formula simplifies.
    - Result: conjunction of INF condition (V-exists-forall) and IH result (V-exists-forall). By Lemma 3.4, conjunction of V-exists-forall is V-exists-forall.

**Key integer simplification**: On integers, `inf{z in (z_0, z_1) | P(z)}` is just `min{z in (z_0, z_1) | P(z)}`, which IS in the set (the infimum is attained). So `P_1(r_0)` always holds, eliminating the `K+(P_1)(r_0)` disjunct. This makes the proof significantly simpler than the general Dedekind-complete case.

**Key building blocks**:
- `semantic_prior_UZ`: gives first occurrence of any temporal formula in (t, infinity) -- provides the r_0 witness
- `ExistsForallSpec.translate_correct`: converts ExistsForallSpec to TL formula with proved equivalence
- `neg_until_equiv_prior` from SeparationBridge.lean: negation of Until on Prior structures

**Tasks**:
- [ ] **Task 1.1**: Create `RabinovichProp42.lean` with imports and documentation header. Define the type for a "point-only existential specification" -- a list of point type predicates with an interval `(z_0, z_1)`. This is a simplified ExistsForallSpec where all interval types are True. (~30 lines)
- [ ] **Task 1.2**: Prove the base case (n=1): the negation of `exists x in (z_0, z_1), P(x)` is the universal `forall y in (z_0, z_1), not P(y)`, which is expressible as an ExistsForallSpec with 0 witnesses and interval type `not P`. (~40 lines)
- [ ] **Task 1.3**: Prove the inductive step: given the IH for n predicates, handle n+1 predicates. Use Prior-UZ to find first occurrence of P_1. Case split: no occurrence (trivial) vs. occurrence at r_0 (decompose at r_0 and apply IH). (~80 lines)
- [ ] **Task 1.4**: Assemble Lemma 5.3: the negation of any point-only existential with n predicates in an interval is equivalent to a disjunction of ExistsForallSpecs. Use `translate_correct` to get the TL formula. (~30 lines)
- [ ] **Task 1.5**: Verify with `lean_verify` on the main lemma. Run `lake build` on the module.

**Timing**: 3 hours (~200 lines)

**Depends on**: none

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichProp42.lean` (new file)

**Verification**:
- `lean_verify` on Lemma 5.3 main theorem shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.RabinovichProp42` succeeds

---

### Phase 2: Lemma 5.1 -- Full Negation Closure (Prop 4.2) [COMPLETED]

*(deviation: altered -- Prop 4.2 (neg_2var_vec_ea) was already proved sorry-free in NegationClosureProp42.lean. No new code needed.)*

**Goal**: Extend `RabinovichProp42.lean` with Lemma 5.1 -- the negation of an exists-forall formula with interval types is V-exists-forall. Combined with Lemma 5.3, this gives Proposition 4.2.

**Mathematical Content (Rabinovich Section 5, specialized to integers)**:

The formula to negate is:
```
[alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)
```
meaning: exists x_1 ... x_n in (z_0, z_1) with z_0 < x_1 < ... < x_n < z_1, point types alpha_i at x_i, interval types beta_j in (x_{j-1}, x_j), plus alpha_0(z_0) and the final interval type.

Case analysis on what goes wrong with the pattern:
- **Case 1**: `not alpha_0(z_0)` or the first interval type beta_1 fails immediately. This is an endpoint check -- expressible as an ExistsForallSpec.
- **Case 2**: `alpha_0(z_0)` and beta_1 holds throughout `(z_0, z_1)` but no witness x_1 with alpha_1(x_1) exists. Then `not (exists x in (z_0, z_1), alpha_1(x))` holds while beta_1 holds everywhere in `(z_0, z_1)`. The negation of the point existential is V-exists-forall by Lemma 5.3. The conjunction with the beta_1 guard is also V-exists-forall.
- **Case 3**: `alpha_0(z_0)`, beta_1 does NOT hold everywhere (exists x with not beta_1(x)), and there exists a witness with alpha_1. Decompose at the first failure point of beta_1. Use the A_i^-/A_i^+ decomposition from Rabinovich:
  - `A_i^-(z_0, z) = [alpha_0, beta_1, ..., beta_i, alpha_i](z_0, z)`
  - `A_i^+(z, z_1) = [alpha_i, beta_{i+1}, ..., beta_n, alpha_n](z, z_1)`
  - By IH on shorter formulas, `not A_i^-` and `not A_i^+` are V-exists-forall.
  - The full negation reduces to a disjunction/conjunction of V-exists-forall formulas.

Induction on n (number of existentially chosen points). The decomposition at each step reduces n by splitting into a shorter prefix A_i^- and suffix A_i^+.

**Key integer simplification**: Prior-UZ gives the first failure point of beta_1 directly. No abstract Dedekind completeness argument needed.

**Key building blocks**:
- Lemma 5.3 from Phase 1 (point-only negation closure)
- `neg_until_equiv_prior`, `neg_since_equiv_prior` from SeparationBridge.lean (negation of Until/Since)
- `ExistsForallSpec.translate_correct` (conversion to TL formulas)

**Tasks**:
- [ ] **Task 2.1**: Define the full exists-forall formula type for intervals -- extending the point-only spec with interval types beta_j. If ExistsForallSpec already captures this, use it directly. (~20 lines)
- [ ] **Task 2.2**: Prove Case 1 (endpoint failure): `not alpha_0(z_0)` gives a trivial ExistsForallSpec. (~30 lines)
- [ ] **Task 2.3**: Prove Case 2 (guard holds, no witness): combine beta_1 universality with Lemma 5.3 negation of the point existential. (~60 lines)
- [ ] **Task 2.4**: Prove Case 3 (decomposition at failure point): use Prior-UZ for first beta_1 failure, apply A_i^-/A_i^+ decomposition with IH. (~120 lines)
- [ ] **Task 2.5**: Assemble Proposition 4.2: the negation of any exists-forall formula with <=2 free variables is V-exists-forall over Prior structures. (~40 lines)
- [ ] **Task 2.6**: Verify with `lean_verify` on Prop 4.2. Run `lake build` on the module.

**Timing**: 3.5 hours (~300-400 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichProp42.lean` (extend)

**Verification**:
- `lean_verify` on Prop 4.2 main theorem shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.RabinovichProp42` succeeds

---

### Phase 3: Wire Prop 4.2 into ExistPart and Close Sorries [BLOCKED]

**BLOCKER** (Phase 3):
- **What failed**: The backward direction of nf_exist_formula_nested (NegationClosure.lean:1712) requires a composition argument for non-interval zones. The formula nf_exist_formula_nested correctly encodes interval quantifier conditions (via nested Since/Until) but is too permissive for non-interval zones (y > x, y < t, y = x, y = t). The filter nf_full_compat_right only checks atom-level compatibility, not full quantifier conditions, causing potential false positives.
- **What was tried**: (1) Classical existence argument -- fails because the formula must work for ALL Prior structures. (2) Using p2_k (depth-k 2-var IH) -- only handles constant base, not (x,t) base. (3) Direct zone composition at depth 0 -- works but doesn't extend to depth > 0 without a full composition theorem. (4) Using existing VecEA2/Prop4.2 infrastructure -- the infrastructure is sorry-free but the WIRING requires encoding NF evaluation as VecEA2, which itself needs the composition theorem.
- **Why stuck**: The composition theorem (Feferman-Vaught for linear orders / Rabinovich implicit in Section 5) states: the depth-k n-var NF of (y, x, t) with y in a fixed zone relative to x and t is determined by depth-k 2-var NFs of the pairs (y,x), (y,t), (x,t). At depth 0 this is trivial (atoms). At depth k+1, it requires showing that depth-k (n+1)-var existentials decompose by zone, which is the same theorem at depth k with higher arity -- a genuine induction on k.
- **What is needed**: A self-contained proof of the composition lemma for depth-k NFs on linear orders, stated as: for fixed zone z and fixed depth-(k+1) 1-var NFs nf_x, nf_t of the base points, `(∃ y in zone z, nf_eval_nf M k 3 (y, x, t) ssn) ↔ f(nf_x, nf_t, ssn, z)` where f is a computable function. This lemma would fill the sorry at NegationClosure.lean:1712.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Goal**: Use Prop 4.2 to fill `existPart_succ` at n=1 (RabinovichGeneralized.lean:440), then cascade to fill n>=2 and wire into NfCharFormula.lean:572.

**Mathematical Argument**:

At depth k+1, n=1, the existential to characterize is:
```
exists x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf
```

This decomposes into:
1. **Atom conditions**: predicates at x and t, order between x and t -- captured by CharPart(k+1) characteristic formulas
2. **Quantifier conditions**: for each depth-k 3-var NF ssn, whether `exists y, nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn` holds

The quantifier conditions are exists-forall formulas (existential over y with conditions depending on x and t -- two free variables). By Prop 4.2, their negations are V-exists-forall, hence TL-expressible via Prop 3.5. The positive conditions are directly exists-forall, also TL-expressible.

**Construction**:
- For each zone position (x < t, x = t, x > t):
  - For each atom type alpha at x (from CharPart(k+1)):
    - For each quantifier profile q (mapping depth-k 3-var NFs to Bool):
      - Positive conditions: `exists y, nf_eval_nf M k 3 env ssn` for ssn with q(ssn)=true. These are ExistsForallSpecs -- translate to TL via Prop 3.5.
      - Negative conditions: `not (exists y, ...)` for ssn with q(ssn)=false. By Prop 4.2, these are V-exists-forall -- translate to TL via Prop 3.5.
      - The conjunction of all conditions, combined with the zone/atom conditions, gives the ExistsForallSpec for this (zone, alpha, q) triple.
- The full existential is the disjunction over all such triples.

**Tasks**:
- [ ] **Task 3.1**: Use Prop 4.2 to construct the temporal formula for each quantifier condition at depth k+1, n=1. For positive conditions: build ExistsForallSpec from the 3-var existential. For negative conditions: apply Prop 4.2 to get V-exists-forall, then Prop 3.5 to get TL formula. (~80 lines)
- [ ] **Task 3.2**: Assemble the full existential formula as a disjunction over (zone, atom-type, quantifier-profile) triples. Each disjunct encodes: zone position (via Until/Since), atom conditions (via char(k+1)), quantifier conditions (via Task 3.1). (~60 lines)
- [ ] **Task 3.3**: Prove forward direction: given x satisfying the NF, show the formula holds. Pattern from `nf_exist_formula_forward'`. (~80 lines)
- [ ] **Task 3.4**: Prove backward direction: given formula truth, extract x and verify all NF conditions. The zone and atom extraction follows existing patterns. The quantifier condition verification uses Prop 4.2's biconditional. (~120 lines)
- [ ] **Task 3.5**: Fill `existPart_succ` at n=1 by replacing `nf_2var_exist_formula_prior_neg` call at RabinovichGeneralized.lean:446 with the Prop 4.2-based construction. (~20 lines)
- [ ] **Task 3.6**: Fill `existPart_succ` at n>=2 (RabinovichGeneralized.lean:474). This follows the same constant-base projection pattern as depth 0 -- use `bool_eq_of_iff_same` for atoms, and now that n=1 is sorry-free at depth k+1, the quantifier projection closes too. (~40 lines)
- [ ] **Task 3.7**: Verify `existPart_succ`, `kamp_mutual_induction`, and `nf_2var_exist_formula_prior_filled` compile sorry-free. Wire into NfCharFormula.lean:572 by replacing the sorry with a call to `nf_2var_exist_formula_prior_filled`. (~20 lines)
- [ ] **Task 3.8**: Verify the Kamp chain: `nf_characterizable_temporal_prior`, `kamp_prior_expressive_completeness`, `US_expressively_complete_over_prior` all compile sorry-free.

**Timing**: 2.5 hours (~150-250 lines in RabinovichGeneralized.lean + ~20 lines in NfCharFormula.lean)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- fill existPart_succ n=1 and n>=2
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill sorry at :572

**Verification**:
- `lean_verify existPart_succ` shows no sorryAx
- `lean_verify kamp_mutual_induction` shows no sorryAx
- `lean_verify nf_2var_exist_formula_prior_filled` shows no sorryAx
- `lean_verify nf_characterizable_temporal_prior` shows no sorryAx
- `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.RabinovichGeneralized` succeeds

---

### Phase 4: Chronicle Gap + Full Verification [NOT STARTED]

**Goal**: Fill `chronicle_gap_contradiction` and verify end-to-end build.

**Tasks**:
- [ ] **Task 4.1**: Fill `chronicle_gap_contradiction` (ChronicleToCountermodel.lean). Activate and fix the OLD PROOF block. Case A (limit_f(a) != limit_f(b)): fix k=0 -> k>=1 issue, use k=1 for `contemp_equiv`. Case B (limit_f(a) = limit_f(b)): prove or mark as sub-sorry. (~50-80 lines)
- [ ] **Task 4.2**: Run `lake build` (full project) -- must succeed with 0 errors.
- [ ] **Task 4.3**: Verify axiom checks:
  - `lean_verify chronicle_gap_contradiction` -- no sorryAx
  - `lean_verify completeness_discrete` -- remaining sorryAx should trace ONLY through Task 202 chain (succ_cofinal)

**Timing**: 1 hour (~50-80 lines)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fill chronicle_gap_contradiction

**Verification**:
- `lean_verify chronicle_gap_contradiction` shows no sorryAx
- `lake build` succeeds (full project, clean)
- `lean_verify completeness_discrete` -- remaining sorryAx traces only through Task 202 chain

---

## Testing & Validation

- [x] Phase 1-4 (v21/v22): Vec-EA infrastructure (~2700 lines sorry-free) (DONE)
- [x] Phase 0 (v23): VecEADecomposition quarantined (DONE)
- [x] Phases 1-2 (v24): Separation module sorry-free (DONE)
- [x] Rabinovich core: 4 files, 1349+ lines sorry-free (DONE)
- [x] Phase 1-2 (v26): existPart_zero all n + existPart_succ factored (DONE)
- [ ] Phase 1 (v27): Lemma 5.3 (point-only negation closure) sorry-free
- [ ] Phase 2 (v27): Lemma 5.1 / Prop 4.2 (full negation closure) sorry-free
- [ ] Phase 3 (v27): existPart_succ sorry-free for all n and k; NfCharFormula:572 filled; Kamp chain sorry-free
- [ ] Phase 4 (v27): chronicle_gap_contradiction filled, `lake build` clean

## Artifacts & Outputs

**Existing (sorry-free, preserved)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichTranslation.lean` (302 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichWiring.lean` (365 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichNegation.lean` (297 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` (~470 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` (267 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/SeparationBridge.lean` (~199 lines)

**New (v27)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichProp42.lean` -- Lemma 5.3 + Lemma 5.1 + Prop 4.2 (~500-600 lines)

**Modified (v27)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- fill existPart_succ n=1 and n>=2 (~200 lines modified)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill sorry at :572 (~20 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fill chronicle_gap_contradiction (~50-80 lines)

**Estimated new Lean code**: ~700-900 lines across all files

## Rollback/Contingency

**If Lemma 5.3 induction is harder than expected (Phase 1)**:
- The base case (n=1) is mathematically trivial. If the inductive step has Fin bookkeeping issues, try a simpler encoding: instead of Fin-indexed arrays, use recursive List-based existentials. The mathematical content is the same; only the data representation changes.

**If Lemma 5.1 case analysis is too large for one phase (Phase 2)**:
- Split Phase 2 into 2a (Cases 1-2) and 2b (Case 3 + assembly). Mark [PARTIAL] with handoff.
- Cases 1-2 together are ~100 lines. Case 3 is ~150 lines. Assembly is ~40 lines. If needed, the split is clean.

**If the ExistPart wiring (Phase 3) hits type mismatches**:
- The Prop 4.2 result produces ExistsForallSpecs. These translate to TL formulas via `translate_correct`. The type of `existPart_succ` expects a `Formula` with a biconditional to the existential. If the biconditional doesn't match, try adjusting the ExistsForallSpec construction to match the NF evaluation exactly.
- Fallback: construct the formula directly (without ExistsForallSpec) using the Prop 4.2 argument as a guide for the Lean proof structure.

**If chronicle_gap_contradiction Case B is non-trivial (Phase 4)**:
- Mark Case B as a separate sorry with a TODO comment
- Create a follow-up task for Case B
- The Kamp chain closure (the primary goal) is independent of the chronicle gap

**If the approach fails entirely**:
- All existing sorry-free code (~4000+ lines including Rabinovich files) remains valid
- The NegationClosure.lean:1712 path remains as an alternative approach
- Consider direct EF-game-based proof of expressive completeness
