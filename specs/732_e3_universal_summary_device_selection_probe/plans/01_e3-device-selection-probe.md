# Implementation Plan: Task #732

- **Task**: 732 - Run experiment E3: select the universal summary device for the seam-gluing stab fibre check
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Dependencies**: None (task 711 depends on this one; the discharge of 711's blocked reason is a separate `/revise 711`, not performed here)
- **Research Inputs**: specs/732_e3_universal_summary_device_selection_probe/reports/01_e3-device-selection-probe.md
- **Artifacts**: plans/01_e3-device-selection-probe.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research dispatch already did the experiment's mathematics and compiled it: a research
prototype at `specs/732_e3_universal_summary_device_selection_probe/probes/device-probe-proto.lean`
(184 lines, `lake env lean` exit 0, no warnings, standard axioms) proves that the specified
`⊡(Fp)`/`⊡(Pp)` shapes are **device-inert on finite fixtures** — the per-path acceptor for
"eventually `p`" is already a 2-state deterministic automaton (`detRun_accepts_iff`), and the
universal summary over any finite step graph reduces to ultimately periodic paths by pigeonhole
alone (`allPathsMeet_iff_lasso`, its `Pp` dual by graph reversal) — and that pigeonhole-tier lasso
summaries are **refuted** as a general device on an infinite acyclic fibre
(`not_lasso_sufficient_on_chain`). This plan turns that prototype into the deliverable the
acceptance criteria name: one probe file under `specs/evidence/seam-gluing-ray-product/`, bridged
to the real `⊡(Fp)` formula on the shared Bool fixture, carrying a header that records the
selection the evidence supports **and its exact scope**, wired into `scripts/check-evidence-probes.sh`.

The selection the header will record (verbatim from the report's Recommendation 1, to be
transcribed, not re-derived): the shapes select no candidate behaviourally; on infrastructure and
literature evidence the substrate should be built on the **time-axis Ramsey-coloured summary (d)**
via the in-tree `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs`, framed by the
**MSO-over-`⟨ℤ,<⟩` quasimodel route (c)** (HWZ 2000 Thm 15; GKWZ 2003 Lemma 11.23, Thm 13.6);
(a) Safra/Piterman and (b) Safraless are **not selected** (inert on the shapes, no formalization
anywhere, (b)'s FOCS 2005 source WANTED). No device code is written; `detRun` is labelled as a
counterexample to the need for determinization, never as a substrate component.

### Research Integration

- **Every established fact re-verified** (report "Re-verification" table): `plusStab_iff_rays`
  (`PlusRayFibre.lean:116`), `pathFibreEquiv` (`:169`), `seamOmegaEquiv` (`:271`),
  `plusStab_iff_omega` (`:290`), all under `[F.IsRegular]`; `Probe718PathQuantifier.exists_ne_stab`
  (`path-quantifier-alternation.lean:159`), `exists_ne_universal` (`:167`);
  `Probe718Stratification.plusTruthAt_iff_stratum_atomize` (`stab-depth-stratification.lean:106`).
  The header cites these by name; the implementer re-greps each name before the header is final
  (names drift; the report's line numbers are a locator, not a fact).
- **The comparison core is already proved** (report "Lemma-level mapping table", status
  `prototype`): `allPathsMeet_iff_lasso`, `allBwdPathsMeet_iff_lasso`, `detRun_accepts_iff`,
  `not_lasso_sufficient_on_chain`. Phase 1 transcribes them; no new mathematics is planned.
- **The bridge is one definitional step** (report "Codebase Patterns", Medium confidence,
  "not compiled as a bridge lemma"): the Bool fixture's `IsFwdPath w₀ g` is
  `g 0 = w₀ ∧ ∀ n, Rf 0 (g n) (g (n+1))` (`path-quantifier-alternation.lean:63`) and the prototype's
  `IsPath (Rf 0) w₀ g` unfolds to the same proposition, so the fixture's `AllPathsMeet w₀` and the
  abstract `AllPathsMeet (Rf 0) (· = true) w₀` should be `Iff.rfl`. Phase 2 compiles exactly this
  and composes it with `will_iff_allPathsMeet` (`:68`), which is the one place the real formula
  `.stab (someFuture (.atom pa))` enters. Promoting that Medium claim to compiled is Phase 2's
  whole job.
- **Infrastructure facts the header relies on** (report "External Resources", High): Mathlib at
  pin `v4.33.0-rc1` has no ω-automata, no MSO, no infinite Ramsey for pairs (grep +
  `lean_leansearch`, two sources); `infinite_ramsey_pairs` is proved in-tree on
  `[propext, Classical.choice, Quot.sound]` (`lean_verify`). The implementer re-runs
  `lean_verify FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` once before the
  header cites it.
- **Tactic notes carried from the report's Tactic Survey**: `push_neg` is deprecated at this pin
  (use `simp only [not_exists, not_and]`); `omit [Finite S] in` must precede the docstring, not
  sit between docstring and `theorem`; `set r := …` failed to abstract the modulus — work with the
  raw `(n - i) % (j - i)`.
- **Scoping finding adopted** (report Contradiction Log, second entry): the acceptance criterion
  says "compare the devices on the shapes", and the compiled result is that the shapes do not
  discriminate. Both hold. The probe runs the shapes (recording inertness as the result, with the
  mechanized reason) **and** includes the infinite-fibre falsifier, because a probe that only ran
  the four devices on the Bool fixture would record four identical tables and select nothing.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's context and `roadmap_flag` is not set; no roadmap
phases are included. For orientation only (read, not modified): `specs/ROADMAP.md:65` names the
critical path 732 → 711 → 735, and `:67–71` is the E3 item this task closes.

## Goals & Non-Goals

**Goals**:

- Produce `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` that compiles under
  `lake env lean` from the repository root, sorry-free, with `#print axioms` at the foot showing
  only `[propext, Classical.choice, Quot.sound]` (or a subset) for every exported theorem.
- Make the probe **discriminating**: the three positive lemmas showing why all four devices
  coincide on the specified shapes over finite fixtures, plus the falsifier showing where
  pigeonhole-tier summaries stop working, plus the bridge from the abstract step-graph statement
  to the real `⊡(Fp)` formula on the shared Bool fixture.
- Write a header that states, in this order: which device the comparison selected, on what
  evidence, and what it does NOT establish — including that a behavioural superiority of (d) over
  (c) is not shown, that adequacy of (d) beyond the probed shapes is not shown, and that no
  complexity bound is claimed.
- Wire the probe into `scripts/check-evidence-probes.sh`'s `WIRED` array with a table row in the
  existing style, and run the **whole** collection once (the collection is the gate).

**Non-Goals**:

- Writing any device code or beginning a determinization substrate (dispatch HARD CONSTRAINTS; the
  archived ray-layer prohibition extends here). `detRun` is a 2-state counterexample, not a
  component.
- Asserting any complexity bound, or treating the CTL* 2EXPTIME lower bound (argued, not
  formalized) as anything but a sanity ceiling.
- Proving a frame-level `⊡(Pp)` bridge on the Bool fixture. No `pastStab_iff_…` lemma exists for
  that fixture (the only backward bridge, `Probe719Backward.pastStab_iff_allBwdPathsMeet`, is on
  the time-asymmetric fixture and is ~100 lines with `Classical.choice`); re-proving one is
  substrate-adjacent work out of proportion to a selection probe. The `Pp` side is carried at the
  step-graph level by graph reversal (`allBwdPathsMeet_iff_lasso`), and the header says so
  explicitly as a stated limit, citing the sibling probe that fixes the backward shape.
- Acquiring the WANTED/paywalled sources (Kupferman–Vardi FOCS 2005; Safra 1988). The research
  found them unobtainable this round; the header cites the in-corpus Kupferman–Vardi 2001 rank
  construction as the mathematical core (b) rests on, and marks 2005 as WANTED.
- Editing `.claude/context/**` to record the "device-inert shapes" insight or the in-tree Ramsey
  pointer (report "Context Extension Recommendations"). Those are deploy-artifact paths governed
  by `source-store-deploy-boundary.md` and are outside this task's `file_scope`; they are
  recommended as a follow-up filing, not done here.
- Any edit to `specs/state.json` task 711 (its blocked reason is dischargeable by a separate
  `/revise 711`, per the acceptance text).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `IsFwdPath`/`IsPath (Rf 0)` is not definitionally equal after all (the report rates this Medium, uncompiled) | M | L | Phase 2 proves the bridge as an explicit `Iff` with `Iff.rfl`; if that fails, fall back to `constructor <;> intro h <;> exact h` after `unfold`, or a two-line `fun h => ⟨h.1, h.2⟩` each way. Either closes the gap without new mathematics. |
| Concurrent edit to `scripts/check-evidence-probes.sh` by a sibling task (720, 733, 734 share it in `file_scope`) | H | M | Dispatch SCHEDULING says run in a separate cycle. Phase 3 begins with `git status --short -- scripts/check-evidence-probes.sh`; if dirty from another writer, STOP that phase and report `blocked` on that target rather than editing. Append the `WIRED` entry at the end of the `seam-gluing-ray-product/` block so a later merge is a pure insertion. |
| Header overclaims — reads as "device (d) is correct" rather than a scoped, evidence-based selection | H | M | Phase 3 transcribes the report's Recommendation 1 five-part statement verbatim, with the "does NOT establish" clause mandatory. Reviewer check: the header must contain the words "not selected", "does not establish", and "no complexity bound". |
| `#print axioms` shows an unexpected axiom (e.g. `sorryAx`, or a nonstandard axiom pulled in via `import FormalSystem`) | H | L | Every phase ends with a compile and an axiom read; the prototype's measured axioms are the baseline (`allPathsMeet_iff_lasso`: `[propext, Classical.choice, Quot.sound]`; `detRun_accepts_iff`, `not_lasso_sufficient_on_chain`: `[propext, Quot.sound]`). The bridge theorem will inherit `will_iff_allPathsMeet`'s axioms, which the sibling probe's foot prints — compare against it. |
| A dispatch-cited declaration name has drifted since 2026-10-05 | M | L | Phase 3's first task re-greps every name the header cites against the tree before writing it. A name that no longer resolves is cited by its replacement or dropped, never by the stale string. |
| `lean_local_search` index `warming`/`unavailable` during the dispatch | L | M | Not used for any absence claim in this plan; all lookups are grep/`sed` against known files plus `lake env lean`. Announce the evidence tier if degraded. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. This plan is fully sequential: the bridge
needs the abstract lemmas in place, and the header needs the bridge's measured result.

### Phase 1: Transcribe the compiled comparison core into the deliverable probe [COMPLETED]

**Goal**: Create `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` containing
the four compiled results of the research prototype under the probe collection's conventions, so
that the file compiles sorry-free on standard axioms before any fixture or header work begins.
This phase moves proved text; it proves nothing new.

**Tasks**:

- [x] Re-compile the prototype first, as the baseline this phase must not regress:
      `lake env lean specs/732_e3_universal_summary_device_selection_probe/probes/device-probe-proto.lean`
      (expected: exit 0, no warnings, three `#print axioms` lines matching the report).
- [x] Create the deliverable file with a **provisional** header (two lines: "Probe 732 (E3):
      device-selection comparison — header finalized in Phase 3" and the compile line
      `lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`), then
      `import FormalSystem` and the `open` lines used by `path-quantifier-alternation.lean:37–38`.
      Try **without** `import Mathlib.Data.Fintype.Pigeonhole` first (sibling convention: a probe
      imports `FormalSystem` only; `Finite.exists_ne_map_eq_of_infinite` is very likely already
      transitively available). Add the Mathlib import back only if the compile reports the name
      unknown, and note that in the header.
- [x] Transcribe into `namespace Probe732Device` (rename from `Probe732Proto`; keep every
      declaration name otherwise unchanged so the report's mapping table stays valid): `IsPath`,
      `IsLasso`, `AllPathsMeet`, `lassoIdx`, `lassoIdx_pos`, `lassoIdx_lt`, `exists_lasso_of_repeat`,
      `allPathsMeet_iff_lasso`, `allBwdPathsMeet_iff_lasso`, `detRun`, `detRun_true_iff`,
      `detRun_accepts_iff`, `chainR`, `chain_path_strictAnti`, `chain_no_lasso`,
      `not_lasso_sufficient_on_chain`. Keep the `omit [Finite S] in` placements exactly (before
      the docstring). Keep the prototype's section docstrings, which already carry the per-lemma
      interpretation ("no nondeterminism is involved, so no determinization device acts on this
      shape"; "pigeonhole-tier lasso sufficiency is therefore NOT a device for infinite fibres").
- [x] Add the `#print axioms` foot for `Probe732Device.allPathsMeet_iff_lasso`,
      `Probe732Device.allBwdPathsMeet_iff_lasso`, `Probe732Device.detRun_accepts_iff`,
      `Probe732Device.not_lasso_sufficient_on_chain`.
- [x] Compile: `lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`.
      Expected exit 0, no warnings, no `sorryAx`, axioms matching the prototype baseline. If a
      lemma that compiled in the prototype fails here, the cause is the import change — restore
      the Mathlib import before touching any proof.
- [ ] Commit the green file (`task 732 phase 1: transcribe comparison core`), staging only the new
      probe file.

**Timing**: 1.0 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The transcription is hypothesized to be ~190 lines (the prototype's 184
plus the provisional header and foot) with **zero** proof edits required. Confirm by compiling;
if any proof needs editing beyond the namespace rename and the import line, record it with
`issue-record.sh` (`--class "tooling bug or gap"` or the concrete class) because it means the
prototype's compile environment differed from the probe collection's.

**Files to modify**:

- `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` - new; the comparison
  core (abstract step-graph lemmas, deterministic acceptor, infinite-chain falsifier), provisional
  header

**Verification**:

- `lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` exits 0 with
  no warnings.
- The four `#print axioms` lines show no axiom outside `[propext, Classical.choice, Quot.sound]`
  and no `sorryAx`.
- `grep -c sorry specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` is 0.

---

### Phase 2: Bridge the abstract statement to the real `⊡(Fp)` formula on the Bool fixture [NOT STARTED]

**Goal**: Show the device-inertness result on the actual formula `.stab (someFuture (.atom pa))`
over the shared two-state Bool fixture — the fixture every sibling probe in the collection uses —
so the header can say "on the specified shape, over the fixture the necessity probe used, the
universal summary equals its lasso restriction, hence all four devices coincide with the
reachability summary already proved". This phase promotes the report's one Medium-confidence,
uncompiled claim (the `IsFwdPath`/`IsPath` identification) to a compiled theorem.

**Tasks**:

- [ ] Restate the Bool fixture **verbatim** from `path-quantifier-alternation.lean:44–66` into a
      `/-! ## The fixture, restated verbatim … -/` section of `Probe732Device`: `Rf`, `Rf_fwd`,
      `Rf_bwd`, `Ff`, `instance : Ff.IsRegular`, `pa`, `Mf`, `IsFwdPath`, and the fixture-level
      `AllPathsMeet` **renamed** `AllFwdPathsMeet` to avoid clashing with the abstract
      `AllPathsMeet (R) (P) (w₀)` already in the namespace. Probes do not import each other (collection
      convention, `check-evidence-probes.sh` header); say so in the section docstring as the
      siblings do.
- [ ] Restate `will_iff_allPathsMeet` (`path-quantifier-alternation.lean:68–127`) verbatim, with
      its conclusion's `AllPathsMeet` replaced by `AllFwdPathsMeet`. Compile before proceeding.
      If this transcription does not compile unchanged, the cause is the rename — check that every
      occurrence inside the proof was renamed; do not alter proof steps.
- [ ] Prove the bridge:
      `theorem allFwdPathsMeet_iff_abstract (w₀ : Bool) : AllFwdPathsMeet w₀ ↔ AllPathsMeet (Rf 0) (fun b => b = true) w₀ := Iff.rfl`.
      If `Iff.rfl` is rejected, use `⟨fun h g hg => h g hg, fun h g hg => h g hg⟩` (the two
      `IsPath`/`IsFwdPath` hypotheses are the same conjunction) — still no new mathematics.
- [ ] Prove the headline inertness statement on the real formula:
      `theorem stab_will_iff_lasso (τ : WorldHistory Ff.toTaskFrame) (t : ℤ) : PlusTruthAt Mf τ t (.stab (someFuture (.atom pa))) ↔ ∀ g, IsFwdPath (τ.state t).2 g → IsLasso g → ∃ n, 0 < n ∧ g n = true`
      by `rw [will_iff_allPathsMeet, allFwdPathsMeet_iff_abstract, allPathsMeet_iff_lasso]` and
      closing the residual `IsPath (Rf 0) … ↔ IsFwdPath …` by `Iff.rfl` if any remains.
- [ ] Add a short `/-! ## What the shape exercises of each device -/` docstring block (prose, not
      new declarations) that says in one line each: (a)/(b) — `detRun_accepts_iff` shows the
      acceptor is deterministic, nothing to determinize; (c) — on a finite fixture the MSO
      sentence is decided by the same reachability, nothing to absorb; (d) — only the pigeonhole
      tier is invoked, `infinite_ramsey_pairs` is never needed here. Cite
      `Probe718FiniteGraph.will_iff_allPathsMeet` / `decide_will` (⊡(Fp) is False at every seam
      state) and `Probe719Backward.pastStab_iff_allBwdPathsMeet` (the backward shape) as the
      sibling results all four devices coincide with.
- [ ] Extend the `#print axioms` foot with `Probe732Device.will_iff_allPathsMeet`,
      `Probe732Device.allFwdPathsMeet_iff_abstract`, `Probe732Device.stab_will_iff_lasso`.
- [ ] Compile; compare the axioms of `will_iff_allPathsMeet` against the sibling's printed foot
      (`path-quantifier-alternation.lean:174`) — they must match, since the proof is verbatim.
- [ ] Commit the green file (`task 732 phase 2: bridge to the Bool fixture`), staging only the
      probe file.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The fixture restatement plus `will_iff_allPathsMeet` is hypothesized at
~85 lines transcribed verbatim and the bridge at ≤ 10 new lines, two of which are proofs
(`Iff.rfl`, one `rw` chain). Confirm by line count after compile. If the bridge needs more than
~10 lines, stop and record why with `issue-record.sh` before continuing: it would mean the
definitional identification the report asserted does not hold and the header must be worded
accordingly.

**Files to modify**:

- `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` - add the Bool fixture
  restatement, the verbatim `will_iff_allPathsMeet`, the bridge, the headline
  `stab_will_iff_lasso`, the per-device docstring block, and the extended axioms foot

**Verification**:

- `lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` exits 0 with
  no warnings; `grep -c sorry` is 0.
- `stab_will_iff_lasso` is stated on `PlusTruthAt Mf τ t (.stab (someFuture (.atom pa)))` — the
  real formula — not on an abbreviation.
- Printed axioms for `stab_will_iff_lasso` are a subset of `[propext, Classical.choice, Quot.sound]`.

---

### Phase 3: Write the scoped selection header, wire the gate, run the collection [NOT STARTED]

**Goal**: Replace the provisional header with the final one that states the selection, its
evidence, and its limits; add the probe to `scripts/check-evidence-probes.sh`; run the whole
collection. After this phase the acceptance criteria are met in full and task 711's blocked
reason is dischargeable by `/revise 711` (not done here).

**Tasks**:

- [ ] **Collision check first**: `git status --short -- scripts/check-evidence-probes.sh`. If the
      script is modified by another writer, do not edit it; finish the header tasks below, commit
      them, and return `blocked` on target `scripts/check-evidence-probes.sh` with the verbatim
      goal "wire `seam-gluing-ray-product/device-selection-probe` into `WIRED`" so the
      orchestrator reschedules the wiring in a clean cycle (dispatch SCHEDULING).
- [ ] Re-verify every declaration name the header will cite, by grep against the tree (not
      against the report): `plusStab_iff_rays`, `plusStab_iff_omega`, `seamOmegaEquiv`,
      `pathFibreEquiv` (`FormalSystem/PlusLanguage/PlusRayFibre.lean`);
      `Probe718PathQuantifier.exists_ne_stab`, `exists_ne_universal`;
      `Probe718Stratification.plusTruthAt_iff_stratum_atomize`;
      `Probe718FiniteGraph.will_iff_allPathsMeet`, `decide_will`;
      `Probe719Backward.pastStab_iff_allBwdPathsMeet`; `Probe710.not_finite_width_fmp`;
      `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` (also
      `lean_verify` it once; expected `[propext, Classical.choice, Quot.sound]`).
- [ ] Write the final header in the sibling style (`path-quantifier-alternation.lean:1–33` is the
      model), with these mandatory parts in this order:
      1. Title: "Probe 732 (E3): **device-selection comparison** for the universal summary over
         the stab fibre — which device, on what evidence, and what is NOT established."
      2. **Outcome on the specified shapes** (High, machine-checked): `⊡(Fp)`/`⊡(Pp)` are
         device-inert on finite fixtures — `allPathsMeet_iff_lasso`, `allBwdPathsMeet_iff_lasso`,
         `detRun_accepts_iff`, and on the real formula `stab_will_iff_lasso`. All four candidates
         coincide with the reachability summaries of `Probe718FiniteGraph` / `Probe719Backward`.
      3. **Falsifier**: `not_lasso_sufficient_on_chain` — pigeonhole-tier lasso summaries are
         refuted for infinite fibres, which `Probe710.not_finite_width_fmp` makes unavoidable for
         complete classes.
      4. **Selection, scoped exactly** (transcribe the report's Recommendation 1 (iii)–(iv)):
         on infrastructure and literature evidence the substrate should be built on the
         time-axis Ramsey-coloured summary (d) via `infinite_ramsey_pairs` (in-tree, standard
         axioms; absent from Mathlib at pin `v4.33.0-rc1`), framed by the MSO-over-`⟨ℤ,<⟩`
         quasimodel route (c) — HWZ 2000 Theorem 15 (§4, flows incl. `⟨ℤ,<⟩`); GKWZ 2003
         Theorem 1.28, Lemma 11.23, Theorem 13.6 (§13.2, S5 × linear time). (a) and (b) are
         **not selected**: inert on the shapes; no ω-automata/Büchi/parity/Rabin in Mathlib; no
         formalization of Safra/Piterman in any proof assistant; (b)'s FOCS 2005 source WANTED
         (its 2001 rank-construction core is in corpus).
      5. **What this does NOT establish**: any behavioural superiority of (d) over (c); adequacy
         of (d) beyond the probed shapes; a frame-level `⊡(Pp)` bridge on this fixture (the `Pp`
         side is carried at the step-graph level by reversal; the backward shape is fixed by
         `Probe719Backward` on the asymmetric fixture); any complexity bound (the argued CTL*
         2EXPTIME lower bound is a sanity ceiling only). The selection is by evidence of what
         exists and what fails, not a behavioural discrimination.
      6. **No substrate work**: `detRun` is a counterexample to the need for determinization, not a
         component; nothing here begins a determinization substrate. The first behavioural
         discrimination lives on a finitely presented infinite fibre with a per-time alphabet and
         belongs to the substrate task, not here.
      7. The compile line.
- [ ] Reviewer check on the header text: it must contain the literal phrases "not selected",
      "does NOT establish" (or "does not establish"), and "no complexity bound"; it must not
      contain "correct device", "the right device", or any big-O/EXPTIME upper-bound claim.
- [ ] Compile the file once more (header is a comment, but a stray `-/` or `/-` breaks it).
- [ ] Wire: in `scripts/check-evidence-probes.sh`, add a table row **after** the
      `seam-gluing-ray-product/backward-dual-asymmetric-fixture` block (ending `:177`) in the
      existing 62-column `# path | decision` style, summarizing: "DEVICE-SELECTION (E3):
      `⊡(Fp)`/`⊡(Pp)` are device-inert on finite fixtures (machine-checked); pigeonhole-tier
      lasso summaries refuted on infinite fibres; selection on infrastructure + literature
      evidence = time-axis Ramsey (d) via in-tree `infinite_ramsey_pairs`, framed by HWZ/GKWZ MSO
      route (c); (a)/(b) not selected. No complexity bound. Begins no substrate work." Then
      append `"seam-gluing-ray-product/device-selection-probe"` as the last entry of the
      `seam-gluing-ray-product/` run inside `WIRED` (currently `:185`).
- [ ] Run the gate: `bash scripts/check-evidence-probes.sh`. Expected: `PASS  all 13 wired
      probe(s) compile` (12 today + this one; confirm the count rather than assuming it).
- [ ] Run `lake build` once as a cheap no-regression confirmation (the probe is outside the build
      graph, so this should be a cache hit; it confirms no `FormalSystem/` file was touched).
- [ ] Commit (`task 732 phase 3: selection header and gate wiring`), staging exactly the probe
      file and `scripts/check-evidence-probes.sh`.
- [ ] Record one `issue-record.sh --kind win` entry if the whole collection passed first time
      (positive signal has a home in the log too), or the concrete issue if it did not.

**Timing**: 1.0 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: The `WIRED` array is hypothesized to hold 12 entries at implement time
(`check-evidence-probes.sh:180–185` today) and the new row to land after line 177. Both are
hypotheses — sibling tasks 720/733/734 may have inserted rows. Confirm by reading the array
before editing and by the script's own printed `all N wired probe(s)` count after.

**Files to modify**:

- `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` - replace the provisional
  header with the final selection header; no declaration changes
- `scripts/check-evidence-probes.sh` - one table row in the commented decision table; one
  `WIRED` entry

**Verification**:

- `bash scripts/check-evidence-probes.sh` exits 0 and lists `seam-gluing-ray-product/device-selection-probe … PASS`.
- `lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` exits 0 with
  no warnings; `grep -c sorry` is 0.
- The header contains "not selected", "does not establish"/"does NOT establish", and "no
  complexity bound"; grep confirms the absence of "right device"/"correct device"/"EXPTIME" as an
  upper-bound claim.
- `git diff --staged --stat` before the commit shows exactly the two files above.

## Literature Proof Structure (H3 Tier 1 mapping, carried from the report)

This task is Tier 1 (literature-backed); the 5-column table is required in the plan. Statuses
are the **intended end state after Phase 3**; `transcribed` for prototype lemmas means "proved in
the deliverable probe". Nothing marked `absent`/`pending` is to be transcribed by this task.

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|---|---|---|---|---|
| HWZ 2000 (APAL 106) | Theorem 14, §4 (chunk 0025) | — | satisfiable on flow ↔ quasimodel exists | pending (cited in header as (c)'s frame) |
| HWZ 2000 | Theorem 15, §4 (chunk 0024, flows 1–4 incl. `⟨ℤ,<⟩`) | — | monodic satisfiability over the listed flows decidable via MSO `σ_ϕ` | absent (route (c) target; cited, not transcribed) |
| GKWZ 2003 | Theorem 1.28 (chunk 0058) | — | MSO theory of `⟨ℤ,<⟩` decidable (Büchi/Rabin); non-elementary | absent (Büchi's theorem; no Lean formalization) |
| GKWZ 2003 | Lemma 11.23 (chunk 0490) | — | `𝔉 ⊨ qm_ϕ` iff a quasimodel for ϕ on 𝔉 exists | pending (cited) |
| GKWZ 2003 | Theorem 13.6, §13.2 (chunks 0589–0591) | — | S5 × linear-time logics decidable by MSO reduction, runs quantified universally | pending (cited as nearest analogue) |
| Kupferman–Vardi 2001 | abstract; chunks 18–23 (rank construction) | — | Büchi/co-Büchi alternating → weak alternating without determinization | absent (route (b) core; cited) |
| Kupferman–Vardi 2005 (FOCS) | `SOURCES.md` D8:1018 — PAYWALLED, WANTED | — | — | absent (marked WANTED in header) |
| Safra 1988 / Piterman 2007 | `SOURCES.md` D8:1008–1032 | — | — | absent (no formalization in any proof assistant; header says so) |
| Mathlib `v4.33.0-rc1` | `Mathlib/Data/Fintype/Pigeonhole.lean:74` | `Finite.exists_ne_map_eq_of_infinite` | `∀ {α β} [Infinite α] [Finite β] (f : α → β), ∃ x y, x ≠ y ∧ f x = f y` | transcribed (Mathlib; used by `allPathsMeet_iff_lasso`) |
| This tree | `RamseyFactorization.lean:146` | `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs` | `(c : ℕ → ℕ → C) : ∃ g, StrictMono g ∧ ∃ τ, ∀ i j, i < j → c (g i) (g j) = τ` | transcribed (in-tree; cited by header, `lean_verify`'d in Phase 3) |
| Prototype → Phase 1 | `device-probe-proto.lean` | `Probe732Device.allPathsMeet_iff_lasso` | `AllPathsMeet R P w₀ ↔ ∀ g, IsPath R w₀ g → IsLasso g → ∃ n, 0 < n ∧ P (g n)` | transcribed (Phase 1) |
| Prototype → Phase 1 | same | `Probe732Device.allBwdPathsMeet_iff_lasso` | the `Pp` dual on `fun a b => R b a` | transcribed (Phase 1) |
| Prototype → Phase 1 | same | `Probe732Device.detRun_accepts_iff` | `(∃ n, detRun P g n = true) ↔ ∃ m, 0 < m ∧ P (g m)` | transcribed (Phase 1) |
| Prototype → Phase 1 | same | `Probe732Device.not_lasso_sufficient_on_chain` | `¬ (universal summary on the `ℤ`-chain ↔ its lasso restriction)` | transcribed (Phase 1) |
| Sibling probe → Phase 2 | `path-quantifier-alternation.lean:68` | `Probe732Device.will_iff_allPathsMeet` | `PlusTruthAt Mf τ t (.stab (someFuture (.atom pa))) ↔ AllFwdPathsMeet (τ.state t).2` | transcribed (Phase 2, verbatim restatement) |
| New (Phase 2) | — | `Probe732Device.allFwdPathsMeet_iff_abstract` | `AllFwdPathsMeet w₀ ↔ AllPathsMeet (Rf 0) (· = true) w₀` | transcribed (Phase 2; expected `Iff.rfl`) |
| New (Phase 2) | — | `Probe732Device.stab_will_iff_lasso` | `PlusTruthAt Mf τ t (.stab (someFuture (.atom pa))) ↔ ∀ g, IsFwdPath (τ.state t).2 g → IsLasso g → ∃ n, 0 < n ∧ g n = true` | transcribed (Phase 2) |

**Transcription discipline**: the source wins. The prototype's proofs are copied, not re-proved;
`will_iff_allPathsMeet` is copied verbatim from the sibling. The only new terms are the two
Phase 2 bridge lemmas, both compositions of existing results. No divergence from any cited
source is planned; if one becomes necessary it is recorded in the header and in `issues.jsonl`.

## Testing & Validation

- [ ] `lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` exits 0,
      no warnings, after each phase.
- [ ] `grep -c sorry` on the probe is 0 at every commit; `#print axioms` shows only
      `[propext, Classical.choice, Quot.sound]` or subsets, and never `sorryAx`.
- [ ] `stab_will_iff_lasso` is stated on the real formula `PlusTruthAt Mf τ t (.stab (someFuture (.atom pa)))`.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 with the new probe listed `PASS` and the
      printed wired count equal to the array length.
- [ ] `lake build` succeeds (expected cache hit; confirms no `FormalSystem/` edit).
- [ ] Header content check: contains "not selected", "does not establish" (any case), "no
      complexity bound"; excludes "right device", "correct device", any upper-bound complexity claim.
- [ ] `git diff --stat` across the task's commits touches only
      `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` and
      `scripts/check-evidence-probes.sh` (plus task 732's own `specs/732_…/` records).

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` — the E3 probe: comparison
  core, Bool-fixture bridge to the real `⊡(Fp)` formula, infinite-fibre falsifier, scoped
  selection header, axioms foot.
- `scripts/check-evidence-probes.sh` — one decision-table row and one `WIRED` entry.
- `specs/732_e3_universal_summary_device_selection_probe/summaries/01_e3-device-selection-probe-summary.md`
  — implementation summary (written by the implement phase per summary-format.md).
- Not produced here, named for the next step: the `/revise 711` that discharges 711's blocked
  reason "device not yet selected; probe E3 pending", and a follow-up filing for the two context
  extension recommendations in the report.

## Rollback/Contingency

- Every phase commits only a green probe file; a failing later phase leaves the previous phase's
  commit intact. To back out an in-progress phase, `git stash` the working edits (not a
  destructive reset — see `rules/git-workflow.md`) or take `bash .claude/scripts/git-snapshot.sh 732 --no-revert`
  as a defensive checkpoint before the Phase 3 script edit.
- If Phase 2's bridge genuinely cannot be closed (the definitional identification fails and no
  ≤ 10-line repair exists), the probe still meets the acceptance criteria with the abstract
  step-graph statements alone: finalize the header with the bridge listed under "does NOT
  establish" (frame-level `⊡(Fp)` bridge on this fixture), record the failure in `issues.jsonl`,
  and proceed to Phase 3. Do not substitute a `sorry`.
- If the gate script is dirty from a sibling writer at Phase 3, commit the header, return
  `blocked` on the wiring target with the verbatim goal, and let the orchestrator schedule the
  one-line wiring in a clean cycle. Never edit a file another live writer has modified.
- A selection recorded as "no candidate is adequate on this evidence" remains a complete and
  valid outcome per the acceptance text; the header template above already carries the
  "not selected" and "does NOT establish" clauses that such an outcome would lean on, so no plan
  change is needed to record it.
