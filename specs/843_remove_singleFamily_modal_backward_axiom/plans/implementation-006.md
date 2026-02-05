# Implementation Plan: Task #843 (v006)

- **Task**: 843 - Remove singleFamily_modal_backward_axiom
- **Status**: [PARTIAL]
- **Effort**: 42-59 hours
- **Dependencies**: Task 856 (COMPLETED), Task 857 (COMPLETED)
- **Research Inputs**: research-014.md (approach comparison), research-015.md (S5 Box invariance breakthrough, cross-task synthesis)
- **Artifacts**: plans/implementation-006.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Language**: lean

## Overview

This plan eliminates BOTH axioms (`singleFamily_modal_backward_axiom` and `temporal_coherent_family_exists`) from the completeness proof chain using the **S5-based full canonical model construction with time-shifted temporal chains**, as identified in research-015. The key breakthrough is S5 Box invariance: in our proof system (which has T, 4, B, 5-collapse axioms for Box), Box formulas are uniform across all MCS -- if Box phi is in any MCS, it is in every MCS. This makes modal_forward trivial. Combined with time-shifted temporal chains (which ensure every MCS appears as some family's evaluation at every time), modal_backward follows by contraposition via diamond-witness construction. This approach resolves the BoxContent preservation problem that blocked all 14 prior rounds of research.

### Research Integration

- **research-015.md** (primary): S5 Box invariance theorem, time-shifted chain construction, 6-phase estimate with verification of all BMCS conditions (Sections 4.5-6.5)
- **research-014.md** (secondary): Comprehensive comparison of 5 approaches, identification of the BoxContent preservation problem as fundamental obstacle, confirmation that temporal dovetailing chain is well-understood
- **research-004.md** (task 865): Construction B2 (family-indexed canonical task frame), confirms BMCS layer is independent from task frame representation layer

### What Changed from v005

| Aspect | v005 | v006 |
|--------|------|------|
| Modal approach | Iterative saturation + Zorn on coherent bundles | S5 Box invariance + time-shifted chains |
| Family set | Iteratively constructed coherent bundle | All temporal chains from all MCS, time-shifted |
| BoxContent preservation | Open problem (blocked v005) | Resolved via S5 invariance (Box uniform across MCS) |
| modal_forward proof | Required BoxContent inclusion in chain seeds | Trivial via S5 invariance + T-axiom |
| modal_backward proof | Required full saturation construction | Contraposition via diamond witness at shifted chain |
| Combination strategy | Temporalize constant modal families | All families are temporal chains from the start |
| Estimated effort | 30-40h | 42-59h (more phases, but each is well-understood) |

### Completeness Dependency Graph (Current)

```
bmcs_strong_completeness (sorry-free)
  -> bmcs_context_representation (sorry-free)
    -> construct_temporal_bmcs
      -> singleFamilyBMCS
        -> singleFamily_modal_backward_axiom  <- AXIOM 1 (FALSE)
      -> temporal_eval_saturated_bundle_exists
        -> temporal_coherent_family_exists     <- AXIOM 2 (CORRECT, unproven)
    -> bmcs_truth_lemma (sorry-free)
```

### Target Dependency Graph

```
bmcs_strong_completeness (sorry-free, axiom-free)
  -> bmcs_context_representation (sorry-free, axiom-free)
    -> construct_s5_canonical_bmcs
      -> build_temporal_dovetailing_chain (proven)    <- REPLACES AXIOM 2
      -> s5_box_invariance (proven)                   <- ENABLES modal_forward
      -> time_shifted_chain_bmcs (proven)             <- REPLACES AXIOM 1
    -> bmcs_truth_lemma (sorry-free, unchanged)
```

## Goals & Non-Goals

**Goals**:
- Zero axioms in the completeness chain (`construct_s5_canonical_bmcs` -> `bmcs_strong_completeness`)
- Remove the mathematically FALSE axiom `singleFamily_modal_backward_axiom` via S5-based multi-family construction
- Remove the correct-but-unproven axiom `temporal_coherent_family_exists` via dovetailing temporal chain theorem
- Prove S5 Box invariance (`Box phi in M -> Box phi in M'` for any two MCS) as a key enabling lemma
- Prove modal_forward and modal_backward for the time-shifted chain BMCS
- All proofs compile with `lake build` at each phase boundary
- Preserve the existing sorry-free `bmcs_truth_lemma` unchanged

**Non-Goals**:
- Removing orphaned axioms in dead code paths (`saturated_extension_exists`, etc.)
- Boneyard moves of legacy construction files
- Task 865 (canonical task frame bridge) -- fully independent
- Removing sorries in `eval_bmcs_truth_lemma` (legacy EvalBMCS approach)
- Module hierarchy restructuring

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| S5 Box invariance proof more complex than expected | High | Medium | Well-established result in modal logic; proof sketch verified in research-015 Section 6.5; can be proven via canonical accessibility relation symmetry |
| Dovetailing chain cross-sign forward_G/backward_H | Medium | Medium | Two known approaches: (1) single bidirectional chain with interleaved steps, (2) global Zorn argument. Phase 1 addresses this directly. |
| Time-shifted chain temporal coherence | Low | Low | Pure time translation; inherits ALL properties from base chain. Research-015 Section 6.3 verifies. |
| Diamond-BoxContent consistency for non-constant families | Medium | Low | Generalization of proven `diamond_boxcontent_consistent_constant`; same K-distribution argument at single time point |
| Large (uncountable) family set | Low | Low | Set-theoretic construction; Lean handles via `Set (IndexedMCSFamily D)` with Classical.choice |
| Interaction with existing TemporalChain.lean (4 sorries) | Medium | Low | New construction replaces rather than extends; existing file becomes dead code |

## Sorry Characterization

### Pre-existing Sorries
- 4 sorries in `TemporalChain.lean` (forward_G cross-sign, backward_H cross-sign, forward_F, backward_P)
- 4 sorries in `eval_bmcs_truth_lemma` (EvalBMCS structural limitations, not in scope)

### Expected Resolution
- Phase 1 resolves the 4 `TemporalChain.lean` sorries by building a complete dovetailing chain with all properties proven
- The `eval_bmcs_truth_lemma` sorries are out of scope (legacy approach)

### New Sorries
- None expected. Each phase has a clear mathematical path verified in research-015.

### Remaining Debt
After this implementation:
- 0 axioms in the completeness chain
- 0 sorries in the main completeness path (`bmcs_truth_lemma` through `bmcs_strong_completeness`)
- 4 sorries remain in legacy `eval_bmcs_truth_lemma` (out of scope, structural limitation of EvalBMCS)
- Publication no longer blocked by axiom dependencies

## Axiom Characterization

### Pre-existing Axioms
- `singleFamily_modal_backward_axiom` in `Construction.lean:210` (FALSE -- `phi in M -> Box phi in M` is invalid)
- `temporal_coherent_family_exists` in `TemporalCoherentConstruction.lean:578` (CORRECT but unproven)

### Expected Resolution
- Phase 1 eliminates `temporal_coherent_family_exists` via dovetailing temporal chain theorem
- Phases 2-5 eliminate `singleFamily_modal_backward_axiom` via S5-based full canonical model
- Phase 6 rewires completeness to use the new axiom-free construction

### New Axioms
- None. Zero-axiom target for the entire completeness chain.

### Remaining Debt
After this implementation:
- 0 axioms in `bmcs_strong_completeness` dependency tree (excluding Lean builtins)
- `#print axioms bmcs_strong_completeness` shows ONLY `propext`, `Quot.sound`, `Classical.choice`
- Orphaned axioms in dead code paths (`saturated_extension_exists`, `weak_saturated_extension_exists`) remain as cleanup debt

## Implementation Phases

### Phase 1: Temporal Dovetailing Chain [COMPLETED]

**Goal:** Build a complete `IndexedMCSFamily Int` with all four temporal coherence properties (forward_G, backward_H, forward_F, backward_P) proven, eliminating `temporal_coherent_family_exists`.

**Tasks:**
- [ ] Define `DovetailingChain` structure: `Int -> Set Formula` using `Nat.pair`/`Nat.unpair` to enumerate `(formula, time)` pairs
- [ ] Implement forward chain: `chain(n+1)` extends `GContent(chain(n))` with F-witness at dovetailed step
- [ ] Implement backward chain: `chain(-(n+1))` extends `HContent(chain(-n))` with P-witness at dovetailed step
- [ ] Handle chain junction at 0 (shared base MCS from Lindenbaum)
- [ ] Prove `forward_G` for ALL index pairs (including cross-sign case t < 0 < t')
- [ ] Prove `backward_H` for ALL index pairs (including cross-sign case t' < 0 < t)
- [ ] Prove `forward_F` via dovetailing enumeration completeness (Encodable.decode surjectivity)
- [ ] Prove `backward_P` symmetrically
- [ ] Build `IndexedMCSFamily Int` from the dovetailing chain
- [ ] Prove `temporal_coherent_family_exists` as a THEOREM (replacing the axiom)
- [ ] Verify `lake build` succeeds

**Cross-sign resolution strategy:** Use a single unified chain that interleaves forward and backward steps. At each natural number n, process BOTH a forward obligation (at index +n) and a backward obligation (at index -n). The seed at each step includes TemporalContent (GContent union HContent) from the ADJACENT chain element, ensuring G-formulas propagate forward AND H-formulas propagate backward across the junction at 0.

**Timing:** 18-21 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (NEW) -- Main dovetailing chain construction
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- Replace axiom with theorem call

**Verification:**
- `lake build` succeeds
- `#print axioms temporal_coherent_family_exists` shows ONLY Lean builtins (or definition is deleted and theorem replaces it)
- Forward_F and backward_P pass Lean's type checker without sorry

**Dependencies:** None (independent of all other phases)

---

### Phase 2: S5 Box Invariance Lemma [BLOCKED]

**Goal:** Prove that Box formulas are uniform across all MCS: `Box phi in M -> Box phi in M'` for any two MCS M, M'. This is the key enabling lemma that resolves the BoxContent preservation problem.

**Tasks:**
- [ ] Prove the canonical accessibility relation is symmetric: `BoxContent(M) subset M' -> BoxContent(M') subset M`
  - Uses `modal_b` (phi -> Box(Diamond phi)) applied to `neg chi` to derive contradiction
  - Research-015 Section 6.5 provides the proof: from Box chi in M', suppose chi not in M, then neg chi in M, by modal_b Box(Diamond(neg chi)) in M, Diamond(neg chi) in BoxContent(M) subset M', but Box chi in M' so chi in M' and neg(neg chi) in M', then derive neg(Box(neg(neg chi))) = Diamond(chi) ... need careful syntactic argument
- [ ] Prove the canonical accessibility relation is transitive (from `modal_4`)
- [ ] Prove the canonical accessibility relation is universal (single equivalence class, from reflexivity + symmetry + transitivity in standard canonical model)
- [ ] Prove `s5_box_invariance`: `SetMaximalConsistent M -> SetMaximalConsistent M' -> Box phi in M -> Box phi in M'`
  - Via: Box phi in M, suppose Box phi not in M', then neg(Box phi) in M'. By modal_5_collapse contrapositive: Box(neg(Box phi)) in M'. Since accessibility is symmetric and M' accessible from M, neg(Box phi) in M. Contradiction with Box phi in M.
- [ ] Prove corollary: `BoxContent(M) = BoxContent(M')` for any two MCS
- [ ] Prove corollary: `Box phi in M iff phi is a theorem` (S5 characteristic)

**Timing:** 6-10 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/S5Properties.lean` (NEW) -- S5 Box invariance and related lemmas
- May extend `Theories/Bimodal/Theorems/ModalS5.lean` with new derivable theorems

**Verification:**
- `lake build` succeeds
- `s5_box_invariance` type-checks without sorry
- Statement matches: `(hM : SetMaximalConsistent M) -> (hM' : SetMaximalConsistent M') -> Formula.box phi in M -> Formula.box phi in M'`

**Dependencies:** None (independent of Phase 1; uses only proof system axioms and MCS properties)

---

### Phase 3: Generalized Diamond-BoxContent Consistency [NOT STARTED]

**Goal:** Prove that for any MCS M containing Diamond(psi), the set `{psi} union {chi | Box chi in M}` is consistent, without requiring M to come from a constant family. This generalizes `diamond_boxcontent_consistent_constant` from `CoherentConstruction.lean`.

**Tasks:**
- [ ] Define `BoxContentAt(M)` for a bare MCS M (not requiring IndexedMCSFamily): `{chi | Box chi in M}`
- [ ] Prove `diamond_boxcontent_consistent_mcs`: For any MCS M with Diamond(psi) in M, the set `{psi} union BoxContentAt(M)` is consistent
  - Proof: Same K-distribution argument as `diamond_boxcontent_consistent_constant` but operating on a single MCS rather than requiring a constant family wrapper
  - Key steps: Suppose inconsistent. Then finite subset `{chi_1, ..., chi_n} subset BoxContentAt(M)` derives `neg psi`. By K-distribution and necessitation: `Box(neg psi)` derivable from `{Box chi_1, ..., Box chi_n}`. All Box chi_j are in M. So `Box(neg psi) in M`. But Diamond(psi) = neg(Box(neg psi)) in M. Contradiction with MCS consistency.
- [ ] Prove that Lindenbaum extension of `{psi} union BoxContentAt(M)` produces an MCS W with:
  - `psi in W`
  - `BoxContentAt(M) subset W` (i.e., chi in W for all chi with Box chi in M)

**Timing:** 3-5 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/S5Properties.lean` -- Add generalized consistency lemma (same file as Phase 2)
- OR `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` -- Extend existing module

**Verification:**
- `lake build` succeeds
- `diamond_boxcontent_consistent_mcs` type-checks without sorry
- Lemma is usable with bare `Set Formula` MCS (no `IndexedMCSFamily` wrapper required)

**Dependencies:** None (independent of Phases 1-2; uses only MCS properties and K-distribution)

---

### Phase 4: Time-Shifted Temporal Chains [NOT STARTED]

**Goal:** Define `shiftedChain(M, s)` -- a temporal chain starting from MCS M centered at time s -- and prove that temporal coherence properties are preserved under time translation.

**Tasks:**
- [ ] Define `shiftedChain`: Given an MCS M and starting time s : D, produce an `IndexedMCSFamily D` where `shiftedChain(M, s).mcs(t) = temporalChain(M).mcs(t - s)`
  - `temporalChain(M)` is the dovetailing chain from Phase 1 (with D = Int and M at index 0)
- [ ] Prove `shiftedChain_at_start`: `shiftedChain(M, s).mcs(s) = temporalChain(M).mcs(0) = M`
- [ ] Prove `shiftedChain_forward_G`: Inherited from `temporalChain` via index translation
- [ ] Prove `shiftedChain_backward_H`: Inherited from `temporalChain` via index translation
- [ ] Prove `shiftedChain_forward_F`: Inherited from `temporalChain` via index translation
- [ ] Prove `shiftedChain_backward_P`: Inherited from `temporalChain` via index translation
- [ ] Prove `shiftedChain_is_mcs`: `shiftedChain(M, s).mcs(t)` is an MCS for all t (inherited from chain)

**Timing:** 4-6 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/ShiftedChain.lean` (NEW) -- Time-shifted chain definition and properties
- Imports `DovetailingChain.lean` from Phase 1

**Verification:**
- `lake build` succeeds
- All four temporal coherence properties proven for `shiftedChain` without sorry
- `shiftedChain_at_start` confirms the chain is centered at the specified time

**Dependencies:** Phase 1 (requires `temporalChain` definition and properties)

---

### Phase 5: S5 Canonical BMCS Construction [NOT STARTED]

**Goal:** Construct the full BMCS using time-shifted chains from ALL MCS, and prove modal_forward and modal_backward. This eliminates `singleFamily_modal_backward_axiom`.

**Tasks:**
- [ ] Define the family set: `s5_families := { shiftedChain(M, s) | M : MCS, s : Int }`
  - In Lean: `Set.range (fun (pair : (Set Formula) x Int) => shiftedChain pair.1 pair.2)` restricted to MCS M
- [ ] Define eval family: `shiftedChain(lindenbaum(Gamma), 0)`
- [ ] Prove `s5_modal_forward`: Box phi in any family at time t implies phi in every family at time t
  - Proof (research-015 Section 6.1): `shiftedChain(M, s).mcs(t)` is an MCS. Box phi in this MCS. By `s5_box_invariance` (Phase 2): Box phi in every MCS. In particular, Box phi in `shiftedChain(M', s').mcs(t)` (another MCS). By T-axiom: phi in `shiftedChain(M', s').mcs(t)`.
- [ ] Prove `s5_modal_backward`: phi in ALL families at time t implies Box phi in any family at time t
  - Proof (research-015 Section 6.2): Suppose Box phi not in `shiftedChain(M, s).mcs(t)`. Let N = `shiftedChain(M, s).mcs(t)`. Then Diamond(neg phi) in N. By `diamond_boxcontent_consistent_mcs` (Phase 3): `{neg phi} union BoxContentAt(N)` is consistent. Let W = Lindenbaum extension. W is an MCS with neg phi in W. Consider `shiftedChain(W, t)`. By definition, `shiftedChain(W, t).mcs(t) = W`. Since W is an MCS, `shiftedChain(W, t)` is in `s5_families`. But phi is in ALL families at time t, so phi in `shiftedChain(W, t).mcs(t) = W`. Contradiction: phi and neg phi both in W.
- [ ] Prove temporal coherence for all families: inherited from `shiftedChain` (Phase 4)
- [ ] Prove context preservation: Gamma subset lindenbaum(Gamma) = `shiftedChain(lindenbaum(Gamma), 0).mcs(0)`
- [ ] Construct `BMCS Int` from the above components
- [ ] Prove `construct_s5_canonical_bmcs_temporally_coherent`: all families satisfy forward_F and backward_P
- [ ] Prove `construct_s5_canonical_bmcs_contains_context`: original context preserved at eval family

**Timing:** 8-12 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/S5CanonicalBMCS.lean` (NEW) -- Full BMCS construction
- Imports from Phases 1-4

**Verification:**
- `lake build` succeeds
- `s5_modal_forward` and `s5_modal_backward` proven without sorry
- `construct_s5_canonical_bmcs` produces a valid `BMCS Int` without axiom dependencies
- `#print axioms construct_s5_canonical_bmcs` shows ONLY Lean builtins

**Dependencies:** Phases 1-4 (requires dovetailing chain, S5 invariance, diamond consistency, shifted chains)

---

### Phase 6: Integration and Axiom Removal [NOT STARTED]

**Goal:** Rewire the completeness theorems to use the new S5 canonical BMCS construction, and verify that both axioms are eliminated from the dependency tree.

**Tasks:**
- [ ] Modify `Completeness.lean` to use `construct_s5_canonical_bmcs` instead of `construct_temporal_bmcs`
  - Update `bmcs_representation` to call the new construction
  - Update `bmcs_context_representation` similarly
  - Provide `temporally_coherent` proof from `construct_s5_canonical_bmcs_temporally_coherent`
- [ ] Verify `bmcs_truth_lemma` still works unchanged (it only requires a valid BMCS + temporal coherence)
- [ ] Verify all three completeness theorems compile without sorry
- [ ] Run `#print axioms bmcs_strong_completeness` and confirm ONLY Lean builtins appear
- [ ] Run `#print axioms bmcs_weak_completeness` similarly
- [ ] Run `#print axioms bmcs_representation` similarly
- [ ] Comment out (do not delete yet) the two axiom declarations:
  - `singleFamily_modal_backward_axiom` in `Construction.lean:210`
  - `temporal_coherent_family_exists` in `TemporalCoherentConstruction.lean:578`
- [ ] Update module documentation to reflect axiom-free status
- [ ] Final `lake build` to verify everything compiles

**Timing:** 3-5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` -- Rewire to new construction
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` -- Comment out axiom
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- Comment out axiom

**Verification:**
- `lake build` succeeds with zero errors
- `#print axioms bmcs_strong_completeness` shows ONLY `propext`, `Quot.sound`, `Classical.choice`
- Both axiom declarations are commented out
- All existing tests/theorems still compile

**Dependencies:** Phase 5 (requires the complete S5 canonical BMCS)

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `#print axioms bmcs_strong_completeness` shows only Lean builtins after Phase 6
- [ ] `#print axioms bmcs_weak_completeness` shows only Lean builtins after Phase 6
- [ ] `#print axioms bmcs_representation` shows only Lean builtins after Phase 6
- [ ] No new `sorry` declarations introduced in any phase
- [ ] `bmcs_truth_lemma` remains unchanged and sorry-free
- [ ] Forward_F and backward_P for dovetailing chain verified in Phase 1
- [ ] S5 Box invariance verified in Phase 2
- [ ] Modal_forward and modal_backward verified in Phase 5

## Artifacts & Outputs

- `plans/implementation-006.md` (this file)
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (NEW, Phase 1)
- `Theories/Bimodal/Metalogic/Bundle/S5Properties.lean` (NEW, Phases 2-3)
- `Theories/Bimodal/Metalogic/Bundle/ShiftedChain.lean` (NEW, Phase 4)
- `Theories/Bimodal/Metalogic/Bundle/S5CanonicalBMCS.lean` (NEW, Phase 5)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` (MODIFIED, Phase 6)
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If the S5 Box invariance proof (Phase 2) proves intractable in Lean formalization:
- **Fallback A**: Use the proof via canonical model construction (define accessibility relation, prove equivalence relation, derive invariance). More verbose but well-established.
- **Fallback B**: If the full S5 argument fails, Phase 1 (temporal chain) is independently valuable and can be committed separately, reducing axiom count from 2 to 1.

If the time-shifted chain approach (Phase 4-5) encounters unforeseen type-theoretic issues:
- **Fallback C**: Use constant witness families (from proven `eval_saturated_bundle_exists`) for modal saturation, accepting that constant families lack temporal coherence. Replace `temporal_coherent_family_exists` axiom with a CORRECT axiom for the combined temporal+modal construction.

If any phase exceeds its time estimate by 50%:
- Commit partial progress with `sorry` markers at the blocking point
- Document the obstacle in the plan file
- Create a focused sub-task for the blocking lemma
