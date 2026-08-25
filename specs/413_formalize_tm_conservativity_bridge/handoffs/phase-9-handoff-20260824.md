# Task 413 — Phase 9 handoff (final)

All nine phases COMPLETED. `lake build` green (2487 jobs). Zero new sorry, zero new axiom.
No continuation work is pending for this task.

## Acceptance gate results
See `specs/413_formalize_tm_conservativity_bridge/summaries/01_tm-conservativity-backward-bridge-summary.md`
for the full table. Headline: all four row corollaries `#print axioms` clean at exactly
`[propext, Classical.choice, Quot.sound]`; `cef_backward` carries no `completeness_*`
dependency, so Route B did not creep in.

## Standing prohibition, now recorded in-tree
`FormalSystem/Metalogic/Conservativity.lean`'s module docstring is the durable record that the
forward direction is refuted (Base, Discrete) / open (Dense, Dedekind) and must not be stated
or `sorry`-ed. `z1_translate` machine-checks the TM+ half of the CEF witness.

## Follow-on work this task deliberately did NOT do
A machine-checked refutation needs three things none of which exist here: a BL-side semantics,
a BL-side soundness theorem, and the two-fibre / Z x_lex Z countermodels. That is separate task
material and would consume the non-Archimedean discrete carrier work (tasks 421/422/425), not
this proof-theoretic bridge.
