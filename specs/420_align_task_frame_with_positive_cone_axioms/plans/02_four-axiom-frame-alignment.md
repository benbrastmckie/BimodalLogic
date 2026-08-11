# Implementation Plan: Task #420 (v2) — Four-Axiom Frame Alignment

- **Task**: 420 - align_task_frame_with_positive_cone_axioms
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours (Phases 1-5, landed) + 5.5 hours (Phases 6-9, unblocked) + ~5 hours (Phase 10, blocked on task 415)
- **Dependencies**: Task 438 (landed context). Coordination with task 415 is a **phase-level wait on Phase 10 ONLY** — the task-level `420 -> 415` `dependencies[]` edge was deliberately DROPPED on 2026-08-10 to break a real cycle (`420 <-> 415`, and `420 -> 415 -> 414 -> 420`) and MUST NOT be re-added; coordinate with 415 directly, not via the edge list. Joint design decisions with task 414 (see Open Design Questions).
- **Research Inputs**:
  - `specs/420_align_task_frame_with_positive_cone_axioms/reports/01_taskframe-positive-cone-limit-nullity.md` (integrated in plan v1)
  - Dedicated blocker-research pass, 2026-08-10 (delegated inline, no report file; findings recorded verbatim in `### Research Integration` below)
  - `specs/paper-definitions-of-record.md` (authoritative anchor record; lint PASS, exit 0)
- **Reports Integrated**: `01_taskframe-positive-cone-limit-nullity.md` (v1); inline blocker-research findings 2026-08-10 (v2)
- **Artifacts**: plans/02_four-axiom-frame-alignment.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v1 (`plans/01_taskframe-limit-nullity-alignment.md`) landed Phases 1-5 green and committed,
but was written against a superseded THREE-axiom frame ("Limit Nullity", lax one-directional
Compositionality). The paper's `\label{def:frame}` (recorded at
`specs/paper-definitions-of-record.md:185`) has exactly FOUR axioms — *Compositionality*
(biconditional), *Seriality*, *Limit*, *Spherical* — and Nullity is NOT among them (it is the
derived `lem:nullity`, reflexivity only). This revision addresses two blockers:

1. **Phase-6 dependency on task 415**: plan v1's Phase 6 phase-waits on 415's `bundleFlowFrame`,
   which is `not_started`. The task-level dependency edge is gone (deliberately, to break a
   cycle) but the phase-level wait is real and remains — for the STRUCTURE CHANGE only.
2. **Phase-6 scope stale a second time**: plan v1's Phase 6 adds ONE axiom field; the target is
   FOUR axioms plus the supporting fiber/cone/segment/directed-family apparatus, `Nonempty
   WorldState`, and `[Nontrivial D]`.

**Revision verdict** (from the blocker-research pass, adopted): genuinely blocked on 415 for the
structure change — but Blocker 2 is clearable NOW, and there is substantial unblocked work plus
one unblocked defect (`identityFrame` violates *Seriality* independently of 415). Phases 1-5 stay
as landed history. Plan v1's Phase 6 is superseded by Phases 6-10 here: four UNBLOCKED phases
(LaTeX four-axiom restatement; apparatus definitions; `identityFrame` repair; docstring
corrections) and one terminal BLOCKED atomic-batch phase (the structure change and 16-site
discharge).

**Definition of done for the next dispatch**: Phases 6-9 complete, `lake build` green, standalone
`pdflatex` of `02-Semantics.tex` green, all work committed. The correct terminus is then task
status `[BLOCKED]` on task 415 (phase-level wait, Phase 10) — **not** `[COMPLETED]`, and never a
`sorry` or placeholder axiom.

### Research Integration

Newly integrated in this revision — the dedicated blocker-research pass of 2026-08-10 (treat as
verified; file:line citations as given):

- **A. Definition lint PASS**: `bash scripts/check-paper-definitions.sh` exits 0, silent. No
  anchor drifted. `specs/paper-definitions-of-record.md` is authoritative and consumable — that
  file, NOT the paper, is what this repo's specs cite. Key recorded facts:
  - `def:frame` (paper-definitions-of-record.md:185) — exactly FOUR axioms; Nullity is NOT
    among them.
  - `def:frame#Compositionality` — BICONDITIONAL; the record explicitly flags the right-to-left
    direction as load-bearing ("used directly in, e.g., the constraint-family proofs").
  - `lem:nullity` (:220) — DERIVED, asserts reflexivity only (`w ⇒₀ w`), NOT an iff.
  - `lem:step` (:328) — *Spherical*'s SOLE application site. Verbatim closing remark: "When the
    family has a ⊆-least member, that member already contains a candidate and *Spherical* is
    not needed."
- **B. Site inventory**: 16 live + 2 dead = 18, UNCHANGED (full table in Phase 10). No
  `TaskFrame.mk`/`FiniteTaskFrame.mk` anywhere — every construction uses `where`-syntax, so the
  compiler enumerates missing fields cleanly.
- **B.2 `ParametricCanonicalTaskFrame` Limit violation CONFIRMED**: carrier is MCS pairs,
  D-independent (ParametricCanonical.lean:199, :204-205); `parametric_task_rel_pos` (:236-241)
  is duration-blind above zero, so over dense D, `⋂_{x>0}(M)_x ≠ {M}`. The witness is LIVE:
  `countermodel_dense_enriched` (BXCanonical/Completeness.lean:133-138, witness at :143),
  consumed by `completeness` (:221) and `completeness_dense` (:266), plus
  ChronicleToCountermodelBasic.lean:839. **No `pos` function is possible** on the current
  carrier — `limit_nullity_of_shift` is STRUCTURALLY INAPPLICABLE; the carrier must change.
  That is exactly 415's `bundleFlowFrame`. Blocker 1's mechanism is sound and unchanged.
- **B.3 The three landed helpers are present VERBATIM** in
  FormalSystem/Semantics/TaskFrame.lean, all against a bare `R : W → D → W → Prop`:
  `limit_nullity_of_succOrder` (:261-270), `limit_nullity_of_shift` (:289-296),
  `exists_uniform_radius_of_finite` (:340-346).
- **B.4 The naive split of the atomic batch is REFUTED — two new findings**:
  - (i) **Seriality breaks `identityFrame` outright** (TaskFrame.lean:393,
    `TaskRel := fun w x u => w = u ∧ x = 0`): for any `x > 0` there is NO successor.
    Violates *Seriality* over EVERY nontrivial D — discretely as well as densely. 415 is
    IRRELEVANT to it. Live export (TaskFrame.lean:390), referenced at WorldHistory.lean:125,
    SemanticPropertyTest.lean:108, TaskFrameTest.lean:41-42. Must be repaired, re-carriered, or
    deleted regardless of 415 (Phase 8).
  - (ii) **Biconditional Compositionality re-collides with the blocked frame**: interpolation at
    `x, y > 0` for `ParametricCanonicalTaskFrame` requires an MCS interpolation lemma that does
    not exist (`ExistsTask` is `GContent M ⊆ M'`, Metalogic/Bundle/CanonicalFrame.lean:73; only
    transitivity is available, :260). Failures cluster on exactly TWO frames: `identityFrame`
    (Seriality) and `ParametricCanonicalTaskFrame` (Limit + interpolation). All other sites are
    genuinely easy.
  - Structural argument: adding Seriality now and Limit later means TWO repo-wide red windows,
    not one. Splitting the STRUCTURE-CHANGE batch strictly increases risk. (This argues against
    splitting the field-addition batch — NOT against the pure-addition and docstring phases 6-9,
    which never make the build red.)
- **C.1-C.3 Per-axiom targets, apparatus, binders**: none of the supporting apparatus exists
  (no task-relation fiber/cone/segment/directed-family definition anywhere in FormalSystem/ +
  Tests/ excluding Boneyard; the 966 `segment`/`directed` hits are all unrelated). `Nonempty
  WorldState` absent from the structure; `[Nontrivial D]` absent from the structure binders
  (TaskFrame.lean:152) though already carried by `valid`/`SemanticConsequence`
  (Semantics/Validity.lean:80, 104, 171, 189, 242, 278) — the gap is exactly and only at
  STRUCTURE level. Full target table in Phase 10; apparatus definitions in Phase 7.
- **C.4 Wrong declarations/docstrings** — enumerated in Phase 9 (unblocked subset) and Phase 6
  (the 02-Semantics.tex restatement).
- **C.5 `WorldHistory` gap CONFIRMED**: WorldHistory.lean:75-105 has four fields (`domain`,
  `convex`, `states`, `respects_task`); NO nonemptiness field (the empty history is a legal Lean
  `WorldHistory` but not a world history per `def:world-history`,
  paper-definitions-of-record.md:232), and NO `PartialHistory` layer at all — a partial history
  requires nonemptiness WITHOUT convexity, so it cannot be carved out by weakening the current
  structure. Match on four of five conjuncts. JOINT SCOPE WITH 414 — the layering lands ONCE,
  before the consequence refactor, not twice (deferred here; see Open Design Questions).

### Corrections to the Recorded Blocker Text (plan notes, record verbatim)

- **(a) Dense exposure is BROADER than recorded**: `ParametricCanonicalTaskFrame` is elaborated
  not only at ℚ but also at ℝ — CompletenessDedekind.lean:78, 81, 86. Neither ℚ nor ℝ has
  `SuccOrder`, so the discrete-binder route is closed at BOTH.
- **(b) The site inventory is unchanged at 18** (16 live + 2 dead). Plan v1's "re-run the greps,
  the prior inventory predates 415's landing" caveat is MOOT — 415 is `not_started` and never
  landed. (Phase 10 still re-runs the greps at implementation time, because by then 415 will
  genuinely have landed.)

### Prior Plan Reference

`plans/01_taskframe-limit-nullity-alignment.md`. Its Phases 1-5 are LANDED, GREEN, and
COMMITTED — carried forward below as recorded history, never re-run or reverted. Its Phase 6
(single `limit_nullity` field) is superseded by Phases 6-10 of this plan and is NOT carried
forward.

### Coordination Contract with Task 415 (record so 415 can be coordinated with directly)

**Minimum 415 must deliver**: a `bundleFlowFrame` with a position-carrying carrier of the form
`Index × D` (or equivalent) and a projection `pos : W → D` satisfying
`R w y u → pos u = pos w + y`, such that it can replace `ParametricCanonicalTaskFrame` at
Completeness.lean:143, ChronicleToCountermodelBasic.lean:839, and the three ℝ-probes at
CompletenessDedekind.lean:78/81/86. That single delivery makes *Limit* free via
`limit_nullity_of_shift` AND puts the interpolation obligation within reach, since a
deterministic-shift relation interpolates structurally.

### Cross-Task Acceptance Criterion (restated verbatim; binds Phase 10)

Phase 10 is NOT done when *Spherical* typechecks as a structure field. *Spherical*'s Lean
statement must be LITERALLY the hypothesis that `lem:step`'s proof consumes — not an inert
field, and no longer pointed at `thm:extension`, which under the current architecture consumes
only Zorn + `lem:step`. If this task lands *Spherical* as an inert field while 414 separately
rebuilds totality machinery without threading it through, both tasks can go green while jointly
failing to reconstruct `thm:extension`. Landing the field and demonstrating `lem:step` consumes
it are ONE deliverable, not two. `lem:step`'s recorded closing remark gives the discrete escape
hatch: a ⊆-least member makes *Spherical* unnecessary.

### Open Design Questions (FRAMED here, NOT settled — joint with task 414)

1. **`nullity_identity`** — currently an axiom FIELD (TaskFrame.lean:163) in the strictly
   stronger iff form `TaskRel w 0 u ↔ w = u`. The paper asserts reflexivity only, derived
   (`lem:nullity`, paper-definitions-of-record.md:220). Three live options:
   - (a) demote to a derived lemma proved from Seriality + Limit;
   - (b) keep the iff as a deliberate, documented strengthening;
   - (c) keep reflexivity derived and drop injectivity-at-zero.
   Cost signal: 39 `nullity_identity` references and 40 `forward_comp` references across 12 live
   files — either change is a wide but mechanical edit. This is a JOINT decision with task 414
   and MUST NOT be settled unilaterally by any phase of this plan. Phase 9 documents the
   question in the docstrings; Phase 10 leaves the field as-is unless the joint decision has
   landed by then.
2. **`PartialHistory` / `WorldHistory` nonemptiness layering** (finding C.5) — introduce the
   paper's partial-history → world-history → total layering ONCE, before 414's consequence
   refactor. Deferred out of this plan entirely; recorded so neither task does it twice.

### Decision Gate Resolution (carried from v1 — do not re-litigate)

The `parametric-canonical-carrier` gate remains settled as Option B: land all non-breaking work
now; the structure change waits for 415's deterministic-shift carrier. Option C (doing the
carrier change here) remains rejected — it duplicates 415's work and risks two divergent
refactors of the same definitions.

## Goals & Non-Goals

**Goals**:
- Rewrite `latex/subfiles/02-Semantics.tex`'s frame subsection to the paper's four-axiom
  `def:frame`, with the fiber/cone/segment/directedness apparatus and derived `lem:nullity`,
  preserving Phase 5's scaffolding (Phase 6).
- Land the fiber/cone/segment/directed-family apparatus as standalone, sorry-free Lean
  definitions over a bare relation — the prerequisite that makes *Spherical* statable at all
  (Phase 7).
- Repair or delete `identityFrame`, a genuine *Seriality* violation independent of 415, BEFORE
  the atomic-batch window so it is not discovered inside it (Phase 8).
- Correct every stale docstring and citation that does not depend on the field landing: the
  lax-law claims, the Nullity-exact-match claim, the "Limit Nullity" naming (the axiom is now
  simply *Limit*), and every bare `possible_worlds.tex:NNNN` locator → `\label` citations with
  verbatim quoted definition text (Phase 9).
- Fully specify the blocked structure change — four axiom fields, `Nonempty WorldState`,
  `[Nontrivial D]`, 16-site discharge — as a clean drop-in for the moment 415 lands (Phase 10,
  `[BLOCKED]`, atomic-batch).
- Mirror the paper's `def:constraints → lem:constraint → lem:fibers → lem:admissible → lem:step
  → thm:extension → cor:occurrence` decomposition LEMMA-FOR-LEMMA per the literature-fidelity
  policy (apparatus here; the lemma chain itself is 414-coordinated consumption, with the
  *Spherical*-consumption criterion above binding Phase 10).

**Non-Goals**:
- **Paper is READ-ONLY**: no edits under `/home/benjamin/Philosophy/Papers/`. Cite by `\label`
  (or `\aitem` key) ONLY; a bare `possible_worlds.tex:NNNN` is never a citation. Quote
  definition TEXT verbatim alongside each anchor so a renamed anchor stays detectable by text
  search.
- No settling of the `nullity_identity` design question or the `PartialHistory`/`WorldHistory`
  layering — joint with 414 (framed above).
- No change to `WorldHistory.respects_task` beyond the (deferred) layering decision.
- No validity/semantics refactor — 414 owns that and depends on this task, so the Ω-free API
  lands once, against the final frame structure.
- **Scope boundary with task 409**: 409 owns `04-Metalogic.tex` and `06-Notes.tex`
  identifier-architecture fidelity; THIS task owns the `02-Semantics.tex` frame-definition
  subsection ONLY.
- Optional stretch (defer if nontrivial): formalize the paper's T1 topology theorem as a sanity
  check — `exists_uniform_radius_of_finite` (TaskFrame.lean:340) is already the sanctioned
  topology-free substitute and no topology exists anywhere in the library.
- No `sorry`, no new axiom, no vacuous definition anywhere.
- No re-adding of the `420 -> 415` `dependencies[]` edge (cycle-breaking decision of
  2026-08-10 stands).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer starts the Phase 10 structure change before 415 lands "to make progress" | H | M | Phase 10 is the only phase permitted to touch the structure signature and it is `[BLOCKED]`; Phases 6-9 are pure additions, one localized repair, and prose |
| `identityFrame` repair choice (re-carrier vs delete) breaks its 3 reference sites | M | M | Phase 8 enumerates all 3 sites up front and requires a green build over them; both options specified, chosen at implementation time by what the sites need |
| Apparatus definitions (Phase 7) drift from `def:task-relation`/`def:directed` verbatim record | H | L | Definitions transcribed in the phase body against the recorded anchors; docstrings quote the record text; segments MUST use bracket form, fibers and segments as TWO separate classes |
| Renaming "Limit Nullity" prose/identifiers churns references | M | M | Phase 9 renames prose unconditionally; identifier renames only under its Scope Hypothesis (grep-confirmed reference count), else deferred to Phase 10's batch |
| Biconditional `comp` collides with `forward_comp`'s 40 references | M | M | Phase 10 keeps `forward_comp` available as a derived lemma (the `←` projection of `comp`) so consumer sites stay mechanical; wide edit acknowledged in its Scope Hypothesis |
| 415 delivers a carrier that does not satisfy the coordination contract | H | L | Contract recorded above (pos-projection + replacement sites); Phase 10's first task re-verifies it before adding any field; on failure, task returns to `[BLOCKED]` with a precise gap statement — never a `sorry` |
| Two red windows if Seriality and Limit land separately | H | M | Refuted-split finding B.4 recorded; Phase 10 is ONE atomic batch for ALL fields; anti-abuse guard: the batch is declared here, in advance |
| Task-number citations leak into deliverables outside `specs/**` | M | M | Explicit prohibition restated in every deliverable-writing phase; grep at task close |
| LaTeX rewrite collides with master-document labels or 409's files | M | L | Phase 6 verifies standalone AND master builds; touches `02-Semantics.tex` (+ `.sty` if needed) only |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 (landed) | 1, 5 | -- |
| 2 (landed) | 2 | 1 |
| 3 (landed) | 3 | 2 |
| 4 (landed) | 4 | 3 |
| 5 | 6, 7 | -- (6 builds on landed 5; 7 on landed 3) |
| 6 | 8 | 7 |
| 7 | 9 | 8 |
| 8 | 10 | 7, 8, 9 — and, externally, task 415 |

Phases within the same wave can execute in parallel. Phases 7-9 are serialized because they all
edit `FormalSystem/Semantics/TaskFrame.lean`; Phase 6 is LaTeX-only and shares no file with any
other phase.

---

### Phase 1: Re-anchor stale def:frame citations [COMPLETED]

*(Landed under plan v1 — recorded history, do not re-run. Original content preserved.)*

**Goal**: Every `def:frame, line 1835` citation in the tree points at the correct live anchor.

**Tasks**:
- [x] Replace the stale anchor at `FormalSystem/Semantics/TaskFrame.lean:17`, `:68`, `:90`
- [x] Replace the stale anchor at `FormalSystem/Examples/TemporalStructures.lean:20`, `:57`
- [x] Replace the stale anchor at `docs/user-guide/architecture.md:454`
- [x] Replace the stale anchor at `docs/reference/API_REFERENCE.md:147`
- [x] Use the correct anchor: `possible_worlds.tex:2423-2451` for the formal `def:frame`,
      `possible_worlds.tex:908-926` for the body statement with gloss at 932
- [x] Re-run the discovery grep to confirm zero remaining `line 1835` hits outside `specs/**`

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Post-landing note (v2)**: the raw-line-number anchors this phase installed are themselves
superseded by the "bare `possible_worlds.tex:NNNN` is never a citation" constraint; Phase 9
converts them to `\label` citations with verbatim quoted text.

---

### Phase 2: Recast TaskFrame docstrings from divergence to agreement [COMPLETED]

*(Landed under plan v1 — recorded history, do not re-run. Original content preserved.)*

**Goal**: The module's prose states the true relationship to the paper: agreement on the
positive-cone presentation, with Reflection and backward composition derived and mixed-sign
composition inexpressible.

**Tasks**:
- [x] Rewrite the `converse` field docstring: the paper's definitional converse convention
      packaged as a structure field, not a substantive temporal-symmetry axiom
- [x] Invert the `Axiomatization Notes` block from "we diverge" to "we agree" (lax-law framing)
- [x] Record that Reflection and backward composition are derived; mixed-sign composition
      inexpressible at the primitive level
- [x] Record the known gap: paper requires `W` nonempty and `D` nontrivial
- [x] Add a forward-looking note that Limit Nullity is the one paper clause still absent

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Post-landing note (v2)**: the lax-law and "one clause absent" prose this phase wrote is now
stale a second time against the four-axiom `def:frame`; Phase 9 corrects it. The phase remains
recorded history.

---

### Phase 3: Add the two reusable Limit Nullity discharge helpers [COMPLETED]

*(Landed under plan v1 — recorded history, do not re-run. Original content preserved.)*

**Goal**: Both discharge strategies exist as standalone, sorry-free theorems before any field
consumes them.

**Tasks**:
- [x] `limit_nullity_of_succOrder` — landed verbatim at TaskFrame.lean:261-270:
      `[SuccOrder D] [NoMaxOrder D] {W} {R} (hnull : ∀ w u, R w 0 u ↔ w = u)`
- [x] `limit_nullity_of_shift` — landed at TaskFrame.lean:289-296 with the added binder
      `[Nontrivial D]` (deviation authorized by the phase's Scope Hypothesis):
      `[Nontrivial D] {W} (pos : W → D) {R} (hshift …) (hzero …)`
- [x] Both placed in `namespace TaskFrame` with docstrings; imports
      `Mathlib.Algebra.Order.Group.Abs` and `Mathlib.Order.SuccPred.Basic` added

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Post-landing note (v2)**: re-verified present VERBATIM on 2026-08-10 (finding B.3). All three
helpers state their hypotheses against a bare `R : W → D → W → Prop`, not a structure field —
exactly the shape Phase 10 consumes. The "Limit Nullity" NAMING is superseded (the axiom is now
*Limit*); Phase 9 handles the prose, and identifier renames fall under Phase 9's Scope
Hypothesis.

---

### Phase 4: Add the finite uniform-radius theorem [COMPLETED]

*(Landed under plan v1 — recorded history, do not re-run. Original content preserved.)*

**Goal**: The substitute for the deferred T1 stretch goal lands as a machine-checked derived
result.

**Tasks**:
- [x] `exists_uniform_radius_of_finite` — landed at TaskFrame.lean:340-346:
      `[Nontrivial D] {W} [Fintype W] (R) (hlim …) (w) : ∃ x, 0 < x ∧ ∀ u y, |y| < x → R w y u → u = w`
- [x] `push_neg` deprecation replaced with `push Not`; zero diagnostics
- [x] Docstrings: uniform-radius reading; finite frames over dense D are temporally rigid;
      deliberate substitute for the deferred cone-topology T1 result

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: local

---

### Phase 5: Restate the LaTeX Task Frame definition [COMPLETED]

*(Landed under plan v1 — recorded history, do not re-run. Original content preserved.)*

**Goal**: `latex/subfiles/02-Semantics.tex`'s frame-definition subsection matches the paper as
then recorded, and still compiles standalone.

**Tasks**:
- [x] Rewrote the Task Frame definition: nonempty `\worldstate`, nontrivial totally ordered
      abelian group `D`, positive-cone primitive relation, converse convention, two-sided cone
- [x] Stated THREE axioms (iff-Nullity, lax positive-cone Compositionality, Limit Nullity) —
      correct against the paper state known at the time
- [x] Added the derived-Reflection remark, corrected the primitives table, updated the gloss
- [x] Added `\label{def:frame}` (file previously had zero `\label` commands)
- [x] Added `\poscone` (`D^{+}`) and `\taskcone{w}{x}` (`(w)_{x}`) macros to
      `latex/assets/bimodal-notation.sty`

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Post-landing note (v2)**: stale a SECOND time — the restatement carries three axioms
(Nullity as an iff axiom, one-directional Compositionality, "Limit Nullity") and omits
*Seriality* and *Spherical* entirely; `:56` still claims the equality "would additionally assert
interpolation" (finding C.4). Phase 6 rewrites it to the four-axiom `def:frame`, PRESERVING this
phase's scaffolding (the `\label{def:frame}` cross-reference, the `\poscone`/`\taskcone` macros,
the primitives table).

---

### Phase 6: Rewrite 02-Semantics.tex to the four-axiom def:frame [COMPLETED]

**Goal**: The frame-definition subsection of `latex/subfiles/02-Semantics.tex` (currently lines
31-62) states the paper's FOUR-axiom `def:frame` with the supporting apparatus and derived
`lem:nullity`, and compiles standalone and in the master document.

**Tasks**:
- [x] Rewrite the frame definition to the four axioms, matching the record at
      `specs/paper-definitions-of-record.md:185` (quote alongside the anchor; verbatim axiom
      text, `\label` sub-anchors `def:frame#Compositionality|Seriality|Limit|Spherical`):
      - *Compositionality* (BICONDITIONAL): `$w \Rightarrow_{x + y} v$ if and only if
        $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$` — the right-to-left
        direction is load-bearing. Delete the current `:56` claim that the equality "would
        additionally assert interpolation" and is not adopted — it IS adopted.
      - *Seriality*: `$w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$` (for
        `x ≥ 0`).
      - *Limit*: `$\bigcap_{x > 0} (w)_x = \set{w}$` (rename from "Limit Nullity").
      - *Spherical*: `$\bigcap \mathcal{S} \neq \emptyset$ for any directed family
        $\mathcal{S}$ of nonempty fibers and segments`.
- [x] Add the apparatus before the definition, per `def:task-relation`
      (paper-definitions-of-record.md:161) and `def:directed` (:176): Fiber
      `$\Fib(w, x) := \{u \in W : w \Rightarrow_x u\}$`; Cone
      `$(w)_x := \bigcup_{|y| < x} \Fib(w, y)$` for `x > 0`; Segment in the BRACKET form
      `$[w, v]_x^y := \Fib(w, x) \cap \Fib(v, -y)$` for `x, y ≥ 0` (the retired `\Seg`
      function-application notation is deleted from the paper preamble and must NOT be
      reintroduced); directed family per `def:directed`. *Spherical* ranges over directed
      families of nonempty FIBERS and SEGMENTS as TWO SEPARATE CLASSES — do not reintroduce the
      retired device by which one-sided fibers counted among the segments.
- [x] Demote Nullity: remove it from the axiom list and state it as the derived `lem:nullity`
      (reflexivity only, `$w \Rightarrow_0 w$`; proved from Seriality at `x = 0` plus Limit,
      choice-free) — per paper-definitions-of-record.md:220.
- [x] PRESERVE Phase 5's scaffolding: the `\label{def:frame}` cross-reference, the
      `\poscone`/`\taskcone` macros, and the primitives table (extend the table only as the
      apparatus requires, e.g. fiber/segment rows).
- [x] Update the gloss paragraph so it describes the four axioms actually stated.

**Timing**: 1.5 hours

**Depends on**: none (builds on landed Phase 5)

**Verification Tier**: interface

**Scope Hypothesis**: The stale region is `latex/subfiles/02-Semantics.tex:31-62` (finding
C.4). Line extents are a plan-time hypothesis; read the file and confirm before editing, and
keep the diff inside the Task Frames subsection — the World Histories subsection onward is out
of scope (its `WorldHistory` alignment is deferred, joint with 414).

**Files to modify**:
- `latex/subfiles/02-Semantics.tex` — apparatus, four-axiom definition, derived `lem:nullity`,
  gloss, primitives table
- `latex/assets/bimodal-notation.sty` — only if new macros are needed (e.g. `\Fib`, segment
  brackets); reuse `\poscone`/`\taskcone`

**Constraints**:
- **Notation (binding user decision, carried forward unchanged)**: any explicit converse
  operation is written with a superscript inverse — `$\Rightarrow^{-1}$` (and `$R^{-1}$` for
  abstract relations) — NEVER the relation-algebra breve/smile (`$\breve{R}$`,
  `$R^{\smallsmile}$`). The paper itself introduces no operator symbol for the converse
  (subscript negation only); the safest restatement introduces none either.
- Scope boundary: `04-Metalogic.tex` and `06-Notes.tex` belong to task 409 — do not touch them.
- Paper is READ-ONLY; cite by `\label` with verbatim quoted text.
- No task-number citations in any `.tex` or `.sty` file.

**Verification**:
- Standalone: `cd latex/subfiles && TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 02-Semantics.tex`
  — exits clean, produces a PDF, no undefined-control-sequence errors
- Master: `cd latex && latexmk BimodalReference.tex` — green, no duplicate-label warnings
- Read the rendered definition and confirm all FOUR axioms, the apparatus (fiber, cone, segment
  in bracket form, directed family), and the derived `lem:nullity` are present, and Nullity is
  NOT listed as an axiom

---

### Phase 7: Define the fiber/cone/segment/directed-family apparatus in Lean [COMPLETED]

**Goal**: The supporting apparatus that makes *Spherical* statable exists as standalone,
sorry-free Lean definitions — pure additions over a bare relation, zero discharge obligations,
build stays green throughout.

**Tasks**:
- [x] Define, in `FormalSystem/Semantics/TaskFrame.lean` (same standalone style as the Phase 3
      helpers — against a bare relation or a frame parameter, NOT as structure fields), per
      `def:task-relation` (paper-definitions-of-record.md:161) and `def:directed` (:176):
      ```
      Fib F w x         := {u | F.TaskRel w x u}
      cone F w x (0<x)  := ⋃_{|y| < x} Fib F w y
      Seg F w v x y     := Fib F w x ∩ Fib F v (-y)     -- notation [w,v]_x^y, 0 ≤ x,y
      DirectedFamily S  := S.Nonempty ∧ ∀ S₁ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂
      ```
      (exact Lean spellings at the implementer's discretion — e.g. `Set W` vs predicates,
      hypothesis vs subtype for the cone's `0 < x` — but the MATHEMTICAL content must transcribe
      the recorded definitions exactly; segments use the two-endpoint bracket semantics, never a
      one-sided `\Seg`-style function application.)
- [x] Keep fibers and segments as TWO SEPARATE CLASSES wherever a "fibers and segments"
      predicate is needed (e.g. an `IsFiber s ∨ IsSegment s` disjunction) — the retired device
      by which one-sided fibers counted among the segments must not be reintroduced.
- [x] Docstring each definition with the `\label` anchor plus the verbatim recorded text (so a
      renamed anchor stays detectable by text search); no bare `possible_worlds.tex:NNNN`
      locators.
- [x] Optionally state and prove trivial sanity lemmas only if free (e.g. cone monotonicity);
      no obligation — this phase carries ZERO discharge obligation by design.

**Timing**: 1.5 hours

**Depends on**: none (same style as landed Phase 3)

**Verification Tier**: local

**Scope Hypothesis**: Finding C.2 (verified 2026-08-10): NO task-relation fiber, cone, segment,
or directed-family definition exists anywhere in `FormalSystem/` + `Tests/` (excluding
`Boneyard/`); the 966 `segment`/`directed` grep hits are all unrelated (Reynolds separability
prose at SoundnessLemmas/Separability.lean:38,259; DenseModelSurgery interval reasoning at
TruthTransfer.lean:208-210; order-theoretic "past-directed" naming). Re-run the grep before
defining; if a genuine collision has appeared since, reconcile naming rather than duplicating.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — new definitions (and notation) in
  `namespace TaskFrame`

**Constraints**:
- Pure additions only. Do NOT add or change any structure field in this phase.
- No task-number citations in this file.
- No `sorry`, no new axiom.

**Verification**:
- `lake build` — green, no new warnings
- `grep -n "sorry" FormalSystem/Semantics/TaskFrame.lean` returns nothing
- `#print axioms` on any new lemmas — only the standard Lean axioms

---

### Phase 8: Repair or delete identityFrame (Seriality violation, 415-independent) [NOT STARTED]

**Goal**: `identityFrame` no longer violates *Seriality*, so the Phase 10 atomic batch does not
trip over a defect that has nothing to do with 415.

**Why now**: finding B.4(i) — TaskFrame.lean:393 has
`TaskRel := fun w x u => w = u ∧ x = 0`. *Seriality* requires
`∀ w x, 0 ≤ x → (∃ u, w ⇒ₓ u) ∧ (∃ v, v ⇒ₓ w)`; for any `x > 0` there is NO `u` with
`w = u ∧ x = 0`. The violation holds over EVERY nontrivial D — discretely as well as densely —
so task 415 is IRRELEVANT to it, and it MUST NOT be discovered inside the atomic-batch red
window. This is a failure plan v1 did not contemplate.

**Tasks**:
- [ ] Enumerate the live references (Scope Hypothesis below): the export at TaskFrame.lean:390
      and the three consumers — WorldHistory.lean:125, SemanticPropertyTest.lean:108,
      TaskFrameTest.lean:41-42. Confirm by grep before editing.
- [ ] Choose ONE of, based on what the reference sites actually need:
      - **(a) Re-carrier/redefine**: replace the relation with one satisfying all four target
        axioms — the natural candidate is the static frame `TaskRel := fun w _ u => w = u`
        (every state related to itself at every duration), which satisfies biconditional
        Compositionality, Seriality, Limit, and Spherical trivially, and keeps
        `nullity_identity` intact. Rename if "identity" no longer describes it (e.g.
        `staticFrame`), updating the three consumers.
      - **(b) Delete**: remove `identityFrame` and repoint or delete the three consumers.
- [ ] Whichever option: docstring the frame's axiom status against the recorded `def:frame`
      anchors; keep the `[Nontrivial D]` binder if the definition still requires it.
- [ ] Do NOT add any structure field in this phase; the repaired frame must discharge the
      CURRENT structure's fields only (Phase 10 adds the rest and re-discharges).

**Timing**: 1 hour

**Depends on**: 7

**Verification Tier**: interface

**Scope Hypothesis**: Exactly 3 live references outside the definition itself
(WorldHistory.lean:125, SemanticPropertyTest.lean:108, TaskFrameTest.lean:41-42), per the
2026-08-10 inventory. Confirm with `grep -rn "identityFrame" FormalSystem/ Tests/` before
editing; treat any new site as in scope.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — the definition
- `FormalSystem/Semantics/WorldHistory.lean`, `Tests/.../SemanticPropertyTest.lean`,
  `Tests/.../TaskFrameTest.lean` — the consumers (as the chosen option requires)

**Constraints**:
- No task-number citations in any of these files.
- No `sorry`, no new axiom, no vacuous definition (a frame nothing can instantiate is not a
  repair).

**Verification**:
- `lake build` — green (full build: consumers span FormalSystem/ and Tests/)
- `grep -n "sorry"` on every touched file returns nothing
- The chosen definition provably satisfies *Seriality* as a standalone lemma OR is deleted —
  record which in the summary

---

### Phase 9: Correct stale docstrings, naming, and citations (field-independent subset) [NOT STARTED]

**Goal**: Every C.4 item that does NOT depend on the structure change landing is corrected: the
prose tells the truth about the four-axiom target, and every paper reference is a `\label`
citation with verbatim quoted text.

**Tasks**:
- [ ] **Lax-law claims** (TaskFrame.lean:48-53, 170-176): delete the claim that "the law is the
      LAX inclusion `R_{x+y} ⊇ R_x ∘ R_y`: an equality would additionally assert interpolation
      and is not adopted" — it directly contradicts `def:frame#Compositionality`
      (BICONDITIONAL, right-to-left load-bearing). Recast `forward_comp`'s docstring (:177): it
      is the `←` HALF of the paper's biconditional; the `→` (interpolation) direction lands with
      the structure change.
- [ ] **Nullity claim** (TaskFrame.lean:47): replace "Paper's *Nullity* is an iff, and
      `nullity_identity` … is an exact match" — Nullity is NOT an axiom; `lem:nullity`
      (paper-definitions-of-record.md:220) is DERIVED and asserts reflexivity only. Document the
      `nullity_identity` iff-form as an OPEN DESIGN QUESTION (three options, joint with 414 —
      frame it exactly as this plan's Open Design Questions section does; do NOT settle it and
      do NOT change the field).
- [ ] **"Limit Nullity" → *Limit*** naming (TaskFrame.lean:69, 84, 86, 232, and the :261
      header): the axiom is now simply *Limit*. Update all prose unconditionally. Rename the
      Lean identifiers (`limit_nullity_of_succOrder`, `limit_nullity_of_shift`) ONLY under the
      Scope Hypothesis below; otherwise record the naming lag in their docstrings and defer the
      rename into Phase 10's batch.
- [ ] **Known-gaps block** (TaskFrame.lean:66-72): currently lists only `Nonempty W`,
      `Nontrivial D`, "Limit Nullity". Rewrite to the full gap list: `Nonempty W`,
      `[Nontrivial D]` (structure level — already carried by `valid`/`SemanticConsequence` at
      Validity.lean:80/104/171/189/242/278), *Seriality*, *Limit*, *Spherical*, the
      interpolation (`→`) direction of *Compositionality*, and the apparatus consumption
      (pointing at the Phase 7 definitions).
- [ ] **Bare locators → `\label` citations** (TaskFrame.lean:52, 59, 63, 71, 105-106, 187, 232;
      WorldHistory.lean:73, 84): "a bare `possible_worlds.tex:NNNN` is never a citation" —
      convert every one to a `\label` reference (`def:frame`, `def:task-relation`,
      `def:temporal-order`, `def:world-history`, `lem:nullity`, …) quoting the recorded
      definition text verbatim alongside the anchor.
- [ ] **WorldHistory.lean:73, 84**: beyond the locator fix, correct "Matches JPL paper
      def:world-history (line 1849)" — it does NOT fully match: no nonemptiness field (the
      empty history is legal in Lean but not per `def:world-history`,
      paper-definitions-of-record.md:232) and no `PartialHistory` layer. State the gap plainly
      as deferred joint scope with the consequence-refactor work; do NOT change any field.

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: local

**Scope Hypothesis**: The identifier rename (`limit_nullity_of_*` → `limit_of_*` or similar) is
in scope ONLY if `grep -rn "limit_nullity_of" FormalSystem/ Tests/` confirms references are
confined to TaskFrame.lean itself (the helpers landed recently and plan-time expectation is
zero external consumers). If external references exist, do the prose-only correction here and
fold the rename into Phase 10's atomic batch. Line numbers throughout are plan-time hypotheses
from the 2026-08-10 findings; confirm each by reading before editing.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — docstrings, header comments, (conditionally) helper
  identifiers
- `FormalSystem/Semantics/WorldHistory.lean` — two docstrings

**Constraints**:
- Comment/docstring edits plus (at most) the grep-gated identifier rename. NO structure-field
  change, NO change to `nullity_identity` or `forward_comp` themselves.
- No task-number citations in these files (cite `def:frame`, `lem:nullity`, sibling filenames —
  durable anchors only).
- No `sorry`, no new axiom.

**Verification**:
- `lake build` — green
- `git diff` confined to comment/docstring regions plus any grep-gated rename sites
- `grep -rn "possible_worlds.tex:[0-9]" FormalSystem/ --include=*.lean` returns nothing (all
  converted to `\label` citations)
- `grep -rn "Limit Nullity" FormalSystem/ --include=*.lean` returns nothing (prose renamed)

---

### Phase 10: Add the four axiom fields and discharge all 16 live sites [BLOCKED]

**Goal**: `TaskFrame` carries the paper's four-axiom `def:frame` — biconditional `comp`,
`serial`, `limit`, `spherical` — plus `Nonempty WorldState` and `[Nontrivial D]`, with every
live construction site discharging every field sorry-free, and *Spherical* demonstrably
consumed by `lem:step` per the Cross-Task Acceptance Criterion.

**BLOCKED ON**: task 415's `bundleFlowFrame` (phase-level wait — the `dependencies[]` edge was
deliberately dropped 2026-08-10 and MUST NOT be re-added; coordinate directly). Mechanism
(finding B.2, confirmed): `ParametricCanonicalTaskFrame` (ParametricCanonical.lean:207-215) has
a D-independent MCS-pair carrier and a duration-blind relation above zero
(`parametric_task_rel_pos`, :236-241), so over dense D `⋂_{x>0}(M)_x ≠ {M}` — *Limit* genuinely
fails, and no `pos : W → D` shift projection can exist on that carrier, so
`limit_nullity_of_shift` is STRUCTURALLY INAPPLICABLE. The carrier must change; that is exactly
415's `bundleFlowFrame`. Live exposure: `countermodel_dense_enriched`
(BXCanonical/Completeness.lean:133-138, witness :143) feeding `completeness` (:221) and
`completeness_dense` (:266); ChronicleToCountermodelBasic.lean:839; and the ℝ elaborations at
CompletenessDedekind.lean:78, 81, 86. Neither ℚ nor ℝ has `SuccOrder`, so the discrete-binder
route is closed at BOTH. Additionally, biconditional `comp` requires MCS interpolation
(`ExistsTask M V → ∃ U, ExistsTask M U ∧ ExistsTask U V`) which does not exist
(CanonicalFrame.lean:73, :260) — also resolved by the deterministic-shift carrier, which
interpolates structurally.

**Do not start this phase until 415 has landed a carrier satisfying the Coordination Contract
(Overview).** If tempted to proceed anyway, the correct outcome is to leave this phase blocked —
never a `sorry`, never a placeholder axiom, never a vacuous or inert field.

**Per-axiom target table** (finding C.1):

| Paper axiom | Target Lean field | Exists today? | New work |
|---|---|---|---|
| *Compositionality* (biconditional) | `comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → (TaskRel w (x+y) v ↔ ∃ u, TaskRel w x u ∧ TaskRel u y v)` | HALF — `forward_comp` (TaskFrame.lean:177) is the `←` direction only | `→` (interpolation) at all 16 sites; MCS interpolation for site #9 via 415's carrier |
| *Seriality* | `serial : ∀ w x, 0 ≤ x → (∃ u, TaskRel w x u) ∧ (∃ v, TaskRel v x w)` | ABSENT — the `Axiom.serial_future`/`serial_past` hits at SoundnessLemmas/FrameClassVariants.lean:90,98 are OBJECT-LANGUAGE proof-system axioms, unrelated | whole field; `identityFrame` pre-repaired in Phase 8 |
| *Limit* | `limit : ∀ w u, (∀ x, 0 < x → ∃ y, \|y\| < x ∧ TaskRel w y u) → u = w` | discharge helpers landed (Phase 3) | field + 16 discharges; site #9 via 415's carrier |
| *Spherical* | `spherical : ∀ (S : Set (Set WorldState)), DirectedFamily S → (∀ s ∈ S, s.Nonempty) → (∀ s ∈ S, IsFiber s ∨ IsSegment s) → (⋂₀ S).Nonempty` | ABSENT; statable only after Phase 7's apparatus | field + discharges + `lem:step` consumption (acceptance criterion) |

Structure binders (finding C.3): add `Nonempty WorldState` (required by `def:task-relation`)
and `[Nontrivial D]` at STRUCTURE level (already carried by `valid`/`SemanticConsequence` —
the gap is exactly and only the structure).

**Site inventory** (finding B, re-verified 2026-08-10, unchanged at 18; Scope Hypothesis
below):

| # | Site | file:line | Notes |
|---|---|---|---|
| 1 | `trivialFrame` | FormalSystem/Semantics/TaskFrame.lean:376 | OK subsingleton |
| 2 | `identityFrame` | TaskFrame.lean:390 | pre-repaired/deleted in Phase 8 |
| 3 | `natFrame` | TaskFrame.lean:422 | Limit fails dense — discrete binders + `limit_nullity_of_succOrder` |
| 4 | `intTimeFrame` | Examples/TemporalStructures.lean:74 | OK `Unit` |
| 5 | `intNatFrame` | TemporalStructures.lean:87 | OK at `Int` |
| 6 | `genericTimeFrame` | TemporalStructures.lean:153 | OK `Unit` |
| 7 | `genericNatFrame` | TemporalStructures.lean:165 | Limit fails dense — discrete binders |
| 8 | `multiFamTaskFrameGen` | Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:139 | OK shift (`limit_nullity_of_shift`) |
| 9 | `ParametricCanonicalTaskFrame` | Metalogic/Algebraic/ParametricCanonical.lean:207 | **BLOCKING** — replace with 415's `bundleFlowFrame` |
| 10 | `zIntervalTaskFrame` | Metalogic/WeakCanonical/Transfer.lean:568 | OK at ℤ |
| 11 | `zTaskFrameV2` | Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:453 | OK at ℤ, shift |
| 12 | `multiFamTaskFrame` | ReynoldsBridge.lean:671 | OK at ℤ, shift |
| 13 | `RefinedFilteredTaskFrame` | Metalogic/Decidability/FMP/Filtration.lean:197 | fails dense-polymorphic — restrict (coordinate with the FMP-to-ℤ move) |
| 14 | `FiniteFilteredTaskFrame` | Metalogic/Decidability/FMP/FiniteModel.lean:159 | extends 13 |
| 15 | `regionFrame` | Metalogic/Decidability/Verified/Bridge/Omega.lean:136 | fails at dense probes — delete/re-carrier probes; Seriality easy (`d = 0 → s = s'` at :138) |
| 16 | `customFrame` | Tests/BimodalTest/Semantics/TaskFrameTest.lean:56 | OK at Int |
| D1 | `CanonicalTaskTaskFrame` | Boneyard/ChainCompleteness/Bundle/SuccChainTaskFrame.lean:95 | DEAD — Boneyard excluded (lakefile.lean:16-19 roots only `FormalSystem`; root FormalSystem.lean has no Boneyard import) |
| D2 | `CanonicalTaskFrame` | Boneyard/StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean:267 | DEAD |

Non-sites (aliases, no field obligation): Tests/.../Property/Generators.lean:148
(`SampleableExt` instance over `TaskFrame.natFrame (D := Int)`, inherits from #3),
TruthTest.lean:29, SemanticBenchmark.lean:50.

The Seriality/interpolation discharges at the easy sites are genuinely easy (finding B.4):
`regionFrame` (Omega.lean:138, `d = 0 → s = s'`), `refinedFilteredTaskRel` (Filtration.lean:192,
`if d = 0 then w = u else True`), `natFrame`/`genericNatFrame` (`d ≠ 0 ∨ w = u`), and the
`Unit`/`True` frames all satisfy Seriality and interpolation trivially. Failures cluster on
exactly TWO frames — `identityFrame` (repaired in Phase 8) and `ParametricCanonicalTaskFrame`
(replaced via 415).

**Tasks** (specified now so the phase is a clean drop-in once unblocked):
- [ ] GATE: verify 415's landed `bundleFlowFrame` satisfies the Coordination Contract (carrier
      `Index × D` or equivalent; `pos : W → D` with `R w y u → pos u = pos w + y`; replaces
      site #9 at Completeness.lean:143, ChronicleToCountermodelBasic.lean:839, and
      CompletenessDedekind.lean:78/81/86). On failure: stop, restate the precise gap, return to
      `[BLOCKED]`.
- [ ] Add the structure binders: `[Nontrivial D]` on `TaskFrame`; `Nonempty WorldState` (field
      or instance argument, implementer's choice, documented).
- [ ] Add the four fields per the target table. `comp` replaces `forward_comp` as the field;
      immediately re-derive `forward_comp` as a lemma (the `←` projection of `comp`) so the 40
      existing references across 12 files stay mechanical or untouched.
- [ ] Leave `nullity_identity` AS-IS unless the joint 414 decision has landed (Open Design
      Questions); if it has, apply it here inside the same batch.
- [ ] Discharge all 16 live sites per the inventory: subsingleton/`Unit` sites trivially;
      shift sites via `limit_nullity_of_shift`; discrete sites via `limit_nullity_of_succOrder`
      under `[SuccOrder D] [NoMaxOrder D]`; site #9 via 415's `bundleFlowFrame` (shift
      discharge + structural interpolation); sites #13/#14 restricted in coordination with the
      FMP-to-ℤ move; site #15's dense elaboration probes deleted or re-carriered.
- [ ] *Spherical* per-site: finite/discrete sites may use the recorded escape-hatch shape (a
      ⊆-least member of the directed family contains a candidate — mirror `lem:step`'s closing
      remark as a helper lemma); dense sites via the deterministic-shift structure.
- [ ] **Acceptance (Cross-Task Acceptance Criterion, Overview — binding)**: demonstrate
      `lem:step`'s Lean counterpart consumes the `spherical` field literally as its hypothesis.
      Landing the field and demonstrating consumption are ONE deliverable. Coordinate the
      lemma-chain naming with the `def:constraints → lem:constraint → lem:fibers →
      lem:admissible → lem:step` decomposition (lemma-for-lemma per the literature-fidelity
      policy) so 414's totality rebuild threads through it.
- [ ] Ignore Class D (dead, Boneyard) — re-confirm the exclusion holds at implementation time.

**Timing**: ~5 hours (estimate only; re-scope via `/revise` once 415 lands and the inventory is
re-confirmed)

**Depends on**: 7, 8, 9 — and, externally, task 415

**Verification Tier**: full

**Commit Mode**: atomic-batch

Rationale for `atomic-batch` (carried from v1, reinforced by finding B.4): adding structure
fields is inherently atomic across all live construction sites — the build is red from the
first field until the last site is discharged. No `TaskFrame.mk` occurs anywhere (all
`where`-syntax), so the compiler enumerates missing-field sites cleanly, but intermediate
per-file states are expected red and MUST NOT be committed. Adding Seriality now and Limit
later would mean TWO repo-wide red windows; ALL fields land in ONE batch. The batch is declared
here in advance (anti-abuse guard satisfied).

**Scope Hypothesis**: 18 total construction sites (16 live, 2 dead), re-verified 2026-08-10 —
the inventory did NOT shift (correction (b): the v1 caveat was moot because 415 never landed).
By the time this phase runs, 415 WILL have landed, so re-run the discovery greps
(`: TaskFrame`, `TaskFrame .* where`, `.mk`) and reconcile against the table before adding any
field; treat any newly-appeared site as in scope and any disappeared site as resolved.
Reference counts (39 `nullity_identity`, 40 `forward_comp` across 12 live files) are likewise
hypotheses to re-confirm.

**Constraints**:
- No task-number citations in any Lean file (cite `def:frame` sub-anchors, `lem:step`,
  filenames — durable anchors only).
- Notation: converse operations use `inv`/`⁻¹` vocabulary (e.g. `TaskRel.inv`, consistent with
  Mathlib's `Inv`) — never breve/smile.
- Lean v4.33.0-rc1, Mathlib pinned to tag v4.33.0-rc1.
- No `sorry`, no new axiom, no vacuous/inert field.

**Verification**:
- `lake build` — green
- `grep -rn "sorry" FormalSystem/` shows no new occurrences relative to the pre-phase baseline
- `#print axioms` on touched frames and the `lem:step` counterpart — no new axiom
- `countermodel_dense_enriched`, `completeness`, `completeness_dense`, and the
  CompletenessDedekind.lean probes still elaborate against the replacement carrier
- The `spherical` field appears as a hypothesis consumed by the `lem:step` counterpart's proof
  term (inspect, and record the consuming declaration name in the summary) — the acceptance
  criterion, not merely typechecking

---

## Testing & Validation

- [ ] `lake build` green after each of Phases 7-9 (and after Phase 10's single batch, once
      unblocked); Phase 6 is LaTeX-only
- [ ] `cd latex/subfiles && TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 02-Semantics.tex`
      exits clean (Phase 6)
- [ ] `cd latex && latexmk BimodalReference.tex` green, no duplicate-label warnings (Phase 6)
- [ ] `grep -n "sorry" FormalSystem/Semantics/TaskFrame.lean` returns nothing
- [ ] `#print axioms` on every new definition/theorem — only the standard Lean axioms
- [ ] `grep -rn "possible_worlds.tex:[0-9]" FormalSystem/ --include=*.lean` returns nothing
      after Phase 9
- [ ] `grep -rn "Limit Nullity" FormalSystem/ --include=*.lean` returns nothing after Phase 9
- [ ] `bash scripts/check-paper-definitions.sh` still exits 0 silent (no anchor drift
      introduced by any phase)
- [ ] No task-number citation in any changed file outside `specs/**`
      (`bash .claude/scripts/check-task-references.sh` if available, else grep the diff)
- [ ] `git status` shows no stray edits outside the phases' declared file sets

## Artifacts & Outputs

- `specs/420_align_task_frame_with_positive_cone_axioms/plans/02_four-axiom-frame-alignment.md`
  (this file)
- `specs/420_align_task_frame_with_positive_cone_axioms/summaries/02_four-axiom-frame-alignment-summary.md`
  (on completion of the next dispatch)
- `latex/subfiles/02-Semantics.tex` — four-axiom frame definition with apparatus (Phase 6)
- `latex/assets/bimodal-notation.sty` — new macros, only if needed (Phase 6)
- `FormalSystem/Semantics/TaskFrame.lean` — apparatus definitions (Phase 7), `identityFrame`
  repair (Phase 8), docstring/naming/citation corrections (Phase 9), structure change (Phase
  10, blocked)
- `FormalSystem/Semantics/WorldHistory.lean` — two docstring corrections (Phase 9)
- Phase 8 consumer sites as its chosen option requires

**Deferred, recorded for follow-up (do not implement here)**:
- The `nullity_identity` design decision and the `PartialHistory`/`WorldHistory` nonemptiness
  layering — JOINT WITH 414 (framed in Open Design Questions; layering lands once, before the
  consequence refactor)
- The `lem:constraint`/`lem:fibers`/`lem:admissible`/`lem:step`/`thm:extension`/
  `cor:occurrence` lemma chain itself (414-coordinated; Phase 10's acceptance criterion binds
  the *Spherical* seam)
- The cone-topology T1 result (`exists_uniform_radius_of_finite` is the sanctioned substitute)
- `typst/chapters/02-semantics.typ:37` (stale Nullity) and `typst/SYNC-MAP.md:230` (pre-refactor
  range) — flagged in v1, still out of scope
- Collapsing the duplicated frame bodies into thin wrappers (v1 deferred item, carried)

## Rollback/Contingency

- Phases 6-9 are each small and independently revertible: Phase 6 is LaTeX-only (cannot affect
  `lake build`); Phase 7 adds standalone definitions nothing yet consumes; Phase 9 is
  prose/citation edits plus an optional grep-gated rename. Phase 8 spans four files but is one
  scoped commit; revert restores the (defective but building) `identityFrame`.
- If Phase 7's cone or segment encoding resists a clean Lean statement, land the subset that
  transcribes cleanly (Fib and DirectedFamily are unconditionally simple) and record the
  remainder as the FIRST task of Phase 10's batch — never `sorry` a definition.
- If Phase 8's option (a) frame cannot discharge a current field, fall back to option (b)
  (delete + repoint) — the three consumers are enumerated and small.
- Phase 10, once unblocked: on a failed batch, the snapshot-then-rollback ladder applies
  (`git-snapshot.sh` before any destructive recovery); the batch is one objective, so a failed
  attempt reverts to the last green pre-batch commit with Phases 6-9 intact.
- **Terminal state for the next dispatch**: with Phases 6-9 green and committed and Phase 10
  blocked, the correct task status is `[BLOCKED]` on task 415 (phase-level wait — do NOT
  re-add the `dependencies[]` edge). Marking the task `[COMPLETED]` with Phase 10 open would
  misrepresent the state; a `sorry` or placeholder axiom to close it early is explicitly
  forbidden.
