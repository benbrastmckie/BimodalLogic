# Report 40: Literature Cross-Reference of Sorry Sites

## Scope

Cross-references every remaining `sorry` in the WeakCanonical, BXCanonical, and
Algebraic modules against GHR93 (Sections 2-8), GHR94 (Chapter 12), and
Reynolds 1994 (Sections 5-9). Identifies divergences and traces each sorry to
its paper-side proof step.

---

## 1. Sorry Inventory

### 1.1 ExpressivenessGeneral.lean (11 sorry sites)

| Line | Lemma/Context | Category |
|------|---------------|----------|
| 3901 | `ghr93_claim1_step_left`, edge case: r2_resp = rank_embed(y'), c_inf boundary | Claim 1 |
| 3935 | `ghr93_claim1_step_left`, gap r2_resp case | Claim 1 |
| 4412 | `h_cont_transfer_mr`, multi-round game adaptation | Claim 1 |
| 4424 | `h_mr_resp_le_d`, Direction 1 for multi-round game | Claim 1 |
| 4468 | `h_mr_resp_ge_d`, gap mr_resp case | Claim 1 |
| 4483 | `h_interior_left`, position constraint after rank_down | Claim 1 |
| 4508 | `h_interior_right`, position constraint after rank_down | Claim 1 |
| 5945 | Case II: cross-boundary orderings (p_n/e_n) | Case II |
| 6045 | Case II: same_order_type (tau sub-case) | Case II |
| 6098 | Case II: ordering (dead code fallback) | Case II |
| 7028 | `ghr93_cases_III_IV`, gap detection via Lemma 9 | Cases III-IV |
| 7390 | `ghr93_forward_to_backward_varying`, strategy restriction | Thm 6 outer |

### 1.2 EFGames.lean (1 sorry)

| Line | Lemma/Context | Category |
|------|---------------|----------|
| 10086 | `nf_characterizable_by_stavi`, inductive step | Prop 6-7 / NF bridge |

### 1.3 IntegerModel.lean (1 sorry)

| Line | Lemma/Context | Category |
|------|---------------|----------|
| 863 | `no_gaps_discrete` | Reynolds Thm 14 / Thm 5 |

### 1.4 OrderedSum.lean (1 sorry)

| Line | Lemma/Context | Category |
|------|---------------|----------|
| 56 | `doets_lemma_1_5` (type-matching sum) | Doets 1989 Lemma 1.5 |

### 1.5 TruthLemma.lean (6 sorries)

| Line | Lemma/Context | Category |
|------|---------------|----------|
| 431 | `until_forward_mcs`, intermediate guard | Canonical model |
| 448 | `until_backward_mcs` | Canonical model |
| 483 | `since_forward_mcs`, intermediate guard | Canonical model |
| 497 | `since_backward_mcs` | Canonical model |
| 540 | `truth_lemma`, Until backward branch | Canonical model |
| 556 | `truth_lemma`, Since backward branch | Canonical model |

### 1.6 BXCanonical/Completeness.lean (4 sorries)

| Line | Lemma/Context | Category |
|------|---------------|----------|
| 227 | `countermodel_discrete_enriched` | Chronicle pipeline |
| 256 | `completeness_dense`, non-dense case | Frame-class theory |
| 281 | `completeness_discrete`, dense sub-case | Frame-class theory |
| 290 | `completeness_discrete`, mixed case | Frame-class theory |

### 1.7 BXCanonical/Frame.lean (1 sorry)

| Line | Lemma/Context | Category |
|------|---------------|----------|
| 205 | `bx_le_refl` | Irreflexive semantics |

### 1.8 Algebraic (3 sorries)

| Line | File | Lemma | Category |
|------|------|-------|----------|
| 83 | InteriorOperators.lean | G monotonicity | temp_k_dist |
| 177 | LindenbaumQuotient.lean | ProvEquiv G-fwd | temp_k_dist |
| 182 | LindenbaumQuotient.lean | ProvEquiv G-bwd | temp_k_dist |

**Total: 28 active sorry sites** across 8 files.

---

## 2. Literature Cross-Reference

### 2.1 Claim 1 Cluster (7 sorries in ExpressivenessGeneral.lean)

**Paper**: GHR93 pp.115-116 (Claim 1); GHR94 pp.28-29 (Claim 12.8.15, Claim 1)

**What the paper says**: In any play of G_{m;r'}(M,xy; N,x'y') where Exists uses
a winning strategy, if Forall plays c (the infimum of C-truth) plus m-1 other
points, Exists's response to c is d = c' (the corresponding infimum in N).

**Paper's proof**: Two sentences. (1) The formula C' = ~C v K^-(~C) has
M_r |= C'(c). By winning strategy, N_r |= C'(d), so d <= c'. (2) If d < c'
then Forall picks d' in (d,y') with N |= ~C(d'), and Exists has no winning
response -- contradiction. Hence d = c'.

**Lean divergence**: The formalization replaces the paper's formula C (a rank-r
temporal formula characterizing the type of (a_n, y')) with a PREDICATE
`cont_holds` that captures the semantic content directly. This is the root
cause of the "formula materialization" problem documented in reports 28, 36,
38, 39. The paper's argument works because C is a concrete formula that can
be embedded in game positions; the predicate cannot.

**Specific sorry analysis**:

- **Lines 3901, 3935** (edge cases in Direction 1): The r2_resp = rank_embed(y')
  boundary case and the gap case both need `cont_holds` to be a formula for
  the Prior-axiom / gap-definability argument to close. GHR93 handles these
  via the formula C directly: "As the strategy is winning, any rank r' temporal
  formula satisfied by one of Forall's choices must also be satisfied by the
  corresponding choice of Exists" (p.116). The gap case at line 3935 requires
  GHR93's reasoning that the gap is "defined by D on the left" with D being
  a concrete temporal formula.

- **Lines 4412, 4424, 4468** (multi-round adaptation): These are the same
  argument applied to the (1+3n+1)-round game instead of the 1-round game.
  The paper treats all rounds uniformly: "We will use this argument repeatedly"
  (p.116). The Lean code has separate blocks for 1-round and multi-round with
  index arithmetic changes. The sorry content is identical to the 1-round case.

- **Lines 4483, 4508** (position constraint): After rank_down from r+2 to r,
  the code needs to show that the projected response tuple has its 0th (or
  (1+3n)th) element equal to d. The paper implicitly relies on Claim 1 for
  this: the split point d is determined uniquely by the formula C', and
  rank_down preserves formula agreement. The code uses `rank_down` as a
  black box but cannot extract position tracking from it.

**Divergence assessment**: The formalization has diverged from the paper at a
fundamental level. The paper uses formula C as both a semantic characterizer
AND a syntactic object that participates in game positions. The Lean code
uses a predicate (which captures the semantics) but cannot materialize it as
a formula (which is needed for the game). Report 39 confirmed this
materialization is circular: you need expressive completeness to turn
predicates into formulas, but Claim 1 is part of the proof of expressive
completeness.

**What the paper's approach would look like in Lean**: Define C as
`StaviFormula` (disjunction of rank-r type formulas X_v for v in (a_n, y')),
not as a predicate. Then `cont_holds` is replaced by
`stavi_temporal_truth M atomMap t C`, which can be embedded in game tuples
and compared across rank levels. This requires the finite type enumeration
to be explicitly constructed, which is available via the existing `Xt`
definitions.

### 2.2 Case II (3 sorries at lines 5945, 6045, 6098)

**Paper**: GHR93 pp.117-118 (Case II); GHR94 pp.30 (Case II)

**What the paper says**: All a_0,...,a_n lie in (c',y'), a_n is a point (not a
gap). Define B = X_{a_n}, b = sup{t in (x,y) : M |= B(t)}. Use tau to
respond to a_0,...,a_{n-1}. Then U(B,A) has rank r+1 and is preserved by
tau (which preserves up to rank r+4). So M_r |= U(B,A)(e_{n-1}). Choose
e_n > e_{n-1} with M |= B(e_n) and A holding on (e_{n-1}, e_n).

**Lean status**: Case II is substantially implemented but three ordering
sub-goals remain open:

- **Line 5945**: Cross-boundary orderings between the forward-game point p_n
  and the tau-game points. The paper's proof has these "for free" because the
  forward and backward games share the full interval [x,y] / [x',y']. The
  Lean code has the games on disjoint sub-intervals and needs to cross-reference
  order relations between them. This requires either the full sigma-strategy
  instantiation (giving x' < d <-> x < c) or a restructured game argument.

- **Line 6045**: The `same_order_type` predicate for the (n+1)-round game
  assembled from the n-round tau game and the forward game. The paper handles
  this implicitly by case analysis on where Forall's round-2 choice falls
  relative to e_{n-1} and e_n. The Lean code has the right structure but
  simp/split_ifs do not close all goals automatically.

- **Line 6098**: Dead-code fallback from an earlier attempt; same content as
  6045.

**Divergence assessment**: Moderate. The Case II structure is correct but the
Lean proof needs explicit order-type assembly across two sub-games that the
paper treats as one.

### 2.3 Cases III-IV (1 sorry at line 7028)

**Paper**: GHR93 pp.118-119 (Cases III-IV); GHR94 pp.31-32

**What the paper says**:

Case III: a_n is a left-defined gap (defined by formula D of rank <= r).
Use delta = A ^ left(B,D) (rank r+2). Exists has M_r |= U(delta, A)(e_{n-1}).
Find t < g with M |= delta(t) and A on (e_{n-1}, t]. By Lemma 9 (left formula
correctness), there is a gap e_n in (t,d) defined by D on the left, with
the same relativized rank-r formulas as a_n.

Case IV: a_n is a gap not left-defined. Choose D of rank <= r defining a_n
on the right. Use delta = A ^ ~D ^ U(right(B,D), A) (rank r+3). Analogous
argument using right(B,D) and Lemma 9.

**Lean status**: Entirely sorry'd. The `left_formula` and `right_formula`
functions exist in EFGames.lean, and their correctness lemma (corresponding
to GHR93 Lemma 9 / GHR94 Lemma 12.8.7) has the right type signature. But
the proof body is not implemented.

**Divergence**: None at the architectural level. The Lean code has the right
definitions (left_formula, right_formula) matching the paper's left(A,D) and
right(A,D). The sorry is purely an implementation gap.

### 2.4 Theorem 6 Outer (1 sorry at line 7390)

**Paper**: GHR93 p.115 (Claim 2); GHR94 p.28-29 (Claim 2)

**What the paper says** (Claim 2): If Exists has a winning strategy for
G_{4+3n; r+4(n+1)}(M, xy; N, x'y'), then by restricting sigma to sub-intervals
[x,c] / [x',c'] and adding c to Forall's choices, she gets a winning strategy
for G_{1+3n; r+4(n+1)}(M, xc; N, x'c'). "We will use this argument repeatedly."

**Lean status**: The code at line 7390 needs strategy restriction from the
full interval [x,y] to arbitrary sub-intervals [x1,y1]. This is Lemma 10
(GHR93 p.112 / GHR94 Lemma 12.8.12). The Lean code has `ghr93_duplicator_wins_rank_down`
but not the full Lemma 10 strategy restriction to sub-intervals.

**Divergence**: The paper uses Lemma 10 implicitly ("cf. Lemma 10") while the
Lean code needs it explicitly. The implementation gap is that strategy restriction
to sub-intervals has not been fully formalized.

### 2.5 NF Characterization (1 sorry in EFGames.lean:10086)

**Paper**: GHR93 pp.113-114 (Proposition 6-7, Corollary 5, and the paragraph
after it); GHR94 pp.26-27 (Propositions 12.8.16-12.8.19, Corollary 12.8.19)

**What the paper says**: The final step of expressive completeness works by:
(1) For any monadic formula phi(x) of quantifier depth n, choose a finite set
Psi of temporal formulas of rank 1+g(n+1) that partition the formula space.
(2) Let Psi' = {B in Psi : exists linear M, t with M |= B(t) and M |= phi(t)}.
(3) phi is equivalent over linear time to the disjunction of Psi'.

**Lean approach**: The code takes a different route: instead of the rank-type
partition, it tries to show `nf_characterizable_by_stavi` by induction on k
(the NF depth), aiming to produce a StaviFormula equivalent to each NormalForm.
The base case (k=0) is closed. The inductive step (k -> k+1) requires the
full game-theoretic argument (Theorem 6 + Propositions 6-7 + the composition
Proposition 7 / 12.8.18).

**Divergence**: The Lean approach (NormalForm -> StaviFormula directly) is
faithful to the paper's spirit but packages it differently. The paper goes
monadic formula -> rank-type partition -> temporal disjunction. The Lean code
goes NormalForm -> induction on depth -> StaviFormula. Both ultimately rely on
the same Theorem 6 + composition argument, but the Lean induction requires
expressing the 2-variable sub-NFs as StaviFormulas, which is exactly the
"characterizing the joint type of (x,t)" problem noted in the code comment.

### 2.6 Reynolds no_gaps_discrete (1 sorry in IntegerModel.lean:863)

**Paper**: Reynolds 1994, Theorem 14 (p.129) + Theorem 5 (pp.123-124);
GHR93 is not directly relevant here.

**What Reynolds says** (Theorem 14): If ~M is a contemporaneous equivalence
relation on a Prior structure M, then the ~M-classes do not end at gaps.

**Reynolds's proof**: Defines R = temporal formula true at points whose ~M-class
ends in a gap on the right (exists by Theorem 5 / expressive completeness of
US over Prior structures). Uses Prior-U/Prior-S axioms to show:
- Maximal intervals of R have excluded endpoints (Lemma 7)
- No first/last class in any maximal interval of R (Lemma 8)
- Formula truth transfers across ~M-classes in R-intervals (Lemma 9)
- Model surgery: replacing a bad interval by one of its ~M-classes preserves
  temporal truth (Lemma 12)
- Contradiction: R holds in the surgery model but the ~M-class can't end at
  a gap (Lemma 13)

**Lean status**: The code comment says "BLOCKED: Requires Reynolds Theorem 5
(US expressive completeness over Prior structures)." The Prior-UZ axioms are
formalized (h_prior_UZ, h_prior_SZ parameters) but the expressive completeness
over Prior structures (Theorem 5 / GHR93 Lemma 2 / GHR94 Lemma 12.4.1) is
not formalized. This is the foundation theorem that Reynolds relies on.

**Divergence**: No divergence in architecture. The code correctly identifies
the dependency chain: no_gaps_discrete -> Reynolds Thm 14 -> Reynolds Thm 5
-> Stavi expressive completeness (GHR93 Thm 3). The sorry is a dependency
on an upstream theorem not yet formalized.

### 2.7 Doets Lemma 1.5 (1 sorry in OrderedSum.lean:56)

**Paper**: Doets 1989, Lemma 1.5; Reynolds 1994, Lemma 16 (p.130)

**What Reynolds says** (Lemma 16): If N is countable and very good then it
is good. The proof uses ordered sums where each Z_i =k N|[a_i, a_{i+1}-1]
with finite Z-interval flows. The key property: =k is preserved under
lexicographic sums.

**Lean status**: Doets 1.4 (sum preservation with matched components) is
closed, delegating to `KEquivalenceFramework.sum_preservation`. Doets 1.5
(type-matching variant with different index sets I, J) is sorry'd. The code
comment says "Not on discrete completeness critical path. Required only for
dense case."

**Divergence**: This is correct. In the discrete case, the `one_class` theorem
bypasses Doets 1.5 entirely by going through `no_gaps_discrete` +
`no_boundary_at_successor`. Doets 1.5 would be needed for a dense/general
completeness argument (future work).

### 2.8 TruthLemma Until/Since (6 sorries)

**Paper**: Burgess 1982 / Xu 1988 / GHR94 Chapter 6 (Henkin-style chain
construction for Until/Since guards through intermediate MCS).

**Lean status**: All 6 are "non-critical-path." The parametric truth lemma
handles Until/Since via BFMCS coherence. These need chain infrastructure
from BXCanonical/CanonicalChain.lean ported to ReflCanDomain.

**Divergence**: None. Two parallel approaches exist; the parametric one works.

### 2.9 BXCanonical/Completeness (4 sorries)

**Paper**: No single paper; frame-class-specific completeness engineering.

**Lean status**: Line 227 inherits from chronicle pipeline. Lines 256, 281, 290
are frame-class branching (dense/discrete/mixed cases needing separate
countermodel constructions). **Divergence**: None from literature; engineering.

### 2.10 BXCanonical/Frame.lean bx_le_refl (1 sorry)

**Paper**: BX1 (G(phi) -> phi) gives reflexivity. Under irreflexive semantics
BX1 is invalid. **Divergence**: Intentional (strict < semantics). Architectural.

### 2.11 Algebraic temp_k_dist (3 sorries)

**Paper**: K distribution axiom, derivable from BX axioms. Missing derivation
in DerivationTree framework. **Divergence**: None. Pure implementation gap.

---

## 3. Divergence Summary

### 3.1 Critical Divergence: Formula C vs Predicate cont_holds

The single most significant divergence from the literature is the Claim 1
cluster (7 sorries). The paper defines C as a temporal formula:

  C = X_{(a_n, y')}

which is the disjunction of rank-r type descriptions of points in (a_n, y').
This is a FINITE disjunction (since there are finitely many inequivalent
rank-r formulas) and hence a well-defined temporal formula.

The Lean code instead defines `cont_holds` as a predicate:

  cont_holds a y t := forall A, depth(A) <= r -> (a_n satisfies A <-> t satisfies A)

This captures the same semantic content but CANNOT participate in game tuples
as a formula. When the proof needs "C holds at the gap" or "C is preserved
by the winning strategy," the predicate version has no syntactic object to
embed.

**Resolution path**: Replace `cont_holds` with the explicit StaviFormula
`X_{(a_n,y')}` (the disjunction of all rank-r type formulas true at some point
in (a_n, y')). The `Xt` definitions already exist in the codebase. This would
align with the paper and resolve all 7 Claim 1 sorries simultaneously.

### 3.2 Moderate Divergence: Case II Ordering Assembly

The paper handles Case II orderings by treating the forward and backward games
as operating on the same interval. The Lean code splits into sub-interval
games (sigma on [x',c'], tau on [c',b']) and needs to reassemble ordering
relations across the boundary. This is not wrong but requires explicit
cross-boundary lemmas that the paper does not need.

### 3.3 No Divergence: Cases III-IV, Theorem 6 outer, NF bridge

These sorry sites faithfully follow the paper's architecture. The gap is
purely in implementation, not in proof strategy.

---

## 4. The d_consistency / Claim 1 Deep Trace

### 4.1 Has the C-as-predicate issue been fixed?

**No.** Report 29 identified the issue. Reports 36, 38, 39 analyzed it further.
Report 39 confirmed that formula materialization is circular in the current
architecture. The `cont_holds` predicate remains in the code.

### 4.2 What remains?

The full Claim 1 resolution requires:

1. **Replace cont_holds with formula C**: Define C as the explicit disjunction
   of Xt formulas (X_t for each rank-r type t realized in the interval).
   This is finite by the finiteness of rank-r types.

2. **Prove C captures cont_holds**: Show that `stavi_temporal_truth M atomMap t C`
   iff `cont_holds a y t`. This follows from the definition of X_t as the
   conjunction of all rank-r formulas true at t.

3. **Thread C through the game**: Replace predicate-level arguments with
   formula-level arguments. This affects lines 3901, 3935, 4412, 4424, 4468,
   4483, 4508.

4. **Close the edge cases**: The boundary case (line 3901) and gap cases
   (lines 3935, 4468) become standard once C is a formula, because the
   winning strategy preserves formula truth.

### 4.3 GHR93 Claim 1 step-by-step vs current code

| GHR93 Step | Paper Reference | Lean Status |
|------------|-----------------|-------------|
| Define c = inf{t: M |= C(u) for all u in (t,y)} | p.115 | Done (`c_inf`) |
| Define c' in N similarly | p.115-116 | Done (`d`) |
| C' = ~C v K^-(~C); M_r |= C'(c) | p.116 | Partially done (predicate version) |
| Winning strategy => N_r |= C'(d), so d <= c' | p.116 | Direction 1: lines 3335-3937 (mostly done, 2 sorries) |
| If d < c' => contradiction | p.116 | Direction 2: lines 3938-4250 (mostly done, 0-1 sorry) |
| Therefore d = c' | p.116 | Follows from above |
| Strategy restriction to [x,c]/[x',c'] (Claim 2) | p.116 | Line 7390 sorry |
| IH gives backward strategies sigma, tau | p.116 | Done |
| Four-case split | pp.117-119 | Cases I-II partially done, III-IV sorry'd |

---

## 5. NF Characterization Trace

### 5.1 GHR93 Propositions 6-7 vs nf_characterizable_by_stavi

**Paper's route** (GHR93 pp.113-114):

1. Prop 6: If x,y satisfy the same rank r+4n+1 formulas, then Exists has
   winning strategies for the future/past n;r-games.
2. Prop 7: Composing sub-interval strategies gives an EF game strategy.
3. Corollary 5: Same rank g(n+1)+1 formulas => same monadic sentences of
   quantifier depth <= n.
4. Final argument: Take Psi = rank partition of temporal formulas at rank
   1+g(n+1). Then phi is equivalent to V Psi'.

**Lean's route** (EFGames.lean, lines 10060-10110):

1. Induction on k (NF depth).
2. Base case (k=0): directly construct StaviFormula from atomic NFs. DONE.
3. Inductive step (k+1): needs the 2-variable sub-NFs to be expressible
   as StaviFormulas. This is exactly the quantifier elimination step.

**Is the approach faithful?** Yes, at the level of mathematical content. Both
routes need Theorem 6 (forward-to-backward) as the core engine. The Lean
route packages it as "NormalForm depth k+1 has a StaviFormula equivalent"
while the paper packages it as "rank types determine monadic truth." The
difference is organizational, not mathematical.

**What blocks the inductive step?** The 2-variable NFs. A rank-(k+1) formula
phi(x) may contain existential quantifiers: exists y, psi(x,y). Expressing
psi(x,y) temporally requires the game argument (Theorem 6) applied to the
2-variable structure. The current game infrastructure operates on 1-variable
structures (intervals [x,y] in a linear order). Extending to joint types
of (x,t) pairs is the gap.

---

## 6. Summary of Required Work

### Critical path (blocks expressive completeness):
1. **Formula C materialization** (Claim 1): Replace cont_holds predicate with
   explicit formula C. Estimated: 300-500 lines.
2. **Case II ordering closure**: Close 3 remaining order-type goals. Estimated:
   100-200 lines.
3. **Cases III-IV**: Implement left/right gap detection (Lemma 9 correctness).
   Estimated: 200-300 lines.
4. **Strategy restriction** (line 7390): Implement full Lemma 10 for sub-intervals.
   Estimated: 100-200 lines.
5. **NF inductive step** (EFGames:10086): Implement the quantifier elimination
   via game composition. Estimated: 300-500 lines.

### Reynolds pipeline (blocks integer completeness):
6. **no_gaps_discrete** (IntegerModel:863): Requires upstream Theorem 5
   (US expressive completeness over Prior structures), which requires
   Stavi expressive completeness. Circular dependency: this cannot be
   resolved until items 1-5 are done.

### Non-blocking:
7. **TruthLemma Until/Since** (6 sorries): Non-critical-path. Parametric truth
   lemma handles these.
8. **BXCanonical/Completeness** (4 sorries): Frame-class branching, not on
   the GHR93/Reynolds critical path.
9. **bx_le_refl**: Architectural (irreflexive semantics).
10. **temp_k_dist** (3 sorries): Missing derivation, straightforward.
11. **Doets 1.5**: Dense case only, not on discrete critical path.

### Dependency order:
Items 1-4 -> Item 5 -> Item 6 -> Integer completeness

---

## 7. Recommendations

1. **Highest priority**: Resolve the formula C materialization (item 1). This
   is the single change that would unlock the most sorry closures (7 direct +
   downstream effects on Cases III-IV and strategy restriction).

2. **Second priority**: Close Case II ordering goals (item 2). These are
   "almost done" -- the proofs have the right structure but need explicit
   cross-boundary order lemmas.

3. **Third priority**: Implement Cases III-IV (item 3). These are architecturally
   correct and just need the Lemma 9 proof body.

4. **Defer**: NF inductive step (item 5) and no_gaps_discrete (item 6) depend
   on items 1-4 and are the largest remaining pieces.
