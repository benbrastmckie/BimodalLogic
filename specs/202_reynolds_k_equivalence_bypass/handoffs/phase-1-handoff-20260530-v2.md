# Phase 1 Handoff: Gap Formula Construction (v2)

**Task**: 202 -- Reynolds k-equivalence bypass
**Session**: sess_1780162885_5a6fd2
**Date**: 2026-05-30
**Plan**: plans/17_reynolds-model-surgery-v16.md
**Phase**: 0 COMPLETED, 1 BLOCKED
**Status**: PARTIAL (Phase 0 done, Phase 1 blocked on De Bruijn correctness proof)

## Completed Work

### Phase 0: Bounded Quantifier Relativization [COMPLETED]

All Tasks 0.1-0.5 completed, sorry-free, builds clean.

#### NormalForm.lean additions (~225 lines, all sorry-free)

1. **nf_to_formula bridge** (Task 0.5):
   - `atom_to_formula`: AtomKind → MonadicFormula (atomic propositions)
   - `eval_atom_to_formula`: correctness proof
   - `MonadicFormula.trueFormula`: always-true formula (∀ x, ¬(x < x))
   - `eval_trueFormula`: correctness proof
   - `MonadicFormula.listConj`: finite conjunction of formula list
   - `eval_listConj`: eval ↔ ∀ φ ∈ list, eval φ
   - `atom_cond_formula`: single atom condition for Bool assignment
   - `eval_atom_cond`: correctness proof
   - `quant_cond_formula`: single quantifier condition
   - `nf_to_formula`: NormalForm sig k n → MonadicFormula sig n (recursive)
   - `nf_to_formula_correct`: eval M env (nf_to_formula nf) ↔ nf_eval_nf M k n env nf
   - `MonadicFormula.listDisj`: finite disjunction
   - `eval_listDisj`: eval ↔ ∃ φ ∈ list, eval φ
   - `nf_to_sentence` / `nf_to_sentence_correct`: specialization for n=0

2. **Prior Phase 0 work** (Tasks 0.1-0.4, from previous session):
   - Syntactic sugar (imp, or, leq, true_, false_) with eval lemmas
   - `relativize`: MonadicFormula sig n → MonadicFormula sig (n+2)
   - `relativize_correct`: full correctness by structural induction
   - `relativize_sentence_correct`: sentence specialization

#### GoodStructuresModelSurgery.lean additions (~95 lines, all sorry-free)

1. **good_sentence** (Task 0.6 partial):
   - `is_Z_type`: classically decidable predicate for Z-interval achievable k-types
   - `good_sentence`: MonadicSentence encoding `good sig k` via finite disjunction over Z-types
   - `good_sentence_correct`: eval S Fin.elim0 (good_sentence sig k) ↔ good sig k S
   - `good_formula_relativized`: MonadicFormula sig 2 for good on subintervals
   - `good_formula_relativized_correct`: composes with relativize_sentence_correct

2. **right_gap_class_formula** (Phase 1 partial):
   - `good_rel_lifted`: lifts good_formula_relativized from sig 2 to sig 4
   - `right_gap_class_formula`: MonadicFormula sig 1 encoding right_gap_class_prop

## Phase 1 Blocker

### What failed

`eval_good_rel_lifted` requires proving that:
```
eval M (Fin.cons a' (Fin.cons b' (Fin.cons b_val (Fin.cons t Fin.elim0))))
  (good_rel_lifted sig k) =
eval M (Fin.cons a' (Fin.cons b' Fin.elim0))
  (good_formula_relativized sig k)
```

This needs `lift_eval` composed with a `Fin.cons ↔ insertEnv` identity:
```
Fin.cons a' (Fin.cons b' (Fin.cons b_val (Fin.cons t Fin.elim0))) =
  insertEnv ⟨3, _⟩ t (insertEnv ⟨2, _⟩ b_val (Fin.cons a' (Fin.cons b' Fin.elim0)))
```

### What was tried

1. `fin_cases i <;> simp [Fin.cons, Fin.cases]` -- Fin.cases doesn't fully reduce
2. `split_ifs <;> simp_all [Fin.cons, Fin.ext_iff] <;> omega` -- omega can't handle non-Nat goals
3. Manual `rcases` on `⟨i, hi⟩` -- syntax issues with Nat case split

### Why it's stuck

The `Fin.cons` function is defined via `Fin.cases` which pattern-matches on `Fin (n+1)` as either `0` or `i.succ`. The `insertEnv` function uses `if h : i.val < c ...` with `dif`. Converting between these two representations requires showing that for each concrete index value (0, 1, 2, 3), both sides compute to the same element. The simp lemmas for `Fin.cons` and `insertEnv` don't compose well when the index is a variable.

### What is needed

1. **Option A**: A general `Fin.cons_eq_insertEnv` lemma showing `Fin.cons x env = insertEnv 0 x env` extended to arbitrary positions. The existing `insertEnv_zero_eq_cons` only handles position 0.

2. **Option B**: A tactic or automation that can prove `∀ (i : Fin n), f i = g i` when n is a concrete numeral (like 4) by splitting into all cases and computing. The `omega` tactic can't handle this because the goals involve carrier elements, not Nats.

3. **Option C**: Use `Finset.univ.forall` or `Decidable.decide` for the finite case check. Since `Fin 4` is finite, the extensionality should be decidable.

4. **Option D**: Redefine `good_rel_lifted` using `weaken` instead of `lift`, which would compose with `weaken_eval` (= `Fin.cons x env` → `env`). Two weakens would give MonadicFormula sig 4 where vars 2, 3 are unused and vars 0, 1 reference the original variables.

**Recommended**: Option D (use `weaken` instead of `lift`). `weaken = lift 0` shifts ALL variables up by 1. So:
- `φ.weaken` : sig 2 → sig 3, vars 0,1 become 1,2 (var 0 unused)
- `φ.weaken.weaken` : sig 3 → sig 4, vars 1,2 become 2,3 (vars 0,1 unused)

Then `eval M (Fin.cons x0 (Fin.cons x1 env)) φ.weaken.weaken = eval M env φ` by two applications of `weaken_eval`.

Wait -- this means vars 0,1 in the weakened formula are UNUSED. But the right_gap_class_formula puts a' at var 0 and b' at var 1, and needs good_rel_lifted to reference these. With weaken, good_rel_lifted would reference vars 2,3 instead.

So the right approach is: change the right_gap_class_formula's quantifier binding order so that a', b' end up at vars 2, 3 (matching the weakened formula). Or: use `lift 2` once + `weaken_eval` differently.

Actually, the cleanest fix is: don't use lift at all. Instead, directly construct a `MonadicFormula sig 4` that checks good sig k at vars 0 and 1 by inlining the relativized sentence. This avoids the lift altogether.

## Remaining Work

### Phase 1 completion (~100 lines)
- Fix `eval_good_rel_lifted` (see blocker above)
- Prove `right_gap_class_formula_correct`
- Apply `US_expressively_complete_over_prior` to get temporal formula R
- Prove R(a) and ¬R(s) for some s > a

### Phase 2: R-Interval Analysis (~55 lines)
- Apply `prior_UZ_first_transition` with R
- Get first R-transition point c

### Phase 3: Model Surgery (~350 lines)
- Construct surgery model N = Q- ∪ I ∪ Q+
- Prove temporal truth preservation (26 U/S subcases)

### Phase 4: Contradiction (~120 lines)
- Show R false at representative in surgery model
- Derive contradiction

## Build Status

- `lake build` passes (1679 jobs, 0 errors)
- No new sorry sites introduced
- GoodStructuresModelSurgery.lean unchanged at 2 sorry sites (lines 831, 857)
- MonadicFO.lean: 0 sorry (some lint warnings about unused simp args)
- NormalForm.lean: 0 sorry
