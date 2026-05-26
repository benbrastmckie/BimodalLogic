# Literature Analysis: sel-vs-p_n Ordering in GHR93 Claim 1 Case II

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-26
**Focus**: How GHR93 establishes the ordering between selected points e_i and the extension point e_n (corresponding to formalization's sel-vs-p_n), and why the formalization diverges.

---

## 1. The Precise Blocker

The sorry at CaseAnalysis.lean:1594 (Case A) and :1866 (Case B) arise from
goals of the form:

```
(a_init k < extendPoint p_n ↔ resp_tau k < e_n) ∧
(a_init k = extendPoint p_n ↔ resp_tau k = e_n)
```

where:
- `a_init k = a_bwd ⟨k, ...⟩` is Spoiler's k-th backward selection (in N)
- `extendPoint p_n = a_bwd ⟨n, ...⟩` is Spoiler's last backward selection (in N)
- `resp_tau k` is tau's response to `a_init k` (in M)
- `e_n` is the forward game response matching `p_n` (in M)

Available infrastructure:
- `tau_d_sel k`: `(d < a_init k ↔ c < resp_tau k)` -- tau game
- `hord_cd_en_pn`: `(c < e_n ↔ d < extendPoint p_n)` -- d-compatible forward game
- `hd_le_sel k`: `d ≤ a_init k` -- all selections above split point
- `hc_le_rtau k`: `c ≤ resp_tau k` -- tau responses above c
- `hd_le_pn`: `d ≤ extendPoint p_n` -- p_n above split point
- `hc_le_en`: `c ≤ e_n` -- derived from hord_cd_en_pn + hd_le_pn

The `pivot_chain_order'` lemma (EFGameTactics.lean:86) requires a chain
`a ≤ p ≤ b` with known orderings `(a vs p)` and `(p vs b)`, deriving `(a vs b)`.
Both `a_init k` and `extendPoint p_n` satisfy `≥ d`, so d sits BELOW both
rather than BETWEEN them. No chain `a_init k ≤ d ≤ p_n` or `p_n ≤ d ≤ a_init k`
exists, so `pivot_chain_order'` cannot be applied.

---

## 2. How GHR93 Establishes This Ordering

### 2.1 GHR93's Construction of e_n (pp. 117-118 / GHR94 ch12 p. 29-30)

In GHR93, e_n is NOT constructed from a forward game. Instead:

1. Tau is applied to `a_0, ..., a_{n-1}`, delivering `e_0, ..., e_{n-1} ∈ (c, b)_r`.
2. Observe `N_r ⊨ U(B, A)^#(a_{n-1})` where `B = X_{a_n}` and `A = X_{(a_{n-1}, a_n)}`.
3. Since tau preserves rank-(r+4) formulas and `U(B,A)` has rank `r+1 ≤ r+4`,
   transfer gives `M_r ⊨ U(B, A)^#(e_{n-1})`.
4. Unfold `U(B,A)` semantically: there exists `z > e_{n-1}` in M with `B(z)` and
   `A(t)` for all `t ∈ (e_{n-1}, z)`.
5. Define `e_n = z`.

### 2.2 Why the Ordering Is Trivial in GHR93

Spoiler's choices are strictly ordered: `x' < a_0 < a_1 < ... < a_n < y'`
(GHR93 p. 116; GHR94 ch12 p. 27, line 741).

Tau's responses are strictly ordered within (c, b): `c < e_0 < ... < e_{n-1} < b`
(follows from tau's winning condition on (d, y') / (c, y), which preserves
same-order-type; since `a_0 < ... < a_{n-1}` are strictly ordered in (d, y'),
`e_0 < ... < e_{n-1}` are strictly ordered in (c, y)).

Since `e_n = z > e_{n-1}` (from U(B,A) witness), we have:
- `e_k < e_{n-1} < e_n` for all `k < n-1` (by tau ordering + transitivity)
- `e_{n-1} < e_n` (direct from U(B,A) construction)

Since `a_k < a_n` for all `k < n` (Spoiler's choices strictly ordered), the
biconditional `(a_k < a_n ↔ e_k < e_n)` is trivially true: BOTH SIDES TRUE.

Similarly, `a_k = a_n` is always false (distinct selections) and `e_k = e_n` is
always false (e_k < e_n strictly), so `(a_k = a_n ↔ e_k = e_n)` is trivially
true: BOTH SIDES FALSE.

**GHR93 never needs an explicit ordering argument for sel-vs-p_n.** The
ordering follows from the strict monotonicity of both sequences, which in turn
follows from the game construction itself.

### 2.3 The Game Does NOT Include p_n as a Separate Position

In GHR93's backward game `G_{n+1;r}(N, x'y'; M, xy)`:
- Round 1: Spoiler chooses `a_0, ..., a_n` in `[x', y']` (including `a_n = p_n`)
- Duplicator responds with `e_0, ..., e_n` in `[x, y]`
- Round 2: Spoiler chooses `b_sp` in `[x, y]`, Duplicator responds with `b_resp` in `[x', y']`

The point `a_n` (our `p_n`) IS one of the game positions -- it is position `n`
in the selection tuple. It is not a separate "extension point" outside the game.
The winning condition requires same-order-type of the full tuple
`(x, e_0, ..., e_n, b_sp, y)` vs `(x', a_0, ..., a_n, b_resp, y')`.

### 2.4 The Role of the Split Point d

GHR93's split point d (= c' in GHR94) is the infimum of the continuation set.
It serves to partition the interval into two sub-games (sigma on [x', d] and tau
on [d, y']). The ordering argument for sel-vs-p_n does NOT go through d at all
-- it goes through the construction of e_n as a U(B,A) witness above e_{n-1}.

The split point d is used for:
- Claim 1 (d-consistency): showing Duplicator's response to c equals d
- Strategy restriction: splitting the forward game into sigma and tau
- Cross-boundary orderings between sigma-side and tau-side points

But within the tau side (where all a_i and a_n live in Case II), the ordering is
handled by the tau game and the U(B,A) transfer, not by d.

---

## 3. Why the Formalization Diverges

### 3.1 The e_n Construction Divergence

The formalization constructs e_n from the d-compatible forward game (lines
1223-1247 of CaseAnalysis.lean) rather than from U(B,A) transfer. This was a
deliberate architectural choice to avoid materializing formula C and U(B,A) as
StaviFormula objects (see report 22, Section 5.1.1).

The forward game gives:
- e_n matches p_n on rank-r formulas (line 1252)
- Ordering between c and e_n (line 1262: hord_cd_en_pn)
- Ordering between x/y and e_n (lines 1291-1301)

But it does NOT give:
- Ordering between resp_tau(k) and e_n
- Any relationship between the forward game's N-side responses (a'_big) and the
  original Spoiler choices (a_bwd)

### 3.2 The Fundamental Gap

In GHR93, `e_{n-1} < e_n` follows from `e_n` being a U(B,A) witness above
`e_{n-1}`. In the formalization, `resp_tau(n-1)` and `e_n` come from DIFFERENT
games:
- `resp_tau(k)` comes from the tau backward game on [d, y'] / [c, y]
- `e_n` comes from the d-compatible forward game on [x, y] / [x', y']

There is no direct connection between these two games' responses that would
establish `resp_tau(k) < e_n`.

### 3.3 The Padded Big Game's Limitations

The big game (d-compatible forward) has M-side selections `a_pad_big` that
include `resp_tau(0..n-1)` at positions 0..n-1. The N-side responses `a'_big`
have `a'_big(1+3*n) = d`, but `a'_big(0..n-1)` are strategy-determined and
NOT equal to `a_bwd(0..n-1)` in general.

One COULD extract `resp_tau(k) < e_n ↔ a'_big(k) < p_n` from the big game
at positions `⟨1+k, ...⟩` vs `⟨(1+3*n+1)+1, ...⟩`. But since `a'_big(k) ≠
a_init(k)` in general, this doesn't yield `a_init(k) < p_n ↔ resp_tau(k) < e_n`.

---

## 4. Resolution Approaches

### 4.1 Approach A: Prove Both Sides True (Mimicking GHR93 Triviality)

If we can show `a_init(k) < extendPoint p_n` (always true, from Spoiler's
strict ordering) AND `resp_tau(k) < e_n` (from big game + chain), then the
biconditional is trivially `True ↔ True`.

**For `a_init(k) < extendPoint p_n`**: Spoiler's choices are strictly ordered
(`a_0 < ... < a_n`), so `a_bwd ⟨k, ...⟩ < a_bwd ⟨n, ...⟩ = extendPoint p_n`
for `k < n`. This should be available from `ha_bwd` or an ordering hypothesis
on Spoiler's selections. Check whether the formalization requires Spoiler's
choices to be strictly ordered or merely in the closed interval.

**For `resp_tau(k) < e_n`**: Use the big game. The big game has M-side
selection `a_pad_big(k) = resp_tau(k)` and b-position `e_n`. Extract ordering:

```
hord_big ⟨1+k, ...⟩ ⟨(1+3*n+1)+1, ...⟩
```

This gives `resp_tau(k) < e_n ↔ a'_big(k) < p_n`. If `a'_big(k) < p_n` can
be shown (since the strategy's response preserves ordering and d ≤ a'_big(k) ≤
y', with a'_big preserving d-compatibility), then `resp_tau(k) < e_n` follows.

**Risk**: The formalization may not enforce strict ordering of Spoiler's choices
(the game definition uses `inClosedInterval` not strict ordering). The GHR93
remark "we may assume that they are all distinct" (p. 116) is handled by a
separate argument using Lemma 10. If the formalization does NOT require
distinctness, this approach would need an additional case split.

### 4.2 Approach B: Extract resp_tau(k) vs e_n From Big Game Directly

Add extraction of the ordering between `a_pad_big(k)` and the b-position
from the big game:

```lean
have big_sel_b : ∀ (k : Fin n),
    (resp_tau k < e_n ↔ a'_big ⟨k.val, ...⟩ < extendPoint p_n) ∧
    (resp_tau k = e_n ↔ a'_big ⟨k.val, ...⟩ = extendPoint p_n) := by
  intro k
  have h := hord_big ⟨1 + k.val, by omega⟩ ⟨(1 + 3 * n + 1) + 1, by omega⟩
  simp only [game_tuple, ...] at h
  -- M-side: a_pad_big(k) = resp_tau(k), b = e_n
  -- N-side: a'_big(k), b = p_n
  exact h
```

Then use `pivot_chain_order'` with pivot `a'_big(k)` / `resp_tau(k)`:
- Chain on N-side: `a_init(k)` vs `a'_big(k)` (from... unclear)
- Chain on M-side: `resp_tau(k)` vs `resp_tau(k)` (reflexive)

This doesn't work because we don't know the relationship between `a_init(k)`
and `a'_big(k)`.

### 4.3 Approach C: Restructure e_n Construction to Follow GHR93

Replace the forward-game e_n construction with the U(B,A) transfer approach:

1. After tau gives `resp_tau(0..n-1)`, show `N_r ⊨ U(B,A)^#(a_{n-1})`
2. Transfer via tau: `M_r ⊨ U(B,A)^#(resp_tau(n-1))`
3. Extract witness `z > resp_tau(n-1)` with `B(z)` and `A` on `(resp_tau(n-1), z)`
4. Set `e_n = z`

This gives `resp_tau(k) < resp_tau(n-1) < e_n` for all `k < n-1`, and
`resp_tau(n-1) < e_n` directly. The sel-vs-p_n ordering becomes trivial as in
GHR93.

**Estimated effort**: Very high. Requires materializing U(B,A) as a StaviFormula
of rank r+1, proving its semantics, and restructuring ~200 lines.
The formula materialization problem was previously analyzed as infeasible (see
report 22, Section 5.1.1 and report 30, Section 3).

### 4.4 Approach D: Add sel-vs-p_n as a SplitPointProps Field (Recommended)

Add a field to `SplitPointProps` that provides the sel-vs-p_n ordering directly
from the d-compatible forward game, avoiding the formula materialization:

```lean
/-- Ordering between tau selections and the d-compatible game's b-position.
    Derived from the (1+3n+1)-round d-compatible forward game by extracting
    orderings between M-side selections (resp_tau) and M-side b (e_n). -/
h_sel_pn_ord :
  ∀ (resp_tau : Fin n → ExtendedCarrier M atomMap r)
    (e_n : ExtendedCarrier M atomMap r)
    (a_init : Fin n → ExtendedCarrier N atomMap r),
    ... →
    ∀ k, (a_init k < a_bwd ⟨n, ...⟩ ↔ resp_tau k < e_n) ∧
         (a_init k = a_bwd ⟨n, ...⟩ ↔ resp_tau k = e_n)
```

This is mathematically sound because the d-compatible forward game has
`resp_tau(k)` as M-side selections and `e_n` as the M-side b-response. The
ordering data `resp_tau(k) vs e_n` is available from `hord_big`, and `a_init(k)
vs p_n` should follow from Spoiler's strict ordering (or from the N-side big
game response being compatible with the original selections).

**However**, the core difficulty remains: the big game's N-side selections
`a'_big(k)` are NOT `a_init(k)`. So even passing this as a SplitPointProps
field would require resolving the same mathematical gap at the construction
site in `obtain_split_point_props`.

### 4.5 Approach E: Prove a_init(k) < p_n Directly From Game Hypotheses

The most promising approach exploits the GAME STRUCTURE:

In the GHR93 game, Spoiler chooses `a_0 < a_1 < ... < a_n`. The formalization
receives `a_bwd : Fin (n+1) → ExtendedCarrier N atomMap r` with
`ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i)`.

If we can show `a_bwd` is strictly ordered (which is implicit in GHR93 and
may be an explicit or derivable hypothesis), then `a_init(k) < extendPoint p_n`
is immediate. Combined with `resp_tau(k) < e_n` (which can potentially be
derived from the big game as in 4.2), the biconditional reduces to
`True ↔ True`.

**Key question**: Does the formalization enforce that `a_bwd` is strictly
increasing? Check `ghr93_duplicator_wins` and the game definition.

**ANSWER (verified)**: NO. The game definition at CustomGame.lean:285 has
`∀ (a : Fin n → ExtendedCarrier) ...` with only `inClosedInterval x y (a i)`
as a constraint. There is no ordering requirement. The `a_bwd` selections
can be equal or arbitrarily ordered. GHR93 handles this by saying "we may
assume they are all distinct" (p. 116) and reducing to the distinct case
via Lemma 10, but the formalization does NOT make this reduction. So
`a_init(k) < extendPoint p_n` is NOT guaranteed -- they could be equal.

This means Approach E is BLOCKED as stated. The biconditional genuinely
requires proving the ordering relationship, not just exploiting both sides
being true. However, the "both sides true" sub-case DOES work when the
selections happen to be distinct and strictly ordered, which covers the
typical case. The difficulty is the edge case where `a_init(k) = extendPoint p_n`.

**Revised recommendation**: The most viable path is to extract the ordering
from the d-compatible big game by showing that `hord_big` at the appropriate
positions gives exactly `(a_init k < extendPoint p_n ↔ resp_tau k < e_n)`.
This requires either (a) showing `a'_big(k)` relates to `a_init(k)` through
the game structure, or (b) adding a richer d-compatible game that constrains
its N-side selections to align with `a_bwd`.

---

## 5. Other Formalizations and Treatments

### 5.1 Doets (1989)

Doets' "Monadic Pi^1_1 Theories" uses EF-games for monadic second-order
theories of orderings but does not treat the GHR93 game-theoretic proof of
temporal expressive completeness. The ordering argument doesn't appear.

### 5.2 Blackburn, de Rijke, Venema (2002)

Section 7.2 covers Since-Until logic completeness for natural numbers but
uses an algebraic/canonical model approach, not the GHR93 game construction.
The sel-vs-p_n ordering question doesn't arise.

### 5.3 GHR94 (Book Version, Chapter 12)

Chapter 12 of GHR94 gives an expanded treatment of the same proof. The Case II
construction (p. 29-30) is essentially identical to GHR93 but with cleaner
notation. The ordering between `e_i` and `e_n` is still handled by the trivial
argument: both sequences are strictly ordered, so pairwise orderings are all
positive. The relevant passage:

> "Let her first use τ in response to a_0, ..., a_{n-1}. It delivers n points
> e_0, ..., e_{n-1} ∈ (c, b)_r (cf Lemma 12.8.12). Now clearly
> N_r ⊨ U(B, A)^#(a_{n-1}); a_n is a witness to this."

The "cf Lemma 12.8.12" reference confirms that the ordering of e_0, ..., e_{n-1}
follows from the winning condition of tau (same order type), and e_n is placed
above e_{n-1} by construction.

---

## 6. Conclusions and Recommendation

### 6.1 Answer to Question 1: How GHR93 Establishes sel-vs-p_n Ordering

GHR93 does NOT establish the sel-vs-p_n ordering through an explicit argument.
It follows trivially from the construction: Spoiler's choices are strictly
ordered (`a_k < a_n` for all `k < n`), and Duplicator's responses are strictly
ordered (`e_k < e_{n-1} < e_n` from tau + U(B,A) construction). The
biconditional is `True ↔ True`.

### 6.2 Answer to Question 2: Does the Tau Game Include p_n?

No. In GHR93, tau operates on `(d, b')` / `(c, b)` where `b = sup{t : M ⊨ B(t)}`
and `b' = sup{t : N ⊨ B(t)}`. The point `a_n` (= p_n) satisfies `d < a_n < b'`,
so `a_n` is within tau's interval but is NOT a boundary of tau. The point p_n IS
one of Spoiler's selections (position n in the backward game), not a separate
extension point.

### 6.3 Answer to Question 3: Relationship Between Split Point d and Ordering

The split point d is irrelevant to the sel-vs-p_n ordering in GHR93. The
ordering is structural: both `a_k < a_n` and `e_k < e_n` hold by construction,
so d plays no role. The formalization's attempt to route the ordering through
d (via pivot_chain_order') is an artifact of diverging from GHR93's e_n
construction.

### 6.4 Answer to Question 4: Alternative Treatments

No other formalization or textbook treatment of this specific step exists.
Doets (1989) doesn't cover it. Blackburn et al. (2002) uses a different
approach entirely. GHR94 Ch 12 repeats the same proof with identical structure.

### 6.5 Recommended Resolution Path

**Immediate (Approach E from Section 4.5)**: Check whether the formalization
has a strict ordering hypothesis on `a_bwd`. If Spoiler's selections are
known to be strictly ordered, then `a_init(k) < extendPoint p_n` is immediate,
and the goal reduces to showing `resp_tau(k) < e_n` which may be derivable from
the big game ordering data.

**If no strict ordering available**: Add the biconditional as a DIRECT
extraction from the d-compatible big game. The big game has:
- M-side: `(x, resp_tau(0), ..., resp_tau(n-1), c, ..., e_n, y)`
- N-side: `(x', a'_big(0), ..., a'_big(n-1), d, ..., p_n, y')`

Extract `resp_tau(k) < e_n ↔ a'_big(k) < p_n` and then separately show
`a'_big(k) < p_n ↔ a_init(k) < p_n` (which requires understanding the
relationship between the strategy's response `a'_big(k)` and the original
selection `a_init(k)`). If this fails, the remaining option is Approach C
(full GHR93-aligned restructure of e_n construction), estimated at 200+ lines.

---

## Appendix: Key Line References

| Item | File | Lines | Description |
|------|------|-------|-------------|
| `ghr93_case_II` | CaseAnalysis.lean | 1175-1920 | Full Case II theorem |
| Case A sorry | CaseAnalysis.lean | 1594 | Fallthrough in first tactic |
| Case B sorry | CaseAnalysis.lean | 1866 | Fallthrough in first tactic |
| `SplitPointProps` | SplitPoint.lean | 44-111 | Split point structure |
| `h_d_compat_left` | SplitPoint.lean | 101-111 | D-compatible forward game |
| `pivot_chain_order'` | EFGameTactics.lean | 86-92 | Pivot chain lemma |
| `hord_cd_en_pn` | CaseAnalysis.lean | 1262-1289 | Cross-boundary ordering |
| Big game setup | CaseAnalysis.lean | 1226-1247 | a_pad_big and d-compat |
| Tau application | CaseAnalysis.lean | 1204 | resp_tau extraction |
| e_n construction | CaseAnalysis.lean | 1242-1244 | Forward game e_n |
| GHR93 Case II | GHR93 paper | pp. 117-118 | Original proof |
| GHR94 Case II | GHR94 Ch 12 | pp. 29-30 | Book version |
