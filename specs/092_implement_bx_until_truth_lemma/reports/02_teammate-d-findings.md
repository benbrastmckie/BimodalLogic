# Task 92 — Teammate D (Horizons) Findings

- **Task**: 92 — Burgess-Xu Until/Since truth lemma
- **Role**: Horizons — strategic alignment, long-term trajectory, unconventional approaches
- **Date**: 2026-04-10
- **Inputs**: reports/01_inherited-from-task90.md, 090/reports/03_task92_recommendation.md, specs/TODO.md, specs/ROAD_MAP.md §"Active-Path Sorry Inventory", Theories/Bimodal/Metalogic/BXCanonical/{Frame.lean, TruthLemma.lean, Completeness.lean}

## Summary

Task 92 is one of two remaining load-bearing obstacles on the BXCanonical completeness critical path; after 92 + 93 land, `bx_completeness` is sorry-free on the active path and only the non-critical legacy backlog remains (to be archived in task 94). The Burgess-Xu induction scaffolding the task 90 recommendation proposes is substantially reusable — not just for the 4 sorries at hand but also for task 93's Box-direction argument and for any future decidability / finite-model work that needs to reason about eventualities along `bx_le`. The strategic recommendation is: **proceed with the task 90 plan, but factor the scaffolding out of inline proofs into a new `BXCanonical/UntilHelpers.lean` module**, and capture 3 crisp memory entries so the "X-vs-G mismatch" narrative does not get re-discovered a third time. No escalation, no Option A revival in task 92 itself (but flag as a possible post-92 refactor).

## Completeness Critical Path (Post-92 Trajectory)

```
bx_completeness (BXCanonical/Completeness.lean:124)
├── truth lemma (BXCanonical/TruthLemma.lean)
│   ├── atom / bot / imp           [done]
│   ├── box  → box_iff_mcs         [done modulo Frame.lean:440]
│   │        └─ bx_modal_witness   [SORRY 1/6 — task 93]
│   ├── G, H → G_iff_mcs/H_iff_mcs [done]
│   └── U, S → until_iff_mcs/since_iff_mcs
│              ├── forward (ψ ∈ w)   [done via BX8/BX8']
│              ├── forward (ψ ∉ w)   [SORRIES 2, 4/6 — TASK 92]
│              │     ↳ bx_until_eventuality_resolution
│              │     ↳ bx_since_eventuality_resolution
│              └── backward (ψ ∉ w)  [SORRIES 3, 5/6 — TASK 92]
│                    ↳ bx_until_backward
│                    ↳ bx_since_backward
└── TaskModel embedding             [SORRY 6/6 — task 93]
        └─ Completeness.lean:154
```

**After 92 lands**: 4 sorries removed. `TruthLemma.lean` becomes entirely sorry-free (the Until/Since theorems already *call* the four `bx_until_*` / `bx_since_*` Frame helpers).

**After 93 lands**: 2 remaining sorries closed. `#print axioms bx_completeness` should show only `{propext, Classical.choice, Quot.sound}` plus the inherited `discrete_Icc_finite_axiom` (custom axiom, cleanup owned by task 60).

**Verdict on "is 92 the last big mathematical obstacle?"**: Yes, mathematically. Task 93's remaining sorries are both *engineering* steps — the Box direction is a standard S5 canonical-model argument with the S5 collapse plumbing already present in `Frame.lean:459-499`, and the TaskModel embedding is a data-structure reshuffle. Task 92 is **the** mathematical load-bearing step. The only "further downstream sorries" blocking top-level completeness after 93 are the legacy piles in `UltrafilterChain.lean`, `DovetailedChain.lean`, etc., which task 94 will archive (not prove) because they are strict-semantics code that the reflexive-semantics BX path bypasses entirely.

## Reusability Analysis

| Candidate Lemma | Task 92 (4 sorries) | Task 93 Box | Task 93 TaskModel | FMP / Decidability (future) | Soundness | Tactics / simp set |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| `guard_persists_self_accum` (BX5+BX6 keep φ and φUψ on the prefix) | YES (core) | — | — | YES (finite model guard reasoning) | — | maybe simp |
| `earliest_until_witness_of_F` (BX7+BX12 pick minimal ψ-witness in trajectory) | YES (core) | — | — | YES (used in filtration minimization) | — | — |
| `propagate_not_until_forward` (BX4 `connect_future` propagates ¬(φUψ) forward along `w`) | YES (backward direction) | — | — | YES | YES (symmetric soundness) | — |
| `vacuous_guard_lift` (BX12: F(ψ) → (⊤ U ψ)) | YES | — | — | YES | — | safe simp candidate |
| Since-dual of all four (BX5', BX6', BX7', BX10', BX11', BX12' + connect_past) | YES (mirror sorries) | — | — | YES | YES | — |
| `box_preserved_on_trajectory` (already exists as `box_preserved_along_bx_le`, Frame.lean:538) | — | YES (reused) | YES | — | — | — |
| Interval-based `linear_until` extracted from BX7 | YES | — | — | maybe | — | — |

**Key finding**: `guard_persists_self_accum`, `earliest_until_witness_of_F`, `propagate_not_until_forward`, and `vacuous_guard_lift` together constitute a **small reusable Burgess-Xu kernel** that will also pay off in FMP filtration work (task 82 / 998), and their Since-duals double the surface area — for roughly 8 lemmas. They deserve to be named, docstring'd, and placed in their own file. Inlining them 4× into the 4 Until/Since theorems would duplicate the absorption reasoning and hide the reusable structure behind a wall of `by` tactics.

## Suggested Module Structure

Current `BXCanonical/` is a flat 4-file directory:

```
BXCanonical/
├── BXCanonical.lean      (15 lines — aggregator)
├── Frame.lean            (706 lines — everything)
├── TruthLemma.lean       (359 lines — pure truth lemmas)
└── Completeness.lean     (163 lines — top-level theorem)
```

Proposed structure after task 92:

```
BXCanonical/
├── BXCanonical.lean      (aggregator, add UntilHelpers import)
├── Frame.lean            (-80 to -120 lines: move BX5/6/7/12 scaffolding out;
│                          leaves 4 bx_until_* / bx_since_* definitions as
│                          thin wrappers over helpers, plus the box layer.)
├── UntilHelpers.lean     (NEW, ~250-350 lines)
│   ├── guard_persists_self_accum
│   ├── earliest_until_witness_of_F
│   ├── propagate_not_until_forward
│   ├── vacuous_guard_lift
│   ├── Since-duals of all four
│   └── prose-level doc block explaining the Burgess-Xu substitution
│       for linearity (see "Linearity Gap Narrative" below)
├── TruthLemma.lean       (unchanged — already calls the bx_until_* helpers)
└── Completeness.lean     (unchanged, still owns TaskModel sorry for task 93)
```

**Why a new file and not an extension of Frame.lean?** Two reasons:
1. Frame.lean is already 706 lines and carries *three* distinct layers (ordering + S5 modal-witness + eventuality resolution). Splitting it along the natural seam keeps each file focused.
2. Task 93 will need to read the helpers (`box_preserved_along_bx_le` is already cited in the Box sorry comment trail); having them in a separate file with good docstrings accelerates 93 without requiring 93's author to scroll through 4 proofs that call the same helper.

**Risk**: moving code across files changes import order and could delay task 92 by 1-2h of lake-build mechanics. Acceptable — the time savings on 93 recoup it.

## Future Refactor Opportunities (Post-92)

1. **Option A revival (post-92, not during)**. Task 90 rejected "redefine `bx_le` via trajectory closure" as structurally infeasible because (a) the bridge lemma `bx_le ↔ trajectory closure` cannot be proved without the Until-induction infrastructure *that task 92 will build*, and (b) redefining `bx_le` mid-stream breaks `box_preserved_along_bx_le` and every `bx_G_forward` user. Once task 92 lands, (a) disappears: the Burgess-Xu kernel can now prove the bridge. Whether it is *worth* doing is a separate question — the answer depends on whether a future task needs trajectory-closed `bx_le` for something else (e.g., a cleaner FMP argument). **Flag as "Option A (deferred)" in the roadmap; do not action in 92.**

2. **Strict U/S extension**. After BX reflexive completeness is closed, the strict-semantics research track (tasks 74-76) may want to reuse the Burgess-Xu kernel. The helpers in `UntilHelpers.lean` should be parameterized where feasible so a strict variant can import them.

3. **`bx_lt` vs interval predicates**. `TruthLemma.lean:212` defines `bx_lt w v := bx_le w v ∧ ¬bx_le v w`. After 92, consider promoting this to a proper strict order lemma bundle (irreflexivity, transitivity-on-intervals) — not load-bearing but cleans up the guard-property reasoning downstream.

4. **Comment rewrite scope**. Task 90 recommendation asks to rewrite the misleading "linearity gap" comments at `Frame.lean:647-651` and `:674`. Consider also rewriting the module docstring at `Frame.lean:585-622` (the "Mathematical Status" block still describes approaches (A)/(B)/(C) as blocked) — once 92 lands, the whole block should become a positive description of the Burgess-Xu resolution.

## Alternative Macro Strategies (Roadmap Only)

These are flagged for ROAD_MAP.md, not for action in task 92:

- **Selection-based / filtration canonical model**. Instead of MCS-indexed canonical frame, build a filtered canonical model whose points are equivalence classes of MCSes modulo a finite subformula-closure. This makes the Until case easier (finite ordering lets us induct on the minimal witness) at the cost of a harder soundness setup. Would supersede the Burgess-Xu kernel rather than complement it.

- **Quotient by modal-equivalence**. The current construction keeps distinct BXPoints that are `bx_modal_equiv` and distinct. Quotienting early collapses the S5 layer and may let `box_iff_mcs` become a definitional unfolding. Has knock-on effects on `bx_le` (needs to lift to quotients) and is almost certainly more work than it saves for closing the remaining sorries.

- **Algebraic semantics (BAO) as intermediate step**. Prove completeness of BX over Boolean Algebras with Operators (Until/Since as normal operators with compatibility axioms), then dualize via Jónsson-Tarski to get Kripke completeness. Bypasses eventuality resolution entirely. This is a *very* large undertaking (essentially a second Lean development) but would make the Until problem dissolve. Worth listing as a long-horizon alternative in ROAD_MAP.md §"Future Directions" but **not** for task 92.

None of these dissolves the Until problem in a way that is cheaper than finishing task 92 as specified.

## Linearity Gap Narrative (for comment/docstring block)

The intuition "Until needs linearity" is *half right*. In a classical Burgess canonical model over a linearly ordered MCS carrier, linearity lets you case-split `u ≤ v ∨ v ≤ u` on arbitrary MCSes and pin the guard. The BX canonical model here has a `bx_le` that is **not** linear in that sense (probes 1-3 of the task 90 diagnostic show it structurally: `bx_le` is a metalogic relation and `temp_linearity` is an object-level schema, so there is no closing tactic).

Burgess-Xu induction substitutes for linearity by *constructing* the interval along which linearity is needed. The trick is:

1. Do not start from two arbitrary `u, v ≥ w` and try to compare them.
2. Instead, pick the **earliest** ψ-witness `v` along a BX7-linearized Until-resolution sequence, and use BX5 self-accumulation so every point traversed on the way carries `(φ U ψ)`. The "interval" `[w, v)` becomes a by-construction object rather than a set of arbitrary comparable points.
3. For any `u` that the truth-lemma quantifies over, `u ∈ [w, v)` is enforced by the guard hypothesis itself (`bx_le w u ∧ bx_le u v ∧ ¬bx_le v u`), so we never *need* to decide comparability against non-trajectory points.

In short: linearity in the classical construction is needed because points are introduced globally; Burgess-Xu constructs points locally, so comparability is a construction invariant rather than a theorem. The axiom set pays for this: BX5/BX6/BX7 are *stronger than* classical linearity in their distribution of proof power — they grant local structural control in exchange for not granting global MCS comparability. This is why the axioms are sufficient even though `bx_le_linear` is not derivable.

This narrative belongs in a prose block atop `UntilHelpers.lean` (or the new top-of-Until section in `Frame.lean`) — it is the single most important thing a future reader needs to understand, and without it the codebase will produce a "missing linearity lemma" task for the third time in 18 months.

## Proposed Memory Entries

Write each of these to `.memory/10-Memories/` after task 92 lands (via `/learn --task 92`):

1. **`bx_le-is-g-content-subset-intentionally.md`**
   - Content: `bx_le := g_content ⊆` is the final chosen definition. It is intentionally NOT trajectory-closed. Redefining it (Option A) was investigated by task 90 and rejected as structurally infeasible before task 92. Post-task-92, Option A may become technically feasible but should still be avoided unless a concrete downstream consumer needs trajectory closure.
   - Links: specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md, Frame.lean:61

2. **`until-via-burgess-xu-not-linearity.md`**
   - Content: The Until/Since truth lemma does NOT use a `bx_le_linear` lemma and cannot. Both global and interval `bx_le_linear` are non-derivable from BX7 + BX11 + BX12 (object-logic / metalogic bridge gap, verified by task 90 Phase 1 diagnostic probes). Instead, task 92 uses Burgess-Xu Until-induction: BX5 self-accumulation + BX6 absorption + BX7 earliest-witness + BX4 forward propagation. Future research that "discovers" a need for linearity has re-discovered a known dead end.
   - Links: specs/090_research_bx_le_redefinition/reports/02_bx_le_linear_diagnostic.md, specs/092_implement_bx_until_truth_lemma/reports/02_teammate-d-findings.md (this file)

3. **`bx7-linear-until-is-local.md`**
   - Content: BX7 (`linear_until`) gives witness-ordering for *two Until formulas at the same point*. It does NOT give global `bx_le` linearity or pointwise comparability of MCSes. Applying BX7 requires having both Until formulas in the same MCS — which is only usable to select the earliest witness along a pre-existing trajectory, not to linearize arbitrary intervals.
   - Links: Theories/Bimodal/ProofSystem/Axioms.lean (BX7), task 90 Phase 2 report

4. **(Optional) `bxcanonical-file-layout.md`** — only if the module split is adopted
   - Content: BXCanonical split: `Frame.lean` owns ordering + Box modal witness; `UntilHelpers.lean` owns Burgess-Xu kernel lemmas; `TruthLemma.lean` stitches them into the formula-structural truth lemma; `Completeness.lean` owns the TaskModel embedding and top-level theorem. Any new lemma should go in the file whose responsibility matches, not into whichever file is shortest.

## Quality Bar Recommendations

"Mathematically correct" for task 92 should mean all of the following, not just the first:

1. **Baseline (required)**: All 4 sorries at `Frame.lean:653/675/690/704` closed. `lake build Bimodal.Metalogic.BXCanonical.Frame` succeeds. `#print axioms bx_until_eventuality_resolution` lists only standard axioms (no new `sorry`, no new `axiom`).

2. **Named intermediate lemmas with docstrings**. The Burgess-Xu kernel (4 helpers plus duals) must have docstrings explaining mathematical role. Anonymous `have h1 ... have h2 ...` chains hide the reusable structure and cost task 93 / FMP readers hours. This is the single biggest review criterion.

3. **Prose block on Burgess-Xu substitution for linearity**. A docstring or comment block (at module level or on the first helper) articulating the "Linearity Gap Narrative" above. This is the institutional memory of *why* task 92 does what it does.

4. **Rewritten misleading comments**. `Frame.lean:585-622` module docstring, `:647-651`, `:674` all rewritten to describe what task 92 actually proved (not what pre-90 thought was blocked). Remove stale references to Approaches (A)/(B)/(C) and "X-vs-G mismatch" as blockers — retain "X-vs-G mismatch" only as historical context under a "Why this is subtle" heading if at all.

5. **Light soundness sanity test (optional but recommended)**. Add a test in `Tests/BimodalTest/` picking a specific instance — e.g., derivation of a simple `φ U ψ → F ψ` theorem — and checking its canonical-model semantics. This is not a "new theorem" but a smoke test that the truth lemma's Until case actually evaluates on a concrete input. Catches silent regressions during task 93 refactoring.

6. **Update active-path sorry inventory in ROAD_MAP.md**. Remove rows 2, 3, 4, 5 from the table at `specs/ROAD_MAP.md:292-306`. Update the critical-path diagram. This is an artifact-hygiene step that should be part of the task 92 completion commit, not deferred.

## Strategic Verdict

**Proceed with the task 90 plan, with three modifications:**

1. **Extract helpers into `BXCanonical/UntilHelpers.lean`** rather than inlining 4× into Frame.lean. This adds ~1h to task 92 but saves time on task 93 and any future reuse. If the planner chooses to inline, at least ensure the helpers are named `have` blocks with docstring comments above them.

2. **Include the Linearity Gap Narrative as a prose block** (see section above) in the most visible code location — the top of the Until section in Frame.lean or at the top of UntilHelpers.lean. This is the single highest-leverage documentation write in this task.

3. **Bundle a ROAD_MAP.md sorry-inventory update and memory-entry creation with the task 92 completion commit** rather than deferring to a separate artifact-hygiene task. The four proposed memory entries lock in the institutional knowledge while the context is hot.

**Do NOT**:
- Escalate to task 94 / quasimodel pivot preemptively.
- Revive Option A (redefine `bx_le`) within task 92 scope — flag for post-92 roadmap only.
- Introduce any new axioms.
- Use `sorry` as an intermediate step "to be cleaned up later" — if BX6 absorption stalls, pause and `/spawn 92` per the task 90 escalation path.

No blockers foreseen for the task 90 plan as written. The extracted helpers proposal is an amplification, not a blocker.

## Confidence Level

**High (≈ 88%)** that task 92 will land successfully on the Burgess-Xu plan, with the Since-duals being the lowest-confidence sub-step (BX6' absorption is historically the most error-prone axiom to discharge in the proof search; if anything stalls, it will stall there, and the task 90 recommendation already flags this as the spawn trigger).

**Very high (≈ 95%)** that the reusability analysis holds: the 4 kernel lemmas genuinely *are* reusable for task 93 and FMP work, based on the code I read in `Frame.lean` and the dependency graph.

**Moderate (≈ 65%)** that the Option A deferred-revival is actually worth doing post-92. The current verdict is "flag in roadmap, act only if a concrete consumer demands it." I do not see one on the current TODO list.
