# Reynolds Theorem 14 (Gap Elimination): Second Opinion

## Executive Summary

Report 07 concluded "we do NOT need expressive completeness because discrete orders have no gaps." This is **incorrect in our setting**. The chronicle's `LimitDomSubtype` is a discrete order with `SuccOrder` and `PredOrder`, but `IsSuccArchimedean` carries a sorry via `succ_cofinal`. Without `IsSuccArchimedean`, a discrete order CAN have gaps: the canonical example is Z+Z (two copies of the integers glued together), which has `SuccOrder` but points across the junction are not connected by finite successor chains. The current `no_gaps_discrete` and `one_class` both use `IsSuccArchimedean` as a hypothesis, so removing it requires a fundamentally different argument.

This report provides the detailed analysis of Reynolds's Theorem 14, maps every use of expressive completeness, studies the separation proof and gap literature, examines the codebase, and proposes a concrete formalization plan.

---

## Task 1: Detailed Proof Walkthrough of Reynolds Lemmas 6-13 and Theorem 14

### Background Setup (Reynolds Section 7, pp.124-125)

Reynolds works in the setting of a **Prior structure** M: a linear temporal structure satisfying all substitution instances of Prior-U and Prior-S. A **contemporaneous equivalence relation** ~M on M is one defined by a monadic formula epsilon(x,y) with two free variables such that:
- ~M is an equivalence relation,
- ~M partitions M into intervals (convex classes), and
- ~ depends only on contemporary properties: a ~M b iff M|[a,b] satisfies epsilon.

Given such epsilon, Reynolds defines rho(x) as a monadic FO formula saying "x's ~-class ends in a gap on the right":

```
rho(x) = exists y > x (not epsilon(x,y))
       AND exists z (y < z < gap AND epsilon(x,z))
       AND forall y (if ... then epsilon(x,y))
```

(The precise formula says: there is a point y > x not in x's class, and there is a "gap" between x's class and y, in that points closer to the gap from below ARE in x's class but points on the other side are not.)

Dually, lambda(x) for left gaps.

### Lemma 6 (p.125)

**Statement**: There is a US-formula R which holds in any Prior structure N exactly at those points whose ~N-class ends in a gap on the right. Dually L.

**Proof**: "By the expressive completeness of U and S" (Theorem 5), rho(x) has a temporal equivalent R valid over all Prior structures.

**Dependencies**: Theorem 5 (expressive completeness of {U,S} for Prior structures).

**Formalization difficulty**: HIGH. The key blocker. Requires either:
- The full separation theorem (Chapter 10.2) + the forward implication of Theorem 9.3.1
- Or a workaround (see Task 7 below)

### Lemma 7 (pp.125-126)

**Statement**: The maximal intervals in which R holds are open intervals which, if bounded, have elements of M as their (excluded) endpoints.

**Proof (right boundary)**: Suppose R holds at t. Then rho holds at t, so R holds for a while after t (until the gap ending t's class). If R does not hold forever after t, Prior-U applied to R gives either (a) a last point of R (impossible since rho guarantees R holds for a while) or (b) a first point of not-R. Case (b) is the claimed excluded endpoint.

**Proof (left boundary)**: Looking left from t, Prior-S gives three cases: (i) R always before t, (ii) a last point of not-R just before, or (iii) a first point of R. Case (iii) leads to contradiction: let s be this first point. s's class can't stretch to the end of the R-interval (it would not end at a gap). So there are other classes after the gap ending s's. "Let B be the temporal formula saying that the ~-class we are now in begins with a point satisfying R AND K-(not R). B exists by expressive completeness." B holds in s's class up to the gap and is false arbitrarily soon after. This contradicts Prior-U applied to B.

**Dependencies**: Lemma 6, Prior-U, **expressive completeness** (to construct B).

**Formalization difficulty**: MEDIUM. The core argument is a Prior-U contradiction. The expressive completeness usage is for constructing B, which is a specific FO formula about the class structure.

### Lemma 8 (pp.125-126)

**Statement**: There is no last class and no first class in any maximal interval of R.

**Proof (no last class)**: The last class in a maximal interval of R would not end at a gap (it would end at the boundary of the R-interval, which by Lemma 7 is a point of M). Hence R would not hold there.

**Proof (no first class)**: "By expressive completeness, the formula rho(x) AND not-exists z (y < z < x AND rho(z)) has a temporal equivalent" which is true only in first classes. If there is a first class, this formula holds up to a gap and is false arbitrarily soon afterwards. Contradicts Prior-U.

**Dependencies**: Lemma 7, **expressive completeness** (to construct the "first class" detector), Prior-U.

**Formalization difficulty**: MEDIUM.

### Lemma 9 (pp.126-127)

**Statement**: (i) If a temporal formula holds somewhere in one ~-class in a maximal interval of R, then it holds somewhere in each ~-class in the interval. (ii) Each pair of ~-classes in a maximal R-interval are elementarily equivalent (as substructures of M).

**Proof of (i)**: Suppose A holds in one class but not in another. "Using expressive completeness and ~, find B which is true at points only if A occurs somewhere in their ~-class." By using not-B if necessary, B holds throughout one class and is false throughout a later class. Choose t in the former. B holds in the whole class, so continues for a while after t. By Prior-U, there is a first point s > t where not-B AND K-(B) holds. So s starts a new class. After s's class's gap, "we can not have B arbitrarily soon after" because of Prior-U. "Let C be the temporal formula saying we are in a class whose left-hand endpoint is also in the class and at that point K-(B) holds." C is true in s's class but false afterwards, contradicting Prior-U.

**Proof of (ii)**: Given a monadic sentence r, relativize it to where epsilon(x,-) holds. Get a formula r* of one free variable. "By expressive completeness this is equivalent to a temporal formula." True exactly throughout classes modeling r. By part (i), it can't vary within the interval.

**Dependencies**: Lemma 8, **expressive completeness** (used three times: for B, for C, and for relativized sentences), Prior-U.

**Formalization difficulty**: HIGH. Multiple uses of expressive completeness, and the argument structure is intricate.

### Lemma 10 (pp.127-128)

**Statement**: Define "bad point" = R or L. Define "bad interval" = maximal interval of R or L. Then: bad points only occur in non-singleton bad intervals; both R and L hold throughout any bad interval; bad intervals have excluded endpoints.

**Proof**: Show L holds wherever R does (by contradiction). If L fails somewhere in a maximal R-interval, some class satisfies not-L throughout (by Lemma 9). This class either includes its left endpoint or begins just after a point of M. The latter is impossible (the preceding class's right end would not be a gap). The former, combined with Lemma 9, implies ALL classes include their left endpoints. "Let B be a temporal formula true at times which are not left-hand endpoints of their ~-classes." B is true in each class from just after the left endpoint up to the gap. B must be false arbitrarily soon after the gap, contradicting Prior-U.

**Dependencies**: Lemma 9, Prior-U. No new expressive completeness usage (B is constructed from temporal formulas already available, not directly from FO formulas).

**Formalization difficulty**: MEDIUM.

### Lemma 11 (pp.128-129)

**Statement**: If a formula B is true for a while at the start of a ~-class in a bad interval, then it holds throughout the bad interval. If a formula is true anywhere in a bad interval, it is true arbitrarily close to each end of each class in the interval.

**Proof**: Suppose B holds for a while after gamma (start of class (gamma, delta)) but not-B holds somewhere in the bad interval. By Lemma 9, not-B also holds somewhere in (gamma, delta). "Using epsilon and expressive completeness, find C true only at points within a ~-class after some not-B." C is false for a while at the beginning of each class and true for a while at the end. C is true up to the gap and false arbitrarily soon after -- contradicts Prior-U.

**Dependencies**: Lemma 9, **expressive completeness** (one usage, for C), Prior-U.

**Formalization difficulty**: LOW-MEDIUM.

### Lemma 12 (pp.128-129)

**Statement**: Let Q- precede the bad interval, Q0 be the bad interval, I be any one ~-class from Q0, and Q+ follow. Let N be the substructure of M whose domain is Q- union I union Q+. Then for all temporal formulas A and all t in N: M satisfies A(t) iff N satisfies A(t).

**Proof**: By induction on the construction of A. Atoms and booleans are immediate. For U(A,B):

**Forward (M -> N)**: 7 cases based on positions of t (in Q-, I, or Q+) and witness s:
1. t < s in Q-: induction hypothesis
2. t in Q-, s in Q0: A somewhere in Q0 implies somewhere in I (Lemma 9). B holds for a while into Q0, so by Lemma 11, B holds everywhere in Q0 and hence in I.
3. t in Q-, s in Q+: B throughout I.
4. t < s in I: straightforward induction.
5. t in I, s later in Q0: B throughout I (Lemma 11). A somewhere in Q0 implies A arbitrarily close to end of I (Lemma 9).
6. t in I, s in Q+: B throughout I.
7. t < s in Q+: induction hypothesis.

**Backward (N -> M)**: 6 cases, symmetric.

**Dependencies**: Lemma 9, Lemma 11. **No expressive completeness usage.**

**Formalization difficulty**: VERY HIGH. This is the most technically demanding piece. 200-300 lines. 14 case splits total. But it is purely structural -- no deep mathematical barriers, just tedious.

### Lemma 13 (p.129)

**Statement**: There can't have been any bad points.

**Proof**: By Lemma 12, R holds in I within N. But N is a Prior structure (any counterexample to Prior-U/S in N would also be one in M, since N is a substructure). By contemporaneity of epsilon, I as a subset of N is all in one ~N-class. R holds in this class, so it's bounded above. Thus Q+ is nonempty and begins with a point q (by Lemma 7). not-R holds at q in M and hence in N. So q is not in I's class in N. The class ends just before q -- not at a gap but at an endpoint. But R says the class ends at a gap. Contradiction.

**Dependencies**: Lemma 7, Lemma 12. **No expressive completeness usage.**

**Formalization difficulty**: MEDIUM.

### Theorem 14 (p.129)

**Statement**: ~M classes do not end at gaps in any Prior structure.

**Proof**: Immediate from Lemma 13.

**Formalization difficulty**: TRIVIAL (one-line wrapper).

---

## Task 2: Map Every Use of Expressive Completeness

### Inventory

| Location | What FO formula is converted? | Quantifier depth | Could k-equiv/doets work instead? |
|----------|-------------------------------|------------------|----------------------------------|
| Lemma 6 | rho(x) = "x's ~-class ends at right gap" | depth 3-4 (nested forall/exists over carrier with epsilon) | Possibly: rho involves only epsilon and order, which are expressible in terms of k-types |
| Lemma 7 | B = "our class begins with a point satisfying R AND K-(not R)" | depth 2-3 (relativized to class using epsilon) | Same: B is built from epsilon + temporal formulas |
| Lemma 8 | "rho(x) AND first in interval" = rho(x) AND not-exists z below with rho(z) | depth 4-5 | Same pattern |
| Lemma 9 (i) | B = "A occurs somewhere in my ~-class" | depth 2-3 (exists y with epsilon(x,y) AND A(y)) | YES: this is exactly "there exists y in [a,b] with table(A)(y)", which is a bounded-quantifier sentence about the subinterval |
| Lemma 9 (ii) | Relativized monadic sentence | depth of original sentence | YES: relativization to a class is exactly what k-types capture |
| Lemma 11 | C = "exists a not-B point earlier in my class" | depth 2-3 | Same pattern as Lemma 9 |

### Key Observation

Every use of expressive completeness converts a specific FO formula phi(x) into a temporal formula A such that in any Prior structure, phi(x) holds at t iff A holds at t. The FO formulas all share a common pattern: they are built from epsilon(x,y) (the contemporaneous equivalence formula), order comparisons, and possibly temporal truth predicates (table translations of other temporal formulas).

The crucial question: **can we avoid temporal formulas entirely and work at the k-type / monadic FO level?**

### The k-Type Alternative

The fundamental purpose of expressive completeness in Reynolds's argument is to feed the resulting temporal formula into Prior-U. Prior-U is stated for temporal formulas:

> Prior-U: U(q-, p) AND F(not p) implies U(not p OR K+(not p), p)

If we could state Prior-U for monadic FO formulas (or normal forms), we would not need expressive completeness at all. The semantic content of Prior-U is:

> "There are no definable gaps": If a definable property holds for a while and then stops, the transition happens at a point (not at a gap).

This can be stated for monadic FO formulas of bounded depth using `doets_lemma_1_1` and `nf_eval_nf`. See Task 7 for details.

---

## Task 3: The Separation Proof (Chapter 10.2)

### Structure

The separation proof for {U,S} over integer time is a 6-layer nested induction:

1. **Layer 1** (Lemma 10.2.8): Induction on junction depth (alternation depth of U/S nesting)
2. **Layer 2** (Lemma 10.2.7): No S-within-U, induction on max nesting depth of U beneath S
3. **Layer 3** (Lemma 10.2.6): Multiple U-subformulas, induction on count n
4. **Layer 4** (Lemma 10.2.5): Single U(A,B) at varying S-nesting depth, induction on depth k
5. **Layer 5** (Lemma 10.2.4): Single S with U beneath, reduce to 8 cases via DNF/CNF
6. **Layer 6** (Lemma 10.2.3): The 8 elimination cases

### The 8 Elimination Cases

Each case handles S(a +/- U(A,B), q +/- U(A,B)) where a, q, A, B are atoms. The cases produce equivalent formulas where U(A,B) appears only at the top level (not under S). Key tools:
- **Lemma 10.2.1**: Distributivity (S distributes over disjunction/conjunction)
- **Lemma 10.2.2**: Negation of U over integer time: not-U(A,B) <-> G(not A) OR U(not A AND not B, not A). This crucially uses **discreteness**.

### Formalization Difficulty Assessment

| Component | Est. LOC | Difficulty |
|-----------|----------|------------|
| Formula representation + separated wff definition | 100 | Low |
| Distributivity lemmas (10.2.1) | 200 | Medium |
| Negation lemmas (10.2.2) | 200 | Medium |
| 8 elimination lemmas (10.2.3) | 800-1200 | High |
| Layers 4-5 (10.2.4, 10.2.5) | 250 | Medium |
| Layers 2-3 (10.2.6, 10.2.7) | 200 | Medium |
| Layer 1 + assembly (10.2.8, 10.2.9) | 200 | Medium |
| Separation -> expressive completeness (9.3.1) | 300 | High |
| **Total** | **2250-2650** | -- |

**Verdict**: Full separation formalization is a massive undertaking (~2500 LOC). This is NOT the recommended approach.

---

## Task 4: Chapter 12 on Gaps

### 12.2 "Gaps in the Flow of Time"

Defines a hierarchy of gap types:
- **Zero-order (isolated) gap**: lies in an otherwise gap-free open interval
- **Alpha-th order gap**: not of lesser order, lies in an open interval containing only gaps of order < alpha
- **Unranked gap**: the forall-player has no winning strategy in the gap game (every neighborhood contains other gaps of comparable complexity)

Key results:
- Corollary 12.2.3: A linear order of cardinality kappa has at most kappa ranked gaps
- Game characterization of unranked gaps

### 12.3 "Connectives to Talk About Gaps"

Defines connectives:
- gamma+(A): "A holds up until a gap but fails arbitrarily soon after"
- gamma_0+(A): "the gap is isolated (as an A-gap)"
- gamma_n+(A): "the gap is of order n" (recursive definition using Stavi connectives)

Key fact: gamma+/- are expressible in {U,S}. gamma_0+/- require Stavi connectives.

### 12.4 "Expressive Power"

**Lemma 12.4.1**: Over flows with only isolated gaps, {U,S} is expressively complete. (Because U' can be defined from gamma_0+ and U.)

**Lemma 12.4.7**: {U, S, gamma_0+/-} is expressively complete over GENERAL linear time.

### Does Chapter 12 Provide a More Direct Route?

**No.** Chapter 12's results are about GENERAL linear time (with arbitrary gaps). For Prior structures, the simpler fact is:

> In Prior structures, there are NO definable gaps at all (Theorem 5 = Reynolds Theorem 5).

Chapter 12's machinery (gamma connectives, gap hierarchies, Stavi connectives) is overkill for our setting. Prior-U already eliminates ALL definable gaps, not just isolated ones.

The relevance of Chapter 12 is conceptual: it confirms that gaps in flows of time CAN be complex (non-isolated, unranked, etc.), which is precisely why the Reynolds Theorem 14 argument is non-trivial even in the discrete case -- without `IsSuccArchimedean`, the chronicle's LimitDomSubtype could have "gaps" in the sense of points not reachable by successor iteration, even though every point has an immediate successor.

---

## Task 5: The 1993 Paper

### Content Summary

The 1993 paper (Gabbay, Hodkinson, Reynolds) proves:

1. **Theorem 3 (= {U,S,U',S'} is expressively complete over all linear time)**: Proved via Ehrenfeucht-Fraisse games in Section 8. The game proof is 10 pages (pp.108-118), using special games G_{n;r} that track decomposition formulas around gaps.

2. **Lemma 2 (flows with only isolated gaps)**: {U,S} alone suffices (U' definable from gamma_0+ and U).

3. **Lemma 3 (negative result)**: {U,S} is NOT expressively complete over general linear time.

4. **Lemma 8 (= Chapter 12's Lemma 12.4.7)**: {U,S,gamma_0+} is expressively complete.

5. **Gap hierarchy** (Lemmas 5-7): Detailed analysis of how gap orders shift under definability transformations.

### Does It Provide a Simpler Proof?

**No.** The game proof in Section 8 is MORE complex than the syntactic separation of Chapter 10.2:
- It uses Ehrenfeucht-Fraisse games with a specialized variant (G_{n;r} games)
- The induction involves formulas of rank r, games of n rounds, and decomposition formulas
- The proof spans 10 dense pages with multiple Claims and Cases

### Does It Provide Direct Gap Elimination?

**No.** The paper focuses on expressive completeness WITH gaps, not on eliminating gaps. Theorem 5 (= Reynolds's Theorem 5) follows trivially from Theorem 3:

> "In Prior structures, U'(A,B) <-> bot, so {U,S} alone is expressively complete."

This is a 5-line derivation once you have Theorem 3, and it is the same result Reynolds uses. The paper does not provide any alternative to Reynolds's Lemmas 6-13 for showing that contemporaneous equivalence classes do not end at gaps.

### Game-Theoretic Tools for Formalization?

The EF games are interesting but HARDER to formalize than syntactic separation:
- Games require defining strategy types, game trees, winning conditions
- The special G_{n;r} games add additional complexity (decomposition formulas, gap handling)
- Corollary 5 (the key bridge from games to FO equivalence) requires Propositions 5 and 7, each of which is a substantial proof

**Verdict**: The 1993 paper does not offer a shortcut for our formalization needs.

---

## Task 6: Existing Codebase Check

### `table_correctness` (Table.lean:268)

```lean
theorem table_correctness {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula -> sig.preds) (t : M.carrier) (phi : Formula) :
    eval M (fun _ => t) (table sig atomMap phi) <-> temporal_truth M atomMap t phi
```

Status: FULLY PROVED (sorry-free). All 8 formula constructors handled.

### `no_gaps_discrete` (IntegerModel.lean:804)

```lean
theorem no_gaps_discrete (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [IsSuccArchimedean M.carrier]
    (a b : M.carrier) (h_diff_class : not (contemp_equiv sig k M a b)) :
    exists (c : M.carrier), contemp_equiv sig k M a c AND
      not (contemp_equiv sig k M a (Order.succ c))
```

Status: Proved but **uses `IsSuccArchimedean`** via `subinterval_finite_of_succ_archimedean`. The proof works by showing the entire subinterval [min a b, max a b] is finite (via succ-Archimedean), hence every sub-subinterval is finite, hence good, contradicting h_diff_class.

### `one_class` (IntegerModel.lean:851)

```lean
theorem one_class (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [IsSuccArchimedean M.carrier] :
    forall (a b : M.carrier), contemp_equiv sig k M a b
```

Status: Proved but **uses `IsSuccArchimedean`** (same finiteness argument). This is the theorem that needs to work WITHOUT `IsSuccArchimedean`.

### `contemp_equiv_is_equiv` (IntegerModel.lean:707)

Status: PROVED, **sorry-free, does NOT use `IsSuccArchimedean`**. Uses SuccOrder and NoMaxOrder only.

### `ChronicleAsPriorModel` (ChronicleExtraction.lean:89-121)

The chronicle prior model bundles:
- `domain_succ_archimedean : IsSuccArchimedean domain` (carries sorry via `succ_cofinal`)
- `prior_UZ_valid`: Prior-UZ formula membership in MCS at every point
- `prior_SZ_valid`: Prior-SZ formula membership in MCS at every point

### `limitDomSubtype_isSuccArchimedean` (ChronicleToCountermodel.lean:1896)

Contains sorry via `succ_cofinal`. This is THE sorry that propagates to `one_class` -> `very_good_implies_good` -> `chronicle_is_good`.

### Key Monadic FO Infrastructure

| Definition/Theorem | File | Status |
|-------------------|------|--------|
| `MonadicFormula sig n` | MonadicFO.lean | Complete |
| `eval` (Tarski satisfaction) | MonadicFO.lean | Complete |
| `NormalForm sig k n` | NormalForm.lean | Complete |
| `nf_eval_nf` | NormalForm.lean | Complete |
| `doets_lemma_1_1` | NormalForm.lean:433 | Sorry-free |
| `KType`, `k_type_of`, `k_equiv` | NEquivalence.lean | Complete |
| `doets_lemma_1_4` (sum preservation) | OrderedSum.lean:34 | Sorry-free |
| `doets_lemma_1_5` (type-matching sums) | OrderedSum.lean:50 | SORRY |
| `orderedSum` | NEquivalence.lean | Complete |
| `table`, `table_correctness` | Table.lean | Sorry-free |
| `temporal_truth` | Table.lean | Complete |
| `operator_depth`, `table_depth_bound` | Table.lean | Sorry-free |
| `k_equiv_of_iso` | IntegerModel.lean:98 | Sorry-free |
| `finite_structures_good` | IntegerModel.lean:173 | Sorry-free |
| `no_boundary_at_successor` | IntegerModel.lean:828 | Sorry-free |
| `good_of_split_at_succ` | IntegerModel.lean:395 | Sorry-free |
| `contemp_equiv_is_equiv` | IntegerModel.lean:707 | Sorry-free |

---

## Task 7: Proposed Formalization Plan

### The Core Problem

We need `one_class` (all points are contemporaneously equivalent) WITHOUT `IsSuccArchimedean`. The current proof trivially derives this from finiteness of intervals. Without `IsSuccArchimedean`, intervals can be infinite even in a discrete order.

Reynolds's genuine proof (Theorem 14) shows that ~M classes do not end at gaps, then uses the discrete structure (successor steps) to bootstrap from "no gap boundaries" to "one class." We need to formalize this argument.

### Recommended Approach: Semantic Prior-U at the k-Type Level

**Key insight**: Reynolds uses expressive completeness solely to feed FO-definable properties into Prior-U. Instead of converting FO formulas to temporal formulas, we can state and use Prior-U directly for k-type properties.

#### Step 1: Define "Prior structure" semantically (NEW)

```lean
/-- A structure satisfies semantic Prior-U at depth k if: for every monadic
    formula phi of depth <= k, if phi holds for a while after t and eventually
    fails, then there is a boundary point (transition at a point, not a gap). -/
def semantic_prior_U (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : Prop :=
  forall (phi : MonadicFormula sig 1) (_h_depth : phi.quantifier_depth <= k),
    forall (t : M.carrier),
      -- phi holds at t and for a while after
      eval M (fun _ => t) phi ->
      -- phi eventually fails
      (exists s, t < s AND not (eval M (fun _ => s) phi)) ->
      -- then there is a "transition point": a last point where phi holds,
      -- or a first point where it fails (no gap)
      (exists c, t <= c AND eval M (fun _ => c) phi AND
        not (eval M (fun _ => Order.succ c) phi)) OR
      (exists c, t < c AND not (eval M (fun _ => c) phi) AND
        eval M (fun _ => Order.pred c) phi)
```

**Estimated effort**: 30-50 lines for definition + basic properties.

#### Step 2: Prove the chronicle satisfies semantic Prior-U (BRIDGE)

Show that `prior_UZ_valid` (syntactic, in MCS) implies `semantic_prior_U` for the chronicle-as-monadic-structure. This requires:

1. Using `table_correctness` to relate `temporal_truth` of Prior-UZ formulas to `eval` of their table translations.
2. Showing that Prior-UZ, instantiated at the table translation of phi, gives us the semantic Prior-U property.

The key connection: Prior-UZ says `Fphi -> U(phi, not phi)`. The table of `Fphi -> U(phi, not phi)` evaluated at t in the chronicle is equivalent (by `table_correctness`) to the temporal truth of this formula, which holds because `prior_UZ_valid` gives us the formula in the MCS.

**Estimated effort**: 80-120 lines. Requires careful navigation of the `table_correctness` bridge but no fundamentally new mathematics.

#### Step 3: Prove "no definable gaps" at the k-type level (NEW)

From semantic Prior-U, derive: if a monadic formula phi of depth <= k holds throughout an interval (a, gamma) approaching a gap gamma from the left, then phi also holds for a while after gamma (i.e., there is no "definable gap" for phi).

This is the k-type version of Reynolds's "no definable gaps" (which follows from Prior axioms). The proof mirrors Reynolds's Theorem 5 argument but works directly with monadic formulas rather than temporal ones.

**Estimated effort**: 40-60 lines.

#### Step 4: Reformulate Reynolds Lemmas 6-13 at the k-type level (CORE)

The key reformulation: instead of constructing temporal formulas R, B, C via expressive completeness, we work directly with monadic formulas and use `doets_lemma_1_1` to transfer truth between k-equivalent structures.

**Lemma 6 (reformulated)**: The monadic formula rho(x) defines a property that can be used directly. We do not need a temporal equivalent R; we just need rho(x) itself as a `MonadicFormula sig 1`.

**Lemma 7 (reformulated)**: Maximal intervals where rho holds have excluded endpoints. Proof uses semantic Prior-U applied to rho directly (since rho has bounded quantifier depth).

**Lemmas 8-9 (reformulated)**: Same arguments but with monadic formulas instead of temporal formulas. Each "by expressive completeness, find B" becomes "let B be the monadic formula..." and the Prior-U application uses semantic Prior-U.

**Lemma 12 (reformulated)**: Model surgery. This proof does NOT use expressive completeness. It uses induction on temporal formulas, but we can reformulate it as induction on monadic formulas (which is actually simpler since monadic formulas have fewer cases: atom, lt, not, and, all, ex -- six cases instead of eight).

**Lemma 13 (reformulated)**: Same argument, using the monadic version of R (= rho).

**Estimated effort per component**:

| Component | Est. LOC | Difficulty |
|-----------|----------|------------|
| `semantic_prior_U` definition | 40 | Low |
| Chronicle satisfies `semantic_prior_U` | 100 | Medium |
| `no_definable_gaps` from `semantic_prior_U` | 50 | Low-Medium |
| rho(x) as `MonadicFormula sig 1` | 40 | Low |
| Lemma 7 (k-type version) | 80 | Medium |
| Lemma 8 (k-type version) | 60 | Medium |
| Lemma 9 (k-type version) | 120 | High |
| Lemma 10 (bad intervals) | 70 | Medium |
| Lemma 11 (propagation) | 50 | Medium |
| Lemma 12 (model surgery) | 250 | Very High |
| Lemma 13 (contradiction) | 50 | Medium |
| Theorem 14 (assembly) | 10 | Low |
| `one_class` without `IsSuccArchimedean` | 30 | Low |
| Update `ChronicleAsPriorModel` | 40 | Low |
| **Total** | **~990** | -- |

### Alternative Approach: Direct k-Type Propagation (Simpler but Less General)

Instead of formalizing the full Reynolds Lemmas 6-13, exploit the specific structure of our setting more directly:

**Observation**: In the chronicle's `LimitDomSubtype`, the order is a subtype of the rationals. The key property we need is not `IsSuccArchimedean` but rather: *every ~M class boundary falls at a successor pair.* Since `no_boundary_at_successor` proves c ~M succ(c) for all c, we need to show there are no OTHER boundaries (i.e., no boundaries at gaps).

**Direct argument**: Suppose a and b are in different ~M classes. Consider the k-type function tau(x) = k_type_of(M|[a,x]) as x moves from a to b. This function can take only finitely many values (since there are finitely many k-types). By `no_boundary_at_successor`, tau(x) = tau(succ(x)) for all x. So tau is constant along successor chains. If the entire interval [a,b] is a single successor chain (i.e., `IsSuccArchimedean`), tau is constant, giving a ~M b. Without `IsSuccArchimedean`, we need to show tau is also constant ACROSS gaps between successor chains.

This is where Prior-U comes in: if tau changes at a gap, there is a definable property (some normal form nf with nf_eval_nf true on one side and false on the other) that exhibits the gap. Prior-U applied to the temporal equivalent of nf (via `table_correctness` in reverse, which is Theorem 5) would give a contradiction. But this circles back to needing expressive completeness.

**However**, we can use the semantic Prior-U approach: Prior-U applied directly to the monadic formula nf (via the semantic formulation) gives the contradiction without needing to convert to a temporal formula.

**This is essentially the same as the main approach above**, but framed differently. The key mathematical content is identical: Prior-U prevents definable gaps, and since k-type transitions are definable, there are no k-type transitions at gaps.

### Effort Summary

| Approach | Total LOC | Calendar Time | Feasibility |
|----------|-----------|---------------|-------------|
| Full Reynolds faithful (with expressive completeness) | 2500-3500 | 3-4 weeks | Low (separation is massive) |
| k-Type reformulation (recommended) | 900-1100 | 1-2 weeks | High |
| Direct k-type propagation (simplified) | 600-800 | 1 week | High (if semantic Prior-U bridge works) |

### Hardest Parts

1. **Model surgery (Lemma 12)**: 200-300 lines regardless of approach. This is the technical core. Building the surgery structure N, proving all cases of the truth preservation induction. No deep mathematical barriers, purely engineering.

2. **Semantic Prior-U bridge**: Connecting the syntactic `prior_UZ_valid` (formula in MCS) to the semantic `semantic_prior_U` (truth of monadic formulas). This requires careful use of `table_correctness` and possibly the truth lemma for the chronicle. The truth lemma has sorries for the U/S cases in TruthLemma.lean, but the parametric truth lemma (in the algebraic pipeline) may provide a clean path.

3. **Lemma 9 (elementary equivalence of classes)**: The most mathematically involved argument after the surgery. Requires careful use of k-types and the propagation argument.

### What a Restricted Expressive Completeness Would Look Like

If the semantic Prior-U approach hits a wall, we could formalize a RESTRICTED form of expressive completeness:

> For every `MonadicFormula sig 1` of quantifier depth <= k, there exists a temporal formula of operator depth <= f(k) that is equivalent in all Prior structures.

This requires:
- Formalizing Theorem 5: {U,S,U',S'} complete -> eliminate U'/S' in Prior structures -> {U,S} complete
- For Theorem 5, we only need: (a) U'(A,B) <-> bot in Prior structures (1-page proof), and (b) {U,S,U',S'} complete (Theorem 4)
- Theorem 4 is the real blocker: it is the full Stavi expressive completeness, proved via separation in Chapter 11 (over ALL linear flows, not just integers)

This is why the semantic Prior-U approach is strongly preferred: it avoids the need for Theorem 4 entirely.

---

## Addendum: Comparison of Sources for Formalizability

### Summary of Three Proof Routes to Expressive Completeness

| Source | Method | Length | Generality | Formalization Difficulty |
|--------|--------|--------|------------|------------------------|
| GHR 1994 Ch 10.2 | Syntactic separation (8 elimination cases, nested induction) | ~25 textbook pages | Integer time | HIGH (~2500 LOC) |
| GHR 1993 Section 8 | Ehrenfeucht-Fraisse games (special G_{n;r} games) | ~10 dense pages | All linear time | VERY HIGH (~3000+ LOC) |
| Reynolds 1994 Theorem 5 | Trivial from Theorem 4 + Prior-U (5 lines) | 0.5 page | Prior structures | DEPENDS on Theorem 4 |

### The Game Approach (1993 Paper, Section 8) -- Detailed Assessment

The game proof works as follows:

1. **Define special games G_{n;r}(M, xy; N, x'y')** (Definition 8.7): Two-round games where forall first chooses n elements from [x,y]_r, exists responds in [x',y']_r, then forall picks one more real point b' in [x',y'], exists responds with b in [x,y]. Winning = same order type + same gap status + same rank-r temporal formulas.

2. **Lemma 11**: Winning strategy for G_{n;r} iff agreement on all n;r-decomposition formulas. This bridges games and FO formulas.

3. **Theorem 6** (the main step): If exists has winning strategies for "enough forward games" G(M,xy;N,x'y'), then she has a winning strategy for the corresponding "backward game" G(N,x'y';M,xy). The proof is by induction on n with three major cases (I, II, III) depending on point positions relative to gaps.

4. **Proposition 7**: Bootstraps from local games to Ehrenfeucht-Fraisse games G^n((M,x),(N,y)).

5. **Corollary 5**: Agreement on rank-g(n+1)+1 temporal formulas implies agreement on all depth-n monadic FO formulas.

6. **Expressive completeness**: For any FO formula phi(x) of depth n, phi is equivalent to a disjunction of rank 1+g(n+1) temporal formulas (selected by model-checking).

**Why this is HARDER to formalize than syntactic separation**:

- Games require defining strategy types as families of functions (Definition 8.6), not just syntactic rewrites
- The game characterization (Proposition 5, EF game theorem) is a non-trivial prerequisite
- The special games G_{n;r} add gap-handling complexity (Definition 8.7, conditions 1-3)
- The main inductive proof (Theorem 6) has three nested Cases (I, II, III) each involving Claims with sub-proofs about gap classification (left-definable, right-definable, point)
- The "left" and "right" formula constructions (Definition 8.5) are intricate recursive definitions with 7 clauses each
- Lemma 9 (bridge between temporal truth at gaps and temporal truth at points) requires reasoning about gap-extended structures M_r
- The rank function g grows super-exponentially: g(n+1) > g(n) + 4f(n) where f(n+1) > (1+3f(n))(2k_n) + 1 and k_n counts inequivalent decomposition formulas

**Verdict**: The game approach is more general but substantially harder to formalize. It introduces new conceptual machinery (games, strategies, decomposition formulas, relativized connectives) that would need to be built from scratch. The syntactic separation approach at least works with formula rewriting, which is closer to existing infrastructure.

### Which Source Provides the Most Direct Route?

**For our specific needs (gap elimination in Prior structures)**, none of the three expressive completeness proofs is the best route. The recommended approach is:

1. **Skip expressive completeness entirely** by reformulating Reynolds's Lemmas 6-13 at the k-type level using semantic Prior-U
2. **Use only existing infrastructure**: `table_correctness`, `doets_lemma_1_1`, `nf_eval_nf`, `k_equiv`
3. **The only new mathematical content needed** is the semantic Prior-U bridge and the model surgery (Lemma 12)

If expressive completeness were forced upon us (which it is not), the syntactic separation of Chapter 10.2 would be the most direct route for integer time, being significantly shorter than the game proof and specialized to the discrete case.

---

## Conclusions

1. **Report 07 was wrong**: Discrete orders without `IsSuccArchimedean` CAN have gaps (in the sense of points unreachable by successor chains). The example Z+Z has SuccOrder but is not succ-Archimedean, and contemporaneous equivalence classes CAN end at the junction. Reynolds's Theorem 14 is genuinely needed.

2. **Expressive completeness is NOT needed if we reformulate at the k-type level**: The key insight is that Prior-U can be stated semantically for monadic formulas of bounded depth, avoiding the need to convert FO formulas into temporal formulas.

3. **The hardest single component is Lemma 12 (model surgery)**: 200-300 lines of case analysis, but no fundamental mathematical barriers.

4. **The recommended approach is the k-type reformulation**: ~1000 LOC, ~1-2 weeks, with the semantic Prior-U bridge as the main technical innovation.

5. **Neither Chapter 12 nor the 1993 paper provides a shortcut**: They address more general settings (arbitrary gaps, gap hierarchies) that are overkill for Prior structures. The Reynolds 1994 argument is already the most direct route.

6. **The game proof (1993) is HARDER to formalize than syntactic separation (Ch 10.2)**: Games introduce additional conceptual machinery (strategies, special games, decomposition formulas, gap-extended structures) with no corresponding infrastructure in the codebase. If expressive completeness were needed, syntactic separation would be preferred.

7. **The semantic Prior-U bridge is the critical innovation**: Converting `prior_UZ_valid` (syntactic) to `semantic_prior_U` (semantic for monadic formulas) is the key step that unlocks the entire argument without expressive completeness. This bridge uses `table_correctness` and the relationship between temporal and monadic FO semantics.

8. **{U,S} alone suffice for integer time because discrete = no gaps at successor boundaries**: The integer flow has no gaps at all (it is Dedekind complete as an order type isomorphic to Z). The issue in our setting is NOT gaps in the flow of time but rather gaps in the succ-reachability structure of the chronicle's LimitDomSubtype -- points that are in the same linear order but cannot be connected by finitely many successor steps. Reynolds's Theorem 14 addresses exactly this: contemporaneous equivalence class boundaries cannot coincide with these "reachability gaps."
