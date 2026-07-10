# Supersession Decision Record — Task 321 (F4 k=2 carrier / correctness gate)

- **Task**: 321 — implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution
- **Type**: lean4
- **Decision session**: sess_1783659497_144c59
- **Date**: 2026-07-09
- **HEAD at decision**: `a4ad1cb35`
- **Decision**: **RETIRE — recommended terminal status `EXPANDED`.** Do NOT revise; plan v7
  (`plans/07_v7-faithful-separate-bracket.md`) is stale and every open deliverable is now owned
  by a live successor task.
- **Sources of truth**: PDF `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
  (16 pp., cited by page); code at HEAD `a4ad1cb35` (cited `file:line`);
  `specs/333_.../reports/03_pdf-fidelity-r3-dissolved-regrounding.md` (H4-verified);
  `specs/state.json`.

## 1. Verdict

Task 321 should be **retired as superseded**, terminal status **`EXPANDED`** (not `abandoned`).
The task was genuinely *divided* into successors that are actively closing — and in large part
have already **completed** — the very work its additive-only v7 plan structurally could not do.
Its landed Phases 1–10 assets are preserved and are the foundation the successors build on
(not discarded), which is the defining condition of `EXPANDED` over `abandoned`.

## 2. Why plan v7 is stale (verified at HEAD `a4ad1cb35`)

| Plan-v7 asset / premise | Status at HEAD | Verification |
|---|---|---|
| `kvE2_sepArrL` / `kvE2_sepArrR` / `kvE2_sepValid` | **DELETED** (0 declarations each) | `grep` over `Theories/` — all 0; replaced by `kvE2_sepArr'` (3) + `kvE2_sepDisjValidOwner` (1) [task 334] |
| Entire `kvE2_sepSingleton` block (21 refs in v7) | **DELETED** (0 occurrences anywhere) | `grep -r kvE2_sepSingleton Theories/` = 0 |
| The two strategic sorries v7 Phase 11 tracked (`kvE2_sepSingleton_coverage_left`, `kvE2_sepBody_singleton_complete_left`) | **GONE** (restructured out) | not present at HEAD; SharedWitness live-path sorries now **1** (was 2) |
| O4 CRUX (hgate forward-zone coverage residue) | **DISSOLVED** | `specs/333_.../reports/03` Part C, H4-verified: the conjunct `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1)=true` is never a goal at HEAD — it is the *antecedent* of a per-owner `bit ⟹ witness` bundle; `kvE2_sepGate` (SW:1238) has 4 clauses all concluding `= false`; `kvE2_sepBody_extract` (SW:6328) already produces the bundles sorry-free |
| `kvE2_sepPosI` (interior-restricted owner index) + tie-admitting weak orders; `hLR` deleted | Present (9 decls); `hLR` = **0 declarations** | task 342; `grep` confirms |
| 70 distinct `md:NN` literature citations across 321 artifacts | **DANGLING / unsound** | the Rabinovich `.md` was a hand paraphrase, replaced by a PDF text-extract that drops every displayed equation and inverts `k≠m`→`k=m` (`specs/333_.../reports/03` Part A; `specs/342_.../reports/01`). Cite the PDF by page instead |
| Plan v7 mentions of tasks 334 / 342, `kvE2_sepPosI`, interior restriction, tie-admitting validity | **None** — v7 predates all of them | read of `plans/07_...` (no occurrences) |

The carrier `kvE2_sepBody` v7 built in Phase 7 still exists (1 def) but has been **re-architected
in place** by task 334 (`kvE2_sepArr'` + `kvE2_sepDisjValidOwner`) and task 342
(`kvE2_sepPosI` + tie-admitting validity). Plan v7 describes a code landscape that no longer
exists; its only non-completed phases (11 PARTIAL, 12–13 NOT STARTED) are exactly the phases the
successors have taken over.

## 3. What was absorbed, by which task

| Task 321 deliverable (v7) | Absorbed by | Status |
|---|---|---|
| Carrier redefinition to close the O4/hgate residue additively couldn't do; discharge v7's two strategic sorries; multi-positive-sub correctness lift; **Phase 12 (N2-C gate wrapper)**; **Phase 13 (F4 `ℤ` LHS-FALSE + GO verdict record)** | **task 333** (`[implementing]`) — self-declared "Successor to task 321 (F4 correctness gate)"; deliverables (2),(3),(4) name exactly these | Owned, live |
| The carrier redesign itself (per-order-type validity, `kvE2_sepArr'`, faithful non-vacuity/completeness) | **task 334** (`[completed]`), with **337/339/340/342** (all `[completed]`) refining the interior index + tie-admitting orders | Done |
| Outer-gate assembly ⇒ soundness half (`bracketEndChar_kvE2_sound_two_prior`, `OuterGate.lean`) | **task 335** (`[partial]`) | Owned, live (its BLOCKED record cites the *same, now-dissolved* O4 crux — stale per `333/reports/03` C.5) |
| Structural refactor of the grown SharedWitness carrier layer | **task 341** (`[not_started]`) | Owned, scheduled after the active carrier chain |

## 4. What genuinely remains open under task 321's OWN scope

**Nothing that is not already owned by a live task.** Specifically:

- The soundness-extraction / outer depth-2 fold (`kvE2_sepBody_extract`, `kvE2_outer_fold`,
  the R2 `Pairwise`/`Nodup` side-conditions) — owned by **task 333** (`SharedWitness.lean`).
- The `OuterGate.lean` ⇒ half — owned by **task 335**.
- The refactor — owned by **task 341**.
- **The F4 semantic `ℤ` LHS-FALSE discriminator + GO verdict record.** `SubBracket.lean:~231`
  records the construction-level F4 discrimination as COMPLETE and states "the FULL semantic
  `M = ℤ` LHS-FALSE proof … is folded into the spawned continuation." That continuation is
  **task 333 deliverable (4)** ("run … Phase 13 (F4 Z adversarial LHS-FALSE + GO verdict
  record) from task 321's v7 plan"). So the F4 residue is **already spawned into task 333**, not
  an unspawned orphan. If task 333 is later judged too broad to also carry F4, splitting F4 into
  its own task is a task-333 scoping decision, not a reason to keep 321 open.

Because no residue is both genuinely open *and* unowned, there is no re-scope target for a task-321
v8 plan. Retirement is the correct action.

## 5. Impact on task 309's dependency

Task 309 (`[blocked]`, off-diagonal two-anchor `F_i` chain) carries no formal `blocked_by`/
`depends_on` edge in `state.json` (both `none`); its dependence on 321 is narrative: task 321's
v7 Non-Goals state that a **GO verdict** (v7 Phase 13) is what "UNBLOCKS" *task 309 Phase 13.4
(general-k one-step correctness)* and the `KampPrior.lean:351` hook rewire.

- That GO-verdict dependency **re-points from task 321 to task 333**, which owns Phase 13 (F4 +
  GO verdict) as deliverable (4). When 333 lands the GO/NO-GO record, 309 Phase 13.4 is what it
  unblocks.
- Note this is a *different* hook from 309's **current** blocker: 309's description blocks on
  `KampPrior.lean:350` (its own off-diagonal arms, consuming task 308), not on the k=2 gate at
  `:351`. Retiring 321 therefore does **not** worsen 309's present blocked state; it only moves
  the *downstream* (Phase 13.4) GO dependency to its live owner (333).
- **Recommended graph action for the orchestrator**: retarget any 321→309 dependency annotation
  to **333**; leave 309's current `[blocked]` status unchanged (its live blocker is task-308 /
  `KampPrior:350`, independent of this retirement).

## 6. Recommended terminal status and rationale

- **Recommended status: `EXPANDED`.** Task 321 was divided into successor tasks
  (333 carrier-redefinition + gate close + F4; 335 outer gate; 341 refactor), several of which
  (334/337/339/340/342) have already **completed**. Its landed Phases 1–10 (carrier, shared-`w`
  extraction, decision gate, N2-A) are preserved, axiom-clean, and actively consumed by the
  successors — work continued and largely succeeded, so this is expansion, not abandonment.
- **Not `abandoned`**: nothing was dropped as a dead end; the line of work is thriving under the
  successor chain.

## 7. Citations note

All literature claims here are PDF-page-cited (Def 3.1 p.4, Lemma 3.2 p.4, Lemma 5.1/(5.1) p.7,
Cor 5.4 p.9, Def 7.5 p.13, per `specs/333_.../reports/03` Part A). The 70 `md:NN` citations in
task 321's artifacts are **unsound** (dangling line anchors into a paraphrase-then-extract swap)
and must not be relied on. No `Theories/` file was edited in producing this record.
