# Teammate D Findings — Strategic Horizons

**Task**: 154 - sum_preservation_ef_games
**Angle**: Strategic assessment — should the approach change fundamentally?
**Date**: 2026-05-16

## Key Findings

### 1. The Monolith is the Problem

NEquivalence.lean at 1133 lines is by far the largest file in WeakCanonical/ (next largest: ReflexiveCanonical.lean at 775, NormalForm.lean at 615). But line count alone isn't the issue. The real problem is **proof coupling density**: `build_bicompat` (lines 474-669, ~195 lines) is a single recursive definition where the forward oracle, backward oracle, CompData construction, `h_idx'`, `cd'`, recursive call, `extend_atoms`, and order transfer are all interdependent within one term. **Any type-level change propagates to every other subexpression before Lean will accept the file.** This is why 5+ attempts at incremental patching failed — each fix works in isolation but the combined 80-line diff triggers cascading interactions.

### 2. The `show T from x` Pattern is Baked into BiCompat's Definition

The `show (orderedSum sig I ms).carrier from ⟨j, c⟩` pattern appears **in the definition of `BiCompat` itself** (lines 166-180), not just in proofs. Every use of `BiCompat` must work with this opaque coercion. The `build_bicompat` proof can't avoid it because the *goal type* contains it. Changing `BiCompat`'s definition would be the cleanest fix, but then `sum_nf_lift_gen` (which also pattern-matches on `BiCompat`) and all callers need updating.

### 3. Dependency Graph is Narrow and Contained

The dependency chain is: NEquivalence → OrderedSum → {IntegerModel, Transfer, WeakCanonical}. Critically:
- `doets_lemma_1_4` (OrderedSum.lean line 34) just calls `KEquivalenceFramework.sum_preservation` — it doesn't reference any internal definitions
- `IntegerModel.lean` and `Transfer.lean` import OrderedSum but only reference `doets_lemma_1_4`, `k_equiv`, `orderedSum`, and `KEquivalenceFramework` — all public API
- **All 24 private definitions** (lines 136-984) are implementation details. They could be in a separate file without any interface change.

This means restructuring the internal proof is **zero-risk to downstream consumers**. The public API is: `KType`, `k_type_of`, `k_equiv`, `k_equiv_monotone`, `orderedSum`, `KEquivalenceFramework` instance, `chronicleAsMonadicStructure` + instances. Everything else is `private`.

### 4. Cost-Benefit of Continued Patching vs. Restructuring

**Patching cost**: 5+ attempts × ~4 hours = ~20+ hours spent. The v7 handoff says ~80 coordinated line changes, all fixes verified in isolation but failing when combined. The fundamental blocker (CompData fields must be changed atomically) hasn't been overcome.

**Restructuring cost**: Extract `build_bicompat` and `sum_lift_one_var` into tactic-mode proofs with explicit intermediate lemmas. Estimated 4-6 hours for a clean rewrite, but with much higher success probability because each lemma can be verified independently.

**Clear winner**: Restructuring. The atomic-compilation constraint of the current monolithic structure makes incremental debugging near-impossible.

### 5. The Core Issue: `orderedSum` is `noncomputable def`, not `abbrev`

The root of almost all elaboration failures traces to `orderedSum` (line 122) being a `noncomputable def`. This means:
- `(orderedSum sig I ms).carrier` is opaque — Lean cannot see it equals `Sigma fun i => (ms i).carrier`
- `show (orderedSum sig I ms).carrier from ⟨j, c⟩` creates a `have this := ⟨j, c⟩; this` binding that's opaque to projections
- `.1` on `Fin.cons (show T from x) env` fails because Lean can't unfold `T` to see it's a `Sigma`

Making `orderedSum` an `abbrev` was tried (v7 handoff) and caused 20+ simp/typeclass failures elsewhere. But there's a middle path: **introduce a local `abbrev` or helper that provides the transparent coercion where needed**.

### 6. A Simpler Mathematical Approach Exists (Partial)

The current architecture uses CompData + BiCompat + build_bicompat as machinery to track per-component environments through the induction. This is faithful to Doets 1987 but creates enormous proof terms. An alternative:

**Direct NF induction without CompData**: Instead of tracking per-component environments explicitly, prove `sum_nf_agree_sentence` by direct induction on depth `k`, using `nf_characteristic` + `nf_agreement_from_shared_nf` at each step. The key insight: `sum_lift_one_var` (lines 744-816) is the only caller of `build_bicompat`, and it only needs the `n=1` case. At `n=1`, CompData tracks a single element per component — this is massively simpler than the general case.

However, this would require reproving `build_bicompat` for the general `n` case (used in the recursive step). The mathematical content is the same; only the Lean encoding differs.

### 7. Recommended Strategic Approach: Refactor into Two Files

**Phase A**: Create `SumPreservation.lean` containing all the private proof machinery (BiCompat through sum_preservation_proof). Change `BiCompat` definition to use direct Sigma type instead of `show T from x`:
```lean
-- Instead of:
Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M
-- Use:
Fin.cons (⟨j, c⟩ : Sigma fun i => (ms i).carrier) env_M
```
Then add a coercion lemma connecting `Sigma fun i => (ms i).carrier` to `(orderedSum sig I ms).carrier`.

**Phase B**: Rewrite `build_bicompat` as separate lemmas:
- `build_bicompat_oracle_fwd` (forward oracle, ~50 lines)
- `build_bicompat_oracle_bwd` (backward oracle, ~50 lines)  
- `build_bicompat_step` (combining them, ~20 lines)
- `build_bicompat` (induction wrapper, ~10 lines)

Each is independently compilable and testable. The cascading-fix problem disappears because each lemma states its types explicitly.

**Phase C**: Rewrite `sum_lift_one_var` with k-split (k=0 trivial, k>0 with CompData). Factor CompData construction into its own lemma.

**Phase D**: NEquivalence.lean keeps only the public API + imports SumPreservation.lean.

### 8. Lean 4 Elaboration Strategies Worth Trying

If restructuring is considered too heavy:

1. **`set_option maxRecDepth 1024`**: The current default (512) may be too low for the deeply nested CompData term
2. **`with_unfolding_all`**: Could help Lean see through `orderedSum` locally without global `@[reducible]`
3. **`change` tactic**: Instead of `show T from x`, use `change T` after introducing the sigma pair — `change` is more transparent
4. **`refine { sz := ..., eM := ..., eN := ..., agree := ?_, bound := ?_, consistent := ?_ }`**: Providing all non-proof fields as terms and leaving proof fields as goals lets Lean elaborate field types one at a time

## Recommended Approach

**Primary recommendation**: Refactor (Phase A-D above). The 20+ hours of failed patching strongly suggests the monolithic structure is fundamentally hostile to Lean's elaborator. Splitting into independently-compilable lemmas eliminates the cascading-fix problem by construction.

**Secondary recommendation** (if restructuring budget is too high): Apply the "refine with explicit goals" strategy — provide CompData fields using `refine { ... }` with `?_` for all proof fields, then close each `?_` in a separate `case` block. This isolates each proof obligation from the others within the same definition.

**Do NOT try**: More incremental patching of the current structure. The v7 handoff is clear: atomicity of the CompData compilation makes it impossible to test fixes incrementally.

## Evidence/Examples

- v7 handoff: "ALL changes to a single CompData construction must be applied atomically"
- v7 handoff: 5 approaches tried and failed, all for the same structural reason
- BiCompat definition uses `show T from x` in its TYPE, propagating the problem to all consumers
- NEquivalence.lean is 45% longer than the next-largest file and contains 24 private definitions that no downstream file references

## Confidence Level

**High** for the diagnosis (monolith + opaque BiCompat definition is the root cause).
**Medium-high** for the refactoring recommendation (the dependency graph is narrow enough that it's safe, but the implementation effort is non-trivial).
**Low** for the elaboration-strategy workarounds (they might help but don't address the fundamental coupling).
