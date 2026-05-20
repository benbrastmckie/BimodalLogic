# Rank Embedding Design for GHR93 Theorem 6

## 1. The Problem: Where Rank Variation Enters

### 1.1 Current Code (Uniform Rank)

The current `ghr93_forward_to_backward` in `ExpressivenessGeneral.lean` uses
uniform rank `r` for both games:

```
(*)_n (uniform): G_{1+3n; r}(M,xy; N,x'y')  =>  G_{n;r}(N,x'y'; M,xy)
```

All bounds x, y, x', y' live in `ExtendedCarrier M atomMap r` (resp. N).
The base case (n=0) is proved. The inductive step is `sorry`.

### 1.2 The Real GHR93 Statement

GHR93 Theorem 6 states (*)_n with rank variation:

```
(*)_n (real): G_{1+3n; r+4n}(M,xy; N,x'y')  =>  G_{n;r}(N,x'y'; M,xy)
```

The forward game uses rank `r+4n`; the backward game uses rank `r`.

### 1.3 Why Rank Variation Is Needed

In the inductive step (n to n+1), the proof:

1. **Starts** with forward `G_{4+3n; r+4(n+1)}(M,xy; N,x'y')` at rank `r+4n+4`.
2. **Restricts** to sub-intervals, getting `G_{1+3n; r+4(n+1)}(M,xc; N,x'd)`.
3. **Applies IH** `(*)_n` to get backward `G_{n; r+4}(N,x'd; M,xc)`.
   - The IH at level n needs forward rank `(r+4)+4n = r+4n+4` (matches step 2).
   - The IH produces backward rank `r+4`.
4. **Uses** the backward strategies sigma, tau at rank `r+4` to build
   the backward strategy at rank `r`.

The key rank chain is: `r+4(n+1) --> r+4+4n --> r+4 --> r`. Each arrow
potentially changes the `ExtendedCarrier` type.

### 1.4 What Exactly Breaks

With uniform rank, the IH application in step 3 is:

- IH says: `G_{1+3n; r}(M,...) => G_{n;r}(N,...)` (same r for both).
- We have: `G_{1+3n; r+4n+4}(M,xc; N,x'd)` at rank `r+4n+4`.
- To use IH, we would need r = r+4n+4, i.e., n = 0 and rank unchanged.

The uniform-rank formulation simply cannot express the rank drop from
`r+4n+4` to `r+4` that the IH produces. The four cases (I-IV) then need
strategies sigma, tau at rank `r+4`, but the elements they operate on are
in `ExtendedCarrier ... (r+4)`, not `ExtendedCarrier ... r`.

---

## 2. How M_r Depends on r

### 2.1 The Monotonicity of Extended Carriers

`ExtendedCarrier M atomMap r = M.carrier + RDefinableGap M atomMap r`

An r-definable gap requires a StaviFormula D of depth <= r defining it.
If r' >= r, then depth <= r implies depth <= r', so every r-definable gap
is also r'-definable. Thus:

```
RDefinableGap M atomMap r  embeds into  RDefinableGap M atomMap r'
```

and consequently:

```
ExtendedCarrier M atomMap r  embeds into  ExtendedCarrier M atomMap r'
```

The embedding maps points to points (identity on M.carrier) and gaps to
gaps (same underlying Gap, just with a weaker rank bound on the defining
formula).

### 2.2 Order Preservation

The ordering on ExtendedCarrier is defined structurally:
- point vs point: use M's order
- point vs gap: membership in cut
- gap vs gap: cut inclusion

Since the embedding preserves the underlying point/gap and their cuts,
it is strictly order-preserving (an OrderEmbedding).

### 2.3 Non-Surjectivity

`ExtendedCarrier M atomMap r'` may contain gaps not present in
`ExtendedCarrier M atomMap r` (those definable only by formulas of depth
in (r, r']). So the embedding is injective but not surjective in general.

---

## 3. Evaluation of Options

### Option A: Define rank_embed as OrderEmbedding

**Approach**: Define `rank_embed : ExtendedCarrier M atomMap r -> ExtendedCarrier M atomMap r'`
for `r <= r'`, prove it is an OrderEmbedding, then restate Theorem 6 with
the proper rank-varying signature.

**Implementation sketch**:
```lean
def rank_embed (h : r ≤ r') : ExtendedCarrier M atomMap r → ExtendedCarrier M atomMap r' :=
  Sum.map id (fun g => ⟨g.val, r_definable_gap_mono g.prop h⟩)
```

where `r_definable_gap_mono` proves that r-definable implies r'-definable.

**Theorem 6 signature becomes**:
```lean
theorem ghr93_forward_to_backward (n r : Nat)
    {x y : ExtendedCarrier M atomMap (r + 4*n)}
    {x' y' : ExtendedCarrier N atomMap (r + 4*n)}
    (h_bounds_M : ∃ xr yr : ExtendedCarrier M atomMap r,
        rank_embed ... xr = x ∧ rank_embed ... yr = y)
    (h_bounds_N : ∃ x'r y'r : ExtendedCarrier N atomMap r,
        rank_embed ... x'r = x' ∧ rank_embed ... y'r = y')
    (h : ghr93_duplicator_wins M N atomMap (1+3*n) (r+4*n) x y x' y') :
    ghr93_duplicator_wins N M atomMap n r x'r y'r x y
```

**Pros**: Faithful to GHR93. Maximally general.

**Cons**: Complex. Every lemma that touches ExtendedCarrier needs a
rank_embed variant. The IH application requires showing that restricted
sub-interval bounds are in the image of rank_embed. The four cases all
need to thread rank_embed through their constructions. Estimated 300-500
additional lines of infrastructure before even starting the cases.

**Verdict**: Correct but high cost. Overkill if a simpler approach works.

### Option B: Work at Maximum Rank Throughout

**Approach**: Reformulate Theorem 6 so everything lives at a single
"max rank" R = r + 4n. The forward game is at rank R. The backward game
is also at rank R (not rank r). Then use Lemma 10 (rank monotonicity,
once we prove it) to drop from R to r at the very end.

**Problem**: This just pushes the problem to Lemma 10's rank monotonicity.
Lemma 10 says: wins at (n, r) implies wins at (n', r') for n' <= n,
r' <= r, **provided x, y are in M_{r'}**. The "provided" clause means
Lemma 10 ITSELF needs rank_embed to state and prove.

Additionally, the current code already has the uniform-rank Theorem 6.
The issue is not the statement but the inductive step, where the IH
produces strategies at rank r+4, not rank r+4n+4. Even at "max rank"
the IH still produces a lower rank.

**Verdict**: Does not actually avoid the problem. Defers it to Lemma 10.

### Option C: Rank-Independent ExtendedCarrier

**Approach**: Define `ExtendedCarrier M atomMap` (no rank parameter) as
`M.carrier + AllGaps M` where `AllGaps` includes ALL definable gaps
across all ranks. Add a predicate `in_M_r : ExtendedCarrier M atomMap -> Nat -> Prop`
that checks whether an element is in M_r.

**Implementation sketch**:
```lean
def AllDefinableGap M atomMap := { g : Gap M.carrier // ∃ r, r_definable_gap M atomMap g r }

def ExtendedCarrierUniv M atomMap := M.carrier ⊕ AllDefinableGap M atomMap

def in_M_r (e : ExtendedCarrierUniv M atomMap) (r : Nat) : Prop :=
  match e with
  | .inl _ => True  -- points are in every M_r
  | .inr g => r_definable_gap M atomMap g.val r
```

Then `ghr93_duplicator_wins` would quantify over elements satisfying
`in_M_r e r` instead of using `ExtendedCarrier M atomMap r` as the type.

**Pros**: All elements live in the same type. No coercions needed.
Rank variation is just predicate variation.

**Cons**: Massive refactor. Every existing definition (extendedLE,
extendedLinearOrder, extendedStructure, mu_holds, rank_type, game_tuple,
ghr93_duplicator_wins, decomposition_agreement, left_formula, right_formula,
the complete 4B infrastructure) must be rewritten. The linear order proof
becomes harder because AllDefinableGap is not finite at any rank. Estimated
1000+ lines of changes.

**Verdict**: Cleanest in principle but prohibitively expensive given the
existing codebase. Would require rewriting all of Phase 4B.

### Option D: Reformulate Using Lemma 10 Proviso

**Approach**: Keep ExtendedCarrier rank-dependent. State Theorem 6 at
rank r+4n for the forward game and r for the backward game, but with
the bounds x, y in M_r (not M_{r+4n}). This matches the GHR93 Lemma 10
proviso: "provided x, y in M_{r'}."

The key observation: **the bounds x, y, x', y' are always points or
r-definable gaps** in the GHR93 proof. They are never gaps definable
only at higher ranks. So we can state:

```lean
theorem ghr93_forward_to_backward (n r : Nat)
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (h : ghr93_duplicator_wins M N atomMap (1+3*n) (r+4*n)
           (rank_embed .. x) (rank_embed .. y)
           (rank_embed .. x') (rank_embed .. y')) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y
```

This still needs rank_embed, but only for the bounds -- not for every
element in the game. The Spoiler's selections and Duplicator's responses
in the forward game are at rank r+4n, but the backward game's elements
are at rank r.

**Pros**: Matches GHR93 exactly. Only needs rank_embed for bounds.

**Cons**: Still needs rank_embed infrastructure. The IH application
requires showing c, d (the infimum elements) are in M_{r+4} and can be
embedded up.

**Verdict**: Moderate cost. Better than Option A but still needs embedding.

---

## 4. Recommended Approach: Option A (Minimal Version)

After analyzing all options, **Option A with minimal infrastructure** is
the recommended approach. Here is why:

1. Options B and C do not actually avoid the problem.
2. Option D is essentially Option A with a different packaging.
3. The rank_embed infrastructure, while non-trivial, is a one-time cost
   that enables the entire inductive step and is mathematically natural.

### 4.1 Minimal Infrastructure Needed

The rank embedding needs exactly these components:

**Core definition** (~20 lines):
```lean
theorem r_definable_gap_mono {r r' : Nat} (h : r ≤ r')
    (hg : r_definable_gap M atomMap g r) :
    r_definable_gap M atomMap g r' := by
  obtain ⟨D, hd, hdef⟩ := hg
  exact ⟨D, le_trans hd h, hdef⟩

def rank_embed_gap (h : r ≤ r') :
    RDefinableGap M atomMap r → RDefinableGap M atomMap r' :=
  fun g => ⟨g.val, r_definable_gap_mono h g.prop⟩

def rank_embed (h : r ≤ r') :
    ExtendedCarrier M atomMap r → ExtendedCarrier M atomMap r' :=
  Sum.map id (rank_embed_gap h)
```

**Order preservation** (~30 lines):
```lean
theorem rank_embed_le_iff (h : r ≤ r') (a b : ExtendedCarrier M atomMap r) :
    rank_embed h a ≤ rank_embed h b ↔ a ≤ b

theorem rank_embed_order_embedding (h : r ≤ r') :
    OrderEmbedding (ExtendedCarrier M atomMap r) (ExtendedCarrier M atomMap r')
```

**Compatibility lemmas** (~40 lines):
```lean
theorem rank_embed_point (h : r ≤ r') (x : M.carrier) :
    rank_embed h (extendPoint x) = extendPoint x

theorem rank_embed_isPoint (h : r ≤ r') (e : ExtendedCarrier M atomMap r) :
    IsPoint (rank_embed h e) ↔ IsPoint e

theorem rank_embed_inClosedInterval (h : r ≤ r') (x y e) :
    inClosedInterval (rank_embed h x) (rank_embed h y) (rank_embed h e) ↔
    inClosedInterval x y e

theorem rank_embed_mu_holds (h : r ≤ r') (e) :
    mu_holds (rank_embed h e) ↔ mu_holds e
```

**Formula agreement transfer** (~50 lines):
```lean
-- Key: rank-r formulas agree at rank_embed(e) in M_{r'} iff they agree at e in M_r
-- This follows because rank_embed preserves mu_holds and order, and
-- r-bounded formulas only reference mu-points and order.
theorem rank_embed_formula_agreement (h : r ≤ r')
    (A : StaviFormula) (hA : stavi_depth A ≤ r)
    (e : ExtendedCarrier M atomMap r) :
    stavi_temporal_truth_mu M atomMap r' (rank_embed h e) A ↔
    stavi_temporal_truth_mu M atomMap r e A
```

**Total**: ~140 lines of infrastructure.

### 4.2 Revised Theorem 6 Signature

```lean
theorem ghr93_forward_to_backward (n r : Nat)
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h : ghr93_duplicator_wins M N atomMap (1 + 3*n) (r + 4*n)
           (rank_embed (by omega) x) (rank_embed (by omega) y)
           (rank_embed (by omega) x') (rank_embed (by omega) y')) :
    ghr93_duplicator_wins N M atomMap n r x' y' x y
```

The base case (n=0) has r+4*0 = r, so `rank_embed (by omega)` is the
identity (up to definitional equality or a simple `rank_embed_id` lemma).

### 4.3 Inductive Step Sketch

In the inductive step, given:
- Forward: `ghr93_duplicator_wins M N atomMap (4+3*n) (r+4*(n+1)) X Y X' Y'`
  where X = rank_embed x, Y = rank_embed y (embedded from rank r to r+4n+4)

The proof:
1. Restrict to sub-intervals at rank r+4n+4 to get
   `ghr93_duplicator_wins M N atomMap (1+3*n) (r+4n+4) Xc Xd ...`
2. Note r+4n+4 = (r+4)+4n, so apply IH at base rank r+4:
   `ghr93_forward_to_backward n (r+4) ...`
   This needs bounds c, d in `ExtendedCarrier M atomMap (r+4)`.
3. The IH produces backward strategies at rank r+4.
4. The four cases operate at rank r+4 and produce backward moves at rank r.

The critical question: **are c and d in M_{r+4}?**

From the GHR93 proof, c and d are infima defined by rank-r formulas
(specifically C, which has rank r). So c is either a point of M (always
in M_r) or a gap definable by a formula of rank r+1 (in M_{r+1}, hence
in M_{r+4}). Similarly for d. So yes, c and d can be represented as
elements of `ExtendedCarrier M atomMap (r+4)`, and then embedded up to
rank r+4n+4 where the strategy operates.

### 4.4 Rank Monotonicity for Lemma 10

With rank_embed, we can also state and prove the full Lemma 10:

```lean
theorem ghr93_duplicator_wins_mono (hn : n' ≤ n) (hr : r' ≤ r)
    {x y : ExtendedCarrier M atomMap r'}
    {x' y' : ExtendedCarrier N atomMap r'}
    (h : ghr93_duplicator_wins M N atomMap n r
           (rank_embed hr x) (rank_embed hr y)
           (rank_embed hr x') (rank_embed hr y')) :
    ghr93_duplicator_wins M N atomMap n' r' x y x' y'
```

This combines the existing round monotonicity with rank monotonicity.

---

## 5. Implementation Plan

### Step 1: rank_embed infrastructure (~140 lines, in EFGames.lean)
- `r_definable_gap_mono`
- `rank_embed_gap`, `rank_embed`
- `rank_embed_id` (r <= r with rfl gives identity)
- `rank_embed_le_iff`, `rank_embed_order_embedding`
- `rank_embed_point`, `rank_embed_isPoint`, `rank_embed_mu_holds`
- `rank_embed_inClosedInterval`
- `rank_embed_formula_agreement`

### Step 2: Revise Theorem 6 signature (~20 lines, in ExpressivenessGeneral.lean)
- Change hypothesis to use `rank_embed` with rank `r+4*n`
- Verify base case still works (rank_embed at r+0 = id)

### Step 3: Full Lemma 10 (~60 lines, in EFGames.lean)
- `ghr93_duplicator_wins_rank_mono` (rank-only monotonicity)
- `ghr93_duplicator_wins_mono` (combined round + rank)

### Step 4: Proceed with inductive step (Tasks 4C.2-4C.7)
- With rank_embed available, the inductive step can properly thread
  rank changes through the IH application and case analysis.

**Total additional infrastructure**: ~220 lines before Cases I-IV.

---

## 6. Key Risk: rank_embed_formula_agreement

The hardest lemma is `rank_embed_formula_agreement`: showing that
mu-relativized truth of rank-r formulas is preserved by rank_embed.

The argument is: rank_embed preserves (a) the order, (b) mu-status
(points stay points, gaps stay gaps), and (c) predicate values at points.
Since stavi_temporal_truth_mu only quantifies over mu-points and uses the
interleaved order, and since rank_embed is an order embedding that
preserves mu-status, truth of formulas referencing only rank-r concepts
is preserved.

This requires an induction on StaviFormula structure, which is moderate
(~50-80 lines) but straightforward -- each case follows from the order
embedding and mu-preservation properties.

The one subtlety: the quantifiers in Until/Since range over ALL elements
of the extended carrier, but only "visit" mu-points. Since rank_embed
adds gaps (not points), the mu-points are the same set, and the ordering
among them is preserved. So the truth of mu-relativized formulas is
invariant under rank_embed.
