# Implementation Plan: Task #734

- **Task**: 734 - Run experiment E4: decide StabSaturated on the Bool fixture's mosaic set, and acquire the Hodkinson-Reynolds Handbook sections
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours
- **Dependencies**: 733 (completed)
- **Research Inputs**: specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/reports/01_e4-stabsaturated-mixed-germ-probe.md
- **Artifacts**: plans/01_e4-stabsaturated-mixed-germ-probe.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Land the E4 probe `specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` and wire
it into `scripts/check-evidence-probes.sh`; record the Handbook ch. 11 sections 5.10-5.11
acquisition half as a residual gap in `specs/literature-index.json` with today's re-measurement
and its unchanged reactivation condition. The research dispatch already compiled a sorry-free
scratch of the whole proof, preserved lift-ready at
`specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/prototype/mosaic-stab-saturated.proto.lean`
(namespace `Probe734Mosaic`, 179 lines, four `#print axioms` lines, re-compiled at plan time in
2.3 s with rc=0 and no `sorryAx`). The mathematical outcome is fixed and empty-but-definite:
`Probe718Mosaic.StabSaturated` is identically true (`stabSaturated_univ`), so it is decidable on
the mixed-germ E2 Bool fixture because it is constantly true, the review's literal R2 falsifier
is unsatisfiable, and the real SH1 content -- the witness-direction predicate `StabWitnessedAt`
-- is non-trivial on mixed sets (holds on `Smix`, fails on `Sdrop`). Implementation is a
lift-header-wire job plus one JSON field edit. Definition of done: the probe compiles under
`lake env lean` with exactly its four axiom lines, the gate reports every wired probe passing
with the count up by one (baseline 26, re-derived at plan time), the sub-index entry carries the
re-measurement, the full gate set is green, and the implementer returns `partial` with the
Handbook acquisition as a named external blocker -- the task rests `[PARTIAL]` by the recorded
user decision (cycle 4, `.decisions.json`), which is the acceptance clause's own prescribed
outcome, not a shortfall.

### Research Integration

From `reports/01_e4-stabsaturated-mixed-germ-probe.md`:
- F1-F3: the landed predicate is a tautology, proved by the one-line term
  `fun _ _ _ hχ m' _ heq => hχ m'.hist heq.symm`; `stabSaturated_of_sameState`'s hypothesis was
  never load-bearing; the literal falsifier cannot be instantiated. The header must say
  "vacuous" in so many words so a reader never takes `stabSaturated_univ` as support for R2.
- F4: `StabWitnessedAt Mg Fp` holds on `Smix = {stayA, jumpB, stayB}` and fails on
  `Sdrop = {jumpB, stayB}`; both sets are mixed (`Smix_mixed`, `Sdrop_mixed`). New fixture
  lemmas `succ_of_b` and `stabFp_stayB`. All sorry-free at
  `[propext, Classical.choice, Quot.sound]`.
- F5: checking the witness direction over a finite set presupposes deciding `⊡χ` per mosaic,
  which on this fixture is `Probe711DepthTwo.stab_will_iff` -- R1's device. The header must
  say the semantic-label mosaic set decides nothing on its own.
- Literature (Caleiro-Vigano-Volpe 2013, sections 3.1, 3.2, 4.3, the in-corpus stand-in for
  Handbook section 5.10): SH1 is the diamond/witness clause; the mosaic decidability argument
  (Thm 4.11) does not extend once the horizontal and vertical components interact, and `⊡`
  interacts with the task relation by construction. This is what the header's "R2 standing"
  paragraph cites: hypothesis restated, R2 neither promoted nor closed.
- D1: "the two-state Bool fixture" is read as the E2 fixture `Rg` (`a→a`, `a→b`, `b→b`, `p`
  at `b`), not the complete-graph fixture `Rf` on which `⊡(Fp)` is uniformly false. State this
  in the header.
- E1 and R-C: the Handbook sections remain unobtainable (publisher preview re-measured at 3
  pages, 51,937 bytes, byte-identical; DOI `10.1016/S1570-2464(07)80014-0` paywalled). Record
  the re-measurement in the sub-index `hazard` field; do not ingest a summary from memory.
- R-B: do not edit `mosaic-germ-amalgamation.lean`; the no-weakening rule for wired probes
  applies to its statement too. The vacuity is recorded in the new probe; the old one stays as
  the historical record. The gate's Probe 718 table row (comment only) is amended by pointer.
- Gate mechanics (F7): one comment-table row under `# --- WIRED ---` and one string in
  `WIRED=( ... )`, both directly after the `b2b-frame-constructor-branching` entry (the last
  one at plan time).
- Pitfalls hit and fixed in research (Risks table): the classical `DecidableEq` instance must be
  a global `noncomputable instance`, not `open Classical in` scoped to the def; `Fg.WorldState`
  projections need `have hb' : (τ.path t).2 = true := hb` plus `Bool.noConfusion`, and
  `(c,false) = (c,true)` needs `injection ... with _ h2`. The prototype already embodies these;
  do not re-derive.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided in this dispatch (no `roadmap_path`); ROADMAP.md was not
consulted.

## Goals & Non-Goals

**Goals**:
- The landed predicate and its vacuity: `StabSaturated`, `stabSaturated_univ`
- The witness-direction predicate (SH1): `StabWitnessedAt`
- E2 fixture transcription: `Rg_fwd`, `Rg_bwd`, `Mg`, `stayA`, `stayA_state`, `stayA_state_t`,
  `stayB`, `stayB_state`, `stayB_state_t`, `jumpB`, `jumpB_state`, `jumpB_state_t`,
  `jumpB_state_succ`, `not_Fp_stayA`, `Fp_jumpB`, `not_stabFp_jumpB`, `succ_of_b`,
  `stabFp_stayB` (Rg, Fg, pa, Fp are abbrev scaffolding in the Challenge block, not pinned
  identifiers; see the note there)
- The mixed-germ sets and the four verdicts: `instDecEqMosaic`, `Smix`, `Sdrop`, `Smix_mixed`,
  `Smix_stabSaturated`, `Smix_witnessed`, `Sdrop_not_witnessed`, `Sdrop_mixed`
- Goals stated in prose (not Challenge-pinned; no backticks here by design, the snapshot tool
  reads every backticked token in this block as an identifier): the probe file at its declared
  file_scope path with the collection-style header (fixture choice, vacuity verdict, falsifier
  unsatisfiable, witness-direction result, R2 standing, Handbook residual gap, hard
  constraints, axiom record, compile-check line); the gate wiring (one WIRED entry, one table
  row, the Probe 718 row amended by pointer); the sub-index hazard re-measurement on
  hodkinson_2006; scoped commits of exactly the three file_scope paths; a partial return with
  the acquisition blocker named.

**Non-Goals**:
- No acquisition phase for Handbook sections 5.10-5.11 (recorded user decision, cycle 4: the
  acquisition half stays a residual gap with its reactivation condition). No summary written from
  memory is ingested as a stand-in for the section bodies (provenance rule).
- No complexity claim, no fourth certificate class, no re-ranking of R2 above R1 (task hard
  constraints; `Probe710.not_finite_width_fmp` stands untouched). The header reports evidence;
  ranking is the review's.
- No edit to `mosaic-germ-amalgamation.lean` or any other wired probe `.lean` file; no
  "repair" of `StabSaturated` to the witness direction in the landed probe.
- No syntactic mosaic calculus (points on a finite closure, H1/SH1 as label conditions, the
  bespoke `⊡`-fibre interaction condition) and no saturated-set existence theorem for L⁺ --
  the research names these as the real R2 content and as open; this probe only records that the
  semantic-label predicate was the wrong object.
- No README note under `FormalSystem/Metalogic/Decidability/` (the report's context-extension
  recommendation; outside this task's `file_scope`, left to a follow-up).
- No re-derivation of the prototype's proofs; no proof edits beyond the namespace and the three
  binder lines already applied to the prototype.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A reader takes `stabSaturated_univ` as positive evidence for R2 | M | M | The header's outcome line says "VACUOUS" and "decides nothing about R2" in those words; the gate table row says the same; the R2-standing paragraph cites Caleiro section 4.3's non-transfer statement. |
| Concurrent writer on `scripts/check-evidence-probes.sh` (747 is `[RESEARCHED]` and declares the script in its `file_scope`; 720 declares the whole collection directory and lists 734 as a dependency; both `not_started`/not implementing at plan time) | M | L | Re-read the script immediately before editing (Phase 4); stage only the declared `file_scope` paths plus this plan by explicit path; an unexpected foreign modification at the insertion point is stop-and-report, never overwrite. Do not run Phase 4 in a cycle where 747 is implementing. |
| Challenge/landed statement drift on `StabSaturated`, `stabSaturated_univ`, `StabWitnessedAt` (`M` must be an explicit binder, not a `variable`, for a `sorry`-bodied Challenge def to carry it) | M | L | The prototype already carries `M` as an explicit binder on those three lines (plan-time compile rc=0, four axiom lines unchanged); Phase 1 lifts it verbatim and the Challenge block below was type-checked against `FormalSystem` at plan time (rc=0, warnings only). |
| Header axiom record drifts from the measured record | M | L | Phase 1 captures the four printed lines; Phase 2 copies them verbatim; Phase 4 re-runs the compile and diffs against the header. |
| Header prose introduces a Lean error (unterminated `/- -/`, a backtick-free `⊡` is fine, a stray `-/`) | L | L | `lake env lean` on the file after every header edit; fix forward. |
| `specs/literature-index.json` left invalid after the `hazard` edit | M | L | Edit via `jq` with a filtered write to a temp file, `jq empty` the result, then move into place; the entry's other fields are preserved byte-for-byte by the filter. |
| `[PARTIAL]` resting state misread as a failed dispatch | M | M | Phase 4 returns `partial` with a populated `blockers[]` naming the acquisition blocker and the decision that settled it; the summary and handoff state that all four phases completed and that the resting state is the acceptance clause's prescribed outcome. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel: Phase 3 (the sub-index field) is independent
of the Lean lift and can run alongside Phase 1; Phase 4 is the terminal node and depends on every
other phase.

### Phase 1: Lift the prototype to its evidence path and compile [COMPLETED]

**Goal**: The probe exists at its declared `file_scope` path, compiles clean under
`lake env lean`, and its measured axiom record is captured for the header.

**Tasks**:
- [x] Re-read the Probe 718 header (`specs/evidence/seam-gluing-ray-product/mosaic-germ-amalgamation.lean`,
      the `/- Probe 718 ... -/` block) and confirm `StabSaturated` (line ~127) and
      `stabSaturated_of_sameState` (line ~138) still carry the names and statements the research
      verified; the new probe cites both by name and re-declares `Mosaic`/`StabSaturated`
      verbatim (probes never import each other).
- [x] Copy `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/prototype/mosaic-stab-saturated.proto.lean`
      to `specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` (new file). The
      prototype is already lift-ready: `namespace Probe734Mosaic`, `variable {F : TaskFrame}
      {t : F.Duration}`, and `M : TaskModel F` as an explicit binder on `StabSaturated`,
      `stabSaturated_univ`, and `StabWitnessedAt` (the Challenge-compatible shape; the elaborated
      types are identical to the research scratch's).
- [x] Prepend a provisional `/- Probe 734 ... -/` block above `import FormalSystem`, ending in
      the collection's compile-check line
      (`lake env lean specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean`).
      Change nothing below `import FormalSystem`: keep every proof and the four-line
      `#print axioms` footer exactly as in the prototype.
- [x] Run `timeout 300 lake env lean specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean`
      from the repository root; require exit 0, no `error`/`warning` lines, and exactly four
      `'Probe734Mosaic.<name>' depends on axioms: [propext, Classical.choice, Quot.sound]` lines
      for `stabSaturated_univ`, `Smix_mixed`, `Smix_witnessed`, `Sdrop_not_witnessed`.
- [x] Record the four printed axiom lines verbatim (progress file) for Phase 2.
- [x] Record an issue-log entry (`issue-record.sh`, kind `win` or an explicit "nothing to
      record") for this phase.

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The prototype is 179 lines with 35 top-level declarations and a 4-line
`#print axioms` footer, and compiles with 0 errors, 0 warnings, 0 `sorry` (re-derived at plan
time: `wc -l`, `grep -cE '^(theorem|def|...)'`, `grep -n sorry` empty, `lake env lean` rc=0 in
2.3 s); confirm at lift time with the same three commands and the compile's exit status and
output line count.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean`
is the complete covering check -- the probe lives outside the Lake build graph, imports only
`FormalSystem`, and no file imports it, so the single-file compile is its entire blast radius.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` - new file, lifted from
  the prototype with a provisional header

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` exits 0
  with no `error`/`warning` lines and exactly four axiom lines, each
  `[propext, Classical.choice, Quot.sound]` -- any deviation (a fifth line, `sorryAx`, a
  different axiom set) is a stop-and-investigate signal, not something to paper over.
- `git status --short specs/evidence/` shows only the new probe file; no existing probe
  modified.

---

### Phase 2: Write the collection-style header [COMPLETED]

**Goal**: The header states, with every claim backed by a named declaration, what the acceptance
criteria require: whether `StabSaturated` is decidable on mixed germ states and what that does
to R2's standing -- plus the falsifier verdict, the witness-direction result, the Handbook
residual gap, the hard constraints, and the measured axiom record.

**Tasks**:
- [x] Replace the provisional header with the full `/- Probe 734 ... -/` block, modelled on the
      Probe 718 and Probe 733 headers (bold-lead paragraphs, compile-check line last). Required
      paragraphs:
  - [x] **Title line**: E4 -- `⊡`-saturation on a MIXED-germ mosaic set of the E2 Bool fixture;
        the question Probe 718 left "open for the next round to attack by name".
  - [x] **Which fixture and why**: the E2 fixture `Rg` (`a→a`, `a→b`, `b→b`, `p` at `b`),
        transcribed as `Rg`/`Fg`/`Mg` and never imported (cite `stab-depth-two-probe.lean`,
        `Probe711DepthTwo.stab_will_iff`: `⊡(Fp)` True at `b`, False at `a`); not the
        complete-graph fixture `Rf`, on which `⊡(Fp)` is uniformly False
        (`Probe718FiniteGraph.decide_will`) and no state distinguishes anything.
  - [x] **Outcome: VACUOUS -- decidable because identically true.** `stabSaturated_univ`: the
        landed `Probe718Mosaic.StabSaturated` (re-declared verbatim as `StabSaturated`) holds
        for EVERY finite mosaic set, mixed or not, by `fun _ _ _ hχ m' _ heq => hχ m'.hist
        heq.symm` -- the predicate's own body carries `m'.hist.state t = m.hist.state t`, and
        `⊡χ` at `m` is definitionally `∀ σ, m.state t = σ.state t → χ at σ`
        (`PlusTruth.stab_iff`, `Iff.rfl`). `stabSaturated_of_sameState`'s `hS` was never
        load-bearing. `Smix_mixed` + `Smix_stabSaturated`: a genuinely mixed set on which the
        corner hypothesis fails and the predicate still holds. Say explicitly: this decides
        nothing about R2.
  - [x] **The falsifier is unsatisfiable as stated**: no finite mosaic set, mixed or not, makes
        `StabSaturated` false, so the review's R2 falsifier cannot be instantiated; nothing is
        weakened because there is nothing to record as a refutation. A finding about the
        hypothesis statement, not a null probe result.
  - [x] **The real SH1 content is the witness direction**: `StabWitnessedAt` (Caleiro-Vigano-Volpe
        2013 Def. 3.6 SH1 transcribed to `⊡`: every mosaic refuting `⊡χ` has a same-germ mosaic
        in the SET refuting `χ`). On `Smix = {stayA, jumpB, stayB}` it HOLDS (`Smix_witnessed`);
        on `Sdrop = {jumpB, stayB}` it FAILS (`Sdrop_not_witnessed`: `jumpB` refutes `⊡Fp`,
        `not_stabFp_jumpB`, with `stayA` a same-germ refuter in the MODEL but absent from the
        SET); both sets mixed (`Smix_mixed`, `Sdrop_mixed`). Name the new fixture lemmas
        `succ_of_b` and `stabFp_stayB`.
  - [x] **What the witness direction does and does not decide**: finitely checkable over a
        finite set only once `⊡χ`'s value at each mosaic is known, and on this fixture that
        value is `stab_will_iff` -- R1's forward-reachability summary. A semantic-label mosaic
        set is a consumer of R1's device, not an independent decision procedure.
  - [x] **What this does to R2's standing** (evidence only; ranking is the review's): the
        load-bearing hypothesis as filed was vacuous and must be restated as a SYNTACTIC
        saturated-set existence theorem for L⁺ (points on a finite closure, H1, SH1, plus a
        bespoke `⊡`-fibre/task-relation interaction condition Caleiro does not list); Caleiro
        section 4.3 states that the mosaic decidability argument does not extend once the
        dimensions interact. R2 is neither promoted nor closed; `amalgamate` is semantic and
        its "free" precondition does not carry to the syntactic calculus.
  - [x] **Evidence gap, recorded**: Handbook of Modal Logic ch. 11 sections 5.10 "Mosaics" and
        5.11 "Monodic fragments" remain absent -- publisher preview re-measured 2026-10-09 at 3
        pages, byte-identical to the corpus copy; DOI `10.1016/S1570-2464(07)80014-0` paywalled;
        recorded as a residual gap in `specs/literature-index.json` (`hodkinson_2006`, `hazard`)
        with reactivation condition "institutional access or purchase, or an open release". In-corpus
        stand-ins: Caleiro 2013 (section 5.10), HWZ 2000 (section 5.11).
  - [x] **What this does NOT do**: no complexity claim; no fourth certificate class
        (`Probe710.not_finite_width_fmp` untouched); no promotion of R2 above R1; no syntactic
        mosaic calculus; no edit to `mosaic-germ-amalgamation.lean`.
  - [x] **Axiom record**: the four lines captured in Phase 1, copied verbatim, with the cause
        named (`PlusTruthAt`'s classical semantics and the classical `DecidableEq` on `Mosaic`
        pull `Classical.choice` even into the one-line `stabSaturated_univ`).
  - [x] **Compile-check line**: `lake env lean specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean`.
- [x] Keep the body byte-identical to Phase 1's lift; adjust only a docstring if one still says
      "scratch" or "CLAIM".
- [x] Re-run `timeout 300 lake env lean` on the file; require exit 0, no errors/warnings, four
      axiom lines identical to Phase 1's capture.
- [x] Record an issue-log entry for this phase.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The header's cited declaration names (`stabSaturated_univ`, `Smix_mixed`,
`Smix_stabSaturated`, `Smix_witnessed`, `Sdrop_not_witnessed`, `Sdrop_mixed`, `not_stabFp_jumpB`,
`succ_of_b`, `stabFp_stayB`, and the cross-file `Probe718Mosaic.StabSaturated`,
`Probe718Mosaic.stabSaturated_of_sameState`, `Probe711DepthTwo.stab_will_iff`,
`Probe718FiniteGraph.decide_will`, `Probe710.not_finite_width_fmp`) exist under those names
(in-file names re-derived at plan time from the prototype; cross-file names carried from the
report's "Declaration names re-verified" paragraph, dated this session); confirm each with
`grep -n '^theorem <name>\|^def <name>'` on the relevant file before citing it.

**Tier Justification**: The edit is confined to the opening block comment of one file, and
`lake env lean specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` (~2 s) covers
the one blind spot of a comment-only edit -- an edit that escapes the `/- -/` boundary -- while
the diff read-through confirms every changed hunk lies inside the comment.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` - header block only

**Verification**:
- Diff against the Phase 1 file shows changes only inside the opening `/- ... -/` block (and at
  most docstring wording).
- Header contains, as literal text, the word "VACUOUS", the sentence that the result decides
  nothing about R2, the falsifier-unsatisfiable paragraph, the witness-direction paragraph naming
  `Smix_witnessed` and `Sdrop_not_witnessed`, the R2-standing paragraph, the Handbook
  residual-gap paragraph with the 2026-10-09 re-measurement, the "What this does NOT do"
  paragraph, the axiom record, and the compile-check line.
- `lake env lean` on the file exits 0 with four axiom lines matching Phase 1's capture.

---

### Phase 3: Record the Handbook residual gap in the literature sub-index [COMPLETED]

**Goal**: `specs/literature-index.json`'s `hodkinson_2006` entry carries today's re-measurement
and the user decision, so the acquisition half is a recorded residual gap with its reactivation
condition rather than an unrecorded shortfall. No acquisition is attempted.

**Tasks**:
- [x] Read the current `hodkinson_2006` entry:
      `jq '.entries[] | select(.doc_id == "hodkinson_2006")' specs/literature-index.json`.
      Confirm it still carries the `RESIDUAL GAP (task 389 Phase 8, ...)` `hazard` text.
- [x] Append one sentence block to the END of the existing `hazard` string (never replace the
      existing text), of the shape: `Re-measured 2026-10-09 (task 734): publisher URL
      https://www.csc.liv.ac.uk/~frank/MLHandbook/11.pdf still 3 pages / 51,937 bytes,
      byte-identical to the corpus PDF; no preprint on either author's page; DOI
      10.1016/S1570-2464(07)80014-0 resolves to Elsevier (paywalled). User decision (task 734,
      cycle 4, 2026-10-09): acquisition half stays a residual gap; sections 5.10 "Mosaics" and
      5.11 "Monodic fragments" are the ones R2 needs; in-corpus stand-ins caleiro_2013 (5.10)
      and hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl (5.11). Reactivation
      condition unchanged.` Apply with a `jq` filter of the form
      `(.entries[] | select(.doc_id == "hodkinson_2006") | .hazard) += " ..."` writing to a
      temp file under the scratchpad, then `jq empty` the temp file, then `mv` it into place.
- [x] Confirm the edit touched only that one string: `git diff --stat specs/literature-index.json`
      shows one file, and `git diff specs/literature-index.json | grep -c '^[-+] '` is 2 (one
      removed line, one added line) -- a larger count means `jq` reformatted the file and the
      edit must be redone preserving the existing formatting (`jq --indent 2`, or a targeted
      `python -I` string replacement).
- [x] Record an issue-log entry for this phase (kind `issue`, class `environment` or similar,
      severity `none`, resolution `worked_around`: the external paywall is the blocker; nothing
      to fix locally).

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The sub-index has exactly one `hodkinson_2006` entry and its `hazard`
field begins `RESIDUAL GAP (task 389 Phase 8` (re-derived at plan time with the `jq` select
above); confirm with the same command before editing, and stop if the count is not 1.

**Tier Justification**: `jq empty specs/literature-index.json` plus
`jq -e '.entries[] | select(.doc_id == "hodkinson_2006") | .hazard | test("2026-10-09")'` is the
complete covering check -- the file is data read by the literature scripts, nothing compiles
against it, and a syntactically valid JSON with the one field extended is the whole blast radius.

**Files to modify**:
- `specs/literature-index.json` - `hodkinson_2006.hazard` string extended by one sentence block

**Verification**:
- `jq empty specs/literature-index.json` exits 0.
- `jq -e '[.entries[] | select(.doc_id == "hodkinson_2006")] | length == 1' specs/literature-index.json`
  exits 0, and the entry's `hazard` contains `2026-10-09`, `10.1016/S1570-2464(07)80014-0`, and
  `Reactivation condition unchanged`.
- `git diff specs/literature-index.json` touches exactly one line pair.

---

### Phase 4: Wire into the evidence gate, run the full gate, commit, and return partial with the acquisition blocker named [COMPLETED]

**Goal**: The probe is held in place by `scripts/check-evidence-probes.sh` with the Probe 718
row amended by pointer, the full gate set is green, exactly the declared `file_scope` files are
committed, and the dispatch returns `partial` with the Handbook acquisition as its one named
external blocker so the task rests `[PARTIAL]` per the recorded decision.

**Tasks**:
- [x] Re-read `scripts/check-evidence-probes.sh` immediately before editing (concurrent-sibling
      hazard: 747 declares the script); if the `WIRED` array or the comment table differs from
      the plan-time state (23 `WIRED`, 3 `WIRED_REPO`, last `WIRED` entry
      `seam-gluing-ray-product/b2b-frame-constructor-branching`) in a way that touches the
      insertion point, append after whatever the current last entry is rather than overwrite;
      stop and report only if the mosaic rows themselves have been altered.
- [x] Add `"seam-gluing-ray-product/mosaic-stab-saturated"` as the last string of the
      `WIRED=( ... )` array.
- [x] Add a comment-table row under `# --- WIRED ---` as the last row, in the table's
      two-column wrapped style: `VACUOUS, recorded (E4): the landed Probe 718 StabSaturated
      predicate is identically true on EVERY finite mosaic set, mixed germ states included
      (stabSaturated_univ; Smix_mixed + Smix_stabSaturated on the E2 Bool fixture), so it is
      decidable because constant and the review's literal R2 falsifier is unsatisfiable. The real
      SH1 content is the witness direction (StabWitnessedAt): HOLDS on {stayA, jumpB, stayB},
      FAILS on {jumpB, stayB}, both mixed -- finitely checkable only once the per-mosaic
      ⊡-value is known, which on this fixture is R1's stab_will_iff. Holds in place: R2's
      hypothesis is restated as a SYNTACTIC saturated-set existence theorem with a bespoke
      ⊡-fibre interaction condition (Caleiro 2013 section 4.3: mosaic decidability does not
      transfer once the dimensions interact); R2 neither promoted nor closed; Handbook ch. 11
      sections 5.10-5.11 remain a recorded residual gap (specs/literature-index.json,
      hodkinson_2006). No complexity claim, no certificate class, no edit to the Probe 718
      file.`
- [x] Pointer-only amendment of the Probe 718 row (the comment, not the `.lean` file): replace
      its final clause `left open for the next round to attack by name` with `attacked by name
      and found VACUOUS by the mosaic-stab-saturated entry below`. Skip if the row's wording has
      changed since the plan read.
- [x] `timeout 560 bash scripts/check-evidence-probes.sh` from the repository root (foreground,
      bounded; the full run measured ~1.5 min at plan time); require exit 0 and the PASS summary
      with the wired count one higher than the pre-edit baseline (26 at plan time; expect 27).
- [x] `timeout 300 lake env lean specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean`
      once more; diff the four axiom lines against the header's axiom record (must match
      verbatim).
- [x] `git status --short` and `git diff --stat -- specs/evidence/`: the only `specs/evidence/`
      change is the new probe; `mosaic-germ-amalgamation.lean` is byte-identical to HEAD.
- [x] `bash .claude/scripts/verify-deploy.sh` (the complete gate set, per the `full` tier). If
      backgrounded at all, use `context/patterns/bounded-build-waiter.md`'s idiom verbatim
      (captured `pid=$!`, `kill -0` liveness loop, outer `timeout N`) inside one Bash call;
      never end the turn waiting on a notification.
- [x] Commit through `bash .claude/scripts/git-commit-scoped.sh --message "task 734 phase 4:
      wire mosaic-stab-saturated probe into the evidence gate" --session <session_id> --task 734
      -- <explicit paths>` with exactly the three `file_scope` paths
      (`specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean`,
      `scripts/check-evidence-probes.sh`, `specs/literature-index.json`), the prototype
      (`specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/prototype/mosaic-stab-saturated.proto.lean`),
      and this plan file as the pathspec -- never `git add -A`, `git add .`, a directory
      pathspec, or `git commit -am`. (Phases 1-3 commit their own green sub-steps per the
      Commit-Per-Green-Substep Mandate; this is the phase-closing commit.)
- [x] Return shape: `.return-meta.json` and `.orchestrator-handoff.json` with
      `status: "partial"`, `phases_completed: 4`, `phases_total: 4`, and ONE `blockers[]` entry
      -- `phase: "acquisition half (not a plan phase)"`, `target:
      "specs/literature-index.json#hodkinson_2006"`, `verbatim_goal: "the two Handbook sections
      present in the Literature index with an index entry"`, `what_was_tried:` the research's
      bounded acquisition (publisher URL, both author pages, UWA repository, DOI), and the
      recorded user decision (cycle 4, 2026-10-09) that the half stays a residual gap. Write the
      continuation handoff markdown the wrap-up contract requires for `partial`, whose
      "Immediate Next Action" is "nothing until the reactivation condition (institutional access
      or purchase of Handbook ch. 11 pp. 708-712) is met; then ingest sections 5.10-5.11 and
      re-open". The summary states plainly that all four phases completed and that `[PARTIAL]`
      is the acceptance clause's prescribed resting state, not a shortfall.
- [x] Record an issue-log entry for this phase.

**Timing**: 0.75 hours

**Depends on**: 2, 3

**Verification Tier**: full

**Scope Hypothesis**: Before the edit the gate holds 23 `WIRED` + 3 `WIRED_REPO` = 26 probes and
reports `PASS  all 26 wired probe(s) compile` (re-derived at plan time by counting both arrays and
running the script, rc=0); after the edit expect 27. Confirm at implementation time by running the
script before and after the edit -- a concurrent sibling may have changed the count, in which case
the expectation is "baseline + 1", not literally 27.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - one `WIRED` entry, one comment-table row, the Probe 718
  row's final clause amended by pointer
- `specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` - no planned change;
  re-verified and committed here
- `specs/literature-index.json` - no planned change; committed here

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0; its summary line reports every wired probe
  passing with the count equal to the pre-edit baseline plus one, and a PASS line for
  `seam-gluing-ray-product/mosaic-stab-saturated`.
- `lake env lean specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` exits 0;
  its four axiom lines equal the header's axiom record.
- `git diff HEAD --stat -- specs/evidence/seam-gluing-ray-product/mosaic-germ-amalgamation.lean`
  is empty (Probe 718 untouched); no other wired probe `.lean` file is modified.
- `bash .claude/scripts/verify-deploy.sh` exits 0.
- The phase commit contains exactly the three `file_scope` paths, the prototype, and the plan
  file (`git show --stat HEAD`).
- `.orchestrator-handoff.json` validates (`status: "partial"`, `phases_completed: 4`,
  `phases_total: 4`, one blocker, non-empty `summary`), and the continuation handoff markdown
  exists at `continuation_path`.

## Lean Challenge Statements

```lean
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula

namespace Probe734Mosaic

variable {F : TaskFrame} {t : F.Duration}

/-- A **mosaic** at germ time `t`: a possible world, marked at `t` (re-declared verbatim from
`mosaic-germ-amalgamation.lean`; probes never import each other). -/
@[ext]
structure Mosaic (F : TaskFrame) (t : F.Duration) where
  hist : WorldHistory F

/-- The landed `Probe718Mosaic.StabSaturated` predicate, verbatim. -/
def StabSaturated (M : TaskModel F) (S : Finset (Mosaic F t)) : Prop := sorry

/-- **Vacuity.** The landed predicate holds for EVERY finite mosaic set, mixed germ states or
not. -/
theorem stabSaturated_univ (M : TaskModel F) (S : Finset (Mosaic F t)) : StabSaturated M S := sorry

/-- The witness-direction (SH1 / diamond) saturation at one formula `χ`: every mosaic refuting
`⊡χ` has a same-germ witness in `S` refuting `χ`. -/
def StabWitnessedAt (M : TaskModel F) (χ : PlusFormula) (S : Finset (Mosaic F t)) : Prop := sorry

/-! ## The E2 fixture (`a→a`, `a→b`, `b→b`, `p` at `b`), transcribed -/

/-- The step relation. Declared as an `abbrev` with its real body so that `Fg.toTaskFrame.WorldState`
reduces to `ℤ × Bool` and the statements below type-check as the probe states them; `Rg` is
scaffolding, not a pinned identifier (the snapshot regex matches `theorem|lemma|def|instance`
only). The landed probe keeps `def Rg`. -/
abbrev Rg : ℤ → Bool → Bool → Prop := fun _ u v => u = false ∨ v = true
theorem Rg_fwd : ∀ (t : ℤ) (w : Bool), ∃ u, Rg t w u := sorry
theorem Rg_bwd : ∀ (t : ℤ) (w : Bool), ∃ v, Rg (t - 1) v w := sorry
/-- Scaffolding (`abbrev`, real body), as for `Rg`. -/
abbrev Fg : FrameOver intOrder := FrameOver.ofSlicedStep Rg Rg_fwd Rg_bwd
instance : Fg.IsRegular := FrameOver.ofSlicedStep_isRegular Rg Rg_fwd Rg_bwd
/-- Scaffolding. -/
abbrev pa : Atom := ⟨"p", none⟩
/-- The model: `p` holds exactly at state `b`. -/
def Mg : TaskModel Fg.toTaskFrame := sorry
/-- Scaffolding: the formula under test, `Fp`. -/
abbrev Fp : PlusFormula := someFuture (.atom pa)

/-- The history through `(c, a)` at `t` that stays at `a`. -/
noncomputable def stayA (c t : ℤ) : WorldHistory Fg.toTaskFrame := sorry
theorem stayA_state (c t z : ℤ) : (stayA c t).state z = (z + (c - t), false) := sorry
theorem stayA_state_t (c t : ℤ) : (stayA c t).state t = (c, false) := sorry

/-- The history through `(c, b)` at `t` that stays at `b`. -/
noncomputable def stayB (c t : ℤ) : WorldHistory Fg.toTaskFrame := sorry
theorem stayB_state (c t z : ℤ) : (stayB c t).state z = (z + (c - t), true) := sorry
theorem stayB_state_t (c t : ℤ) : (stayB c t).state t = (c, true) := sorry

/-- The history at `a` through `t` and at `b` from `t + 1`. -/
noncomputable def jumpB (c t : ℤ) : WorldHistory Fg.toTaskFrame := sorry
theorem jumpB_state (c t z : ℤ) : (jumpB c t).state z = (z + (c - t), decide (t < z)) := sorry
theorem jumpB_state_t (c t : ℤ) : (jumpB c t).state t = (c, false) := sorry
theorem jumpB_state_succ (c t : ℤ) : ((jumpB c t).state (t + 1)).2 = true := sorry

theorem not_Fp_stayA (c t : ℤ) : ¬ PlusTruthAt Mg (stayA c t) t Fp := sorry
theorem Fp_jumpB (c t : ℤ) : PlusTruthAt Mg (jumpB c t) t Fp := sorry
/-- `⊡Fp` fails at `jumpB` (germ state `a`): `stayA` is a same-germ refuter in the MODEL. -/
theorem not_stabFp_jumpB (c t : ℤ) : ¬ PlusTruthAt Mg (jumpB c t) t (.stab Fp) := sorry
/-- From `b` only `b`. -/
theorem succ_of_b (τ : WorldHistory Fg.toTaskFrame) (t : ℤ) (hb : (τ.state t).2 = true) :
    (τ.state (t + 1)).2 = true := sorry
/-- `⊡Fp` holds at `stayB` (germ state `b`). -/
theorem stabFp_stayB (c t : ℤ) : PlusTruthAt Mg (stayB c t) t (.stab Fp) := sorry

/-! ## The mixed-germ sets -/

/-- Mosaics wrap possible worlds, which carry no decidable equality; the finite sets are classical. -/
noncomputable instance instDecEqMosaic (t : ℤ) : DecidableEq (Mosaic Fg.toTaskFrame t) :=
  Classical.decEq _

/-- The three-mosaic MIXED set: two `a`-germ mosaics and one `b`-germ mosaic. -/
noncomputable def Smix (c t : ℤ) : Finset (Mosaic Fg.toTaskFrame t) := sorry
/-- The two-mosaic MIXED set with the `a`-germ refuter of `Fp` removed. -/
noncomputable def Sdrop (c t : ℤ) : Finset (Mosaic Fg.toTaskFrame t) := sorry

/-- `Smix` is genuinely mixed: the landed corner hypothesis FAILS on it. -/
theorem Smix_mixed (c t : ℤ) :
    ¬ ∀ m ∈ Smix c t, ∀ m' ∈ Smix c t, m.hist.state t = m'.hist.state t := sorry
/-- ... and yet the landed predicate holds on it, by the universal theorem. -/
theorem Smix_stabSaturated (c t : ℤ) : StabSaturated Mg (Smix c t) := sorry
/-- The witness-direction saturation at `Fp` HOLDS on `Smix`. -/
theorem Smix_witnessed (c t : ℤ) : StabWitnessedAt Mg Fp (Smix c t) := sorry
/-- The witness-direction saturation at `Fp` FAILS on `Sdrop`, a mixed set of genuine possible
worlds: `jumpB` refutes `⊡Fp` at germ `a`, and its only same-germ companion in the SET is itself,
where `Fp` holds. -/
theorem Sdrop_not_witnessed (c t : ℤ) : ¬ StabWitnessedAt Mg Fp (Sdrop c t) := sorry
/-- `Sdrop` is genuinely mixed. -/
theorem Sdrop_mixed (c t : ℤ) :
    ¬ ∀ m ∈ Sdrop c t, ∀ m' ∈ Sdrop c t, m.hist.state t = m'.hist.state t := sorry

end Probe734Mosaic
```

## Testing & Validation

- [x] `lake env lean specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` exits 0
      with no errors or warnings and exactly four `#print axioms` output lines (after Phases 1,
      2, and 4).
- [x] Axiom record: `stabSaturated_univ`, `Smix_mixed`, `Smix_witnessed`, `Sdrop_not_witnessed`
      each at `[propext, Classical.choice, Quot.sound]`; no `sorryAx` anywhere.
- [x] `grep -c sorry specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` is 0.
- [x] `bash scripts/check-evidence-probes.sh` exits 0 with the wired count at baseline + 1 and a
      PASS line for the new entry; `mosaic-germ-amalgamation.lean` byte-identical to HEAD.
- [x] `jq empty specs/literature-index.json` exits 0 and the `hodkinson_2006.hazard` string
      contains the 2026-10-09 re-measurement and the user decision.
- [x] `bash .claude/scripts/verify-deploy.sh` exits 0 (Phase 4).
- [x] The Challenge block above type-checks standalone against `FormalSystem` (re-derived at
      plan time: rc=0, `declaration uses sorry` warnings only) and its 29 pinned identifiers
      equal the `**Goals**:` identifier set.
- [x] Return metadata: `status: "partial"` with one acquisition blocker; `phases_completed` =
      `phases_total` = 4; continuation handoff markdown present.

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` -- the E4 probe (new,
  wired, sorry-free, namespace `Probe734Mosaic`)
- `scripts/check-evidence-probes.sh` -- one `WIRED` entry, one table row, Probe 718 row
  amended by pointer
- `specs/literature-index.json` -- `hodkinson_2006.hazard` extended with the 2026-10-09
  re-measurement and the recorded user decision
- `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/prototype/mosaic-stab-saturated.proto.lean`
  -- the research scratch, lift-ready (committed with Phase 4)
- `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/summaries/01_e4-stabsaturated-mixed-germ-probe-summary.md`
  -- implementation summary, stating the `[PARTIAL]` resting state and its cause
- Continuation handoff markdown at the path the handoff's `continuation_path` names

## Rollback/Contingency

- The probe and the gate wiring are additive: if the probe fails to compile at Phase 4 after
  passing at Phase 1 (citation drift from a concurrent change to `FormalSystem`), fix forward
  in the probe -- never weaken a statement; if a statement genuinely no longer holds, say so in
  the header and leave the entry wired red with the reason, per the gate's own failure banner.
- If the gate script was concurrently modified at the insertion point, re-base the two edits on
  the current file by hand (they are a one-string append and a one-row append); do not revert
  the sibling's change.
- If `specs/literature-index.json` is left invalid, restore it from HEAD with
  `git checkout -- specs/literature-index.json` only after a snapshot per
  `context/contracts/recovery.md`'s rollback rung, then redo Phase 3 with the formatting-preserving
  path.
- A genuine whole-tree rollback (not expected) follows `context/contracts/recovery.md`'s
  rollback rung; an ordinary defensive checkpoint before Phase 4's commit is
  `bash .claude/scripts/git-snapshot.sh 734 --no-revert`.
