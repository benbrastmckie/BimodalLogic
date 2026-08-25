# Implementation Evidence Ledger: Task #468

**Purpose**: durable record of every fact later phases of this task's implementation cite,
established fresh at implementation time (2026-08-25) rather than inherited from report 02
(2026-08-25T11:00-12:00Z, ~hours earlier) without independent re-confirmation. Later phases
append sections rather than re-running these checks.

**Standards**: report-format.md, subagent-return.md

---

## Phase 1 — Baseline re-verification

### C2/C3/C4/C5/C7 — full `check-module-invariants.sh` run, this dispatch

```
$ bash scripts/check-module-invariants.sh
=== Module invariants: 391e9928f ===

PASS  B0   Boneyard exclusion covers exactly 1 directory
PASS  C1   lake build exits 0
PASS  C1   lake build BimodalTest exits 0

PASS  C2   all four flagship axiom sets match baseline
            'FormalSystem.Metalogic.BXCanonical.completeness' depends on axioms: [propext, Classical.choice, Quot.sound]
            'FormalSystem.Metalogic.BXCanonical.completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
            'FormalSystem.Metalogic.BXCanonical.completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
            'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]

PASS  C3   structural sorry inventory is ZERO across FormalSystem/ (Boneyard/ excluded)

PASS  C4   all 1438 FormalSystem/BimodalTest import lines resolve
PASS  C5   all module-shaped paths in 1662 markdown files resolve (4 allowlisted)
PASS  C6   all 22 unreachable live module(s) are manifested
PASS  C7   467 live .lean files (413 FormalSystem / 53 Tests); 445 reachable, 22 unreachable
PASS  C8   every FormalSystem/ and Metalogic/ subdirectory has exactly one sibling aggregator
PASS  C11  all 497 archived import lines in 156 archived file(s) resolve (6 waived)
PASS  C9   zero task-number citations under FormalSystem/
PASS  C10  zero references to FormalSystem/{docs,latex,typst} outside specs/

ALL CHECKS PASSED
```

Both `lake build` and `lake build BimodalTest` exit 0. C2's four flagship axiom sets are
identically clean (`[propext, Classical.choice, Quot.sound]`, no `sorryAx`) to report 02's
recording. C3's structural sorry inventory is zero. This is a fresh, independent re-run at
implementation time, not a restatement of report 02.

### Six Stage 1(a) claims, re-confirmed by symbol name

1. **No declaration takes `DecisionProcedure.isValid` as its subject.** `grep -rn "isValid"
   FormalSystem/Metalogic/Decidability/` (Boneyard excluded) shows only: `DecisionResult.isValid`
   (`DecisionProcedure.lean:93`, `Bool`-valued wrapper), `DecisionProcedure.isValid`
   (`DecisionProcedure.lean:317-318`, `def isValid (φ) (fc) : Bool := (decide φ (fc :=
   fc)).isValid`), the case-exhaustion lemma over the four-constructor result type
   (`Correctness.lean:122-126`, pure `simp`), and `truthAt_of_isValid`
   (`Verified/Decidable.lean:2412`) — which is about `SoundnessLemmas.IsValid`, a semantic-side
   predicate distinct from `DecisionProcedure.isValid`. No theorem has
   `DecisionProcedure.isValid _ = true` as hypothesis or conclusion. **CONFIRMED, unchanged.**
2. **`ruleSound_of_mem_allRulesForFC` is not lifted; no `allClosed → valid` exists.**
   `ruleSound_of_mem_allRulesForFC` (`Verified/Decidable.lean:3155`) is real, unique, cited only
   in prose (`Correctness.lean:93`, README files). `grep -rn "allClosed"` over
   `Verified/Decidable.lean` and `Saturation.lean` finds only prose usages and
   `upgrade_allClosed`/`buildTableauAt_allClosed_imp`-style statements, none stating branch
   satisfiability. **CONFIRMED, unchanged.**
3. **`serialityRule`/`timeLinearity` excluded from `allRulesForFC`, no `RuleSound` obligation
   discharged for either.** `serialityRule_not_mem_allRulesForFC` and
   `timeLinearity_not_mem_allRulesForFC` both proved at `Verified/RuleSpec.lean:337,342`.
   **CONFIRMED, unchanged.**
4. **`Verified/Refutation/` does not exist.** `ls
   FormalSystem/Metalogic/Decidability/Verified/Refutation/` → "No such file or directory".
   **CONFIRMED, unchanged.**
5. **`ProofExtraction.lean` has zero theorems; `verifyProof` is constantly `true`.**
   `ProofExtraction.lean:345`: `def verifyProof (_phi : Formula) (_proof : DerivationTree .Base []
   _phi) : Bool := true`. `grep -n "^theorem\|^lemma"` on the file: no output. **CONFIRMED,
   unchanged.**
6. **`countermodel_discrete` as "the only live structural sorry" — STALE.** `grep -rn
   --include='*.lean' -E '^\s*sorry\s*$' FormalSystem/ | grep -v Boneyard` — empty output, zero
   live structural sorries anywhere in the tree. C3 (above) independently confirms zero.
   **CONFIRMED STALE — this is the correction, grounded in C2/C3 fresh this dispatch, not
   restated.** The soundness/completeness metatheory front (charter's F7) is DONE, axiom-clean
   for all four frame classes, modulo the Kamp `k ≤ 1` scope caveat and the propositional-fragment
   note (both unaffected by this correction).

### Box-anchor artifact prerequisites (probe NOT re-run, per amendment 10a)

- All four named probes live: `Tests/BimodalTest/BoxSpreadProbe.lean`, `RegionGateProbe.lean`,
  `RayRegionProbe.lean`, `TemporalWitnessProbe.lean` (confirmed by `ls`).
- `BoxSpreadProbe.lean` carries five `#guard_msgs` blocks at lines 168, 177, 185, 221, 229,
  pinning the post-fix `false` verdicts.
- `lake build BimodalTest` exits 0 (see C1 above, this dispatch) — the guard blocks still hold.
- **Verdict: NEGATIVE**, cited from `specs/archive/418_.../artifacts/boxanchored-finding.md`, not
  re-derived. The decidable-branch-gate family (`boxAnchoredCheck`, `boxGridCheck`, `regionGate`,
  `regionLabelCheck`, `rayUpOk`/`rayDnOk`) collapses to `false` on any branch minting a world.
  **Task 429 is a redesign, not a repair.** Probe not re-run, per amendment 10a.

### Task 470 item (G) — 177's `file_scope`

`jq -c '.active_projects[] | select(.project_number==177) | .file_scope' specs/state.json` →
`["README.md","specs/ROADMAP.md","FormalSystem/","docs/"]` — resolvable, no duplicate.
**CONFIRMED repaired; not redone.**

### Task 472/473 spot-check

Both `completed` (`jq` confirmed). Spot-checked file existence for a sample of 472's nine named
files (`Verified/README.md`, `FMP/README.md`, `DecisionProcedure.lean`,
`Verified/Decidable.lean`, `WeakCanonical.lean`, `RealModel/ShuffleReal.lean`,
`Metalogic/Soundness.lean`, `WeakCanonical/PriorExpressivenessDense.lean` — the latter two at
paths one directory level different from a naive guess, both confirmed present by `find`) — all
present. 473's deletion confirmed landed: `grep -rn "neg_2var_vec_ea\|reflatten_neg_step"
FormalSystem/` (Boneyard excluded) returns only doc/comment references inside
`Prop42Vacuity.lean`/`Prop42Contentful.lean`/`EANegationClosure.lean`/`NfMultiAnchorBridge.lean`
recording the deletion as history — no live declaration of either symbol remains.

### `specs/state.json` recomputation

- `active_projects | length` = **48** (matches report 02's measurement; confirmed unchanged
  across the 13-sibling-agent session per the plan's Scope Hypothesis).
- `next_project_number` = **480** (matches report 02's measurement; confirmed unchanged).
- Status breakdown (fresh `jq` tally, this dispatch): `blocked=3, completed=16, implementing=1,
  not_started=20, partial=5, planned=1, researched=2`. Sums to 48. (Task 468 itself now shows
  `implementing` rather than report 02's `researching`, since this task has advanced a stage —
  the only breakdown delta from report 02, and expected.)
- `.metadata.total_tasks` = 42, `.task_counts.total` = 42 — both still wrong against the live 48,
  confirming report 02's finding is unchanged. `.task_counts` = `{blocked:3, implementing:1,
  not_started:31, partial:5, planned:1, researched:1, active:42, total:42}` — internally
  inconsistent with the live breakdown above (`not_started` alone is 20 live vs. 31 recorded;
  `completed`/`researched=2` have no matching keys). Repair deferred to Phase 6.

### Dangling-edge scan (zero-padded)

Built the valid-ID union from `active_projects` (48 entries, all statuses) plus
`specs/archive/state.json`'s `archived_projects` + `completed_projects` (405 entries), zero-padded
to 4 digits before any `sort`/`comm` (avoiding the lexicographic-vs-numeric mismatch that produced
50 false positives in an earlier, unpadded run per report 02's Appendix). Union: 453 valid IDs.
Every one of the 50 distinct dependency targets across `active_projects` (`jq -r
'.active_projects[] | .dependencies[]?'`, zero-padded, deduplicated) is a member of this union.

**Result: zero dangling edges.** Padding requirement recorded here so the 50-false-positive
artifact is not rediscovered downstream.

### Hard-constraint check for this phase

`git diff --stat` at end of Phase 1: no `.lean` file touched (only this ledger file and
`.return-meta.json` written).

---
