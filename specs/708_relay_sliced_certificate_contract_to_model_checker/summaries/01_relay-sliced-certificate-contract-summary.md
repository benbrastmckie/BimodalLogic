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
