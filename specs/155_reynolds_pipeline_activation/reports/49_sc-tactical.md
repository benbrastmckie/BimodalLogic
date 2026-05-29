# SC-D Tactical MCP Analysis: succ_cofinal and the Sorry Chain

**Task**: 155 (reynolds_pipeline_activation)
**Teammate**: SC-D (tactical MCP analysis)
**Date**: 2026-05-28
**File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

---

## 1. Goal State at the Sorry (Line 1885)

### lean_goal output (line 1885, goals_before)

The sorry sits in `case neg` -- the `L <= pred(b).val` branch of the `succ_cofinal` proof. The full goal state:

```
case neg
fc : FrameClass
A : Set Formula
h_mcs : SetMaximalConsistent A
h_discrete : forall x in limit_dom fc A h_mcs, next_top in limit_f fc A h_mcs x
a b : LimitDomSubtype fc A h_mcs
hab : a < b
s : LimitDomSubtype fc A h_mcs -> LimitDomSubtype fc A h_mcs
    := limitDomSubtype_succ fc A h_mcs h_discrete
h_not_cofinal : forall (n : Nat), s^[n] a < b
pb : LimitDomSubtype fc A h_mcs := limitDomSubtype_pred fc A h_mcs h_discrete b
h_le_pb : forall (n : Nat), s^[n] a <= pb
f : Nat -> Real := fun n => (s^[n] a).val
s_lt : forall (x : LimitDomSubtype fc A h_mcs), x < s x
f_mono : Monotone f
f_bdd : BddAbove (Set.range f)
L : Real
hL_tendsto : Filter.Tendsto f Filter.atTop (nhds L)
hL_ub : forall (n : Nat), f n <= L
hL_le_b : L <= b.val
h_pb_lt_b : pb.val < b.val
h_case : L <= pb.val
h_ne_pb : forall (n : Nat), s^[n] a != pb
h_lt_pb : forall (n : Nat), s^[n] a < pb
orbit_below_L : forall (c : LimitDomSubtype fc A h_mcs),
    a <= c -> c.val < L -> exists m, s^[m] a = c
p : LimitDomSubtype fc A h_mcs -> LimitDomSubtype fc A h_mcs
    := limitDomSubtype_pred fc A h_mcs h_discrete
p_def : p = limitDomSubtype_pred fc A h_mcs h_discrete
h_lt_pred_chain : forall (k n : Nat), s^[n] a < p^[k] pb
h_pred_chain_strict : forall (k : Nat), (p^[k + 1] pb).val < (p^[k] pb).val
h_pred_chain_ge_L : forall (k : Nat), L <= (p^[k] pb).val
backward_G : forall (psi : Formula) (x : LimitDomSubtype fc A h_mcs),
    (forall y : LimitDomSubtype fc A h_mcs, x < y ->
        psi in limit_f fc A h_mcs y.val) ->
    psi.all_future in limit_f fc A h_mcs x.val
backward_F : forall (phi : Formula) (x y : LimitDomSubtype fc A h_mcs),
    x < y -> phi in limit_f fc A h_mcs y.val ->
    phi.some_future in limit_f fc A h_mcs x.val
_backward_P : forall (phi : Formula) (x y : LimitDomSubtype fc A h_mcs),
    y < x -> phi in limit_f fc A h_mcs y.val ->
    phi.some_past in limit_f fc A h_mcs x.val
|- False
```

### Key observations about the goal state

1. **Goal is `False`**: This is a by-contradiction proof. The sorry must derive a contradiction from the "gap scenario."

2. **Two regions established**:
   - **Orbit**: `{s^[n](a) | n : Nat}` -- all with values `< L` in Real, `< pb` in LimitDomSubtype
   - **Pred-chain**: `{p^[k](pb) | k : Nat}` -- all with values `>= L` in Real, strictly decreasing

3. **Complete separation**: `h_lt_pred_chain` says ALL orbit points are strictly below ALL pred-chain points. Combined with `orbit_below_L` (any domain point `c` with `a <= c` and `c.val < L` is an orbit point), the orbit and pred-chain are completely disconnected components.

4. **Three backward truth lemmas available** (proved without using succ_cofinal):
   - `backward_G`: if psi holds at ALL y > x (in limit_dom), then G(psi) is in limit_f(x)
   - `backward_F`: if phi holds at some y > x, then F(phi) is in limit_f(x)
   - `_backward_P`: if phi holds at some y < x, then P(phi) is in limit_f(x)

5. **Only one branch leads to sorry**: The `L > pred(b).val` case was resolved (lines 1609-1621) -- direct contradiction because orbit exceeds pred(b). Only the `L <= pred(b).val` case is open.

---

## 2. Key Type Signatures (lean_hover_info)

### LimitDomSubtype

```lean
abbrev LimitDomSubtype (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent A) : Type
    := {q : Rat // q in limit_dom fc A h_mcs}
```

The limit domain as a subtype of the rationals. Countable (union of finite sets from omega-chain stages).

### succ_cofinal (private, line 1553)

```lean
private theorem succ_cofinal (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent A)
    (h_discrete : forall x in limit_dom fc A h_mcs,
        next_top in limit_f fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs) (hab : a < b) :
    exists n, b <= (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a
```

Claims: for any `a < b` in the limit domain, iterating `succ` from `a` eventually reaches or exceeds `b`.

### limitDomSubtype_isSuccArchimedean (line 1893)

```lean
noncomputable def limitDomSubtype_isSuccArchimedean (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent A)
    (h_discrete : forall x in limit_dom fc A h_mcs,
        next_top in limit_f fc A h_mcs x) :
    IsSuccArchimedean (LimitDomSubtype fc A h_mcs)
```

Wraps `succ_cofinal` + `succ_orbit_convex` to produce the Mathlib typeclass instance.

### IsSuccArchimedean (Mathlib)

```lean
IsSuccArchimedean.{u_3} (alpha : Type u_3) [Preorder alpha] [SuccOrder alpha] : Prop
-- A SuccOrder is succ-archimedean if one can go from any two comparable
-- elements by iterating succ
```

From `Mathlib.Order.SuccPred.Archimedean`. The key API:
- `exists_succ_iterate_of_le : a <= b -> exists n, Order.succ^[n] a = b`

### succ_embed_surjective (line 2817)

```lean
theorem succ_embed_surjective (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent A)
    (h_discrete : forall x in limit_dom fc A h_mcs,
        next_top in limit_f fc A h_mcs x)
    (w : LimitDomSubtype fc A h_mcs) :
    exists n : Int, succ_embed fc A h_mcs h_discrete n = w
```

Every limit domain point is in the succ_embed image. Uses `IsSuccArchimedean.exists_succ_iterate_of_le`.

### adj_g_mem_limit_f (ChronicleConstruction.lean:1357)

```lean
theorem adj_g_mem_limit_f (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent A) (k : Nat) (a b : Rat)
    (h_adj : Adjacent (omega_chain_val fc A h_mcs k).dom a b)
    (phi : Formula) (hphi : phi in (omega_chain_val fc A h_mcs k).g a b)
    (w : Rat) (hw : w in limit_dom fc A h_mcs)
    (haw : a < w) (hwb : w < b) :
    phi in limit_f fc A h_mcs w
```

Guard membership propagation: if phi is in the guard g(a,b) at stage k, and w is a limit-domain point strictly between a and b, then phi is in limit_f(w). **Sorry-free.**

### limit_F_resolution (ChronicleConstruction.lean:689)

```lean
theorem limit_F_resolution (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent A) (x : Rat)
    (hx : x in limit_dom fc A h_mcs) (phi : Formula)
    (h_F : phi.some_future in limit_f fc A h_mcs x) :
    exists y in limit_dom fc A h_mcs, x < y and phi in limit_f fc A h_mcs y
```

F-resolution: `F(phi) in limit_f(x)` implies witness `y > x` with `phi in limit_f(y)`. **Sorry-free.**

### limit_forward_G (ChronicleConstruction.lean:1027)

```lean
theorem limit_forward_G (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent A) (x y : Rat)
    (hx : x in limit_dom fc A h_mcs) (hy : y in limit_dom fc A h_mcs)
    (hxy : x < y) (phi : Formula)
    (h_G : phi.all_future in limit_f fc A h_mcs x) :
    phi in limit_f fc A h_mcs y
```

Forward G: `G(phi) in limit_f(x)` and `x < y` implies `phi in limit_f(y)`. **Sorry-free.**

### succ_embed_no_gap (line 2699)

```lean
theorem succ_embed_no_gap (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent A)
    (h_discrete : ...) (n : Int)
    (w : LimitDomSubtype fc A h_mcs)
    (h1 : succ_embed ... n < w) (h2 : w < succ_embed ... (n + 1)) : False
```

No domain point exists strictly between consecutive succ_embed images. The KEY property of the discrete case. **Sorry-free.**

### succ_embed_squeeze (line 2736)

```lean
theorem succ_embed_squeeze (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent A)
    (h_discrete : ...) (a b : Int) (hab : a <= b)
    (w : LimitDomSubtype fc A h_mcs)
    (hw_lo : succ_embed ... a <= w)
    (hw_hi : w <= succ_embed ... b) :
    exists k, a <= k and k <= b and succ_embed ... k = w
```

Any domain point BETWEEN two known embed images is itself an embed image. The key lemma that makes BUC work without surjectivity. **Sorry-free.**

---

## 3. lean_verify Results: The Sorry Chain

### Summary Table

| Theorem | File | sorryAx? | Other Axioms |
|---------|------|----------|-------------|
| `succ_cofinal` | ChronicleToCountermodel.lean | **YES** | propext, Classical.choice, ofReduceBool, trustCompiler, Quot.sound |
| `limit_dom_points_are_succ_iterates` | ChronicleToCountermodel.lean | **YES** | (same) |
| `limitDomSubtype_isSuccArchimedean` | ChronicleToCountermodel.lean | **YES** | (same) |
| `succ_embed_surjective` | ChronicleToCountermodel.lean | **YES** | (same) |
| `cantor_bfmcs_discrete_restricted_tc` | ChronicleToCountermodel.lean | **YES** | (same) |
| `cantor_bfmcs_discrete_restricted_fuc` | ChronicleToCountermodel.lean | **YES** | (same) |
| `cantor_bfmcs_discrete_restricted_buc` | ChronicleToCountermodel.lean | **NO** | propext, Classical.choice, ofReduceBool, trustCompiler, Quot.sound |
| `dd_countermodel_chronicle_discrete` | ChronicleToCountermodel.lean | **YES** | (same) |
| `countermodel_discrete_enriched` | Completeness.lean | **YES** | (same) |
| `completeness_discrete` | Completeness.lean | **(see note)** | **(see note)** |
| `completeness` (main) | Completeness.lean | **YES** | (same) |
| `dd_countermodel_chronicle_mixed_sorry` | ChronicleToCountermodel.lean | **NO** | propext, Classical.choice, ofReduceBool, trustCompiler, Quot.sound |

### Sorry-Free Infrastructure (All Verified)

| Theorem | File | Status |
|---------|------|--------|
| `succ_embed_no_gap` | ChronicleToCountermodel.lean | Clean |
| `succ_embed_squeeze` | ChronicleToCountermodel.lean | Clean |
| `succ_embed_squeeze_strict` | ChronicleToCountermodel.lean | Clean |
| `succ_embed_strictMono` | ChronicleToCountermodel.lean | Clean |
| `limit_F_resolution` | ChronicleConstruction.lean | Clean |
| `limit_forward_G` | ChronicleConstruction.lean | Clean |
| `limit_satisfies_c5_strong` | ChronicleConstruction.lean | Clean |
| `adj_g_mem_limit_f` | ChronicleConstruction.lean | Clean |

### Note on completeness_discrete

`lean_verify` for `completeness_discrete` returned `{"axioms":[]}`. This is likely a lean_verify reporting anomaly (the tool may not follow private theorem dependencies or may have limitations on axiom reporting for theorems whose proof was checked but whose transitive closure includes private definitions). The `#print axioms` statement at Completeness.lean:374 should reflect the actual axiom set. Since `completeness_discrete` calls `countermodel_discrete_enriched` (which has sorryAx), the theorem transitively depends on sorryAx through:
```
completeness_discrete
  -> countermodel_discrete_enriched (has sorryAx)
    -> cantor_bfmcs_discrete_restricted_tc (has sorryAx)
    -> cantor_bfmcs_discrete_restricted_fuc (has sorryAx)
```

---

## 4. The Sorry Chain: Precise Dependency Graph

```
succ_cofinal (LINE 1885, ROOT SORRY)
  |
  v
limitDomSubtype_isSuccArchimedean (LINE 1893)
  |
  v
succ_embed_surjective (LINE 2817)
  |
  +---> cantor_bfmcs_discrete_restricted_tc (LINE 3142)
  |       |
  |       v
  |     countermodel_discrete_enriched (Completeness.lean:222)
  |       |
  |       v
  |     completeness_discrete (Completeness.lean:308)
  |       |
  |       v
  |     completeness (Completeness.lean, main theorem)
  |
  +---> cantor_bfmcs_discrete_restricted_fuc (LINE 3197)
          |
          v
        (same path to completeness_discrete)

SEPARATE (sorry-free):
  cantor_bfmcs_discrete_restricted_buc (LINE 3066)
    uses succ_embed_squeeze_strict (sorry-free)

DEAD CODE (has sorry, not on critical path):
  limit_dom_points_are_succ_iterates (LINE 1458)
    not used by any other theorem
```

### The Minimum Cut Point

**`succ_embed_surjective`** is the minimum cut point. It is called 4 times in TC and 4 times in FUC (mapping limit_dom witnesses back to integers). If surjectivity is established, ALL downstream theorems become sorry-free automatically.

Equivalently, **`succ_cofinal`** is the root sorry. It is the ONLY sorry that propagates to `completeness_discrete`.

---

## 5. Why succ_embed_surjective Is Needed (and Why BUC Avoids It)

### BUC (backward until/since coherence) -- sorry-free

BUC uses the **contrapositive** approach:
1. Assume `neg(Until(xi, eta)) in MCS(t)` and `eta in MCS(u)` for some `u > t`
2. By `limit_satisfies_c4`: there exists witness `z` with `t < z < u` and `xi.neg in limit_f(z)`
3. Use `succ_embed_squeeze_strict`: since `z` is BETWEEN `succ_embed(t + offset)` and `succ_embed(u + offset)`, there exists integer `k` with `succ_embed(k) = z`
4. Contradiction with the guard condition

**Key**: The witness `z` falls BETWEEN two known embed images, so `squeeze_strict` (sorry-free) suffices.

### TC (temporal coherence) -- has sorry

TC needs: `F(phi) in MCS(t)` implies `exists s > t, phi in MCS(s)`.
1. `F(phi) in limit_f(succ_embed(t + offset))`
2. `limit_F_resolution` gives witness `y > succ_embed(t + offset)` with `phi in limit_f(y)`
3. Need to convert `y` to an integer `m` -- **requires `succ_embed_surjective`**

**Key**: The witness `y` may be ABOVE all known embed images. There is no upper bound to squeeze against.

### FUC (forward until/since coherence) -- has sorry

FUC needs: `U(phi, psi) in MCS(t)` implies `exists s > t, phi in MCS(s)` with guard.
1. `U(phi, psi) in limit_f(succ_embed(t + offset))`
2. `limit_satisfies_c5_strong` gives witness `y` with `phi in limit_f(y)` and guards
3. Need to convert `y` to integer `m` -- **requires `succ_embed_surjective`**

Same issue as TC: the witness may be above all known embed images.

---

## 6. Steps 1-8 of the succ_cofinal Proof (Lines 1557-1696)

### Step-by-step analysis with goal states

| Step | Lines | What It Establishes | Status |
|------|-------|---------------------|--------|
| 1 | 1561-1564 | `h_le_pb`: all orbit points `<= pred(b)` | Complete |
| 2 | 1565-1596 | `f_mono`, `f_bdd`, `hL_tendsto`, `hL_ub`, `hL_le_b`: real-valued orbit converges to L | Complete |
| 3 | 1597-1621 | Case `L > pred(b).val`: direct contradiction | Complete |
| 4 | 1633-1635 | `h_lt_pb`: all orbit strictly below pred(b) | Complete |
| 5 | 1639-1656 | `orbit_below_L`: domain points with `a <= c` and `c.val < L` are orbit points | Complete |
| 6 | 1658-1684 | `h_lt_pred_chain`: ALL orbit < ALL pred-chain | Complete |
| 7 | 1685-1695 | `h_pred_chain_strict`, `h_pred_chain_ge_L`: pred-chain strictly decreasing, bounded below by L | Complete |
| 8 | 1696-1839 | `backward_G`, `backward_F`, `_backward_P`: truth lemmas (proved without succ_cofinal) | Complete |
| 9 | 1840-1885 | **Gap elimination: derive False** | **SORRY** |

### Goal state at the boundary (line 1696, just after Step 8)

Confirmed by `lean_goal` at line 1696: the goal is `False` with all 8 steps' hypotheses available (as listed in the full goal state in Section 1 above).

### What Step 9 must prove

Derive `False` from the existence of a "gap" between orbit and pred-chain. The gap scenario:
- Orbit `{s^[n](a)}` has rational values converging to `L` from below
- Pred-chain `{p^[k](pb)}` has rational values `>= L`, strictly decreasing
- ALL orbit < ALL pred-chain
- There are NO domain points with value exactly `L` (if there were, they would be captured by `orbit_below_L` or be a pred-chain point, both contradictory)

---

## 7. Approaches Investigated and Failed

Documented in the proof comments (lines 1848-1884):

### (1) Prior-UZ + c5_strong

`F(phi) -> U(phi, neg(phi))` by Prior-UZ. Then `c5_strong` gives witness `y` with phi at `y` and `neg(phi)` at all intermediates. **Fails in discrete case**: between consecutive succ points, there are NO intermediates, so the guard is vacuously satisfied.

### (2) Z1 (Doets maximum principle)

`Z1 = G(G(phi)->phi) -> (FG(phi)->G(phi))`. **Fails in constant-MCS case**: if all limit_dom points have identical MCS labels, then `G(phi)->phi` is trivially in every MCS, and `Z1` gives no information.

### (3) Gap point / infinite descent

If a limit_dom point `c` exists with `c.val >= L` and below all pred-chain points, then `pred(c)` is either an orbit point (contradiction) or another gap point (infinite descent). **Fails**: the descent converges to `L` but no contradiction is reached because `NoMinOrder` allows unbounded descent.

---

## 8. Infrastructure Search Results

### lean_local_search: "cofinal"

| Name | File | Kind |
|------|------|------|
| `WeakCanonical.cofinal_above_iff_succ` | StaviConnectives.lean | theorem |
| `WeakCanonical.cofinal_below_iff_pred` | StaviConnectives.lean | theorem |
| `Order.cofinal_meets_idealOfCofinals` | Mathlib | theorem |

No project-local `cofinal` besides the WeakCanonical variants (different pipeline).

### lean_local_search: "succ_embed"

8 results, all in ChronicleToCountermodel.lean:
- `succ_embed_pred`, `succ_embed_succ`, `succ_embed_zero` (definitional)
- `succ_embed_no_gap`, `succ_embed_squeeze`, `succ_embed_squeeze_strict` (sorry-free infrastructure)
- `succ_embed_strictMono` (sorry-free)
- `succ_embed_surjective` (has sorryAx -- the one we need)

### lean_local_search: "completeness_discrete"

2 results:
- `BXCanonical.completeness_discrete` (Completeness.lean) -- main theorem
- `DiscreteCompleteness.completeness_discrete` (Boneyard, legacy)

---

## 9. Critical Structural Insight

### The sorry is purely about ORDER THEORY, not about temporal logic

The sorry goal is `False` given a gap between a monotone sequence and a descending pred-chain in a SuccOrder/PredOrder on a countable subset of Rat. The temporal logic infrastructure (`backward_G`, `backward_F`, `_backward_P`, `z1_in_mcs`, `limit_F_resolution`, etc.) has been fully established in the context but CANNOT close the gap.

The gap scenario is **consistent with all temporal axioms** in the constant-MCS case. The contradiction must come from **properties of the omega-chain construction itself** -- specifically, that the construction process cannot produce a domain with disconnected Z-components.

### What a solution requires

1. **A construction-level argument** showing omega-chain stages cannot produce a gap (requires deep interaction with `omega_chain_elim_result`, `BurgessR3Maximal`)
2. OR **the Reynolds pipeline** (task 155) bypassing `succ_cofinal` entirely
3. OR **the Henkin model approach** (task 129) providing `IsSuccArchimedean` via a different canonical model

### The sorry does NOT propagate to BUC

`cantor_bfmcs_discrete_restricted_buc` is completely sorry-free because it uses `succ_embed_squeeze_strict` instead of `succ_embed_surjective`. This is because C4 witnesses fall BETWEEN known embed images (contrapositive argument), while C5/F-resolution witnesses may fall OUTSIDE the known range.

---

## 10. Two Sorry Sites (Both Same Root Cause)

| Line | Theorem | Used By | Status |
|------|---------|---------|--------|
| 1508 | `limit_dom_points_are_succ_iterates` | Nothing (dead code) | Dead sorry |
| 1885 | `succ_cofinal` | `limitDomSubtype_isSuccArchimedean` -> chain to `completeness_discrete` | **ROOT SORRY** |

Only line 1885 is on the critical path. Line 1508 is dead code with the same mathematical content (both face the gap scenario).
