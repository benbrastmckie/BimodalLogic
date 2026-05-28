# Lean Infrastructure Inventory for X_t and Task 155 Sorry Closure

**Date**: 2026-05-28
**Task**: 155 (Reynolds Pipeline Activation)

---

## 1. StaviFormula Infrastructure

### 1.1 StaviFormula Type and Core Definitions

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean`

The `StaviFormula` inductive type exists with seven constructors:
```
.base (φ : Formula)
.stavi_untl (A B : StaviFormula)
.stavi_snce (A B : StaviFormula)
.neg (φ : StaviFormula)
.conj (φ ψ : StaviFormula)
.std_untl (A B : StaviFormula)
.std_snce (A B : StaviFormula)
```

Key semantic evaluators:
- `stavi_temporal_truth` -- truth on `OrderedMonadicStructure` (non-mu-relativized)
- `stavi_temporal_truth_mu` -- truth on `ExtendedCarrier` with mu-relativization (in `TypeFormulas.lean`)
- `temporal_truth_mu` -- mu-relativized truth for standard `Formula` (in `TypeFormulas.lean`)

### 1.2 Depth Function

**File**: `EFGames/Defs.lean` (lines 164-171)

`stavi_depth` is defined recursively:
- `.base phi => operator_depth phi`
- `.stavi_untl A B => max (stavi_depth A) (stavi_depth B) + 2`
- `.neg phi => stavi_depth phi`
- `.conj phi psi => max (stavi_depth phi) (stavi_depth psi)`
- `.std_untl A B => max (stavi_depth A) (stavi_depth B) + 2`
- (Similarly for `stavi_snce`, `std_snce`)

Supporting lemma: `stavi_depth_neg` -- negation preserves depth. **Sorry-free.**

### 1.3 Conjunction/Disjunction Lists

**File**: `EFGames/StaviCompleteness.lean` (lines 1277-1360)

Both exist and are **sorry-free**:
- `sf_conjList : List StaviFormula -> StaviFormula` (empty = `.base .bot` imp `.base .bot`, cons = `.conj`)
- `sf_disjList : List StaviFormula -> StaviFormula` (empty = `.base .bot`, cons = `sf_disj`)
- `sf_conjList_iff` -- correctness theorem (forall membership)
- `sf_disjList_iff` -- correctness theorem (exists membership)

### 1.4 Fintype for StaviFormulas of Bounded Depth

**STATUS: DOES NOT EXIST.** There is no `Fintype` instance for `StaviFormula` or for `{A : StaviFormula // stavi_depth A <= r}`. The `StaviFormula` type is inductively defined with no bound on size; Fintype instances are only available for `NormalForm sig k n` (see Section 2).

The characteristic formula `X_t` does NOT require enumerating all StaviFormulas. Instead, it works through the `NormalForm` finiteness:
- `NormalForm sig k n` HAS a `Fintype` instance (see Section 2.1)
- `nf_characterizable_by_stavi` constructs a StaviFormula for each NormalForm
- The rank_type `{A | stavi_depth A <= r /\ stavi_temporal_truth_mu ... A}` is characterized indirectly through NormalForm equivalence classes

### 1.5 n-Equivalence

**File**: `EFGames/Defs.lean` (lines 180-206)

`stavi_n_equiv atomMap n M t N s` is defined as agreement on all StaviFormulas of depth <= `game_depth sig n`. Supporting lemmas:
- `stavi_n_equiv_symm` -- symmetry. **Sorry-free.**
- `stavi_n_equiv_mono` -- monotone in n. **Sorry-free.**
- `game_depth_strict_mono`, `game_depth_mono` -- depth function properties. **Sorry-free.**

---

## 2. NormalForm <-> StaviFormula Connections

### 2.1 NormalForm Type and Fintype

**File**: `NormalForm.lean`

`NormalForm sig k n` is defined recursively:
- Base (k=0): `AtomKind sig n -> Bool` (truth assignment to atoms)
- Step (k+1): `(AtomKind sig n -> Bool) x (NormalForm sig k (n+1) -> Bool)`

Key instances and theorems (**all sorry-free**):
- `normalForm_fintype : Fintype (NormalForm sig k n)` -- via mutual induction with `DecidableEq`
- `normalForm_decEq : DecidableEq (NormalForm sig k n)`
- `atomKind_fintype : Fintype (AtomKind sig n)`
- `atomKind_card : Fintype.card (AtomKind sig n) = atomCount (Fintype.card sig.preds) n`
- `normalForm_card : Fintype.card (NormalForm sig k n) = nfCount (Fintype.card sig.preds) k n`
- `nf_exists_unique` -- each environment satisfies exactly one NF
- `nf_agreement_monotone` -- NF agreement monotone in depth
- `doets_lemma_1_1` -- the bridge theorem (depth-k NF agreement implies depth-k sentence agreement)

### 2.2 nf_characterizable_by_stavi

**File**: `EFGames/StaviCompleteness.lean` (line 3060)

```lean
theorem nf_characterizable_by_stavi
    {sig : MonadicSignature} (atomMap : Formula -> sig.preds)
    (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p)
    (k : Nat) (nf : NormalForm sig k 1) :
    exists A : StaviFormula, forall (M : OrderedMonadicStructure sig) (t : M.carrier),
      stavi_temporal_truth M atomMap t A <->
      nf_eval_nf M k 1 (fun _ => t) nf
```

**Status**: The theorem statement is proven by induction on k.
- **Base case (k=0)**: Uses `nf_base_sf` -- **sorry-free**.
- **Inductive case (k+1)**: Uses `nf_2var_existence_characterizable` which internally calls `nf_2var_exist_sf_classical`, which uses `nf_exist_sf_guarded_backward`. This function calls `nf_2var_from_interval_data`.

**SORRY CHAIN**: `nf_characterizable_by_stavi` depends on:
1. `nf_exist_sf_guarded_backward` (line 2787) -- **sorry'd** because it needs `nf_2var_from_interval_data`
2. `nf_2var_from_interval_data` (line 2442-2508) -- **sorry-free itself** (delegates to `nf_fraisse_compression` + `nf_2var_existential_transfer`)
3. `nf_2var_existential_transfer` (lines 2190-2429) -- contains **2 sorries** at lines 2347 and 2429 (4-var existential transfer at depth j')

So: `nf_characterizable_by_stavi` is sorry-affected via the existential transfer chain. The sorry is in the "backward direction" of the 2-var NF bridge -- proving that a temporal formula witness implies the NF existence.

### 2.3 stavi_expressive_completeness (Theorem 9.3.1)

**File**: `EFGames/StaviCompleteness.lean` (line 3170)

```lean
noncomputable def stavi_expressive_completeness
    (sig : MonadicSignature) (atomMap : Formula -> sig.preds)
    (h_surj : ...) (psi : MonadicFormula sig 1) :
    { A : StaviFormula //
      forall (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t A <-> eval M (fun _ => t) psi }
```

**Status**: The proof structure is complete -- it builds a disjunction of characteristic formulas over all "good" NormalForms and uses `doets_lemma_1_1` + `nf_exists_unique`. BUT it depends on `nf_characterizable_by_stavi` which has the sorry chain above.

---

## 3. rank_type and TypeFormulas

### 3.1 TypeFormulas Infrastructure

**File**: `EFGames/TypeFormulas.lean` (1043 lines)

All definitions and major theorems are **sorry-free**:

| Definition/Theorem | Status |
|---|---|
| `extendedStructure` (M_r as OrderedMonadicStructure) | Sorry-free |
| `muSig`, `extendedStructureWithMu` | Sorry-free |
| `mu_holds`, `mu_holds_point`, `not_mu_holds_gap` | Sorry-free |
| `temporal_truth_mu` (standard Formula, mu-relativized) | Sorry-free |
| `stavi_temporal_truth_mu` (StaviFormula, mu-relativized) | Sorry-free |
| `rank_type` (X_t from GHR93 Def 8.8) | Sorry-free |
| `interval_types` (X_{(t,u)} from GHR93 Def 8.8) | Sorry-free |
| `rank_type_eq_iff` | Sorry-free |
| `mem_rank_type_iff` | Sorry-free |
| `neg_mem_rank_type_of_not` | Sorry-free |

### 3.2 Rank Embedding Infrastructure

All **sorry-free** (in `TypeFormulas.lean`):

| Theorem | Description |
|---|---|
| `r_definable_gap_mono` | Gap definability monotone in rank |
| `rank_embed_gap`, `rank_embed` | Order-preserving embedding r -> r' |
| `rank_embed_point`, `rank_embed_gap_eq` | Points/gaps preserve identity |
| `rank_embed_le`, `rank_embed_lt` | Order preservation (iff) |
| `rank_embed_injective`, `rank_embed_ne` | Injectivity |
| `rank_embed_mu_holds` | Preserves mu-status |
| `rank_embed_interp` | Preserves predicate values |
| `rank_embed_temporal_truth_mu` | Standard formula truth preserved |
| `rank_embed_stavi_truth_mu` | StaviFormula truth preserved (970-line proof!) |

### 3.3 rank_type Finiteness

There is **no explicit Fintype for `rank_type`** (the set `{A | stavi_depth A <= r /\ stavi_temporal_truth_mu ...}`). However, the finiteness is established implicitly:
- `rank_type M atomMap r t = rank_type M atomMap r u` can be decided by checking agreement on all StaviFormulas of bounded depth
- The number of distinct rank_types is bounded by `2^(nfCount ...)` via the NormalForm correspondence
- This finiteness is what drives the pigeonhole argument in `stavi_expressive_completeness`

---

## 4. Game Infrastructure

### 4.1 Custom Game Definitions

**File**: `EFGames/CustomGame.lean` (sorry-free)

| Definition | Description |
|---|---|
| `inClosedInterval` | Element in [x, y] |
| `ghr93_duplicator_wins` | Full game definition (Round 1 + Round 2 + winning condition) |
| `ghr93_winning_condition` | Order, gap/point, formula agreement |
| `game_tuple` | Construct n+3 element tuple from endpoints + selections + point |
| `ghr93_winning_condition_perm` | Permutation invariance |
| `ghr93_winning_condition_symm` | Symmetry |
| `ghr93_duplicator_wins_round_mono` | Round monotonicity (Lemma 10) |

### 4.2 Decomposition (Lemma 11)

**File**: `EFGames/Decomposition.lean` (sorry-free)

| Theorem | Status |
|---|---|
| `decomposition_agreement` (definition) | Sorry-free |
| `ghr93_game_implies_decomposition` | Sorry-free |
| `ghr93_decomposition_implies_game` | Sorry-free |

### 4.3 NFGameBridge

**File**: `EFGames/NFGameBridge.lean` (sorry-free)

Bridges between `decomposition_agreement` and `ghr93_duplicator_wins`. All sorry-free.

### 4.4 Composition

**File**: `EFGames/Composition.lean` (sorry-free)

Contains game composition infrastructure including `rank_embed_inClosedInterval`.

### 4.5 GapDetection

**File**: `EFGames/GapDetection.lean` (sorry-free)

Gap detection transfer infrastructure. Comment at line 1128 mentions a sorry'd "full game-theoretic proof" but the file itself has no actual sorry statements.

---

## 5. CaseAnalysis.lean State

### 5.1 Overall Structure (3498 lines)

The file implements Cases I, II, and III-IV for the inductive step of Theorem 6.

### 5.2 Sorry Sites

| Line | Location | Nature |
|---|---|---|
| 1668-1669 | `ghr93_case_II`, grid dispatch | 2 small ordering grid cases (sel(i) vs p_n) |
| 2026 | `ghr93_case_II`, Case B2 | b_resp vs x' equality direction |
| 2027 | `ghr93_case_II`, Case B2 | Remaining grid dispatch cases |
| 2107 | `ghr93_case_II`, Case B2 | Ordering grid dispatch |
| 3350 | `ghr93_cases_III_IV` | **MAJOR**: Entire Case III-IV winning condition assembly |

### 5.3 Case I: `ghr93_case_I` (lines 60-1170)

**Status**: Proof is **structurally complete** but the ordering grid at line 434 was noted as "deferred to a separate sorry" -- however, examining the actual code, the ordering is handled via `pivot_chain_order_rev` and similar lemmas. The 1170 lines are sorry-free in terms of actual `sorry` statements.

### 5.4 Case II: `ghr93_case_II` (lines 1196-2110)

**Status**: ~900 lines of proof with **5 small sorries** in grid dispatch cases. These are all in the ordering/equality case analysis between game_tuple positions -- mechanical index arithmetic, not conceptual gaps.

### 5.5 Cases III-IV: `ghr93_cases_III_IV` (lines 2190-3350)

**Status**: ~1160 lines of setup with a **single large sorry** at line 3350. This sorry covers the final winning condition assembly for the gap case (when a_n is a gap rather than a point). The setup (Steps 1-5c) is complete:
- Step 1-2: Derive sigma/tau from props
- Step 3: Gap construction and definability proof
- Step 4: Gap-detection transfer
- Step 5a: Formula agreement at gap position
- Step 5b: Response function construction
- Step 5c: All responses in [x, y]

The sorry is the point challenge + winning condition dispatch, which mirrors the Case II pattern (~200 lines of mechanical grid work).

### 5.6 `ghr93_inductive_step` (lines 3409-3498)

**Status**: **Sorry-free.** This is the top-level dispatcher that:
1. Sorts Spoiler's selections (WLOG monotone)
2. Obtains split points c, d via `obtain_split_point_props`
3. Dispatches to Case I or Cases II-IV

---

## 6. Theorem6.lean State

### 6.1 Sorry Sites

| Line | Location | Nature |
|---|---|---|
| 124 | `ghr93_forward_to_backward_core` (uniform) | IH construction for delta=2 |
| 325 | `ghr93_forward_to_backward_rank_varying` (rank-varying) | IH rank promotion (forward r -> backward r+4) |

### 6.2 Delta Values

- **Uniform version** (`ghr93_forward_to_backward_core`): Uses `delta = 2`, sorry'd IH
- **Rank-varying version** (`ghr93_forward_to_backward_rank_varying`): Uses `delta = 4`, sorry'd IH at line 325
- **Public API** (`ghr93_forward_to_backward`): Calls core with `delta = 0` conceptually, but the core uses `delta = 2`

### 6.3 `h_surj` Availability

`h_surj` (surjectivity of atomMap) is NOT a parameter of Theorem 6. It appears only in `StaviCompleteness.lean` where the NF-to-StaviFormula construction needs it. Theorem 6 works purely at the game level.

---

## 7. Complete Sorry Inventory

### 7.1 Critical Path for bx_completeness (WeakCanonical)

| File | Lines | Count | Blocker Type |
|---|---|---|---|
| `StaviCompleteness.lean` | 2347, 2429 | 2 | 4-var existential transfer in NF bridge |
| `StaviCompleteness.lean` | 2787 | 1 | `nf_exist_sf_guarded_backward` (depends on above) |
| `CaseAnalysis.lean` | 1668-1669, 2026-2027, 2107 | 5 | Grid dispatch (mechanical) |
| `CaseAnalysis.lean` | 3350 | 1 | Cases III-IV assembly (structural, mirrors Case II) |
| `Theorem6.lean` | 124 | 1 | IH construction (uniform, delta=2) |
| `Theorem6.lean` | 325 | 1 | IH rank promotion (rank-varying, delta=4) |
| **Subtotal** | | **11** | |

### 7.2 Non-Critical Path (WeakCanonical)

| File | Lines | Count | Nature |
|---|---|---|---|
| `TruthLemma.lean` | 431, 448, 483, 497, 540, 556 | 6 | Guard condition intermediate steps (documented non-critical) |
| `OrderedSum.lean` | 56 | 1 | Ordered sum construction |
| `IntegerModel/GoodStructures.lean` | 842 | 1 | Good structures for integer model |
| **Subtotal** | | **8** | |

### 7.3 Independent Subsystems (NOT blocking bx_completeness)

| File | Count | Nature |
|---|---|---|
| `BXCanonical/Frame.lean` | 1 | bx_le_refl under irreflexive semantics |
| `BXCanonical/Chronicle/ChronicleToCountermodel.lean` | 4 | succ_cofinal chain construction |
| `Bundle/SuccExistence.lean` | 3 | Successor existence |
| `Bundle/SuccRelation.lean` | 7 | Successor relation |
| `Bundle/UntilSinceCoherence.lean` | 2 | Until/Since coherence |
| `Algebraic/InteriorOperators.lean` | 1 | temp_k_dist |
| `Algebraic/LindenbaumQuotient.lean` | 2 | temp_k_dist |
| **Subtotal** | **20** | |

### 7.4 Grand Total

| Category | Sorry Count |
|---|---|
| Critical path (WeakCanonical Expressiveness + EFGames) | 11 |
| Non-critical path (WeakCanonical other) | 8 |
| Independent subsystems (BXCanonical, Bundle, Algebraic) | 20 |
| **Total** | **39** |

---

## 8. What Exists vs What's Missing for X_t

### 8.1 What EXISTS (complete infrastructure)

1. **StaviFormula type** with all connectives and depth function
2. **NormalForm type** with Fintype/DecidableEq instances and cardinality theorems
3. **rank_type definition** `{A | stavi_depth A <= r /\ stavi_temporal_truth_mu ...}`
4. **rank_type_eq_iff** -- equal rank_types imply formula agreement
5. **interval_types definition** -- types realized in open intervals
6. **ExtendedCarrier** (M_r) with full LinearOrder instance
7. **Mu-relativized truth** for both Formula and StaviFormula
8. **Rank embedding** (rank_embed) with all preservation theorems
9. **Game infrastructure** -- custom game, winning conditions, round mono, decomposition
10. **sf_conjList / sf_disjList** with correctness theorems
11. **nf_characterizable_by_stavi** (modulo sorry chain in backward direction)
12. **stavi_expressive_completeness** (Theorem 9.3.1, modulo sorry chain)
13. **doets_lemma_1_1** and **nf_exists_unique** (sorry-free)
14. **Decomposition agreement** (Lemma 11, both directions sorry-free)
15. **ghr93_inductive_step** (sorry-free dispatcher)
16. **Case I** (sorry-free, 1170 lines)
17. **Case II** (95% done, 5 mechanical sorries)
18. **Cases III-IV** setup (1160 lines, 1 assembly sorry)

### 8.2 What's MISSING (sorry blockers)

**Tier 1: Mechanical grid work (5 sorries in Case II, 1 in Cases III-IV)**
- These are ordering/equality/gap-point dispatches between game_tuple positions
- Pattern: match on `i.val` ranges, apply existing lemmas
- Estimated effort: 200-400 lines each, no conceptual difficulty

**Tier 2: Cases III-IV winning condition assembly (1 sorry, line 3350)**
- Mirror of Case II's structure but with gap at position n+1 instead of point e_n
- All prerequisites are in place (Steps 1-5c complete)
- Estimated effort: ~200 lines of grid dispatch

**Tier 3: Theorem 6 IH construction (2 sorries)**
- Line 124 (uniform): IH at delta=2, needs strategy restriction to sub-intervals
- Line 325 (rank-varying): IH rank promotion from r to r+4, needs ambient high-rank game restriction
- These are the most conceptually challenging remaining sorries

**Tier 4: NF bridge backward direction (3 sorries in StaviCompleteness.lean)**
- Lines 2347, 2429: 4-variable existential transfer at depth j'
- Line 2787: `nf_exist_sf_guarded_backward` (blocked by above)
- These require establishing that zone-matched 3-variable configurations transfer existential witnesses at the next depth level

### 8.3 Dependency Chain for Full Sorry Closure

```
stavi_expressive_completeness (Theorem 9.3.1)
  |-- nf_characterizable_by_stavi
  |     |-- nf_2var_existence_characterizable
  |           |-- nf_exist_sf_guarded_backward (sorry: line 2787)
  |                 |-- nf_2var_from_interval_data (sorry-free)
  |                       |-- nf_2var_existential_transfer (sorries: 2347, 2429)
  |
  |-- [The above feeds char_k into:]
  |
  ghr93_forward_to_backward (Theorem 6)
    |-- ghr93_inductive_step (sorry-free)
    |     |-- Case I (sorry-free)
    |     |-- Case II (5 mechanical sorries)
    |     |-- Cases III-IV (1 assembly sorry)
    |
    |-- IH construction (2 sorries: lines 124, 325)
```

### 8.4 Key Observation

The X_t (characteristic formula) infrastructure is **substantially complete**. The `rank_type` definition, `nf_characterizable_by_stavi`, and `stavi_expressive_completeness` form the full X_t pipeline. The remaining sorries are:
- **6 mechanical** (grid dispatch in Case II + Cases III-IV assembly)
- **2 architectural** (Theorem 6 IH construction)
- **3 bridge** (NF existential transfer at higher variable count)
