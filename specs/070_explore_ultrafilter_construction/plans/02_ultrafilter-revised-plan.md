# Implementation Plan: Task #70 - Ultrafilter-Based Temporal Coherence (Revised v2)

- **Task**: 70 - Explore ultrafilter-based construction for temporal coherence
- **Status**: [IN PROGRESS]
- **Effort**: 10-14 hours
- **Dependencies**: None (all infrastructure exists)
- **Research Inputs**:
  - reports/05_team-research.md (synthesized team findings)
  - reports/05_teammate-a-findings.md (Phase 4 sorry strategies)
  - reports/05_teammate-b-findings.md (Phases 5-7 design)
  - summaries/01_ultrafilter-summary.md (Phases 1-3 completion)
- **Artifacts**: plans/02_ultrafilter-revised-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan completes the ultrafilter-based construction for achieving family-level temporal coherence in BFMCS, which is the final blocker for modal completeness. The ultrafilter approach eliminates the "F-persistence gap" that plagues MCS-based constructions: ultrafilters have automatic negation completeness (exactly one of a or a^c in U), preventing G(neg phi) from entering when F(phi) is present.

The plan follows the **ultrafilter route** (not truth lemma modification) as requested, using the correct definitions of logical consequence and validity from the official TaskFrame semantics. All proofs respect the dependency graph (no circular dependencies) and leverage the existing sorry-free infrastructure from Phases 1-3.

### Research Integration

From the team research (reports/05_team-research.md):
- **Phase 4 has 3 sorries** with complete proof strategies verified
- **Phase 5 can proceed immediately** - not blocked by Phase 4 sorries
- **Phases 6-7 are blocked** by `ultrafilter_F_resolution` (Sorry 2)
- **Two paths to completeness exist** - this plan follows the ultrafilter route

Key infrastructure confirmed:
- `lce_imp`, `rce_imp` (Propositional.lean:737,755) - conjunction elimination
- `pairing`, `imp_trans` (Combinators.lean) - derivation combinators
- `temp_k_dist` (Axiom) and `past_k_dist` (GeneralizedNecessitation.lean:81) - K-axiom distribution
- `set_lindenbaum` (Core.lean) - Zorn-based MCS extension
- `mcsToUltrafilter`, `ultrafilterToSet_mcs` (UltrafilterMCS.lean) - bijection

## Goals and Non-Goals

**Goals**:
- Prove all 3 Phase 4 sorries (`G_preimage_inf`, `ultrafilter_F_resolution`, `ultrafilter_P_resolution`)
- Implement Phase 5: `UltrafilterChain_to_FMCS` conversion
- Implement Phase 6: Family-level temporal coherence (`ultrafilter_FMCS_forward_F`, `ultrafilter_FMCS_backward_P`)
- Implement Phase 7: Integration with `parametric_canonical_truth_lemma` via `BFMCS.temporally_coherent`
- Achieve sorry-free path from MCS construction to completeness theorem

**Non-Goals**:
- Modifying the truth lemma to accept bundle-level coherence (Path B approach)
- Resolving sorries in the Z_chain/omega_chain constructions (separate approach)
- Changing the official semantics or TaskFrame definitions

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `G_preimage_inf` proof more complex than anticipated | M | L | lce_imp/rce_imp confirmed to exist; proof is mathematically routine |
| Type-matching bookkeeping between Formula and LindenbaumAlg | M | M | Use `Quotient.ind` pattern consistently; bridge via `toQuot` |
| H_preimage_inf infrastructure missing | H | L | `past_k_dist` confirmed at line 81; symmetric to G case |
| Chain extension problem in Phase 6 | H | M | Use `UltrafilterChain.shift` or construct new chain from V |
| `set_lindenbaum` consistency proof complex | M | M | Detailed proof sketch provided in teammate-a-findings |

## Implementation Phases

### Phase 4A: Prove G_preimage_inf [COMPLETED]

**Goal**: Complete the K-axiom distribution proof for G_preimage closure under meets.

**Tasks**:
- [ ] Add helper lemma `G_inf_le` proving `STSA.G a inf STSA.G b <= STSA.G (a inf b)`
- [ ] Unfold to derivation level via `Quotient.ind` on both `a` and `b`
- [ ] Build derivation: `pairing` -> `temporal_necessitation` -> 2x `temp_k_dist` -> `imp_trans`
- [ ] Use `lce_imp`/`rce_imp` to connect `(G(phi) and G(psi)) -> G(phi and psi)`
- [ ] Complete the `G_preimage_inf` theorem using `U.mem_of_le` with `h_K_inf`

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (line ~697)

**Verification**:
- `lake build` passes
- `sorry` count in UltrafilterChain.lean decreases by 1 (from 3 Phase 4 sorries to 2)

**Proof Sketch** (from teammate-a):
```lean
have h_K_inf : STSA.G a ⊓ STSA.G b ≤ STSA.G (a ⊓ b) := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  show Derives (φ.all_future.and ψ.all_future) (φ.and ψ).all_future
  unfold Derives
  -- Step 1: pairing φ ψ : [] ⊢ φ.imp (ψ.imp (φ.and ψ))
  -- Step 2: temporal_necessitation: [] ⊢ (φ.imp (ψ.imp (φ.and ψ))).all_future
  -- Step 3: temp_k_dist φ (ψ.imp (φ.and ψ)): [] ⊢ G(φ) → G(ψ → φ∧ψ)
  -- Step 4: temp_k_dist ψ (φ.and ψ): [] ⊢ G(ψ → φ∧ψ) → G(ψ) → G(φ∧ψ)
  -- Step 5: imp_trans: [] ⊢ G(φ) → G(ψ) → G(φ∧ψ)
  -- Step 6: Use lce_imp/rce_imp to get (G(φ) ∧ G(ψ)) → G(φ∧ψ)
```

---

### Phase 4B: Add H_preimage_inf [COMPLETED]

**Goal**: Add the symmetric H-preimage closure lemma needed for `ultrafilter_P_resolution`.

**Tasks**:
- [ ] Define `H_preimage` analogously to `G_preimage` (if not already defined)
- [ ] Add `H_preimage_top` (H_preimage contains top)
- [ ] Add `H_preimage_upward` (H_preimage is upward closed)
- [ ] Add `H_preimage_inf` using `past_k_dist` (GeneralizedNecessitation.lean:81)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- `lake build` passes
- New lemmas added for H analogous to G

**Note**: This phase can run in parallel with Phase 4A since they use symmetric but independent infrastructure.

---

### Phase 4C: Prove ultrafilter_F_resolution [PARTIAL]

**Goal**: Prove the core filter extension theorem: F(a) in U implies existence of successor ultrafilter containing a.

**Tasks**:
- [ ] Extract formula representative: `obtain <phi, rfl> := Quotient.exists_rep a`
- [ ] Define seed formula set: `{ psi | Formula.all_future psi in MU } union {phi}`
- [ ] Prove seed is `SetConsistent` via case analysis:
  - [ ] Case phi not in L: L subset G-preimage, fold leads to G(bot) contradiction
  - [ ] Case phi in L: L\{phi} derives neg(phi), so G(neg(phi)) in U, contradicts h_F
- [ ] Apply `set_lindenbaum` to extend seed to MCS M
- [ ] Construct ultrafilter V via `mcsToUltrafilter <M, hM_mcs>`
- [ ] Prove `R_G U V`: for all b, G(b) in U -> b in V (seed subset M)
- [ ] Prove `a in V`: phi in seed subset M

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (line ~729)

**Verification**:
- `lake build` passes
- `sorry` count decreases by 1

**Dependencies**: Phase 4A (`G_preimage_inf` required for consistency proof)

**Proof Sketch** (seed consistency - the crux):
```lean
have h_seed_cons : SetConsistent seed := by
  intro L hL h_incons
  by_cases h_phi_in_L : φ ∈ L
  · -- Hard case: φ ∈ L
    -- L\{φ} ⊢ ¬φ (deduction theorem from L ⊢ ⊥)
    -- All ψ in L\{φ} have G(ψ) ∈ MU
    -- By G_preimage_inf: G(⋀(L\{φ})) ∈ U
    -- G(⋀(L\{φ})) ≤ G(¬φ) by G_monotone (since ⋀(L\{φ}) ≤ ¬φ)
    -- So G(¬φ) ∈ U, but h_F : (G(¬φ))ᶜ ∈ U → contradiction
  · -- Easy case: φ ∉ L
    -- L ⊆ G-preimage part, so ⋀L ≤ ⊥
    -- G(⋀L) ∈ U by G_preimage_inf
    -- G(⊥) ∈ U by upward closure → contradiction
```

---

### Phase 4D: Prove ultrafilter_P_resolution [PARTIAL]

**Status Note (2026-03-30)**: The main proof structure is complete. Two sorries remain:
1. Line 1113: Corner case where `φ ∈ L_no_phi` but `φ ∉ G_seed` in F_resolution
2. Line 1322: Symmetric corner case in P_resolution

The sorries are for a degenerate edge case where the witness formula appears multiple times
in the list but isn't in the G-preimage. This requires either:
- Strong induction on the count of non-G_seed elements
- Or showing this case is actually impossible via MCS properties

**Goal**: Prove the symmetric past filter extension theorem: P(a) in U implies existence of predecessor ultrafilter containing a.

**Tasks**:
- [ ] Mirror Phase 4C structure with H replacing G
- [ ] Use `H_preimage_inf` from Phase 4B
- [ ] Define seed: `{ psi | Formula.all_past psi in MU } union {phi}`
- [ ] Prove seed consistency (symmetric argument with H)
- [ ] Apply `set_lindenbaum`, construct V via `mcsToUltrafilter`
- [ ] Prove `R_H U V` and `a in V`

**Timing**: 1-2 hours (faster due to symmetry with Phase 4C)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (line ~738)

**Verification**:
- `lake build` passes
- All Phase 4 sorries resolved
- `#print axioms ultrafilter_P_resolution` shows no `sorryAx`

**Dependencies**: Phase 4B (`H_preimage_inf` required)

---

### Phase 5: UltrafilterChain to FMCS Conversion [COMPLETED]

**Goal**: Implement conversion from `UltrafilterChain` to `FMCS Int` structure.

**Tasks**:
- [ ] Define `noncomputable def UltrafilterChain_to_FMCS (uc : UltrafilterChain) : FMCS Int`
- [ ] Set `mcs := fun t => (ultrafilter_to_mcs (uc.chain t)).val`
- [ ] Prove `is_mcs` from `ultrafilter_to_mcs` return type
- [ ] Prove `forward_G` using `UltrafilterChain.forward_G` (already proven)
- [ ] Prove `backward_H` using `UltrafilterChain.backward_H` (already proven)
- [ ] Add bridge lemma: `phi in ultrafilter_to_mcs U <-> toQuot phi in U`

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (or new file `UltrafilterFMCS.lean`)

**Verification**:
- `lake build` passes
- New `UltrafilterChain_to_FMCS` compiles without sorry
- `#print axioms UltrafilterChain_to_FMCS` shows no `sorryAx`

**Dependencies**: None (uses only sorry-free Phase 1-3 infrastructure)

**Note**: This phase can run in parallel with Phases 4A-4D.

**Type Signature**:
```lean
noncomputable def UltrafilterChain_to_FMCS (uc : UltrafilterChain) : FMCS Int where
  mcs        := fun t => (ultrafilter_to_mcs (uc.chain t)).val
  is_mcs     := fun t => (ultrafilter_to_mcs (uc.chain t)).property
  forward_G  := fun t t' phi h_le h_G => ...  -- uses uc.forward_G
  backward_H := fun t t' phi h_le h_H => ...  -- uses uc.backward_H
```

---

### Phase 6A: Ultrafilter FMCS Forward F Coherence [NOT STARTED]

**Goal**: Prove that ultrafilter-based FMCS have family-level forward F coherence.

**Tasks**:
- [ ] Define `structure UltrafilterFMCS extends FMCS Int` with:
  - [ ] `uc : UltrafilterChain`
  - [ ] `mcs_eq : forall t, mcs t = ultrafilter_to_mcs (uc.chain t)`
- [ ] Prove `ultrafilter_FMCS_forward_F`:
  - [ ] Given F(phi) in mcs t, translate to (G(neg phi))^c in uc.chain t
  - [ ] Apply `ultrafilter_F_resolution` to get V with R_G(chain t, V) and phi in V
  - [ ] Construct successor chain or use V at t+1
  - [ ] Return s = t+1 with t <= s and phi in mcs s

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (or new file)

**Verification**:
- `lake build` passes
- `ultrafilter_FMCS_forward_F` compiles without sorry

**Dependencies**: Phase 4C (`ultrafilter_F_resolution`)

**Chain Extension Challenge**:
The key challenge is extending from a single successor V to a full chain. Options:
1. **One-step extension**: Define `extend_chain_one_step (uc : UltrafilterChain) (V : Ultrafilter) (h : R_G (uc.chain t) V) : UltrafilterChain` that replaces chain(t+1) with V and continues from there
2. **Use existing shift**: `UltrafilterChain.shift` can create a chain starting from any position
3. **Construct fresh chain from V**: Build new chain using `ultrafilter_F_resolution` recursively

For Phase 6, we need to show existence of s >= t with phi in mcs s. The simplest approach:
- Apply `ultrafilter_F_resolution` to get V
- phi in V means phi in ultrafilter_to_mcs V
- If V = chain(t+1), done with s = t+1
- Otherwise, need to justify that any ultrafilter with phi can be the t+1 position

**Type Signature**:
```lean
theorem ultrafilter_FMCS_forward_F (uf : UltrafilterFMCS)
    (t : Int) (phi : Formula) (h_F : Formula.some_future phi ∈ uf.mcs t) :
    ∃ s : Int, t ≤ s ∧ phi ∈ uf.mcs s
```

---

### Phase 6B: Ultrafilter FMCS Backward P Coherence [NOT STARTED]

**Goal**: Prove that ultrafilter-based FMCS have family-level backward P coherence.

**Tasks**:
- [ ] Prove `ultrafilter_FMCS_backward_P`:
  - [ ] Given P(phi) in mcs t, translate to (H(neg phi))^c in uc.chain t
  - [ ] Apply `ultrafilter_P_resolution` to get V with R_H(chain t, V) and phi in V
  - [ ] Construct predecessor or use V at t-1
  - [ ] Return s = t-1 with s <= t and phi in mcs s

**Timing**: 1-1.5 hours (symmetric to Phase 6A)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (or new file)

**Verification**:
- `lake build` passes
- `ultrafilter_FMCS_backward_P` compiles without sorry

**Dependencies**: Phase 4D (`ultrafilter_P_resolution`)

**Type Signature**:
```lean
theorem ultrafilter_FMCS_backward_P (uf : UltrafilterFMCS)
    (t : Int) (phi : Formula) (h_P : Formula.some_past phi ∈ uf.mcs t) :
    ∃ s : Int, s ≤ t ∧ phi ∈ uf.mcs s
```

---

### Phase 7A: Construct Ultrafilter-Based BFMCS [NOT STARTED]

**Goal**: Build a BFMCS from ultrafilter chains with temporally_coherent property.

**Tasks**:
- [ ] Define `construct_ultrafilter_bfmcs` that:
  - [ ] Takes MCS M0 as seed
  - [ ] Converts M0 to ultrafilter U0 via `mcsToUltrafilter`
  - [ ] Builds `UltrafilterChain` starting from U0
  - [ ] Converts to FMCS via `UltrafilterChain_to_FMCS`
  - [ ] Creates BFMCS with ultrafilter-based families
- [ ] Prove modal_forward and modal_backward (reuse existing boxClassFamilies infrastructure or prove fresh)
- [ ] Prove `temporally_coherent` using Phases 6A and 6B

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (or new file)

**Verification**:
- `lake build` passes
- `construct_ultrafilter_bfmcs` returns `Sigma' (B : BFMCS Int) (h_tc : B.temporally_coherent) ...`
- `#print axioms construct_ultrafilter_bfmcs` shows no `sorryAx`

**Dependencies**: Phases 5, 6A, 6B

**Type Signature**:
```lean
noncomputable def construct_ultrafilter_bfmcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent)
       (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
       M0 = fam.mcs t
```

---

### Phase 7B: Integration with Truth Lemma [NOT STARTED]

**Goal**: Complete the integration with `parametric_canonical_truth_lemma` for modal completeness.

**Tasks**:
- [ ] Verify `construct_ultrafilter_bfmcs` output matches `parametric_canonical_truth_lemma` input:
  - [ ] B : BFMCS Int
  - [ ] h_tc : B.temporally_coherent
  - [ ] fam : FMCS Int with fam in B.families
  - [ ] t : Int
- [ ] Apply truth lemma: `phi in fam.mcs t <-> truth_at CanonicalTaskModel Omega fam t phi`
- [ ] Complete completeness theorem:
  - [ ] If phi not provable, neg(phi) in some MCS M0 (Lindenbaum)
  - [ ] Build BFMCS via `construct_ultrafilter_bfmcs`
  - [ ] Apply truth lemma: neg(phi) true in canonical model
  - [ ] Hence phi false in model, contradicting validity
- [ ] Verify final completeness theorem is sorry-free

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` (integration)
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (final theorem)

**Verification**:
- `lake build` passes
- Completeness theorem compiles without sorry
- `#print axioms modal_completeness` shows only acceptable axioms (propext, Quot.sound, Classical.choice, etc.)

**Dependencies**: Phase 7A

---

## Testing and Validation

- [ ] `lake build` passes at each phase checkpoint
- [ ] `#print axioms` on key theorems shows no `sorryAx`
- [ ] Phase 4 sorries (3) all resolved
- [ ] `UltrafilterChain_to_FMCS` is sorry-free
- [ ] `construct_ultrafilter_bfmcs` returns `BFMCS Int` with `temporally_coherent` proof
- [ ] Final completeness theorem integrates with official semantics
- [ ] No circular dependencies introduced

## Artifacts and Outputs

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Updated with Phases 4-6
- (Optional) `Theories/Bimodal/Metalogic/Algebraic/UltrafilterFMCS.lean` - Phase 5-6 if split
- `Theories/Bimodal/Metalogic/Completeness.lean` - Phase 7 integration
- `specs/070_explore_ultrafilter_construction/summaries/02_ultrafilter-completion-summary.md` - Final summary

## Rollback/Contingency

If the ultrafilter route encounters unexpected obstacles:
1. **Preserve all Phase 4 progress** - sorries may be useful for alternative approaches
2. **Consider Path B** (truth lemma modification) as fallback - requires changing semantics to accept bundle-level coherence
3. **Document learnings** in summary even if incomplete - insight into F-persistence gap is valuable

If specific phases fail:
- Phase 4A fails: Check if alternative K-distribution proof exists; consider direct tactic proof
- Phase 4C fails: Verify `set_lindenbaum` signature matches seed; try direct Zorn on Boolean algebra
- Phase 6 chain extension fails: Simplify to single-step resolution (just prove existence, not full chain embedding)

## Dependency Graph

```
[Phase 4A]: G_preimage_inf (standalone)
    |
    +---------------------------+
    |                           |
    v                           v
[Phase 4C]: ultrafilter_F    [Phase 4B]: H_preimage_inf
            _resolution              |
    |                                |
    |                                v
    |                    [Phase 4D]: ultrafilter_P
    |                               _resolution
    |                                |
    v                                v
[Phase 5]: UltrafilterChain_to_FMCS (independent, can run parallel with 4A-4D)
    |                                |
    +--------------------------------+
    |
    v
[Phase 6A]: ultrafilter_FMCS_forward_F  <-- needs Phase 4C
    |
    v
[Phase 6B]: ultrafilter_FMCS_backward_P <-- needs Phase 4D
    |
    v
[Phase 7A]: construct_ultrafilter_bfmcs
    |
    v
[Phase 7B]: integration with truth lemma
    |
    v
[COMPLETENESS]
```

**Parallelization Opportunities**:
- Phase 5 can run in parallel with Phases 4A-4D (no dependencies)
- Phases 4A and 4B can run in parallel (G and H are symmetric)
- Phases 4C and 4D can run in parallel after their prerequisites

**Critical Path**: 4A -> 4C -> 6A -> 7A -> 7B
