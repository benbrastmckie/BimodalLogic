# Teammate D Findings: Strategic Horizons for Task 303

**Role**: Horizons researcher — long-term alignment, strategic direction, creative approaches
**Date**: 2026-06-16
**Task**: Close `existPart_succ_n1_bypass` k>0 (KampBypass.lean) via Rabinovich Section 5 Lemma 5.1

---

## Key Findings

### 1. Post-303 Critical Path: There IS a Second Sorry Chain

**Finding (HIGH CONFIDENCE)**: Task 303 alone does NOT make `completeness_discrete` sorry-free. The ROADMAP (lines 71-82, verified 2026-06-09) documents a SECOND independent sorry chain — the **Stavi chain** — that also blocks `completeness_discrete`:

```
nf_2var_existential_transfer (StaviCompleteness.lean:2353, 2435)
  → nf_2var_from_interval_data
  → nf_exist_sf_guarded_backward (StaviCompleteness.lean:2805)
  → nf_2var_exist_sf_classical → nf_characterizable_by_stavi
  → stavi_expressive_completeness (GHR93 Theorem 9.3.1)
  → US_expressively_complete_over_prior (PriorExpressiveness.lean:384)
  → gap_prior_UZ_contradiction (GoodStructuresModelSurgery.lean:1169)
  → no_gaps_discrete_model_surgery → completeness_discrete
```

The **root sorry** is `nf_2var_existential_transfer` at the `j'+1` case, which needs 4-variable existential transfer to prove 3-variable NF agreement. This is GHR93 Proposition 7.

**The Reynolds chain** (the one Task 303 targets) is:
```
completeness_discrete → ... → existPart_succ_n1_bypass (k>0 sorry at KampBypass.lean)
```

Both chains must be closed for a sorry-free `completeness_discrete`. Task 303 closes the Reynolds chain; a separate task is needed for the Stavi chain.

**Implication for 303 scope**: Task 303 as scoped (closing only the k>0 sorry) is correctly scoped — it should not attempt to absorb the Stavi chain. But the team lead should be aware that task 303 completion is necessary but not sufficient.

### 2. Next Bottleneck After Task 303

After Task 303 closes the Reynolds chain sorry:
1. **Stavi chain becomes the sole blocker** — `nf_2var_existential_transfer` at `j'+1`
2. The fix is a **generalized existential transfer by strong induction on depth j**, universally quantified over arity n (GHR93 Proposition 7). At each inductive step, `zone_match_witness` provides the matching point, and the IH at lower depth (with higher arity) provides the transfer.
3. Task 95 (verification pass on sorry status) should be re-scoped: it assumes only the Reynolds chain; after 303, its primary value becomes auditing and classifying the Stavi chain sorries.
4. Task 299 (refactor DiscreteGameTransfer.lean) remains blocked until BOTH chains close.

### 3. Infrastructure Reuse from Task 273

Task 273 delivered ~1400 lines of sorry-free proofs across the four KampBypass files (now split as KampBypassCore, KampBypassUntil, KampBypassSince, KampBypass). The k=0 infrastructure is the **direct template** for k>0:

- **Pattern to replicate**: The k=0 case dispatches on `sub_nf.1 (.order ...)` to produce Until/Since/Eq sub-cases, then calls direction-specific bypass theorems. The k>0 case will use Rabinovich Section 5 Lemma 5.1 (interval-splitting induction): reduce the k+1 case to the k case by splitting the interval at intermediate points.
- **Patterns to avoid**: Task 273 had multiple divergences from the literature (BracketFormula ordering flaw, conjunction-of-existentials unsoundness). The k>0 case should follow Rabinovich faithfully from the start rather than attempting novel shortcuts.
- **Key infrastructure already sorry-free**: `KampBypassCore.lean` (2160 lines), `KampBypassUntil.lean` (979 lines), `KampBypassSince.lean` (1307 lines). The k>0 proof can import these directly.

### 4. Generalization Opportunities

**The k>0 infrastructure serves the project in a contained way.** Task 303 closes the specific sorry at `existPart_succ_n1_bypass (k : Nat)` for the succ k' branch. This is not a candidate for further generalization along variable count axes (n=1 is already the correct specialization for the Prior structure argument; the general n case is handled by `stavi_expressive_completeness` which is the Stavi chain's endpoint). Attempting to generalize beyond what Rabinovich requires would risk introducing new sorries or deviating from the literature's proof structure.

**Strategic recommendation**: Scope Task 303 exactly to the Rabinovich Lemma 5.1 induction for the k>0 succ case. Do not expand scope to arbitrary n.

### 5. Publication Readiness Impact

Tasks 292, 293, 294, 180 (publication quality work) are in **Wave 2** — they all depend on Task 303 completing. The sorry at k>0 is **not** the only thing blocking publication-ready discrete completeness; the Stavi chain must also close. However, Task 303 is the more tractable of the two (estimated 200-400 lines vs. the Stavi chain's more complex GHR93 Proposition 7 induction).

For a Lean 4 formalization paper:
- Both sorry chains must close (303 + Stavi task)
- After that: tasks 95 (audit), 293 (Mathlib linter), 292 (copyright headers), 294 (ModalS5 sorry elimination)
- Structural improvement that should accompany 303: task 299 refactor of DiscreteGameTransfer.lean can proceed immediately after 303, before the Stavi chain closes

### 6. Dense Completeness Independence

`countermodel_dense` is described as "internally sorry-free" (ROADMAP line 25). The dense path uses a different construction (Chronicle with natural inclusion X ⊂ ℚ) and does not depend on KampBypass or the Stavi chain. Task 303 has no effect on the dense completeness path. They are fully independent.

### 7. Task 95 and Task 299 Relationship to 303

- **Task 95** (dependency: 303): currently scoped to audit `completeness_discrete` and `bx_completeness`. After 303, its scope should expand to confirm the Stavi chain is the new blocker and produce a fresh sorry classification. The current state.json description refers to outdated sorry sites.
- **Task 299** (dependency: 303): refactor DiscreteGameTransfer.lean. This is purely cosmetic cleanup and can proceed once the Reynolds chain (303) closes, independent of the Stavi chain. It is correctly scoped.

---

## Recommended Approach

### Strategic Priority Order

1. **Task 303 first, fully scoped to Reynolds chain**: Close `existPart_succ_n1_bypass k>0` via Rabinovich Lemma 5.1 induction. Do not attempt to absorb Stavi chain work into this task.

2. **Create a new task for the Stavi chain** (not 303's scope): `nf_2var_existential_transfer j'+1` via GHR93 Proposition 7 strong induction. Estimated: larger effort than 303. The fix is: prove generalized existential transfer by strong induction on depth j, universally quantified over arity n. ROADMAP lines 80-82 document the architecture.

3. **Task 95 after both chains close**: Re-scope to full sorry audit across the production path, not just the Reynolds chain.

4. **Task 299 after 303** (before Stavi chain): Refactor DiscreteGameTransfer.lean since it only depends on the Reynolds chain.

### For Task 303 Implementation

- Follow Rabinovich 2014 Section 5 Lemma 5.1 faithfully (literature fidelity policy).
- The inductive step for `succ k'` case: split the witness interval, apply IH at depth k' to sub-intervals, assemble using the k=0 infrastructure's zone-aware pattern.
- The k=0 dispatch (Until/Since/Eq sub-cases via `sub_nf.1 (.order ...)`) is the model — replicate this structure for k>0.
- Do not introduce sorry placeholders for sub-goals during implementation; plan decomposition should identify sorry-free sub-lemmas before starting.

---

## Evidence and Examples

### ROADMAP Verification

- Line 27: "Task 303 targets the k>0 closure" — correctly describes 303's scope.
- Lines 49-63: Reynolds sorry chain (single sorry: `existPart_succ_n1_bypass k>0`).
- Lines 71-82: Stavi chain documented as SECOND independent blocker (verified 2026-06-09).
- Lines 84-89: Sorry summary confirms TWO categories of sorries in the discrete branch.
- Lines 1402-1415: Recommended priority order — Task 303 is item 1, followed by Stavi chain (implicit in the "Previously two chains — now one" note, which actually understates the situation — Stavi chain remains open per lines 71-82).

### Task State Evidence

- Task 273 `completion_summary`: "BracketFormula k encoding fix complete: all 5 phases done, k=0 bypass fully proved (Until+Since+Eq directions), only quarantined k>0 sorry remains. ~1400 lines of sorry-free proofs added."
- Task 303 `status`: "researching" — correctly in progress.
- Task 95 `dependencies`: [303] — correctly sequenced.
- Task 299 `dependencies`: [303] — correctly sequenced, but description notes "once the completeness chain is sorry-free," which overstates the dependency (it only needs the Reynolds chain, not both chains).

### KampBypass File Sizes (confirmed 2026-06-16)

- KampBypassCore.lean: 2160 lines (sorry-free)
- KampBypassUntil.lean: 979 lines (sorry-free)
- KampBypassSince.lean: 1307 lines (sorry-free)
- KampBypass.lean: 107 lines (1 sorry at line 104, the k>0 case)

---

## Confidence Level

| Finding | Confidence | Basis |
|---------|-----------|-------|
| Two independent sorry chains block completeness_discrete | **HIGH** | ROADMAP lines 71-82, verified 2026-06-09 |
| Task 303 closes Reynolds chain only | **HIGH** | KampBypass.lean:78-104 directly inspected |
| Stavi chain root sorry: nf_2var_existential_transfer j'+1 | **HIGH** | ROADMAP lines 71-82 |
| Next bottleneck after 303: Stavi chain | **HIGH** | Chain analysis |
| k>0 induction follows Rabinovich Section 5 Lemma 5.1 | **HIGH** | Task description + ROADMAP |
| 200-400 lines estimated for k>0 closure | **MEDIUM** | ROADMAP estimate; actual may vary with Lean formalization details |
| dense completeness independence from 303 | **HIGH** | ROADMAP line 25 (internally sorry-free) |
| Task 299 dependency only on Reynolds chain | **MEDIUM** | State.json description is ambiguous; "completeness chain" may mean Reynolds only |
