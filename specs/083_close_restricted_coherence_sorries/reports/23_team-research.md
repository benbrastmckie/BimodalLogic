# Research Report: Task #83 — Forward_F Blocker Analysis

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-06
**Mode**: Team Research (3 teammates)
**Session**: sess_1775506025_aeb53f

## Summary

Three research agents (quasimodel specialist, canonical model surveyor, critic) unanimously confirm that the `deterministic_forward_F` circularity is genuine and unbreakable within the current single-chain deterministic architecture. The circularity loop is: forward_F(psi) -> backward_G(neg psi) -> forward_F(neg(neg psi)) -> forward_F(psi), with no well-founded measure to break it (sizeof(neg(neg psi)) > sizeof(psi)).

Two distinct resolution paths emerged, with a novel third approach identified by Teammate A:

1. **Finite deferral + soundness** (novel, ~500-850 lines): Build a finite cyclic model from the pigeonhole cycle and derive contradiction via soundness of Until Induction — avoids encoding the cycle in the object language
2. **Quasimodel/filtration** (standard, ~500-1000 lines): Abandon the single-chain architecture; build an MCS graph with built-in F-witnesses and extract a path
3. **Restricted completeness via FMP** (~400-600 lines): Use existing FMP infrastructure to build a finite model from cyclic restricted theories

## Key Findings

### 1. Circularity Confirmation (All 3 Agree)

The forward_F circularity is a genuine mathematical obstacle, not a proof engineering gap:

- Report 20 (prior) proved that `deterministic_forward_F` is literally **false** for some MCSes — there exist MCSes M_0 where F(p) in M_0 but p never appears in x_content^n(M_0)
- The backward G derivation (`temporal_backward_G_with_fwd_F`) requires forward_F via contraposition, creating an inescapable loop
- No instantiation of `until_induction` resolves it without G-premises that reintroduce the circularity
- No well-founded induction measure works (neg(neg psi) is larger than psi)

### 2. The Common Failure Mode (Teammate C)

All 22 prior research reports hit the same wall: **converting meta-level "for all n, phi in chain(n)" to object-level "G(phi) in chain(t)"**. This is a fundamental mismatch between external (semantic) reasoning and internal (syntactic) reasoning in the chain architecture.

### 3. Approach Analysis

#### Approach A: Finite Deferral + Soundness (Teammate A — Novel)

**Idea**: The existing pigeonhole lemma gives two positions i < j with the same restricted theory, where (top U psi) holds everywhere and psi holds nowhere. Construct a **finite cyclic model** from positions [t+i, ..., t+j-1] with wraparound successor. In this finite model:
- (top U psi) is true at every world (semantic)
- psi is false at every world (semantic)
- This violates the semantic meaning of Until (there must be a future psi-witness)
- By **soundness** (already proven sorry-free), the Until Induction axiom is sound in this model
- Contradiction

**Why this might work**: It sidesteps the meta-level/object-level gap entirely by working at the semantic level. The soundness theorem is already proven, so we get the contradiction without needing to derive G(neg psi) in the object language.

**Risk**: Need to verify that the finite cyclic model correctly interprets all formulas in the deferral closure, and that the existing soundness theorem applies to finite cyclic models (not just the standard Int-indexed models).

**Estimated effort**: ~500-850 lines, HIGH difficulty

#### Approach B: Quasimodel (GHR 1994) (Teammates A, B, C)

**Idea**: Abandon the single deterministic chain. Build a quasimodel — a non-deterministic graph of MCSes where every F-obligation has an explicit witness (via `temporal_theory_witness_with_g_exists`, already sorry-free). Extract a linear path using fair scheduling/König's lemma. Prove the truth lemma over the extracted path.

**How it avoids circularity**: F-resolution is built into the construction by design. The model is the extracted path, which visits witnesses. No backward G needed because the model is constructed to satisfy eventualities.

**Caveat** (Teammate A): When the extracted path detours to a witness MCS, Until persistence may break (the X-vs-G mismatch). The enriched seed `{target} union x_content(M)` can be inconsistent when target is not in x_content(M).

**Counterpoint** (Teammate C): This is the standard published technique (Burgess 1984, GHR 1994, Reynolds 2010). The literature handles Until through detours — but the formalization details for THIS specific logic system need verification.

**Estimated effort**: ~500-1000 lines, VERY HIGH difficulty

#### Approach C: Restricted Completeness via FMP (Teammate B)

**Idea**: Use existing FMP infrastructure (Filtration.lean, ClosureMCS.lean, RestrictedTruthLemma.lean, TruthPreservation.lean) to build a finite model from the cyclic restricted theories and derive the contradiction within the finite model.

**Estimated effort**: ~400-600 lines, HIGH difficulty

### 4. S5 Modal Component (Teammate C)

The S5 modal operators are **orthogonal** to the forward_F problem. Modal coherence is already sorry-free. The master modality does not help (requires the even stronger `always phi`).

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate C | Resolution |
|----------|-----------|-----------|------------|
| Quasimodel viability | Hits same X-vs-G mismatch | Standard published technique, works | **Both valid**: quasimodel works mathematically but formalization may hit the same blocker in Until-through-detours |
| Primary recommendation | Finite deferral + soundness | Quasimodel | **Finite deferral first** (lower cost, reuses existing infra), quasimodel as fallback |
| Formalization effort for quasimodel | 1400-1900 lines | 500-800 lines | **Range: 500-1500 lines** depending on how much existing infra is reused |

### Gaps Identified

1. **Soundness-based cycle contradiction is untested** (Teammate A's novel idea): No published proof uses this technique for temporal logic completeness. Needs mathematical verification before committing to implementation.

2. **Finite cyclic model semantics**: Does the existing soundness theorem apply to finite cyclic models? The soundness is proven for task frame semantics over ℤ-indexed models. A finite cyclic model wraps around — is it a valid task frame? Likely yes if we model it as ℤ with periodic interpretation, but this needs confirmation.

3. **Until through detours in quasimodel**: Teammate A identified that the quasimodel detour breaks x_content linkage. The literature handles this, but the specific mechanism for THIS logic (bimodal S5 + temporal) needs detailed analysis.

4. **Bounded G unexploited** (Teammate C, Gap 3): Bounded universal quantification ("phi holds at all of the next K steps") is not expressible in the object language, but the cycle gives us exactly K positions where neg(psi) holds. Could a meta-level argument over K positions suffice without needing full G?

### Recommendations

**Primary path: Finite deferral + soundness approach** (Teammate A's novel idea)
- Build finite cyclic model from pigeonhole cycle
- Use existing soundness theorem to derive contradiction
- Lowest new code (~500-850 lines), highest infrastructure reuse
- **Risk**: Novel technique, needs mathematical verification first

**Fallback: Quasimodel (GHR 1994)**
- Standard published technique, mathematically proven
- Higher formalization cost (~500-1500 lines)
- **Risk**: Until-through-detours may hit same X-vs-G mismatch

**Pre-implementation step**: Before committing to either path, verify:
1. Can the existing soundness theorem be applied to a finite cyclic model?
2. What exactly is the semantic contradiction in the cyclic model? (Is "Until holds everywhere but witness never appears" provably false in the soundness framework?)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Insight |
|----------|-------|--------|------------|-------------|
| A | Quasimodel (GHR 1994) | completed | MEDIUM | Quasimodel hits same X-vs-G mismatch; finite deferral + soundness is more promising |
| B | Global canonical model alternatives | completed | MEDIUM-HIGH | Surveyed 5 approaches; finite deferral via restricted completeness most practical |
| C | Critic / gap analysis | completed | HIGH | Circularity is genuine; common failure mode identified; quasimodel is standard solution |

## References

1. Burgess, J. (1984). "Basic tense logic." Handbook of Philosophical Logic, vol. 2.
2. Gabbay, D., Hodkinson, I., Reynolds, M. (1994). Temporal Logic: Mathematical Foundations and Computational Aspects. Oxford.
3. Goldblatt, R. (1992). Logics of Time and Computation. CSLI.
4. Vardi, M.Y., Wolper, P. (1986). An Automata-Theoretic Approach to Linear Temporal Logic.
5. Venema, Y. Chapter 10: Temporal Logic.
6. Prior research reports 01-22 for task 83.
7. Codebase: FiniteDeferral.lean, DeterministicFMCS.lean, DeterministicChain.lean, RestrictedTruthLemma.lean, Filtration.lean
