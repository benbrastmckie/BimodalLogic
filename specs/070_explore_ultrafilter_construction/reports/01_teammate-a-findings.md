# Teammate A Findings: Task Semantics Alignment

**Task**: 70 - Explore ultrafilter-based construction for temporal coherence
**Date**: 2026-03-30
**Focus**: Task Semantics Alignment — how ultrafilter chains can satisfy the official TaskFrame constraints

## Summary

The official TaskFrame semantics (TaskFrame.lean:93-122) imposes three algebraic constraints: `nullity_identity`, `forward_comp`, and `converse`. An ultrafilter-based construction would use `Ultrafilter LindenbaumAlg` as world states and define `task_rel` via indexed chain membership. The existing `R_G` relation (UltrafilterChain.lean:59-60) is a one-step accessibility relation, not directly a `task_rel`. However, the **correct alignment** is that ultrafilter chains provide the FMCS-level structure — the temporal coherence and world histories — while `task_rel` is defined separately through the CanonicalTask pattern. The key advantage of ultrafilters is negation completeness eliminating the F-persistence problem.

---

## Key Findings

### Task Frame Constraint Analysis

The three TaskFrame axioms from TaskFrame.lean:93-122 are:

**1. `nullity_identity` (line 104)**: `∀ w u, task_rel w 0 u ↔ w = u`

For an ultrafilter-based construction, "zero duration" must mean identity. If we define `task_rel U d V` as "V is reachable from U in d steps along an R_G chain", then:
- `task_rel U 0 V` means V is reachable in 0 steps → V = U
- This naturally satisfies `nullity_identity` since 0-step reachability is identity

**Verdict**: Satisfiable. R_G-chain reachability in 0 steps is the identity relation.

**2. `forward_comp` (line 114)**: `∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v`

If `task_rel U n V` means "V is reachable from U via exactly n forward R_G steps (for n : Nat)", then:
- n-step + m-step reachability = (n+m)-step reachability
- `forward_comp` holds by chain concatenation (same argument as `CanonicalTask_forward_comp` in CanonicalTaskRelation.lean)

**Verdict**: Satisfiable. Ultrafilter R_G chains concatenate for forward direction.

**3. `converse` (line 122)**: `∀ w d u, task_rel w d u ↔ task_rel u (-d) w`

This requires temporal symmetry. For ultrafilter chains over `Int`:
- If U is related to V by d forward R_G steps, then V is related to U by d backward steps
- This requires the R_G relation to have a backward analogue (analogous to R_H/backward_P for MCS chains)
- The existing code has `R_G` for G-accessibility but no explicit `R_H`; however, the converse can be *defined* to hold by the backward construction

**Verdict**: Achievable by defining backward R_H chains as the converse of R_G chains (same pattern as SuccChainFMCS which uses Succ both forward and backward).

**Critical observation**: These constraints are **already satisfied by the CanonicalTask relation** in `CanonicalTaskRelation.lean`, which uses MCS sets (not ultrafilters) as world states. An ultrafilter-based construction would follow the same pattern but with ultrafilters as worlds instead of MCS.

---

### R_G to task_rel Translation

The current `R_G` in UltrafilterChain.lean:59-60 is:
```
R_G(U, V) := ∀ a, G(a) ∈ U → a ∈ V
```

This is a **one-step relation**: V sees everything that U expects to see "next". To translate this to `task_rel`:

**Proposed definition** (parallel to CanonicalTask):
```
ultrafilter_task_rel (U : Ultrafilter LindenbaumAlg) (n : Int) (V : Ultrafilter LindenbaumAlg) : Prop
```
- For n ≥ 0 (Nat n): V is reachable from U by n applications of R_G
- For n < 0 (backward): U is reachable from V by (-n) applications of R_G
- For n = 0: U = V (satisfying nullity_identity)

**Key structural fact**: R_G is reflexive (UltrafilterChain.lean:80-90) and transitive (lines 100-113), so n-step reachability is well-defined.

**Alignment with task_rel requirements**:
| TaskFrame axiom | CanonicalTask pattern | Ultrafilter version |
|-----------------|----------------------|---------------------|
| nullity_identity | CanonicalTask w 0 u ↔ w = u | 0-step R_G = identity |
| forward_comp | Chain concatenation (Nat) | R_G chain concatenation |
| converse | backward chain = negated forward | backward R_G chain = negated forward |

---

### Time Domain Considerations

**Current codebase**: CanonicalTask uses `Int` as the time domain (CanonicalTaskRelation.lean). The FMCS structures also use `D = Int` (FMCSDef.lean).

**For ultrafilter construction**:

**Int (discrete time)** — Natural fit:
- R_G gives one-step forward relation
- n-step R_G chain gives n-step temporal reachability
- Int arithmetic works naturally with forward/backward chains
- Matches existing SuccChainFMCS pattern

**Rat (dense time)** — Problematic:
- R_G is a one-step relation; "1/2 step" has no natural meaning for discrete ultrafilter chains
- Dense time would require a different construction (e.g., ultrafilter-indexed trees)
- Not needed for TM completeness, which works over discrete Int time

**Arbitrary D** — Overly general:
- TaskFrame allows any D with AddCommGroup + LinearOrder
- Ultrafilter chains naturally index over Int (countable steps)
- For the completeness proof, Int is the right domain

**Recommendation**: Use `D = Int` for the ultrafilter chain construction, matching the existing CanonicalTask/SuccChainFMCS infrastructure.

---

### Negation Completeness Advantage

**The F-persistence problem** (from task 69 research): When building an MCS chain using the SuccChain approach, the seed for each successor must be consistent. The core failure was `f_preserving_seed_consistent` (proven FALSE in 17_team-research.md): including all `F_unresolved_theory M` in the seed leads to inconsistency because some F-formulas require satisfaction BEFORE the current world, not after.

**How ultrafilters eliminate this**:

Ultrafilters have full negation completeness by definition: for any element `a`, exactly one of `a` or `aᶜ` is in the ultrafilter. This is leveraged in `R_Box_euclidean` (UltrafilterChain.lean:144-207) and `box_class_witness_consistent`.

For temporal coherence specifically:
- **MCS approach**: To satisfy `F(phi) ∈ M`, we must extend a seed containing `{phi}` to an MCS. But the seed may be inconsistent due to conflicting F-formulas.
- **Ultrafilter approach**: An ultrafilter `U` already contains exactly one of `F(phi)` or `neg(F(phi))` for every formula phi. There's no "seed extension" step — ultrafilters are *already* maximally consistent by definition.

**Concretely**:
- `F(phi) ∈ U` (ultrafilter)
- The successor ultrafilter `V` (with `R_G(U, V)`) automatically satisfies or refutes `phi`
- Because `V` is a complete ultrafilter, `phi ∈ V` or `phi^c ∈ V` — no consistency gap

**What ultrafilter chains DON'T solve directly**: The witness existence problem. Given `F(phi) ∈ U`, we need to show there EXISTS an ultrafilter `V` with `R_G(U, V)` and `phi ∈ V`. This requires the filter extension lemma (Zorn's Lemma / ultrafilter existence), which is the ultrafilter construction's main technical contribution.

---

### Architectural Alignment with Existing Code

The **bundle-level approach** (already proven, from 17_team-research.md lines 108-129) provides temporal coherence for BFMCS by:
1. Using `temporal_theory_witness_exists` to get a witness MCS W with `phi ∈ W`
2. Building a new FMCS family from W via `SuccChainFMCS`
3. The witness is in a **different** FMCS family, avoiding F-persistence

An ultrafilter-based construction would be an *alternative* path that:
1. Uses ultrafilters as world states (instead of MCS)
2. Defines `task_rel` via R_G chain reachability
3. Proves temporal coherence via ultrafilter filter extension (instead of SuccChain)

**Key question**: Does the ultrafilter approach offer anything new over the bundle-level BFMCS approach? The answer is likely **yes** for the modal saturation part: ultrafilter worlds are automatically modally saturated by negation completeness, avoiding the complex ModalSaturation arguments. The bundle-level approach already handles temporal coherence; the ultrafilter approach may simplify modal coherence.

---

## Confidence Level

**High** (8/10) on the following:
- TaskFrame axioms CAN be satisfied by an ultrafilter chain construction using `D = Int`
- `task_rel U d V` via n-step R_G reachability satisfies all three axioms
- Ultrafilters eliminate the seed consistency problem (negation completeness)
- `D = Int` is the right time domain (not Rat or arbitrary D)

**Medium** (6/10) on:
- Whether an ultrafilter construction is *needed* given the bundle-level approach is already proven
- Exact implementation details for the filter extension step

**Lower** (5/10) on:
- Whether the ultrafilter task_rel would satisfy `converse` without additional axiomatic structure (depends on how backward R_H is defined relative to R_G)

---

## Recommendations

**1. For immediate implementation**: The bundle-level BFMCS approach (already sorry-free) is sufficient for completeness. The ultrafilter construction is exploratory for potential simplification.

**2. If pursuing ultrafilter construction**:
   - Define `ultrafilter_task_rel : Ultrafilter LindenbaumAlg → Int → Ultrafilter LindenbaumAlg → Prop` using n-step R_G reachability over `Int`
   - Prove `nullity_identity`: 0-step reachability = identity (trivial from definition)
   - Prove `forward_comp`: chain concatenation (mirror of `CanonicalTask_forward_comp_int`)
   - Prove `converse`: define backward R_H = R_G converse, then use symmetry
   - For temporal coherence: use ultrafilter extension (Zorn's Lemma) to build successor ultrafilters

**3. Leverage existing infrastructure**:
   - `R_G_refl` and `R_G_trans` (already proven) enable n-step chain construction
   - `box_class_witness_consistent` (already proven) gives modal saturation
   - `R_Box_euclidean` (already proven) gives S5 collapse

**4. Key missing piece**: A proof that given `F(phi) ∈ U` (ultrafilter), there exists an ultrafilter `V` with `R_G(U, V)` and `phi ∈ V`. This is the "temporal coherence for ultrafilters" theorem and is the crux of the construction.

**5. Definitional note**: The `UltrafilterChain` type itself (currently not yet defined in UltrafilterChain.lean as a concrete structure) would be an Int-indexed function `Int → Ultrafilter LindenbaumAlg` with consecutive R_G connectivity — essentially an ultrafilter analogue of `FMCS Int`.
