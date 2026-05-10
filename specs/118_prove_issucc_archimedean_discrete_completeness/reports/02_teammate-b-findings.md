# Teammate B Findings: Alternative Approaches to Bypass IsSuccArchimedean

- **Task**: 118 - Prove IsSuccArchimedean for discrete completeness
- **Focus**: Alternative proof paths -- can we eliminate the sorry by restructuring rather than proving IsSuccArchimedean directly?
- **Date**: 2026-05-09

---

## Key Findings

### 1. IsPredArchimedean Equivalence: Does Not Help

**Verdict**: DEAD END
**Confidence**: HIGH

Mathlib's `LinearOrder.isSuccArchimedean_iff_isPredArchimedean` (in `Mathlib.Order.SuccPred.LinearLocallyFinite`, line 94) confirms that `IsSuccArchimedean` and `IsPredArchimedean` are logically equivalent for linear orders with `SuccOrder` and `PredOrder`. The equivalence is proven by mutual implication:
- `isPredArchimedean_of_isSuccArchimedean` (line 69, priority 100 instance)
- `isSuccArchimedean_of_isPredArchimedean` (line 89)

The pred-descent from `b` to `a` faces the identical fundamental obstacle: `pred(b')` may not be in any fixed `dom_N`, making all WF measures based on dom-N cardinality fail. The "birth-stage non-monotonicity" problem (predecessor of a point may have been born LATER in the omega chain) affects both directions equally. Proving either property is exactly as hard as proving the other.

### 2. Refactoring to Remove AddCommGroup: INFEASIBLE

**Verdict**: DEAD END
**Confidence**: HIGH
**Blast radius**: Would break entire semantic infrastructure

The `AddCommGroup D` requirement in `valid`, `TaskFrame`, `TaskModel`, and throughout the semantic layer is **mathematically necessary**, not a cosmetic convenience:

**Soundness dependencies** (confirmed by reading `Soundness.lean`):
- **MF (modal_future)**: `Box(phi) -> Box(G(phi))`. Proof uses `WorldHistory.time_shift sigma (s - t)`, requiring subtraction
- **TF (temp_future)**: `Box(phi) -> G(Box(phi))`. Same time-shift mechanism
- **discrete_symm_fwd**: `U(T,bot) -> S(T,bot)`. Constructs witness at `t - (s - t)` using group arithmetic
- **discrete_symm_bwd**: `S(T,bot) -> U(T,bot)`. Uses `t + (t - r)` translation
- **discrete_propagate_fwd/bwd**: Use `u + (s - t)` translation
- **seriality_future/past**: Use `Nontrivial` + ordered group to find witnesses

**ShiftClosed** (from `WorldHistory.lean`): `ShiftClosed Omega` requires `forall sigma in Omega, forall Delta : D, time_shift sigma Delta in Omega`. The `time_shift` function uses addition directly: `domain z := sigma.domain (z + Delta)`. The `respects_task` proof uses `(t + Delta) - (s + Delta) = t - s` (group cancellation).

**Files affected**: 30 files reference `AddCommGroup` across the codebase (111 total references). Every file in `Semantics/`, most of `Metalogic/`, `FrameConditions/`, and `Decidability/` would need changes. Estimated effort: multi-week refactoring with high regression risk.

**Mathematical impossibility**: Even if we could remove `AddCommGroup` from `valid`, the uniformity axioms (discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd) would NOT be sound on arbitrary linear orders. The BX axiom system is specifically designed for totally ordered abelian groups.

### 3. Quotient Construction: Reduces to IsSuccArchimedean

**Verdict**: DEAD END
**Confidence**: HIGH

The quotient idea: define an equivalence relation on `LimitDomSubtype` where `x ~ y` iff they are in the same succ-orbit (connected by finite succ/pred chains), then show the quotient has exactly one class.

**Analysis**: The succ-orbits partition `LimitDomSubtype` into copies of ℤ. Orbits are convex (if `a, b` are in the same orbit with `a < c < b` and `c ∈ limit_dom`, then `c` is in the same orbit). The statement "there is exactly one orbit" is EQUIVALENT to `IsSuccArchimedean`. The quotient by orbits is isomorphic to a set of copies of ℤ, and showing it has one element is exactly the problem we're trying to solve.

### 4. Order Embedding into ℤ: Insufficient

**Verdict**: DEAD END
**Confidence**: HIGH

We CAN construct an `OrderEmbedding` from a single succ-orbit of `LimitDomSubtype` into `ℤ`:
```
n >= 0: n ↦ succ^[n](root)
n < 0:  n ↦ pred^[|n|](root)
```

This is well-defined and strictly monotone (by `StrictMono.strictMono_iterate_of_lt_map` + `Order.succ_strictMono` + `NoMaxOrder`). However:

- It is NOT an `OrderIso` unless `IsSuccArchimedean` holds (the range might not be all of `LimitDomSubtype`)
- The FMCS coherence properties (forward_G, backward_H, Until/Since) need to hold over ALL of ℤ. The Until/Since witness `y` from `limit_satisfies_c5_strong` might not be in the succ-reachable fragment, making the coherence proof fail.
- An embedding is insufficient: the parametric truth lemma infrastructure requires an `OrderIso` to transport properties between domain types.

### 5. LocallyFiniteOrder: Equivalent to IsSuccArchimedean (Circular)

**Verdict**: DEAD END (circular dependency)
**Confidence**: HIGH

Mathlib provides `instance (priority := 100) [LocallyFiniteOrder iota] [SuccOrder iota] : IsSuccArchimedean iota` at `LinearLocallyFinite.lean:166`. The proof uses pigeonhole: if `succ^[n](i)` never reaches `j`, then infinitely many iterates land in the finite `Finset.Icc i j`, giving a collision via `Finite.exists_ne_map_eq_of_infinite`, which proves `IsMax` for some iterate (contradicting `NoMaxOrder`).

However, constructing `LocallyFiniteOrder` for `LimitDomSubtype` requires showing that `{x : LimitDomSubtype | a <= x /\ x <= b}` is finite for all `a, b`. This is EQUIVALENT to `IsSuccArchimedean`:
- `IsSuccArchimedean` => finite intervals (the succ chain from `a` to `b` has `n` steps, so the interval has at most `n+1` elements)
- Finite intervals => `LocallyFiniteOrder` => `IsSuccArchimedean` (Mathlib instance)

The circularity is complete. `LocallyFiniteOrder` cannot serve as an intermediate stepping stone.

Mathlib's `Subtype.instLocallyFiniteOrder` (for `{x : alpha // p x}` when `alpha` has `LocallyFiniteOrder`) also doesn't help because `Rat` does NOT have `LocallyFiniteOrder` (it's dense).

### 6. LinearLocallyFinite.lean Deep Dive: What It Provides

The file provides the key infrastructure for ℤ-isomorphisms:

| Definition/Instance | Requires | Provides |
|---|---|---|
| `succFn`, `predFn` | `LocallyFiniteOrder` | Non-computable succ/pred |
| `succOrder` (noncomputable def) | `LocallyFiniteOrder` | `SuccOrder iota` |
| `predOrder` (noncomputable def) | `LocallyFiniteOrder` | `PredOrder iota` |
| `instance IsSuccArchimedean` | `LocallyFiniteOrder + SuccOrder` | `IsSuccArchimedean` |
| `instance IsPredArchimedean` | `LocallyFiniteOrder + PredOrder` | `IsPredArchimedean` |
| `toZ i0 i : Int` | `SuccOrder + IsSuccArchimedean + PredOrder` | Integer encoding |
| `orderIsoRangeToZOfLinearSuccPredArch` | `IsSuccArchimedean` | `iota ≃o range(toZ)` |
| `orderIsoIntOfLinearSuccPredArch` | `IsSuccArchimedean + NoMax + NoMin + Nonempty` | `iota ≃o Int` |

All paths through this infrastructure require either `LocallyFiniteOrder` or `IsSuccArchimedean` as input. There is no way to bypass.

### 7. Alternative Architecture: "Direct FMCS on ℤ" (No OrderIso Needed)

**Verdict**: THEORETICALLY PROMISING but has the same fundamental gap
**Confidence**: MEDIUM

**Idea**: Instead of `LimitDomSubtype ≃o ℤ`, define the FMCS on ℤ directly by walking the succ/pred chain from the root:
```
f_Z(0)   = limit_f(root)
f_Z(n+1) = limit_f(succ^[n+1](root))   for n >= 0
f_Z(-n)  = limit_f(pred^[n](root))      for n > 0
```

This is well-defined, gives `f_Z(0) = A`, and the G/H coherence follows from `limit_forward_G` / `limit_backward_H` plus strict monotonicity of succ iteration.

**The gap**: Until/Since coherence fails. If `U(phi, psi) ∈ f_Z(n)`, we need a witness `m > n` in ℤ with `phi ∈ f_Z(m)` and guard. The chronicle gives a witness `y > succ^[n](root)` in `limit_dom`. But if `y` is NOT reachable from root by succ (i.e., `y` is in a different orbit), then there is no integer `m` with `f_Z(m) = limit_f(y)`. The Until/Since coherence on ℤ fails.

So this approach works IF AND ONLY IF all of `limit_dom` is in one succ-orbit -- which is exactly `IsSuccArchimedean`.

### 8. Schedule-Based Chain on ℤ (Existing Alternative)

**Verdict**: ALTERNATIVE PATH (but has its own sorries)
**Confidence**: HIGH

`RootScopedChain.lean` already implements a schedule-based BFMCS construction directly on `D = ℤ`, avoiding the chronicle construction and all `IsSuccArchimedean` issues entirely. It has 3 remaining sorries:

1. `bx_bfmcs_restricted_tc` (restricted temporal coherence) -- F/P resolution
2. `bx_bfmcs_restricted_buc` (backward Until/Since coherence)
3. `bx_bfmcs_restricted_fuc` (forward Until/Since coherence)

These sorries have a DIFFERENT fundamental obstacle: the "F-obligation preservation" problem. The Lindenbaum step in the chain construction does not preserve F(phi) obligations across steps -- F(phi) can be lost without phi ever appearing. This is related to BX11 fold opacity (dead ends 13-37 in ROADMAP).

**Comparison of the two paths to zero-sorry completeness**:

| Path | Sorry Site | Fundamental Obstacle | Estimated Effort |
|------|-----------|---------------------|-----------------|
| Chronicle (current) | `IsSuccArchimedean` at line 994 | WF measure for gap lemma | Hard (14+ rounds, NO-GO) |
| Schedule (RootScopedChain) | 3 restricted coherence at lines 186/193/198 | F-obligation preservation | Hard (BX11 opacity) |

Neither path currently has a clear resolution.

---

## Recommended Approach

### Primary Recommendation: Birth-Monotonicity Proof for IsSuccArchimedean

After investigating all 6+ bypass alternatives, the evidence overwhelmingly shows that **bypassing IsSuccArchimedean is not feasible** without equally hard work in a different direction. The sorry cannot be eliminated by restructuring.

The most promising approach (independently converged upon by prior research) is:

**Birth-monotonicity argument**: For the gap lemma (adjacent dom_N elements `p < q`), show `birth(succ_limitdom(z)) > birth(z)` for `z` in the gap `(p, q)`. Here `birth(x) = min{n | x.val ∈ dom_n}`.

**Why this might work**: The `witness_not_old` property from `C5ForwardWalkResult` guarantees each C5 witness is a NEW domain point (not previously in the domain). If the C5 witness for `U(T, bot)` at `z` IS `succ_limitdom(z)`, then `birth(succ_limitdom(z)) > birth(z)` follows directly. The WF measure would be `birth(q) - birth(current)`, which is a natural number that strictly decreases along the succ chain in the gap.

**What needs to be proven**: That the C5 witness for `U(T, bot)` at a point `z` is exactly `succ_limitdom(z)`. This requires examining the `c5_forward_walk` mechanism in `CounterexampleElimination.lean` to verify that when the guard is `bot`, the walk produces exactly the immediate successor.

### Fallback: Document the Sorry

If the birth-monotonicity proof cannot be completed, the sorry should remain documented with the following context:
- The mathematical fact is almost certainly TRUE (Burgess 1982)
- 14+ research rounds confirm no simple WF measure works
- The gap is a formalization challenge, not a mathematical gap
- The dense case (Task 117 Track A) provides sorry-free completeness for the main case

---

## Evidence / Examples

### Mathlib Infrastructure Verified

| Theorem | Verified | Relevance |
|---------|----------|-----------|
| `isSuccArchimedean_iff_isPredArchimedean` | YES (line 94 of LinearLocallyFinite) | Equivalence -- proving either suffices |
| `LocallyFiniteOrder + SuccOrder => IsSuccArchimedean` | YES (line 166) | Would bypass, but LocallyFiniteOrder is circular |
| `orderIsoIntOfLinearSuccPredArch` | YES (line 378) | Target: consumes IsSuccArchimedean |
| `StrictMono.strictMono_iterate_of_lt_map` | YES (found via leanfinder) | Succ iteration is strictly monotone |
| `Order.isMax_iterate_succ_of_eq_of_ne` | YES (found via leanfinder) | Pigeonhole collision implies max |
| `Subtype.instLocallyFiniteOrder` | YES (found via loogle) | Only works when base type is LocallyFiniteOrder |

### Codebase Architecture Verified

| Fact | Source | Implication |
|------|--------|-------------|
| `AddCommGroup` in 30 files, 111 references | grep across `Theories/Bimodal/` | Removal is massive refactoring |
| 6 axioms need group arithmetic for soundness | `Soundness.lean` lines 858-925 | Cannot weaken to LinearOrder |
| `valid` quantifies over `AddCommGroup D` | `Validity.lean:74` | Countermodel must provide AddCommGroup |
| `valid_discrete` additionally requires `IsSuccArchimedean D` | `Validity.lean:182` | For discrete frame class completeness |
| Schedule-based chain has 3 own sorries | `RootScopedChain.lean:186/193/198` | Not a clean alternative |
| ShiftClosed uses addition | `Truth.lean:242`, `WorldHistory.lean:238` | Cannot avoid group structure |

### Order-Theoretic Counterexample

`S = {-1/2^n : n >= 0} union {1/2^n : n >= 0}` in Rat (from prior research) demonstrates:
- Discrete linear order (SuccOrder + PredOrder) that is NOT IsSuccArchimedean
- Two succ-orbits separated by a gap at 0 (not in S)
- Satisfies NoMaxOrder, NoMinOrder, Countable
- Proves IsSuccArchimedean does NOT follow from order-theoretic properties alone

---

## Confidence Level

**HIGH** that no bypass exists. All 6 alternative paths investigated lead to dead ends:

1. **IsPredArchimedean**: Equivalent (no savings)
2. **Remove AddCommGroup**: Breaks soundness
3. **Quotient construction**: Equivalent to IsSuccArchimedean
4. **Order embedding**: Insufficient for coherence transport
5. **LocallyFiniteOrder**: Circular with IsSuccArchimedean
6. **Direct FMCS on ℤ**: Same gap (orbit reachability)

The sorry can only be eliminated by either:
**(A)** Proving `IsSuccArchimedean` directly (best current hope: birth-monotonicity argument)
**(B)** Fixing the 3 schedule-based chain sorries in `RootScopedChain.lean` (alternative path with its own obstacles)

Both are genuinely hard problems. The birth-monotonicity approach (A) is recommended as most promising.
