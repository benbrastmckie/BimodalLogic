# Implementation Plan: Task #118

- **Task**: 118 - Prove limitDomSubtype_isSuccArchimedean
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (task 117 research informs but does not block)
- **Research Inputs**: specs/118_prove_issucc_archimedean_discrete_completeness/reports/02_team-research.md
- **Artifacts**: plans/02_issucc-archimedean-proof.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Prove `limitDomSubtype_isSuccArchimedean` (ChronicleToCountermodel.lean:1063) to eliminate the remaining sorry in the discrete branch of `bx_completeness`. The proof shows that for any `a <= b` in `LimitDomSubtype`, there exists `n` with `Order.succ^[n] a = b`. The strategy uses strong induction on `|dom_N cap (a.val, b.val]|` (the count of finite-stage domain points between `a` and `b`), combined with a "gap lemma" that handles the case where `pred(b')` is not in `dom_N`. The gap lemma uses birth-monotonicity: each successor step in a gap between consecutive `dom_N` elements strictly increases the "birth stage" (the earliest omega chain stage at which a point appears), giving a well-founded descent. Definition of done: `lake build` succeeds with zero sorries in `ChronicleToCountermodel.lean`.

### Research Integration

The team research report (02_team-research.md) confirmed two viable strategies after exhausting 6 bypass alternatives. The primary strategy is **birth-monotonicity induction**: for consecutive `dom_N` elements `p < q`, each successor step from `p` toward `q` produces a new domain point (via `witness_not_old` from `C5ForwardWalkResult`), so `birth(succ(z)) > birth(z)`, making `birth(q) - birth(current)` a strictly decreasing natural number measure. The secondary strategy (dual-chain contradiction) is available as a fallback for the "L in limit_dom" case but is not needed if birth-monotonicity works. Key codebase facts available: `limitDomSubtype_succ_pred` (line 1001), `limitDomSubtype_pred_lt` (line 1040), `limitDomSubtype_le_pred_of_lt` (line 1031), `limit_dom_has_succ` (line 852), `omega_chain_dom_mono_le` (line 334), `omega_chain_dom_new_unique` (line 1196).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This plan advances:
- **Task 117** item: "Replace Cantor iso with natural inclusion X subset Q" -- while task 117 handles the dense branch sorry, task 118 handles the discrete branch sorry. Both are on the critical path.
- **Task 95** dependency: "print axioms audit on completeness theorem" -- requires 117 (and hence 118) to complete first.
- Closing this sorry unblocks the discrete countermodel (`dd_countermodel_chronicle_nondense_sorry` at line 825, which also has a sorry depending on this result).

## Goals & Non-Goals

**Goals**:
- Prove `limitDomSubtype_isSuccArchimedean` sorry-free
- Build supporting infrastructure: birth-stage extraction, gap lemma, dom_N counting lemma
- Ensure `lake build` passes with no sorries in ChronicleToCountermodel.lean

**Non-Goals**:
- Closing the dense branch sorry at CE:3570 (that is task 117)
- Closing `dd_countermodel_chronicle_nondense_sorry` (line 825) beyond what follows from IsSuccArchimedean
- Refactoring existing SuccOrder/PredOrder infrastructure
- Addressing BXCanonical sorries (task 109)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| C5 walk witness is not `succ_limitdom(z)` but farther away | H | M | Birth-monotonicity still works: succ_limitdom(z) must have been born by stage of witness, so birth(succ(z)) >= birth(z)+1 regardless. Verify by inspecting limit_dom_has_succ structure. |
| Birth stage extraction via Nat.find is complex | M | M | Use `Nat.find` with the decidability instance from omega_chain_dom membership. This is standard Mathlib infrastructure. |
| Finset cardinality induction (dom_N counting) has edge cases | M | L | Use `Finset.card_lt_card` or `Finset.card_strictMono` for the descent. Test with lean_multi_attempt before committing. |
| dom_N interval computation requires Finset.filter on Rat | M | M | Use `(omega_chain_val A h_mcs N).dom.filter (fun x => a.val < x && x <= b.val)` with decidable Rat comparisons. |
| The gap lemma inner induction is more than 2 hours | M | M | Phase 3 is allocated 2.5 hours with a fallback: if birth-monotonicity formalizes cleanly, the gap lemma is ~40 lines. If not, use the dual-chain "L in limit_dom" shortcut for a partial result. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Birth-Stage Infrastructure [BLOCKED]

**Goal**: Define the "birth stage" function and prove its key properties: birth(x) is the earliest omega chain stage at which x appears in the domain, and it is well-defined for all limit_dom points.

**Tasks**:
- [ ] Define `birth_stage` as `Nat.find` applied to the existence proof from limit_dom membership: given `x in limit_dom`, `birth_stage x hx = Nat.find hx` where `hx : exists n, x in (omega_chain_val A h_mcs n).dom`
- [ ] Prove `birth_stage_spec`: `x in (omega_chain_val A h_mcs (birth_stage x hx)).dom`
- [ ] Prove `birth_stage_min`: for all `m < birth_stage x hx`, `x notin (omega_chain_val A h_mcs m).dom`
- [ ] Prove `birth_stage_le`: if `x in (omega_chain_val A h_mcs n).dom` then `birth_stage x hx <= n`
- [ ] Prove `birth_stage_mono_dom_N`: if `x in (omega_chain_val A h_mcs N).dom` and `y in limit_dom` with `y notin (omega_chain_val A h_mcs N).dom`, then `birth_stage y hy > N`
- [ ] Verify all definitions compile with `lean_goal` at key positions

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Add birth_stage definitions and lemmas in a new section before the IsSuccArchimedean definition

**Verification**:
- `lake build` succeeds (sorry count unchanged)
- `lean_hover_info` on `birth_stage` shows expected type signature
- All five lemmas type-check without sorry

---

### Phase 2: Successor Birth-Monotonicity Lemma [BLOCKED]

**Goal**: Prove that in the discrete case, `birth_stage(succ(z)) > birth_stage(z)` for any `z` in `LimitDomSubtype`. This is the key lemma enabling the well-founded descent in the gap.

**Tasks**:
- [ ] Prove `succ_birth_gt`: for `z : LimitDomSubtype`, `birth_stage (succ z).val (succ z).property > birth_stage z.val z.property` where `succ` is `limitDomSubtype_succ`
- [ ] The proof structure: Let `n = birth_stage z.val z.property`. Then `z.val in (omega_chain_val A h_mcs n).dom`. The successor `(limitDomSubtype_succ A h_mcs h_discrete z).val` is the C5 witness from `limit_dom_has_succ`. By `limit_dom_has_succ`, it is obtained from `limit_satisfies_c5_strong` applied to `U(top, bot)` at `z.val`. The C5 walk produces a witness with `witness_not_old` property -- the witness is NOT in the chronicle's domain at the stage it was created. Trace this through: the C5 witness at some stage `s >= n` satisfies `witness notin (omega_chain_val A h_mcs s).dom`, so `birth_stage(witness) >= s + 1 > n = birth_stage(z)`.
- [ ] Handle the indirection: `limit_dom_has_succ` calls `limit_satisfies_c5_strong`, which calls `omega_chain_c5_witness`. Need to extract the stage at which the C5 elimination happened and connect `witness_not_old` to the birth stage ordering.
- [ ] Prove helper: `c5_witness_birth_gt_start` -- when limit_satisfies_c5_strong produces witness `y` from start `x`, and `x in dom_n`, then `birth_stage y > n`. This follows from the construction: the C5 elimination at stage `s >= n` produces `y in dom_{s+1} \ dom_s`, so `birth_stage(y) = s + 1 > n`.
- [ ] Prove that `limitDomSubtype_succ z` and the C5 witness from `limit_dom_has_succ` agree (they are defined via the same `Classical.choose`), so birth-monotonicity of the C5 witness transfers to `limitDomSubtype_succ`
- [ ] If the direct connection is too complex, use an indirect argument: `succ(z).val notin dom_{birth(z)}` because if it were, then `z < succ(z) < ...` would violate the immediate successor property (no domain points between z and succ(z) by the successor definition), combined with the fact that `succ(z)` is not equal to `z`. Therefore `birth(succ(z)) > birth(z)`.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Add succ_birth_gt and supporting lemmas after the birth_stage section

**Verification**:
- `succ_birth_gt` type-checks without sorry
- `lean_goal` at the sorry site shows the expected goal state after applying the lemma
- `lake build` succeeds (sorry count unchanged)

---

### Phase 3: Gap Lemma via Birth Induction [BLOCKED]

**Goal**: Prove the "gap lemma": for consecutive `dom_N` elements `p < q` (no `dom_N` points between them), there exists `k` with `Order.succ^[k] p_sub = q_sub` where `p_sub` and `q_sub` are the corresponding `LimitDomSubtype` elements.

**Tasks**:
- [ ] State the gap lemma: `gap_lemma`: given `p q : Rat`, `hp : p in (omega_chain_val A h_mcs N).dom`, `hq : q in (omega_chain_val A h_mcs N).dom`, `hpq : p < q`, `h_consec : forall w in (omega_chain_val A h_mcs N).dom, p < w -> w < q -> False`, then `exists k, Order.succ^[k] (Subtype.mk p (exists.intro N hp)) = Subtype.mk q (exists.intro N hq)`
- [ ] Prove by strong induction on `birth_stage q.val hq_limit - birth_stage current.val hcurrent_limit` (a natural number that decreases at each succ step by Phase 2's `succ_birth_gt`)
- [ ] Base case: `current = q` (birth difference is 0, but actually this comes from the antisymmetry -- if `succ(current) = q` then k=1)
- [ ] Inductive step: `succ(current)` is in the gap `(p, q)` (since `current >= p` and `succ(current) <= q` by the successor property and `q` being in dom_N), and `birth(succ(current)) > birth(current)`, so `birth(q) - birth(succ(current)) < birth(q) - birth(current)`. Apply IH with `succ(current)`.
- [ ] Handle the bound: need `succ(current).val <= q` to ensure we stay in the gap. This follows from `limitDomSubtype_succ_le_iff`: `succ(current) <= q_sub iff current < q_sub`, and we have `current < q_sub` from the gap hypothesis.
- [ ] Verify the WF measure: use `Nat.lt_wfRel` or direct `Nat.strongRecOn` for the well-founded recursion
- [ ] Combine: `succ^[k](p_sub) = succ^[k-1](succ(p_sub))`, use IH with `succ(p_sub)` and `q_sub`

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Add gap_lemma after the succ_birth_gt section

**Verification**:
- `gap_lemma` type-checks without sorry
- The WF recursion compiles without `decreasing_by sorry`
- `lake build` succeeds (sorry count unchanged)

---

### Phase 4: Complete IsSuccArchimedean Proof [BLOCKED]

**Goal**: Replace the sorry in `limitDomSubtype_isSuccArchimedean` with a complete proof using the gap lemma and dom_N counting induction.

**Tasks**:
- [ ] Replace the `sorry` at line 1101 with a proof by strong induction on `((omega_chain_val A h_mcs N).dom.filter (fun x => a.val < x && x <= b.val)).card`
- [ ] Base case: card = 0 means no dom_N points in `(a.val, b.val]`. Since `b.val in dom_N` (from `hb_N`), `b.val` must be in the filter, so card >= 1. Actually: if `a = b` then `exists 0, rfl`. If `a < b` then `b.val in (a.val, b.val]` gives card >= 1.
- [ ] Inductive step (card = k+1, a < b): Use `pred(b)` from `limitDomSubtype_pred`. Two sub-cases:
  - Sub-case A: `pred(b).val in dom_N`. Then the filter for `(a.val, pred(b).val]` has card <= k (since `b.val` was in the old filter but not the new one, and `pred(b).val <= pred(b).val`). Apply IH to get `succ^[m](a) = pred(b)`. Then `succ^[m+1](a) = succ(pred(b)) = b` by `limitDomSubtype_succ_pred`.
  - Sub-case B: `pred(b).val notin dom_N`. Find consecutive dom_N elements `p, q` with `p <= pred(b).val < q <= b.val`. Apply `gap_lemma` to get `succ^[j](p_sub) = q_sub`. If `q = b.val`, then find `succ^[m](a) = p_sub` by IH (smaller count since `p < b`), combine to get `succ^[m+j](a) = b`. If `q < b.val`, apply IH with `(a, q)` having smaller count.
- [ ] Handle the a = b base case: `exists 0, rfl` (or `le_antisymm` when `a <= b` and not `a < b`)
- [ ] Verify the Finset.filter cardinality descent is strictly decreasing in both sub-cases
- [ ] Remove all `sorry` markers from the definition
- [ ] Run `lake build` and verify zero sorries in ChronicleToCountermodel.lean
- [ ] Check that `dd_countermodel_chronicle_nondense_sorry` (line 825) still has its own sorry (it depends on more than just IsSuccArchimedean) -- do not attempt to close it

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Replace sorry in limitDomSubtype_isSuccArchimedean with proof using gap_lemma and dom_N counting

**Verification**:
- `lake build` succeeds with zero new sorries
- `lean_goal` at the end of the proof shows "no goals"
- The sorry count in ChronicleToCountermodel.lean decreases by 1 (from 2 to 1, since dd_countermodel_chronicle_nondense_sorry remains)
- `grep -c "sorry" ChronicleToCountermodel.lean` confirms the count

---

## Testing & Validation

- [ ] `lake build` succeeds without errors
- [ ] `grep "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` shows exactly 1 sorry (the dd_countermodel_chronicle_nondense_sorry at line 833)
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` passes (no sorry axiom)
- [ ] `lean_verify` on `discrete_iso` passes (transitive dependency on IsSuccArchimedean)
- [ ] The existing `discrete_fmcs`, `discrete_f`, and `discrete_zero` all compile without changes

## Artifacts & Outputs

- `specs/118_prove_issucc_archimedean_discrete_completeness/plans/02_issucc-archimedean-proof.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (sorry replaced with proof, ~150-250 new lines)

## Rollback/Contingency

If birth-monotonicity formalization fails (Phase 2 blocked):
1. Fall back to the dual-chain contradiction approach for the "L in limit_dom" sub-case (pure order theory, ~30 lines per research report). This gives a partial result for consecutive dom_N elements where the succ-chain limit is itself in limit_dom.
2. For the "L not in limit_dom" case, try the sealed-interval compactness argument: total length of (succ^k(p), succ^{k+1}(p)) intervals sums to q - p (finite), and each interval has positive rational length, so finitely many steps.
3. If both fail, save partial infrastructure (birth_stage definitions, gap lemma statement) and write a handoff file documenting the blocker. Return `status: "partial"`.

If the Finset cardinality approach (Phase 4) has edge cases:
1. Simplify by using `WellFoundedRelation` directly on a custom measure rather than Finset.card
2. Alternative: use `Finset.strongInduction` or `Nat.strongRecOn` with explicit measure

Git revert: all changes are in a single file (`ChronicleToCountermodel.lean`). Revert with `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` if needed.
