# Findings draft (accumulated during implementation, to be folded into Phase 16 report)

## Phase 5: BX canonical-model completeness vs. cor:tm-completeness tension
`Metalogic/BXCanonical/Completeness.lean` states `completeness_dense` and `completeness_discrete`
(sorry-free) as: validity over densely-ordered/discrete frames implies derivability at BX frame
class `Dense`/`Discrete`. The general `completeness` (Base class) theorem carries `sorryAx`
attributed by the file's own docstring to a deprecated dead-code dependency
(`WeakCanonical.countermodel_discrete`), not to an identified mathematical obstruction.

The paper's `cor:tm-completeness` states TM/TM_f/TM_d/TM_c/TM_dc are sound but none is
*established* as complete: TM (base) is *provably* incomplete via the (DD) two-fibre
countermodel; TM_c fails identically over {Z,R}; TM_f's completeness over the broader discrete
class is explicitly *open* (not refuted); TM_d's status is covered only by the corollary's flat
headline, with no dedicated countermodel given in the paper text I could find.

The relationship between the Lean `completeness_dense`/`completeness_discrete` theorems (BX
proof system, frame-class-parameterized, NOT identical to the paper's TM_d/TM_f) and the paper's
claims is NOT resolved in this book. Two live possibilities, not adjudicated here: (a) BX being
"more fine-grained" than TM could still be affected by the same (DD)-style split-validity
argument at the Base level (unclear whether it generalizes to Dense/Discrete-restricted
subclasses -- (DD) needs both a discrete and dense fibre, so it may simply not apply once
restricted to a single subclass, which would make completeness_dense/completeness_discrete
consistent with the paper); or (b) these Lean results genuinely establish something the paper's
text does not yet claim (TM_d complete over Dense, and by the discrete-class discussion,
something adjacent to but not identical to TM_f's open status, since BX_f-over-Z-time is
explicitly named in the paper as "narrower and deductively stronger than TM + DF").

Marked in the book with `LEAN-ANCHOR-MAY-MOVE: canonical-completeness` at each citation site
(04-metalogic.typ Completeness section x2, 06-notes.typ Completeness Status). Recommend the user
have this reconciled explicitly, ideally as part of or after the completeness_over_total_history_semantics
in-flight work, since it touches exactly the same BXCanonical/Completeness.lean file.

## Phase 5: cor:tm-completeness / cor:tm-decidability / def:TMplus untracked-anchor note
These three anchors are NOT among the 26 tracked in specs/paper-definitions-of-record.md.
Re-verified directly against the live paper (2026-08-13 live tree) for every quote in this task;
matches the task description's section 4/5 verbatim. check-paper-definitions.sh does not protect
this book's completeness/decidability text against future paper drift on these three anchors.
