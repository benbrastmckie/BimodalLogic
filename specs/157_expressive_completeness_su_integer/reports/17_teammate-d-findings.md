# Teammate D (Horizons) Findings: Task 157

**Date**: 2026-05-19
**Artifact**: 17, teammate d
**Focus**: Strategic alignment, downstream impact, and alternative approaches

## Key Findings

### 1. Downstream Dependency Chain Is Critical and Tight

Task 157 (axiom elimination) is the **sole blocker** for:
- **Task 155 Phase 3B** (gap elimination, Reynolds Theorem 14): Uses expressive completeness 6 times (Lemmas 6-13) to convert monadic FO formulas into temporal formulas for Prior-U.
- **Task 155 Phases 4b/6b**: Depend on Phase 3B's `one_class` theorem.
- **Sorry-free `bx_completeness`**: The full completeness theorem is blocked by task 155, which is blocked by task 157.

The `ExpressiveCompleteness.lean` file (GHR94 Theorem 9.3.1) actively uses **two** of the 9 axioms:
1. `proper_separation_preserves_atoms` (SeparationThm.lean:276) — used at lines 1925 and 1998 of ExpressiveCompleteness.lean
2. `proper_separation_theorem_int` — which depends on `all_properly_separable`, which depends on the 4 `is_properly_separable` axioms

**Strategic implication**: Even the "less important" `is_properly_separable` axioms and `proper_separation_preserves_atoms` are on the critical path. The fallback plan of deferring proper separability axioms would NOT unblock task 155. All 9 axioms must be eliminated for a sorry-free completeness.

### 2. The `proper_separation_preserves_atoms` Axiom Is the Hardest

Among the 9 axioms, this one is architecturally distinct:
- The 4 `is_separable` axioms become trivial once `all_formulas_separable` is axiom-free (just `all_formulas_separable _`).
- The 4 `is_properly_separable` axioms require proving `is_separable → is_properly_separable`, which needs showing syntactic separation equals proper separation in the 6-constructor language.
- `proper_separation_preserves_atoms` requires atom-tracking through the entire GHR94 separation procedure. This is NOT done by the current hierarchy proof.

The plan's fallback (Phase 5, Task 5.6) acknowledges this may be the sole remaining axiom. But ExpressiveCompleteness.lean uses it, so it's NOT deferrable.

**Alternative approach**: Instead of threading atom-preservation through the hierarchy proof, consider a separate meta-theorem: "The GHR94 separation procedure preserves atoms because Cases 1-8 only rearrange existing subformulas and introduce fresh atoms that are eliminated by back-substitution." This could be proved by induction on the separation procedure itself (not on the formula), potentially as a wrapper around `all_formulas_separable` that tracks atoms.

### 3. Current Plan Complexity Is Appropriate (Not Over-Engineered)

The 7-phase plan with ~27 hours reflects genuine mathematical complexity:
- GHR94 Lemma 10.2.7 requires `abstract_inner_U` (a non-trivial formula transformation) plus a depth-decrease argument
- The existing codebase uses a callback-based architecture that must be either replaced or shown compatible with axiom-free callbacks
- Multiple interlocking induction measures (junction depth, U-nesting depth, count_U_subformulas) must be threaded correctly

However, the plan could be **simplified** by observing that Phases 6-7 (dead code removal, integration verification) are cleanup that can happen post-axiom-elimination. The critical path is Phases 3-5 only.

### 4. No Existing Formalizations of the Separation Theorem Exist

Web search found:
- **No mechanized proofs** of Kamp's theorem or the GHR94 separation theorem in any proof assistant (Lean, Isabelle, Coq)
- MLTL formalization exists in Isabelle/HOL (formula progression), but that's a different logic
- PAL·S5 formalization in Lean (dynamic epistemic logic), but unrelated to separation
- Rabinovich (2014) provides a simplified proof of Kamp's theorem using separation, but it's for TL(F,P) not TL(U,S), and still paper-only

**This formalization would be the first mechanized proof of the full GHR94 separation theorem.** This is significant for the publication story.

### 5. Modern Treatments Don't Simplify the Core Difficulty

- Hodkinson & Reynolds (2005), "Separation — Past, Present, and Future" is a survey that covers the proof landscape but doesn't simplify the integer case
- Rabinovich (2014) simplifies Kamp's theorem but relies on F/P (not U/S) and uses a different approach
- The integer case (GHR94 Ch 10.2) remains the simplest known treatment for {U,S} separation over Z
- Dedekind-complete time (Ch 10.3) is significantly harder and is correctly excluded from scope

### 6. Lean 4 Patterns That Could Help

The codebase already uses appropriate Lean 4 patterns:
- `Nat.strongRecOn` for strong induction (used in `no_S_nested_in_U_separable_param`)
- Structural induction nested inside strong induction (used in `all_formulas_separable_aux`)
- `termination_by` / `decreasing_by` for custom termination (available if needed for `abstract_inner_U`)

One pattern NOT yet used that could simplify Phase 4:
- **`Nat.strongRecOn` with a product measure**: Instead of separate strong inductions, use `termination_by (U_nesting_depth phi, count_U_subformulas phi)` with lexicographic order. This would let `no_S_nested_in_U_separable_direct` handle the outer U_nesting_depth induction while delegating to `no_S_nested_in_U_separable_param`'s inner count_U_subformulas induction naturally.

### 7. The Blocker Is Not the Plan — It's the `.snce` Case in `single_U_formula_separable`

The handoff identifies the exact problem: line 187 of Hierarchy.lean uses `snce_separable` (axiom). The fix requires making this case axiom-free by:
1. Recognizing that the `.snce` case at single-U depth can be handled by 10.2.4 (Cases 1-8)
2. OR by using the existing `subst_in_separated_separable` with an axiom-free callback

This is a targeted problem with a targeted solution — not an architectural overhaul. The plan's Phase 3 tasks 3.4-3.11 correctly address this by building the axiom-free callback infrastructure.

## Recommended Approach

1. **Prioritize Phases 3-5 aggressively**. Phases 6-7 are optional cleanup. The goal should be axiom-free `all_formulas_separable` + axiom-free `proper_separation_preserves_atoms`.

2. **Address `proper_separation_preserves_atoms` in parallel with Phase 3**, not as a Phase 5 afterthought. This axiom is on the critical path through `ExpressiveCompleteness.lean` → task 155 → sorry-free completeness.

3. **Consider the simpler callback structure first** (plan Tasks 3.4-3.5 before 3.6-3.11). If `lemma_10_2_6_self_contained` works (using `single_U_formula_separable` with the `.snce` case redirected through Cases 1-8), then `abstract_inner_U` handles only the depth ≥ 2 case and may be simpler than feared.

4. **Publication angle**: This would be the first mechanized proof of GHR94 separation. Consider writing up the formalization as a paper after completion, targeting venues like ITP (Interactive Theorem Proving) or CPP (Certified Programs and Proofs).

## Evidence/Examples

- **Dependency chain**: TODO.md Wave 3 shows task 155 depends on 157; roadmap shows task 155 Phase 3B is blocked on task 157's completion
- **ExpressiveCompleteness.lean:1925,1998,2127**: Active use of axioms `proper_separation_preserves_atoms` and `proper_separation_theorem_int`
- **Literature**: No existing formalizations found via web search (searched: "temporal logic separation theorem formalization", "Kamp theorem mechanized proof", "GHR94 separation formalization")
- **Rabinovich 2014**: Simplified Kamp proof exists but uses F/P not U/S, not applicable
- **Hodkinson & Reynolds 2005 survey**: Confirms integer case is the baseline; Dedekind-complete case is harder

## Confidence Level

**Medium-High**

- High confidence on the dependency analysis (direct code tracing)
- High confidence on the "no existing formalization" claim (multiple search strategies)
- Medium confidence on the `proper_separation_preserves_atoms` difficulty assessment (haven't traced the full proof structure needed)
- Medium confidence on the Lean 4 pattern suggestions (the existing patterns work; improvements are marginal)

## References

- [Hodkinson & Reynolds 2005 — "Separation — Past, Present, and Future"](https://www.doc.ic.ac.uk/~imh/papers/sep.pdf)
- [Rabinovich 2014 — "A Proof of Kamp's Theorem"](https://arxiv.org/pdf/1401.2580)
- [Lean 4 Well-Founded Recursion](https://github.com/leanprover-community/leanprover-community.github.io/blob/lean4/templates/extras/well_founded_recursion.md)
- [Lean 4 Induction and Recursion](https://lean-lang.org/theorem_proving_in_lean4/Induction-and-Recursion/)
