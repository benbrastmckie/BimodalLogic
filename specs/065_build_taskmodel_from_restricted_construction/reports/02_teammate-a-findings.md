# Teammate A: Primary Approach Analysis

## Summary

The primary approach via `RestrictedTemporallyCoherentFamily` is viable and well-structured. The restricted construction provides family-level temporal coherence (F/P witnesses in the SAME chain), which the bundle construction lacks. Building a TaskModel from this structure requires: (1) defining a restricted TaskFrame, (2) constructing a single WorldHistory from the chain, (3) proving shift-closure of the singleton Omega, and (4) establishing a semantic truth lemma that bridges DRM membership to `truth_at`.

## Key Findings

### 1. RestrictedTemporallyCoherentFamily Analysis

**Location**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:4191-4202`

The structure packages:
```lean
structure RestrictedTemporallyCoherentFamily (phi : Formula) where
  seed : DeferralRestrictedSerialMCS phi
  forward_F : ∀ n : Int, ∀ psi : Formula,
    Formula.some_future psi ∈ restricted_succ_chain_fam phi seed n →
    ∃ m : Int, m > n ∧ psi ∈ restricted_succ_chain_fam phi seed m
  backward_P : ∀ n : Int, ∀ psi : Formula,
    Formula.some_past psi ∈ restricted_succ_chain_fam phi seed n →
    ∃ m : Int, m < n ∧ psi ∈ restricted_succ_chain_fam phi seed m
```

**Key difference from bundle construction**: The F/P witnesses are guaranteed to exist in the SAME chain (same `seed`), not merely somewhere in a bundle. This is exactly what the truth lemma backward cases require.

**Construction**: `build_restricted_tc_family` (lines 4210-4270) constructs this from a `DeferralRestrictedSerialMCS`. The proof handles:
- Forward chain (positive integers): uses `restricted_forward_chain_forward_F`
- Backward chain (negative integers): uses `restricted_backward_to_combined_F_witness`
- Position 0 transition: handled via chain equality at 0

**Underlying structure**: `restricted_succ_chain_fam` (line 3640) maps Int -> Set Formula:
```lean
noncomputable def restricted_succ_chain_fam (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Int) : Set Formula :=
  match n with
  | Int.ofNat k => restricted_forward_chain phi M0 k
  | Int.negSucc k => restricted_backward_chain phi M0 (k + 1)
```

Each element is a `DeferralRestrictedMCS` (proven in `restricted_succ_chain_fam_is_drm`).

### 2. TaskModel Infrastructure Requirements

**Reference**: `Theories/Bimodal/Semantics/TaskFrame.lean:93-122` and `TaskModel.lean:43-49`

A TaskModel over a TaskFrame requires:

**TaskFrame D**:
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

**TaskModel**:
```lean
structure TaskModel {D : Type*} [...] (F : TaskFrame D) where
  valuation : F.WorldState → Atom → Prop
```

**For RestrictedTaskFrame (to be built)**:

1. **WorldState**: Use `DeferralRestrictedMCS phi` packaged as a subtype, or reuse `ParametricCanonicalWorldState` (full MCS). The key decision: do we stay within DRMs or extend to full MCSes?

   **Recommendation**: Use the Lindenbaum extension approach from `restricted_chain_ext` (RestrictedTruthLemma.lean:163-167). This extends each DRM to a full MCS, allowing reuse of `ParametricCanonicalTaskFrame`.

2. **task_rel**: For DRM-based approach, would need to define accessibility. For MCS-based approach (via extension), can reuse `parametric_canonical_task_rel` which uses `ExistsTask` (g_content subset).

3. **Valuation**: Atom truth at world state = membership in MCS. Standard definition:
   ```lean
   valuation := fun M p => Formula.atom p ∈ M.val
   ```

### 3. RestrictedOmega Definition

**Key insight**: The restricted construction is a SINGLE Int-indexed chain. Unlike the bundle construction (multiple families), we have exactly one "history" modulo time-shifts.

**Definition approach**:
```lean
def RestrictedOmega (phi : Formula) (tc_fam : RestrictedTemporallyCoherentFamily phi) :
    Set (WorldHistory (ParametricCanonicalTaskFrame Int)) :=
  { σ | ∃ (delta : Int), σ = WorldHistory.time_shift (restricted_to_history phi tc_fam) delta }
```

Where `restricted_to_history` converts the chain to a WorldHistory:
```lean
def restricted_to_history (phi : Formula) (tc_fam : RestrictedTemporallyCoherentFamily phi) :
    WorldHistory (ParametricCanonicalTaskFrame Int) where
  domain := fun _ => True  -- Full domain (all integers)
  convex := fun _ _ _ _ _ _ _ => True.intro
  states := fun t _ => ⟨restricted_chain_ext phi tc_fam t, restricted_chain_ext_is_mcs phi tc_fam t⟩
  respects_task := [proof needed - uses forward_G property of extended chain]
```

**Why single chain simplifies everything**:
- Only one base history (modulo shifts)
- Box quantification over Omega becomes quantification over shifts of this single history
- Shift-closure is trivial: shifting a shift just changes the offset

### 4. Shift-Closure Strategy

**Definition** (from Truth.lean:237):
```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  ∀ σ ∈ Omega, ∀ (Δ : D), WorldHistory.time_shift σ Δ ∈ Omega
```

**Proof for RestrictedOmega**:

```lean
theorem restricted_omega_shift_closed (phi : Formula) (tc_fam : RestrictedTemporallyCoherentFamily phi) :
    ShiftClosed (RestrictedOmega phi tc_fam) := by
  intro σ h_mem delta'
  -- σ ∈ RestrictedOmega means ∃ delta, σ = time_shift base delta
  obtain ⟨delta, h_eq⟩ := h_mem
  -- time_shift (time_shift base delta) delta' = time_shift base (delta + delta')
  -- [Use time_shift composition lemma]
  refine ⟨delta + delta', ?_⟩
  rw [h_eq, time_shift_compose]  -- Need this lemma
```

The key lemma (`time_shift_compose`) already exists in the codebase:
- `time_shift_parametric_to_history_compose` (ParametricHistory.lean:131-142)
- `time_shift_to_history_compose` (CanonicalConstruction.lean:345-357)

### 5. Semantic Truth Lemma Gap

**Current state**: `restricted_truth_lemma` (RestrictedTruthLemma.lean:268-280) establishes:
```lean
theorem restricted_truth_lemma (phi : Formula)
    (tc_fam : RestrictedTemporallyCoherentFamily phi)
    (n : Int) (ψ : Formula)
    (h_ψ_sub : ψ ∈ subformulaClosure phi) :
    ψ ∈ restricted_succ_chain_fam phi tc_fam.seed n ↔
    ψ ∈ restricted_chain_ext phi tc_fam n
```

This relates DRM membership to extended MCS membership. **This is NOT yet semantic truth**.

**Gap to bridge**: Need `restricted_truth_lemma_semantic`:
```lean
theorem restricted_truth_lemma_semantic (phi : Formula)
    (tc_fam : RestrictedTemporallyCoherentFamily phi)
    (M : RestrictedTaskModel phi tc_fam)
    (n : Int) (ψ : Formula)
    (h_ψ_sub : ψ ∈ subformulaClosure phi) :
    ψ ∈ restricted_succ_chain_fam phi tc_fam.seed n ↔
    truth_at M (RestrictedOmega phi tc_fam) (restricted_to_history phi tc_fam) n ψ
```

**Proof strategy** (by induction on formula structure):
- **Atoms**: `atom p ∈ chain(n)` iff `valuation(state(n), p)` - by valuation definition
- **Bot**: Both sides false - trivial
- **Imp**: IH on subformulas
- **Box**: This is where family-level coherence matters!
  - Forward: `□ψ ∈ chain(n)` means `ψ ∈ chain(n)` for all histories in Omega
  - Since Omega is just shifts of one history, this reduces to checking all time-shifts
  - Use: box-formulas are constant along the chain (`succ_chain_box_persistent` pattern)
- **G (all_future)**: Uses `forward_F` coherence
  - If `Gψ ∈ chain(n)`, need `ψ` true at all `m ≥ n`
  - Use `forward_G` property from the extended chain's FMCS structure
- **H (all_past)**: Uses `backward_P` coherence
  - Symmetric to G case

**Key insight**: The existing `parametric_truth_lemma_shifted` (ParametricTruthLemma.lean) provides the template. The restricted version should follow the same structure but use `restricted_chain_ext` instead of `fam.mcs`.

### 6. Completeness Argument

**Step-by-step proof outline**:

1. **If phi not provable, neg(phi) consistent**:
   - Use `not_provable_implies_neg_consistent` (already exists)

2. **Extend neg(phi) to restricted MCS**:
   - Need: `extend_to_deferral_restricted_serial_mcs`
   - This creates a `DeferralRestrictedSerialMCS phi` containing `neg(phi)`
   - The `has_F_top` and `has_P_top` conditions ensure seriality

3. **Build RestrictedTemporallyCoherentFamily**:
   - Use `build_restricted_tc_family phi seed`
   - This is the key step that provides family-level coherence

4. **Build RestrictedTaskModel**:
   - Create TaskFrame (reuse `ParametricCanonicalTaskFrame Int` or define restricted version)
   - Create TaskModel with valuation from chain
   - Define RestrictedOmega (shifts of single history)

5. **Apply restricted_truth_lemma_semantic**:
   - `neg(phi) ∈ restricted_succ_chain_fam phi seed 0` (by construction - seed contains neg(phi))
   - By truth lemma: `neg(phi)` is true at time 0 in the model
   - Therefore `phi` is NOT true at time 0 (by consistency)

6. **Contrapositive gives completeness**:
   - We have: not provable → countermodel exists → not valid
   - Contrapositive: valid → provable

**Connection to target sorries**:

`bundle_validity_implies_provability` (Completeness.lean:186-214):
```lean
theorem bundle_validity_implies_provability (φ : Formula)
    (h_valid : valid_over Int φ) : Nonempty ([] ⊢ φ)
```

The restricted completeness provides an alternative path:
- `valid_over Int φ` quantifies over ALL TaskModels
- RestrictedTaskModel is a TaskModel over Int
- If `valid_over Int φ`, then `φ` true in RestrictedTaskModel
- But construction ensures `neg(φ)` true if `neg(φ)` consistent
- Contradiction → `neg(φ)` inconsistent → `φ` provable

## Recommended Approach

### Phase 1: Infrastructure (2-3 hours)

1. **Define `restricted_to_history`**: Convert `RestrictedTemporallyCoherentFamily` to `WorldHistory (ParametricCanonicalTaskFrame Int)`
   - Domain: `fun _ => True`
   - States: `fun t _ => ⟨restricted_chain_ext phi tc_fam t, ...⟩`
   - Prove `respects_task` using `forward_G` from the extended chain

2. **Define `RestrictedOmega`**: Set of time-shifts of `restricted_to_history`

3. **Prove `restricted_omega_shift_closed`**: Use time-shift composition

### Phase 2: Semantic Truth Lemma (2-3 hours)

4. **Prove `restricted_truth_lemma_semantic`**: Induction on formula structure
   - Atoms: by valuation definition
   - Bot/Imp: trivial
   - Box: use box-persistence across chain + Omega structure
   - G/H: use forward_F/backward_P from RestrictedTemporallyCoherentFamily

### Phase 3: Completeness Connection (1-2 hours)

5. **Prove restricted completeness**: Assemble the pieces
   - `not_provable_implies_neg_consistent`
   - Extend to DeferralRestrictedSerialMCS
   - Build RestrictedTemporallyCoherentFamily
   - Apply truth lemma
   - Derive contradiction

6. **Wire to target sorries**: Connect `restricted_completeness` to `bundle_validity_implies_provability`

## Confidence Level

**HIGH** with the following justifications:

1. **Mathematical soundness**: The restricted construction is specifically designed for family-level coherence, which is exactly what the truth lemma requires

2. **Existing infrastructure**: 90% of needed components exist:
   - `RestrictedTemporallyCoherentFamily` with coherence proofs
   - `restricted_truth_lemma` (DRM ↔ extended MCS)
   - `ParametricCanonicalTaskFrame` for TaskFrame structure
   - Time-shift composition lemmas

3. **Clear gap identification**: The only truly new work is:
   - `restricted_to_history` definition (straightforward)
   - `restricted_truth_lemma_semantic` (follows existing parametric pattern)

4. **Smaller scope than bundle approach**: Single chain vs. multiple families means simpler Omega, simpler shift-closure, simpler box quantification

## Open Questions

1. **WorldState choice**: Should we use DRM-based world states or full MCS (via Lindenbaum extension)?
   - **Recommendation**: Use full MCS via extension for compatibility with existing `ParametricCanonicalTaskFrame`
   - Trade-off: slightly more infrastructure but reuses proven components

2. **respects_task proof**: Does `restricted_chain_ext` preserve the `forward_G` property needed for `respects_task`?
   - **Likely yes**: Lindenbaum extension preserves derivability, and G-propagation uses derivation
   - **Needs verification**: Check that `restricted_chain_ext` forms an FMCS-like structure

3. **Termination of sorries in SuccChainFMCS.lean**: Lines 4154 has `sorry` for termination. Does this affect soundness?
   - **Investigation needed**: These are termination proofs, not correctness proofs
   - The theorems are still valid assuming termination

4. **Box-persistence for restricted chain**: Need to verify that `succ_chain_box_persistent` or equivalent holds for `restricted_chain_ext`
   - Key for the box case of the semantic truth lemma

## References

| Component | Location | Status |
|-----------|----------|--------|
| RestrictedTemporallyCoherentFamily | SuccChainFMCS.lean:4191-4270 | Complete |
| restricted_succ_chain_fam | SuccChainFMCS.lean:3640-3661 | Complete |
| restricted_truth_lemma | RestrictedTruthLemma.lean:268-280 | Complete |
| restricted_chain_ext | RestrictedTruthLemma.lean:163-175 | Complete |
| ParametricCanonicalTaskFrame | ParametricCanonical.lean:150+ | Complete |
| parametric_to_history | ParametricHistory.lean:61-89 | Complete |
| ShiftClosedParametricCanonicalOmega | ParametricHistory.lean:122-125 | Template for RestrictedOmega |
| truth_at | Truth.lean:118-125 | Complete |
| valid_over | Validity.lean:53-58 | Complete |
| bundle_validity_implies_provability | Completeness.lean:186-214 | Target sorry |
