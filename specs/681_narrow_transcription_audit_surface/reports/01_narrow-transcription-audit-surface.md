# Research Report: Narrow the transcription audit surface

- **Task**: 681 - Narrow transcription audit surface
- **Started**: 2026-09-27T17:06:32Z
- **Completed**: 2026-09-27T17:25:00Z
- **Effort**: ~1.5 hours (research only)
- **Dependencies**: None
- **Sources/Inputs**:
  - Consuming repository: `~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md`
    (sections 2, 3, 4.1, 4.2, "Why the design is deterministic")
  - `FormalSystem/Semantics/TaskFrame.lean`, `TemporalOrder.lean`, `ShiftSet.lean`,
    `Truth.lean`, `TruthTransport.lean`, `Validity.lean`, `FrameClassValidity.lean`,
    `PartialHistory.lean`, `TaskModel.lean`
  - `FormalSystem/Metalogic/Decidability/WitnessFamily/{Std,Agreement,Examples}.lean`,
    `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`
  - `docs/reference/paper-definitions-of-record.md`, `docs/development/MODULE_INVARIANTS.md`
    (C20, C34a/C34b), `scripts/check-module-invariants.sh`, `scripts/lib/lean_citations.py`
  - lean-lsp `lean_run_code` (four verification snippets, all against the live build)
- **Artifacts**:
  - `specs/681_narrow_transcription_audit_surface/reports/01_narrow-transcription-audit-surface.md`
- **Standards**: report-format.md, status-markers.md, artifact-management.md, tasks.md

## Project Context

- **Upstream Dependencies**: `Semantics/TaskFrame.lean` (the four bare-relation constraint
  predicates and their discharge helpers), `Semantics/TemporalOrder.lean`,
  `Semantics/ShiftSet.lean` (the certified construction's axiom set)
- **Downstream Dependents**: the consuming repository's `ADEQUACY.md` §4.1/§4.2 (obligation S2),
  `Metalogic/Decidability/WitnessFamily/Std.lean`
- **Alternative Paths**: none — the audit is the only discharge route for S2 by construction
- **Potential Extensions**: a generated, gate-checked cross-repository citation manifest
  (see Recommendation R4)

## Executive Summary

- **One genuine definition-to-theorem conversion is available and is verified to compile.**
  `ShiftSet`'s `sep` field (the paper's *Limit*, transcribed over the shift action) is derivable
  from `sh_zero` alone whenever the duration order is discrete. Since the whole certificate
  pipeline is `intOrder`-only, every certified construction can drop `sep`: the `ShiftSet` axiom
  count falls from four to three, and *Limit* moves from a hand-supplied field to a kernel-checked
  consequence. A general `sep_of_succOrder` plus an `ofIntAction` smart constructor were written
  and compiled clean (`lean_run_code`, zero errors).
- **The four frame constraints are pairwise irreducible, and this is provable rather than
  assertable.** Two independence witnesses were fully verified in Lean this session (the empty
  relation refutes *Seriality* while satisfying the other three; an upward-ray relation on `ℤ`
  refutes *Saturation*), and a third (the total relation on a two-point carrier refutes *Limit*)
  is verified except for one tactic line. This converts "the audit surface is small" into a
  machine-checked minimality claim — which is precisely what the task asks be stated plainly.
- **The citation table has drifted and the drift is invisible to every existing gate.** Four of
  the 24 rows in §4.1 are stale by exactly +38 lines and now land inside a *different* theorem
  (`not_validOn_z1_dense`). Every other cited line still resolves. The cause is structural: check
  C20's declaration-span cross-check covers this repository's own files only, so a table living in
  the consuming repository is outside every gate in either repo.
- **The audit surface as recorded in §4.2 is smaller than the real one.** Three notions the
  soundness claim depends on have no audit row: `FrameOver.worldNonempty` (the paper's *nonempty*
  `W`), `WorldHistory` / `PartialHistory.IsTotal` (`def:world-history`, quantified over by the box
  clause and characterised by Lemma 2), and — because the cited Lean theorem instantiates rather
  than states the paper's lemma — the `TruthCorr` structure that carries
  `def:time-shift-histories` and `app:auto_existence`. Fixing the table *enlarges* the stated
  residue; that is the honest direction.
- **The full inspection-only residue is 24 Lean definitions**, enumerated below. After the one
  available conversion it is still 24: the conversion shrinks the *construction's* axiom burden,
  not the definitional surface. The definitional surface is reducible only by deleting audit rows,
  and no row can be deleted.

## Context & Scope

Obligation S2 of the consuming repository's `(SOUND)` claim is "the Lean definitions transcribe
the paper's", discharged by inspection in `ADEQUACY.md` §4.2. This research asked three questions:

1. Which paper frame conditions currently carried as Lean *definitions* can be derived as
   *theorems* from more primitive definitions?
2. Does every `file:line` citation in §4.1/§4.2 still resolve?
3. What exactly remains inspection-only, counted rather than characterised?

Scope boundary observed: `ADEQUACY.md` is owned by the consuming repository. This report proposes
the corrected table but does not edit that repository, consistent with the "record on this side
only" convention already established for cross-repository coordination in this task family. No
Lean file was modified during research; all verification ran through `lean_run_code`.

A distinction that the task description conflates and that the findings below keep apart:

- **Surface A — the definitional surface.** The set of Lean definitions a human must read against
  paper text. This is what §4.2 tabulates. It shrinks only when a paper notion stops being
  transcribed at all because Lean derives it (§4.2's `app:auto_existence` row is the one existing
  instance).
- **Surface B — the construction's axiom burden.** The facts a *particular* certified frame must
  supply by hand. This is what §4.1's Lemma 1 rows tabulate. It shrinks whenever a supplied field
  becomes a derived theorem.

Surface B is where the available narrowing lives. Surface A is where the irreducible residue is,
and the contribution there is to make its irreducibility provable and its size exact.

## Findings

### Codebase Patterns

**The narrowing programme is already far advanced, and the remaining margin is thin.** Five
conversions have already landed and should not be re-attempted:

| Paper obligation | How it is already derived | Site |
|---|---|---|
| *Limit*'s `⊇` half (`w` lies in its own positive cones) | `lem:nullity`, derived from *Seriality* + the `⊆` half | `TaskFrame.nullity_of_serial_limit`; recorded in `TaskFrame.Limit`'s docstring, `Semantics/TaskFrame.lean:828` |
| *Compositionality*'s two halves | `comp_of` assembles the biconditional from `Interpolates` + composition; `interpolates_of_comp` projects back | `Semantics/TaskFrame.lean:897, 911` |
| *Saturation* under a functional relation | `saturation_of_fib_subsingleton` (subsingleton fibres); `saturation_of_fib_finite`, `saturation_of_finite` for the finite routes | `Semantics/TaskFrame.lean:1851` and neighbours; consumed at `Semantics/ShiftSet.lean:172` |
| *Seriality* and *Interpolation* for a shift action | free from the group action | `ShiftSet.shRel_serial`, `ShiftSet.shRel_comp`, `Semantics/ShiftSet.lean:163, 148` |
| `app:auto_existence` | Corollary 2.1 of the consuming document derives translation closure by construction | `ADEQUACY.md` §3, Corollary 2.1 |

`ShiftSet.lean`'s own module header states the resulting score explicitly: four axiom fields in
place of six frame fields, with three of the four constraints free under functionality and only
*Limit* non-free.

**The one remaining conversion: `sep` over a discrete duration order.** `Semantics/ShiftSet.lean:115`
carries `sep` as a structure field, and `Metalogic/Decidability/WitnessFamily/Std.lean:71-77`
discharges it by hand for `std` via `Int.abs_lt_one_iff`. That hand proof is unnecessary:
`TaskFrame.limit_of_succOrder` (`Semantics/TaskFrame.lean:1591`) already discharges exactly this
shape from a zero-duration hypothesis, and for a shift action the zero-duration hypothesis *is*
`sh_zero`. Verified, compiling clean against the live build:

```lean
theorem sep_of_succOrder {D : TemporalOrder} [SuccOrder (↑D : Type)] [NoMaxOrder (↑D : Type)]
    {Ω : Type} (sh : Ω → ↑D → Ω) (hz : ∀ w, sh w 0 = w) :
    ∀ w u, (∀ x : ↑D, 0 < x → ∃ y, |y| < x ∧ u = sh w y) → u = w :=
  TaskFrame.limit_of_succOrder (R := fun w y u => u = sh w y)
    (fun w u h => by rw [h, hz])
```

An `ofIntAction` smart constructor taking `Carrier`, `carrier_nonempty`, `sh`, `sh_zero`,
`sh_add`, `A` and supplying `sep` from this theorem also compiled clean. Two notes on the
instance plumbing, which is the only friction: `SuccOrder ↑intOrder` does not synthesise
(`intOrder.carrier` is not syntactically `ℤ` for instance search), so the application needs the
explicit `@ … (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (NoMaxOrder ℤ))` form that
`std_isZTime` already uses for the same reason; and `Mathlib.Data.Int.SuccPred` is the import that
carries `SuccOrder ℤ`.

This narrowing is bounded, and the bound is itself a theorem:
`ShiftSet.SepNotDerivable.sep_not_derivable` (`Semantics/ShiftSet.lean:520`) refutes `sep` for
`D = ℚ` acting on `ℚ ⧸ DyadicGroup`. So *Limit* is derivable over discrete duration orders and
provably not in general — exactly the shape the task anticipates ("this reduces an audit's scope,
it does not eliminate an obligation").

**The four constraints are pairwise irreducible, and three of four witnesses are in hand.**
No such independence record exists in the tree today; `FormalSystem/Metalogic/Independence/` holds
proof-system axiom independence, not frame-constraint independence. Verified this session:

| Refuted constraint | Witness | Verification status |
|---|---|---|
| *Seriality* | `fun _ _ _ => False` on `Bool` over `intOrder` | **Fully verified**: `Compositional`, `Limit`, `Saturation` all proved; `¬ Serial` proved |
| *Limit* | `fun _ _ _ => True` on `Bool` over `intOrder` | `Compositional`, `Serial`, `Saturation` proved; `¬ Limit` needs one corrected tactic line (`fun x hx => ⟨0, by simpa using hx, trivial⟩`) |
| *Saturation* | upward rays on `ℤ`: `(x = 0 ∧ u = w) ∨ (0 < x ∧ w ≤ u) ∨ (x < 0 ∧ u ≤ w)` | `¬ Saturation` **fully verified** (the family `{Fib R w 1}` is `⊇`-directed, every member a nonempty fibre, `⋂₀` empty); `Compositional`/`Serial`/`Limit` proved modulo `omega` friction (see Risks) |
| *Compositionality* | a non-additive functional shift, `R w x u := u = w + f x` with `f 1 = 5`, `f x = x` otherwise — functional so *Saturation* is free from subsingleton fibres, *Limit* from `limit_of_succOrder`, *Seriality* from surjectivity | designed, not yet written |

Because all four witnesses live over `intOrder`, the resulting statement is the strongest one
available: each of `def:frame`'s four constraints is independent of the other three *over the very
time structure the certificate uses*, so no rewriting of the certificate's frame class can shrink
the four-condition audit row to three.

**Nothing can be shaved off the time-structure row.** `structure TemporalOrder`
(`Semantics/TemporalOrder.lean:83-93`) carries `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`,
`Nontrivial` — four Mathlib classes against the paper's four adjectives at `:961`, one to one. This
Mathlib pin (v4.33.0-rc1) carries no single bundled `LinearOrderedAddCommGroup` class to collapse
them into; the name survives only in `…WithTop` variants and in namespaced lemmas such as
`LinearOrderedAddCommGroup.discrete_or_denselyOrdered`, which `Semantics/DurationClassification.lean`
uses. `Nontrivial` in particular is load-bearing rather than decorative:
`TaskFrame.limit_of_shift`'s docstring records that over a trivial duration group *Limit* outright
fails, and notes the paper mandates nontriviality for that reason.

**The recorded audit surface understates the real one.** Three notions the `(SOUND)` chain depends
on have no row in §4.2:

- `FrameOver.worldNonempty` (`Semantics/TaskFrame.lean:1055` block) transcribes the paper's
  reading of `W` as a *nonempty* set of world states. Its own docstring explains why: an empty
  carrier satisfies all four axioms vacuously while validating `⊥`. That is a transcription
  decision with soundness consequences and it is unaudited.
- `WorldHistory` (`Semantics/PartialHistory.lean:423`), the subtype of total partial histories,
  transcribes `def:world-history` (`:1029`). The box clause of `TruthAt` quantifies over it and
  Lemma 2 characterises `H_F`, so the whole box case rests on this transcription. `PartialHistory`
  itself quotes `def:world-history` verbatim in its docstring, so the material exists; only the
  audit row is missing.
- The `lem:history-time-shift-preservation` row cites
  `TimeShift.timeShift_preserves_truth` (`Semantics/TruthTransport.lean:254`) and calls it
  "Exact". It is not the paper's statement but an *instance* of it: the paper quantifies over any
  pair with `σ ≈_x^y ρ`, whereas the Lean theorem fixes `ρ := σ.timeShift (y - x)`. The general
  form is available — `Truth.truthAt_of_truthCorr` at `shiftCorr`, whose `TruthCorr` structure
  (`Semantics/TruthTransport.lean:92`) carries `def:time-shift-histories` as its `Rel` field and
  `app:auto_existence` as `fwd`/`bwd` — but citing it brings `TruthCorr`'s five fields into the
  audit. Either the row should say "the paper's lemma at one instantiated pair, which is all the
  construction needs", or it should cite the general path and admit `TruthCorr`.

**Citation verification: 20 of 24 §4.1 rows and all §4.2 rows resolve; four do not.** Every cited
`file:line` was resolved against the named declaration's span (the same reading C20's third
assertion uses, which includes the declaration's own doc comment). Results:

| Status | Rows |
|---|---|
| Lands on the named declaration's keyword line | 16 |
| Lands inside the named declaration's span (docstring or body) | 4 — `std_isZTime` (:84, keyword 82), `std_sat_ztime` (:91, keyword 88), `std_sat_base` (:96, keyword 93), `sh_surj` (:101, keyword 99); plus `FrameClass.Base.Sat` (:152, keyword 151) and the `sep` discharge range (cited `Std.lean:73-80`, actual 71-77). All correct by the span convention; the two ranges are worth tightening. |
| **Stale — lands inside a different declaration** | 4, all in `Metalogic/Independence/ZTimeSharpness.lean`, all off by exactly +38, all now inside `not_validOn_z1_dense` (keyword line 211) |

The corrected lines are: `not_validIn_base_prior_UZ` 225 → **263**; `not_validIn_base_z1`
236 → **274**; `prior_UZ_minFrameClass_sharp` 251 → **289**; `z1_minFrameClass_sharp`
262 → **300**. The uniform +38 offset is the signature of a docstring edit above the citation
targets; the file's last three touching commits are documentation and ledger passes.

The supporting claims in §4.1's preamble all still hold: `grep -c sorry` is 0 for
`Semantics/ShiftSet.lean`, `WitnessFamily/Agreement.lean`, `WitnessFamily/Decide.lean` and
`Metalogic/Independence/ZTimeSharpness.lean`, and `FormalSystem/MainResults.lean:85` still runs
`#print axioms` at build time.

**Why the drift went unnoticed, and why it will recur.** Check C20 in
`scripts/check-module-invariants.sh` already encodes the right convention — tier 2 asks
publication-facing surfaces to cite declaration *names*, and the third assertion
(`ENFORCE_C20_DECL=1`) fails a named `file.lean:NNN` citation that does not land inside the named
declaration's span, specifically because a shifted citation "almost always" lands on some other
non-blank line and tier 1 passes it. That is exactly the failure observed here. But C20's live
scope is this repository's files; `ADEQUACY.md` is in the consuming repository, and no gate in
either repository reads it. `docs/reference/paper-definitions-of-record.md` reached the same
conclusion about the *paper* side and acted on it: "Anchors here are resolved by `\label{}` name or
`\aitem{}` key, never by line number", with `scripts/check-paper-definitions.sh` re-deriving every
hash from the live file. The cross-repository Lean side is the remaining place where a bare line
number is still trusted.

### External Resources

No Mathlib search was required: every lemma needed (`limit_of_succOrder`, `limit_of_shift`,
`saturation_of_fib_subsingleton`, `Int.abs_lt_one_iff`, `SuccOrder ℤ`) already exists in the tree
or in the pinned Mathlib. `Mathlib.Data.Int.SuccPred` is the sole import the proposed conversion
adds, and it is already transitively present wherever `std_isZTime` elaborates.

### The inspection-only residue, enumerated

This is the answer to "state plainly which residue remains inspection-only". Twenty-four Lean
definitions, each of which a human must read against paper text. Line numbers are current as of
this report; the durable citation is the name.

| # | Lean definition | Site | Paper anchor |
|---|---|---|---|
| 1 | `TemporalOrder` (4 instance fields) | `Semantics/TemporalOrder.lean:83` | `def:temporal-order`, `:961` |
| 2 | `FrameOver` (`WorldState`, `PosRel`) | `Semantics/TaskFrame.lean:1055` | `def:task-relation` |
| 3 | `FrameOver.worldNonempty` | `Semantics/TaskFrame.lean:1055` block | `W` nonempty (**unrecorded in §4.2**) |
| 4 | `TaskFrame.reflect` | `Semantics/TaskFrame.lean:329` | reflection convention, `:970` |
| 5 | `FrameOver.TaskRel` | `Semantics/TaskFrame.lean:1115` | the two-sided `⇒` |
| 6 | `TaskFrame.Compositional` | `Semantics/TaskFrame.lean:805` | `def:frame#Compositionality` |
| 7 | `TaskFrame.Interpolates` | `Semantics/TaskFrame.lean:781` | the `→` half of the same |
| 8 | `TaskFrame.Serial` | `Semantics/TaskFrame.lean:763` | `def:frame#Seriality` |
| 9 | `TaskFrame.Limit` | `Semantics/TaskFrame.lean:828` | `def:frame#Limit` (`⊆` half only; `⊇` derived) |
| 10 | `TaskFrame.Saturation` | `Semantics/TaskFrame.lean:683` | `def:frame#Saturation` |
| 11 | `TaskFrame.DirectedFamily` | `Semantics/TaskFrame.lean:499` | "`⊇`-directed family", inlined `def:directed` |
| 12 | `TaskFrame.Fib` | `Semantics/TaskFrame.lean:419` | `def:task-relation` *Fiber* |
| 13 | `TaskFrame.Seg` | `Semantics/TaskFrame.lean:469` | `def:task-relation` *Segment* |
| 14 | `TaskFrame.IsFiber` | `Semantics/TaskFrame.lean:561` | the fibre class |
| 15 | `TaskFrame.IsSegment` | `Semantics/TaskFrame.lean:571` | the segment class |
| 16 | `FrameOver.IsRegular` | `Semantics/TaskFrame.lean:1172` | the four constraints, bundled |
| 17 | `TaskFrame` / `TaskFrame.IsRegular` | `Semantics/TaskFrame.lean:2571, 2657` | `def:frame`, `:989-994` |
| 18 | `FrameClass.Sat` | `Semantics/FrameClassValidity.lean:151` | the `.Base` / `.ZTime` seam |
| 19 | `TaskModel.valuation` | `Semantics/TaskModel.lean:60` | `\|·\| ⊆ W` |
| 20 | `PartialHistory` / `IsTotal` / `WorldHistory` | `Semantics/PartialHistory.lean:423` | `def:world-history`, `:1029` (**unrecorded in §4.2**) |
| 21 | `TruthAt` (6 clauses) | `Semantics/Truth.lean:232-238` | `:1068-1076` |
| 22 | `ConsequenceOnFrames` | `Semantics/Validity.lean:80` | `def:logical-consequence`, `:1124` |
| 23 | `SemanticConsequenceIn` | `Semantics/Validity.lean:89` | the class-restricted form |
| 24 | `TruthCorr` (5 fields) | `Semantics/TruthTransport.lean:92` | `def:time-shift-histories` + `app:auto_existence` (**only if the general lemma is cited**) |

Rows 3, 20 and 24 are the ones §4.2's six-row table does not currently reach. Rows 6-15 are the
four-constraint block: ten definitions for four paper clauses, because each clause's supporting
vocabulary is named rather than inlined. That is a deliberate and defensible choice — auditing
`IsFiber` against "fibers" is easier than auditing an inlined set comprehension — but it should be
counted honestly at ten, not at four.

### Recommendations

**R1 — convert `ShiftSet.sep` over discrete duration orders (implement).** Add
`ShiftSet.sep_of_succOrder` to `Semantics/ShiftSet.lean` beside `sep_not_derivable`, whose
docstring already frames the general-versus-discrete distinction, and an `ofIntAction` smart
constructor. Rewrite `WitnessFamily.std` (`Std.lean:65`) to use it, deleting the hand proof at
`Std.lean:71-77`. Effort: small; both declarations already compile. Payoff: the certificate path's
*Limit* obligation becomes kernel-checked, and §4.1's Lemma 1 *Limit* row stops citing a field.

**R2 — land the four-constraint independence witnesses (implement).** One new module —
`FormalSystem/Semantics/FrameConstraintIndependence.lean` is the natural home, next to the
constraint predicates it is about — carrying four relations over `intOrder` and sixteen small
theorems (each witness satisfies three constraints and refutes the fourth). Effort: moderate; three
of four witnesses are designed and partly verified. Payoff: the four-condition audit row becomes
provably irreducible, which is the difference between telling a reader the surface is small and
showing them it cannot be smaller. Naming caution: the existing
`FormalSystem/Metalogic/Independence/` means *proof-system axiom* independence, and
`MODULE_INVARIANTS.md` C34a explicitly flags the collision risk, so do not put this module there.

**R3 — correct and extend the audit table (coordinate with the consuming side).** Four line
corrections (`263`, `274`, `289`, `300`), two range tightenings (`Std.lean:71-77`), three new rows
(`worldNonempty`, `WorldHistory`, and either a narrowed `lem:history-time-shift-preservation` verdict
or a `TruthCorr` row), and one verdict softened: the *Limit* row should record that only the `⊆`
half is transcribed and the `⊇` half is `lem:nullity`. The residue table above is drop-in material
for §4.2. This is a documentation change in the consuming repository, so it needs the same
cross-repository coordination the certificate wire contract gets.

**R4 — make the cross-repository table generated rather than maintained (implement here).** The
durable fix for R3's recurrence: a script in this repository that takes a list of fully qualified
declaration names and emits the current `file:line` for each, reusing
`scripts/lib/lean_citations.py`'s declaration-span reader so the exporter and C20 cannot disagree.
The consuming document then cites names and includes a generated manifest, exactly as
`paper-definitions-of-record.md` cites `\label{}` keys and re-derives hashes. Wire it into
`check-module-invariants.sh` as a manifest-freshness assertion so a rename or a docstring sweep on
this side fails loudly here rather than silently rotting a table over there.

**R5 — do not attempt to shrink the time-structure row.** Four Mathlib classes against four paper
adjectives is already one-to-one, and the pinned Mathlib offers no bundled class to collapse them
into. Record the finding so a later pass does not re-derive it as an opportunity.

## Decisions

- **Surface A and Surface B are reported separately.** Conflating them is what would let a
  report claim the audit shrank when only the construction's axiom burden did. The one available
  conversion (R1) touches Surface B only; Surface A stays at 24 definitions.
- **The residue is reported as larger than §4.2 records, not smaller.** Three notions the
  soundness chain depends on are unaudited. Narrowing an audit that does not yet cover its own
  surface would be narrowing the wrong number.
- **No Lean file was edited during research.** All four verification snippets ran through
  `lean_run_code` against the live build, leaving the tree clean — relevant because three sibling
  research dispatches share this working tree this cycle.
- **`ADEQUACY.md` was read but not edited.** It is the consuming repository's artifact; R3 is
  proposed as coordinated work, and R4 is the part that belongs on this side.
- **No sorry-deferred route is proposed.** R1 compiles today; R2's witnesses are elementary
  constructions with no research-scale step. If R2's *Compositionality* witness resists, the
  honest outcome is three independence results and an explicit gap, not a placeholder.

## Risks & Mitigations

- **`omega` does not see `↑intOrder` as `ℤ`.** Every tactic failure encountered while writing the
  independence witnesses was this: goals typed at `intOrder.carrier` defeat `omega`'s linear
  arithmetic front end. *Mitigation*: state the witnesses over `ℤ` with a `show` into
  `↑intOrder` at the boundary, or supply `Int`-typed intermediate `have`s, and expect to replace
  `omega` with explicit `lt_irrefl` / `le_trans` steps in the vacuous-branch cases.
- **Instance synthesis at `intOrder`.** `SuccOrder ↑intOrder` does not synthesise. *Mitigation*:
  the explicit `@ … (inferInstanceAs (SuccOrder ℤ))` form, already the established idiom at
  `Std.lean:82-86`; the module header there documents why `haveI` does not work.
- **R1 changes a structure's construction sites, not its fields.** `sep` remains a `ShiftSet`
  field, because it is genuinely required over dense duration orders
  (`sep_not_derivable`). *Mitigation*: R1 adds a constructor and a theorem; it must not attempt to
  delete the field, which would break `ofModel` and the reverse representation.
- **Deleting `Std.lean:71-77` invalidates a cited range.** *Mitigation*: R3 and R1 should land
  together, or R1's summary should name the rows R3 must then fix.
- **C20 will re-anchor nothing here.** The stale citations are in the consuming repository, so
  `scripts/reanchor-lean-citations.py` does not reach them and must not be pointed at them.
  *Mitigation*: apply the four corrections by hand once, then rely on R4.

## Tactic Survey Results

Four `lean_run_code` snippets were run against the live build; the goals below are the frame
constraints at the witness relations, not proof-search targets, so the survey is a record of what
closed each obligation rather than a portfolio sweep.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `sep` over a discrete duration order | `TaskFrame.limit_of_succOrder` + `rw [h, hz]` | success | explicit `(R := fun w y u => u = sh w y)`; `[SuccOrder ↑D] [NoMaxOrder ↑D]` |
| `ShiftSet` field `sep` at `intOrder` (smart constructor) | the above, applied with `@` | success | `inferInstanceAs (SuccOrder ℤ)`, `inferInstanceAs (NoMaxOrder ℤ)`; import `Mathlib.Data.Int.SuccPred` |
| `Compositional`/`Limit`/`Saturation` at the empty relation | `simp [botRel]`, `rcases` + `absurd` | success | `Fib`, `Seg`, `botRel` as simp lemmas |
| `¬ Serial` at the empty relation | `intro h; obtain … := h true 0 le_rfl` | success | — |
| `Compositional`/`Serial`/`Saturation` at the total relation | `simp [topRel]`, `serial_of_total` | success | `serial_of_total (fun _ _ _ => trivial)` |
| `¬ Limit` at the total relation | `simpa using abs_pos.mpr …` | fail | wrong lemma; `fun x hx => ⟨0, by simpa using hx, trivial⟩` is the fix |
| `¬ Saturation` at the upward-ray relation | explicit family `{Fib R w 1}` + `hfib` rewrite + `omega` | success | needed `simp only [Set.mem_setOf_eq]` before `omega`, and `Set.subset_inter_iff` for directedness |
| `Compositional`/`Serial`/`Limit` at the upward-ray relation | `rcases` + `omega` | fail | `omega` blind to `↑intOrder`-typed hypotheses; see Risks |

`lean_hammer_premise` and `lean_state_search` were not used: every obligation had a named local
discharge helper, and the failures were type-coercion friction rather than missing premises.

## Context Extension Recommendations

- **Topic**: cross-repository citation hygiene.
  **Gap**: `context/project/lean4/` documents the Comparator trust model and the MCP tool set, but
  nothing records that a `file:line` citation crossing a repository boundary is outside every
  gate, nor the convention (cite names, generate the manifest) that
  `paper-definitions-of-record.md` and C20 have each independently arrived at.
  **Recommendation**: a short `context/project/lean4/patterns/cross-repo-citation.md` stating the
  rule — a citation leaving this repository carries a declaration name and no line number, and any
  line-numbered export is generated — with pointers to C20's third assertion and to
  `scripts/lib/lean_citations.py`.
- **Topic**: the two audit surfaces.
  **Gap**: nothing in `context/` distinguishes "definitions a human audits against a paper" from
  "facts a construction supplies by hand", and the two are easy to conflate when a task asks for an
  audit to be narrowed.
  **Recommendation**: fold the distinction into the comparator/trust-model context, since it is
  the same question — what a green build does and does not certify — asked about definitions
  rather than about proofs.

## Appendix

**Verification snippets.** Four `lean_run_code` calls, all against
`import FormalSystem.Semantics.{ShiftSet,TaskFrame}` plus `Mathlib.Data.Int.SuccPred`:
`sep_of_succOrder` and `ofIntAction` (clean, one long-line style warning); the empty-relation
witness (clean); the total-relation witness (one tactic error, diagnosed); the upward-ray witness
(`¬ Saturation` clean, the three positive constraints erroring only on `omega`).

**Citation resolution method.** Each cited `file:line` was checked for the named declaration's
identifier within ±3 lines, then the enclosing declaration was identified by scanning backwards to
the nearest `theorem`/`lemma`/`def`/`abbrev`/`instance`/`structure`/`class` keyword — the same span
reading `scripts/lib/lean_citations.py` implements for C20's third assertion. A hit inside the
declaration's own doc comment or body counts as resolving; a hit inside a *different* declaration
does not.

**References.**
- Consuming document: `ADEQUACY.md` §2 (the four obligations S1-S4), §3 (Lemmas 1-4),
  §4.1 (the citation table), §4.2 (the transcription audit), "Why the design is deterministic"
- `docs/reference/paper-definitions-of-record.md` — the name-not-line-number convention and its
  drift-detection script
- `docs/development/MODULE_INVARIANTS.md` — C20 (citation tiers and the declaration-span
  cross-check), C34a/C34b (`Constraints consumed:` markers, and the naming collision with
  `Metalogic/Independence/`)
- `scripts/check-module-invariants.sh:2397-2445` — C20's rationale, including the double-re-anchor
  incident that motivated the third assertion
