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

---

# Phase 22 — The object-dependent clip, recorded as a NAMED OPEN QUESTION

Phase 22 of `plans/34_readoff-construction-pair-restatement.md`, decision 26 obligation 5,
Ruling 36. **This section records a question and does not answer it.** No clip is adopted, no
agreement is attempted, no Lean declaration is landed, and `paramsOkK4`, `Bof` and `ParamsOk` are
not edited. The object-dependent clip `B(Q, φ)` is **the one route in this chain that is not
refuted**; recording it as dead would be as wrong as adopting it untested, and this task has spent
five rounds learning the cost of the second error.

## 7. The boundary, stated exactly

Every row carries COMPILED, INFERRED or OPEN, and every COMPILED row cites a **wired** probe path
under `specs/evidence/` together with the declaration name. Each line number below was re-measured
against the live file in this dispatch, not quoted from the plan.

| Claim | Status |
|---|---|
| Every clip that is a function of the FORMULA alone fails, at every `(Tc, Tn, P)` | **COMPILED** — `no_formula_only_clip (E : PlusFormula → ℕ)`, quantified over ALL `E`, wired at `specs/evidence/seam-gluing-ray-product/ladder-chain-object-clip-refutation.lean:521` |
| The exponential clip `E φ := 2 ^ (dBack φ + 1)` fails | **COMPILED** — `exponential_clip_refuted`, its instance, wired at `specs/evidence/seam-gluing-ray-product/ladder-chain-object-clip-refutation.lean:555` |
| On `Qc`, every clip `B` with `B + 1 ≤ 2 ^ (j + 1)` fails at `dblC j` | **COMPILED** — `gap_clip_below_exponential_refuted`, wired at `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean:3295` |
| The same, for the keyed cell map rather than the agreement | **COMPILED** — `no_keyed_cell_map_below_exponential`, wired at `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean:3482` |
| The refuting chain family reaches up to `card Q − 2` and no further | **COMPILED** — at `Qm m` (`…/ladder-chain-object-clip-refutation.lean:70`, `abbrev Qm (m : ℕ) := Fin (m + 3)`, so `card Q = m + 3`), `chainC_cell_ne` (`:433`) separates gap `m + 1` from gap `≥ m + 2` under `hgap : c + m + 2 ≤ n'`. A `kappa`-collision needs both gaps saturated at the clip, so the family speaks only for `B ≤ m + 1 = card Q − 2` and is **silent at `B ≥ m + 2`** |
| Any surviving clip is of order `card Q · 2 ^ (dBack φ)` | **INFERRED, NOT COMPILED** — report 33 F4 did not build the `lvlC` induction over `Qm m`. **No record states this as compiled, and this one does not either.** |
| Cells are constant on `kappa`-classes at some `B(Q, φ)` | **OPEN** — neither proved nor refuted, by anyone, anywhere |

**The accurate scope sentence, which supersedes any shorter one**: below `2 ^ (dBack + 1)` refuted
on `Qc`; at every formula-only clip refuted on the chain family; an object-dependent clip OPEN.

**A correct clip EXCEEDS the clips at which the filed families separate; it never reproduces
them.** `Bof thetaC = 3` and `Bof (mixC (k + 2) k) = 2 · k + 5` are the clips that FAIL; the
compiled non-collision results stand at `B ≥ 4` and `B ≥ 3 · k + 5`.

## 8. The missing piece for a positive result, named

A closure theorem for definable register sets on ARBITRARY finite objects:

1. **which sets of idle registers are definable at each operator depth** — conjecture: eventually
   periodic with period dividing `P + 1` and threshold `≤ T(Q, depth)`;
2. **closure of that class under the four jump moves and under `⊡`'s re-selection**, with `T`
   solving Ruling 32's jump recurrences;
3. **the same for pending states**, where the gap is converted to an exit register.

`grep` finds no statement of (i)–(iii) anywhere in the tree, re-run at this phase's entry. The
nearest compiled objects are probe-level and object-specific: `stepFrag_gap_depth_exact`
(`specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean:1160`), **step
fragment only** — the step fragment admits `untl`/`snce` only at the guard `⊥`, and `thetaC` and
`mixC` each use one jump and are therefore **NOT covered** by it — and `nxt_le_double`
(`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean:3018`), on `Qc`
only.

**This is Phase 11.7 at a larger clip — a theorem-sized programme, not a missing lemma.** Phase
11.7's own `#### Reasoned Exclusions` record (this plan, under
`### Phase 11.7: The Agreement cellAt_const_of_kappa_eq [COMPLETED WITH EXCLUSIONS]`) closed the
filed Goal at the filed clip and again at the repaired clip, and its third row records that no
weakened, regime-narrowed or same-named restatement may be landed under
`cellAt_const_of_kappa_eq`. Nothing in this section relaxes that; the open question here is a
DIFFERENT claim — a clip reading the OBJECT — under a signature that does not yet exist.

## 9. The signature cost, and why taking it is a user decision

| Object | Where | What it reads today |
|---|---|---|
| `paramsOkK4 (φ : PlusFormula) (B : ℕ)` | `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean:920` | the FORMULA and the clip; no object binder |
| `Bof` | same file, `:854` | `max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)` — the FORMULA alone; its three object binders are documented in its own body as unused |
| `paramsOk_params` | same file, `:938` | the discharge lemma for the whole tuple |
| every statement carrying `ParamsOk` as a hypothesis | across `RaySummary/` | the tuple as filed |

An object-dependent clip edits a pinned predicate and its discharge lemma, hence every consumer.
**That is a Statement Fidelity change** (`.claude/rules/plan-compliance.md`): the theorem text of
the Challenge block would be unchanged while `ParamsOk`'s MEANING changed. It is therefore routed
to the user and is not taken by any phase of this plan.

**The order of `K` is NOT the obstacle.** `K = (Tc + 1) · (P + 1)² · (Tn + 1) · (2 B + 1)`, and
`Tcof` (`CounterQuotient.lean:820`) already carries
`Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (Pof + 1) * (stabDepth sup + 1)` — so `K`
is already exponential in the formula and already reads `card Q`. The worry that an
object-dependent clip would make `K` exponential is moot: it is exponential today.

## 10. What an attack-first round would do, if the user ever takes it

Ruling 31's discipline applies: **attack before adopt**. Every hypothesis adopted untested in this
task (`Zrel`, `Srel`, `Mrel` as filed) turned out refuted; the two rounds that attacked first
(11.44, 11.48) are the ones whose hypotheses survived. So such a round would, in this order:

1. **First compile the composed `card Q · 2 ^ (dBack φ)` lower bound** — the `lvlC` induction
   re-proved over `Qm m` — so that the figure stops being INFERRED. Until that compiles, no clip
   is even stated.
2. **Then attack**, with two families the chain family does not reach: two-chain objects of
   DIFFERENT lengths joined at the pending state, and objects whose pending region must traverse a
   cycle.
3. **Only then**, and only if both attacks fail, a proof attempt — which would owe (i)–(iii) of
   §8 and the signature change of §9.

## 11. The scope-sentence sweep, and a plan defect found while running it

The sweep is for the stale sentence saying that the sub-exponential refutations `leave(s) the
exponential clip open`. It returns **no assertion of that sentence anywhere in the tree**. The
only hits were inside Phase 22's OWN text in the plan: the task bullet that quoted the sentence in
order to ask for its correction, and the verification criterion, whose filed form spelled the
pattern out as two literal alternatives. **That criterion was unsatisfiable by construction** — it
greps a directory that contains the grep, so writing the criterion down falsifies it, and so does
writing down any faithful record of having run it.

The repair is a pattern, not an exclusion list: the criterion now uses the single regex
`leaves? the exponential clip open`, which matches both inflections while **not itself being a
literal occurrence of either**, so the criterion line, this record and the task bullet are all
exempt by construction rather than by a `grep -v` that could also hide a genuine hit. The one
carved-out path is `issues.jsonl`, the machine capture log, whose entry on this very defect quotes
the sentence as its content; it is a capture log, not prose. The substantive check the criterion
exists to make — that nothing in the tree ASSERTS the stale sentence — is discharged and passes.
Nothing else in the tree's prose was edited, because nothing else said it.

## 12. What this section does NOT do

No clip is adopted. No agreement is attempted. No phase of this plan takes this route. The
question is not described as settled, likely, nearly-settled or dead, and the
`card Q · 2 ^ (dBack φ)` figure is not stated as compiled. `paramsOkK4`, `Bof` and `ParamsOk` are
unedited, Phase 11.7 is not re-opened, and no `sorry`, `axiom` or vacuous definition was written.
