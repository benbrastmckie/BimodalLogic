# Research Team Synthesis — Task 340 Phase 5 Blocker

**Session**: sess_1783561356_89aa2d (multi-task orchestrate 340→337→335, --hard --opus)
**Trigger**: Task 340 implementation reached partial (Phases 1-4+6 green/sorry-0/axiom-clean); Phase 5 deferred as a "design boundary co-located with 337."
**Team**: 3 parallel `lean-research-hard-agent`s, distinct territories (H7).
**Inputs**: reports/02 (Rabinovich faithfulness), 03 (Lean carrier), 04 (337 interface).

## Headline

**The blocker was mis-framed. Phase 5 is resolvable — no carrier type change, no vacuous placeholder, no fifth carrier layer.** All three agents converge: the enriched per-slot global-index carrier (340 Phases 1-4) is faithful, terminal, and already rich enough to express the honest cross-region interleaving. Phase 5 is a *model-dependent selection lemma over the existing carrier*, and it stays split from 337 with a clean, acyclic interface.

## Convergent findings

### 1. The carrier is faithful and terminal (Agent A — Rabinovich)
- The per-slot global index — a `Nodup` total order on the full cross-owner slot multiset, linearly extending each owner's region order `lXU<lX1<lUW` — is a correct finite encoding of Rabinovich **Def 3.1**'s single strictly-increasing chain (md:63-74), enumerated over all order-consistent interleavings by **Lemma 3.2(1)** (md:77), generalized to multiple owners by **Def 7.13** (md:202).
- It is the **terminal** representation: a total order over a fixed finite point set admits no further refinement. No fifth carrier layer is warranted.
- The `a < u' < b` interleaving (σ's `lUW` below τ's anchor) is a genuine Rabinovich §5 disjunct (md:161-173) — admitting it *repairs* task 339's unfaithful under-approximation, not an over-generalization.
- The paper locates model contact in **exactly one place** (Prop 4.3 all-chains equivalence md:103-115; Insight #3 md:221-222: Dedekind-completeness "used in exactly one place"): the **realization/witness layer = task 337's per-M construction**. The 340/337 seam sits exactly on Rabinovich's formula-level/realization-level boundary.

### 2. The obstruction is a strawman (Agent B — Lean carrier)
- The blocker **conflated two obligations**:
  - `kvE2_sepBody_complete` (SW:1830-1838) concludes only `kvE2_sepArr' qnf ≠ []` — pure **non-vacuity**, already sorry-free via the placeholder coincident order. Needs nothing.
  - The genuine Phase-5 obligation is the **latent RHS of `kvE2_sepBody_holds_iff`** (SW:1111-1113): `∃ wo ∈ kvE2_sepArr' qnf, (kvE2_sepDisjunct … (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds M …`.
- Adversarial result: the obstruction is real **only** for the narrow claim "make the fixed `qnf → KvE2SepWeakOrder` function value-faithful" (a fixed function can't track every M) — **false** for the actual goal. The carrier type `ℕ×ℕ×ℕ` is unchanged; `kvE2_sepIdxTuples` enumerates all of `[0,3n)³` (SW:734-737); validity's `i₀<i₁<i₂ + Nodup` (SW:828-832) admits any honest model order (M refines each owner's region order; distinct anchors → distinct bases).
- **Resolution**: Phase 5 = a model-dependent **selection lemma** `∃ wo ∈ kvE2_sepArr', monotone-in-M`, in **340/SharedWitness**, over the existing carrier, needing one trivial enumeration-richness lemma (`kvE2_sepIdxTuple_mem_of_lt`) + membership/monotonicity. `kvE2_sepCoincidentOrder` stays as-is for non-vacuity.
- Boundary object imported from 337: `hreal` — the per-slot honest realized global order + `.holds` construction (`kvE_subBracket2V_sound_of_parts`, SubBracket2V.lean:1025, referenced at SW:1927).

### 3. Keep-separate, no cycle, but strengthen the interface (Agent C — 337 engine)
- `k1v_sorted_realizationK` (SubBracket2V.lean:633-646) already emits one globally strictly-monotone chain (`interleaveK ps`) — but only when fed a **single boundary-linked anchor chain** (`hlink`) with per-region types realized strictly interior (`hreal`). It is the monotone-sequence *realizer*, already landed/green — **not** a cross-owner merger.
- The honest bundles (`kvE2_sepHonestBundleL/R`, SW:1471-1565) give each owner an **independent** anchor `x1_σ` with no cross-owner relation — precisely the gap 340's global index closes (`kvE2_sepSlotGIdx` SW:921-928, single-level `mergeLe` SW:936-938). A `wo` matching the true model value order now exists (impossible under 339's region-primary key; report 06's `omega`-refuted below-anchor case).
- The implementer's `∃ wo, SlotsLOf wo monotone` interface is the right direction but **too weak** — it must hand 337 the engine's precondition bundle (`hpos/hlink/hnd/hreal` in genuine M-value order for `SlotsLOf/ROf wo`) — the realized value assignment, not just order-existence.
- **Verdict: keep-separate, lightly re-scoped.** 340 Phase 5 = bracket-independent honest→value-order aggregation (collect+sort+linear-extension over existing per-owner bundles, **derivable for free from M's `LinearOrder` — no new model data or axioms**). 337 owns the engine invocation + the `kvE2_sepBracketN` single-`ptW` point-type match (the only bracket-entangled step).
- **No circular dependency**: 340-P5→337 is a linear shared-subgoal chain over the already-green engine; 340-P5 consumes nothing 337 produces.

## Reconciled co-design contract

| Owner | Deliverable | Nature |
|-------|-------------|--------|
| **340 Phase 5** (SharedWitness) | `∃ wo ∈ kvE2_sepArr' qnf`, with `kvE2_sepSlotsLOf/ROf wo` in genuine M-value order + realized per-slot value assignment (aggregated from per-owner honest bundles) | bracket-independent; free from M's `LinearOrder`; one enumeration-richness lemma |
| **337** | Consume that bundle → build `hlink/hreal/hpos/hnd` → invoke `k1v_sorted_realizationK` → match `interleaveK` chain to `kvE2_sepBracketN` IntervalPattern point types → discharge endpoint conjuncts → `.holds` | bracket-entangled; the only M-realization step |

Together these discharge `kvE2_sepBody_holds_iff.mpr` (`∃ wo, .holds M`). Unblocking signature (Agent B): `kvE2_sepBody_complete_holds`.

## Corrections to apply (Agent A caveats)
- **R1 (citation precision)**: The 340 plan's H3 table (lines ~75-77) mis-grounds the single-chain / linear-extension claim on Lemma 3.2(1) md:77 alone (md:77 states only "conjunction ≡ disjunction"). Re-ground chain content on **Def 3.1**; multi-owner union on **Def 7.13**. (The earlier 337 report already cites correctly.)
- **R2 (residual rigor)**: One outstanding H3 item — a PDF spot-check of Def 3.1's reference-point placement and Def 7.13's union (verdict rests on the summary markdown).

## R2 PDF spot-check — COMPLETE (verdict HOLDS, citation refined)

Verified Def 3.1 / Lemma 3.2 (PDF p.4) and Def 7.13 / Lemma 7.6 (PDF pp.14-15) against the source, not the summary markdown.

- **Def 3.1 CONFIRMED (p.4)**: The ∃∀-formula has a *single* strictly-ordered existential chain `x_n > x_{n-1} > … > x_1 > x_0`; reference points are placed *onto* the chain via `z_k = x_{i_k}` (with `i_0,…,i_m ∈ {0,…,n}` free); interval decomposition = `α_j` at points, `β_j` along open `(x_{j-1}, x_j)`, `β_0` before `x_0`, `β_{n+1}` after `x_n`. → The Lean `Nodup` total order extending each owner's region order is a **faithful finite encoding**. The free `i_k` placement is exactly what admits the `a < u' < b` interleaving (σ's interior point below τ's anchor) — **the paper permits it**, so 340 repairs 339's under-approximation rather than over-generalizing. ✓
- **Lemma 3.2(1) CONFIRMED verbatim (p.4)**: "Conjunction of ∃∀-formulas ≡ disjunction of ∃∀-formulas." This is the correct grounding for the **enumeration** `kvE2_sepArr'` over order-consistent interleavings (conjoin owners' ∃∀ → disjunction, one disjunct per interleaving). It does **not** itself assert the single-chain order — that is Def 3.1. **Agent A's R1 is validated.**
- **Def 7.13 CONFIRMED (p.15)**: `(z_0,…,z_k,∞)`-∃∀ = conjunction `⋀_{i≤k} φ_i` of per-segment ∃∀ over distinct ordered `z_0 < … < z_k`; ∨-version is a disjunction. Lemma 7.6 (p.14) gives closure under the `∃z_1` merge. → Grounds the **multi-reference-point / depth-k≥2 segment framing**. Note: Def 7.13's segments are *sequential*; the cross-owner **interleaving** inside the merged chain is licensed by **Lemma 3.2(1)**, not Def 7.13.

**Refined R1 fix for the plan's H3 table (lines ~75-77)**:
- Row 75 ("single global chain over the union"): already cites *both* Def 3.1 (chain) + Lemma 3.2(1) (union-enumeration) — **acceptable as-is**.
- Row 76 ("linear extension of each owner's region order"): the gloss `Lemma 3.2(1) "one consistent global order over the union"` is imprecise — Lemma 3.2(1) says only conjunction≡disjunction. **Correct to**: Def 3.1 per-owner interval order + Lemma 3.2(1) (disjuncts are exactly the order-consistent interleavings). Optionally add Def 7.13 for the multi-segment framing.

**R2 verdict: the faithfulness + terminality verdict HOLDS unchanged.** A total order over a fixed finite point set admits no refinement → terminal carrier confirmed. Only a citation-precision edit (row 76) is warranted; no design change.

## Recommended next actions
1. **Revise task 340 plan**: rewrite Phase 5 as the model-dependent selection/aggregation lemma over the existing carrier (drop the "carrier change / co-located-can't-proceed" framing); apply R1 citation fix.
2. **Revise task 337 plan**: pin the strengthened interface (engine precondition bundle `hpos/hlink/hnd/hreal`, not mere order-existence) as its input contract from 340-P5.
3. **Resume implementation**: 340 Phase 5 → then 337 → then 335. No task merge, no re-scoping of 335.
4. Optional: PDF spot-check (R2) before final axiom-clean sign-off.
