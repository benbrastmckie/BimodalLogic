# Report 41: Stavi Completeness Audit -- nf_characterizable_by_stavi Sorry Analysis

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Can nf_characterizable_by_stavi be used for the U(B,A) path in GHR93 Case II?

## 1. Theorem Signature and Purpose

`nf_characterizable_by_stavi` is at line 2425 of `StaviCompleteness.lean`:

```lean
theorem nf_characterizable_by_stavi
    {sig : MonadicSignature} (atomMap : Formula -> sig.preds)
    (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p)
    (k : Nat) (nf : NormalForm sig k 1) :
    exists A : StaviFormula, forall (M : OrderedMonadicStructure sig) (t : M.carrier),
      stavi_temporal_truth M atomMap t A <->
      nf_eval_nf M k 1 (fun _ => t) nf
```

**What it provides**: For any depth-k 1-variable normal form `nf`, there exists a StaviFormula `A` whose temporal truth at point `t` is equivalent to `nf_eval_nf M k 1 (fun _ => t) nf`.

**What it does NOT provide**: No `stavi_depth` bound on the output formula. The theorem guarantees existence of a characterizing StaviFormula but says nothing about its temporal depth.

## 2. Sorry Status

**lean_verify result**: `sorryAx` is present in the axiom list for `nf_characterizable_by_stavi`.

**Total sorry count in StaviCompleteness.lean**: 2 actual sorry tokens (not comments).

### Sorry #1: `nf_2var_from_interval_data` (line 1873)

The "bridge lemma" -- GHR93 Proposition 7 + Lemma 11.

```lean
private theorem nf_2var_from_interval_data
    {M M' : OrderedMonadicStructure sig}
    (k : Nat) (x t : M.carrier) (x' t' : M'.carrier)
    (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
              nf_characteristic M' k 1 (fun _ => x'))
    (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
              nf_characteristic M' k 1 (fun _ => t'))
    (h_order_xt : ...)
    (h_interval_above : ...)
    (h_interval_below : ...)
    (h_above_max : ...)
    (h_below_min : ...) :
    nf_characteristic M k 2 (Fin.cons x (fun _ => t)) =
    nf_characteristic M' k 2 (Fin.cons x' (fun _ => t'))
```

**Nature**: Fundamental mathematical content. This is the core game-theoretic composition argument: if two 2-variable environments agree on 1-variable types, ordering, interval types, and types above/below the interval, then their 2-variable NFs are equal. This requires an induction on k with a game-composition argument at each step.

**Estimated effort to close**: 200-500 lines. Requires establishing a Duplicator strategy for the (k+1)-round game from strategies for the k-round sub-games. The existing `ghr93_strategy_compose` (Composition.lean) and `decomposition_agreement` (Decomposition.lean) provide infrastructure but the connection from interval_nf_types to decomposition_agreement needs to be built.

### Sorry #2: `nf_exist_sf_guarded_backward` (line 2152)

The backward direction: temporal formula truth implies 2-variable NF satisfaction.

```lean
private theorem nf_exist_sf_guarded_backward
    ... :
    exists x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
```

**Nature**: Depends entirely on Sorry #1 (bridge lemma). The proof structure is outlined in the comments: extract witness x from temporal formula, determine its 1-var type via IH, extract interval types from the guard formula, then apply the bridge lemma. Once `nf_2var_from_interval_data` is proved, this should follow in approximately 100-200 lines.

### Dependency Chain

```
nf_characterizable_by_stavi (line 2425)
  <-- nf_2var_existence_characterizable (line 2194)
    <-- nf_2var_exist_sf_classical (line 2157)
      <-- nf_exist_sf_guarded_backward (line 2125) [SORRY #2]
        <-- nf_2var_from_interval_data (line 1853) [SORRY #1 -- ROOT CAUSE]
      <-- nf_exist_sf_guarded_forward (line 1990) [PROVED]
```

The root sorry is **single**: `nf_2var_from_interval_data`. Everything else chains through it.

## 3. stavi_depth of the Output Formula

`nf_characterizable_by_stavi` provides NO depth bound on its output. The theorem is:
```lean
exists A : StaviFormula, ...
```

The formula A is constructed via:
- Base case (k=0): conjunction of atom literals. Depth = 0 (no temporal operators).
- Inductive case (k+1): `StaviFormula.conj (sf_conjList atom_lits) (sf_conjList quant_formulas)` where each `quant_formula` is either `exist_sf sub_nf` or `.neg (exist_sf sub_nf)`.

Each `exist_sf sub_nf` is classically chosen from `nf_2var_existence_characterizable`, which returns `nf_exist_sf_guarded`. The guarded formula uses `std_untl` / `std_snce` (standard Until/Since), each adding +2 to the stavi_depth, with `interval_guard_sf char_k` as the guard (a disjunction of char_k formulas).

**Depth analysis**: The formula at depth k+1 uses Until/Since of formulas built from char_k (the IH at depth k). Each temporal operator adds +2. So the stavi_depth grows as approximately O(k) but the exact bound is not proved. The formula is NOT the rank_type formula from TypeFormulas.lean -- it is a different construction that characterizes NF satisfaction rather than bounded-depth formula agreement.

**For U(B,A) purposes**: The plan v40 line 237 says "B = X_{a_n}: the full rank-r type formula". This refers to `rank_type` from TypeFormulas.lean (depth <= r by construction), NOT to `nf_characterizable_by_stavi`. The two serve different purposes:
- `rank_type`: set of all depth-<= r formulas true at a point (a "type" in the model-theoretic sense)
- `nf_characterizable_by_stavi`: a single formula characterizing a specific NF (no depth bound proved)

## 4. Whether the Sorries Are Closeable

### Sorry #1 (`nf_2var_from_interval_data`) -- FUNDAMENTAL but CLOSEABLE

This is genuine mathematical content (game-theoretic composition for 2-variable EF games). It requires:

1. Showing that agreement on 1-var types + ordering + interval types implies Duplicator wins the 2-variable game.
2. This uses the existing game composition machinery in Composition.lean.
3. The key step: translate interval_nf_types agreement into decomposition_agreement format.

**Assessment**: Closeable with 200-500 lines of new proof. Not trivially mechanical (requires understanding the game-theoretic argument), but the infrastructure exists.

### Sorry #2 (`nf_exist_sf_guarded_backward`) -- MECHANICAL given Sorry #1

Once the bridge lemma is proved, this follows by:
1. Pattern-matching on the temporal formula to extract witness x
2. Using char_k_correct to determine x's 1-var type
3. Using interval_guard to extract intermediate point types
4. Applying the bridge lemma

**Assessment**: 100-200 lines, mostly mechanical. Blocked only by Sorry #1.

## 5. Flat Conjunction Alternative -- Viability Assessment

**Question**: Can we build B differently, bypassing `nf_characterizable_by_stavi`?

### Fintype Instance

`NormalForm sig k n` has a `Fintype` instance (NormalForm.lean:177). `StaviFormula` does NOT have a `Fintype` instance (it is an inductive type with unbounded recursion).

### sf_conjList

`sf_conjList` exists (line 1328) and converts a `List StaviFormula` to a single conjunction. `sf_conjList_iff` (line 1333) proves the conjunction holds iff all members hold.

### Could we enumerate depth-<= r StaviFormulas?

No. `StaviFormula` is not Fintype -- there are infinitely many StaviFormulas of any given depth because `base` wraps arbitrary `Formula` terms. Even filtering to a bounded depth, the base case includes arbitrary propositional formulas.

### Alternative: Use `rank_type` directly

`rank_type` (TypeFormulas.lean:356) IS the flat characteristic:
```lean
def rank_type (M : OrderedMonadicStructure sig) (atomMap : ...) (r : Nat) (t : ...) :=
  { A | stavi_depth A <= r AND stavi_temporal_truth_mu M atomMap r t A }
```

This is a SET of formulas, not a single formula. The key theorem `rank_type_eq_iff` (line 374) says equal rank_types imply formula agreement at depth <= r.

**For U(B,A)**: The plan v40 deviated from using `nf_characterizable_by_stavi` (R3.2 deviation note). Instead, Case II uses a forward-game construction with tau_left/tau_right sub-split. This approach does NOT need `nf_characterizable_by_stavi` at all.

## 6. What h_surj Requires

`nf_characterizable_by_stavi` requires:
```lean
h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p
```

This is atomMap surjectivity: every predicate in the signature has a pre-image atom. In ShiftAndGlue.lean (line 135), this is obtained from `Encodable.surjective_decode_iget`. It is available at the top level for the standard signature used in the completeness proof.

## 7. Impact Assessment for U(B,A) Path

### Current State of CaseAnalysis.lean

CaseAnalysis.lean does NOT import StaviCompleteness.lean. It imports:
- `SplitPoint`
- `EFGames.Composition`
- `Mathlib.Data.Fin.Tuple.Sort`

The plan v40 R3.2 deviation explicitly states: "instead of U(B,sf_top) transfer (requires Stavi completeness), uses forward-game e_n construction with tau_left/tau_right sub-split".

**The current Case II implementation does NOT use nf_characterizable_by_stavi and does NOT need it.**

### Remaining Sorries in CaseAnalysis.lean

3 actual sorry sites:
1. Line 2026: `b_resp vs x' equality direction` (Case B1 grid edge case)
2. Line 2107: `Case B2 ordering grid dispatch`
3. Line 3350: `Cases III/IV winning condition assembly`

None of these depend on `nf_characterizable_by_stavi`. They are all ordering-grid dispatch problems within the game-theoretic case analysis.

### Remaining Sorries in Theorem6.lean

1 actual sorry site:
- Line 325: `rank promotion: forward (1+3n) at r -> backward n at r+4`

This is a rank-promotion argument, also unrelated to `nf_characterizable_by_stavi`.

## 8. Recommendation

### Is U(B,A) within reach?

**The U(B,A) path as originally conceived (using `nf_characterizable_by_stavi` for the characteristic formula B) is NOT needed.** The plan v40 already deviated away from this approach at R3.2, and CaseAnalysis.lean does not import StaviCompleteness.lean.

### What actually blocks sorry-free completion?

The critical path to sorry-free `bx_completeness` is:

1. **CaseAnalysis.lean** (3 sorries): Grid dispatch ordering problems. These are mechanical but tedious -- they involve showing that ordering relationships between game positions are preserved through the forward/backward game construction.

2. **Theorem6.lean** (1 sorry): Rank promotion for the forward-to-backward conversion. This requires showing that a forward game at rank r can be promoted to a forward game at rank r+4, using strategy restriction to sub-intervals.

3. **StaviCompleteness.lean** (2 sorries): Only needed for `stavi_expressive_completeness` (Theorem 9.3.1), which is NOT on the critical path to `bx_completeness` unless the completeness proof goes through expressive completeness.

### Effort Estimate

| Component | Sorries | Est. Lines | Nature |
|-----------|---------|-----------|--------|
| CaseAnalysis grid dispatch | 3 | 200-400 | Mechanical ordering |
| Theorem6 rank promotion | 1 | 100-200 | Strategy restriction |
| StaviCompleteness bridge (OFF critical path) | 2 (root: 1) | 300-700 | Game composition |

**Critical path total**: 4 sorries, 300-600 lines of new proof.

### Should `nf_characterizable_by_stavi` be fixed anyway?

For the immediate goal of sorry-free `bx_completeness`: NO, it is not on the critical path.

For the long-term goal of proving Stavi expressive completeness (GHR93 Theorem 9.3.1): YES, the bridge lemma `nf_2var_from_interval_data` needs to be proved. But this is a separate concern from the Reynolds pipeline.
