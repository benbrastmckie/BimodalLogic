# Teammate B Findings: Infrastructure Reusability and Alternative Approaches

- **Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
- **Focus**: Q1-Q6 infrastructure reusability analysis and alternative approach evaluation
- **Type**: lean4

## Executive Summary

The existing chronicle infrastructure is heavily hardcoded to `Rat` -- the `Chronicle` structure, `BurgessR3Maximal`, and `CounterexampleElimination` all operate exclusively on `Rat`. A separate "Z-chronicle" construction is NOT feasible because the entire Burgess construction fundamentally requires density for C4 counterexample elimination (inserting midpoints). The correct architecture is what the codebase already implements: build the chronicle on Rat, then transport to the target domain (Rat or Int) via an order isomorphism. The sole remaining blocker is `IsSuccArchimedean` for the discrete case.

---

## Q1: BurgessR3Maximal Reusability

### Type Parameters

`BurgessR3Maximal` is defined in `ChronicleTypes.lean:358`:

```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  ClosedUnderDerivation B /\
  burgessR3 A B C /\
  forall D, ClosedUnderDerivation D -> B < D -> not (burgessR3 A D C)
```

It is parameterized ONLY by `Set Formula` triples -- it has NO type parameter for the domain type. It does NOT mention `Rat`, `Int`, `Q`, `dom`, or any domain-dependent concept. The structure captures a purely logical relationship between sets of formulas: B is a maximal CUD set satisfying the Burgess content-based r-relation between endpoints A and C.

### Domain Independence

`BurgessR3Maximal` is completely generic. It could be used in ANY construction (Q-based, Z-based, or arbitrary linear order) because it describes the interval set B between two endpoint MCS without reference to where those MCS live in the temporal domain. The chronicle's `c2'` condition uses it:

```lean
def Chronicle.c2' (chi : Chronicle) : Prop :=
  forall x y : Rat, Adjacent chi.dom x y ->
    BurgessR3Maximal (chi.f x) (chi.g x y) (chi.f y)
```

The `Rat` appears only because `Chronicle.dom` is `Finset Rat`, not because `BurgessR3Maximal` requires it.

### Answer

`BurgessR3Maximal` is fully reusable without modification for any domain type. Its type parameters are `Set Formula` only.

---

## Q2: CounterexampleElimination Reusability

### Domain Assumptions

`CounterexampleElimination.lean` has pervasive domain assumptions tied to `Rat`:

1. **`C5Counterexample` and `C5'Counterexample`** (lines 48-68): These structures take `chi : Chronicle`, which means `x : Rat`, `x_mem : x in chi.dom` where `chi.dom : Finset Rat`.

2. **Fresh point construction** uses rational-specific theorems:
   - `exists_rat_gt_finset` (line 77): finds a rational strictly greater than all elements of a finite set
   - `exists_rat_lt_finset` (line 94): finds a rational strictly less
   - `exists_rat_between_not_in_finset` (line 120): finds a rational strictly between two given rationals that is not in a finite set (this is the critical one -- it requires density of Q)

3. **`eliminate_potential_counterexample`** (line 1811): Takes `chi : Chronicle` and `pc : PotentialCounterexample`, where `PotentialCounterexample` has fields `x : Rat`, `y : Rat`.

4. **`c5_forward_walk`** (line 668): The recursive walk that implements Burgess 2.10 induction uses midpoints `z = (x + y) / 2` to find fresh points between existing domain elements.

### Could It Work on Z?

**No.** The fundamental operation in counterexample elimination is inserting points BETWEEN existing domain points. This requires the density of the domain type:

- **C4 elimination** (Burgess 2.9): Given a counterexample at (x, y) with n=0 (adjacent pair), insert `z = (x + y) / 2`. On Int, there is no integer between consecutive integers.
- **C5 walk split cases**: When condition (i) fails, insert `z = (x + x') / 2` between start and its successor. Again requires density.
- **Fresh point construction**: `exists_rat_between_not_in_finset` is invoked whenever a new point must be placed between two existing points.

The entire chronicle construction is architecturally coupled to a dense domain. This is not incidental -- it is mathematically necessary (Burgess's construction fundamentally requires inserting midpoints). See report 08, Section 1 (Approach 1) for the proof that a direct Int chain cannot satisfy C4.

### Answer

`CounterexampleElimination` cannot work on Z. It requires density (midpoint insertion) which is mathematically necessary for the Burgess construction.

---

## Q3: Existing Int Chain (RootScopedChain)

### What Exists

`RootScopedChain.lean` at `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` defines:

```lean
noncomputable def bx_bfmcs (M0 : Set Formula) (h0 : SetMaximalConsistent M0) : BFMCS Int where
  families := { fam | exists (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
    (forall phi, Formula.box phi in M0 <-> Formula.box phi in N) /\
    fam = shifted_bx_fmcs N h_N s }
  ...
```

This uses the schedule-based `shifted_bx_fmcs` from `CanonicalModel.lean`, which builds `FMCS Int` chains via `fwd_chain`/`bwd_chain` (Lindenbaum-based successor/predecessor MCS construction).

### Sorry Sites

Three sorry sites (all dead code, no longer on critical path):

1. `bx_bfmcs_restricted_tc` (line 182-186): Restricted temporal coherence. F-resolution in the chain is blocked because `fwd_succ` (Lindenbaum step) does not preserve F-obligations.
2. `bx_bfmcs_restricted_buc` (line 190-193): Restricted backward Until/Since coherence.
3. `bx_bfmcs_restricted_fuc` (line 195-198): Restricted forward Until/Since coherence.

### What It Provides vs. What Is Missing

**Provides**: An `FMCS Int` chain with `forward_G`/`backward_H` (G/H propagation via g_content/h_content). A `BFMCS Int` bundle with `modal_forward`/`modal_backward` (Box stability across families).

**Missing**: All three coherence properties needed for the truth lemma. The fundamental issue documented in the file header (lines 28-36): "The simple Lindenbaum-based chain does not preserve F-obligations across steps." This is the same problem that blocked the defect-directed chain (archived in Boneyard).

### Answer

`RootScopedChain.lean` provides a `BFMCS Int` but with three sorry sites in the coherence properties. It is dead code -- the Completeness.lean proof bypasses it entirely via the chronicle-based `dd_countermodel_chronicle`. It cannot be reused for the Z-construction because its coherence sorries are mathematically blocked (not just missing proofs).

---

## Q4: omega_chain_val Parameterization

### Current Structure

`omega_chain_val` in `ChronicleConstruction.lean:265`:

```lean
noncomputable def omega_chain_val (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) : Chronicle :=
  (omega_chain A h_mcs n).val
```

Where `omega_chain` calls `eliminate_potential_counterexample` which returns an `EliminationResult` -- all operating on `Chronicle` (which is `Rat`-based).

### Could It Be Parameterized?

The `Chronicle` structure is hardcoded to `Rat`:

```lean
structure Chronicle where
  f : Rat -> Set Formula
  g : Rat -> Rat -> Set Formula
  dom : Finset Rat
```

To parameterize by domain type D, one would need:
- `structure Chronicle (D : Type) [LinearOrder D] where f : D -> ..., g : D -> D -> ..., dom : Finset D`
- `PotentialCounterexample` with `x y : D` instead of `x y : Rat`
- `Countable D` and `Infinite D` for `Denumerable PotentialCounterexample`
- `DenselyOrdered D` for `exists_rat_between_not_in_finset` (midpoint insertion)
- A midpoint operation `mid : D -> D -> D` with `x < mid x y < y`

This is conceptually possible but would require:
- Rewriting `Chronicle`, `ChronicleTypes`, `CounterexampleElimination`, `PointInsertion`, `RRelation`, and `ChronicleConstruction` -- collectively ~8000+ lines
- Adding `DenselyOrdered D` as a parameter everywhere (which means Int is still excluded)
- Replacing `Rat`-specific operations ((x+y)/2, linarith, etc.) with abstract operations

### Answer

The omega chain CANNOT be meaningfully parameterized to work on both Q and Z. The construction fundamentally requires density for midpoint insertion (C4 elimination). Parameterizing by D would still exclude Int since Int is not dense. The abstraction would be:
- D = Rat: insert midpoints (current behavior) -- WORKS
- D = Int: extend by one integer -- CANNOT satisfy C4

The right approach is NOT parameterization but rather the current architecture: build on Rat, transport via order isomorphism.

---

## Q5: Parameterized Chronicle Construction

### Interface Sketch

A parameterized construction would look like:

```lean
class ChronicleInsertable (D : Type) [LinearOrder D] where
  between : D -> D -> D  -- insert point between two existing points
  above : Finset D -> D   -- insert point above all existing points
  below : Finset D -> D   -- insert point below all existing points
  between_spec : forall x y, x < y -> x < between x y /\ between x y < y
  ...
```

With `D = Rat`: `between x y = (x + y) / 2`, `above S = S.max' + 1`, etc.
With `D = Int`: `between x y = ???` -- impossible when `y = x + 1`.

### Refactoring Cost

Even if the interface were defined, refactoring would require changing:
- `ChronicleTypes.lean` (700 lines)
- `RRelation.lean` (likely 1000+ lines)
- `PointInsertion.lean` (5300+ lines)
- `CounterexampleElimination.lean` (2600+ lines)
- `ChronicleConstruction.lean` (1500+ lines)

Total: ~11,000+ lines would need modification.

### Answer

Parameterization is architecturally impossible because D = Int cannot implement `ChronicleInsertable.between` for consecutive integers. Even if we restricted to D with density, the refactoring cost (~11,000 lines) vastly exceeds the value. The current approach (build on Rat, transport) is the correct architecture.

---

## Q6: Compose Q-chronicle with Projection

### The Proposal

Define `f_Z : Int -> MCS` by `f_Z(n) = limit_f(succ^n(0))` where `succ` is the limit_dom successor function. This avoids the Z-isomorphism entirely by using the successor function to enumerate limit_dom points.

### Analysis

**What this provides**: An `Int -> Set Formula` function that maps each integer to an MCS. The function is well-defined because:
1. `0 in limit_dom` (from `zero_mem_limit_dom`)
2. Under the discrete hypothesis, every limit_dom element has an immediate successor (`limit_dom_has_succ`)
3. `succ^n(0)` is defined for all n >= 0

For negative integers: use `pred^|n|(0)` (the predecessor function exists from `limit_dom_has_pred`).

### Coherence Conditions

**forward_G**: Need `G(phi) in f_Z(n) -> phi in f_Z(n')` for `n < n'`. This requires `phi in limit_f(succ^{n'}(0))` given `G(phi) in limit_f(succ^n(0))` and `succ^n(0) < succ^{n'}(0)` (strictly increasing successor iterates).

This follows from `limit_forward_G` IF `succ^n(0) < succ^{n'}(0)` when `n < n'`. The successor function is strictly increasing (`succ(x) > x`), so `succ^n(0) < succ^{n+1}(0) < ... < succ^{n'}(0)`. So `limit_forward_G` applies directly.

**backward_H**: Analogous, using `limit_backward_H` and the strict monotonicity of `pred` iterates.

**restricted_tc** (F/P-resolution): Need `F(phi) in f_Z(n) -> exists m > n, phi in f_Z(m)`. This means: given `F(phi) in limit_f(succ^n(0))`, find `m > n` with `phi in limit_f(succ^m(0))`.

From `limit_F_resolution`, there exists `y in limit_dom` with `succ^n(0) < y` and `phi in limit_f(y)`. But we need `y = succ^m(0)` for some `m > n`. This requires `y` to be a non-negative successor iterate of 0 -- which is equivalent to `IsSuccArchimedean` on the positive direction.

**This is the same blocker**: proving that every limit_dom element above 0 is reachable by iterated `succ` from 0 IS the IsSuccArchimedean problem.

**restricted_buc** (backward Until): Need: if `phi in f_Z(s)` and `psi in f_Z(r)` for all `n < r < s` (in Z), prove `(phi U psi) in f_Z(n)`. Since `f_Z(k) = limit_f(succ^k(0))`, this translates to: if `phi in limit_f(succ^s(0))` and `psi in limit_f(succ^r(0))` for all `n < r < s`, prove `(phi U psi) in limit_f(succ^n(0))`.

This requires knowing that the guard covers ALL limit_dom points between `succ^n(0)` and `succ^s(0)`, not just the succ-iterate points. If every limit_dom point between `succ^n(0)` and `succ^s(0)` is a succ-iterate of 0 (i.e., equals `succ^k(0)` for some `n < k < s`), then the guard holds at all intermediate limit_dom points, and contrapositive via `limit_satisfies_c4` gives the Until.

But proving "every limit_dom point between succ^n(0) and succ^s(0) is a succ-iterate of 0" IS IsSuccArchimedean again.

**restricted_fuc** (forward Until): Similar analysis; needs `limit_satisfies_c5_strong` which gives a witness `y in limit_dom`, but mapping it back to a succ-iterate index requires IsSuccArchimedean.

### Answer

The Q-chronicle-with-projection approach constructs the same `Int -> MCS` function as `discrete_f` (via `discrete_iso.symm`), just with a different definition. The three coherence conditions (`restricted_tc`, `restricted_buc`, `restricted_fuc`) ALL require `IsSuccArchimedean` -- specifically, that every limit_dom element is reachable from 0 via finitely many succ/pred steps. The projection does NOT bypass the IsSuccArchimedean blocker; it merely reformulates the same problem.

---

## Cross-Cutting Finding: The IsSuccArchimedean Blocker

All alternative approaches (Q4, Q5, Q6) and the current plan (Phase 4) converge on the same fundamental problem: proving `IsSuccArchimedean (LimitDomSubtype A h_mcs)` under the discrete hypothesis. This is the SOLE remaining sorry in the discrete case.

The mathematical argument is valid: a discrete linear order without endpoints that is countable and embeds into Q (hence Archimedean) must be IsSuccArchimedean. The formalization challenge is finding a well-founded termination measure that Lean accepts. Report 08 (Section 4) analyzed multiple approaches:

- **Direct dom_N measure**: Fails because pred(b) might not be in dom_N
- **Two-component lexicographic measure**: Fails because updating N can increase the second component
- **LocallyFiniteOrder**: Circular (requires IsSuccArchimedean to prove finiteness)
- **Gap lemma**: Correct but formalization is non-trivial (requires omega chain stage analysis)

The recommended path remains: prove `IsSuccArchimedean` via the gap lemma approach from report 07/08, or find a more elegant WF argument using the Rat embedding.

---

## Summary Table

| Question | Component | Reusable? | Key Finding |
|----------|-----------|-----------|-------------|
| Q1 | BurgessR3Maximal | YES fully | No domain type parameter; operates on Set Formula only |
| Q2 | CounterexampleElimination | NO for Z | Requires density (midpoint insertion); mathematically necessary |
| Q3 | RootScopedChain (Int) | NO | Three sorry sites in coherence; fundamentally blocked |
| Q4 | omega_chain_val parameterization | NO | Requires density; Int excluded; ~11K lines to change |
| Q5 | Parameterized Chronicle | NO | ChronicleInsertable.between impossible for Int |
| Q6 | Q-chronicle + projection | NOT helpful | All three coherence conditions still require IsSuccArchimedean |

**Bottom line**: The existing architecture (build on Rat, transport via order isomorphism) is correct. No alternative avoids the IsSuccArchimedean obligation. The sole remaining work is proving this one sorry.
