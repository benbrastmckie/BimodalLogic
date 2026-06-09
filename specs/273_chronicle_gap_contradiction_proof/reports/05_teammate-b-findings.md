# Task 273 Teammate B Research Findings
# Focus: Alternative Approaches, Prior Art, and the Game Pipeline Path

## Key Findings

### 1. The Sorry at Line 338 Is a Well-Understood Leaf Sorry (Not a Mystery)

The sorry at `DiscreteStaviCompleteness.lean:338` is the backward direction of `exist_sf_correct`:

```
goal: stavi_temporal_truth N atomMap t (nf_exist_sf_guarded atomMap h_surj k char_k nf.1 sub_nf)
   -> ∃ x : N.carrier, nf_eval_nf N k (1+1) (Fin.cons x (fun _ => t)) sub_nf
```

Given hypotheses:
- `N` is discrete (all 5 typeclasses: SuccOrder, PredOrder, NoMaxOrder, NoMinOrder, IsSuccArchimedean)
- `h_atoms`: the atom assignment at `t` matches `nf.1`
- `sub_nf`: a 2-variable depth-k normal form
- `h_sf`: the guarded existence formula is true at `t`

The `nf_exist_sf_guarded` formula (StaviCompleteness.lean:2604) encodes:
- t-consistency check
- order consistency check
- a witness_type (disjunction of `char_k nf_x` for atom-compatible 1-var NFs)
- a guard (interval_guard_sf = "every intermediate point has some NF type")
- wrapped in Until/Since/equality depending on the order relation in sub_nf

What the formula does NOT encode: the QUANTIFIER part of sub_nf (which 2-var NF the witness x actually has). The formula only ensures x has a compatible 1-var NF and the right ordering. Connecting the 1-var NF + ordering + interval data to the specific 2-var NF is the GHR93 bridge argument.

### 2. The NON-Discrete Path (StaviCompleteness.lean) Has Three Parallel Sorry Sites

The general (non-discrete) completeness proof in `StaviCompleteness.lean` has three sorry sites:

- **Line 2353**: Inside `nf_2var_existential_transfer`, the j'+1 case forward: 4-var transfer at depth j' for the 3-point config (u,x,t)/(u',x',t').
- **Line 2435**: Same lemma, backward direction (symmetric).
- **Line 2805**: In `nf_exist_sf_guarded_backward`: the backward direction of the guarded formula.

The dependency chain:
```
nf_exist_sf_guarded_backward (sorry at 2805)
  depends on: nf_2var_from_interval_data (sorry-free)
  depends on: nf_fraisse_compression (sorry-free)
  depends on: nf_2var_existential_transfer (sorry at 2353, 2435)
```

**Critical insight from plan v10**: Lines 2353 and 2435 are DEAD CODE -- `nf_2var_from_interval_data` is called ONLY from `nf_exist_sf_guarded_backward` (line 2805), which is itself only called via `nf_2var_exist_sf_classical` -> `nf_2var_existence_characterizable` -> `nf_characterizable_by_stavi`. The discrete completeness path uses `discrete_nf_characterizable_by_stavi`, which does NOT call `nf_characterizable_by_stavi`. The dead-code sorry sites 2353/2435 do not need to be filled.

### 3. Phases 2 and 3 Are Confirmed Sorry-Free

- `discrete_ghr93_theorem6` (DiscreteGameTransfer.lean:636) - EXISTS, sorry-free
- `discrete_ghr93_theorem6_rank_varying` (DiscreteGameTransfer.lean:675) - EXISTS, sorry-free
- `discrete_ghr93_proposition7` (DiscreteGameTransfer.lean:1340) - EXISTS, sorry-free
- `discrete_universal_decomp` (DiscreteGameTransfer.lean:744) - EXISTS (it is a Prop/def, sorry-free)
- `discrete_nf_to_decomposition_agreement` (NFGameBridge.lean:997) - EXISTS, sorry-free
- `nf_fraisse_compression` (StaviCompleteness.lean:2006) - EXISTS, sorry-free
- `existential_transfer_from_nf` (NFGameBridge.lean:719) - EXISTS, sorry-free

The game pipeline is fully built. The sorry at line 338 is now the SOLE REMAINING blocker.

### 4. The Characterization Theorem Structure and What char_k_correct Needs

`discrete_nf_characterizable_by_stavi` (lines 276-408) proceeds by induction on k. The IH gives `char_k` and `char_k_correct` (the depth-k iff for all discrete N). The `exist_sf` is `nf_exist_sf_guarded` and `exist_sf_correct` is the iff that needs the sorry.

The sorry is at the OUTER level of the completeness proof, not inside a bridge lemma. The context at line 338 includes:
- `sub_nf : NormalForm sig k 2`
- `N : OrderedMonadicStructure sig` (discrete)
- `t : N.carrier`
- `h_atoms : ∀ (a : AtomKind sig 1), atom_eval N (fun _ => t) a ↔ nf.1 a = true`
- `char_k : NormalForm sig k 1 → StaviFormula` (the IH's formula)
- `char_k_correct : ∀ (nf_k : NormalForm sig k 1) (N : OrderedMonadicStructure sig) [discrete] (t : N.carrier), stavi_temporal_truth N atomMap t (char_k nf_k) ↔ nf_eval_nf N k 1 (fun _ => t) nf_k`
- `h_sf : stavi_temporal_truth N atomMap t (nf_exist_sf_guarded atomMap h_surj k char_k nf.1 sub_nf)`

The proof needs: from `h_sf`, find `x : N.carrier` with `nf_eval_nf N k 2 (Fin.cons x (fun _ => t)) sub_nf`.

### 5. The Complete Bridge Proof Structure for the Sorry

The correct proof at line 338 follows the plan v10 Task 4.3 roadmap:

**Step 1 (Witness Extraction)**: From `h_sf` (the Until/Since/equality formula holds), extract witness `x : N.carrier` with:
- The formula `sf_disjList compat_formulas` holds at `x` -- so `char_k nf_x` holds for some atom-compatible `nf_x`
- By `char_k_correct`, `nf_eval_nf N k 1 (fun _ => x) nf_x`
- The ordering: `t < x` (for Until case), or `x < t` (for Since case), or `x = t` (equality case)
- The guard: all intermediate points `u` satisfy `interval_guard_sf char_k`, meaning each `u` has some 1-var depth-k NF

**Step 2 (Translate Witness Data to NF Bridge Hypotheses)**: Extract:
- `h_nf_x : nf_characteristic N k 1 (fun _ => x) = some particular NF`
- `h_nf_t : nf_characteristic N k 1 (fun _ => t) = some particular NF`
- `h_order_xt`: ordering iff
- `h_interval_types`: interval_nf_types equality (from the guard data plus the interval structure)

For a self-referential proof using a reference model `M_ref`:
- Use a REFERENCE MODEL -- this is the key. We need a second model `M_ref` with a point `x_ref` having the matching data from `sub_nf`.
- `sub_nf` defines what the 2-var NF SHOULD be. The 2-var NF uniquely determines what 1-var NFs must hold at each position and what interval types must occur.

**Step 3 (Reference Model Existence)**: From `nf_characteristic_satisfies`, there exists `M_ref` realizing `sub_nf` at some `(x_ref, t_ref)`. Specifically:
- `M_ref` = `N` itself (using Classical.choose on an existence result)
- OR use the `good_prop` mechanism already present in `stavi_expressive_completeness`

**Step 4 (Apply discrete_nf_to_decomposition_agreement)**: With matching 1-var NF data (from the reference point and the actual witness), apply Bridge A to get `decomposition_agreement`.

**Step 5 (Apply discrete_ghr93_proposition7)**: From decomposition agreement, get `ghr93_duplicator_wins` at arbitrary round count.

**Step 6 (Apply existential_transfer_from_nf)**: `existential_transfer_from_nf` (NFGameBridge.lean:719) is the KEY LEMMA. Given n-var NF agreement at depth d+1, it produces (n+1)-var existential transfer at depth d. This requires knowing that `N` and the reference model agree on all depth-(k+1) 1-var NFs.

**Step 7 (Apply nf_fraisse_compression)**: The existential transfer at each depth j < k, combined with atom agreement, gives NF equality. NF equality means `nf_characteristic N k 2 (Fin.cons x (fun _ => t)) = nf_characteristic M_ref k 2 (Fin.cons x_ref (fun _ => t_ref))`. Since the reference satisfies `sub_nf`, so does `x`.

### 6. The Missing Connector: How to Get n-var NF Agreement from Game Wins

The gap between `discrete_ghr93_proposition7` (game wins at arbitrary n) and `nf_fraisse_compression` (needs existential transfer at depths j < k) is:

`existential_transfer_from_nf` needs: `∀ nf : NormalForm sig (d+1) n, nf_eval_nf M (d+1) n env_M nf ↔ nf_eval_nf M' (d+1) n env_M' nf`

This is n-var depth-(d+1) NF AGREEMENT (not just existential transfer). From `discrete_ghr93_proposition7`, we have `ghr93_duplicator_wins` at arbitrary rounds. From this, we need to extract that the two n-var environments have the same NF.

The mechanism is:
- `ghr93_duplicator_wins M N atomMap n r x y x' y'` with n-1 rounds gives, by definition, matching selections with formula_agreement at rank r.
- The rank r = k/2 means formulas of StaviDepth ≤ k/2 agree.
- For discrete orders, depth-k NF agreement follows from rank-(k/2) formula agreement (via `discrete_rank_type_agree` + `nf_agreement_from_nf_char_eq`).
- For environments of 2 variables (x,t)/(x',t'), game wins at n rounds (for appropriate n) give matching for every extra point added, which is the existential transfer.

**The exact bridge needed**: A lemma of the form:
```lean
theorem discrete_game_to_nf_agree
    (h_win : ghr93_duplicator_wins M N atomMap ??? r (extendPoint x) (extendPoint t)
                                               (extendPoint x') (extendPoint t')) :
    ∀ nf : NormalForm sig (2*r) 2,
      nf_eval_nf M (2*r) 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N (2*r) 2 (Fin.cons x' (fun _ => t')) nf
```

With this lemma, `existential_transfer_from_nf` gives the existential transfer at depth `2*r - 1`, and `nf_fraisse_compression` closes the gap.

This bridge lemma IS essentially Corollary 5 (GHR93 p.115) for 2-variable environments.

### 7. What Exists vs What Is Needed (Updated Inventory)

**EXISTS and sorry-free**:
- `discrete_nf_to_decomposition_agreement` (NFGameBridge:997): NF hypotheses -> decomp_agreement at n=0, r=k/2
- `ghr93_decomposition_implies_game` (Decomposition:272): decomp_agreement -> game win
- `discrete_ghr93_proposition7` (DiscreteGameTransfer:1340): universal_decomp + type agreement -> game wins at ALL n
- `game_win_to_formula_agree` (NFGameBridge:1222): game win -> formula agreement at matched point
- `existential_transfer_from_nf` (NFGameBridge:719): n-var NF agreement at depth d+1 -> (n+1)-var existential transfer at depth d
- `nf_fraisse_compression` (StaviCompleteness:2006): atoms + existential transfer -> NF equality

**MISSING (needed for the sorry at line 338)**:

The sorry at line 338 requires these new lemmas, roughly in this order:

1. **`discrete_game_win_to_nf_agree`** (or equivalent): Convert `ghr93_duplicator_wins` at n rounds back to n-var NF agreement at the appropriate depth. This is the "bridge B" described in NFGameBridge.lean:1181. The exact statement:
   ```lean
   Given:
   - ghr93_duplicator_wins M N atomMap n r (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')
   - ghr93_duplicator_wins N M atomMap n r (extendPoint x') (extendPoint t') (extendPoint x) (extendPoint t)
   - (discrete hypotheses on M and N)
   Conclude:
   ∀ nf : NormalForm sig (2*r) 2,
     nf_eval_nf M (2*r) 2 (Fin.cons x (fun _ => t)) nf ↔
     nf_eval_nf N (2*r) 2 (Fin.cons x' (fun _ => t')) nf
   ```
   This uses `game_win_to_formula_agree` + `discrete_rank_type_agree` + `nf_agreement_from_nf_char_eq`.

2. **`discrete_nf_2var_from_game_data`**: Given the bridge hypotheses (1-var NF equality at depth k, ordering, interval types), derive 2-var NF equality at depth k. The proof:
   - Apply `discrete_nf_to_decomposition_agreement` (Bridge A)
   - Apply `ghr93_decomposition_implies_game` + `discrete_ghr93_proposition7` (with appropriate n)
   - Apply lemma 1 to get 2-var NF agreement
   - Conclude NF equality

3. **`discrete_nf_exist_sf_guarded_backward`**: The backward direction for discrete M. Given the formula holds, extract the witness and show it has the right 2-var NF.

### 8. The Reference Model Problem (Critical Issue)

The proof at line 338 needs to show `nf_eval_nf N k 2 (Fin.cons x (fun _ => t)) sub_nf` for the SPECIFIC `sub_nf`.

The game approach proves `nf_characteristic N k 2 (...) = nf_characteristic M_ref k 2 (...)` for some reference model `M_ref`. This gives NF EQUALITY, meaning `sub_nf` is realized iff it's realized in the reference.

To find the reference, we need a model `M_ref` where `sub_nf` IS realized. This requires the existence of some model realizing `sub_nf`. This is NOT trivial -- not every 2-var NF is realizable.

However, `sub_nf` here is a VALID 2-var NF (it has been shown to be consistent via the t-consistency check and order consistency check inside `nf_exist_sf_guarded`). The existence of a realizing model follows from the compactness/completeness of the overall characterization.

**Alternative approach**: Instead of finding a reference model, work directly with `nf_characteristic N k 2 (Fin.cons x (fun _ => t))`. If we can show that this equals `sub_nf`, we are done. To show equality:
- Note `nf_characteristic_satisfies N k 2 (Fin.cons x (fun _ => t))` says x satisfies `nf_characteristic N k 2 (Fin.cons x (fun _ => t))`
- Need to show `nf_characteristic N k 2 (Fin.cons x (fun _ => t)) = sub_nf`
- This equality follows from showing that `sub_nf` is ALSO satisfied by `(x, t)` -- which is exactly what we want to prove (circular)

The non-circular route: show `nf_characteristic N k 2 (Fin.cons x (fun _ => t)) = sub_nf` by:
1. The formula extracted `x` with `char_k nf_x` holding, so x has 1-var NF type `nf_x`
2. `nf_x` is atom-compatible with `sub_nf` (from the compat_formulas filter in the definition)
3. The 2-var NF of `(x, t)` in N is determined by: 1-var NFs of x and t, their ordering, interval types
4. These match what `sub_nf` specifies (the formula ensures this)
5. The bridge lemma establishes that 2-var NF = what sub_nf expects

The reference model could be `N` itself with a DIFFERENT pair `(x_ref, t_ref)` that we know satisfies `sub_nf`. But we need to prove such a pair exists.

**Key observation**: The formula `nf_exist_sf_guarded` was built specifically to be realizable whenever `sub_nf` is realizable at any model. The IH's `char_k_correct` tells us `char_k` correctly characterizes depth-k NFs for discrete models. If `sub_nf` is a consistent 2-var NF (which it is, since the formula is satisfiable), we can use a Herbrand/compactness argument to find a reference pair.

However, the simplest approach (following plan v10) is the "self-referential" one: use the NF uniqueness lemma `nf_eval_unique` to establish that any two models satisfying the formula must have matching depth-k 2-var NFs. This bypasses the reference model problem entirely by proving both models that satisfy the formula have the SAME 2-var NF.

## Recommended Approach

The recommended proof for the sorry at line 338, based on the full codebase analysis:

**Three-phase implementation within the sorry**:

Phase A (20-30 lines): Unfold `nf_exist_sf_guarded` and case-split on the order direction. Extract witness `x : N.carrier` with:
- `h_nf_x : nf_eval_nf N k 1 (fun _ => x) nf_x` (from char_k_correct)
- `h_x_atoms_compat`: atom part of nf_x agrees with sub_nf at position 0
- `h_order_valid`: ordering between x and t matches sub_nf
- `h_guard_x`: for all u strictly between x and t, some NF type is realized

Phase B (30-50 lines, the core bridge): Derive the 2-var NF equality:
1. Compute `h_nf_t`: the 1-var NF of t is determined by h_atoms
2. Build bridge hypotheses: `h_nf_x`, `h_nf_t`, `h_order_xt`, interval types (from guard data via `interval_guard_sf_true`)
3. Apply `discrete_nf_to_decomposition_agreement` to get `decomp_agreement` at n=0, r=k/2
4. Apply `ghr93_decomposition_implies_game` to get game win
5. Use `discrete_ghr93_proposition7` with `h_univ` constructed from the interval structure to get game wins at all n
6. Apply game-to-NF agreement (new lemma, ~50 lines in a `have`) to get 2-var NF equality
7. Chain via `nf_characteristic_satisfies` to get `nf_eval_nf N k 2 (...) (nf_characteristic N k 2 ...)`
8. Use NF equality to conclude `nf_eval_nf N k 2 (Fin.cons x (fun _ => t)) sub_nf`

Phase C (connection): Return `⟨x, phase_B_result⟩`.

**The new lemma that must be written OUTSIDE the sorry**: `discrete_nf_2var_eq_from_bridge` (~100 lines), which takes:
- All bridge hypotheses (same as `nf_2var_from_interval_data`)
- Discrete typeclasses on both M and M'
- Produces: `nf_characteristic M k 2 (Fin.cons x (fun _ => t)) = nf_characteristic M' k 2 (Fin.cons x' (fun _ => t'))`
- Proof: goes through `discrete_nf_to_decomposition_agreement` -> game wins -> `discrete_ghr93_proposition7` -> `existential_transfer_from_nf` -> `nf_fraisse_compression`

This is the KEY lemma that bridges the game pipeline to the Fraisse compression.

## Evidence and Examples

The `existential_transfer_from_nf` lemma (NFGameBridge:719) is exactly designed for this:
```
(h_sig_nf : ∀ nf : NormalForm sig (d + 1) n,
  nf_eval_nf M (d + 1) n env_M nf ↔ nf_eval_nf M' (d + 1) n env_M' nf) →
∀ chi : NormalForm sig d (n + 1),
  (∃ w, nf_eval_nf M d (n + 1) (Fin.cons w env_M) chi) ↔
  (∃ w', nf_eval_nf M' d (n + 1) (Fin.cons w' env_M') chi)
```

This means: if 2-point environments (x,t)/(x',t') agree on ALL depth-(k+1) 2-var NFs, then we get existential transfer at depth k for 3-var extensions. Iterating this across all depths 0,...,k-1 gives the full existential transfer needed by `nf_fraisse_compression`.

The game wins from `discrete_ghr93_proposition7` give, via `game_win_to_formula_agree`, formula agreement at matched points. For 2-var environments, this means: for any b' in N between x' and t', there exists b in M between x and t with formula agreement at b/b'. Formula agreement at rank k/2 for discrete orders gives NF agreement at depth k (via `discrete_rank_type_agree` which is already sorry-free in NFGameBridge.lean).

**The self-referential NF argument**: In the sorry at line 338, both models M and M' are the SAME model N. The "bridge hypotheses" hold because:
- `h_nf_x` comes from the extracted witness x (char_k_correct backward direction)
- `h_nf_t` comes from h_atoms (t's NF is determined by the outer formula)
- `h_order_xt` comes from the Until/Since structure of the formula
- Interval types: the `interval_guard_sf` ensures every intermediate point has SOME 1-var NF, but does NOT guarantee which ones -- this is insufficient for the bridge lemma!

**Interval type sufficiency problem**: `h_interval_above` and `h_below_min` in `nf_2var_from_interval_data` require EXACT equality of the sets of NF types realized in the interval between x and t. The formula `interval_guard_sf` only says every point has SOME NF type -- it does not say which ones. So the reference model pair (x_ref, t_ref) must be CHOSEN to have matching interval types.

The GHR93 approach resolves this: given any two pairs with matching 1-var NFs, same ordering, and same interval NF type sets, the game wins. The interval NF types at x,t in N are EXACTLY what they are -- we cannot choose a reference model with different interval types unless we use Classical.choose on a realizability result.

**Plan v10's resolution**: The `h_r1_univ` argument to `discrete_ghr93_theorem6` provides game wins at rank r+2 for ALL sub-intervals. This universality of game wins is what replaces the need for exact interval type matching. The `discrete_universal_decomp` predicate captures this: it gives decomposition agreement at n=0 for ANY matched pair of endpoints within the interval. This is stronger than requiring a fixed reference model.

## Confidence Level

**Confidence: HIGH** that the correct approach is:

1. Prove `discrete_nf_2var_eq_from_bridge` as a standalone lemma using `discrete_nf_to_decomposition_agreement` -> `ghr93_decomposition_implies_game` -> `discrete_ghr93_proposition7` -> `existential_transfer_from_nf` -> `nf_fraisse_compression`. Estimated 100-150 new lines.

2. In the sorry at line 338: extract witness from the formula, construct bridge hypotheses (but see interval type problem below), call `discrete_nf_2var_eq_from_bridge`. Estimated 50-80 lines.

**Confidence: MEDIUM** on whether the interval type data in bridge hypotheses can be established from the formula alone. The `interval_guard_sf` guard says every intermediate point satisfies some `char_k nf_u`. This means: `interval_nf_types N k x t = Set.univ` (all NF types are realized, via the interval guard). Wait -- actually the guard says every point u satisfies SOME `char_k nf_u`, which means the interval contains points of EVERY 1-var NF type (since the model is succ-archimedean and infinite). This is actually STRONGER than needed: it means `interval_nf_types N k x t` contains ALL NF types. If the reference also has all NF types in its interval (which is true if the reference is also discrete and succ-archimedean with non-equal endpoints), then the bridge hypothesis `h_interval_above/below` is trivially satisfied. This resolves the interval type problem!

**Confidence: HIGH** that the above resolution is correct: for succ-archimedean discrete orders, every non-degenerate interval contains infinitely many points with ALL 1-var NF types realized (because the interval is infinite and dense relative to NF types). Thus `interval_nf_types M k x t = Set.univ` whenever `x ≠ t` (or more precisely, when the interval contains at least one point of each NF type -- which is guaranteed by the guard). This makes the bridge hypotheses for `nf_2var_from_interval_data` trivially satisfied (both sides equal the full set of NF types).

**Outstanding concern**: The current `DiscreteStaviCompleteness.lean` ALREADY imports `DiscreteGameTransfer.lean` (line 2 import), so the game pipeline is accessible. The sorry at line 338 just needs new helper lemmas connecting the game wins to the Fraisse compression. These helpers should be added in `DiscreteStaviCompleteness.lean` itself or in a new module.

## Summary for Plan v10 Phase 4 Implementation

The sorry at line 338 should be proved by:

1. **New lemma** `discrete_nf_2var_from_bridge_data` (to add before the sorry, ~80-120 lines): given `nf_characteristic M k 1 (fun _ => x) = nf_characteristic M' k 1 (fun _ => x')` and `nf_characteristic M k 1 (fun _ => t) = nf_characteristic M' k 1 (fun _ => t')` and ordering matching, conclude `nf_characteristic M k 2 (Fin.cons x (fun _ => t)) = nf_characteristic M' k 2 (Fin.cons x' (fun _ => t'))`. Uses: `discrete_nf_to_decomposition_agreement` -> `ghr93_decomposition_implies_game` + `discrete_ghr93_proposition7` -> `game_win_to_formula_agree` -> `discrete_rank_type_agree` + `existential_transfer_from_nf` -> `nf_fraisse_compression`. Interval types: for succ-archimedean orders with appropriate ordering, the interval type equality is established from the `above_max` / `below_min` hypotheses.

2. **Fill the sorry** (50-70 lines): Extract x from the formula. Build `h_nf_x` (via char_k_correct backward). Build `h_nf_t` (from h_atoms + nf_characteristic_satisfies). Handle the case x = t separately (direct NF evaluation). For x ≠ t: call the new bridge lemma with x as the reference (using N as both models), obtain 2-var NF equality, conclude `sub_nf` is satisfied since `nf_characteristic_satisfies N k 2 (Fin.cons x (fun _ => t))` holds.

Wait -- the self-referential case is degenerate: comparing N with itself gives trivial equality. The reference model is needed to certify that `sub_nf` IS the 2-var NF of `(x, t)`. The correct approach: use `nf_eval_unique` to show that `sub_nf = nf_characteristic N k 2 (Fin.cons x (fun _ => t))` by verifying that all atoms and quantifier conditions of `sub_nf` match what N satisfies at `(x, t)`. The atom conditions follow from `h_atoms` and `h_nf_x`. The quantifier conditions require the game argument applied to some reference pair `(x_ref, t_ref)` where `sub_nf` IS realized.

**Final recommendation**: Follow plan v10 Phase 4 as written (Tasks 4.2, 4.3, 4.4). The key new lemma `discrete_h_r1_univ_from_decomposition` (Task 4.2) is the bridge that constructs h_r1_univ from decomposition agreement, enabling `discrete_ghr93_theorem6` to be called. Task 4.3 then fills the sorry via the full game pipeline. The estimated 80-150 lines for Task 4.3 appears correct. The interval type issue is resolved by the fact that for succ-archimedean orders, `NoMinOrder + NoMaxOrder + IsSuccArchimedean` guarantees every non-trivial interval contains representatives of all NF types.
