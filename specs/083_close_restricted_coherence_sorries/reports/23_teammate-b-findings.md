# Teammate B Findings: Global Canonical Model Refactor

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-06
**Focus**: Alternative canonical model constructions that avoid the `deterministic_forward_F` circularity

---

## Key Findings

### 1. The Circularity is Real and Well-Known

The circularity between `deterministic_forward_F` and backward G derivation is a genuine mathematical obstacle, confirmed across 22 prior research rounds. The core issue:

- **Forward F**: If `F(psi) in chain(t)`, prove `psi in chain(s)` for some `s > t`
- **Backward G**: If `phi in chain(s)` for all `s > t`, prove `G(phi) in chain(t)`
- **Circularity**: Backward G requires Forward F as a hypothesis (see `temporal_backward_G_with_fwd_F`), but Forward F would use backward G to derive `G(neg psi) in chain(t)` for contradiction

Report 20 proved this is **not just a proof engineering issue**: there exist MCSes M_0 where `F(p) in M_0` but `p not in x_content^n(M_0)` for any n (Section 3.1 of report 20). The deterministic chain is locked into a timeline that may never resolve a given F-obligation.

### 2. Standard Textbook Approaches

The literature uses several approaches to prove completeness for temporal logics with Until:

#### 2a. Burgess (1984) -- Direct Path Construction
Burgess's approach for tense logic over general linear orderings:
1. Build the universe of ALL MCSes sharing a box-class
2. Define temporal relation via x_content (forward) and y_content (backward)
3. For F-resolution: use `temporal_theory_witness_with_g_exists` to get a witness MCS W with `psi in W` and `g_content(M) subset W`
4. **Connect chains by concatenation** -- splice the chain from M_0 to the chain from W

**Problem for this codebase**: The splice breaks x_content linkage at the join point. The truth lemma requires a single Int-indexed family with chain(n+1) = x_content(chain(n)), not a patched sequence.

#### 2b. Gabbay-Hodkinson-Reynolds (1994) -- Quasimodel Approach
The GHR approach from "Temporal Logic: Mathematical Foundations and Computational Aspects":
1. Build a **quasimodel**: a set of MCSes equipped with witness functions for all existential formulas
2. For each MCS M with `F(psi)`, the quasimodel contains a designated witness W(M, psi) with `psi in W(M, psi)`
3. Extract **paths** from the quasimodel using a graph traversal / Konig's lemma argument
4. The extracted path forms the Int-indexed family

**Assessment**: Clean mathematical approach. Avoids the chain circularity entirely because the quasimodel is built "all at once" rather than step-by-step. However, it requires ~1000 lines of new infrastructure: quasimodel definition, witness saturation, path extraction, and connection to FMCS/BFMCS.

#### 2c. Goldblatt (1992) -- Logics of Time and Computation
Goldblatt uses a similar approach to GHR but for simpler settings. For discrete time with Until:
1. Start with consistent set, extend to MCS via Lindenbaum
2. Build successor MCSes step by step, resolving F-obligations via dovetailing
3. The key technique: **fair scheduling** ensures every F-obligation is eventually targeted

**Assessment**: This is essentially the dovetailed chain approach already attempted in `DovetailedChain.lean`. It fails in this codebase because the Lindenbaum extension at each step breaks Until persistence (the X-vs-G mismatch identified in reports 05-09).

#### 2d. Automata-Theoretic Approach (Vardi-Wolper)
An alternative to axiomatic completeness:
1. Convert formula to Buchi automaton
2. Check emptiness via strongly connected component analysis
3. Eventualities are resolved by the acceptance condition (infinitely often visiting accepting states)

**Assessment**: Not directly applicable to the axiomatic completeness proof architecture. Would require a fundamentally different approach to the entire formalization.

### 3. Simultaneous Construction (Colimit/Fixed-Point)

**Idea**: Build the entire omega-chain simultaneously rather than step-by-step.

**Approach**: Define the chain as a fixed point of a functional on sequences of MCSes:
```
F(sigma) = lambda n. if n = 0 then M_0 else x_content_with_resolution(sigma, n-1)
```

**Problem**: The resolution step at position n depends on what happens at ALL future positions (to know whether `psi` eventually appears). This is not a monotone operator, so standard fixed-point theorems (Knaster-Tarski, Kleene) do not apply.

**Variant -- Omega-limit construction**: Build finite approximations sigma_k (chains of length k) and take a limit.
- Each sigma_k resolves F-obligations within k steps via dovetailing
- The limit sigma_omega resolves all F-obligations by fair scheduling
- **Problem**: Same Until persistence issue -- the limit may not preserve Until formulas through resolution steps

**Conclusion**: Simultaneous/colimit construction does not avoid the fundamental Until persistence blocker.

### 4. Deficiency-Based Construction (Dovetailing)

**Idea**: Enumerate all F-obligations and build the chain to satisfy them one by one.

**Standard version** (as in Goldblatt):
1. At step 0: M_0
2. At step n+1: Pick the nth F-obligation F(psi_n) from a fair enumeration
3. If `F(psi_n) in chain(n)`: use Lindenbaum extension to get chain(n+1) containing both `g_content(chain(n))` and `psi_n`
4. If not: set chain(n+1) = x_content(chain(n))

**Why it fails here**: Step 3 uses Lindenbaum extension, which only preserves g_content (G-wrapped formulas), not Until formulas. The formula `(phi U psi) in chain(n)` need not survive in chain(n+1) because `(phi U psi)` is not G-liftable.

**Enriched seed variant** (report 22, Section 8.2): Add Until deferrals to the Lindenbaum seed:
```
enriched_seed(M) = temporal_box_g_seed(M) union { psi_i or (phi_i and (phi_i U psi_i)) | (phi_i U psi_i) in M } union {target}
```

**Why it also fails**: While `temporal_box_g_seed(M) union until_deferrals(M) subset x_content(M)` (consistent), adding `{target}` when `target not in x_content(M)` makes the enriched seed inconsistent. The G-lift argument cannot handle Until deferrals because they are X-liftable but not G-liftable (report 22, Section 8.3).

### 5. Graph-Based Canonical Models

**Idea**: Instead of building a linear chain, build a graph of MCSes with accessibility relations and extract a path.

**Construction**:
1. **Worlds** = all MCSes in the box-class of M_0
2. **Temporal relation** R(M, N) iff N = x_content(M)
3. **Modal relation** = universal within box-class
4. **Truth lemma** over the graph, not over Int-indexed families

**Advantages**: F-resolution is trivially satisfied because for each F(psi) in M, a witness W exists with psi in W (by `temporal_theory_witness_with_g_exists`), and W is reachable from M via some path in the graph.

**Critical problem**: The backward direction of the truth lemma for G still requires forward_F. If `G(phi)` is not in M, then `F(neg phi)` is in M. We need a witness N reachable from M with `neg phi in N`. The witness exists in the graph (by temporal_theory_witness_with_g_exists), but we need it to be reachable via the x_content relation, not just present in the graph. Report 22, Section 6.1 confirms this circularity persists even in the graph model.

**Resolution in the literature**: Graph-based approaches use **omega-saturation** -- they build the graph so that EVERY existential formula has a witness reachable via the temporal relation. This is typically done by iterating: add witnesses, add witnesses for the new nodes, etc., until saturated. The result is a "quasimodel" (GHR terminology).

### 6. Existing Codebase Infrastructure Reuse

| Component | Status | Relevance to Solution |
|-----------|--------|----------------------|
| `DeterministicChain.lean` | Sorry-free | ESSENTIAL: Until persistence, G/H coherence, x_content linkage |
| `DeterministicFMCS.lean` | 2 leaf sorries | TARGET: Where forward_F/backward_P sorries live |
| `FiniteDeferral.lean` | Partial (step 5 sorry) | REUSE: Steps 1-4 formalized (F_to_until, persistence, pigeonhole, G_neg_kills_until) |
| `SubformulaClosure.lean` | Exists | REUSE: deferralClosure, closureWithNeg, subformulaClosure as Finset |
| `Filtration.lean` (FMP) | Exists | POTENTIAL: MCSFiltrationEquiv, restricted model construction |
| `ClosureMCS.lean` (FMP) | Exists | POTENTIAL: RestrictedMCS, projection from full MCS |
| `RestrictedTruthLemma.lean` | Exists | REUSE: Restricted truth lemma for closure-bounded formulas |
| `ParametricTruthLemma.lean` | Sorry-free | KEEP: Parametric truth lemma (conditional on tc + usc) |
| `ParametricRepresentation.lean` | Sorry-free | KEEP: Representation theorem |
| `DovetailedChain.lean` | 6 sorries | DEPRECATE: Architecturally blocked |
| `temporal_theory_witness_with_g_exists` | Sorry-free | ESSENTIAL: Witness MCS existence for F-resolution |

---

## Recommended Approach: Finite Deferral via Cycle Contradiction

After analyzing all alternatives, the **finite deferral / pigeonhole argument** is the most practical approach for this codebase. It works within the existing DeterministicChain architecture and requires the least new infrastructure.

### Detailed Proof Sketch

**Theorem**: `deterministic_forward_F`: If `F(psi) in chain(t)`, then `exists s > t, psi in chain(s)`.

**Proof by contradiction**: Assume `psi not in chain(s)` for all `s > t`.

**Step 1** (formalized in FiniteDeferral.lean): `F(psi) in chain(t)` implies `(top U psi) in chain(t)` by `F_to_until_in_chain`.

**Step 2** (formalized): By `until_persists_forward_steps`, `(top U psi) in chain(n)` for all `n >= t`.

**Step 3** (formalized): By `pigeonhole_restricted_theories`, within `2^|deferralClosure(psi)|` steps, two positions `i < j` have the same restricted theory.

**Step 4** (THE GAP -- the key step that needs formalization): The cycle from position `t+i` to position `t+j` has:
- `(top U psi)` at every position in the cycle
- `psi` at no position in the cycle
- The same restricted theory at positions `t+i` and `t+j`

**Why this is contradictory**: Apply the `until_induction` axiom with an appropriate instantiation over the cycle. The key insight:

**Instantiation**: Let `chi = neg(top U psi)` (or more precisely, a formula encoding "the restricted theory has been seen before"). The Until Induction axiom:
```
G(psi -> chi) and G((top and X(chi)) -> chi) -> ((top U psi) -> X(chi))
```

Since `psi not in chain(n)` for all `n > t`, the premise `G(psi -> chi)` is vacuously satisfied (psi is always false). The premise `G((top and X(chi)) -> chi)` requires that if chi holds at the next step, it holds now -- this is the "backward propagation" condition.

**Alternative (cleaner) approach**: Instead of Until Induction directly, use the following argument:

1. Since the restricted theory cycles with period `p = j - i`, the sequence of restricted theories is eventually periodic.
2. In the periodic part, `(top U psi)` is in every restricted theory, and `psi` is in none.
3. Consider the "unfolding" of the cycle into an infinite sequence. This gives an omega-model where `(top U psi)` holds everywhere but `psi` never holds.
4. By soundness of `until_induction` (or the FMP argument), this is impossible.

**But soundness requires a model, and we have restricted theories, not a model**. The argument needs refinement.

**The correct formalization path**: Use the `G_neg_kills_until` lemma (already proven sorry-free in FiniteDeferral.lean):
```lean
theorem G_neg_kills_until : G(neg psi) in chain(t) -> (top U psi) not in chain(t)
```

The missing link is: **derive `G(neg psi) in chain(t)` from the assumption that `neg psi in chain(s)` for all `s > t`**.

This is exactly `temporal_backward_G`, which requires `forward_F` -- **circular**.

### Breaking the Circularity: The Restricted Completeness Route

The cycle contradiction cannot use full `G_neg_kills_until` without circularity. Instead:

**Option A -- Well-Founded Induction on Subformula Depth**:
Prove `forward_F` by well-founded induction on `Formula.sizeof psi`. For formulas smaller than psi, assume forward_F holds. This gives `temporal_backward_G` for `neg(psi')` when `sizeof(psi') < sizeof(psi)`. However, `sizeof(neg psi) = sizeof(psi) + 1 > sizeof(psi)`, so this does not directly help.

**Option B -- Restricted Completeness via FMP**:
Use the existing FMP infrastructure to build a **finite model** from the cyclic restricted theories, and derive the contradiction within the finite model:

1. The cycle of restricted theories forms a finite "pseudo-model" (at most `2^|deferralClosure|` distinct states).
2. By the FMP truth preservation theorem (in `TruthPreservation.lean`), formulas in the closure are preserved.
3. In this finite pseudo-model, `(top U psi)` holds everywhere but psi never holds, contradicting soundness of the Until axioms in finite models.

This avoids the circularity because the finite model is constructed directly from restricted theories, not via the full completeness proof.

**Option C -- Direct Until Induction on the Cycle**:
This is the most promising approach within the existing infrastructure:

1. Positions `t+i` through `t+j-1` form a cycle of length `p = j-i` in restricted theories.
2. `(top U psi) in chain(n)` and `neg(psi) in chain(n)` for all `n` in `[t+i, t+j]`.
3. By Until Unfold at each position: `X(psi or (top and (top U psi))) in chain(n)`, so `(top and (top U psi)) in chain(n+1)` (since psi is absent).
4. The `until_induction` axiom with `chi = bot`:
   ```
   G(psi -> bot) and G((top and X(bot)) -> bot) -> ((top U psi) -> X(bot))
   ```
   Simplifies to: `G(neg psi) -> ((top U psi) -> X(bot))`.
   Since `X(bot)` is refutable, this gives `G(neg psi) -> neg(top U psi)`.
5. **The gap remains**: we need `G(neg psi) in chain(t)` from `neg(psi) in chain(n)` for all `n > t`.

**Option D -- Quasimodel (Last Resort)**:
If all the above fail, build the quasimodel from scratch. This avoids the circularity entirely by constructing all witnesses simultaneously. Estimated effort: ~800-1000 lines.

---

## Formalization Complexity Assessment

| Approach | Lines | Difficulty | Fits Architecture | Reuse |
|----------|-------|------------|-------------------|-------|
| Finite Deferral (Option B/C) | 400-600 | HIGH | YES | Heavy (FiniteDeferral.lean, FMP) |
| Quasimodel (Option D) | 800-1000 | VERY HIGH | Partial (needs new FMCS wiring) | Low |
| Graph-Based Canonical Model | 1000-1500 | VERY HIGH | NO (requires refactor) | Low |
| Simultaneous Construction | N/A | BLOCKED | N/A | N/A |
| Dovetailed Chain (enriched seed) | N/A | BLOCKED | N/A | N/A |

---

## Confidence Level

**Medium-High** for the finite deferral approach (Option B or C), contingent on resolving the backward G circularity via restricted completeness or direct Until Induction argument.

**High** confidence that the quasimodel approach (Option D) works mathematically, but with significant formalization overhead.

**High** confidence that the dovetailed chain and enriched seed approaches are definitively blocked (confirmed across reports 05-22).

---

## Evidence/Examples

### Evidence that `deterministic_forward_F` is false for arbitrary M_0 (Report 20, Section 3.1)

The set `S = {F(A), neg(A), X(neg(A)), X(X(neg(A))), ...} union {X(F(A)), X(X(F(A))), ...}` is finitely consistent and extends to an MCS M_0 where `F(A) in M_0` but `A not in x_content^n(M_0)` for any n. This proves the deterministic chain cannot resolve all F-obligations purely from x_content iteration.

### Evidence that the finite deferral infrastructure is nearly complete

`FiniteDeferral.lean` already has sorry-free:
- `F_to_until_in_chain`: F(psi) -> (top U psi) in the chain
- `until_persists_forward_steps`: (top U psi) persists for n steps
- `pigeonhole_restricted_theories`: restricted theories must cycle within `2^|deferralClosure|` steps
- `G_neg_kills_until`: G(neg psi) kills (top U psi) via Until Induction

The single remaining gap: deriving `G(neg psi) in chain(t)` from "neg psi in chain(s) for all s > t" without using forward_F.

### Evidence for the restricted completeness route

The codebase has:
- `RestrictedTruthLemma.lean`: Restricted truth lemma for closure-bounded formulas
- `Filtration.lean`: MCS-based filtration equivalence
- `ClosureMCS.lean`: RestrictedMCS, projection from full MCS to closure MCS
- `TruthPreservation.lean`: Truth preservation through filtration

These provide the foundation for building a finite model from the cyclic restricted theories.

---

## References

1. Burgess, J. (1984). "Basic tense logic." Handbook of Philosophical Logic, vol. 2.
2. Gabbay, D., Hodkinson, I., Reynolds, M. (1994). [Temporal Logic: Mathematical Foundations and Computational Aspects](https://global.oup.com/academic/product/temporal-logic-9780198537694). Oxford.
3. Goldblatt, R. (1992). [Logics of Time and Computation](https://csli.sites.stanford.edu/publications/csli-lecture-notes/logics-time-and-computation). CSLI.
4. Vardi, M.Y., Wolper, P. (1986). [An Automata-Theoretic Approach to Linear Temporal Logic](https://www.semanticscholar.org/paper/An-Automata-Theoretic-Approach-to-Linear-Temporal-Vardi/76d6f6fa1c7da03ee8f0a28bfdc6a5b9eb8b0b82).
5. [Temporal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-temporal/)
6. Venema, Y. [Chapter 10: Temporal Logic](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf).
7. Prior research reports 01-22 for task 83.
8. Codebase: `FiniteDeferral.lean`, `DeterministicFMCS.lean`, `DeterministicChain.lean`, `RestrictedTruthLemma.lean`, `Filtration.lean`
