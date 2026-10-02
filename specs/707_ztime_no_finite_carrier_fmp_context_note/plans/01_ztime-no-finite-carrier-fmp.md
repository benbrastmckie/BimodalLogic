# Implementation Plan: Task #707

- **Task**: 707 - Z-time no-finite-carrier FMP context note (with the finite-width second section)
- **Status**: [COMPLETED]
- **Effort**: 6 hours
- **Dependencies**: None blocking. Inputs are all on disk: the 706 probe, the 710 probe, the 703 round-2 report, the five literature entries, and this task's research report.
- **Research Inputs**: specs/707_ztime_no_finite_carrier_fmp_context_note/reports/01_ztime-no-finite-carrier-fmp.md
- **Artifacts**: plans/01_ztime-no-finite-carrier-fmp.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Write one context note, `ztime-no-finite-carrier-fmp.md`, into the formal extension's
**source store** (never under `.claude/`), register it in that extension's `index-entries.json`
and logic README, redeploy, and lint it for task-number references. The note records two
machine-checked refutations and the design rule they imply: (1) the finite-CARRIER finite model
property fails for L and L⁺ over ℤ-time (probe `Probe706`, witness `θ`), so a ℤ-time certificate
class must present an infinite, finitely presented carrier; and (2) — the dispatch's STATUS NOTE,
which the research report predates — that rule is NECESSARY BUT NOT SUFFICIENT, because the
finite-WIDTH property also fails (probe `Probe710`, witness `Φ`): no class presenting finite
per-time fibres is complete for L⁺, or even for its CTL-like fragment. Around these the note
carries the published counterpart (GKWZ "repeating finite pieces", HWZ quasimodels), the
explicit warning that FMP failure is not undecidability (Krommes 2020, GKWZ 5.28/5.32), the
time-sliced-graph diagnosis, and fidelity labels for every source. No Lean work: the probes are
cited, not landed or modified.

### Research Integration

The research report (Stage 2 input) settled everything the plan would otherwise have to guess:

- **Source status (F1, F2)**: `specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`
  is sorry-free with axioms `[propext, Classical.choice, Quot.sound]`; none of its seven
  declarations are landed under `FormalSystem/`, so the note cites the probe (D2). The L-side
  twin is the archived `Probe476.fmp_false`.
- **Landed embodiment (F3, D3)**: `FrameOver.ofSlicedStep` on `ℤ × Fin n`,
  `FrameOver.ofSlicedStep_not_finite_worldState` / `PlusSlicedCertificate.frame_worldState_not_finite`,
  `TaskFrame.saturation_of_fib_finite` (`Semantics/TaskFrame.lean:2222`),
  `TaskFrame.limit_of_succOrder` (`TaskFrame.lean:1591`); `FrameOver.ofStep`
  (`Semantics/IntNormalForm.lean:456`) requires `[Finite W]`.
- **Pumping ingredients (F4)**: `FrameOver.mem_HF_iff_adjacent` (`IntNormalForm.lean:348`),
  `FrameOver.worldHistoryOfStepPath` (`:323`), `Finite.exists_ne_map_eq_of_infinite`,
  `plusBox_const`, `ShiftSet.total_eq_orbit`.
- **GKWZ verification discharged (F9, D1)**: Theorem 5.28 printed p. 244 (coN2EXPTIME for
  `L × S5`, corollary of 5.27's 2-exponential *abstract* fmp); Theorem 5.32 printed p. 246
  (`Log C × L` lacks the *product* fmp); pp. 234/236 "repeating finite pieces". The 5.32 proof
  formula is OCR-garbled and must not be transcribed (Rec. 4). Page numbers may be cited without
  re-verification.
- **Literature readings (F7, F8, F10-F12)** with fidelity labels and the exact nuance for
  each: HWZ correspondence table is "correspondence, not identity"; HVV 2004 is cited for its
  §2/Table 1 summary of Halpern-Vardi 1989, not as the origin; HKKM 2019 with the
  not-a-product caveat; GKWZ Chapter 11 was in the corpus the whole time.
- **Mechanics (F14-F17)**: source-store path, `index-entries.json` entry shape (copy of the
  `frame-constraint-landscape.md` entry), README line form, `deploy-headless.sh`, the
  task-reference lint (`specs/NNN_...` *paths* pass; "task N" phrasing does not), house style
  (`frame-constraint-landscape.md` as the model: H1, purpose paragraph, fully qualified Lean
  names, tables keyed by machine-checked witness, no frontmatter).

**What the report does not cover and this plan adds from the dispatch's STATUS NOTE**: the
finite-width section. Verified this round directly against
`specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean`
(1180 lines, `grep -c sorry` = 0, `#print axioms` on the four closing theorems): the witness
`Φ := θ' ∧ □(⊡Fp → ¬⊡¬Xp)` with `Xp := ⊥ U p`; declarations `Probe710.not_plusValidZTime_neg_Φ`,
`no_finite_width_sat`, `not_certifies`, `not_sliced_complete`, `not_finite_width_fmp`; the
positive-half frame on `Node = {pre k} ∪ {x k} ∪ {post k j}`; and the negative-half sketch in
the probe's header (pre/post trichotomy, `D` forces `p` states at every time `≤ a`, a post state
has no infinite backward post-path, finitely many predecessors bounds backward post-chains by
König, forward post-chains from `p` states at times `a - n - 1` give backward post-chains of every
length at time `a`, pigeonhole on the finite fibre at `a`).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided; `specs/ROADMAP.md` was not consulted.

## Goals & Non-Goals

**Goals**:
- A single durable note at
  `/home/benjamin/.config/nvim/agent-system/extensions/formal/context/project/logic/domain/ztime-no-finite-carrier-fmp.md`
  that a certificate-design round will actually read, carrying both refutations (carrier and
  width), the strengthened design rule, the landed embodiment, the published counterpart, and
  the "not undecidability" warning.
- Registration so the note is discoverable: one `index-entries.json` entry loaded for
  `logic-research-agent` / `formal-research-agent` on `logic` / `formal` task types, and one
  README line under "Domain Files".
- The deployed copy appears at `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md`
  after `deploy-headless.sh`.
- Zero "task N" references in the note (lint passes); every cited Lean name resolves by grep.

**Non-Goals**:
- No Lean work: no landing of `Probe706`/`Probe710` theorems, no probe edits, no probe
  compilation beyond the optional spot-check named in Phase 2.
- No `limit-closure-and-fairness.md` (separate follow-up, Rec. 6); the note cross-references the
  gap only.
- No complexity claim for this logic (Rec. 5): Krommes's EXPSPACE result is about `K4 × S5`.
- No transcription of GKWZ's 5.32 proof formula (Rec. 4).
- No successor-class design: the note records that a successor class must present infinite
  fibres and that no checker precedent exists; it does not propose one.
- No hand-edits under `.claude/**` (deploy boundary rule); no edits to any file in sibling
  704's or 710's declared `file_scope`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Note written under `.claude/context/...` and wiped at the next deploy (research R1) | H | L | Phase 1 names the absolute source-store path verbatim; Phase 5 verifies the deployed copy is *generated*, not hand-placed |
| Sibling 708 (undeclared scope) or a foreign process edits the formal `index-entries.json` or the `~/.config/nvim` tree concurrently (R2; the tree is already dirty with sibling edits to core/lean/typst `index-entries.json`) | M | M | Re-read `index-entries.json` and README immediately before each edit; targeted append of one entry; stage only the three source-store paths by explicit name; never `git add` a directory or `-A`; never `git-snapshot.sh` in reverting mode |
| "task N" phrasing slips in from the dispatch text or the probe headers (both say "task 706's") and the write-time hook or lint blocks the commit (R3) | L | M | Paraphrase as "the earlier certificate-design round" or cite the `specs/...` path; run `check-task-references.sh` on the note before Phase 5's commit |
| HWZ quasimodel overstated as identical to the sliced certificate (R4) | M | M | Carry the F7 correspondence table with the "correspondence, not identity" caveat; say HWZ is first-order temporal with no `□`/`⊡` |
| The finite-width section misstates the probe's argument or theorem shapes | M | L | Phase 2 transcribes statement shapes from the probe's closing declarations (lines 1105-1172) and the argument order from its header; cites `lake env lean <path>` as the compile command |
| The two obstructions (carrier size vs. width) and the third (all-threads fulfilment) are conflated | M | M | Phase 3 writes one sentence per obstruction with its witness, its probe/landed theorem, and what repaired it (or did not) |
| Deploy regenerates `.claude/` while another dispatch reads it (R6) | L | L | Deploy once, at the end of Phase 5, after the three source files are committed |
| Writing outside the BimodalLogic working tree (the source store is `~/.config/nvim`) is refused by the harness | M | L | Precedent exists (`frame-constraint-landscape.md` was landed the same way); if the write is refused, stop and report `blocked` with the path rather than falling back to `.claude/` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases are strictly sequential: Phases 1-4 edit the same file in section order, and Phase 5
registers and deploys the finished note. Nothing runs in parallel.

### Phase 1: Draft the core sections (the carrier refutation and the design rule) [COMPLETED]

**Goal**: Create the note in the source store with its header and sections 1-5: the fact, the
machine-checked source, the pumping argument, why it is the certificate TYPE and not a bound, and
the design rule with its landed embodiment.

**Tasks**:
- [x] Create `ztime-no-finite-carrier-fmp.md` at the absolute source-store path below, in the
  house style of `frame-constraint-landscape.md` (H1 title, one-paragraph purpose stating the
  never-rediscover-it intent, no frontmatter, fully qualified Lean names in code spans,
  "sentence letter" not "propositional atom"). *(completed)*
- [x] Section *The fact*: `θ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` is a ℤ-time non-validity of L and
  L⁺ (`θ.neg`) with no countermodel on any regular ℤ-frame with a finite carrier; the
  stability-modal-free reading ("every history meets `p`, and never twice from the left"); the
  CTL-like-fragment variant `θ' := □(p ∨ ⊡Fp ∨ ⊡Pp) ∧ □(p → ⊡¬Pp)`; primitive-syntax forms from
  the 706 report's appendix. *(completed)*
- [x] Section *The machine-checked source*: probe path, compile command (`lake env lean
  specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean` from
  the repository root), the seven declaration names in a table (`θ_eq_ofFormula`,
  `not_plusValidZTime_neg_θ`, `no_finite_carrier_sat`, `no_ofStep_sat`, `not_finite_carrier_fmp`,
  and the three `θ'` variants), the axiom list, the archived L-side twin `Probe476.fmp_false`
  (`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`),
  and one sentence that these are probe-level, not library-level, so the note is to be updated
  when they land. *(completed)*
- [x] Section *The pumping argument*, in the probe's order: `□` is history- and
  time-independent by `plusBox_const`, so A says every history meets `p` somewhere and C says a
  `p`-time has no earlier `p`-time on the same history; the target history meets `p` at some
  `a`, so every earlier time on it is `p`-free; pigeonhole via
  `Finite.exists_ne_map_eq_of_infinite` on the states before `a`; the resulting cycle is a
  bi-infinite step path, hence a history by `FrameOver.mem_HF_iff_adjacent` /
  `FrameOver.worldHistoryOfStepPath`, and never meets `p`, contradicting A. Positive half:
  `ShiftSet` on carrier `ℤ`, `p` at `0` only; `ShiftSet.total_eq_orbit` for the `⊡` collapse. *(completed)*
- [x] Section *Why this is the certificate type, not a bound*: `FrameOver.ofStep`
  (`FormalSystem/Semantics/IntNormalForm.lean`) requires `[Finite W]` and routes Saturation
  through `saturation_of_finite`; `no_ofStep_sat` has no `n`; no checker clause and no liveness
  formulation repairs it. *(completed)*
- [x] Section *The design rule and its landed embodiment*: the rule in capitals as the dispatch
  states it (infinite, finitely presented carrier, `ℤ × Fin n` with finite fibres, never a
  finite one via `FrameOver.ofStep`), immediately followed by the "necessary, not sufficient"
  forward reference to the finite-width section; then `FrameOver.ofSlicedStep`,
  `FrameOver.ofSlicedStep_not_finite_worldState` / `PlusSlicedCertificate.frame_worldState_not_finite`,
  `TaskFrame.saturation_of_fib_finite`, `TaskFrame.limit_of_succOrder`,
  `PlusSlicedCertificate/Sound.lean`'s prose statement of the obstruction, and the two
  `docs/theorem-index.md` rows (`not_exists_plusCertifies_pumpTarget`,
  `WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`). *(completed)*
- [x] Cite reports only by `specs/...` path; never write "task N". *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The finished note is expected to run 200-280 lines (the research estimated
150-220 before the finite-width section was added). Confirm with `wc -l` at the end of Phase 4;
a note under 150 or over 350 lines is a signal to re-check that nothing was dropped or padded.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/formal/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` - create; header plus sections 1-5

**Verification**:
- The file exists at the source-store path and NOT at `.claude/context/project/logic/domain/`.
- Every Lean name cited in sections 2-5 resolves: `grep -rn "<name>" FormalSystem/ specs/706_*/probes/ specs/archive/476_*/evidence/` returns a declaration for each.
- `grep -n -i "task [0-9]" <note>` returns nothing.

---

### Phase 2: The finite-width section ("finite width fails too") [COMPLETED]

**Goal**: Add the second machine-checked refutation, from the 710 probe, and state the
strengthened rule so that the carrier rule is never recorded alone.

**Tasks**:
- [x] Re-read the probe's header (lines 1-41) and closing declarations (lines 1105-1172) of
  `specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean`
  immediately before writing; transcribe statement shapes, not the proofs. *(completed)*
- [x] Section *Finite width fails too*: the witness `Φ := θ' ∧ □(⊡Fp → ¬⊡¬Xp)` with
  `Xp := ⊥ U p`, in the CTL-like fragment; the reading of the new conjunct (at every *pre*
  state, some history reaches `p` at the very next time). *(completed)*
- [x] The declarations, in a table: `Probe710.not_plusValidZTime_neg_Φ` (positive half, on a
  countable, finitely branching, time-homogeneous frame with carrier
  `Node = {pre k} ∪ {x k} ∪ {post k j}`); `no_finite_width_sat` (no model on
  `FrameOver.ofSlicedStep R fwd bwd` with `[Finite W]` satisfies `Φ` anywhere);
  `not_certifies` (no `PlusSlicedCertificate [] [Φ.neg]` certifies); `not_sliced_complete` (the
  time-sliced class is incomplete for L⁺); `not_finite_width_fmp` (no class presenting finite
  per-time fibres is complete, whatever its clauses). Axioms `[propext, Classical.choice,
  Quot.sound]`, zero `sorry`, compile command `lake env lean <probe path>`. *(completed)*
- [x] The argument sketch in the probe's order: every state is `p`, *pre*, or *post*;
  predecessors of a `p` state are pre, so `D` forces `p` states at every time `≤ a`; successors
  of `p` or post states are post; a post state has no infinite backward post-path (pasted with
  any forward path it is a `p`-free history, contradicting A'); with finitely many predecessors
  per state, backward post-chains into any post state are bounded (König); but forward
  post-chains from the `p` states at times `a - n - 1` reach time `a` as backward post-chains of
  every length `n`, and the fibre at `a` is finite — pigeonhole. *(completed)*
- [x] One paragraph contrasting the two obstructions: the carrier failure is about the SIZE of
  the carrier (a finite graph can never host a countermodel to `θ.neg`); the width failure is
  about limit closure plus finite FIBRES (a countermodel to `Φ.neg` can be countable and finitely
  branching, as the positive half shows, but must have infinitely many states at some time).
  The second is strictly stronger for certificate design: `ℤ × Fin n` satisfies the carrier rule
  and still fails. *(completed)*
- [x] The strengthened rule, in capitals: a ℤ-time certificate class must present an infinite,
  finitely presented carrier AND, if its per-time fibres are finite, it is still incomplete for
  any target carrying `⊡` (`stab`); a successor class must present INFINITE fibres (root paths of
  a finite class graph), for which no checker precedent exists. Record that the stab-free
  flagship is unaffected and that decidability of full L⁺ ℤ-time validity does not follow by the
  sliced route. *(completed)*
- [x] Add the back-reference from the Phase 1 design-rule section (the "necessary, not
  sufficient" sentence) if it was left as a placeholder. *(completed)*
- [ ] Optional spot-check, only if time permits and no build is already running on the tree
  (territory note): `lake env lean specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean`
  from the repository root, expecting four `#print axioms` lines and no `sorry` warning. Do not
  treat a failure as this task's regression; report it. *(deviation: skipped — the operator forbids Lean builds in this dispatch; the probe is cited, not compiled)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: prose

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/formal/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` - append the finite-width section; patch the forward reference in the design-rule section

**Verification**:
- All five `Probe710` names and the `Node` constructor names appear verbatim in the probe (`grep -n` each).
- The section states both rules (carrier and width) and names the carrier rule as necessary but not sufficient.
- No "task N" phrasing (the probe header's "task 706's" must not be copied).

---

### Phase 3: ℤ-time semantics as a time-sliced graph semantics [COMPLETED]

**Goal**: Fold in the earlier round's graph-semantics recommendation with the sliced
correction, and keep the three obstructions apart.

**Tasks**:
- [x] Section *ℤ-time semantics as a time-sliced graph semantics*: state S1-S5 from
  `specs/703_lplus_compression_and_completeness/reports/02_semantics-first-compression-research.md`
  §1.1 as TRUE, time-homogeneous facts (histories are the step paths; shift invariance; `⊡` is
  state-determined; fusion and limit closure; type-preserving pasting), with the landed names
  the round cited (`FrameOver.mem_HF_iff_adjacent`, `FrameOver.ofStep`, `plusTruthAt_timeShift`,
  `stab_state_only`, `paste`) — confirm each by grep before citing. *(completed)*
- [x] The diagnosis: that round's "period one and no time origin" is exactly what `θ` forbids;
  a countermodel to `θ.neg` must have a time at which something happens once, so its state space
  cannot be time-homogeneous and finite; the graph must be TIME-SLICED, not time-homogeneous. *(completed)*
- [x] One sentence each for the three distinct obstructions, with witness and what answered it:
  carrier size (`θ`, `no_ofStep_sat`; answered by `ℤ × Fin n`); all-threads fulfilment (the
  sharing-class pumping, `not_exists_plusCertifies_pumpTarget`; answered by liveness-as-fixpoint,
  see `PlusSlicedCertificate.lean`'s header); finite width (`Φ`, `not_finite_width_fmp`; NOT
  answered by any landed class). *(completed)*
- [x] Cross-reference the still-missing `limit-closure-and-fairness.md` as a gap, citing
  `PlusWitnessFamily/Limits/NoCertificate.lean` as where that note would start. *(completed)*

**Timing**: 45 minutes

**Depends on**: 2

**Verification Tier**: prose

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/formal/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` - append the time-sliced section

**Verification**:
- Each of the five S-facts is marked as true and as time-homogeneous; the diagnosis sentence names what `θ` adds.
- Three obstructions, three witnesses, three statuses, no conflation.
- Every cited Lean name resolves by grep under `FormalSystem/`.

---

### Phase 4: Published counterpart, the "not undecidability" warning, secondary literature, fidelity labels [COMPLETED]

**Goal**: Name the published construction that satisfies the rule, record that FMP failure is
not an undecidability result, record that the technique was in the corpus the whole time, and
label every source's fidelity.

**Tasks**:
- [x] Section *The published counterpart*: GKWZ 2003 printed pp. 234 and 236, the two
  "repeating finite pieces" sentences quoted as the research report gives them, labelled
  **[verified-pdf]**; HWZ 2000's quasimodel over `⟨ℤ, <⟩` as the concrete form, with the
  correspondence table (type / state candidate / state function / run / quasimodel / splice
  Lemma 17 / bounded realisation Lemma 21 / ultimately periodic form Lemma 23, Theorem 24, each
  with its Definition number and the sliced-certificate counterpart: fibre, per-slice labelling,
  target path, time-sliced certificate, the pumping/splice, tail stability) and the caveat
  "correspondence, not identity: HWZ's object is first-order temporal and has no `□`/`⊡`";
  HWZ's three decidability routes, with the MSO/Büchi route noted as needing no Safra
  construction; GKWZ Chapter 11 (§11.3 K-quasimodel and Lemma 11.22, Theorem 11.21; §11.4
  periodic state functions, Lemmas 11.27/11.29 = HWZ Lemmas 17/21; §13.2 Theorem 13.6 for
  PTL × S5) as the book form, with the diagnosis that it was ingested 2026-08-18 and never read
  for this purpose. *(completed)*
- [x] Section *FMP failure is not undecidability*: Krommes 2020 Theorem 1.1 (`K4 × S5`,
  `S4 × S5`, SSL are EXPSPACE-complete) alongside its own sentence that both lack the finite
  product model property [GKWZ Thm 5.32] but are decidable, in coN2EXPTIME [GKWZ Thm 5.28];
  GKWZ Theorem 5.32 (printed p. 246) and 5.28 (printed p. 244) stated as the research verified
  them; the product-vs-abstract fmp distinction (5.32 loses product fmp, 5.27 keeps abstract fmp,
  5.28's bound comes from 5.27); why the abstract-fmp retreat is unavailable here
  (`PlusValidZTime` ranges over regular ℤ-frames only); "structurally the same trick" for the
  5.32 countermodel, no more; the three wrong readings (a large enough `n` will do; decidability
  is hopeless; retreat to an abstract fmp). Do NOT state a complexity for this logic. Do NOT
  transcribe the 5.32 proof formula; cite Figure 5.9's caption. *(completed)*
- [x] Section *Secondary literature*: HVV 2004 §2 / Table 1 as a summary of Halpern-Vardi 1989
  (S5-like modality over a discrete linear flow; perfect-recall / no-learning as the knob from
  PSPACE to non-r.e.; HVV's own contribution is axiomatizability); HKKM 2019 (Diff × Diff
  non-finitely axiomatisable but axiomatisable by infinitely many Sahlqvist axioms) as "what an
  axiomatisation of a product-like system can look like", in the same sentence that this logic
  is not a product (GKWZ product quasimodels presuppose commutativity and Church-Rosser, which
  the stability modal lacks). *(completed)*
- [x] Section *Sources and fidelity*: a table of the five documents with corpus id, what was
  read, and label — GKWZ **[verified-pdf]** for 5.27/5.28/5.32 and pp. 234/236, otherwise
  **[literature]** (`unverified_conversion`); HWZ, Krommes, HVV, HKKM **[literature]**
  (`unverified_conversion`); the probes **[checked]**; the archived twin **[archived]**. Name
  the verification recipe (`pdftotext -layout` on the staging PDF named by the global
  `metadata.json`) in one line so the next reader can repeat it. *(completed)*
- [x] Confirm `wc -l` against Phase 1's scope hypothesis; record the count for Phase 5's
  `line_count`. *(completed)*

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: prose

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/formal/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` - append sections 6-10

**Verification**:
- Both GKWZ theorem numbers appear with their printed page numbers; no formula from the 5.32 proof appears.
- The note contains no complexity bound attributed to this logic.
- Every one of the five literature sources carries a fidelity label.
- `bash .claude/scripts/check-task-references.sh <note path>` passes.

---

### Phase 5: Register, lint, commit in the source store, deploy, verify [COMPLETED]

**Goal**: Make the note discoverable and deployed, with concurrency-safe edits and staging.

**Tasks**:
- [x] Re-read `/home/benjamin/.config/nvim/agent-system/extensions/formal/index-entries.json`
  immediately before editing (sibling 708 has no declared scope; the `~/.config/nvim` tree is
  already dirty with other extensions' `index-entries.json` edits). Append ONE entry to its
  `entries` array, shaped exactly like the `frame-constraint-landscape.md` entry:
  `path: "project/logic/domain/ztime-no-finite-carrier-fmp.md"`, a one-sentence `summary`
  naming both refutations and the rule, `category: "domain"`, `line_count` from Phase 4,
  `load_when.agents: ["logic-research-agent", "formal-research-agent"]`,
  `load_when.task_types: ["logic", "formal"]`, `domain: "project"`, `subdomain: "logic"`,
  `topics` (e.g. `ztime`, `finite-model-property`, `finite-carrier`, `finite-width`,
  `sliced-certificate`, `quasimodel`, `koenig`). Validate with `python3 -m json.tool` or `jq .`. *(completed)*
- [x] Re-read `/home/benjamin/.config/nvim/agent-system/extensions/formal/context/project/logic/README.md`
  immediately before editing; add one line under "Domain Files" in the form of the
  `frame-constraint-landscape.md` line. *(completed)*
- [x] Run `bash .claude/scripts/check-task-references.sh` on the note and on the README; fix
  any hit by paraphrase or path citation. *(completed)*
- [x] In the source-store repository (`/home/benjamin/.config/nvim`), `git status --short` to
  see the foreign dirt, then stage ONLY the three files by explicit path
  (`git add -- <note> <index-entries.json> <README>`), review `git diff --staged`, and commit
  with a message naming the note (precedent: "Add lean, logic and literature context docs
  written from consumer-repo work"). Never `git add -A`, a directory, or `-am`; never
  `git-snapshot.sh` in reverting mode. *(completed)*
- [x] Deploy once: `bash .claude/scripts/deploy-headless.sh` from the BimodalLogic root (the
  dispatch's deploy-freshness context already reports `core` and `memory` stale, so a full
  redeploy is due regardless). *(completed)*
- [x] Verify the deployed copy: `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md`
  exists and is byte-identical to the source (`cmp`); the entry appears in
  `.claude/context/index.json` (`grep ztime-no-finite-carrier-fmp`); the README line appears in
  the deployed README. *(completed)*
- [x] In the BimodalLogic repository, nothing under `.claude/` is to be committed (gitignored
  deploy artifact); the task's own commit covers `specs/707_.../` artifacts only, via the
  sanctioned scoped-commit path. *(completed)*

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: Exactly three source-store files are touched (note, `index-entries.json`,
logic `README.md`) and zero files under `.claude/**` are hand-edited. Confirm with
`git -C /home/benjamin/.config/nvim status --short` before staging: only those three paths should
be this task's; any other modification is a sibling's and is left alone.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/formal/index-entries.json` - append one entry
- `/home/benjamin/.config/nvim/agent-system/extensions/formal/context/project/logic/README.md` - one line under "Domain Files"
- `/home/benjamin/.config/nvim/agent-system/extensions/formal/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` - final lint fixes only

**Verification**:
- `index-entries.json` parses; the new entry's `line_count` equals `wc -l` of the note.
- `check-task-references.sh` passes on the note and the README.
- Source-store commit contains exactly the three paths.
- Deployed copy is byte-identical to the source; `index.json` carries the entry.

## Testing & Validation

- [ ] Every Lean name cited in the note resolves by `grep -rn` under `FormalSystem/`, the two probes, or the archived evidence file (no fabricated names).
- [ ] The five `Probe710` declarations and seven `Probe706` declarations are listed with the statement shapes the probes actually prove.
- [ ] `grep -n -i "task [0-9]" <note>` is empty and `check-task-references.sh` passes.
- [ ] GKWZ 5.28 and 5.32 cited with printed page numbers; no 5.32 proof formula; no complexity bound for this logic.
- [ ] Both rules (carrier; width) stated, with the carrier rule explicitly marked necessary-but-not-sufficient.
- [ ] `index-entries.json` valid JSON; deployed copy byte-identical; entry present in `.claude/context/index.json`.
- [ ] No file under `.claude/**` hand-edited; no file in sibling 704's or 710's `file_scope` touched.

## Artifacts & Outputs

- `/home/benjamin/.config/nvim/agent-system/extensions/formal/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` (the note, ~200-280 lines)
- One entry in `/home/benjamin/.config/nvim/agent-system/extensions/formal/index-entries.json`
- One line in `/home/benjamin/.config/nvim/agent-system/extensions/formal/context/project/logic/README.md`
- Deployed copy at `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` (generated, not committed)
- `specs/707_ztime_no_finite_carrier_fmp_context_note/summaries/01_ztime-no-finite-carrier-fmp-summary.md` (implementation summary)

## Rollback/Contingency

All edits are three text files in the source-store repository plus a regenerable deploy. If the
note must be withdrawn: in `/home/benjamin/.config/nvim`, revert the single commit that added
the three paths (`git revert <sha>`, which touches only those paths and leaves sibling dirt
alone), then rerun `bash .claude/scripts/deploy-headless.sh` so the deployed copy disappears.
If an uncommitted partial note must be discarded while siblings have uncommitted work in the
same tree, do NOT use a reverting `git-snapshot.sh` or `git checkout --`; delete the one new
file and `git checkout -- <index-entries.json> <README>` by explicit path only after confirming
via `git diff` that the hunks in those two files are this task's alone. See
`context/contracts/recovery.md`'s rollback rung before any reverting command.
