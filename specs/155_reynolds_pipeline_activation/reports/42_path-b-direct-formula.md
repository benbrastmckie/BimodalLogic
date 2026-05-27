# Report 42: Path B -- Direct Interval Type Formula Construction

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-27
**Focus**: Can interval type formulas be built as StaviFormulas without `nf_characterizable_by_stavi`?

---

## 1. Existing Infrastructure

### 1.1 Formula Construction Tools Already Present

| Tool | Location | What It Does |
|------|----------|--------------|
| `nf_base_sf` | StaviCompleteness.lean:1413 | Builds StaviFormula for depth-0 NFs (conjunction of atom literals) |
| `nf_base_sf_correct` | StaviCompleteness.lean:1421 | Proves base case correctness |
| `sf_conjList` / `sf_disjList` | StaviCompleteness.lean:1274-1358 | Finite conjunction/disjunction combinators with correctness proofs |
| `sf_atom_literal` | StaviCompleteness.lean:1364 | Atom literal StaviFormula builder |
| `atomKind_to_sf_literal` | StaviCompleteness.lean:1379 | AtomKind-to-StaviFormula translator |
| `nf_exist_sf_depth0` | StaviCompleteness.lean:1497 | Existence formula for 2-variable depth-0 NFs using Until/Since |
| `stavi_table_mu` | StaviCompleteness.lean:291 | Translates StaviFormula to MonadicFormula (muSig), with correctness theorem |
| `stavi_table_mu_correct` | StaviCompleteness.lean:548 | The FO translation preserves mu-relativized temporal semantics |
| `stavi_expressive_completeness` | StaviCompleteness.lean:1570 | Full expressive completeness (depends on `nf_characterizable_by_stavi`) |

### 1.2 Interval Type as Predicate (Not Formula)

| Predicate | Location | Purpose |
|-----------|----------|---------|
| `cont_holds` | Claim1.lean:95 | `C(t)` = t satisfies every rank-r StaviFormula holding on `(a_n, y')` |
| `cont_holds_cross` | Claim1.lean:110 | Cross-structure variant for M-side |
| `continuation_set` | Claim1.lean:164 | `S_C` = set of t where cont_holds holds cofinally |
| `continuation_set_cross` | Claim1.lean:125 | Cross-structure variant for M-side |

These are **Prop-level** predicates quantifying over ALL StaviFormulas of depth `<= r`. They cannot directly be used as formulas in the game-theoretic argument because they quantify over the metatheory, not over a syntactic object.

### 1.3 pigeonhole_definable_formula

**Location**: Claim1.lean:646

**What it does**: Given that `cont_holds` fails cofinally below a gap, it extracts a SINGLE formula `D` of `stavi_depth D <= r` that:
- holds on all mu-points in `(a_n, y')`
- fails cofinally in the gap's carrier cut

**How it works**: Builds an ascending chain of failure points with pairwise distinct NormalForm types at depth `2*r` over `muSig sig`. Since `NormalForm (muSig sig) (2*r) 1` is `Fintype`, the chain length exceeds cardinality, giving a pigeonhole contradiction.

**Key limitation**: This extracts ONE distinguishing formula from cont_holds failure. It does NOT construct the full interval type formula `X_{(a_n, y')}`. It is used for gap detection (Claim 1 infrastructure), not for the U(B,A) transfer.

---

## 2. Finiteness Analysis

### 2.1 NormalForm is Fintype at Every Bounded Depth

```lean
instance normalForm_fintype (sig : MonadicSignature) (k n : Nat) :
    Fintype (NormalForm sig k n) :=
  (normalForm_fintype_and_decEq sig k n).1
```

**Location**: NormalForm.lean:177

`NormalForm sig k 1` is a `Fintype` for ALL `k`. This means:
- We can enumerate all 1-variable depth-k NFs
- `Fintype.elems` gives the complete set
- This is already used in `stavi_expressive_completeness` (line 1593)

### 2.2 StaviFormula is NOT Fintype

`StaviFormula` is an inductive type with no canonical bound on depth or size. There is no `Fintype` instance for "StaviFormulas of depth <= r". The depth function `stavi_depth` is defined recursively, but there is no enumeration of formulas at bounded depth.

**However**: `stavi_depth A <= r` formulas are not what we need to enumerate directly. What GHR93 uses is that there are finitely many **equivalence classes** of rank-r formulas (formulas whose truth is determined by the NF at appropriate depth). This finiteness comes from `NormalForm`, not from counting StaviFormulas.

### 2.3 The IH Provides Formulas at Depth k

In the `nf_characterizable_by_stavi` induction:
- **Base case (k=0)**: `nf_base_sf` constructs StaviFormulas for depth-0 NFs. Done and correct.
- **IH at depth k**: For each `nf : NormalForm sig k 1`, we have a StaviFormula `char_sf nf` characterizing it.
- **Goal at depth k+1**: For each `nf : NormalForm sig (k+1) 1`, construct a StaviFormula characterizing it.

The IH gives us StaviFormulas for **1-variable NFs at depth k**, but the quantifier part of a depth-(k+1) NF involves **2-variable NFs at depth k** (`NormalForm sig k 2`). The gap between 1-variable and 2-variable is the core difficulty.

---

## 3. Depth Analysis: What Does the U(B,A) Transfer Need?

### 3.1 Game Parameters

In `ghr93_case_II` (CaseAnalysis.lean:1187), the game runs at rank `r` on `ExtendedCarrier M atomMap r`. The rank `r` flows from `ghr93_forward_to_backward_core` (Theorem6.lean:31), where the induction is on `n` (number of rounds) with fixed `r`.

### 3.2 What GHR93 Does (Literature, p.30)

GHR93 Definition 12.8.13 defines:
- `X_t` = conjunction of all rank-r formulas true at t (effectively finite since finitely many equivalence classes)
- `X_{(a,b)}` = disjunction of `X_v` for all v in `(a,b)` (effectively finite since only non-gaps contribute)

In Case II (p.30):
- `A = X_{(a_{n-1}, a_n)}` -- the interval type of `(a_{n-1}, a_n)`
- `C = X_{(a_n, y')}` -- the interval type of `(a_n, y')`
- `B = X_{a_n}` -- the point type of `a_n`
- Then `U(B, A)` has rank `r + 1`, and since tau preserves formulas up to rank `r + 4`, the truth of `U(B, A)` transfers from a_{n-1} to e_{n-1}.

### 3.3 What Depth Formulas Are Needed

The interval type `X_{(a_n, y')}` (called `C` in GHR93) and the point type `X_{a_n}` (called `B`) need to be rank-r formulas. Then `U(B, A)` is rank `r + 1`.

**Key**: These are rank-r formulas in the sense of `stavi_depth <= r`. The tau strategy preserves formulas at rank `r + 4` (since it operates on the sub-interval `[d, y'] / [c, y]` at rank `r` but with a rank offset from the forward game at `r + 4(n+1)`). Actually, in the formalization, tau is `ghr93_duplicator_wins N M atomMap n r d y' c y` -- it preserves formulas at rank `r`.

Wait -- let me re-examine. The handoff states that `U(B,A)` has rank `r + 1`, and tau preserves up to `r + 4`. Looking at SplitPointProps:

```lean
tau : ghr93_duplicator_wins N M atomMap n r d y' c y
```

Tau operates at rank `r`. The formula agreement in `ghr93_winning_condition` checks `stavi_depth A <= r`. So tau preserves StaviFormulas of depth `<= r`.

If `U(B, A)` has `stavi_depth = max(stavi_depth B, stavi_depth A) + 2`, and B and A have depth `<= r`, then `U(B,A)` has depth `<= r + 2`. This is ABOVE what tau preserves (tau preserves depth `<= r`).

**This is a problem.** GHR93 handles this by using sigma_1 and tau at rank `r + 4`, not rank `r`. In the book (p.29): "sigma_1 for G_{n, r+4}" and "tau for G_{n, r+4}". The formalization uses rank `r` for sigma/tau per SplitPointProps.

Let me check the rank parameter more carefully.

Actually, looking at Theorem6.lean line 43-48:
```lean
(h_enough : 1 + 3 * n ≤ rounds_r1)
...
(h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y') :
    ghr93_duplicator_wins N M atomMap n r x' y' x y
```

The input is a `(1+3n)`-round forward game at rank `r`, and the output is an `n`-round backward game at rank `r`. The rank is the SAME. In GHR93, the rank offset `r+4n` is built into the forward game's rank parameter. The formalization decouples rounds and rank.

**Looking more carefully**: The `r` in `SplitPointProps` is the same `r` throughout. The sub-strategies sigma and tau operate at rank `r`. `U(B,A)` at `stavi_depth <= r+2` would NOT be preserved by tau at rank `r`.

**Resolution**: In the actual GHR93 proof structure, the IH gives sigma_1/tau at rank `r+4`, and `U(B,A)` has rank `r+1`, which is within `r+4`. The formalization currently has sigma/tau at rank `r`, not `r+4`. This suggests the rank parameter in the formalization may need adjustment for the U(B,A) approach.

**However**: Looking at the `h_r1_univ` parameter in Theorem6.lean and CaseAnalysis.lean, there IS a mechanism for obtaining higher-rank games. The `h_r1_univ` parameter provides forward games at rank `r'+2` for any `r'`. So one could potentially construct a tau at rank `r+4` from this.

### 3.4 Summary of Depth Requirements

For the U(B,A) transfer in Case II:
- `B = X_{a_n}` (point type): depth `<= r`
- `A = X_{(a_{n-1}, a_n)}` (interval type): depth `<= r`
- `U(B, A)`: depth `<= r + 2`
- Tau must preserve depth `<= r + 2` (or higher)
- Current tau preserves depth `<= r` -- **insufficient** for U(B,A) transfer

This means the U(B,A) approach requires either:
1. Reconstructing tau at a higher rank (r+4), which is available via `h_r1_univ` + IH
2. Or finding an alternative that only uses depth-r formulas

---

## 4. Direct Construction Design: Building X_t Without nf_characterizable_by_stavi

### 4.1 What GHR93 Definition 12.8.13 Actually Says

> `X_t` = conjunction of all temporal L-formulas X of rank <= r with M_r |= X^#(t). This conjunction is effectively finite, as because L is finite there are up to logical equivalence only finitely many distinct formulae of any rank. Hence X_t can be taken to be a temporal formula of rank r.

The "effectively finite" argument is: there are finitely many NFs at depth r, and two formulas of depth <= r that have the same truth value at every point of every structure are logically equivalent. So the number of equivalence classes is bounded by `2^(Fintype.card (NormalForm sig r 1))`.

### 4.2 Direct Construction Strategy

**Idea**: Instead of enumerating StaviFormulas up to equivalence (which requires `nf_characterizable_by_stavi`), use the NF finiteness directly.

For a point `t` in `M_r`, the "type of t" at rank r is determined by:
```
nf_characteristic (extendedStructureWithMu M atomMap r) (2*r) 1 (fun _ => extendPoint t)
```

This is an element of `NormalForm (muSig sig) (2*r) 1`, which is `Fintype`. Two points with the same NF-type agree on all StaviFormulas of depth <= r (by `nf_determines_stavi_truth_depth`).

**The point type formula `X_t`** needs to be a StaviFormula A such that:
```
stavi_temporal_truth M atomMap s A <-> (nf_characteristic ... s = nf_characteristic ... t)
```

This is exactly what `nf_characterizable_by_stavi` provides -- for each NF, a characteristic StaviFormula.

### 4.3 Can We Bypass nf_characterizable?

**Attempt 1: Use the IH at depth k for interval types at the inductive step of Theorem 6.**

The key observation: the U(B,A) transfer in Case II does NOT need arbitrary formula materialization. It needs three specific formulas:
- `B = X_{a_n}` (point type of a_n)
- `A = X_{(a_{n-1}, a_n)}` (interval type between two adjacent selections)
- `C = X_{(a_n, y')}` (interval type of the continuation)

For B (point type): B is a conjunction of all depth-r StaviFormulas true at a_n. If we had a characteristic StaviFormula for the NF of a_n, B would be that formula. Without `nf_characterizable_by_stavi`, we cannot construct B as a single StaviFormula.

**Attempt 2: Use NormalForm finiteness + `nf_determines_stavi_truth_depth` directly.**

We know `nf_determines_stavi_truth_depth`: if two carrier points have the same NF at depth `2*r`, they agree on all StaviFormulas of depth `<= r`. So the "type" is determined by the NF. The NF space is finite.

Could we build a StaviFormula that says "my NF equals nf_0" without going through `nf_characterizable_by_stavi`?

The NF at depth 0 is captured by `nf_base_sf` (atom literals). The NF at depth k+1 extends with quantifier information about depth-k sub-NFs with one extra variable. Expressing "there exists x with 2-variable depth-k NF = sub_nf" as a StaviFormula requires characterizing the joint type of (x, t), which is where the 2-variable-to-1-variable gap bites.

**Attempt 3: Work at the semantic level using `cont_holds` directly.**

Instead of materializing the interval type as a formula, can we work with the Prop-level `cont_holds` predicate throughout the Case II proof?

The trouble is that `U(B,A)` must be a syntactic formula whose truth can transfer across structures via the game. `cont_holds` is a semantic predicate -- it cannot be "evaluated" in another structure via stavi_temporal_truth.

**Attempt 4: The finite disjunction approach.**

GHR93's `X_t` is defined as a conjunction of all rank-r formulas true at t. But we can instead define it as follows:

For each NF `nf : NormalForm (muSig sig) (2*r) 1`, IF we had a characteristic StaviFormula `char_sf nf`, then:
```
X_t = char_sf (nf_characteristic ... t)
```

The "if" is the circularity. Without `nf_characterizable_by_stavi`, we have no `char_sf`.

**Attempt 5: Exploit the IH within the induction on n (game rounds), not on k (formula depth).**

In Theorem 6, the induction is on `n` (game rounds), with `r` fixed. The IH gives `(*)_n`: the forward-to-backward transfer for n rounds. At the step from n to n+1, we need U(B,A) to be a StaviFormula of bounded depth.

But the depth of U(B,A) depends on the depth of B and A. These are rank-r formulas. The rank `r` is not part of the induction -- it's universally quantified. So there is no IH on formula depth available within Theorem 6.

The formula depth IH is in `nf_characterizable_by_stavi` (induction on `k`), which is what we're trying to avoid.

### 4.4 The Circular Dependency Precisely

The dependency chain:
1. `nf_characterizable_by_stavi` (k+1 case) needs the game-theoretic argument from Theorem 6
2. Theorem 6 (Case II) needs the U(B,A) transfer
3. U(B,A) transfer needs formula materialization (X_t as StaviFormula)
4. Formula materialization needs `nf_characterizable_by_stavi` (k case IH)

Wait -- step 4 uses the IH at depth **k**, not k+1. Let me trace this more carefully.

`nf_characterizable_by_stavi` has this structure:
```lean
induction k with
| zero => ... (base case, done)
| succ k ih =>
    -- ih : for all nf : NormalForm sig k 1, exists A : StaviFormula, ...
    -- Goal: for all nf : NormalForm sig (k+1) 1, exists A : StaviFormula, ...
    sorry
```

The sorry in the succ case is where the game-theoretic argument goes. Specifically:
- The IH gives characteristic StaviFormulas for depth-k 1-variable NFs
- The goal needs characteristic StaviFormulas for depth-(k+1) 1-variable NFs
- The depth-(k+1) NF has a quantifier part involving depth-k 2-variable NFs

For the U(B,A) transfer in Theorem 6:
- The game rank `r` corresponds to some formula depth
- B and A need to be formulas at depth `<= r`
- If `r = k` (the formula depth from the `nf_characterizable` induction), then B and A are depth-k formulas
- The IH at depth k gives us characteristic StaviFormulas for depth-k 1-variable NFs

**Key question**: Can `X_t` (the point type) and `X_{(a,b)}` (the interval type) be constructed from the depth-k IH?

`X_t` at rank r: the type of point t is determined by which depth-r StaviFormulas hold at t. With the IH at depth k (= r), we have characteristic StaviFormulas for each `NormalForm sig k 1`. So:

```
X_t = char_sf (nf_characteristic (extendedStructureWithMu ...) (2*k) 1 (fun _ => extendPoint t))
```

But `char_sf` comes from the IH, which gives formulas for `NormalForm sig k 1`, NOT for `NormalForm (muSig sig) (2*k) 1`. The NF space in the bridge uses `muSig sig` (the extended signature with the mu predicate) at depth `2*k`, while the IH works over `sig` at depth `k`.

**This is a mismatch.** The bridge theorem `nf_determines_stavi_truth_depth` works at depth `2*r` over `muSig sig`, but `nf_characterizable_by_stavi` works at depth `k` over `sig`. The IH gives StaviFormulas that characterize NFs over `sig`, not over `muSig sig`.

However, looking at `nf_determines_stavi_truth_depth` more carefully: it says that if two carrier points have the same `NormalForm (muSig sig) (2*r) 1` (evaluated on `extendedStructureWithMu`), then they agree on all StaviFormulas of `stavi_depth <= r`. The NF is over `muSig sig`, but the conclusion is about StaviFormulas evaluated on the original structure.

**The connection**: `stavi_truth_mu_at_point` shows that `stavi_temporal_truth M atomMap p A <-> stavi_temporal_truth_mu M atomMap r (extendPoint p) A`. So StaviFormula truth at a carrier point equals mu-relativized truth at the extended point.

For the IH to be useful: we need, for each distinct truth-pattern of StaviFormulas of depth `<= r`, a single StaviFormula that characterizes it. The number of distinct patterns is bounded by `Fintype.card (NormalForm (muSig sig) (2*r) 1)` (via the bridge), but the patterns themselves are determined by StaviFormula truth, not by muSig NF membership.

**Can we enumerate the truth patterns using the IH?** The IH gives, for each `nf : NormalForm sig k 1`, a StaviFormula. But a depth-k NF over `sig` determines more than just temporal formula truth -- it determines the evaluation of ALL depth-k monadic FO formulas. The StaviFormula truth is a coarser equivalence relation (fewer equivalence classes). So the IH at depth k over `sig` gives MORE formulas than needed, but they are formulas over `sig` with correct temporal truth.

### 4.5 The Direct Construction (If IH is Available)

If we assume the IH at depth k gives `char_sf : NormalForm sig k 1 -> StaviFormula` with correctness, then:

**Point type X_t at rank r (where r >= k for some appropriate relationship)**:

1. Compute `nf_t := nf_characteristic (extendedStructureWithMu M atomMap r) (2*r) 1 (fun _ => extendPoint t)`.
2. The truth of X_t at any point s should be: "s has the same muSig NF as t".
3. But we cannot directly build a formula for "same muSig NF" from the `sig`-level IH.

**Alternative**: Use the `sig`-level NF directly.

For a carrier point p in M, the depth-k NF over sig is:
```
nf_characteristic M k 1 (fun _ => p)
```

This determines `nf_eval_nf M k 1 (fun _ => p) nf` for each nf. By `doets_lemma_1_1`, it determines truth of all depth-k monadic formulas. By the bridge chain (stavi_table_mu), it determines truth of all StaviFormulas with `stavi_fo_depth <= k`.

Since `stavi_fo_depth A <= 2 * stavi_depth A`, depth-k NFs over sig determine truth of StaviFormulas with `stavi_depth <= k/2`. This is weaker than what we need (we need `stavi_depth <= r` where `r` may equal `k`).

Wait, the muSig NF at depth `2*r` is what determines `stavi_depth <= r` truth. But the IH is over `sig`, not `muSig sig`. The `muSig` NF requires understanding the mu predicate, which involves the extended carrier.

**This is the fundamental mismatch**: the NF-to-StaviFormula bridge works via `muSig sig` and `extendedStructureWithMu`, but the IH in `nf_characterizable_by_stavi` works over the original `sig`.

---

## 5. GHR93 Alignment

### 5.1 What GHR93 Actually Does

GHR93 Definition 12.8.13 defines `X_t` as "the conjunction of all temporal L-formulas of rank <= r true at t in M_r". This is a semantic/syntactic definition -- it uses the fact that L is finite to ensure finitely many equivalence classes.

The paper does NOT construct `X_t` via NF characterization. It simply observes that there are finitely many equivalence classes of rank-r formulas (because the language is finite), picks a representative for each class that holds at t, and takes their conjunction.

### 5.2 The "Effectively Finite" Argument

GHR93's argument for finite equivalence classes:
1. A finite temporal language L has finitely many formulas up to logical equivalence at any fixed rank.
2. This follows from the standard normal form theory: there are finitely many non-equivalent FO formulas of bounded quantifier depth over a finite signature.
3. Since the standard translation embeds temporal formulas into FO, finitely many temporal formulas at rank r.

This argument is purely semantic -- it works by counting equivalence classes, not by explicitly constructing representatives. The construction of representatives IS the content of the expressive completeness theorem.

### 5.3 Does GHR93 Need nf_characterizable?

In GHR93's proof of Theorem 12.8.15 (our Theorem 6), the use of `X_t`, `X_{(a,b)}`, etc., presupposes that these are syntactic formulas (temporal L-formulas). The paper takes their existence as given by the finiteness argument.

In the formalization, the finiteness argument corresponds to `nf_characterizable_by_stavi`: for each NF, there exists a characteristic StaviFormula. The proof of this theorem IS the expressive completeness proof (the game argument). So there is a genuine circularity:
- The game argument (Theorem 6) uses formula materialization
- Formula materialization is the expressive completeness theorem

GHR93 resolves this by doing the game argument and formula materialization SIMULTANEOUSLY in one big induction. The paper's proof of Theorem 12.8.15 (the induction on n) constructs the formulas `X_t`, `U(B,A)`, etc., as part of the proof itself, assuming they exist at lower ranks by the IH.

### 5.4 How to Resolve the Circularity in the Formalization

The key insight from GHR93 is that the induction should be structured so that:
- At the base case, `X_t` for rank-0 types is trivially constructible (atom conjunctions -- this is `nf_base_sf`).
- At the inductive step, the IH gives `X_t` for rank-k types, and we use the game argument to construct `X_t` for rank-(k+1) types.

The game argument (Theorem 6) at round n uses formulas of rank r. If we set up the induction so that r = k (the formula depth from the NF induction), then the IH at depth k provides the formulas needed by the game at rank k.

**The resolution**: The induction in `nf_characterizable_by_stavi` at depth k+1 should invoke the game argument (Theorem 6) with r = k (or appropriate function of k). The game argument uses X_t at rank k, which is provided by the IH at depth k. The game argument then produces the backward strategy, which is used to construct the depth-(k+1) characteristic formula.

This means `nf_characterizable_by_stavi` and Theorem 6 are NOT independent. They form a mutual recursion where the k+1 case of nf_characterizable invokes Theorem 6 with formulas from the k case.

---

## 6. Feasibility Verdict

### 6.1 Can Path B (Direct Construction Without nf_characterizable) Work?

**No, not in a straightforward way.** The fundamental issue is:

1. Building `X_t` (point type at rank r) as a StaviFormula requires knowing which StaviFormulas of depth <= r hold at t. The finitely many equivalence classes are determined by `NormalForm (muSig sig) (2*r) 1`, but translating an NF to a StaviFormula IS the content of `nf_characterizable_by_stavi`.

2. There is no shortcut: you cannot enumerate "all StaviFormulas of depth <= r" because StaviFormula is an inductive type with no built-in depth bound. The finiteness comes from the NF theory (which works over muSig and extendedStructure), not from StaviFormula syntax.

3. The IH at depth k within `nf_characterizable_by_stavi` gives formulas over `sig` at depth k. But the game argument needs formulas that distinguish points of `extendedStructureWithMu` (involving the mu predicate). This is a signature mismatch.

### 6.2 What DOES Work: Path A (Reorder to Implement Phase 6 First)

The correct resolution (as identified in the Phase 3C handoff) is:

1. **Prove nf_characterizable_by_stavi's sorry** by mutual induction with the game argument.
2. The k+1 case of `nf_characterizable_by_stavi` calls the game argument (Theorem 6) with formulas from the k case IH.
3. The game argument's Case II uses `U(B, A)` where B and A are built from the k-case characteristic formulas.
4. This unblocks the sel_pn_ord sorry in CaseAnalysis.lean.

**Key dependency clarification**: The sorry in `nf_characterizable_by_stavi` at line 1567 and the sorries in CaseAnalysis.lean at lines 1435/1804 are part of the SAME mathematical argument. They should be resolved together, not separately.

### 6.3 Estimated Effort for the Correct Approach

| Component | Lines | Difficulty |
|-----------|-------|------------|
| Restructure `nf_characterizable_by_stavi` as mutual recursion with Theorem 6 | 200-300 | High |
| Point type formula `X_t` at rank k using k-case IH | 80-120 | Medium |
| Interval type formula `X_{(a,b)}` at rank k using k-case IH | 60-100 | Medium |
| U(B,A) witness extraction in Case II | 80-120 | Medium |
| e_n construction from U(B,A) witness | 40-60 | Medium |
| sel_pn_ord closure (trivial after e_n is chain-constructed) | 20-30 | Low |
| Tau rank adjustment (r to r+4 via h_r1_univ) | 60-100 | Medium |
| **Total** | **540-830** | High |

### 6.4 The Remaining Question: Can nf_characterizable_by_stavi's IH Be Used at Rank r?

The IH gives: for each `nf : NormalForm sig k 1`, a StaviFormula `A` with `stavi_temporal_truth M atomMap t A <-> nf_eval_nf M k 1 (fun _ => t) nf`.

For the game at rank r, we need formulas that distinguish rank-r types. If `r = game_depth sig (k+1)` or similar, and the IH gives depth-k NF characterizations, then the relationship between r and k determines whether the IH formulas are sufficient.

In the `nf_characterizable_by_stavi` induction, the IH gives StaviFormulas for depth-k NFs. The depth-(k+1) case needs to express "exists x such that 2-variable depth-k NF of (x, t) is sub_nf", using Until/Since. The IH gives 1-variable depth-k characteristic formulas. The 2-variable NF encodes both the 1-variable types of x and t AND their order relation AND their cross-predicate relations.

For 2-variable depth-0 NFs: `nf_exist_sf_depth0` already handles this case.
For 2-variable depth-k NFs (k >= 1): The IH gives 1-variable depth-k formulas, but 2-variable depth-k NFs contain joint information (order between x and t, plus which depth-(k-1) 3-variable NFs with one extra variable are realized). This joint information cannot be decomposed into independent 1-variable properties.

**This is precisely why `nf_characterizable_by_stavi` has a sorry at the succ case.** The decomposition of 2-variable NFs into temporal connectives applied to 1-variable formulas IS the game-theoretic argument.

---

## 7. pigeonhole_definable_formula Analysis

### 7.1 What It Provides

`pigeonhole_definable_formula` extracts a single formula `D` from the fact that `cont_holds` fails cofinally below a gap. It does NOT construct the full interval type. It constructs ONE distinguishing formula.

### 7.2 Can It Be Leveraged for U(B,A)?

No. The U(B,A) transfer needs:
- `B = X_{a_n}`: the COMPLETE type of a_n (characterizes a_n's truth on ALL rank-r formulas)
- `A = X_{(a_{n-1}, a_n)}`: the COMPLETE interval type

`pigeonhole_definable_formula` gives one formula that distinguishes specific behavior, not the complete type. Using it for U(B,A) would require that a single distinguishing formula captures enough structure for the backward strategy, which it does not.

### 7.3 Where pigeonhole IS Used

Pigeonhole is correctly used in Claim 1 (gap detection): extracting a single formula D that fails cofinally below a gap, then using K^-(not D) to define the gap. This is a WEAKER requirement than full formula materialization.

---

## 8. Conclusions and Recommendations

### 8.1 Path B (Direct Construction) Is Not Viable

There is no way to construct interval type formulas as StaviFormulas without, in some form, proving `nf_characterizable_by_stavi`. The finiteness of rank-r formula equivalence classes comes from NF theory, and converting NF types to StaviFormulas IS the expressive completeness theorem.

### 8.2 Path A (Implement nf_characterizable First) Is the Correct Approach

The sorry in `nf_characterizable_by_stavi` (StaviCompleteness.lean:1567) and the sorries in CaseAnalysis.lean (1435, 1804, 2015) are mathematically coupled. They should be resolved by:

1. Restructuring `nf_characterizable_by_stavi`'s succ case to invoke the game argument with k-case IH formulas.
2. Within the game argument, constructing B, A, C as StaviFormulas from the k-case IH.
3. Using U(B,A) for the e_n construction in Case II.
4. Adjusting tau's rank to r+4 (available via h_r1_univ and IH on n).

### 8.3 Alternative: Weaken What Case II Needs

If full formula materialization is too costly, an alternative is to restructure Case II to avoid the U(B,A) transfer entirely. This would require finding a different way to construct e_n that does not need cross-game ordering. However, all 20+ attempts documented in Report 41 failed.

### 8.4 The Priority Should Be the `nf_characterizable_by_stavi` Sorry

The single sorry at StaviCompleteness.lean:1567 is the mathematical heart of the entire GHR93 formalization. Closing it (even partially, for the k=0->k=1 step) would unblock both:
- The U(B,A) transfer in Case II (closing sorries at 1435, 1804, 2015)
- The expressive completeness theorem itself
