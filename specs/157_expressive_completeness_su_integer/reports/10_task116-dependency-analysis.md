# Report: How Task 116 Resolves the Task 157 Hierarchy Circularity

**Task**: 157 — Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-18
**Session**: sess_1779144447_32fc24
**Purpose**: Document why task 157 Phase 3 (axiom elimination) now depends on task 116 (redefine G/H/F/P)

## The Circularity (Summary of 9 Research Rounds)

Task 157's Phase 3 requires proving `all_formulas_separable` — the hierarchy theorem from GHR94 Lemmas 10.2.5-10.2.8. This theorem eliminates 9 axioms in SeparationThm.lean. After 7+ implementation attempts spanning 2+ days, the proof remains blocked by a single issue: **callback circularity in the constituent substitution step**.

### Root Cause

`is_syntactically_separated` (Defs.lean:148-149) accepts `all_past` and `all_future` as syntactically separated formulas:

```lean
| .all_past φ => is_U_free φ    -- Allows H(φ) when φ has no U
| .all_future φ => is_S_free φ  -- Allows G(φ) when φ has no S
```

GHR94 Section 10.2 works exclusively in `{S, U, ¬, ∧}` — no `all_past`/`all_future` primitives. Their definition of "syntactically separated" (p. 571): *"a boolean combination of atoms, wffs U(E,F) with E and F built without using S, and wffs S(E,F) with E and F built without using U."*

Because our definition is wider than GHR94's, Cases 1-2 of Lemma 10.2.3 (Eliminations.lean) produce separated witnesses containing `.all_future (¬A)` and `.all_past (¬a)`. These appear at:
- `Eliminations.lean:372` (Case 2_gen): `.all_future (Formula.neg A)` inside S event
- `Eliminations.lean:458, 515` (Cases 3-4): `Formula.neg (.all_past (Formula.neg a))`
- `DedekindZ.lean:1154` (Case 5): `.all_future (Formula.neg A)`
- `DedekindZ.lean:1878` (Case 8): `.all_past (Formula.neg ev)`

### The Circularity Mechanism

The hierarchy theorem's core operation is `subst_in_separated_separable` (Hierarchy.lean:1261): given a separated formula ψ and an atom p, substitute `.untl A B` for p, then prove the result is separable by handling each constituent:

- **`.untl` positions**: args are S-free in ψ. Substituting S-free `.untl A B` preserves S-freeness. Result stays separated.
- **`.snce` positions**: args are U-free in ψ. After substitution, args contain `.untl A B`. Apply the induction hypothesis (count of U-types decreases).
- **`.all_past` positions**: args are U-free in ψ. After substitution, args contain `.untl A B`. To prove `is_separable (.all_past c')`, must expand to `¬S(¬c', ⊤)`. But:
  - Expanding doesn't decrease `count_U_subformulas` (the U-types are preserved)
  - Expanding `all_future` introduces NEW `.untl` nodes, increasing U-type count
  - The expansion can break `no_S_nested_in_U` (the key precondition)
  - Every workaround eventually requires the temporal closure axioms being proved

**Every one of the 7+ failed attempts** followed this pattern: accept the Case 1-2 witnesses as given, try to handle `all_past`/`all_future` in the callback, hit circular dependency.

### Why Simple Fixes Don't Work

1. **Substituting `all_future(¬A)` → `¬U(A, ⊤)` inside `.snce` events**: Makes the `.snce` event not U-free, so the formula isn't separated.
2. **Lexicographic measure `(count_allpast_allfuture, count_U)`**: The outer theorem requires `has_no_allpast_allfuture = true` (count = 0). The callback receives count > 0. The first component goes from 0 to >0 — an INCREASE.
3. **Expanding temporal in the callback**: `expand_temporal(.all_future x)` introduces `.untl` with args that may not be S-free when x contains `.all_past`. Breaks `no_S_nested_in_U`.
4. **Two-predicate approach**: Still requires rewriting Cases 1-2 to produce base-separated witnesses — the same core work.

## How Task 116 Resolves This

Task 116 removes `all_future` (G) and `all_past` (H) as primitive constructors from the `Formula` inductive type. After task 116:

### 1. The Problem Constructors Cease to Exist

`Formula` will no longer have `.all_past` or `.all_future` constructors. The definition `is_syntactically_separated` will have no cases for them — they simply don't exist in the language. This is identical to GHR94's `{S, U, ¬, ∧}` language.

### 2. Cases 1-8 Cannot Produce Non-GHR94 Witnesses

With no `.all_past`/`.all_future` constructors, the elimination cases must produce witnesses using only `{S, U, ¬, ∧, atoms, □}`. The cases will naturally use:
- `¬(.untl A .top)` for what was `G(¬A)` = `all_future(¬A)` — at the BOOLEAN level (separated)
- `.snce a .top` for what was `¬H(¬a)` = `¬all_past(¬a)` (separated)
- GHR94's direct three-disjunct formulas for Cases 2-4

### 3. The Callback Circularity Vanishes

`subst_in_separated_separable` traverses a separated formula by structural induction. With no `.all_past`/`.all_future` constructors in `Formula`, the only temporal cases are `.untl` and `.snce`:

- `.untl` positions: args S-free → substitution preserves S-freeness → stays separated
- `.snce` positions: args U-free → substitution introduces U-types → apply IH (count decreases)

No `.all_past`/`.all_future` cases exist. The callback never receives these. The circularity is structurally impossible.

### 4. The Hierarchy Follows GHR94 Exactly

With the language matching GHR94:
- **10.2.5** (single U-type): S-nesting induction. Base case: U not under S → already separated. Step: apply 10.2.4 to deepest S containing U. No `all_past`/`all_future` cases.
- **10.2.6** (multi U-type): Induction on count of distinct U-types n. Abstract n-1 types to atoms, apply 10.2.5, substitute back into past constituents. Each constituent has n-1 types. No `all_past`/`all_future` in separated form.
- **10.2.7** (no S nested in U): Reduces to 10.2.5-10.2.6 after handling U-nesting.
- **10.2.8** (all formulas): Junction-depth induction. Abstract S from U-args (or vice versa), apply 10.2.7, substitute back. JD strictly decreases. No `all_past`/`all_future` complications.

### 5. Axiom Elimination Becomes Straightforward

Once `all_formulas_separable` is proved:
```lean
theorem snce_separable (φ ψ) (_ : is_separable φ) (_ : is_separable ψ) :
    is_separable (.snce φ ψ) := all_formulas_separable _

-- Similarly for all 9 axioms
```

The `is_properly_separable` bridge and atom preservation follow from the constructive hierarchy.

## Estimated Impact on Task 157

After task 116 completes:

| Phase 3 Component | Before 116 | After 116 |
|-------------------|------------|-----------|
| `.all_past`/`.all_future` in callbacks | BLOCKER (irresolvable circularity) | Non-existent (constructors removed) |
| Cases 1-2 witness refactoring | ~300 LOC of new proofs | Done as part of 116 |
| `has_no_allpast_allfuture` precondition | Required everywhere, hard to maintain | Trivially true (constructors don't exist) |
| `expand_temporal` step | Critical (converts all_past/all_future) | Unnecessary (nothing to expand) |
| Hierarchy proof | ~600 LOC with workarounds | ~400 LOC following GHR94 directly |
| Total Phase 3 effort | 6-8 hours, high risk | 4-6 hours, low risk |

## Task 157 Current State

- **Phases 1-2**: COMPLETED (Cases 6-7 sorry-free, non-circular)
- **Phase 3**: BLOCKED → now depends on task 116
- **Phases 4-5**: Depend on Phase 3
- **Main theorem**: `US_expressively_complete_over_Z` is SORRY-FREE (Reynolds Theorem 5)
- **9 axioms**: Remain in SeparationThm.lean (eliminated after 116 + Phase 3)

## Dependency Chain

```
Task 107 (archive dead code) → Task 116 (remove G/H/F/P primitives) → Task 157 Phase 3 (hierarchy + axiom elimination)
```

Task 155 (Reynolds pipeline) does NOT need axiom-free separability — it only needs the sorry-free main theorem, which is already achieved.
