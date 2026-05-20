# Research Report: Separation Theorem Remaining Axioms & Cleanup

**Task**: 171 - Eliminate remaining separation axioms and clean up post-157 artifacts
**Date**: 2026-05-20
**Context**: Task 157 eliminated 4 temporal closure axioms from SeparationThm.lean by making the GHR94 Lemmas 10.2.4-10.2.8 hierarchy oracle-free. This report documents everything remaining.

## Current State

**Build**: `lake build` passes (1647 jobs, zero errors).
**Sorry**: Zero in the Separation/ directory.
**Axioms in SeparationThm.lean**: 5 (down from 9 before task 157).

The `is_separable` proof chain is **fully self-contained** — no axioms, no oracles, no sorry. The remaining 5 axioms all concern the stronger `is_properly_separable` predicate or atom preservation.

## Remaining Axioms

### Group A: Proper Separation Temporal Closure (4 axioms)

```lean
axiom all_past_properly_separable (φ : Formula) (h : is_properly_separable φ) :
    is_properly_separable (.all_past φ)

axiom all_future_properly_separable (φ : Formula) (h : is_properly_separable φ) :
    is_properly_separable (.all_future φ)

axiom untl_properly_separable (φ ψ : Formula)
    (h1 : is_properly_separable φ) (h2 : is_properly_separable ψ) :
    is_properly_separable (.untl φ ψ)

axiom snce_properly_separable (φ ψ : Formula)
    (h1 : is_properly_separable φ) (h2 : is_properly_separable ψ) :
    is_properly_separable (.snce φ ψ)
```

**What `is_properly_separable` adds**: Beyond `is_syntactically_separated` (S-args are U-free and vice versa), proper separation adds **semantic purity** — past-part subformulas are semantically "past" (don't depend on future) and future-part subformulas are semantically "future" (don't depend on past). This is needed by Theorem 9.3.1 (the quantifier elimination step in expressiveness).

**Why these aren't eliminated yet**: Task 157's oracle-free hierarchy proves `is_separable` (syntactic separation + equivalence). Proving `is_properly_separable` requires the same hierarchy but tracking the stronger purity predicate through every case. The proof architecture would be identical — strengthen the IH to return `is_properly_separable_with_U_type` and cascade through 10.2.4-10.2.8.

**Approach to eliminate**: Mirror the `is_separable_with_U_type` infrastructure for `is_properly_separable`:
1. Define `is_properly_separable_with_U_type`
2. Prove case outputs (case1_psi, case2_psi) satisfy proper separation + single U-type
3. Strengthen 10.2.4 → 10.2.5 → 10.2.6/10.2.7 for `is_properly_separable`
4. Create `all_formulas_properly_separable` in Hierarchy.lean
5. Replace the 4 axioms with theorems

**Effort estimate**: 6-10 hours. The proof architecture from task 157 provides the template. The main new work is proving proper purity (past/future semantic independence) for each case output. The case outputs are explicit formulas, so this is verifiable by structural inspection.

**Risk**: Low-medium. The `is_properly_separated` predicate may interact differently with box-normalization and the `.box → .imp .bot .bot` trick (which is semantically correct but changes the formula's structural "past/future" classification).

### Group B: Atom Preservation (1 axiom)

```lean
axiom proper_separation_preserves_atoms (φ : Formula) :
    ∃ ψ : Formula, is_properly_separated ψ = true ∧ int_equiv φ ψ ∧
    formula_atoms ψ ⊆ formula_atoms φ
```

**What this says**: The separated equivalent of any formula uses only atoms from the original. No new atomic propositions are introduced by the separation procedure.

**Why this isn't eliminated yet**: Proving atom preservation requires tracking `formula_atoms` through every step of the hierarchy. The case proofs (Cases 1-8) construct explicit formulas from atoms a, q, A, B — so their atoms are subsets of the input's atoms. But the full hierarchy (10.2.4-10.2.8) involves abstraction (replacing U-types with fresh atoms p) and back-substitution. The fresh atoms p must cancel out after substitution, leaving only original atoms.

**Approach to eliminate**: 
1. Prove `formula_atoms (case1_psi a q A B) ⊆ formula_atoms a ∪ formula_atoms q ∪ formula_atoms A ∪ formula_atoms B` (and similarly for case2_psi)
2. Prove `formula_atoms (abstract_untl phi A B p) ⊆ formula_atoms phi ∪ {p}`
3. Prove `formula_atoms (subst_formula psi p (untl A B)) ⊆ (formula_atoms psi \ {p}) ∪ formula_atoms A ∪ formula_atoms B`
4. Chain through the hierarchy: at each abstraction-substitution step, the fresh atom p is introduced and then eliminated
5. Prove the full `all_formulas_separable_preserves_atoms`

**Effort estimate**: 8-12 hours. This is a separate proof track from the separation hierarchy — it's about tracking a set-theoretic property (atom containment) rather than a logical property. Each step is straightforward but there are many steps.

**Risk**: Medium. The `expand_temporal` preprocessing step (which rewrites `all_future`/`all_past` to `untl`/`snce` + negation) may introduce or rearrange atoms. Need to verify that `formula_atoms (expand_temporal phi) = formula_atoms phi`.

## Cleanup Items

### C1: Stale Comments (30 min)

Several comments reference "Phase 6", "will be eliminated", or "axiom-backed" for things that are now theorems:

| File | Line(s) | Issue |
|------|---------|-------|
| Hierarchy.lean | 103 | References `snce_separable` axiom (now a theorem) |
| Hierarchy.lean | 178-179 | "closure axioms (via `all_separable`). In Phase 6..." — Phase 6 is done |
| Hierarchy.lean | 674 | "These used all_separable/snce_separable. Replaced by no_S_nested_sep" — can simplify |
| Hierarchy.lean | 2946-2948 | "Uses `all_separable` as callback. Will be eliminated..." — already eliminated |
| SeparationThm.lean | 15-16 | "consolidated in `Eliminations.lean` as `all_separable`" — now in Hierarchy.lean |
| SeparationThm.lean | 63-82 | Entire comment block about temporal closure axioms — now theorems |
| SeparationThm.lean | 104-117 | Comment about axiom soundness — no longer axioms |
| Eliminations.lean | 787, 893 | References `all_separable` from old architecture |

### C2: Dead Backward-Compat Wrappers (30 min)

| Wrapper | File:Line | Status |
|---------|-----------|--------|
| `no_S_nested_in_U_separable_noax` | Hierarchy.lean:2949 | Now calls `no_S_nested_sep` — can delete or keep for API stability |
| `no_S_nested_in_U_separable_direct` | Hierarchy.lean:3624 | Thin wrapper around `no_S_nested_sep` — same |
| `no_S_nested_in_U_separable_direct_param` | Hierarchy.lean:3570 | Still used by n>=2 path in `all_formulas_separable_aux` — keep |
| `single_U_formula_separable_noax_param` | Hierarchy.lean:~2451 | Old oracle-taking version — used by `lemma_10_2_6_self_contained_param` which is used by n>=2 path — keep |
| `lemma_10_2_6_self_contained_param` | Hierarchy.lean:~2604 | Used by n>=2 path — keep |

Only `no_S_nested_in_U_separable_noax` is clearly dead. The others are still used in the n>=2 path of `all_formulas_separable_aux`, which threads the JD IH as oracle.

### C3: DualEliminations.lean Header Comment (5 min)

The file header says it depends on `all_separable` combined with the duality principle. `all_separable` is now a theorem, not an axiom. Update the comment.

### C4: Plan File Cleanup (10 min)

The plan file `specs/157_.../plans/26_case2-fix-plan.md` has Phase 2 marked `[COMPLETED]` by the agent but still contains stale blocker text from the earlier incorrect assessment. Should be cleaned to reflect final state.

## Priority Ordering

1. **C1-C4 cleanup** (1 hour) — immediate, no risk, improves codebase quality
2. **Group A: proper separation axioms** (6-10 hours) — same architecture as task 157, medium complexity
3. **Group B: atom preservation** (8-12 hours) — separate proof track, higher complexity

## Dependency on Other Tasks

- Group A (proper separation) is **independent** — can be done anytime
- Group B (atom preservation) is **independent** — can be done anytime
- Neither blocks task 155 (Reynolds pipeline) or any other active task
- Task 95 (verification audit) would benefit from these being done first, as it will flag the remaining axioms
