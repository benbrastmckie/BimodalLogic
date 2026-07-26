# Archivability Verdicts for the 12 Live `sorry` Instances

**Task**: 393 — Review archivable sorries to Boneyard
**Type**: lean4 (analysis and decision; no proof effort, no file moves performed)
**Date**: 2026-07-26
**Baseline**: `lake build` green (1877 jobs). Module roots are `Bimodal.*` (lakefile `srcDir := "Theories"`, `roots := #[`Bimodal]`).

---

## Executive Summary

| Verdict | Count | Sorries |
|---------|------:|---------|
| (a) ARCHIVE — zero live consumers | 11 | 7 in `Bundle/SuccRelation.lean`, 3 in `Bundle/SuccExistence.lean`, 1 in `Chronicle/ChronicleToCountermodel.lean` |
| (b) KEEP AND PROVE — load-bearing | 1 | `WeakCanonical/Transfer.lean:1283` `countermodel_discrete` |
| (c) KEEP AS EXPLICIT AXIOM | 0 | none — see "Why category (c) is rejected" |

**The single load-bearing sorry is `WeakCanonical.countermodel_discrete`.** It is the sole
`sorryAx` source of `Bimodal.Metalogic.BXCanonical.completeness` (and its alias
`completeness'`). Every other live sorry is genuinely dead.

**Two documentation defects were found and must be corrected by any follow-up work:**

1. **`ChronicleToCountermodel.lean:62-71` is stale.** Its in-file note justifies keeping the
   `chronicle_gap_contradiction` chain because it "is still called by
   `cantor_bfmcs_discrete_restricted_tc/fuc`, used by `countermodel_discrete_enriched` in
   Completeness.lean and Transfer.lean". `countermodel_discrete_enriched` no longer exists —
   it was archived to `Boneyard/DeadChronicleGapElimination/TransferDead.lean` (see the
   tombstone comment at `Completeness.lean:300`). The chain's two current head consumers,
   `dd_countermodel_chronicle_discrete` and `countermodel_discrete_reynolds`, each have **zero
   consumers**. The stated reason for retention no longer holds.

2. **`Completeness.lean:372` overstates cleanliness.** It says "The Reynolds pipeline … is fully
   discharged". Machine check: `WeakCanonical.countermodel_discrete_reynolds` **is
   `sorryAx`-tainted**. The live discrete path is the *different* theorem
   `countermodel_discrete_reynolds_v2` (`IntegerModel/ReynoldsBridge.lean:730`), which is clean.
   `countermodel_discrete_reynolds` (Transfer.lean:1222) has zero consumers and is itself dead.

---

## Method and Evidence Base

Four independent instruments, all run against the current tree:

**1. `#print axioms` on the headline theorems** (`lake env lean` over a scratch file importing
`Bimodal.Metalogic.Metalogic`):

```
completeness                      : [propext, sorryAx, Classical.choice, Quot.sound]
completeness'                     : [propext, sorryAx, Classical.choice, Quot.sound]
completeness_dense                : [propext, Classical.choice, Quot.sound]      -- clean
completeness_discrete             : [propext, Classical.choice, Quot.sound]      -- clean
countermodel_discrete             : [propext, sorryAx]
countermodel_discrete_reynolds    : [propext, sorryAx, Classical.choice, Quot.sound]
countermodel_discrete_reynolds_v2 : (clean — completeness_discrete depends on it and is clean)
cantor_bfmcs_discrete_restricted_tc  : [propext, sorryAx, Classical.choice, Quot.sound]
cantor_bfmcs_discrete_restricted_fuc : [propext, sorryAx, Classical.choice, Quot.sound]
cantor_bfmcs_discrete_restricted_buc : [propext, Classical.choice, Quot.sound]   -- clean
dd_countermodel_chronicle_discrete   : [propext, sorryAx, Classical.choice, Quot.sound]
```

Note `countermodel_discrete`'s axiom set is `[propext, sorryAx]` only — no `Classical.choice`,
no `Quot.sound`. That is the signature of a *direct terminal* `sorry`: the theorem's body is a
bare `sorry` and it inherits no other sorried lemma. Its taint is its own.

**2. Whole-environment `sorryAx` taint scan.** A `run_cmd` over all 19,442 `Bimodal.*` constants
calling `Lean.collectAxioms` found **exactly 47 tainted declarations**. Full list preserved
below (Appendix A). The taint partitions cleanly into three closed islands plus the
`completeness` head:

- 36 declarations inside `Bundle/SuccRelation.lean` + `Bundle/SuccExistence.lean`
- 8 declarations in the `chronicle_gap_contradiction` chain (Chronicle + Transfer)
- `countermodel_discrete`, `completeness`, `completeness'`

**3. Word-boundary grep for every candidate declaration** across `Theories/` and `Tests/`
excluding `Boneyard/`, with docstring/comment hits separated from code hits.

**4. Exhaustive per-declaration external-usage sweep of `SuccExistence.lean`**: all 72
declarations in the file were extracted and each grepped across the tree outside its own file.
Result: **five hits, all inside comments**; zero code references.

**Instrumentation caveat (recorded for reproducibility).** A reverse-dependency BFS over
`Expr.getUsedConstants` was attempted first and gave systematically wrong answers (it reported
`countermodel_discrete` as having zero consumers). Cause: under Lean 4.33's module system,
`ConstantInfo.value?` returns `none` for **imported theorems** — proof bodies do not cross module
boundaries (this is exactly why `Lean/Util/CollectAxioms.lean` maintains a pre-computed
`exportedAxiomsExt` per-module extension). Value-level dependency graphs therefore cannot be
built from a downstream file. Any future tooling for this repo must use `collectAxioms` plus
textual analysis, not `value?` traversal. Definitions (`def`/`noncomputable def`) *do* retain
values, which is why the broken run still found `constrained_successor_seed_consistent`'s seven
consumers — a partial result that could easily have been mistaken for a complete one.

---

## Per-Sorry Verdicts

### Group A — `Bundle/SuccRelation.lean`, 7 sorries → **ARCHIVE**

| Line (sorry) | Declaration | Code consumers |
|---:|---|---:|
| 564 | `until_unfold_in_mcs` | 0 |
| 573 | `since_unfold_in_mcs` | 0 |
| 597 | `until_persists_through_succ` | 0 |
| 621 | `or_until_in_mcs` | 0 |
| 635 | `or_since_in_mcs` | 0 |
| 646 | `g_content_subset_mcs` | 0 |
| 654 | `h_content_subset_mcs` | 0 |

**Evidence.** Each name appears in the tree exactly once as a definition site; every other
occurrence is inside a docstring or a `--` comment (`TemporalCoherence.lean:471`,
`UntilSinceCoherence.lean:42`, `SuccRelation.lean:626`). In the 47-name taint scan, each of the
seven appears **only as itself** — no downstream declaration inherits its taint.

**Why they are dead.** All seven are explicitly tombstoned in their own docstrings: they were
proved under BX1/BX8/BX9 (reflexive `G`, reflexive Until/Since introduction, Until/Since
elimination), all of which were removed as unsound under the current open-guard `(t,s)`
irreflexive semantics. `g_content_subset_mcs` (`G φ ∈ u → φ ∈ u`) and `h_content_subset_mcs` are
not merely unproven — they are **false** under irreflexive semantics; they are precisely the
T-axiom for `G`/`H` that `Boneyard/TAxiomDependentCode/` already documents as unsound. The
original proofs are already in `Boneyard/OpenGuardInvalid/`.

**Archival unit.** Lines **549–654** of `SuccRelation.lean` are a contiguous block: the
`/-! ## Until/Since Step Properties -/` section header at 551 through `h_content_subset_mcs`,
ending immediately before `end Bimodal.Metalogic.Bundle` at 656. The rest of `SuccRelation.lean`
(`Succ`, the f/p/g/h-step lemmas) is live — consumed by `ChronicleToCountermodel.lean`,
`GoodStructures.lean`, `CanonicalTaskRelation.lean`, `UntilSinceCoherence.lean` — so this is a
**declaration-excision**, not a file move. It matches the existing `SorriedDeclExcisions`
convention (imports verbatim, `ARCHIVED (Boneyard)` docstring, `#exit`, code verbatim).

---

### Group B — `Bundle/SuccExistence.lean`, 3 sorries → **ARCHIVE (whole file)**

| Line (sorry) | Enclosing declaration | Immediate consumers |
|---:|---|---|
| 452 | `constrained_successor_seed_consistent` | 7, all in-file |
| 755 | `successor_deferral_seed_consistent_axiom` | `successor_deferral_seed_consistent` → … → `successor_exists` |
| 829 | `predecessor_deferral_seed_consistent_axiom` | `predecessor_deferral_seed_consistent` → … → `predecessor_exists` |

**Evidence.** The three sorries taint a 36-declaration closure (see Appendix A) that is
**entirely contained in `SuccRelation.lean` + `SuccExistence.lean`**. No declaration outside
those two files inherits their taint — which is a stronger statement than grep alone: if any
Chronicle or WeakCanonical declaration consumed `successor_exists`, it would appear in the
47-name tainted set, and none does.

The file's two headline results, `successor_exists` (line 981) and `predecessor_exists`
(line 1126), have **zero code consumers anywhere**. The exhaustive 72-declaration sweep found
external references only in comments:

```
SuccRelation.lean:443,480,491  -- prose about pastDeferralDisjunctions / predecessor_deferral_seed
SuccRelation.lean:509,516      -- prose about predecessor_from_deferral_seed / _satisfies_p_step
CanonicalTaskRelation.lean:694 -- prose about predecessor_satisfies_p_step
```

`Core/RestrictedMCS/Basic.lean:13` does `import Bimodal.Metalogic.Bundle.SuccExistence` but uses
no declaration from it — a stale import edge, not a dependency. (Note
`Boneyard/RestrictedMCSDeferral/` already archives the deferral-restricted MCS variant of this
same successor-seed construction as having "no live consumers"; this file is the remaining half
of that same dead approach.)

**Root cause is shared with Group A.** All three sorries are literally the same hole:

```lean
have h_g_content_in_u : g_content u ⊆ u := by
  sorry            -- SuccExistence.lean:452 and :755
have h_h_content_in_u : h_content u ⊆ u := by
  sorry            -- SuccExistence.lean:829
```

That is `g_content_subset_mcs` / `h_content_subset_mcs` inlined. Each of the three enclosing
docstrings still asserts "**Status**: PROVEN under BX1 (reflexive G)" — stale text from before
BX1 was removed. The proof route is invalid under the current semantics.

**Archival unit.** The entire file `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
(1,178 lines, 72 declarations, zero live consumers). Also delete the dead import line at
`Core/RestrictedMCS/Basic.lean:13`.

---

### Group C — `Chronicle/ChronicleToCountermodel.lean:208` `chronicle_gap_contradiction` → **ARCHIVE (as a chain, not a single declaration)**

**The lead in the task description is confirmed: this is a leftover the earlier archival pass
missed.** `Boneyard/README.md` already lists `DeadChronicleGapElimination` (2 files, 1,013 lines)
archived for "the `chronicle_gap_contradiction` sorry chain", yet the sorry is still live.

**Chain, verified by grep at each edge and cross-checked against the taint set:**

```
chronicle_gap_contradiction  (private, ChronicleToCountermodel.lean:200, sorry at :208)
  → succ_cofinal                        (private, :495; call site :502)
  → limitDomSubtype_isSuccArchimedean   (:509)
  → succ_embed_surjective               (:1384; letI binding at :1391)
  → cantor_bfmcs_discrete_restricted_tc (:1710) and _fuc (:1766)
  → dd_countermodel_chronicle_discrete  (:1854)          — 0 consumers
  → countermodel_discrete_reynolds      (Transfer.lean:1222) — 0 consumers
```

Both heads are dead. `dd_countermodel_chronicle_discrete` is referenced only from comments
(`WeakCanonical.lean:49`, `Transfer.lean:30,1220,1292`). `countermodel_discrete_reynolds` is
referenced only from comments (`Transfer.lean:24,1191,1204,1279,1295`) — and note
`Transfer.lean:1191` asserts it "is now sorry-free", which `#print axioms` refutes.

The live discrete completeness path does **not** touch this chain: `completeness_discrete`
(`Completeness.lean:354`) calls `countermodel_discrete_reynolds_v2`
(`IntegerModel/ReynoldsBridge.lean:730`), whose header states it "bypasses
`succ_embed_surjective` and the `IsSuccArchimedean` requirement". `completeness_discrete`
is `sorryAx`-free, which independently confirms the bypass.

**Do not excise `chronicle_gap_contradiction` alone.** The in-file warning at
`ChronicleToCountermodel.lean:70-71` ("excising any of them breaks `lake build` — keep them") is
correct about *piecemeal* excision and wrong about the conclusion. The whole 8-declaration
closure must move as one unit. Additional care needed during excision:

- `cantor_bfmcs_discrete_restricted_buc` (:1634) is sorry-free but is consumed **only** by the
  two dead heads; it becomes orphaned once they move. Either move it too or accept a new orphan.
- `succ_embed_squeeze` (:1303) and `succ_embed_squeeze_strict` (:1340) feed
  `succ_embed_surjective`; their other consumers must be checked before the fixpoint is closed.
- `limitDomSubtype_succOrder` / `limitDomSubtype_predOrder` are `letI`-bound inside the chain
  and may have live uses elsewhere — verify before moving.

The planner should compute the exact closure fixpoint (the `StaviDiscretePath` precedent in
`Boneyard/README.md` records a closure that grew from 16 to 24 declarations during excision, so
budget for growth). Destination: extend the existing `Boneyard/DeadChronicleGapElimination/`
subdirectory rather than create a new one — that is where this chain's siblings already live.

---

### Group D — `WeakCanonical/Transfer.lean:1297` `countermodel_discrete` → **KEEP AND PROVE**

**This is the one load-bearing sorry.** It is called at `Completeness.lean:219`, inside the
purely-discrete branch of `completeness`:

```lean
· -- Purely discrete case: □(U(T,bot)) ∈ M
  obtain ⟨D, _, _, _, _, F, TM, Omega, h_sc, τ, h_mem, t, h_not_true⟩ :=
    WeakCanonical.countermodel_discrete M hM_mcs φ h_neg_in h_box_discrete
```

**It is the *only* `sorryAx` source reaching `completeness`.** Proof: the taint scan's 47 names
contain exactly one declaration that `completeness` consumes — `countermodel_discrete` — and the
other two branches of the case split are independently clean (`countermodel_dense_enriched` and
`mcs_mixed_case_absurd` do not appear in the tainted set). Archiving it would delete the real
obligation and break `completeness`.

**Difficulty assessment (no proof attempted, per scope discipline).** This is a genuine open
construction, not a re-wiring, and the repo's own analysis at `Completeness.lean:174-184` agrees:

- The obligation is: from a **Base**-MCS `M` with `□(U(⊤,⊥)) ∈ M` and `¬φ ∈ M`, build a discrete
  countermodel.
- `countermodel_discrete_reynolds_v2` cannot be reused directly: its signature demands
  `SetMaximalConsistent (fc := FrameClass.Discrete) A`, and a Base-MCS is not automatically
  Discrete-consistent.
- The old BX-pipeline route is **provably** unavailable: it terminates in `succ_cofinal`, refuted
  by the ℤ+ℤ counterexample (`Boneyard/BXPipelineGapAnalysis/` documents this; two copies of ℤ
  with constant MCS satisfy all `PriorModelData` hypotheses yet have a Dedekind gap).
- Two candidate routes, both substantial: (i) a Base-to-Discrete MCS transfer lemma that lets
  `countermodel_discrete_reynolds_v2` apply, or (ii) a Henkin-style discrete canonical model
  built directly from a Base-MCS. Route (i) is the smaller of the two if the transfer is
  provable, and should be scoped first.

**Estimated effort: large — a task in its own right**, comparable to the original Reynolds
pipeline landing. It should be spawned as a separate task, not folded into any archival work.
Until it lands, `completeness` legitimately carries `sorryAx` while `completeness_dense` and
`completeness_discrete` remain clean — which is the honest current state and is already
documented at `Metalogic/Metalogic.lean:34-37`.

---

## Why Category (c) — KEEP AS EXPLICIT AXIOM — Is Rejected

The task flagged `successor_deferral_seed_consistent_axiom` (SuccExistence.lean:748) and
`predecessor_deferral_seed_consistent_axiom` (:822) as possible intended-assumption cases,
given their `..._axiom` suffix. **Converting them to declared `axiom`s would be a mistake**, for
two independent reasons:

1. **They have zero live consumers.** An axiom exists to discharge an obligation something else
   needs. Nothing needs these. Declaring an axiom that no live result uses adds trust surface
   for no benefit — strictly worse than archiving.

2. **The proof route they encode is unsound, and the naming is stale.** Both bodies reduce to
   `g_content u ⊆ u` / `h_content u ⊆ u`, i.e. the T-axiom for `G`/`H`, which
   `Boneyard/TAxiomDependentCode/` already records as invalid under strict temporal semantics.
   The `_axiom` suffix and the "**Status**: PROVEN under BX1" docstrings both date from before
   BX1 was removed. The *statements* (`successor_deferral_seed u` is consistent) may well be
   true for other reasons — the standard seriality argument — but nothing in the file
   establishes that, and axiomatizing a statement whose only written justification is a removed
   axiom is exactly the failure mode the Boneyard convention exists to prevent.

Archiving is the correct disposition for all three.

---

## Recommended Implementation Sequence

Ordered by risk, lowest first. Each step must end with `lake build` green and a strictly reduced
sorry count.

1. **`SuccExistence.lean` → Boneyard (3 sorries retired).** Whole-file move; zero live
   consumers of any of its 72 declarations. Also remove the dead import at
   `Core/RestrictedMCS/Basic.lean:13`. Natural destination: alongside
   `Boneyard/RestrictedMCSDeferral/`, which archives the sibling deferral-restricted variant.

2. **`SuccRelation.lean` lines 549-654 → Boneyard (7 sorries retired).** Declaration-excision
   under the `SorriedDeclExcisions` conventions; the rest of the file stays live.

3. **`chronicle_gap_contradiction` chain → `Boneyard/DeadChronicleGapElimination/`
   (1 sorry retired).** Largest and highest-risk step: compute the closure fixpoint first,
   move as one unit, expect the closure to grow during excision.

4. **Correct the two stale in-repo claims** (these are wrong today regardless of whether any
   archival happens):
   - `ChronicleToCountermodel.lean:62-71` — retention rationale cites the archived
     `countermodel_discrete_enriched`.
   - `Completeness.lean:372` and `Transfer.lean:1191` — both assert the Reynolds pipeline /
     `countermodel_discrete_reynolds` is sorry-free; `countermodel_discrete_reynolds` is
     `sorryAx`-tainted. The clean theorem is `countermodel_discrete_reynolds_v2`.

5. **Spawn a separate task for `countermodel_discrete`.** Base-MCS discrete countermodel;
   scope route (i) (Base→Discrete MCS transfer) before route (ii) (Henkin discrete model).

After steps 1-3: **12 live sorries → 1**, with `completeness` still carrying `sorryAx` from that
one remaining genuine obligation, and `completeness_dense` / `completeness_discrete` unchanged
and clean.

**Boneyard bookkeeping required by the existing convention** (see
`Boneyard/README.md` "Boneyard Maintenance Standard"): per-subdirectory `README.md` explaining
what was archived and why it is dead; a new row in the Directory Inventory table matching the
existing column format (Directory / Files / Lines / Archived From / Why Archived / Task); a row
in the Task Cross-References table; and confirmation that no live module imports the archived
path.

---

## Appendix A — The 47 `sorryAx`-Tainted Declarations

Produced by `Lean.collectAxioms` over all 19,442 `Bimodal.*` constants.

**Island 1 — `Bundle/` (36 declarations, dead).**
`until_unfold_in_mcs`, `since_unfold_in_mcs`, `until_persists_through_succ`,
`or_until_in_mcs`, `or_since_in_mcs`, `g_content_subset_mcs`, `h_content_subset_mcs`,
`constrained_successor_seed_consistent`, `constrained_successor_from_seed`,
`constrained_successor_from_seed_mcs`, `constrained_successor_from_seed_extends`,
`constrained_successor_succ`, `constrained_successor_satisfies_f_step`,
`constrained_successor_satisfies_g_persistence`, `successor_p_step`,
`successor_deferral_seed_consistent_axiom`, `successor_deferral_seed_consistent`,
`successor_from_deferral_seed`, `successor_from_deferral_seed_mcs`,
`successor_from_deferral_seed_extends`, `successor_exists`, `successor_succ`,
`successor_satisfies_f_step`, `successor_satisfies_g_persistence`,
`predecessor_deferral_seed_consistent_axiom`, `predecessor_deferral_seed_consistent`,
`predecessor_from_deferral_seed`, `predecessor_from_deferral_seed_mcs`,
`predecessor_from_deferral_seed_extends`, `predecessor_exists`, `predecessor_pred`,
`predecessor_succ`, `predecessor_f_step`, `predecessor_satisfies_p_step`,
`predecessor_satisfies_h_persistence`, `predecessor_satisfies_g_persistence_reverse`.

**Island 2 — `chronicle_gap_contradiction` chain (8 declarations, dead).**
`chronicle_gap_contradiction` (private), `succ_cofinal` (private),
`limitDomSubtype_isSuccArchimedean`, `succ_embed_surjective`,
`cantor_bfmcs_discrete_restricted_tc`, `cantor_bfmcs_discrete_restricted_fuc`,
`dd_countermodel_chronicle_discrete`, `countermodel_discrete_reynolds`.

**Island 3 — the live obligation (3 declarations).**
`countermodel_discrete`, `completeness`, `completeness'`.

## Appendix B — Reproduction

```bash
# Axiom check on the headline theorems
cat > /tmp/Ax.lean <<'EOF'
import Bimodal.Metalogic.Metalogic
#print axioms Bimodal.Metalogic.BXCanonical.completeness
#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete
#print axioms Bimodal.Metalogic.WeakCanonical.countermodel_discrete
#print axioms Bimodal.Metalogic.WeakCanonical.countermodel_discrete_reynolds
EOF
lake env lean /tmp/Ax.lean

# Whole-environment taint scan
cat > /tmp/Tainted.lean <<'EOF'
import Bimodal
import Bimodal.Metalogic.Metalogic
open Lean Elab Command
run_cmd do
  let env ← getEnv
  for (n, _) in env.constants.toList do
    if (n.toString.splitOn "Bimodal").length > 1 then
      if (← collectAxioms n).contains ``sorryAx then logInfo s!"TAINTED {n}"
EOF
lake env lean /tmp/Tainted.lean
```

Do **not** attempt a reverse-dependency graph via `ConstantInfo.value?` — imported theorem
bodies are unavailable under Lean 4.33's module system and the graph will silently under-report.
