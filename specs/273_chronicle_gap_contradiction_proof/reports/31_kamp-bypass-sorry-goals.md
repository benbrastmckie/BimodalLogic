# Research Report: KampBypass Sorry Goal States and Feasibility Analysis

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Session**: sess_1718380800_a7c3e2
- **Date**: 2026-06-14
- **Scope**: Detailed goal-state analysis of 5 remaining KampBypass.lean sorries, infrastructure inventory, feasibility assessment, and recommended fill order

## Summary

Five sorries remain in KampBypass.lean (1705 lines total). Four are depth-0 wiring sorries (lines 753, 1284, 1503, 1615) and one is the depth >= 2 arity-climbing sorry (line 1703). The depth-0 sorries are all mechanical: the mathematical content exists in sorry-free infrastructure (ZoneBridge.lean, VecEADecomp.lean, KampForward.lean). The depth >= 2 sorry requires significant new mathematical content. Filling the 4 depth-0 sorries makes `existPart_succ_n1_bypass_k0` sorry-free, which directly resolves `nf_2var_exist_formula_prior` at depth 1.

## Goal States from lean_goal

### Sorry 1: Line 753 -- existPart_succ_n1_bypass_k0_eq (compatible subcase)

**Goal**:
```
⊢ temporal_truth M atomMap t (enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms) ↔
    ∃ x, nf_eval_nf M 1 (1 + 1) (Fin.cons x fun x ↦ t) sub_nf
```

**Available hypotheses** (key ones):
- `h_gt : sub_nf.1 (AtomKind.order ⟨1, ...⟩ ⟨0, ...⟩ ...) = false` (no t < x)
- `h_lt : sub_nf.1 (AtomKind.order ⟨0, ...⟩ ⟨1, ...⟩ ...) = false` (no x < t)
- `h_pred_compat : ∀ p, sub_nf.1 (pred p 0) = sub_nf.1 (pred p 1)` (var-0 = var-1 preds)
- `h_t_compat : ∀ p, sub_nf.1 (pred p 1) = parent_atoms (pred p 0)` (var-1 matches parent)
- `h_atoms : ∀ a, atom_eval M (fun x => t) a ↔ parent_atoms a = true`
- `char_1_correct : ∀ nf_1 M ..., temporal_truth M atomMap t (char_1 nf_1) ↔ nf_eval_nf M 1 1 (fun _ => t) nf_1`
- `h_UZ, h_SZ` (Prior structure hypotheses)

**Analysis**: When both order booleans are false, `witness_eq_t_of_no_order` forces any witness x to equal t. The enriched_bypass_eq formula is a disjunction over compatible `nf_x` values. For each `nf_x`, the conjunct is `char_1(nf_x) AND quant_conjuncts`. The proof strategy:

- **Backward** (exists x, nf_eval -> formula truth): Given x with nf_eval, x = t by `witness_eq_t_of_no_order`. The NF characteristic `nf_x = nf_characteristic M 1 1 (fun _ => t)` is the unique satisfying NF. Show it appears in the disjunction list (via `nf_x_compat_check` + Fintype.complete). Show `char_1(nf_x)` holds at t (via `char_1_correct`). Show each quant_conjunct holds using zone_bridge_* adapted for x=t case (all 3 vars collapse: y < x=t, y=x=t, y > x=t). Key adapter: `eq_case_orders` already proved.

- **Forward** (formula truth -> exists x, nf_eval): Formula truth gives some compatible nf_x with `char_1(nf_x)` and quant_conjuncts at t. Use `char_1_correct` to get `nf_eval_nf M 1 1 (fun _ => t) nf_x`. Reconstruct `nf_eval_nf M 1 2 (Fin.cons t (fun _ => t)) sub_nf` by combining the atom part (from pred_compat + t_compat + h_atoms) and the quantifier part (from quant_conjuncts).

**Key infrastructure needed**:
- Zone bridges for x=t case: `zone_bridge_eq_t`, `zone_bridge_eq_x` (already in ZoneBridge.lean)
- `eq_case_orders` (already proved in KampBypass.lean, line 676)
- `nf_eval_unique` (NormalForm.lean:244) for NF uniqueness
- `nf_depth0_char_formula_correct` for y's characteristic at depth 0

**Estimated lines**: 80-120

**Feasibility**: HIGH. All infrastructure exists. The proof is structural: disjunction membership + conjunction verification + NF uniqueness. The x=t collapse means all zones simplify: zone_bridge_eq_t, zone_bridge_eq_x handle the y=t and y=x=t cases, and zone_bridge_below_t/above_x handle y < t and y > t.

---

### Sorry 2: Line 1284 -- bracket_holds_of_eval_quant (bracket case)

**Goal**:
```
⊢ IntervalPattern.holds M atomMap { alpha := bracket.pointTypes, beta := bracket.segmentTypes } t x
```

**Available hypotheses** (key ones):
- `h_tx : t < x` (strict order)
- `h_x_pred : ∀ p, M.interp p x ↔ nf_x_1var (pred p 0) = true`
- `h_t_pred : ∀ p, M.interp p t ↔ parent_atoms (pred p 0) = true`
- `h_eval_quant : ∀ ssn, (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔ sub_nf.2 ssn = true`
- `pos_between : List (NormalForm sig 0 3)` -- positive between_tx SSNs, each with `sub_nf.2 ssn = true`
- `neg_between : List (NormalForm sig 0 3)` -- negative between_tx SSNs, each with `sub_nf.2 ssn = false`
- `seg_guard : TemporalPred` -- conjunction of negated char_y formulas for negative SSNs
- `n : Nat := pos_between.length` -- number of bracket witnesses
- `bracket : BracketFormula n` with pointTypes and segmentTypes from above
- `h_seg : ∀ y, t < y → y < x → seg_guard.eval_at M atomMap y` (already proved)

**Analysis**: IntervalPattern.holds at n+1 requires:
1. Witnesses: `Fin (n+1) -> M.carrier` mapping each positive between_tx SSN to a y-witness
2. Strictly increasing witnesses
3. All witnesses in (t, x)
4. Point types hold at witnesses: `nfPred atomMap h_surj (nf_y_proj ssn_i)` at `witnesses i`
5. Segment guards hold on all intervals between consecutive witnesses and at boundaries

For each positive SSN `ssn_i` in `pos_between`, `h_eval_quant` gives `∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn_i`. By `between_tx_temporal_iff` (or directly via zone_bridge_between_tx), this yields `∃ y, t < y ∧ y < x ∧ pred_match_at_y`. This provides the witness for position i.

The challenge is constructing STRICTLY INCREASING witnesses. The positive SSNs may have the same y-predicate profile, meaning their witnesses could collide. But the model M has a dense/discrete linear order. For n=0 (no positive SSNs), the goal becomes trivially the segment guard on (t, x), which follows from h_seg. For n >= 1, we need a sorting/selection argument.

**Critical subtlety**: The standard IntervalPattern.holds requires witnesses to be strictly increasing (condition 1 of IntervalPattern.holds). If `pos_between` has more than one element, we need to show we can find strictly ordered witnesses. This is non-trivial in general -- on a dense order it's possible, but on a discrete order it may fail if the interval (t, x) is too small.

However, looking more carefully at the structure: since we're working with `OrderedMonadicStructure` which has a linear order, and the positive SSNs have distinct predicate profiles at y (each SSN in pos_between passes the zone filter with different nf_y_proj values), we can use the fact that depth-0 NFs are determined by their predicate profile. If two SSNs in pos_between have the same nf_y_proj, their witnesses can be the same point, which would violate strict monotonicity. But `pos_between` is filtered from `Fintype.elems` -- it can contain SSNs with the same y-projection but different quantifier assignment values. This seems like a real issue.

**Wait** -- re-examining the IntervalPattern: `bracket.pointTypes i` is `nfPred atomMap h_surj (nf_y_proj (pos_between[i]))`. If two elements of pos_between have the same nf_y_proj, their pointTypes coincide. But the witnesses still need to be distinct and ordered. 

Actually, re-reading IntervalPattern.holds more carefully: for n+1 witnesses, we need the witnesses to be strictly increasing AND all in (t, x). The segment types (all = seg_guard) hold between consecutive witnesses. Since h_seg shows seg_guard holds for ALL y in (t, x), the segment condition is automatically satisfied regardless of witness placement. The point type condition requires `nfPred atomMap h_surj (nf_y_proj ssn_i)` to hold at `witnesses i`, meaning `nf_eval_nf M 0 1 (fun _ => witnesses_i) (nf_y_proj ssn_i)`.

For each positive SSN, we have a y-witness from h_eval_quant. The issue is whether we can arrange them in strictly increasing order. If the model has enough points, yes. In a dense order, we can always find distinct points. But we're working with general `OrderedMonadicStructure` which is a strict linear order -- not necessarily dense.

Key insight: The model M need not be dense. But `h_eval_quant` gives us ACTUAL witnesses y_i in the model, not just existential assertions. We have `∃ y, t < y ∧ y < x ∧ ...` for each positive SSN. Different SSNs may have the same y, or y_i values may not be ordered as needed. However, what matters is not the SSNs' original witnesses but whether we can find a DIFFERENT set of witnesses with the right pointType predicates.

Actually, this is where the approach may need refinement. The IntervalPattern definition requires witnesses strictly between t and x, with specific predicate profiles. If two SSNs share the same nf_y_proj but appear at different positions in pos_between, we need two distinct points with the same predicate profile, which is only possible if the model has duplicates (not guaranteed).

**Alternative reading**: Perhaps pos_between is constructed so that each element has a UNIQUE nf_y_proj? Let me check... The filter condition is `ssn_xt_compatible && ssn_zone_until == between_tx && sub_nf.2 ssn`. Different SSNs can have the same nf_y_proj but different x/t predicate parts -- but those are filtered by ssn_xt_compatible fixing the x and t predicates. So two SSNs in pos_between with the same y-predicates would differ only in their order atoms between y and x/t. But the between_tx zone fixes all order atoms: t < y, y < x. So SSNs in between_tx with the same nf_y_proj AND the same x/t predicates are actually identical NFs. Since pos_between comes from `Fintype.elems.val.toList.filter ...`, and Fintype.elems has unique elements, each SSN is unique. But they CAN have the same nf_y_proj (the y-predicate projection).

So the core question for the bracket sorry is: can we find strictly increasing witnesses when multiple positive between_tx SSNs have the same nf_y_proj? If two SSNs have the same y-predicates, the same x-predicates, the same t-predicates, and the same order profile -- they ARE the same NF (by function extensionality). So actually, each element of pos_between is a DISTINCT NF, and since they're all in between_tx zone with the same x/t predicates, they MUST differ in their y-predicates. This means nf_y_proj is injective on pos_between.

With distinct y-predicate profiles, different witnesses automatically have different predicate profiles, meaning they represent different "types" of points. On a model M, if we have witnesses y_1, ..., y_n all in (t, x) with distinct predicate profiles, we can sort them by the order of M to get strictly increasing witnesses. The predicate profiles at the sorted positions still match the corresponding SSNs (we just need to reindex).

BUT -- the bracket's pointTypes are defined by position in `pos_between`, not by the sorted order of witnesses. So we need a permutation argument: we can reorder the witnesses to be increasing, and then match each reordered witness to the correct position in pos_between.

Actually, looking again at the IntervalPattern definition: it requires `pointTypes i` to hold at `witnesses i`. The bracket's pointTypes are indexed by `Fin n` corresponding to `pos_between[i]`. If we sort witnesses, we get `witnesses' : Fin n -> M.carrier` that are strictly increasing, but `pointTypes i` needs to hold at `witnesses' i`, not at the original `witnesses i` (pre-sorting). This means the sorted witness at position i must satisfy the predicate profile of `pos_between[i]`.

This is NOT guaranteed by sorting -- the sorted order of witnesses depends on the model, not on the order of elements in pos_between.

**This is a genuine challenge.** The bracket may need to be defined with pointTypes indexed by the sorted order, not by the list order. Or the proof may need to show that we can construct witnesses matching the pos_between ordering.

Looking at how VecEADecomp handles this: `nf_3var_bracket_tyx_correct` handles the case of a SINGLE between_tx SSN (BracketFormula.single), where n=1 and there's exactly one witness. For multiple witnesses, we'd need a more general construction.

**Potential approach**: Use Classical.choice to select witnesses for each positive SSN, then sort them. Show the sorted assignment still satisfies all conditions. This requires that nf_y_proj is injective on pos_between (proved above) and that the model's linear order on the witnesses induces a permutation that correctly matches pointTypes.

Actually, a simpler approach: since segmentTypes are all the SAME seg_guard, and seg_guard holds everywhere in (t, x) (by h_seg), the segment conditions are trivially satisfied regardless of witness placement. So we just need:
1. Distinct witnesses (from distinct predicate profiles + model linearity)
2. All in (t, x)
3. Strictly increasing (sort them)
4. PointTypes match after sorting

The sorting works because: collect witnesses {y_1, ..., y_n} with distinct predicate profiles. Sort by model order: y_{σ(1)} < ... < y_{σ(n)}. Define `witnesses i := y_{σ(i+1)}`. Then `witnesses` are strictly increasing and in (t, x). For pointTypes: we need `nfPred atomMap h_surj (nf_y_proj (pos_between[i]))` to hold at `witnesses i = y_{σ(i+1)}`. But `nfPred` at `y_{σ(i+1)}` gives `nf_y_proj(ssn_{σ(i+1)})`, which matches `pos_between[σ(i+1)]`, not necessarily `pos_between[i]`.

So the bracket as currently defined requires the pos_between list to be ordered in a way that matches the model's ordering of witnesses. Since pos_between is derived from `Fintype.elems.val.toList.filter`, its order depends on the Fintype enumeration, which has no relation to the model's order.

**Revised assessment**: This sorry is MEDIUM difficulty. The bracket construction as defined may have an ordering mismatch. Two possible approaches:

(a) **Permutation argument**: Show that BracketFormula.holds is invariant under permutation of (pointTypes, segmentTypes) when all segmentTypes are the same. This would allow reordering pos_between to match the model's witness ordering.

(b) **Use Finset instead of sorted list**: Reformulate the bracket in terms of a Finset of witnesses, avoiding the ordering issue.

(c) **Direct IntervalPattern construction**: Instead of going through BracketFormula, directly construct the IntervalPattern witness (Fin (n+1) -> M.carrier) by choosing witnesses via Classical.choice, sorting them by model order, and constructing the permutation that maps each sorted position to the correct SSN.

Approach (c) is the most direct. Estimated lines: 60-120.

**Feasibility**: MEDIUM. The mathematical content is clear, but the permutation/sorting argument in Lean requires careful Fin arithmetic. Key steps: (1) use h_eval_quant + zone_bridge_between_tx to get individual witnesses, (2) Classical.choice for a function assigning witnesses, (3) sort by model order (requires decidable linear order on M.carrier, which exists), (4) construct the IntervalPattern witness function, (5) verify all conditions.

---

### Sorry 3: Line 1503 -- forward_nf_eval_of_holdsLeft (forward direction)

**Goal**:
```
case pos
⊢ nf_eval_nf M 1 (1 + 1) (Fin.cons x fun x ↦ t) sub_nf
```

**Available hypotheses** (key ones):
- `h_gt : sub_nf.1 (order 1 0) = true` (t < x direction)
- `h_lt : sub_nf.1 (order 0 1) = false` (not x < t)
- `h_compat : nf_x_compat_check sub_nf nf_x = true`
- `h_eq : enriched_vecEA2_until ... nf_x nf_x_1var parent_atoms = ⟨n, vea⟩`
- `h_endLeft : TemporalPred.eval_at M atomMap vea.endpointLeft t`
- `h_t_lt_x : t < x`
- `h_endRight : TemporalPred.eval_at M atomMap vea.endpointRight x`
- `h_bracket : BracketFormula.holds M atomMap vea.bracket t x`
- `h_atoms : ∀ a, atom_eval M (fun _ => t) a ↔ parent_atoms a = true`
- `char_1_correct, h_UZ, h_SZ`

**Analysis**: Need to reconstruct `nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf`. This unfolds to:
1. **Atom part**: `∀ a : AtomKind sig 2, atom_eval M (Fin.cons x (fun _ => t)) a ↔ sub_nf.1 a = true`
2. **Quantifier part**: `∀ ssn : NormalForm sig 0 3, (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔ sub_nf.2 ssn = true`

**For the atom part**:
- Predicate atoms at x (index 0): `h_compat` gives `nf_x.1 (pred p 0) == sub_nf.1 (pred p 0)`, so M.interp p x matches sub_nf.1. But we need to extract M.interp p x from `h_endRight`. Since `h_endRight = TemporalPred.eval_at M atomMap vea.endpointRight x`, and `vea.endpointRight = ⟨Formula.and (char_1 nf_x) (formula_conjList ...)⟩`, evaluating temporal_truth gives `char_1(nf_x)` holds at x. By `char_1_correct`, `nf_eval_nf M 1 1 (fun _ => x) nf_x`. This gives us the atom conditions at x.
- Predicate atoms at t (index 1): from `h_atoms` directly.
- Order atoms: h_gt/h_lt + h_t_lt_x give t < x and not x < t.

**For the quantifier part**: For each SSN, need `(∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔ sub_nf.2 ssn = true`. This requires showing that the VecEA2 components (endLeft, endRight, bracket) encode all the quantifier information.

Strategy: for each ssn, case-split on its zone (via `ssn_zone_until`):
- **below_t**: h_endLeft encodes the pre_conditions_at_t_until, which includes Since/snce formulas for below_t SSNs. Extract the quantifier condition from the conjunction.
- **eq_t**: h_endLeft encodes eq_t conditions (char_y at t). Extract similarly.
- **between_tx**: h_bracket encodes these via IntervalPattern witnesses. Positive: bracket witnesses give y. Negative: segment guards exclude impossible types.
- **eq_x**: h_endRight encodes these via char_y or neg(char_y) at x. Extract from the conjunction.
- **above_x**: h_endRight encodes these via Until(char_y, top) or neg at x. Extract similarly.

This is the hardest sorry because it requires reversing the enriched formula construction -- extracting NF information from temporal formula truth. The zone-by-zone case analysis mirrors the backward direction (backward_holdsLeft_of_nf_eval) but in reverse.

**Key challenge**: The endLeft/endRight/bracket encode conjunctions of temporal formulas. Extracting individual conjunct truth from `formula_conjList` truth requires `formula_conjList_iff` (List.Forall version). Then for each SSN, the relevant temporal formula encodes `∃ y, nf_eval_nf M 0 3 ...` via zone bridge biconditionals.

**Estimated lines**: 120-180

**Feasibility**: MEDIUM-HIGH. The mathematical content follows from the zone bridge biconditionals (all proved in ZoneBridge.lean). The proof is a zone-by-zone case analysis, extracting temporal formula truth from the conjunctions in endLeft/endRight and from bracket witnesses. Each case uses the corresponding zone_bridge_* backward direction. The main complexity is Lean bookkeeping (conjunct extraction, zone case dispatch, Fin arithmetic).

---

### Sorry 4: Line 1615 -- existPart_succ_n1_bypass_k0_since (Since case)

**Goal**:
```
⊢ ∃ A,
    ∀ (M : OrderedMonadicStructure sig),
      semantic_prior_UZ M atomMap →
        semantic_prior_SZ M atomMap →
          ∀ (t : M.carrier),
            (∀ (a : AtomKind sig 1), atom_eval M (fun x ↦ t) a ↔ parent_atoms a = true) →
              (temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M 1 (1 + 1) (Fin.cons x fun x ↦ t) sub_nf)
```

**Available hypotheses**:
- `h_gt : sub_nf.1 (order 1 0) = false` (NOT t < x)
- `h_lt : sub_nf.1 (order 0 1) = true` (x < t -- Since direction)
- `char_1_correct, h_surj, atomMap`

**Analysis**: This is structurally identical to the Until case (`existPart_succ_n1_bypass_k0_until`, lines 1507-1587) but with reversed roles of x and t. In the Until case, the formula is `enriched_bypass_until` which uses `VVecEA2.translateLeft`. For Since, the formula is `enriched_bypass_since` (defined at line 515) which uses `formula_disjList` of `Since(pt_x, guard)` patterns.

The Since definition (lines 515-594) uses a different encoding than Until:
- It does NOT use VVecEA2/VecEA2 framework
- Instead, it directly constructs `formula_disjList` of `Formula.and pre_at_t (Formula.snce pt_x guard)`
- pre_at_t handles y > t and y = t zones (evaluated at t)
- pt_x handles y = x and y < x zones (evaluated at x)
- guard handles x < y < t (between zone, negative cases)

The proof structure mirrors Until:
1. **Formula construction**: `enriched_bypass_since` provides the formula A
2. **Backward** (exists x, nf_eval -> formula truth): Given x < t with nf_eval, find the right disjunct (nf_x = nf_characteristic), show pre_at_t holds at t (above_t and eq_t zones), show pt_x holds at x (eq_x and below_x zones), show guard holds between x and t (negative between SSNs)
3. **Forward** (formula truth -> exists x, nf_eval): From Since semantics, extract x < t. Extract nf_x from the disjunction. Reconstruct nf_eval from the temporal conditions.

**Key asymmetries with Until**:
- Zone naming is reversed: below_t <-> above_x, between_tx -> between_xt
- The Since formula uses `Formula.snce` instead of Until's `Formula.untl`
- The enriched_bypass_since does NOT use VecEA2 framework, so `VVecEA2.translateLeft_correct` is not directly available
- Instead, the proof needs to work with `formula_disjList` + `Formula.snce` directly

This means the Since proof cannot simply copy-paste the Until proof structure. The Since formula uses a flatter construction (no VecEA2 wrapper), so the proof needs to handle the Since temporal semantics directly:
- `temporal_truth M atomMap t (Formula.snce pt_x guard)` unfolds to `∃ x, x < t ∧ temporal_truth M atomMap x pt_x ∧ ∀ z, x < z → z < t → temporal_truth M atomMap z guard`

**Estimated lines**: 150-200

**Feasibility**: MEDIUM. Structurally mirrors Until but uses a different formula encoding (flat disjList + Since, not VVecEA2). The proof requires adapting the zone-by-zone case analysis for the reversed direction. The zone bridge theorems in ZoneBridge.lean are symmetric (zone_bridge_below_t handles y < t, zone_bridge_above_x handles y > x -- both applicable in the Since case with swapped roles). The main risk is that the Since formula definition may have subtle differences from Until that require proof adjustments.

---

### Sorry 5: Line 1703 -- existPart_succ_n1_bypass (depth >= 2)

**Goal**:
```
case succ
k' : ℕ
char_kp1 : NormalForm sig (k' + 1 + 1) 1 → Formula
char_kp1_correct :
  ∀ (nf_1 : NormalForm sig (k' + 1 + 1) 1) (M : OrderedMonadicStructure sig),
    semantic_prior_UZ M atomMap →
      semantic_prior_SZ M atomMap →
        ∀ (t : M.carrier), temporal_truth M atomMap t (char_kp1 nf_1) ↔ nf_eval_nf M (k' + 1 + 1) 1 (fun x ↦ t) nf_1
sub_nf : NormalForm sig (k' + 1 + 1) 2
⊢ ∃ A,
    ∀ (M : OrderedMonadicStructure sig),
      semantic_prior_UZ M atomMap →
        semantic_prior_SZ M atomMap →
          ∀ (t : M.carrier),
            (∀ (a : AtomKind sig 1), atom_eval M (fun x ↦ t) a ↔ parent_atoms a = true) →
              (temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M (k' + 1 + 1) (1 + 1) (Fin.cons x fun x ↦ t) sub_nf)
```

**Analysis**: At depth k'+2 with arity 2, `sub_nf : NormalForm sig (k'+2) 2` has:
- Atom part: `sub_nf.1 : AtomKind sig 2 -> Bool` (same as depth 0/1)
- Quantifier part: `sub_nf.2 : NormalForm sig (k'+1) 3 -> Bool` (depth-(k'+1) 3-var sub-NFs)

The existential `∃ x, nf_eval_nf M (k'+2) 2 (Fin.cons x (fun _ => t)) sub_nf` requires:
1. Atoms at (x, t) match sub_nf.1
2. For each `ssn : NormalForm sig (k'+1) 3`: `(∃ y, nf_eval_nf M (k'+1) 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔ sub_nf.2 ssn = true`

The critical difference from depth 0 is that the quantifier conditions involve depth-(k'+1) 3-var existentials, not depth-0 (purely atomic) ones. At depth 0, the 3-var existentials decompose into zone conditions via VecEADecomp. At depth k'+1, the decomposition is not purely atomic -- the 3-var NF includes its own quantifier conditions at depth k'.

**Plan v30 Phase 3 approach**: Generalize the enriched formula to all depths by using `char_kp1_correct` (the IH) to encode the depth-(k'+1) quantifier conditions. The key insight is that `char_kp1_correct` provides temporal formulas for depth-(k'+2) 1-var NFs. Combined with the zone decomposition, each 3-var condition at depth k'+1 can be encoded temporally IF we have ExistPart at depth k'+1 for all arities.

However, `existPart_succ_n1_bypass` itself only handles n=1 (arity 2). The 3-var existential has arity 3 (n=2). This is the "arity-climbing" issue: to encode depth-(k'+2) arity-2 conditions, we need depth-(k'+1) arity-3 encodings, which need depth-k' arity-4 encodings, etc.

The mutual induction in `kamp_mutual_induction` provides `ExistPart atomMap h_surj k` for all k, but ExistPart is defined for all n. The `existPart_succ` theorem at n >= 2 (RabinovichGeneralized.lean:465) has its own sorry that depends on the n=1 case.

**Estimated lines**: 400-600 (new generalized bypass + proof)

**Feasibility**: LOW. This requires substantial new mathematical content:
1. Generalize `enriched_bypass_formula` to arbitrary depth and arity
2. Prove correctness at all depths via induction on k
3. Handle the arity-climbing: n=1 -> n=2 -> n=3 -> ...
4. The mutual induction structure needs careful management of the IH

This sorry blocks `nf_2var_exist_formula_prior` at depth >= 2 and `existPart_succ` at n >= 2. It is the deepest mathematical content remaining.

## Infrastructure Inventory

### Sorry-Free Files (DO NOT MODIFY)

| File | Lines | Key Exports |
|------|-------|-------------|
| ZoneBridge.lean | ~430 | zone_bridge_{above_x, between_tx, below_t, eq_x, eq_t}, ssn_order_consistent, ssn_order_consistent_of_eval |
| VecEADecomp.lean | 898 | nf_3var_bracket_tyx_correct, zone decomposition for all 9 zones |
| KampForward.lean | ~670 | ssn_bracket_tyx_forward, ssn_zone_ytx_forward, ssn_eq_yt_forward, ssn_eq_yx_forward, per-SSN zone composition |
| NfToVecEA.lean | 700+ | bracketBuildLeft, depth-0 2-var bridge |
| VecEATranslation.lean | 302 | VecEA2.translateLeft_correct, VVecEA2.translateLeft_correct |
| VecEAFormula.lean | ~340 | IntervalPattern.holds, BracketFormula.holds, VecEA2.holds, VVecEA2.holds |
| NormalForm.lean | ~270 | nf_eval_nf, nf_characteristic, nf_characteristic_satisfies, nf_eval_unique |

### Key Lemmas Available in KampBypass.lean (proved)

| Name | Line | Purpose |
|------|------|---------|
| witness_eq_t_of_no_order | 653 | x = t when both order bools false |
| eq_case_orders | 676 | xt=false, tx=false, yx=yt, xy=ty from ssn_order_consistent |
| below_t_temporal_iff | 907 | zone bridge for y < t |
| eq_t_temporal_iff | 969 | zone bridge for y = t |
| eq_x_temporal_iff | 1041 | zone bridge for y = x |
| above_x_temporal_iff | 1079 | zone bridge for y > x |
| between_tx_temporal_iff | 1177 | zone bridge for t < y < x |
| seg_guard_holds | 1206 | segment guard holds for neg between_tx SSNs |
| pre_conditions_at_t_until_holds | 1124 | endLeft holds at t |
| nf_x_compat_of_nf_eval | 288 | compat check passes for characteristic NF |
| zone_from_nf_eval | 264 | extract zone from nf_eval |

## Critical Path Analysis

### If all 4 depth-0 sorries are filled (lines 753, 1284, 1503, 1615):
- `existPart_succ_n1_bypass_k0` becomes sorry-free
- `nf_2var_exist_formula_prior` at depth 1 (k=1 case, NfCharFormula.lean:639-644) becomes sorry-free
- `nf_characterizable_temporal_prior_classical` at depth 1 becomes sorry-free
- `kamp_mutual_induction` at k=1 becomes sorry-free (CharPart(1) + ExistPart(1))
- NfCharFormula.lean:542 (`nf_exist_backward_prior`) remains sorry but is BYPASSED (not on critical path)

### Remaining sorry chain after depth-0 fills:
1. KampBypass.lean:1703 (`existPart_succ_n1_bypass` succ k') -- blocks depth >= 2
2. RabinovichGeneralized.lean:465 (`existPart_succ` n >= 2) -- depends on #1
3. NfCharFormula.lean:542 (`nf_exist_backward_prior`) -- bypassed
4. Downstream: `kamp_mutual_induction` at k >= 2, `US_expressively_complete_over_prior` at depth >= 2

### If depth >= 2 sorry (line 1703) is also filled:
- `existPart_succ_n1_bypass` becomes sorry-free at all depths
- `nf_2var_exist_formula_prior` becomes sorry-free at all depths
- `existPart_succ` n=1 becomes sorry-free (via `existPart_succ_n1_bypass`)
- `existPart_succ` n >= 2 (RabinovichGeneralized.lean:465) still sorry -- separate fix needed
- `kamp_mutual_induction` at all k depends on `existPart_succ` for all n

## Recommended Fill Order

### Order: Line 753 (eq) -> Line 1615 (since) -> Line 1284 (bracket) -> Line 1503 (forward) -> Line 1703 (depth >= 2)

**Rationale**:

1. **Line 753 (eq case)** -- FIRST. Easiest (HIGH feasibility). The x=t collapse eliminates zone complexity. Uses existing `witness_eq_t_of_no_order`, `eq_case_orders`, and zone bridges. ~80-120 lines. Quick win that validates the enriched formula approach.

2. **Line 1615 (since case)** -- SECOND. Self-contained sorry that doesn't depend on the other depth-0 sorries. The Since formula uses a simpler encoding (flat disjList, not VVecEA2). Can be developed independently. ~150-200 lines.

3. **Line 1284 (bracket)** -- THIRD. Requires the witness-sorting argument for IntervalPattern construction. Medium difficulty but well-scoped. Does NOT depend on the forward direction. ~60-120 lines.

4. **Line 1503 (forward)** -- FOURTH. Hardest of the depth-0 sorries. Requires extracting NF conditions from temporal formula truth by reversing the enriched formula construction zone-by-zone. May benefit from having the bracket sorry filled first (validates the IntervalPattern approach). ~120-180 lines.

5. **Line 1703 (depth >= 2)** -- LAST. Substantial new mathematical content. Depends on all depth-0 sorries being filled (or at least validated). ~400-600 lines. Should be attempted as a separate phase.

### Estimated Total Lines

| Sorry | Est. Lines | Feasibility |
|-------|-----------|-------------|
| L753 (eq) | 80-120 | HIGH |
| L1615 (since) | 150-200 | MEDIUM |
| L1284 (bracket) | 60-120 | MEDIUM |
| L1503 (forward) | 120-180 | MEDIUM-HIGH |
| L1703 (depth >= 2) | 400-600 | LOW |
| **Total** | **810-1220** | -- |

## Risk Factors

1. **Bracket witness ordering (L1284)**: The IntervalPattern requires strictly increasing witnesses. If `pos_between` has multiple elements, a sorting/permutation argument is needed. Risk: Fin arithmetic complexity in Lean. Mitigation: use Classical.choice + well-ordering of M.carrier.

2. **Forward direction zone extraction (L1503)**: Reversing the enriched formula requires extracting individual zone conditions from conjunctions. Risk: formula_conjList extraction may be tedious with many zone cases. Mitigation: each zone follows the same pattern (zone_bridge_* backward).

3. **Since asymmetry (L1615)**: The enriched_bypass_since uses a different encoding than Until (flat disjList vs VVecEA2). Risk: proof patterns don't transfer directly. Mitigation: the Since formula is actually simpler (no VecEA2 wrapper), so the proof may be more direct.

4. **Depth >= 2 arity climbing (L1703)**: This is the deepest mathematical challenge. The mutual induction on depth and arity requires careful management of IH parameters and Lean type constraints (Fin arithmetic at higher arities). Risk: high. Mitigation: start with the n=1 case (sufficient for the critical path via `nf_2var_exist_formula_prior`), then generalize.

5. **Heartbeat budget**: Several theorems already use `set_option maxHeartbeats 800000-1600000`. Adding 100+ lines of proof may push heartbeat limits. Mitigation: factor proofs into small helper lemmas.
