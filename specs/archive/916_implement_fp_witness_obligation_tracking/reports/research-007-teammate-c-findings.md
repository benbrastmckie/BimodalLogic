# Research Report: Task #916 (Teammate C -- Semantic Argument for F-Preserving Seed Consistency)

**Task**: Close forward_F and backward_P sorries in DovetailingChain.lean
**Date**: 2026-02-20
**Focus**: Explore the SEMANTIC argument approach for proving F-preserving seed consistency
**Session**: sess_1771653700_ae70b8

---

## 1. The Semantic Argument Approach

### 1.1 Problem Recap

The forward_F sorry requires proving:

```
If F(psi) in M_t, then there exists s > t with psi in M_s.
```

The current chain construction uses seeds of the form `{psi} union GContent(M)` to build the next MCS via Lindenbaum extension. The consistency of this seed is proven syntactically by the `forward_temporal_witness_seed_consistent` lemma (DovetailingChain.lean, line 398). However, F-formulas from M are NOT included in the seed, so there is no guarantee that F-formulas persist to the next step (the "F-persistence problem").

Research-006 Section 4.3 suggested an "F-preserving seed" approach: include all F-formulas from M in the seed, i.e., build seeds of the form:

```
{psi} union GContent(M) union FContent(M)
```

where `FContent(M) = {F(chi) : F(chi) in M}`.

The syntactic proof of this seed's consistency FAILS because G-lifting (`generalized_temporal_k`) cannot handle F-formulas (which are of the form `neg(G(neg(chi)))`). Research-006 recommended trying a SEMANTIC argument instead.

### 1.2 The Core Idea

Instead of proving consistency syntactically (showing no finite subset derives bot), prove it semantically: show that there exists a model satisfying the seed set. By soundness, a satisfiable set is consistent (the contrapositive of soundness: if a derivation of bot existed, the model would satisfy bot, which is impossible).

Specifically:
- Given an MCS M with F(psi) in M, construct a Kripke model where:
  - psi is true at some world w
  - All formulas in GContent(M) are true at w
  - All F-formulas from M are true at w

### 1.3 Why Semantic Arguments Are Attractive

1. **Avoid G-lifting**: The syntactic obstacle is precisely that G-lifting cannot handle neg(G(...)) formulas. A semantic argument does not require G-lifting at all.
2. **Use model-theoretic tools**: Compactness, ultraproducts, truth lemma itself.
3. **Standard technique**: In modal/temporal logic literature, canonical model constructions routinely use semantic arguments for consistency of extended sets.

---

## 2. Model Construction Strategy

### 2.1 Strategy A: Use Completeness (Circular Risk)

**Idea**: If the TM proof system is complete with respect to its intended semantics, then every consistent set is satisfiable. So the seed `{psi} union GContent(M) union FContent(M)` is satisfiable iff it is consistent. But we are trying to prove consistency, so this reduces to: prove satisfiability implies consistency.

**Analysis**: This direction is WRONG. Soundness gives us consistency => satisfiability (via contrapositive). To go the other direction (satisfiability => consistency), we would need the soundness direction which gives: if we derive bot from a set, then the set is unsatisfiable. So: if we CONSTRUCT a model satisfying the set, then no derivation of bot can exist, establishing consistency.

**Critical issue**: This approach requires constructing an ACTUAL KRIPKE MODEL (in the `TaskModel` / `WorldHistory` sense) satisfying the seed. But the completeness proof IS the very result we're building. The truth lemma requires forward_F, and forward_F requires seed consistency, so we cannot use completeness to prove seed consistency without circularity.

**Verdict**: CIRCULAR. Cannot be used directly.

### 2.2 Strategy B: Construct a Custom Model

**Idea**: Build a specific Kripke model satisfying the seed, WITHOUT invoking completeness.

**What we need**: A model `(M_model, Omega, tau, t)` where:
- `truth_at M_model Omega tau t psi` holds
- For all chi in GContent(M): `truth_at M_model Omega tau t chi` holds
- For all F(chi) in M: `truth_at M_model Omega tau t (F(chi))` holds

**Challenges**:

1. **GContent(M) is semantically rich**: GContent(M) = {phi : G(phi) in M}. For ALL these phi to be true at the same world requires the model to satisfy a potentially INFINITE conjunction. We cannot simply assign truth values arbitrarily; they must be consistent with the model structure (the truth function is recursive on formula structure).

2. **F-formulas require future witnesses**: For `truth_at ... tau t (F(chi))` to hold, there must exist some s >= t with `truth_at ... tau s chi`. So each F-formula in M imposes an existential demand on the model's temporal structure.

3. **Interaction constraints**: The model must simultaneously satisfy GContent formulas (which propagate universally to all future times) and F-formulas (which need specific witnesses at future times). These constraints must be jointly satisfiable.

**Approach outline**:

To build such a model, we would essentially need to:
1. Take the MCS M and its formulas as data
2. Build a temporal structure (a linear order, or a subset of Int) as the time domain
3. Assign to each time point a valuation consistent with M's structure
4. Verify the truth conditions hold

This is essentially re-doing a completeness proof for a SINGLE MCS, which is very close to what the canonical model construction does. The canonical model for temporal logic IS the family of MCS's.

**Verdict**: This approach is effectively EQUIVALENT to the canonical model construction we're already building. It does not simplify the problem.

### 2.3 Strategy C: Use Existing Soundness + Syntactic Consistency Proof

**Idea**: We ALREADY have soundness (proven in Soundness.lean). Soundness says: if `Gamma derives phi`, then `Gamma models phi`. Contrapositively: if `Gamma does NOT model phi`, then `Gamma does NOT derive phi`.

But what we need for seed consistency is: `NOT (Gamma derives bot)`. By soundness contrapositive: if `Gamma does NOT model bot`, i.e., if there exists a model satisfying Gamma, then Gamma is consistent.

So the semantic argument reduces to: construct a model satisfying the seed. But constructing a model satisfying an arbitrary consistent set IS the completeness theorem, which is what we're trying to prove.

**Verdict**: CIRCULAR (same as Strategy A).

### 2.4 Strategy D: Compactness-Based Argument

**Idea**: Use the compactness theorem for the logic. If every FINITE subset of the seed is consistent, then the full seed is consistent.

Mathlib has `isSatisfiable_iff_isFinitelySatisfiable` for first-order logic. However, this project's TM logic is NOT first-order; it has custom modal and temporal operators. There is no compactness theorem proven for TM logic in this codebase.

Even if we had compactness, proving every finite subset is consistent faces the same challenge: we need to show that any finite subset of `{psi} union GContent(M) union FContent(M)` is consistent. A finite subset looks like `{psi, g1, ..., gn, F(c1), ..., F(cm)}` where gi in GContent(M) and F(cj) in M. This finite consistency claim is EXACTLY what we need to prove, and it faces the same G-lifting obstacle for the F-formulas.

**Subtlety**: Actually, compactness could help in a different way. The seed is an infinite set, and if we could show every FINITE subset is consistent without proving full consistency, we gain something. But each finite subset still contains F-formulas, and the G-lifting argument still fails for those.

**Verdict**: BLOCKED. No compactness theorem available for TM, and finite subsets face the same obstacle.

### 2.5 Strategy E: Use the MCS M Itself as a Model Fragment

**Idea**: The MCS M is already a model of all its formulas (in the MCS-membership sense). Can we use M itself as evidence that the seed is consistent?

The key observation: M contains ALL of:
- psi? No, M contains F(psi), not necessarily psi itself.
- GContent(M): By definition, G(phi) in M implies phi in GContent(M). By the T-axiom G(phi) -> phi, we have phi in M. So GContent(M) subset M.
- FContent(M): Every F(chi) in FContent(M) is in M by definition.

So `GContent(M) union FContent(M) subset M`, and M is consistent (as an MCS). Therefore `GContent(M) union FContent(M)` is consistent (a subset of a consistent set is consistent).

The only additional element is psi. The question is whether `{psi} union GContent(M) union FContent(M)` is consistent.

We KNOW `{psi} union GContent(M)` is consistent (proven in `forward_temporal_witness_seed_consistent`). The question is whether adding FContent(M) breaks consistency.

**Key insight**: GContent(M) union FContent(M) is a SUBSET of M (as shown above). And we know {psi} union GContent(M) is consistent. But we do NOT know that {psi} union M is consistent (M is maximal, so adding any formula not in M makes it inconsistent). Specifically, if psi is NOT in M, then {psi} union M is inconsistent.

However, adding a SUBSET of M (FContent) to a set that is already consistent with GContent(M) might not break consistency. This is the crux: does adding more elements from M (specifically the F-formulas) to an already-consistent seed preserve consistency?

This is NOT automatic. Adding formulas to a consistent set can make it inconsistent even if all the added formulas individually come from a consistent set. Example: {p, neg(p)} is inconsistent even though both p and neg(p) individually belong to some consistent set.

**Verdict**: The observation that FContent subset M is valuable but INSUFFICIENT to conclude seed consistency.

---

## 3. A Deeper Analysis: Why F-Formulas Might Be "Free"

### 3.1 Structural Independence of F-Formulas from GContent

F-formulas have the form `neg(G(neg(chi)))`. GContent formulas have the form `phi` where `G(phi) in M`.

The question: can `{psi, g1, ..., gn, F(c1), ..., F(cm)}` derive bot?

A derivation of bot from this set would, after applying the deduction theorem, give:
```
g1, ..., gn, F(c1), ..., F(cm) |- neg(psi)
```

By `forward_temporal_witness_seed_consistent`, we know `g1, ..., gn |- neg(psi)` is impossible (otherwise {psi} union GContent(M) would be inconsistent). So any derivation must ESSENTIALLY USE the F(ci) formulas.

Now, F(ci) = neg(G(neg(ci))). In the Hilbert-style proof system for TM, what can be derived from F-formulas?

The F-formulas are NEGATIONS of G-formulas. In TM logic:
- From `neg(G(neg(chi)))` alone, we can derive very little. There is no axiom that extracts content from a negated G-formula.
- The only way to derive bot from F-formulas and GContent-formulas is if there is a propositional combination that yields bot.

### 3.2 Propositional Independence Argument

Consider the propositional structure of the seed. The seed contains:
- psi (arbitrary formula)
- phi_i where G(phi_i) in M (from GContent)
- neg(G(neg(chi_j))) where F(chi_j) in M (F-formulas)

At the propositional level, these are independent atoms (since the outermost connective of each GContent formula is different from that of each F-formula).

BUT this argument is WRONG in general. Modal and temporal logic formulas are not propositionally independent. For example:
- If phi_1 = G(neg(chi_1)) then G(phi_1) is in M and phi_1 = G(neg(chi_1)) is in GContent(M). But also F(chi_1) = neg(G(neg(chi_1))) = neg(phi_1). So {phi_1, F(chi_1)} = {phi_1, neg(phi_1)}, which is inconsistent!

### 3.3 The Critical Constraint: No Direct Conflicts

Wait -- the scenario in 3.2 is IMPOSSIBLE because:
- If G(neg(chi_1)) in GContent(M), then G(G(neg(chi_1))) in M (by definition of GContent + G(phi) -> G(G(phi)) via temp_4).
- Actually, G(neg(chi_1)) in GContent(M) means G(G(neg(chi_1))) in M. By the T-axiom: G(neg(chi_1)) in M.
- If also F(chi_1) = neg(G(neg(chi_1))) in M, then M contains both G(neg(chi_1)) and neg(G(neg(chi_1))), contradicting M's consistency.

So: **if both G(neg(chi)) and F(chi) are in M, then M is inconsistent.** Since M is an MCS (consistent), this cannot happen.

This means: for every chi such that F(chi) in M, we have G(neg(chi)) NOT in M. Equivalently, neg(chi) NOT in GContent(M) (since neg(chi) in GContent(M) iff G(neg(chi)) in M).

Conversely: for every phi in GContent(M), G(phi) in M. If F(neg(phi)) = neg(G(neg(neg(phi)))) = neg(G(phi)) were also in M, that would contradict M's consistency. So neg(phi) is NOT among the chi such that F(chi) in M. In other words, the GContent formulas and the "inner" formulas of the F-content are COMPATIBLE in M.

### 3.4 The Precise Obstacle

Despite the compatibility constraint (no direct conflicts between GContent and FContent), the consistency of the UNION WITH PSI is not guaranteed by this alone. The issue is that there could be COMPLEX derivations involving multiple GContent and FContent formulas that together derive neg(psi), even though no single formula conflicts.

However, for such a derivation to work, it would need to extract content from F-formulas. In TM's Hilbert-style system, the ONLY thing you can do with F(chi) = neg(G(neg(chi))) is:
1. Use it as a hypothesis in a propositional derivation
2. Combine it with other formulas via modus ponens

There is NO axiom of the form `F(chi) -> X` for any interesting X. The formula F(chi) is a negation, so it can only be used to derive bot when combined with its positive counterpart G(neg(chi)). But we just showed that G(neg(chi)) is NOT in GContent(M) for any F(chi) in M.

### 3.5 The Key Theorem (Conjecture)

**Conjecture**: If M is an MCS and F(psi) in M, then `{psi} union GContent(M) union FContent(M)` is consistent.

**Argument sketch**:
Suppose for contradiction that some finite L subset of the seed derives bot. Write L = {psi, g1,...,gn, F(c1),...,F(cm)} where gi in GContent(M) and F(cj) in M.

By the deduction theorem applied m times to remove the F-formulas:
```
psi, g1,...,gn |- F(c1) -> (F(c2) -> ... (F(cm) -> bot)...)
```

This simplifies (since A -> (B -> bot) iff A -> neg(B), etc.) to:
```
psi, g1,...,gn |- neg(F(cm)) (in the inner case)
psi, g1,...,gn |- G(neg(cm))
```

Wait, this is not quite right. Let me be more careful.

If `{psi, g1,...,gn, F(c1),...,F(cm)} |- bot`, then by deduction:
```
{g1,...,gn, F(c1),...,F(cm)} |- neg(psi)
```

Now apply G-lifting to the g1,...,gn (which ARE in GContent): by `generalized_temporal_k`, wrapping with G:
```
{G(g1),...,G(gn), F(c1),...,F(cm)} |- G(neg(psi))
```

NO -- this is EXACTLY the step that fails. G-lifting requires ALL hypotheses to be wrapped with G. We cannot G-lift the F(ci) hypotheses because G(F(ci)) = G(neg(G(neg(ci)))) is not F(ci).

So the syntactic argument fails here, as previously identified.

### 3.6 Alternative: The "Derivation Surgery" Approach

What if we analyze the structure of any derivation of bot from the seed and show it's impossible?

In TM's Hilbert system, derivations are trees of modus ponens applications with axiom and assumption leaves. The F-formulas `neg(G(neg(chi)))` can only be used as:
1. Leaves (assumptions)
2. The antecedent in a modus ponens: if F(chi) is an assumption and `F(chi) -> X` is derived, then X is derived.

For `F(chi) -> X` to be derivable, we need either:
- An axiom instance `F(chi) -> X` -- but no TM axiom has this form for arbitrary F(chi)
- A derivation from other assumptions that produces `F(chi) -> X`

The only way to produce bot from neg(A) (where A = G(neg(chi))) is to combine it with A itself, i.e., derive A from the remaining hypotheses and then apply modus ponens with neg(A).

So: to derive bot from {psi, g1,...,gn, F(c1),...,F(cm)}, we would need (for some chain of deductions) to derive G(neg(ci)) from {psi, g1,...,gn, remaining F-formulas}. But G(neg(ci)) is a G-formula; deriving it from non-G-hypotheses requires temporal necessitation, which is only applicable when the derivation is from the empty context.

Specifically: in TM, `Gamma |- G(phi)` is NOT derivable in general from `Gamma |- phi`. Temporal necessitation only gives `[] |- phi` implies `[] |- G(phi)`. So G(neg(ci)) cannot be derived from non-empty context psi, g1,...,gn unless it is itself in the context or derivable from axioms alone.

**This is the crucial insight**: G-formulas cannot be derived from non-G hypotheses in the TM Hilbert system (without temporal necessitation from the empty context). The only way G(neg(ci)) can appear in a derivation is if:
1. It's an assumption (but it's NOT in our seed -- we verified G(neg(ci)) NOT in M, and the seed only contains GContent elements and F-formulas, not arbitrary G-formulas)
2. It's a theorem (derivable from empty context)

If G(neg(ci)) is a theorem (derivable from []), then by soundness it's valid. Then neg(ci) holds at all times in all models, meaning ci is false at all times, meaning F(ci) is false. By soundness, F(ci) would not be in any consistent set, contradicting F(ci) in M.

So G(neg(ci)) is NOT a theorem and NOT in the seed. Therefore it CANNOT be derived from the seed. Therefore the seed cannot derive bot via the route of combining F(ci) with G(neg(ci)).

### 3.7 But There Are Subtler Routes

The argument in 3.6 considers only the "direct conflict" route. But there could be more complex derivations. For instance, from multiple F-formulas and GContent formulas, one might derive an intermediate formula that conflicts with something else.

However, the fundamental constraint remains: in TM's Hilbert system, WITHOUT temporal necessitation from the empty context, you cannot introduce NEW G-formulas as intermediate results. Any G-formula that appears in the derivation must either be:
1. An assumption
2. Derived from other G-formulas via axioms (like G(phi -> psi) -> (G(phi) -> G(psi)))
3. A theorem (derivable from [])

The GContent formulas are phi_i (not G-formulas themselves). The F-formulas are negations of G-formulas. Propositional combinations of these (via modus ponens with prop_k, prop_s, ex_falso, peirce) cannot produce G-formulas.

The only TM axioms that produce G-formulas as outputs are:
- `temp_4`: G(phi) -> G(G(phi)) -- requires G(phi) as input
- `temp_a`: phi -> G(P(phi)) -- produces a G-formula from any phi
- `temp_l`: always(phi) -> G(H(phi)) -- requires always(phi) as input
- `temp_future`: Box(phi) -> G(Box(phi)) -- requires Box(phi) as input
- `temp_k_dist`: G(phi -> psi) -> (G(phi) -> G(psi)) -- requires two G-formulas
- `temp_t_future`: G(phi) -> phi -- CONSUMES a G-formula

So from phi_i (GContent formulas) and neg(G(neg(chi_j))) (F-formulas), using temp_a we can derive G(P(phi_i)) and G(P(neg(G(neg(chi_j))))). These are new G-formulas, but they have very specific structure and cannot in general be combined to derive G(neg(chi_k)) for any k.

---

## 4. Lean Formalization Path

### 4.1 What a Semantic Proof Would Look Like in Lean

A semantic proof of seed consistency would require:
1. Construct a `TaskModel F` and `WorldHistory F` and time `t`
2. Show `truth_at M Omega tau t phi` for every phi in the seed
3. Conclude `SetConsistent seed` by soundness contrapositive

Step 3 is straightforward given soundness. Steps 1-2 are the hard part.

### 4.2 Required Infrastructure

To build the model in Step 1:
- Need a `TaskFrame D` with a time domain D (could use Int or Nat)
- Need a `TaskModel F` with a valuation function
- Need a set of `WorldHistory F` as Omega
- Need the Omega to be shift-closed (for soundness to apply)

### 4.3 The Fundamental Difficulty

Building a model satisfying an arbitrary MCS is THE completeness theorem. We cannot use the completeness theorem to prove a lemma that the completeness theorem depends on. This creates an unavoidable circularity.

### 4.4 Recommendation: Pure Syntactic Approach

Given the circularity of the semantic approach, I recommend pursuing a SYNTACTIC proof instead, building on the "derivation surgery" analysis from Section 3.6-3.7.

The key insight is: **In TM's Hilbert system, F-formulas (negations of G-formulas) cannot interact with GContent formulas to produce new contradictions beyond the direct conflict route, and the direct conflict route is blocked by MCS consistency of M.**

This can be formalized as a structural induction on derivation trees, showing that any derivation of bot from `{psi} union GContent(M) union FContent(M)` can be transformed into a derivation of bot from `{psi} union GContent(M)` alone (by replacing each use of F(ci) with an appropriate propositional tautology or vacuous step), contradicting the already-proven consistency of `{psi} union GContent(M)`.

---

## 5. Risk Assessment

### 5.1 Semantic Approach: HIGH RISK

| Factor | Assessment |
|--------|------------|
| Circularity | FATAL: Cannot construct models without completeness, which depends on forward_F |
| Infrastructure | Enormous: would need full model construction machinery |
| Formalization effort | Very high: months of work |
| Mathematical novelty | Low: essentially re-deriving completeness |

The semantic approach is fundamentally circular for this specific use case. It cannot be used to prove the seed consistency lemma because the model construction IS the completeness proof.

### 5.2 Syntactic "Derivation Surgery" Approach: MEDIUM RISK

| Factor | Assessment |
|--------|------------|
| Circularity | NONE: purely syntactic argument |
| Key insight | F-formulas cannot generate G-formulas in derivations |
| Formalization effort | Medium: structural induction on derivation trees |
| Mathematical novelty | Medium: custom analysis of TM derivation structure |
| Risk | Analysis in 3.7 shows subtler routes via temp_a need careful handling |

### 5.3 Original G-lifting Approach: KNOWN FAILURE

Already proven impossible in research-006 Section 4.3. G-lifting cannot handle F-formulas.

---

## 6. Confidence Level

**Confidence: MEDIUM (50%)**

- HIGH confidence that the semantic approach is circular and should NOT be pursued.
- MEDIUM confidence that the syntactic "derivation surgery" approach could work, but temp_a introduces complications (it can generate G-formulas from arbitrary inputs).
- The F-preserving seed conjecture remains PLAUSIBLE but UNPROVEN. The syntactic derivation analysis provides the strongest available evidence that it should be true.

---

## 7. Summary

1. **The semantic argument is fundamentally circular**: Constructing a Kripke model satisfying the seed requires the completeness theorem, which depends on forward_F, which depends on the seed consistency we're trying to prove. This circularity cannot be broken within the current architecture.

2. **No shortcut via compactness**: TM compactness is not proven in the codebase, and finite subsets face the same obstacle.

3. **MCS consistency provides useful constraints**: The fact that M is consistent means GContent and FContent cannot directly conflict (if G(neg(chi)) in GContent then F(chi) not in M, and vice versa). But this is necessary, not sufficient.

4. **The most promising syntactic route** is a "derivation surgery" argument: analyze the structure of any hypothetical derivation of bot from the seed and show it cannot exist. The key structural fact is that F-formulas (negated G-formulas) cannot interact with GContent formulas to produce G-formulas in the Hilbert system, blocking the only route to contradiction.

5. **The temp_a axiom (phi -> G(P(phi)))** is the main complication, as it can generate G-formulas from arbitrary inputs. However, the G-formulas it produces have a very specific structure (G(P(...))) that should not lead to contradictions with F-formulas.

6. **Recommendation**: Abandon the semantic approach. Pursue the syntactic derivation surgery approach, or alternatively, restructure the chain construction to avoid needing the F-preserving seed conjecture entirely (e.g., by building a chain where F-formula persistence is ensured by construction, not by seed inclusion).

---

## 8. References

### Project Files
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- 2 forward_F/backward_P sorries
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- TemporalCoherentFamily definition
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` -- Truth lemma (depends on forward_F)
- `Theories/Bimodal/Semantics/Truth.lean` -- Semantic truth definition
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` -- BMCS truth definition
- `Theories/Bimodal/Metalogic/Soundness.lean` -- Soundness theorem (no sorry)
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- GContent/HContent definitions

### Prior Research
- `specs/916_.../reports/research-006.md` -- Section 4.3 (F-preserving seed conjecture), Section 5.1 (semantic suggestion)
- `specs/916_.../reports/research-005-teammate-a-findings.md` -- Chain-based approach failures
- `specs/916_.../reports/research-005.md` -- Prior synthesis

### Key Lean Definitions
- `SetMaximalConsistent M` -- M is consistent and maximal
- `SetConsistent S` -- No finite subset of S derives bot
- `GContent M = {phi : G(phi) in M}` -- G-content of an MCS
- `Formula.some_future phi = neg(G(neg(phi)))` -- F operator definition
- `forward_temporal_witness_seed_consistent` -- Proves `{psi} union GContent(M)` consistent when `F(psi) in M`
