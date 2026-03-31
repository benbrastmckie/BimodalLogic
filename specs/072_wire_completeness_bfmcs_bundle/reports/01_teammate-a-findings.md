# Teammate A Findings: Primary BFMCS Wiring Approaches

## Key Findings

### 1. The `construct_bfmcs` Callback Signature

`parametric_algebraic_representation_conditional` (ParametricRepresentation.lean:252) requires:

```lean
construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
  Σ' (B : BFMCS D) (h_tc : B.temporally_coherent)
     (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
     M = fam.mcs t
```

This asks for a function that, given any MCS `M`, produces:
- A `BFMCS D` (parametric in `D : Type*` with `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`)
- A proof `B.temporally_coherent` — **family-level** F/P coherence (same-family witnesses)
- A `fam ∈ B.families` such that `M = fam.mcs t` for some `t : D`

The theorem is generic in `D`. To instantiate it for base completeness (D = Int), you provide a concrete callback.

### 2. The `BFMCS.temporally_coherent` Requirement

`BFMCS.temporally_coherent` is defined at TemporalCoherence.lean:218:

```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ, Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t ≤ s ∧ φ ∈ fam.mcs s) ∧
    (∀ t : D, ∀ φ, Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s ≤ t ∧ φ ∈ fam.mcs s)
```

This requires **same-family** witnesses: F(phi) at time t in fam must have phi at some s ≥ t **in the same fam**.

### 3. What `construct_bfmcs_bundle` Provides

`construct_bfmcs_bundle` (UltrafilterChain.lean:5728) is sorry-free and produces a `BFMCS_Bundle` — a **different** structure with **bundle-level** coherence:

```lean
structure BFMCS_Bundle where
  families : Set (FMCS Int)
  nonempty : families.Nonempty
  modal_forward : ∀ fam ∈ families, ∀ φ t, Formula.box φ ∈ fam.mcs t → ∀ fam' ∈ families, φ ∈ fam'.mcs t
  modal_backward : ∀ fam ∈ families, ∀ φ t, (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t
  bundle_forward_F : ∀ fam ∈ families, ∀ φ t, Formula.some_future φ ∈ fam.mcs t →
    ∃ fam' ∈ families, ∃ s > t, φ ∈ fam'.mcs s  -- witness in ANY family
  bundle_backward_P : ∀ fam ∈ families, ∀ φ t, Formula.some_past φ ∈ fam.mcs t →
    ∃ fam' ∈ families, ∃ s < t, φ ∈ fam'.mcs s  -- witness in ANY family
  eval_family : FMCS Int
  eval_family_mem : eval_family ∈ families
```

**Critical type mismatch**: `construct_bfmcs_bundle` returns `BFMCS_Bundle`, NOT `BFMCS`. The callback requires `BFMCS D` (with D parametric), not `BFMCS_Bundle`.

### 4. The Fundamental Gap: Bundle vs Family Coherence

The core blocker is structural:

- `BFMCS.temporally_coherent` (required) = witnesses in the **same** family
- `BFMCS_Bundle.bundle_forward_F` (available) = witnesses in **any** family of the bundle

These are **not** the same. You cannot coerce `BFMCS_Bundle` to satisfy `BFMCS.temporally_coherent` without an additional proof.

This gap is explicitly documented at UltrafilterChain.lean:5778:
> "Step 3 requires `B.temporally_coherent` (family-level forward_F/backward_P). The sorry-free bundle construction provides only bundle-level coherence. The gap between bundle-level and family-level coherence is the remaining blocker."

### 5. The Z-Chain Has Sorries for F/P Coherence

The `Z_chain` structure (UltrafilterChain.lean:5112) provides forward_G/backward_H sorry-free. However `Z_chain_forward_F` (line 5330) and `Z_chain_backward_P` (line 5360) both end with `sorry` when phi ∉ chain(t):

```lean
theorem Z_chain_forward_F ... :
    ∃ s : Int, t ≤ s ∧ phi ∈ Z_chain M0 h_mcs0 s := by
  by_cases h_phi_t : phi ∈ Z_chain M0 h_mcs0 t
  · exact ⟨t, le_refl t, h_phi_t⟩
  · -- ... sorry
    sorry
```

The easy case (phi already in chain) is handled. The hard case (F(phi) genuinely unresolved) requires the dovetailed construction.

### 6. Dovetailed Chain: Partially Implemented, Not Closed

The `omega_chain_dovetailed_forward` (UltrafilterChain.lean:6268) is defined but incomplete — it still uses F_top at each step rather than scheduling specific F-obligations. The `select_F_obligation` function (line 6234) returns `Formula.neg Formula.bot` unconditionally.

### 7. `OmegaFMCS`: The Closest Sorry-Free Candidate

`OmegaFMCS` (UltrafilterChain.lean:5294) wraps `Z_chain` as an FMCS with sorry-free:
- `forward_G := Z_chain_forward_G M0 h_mcs0`
- `backward_H := Z_chain_backward_H M0 h_mcs0`

But it does NOT provide forward_F/backward_P (those have sorries in Z_chain).

### 8. Deprecated `construct_bfmcs` Is Dead Code

The original `construct_bfmcs` function (line 4760) is marked `@[deprecated "Use construct_bfmcs_omega"]` and has a `sorry` body. The suggested `construct_bfmcs_omega` does not appear to be defined yet — it is referenced as a future target.

---

## Recommended Approach

**The only path to sorry-free wiring is implementing family-level F/P coherence for the Z-chain (or a modified chain).**

There are two viable sub-strategies:

### Strategy A: Complete Z_chain_forward_F via Dovetailed Construction

1. Implement `omega_chain_dovetailed_forward` properly — at step n = Nat.unpair (t, k), resolve the k-th F-obligation in chain(t) using `resolving_witness`. The infrastructure for this is in place (resolving_witness, F_resolution_witness_in_box_class, etc.).

2. Show that for any F(phi) ∈ Z_chain(t), the dovetailed chain eventually contains phi at some s > t. Use the surjectivity of `Nat.unpair`.

3. Package as `OmegaFMCS` with temporal coherence proof.

4. Build `BFMCS Int` (NOT `BFMCS_Bundle`) from this FMCS:
   - `families := {OmegaFMCS M0 h_mcs0}` (singleton bundle)
   - `modal_forward/backward` from MCS S5 properties
   - `temporally_coherent` from Z_chain_forward_F/backward_P

5. The callback for `parametric_algebraic_representation_conditional` is:
   ```lean
   fun M h_mcs => ⟨singleton_bfmcs M h_mcs, tc_proof, OmegaFMCS M h_mcs, mem_singleton, 0, rfl⟩
   ```

**Key challenge**: The dovetailed chain references `Z_chain(t)` for arbitrary `t ≤ n` at step `n`, creating a circular dependency. This likely requires mutual recursion or a `WellFounded` argument. The existing `omega_chain_resolving_at_1` (line 6055) resolves phi at step 1 from M0 but only handles a single obligation.

### Strategy B: Singleton BFMCS from RestrictedTemporallyCoherentFamily

Use the sorry-free `RestrictedTemporallyCoherentFamily` (SuccChainFMCS.lean:5847) and `build_restricted_tc_family` (line 5866):

1. Build `DeferralRestrictedSerialMCS phi` from the target formula's negation (requires phi-specific construction).
2. Build `RestrictedTemporallyCoherentFamily` — provides forward_F/backward_P for formulas in `deferralClosure(phi)`.
3. Convert to a full FMCS via Lindenbaum extension (CanonicalConstruction.lean:838). **Problem**: `restricted_tc_family_to_fmcs` has sorries at lines 889/893 for forward_G/backward_H over the extended MCSes.

**Key challenge**: Converting restricted family to full FMCS breaks forward_G/backward_H for independent Lindenbaum extensions. Strategy A is cleaner.

### Strategy C: Modify `parametric_algebraic_representation_conditional` Signature

Change the callback to accept `BFMCS_Bundle` instead of `BFMCS D` with `temporally_coherent`. This requires:
1. A parametric truth lemma that works with bundle-level coherence.
2. Refactoring `parametric_shifted_truth_lemma` (ParametricTruthLemma.lean) to work with bundle semantics.

This is the deepest structural change but may be the cleanest long-term path since `BFMCS_Bundle` is sorry-free.

---

## Evidence and Key Locations

| Item | File | Lines |
|------|------|-------|
| `parametric_algebraic_representation_conditional` signature | ParametricRepresentation.lean | 252–261 |
| `BFMCS.temporally_coherent` definition | TemporalCoherence.lean | 218–221 |
| `construct_bfmcs` (deprecated, sorry) | UltrafilterChain.lean | 4760–4767 |
| `construct_bfmcs_bundle` (sorry-free, wrong type) | UltrafilterChain.lean | 5728–5739 |
| `BFMCS_Bundle` structure | UltrafilterChain.lean | 5633–5660 |
| `Z_chain_forward_F` (sorry in hard case) | UltrafilterChain.lean | 5330–5352 |
| `Z_chain_backward_P` (sorry in hard case) | UltrafilterChain.lean | 5360–5369 |
| `OmegaFMCS` (sorry-free forward_G/backward_H) | UltrafilterChain.lean | 5294–5306 |
| `omega_chain_resolving_at_1` (resolves one obligation) | UltrafilterChain.lean | 6055–6077 |
| `RestrictedTemporallyCoherentFamily` | SuccChainFMCS.lean | 5847–5857 |
| `build_restricted_tc_family` (sorry-free) | SuccChainFMCS.lean | 5866–5926 |
| Gap between bundle and family coherence (documented) | UltrafilterChain.lean | 5754–5780 |

---

## Confidence Level

**High** for the problem diagnosis:
- The type mismatch between `BFMCS_Bundle` and `BFMCS D` is unambiguous
- The sorry locations in Z_chain_forward_F/backward_P are clear
- The dovetailed construction is partially in place

**Medium** for Strategy A (dovetailed chain completion):
- The resolving_witness infrastructure is sorry-free
- The circular/dependent structure of dovetailed indexing is non-trivial
- Nat.unpair surjectivity argument is standard but requires careful formalization

**Low** for estimating complexity:
- The dovetailed chain may need a complete redesign rather than just filling in the sorry
- The circular reference to chain(t) for t ≤ n may require a fundamentally different construction

---

## Open Questions

1. **Does `construct_bfmcs_omega` exist?** It is referenced in deprecation annotations but not found in the codebase. If it exists in a separate file, Strategy A may already be partially done.

2. **Singleton BFMCS construction**: Is there a theorem that builds a `BFMCS Int` from a single `FMCS Int` with proven family-level temporal coherence? This would complete Strategy A once Z_chain_forward_F is closed.

3. **Can the parametric truth lemma be adapted to bundle-level coherence?** If the `Imp` forward case's backward IH can be satisfied by bundle-level witnesses (accessing any family at time t via the evaluation family's membership in the bundle), Strategy C becomes viable without deep refactoring.

4. **What does the task 73 blocker analysis say?** Tasks 73/77 may have identified the same gap. The spawned subtasks from task 73 may have produced relevant findings.

5. **Is there a sorry-free `Z_chain_forward_F` for the restricted case?** The `restricted_combined_bounded_witness_F` pattern in SuccChainFMCS.lean suggests the restricted setting handles F-nesting via the `closure_F_bound`. Can this be reused for base completeness with a formula-specific approach?

---

## Errata (2026-03-31)

**CORRECTION**: This report analyzes the type mismatch between `BFMCS_Bundle` (bundle-level
coherence) and `BFMCS` (family-level coherence) and correctly identifies the gap. However,
the discussion of "adapting the parametric truth lemma to bundle-level coherence" does not
recognize that bundle-level coherence is semantically WRONG for TM task semantics.

TM temporal operators (G, H, F, P) quantify over times in the SAME world history, not over
different histories as bundle-level coherence allows. The truth lemma requires family-level
coherence, not bundle-level coherence.

See `reports/06_semantic-correction.md` for full analysis.
See also: `ROADMAP.md:158-160` (identifies bundle as "dead end")
