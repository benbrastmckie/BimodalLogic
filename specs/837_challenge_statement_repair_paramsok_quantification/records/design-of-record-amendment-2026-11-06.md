# Design-of-Record Amendment — Durable Copy

`specs/archive/` is gitignored (`.gitignore:94`), so the three `**Amended by**` paragraphs this
round added to the design of record
(`specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md`, Sections A and
C and the H4 record) are reproduced here verbatim, inside the tracked task directory, so the
amendment survives a fresh clone. The archived file carries all three paragraphs on disk and
remains the amended record; this copy exists for durability only.

The three paragraphs ratify the parameter-hypothesis repair to the two refuted factorization-side
Challenge statements `cellAt_const_of_kappa_eq` and `ladderRealized`. The repair itself was
adopted by task 761's
`specs/761_ladder_realization_theorem/plans/03_ladder-paramsok-parameter-repair.md` revision round;
the ratification record these paragraphs cite is
`specs/837_challenge_statement_repair_paramsok_quantification/records/01_parameter-hypothesis-repair-ratification.md`.

## Section A amendment (as written into the archived file)

**Amended by** `specs/837_challenge_statement_repair_paramsok_quantification/records/01_parameter-hypothesis-repair-ratification.md`,
2026-11-06: the fibre equation `ladderRealized` likewise carries the parameter hypothesis
`(hp : ParamsOk step pend lab phi Tc Tn P B)`, in the same recorded position, and for the same
reason — the unconstrained universal quantification over `(Tc Tn P B : Nat)` makes the equation
FALSE at the all-zero tuple, where `CK 0 0 0 0` is a subsingleton. The four parameters remain
UNIVERSALLY quantified and CONSTRAINED by `ParamsOk`'s conditions (K1)-(K4); they are NOT
existentially quantified, because every downstream consumer — `ladderSound`,
`ladderCons_localRun`, `ladderLift`, and `Dmax` itself, which is indexed by the four parameters —
must instantiate at a tuple the caller chooses, and an existential would assert only that some
tuple works while hiding the parameter conditions this specification names. `paramsOk_params`
discharges the hypothesis at the periodicity fixpoint's own outputs, so the fibre equation is not
vacuous. The statement line this section records is otherwise unchanged: the right-hand side stays
the set-valued datum `{T | ∃ S : ClType φ, typeOfCl S = T ∧ (q, S, κ (c, n)) ∈ Dmax …}` over the
maximum `certAdm`-certified subset. The repair was adopted by task 761's
`specs/761_ladder_realization_theorem/plans/03_ladder-paramsok-parameter-repair.md` revision round
and is RATIFIED, not decided, here, so Statement Fidelity is satisfied.

## Section C amendment (as written into the archived file)

**Amended by** `specs/837_challenge_statement_repair_paramsok_quantification/records/01_parameter-hypothesis-repair-ratification.md`,
2026-11-06: the factorization lemma `cellAt_const_of_kappa_eq` carries the parameter
hypothesis `(hp : ParamsOk step pend lab phi Tc Tn P B)`, in the recorded position immediately
after the parameter binder `(phi : PlusFormula) (Tc Tn P B : Nat)`. Without it the statement is
REFUTED as written: at `Tc = Tn = P = B = 0` the quotient `CK 0 0 0 0` is a subsingleton
(`ck_zero_subsingleton`, by `decide`), so `kappa` identifies every counter pair and the lemma
asserts the cell is constant in `(c, n)` — which `cell_succ_ne` refutes for every `c` and `n` at
fixed next deadline, non-vacuity witnessed on both sides (`separating_pair_nonvacuous`), on the
four-state tag object of the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-unconstrained-parameter-refutation.lean`. The
hypothesis is DISCHARGEABLE — `paramsOk_params`
(`FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean:785`) proves `ParamsOk` at
the periodicity fixpoint's own four outputs `(Tcof, Tnof, Pof, Bof)`, so the lemma is not vacuous
— and LOAD-BEARING: `not_paramsOk_allZero` (`CounterQuotient.lean:868`) records that `ParamsOk`
FAILS at the all-zero tuple the refutation turns on, on that probe's own object. This section's
existing record stands unchanged: the lemma remains a COROLLARY of (S) `ladderSound` and (C')
`ladderLift`, never a hypothesis of either and never an index claim, and `Dmax` — not `K` — is
what factors `cellAt`. The repair was adopted by task 761's
`specs/761_ladder_realization_theorem/plans/03_ladder-paramsok-parameter-repair.md` revision round
and is RATIFIED, not decided, here, so Statement Fidelity is satisfied. The repair's reach is
bounded: `ParamsOk` is NOT the repair for `rk_of_count_drift` and must not be added there
(`specs/761_ladder_realization_theorem/reports/08_rk-bounded-representative-refutation.md`
Finding 4; the instruction is in-source at `CounterQuotient.lean:421`).

## H4 record amendment (as written into the archived file)

**Amended by** `specs/837_challenge_statement_repair_paramsok_quantification/records/01_parameter-hypothesis-repair-ratification.md`,
2026-11-06: against this record's own `STATEMENT` block, both factorization-side signatures
carry the parameter hypothesis `(hp : ParamsOk step pend lab phi Tc Tn P B)` — the factorization
lemma `cellAt_const_of_kappa_eq` and the fibre equation `ladderRealized` — with the four
parameters `(Tc Tn P B : Nat)` universally quantified and constrained by (K1)-(K4) rather than
existentially quantified. The `STATEMENT` block's `HitCl … = ↑(hitOf (truncate B …) … (clNow φ) k)`
form was already WITHDRAWN by this file's Section A amendment of 2026-10-18 and is NOT revived
here: this amendment adds a hypothesis to the fibre-equation form that replaced it, and provides
no substitute index. `ladderSound`, `ladderCons_localRun` and `ladderLift` do NOT carry the
hypothesis — they are not factorization-side statements, so the subsingleton collapse does not
refute them. Neither amended theorem is proved: task 761's Phase 11.7 owns
`cellAt_const_of_kappa_eq` and its Phase 16 owns `ladderRealized`, both `[NOT STARTED]` in
`specs/761_ladder_realization_theorem/plans/11_idle-insertion-cascade-restatement.md`. The repair
was adopted by task 761's
`specs/761_ladder_realization_theorem/plans/03_ladder-paramsok-parameter-repair.md` revision round
and is RATIFIED, not decided, here, so Statement Fidelity is satisfied.
