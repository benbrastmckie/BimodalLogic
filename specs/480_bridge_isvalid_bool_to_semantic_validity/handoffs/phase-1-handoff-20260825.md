# Phase 1 Handoff — task 480

**Next action**: Phase 2 — narrow `FormalSystem/Metalogic/Decidability.lean:140-147` open-obligations bullet.

**State**: Eleven declarations landed in `FormalSystem/Metalogic/Decidability/Correctness.lean`
after `decide_sound'` (`sound_of_isValid` plus ten corollaries). `lake build
FormalSystem.Metalogic.Decidability.Correctness` and `lake build
FormalSystem.Metalogic.Decidability` both green. `#print axioms` on all eleven:
`[propext, Classical.choice, Quot.sound]`. No new imports. Only `Correctness.lean` touched.
`grep -n sorry` on the file: two hits, both prose.

**Key decisions**: transcribed the report's verified snippets verbatim, including the targeted
`simp only [isSatisfiable, decide_eq_false_iff_not, not_not] at h` in `not_isSatisfiable_sound`.
Module docstring "Main Theorems" list extended; the "What is still owed" paragraph split into a
"What has since landed" paragraph (sound direction) plus a narrowed completeness-direction
obligation. The `validity_decidable` / `validity_has_decision_procedure` retirement narrative is
unchanged in substance.

**Deviations**: the plan's prose says "ten theorems" while its own Goals list names eleven
declarations. All eleven landed; the count in the plan prose is off by one, the declaration set
is not.
