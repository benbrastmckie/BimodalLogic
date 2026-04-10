# Task 92 — Team Research Synthesis (Round 02)

- **Task**: 92 — Close 4 Until/Since truth-lemma sorries in `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (lines 653, 675, 690, 704)
- **Date**: 2026-04-10
- **Session**: sess_1775853007_8f994f
- **Mode**: Team Research (4 teammates: A=Primary, B=Alternatives, C=Critic, D=Horizons)
- **Source reports**:
  - [02_teammate-a-findings.md](02_teammate-a-findings.md) — Primary-angle validation
  - [02_teammate-b-findings.md](02_teammate-b-findings.md) — Alternatives & prior art
  - [02_teammate-c-findings.md](02_teammate-c-findings.md) — Critic
  - [02_teammate-d-findings.md](02_teammate-d-findings.md) — Horizons
- **Inherited**: [01_inherited-from-task90.md](01_inherited-from-task90.md); task 90 recommendation at `specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md`

---

## Executive Summary

The four teammates **converge** on two important facts and **diverge sharply** on a third:

**Convergence 1 — No alternative is better than Burgess-Xu Until-induction.**
Teammate B rigorously rejected six alternative strategies (direct witness, minimal counterexample, trajectory-rank induction, X-fixpoint unfolding, reduction to Box, chain/filtration). Three collapse into Burgess-Xu the moment BX5 is invoked; three are structurally infeasible (no Next operator, no well-founded rank on BXPoints, or cascade-break existing infrastructure). Prior-art survey (Burgess 1982, Xu 1988, Verbrugge, Goldblatt, Venema, LeanearTemporalLogic, LeanLTL, PAL+S5, Coalition-Logic/ITP 2024) yields no superior path. DovetailedChain.lean is independent in-project empirical evidence that chain/filtration fails at the `g_content ⊆` level.

**Convergence 2 — The axiom inventory is complete.**
All cited axioms (BX4, BX5, BX6, BX7, BX9, BX10, BX11, BX12) and their primed Since-duals exist with the exact shapes task 90 cites. No axiom must be added.

**Divergence — Is the task 90 proof sketch actually sound as written?**

| Teammate | Confidence in task 90 sketch | Position |
|---|---|---|
| A (Primary) | Medium-low | Two load-bearing gaps (U5 forward, B-GAP backward) found by walking the sketch against actual Lean types. |
| B (Alternatives) | Medium-high | Approves task 90 path; proposes lifting step 5 into a named `bx_earliest_until_witness` primitive. |
| C (Critic) | 25% | Three BLOCKER-severity issues: BX5 propagation, BX4 docstring disavowal, BX7 is formula-level. Recommends mandatory Phase 0 diagnostic gate. |
| D (Horizons) | 88% | Accepts sketch at face value; focuses on module structure, memory, quality bar, and post-92 refactor opportunities. |

A and C find the **same two gaps independently**:
- **U5 (forward)**: "For arbitrary `u` with `w ≤ u ≤ v ∧ ¬(v ≤ u)`, `(φ U ψ) ∈ u`" — this does not follow from `bx_le w u := g_content(w) ⊆ u.formulas`, because `φ U ψ` is not a `G(...)` formula and therefore does not transfer via g_content. BX5 self-accumulation produces the enriched Until inside `w.formulas` only, not inside `u.formulas`.
- **B-GAP (backward)**: Task 90 says "propagate `¬(φ U ψ)` forward along `w` via BX4 `connect_future`". But BX4 is `φ → G(P(φ))`, so this yields `P(¬(φ U ψ)) ∈ u` at every `u ≥ w`, not `¬(φ U ψ) ∈ u`. Cashing the `P` back through `bx_backward_witness` introduces a point `u'` with `bx_le u' u`, no guarantee that `bx_le w u'`, re-establishing the linearity gap task 90 claimed to have bypassed.

D and B did not investigate the forward/backward propagation step at the Lean-type level, which is why their confidence estimates are higher.

**The synthesis conclusion**: The task 90 recommendation is **a correct setup of the right ingredients plus a strategic direction, but not yet a complete proof sketch**. There are two specific points where the argument is currently hand-waved, and at least one of them (U5) may admit a rescue that was not discovered in a single research pass. Implementation must therefore begin with a **Phase 0 diagnostic gate** that attempts the hand-waved steps via `lean_multi_attempt` before committing the 8–16h budget.

---

## The Two Gaps in Detail

### Gap 1 — Forward direction step (U5): `(φ U ψ) ∈ u`

Task 90 sketch (paraphrased): Let `u` be an arbitrary point with `bx_le w u ∧ bx_le u v ∧ ¬bx_le v u`. By BX5 self-accumulation applied in `w`, `(φ ∧ (φ U ψ)) U ψ ∈ w`. "Therefore `(φ U ψ) ∈ u`." Now apply BX9 `until_elim` at `u` and — since `ψ ∉ u` by minimality of `v` — conclude `φ ∈ u`.

**Why this fails as written**:
- `bx_le w u` means `g_content(w) ⊆ u.formulas`, where `g_content(w) = { G χ ∈ w }` (Frame.lean:61).
- `(φ ∧ (φ U ψ)) U ψ` is an Until formula, not a `G(...)` formula, so it is **not** in `g_content(w)`.
- There is no Lean lemma `Formula.untl ... ∈ w → bx_le w u → Formula.untl ... ∈ u`. Teammate A confirmed by exhaustive grep: no `untl.*all_future`, `all_future.*untl`, `G.*untl` persistence hits. The only matches are antecedent forms in BX2/BX3 `*_mono_until`, which require a `G(φ → χ)` hypothesis we do not have.

**What task 90 likely meant but did not articulate**: The selection of `v` via BX7 + BX12 is supposed to make the `u`-guard *vacuous or trivially φ-witnessed*, not to propagate the Until formula forward. The sketch conflates "pick an earliest witness so the guard interval is tight" with "the Until persists on the interval". These are different claims and only the first is compatible with the axiom set.

**Candidate rescues** (from A/B/C open questions):

- **R1 (most promising)**: Do not attempt to propagate `(φ U ψ)` to arbitrary `u`. Instead, construct `v` via a **two-formula BX7 application** on `(φ U ψ) ∧ (⊤ U ψ) ∈ w` (BX12 supplies the second conjunct from `F(ψ) ∈ w`). The three disjuncts of BX7's conclusion are each Until formulas inside `w.formulas`. By repeatedly applying BX9 + BX10 + BX12 to each disjunct, derive that **the ψ-witness `v` constructed from `bx_forward_witness` on `F(ψ ∧ φ)` (if derivable) or similar** automatically has `φ` at all g_content-reachable intermediate points. This is essentially teammate B's `bx_earliest_until_witness` primitive. **However, teammate C correctly points out** that BX7 is still a formula-level disjunction in `w.formulas`, not an MCS-level selection. The rescue must therefore *not* rely on "BX7 picks the earliest v"; it must reason at the formula level throughout.

- **R2**: Search for a *derived* Until-persistence lemma via `generalized_temporal_k` applied to a clever derivation tree. Teammate A suggests `BX5 + BX6 + BX9 + BX10` combinations, but did not exhibit one. High uncertainty.

- **R3**: Construct `v` as a **Lindenbaum-minimum** MCS whose seed forces `¬bx_le v u` for all `u` in the strict interval — i.e., build `v` so the strict interval is empty by construction. Teammate A notes this is "at the edge of the task 90 scope fence" and would likely require new Lindenbaum infrastructure.

### Gap 2 — Backward direction (B-GAP): BX4 propagates `P`, not the formula itself

Task 90 sketch: From `¬(φ U ψ) ∈ w`, apply BX4 `connect_future` to "propagate `¬(φ U ψ)` forward along `w`".

**Why this fails as written**:
- BX4 at `Axioms.lean:146` is `connect_future φ : φ → G(P φ)`, i.e. `φ.imp (φ.some_past.all_future)`.
- Applied to `¬(φ U ψ) ∈ w`: `G(P(¬(φ U ψ))) ∈ w`. At every `u` with `bx_le w u`, this gives `P(¬(φ U ψ)) ∈ u`, not `¬(φ U ψ) ∈ u`.
- Cashing out the `P` via `bx_backward_witness` at `u` yields `u' ≤ u` with `¬(φ U ψ) ∈ u'`, but **no guarantee** that `bx_le w u'`.
- Teammate C highlights BX4's docstring explicitly disclaiming the Burgess-Xu Until-Since connectedness principle this step needs: *"This replaces the Burgess-Xu Until-Since connectedness axiom, which is not valid under half-open guard semantics."* Task 90 did not engage with this disclaimer.

**Candidate rescues**:

- **R4**: Instead of propagating `¬(φ U ψ)` forward, use **BX4' `connect_past`** (`φ → H(F φ)`, `Axioms.lean:151`) applied at `v` to `ψ`. This yields `H(F(ψ)) ∈ v`. Pulling back through `bx_H_forward` to any `u ≤ v` gives `F(ψ) ∈ u`, and `bx_forward_witness` then produces a ψ-point reachable from `u`. Teammate A's open question 4. **Does this actually link to `w`?** Unclear on paper.

- **R5**: Abandon the "propagate ¬Until" strategy entirely and prove `bx_until_backward` by **direct syntactic derivation**: given the guard hypothesis and `bx_le w v ∧ ψ ∈ v`, construct a DerivationTree for `(φ U ψ) ∈ w` using `or_until_imp` (`TemporalDerived.lean:338`, teammate B's find) and the fact that `ψ ∨ (φ ∧ (φ U ψ)) → (φ U ψ)`. This requires `φ ∈ w` (which BX9 + the guard at u=w provides) and a way to extract "the Until holds structurally" from the guard — still not obviously tractable.

---

## Axiom Role Audit (Forward & Backward)

Teammate C's axiom audit, corrected and extended:

| Axiom | Statement | Forward role | Backward role | Status |
|---|---|---|---|---|
| BX4 `connect_future` | `φ → G(P φ)` | — | Task 90 claimed "forward propagation"; **actually propagates G(P)**, not φ itself. B-GAP. | **Misapplied** |
| BX4' `connect_past` | `φ → H(F φ)` | Possible rescue path (R4) | Possible rescue path | Underutilized |
| BX5 `self_accum_until` | `(φUψ) → ((φ ∧ (φUψ)) U ψ)` | Enriches Until in `w.formulas`; does NOT propagate to `u`. | — | **Partial / at the bridge step** |
| BX6 `absorb_until` | `(φ U (φ ∧ (φUψ))) → (φUψ)` | Anti-deferral; non-negotiable for any Burgess-style argument. | — | Present, tooling unused |
| BX7 `linear_until` | `(φUψ) ∧ (χUθ) → 3-way disjunction` | Gives formula-level "linearity" of two Untils in one MCS; **not an MCS-level minimum selector**. | — | Present, formula-level only |
| BX9 `until_elim` | `(φUψ) → (φ ∨ ψ)` | Gives `φ ∈ w` when `ψ ∉ w`. Cannot be invoked at `u` unless `(φUψ) ∈ u` (blocked by Gap 1). | — | Present |
| BX10 `until_F` | `(φUψ) → Fψ` | Yields `F(ψ) ∈ w`, then `bx_forward_witness` → `v₀`. Sound. | — | Present |
| BX11 `temp_linearity` | `Fφ ∧ Fψ → F(φ∧ψ) ∨ F(φ ∧ Fψ) ∨ F(Fφ ∧ ψ)` | **Not used** in task 90 sketch despite being central to linearity discussion. Sketch is inconsistent or underused. | — | **Unused — investigate** |
| BX12 `F_until_equiv` | `Fφ → (⊤Uφ)` | Vacuous-guard lift: supplies the second Until for BX7 via F(ψ). | — | Present |

Since-duals (BX4', BX5', BX6', BX7', BX10', BX11', BX12') are all present at `Axioms.lean:151-264`.

**Key observation**: BX11 `temp_linearity` is cited in task 90's linearity discussion as "mistakenly believed absent" but does not appear in the actual proof sketch. Either it has a hidden role the sketch does not make explicit, or it is actually unnecessary and its "restoration" from task 89 was a distraction. This should be clarified early in Phase 0.

---

## Since-Mirror Construction

Task 90 claims "Mirrors apply for Since via BX5/6/7/10/11/12-primes." Teammate C identified a **non-trivial directional asymmetry** that task 90 did not audit:

- The Since eventuality-resolution signature at `Frame.lean:683-688` has guard `∀ u, bx_le v u ∧ ¬bx_le u v → bx_le u w → φ ∈ u.formulas`.
- The guard universal quantifies over `u` strictly between `v` (past witness) and `w` (current point). The inner `u` is simultaneously future of `v` and past of `w`.
- Mirroring Gap 1 (the BX5'-based propagation step) requires propagating `(φ ∧ (φ S ψ)) S ψ` from `w` **backwards** via `bx_le u w`, which is `g_content(u) ⊆ w.formulas`. But `bx_le u w` is a G-content subset in the *opposite* direction to the forward case, and the Since-formula is not an `H(...)` formula, so it does not propagate via h_content either.

The Since case therefore **inherits Gap 1** with an additional asymmetry: the guard interval anchors between a past witness and the current point, and the proof must use both `bx_forward_witness` (or its past-dual) and `bx_backward_witness` coherently.

**Implication**: The mirror is **not** free. If the forward case rescue R1/R2/R3 works, its Since-mirror must be separately validated. Budget an extra 4-8 hours specifically for Since-asymmetry auditing.

---

## Synthesized Recommendation

### Phase 0: Diagnostic Gate (≤ 3 hours, mandatory)

Before committing the full 8-16h implementation budget, run the following probes via `lean_multi_attempt` / `lean_goal` at `Frame.lean:653` and `:675`:

**Probe 1** — BX5 self-accumulation propagation:
Given `(φ U ψ) ∈ w.formulas` and `bx_le w u`, attempt to derive `(φ U ψ) ∈ u.formulas` or `φ ∈ u.formulas` directly. Expected: failure. If failure confirmed, record the precise type of the stuck goal — this is the formal statement of Gap 1.

**Probe 2** — BX7 two-formula application:
Derive `(⊤ U ψ) ∈ w.formulas` from BX10 + BX12, then apply BX7 `linear_until φ ψ ⊤ ψ` in `w.formulas`. Inspect the three-way disjunction. Attempt to extract an MCS-level "earliest" witness from each disjunct via BX10 + `bx_forward_witness`. Record whether any disjunct actually yields a `v : BXPoint` whose guard is automatically discharged.

**Probe 3** — BX4 backward direction:
Given `¬(φ U ψ) ∈ w.formulas` and `bx_le w v ∧ ψ ∈ v`, apply BX4 `connect_future` to get `G(P(¬(φ U ψ))) ∈ w`, transfer to `v`, take backward witness `u' ≤ v`. Attempt to prove `bx_le w u'`. Expected: failure (B-GAP confirmed).

**Probe 4** — BX4' `connect_past` alternative:
Given `ψ ∈ v`, apply BX4' to get `H(F ψ) ∈ v`. Pull back to arbitrary `u ≤ v` via `bx_H_forward`. Attempt to derive a contradiction with the guard hypothesis + the assumption `¬(φ U ψ) ∈ w`. Record whether this path closes.

**Probe 5** — Derived Until-persistence search:
Run `lean_leansearch` / `lean_state_search` with goal `Formula.untl φ ψ ∈ w.formulas → bx_le w u → Formula.untl φ ψ ∈ u.formulas ∨ ψ ∈ u.formulas`. Record any hits or clear refutation.

**Probe 6** — BX11 `temp_linearity` role:
Search for any use of `temp_linearity` in the existing codebase. If zero uses exist, document the axiom as "available but unused in Burgess-Xu sketch" and note it as a candidate for the forward rescue R1 (it may actually be the right tool for picking an MCS-level earliest witness when combined with BX10 twice).

### Decision Tree After Phase 0

| Outcome | Action |
|---|---|
| Probes 1+3 fail AND Probe 5 finds no derived persistence AND Probes 2/4 both fail | **Escalate: `/spawn 92` immediately** with blocker "BX5 propagation gap and BX4 connectedness disavowal both unrescued". Create task 94 to investigate either (a) a new derived persistence lemma, (b) a quasimodel pivot, or (c) revised axiom set. Task 92 goes `[BLOCKED]`. |
| Probe 2 yields an MCS-level earliest witness construction | Proceed with teammate B's `bx_earliest_until_witness` primitive as the core helper. Implement Phase 1 via R1 rescue. |
| Probe 4 closes the backward direction via BX4' | Proceed with Phase 2 via R4 rescue, adjusting the comment at `Frame.lean:674` to cite BX4' instead of BX4. |
| All probes succeed | Proceed with the full Burgess-Xu plan as task 90 outlined, but with the corrected axiom-role table from this report. |
| Phase 0 runs past 3 hours without a clear outcome | Pause, write findings to a revised report, and re-plan. Do not extend Phase 0 silently. |

### Phase 1-5: Implementation (only if Phase 0 succeeds)

Follow teammate D's module structure recommendation with the following named helpers:

```
BXCanonical/UntilHelpers.lean  (new file, ~250-350 LOC)
├── bx_vacuous_guard_lift        -- BX12: F(ψ) → (⊤ U ψ)
├── bx_earliest_until_witness    -- The primitive from teammate B / rescue R1
├── bx_until_forward_prefix      -- Whatever Phase 0 Probe 2/5 yields for Gap 1
├── bx_not_until_backward_pull   -- Whatever Phase 0 Probe 3/4 yields for Gap 2
├── Since-duals of all four     -- Separately validated; do not assume symmetry
└── Prose block: "Linearity Gap Narrative" (see teammate D)
```

Thin wrappers at `Frame.lean:653/675/690/704` call these helpers. Frame.lean shrinks by 80-120 lines.

### Phase 6: Documentation & Memory

Per teammate D's quality-bar recommendations:

1. **Rewrite comments** at `Frame.lean:585-622` (module docstring), `:647-651`, `:674`. **Do NOT delete** the existing "G-content vs Until-witness mismatch" analysis — teammate C is correct that it is historically accurate. Instead, extend it with a "Task 92 resolution: Burgess-Xu substitute for linearity" subsection that explains *how* the resolution works (prose block from teammate D section "Linearity Gap Narrative").

2. **Update `specs/ROAD_MAP.md`** Active-Path Sorry Inventory: remove rows 2, 3, 4, 5 (the 4 sorries closed by task 92). Update the critical-path diagram.

3. **Create memory entries** (via `/learn --task 92` after completion):
   - `bx_le-is-g-content-subset-intentionally.md`
   - `until-via-burgess-xu-not-linearity.md`
   - `bx7-linear-until-is-local.md`
   - (optional) `bxcanonical-file-layout.md` if the UntilHelpers split is adopted

4. **Light soundness test** in `Tests/BimodalTest/`: pick a concrete instance (e.g., `F(ψ) ↔ ⊤ U ψ` as a theorem) and verify canonical-model truth evaluation. Smoke test catches silent regressions during task 93.

---

## Revised Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Phase 0 Probe 1 fails (BX5 propagation gap is terminal) | **60%** | Phase 1 unclosable as task 90 sketch | R1 rescue via BX7 two-formula construction (Probe 2); if Probe 2 also fails, `/spawn 92`. |
| Phase 0 Probe 3 fails (BX4 backward direction unrescued) | **55%** | Phase 2 unclosable as task 90 sketch | R4 rescue via BX4' connect_past (Probe 4); if Probe 4 also fails, `/spawn 92`. |
| Both Probe 2 and Probe 4 rescues fail | **30%** | Task 92 goes `[BLOCKED]`, spawn task 94 | Pre-approve this outcome. Treat it as *correct* research behavior, not failure. |
| Task 90 plan succeeds as literally written | **15%** | Fastest path (8-16h) | Phase 0 confirms; proceed with D's module structure. |
| Task 90 plan succeeds with R1/R4 rescues | **45%** | Slower path (12-20h) | Phase 0 identifies rescue; Phase 1-5 proceed with revised helpers. |
| Since mirror asymmetry (teammate C Issue 5) adds hours mid-implementation | **60%** | +4-8h | Audit Since guard structure in Phase 0 Probe 6 adjunct. |
| Comment rewrite deletes accurate history | **90% if not explicitly prevented** | Regression in documentation accuracy | Plan Phase 6 must *extend*, not *replace*, the existing comment. |
| 8-16h estimate blown | **75%** | Schedule slip | Revise upfront to **12-24h** including Phase 0 diagnostic; communicate uncertainty. |

**Net confidence in task 92 closing all 4 sorries via task 90's plan**: **≈ 50%** (weighted mean of teammate confidences, adjusted for the severity of the gaps A and C identified).

**Net confidence in task 92 closing all 4 sorries via *some* BX-compatible path** (task 90 plan, R1+R4 rescues, or a Phase 0-discovered variant): **≈ 75%**.

**Net confidence in the task going [BLOCKED] and correctly spawning task 94**: **≈ 25%**.

---

## On the "Linearity Gap" Comments at Frame.lean:647-651 and :674

**Teammate A and C both flagged** that task 90's characterization of these comments as "misleading" is itself inaccurate. The existing comments document the (correct) finding that a `bx_le_linear`-style lemma is not derivable from BX7 + BX11 + BX12 at the MCS level. This is sound analysis.

What task 90 *should* have said: the comments are **incomplete**, not wrong. They describe the obstruction to one approach (direct interval linearity) without mentioning that a Burgess-Xu substitute exists. The correct action in Phase 6 is:

1. **Preserve** the existing comments verbatim as historical analysis under a "Why we thought this was blocked" or "Pre-task-92 analysis" heading.
2. **Append** a new "Task 92 resolution" subsection that explains the Burgess-Xu substitute and cites the new `UntilHelpers.lean` module.
3. **Do not** delete `"X-vs-G mismatch"` as a term — it is still the correct diagnosis of *why* direct linearity fails. Reclassify it from "blocker" to "motivation for Burgess-Xu substitution".

---

## Estimate

**Phase 0 Diagnostic Gate**: 2-3 hours (hard cap).

**If Phase 0 succeeds**:
- Phase 1 (forward Until eventuality resolution): 3-5 hours
- Phase 2 (backward Until): 2-4 hours
- Phase 3 (Since forward mirror with asymmetry audit): 3-5 hours
- Phase 4 (Since backward mirror): 2-4 hours
- Phase 5 (helper extraction to UntilHelpers.lean, if adopted): 1-2 hours
- Phase 6 (comment rewrite, ROAD_MAP update, memory entries, sanity test): 2-3 hours
- **Total: 13-23 hours** (upward revision of task 90's 8-16h, reflecting the gaps exposed here)

**If Phase 0 fails both Probe 1/2 and Probe 3/4**:
- Phase 0 diagnostic (3h) + `/spawn 92` task-94 creation (0.5h) + task 92 → `[BLOCKED]` (0.5h)
- **Total: 4 hours**, with task 92 blocked pending task 94 resolution.

---

## Scope Fence

Task 92 scope remains as task 90 specified:

- **Closes**: Frame.lean:653 (`bx_until_eventuality_resolution`), Frame.lean:675 (`bx_until_backward`), Frame.lean:690 (`bx_since_eventuality_resolution`), Frame.lean:704 (`bx_since_backward`).
- **Does NOT close**: Frame.lean:440 (Box modal witness — task 93), Completeness.lean:154 (TaskModel embedding — task 93).
- **May introduce**: A new file `BXCanonical/UntilHelpers.lean` (per teammate D, if Phase 0 succeeds).
- **Will modify**: `Frame.lean:585-622` (module docstring), `:647-651`, `:674` (comment rewrites — *extend*, do not replace).
- **Will NOT modify**: Axioms.lean (no axiom additions or changes), `bx_le` definition (stays `g_content ⊆`), any other file unless required for the UntilHelpers import.

**Cross-dependency with task 93**: Teammate C verified the 4 Until/Since lemmas do not depend on `box_preserved_along_bx_le` being sorry-free at line 440 or on the TaskModel embedding. Task 92 and task 93 are mathematically independent.

---

## Open Questions Forwarded to Implementation

1. **Does BX11 `temp_linearity` have a hidden role in the sketch, or is it genuinely unused?** Resolve in Phase 0 Probe 6.
2. **Is there a derived Until-forward-persistence lemma via `generalized_temporal_k` applied to a clever derivation tree?** (Teammate A Q1) Resolve in Phase 0 Probe 5.
3. **Can `v` be constructed as a Lindenbaum minimum on `g_content(w) ∪ {ψ}` forcing an empty strict interval?** (Teammate A Q2) Resolve as a fallback if Probes 2 and 4 both fail — likely requires new Lindenbaum infrastructure and is at the scope-fence edge.
4. **For the Since case, does the `u ∈ [v, w]` interval admit the same rescues as the Until case, or is the two-direction coherence a separate theorem?** Resolve in Phase 0 Probe 6 adjunct.
5. **Is `bx_earliest_until_witness` as formulated by teammate B actually derivable, or is it a restatement of Gap 1?** Teammate C's Issue 3 argues the "earliest ψ-witness" notion is ill-defined at the BXPoint level. Resolve in Phase 0 Probe 2.
6. **What is the `/spawn 92` budget?** Recommended: if Phase 0 fails both Probe 1/2 and Probe 3/4, spawn immediately. Do not attempt Phase 1 on an unvalidated sketch.

---

## Conflicts Resolved

| Conflict | Resolution | Evidence |
|---|---|---|
| Teammate A/C "sketch has gaps" vs Teammate B/D "sketch is sound" | A and C are correct about the literal sketch; B and D did not walk the sketch against the Lean types. Synthesis: sketch has real gaps, but rescues may exist. | A's `lean_goal` inspection at `Frame.lean:653`, `:675`; C's axiom audit showing BX4 docstring disclaimer. |
| Teammate B "earliest-witness primitive" vs Teammate C "earliest-ness is formula-level only" | B's primitive name is acceptable *only if* Phase 0 Probe 2 shows an MCS-level extraction works. C's objection is valid but Phase 0 can definitively resolve it. | Both rely on interpretation of BX7's three-way disjunction. Phase 0 probes it directly. |
| Teammate D "comments are misleading, rewrite" vs Teammate C "comments are accurate, preserve" | C is correct. D's intent was to update the narrative, not to delete accurate history. Resolution: Phase 6 *extends* the comments with a new subsection rather than replacing them. | Existing comment content matches task 90 Phase 1 diagnostic verdicts. |
| Confidence estimates (A medium-low, B high, C 25%, D 88%) | Weighted mean ≈ 50% on literal task 90 plan; 75% on some BX-compatible variant; 25% on `[BLOCKED]`. Phase 0 will rapidly resolve the spread. | Each teammate's confidence reflects what they investigated; A/C walked proofs, B/D audited structure. |
| Teammate D "88% confidence, proceed aggressively" vs synthesis "Phase 0 gate mandatory" | Phase 0 is cheap insurance (≤3h) against a 25% probability of `[BLOCKED]`. The expected value of running it is strictly positive. Proceed with Phase 0. | Risk assessment table. |

---

## Gaps in the Research (Honest Accounting)

1. **No teammate actually attempted the rescues R1/R4 in Lean**. They are hypothesized paths, not validated. Phase 0 of implementation must do this.
2. **PDF extraction failed** for Verbrugge, Venema, and the LIPIcs paper (teammate B's sandbox had no `pdftotext`). The prior-art survey relies on abstracts and Stanford Encyclopedia summaries for those sources. A direct read of Verbrugge's "Completeness by construction" could add concrete tactic guidance.
3. **No teammate ran the Phase 0 probes**. This is the most important follow-up. All research conclusions are conditional on Phase 0 outcomes.
4. **Task 89 artifacts were not fully re-read** in this round (teammate C referenced them but did not quote from task 89's team-research report in detail). Worth a quick re-read before implementation begins.
5. **The `Bimodal.Theorems.TemporalDerived.or_until_imp` helper** identified by teammate B at `TemporalDerived.lean:338` was not walked against Gap 1 specifically. It may be the key to direct R5-style syntactic derivation in the backward direction.

---

## Recommendation to the Planner (`/plan 92`)

1. **Adopt a 7-phase plan**: Phase 0 diagnostic, Phases 1-4 (Until forward, Until backward, Since forward, Since backward), Phase 5 (helper extraction and restructuring), Phase 6 (documentation + memory + sanity test).
2. **Phase 0 is a hard gate**: if any of Probes 1, 3 fail AND their corresponding rescue probes (2, 4) also fail, `/spawn 92` to create task 94 and mark task 92 `[BLOCKED]`. Do not continue to Phase 1 on an unvalidated sketch.
3. **Budget revised upward** to 13-23 hours from the task 90 estimate of 8-16 hours. Communicate the revision.
4. **Preserve existing comments** at `Frame.lean:647-651` and `:674` as historical analysis; do not delete. Extend with Burgess-Xu resolution narrative.
5. **Create UntilHelpers.lean** if Phase 0 succeeds — do not inline the 4-lemma Burgess-Xu kernel into Frame.lean. Downstream reusability is real.
6. **Memory harvest** is part of task 92 completion, not a separate task.
7. **Treat `[BLOCKED]` + task 94 as an acceptable outcome**. It is the correct scientific response if the gaps cannot be bridged.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key contribution |
|---|---|---|---|---|
| A | Primary | completed | medium-low | Identified Gap 1 (U5) and Gap 2 (B-GAP) by walking sketch against Lean types. Produced tactic-level skeletons with explicit `[GAP]` markers. |
| B | Alternatives | completed | medium-high | Exhaustively rejected 6 alternatives with prior-art survey. Proposed `bx_earliest_until_witness` primitive. Identified `or_until_imp` helper at `TemporalDerived.lean:338`. |
| C | Critic | completed | 25% | Three BLOCKER-severity issues. Phase 0 diagnostic gate proposal. Defense of existing comments as accurate historical analysis. Since-mirror asymmetry flag. |
| D | Horizons | completed | 88% | Completeness critical path diagram. `UntilHelpers.lean` module structure. 4 memory entry proposals. Linearity Gap Narrative prose block. Quality bar recommendations. |

---

## References

### Reports
- Task 90 recommendation: `specs/090_research_bx_le_redefinition/reports/03_task92_recommendation.md`
- Task 90 bx_le_linear diagnostic: `specs/090_research_bx_le_redefinition/reports/02_bx_le_linear_diagnostic.md`
- Task 92 inherited research: `specs/092_implement_bx_until_truth_lemma/reports/01_inherited-from-task90.md`
- Task 89 team research (superseded but relevant): `specs/089_*/reports/01_team-research.md`

### Code
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (lines 61, 164-171, 192-195, 208-257, 440, 501-583, 585-622, 647-651, 653, 674, 675, 683-688, 690, 704)
- `Theories/Bimodal/ProofSystem/Axioms.lean` (lines 140-264 — BX4, BX4', BX5, BX5', BX6, BX6', BX7, BX7', BX8, BX8', BX9, BX9', BX10, BX10', BX11, BX11', BX12, BX12')
- `Theories/Bimodal/Theorems/TemporalDerived.lean` (lines 41, 190, 264, 338-352 — derivation-tree helpers, especially `or_until_imp`)
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` (lines 81, 111, 145, 185, 199 — FMCS-level proof-pattern template)
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` (deprecated anti-template, 6 sorries)

### Prior Art
- Burgess 1982, "Axioms for tense logic. I. Since and Until", Notre Dame J. Formal Logic 23(4):367-383
- Xu 1988, "On some U, S-tense logics", J. Phil. Logic 17:181-202
- Verbrugge, "Completeness by construction for tense logics of linear time" (Festschriften D65)
- Goldblatt, "Logics of Time and Computation" (2nd ed., CSLI, cited in `Frame.lean:33`)
- Venema, "Temporal Logic" (staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- Stanford Encyclopedia of Philosophy, "Temporal Logic"

### Lean 4 / Mathlib
- `mrigankpawagi/LeanearTemporalLogic` — semantic LTL, `ltl_expansion_until`
- `ljt12138/Formalization-PAL` — S5 Henkin canonical model template
- LIPIcs.ITP.2024.28 — Lean coalition logic completeness (filtration-based; not applicable here)
- arXiv:2507.01780 "LeanLTL" — tableau-based (not applicable)
