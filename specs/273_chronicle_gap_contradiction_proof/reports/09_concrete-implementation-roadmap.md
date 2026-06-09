# Concrete Implementation Roadmap for Existential Transfer

**Task**: 273 -- chronicle_gap_contradiction_proof
**Session**: sess_1781038703_f34152
**Date**: 2026-06-09

## 1. Literature Mapping: GHR93 Proposition 7

### What Proposition 7 States

GHR93 Proposition 7 (= GHR94 Proposition 12.8.18) is the composition lemma for EF games on colored linear orders. It says:

**Statement**: For all n < omega, let M, N be linear temporal structures with matched m-tuples x_1 < ... < x_m and y_1 < ... < y_m. If Duplicator has winning strategies for the interval games G_{f(n),g(n)}(M, x_i x_{i+1}; N, y_i y_{i+1}) AND G_{f(n),g(n)}(N, y_i y_{i+1}; M, x_i x_{i+1}) for all 0 <= i <= m, then Duplicator wins the n-round EF game G^n((M,x),(N,y)).

### How the Proof Works (Step by Step)

1. **Base case n=0**: Trivial (no moves to play).

2. **Inductive step n -> n+1**: Suppose Forall picks a point `a` in M falling in the interval (x_i, x_{i+1}).

3. **Decomposition enumeration**: List all decomposition formulas phi_1,...,phi_j satisfied by (x_i, a) and psi_1,...,psi_k satisfied by (a, x_{i+1}).

4. **Strategy application**: Exists chooses witnesses for the decomposition formulas plus `a` itself, making at most f(n+1) points total. She applies her winning strategy for the interval game to find a matching point `e`.

5. **Interval splitting**: By Lemma 12.8.14, the decomposition agreement gives forward strategies on sub-intervals. By Theorem 12.8.15 (the backward game theorem), she also gets backward strategies.

6. **IH application**: The IH at `n` with the augmented tuple (x,...,a,...) / (y,...,e,...) completes the proof.

### The Critical Sub-result: Theorem 12.8.15

The backward game theorem says: if Exists wins G_{1+3n, r+4n}(M,xy; N,x'y') then she wins G_{n,r}(N,x'y'; M,xy). The proof is by induction on n with 4 cases based on the nature of the last point a_n (real point, left-definable gap, right-definable gap, etc.).

### Mapping to Lean Constructs

In the existing codebase, the EF game framework is encoded as **NormalForm agreement** rather than explicit game strategies. The key correspondence:

| GHR93 Concept | Lean Construct |
|---|---|
| Duplicator winning strategy for G_{n,r} | `nf_characteristic M k n env = nf_characteristic M' k n env'` |
| n-round EF game at depth r | `nf_eval_nf M k n env nf` (depth k, arity n) |
| Decomposition formula agreement | `nf_fraisse_compression` (atoms + quantifier transfer => NF equality) |
| Interval type agreement | `interval_nf_types M k lo hi = interval_nf_types M' k lo' hi'` |
| Zone matching (Exists's strategy) | `zone_match_witness` (5-zone case analysis) |
| Existential transfer at depth j | `existential_transfer_from_nf` (n-var NF agreement at depth j+1 => (n+1)-var transfer at depth j) |

## 2. Sorry Site Analysis

### Sorry Site 1 (Line 2405) -- Forward direction of nf_2var_existential_transfer

**Location**: `nf_2var_existential_transfer`, forward branch, case `j' + 1`

**Goal state**:
```lean
⊢ (∃ x, nf_eval_nf M' j' (2 + 1 + 1) (Fin.cons x (Fin.cons u' (Fin.cons x' fun x ↦ t'))) sub_nf) ↔
    ∃ x_1, nf_eval_nf M j' (2 + 1 + 1) (Fin.cons x_1 (Fin.cons u (Fin.cons x fun x ↦ t))) sub_nf
```

**Available hypotheses include**:
- `h_3var_atoms`: 3-var atom agreement at (u,x,t)/(u',x',t')
- `hj : j' + 1 < k`
- `hu_quant`: quantifier part of chi encodes existential transfer correctly in M
- Point-wise 1-var NF agreement: `h_nf_u`, `h_nf_x`, `h_nf_t` (at depth k)
- Full zone-matching bridge data: `h_order_xt`, `h_interval_above/below`, `h_above_max`, `h_below_min`

**Meaning**: This asks for 4-variable existential transfer at depth j' for the 3-point configuration (u,x,t)/(u',x',t'). The arity is 4 (= 3+1) and the depth is j'.

### Sorry Site 2 (Line 2487) -- Backward direction of nf_2var_existential_transfer

**Goal state**: Symmetric to sorry site 1 (M and M' swapped).

```lean
⊢ (∃ x_1, nf_eval_nf M j' (2 + 1 + 1) (Fin.cons x_1 (Fin.cons u (Fin.cons x fun x ↦ t))) sub_nf) ↔
    ∃ x, nf_eval_nf M' j' (2 + 1 + 1) (Fin.cons x (Fin.cons u' (Fin.cons x' fun x ↦ t'))) sub_nf
```

### Sorry Site 3 (Line 2857) -- nf_exist_sf_guarded_backward

**Goal state**:
```lean
⊢ ∃ x, nf_eval_nf M k (1 + 1) (Fin.cons x fun x ↦ t) sub_nf
```

**Available hypotheses**:
- `h_sf`: the Stavi formula `nf_exist_sf_guarded ...` is true at `t` in `M`
- `char_k_correct`: characterizing formulas for depth-k 1-var NFs
- `h_atoms`: atom assignment at `t` matches `parent_atoms`

**Meaning**: From the Stavi formula truth, extract a witness `x` and show it satisfies the 2-var NF `sub_nf`. This requires:
1. Parsing the Stavi formula to extract a temporal witness
2. Using the bridge lemma (`nf_2var_from_interval_data`) to conclude the 2-var NF

**Dependency**: Sorry site 3 is downstream of sorry sites 1 & 2. The bridge lemma `nf_2var_from_interval_data` calls `nf_2var_existential_transfer`. Once sorry sites 1 & 2 are resolved, the bridge lemma is proved (it already has a complete proof calling `nf_fraisse_compression` + `nf_2var_existential_transfer`), and sorry site 3 becomes the standalone problem of parsing the temporal formula.

## 3. Existing Infrastructure

### Fully Proved and Available

| Lemma | Signature | Location |
|---|---|---|
| `nf_fraisse_compression` | `(k n : Nat) (M : OMS) (env_M : Fin n -> M) (M' : OMS) (env_M' : Fin n -> M') (h_atoms) (h_transfer : forall j < k, forall chi, ...) : nf_characteristic M k n env_M = nf_characteristic M' k n env_M'` | StaviCompleteness.lean:2006 |
| `zone_match_witness` | `(k : Nat) (x t : M) (x' t' : M') (u : M) (h_nf_x) (h_nf_t) (h_order) (h_interval_above) (h_interval_below) (h_above_max) (h_below_min) : exists u', nf_char M k 1 u = nf_char M' k 1 u' /\ orderings match` | StaviCompleteness.lean:2044 |
| `existential_transfer_from_nf` | `(env_M : Fin n -> M) (env_M' : Fin n -> M') (h_sig_nf : forall nf : NF (d+1) n, nf_eval M env nf <-> nf_eval M' env' nf) (chi : NF d (n+1)) : (exists w, nf_eval M (w::env) chi) <-> (exists w', nf_eval M' (w'::env') chi)` | NFGameBridge.lean:719 |
| `atom_agree_from_pointwise_nf` | `(env_M) (env_M') (h_nf_points : forall i, nf_char M k 1 (env_M i) = nf_char M' k 1 (env_M' i)) (h_order : forall i j, env_M i < env_M j <-> ...) (a : AtomKind) : atom_eval M env a <-> atom_eval M' env' a` | NFGameBridge.lean:140 |
| `nvar_nf_eq_depth_zero_from_pointwise` | `... : nf_characteristic M 0 n env_M = nf_characteristic M' 0 n env_M'` | NFGameBridge.lean:160 |
| `nf_agreement_monotone` | Depth-k agreement implies depth-j agreement for j <= k | NormalForm.lean |
| `nf_char_depth_decrease` | Depth-(k+1) 1-var NF equality implies depth-k 1-var NF equality | StaviCompleteness.lean:1857 |
| `interval_nf_types_depth_decrease` | Depth-(k+1) interval types determine depth-k interval types | StaviCompleteness.lean:1904 |
| `above_max_depth_decrease` | Depth-(k+1) above-max types determine depth-k above-max types | StaviCompleteness.lean:1942 |
| `below_min_depth_decrease` | Depth-(k+1) below-min types determine depth-k below-min types | StaviCompleteness.lean:1971 |
| `atom_agree_from_pointwise` (in StaviCompleteness.lean) | Same as `atom_agree_from_pointwise_nf` but for unbounded NF agreement | StaviCompleteness.lean:2216 |
| `nf_2var_from_interval_data` | Uses `nf_fraisse_compression` + `nf_2var_existential_transfer` to conclude 2-var NF equality | StaviCompleteness.lean:2500 |
| `nf_exist_sf_guarded_forward` | Forward direction: nf_eval => formula truth (FULLY PROVED) | StaviCompleteness.lean:2695 |

### Critical Missing Piece

**The arity-parametric depth induction inside `nf_2var_existential_transfer`**. The current code handles depth 0 correctly but at depth j'+1 reaches the sorry when it needs 4-var transfer. The resolution is a depth induction that works at ALL arities simultaneously.

## 4. Implementation Sequence

### The Mathematical Key Insight

The sorry at line 2405 needs:
```
(exists w, nf_eval_nf M' j' 4 (w :: u' :: x' :: t') sub_nf) <->
(exists w, nf_eval_nf M  j' 4 (w :: u  :: x  :: t ) sub_nf)
```

By `existential_transfer_from_nf`, this follows from 3-var NF agreement at depth j'+1:
```
forall nf : NF (j'+1) 3,
  nf_eval_nf M (j'+1) 3 (u :: x :: t) nf <-> nf_eval_nf M' (j'+1) 3 (u' :: x' :: t') nf
```

By `nf_fraisse_compression`, 3-var NF agreement at depth j'+1 follows from:
- (a) 3-var atom agreement at (u,x,t)/(u',x',t') -- **ALREADY PROVED** as `h_3var_atoms`
- (b) 4-var existential transfer at each depth d < j'+1

So the problem is self-reducing: proving 4-var transfer at depth j' reduces to proving 4-var transfer at depths d < j'. At depth 0, 4-var transfer is trivially atom agreement. This is a clean induction on j' (or equivalently on `j` in the original code).

**The fix: restructure `nf_2var_existential_transfer` to use strong induction on `j`**, where at each step the inductive hypothesis gives 4-var transfer at all depths d < j, which feeds into `nf_fraisse_compression` to get 3-var NF agreement at depth j, which feeds into `existential_transfer_from_nf` for the conclusion.

### Step 1: Arity-General NF Agreement from Pointwise Data (~30 lines)

**Lemma**: `nvar_nf_agreement_from_pointwise`

```lean
theorem nvar_nf_agreement_from_pointwise {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {k : Nat} (n : Nat)
    (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_nf_points : ∀ i : Fin n,
      nf_characteristic M k 1 (fun _ => env_M i) =
      nf_characteristic M' k 1 (fun _ => env_M' i))
    (h_order : ∀ i j : Fin n,
      (env_M i < env_M j ↔ env_M' i < env_M' j)) :
    ∀ d, d ≤ k →
      nf_characteristic M d n env_M = nf_characteristic M' d n env_M' := by
  intro d hd
  induction d with
  | zero =>
    exact nvar_nf_eq_depth_zero_from_pointwise env_M env_M' h_nf_points h_order
  | succ d' ih =>
    apply nf_fraisse_compression (d' + 1) n M env_M M' env_M'
    · exact atom_agree_from_pointwise_nf env_M env_M' h_nf_points h_order
    · intro j hj chi
      -- Use existential_transfer_from_nf: need n-var NF agreement at depth j+1
      -- j < d'+1, so j ≤ d', so j+1 ≤ d'+1 ≤ k
      -- IH gives d'-var NF agreement at depth j+1 ≤ d'
      -- But we need n-var, not d'-var... actually IH gives us depth j+1 ≤ d'
      -- Wait: IH: ∀ d ≤ d', nf_char M d n env = nf_char M' d n env'
      -- We need depth-(j+1) n-var NF agreement, and j+1 ≤ d'
      have h_nf_j1 : nf_characteristic M (j + 1) n env_M =
          nf_characteristic M' (j + 1) n env_M' :=
        ih (j + 1) (by omega) (by omega)
      -- From NF characteristic equality, get NF agreement
      have h_agree_j1 := nf_agreement_from_shared_nf M env_M M' env_M'
        (nf_characteristic M (j + 1) n env_M)
        (nf_characteristic_satisfies M (j + 1) n env_M)
        (h_nf_j1 ▸ nf_characteristic_satisfies M' (j + 1) n env_M')
      exact existential_transfer_from_nf env_M env_M' h_agree_j1 chi
```

**Purpose**: Given pointwise 1-var NF agreement at depth k and ordering agreement for an n-tuple, derive n-var NF agreement at every depth d <= k. This is the arity-parametric induction on depth that the sorry sites need.

**Dependencies**: `nvar_nf_eq_depth_zero_from_pointwise`, `nf_fraisse_compression`, `atom_agree_from_pointwise_nf`, `existential_transfer_from_nf`, `nf_agreement_from_shared_nf`

**Risk**: Low. All dependencies are fully proved. The induction is clean: the IH at depth j+1 <= d' gives n-var NF agreement, from which `existential_transfer_from_nf` derives (n+1)-var transfer.

### Step 2: Fix Sorry Site 1 & 2 (~20 lines each, ~40 total)

Replace the sorry at line 2405 with:

```lean
-- Use nvar_nf_agreement_from_pointwise to get 3-var NF agreement at depth j'+1
have h_nf_3var : nf_characteristic M (j' + 1) 3
    (Fin.cons u (Fin.cons x fun _ => t)) =
    nf_characteristic M' (j' + 1) 3
    (Fin.cons u' (Fin.cons x' fun _ => t')) := by
  apply nvar_nf_agreement_from_pointwise 3
    (Fin.cons u (Fin.cons x fun _ => t))
    (Fin.cons u' (Fin.cons x' fun _ => t'))
  · -- Pointwise 1-var NF agreement at depth k
    intro i
    refine Fin.cases ?_ (fun i' => ?_) i
    · simp only [Fin.cons_zero]
      exact h_nf_u
    · refine Fin.cases ?_ (fun i'' => ?_) i'
      · simp only [Fin.cons_succ, Fin.cons_zero]; exact h_nf_x
      · simp only [Fin.cons_succ]; exact h_nf_t
  · -- Ordering agreement for all pairs
    intro i j
    ... -- Fin.cases on i and j, using h_ux, h_xu, h_ut, h_tu, h_order_xt
  · exact j' + 1
  · omega  -- j' + 1 ≤ k from hj : j' + 1 < k
-- Now apply existential_transfer_from_nf
have h_agree := nf_agreement_from_shared_nf M
  (Fin.cons u (Fin.cons x fun _ => t)) M'
  (Fin.cons u' (Fin.cons x' fun _ => t'))
  _ (nf_characteristic_satisfies M (j' + 1) 3 _)
  (h_nf_3var ▸ nf_characteristic_satisfies M' (j' + 1) 3 _)
exact (existential_transfer_from_nf _ _ h_agree sub_nf).symm
```

The backward direction (sorry site 2) is identical with M/M' swapped.

**Risk**: Medium-low. The main risk is the `Fin.cases` boilerplate for ordering agreement at 3 variables (9 cases for all i,j pairs). This is tedious but straightforward -- the same pattern is already used extensively in the existing `h_3var_atoms` proof block (lines 2335-2375).

### Step 3: Fix Sorry Site 3 (nf_exist_sf_guarded_backward) (~80-120 lines)

This is the hardest sorry site. The goal is:
```lean
∃ x, nf_eval_nf M k (1 + 1) (Fin.cons x fun x ↦ t) sub_nf
```

given that the Stavi formula `nf_exist_sf_guarded ...` holds at `t`.

**Proof Structure**:

1. **Unfold nf_exist_sf_guarded** and case-split on the consistency checks and order direction.

2. **Extract temporal witness**: From `U(witness_type, guard)` or `S(witness_type, guard)`, extract a point `x` where `witness_type` holds (with `guard` holding between `t` and `x`).

3. **Determine x's 1-var NF**: From `char_k_correct`, the fact that `x` satisfies some `char_k nf_x` gives us `nf_eval_nf M k 1 (fun _ => x) nf_x`.

4. **Build interval data**: From the interval guard, every point between `x` and `t` satisfies some `char_k nf_u`, so we can extract interval NF types.

5. **Construct a reference model**: The sub_nf, being a valid NF, is realized in SOME model M_ref at some (x_ref, t_ref). This gives us a "reference pair" where `nf_eval_nf M_ref k 2 (x_ref, t_ref) sub_nf` holds.

6. **Apply the bridge lemma**: Show that the interval data of (x,t) in M matches that of (x_ref, t_ref) in M_ref:
   - 1-var NF agreement at x and x_ref (from atom compatibility)
   - 1-var NF agreement at t and t_ref (from parent_atoms)
   - Ordering agreement
   - Interval type agreement

7. **Transfer via nf_2var_transfer**: Conclude `nf_eval_nf M k 2 (x,t) sub_nf`.

**Dependencies**: `nf_2var_from_interval_data` (or `nf_2var_transfer`) which is proved once sorry sites 1 & 2 are resolved.

**Risk**: High. This is the most complex step because:
- Extracting the witness from the temporal formula requires case analysis on the structure of `nf_exist_sf_guarded`
- The reference model argument requires either (a) using the finite model property for NFs (i.e., every consistent NF is realized) or (b) a more direct argument
- The interval data matching between the extracted configuration and the reference may require substantial bookkeeping

**Alternative approach**: Instead of the reference model argument, prove directly that the 2-var NF of (x,t) equals sub_nf by showing they agree on atoms (from the formula structure) and on the quantifier part (from the bridge lemma applied to ANY reference model realizing sub_nf).

### Step Ordering Summary

```
Step 1: nvar_nf_agreement_from_pointwise  (~30 lines, NEW lemma)
  |
  v
Step 2: Fix sorry sites 1 & 2            (~40 lines, EDIT existing)
  |                                        Uses Step 1
  v
  [nf_2var_from_interval_data now proved]  (automatically, chain)
  [nf_2var_transfer now proved]            (automatically, chain)
  |
  v
Step 3: Fix sorry site 3                  (~80-120 lines, EDIT existing)
                                           Uses nf_2var_transfer
```

## 5. Dependency Graph

```
[PROVED] nf_fraisse_compression
[PROVED] zone_match_witness
[PROVED] existential_transfer_from_nf
[PROVED] atom_agree_from_pointwise_nf
[PROVED] nvar_nf_eq_depth_zero_from_pointwise
[PROVED] nf_agreement_from_shared_nf
[PROVED] nf_char_depth_decrease
[PROVED] interval_nf_types_depth_decrease
[PROVED] above_max_depth_decrease / below_min_depth_decrease
[PROVED] nf_exist_sf_guarded_forward
    |
    v
[NEW] nvar_nf_agreement_from_pointwise    <-- Step 1
    |
    v
[FIX] nf_2var_existential_transfer       <-- Step 2 (sorry sites 1 & 2)
    |
    v
[CHAIN] nf_2var_from_interval_data        (auto-proved, calls above)
[CHAIN] nf_2var_transfer                  (auto-proved, calls above)
    |
    v
[FIX] nf_exist_sf_guarded_backward       <-- Step 3 (sorry site 3)
    |
    v
[CHAIN] nf_2var_exist_sf_classical        (auto-proved)
[CHAIN] nf_2var_existence_characterizable (auto-proved)
[CHAIN] nf_characterizable_by_stavi       (auto-proved)
[CHAIN] pigeonhole_definable_formula      (auto-proved)
[CHAIN] stavi_expressive_completeness     (auto-proved)
```

## 6. Risk Assessment

### Step 1 (nvar_nf_agreement_from_pointwise) -- LOW RISK

- Clean induction on depth
- All dependencies are fully proved
- The pattern is straightforward: base case uses `nvar_nf_eq_depth_zero_from_pointwise`, inductive step uses `nf_fraisse_compression` + `existential_transfer_from_nf`
- **Potential issue**: The `nvar_nf_agreement_from_pointwise` lemma statement needs depth k as a parameter, but the pointwise NF data is at depth k while we want to conclude at depth d <= k. This requires `nf_agreement_monotone` to weaken pointwise data from depth k to depth d. Already available.

### Step 2 (Fix sorry sites 1 & 2) -- MEDIUM-LOW RISK

- Uses Step 1 as a black box
- Main complexity: 3-variable ordering boilerplate (9 cases for Fin 3 pairs)
- The pattern is exactly the same as the existing `h_3var_atoms` proof block
- **Potential issue**: Getting the depth bound right. We need depth j'+1 <= k for the Step 1 lemma. We have `hj : j' + 1 < k`, so `j' + 1 <= k - 1 < k`. But we need d = j'+1 <= k... `j'+1 < k` gives `j'+1 <= k-1 < k`, which is `j'+1 <= k` since k >= 1 (from j'+1 < k). So `j'+1 <= k` holds. This is fine.

### Step 3 (Fix sorry site 3) -- HIGH RISK

This is the most complex step and has multiple sub-problems:

1. **Temporal formula parsing**: The structure of `nf_exist_sf_guarded` involves several cases (t < x, x < t, x = t) and uses `sf_disjList` for witness type matching. Extracting the witness requires unfolding these definitions.

2. **Reference model construction**: We need to show that sub_nf is realizable in some model. The NF theory guarantees this (every NF is the characteristic NF of some environment in some model), but we may need a separate lemma `nf_realizable`.

3. **Interval data matching**: The bridge lemma needs 7 hypotheses (2 NF equalities, ordering, 2 interval type equalities, above-max, below-min). Establishing each from the formula parse requires careful argument.

4. **Size estimate**: The `nf_exist_sf_guarded_forward` proof (the "easy" direction) is already ~120 lines (lines 2695-2815). The backward direction will be at least as long.

**Mitigation strategies**:
- Factor the reference model argument into a separate lemma
- Use the already-proved `nf_exist_sf_guarded_forward` as a guide for structure
- Consider whether the backward direction can be simplified by using Classical logic more aggressively (the theorem is already noncomputable)

### Overall Assessment

Steps 1 and 2 are highly feasible and should eliminate all 3 sorry sites that are upstream of sorry site 3. The total new code for Steps 1 and 2 is estimated at ~70 lines.

Step 3 is the riskiest but is also the most self-contained. Once Steps 1 and 2 are done, Step 3 is a pure formula-parsing problem with no mathematical uncertainty.

**Estimated total new/modified code**: 150-200 lines across 3 steps.

## 7. Implementation Notes for Agents

### File to Modify

All changes go in: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

### Exact Insertion Points

**Step 1**: Insert `nvar_nf_agreement_from_pointwise` just BEFORE `nf_2var_existential_transfer` (around line 2265). It needs to import from NFGameBridge.lean, which is already imported via Decomposition.

**Step 2**: Replace `sorry` at line 2405 and `sorry` at line 2487. The replacement code uses `nvar_nf_agreement_from_pointwise` + `existential_transfer_from_nf`.

**Step 3**: Replace `sorry` at line 2857. This is the largest change.

### What NOT to Do

- Do NOT restructure the entire `nf_2var_existential_transfer` theorem. The existing structure (forward/backward with zone_match + case split on j) is correct. Only the sorry inside `| j' + 1 =>` needs replacement.
- Do NOT introduce new axioms or sorry placeholders.
- Do NOT try to bypass the bridge lemma with a different approach. The bridge lemma architecture is sound; only the depth induction was missing.
- Do NOT try to solve Step 3 before Steps 1 and 2. The dependency is strict.

### Verification Strategy

After each step:
1. Run `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness`
2. Check that sorry count decreases
3. For Step 2: verify that `nf_2var_from_interval_data` and `nf_2var_transfer` are now sorry-free
4. For Step 3: verify that `nf_exist_sf_guarded_backward` and all downstream theorems are sorry-free
