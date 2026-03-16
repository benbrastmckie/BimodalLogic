# Research Report: Task #961 (Team Research - Run 006)

**Task**: 961 - quotient_density_iteration_no_max_min_dense
**Date**: 2026-03-13
**Mode**: Team Research (2 teammates)
**Session**: sess_1773631222_f0a6b5
**Domain Override**: math

## Summary

Two research teammates investigated the fundamental termination obstacle blocking
task 961. **Key finding**: A cleaner proof architecture exists using Mathlib's
`denselyOrdered_iff_forall_not_covBy`, combined with an asymmetric iteration strategy
leveraging `dense_timeline_has_strict_intermediate`. The termination gap remains,
but both teammates converge on the same structural approach and agree it is the
most mathematically elegant path forward.

---

## Key Findings

### Primary Analysis (Teammate A)

**Core Insight**: The problem has been over-constrained. We don't need MCS-level
strict intermediates — we need quotient-level strict intermediates. These are
different requirements:

- MCS-level strict: `CanonicalR(p,c) ∧ ¬CanonicalR(c,p) ∧ CanonicalR(c,q) ∧ ¬CanonicalR(q,c)`
- Quotient-level strict: `[p] < [c] < [q]`, meaning only `[c] ≠ [p]` AND `[c] ≠ [q]`

**The Reflexivity Propagation**:
The lemma `dense_timeline_has_strict_intermediate` proves: when source `a` is
**reflexive**, the intermediate `c` satisfies `¬CanonicalR(b, c)` — i.e., `c ≁ target`.

The missing link: **equivalence class membership implies reflexivity**. If `c ~ p`,
then `c` is reflexive (via `mutual_canonicalR_implies_reflexive`). So after any
iteration that produces an element equivalent to the source, the next iteration
uses a reflexive source and thus guarantees strict separation from the target.

**The Asymmetric Iteration**:
1. Get `c` from `dense_timeline_has_intermediate(p, q)`: `p ≤ c ≤ q`
2. If `c ≁ p` AND `c ≁ q`: done — `[p] < [c] < [q]`
3. If `c ~ p`: `c` is reflexive → apply `dense_timeline_has_strict_intermediate(c, q)`:
   - Get `d` with `c ≤ d ≤ q` and **`d ≁ q`** (guaranteed!)
   - Either `d ≁ p`: done (strict intermediate found)
   - Or `d ~ p`: iterate from `d`
4. If `c ~ q` (symmetric case): similar with past-direction

**Termination Argument (Sketch, not proven)**:
Each iteration uses `dense_timeline_has_strict_intermediate` with a reflexive
source toward `q`, producing elements strictly not equivalent to `q`. If all
such elements are also equivalent to `p`, we accumulate infinitely many distinct
elements in `[p]` all strictly below `[q]`. This should contradict the formula
structure (specific formula content constraints must eventually force escape from
the source equivalence class), but this argument is not yet formalized.

---

### Alternative Approach (Teammate B)

**Mathlib Discovery — the key architectural improvement**:

```lean
theorem denselyOrdered_iff_forall_not_covBy :
    DenselyOrdered α ↔ ∀ a b : α, ¬a ⋖ b
```

This equivalence in `Mathlib.Order.Cover` means we can prove `DenselyOrdered`
by showing no covering relations exist — a PROOF BY CONTRADICTION structure
instead of a constructive intermediate witness.

**Related Mathlib lemmas confirmed**:
- `not_covBy_iff (h : a < b) : ¬a ⋖ b ↔ ∃ c, a < c ∧ c < b`
- `exists_lt_lt_of_not_covBy` — extract intermediate from non-covering
- `CovBy` definition: `a ⋖ b ↔ a < b ∧ ∀ ⦃c⦄, a < c → ¬c < b`

**Why this is cleaner**:
Instead of constructing a witness (which requires termination), we assume `[p] ⋖ [q]`
and derive contradiction from the density + reflexivity structure. The proof goal
becomes: "assuming covering, nothing can be strictly between [p] and [q] — but
density gives something — contradiction."

**Termination Analysis**:
The same fundamental problem appears: assuming covering, every intermediate
lands in `[p]` or `[q]`, leading to the same asymmetric iteration. The no-covers
structure doesn't eliminate the termination question; it reframes it as a
contradiction derivation. However, the contradiction framing may be more
tractable in Lean.

---

## Synthesis

### What Both Teammates Agree On

1. **Architecture**: Use `denselyOrdered_iff_forall_not_covBy` (Teammate B's discovery)
   as the top-level proof structure for DenselyOrdered. Prove `timelineQuot_no_covBy`
   as the key lemma.

2. **Key Tool**: `dense_timeline_has_strict_intermediate` (from task 962) is the
   right tool for the asymmetric iteration in the contradiction proof.

3. **Reflexivity Propagation**: `c ~ p → c` is reflexive is the essential link
   enabling the asymmetric iteration.

4. **Gap Honest Assessment**: Neither teammate found a complete termination proof.
   The formula content constraint argument is the most promising direction.

### Conflicts Found and Resolved

**Conflict**: Teammate A claims HIGH confidence in eventual termination via formula
structure; Teammate B rates this MEDIUM, noting the iteration may not terminate.

**Resolution**: Teammate B is more conservative but correct. The iteration may not
terminate with the tools currently available. A new lemma is needed about
reflexive equivalence class structure. Both approaches agree on the architecture;
the gap is in the termination sub-proof.

### Gaps Identified

1. **No lemma**: We lack `reflexive_interval_exhaustion` or equivalent — that a
   reflexive equivalence class cannot contain infinitely many distinct elements
   all strictly below a non-equivalent target. This is the crucial missing piece.

2. **Formula structure**: The relationship between formula content and equivalence
   class membership under repeated density application is not formalized. The
   conjecture is that formula constraints accumulate and eventually force escape,
   but this needs a proof.

---

## Recommended Implementation Plan (for /revise 961)

### Architecture

```lean
-- Top level: use denselyOrdered_iff_forall_not_covBy
instance : DenselyOrdered (TimelineQuot root_mcs root_mcs_proof) :=
  denselyOrdered_iff_forall_not_covBy.mpr timelineQuot_no_covBy

-- Key theorem
theorem timelineQuot_no_covBy (a b : TimelineQuot root_mcs root_mcs_proof) :
    ¬ a ⋖ b := by
  intro ⟨hab, h_no_between⟩
  -- Assume covering: a < b, no element strictly between
  -- Get representatives p, q
  -- Apply density to get intermediate c
  -- Case split: c ~ p or c ~ q
  -- If c ~ p: reflexivity → apply dense_timeline_has_strict_intermediate(p, q)
  --           get d ≁ q → [d] must be a or b → [d] = a (= [p])
  --           contradiction must come from additional lemma
  sorry -- THE termination gap
```

### Required New Lemma

The gap requires one of:

**Option 1** (formula wellfoundedness): A lemma showing that when source `p` is
reflexive and `[p] < [q]`, the density construction applied `n` times must produce
something not in `[p]` when `n > subformulaClosure(delta).card` for the
distinguishing formula `delta`.

**Option 2** (non-constructive cardinality): A lemma showing that the interval
`{x | p ≤ x ≤ q}` cannot be partitioned into exactly two non-empty equivalence
classes `[p]` and `[q]` when the preorder is dense. This would be the cleanest
mathematical statement.

**Option 3** (accessibility chain bound): The density construction creates
intermediates via formula Lindenbaum extension. Since the accessibility axioms
are finite (finite axiom set), the depth of strictly increasing CanonicalR chains
is bounded. This may give the termination bound directly.

**Recommended**: Option 2 is most mathematically natural. It says: a dense
preorder cannot have a "covering pair" in its Antisymmetrization. This should
be provable from first principles without induction on formula structure.

### Proof Attempt for Option 2 (Key Mathematical Argument)

Assume `[p] ⋖ [q]`. Then every element between `p` and `q` (at preorder level) is
in `[p] ∪ [q]`. Define:
- `A = {x | CanonicalR(p, x) ∧ CanonicalR(x, q) ∧ CanonicalR(x, p)}`  (x in [p] ∩ [p,q])
- `B = {x | CanonicalR(p, x) ∧ CanonicalR(x, q) ∧ CanonicalR(q, x)}`  (x in [q] ∩ [p,q])

Claim: every element of A is strictly below every element of B in the preorder.

(This is because a ∈ A means a ~ p, b ∈ B means b ~ q, and [p] < [q].)

Now take any a ∈ A and b ∈ B. By density of the preorder, ∃ c with a < c < b.
c must be in A or B. If c ∈ A: c ~ p, so [p] ≤ [c]. But also c < b means [c] ≤ [b] = [q].
If c ∈ B: c ~ q, symmetric.

The key: in A, every element is below every element of B. Apply density between
any a ∈ A and b ∈ B: get c strictly between them. c ∈ A means c > a strictly.
Apply density again between c and b: get c' ∈ A with c < c' < b. This creates
an infinite STRICTLY INCREASING chain in A, all below b.

But wait: if a, c, c' all satisfy a ~ c ~ c' ~ p (all equivalent to p), then by
the preorder antisymmetry within equivalence classes... actually this IS possible
in a preorder (multiple non-equivalent elements can be mutually inaccessible).

**The genuine conclusion**: Option 2 does not immediately yield a contradiction from
the density argument alone. A separate invariant about the density construction
is needed.

**Bottom line**: The most viable path is **Option 1** (formula wellfoundedness):
add a lemma `density_escapes_source_class` in DenseTimeline.lean that proves,
given p reflexive and [p] < [q], the density function applied with the canonical
distinguishing formula produces an element not equivalent to p.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary mathematical analysis | Completed | HIGH (architecture) / MEDIUM (termination) |
| B | Alternative approaches / Mathlib | Completed | MEDIUM-HIGH |

### Conflicts Resolved

1. Termination certainty: A (high confidence) vs B (medium). Resolution: B is more
   accurate; termination needs additional lemma.

### Gaps Identified

- `density_escapes_source_class` lemma not proven
- No Mathlib theorem for "dense preorder → dense antisymmetrization" (gap in Mathlib)

---

## Recommendations

1. **Revise plan to v006** using `denselyOrdered_iff_forall_not_covBy` as top-level
   architecture. This is cleaner than constructive strict intermediate.

2. **Add `density_escapes_source_class` lemma** to DenseTimeline.lean:
   ```
   If p is reflexive, [p] < [q], then density_frame_condition applied to (p, q)
   produces intermediate c with ¬CanonicalR(c, p) (c not equivalent to p).
   ```
   This is the key missing lemma. It may follow from the specific formula content
   of the Lindenbaum extension used in `density_frame_condition_reflexive_source`.

3. **NoMaxOrder and NoMinOrder** follow easily once DenselyOrdered is proven:
   - NoMaxOrder: Given [p], apply density on a serial (future-having) element
   - NoMinOrder: Symmetric

4. **Consider**: Does `density_frame_condition_reflexive_source` actually prove
   `c ≁ p` (strict from source) rather than just `c ≁ q` (strict from target)?
   If the source-strict version can be proven, the problem is solved directly.
   This is worth investigating in the implementation.

---

## References

- `Mathlib.Order.Cover` — `denselyOrdered_iff_forall_not_covBy`
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` — `dense_timeline_has_strict_intermediate`
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` — `density_frame_condition_reflexive_source`
- Prior research: research-001 through research-005
