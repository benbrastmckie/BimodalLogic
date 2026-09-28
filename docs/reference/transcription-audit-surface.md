# The Transcription Audit Surface

[Back to Reference Documentation](README.md)

**What this is.** The exact, name-keyed record of what remains **inspection-only** in this
repository's relationship to the source paper: the Lean definitions a human must read against paper
text, because nothing inside the formalism can discharge the claim that they transcribe it
faithfully. A consuming repository's adequacy argument lists that claim among the obligations its
soundness result rests on, and records it as discharged *by inspection*. This page states how large
that inspection is, by counting it and naming every row.

The obligation is irreducible in principle: it spans the boundary between an informal paper and a
formalism, and no theorem inside the formalism can reach across. It can be **narrowed** — where a
paper condition is currently carried as a Lean definition, deriving it as a theorem from more
primitive definitions shrinks the surface to those primitives — and this page records how far that
narrowing has got. It does not claim the obligation is small. It states its size so a reader can
judge.

**Audience**: whoever is writing or reviewing an adequacy argument that rests on these
transcriptions, and needs to know exactly which Lean definitions that argument is asking a human to
check.

**How rows are keyed.** By **declaration name** and paper anchor — never by line number. A
line-numbered table living outside this repository is stale the moment a docstring above one of its
targets grows a line, and that is not hypothetical: see "Corrections the consuming table owes"
below. The line-numbered view exists, but it is **generated**, at
[`../../scripts/lean-citation-manifest.json`](../../scripts/lean-citation-manifest.json), from the
reviewable seed list [`../../scripts/lean-citation-seeds.txt`](../../scripts/lean-citation-seeds.txt)
by [`../../scripts/export-lean-citations.py`](../../scripts/export-lean-citations.py), and check
**C35** in [`../../scripts/check-module-invariants.sh`](../../scripts/check-module-invariants.sh)
fails in *this* repository the moment it goes stale.

**Relation to the ledger.** [`../theorem-index.md`](../theorem-index.md) is the single per-theorem
status ledger and remains the authority on any individual declaration's statement, file and axiom
profile. This page is not a ledger of theorems; it is the record of the **definitions** that no
theorem covers.

## Two surfaces, and why they must not be conflated

Every number below depends on this distinction.

| | **The definitional surface** | **A construction's axiom burden** |
|---|---|---|
| What it counts | Lean **definitions** a human reads against paper text | **Axiom fields** a particular certified construction supplies by hand |
| Who must check it | a human, by inspection | the kernel, once the fields are supplied |
| Shrinks when | a paper condition stops being a definition and becomes a theorem | a construction's field is discharged by a theorem instead of a hand proof |

These move independently, and a change to the second is **not** a narrowing of the first. Stating
that clearly is the whole point of separating them: it is what stops a report claiming that an audit
shrank when only a construction's obligations did.

**What the most recent narrowing pass changed.** `ShiftSet.sep_of_succOrder` derives *Limit*,
transcribed over a shift action, from the zero-shift law alone whenever the duration order is
discrete, and `ShiftSet.ofIntAction` supplies the `sep` field from it. So a certified construction
over `intOrder` now hands over three axiom fields — `carrier_nonempty`, `sh_zero`, `sh_add` — where
it used to hand over four, and the certificate's own `WitnessFamily.std` is built that way: its
*Limit* obligation is kernel-checked rather than hand-proved. That is a change to the **second**
column. The definitional surface is **unchanged**, at 24 rows.

The narrowing is bounded, and the bound is itself a theorem:
`ShiftSet.SepNotDerivable.sep_not_derivable` refutes the same shape for a dense duration order, so
the `sep` field survives and must. Discreteness is the boundary of the derivation, not a convenience
hypothesis a later pass could drop.

## The inspection-only residue

**Twenty-four rows**, naming **twenty-seven** distinct Lean declarations or structure fields. Every
one of the twenty-seven resolves in the tree today; that was verified by name through the generated
manifest, not by reading line numbers. Rows 6-15 are the four-constraint block, discussed under
"What the independence matrix does not do" below.

| # | Declaration or field | Paper anchor | Note |
|---|---|---|---|
| 1 | `FormalSystem.Semantics.TemporalOrder` | `def:temporal-order` | Four Mathlib instance fields against the paper's four adjectives, one to one |
| 2 | `FormalSystem.Semantics.FrameOver` | `def:task-relation` | The `WorldState` and `PosRel` components |
| 3 | `FormalSystem.Semantics.FrameOver`'s `worldNonempty` field, and its frame-level accessor `FormalSystem.Semantics.TaskFrame.worldNonempty` | — (the paper's reading of `W` as a *nonempty* set; **not reached** by the consuming audit) | Its own docstring records why it matters: an empty carrier satisfies all four constraints vacuously while validating falsehood |
| 4 | `FormalSystem.Semantics.TaskFrame.reflect` | `def:task-relation` | The reflection convention: the extension of the primitive positive-cone relation to all durations |
| 5 | `FormalSystem.Semantics.FrameOver.TaskRel` | `def:task-relation` | The two-sided `⇒` |
| 6 | `FormalSystem.Semantics.TaskFrame.Compositional` | `def:frame#Compositionality` | The full biconditional |
| 7 | `FormalSystem.Semantics.TaskFrame.Interpolates` | `def:frame#Compositionality` | The `→` half of the same clause, named separately |
| 8 | `FormalSystem.Semantics.TaskFrame.Serial` | `def:frame#Seriality` | Both conjuncts: an `x`-successor *and* an `x`-predecessor |
| 9 | `FormalSystem.Semantics.TaskFrame.Limit` | `def:frame#Limit` | **Only the `⊆` half of the paper's set equation is transcribed.** The `⊇` half is `lem:nullity`, derived — see the corrections table |
| 10 | `FormalSystem.Semantics.TaskFrame.Saturation` | `def:frame#Saturation` | |
| 11 | `FormalSystem.Semantics.TaskFrame.DirectedFamily` | `def:frame#Saturation` | The paper inlines "`⊇`-directed family"; the Lean transcription names it |
| 12 | `FormalSystem.Semantics.TaskFrame.Fib` | `def:task-relation` | The *Fiber* clause |
| 13 | `FormalSystem.Semantics.TaskFrame.Seg` | `def:task-relation` | The *Segment* clause |
| 14 | `FormalSystem.Semantics.TaskFrame.IsFiber` | `def:frame#Saturation` | The fibre class quantified over by *Saturation* |
| 15 | `FormalSystem.Semantics.TaskFrame.IsSegment` | `def:frame#Saturation` | The segment class, with the `x, y ≥ 0` proviso |
| 16 | `FormalSystem.Semantics.FrameOver.IsRegular` | `def:frame` | The four constraints, bundled as a class rather than carried as fields |
| 17 | `FormalSystem.Semantics.TaskFrame` and `FormalSystem.Semantics.TaskFrame.IsRegular` | `def:frame` | The total space of the frame fibration, so that `⟨W, 𝔇, ⇒⟩` unfolds as the paper writes it |
| 18 | `FormalSystem.ProofSystem.FrameClass.Sat` | — (the formalization's own seam between a proof-side frame-class tag and a semantic meaning) | The only point at which that seam exists |
| 19 | `FormalSystem.Semantics.TaskModel`'s `valuation` field | — (the paper's `‖·‖ ⊆ W`) | |
| 20 | `FormalSystem.Semantics.PartialHistory`, its `FormalSystem.Semantics.PartialHistory.IsTotal` predicate, and `FormalSystem.Semantics.WorldHistory` | `def:world-history` (**not reached** by the consuming audit) | The box clause quantifies over the total ones, so the whole box case rests on this transcription |
| 21 | `FormalSystem.Semantics.TruthAt` | `def:TMplus` | Six clauses, one per `Formula` constructor |
| 22 | `FormalSystem.Semantics.ConsequenceOnFrames` | `def:logical-consequence` | |
| 23 | `FormalSystem.Semantics.SemanticConsequenceIn` | `def:logical-consequence` | The class-restricted form |
| 24 | `FormalSystem.Semantics.TruthCorr` | `def:time-shift-histories` and `app:auto_existence` (**not reached** by the consuming audit) | Five fields. Reachable only if the *general* time-shift lemma is cited rather than the instantiated one — see the corrections table |

### The three rows the consuming audit does not reach

Rows **3**, **20** and **24** have no row in the consuming repository's own transcription table.
Recording them here makes the stated residue **larger**, not smaller. That is the honest direction,
and it is the direction this page takes deliberately: a smaller number obtained by leaving rows out
is not a narrower audit, it is a less accurate one.

- **Row 3**, the nonempty world set, is a transcription decision with soundness consequences. An
  empty carrier satisfies all four frame constraints vacuously while validating falsehood, so the
  claim that the paper reads `W` as nonempty is load-bearing, and it is unaudited.
- **Row 20**, the world-history layer, is quantified over by the box clause of `TruthAt`. The
  material for auditing it already exists — `PartialHistory`'s own docstring quotes
  `def:world-history` verbatim — so only the row is missing.
- **Row 24** is conditional on which time-shift statement is cited; see the corrections table.

## Corrections the consuming table owes

Nothing here edits the consuming repository. Its adequacy argument is read-only input, and these
corrections are recorded on this side so the consuming side can apply them by mechanical lookup
rather than by re-deriving them. Resolve every row against
[`../../scripts/lean-citation-manifest.json`](../../scripts/lean-citation-manifest.json); that file
is generated, and check C35 keeps it current. The seed list now also carries the §4.1 proof-mapping
table's full `ShiftSet.lean` cluster — the rows below, plus the neighbouring declarations those
citations currently land on — so the *next* drift at any of these names fails C35 here rather than
rotting silently over there; seeding does not retroactively repair what the consuming document
currently cites.

| What is wrong | Declarations involved | What to do |
|---|---|---|
| Four citations are **stale** — each landed inside a *different* theorem, `not_validOn_z1_dense`, after a uniform shift caused by a docstring edit above the targets | `FormalSystem.Metalogic.Independence.not_validIn_base_prior_UZ`, `not_validIn_base_z1`, `prior_UZ_minFrameClass_sharp`, `z1_minFrameClass_sharp` | Cite the names; take the locations from the manifest. Every gate in both repositories was green while these were wrong, which is why the manifest and C35 exist |
| One cited **range no longer exists**: the hand separation proof it pointed at has been deleted | `FormalSystem.Metalogic.Decidability.WitnessFamily.std`, now built through `FormalSystem.Semantics.ShiftSet.ofIntAction` | Cite `ShiftSet.ofIntAction` and `ShiftSet.sep_of_succOrder` instead. The row's verdict improves: the obligation is now kernel-checked rather than hand-proved |
| Two cited ranges are **loose** — correct under the span convention (a citation may anchor a declaration's own docstring or body), but wider than the declaration | `FormalSystem.Metalogic.Decidability.WitnessFamily.std_isZTime`, `std_sat_ztime`, `std_sat_base`, `sh_surj`, and `FormalSystem.ProofSystem.FrameClass.Sat` | Cite names; the manifest carries both the keyword line and the full span, so either reading is available without guessing |
| The *Limit* verdict is **too strong**. `TaskFrame.Limit` transcribes only the `⊆` half of the paper's set equation | `FormalSystem.Semantics.TaskFrame.Limit`, with `FormalSystem.Semantics.TaskFrame.nullity_of_serial_limit` for the other half | Soften the row: the `⊇` half — `w` lies in each of its own positive cones — is `lem:nullity`, **derived** choice-free from *Seriality* together with the `⊆` half, not postulated. Carrying it as an axiom would duplicate a theorem |
| The time-shift row cites an **instance** of the paper's lemma, not the lemma | `FormalSystem.Semantics.TimeShift.timeShift_preserves_truth` (the instance) versus `FormalSystem.Semantics.Truth.truthAt_of_truthCorr` at `FormalSystem.Semantics.TimeShift.shiftCorr` (the general form) | Pick one and say which. The instance fixes one pair of histories, which is all the construction needs; the general form quantifies over the paper's relation, and citing it brings `TruthCorr`'s five fields into the audit as row 24 |
| Seven more §4.1 citations, all in the `ShiftSet.lean` proof-mapping table, are **stale the same way as the four above** — each landed inside a *different*, neighbouring declaration, after one uniform shift a single commit caused by inserting a docstring block above them. Older than the +38 drift and invisible until now, because nothing in either repository read these particular citations | `FormalSystem.Semantics.ShiftSet.shRel_comp`, `shRel_serial`, `shRel_saturation`, `fibre_isRegular`, `frame_isRegular`, `forward_repr`, and the *Limit* row's second citation (the `TaskFrame.limit_reflect_of_reflective` usage inside `fibre_isRegular`) — all seven now land inside one of `shRel_reflection`, `shRel_comp`, `shRel_serial`, `fibre` or `ShiftTruth` | Cite the names; take the locations from the manifest. The seed list now also carries `ShiftSet.fibre`, `ShiftSet.frame` and `ShiftSet.ShiftTruth` — the neighbouring declarations these particular citations land on today — so the manifest can name exactly what the old citation actually reaches |
| One further citation in the same Lemma 3/Corollary 3.1 row names the wrong **file**, not merely the wrong declaration: the location currently cited for `Truth.box_const` is where `WitnessFamily.sh_surj` is declared, and `box_const` is not in that file at all | `FormalSystem.Semantics.Truth.box_const`; `FormalSystem.Metalogic.Decidability.WitnessFamily.sh_surj` | Split the row's second citation in two — `box_const` and `sh_surj` each get their own location from the manifest, resolved against their own (different) files |
| Two more cited locations in this cluster are **loose**, same convention as the row above — correct under the span convention, but not on the declaration's keyword line | `FormalSystem.Semantics.ShiftSet#sep` (the field); `FormalSystem.Semantics.ShiftSet.total_eq_orbit` | No correction needed; recorded so the consuming side does not spend effort repairing rows that are already sound |

## Two closed questions

Recorded so a later pass does not re-derive either as an opportunity.

**The time-structure row cannot be shrunk.** `TemporalOrder` carries `AddCommGroup`,
`LinearOrder`, `IsOrderedAddMonoid` and `Nontrivial` — four Mathlib classes against
`def:temporal-order`'s four adjectives, one to one. The pinned Mathlib carries no single bundled
class to collapse them into: the name survives only in `…WithTop` variants and in namespaced
lemmas. `Nontrivial` in particular is load-bearing rather than decorative —
`TaskFrame.limit_of_shift`'s docstring records that over a trivial duration group *Limit* outright
fails, which is why the paper mandates nontriviality.

**The four-clause constraint row cannot be compressed to three.** This is now a theorem:
`FormalSystem.Semantics.FrameConstraintIndependence.constraints_pairwise_independent` exhibits, for
each of *Compositionality*, *Seriality*, *Limit* and *Saturation*, a carrier and a relation over
`ℤ` — reducibly the certificate's own duration type — satisfying the other three and refuting it.
So an audit that tabulates `def:frame`'s constraints against their transcriptions has four rows
there irreducibly, and cannot be told that three would do.

## What the independence matrix does not do

Two limits, both deliberate.

**It bounds a clause count, not a definition count.** `constraints_pairwise_independent` says the
four-clause row cannot become a three-clause row. It says nothing about how many Lean definitions a
reader must inspect. Those are different quantities, and the four clauses of `def:frame` stand on
**ten** definitions here — rows 6-15 above: the two halves of *Compositionality*, *Seriality*,
*Limit*, *Saturation*, and the supporting fibre and segment vocabulary `DirectedFamily`, `Fib`,
`Seg`, `IsFiber`, `IsSegment`. Naming that vocabulary rather than inlining it is a defensible
choice — auditing `IsSegment` against the paper's *Segment* clause is easier than auditing an
inlined set comprehension — but the honest count of the constraint block is **ten**, not four.

**Three of its four rows were already established, at other witnesses.**
`FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` carries a complete independence
matrix and says so in its own header: `voidRel` (character-identical to
`FrameConstraintIndependence.emptyRel`) refutes *Seriality*, `bumpRel` refutes *Compositionality*,
and `SeparatingFrame.srel` refutes *Saturation*, all over `ℤ`-time. What the new module adds is
narrower than a first matrix, and should be cited as exactly that:

1. the first **aggregate** statement — before it, the fact was four scattered groups of theorems
   plus a claim in a module header, and nothing citable;
2. the first *Limit* refutation that holds over **discrete** time — the four-state funnel's carries
   a `[DenselyOrdered ↑D]` binder, so nothing previously refuted *Limit* over the duration order the
   certificate uses;
3. uniformity over one time structure at no import weight, which is what makes the aggregate
   reachable from the `FormalSystem/Semantics.lean` aggregator; the topology-carrying witnesses are
   deliberate leaves and must stay out of it.

The cost is that three of the four rows re-prove, at a different witness, something the tree already
knew — one of them at the identical witness, since the new module's `emptyRel` and
`FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`'s `voidRel` are character-identical.
That is recorded here rather than glossed over, because a reader who took the new module for the
tree's first independence record would be misled about both the module and the earlier work. The
**decision not to consolidate the two matrices** — kept deliberately, because only a topology-free
module is reachable from the `FormalSystem/Semantics.lean` aggregator — is now stated in both module
headers, with both rejected consolidation directions, so neither module reads as an unreviewed
duplicate of the other.

## What this page does not claim

- **It does not re-derive the consuming table's own verdicts.** That document lives in another
  repository and was not read while this page was written. The four stale citations above, and the
  count of how many of that table's cited locations still resolve, come from the research pass that
  measured them; only the *current* locations of the four named declarations were re-derived here,
  through the manifest, and they agree with that measurement. Anyone auditing that table should
  resolve it against the manifest rather than against this paragraph.
- **It does not claim the residue is small.** Twenty-four rows and twenty-seven declarations is the
  measurement; whether that is small is the reader's judgment, which is exactly why the rows are
  listed rather than summarised.
- **It does not claim the obligation can be eliminated.** Narrowing an audit's scope is not
  discharging it. The boundary between an informal paper and a formalism stays where it is.

## Related Documentation

- [`../theorem-index.md`](../theorem-index.md) — the per-theorem ledger; the authority on any
  individual declaration
- [`paper-definitions-of-record.md`](paper-definitions-of-record.md) — the pinned paper-anchor
  manifest every anchor above resolves against, under check C15
- [`state-topology-appendix-support.md`](state-topology-appendix-support.md) — the same
  name-keyed, manuscript-facing treatment for the topology appendix
- [`../development/MODULE_INVARIANTS.md`](../development/MODULE_INVARIANTS.md) — checks C20 and C35,
  the two gates that keep citations honest inside and across repositories

## Tags

transcription-audit · adequacy · def:frame · inspection-only · narrowing

*Last verified: 2026-09-27*
