# Synthesis Report: Big Picture Analysis and Alternative Approaches

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Date**: 2026-03-18
**Focus**: Why termination fails, alternative paths, recommended direction
**Session ID**: sess_1773893999_6d58c5

---

## Summary

Both teammates converge on the same diagnosis and similar recommendations. The forward_F termination problem is **not a proof technique failure** — it reflects a genuine formalization gap between the mathematical intent of the dovetailed construction and what is actually provable about it. Every approach hits the same wall because the underlying mathematical fact needed (that the dovetailed build exhaustively covers F-obligations even in the small-step case) is not currently provable from the existing infrastructure.

---

## Agreed Diagnosis

### The Core Obstacle (Both Teammates Agree)

The density argument, when applied in the small-step case, produces a witness `w` with `F^j(phi) ∈ w.mcs` — NOT `phi ∈ w.mcs`. Peeling off j layers of F requires j recursive calls, each of which may again hit the small-step case and introduce new j' layers. There is no well-founded measure that bounds this process because:

1. **Formula depth increases**: density replaces `phi` with `F^j(phi)` which is syntactically larger
2. **j is not bounded**: each recursive call chooses its own j' independently
3. **Build stage increases but is unbounded**: no finite upper bound exists
4. **Large-step propagation fails**: witness `w.point_index` can be much smaller than the step at which w was added (the build grows sparsely, not at every step)

This is a FINITARY vs INFINITARY gap: the construction terminates mathematically (every pair is eventually processed), but the termination argument is inherently infinitary (requires knowing the timeline is "eventually complete") — not a finite descent.

### The Coverage Theorem Has Its Own Gap (Teammate B)

Plan v13's coverage approach (`dovetailed_covers_reachable`) faces an additional obstacle: the dovetailed build's witness for (p.index, encode(phi)) is a fresh Lindenbaum extension that may not equal the canonical `forward_F` witness W. Since Lindenbaum extensions of the same consistent seed are NOT unique in propositional logic (different extensions can include `q` or `¬q` differently), the coverage theorem's inductive step cannot be closed by identity of MCS witnesses.

Furthermore, the coverage theorem requires knowing that a missed obligation (where `pair(p.index, encode(phi)) <= entry_stage(p)`) is somehow addressed. The current dovetailed build does nothing when the point index is out of range at processing time — these obligations are permanently missed.

### The Real fix is in the Build (Teammate B's Finding 9)

The dovetailed construction, as currently implemented, may genuinely fail to cover F-obligations for points that arrive AFTER their obligation step was processed. This is not a proof artifact — it is a construction completeness issue. The density workaround (use a larger encoding) only produces witnesses for the larger-encoded formula, not for phi.

---

## Divergence: What the Teammates Emphasize

**Teammate A** focuses on the single-sorry path in `forward_F_core` (line 806): the "j > 0" case is THE ONLY blocker, and everything else is proved. They note that `forward_F_chain_witness` with the `i` parameter introduces unnecessary complexity, and the `forward_F_core` structure is already close to correct. They suggest the fuel-based approach or non-constructive by-contradiction as alternatives.

**Teammate B** takes a more architectural view: the coverage theorem approach (plan v13) is sound in structure but has two gaps — (a) the inductive step needs the missed-obligation problem solved, and (b) MCS non-uniqueness prevents identification of witnesses. Teammate B recommends redesigning the dovetailed build to retroactively process missed obligations.

---

## Recommended Path Forward

### Immediate Action: Localized Sorry (Both teammates agree)

**Replace the current broken proof structure** with a clean sorry at the right location:

**Option A (Teammate A's preference)**: Keep `forward_F_core` structure, place sorry at the j > 0 case in the small-step branch. This is a single sorry at line 806 with precise documentation.

**Option B (Teammate B's preference)**: Implement plan v13's structure — define `CanonicalR_chain`, place sorry in `dovetailed_covers_reachable`'s inductive step. This sorry is at a higher abstraction level and more mathematically honest about what is missing.

**Either option is better than the current state.** The current sorries (lines 806 and 959) are inside broken induction proofs with misleading structure. A clean sorry at a well-documented mathematical gap is the right representation.

### Medium-term: Redesign the Dovetailed Build

The construction needs to guarantee that every F-obligation is addressed, including "late-arriving" obligations where the point arrives after the pair's step was processed. The fix requires the dovetailed step function to either:

1. **Re-process** obligations when new points arrive (retroactive processing)
2. **Use a different pairing** that guarantees pair(p.index, k) > entry_stage(p) for all relevant k

Option 2 is cleaner: modify the enumeration so that obligation `(p.index, k)` is always processed at a step AFTER p's entry stage. For example, use a pairing function that depends on entry_stage rather than absolute index.

This is a significant redesign of `DovetailedBuild.lean` and all downstream files, warranting a separate task.

### Non-Starter Approaches (Both teammates agree to avoid)

- **Well-founded recursion on any proposed measure**: All proposed measures (formula depth, density index j, build stage, lexicographic combinations) fail for provably identified reasons
- **Large-step propagation claim**: `w.point_index >= m` is not provable (sparse build)
- **MCS uniqueness argument**: Lindenbaum extensions are not unique in propositional logic

---

## Specific Code Actions

### Immediate (this task):

1. **Remove `forward_F_chain_witness`** (lines 813-959 in DovetailedTimelineQuot.lean) — it is a broken attempted proof that misleadingly suggests progress
2. **Keep `forward_F_core`** (lines 652-806) as the structure for the proof attempt, or adopt plan v13's coverage structure
3. **Place a clean sorry** at exactly one location with full documentation of the gap
4. **Do the same for `backward_P_chain_witness`** symmetrically

### Preferred sorry placement and documentation:

```lean
-- In forward_F_core, small-step case, j = succ j':
-- FORMALIZATION GAP (Task 981):
-- We have F(iteratedFuture j' psi) ∈ w.mcs and CanonicalR p.mcs w.mcs,
-- and need phi ∈ q.mcs for some q reachable from w via CanonicalR.
--
-- Mathematically true: the dovetailed construction eventually processes the obligation
-- (w.point_index, encode(iteratedFuture j' psi)) and adds a witness, and this
-- eventually terminates after at most j' more steps.
--
-- Lean formalization gap: there is no well-founded measure for this recursion.
-- Every proposed measure (formula depth, density index j, build stage) fails
-- because: (a) depth increases via density, (b) j is chosen fresh at each step,
-- (c) build stage is unbounded. The termination is infinitary (the construction
-- is exhaustive over all pairs) but cannot be expressed as a finite descent.
--
-- Fix requires: either redesigning DovetailedBuild to guarantee retroactive
-- obligation coverage, or proving a coverage theorem (dovetailed_covers_reachable)
-- which has its own gap (see DovetailedCoverageReach.lean).
sorry
```

---

## Impact Assessment

**Is the overall completeness theorem still valid?** YES. The mathematical argument for dense completeness is sound. The dovetailed construction, properly implemented with retroactive processing, would make the theorem provable. The current sorry represents an implementation gap in DovetailedBuild.lean's step function, not a flaw in the proof strategy.

**Is the sorry in a "leaf" position?** YES, after cleanup. Once `forward_F_chain_witness` is removed and replaced with the clean structure, the sorry will be at exactly one location in DovetailedTimelineQuot.lean (or DovetailedCoverageReach.lean if plan v13 is adopted). All downstream proofs that use forward_F will be properly abstracted behind the FMCS structure.

**What other sorries exist?** `density_of_canonicalR` in CanonicalTimeline.lean (line 183) is a separate unresolved sorry. The DenselyOrdered intermediate case in DovetailedTimelineQuot.lean (around line 295) may also remain.

---

## Confidence

**High** that the diagnosis is correct — both independent analyses converge.
**High** that the immediate action (clean sorry replacement) is the right short-term move.
**Medium** that the DovetailedBuild redesign is the correct long-term fix.
**Low** that any approach can close the gap without additional infrastructure (new task needed).
