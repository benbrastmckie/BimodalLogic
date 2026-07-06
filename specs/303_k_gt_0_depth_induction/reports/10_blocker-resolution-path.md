# Blocker Resolution Path: Task 303 (k_gt_0_depth_induction)

**Task**: 303
**Session**: sess_1783306400_33dd64
**Date**: 2026-07-05
**Reference Grounding Tier**: Tier 3 (implementation-backed) — the decisive evidence is the
current codebase state, cross-checked against Rabinovich 2014 and task 305's audit.
**Effort flag**: hard (H2/H3/H4)

## Decision: (a) SUBSUMPTION — already physically realized

The six PriorComposition.lean sorries described in task 303's `.orchestrator-handoff.json`
**no longer exist on the live path**. The file that hosted them, `PriorComposition.lean`, was
archived wholesale to `Theories/Bimodal/Boneyard/KampBypassArchive/` by task 305 (commits
`3413d0292` "archive PriorComposition.lean, create slim replacement" and `32b4fae37`
"task 305 phase 0: archive bypass infrastructure to Boneyard"). The entire NF-based
cross-structure-transfer architecture that task 303 pursued has been superseded by task 305's
faithful-Rabinovich rebuild.

Therefore the resolution is **not** to close the six sorries (there are no live declarations to
close) and **not** a direct fix or a corrected `nvar_transfer` statement. The resolution is
administrative: **declare task 303 dependent on task 305 and re-scope it to a subsumption /
cleanup task.** No Lean proof dispatch is required for task 303.

The handoff that framed this blocker is **stale**: it was written against a codebase state that
task 305 has since replaced.

### Why not (b) DIRECT FIX

Option (b) is moot and mis-targeted:
1. **No live target exists.** `nvar_transfer_from_1var_agree` and
   `prior_nonconstenv_2var_agree_until/since` survive only in three Boneyard files
   (`PriorComposition.lean`, `PriorComposition_old.lean`, `KampBypassK1.lean`), none of which is
   imported by any live module. Proving them would not affect `completeness_discrete`.
2. **The architecture is refuted, not merely stuck.** Report 20 (§4, §5.2) concluded
   cross-structure witness transfer on non-constant environments is the wrong abstraction after
   10+ failed dispatches. Task 305's Phase 4 audit independently re-derived the same verdict from
   a different angle: the per-model existential statement (`∃ v, v.holds env ↔ eval φ`) — the
   convention `nvar_transfer`/`neg_vec_ea_m` are built on — is **vacuous** (closable by `tt`/`ff`
   for any formula). Two independent audits converging on "this shape is wrong" rules out a
   bounded direct fix.

### Why not (c) CORRECTED TARGET (for task 303)

The corrected target has already been identified — but it is **task 305's territory, not 303's**.
Task 305's Phase 4 handoff establishes that the faithful replacement is the **uniform** Prop 4.3
`translate : MonadicFormula sig m → VVecEA_m m` with a model-independent correctness iff, gated on
three pieces (complete arity-m conjunction / Lemma 3.2(1); Lemma 3.4 arbitrary-position existential
closure; model-independent Prop 4.2 negation). Per the delegation constraint, this report does
**not** design that mechanization. Task 303 does not own a corrected lemma; its contribution is
subsumed by 305's `KampPrior.lean:391/:394` re-anchor (305 plan v37 Phase 5).

## Reverse-Dependency Analysis of the Six Sorries

All six sorries lived in `PriorComposition.lean`. Reverse-dependency scan of the live tree
(`Theories/Bimodal/`, excluding `Boneyard/`):

| Sorry (per 303 handoff) | Host declaration | Live callers | On live path to `completeness_discrete`? |
|---|---|---|---|
| PriorComposition:459/462 | `nvar_transfer_from_1var_agree` | **none** (only Boneyard) | No — file archived |
| PriorComposition:554/559 | `prior_nonconstenv_2var_agree_until` | **none** (only Boneyard) | No — file archived |
| PriorComposition:610/614 | `prior_nonconstenv_2var_agree_since` | **none** (only Boneyard) | No — file archived |

Supporting evidence (all commands run against HEAD `9cc74741b`):
- `ls Kamp/PriorComposition.lean` → **No such file** on the live path.
- `grep -rn "import.*Boneyard" Theories/Bimodal/ --include=*.lean` (outside `Boneyard/`) → **empty**.
  The archive is imported by nothing.
- `grep -rn "PriorComposition" BXCanonical/ WeakCanonical/` (outside `Boneyard/`) → **empty**.
  The completeness chain does not reference it.
- The three lemma names resolve **only** to files under `Boneyard/KampBypassArchive/`.

Conclusion: the six sorries are already dead code, off the live path, with zero live consumers.

## Current Live State (ground truth at HEAD)

- **`completeness_discrete`** is defined in `BXCanonical/Completeness.lean`. Its Kamp/Prior arm now
  routes through `Kamp/KampPrior.lean` (consumed live via `WeakCanonical/PriorExpressiveness.lean`),
  **not** through the archived PriorComposition path.
- **The live Kamp/Prior sorries are exactly two**: `KampPrior.lean:391` (n=1, the critical
  `nf_nvar_exist_all_depths` arm) and `KampPrior.lean:394` (n≥2, documented off critical path).
  These are task **305's** `nf_nvar_exist_all_depths` artifact — not relocated 303 lemmas — and are
  the explicit target of 305 plan v37 Phase 5 (re-anchor through Prop 4.3 + Prop 3.5) / Phase 6.
- Task 305 is itself currently **[BLOCKED]** at Phase 4 (non-vacuous uniform Prop 4.3). A separate
  research dispatch on that blocker is running concurrently; this report does not duplicate it.
- (For situational awareness only — outside 303's scope: the wider `Theories/Bimodal/` tree carries
  other unrelated sorries in TruthLemma, StaviCompleteness, ChronicleToCountermodel, CaseAnalysis,
  Bundle/*, EANegation. None belong to task 303.)

## Declarations: Retired vs Kept

The team lead asked which declarations get retired vs kept. Because 305 Phase 0 already archived
the whole file, the "retire" action is **already done** — the table records the realized state:

| Declaration | Status | Location now |
|---|---|---|
| `nvar_transfer_from_1var_agree` | RETIRED (archived) | `Boneyard/KampBypassArchive/PriorComposition_old.lean` |
| `prior_nonconstenv_2var_agree_until` | RETIRED (archived) | `Boneyard/KampBypassArchive/PriorComposition*.lean` |
| `prior_nonconstenv_2var_agree_since` | RETIRED (archived) | `Boneyard/KampBypassArchive/PriorComposition*.lean` |
| `prior_2var_transfer_until/since` | RETIRED (archived) | `Boneyard/KampBypassArchive/` |
| `exist_transfer_from_full_agree`, `reconstruction_depth_agree`, etc. (sorry-free infra) | RETIRED (archived with the file; not reused by 305) | `Boneyard/KampBypassArchive/` |
| Forward NF infra `ExistsForallNF`, `NfToVecEA`, `NfDepth0Generalized` | KEPT (live, sorry-free) | `Kamp/` — imported by `KampPrior.lean` |

No live declaration from the 303 cross-structure-transfer architecture remains to be retired.

## Concrete Next-Dispatch Definition (re-scope, not a proof dispatch)

Task 303 needs **no Lean dispatch**. The concrete actions:

1. **Add dependency**: set task 303 `dependencies: [305]` in `state.json`.
2. **Re-scope the task description** to (verbatim suggested text):

   > Task 303's NF-based depth-induction / cross-structure-transfer path (PriorComposition.lean,
   > KampBypass zone-3) diverged from Rabinovich 2014 and was refuted after 10+ dispatches. Task
   > 305 archived that entire path to `Boneyard/KampBypassArchive/` (Phase 0) and is rebuilding
   > the faithful-Rabinovich route (Prop 4.3 + Prop 3.5) that re-anchors `KampPrior.lean:391/:394`.
   > Task 303's completeness contribution is therefore **subsumed by task 305**. Task 303 has no
   > independent live sorry to close. On task 305 completing its Phase 5/6 (clearing
   > KampPrior:391/:394), task 303 is closeable as a documentation/cleanup step: verify no live
   > module imports `Boneyard/KampBypassArchive/`, optionally delete the archive, and record the
   > closure note.

3. **Status**: move 303 from `blocked` → `researched` (this dispatch), pending 305. When 305 lands
   Phase 5, 303 can go straight to a short cleanup implementation (no research/plan re-loop needed).

**Optional cleanup dispatch** (only after 305 Phase 5/6 is GREEN): delete
`Theories/Bimodal/Boneyard/KampBypassArchive/{PriorComposition.lean, PriorComposition_old.lean,
KampBypassK1.lean}` and re-run `lake build` to confirm no regression. ~1 dispatch, <50 lines
(deletions), 0 new proof obligations.

## Line / Dispatch Estimates

| Path | Lean proof dispatches for 303 | Lines for 303 | Notes |
|---|---|---|---|
| (a) Subsumption (chosen) | **0** | 0 | 303's proof work is entirely in 305; 303 closes via cleanup |
| (b) Direct fix (rejected) | ∞ / undefined | n/a | No live target; refuted architecture |
| (c) Corrected target (rejected for 303) | belongs to 305 | n/a | Uniform Prop 4.3; 305's blocked Phase 4 |
| Optional 303 cleanup (post-305) | 1 | <50 (deletions) | Delete Boneyard archive, `lake build` |

## Adversarial Self-Verification

| Claim | Source/Counterexample | Verdict |
|---|---|---|
| The 6 PriorComposition sorries are off the live path | `ls Kamp/PriorComposition.lean` → No such file; `grep import.*Boneyard` outside Boneyard/ → empty; the 3 lemma names resolve only under `Boneyard/KampBypassArchive/` | VERIFIED |
| `completeness_discrete` does not depend on PriorComposition | `grep -rn PriorComposition BXCanonical/ WeakCanonical/` (excl. Boneyard) → empty; `completeness_discrete` in `BXCanonical/Completeness.lean`; live Kamp arm routes via KampPrior ← PriorExpressiveness | VERIFIED |
| The archival was done by task 305, not by 303 | `git log --oneline` → `3413d0292 task 305: archive PriorComposition.lean, create slim replacement`; `32b4fae37 task 305 phase 0: archive bypass infrastructure to Boneyard` | VERIFIED |
| The live Kamp sorries are exactly KampPrior:391/:394 | `grep -n sorry KampPrior.lean` → lines 391, 394 (tactic sorries); `sed 385,395` shows n=1 critical arm (:391) + n≥2 off-path (:394) — the `nf_nvar_exist_all_depths` artifact | VERIFIED |
| KampPrior:391/:394 are 305's artifact, not relocated 303 lemmas | 305 plan v37 §Overview + Phase 5 name them as `nf_nvar_exist_all_depths` (:391) targets; 305 handoff lists them as its baseline live-path sorries; they are structurally different (NF-depth recursion, not cross-structure transfer) | VERIFIED |
| Option (b) direct fix is not merely hard but architecturally refuted | Report 20 §5.2 (10+ failed dispatches, wrong abstraction); 305 Phase 4 handoff independently proves the per-model existential framing is vacuous (`tt`/`ff` close it for any φ) — two independent audits converge | VERIFIED |
| A corrected target exists but belongs to 305 | 305 Phase 4 BLOCKER: uniform `translate : MonadicFormula sig m → VVecEA_m m` with model-independent iff, gated on Lemma 3.2(1)/Lemma 3.4/Prop 4.2-backward — explicitly 305's blocked research territory | VERIFIED (scope-excluded per delegation) |
| Task 303 needs 0 Lean proof dispatches | Follows from: no live target (row 1) + subsumption realized (rows 3–5) + corrected target owned by 305 (row 7) | VERIFIED |

**Contradiction log**: The task-303 handoff's sorry inventory (6 sorries in PriorComposition.lean)
contradicts the current filesystem (file archived, 0 live). Resolution via precedence: **live
codebase state at HEAD > stale handoff JSON.** The handoff was authored before task 305's Phase 0
archival and has not been refreshed. No unresolved contradiction remains.

**Recommendations modified after verification**: The initial reading of the delegation (which
listed (a)/(b)/(c) as roughly co-equal options, with (a) framed as a *future* subsumption "after
305 Phase 5 lands") was strengthened: the subsumption is **already physically realized** at the
file level (305 Phase 0), not contingent on 305 Phase 5. 303 is unblocked *now* for re-scoping; only
the optional Boneyard deletion waits on 305 Phase 5/6.
