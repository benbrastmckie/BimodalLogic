# Round 34 — Route (Q-1): the read-off / construction pair, and the evidence wiring

Phase 19 of `plans/34_readoff-construction-pair-restatement.md`, Ruling 35. This round wires the
four refutation units that the chain's exclusion records cite but that existed only in report
appendices. Nothing is re-derived, re-proved, renamed or repaired: every declaration below is the
report's own text, copied verbatim.

## 0. Entry gate, and why this phase ran instead of the one the dispatch named

Dispatch 83 was issued `Implement phase 12.5 only`. That selection was the product of a known
orchestration defect, re-measured at this phase's entry rather than assumed:

- The working-tree plan file carried **four** closed phase headings downgraded to `[PARTIAL]` —
  12.5 (`[COMPLETED]`), 12.6 (`[COMPLETED]`), 15.2 and 16 (both
  `[COMPLETED WITH EXCLUSIONS]`) — against the committed plan at `96db600f9`.
- Measured marker counts: HEAD = 36 `[COMPLETED]` + 27 `[COMPLETED WITH EXCLUSIONS]` + 12
  `[NOT STARTED]` + 2 `[PARTIAL]` = 77 headings, i.e. **63 closed**. Working tree = 34 + 25 + 12 +
  6 = 77, i.e. **59 closed**. The plan's own metadata line states `63 of 77 phases closed`.
- The surviving `.orchestrator-handoff.json` is **dispatch 82's**, written for Phase 11.49, before
  five research rounds and the v34 revision. Its `phases_completed` is **59**. The four
  downgrades are exactly the number needed to force the plan's count down to that stale figure.
- This is the H1 marker/handoff gate defect already recorded as `iss_1794847364431_bAgQCh`,
  whose recorded remedy is: when the revision sentinel is newer than the handoff, **the plan
  markers are authoritative** and the handoff count is resynced, rather than plan headings being
  edited. `.plan-revised.json` carries `revised_at: 1794872246`, newer than the handoff.
- Phase 12.5's three deliverables are landed and committed: `real_certBiInfK`
  (`LadderRealize.lean:549`), `real_certFwdK` (`:571`), `real_certBwdK` (`:610`).

The four headings were reverted to their committed values (the plan file is byte-identical to
`HEAD` on that account), and this dispatch executed the plan's genuinely live phase. Phase 19
carries `Depends on: none`, sits at **wave 1**, and the Dependency Analysis names it "the first
thing any dispatch should run".

**Escalation note.** Previous observations of this defect were one heading per revision. This one
is four, because the v34 revision closed four phases by exclusion at once. Ruling 28's structural
fix (relocate `[PARTIAL]` headings past every open phase) does **not** cover it: that ruling
relocates genuinely-`[PARTIAL]` headings, whereas this gate *manufactures* new `[PARTIAL]`
headings at arbitrary file positions, ahead of the relocation barrier.

## 1. The four units, their sources and their destinations

| # | Source | Destination | Lines |
|---|---|---|---|
| 1 | `reports/29_row-link-route-viability.md` Appendix A, lines 153–393 | **NEW** `specs/evidence/seam-gluing-ray-product/ladder-gap-jump-refutation.lean` | 241 |
| 2 | `reports/29_row-link-route-viability.md` Appendix B, lines 401–446 | appended to `ladder-cell-agreement-refutation.lean` | 46 |
| 3 | `reports/32_laddermodel-construction-falsifier.md` Appendix, lines 175–323 | appended to the same file, **after** unit 2 | 149 |
| 4 | `reports/33_exponential-clip-cell-constancy.md` Appendix, lines 163–683 | **NEW** `specs/evidence/seam-gluing-ray-product/ladder-chain-object-clip-refutation.lean` | 521 |

Each extraction was taken at exactly the plan's stated line range and the resulting line counts
(241 / 46 / 149 / 521) match the plan's figures exactly. Unit 3 `open`s `Probe761C`, so it is
appended after unit 2; the existing file's final `end Probe761C` is followed by unit 2 reopening
that namespace, which is legal and compiles.

## 2. The import correction, confirmed against the live modules

Report 32 instructs replacing the import with `LadderRealize`; report 29 Appendix B instructs
`LadderStepFrag`. Units 2 and 3 land in the same file, so neither literal instruction serves both.
The import graph was re-read from each module's own `import` lines at this phase's entry:

```
LadderStepFrag → LadderRealize → LadderChain → LadderPump → LadderAgree
```

So the single line `import FormalSystem.Metalogic.Decidability.RaySummary.LadderStepFrag`
transitively supplies `typeOfCl` (via `LadderRealize`), `mem_cellAt_ladder_iff` (via
`LadderAgree`) **and** `Mrel`. That is the line this phase wrote at line 68, replacing
`…LadderAgree`. **It compiled on the first attempt with both units present**, which is the
derivation's confirmation: the plan's one derived departure from both reports was correct, and a
dispatch following either report literally would have broken the other unit.

## 3. Compilation and axiom profiles

All three files compiled through `lake-build-guard.sh`, each `exit_status=0` with zero warnings.
**No block required any repair**: there is no drift to record between the commits the appendices
compiled against and the tree at `96db600f9`.

Unit 1 — `ladder-gap-jump-refutation.lean`:

```
'ProbeGapJump.region_exit_register'            [propext, Classical.choice, Quot.sound]
'ProbeGapJump.no_rowLinked_path_gap'           [propext, Classical.choice, Quot.sound]
'ProbeGapJump.exists_rowLinked_path_K1_refuted' [propext, Classical.choice, Quot.sound]
'ProbeGapJump.no_rowLinked_path_gap_any_room'  [propext, Classical.choice, Quot.sound]
```

Unit 4 — `ladder-chain-object-clip-refutation.lean`:

```
'Probe761G.chainC_cell_ne'                [propext, Classical.choice, Quot.sound]
'Probe761G.gap_clip_refuted_at_every_clip' [propext, Classical.choice, Quot.sound]
'Probe761G.no_formula_only_clip'          [propext, Classical.choice, Quot.sound]
'Probe761G.exponential_clip_refuted'      [propext, Classical.choice, Quot.sound]
```

Units 2 and 3 — appended to `ladder-cell-agreement-refutation.lean`:

```
'Probe761C.cell_agreement_over_Mrel_refuted'           [propext, Classical.choice, Quot.sound]
'Probe761C.cell_agreement_over_Mrel_refuted_at_depths' [propext, Classical.choice, Quot.sound]
'Probe761F.no_keyed_cell_map'                          [propext, Classical.choice, Quot.sound]
'Probe761F.no_construction_receives_ladderModel'       [propext, Classical.choice, Quot.sound]
'Probe761F.no_dmax_construction_receives_ladderModel'  [propext, Classical.choice, Quot.sound]
'Probe761F.ladderModel_realizes_no_set'                [propext, Classical.choice, Quot.sound]
'Probe761F.no_keyed_cell_map_below_exponential'        [propext, Classical.choice, Quot.sound]
'Probe761F.no_slice_respecting_injection'              [propext, Classical.choice, Quot.sound]
'Probe761F.no_slice_respecting_injection_into_set'     [propext, Classical.choice, Quot.sound]
```

Every profile is a subset of `[propext, Classical.choice, Quot.sound]`. No `sorryAx`, no custom
axiom, no `native_decide`, in any of the three files.

## 4. The citation map — which phase's exclusion record each unit holds in place

| Declaration | Wired at | The phase whose record cites it |
|---|---|---|
| `exists_rowLinked_path_K1_refuted` | `ladder-gap-jump-refutation.lean` (unit 1) | **11.49**, closed by exclusion: the path forth is false at that phase's own two-hypothesis signature |
| `no_rowLinked_path_gap_any_room` | same file (unit 1) | **11.40**, closed by exclusion: equal countdowns of arbitrary size, so no countdown-side repair revives the route |
| `cell_agreement_over_Mrel_refuted` | `ladder-cell-agreement-refutation.lean` (unit 2) | **15.2**, closed by exclusion: the route's own projected end result |
| `no_dmax_construction_receives_ladderModel`, `ladderModel_realizes_no_set` | same file (unit 3) | **16**, closed by exclusion: falsifier (4) failed with a compiled reason |
| `no_keyed_cell_map_below_exponential` | same file (unit 3) | **16** and **22**: the sub-exponential boundary of the open question |
| `no_formula_only_clip`, `exponential_clip_refuted` | `ladder-chain-object-clip-refutation.lean` (unit 4) | **16**, closed by exclusion, and **22**, which records the object-dependent clip as a NAMED OPEN QUESTION with exactly this compiled boundary |

## 5. Ruling 35's mechanical check

Before this phase:

```
grep -rnE '(theorem|lemma) +(no_keyed_cell_map_below_exponential|no_formula_only_clip|exists_rowLinked_path_K1_refuted|cell_agreement_over_Mrel_refuted)\b' specs/evidence/
```

returned **no hits**, re-run at this phase's entry and confirmed. After this phase it returns
**four hits**, one per declaration. Both new files are **tracked** (`git ls-files
--error-unmatch` exits 0 on each), which `check_probe` tests and reports as a failure otherwise.

`bash scripts/check-evidence-probes.sh` exits **0**: `PASS  all 67 wired probe(s) compile`, with
both new probes named PASS in its output and zero FAIL rows.

## 6. What this round does NOT do

It wires evidence; it changes no mathematics. No declaration was re-proved, restated, renamed,
weakened or strengthened; nothing was moved out of `specs/evidence/`; nothing was landed in
`FormalSystem/`. The read-off half (Phase 20) and the construction half (Phase 21) are untouched
and remain unwritten, and the object-dependent clip remains the one unrefuted route and an open
question, not a closed one.
