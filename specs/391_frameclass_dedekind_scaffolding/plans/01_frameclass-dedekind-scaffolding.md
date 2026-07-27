# Implementation Plan: FrameClass Dedekind Scaffolding

- **Task**: 391 - frameclass_dedekind_scaffolding
- **Status**: [IMPLEMENTING]
- **Effort**: 17 hours (8 phases)
- **Dependencies**: Task 390 (research, COMPLETE)
- **Research Inputs**: `specs/390_dedekind_carrier_construction_research/reports/01_dedekind-carrier-construction.md`
- **Artifacts**: plans/01_frameclass-dedekind-scaffolding.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/rules/plan-compliance.md
- **Type**: lean4
- **Mode**: hard (H3 reference grounding Tier 1, H7 territory, H8 phase sizing, H9 sorry inventory)
- **Plan shape**: SKELETON — the critical path ends in three declared strategic-sorry division
  points in Phase 8, discharged by two follow-up tasks.

---

## Overview

Land the frame-class and axiom scaffolding for a Dedekind-complete extension of the bimodal
proof system: a fourth `FrameClass` constructor `.Dedekind` sitting strictly above `.Dense`,
Reynolds' three gap/separation axioms as new `Axiom` constructors, a `ValidDedekind` /
`ValidDedekindDense` pair of semantic predicates, a `DedekindTemporalFrame` marker class, and a
`soundness_dedekind` skeleton whose only debt is three declared, tracked strategic sorries for
the semantic validity of the three new axioms.

The carrier question is settled and requires no work: the live parametric canonical scaffolding
was compile-verified in the research to instantiate at `ℝ` with zero modifications. What is
actually expensive here is blast radius, not mathematics — `FrameClass` occurs 1460 times across
96 live files and the `Axiom` inductive has 42 constructors consumed by five exhaustive-match
sites plus four independent name/coverage lists in `FormalSystem/Automation/`.

**Definition of done**: `lake build` green; `bash scripts/typst-sync-check.sh` green; exactly
three new `declaration uses 'sorry'` warnings relative to the pre-Phase-1 baseline, all three
matching rows in the Planned Strategic Sorries table below.

### Research Integration

| Report | Integrated | Date |
|---|---|---|
| `specs/390_dedekind_carrier_construction_research/reports/01_dedekind-carrier-construction.md` | plan v1 | 2026-07-27 |

The research report's nine-phase decomposition is the starting point. This plan **retains its
phases 1-5 and re-decomposes them**, and **excludes its phases 6-9** (`ℚ`-flowed Prior/Sep model,
Reynolds Theorems 4/5, Doets transfer, `completeness_dedekind`) as out of scope for this task —
they are the report's highest-risk items and belong to separate work.

### Preserved Assets

No prior plan or prior implementation exists for this task. The following **existing tree assets
are load-bearing for this plan and must not regress**:

| Component | File | Status | Verified |
|---|---|---|---|
| `Axiom` inductive, 42 constructors | `FormalSystem/ProofSystem/Axioms.lean:84-356` | [COMPLETED] | 2026-07-27 (this plan, `awk` recount = 42) |
| `Axiom.minFrameClass` (single source of truth) | `FormalSystem/ProofSystem/Axioms.lean:412-418` | [COMPLETED] | 2026-07-27 |
| `DerivationTree` axiom gate `h.minFrameClass ≤ fc` | `FormalSystem/ProofSystem/Derivation.lean:98` | [COMPLETED] | 2026-07-27 (generic in `fc`; expected NO-OP) |
| `soundness` / `soundness_dense` / `soundness_discrete` | `FormalSystem/Metalogic/Soundness.lean:1050 / :1218 / :1361` | [COMPLETED] | 2026-07-27 |
| `axiom_dense_valid` / `axiom_discrete_valid` | `FormalSystem/Metalogic/Soundness.lean:887 / :944` | [COMPLETED] | 2026-07-27 |
| `axiom_swap_valid_general` (frame-class-free, reusable) | `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean:40` | [COMPLETED] | 2026-07-27 |
| `valid` / `ValidDense` / `ValidDiscrete` + bridges | `FormalSystem/Semantics/Validity.lean:79 / :169 / :187 / :200 / :207` | [COMPLETED] | 2026-07-27 |
| Marker classes `LinearTemporalFrame`/`SerialFrame`/`DenseTemporalFrame`/`DiscreteTemporalFrame` | `FormalSystem/FrameConditions/FrameClass.lean:88 / :103 / :124 / :148` | [COMPLETED] | 2026-07-27 |
| `allAxiomNames` (42-name canonical list) | `FormalSystem/Automation/AxiomNames.lean:33` | [COMPLETED] | 2026-07-27 |
| Committed machine appendix | `typst/generated/machine-appendix.{jsonl,typ}` | [COMPLETED] | 2026-07-27 |

### Anchor Verification (all task-description file:line references checked against the tree)

| Description anchor | Verified | Note |
|---|---|---|
| `Axioms.lean:378-382` `inductive FrameClass` | CONFIRMED | exact |
| `Axioms.lean:384` `LE` instance | CONFIRMED | exact, body as quoted |
| `Axioms.lean:391` `DecidableRel` | CONFIRMED | exact |
| `Axioms.lean:394` `PartialOrder` | CONFIRMED | exact |
| `Axioms.lean:412` `Axiom.minFrameClass`; rows `:413-417` | CONFIRMED | exact |
| `Axioms.lean:343` `density`, `:354` `dense_indicator` | CONFIRMED | exact |
| `Axioms.lean:315` `prior_UZ`, `:320` `prior_SZ` | CONFIRMED | exact; forms are `F(φ) → U(φ,¬φ)` / `P(φ) → S(φ,¬φ)` as described |
| `Axioms.lean:301` `discrete_box_necessity` (Base axiom) | CONFIRMED | exact |
| `Derivation.lean:98` axiom-constructor gate | CONFIRMED | exact |
| `Validity.lean:79` `valid`, `:169` `ValidDense`, `:187` `ValidDiscrete`, `:200`/`:207` bridges | CONFIRMED | exact; names are `ValidDense`/`ValidDiscrete` as the description warns |
| `Soundness.lean:1050` `soundness`, `:1218` `soundness_dense`, `:1361` `soundness_discrete` | CONFIRMED | exact |
| `FrameClassVariants.lean:40` `axiom_swap_valid_general` | CONFIRMED | exact; frame-class-free |
| `FrameConditions/FrameClass.lean:88/:103/:124/:148` marker classes | CONFIRMED | exact |
| `Completeness.lean:196/:255/:296` and `:173-193` sorryAx note | CONFIRMED | exact |
| grep count `FrameClass` = 1460 / 96 files (1735 / 120 with Boneyard) | CONFIRMED | reproduced exactly |
| "42 axiom constructors" | CONFIRMED | `awk` range recount = 42 (a naive `^  \| [a-z]` grep undercounts to 40 because `F_until_equiv` and `P_since_equiv` start uppercase) |

**No drift found.** Every anchor in the task description is accurate. The research report's
Finding 0 corrections (`Theories/Bimodal/` → `FormalSystem/`) have already been applied to the
task description.

### Source-to-Implementation Mapping (H3, Tier 1)

All three axiom forms and both `K±` definitions were **read verbatim from the primary source
chunk** `/home/benjamin/Projects/Literature/sources/reynolds_1992/sec01_an-axiomatization-for-until-and-since-ov.md`
(`provenance_fidelity: verified_conversion`), corroborated for `K±` by GHR 1994 §10.3.1
(`gabbay_1994/ch1002_1031-introduction.md`). The task description's rendering is **correct in
every character**. None of the `[UNVERIFIED]`-marked briefing entries are load-bearing for any
claim in this plan.

| Source | Prop / Location | Lean Identifier | Type Signature / Statement | Status |
|---|---|---|---|---|
| Reynolds 1992 | Abbreviation table, printed p.168 | `Formula.kPlus` | `(Formula.untl Formula.top A.neg).neg` — i.e. `K⁺A = ¬U(⊤,¬A)` | pending (Phase 5) |
| Reynolds 1992 | Abbreviation table, printed p.168 | `Formula.kMinus` | `(Formula.snce Formula.top A.neg).neg` — i.e. `K⁻A = ¬S(⊤,¬A)` | pending (Phase 5) |
| GHR 1994 | §10.3.1, PDF idx 8 (corroborating) | (same) | `K⁺q = ¬U(⊤,¬q)`, `K⁻q = ¬S(⊤,¬q)` | corroborated |
| Reynolds 1992 | Prior-U, printed p.168 | `Axiom.prior_U_gap` | `U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p), p)` | pending (Phase 5) |
| Reynolds 1992 | Prior-S, printed p.168 | `Axiom.prior_S_gap` | `S(⊤,p) ∧ P¬p → S(¬p ∨ K⁻(¬p), p)` | pending (Phase 5) |
| Reynolds 1992 | Sep, printed p.168 | `Axiom.sep` | `K⁺p ∧ ¬K⁺(p ∧ U(p,¬p)) → K⁺(K⁺p ∧ K⁻p)` | pending (Phase 5) |
| Reynolds 1992 | "density and no end points" axioms, printed p.168 | `Axiom.dense_indicator` (existing), `Axiom.serial_future`/`serial_past` (existing) | `K⁺⊤ = ¬U(⊤,⊥)` is literally `dense_indicator`; `F⊤`/`P⊤` are `serial_future`/`serial_past` | **PRESENT** — grounds `Dense ≤ Dedekind` |
| Reynolds 1992 | "definably Dedekind complete", printed p.169 | docstring of `ValidDedekind` | prose: gaps may exist but are temporally invisible | pending (Phase 3) |
| Reynolds 1992 | Sep validity deferred to §7 Lemma 10, printed p.168 note | `sep_valid` | `IsValid` over dense Dedekind-complete `D` | **strategic sorry** (Phase 8) → `406` |
| Reynolds 1992 | "It is clear that all these axioms are valid over the reals", printed p.168 | `prior_U_gap_valid`, `prior_S_gap_valid` | `IsValid` over dense Dedekind-complete `D` | **strategic sorry** (Phase 8) → `405` |
| Research 390 | Finding 1, compile-verified probe | `ValidDedekind` | Variant B, `LinearOrder` + Prop-valued LUB hypothesis | pending (Phase 3) |
| Research 390 | Finding 1, proved sorry-free in probe | `valid_implies_validDedekind` | `valid φ → ValidDedekind φ` | pending (Phase 3), body known |

**Critical source finding (new, not in the research report):** Reynolds' US/R system includes
"axioms for density and no end points: `K⁺⊤`, `K⁻⊤`, `F⊤`, `P⊤`" (printed p.168). Unfolding
`K⁺⊤ = ¬U(⊤,¬⊤) = ¬U(⊤,⊥)` gives **exactly the tree's existing `dense_indicator`**
(`Axioms.lean:354`, `(Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).neg`). This is the
primary-source justification for placing `.Dedekind` **above** `.Dense` in the frame-class order:
Reynolds' Dedekind/real axiom set genuinely contains the tree's density axiom.

---

## Postmortem Constraints

Binding rules for all implementation dispatches on this task. No prior attempts exist; these are
derived from the research report's warnings, from primary-source reads performed during planning,
and from tree facts verified during planning.

**Do NOT**:

- **Do NOT reuse, rename, generalize, or "unify" `prior_UZ` / `prior_SZ`** (`Axioms.lean:315`,
  `:320`) with the new `prior_U_gap` / `prior_S_gap`. They are different axioms with confusingly
  similar names: the existing pair is the **integer well-ordering** form `F(φ) → U(φ,¬φ)` at
  `.Discrete`; the new pair is Reynolds' **definable-gap** form at `.Dedekind`. Add fresh
  constructors and leave the old ones byte-identical.
- **Do NOT reuse `kplusFormula` / `kminusFormula`** (`FormalSystem/Metalogic/WeakCanonical/Kamp/PriorINF.lean:93`).
  A second name-collision trap, not flagged in the research report: the tree's `kplusFormula P`
  is `P.neg ∧ ¬(⊤ U P.neg)` — it carries an extra `¬P` conjunct ("P holds arbitrarily soon after
  t, *but not at t itself*"). Reynolds' and GHR's `K⁺A = ¬U(⊤,¬A)` has **no such conjunct**.
  Using the tree's version would silently transcribe the wrong axioms. It is also in `Metalogic/`,
  downstream of `ProofSystem/`, so it is unimportable from `Axioms.lean` anyway. Define fresh
  `Formula.kPlus` / `Formula.kMinus` in `Syntax/Formula.lean`.
- **Do NOT add `DenselyOrdered` to `ValidDedekind`** — `ℤ` carries a Mathlib
  `ConditionallyCompleteLinearOrder` instance (`Mathlib/Data/Int/ConditionallyCompleteOrder.lean:29`,
  verified in research), so including density silently narrows the frame class to `ℝ` alone.
  Land the density-carrying variant under the **separate** name `ValidDedekindDense` and say so
  in both docstrings.
- **Do NOT target `soundness_dedekind` at `ValidDedekind`** — see the SETTLED decision below.
  This is the single most consequential correctness trap in the task.
- **Do NOT mistake the marker classes in `FrameConditions/FrameClass.lean` for the load-bearing
  layer.** They are a side-car. The live completeness and soundness theorems consume the raw
  instance-binder validity predicates in `Semantics/Validity.lean`. `DedekindTemporalFrame` is
  cosmetic parity work; if it costs more than its phase budget, mark it `[BLOCKED]` and move on
  rather than growing it.
- **Do NOT attempt `completeness_dedekind` or any part of it.** Out of scope. `Completeness.lean:173-193`
  documents that general `completeness` already carries `sorryAx` because a Base-MCS is not
  automatically Discrete-consistent; a Dedekind variant hits the structurally identical problem
  (a Base-MCS need not validate Prior-U / Prior-S / Sep) and its countermodel must be built from
  an MCS of its own class. That is separate work.
- **Do NOT use `mcp__lean-lsp__lean_run_code` for existence checks.** The research established
  it is unreliable in this environment (returned `success: true, diagnostics: []` for a
  deliberately bogus identifier). Use `lake env lean` on a probe file, with a bogus-identifier
  control, or `lake build`.
- **Do NOT write `def X := True` / `:= trivial` / `:= Unit` placeholders** (`.claude/rules/lean4.md`).
  The only permitted debt in this plan is the three Phase 8 strategic sorries listed in the
  Planned Strategic Sorries table.
- **Do NOT re-derive the phase decomposition** (`.claude/rules/plan-compliance.md`). A step that
  cannot be executed as written is escalated as `[BLOCKED]`, not silently substituted.

**MUST preserve**:

- Every asset in the Preserved Assets table above, unchanged in behaviour.
- The `ax.minFrameClass ≤ fc` invariant enforced at `Derivation.lean:98`. `Axiom.minFrameClass`
  remains the single source of truth for axiom/frame-class compatibility — do not introduce a
  parallel predicate.
- The existing `FrameClass` order relations exactly as they are: `Base ≤ everything`,
  `Dense`/`Discrete` reflexive, `Dense` and `Discrete` mutually incomparable. The only NEW
  relations are `Dedekind ≤ Dedekind` and `Dense ≤ Dedekind`. `Discrete` and `Dedekind` remain
  incomparable, and `Dedekind ≰ Dense`.
- Sorry count. Baseline is captured in Phase 1 and every phase except Phase 8 must show delta 0.
- `bash scripts/typst-sync-check.sh` green (it mechanically recounts `inductive Axiom`
  constructors from live source and cross-checks the committed machine appendix).

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):

1. **`.Dedekind` sits strictly above `.Dense`; `Discrete` and `Dedekind` stay incomparable.**
   Justification is primary-source, not intuition: Reynolds' US/R (printed p.168) explicitly
   includes "axioms for density and no end points", and `K⁺⊤` unfolds to the tree's
   `dense_indicator`. Rejected alternative — `.Dedekind` as a fourth incomparable leaf — would
   make `density`/`dense_indicator` inadmissible in `DerivationTree .Dedekind` and so could not
   host Reynolds' system.

2. **`soundness_dedekind` targets `ValidDedekindDense`, NOT `ValidDedekind`.** This resolves a
   latent inconsistency between two directives in the task description ("Dedekind ABOVE Dense"
   + "OMIT `DenselyOrdered`"), which taken together would produce an **unsound** theorem.
   Concretely: decision 1 makes `density : GGφ → Gφ` and `dense_indicator : ¬U(⊤,⊥)` admissible
   in `DerivationTree .Dedekind`; both are **false on `ℤ`** (for `density`, take `φ` true exactly
   at `≥ t+2`: `GGφ` holds, `Gφ` fails; for `dense_indicator`, `U(⊤,⊥)` holds on `ℤ` by immediate
   successor); and `ℤ` is Dedekind-complete. So a `soundness_dedekind : DerivationTree .Dedekind … → ValidDedekind`
   is refutable. `ValidDedekind` is still landed (Phase 3), faithful to its name and to the
   research recommendation, as the strictly weaker predicate and as the target of the forgetful
   bridge; it is simply not what soundness proves against. **Both docstrings must state this.**

3. **`Formula.kPlus` / `Formula.kMinus` are new declarations in `Syntax/Formula.lean`**, beside
   `allFuture` (`:151`), not reuses of `Metalogic`'s `kplusFormula`. See the Do-NOT above.

4. **Constructor names are `prior_U_gap`, `prior_S_gap`, `sep`** (research Finding 4, task
   description). Fixed; do not "improve" them.

5. **Phase 8 is a skeleton phase.** Three strategic sorries are pre-declared and budgeted. They
   are not failures and must not trigger an escalation loop. Everything else in Phase 8 —
   `axiom_dedekind_valid`, `soundness_dedekind_valid`, `soundness_dedekind`, and all 42 existing
   axiom cases — is sorry-free.

---

## Goals & Non-Goals

**Goals**:
- `FrameClass.Dedekind` with a genuine `Base < Dense < Dedekind` chain and green `LE` /
  `DecidableRel` / `PartialOrder` instances.
- Reynolds' Prior-U, Prior-S, Sep as `Axiom` constructors mapped to `.Dedekind` in
  `Axiom.minFrameClass`, with `Formula.kPlus`/`kMinus` defined faithfully.
- Full tree, automation coverage lists, and machine appendix restored to green.
- `ValidDedekind`, `ValidDedekindDense`, and their bridges from `valid`.
- `DedekindTemporalFrame` marker class for parity with the existing side-car.
- `soundness_dedekind` existing and typechecking, with debt confined to three named,
  documented, tracked lemmas.

**Non-Goals**:
- `completeness_dedekind` and every prerequisite of it (`ℚ`-flowed Prior/Sep model, Reynolds
  Theorems 4/5 = D1/D2, Doets real-flow transfer). Research report phases 6-9.
- Constructing any Dedekind-complete carrier. Settled: `ℝ` is taken off the shelf and the live
  parametric scaffolding instantiates at it unmodified.
- Proving the semantic validity of the three new axioms (deferred to `405` and
  `406`).
- Any change to `prior_UZ` / `prior_SZ` / `z1` / the `.Discrete` class.
- Strong completeness anywhere — Reynolds Theorem 7 delivers only WEAK completeness over real
  flow, and compactness provably fails for `{U,S}` over `ℝ` (printed p.168, "there can be no
  strongly complete axiomatization").

---

## File Scope Resolution

The task's declared `file_scope` in `state.json` lists five files. Planning verification found it
**materially incomplete**. Resolved explicitly:

| File | Declared? | Verdict |
|---|---|---|
| `FormalSystem/ProofSystem/Axioms.lean` | yes | REQUIRED — Phases 1 and 5 both. See territory note below. |
| `FormalSystem/ProofSystem/Derivation.lean` | yes | **Expected NO-OP.** The `:98` gate `(h_fc : h.minFrameClass ≤ fc)` is generic in `fc`. Verified; no edit anticipated. Kept in scope only as a tripwire. |
| `FormalSystem/Semantics/Validity.lean` | yes | REQUIRED — Phase 3. |
| `FormalSystem/Metalogic/Soundness.lean` | yes | REQUIRED — Phases 2, 6, 8. |
| `FormalSystem/FrameConditions/FrameClass.lean` | yes | REQUIRED — Phase 4. |
| `FormalSystem/Automation/AxiomNames.lean` | **NO** (named in SCOPE item 2 only) | REQUIRED — Phase 7. `allAxiomNames` is a hand-maintained 42-name list whose own docstring mandates same-change updates. |
| `FormalSystem/Syntax/Formula.lean` | **NO** | REQUIRED — Phase 5. Host for `Formula.kPlus`/`kMinus`; `Axioms.lean:7` imports it, and `top`/`neg`/`and`/`or`/`someFuture`/`somePast` all live there (`:118`-`:406`). |
| `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` | **NO** | REQUIRED — Phases 2, 6. One of only four files containing `LE.le]` order reasoning. |
| `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean` | **NO** | REQUIRED — Phases 2, 6. Same. |
| `FormalSystem/Automation/MachineAppendixExport.lean` | **NO** | REQUIRED — Phase 7. `allAxiomEntries` (`:184`) applies every real constructor; `:427-434` asserts exact-42 agreement. |
| `FormalSystem/Automation/BenchmarkAnchors.lean` | **NO** | REQUIRED — Phase 7. Coverage assertion at `:310`, iteration at `:541`. |
| `FormalSystem/Automation/ProofStepExport.lean` | **NO** | REQUIRED — Phase 7. Carries a **second, independent, duplicated** `allAxiomNames` at `:1520` that does not import the canonical one. Easily missed. |
| `FormalSystem/Metalogic/Decidability/{Tableau,Saturation}.lean`, `FormalSystem/Automation/{Tactics/Helpers,Tactics/Commands,ProofSearch/Core,FormulaEnumerator,InterestingnessMetrics,DatasetGenerator,ForwardProofGenerator,ProofStepExtractor}.lean` | **NO** | CONDITIONALLY REQUIRED — Phases 6/7. Each references `dense_indicator`; whether it breaks depends on whether its match is exhaustive. Enumerate from the build log, do not pre-edit. |
| `typst/generated/machine-appendix.{jsonl,typ}` | **NO** | REQUIRED (regenerated, not hand-edited) — Phase 7, via `bash scripts/typst-machine-appendix.sh`. `scripts/typst-sync-check.sh` Check 3 recounts constructors from live source and will fail otherwise. |

**Action for the implementer**: `file_scope` in `state.json` is descriptive and is not mutated by
status-sync. Do not attempt to "fix" it mid-implementation; this table is the operative scope.

**Territory (H7) note on `Axioms.lean`**: SCOPE items 1 and 2 both touch it, so Phases 1 and 5
share the file. They are placed in **different waves** (1 and 4) precisely so no two concurrent
agents ever own it. Within `Axioms.lean` they touch disjoint regions: Phase 1 owns `:358-422`
(the `FrameClass` inductive, instances, docstring, `base_le`); Phase 5 owns `:84-356` (the
`Axiom` inductive tail) and `:412-418` (`minFrameClass` rows).

---

## Risks & Mitigations

- **Risk**: `simp [LE.le]` / `simp_all [LE.le]` closes break once the `LE` match gains a
  non-reflexive `Dense ≤ Dedekind` arm. There are 42 such sites across exactly four files
  (`Soundness.lean`, `FrameClassVariants.lean`, `DenseValidity.lean`, `Axioms.lean`).
  **Mitigation**: `FrameClass` derives `DecidableEq` and the `DecidableRel` instance is landed in
  Phase 1, so `by decide` is a total fallback for every closed order goal. Phase 2 is a dedicated
  phase for exactly this repair, sized against the enumerated 42 sites.

- **Risk**: `le_trans` goes from a 27-case to a 64-case `cases a <;> cases b <;> cases c` split
  and `simp_all [LE.le]` times out or leaves goals. **Mitigation**: fall back to
  `decide`-per-case (`cases a <;> cases b <;> cases c <;> first | trivial | simp_all [LE.le] | decide`),
  or restate `le` via an explicit `rank : FrameClass → ℕ`-free but fully-enumerated helper. Both
  are bounded; the module either builds or it does not.

- **Risk**: Adding 3 `Axiom` constructors breaks five exhaustive `cases h_ax with` sites
  (`Soundness.lean:839, 889, 947, 1061, 1229`) plus an unknown number in
  `Decidability/` and `Automation/`. **Mitigation**: Phase 6 and Phase 7 split the repair by
  territory (Metalogic vs Automation) and both work from an enumerated `lake build` failure list,
  giving each a concrete stopping condition.

- **Risk**: A silent semantic regression in `Automation/` — a file that lists axioms
  non-exhaustively (so it compiles) but now under-covers. **Mitigation**: `bash scripts/typst-sync-check.sh`
  Check 3A mechanically recounts constructors from live source; `lake exe machine_appendix` and
  `lake exe benchmark_anchors` both carry coverage assertions. Phase 7 runs all three.

- **Risk**: `Formula.or` / `Formula.and` / `Formula.top` unfold surprisingly in the new axiom
  statements (`and` is `(φ.imp ψ.neg).neg`, `or` is `φ.neg.imp ψ`). **Mitigation**: Phase 5 has
  no proof obligation — the constructors only need to *elaborate*. Verify each with
  `#check` in a `lake env lean` probe before editing `Axioms.lean`.

- **Risk (accepted, mitigated by design)**: `sep`'s semantic validity over `ℝ` is deferred even in
  the primary source (Reynolds, printed p.168: "defer proving its validity in `ℝ` until lemma 10"
  in §7). Proving it is research-grade with no fixed attempt budget. **Mitigation**: it is a
  pre-declared strategic sorry (Phase 8, `406`), not a phase.

- **Risk**: `--hard` implementation dispatches read the whole tree instead of writing. **Mitigation**:
  the anti-analysis contract's 30%-of-tool-calls first-sorry-free-lemma bar applies; Phase 1 is
  deliberately first and is mechanical, so a green scoped build lands early.

---

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 2 |
| 5 | 6, 7 | 5 |
| 6 | 8 | 3, 6, 7 |

Phases within the same wave can execute in parallel.

**Territory contract (H7) — file ownership per parallel wave**:

| Wave | Phase | Owns (exclusive write) |
|---|---|---|
| 3 | 3 | `FormalSystem/Semantics/Validity.lean` |
| 3 | 4 | `FormalSystem/FrameConditions/FrameClass.lean` |
| 5 | 6 | `FormalSystem/Metalogic/**` (Soundness, SoundnessLemmas, Decidability) |
| 5 | 7 | `FormalSystem/Automation/**`, `typst/generated/**` |

Wave 3's two phases and wave 5's two phases have strictly disjoint file sets. **Wave 4 (Phase 5)
is deliberately alone**: it leaves the tree red until wave 5 completes, so nothing may build
concurrently with it. Waves 1, 2, 6 are single-phase.

**Sorry inventory expectation** (H9). Capture the baseline in Phase 1 with:

```
lake build 2>&1 | grep -c "declaration uses 'sorry'"
```

Record the number as `SORRY_BASELINE`. Every phase 1-7 must exit with the same count. Phase 8
exits at `SORRY_BASELINE + 3`, and the three new warnings must point at exactly
`prior_U_gap_valid`, `prior_S_gap_valid`, `sep_valid`.

---

### Phase 1: FrameClass.Dedekind constructor and order instance rework [COMPLETED]

- **Goal:** `FrameClass` has a fourth constructor `.Dedekind` with a genuine `Base < Dense <
  Dedekind` chain, and the `LE` / `DecidableRel` / `PartialOrder` instances plus `base_le` all
  build.
- **Owns:** `FormalSystem/ProofSystem/Axioms.lean`, region `:358-422` only.
- **Tasks:**
  - [x] Capture `SORRY_BASELINE` via the command above; record it in the phase completion note.
        *(deviation: altered — the plan's grep pattern `"declaration uses 'sorry'"` uses straight
        quotes, but Lean 4.33 emits backticks: ``declaration uses `sorry` ``. With the corrected
        pattern, **SORRY_BASELINE = 1**, the pre-existing live sorry at
        `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1225` (`countermodel_discrete`).
        The plan's literal command reports 0 and would have masked a regression.)*
  - [x] Add `| Dedekind` to `inductive FrameClass` (`:378-382`), keeping the
        `deriving Repr, DecidableEq, Inhabited, BEq, Hashable` clause.
  - [x] Rewrite the `LE` instance (`:384-389`) to:
        ```lean
        instance : LE FrameClass where
          le a b := match a, b with
            | .Base, _ => True
            | .Dense, .Dense => True
            | .Dense, .Dedekind => True
            | .Dedekind, .Dedekind => True
            | .Discrete, .Discrete => True
            | _, _ => False
        ```
  - [x] Repair `DecidableRel` (`:391`, 9 → 16 cases) and `PartialOrder` (`:394`: `le_refl` 4
        cases, `le_trans` 27 → 64, `le_antisymm` 9 → 16). Try the existing tactic first; on
        failure escalate within the phase to
        `<;> first | trivial | simp_all [LE.le] | decide`.
  - [x] Verify `FrameClass.base_le` (`:421-422`, `cases fc <;> trivial`) still closes.
  - [x] Update the frame-class docstring diagram (`:358-377`) to show
        `Base < Dense < Dedekind` with `Discrete` incomparable, and cite Reynolds 1992 printed
        p.168 ("axioms for density and no end points": `K⁺⊤` = the tree's `dense_indicator`) as
        the reason `Dedekind` is above `Dense`.
  - [x] Confirm the three preserved order facts by `#guard`/`example`: `¬(Dedekind ≤ Dense)`,
        `¬(Discrete ≤ Dedekind)`, `¬(Dedekind ≤ Discrete)`.
- **Verification (green criterion):** `lake build FormalSystem.ProofSystem.Axioms` exits 0.
  Then run full `lake build`, expect failures, and **write the enumerated failure list to the
  phase completion note** — it is Phase 2's input.
- **Estimated output:** ~90-130 lines (instance bodies plus docstring).
- **Bounded-unit check:** one file, one inductive, three instances. Stopping condition = the
  scoped module build exits 0. Fixed attempt surface: `decide` is a total fallback because
  `FrameClass` is finite with `DecidableEq`.
- **Timing:** ~2 hours.
- **Depends on:** none

### Phase 2: FrameClass order-rework downstream repair to full green [COMPLETED]

- **Goal:** `lake build` fully green after the order rework; no behaviour change to any existing
  theorem.
- **Owns:** `FormalSystem/Metalogic/Soundness.lean`,
  `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean`,
  `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean`, plus any file the Phase 1 failure
  list names.
- **Tasks:**
  - [x] Work the Phase 1 failure list top-down. The expected population is the 42 `LE.le]`
        reasoning sites across the four files identified in planning (`Soundness.lean`,
        `FrameClassVariants.lean`, `DenseValidity.lean`, `Axioms.lean`).
  - [x] The dominant pattern to repair is the incomparable-case elimination
        `exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])`
        (`Soundness.lean:1270-1272` and siblings). Prefer `by decide` where `simp` no longer
        closes; do not restructure the surrounding proof.
  - [x] Add any newly-required `| Dedekind => …` arms to `match fc` sites. At this point no axiom
        maps to `.Dedekind`, so such arms are vacuous/absurd-eliminable.
  - [x] Do NOT touch `Axiom.minFrameClass` rows — that is Phase 5.
- **Verification (green criterion):** `lake build` exits 0; sorry count equals `SORRY_BASELINE`;
  `git diff --stat` shows no file outside this phase's owned set.
- **Estimated output:** ~120-260 lines of edits.
- **Bounded-unit check:** the work item set is fully enumerated by the Phase 1 build log before
  the phase starts. Stopping condition = full build exits 0.
- **Timing:** ~3 hours.
- **Depends on:** 1

**Phase 1-2 completion note.** The Phase 1 full-build failure list was **2 errors, not the 42
`LE.le]` sites the plan anticipated** — both `Missing cases: FrameClass.Dedekind` in exhaustive
`match fc` sites, and both in `Automation/` rather than `Metalogic/`:

| Site | Repair |
|---|---|
| `FormalSystem/Automation/FormulaEnumerator.lean:1428` (`pickSchemaIdx`) | added `| .Dedekind => (List.range 37) ++ [40, 41]` (Base + Dense schemas, since `Dense ≤ Dedekind`) |
| `FormalSystem/Automation/ProofStepExtractor.lean:200` (`frameClassToString`) | added `| .Dedekind => "Dedekind"` |

**Zero** `simp [LE.le]` / `simp_all [LE.le]` sites in `Soundness.lean`,
`FrameClassVariants.lean`, or `DenseValidity.lean` broke. The plan's central Phase 2 risk did
not materialise: those closes are all discharging goals about `Base`/`Dense`/`Discrete` only,
and adding a constructor plus one new `LE` arm left every one of them provable by the same
tactic. The `PartialOrder` rework itself needed only `trivial` for the 64-case `le_trans`
(`simp_all`/`decide` fallbacks were flagged unreachable by the linter and removed) and
`first | rfl | simp_all [LE.le]` for the 16-case `le_antisymm`.

- **Commit here** (`task 391 phase 2: FrameClass.Dedekind constructor and order rework`) — first
  full-green milestone.

### Phase 3: ValidDedekind, ValidDedekindDense, and validity bridges [NOT STARTED]

- **Goal:** Two new semantic predicates and two forgetful bridges from `valid`, all sorry-free.
- **Owns:** `FormalSystem/Semantics/Validity.lean` (exclusive).
- **Tasks:**
  - [ ] Add `ValidDedekind` after `ValidDiscrete` (`:187-193`), using research Variant B
        verbatim (compile-verified in the research probe):
        ```lean
        def ValidDedekind (φ : Formula) : Prop :=
          ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
            (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
            (F : TaskFrame D) (M : TaskModel F)
            (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
            (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
            TruthAt M Omega τ t φ
        ```
        `DenselyOrdered` is deliberately absent — see SETTLED decision 2.
  - [ ] Add `ValidDedekindDense`: identical, plus `[DenselyOrdered D]`.
  - [ ] Docstring `ValidDedekind` with the Reynolds "definably Dedekind complete" transcription
        (printed p.169) and an explicit note that `ℤ` satisfies these binders, that `density`
        and `dense_indicator` are FALSE on `ℤ`, and that therefore `soundness_dedekind` targets
        `ValidDedekindDense`, not this predicate.
  - [ ] Docstring `ValidDedekindDense` as the real-flow predicate and the soundness target.
  - [ ] Add both bridges in `namespace Validity` beside `valid_implies_valid_dense` (`:200`) and
        `valid_implies_valid_discrete` (`:207`). The first body was proved sorry-free in the
        research probe:
        ```lean
        theorem valid_implies_validDedekind {φ : Formula} (h : valid φ) : ValidDedekind φ :=
          fun D _ _ _ _ _ F M Omega hO τ hτ t => h D F M Omega hO τ hτ t
        ```
        Add `valid_implies_validDedekindDense` with one extra `_` binder.
  - [ ] Optionally add `validDedekindDense_of_validDedekind` (forgetting `DenselyOrdered` is a
        weakening in the wrong direction — check the binder order before asserting it; if it does
        not typecheck in one attempt, omit it rather than fighting it).
- **Verification (green criterion):** `lake build FormalSystem.Semantics.Validity` exits 0, then
  full `lake build` exits 0; sorry count `= SORRY_BASELINE`.
- **Estimated output:** ~80-110 lines.
- **Bounded-unit check:** four declarations, two of which have research-verified bodies. Stopping
  condition = module build exits 0.
- **Timing:** ~1 hour.
- **Depends on:** 2

### Phase 4: DedekindTemporalFrame marker class [NOT STARTED]

- **Goal:** Side-car parity: a `DedekindTemporalFrame` marker class alongside the existing four.
- **Owns:** `FormalSystem/FrameConditions/FrameClass.lean` (exclusive).
- **Tasks:**
  - [ ] Add `class DedekindTemporalFrame (D : Type) [AddCommGroup D] [LinearOrder D]
        [IsOrderedAddMonoid D] : Prop` following the shape of `DiscreteTemporalFrame` (`:148`)
        and `DenseTemporalFrame` (`:124`), carrying the conditional-completeness field
        `lub_exists : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x`.
  - [ ] Add the derivation `instance` in the style of `:129`/`:154` (from a
        `ConditionallyCompleteLinearOrder D` instance where one is in scope).
  - [ ] Add a `DedekindTemporalFrame.mk'` convenience theorem mirroring `DenseTemporalFrame.mk'`
        (`:215`) and `DiscreteTemporalFrame.mk'` (`:223`).
  - [ ] Docstring MUST open with the side-car warning: this class is NOT consumed by
        `Soundness.lean` or `Completeness.lean`; those consume the instance-binder predicates in
        `Semantics/Validity.lean`.
  - [ ] Do NOT add an `instance : DedekindTemporalFrame Int` next to `:203` unless it builds in a
        single attempt — `ConditionallyCompleteLinearOrder ℤ` is noncomputable.
- **Verification (green criterion):** `lake build FormalSystem.FrameConditions.FrameClass` exits
  0, then full `lake build` exits 0; sorry count `= SORRY_BASELINE`.
- **Estimated output:** ~50-80 lines.
- **Bounded-unit check:** one class, one instance, one lemma, all patterned on live siblings.
  Explicit stopping condition: if the derivation instance does not land within the phase budget,
  ship the bare class + `mk'` and mark the instance `[BLOCKED]` — this phase is explicitly
  optional per SCOPE item 4 and must not expand.
- **Timing:** ~1 hour.
- **Depends on:** 2
- **Commit after wave 3** (`task 391 phase 3-4: ValidDedekind predicates and Dedekind marker class`).

### Phase 5: Formula.kPlus/kMinus and the three Reynolds axiom constructors [NOT STARTED]

- **Goal:** `Formula.kPlus`/`Formula.kMinus` land faithfully; `Axiom.prior_U_gap`,
  `Axiom.prior_S_gap`, `Axiom.sep` exist and map to `.Dedekind` in `Axiom.minFrameClass`.
- **Owns:** `FormalSystem/Syntax/Formula.lean`, `FormalSystem/ProofSystem/Axioms.lean`
  (regions `:84-356` and `:412-418`). **Runs alone in its wave** — it leaves the tree red.
- **Tasks:**
  - [ ] In `Syntax/Formula.lean`, beside `allFuture` (`:151`), add:
        ```lean
        /-- `K⁺A = ¬U(⊤, ¬A)` — "A will be true arbitrarily soon" (Reynolds 1992, printed p.168;
            GHR 1994 §10.3.1). NOT the same as `Metalogic`'s `kplusFormula`, which carries an
            extra `¬A` conjunct. -/
        def kPlus (φ : Formula) : Formula := (Formula.untl Formula.top φ.neg).neg

        /-- `K⁻A = ¬S(⊤, ¬A)` — past dual. Same caveat as `kPlus`. -/
        def kMinus (φ : Formula) : Formula := (Formula.snce Formula.top φ.neg).neg
        ```
        Both docstrings MUST carry the `kplusFormula` collision warning.
  - [ ] Probe-elaborate the three axiom bodies in a scratch file under `lake env lean` (with a
        bogus-identifier control) BEFORE editing `Axioms.lean`. `Formula.and` is
        `(φ.imp ψ.neg).neg` (`:401`) and `Formula.or` is `φ.neg.imp ψ` (`:406`) — confirm both
        unfold as expected.
  - [ ] Add a new "Layer 9: Reynolds Dedekind Axioms (3)" block at the end of `inductive Axiom`
        (immediately before `deriving Repr`, `:356`), following the existing per-constructor
        docstring style:
        ```lean
        | prior_U_gap (φ : Formula) :
            Axiom ((Formula.and (Formula.untl Formula.top φ) φ.neg.someFuture).imp
              (Formula.untl (Formula.or φ.neg (Formula.kPlus φ.neg)) φ))
        | prior_S_gap (φ : Formula) :
            Axiom ((Formula.and (Formula.snce Formula.top φ) φ.neg.somePast).imp
              (Formula.snce (Formula.or φ.neg (Formula.kMinus φ.neg)) φ))
        | sep (φ : Formula) :
            Axiom ((Formula.and (Formula.kPlus φ)
              (Formula.kPlus (Formula.and φ (Formula.untl φ φ.neg))).neg).imp
              (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ))))
        ```
        Each docstring MUST cite "Reynolds 1992, printed p.168" and MUST state that this is NOT
        `prior_UZ`/`prior_SZ` (`:315`, `:320`), which are the integer well-ordering axioms.
  - [ ] Add three rows to `Axiom.minFrameClass` (`:412`), before the `| _ => .Base` catch-all:
        `| prior_U_gap _ => .Dedekind`, `| prior_S_gap _ => .Dedekind`, `| sep _ => .Dedekind`.
  - [ ] Update the `minFrameClass` docstring counts (`:400-411`): Base 37, Dense 2, Discrete 3,
        Dedekind 3; total 45.
- **Verification (green criterion):** `lake build FormalSystem.Syntax.Formula` and
  `lake build FormalSystem.ProofSystem.Axioms` both exit 0. Then run full `lake build`, expect
  failures, and **write the enumerated failure list, partitioned into `Metalogic/` vs
  `Automation/`, to the phase completion note** — it is the input to Phases 6 and 7.
- **Estimated output:** ~110-150 lines.
- **Bounded-unit check:** five declarations with source-verbatim statements and zero proof
  obligations. Stopping condition = the two scoped module builds exit 0.
- **Timing:** ~2 hours.
- **Depends on:** 2

### Phase 6: Axiom-constructor downstream repair — Metalogic territory [NOT STARTED]

- **Goal:** Every exhaustive `cases h_ax with` / `match` over `Axiom` in `Metalogic/` covers the
  three new constructors.
- **Owns:** `FormalSystem/Metalogic/**` (exclusive) — expected: `Soundness.lean`,
  `SoundnessLemmas/FrameClassVariants.lean`, `SoundnessLemmas/DenseValidity.lean`,
  `Decidability/Tableau.lean`, `Decidability/Saturation.lean`.
- **Tasks:**
  - [ ] Work the `Metalogic/` partition of the Phase 5 failure list. Known exhaustive sites:
        `Soundness.lean:839, 889, 947, 1061, 1229`.
  - [ ] In `axiom_valid` (Base), `axiom_dense_valid` (`:887`) and `axiom_discrete_valid`
        (`:944`), and in `soundness_dense`'s inline split (`:1229`), the three new cases are
        **eliminated by frame-class incomparability**, exactly like the existing
        `| prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])` at `:1270`.
        `Dedekind ≰ Base`, `Dedekind ≰ Dense`, `Dedekind ≰ Discrete` all hold by SETTLED decision
        1, so this is the correct and only disposition. Use `by decide` if `simp` does not close.
  - [ ] In `FrameClassVariants.lean:40` `axiom_swap_valid_general`, the three new cases are
        likewise eliminated (`h_fc : h.minFrameClass ≤ FrameClass.Base`).
  - [ ] For non-proof matches (`Decidability/`), add whatever arms the build demands; keep them
        behaviourally neutral and do not invent tableau rules for the new axioms.
  - [ ] Do NOT touch `Automation/` — that is Phase 7's territory.
- **Verification (green criterion):** `lake build FormalSystem.Metalogic` exits 0 (full
  `lake build` may still fail on `Automation/` until Phase 7 lands — that is expected and
  in-contract); sorry count `= SORRY_BASELINE`.
- **Estimated output:** ~100-200 lines of edits.
- **Bounded-unit check:** the work set is enumerated by the Phase 5 build log. Stopping condition
  = the `Metalogic` subtree builds.
- **Timing:** ~3 hours.
- **Depends on:** 5

### Phase 7: Axiom-constructor downstream repair — Automation and machine appendix [NOT STARTED]

- **Goal:** All four independent axiom-name/coverage lists updated to 45, and the committed
  machine appendix regenerated and consistent.
- **Owns:** `FormalSystem/Automation/**`, `typst/generated/**` (exclusive).
- **Tasks:**
  - [ ] `FormalSystem/Automation/AxiomNames.lean`: append `"prior_U_gap", "prior_S_gap", "sep"`
        to `allAxiomNames` (`:33`) in `Axioms.lean` source order; update the module docstring and
        the `/-- All 42 axiom constructor names -/` comment to 45.
  - [ ] `FormalSystem/Automation/ProofStepExport.lean:1520`: this is a **second, duplicated**
        `allAxiomNames` that does not import the canonical one. Update it too, and add a comment
        cross-referencing `Automation/AxiomNames.lean` so the duplication is at least visible.
  - [ ] `FormalSystem/Automation/MachineAppendixExport.lean`: add a `layerReynoldsDedekind`
        layer name and three `mkAxiomEntry` rows to `allAxiomEntries` (`:184`), applying the real
        constructors (never transcribing the schema formula); update the "42" assertions and
        docstrings at `:39`, `:72`, `:181`, `:427-434`.
  - [ ] `FormalSystem/Automation/BenchmarkAnchors.lean`: update the coverage filter (`:310`),
        the iteration at `:541`, and the `:302` note.
  - [ ] Work the `Automation/` partition of the Phase 5 failure list for any remaining
        `dense_indicator`-adjacent enumeration in `Tactics/Helpers.lean`, `Tactics/Commands.lean`,
        `ProofSearch/Core.lean`, `FormulaEnumerator.lean`, `InterestingnessMetrics.lean`,
        `DatasetGenerator.lean`, `ForwardProofGenerator.lean`, `ProofStepExtractor.lean`.
  - [ ] Regenerate the appendix: `bash scripts/typst-machine-appendix.sh`. Do NOT hand-edit
        `typst/generated/machine-appendix.jsonl` or `.typ` — Check 3B proves the `.typ` is
        derived by re-rendering byte-for-byte.
- **Verification (green criterion):** full `lake build` exits 0;
  `lake exe machine_appendix` and `lake exe benchmark_anchors` both pass their coverage
  assertions; `bash scripts/typst-sync-check.sh` exits 0 (Check 3A independently recounts
  `inductive Axiom` constructors from live source and must report 45); sorry count
  `= SORRY_BASELINE`.
- **Estimated output:** ~120-220 lines of edits plus regenerated artifacts.
- **Bounded-unit check:** four named list sites plus a script-driven regeneration. Stopping
  condition = `typst-sync-check.sh` exits 0.
- **Timing:** ~2 hours.
- **Depends on:** 5
- **Commit after wave 5** (`task 391 phase 5-7: Reynolds Dedekind axiom constructors`) — full-green
  milestone with sorry count still at baseline.

### Phase 8: soundness_dedekind skeleton with three strategic sorries [NOT STARTED]

- **Goal:** `soundness_dedekind` exists and typechecks. All plumbing and all 42 pre-existing
  axiom cases are sorry-free; debt is confined to exactly three named, documented, tracked
  lemmas.
- **Owns:** `FormalSystem/Metalogic/Soundness.lean` (exclusive).
- **Tasks:**
  - [ ] Add three top-level validity lemmas beside the existing per-axiom `*_valid` family, each
        stated over the `ValidDedekindDense` binder set (`[AddCommGroup D] [LinearOrder D]
        [IsOrderedAddMonoid D] [DenselyOrdered D] [Nontrivial D]` plus the LUB hypothesis), each
        with a **strategic sorry** body carrying the mandated three-part comment
        (`-- sorry: assumes X; deferred because Y; follow-up: task NNN`):
        - `prior_U_gap_valid`
        - `prior_S_gap_valid`
        - `sep_valid`
  - [ ] Add `axiom_dedekind_valid {φ : Formula} (h : Axiom φ) (h_fc : h.minFrameClass ≤
        FrameClass.Dedekind)`, patterned on `axiom_discrete_valid` (`:944`). The 37 Base cases
        and the 2 Dense cases (`density`, `dense_indicator` — admissible here by SETTLED decision
        1, and valid because the binder set carries `DenselyOrdered`) route to existing
        `*_valid` lemmas. The 3 Discrete cases (`prior_UZ`, `prior_SZ`, `z1`) are eliminated by
        `absurd h_fc`. The 3 new cases route to the three lemmas above. **All of this is
        sorry-free**; the sorries live only in the three lemma bodies.
  - [ ] Add `soundness_dedekind_valid {phi : Formula} (d : DerivationTree FrameClass.Dedekind []
        phi) : ValidDedekindDense phi`, patterned on `soundness_discrete_valid` (`:1309`).
  - [ ] Add `soundness_dedekind (Γ : Context) (φ : Formula) (d : DerivationTree
        FrameClass.Dedekind Γ φ) …`, patterned on `soundness_discrete` (`:1361`) — a single
        `exact axiom_dedekind_valid h_ax h_fc D F M Omega h_sc τ h_mem t` in the `axiom` case
        (the `soundness_discrete` shape), NOT `soundness_dense`'s 42-case inline split.
  - [ ] For the `temporal_duality` case, reuse `axiom_swap_valid_general`
        (`FrameClassVariants.lean:40`) — it is frame-class-free and directly applicable, exactly
        as the task description states.
  - [ ] The theorem docstring MUST state that the target is `ValidDedekindDense` and MUST give
        the `ℤ`-counterexample reason (SETTLED decision 2) so no future reader "fixes" it to
        `ValidDedekind`.
- **Verification (green criterion):** full `lake build` exits 0;
  `lake build 2>&1 | grep -c "declaration uses 'sorry'"` equals `SORRY_BASELINE + 3`; the three
  new warnings name exactly `prior_U_gap_valid`, `prior_S_gap_valid`, `sep_valid`; and
  `#print axioms FormalSystem.Metalogic.soundness_dedekind` lists `sorryAx` (confirming the
  sorries are real and located where documented). `bash scripts/typst-sync-check.sh` exits 0.
- **Estimated output:** ~180-260 lines.
- **Bounded-unit check:** PASSES only because the three unbounded proof obligations are converted
  to pre-declared division points. Without that conversion this phase would fail the test (Sep's
  validity is deferred even in the primary source). The remaining work — one dispatcher, two
  wrapper theorems, 45 enumerated cases — has a fixed attempt surface.
- **Timing:** ~3 hours.
- **Depends on:** 3, 6, 7
- **Commit** (`task 391 phase 8: soundness_dedekind skeleton`), then
  `task 391: complete implementation`.

---

## Planned Strategic Sorries

| Division Point | File / Line / Statement | Assumption | Why Deferred | Follow-Up Task |
|---|---|---|---|---|
| Prior-U gap-axiom validity | `FormalSystem/Metalogic/Soundness.lean` / TBD / `prior_U_gap_valid : ∀ φ, IsValid D (prior_U_gap φ).formula` over `ValidDedekindDense` binders | `U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p), p)` is semantically valid on every dense Dedekind-complete duration group | Reynolds asserts validity over `ℝ` without proof ("It is clear that all these axioms are valid over the reals", printed p.168). The actual argument is a supremum construction over the `p`-region and is open-ended in attempt count — it is a division point, not a bounded phase. | 405 |
| Prior-S gap-axiom validity | `FormalSystem/Metalogic/Soundness.lean` / TBD / `prior_S_gap_valid` over `ValidDedekindDense` binders | `S(⊤,p) ∧ P¬p → S(¬p ∨ K⁻(¬p), p)` is semantically valid on every dense Dedekind-complete duration group | Past dual of the above; same unbounded attempt surface. Grouped with Prior-U because the dual proof reuses the same infimum machinery. | 405 |
| Sep axiom validity | `FormalSystem/Metalogic/Soundness.lean` / TBD / `sep_valid` over `ValidDedekindDense` binders | `K⁺p ∧ ¬K⁺(p ∧ U(p,¬p)) → K⁺(K⁺p ∧ K⁻p)` is semantically valid on real flow | **The primary source itself defers it**: Reynolds, printed p.168, "we investigate this axiom in more detail in section 7 and defer proving its validity in `ℝ` until lemma 10 there." Genuinely research-grade; the argument turns on the separability of `ℝ` (countable dense suborder), and Reynolds notes Sep does not characterize separability (the long line also satisfies it). | 406 |

Any implementer-placed strategic sorry NOT on this table is a plan-unanticipated deviation and
MUST be flagged in the implementation summary, not silently accepted.

---

## Testing & Validation

- [ ] `lake build` exits 0 at the end of every phase except Phase 1 and Phase 5 (both of which
      exit on a scoped module build plus an enumerated failure list) and Phase 6 (which exits on
      `lake build FormalSystem.Metalogic`).
- [ ] Sorry count tracked at every phase boundary via
      `lake build 2>&1 | grep -c "declaration uses 'sorry'"`. Delta 0 for phases 1-7; delta +3 for
      phase 8, with the three warnings naming exactly the three planned lemmas.
- [ ] `bash scripts/typst-sync-check.sh` exits 0 after Phase 7 and again after Phase 8. Check 3A
      independently recounts `inductive Axiom` constructors from live source and must report 45.
- [ ] `lake exe machine_appendix` coverage assertion passes (45 names, no missing, no extra).
- [ ] `lake exe benchmark_anchors` coverage assertion passes.
- [ ] Order-shape regression, as `example`s in `Axioms.lean` (Phase 1): `Base ≤ Dedekind`,
      `Dense ≤ Dedekind`, `Dedekind ≤ Dedekind`, `¬(Dedekind ≤ Dense)`, `¬(Dedekind ≤ Discrete)`,
      `¬(Discrete ≤ Dedekind)`, `¬(Dense ≤ Discrete)`, `¬(Discrete ≤ Dense)`.
- [ ] `#print axioms FormalSystem.Metalogic.soundness_dedekind` shows `sorryAx` after Phase 8
      (confirming the strategic sorries are real), and
      `#print axioms FormalSystem.Validity.valid_implies_validDedekind` shows no `sorryAx`
      after Phase 3.
- [ ] No file outside the per-phase owned set appears in `git diff --stat` at any phase boundary
      (H7 territory check).
- [ ] `Tests/BimodalTest/` continues to build and pass.

---

## Artifacts & Outputs

- `specs/391_frameclass_dedekind_scaffolding/plans/01_frameclass-dedekind-scaffolding.md` (this file)
- `specs/391_frameclass_dedekind_scaffolding/.skeleton-return.json` (follow-up task declarations)
- `specs/391_frameclass_dedekind_scaffolding/summaries/01_frameclass-dedekind-scaffolding-summary.md` (on completion)
- Modified Lean sources per the File Scope Resolution table
- Regenerated `typst/generated/machine-appendix.{jsonl,typ}`

---

## Rollback/Contingency

- Every phase boundary is a green build, so `git revert` of the phase commit is sufficient and
  safe. Commit points: after Phase 2, after wave 3 (Phases 3-4), after wave 5 (Phases 5-7), after
  Phase 8.
- **The single high-consequence rollback** is Phase 1's `LE` restructure: everything downstream
  depends on it. If Phase 2's repair set proves larger than the enumerated 42 `LE.le]` sites by
  more than a factor of two, stop, revert Phase 1, and re-plan the order encoding (a `decide`-only
  `LE` or a rank-function encoding) rather than grinding through unbounded repair.
- Phase 4 is explicitly optional (SCOPE item 4). Dropping it costs nothing downstream — the
  marker classes are a side-car and no soundness or completeness theorem consumes them.
- If Phase 8's `axiom_dedekind_valid` dispatcher proves harder than budgeted (e.g. the Dense-case
  routing does not typecheck against the `ValidDedekindDense` binders), the fallback is to land
  `prior_U_gap_valid`/`prior_S_gap_valid`/`sep_valid` and `soundness_dedekind_valid` only, mark
  `soundness_dedekind` `[BLOCKED]`, and let the follow-up tasks pick it up — do NOT weaken the
  target to `ValidDedekind` to make it typecheck (SETTLED decision 2).
- Per `.claude/rules/error-handling.md`, recovery is fix-forward. Never discard uncommitted
  changes to reach a passing build; run `bash .claude/scripts/git-snapshot.sh` before any
  intentional rollback.
