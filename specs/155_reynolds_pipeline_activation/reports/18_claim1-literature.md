# Claim 1 (D-Consistency) Literature Extraction

## Sources

- **Primary**: Gabbay, Hodkinson, Reynolds (1993), "Temporal Expressive Completeness in the Presence of Gaps", Section 8, pages 115--117 (Theorem 6 proof).
- **Secondary**: Gabbay, Hodkinson, Reynolds (1994), *Temporal Logic: Mathematical Foundations and Computational Aspects, Vol. 1*, Chapter 12, Section 12.8, pages 441--446 (Theorem 12.8.15 proof).
- **Tertiary**: Blackburn, de Rijke, Venema (2002), *Modal Logic*, Section 7.2, pages 428--436 (Theorem 7.12 statement only; no EF game proof given).

## 1. Exact Formula Definitions

### 1.1 Context and Parameters

We are proving Theorem 6 (GHR93) / Theorem 12.8.15 (GHR94), the forward-to-backward game transfer theorem. The inductive step proves `(*)_{n+1}`:

> For all `r < omega`, if `x < y` in `M_r`, `x' < y'` in `N_r`, and Duplicator has a winning strategy for `G_{4+3n; r+4(n+1)}(M, xy; N, x'y')`, then Duplicator has a winning strategy for `G_{n+1; r}(N, x'y'; M, xy)`.

Spoiler (playing in N, the *backward* game) chooses `n+1` points:
```
x' < a_0 < a_1 < ... < a_n < y'   in N_r
```
(We may assume all distinct by the inductive hypothesis and Lemma 10/12.8.12.)

### 1.2 Formula A

**Definition** (GHR93 p.115 / GHR94 p.441):
```
A = X_{(a_{n-1}, a_n)}
```

where `X_t` (Definition 8.8 / 12.8.13) is the conjunction of all temporal L-formulas `X` of rank at most `r` such that `N_r |= X^mu(t)`.

When `n = 0`, we take `a_{n-1} = a_{-1}` to be `x'`.

**Meaning**: `A` is a rank-r temporal formula (using relativized connectives) that characterizes the "type" of the interval `(a_{n-1}, a_n)` in `N`. More precisely, `X_{(a_{n-1}, a_n)}` is defined as the disjunction `V_{v in (a_{n-1}, a_n)} X_v` over all non-gap points v in this interval. Since there are finitely many rank-r formulas up to logical equivalence, `A` is effectively a single formula of rank `r`.

### 1.3 Formula C

**Definition** (GHR93 p.115 / GHR94 p.441):
```
C = X_{(a_n, y')}
```

**Meaning**: `C` is the rank-r formula characterizing the "type" of the open interval `(a_n, y')` in `N`. Specifically, `C(u)` holds (in the relativized sense, `N_r |= C^mu(u)`) iff `u` satisfies all rank-r temporal formulas that hold throughout `(a_n, y')`.

**Relationship between A and C**: `A` holds on the interval `(a_{n-1}, a_n)` and `C` holds on `(a_n, y')`. Together they describe the local structure around the last selected point `a_n`.

### 1.4 The Split Point c

**Definition** (GHR93 p.115 / GHR94 p.441):
```
c = inf { t in [x, y] : M |= C(u) for all u in (t, y) }
```

Equivalently: `c` is the infimum of the set `S_C = { t in [x,y] : C holds throughout (t, y) in M }`.

**Key property** (GHR93 p.116 / GHR94 p.441): If `c` is not an element of `M`, then either `c = x` (which is already in `M_r`), or `c` is a gap definable on the right by `C`. In either case, `c` belongs to `M_r` (the extended carrier at rank `r`).

### 1.5 The Split Point c' (= d-bar)

**Definition** (GHR93 p.116 / GHR94 p.441):
```
c' = inf { t in [x', y'] : N |= C(u) for all u in (t, y') }
```

Defined "similarly" in `N_r`. This is what the task description calls `d-bar` (written `d` with overline in GHR93). In GHR94, it is simply called `c'`. We adopt the notation `c'` from GHR94 henceforth.

**Key property**: By the same argument as for `c`, we have `c' in N_r`.

**Ordering**: Clearly `c' <= a_n`, because `C` holds on `(a_n, y')` by construction (the formula `C = X_{(a_n,y')}` was built exactly to describe the type of points in `(a_n, y')`). So `a_n` is in the set `S_C`, and the infimum is at most `a_n`.

## 2. Auxiliary Definitions

### 2.1 Operator K^+ and K^-

These abbreviations appear throughout GHR93/GHR94 (see Lemma 10 / 12.8.12 proof):

```
K^+ X  abbreviates  ~U(T, ~X)    i.e., "X holds cofinally in the future"
                                   equivalently: "there is no future interval where ~X holds throughout"

K^- X  abbreviates  ~S(T, ~X)    i.e., "X holds cofinally in the past"
```

More explicitly:
- `K^+ X` holds at point `t` iff for every `s > t`, there exists `u` with `t < u <= s` and `X(u)`.
- `K^- X` holds at point `t` iff for every `s < t`, there exists `u` with `s <= u < t` and `X(u)`.

In the GHR94 axiomatization (Section 12.6, p.425), the definition is:
```
K^+(q) abbreviates ~U(T, ~q)
```
and similarly `K^-(q)` abbreviates `~S(T, ~q)`.

### 2.2 Operator O

The operator `O` is not separately defined in GHR93 -- it appears implicitly. From context (GHR93 p.116, GHR94 p.442), the statement `M_r |= O(c)` means `M_r |= C'^mu(c)`, where `C'` is evaluated in the relativized structure `M_r`. The letter `O` does not name a standard operator; rather, the text is using it as shorthand for `C'^mu` evaluated at `c`.

**Correction to the OCR/markdown garble**: The OCR text reads "M_r |= O(c)". From the PDF, the actual text is:

> Now the rank `r+1` formula `C' = ~C V K^- ~C` satisfies `M_r |= C'^mu(c)`.

The `O` in the OCR is a misread of `C'^mu`. The statement is that `C'^mu(c)` holds in `M_r`.

### 2.3 Formula C' (C-prime)

**Definition** (GHR93 p.116 / GHR94 p.442):
```
C' = ~C V K^-(~C)
```

**Rank**: `rank(C') = rank(C) + 1 = r + 1`.

**Meaning**: `C'(t)` holds iff either `C` fails at `t`, or `~C` holds cofinally in the past of `t`. Equivalently, `C'(t)` holds iff `t` is NOT in the interior of a maximal interval where `C` holds.

**Why C' holds at c**: By definition, `c = inf S_C`. There are two cases:
1. If `c` is in `S_C`, then `C` holds on `(c, y)`. But by the infimum property, for any `epsilon > 0`, there are points arbitrarily close below `c` where `C` fails (i.e., `~C` holds cofinally in the past of `c`). So `K^-(~C)` holds at `c`, hence `C'(c)` holds.
2. If `c` is not in `S_C` (but is the infimum), then `~C(c)` holds directly, so `C'(c)` holds.

In fact, at the infimum `c`, `C'` holds because `c` is the boundary point where `C` transitions from failing to holding.

## 3. Claim 1: D-Consistency Proof

### 3.1 Statement

**Claim 1** (GHR93 p.116 / GHR94 p.442):

> Consider a play of the game `G_{m; r'}(M, xy; N, x'y')` for arbitrary `r' > r`, `m >= 1`, in which Duplicator uses a winning strategy. Let Spoiler begin by choosing `c` plus `m - 1` other points, and let Duplicator's response to `c` be `d` (plus `m - 1` other points). Then `d = c'`.

(Recall: `c'` is the infimum in `N`, defined in Section 1.5 above.)

### 3.2 Proof Step-by-Step

**Step 1: Formula transfer gives d <= c'.**

Since the strategy is winning, any rank `r'` temporal formula satisfied by one of Spoiler's choices must also be satisfied by Duplicator's corresponding response. Now consider the rank `r+1` formula:
```
C' = ~C V K^-(~C)
```

We showed above (Section 2.3) that `M_r |= C'^mu(c)` holds. Since `r' > r`, the formula `C'` has rank `r+1 <= r'`, so formula transfer applies:
```
M_r |= C'^mu(c)  ==>  N_r |= C'^mu(d)
```

Now we analyze what `N_r |= C'^mu(d)` means:
- Either `~C(d)` holds in `N_r`, which means `d` is not in `S_C(N)`, so `d <= c'` (since `c' = inf S_C(N)` and points outside `S_C(N)` that are in `[x', y']` must be `<= c'` or outside the "C-holds" region).
- Or `K^-(~C)(d)` holds in `N_r`, which means `~C` holds cofinally in the past of `d`. If `d > c'`, then since `C` holds on `(c', y')`, the formula `C` holds in particular on `(c', d)`, contradicting that `~C` is cofinal in the past of `d`. So `d <= c'`.

In either case, `d <= c'`.

**Step 2: Contradiction argument gives c' <= d.**

Suppose for contradiction that `d < c'`. Then by definition of `c'` as the infimum of `S_C(N) = { t : C holds on (t, y') in N }`, there exists a point `d'` in `(d, y')` (specifically in `(d, c')`) such that `N |= ~C(d')`. (If `C` held throughout `(d, y')`, then `d` would be in `S_C(N)` and we'd have `c' <= d`, contradicting `d < c'`.)

Spoiler now challenges at `d'` in the next round (in `N`). Duplicator must respond with some point `b` in `[x, y]` (in `M`). For the response to be winning:
- The point `b` must satisfy the same rank-`r'` formulas as `d'`.
- In particular, since `N |= ~C(d')`, we need `M |= ~C(b)`.
- But `d' in (d, y')` and `d` corresponds to `c` in `M`, so `b` should correspond to a point in `(c, y)` in `M`.
- However, by definition of `c = inf S_C(M)`, the formula `C` holds throughout `(c, y)` in `M`. So `M |= C(b)` for any `b in (c, y)`.
- This contradicts `M |= ~C(b)`.

Therefore Duplicator has no winning response, contradicting the assumption that the strategy is winning.

**Step 3: Conclusion.**

From Steps 1 and 2: `d <= c'` and `c' <= d`, so `d = c'`.

### 3.3 Summary of the Logical Structure

```
1. c := inf {t in [x,y] : M |= C(u) for all u in (t,y)}       -- infimum in M
2. c' := inf {t in [x',y'] : N |= C(u) for all u in (t,y')}   -- infimum in N
3. C' = ~C V K^-(~C)                                            -- rank r+1 formula
4. M_r |= C'^mu(c)                                              -- by infimum property
5. N_r |= C'^mu(d)                                              -- by formula transfer (winning strategy)
6. d <= c'                                                       -- from (5)
7. d < c' ==> exists d' in (d,y') with N |= ~C(d')             -- from negation of infimum
8. Spoiler plays d' ==> Duplicator stuck (C holds on (c,y) in M) -- contradiction
9. c' <= d                                                       -- from (7,8)
10. d = c'                                                       -- from (6,9)
```

## 4. Cross-Reference: GHR94 Chapter 12

GHR94 Section 12.8 (Theorem 12.8.15, pages 441--446) presents the identical proof with cleaner typography:

- **Definitions**: Identical to GHR93. `A = X_{(a_{n-1}, a_n)}`, `C = X_{(a_n, y')}`, `c = inf{...}`, `c' in N_r` similarly.
- **Claim 1** (p.442): Verbatim the same statement and proof. The key formula is again `C' = ~C V K^- ~C` of rank `r+1`.
- **Claim 2** (p.442--443): Strategy restriction to sub-intervals. Also identical.
- **Figure 12.2** (p.442): Shows the interval layout with `~C V K^- ~C` above the interval to the left of `c'`, `C` to the right, `A` between `a_{n-1}` and `a_n`, and `C` between `a_n` and `y'`.

The GHR94 presentation is preferred for formalization because:
1. The numbering is cleaner (Definition 12.8.13 for `X_t`, Theorem 12.8.15 for the main theorem).
2. The notation is consistent with the rest of the chapter.
3. The `left(A, D)` / `right(A, D)` infrastructure (Definition 12.8.6) needed for Cases III/IV is fully developed earlier in the chapter.

## 5. Cross-Reference: BdRV 2002

Blackburn, de Rijke, and Venema (2002), Section 7.2:

- **Theorem 7.12**: States expressive completeness of `{U, S}` over Dedekind complete flows, and `{U, S, U', S'}` over all linear flows. **No proof is given** -- the result is cited from GHR93/GHR94.
- **Definition 7.11**: Defines the Stavi connectives U' and S' informally.
- **Section 7.2 focus**: Uses expressive completeness as a tool to derive axiomatic completeness (Theorem 7.19 for well-ordered flows), not to prove it. The EF game machinery is not reproduced.
- **Conclusion**: BdRV does not contain any alternative proof or additional insight for Claim 1 / d-consistency. It is not useful for this task.

## 6. Mapping to Lean Code

### 6.1 Key Correspondences

| GHR93/94 Concept | Lean Type/Definition | File |
|---|---|---|
| Linear temporal structure M | `OrderedMonadicStructure sig` | `Table.lean` |
| M_r (extended carrier at rank r) | `ExtendedCarrier M atomMap r` | `EFGames.lean` |
| X_t (rank-r type of point t) | `rank_type` / needs construction | `EFGames.lean` |
| X_{(s,t)} (interval type) | `interval_type` / needs construction | -- |
| Formula of rank <= r | `Formula` with rank constraint | `Syntax/` |
| A^mu (relativization to mu) | Relativized temporal truth | `Table.lean` |
| G_{n;r}(M,xy;N,x'y') | `ghr93_duplicator_wins` | `EFGames.lean` |
| Game winning condition | `ghr93_winning_condition` | `EFGames.lean` |
| Spoiler/Duplicator strategies | `game_tuple` / strategy functions | `ExpressivenessGeneral.lean` |
| left(A,D) / right(A,D) | `left_formula` / `right_formula` | `EFGames.lean` |
| SplitPointProps | `SplitPointProps` structure | `ExpressivenessGeneral.lean` |

### 6.2 What Needs to Change

The current implementation (in `ExpressivenessGeneral.lean`) defines `d = a_bwd(n)` (Spoiler's backward selection), making d-consistency trivially true but the downstream properties unprovable. The correct approach from the literature requires:

**Step A: Define the formula C as a rank-r formula.**
```lean
-- C = X_{(a_n, y')} = the conjunction of all rank-r formulas holding on (a_n, y')
-- This is the "interval type" formula from Definition 8.8 / 12.8.13
def formula_C (a_n y' : ExtendedCarrier N atomMap r) : Formula := ...
```
This can be built from the existing `X_t` infrastructure (Definition 8.8 item 1 in GHR93, Definition 12.8.13 item 1 in GHR94): `X_{(s,t)} = V_{v in (s,t), v non-gap} X_v`.

**Step B: Define c and c' as infima.**
```lean
-- c = inf { t in [x,y] : M |= C(u) for all u in (t, y) }
-- c' = inf { t in [x',y'] : N |= C(u) for all u in (t, y') }
```
The infimum exists in `ExtendedCarrier` because either it is a point (in `M`) or a gap definable by `C` on the right (hence in `M_r`).

**Step C: Define C' and prove Claim 1.**
```lean
-- C' = ~C V K^-(~C), rank r+1
-- Prove: M_r |= C'^mu(c)  (infimum property)
-- Prove: formula transfer gives d <= c'
-- Prove: contradiction gives c' <= d
-- Conclude: d = c'
```

**Step D: Refactor SplitPointProps.**
Replace `hd_eq_an : d = a_bwd(n)` with:
- `hd_is_infimum : d = c'` (where `c'` is the infimum in N)
- `hd_le_an : d <= a_n` (consequence of the infimum definition since `a_n in S_C`)
- The d-consistency property becomes a proved theorem (Claim 1), not an axiom.

### 6.3 Infrastructure Dependencies

To implement the above, the following infrastructure is needed:

1. **Interval type formula** `X_{(s,t)}`: Disjunction of `X_v` over non-gap points `v in (s,t)`. The individual `X_t` (point type) should already be available or constructible from Definition 8.8/12.8.13.

2. **Infimum existence in ExtendedCarrier**: Proof that the set `S_C = { t in [x,y] : C holds on (t,y) }` has an infimum in `ExtendedCarrier`. This follows from the gap-enrichment: if the infimum is not a point, it is a C-definable gap (definable on the right by C), hence in `M_r`.

3. **K^- operator**: `K^-(X) = ~S(T, ~X)`. This needs to be defined as a temporal formula constructor. It has rank `rank(X) + 1`.

4. **Formula transfer for the custom game**: If Duplicator wins `G_{m;r'}(M,xy;N,x'y')` and a formula `phi` of rank `<= r'` holds at a point in M, then `phi` holds at the corresponding point in N. This should follow from the game winning condition (item 3 of Definition 8.7 / 12.8.11).

### 6.4 Risk Assessment

- **High confidence**: The proof structure is clear and well-documented in both GHR93 and GHR94. The argument is short (5 lines in the paper).
- **Medium complexity**: The main challenge is the infimum existence proof in `ExtendedCarrier`, which requires showing that C-definable gaps are in `M_r`. This is the entire purpose of the `ExtendedCarrier` construction.
- **Low risk of sorry**: Unlike the current approach (which is provably stuck at d-consistency), the infimum-based approach has a clear proof path at every step.
