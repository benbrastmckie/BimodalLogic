# Teammate C Findings: Critical Analysis and Gap Detection

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-06
**Role**: Critic / Skeptic
**Focus**: Audit circularity claim, assess previous approaches, detect missed opportunities

---

## Key Findings

### 1. The Circularity Is Genuine and Unbreakable Within the Current Architecture

The circularity is not a mere technical inconvenience -- it is a structural consequence of the proof architecture. Here is the precise loop:

```
deterministic_forward_F(psi)           -- GOAL
  requires: G(neg psi) in chain(t)     -- to contradict (top U psi)
  requires: temporal_backward_G(neg psi)
  requires: forward_F(neg(neg psi))    -- by contraposition
  requires: forward_F(psi)             -- by double negation
```

The contraposition step in `temporal_backward_G_with_fwd_F` (TemporalCoherence.lean:213-229) is the culprit. To derive `G(phi) in fam.mcs t` from `phi in fam.mcs s` for all `s > t`, the proof:
1. Assumes `G(phi) not in fam.mcs t`
2. Gets `F(neg phi) in fam.mcs t` via MCS maximality + `neg_all_future_to_some_future_neg`
3. Applies `forward_F` to get witness `s > t` with `neg(phi) in fam.mcs s`
4. Contradicts with `phi in fam.mcs s`

Step 3 requires exactly the theorem we are trying to prove. And `neg(neg psi)` has size `sizeof(psi) + 2`, so well-founded induction on formula size does NOT break the loop.

**Verdict**: No trick within the single-chain deterministic architecture can break this. The circularity is genuine.

### 2. The Pigeonhole Argument Is Sound but Incomplete

The infrastructure in FiniteDeferral.lean (lines 99-153) is correct and sorry-free:
- `restrictedTheory` correctly restricts chain(n) to `deferralClosure(root)`
- `pigeonhole_restricted_theories` correctly establishes that among `2^|deferralClosure| + 1` consecutive positions, two share the same restricted theory

The gap is in Step 5 of the finite deferral argument: deriving a contradiction from a restricted theory cycle with unresolved `(top U psi)`. The existing `G_neg_kills_until` (lines 164-333) is correctly proved and shows that `G(neg psi)` in chain(t) kills `(top U psi)` in chain(t). BUT getting `G(neg psi)` into chain(t) from the cycle is exactly the backward G problem that requires forward_F.

**Specific failure mode**: The cycle tells us `restrictedTheory(chain(t+i)) = restrictedTheory(chain(t+j))` for some `i < j`. This means the chain's projection onto `deferralClosure(psi)` repeats. But this does NOT directly yield `G(neg psi)` because:
- We know `neg(psi) in chain(n)` for all `n > t` (by assumption in the proof by contradiction)
- We need `G(neg psi) in chain(t)` (universally quantified statement about ALL future times)
- The former is a meta-level "for all n" statement; the latter is an object-level formula membership

Bridging meta-level universal quantification to object-level G requires exactly `temporal_backward_G`, which requires `forward_F`.

### 3. The "Stupid Simple" Assessment

I examined several direct approaches:

**(a) F(psi) AND G(neg psi) is inconsistent -- can we derive this purely from axioms?**

Yes: `G(neg psi)` implies `neg(F(psi))` by temporal duality (this is just the definition of F). So `F(psi) AND G(neg psi)` is inconsistent in any MCS. This is trivial.

The problem is not showing the inconsistency -- it is getting `G(neg psi)` into chain(t) in the first place.

**(b) Use F_until_equiv: F(psi) <-> (top U psi), then apply Until properties directly?**

This is exactly what FiniteDeferral.lean does. `F_to_until_in_chain` converts F(psi) to `(top U psi)`. But Until persistence just means the obligation keeps deferring -- it never generates a contradiction by itself. The Until Induction axiom can generate a contradiction, but only when combined with G-premises, which reintroduces the backward G problem.

**(c) Using temporal induction creatively?**

The `until_induction` axiom is:
```
G(psi -> chi) AND G((phi AND X(chi)) -> chi) -> ((phi U psi) -> X(chi))
```

For phi = top, psi = psi, we need some chi such that:
- `G(psi -> chi)` holds (psi implies chi at all future times)
- `G((top AND X(chi)) -> chi)` holds (chi propagates backward from next step)
- `X(chi)` does NOT hold (to get a contradiction with (top U psi) -> X(chi))

The ideal chi would be `bot` (false), giving:
- `G(psi -> bot)` = `G(neg psi)` -- but this requires exactly what we cannot prove
- If we had `G(neg psi)`, the result `(top U psi) -> X(bot)` combined with `X(bot)` being refutable gives the contradiction immediately

Every other choice of chi either requires G-premises we cannot establish, or produces a non-contradictory conclusion.

**(d) Is there a proof that avoids backward G entirely?**

I searched for this extensively. The answer is no, within the current proof architecture. The backward direction of the truth lemma for G (ParametricTruthLemma.lean:345,527) explicitly calls `temporal_backward_G`, which requires `forward_F`. There is no alternative path in the current codebase.

### 4. The Common Failure Mode Across All 22 Reports

After reading reports 15, 17, 18, 20, and 22, the pattern is:

**Every approach eventually hits the same wall**: converting a meta-level "for all future chain positions, phi holds" into an object-level `G(phi) in chain(t)`. This is the fundamental mismatch between:
- **External (semantic) reasoning**: We can see that the chain satisfies a property at every position
- **Internal (syntactic) reasoning**: The MCS chain(t) does not know about positions beyond its immediate x_content successor

The approaches that were tried:
1. **Direct backward G** (reports 1-14): Circular via forward_F
2. **Well-founded induction on formula size** (report 15): sizeof(neg(neg psi)) > sizeof(psi), no decrease
3. **Chain unification** (report 17): Merging dovetailed and deterministic chains fails because dovetailed chain breaks Until persistence
4. **Half-open interval semantics** (report 8): Same gap for intervals beyond the witness
5. **Finite deferral / pigeonhole** (reports 20-22): Cycle detection works but extracting the contradiction requires backward G
6. **Global canonical model** (report 22): Shifts the problem to a different architecture but the same G-backward issue surfaces in the truth lemma

**Root cause**: The proof system has no way to internalize "for all positions in this specific syntactic chain." G is a semantic quantifier over a model's time domain, not a syntactic quantifier over chain indices.

### 5. The S5 Modal Component

The S5 modal operators (box/diamond) do NOT create additional complications for completeness. The modal coherence is already sorry-free (`bundle_modal_forward`, `bundle_modal_backward` in DeterministicFMCS.lean:116-157). The modal component is essentially orthogonal to the temporal forward_F problem.

The master modality (box AND G AND H, quantifying over all accessible worlds and all times) does not help either. The `temp_l` axiom (`always phi -> G(H phi)`) combines modal and temporal, but it requires `always phi` which is even stronger than `G(phi)`.

The box-class agreement propagates cleanly through x_content (`box_in_x_content`) and is not a source of difficulty.

## Gaps in Previous Analysis

### Gap 1: No report has seriously considered abandoning the Int-indexed FMCS architecture

All 22 reports take the FMCS/BFMCS/ParametricTruthLemma pipeline as given and try to prove `deterministic_forward_F` within it. Report 22 mentions a global canonical model but then notes the truth lemma refactor would be "massive" and retreats.

The standard approach in the literature (Burgess 1984, GHR 1994, Reynolds 2010) does NOT use a single deterministic chain. It uses a **filtration/quasimodel** where worlds are MCSes (not time indices) and the truth lemma is proved over the MCS graph directly. This would require restructuring the truth lemma, but it is the mathematically correct approach.

### Gap 2: The "x_content preserves Until" observation is underexploited

The key fact `chain(n+1) = x_content(chain(n))` gives Until persistence for free. But no report explores whether x_content also resolves F-obligations in bounded time via a combinatorial argument that does NOT require backward G.

Specifically: if F(psi) persists for K = 2^|deferralClosure(psi)| steps, the restricted theory cycles. At the cycle, the restricted theory is identical. Since `(top U psi)` is in the restricted theory at both endpoints, and `neg(psi)` is in the restricted theory at both endpoints (by assumption), the restricted theory cycle means the chain is "stuck in a loop" with respect to `deferralClosure(psi)`.

Could we use the `until_induction` axiom LOCALLY within the cycle (not requiring G over all future times, just over the cycle length)? This is unexplored.

### Gap 3: Bounded G is not the same as G

If we could prove something like "G restricted to the next K steps" (a bounded universal quantifier), that might suffice. The `until_induction` axiom uses full G, but perhaps a variant with bounded premises could be derived. This is NOT explored in any report.

However, bounded G is not expressible in the object language -- there is no `G_K(phi)` operator for "phi holds at all of the next K time steps." The language only has unbounded G. So this direction is likely a dead end unless we can show that the bounded meta-level reasoning suffices.

## Most Promising Path

**The quasimodel/filtration approach (GHR 1994)** remains the most promising, despite the refactoring cost. Here is why:

1. It avoids the single-chain deterministic architecture entirely
2. F-resolution is built into the construction by design (the quasimodel is saturated)
3. The truth lemma works over the MCS graph, not over Int-indexed families
4. It is the standard published approach, so correctness is well-established

**Estimated effort**: The existing sorry-free infrastructure (x_content_mcs, Until persistence, box-class agreement, modal coherence) can be reused. The new pieces are:
- A quasimodel type (set of MCSes with Succ relation + saturation)
- A construction that saturates an initial MCS into a quasimodel
- A truth lemma over the quasimodel
- Path extraction (Konig's lemma or direct construction) to get an Int-indexed model

This is ~500-800 lines of new Lean code, reusing existing infrastructure heavily.

**Second option**: A direct proof of `deterministic_forward_F` that avoids backward G. This would require finding a proof of "F-obligations are resolved in bounded time" that uses only FORWARD reasoning (x_content steps, Until unfold, pigeonhole) without ever needing to derive G(phi) from "phi at all future positions." I do not see how to do this with the current axiom set, but I cannot rule it out.

## "Stupid Simple" Assessment

**Did we miss something obvious?** Possibly, but I doubt it.

The one thing that nags me: the `until_induction` axiom is specifically designed to prove properties of Until chains. It says that if you have a "base case" (psi -> chi) and a "step case" (phi AND X(chi) -> chi) holding at all future times (under G), then (phi U psi) implies X(chi). This is essentially an induction principle for the Until operator.

If we instantiate chi = `neg(top U psi)` (i.e., "the Until obligation has been discharged or was never there"), then:
- Base: `psi -> neg(top U psi)`: FALSE. If psi holds, it does not mean (top U psi) is false -- (top U psi) could still be true for a different future witness. So this instantiation fails.

If we instantiate chi = `psi`:
- Base: `G(psi -> psi)` = `G(top)`: provable (vacuously)
- Step: `G((top AND X(psi)) -> psi)`: NOT provable. Just because psi holds at the next step does not mean psi holds now. Under strict semantics, X(psi) at time t means psi at time t+1, and there is no backward implication.

So no -- there is no obvious instantiation of until_induction that directly resolves the problem.

## Risk Assessment for Each Proposed Approach

| Approach | Risk Level | Reason |
|----------|-----------|--------|
| Direct backward G | **BLOCKED** | Proven circular, will not work |
| Well-founded induction on formula size | **BLOCKED** | neg(neg psi) is larger, not smaller |
| Pigeonhole + cycle contradiction | **HIGH** | Sound infrastructure but gap at the crucial step |
| Quasimodel (GHR 1994) | **MEDIUM** | Standard technique, requires ~500-800 lines new code |
| Global canonical model refactor | **HIGH** | Large refactor, same truth lemma issue may resurface |
| Bounded-G variant | **BLOCKED** | Not expressible in object language |
| Dovetailed chain (hybrid) | **BLOCKED** | Breaks Until persistence, deprecated |

## Confidence Level

**HIGH confidence** that:
- The circularity is genuine and cannot be broken within the deterministic chain + backward G architecture
- The pigeonhole infrastructure is sound but insufficient alone
- A quasimodel or filtration approach will work (it is the published standard)

**MEDIUM confidence** that:
- The quasimodel can reuse ~60% of existing infrastructure
- The refactoring cost is 500-800 lines (could be more if edge cases arise)

**LOW confidence** that:
- There exists a "stupid simple" proof within the current architecture that all 22 reports missed
- Any induction scheme (formula size, chain index, nesting depth) can break the circularity without changing the proof architecture
