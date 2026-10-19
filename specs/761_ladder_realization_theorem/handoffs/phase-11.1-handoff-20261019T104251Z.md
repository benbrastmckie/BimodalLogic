# Phase 11.1 Handoff — Half (ii) REFUTED, the Phase Closes [BLOCKED]

- **Dispatch**: seq 19, session `sess_1792395030_22ac66`
- **Plan**: specs/761_ladder_realization_theorem/plans/05_ladder-truth-transport-layer.md
  (the live plan; the pre-write re-read obligation fired and found NO fresh revision —
  `.plan-revised.json` carries `revised_at 1792402682`, earlier than this dispatch's
  `dispatch_start_ts 1792404381`, so Phase 11.1's own section was re-read and is unchanged)
- **Phase 11.1**: `[BLOCKED]`. Phases 11.2, 11.3, 11.4 and 12-18 `[NOT STARTED]` and now gated on
  a route decision.

## Immediate next action

**A route decision, which is the user's or the reviser's and not an implementation dispatch's.**
Half (ii) is not open; it is false. Phases 11.2, 11.3 and 11.4 all consume it as decomposed, so
none of them can be entered as written. The two candidate routes are recorded in the plan's
BLOCKER entry and are repeated below; neither is stated anywhere in the tree and neither is
endorsed here.

## What landed this dispatch

The forty-fifth wired probe,
`specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean` (`Probe761S`), with
19 printed theorems, all on `[propext, Classical.choice, Quot.sound]`. Headline:
`splice_type_invariance_refuted : ¬ SpliceTypeInvariance`, against a schema that writes out half
(ii) with EVERY hypothesis the plan records.

**The mechanism.** One splice DUPLICATES the pumped block, so it ADDS one occurrence of every
object state of that block to the walk's future. A nested eventuality COUNTS occurrences, at
unbounded distance. The object is three states (`0`, `1` pending, `2` idle); the walk is `0` at
every position at or below `0`, `1` at position `1`, `0` at `2` and `3`, `2` from `4` on, with
`cS v = (3 - v).toNat` the countdown `Count` forces — pending on `(-∞, 3]`, idle on `[4, ∞)`, NO
region start at all, and the `p`-state hit EXACTLY ONCE. The splice at `a = 0` with `l = 2` puts a
second hit at position `3`, so `⊤ U (p ∧ ⊤ U p)` is false along the original at every position and
true along the spliced path at every position below `1`.

**Every hypothesis discharged, not sidestepped.** Seriality both ways (`fwdS`, `bwdS`); the
original path through the landed `exists_ladderPath_of_walk` (pin side condition vacuous — no
region start); the spliced path through the landed `exists_spliced_ladderPath_of_pend_past` (the
record's own surgery, not a variant); `2 ∣ P + 1` through `(K1)` on a compiled object `2`-cycle
(`two_mem_objCycleLensS`, `two_dvd_PS_succ`); `ParamsOk` through `paramsOk_params` at the
periodicity fixpoint's own four outputs; `Tc ≤ |a - z|` at `z = -T_c`, arbitrarily far below the
splice point.

**It survives the ITERATED surgery.** `twoHits_of_spliced` creates the second hit,
`twoHits_iterate` shows no further splice at `(0, 2)` destroys it, and `spliced_rehypotheses`
shows the spliced path satisfies the splice hypotheses again at `(0, 2)` — so the
`(P + 1) / l` repetitions `kappa`'s residue coordinate needs keep the separating formula true at
every stage.

**Non-vacuity on both sides.** `exists_separating_splice` carries `PlusFormula.top ∈ tpOf … σ z`
and `PlusFormula.top ∈ tpOf … σ' z` as conjuncts: neither realized type is empty.

Wiring: one `WIRED` row plus its documentation block in `check-evidence-probes.sh`; the
`LadderAgree.lean` module docstring's "NO SPLICE INVARIANCE" bullet upgraded from "not landed" to
"REFUTED, not merely absent" (docstring only — no declaration added, changed or removed); three
generated README inventory blocks and the `typst/generated/status.typ` line count resynced.

## Why the preceding round's intelligence was wrong — and which half of it still stands

The preceding round offered two observations. The SECOND one stands: the splice only ADDS future
positions carrying objects already present, so a pure eventuality (`⊤ U p`) does transport in both
directions by monotonicity. The FIRST one is the error: "a formula of `U`/`S`-nesting depth `d`
distinguishes positions only up to distance `d` from a region's end" is false, because nested `U`
reads an occurrence COUNT and a count is not a local datum. The separating formula has nesting
depth three and distinguishes at every distance. No distance budget can work, and a dispatch spent
looking for one would have been spent on an impossible statement.

## What is refuted, and what is NOT — said sharply so no later round over-reads it

Refuted: that the FIXED surgery `spliceObj`/`spliceCnt`, chosen to preserve ADMISSIBILITY, also
preserves the realized TYPE. It is type-blind.

NOT refuted, and no claim made either way: half (i), which stands on its own ground; the
PRESENTATION (the set-valued datum, the fibre equation over `Dmax`, the factorization lemma as its
corollary); and `cellAt_const_of_kappa_eq` ITSELF — a cell is the set of types realized by ALL
histories through a state, and the probe compares two particular histories, so whether some other
history through the original state realizes the separating formula is not decided. Nothing about
`ladderSound`, `ladderLift` or `ladderRealized`. No bound; every quantity named is a count.

## The two candidate routes, recorded and NOT taken

- **(a) A TYPE-AWARE region lengthening.** Choose the lengthened region's walk so the realized type
  at `z` is preserved, instead of taking the fixed `spliceObj`. The refutation does not touch this,
  and Phase 11's admissibility content would have to be re-established for whatever walk it
  produces. Concretely, on the probe's own object a type-preserving lengthening exists (extend the
  run of `0`s rather than duplicating the block that contains the single `1`) — an observation
  about that fixture, not a landed claim about the general case.
- **(b) Argue at the level of the CELL.** `cellAt_const_of_kappa_eq` names a set over all
  histories, which is strictly weaker than pointwise type equality along a chosen pair of paths,
  and the refutation leaves it entirely open.

No estimate is offered for either, and none is to be invented.

## Verification at closure

- Full guarded `lake build`: exit 0, 2892 jobs, 0 `error:` and 0 `warning:` across both captured
  streams; `.olean` newer than source for the one touched module. Test target
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest`: exit 0, 2361 jobs.
- `check-evidence-probes.sh`: exit 0, 45 of 45 wired probes PASS, no existing probe modified.
  `check-module-invariants.sh`: ALL CHECKS PASSED after `--emit-inventory`.
  `typst-sync-check.sh`: PASS (all 4). `readme-lint.sh`: PASS. `check-task-references.sh`: 0
  unexempted occurrences outside `specs/`.
- `lean-sorry-census.sh`: 0. Vacuous grep 1 and `^axiom ` 14, both unchanged — the only `.lean`
  change under the source roots is a docstring.
- `#print axioms` on all 19 printed probe theorems: `[propext, Classical.choice, Quot.sound]`; no
  `sorryAx`, no custom axiom, no `native_decide`.
- `git diff --stat` on `CounterQuotient.lean`: EMPTY. Certificate-freedom grep on
  `LadderAgree.lean`: zero occurrences; import list unchanged.
- No `sorry`, axiom, vacuous definition, conditional restatement of the refuted claim, positionwise
  narrowing, raised `Tc`, finite-fibre or finite-width retreat, or trace-level `Presented`
  hypothesis anywhere in the tree.

## Deviations

Two on the checklist (both annotated inline on Phase 11.1): half (ii) blocked as REFUTED rather
than unproved, and its pending-forever instantiation not reached and now unreachable. Two process
deviations: the summary is numbered `06` rather than the dispatch's pinned `04` (the live plan is
`05` and this is the second round against it), and the probe plus `LadderAgree.lean` are committed
separately as a declared `file_scope` excursion, as the two preceding rounds did.

---

## Addendum (same dispatch): the blocker research, and STEP 0 settled

The blocker research at `specs/761_ladder_realization_theorem/.blocker-research.json` landed after
this dispatch started and was relayed mid-dispatch. It is CONSISTENT with the refutation, and the
two are complementary rather than competing: the research diagnoses the splice's pumped block as
only an OBJECT cycle, which is not a unit of type-invariance, and the refutation is the compiled
witness that the diagnosis is right and that the resulting statement is false rather than merely
unproved.

One correction of emphasis. The research says the repair claim `truth(g', v) ↔ truth(g, spliceIdx v)`
is false inside the pumped block. That is right, and the refutation says something strictly
stronger: the CONCLUSION of half (ii) itself — equality of the stab-free type at `z` under
`Tc ≤ |a - z|` — is false. So what is closed is not only the proof route through the retraction but
the statement.

### The diagnosis is now compiled, not prose

`Probe761S.splice_block_not_type_respecting` (added this dispatch, bringing the probe to 21 printed
theorems): the refuted block's two endpoints carry the SAME object state and DIFFERENT realized
types — `⊤ U p` holds at the block's entry, the single `p`-hit lying inside the block, and fails at
its exit. So the refutation is confined to the object-cycle splice BY CONSTRUCTION, not by silence,
and it leaves a splice at a TYPE-RESPECTING block entirely open.

### STEP 0: SETTLED AFFIRMATIVELY, with exponential room

Prototype: `specs/761_ladder_realization_theorem/prototype/step0-budget-check.lean`, compiled
standalone through the build guard, four theorems all on `[propext, Classical.choice, Quot.sound]`,
no `sorryAx`. **It is NOT a wired probe and is NOT gate-covered** — the revision should land these
four statements in the library, where the axiom test and the module invariants cover them.

The question the research says to settle first is whether the available countdown is at least
`Fintype.card Q * 2 ^ |plusSubformulaClosure φ|`, the type pigeonhole's budget, given that the plan
forbids strengthening `ParamsOk` to get it. It is, and the reason is an IDENTITY rather than an
estimate:

- `card_prodState : Fintype.card (ProdState Q φ) = Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card`
  — the pigeonhole budget IS the cardinality of the certificate product carrier (`ProdState Q φ` is
  `Q × ClType φ` and `ClType φ` is the powerset of the closure).
- `cascadeBound pend φ = 2 ^ Fintype.card (ProdState Q φ) * (tIdle pend + 2)` carries that budget as
  its own EXPONENT, so `budget_le_cascadeBound` is `n + 1 ≤ 2 ^ n * (tIdle + 2)`.
- `budget_le_Tc` then goes through `(K2)`'s `cascadeBound pend φ ≤ Tc` conjunct ALONE —
  `satThreshold`, `satPeriod`, `prodPre_periodic`, `prodPreStep` and `cohIdle` are not cited, no
  parameter is added, `ParamsOk` is not strengthened and `Tc` is not raised.
- `budget_le_cnt` lands it where the agreement needs it: by the landed `eq_or_both_ge_of_min_eq`,
  a collision of the clipped coordinate gives either `c = c'` (nothing to pump) or both countdowns
  at or above `Tc`, hence both above the budget.

So the route needs no new parameter and the sharper blocker the research warned of does NOT
materialise.

### What STEP 0 does NOT settle

The research's own RISK note: its Step 2 needs the endpoint type equality to propagate to the
block's INTERIOR positions, not only its endpoints. If only the endpoints agree, the fallback is a
pigeonhole for a loop whose interior types also match pairwise, at a LARGER budget. The four facts
above are stated at `card (ProdState Q φ) + 1` and would have to be re-derived at whatever that
larger figure is. The gap between `card (ProdState Q φ)` and `2 ^ card (ProdState Q φ)` is wide,
but no claim is made here about how wide is wide enough — that is the next thing to settle, and it
should be settled before Step 2 is built, for the same reason STEP 0 was.

### The route recommendation, updated

The earlier recommendation in this handoff — argue at the level of the CELL — is superseded. The
research's type-respecting-block route is a concrete construction that respects every prohibition
in plan 05, its one named feasibility risk is now settled affirmatively and compiled, and the
objection the preceding round recorded against it (`objCycleLens` has `l ≤ Fintype.card Q` built
into its definition, so divisibility is closed to a long loop) is answered by iterating the splice
`P + 1` times instead of relying on `l ∣ P + 1`. The cell-level route remains available as a
fallback and is not refuted by anything.
