# Task 153 Teammate B: Alternative Approaches to succ_cofinal

**Role**: Teammate B — Alternative approaches, bypassing or reformulating the problem
**Date**: 2026-05-15
**Session**: sess_1747338900_tmb

---

## Key Findings

### Finding 1: The LocallyFiniteOrder Route (Most Promising)

`IsSuccArchimedean` for `LimitDomSubtype` can be obtained without proving `succ_cofinal` directly if
we can establish `LocallyFiniteOrder` for `LimitDomSubtype`. Mathlib provides:

```
LinearLocallyFiniteOrder.instIsSuccArchimedeanOfLocallyFiniteOrder :
  [LocallyFiniteOrder ι] → [SuccOrder ι] → IsSuccArchimedean ι
```

This means: **if every closed interval `[a, b]` in `LimitDomSubtype` is finite, we get `IsSuccArchimedean` for free.**

The path would be:
1. Prove `∀ a b : LimitDomSubtype A h_mcs, (Set.Icc a b).Finite`
2. Apply `LocallyFiniteOrder.ofFiniteIcc` to get `LocallyFiniteOrder (LimitDomSubtype A h_mcs)`
3. `LinearLocallyFiniteOrder.instIsSuccArchimedeanOfLocallyFiniteOrder` then gives `IsSuccArchimedean`

The key lemma `LocallyFiniteOrder.ofFiniteIcc` (Mathlib):
```lean
noncomputable def LocallyFiniteOrder.ofFiniteIcc
    (h : ∀ a b : α, (Set.Icc a b).Finite) : LocallyFiniteOrder α
```

This is **exactly equivalent** to `IsSuccArchimedean` in a discrete linear order (finite intervals
characterize discreteness + Archimedean property together). The `IsSuccArchimedean` proof in
Mathlib for locally finite orders (lines 166-193 of `LinearLocallyFinite.lean`) works by
pigeonhole: if succ iterates from `i` never reach `j`, they all land in the finite set `Icc i j`,
eventually repeating — impossible in a strict order.

**Obstacle**: Proving interval finiteness for `LimitDomSubtype` IS the same difficulty as proving
`succ_cofinal`. A finite interval `[a, b]` in the discrete case contains exactly the orbit points
`a, succ(a), succ²(a), ..., b`. So finiteness of `[a, b]` is equivalent to saying the orbit
reaches `b` in finitely many steps. This is circular with `succ_cofinal`.

**Verdict**: The `LocallyFiniteOrder` approach is mathematically equivalent to `succ_cofinal`, not
a bypass. It reframes the problem but does not eliminate it.

---

### Finding 2: `IsSuccArchimedean.of_orderIso` Transfer

Mathlib provides:
```
IsSuccArchimedean.of_orderIso :
  [SuccOrder X] → [IsSuccArchimedean X] → [SuccOrder Y] → (X ≃o Y) → IsSuccArchimedean Y
```

Since `ℤ` has `IsSuccArchimedean` (`Int.instIsSuccArchimedean`), any type with an `OrderIso` to
`ℤ` inherits `IsSuccArchimedean`. **But `orderIsoIntOfLinearSuccPredArch` requires
`IsSuccArchimedean` as a hypothesis** — so this is circular in the standard approach.

However, there is a non-circular route if we can construct `LimitDomSubtype ≃o ℤ` by other means.
The Doets/Reynolds approach in the literature does this via the "contemporaneous equivalence"
compression (collapsing ℤ+ℤ-type structures), which does NOT require prior knowledge of
`IsSuccArchimedean`. If `chronicle_is_good` from `WeakCanonical/IntegerModel.lean` could be
completed, the Reynolds pipeline would produce `LimitDomSubtype ≃o ℤ` independently.

**Obstacle**: `chronicle_is_good` itself depends on `very_good_implies_good` which depends on
`sum_preservation` (Doets Lemma 1.4) — all marked sorry. These are deep results requiring the
Ehrenfeucht game machinery.

---

### Finding 3: The Reynolds Pipeline as Alternative

The WeakCanonical/ directory contains a partial implementation of Reynolds 1994 Theorem 15. The
pipeline is:

```
ChronicleExtraction.lean:
  extract_chronicle_as_prior : MCS A with □(next_top) → ChronicleAsPriorModel

IntegerModel.lean:
  chronicle_is_good (sorried) → very_good_implies_good (sorried) → (uses sum_preservation, Doets 1.4)

Transfer.lean (task 155 presumably):
  ChronicleAsPriorModel → BFMCS on ℤ → countermodel
```

Reynolds' proof (Corollary 3 → Theorem 15) does NOT need `IsSuccArchimedean` as an intermediate
step. The argument goes:

1. Start with the countable discrete Prior structure M (= the Burgess chronicle)
2. Use "contemporaneous equivalence" ~M to compress: classes that are copies of ℤ-intervals get
   merged
3. The Prior-UZ axioms guarantee no gaps between equivalence classes (Reynolds Lemmas 6-10)
4. The compressed structure has ℤ-type order
5. Observe that the original Prior-UZ axioms hold everywhere, making this a valid countermodel

This completely bypasses `IsSuccArchimedean`. The gap-elimination in Reynolds is done semantically
(using Prior-U applied to the formula `R` that says "my class ends in a gap"), not syntactically.

**Key literature insight (Reynolds §7)**: Reynolds proves no gaps exist between equivalence classes
of his contemporaneous equivalence relation using Prior-UZ: if a class ended in a gap, then `R`
(the formula saying "my class ends in a gap") would hold there, and Prior-U applied to `R` gives a
contradiction. This is the semantic analogue of Z1 gap-elimination.

**Obstacle**: The Reynolds pipeline has its own substantial blockers (all sorry):
- `finite_structures_good` (Doets 1.1 — k-type realizability)
- `sum_preservation` (Doets 1.4 — key lemma)
- `very_good_implies_good` (Reynolds Lemma 16)
- `chronicle_is_good` (synthesis)

These require ~200-400 lines of new formalization at minimum.

---

### Finding 4: The Doets Construction Alternative (No Chronicle)

Doets (1987 Chapter 7) constructs a Z-countermodel WITHOUT going through the Burgess chronicle. His
approach:

1. Build the Henkin canonical model M (all MCS as points, accessibility by G-elimination)
2. Restrict M to the "linear orbit" of the falsifying point m (points comparable to m under R)
3. This gives a linear order of equivalence classes (~M defined by mutual accessibility)
4. Expand each class to a ℤ-copy (A*) using Ehrenfeucht game invariants (n-characteristics)
5. Form N = sum of A* over equivalence classes
6. Apply modified Löb axioms to eliminate unbounded types (getting a ℤ-shaped model)
7. This IS isomorphic to ℤ by construction

Key difference from Burgess: The modified Löb axioms (= Z1 in the Doets formulation, Step 6) are
used to trim N down to ℤ-type, not to prove gap-elimination in a pre-existing construction. This
approach avoids the `succ_cofinal` problem entirely because **ℤ-isomorphism is built into the
construction from the start**.

**This is the approach the comment at line 1874 of ChronicleToCountermodel.lean references**: "A
Doets Henkin canonical model that avoids the gap entirely."

**What this would require**:
- A new module implementing the Doets construction independently of the Burgess chronicle
- The n-characteristics (game-theoretic types) for tense logic
- Modified Löb = Z1 applied in the construction phase

**Obstacle**: This is a complete reimplementation of the completeness proof from scratch. It would
not reuse the existing Burgess chronicle infrastructure.

---

### Finding 5: Adding Z1 as Axiom — Is It Sound for BX?

The in-progress approach in `succ_cofinal` relies on Z1 (= modified Löb axiom `G(Gφ→φ)→(FGφ→Gφ)`)
already being in the axiom system. The docstring at line 1142 says: "Under strict semantics
`G(φ)→φ` is not valid, so the Z1 Doets maximum principle cannot establish `G(Gφ→φ)` at orbit
points."

The core difficulty is:
- Z1 says: if there is a maximum φ-point, then Gφ holds there. But at ORBIT points (where all
  limit domain MCS have the same content), Z1 does not help because we cannot establish a
  discriminating formula φ that holds at ALL orbit points but fails at pred-chain points.
- The constant-MCS subcase: if all limit_dom points have the same MCS (i.e., all satisfy the same
  formulas), then NO formula distinguishes orbit from pred-chain, and Z1 gives no contradiction.

**The constant-MCS case analysis**: If all limit_dom points are labeled by the same MCS A, then
every formula true at one point is true at all points. The structure is "homogeneous" with respect
to formula truth. In this case, the "gap scenario" (orbit + pred-chain separate components)
satisfies all temporal axioms trivially: G(ψ)↔ψ for all ψ ∈ A and G(¬ψ)↔¬ψ for all ψ ∉ A.
This is internally consistent. The construction-level contradiction must come from the omega-chain
internals: the construction resolves counterexamples by inserting witness points with specific MCS
assignments, and having ALL domain points labeled by A is structurally impossible given the
counterexample resolution procedure.

**Proposed approach via omega-chain analysis**: For the constant-MCS case, one can argue that:
- At stage 0, `limit_f(0) = A`
- Each new insertion at stage n+1 is triggered by a counterexample (C5 forward, C5 backward)
- A C5-forward counterexample `U(η,ξ) ∈ f(x)` requires inserting a point y with `η ∈ f(y)`
- Since `next_top ∈ A` (discreteness) and `next_top = U(⊤,⊥)`, we have `U(⊤,⊥) ∈ A`
- This means `C5-forward(⊤,⊥)` at x requires a witness y with `⊤ ∈ f(y)` = trivially satisfied
- The GUARD in C5-strong says: for the intermediate formula, in the discrete case the guard is
  `⊥`, which is never satisfied. So succ(x) has empty guard — it IS the immediate successor.
- This does not immediately force succ(x) to have f(succ(x)) ≠ f(x).

The constant-MCS case remains genuinely hard at the construction level.

---

### Finding 6: The `WellFoundedGT.toIsSuccArchimedean` Route

Mathlib has:
```
WellFoundedGT.toIsSuccArchimedean : [WellFoundedGT α] → [SuccOrder α] → IsSuccArchimedean α
```

`WellFoundedGT α` means the `>` relation on α is well-founded (no infinite strictly increasing
chains). For `LimitDomSubtype`, this would fail because the type has `NoMaxOrder` — there are
infinite strictly increasing sequences. So this route is closed.

Similarly, `WellFoundedLT.toIsPredArchimedean` fails because `LimitDomSubtype` has `NoMinOrder`.

---

## Recommended Approach

**Primary Recommendation**: The Reynolds pipeline (WeakCanonical/) is the structurally correct
alternative. It bypasses `succ_cofinal` entirely because it obtains a ℤ-model without first
proving the Burgess chronicle itself is ℤ-isomorphic. The Reynolds approach uses Prior-UZ
semantically to eliminate gaps between equivalence classes, which is the intended mathematical
route.

Concretely, the most tractable path to zero-sorry `bx_completeness` that does NOT depend on
`succ_cofinal` is:

**Option A: Reynolds Theorem 15 pipeline completion**
1. Implement `sum_preservation` (Doets 1.4) — the key missing lemma
2. This unlocks `very_good_implies_good` → `chronicle_is_good`
3. Which gives a `BFMCS ℤ` from the chronicle
4. Route through `doets_countermodel_discrete` in `Transfer.lean`

This requires deep Ehrenfeucht game formalization. Estimated effort: task-level subtask (3-5 phases).

**Option B: Direct finite-interval proof**
For the discrete case where `next_top ∈ limit_f(x)` for all x, prove:
- Between any two adjacent points `a < b` in `LimitDomSubtype`, there is NO other `limit_dom`
  point (this IS `limit_dom_has_succ` already proved)
- Therefore `Icc a b = {a, b}` for adjacent pairs — 2 elements, finite
- For non-adjacent `a < b`, induction on the number of domain points between them (using finite
  sets at each stage)

But the "number of domain points between a and b" is NOT bounded a priori (it is a countable
union). The issue: the interval `[a, b]` in `limit_dom` could have countably many points (one
inserted at each stage), so interval finiteness is not clear.

**This is the core of the gap scenario**: in the gap scenario, the interval `[a, succ^[n](a)]`
contains infinitely many limit_dom points (the entire pred-chain accumulates between the orbit
limit L and b). Proving this doesn't happen IS `succ_cofinal`.

**Option C: Conservative extension via reflexive semantics**
The comment at line 1146 references "Task 129 (weak/reflexive completeness + conservative extension)".
If BX over strict semantics is provably a conservative extension of BX over reflexive semantics
(where Z1 is easier to use), then `succ_cofinal` could be bypassed entirely by:
1. Prove `IsSuccArchimedean` in the reflexive case (Z1 applies directly via `G(φ)→φ`)
2. Use conservative extension to lift the result

This requires a separate soundness/completeness result for a different semantic variant.

---

## Evidence and Examples

### Mathlib lemma chain for LocallyFiniteOrder route
```
LocallyFiniteOrder.ofFiniteIcc :
  (h : ∀ a b : α, (Set.Icc a b).Finite) → LocallyFiniteOrder α
  [Mathlib.Order.Interval.Finset.Defs line 627]

LinearLocallyFiniteOrder.instIsSuccArchimedeanOfLocallyFiniteOrder :
  [LocallyFiniteOrder ι] → [SuccOrder ι] → IsSuccArchimedean ι
  [Mathlib.Order.SuccPred.LinearLocallyFinite line 166]

Subtype.instLocallyFiniteOrder :
  [LocallyFiniteOrder α] → (p : α → Prop) → [DecidablePred p] → LocallyFiniteOrder (Subtype p)
  [Mathlib.Order.Interval.Finset.Defs line 1072]
  -- Note: Rat does NOT have LocallyFiniteOrder (it is dense), so this doesn't apply directly
```

### Reynolds §7 semantic gap elimination
Reynolds Lemma 7 (p. 125): In any Prior structure, if `R` (the formula saying "my class ends in a
gap on the right") holds and then eventually stops holding, Prior-U gives a last point of `R` or a
first point of `¬R`. Since no class can end at a gap (by definition of `R`), we get a first point
of `¬R` — but that would have to be the start of a gap itself, contradiction. **This eliminates
all gaps without referencing `IsSuccArchimedean`** — the Prior-U axiom does the work.

### ChronicleExtraction already builds the bridge
`ChronicleExtraction.lean` already wraps `LimitDomSubtype` into a `ChronicleAsPriorModel` with
all the properties Reynolds Corollary 3 needs:
- Countable: yes
- Discrete (SuccOrder/PredOrder): yes (from `h_discrete`)
- NoMin/NoMax: yes (from seriality)
- Prior-UZ/SZ valid: yes (from `theorem_in_mcs`)

This means the Reynolds pipeline input is already ready. The blocking items are purely in
`IntegerModel.lean` (the Doets side).

---

## Confidence Level

| Approach | Mathematical Soundness | Lean Feasibility | Recommended |
|----------|----------------------|------------------|-------------|
| LocallyFiniteOrder route | Circular with succ_cofinal | Low (same difficulty) | No |
| Reynolds Theorem 15 pipeline | Sound, well-documented | Moderate (needs Doets 1.4) | Yes (primary) |
| Doets Henkin construction | Sound, proven in literature | Low (full reimplementation) | No (too costly) |
| WellFoundedGT route | Inapplicable (NoMaxOrder) | None | No |
| Conservative extension (Task 129) | Sound if extension proved | Unknown | Contingent |

**Overall confidence**: HIGH that the Reynolds pipeline is the correct long-term path. LOW that any
approach substantially shorter than 3-5 implementation phases exists.

The `succ_cofinal` sorry in `ChronicleToCountermodel.lean` represents a genuine gap: the Burgess
chronicle construction does not guarantee ℤ-structure internally; that structure must be imposed
externally via Reynolds' compression. The existing infrastructure in `WeakCanonical/` is the right
vehicle — it needs `sum_preservation` (Doets 1.4) to be completed.

**For task 153 specifically**: The most immediate action that would make progress is completing
`sum_preservation` in `IntegerModel.lean`, which would unlock the Reynolds route. This is cleaner
than attacking `succ_cofinal` directly because the Reynolds route is semantically motivated
(Prior-UZ eliminates gaps) while the direct route faces the hard constant-MCS counterexample.
