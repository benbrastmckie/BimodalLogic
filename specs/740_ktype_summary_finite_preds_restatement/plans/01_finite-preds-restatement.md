# Implementation Plan: Task #740

- **Task**: 740 - Restate three KTypeSummary declarations over [Finite sig.preds] and retire their linter suppressions
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/740_ktype_summary_finite_preds_restatement/reports/01_finite-preds-restatement.md
- **Artifacts**: plans/01_finite-preds-restatement.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Three headline theorems of the `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/` cluster —
`kType_finite` (`Basic.lean`), `exists_matching_factorization` (`Family.lean`) and
`finite_family_triples` (`Universal.lean`) — are stated over `[Fintype sig.preds]
[DecidableEq sig.preds]` binders that only their proofs consume, and each carries a declaration-
scoped `set_option linter.unusedFintypeInType false in` / `set_option
linter.unusedDecidableInType false in` pair to silence the linters that correctly report this.
The research round scratch-compiled all three restated over `[Finite sig.preds]` (with
`haveI := Fintype.ofFinite sig.preds; haveI := Classical.decEq sig.preds` supplied in the proof)
under the project's own linter set: zero warnings, axiom profile `[propext, Classical.choice,
Quot.sound]` for each, and the old pinned form of each provable as an `example` from the new one.
The plan lands those verbatim diffs (Phase 1), propagates the two prose consequences — a dangling
precedent clause in `RaySummary/Compose.lean`'s own C29 reason comment and the cluster README's
hand-maintained line counts (Phase 2) — and runs the full repository gate set (Phase 3).

### Research Integration

- **Verdict adopted: restate all three; none stays pinned.** The report established that the
  statement-fidelity constraint does not bind: the `[Fintype][DecidableEq]` forms were pinned in
  the substrate plan as plan-compliance interface, not as verified content; the same pinned block
  states its Phase-5 theorems over `[Finite sig.preds]`; `finite_family_triples` was never pinned
  at all; no challenge snapshot exists to drift against; and each old statement is an instance of
  the new one (`Finite.of_fintype`, Mathlib priority 900). The description's "partial result"
  branch (keep a pin, comment the fidelity requirement) is therefore recorded only as the per-
  declaration contingency under Rollback/Contingency, not as an expected outcome.
- **Policy already mandates the change.** `scripts/warning-budget.txt` carries a `blocking`
  disposition for both linters ("drop the unused instance from the statement and supply it in the
  proof") and `docs/development/LEAN_STYLE_GUIDE.md`'s "Traps" subsection prescribes exactly the
  `[Fintype X]` -> `[Finite X]` + `haveI` recipe, stating that `set_option … false in` hides the
  finding rather than fixing it. New prose cites those two anchors, never a task number (harness
  check C9 — zero task-number citations under `FormalSystem/`).
- **Zero consumer-code propagation.** Every in-tree call site sits in a `[Fintype sig.preds]`
  context (or a concrete `Fintype` instance: `twoLetter`, the wired evidence probe's `sig2`),
  where `Finite sig.preds` is found by instance search. The probe exercised both call shapes.
- **The verbatim diffs** (binder lists, proof preambles, which lines to delete) are taken from the
  report's Recommendations and the scratch probe
  `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/20e4b647-0c46-4812-b8c8-3b2978d42f6b/scratchpad/probe740/Probe740.lean`
  (session scratchpad; may not survive — the statements are reproduced in `## Lean Challenge
  Statements` below so the plan is self-contained).
- **Two corrections to carried figures**, re-derived at plan time: the test module holds **30**
  `#print axioms` directives (the description says eleven, the report says 33); and one wired
  evidence probe (`specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`,
  compiled by `scripts/check-evidence-probes.sh`) does call `finite_family_triples sig2 k`, under
  an explicit `Fintype sig2.preds` instance — it elaborates unchanged but is a call site to
  confirm, not "no probe targets the names".

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided to this dispatch; ROADMAP.md was not consulted. The task is a
housekeeping follow-up recorded by the universal-summary substrate work and advances no roadmap
item of its own.

## Goals & Non-Goals

**Goals**:
- `kType_finite` restated over a Finite binder on the predicate type, its two suppressions removed
- `exists_matching_factorization` restated the same way, its two suppressions removed
- `finite_family_triples` restated the same way, its two suppressions removed
- Every axiom pin in the test module still matches; every touched headline keeps the standard three-axiom profile with zero sorries
- The module-invariants harness, the evidence-probe collection and the phantom-citation sweep stay green

**Non-Goals**:
- Relocating the k-type kernel (KType, kTypeOf, KEquiv, the mixing lemma) outside WeakCanonical — a separately recorded, deliberately deferred decision
- Generalising InFamily, SegmentFactorization, family_cover, family_saturation, target_eq_union_of_families, HitSig, Hit or the Presents bundle / seam bridge: these are defs and structures (never linted) or carry the instances in their types, and the three restatements force no change to them
- Retiring the identical suppression on kTypeOf_listSeg_append_congr in RaySummary/Compose.lean — same pattern, out of scope; recorded as a follow-up in the research report
- Any new mathematics, axiom, decidability or complexity claim

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Instance mismatch in `exists_matching_factorization`'s proof: `family_cover` is applied at the locally built `Fintype.ofFinite`/`Classical.decEq` instances | M | L | Probe-verified: the projected equations `F.pos_type`/`F.neg_type`/`F.zero_type` have instance-free types, so `exact` closes the goal with no `convert`. If it nonetheless fails, fix forward with `convert … using 2` before considering the pinned-form contingency. |
| A downstream caller fails to elaborate after the signature change | M | L | All callers sit in `[Fintype]` context; `Finite.of_fintype` (priority 900) resolves them. Phase 1's `interface`-tier build enumerates every direct dependent, including the test module; Phase 3's full build and the evidence-probe gate cover the rest. |
| C29/C30 anti-silence guards (exit 2 on zero matched suppressions tree-wide) | H | L | 50 scoped `set_option linter.* false in` lines exist today; removing six leaves 44. Confirm by re-counting in Phase 3 before reading any harness red as this task's. |
| Hand-maintained README line counts drift (no `BEGIN GENERATED` marker on the `## Modules` table) | L | H | Phase 2 re-measures with `wc -l` after Phase 1 lands and updates the three rows in the same commit. |
| Dangling precedent in `RaySummary/Compose.lean`'s C29 reason comment ("as for `exists_matching_factorization` in `KTypeSummary/Family.lean`") | L | H | Phase 2 rewords the clause; the suppression itself is untouched. |
| Concurrent sibling (task 739, plan phase) on the same working tree, scope `scripts/check-evidence-probes.sh` and one `specs/evidence/…` probe | M | M | No file overlap with this task's scope. Re-read each file immediately before editing; stage only the explicit file list; never `git-snapshot.sh` in its reverting default mode; if `check-evidence-probes.sh` itself is mid-edit when Phase 3 runs it, check `git log`/`git status` for the sibling's change before attributing a red to this task. |
| New prose cites a task number under `FormalSystem/` (C9) | M | L | Cite `LEAN_STYLE_GUIDE.md`'s "Traps" subsection and `warning-budget.txt`'s disposition lines by name only; `hooks/validate-no-task-references.sh` blocks the write anyway. |
| `verify-deploy.sh` is red for a pre-existing reason (the dispatch context already flags the deployed `.claude/` tree as stale for `core`) | L | M | Run it as part of the `full` tier; a red whose findings name only `.claude/**` staleness is pre-existing and not attributable to this task — record it in the issue log and do not hand-patch `.claude/**`. The Lean-side gates are this task's acceptance criteria. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Restate the Three Declarations and Retire Their Suppressions [NOT STARTED]

**Goal**: Each of `kType_finite`, `exists_matching_factorization` and `finite_family_triples` is
stated over `[Finite sig.preds]`, with `Fintype`/`DecidableEq` supplied inside the proof, and its
two `set_option linter.* false in` lines and the comment block justifying them are gone.

**Tasks**:
- [ ] Re-read `Basic.lean` immediately before editing (sibling-task discipline). Delete the
      five-line reason comment and the two `set_option … false in` lines directly above
      `kType_finite`'s docstring. Change the binder list to
      `(sig : MonadicSignature) [Finite sig.preds] (k : ℕ)`; replace the proof body with
      `haveI := Fintype.ofFinite sig.preds` / `haveI := Classical.decEq sig.preds` / `unfold KType`
      / `infer_instance`. Rewrite the docstring's final paragraph (the sentences from "the binders
      are that site's" to "already carries") to say the statement is over `[Finite sig.preds]`
      and that `Fintype`/`DecidableEq` are supplied in the proof for `normalFormFintype`, citing
      the style guide's Traps subsection by name. Build the module; commit.
- [ ] Re-read `Family.lean` immediately before editing. Delete the five-line reason comment and
      the two `set_option … false in` lines above `exists_matching_factorization`'s docstring.
      Change the binders to `(sig : MonadicSignature) [Finite sig.preds] (k : ℕ) (c : sig.preds → ℤ → Prop)`;
      prepend the same two `haveI` lines to the existing proof body (the `obtain … := family_cover
      sig k c` / `exact ⟨…⟩` block is otherwise unchanged). Build; commit.
- [ ] Re-read `Universal.lean` immediately before editing. Delete the five-line reason comment and
      the two `set_option … false in` lines above `finite_family_triples`'s docstring. Change the
      binders to `(sig : MonadicSignature) [Finite sig.preds] (k : ℕ)`; the body
      (`haveI := kType_finite sig k` / `infer_instance`) is unchanged. Build; commit.
- [ ] Grep the cluster for any remaining mention of the retired suppressions or of the deleted
      comment blocks' phrasing ("Declaration-scoped, as for", "recorded as a follow-up") and fix
      any docstring in the three files that still describes the old binders.
- [ ] Build the enumerated direct dependents (below) through the build guard and confirm zero
      linter output for the three declarations.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: Exactly three declarations and exactly six `set_option linter.unused*InType
false in` lines are in scope in this cluster (re-derived at plan time by grep: `Basic.lean:99-100`,
`Family.lean:218-219`, `Universal.lean:128-129`; the description's `Universal.lean:110` is stale —
the declaration is at line 133). No call site needs a code edit: `kType_finite` has one in-tree
caller (`finite_family_triples`), `exists_matching_factorization` has none, and
`finite_family_triples` has three — `RaySummary/Closure.lean` `hitSig_finite`,
`RaySummary/SeamMulti.lean` `hit_finite`, and the wired evidence probe
`specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean` `hit_finite` — all in
`[Fintype]` context. Confirm at implementation time by
`grep -rn "kType_finite\|exists_matching_factorization\|finite_family_triples" FormalSystem Tests specs/evidence --include=*.lean`
before editing; a caller outside a `Fintype` context would need `[Finite sig.preds]` added and
would widen this phase's file list.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Basic.lean` - restate `kType_finite`, delete its suppression pair and reason comment, rewrite docstring tail
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Family.lean` - restate `exists_matching_factorization`, delete its suppression pair and reason comment
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Universal.lean` - restate `finite_family_triples`, delete its suppression pair and reason comment

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.WeakCanonical.KTypeSummary FormalSystem.Metalogic.Decidability.RaySummary.Closure FormalSystem.Metalogic.Decidability.RaySummary.SeamMulti BimodalTest.Metalogic.KTypeSummaryAxiomTest`
  exits 0 (check the exit status, not only the log) — the changed modules plus every enumerated
  direct dependent, including the axiom-pin module, whose `#guard_msgs` rows fail the build if a
  profile moved.
- `grep -rn "unusedFintypeInType\|unusedDecidableInType" FormalSystem/Metalogic/WeakCanonical/KTypeSummary/`
  returns nothing (exit 1).
- The build log carries no `linter.unusedFintypeInType` / `linter.unusedDecidableInType` warning
  for any of the three names (a control: the old form without suppression fires both under
  `weak.linter.mathlibStandardSet = true`, so silence here is a genuine negative).
- `lean_verify` (or `#print axioms` via the test build) on
  `FormalSystem.Metalogic.WeakCanonical.kType_finite`,
  `FormalSystem.Metalogic.WeakCanonical.exists_matching_factorization`,
  `FormalSystem.Metalogic.WeakCanonical.finite_family_triples` each report exactly
  `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- `git diff` of each file shows no edit outside the targeted declaration, its comment block, and
  its docstring.

---

### Phase 2: Propagate the Prose Consequences [NOT STARTED]

**Goal**: No comment or documentation in the tree describes the retired suppressions as still
existing, and the cluster README's hand-maintained module line counts match the tree.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` immediately before
      editing. In the C29 reason comment above `kTypeOf_listSeg_append_congr`, remove the trailing
      precedent clause "Declaration-scoped, as for `exists_matching_factorization` in
      `KTypeSummary/Family.lean`" and replace it with "Declaration-scoped." (or equivalent) so the
      reason no longer cites a suppression that no longer exists. Do NOT touch that declaration's
      own `set_option linter.unusedFintypeInType false in` line or its statement — out of scope.
- [ ] Re-measure `wc -l` on `Basic.lean`, `Family.lean`, `Universal.lean` after Phase 1 and update
      the three numeric cells in `KTypeSummary/README.md`'s `## Modules` table (hand-maintained:
      the table has no `BEGIN GENERATED: inventory` marker, so `--emit-inventory` does not own
      it). Leave every other row and every description cell unchanged.
- [ ] Read the README's step table (rows 2, 4, 5′) and the three modules' header docstrings for
      any sentence that describes the `[Fintype]`/`[DecidableEq]` binders as the cluster's
      "recorded interface"; reword only where a statement has become false.
- [ ] Diff read-through: confirm every changed hunk in this phase lies inside a comment, a
      docstring, or markdown.

**Timing**: 0.25 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: Exactly one out-of-cluster comment (`Compose.lean`, the reason block ending
"as for `exists_matching_factorization` in `KTypeSummary/Family.lean`") and exactly three README
line-count cells (today 122 / 238 / 162 for `Basic` / `Family` / `Universal`, carried from the
research report and re-measured at plan time as matching) need editing. Confirm with
`grep -rn "as for \`kType_finite\`\|as for \`exists_matching_factorization\`" FormalSystem/` (expect
only the `Compose.lean` hit after Phase 1) and `wc -l` on the three files after Phase 1.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` - reword one C29 reason comment; no code change
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - update three `## Modules` line-count cells

**Verification**:
- `git diff` for this phase shows changes only inside `--` comment lines (Compose.lean) and the
  README table's numeric cells; no Lean token outside a comment is touched.
- `wc -l` on the three modules equals the three README cells.
- `grep -rn "as for \`exists_matching_factorization\`\|as for \`kType_finite\`" FormalSystem/`
  returns nothing (exit 1).
- The `Compose.lean` reason comment still names `linter.unusedFintypeInType` on its first line
  (C29's requirement for the suppression that remains).

---

### Phase 3: Full Gate Pass [NOT STARTED]

**Goal**: The complete repository gate set is green on the changed tree, every axiom pin still
matches, and the acceptance signal — six suppressions gone, nothing weakened — is confirmed
mechanically.

**Tasks**:
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project
      build, exit 0). If a module outside this task's file scope fails, check `git status` and
      `git log` for the concurrent sibling's in-flight edit before attributing it here.
- [ ] `bash scripts/check-module-invariants.sh` exits 0. Read its C9, C14, C16, C21, C28, C29 and
      C30 lines specifically; confirm the C29/C30 anti-silence guards still see the remaining
      tree-wide suppressions (expect 44 scoped `set_option linter.* false in` lines, down from 50:
      `grep -rn "set_option linter\.[a-zA-Z.]* false in" FormalSystem/ | wc -l`).
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 (the wired
      `presents-is-seam-decidedness.lean` probe calls `finite_family_triples sig2 k` and must
      still compile).
- [ ] `bash scripts/check-phantom-citations.sh` exits 0.
- [ ] Every `#print axioms` row in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` still
      matches (the test module built green in Phase 1 and in the full build; re-confirm the count
      of `#print axioms` directives is unchanged from before the task).
- [ ] `bash .claude/scripts/verify-deploy.sh`; if red, classify: findings naming only `.claude/**`
      staleness are pre-existing (flagged in this dispatch's context) — record via
      `issue-record.sh` and do not hand-patch `.claude/**`; any other finding is this task's.
- [ ] Final acceptance greps: the cluster has zero `unusedFintypeInType`/`unusedDecidableInType`
      mentions; the three declarations each carry `[Finite sig.preds]` and no `[Fintype sig.preds]`
      / `[DecidableEq sig.preds]` binder; `grep -rn "task 740\|task #740" FormalSystem/ Tests/`
      returns nothing.
- [ ] Write the implementation summary and close out per the standard postflight.

**Timing**: 0.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: The axiom-pin module holds 30 `#print axioms` directives (re-derived at plan
time by `grep -c "^#print axioms"`; the description's "eleven" and the report's "33" are both
stale carried figures). The acceptance criterion is count-independent — every pin matches — so a
different count at implementation time changes nothing except this note; confirm with the same
grep before and after the change and record any drift in the issue log. Tree-wide scoped
suppression count after removal is hypothesised at 44 (50 − 6); confirm with the grep in the task
list before reading any C29/C30 red.

**Files to modify**:
- none planned — this phase is verification only; the summary artifact lands under `specs/`

**Verification**:
- All of: `lake-build-guard.sh build … -- build`, `scripts/check-module-invariants.sh`,
  `scripts/check-evidence-probes.sh`, `scripts/check-phantom-citations.sh` exit 0 (exit status
  checked, not stdout diffed).
- `bash .claude/scripts/verify-deploy.sh` run and its outcome classified as above.
- Axiom profile of each touched headline is `[propext, Classical.choice, Quot.sound]`; zero
  sorries (the test module's `#guard_msgs` rows are the mechanical witness).
- `git status --short` shows no stray or out-of-scope modification attributable to this task.

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.WeakCanonical.KTypeSummary

open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness

theorem kType_finite (sig : MonadicSignature) [Finite sig.preds] (k : ℕ) :
    Finite (KType sig k) := sorry

theorem exists_matching_factorization (sig : MonadicSignature) [Finite sig.preds]
    (k : ℕ) (c : sig.preds → ℤ → Prop) :
    ∃ (W : ℤ → ℤ) (τneg τzero τpos : KType sig k),
      Monotone W ∧
      (∀ t : ℤ, ∃ z, W z ≤ t ∧ t < W (z + 1)) ∧
      W 1 < W 2 ∧ W (-2) < W (-1) ∧
      (∀ z : ℤ, 0 < z → kTypeOf sig k (segZ sig c (W z) (W (z + 1))) = τpos) ∧
      (∀ z : ℤ, z < 0 → kTypeOf sig k (segZ sig c (W z) (W (z + 1))) = τneg) ∧
      kTypeOf sig k (segZ sig c (W 0) (W 1)) = τzero := sorry

theorem finite_family_triples (sig : MonadicSignature) [Finite sig.preds] (k : ℕ) :
    Finite (KType sig k × KType sig k × KType sig k) := sorry
```

These are the exact post-change signatures (conclusions byte-identical to the current tree; only
the instance binders change). Each is strictly stronger than the current `[Fintype sig.preds]
[DecidableEq sig.preds]` form, which is derivable from it by `Finite.of_fintype`.

## Testing & Validation

- [ ] Phase 1 `interface` build (changed modules + enumerated dependents + axiom-pin module) exits 0
- [ ] Zero `unusedFintypeInType`/`unusedDecidableInType` mentions remain under `KTypeSummary/`
- [ ] Axiom profile `[propext, Classical.choice, Quot.sound]`, no `sorryAx`, for all three names
- [ ] Every `#print axioms` row in `KTypeSummaryAxiomTest.lean` matches (test module builds)
- [ ] Full `lake build` exits 0
- [ ] `scripts/check-module-invariants.sh`, `scripts/check-evidence-probes.sh`, `scripts/check-phantom-citations.sh` exit 0
- [ ] `verify-deploy.sh` run and classified
- [ ] README `## Modules` cells equal `wc -l`; `Compose.lean` reason comment no longer cites a retired suppression
- [ ] No task-number citation introduced under `FormalSystem/` or `Tests/`

## Artifacts & Outputs

- Three restated theorems in `KTypeSummary/{Basic,Family,Universal}.lean`, six suppressions and
  three reason-comment blocks removed, one docstring tail rewritten
- One reworded comment in `RaySummary/Compose.lean`; three refreshed cells in `KTypeSummary/README.md`
- `specs/740_ktype_summary_finite_preds_restatement/summaries/01_finite-preds-restatement-summary.md`
- Per-phase commits via `.claude/scripts/git-commit-scoped.sh` with explicit file lists (never a
  directory or glob pathspec), message form `task 740 phase {P}: {name}`

## Rollback/Contingency

- **Per-declaration contingency (the description's sanctioned partial outcome)**: if, contrary to
  the probe, one restatement cannot be made to compile with an unchanged conclusion, leave THAT
  declaration in its current `[Fintype][DecidableEq]` form, keep its suppression pair, and replace
  its reason comment with one naming the concrete obstruction (the elaboration failure, not
  "fidelity" — the research established fidelity does not bind). Do not weaken any statement to
  quiet a linter. The other declarations proceed independently; a mixed outcome is acceptable and
  must be recorded in the summary.
- **Phase-level rollback**: every phase commits per green sub-step, so reverting is a `git revert`
  of the offending commit(s). Never `git-snapshot.sh` in its default reverting mode while the
  sibling task shares the tree; an ordinary defensive checkpoint before a risky step is
  `bash .claude/scripts/git-snapshot.sh --no-revert 740`.
- **Gate red outside scope**: a failure in a file outside this plan's `Files to modify` is first
  checked against `git log`/`git status` for the concurrent sibling's in-flight work before being
  treated as this task's regression.
