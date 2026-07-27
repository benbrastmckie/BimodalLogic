# Implementation Plan: Re-base Rabinovich Section 5 onto the faithful Dedekind carrier

- **Task**: 378 - Re-base Rabinovich's Section 5 onto the FAITHFUL Dedekind carrier
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours (9 phases; Phase 7 is the one phase expected to need a re-split)
- **Dependencies**: None (task 377 Phase 6 is CONFIRMED DONE and landed live)
- **Research Inputs**:
  - `specs/378_rebase_section5_onto_faithful_dedekind_carrier/reports/01_faithful-dedekind-rebase-gate.md`
  - `specs/378_rebase_section5_onto_faithful_dedekind_carrier/reports/01_lemma53-faithful-gate-probe.lean`
- **Artifacts**: plans/01_faithful-dedekind-section5-rebase.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md;
  `.claude/rules/lean4.md`; `.claude/rules/plan-compliance.md`;
  `.claude/rules/no-task-references-in-deliverables.md`
- **Type**: lean4
- **Lean Intent**: true

## Overview

Rabinovich's Section 5 is transcribed in `EANegationFix/` at the strictly-too-strong
`HasAttainedINF`/`HasAttainedSUP` carrier, which provably deletes the paper's disjunct (2)
(`hasDefinableINF_excludes_kplus`, `Lemma53.lean:290`). This plan re-bases it onto the faithful
`HasDedekindINF`/`HasDedekindSUP` carrier (`DedekindINF.lean:136`/`:153`), which is already landed,
live, sorry-free and axiom-clean. The GO/NO-GO gate for the hardest single step — the printed
three-disjunct `Oₙ₊₁` of PDF p.8 — has **already resolved GO** on machine-checked evidence: the
research probe `reports/01_lemma53-faithful-gate-probe.lean` compiles standalone at EXIT 0,
sorry-free, axiom-clean, with no hypothesis absent from p.8. Phase 1 therefore lands existing,
proved content into a live module; it is migration, not discovery.

The remainder is a `VBracketFormula → VVecEA2` **type migration** across the 2,750-line
`EANegationFix/` sub-stack (4 splice sites), not the "hypothesis weakening" the inherited plan
assumed. That is why it is decomposed here into seven separately-dispatchable units rather than
carried as one phase.

**Definition of done**: `prop42_contentful_of_dedekind` proved sorry-free and axiom-clean in a live
module, with the attained-carrier stack still green and `AggregateOffDiagK1.lean` still building —
or a bounded, evidence-backed stop at a named phase boundary with everything before it landed green.

### Research Integration

All measured facts below come from `reports/01_faithful-dedekind-rebase-gate.md` and are **not** to
be re-derived:

- **Measured baseline** (re-measure at dispatch, do not trust these as current): `lake build` EXIT 0,
  **1883 jobs**, **269 live modules** reachable from `FormalSystem.lean`, **0 live sorries** in
  `Kamp/` (4 dead, all under `Kamp/Boneyard/`). Each new live module adds exactly +1 to jobs and +1
  to live modules.
- **All inherited paths are stale**: the tree is `FormalSystem/…`, not `Theories/Bimodal/…`. Many
  inherited line numbers are stale. Use report section 0's correction table, never the inherited
  pointers.
- **The Lemma 5.3 gate resolves GO.** `negChainOnFaithful_iff` and `lemma53Faithful` are proved
  axiom-clean in the probe. Do not re-litigate the gate.
- **K+ needs no canonical-expansion machinery.** `kplus_formula_correct` (`Lemma53.lean:162`) makes
  `K⁺` outright TL-definable as `¬P ∧ ¬(⊤ U ¬P)`, carried in `VecEA2.endpointLeft`. This is the
  single most important fidelity finding of the gate.
- **The arity cap does not constrain this work** (report section 7). Every object here has at most
  two free variables and unary types. Do not cite it as a risk.
- **Phase 8 sizing obstruction** (report section 6): `negChainOn` returns `VBracketFormula`;
  `negChainOnFaithful` must return `VVecEA2`. Its `.disjuncts` are spliced into `VBracketFormula`
  literals at `BoundedFix.lean:449`, `:767`, `BoundedFixAnchored.lean:158`, `:385`. A `VVecEA2`'s
  disjuncts are `Σ n, VecEA2 n`; a `VBracketFormula`'s are `Σ n, BracketFormula n`. **The splice
  cannot typecheck**, so the whole sub-stack below the `VecEA2.negFix` lift point
  (`VecEANegFix.lean:67`) must migrate.
- **Roughly half the `VVecEA2` combinator layer already exists**: `disj`/`disj_holds`,
  `conjFull`/`conjFull_iff`, `trivialTrue`, `enrichEndpoints`, `disjList`, `singleton`, `conjStruct`.
  Absent: `prependAll` (endpoint-absorbing — supplied by the probe as `prependAllVec`),
  `conjEverywhere`, `concatPin`.

### Prior Plan Reference

The inherited plan `specs/377_transcribe_rabinovich_faithful_nf_encoding/plans/02_section5-exists-carrier-rebase.md`
supplied the GO/NO-GO gate wording, the sizing-canary discipline, and the sub-obligation ordering,
all of which are carried forward. Two things are **superseded**:

1. Its Phase 6 is CONFIRMED DONE — the carrier, the four shims, `TemporalPred.disj`, and
   `kplusFormula`/`kplus_formula_correct` are all landed live. It is not re-planned here.
2. Its Phase 8 estimate of "2-4 dispatches" is not supportable. The obstruction is structural (type
   migration), not optimism. Its eight sub-obligations are carried here as Phases 1 and 3-9.

Its stale paths and line numbers are **not** carried forward.

### Roadmap Alignment

No `specs/ROADMAP.md` consulted for this dispatch (`roadmap_flag` not set). This work is the
declared fidelity prerequisite feeding the Dedekind-complete frame-class completeness theorem; it is
upstream of, and blocks, that theorem.

## Goals & Non-Goals

**Goals**:

- Land the machine-checked faithful Lemma 5.3 (`negChainOnFaithful`, `negChainOnFaithful_iff`,
  `lemma53Faithful`) into a **live** module, reachable from `FormalSystem.lean`.
- Supply the `HasDedekindSUP`/Since mirror the probe does not cover, including the absent
  `kminusFormula` + `kminus_formula_correct`.
- Migrate the `EANegationFix/` Section 5 stack from `VBracketFormula` to `VVecEA2` at the faithful
  carrier, as a **parallel addition**, terminating in `prop42_contentful_of_dedekind`.
- Maintain full faithfulness with Rabinovich throughout: every new declaration carries a PDF-page
  source correspondence, and no step invents mathematics the paper does not print.
- Add ZERO live sorries.

**Non-Goals**:

- Deleting, weakening, or replacing any attained-carrier declaration. The faithful versions are
  **additions**; the attained ones follow from them via the landed shims.
- Deleting any file. Surgical declaration excision only, and none is required by this plan.
- Touching the model-independent Prop 4.2 backward direction at the `BracketFormula` level. That
  target is ruled UNFIXABLE under a standing three-strikes prohibition (see Binding Constraints).
- Constructing a formalized non-attained Dedekind-complete structure (e.g. `ℝ`). None exists in the
  tree; building one is downstream frame-class work, not this task.
- Producing an object-language canonical expansion. `kplus_formula_correct` makes it unnecessary.

## Binding Constraints

These bind every phase. A phase that violates one is not complete regardless of build status.

1. **Faithfulness is the primary constraint.** "It is ESSENTIAL to maintain full faithfulness with
   Rabinovich to avoid attempting to prove novel mathematics (which is very hard)." Follow the
   printed proof step-by-step. Do not use `simp`/`omega`/`aesop` to bypass a step the paper handles
   explicitly. Do not abandon the paper's approach after a single tactic failure.
2. **Cite Rabinovich by PDF page only**:
   `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
   The companion `.md` is **CORRUPT** (it inverts `k ≠ m` at `md:199`) and is NEVER ground truth.
   No chunk-style citations.
3. **THREE-STRIKES PROHIBITION (standing).** The model-**independent** Prop 4.2 backward direction
   at the `BracketFormula` level is ruled UNFIXABLE. The content now lives at
   `Kamp/Boneyard/EANegationVBracketBackward.lean:452`/`:611` (dead; the historically-named
   `EANegation.lean:1090`/`:1249` no longer exist — that file is 694 lines). **No phase may target
   it.** `BracketFormula.negFix_iff` (`NegFix.lean:694`) is INF-anchored and CONFIRMS the ruling;
   it must never be cited as license for a fourth attempt. Every faithful analogue in this plan is
   carrier-anchored (`HasDedekindINF`/`HasDedekindSUP`) throughout, exactly as the attained versions
   are `HasAttainedINF`-anchored. The anchors are what make the direction go through.
4. **SORRY GATE: add ZERO live sorries.** Strategic sorries are NOT an acceptable stopping outcome
   in this plan. The correct outcome for a phase that cannot close is `[BLOCKED]` with nothing landed
   for that unit and a documented handoff — not a sorry-bodied placeholder. Census must be
   tactic-position via `.claude/scripts/lean-sorry-census.sh`, **never** `grep -c`.
5. **EXTENDED NON-VACUITY RULE.** Every phase that lands or weakens a carrier MUST produce a
   **statement of what it excludes**. An over-strong hypothesis passes sorry-free, axiom-clean and
   EXIT 0 exactly as a vacuous conclusion does; that pattern recurred THREE times undetected on the
   parent task. The probe supplies the required pattern —
   `lemma53Faithful_perPoint_is_VACUOUS` (failed-vacuity control) and
   `prior_makes_disjunct2_unreachable` (exclusion stated as a theorem, not prose). Extend this
   pattern; never drop it. The strengthening chain is:
   `Rabinovich's Dedekind completeness < HasDedekindINF < HasDefinableINF < HasAttainedINF`.
6. **AXIOM GATE.** Every new declaration must print exactly
   `[propext, Classical.choice, Quot.sound]` — no `sorryAx`.
7. **PRESERVE — DO NOT DELETE FILES.** ~29% of `NfMultiAnchorBridge` is load-bearing via
   `kampArm_*_k0`/`_k1`; frozen byte-identity surfaces sit INSIDE live files. Do NOT delete
   `hasDefinableINF_excludes_kplus`, `lemma53`'s basis, or anything in `EANegationFix/`.
8. **LIVENESS.** `lake build BoneyardArchive` passes **VACUOUSLY** (`#exit` at line 5 precedes the
   imports at line 7) and is NEVER a verification gate. Only reachability from `FormalSystem.lean`
   by transitive `import` walk decides liveness. Everything landed must be landed LIVE.
   The CI-protection hook is `Kamp/NfMultiAnchorBridge.lean` (it already carries the import edges for
   `DedekindINF` and `Section5Correspondence`); each new module gets its import edge added there.
9. **No task-number references** in any file written outside `specs/**`. Cite durable anchors
   (filenames, declaration names, PDF pages) instead.
10. **Plan compliance** (`.claude/rules/plan-compliance.md`): the plan is the contract. Do not
    re-derive a different decomposition mid-implementation. If a phase cannot be executed as
    written, mark it `[BLOCKED]` and escalate — do not silently substitute.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The `VVecEA2` splice at `BoundedFix`/`BoundedFixAnchored` cannot be constructed | H | M | Phase 4 is the migration canary and carries the whole-migration GO/NO-GO. A NO-GO there stops the migration with Phases 1-3 landed green. |
| `negFixListFaithful` (681-line recursion, third gate per case) overruns one agent run | H | **H** | Phase 7 declares this up front, names its three internal re-split boundaries (7a/7b/7c), and mandates re-splitting rather than a second dispatch on the same target. |
| Unnoticed strengthening: a faithful arm silently re-introduces attainment | H | M | Per-phase non-vacuity gate requiring an explicit exclusion statement; Phase 9 re-runs the check against the final statement. |
| Regression in the live attained stack (`AggregateOffDiagK1.lean` `k = 1` arm) | H | L | Every phase from 4 on verifies `AggregateOffDiagK1.lean` still builds; nothing is edited in place — faithful versions are additions. |
| Landing into a dead module (Boneyard-style vacuous pass) | H | L | Every phase's gate requires the import-graph walk from `FormalSystem.lean` plus a +1 job / +1 live-module delta. |
| `kminusFormula` turns out not to be TL-definable dually | M | L | Phase 2 states this as its own kill criterion; a NO-GO there scopes the task to the INF/Until direction only and Phases 4-9's left mirrors are re-scoped, not abandoned. |
| Stale line numbers misdirect a dispatch | M | H | Report section 0's correction table is authoritative; every phase instructs re-confirmation by `lean_local_search`/`grep` before editing. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |

Phases within the same wave can execute in parallel. This plan is fully sequential by design: the
directive requires all Phase-7-scope work (Phases 1-2) to land before any migration unit dispatches,
and each migration unit consumes the declarations the previous one lands. Do not parallelize.

**Standard verification gate.** Every phase runs all of the following; per-phase sections list only
what is *additional* or *specific*.

```bash
lake build                                                            # EXIT 0
bash .claude/scripts/lean-sorry-census.sh FormalSystem/Metalogic/WeakCanonical/Kamp
                                                                      # sorry_count: 0 live
```

Plus, in every phase:

- `#print axioms <each new declaration>` → exactly `[propext, Classical.choice, Quot.sound]`.
- Job-count and live-module delta recorded against the re-measured dispatch-time baseline
  (documented baseline: 1883 jobs / 269 live modules; **re-measure, do not trust**). Each new live
  module is exactly +1 to each.
- Liveness confirmed by transitive `import` walk from `FormalSystem.lean` — **not** by
  `lake build <target>`.
- Every new declaration carries a page-cited source correspondence docstring (PDF p.N).
- The phase's non-vacuity statement (what the hypothesis excludes), as specified per phase.

---

### Phase 1: Land the faithful three-disjunct Lemma 5.3 into a live module [COMPLETED]

**Outcome (measured, dispatch `sess_1785150996_3c6f1f_378`):** `lake build` EXIT 0 at **1884
jobs** (baseline re-measured this dispatch: 1883 — delta **+1**, as specified). Live modules
**269 → 270** (delta **+1**) by transitive `import` walk from `FormalSystem.lean`;
`Kamp.Lemma53Faithful` confirmed LIVE, `NfMultiAnchorBridge.AggregateOffDiagK1` still LIVE and
still building. Tactic-position sorry census on `Kamp/` unchanged at **4 dead / 0 live** (all
four under `Kamp/Boneyard/`). All 13 new declarations axiom-clean — no `sorryAx`, no new `axiom`
declarations anywhere in the tree. All 11 lifted declarations plus the two mandatory non-vacuity
declarations landed; no proof required adaptation, so the lift is verbatim from the probe.

- **Goal:** Migrate the GO-gate probe's content, near-verbatim, into a live module. The probe is
  sorry-free and axiom-clean **today**; this is transcription and wiring, not discovery. Do not
  re-derive any proof in it.
- **Source correspondence:** PDF p.8 (Notation 5.2, Lemma 5.3, eq (5.2), the `Subcase r₀ = z₀`
  remark, and the `∨∃⃗∀` closure remark).
- **Tasks:**
  - [x] Create `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53Faithful.lean` with the probe's
        header, imports (`Kamp.DedekindINF`, `Kamp.VecEAConjFull`, `Kamp.VecEAClosure`) and
        namespace. *(completed)*
  - [x] Lift, in probe order: `kplusPred`, `kplusPred_eval`, `VVecEA2.prependAllVec`,
        `VVecEA2.prependAllVec_holds`, `orderedPointsExist_combine_kplus`,
        `orderedPointsExist_widen_left`, `kplusLeftBlock`, `kplusLeftBlock_holds`,
        `negChainOnFaithful`, `negChainOnFaithful_iff`, `lemma53Faithful`. *(completed — all
        eleven lifted verbatim; no proof body required adaptation)*
  - [x] Lift the two non-vacuity declarations **verbatim and unconditionally**:
        `lemma53Faithful_perPoint_is_VACUOUS` (the failed-vacuity control) and
        `prior_makes_disjunct2_unreachable` (the exclusion theorem). These are not optional
        commentary; they are the extended-non-vacuity gate expressed as code. *(completed — both
        landed verbatim and unconditionally)*
  - [x] Preserve the probe's docstrings including their PDF p.8 citations. Refresh any in-docstring
        line references against the current tree before committing (report section 0 lists the
        drifted ones). *(completed — all twelve cited line numbers re-verified by `grep` against the
        current tree; every one was already current, so no in-docstring refresh was needed)*
  - [x] Add `import FormalSystem.Metalogic.WeakCanonical.Kamp.Lemma53Faithful` to
        `Kamp/NfMultiAnchorBridge.lean`, alongside the existing `DedekindINF` edge, with a NOTE
        comment in the same style explaining that the edge exists to keep the module live/CI-protected.
        *(completed)*
  - [x] Correct the two stale in-tree docstrings the research identified, since this phase touches
        their subject matter: `Lemma53.lean:426-428` (claims `BracketFormula.cons` and a
        `TemporalPred` disjunction are missing — both exist: `BracketFormula.prepend` at
        `EANegation.lean:93`, `TemporalPred.disj` at `ExistsForallNF.lean:87` with `eval_at_disj` at
        `VecEAClosure.lean:49`) and `Section5Correspondence.lean:33,35,41` (cites drifted line
        numbers `OnBuilder.lean:159`, `NegFix.lean:669`, `VecEANegFix.lean:164`; current values are
        `:189`, `:694`, `:183`). *(deviation: altered — scope widened, see Phase 1 deviations below)*

**Phase 1 deviations** (both are strict supersets of a listed task, made because leaving the
adjacent text stale would have been actively misleading in files this phase already modifies; no
listed task was skipped, narrowed, or substituted):

1. *Altered — `Section5Correspondence.lean` correspondence-table fix widened from 3 rows to all 6.*
   The plan named lines 33/35/41. Report section 0's correction table lists three further drifted
   citations in the same six-row table: `BoundedFix.lean:449 → :455`, `BoundedFix.lean:768 → :774`,
   `NegFix.lean:424 → :449`. All six were re-verified by `grep` and corrected together. Fixing three
   rows of a six-row table while leaving the other three stale would have made the table *less*
   trustworthy, not more.
2. *Altered — one additional in-tree comment corrected: the `DedekindINF` NOTE in
   `NfMultiAnchorBridge.lean`.* It read "The re-base of Lemma 5.3 / Lemma 5.1 / Prop 4.2 onto that
   carrier is **DEFERRED, not done**". Phase 1 makes the Lemma 5.3 clause false, and the note sits
   directly below the new `Lemma53Faithful` import edge. Amended minimally to "**Lemma 5.3 is
   DONE** … **Lemma 5.1 / Prop 4.2 remain DEFERRED, not done**", preserving the rest of the note
   including its liveness rationale. Nothing was deleted.
- **Files to create/modify:**
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53Faithful.lean` — new, live
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — one import + NOTE
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53.lean` — docstring correction only
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/Section5Correspondence.lean` — docstring correction only
- **Verification (additional to the standard gate):**
  - `#print axioms` clean on: `negChainOnFaithful_iff`, `lemma53Faithful`,
    `VVecEA2.prependAllVec_holds`, `orderedPointsExist_combine_kplus`,
    `orderedPointsExist_widen_left`, `kplusLeftBlock_holds`, `kplusPred_eval`,
    `prior_makes_disjunct2_unreachable`.
  - Job count **1883 → 1884**; live modules **269 → 270** (against re-measured baseline).
  - **Non-vacuity statement (required):** `lemma53Faithful` is the **hoisted** shape
    (`∃ O, ∀ M atomMap z₀ z₁`); `lemma53Faithful_perPoint_is_VACUOUS` compiles with **no carrier
    hypothesis at all** and must be recorded as the control demonstrating the two are different
    statements. Additionally record, from `prior_makes_disjunct2_unreachable`: `HasDedekindINF`
    excludes chains whose first-occurrence infimum exists but is none of the paper's three shapes,
    and disjunct (2) is **provably dead on every Prior structure** — so the re-base is contentful
    mathematics whose content is not yet reachable from any live consumer. State this honestly; do
    NOT cite `hasDedekindINF_admits_kplus_shape` (`DedekindINF.lean:264`) as evidence to the
    contrary — its proof is `Or.inl h_kplus` and its own docstring admits it exhibits no structure.
- **Green commit:** `task 378 phase 1: land the faithful three-disjunct Lemma 5.3 live (p.8)`
- **Done when:** all listed declarations are live, sorry-free, axiom-clean, reachable from
  `FormalSystem.lean`, with the +1/+1 delta recorded and the non-vacuity statement written into the
  module docstring.
- **Timing:** 1.5 hours (one agent run)
- **Depends on:** none

---

### Phase 2: The `HasDedekindSUP` / Since mirror [COMPLETED]

- **Goal:** Supply the past-direction mirror the probe does **not** cover. This is genuinely absent
  work, not a transcription: `kminus` exists (`PriorINF.lean:98`) but there is **no `kminusFormula`
  and no `kminus_formula_correct`** anywhere in the live tree. Do not treat Phase 7-scope as
  complete after Phase 1.
- **Source correspondence:** PDF p.8, mirrored. `HasDedekindSUP` (`DedekindINF.lean:153`) already
  states the mirrored disjunction faithfully; its `last_occ` field is the dual of
  `HasDedekindINF.first_occ`.
- **Tasks:**
  - [x] Confirm by search that `kminusFormula` / `kminus_formula_correct` are absent before writing
        them (`lean_local_search`, then `grep`). If either exists, reuse it. *(completed — `grep`
        over the whole tree returned ZERO hits for `kminusFormula`, `kminus_formula_correct` and
        `kminusPred`; `kminus` itself appears only at `PriorINF.lean:98`/`:102` and in three
        `DedekindINF.lean` references. Nothing to reuse.)*
  - [x] Define `kminusFormula : Formula → Formula` as the exact dual of `kplusFormula`
        (`PriorINF.lean:93`), and prove `kminus_formula_correct` as the dual of
        `kplus_formula_correct` (`Lemma53.lean:162`). Follow the existing proof structurally.
        *(completed — `Formula.untl` swapped for `Formula.snce`, which `Table.lean:198` interprets
        natively; the proof of `kplus_formula_correct` transferred with no step adapted beyond
        reversing the order comparisons. **KILL CRITERION DID NOT FIRE**: no hypothesis absent from
        PDF p.8 was needed.)*
  - [x] Define `kminusPred` and prove `kminusPred_eval`, dual to `kplusPred`/`kplusPred_eval`.
        *(completed)*
  - [x] Prove `HasDedekindSUP.last_occ_tp` — the `TemporalPred`-level wrapper, dual to the pattern
        of `HasAttainedSUP.last_occ_tp` (`BoundedFix.lean:72`) and
        `HasAttainedINF.first_occ_tp` (`EANegationClosure.lean:66`). *(completed — unlike those two
        patterns, the disjunction is preserved rather than collapsed, which is the content the
        faithful carrier adds.)*
  - [x] Prove the duals of the two chain primitives: `orderedPointsExist_combine_kminus` (dual of
        `orderedPointsExist_combine_kplus`, extending a chain **upward** by one `P`-point from
        `K⁻(P)(z₁)`) and `orderedPointsExist_widen_right` (dual of `orderedPointsExist_widen_left`).
        *(deviation: altered — both landed as specified, but `orderedPointsExist_combine_kminus`
        additionally required `orderedPointsExist_combine_right`, the right-end mirror of
        `orderedPointsExist_combine` (`EANegationFix/OnBuilder.lean:95`). The landed combine only
        ever prepends at the LEFT end, because the whole landed stack peels point types off the
        front of the list; the past direction pins the LAST point type, so the right-end mirror had
        to be built. Strict superset of the listed task; nothing was skipped or narrowed.)*
  - [x] Add the exclusion mirror `prior_makes_kminus_disjunct_unreachable`, dual to
        `prior_makes_disjunct2_unreachable`, routed through `prior_hasAttainedSUP`
        (`PriorINF.lean:275`) and the SUP-side exclusion. *(deviation: altered — the routing was
        built as specified, but "the SUP-side exclusion" did not exist. Both
        `HasAttainedSUP.toHasDefinableSUP` (mirror of `HasAttainedINF.toHasDefinableINF`,
        `PriorINF.lean:221`) and `hasDefinableSUP_excludes_kminus` (mirror of
        `hasDefinableINF_excludes_kplus`, `Lemma53.lean:290`) had to be proved first. Strict
        superset of the listed task.)*
  - [x] Add the module's import edge to `Kamp/NfMultiAnchorBridge.lean`. *(completed — verified live
        by transitive `import` walk from `FormalSystem.lean`, never by `lake build <target>`.)*
- **Files to create/modify:**
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53FaithfulPast.lean` — new, live
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — one import + NOTE
- **Kill criterion (phase-local):** if `kminusFormula` cannot be given a TL-definable spelling with
  a proved correctness lemma without a hypothesis absent from p.8, **stop**. Report the asymmetry,
  keep Phase 1 landed, and re-scope Phases 4-9 to the INF/Until direction with the left mirrors
  explicitly out of scope. Do not invent a strengthened past carrier to force the dual through.
- **Verification (additional to the standard gate):**
  - `#print axioms` clean on every new declaration named above.
  - Job count +1; live modules +1.
  - **Non-vacuity statement (required):** state what `HasDedekindSUP` excludes, mirroring Phase 1,
    and record `prior_makes_kminus_disjunct_unreachable` as the machine-checked exclusion. State
    explicitly whether the past mirror is observable by any current consumer (expected: no, for the
    same reason as the INF direction).
- **Green commit:** `task 378 phase 2: the HasDedekindSUP/Since mirror of the faithful carrier (p.8)`
- **Done when:** `kminusFormula`, `kminus_formula_correct`, `kminusPred_eval`,
  `HasDedekindSUP.last_occ_tp`, both chain duals, and the exclusion mirror are live, sorry-free and
  axiom-clean — or a bounded NO-GO report per the kill criterion.
- **Timing:** 2 hours (one agent run)
- **Depends on:** 1

**Phase 2 outcome (measured, not asserted).** `lake build` EXIT 0. Jobs **1884 → 1885** (+1); live
modules reachable from `FormalSystem.lean` **270 → 271** (+1). Tactic-position sorry census via
`.claude/scripts/lean-sorry-census.sh`: `Kamp/` unchanged at 4 dead (all under `Kamp/Boneyard/`:
`EndpointNegation.lean:164`, `FOToVEA.lean:122`, `EANegationVBracketBackward.lean:452`, `:611`),
0 live; the new module itself is 0. `#print axioms` on all **11** new declarations: every axiom set
is a subset of `{propext, Classical.choice, Quot.sound}`, no `sorryAx` anywhere — exactly
`[propext, Classical.choice, Quot.sound]` for `kminus_formula_correct`, `kminusPred_eval`,
`orderedPointsExist_combine_right`, `orderedPointsExist_combine_kminus`; strict subsets for
`orderedPointsExist_widen_right` (`[propext, Quot.sound]`), `HasDedekindSUP.last_occ_tp`,
`HasAttainedSUP.toHasDefinableSUP`, `hasDefinableSUP_excludes_kminus`,
`prior_makes_kminus_disjunct_unreachable` (all `[propext]`); no axioms for `kminusFormula`,
`kminusPred`. Real `axiom` declarations in the tree: unchanged (the only two `^axiom ` grep hits are
prose inside `FormalSystem/Boneyard/` comments, both pre-existing and untouched).

**Phase 2 deviations** (both strict supersets of a listed task; no listed task was skipped,
narrowed, or substituted — recorded inline on the checklist items above):

1. `orderedPointsExist_combine_right` added — the right-end mirror of `orderedPointsExist_combine`
   (`EANegationFix/OnBuilder.lean:95`), which only combines at the left end.
2. `HasAttainedSUP.toHasDefinableSUP` and `hasDefinableSUP_excludes_kminus` added — the "SUP-side
   exclusion" the task list routes through did not exist and had to be proved.

**Kill criterion: DID NOT FIRE.** `kminusFormula` has a TL-definable spelling
(`P.neg ∧ ¬(⊤ S P.neg)`) with a proved correctness lemma, requiring **no hypothesis absent from PDF
p.8**. `Formula.snce` is interpreted natively by `TemporalTruth` (`Table.lean:198`), exactly as
`Formula.untl` is, so `K⁻` is TL-definable on the same terms as `K⁺`. Phases 4-9 do **not** need
re-scoping to the INF/Until direction on this ground.

**Non-vacuity statement (required), written into the module docstring as well as here.**
`HasDedekindSUP` **excludes** chains on which a last occurrence of `P` in `(z₀,z₁)` has a supremum
that is none of the mirrored eq (5.2) shapes: the supremum `r₀` must satisfy `r₀ = z₁` (equivalently
`K⁻(P)(z₁)`), or `r₀ ∈ (z₀,z₁)` with `¬P` on `(r₀,z₁)` and `P(r₀) ∨ K⁻(P)(r₀)`. Bare Dedekind
completeness supplies the supremum's *existence* only; `HasDedekindSUP` additionally asserts
TL-definability in one of those shapes, so the strengthening chain mirrors the INF side exactly:
`Rabinovich's Dedekind completeness < HasDedekindSUP < HasDefinableSUP < HasAttainedSUP`.
The machine-checked exclusion is `prior_makes_kminus_disjunct_unreachable`: on every Prior
structure the `K⁻` boundary disjunct is provably dead. **Is the past mirror observable by any
current consumer? NO** — for the same reason as the INF direction: the live goal chain is Prior
structures, where SUP attainment holds outright from the SZ axiom, so no live consumer can tell
`HasAttainedSUP` and `HasDedekindSUP` apart. Observability arrives only with a genuinely
non-attained Dedekind-complete frame class, which this tree does not construct.
`hasDedekindINF_admits_kplus_shape` (`DedekindINF.lean:264`) is **not** cited as contrary evidence:
its proof is `Or.inl h_kplus` and its own docstring admits it exhibits no structure.

---

**MIGRATION GO/NO-GO GATE (applies to Phases 3-9 as a whole; not itself a phase).**

Phases 3-9 constitute the `VBracketFormula → VVecEA2` migration. It has one written kill criterion,
evaluated as a whole:

- **GO** if, at Phase 4, `negBoundedRightFixFaithful` and its `_iff` can be **stated and proved
  sorry-free at `VVecEA2`** with `negChainOnFaithful`'s disjuncts spliced (the `⟨1, rightPinBracket …⟩ ::
  disjuncts` pattern at `BoundedFix.lean:455` lifted from `Σ n, BracketFormula n` to
  `Σ n, VecEA2 n`), under `HasDedekindINF`, with no hypothesis absent from Rabinovich pp.9-11.
- **NO-GO** if the splice cannot be constructed at `VVecEA2` without such a hypothesis, **or** if any
  route to it requires touching the model-independent Prop 4.2 backward direction (Binding Constraint
  3). On NO-GO: **stop the migration.** Phases 1-3 remain landed and green; `EANegationFix/` remains
  live and correct at the attained carrier; report which of the two NO-GO conditions fired, with the
  goal state as evidence.
- **Earliest phase at which a NO-GO is visible: Phase 4.** Phase 3 is a pure combinator addition at
  a type layer that already exists; it cannot fail informatively and must not be read as evidence
  either way. Phase 4 is the first phase that actually exercises the splice, and is therefore the
  migration canary.
- **Three-strikes sizing guard (standing):** if any phase does not close in one agent run, that is a
  **sizing signal to re-split that phase**, not grounds for a second dispatch on the same target.

---

### Phase 3: The missing `VVecEA2` combinators [COMPLETED]

- **Goal:** Close the combinator gap the migration needs. Measured absent: `VVecEA2.conjEverywhere`
  and `VVecEA2.concatPin`. (`VVecEA2.prependAllVec` — the endpoint-absorbing `prependAll` — is landed
  by Phase 1.) Everything else at this layer already exists and must be reused, not rebuilt:
  `disj`/`disj_holds` (`VecEAFormula.lean:288`/`:292`), `conjFull`/`conjFull_iff`
  (`VecEAConjFull.lean:498`/`:510`), `trivialTrue` (`VecEAConjFull.lean:549`), `enrichEndpoints`,
  `disjList`, `singleton`, `conjStruct`.
- **Source correspondence:** PDF p.6 (Prop 4.3 closure of `∨∃⃗∀` under conjunction, disjunction and
  existential quantification) and p.9 (the bracket concatenation the pinned form encodes).
- **Tasks:**
  - [x] Re-confirm absence of `VVecEA2.conjEverywhere` and `VVecEA2.concatPin` by search before
        writing. *(completed — tree-wide `grep` for both names returned only `BracketFormula.*` and
        `VBracketFormula.*` hits; zero `VVecEA2.` hits. An enumeration of every `VVecEA2.` member
        in the tree confirmed the layer had `disj`, `conjFull`, `trivialTrue`, `conjStruct`,
        `disjList`, `singleton`, `enrichEndpoints`, `prependAllVec`, `negFix`, `holds*`,
        `translate*`, `toVVecEA_m` — and neither of the two. Nothing was rebuilt.)*
  - [x] Define `VVecEA2.conjEverywhere` mirroring `VBracketFormula.conjEverywhere`
        (`NegFix.lean:78`), and prove its `_holds`/`_iff` lemma. *(completed)*
  - [x] Define `VVecEA2.concatPin` mirroring `VBracketFormula.concatPin` (`ConcatPin.lean:97`), and
        prove its `_holds`/`_iff` lemma. The endpoint predicates must be carried through the pin
        point, not discarded — that carrying is the entire reason the `VVecEA2` version is needed.
        *(completed — the pinned point type is `(veaL.endpointRight ∧ pin) ∧ veaR.endpointLeft`;
        the `mpr` direction of `VecEA2.concatPin_holds_iff` is the one that consumes both, and is
        unprovable if either is dropped.)*
  - [x] Follow the `VBracketFormula` proofs structurally; per `plan-compliance.md` do not substitute
        a different decomposition. *(completed — both `VVecEA2`-level proofs are the same
        disjunct-chase as `NegFix.lean:84` and `ConcatPin.lean:104`, with the `BracketFormula`-level
        appeal replaced by the corresponding `VecEA2`-level one.)*
  - [x] Add the module's import edge to `Kamp/NfMultiAnchorBridge.lean`. *(completed — placed after
        the `Kamp.EANegationFix` edge with a cycle-freeness NOTE; liveness confirmed by transitive
        import walk from `FormalSystem.lean`, 271 → 272 modules.)*
- **Files to create/modify:**
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/VecEACombinators.lean` — new, live
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — one import + NOTE
- **Verification (additional to the standard gate):**
  - `#print axioms` clean on both new definitions' `_holds`/`_iff` lemmas.
  - Job count +1; live modules +1.
  - **Non-vacuity statement (required):** no carrier is landed or weakened here, so the requirement
    is discharged by an explicit written statement that this phase is carrier-neutral, plus a
    demonstration that each new `_holds` lemma is a **biconditional** (not a one-directional
    implication that would let a vacuous right-hand side pass). Record the exact statement of each.
- **Green commit:** `task 378 phase 3: VVecEA2.conjEverywhere and concatPin (pp.6, 9)`
- **Done when:** both combinators and their biconditional `_holds` lemmas are live, sorry-free,
  axiom-clean.
- **Timing:** 1.5 hours (one agent run)
- **Depends on:** 2

**Phase 3 measured outcome** (actual, not asserted):

| Gate | Before | After | Verdict |
|---|---|---|---|
| `lake build` exit | 0 | **0** | pass |
| Jobs | 1885 | **1886** | +1, as specified |
| Live modules from `FormalSystem.lean` | 271 | **272** | +1, as specified |
| Tactic-position sorries in `Kamp/` | 4 dead / 0 live | **4 dead / 0 live** | unchanged |
| Tactic-position sorries in the new module | — | **0** | pass |
| Real `axiom` declarations in `FormalSystem/` | 0 | **0** | unchanged |

`#print axioms` on all eight new declarations: **no `sorryAx` anywhere.** The four `_holds_iff`
lemmas are each exactly `[propext, Classical.choice, Quot.sound]`; `VecEA2.concatPin` and
`VVecEA2.concatPin` are `[propext, Quot.sound]`; `VecEA2.conjEverywhere` and
`VVecEA2.conjEverywhere` depend on no axioms.

**Non-vacuity, in the specific form this phase requires:**

1. **Carrier-neutral.** No carrier is landed or weakened. `HasDedekindINF`, `HasDedekindSUP`,
   `HasDefinableINF`/`SUP` and `HasAttainedINF`/`SUP` appear in **no** statement in the new module;
   the only structural hypothesis anywhere is `OrderedMonadicStructure sig`. Recorded as prose in
   the module docstring and checkable from the signatures.
2. **Each `_holds_iff` is a genuine biconditional**, exact statements:
   - `VecEA2.conjEverywhere_holds_iff`:
     `(vea.conjEverywhere s).holds M atomMap z0 z1 ↔ vea.holds M atomMap z0 z1 ∧ ∀ y, z0 < y → y < z1 → s.EvalAt M atomMap y`
   - `VVecEA2.conjEverywhere_holds_iff`:
     `(v.conjEverywhere s).holds M atomMap z0 z1 ↔ v.holds M atomMap z0 z1 ∧ ∀ y, z0 < y → y < z1 → s.EvalAt M atomMap y`
   - `VecEA2.concatPin_holds_iff`:
     `(veaL.concatPin pin veaR).holds M atomMap z0 z1 ↔ ∃ r, z0 < r ∧ r < z1 ∧ veaL.holds M atomMap z0 r ∧ pin.EvalAt M atomMap r ∧ veaR.holds M atomMap r z1`
   - `VVecEA2.concatPin_holds_iff`:
     `(VL.concatPin pin VR).holds M atomMap z0 z1 ↔ ∃ r, z0 < r ∧ r < z1 ∧ VL.holds M atomMap z0 r ∧ pin.EvalAt M atomMap r ∧ VR.holds M atomMap r z1`

   Both directions of both `VVecEA2` lemmas were exercised as `.mp`/`.mpr` in a compiled snippet,
   and a third compiled example derives `veaL.endpointRight.EvalAt M atomMap r` **and**
   `veaR.endpointLeft.EvalAt M atomMap r` from the forward direction alone — the fact an
   endpoint-discarding `concatPin` could not produce, which is what makes the endpoint carrying
   load-bearing rather than decorative.

**Reading discipline (from this plan's own framing):** Phase 3 is a pure combinator addition at an
existing type layer and cannot fail informatively. That it landed on the first build is **not**
evidence the `VBracketFormula` → `VVecEA2` migration will succeed. The GO/NO-GO canary is Phase 4.

**Phase 3 deviations:** none. No listed task was skipped, narrowed, substituted, or deferred.
`VecEA2.conjEverywhere` and `VecEA2.concatPin` are not deviations: both source modules are
two-layer (a `BracketFormula`-level operation plus its `V`-level lift), and reproducing that same
two-layer shape one level up is what "mirror `VBracketFormula.conjEverywhere` / `.concatPin`
structurally" means here.

---

### Phase 4: `negBoundedRightFixFaithful` / `negBoundedLeftFixFaithful` — THE MIGRATION CANARY [COMPLETED]

- **THIS PHASE CARRIES THE WHOLE-MIGRATION GO/NO-GO.** See the MIGRATION GO/NO-GO GATE block
  above. Do not dispatch Phase 5 until this resolves GO.
- **Goal:** Faithful `VVecEA2`-typed analogues of Corollary 5.4(1)/(2), consuming
  `negChainOnFaithful` at the splice point.
- **Source correspondence:** PDF p.9, Cor 5.4(1) and 5.4(2).
- **Tasks:**
  - [x] Read PDF p.9 directly. **PDF only.** *(completed — pp.9-11 read from the PDF; the corrupt
        companion `.md` was never opened. Cor 5.4(1)'s proof closes with exactly two disjuncts:
        `¬F₀(z₀) ∨ Oₙ(F₁,…,Fₙ,z₀,z₁)`, and 5.4(2) is "the mirror image of (1)".)*
  - [x] Re-confirm the current line numbers of `negBoundedRightFix_iff` (`BoundedFix.lean:455`) and
        `negBoundedLeftFix_iff` (`BoundedFix.lean:774`) and the two splice sites
        (`BoundedFix.lean:449`, `:767`) before editing. *(completed — all four re-confirmed by
        `grep -n` before any edit; no drift, the quoted values are current.)*
  - [x] Define `negBoundedRightFixFaithful : … → VVecEA2` following `negBoundedRightFix`
        structurally, with the pinned-bracket head lifted from `Σ n, BracketFormula n` to
        `Σ n, VecEA2 n` (via `VecEA2.fromBracket` at the head, `negChainOnFaithful`'s disjuncts at
        the tail). *(deviation: altered — the tail is exactly as specified; the HEAD is
        `endpointFailLeft (rightFoldHead bf)` (a `VecEA2 0` carrying `¬F₀` in `endpointLeft`)
        rather than `VecEA2.fromBracket (rightPinBracket …)`. `VecEA2.fromBracket`
        (`VecEAFormula.lean:334`) sets BOTH endpoints to `⊤`, so it lifts the pin while discarding
        precisely the endpoint slot that makes the migration worth doing — and the pin it lifts is
        the attained-first-`¬β₁` encoding, unconstructible under `HasDedekindINF`'s `K⁺` branch.
        Rationale and full audit trail in the "Deviation" subsection below; this is the deviation
        the GO verdict turns on and it is reported, not annotated silently.)*
  - [x] Prove `negBoundedRightFixFaithful_iff` under `HasDedekindINF`. *(completed — exactly
        `HasDedekindINF`, no second carrier.)*
  - [x] Mirror for `negBoundedLeftFixFaithful` / `_iff` under `HasDedekindSUP`, using Phase 2's
        `HasDedekindSUP.last_occ_tp` and `orderedPointsExist_combine_kminus`. *(deviation: altered
        — the mirror is landed and proved, but under `HasDedekindINF` ALONE; neither
        `HasDedekindSUP` nor Phase 2's two lemmas are consumed. Reason: `HasDedekindSUP` entered
        the attained `negBoundedLeftFix_iff` for one purpose only — placing `leftPinBracket`'s
        attained LAST `¬βₙ`-point. The chain arm of Cor 5.4(2) is still an increasing chain
        (`chainAllTrue (sinceChainPreds …)`), hence still `negChainOnFaithful` and still
        `HasDedekindINF`. Once the head is the printed `¬Ĝ(z₁)`, the SUP carrier has nothing left
        to do. Stating it anyway would be an unused hypothesis — a strengthening that buys nothing
        and hides what the proof costs. Phase 2 is not wasted: `HasDedekindSUP.last_occ_tp` and
        `orderedPointsExist_combine_kminus` are the Phase 6 inputs (`NegFixOne.lean:243`/`:276`
        call `h_SUP.last_occ_tp`), which is where they are now expected to be consumed.)*
  - [x] **Do not edit `BoundedFix.lean` in place.** The faithful versions live in a new module and
        are additions; the attained ones stay live and consumed. *(completed — `git status` shows
        `BoundedFix.lean` unmodified; the new module imports it and edits nothing.)*
  - [x] Add the module's import edge to `Kamp/NfMultiAnchorBridge.lean`. *(completed — placed after
        the `Kamp.VecEACombinators` edge with a cycle-freeness NOTE; liveness confirmed by
        transitive import walk from `FormalSystem.lean`, 272 → 273 modules.)*
- **Files to create/modify:**
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/BoundedFixFaithful.lean` — new, live
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — one import + NOTE
- **Verification (additional to the standard gate):**
  - `#print axioms` clean on `negBoundedRightFixFaithful_iff` and `negBoundedLeftFixFaithful_iff`.
  - Job count +1; live modules +1.
  - `lake build` confirms `NfMultiAnchorBridge/AggregateOffDiagK1.lean` still compiles — **the
    regression check that matters most from here on.**
  - **Non-vacuity statement (required):** confirm neither arm re-introduces attainment. Concretely:
    state that the only carrier hypotheses in each statement are `HasDedekindINF` /
    `HasDedekindSUP`, and record that the `kplus`/`kminus` branch of each carrier is genuinely taken
    in the proof (name the branch and the lemma discharging it), not routed around by a case that
    silently assumes an attained witness.
  - **GO/NO-GO recorded explicitly** in the phase notes and in the handoff.
- **Green commit:** `task 378 phase 4: faithful Cor 5.4(1)/(2) at VVecEA2 (p.9)`
- **Done when:** both `_iff` lemmas are live, sorry-free, axiom-clean under the faithful carriers,
  with the GO verdict recorded — **or** a bounded NO-GO report naming which condition fired.
- **Timing:** 2 hours (one agent run)
- **Depends on:** 3

## MIGRATION VERDICT: **GO**

Recorded against the MIGRATION GO/NO-GO GATE block above, quoting its own GO condition:

> **GO** if, at Phase 4, `negBoundedRightFixFaithful` and its `_iff` can be **stated and proved
> sorry-free at `VVecEA2`** with `negChainOnFaithful`'s disjuncts spliced …, under
> `HasDedekindINF`, with no hypothesis absent from Rabinovich pp.9-11.

All four conjuncts hold, measured:

| GO conjunct | Result |
|---|---|
| stated at `VVecEA2` | `negBoundedRightFixFaithful : BracketFormula n → VVecEA2` |
| proved sorry-free | tactic-position census on the new module: **0** |
| `negChainOnFaithful`'s disjuncts spliced | `… :: (negChainOnFaithful (untilChainPreds bf.foldPairs)).disjuncts`, verbatim the `_ :: disjuncts` pattern |
| under `HasDedekindINF` | the only carrier hypothesis in either `_iff` |
| no hypothesis absent from pp.9-11 | **zero** hypotheses added; the head disjunct is Rabinovich's printed `¬F₀(z₀)` and consumes no carrier at all |

Neither NO-GO condition fired. Condition 1 (splice needs an absent hypothesis) did not fire — the
splice needed strictly FEWER hypotheses, not more. Condition 2 (route requires the model-independent
Prop 4.2 backward direction) did not fire — `EANegation.lean:1090` and `:1249` were not read, not
referenced, and not touched; `EANegation.lean` was not edited.

**The canary's actual finding, stated plainly because it is the migration's whole thesis.** The
attained `negBoundedRightFix_iff` consumes `HasAttainedINF` in TWO places: once via `negChainOn_iff`
(Lemma 5.3) and once via `h_INF.first_occ_tp` (`BoundedFix.lean:521`) to construct
`rightPinBracket`'s attained first `¬β₁`-point. That second consumption is not in Rabinovich — it is
an artifact of `VBracketFormula` carrying no endpoint predicates, so the paper's *point* condition
`¬F₀(z₀)` had to be re-encoded as an *interval* condition. `VVecEA2.holds`
(`VecEAFormula.lean:268`) is `endpointLeft(z₀) ∧ endpointRight(z₁) ∧ bracket(z₀,z₁)`, so at the
migrated type `¬F₀(z₀)` is writable as printed and the second consumption simply disappears. **The
migration does not merely survive the canary; the canary is where its payoff is realized.**

**Phase 4 measured outcome** (actual, not asserted):

| Gate | Before | After | Verdict |
|---|---|---|---|
| `lake build` exit | 0 | **0** | pass |
| Jobs | 1886 | **1887** | +1, as specified |
| Live modules from `FormalSystem.lean` | 272 | **273** | +1, as specified |
| Tactic-position sorries in `Kamp/` | 4 dead / 0 live | **4 dead / 0 live** | unchanged |
| Tactic-position sorries in the new module | — | **0** | pass |
| Real `axiom` declarations in `FormalSystem/` | 0 | **0** | unchanged |
| `NfMultiAnchorBridge/AggregateOffDiagK1.lean` | builds | **builds (1098 jobs, EXIT 0)** | no regression |

Census is tactic-position via `.claude/scripts/lean-sorry-census.sh`, never `grep -c`. The four dead
sorries are unchanged and all under `Kamp/Boneyard/`: `EndpointNegation.lean:164`,
`FOToVEA.lean:122`, `EANegationVBracketBackward.lean:452`, `:611`. Liveness was decided by a
transitive `import` walk from `FormalSystem.lean`; `lake build BoneyardArchive` was never run or
cited. The bare `grep -c '^axiom '` count over `FormalSystem/` is 2 and unchanged — both hits are
prose continuation lines inside `Boneyard/` comments, neither is a declaration.

`#print axioms` (via `lean_verify`) on all six new declarations: **no `sorryAx` anywhere.**
`negBoundedRightFixFaithful_iff`, `negBoundedLeftFixFaithful_iff`,
`endpointFailLeft_of_rightPinBracket`, `endpointFailRight_of_leftPinBracket` are each exactly
`[propext, Classical.choice, Quot.sound]`; `endpointFailLeft_holds` and `endpointFailRight_holds`
are `[propext, Quot.sound]`.

**Non-vacuity, in the specific form this phase requires.**

1. **Neither arm re-introduces attainment.** The only carrier hypothesis in
   `negBoundedRightFixFaithful_iff` is `HasDedekindINF`; the only carrier hypothesis in
   `negBoundedLeftFixFaithful_iff` is `HasDedekindINF`. `HasAttainedINF`, `HasAttainedSUP`,
   `HasDefinableINF` and `HasDefinableSUP` appear in **no** statement in the module except the two
   deliberate `_of_attained` shims, whose entire content is "the attained hypothesis still reaches
   this result". Checkable from the signatures.
2. **The `K⁺` branch is genuinely taken — branch and discharging lemma named.** The head disjunct of
   each formula takes NO branch of any carrier: it consumes no carrier at all
   (`endpointFailLeft_holds`/`endpointFailRight_holds` have no structural hypothesis beyond
   `OrderedMonadicStructure`). The carrier is spent entirely in the chain arm, through the
   `negChainOnFaithful_iff` call each `_iff` makes in **both** directions. Inside that lemma
   (`Lemma53Faithful.lean:274`) the proof `rcases`es `h_INF.first_occ`; its **left** disjunct — `hk
   : kplus M atomMap P z0`, Rabinovich's *Subcase r₀ = z₀* (PDF p.8) — is the branch at
   `Lemma53Faithful.lean:277-282`, and it is discharged by **`orderedPointsExist_combine_kplus`**
   (`Lemma53Faithful.lean:281`). That is a live branch on the code path both `_iff` lemmas invoke,
   not dead syntax and not routed around.
   The `K⁻`/`kminus` branch is **not** taken anywhere in this phase, because `HasDedekindSUP` is not
   consumed here at all — see the second altered task above. Recorded rather than papered over:
   claiming a `kminus` discharge here would be false.
3. **No case silently assumes an attained witness.** The failure mode this check exists to catch is
   a proof that routes around the weak branch by quietly reintroducing attainment. The route is
   closed structurally, not by inspection: the only two proof obligations in either `_iff` are the
   endpoint condition (carrier-free by signature) and `negChainOnFaithful_iff` (whose carrier is
   `HasDedekindINF` by signature). There is no third obligation into which an attained witness
   could be smuggled — which is exactly the difference from `negBoundedRightFix_iff`, whose third
   obligation (`BoundedFix.lean:521`) is precisely such a witness.
4. **Machine-checked subsumption, so "nothing is lost" is verified rather than argued.**
   `endpointFailLeft_of_rightPinBracket` and `endpointFailRight_of_leftPinBracket` prove that
   wherever the attained pin disjunct fires, the faithful endpoint disjunct fires too — with no
   carrier hypothesis on either side. The converse fails (an interval where `F₀(z₀)` merely fails,
   with no attained first `¬β₁`-point, satisfies the endpoint disjunct and no pin), and that
   asymmetry is the carrier drop made concrete.

**Deviation (one substantive, reported not annotated-and-passed).** Per
`.claude/rules/plan-compliance.md`, a would-be deviation on a `.lean` file is raised rather than
silently substituted. Raising it here rather than blocking, because the plan's own GO/NO-GO gate —
the higher-level contract this phase exists to evaluate — *forces* it, and the two conflict:

- The task line prescribes the head via `VecEA2.fromBracket`. `VecEA2.fromBracket`
  (`VecEAFormula.lean:334`) sets `endpointLeft := ⊤` and `endpointRight := ⊤`. So the prescribed
  mechanism lifts `rightPinBracket` into `VecEA2` while **discarding the one feature of `VecEA2`
  the migration exists to exploit**, and what it lifts is the attained-witness encoding.
- Under `HasDedekindINF` that head is **not provable**. In the `K⁺(¬β₁)(z₀)` branch, `¬β₁` holds
  throughout some initial segment above `z₀`, so no `r` satisfies `rightPinBracket`'s requirement
  that `β₁` hold on all of `(z₀,r)` unless `(z₀,r)` is empty — which needs discreteness, a
  hypothesis absent from pp.9-11. Following the task line literally would therefore have produced
  NO-GO condition 1 by construction, on a mechanism the paper does not use.
- The gate's GO condition is about **hypotheses** ("with no hypothesis absent from Rabinovich
  pp.9-11"), not about the head's construction mechanism. The landed head satisfies it with strictly
  fewer hypotheses than the prescribed one and is Rabinovich's printed disjunct verbatim.

The tail is exactly as prescribed. `negChainOnFaithful`'s disjuncts are spliced unchanged, and
`VecEA2.fromBracket` remains in use throughout the tail via `negChainOnFaithful`'s own construction.
No alternative decomposition was substituted for anything else in the phase.

**Second, minor deviation (strict superset, no listed task skipped or narrowed):**
`endpointFailLeft_of_rightPinBracket` / `endpointFailRight_of_leftPinBracket` and the two
`_of_attained` shims are additions beyond the task list, added to make non-vacuity items 1 and 4
machine-checked rather than prose. Nothing listed was dropped to make room.

---

### Phase 5: The anchored mirrors [NOT STARTED]

- **Goal:** Faithful `VVecEA2` analogues of the anchored bounded-fix pair, covering the remaining
  two splice sites (`BoundedFixAnchored.lean:158`, `:385`).
- **Source correspondence:** PDF p.9 (Cor 5.4 applied at an anchored endpoint) and p.10 (Figure 1's
  anchoring).
- **Tasks:**
  - [ ] Re-confirm the two splice sites' current line numbers before editing.
  - [ ] Define and prove the anchored faithful analogues, following `BoundedFixAnchored.lean`
        structurally, reusing Phase 4's construction rather than re-deriving it. Where Phase 4's
        lemma applies directly, apply it — do not restate.
  - [ ] Additions only; do not edit `BoundedFixAnchored.lean` in place.
  - [ ] Add the module's import edge to `Kamp/NfMultiAnchorBridge.lean`.
- **Files to create/modify:**
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/BoundedFixAnchoredFaithful.lean` — new, live
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — one import + NOTE
- **Verification (additional to the standard gate):**
  - `#print axioms` clean on each new `_iff` lemma; job count +1; live modules +1.
  - `AggregateOffDiagK1.lean` still builds.
  - **Non-vacuity statement (required):** as Phase 4 — confirm no anchored arm re-introduces
    attainment, naming the carrier branch taken in each direction.
- **Green commit:** `task 378 phase 5: faithful anchored bounded-fix mirrors at VVecEA2 (pp.9-10)`
- **Done when:** the anchored faithful pair is live, sorry-free, axiom-clean.
- **Timing:** 1.5 hours (one agent run)
- **Depends on:** 4

---

### Phase 6: `negFixOneFaithful` — Lemma 5.1 at `n = 1` [NOT STARTED]

- **Goal:** The `n = 1` case of Lemma 5.1 at `VVecEA2` over the faithful carriers, following
  `NegFixOne.lean` structurally.
- **Source correspondence:** PDF pp.9-10, Lemma 5.1 base case; eq (5.3) `INF^{¬β₁}`.
- **Tasks:**
  - [ ] Read PDF pp.9-10 directly, including Figure 1 (p.10) and eq (5.3). **PDF only.**
  - [ ] Define `negFixOneFaithful` and prove its cover/`_iff` lemmas, mirroring
        `NegFixOne.lean:224`/`:243`/`:272`/`:276`, which currently call `h_INF.first_occ_tp` and
        `h_SUP.last_occ_tp` at the attained carriers — these become `HasDedekindINF.first_occ` (via
        the Phase 1 pattern) and Phase 2's `HasDedekindSUP.last_occ_tp`.
  - [ ] Additions only; `NegFixOne.lean` is not edited.
  - [ ] Add the module's import edge to `Kamp/NfMultiAnchorBridge.lean`.
- **Files to create/modify:**
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/NegFixOneFaithful.lean` — new, live
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — one import + NOTE
- **Verification (additional to the standard gate):**
  - `#print axioms` clean on the cover and `_iff` lemmas; job count +1; live modules +1.
  - `AggregateOffDiagK1.lean` still builds.
  - **Non-vacuity statement (required):** state which of the four attained call sites
    (`NegFixOne.lean:224`, `:243`, `:272`, `:276`) each faithful counterpart replaces, and confirm
    each now consumes only a faithful carrier. Any site that still needs attainment is a
    strengthening and must be reported, not silently kept.
- **Green commit:** `task 378 phase 6: faithful Lemma 5.1 base case at VVecEA2 (pp.9-10)`
- **Done when:** `negFixOneFaithful` and its lemmas are live, sorry-free, axiom-clean under the
  faithful carriers only.
- **Timing:** 2 hours (one agent run)
- **Depends on:** 5

---

### Phase 7: `negFixListFaithful` — the recursion [NOT STARTED]

- **THE COST CENTRE. This is the one phase this plan expects to overrun a single agent run, and it
  says so up front.** `negFixList` (`NegFix.lean:449`, with `negFixList_iff` at `:520`) is a
  681-line recursion whose Case 2 / Case 3 gates are built around the **attained pin**; admitting the
  `K⁺`/`K⁻` limit case adds a third gate to each.
- **Goal:** The faithful `VVecEA2` analogue of the `Aᵢ`/`Bᵢ` split and closing induction.
- **Source correspondence:** PDF pp.10-11, including the two displayed equivalences on p.11.
- **Tasks:**
  - [ ] Read PDF pp.10-11 directly. **PDF only.**
  - [ ] Define `negFixListFaithful` and prove `negFixListFaithful_iff`, following `NegFix.lean`
        step-by-step. **Prefer generalizing the existing proof over rewriting it** — the structure is
        Rabinovich's and is already proved; only the carrier and the type change.
  - [ ] Reuse Phase 3's `VVecEA2.concatPin` and the landed pinned `conjFull`; the `Aᵢ`/`Bᵢ` split is
        **already formalized** and needs re-carrying, not re-deriving.
  - [ ] Additions only; `NegFix.lean` is not edited.
- **Mandatory internal re-split boundaries.** If this phase does not close in one agent run, **stop
  and re-split at the next boundary below** — do not dispatch again on the same whole target
  (three-strikes sizing guard). The boundaries, in order, each a legitimate stopping point with a
  green build and an updated handoff:
  - **7a** — the Case 2 gate (attained pin → faithful three-way gate) in isolation.
  - **7b** — the Case 3 gate, same treatment.
  - **7c** — the closing induction over the `Aᵢ`/`Bᵢ` split, given 7a and 7b.
  A re-split converts this phase into Phases 7a/7b/7c in the plan file, each with the standard gate.
- **Sorry discipline:** stopping at 7a or 7b with nothing landed for the remainder is CORRECT.
  Landing a sorry-bodied `negFixListFaithful` is NOT — the sorry gate admits zero live sorries. A
  boundary that cannot close is `[BLOCKED]`, not `[PARTIAL]` with debt.
- **Files to create/modify:**
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/NegFixListFaithful.lean` — new, live
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — one import + NOTE
- **Verification (additional to the standard gate):**
  - `#print axioms negFixListFaithful_iff` clean; job count +1; live modules +1.
  - `AggregateOffDiagK1.lean` still builds.
  - **Non-vacuity statement (required):** for each of Case 2 and Case 3, state the three gates
    explicitly and confirm the third (limit) gate is **reachable in the proof**, not dead syntax
    admitted for type-checking. If a gate is provably unreachable, say so and say why — that is the
    same class of finding as `prior_makes_disjunct2_unreachable` and must be recorded, not hidden.
- **Green commit:** `task 378 phase 7: faithful negFixList recursion at VVecEA2 (pp.10-11)`
  (or `task 378 phase 7a: …` etc. after a re-split)
- **Done when:** `negFixListFaithful_iff` is live, sorry-free, axiom-clean — or a bounded stop at a
  named boundary (7a/7b/7c) with the plan re-split and everything before it green.
- **Timing:** 3-4 hours (expected to require a re-split into 7a/7b/7c)
- **Depends on:** 6

---

### Phase 8: The faithful `negFix` lift chain [NOT STARTED]

- **Goal:** `BracketFormula.negFixFaithful` → `VecEA2.negFixFaithful` → `VVecEA2.negFixFaithful`,
  with their `_iff` lemmas at the faithful carriers.
- **Source correspondence:** PDF pp.10-11 (Lemma 5.1) and p.6 (Prop 4.3's De Morgan fold, which
  `VVecEA2.negFix` at `VecEANegFix.lean:154` already encodes).
- **Tasks:**
  - [ ] Re-confirm the current line numbers of `BracketFormula.negFix_iff` (`NegFix.lean:694`),
        `VVecEA2.negFix` (`VecEANegFix.lean:154`), `VVecEA2.negFix_iff` (`VecEANegFix.lean:183`) and
        the lift point (`VecEANegFix.lean:67`) before editing.
  - [ ] Build the three faithful analogues in that order, each proved from the previous, following
        the landed lift structurally.
  - [ ] **Binding Constraint 3 applies with full force here.** These are carrier-anchored
        (`HasDedekindINF`/`HasDedekindSUP`) throughout. The model-independent `BracketFormula`-level
        backward direction is out of scope and must not be attempted, cited as license, or worked
        around. If a step appears to require it, that is a `[BLOCKED]` escalation, not a fourth
        attempt.
  - [ ] Additions only; `NegFix.lean` and `VecEANegFix.lean` are not edited.
- **Files to create/modify:**
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/VecEANegFixFaithful.lean` — new, live
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — one import + NOTE
- **Verification (additional to the standard gate):**
  - `#print axioms` clean on all three `_iff` lemmas; job count +1; live modules +1.
  - `AggregateOffDiagK1.lean` still builds.
  - **Non-vacuity statement (required):** confirm the lift preserves the faithful carrier at every
    step — i.e. no intermediate lemma silently re-anchors to `HasAttainedINF` via a shim. The shims
    go attained → faithful (`HasAttainedINF.toHasDedekindINF`), so any use in the **opposite**
    direction is a strengthening and must be reported.
- **Green commit:** `task 378 phase 8: faithful negFix lift chain at VVecEA2 (pp.6, 10-11)`
- **Done when:** all three faithful `_iff` lemmas are live, sorry-free, axiom-clean.
- **Timing:** 2 hours (one agent run)
- **Depends on:** 7

---

### Phase 9: `prop42_contentful_of_dedekind` — terminal fidelity milestone [NOT STARTED]

- **Goal:** The faithful analogue of `prop42_contentful_of_attained`
  (`Section5Correspondence.lean:128`), plus the final regression and correspondence-table update.
- **Source correspondence:** PDF p.6, Prop 4.2.
- **Tasks:**
  - [ ] Read PDF p.6 directly. **PDF only.**
  - [ ] State and prove `prop42_contentful_of_dedekind` in the **hoisted, contentful** shape,
        matching `prop42_contentful_of_attained` verbatim except for the carrier.
  - [ ] Extend `Section5Correspondence.lean`'s page-cited table with the faithful rows landed by
        Phases 1-9, each citing its PDF page. Do not delete or renumber existing rows.
  - [ ] Add the module's import edge to `Kamp/NfMultiAnchorBridge.lean` if a new module is used.
- **Files to create/modify:**
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/Prop42Faithful.lean` — new, live
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/Section5Correspondence.lean` — table rows appended
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — one import + NOTE
- **Verification (additional to the standard gate):**
  - `#print axioms prop42_contentful_of_dedekind` → exactly `[propext, Classical.choice, Quot.sound]`.
  - Job count +1; live modules +1.
  - Full `lake build` EXIT 0; `AggregateOffDiagK1.lean` still builds; the attained stack
    (`EANegationFix/`) is untouched and still live.
  - **Failed-vacuity check re-run against the FINAL statement**, per the
    `lemma53Faithful_perPoint_is_VACUOUS` template: exhibit the per-point ordering as vacuous and the
    hoisted ordering as the claim. A contentful statement that silently drifted to a vacuous one
    during transcription is the exact failure this plan exists to prevent.
  - **Non-vacuity statement (required, final and cumulative):** one consolidated statement covering
    the whole re-base — what `HasDedekindINF`/`HasDedekindSUP` exclude, that disjunct (2) and its
    dual are provably dead on every Prior structure, that no live consumer can yet observe the
    difference, and that observability arrives only with a genuinely non-attained Dedekind-complete
    frame class (which this task does not build).
  - Total delta recorded: expected **1883 → 1891 jobs**, **269 → 277 live modules** (8 new modules
    across Phases 1-9; adjust for any Phase 7 re-split, which adds modules).
- **Green commit:** `task 378 phase 9: prop42_contentful_of_dedekind, the faithful Prop 4.2 (p.6)`
- **Done when:** `prop42_contentful_of_dedekind` is live, sorry-free, axiom-clean, with the
  correspondence table extended and the cumulative non-vacuity statement written.
- **Timing:** 1.5 hours (one agent run)
- **Depends on:** 8

## Testing & Validation

- [ ] `lake build` EXIT 0 after every phase.
- [ ] `bash .claude/scripts/lean-sorry-census.sh FormalSystem/Metalogic/WeakCanonical/Kamp` reports
      `sorry_count: 0` live at every phase boundary (4 dead sorries under `Kamp/Boneyard/` are
      expected and are not live: `EndpointNegation.lean:164`, `FOToVEA.lean:122`,
      `EANegationVBracketBackward.lean:452`, `:611`). Never `grep -c`.
- [ ] `#print axioms` on every new declaration → exactly `[propext, Classical.choice, Quot.sound]`.
- [ ] Liveness by transitive `import` walk from `FormalSystem.lean` for every new module. Never
      `lake build BoneyardArchive` — it passes vacuously.
- [ ] Job-count and live-module deltas match the per-phase expectations against the re-measured
      dispatch-time baseline.
- [ ] `NfMultiAnchorBridge/AggregateOffDiagK1.lean` builds at every phase from 4 onward.
- [ ] Every new declaration carries a PDF-page source correspondence.
- [ ] Every phase records its non-vacuity / exclusion statement.
- [ ] No file deleted; no attained-carrier declaration deleted or weakened.
- [ ] No file outside `specs/**` contains a task-number reference.

## Artifacts & Outputs

- `specs/378_rebase_section5_onto_faithful_dedekind_carrier/plans/01_faithful-dedekind-section5-rebase.md` (this file)
- `specs/378_rebase_section5_onto_faithful_dedekind_carrier/summaries/01_faithful-dedekind-section5-rebase-summary.md`
- New live Lean modules (8 expected, more if Phase 7 re-splits):
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53Faithful.lean`
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53FaithfulPast.lean`
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/VecEACombinators.lean`
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/BoundedFixFaithful.lean`
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/BoundedFixAnchoredFaithful.lean`
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/NegFixOneFaithful.lean`
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/NegFixListFaithful.lean`
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/VecEANegFixFaithful.lean`
  - `FormalSystem/Metalogic/WeakCanonical/Kamp/Prop42Faithful.lean`
- Modified: `Kamp/NfMultiAnchorBridge.lean` (import edges), `Kamp/Section5Correspondence.lean`
  (table rows + line-number corrections), `Kamp/Lemma53.lean` (docstring correction).

## Rollback/Contingency

- **Per-phase.** Every phase is additive: new modules plus one import line in
  `NfMultiAnchorBridge.lean`. Rollback is `git revert` of that phase's commit, or removal of the new
  module together with its import edge. Nothing in `EANegationFix/` is edited in place, so the
  attained-carrier stack cannot regress by construction.
- **Phase 4 NO-GO.** Stop the migration. Phases 1-3 stay landed and green (the faithful Lemma 5.3,
  its past mirror, and the `VVecEA2` combinators are self-contained and valuable independently).
  Report which NO-GO condition fired with the goal state as evidence. Mark Phases 5-9 `[BLOCKED]`.
- **Phase 7 overrun.** Re-split into 7a/7b/7c per the named boundaries and re-dispatch the next
  boundary only. A green build at 7a with 7b/7c unstarted is a correct, committable state.
- **Any phase that cannot close.** Mark `[BLOCKED]`, land nothing for that unit, keep the previous
  phase's green commit, and record what was tried and the goal state reached. Do **not** land a
  strategic sorry — the sorry gate admits zero.
- **Regression in the attained stack.** If `AggregateOffDiagK1.lean` or any `EANegationFix/` module
  breaks, that is a defect in the phase just landed, not an acceptable cost. Revert that phase's
  commit and re-approach; never "fix" it by weakening or deleting an attained-carrier declaration.
- **Before any destructive git operation on a dirty tree**, run
  `bash .claude/scripts/git-snapshot.sh` first (per `.claude/rules/git-workflow.md`).
