# Teammate A Findings — Option A Deep Dive

**Task**: 90 — Decide between Option A (redefine bx_le via Until-witnesses) and Option B (Henkin-closure enrichment)
**Date**: 2026-04-10
**Teammate**: A — Primary Approach Analyzer
**Focus**: Option A — redefine `bx_le` via Until-witnesses

---

## Background: The Mismatch

The current definition:

```lean
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas
```

means `w ≤ v` iff every formula whose **global future** holds at w also holds at v.
The four sorry'd lemmas (`bx_until_eventuality_resolution`, `bx_until_backward`,
`bx_since_eventuality_resolution`, `bx_since_backward`) fail because BX7 speaks to
the linear ordering of **Until witnesses** (local formula-level witnesses), not to
**G-content inclusion** (global universal-future sets). No bridge between the two
exists in the current axiom system (confirmed: task 86 report 08, section 3).

---

## Option A Definition (exact Lean signature)

The Until-witness ordering on BXPoints is:

```
w ≤_U v iff for all φ ψ, φ U ψ ∈ w implies φ U ψ ∈ v
           OR ψ ∈ v
```

but this is not the right formulation for a preorder useful in the truth lemma.
The standard Burgess/Gabbay-Hodkinson-Reynolds witness ordering is:

> `w ≤ v` iff for all φ ψ: if `φ U ψ ∈ w` and `ψ ∉ w`, then `φ U ψ ∈ v` or `ψ ∈ v`.

In Lean, the new definition would look like:

```lean
/-- Until-witness ordering: w ≤_uw v iff for every pending Until formula φ U ψ ∈ w
    (with ψ ∉ w), either the Until formula has propagated to v (φ U ψ ∈ v), or
    ψ has been resolved at v (ψ ∈ v). -/
def bx_le_uw (w v : BXPoint) : Prop :=
  ∀ (φ ψ : Formula),
    Formula.untl φ ψ ∈ w.formulas →
    ψ ∉ w.formulas →
    Formula.untl φ ψ ∈ v.formulas ∨ ψ ∈ v.formulas
```

### Why This Particular Formulation

- If `ψ ∈ w`, then `v = w` satisfies the vacuous case; no constraint needed.
- If `φ U ψ ∈ w` and `ψ ∉ w`, the Until formula is "pending" and its witness lies
  strictly after `w`. We need `v` to be at least as close to the witness as `w` is.
- This is exactly what BX7 (linearity of Until) constrains: if two Until formulas hold
  simultaneously at w, their witnesses are linearly ordered. This lets us prove that
  bx_le_uw is a total preorder on BXPoints.

---

## How the 4 Sorries Close Under Option A

### 1. `bx_until_eventuality_resolution` (Frame.lean:632)

**Goal**:
```
w : BXPoint, φ ψ : Formula
h_until : φ.untl ψ ∈ w.formulas
h_not_psi : ψ ∉ w.formulas
⊢ ∃ v, bx_le_uw w v ∧ ψ ∈ v.formulas ∧
    ∀ u : BXPoint, bx_le_uw w u → bx_le_uw u v ∧ ¬bx_le_uw v u → φ ∈ u.formulas
```

**Under the new definition**, the key property is that bx_le_uw is **total** (BX7 gives
this), so the chain `{u | bx_le_uw w u}` is linearly ordered.

**Step 1**: By BX10 (`until_F`): `F(ψ) ∈ w`, so by `bx_forward_witness` (which
works for any ordering that admits F-witnesses via Lindenbaum) there exists `v ≥ w`
with `ψ ∈ v`. Under the new ordering, the seed for `v` should be:
`{ψ} ∪ g_content(w)` (unchanged — this is the forward witness seed).

**Step 2 (guard proof)**: For any `u` with `bx_le_uw w u` and `bx_le_uw u v` but
`¬bx_le_uw v u`:
- Since the ordering is total, `bx_le_uw u v ∧ ¬bx_le_uw v u` means `u <_uw v` strictly.
- Strict ordering means: there exists `α β` with `α U β ∈ u.formulas`, `β ∉ u.formulas`,
  and NOT (`α U β ∈ v.formulas ∨ β ∈ v.formulas`). Since `β ∈ v.formulas` (taking `α = φ, β = ψ`).
- Actually the guard proof needs: `φ U ψ ∈ u → φ ∈ u` (when `ψ ∉ u`). This follows
  from BX9 (until_elim: `φ U ψ → φ ∨ ψ`) since `ψ ∉ u` means the disjunct is `φ`.
- We need `φ U ψ ∈ u`: by `bx_le_uw w u` and `h_until`: since `φ U ψ ∈ w` and `ψ ∉ w`,
  the definition of `bx_le_uw w u` gives `φ U ψ ∈ u ∨ ψ ∈ u`. If `ψ ∈ u`, then
  `bx_le_uw u v` is vacuously satisfied (the pending formula disappears), but then
  `¬bx_le_uw v u` requires v not to satisfy `bx_le_uw v u`... this case analysis
  requires careful BX5/BX6 work to avoid. The condition `¬bx_le_uw v u` with `ψ ∈ u`
  can actually be ruled out by the choice of `v`.

**Assessment**: The argument is plausible in outline but involves subtle interactions
between BX5 (self_accum_until) and the new ordering. The proof of transitivity of
bx_le_uw itself requires BX7 in a non-trivial way. The guard proof requires
showing `φ U ψ` propagates forward through the new ordering.

### 2. `bx_until_backward` (Frame.lean:664)

**Goal**:
```
w v : BXPoint, h_wv : bx_le_uw w v, h_ψv : ψ ∈ v.formulas
h_guard : ∀ u, bx_le_uw w u → (bx_le_uw u v ∧ ¬bx_le_uw v u) → φ ∈ u.formulas
h_not_psi : ψ ∉ w.formulas
⊢ φ.untl ψ ∈ w.formulas
```

**Under the new definition**:
- **By contradiction**: assume `¬(φ U ψ) ∈ w`, so `(φ U ψ).neg ∈ w`.
- By BX4 (`connect_future`): `G(P(¬(φ U ψ))) ∈ w`. So for any `u` with `bx_le_uw w u`,
  we get `P(¬(φ U ψ)) ∈ u`.
- Since `bx_le_uw w v`, we get `P(¬(φ U ψ)) ∈ v`.
- By `bx_backward_witness`: there exists `u ≤ v` with `¬(φ U ψ) ∈ u`.
- **Gap**: Under the new ordering, we need `bx_le_uw w u`. But BX4 gives
  G(P(¬(φ U ψ))) ∈ w. Here "G" in the g_content sense means `∀ v' ≥ w (g_content), P(¬(φ U ψ)) ∈ v'`.
  The new ordering `bx_le_uw` is **different** from `g_content` inclusion, so this
  G-based step no longer directly applies.

**This is the critical break**: The backward proof uses `bx_G_forward` which exploits
`g_content ⊆ v.formulas`. If bx_le is no longer g_content-based, this entire G-content
propagation machinery breaks for the backward direction.

### 3 & 4. `bx_since_eventuality_resolution` and `bx_since_backward`

These are symmetric to the Until case using H-content and past witnesses. All the same
issues apply in the past direction.

---

## Equivalence Proof Sketch (bx_le_new ↔ g_content_subset)

The task description says to use BX10/BX12/BX4/T to prove equivalence. Let us
analyze each direction carefully.

### Claim: `bx_le_uw w v → g_content(w) ⊆ v.formulas`

**Attempt**: Suppose `G(φ) ∈ w`. We want `φ ∈ v.formulas`.

- The only direct link from G-formulas to Until-formulas is through BX12
  (`F_until_equiv`: `F(φ) → ⊤ U φ`) and BX10 (`until_F`: `φ U ψ → F(ψ)`).
- From `G(φ) ∈ w` we get `φ ∈ w` (by BX1/temp_t_future).
- We need `φ ∈ v`. The only way `bx_le_uw` tells us about `v` is through
  Until formulas pending at w.
- `G(φ)` being in w does not imply any Until formula is pending at w.
  Unless we also have `¬φ ∉ w` (which is true since `G(φ) ∈ w` gives `φ ∈ w`),
  but that's a statement about w, not about Until formulas.

**Key obstacle**: `G(φ) ∈ w` cannot be converted to a pending Until formula `α U β ∈ w`
with `β ∉ w` without the equivalence `G(φ) ↔ "always φ U ⊤" = ¬F(¬φ)`. This requires
that `G = "never Until something false"`, i.e., `G(φ) ↔ ¬F(¬φ)`, which is the
definition. But this still does not give an Until formula with a *pending* witness.

**The equivalence is NOT straightforward to prove in either direction.**

Specifically:
- bx_le_uw w v does NOT imply g_content(w) ⊆ v: Consider MCS w with `G(p) ∈ w`
  but no Until formulas with pending witnesses. Then `bx_le_uw w v` holds vacuously
  for ANY v (no constraints at all). But g_content(w) ⊆ v requires p ∈ v for all v,
  which is false.

This is a **fatal flaw**: when w has no pending Until formulas, `bx_le_uw w v` holds
for every v, making the ordering trivial (the bottom element relates to everything).
Under such an ordering, `G_iff_mcs` (`G(φ) ∈ w ↔ ∀ v ≥ w, φ ∈ v`) fails because
"all v ≥ w" under bx_le_uw is "all v" (when no Until formulas are pending), and
not all v need contain φ.

**Conclusion**: The two orderings are NOT equivalent. The bx_le_uw ordering is strictly
weaker than g_content inclusion, not equivalent to it.

---

## Impact on Existing Box-Direction Proof

The existing sorry-free proofs using `bx_le` include:

1. **`bx_le_refl`** (Frame.lean:140): Uses BX1 (`G(φ) → φ`). Under bx_le_uw, reflexivity
   holds trivially: `bx_le_uw w w` requires that for every pending `φ U ψ ∈ w` (ψ ∉ w),
   either `φ U ψ ∈ w` (trivially true) or `ψ ∈ w` (excluded by assumption). The
   `φ U ψ ∈ w` branch is trivially satisfied. So reflexivity holds without repair.

2. **`bx_le_trans`** (Frame.lean:153): Uses temp_4 (`G(φ) → G(G(φ))`). Under bx_le_uw,
   transitivity requires: if every pending `φ U ψ ∈ w` either propagates to u or resolves
   at u, AND every pending `α U β ∈ u` either propagates to v or resolves at v, then every
   pending `φ U ψ ∈ w` either propagates to v or resolves at v. This requires case analysis:
   - If `φ U ψ ∈ u` (propagated): then bx_le_uw u v applies to this formula (if `ψ ∉ u`).
   - If `ψ ∈ u` (resolved): but we need `φ U ψ ∈ v` or `ψ ∈ v`, and we only know
     `ψ ∈ u`. Does `ψ ∈ u` propagate to v? Only if G(ψ) ∈ w... which we don't have.
   Transitivity **fails** in general for bx_le_uw.

3. **`bx_G_forward`** (Frame.lean:192): Uses `h_le : bx_le w v` and `h_G : G(φ) ∈ w`.
   Under bx_le_uw, there is no mechanism to derive `φ ∈ v` from `G(φ) ∈ w` because
   bx_le_uw does not track G-formulas. This proof **breaks completely**.

4. **`bx_G_backward`** (Frame.lean:208): Seed construction uses `g_content(w)` for the
   Lindenbaum extension. The connection between bx_le_uw and g_content is required
   here (`fun χ hχ => hM_sup (Set.mem_union_right _ hχ)` on line 255). This breaks.

5. **`bx_H_forward`** (Frame.lean:266): Uses `g_content_subset_implies_h_content_reverse`.
   Breaks if bx_le_uw replaces g_content inclusion.

6. **`box_preserved_along_bx_le`** (Frame.lean:538): Uses temp_future (`□φ → G(□φ)`)
   which goes through G-content. Breaks.

7. **`bx_modal_equiv_of_bx_le`** (Frame.lean:581): Corollary of above. Breaks.

8. **`G_iff_mcs`** (TruthLemma.lean:124): Central to the G truth lemma. Breaks entirely.

9. **`H_iff_mcs`** (TruthLemma.lean:137): Breaks.

**Cascading count**: 9 existing sorry-free theorems break. All the G/H truth lemma
infrastructure must be rebuilt on different foundations.

---

## Impact on TaskModel Embedding (Completeness.lean:154)

The sorry at Completeness.lean:154 is:

```lean
-- Frame.lean X-vs-G mismatch: Until formulas don't propagate through
-- g_content-based bx_le ordering
sorry
```

If Option A is adopted, this sorry is not automatically closed. The sorry at :154
also depends on:
- A canonical TaskModel construction embedding BXPoints into a TaskFrame
- G/H truth lemma cases for non-constant histories
- Until/Since eventuality resolution

**Option A changes the problem at :154** but does not solve it:
- The G/H truth lemma cases would now be based on bx_le_uw rather than g_content
  inclusion, but the G_iff_mcs theorem (which is needed) breaks under Option A.
- The TaskModel embedding would need to use a different temporal ordering, one
  compatible with bx_le_uw. But bx_le_uw does not support the standard G/H
  frame conditions (G requires universal future, not just Until propagation).

The sorry at :154 would remain blocked on different (equally hard) problems.

---

## Complexity Estimate (lines of Lean, hours)

### What must be proved from scratch under Option A

| Item | Estimated LOC | Notes |
|------|--------------|-------|
| New bx_le_uw definition | 10 | Trivial |
| Reflexivity for bx_le_uw | 15 | Trivial |
| Transitivity for bx_le_uw | 80–120 | Requires BX7; likely fails (see §above) |
| G_iff_mcs replacement | 150–250 | Needs entirely different approach |
| H_iff_mcs replacement | 150–250 | Mirror |
| box_preserved_along_bx_le | 100–150 | Needs new temp_future analogue |
| bx_G_backward rebuild | 100–150 | Seed must change entirely |
| bx_H_backward rebuild | 100–150 | Mirror |
| bx_until_eventuality_resolution | 200–400 | Core target; feasibility unclear |
| bx_until_backward | 150–300 | Core target; feasibility unclear |
| bx_since_* (both) | 350–700 | Mirrors |
| Total | ~1,400–2,500 LOC | — |

**Time estimate**: 40–80 hours (matching task 89's assessment for this approach).

---

## Confidence Level: low

**Reason**: Option A has two independent fatal flaws:

**Flaw 1 — Non-equivalence**: `bx_le_uw` is NOT equivalent to `g_content` inclusion.
When an MCS has no pending Until formulas, `bx_le_uw` places it below everything
(vacuously), destroying the G-truth lemma (`G_iff_mcs`). This is not a gap to fill —
it is a provable non-equivalence. The equivalence proof the task description calls for
does not exist.

**Flaw 2 — Transitivity failure**: `bx_le_uw` is not transitive in general. If
`ψ ∈ u` resolves a pending `φ U ψ` at step w→u, there is no mechanism to carry `ψ`
forward to v at step u→v (since bx_le_uw only tracks pending Until formulas, not
resolved ones). Transitivity of bx_le_uw is not derivable from BX axioms alone.

These flaws are not repair items — they are structural incompatibilities between
the Until-witness ordering and the requirements of the G/H canonical model machinery.
The task description's claim that Option A "works" appears to be based on an incorrect
assumption that the two orderings are equivalent.

---

## Recommended: Option A? NO — recommend Option B or alternative

### Why not Option A

The fundamental problem is that the G/H truth lemma and the Until/Since truth lemma
require **different orderings**:

- G/H truth lemma requires: `w ≤ v ↔ g_content(w) ⊆ v` (the current bx_le)
- Until/Since truth lemma requires: ordering under which pending Until formulas
  either propagate or resolve, and the ordering is **total**

These two orderings are provably non-equivalent (Flaw 1 above). Replacing one with
the other breaks the currently working proofs.

### What would actually work

**Option 1 (Best — matches task 89 priority 1 + 2)**:
Re-add `temp_linearity` to the axiom system. This axiom:
- Was removed during BX refactoring (documented in task 88 as an error)
- Is semantically valid (sorry-free soundness proof exists)
- Makes `bx_le` (the current g_content definition) provably **total** (linear)
- Under total bx_le, the current 4 sorries become provable using standard techniques:
  - Forward: construct the Zorn-maximal point in the interval [w, ∞) ∩ {v | ψ ∉ v}
  - Backward: BX4 + backward witness + linearity to place u in [w, v)
- No existing sorry-free proofs break
- Effort: 2–4h to re-add axiom + 8–16h to close the 4 sorries
- **Total: 10–20h, 85–90% confidence**

**Option 2 (Option B — Henkin-closure enrichment)**:
Keep `bx_le := g_content-subset` and strengthen MCS closure to include Until witnesses.
This is the Burgess 1984 / Gabbay-Hodkinson-Reynolds approach. The prior research
(task 89, teammate B's work) assigns this 60% confidence and 15–25h.

**Option 3 (Chain-specific guards)**:
Restructure the Frame.lean sorries to quantify over a specific constructed chain
(not all BXPoints), as recommended in task 86 report 08 section 6. This avoids
the global linearity problem by working with chain points only.

### Summary judgment on Option A

Option A is not merely risky — it is **structurally infeasible** as described.
The equivalence proof required does not exist. Adopting Option A would:
1. Break 9 existing sorry-free proofs
2. Fail to establish transitivity of the new ordering
3. Fail to close the G/H truth lemma
4. Require 40–80h of work to discover these dead ends

**Recommend Option B (Henkin-closure enrichment)** as the approach most compatible
with the existing infrastructure, or re-adding `temp_linearity` as the single
highest-ROI action.

---

## Appendix: Key Files and Lines

- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:61` — current `bx_le` definition
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:632` — `bx_until_eventuality_resolution` sorry
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:664` — `bx_until_backward` sorry
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:683` — `bx_since_eventuality_resolution` sorry
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:697` — `bx_since_backward` sorry
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:154` — TaskModel embedding sorry
- `Theories/Bimodal/ProofSystem/Axioms.lean:180` — BX7 (linear_until) definition
- `Theories/Bimodal/ProofSystem/Axioms.lean:241` — BX11 (temp_linearity, currently present)
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean:124` — `G_iff_mcs` (would break under Option A)
- `specs/archive/086_close_bxcanonical_completeness_sorries/reports/08_bxle-linearity-research.md` — bx_le linearity analysis
- `specs/089_close_frame_lean_eventuality_sorries/reports/01_team-research.md` — team synthesis (stale on option feasibility)
