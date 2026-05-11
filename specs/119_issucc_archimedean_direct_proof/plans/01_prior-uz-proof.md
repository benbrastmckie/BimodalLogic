# Implementation Plan: Task #119 (Revised)

- **Task**: 119 - Prove IsSuccArchimedean via Prior-UZ Axiom Addition
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (all prerequisite infrastructure exists in Axioms.lean, Soundness.lean, SoundnessLemmas.lean, ChronicleToCountermodel.lean)
- **Research Inputs**:
  - specs/119_issucc_archimedean_direct_proof/reports/01_connectivity-proof-research.md
  - specs/119_issucc_archimedean_direct_proof/reports/05_team-research.md
  - specs/119_issucc_archimedean_direct_proof/reports/06_prior-uz-implementation.md
- **Artifacts**: plans/01_prior-uz-proof.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The previous plan (01_lex-pair-proof.md) attempted to prove `limitDomSubtype_isSuccArchimedean` directly from the existing BX axiom system using a lexicographic well-founded measure. Two implementation attempts confirmed that the key enabling lemma (birth-monotonicity) is false, and Round 5 team research proved that **IsSuccArchimedean is mathematically impossible to derive from the current axioms** -- the ZxZ counterexample (lexicographic order, componentwise addition) satisfies all BX + uniformity axioms but fails IsSuccArchimedean.

The fix, following Reynolds 1992 and Venema 1993, is to add **Prior-UZ** (`Fp -> U(p, neg p)`) and **Prior-SZ** (`Pp -> S(p, neg p)`) as axioms for the discrete case. These are sound on all discrete orders with IsSuccArchimedean (including Z) and, when added, make IsSuccArchimedean derivable for the limit domain construction.

This revised plan: (1) adds the axiom constructors and frame class machinery, (2) proves soundness on discrete frames, (3) updates all exhaustive pattern matches across the codebase, (4) derives IsSuccArchimedean from Prior-UZ using the finite omega-chain interval argument, and (5) wires up the discrete countermodel.

### Research Integration

- **01_connectivity-proof-research.md** (Round 1): Identified the sorry site and limit domain structure. Superseded by the impossibility finding.
- **05_team-research.md** (Round 5): Proved mathematical impossibility of IsSuccArchimedean under current axioms via ZxZ counterexample. Identified Prior-UZ as the fix. Recommended Option B (direct proof, ~400 lines).
- **06_prior-uz-implementation.md** (Round 6): Provided concrete Lean code for axiom constructors, frame class updates, soundness proof sketches, and analysis of the soundness architecture challenges.

### Prior Plan Reference

Previous plan 01_lex-pair-proof.md used a lexicographic `(domN_count, birth_stage)` well-founded measure. Birth-monotonicity (`birth(succ(z)) > birth(z)`) was proven false because `BurgessR3Maximal` at finite stages can be `Set.univ`. The lex-pair approach is abandoned entirely.

### Roadmap Alignment

This task closes the `limitDomSubtype_isSuccArchimedean` sorry at ChronicleToCountermodel.lean:1068 and, via Phase 5, aims to close the `dd_countermodel_chronicle_nondense_sorry` at line 825. The Prior-UZ axiom addition strengthens the BX system for discrete completeness, aligning with the Reynolds/Venema architecture.

## Goals & Non-Goals

**Goals**:
- Add `prior_UZ` and `prior_SZ` constructors to the `Axiom` inductive type
- Update `frameClass`, `isBase`, `isDenseCompatible`, `isDiscreteCompatible` to classify Prior-UZ/SZ as discrete-only
- Prove Prior-UZ and Prior-SZ valid on discrete frames (`valid_discrete`)
- Update all exhaustive pattern matches on `Axiom` across Soundness.lean, SoundnessLemmas.lean, and ProofSearch.lean
- Close the sorry at ChronicleToCountermodel.lean:1068 (`limitDomSubtype_isSuccArchimedean`)
- Ensure `lake build` passes after each phase with no new sorries
- Wire up the discrete countermodel using the sorry-free IsSuccArchimedean

**Non-Goals**:
- Full Reynolds/Doets transfer infrastructure (Ehrenfeucht-Fraisse games, quantifier depth, composition methods)
- Venema Stavi connective formalization
- Modifying the dense case or Cantor iso pathway
- Proving `dd_countermodel_chronicle_nondense_sorry` completely (Phase 5 may leave this as sorry if the FMCS transport is complex)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Frame class refactoring cascade: changing `isBase` from wildcard to explicit matches breaks many downstream proofs | H | H | Phase 2 is dedicated entirely to this. Use `cases h with` and add explicit arms for Prior-UZ/SZ. Build after each file. |
| General `soundness` theorem breaks: Prior-UZ is not universally valid, so the general `soundness` (which cases on all axioms) cannot prove `valid` for Prior-UZ | H | Certain | In Phase 2, handle Prior-UZ/SZ in the general `soundness` by extracting `isBase` or `isDenseCompatible` from the `h_dc` hypothesis. Since all existing axioms have `isBase = True`, only Prior-UZ/SZ need frame-class gating. |
| SoundnessLemmas.lean has 4 separate exhaustive matches on Axiom (axiom_swap_valid, axiom_locally_valid, and their general variants), each needing Prior-UZ/SZ cases | M | Certain | Systematic: grep for all `cases h with` on Axiom, add matching cases. These are mechanical but tedious. |
| Prior-UZ soundness proof requires well-founded descent on succ chains in abstract type class setting | M | M | Use `Nat.find` with `Classical.dec` and `IsSuccArchimedean.exists_succ_iterate_or_eq` from Mathlib. Fallback: sorry the validity and proceed to Phase 3. |
| IsSuccArchimedean derivation from Prior-UZ requires proving `limit_dom ∩ [a, b]` is finite | H | M | Use the omega-chain finiteness: both a, b appear at stage N, and Prior-UZ in every MCS prevents indefinite accumulation of new points in (a, b). Fallback: sorry the finiteness lemma and complete the main theorem structure. |
| `matchAxiom` in ProofSearch.lean needs new pattern matching arms for Prior-UZ/SZ formulas | L | Certain | Add `<|>` arms matching the Prior-UZ and Prior-SZ formula patterns. Mechanical. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Prior-UZ/SZ Axiom Constructors [COMPLETED]

**Goal**: Add the `prior_UZ` and `prior_SZ` constructors to the `Axiom` inductive type and update all frame class classification functions to mark them as discrete-only.

**Tasks**:
- [ ] Add `prior_UZ (phi : Formula) : Axiom (phi.some_future.imp (Formula.untl phi phi.neg))` constructor to the `Axiom` inductive type in Axioms.lean, after the Layer 5 uniformity axioms and before `deriving Repr`
- [ ] Add `prior_SZ (phi : Formula) : Axiom (phi.some_past.imp (Formula.snce phi phi.neg))` constructor
- [ ] Update `Axiom.frameClass` from wildcard `| _ => .Base` to explicit match: `| prior_UZ _ => .Discrete | prior_SZ _ => .Discrete | _ => .Base`
- [ ] Update `Axiom.isBase` from wildcard to: `| prior_UZ _ => False | prior_SZ _ => False | _ => True`
- [ ] Update `Axiom.isDenseCompatible` from wildcard to: `| prior_UZ _ => False | prior_SZ _ => False | _ => True`
- [ ] Keep `Axiom.isDiscreteCompatible` as `| _ => True` (Prior-UZ/SZ ARE discrete-compatible)
- [ ] Fix `Axiom.frameClass_eq_base_iff_isBase`: the `simp` proof will break because frameClass no longer always returns `.Base`. Rewrite as explicit case split.
- [ ] Fix `Axiom.isDiscreteCompatible_iff_frameClass`: `simp` will break. Rewrite with explicit cases.
- [ ] Fix `Axiom.isBase_implies_both_compatible`: may need explicit case split since `isBase` is no longer trivially `True`.
- [ ] Update the module docstring axiom count from "43 axiom constructors (39 base + 4 uniformity)" to "45 axiom constructors (39 base + 4 uniformity + 2 prior)"
- [ ] Run `lake build Bimodal.ProofSystem.Axioms` to verify compilation

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean`

**Verification**:
- `lake build Bimodal.ProofSystem.Axioms` passes
- `lean_goal` confirms no remaining goals in the three frame class theorems
- No sorries in Axioms.lean

---

### Phase 2: Soundness Infrastructure and Pattern Match Updates [COMPLETED]

**Goal**: Prove Prior-UZ and Prior-SZ valid on discrete frames, and update all exhaustive `cases h` pattern matches on `Axiom` constructors across the soundness infrastructure so that `lake build` passes.

**Tasks**:
- [ ] Write `prior_UZ_valid : valid_discrete (phi.some_future.imp (Formula.untl phi phi.neg))` in Soundness.lean. The proof uses `IsSuccArchimedean` (available in `valid_discrete` signature) to find the minimal future p-point via `Nat.find` or well-founded descent on the succ chain.
- [ ] Write `prior_SZ_valid : valid_discrete (phi.some_past.imp (Formula.snce phi phi.neg))` as the past mirror.
- [ ] Update `axiom_base_valid` in Soundness.lean: add `| prior_UZ _ => exact absurd h_base (by simp [Axiom.isBase])` and similarly for `prior_SZ`
- [ ] Update `axiom_valid_dense` in Soundness.lean: add `| prior_UZ _ => exact absurd h_dc (by simp [Axiom.isDenseCompatible])` and similarly for `prior_SZ`
- [ ] Update `axiom_valid_discrete` in Soundness.lean: add `| prior_UZ phi => exact prior_UZ_valid phi` and `| prior_SZ phi => exact prior_SZ_valid phi`
- [ ] Update the general `soundness` theorem (line 1142): add cases for `prior_UZ` and `prior_SZ`. Since these are NOT universally valid, the general `soundness` theorem needs restructuring. Approach: since all existing axioms have `isBase = True`, add `| prior_UZ _ => ...` and `| prior_SZ _ => ...` cases that prove validity using additional frame assumptions (or sorry these two cases if the general soundness restructuring is too complex, since `soundness_discrete` handles them correctly).
- [ ] Update `soundness_dense_valid` (line 1243): add `| .axiom _ _ (.prior_UZ _) => exact absurd h_dc (by simp [Axiom.isDenseCompatible, DerivationTree.isDenseCompatible])` and similarly for `prior_SZ`
- [ ] Update `soundness_dense` (line 1315): if it uses `axiom_valid_dense` in the axiom case, no change needed. Otherwise add Prior-UZ/SZ cases.
- [ ] Update `soundness_discrete_valid` (line 1414): axiom case already delegates to `axiom_valid_discrete`, which handles Prior-UZ/SZ from Phase 2 step 5. Verify no explicit match needed.
- [ ] Update `soundness_discrete` (line 1471): similarly verify no explicit match needed.
- [ ] Update `axiom_swap_valid` in SoundnessLemmas.lean: add `| prior_UZ phi => ...` and `| prior_SZ phi => ...` cases. These need to prove `is_valid D (prior_UZ_formula).swap_temporal` under `[DenselyOrdered D]`. Since Prior-UZ is `isDenseCompatible = False`, these cases should be discharged by `absurd h_dc (by simp [Axiom.isDenseCompatible])`.
- [ ] Update `axiom_locally_valid` in SoundnessLemmas.lean: same pattern -- absurd from `isDenseCompatible = False`.
- [ ] Update `axiom_swap_valid_general` and `axiom_locally_valid_general` in SoundnessLemmas.lean: these are the general (non-dense-gated) variants. They need to actually handle Prior-UZ/SZ. Since they prove `is_valid D phi` for all `D` (including non-discrete), Prior-UZ cases cannot be proved. Approach: either restrict these theorems with `isBase` guard, or sorry the Prior-UZ/SZ cases, or restructure to use `isDenseCompatible` guard.
- [ ] Update `matchAxiom` in ProofSearch.lean: add `<|>` arms to recognize the Prior-UZ and Prior-SZ formula patterns and return the corresponding `Axiom` constructors.
- [ ] Check for any other exhaustive matches on `Axiom` (Closure.lean, ProofExtraction.lean, DecisionProcedure.lean) and update as needed.
- [ ] Run `lake build` to verify full compilation

**Timing**: 3.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` -- validity proofs, axiom validators, soundness theorem updates
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- swap and local validity pattern match updates
- `Theories/Bimodal/Automation/ProofSearch.lean` -- matchAxiom pattern recognition
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean` -- if it pattern matches on Axiom
- `Theories/Bimodal/Metalogic/Decidability/ProofExtraction.lean` -- if it pattern matches on Axiom
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` -- if it pattern matches on Axiom

**Verification**:
- `lake build` passes with no new errors
- `prior_UZ_valid` and `prior_SZ_valid` have no sorry
- All soundness theorems compile
- `grep -rn "sorry" Theories/Bimodal/Metalogic/Soundness.lean` shows no new sorries
- `grep -rn "sorry" Theories/Bimodal/Metalogic/SoundnessLemmas.lean` shows no new sorries

---

### Phase 3: Prior-UZ Propagation to Limit Domain MCS [NOT STARTED]

**Goal**: Prove that every MCS in the limit domain contains Prior-UZ (because it is now a theorem of the proof system), establishing the key property needed for the IsSuccArchimedean derivation.

**Tasks**:
- [ ] Verify that `theorem_in_mcs` or equivalent in the chronicle construction automatically ensures that all axioms (including Prior-UZ) are in every MCS in `limit_dom`. Since `limit_f` assigns MCS's and axioms are theorems, `DerivationTree.axiom [] _ (Axiom.prior_UZ phi)` gives `[] ⊢ prior_UZ_formula`, and `theorem_in_mcs h_mcs (...)` puts it in every MCS.
- [ ] If the above is automatic (which it should be since Prior-UZ is now an axiom constructor), document this in a comment and proceed to Phase 4.
- [ ] If additional infrastructure is needed to propagate Prior-UZ to limit_dom MCS's, add the necessary lemmas in ChronicleToCountermodel.lean.
- [ ] Prove or verify: for any `x ∈ limit_dom`, `phi.some_future.imp (Formula.untl phi phi.neg) ∈ limit_f A h_mcs x` for all formulas `phi`.
- [ ] Run `lake build` to verify

**Timing**: 0.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add Prior-UZ membership lemmas if needed

**Verification**:
- `lake build` passes
- Prior-UZ membership in limit_dom MCS's is established or verified

---

### Phase 4: Derive IsSuccArchimedean from Prior-UZ [NOT STARTED]

**Goal**: Replace the sorry at ChronicleToCountermodel.lean:1068 with a complete proof of `limitDomSubtype_isSuccArchimedean`, using the Prior-UZ axiom to prove that `limit_dom ∩ [a, b]` is finite for any `a <= b` in LimitDomSubtype.

**Tasks**:
- [ ] Prove the key lemma `limit_dom_interval_finite`: for any `a <= b` in LimitDomSubtype, the set `{x in limit_dom | a.val <= x <= b.val}` is finite. The proof strategy:
  1. Both `a.val` and `b.val` appear at some stage `N` of the omega chain.
  2. At stage `N`, `omega_chain_val(N).dom` is a `Finset`, so there are finitely many domain points in `[a.val, b.val]`.
  3. Any new point added at stage `M > N` in the interval `(a.val, b.val)` would have to be inserted between two consecutive stage-N domain points.
  4. Use the discreteness hypothesis (`next_top in limit_f(x)` for all `x in limit_dom`) and Prior-UZ to show that between consecutive domain points, no new points can accumulate: Prior-UZ prevents the accumulation-at-external-point scenario.
  5. Conclude the interval is finite.
- [ ] Alternative approach if the finiteness lemma is too complex: use strong induction on `|omega_chain_val(N).dom ∩ (a.val, b.val]|` (which IS finite as a Finset), showing that the succ chain from `a` matches the omega-chain ordering within this interval. Each succ step either stays within the finset or reaches a point that is also in the finset at a later stage, and Prior-UZ prevents infinite descent.
- [ ] Complete the `limitDomSubtype_isSuccArchimedean` proof: once finiteness of the interval is established, use induction on the cardinality of `limit_dom ∩ (a.val, b.val]` to show `succ^[n](a) = b` for some `n`.
- [ ] Run `lake build` to verify

**Timing**: 3.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace sorry at line 1068 with complete proof, add finiteness lemma

**Verification**:
- `lake build` passes with no errors
- `grep "sorry" ChronicleToCountermodel.lean` shows no sorry at `limitDomSubtype_isSuccArchimedean`
- `lean_goal` at end of `limitDomSubtype_isSuccArchimedean` shows "no goals"
- `discrete_iso` (line 1081) still compiles

---

### Phase 5: Wire Up Discrete Countermodel [NOT STARTED]

**Goal**: With `limitDomSubtype_isSuccArchimedean` proved sorry-free, verify that `discrete_iso` compiles and connect the discrete completeness path by completing or advancing `dd_countermodel_chronicle_nondense_sorry`.

**Tasks**:
- [ ] Verify `discrete_iso` (line 1081) compiles without sorry, since it depends on `limitDomSubtype_isSuccArchimedean`
- [ ] Verify `discrete_fmcs_f`, `discrete_fmcs_c0`, and related Z-isomorphism transport definitions compile
- [ ] Assess `dd_countermodel_chronicle_nondense_sorry` (line 825): determine what remains to complete this theorem. It requires constructing a discrete BFMCS (bounded FMCS) on Int, analogous to `cantor_bfmcs_dense` for the dense case.
- [ ] If the BFMCS construction is straightforward (transport through `discrete_iso`), complete it. If it requires significant additional infrastructure, document what remains and leave the sorry with a clear explanation.
- [ ] Run `lake build` to verify full compilation

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- verify/complete discrete countermodel

**Verification**:
- `lake build` passes
- `grep -c "sorry" ChronicleToCountermodel.lean` shows equal or fewer sorries than before
- `discrete_iso` is sorry-free
- Document any remaining sorries with clear descriptions

## Testing & Validation

- [ ] `lake build` passes with no new errors after each phase
- [ ] `grep -rn "sorry" Theories/Bimodal/ProofSystem/Axioms.lean` shows 0 sorries
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/Soundness.lean` shows no new sorries
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/SoundnessLemmas.lean` shows no new sorries
- [ ] `limitDomSubtype_isSuccArchimedean` has no sorry
- [ ] `discrete_iso` compiles and has no sorry
- [ ] `dd_countermodel_chronicle_dense` (line 790) still works (regression check)
- [ ] The overall sorry count in ChronicleToCountermodel.lean is equal or lower

## Artifacts & Outputs

- `Theories/Bimodal/ProofSystem/Axioms.lean` -- Modified: Prior-UZ/SZ constructors, frame class updates
- `Theories/Bimodal/Metalogic/Soundness.lean` -- Modified: validity proofs, soundness theorem updates
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- Modified: pattern match updates
- `Theories/Bimodal/Automation/ProofSearch.lean` -- Modified: matchAxiom updates
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- Modified: sorry replaced, finiteness lemma added
- `specs/119_issucc_archimedean_direct_proof/plans/01_prior-uz-proof.md` -- This plan file

## Rollback/Contingency

If the implementation encounters blockers at any phase:

1. **Phase 1 rollback**: Remove the two constructors from `Axiom` and revert wildcard matches. Single file change (Axioms.lean).

2. **Phase 2 fallback**: If the general `soundness` theorem restructuring is too complex, sorry the Prior-UZ/SZ cases in `soundness` only (since `soundness_discrete` is the one used for discrete completeness, and it will work correctly). Similarly, sorry the Prior-UZ/SZ cases in `axiom_swap_valid_general` and `axiom_locally_valid_general` if needed.

3. **Phase 4 fallback**: If the finiteness lemma is too hard to prove directly, sorry the finiteness lemma and complete the rest of the `limitDomSubtype_isSuccArchimedean` proof around it. This localizes the remaining sorry to a single clear mathematical claim ("discrete intervals in limit_dom are finite") rather than the sprawling original sorry.

4. **Phase 5 fallback**: The discrete countermodel (`dd_countermodel_chronicle_nondense_sorry`) can remain as sorry if the BFMCS transport is complex. The primary goal (closing the IsSuccArchimedean sorry) is achieved in Phase 4.

5. **Full rollback**: `git checkout -- Theories/` restores all files. All changes are in the `Theories/Bimodal/` tree.
