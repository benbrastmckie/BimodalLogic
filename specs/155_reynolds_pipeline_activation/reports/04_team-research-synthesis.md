# Team Research Synthesis: Phase 2 Crux (good_of_split_at_succ sorry)

**Task**: 155 (Reynolds Pipeline Activation)
**Date**: 2026-05-16
**Team**: 4 parallel research agents + critical path verification
**Focus**: How to close the sorry at IntegerModel.lean:470

---

## Critical Path Verification

**CONFIRMED: `good_of_split_at_succ` IS on the critical path for sorry-free `bx_completeness`.**

One research agent claimed it was "dead code." This is ONLY true for the CURRENT implementation where `chronicle_is_good` uses `orderIsoIntOfLinearSuccPredArch` (which itself is sorry-free, but CONSTRUCTING the ChronicleAsPriorModel requires `succ_cofinal` sorry).

**Current sorry chain** (what must be replaced):
```
bx_completeness → doets_countermodel_discrete → dd_countermodel_chronicle_discrete
  → constructs ChronicleAsPriorModel (needs IsSuccArchimedean)
  → limitDomSubtype_isSuccArchimedean → succ_cofinal (SORRY)
```

**Planned replacement** (task 155):
```
contemp_equiv_is_equiv [SuccOrder, NoMaxOrder]  ← uses good_of_split_at_succ
  → no_gaps_discrete (Phase 3)
  → one_class (Phase 3)
  → very_good_implies_good WITHOUT IsSuccArchimedean (Phase 4)
  → chronicle_is_good WITHOUT orderIsoIntOfLinearSuccPredArch (Phase 4 rewrite)
  → truth transfer (Phase 5)
  → TaskFrame Int (Phase 6)
  → replaces fallback in Transfer.lean
```

**Verification**:
- `lean_verify bx_completeness` → has `sorryAx` (confirmed)
- `lean_verify chronicle_is_good` → NO `sorryAx` (because it assumes ChronicleAsPriorModel, doesn't construct it)
- `lean_verify dd_countermodel_chronicle_discrete` → has `sorryAx` (from succ_cofinal)

---

## The Sorry (IntegerModel.lean:470)

```lean
| succ k' =>
  -- k = k'+1 ≥ 1. Need: good sig k (orderedSum sig Bool witnesses)
  sorry
```

Context: `witnesses false = Z1.toOrdered sig`, `witnesses true = Z2.toOrdered sig`.
We know: `hZ1 : k_equiv sig k (M.subinterval sig t b) (Z1.toOrdered sig)`
and `hZ2 : k_equiv sig k (M.subinterval sig (Order.succ b) u) (Z2.toOrdered sig)`.

---

## Unanimous Strategy: Case Split on k

### Case k' = 0 (k = 1): Direct profile-matching (~50 lines)

**Why special treatment**: `AtomKind sig 1` has NO order atoms (confirmed: `atomKind_one_pred_only` at NEquivalence.lean:145). At depth 1, k-equivalence only tracks which predicate-patterns (`sig.preds → Bool`) are realized. Order structure is invisible.

**Strategy**: Construct a finite Z-interval `[0, m-1]` where `m` = number of distinct realized predicate-patterns in the ordered sum. Assign each integer a different realized pattern. This is 1-equiv to the ordered sum (same set of realized 1-types). Apply `finite_structures_good` or `k_equiv_of_iso`.

**Key facts**:
- `k_type_of sig 1` maps each NF to whether it's realized
- At depth 1, NFs encode: "which predicate-patterns have witnesses"
- The ordered sum realizes union of Z1's and Z2's patterns
- A finite Z-interval with m elements can realize exactly m patterns

### Case k' ≥ 1 (k ≥ 2): Expressibility + Fintype (~80 lines)

**Why this works**: "Has a maximum" = `∃x. ∀y. ¬(x < y)`, quantifier depth 2. Since k ≥ 2 and `doets_lemma_1_1` (sorry-free, NormalForm.lean:433) proves k-equiv preserves all sentences of depth ≤ k, the sentence "has max" is preserved.

**Step-by-step**:
1. `M.subinterval sig t b` has max element (b) — trivial from subtype definition
2. By `doets_lemma_1_1` + k_equiv at k≥2: Z1 also has max → `Z1.hi = some _`
3. Similarly: `M.subinterval sig t b` has min (t) → Z1 has min → `Z1.lo = some _`
4. Bounded Z-interval carrier = `{z : ℤ // lo ≤ z ∧ z ≤ hi}` = Fintype (Mathlib `Set.Icc`)
5. Same for Z2: bounded → Fintype
6. `Sigma.instFintype` gives Fintype on orderedSum carrier (Sigma of two Fintypes)
7. Apply `finite_structures_good`

**Key lemmas needed**:
- `has_max_sentence : MonadicSentence sig` (construct the depth-2 sentence)
- `has_max_sentence_depth : has_max_sentence.depth ≤ 2`
- `has_max_true_of_has_max : has_max M → nf_eval_sentence has_max_sentence M = true` (or use doets_lemma_1_1's bridge)
- `z_interval_hi_of_has_max : (Z has max element) → Z.hi = some _`
- `z_interval_fintype_of_bounded : Z.lo = some _ → Z.hi = some _ → Fintype Z.intervalCarrier`

---

## Key Infrastructure (all sorry-free)

| Lemma | Location | Status |
|-------|----------|--------|
| `k_equiv_of_iso` | IntegerModel.lean:97 | sorry-free |
| `doets_lemma_1_1` | NormalForm.lean:433 | sorry-free |
| `doets_lemma_1_4` | OrderedSum.lean:34 | sorry-free |
| `finite_structures_good` | IntegerModel.lean (Phase 1) | sorry-free |
| `atomKind_one_pred_only` | NEquivalence.lean:145 | sorry-free |

## DO NOT USE

| Lemma | Location | Status | Why |
|-------|----------|--------|-----|
| `doets_lemma_1_5` | OrderedSum.lean:56 | SORRY'd | Harder than our problem |
| `orderIsoIntOfLinearSuccPredArch` | Mathlib | sorry-free but requires IsSuccArchimedean | Whole point is to avoid this |

---

## Estimated Effort

- k=1 case: ~50 lines
- k≥2 case: ~80 lines (mostly proving "has max" sentence construction + bounded → Fintype)
- Total: ~130 lines
- Estimated time: 2-3 hours

---

## After Closing the Sorry

Phase 2 will be COMPLETE. Continue to:
- Phase 3: `no_gaps_discrete` (Reynolds Theorem 14 — THE HARDEST PHASE, 8 hours budgeted)
- Phase 4: `very_good_implies_good` and rewrite `chronicle_is_good`
- Phase 5: Truth transfer
- Phase 6: TaskFrame Int + wire into Transfer.lean
