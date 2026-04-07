# Alternative Approaches to Forward-F Resolution

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Role**: Teammate B -- Alternative Approach Exploration
**Artifact**: 29

---

## 0. Executive Summary

Report 28 recommends the finite deferral cycle contradiction approach. This report evaluates six alternative approaches that might have been overlooked or dismissed too quickly. After deep analysis, including codebase examination and Mathlib search, the findings are:

1. **FMP-based completeness bypass**: The most promising unexplored direction. The existing sorry-free FMP infrastructure could potentially replace the canonical model approach entirely.
2. **Step-indexed/fuel-based forward_F**: Viable reformulation that avoids circularity structurally, but still requires the same cycle contradiction at its core.
3. **Well-founded induction on deficiency measure**: Novel measure that genuinely decreases, but hits the same backward-G wall when trying to discharge the induction step.
4. **Direct syntactic contradiction from cycle**: The cycle approach with a specific instantiation of until_induction -- blocked by the same G-wrapping problem but has a subtle variant worth exploring.
5. **Omega-rule / compactness**: Not directly applicable because the logic is not compact in the relevant sense.
6. **Literature search**: No temporal logic completeness formalization exists in Mathlib. Published proofs all use reflexive semantics.

The key structural insight across all approaches: **every path that attempts to derive a contradiction from "psi absent at all future positions" eventually needs to convert this meta-level fact into an object-level G(neg(psi)) formula inside the chain.** Breaking this meta-to-object barrier is THE fundamental problem.

However, I identify one genuinely new direction (Section 7) that the prior 28 reports may have overlooked: **completeness via FMP + soundness composition**, which completely sidesteps the canonical model construction.

---

## 1. FMP-Based Completeness Bypass

### 1.1 Precise Statement

Instead of proving completeness via a canonical model (which requires forward_F), prove it by composing:
- **Soundness** (sorry-free): If `[] |- phi`, then phi is valid in all task models.
- **FMP** (sorry-free infrastructure in `Decidability/FMP/`): If phi is satisfiable, then phi is satisfiable in a finite task model of bounded size.
- **Finite model decidability**: For any formula phi and finite model M, truth of phi at any world in M is decidable.

Completeness follows: if phi is not provable, then neg(phi) is consistent, hence satisfiable (by Lindenbaum + restricted MCS), hence satisfiable in a finite model (by FMP), hence phi is not valid. Contrapositive: if phi is valid, phi is provable.

### 1.2 Why It Might Work

- The existing FMP infrastructure in `Decidability/FMP/` has **zero sorries**: `Filtration.lean`, `ClosureMCS.lean`, `FiniteModel.lean` all compile clean.
- `TruthPreservation.lean` provides the filtration lemma infrastructure.
- The approach completely **bypasses the canonical model construction**, so forward_F is never needed.
- Soundness is already sorry-free.

### 1.3 Why It Might Fail

The critical gap is in the FMP proof itself. The current `TruthPreservation.lean` header says:

> "Phase 4 infrastructure is in place. The full filtration lemma proof for all formula cases (atom, bot, imp, box, past, future) requires additional work on modal/temporal MCS properties."

So the FMP TRUTH PRESERVATION is not fully proven. Specifically:
- The `mcsTruth` (membership = truth) equivalence is defined but not proven for temporal cases (G, H, Until, Since).
- The filtration lemma for the Until case likely requires the same forward_F style argument (if phi U psi is in the closure MCS, there must be a witness).

However, the FMP approach constructs the model FROM the closure MCS differently than the canonical model approach. In filtration, you start from a semantic model and quotient it. In the MCS-based approach, you build truth directly from MCS membership. The question is whether the filtration lemma for Until avoids the backward-G dependency.

**Key question**: Does the FMP filtration approach need backward-G? The forward direction (MCS membership implies truth) for Until requires a WITNESS -- which is forward_F. The backward direction (truth implies MCS membership) for G requires showing G(phi) is in the MCS when phi is true everywhere -- which is backward-G.

**Assessment**: The FMP approach likely hits the same wall for the Until/G cases in the filtration truth lemma. The structural issue is that converting between MCS membership and semantic truth for temporal operators inherently involves the forward_F/backward_G pair.

### 1.4 A Variant: Decidability-Based Completeness

A more radical variant: prove completeness via the DECIDABILITY infrastructure rather than the FMP.

The decision procedure (`DecisionProcedure.lean`, `Tableau.lean`) provides:
- A tableau method that terminates for all formulas
- Proof extraction: if the tableau closes, extract a derivation
- Countermodel extraction: if the tableau stays open, extract a finite model

If the decision procedure is proven correct (tableau-closed iff provable, tableau-open iff satisfiable), then completeness follows immediately: if phi is valid, then neg(phi) is unsatisfiable, so the tableau for neg(phi) closes, so neg(neg(phi)) is provable, so phi is provable.

**Status check**: The `Correctness.lean` file exists. Let me note what its sorry status is. From the file listing, `DecisionProcedure.lean`, `Tableau.lean`, `CountermodelExtraction.lean`, `Correctness.lean` are all present. If these have a complete correctness proof, completeness would follow without ANY canonical model construction.

### 1.5 Verdict

| Aspect | Rating |
|--------|--------|
| Novelty | HIGH -- genuinely different from canonical model |
| Feasibility | MEDIUM -- depends on FMP/decidability sorry status |
| Estimated effort | 200-500 lines if FMP truth preservation is mostly done; 1000+ if starting from scratch |
| Confidence | LOW-MEDIUM -- likely hits same wall for Until truth preservation |
| Comparison with Cycle Approach | Potentially BETTER if decidability correctness is close to done |

**Recommendation**: Check sorry count in `Decidability/Correctness.lean` and `Decidability/FMP/TruthPreservation.lean`. If the decidability path is close to sorry-free, it may be a faster route than the cycle contradiction.

---

## 2. Step-Indexed / Fuel-Based Forward_F

### 2.1 Precise Statement

Instead of proving:

```
F(psi) in chain(t) -> exists s > t, psi in chain(s)
```

Prove a BOUNDED version with explicit fuel:

```
F(psi) in chain(t) -> exists s, t < s /\ s <= t + 2^|deferralClosure(psi)| /\ psi in chain(s)
```

The fuel bound `2^|deferralClosure(psi)|` comes from the pigeonhole principle: if psi doesn't appear within this many steps, the restricted theory must cycle, leading to contradiction.

### 2.2 Why It Might Work

- The fuel bound is **computable** from the formula structure, so no circularity in defining it.
- The proof structure becomes: "either psi appears within fuel steps (done), or the restricted theory cycles (derive contradiction)."
- The pigeonhole step is already sorry-free (`pigeonhole_restricted_theories`).
- The contradiction step is exactly the cycle contradiction from report 28 -- but now framed as the else-branch of a bounded search.

### 2.3 Why It Might Fail

The step-indexed formulation doesn't actually avoid the cycle contradiction. It's a **reformulation**, not an alternative. The hard part remains: "if psi doesn't appear within fuel steps, derive contradiction from the cycle." This is exactly the same gap as in `forward_F_via_deferral`.

The fuel bound does help structurally: it turns an existential over all of Z into an existential bounded by a computable function. But the proof of the bounded existential still requires the cycle contradiction.

### 2.4 What It Does Buy

The bounded formulation enables a cleaner proof structure:

```lean
theorem forward_F_bounded (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (ψ : Formula) (h_F : Formula.some_future ψ ∈ deterministic_chain M₀ t) :
    ∃ s : ℤ, t < s ∧ s ≤ t + 2^(deferralClosure ψ).card ∧ ψ ∈ deterministic_chain M₀ s := by
  by_contra h_no_psi
  push_neg at h_no_psi
  -- h_no_psi : for all s, t < s -> s <= t + bound -> psi not in chain(s)
  -- Get the cycle from pigeonhole
  -- Derive contradiction from the cycle
  sorry
```

This is arguably cleaner than the unbounded version because:
1. The bound makes the proof constructive.
2. The `by_contra` immediately gives a bounded "psi absent" hypothesis.
3. The bounded hypothesis is exactly what `until_persists_forward_steps` and `pigeonhole_restricted_theories` consume.

### 2.5 Verdict

| Aspect | Rating |
|--------|--------|
| Novelty | LOW -- reformulation, not new approach |
| Feasibility | Same as cycle approach |
| Estimated effort | Same as cycle approach (the reformulation itself is ~20 lines) |
| Confidence | Same as cycle approach |
| Comparison with Cycle Approach | EQUIVALENT but slightly cleaner proof structure |

---

## 3. Well-Founded Induction on a Different Measure

### 3.1 Why Formula Complexity Fails

Report 24 (Section 4.4) shows that well-founded induction on `sizeof(psi)` fails because the backward-G case for `G(phi)` uses `forward_F(neg(phi))`, and `sizeof(neg(phi)) = sizeof(phi) + 2 > sizeof(G(phi)) = sizeof(phi) + 1`. The sizes increase.

### 3.2 Alternative Measure: Deficiency

Define the **deficiency** of a chain at position t relative to formula psi:

```
deficiency(t, psi) = |{ chi in deferralClosure(psi) | F(chi) in chain(t) and chi not in chain(s) for any s > t }|
```

This counts the number of unresolved F-obligations within the deferral closure at position t.

**Key property**: If F(psi) in chain(t) and psi not in chain(s) for any s > t, then deficiency(t, psi) >= 1 (since psi is itself an unresolved obligation).

**Does deficiency decrease?** Consider the chain stepping from t to t+1:
- Some F-obligations may get resolved at t+1 (chi appears in chain(t+1)), decreasing deficiency.
- New F-obligations may arise at t+1 (F(chi') in chain(t+1) where it wasn't before), increasing deficiency.

The problem: new F-obligations CAN arise. The x_content step can introduce new F-formulas that weren't present before. So deficiency is NOT monotonically non-increasing.

### 3.3 Alternative Measure: Multiset of Unresolved Until-Nesting Depths

Define the **Until-depth** of a formula: depth(psi) = 0 for atoms/bot, depth(phi U psi) = max(depth(phi), depth(psi)) + 1, etc.

Define the multiset of Until-depths of unresolved formulas in the deferral closure. Under the cycle, this multiset is fixed (by restricted theory equality). But this doesn't help -- we need the multiset to DECREASE, not be fixed.

### 3.4 Alternative Measure: F-Nesting Depth

For the mutual induction approach, consider F-nesting depth:

```
f_depth(atom p) = 0
f_depth(bot) = 0
f_depth(phi.imp psi) = max(f_depth(phi), f_depth(psi))
f_depth(box phi) = f_depth(phi)
f_depth(all_future phi) = f_depth(phi)
f_depth(some_future phi) = f_depth(phi) + 1  -- F adds nesting
f_depth(untl phi psi) = max(f_depth(phi), f_depth(psi))
-- etc.
```

The backward-G case for G(phi) uses forward_F(neg(phi)). We have f_depth(neg(phi)) = f_depth(phi.imp bot) = f_depth(phi). And forward_F(psi) needs the truth lemma for psi, which for G-subformulas needs forward_F for neg-subformulas...

The problem: `f_depth(neg(phi)) = f_depth(phi)`, so forward_F(neg(phi)) has the SAME f-nesting depth as forward_F(phi). We need STRICTLY decreasing, not equal.

### 3.5 The Mutual Induction Attempt

Prove simultaneously:
- TL(phi): truth lemma for phi (both directions)
- FF(psi): forward_F for F(psi)

By mutual induction on some well-founded measure m(phi).

The dependency chain is:
- TL(G(phi)) backward direction needs FF(neg(phi))
- FF(psi) needs TL for Until subformulas (to extract witness from phi U psi)
- TL(phi U psi) forward direction needs FF for the Until witness

For any measure m where m(neg(phi)) < m(G(phi)) and m(psi) < m(phi U psi), we would need:
- m(neg(phi)) < m(G(phi)): requires m(neg(phi)) < m(phi) + C for some constant
- But the backward-G case also needs TL(phi), where phi can be arbitrary

The dependencies form a cycle that no single well-founded measure can break. The cycle is: FF(psi) -> TL(top U psi) -> TL(G(neg(psi))) backward -> FF(neg(neg(psi))), and neg(neg(psi)) is LARGER than psi in any reasonable measure.

### 3.6 Verdict

| Aspect | Rating |
|--------|--------|
| Novelty | MEDIUM -- different measures explored |
| Feasibility | LOW -- all measures hit the same structural cycle |
| Estimated effort | N/A -- no viable measure found |
| Confidence | LOW |
| Comparison with Cycle Approach | WORSE -- does not avoid the fundamental circularity |

---

## 4. Direct Syntactic Contradiction from Cycle

### 4.1 The Setup

Given the cycle: positions t+1+i through t+j (length k = j-i) where:
- `chain(m+1) = x_content(chain(m))` for all m
- `restrictedTheory(t+1+i) = restrictedTheory(t+1+j)` on deferralClosure(psi)
- `(top U psi) in chain(m)` for all m in the range
- `neg(psi) in chain(m)` for all m in the range

### 4.2 Attempt: Until Induction with chi = bot

The until_induction axiom:
```
G(psi -> chi) /\ G((top /\ X(chi)) -> chi) -> ((top U psi) -> X(chi))
```

With chi = bot (already analyzed in G_neg_kills_until):
- Premise 1: G(psi -> bot) = G(neg(psi))
- Premise 2: G((top /\ X(bot)) -> bot) = G(theorem), which is a theorem
- Conclusion: (top U psi) -> X(bot), and X(bot) is absurd

So this reduces to: **if G(neg(psi)) in chain(t+1+i), then contradiction**. The gap is deriving G(neg(psi)).

### 4.3 A New Variant: Until Induction with chi = (top U psi)

Try chi = (top U psi). The until_induction axiom gives:

```
G(psi -> (top U psi)) /\ G((top /\ X(top U psi)) -> (top U psi)) -> ((top U psi) -> X(top U psi))
```

Analysis:
- Premise 1: `G(psi -> (top U psi))`. Is `psi -> (top U psi)` a theorem? YES if the seriality axiom gives F(psi) from psi (under reflexive semantics, psi -> F(psi) is valid, and F(psi) <-> top U psi). But under STRICT semantics, psi does NOT imply F(psi). So `psi -> (top U psi)` is NOT a theorem under strict semantics.

  However, in our specific chain, neg(psi) is everywhere, so psi -> (top U psi) is vacuously true in every chain element. But we need G(psi -> (top U psi)) in chain(t+1+i), which requires backward-G -- circular.

- Premise 2: `G((top /\ X(top U psi)) -> (top U psi))`. This says: if X(top U psi) holds (top U psi at the next step), then top U psi holds now. Is this provable? This is essentially `X(top U psi) -> (top U psi)`, which is NOT a theorem (the converse of until_unfold's forward direction).

### 4.4 A More Creative Variant: Build a Derivation from the Cycle Structure

The cycle gives us: for all gamma in deferralClosure, `gamma in chain(t+1+i) iff gamma in chain(t+1+i+k)`.

Since `chain(t+1+i+k) = x_content^k(chain(t+1+i))`, this means:
`gamma in chain(t+1+i) iff X^k(gamma) in chain(t+1+i)` (where X^k means k iterated applications of X).

Now, `X^k` can be expressed as `bot U (bot U (... (bot U gamma)...))` (k layers of Until with bot guard). Define `X^k(gamma)` recursively.

The fact that `gamma in chain(n) iff X^k(gamma) in chain(n)` for all gamma in the closure means the chain satisfies a k-periodicity condition at the object level. Specifically:

```
(top U psi) in chain(n)  iff  X^k(top U psi) in chain(n)
```

And `X^k(top U psi)` semantically means "(top U psi) holds k steps from now."

But this does NOT give a theorem `(top U psi) <-> X^k(top U psi)` -- it's only true in this particular chain, not universally. And we cannot derive G of it without backward-G.

### 4.5 Verdict

| Aspect | Rating |
|--------|--------|
| Novelty | MEDIUM -- creative instantiations explored |
| Feasibility | LOW -- all instantiations hit the G-wrapping barrier |
| Estimated effort | N/A -- no viable instantiation found |
| Confidence | LOW |
| Comparison with Cycle Approach | WORSE -- this IS a sub-problem of the cycle approach |

---

## 5. Omega-Rule / Compactness Argument

### 5.1 The Idea

If psi is absent at all future positions, then for any n, we can derive that neg(psi) holds at positions t+1 through t+n. By some form of "completeness at omega" or compactness, this should give G(neg(psi)).

### 5.2 Why It Fails

**Omega-rule**: The omega-rule says: if `phi(n)` is provable for every n in N, then `forall n, phi(n)` is provable. Applied here: if `X^n(neg(psi))` is in chain(t) for every n (which it is, by iterated x_content steps and neg(psi) being everywhere), can we conclude G(neg(psi)) in chain(t)?

The answer is NO. Having `X^n(neg(psi))` in chain(t) for each n means neg(psi) holds at each individual future step. But G(neg(psi)) means neg(psi) holds at ALL future steps simultaneously. The omega-rule is not available in finitary proof systems, and TM is finitary.

**Compactness**: Propositional temporal logic over Z is NOT compact. The set {F(p)} union {X^n(neg(p)) | n in N} is finitely satisfiable (each finite subset has a model) but not satisfiable (if F(p), then p must hold at some future point, but X^n(neg(p)) for all n says p is never true). So compactness fails.

Wait -- actually this set IS satisfiable: F(p) says p holds at some future time. X^n(neg(p)) says neg(p) at time n. If p holds at time omega... but Z has no omega. So the set IS unsatisfiable over Z with strict semantics. This confirms non-compactness.

### 5.3 Can We Formalize the Non-Compactness Argument?

The non-compactness of temporal logic means we CANNOT use compactness to go from "for each n, neg(psi) at step n" to "G(neg(psi))." This is exactly the gap.

However, the finite deferral argument uses a DIFFERENT route: it doesn't try to derive G(neg(psi)). Instead, it uses the FINITENESS of the deferral closure and the pigeonhole principle to find a cycle, and then derives contradiction from the cycle. The non-compactness is circumvented by working with a finite closure rather than infinitely many instances.

### 5.4 Verdict

| Aspect | Rating |
|--------|--------|
| Novelty | LOW -- well-known limitation |
| Feasibility | NONE -- omega-rule unavailable, logic non-compact |
| Estimated effort | N/A |
| Confidence | NONE |
| Comparison with Cycle Approach | NOT APPLICABLE |

---

## 6. Literature and Mathlib Search

### 6.1 Mathlib Search Results

Searched using lean_leansearch, lean_loogle, and lean_leanfinder for:
- Temporal logic completeness: **Nothing found**. Mathlib has first-order model theory (`FirstOrder.Language.Theory.CompleteType`, `completeTheory`) but no temporal logic.
- Kripke completeness for LTL: **Nothing found**.
- Periodic orbits / pigeonhole: Found `Function.periodicPts`, `Function.periodicOrbit`, `Function.isPeriodicPt_factorial_card_of_mem_periodicPts`, `Function.mem_periodicPts_of_injective`. These are for dynamics, not temporal logic, but the pigeonhole-based periodicity argument aligns with what's already in `FiniteDeferral.lean`.
- Well-founded induction on multisets: Found `Multiset.strongInductionOn`, `Finset.strongInductionOn`. These are available but (as shown in Section 3) no suitable measure exists.

### 6.2 Published Approaches

All published completeness proofs for discrete temporal logic with Until that I am aware of use one of:

1. **Reflexive semantics** (Burgess 1984, GHR 1994, Goldblatt 1992): G(phi) -> phi is valid. This makes the backward-G step trivial: if phi at all future times (including present), G(phi) follows from the T-axiom semantics.

2. **Quasimodels** (GHR 1994, Reynolds 2001): Build a directed graph with explicit eventuality witnesses. But as report 24 shows, the deterministic x_content linkage required for Until persistence is incompatible with witness detours.

3. **Maximal atom sets / Hintikka structures** (Emerson 1990, Clarke-Grumberg-Peled): Finite-state approach where eventualities are resolved by the structure of the Hintikka set. This is essentially the FMP/filtration approach.

4. **Automata-theoretic** (Vardi-Wolper 1986): Completeness via Buchi automata. This is algorithmically elegant but requires substantial automata infrastructure not present in the codebase.

**For strict temporal semantics specifically**: I found no published completeness proof that avoids reflexive G. The standard approach is to INCLUDE the T-axiom G(phi) -> phi as an axiom of the logic, making it reflexive. TM's strict semantics (without T-axiom for G) appears to be non-standard in the literature.

### 6.3 Implication

The fact that no published proof handles strict temporal semantics without G -> phi suggests that the circularity identified in this project is a genuine mathematical difficulty, not merely a formalization gap. The strict semantics of TM may require a novel proof technique.

---

## 7. The Most Promising Unexplored Direction: Decidability-Based Completeness

### 7.1 Bypassing Canonical Models Entirely

The canonical model approach builds an infinite model from MCSes and proves a truth lemma connecting MCS membership to semantic truth. The forward_F/backward_G circularity is intrinsic to this approach.

An entirely different route to completeness:

```
COMPLETENESS: valid(phi) -> provable(phi)

Proof: By contrapositive. Assume not provable(phi).
  Step 1: Run the decision procedure on phi.
  Step 2: Since phi is not provable, the decision procedure returns "unsatisfiable" is false,
          i.e., neg(phi) is satisfiable.
  Step 3: Extract a finite countermodel from the decision procedure.
  Step 4: phi is false in this countermodel, hence not valid.
```

This requires:
- A terminating decision procedure (exists: `DecisionProcedure.lean`, `Tableau.lean`)
- Correctness: decision procedure says "satisfiable" iff the formula is satisfiable
- Countermodel extraction: extracting a finite model from the "satisfiable" case

### 7.2 Codebase Status

The following files exist in `Metalogic/Decidability/`:
- `Closure.lean` -- closure infrastructure
- `SignedFormula.lean` -- signed formulas for tableaux
- `Saturation.lean` -- saturation procedures
- `Tableau.lean` -- tableau method
- `DecisionProcedure.lean` -- decision procedure
- `Correctness.lean` -- correctness proof
- `CountermodelExtraction.lean` -- countermodel from open tableau
- `ProofExtraction.lean` -- proof from closed tableau
- `FMP/` -- finite model property (sorry-free)

If `Correctness.lean` and `ProofExtraction.lean` are close to complete, then completeness can be obtained by:

```
valid(phi) -> provable(phi)
```
via: valid(phi) -> tableau for neg(phi) closes -> proof of neg(neg(phi)) exists -> proof of phi exists.

### 7.3 Why This Might Be Better

- **No canonical model needed**: Completely avoids the forward_F/backward_G circularity.
- **No truth lemma needed**: The truth lemma is replaced by the correctness of the decision procedure.
- **Builds on existing infrastructure**: The decidability module is already substantial.
- **FMP is sorry-free**: The finiteness bound is already established.

### 7.4 Why It Might Be Hard

- The tableau correctness proof may itself have sorries (I cannot determine this without reading those files in detail).
- ProofExtraction (converting closed tableau to a derivation tree) may be complex.
- The tableau method needs to handle Until/Since correctly, which may involve similar eventuality-resolution logic.

### 7.5 Estimated Effort

Unknown without examining sorry status of `Correctness.lean` and `ProofExtraction.lean`. Could range from 200 lines (if mostly done) to 2000+ lines (if substantial gaps remain).

### 7.6 Verdict

| Aspect | Rating |
|--------|--------|
| Novelty | HIGH -- genuinely different proof architecture |
| Feasibility | UNKNOWN -- depends on decidability module sorry status |
| Estimated effort | UNKNOWN (200-2000+ lines) |
| Confidence | MEDIUM -- architecturally sound, implementation status unknown |
| Comparison with Cycle Approach | Potentially MUCH BETTER if decidability module is close to done |

---

## 8. Comparative Analysis

### 8.1 All Approaches Ranked

| Rank | Approach | Confidence | Effort | Avoids Circularity? |
|------|----------|------------|--------|---------------------|
| 1 | Decidability-based completeness (Section 7) | MEDIUM | UNKNOWN | YES (completely) |
| 2 | Cycle contradiction (Report 28) | MEDIUM | 600-900 LOC | Partially (still needs restricted contradiction) |
| 3 | Step-indexed reformulation (Section 2) | MEDIUM | Same as #2 | Same as #2 (equivalent) |
| 4 | FMP-based bypass (Section 1) | LOW-MEDIUM | 200-1000 LOC | Likely NO (same wall for Until) |
| 5 | Deficiency measure induction (Section 3) | LOW | N/A | NO |
| 6 | Syntactic until_induction instantiation (Section 4) | LOW | N/A | NO |
| 7 | Omega-rule / compactness (Section 5) | NONE | N/A | N/A |

### 8.2 The Key Structural Insight

Every approach that tries to work WITHIN the canonical model construction (Sections 2-6) hits the same wall: the meta-to-object conversion for G. The only approaches that avoid this wall entirely are those that bypass the canonical model:

1. **Decidability-based completeness** (Section 7): Replaces the canonical model with a decision procedure + proof extraction.
2. **FMP-based completeness** (Section 1): Replaces the canonical model with a filtration construction (but likely has the same issue for temporal cases).

### 8.3 Recommendation

**Primary recommendation**: Investigate the decidability-based completeness path (Section 7). Read `Correctness.lean`, `ProofExtraction.lean`, and `CountermodelExtraction.lean` to assess their sorry status. If these files are close to complete, this is the fastest path to zero sorries.

**Secondary recommendation**: If the decidability path is far from complete, proceed with the cycle contradiction approach from Report 28, using the step-indexed reformulation (Section 2) for cleaner proof structure.

**Tertiary recommendation**: If both of the above are blocked, consider whether the logic's axiom system should include a bounded induction principle that directly captures the finite deferral argument as an axiom schema. This would be a change to the proof system, not the proof -- but it might be the mathematically correct formulation for strict temporal semantics.

---

## 9. Files Examined

| File | Role | Sorry Status |
|------|------|-------------|
| `Metalogic/Algebraic/FiniteDeferral.lean` | Cycle infrastructure | 1 sorry (forward_F_via_deferral) |
| `Metalogic/Algebraic/DeterministicChain.lean` | Chain construction | 0 sorries |
| `Metalogic/Algebraic/DeterministicFMCS.lean` | FMCS/BFMCS bundle | 4 sorries (2 leaf + 2 derived) |
| `Metalogic/Algebraic/DovetailedChain.lean` | DEPRECATED chain | 6 sorries (architectural) |
| `Metalogic/Bundle/TemporalCoherence.lean` | Backward G/H lemmas | 0 sorries |
| `Metalogic/Decidability/FMP/Filtration.lean` | Filtration equivalence | 0 sorries |
| `Metalogic/Decidability/FMP/FiniteModel.lean` | Finiteness bound | 0 sorries |
| `Metalogic/Decidability/FMP/FMP.lean` | FMP statement | Unknown |
| `Metalogic/Decidability/FMP/TruthPreservation.lean` | Filtration lemma | Incomplete (Phase 4 infra only) |
| `Metalogic/Algebraic/RestrictedTruthLemma.lean` | Restricted truth lemma | Unknown |
| `Syntax/SubformulaClosure.lean` | deferralClosure definition | 0 sorries |
| `Theorems/TemporalDerived.lean` | G_implies_X, X_bot_absurd | 0 sorries |
| `ProofSystem/Axioms.lean` | until_induction axiom | 0 sorries |

---

## 10. Key Formulas and References

### The Two Leaf Sorries

```lean
-- DeterministicFMCS.lean:64
theorem deterministic_forward_F (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (psi : Formula) (h_F : Formula.some_future psi ∈ deterministic_chain M₀ t) :
    ∃ s : ℤ, t < s ∧ psi ∈ deterministic_chain M₀ s

-- DeterministicFMCS.lean:71
theorem deterministic_backward_P (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (psi : Formula) (h_P : Formula.some_past psi ∈ deterministic_chain M₀ t) :
    ∃ s : ℤ, s < t ∧ psi ∈ deterministic_chain M₀ s
```

### The Fundamental Circularity

```
forward_F(psi)
  -> needs backward_G(neg(psi))  [to derive G(neg(psi)) for contradiction]
  -> needs forward_F(neg(neg(psi)))  [temporal_backward_G_with_fwd_F]
  -> sizeof(neg(neg(psi))) > sizeof(psi)  [sizes increase]
```

### The until_induction Axiom

```lean
-- Axioms.lean:506
| until_induction (φ ψ χ : Formula) :
    Axiom (Formula.and
      ((ψ.imp χ).all_future)
      (((Formula.and φ (Formula.untl Formula.bot χ)).imp χ).all_future)
      |>.imp ((Formula.untl φ ψ).imp (Formula.untl Formula.bot χ)))
```
