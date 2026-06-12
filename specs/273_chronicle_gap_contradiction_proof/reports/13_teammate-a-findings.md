# Teammate A Findings: Lemma 3.2.2 Formalization Design

**Artifact**: 13a
**Date**: 2026-06-12
**Focus**: Cleanest, most general formalization of Rabinovich Lemma 3.2(2)

---

## 1. Precise Mathematical Content of Lemma 3.2(2)

From Rabinovich 2014, p. 4 (Definition 3.1 + Lemma 3.2):

**Definition 3.1**: An EA (exists-forall) formula over a signature Sigma is:
```
psi(z_0, ..., z_m) := exists x_n ... exists x_1 exists x_0
  (AND_{k=0}^{m} z_k = x_{i_k})          -- free vars placed among witnesses
  AND (x_n > x_{n-1} > ... > x_1 > x_0)  -- strict ordering
  AND (AND_{j=0}^{n} alpha_j(x_j))        -- point types at each witness
  AND (AND_{j=1}^{n} (forall y)^{<x_j}_{>x_{j-1}} beta_j(y))  -- interval types
  AND (forall y)_{>x_n} beta_{n+1}(y)     -- unbounded right tail
  AND (forall y)^{<x_0} beta_0(y)         -- unbounded left tail
```

The formula has m+1 free variables z_0,...,z_m placed at positions i_0,...,i_m
among the n+1 witnesses x_0,...,x_n (so m+1 witnesses are "dummy" free-variable
placeholders, and the remaining n-m are genuine existential witnesses).

**Lemma 3.2(2)** (the key result): Every EA formula psi(z_0,...,z_m) is
equivalent to a CONJUNCTION of EA formulas, each with AT MOST TWO free variables.

**The decomposition argument**: Given z_0 < z_1 < ... < z_m as the free variables
(they appear in fixed positions among the witnesses), the formula psi decomposes
along the "gaps" between consecutive free variables. Specifically:
- The segment before z_0 (left tail) contributes a formula with z_0 as only free var
- Each segment (z_i, z_{i+1}) contributes a formula with z_i and z_{i+1} as free vars
- The segment after z_m (right tail) contributes a formula with z_m as only free var
- Point types at each z_i appear in TWO formulas (as right endpoint of left segment,
  left endpoint of right segment) but the conjunction still works

The key insight: **point types and interval types are LOCAL**. The type alpha_j at
a witness x_j only depends on what holds AT x_j, and the type beta_j on (x_{j-1}, x_j)
only depends on what holds BETWEEN those two points. There is NO interaction across
the free variables once positions are fixed.

**No density or completeness needed**: Lemma 3.2(2) is PURELY COMBINATORIAL. It
holds over any linear order. The only structural property of the ordering used is
that the free variables z_0,...,z_m are already in order -- which is given as part
of the formula semantics (the ordering constraint is explicit in Definition 3.1).

---

## 2. The Decomposition is CONSTRUCTIVE

The decomposition is fully constructive. Given an EA formula psi(z_0,...,z_m) with:
- Free variable positions i_0 < i_1 < ... < i_m in the combined sequence
- n+1 total positions (witnesses + free variables)

We can EXPLICITLY BUILD the 2-var pieces. For consecutive free variables z_k and z_{k+1}
(at positions i_k and i_{k+1}), the bracket formula between them uses:
- The witnesses strictly between positions i_k and i_{k+1} (those with position j such
  that i_k < j < i_{k+1})
- Point types from the original formula at those witnesses
- Interval types from the original formula on those segments

The formulas for the tails (before z_0 and after z_m) use a single free variable.

---

## 3. Generality Level Appropriate for CSLib

The result should be stated for **arbitrary strict linear orders** without density
or completeness. The mathematical content is:

> Over any strict linear order (M, <), every EA formula in the sense of Definition 3.1
> is equivalent to a conjunction of EA formulas with at most 2 free variables.

For the existing codebase, the relevant instantiation is:
- M is an `OrderedMonadicStructure sig`
- EA formulas are represented by `VecEAFormula m n` (m free vars, n witnesses)
- 2-var EA formulas are represented by `VecEA2 n` (via `BracketFormula n`)
- The conjunction target is a LIST of VecEA2 formulas (with different witness counts)

This is the RIGHT level of generality for CSLib: it captures the combinatorial
structure without depending on the specific Prior/Dedekind structure of the order.

---

## 4. VecEAFormula.holds: Proposed Design

**Critical gap**: `VecEAFormula m n` has NO semantic evaluation function.
`BracketFormula n` does (via `IntervalPattern.holds`). This is the central missing piece.

### 4.1 What VecEAFormula.holds Must Capture

An `VecEAFormula m n` with `m` free variables and `n` existential witnesses describes:
- An environment `env : Fin m → M.carrier` providing the free variable values
- Existential witnesses `w : Fin n → M.carrier` (strictly increasing)
- The combined sequence of m+n points in the linear order
- Point types at each WITNESS position (not at free variable positions)
- Interval types on each of the m+n+1 segments between consecutive combined elements

The `freePos : FreeVarPositions m n` structure in `VecEAFormula` stores where each
free variable sits in the combined order. This already encodes the ordering constraint.

### 4.2 Proposed Type Signature for VecEAFormula.holds

```lean
/-- Evaluate a vec-EA formula at a given environment.
    Holds iff there exist strictly increasing witness values w : Fin n → M.carrier
    such that:
    (1) All n witnesses lie between the outermost free variables (or unbounded if m=0).
    (2) The combined sequence (free vars + witnesses, ordered by freePos) is strictly
        increasing with witnesses in their correct relative positions.
    (3) Point types hold at each witness position in the combined sequence.
    (4) Interval types hold at all points in each segment between consecutive combined
        elements (and in the unbounded tails if no bounding free variable exists). -/
def VecEAFormula.holds {sig : MonadicSignature} {m n : Nat}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (vf : VecEAFormula m n)
    (env : Fin m → M.carrier) : Prop :=
  -- The environment must be strictly monotone (free variables in order)
  StrictMono env ∧
  ∃ w : Fin n → M.carrier,
    -- Witnesses are strictly increasing
    StrictMono w ∧
    -- The combined sequence is consistent with freePos
    (∀ i : Fin m, ∀ j : Fin n,
      vf.freePos.pos i < ⟨m + j.val, by omega⟩ ↔ env i < w j) ∧
    -- Point types hold at each witness
    (∀ j : Fin n, vf.witnessTypes j |>.eval_at M atomMap (w j)) ∧
    -- Segment types hold on each segment
    (∀ seg : Fin (m + n + 1),
      ∀ y : M.carrier,
        -- y is in segment seg (between element seg-1 and element seg in combined order)
        combinedLowerBound vf env w seg y →
        combinedUpperBound vf env w seg y →
        vf.segmentTypes seg |>.eval_at M atomMap y)
```

Where `combinedLowerBound`/`combinedUpperBound` are helper functions that extract
the actual lower/upper bound point from the combined sequence for a given segment index.

### 4.3 Concrete Implementation of the Combined Sequence

The clean way to implement this is via a helper that reconstructs the combined
sequence from `env`, `w`, and `freePos`:

```lean
/-- Extract the k-th element of the combined sequence (free vars + witnesses,
    sorted by position). Returns the value at position k in the linear order. -/
noncomputable def VecEAFormula.combinedElem {sig : MonadicSignature} {m n : Nat}
    (vf : VecEAFormula m n) (env : Fin m → M.carrier) (w : Fin n → M.carrier)
    (k : Fin (m + n)) : M.carrier :=
  -- Determine if position k is a free variable position or a witness position
  if h : ∃ i : Fin m, vf.freePos.pos i = k
  then env (Classical.choose h)
  else
    -- Find which witness this is (complement of free var positions)
    let witnessIdx := witnessIndexOf vf.freePos k  -- maps witness position to Fin n
    w witnessIdx
```

This approach requires a `witnessIndexOf` function that maps positions not in the
range of `freePos.pos` to `Fin n`. This is a finite computation that can be made
computable.

### 4.4 Simpler Alternative: Hold Via Witness Lists

For the specific purpose of PROVING Lemma 3.2.2, a SIMPLER holds definition suffices:
operate directly on the data rather than through position arithmetic. The segment
conditions can be expressed using the combined sequence once it is built.

---

## 5. Proposed Lean 4 Type Signature for Lemma 3.2.2

### 5.1 The Main Theorem

```lean
/-- Rabinovich 2014, Lemma 3.2(2): Every EA formula with m > 2 free variables
    is equivalent to a conjunction of EA formulas with at most 2 free variables.

    The decomposition is constructive: given a VecEAFormula m n, we produce
    a list of VecEA2 formulas (2-free-variable bracket formulas) whose
    simultaneous truth is equivalent to the original formula.

    The decomposition works over ANY strict linear order; no density or
    completeness assumptions are needed. -/
theorem VecEAFormula.decompose_to_two_free {sig : MonadicSignature} {m n : Nat}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (vf : VecEAFormula m n)
    (env : Fin m → M.carrier)
    (h_env_mono : StrictMono env) :
    vf.holds M atomMap env ↔
    ∀ seg ∈ vf.decompose,
      seg.2.holds M atomMap (env (seg.1.1)) (env (seg.1.2))
```

where `vf.decompose : List ((Fin m × Fin m) × (Σ k, VecEA2 k))` produces the list
of adjacent free-variable index pairs and their bracket formulas.

### 5.2 The Decomposition Function

```lean
/-- Construct the list of 2-variable bracket segments from a VecEAFormula.
    For each pair of adjacent free variable indices (i, i+1), produces the
    VecEA2 formula describing what must hold between env(i) and env(i+1).
    Also produces 1-variable formulas for the left and right tails (using
    VecEA2 with degenerate endpoint via z_0 as a sentinel, or handled as a
    separate case). -/
noncomputable def VecEAFormula.decompose {m n : Nat}
    (vf : VecEAFormula m n) :
    List ((Fin m × Fin m) × (Σ k, VecEA2 k)) := ...
```

### 5.3 Segment Extraction Helper

```lean
/-- Extract the bracket formula for the sub-interval between free variable
    positions i and i+1. Uses only the witnesses whose combined-sequence
    position lies strictly between freePos(i) and freePos(i+1). -/
noncomputable def VecEAFormula.segmentBracket {m n : Nat}
    (vf : VecEAFormula m n) (i : Fin (m - 1)) :
    Σ k, VecEA2 k := ...
```

---

## 6. The Witness Partition Map

The central combinatorial object is the PARTITION of the n witnesses among the
m+1 segments (before z_0, between z_0 and z_1, ..., after z_{m-1}).

### Representation

For each witness j : Fin n, define its segment assignment:
```
segOf(j) : Fin (m + 1)
```
determined by the combined ordering: witness j goes to segment s iff the combined
position of witness j lies in the s-th segment of the combined sequence.

Concretely: since `freePos.pos : Fin m → Fin (m + n)` specifies where free
variables sit, the witnesses are the positions NOT in the range of `freePos.pos`.
We can enumerate them in order as `witnessPos : Fin n → Fin (m + n)`.

Then `segOf(j)` = number of free variable positions k < witnessPos(j).

This is FINITE and COMPUTABLE.

### Alternative: Explicit Fin n → Fin (m+1) Map

The decomposition function can be parameterized by:
```lean
structure WitnessPartition (m n : Nat) where
  segOf : Fin n → Fin (m + 1)  -- which segment each witness belongs to
  mono  : ∀ i j, i < j → segOf i ≤ segOf j  -- witnesses ordered within segments
```

This is derivable from `FreeVarPositions m n` deterministically.

---

## 7. What Formulation Should Be Used: VecEAFormula or BracketFormula Directly?

### Recommendation: State for VecEAFormula, Prove via BracketFormula

The theorem should be stated for `VecEAFormula m n` because:
1. This is the structure that carries the position data (`freePos`)
2. The decomposition is a property of the full formula structure
3. It matches the mathematical level of Definition 3.1

The proof should proceed by:
1. Defining `VecEAFormula.holds` using the combined sequence
2. Proving the decomposition by showing each segment's witnesses are independent
3. The 2-var output is naturally a `BracketFormula` wrapped in `VecEA2`

The CONCLUSION of Lemma 3.2.2 should be a `List (Σ k, VecEA2 k)` where each
element is a 2-variable bracket formula, and the original formula is equivalent
to the conjunction of their semantics.

---

## 8. How Lemma 3.2.2 Feeds into Prop 4.3

**Prop 4.3** (every FOMLO formula is V-EA over Dedekind complete chains) uses
Lemma 3.2.2 as follows:

```
FOMLO formula phi(x_1,...,x_m)
  --[structural induction]--> conjunction of EA formulas with ≤ 2 free vars
  --[Lemma 3.2.2]--> conjunction of 2-free-var EA formulas
  --[Prop 4.2 negation closure]--> V-EA formula (with 2 free vars)
  --[Lemma 3.4 existential closure]--> V-EA formula for ∃ quantifiers
  --[Prop 3.5]--> temporal formula
```

The ROLE of Lemma 3.2.2 in the task 273 context is to enable PROP 4.3, which
in turn provides the structural induction that avoids the P1/P2 circularity.
Instead of the inductive NF approach (which creates circular dependencies), the
structural induction on formula size terminates cleanly.

**Key use in the contradiction proof**: The blocked sorry at NegationClosure.lean:1371
becomes irrelevant if we can prove: "every MonadicFormula is equivalent to a
V-EA formula over Prior structures" by structural induction using Lemma 3.2.2 +
Prop 4.2 + Lemma 3.4. This gives P1(k) for ALL k simultaneously without ever
needing the backward direction of nf_exist_formula_nested.

---

## 9. VecEAClosure.lean: What Already Exists

The existing `VecEAClosure.lean` proves:
- **Lemma 3.2.1** (in spirit): `BracketFormula.conj_to_bracket_exists` -- conjunction of two bracket
  formulas implies existence of a combined bracket formula. Note this is WEAKER
  than what we need (it just finds SOME bracket formula, not a canonical conjunction).
- **Lemma 3.2.3**: `BracketFormula.existsBounded_right` -- bounded existential over a
  bracket formula produces a larger bracket formula (adds the quantified variable as a
  new witness in the bracket formula).

**What is MISSING**: There is NO `VecEAFormula.holds` definition and NO Lemma 3.2.2
formalization. The `VecEAFormula` type is defined but not equipped with semantics.

---

## 10. Doets 1989 Assessment

Doets 1989 works with monadic Pi_1^1 theories using EF-game methods. The approach is
game-theoretic (Ehrenfeucht-Fraisse), not the interval-decomposition approach of
Rabinovich. Doets does NOT provide a cleaner formulation of Lemma 3.2.2.

**Conclusion**: For Lemma 3.2.2, the Rabinovich formulation is the right source.
Doets is relevant for a completely different proof strategy (Path C in the handoff).

---

## 11. Estimated Line Counts

| Component | Estimated Lines | Notes |
|-----------|----------------|-------|
| `VecEAFormula.holds` definition | 30-50 | Requires `combinedElem` helper |
| `combinedElem` + helpers | 40-60 | Position arithmetic in Fin (m+n) |
| `WitnessPartition` extraction | 30-40 | From FreeVarPositions |
| `VecEAFormula.decompose` | 50-80 | Constructs the segment list |
| `segmentBracket` helper | 40-60 | Extracts n_s witnesses for segment s |
| Core Lemma 3.2.2 theorem | 80-150 | Forward and backward directions |
| **Total for Lemma322.lean** | **270-440 lines** | |
| Prop43 structural induction | 80-120 | Forward induction on formula |
| Bridge to P1/P2 | 60-120 | Connect VecEA to NF characterizations |
| **Total overall** | **410-680 lines** | |

The lower bound assumes omega/simp handle most Fin arithmetic. The upper bound
assumes explicit case splits for the position arithmetic.

---

## 12. Answers to the Research Questions

**Q1: Precise type signature of Lemma 3.2.2**

```lean
theorem VecEAFormula.decompose_to_two_free {sig : MonadicSignature} {m n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vf : VecEAFormula m n) (env : Fin m → M.carrier) (h_env_mono : StrictMono env) :
    vf.holds M atomMap env ↔
    ∀ (i : Fin (m + 1 - 1)), (vf.segmentBracket i).2.holds M atomMap (env i.castSucc) (env i.succ)
```
(plus endpoint conditions for the tails before z_0 and after z_{m-1} when m > 0)

**Q2: VecEAFormula.holds -- Fin m → M.carrier or require StrictMono?**

Require StrictMono as a SEPARATE HYPOTHESIS, not baked into the definition. This
matches mathematical practice: the formula psi(z_0,...,z_m) is only interesting
when z_0 < ... < z_m (the ordering constraint from Definition 3.1 is part of the
formula, not the evaluation context). The evaluation function should be total but
the theorem should add `h_env_mono` as a hypothesis.

**Q3: Witness partition map representation**

Implicit via the `FreeVarPositions m n` data already in `VecEAFormula`. The segment
assignment of each witness is DETERMINISTICALLY computed from `freePos.pos`. There is
no need for an explicit `Fin n → Fin (m-1)` map; it can be derived via:
```lean
def VecEAFormula.witnessSegment {m n : Nat} (vf : VecEAFormula m n) (j : Fin n) : Fin (m + 1) :=
  ⟨(Finset.filter (fun i : Fin m => vf.freePos.pos i < vf.witnessPos j) Finset.univ).card,
   by omega⟩
```

**Q4: Is the decomposition constructive?**

YES. Both the decomposition function and the equivalence proof are constructive.
No choice principles needed -- all witnesses for the 2-var pieces are extracted
directly from the witnesses of the original formula.

**Q5: Generality level for CSLib**

Arbitrary strict linear orders. No density, no completeness, no Dedekind property.
The type parameter is `[Preorder M.carrier] [IsStrictOrder M.carrier (· < ·)]` or
equivalently the existing `OrderedMonadicStructure sig` which already carries a
strict linear order. The theorem holds for ALL such structures.

**Q6: VecEAFormula or BracketFormula directly?**

`VecEAFormula m n` for the statement (captures the m-free-variable case cleanly).
`BracketFormula` is the TYPE of the output (the 2-variable pieces). The theorem
should be at the `VecEAFormula` level but produce `BracketFormula`/`VecEA2` outputs.

---

## 13. Key Implementation Risks

1. **Fin arithmetic for position extraction**: The combinedElem function requires
   computing the inverse of freePos.pos on the complement. Lean's `Fin` API can be
   clunky for this. The cleanest approach is to build the combined sequence as a
   `Fin (m+n) → M.carrier` function and then prove the segment bounds.

2. **Injectivity of the segment extraction**: We need to show the `n_s` witnesses for
   segment s are exactly those with witnessSegment j = s. This is straightforward
   by definition but requires careful case splits.

3. **The n = 0 case (no witnesses)**: VecEAFormula with no witnesses reduces to a
   pure constraint on the free variables (their ordering, their types if any). The
   decomposition should handle this cleanly by producing BracketFormula 0 pieces.

4. **The m = 0 case (no free variables)**: A sentence. Can be handled by returning
   an empty decomposition list and noting the formula holds iff it holds outright.

5. **The m = 1 case**: One free variable, decomposition trivially gives a single 1-var
   formula (treated as BracketFormula 0 from -∞ to z_0 and BracketFormula 0 from
   z_0 to +∞). Or we can skip tails and just note the formula is already 1-free-var
   (which satisfies ≤ 2 free variables).

---

## 14. Summary Recommendations

The cleanest formalization design is:

1. **Add `VecEAFormula.holds`** that operates on `Fin m → M.carrier` environments
   (no StrictMono requirement in the definition; add as hypothesis to theorems).

2. **Define `VecEAFormula.witnessPos`** as the canonical function mapping each
   witness j : Fin n to its combined position (the j-th element of the complement
   of `freePos.pos`'s range in `Fin (m+n)`).

3. **State Lemma 3.2.2** as an iff between `VecEAFormula.holds` and a list of
   `VecEA2.holds` applications on adjacent free variable pairs.

4. **Keep the result in a new file `Lemma322.lean`** importing VecEAFormula.lean,
   so it can be used by both VecEAClosure.lean and a new Prop43.lean.

5. **The CSLib-quality statement** should be parameterized over any
   `OrderedMonadicStructure sig` with no additional assumptions on the order.

This gives a general, clean result that stands on its own as a contribution
independent of the Kamp theorem proof context.
