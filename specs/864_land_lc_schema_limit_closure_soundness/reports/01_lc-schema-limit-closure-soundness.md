# Research Report: Landing the LC_n / LCU limit-closure soundness results

- **Task**: 864 - Land LC schema limit-closure soundness
- **Started**: 2026-11-05T05:20:00Z
- **Completed**: 2026-11-05T05:52:18Z
- **Effort**: ~30 minutes research; port estimated at 2 phases / ~500-700 Lean lines
- **Dependencies**: None (task 559 is `[COMPLETED]`; its probe directory is the input, not a blocker)
- **Sources/Inputs**:
  - Source probe: `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/03_morphisms-clock-rule-lc-schema.lean` (814 lines, Part I at lines 604-813)
  - Library semantics: `FormalSystem/Semantics/PartialHistory.lean`, `FormalSystem/Semantics/IntNormalForm.lean`, `FormalSystem/Semantics/TemporalOrder.lean`, `FormalSystem/Semantics/FrameProperty.lean`, `FormalSystem/Semantics/HistoryMorphism.lean`
  - Library L⁺ layer: `FormalSystem/PlusLanguage/Formula.lean`, `PlusTruth.lean`, `PlusValidity.lean`, `PlusPasting.lean`, `PlusLimitClosure.lean`, `PlusIntTransfer.lean`
  - Already-landed sibling: `FormalSystem/Metalogic/NamingRules.lean`
  - Gates: `scripts/check-module-invariants.sh`, `scripts/check-metalogic-cycles.sh`, `scripts/check-evidence-probes.sh`, `docs/theorem-index.md`
  - Tooling: lean-lsp `lean_local_search` (index state `warming` — see Evidence Tier), `lake env lean` on the probe
- **Artifacts**:
  - `specs/864_land_lc_schema_limit_closure_soundness/reports/01_lc-schema-limit-closure-soundness.md`
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Absence confirmed.** `lcAnte`, `lcCons`, `lcN`, `lcN_valid_full` and `omega_limit` occur nowhere under `FormalSystem/`, `Tests/` or `docs/` under any spelling (grep over the five names plus `omegaLimit`, `limit_closure`, `limitClosure` returns zero rows outside the probe). The task is not already satisfied.
- **The probe still compiles.** `lake env lean` on the probe exits 0 with empty output today — no errors, no warnings, no `sorry`. Measured in this session, not carried.
- **The port is close to mechanical, but only at ℤ-time.** The library already carries the two bridges the transposition needs: `Semantics/IntNormalForm.lean`'s step-path/world-history dictionary (`mem_HF_iff_adjacent`, `worldHistoryOfStepPath`, `WorldHistory.isStepPath`) makes "all-walks ℤ-model" and "every world history of a `FrameOver intOrder` frame" *the same set*, and `PlusLanguage/PlusIntTransfer.lean`'s `plusValidZTime_iff_plusValidInt` lifts a ℤ-fibre result to `PlusValidZTime`. The probe's `T (fullModel R V)` becomes `PlusTruthAt M`, and `IsWalk R` becomes `IsStepPath F`, with no change of argument.
- **One genuine mathematical limit.** The probe's ω-chain argument needs its marker sequence to be **cofinal** in the duration order (it uses `c 0 + k ≤ c k` over ℤ). That is false over a dense temporal order, so `lcN_valid_full` lands as a `.ZTime`-class result, **not** at `.Base`. This independently confirms the dispatch's instruction to keep the Zorn/Extension-Theorem argument for Base stated-not-claimed.
- **`NamingRules.lean` is the wrong home.** It is the natural sibling for the *clock rule* only. The LC schema's sibling is `PlusLanguage/PlusLimitClosure.lean`, which already holds the n = 1 limit-closure formula `blc` and the semantic lemma `limit_history`, and whose own docstring records the missing piece verbatim: "the instance at an `ω`-indexed recurrence schema is not stated here".
- **Time-sensitivity is sharper than the dispatch states, and separable from the port.** The probe is not wired into `scripts/check-evidence-probes.sh`, and `.gitignore` excludes `specs/archive/`, so `/todo` archival of task 559 silently removes the compiled provenance from version control. Promoting the probe into `specs/evidence/` is a cheap Phase 0 that de-risks archival independently of whether the Lean port completes.

## Context & Scope

In scope: locate the port targets for the probe's Part I (`omega_limit`, `omega_chain`, `bigAnd`, `lcAnte`, `lcCons`, `lcN`, `lcN_valid_full`), determine the layering/home module, identify every piece of library infrastructure the port consumes, and state honestly what will and will not compile at which frame class.

Out of scope, per the dispatch and respected here: any completeness or axiomatizability claim; any engine; the Auxiliary-Atoms expansion (its obstruction is `TaskFrame.Saturation` at the unravelled carrier, recorded at `FormalSystem/Metalogic/NamingRules.lean`'s "The Auxiliary-Atoms expansion, and where it stops"); Part H, Part J and Part K of the probe (Part K already landed).

### Evidence Tier

`lean_local_search` reported `index: warming` on the one query made, so LSP-backed absence is not proof of absence on its own. The absence finding therefore rests on the grep sweep (full-text, case-sensitive, over `FormalSystem/`, `Tests/`, `docs/`), which is the recorded evidence tier for this report. The `lake env lean` probe result is a direct measurement and carries no such caveat.

## Findings

### Absence of the five target declarations

A grep for `lcAnte|lcCons|lcN\b|lcN_valid|omega_limit|omegaLimit|limit_closure|limitClosure` over `FormalSystem/`, `Tests/` and `docs/` returns no rows. `lean_local_search` for `omega_limit` returns exactly three items: `Probe559c.omega_limit` (the probe itself), `Flow.omegaLimit_omegaLimit` (Mathlib dynamics, unrelated) and `Ordinal.omega0_le_of_isSuccLimit` (unrelated). Nothing has landed this content under a renamed form.

### What the library already has, and what the port consumes

| Probe construct | Library counterpart | File |
|---|---|---|
| `Fm` | `PlusFormula` | `FormalSystem/PlusLanguage/Formula.lean` |
| `T M σ t` | `PlusTruthAt M τ t` | `FormalSystem/PlusLanguage/PlusTruth.lean` |
| `dstab`, `someFuture`, `allFuture`, `and`, `neg`, `always` | present, same definitions | `PlusLanguage/Formula.lean` |
| clause lemmas `dstab_iff`, `someFuture_iff`, `allFuture_iff`, `and_iff` | present, same shapes | `PlusLanguage/PlusTruth.lean` |
| `IsWalk R σ` | `IsStepPath F f` (`∀ n : ℤ, F.step (f n) (f (n+1))`) | `Semantics/IntNormalForm.lean` |
| `fullModel R V` (all walks) | `WorldHistory F` at `F : FrameOver intOrder` — **equal** by `FrameOver.mem_HF_iff_adjacent` | `Semantics/IntNormalForm.lean` |
| walk → model element | `FrameOver.worldHistoryOfStepPath` | `Semantics/IntNormalForm.lean` |
| model element → walk | `WorldHistory.isStepPath` | `Semantics/IntNormalForm.lean` |
| `paste`, `paste_walk` | `paste` (same `if s ≤ t` definition), `paste_agreeFrom`, `paste_agreeUpTo` | `PlusLanguage/PlusPasting.lean` |
| limit of a sequence of walks | **absent** — build via `WorldHistory.ofTotal` | `Semantics/PartialHistory.lean` |
| `Fm.gle` (G≤) | **absent** — define locally as `φ.and φ.allFuture` | — |
| `bigAnd : ℕ → (ℕ → Fm) → Fm` | **absent**; `Syntax.bigconj` exists but is `List Formula → Formula` with a non-uniform base case, so it is not reusable at the L⁺ layer | `FormalSystem/Syntax/BigConj.lean` |
| validity target | `PlusValidInt` (ℤ fibre) → `PlusValidZTime` via `plusValidZTime_iff_plusValidInt` | `PlusLanguage/PlusIntTransfer.lean` |

The `omega_limit` port is *shorter* than the probe's, not longer: `WorldHistory.ofTotal F f h` asks for `h : ∀ s t, F.TaskRel (f s) (t - s) (f t)`, which the limit discharges directly from local agreement (pick a marker above both `s` and `t`, then use that stage's own `respects_task`). The probe needed `IsWalk` plus a composition argument because its bundle was defined by adjacency.

### The home module, and why it is not `NamingRules.lean`

The dispatch asks to confirm the layering before committing to `FormalSystem/Metalogic/NamingRules.lean`. It is the wrong home:

- `NamingRules.lean` is about *naming rules* — non-orthodox inference rules that discharge an auxiliary letter. Its imports are `Semantics/Frames/TranslationProduct` and `PlusLanguage/PlusValidity`, and its content is `Fresh`, the clock valuation, and the two soundness theorems. LC_n discharges no letter and needs no translation product.
- `PlusLanguage/PlusLimitClosure.lean` is the actual sibling. It carries `blc` — `(⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))`, the n = 1 case of exactly this schema — and `limit_history`, its semantic core, at `.Base` by Zorn plus the Extension Theorem. Its `PartialHistory.exists_maximal_of_chainClosed` docstring already names the gap this task fills: "`Q` is arbitrary: `LCProp` below is one instance, and the instance at an `ω`-indexed recurrence schema is not stated here."
- Import direction is clean: the new content needs `PlusPasting` (for `paste`) and `PlusIntTransfer` (for the ZTime transfer), both inside `PlusLanguage/`. No `Metalogic/` dependency, so `scripts/check-metalogic-cycles.sh`'s assertion B (the 8-line upward-import allowlist) acquires no new edge.

Recommended placement: two new modules beside `PlusLimitClosure.lean`, registered in `FormalSystem/PlusLanguage.lean` and `FormalSystem.lean` (both already list `PlusLimitClosure` and `PlusIntTransfer`, at `FormalSystem.lean` lines 572-573).

### The ℤ-time scoping is forced, and the Base case stays stated-not-claimed

The probe's `lcN_valid_full` closes the consequent's `G≤` by producing, for an arbitrary `s ≥ t` and index `j`, a marker `c k > s` whose index is `j + 1 mod n`. That needs the markers to be cofinal, which the probe gets from ℤ: `c_ge` gives `c 0 + k ≤ c k`. A `TemporalOrder` is an arbitrary nontrivial totally ordered abelian group (`Semantics/TemporalOrder.lean`), so over a dense order a strictly increasing marker sequence may converge and the argument does not close.

Nor does the library's existing Zorn route generalize for free. `lcProp_restrictIic` works at n = 1 because the restriction's maximum *is* a `P`-point, which discharges the one pending obligation. With n indices, the splice witness realizes `⟐α_{j+1}` only, so it cannot serve as the excusing maximum for the other `n-1` obligations, and `LCProp`'s `recur` clause fails on the nonempty-ness step. Generalizing the Zorn property to a cycling family is genuinely new mathematics, not a transposition.

Consequence, matching the dispatch: land `lcN_valid_full` as a ℤ-time result, record the Base question as open in the module docstring and in prose, and claim nothing about it. The ℤ-time scoping is the compiled claim; `.Base` would be a prose claim.

### Statement shapes recommended for the port

Stated here so the plan can pin them as Lean Challenge Statements (names are proposals):

```lean
-- Phase 1, frame-generic kernel
theorem omega_limit {F : TaskFrame} {τ : ℕ → WorldHistory F} {c : ℕ → F.Duration}
    (hc : ∀ k, c k < c (k + 1)) (hcof : ∀ x, ∃ k, x ≤ c k)
    (hag : ∀ k x, x ≤ c k → (τ (k + 1)).state x = (τ k).state x) :
    ∃ lim : WorldHistory F, ∀ k x, x ≤ c k → lim.state x = (τ k).state x

theorem omega_chain {F : TaskFrame} [F.IsRegular] (hcof : ∀ c : ℕ → F.Duration,
      (∀ k, c k < c (k + 1)) → ∀ x, ∃ k, x ≤ c k) …   -- probe's binder bundle otherwise unchanged

-- the ℤ discharge of the cofinality hypothesis
theorem intOrder_omega_cofinal (c : ℕ → ℤ) (hc : ∀ k, c k < c (k + 1)) (x : ℤ) : ∃ k, x ≤ c k

-- Phase 2, the schema
def bigAnd : ℕ → (ℕ → PlusFormula) → PlusFormula
def lcAnte (n : ℕ) (α : ℕ → PlusFormula) : PlusFormula
def lcCons (n : ℕ) (α : ℕ → PlusFormula) : PlusFormula
def lcN   (n : ℕ) (α : ℕ → PlusFormula) : PlusFormula
theorem lcN_plusValidInt (n : ℕ) (hn : 0 < n) (α : ℕ → PlusFormula) : PlusValidInt (lcN n α)
theorem lcN_plusValidZTime (n : ℕ) (hn : 0 < n) (α : ℕ → PlusFormula) : PlusValidZTime (lcN n α)
```

Threading `hcof` as a hypothesis on `omega_chain` rather than hard-wiring `intOrder` keeps the ℤ-dependence explicit and auditable at exactly one binder, and leaves the kernel reusable if the dense case is ever settled. The planner may instead state both kernel lemmas directly at `FrameOver intOrder`; that is simpler and loses only reusability.

### Literature Proof Structure

**Source**: M. Reynolds, *An Axiomatization of Prior's Ockhamist Logic of Historical Necessity* (2003) — the repository's established citation key `reynolds2003` (used in `FormalSystem/OpenLanguage/README.md` and `FormalSystem/Metalogic/BXCanonical/Quasimodel/Realization.lean`). The paper itself is **not** in `specs/literature-index.json`; the index carries `reynolds_2001` and several `reynolds_1992_*` sections only.

**Strategy**: the proof of record for this task is not the paper's. It is the probe's compiled transposition of the schema to `⊡` with `G≤`, which is a direct ω-chain construction. The step map below is extracted from that compiled proof (`specs/559_.../probes/03_morphisms-clock-rule-lc-schema.lean`, Part I), not from the paper, and the report claims nothing about the paper's own argument.

**Step map** (probe Part I):

1. `c_mono`, `c_ge`, `agree_add` — marker monotonicity and transitive agreement across stages (lines 609-628).
2. `omega_limit` — the ω-limit-of-splices principle: a sequence of walks each agreeing with its predecessor up to a strictly increasing marker has a limit walk agreeing with stage `k` up to marker `k` (line 630).
3. `Stg`, `stg_step` — one splice: paste the continuation onto the current stage at its marker, producing a later stage with a strictly larger marker (lines 651-679).
4. `omega_chain` — iterate `stg_step` by `Nat.rec` with `choose`, then take the `omega_limit` (line 681).
5. `bigAnd`, `bigAnd_iff` — finite conjunction and its truth clause (lines 707-725).
6. `lcAnte`, `lcCons`, `lcN` — the schema, with indices `mod n` (lines 727-734).
7. `lcN_valid_full` — case split on whether any `⟐α_i`-point is reachable; vacuous branch uses the evaluation history itself; the main branch runs `omega_chain` at `A k := ⟐α_{(i₀+k) mod n}` and closes `G≤` by choosing a marker `c k > s` in residue class `j + 1 mod n` (line 737).

**Dependencies**: step 2 depends on step 1; step 4 on steps 2 and 3; step 7 on steps 4, 5 and 6.

**Potential formalization challenges** (per step, for the library target):

- Step 2: none — `WorldHistory.ofTotal` makes it shorter than the probe's version. The one new obligation is well-definedness of the limit under the choice of stage index, which `agree_add` already supplies.
- Step 3: none — the library's `paste` has the probe's exact definition and the two agreement lemmas the splice needs.
- Step 4: `Nat.rec` over a `Stg` bundle plus `Exists.choose` transposes unchanged; it introduces `Classical.choice`, which is already the tree's standard `pcq` profile.
- Step 5: new helper. The index must be `ℕ` with a uniform `top` base case; the existing `Syntax.bigconj` has neither shape nor layer.
- Step 6: `gle` does not exist in `PlusLanguage/Formula.lean`; define it locally (as `φ.and φ.allFuture`) together with its truth clause, which the probe's `gle_iff` supplies as a template.
- Step 7: the only step where the ℤ-time hypothesis is consumed a second time (`c k > s`), and therefore the step that fixes the frame class of the result.

### Gate obligations

- **`docs/theorem-index.md`**: one row per landed result, columns `Paper label | Statement | Lean name | File | Frame class | Axioms`. `Paper label` is `—` for formalization-native results (the `NamingRules` rows at lines 480-481 are the pattern to copy). `Frame class` must read `ZTime` for `lcN_plusValidZTime`, `—` for the class-generic kernel lemmas. The `Axioms` cell is **generated from the baseline, never typed** — `pcq` abbreviates exactly `[propext, Classical.choice, Quot.sound]`, and the `pinned:C14` token is what makes the row assertable.
- **`scripts/check-module-invariants.sh`**: C14 needs a `#print axioms <fully.qualified.name>` line in its probe block (the `NamingRules` lines sit at 2743-2746) and the measured response in `C14_BASELINE` (the matching rows are at 2473-2476). Measure, then paste; a hand-typed profile is the defect the gate exists to catch.
- **`scripts/check-metalogic-cycles.sh`**: no new upward edge is expected (new modules live inside `PlusLanguage/`), but it must be re-run green against its pre-task baseline.
- **Build order**: guarded scoped build of the new modules first (`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.PlusLanguage.<Module>`), then the unscoped build. Three tasks share this working tree this cycle, so an unexplained failure outside the new modules may be a sibling's in-flight edit.

### Provenance: the probe leaves version control on archival

`scripts/check-evidence-probes.sh` contains no reference to task 559 or to its `probes/` directory, so the source probe is unguarded; and `.gitignore` line 94 excludes `specs/archive/`. The script's own header documents this exact failure mode from a previous occurrence ("When `/todo` archived that task the whole directory moved to `specs/archive/`, which `.gitignore` excludes — so the four probes left version control entirely"). The remedy the script prescribes is promotion into `specs/evidence/`, which is tracked and task-independent, plus a `WIRED` entry naming the decision the probe holds in place.

This matters even if the port lands in full: the probe is the compiled record of the *unverified* Base argument and of Parts H and J, none of which this task lands.

## Decisions

- Home module: `FormalSystem/PlusLanguage/`, beside `PlusLimitClosure.lean` — **not** `FormalSystem/Metalogic/NamingRules.lean`. Rationale above; the dispatch explicitly left this open for confirmation.
- Frame class of the landed result: `.ZTime`, reached as `PlusValidInt` on the ℤ fibre and transferred by `plusValidZTime_iff_plusValidInt`. The `.Base` case is recorded as open, in prose, with no claim.
- Walk layer: use the existing `IsStepPath` dictionary rather than importing or redefining the probe's `IsWalk`-over-a-raw-relation setting. `Walk.IsWalk` does exist (`Semantics/Correspondence/FwdRecPeriodicity.lean`) and is definitionally `IsStepPath F F.step`, but the history-level statement is the one the L⁺ truth definition consumes.
- Pasting: reuse `PlusPasting.paste` and its two agreement lemmas. Do not introduce a second pasting operator.
- Two phases, in the dispatch's order: the ω-limit/ω-chain kernel first, the schema and its validity second.

## Recommendations

1. **Phase 0 (optional, ~15 min, independent of the port)** — promote `specs/559_.../probes/03_morphisms-clock-rule-lc-schema.lean` into `specs/evidence/` (a new `limit-closure-schema/` collection, or the existing `stability-modal-substrate/`) and add a `WIRED` entry to `scripts/check-evidence-probes.sh` naming the decision it holds in place. This is the only action that makes task 559's archival harmless. Flagged as a scope judgment: it preserves this task's input rather than landing this task's output, so the planner may legitimately drop it — but dropping it should be a recorded choice, not an omission.
2. **Phase 1** — the kernel: `omega_limit`, the `Stg`/`stg_step`/`omega_chain` bundle, and the ℤ cofinality discharge. Verify with a guarded scoped build; no new formula syntax yet, so nothing in `docs/` changes.
3. **Phase 2** — the schema: `bigAnd` + `bigAnd_iff`, local `gle` + its truth clause, `lcAnte`/`lcCons`/`lcN`, `lcN_plusValidInt`, `lcN_plusValidZTime`. Verify scoped, then unscoped.
4. **Phase 3** — the ledger: measure `#print axioms` for every new public result, paste the measured lines into the C14 baseline and probe block, add the `docs/theorem-index.md` rows with `pinned:C14`, and re-run `check-module-invariants.sh` and `check-metalogic-cycles.sh` green.
5. **LCU**: the dispatch's title mentions LCU alongside LC_n, but the probe's Part I defines no separate `LCU` declaration — the compiled content is `lcN` (`lcAnte`/`lcCons`/`lcN`/`lcN_valid_full`) and the `omega_limit`/`omega_chain` kernel. The plan should either identify LCU with the `n = 1` instance of `lcN` (which is what the schema specializes to, and what `blc` already covers at `.Base` by a different route) or record LCU as not present in the source and therefore out of this task's deliverable. Do not invent a declaration to fill the name.

## Risks & Mitigations

- **Risk**: an implementer reads "this is a port, not a proof search" and attempts `.Base` generality, then reaches for a `sorry` when the cofinality step fails. **Mitigation**: pin the frame class in the plan's Lean Challenge Statements (`PlusValidZTime`, not `PlusValid`), and quote the cofinality obstruction in the phase body.
- **Risk**: LC_n's name collides conceptually with the landed `blc`, and a reviewer concludes one supersedes the other. **Mitigation**: the module docstring must state the relation explicitly — `blc` is the n = 1 case at `.Base` by Zorn; `lcN` is the n ≥ 1 cycling schema at `.ZTime` by ω-chain; neither subsumes the other, because the routes differ in frame class and in index arity.
- **Risk**: hand-typed axiom profiles in `docs/theorem-index.md`. **Mitigation**: the dispatch already forbids this; Phase 3 measures first and pastes second.
- **Risk**: concurrent siblings (tasks 866, 868, undeclared file scope) collide on `scripts/check-module-invariants.sh` or `docs/theorem-index.md`, both of which are plausible shared targets. **Mitigation**: re-read both files immediately before editing, stage only this task's hunks, and treat an out-of-scope build failure as possibly foreign.
- **Risk**: the `Classical.choice` introduced by `omega_chain`'s `Nat.rec`/`choose` changes an existing pinned profile. **Mitigation**: nothing existing imports the new modules, so no existing baseline row can move; only new rows are added.

## Tactic Survey Results

- Not applicable (no tactic survey performed). The source proofs are compiled and sorry-free, so no goal needed closing in this dispatch; the port's tactic choices are fixed by the probe's own script under the plan-compliance and literature-fidelity rules.

## Context Extension Recommendations

- **Topic**: the ℤ-fibre normalization route for L⁺ validity results.
- **Gap**: `context/project/lean4/` has no note recording that a result about "all-walks ℤ-models" lands in this library as `PlusValidInt` on `FrameOver intOrder`, transferred to `PlusValidZTime` by `plusValidZTime_iff_plusValidInt`, with `mem_HF_iff_adjacent` supplying the walk/history identification. This dispatch spent most of its search budget rediscovering that path, and every future probe written in the Mathlib-only all-walks idiom will need it.
- **Recommendation**: add `context/project/lean4/patterns/ztime-walk-normalization.md` naming the three declarations and the two-step transfer, with the standing caveat that cofinality-dependent arguments do not generalize off the ℤ fibre.

## Appendix

### Commands run

- `grep -rn "lcAnte\|lcCons\|lcN\b\|lcN_valid\|omega_limit\|omegaLimit\|limit_closure\|limitClosure" FormalSystem/ Tests/ docs/` — no output.
- `lake env lean specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/03_morphisms-clock-rule-lc-schema.lean` — exit 0, empty output.
- `mcp__lean-lsp__lean_local_search` for `omega_limit` — three items, `index: warming`.

### Key declaration locations

- Probe Part I: `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/03_morphisms-clock-rule-lc-schema.lean`, `omega_limit` at line 630, `omega_chain` at line 681, `bigAnd` at 707, `lcAnte`/`lcCons`/`lcN` at 727-734, `lcN_valid_full` at 737.
- `FrameOver.mem_HF_iff_adjacent`, `FrameOver.worldHistoryOfStepPath`, `WorldHistory.isStepPath`, `IsStepPath` — `FormalSystem/Semantics/IntNormalForm.lean`.
- `PlusValidInt`, `plusValidZTime_iff_plusValidInt` — `FormalSystem/PlusLanguage/PlusIntTransfer.lean`.
- `paste`, `paste_agreeFrom`, `paste_agreeUpTo`, `AgreeFrom`, `AgreeUpTo` — `FormalSystem/PlusLanguage/PlusPasting.lean`.
- `blc`, `blc_plusValid`, `limit_history`, `LCProp`, `PartialHistory.exists_maximal_of_chainClosed` — `FormalSystem/PlusLanguage/PlusLimitClosure.lean`.
- `WorldHistory.ofTotal` — `FormalSystem/Semantics/PartialHistory.lean`.
- `TaskFrame.IsZTime` — `FormalSystem/Semantics/FrameProperty.lean`; `intIso` — `FormalSystem/Semantics/DurationClassification.lean`.
- Landed clock/irreflexivity rules — `FormalSystem/Metalogic/NamingRules.lean`.

### References

- `FormalSystem/PlusLanguage.lean` — aggregator prose describing `PlusLimitClosure` and `PlusIntTransfer`.
- `scripts/check-evidence-probes.sh` — the "TRACKED, NOT MERELY PRESENT" header section, which documents the archival hazard this task's input is exposed to.
- `docs/theorem-index.md` lines 15-24 — the column conventions and the `pinned:C14` re-derivation command.
