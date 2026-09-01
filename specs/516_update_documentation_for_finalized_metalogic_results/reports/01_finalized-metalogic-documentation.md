# Research Report: Task #516

**Task**: 516 - Update documentation for finalized metalogic results
**Started**: 2026-09-01T00:00:00Z
**Completed**: 2026-09-01T21:10:18Z
**Effort**: small (2-4 hours)
**Dependencies**: None
**Sources/Inputs**:
- `bash scripts/check-module-invariants.sh` (C1-C15 invariant checks, run live)
- `bash scripts/typst-status-counts.sh --json` (ground-truth count generator)
- Direct `grep`/`Read` over `FormalSystem/Metalogic/**/*.lean` module docstrings
- `specs/TODO.md` (task 494 full description, task 516 entry)
- `README.md`, `docs/project-info/implementation-status.md`, `docs/project-info/known-limitations.md`,
  `docs/research/BIMODAL_LOGIC.md`, `FormalSystem/Semantics/Correspondence/README.md`,
  `FormalSystem/Metalogic/Independence/README.md`, `FormalSystem/Metalogic/WeakCanonical/Kamp/README.md`
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **README.md is already substantially accurate and current** (last touched 2026-09-01 by
  task-493/510 documentation-correction phases, same day as this research). Its claims about
  soundness, weak/finite-context completeness (all four frame classes), the three-way
  compactness/strong-completeness split, and decidability's one-directional status all match
  live ground truth verified below. **No corrections are needed to the existing prose in these
  areas.**
- **The one real content gap**: nothing in `README.md` or in the in-tree authoritative status
  ledger (`FormalSystem/Metalogic.lean`'s "Publication-Ready Results" docstring) mentions the
  **characterization/definability results** — two finished, sorry-free result families that
  exist in the tree today: (1) frame-class Galois-closure ("which frame classes are
  axiomatizable by a single formula") in `FormalSystem/Semantics/Correspondence/`, and (2)
  Kamp's expressive-completeness theorem for Prior structures
  (`kampPriorExpressiveCompleteness`, `WeakCanonical/Kamp/KampPrior.lean:672`). This is almost
  certainly what task 516's mention of "characterization results" (alongside completeness,
  soundness, compactness) is asking to have reflected — because currently it is reflected
  **nowhere**, not because anything currently says something false about it.
  See [Findings > Characterization/Definability Results](#characterizationdefinability-results)
  for the durable anchors to cite.
- **Task 494's substantive content** (verified independently, without trusting prose): there is
  no `CompactDedekind` definition, no `StrongCompletenessDedekind`, and no refutation anywhere in
  the tree. The Discrete-class non-compactness witness (`archWitness`,
  `DiscreteNonCompactness.lean:102`) provably does not port to the Dedekind class, because it
  depends on `[SuccOrder D] + [IsSuccArchimedean D]`, which the Dedekind binder list
  (`DenselyOrdered` + LUB, no successor structure) does not supply, and `Formula.next` is
  semantically vacuous over ℝ. A new witness construction is the open work. Both `README.md` and
  `docs/project-info/known-limitations.md` already describe this precisely and accurately
  ("unavailable on the primary source's own terms... unproved rather than refuted" /
  "remains the one open case") — **no change needed there**, but any new prose this task adds
  must preserve that framing and not accidentally claim Dedekind compactness is settled.
- A distinction worth flagging explicitly for whoever writes the doc update: **"Dedekind
  compactness is open" (task 494) is a different, unrelated fact from "`Sat FrameClass.Dedekind`
  is not Galois-closed" (already proved, `Independence/RationalWitness.lean`,
  `sat_dedekind_ssubset_mod_axiomSet`)**. Both are true statements about the same frame class but
  about different properties (compactness of the *consequence relation* vs. Galois-closedness of
  the *model class*); conflating them in new prose would be a new inaccuracy.
- `lake build` is green, the structural sorry inventory is zero outside `Boneyard/` (machine
  re-verified, not merely quoted from a docstring), and all four flagship-theorem axiom sets are
  exactly `[propext, Classical.choice, Quot.sound]` (no `sorryAx`, no `native_decide`
  dependency). One repo-hygiene check (`C6`) is currently failing, but it is unrelated to
  documentation content — see [Risks & Mitigations](#risks--mitigations).

## Context & Scope

Task 516 asks that `README.md` and other relevant documentation reflect the **finalized**
completeness, soundness, compactness, and characterization results, while task 494 (Dedekind
compactness) remains outstanding and must not be over- or under-represented. The instruction is
accuracy discipline, not a rewrite: everything claimed must trace to a file path plus
theorem/definition name actually verified in this pass, using the repo's own verification
tooling rather than trusting existing prose.

This repository has an unusually rigorous, machine-enforced documentation-sync discipline
(`scripts/check-module-invariants.sh`, checks C1-C15, including C14 "no stale axiom or sorry
counts documented in docs/ + README.md + FormalSystem/*.lean"), and documentation was corrected
today, same-day, by two other tasks (`493 phase 3: correct documentation`,
`510 phase 5: repair stale FrameConditions documentation references`). That materially narrowed
this task's actual scope: most of what a "verify README against ground truth" pass would
normally have to fix turned out to already be correct.

## Findings

### Codebase Patterns — Verification Tooling

- `scripts/check-module-invariants.sh` is the authoritative, re-runnable ground-truth check. Ran
  it live (`bash scripts/check-module-invariants.sh`, no `--no-build` flag, full `lake build`
  included):
  - `PASS C1` — `lake build` and `lake build BimodalTest` both exit 0.
  - `PASS C2` — all four flagship axiom sets match baseline:
    `FormalSystem.Metalogic.BXCanonical.completeness`,
    `FormalSystem.Metalogic.BXCanonical.completeness_dense`,
    `FormalSystem.Metalogic.BXCanonical.completeness_discrete`,
    `FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense` — each
    `[propext, Classical.choice, Quot.sound]`, nothing else.
  - `PASS C3` — structural `sorry` inventory is **zero** across `FormalSystem/` excluding
    `Boneyard/`, asserted by content (not by a stale line-number list).
  - `PASS C14` — no stale axiom or sorry counts documented in `docs/` + `README.md` +
    `FormalSystem/*.lean`; additionally re-checks
    `FormalSystem.Metalogic.Decidability.sound_of_isValid`,
    `FormalSystem.Metalogic.completeness_dedekind`,
    `FormalSystem.Metalogic.strongCompletenessBase`,
    `FormalSystem.Metalogic.strongCompletenessDense` against their axiom baseline — all four
    match, same axiom set.
  - `PASS C15` — all 47 paper-anchor citations resolve against
    `specs/paper-definitions-of-record.md`.
  - `FAIL C6` — 4 unreachable live modules absent from
    `scripts/module-invariants-manifest.txt` (`Metalogic/SpWitness.lean`,
    `Metalogic/TMCompletenessReduction.lean`, `Metalogic/Z1Countermodel.lean`,
    `Semantics/LexCarrier.lean`). This is a manifest-registration gap in test infrastructure, not
    a documentation-content claim; see Risks below.
  - `INFO C9D` — 138 task-number citations under `docs/` (not yet exit-code-enforced,
    `ENFORCE_C9_DOCS=1` would make it so). Largely in `docs/development/PHASED_IMPLEMENTATION.md`
    (100), `docs/training/PIPELINE.md` (11), and three research/architecture docs. These are
    **outside** this task's scope (none touch completeness/soundness/compactness/characterization
    claims) but are worth flagging to whoever owns `docs/` hygiene generally, per
    `.claude/rules/no-task-references-in-deliverables.md`.
- `scripts/typst-status-counts.sh --json` independently reproduces: `sorry_total_excl_boneyard:
  0`, `axiom_count: 45`, `rule_count: 7`, `base_count: 37`, `dense_only_count: 2`,
  `discrete_only_count: 3`, `dedekind_only_count: 3` — all match what `README.md`'s "Axiom
  Systems" table already states.
- Manual audit of raw `sorry` occurrences: `grep -rn '\bsorry\b' FormalSystem/ --include='*.lean'
  | grep -v '/Boneyard/'` returns ~90 lines after filtering out `sorry-free`/`zero sorry`/etc.
  phrasing, but every one of those ~90 is prose (module docstrings narrating past sorry history,
  decisions *not* to sorry, or comments about a sorry that now lives only in `Boneyard/`) — none
  is a live `sorry` tactic invocation. This independently corroborates C3's zero-count rather than
  contradicting it; a naive grep-count would have overstated the live sorry inventory by orders
  of magnitude, which is exactly the kind of trap this task's instructions warned against.

### Soundness — Verified Finalized

`FormalSystem/Metalogic.lean`'s docstring ("Publication-Ready Results") and the live checks agree:
- `soundness`, `soundness_dense`, `soundness_discrete` — SORRY-FREE.
- `bl_soundness`, `bl_soundness_dense`, `bl_soundness_discrete`, `bl_soundness_dedekind`
  (`Metalogic/BaseLanguageSoundness.lean`) — SORRY-FREE, stated against the native
  `BLTruthAt` recursion (`Semantics/BLTruth.lean`), obtained by composing
  `Conservativity.translate` with the four soundness theorems across the `truthAt_tr` bridge.
- `soundness_dedekind` exists and is used by `bl_soundness_dedekind`'s composition, at
  `ValidDedekindDense`, not the density-free `ValidDedekind` (which would be refutable).

`README.md`'s "Axiom Systems" table already attributes `soundness`/`soundness_discrete`/
`soundness_dense`/`soundness_dedekind` correctly to each of the four axiom systems — accurate,
no change needed.

### Completeness — Verified Finalized (weak / finite-context)

All four weak completeness theorems are proved and sorryAx-free at
`[propext, Classical.choice, Quot.sound]`:
- `completeness`, `completeness_dense`, `completeness_discrete` —
  `FormalSystem/Metalogic/BXCanonical/Completeness.lean`.
- `completeness_dedekind` — `FormalSystem/Metalogic/StrongCompleteness.lean:469`, weak
  completeness for `FrameClass.Dedekind` against `ValidDedekindDense` on the real line, a
  corollary of `consequence_completeness_dedekind`.
- `countermodel_discrete` (the Base-class discrete branch) is proved, not dead code, at
  `WeakCanonical/GroupModel/CountermodelBase.lean:142`.

Finite-context consequence completeness (`consequence_completeness_base/dense/discrete/dedekind`)
exists for all four classes and is explicitly, correctly distinguished in both `README.md` and
`FormalSystem/Metalogic.lean` from "strong completeness" (infinite `Γ : Set Formula`) — this
terminology discipline is already correct everywhere audited and should be preserved verbatim in
any new prose.

### Compactness / Strong Completeness — Verified Three-Way Split

`FormalSystem/Metalogic/Compactness.lean` and `DiscreteNonCompactness.lean` (module docstrings
plus theorem signatures read directly):
- **Base and Dense — PROVED.** `modelExistenceBase`/`modelExistenceDense`
  (`Compactness.lean:82,119`) by an ultraproduct over `Ultraproduct.Idx Γ` with Łoś's theorem
  (`Ultraproduct.los_truthAt`, `Semantics/Ultraproduct/Los.lean`); `compactBase`/`compactDense`
  (`:141,144`) immediate from `compact_of_modelExistence`; `strongCompletenessBase`/
  `strongCompletenessDense` (`:154,161`) from `strongCompleteness_of_compact`. All sorry-free,
  axiom set confirmed by C14 above.
- **Discrete — REFUTED.** Witness `archWitness p = {F p} ∪ {¬Xⁿp : n ∈ ℕ}`
  (`DiscreteNonCompactness.lean:102`): every finite subset satisfiable over ℤ
  (`archWitness_finitely_satisfiable:194`), the whole set unsatisfiable on any Archimedean
  discrete carrier (`archWitness_not_satisfiable:228`), giving
  `discrete_consequence_not_compact:249` and, via soundness,
  `strongCompletenessDiscrete_refuted:278`. Both sorry-free.
- **Dedekind — UNRESOLVED (task 494's substantive content).** Verified by direct absence: no
  `CompactDedekind`, `StrongCompletenessDedekind`, `SatisfiableDedekindSet`, or
  `ModelExistenceDedekind` symbol exists anywhere in `FormalSystem/` (confirmed by grep; the
  `Metalogic.lean` docstring states this directly: "this tree contains no `CompactDedekind`
  definition and no refuting theorem, so the class is *unproved* rather than refuted"). The
  paper's `cor:tm-completeness` (`possible_worlds.tex:4657`) asserts strong completeness
  "provably fails... for the dense-and-complete class R where compactness fails," but that
  assertion is **not yet machine-checked** in this tree — it rests on Reynolds 1992 §9 Theorem 7
  alone, which is weak-only. Per the current `specs/TODO.md` entry, task 494 is sequenced behind
  a compactness-parameterization prerequisite and its dependencies (tasks 490, 493, 509) are now
  complete per recent commit history, so the remaining work is a **new** non-compactness witness
  for the Dedekind class — `archWitness` cannot be reused because it needs
  `[SuccOrder D] + [IsSuccArchimedean D]`, which Dedekind's binder list (`DenselyOrdered` + LUB,
  no successor structure) does not provide, and `Formula.next` is semantically vacuous over ℝ.

`README.md`'s "Strong completeness" paragraph and mermaid-adjacent prose already state exactly
this three-way split, correctly, including the precise Dedekind framing ("not stated, and
unavailable on the primary source's own terms... unproved rather than refuted"). No correction
needed. `docs/project-info/known-limitations.md`'s "Limitation 1" table and prose independently
state the identical three-way split with the identical framing, also correct as-is.

### Decidability — Verified One-Directional

`Decidability/Correctness.lean` and `Decidability/Verified/Decidable.lean` (cross-checked against
`README.md`'s "### Decidability" subsection):
- **Landed**: `sound_of_isValid`, `isValid_sound`, `decide_sound`, and the tableau rule-soundness
  half `ruleSound_of_mem_allRulesForFC` — sorry-free. C14 independently re-verifies
  `sound_of_isValid`'s axiom set live.
- **Open**: the completeness direction (`⊨ φ → isValid φ fc = true`), hence
  `valid_iff_allClosed` and the `Decidable (⊨ φ)` instances, is not proved. Two theorems that
  once claimed a decidability result vacuously (`validity_decidable`,
  `validity_has_decision_procedure`) are documented as retired.
- **Partial**: `extractProof` runs five strategies and returns `.incomplete` when exhausted.

`README.md`'s "### Decidability" section already states this precisely, including the historical
note about the retired vacuous theorems (a rare and valuable piece of accuracy discipline — it
warns a reader away from trusting a theorem *name* alone). No correction needed.

### Characterization/Definability Results

This is the one area with a genuine documentation gap. Two independent, finished, sorry-free
result families exist and are absent from every status-summarizing document audited
(`README.md`, `FormalSystem/Metalogic.lean`'s "Publication-Ready Results" list,
`docs/project-info/implementation-status.md`):

**1. Frame-class Galois-closure / definability**
(`FormalSystem/Semantics/Correspondence/`, module README last-verified 2026-09-01):
- The organizing fact: "is this frame class axiomatizable?" and "is this frame class
  Galois-closed?" are the same question (`galoisClosed_mod`, `Correspondence/Galois.lean:139`),
  and a class is shown closed by exhibiting a *single* formula valid on exactly its members
  (`galoisClosed_of_indicator`, `Galois.lean:158`).
- **Positive** (Galois-closed, i.e. characterized by a single formula):
  `galoisClosed_sat_dense` and `galoisClosed_isDiscrete`
  (`Correspondence/Indicator.lean:133,151`), plus the underlying indicator biconditionals
  `validOn_nextTop_iff`, `validOn_nextTop_iff_isDiscrete` — note this is `TaskFrame.IsDiscrete`,
  the bare structural clause, not the narrower Hölder-to-ℤ class.
- **Negative** (provably NOT Galois-closed, via the `Independence/` sandwich witnesses):
  `sat_dedekind_ssubset_mod_axiomSet` (`Independence/RationalWitness.lean`) and
  `sat_discrete_ssubset_mod_axiomSet` (`Independence/LexIntWitness.lean`) — `Sat
  FrameClass.Dedekind` and `Sat FrameClass.Discrete` (the narrow, `FrameClass`-indexed reading)
  are each strictly smaller than the model class of their own axiom set.
- Explicitly documented non-goal, worth preserving in any new prose so as not to over-claim:
  "closed-form characterizations of `Mod (AxiomSet .Discrete)` and `Mod (AxiomSet .Dedekind)` are
  open and not promised" (`Correspondence/Galois.lean` module docstring, echoed in
  `Correspondence/README.md`).

**2. Kamp's expressive-completeness theorem for Prior structures**
(`WeakCanonical/Kamp/KampPrior.lean:672`, `kampPriorExpressiveCompleteness`):
- Statement: every `MonadicFormula sig 1` has an equivalent `Formula` using only `U`/`S` on Prior
  structures — i.e. `{U, S}` is expressively complete relative to monadic first-order logic,
  following Rabinovich 2014's proof chain (Lemma 5.1 -> Prop 4.2 -> Prop 4.3 -> Theorem 4.4).
- Status, per the module's own "## Status" section: sorry-free at every depth (`k=0`, `k=1`,
  `k>=2` via the ζ-wire), full chain axioms `[propext, Classical.choice, Quot.sound]`. This is
  not merely claimed in prose — it is load-bearing: `kampPriorExpressiveCompleteness` feeds the
  live completeness chain (`BXCanonical/Completeness.lean:406`:
  `... -> uSExpressivelyCompleteOverPrior -> kampPriorExpressiveCompleteness`), so its
  correctness is already transitively covered by C2's axiom check on `completeness` itself.
- `WeakCanonical.lean` and `README.md`'s Project Structure section currently only note that
  `Kamp/` (116 files, largest subtree in the repo) is "the Kamp-style expressiveness
  development" — true but silent on the fact that the headline theorem is *done*.

## Decisions

- **Recommend not touching** the existing soundness/completeness/compactness/decidability prose
  in `README.md`, `docs/project-info/implementation-status.md`, or
  `docs/project-info/known-limitations.md` — all verified accurate as of this pass. Editing
  correct prose risks introducing the very staleness this task exists to prevent.
- **Recommend adding** a new subsection to `README.md`'s "## Metalogical Results" (after the
  existing "### Decidability" subsection, before "## Documentation") summarizing the
  characterization/definability results above, citing the specific theorem names and file
  anchors given in Findings — both the positive Galois-closure results and the Kamp
  expressive-completeness result, each with its sorry-free/axiom-set status stated the same way
  the rest of that section already does it.
- **Recommend adding** the same two result families to `FormalSystem/Metalogic.lean`'s
  "Publication-Ready Results" docstring list, since that file is the in-tree authoritative status
  ledger other documents are meant to mirror (its own docstring language: "SORRY-FREE" bullets in
  the same format used for `completeness`, `soundness`, etc.) — this keeps the two documents in
  sync rather than having `README.md` state something the ledger itself omits.
- **Recommend, low priority**: mirror the same addition as a row/line in
  `docs/project-info/implementation-status.md`'s Layer 2 Metalogic table for consistency, once
  the above two land — optional, small, not required for accuracy (the file doesn't currently
  claim anything false by omission the way a "Layer X: Not Started" row would).
- **Decision on wording discipline**: any new prose must state the Kamp result's scope precisely
  as "expressively complete for **Prior structures**" (not "for TM" or "for all task frames") and
  must not conflate the Correspondence layer's Galois-closure negative results (Dedekind/Discrete
  *not* Galois-closed — a settled, proved fact) with task 494's Dedekind-compactness open
  question (unresolved) — these are different properties of the same frame class. See Executive
  Summary.
- **Out of scope for this task**: `C6`'s manifest gap and `C9D`'s task-number-citation count in
  `docs/` are pre-existing, unrelated repo-hygiene items, not documentation-*content* staleness on
  the four result families this task covers. Not recommending they be touched here.

## Risks & Mitigations

- **Risk**: a documentation-update pass motivated by "make it comprehensive" could add prose
  claiming more than is proved (e.g., stating Kamp's theorem holds "for TM" generally, or that
  Dedekind's Galois-closure negative result settles compactness). **Mitigation**: the exact
  scope-qualifiers and theorem names are given above; use them verbatim rather than paraphrasing
  from memory.
- **Risk**: `C6` (4 unreachable live modules missing from the compile-isolation manifest) could
  be mistaken for a documentation problem because it surfaces in the same script run.
  **Mitigation**: it is a `scripts/module-invariants-manifest.txt` registration issue in test
  infrastructure — unrelated to prose accuracy in `README.md`/`docs/`, and no result-status claim
  in any audited document depends on those four modules. Flagged here for awareness only; not a
  task-516 blocker.
- **Risk**: `C9D`'s 138 task-number citations under `docs/` might tempt a broader cleanup than
  this task's scope. **Mitigation**: none of the flagged files
  (`PHASED_IMPLEMENTATION.md`, `PIPELINE.md`, `NONCOMPUTABLE.md`, `ADR-001...`, `research/README.md`)
  contain completeness/soundness/compactness/characterization claims — confirmed by their names
  and by C9D's own file-count breakdown; this is a separate, pre-existing hygiene item not
  gated on task 494 and not requested by task 516.

## Context Extension Recommendations

- **Topic**: characterization/definability results status.
- **Gap**: no `.claude/context/` entry currently indexes
  `FormalSystem/Semantics/Correspondence/` or `WeakCanonical/Kamp/KampPrior.lean`'s finished
  status for quick agent retrieval — an agent asked "what characterization results exist" would
  have to rediscover this the same way this research pass did (cross-referencing three module
  READMEs and one theorem file).
- **Recommendation**: not urgent enough to spawn separately; if a future task touches this area
  again, consider a short context file at `.claude/context/project/lean4/domain/` pointing at
  `FormalSystem/Metalogic.lean`'s "Publication-Ready Results" docstring as the single
  authoritative status ledger, once this task's additions land there.

## Appendix

### Commands run (reproducible)

```bash
bash scripts/check-module-invariants.sh          # full C1-C15, includes lake build
bash scripts/typst-status-counts.sh --json        # independent ground-truth counts
grep -rn '\bsorry\b' FormalSystem/ --include='*.lean' | grep -v '/Boneyard/'
grep -n "^theorem\|^def" FormalSystem/Metalogic/Compactness.lean
grep -n "^theorem\|^def" FormalSystem/Metalogic/DiscreteNonCompactness.lean
grep -rn "kampPriorExpressiveCompleteness" FormalSystem/ --include='*.lean' | grep -v Boneyard
grep -n "^theorem\|^def " FormalSystem/Semantics/Correspondence/Galois.lean \
  FormalSystem/Semantics/Correspondence/Indicator.lean
```

### Files read in full or in substantial part

- `FormalSystem/Metalogic.lean` (the authoritative status ledger)
- `FormalSystem/Metalogic/Compactness.lean`, `DiscreteNonCompactness.lean`
- `FormalSystem/Metalogic/WeakCanonical.lean`, `WeakCanonical/Kamp/KampPrior.lean`,
  `WeakCanonical/Kamp/README.md`, `WeakCanonical/EFGames/StaviCompleteness.lean`
- `FormalSystem/Metalogic/Independence.lean`, `Independence/README.md`
- `FormalSystem/Semantics/Correspondence/README.md`
- `README.md` (full)
- `docs/project-info/implementation-status.md`, `known-limitations.md`
- `docs/research/BIMODAL_LOGIC.md`
- `specs/TODO.md` (task 494 and 516 entries in full)
- `typst/SYNC-MAP.md` (header/legend section)

### Not yet machine-checked, cited from prose only (flagged as such, not asserted as fact)

- The paper's own claim that strong completeness "provably fails" for the Dedekind class
  (`possible_worlds.tex:4657`) — this is the paper's assertion, not yet a Lean theorem in this
  tree; task 494 is precisely the work of either machine-checking or correcting that.
