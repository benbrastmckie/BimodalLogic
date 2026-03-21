# Research Report: Task #29

**Task**: Switch TM metalogic to reflexive G/H semantics
**Date**: 2026-03-21
**Mode**: Team Research (2 teammates, 1 completed)
**Session**: sess_1774128759_b570d5

---

## Summary

Switching the temporal operators G (all_future) and H (all_past) from strict semantics (`t < s`) to reflexive semantics (`t ≤ s`) has profound and far-reaching consequences for the TM axiom system. The key finding is that **reflexive semantics makes all axioms from all three frame classes (Base, Dense, Discrete) universally valid**, collapsing the three-variant logic structure into a single logic. The two new valid axioms (Gφ → φ and Hφ → φ, the T-axioms) additionally enable a cleaner canonical model irreflexivity proof—a design that was actually preferred before Task 991 switched back to strict semantics.

---

## Key Findings

### Newly Valid Axioms (Strict → Valid)

Two axioms that are currently INVALID become VALID under reflexive semantics:

1. **Temporal T Future** (`Gφ → φ`): Under reflexive G, setting s = t in "∀ s ≥ t, φ(s)" immediately gives φ(t). Definitionally valid.

2. **Temporal T Past** (`Hφ → φ`): Same argument with H. Definitionally valid.

These are the axioms documented in `CanonicalIrreflexivityAxiom.lean` as the intended design (Task 967) before Task 991 reverted to strict semantics.

### Frame Class Collapse (Dense/Discrete → Base)

All four extension axioms become trivially valid on any linear order:

| Axiom | Current Frame Requirement | Under Reflexive | Reason |
|-------|--------------------------|-----------------|--------|
| DN: GGφ → Gφ | DenselyOrdered | Base (universal) | Take r = t: GGφ at t gives ∀ s ≥ t, φ(s) directly |
| DF: (F⊤ ∧ φ ∧ Hφ) → F(Hφ) | SuccOrder | Base (universal) | s = t witnesses F(Hφ) since Hφ(t) holds |
| SF: Gφ → Fφ | NoMaxOrder | Base (universal) | T-axiom makes t a witness for Fφ |
| SP: Hφ → Pφ | NoMinOrder | Base (universal) | T-axiom makes t a witness for Pφ |

**Architectural consequence**: The three-variant structure (TM Base / TM Dense / TM Discrete) collapses to a single logic. The `FrameClass` enum and the `isDenseCompatible` / `isDiscreteCompatible` predicates in `Axioms.lean` become degenerate.

### All 16 Current Base Axioms Remain Valid

Every axiom currently in the Base frame class remains valid under reflexive semantics. Their soundness proofs in `Metalogic/Soundness.lean` are independent of whether temporal quantification uses `<` or `≤`:

- Propositional: prop_k, prop_s, ex_falso, peirce
- Modal S5: modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist
- Temporal base: temp_k_dist, temp_4, temp_a, temp_l
- Interaction: modal_future, temp_future
- Linearity: temp_linearity

### Impact on DN (Density Axiom) — Critical

Under reflexive semantics, GGφ → Gφ becomes trivially provable **from T4 alone**:

- T4 gives Gφ → GGφ (already in base)
- Reflexive T-axiom gives GGφ → Gφ (new base axiom)
- Therefore GGφ ↔ Gφ becomes a theorem

This means DN is derivable in the base logic under reflexive semantics, with no density frame condition required. The `density_valid` proof in `Soundness.lean` (which uses `DenselyOrdered.dense` to find an intermediate point r) would be replaced by a trivial proof using r = t.

### Impact on DF (Discreteness Forward) — Critical

Under reflexive semantics:
- F⊤ is trivially true (s = t witnesses "∃ s ≥ t, ⊤")
- Hφ(t) under reflexive means ∀ r ≤ t, φ(r), which includes φ(t) itself
- So F(Hφ) holds with witness s = t: Hφ(t) is exactly "∀ r ≤ t, φ(r)"

DF becomes trivially valid. The `discreteness_forward_valid` proof (which uses `Order.succ t` and requires `SuccOrder`) would be replaced by a proof setting s = t.

### Canonical Model Impact

The canonical model construction is the most important impact. `CanonicalIrreflexivityAxiom.lean` documents:

> The proof uses the Gabbay Irreflexivity Rule (IRR) contrapositively with the T-axiom for past (`H(φ) → φ`), which is valid under the reflexive temporal semantics.

The 8-step proof in that file uses the T-axiom (step 7: "Apply T-axiom: H(¬p) → ¬p, so ¬p ∈ M'") to derive irreflexivity of the canonical relation **without requiring atom freshness**. This was the resolution in Task 967 and is cleaner than the strict approach.

Under reflexive semantics, the canonical relation CanonicalR would be defined using ≤ (reflexive), so CanonicalR(M, M) holds — and the proof must derive a contradiction from this. The T-axiom approach does exactly this.

---

## Synthesis

### Conflicts Between Teammates

None — only Teammate A completed (Teammate B did not produce findings).

### Gaps Identified

1. **Completeness pipeline impact**: The completeness proof chain (BaseCompleteness, DenseCompleteness, DiscreteCompleteness) would need re-examination. Under reflexive semantics, all three collapse to a single completeness proof.

2. **Temporal duality**: The `swap_temporal` function and TD rule swap G↔H. Under reflexive semantics, both G and H have T-axioms, so the duality is preserved. However, the proof system changes (T-axioms added) need to be verified for duality compatibility.

3. **Seriality axioms under reflexive**: SF (Gφ → Fφ) becomes `Gφ → ∃ s ≥ t, φ(s)`, which is trivially witnessed by t. But the "classical" use of SF to establish that the canonical timeline has no maximum element may be affected — if SF is trivially true, it carries less information for the canonical construction.

4. **Wave 2 research needed**: Impact on MCS properties, truth lemma, Succ relation, CanonicalTask.

### Recommendations

1. **Add T-axioms to proof system**: Add `temp_t_future (φ : Formula) : Axiom (φ.all_future.imp φ)` and `temp_t_past (φ : Formula) : Axiom (φ.all_past.imp φ)` to `ProofSystem/Axioms.lean`.

2. **Modify Truth.lean**: Change `t < s` to `t ≤ s` in the `all_past` and `all_future` cases of `truth_at`.

3. **Simplify soundness proofs**: The `density_valid` and `discreteness_forward_valid` proofs become trivial. The `seriality_future_valid` and `seriality_past_valid` proofs also become trivial.

4. **Collapse FrameClass**: The `FrameClass` enum can be simplified (or the Dense/Discrete axioms reclassified as Base).

5. **Revisit canonical model**: Update `CanonicalIrreflexivityAxiom.lean` and related files to use the T-axiom-based proof that was designed for reflexive semantics.

6. **Remove IRR rule**: The current system uses the Gabbay IRR (Irreflexivity) rule to compensate for not having the T-axiom. Under reflexive semantics, T-axioms replace IRR.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Axiom-by-axiom analysis, frame class impact | completed | high |
| B | Alternative patterns, prior art | not_started (team degraded) | — |

---

## References

- `Theories/Bimodal/ProofSystem/Axioms.lean` — Full axiom system (19 axioms)
- `Theories/Bimodal/Semantics/Truth.lean` — Current strict truth definition
- `Theories/Bimodal/Metalogic/Soundness.lean` — Axiom validity proofs
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` — T-axiom approach for canonical model
- `Theories/Bimodal/FrameConditions/FrameClass.lean` — Frame class typeclasses
- `Theories/Bimodal/LogicVariants.lean` — Three-variant TM logic summary
- Task 967 (atom type change) — Introduced reflexive semantics and T-axiom approach
- Task 991 — Reverted to strict semantics (the change this task proposes to undo)
