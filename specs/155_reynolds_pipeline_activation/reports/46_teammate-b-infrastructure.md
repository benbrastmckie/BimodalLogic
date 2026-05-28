# Teammate B: Lean Infrastructure Audit for Until Witness Containment

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Audit existing Lean infrastructure for the three resolution paths in report 45 Section 8.1

---

## 1. CharacteristicFormula.lean -- Full Audit

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean`
**Lines**: 632 total, zero sorries, zero `sorry`-adjacent definitions.
**Imports**: `TypeFormulas`, `StaviCompleteness`

### 1.1 untl_extract_witness (lines 610-619)

```lean
theorem untl_extract_witness {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t : ExtendedCarrier M atomMap r}
    {B A : StaviFormula}
    (h : stavi_temporal_truth_mu M atomMap r t (sf_untl B A)) :
    ∃ z : ExtendedCarrier M atomMap r, t < z ∧ mu_holds z ∧
      stavi_temporal_truth_mu M atomMap r z B ∧
      ∀ w : ExtendedCarrier M atomMap r, t < w → w < z → mu_holds w →
        stavi_temporal_truth_mu M atomMap r w A :=
  (sf_untl_truth_mu B A).mp h
```

**Key finding**: The witness `z` is existentially quantified over **all** of `ExtendedCarrier M atomMap r`. There is NO interval bound on `z`. The only constraint is `t < z` (strict). This is a direct wrapper around `sf_untl_truth_mu`, which is itself a direct expansion of the `stavi_temporal_truth_mu` definition for `.base (.untl _ _)`.

**Implication for containment**: If `t` is in `[c, y]`, the witness `z` can be ANYWHERE in `ExtendedCarrier M atomMap r` above `t`. There is no guarantee that `z <= y`.

### 1.2 sf_untl and its semantics (lines 532-564)

```lean
def sf_untl (B A : StaviFormula) : StaviFormula :=
  .std_untl B A

theorem sf_untl_depth (B A : StaviFormula) :
    stavi_depth (sf_untl B A) = max (stavi_depth B) (stavi_depth A) + 2

theorem sf_untl_truth_mu ... (B A : StaviFormula) :
    stavi_temporal_truth_mu M atomMap r t (sf_untl B A) ↔
    ∃ s : ExtendedCarrier M atomMap r, t < s ∧ mu_holds s ∧
      stavi_temporal_truth_mu M atomMap r s B ∧
      ∀ w : ExtendedCarrier M atomMap r, t < w → w < s → mu_holds w →
        stavi_temporal_truth_mu M atomMap r w A
```

The Until semantics quantifies over the FULL extended carrier. There is no interval-restricted variant of Until evaluation anywhere in the codebase. The search for `interval_restrict`, `restricted_truth`, `bounded_until`, `truth_in_interval` returned zero results.

### 1.3 stavi_temporal_truth_mu (TypeFormulas.lean, lines 304-328)

```lean
noncomputable def stavi_temporal_truth_mu ... :
    ExtendedCarrier M atomMap r → StaviFormula → Prop
  | .base φ => temporal_truth_mu M atomMap r t φ
  | .stavi_untl A B => ∃ s, t < s ∧ (body) ∧ (fail) ∧ (init)
  | .stavi_snce A B => ...
  | .neg A => ¬ stavi_temporal_truth_mu M atomMap r t A
  | .conj A B => ...
  | .std_untl A B => ∃ s, t < s ∧ mu_holds s ∧ ...  -- FULL carrier
  | .std_snce A B => ∃ s, s < t ∧ mu_holds s ∧ ...  -- FULL carrier
```

The `temporal_truth_mu` (lines 274-292) for standard Until:
```lean
  | .untl φ ψ =>
    ∃ s : ExtendedCarrier M atomMap r, t < s ∧ mu_holds s ∧
      temporal_truth_mu M atomMap r s φ ∧
      ∀ u : ExtendedCarrier M atomMap r, t < u → u < s → mu_holds u →
        temporal_truth_mu M atomMap r u ψ
```

**Conclusion**: ALL temporal connectives in the mu-relativized semantics quantify over the full `ExtendedCarrier`. There is NO interval restriction. This is by design -- the semantics of Until/Since in GHR93 are global. The game mechanism confines attention to intervals, but the formula semantics are inherently global.

### 1.4 x_interval_formula (lines 497-527)

```lean
noncomputable def x_interval_formula ... (t u : ExtendedCarrier M atomMap r) : StaviFormula

theorem x_interval_correct (w : ExtendedCarrier M atomMap r) :
    stavi_temporal_truth_mu M atomMap r w (x_interval_formula M atomMap r t u) ↔
    ∃ v : ExtendedCarrier M atomMap r,
      mu_holds v ∧ t < v ∧ v < u ∧
      rank_type M atomMap r w = rank_type M atomMap r v
```

**Key**: `x_interval_correct` says `A(w)` holds iff `w` has the same rank type as some mu-point `v` in the open interval `(t, u)`. The formula ITSELF has depth <= r (from `x_interval_depth`). But this formula does NOT restrict where `w` is evaluated -- it only defines which types are "interval types". A point outside `[t, u]` can also satisfy `x_interval_formula` if it has a matching rank type.

### 1.5 x_t_formula (lines 371-408)

```lean
noncomputable def x_t_formula ... (t : ExtendedCarrier M atomMap r) : StaviFormula

theorem x_t_correct (u : ExtendedCarrier M atomMap r) :
    stavi_temporal_truth_mu M atomMap r u (x_t_formula M atomMap r t) ↔
    rank_type M atomMap r u = rank_type M atomMap r t

theorem x_t_depth :
    stavi_depth (x_t_formula M atomMap r t) ≤ r
```

**x_t_self**: `stavi_temporal_truth_mu M atomMap r t (x_t_formula M atomMap r t)` (line 393-397) -- trivially true by `x_t_correct t |>.mpr rfl`.

**x_t_implies_agreement** (lines 401-408): If `X_t(u)` holds, then `u` and `t` agree on all depth-le-r StaviFormulas. This is the key bridge from B(z) to formula agreement between e_n and a_n.

### 1.6 untl_type_holds_at_witness (lines 581-589)

```lean
theorem untl_type_holds_at_witness ...
    (hmu_t : mu_holds t) (hst : s < t) :
    stavi_temporal_truth_mu M atomMap r s
      (sf_untl (x_t_formula M atomMap r t) (x_interval_formula M atomMap r s t))
```

**Requires**: `mu_holds t` (t is a point) and `s < t` (strict). This is exactly what Case II needs: `mu_holds (a_bwd n)` from `h_point` (a_n is a point), and `ref_N < a_bwd n` (strict inequality from the reference point below a_n).

### 1.7 Depth budget infrastructure (lines 592-607)

```lean
theorem untl_type_depth : stavi_depth (sf_untl (x_t_formula ...) (x_interval_formula ...)) ≤ r + 2
theorem untl_type_depth_le_r_plus_4 : ... ≤ r + 4
```

Since `delta >= 2` (from `hd : 2 <= delta`), tau at rank `r + delta` has formula agreement at depth `<= r + delta >= r + 2`. So U(B,A) at depth r+2 is within tau's formula budget.

### 1.8 formula_transfer_rank_embed (lines 624-630)

```lean
theorem formula_transfer_rank_embed {r r' : Nat} (h : r ≤ r')
    (t : ExtendedCarrier M atomMap r) (A : StaviFormula) :
    stavi_temporal_truth_mu M atomMap r' (rank_embed h t) A ↔
    stavi_temporal_truth_mu M atomMap r t A
```

This is a thin wrapper around `rank_embed_stavi_truth_mu`. It transfers formula truth between ranks for rank-embedded positions.

---

## 2. CaseAnalysis.lean -- ghr93_case_II Audit

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`
**Total lines**: 3625
**ghr93_case_II**: Lines 1196-2302 (~1107 lines)

### 2.1 Function Signature (lines 1196-1232)

```lean
private theorem ghr93_case_II {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r delta : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    {a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r}
    (props : SplitPointProps n delta x y x' y' c d a_bwd)
    (hd : 2 ≤ delta)
    (ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i))
    (h_no_split : ∀ i : Fin (n + 1), d ≤ a_bwd i)
    (h_point : IsPoint (a_bwd ⟨n, by omega⟩))
    (ih : ...)
    (h_r1_univ : ...)
    (h_mono : Monotone a_bwd) :
    ∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a'_resp i)) ∧ ...
```

### 2.2 inClosedInterval (CustomGame.lean, line 39-42)

```lean
def inClosedInterval ... (x y e : ExtendedCarrier M atomMap r) : Prop :=
  x ≤ e ∧ e ≤ y
```

Simple conjunction of `x ≤ e` and `e ≤ y`.

### 2.3 SplitPointProps (SplitPoint.lean, lines 43-121)

Key fields relevant to the rewrite:

| Field | Type | Line |
|-------|------|------|
| `hc_interval` | `inClosedInterval x y c` | 52 |
| `hd_interval` | `inClosedInterval x' y' d` | 54 |
| `hd_le_an` | `d ≤ a_bwd ⟨n, by omega⟩` | 59 |
| `hxc` | `x ≤ c` | 61 |
| `hcy` | `c ≤ y` | 63 |
| `hx'd` | `x' ≤ d` | 65 |
| `hdy'` | `d ≤ y'` | 67 |
| `h_pt_cy` | `(∃ p, inClosedInterval c y (extendPoint p)) ∨ (c = y ∧ d = y' ∧ IsGap c ∧ IsGap d)` | 76-77 |
| `hcd_form` | formula agreement c <-> d at depth ≤ r | 80-82 |
| `hcd_gp` | gap/point correspondence c <-> d | 85 |
| `sigma` | `ghr93_duplicator_wins N M n (r+delta) (re x') (re d) (re x) (re c)` | 89-93 |
| `tau` | `ghr93_duplicator_wins N M n (r+delta) (re d) (re y') (re c) (re y)` | 97-101 |
| `h_fwd_n1` | `ghr93_duplicator_wins M N (n+1) r x y x' y'` | 105 |
| `h_d_compat_left` | d-compatible (1+3n+1)-round forward game | 110-120 |

### 2.4 Current e_n Construction (lines 1257-1288)

The current approach builds `e_n` via the forward game `props.h_d_compat_left`:

1. Build `a_pad_big : Fin (1 + 3*n + 1) -> ExtendedCarrier M atomMap r` (lines 1269-1272)
2. Play `props.h_d_compat_left a_pad_big ha_pad_big hpad_last` to get `a'_big` with `a'_big(last) = d` (lines 1282-1283)
3. Challenge with `p_n` to get `e_n_pt` (line 1285)
4. Set `e_n := extendPoint e_n_pt` (line 1286)

**e_n is in [x, y]** because `he_n_pt_in` comes from the forward game's Round 2 response: `inClosedInterval x y (extendPoint e_n_pt)` (line 1287). The forward game `h_d_compat_left` maps from `[x', y']` to `[x, y]`, so any Round 2 response point is automatically in `[x, y]`.

### 2.5 tau_left / tau_right (lines 1358-1378)

Currently, the code constructs two sub-interval backward games via IH:
- `tau_left : ghr93_duplicator_wins N M n r d (extendPoint p_n) c e_n` (line 1368)
- `tau_right : ghr93_duplicator_wins N M n r (extendPoint p_n) y' e_n y` (line 1374)

These are built from `h_r1_univ` (which gives a (4+3n)-round forward game at rank r+2) via `ghr93_duplicator_wins_rank_down` and `ghr93_duplicator_wins_round_mono`, then applying `ih` (the inductive hypothesis).

**This requires** `hc_le_en : c ≤ e_n` (line 1361), `h_en_le_y : e_n ≤ y` (line 1365), and `hd_le_pn : d ≤ extendPoint p_n` (line 1359). All are established from the forward game output.

### 2.6 The resp_mod Elimination (lines 1415-1424)

The current code (post-task-5.5 simplification) no longer uses `resp_mod`. Instead it directly uses `resp_left`:
```lean
let a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_left ⟨i.val, h⟩ else e_n
```

The `tau_left` game's `hord_left_sel_pn` provides the key ordering between `a_init(k)` / `extendPoint p_n` and `resp_left(k)` / `e_n`.

---

## 3. Semantics -- Until Definition

### 3.1 Where Until is Defined

- **Temporal formula syntax**: `Formula.untl` (in `Theories/Bimodal/Syntax/`)
- **StaviFormula syntax**: `StaviFormula.std_untl` (standard Until) and `StaviFormula.stavi_untl` (Stavi Until)
- **Mu-relativized semantics**: `temporal_truth_mu` for `Formula.untl`, `stavi_temporal_truth_mu` for both `StaviFormula.std_untl` and `.stavi_untl`

### 3.2 Is There Interval-Restricted Evaluation?

**No.** Exhaustive search confirms:
- No `interval_restrict` or `restricted_truth` or `bounded_until` or `truth_in_interval` definitions exist
- `stavi_temporal_truth_mu` always quantifies over the full `ExtendedCarrier`
- The game mechanism (`ghr93_duplicator_wins`) confines Spoiler's SELECTIONS to intervals, but the FORMULA SEMANTICS are global
- `untl_extract_witness` returns a witness from the full carrier with no upper bound

### 3.3 mu_holds and IsPoint (TypeFormulas.lean, lines 231-236)

```lean
def mu_holds (e : ExtendedCarrier M atomMap r) : Prop := IsPoint e
```

`mu_holds e` iff `e` is a carrier point (not a gap). `mu_holds_point` gives `mu_holds (extendPoint x)` for any `x : M.carrier`.

---

## 4. EF Games Infrastructure

### 4.1 ExtendedCarrier (Defs.lean, lines 335-337)

```lean
def ExtendedCarrier (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (r : Nat) : Type :=
  M.carrier ⊕ RDefinableGap M atomMap r
```

`ExtendedCarrier M atomMap r` = original points of M PLUS all r-definable gaps. The linear order interleaves gaps among points.

### 4.2 Game Tuple Structure (CustomGame.lean, lines 106-270)

```lean
noncomputable def game_tuple ... (x y : ...) (a : Fin n → ...) (b : M.carrier) :
    Fin (n + 3) → ExtendedCarrier M atomMap r
```

The game tuple has n+3 positions: `x` at 0, `a(0)..a(n-1)` at 1..n, `b` at n+1, `y` at n+2.

### 4.3 ghr93_duplicator_wins (CustomGame.lean, lines 285-303)

Games are played on intervals: Spoiler picks from `[x, y]`, Duplicator responds in `[x', y']`. The winning condition checks order type, gap/point status, and formula agreement AT ALL positions (including `x`, `y`, `b`).

**Key**: Games are NOT sub-interval restricted in their SEMANTICS -- they only restrict Spoiler's selections and Duplicator's responses to intervals. The formula agreement condition checks formulas at full-carrier semantics.

### 4.4 rank_down (DConsistencyTransport.lean, lines 258-267)

```lean
theorem ghr93_duplicator_wins_rank_down ... (hle : r ≤ r') (h2 : r + 2 ≤ r')
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h : ghr93_duplicator_wins M N m r' (rank_embed hle x) ... (rank_embed hle y')) :
    ghr93_duplicator_wins M N m r x y x' y'
```

Requires `r + 2 ≤ r'` because gap detection formulas have depth `stavi_depth(D) + 2`. Projects a rank-r' game to rank r but LOSES formula agreement beyond depth r.

### 4.5 Composition (Composition.lean)

`ghr93_strategy_compose` (line 40) composes two strategies across a pivot point. Used in Case I. The current Case II uses `tau_left` + `tau_right` with pivot at `p_n`/`e_n`, but the GHR93-faithful rewrite would NOT use composition.

---

## 5. Resolution Path Assessment

The three resolution paths from report 45 Section 8.1 are:

### 5.1 Resolution Path 1: Forward Game for Existence, U(B,A) for Properties

**What it says**: Use `h_fwd_n1` or `h_d_compat_left` to establish that a type-matching point exists in `[c, y]`, then separately show it satisfies U(B,A) properties.

**Infrastructure that EXISTS**:

| Component | Status | Location |
|-----------|--------|----------|
| `h_d_compat_left` | EXISTS in SplitPointProps | SplitPoint.lean line 110 |
| `h_fwd_n1` | EXISTS in SplitPointProps | SplitPoint.lean line 105 |
| Forward game gives `e_n_pt` in `[x, y]` | EXISTS (current code) | CaseAnalysis.lean line 1285-1287 |
| `hform_en_an` from forward game | EXISTS (current code) | CaseAnalysis.lean line 1290-1296 |
| `untl_type_holds_at_witness` | EXISTS | CharacteristicFormula.lean line 581 |
| `untl_extract_witness` | EXISTS | CharacteristicFormula.lean line 610 |
| `sf_untl_truth_mu` | EXISTS | CharacteristicFormula.lean line 556 |
| `x_t_correct` | EXISTS | CharacteristicFormula.lean line 384 |
| `x_interval_correct` | EXISTS | CharacteristicFormula.lean line 510 |
| `formula_transfer_rank_embed` | EXISTS | CharacteristicFormula.lean line 624 |
| Import of CharacteristicFormula | MISSING | Must add to CaseAnalysis.lean |

**What would need to be BUILT**:

1. **Bridge lemma**: Given `e_n` from the forward game AND U(B,A)(ref_M) from tau transfer, show that `e_n` satisfies the U(B,A) interval type condition. This requires:
   - `hform_en_an` already gives formula agreement between `e_n` and `a_n` at depth <= r
   - From `x_t_correct`: `B(e_n) <-> rank_type(e_n) = rank_type(a_n)` (which `hform_en_an` implies)
   - The Until witness from `untl_extract_witness` applied to `h_untl_M` gives SOME `z` above `ref_M`
   - Need to show `z = e_n` or that `e_n` can serve as the witness (it may not be the SAME `z`)
   - **Problem**: The forward game's `e_n` is not necessarily the same point as the Until witness `z`. They both have type matching `a_n`, but they may be different points at different positions.

2. **Interval type data for Round 2**: Need to extract A-type data from the Until witness interval `(ref_M, z)` and transfer it to the interval `(resp_tau(k), e_n)` for the Round 2 B-interval case. This is where the GHR93 proof gets its key leverage.

**Estimated lines**: ~80-120 new lines for the bridge + ~20 for import. The main challenge is establishing that e_n (from forward game) has the same interval-type properties as z (from Until).

**Risk**: MEDIUM. The forward-game e_n and the Until witness z may produce different interval type data. The bridge requires showing that formula agreement at e_n (from the forward game) plus the Until interval property (from tau transfer) together give the Round 2 orderings.

### 5.2 Resolution Path 2: Prove Until Witness is in [c, y] Structurally

**What it says**: Prove that the Until witness z from `untl_extract_witness` must be in `[c, y]` by structural argument.

**Infrastructure that EXISTS**:

| Component | Status | Location |
|-----------|--------|----------|
| `untl_extract_witness` | EXISTS | CharacteristicFormula.lean line 610 |
| `mu_holds z` (z is a point) | EXISTS (from Until witness) | Automatic |
| `rank_embed_stavi_truth_mu` | EXISTS | TypeFormulas.lean line 531 |
| `rank_embed_le`, `rank_embed_lt` | EXISTS | TypeFormulas.lean lines 95, 123 |

**What would need to be BUILT**:

1. **Interval-restricted Until lemma**: Something like:
   ```lean
   theorem untl_witness_in_interval {x y t : ExtendedCarrier M atomMap r}
       (h_untl : stavi_temporal_truth_mu M atomMap r t (sf_untl B A))
       (h_t_in : inClosedInterval x y t)
       (h_restrict : <some restriction on B, A, or the structure>) :
       ∃ z, t < z ∧ z ≤ y ∧ mu_holds z ∧ ...
   ```
   This does NOT exist. The Until semantics are inherently global. To bound the witness, we would need to show that the FIRST mu-point above `ref_M` satisfying B must be in `[c, y]`.

2. **"First witness" infrastructure**: The Until formula gives an EXISTENTIAL witness. Lean's `Classical.choose` could select a witness, but there's no Lean infrastructure for finding the FIRST or CLOSEST witness. In a linear order, we would need:
   - Well-ordering or minimality on `ExtendedCarrier`
   - Or: a proof that if B holds at ANY z > ref_M, then B holds at some z' with ref_M < z' <= y
   - The extended carrier has Fintype for the gap part but NOT for the carrier points. So well-ordering arguments on the full ExtendedCarrier are non-trivial.

3. **Type transfer argument**: The claim would be: "tau maps the type content of [d, y'] to [c, y], so any type realized in [c, y] by the Until formula must have its witness in [c, y]." This is mathematically correct (GHR93 uses this implicitly) but formalizing it requires:
   - Showing that `x_t_formula` truth is determined by types
   - Showing that types in [c, y] are exactly the types in [d, y'] (via tau)
   - Showing that if U(B,A)(ref_M) holds with B = X_{a_n}, then since a_n's type appears in [d, y'], the corresponding type must appear in [c, y] via tau

**Estimated lines**: ~150-250 new lines. This is the most mathematically clean approach but requires the most new infrastructure.

**Risk**: HIGH. The argument "the Until witness must be in the interval because tau preserves types" requires formalizing a subtle model-theoretic transfer that has no existing Lean precedent in this codebase. The key gap: tau's formula agreement does not directly constrain WHERE a formula-satisfying point exists, only that formula truth transfers at corresponding positions.

### 5.3 Resolution Path 3: Hybrid -- Forward Game for Existence, U(B,A) for Formula Properties

**What it says**: Retain the forward game for e_n existence and interval containment, but use U(B,A) for formula properties, getting the best of both approaches.

**Infrastructure that EXISTS**:

| Component | Status | Location |
|-----------|--------|----------|
| Forward game `h_d_compat_left` | EXISTS | SplitPointProps.h_d_compat_left |
| `e_n` construction from forward game | EXISTS (current code lines 1257-1288) | CaseAnalysis.lean |
| `hform_en_an` from forward game | EXISTS (current code line 1290) | CaseAnalysis.lean |
| `he_n_in : inClosedInterval x y e_n` | EXISTS (current code line 1287) | CaseAnalysis.lean |
| `untl_type_holds_at_witness` | EXISTS | CharacteristicFormula.lean line 581 |
| `x_t_implies_agreement` | EXISTS | CharacteristicFormula.lean line 401 |
| `sf_untl_truth_mu` | EXISTS | CharacteristicFormula.lean line 556 |
| tau transfer at rank r+delta | EXISTS (props.tau) | SplitPointProps.tau |
| `formula_transfer_rank_embed` | EXISTS | CharacteristicFormula.lean line 624 |

**What would need to be BUILT**:

1. **Import**: Add `import Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula` to CaseAnalysis.lean (~1 line)

2. **Construct B, A, prove U(B,A)(ref_N)** (~15-25 lines):
   - Define `ref_N`, `B`, `A`
   - Apply `untl_type_holds_at_witness` (needs `mu_holds (a_bwd n)` from `h_point`, `ref_N < a_bwd n`)
   - Handle n=0 boundary

3. **Transfer U(B,A) through tau** (~30-50 lines):
   - Define `ref_M`
   - Play props.tau at rank r+delta with rank-embedded a_init
   - Extract formula agreement at ref position
   - Use `formula_transfer_rank_embed` and depth bound to transfer U(B,A)
   - Get `h_untl_M : stavi_temporal_truth_mu M atomMap r ref_M (sf_untl B A)`

4. **Extract interval type data from U(B,A)** (~20-30 lines):
   - Apply `untl_extract_witness` to `h_untl_M` to get witness `z`
   - **BUT z may not be e_n and may not be in [x, y]** -- this is the SAME containment problem
   - **Key insight for this path**: We do NOT use z as e_n. We keep the forward-game e_n. Instead, we use the EXISTENCE of z (anywhere) to establish interval type data: "every mu-point in (ref_M, z) satisfies A". Since (ref_M, e_n) is a subset of (ref_M, z) when e_n <= z, the A condition holds on (ref_M, e_n).
   - **BUT**: We don't know that e_n <= z. They could be ordered either way.
   - **Alternative**: Use the fact that both e_n and z satisfy B (i.e., have the same rank type as a_n). Then by rank type agreement, they are formula-equivalent at depth r. The interval type data from U(B,A) at (ref_M, z) tells us what types appear in (ref_M, z). If e_n < z, those types also appear in (ref_M, e_n). If z < e_n, the types in (ref_M, z) are a subset of types in (ref_M, e_n).

5. **Simplify Round 2 dispatch** -- this is already partially done by task 5.5/5.6 (~200-300 lines):
   - The current code already eliminates resp_mod
   - The sel_pn_ord from tau_left still works
   - The key new element: B-interval case in Round 2 uses interval type A data

**Estimated lines**: ~80-120 new lines for steps 2-4, reuse existing ~200-300 lines for Round 2 dispatch. Net change is modest.

**Risk**: MEDIUM-LOW for the forward-game part (well-understood), MEDIUM for the U(B,A) interval type extraction (step 4). The main question is whether we need the Until witness z to be in [x, y] for the interval type argument, or whether we can use it indirectly.

---

## 6. Critical Gap Analysis

### 6.1 The Fundamental Problem

The Until semantics in this codebase are GLOBAL: `untl_extract_witness` gives a witness anywhere in `ExtendedCarrier M atomMap r`. GHR93 implicitly assumes the witness can be chosen in the relevant interval because they work in a setting where the interval types of `[d, y']` and `[c, y]` are matched by tau. In the Lean formalization, this matching is encoded as formula agreement, not as a structural correspondence of the carrier elements.

### 6.2 What Would Be Required to Close the Gap

To guarantee a witness in `[c, y]`, one of these approaches would work:

**(A) tau guarantees type matching in [c, y]**: Since tau maps `[d, y']` to `[c, y]` with formula agreement, and B = X_{a_n} holds at a_n in `[d, y']`, we need to show that a B-satisfying point exists in `[c, y]`. This is actually provable using the forward game: the forward game's Round 2 response to p_n gives e_n in [x, y] with formula agreement at depth r. Since e_n has the same rank type as a_n, B(e_n) holds. And e_n is in [c, y] if c <= e_n, which follows from the ordering data (c <= e_n from `hord_cd_en_pn` when d <= p_n).

**(B) Use e_n from forward game, derive U(B,A) properties indirectly**: Since e_n is in [c, y] and has matching rank type, and the Until formula holds at ref_M, we can derive that all mu-points in (ref_M, e_n) satisfy the interval condition A. This requires:
- If z (the Until witness) >= e_n: then (ref_M, e_n) subset of (ref_M, z), so A holds on (ref_M, e_n)
- If z < e_n: then z is a B-point in (ref_M, e_n), and we could potentially use z instead of e_n. But z might not be in [x, y].

**The cleanest resolution**: Use the forward game for e_n (guaranteed in [x, y]), and then establish that U(B,A)(ref_M) with e_n as a B-satisfying point gives the interval A data. The key lemma needed:

```lean
-- If U(B,A)(t) holds and z > t with B(z), then:
-- Either z is the Until witness, or there's a CLOSER Until witness z' < z
-- In either case, A holds on all mu-points in (t, min(z, z'))
```

This "closer witness" argument is the mathematical crux. In a linear order with the type finiteness constraint, if B(e_n) holds at e_n > ref_M, and U(B,A)(ref_M) holds, then either:
1. The Until witness is <= e_n, in which case A holds on (ref_M, witness) which is a sub-interval of (ref_M, e_n)
2. The Until witness is > e_n, in which case A holds on (ref_M, witness) which contains (ref_M, e_n)

Either way, A holds on all mu-points in (ref_M, e_n). This can be formalized without constructing the witness explicitly.

### 6.3 The "Witness Irrelevance" Lemma

The key new lemma that would resolve the containment problem:

```lean
theorem untl_interval_condition {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t e : ExtendedCarrier M atomMap r} {B A : StaviFormula}
    (h_untl : stavi_temporal_truth_mu M atomMap r t (sf_untl B A))
    (h_te : t < e)
    (h_B_e : stavi_temporal_truth_mu M atomMap r e B)
    (h_mu_e : mu_holds e) :
    ∀ w : ExtendedCarrier M atomMap r, t < w → w < e → mu_holds w →
      stavi_temporal_truth_mu M atomMap r w A
```

**Proof sketch**: From `h_untl`, obtain witness z > t with mu_holds z, B(z), and A on (t, z). Case split:
- If z <= e: every w in (t, e) with w < z gets A from the Until interval condition. Every w in [z, e) ... hmm, this doesn't directly help because A only holds in (t, z).
- If z > e: then (t, e) is a subset of (t, z), so A holds on all mu-points in (t, e).
- If z = e: A holds on (t, z) = (t, e) directly.

Wait -- in the z < e case, we only get A on (t, z), not on (z, e). So the lemma as stated is NOT provable in general.

**Revised analysis**: The lemma holds if z >= e (cases z > e and z = e). When z < e, it fails because there could be mu-points in (z, e) that do not satisfy A.

**But**: In the specific Case II scenario, B = X_{a_n} (rank type characterizer). Both z and e_n satisfy B (same rank type as a_n). If z < e_n, we can use z instead of e_n as the witness. Since z is the Until witness and mu_holds z (so z is a carrier point), and A holds on (ref_M, z), we get interval type data for (ref_M, z).

The question then becomes: can we use z in (ref_M, e_n) as the response point instead of e_n? Only if z is in [x, y]. And that's the original containment problem.

**Conclusion**: The "witness irrelevance" lemma is provable ONLY in the z >= e case. The z < e case requires additional argument. The complete resolution requires handling both cases.

---

## 7. Recommended Approach

Based on this audit, **Resolution Path 3 (Hybrid)** is the most viable, with the following modification:

### 7.1 Modified Hybrid Approach

1. **Keep e_n from forward game** (guaranteed in [x, y], no containment issue)
2. **Transfer U(B,A) through tau** (straightforward, all infrastructure exists)
3. **Case split on Until witness z vs e_n**:
   - **z >= e_n**: A holds on (ref_M, z) which contains (ref_M, e_n). Done.
   - **z < e_n**: z is a B-satisfying mu-point in (ref_M, e_n). Since both z and e_n satisfy B (same rank type as a_n), and z < e_n, we can potentially reconstruct the Round 2 argument using z as an intermediate point. However, z is not guaranteed to be in [x, y].
   - **z < e_n, alternative**: Since U(B,A)(ref_M) holds with witness z < e_n, and A holds on (ref_M, z), we get interval type data for (ref_M, z). For Round 2, when b_sp is in (resp_tau(n-1), e_n):
     - If b_sp < z: A holds at b_sp (from Until interval condition)
     - If b_sp >= z: Use B(z) to respond (z has matching rank type). But z might not be in [x, y].

4. **Simplify**: Actually, we can avoid the z < e_n case entirely by choosing the correct Until formula. Define U(B, A) not from ref_M but from a position BELOW ref_M. Specifically, use U(B, A)(c). Since tau maps d to c with formula agreement, and U(B,A)(d) holds in N (because all a_bwd are above d), transferring gives U(B,A)(c) in M. The witness z from U(B,A)(c) satisfies z > c. If z is the FIRST B-point above c, and e_n is also a B-point above c (from forward game), then z <= e_n (z is the first). Then A holds on (c, z) which is a subset of (c, e_n).

   **But**: "first B-point" requires well-ordering or minimality infrastructure that does not exist.

### 7.2 Estimated Effort per Path

| Path | New Lines | New Lemmas | Risk | Existing Coverage |
|------|-----------|------------|------|-------------------|
| Path 1 (Forward + Bridge) | 80-120 | 1-2 bridge lemmas | MEDIUM | ~70% |
| Path 2 (Structural Bound) | 150-250 | 3-5 new lemmas | HIGH | ~40% |
| Path 3 (Hybrid) | 80-120 | 1-2 interval lemmas | MEDIUM-LOW | ~80% |
| Path 3 Modified | 100-150 | 2-3 interval lemmas + case split | MEDIUM | ~75% |

### 7.3 The Pragmatic Resolution

The simplest resolution that avoids the containment problem entirely:

**Keep the current forward-game e_n for BOTH existence and properties.** The current code already gets formula agreement from the forward game (`hform_en_an`). The only thing U(B,A) provides additionally is the interval type data for Round 2's B-interval case. But the current code handles Round 2 without interval type data, using tau_left's ordering directly.

In other words: **the current code (post-task-5.5/5.6) may already be sufficient.** The GHR93 U(B,A) approach would be cleaner and shorter, but it introduces the containment problem. The current approach is longer but avoids it entirely.

The question is whether the user specifically requires GHR93 faithfulness (in which case containment must be solved) or accepts the current working proof structure.

---

## 8. File-Level Summary

| File | Path | Lines | Sorries | Relevance |
|------|------|-------|---------|-----------|
| CharacteristicFormula.lean | `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` | 632 | 0 | Primary: all Until/type formula infrastructure |
| CaseAnalysis.lean | `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` | 3625 | 1 (line 3477, Cases III/IV) | Primary: ghr93_case_II proof |
| SplitPoint.lean | `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` | ~1600 | 0 | SplitPointProps structure |
| CustomGame.lean | `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CustomGame.lean` | ~350 | 0 | Game definitions |
| TypeFormulas.lean | `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/TypeFormulas.lean` | ~600 | 0 | rank_embed, rank_type, mu_holds |
| Defs.lean | `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Defs.lean` | ~460 | 0 | ExtendedCarrier, IsPoint, IsGap |
| GapDetection.lean | `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapDetection.lean` | ~2700 | 0 | stavi_truth_mu_at_point |
| EFGameTactics.lean | `Theories/Bimodal/Automation/EFGameTactics.lean` | ~290 | 0 | same_order_type_of_cases |
| Composition.lean | `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean` | ~200 | 0 | ghr93_strategy_compose |
| DConsistencyTransport.lean | `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyTransport.lean` | ~350 | 0 | ghr93_duplicator_wins_rank_down |
