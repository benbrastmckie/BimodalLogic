# Implementation Summary: Task #708

- **Task**: 708 - Relay the sliced certificate contract to the model checker
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-02T16:49:35Z
- **Completed**: (pending)
- **Effort**: (pending)
- **Dependencies**: 703 (`completed`, 2026-10-02T08:54:27Z — the landed `PlusSlicedCertificate` tree is the source of truth). Soft: 710 (`researched`; its probe is the citation source for the incompleteness result), 704 (`planned`; gates the entry-219 non-vacuity wording), 712 (`blocked`; if it lands the probe's theorems as library declarations, the cited path moves)
- **Artifacts**: plans/01_relay-sliced-certificate-contract.md, reports/01_relay-sliced-certificate-contract.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md, no-task-references-in-deliverables.md

## Overview

This task relays the sliced-certificate contract change to the paired ModelChecker repository
(`/home/benjamin/Projects/ModelChecker`, read-only from here), entirely by producing ready-to-file
text inside this summary: replacement paragraphs for ModelChecker `specs/TODO.md` entry 200, a
conditional citation amendment for entry 219, amendments to `theory_lib/bimodal/docs/ADEQUACY.md`
(row A3, §7.1(iii-e), a new §6.1 subsection, a new tail-stability item, one sentence for §7.4) and
a rewrite of `TRUST_PIPELINE.md`'s "The stability modal" middle paragraphs, plus the HOA decision
record and a published-vocabulary glossary. Every Lean citation is given by fully qualified
declaration name and was checked against the live tree at write time; every paired-repository
anchor was checked against the live paired tree. The one substantive change since the research
report: the sliced class is now **machine-checked incomplete** for L⁺ (the `NoFiniteWidthModel.lean`
probe), so the never-report-validity discipline is relayed as **permanent** for `⊡`-carrying targets,
not as pending a finite model property.

## Verification Snapshot

Re-run at implementation time, independently of the research report's own snapshot (which was
taken at HEAD `4252ebe92`), per this task's recorded cross-repository drift risk and the task-701
precedent. Every command below was executed against the live trees during Phase 1; the Phase 5
re-check is recorded at the end of this section.

**Timestamp**: 2026-10-02T16:49:35Z. **BimodalLogic HEAD**: `780a4265a`
(`780a4265a481742b0890f6665e3c68d10893da33`, branch `main`). **ModelChecker HEAD**: `3d29069e`
(`3d29069e55cfdc871414fe85cddb3c5573fce9aa`, branch `master`).

**ModelChecker `git status --porcelain`** (recorded verbatim; pre-existing, not touched by this
task):

```
 M specs/events.jsonl
```

**BimodalLogic working tree at Phase 1 start**: uncommitted modifications confined to `specs/`
(`specs/707_*/{.return-meta.json,plans/01_*.md}` — the concurrently dispatched sibling task 707;
`specs/TODO.md`, `specs/state.json`, `specs/events.jsonl`, and this task's own plan heading — the
orchestrator's preflight). Nothing under `FormalSystem/`, `BimodalTools/` or any other source
path was modified before, during or after this task. Two `lean` processes were already running
when this task started; both belong to an unrelated repository
(`~/Projects/Logos/Verification/books/certifier/Certify.lean`), not to this tree, and were left
alone.

### BimodalLogic checks

| Check | Command | Result |
|---|---|---|
| Task 703 status | `jq -r '.active_projects[] \| select(.project_number==703) \| {status,last_updated}' specs/state.json` | `completed`, `2026-10-02T08:54:27Z`. Matches the report. |
| Task 704 status (entry-219 gate) | same, `704` | `planned`, `2026-10-02T16:37:22Z`. Still open; the entry-219 `⊡` non-vacuity sentence below stays conditional. |
| Task 710 status (probe source) | same, `710` | `researched`, `2026-10-02T14:36:23Z`. The probe's library landing (its Recommendation 1 / task 712, `blocked`) has not happened; the probe is cited by path and SHA. |
| Full build before the probe check | `lake build` | `Build completed successfully (2806 jobs).` Run to completion **before** `lake env lean` on the probe, per the stale-`.olean` defect logged in `specs/errors.json` on 2026-10-02. |
| Closing record: no bound on `n` | `grep -n "bound" FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` | Line 263-264: "no slice-width bound, no tail-period bound and no complexity claim is proved anywhere in this subtree, and none should be read into it." Line 259: "The **sliced** finite model property is **OPEN, not refuted**" — this sentence of the closing record is now **superseded by the probe below** (task 710's Recommendation 2 asks for its restatement; not this task's file to edit). |
| `PlusSlicedCertificate` field list | `sed -n '328,349p' .../PlusSlicedCertificate/Basic.lean` | Fields exactly: `n`, `n_pos`, `back`, `mid`, `fwd`, `back_ne`, `fwd_ne`, `bx`, `target`, `targetTime`. `PlusSlice` (line 280): `edge`, `lab`, `lab_sub`. `PlusGraphPath` (line 140): `back`, `mid`, `fwd`, `back_ne`, `fwd_ne`, `label_sub`. The §6.1 envelope below mirrors the data fields and omits the proof fields. |
| `Certifies` conjunct count | `sed -n '565,570p' .../Check.lean` | Nine conjuncts: `BiSerial`, `TailStable`, `BoxLabelFaithful`, `targetTime ∈ winTimes`, `TargetPathPos`, `targetPos targetTime ∈ liveAt targetTime`, `StabFaithful`, `BoxLiveFaithful`, `Target`. |
| `TailStable` shape | `sed -n '841,848p' .../Stable.lean` | Both conjuncts residue-indexed (`∀ r ∈ Finset.range G.NBnat` / `G.NFnat`) and each intersected with its one-directional live set (`∩ G.bwdLiveAt …` / `∩ G.fwdLiveAt …`). `TailStableRaw` (line 734) is the same without the intersections. |
| Embedding theorem statement | `sed -n '1492,1494p' .../EmbedComplete.lean` | `(φ : Formula) (h : ¬ PlusValidZTime (ofFormula φ)) : ∃ G : PlusSlicedCertificate [] [ofFormula φ], G.Certifies`. No bound on `n` or on any segment length appears in the statement. |
| `WitnessFamily.sliced` width | `sed -n '577,580p' .../Embed.lean` | `n := W.lassos.length` — slice width = lasso count, confirming the lasso family as the `i → i` special case. |
| `decodeOptLassos` absent-reads-as-`[]` | `sed -n '386,388p' BimodalTools/CanonicalWire/Cert.lean` | `\| none => .ok []`. Confirmed. |

### BimodalLogic declaration checks (every Lean name the relay cites)

The report's convention of prefixing a short name with its **file** (`Sound.`, `Check.`,
`Complete.`, `FixtureStable.`) does not match the live **namespaces**: every file under
`PlusSlicedCertificate/` opens `namespace FormalSystem.Metalogic.Decidability` then
`namespace PlusSlicedCertificate` (with `namespace Fixture` nested inside for both `Fixture.lean`
and `FixtureStable.lean`), and `EmbedComplete.lean`/`Embed.lean` put the embedding results under
`WitnessFamily`. The relay text below uses the live fully qualified names in this table — the
paired repository's own citation convention is "fully qualified declaration name, never
`file:line`" (its entry 219). The enclosing namespace of each line was computed mechanically
(namespace/end stack walk) and the declaration keyword confirmed by grep.

| Live fully qualified name | Kind | Defining file : line |
|---|---|---|
| `FormalSystem.Metalogic.Decidability.PlusSlice` | `structure` | `PlusSlicedCertificate/Basic.lean:280` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate` | `structure` | `PlusSlicedCertificate/Basic.lean:328` |
| `FormalSystem.Metalogic.Decidability.PlusGraphPath` | `structure` | `PlusSlicedCertificate/Basic.lean:140` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.onePointCertificate` | `def` | `PlusSlicedCertificate/Basic.lean:620` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.TailStable` | `def` | `PlusSlicedCertificate/Stable.lean:841` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.TailStableRaw` | `def` | `PlusSlicedCertificate/Stable.lean:734` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.decidableTailStable` | `instance` | `PlusSlicedCertificate/Stable.lean:849` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.fwdLiveAt` | `def` | `PlusSlicedCertificate/Stable.lean:568` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.bwdLiveAt` | `def` | `PlusSlicedCertificate/Stable.lean:630` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Certifies` | `def` | `PlusSlicedCertificate/Check.lean:565` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.BoxLiveFaithful` | `def` | `PlusSlicedCertificate/Check.lean:514` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.StabFaithful` | `def` | `PlusSlicedCertificate/Check.lean:480` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.plusRefutes_of_certifies` | `theorem` | `PlusSlicedCertificate/Sound.lean:330` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.exists_plusSlicedCertificate_of_tailStable_countermodel` | `theorem` | `PlusSlicedCertificate/Complete.lean:558` |
| `FormalSystem.Metalogic.Decidability.WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` | `theorem` | `PlusSlicedCertificate/EmbedComplete.lean:1492` |
| `FormalSystem.Metalogic.Decidability.WitnessFamily.sliced_tailStable_of_certifies` | `theorem` | `PlusSlicedCertificate/EmbedComplete.lean:1422` |
| `FormalSystem.Metalogic.Decidability.WitnessFamily.sliced` | `def` | `PlusSlicedCertificate/Embed.lean:577` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixture.not_tailStable_cert` | `theorem` | `PlusSlicedCertificate/FixtureStable.lean:357` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixture.not_tailStableRaw` | `theorem` | `PlusSlicedCertificate/FixtureStable.lean:302` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixture.not_mem_L₀_pR` | `theorem` | `PlusSlicedCertificate/FixtureStable.lean:381` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixture.live_not_determined_by_slice` | `theorem` | `PlusSlicedCertificate/Fixture.lean:662` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.mem_HF_iff_slicedPath` | `theorem` | `PlusSlicedCertificate/Frame.lean:160` |
| `FormalSystem.Metalogic.Decidability.WitnessFamily.compressionBound` | `def` | `WitnessFamily/Compression/Extract.lean:311` |
| `BimodalTools.CanonicalWire.decodeOptLassos` | `def` | `BimodalTools/CanonicalWire/Cert.lean:386` |
| `BimodalTools.CanonicalWire.parse_print` | `theorem` | `BimodalTools/CanonicalWire/Cert.lean:668` |
| `BimodalTools.CanonicalWire.print_parse_canonical` | `theorem` | `BimodalTools/CanonicalWire/Cert.lean:688` |

Two name corrections against the report, live name wins: (i) the report's `Fixture.not_tailStable`
is `Fixture.not_tailStableRaw` (the raw-demand refutation, stated for every pre-period `a`, period
multiplier `b ≥ 1` and offset `c`); (ii) the report's `FixtureStable.*` names live under namespace
`PlusSlicedCertificate.Fixture`, the file being `FixtureStable.lean`. A name-collision note the
relay carries: `PlusSlicedCertificate.StabFaithful` (`Check.lean:480`, on sliced certificates) is
distinct from `PlusSharingWitnessFamily.StabFaithful` (`PlusWitnessFamily/Predicates.lean:283`, on
the older sharing families the paired repository's entry 219 header cites).

### BimodalLogic dangling-citation check

| Cited name | Declaration search | Result |
|---|---|---|
| `exists_tailStable_repr` | `grep -rn "exists_tailStable_repr" FormalSystem/ BimodalTools/` | Eight hits, all prose (module docstrings of `PlusSlicedCertificate.lean:146`, `FixtureStable.lean:14,87,291`, `Stable.lean:67,722`, `Fixture.lean:788,796`), every one saying it is false or "not stated anywhere". **No declaration site. Dangling by design, confirmed** — the relay cites it as the refuted re-presentation claim. |

### Probe compile check (the incompleteness result)

| Check | Command | Result |
|---|---|---|
| Compile at HEAD, after the full build | `lake env lean specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean` | **Exit 0.** |
| `#print axioms` output (all five, verbatim) | same | `'Probe710.not_plusValidZTime_neg_Φ' depends on axioms: [propext, Classical.choice, Quot.sound]`; `'Probe710.no_finite_width_sat' …: [propext, Classical.choice, Quot.sound]`; `'Probe710.not_certifies' …: [propext, Classical.choice, Quot.sound]`; `'Probe710.not_sliced_complete' …: [propext, Classical.choice, Quot.sound]`; `'Probe710.not_finite_width_fmp' …: [propext, Classical.choice, Quot.sound]`. No `sorryAx`. |
| `sorry` count | `grep -c sorry …/NoFiniteWidthModel.lean` | `0`. |
| Theorem names present | `grep -cE "^theorem NAME\b"` for each | `not_plusValidZTime_neg_Φ` (line 514), `no_finite_width_sat` (1105), `not_certifies` (1129), `not_sliced_complete` (1154), `not_finite_width_fmp` (1164) — one declaration each. |
| Witness formula | `sed -n '48,62p'` | `Φ := (A'.and C').and D` with `A' = □(p ∨ ⊡Fp ∨ ⊡Pp)`, `C' = □(p → ⊡¬Pp)`, `D = □(⊡Fp → ¬⊡¬Xp)`, `Xp := ⊥ U p`. |
| Statement of `not_sliced_complete` | `sed -n '1154,1157p'` | `¬ ∀ ψ : PlusFormula, ¬ PlusValidZTime ψ → ∃ G : PlusSlicedCertificate [] [ψ], G.Certifies`. |
| Statement of `not_finite_width_fmp` | `sed -n '1164,1172p'` | `¬ ∀ φ, ¬ PlusValidZTime φ → ∃ (W : Type) (_ : Finite W) (_ : Nonempty W) (R …) (fwd …) (bwd …) (M : TaskModel (FrameOver.ofSlicedStep R fwd bwd).toTaskFrame) (τ …) (t : ℤ), ¬ PlusTruthAt M τ t φ` — quantifies over **every** finite-`W` `ofSlicedStep` frame and every model on it, independent of any checker clause (the probe's decision D2). |

### ModelChecker checks (read-only: `jq`, `grep`, `sed`, `awk` only)

| Check | Command | Result |
|---|---|---|
| Entry 200 status | `jq -r '.active_projects[] \| select(.project_number==200) \| {status,last_updated,dependencies}' specs/state.json` | `blocked`, `2026-09-29T11:28:06Z`, `dependencies: [193, 194, 197]` (ModelChecker-local, flagged as a pre-existing mismatch by the entry's own text; left alone below). TODO.md heading at line 641. |
| Entry 219 status | same, `219` | `completed`, `2026-09-29T15:03:54Z`. TODO.md heading at line 145. |
| Entry 200 text to be replaced | `awk` over lines 641-end of entry | Present verbatim: the "Restated blocker" paragraph says 696 is `implementing` and 703 is `not_started` "with dependencies on projects 695 and 696"; the "There is no L-plus compression subtree at all yet" paragraph; the "Status: remains BLOCKED" paragraph; the "Provenance (2026-09-29)" paragraph. **Drift beyond the report**: the entry still carries the *pre-701* text (it also says 696 is `implementing` and cites `not_plusCertifies_stabSnce`), i.e. the task-701 relay has not yet been filed on their side either. The replacement below therefore supersedes both: it is written against the live entry, not against 701's proposed text. |
| Entry 219 / THEORY-LIMITS header | `sed -n '1335,1435p' examples.py` | Banner at line 1335. Limit kinds: "(a) a genuine ZZ-time non-validity this checker correctly reports as a countermodel … (b) a completeness gap in the VERIFIED side's own certificate system -- a schema for which no certificate meeting that system's conditions exists". FACT 2 still cites `PlusSharingWitnessFamily.not_plusCertifies_stabSnce` / `…_premise` and `snce_share_congr` — the three names task 701 found dangling; still unamended on their side. |
| ADEQUACY.md §6.1 | `grep -n "^### 6.1" ADEQUACY.md` | Line 444, "The wire contract"; lasso envelope with keys `target`, `bx`, `lassos`; `canonical_wire_bytes` named as their serializer. |
| ADEQUACY.md rows A0/A1/A1-Γ/A2/A3 | `grep -n "^\| \*\*A" ADEQUACY.md` | Table at lines 631-636 (A0 line 632, A1 633, A1-Γ 634, A2 635, A3 636). A3's status cell: "Live and open, at A1's scope … needs §7.1(iii-a)'s bounded sweep". |
| ADEQUACY.md §7.1(iii-a), (iii-e) | `grep -n "iii-a\|iii-e" ADEQUACY.md` | (iii-a) at line 709 (bounded sweep); (iii-e) at line 729: "the upstream bound is a single `n` over all three segments while the search takes three independent settings". |
| ADEQUACY.md §7.4 | `grep -n "^### 7.4" ADEQUACY.md` | Line 869, "The never-report-validity rule"; grounds (i) and (ii) as the report describes. No §7.5 exists (§7.4 is followed by "## Why ℤ-time only"). |
| TRUST_PIPELINE.md "The stability modal" | `grep -n "stability modal\|four Lean-side\|Lemma 2\|paper-level" TRUST_PIPELINE.md` | Section at line 330; "In this repository" row at line 310 ("See below. Blocked on four Lean-side results."); "re-proving Lemma 2 and redesigning (C3)" at 347; "paper-level only" at 357; "honest ceiling" item 3 at 374. |
| SEARCH_COVERAGE.md §3(b), §4 | `grep -n "^## " SEARCH_COVERAGE.md` | §3 "Three routes compared" line 73 (route (b) the bounded sweep, `mid` fixed); §4 "The decision: route (b)" line 118. |
| SETTINGS.md divisibility caveat | `sed -n '33,39p' SETTINGS.md` | "representable … **if and only if `nb'` divides `nb`** (respectively `nf'` divides `nf`)"; "`mid` is not affected". |
| `certificate.py` `raw.get("lassos", [])` | `grep -n 'raw.get("lassos"' semantic/certificate.py` | Line 563. Absent `lassos` reads as `()` → structural rejection, mirroring `decodeOptLassos`. |
| D8 anchors | `grep -n "D8" docs/ARCHITECTURE.md semantic/core.py semantic/model.py` | `ARCHITECTURE.md:263` "## Never Reporting Validity (D8)"; `core.py:67`; `model.py:27`. |
| Repo-wide zero-hit greps (`--exclude-dir=.git`) | `grep -rIlE … \| wc -l` | `tail.{0,3}stab`: 0; `Hanoi\|\bHOA\b`: 0; `sliced\|time-slice`: 0; `finite.graph`: 0. All four still zero — tail-stability and the sliced class remain new information on their side. |

### Net effect on the deliverable below

Every fact the ready-to-file text asserts was re-checked at write time. Three things moved
relative to the research report: (i) the incompleteness result is now machine-checked (probe
compiles, exit 0, no `sorry`, standard axioms only), which changes point (5) from "until a finite
model property is proved" to **permanent**; (ii) two cited names were corrected to their live
forms (table above); (iii) the paired repository's entry 200 and THEORY-LIMITS header turned out
still to carry their pre-701 text, so the entry-200 replacement below is written against the live
entry and absorbs 701's corrections rather than assuming they were applied.

## ModelChecker entry 200 — ready-to-file replacement paragraphs

ModelChecker entry 200 (`extend_bimodal_to_stability_modal`, live status `blocked`,
`last_updated: 2026-09-29T11:28:06Z`) still carries the text written against BimodalLogic's
September state: it frames the design-authority project 696 as `implementing`, project 703 as
`not_started`, expects "a compression bound" and "the verified side's branching structure" as
things still to come, says "There is no L-plus compression subtree at all yet", and cites two
theorem names (`not_plusCertifies_stabSnce`, `not_plusCertifies_stabSnce_premise`) and one lemma
name (`snce_share_congr`) that have no declaration in the BimodalLogic tree (re-confirmed at HEAD
`780a4265a`; what stands in their place is `not_snce_share_congr` at
`PlusWitnessFamily/Incompleteness.lean:120` and the two landed certifying examples
`plusCertifies_stabSnce_example` / `plusCertifies_stabUntl_example` in
`PlusWitnessFamily/Examples.lean`). The task-701 relay that corrected those citations was never
filed on the ModelChecker side, so the replacement below is written against the **live** entry and
absorbs those corrections rather than assuming them.

**What is kept verbatim** (unchanged, still correct): the "Root cause, in shape form" paragraph;
the "Deeper conflation" paragraph; the "CORRECTION, do not transcribe the temporal-asymmetry
account" paragraph; the "Upstream project 694 … was evaluated and abandoned" paragraph; and the
"Flag (not corrected here …)" paragraph about the entry's own `dependencies` array. **What is
replaced**: the opening scope paragraph; the "four upstream tasks" paragraph; the "until-side gate
family" paragraph; the "Restated blocker" paragraph; the "There is no L-plus compression subtree"
paragraph; the "Status: remains BLOCKED" paragraph; and the "Provenance (2026-09-29)" paragraph.
The block below is the full `description` field, ready to paste over the current one verbatim; the
kept paragraphs are reproduced in place so no splicing is needed. One mechanical change inside
the kept paragraphs: their `file:line` anchors are dropped (the entry's own convention, stated in
entry 219, is fully qualified names, never `file:line`; two of those anchors have already
drifted — `share_refl`/`share_symm` now live in `WitnessFamily/Sharing/Skeleton.lean`, not
`Basic.lean`, and `Thread.step` is no longer at `Skeleton.lean:305`).

```
Extend the bimodal theory to the language with the stability modal. The verified side has now
supplied the branching certificate structure, its histories characterization, its redesigned box
condition, and the SHAPE of the search bound -- and has also proved what that structure cannot
do, which changes this task's blocker from "waiting on upstream" to a permanent limit on one
fragment (see "THE CLASS IS INCOMPLETE" below). The modal is absent from this theory entirely
today: operators.py defines negation, conjunction, disjunction, bottom, Box, Future, Past, Until,
Since and the defined operators, with no stability modal, and ADEQUACY.md states it is out of
scope throughout. Adding it is not an operator definition plus a truth clause. The received
account of why this design is deterministic is explicit that the obstruction is not Limit or
Saturation but the histories characterization and the box case of the truth lemma: determinism
is what makes every world history one of the lasso orbits, so sharing states between lassos lets
a history cross from one lasso to another, breaks that characterization and the corollary that
the frame's history set is exactly the certified histories, and breaks box faithfulness, which is
calibrated against "every position of every lasso" and stops enumerating the history set once
histories recombine. Consequently this task's scope is: add the operator and its truth
conditions; adopt the verified side's TIME-SLICED certificate (below) as the certificate
datatype, as a strict extension of the current lasso family rather than a replacement; re-encode
the conditions for Z3 over that structure -- box faithfulness in particular, which can no longer
be a conjunction over lasso positions and is now stated over computed LIVE positions, and
TAIL-STABILITY, which is a new accept/reject criterion this repository has never had; extend the
wire contract and the re-checker in step, as the strict extension the ADEQUACY.md 6.1 amendment
specifies; and set search bounds as the 4-tuple (n, nb, nm, nf) described below, with NO bound on
the slice width n. Also revisit the iteration machinery: the symmetry group for orbit-distinctness
(rotation per lasso, permutation of witness lassos) is defined for a family of lassos and will
need a different group action on a sliced structure (per-slice state permutations commuting with
the edge matrices).

HISTORY OF THE BLOCKER, CORRECTED. The four upstream tasks originally named as this blocker
(stability_decidability_provenance_gate, state_sharing_witness_structure_and_c3,
agreement_lemma_over_all_walks, stability_compression_and_assembly) completed as a REFUTATION
of the earlier six-condition sharing substrate, not a construction: that substrate's own
congruence lemma collapsed the stability modal, and the refutation is recorded at
FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.not_snce_share_congr with the
genuine integer-time non-validity ...not_plusValidZTime_stabSnce (at Pp -> stab Pp) and its
until-side mirror ...not_plusValidZTime_stabUntl. Two theorem names an earlier draft of this
entry cited for "the certificate class is EMPTY" (not_plusCertifies_stabSnce and its _premise
variant) no longer exist upstream; the redesigned substrate certifies both gate families
(FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusCertifies_stabSnce_example and
...plusCertifies_stabUntl_example, landed theorems in PlusWitnessFamily/Examples.lean, not
archived probes). Do not cite the two
retired names. The design-authority project 696 (stability_modal_substrate_design) is completed,
and so is project 703 (lplus_compression_and_completeness), which is the one this task consumes.

Root cause, in shape form (not temporal form -- see the correction below). Any truth clause of
the form "for all j accessible from i, phi holds at i if and only if <condition mentioning only
j>" is an invariance axiom for phi across the accessibility class, derivable from reflexivity
alone: instantiate the clause once at an arbitrary class member j, and once at j itself via
reflexivity of the class relation, then chain the two biconditionals. The upstream congruence
lemma's entire proof is exactly this chaining, via share_refl. The sharing relation (share) is a
landed equivalence -- share_refl/share_symm/share_trans -- so the invariance runs across the entire share-class, not just a pair.

Deeper conflation: one relation carries two algebraically incompatible jobs. The stability modal
needs an equivalence (same world-state, different history); one-step succession must be neither
symmetric nor transitive. Yet the earlier SharingSkeleton.Thread's step field was defined
directly in terms of share, so succession inherited symmetry and transitivity from share, and
past truth became a function of the present state. The landed redesign separates the two: the
time-sliced certificate carries a per-slice EDGE matrix for succession and treats "same state at
the same time" as the equivalence, with no shared relation between them.

CORRECTION, do not transcribe the temporal-asymmetry account: an earlier account of this blocker
attributed the collapse to the snce clause quantifying its predecessor over the share-class at
the label's own time, while "the untl clause escapes only by quantifying at the successor time."
That account is refuted, machine-checked, at a named lemma: ...plusSnce_thread_step
(PlusWitnessFamily/Fulfil.lean) instantiates the snce clause at k := theta.idx(t-1) using
...plusThread_share_pred, which is Thread.step (t-1) read backwards via share_symm. The snce
clause is therefore already the exact structural mirror of the untl clause relative to
Thread.step; there is no temporal asymmetry, and both clauses collapse for the same reflexivity
reason. The candidate repair of simply re-timing snce to t-1 is independently confirmed closed
and must not be re-proposed.

THE BRANCHING STRUCTURE HAS LANDED: THE TIME-SLICED CERTIFICATE. As of 2026-10-02T08:54:27Z
upstream project 703 is completed, and the object this task was waiting on exists as landed,
sorry-free code under FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/ (24 modules).
The certificate is FormalSystem.Metalogic.Decidability.PlusSlicedCertificate: a slice width n; a
leftward period back, a window mid and a rightward period fwd, each a list of slices
(FormalSystem.Metalogic.Decidability.PlusSlice: an n x n Boolean edge matrix from this slice to
the next, and a state labelling lab from the closure); a box guess bx; a target path target
(FormalSystem.Metalogic.Decidability.PlusGraphPath: three segments of (label, state) pairs); and
a targetTime. It presents a frame on the infinite carrier Z x Fin n with finite fibres. In the
published vocabulary (Hodkinson-Wolter-Zakharyaschev 2000) it is a quasimodel over <Z,<> with
named states: each slice is a state candidate, the slice sequence a state function, the target
path a run. The conditions the checker decides are the nine conjuncts of
FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Certifies: BiSerial, TailStable,
BoxLabelFaithful, targetTime in the window, TargetPathPos, the target position live at the
target time, StabFaithful (the stability clause, both directions), BoxLiveFaithful (the box
clause, over computed live positions -- not over "every position of every lasso"), and Target.
Soundness is ...PlusSlicedCertificate.plusRefutes_of_certifies; relative completeness for
tail-stable countermodels is
...PlusSlicedCertificate.exists_plusSlicedCertificate_of_tailStable_countermodel; and the
embedding theorem
FormalSystem.Metalogic.Decidability.WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula
says that every integer-time non-validity of a stability-free formula has a certifying sliced
certificate. All four are C2-pinned, axiom closure {propext, Classical.choice, Quot.sound}.

THE LASSO FAMILY IS THE SPECIAL CASE; THE WIRE FORMAT IS A STRICT EXTENSION. The current
(k,l)-loop family this repository exports (ADEQUACY.md 6.1: target, bx, lassos) is exactly the
sliced certificate whose slice width is the lasso count and whose edge matrices are i -> i only
(FormalSystem.Metalogic.Decidability.WitnessFamily.sliced). So the sliced envelope is an
EXTENSION of the current wire contract, not a replacement: nothing already shipped breaks, the
lasso envelope stays byte-for-byte what it is, and the sliced envelope is a NEW key set (see the
ADEQUACY.md 6.1 amendment) with the lassos key OMITTED. Neither repository has shipped a sliced
wire field; the 6.1 amendment is a proposal for the two sides to pin together.

THE SEARCH BOUND IS A 4-TUPLE, AND ONE COMPONENT HAS NO BOUND. The bound this task was told to
expect -- a bound on "the number of world states" -- is wrong in kind: there is no finite number
of world states. The upstream shape is (n, nb, nm, nf): slice width and the three segment
lengths. NO bound on n is proved for any target containing the stability modal, upstream's own
closing record says none should be read into the tree, and n must NOT be configured from a
formula. For stability-free targets the landed L bounds apply unchanged -- at most |C| + 1
lassos, every segment length at most compressionBound -- and the lasso contract remains the
right encoding for them; the embedding theorem above is the guarantee that the extension loses
nothing on that fragment. The registry's period-folding caveat (ADEQUACY.md 7.1(iii-a), the
divisibility rule in SETTINGS.md) carries over to nb and nf unchanged; mid carries no
periodicity.

TAIL-STABILITY IS A NEW ACCEPT/REJECT CRITERION ON THIS SIDE. The checker computes LIVE position
sets (a nested fixpoint over the finite timed position graph of the window) and demands that
transporting the live set one whole period down each tail, filtered by that direction's
one-directional live set, returns the live set at every residue of the period
(FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.TailStable; decidable, cost nb + nf
transfers). Of its two failure modes only the pre-period one is repaired by the search --
by absorbing the pre-period into mid, a mid-length increase, NOT a period multiplication; the
other is absorbed by the checker's own filter and needs no search action; and no theorem says
absorption always succeeds (the claim "every certificate has a tail-stable re-presentation" is
FALSE upstream and stated nowhere). The full statement is the ADEQUACY.md tail-stability item in
this relay. This is the one point that changes this repository's accept/reject logic; it is not
an amendment to anything already here, because nothing here mentions it.

THE CLASS IS INCOMPLETE FOR THE FULL LANGUAGE -- MACHINE-CHECKED, AND PERMANENT. The sliced
certificate class is semantically incomplete for L-plus, and already for its CTL-like fragment.
The witness is Phi := theta' and Box(stab Fp -> not stab not Xp), where theta' := Box(p or stab
Fp or stab Pp) and Box(p -> stab not Pp) says every history meets p exactly once and Xp := bot U p
is "p at the next time". Phi.neg is an integer-time non-validity (Probe710.not_plusValidZTime_neg_Phi)
that NO sliced certificate certifies (Probe710.not_certifies, Probe710.not_sliced_complete), and
-- the stronger statement -- NO model on ANY frame with finite per-time fibres satisfies Phi
(Probe710.no_finite_width_sat, Probe710.not_finite_width_fmp): every countermodel of Phi.neg has
infinitely many states at some time. These five theorems compile sorry-free at BimodalLogic HEAD
780a4265a (specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean,
axiom closure {propext, Classical.choice, Quot.sound}); their library home
(PlusSlicedCertificate/Limits/NoFiniteWidth.lean) is planned, not landed, so cite the probe path
and SHA until it moves. READ THIS CORRECTLY: the refutation is of the FRAME CLASS, not of the
checker -- no_finite_width_sat quantifies over every model on every finite-width sliced frame,
independent of any clause -- so no change to the checker's clauses, tails, windows or stability
demand can rescue completeness. This is not a defect to repair on either side. The
stability-free fragment is unaffected and stays complete (the embedding theorem above).

CONSEQUENCE FOR THIS TASK'S BLOCKER. For stability-free targets nothing on the upstream side
blocks this repository: the lasso contract, the L bounds and the existing re-checker stand. For
targets containing the stability modal, the sliced class is a SOUND, strictly larger search
space with no proved bound on n and no completeness, so the never-report-validity discipline
(decision D8) is PERMANENT for such targets -- not pending a proof, not an open question -- and
an empty search at any (n, nb, nm, nf) licenses nothing. Recommended disposition (a
recommendation, not an instruction): this entry is no longer blocked on upstream; it is blocked,
if at all, on this repository's own decision whether to build a sound-but-incomplete sliced
search for stability targets under D8, and that is a scoping question for this side.

Upstream project 694 (sharing_substrate_trans_redesign), one of the three tasks an earlier draft
of this blocker proposed naming, was evaluated and abandoned: its single-datum trans proposal is
a strict subset of 696's own design and has been folded into 696's design authority directly.
Upstream project 695 (plus_carrier_normalization_int_transfer), the other of those three, is
completed; it no longer blocks this task directly and instead sat upstream of 703 as a
dependency.

Flag (not corrected here, left for whoever next maintains this entry): this task's own
dependencies array names ModelChecker-local task numbers unrelated to the upstream (BimodalLogic)
tasks this description discusses; that pre-existing mismatch is outside this rewrite's scope.

Provenance (2026-10-02): verified against BimodalLogic HEAD 780a4265a -- specs/state.json
(projects 703, 704, 710, 712), FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/{Basic,
Stable,Check,Sound,Complete,Embed,EmbedComplete,Fixture,FixtureStable,Frame}.lean,
PlusWitnessFamily/{Incompleteness,Examples}.lean, BimodalTools/CanonicalWire/Cert.lean, and a
full lake build followed by a compile of the NoFiniteWidthModel.lean probe -- by the relay
"Relay the sliced certificate contract to the model checker" (summary dated 2026-10-02). Re-check
the probe path if BimodalLogic has since landed it as library theorems.
```

## ModelChecker entry 219 — conditional citation amendment

Entry 219 (`bimodal_theory_limits_example_group`, live status `completed`) is not reopened by
this relay. Its THEORY-LIMITS header in `examples.py` (banner at line 1335) states two kinds of
limit: "(a) a genuine ZZ-time non-validity this checker correctly reports as a countermodel" and
"(b) a completeness gap in the VERIFIED side's own certificate system -- a schema for which no
certificate meeting that system's conditions exists". The wording of (b) stands. Three things
change around it, and the third is new in kind.

1. **The certificate class to cite is now `PlusSlicedCertificate`.** FACT 2's sentence "the
   certificate class is EMPTY for this schema" was written about the retired sharing substrate
   and cites `PlusSharingWitnessFamily.not_plusCertifies_stabSnce` / `…_premise` and
   `snce_share_congr`, none of which exists in the live tree (see the entry-200 preface above).
   The live certificate class for L⁺ is
   `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate`, with acceptance
   `…PlusSlicedCertificate.Certifies`, and it is **non-vacuous on stability-free targets** by
   `FormalSystem.Metalogic.Decidability.WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`.
   Replace the three retired citations with `…PlusSharingWitnessFamily.not_snce_share_congr`
   (the shape-mechanism lemma that stands) and `…not_plusValidZTime_stabSnce` /
   `…not_plusValidZTime_stabUntl` (the non-validities, unchanged).

2. **Non-vacuity on stability-carrying targets is conditional — do not assert it.** Whether any
   instance containing the stability modal is now certified by the sliced class is the open
   question of BimodalLogic's `certificate_non_vacuity_and_shape_gates` task (live status
   `planned` as of 2026-10-02T16:37:22Z; the gate this relay names). Until it closes, the
   header may say only: "the sliced class is proved non-empty on stability-free targets; whether
   it certifies any stability-modal instance is open upstream". If that work lands a certifying
   instance, cite it by fully qualified name; if it refutes, record the refutation under (b).

3. **A limit of a stronger kind than (b), to record separately.** `Φ.neg` (the entry-200 block
   above; `Probe710.not_sliced_complete`, `Probe710.not_finite_width_fmp`) is not "no certificate
   has yet been constructed for this schema" — it is "no certificate in this class, or in any
   class presenting finite per-time fibres, can exist", **proved**. Criterion (b) describes an
   emptiness that a redesigned certificate system could in principle fill (as the sliced class
   did for the sharing substrate's gap); this one no checker redesign can fill, because the
   refutation is of the frame class. Suggest recording it as a distinct kind — the header's own
   taxonomy is theirs to extend, and this relay does not draft that paragraph — with the
   observation that the Box-form analogue of `Φ` is *not* a probe to add: `Φ` uses the stability
   modal essentially (it quantifies over histories through a state), and its Box-form is a
   different principle, exactly as the header's own Box-versus-stability caveat warns.

## ADEQUACY.md — row A3 and §7.1(iii-e)

Live anchors: the component table at lines 630-636 (row **A3** at line 636) and §7.1's bullet
(iii-e) at line 729, which currently reads "the upstream bound is a single `n` over all three
segments while the search takes three independent settings". Row A3's statement and status cells
stay as they are (they are about the L bound, which is unchanged); the amendment is one appended
note on the row and a rewrite of (iii-e). Ready to file:

**Row A3 — appended note** (append to the status cell, after "§7.1, §7.3."):

```
**L⁺ note.** For targets containing the stability modal the upstream bound SHAPE is no longer
a single length: it is the 4-tuple `(n, nb, nm, nf)` — slice width and the three segment
lengths of the time-sliced certificate (`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate`).
`n` is a new, unbounded search dimension: NO bound on it is proved upstream for any such
target, upstream's own closing record says none should be read into the tree, and `n` must not
be configured from a formula. For stability-free targets this row stands unchanged — the lasso
contract remains the encoding, the embedding theorem
`FormalSystem.Metalogic.Decidability.WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`
guarantees the sliced extension loses nothing on that fragment, and the `f(|C|)` bound above
applies to the lasso family exactly as before. §7.1(iii-e).
```

**§7.1(iii-e) — replacement bullet** (replaces the whole (iii-e) bullet):

```
- **(iii-e) Segment-length parity with the bound's shape** — the upstream shape is now known
  and it differs by fragment. For stability-free targets the landed bound is on segment
  LENGTHS (`compressionBound`), one number for all three segments, while this search takes
  three independent settings `(back, mid, fwd)`; the parity check is that `back`, `fwd` are
  set as multiples of the needed periods (the divisibility rule, `docs/SETTINGS.md`) and `mid`
  at least `f(|C|)`. For targets containing the stability modal the upstream shape is the
  4-tuple `(n, nb, nm, nf)`: the three lengths keep this bullet's divisibility caveat on
  `nb`/`nf` unchanged (`mid` carries no periodicity, `docs/SEARCH_COVERAGE.md` §3(b)), and the
  slice width `n` has no proved bound and is not to be set from a formula. One subtlety, so
  that nobody restates the L bound as a sliced-tail bound: the SLICED presentation of an
  L countermodel (`FormalSystem.Metalogic.Decidability.WitnessFamily.sliced`) cuts the slice
  sequence at the lassos' COMMON periods, so its `nb`/`nf` can be a common multiple of up to
  `|C| + 1` periods each bounded by `f(|C|)`, not `f(|C|)` itself. This is immaterial here
  because the lasso contract stays in force for stability-free targets; the sliced format is
  for stability targets, where no bound is on offer anyway.
```

## ADEQUACY.md — §6.1 sliced envelope (proposed, unshipped)

Live anchor: §6.1 "The wire contract" (line 444), whose input block has the three top-level keys
`target`, `bx`, `lassos` and whose six frozen names are an export contract. Nothing in that
subsection changes; the following is a **new sub-subsection** to append after the `"echo"`
paragraph (before "### 6.2"). Ready to file:

```
#### 6.1.1 The time-sliced envelope — proposed, not yet shipped by either side

The time-sliced certificate (`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate`) is
a STRICT EXTENSION of the lasso family above: a lasso family with `k` lassos is exactly the
sliced certificate of width `n = k` whose every edge matrix is the identity pattern `i → i`
(`FormalSystem.Metalogic.Decidability.WitnessFamily.sliced`). The envelope below is the wire
form of that extension. It is a PROPOSAL for the two repositories to pin together; neither
side has shipped it, `check_certificate` does not read it today, this repository's
`certificate.py` does not emit it, and the lasso envelope above is unchanged byte-for-byte.
Field names mirror the Lean structure's data fields exactly, as the lasso contract does.

Input (key order frozen in this sequence; canonical bytes as in 6.1):

{"target": {"premises": [<formula>,...], "conclusions": [<formula>,...], "time": <int>},
 "bx":     [[<formula>, true], [<formula>, false], ...],
 "n":      <int>,
 "slices": {"back": [<slice>,...], "mid": [<slice>,...], "fwd": [<slice>,...]},
 "path":   {"back": [[<label>, <state>],...], "mid": [...], "fwd": [...]}}

<slice> = {"edge": [[<bool>,...],...], "lab": [<label>,...]}

- `target` and `bx` are the lasso envelope's fields, unchanged in shape. `target.time` is the
  certificate's `targetTime`; `<formula>` gains one tag, `stab` (`child`), for the stability
  modal, alongside `atom`, `bot`, `imp`, `box`, `untl`, `snce`.
- `n` is the slice width (`n`, with `0 < n`); every `<state>` is an integer in `[0, n)`.
- `slices.back`, `slices.mid`, `slices.fwd` are the three segments (`back`, `mid`, `fwd`), each
  a list of slices; `back` and `fwd` are non-empty, `mid` may be empty. Each `<slice>` is one
  `PlusSlice`: `edge` is its `n × n` Boolean matrix (`edge[i][j]` = an edge from state `i` of
  this slice to state `j` of the NEXT slice), `lab` is its length-`n` list of state labels
  (`lab[i]`, a `<label>` read as a set, drawn from the closure: atoms, `box`- and
  `stab`-formulas true at that state).
- `path.back`, `path.mid`, `path.fwd` are the target path's three segments (`PlusGraphPath`):
  lists of `[<label>, <state>]` pairs, `back` and `fwd` non-empty; the path is read at
  `target.time`.
- Time indexing is the lasso envelope's: `mid` occupies `[0, |mid|)`, `back` repeats leftward,
  `fwd` repeats rightward; a slice's `edge` relates time `t` to `t + 1`.
- **There is no `lassos` key.** A sliced envelope OMITS `lassos` entirely, and a document
  carrying both `lassos` and `slices` is forbidden by this contract. Reason: both re-checkers
  read an absent `lassos` as empty (`BimodalTools.CanonicalWire.decodeOptLassos` upstream;
  `raw.get("lassos", [])` in `semantic/certificate.py` here) and then REJECT structurally, so a
  lasso-only checker fed a sliced envelope fails loudly; a sliced envelope that also carried
  `lassos` would instead be silently checked as a lasso family with its slices ignored. This
  is the Hanoi Omega-Automata format's header discipline applied here: a consumer that does
  not understand a semantics-bearing field must error, never reinterpret.
- The accepted verdict's conditions are the nine conjuncts of
  `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Certifies`; the `rejected`
  verdict's `condition` vocabulary will need the new names (at least `tail_stable`,
  `stab_faithful`, `box_live_faithful`) when the envelope ships. Not specified here.
```

## ADEQUACY.md — new tail-stability item (suggest §7.5, or a row A4)

No section of ADEQUACY.md mentions tail-stability (repo-wide grep `tail.{0,3}stab`: 0 hits), so
this is new information, not an amendment. It is the one point in this relay that changes this
repository's accept/reject logic. Suggested placement: a new "### 7.5 Tail-stability (L⁺ only)"
after §7.4 (there is no §7.5 today), or a row **A4** in the component table with this as its
section. Ready to file:

```
### 7.5 Tail-stability, the sliced checker's wrap-faithfulness demand (L⁺ only)

This condition does not exist for the lasso family and has no counterpart anywhere in this
repository today. It is a conjunct of the sliced checker's acceptance
(`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Certifies`) and will become a
condition this repository's re-checker and search must handle once the sliced envelope
(§6.1.1) ships.

**What the checker computes.** For a sliced certificate `G` the checker computes a LIVE
POSITION SET at each window time. A position is a `(state, type)` pair over a slice; it is
live iff a forward run and a backward run of `G`'s own labelled structure pass through it
with every pending eventuality discharged. This is a nested greatest/least fixpoint over the
finite timed position graph of the combined window, not a field of the certificate.
Liveness replaces the lasso family's all-threads fulfilment ((C2) of §3) by fulfilment of
LIVE positions only, and the box and stability clauses are stated over live positions
(`...PlusSlicedCertificate.BoxLiveFaithful`, `...PlusSlicedCertificate.StabFaithful`), not over
"every position of every lasso".

**The demand.** With `NB`/`NF` the combined back/forward periods (least common multiples of
the certificate's and the target path's segment lengths),
`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.TailStable G` says: transporting the
live set one whole period down each tail, FILTERED by that direction's one-directional live
set (`...PlusSlicedCertificate.bwdLiveAt`, `...PlusSlicedCertificate.fwdLiveAt`), returns the
live set, at EVERY residue of the period — one equation per residue, both tails. It is
decidable (`...PlusSlicedCertificate.decidableTailStable`, a synthesized instance) and costs
`NB + NF` transfer applications. In the published vocabulary it is the periodic-state-function
condition of Hodkinson–Wolter–Zakharyaschev 2000, §5 (Lemma 23's conditions on `f₁ · f₂^ω`,
Theorem 24), stated on named states rather than on types.

**Why it is needed.** Forward liveness from the back tail is NOT a function of the slice at
that time (`...PlusSlicedCertificate.Fixture.live_not_determined_by_slice`): two times with
the same slice can carry different live sets. So the stability clause of the truth lemma must
read the live set at a window representative that carries the same live set at every time
down the tail, and tail-stability is exactly the condition under which such a representative
exists. Without it the window's verdict does not extend to the infinite frame.

**The two failure modes, and who repairs each.**
(a) `⊆` failure: the one-step transfer is a reachability relation, so a position reachable
from a live position but dead in one direction lands in the iterate. The checker's FILTER
(the intersection with `bwdLiveAt`/`fwdLiveAt`) removes it. No search-side action.
(b) `⊇` failure: a genuinely live position has no live predecessor one whole period back,
because a pre-period shows through the window's edge. No filter repairs this. It is
repaired, when it is, by RE-PRESENTING the same frame with the pre-period absorbed into
`mid` — a `mid`-length increase, NOT a period multiplication
(`...PlusSlicedCertificate.Fixture.not_mem_L₀_pR` records the failure's witness leaving the
live set once the pre-period is absorbed).

**What is NOT promised.** There is no theorem that absorption always succeeds. The claim
"every certificate has a tail-stable re-presentation" (`exists_tailStable_repr`) is FALSE
upstream and is stated nowhere: it is refuted at a named certificate for the raw demand
(`...PlusSlicedCertificate.Fixture.not_tailStableRaw`, for every pre-period and every period
multiplier), and for the filtered demand no general re-presentation lemma is stated either.
`TailStable` is a demand on the frame together with its closure — a conjunct of `Certifies`,
not a theorem — and `...PlusSlicedCertificate.Fixture.not_tailStable_cert` exhibits a
certificate it rejects. So a search that finds a countermodel frame and cannot present it
tail-stably reports exactly that, and D8 (§7.4) covers the gap: nothing is licensed either
way. (The raw, unfiltered demand is kept upstream under the name
`...PlusSlicedCertificate.TailStableRaw`; cite `TailStable`, the filtered one, as the landed
condition.)

**The embedded case is fully covered.** Every certified lasso family yields a tail-stable
sliced certificate at every residue
(`FormalSystem.Metalogic.Decidability.WitnessFamily.sliced_tailStable_of_certifies`). On
stability-free targets the demand never rejects anything the lasso contract accepts.

**Representability and tail-stability are different questions, and they compose.** This
repository's exact-modulus folding (`witness_registry.py` `wrap`, §7.1(iii-a)) is about
REPRESENTABILITY of a period at a configured length — whether `nb'` divides `nb`.
Tail-stability is about whether liveness wraps FAITHFULLY at the configured period. The
bounded sweep over `(back', fwd')` remains the mechanism for exploring periods; absorbing a
pre-period is an increase of `mid`, which the sweep holds fixed and may be raised freely
(`docs/SETTINGS.md`). Do not equate the two.
```

## ADEQUACY.md — §7.4 one added sentence

Live anchor: §7.4 "The never-report-validity rule" (line 869), grounds (i) and (ii). Append, as a
third paragraph after "Both grounds hold independently of each other and of any future progress
on A1." Ready to file:

```
**For L⁺ targets containing the stability modal, ground (i) holds PERMANENTLY, not pending
A1-style work.** The time-sliced certificate class is semantically incomplete for L⁺
(`Probe710.not_sliced_complete`: the formula `Φ := θ' ∧ □(⊡Fp → ¬⊡¬Xp)` has `Φ.neg` a
ℤ-time non-validity that no sliced certificate certifies), and so is EVERY certificate class
presenting a frame with finitely many states per time (`Probe710.not_finite_width_fmp`),
whatever its clauses — the refutation is of the frame class, not of the checker. Both are
machine-checked, sorry-free, in BimodalLogic's `NoFiniteWidthModel.lean` probe (HEAD
`780a4265a`; planned library home `PlusSlicedCertificate/Limits/NoFiniteWidth.lean`). So an
empty search at any `(n, nb, nm, nf)` licenses nothing for such a target, and will not after
any future bound on `n` either. Stability-free targets are unaffected: there the class is
complete (A1's embedding, §7.1(iii-e)).
```

## ADEQUACY.md and SEARCH_COVERAGE.md — unchanged

Confirmed against the live files; nothing in this relay touches them:

| Artifact | Live anchor | Why unchanged |
|---|---|---|
| ADEQUACY.md row **A0** | line 632 | The frame-class gap (ℤ-time completeness ≠ completeness at every temporal order) is independent of the certificate class. |
| ADEQUACY.md row **A1** | line 633 | The landed compression instance (`exists_witnessFamily_of_not_validZTime`, `compressionBound`) is about the lasso family on stability-free targets, which the relay keeps as the encoding for that fragment. |
| ADEQUACY.md row **A1-Γ** | line 634 | The general-premise obligation is unchanged in form; the sliced class adds nothing to it and takes nothing from it. |
| ADEQUACY.md row **A2** | line 635 | Encoding completeness is about the Z3 encoding of the lasso family at configured lengths; the sliced envelope is unshipped, so there is no encoding to be complete for yet. |
| ADEQUACY.md §7.1(iii-a) | line 709 | The bounded sweep is the mechanism the relay's tail-stability item composes with; it is not altered. |
| SEARCH_COVERAGE.md §3(b), §4 | lines 73, 118 | Route (b), the bounded sweep over `(back', fwd')` with `mid` fixed, stands. One note for whoever builds the sweep driver (its §5 staged path): absorbing a pre-period to repair a tail-stability `⊇` failure is a `mid` increase, which composes with the sweep — `mid` is held fixed per sweep and raised between sweeps, never swept. |
| SETTINGS.md divisibility caveat | lines 33-39 | Carries over to `nb`/`nf` verbatim; `mid` remains unaffected. |
| TRUST_PIPELINE.md "Compute bounds from the closure (A3)" row | line 309 | About the L bound and the representability gap; unchanged. |
