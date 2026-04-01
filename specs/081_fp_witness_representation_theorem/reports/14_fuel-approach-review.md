# Report: Plan v13 Review — Fuel Approach Historical Analysis

**Task**: 81 — F/P Witness Representation Theorem
**Date**: 2026-04-01
**Session**: sess_1775080786_4e64ca
**Type**: Review / Historical cross-reference

## Summary

Plan v13 proposes closing the completeness sorry by proving that fuel `B*B+1` is always sufficient in the bounded witness recursion, making the fuel=0 branches unreachable. **This approach was extensively studied and abandoned in archived tasks 48 and 67.** The fuel invariant weakening problem that killed those attempts applies identically to the current code. Plan v13 should be revised to avoid repeating this known dead end.

## Historical Record

### Task 48: `prove_succ_chain_fam_bounded_f_depth` (Archived)

This task went through the exact cycle plan v13 proposes:

1. **Plan v5** (`specs/archive/048_.../plans/05_fuel-recursion.md`): Proposed explicit fuel parameter bounded by `closure_F_bound(phi)` — the same basic idea as plan v13's "prove B*B+1 suffices."

2. **Execution** (`specs/archive/048_.../summaries/05_fuel-recursion-partial.md`): Discovered a **critical blocker**:

   > "The fuel bound invariant weakens by 1 each time we take an inr step. After at most `closure_F_bound phi` inr steps, we'd have fuel = 0 and couldn't make progress."

   Specifically:
   - In the `inl` case (depth decrease): d decreases, fuel stays same — measure decreases.
   - In the `inr` case (persistence): d stays same, fuel decreases by 1.
   - After enough `inr` steps: fuel = 0, d still nonzero, no contradiction derivable AND no further recursion possible.

3. **Post-mortem** (`specs/archive/048_.../reports/08_lexicographic-wf.md`):

   > "The formula has fixed F-nesting depth `d + f_nesting_depth(psi)`. Nothing in the fuel-based approach bounds how many times the SAME formula can persist."

   Recommended lexicographic recursion on `(depth, steps_remaining)` using `WellFounded.prod_lex` instead.

### Task 67: `prove_bundle_validity_implies_provability` (Archived)

Attempted a **two-fuel variant** (resolve_fuel + defer_fuel). Also failed:
- Summary 11 (`specs/archive/067_.../summaries/11_fuel-invariant-partial.md`): Invariant preservation requires preconditions at recursive calls that cannot be guaranteed.
- Summary 12: Documents the abandoned fuel strategies and predecessor to bounded witness approach.

### ROADMAP.md Alignment

The ROADMAP.md documents the architecture clearly:

- **"Known Gaps (F/P Existential Witnesses)"** (line 184): "These have sorries due to unbounded F/P nesting in arbitrary MCS"
- **"Dead Ends"** section (line 143): Documents multiple failed approaches including the Lindenbaum extension adding G(neg(phi)) — the same obstruction plan v13's research identified.
- **"Separate-Direction Witnesses"** (line 167): The current working approach uses separate G/H seeds, which are sorry-free. The F/P gap is explicitly acknowledged as an open problem.
- **"Representation Theorem Goal"** (line 234): Emphasizes that only the algebraic/canonical model approach should be pursued — no retreating to FMP.

## Why Plan v13 Faces the Same Problem

Plan v13's Phase 1 asks: "does each recursive call strictly decrease either d or fuel?" This is exactly the question task 48 answered **no** to. The recursion structure in `restricted_combined_bounded_witness_fueled` is:

| Case | d change | fuel change | Problem |
|------|----------|-------------|---------|
| `inl` (depth decrease) | d → d-1 | unchanged | Works fine |
| `inr` (persistence) | unchanged | fuel → fuel-1 | Invariant weakens |
| fuel = 0 | — | — | Cannot recurse, cannot derive contradiction |

The `inr` case can repeat up to `fuel` times without reducing depth. When fuel reaches 0 with d still positive, the proof is stuck — there is no argument that this state is unreachable, because **persistence at the same depth CAN happen arbitrarily many times** (the same F-formula can persist through many chain steps before being resolved).

Plan v13 claims fuel `B*B+1` suffices, asserting the recursion depth is bounded. But the archived research showed that the number of persistence steps at a given depth is NOT bounded by B — it depends on how many chain steps elapse before the scheduler targets that particular obligation, which can be arbitrarily many.

## What the Fuel Approach Gets Wrong

The fundamental confusion is between two different quantities:

1. **F-nesting depth** (bounded by `closure_F_bound`): How deeply nested the F operators are in a formula. This IS bounded.

2. **Persistence count**: How many chain steps a formula F(psi) can survive without being resolved. This is NOT bounded by F-nesting depth — it depends on the chain construction and scheduling.

Fuel conflates these. The `inl` case tracks depth decrease (quantity 1), but the `inr` case tracks persistence (quantity 2) with the same counter. Since persistence is not bounded by depth, the fuel budget is fundamentally insufficient.

## What the ROADMAP Suggests Instead

The ROADMAP's "Algebraic Perspective" section (line 93) outlines an alternative:

> "The algebraic approach could instead: (1) Take the Lindenbaum algebra L = Formula / equiv, (2) The temporal operators G, H are interior operators on L (proven), (3) Ultrafilters of L correspond to MCSs (proven), (4) Define mcs(t) for each t : D using the algebraic temporal shift..."

This avoids the F-nesting boundary entirely because it works at the algebra level rather than enumerating individual F-obligations.

The ROADMAP also notes the "Separate-Direction Witnesses" approach (line 167) is sorry-free for G/H. The gap is specifically F/P, and the ROADMAP frames this as an open challenge requiring new ideas — not something solvable by tweaking fuel bounds.

## Recommendations

### Do Not Pursue Plan v13 As Written

Phases 1-3 (fuel sufficiency proof) will fail for the same reason they failed in tasks 48 and 67. The mathematical structure hasn't changed.

### Viable Alternatives (from archived research + ROADMAP)

1. **Well-founded recursion on lexicographic measure** (Task 48 Report 08 recommendation): Replace fuel with `Prod.Lex` on `(max_depth - d, chain_position_bound - position)`. This separates the two termination sources properly. However, this was recommended but never fully implemented — it may have its own difficulties.

2. **Algebraic temporal shift** (ROADMAP line 124): The ROADMAP's most forward-looking suggestion. Define the FMCS via algebraic automorphism of the Lindenbaum algebra rather than explicit chain construction. This sidesteps F-obligation enumeration entirely. This is the approach the ROADMAP identifies as the natural one but it requires significant new infrastructure.

3. **Direct construction via `build_targeted_successor`** (sorry-free from task 81 v11): The one-step F-resolution IS sorry-free. The gap is composing it into a full `forward_F`. Research report 12 identified the "safe target lemma" as the key missing piece — proving syntactically that for any DRM with F-obligations, there exists a target choice that doesn't kill other F-obligations. This remains the most direct path but requires a novel proof-theoretic argument.

4. **Restricted completeness**: Prove completeness for a fragment where F-nesting depth is bounded (e.g., formulas where all F-obligations are at depth 1). This gives a partial result that may be publishable while the full case remains open.

### What Should a Revised Plan Address

Any new plan should:
- Treat fuel-based approaches as a **known dead end**, not a fallback
- Build on the sorry-free `build_targeted_successor` infrastructure
- Focus on either the safe target lemma (syntactic) or the algebraic approach (structural)
- Not re-derive results that were already proven and abandoned in tasks 48/67
