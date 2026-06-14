# Report 28: KampBypass Sorry-to-Resolution Mapping

**Task**: 273 (chronicle_gap_contradiction_proof)
**Agent**: lean-research-hard-agent (hard mode)
**Session**: sess_1781453638_2632a8
**Reference Grounding Tier**: 3 (implementation-backed)

---

## Summary

All 7 sorries in KampBypass.lean are in the k=0 (depth-1) case of the enriched bypass formula. They fall into two groups: the **backward direction** (nf_eval -> temporal formula, 4 sorries: lines 831, 911, 923, 927), the **forward direction** (temporal formula -> nf_eval, 1 sorry: line 985), the **equality case** (1 sorry: line 720), and the **since case** (1 sorry: line 1097).

The critical finding: **KampForward.lean already has sorry-free per-SSN zone composition theorems** that cover the same zone-to-temporal bridges these sorries need. The remaining work is wiring: composing these per-SSN theorems into the formula_conjList/filterMap structure that KampBypass uses.

---

## Sorry Mapping Table

| Sorry Line | Theorem | Goal (abbreviated) | Resolution | Theorem/Adapter |
|-----------|---------|-------------------|------------|-----------------|
| 720 | `existPart_succ_n1_bypass_k0_eq` | `temporal_truth M atomMap t (enriched_bypass_eq ...) <-> exists x, nf_eval_nf M 1 (1+1) ...` | ADAPTER NEEDED | `enriched_bypass_eq_correct` (~120 lines) using `eq_yt_nf_correct`, `eq_yx_nf_correct`, `char_1_correct` |
| 831 | `pre_conditions_at_t_until_holds` | `temporal_truth M atomMap t (pre_conditions_at_t_until ...)` | ADAPTER NEEDED | `pre_conditions_holds` (~100 lines) using `ssn_zone_ytx_forward`, `ssn_eq_yt_forward`, `formula_conjList_iff` |
| 911 | `backward_holdsLeft_of_nf_eval` (endLeft) | `TemporalPred.eval_at M atomMap vea.snd.endpointLeft t` | DIRECT APPLY | `exact pre_conditions_at_t_until_holds M atomMap h_surj sub_nf nf_x_1var parent_atoms x t h_t_lt_x ... h_eval_quant` (once line 831 is filled) |
| 923 | `backward_holdsLeft_of_nf_eval` (endRight) | `temporal_truth M atomMap x (formula_conjList (filterMap ... eq_x/above_x ...))` | ADAPTER NEEDED | `right_conjuncts_holds` (~80 lines) using `ssn_eq_yx_forward`, `ssn_zone_txy_forward`, `formula_conjList_iff` |
| 927 | `backward_holdsLeft_of_nf_eval` (bracket) | `BracketFormula.holds M atomMap vea.snd.bracket t x` | ADAPTER NEEDED | `bracket_holds_of_nf_eval` (~100 lines) using `ssn_bracket_tyx_forward`, `BracketFormula.holds` |
| 985 | `forward_nf_eval_of_holdsLeft` | `nf_eval_nf M 1 (1+1) (Fin.cons x (fun _ => t)) sub_nf` | ADAPTER NEEDED | `reconstruct_nf_eval_from_vecEA2` (~150 lines) using `zone_bridge_*`, `nf_characteristic_satisfies` |
| 1097 | `existPart_succ_n1_bypass_k0_since` | `exists A, forall M h_UZ h_SZ t, ... (temporal_truth M atomMap t A <-> exists x, nf_eval ...)` | MIRROR OF UNTIL | Mirror of Until case (~200 lines) with swapped directions |

---

## Detailed Analysis: Each Sorry

### Sorry 1: Line 720 -- Equality Case (`x = t`)

**Goal state:**
```lean
|- temporal_truth M atomMap t (enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms) <->
    exists x, nf_eval_nf M 1 (1 + 1) (Fin.cons x fun x => t) sub_nf
```

**Context:** We are in the `existPart_succ_n1_bypass_k0_eq` theorem, in the case where both `h_pred_compat` and `h_t_compat` hold (all predicate compatibility checks pass). The witness `x` must equal `t` (by `witness_eq_t_of_no_order`).

**What it asks:** The enriched bypass formula for the equality zone (`enriched_bypass_eq`) -- a disjunction over compatible `nf_x` values of `char_1(nf_x) /\ quant_conjuncts` -- is equivalent to the existential `exists x, nf_eval_nf M 1 2 [x, t] sub_nf` when `x = t`.

**Available infrastructure:**
- `enriched_bypass_eq` is a `formula_disjList` over `nf_x` values satisfying `nf_x_compat_check`
- `char_1_correct`: `temporal_truth M atomMap t (char_1 nf_1) <-> nf_eval_nf M 1 1 (fun _ => t) nf_1`
- `nf_characteristic_satisfies`: the NF characteristic of `[t]` satisfies `nf_eval_nf`
- `nf_eval_nf_unique`: if two NFs are both satisfied, they are equal
- `eq_yt_nf_correct`, `eq_yx_nf_correct` from KampForward.lean (for the inner 3-var conditions)
- `nf_depth0_char_formula_correct` from Separation (for `char_y` formulas)

**Resolution strategy:**
- Forward: Given `enriched_bypass_eq` holds at `t`, extract the satisfied disjunct `nf_x`. Since `x = t`, `char_1(nf_x)` holds at `t` means `nf_eval_nf M 1 1 [t] nf_x`. The quant_conjuncts encode `forall ssn, (exists y, nf_eval_nf M 0 3 [y,t,t] ssn) <-> sub_nf.2 ssn`. Since `x = t`, the y-x and y-t orders coincide. Reconstruct `nf_eval_nf M 1 2 [t, t] sub_nf` from the atom part (via `nf_x_compat_check` + `h_t_compat`) and quant part (from `quant_conjuncts`).
- Backward: Given `exists x, nf_eval_nf M 1 2 [x, t] sub_nf`, get `x = t`. Use `nf_x := nf_characteristic M 1 1 [t]`, show it's compatible, apply `char_1_correct`, show `quant_conjuncts` hold using zone bridges from KampForward.

**Estimated complexity:** ~120 lines. The key challenge is connecting `enriched_bypass_eq`'s quant_conjuncts (which use `nf_depth0_char_formula` and Since/Until) back to the 3-var existentials. KampForward's `ssn_eq_yt_forward` and `ssn_zone_ytx_forward`/`ssn_zone_txy_forward` handle each zone.

**Adapter lemma needed:**
```lean
private theorem enriched_bypass_eq_correct
    {sig : MonadicSignature} (atomMap : Formula -> sig.preds)
    (h_surj : ...) (char_1 : NormalForm sig 1 1 -> Formula)
    (char_1_correct : ...) (parent_atoms : ...) (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ...) = false)
    (h_lt : sub_nf.1 (.order ...) = false)
    (h_pred_compat : forall p, sub_nf.1 (.pred p 0) = sub_nf.1 (.pred p 1))
    (h_t_compat : forall p, sub_nf.1 (.pred p 1) = parent_atoms (.pred p 0))
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier)
    (h_atoms : forall a, atom_eval M (fun _ => t) a <-> parent_atoms a = true) :
    temporal_truth M atomMap t (enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms) <->
    exists x, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
```

---

### Sorry 2: Line 831 -- Pre-conditions at t (Until direction)

**Goal state:**
```lean
|- temporal_truth M atomMap t (pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms)
```

**Context:** We have `h_tx : t < x`, `h_x_pred`/`h_t_pred` (predicate matching), and crucially `h_eval_quant : forall ssn, (exists y, nf_eval_nf M 0 3 [y, x, t] ssn) <-> sub_nf.2 ssn = true`.

**What it asks:** The conjunction of temporal formulas encoding y < t and y = t zone conditions holds at t.

**Available infrastructure:**
- `pre_conditions_at_t_until` is `formula_conjList` of a `filterMap` over compatible ssn values in `below_t`/`eq_t` zones
- `ssn_zone_ytx_forward` from KampForward: `exists y, nf_eval ... ssn` with `y < t` implies `Since(char_y, top)` at t
- `ssn_eq_yt_forward` from KampForward: `exists y, nf_eval ... ssn` with `y = t` implies `char_y` at t
- `formula_conjList_iff`: a conjunction holds iff each conjunct holds
- `nf_depth0_char_formula_correct`: `temporal_truth <-> predicate matching`
- `zone_bridge_below_t`, `zone_bridge_eq_t` from ZoneBridge: 3-var existential <-> simpler conditions

**Resolution strategy:**
1. Unfold `pre_conditions_at_t_until`, apply `formula_conjList_iff`
2. For each ssn in the filterMap that produces a `some` value, case split on zone:
   - `below_t` with `sub_nf.2 ssn = true`: need `Since(char_y, top)` at t. From `h_eval_quant`, the existential holds. Apply `ssn_zone_ytx_forward`.
   - `below_t` with `sub_nf.2 ssn = false`: need `neg Since(char_y, top)` at t. From `h_eval_quant`, the existential does NOT hold. Need backward direction: if `Since(char_y, top)` held, we could find `y < t` with matching preds, reconstruct the NF (via `zone_bridge_below_t`), contradicting `sub_nf.2 ssn = false`.
   - `eq_t` similarly: forward uses `ssn_eq_yt_forward`, backward uses `zone_bridge_eq_t`.

**Estimated complexity:** ~100 lines. The positive directions are direct applications of KampForward theorems. The negative directions require contrapositive + zone_bridge reconstruction.

**Key dependency:** `ssn_xt_compat_x_preds`, `ssn_xt_compat_t_preds` (already proved in KampBypass). Also needs the observation that `h_eval_quant` gives the truth value of each ssn.

---

### Sorry 3: Line 911 -- Backward endpointLeft (same as 831)

**Goal state:**
```lean
|- TemporalPred.eval_at M atomMap vea.snd.endpointLeft t
```

**Context:** Same as 831 but wrapped in `TemporalPred.eval_at`. The `vea.snd.endpointLeft` unfolds to `pre_conditions_at_t_until ...` (by definition of `enriched_vecEA2_until`).

**Resolution:** Once sorry 2 (line 831) is filled as a standalone theorem `pre_conditions_at_t_until_holds`, this sorry reduces to:
```lean
exact pre_conditions_at_t_until_holds M atomMap h_surj sub_nf nf_x_1var parent_atoms
  x t h_t_lt_x
  (fun p => ...) -- h_x_pred adapted to nf_x_1var form
  (fun p => ...) -- h_t_pred adapted to parent_atoms form
  h_eval_quant
```

The challenge is that `h_x_pred` gives predicates for the characteristic NF of `x`, while the theorem needs predicates for `nf_x_1var` (the projection of `nf_x`). These are definitionally equal by the construction of `nf_x_1var`.

**Estimated complexity:** ~15 lines (after sorry 2 is filled).

---

### Sorry 4: Line 923 -- Backward endpointRight (eq_x, above_x zones)

**Goal state:**
```lean
|- temporal_truth M atomMap x
    (formula_conjList
      (List.filterMap
        (fun ssn =>
          if ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true then
            match ssn_zone_until ssn with
            | YZone.eq_x => if sub_nf.2 ssn then some char_y else some char_y.neg
            | YZone.above_x =>
              if sub_nf.2 ssn then some (Until(char_y, top)) else some (Until(char_y, top)).neg
            | _ => none
          else none)
        Fintype.elems.val.toList))
```

**Context:** Same backward-direction context as 911. We need the right-endpoint conditions to hold at `x`. These are:
- `eq_x` zone: when `y = x`, the condition is `char_y` at `x` (or its negation)
- `above_x` zone: when `y > x`, the condition is `Until(char_y, top)` at `x` (or negation)

**Available infrastructure:**
- `ssn_eq_yx_forward` from KampForward: `exists y, nf_eval ... ssn` with `y = x` implies `char_y` at `x`
- `ssn_zone_txy_forward` from KampForward: `exists y, nf_eval ... ssn` with `x < y` implies `Until(char_y, top)` at `x`
- `zone_bridge_eq_x`: backward direction for eq_x zone
- `zone_bridge_above_x`: backward direction for above_x zone

**Resolution strategy:** Same pattern as sorry 2 but at point `x` instead of `t`, covering `eq_x` and `above_x` zones instead of `below_t` and `eq_t`.

**Adapter lemma needed:**
```lean
private theorem right_conjuncts_holds
    (M : OrderedMonadicStructure sig) (atomMap : ...) (h_surj : ...)
    (sub_nf : NormalForm sig 1 2) (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : ...) (x t : M.carrier) (h_tx : t < x)
    (h_x_pred : ...) (h_t_pred : ...)
    (h_eval_quant : ...) :
    temporal_truth M atomMap x (formula_conjList (...eq_x/above_x...))
```

**Estimated complexity:** ~80 lines.

---

### Sorry 5: Line 927 -- Backward bracket (between_tx zone)

**Goal state:**
```lean
|- BracketFormula.holds M atomMap vea.snd.bracket t x
```

**Context:** We need the bracket formula to hold on the interval `(t, x)`. The bracket encodes positive `between_tx` zone witnesses (t < y < x) and negative segment guards.

**Available infrastructure:**
- `ssn_bracket_tyx_forward` from KampForward: `exists y, nf_eval ... ssn` with `t < y < x` gives `y` between `t` and `x` with correct predicates
- `nf_3var_bracket_tyx_correct` from VecEADecomp: biconditional for `holds(t, x) <-> exists y, nf_eval`
- `zone_bridge_between_tx` from ZoneBridge: biconditional for the between zone

**Resolution strategy:**
1. Unfold the bracket. By `enriched_vecEA2_until`, the bracket has `pos_between.length` witnesses.
2. For each positive ssn in the between_tx zone: `h_eval_quant` gives `sub_nf.2 ssn = true`, so `exists y, nf_eval_nf M 0 3 [y, x, t] ssn`. Apply `ssn_bracket_tyx_forward` to get `y` with `t < y < x` and matching predicates.
3. For segment guards (negative between_tx): `h_eval_quant` gives `sub_nf.2 ssn = false`, so `not (exists y, nf_eval)`. Via `zone_bridge_between_tx`, any `y` between `t` and `x` with matching preds would give a contradiction.
4. Construct the `BracketFormula.holds` witness function from these y-values.

**Estimated complexity:** ~100 lines. Needs careful management of the `BracketFormula.holds` / `IntervalPattern.holds` unfolding.

---

### Sorry 6: Line 985 -- Forward direction (holdsLeft -> nf_eval)

**Goal state:**
```lean
|- nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
```

**Context:** Forward direction of the Until case. We have:
- `h_compat : nf_x_compat_check sub_nf nf_x = true` (nf_x matches sub_nf's var-0 preds)
- `h_endLeft : TemporalPred.eval_at M atomMap vea.endpointLeft t` (pre-conditions at t)
- `h_endRight : TemporalPred.eval_at M atomMap vea.endpointRight x` (char_1(nf_x) + conditions at x)
- `h_bracket : BracketFormula.holds M atomMap vea.bracket t x` (bracket witnesses)
- `h_t_lt_x : t < x`

**What it asks:** Reconstruct `nf_eval_nf M 1 2 [x, t] sub_nf` from the VecEA2 components.

**Reconstruction needed:**
1. **Atom part** (`sub_nf.1`): From `h_endRight`, extract `char_1(nf_x)` which gives `nf_eval_nf M 1 1 [x] nf_x`. Combined with `h_compat`, this gives the var-0 predicates. The var-1 predicates come from `h_atoms` (parent_atoms = t's preds). The order `t < x` comes from `h_t_lt_x` + `h_gt`.
2. **Quant part** (`sub_nf.2`): For each `ssn`, need `(exists y, nf_eval_nf M 0 3 [y, x, t] ssn) <-> sub_nf.2 ssn`. This requires:
   - Positive: for each zone, extract the temporal witness from endLeft/endRight/bracket and reconstruct the 3-var NF eval via zone bridges
   - Negative: for each zone, show the temporal formula's negation implies no witness exists

**Available infrastructure:**
- `zone_bridge_*` from ZoneBridge: biconditionals for each zone
- `nf_depth0_char_formula_correct`: temporal formula <-> predicate matching
- `reconstruct_nf_eval_3var` from ZoneBridge: reconstruct 3-var NF from predicates + orders
- The VecEA2 structure encodes which ssns are in which zones

**Estimated complexity:** ~150 lines. This is the hardest sorry because it requires reconstructing the full NF evaluation from temporal witnesses. Each zone needs its own reconstruction path.

**Adapter lemma needed:**
```lean
private theorem reconstruct_nf_eval_from_vecEA2
    (M : OrderedMonadicStructure sig) (atomMap : ...) (h_surj : ...)
    (char_1 : ...) (char_1_correct : ...)
    (sub_nf : NormalForm sig 1 2) (nf_x : NormalForm sig 1 1)
    (parent_atoms : ...) (x t : M.carrier) (h_tx : t < x)
    (h_compat : nf_x_compat_check sub_nf nf_x = true)
    (h_atoms : ...)
    (h_endLeft : TemporalPred.eval_at M atomMap (enriched_vecEA2_until ...).endpointLeft t)
    (h_endRight : TemporalPred.eval_at M atomMap (enriched_vecEA2_until ...).endpointRight x)
    (h_bracket : BracketFormula.holds M atomMap (enriched_vecEA2_until ...).bracket t x)
    (h_UZ : ...) (h_SZ : ...) :
    nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
```

---

### Sorry 7: Line 1097 -- Since case (mirror of Until)

**Goal state:**
```lean
|- exists A, forall M h_UZ h_SZ t,
    (forall a, atom_eval M (fun _ => t) a <-> parent_atoms a = true) ->
    (temporal_truth M atomMap t A <->
     exists x, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf)
```

**Context:** This is `existPart_succ_n1_bypass_k0_since`, the Since direction (`x < t`). It has `h_gt = false` and `h_lt = true`.

**What it asks:** Same as the Until case but with `x < t` instead of `t < x`. The enriched bypass since formula should be equivalent to the existential.

**Resolution:** This is a structural mirror of the Until case. The Since case uses `enriched_bypass_since` which mirrors `enriched_bypass_until` with swapped endpoints. The proof should mirror `existPart_succ_n1_bypass_k0_until` with:
- `Since(pt_x, guard)` instead of `Until(enriched_pt, guard)`
- `zone_bridge_*` with swapped x/t roles
- KampForward's `bracket_xyt_temporal_correct`, `zone_yxt_temporal_correct`, `zone_xty_temporal_correct` (the reversed-direction zones)

**Important note:** The Since case in `enriched_bypass_since` does NOT use the VVecEA2 framework. It uses a simpler `formula_disjList` of `Since(pt_x, guard)` formulas. This means its proof structure is different from the Until case -- it does not go through `VVecEA2.translateLeft_correct` and instead needs a direct proof.

**Estimated complexity:** ~200 lines (standalone theorem + helper lemmas mirroring the Until direction).

---

## Architectural Analysis: Should We Abandon KampBypass?

### The Question
KampBypass works BACKWARDS: NF booleans -> temporal formula -> prove equivalence.
KampForward works FORWARDS: VecEADecomp -> VecEA2 -> translate -> done.

KampForward already has sorry-free composition theorems for all zones. Should we restructure `nf_2var_exist_formula_prior` to call KampForward directly?

### Answer: NO, but use KampForward's per-SSN theorems as building blocks.

**Reasons not to abandon KampBypass entirely:**

1. **KampBypass is structurally complete.** All 7 sorries have clear resolution paths. The formulas are defined, the theorem statements are correct, and the proof structure is sound. The remaining work is wiring.

2. **RabinovichGeneralized.lean already depends on KampBypass.** The call chain is:
   ```
   kamp_mutual_induction -> existPart_succ -> existPart_succ_n1_bypass
   -> existPart_succ_n1_bypass_k0 -> existPart_succ_n1_bypass_k0_{eq,until,since}
   ```
   Restructuring would require rewriting RabinovichGeneralized.lean.

3. **The sorries in KampBypass are "last-mile" wiring problems**, not deep mathematical gaps. Each sorry asks "does this temporal formula encode this NF condition?" and the per-SSN answers already exist in KampForward.

### The Right Approach: Fill KampBypass sorries USING KampForward theorems

The resolution for each sorry should import and apply KampForward's per-SSN theorems:
- `ssn_bracket_tyx_forward` for between_tx positive witnesses
- `ssn_zone_ytx_forward` for below_t positive witnesses  
- `ssn_eq_yt_forward` / `ssn_eq_yx_forward` for equality zone witnesses
- `ssn_zone_txy_forward` for above_x positive witnesses
- `zone_bridge_*` from ZoneBridge for the backward (negative) directions

This gives us the best of both worlds: KampBypass's structural completeness + KampForward's sorry-free per-SSN correctness proofs.

### Does KampForward have a theorem matching `nf_2var_exist_formula_prior`'s type signature?

The type signature at k+1 is:
```lean
exists A, forall M h_UZ h_SZ t,
    (forall a, atom_eval M (fun _ => t) a <-> parent_atoms a = true) ->
    (temporal_truth M atomMap t A <->
     exists x, nf_eval_nf M (k+1) (1+1) (Fin.cons x (fun _ => t)) sub_nf)
```

KampForward does NOT have a single theorem with this exact signature. KampForward's theorems are per-SSN (single 3-var NF), while this signature quantifies over the full depth-(k+1) NF which has both an atom part and a quantifier part (`sub_nf.1` and `sub_nf.2`). The composition of all per-SSN theorems into this single existential statement IS what KampBypass does, and its structure (case split on x-t order, disjunction over compatible nf_x, conjunction of per-ssn conditions) is correct.

---

## Dependency Graph

```
Sorry 831 (pre_conditions) -- standalone, no dependency on other sorries
Sorry 911 (endLeft)        -- depends on 831 (same theorem, different wrapper)
Sorry 923 (endRight)       -- standalone, parallel to 831 for x instead of t
Sorry 927 (bracket)        -- standalone, uses different zone
Sorry 985 (forward)        -- depends on 831, 923, 927 being understood but NOT filled
Sorry 720 (equality)       -- standalone, different proof from Until/Since cases
Sorry 1097 (since)         -- standalone, mirror of Until (does NOT depend on Until being filled)
```

**Recommended fill order:**
1. Fill 831 (pre_conditions_at_t_until_holds) -- foundational, used by 911
2. Fill 923 (right_conjuncts) -- parallel to 831
3. Fill 927 (bracket) -- parallel to 831, 923
4. Fill 911 (endLeft) -- trivial once 831 is done
5. Fill 985 (forward) -- hardest, needs understanding of all zones
6. Fill 720 (equality) -- independent
7. Fill 1097 (since) -- mirror, can be done independently

**Total estimated lines:** ~765 lines across all 7 sorries.

---

## Adversarial Self-Verification

### Challenged claims:

1. **"ssn_zone_ytx_forward handles the below_t positive case"** -- VERIFIED. `ssn_zone_ytx_forward` takes `h_yt : ssn order(0,2) = true` and produces `temporal_truth M atomMap t (Since(char_y, top))`. The below_t zone in `pre_conditions_at_t_until` produces `Since(char_y, top)` when `sub_nf.2 ssn = true`. The zone classification differs (`YZone.below_t` in KampBypass vs `zone_ytx` in KampForward) but the order conditions are the same: `y < t`, `y < x`, `t < x`.

2. **"Sorry 911 is trivial once 831 is filled"** -- VERIFIED with caveat. The `vea.snd.endpointLeft` unfolds to `pre_conditions_at_t_until` but through the `enriched_vecEA2_until` definition. Need to verify that the definitional unfolding aligns. Looking at line 471-474 of KampBypass.lean, `endLeft` is defined as `TemporalPred (pre_conditions_at_t_until ...)`, so `TemporalPred.eval_at` unfolds to `temporal_truth M atomMap t (pre_conditions_at_t_until ...)` -- matching the goal of sorry 831. Verified.

3. **"The Since case does not use VVecEA2"** -- VERIFIED. Lines 514-594 of KampBypass.lean define `enriched_bypass_since` as a `formula_disjList` of direct `Formula.and pre_at_t (Formula.snce pt_x guard)` terms. No VVecEA2 construction.

4. **"KampForward per-SSN theorems cover all zones needed"** -- VERIFIED. KampForward has:
   - `ssn_bracket_tyx_forward` (between_tx)
   - `ssn_zone_ytx_forward` (below_t)
   - `ssn_eq_yt_forward` (eq_t)
   - `ssn_eq_yx_forward` (eq_x)
   - `ssn_zone_txy_forward` (above_x)
   All 5 zones used in the Until direction are covered.

5. **"765 lines total"** -- UNCERTAIN (confidence: medium). The line estimates per sorry are conservative. The actual complexity depends on how easily `formula_conjList_iff` interacts with the `filterMap` structure. If the membership/case-split boilerplate is high, the real number could be 900+.

### Uncertain claims:
- Whether the negative directions (showing non-existence from temporal formula negation) will be cleanly expressible using zone bridges alone, or whether additional helper lemmas about `nf_depth0_char_formula_correct` composition are needed. Confidence: 70%.

### No recommendations modified after verification.

---

## Tactic Survey Results

Not performed for this research dispatch (focus was on sorry mapping, not tactic exploration). The implementation dispatch should use `lean_multi_attempt` at each sorry location after the adapter lemmas are written.

---

## Memory Candidates

1. **KampForward per-SSN theorems are the building blocks for KampBypass sorries.** Each sorry in KampBypass's backward direction (nf_eval -> temporal) maps to a specific KampForward forward theorem (`ssn_zone_*_forward`, `ssn_eq_*_forward`, `ssn_bracket_tyx_forward`). The backward negative directions use ZoneBridge's `zone_bridge_*` lemmas for contrapositive arguments.

2. **`formula_conjList_iff` + `filterMap` is the structural pattern.** All "conjunction of zone-based conditions" sorries (831, 911, 923) follow the same pattern: apply `formula_conjList_iff`, then for each element in the `filterMap`, use `h_eval_quant` to determine the truth value and apply the per-SSN forward/backward theorem.

3. **The Since case (1097) does NOT use VVecEA2** -- it uses `formula_disjList` of `Since(pt_x, guard)` directly. This means its proof structure is simpler but more manual than the Until case which goes through `VVecEA2.translateLeft_correct`.
