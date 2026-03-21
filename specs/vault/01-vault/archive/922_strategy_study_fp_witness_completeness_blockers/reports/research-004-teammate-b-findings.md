# Research Report: Alternative Approaches to CanonicalR Antisymmetry Blocker

**Task**: 922 - strategy_study_fp_witness_completeness_blockers
**Teammate**: B (Alternative Approaches)
**Date**: 2026-02-24
**Focus**: Two alternatives to proving antisymmetry: (1) Quotient by mutual CanonicalR, (2) Bypass OrderIso entirely

## Summary

This report analyzes two alternative approaches to resolve the CanonicalR antisymmetry blocker that prevents constructing a `LinearOrder` on `CanonicalReachable M_0 h_mcs_0`. The blocker exists because `CanonicalR M_1 M_2 AND CanonicalR M_2 M_1` does not necessarily imply `M_1 = M_2` (two distinct MCSes can share identical GContent). The two alternatives are:

1. **Quotient by mutual CanonicalR** using Mathlib's `Antisymmetrization` -- RECOMMENDED
2. **Bypass OrderIso entirely** with direct chain construction -- NOT RECOMMENDED

## Key Findings

### Alternative 1: Quotient by Mutual CanonicalR via Antisymmetrization

#### 1.1 Mathlib Infrastructure (Verified)

Mathlib provides a complete, ready-to-use pipeline for turning a preorder into a partial order via quotienting:

| Construct | Location | Status |
|-----------|----------|--------|
| `AntisymmRel r a b` | `Mathlib.Order.Antisymmetrization` | Defines `r a b AND r b a` |
| `AntisymmRel.setoid` | same | Equivalence relation from preorder |
| `Antisymmetrization alpha r` | same | Quotient type `Quotient (AntisymmRel.setoid alpha r)` |
| `toAntisymmetrization` | same | Canonical projection `alpha -> Antisymmetrization alpha r` |
| `ofAntisymmetrization` | same | Noncomputable representative selection |
| `instPartialOrderAntisymmetrization` | same | **PartialOrder** on quotient (lines 263-274) |
| `instLinearOrderAntisymmetrizationLe...` | same | **LinearOrder** on quotient when `IsTotal alpha (. <= .)`, `DecidableLE`, `DecidableLT` (lines 306-311) |
| `OrderEmbedding.ofAntisymmetrization` | same | Order embedding back into alpha (line 367) |
| `OrderHom.antisymmetrization` | same | Functorial lifting of order homomorphisms (line 345) |

All verified via `lean_local_search` and `lean_loogle`.

#### 1.2 Prerequisites Analysis

To use `Antisymmetrization` with `CanonicalReachable`:

**Step 1: Define Preorder on CanonicalReachable**

```
instance : Preorder (CanonicalReachable M_0 h_mcs_0) where
  le a b := CanonicalR a.world b.world
  le_refl a := canonicalR_reflexive a.world a.is_mcs
  le_trans a b c hab hbc := canonicalR_transitive a.world b.world c.world a.is_mcs hab hbc
```

This is straightforward: reflexivity and transitivity of CanonicalR are already proven in `CanonicalFrame.lean` (lines 180-231).

**Step 2: Prove IsTotal (from canonical_reachable_comparable)**

The existing `canonical_reachable_comparable` gives a three-way disjunction: `CanonicalR a.world b.world OR CanonicalR b.world a.world OR a.world = b.world`. This implies `IsTotal (CanonicalReachable M_0 h_mcs_0) (. <= .)` since equality implies both directions via reflexivity.

**Step 3: DecidableLE and DecidableLT**

These are needed for the `LinearOrder` instance on `Antisymmetrization`. Two options:
- **(a) Classical**: Use `Classical.dec` to provide decidability instances. This is already common in the codebase (Lindenbaum uses Zorn's lemma, which is inherently non-constructive).
- **(b) Constructive**: Would require decidability of `GContent M subset_eq M'` for MCSes, which is not straightforward.

**Recommendation**: Use classical decidability. The entire completeness proof is already non-constructive.

**Step 4: Form the quotient**

```
def CanonicalReachableQuotient M_0 h_mcs_0 :=
  Antisymmetrization (CanonicalReachable M_0 h_mcs_0) (. <= .)
```

This automatically inherits `PartialOrder` and `LinearOrder` from `instPartialOrderAntisymmetrization` and the LinearOrder instance.

#### 1.3 Lifting Properties to the Quotient

The key question: do the canonical frame properties (forward_F, backward_P, forward_G, backward_H) lift through the quotient?

**forward_G and backward_H (the BFMCS fields):**

These require: if `G(phi) in mcs(t)` and `t < t'`, then `phi in mcs(t')`.

On the quotient, `t < t'` means `CanonicalR(rep(t), rep(t'))` holds but NOT `CanonicalR(rep(t'), rep(t))`. The key observation from `gcontent_eq_of_mutual_R` (CanonicalReachable.lean lines 109-122): **mutually CanonicalR-related MCSes share the same GContent.** Therefore:

- If `G(phi)` is in any representative of the equivalence class `[M]`, then `G(phi)` is in ALL representatives (because they all share the same GContent, and `G(phi)` in GContent iff `G(G(phi))` in M, which holds for all class members by temp_4).
- If `CanonicalR([M], [M'])` with `[M] != [M']`, then `CanonicalR(rep(M), rep(M'))` holds, giving `phi in rep(M')` via `canonical_forward_G`. And `phi` is in all representatives of `[M']` by the same GContent argument...

Wait, `phi` may not be in GContent. We need: `G(phi) in mcs(t)` implies `phi in mcs(t')`. The proof is: `G(phi) in mcs(t)` means `phi in GContent(mcs(t)) subset mcs(t')` via `CanonicalR`. This works directly on representatives.

The lifting to the quotient requires showing the property is independent of representative choice. Since `G(phi) in M` iff `G(phi) in M'` for `M ~ M'` (they share GContent), and `phi in N` is a property of the target, this lifts cleanly.

**forward_F and backward_P:**

These require: if `F(phi) in mcs(t)`, then there exists `s > t` with `phi in mcs(s)`.

On the quotient, `canonical_forward_F` gives a witness `W` with `CanonicalR(M, W)` and `phi in W`. The question is whether `[W] > [M]` (strictly, not just `>=`).

Case analysis:
- If `W = M` (phi already in M): Then `[W] = [M]`, so we get `[M] >= [M]` but not strict. However, this only happens when `phi in M`. We need `phi` at some `[s] > [M]`.
  - **Key insight**: If `phi in M` and `phi in M'` for all `M' ~ M`, AND `CanonicalR(M, M'')` for some `M'' !~ M`, then we need `phi in M''`. But `phi` may not be in `M''`.
  - **However**: The BFMCS forward_F uses STRICT inequality on the index type. On the quotient, `[M] < [N]` means `CanonicalR(M, N)` and NOT `CanonicalR(N, M)`. So we need a witness W in the quotient with `[M] < [W]` and `phi in rep(W)`.
  - This is exactly the `canonical_forward_F_strict` situation from CanonicalReachable.lean (lines 137-141): when `F(phi) in M` and `phi not in M`, we get `W != M`, hence `[W] != [M]`, hence `[W] > [M]` (by totality).
  - When `F(phi) in M` and `phi in M`: We need `phi` at a strict future position. This is the SAME strict-future-witness problem identified in research-003 Section 12-15.

**Assessment**: The quotient approach does NOT automatically resolve the strict-future-witness problem. It resolves the LinearOrder prerequisite for `orderIsoIntOfLinearSuccPredArch` but the fundamental F-persistence issue remains for the `forward_F` property of the BFMCS/TemporalCoherentFamily.

#### 1.4 Remaining Prerequisites for orderIsoIntOfLinearSuccPredArch

After obtaining `LinearOrder` via quotient, the remaining requirements are:

| Requirement | Status | Difficulty |
|-------------|--------|------------|
| `SuccOrder` | Needs definition | Medium -- requires proving no dense gaps in the quotient |
| `PredOrder` | Needs definition | Medium -- symmetric to SuccOrder |
| `IsSuccArchimedean` | Needs proof | Medium -- follows from countability + linear order |
| `NoMaxOrder` | Needs proof | Medium-Hard -- requires showing every equivalence class has a strict successor class |
| `NoMinOrder` | Needs proof | Medium-Hard -- symmetric |
| `Nonempty` | Trivially holds | Root MCS |

**SuccOrder and PredOrder**: For a countable linear order, `SuccOrder` can be defined if the order is "locally finite" (every bounded interval is finite). A more direct approach: the reachable fragment quotient is countable (Formula is Countable, MCSes are subsets of a countable type, and the quotient is at most as large). If we can show `LocallyFiniteOrder`, then `LinearLocallyFiniteOrder.succOrder` gives `SuccOrder` automatically.

**Alternative**: Define SuccOrder directly by: for each equivalence class `[M]`, define `succ([M])` as the class `[W]` where `W = Lindenbaum({phi} union GContent(M))` for some suitable phi. This is non-trivial because the successor depends on the choice of phi.

**NoMaxOrder/NoMinOrder**: The `canonical_forward_F_strict` theorem shows that if there exists `F(phi) in M` with `phi not in M`, then M has a strict CanonicalR-successor. The question is whether EVERY equivalence class has such a formula. A temporally forward-saturated MCS (where `F(phi) in M` always implies `phi in M`) would be a potential maximum element. Whether such MCSes exist in the reachable fragment is an open question (flagged in the handoff document).

#### 1.5 Complexity Assessment for Alternative 1

| Step | Estimated Effort | Risk |
|------|------------------|------|
| Define Preorder on CanonicalReachable | 1-2 hours | Low |
| Prove IsTotal | 1 hour | Low |
| Form Antisymmetrization quotient | 1 hour | Low |
| Get LinearOrder (classical decidability) | 1 hour | Low |
| Prove NoMaxOrder/NoMinOrder | 3-5 hours | Medium-High |
| Define SuccOrder/PredOrder | 3-5 hours | Medium |
| Prove IsSuccArchimedean | 2-3 hours | Medium |
| Apply orderIsoIntOfLinearSuccPredArch | 1 hour | Low |
| Prove forward_F/backward_P on BFMCS via OrderIso | 4-6 hours | High (strict witness problem) |
| **Total** | **17-28 hours** | **Medium-High** |

### Alternative 2: Bypass OrderIso Entirely

#### 2.1 Direct Chain Construction Approach

Build `BFMCS Int` by explicitly constructing a chain of MCSes indexed by integers, using `canonical_forward_F` for forward witnesses and `canonical_backward_P` for backward witnesses.

**Proposed construction:**
```
mcs(0) = M_0  (root MCS)
mcs(n+1) = some witness W from canonical_forward_F applied to mcs(n) with a suitable formula
mcs(-(n+1)) = some witness W from canonical_backward_P applied to mcs(-n) with a suitable formula
```

**Problems with this approach:**

1. **Choice of witness formula**: What formula do we use for `canonical_forward_F` at each step? We need `F(phi) in mcs(n)` to invoke the theorem. We could use an arbitrary formula from an enumeration, but this doesn't guarantee the witness is strictly different from `mcs(n)`.

2. **F-persistence problem resurrected**: This is exactly the approach that the DovetailingChain attempted and failed at. The chain construction creates MCSes step by step, and the `forward_F` property of the BFMCS requires that for ANY `F(phi)` in `mcs(t)` (not just the formula used to construct the next step), there exists `s > t` with `phi in mcs(s)`. But the chain's next step only witnesses ONE formula, and new F-obligations can appear at each step.

3. **No improvement over DovetailingChain**: The 12 prior failed approaches all attempted variants of this direct chain construction. The fundamental issue is that `GContent(M_n)` does NOT contain `F(phi)` when `F(phi)` is in `M_n`, so the next step `M_{n+1} = Lindenbaum(GContent(M_n))` may not contain `F(phi)` or `phi`.

#### 2.2 Embedding Without OrderIso

An alternative form of bypassing: construct an order-preserving embedding `f : CanonicalReachable -> Int` that is NOT necessarily an OrderIso, then define `mcs(n) = rep(f^{-1}(n))` (using some padding for integers not in the range).

**Problems:**
- Requires an `OrderEmbedding`, which still needs a `LinearOrder` on the source (same antisymmetry blocker).
- The padding approach creates its own strict-future-witness problems (see research-003 Section 9).
- `OrderEmbedding` from a countable linear order into Int exists only if the source is discrete (no dense gaps). If the source has dense gaps, it cannot embed into Int (which is discrete).

#### 2.3 Modify BFMCS to Accept General Ordered Type

Instead of `D = Int`, modify the completeness chain to work with `D = CanonicalReachableQuotient` (the antisymmetrization of the reachable fragment).

**Problems:**
- `BFMCS` requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.
- `CanonicalReachableQuotient` is a quotient of a set of MCSes. It has no natural `AddCommGroup` structure.
- Modifying the `BFMCS` structure to remove the `AddCommGroup` requirement would ripple through: `TemporalCoherentFamily`, `TruthLemma`, `Completeness`, `Validity` -- estimated 10-15 hours of refactoring with high risk of breaking the existing proof chain.
- The `AddCommGroup` requirement exists because temporal operators use `t < t'` (strict ordering) and the semantics are defined for ordered abelian groups. Removing this would require rethinking the semantic framework.

#### 2.4 Complexity Assessment for Alternative 2

| Approach | Estimated Effort | Risk | Assessment |
|----------|------------------|------|------------|
| Direct chain construction | 8-12 hours | Very High | Recreates the DovetailingChain failure |
| OrderEmbedding without OrderIso | 10-15 hours | High | Same antisymmetry blocker |
| Modify BFMCS type | 10-15 hours | High | Large refactoring with cascade risk |

**Verdict: NOT RECOMMENDED.** Alternative 2 in all its forms either recreates known-failed approaches or requires high-effort refactoring with uncertain benefit.

## Comparative Analysis

| Criterion | Alternative 1 (Quotient) | Alternative 2 (Bypass) |
|-----------|--------------------------|------------------------|
| Resolves antisymmetry blocker | YES (by design) | Depends on variant |
| Uses existing Mathlib infrastructure | YES (Antisymmetrization) | Minimal |
| Preserves existing BFMCS chain | YES (still targets Int) | Variant-dependent |
| Handles strict-future-witness | NO (same open problem) | NO (same open problem) |
| Estimated effort | 17-28 hours | 8-15 hours |
| Risk level | Medium-High | Very High |
| Novel failures possible | Few (Mathlib is well-tested) | Many (new construction) |

### The Strict-Future-Witness Problem

Both alternatives face the same fundamental challenge: proving `forward_F` for the BFMCS. This requires that for `F(phi) in mcs(t)`, there exists `s > t` with `phi in mcs(s)`. The canonical frame's `canonical_forward_F` provides a witness `W` with `CanonicalR(M, W)` and `phi in W`, but `W` might equal `M` (when `phi` is already in `M`).

**Analysis of when `W = M`**: The `canonical_forward_F` witness is `Lindenbaum({phi} union GContent(M))`. This equals `M` precisely when `{phi} union GContent(M) subset M`, i.e., when `phi in M` (since `GContent(M) subset M` always holds by reflexivity). So `W = M` iff `phi in M`.

**When `phi in M` and `F(phi) in M`**: We need `phi` at a strictly later integer. Two sub-cases:
- If `G(phi) in M`: then `phi` propagates to ALL future MCSes via `forward_G`. Any `s > t` works.
- If `G(phi) not in M`: then `F(neg(phi)) in M` (by temporal duality). The witness for `F(neg(phi))` gives an MCS `W'` with `neg(phi) in W'` and `CanonicalR(M, W')`. Since `phi in M` and `neg(phi) in W'` and both are MCSes, `W' != M`. So `W'` is at a strictly later position. But `W'` has `neg(phi)`, not `phi`. We need `phi` at some later position, and `W'` is the wrong witness.

**Possible resolution**: When `G(phi) not in M`, the formula `phi` is "fleeting" -- it holds at `M` but may not hold at the next MCS. However, `F(phi) in M` guarantees existence of a witness for `phi` in the canonical frame. The canonical witness IS `M` itself. We need a DIFFERENT kind of argument:

Since `phi in M` and we need `phi` at `s > t`, consider:
- `G(P(phi)) in M` (by temp_a applied to phi).
- So `P(phi)` is in GContent(M) and propagates to all future MCSes.
- At some future MCS `M'`, `P(phi) in M'` means "phi held in the past".
- But this doesn't put phi in M'.

This appears to be a genuine gap that neither alternative resolves. The strict-future-witness problem is orthogonal to the antisymmetry question.

**However, there is an important observation**: The strict-future-witness problem might be resolved by a careful analysis of the quotient's structure. In the quotient, `[M] < [N]` means `CanonicalR(M, N)` and NOT `CanonicalR(N, M)`. So `N` has strictly MORE content than `M` (in the GContent sense). The quotient collapses all MCSes with the same GContent into one class. Within each class, all MCSes satisfy the same formulas that are determined by GContent. The "fleeting phi" scenario (phi in M, G(phi) not in M) means phi is NOT in GContent(M). In the quotient, the class [M] represents a specific GContent. The formula phi might or might not be present in class members, but this variation within the class is irrelevant since the quotient identifies all class members.

**Critical insight**: If we define `mcs` on the quotient by choosing a representative, then the BFMCS forward_F property asks: for `F(phi)` in the chosen representative of class [M], find a class [N] > [M] such that phi is in the chosen representative of [N]. The canonical_forward_F witness W has CanonicalR(M, W) and phi in W. If [W] > [M], done. If [W] = [M] (i.e., W ~ M), then phi is in W and W is in the same class as M. But we need phi in a STRICTLY later class. The same fleeting-phi problem persists.

## Recommended Approach

### Primary Recommendation: Alternative 1 (Quotient via Antisymmetrization)

Despite the strict-future-witness problem remaining open, Alternative 1 is strongly preferred because:

1. **It resolves the immediate blocker** (constructing a `LinearOrder` on the reachable fragment).
2. **It uses robust, well-tested Mathlib infrastructure** (`Antisymmetrization`, `instPartialOrderAntisymmetrization`, LinearOrder instance).
3. **It makes progress** toward `orderIsoIntOfLinearSuccPredArch` by establishing the first of its prerequisites.
4. **The remaining work** (SuccOrder, NoMaxOrder, IsSuccArchimedean, forward_F) is the same regardless of how we obtain the LinearOrder.
5. **The strict-future-witness problem is a separate concern** that likely requires a completely different resolution strategy (perhaps modifying how forward_F is proven, or adding a new axiom about temporal saturation).

### Implementation Roadmap for Alternative 1

**Phase A (Low Risk, 3-5 hours):**
1. Define `Preorder` on `CanonicalReachable` using `CanonicalR`
2. Prove `IsTotal` from `canonical_reachable_comparable`
3. Add classical `DecidableLE`/`DecidableLT` instances
4. Form `Antisymmetrization (CanonicalReachable M_0 h_mcs_0) (. <= .)`
5. Obtain `LinearOrder` from `instLinearOrderAntisymmetrizationLe...`

**Phase B (Medium Risk, 5-10 hours):**
6. Prove `Countable` on the quotient type
7. Investigate `LocallyFiniteOrder` or direct `SuccOrder`/`PredOrder` construction
8. Prove `IsSuccArchimedean`
9. Prove `NoMaxOrder`/`NoMinOrder` (requires non-trivial argument about saturated MCSes)

**Phase C (High Risk, 4-8 hours):**
10. Apply `orderIsoIntOfLinearSuccPredArch` to get `OrderIso (QuotientType) Int`
11. Construct `BFMCS Int` via the OrderIso
12. Prove `forward_G`/`backward_H` on the BFMCS
13. Address the strict-future-witness problem for `forward_F`/`backward_P`

### Secondary Recommendation: Investigate Strict-Future-Witness Resolution

The strict-future-witness problem is the TRUE remaining blocker. Possible resolutions to investigate:

1. **Prove every reachable MCS is NOT temporally saturated** (i.e., for every M in the reachable fragment, there exists phi such that F(phi) in M and phi not in M). This would make canonical_forward_F_strict always applicable.

2. **Prove that temporally saturated MCSes form a single equivalence class** (the quotient's maximum, if it exists). Then NoMaxOrder would fail, but we could handle this case separately.

3. **Use a different witness strategy**: Instead of canonical_forward_F, construct a witness that is always strictly greater. For example, for F(phi) in M with phi in M, use Lindenbaum({phi, some_future(phi)} union GContent(M)) -- this gives a witness W with both phi and F(phi) in W, potentially at a strictly later position.

4. **Weaken the BFMCS/TemporalCoherentFamily requirement**: Instead of strict inequality in forward_F, use non-strict inequality with a separate "non-trivial" condition. This would require modifying TruthLemma and is high-risk.

## Evidence

### Verified Mathlib Declarations

| Name | Verified Via | Exists |
|------|-------------|--------|
| `Antisymmetrization` | `lean_local_search` | YES |
| `instPartialOrderAntisymmetrization` | `lean_loogle` | YES |
| `instLinearOrderAntisymmetrizationLe...` | `lean_loogle` | YES |
| `toAntisymmetrization` | `lean_leanfinder` | YES |
| `ofAntisymmetrization` | `lean_leanfinder` | YES |
| `OrderEmbedding.ofAntisymmetrization` | `lean_leanfinder` | YES |
| `OrderHom.antisymmetrization` | Read file | YES |
| `AntisymmRel.setoid` | Read file | YES |
| `orderIsoIntOfLinearSuccPredArch` | `lean_leansearch` | YES |
| `SuccOrder` | `lean_local_search` | YES |
| `IsSuccArchimedean` | `lean_local_search` | YES |
| `LocallyFiniteOrder` | `lean_local_search` | YES |
| `LinearLocallyFiniteOrder.succOrder` | Read file | YES |

### Verified Codebase Declarations

| Name | File | Status |
|------|------|--------|
| `CanonicalR` | CanonicalFrame.lean:63 | Defined |
| `canonicalR_reflexive` | CanonicalFrame.lean:180 | Proven |
| `canonicalR_transitive` | CanonicalFrame.lean:217 | Proven |
| `canonical_forward_F` | CanonicalFrame.lean:122 | Proven |
| `canonical_backward_P` | CanonicalFrame.lean:151 | Proven |
| `canonical_reachable_comparable` | CanonicalReachable.lean:92 | Proven |
| `gcontent_eq_of_mutual_R` | CanonicalReachable.lean:109 | Proven |
| `canonical_forward_F_strict` | CanonicalReachable.lean:137 | Proven |
| `CanonicalReachable` | CanonicalReachable.lean:55 | Defined |
| `Formula derives DecidableEq, Countable` | Formula.lean:98 | Derived |

## Confidence Level

**Alternative 1 (Quotient)**: **Medium-High** confidence that it resolves the antisymmetry blocker and obtains a LinearOrder. **Medium** confidence for the full path to orderIsoIntOfLinearSuccPredArch (NoMaxOrder and SuccOrder are non-trivial). **Low-Medium** confidence for resolving the strict-future-witness problem (this is orthogonal to the quotient approach).

**Alternative 2 (Bypass)**: **Low** confidence. All variants either recreate known failures or require large refactoring.

## References

- Mathlib source: `.lake/packages/mathlib/Mathlib/Order/Antisymmetrization.lean`
- Mathlib source: `.lake/packages/mathlib/Mathlib/Order/SuccPred/LinearLocallyFinite.lean`
- Codebase: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- Codebase: `Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean`
- Codebase: `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean`
- Task 922 research-003.md (prior analysis of Int embedding paths)
- Task 922 handoff: phase-3-handoff-20260224T215519.md
- Goldblatt 1992, *Logics of Time and Computation* (canonical models for tense logics)
