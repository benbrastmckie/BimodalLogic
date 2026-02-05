# Implementation Plan: Task #843

- **Task**: 843 - Remove singleFamily_modal_backward_axiom
- **Version**: 005
- **Created**: 2026-02-05
- **Status**: [NOT STARTED]
- **Effort**: 30-40 hours
- **Dependencies**: Task 856 (COMPLETED), Task 857 (COMPLETED)
- **Research Inputs**: research-010.md (axiom falsity), research-011.md (architecture), research-012.md (definitive analysis)
- **Artifacts**: plans/implementation-005.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Language**: lean

## Overview

This plan replaces BOTH axioms (`temporally_saturated_mcs_exists` and `singleFamily_modal_backward_axiom`) with proven constructions, achieving an axiom-free completeness theorem for TM bimodal logic. The approach separates temporal and modal concerns into independent constructions, then combines them.

**Key lesson from v004**: The constant-family approach to temporal saturation is mathematically false (`{F(psi), neg psi}` counterexample). Non-constant families are mandatory for temporal coherence.

**Architecture**: Two independent constructions combined:
1. **Temporal layer**: Non-constant dovetailing chain construction (new file `TemporalChain.lean`)
2. **Modal layer**: Multi-family saturated coherent bundle via iterative witness construction + Zorn (extending existing `CoherentConstruction.lean` and `eval_saturated_bundle_exists`)
3. **Combination**: Each constant family from the modal layer is "temporalized" by replacing it with a temporal chain starting from its MCS. GContent propagation preserves temporal coherence; BoxContent preservation requires including a modal core in chain seeds.

### What Changed from v004

| Aspect | v004 | v005 |
|--------|------|------|
| Temporal approach | Temporal Lindenbaum (single set, Zorn) | Dovetailing chain (non-constant family) |
| Modal approach | Not fully specified | Iterative saturation + Zorn on coherent bundles |
| Combination | Assumed constant families worked | Explicit temporalization of modal families |
| Key insight | Constant families suffice | Constant families are mathematically false for temporal; separate concerns |
| IndexedMCSFamily | Keep all 4 coherence fields | Drop forward_H and backward_G |

### Completeness Dependency Graph (Current)

```
bmcs_strong_completeness (sorry-free)
  -> bmcs_context_representation (sorry-free)
    -> construct_temporal_bmcs
      -> singleFamilyBMCS
        -> singleFamily_modal_backward_axiom  <- AXIOM 1 (FALSE)
      -> temporal_eval_saturated_bundle_exists
        -> temporally_saturated_mcs_exists     <- AXIOM 2 (FALSE)
    -> bmcs_truth_lemma (sorry-free)
```

### Target Dependency Graph

```
bmcs_strong_completeness (sorry-free, axiom-free)
  -> bmcs_context_representation (sorry-free, axiom-free)
    -> construct_axiomfree_bmcs
      -> build_temporal_chain (proven)          <- REPLACES AXIOM 2
      -> build_saturated_bmcs (proven)          <- REPLACES AXIOM 1
    -> bmcs_truth_lemma (sorry-free, unchanged)
```

## Goals & Non-Goals

**Goals**:
- Zero axioms in the completeness chain (`construct_temporal_bmcs` -> `bmcs_strong_completeness`)
- Remove the mathematically FALSE axiom `temporally_saturated_mcs_exists`
- Remove the mathematically FALSE axiom `singleFamily_modal_backward_axiom`
- Remove unnecessary `forward_H` and `backward_G` from `IndexedMCSFamily`
- Clean deletion of dead code (constant-family temporal infrastructure)
- All proofs compile with `lake build` at each phase boundary

**Non-Goals**:
- Removing orphaned axioms in dead code paths (`saturated_extension_exists`, `weak_saturated_extension_exists`)
- Boneyard moves (SaturatedConstruction.lean, PreCoherentBundle.lean, WeakCoherentBundle.lean)
- Logos/Automation sorry removal
- Module hierarchy restructuring

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BoxContent not preserved through temporal chains | H | M | Include ModalCore in chain seeds; proven consistent via subset argument |
| Multi-family consistency gap (UnionBoxContent) | H | M | Use BoxEquivalent + careful witness seed construction |
| Dovetailing enumeration complexity in Lean | M | M | Start with simple forward-only chain; add past direction separately |
| TruthLemma regression | H | L | TruthLemma uses only forward_G, backward_H, forward_F, backward_P -- all provided |
| Zorn formalization difficulty | M | M | Existing `set_lindenbaum` uses Zorn; pattern available |
| Phase interdependencies cause cascading rework | M | M | Each phase is independently verifiable; build-test at each boundary |

## Implementation Phases

### Phase 0: Simplify IndexedMCSFamily [NOT STARTED]

**Goal**: Remove unnecessary `forward_H` and `backward_G` fields from `IndexedMCSFamily`, reducing the proof obligations for all subsequent phases.

**Justification**: Research-011 Section 2.15 and Section 4.8 verified that the TruthLemma does NOT use `forward_H` or `backward_G`. These fields exist only because the constant-family construction provided them trivially. Removing them simplifies all downstream family constructions.

**Tasks**:
- [ ] Verify no downstream consumers of `forward_H` and `backward_G` (grep for usage)
- [ ] Remove `forward_H` field from `IndexedMCSFamily` structure
- [ ] Remove `backward_G` field from `IndexedMCSFamily` structure
- [ ] Remove derived lemmas that reference these fields (e.g., `GG_to_G` if it uses backward_G)
- [ ] Update `constantIndexedMCSFamily` in Construction.lean (remove those field proofs)
- [ ] Update `constantWitnessFamily` in ModalSaturation.lean (if it provides these fields)
- [ ] Update any other constructors that build `IndexedMCSFamily` instances
- [ ] Update `TemporalCoherentFamily.toIndexedMCSFamily` in TemporalCoherentConstruction.lean
- [ ] Run `lake build` and fix all compilation errors

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean` - Remove fields and derived lemmas
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Update `constantIndexedMCSFamily`
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Update `constantWitnessFamily`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Update `toIndexedMCSFamily`
- Any other files that construct `IndexedMCSFamily` instances

**Verification**:
- `lake build` succeeds with zero new errors
- `bmcs_truth_lemma` still compiles (it should, since it never used these fields)
- `bmcs_strong_completeness` still compiles

---

### Phase 1: Build Temporal Chain Construction [NOT STARTED]

**Goal**: Create a new file `TemporalChain.lean` implementing the dovetailing temporal chain construction that replaces the false `temporally_saturated_mcs_exists` axiom.

**Key Insight (from research-012 Section 1.6-1.8)**: Build a chain of MCS indexed by integers, where each MCS is constructed from a seed containing the temporal witnesses needed at that step. The dovetailing enumeration of (time, formula) pairs ensures every F-obligation gets a witness at some future step, without requiring F-formulas to propagate through GContent.

**Construction**:

```
chain(0) = M (the base MCS)

For step n > 0 (forward direction):
  let (t, k) = Nat.unpair n
  let phi_opt = Encodable.decode k
  if t is already constructed AND phi_opt = some phi AND F(phi) in chain(t):
    chain(n) = Lindenbaum({phi} union GContent(chain(n-1)))
  else:
    chain(n) = Lindenbaum(GContent(chain(n-1)))

Symmetric for negative steps (past direction using HContent and P-obligations).
```

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/TemporalChain.lean`
- [ ] Define `GContent` extractor: `GContent(M) = {phi | G(phi) in M}`
- [ ] Define `HContent` extractor: `HContent(M) = {phi | H(phi) in M}`
- [ ] Implement `temporalChainForward : Nat -> Set Formula` using dovetailing
  - Uses `Nat.pair`/`Nat.unpair` from Mathlib
  - Uses `Encodable Formula` (already proven in TemporalLindenbaum.lean)
  - At each step, constructs MCS via `set_lindenbaum` on the appropriate seed
- [ ] Implement `temporalChainBackward : Nat -> Set Formula` (symmetric for past)
- [ ] Define unified `temporalChain : Int -> Set Formula` combining forward and backward
- [ ] Prove `temporalChain_is_mcs : forall t, SetMaximalConsistent (temporalChain M h_mcs t)`
- [ ] Prove `temporalChain_base : temporalChain M h_mcs 0 = M`
- [ ] Prove GContent propagation: `GContent(chain(n)) subset chain(n+1)` (by seed inclusion)
- [ ] Prove `forward_G`: `G(phi) in chain(t) -> phi in chain(t')` for `t < t'`
  - Argument: G(phi) in chain(t) -> by 4-axiom, G(G(phi)) in chain(t) -> G(phi) in GContent(chain(t)) -> G(phi) in chain(t+1) -> ... -> G(phi) in chain(t') -> by T-axiom, phi in chain(t')
- [ ] Prove `backward_H`: symmetric using HContent
- [ ] Prove `forward_F`: `F(phi) in chain(t) -> exists s > t, phi in chain(s)`
  - Argument: The pair (t, encode(phi)) is enumerated at step n = Nat.pair(t, encode(phi)). At that step, chain(t) is already built, and if F(phi) in chain(t), phi is placed in chain(n+1) via the seed.
- [ ] Prove `backward_P`: symmetric
- [ ] Bundle into `temporalChainFamily : IndexedMCSFamily Int`
- [ ] Run `lake build` to verify

**Timing**: 8-10 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalChain.lean` - Full temporal chain construction

**Files to modify** (imports only):
- `Theories/Bimodal/Metalogic/Bundle/Bimodal.lean` or module root (if needed for imports)

**Key Dependencies** (all already proven):
- `temporal_witness_seed_consistent` (TemporalCoherentConstruction.lean:477) -- `{psi} union GContent(M)` consistent when `F(psi) in M`
- `temporal_witness_seed_consistent_past` (TemporalLindenbaum.lean:71) -- past analog
- `Encodable Formula` (TemporalLindenbaum.lean:157)
- `Nat.pair`/`Nat.unpair` (Mathlib.Data.Nat.Pairing)
- `set_lindenbaum` (MaximalConsistent.lean)

**Verification**:
- `lake build` succeeds
- The `temporalChainFamily` provides `forward_G`, `backward_H`, `forward_F`, `backward_P`
- No axioms used in the construction

---

### Phase 2: Build Multi-Family Modal Saturation [NOT STARTED]

**Goal**: Extend the existing `eval_saturated_bundle_exists` (proven, axiom-free) to achieve FULL modal saturation across all families, replacing `singleFamily_modal_backward_axiom`.

**Key Insight (from research-012 Section 2.7-2.10)**: Use Zorn's lemma on the collection of `EvalCoherentBundle`s ordered by family inclusion. A maximal bundle is fully saturated (if Diamond(psi) were unsatisfied, we could extend the bundle). The existing `diamond_boxcontent_consistent_constant` lemma (proven) provides the consistency argument at each witness addition.

**Architecture**:

The approach uses the existing `EvalCoherentBundle` infrastructure and extends it:

1. Define a partial order on `EvalCoherentBundle`s by family set inclusion
2. Prove chains have upper bounds (union of families preserves EvalCoherent)
3. Apply Zorn to get a maximal bundle
4. Prove the maximal bundle is fully modally saturated
5. Convert to full BMCS with proven `modal_forward` and `modal_backward`

For `modal_forward`: All families contain `BoxContent(eval)` by EvalCoherent. Since the eval family is fixed, `Box phi in eval.mcs t -> phi in BoxContent(eval) -> phi in all families`. For non-eval families, `modal_forward` requires BoxEquivalent or a more careful argument.

**The resolution for non-eval families**: For constant families built from `{psi} union BoxContent(eval)`, the only Box formulas they contain are:
- Those inherited from `BoxContent(eval)` (in the seed)
- Those added by Lindenbaum extension (uncontrolled)

For `modal_forward` from a witness family W: If `Box phi in W.mcs t`, we need `phi` in all other families. This requires either:
(a) Proving that `Box phi` from Lindenbaum extension implies `phi in BoxContent(eval)` -- NOT guaranteed
(b) Using `BoxEquivalent` to ensure all families share Box formulas
(c) Using a different BMCS construction

**Practical approach**: Use `BoxEquivalent` families. Build witnesses using seed `{psi} union BoxFormulaContent(eval)` where `BoxFormulaContent = {Box chi | Box chi in eval.mcs t} union {chi | Box chi in eval.mcs t}`. This ensures witnesses contain both the Box formulas and their contents. Then use Zorn on BoxEquivalent bundles.

Alternatively, recognize that the TruthLemma Box case at a NON-eval witness family W requires `Box phi in W -> phi in all families`. If we can ensure `Box phi in W -> Box phi in eval`, then by EvalCoherent, `phi in all families`. This is exactly BoxEquivalent at the Box-formula level.

**Tasks**:
- [ ] Define `BoxEquivalentBundle` structure (extending EvalCoherentBundle with BoxEquivalent)
- [ ] Prove that the singleton bundle `{eval}` is BoxEquivalent (trivially)
- [ ] Define the partial order on BoxEquivalentBundles by family inclusion
- [ ] Prove chain upper bounds preserve BoxEquivalent property
- [ ] Apply Zorn's lemma to get a maximal BoxEquivalentBundle
- [ ] Prove maximality implies full modal saturation
  - If Diamond(psi) in some family fam is unsatisfied, construct witness W from `{psi} union BoxFormulaContent(fam)`, prove BoxEquivalent is preserved, contradict maximality
- [ ] Prove `diamond_boxformulacontent_consistent`: If `Diamond(psi) in fam.mcs t` for a constant fam in a BoxEquivalent bundle, then `{psi} union BoxFormulaContent(fam)` is consistent
  - This extends the existing `diamond_boxcontent_consistent_constant` by including Box formulas in the seed
- [ ] Convert maximal BoxEquivalentBundle to BMCS with proven `modal_forward` and `modal_backward`
  - `modal_forward`: `Box phi in fam.mcs t -> Box phi in eval.mcs t` (BoxEquivalent) -> `phi in BoxContent(eval)` -> `phi in all families` (EvalCoherent)
  - `modal_backward`: from full saturation via `saturated_modal_backward` (already proven in ModalSaturation.lean)
- [ ] Run `lake build` to verify

**Timing**: 8-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Add BoxEquivalentBundle, Zorn proof, conversion to BMCS

**Key Dependencies** (all already proven):
- `eval_saturated_bundle_exists` (CoherentConstruction.lean:1405) -- base EvalCoherentBundle
- `diamond_boxcontent_consistent_constant` (CoherentConstruction.lean:249) -- witness seed consistency
- `constructCoherentWitness` (CoherentConstruction.lean:354) -- witness family builder
- `saturated_modal_backward` (ModalSaturation.lean:418) -- saturation implies modal_backward
- `set_lindenbaum` / Zorn's lemma (MaximalConsistent.lean, Mathlib.Order.Zorn)

**Verification**:
- `lake build` succeeds
- A function `build_saturated_bmcs : SetConsistent S -> BMCS Int` exists with no axiom dependencies
- `modal_forward` and `modal_backward` are proven (not assumed)

---

### Phase 3: Combine Temporal and Modal Constructions [NOT STARTED]

**Goal**: Replace each constant family from the modal BMCS with a temporal chain, producing a BMCS that is both modally and temporally coherent. This is the integration phase.

**Key Challenge (from research-012 Section 3.5-3.6)**: Temporal chains use GContent seeds, but modal coherence requires BoxContent preservation. These are independent -- `Box chi in M` does NOT imply `G chi in M`. Including GContent in seeds does NOT preserve BoxContent.

**Resolution**: Define a `ModalCore` for each family:
```
ModalCore(M) = {chi | Box chi in M} union {Box chi | Box chi in M}
```
Include `ModalCore(base_MCS)` in every temporal chain seed:
```
chain(n+1) = Lindenbaum({witness} union GContent(chain(n)) union ModalCore(chain(0)))
```

Since `ModalCore(M) subset M = chain(0)`, and `ModalCore(M)` is included in every seed, by Lindenbaum extension `ModalCore(M) subset chain(n)` for all n. This preserves BoxContent through the temporal chain.

**Consistency of enlarged seed**: `{witness} union GContent(chain(n)) union ModalCore(chain(0))`. Since both `GContent(chain(n))` and `ModalCore(chain(0))` are subsets of `chain(n)` (the former by T-axiom on G, the latter by inductive inclusion from seeds), the seed is `{witness} union subset_of_chain(n)`. By `temporal_witness_seed_consistent`, `{witness} union GContent(chain(n))` is consistent. The additional ModalCore elements are already in chain(n), so they don't change consistency.

Wait -- `temporal_witness_seed_consistent` proves `{psi} union GContent(N)` is consistent, NOT `{psi} union GContent(N) union extra`. Adding extra elements CAN break consistency. However, if the extra elements are already derivable from GContent(N) (i.e., they're in any MCS extending GContent(N)), then adding them doesn't change the consistency. Since `ModalCore(chain(0)) subset chain(n)` and `GContent(chain(n)) subset chain(n)`, any MCS extending `{psi} union GContent(chain(n))` must decide on each element of ModalCore. But we need a specific direction.

**Refined approach**: Prove a strengthened version of `temporal_witness_seed_consistent` that handles the enlarged seed. Specifically:

If `F(psi) in chain(n)` and `S subset chain(n)`, then `{psi} union GContent(chain(n)) union S` is consistent. This follows because `GContent(chain(n)) union S subset chain(n)` (consistent set), and `{psi} union GContent(chain(n))` is consistent (by existing lemma). Any inconsistency in `{psi} union GContent(chain(n)) union S` would give a derivation of bot from a finite subset. The elements from S are all in chain(n), and `GContent(chain(n)) subset chain(n)`, so the finite subset is contained in `{psi} union chain(n)`. But this IS the same as `insert psi chain(n)`, which may or may not be consistent.

Actually, `insert psi chain(n)` CAN be inconsistent (e.g., if `neg psi in chain(n)`). That's exactly the subtlety from research-012 Section 3.6.

**True resolution**: The `temporal_witness_seed_consistent` theorem specifically proves `{psi} union GContent(N)` (NOT `{psi} union N`). The GContent is a proper subset of N. Adding ModalCore (which is a subset of N but not necessarily of GContent(N)) enlarges the seed beyond what the theorem covers.

**Practical resolution**: There are two options:

**Option A (Simpler -- separate temporal and modal)**: Keep the modal BMCS as-is (constant families) and separately construct temporal coherence via a `TemporallyCoherentBMCS` wrapper that stores per-family temporal chains. The `temporally_coherent` predicate on the BMCS provides `forward_F` and `backward_P`, which are the only temporal properties the TruthLemma needs beyond `forward_G` and `backward_H`. In this option, each family in the BMCS stores TWO pieces: the constant MCS (for modal coherence) and a temporal chain starting from that MCS (for temporal coherence). The TruthLemma uses:
- `modal_forward`/`modal_backward` from the constant family BMCS structure
- `forward_G`/`backward_H` from the temporal chain's `IndexedMCSFamily`
- `forward_F`/`backward_P` from the temporal chain construction

This requires reconciling that the BMCS families use constant MCS but the truth evaluation uses temporal chains. The key: redefine the BMCS so that `families` contains temporal chains (non-constant `IndexedMCSFamily`), and modal coherence is at time 0 (or equivalently, all times share the modal properties from the base MCS).

**Option B (Correct -- prove enlarged seed consistency)**: Prove that `{psi} union GContent(N) union ModalCore(N_0)` is consistent when `F(psi) in N` and `ModalCore(N_0) subset N`. This uses the fact that `GContent(N) union ModalCore(N_0) subset N` and the proof of `temporal_witness_seed_consistent` generalizes: the K-distribution argument only uses elements from GContent, and the additional ModalCore elements don't interfere because they're already in N.

**Recommended**: Option A is simpler and more robust. The BMCS is redefined with non-constant temporal chain families. Modal coherence holds at time 0 and propagates (since BoxContent is in GContent for G-formulas... wait, Box and G are different operators).

**Actually, the cleanest approach** (from research-012 Section 3.6): Keep the two constructions SEPARATE:

1. Build the modal BMCS B with constant families (from Phase 2)
2. For each constant family (MCS M_i), build a temporal chain starting from M_i
3. Replace each constant family with its temporal chain in the BMCS
4. Modal coherence at each time t: for the temporal chain `chain_i(t)` built from M_i, we have `BoxContent(M_i) subset chain_i(t)` because ModalCore(M_i) is in every seed. So `Box phi in chain_i(t) -> phi in chain_i(t)` (T-axiom) but NOT `phi in chain_j(t)` unless `Box phi in M_j` originally.

This is the core challenge. For modal_forward: `Box phi in chain_i(t)` does NOT imply `Box phi in M_i` (since chain_i(t) may have new Box formulas from Lindenbaum). So we can't conclude `phi` is in other families.

**The actual resolution**: The TruthLemma evaluates `bmcs_truth_at B fam t phi` where the semantics of Box is: `Box phi true at (fam, t) iff phi true at (fam', t) for all fam' in B.families`. The key is that `bmcs_truth_at` uses the SAME time t for all families. So:

`Box phi in chain_i(t) -> [by modal_forward of B] -> phi in chain_j(t) for all j`

We need modal_forward to work with the temporal chain families, not the constant families. For this, we need: `Box phi in chain_i(t) -> phi in chain_j(t)` for all i, j, t.

This holds if:
1. BoxContent is preserved: if `Box phi in chain_i(t)`, then `Box phi in M_i` (the base) -- NO, this is not guaranteed as Lindenbaum can add new Box formulas.
2. Or: all temporal chains share BoxContent at every time -- requires including ALL families' BoxContent in every chain's seeds.

**Definitive resolution**: Use `GContent + ModalCore(M_i)` as the seed for chain_i, where `ModalCore(M_i)` includes both `{chi | Box chi in M_i}` and `{Box chi | Box chi in M_i}`. Since B is BoxEquivalent, `ModalCore(M_i) = ModalCore(M_j)` for all i, j. So ALL chains share the same ModalCore, meaning they all contain the same Box formulas (from the original constant families).

For `modal_forward` on temporal chains: `Box phi in chain_i(t)`. Two cases:
- `Box phi` was inherited from ModalCore (i.e., `Box phi in M_i`): By BoxEquivalent, `Box phi in M_j` for all j. By ModalCore inclusion, `Box phi in chain_j(t)`. By T-axiom, `phi in chain_j(t)`.
- `Box phi` was added by Lindenbaum extension: This Box formula is NOT in ModalCore and NOT guaranteed to be in other chains.

**The second case is the problem.** Lindenbaum can add arbitrary Box formulas.

**Final resolution (pragmatic)**: Accept that temporal chains may introduce new Box formulas that break inter-family modal coherence. To avoid this, use a **restricted Lindenbaum** that does not add new Box formulas, or use a **Box-closed seed** approach.

Actually, the simplest correct approach: **Don't temporalize at all for modal families. Use the temporal chain only for the eval family.** The TruthLemma evaluation starts at `(eval_family, 0)` and recurses. For Box subformulas, it evaluates at all families at the same time t. For temporal subformulas (G, H, F, P), it evaluates at the SAME family at different times. So:

- The eval_family needs to be a temporal chain (for temporal subformulas)
- Other families (witness families for diamonds) need to be evaluated at the SAME time as the eval_family
- Witness families can be constant (they don't need their own temporal structure)

Wait -- the TruthLemma recurses INTO witness families for the Box case. At a witness family W, if we encounter a G subformula, we need temporal coherence at W too. The TruthLemma is universally quantified over all families.

**True insight**: The TruthLemma requires ALL families to have temporal coherence (forward_G, backward_H, forward_F, backward_P). So we MUST temporalize all families.

**The correct and practical approach**: Build temporal chains with `GContent(chain(n-1))` as seed (no ModalCore), accepting that BoxContent is NOT preserved. Then handle modal coherence differently:

Define `modal_forward` for the temporalized BMCS as follows: We need `Box phi in chain_i(t) -> phi in chain_j(t)` for all i, j. Since this cannot be guaranteed by the construction (Lindenbaum adds uncontrolled Box formulas), we need a different formulation.

**KEY REALIZATION**: The modal BMCS structure requires `modal_forward` and `modal_backward` as fields. These are universally quantified over ALL families and ALL times. For non-constant families, these conditions become much harder to satisfy.

**The actual clean solution**: Define a TWO-LAYER BMCS structure:
1. **Inner layer** (modal): A set of MCS `{M_i}` with modal coherence (BoxEquivalent + saturated)
2. **Outer layer** (temporal): Each `M_i` is expanded to a temporal chain `chain_i`

The BMCS `families` are the temporal chains `{chain_i}`. The modal coherence conditions hold because:
- At time 0: `chain_i(0) = M_i`, and the M_i's are BoxEquivalent/saturated
- At other times: `chain_i(t)` preserves ModalCore(M_i) from seeds

But we already showed that ModalCore preservation through seeds requires the enlarged seed to be consistent, which is NOT guaranteed by `temporal_witness_seed_consistent` alone.

**FINAL PRAGMATIC RESOLUTION**:

Given the genuine mathematical difficulty of combining temporal and modal coherence in a single construction, we adopt a two-stage strategy:

**Stage A (this plan, Phases 0-2)**: Replace both FALSE axioms with CORRECT axioms:
- Replace `temporally_saturated_mcs_exists` with `temporal_chain_exists` (correct, asserting non-constant family)
- Replace `singleFamily_modal_backward_axiom` with `modal_saturated_bmcs_exists` (correct, asserting multi-family saturated BMCS)

**Stage B (Phase 3)**: Prove the temporal chain axiom, making it axiom-free.

**Stage C (Phase 4)**: Prove the modal saturation axiom, making it axiom-free.

**Stage D (Phase 5)**: Combine temporal and modal constructions, making the entire completeness chain axiom-free.

This staged approach ensures mathematical correctness at every step. The false axioms are removed immediately (Stage A), and full formalization proceeds incrementally.

**REVISED PLAN**: Given the deep analysis above revealing the genuine difficulty of Phase 3 as originally conceived, I am restructuring the plan into phases that deliver incremental value.

**Tasks** (for the revised Phase 3 -- Temporal Axiom Replacement):
- [ ] Define the correct temporal chain axiom `temporal_chain_exists`
- [ ] Replace `temporally_saturated_mcs_exists` with `temporal_chain_exists`
- [ ] Update `TemporalEvalSaturatedBundle` to use non-constant families
- [ ] Update `construct_temporal_bmcs` to use the new axiom
- [ ] Remove `TemporalForwardSaturated`, `TemporalBackwardSaturated` definitions (constant-family assumptions)
- [ ] Verify `bmcs_truth_lemma` still compiles with the updated construction
- [ ] Run `lake build`

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Replace axiom, update construction
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - May need import updates

**Verification**:
- `lake build` succeeds
- `temporally_saturated_mcs_exists` no longer exists in codebase
- `bmcs_strong_completeness` still compiles (now depends on `temporal_chain_exists` instead)
- The new axiom is mathematically TRUE (non-constant family existence)

---

### Phase 4: Prove Temporal Chain Construction [NOT STARTED]

**Goal**: Prove `temporal_chain_exists` as a theorem (replacing the axiom from Phase 3), using the dovetailing chain construction from Phase 1.

**Tasks**:
- [ ] Complete the temporal chain construction from Phase 1 (TemporalChain.lean)
- [ ] Prove `temporal_chain_exists` as a theorem using the construction
- [ ] Replace the axiom in TemporalCoherentConstruction.lean with the proven theorem
- [ ] Delete the axiom declaration
- [ ] Run `lake build`

**Timing**: 8-10 hours (includes Phase 1 work)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalChain.lean` - Complete construction and proofs
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Replace axiom with theorem

**Verification**:
- `lake build` succeeds
- `temporal_chain_exists` is a theorem, not an axiom
- Zero axioms in the temporal part of the completeness chain

---

### Phase 5: Prove Multi-Family Modal Saturation [NOT STARTED]

**Goal**: Prove `modal_saturated_bmcs_exists` as a theorem, eliminating the last axiom. This uses the Zorn-based construction from Phase 2.

**Tasks**:
- [ ] Complete the Zorn-based multi-family saturation proof from Phase 2
- [ ] Prove the modal saturation existence theorem
- [ ] Replace the axiom with the proven theorem
- [ ] Delete `singleFamily_modal_backward_axiom`
- [ ] Run `lake build`

**Timing**: 8-10 hours (includes Phase 2 work)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Complete saturation proof
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Delete old axiom

**Verification**:
- `lake build` succeeds
- `singleFamily_modal_backward_axiom` no longer exists
- Zero axioms in the modal part of the completeness chain

---

### Phase 6: Unified Axiom-Free BMCS Construction [NOT STARTED]

**Goal**: Combine the proven temporal chain and modal saturation constructions into a single `construct_axiomfree_bmcs` function. Handle the temporal-modal interaction carefully.

**Approach**: Build the BMCS in two steps:
1. Use `build_saturated_bmcs` to get a modally coherent BMCS with constant families
2. Replace each constant family `M_i` with `temporalChainFamily(M_i)` (from Phase 4)
3. Prove temporal coherence for each chain family
4. Prove modal coherence is preserved

For step 4, the challenge is Box formula preservation through temporal chains. Two sub-approaches:

**Sub-approach A**: Include ModalCore in chain seeds. Prove the enlarged seed `{witness} union GContent(chain(n)) union ModalCore(M_i)` is consistent using a generalized version of `temporal_witness_seed_consistent`. If this works, modal_forward follows from ModalCore inclusion + BoxEquivalent of base MCS.

**Sub-approach B**: Accept that modal_forward may not hold at all times for temporalized families. Instead, restructure the TruthLemma to separate temporal evaluation (within one family's chain) from modal evaluation (across families at the same time). This may require a different BMCS formulation.

**Sub-approach C (most practical)**: Observe that if we include `ModalCore(M_eval)` in every chain's seed (where M_eval is the eval family's base MCS, shared by all families via BoxEquivalent), then:
- All chains contain `{chi | Box chi in M_eval}` at all times
- All chains contain `{Box chi | Box chi in M_eval}` at all times
- For modal_forward: `Box phi in chain_i(t)`. If `Box phi in ModalCore(M_eval)`, then `phi in ModalCore(M_eval) subset chain_j(t)` for all j. If `Box phi` is from Lindenbaum (not in ModalCore), this is harder.

Actually, for the TruthLemma, `modal_forward` is used in the form: `Box phi in chain_i(t)` implies `phi in chain_j(t)` for all j. The induction is on formula complexity. At the point where Box phi is evaluated, phi is a strict subformula. The TruthLemma IH gives: `phi in chain_j(t) iff bmcs_truth_at B chain_j t phi`. So we need the syntactic membership `phi in chain_j(t)`, not just truth.

**The key constraint**: We need `Box phi in chain_i(t) -> phi in chain_j(t)` for ALL phi, not just subformulas. This is a semantic requirement on the BMCS.

**If we can prove the enlarged seed consistency**, this follows. Otherwise, we need a restricted formulation.

**Tasks**:
- [ ] Attempt Sub-approach A: prove enlarged seed consistency
  - Define `ModalCore(M)` = `{chi | Box chi in M} union {Box chi | Box chi in M}`
  - Prove `ModalCore(M) subset M` (by T-axiom and definition)
  - Prove `{psi} union GContent(N) union ModalCore(M)` is consistent when `F(psi) in N` and `ModalCore(M) subset N` and `N` is consistent
  - The key step: show that adding elements of N to the seed `{psi} union GContent(N)` doesn't break consistency. Since `GContent(N) union ModalCore(M) subset N`, any finite subset is from `{psi} union N`. We need `insert psi N` to be consistent when `F(psi) in N` -- but this is NOT always true (research-012 Section 1.4).
  - If this fails, try Sub-approach C or accept a correct axiom for the combination step
- [ ] If enlarged seed consistency is proven:
  - Build `temporalChainWithModalCore : MCS -> IndexedMCSFamily Int` using enlarged seeds
  - Replace constant families in BMCS with temporal chains
  - Prove `modal_forward` using ModalCore inclusion + BoxEquivalent
  - Prove `modal_backward` using saturation (unchanged)
  - Prove `temporally_coherent` for the new BMCS
- [ ] If enlarged seed consistency is NOT provable:
  - Accept a CORRECT axiom for the temporal-modal combination: `temporal_modal_chain_exists`
  - This axiom asserts: given a BoxEquivalent set of MCS, each can be extended to a temporal chain preserving BoxContent. This IS mathematically true.
  - Document as true but unformalized proof debt
- [ ] Define `construct_axiomfree_bmcs` (or `construct_correctaxiom_bmcs`)
- [ ] Rewire `Completeness.lean` to use the new construction
- [ ] Run `lake build`

**Timing**: 6-8 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalChain.lean` - Add ModalCore variant
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - New unified construction
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Update temporal BMCS construction
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Rewire to new construction

**Verification**:
- `lake build` succeeds
- `bmcs_strong_completeness` depends on zero FALSE axioms
- Ideally zero axioms total; at worst one CORRECT axiom for temporal-modal combination

---

### Phase 7: Cleanup and Documentation [NOT STARTED]

**Goal**: Remove dead code, update documentation, and ensure the codebase is clean.

**Tasks**:
- [ ] Delete or boneyard the old `TemporalForwardSaturated` / `TemporalBackwardSaturated` definitions
- [ ] Delete or boneyard the old `TemporalEvalSaturatedBundle` structure (if fully replaced)
- [ ] Delete the old `constantIndexedMCSFamily` (if no longer used)
- [ ] Delete the old `singleFamilyBMCS` (if no longer used)
- [ ] Clean up orphaned `saturated_extension_exists` axiom (CoherentConstruction.lean:871) -- move to Boneyard or delete
- [ ] Update module docstrings in all modified files
- [ ] Update Completeness.lean summary section (axiom status)
- [ ] Remove TemporalLindenbaum.lean (if completely superseded by TemporalChain.lean)
- [ ] Run `lake build` final verification
- [ ] Run `grep -r "axiom " Theories/Bimodal/Metalogic/Bundle/` to verify axiom count

**Timing**: 2-3 hours

**Files to modify**:
- All files in `Theories/Bimodal/Metalogic/Bundle/` (cleanup and documentation)

**Verification**:
- `lake build` succeeds
- `grep axiom` in active code shows zero axioms in completeness chain
- All dead code removed or moved to Boneyard

## Testing & Validation

- [ ] `lake build` succeeds with zero errors at each phase boundary
- [ ] `bmcs_truth_lemma` compiles without sorry at all phases
- [ ] `bmcs_strong_completeness` compiles without sorry at all phases
- [ ] After Phase 0: `IndexedMCSFamily` has 4 fields (mcs, is_mcs, forward_G, backward_H)
- [ ] After Phase 3: `temporally_saturated_mcs_exists` is gone; replaced by correct axiom
- [ ] After Phase 4: temporal axiom is proven (zero temporal axioms)
- [ ] After Phase 5: `singleFamily_modal_backward_axiom` is gone; proven via saturation
- [ ] After Phase 6: unified construction compiles
- [ ] After Phase 7: `grep -r "axiom " Theories/Bimodal/Metalogic/Bundle/` shows zero or one result (the temporal-modal combination, if needed)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/TemporalChain.lean` - New temporal chain construction
- Modified `IndexedMCSFamily.lean` - Simplified structure
- Modified `TemporalCoherentConstruction.lean` - New temporal axiom/theorem
- Modified `CoherentConstruction.lean` - Multi-family saturation proof
- Modified `Construction.lean` - Unified axiom-free construction
- Modified `Completeness.lean` - Rewired to new construction

## Rollback/Contingency

If the full axiom-free construction proves too difficult in Phase 6:
1. The codebase will still be in a correct state after Phases 0-5 (no FALSE axioms)
2. At worst, one CORRECT axiom remains for the temporal-modal combination
3. This is strictly better than the current state (two FALSE axioms)
4. The temporal chain and modal saturation can be used independently
5. Git history preserves all intermediate states for rollback

## Summary of Phased Value Delivery

| Phase | Axioms Before | Axioms After | Key Achievement |
|-------|--------------|-------------|-----------------|
| Phase 0 | 2 (both FALSE) | 2 (both FALSE) | Simplified IndexedMCSFamily |
| Phase 3 | 2 (both FALSE) | 2 (1 FALSE, 1 CORRECT) | Removed false temporal axiom |
| Phase 4 | 1 FALSE + 1 CORRECT | 1 FALSE | Proved temporal chain |
| Phase 5 | 1 FALSE | 1 CORRECT (maybe) | Removed false modal axiom |
| Phase 6 | 0-1 CORRECT | 0 | Fully axiom-free (goal) |
| Phase 7 | 0 | 0 | Clean codebase |
