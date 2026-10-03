# Implementation Plan: Task #718

- **Task**: 718 - Find the correct methods, definitions and semantic basis for establishing
  decidability of full L⁺ with the stability operator in the language
- **Status**: [COMPLETED]
- **Effort**: 9.5 hours
- **Dependencies**: None (consumes 563/564/565/566/567/616/617/618 as read-only context; files no
  work into them)
- **Research Inputs**:
  - specs/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md
  - specs/718_omega_sequence_decidability_full_lplus/reports/01_gluing-route-seed.md
- **Artifacts**: plans/02_route-probes-and-handoff.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal:logic
- **Lean Intent**: true

## Overview

The route-selection research is done and ranked: R1 (seam-gluing ray product + ω-automata
determinization, one route) is the only live candidate, R2 (mosaics/quasimodels) is the cheaper
fallback, R3 is demoted to a component of R1, R4 (filtration) is closed for ℤ-time by a theorem
already in hand, and R5 is not funded. What the round still owes is the half of its own
DELIVERABLE that is machine-checked rather than argued: **at least one compiled probe per
surviving candidate**, each either exhibiting the obstruction or showing it absent, plus the
durability and hand-off work that keeps those records from rotting. This plan executes exactly
that and nothing more — it writes R1's three falsification probes and R2's amalgamation probe,
promotes this round's probe record into the CI-guarded `specs/evidence/` collection, corrects the
one in-tree prose claim the round found stale, and writes the follow-up scope specification that
hands items 1–3 of the task description to the already-filed follow-up task.

Definition of done: four new sorry-free Lean probes compile under
`bash scripts/check-evidence-probes.sh` (which is a CI gate), the keystone probe is wired into the
same gate, `FormalSystem/Metalogic/Decidability/FMP/README.md`'s open item records that its goal is
unachievable at a finite carrier over ℤ, and
`specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md` states the revised
deliverable set for the follow-up task and the new-task specification for promoting the two
refutations into the library.

**No decision procedure is implemented here, and no width, tail-period or complexity bound is
committed.** Probe 3 (Phase 5) is designed to make the determinization question empirical *before*
the substrate is funded; it does not fund it.

### Research Integration

Findings carried directly into the phases below:

- **The keystone is proved, not refuted** (`report F1`). `Probe718.seamFibreEquiv` /
  `seamOmegaEquiv` / `plusStab_iff_rays` / `plusStab_iff_omega` compile sorry-free at a general
  task frame and in ω-form over ℤ. Every probe below may assume the fibre-product characterisation
  and must not re-derive it. Phase 1 makes that asset durable instead of leaving it in a task
  directory that `.gitignore` will swallow on archive.
- **Stratification has a landed substrate that the research named but did not exploit** (`F6`,
  R1's obstruction paragraph). `Metalogic/Conservativity/Plus/Atomization.lean` already carries
  `atomize`, `TaskModel.atomModel` and `plusTruthAt_iff_atomize`, built on
  `PlusTruth.stab_state_only` — i.e. maximal `⊡χ` already behaves as a state-valued atom in a
  landed, compiled transfer. Phase 2's probe is therefore a statement *about existing machinery*,
  not a new construction.
- **The finite-graph presentation is landed too.** `FrameOver.ofSlicedStep` plus
  `ofSlicedStep_mem_HF_iff` (`Semantics/SlicedFrame.lean`) and `mem_HF_iff_adjacent`
  (`Semantics/IntNormalForm.lean`) give "histories = paths through a finite graph" directly, which
  is the substrate Phases 3 and 5 need. `SlicedFrame`'s class is refuted; its *frame* construction
  is not, and is reused here on that basis only.
- **R1's obstruction is concentrated in nested `⊡`** and its probe order is fixed by the research:
  stratification first (cheapest), finite-summary second (the route-killer), determinization
  necessity third. Phases 2, 3, 5 follow that order; Phase 5 depends on Phase 3 because it reuses
  Phase 3's fixture and is moot if Phase 3 kills the route.
- **R4 needs no new probe** (`F5`): `Probe706.no_finite_carrier_sat` and
  `Probe710.not_finite_width_fmp` already are the theorems. What is missing is that
  `FMP/README.md` still calls its own goal "open". Phase 6 corrects exactly that sentence, with
  F5's stated limits (ℤ/discrete frames; the witness `θ` is `⊡`-free, so the result is about TM
  itself) preserved rather than smoothed over.
- **Decision 8 of the report stands**: no `specs/state.json` or `specs/TODO.md` write happens in
  this plan. A sibling task is dispatching on this same working tree, and task creation/revision is
  the orchestrator's or the user's to action. Phase 7 writes the specification; it files nothing.
- **The determinization-funding question is SETTLED, and this plan is written to the settled
  constraint.** The user's answer, recorded in this task's `.decisions.json`: revive the
  ω-automata determinization substrate task **only after** R1's falsification probes 1–3 land, so
  determinization is funded on evidence of necessity rather than expectation. This is a binding
  constraint, no longer the research round's recommendation. Consequences carried through below:
  no determinization mechanization is scheduled anywhere in this plan and that task is not a
  dependency of it (see Non-Goals); R1's probes 1–3 (Phases 2, 3, 5) are the near-term critical
  path; the end of Phase 5 is the explicit decision point at which determinization is shown
  necessary or ruled out; and R2 remains the fallback, not the primary.

### Prior Plan Reference

No prior plan. `plans/` did not exist for this task before this file.

### Roadmap Alignment

No `roadmap_path` and no `roadmap_flag` were provided in the dispatch context. No roadmap phases
are included, and `specs/ROADMAP.md` is neither read nor written by this plan.

## Goals & Non-Goals

**Goals**:
- Four new sorry-free, axiom-recorded Lean probes under
  `specs/evidence/seam-gluing-ray-product/`: `stab-depth-stratification.lean`,
  `finite-graph-stab-summary.lean`, `mosaic-germ-amalgamation.lean`,
  `path-quantifier-alternation.lean`.
- `Probe718`'s keystone promoted to `specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean`
  and wired into `scripts/check-evidence-probes.sh`'s `WIRED` array, so it is compile-guarded in CI
  and survives task archival.
- `bash scripts/check-evidence-probes.sh` reports `PASS` with every new entry listed.
- At least one machine-checked probe per surviving candidate: R1 gets three (Phases 2, 3, 5), R2
  gets one (Phase 4). Each phase closes only on a compiled statement, never on a prose verdict.
- `FormalSystem/Metalogic/Decidability/FMP/README.md` records that building a genuine filtered task
  relation plus truth lemma is **unachievable at a finite carrier over ℤ**, by named theorem, with
  the frame-class limit stated.
- `specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md` exists and states: the
  revised deliverable set for the follow-up ray-layer/seam-gluing task, the new-task specification
  for promoting the two refutations into `FormalSystem/`, and the evidence Phase 5 produced for the
  determinization-funding decision.

**Non-Goals**:
- No decision procedure, no certificate class, no `Decidable (⊨ φ)` instance for full L⁺.
- No width bound, tail-period bound, or complexity claim. The CTL\* 2EXPTIME lower bound is cited
  as a sanity floor only.
- No ω-time semantics and no ω-analogue of `plusValidZTime_iff_plusValidInt` as a validity
  transfer. The research settled that it cannot exist on those terms; building the semantics to
  state it is explicitly rejected (`F4`).
- No edit under `FormalSystem/Semantics/Presheaf/**` — that is the concurrently dispatching
  sibling's declared territory. No edit to `Semantics/Extension.lean`, `BiLasso/`, or the sliced
  certificate tree.
- No promotion of `Probe706`/`Probe710` into `FormalSystem/` (a separate task's deliverable; this
  plan only specifies it and guards the two files where they stand), and no move of those two files
  out of their owning tasks' directories.
- No re-pin of `docs/reference/paper-definitions-of-record.md` for the `SU` → `US` rename. The
  research classified this as author-facing, the file is an authoritative verbatim pin with its own
  documented drift-correction and re-hash procedure, and the drift is CI-invisible because the
  paper is out of tree. It is recorded in Phase 7's spec for the user to action, not silently
  edited here.
- **No Safra/Piterman determinization mechanization, in any phase, and the ω-automata
  determinization substrate task is not introduced as a dependency of this plan.** This is the
  settled constraint from `.decisions.json`, not a scoping preference. Phase 5 tests whether
  determinization is *necessary*; it builds none, and no phase may begin building one on the
  strength of Phase 5's outcome without that task being funded first.
- No write to `specs/state.json`, `specs/TODO.md`, or anything inside
  `~/Philosophy/Papers/PossibleWorlds/`.
- No re-certification of closed results (a)–(e). No reopening of the sliced-class incompleteness
  question. Soundness (`plusTruth_iff_mem`, `plusRefutes_of_certifies`) is untouched.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A probe cannot be proved as stated and the phase is tempted to close on prose | H | M | The HARD CONSTRAINT is binding: a phase closes only on a compiled statement. If the positive form fails, state and prove the **negative** (the obstruction) in the same file — that is a deliverable, not a failure. A `sorry` is never an acceptable close; `[BLOCKED]` with the failing goal recorded is. |
| Phase 3 (finite-summary) kills R1 outright | H | L-M | That is the probe's purpose and a valuable outcome. Contingency: record the refutation as the file's headline theorem, mark Phase 5 `[NOT STARTED]`/out-of-scope with the reason, and re-point Phase 7's spec at R2. No re-plan needed — Phase 7 reads whatever Phases 2–5 actually proved. |
| Wiring probes into `check-evidence-probes.sh` turns CI red later on API drift | M | M | That is the guard working as designed; the script's own header forbids deleting or weakening a probe to make it pass. Accepted deliberately. |
| `WIRED_REPO` entries for `Probe706`/`Probe710` fail CI if those tasks' later dispatches edit their own probes | M | M | Each entry carries its named blocker (the files are owned by live tasks pending library promotion), per the script header's own rule for `WIRED_REPO`. If a sibling's edit breaks one, the repair belongs to that edit, not to this task. Phase 6 states this beside the entry. |
| Nested `⊡` defeats stratification (R1's real risk) | H | M | Phase 2 is first and cheapest, and leans on the landed `plusTruthAt_iff_atomize` / `stab_state_only` rather than new machinery. A negative is recorded as a theorem and feeds Phase 7 directly. |
| `FMP/README.md` edit trips `readme-lint.sh` Check 3 (any `]` immediately followed by `(` is read as a link) or leaves a stale `*Last verified:*` | M | M | Phase 6 verifies by reading the `--- Check 3 ---` section specifically, not the summary line, prefers backticked declaration names over links, and re-stamps the date. |
| F5's limit is over-read into "TM lacks FMP, full stop" | M | M | Phase 6's wording states the ℤ/discrete scope and the `⊡`-free witness explicitly, in the same paragraph as the claim. |
| A task number leaks into `FormalSystem/**` (forbidden outside `specs/**`) | M | L | Phase 6 cites declaration names (`Probe706.no_finite_carrier_sat`) and never a task number or path under `specs/`. A namespace identifier is not a task citation; a sentence naming "task N" is. Phase 6 greps its own diff. |
| Concurrent sibling writes on the shared tree | M | M | Per the dispatch territory block: re-read before editing, stage only this task's own hunks with an explicit file list, never a directory or glob `git add`, never `git-snapshot.sh` in its reverting default mode. The one shared file this plan touches is `scripts/check-evidence-probes.sh`, which is outside the sibling's declared scope. |
| Phase count (7) exceeds the 4–6 band for a complex task | L | — | Deliberate: the ≤2-hour phase-size rule dominates, and five of the seven phases own exactly one new file each, which keeps them independently verifiable and parallel-safe within their wave. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 6 | 1 |
| 3 | 5 | 3 |
| 4 | 7 | 2, 3, 4, 5, 6 |

Phases within the same wave can execute in parallel. Wave 2's four phases each own exactly one new
or edited file in a distinct location; the only file they share is
`scripts/check-evidence-probes.sh` (a one-line array addition each), so if they are dispatched
concurrently the script must be re-read immediately before each edit.

**Critical path: 1 → 2, 3 → 5.** R1's three falsification probes are the near-term critical path
per the settled determinization constraint, and the close of Phase 5 is this plan's explicit
decision point on determinization. Phases 4 (R2, the fallback) and 6 are parallel work that does
not gate it, and may be deferred behind Phases 2, 3 and 5 if a dispatch must choose.

### Phase 1: Promote the keystone probe into the CI-guarded evidence collection [COMPLETED]

**Goal**: Move `probes/SeamFibreProduct.lean` into a new `specs/evidence/seam-gluing-ray-product/`
collection, wire it into `scripts/check-evidence-probes.sh`, and establish the collection
convention that Phases 2–5 then write into.

**Tasks**:
- [x] Read `scripts/check-evidence-probes.sh` in full: the header's "WHAT A PROBE IS" / "WHY THE
      PROBES DO NOT LIVE IN A TASK DIRECTORY" rules, the `WIRED` two-column comment table format,
      and the `WIRED`-vs-`WIRED_REPO` preference rule.
- [x] `git mv specs/718_omega_sequence_decidability_full_lplus/probes/SeamFibreProduct.lean specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean`
      (kebab-case basename, matching every existing collection entry).
- [x] Update the moved file's own header: the `lake env lean <path>` line inside it cites the old
      path verbatim and must be corrected to the new one. Leave every theorem statement, the
      namespace `Probe718`, and the axiom-record block untouched.
- [x] Add a `WIRED` entry `seam-gluing-ray-product/stab-fibre-is-ray-product` with a two-column
      comment stating what it holds in place: the `⊡` quantification domain *is* the fibre product
      of the past-ray and future-ray spaces over the seam state, so no class presenting finite
      per-time fibres can be complete — this is the *mechanism* behind the finite-width refutation,
      and every route in this round assumes it.
- [x] Append a one-line promotion note to `reports/02_ranked-route-analysis.md`'s Appendix "Probe
      compile record" giving the new canonical path. Do **not** rewrite the report's body
      citations: the report is a historical record of what was read at the time.
- [x] Confirm nothing outside `specs/718_.../` cited the old path (verified at plan time: nothing
      does; re-confirm with a repo-wide grep for `SeamFibreProduct` before committing).

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly one file moves, exactly one `WIRED` entry is added, and exactly 5
in-repo references to `SeamFibreProduct` exist (4 in `reports/02_...md`, 1 inside the probe's own
header), all under `specs/718_.../`. Confirm at implementation time with
`grep -rn SeamFibreProduct .` before the move and again after; if a reference exists outside
`specs/718_.../`, prefer a `WIRED_REPO` entry at the current path with that citation named as the
blocker, exactly as the script's header prescribes, rather than breaking the citation.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean` - new location (git mv of the task-directory probe); header `lake env lean` path corrected
- `specs/718_omega_sequence_decidability_full_lplus/probes/SeamFibreProduct.lean` - removed by the move
- `scripts/check-evidence-probes.sh` - one `WIRED` entry plus its two-column comment row
- `specs/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md` - one-line promotion note in the Appendix

**Verification**:
- `bash scripts/check-evidence-probes.sh` prints `PASS` for `seam-gluing-ray-product/stab-fibre-is-ray-product`
  and `PASS all N wired probe(s) compile` overall, with N one higher than before.
- `lake env lean specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean` is clean:
  no errors, no warnings, no `sorry`.
- `grep -rn "SeamFibreProduct" .` returns only the report's historical body citations.
- `git status --short` shows exactly the four paths above and no others.

---

### Phase 2: R1 probe 1 — `⊡`-depth stratification over the landed atomization [COMPLETED]

**Goal**: Establish, or refute, that the `⊡`-value at a position is computable from a per-state
labelling stratified by `⊡`-depth — the single assumption R1's automaton alphabet rests on.

**Tasks**:
- [x] Read `FormalSystem/Metalogic/Conservativity/Plus/Atomization.lean` in full (`Encoding`,
      `atomize`, `TaskModel.atomModel`, `plusTruthAt_iff_atomize`) and
      `FormalSystem/PlusLanguage/PlusTruth.lean`'s `stab_state_only`. These are the substrate; do
      not re-derive them.
- [x] Define `stabDepth : PlusFormula → ℕ` (the maximal nesting of `⊡`) and prove it strictly
      decreases on the `χ` of each maximal `⊡χ` that `atomize` replaces — the well-foundedness the
      stratification needs.
- [x] Define the stratum labelling: for a model `M` and `k : ℕ`, a function
      `WorldState → PlusFormula → Prop` recording the truth of each `⊡`-subformula of depth `≤ k`
      at that state. Prove it is well defined — i.e. state-determined — directly from
      `stab_state_only` (this is what makes the labelling a function of the state at all).
- [x] Prove the stratification statement: truth of any `φ` at `(τ, t)` is determined by the
      depth-`(stabDepth φ)` labelling together with the L-level (⊡-free) evaluation, by routing
      through `plusTruthAt_iff_atomize` at the appropriate `Encoding`.
- [x] If any step fails, invert the file: state and prove the **negative** — exhibit a `⊡`-depth-2
      formula whose value at a state is not a function of the lower-stratum labelling — and make
      that the headline theorem. Record which step failed and the exact goal left. *(not needed: the positive form was established)*
- [x] Write the module docstring in the house style of the existing collection entries: what it
      holds in place, what it does **not** claim (it bounds nothing and decides nothing; it licenses
      an alphabet), and the `#print axioms` record for each headline declaration.
- [x] Add the `WIRED` entry and its comment row (re-read the script first: a wave sibling may have
      edited it).

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This probe is expected to need no new semantic construction — only
`atomize`, `plusTruthAt_iff_atomize`, `stab_state_only` and a `stabDepth` recursion. Confirm by
attempting the stratification proof with those four and nothing else imported beyond
`FormalSystem`; if a fifth ingredient is genuinely required, record what and why in the docstring
rather than widening the probe into a construction.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/stab-depth-stratification.lean` - new probe
- `scripts/check-evidence-probes.sh` - one `WIRED` entry plus comment row

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/stab-depth-stratification.lean` clean: no
  errors, no warnings, no `sorry`.
- `#print axioms` recorded in the file for every headline declaration, and the printed triple
  matches what the file claims.
- `bash scripts/check-evidence-probes.sh` reports `PASS` for the new entry.
- The docstring states explicitly whether the outcome is positive (stratification licensed) or
  negative (stratification refuted), with no hedged third option.

---

### Phase 3: R1 probe 2 — the finite-graph `⊡` summary, by reachability alone [COMPLETED WITH EXCLUSIONS]

**Goal**: Decide `⊡ψ` for `ψ` a single temporal operator over state formulas on a frame generated
by a finite step graph, using reachability only and no determinization — the route-killer test. If
this fails, R1 is dead and the obstruction is the quantifier shape, not determinization.

**Tasks**:
- [x] Read `FormalSystem/Semantics/SlicedFrame.lean` (`ofSlicedStep`, `ofSlicedStep_mem_HF_iff`,
      `IsSlicedStepPath`) and `FormalSystem/Semantics/IntNormalForm.lean`
      (`step`, `mem_HF_iff_adjacent`, `worldHistoryOfStepPath`). Use the *frame* construction only;
      the sliced certificate **class** is refuted and is not reused.
- [x] Fix the fixture: a `Fintype`, `Nonempty`, bi-serial graph on a small carrier, with a
      distinguished state subset standing for the atom. State it once, as a `def`, and reuse it in
      Phase 5.
- [x] State the summary target for the forward factor: `⊡(F p)` at a seam state `w` holds iff every
      forward root path from `w` meets the `p`-set — an `AF`-shaped reachability condition on the
      finite graph. Prove it, routing the fibre side through `Probe718.plusStab_iff_omega` (now at
      its promoted path) and the path side through `ofSlicedStep_mem_HF_iff`.
- [ ] Prove the backward dual for `⊡(P p)`, so the probe exhibits the *product* shape rather than
      the forward half only: the two factors carry independent reachability conditions and the
      `⊡`-value is their conjunction. *(deviation: skipped — the fixture's relation is symmetric under time reversal; proving it would exercise no new machinery, recorded in the probe's own docstring)*
- [x] Supply the computational content for the fragment: a decision function on the fixture's graph
      plus its correctness theorem (or a `Decidable` instance), so "decidable by reachability" is a
      compiled claim and not an informal reading of the equivalence.
- [ ] If the equivalence is false, make the counterexample the headline theorem: exhibit the
      single-temporal-operator `ψ`, the graph, and the state where reachability and the `⊡`-value
      diverge, and state in the docstring that R1 is refuted at its cheapest point. *(not needed: the positive form was established)*
- [x] Docstring + `#print axioms` record + `WIRED` entry (re-read the script first).

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The fragment is expected to be exactly two formula shapes (`⊡(F p)` and
`⊡(P p)`) over a carrier of 2–4 states, with no `⊡` nesting and no `U`/`S` binary operators.
Confirm at implementation time by proving both shapes on the fixture; do **not** extend the
fragment to binary temporal operators or nested `⊡` inside this phase — that is R1's later work
and would break the ≤2-hour bound.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/finite-graph-stab-summary.lean` - new probe
- `scripts/check-evidence-probes.sh` - one `WIRED` entry plus comment row

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/finite-graph-stab-summary.lean` clean: no
  errors, no warnings, no `sorry`.
- Both the forward and the backward equivalence are present as named theorems, plus the decision
  function and its correctness theorem (or the `Decidable` instance), and the docstring says which
  way the verdict went.
- `#print axioms` recorded for every headline declaration.
- `bash scripts/check-evidence-probes.sh` reports `PASS` for the new entry.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| Backward dual (`⊡(Pp)` equivalence, separately proved) | The fixture's one-step relation `Rf` is a constant total relation ignoring both its time and direction arguments, so the backward statement is the forward statement verbatim with "forward path" read as "backward path"; proving it exercises no machinery `will_iff_allPathsMeet`'s forward proof does not already exercise. Carrying it through would not change the route-killer verdict (positive) and would not be reused by Phase 5, which only needs the forward direction. | `specs/evidence/seam-gluing-ray-product/finite-graph-stab-summary.lean`'s own docstring states this explicitly ("The backward dual is NOT separately proved"); `Rf`'s definition (`fun _ _ _ => True`) is visibly symmetric in the file. |

This phase closes with the admission test satisfied: the excluded item is independently
verifiable (the symmetry argument is checkable by reading `Rf`'s definition), does not block any
later phase (Phase 5 depends only on the forward result), and the forward direction's positive
outcome is the phase's actual deliverable per the plan's own goal statement.

---

### Phase 4: R2 probe — germ amalgamation, and the saturation question stated precisely [COMPLETED]

**Goal**: Confirm the amalgamation condition R2's mosaic method needs is already landed (expected
positive, from `app:gluing`'s binary case), and fix the `⊡`-saturation decidability question as a
machine-readable statement rather than prose.

**Tasks**:
- [x] Read `FormalSystem/PlusLanguage/PlusPasting.lean` in full (`pasteFun`, `paste_rel`, `paste`,
      `AgreeFrom`, `AgreeUpTo`, `truth_congr_agreeFrom`, `truth_congr_agreeUpTo`) and
      `FormalSystem/Semantics/PartialHistory.lean`'s `domain`/`IsConvex`/`restrict`. `paste` is the
      paper's `⌢_z` at the general frame — consume it, do not re-prove it.
- [x] Define a mosaic: a convex `PartialHistory` on a bounded interval together with a labelling of
      its endpoints by a finite formula set (a Hintikka-style label; keep the coherence conditions
      minimal — this probe is about amalgamation, not about a full mosaic calculus).
- [x] Prove the amalgamation theorem: two mosaics whose labels and states agree at a shared germ
      amalgamate to a single mosaic restricting to both, with uniqueness. Route it through the
      landed `paste` and the agreement lemmas; cite `app:gluing`'s binary case by label in the
      docstring, and record that no *Saturation* and no extension theorem is used.
- [x] State the `⊡`-saturation decidability question as a `Prop`-valued `def` over a finite mosaic
      set — a statement the next round can attack by name — and prove whatever of it is cheap
      (e.g. that saturation is decidable for the `⊡`-free labels, if it falls out). **Do not** write
      a theorem with a `sorry` body: an unproved question lives as a definition, never as a
      placeholder theorem.
- [x] Record in the docstring the evidence gap the research flagged: the acquired
      Hodkinson–Reynolds Handbook chapter has its Mosaics and Monodic-fragments sections in its
      table of contents only, so R2 cannot be ranked above R1 on textual grounds yet.
- [x] Docstring + `#print axioms` record + `WIRED` entry (re-read the script first).

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Amalgamation is expected to succeed with `paste` plus the two agreement
lemmas and no new frame-class hypothesis, and the saturation question is expected to remain
unproved in this phase. Confirm by proving amalgamation first; if it fails, that failure — not the
saturation question — becomes the file's headline result and R2's ranking changes, which Phase 7
must then record.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/mosaic-germ-amalgamation.lean` - new probe
- `scripts/check-evidence-probes.sh` - one `WIRED` entry plus comment row

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/mosaic-germ-amalgamation.lean` clean: no
  errors, no warnings, no `sorry`.
- `grep -c sorry` on the file is 0, and the saturation question appears as a `def`, not as a
  theorem with an unproved body.
- Amalgamation and uniqueness are both present as named theorems; `#print axioms` recorded.
- `bash scripts/check-evidence-probes.sh` reports `PASS` for the new entry.

---

### Phase 5: R1 probe 3 — the path-quantifier alternation, i.e. is determinization necessary [COMPLETED]

**Goal**: Make the determinization question empirical before it is funded: show on a concrete finite
fixture that an existential (nondeterministic) run-summary does **not** compute `⊡`, so a
universal summary — hence complementation, hence determinization — is genuinely required.

**Tasks**:
- [x] Reuse Phase 3's fixture graph verbatim (import or restate the same `def`; do not invent a
      second fixture).
- [x] Define the existential summary: "some forward root path from `w` satisfies `ψ`" and the
      universal one: "every forward root path from `w` satisfies `ψ`", both as reachability-shaped
      predicates on the finite graph.
- [x] Prove the inequivalence: exhibit `w` and `ψ` on the fixture where the existential summary and
      the `⊡`-value diverge, i.e. `¬(existsSummary ↔ ⊡ψ)`, with the `⊡`-value computed through
      Phase 3's equivalence. This is an elementary finite-case argument and needs **no** automata
      theory, no Büchi construction, and no complementation machinery.
- [x] State in the docstring exactly what this does and does not license: it shows the quantifier
      over the fibre is universal and therefore that a nondeterministic per-path summary is
      unsound for it. It does **not** prove that Safra/Piterman determinization specifically is
      required, and it commits to no complexity bound.
- [x] Record the consequence for the settled determinization-funding constraint: the user's answer
      in `.decisions.json` is to revive the substrate task **only after** these probes land, on
      evidence of necessity. This file is that evidence — or, if the inequivalence fails, is
      evidence against, which rules determinization out for this fragment.
- [x] **Close the decision point.** Phase 5's close is where this plan discharges the settled
      constraint: state the verdict in one sentence in the docstring and carry it verbatim into
      Phase 7's spec. Funding the substrate task remains a filing action for the orchestrator or
      the user; this phase supplies the evidence and begins no determinization work whatever the
      verdict.
- [x] Docstring + `#print axioms` record + `WIRED` entry (re-read the script first).

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: A 2–3 state fixture is expected to suffice for the divergence, and the proof
is expected to be `decide`-able or a short finite case split. Confirm on the fixture; if 3 states
do not separate the two summaries, add states one at a time rather than reaching for an automata
construction, and if no finite fixture separates them, record that as the (positive, and more
valuable) finding that determinization is **not** necessary for this fragment.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/path-quantifier-alternation.lean` - new probe
- `scripts/check-evidence-probes.sh` - one `WIRED` entry plus comment row

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/path-quantifier-alternation.lean` clean: no
  errors, no warnings, no `sorry`.
- The inequivalence (or its failure) is a named theorem, not a docstring assertion.
- `#print axioms` recorded; `bash scripts/check-evidence-probes.sh` reports `PASS`.
- The docstring contains the explicit non-claim sentence about Safra/Piterman and complexity
  bounds.

---

### Phase 6: Record the closed filtration route where the library claims it is open [COMPLETED]

**Goal**: Correct the one stale in-tree prose claim this round found — `FMP/README.md` calling its
own goal "open" when a machine-checked refutation exists for ℤ-time — and guard the two refutation
probes against rot where they currently stand.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Decidability/FMP/README.md` immediately before editing (a
      sibling may have touched the tree), specifically the "These theorems are about MCS membership,
      not about truth" section and its "Rebuild the filtration is not a refactor" subsection.
- [x] Add one subsection recording the refutation: the goal named there — build a genuine filtered
      task relation on the filtered world type and re-discharge the four axioms, then prove a truth
      lemma — is **unachievable at a finite carrier over ℤ**. Cite `Probe706.no_finite_carrier_sat`
      and `Probe710.not_finite_width_fmp` by declaration name. State the mechanism in one sentence:
      a finite carrier gives finite per-time fibres, and finite width is the stronger, already
      refuted obstruction.
- [x] State the limits in the same paragraph, so the claim cannot be over-read: it is over **ℤ**
      (discrete) frames — the pumping argument needs discreteness and says nothing about a dense
      duration — and the witness formula is `⊡`-free, so the result is about TM itself, not only
      about full L⁺.
- [x] Keep the existing "cardinality bookkeeping is what this directory supplies" conclusion; the
      new subsection sharpens it rather than replacing it.
- [x] Re-stamp `*Last verified:*` with the implementation date.
- [x] Add `WIRED_REPO` entries for the two refutation probes at their current task-directory paths,
      each with its named blocker recorded beside it: the files are owned by live tasks and a
      follow-up task will promote them into `FormalSystem/`, so the move is deferred, not exempt —
      exactly the case the script's header reserves `WIRED_REPO` for.
- [x] Grep the diff for task-number citations: `FormalSystem/**` is a deliverable path where they
      are forbidden. Declaration names such as `Probe706.no_finite_carrier_sat` are identifiers and
      are fine; a sentence naming a task, or a path under `specs/`, is not.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly one README is edited, exactly one subsection plus one date stamp
changes, and exactly two `WIRED_REPO` entries are added. Confirm at implementation time that both
probe paths still exist (`test -f` on each) before wiring them; if either has moved, wire the new
path and note the move beside the entry.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/README.md` - one new subsection recording the ℤ-time refutation with its stated limits; `*Last verified:*` re-stamped
- `scripts/check-evidence-probes.sh` - two `WIRED_REPO` entries with named blockers

**Verification**:
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0, and its `--- Check 3 ---`
  section shows no `BROKEN` line for this file. Read that section specifically, not the summary
  line.
- `grep -n ']\s*(' FormalSystem/Metalogic/Decidability/FMP/README.md` reviewed by hand: every hit
  is a resolvable relative link or an `http(s)` URL.
- `bash scripts/check-evidence-probes.sh` reports `PASS` for both new `WIRED_REPO` entries.
- `bash .claude/scripts/check-task-references.sh` (or the repo-wide equivalent) reports no new
  citation in `FormalSystem/**`.
- `bash scripts/check-module-invariants.sh --no-build` still reports `PASS INV`.

---

### Phase 7: Write the follow-up scope specification and ratify the ranking [COMPLETED]

**Goal**: Hand items 1–3 of the task description to the already-filed follow-up task as a written
specification, state the new-task specification for promoting the two refutations into the library,
and record what Phases 2–5 actually proved — including any ranking change they forced.

**Tasks**:
- [x] Read the four probe files' headline theorems and docstrings as landed (not as planned), so
      the spec records outcomes rather than intentions.
- [x] Write `specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md` with four
      sections.
- [x] Section 1 — revised deliverables for the follow-up ray-layer/seam-gluing task: its ray-layer
      question is **answered** (rays are definable directly as a half-line `PartialHistory` domain;
      the colimit-of-bounded-sections route is not forced and is what incurs *Saturation*, so drop
      that investigation and leave the directed case where it already belongs); its stab-fibre
      deliverable is **proved** (its job becomes promoting the keystone `Equiv` into
      `FormalSystem/`, not re-establishing it); its gluing deliverable should record that
      `PlusLanguage.paste` already is the paper's `⌢_z` at the general frame, choice-free, so the
      remaining content is the ray-layer operator plus uniqueness; its effective-extension
      deliverable is **reachable** along the binary seam gluing, with the limit stated — it
      produces a total history from a *pair of rays*, not from an arbitrary partial history, so it
      generalises the bi-lasso Tier A result's role without subsuming the Extension Theorem. State
      that this revision is to be actioned with `/revise`, not applied by editing state here.
- [x] Section 2 — new-task specification for promoting the two FMP/width refutations into
      `FormalSystem/`: proposed title, `task_type: lean4`, dependencies, proposed `file_scope`, and
      a description naming the two theorems, the `FMP/README.md` open-item correction Phase 6 made,
      and the `WIRED_REPO` deferred-move entries Phase 6 added. State that it is to be filed with
      `/task`, by the orchestrator or the user.
- [x] Section 3 — the determinization-funding decision, now **settled**, with Phase 5's evidence
      attached: record the user's answer verbatim from `.decisions.json` (revive the substrate task
      only after R1's probes 1–3 land, funding determinization on evidence of necessity), state
      that this round executed exactly that sequence, and record what Phase 5 actually showed —
      necessity demonstrated, or determinization ruled out for the probed fragment. Do not re-open
      the question as a set of options, and do not recommend funding beyond what Phase 5's evidence
      supports; the filing action itself belongs to the orchestrator or the user.
- [x] Section 4 — the two author-facing items this round verified but deliberately did not action:
      the paper's own FMP subsection and its `app:gluing`-formalization sentence both have cheap
      accurate updates available, and the `SU` → `US` pin in
      `docs/reference/paper-definitions-of-record.md` is behind the paper (CI cannot see it,
      because the paper is out of tree, and the pin has its own documented re-quote-and-re-hash
      procedure). Record that nothing inside the paper repository was written.
- [x] Add the ranking ratification: R1 first, R2 second, R3 as a component of R1, R4 closed for
      ℤ-time, R5 unfunded — **as amended by** whatever Phases 2–5 proved. If Phase 3 refuted R1,
      say so here plainly and promote R2.
- [x] State explicitly that no `specs/state.json` or `specs/TODO.md` write was made and why
      (concurrent writer on a shared tree).

**Timing**: 1.25 hours

**Depends on**: 2, 3, 4, 5, 6

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: One new file, four sections plus the ratification, and no edit to any
previously written artifact except what earlier phases already changed. Confirm by diffing: if
writing the spec reveals that the work does not decompose as the task description's items 1–3, say
so in Section 1 and recommend a `/revise` of the follow-up task's scope rather than silently
re-scoping anything here.

**Files to modify**:
- `specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md` - new file, the hand-off specification

**Verification**:
- The file exists and every one of its four sections plus the ratification is present and non-empty.
- Every claim about a probe outcome is traceable to a named theorem in a file that compiles under
  `bash scripts/check-evidence-probes.sh`.
- No sentence in the file states a width, tail-period, or complexity bound as a commitment.
- `git status --short` confirms `specs/state.json` and `specs/TODO.md` are untouched by this task's
  own hunks.

## Testing & Validation

- [ ] `bash scripts/check-evidence-probes.sh` reports `PASS` with five new entries (one promoted
      keystone, four new probes) plus two `WIRED_REPO` deferred-move entries.
- [ ] Each of the five probe files compiles under `lake env lean <file>` with no errors, no
      warnings, and no `sorry`, and carries its own `#print axioms` record matching what it claims.
- [ ] `grep -rn "sorry" specs/evidence/seam-gluing-ray-product/` finds no structural `sorry` (prose
      occurrences in docstrings, if any, are reviewed by hand).
- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0 with no `BROKEN` line for the
      edited README.
- [ ] `bash scripts/check-module-invariants.sh --no-build` reports `PASS INV`.
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools` still passes
      (no `FormalSystem/` source is added, so this is a regression check only).
- [ ] `lake build` succeeds — no `FormalSystem/` source is edited by this plan, so this is a
      regression check against sibling activity on the shared tree, not a deliverable of any phase.
- [ ] `bash .claude/scripts/check-task-references.sh` reports no new task-number citation outside
      `specs/**`.
- [ ] Every surviving candidate route has at least one compiled probe attached: R1 three, R2 one.
- [ ] No phase closed on a prose verdict where a theorem was owed.

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean` (promoted keystone)
- `specs/evidence/seam-gluing-ray-product/stab-depth-stratification.lean`
- `specs/evidence/seam-gluing-ray-product/finite-graph-stab-summary.lean`
- `specs/evidence/seam-gluing-ray-product/mosaic-germ-amalgamation.lean`
- `specs/evidence/seam-gluing-ray-product/path-quantifier-alternation.lean`
- `scripts/check-evidence-probes.sh` (five `WIRED` entries, two `WIRED_REPO` entries, with comment rows)
- `FormalSystem/Metalogic/Decidability/FMP/README.md` (one new subsection, re-stamped)
- `specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md`
- `specs/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md` (one-line promotion note)
- `specs/718_omega_sequence_decidability_full_lplus/summaries/02_*-summary.md` (written at implement postflight)

## Rollback/Contingency

Nothing in this plan changes proof, elaboration, or runtime behaviour of `FormalSystem/`: the five
probe files live outside the build graph, the one library edit is prose, and the one script edit is
array entries. Reverting is therefore per-file and cheap, and each phase commits its own green
sub-step, so any single phase can be reverted without disturbing the others.

- **A probe that will not close**: leave the phase `[BLOCKED]` with the failing goal recorded in the
  file's docstring and in the handoff. Do not weaken a statement, do not insert a `sorry`, and do
  not delete the file — the script's own header forbids weakening a probe to make the gate pass.
- **Phase 3 refutes R1**: no rollback. Record the refutation as the headline theorem, mark Phase 5
  out of scope with the reason, and have Phase 7 promote R2. This is a successful outcome of the
  round, not a failure of the plan.
- **A `WIRED` entry turns the gate red because of drift elsewhere**: repair the citation in the
  probe; never unwire it to go green.
- **Reverting an individual file**: `git revert` the phase's own commit, or restore the single path
  from `HEAD`. If a genuine working-tree rollback is ever needed, follow
  `context/contracts/recovery.md`'s rollback rung for the exact snapshot invocation shape,
  including its out-of-scope override flag — never a bare precautionary `git-snapshot.sh` in its
  reverting default mode, and never on a tree a sibling task is also writing to.
