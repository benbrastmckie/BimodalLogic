# Implementation Summary: Machine-check CO ⊬ Prior-U (Reynolds gap axiom independence)

- **Task**: 419 - Machine-check the CO-does-not-derive-Reynolds independence result
- **Status**: [COMPLETED]
- **Plan**: `specs/419_machine_check_co_reynolds_independence/plans/01_machine-check-co-independence.md`
- **Research**: `specs/419_machine_check_co_reynolds_independence/reports/01_co-not-derives-prior-u.md`
- **Type**: lean4
- **Session**: sess_1786980263_7f034c

## Outcome

The tree's first machine-checked independence result is landed. Two theorems, both sorry-free and
both verified to consume exactly `propext`, `Classical.choice`, `Quot.sound` (no `sorryAx`):

- **S1** `FormalSystem.Metalogic.Independence.co_not_derives_prior_U_gap` —
  `¬ Derivable FrameClass.Dense Γ (priorUGapFormula (Formula.atom a))` for any context `Γ` all of
  whose members are `CO` instances.
- **S2** `FormalSystem.Metalogic.Independence.co_not_derives_prior_U_gap_schema` —
  `¬ Nonempty (CoDerivation (priorUGapFormula (Formula.atom a)))` for a bespoke `CO`-closed
  system: every `Dense`-admissible `Axiom`, every `CO` instance, and closure under modus ponens,
  modal necessitation, temporal necessitation, and `temporal_duality`.

S2 is the unqualified schema-level claim. S1 alone leaves a gap because `DerivationTree`'s three
rule constructors are restricted to the empty context, so `CO` instances supplied as a *context*
can never appear under them; in `CoDerivation` they are axioms, so they sit under every rule.
`temporal_duality` was kept, as the plan's escalation contract required, and is discharged by the
time-reversal mirror lemma rather than dropped.

## What was built

| File | Content |
|---|---|
| `FormalSystem/Metalogic/Independence/ClockFrame.lean` (new) | `ClockState = ℚ ⧸ AddSubgroup.zmultiples (1:ℚ)`, the projection `cmk` and its arithmetic, `clockRel`, `clockFrame : TaskFrame ℚ` with all seven obligations discharged, `clockHistory` and `clockHistory_isTotal` |
| `FormalSystem/Metalogic/Independence/LoopingDuration.lean` (new) | `LoopingDuration`, Lemma A (`states_add_of_looping`), Lemma B (`truthAt_add_period`, `truthAt_add_nsmul`), Lemma C (`allPast_imp_allFuture`, `allFuture_imp_allPast`, `co_true`), and the clock instances |
| `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` (new) | `arcRadius = √2/4` and its irrationality, `OnArc`, `clockModel`, `ArcTime`, the arc characterization, the three membership facts, `priorUGapFormula_false`, S1, the mirror machinery (`cneg`, `clockRel_neg`, `reflect`, `truthAt_mirror`, `truthAt_swapTemporal`), `CoDerivation`, `coDerivation_sound`, S2 |
| `FormalSystem/Metalogic/Independence.lean` (new) | Aggregator plus a prose record of the four-step countermodel method |
| `FormalSystem/Metalogic.lean` | One import line |
| `FormalSystem/ProofSystem/Axioms.lean` | Layer 9 prose corrected (comment-only) |
| `FormalSystem/Theorems/DedekindDerived.lean` | Module docstring and `co_derived` docstring corrected (comment-only) |
| `FormalSystem/Syntax/Formula.lean` | `Formula.co` docstring pointer corrected (comment-only) |

## The countermodel

`D = ℚ`, `W = ℚ ⧸ ℤ`, `w ⇒_x u ⟺ u = w + ⟦x⟧`, valuation "within `√2/4` of `0` on the circle".

Duration `1` is a **looping duration** (`⟦1⟧ = 0`), so `def:world-history`'s task-respect clause
alone forces every total history to be `1`-periodic; truth is therefore `1`-periodic; over the
Archimedean `ℚ` that collapses `H` into `G`, so `Hψ → Gψ` and a fortiori every `CO` instance holds
everywhere. Because `√2/4` is irrational the arc has no rational endpoint, so no witness `s` can
satisfy `U(¬p ∨ K⁺(¬p), p)` at `0`, and `Axiom.prior_U_gap p` is false there.

The quotient's torsion is load bearing: on the un-quotiented line frame the same time shift moves
world states and the argument collapses. The arc's symmetry about `0` is equally load bearing — it
is what makes `w ↦ -w` an automorphism preserving the valuation, which is what `temporal_duality`
needs. Neither should be "simplified".

## Prose corrections

The Layer 9 note in `Axioms.lean` previously asserted a pen-and-paper witness — a ℚ-flow with
isolated `¬φ` points accumulating at an irrational from above, framed as "the classical Stavi
US-vs-FO phenomenon". That witness is **refuted**, not merely unverified: in it,
`ξ := ¬U(¬p,p) ∧ F(U(¬p,p))` defines the cut, so `CO(ξ)` is false. The note now records the
machine-checked result, names the refuted sketch explicitly so it is not re-attempted, and records
that the countermodel must be a fixed model rather than a frame (under `def:frame-validity`'s
all-valuations quantifier, frame-validity of `CO` on a dense flow forces gap-freeness and hence
Prior-U). The "CONSEQUENCE FOR THE PAPER" paragraph is retained, with its opening conditional
changed from "If the sketch is right" to reflect that the result is established.

Three prose sites carried the stale claim, one more than the plan's scope hypothesis of two:
`Axioms.lean` Layer 9, `DedekindDerived.lean` (both its module docstring — which restated the
refuted sketch verbatim — and `co_derived`'s "Direction" paragraph), and a "not claimed" pointer in
`Formula.lean`'s `Formula.co` docstring. All three were corrected. No file under
`Philosophy/Papers/` was edited.

## Verification

- Full `lake build`: green.
- `grep -rn "sorry" FormalSystem/Metalogic/Independence/`: zero matches.
- No new `axiom` declarations anywhere in `FormalSystem/`.
- `lean_verify` on S1 and S2: axioms are exactly `propext`, `Classical.choice`, `Quot.sound`.
- `co_derived` still compiles sorry-free — the converse direction is untouched.
- `\aitem[CO]{TMP-CO}` anchors in `DedekindDerived.lean` and `Formula.lean` are untouched.

### One pre-existing check that does not pass

`bash scripts/check-paper-definitions.sh` **fails**, reporting drift on 19 anchors. This is not
caused by this work and is outside its scope: the script compares
`specs/paper-definitions-of-record.md` against the live working tree of
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, and neither was touched
here. The drift is concurrent paper editing (added footnotes and similar). The anchors this work
cites in prose were checked individually — `def:frame-validity`'s drift is an added footnote about
non-vacuity, leaving the all-valuations quantifier the argument relies on unchanged — so the
corrected prose remains accurate. Re-pinning the record is a separate concern.

## Plan Deviations

- None (implementation followed plan). Three scope hypotheses were confirmed as stated
  (`TaskFrame`'s two data fields and seven obligations; `Formula`'s six constructors;
  `DerivationTree`'s constructor list, all five schema-form rules mirrored). The fourth, Phase 6's
  "exactly two files carry stale prose", resolved to three; per the plan's own instruction the
  third site was corrected rather than left to match the asserted count.

## Follow-ups (deliberately out of scope)

- Refuting `Axiom.prior_S_gap` in the same model via the arc's mirror symmetry, and probing
  `Axiom.sep`. Cheap now that `truthAt_mirror` and `reflect` exist; excluded from this task so it
  could not block completion (research R7).
- A context document recording the independence-via-countermodel recipe. `.claude/**` is a
  disposable deploy artifact, so it belongs in `agent-system/extensions/**` and is a separate task.
  The recipe itself is recorded in `FormalSystem/Metalogic/Independence.lean`'s module docstring in
  the meantime.
- Re-pinning `specs/paper-definitions-of-record.md` against the drifted paper anchors.
