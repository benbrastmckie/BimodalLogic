# Team Research Report: Forward-F Blocker — Deep Analysis and Alternatives

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Mode**: Team Research (4 teammates)
**Session**: sess_1775585993_5415d4
**Artifact**: 29

---

## Executive Summary

Four teammates conducted deep analysis of the `deterministic_forward_F` blocker from different angles: (A) deep dive into the cycle approach, (B) alternative approaches, (C) critical analysis of gaps and weaknesses, (D) first-principles problem setup.

**The central finding**: The forward_F/backward_G circularity is genuine and structural. Every approach that tries to derive `G(neg ψ) ∈ chain(t)` from "neg ψ at all future positions" will hit the same wall. The cycle approach (Report 28's recommendation) reduces the infinite chain to a finite periodic structure but does NOT resolve the circularity — the restricted truth lemma for the periodic model requires forward_F for the periodic model, reproducing the original problem.

### Key Takeaways

1. **The cycle approach alone cannot close forward_F** (Teammates A, C agree). The restricted truth lemma fails for Until/F in the forward direction because witnesses may lie outside the cycle. The backward G direction fails because knowing φ at finitely many cycle positions does not give G(φ) in an MCS.

2. **A new direction discovered**: The **decidability-based completeness** path (Teammate B, Section 7) completely bypasses canonical model construction. If `Correctness.lean` and `ProofExtraction.lean` in `Metalogic/Decidability/` are close to sorry-free, completeness follows without forward_F. **This deserves immediate investigation.**

3. **The quasimodel approach** (GHR 1994) has the highest probability of success (50-60%) among approaches that stay within the canonical model paradigm, at a cost of 1000-2000 lines.

4. **Well-founded induction on F-nesting depth** (not formula size) was dismissed too quickly by Report 28. Teammate C notes that `F(neg(neg(ψ)))` has the same F-nesting depth as `F(ψ)` under a suitable measure. This deserves a closer look.

5. **The root cause** (Teammate D): The deterministic chain is a PUSH-based construction (x_content determines successor), but F-resolution is a PULL-based property (obligation needs future witness). The push doesn't guarantee the pull.

---

## 1. Cycle Approach: Deep Analysis (Teammate A)

### 1.1 FiniteDeferral.lean Inventory

9 sorry-free theorems + 1 sorry (`forward_F_via_deferral`). The sorry-free infrastructure is substantial:

| Theorem | What It Does |
|---------|-------------|
| `F_to_until_in_chain` | Converts F(ψ) to (⊤ U ψ) in chain |
| `until_persists_forward_steps` | (⊤ U ψ) persists for n steps if ψ absent |
| `pigeonhole_restricted_theories` | Restricted theories must cycle within 2^|dc| steps |
| `G_neg_kills_until` | G(neg ψ) + (⊤ U ψ) → contradiction (170-line proof) |

### 1.2 Why the Cycle Approach Fails

The cycle approach builds a periodic model from the pigeonhole cycle and attempts a restricted truth lemma. Case-by-case analysis reveals:

- **Propositional cases**: Work (MCS properties transfer to restricted theory)
- **X (Next)**: Works at all positions INCLUDING the wrap-around point (x_content linkage + restricted theory equality)
- **G (Always Future) — forward direction**: Works (forward_G_int propagates φ along the original chain)
- **G (Always Future) — backward direction**: **FAILS** (knowing φ at finitely many cycle positions ≠ G(φ) in MCS)
- **F (Some Future) — forward direction**: **FAILS** (F(χ) in chain means witness exists in the infinite chain, but it may lie OUTSIDE the cycle)
- **Until — forward direction**: **FAILS** (same as F — witness may lie outside cycle)

**Critical insight**: The restricted truth lemma breaks for temporal existential connectives (F, Until) because membership in the restricted theory does not entail semantic truth in the periodic model. The cycle captures a FINITE window of the infinite chain, but existential witnesses may lie beyond that window.

### 1.3 Recursive Deferral Also Fails

Report 28 suggested recursively applying deferral for each unresolved F-obligation in deferralClosure. This doesn't work because:
- Each recursive level hits the same circularity (needs G(neg χ) to derive contradiction)
- The recursion is not on formula complexity (sizes can increase)
- deferralClosure finiteness bounds the NUMBER of formulas but not the proof difficulty

### 1.4 What the Cycle Approach CAN Prove

The cycle argument CAN establish: "If F(ψ) in chain(t) and ψ never appears, then restricted theories cycle with (⊤ U ψ) persisting everywhere and neg(ψ) everywhere." This is a useful intermediate result but does not reach contradiction.

---

## 2. Alternative Approaches (Teammate B)

### 2.1 Decidability-Based Completeness (NEW — Highest Priority)

**Completely bypasses canonical model construction.** The proof architecture:

```
valid(φ) → provable(φ)

Proof: By contrapositive. If not provable(φ):
  1. Run decision procedure → neg(φ) is satisfiable
  2. Extract finite countermodel from open tableau
  3. φ is false in countermodel → not valid
```

**Status**: Files exist in `Metalogic/Decidability/`: `DecisionProcedure.lean`, `Tableau.lean`, `Correctness.lean`, `ProofExtraction.lean`, `CountermodelExtraction.lean`. The FMP infrastructure in `Decidability/FMP/` has zero sorries.

**Unknown**: Sorry status of `Correctness.lean` and `ProofExtraction.lean`. If these are close to done, completeness follows WITHOUT forward_F, backward_G, canonical models, or chain constructions.

**Recommendation**: CHECK THESE FILES IMMEDIATELY.

### 2.2 Step-Indexed Reformulation

A bounded version of forward_F with explicit fuel `2^|deferralClosure(ψ)|`. This is a notational improvement (cleaner proof structure) but equivalent in difficulty to the cycle approach — the hard part remains the contradiction from the cycle.

### 2.3 Well-Founded Induction on Different Measures

All explored measures (deficiency, Until-depth, F-nesting depth, multiset orderings) fail because the dependency chain `forward_F(ψ) → backward_G(neg ψ) → forward_F(neg(neg ψ))` increases every proposed measure. However, Teammate C notes that **F-nesting depth** deserves more investigation — `F(neg(neg ψ))` has the same F-nesting depth as `F(ψ)` under certain definitions.

### 2.4 Direct Syntactic Contradiction

Multiple until_induction instantiations explored (χ = bot, χ = ⊤ U ψ, χ = neg(⊤ U ψ)). All require G-wrapped premises, which require backward_G. No viable instantiation found.

### 2.5 Omega-Rule / Compactness

Not applicable. The omega-rule is unavailable in finitary proof systems. Discrete temporal logic is non-compact.

### 2.6 FMP-Based Completeness

The FMP truth preservation (`TruthPreservation.lean`) is incomplete for temporal cases. The filtration truth lemma for Until likely hits the same forward_F wall. Lower priority than decidability path.

---

## 3. Critical Analysis (Teammate C)

### 3.1 Verified Claims from Report 28

✓ DeterministicChain.lean is sorry-free
✓ DeterministicFMCS.lean has exactly 4 sorries (2 leaf + 2 derived)
✓ FiniteDeferral.lean infrastructure is sorry-free (1 sorry in target theorem)
✓ Forward_F circularity is genuine (confirmed by reading temporal_backward_G_with_fwd_F)
✓ F_until_equiv is unsound under mixed semantics

### 3.2 Challenged Claims

1. **"Restricted forward_F can be established independently"** — FALSE. The periodic model's truth lemma faces the SAME circularity. Membership in restricted theory ≠ semantic truth for temporal existentials.

2. **"Only the cycle contradiction step needs formalization"** — UNDERSTATED. A full restricted completeness proof is needed, not just one step.

3. **"600-900 lines estimate"** — UNRELIABLE. Given 24+ failed research rounds, honest estimate is 800-1500 lines IF the approach works, UNKNOWN if it doesn't.

### 3.3 Gaps Found

1. **Nested Until formulas** not analyzed (pigeonhole bounds may not compose)
2. **Periodic model's forward_G breaks** at time-wrapping (monotonicity of time is lost)
3. **deferralClosure vs extendedDeferralClosure** — the pigeonhole uses `deferralClosure` which may not include needed Until/Since deferral formulas
4. **Completeness rerouting** through DeterministicFMCS is possible but does NOT reduce sorry count — it only reorganizes them

### 3.4 Risk Matrix

| Approach | Success Probability | Effort | Key Risk |
|----------|-------------------|--------|----------|
| Cycle contradiction | 30-40% | 800-1500 LOC | Same circularity in periodic model |
| Decidability-based | UNKNOWN (needs investigation) | 200-2000 LOC | Depends on sorry status |
| Quasimodel (GHR 1994) | 50-60% | 1000-2000 LOC | Large new infrastructure |
| Well-founded induction | 15-25% | 200-400 LOC | No viable measure found yet |

### 3.5 Potential Showstoppers

1. **The circularity is structural** — no approach that derives G(neg ψ) from pointwise membership will work without independent forward_F.
2. **The periodic model is NOT trivially a valid model** — forward_G breaks at the wrap-around because monotonicity of time is lost.

### 3.6 F_until_equiv Unsoundness: Scoped Impact

F_until_equiv unsoundness is primarily a SOUNDNESS problem, not a COMPLETENESS problem. Within the syntactic completeness proof (which works with MCS membership), F_until_equiv is valid because it is an axiom of the proof system. The unsoundness affects the separate Soundness.lean theorem.

---

## 4. First-Principles Problem Setup (Teammate D)

### 4.1 The Clean Mathematical Question

**Given**:
- An ω-sequence of MCS: M₀, M₁, M₂, ... where Mₙ₊₁ = x_content(Mₙ)
- (⊤ U ψ) ∈ M₀
- ψ ∉ Mₙ for all n ≥ 1

**Derive**: Contradiction.

**Known**:
1. (⊤ U ψ) ∈ Mₙ for all n ≥ 0 (Until persistence)
2. neg(ψ) ∈ Mₙ for all n ≥ 1 (negation completeness)
3. ∃ i < j, restrictedTheory(Mᵢ) = restrictedTheory(Mⱼ) (pigeonhole)
4. G(neg ψ) ∈ M₀ would give contradiction via G_neg_kills_until

**Gap**: "neg(ψ) ∈ Mₙ for all n ≥ 1" ⇏ "G(neg ψ) ∈ M₀" without forward_F.

### 4.2 Root Cause

The deterministic chain is **PUSH-based** (x_content determines successor) but F-resolution is **PULL-based** (obligation needs future witness). The push doesn't guarantee the pull.

### 4.3 Published Resolutions

Three standard approaches from the literature:

**(A) Well-founded induction on formula complexity** (Reynolds 2003):
- Prove forward_F by strong induction on ψ.complexity
- At each level, backward_G is available for SIMPLER formulas
- **Problem for TM**: neg(neg(ψ)) has complexity > ψ, breaking the induction

**(B) Direct cycle argument with until_induction**:
- Use pigeonhole cycle + until_induction locally
- **Problem**: Still needs G(neg ψ) as a premise

**(C) Quasimodel construction** (GHR 1994):
- Build witnesses INTO the model construction
- Avoids circularity by design
- Standard textbook approach, proven to work

### 4.4 The Proof Engineering vs. Logic Distinction

**This is a proof ENGINEERING circularity, not a logical one.** The theorem IS semantically true. The chain construction DOES produce a model where F-obligations are resolved. Evidence:
- Soundness is sorry-free
- until_induction axiom is specifically designed for termination
- The restricted theories MUST cycle (pigeonhole)

The difficulty is purely syntactic: how to convert a semantic fact into a proof-theoretic one.

---

## 5. Synthesis: Conflicts and Resolutions

### 5.1 Conflict: Cycle Approach Viability

- **Report 28**: Recommends cycle approach as "most promising" (600-900 LOC)
- **Teammate A**: Cycle approach "cannot close forward_F" — truth lemma fails
- **Teammate C**: 30-40% success probability, 800-1500 LOC
- **Teammate D**: Cycle approach is one of three standard approaches but faces genuine gaps

**Resolution**: The cycle approach as described in Report 28 has significant unstated gaps. It is NOT the straightforward path Report 28 suggested. The restricted truth lemma for temporal existentials fails because witnesses can lie outside the cycle. The approach would need substantial new ideas beyond what Report 28 describes. **Downgraded from "recommended" to "possible but risky".**

### 5.2 Conflict: Quasimodel vs. Decidability

- **Teammate A**: Quasimodel (800-1200 LOC) is most viable
- **Teammate B**: Decidability-based completeness could be much cheaper IF the module is close to done
- **Teammate C**: Quasimodel (50-60%) vs decidability (UNKNOWN)

**Resolution**: These are not mutually exclusive. **The decidability path should be investigated FIRST** because it has the highest potential payoff (could bypass ALL canonical model machinery). If it turns out to have major gaps, fall back to the quasimodel approach.

### 5.3 Agreement: The Circularity is Genuine

All four teammates agree: the `forward_F ↔ backward_G` circularity is real, structural, and cannot be broken by any approach that stays within a single chain and tries to derive G-formulas from pointwise membership. The only escape routes are:
1. Bypass the chain entirely (decidability-based completeness)
2. Build witnesses into the construction (quasimodel)
3. Find a clever until_induction instantiation (unlikely but not disproven)

---

## 6. Recommendations (Prioritized)

### Priority 1: Investigate Decidability Path (IMMEDIATE)

Read `Metalogic/Decidability/Correctness.lean`, `ProofExtraction.lean`, and `CountermodelExtraction.lean`. Count sorries. If these files are close to sorry-free, completeness follows without ANY canonical model construction — this would be the fastest path.

### Priority 2: Quasimodel Construction (FALLBACK)

If decidability path is far from complete, implement the quasimodel approach (GHR 1994). Build a finite set of MCS "types" with explicit F-witness pointers, then unravel into a linear model. Estimated 1000-2000 lines but 50-60% probability of success.

### Priority 3: Explore F-Nesting Depth Induction

Teammate C identifies that well-founded induction on F-nesting depth (not formula size) may work because `F(neg(neg(ψ)))` has the SAME F-depth as `F(ψ)`. This could yield a 200-400 line proof if a viable measure exists. Low probability (15-25%) but high payoff.

### Priority 4: Cycle Approach with Novel Ideas

The cycle approach has the infrastructure but needs a new idea to handle the truth lemma gap. If someone finds a way to derive contradiction from the cycle WITHOUT backward_G (e.g., a clever until_induction instantiation or a purely syntactic cycle argument), it would yield a clean 300-500 line proof.

### NOT Recommended

- Continuing with the DovetailedChain (architecturally blocked, all sorries are genuine)
- Lindenbaum detour approach (Plan v26 Phase 4 — Until persistence breaks through detours)
- Omega-rule / compactness (non-applicable to finitary systems)
- Adding new axioms to the proof system

---

## 7. Teammate Contributions

| Teammate | Angle | Key Findings | Confidence |
|----------|-------|-------------|------------|
| A | Cycle approach deep dive | Truth lemma fails for Until/F; quasimodel is most viable | HIGH |
| B | Alternative approaches | Decidability-based completeness bypasses ALL canonical model issues | MEDIUM (needs investigation) |
| C | Critical analysis | Report 28's cycle approach has unstated gaps; F-nesting depth deserves analysis | HIGH |
| D | First principles setup | Push vs pull root cause; proof engineering circularity; published resolutions | HIGH |

---

## 8. References

- Burgess, J.P. (1984). "Basic Tense Logic." *Handbook of Philosophical Logic*, Vol. II.
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol. 1.
- Goldblatt, R. (1992). *Logics of Time and Computation*, 2nd ed. CSLI.
- Reynolds, M. (2003). "A Hierarchical Completeness Proof for Propositional Temporal Logic."
- Venema, Y. (2007). "Temporal Logic." *Handbook of Modal Logic*.
