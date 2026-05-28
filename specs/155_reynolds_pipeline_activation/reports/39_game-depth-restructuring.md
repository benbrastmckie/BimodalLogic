# Game Depth Restructuring: Aligning with GHR93's Rank Infrastructure

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-27
**Focus**: Fix the fundamental rank mismatch between GHR93 and the Lean formalization

---

## 1. Current `game_depth` Definition

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Defs.lean:88`

```lean
noncomputable def game_depth (sig : MonadicSignature) : Nat → Nat
  | 0 => 0
  | n + 1 =>
    let prev := game_depth sig n
    let k_n := Fintype.card (NormalForm sig prev 1)
    (1 + 3 * prev) * (2 * k_n) + 2
```

**Call sites**: ONLY within `Defs.lean` itself (lines 88-206). No other file references `game_depth`. The definition is used to define `stavi_n_equiv` (line 180):

```lean
def stavi_n_equiv ... (n : Nat) ... :=
  ∀ (A : StaviFormula), stavi_depth A ≤ game_depth sig n → ...
```

**Impact assessment**: `game_depth` is a pure definition used only for the semantic n-equivalence relation. It does NOT appear in the game theorem signatures. **No changes to `game_depth` are needed.**

---

## 2. The Real Problem: Rank Flattening in `ghr93_forward_to_backward`

### GHR93's Rank Structure (from reports/08_ghr93-game-theory.md)

```
Theorem 6 (*)_n: forward G_{1+3n; r+4n}(M, xy; N, x'y')
                 → backward G_{n; r}(N, x'y'; M, xy)
```

**Inductive step**: proving `(*)_{n+1}` from `(*)_n`:
- Given: forward `G_{4+3n; r+4(n+1)}(M, xy; N, x'y')`
- Claim 2: sub-interval forward games `G_{1+3n; r+4(n+1)}(M, xc; N, x'd)`, etc.
- Apply `(*)_n` at rank `r+4`: backward `G_{n; r+4}(N, x'd; M, xc)`
  - Here `r+4(n+1) = (r+4) + 4n`, so `(*)_n` at base rank `r+4` applies
- **sigma and tau are at rank r+4**

Case II uses:
- B = X_{a_n} — full rank-r type formula, stavi_depth ≈ r
- phi = U(B, sf_top) — depth r+1
- Transfer via tau at rank **r+4**: depth r+1 ≤ r+4 ✓
- Witness has full rank-r agreement with a_n

### Lean Code's Current Rank Structure

**`ghr93_forward_to_backward` (Theorem6.lean:188)**:
- Takes forward at rank `r`: `ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y'`
- Produces backward at rank `r`: `ghr93_duplicator_wins N M atomMap n r x' y' x y`
- All games at the SAME rank `r`

**`ghr93_forward_to_backward_rank_varying` (Theorem6.lean:247)**:
- Takes forward at rank `r+4n`
- Produces backward at rank `r`
- **But internally**: at line 360-365, it transports the forward game DOWN from `r+4(n+1)` to rank `r` via `ghr93_duplicator_wins_rank_down`, THEN calls `ghr93_forward_to_backward` at rank `r`

**This is the bug**: The rank-varying theorem flattens to rank `r` too early. GHR93 flattens 4 at a time (one induction step removes +4 from the rank), but the Lean code removes ALL of +4(n+1) at once.

### How sigma/tau Get Their Ranks

Inside `ghr93_forward_to_backward_core` (Theorem6.lean:31):
- The `ih` (inductive hypothesis) is used at rank `r` (line 152-159)
- sigma/tau are constructed by `ghr93_inductive_step` at rank `r`

Inside `SplitPoint.lean`, `obtain_split_point_props`:
- Receives `ih` at rank `r` (line 149-154)
- Constructs sigma at rank `r` (line 89): `ghr93_duplicator_wins N M atomMap n r x' d x c`
- Constructs tau at rank `r` (line 92): `ghr93_duplicator_wins N M atomMap n r d y' c y`

The r+2 variants exist as patches:
- `h_fwd_r1` at rank `r+2` (line 156)
- `h_ih_r2` at rank `r+2` in CaseAnalysis.lean (line 1209-1214)
- `tau_r2` at rank `r+2` in CaseAnalysis.lean:1467

---

## 3. The Fix: Raise sigma/tau to rank `r+4`

### What GHR93 Actually Does

The induction removes 4 from the rank at each step:
- Forward at rank `r+4(n+1)` → forward at rank `(r+4)+4n` on sub-intervals → backward at rank `r+4` via `(*)_n`
- So sigma/tau are at rank `r+4`, and the final assembly produces backward at rank `r`

### Proposed Change

**Change SplitPointProps** to have sigma/tau at rank `r+4` (not `r`):

```lean
structure SplitPointProps ... (r : Nat) ... where
  sigma : ghr93_duplicator_wins N M atomMap n (r+4) x' d x c  -- was: r
  tau : ghr93_duplicator_wins N M atomMap n (r+4) d y' c y    -- was: r
```

Wait — this won't work directly because x', d, x, c are `ExtendedCarrier ... atomMap r`, and the game needs `ExtendedCarrier ... atomMap (r+4)`. The positions would need to be embedded.

### The Real Architecture

Looking more carefully, the positions live at rank `r` but the games play at rank `r+4`. In the Lean code, `ghr93_duplicator_wins M N atomMap n r' x y x' y'` requires `x y : ExtendedCarrier M atomMap r'`. So to have tau at rank `r+4`, we need positions at rank `r+4`.

GHR93's construction works because the sub-intervals [d, y'] and [c, y] are in the rank-r carrier, which embeds into the rank-(r+4) carrier via `rank_embed`.

So the fix is:
1. Keep positions at rank `r`
2. Embed them to rank `r+4` for sigma/tau
3. sigma/tau play at rank `r+4` on embedded positions
4. When sigma/tau respond, the response is at rank `r+4` — project back to rank `r`

This is exactly what `ghr93_forward_to_backward_rank_varying` does at the theorem level. The fix is to NOT flatten inside `ghr93_forward_to_backward_core`, but instead keep the rank offset through the induction.

---

## 4. Detailed Change Plan

### Option A: Restructure ghr93_forward_to_backward_core (RECOMMENDED)

Currently the induction in `ghr93_forward_to_backward_core` works at a uniform rank `r`. Change it to carry a rank offset `delta` that decreases by 4 at each step:

```lean
private theorem ghr93_forward_to_backward_core ...
    (n : Nat) (r delta : Nat)
    -- sigma/tau live at rank r+delta (not r)
    -- ih produces backward games at rank r+delta
    -- The inductive step peels off 4 from delta
    ...
```

At the top level (`ghr93_forward_to_backward_rank_varying`), call with `delta = 4*n`.
At each induction step: `delta → delta - 4`. After n steps: `delta = 0`, backward game at rank `r`.

### Key Signature Changes

**1. SplitPointProps (SplitPoint.lean)**:
```lean
-- Current:
sigma : ghr93_duplicator_wins N M atomMap n r x' d x c
tau : ghr93_duplicator_wins N M atomMap n r d y' c y

-- New: add delta parameter, sigma/tau at rank r+delta
-- Positions are rank-embedded from r to r+delta
```

**2. obtain_split_point_props (SplitPoint.lean)**:
- ih needs to produce backward games at rank `r+4` (not `r`)
- Forward game input at rank `r+4(n+1)` gets restricted to sub-intervals at rank `r+4(n+1)`
- Apply `(*)_n` at base rank `r+4`: sub-interval forward at rank `(r+4)+4n = r+4(n+1)` → backward at rank `r+4`

**3. ghr93_case_II (CaseAnalysis.lean)**:
- tau is now at rank `r+4` → can transfer formulas of depth ≤ r+4
- B = X_{a_n} at depth r, U(B, sf_top) at depth r+1 ≤ r+4 ✓
- No need for char_k workaround
- No need for tau_r2, h_ih_r2

**4. ghr93_forward_to_backward_core (Theorem6.lean)**:
- Restructure the induction to peel off 4 from the rank at each step

### What Becomes Unnecessary

With sigma/tau at rank `r+4`:
- **char_k, char_k_correct, char_k_depth**: Can use full rank-r type formula instead
- **tau_r2**: tau already at r+4 > r+2
- **h_ih_r2**: IH already at r+4 > r+2
- **h_r1_univ** in its current form: may still be needed for Cases III/IV at rank (r+4)+2

---

## 5. Files and Estimated Impact

| File | Changes | Estimated Lines |
|------|---------|----------------|
| `EFGames/Defs.lean` | **None** — game_depth not affected | 0 |
| `EFGames/CustomGame.lean` | **None** — game definition unchanged | 0 |
| `EFGames/Composition.lean` | **None** — composition at same rank | 0 |
| `EFGames/Decomposition.lean` | **None** — decomposition at same rank | 0 |
| `Expressiveness/SplitPoint.lean` | Restructure SplitPointProps, obtain_split_point_props | ~200-400 |
| `Expressiveness/Theorem6.lean` | Restructure induction to carry rank offset | ~150-300 |
| `Expressiveness/CaseAnalysis.lean` | Case II: use full rank-r type formula via tau at r+4 | ~300-500 |
| `Expressiveness/DConsistencyTransport.lean` | May need rank adjustments | ~50-100 |
| `EFGames/GapDetection.lean` | May need rank adjustments for Cases III/IV | ~50-100 |

**Total estimated**: 750-1400 lines of changes

### Dependency Order

1. `SplitPoint.lean` — define the new SplitPointProps with rank offset
2. `Theorem6.lean` — restructure induction
3. `CaseAnalysis.lean` — update ghr93_case_II and ghr93_inductive_step
4. `DConsistencyTransport.lean` — update if rank parameters changed
5. `GapDetection.lean` — update if gap detection needs higher rank

---

## 6. Alternative: Minimal Rank Bump (r → r+4 for sigma/tau only)

Instead of a full restructuring, a simpler approach:

**Keep the current architecture** but add a `delta` parameter to SplitPointProps:

```lean
structure SplitPointProps {sig} {M N} {atomMap} {r} (n : Nat) (delta : Nat := 0)
    (x y : ExtendedCarrier M atomMap r)
    (x' y' : ExtendedCarrier N atomMap r)
    (c : ExtendedCarrier M atomMap r)
    (d : ExtendedCarrier N atomMap r)
    (a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r) where
  ...
  sigma : ghr93_duplicator_wins N M atomMap n (r + delta)
    (rank_embed ... x') (rank_embed ... d) (rank_embed ... x) (rank_embed ... c)
  tau : ghr93_duplicator_wins N M atomMap n (r + delta)
    (rank_embed ... d) (rank_embed ... y') (rank_embed ... c) (rank_embed ... y)
```

Then:
- `obtain_split_point_props` constructs with `delta = 4` (from the IH at rank `r+4`)
- `ghr93_case_II` receives tau at rank `r+4`, can transfer rank-(r+1) formulas
- No need for tau_r2 or char_k workaround

**Pros**: Smaller change, localized to SplitPoint + CaseAnalysis
**Cons**: Doesn't fully match GHR93's recursive rank peeling; the IH construction is less clean

---

## 7. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| rank_embed cascading through all position arguments | High | Use rank_embed consistently; may need helper lemmas |
| Cases III/IV need (r+4)+2 = r+6 games | Medium | h_r1_univ already provides arbitrary r'+2 games |
| obtain_split_point_props reconstruction is complex | Medium | Current proof is ~1000 lines; much can be preserved |
| game_tuple at different ranks needs conversion | Medium | rank_embed_game_tuple lemma needed |
| Winning condition at rank r+4 vs rank r | Medium | Use ghr93_duplicator_wins_rank_down for final assembly |

### Critical Insight

The current code already has most of the infrastructure:
- `rank_embed` for embedding positions to higher ranks
- `ghr93_duplicator_wins_rank_down` for projecting games to lower ranks
- `ghr93_forward_to_backward_rank_varying` for the full rank-varying theorem
- `h_r1_univ` for games at arbitrary ranks

The main work is plumbing these through SplitPointProps and CaseAnalysis.

---

## 8. Conclusion

**`game_depth` does NOT need to change.** The problem is not with the depth function but with how the induction flattens ranks too early.

**The fix is architectural**: carry the rank offset through the induction so that sigma/tau end up at rank `r+4` (matching GHR93). This enables the full rank-r type formula transfer in Case II, eliminating the depth-agreement gap.

**Recommended approach**: Option A (full restructure of `ghr93_forward_to_backward_core`) for mathematical correctness, or the minimal delta-parameter approach (Section 6) for lower risk.

**What becomes unnecessary with this fix**:
- `char_k`, `char_k_correct`, `char_k_depth` parameters (use full rank-r type instead)
- `tau_r2` construction (tau already at r+4)
- `h_ih_r2` parameter (IH already at r+4)
- `resp_mod` equality case handling (with full rank-r agreement, same_side may become provable)
- All the same_side workarounds accumulated over 10+ orchestration cycles
