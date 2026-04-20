# Teammate D: Horizons - Strategic Direction for Seriality (Round 51)

**Task**: 93 - Complete BXCanonical Embedding
**Date**: 2026-04-20
**Role**: Horizons — long-term strategic direction

---

## Key Findings

### 1. The Sorry Sites Are a Type-Signature Mismatch, Not a Deep Mathematical Problem

The two sorry sites in `Soundness.lean` (lines 209, 218) for `serial_future_axiom_valid` and
`serial_past_axiom_valid` are caused by a single structural mismatch: the `valid` definition
(Validity.lean line 73-77) quantifies over **all** `LinearOrderedAddCommGroup D` types, but
seriality (`T -> F(T)`) requires `NoMaxOrder D` (and dually `NoMinOrder D`). In a trivial
one-element ordered group, there is no element strictly greater than any element, so
`F(T)` is vacuously false.

This is NOT a deep incompatibility like the BX8/BX9 guard convention tension. It is a
typeclass constraint that is simply missing from the `valid` definition. By contrast:
- `valid_dense` already includes `[Nontrivial D]` (Validity.lean line 162)
- `valid_discrete` already includes `[Nontrivial D]` (Validity.lean line 180)
- `FrameClass.lean` defines `SerialFrame` with `[Nontrivial D] [NoMaxOrder D] [NoMinOrder D]`

The sorries are solvable by adding `[Nontrivial D]` (which implies `NoMaxOrder` for
`LinearOrderedAddCommGroup`) to the `valid` definition, or by introducing a `valid_nontrivial`
predicate.

### 2. Standard Temporal Logic Literature: Seriality as Axiom for Irreflexive Systems

In Burgess (1982, 1984), the axiom system for linear temporal logic with reflexive G/H does
NOT need explicit seriality axioms because `G(phi) -> phi` (BX1) forces any point to be its
own witness, making `F(T)` trivially derivable: from BX1 applied to `G(neg T)` we get
`neg T`, so `neg G(neg T) = F(T)` follows by double-negation (contrapositive of BX1 applied
to `¬T`). Seriality is DERIVABLE in Burgess's reflexive system.

Under the irreflexive switch (BX1 removed, G strict), seriality is NO LONGER DERIVABLE.
It must be AXIOMATIZED as BX1/BX1'. This is correct and established in the codebase:
the axioms are named `serial_future` and `serial_past`, placed at position BX1/BX1'.

The literature parallel: Goldblatt's "Logics of Time and Computation" (1992) treats frames
satisfying "every point has a successor and predecessor" as the appropriate class for
tense logic over Z (the integers). This is exactly the `NoMaxOrder + NoMinOrder` condition.
Goldblatt, Segerberg, and others all recognize seriality as a FRAME CONDITION that must be
either assumed in the semantics or axiomatized in the proof system.

**Verdict**: The project's approach (axiomatize seriality as BX1/BX1') is exactly right for
an irreflexive system. The problem is only that `valid` does not encode the corresponding
frame condition.

### 3. The Valid Definition Does Not Match the Intended Frame Class

The `valid` definition quantifies over ALL `LinearOrderedAddCommGroup D`, including:
- The trivial group `{0}` with `0 < 0` — empty, but satisfies all group laws
- Any group with a maximum element

These are NOT the intended models for temporal logic. The intended frame class is
`LinearOrderedAddCommGroup D` with `NoMaxOrder D` and `NoMinOrder D` (exactly `SerialFrame D`
from FrameClass.lean).

This mismatch means `valid` as currently defined is a STRICTLY STRONGER predicate than
intended. Any formula that is actually valid over all serial frames might fail to be provably
`valid` in the Lean sense. The seriality axioms are the first casualty: they are valid over
all serial frames but not over all `LinearOrderedAddCommGroup` frames.

### 4. Two Fix Strategies: Nontrivial vs Frame-Class Specialization

**Strategy A (Add Nontrivial to valid)**:
Change `valid` to require `[Nontrivial D]`. In a `LinearOrderedAddCommGroup`, `Nontrivial D`
(existence of two distinct elements) implies `NoMaxOrder D` via the group structure:
given `a ≠ b`, we can always form `n * (b - a)` for arbitrarily large `n`, giving
unbounded elements. So `Nontrivial D` is the right minimal condition.

Impact: `serial_future_axiom_valid` and `serial_past_axiom_valid` become provable.
Downstream: every use of `valid` now asserts something slightly weaker (valid on nontrivial
ordered groups instead of all ordered groups). This is a RELAXATION, not a restriction —
more formulas become `valid`, never fewer.

**Strategy B (Separate valid_serial or specialize to Int)**:
Keep `valid` as-is (universal over all ordered groups) and state seriality validity as
`valid_nontrivial`. The soundness theorem for serial axioms uses `valid_nontrivial` instead.

This avoids changing the `valid` definition but requires maintaining two validity predicates.
The completeness theorem would need to target `valid_nontrivial`, which is inelegant.

### 5. The Completeness Theorem Already Specializes to Int

Examining `BXCanonical/Completeness.lean`: the completeness proof builds a canonical model
using MCS-based points. The canonical temporal type is effectively Z (integers), not an
arbitrary ordered group. Z is `Nontrivial`, has `NoMaxOrder`, and has `NoMinOrder`.

Therefore, if `valid` is changed to include `[Nontrivial D]`, the completeness theorem
states: "every Nontrivial-valid formula is derivable." This matches exactly the intended
semantics, and the canonical model witnesses this validity class since Z is nontrivial.

**The Nontrivial constraint costs nothing in the completeness direction.** The canonical
model is built over Z, which satisfies all added constraints.

### 6. BX1 Removal vs Seriality Axiom: No Interaction with IRR Rule

The IRR rule (irreflexivity rule, from `IRRSoundness.lean`) is a meta-rule about which
formulas enter the proof system. It is orthogonal to the seriality axioms. The BX1
reflexivity axiom was removed because `G(phi) -> phi` is unsound under strict semantics.
The seriality axioms BX1/BX1' (`T -> F(T)`, `T -> P(T)`) replace BX1 in a different role:
they assert the EXISTENCE of future/past times, not their reflexive accessibility.

Keeping or removing BX1 (seriality future/past) does NOT interact with the IRR rule in
any important way. The IRR rule is about the syntactic formation of derivation trees, not
about which frame conditions are assumed.

### 7. Current Codebase State for the Seriality Sorries

From examining `Soundness.lean` lines 198-218:
- Both sorries appear inside proofs of the form:
  `⊨ ((⊤).imp (F(⊤)))` unfolded to: given `t : D`, produce `s : D` with `t < s`
- The proof body correctly unfolds the semantics but stops because there is no
  `NoMaxOrder D` instance available in the `valid` quantifier
- The fix requires adding `[Nontrivial D]` (or directly `[NoMaxOrder D] [NoMinOrder D]`)
  to the `valid` definition signature, after which `exists_gt` from Mathlib provides `s`

### 8. Valid_dense and Valid_discrete Already Close the Sorry (Structurally)

The fact that `valid_dense` and `valid_discrete` both include `[Nontrivial D]` means:
- `serial_future_axiom_valid` at type `valid_dense` is immediately closeable with
  `exists_gt` (Nontrivial + LinearOrderedAddCommGroup implies NoMaxOrder)
- The sorry in `axiom_valid_dense` (line 867) delegates to `serial_future_axiom_valid`
  via `Validity.valid_implies_valid_dense serial_future_axiom_valid`
- Since `serial_future_axiom_valid` is sorry'd, this creates a sorry cascade

If `valid` is changed to include `[Nontrivial D]`, all three sorry sites close simultaneously.

---

## Strategic Recommendations

### Primary Recommendation: Add Nontrivial to valid (one targeted change)

**Action**: Change `Validity.lean` definition of `valid` to:
```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

**Why this is correct**:
1. The standard frame class for tense logic is nontrivial linear orders (Z, Q, R, etc.)
2. The trivial one-element group is not a meaningful temporal model
3. Int (Z) is `Nontrivial`, so the completeness proof's canonical model satisfies the condition
4. `Nontrivial D` with `LinearOrderedAddCommGroup D` implies `NoMaxOrder D` and `NoMinOrder D`
   (Mathlib: `LinearOrderedAddCommGroup.noMaxOrder` and dual)
5. This closes BOTH sorry sites (`serial_future_axiom_valid`, `serial_past_axiom_valid`)
6. The existing `valid_dense` and `valid_discrete` already use `[Nontrivial D]`, so this
   aligns the base `valid` with its specializations

**After the change**, the two sorry proofs become:
```lean
theorem serial_future_axiom_valid :
    ⊨ ((Formula.bot.imp Formula.bot).imp (Formula.some_future (Formula.bot.imp Formula.bot))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Formula.some_future, Formula.neg]
  intro _h_top h_G_neg_top
  obtain ⟨s, hs⟩ := exists_gt t  -- Requires NoMaxOrder, which follows from Nontrivial
  exact absurd (h_G_neg_top s hs) (fun h => h trivial)
```

### Secondary Recommendation: Explicit valid_nontrivial as documentation

Even after fixing `valid`, add a theorem documenting the relationship:
```lean
theorem valid_iff_valid_nontrivial (φ : Formula) :
    valid φ ↔ (∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
      [Nontrivial D] ..., truth_at M Omega τ t φ)
```

This is trivially true by definition but makes the frame class assumption explicit for
readers and future maintainers.

### Tertiary Recommendation: Do NOT remove seriality axioms

The option of removing seriality axioms (BX1/BX1') and relying on the canonical model's
implicit use of Z would be technically wrong: it would make the proof system incomplete for
non-serial frames (frames with endpoints). If the project intends completeness for serial
frames specifically, the axioms must remain. They encode the correct frame condition.

---

## Long-term Implications

### Option Comparison: Nontrivial vs Frame-Specialized valid

| Aspect | Add Nontrivial to valid | Keep valid universal |
|--------|------------------------|---------------------|
| Sorry sites closed | Both (2 sorry) | Zero (need valid_nontrivial) |
| Semantic precision | Higher (matches intended frame class) | Lower (too strong a predicate) |
| Completeness theorem | Valid as-is | Needs restating for valid_nontrivial |
| Mathlib alignment | Nontrivial is standard | Valid over trivial groups is non-standard |
| Code changes | 1 line in Validity.lean | ~40 lines + new predicate |
| Risk | Very low | Low-medium |

### What "Sorry-Free Completeness" Requires

For the zero-debt completeness goal, the key requirements are:
1. **Soundness**: Every derivable formula is valid (in the appropriate frame class)
2. **Completeness**: Every valid formula is derivable
3. Both theorems stated and proved without sorry

The two seriality sorry sites block requirement (1) for the base soundness theorem.
Since `axiom_base_valid` calls `serial_future_axiom_valid` and `serial_past_axiom_valid`,
and `soundness` calls `axiom_base_valid`, the entire soundness chain carries sorries
from these two leaf points.

Adding `Nontrivial` to `valid` is the minimal, targeted fix that:
- Closes exactly these 2 sorry sites
- Does not require redesigning any other part of the soundness or completeness architecture
- Aligns the semantics with the standard frame class for temporal logic

### Interaction with the Chain Construction Sorries

The chain construction sorries (in `RootScopedChain.lean`) are orthogonal to the seriality
sorry. They are about the defect discharge mechanism for Until/Since eventuality resolution.
Fixing the seriality sorry does NOT unblock the chain construction sorries, and vice versa.
These are independent problems.

The seriality fix is strictly easier: it is a one-line type signature change plus two short
proof completions (~15 lines total). The chain construction sorries represent the main
research challenge (50+ rounds invested).

### Standard Temporal Logic Literature Alignment

The paper by Burgess (1984) states completeness for linear temporal logic over "the strict
ordering of the integers" — which is precisely `[Nontrivial] [NoMaxOrder] [NoMinOrder]`.
Goldblatt (1992) uses "serial frames" (every point has a successor and predecessor).
Neither source considers validity over trivial or bounded ordered groups as meaningful.

The project's `valid` definition, by omitting `Nontrivial`, is more general than the
intended semantics. This is a conservative choice (harder to be valid), but it creates
an avoidable sorry for the seriality axioms. The fix aligns the formalization with the
standard mathematical meaning of "temporal validity."

### Why This Is NOT Introducing New Axioms

A common failure mode in Lean formalization is resolving sorry by adding axioms (e.g.,
`axiom serial_valid : ⊨ ...`). The recommended fix does NOT do this. It changes the
TYPE of the valid predicate to match the intended domain of discourse. The sorry sites
then close by existing Mathlib lemmas (`exists_gt` for `NoMaxOrder`, `exists_lt` for
`NoMinOrder`). No new mathematical content is introduced.

### The Semantic_consequence Definition Also Needs Updating

If `valid` is updated with `[Nontrivial D]`, consistency requires also updating
`semantic_consequence` in `Validity.lean` (line 96-101) to include `[Nontrivial D]`.
These two predicates should be aligned. Without this, the statement
`valid_iff_empty_consequence` (line 204) would need a proof that bridges the two
quantifier signatures — currently it is a definitional equivalence that would break.

---

## Confidence Level

**Confidence: Very High (95%)**

The diagnosis is mathematically unambiguous:
1. `NoMaxOrder` is necessary and sufficient for `F(T)` at any time
2. `Nontrivial D` implies `NoMaxOrder D` for `LinearOrderedAddCommGroup D` (Mathlib theorem)
3. The `valid_dense` and `valid_discrete` predicates already use `[Nontrivial D]`
4. Z (the canonical model's temporal type) is `Nontrivial`

The remaining 5% uncertainty is:
- Whether adding `[Nontrivial D]` to `valid` causes any downstream proof breakage
  (unlikely, since it weakens the assumption on callers of `valid`)
- Whether `exists_gt` is the right Mathlib lemma name or whether a slightly different
  proof term is needed (easily verified with lean_hover_info)

The fix is isolated, well-motivated by the literature, and consistent with the project's
existing approach in `valid_dense` and `valid_discrete`.

---

## File Reference for Implementation

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean`
  Lines 73-77: `def valid` — add `[Nontrivial D]` typeclass constraint
  Lines 96-101: `def semantic_consequence` — add `[Nontrivial D]` for consistency
  Lines 191-195: `valid_implies_valid_dense` — still works (Nontrivial propagates)
  Lines 197-199: `valid_implies_valid_discrete` — still works

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Soundness.lean`
  Lines 198-209: `serial_future_axiom_valid` — sorry closes with `exists_gt`
  Lines 211-218: `serial_past_axiom_valid` — sorry closes with `exists_lt`

No other files require modification for this targeted fix.
