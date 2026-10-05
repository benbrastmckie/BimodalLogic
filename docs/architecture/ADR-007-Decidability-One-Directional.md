# ADR-007: Decidability Is One-Directional, and Says So

## Status

**Accepted** - 2026-09-07

## Context

`FormalSystem/Metalogic/Decidability/` implements a tableau decision procedure with proof
extraction. Two theorems once stood in `Decidability/Correctness.lean` under names that claimed a
decidability result their proofs did not contain:

- `validity_decidable (φ : Formula) : (⊨ φ) ∨ ¬(⊨ φ)` was proved by `exact Classical.em (⊨ φ)`.
  That is excluded middle for an arbitrary proposition. It holds of any predicate whatsoever and
  says nothing about `⊨`, about tableaux, or about computation: it produces no procedure and no
  `Decidable` instance.
- `validity_has_decision_procedure (φ : Formula) : ∃ decision : Bool, decision = true ↔ ⊨ φ` was
  proved by `by_cases h : (⊨ φ)`, supplying `true` or `false` accordingly. The existential is
  witnessed non-constructively by the truth value one is trying to compute — `Classical.em` again
  with a `Bool` wrapped around it. It is not the statement that `isValid`
  (`Decidability/DecisionProcedure.lean`) *is* that `decision`, which is the content one would
  want.

Both were retired. The risk this ADR exists to prevent is the restatement of that claim in prose:
a reader who is told "decidability is proven" on a README has been told the same false thing the
retired names said, with no proof term to check.

## Decision

**Describe the status one-directionally, everywhere, and never write an `isValid`-shaped
biconditional before it can be proved.**

- **Landed.** The *sound* direction of the `isValid`-shaped statement:
  `sound_of_isValid` and its corollary `isValid_sound` give `isValid φ fc = true → ⊨ φ`,
  sorry-free, with the `isTautology` / `isContradiction` / `isSatisfiable` siblings and the
  frame-class-relativized forms. `decide_sound` is the corresponding corollary at the empty
  context. That direction rides entirely on the `⊢ φ` witness carried by
  `DecisionResult.valid`; it needs nothing from the tableau side.
  `ruleSound_of_mem_allRulesForFC` (`Decidability/Verified/Decidable.lean`) is the rule half of
  the `allClosed → valid` direction: all 34 rules `allRulesForFC` can schedule at a frame class
  preserve satisfiability under that class's carrier property, sorry-free.
- **Open.** The *completeness* direction `⊨ φ → isValid φ fc = true`, and hence
  `valid_iff_allClosed`, the biconditional, and the four `Decidable (⊨ φ)` instances. It requires
  the fuel/termination side and the truth-lemma gate on top of the rule half, and must account for
  the two rules scheduled outside `allRulesForFC` (`serialityRule` and `timeLinearity`, stages 2
  and 3 of `expandOnce`).
- **Partial.** Proof extraction (`Decidability/ProofExtraction.lean`).
- **Landed, separately.** A second decidability theorem, unrelated to the `isValid` biconditional
  above: `Decidable (ValidZTime φ)` is machine-checked as
  `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime`, by the presentation-free
  witness-family certificate route rather than the tableau route. It holds only for
  `FrameClass.ZTime`, only for `φ : FormalSystem.Syntax.Formula` (no stability operator), only
  with empty premises (`[]`), and its `Decidable` computes but is not choice-free
  (`[propext, Classical.choice, Quot.sound]`). This is the one decidability theorem proved in
  this tree to date.

## Consequences

- No surface may say "decidability is fully proven". The retirement record itself lives once, in
  `Decidability/Correctness.lean`'s "`validity_decidable` / `validity_has_decision_procedure` —
  Retired as vacuous" section; every other surface carries a pointer to it and the one-directional
  summary above, not a copy of the argument. The Z-time witness-family result above is the one
  decidability theorem that **is** proven; it does not weaken this rule, since it answers a
  different, narrower statement than the `isValid` biconditional this rule governs.
- `docs/theorem-index.md`'s Decidability section carries every landed decidability row, each with
  its machine-pinned axiom set, and no row for the open `isValid`-shaped biconditional direction.
  An index row is a proved statement; an open obligation is not one.
- Adding an `isValid`-shaped `iff` before it is discharged reproduces exactly the defect this
  retirement removed: a true-looking name over a proof that does not reach it.

## Related

- `FormalSystem/Metalogic/Decidability/Correctness.lean` — the retirement record of source
- [`docs/theorem-index.md`](../theorem-index.md) — the Decidability section's landed rows
- [ADR-001](ADR-001-Classical-Logic-Noncomputable.md) — why `Classical.choice` is available at
  all, which is what made the vacuous proofs typecheck
