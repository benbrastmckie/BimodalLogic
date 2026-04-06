# Teammate A Findings: Quasimodel Approach (GHR 1994)

**Task**: 83 -- Close Restricted Coherence Sorries
**Focus**: Quasimodel approach for breaking the `deterministic_forward_F` circularity
**Date**: 2026-04-06

---

## Key Findings

### 1. What Is a Quasimodel?

A quasimodel (as used in GHR 1994 and subsequent literature) is a **non-deterministic generalization** of a standard temporal model. Rather than a single omega-chain of worlds, a quasimodel is a labeled structure where:

- **States** are maximally consistent sets (MCSes), called "atoms" or "types"
- **Transitions** are non-deterministic: each state may have multiple successor states
- **The temporal relation is no longer necessarily a function** -- unlike a deterministic chain where `chain(n+1) = x_content(chain(n))`, a quasimodel allows multiple candidate successors for each state
- **Eventuality witnesses are built in by construction**: for each MCS M containing F(psi), the quasimodel includes a path from M to some MCS N containing psi

The key difference from the standard canonical model: a quasimodel is constructed so that existential temporal formulas (F, Until) have explicit witnesses **before** the truth lemma is attempted. Standard canonical models build a single chain and then try to prove witnesses exist -- which is where the circularity arises.

Quasimodels give rise to standard models by **unwinding**: selecting a single infinite path through the non-deterministic graph using Konig's lemma or a similar path-extraction argument.

### 2. How the Quasimodel Approach Handles F-Eventuality

The standard GHR/Burgess approach works in three phases:

**Phase A: Build the quasimodel (set of MCSes with witness structure)**

1. Start with a target MCS M_0 (containing the formula to be refuted).
2. For every MCS M in the current set that contains F(psi), add a **witness MCS** W to the set such that:
   - psi in W
   - g_content(M) subset W (G-persistence)
   - box_class_agree(M, W) (modal coherence)
   This is exactly `temporal_theory_witness_with_g_exists` (already proven sorry-free in the codebase).
3. Iterate: the newly added witnesses may themselves contain unsatisfied F-obligations. Add witnesses for those too.
4. Continue until saturation (a fixed point). Since there are only finitely many distinct MCS restrictions to the subformula closure, this terminates.

**Phase B: Define the temporal relation on the quasimodel**

The quasimodel has two temporal relations:
- **Deterministic successor**: `succ(M) = x_content(M)` (used for G/H forward propagation)
- **Witness links**: For each `F(psi) in M`, a link from M to W(M, psi)

**Phase C: Extract a linear path (the actual model)**

Using the quasimodel graph, extract an omega-indexed path that:
- Follows x_content most of the time (preserving Until persistence)
- Detours to witness MCSes when needed (resolving F-obligations)
- Uses fair scheduling to ensure every F-obligation is eventually addressed

The critical insight: **the path extraction step is where F-resolution happens**, not during a truth-lemma induction. The quasimodel guarantees that witnesses exist; the path extraction merely schedules visits to them.

### 3. Can Quasimodels Break the forward_F Circularity?

**Yes, but with a critical caveat.**

The quasimodel approach avoids the circularity by **not trying to prove forward_F for a single deterministic chain**. Instead:

1. It builds a **graph** of MCSes where witnesses are guaranteed to exist (by `temporal_theory_witness_with_g_exists`).
2. It extracts a **path** from this graph that visits witnesses.
3. The truth lemma is proved for the extracted path, not for a pre-existing deterministic chain.

**The circularity in the current codebase**: The current approach builds a deterministic chain first (`chain(n+1) = x_content(chain(n))`) and then tries to prove F-obligations are resolved within this fixed chain. This requires showing that `x_content` eventually brings psi into the chain -- which requires backward G reasoning, which requires forward_F (circular).

**How quasimodels break this**: The quasimodel does NOT commit to a single deterministic chain. The model is the extracted path, which is constructed to visit witnesses. There is no need to prove that a fixed chain resolves obligations, because the chain is built to resolve them.

**The caveat**: The extracted path must preserve **Until persistence**. When the path detours to a witness MCS W instead of following x_content(M), Until formulas in M may not transfer to W. This is **exactly the X-vs-G mismatch** that blocked the dovetailed chain approach (Report 22, Section 8.1).

**Resolution of the caveat**: The quasimodel literature handles this by requiring the witness W to satisfy not just g_content(M) subset W but also an **Until deferral condition**:

For each `(phi U psi) in M`: either `psi in W` or both `phi in W` and `(phi U psi) in W`.

This condition holds if W extends the "x_content seed" rather than just the "g_content seed". The key formula `psi or (phi and (phi U psi))` is in `x_content(M)` by the Until Unfold axiom. If the witness W extends x_content(M), Until deferrals are automatic.

**The problem**: As analyzed in Report 22 Section 8.2-8.3, the enriched seed `{target_alpha} union x_content(M)` may be **inconsistent** when `target_alpha not in x_content(M)`. The G-lift argument only proves consistency of `{target_alpha} union g_content(M)`, not `{target_alpha} union x_content(M)`.

### 4. The Detailed Proof Sketch (Quasimodel with Finite Deferral)

The most viable instantiation of the quasimodel idea for this codebase combines the quasimodel witness structure with the finite deferral / pigeonhole argument:

**Step 1**: Given M_0 with F(psi), build the deterministic chain: chain(n) = x_content^n(M_0).

**Step 2**: By Until persistence (`until_persists_forward_steps`, sorry-free), if psi never appears, (top U psi) persists in every chain(n) for n >= t.

**Step 3**: By pigeonhole (`pigeonhole_restricted_theories`, sorry-free), within 2^|deferralClosure(psi)| + 1 steps, two positions i < j have the same restricted theory: `restrictedTheory(chain(t+i)) = restrictedTheory(chain(t+j))`.

**Step 4** (THE HARD PART): Show that a restricted-theory cycle with unresolved (top U psi) is contradictory.

**Why Step 4 is hard**: A restricted-theory cycle means `chain(t+i)` and `chain(t+j)` agree on all formulas in `deferralClosure(psi)`. Both contain `(top U psi)` and `neg(psi)`. The question is: can the Until Induction axiom detect this cycle and derive a contradiction?

**The Until Induction argument over the cycle**:

The Until Induction axiom states:
```
G(psi -> chi) and G((phi and X(chi)) -> chi) -> ((phi U psi) -> X(chi))
```

Instantiate with phi = top (i.e., neg bot), psi = psi, and let chi be a formula that is:
- True at all positions in the cycle (so G(chi) holds over the cycle)
- False at position t (so X(chi) not in chain(t), giving the contradiction)

**Candidate for chi**: Let chi = "the restricted theory at this position is one of {T_1, ..., T_k}" where T_1, ..., T_k are the restricted theories that appear in the cycle segment [t+1, ..., t+j]. Since the cycle repeats, G(chi) holds from position t+1 onward. But chi is NOT a single formula in our language -- it would be a meta-level statement.

**This is the fundamental difficulty**: The Until Induction axiom operates on formulas of the object language, but the cycle detection is a meta-level argument. To apply Until Induction, we need to encode the cycle condition as a formula.

**Alternative**: Rather than encoding the cycle, use the cycle to construct a **finite model** (the finite "unrolling" of the cycle) where (top U psi) is true at every state but psi is never true. Then show this finite model violates the Until Induction axiom (or its semantic consequence). Since the axiom is sound, this gives a contradiction.

**This is essentially the FMP approach applied locally**: the restricted-theory cycle gives a finite pre-model; showing this pre-model cannot satisfy Until Induction yields the contradiction.

### 5. Formalization Complexity Assessment

| Component | Estimated Lines | Difficulty | Existing Infrastructure |
|-----------|----------------|------------|------------------------|
| Quasimodel graph definition | 200-300 | MEDIUM | `temporal_theory_witness_with_g_exists` (proven) |
| Witness saturation (fixed point) | 300-400 | HIGH | None -- new transfinite/iterative construction |
| Path extraction with fair scheduling | 200-300 | HIGH | Fair scheduling in DovetailedChain (deprecated but reusable ideas) |
| Until persistence through detours | 400-500 | VERY HIGH | This is the X-vs-G mismatch -- the core unsolved problem |
| Truth lemma adaptation | 300-400 | MEDIUM | ParametricTruthLemma (sorry-free, reusable structure) |
| **Total (full quasimodel)** | **1400-1900** | **VERY HIGH** | |

**Versus the finite deferral approach**:

| Component | Estimated Lines | Difficulty | Existing Infrastructure |
|-----------|----------------|------------|------------------------|
| deferralClosure properties | 50-100 | LOW | SubformulaClosure.lean, deferralClosure already defined |
| Restricted theory pigeonhole | 100-150 | LOW | `pigeonhole_restricted_theories` (sorry-free) |
| Cycle contradiction via Until Induction | 300-500 | VERY HIGH | `G_neg_kills_until` (sorry-free), Until Induction axiom |
| Wire to deterministic_forward_F | 50-100 | LOW | FiniteDeferral.lean infrastructure |
| **Total (finite deferral)** | **500-850** | **HIGH** | |

### 6. Comparison: Quasimodel vs Filtration/FMP vs Finite Deferral

| Criterion | Quasimodel (GHR) | FMP/Filtration | Finite Deferral |
|-----------|-------------------|----------------|-----------------|
| Avoids forward_F circularity | Yes (by construction) | N/A (different approach) | Yes (pigeonhole) |
| Preserves Until persistence | HARD (X-vs-G mismatch) | N/A | Inherited (deterministic chain) |
| Reuses existing infrastructure | Moderate | High (Filtration.lean, ClosureMCS.lean) | High (FiniteDeferral.lean) |
| New code required | ~1500 lines | ~800 lines | ~600 lines |
| Architectural disruption | HIGH (new model construction) | MEDIUM (parallel path) | LOW (adds lemmas to existing) |
| Mathematical elegance | High | Medium | Medium |
| Risk of hitting same blockers | MEDIUM (Until through detours) | LOW | HIGH (cycle contradiction) |

### 7. The Core Unsolved Problem Across All Approaches

All three approaches ultimately face the same mathematical challenge, manifested differently:

- **Quasimodel**: Until persistence through non-deterministic (witness) steps requires the enriched seed to be consistent. When `target not in x_content(M)`, the enriched seed `{target} union x_content(M)` is inconsistent. The literature handles this by allowing the detour to happen at a **later** time (not immediately at the next step), but this requires showing the target eventually enters x_content^k(M) for some k -- which is forward_F.

- **FMP/Filtration**: The filtered model has finitely many equivalence classes. Showing that F-formulas are resolved in the filtered model requires that the filtration preserves temporal succession faithfully enough to resolve eventualities. This is standard for basic modal logic but non-trivial for Until.

- **Finite Deferral**: The restricted-theory cycle is proven to exist (pigeonhole is sorry-free). But showing the cycle contradicts Until Induction requires encoding the cycle as an object-language argument, which is the gap.

**The deepest insight**: The `deterministic_forward_F` problem is equivalent to showing that the proof system's axioms (specifically Until Induction) rule out infinite deferrals. This is a **meta-theorem about the proof system** that needs to be internalized as a theorem within the proof system. The finite deferral approach comes closest to achieving this because it reduces the infinite deferral to a finite cycle (via pigeonhole) and then only needs to show the finite cycle is contradictory.

## Recommended Approach

**Recommendation: Finite Deferral (enhanced), not full Quasimodel.**

The quasimodel approach is mathematically the "right" construction from the literature, but its formalization cost is 2-3x higher than the finite deferral approach, and it faces the same Until-through-detours blocker. The finite deferral approach:

1. Keeps the entire existing sorry-free infrastructure intact
2. Only adds ~600 lines of new code
3. Has 80% of the infrastructure already built (`pigeonhole_restricted_theories`, `G_neg_kills_until`, `until_persists_forward_steps`)
4. The remaining gap (cycle contradiction) is a focused mathematical problem

**Specific next step**: The cycle contradiction can be attacked by:

(a) **Showing that a restricted-theory cycle implies G(neg psi) at the cycle start** -- if chain(t+i) and chain(t+j) have the same restricted theory and neg(psi) is in both, then the cycle "looks like" G(neg psi) holds locally. The Until Induction axiom with chi = bot then gives (top U psi) -> X(bot), contradicting (top U psi) in chain(t+i). The gap is making "looks like G(neg psi)" precise -- it requires that G(neg psi) is actually in chain(t+i), not just that neg(psi) appears at every position in the cycle.

(b) **Using the restricted truth lemma** (`CanonicalConstruction.lean:814`): The restricted truth lemma works with `restricted_temporally_coherent` which only requires F-resolution for formulas in `deferralClosure(root)`. If we can show F-resolution for ONE specific formula psi using the cycle contradiction, we get the restricted truth lemma for that formula, which gives the backward G needed for the full argument.

(c) **Constructing a finite model from the cycle and using soundness**: The cycle [chain(t+i), ..., chain(t+j-1)] forms a finite sequence of MCSes. Define a finite model with j-i worlds and the x_content relation wrapping around. Show this model satisfies Until Induction (it must, since Until Induction is sound). But (top U psi) holds at every world while psi holds at none -- contradicting the semantic meaning of Until. This argument uses **soundness** (already proven) to derive the contradiction without needing to internalize the cycle in the object language.

**Approach (c) is the most promising** because it leverages the already-proven soundness theorem and avoids the need to encode the cycle as a formula. The finite model construction from the cycle is straightforward (j-i worlds, x_content as successor, wrap-around at the end). The key lemma would be:

```
If chain(t+i) and chain(t+j) have the same restricted theory for deferralClosure(psi),
and (top U psi) in chain(t+i), and psi not in chain(t+k) for all i < k <= j,
then the cyclic finite model M_cycle satisfies (top U psi) at world (t+i)
but psi is false at all worlds -- contradicting soundness of Until Induction.
```

## Confidence Level

**MEDIUM**

- High confidence that the quasimodel approach is mathematically correct (it is the standard published technique)
- High confidence that the full quasimodel formalization would be very expensive (~1500 lines, VERY HIGH difficulty)
- Medium confidence that the finite deferral + soundness approach (c) can close the gap
- The soundness-based cycle contradiction is novel (not found in published proofs for this specific problem) and needs careful verification that the finite cyclic model correctly models the restricted chain behavior
