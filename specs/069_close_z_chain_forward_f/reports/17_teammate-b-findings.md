# Teammate B Research: Alternative Proof Strategies for f_preserving_seed_consistent

**Task**: 69 - close_z_chain_forward_f
**Date**: 2026-03-30
**Focus**: Find alternative proof strategies beyond extraction-based approaches

---

## Summary

**Key Recommendation**: Use the **Absorption Approach** combined with **Compactness/Finite Satisfiability**. The fundamental insight is that `F_unresolved_theory M` is already a subset of M, meaning adding these F-formulas to a consistent seed cannot introduce new inconsistencies that weren't already present in M itself.

The extraction-based approach fails because `neg(phi)` and `G(neg(phi))` are fundamentally different formulas with different modal strengths. No amount of clever extraction ordering can bridge this gap proof-theoretically.

---

## Alternative Approaches Analyzed

### Approach 1: Semantic/Model-Theoretic Argument

**Idea**: Instead of proof-theoretic extraction, construct a model directly or use model existence to derive consistency.

**Analysis**:
- If `f_preserving_seed M phi` were inconsistent, every finite subset would derive bot
- By compactness contrapositive: if every finite subset is satisfiable, the whole set is satisfiable
- For finite subsets L of the seed, we can build a model from the task semantics

**Feasibility**: MEDIUM-HIGH
- The project already has task frame semantics in `Theories/Bimodal/Semantics/`
- Soundness is proven, so derivation implies semantic truth
- Challenge: need to construct explicit models for finite subsets

**Key Insight**: In task semantics, M corresponds to a world in the canonical model. The seed elements are:
- `phi`: the witness formula (satisfiable at some successor)
- `temporal_box_seed M`: formulas that hold at all future times (from M's perspective)
- `F_unresolved_theory M`: F-obligations that M hasn't resolved yet

These are jointly satisfiable at a successor world where phi holds and F-obligations are deferred further.

### Approach 2: Compactness + Finite Satisfiability (RECOMMENDED)

**Idea**: Show every finite subset of the seed is consistent, then conclude the whole seed is consistent.

**Analysis**:
Given finite `L ⊆ f_preserving_seed M phi`:
- Let `L_phi = L ∩ {phi}`
- Let `L_temp = L ∩ temporal_box_seed M`
- Let `L_F = L ∩ F_unresolved_theory M`

Case structure:
1. If `L ⊆ M`: Consistency follows from M's consistency (derivation closure)
2. If `phi ∉ L`: Then `L ⊆ temporal_box_seed M ∪ F_unresolved_theory M ⊆ M`, reduces to case 1
3. If `phi ∈ L` and `phi ∈ M`: Reduces to case 1
4. If `phi ∈ L` and `phi ∉ M`: This is the hard case

**For Case 4**: The key is that `L \ {phi} ⊆ M`. If `L ⊢ bot`, then by deduction `L \ {phi} ⊢ neg(phi)`. Since `L \ {phi} ⊆ M`, we get `neg(phi) ∈ M` by derivation closure. This is consistent with `phi ∉ M` (in fact, required by MCS completeness).

The issue is we need `G(neg(phi)) ∈ M` for contradiction, but we only get `neg(phi) ∈ M`.

**Resolution**: The finite subset `L` doesn't use all the "power" of the seed. The G-lift works when the context is G-liftable. We need to show that for ANY finite L with L ⊢ bot, we can find a contradiction.

**Feasibility**: HIGH - aligns with existing `forward_temporal_witness_seed_consistent` pattern

### Approach 3: Absorption into M (HIGHLY RECOMMENDED)

**Idea**: Since `temporal_box_seed M ⊆ M` and `F_unresolved_theory M ⊆ M`, only `phi` may not be in M. Use this structure.

**Mathematical Argument**:

**Claim**: `f_preserving_seed M phi` is consistent when `F(phi) ∈ M` (M is MCS).

**Proof**:
Let `S = f_preserving_seed M phi = {phi} ∪ temporal_box_seed M ∪ F_unresolved_theory M`.

Note: `temporal_box_seed M ∪ F_unresolved_theory M ⊆ M`.

**Case 1**: `phi ∈ M`
Then `S ⊆ M`. Any finite `L ⊆ S` satisfies `L ⊆ M`. If `L ⊢ bot`, then `bot ∈ M` by derivation closure, contradicting M's consistency. So S is consistent.

**Case 2**: `phi ∉ M`
Then `neg(phi) ∈ M` by MCS completeness.

Suppose S is inconsistent: there exists finite `L ⊆ S` with `L ⊢ bot`.

Sub-case 2a: `phi ∉ L`
Then `L ⊆ M`. Same as Case 1.

Sub-case 2b: `phi ∈ L`
Then `L \ {phi} ⊆ M`. By deduction: `L \ {phi} ⊢ neg(phi)`.

Now partition `L \ {phi}`:
- `L_temp = (L \ {phi}) ∩ temporal_box_seed M` (G-liftable)
- `L_F = (L \ {phi}) ∩ F_unresolved_theory M` (F-formulas in M)

**Key observation**: `L_F` consists of F-formulas that are IN M. These don't block G-lifting because we can handle them differently.

**The Generalized G-lift Argument**:

From `L \ {phi} ⊢ neg(phi)`, repeatedly extract F-formulas from `L_F`:
- Extract `F(psi_1)`: Get `L' ⊢ neg(phi) ∨ G(neg(psi_1))`
- Extract `F(psi_2)`: Get `L'' ⊢ neg(phi) ∨ G(neg(psi_1)) ∨ G(neg(psi_2))`
- ... continue until `L_temp ⊢ neg(phi) ∨ G(neg(psi_1)) ∨ ... ∨ G(neg(psi_k))`

Now `L_temp ⊆ temporal_box_seed M`, which is G-liftable:
`G(neg(phi) ∨ G(neg(psi_1)) ∨ ... ∨ G(neg(psi_k))) ∈ M`

By T-axiom: `neg(phi) ∨ G(neg(psi_1)) ∨ ... ∨ G(neg(psi_k)) ∈ M`

By MCS disjunction property, at least one disjunct is in M:
- If `G(neg(psi_i)) ∈ M` for some i: Contradicts `F(psi_i) ∈ M` (since `F(psi_i) ∈ F_unresolved_theory M`)
- If `neg(phi) ∈ M`: This is already true (we're in case phi ∉ M), NO CONTRADICTION

**THE CRITICAL GAP**: The `neg(phi)` case doesn't yield contradiction!

**Feasibility**: The absorption structure is correct, but the final step fails.

### Approach 4: Structural Induction on Derivation Trees

**Idea**: Instead of extracting formulas, induct on the structure of the derivation `L ⊢ bot`.

**Analysis**:
Show no valid derivation tree can have:
- Leaves in `f_preserving_seed M phi`
- Root labeled `bot`

Induction on derivation tree height:
- Base: Axioms and assumptions
- Step: Modus ponens preserves non-contradiction

**Challenge**: This is essentially proving consistency directly, which is what we're trying to do.

**Feasibility**: LOW - doesn't add new insight over direct proof

### Approach 5: Lindenbaum Extension Properties

**Idea**: Show that any MCS extending `temporal_box_seed M` can be further extended to include `{phi} ∪ F_unresolved_theory M`.

**Analysis**:
Let `W` be an MCS with `temporal_box_seed M ⊆ W`.

Claim: `{phi} ∪ F_unresolved_theory M` is consistent with `W`.

If not, then finite `L ⊆ W ∪ {phi} ∪ F_unresolved_theory M` with `L ⊢ bot`.
This reduces to the same case analysis as Approach 3.

**Feasibility**: MEDIUM - equivalent to Approach 3

### Approach 6: F-formula Invariant Arguments

**Idea**: Use temporal reasoning about F-obligations to show joint satisfiability.

**Analysis**:
- `F(phi) ∈ M` means "phi eventually"
- `F(psi_i) ∈ F_unresolved_theory M` means "psi_i eventually" for each i
- `phi` in the seed means "phi now" (at the witness world)
- Can all these be jointly satisfied?

**Semantic intuition**: Yes! At a world where phi holds:
- "phi now" is satisfied
- "phi eventually" (F(phi)) is satisfied (witnessed by now)
- "psi_i eventually" (F(psi_i)) can be satisfied by future worlds

The F-obligations can be "passed forward" to successors.

**Challenge**: Converting this semantic intuition to a syntactic proof.

**Feasibility**: MEDIUM - provides intuition but not direct proof technique

---

## The Fundamental Obstruction

All extraction-based approaches hit the same wall:

**The `neg(phi)` vs `G(neg(phi))` Problem**:
- When phi is extracted from a derivation, we get `neg(phi)` in the conclusion
- G-lifting gives `G(neg(phi))` which equals `neg(F(phi))` and contradicts `F(phi) ∈ M`
- BUT: if the disjunction includes `neg(phi)` (not wrapped in G), and MCS picks this disjunct, we only get `neg(phi) ∈ M`
- `neg(phi) ∈ M` is COMPATIBLE with `F(phi) ∈ M` (phi false now, true later)

This is not a bug in the proof attempts - it reflects a real mathematical subtlety:
- `neg(phi)`: "phi is false at the current time"
- `G(neg(phi))`: "phi is false at all future times"
- `F(phi)`: "phi is true at some future time"

`neg(phi) ∧ F(phi)` is satisfiable (phi false now, true later).
`G(neg(phi)) ∧ F(phi)` is unsatisfiable.

---

## Recommended Strategy: Hybrid Semantic-Syntactic Approach

### Step 1: Reformulate the Goal

Instead of proving `SetConsistent(f_preserving_seed M phi)` directly via extraction, prove:

**Alternative Formulation**: For any finite `L ⊆ f_preserving_seed M phi`, there exists a world `w` in some Kripke frame satisfying all formulas in L.

This is equivalent to consistency by soundness/completeness of the logic.

### Step 2: Construct the Witness World

Given `L ⊆ f_preserving_seed M phi`:
1. The canonical model has M as a world
2. By `F(phi) ∈ M`, there exists a temporal successor `w` of M with `phi ∈ w`
3. Show `L ⊆ w` using:
   - `phi ∈ w` by construction
   - `temporal_box_seed M ⊆ w` by G-theory transfer
   - `F_unresolved_theory M ⊆ w` by F-preservation (this is what we're trying to prove!)

**CIRCULAR**: This approach requires the very theorem we're proving!

### Step 3: Break the Circularity

The circularity can be broken by working at a more primitive level:

**Key Insight from WitnessSeed.lean**: The `forward_temporal_witness_seed_consistent` proof works because:
1. It only uses `{psi} ∪ g_content(M)` where `g_content(M) = {chi | G(chi) ∈ M}`
2. When `psi ∉ L`, ALL of L is G-liftable
3. When `psi ∈ L`, extracting psi gives a G-liftable context

The difference with `f_preserving_seed` is the addition of F-formulas, which are NOT G-liftable.

**The Fix**: Show that F-formulas in the seed are "semantically redundant" for consistency purposes.

### Step 4: The Redundancy Argument

**Claim**: If `{phi} ∪ temporal_box_seed M` is consistent, then `{phi} ∪ temporal_box_seed M ∪ F_unresolved_theory M` is also consistent.

**Proof Sketch**:
Every formula in `F_unresolved_theory M` is of the form `F(psi)` where `F(psi) ∈ M`.

By MCS properties, `F(psi) ∈ M` implies `neg(G(neg(psi))) ∈ M`.

In the canonical model, this means there exists a temporal successor where psi holds.

For consistency of the seed, we don't need these F-formulas to be "active" in any derivation - they're "witnesses" for future obligations that don't constrain the current world.

**Formalization**: If `L ⊆ seed` with `L ⊢ bot`, and `L_F = L ∩ F_unresolved_theory M`:
- Each `F(psi_i) ∈ L_F` is in M
- If we could show `L \ L_F ⊢ bot` (F-formulas are derivationally redundant), we'd reduce to the base case
- But F-formulas are NOT generally derivationally redundant

**Alternative**: Show that no derivation `L ⊢ bot` can "essentially depend" on F-formulas from `F_unresolved_theory M`.

This requires a careful analysis of what derivations are possible.

---

## Mathematical Argument Sketch (Cleanest Approach)

**Theorem**: `f_preserving_seed M phi` is consistent when `F(phi) ∈ M` (M is MCS).

**Proof**: By strong induction on `|L ∩ F_unresolved_theory M|`, the number of F-formulas from `F_unresolved_theory M` in the finite subset L.

**Base case** (n = 0): `L ⊆ {phi} ∪ temporal_box_seed M`.
This is exactly `temporal_theory_witness_consistent`, already proven.

**Inductive case** (n > 0): Assume the theorem holds for all subsets with fewer than n F-formulas.

Let `L ⊆ f_preserving_seed M phi` with `L ⊢ bot` and `|L ∩ F_unresolved_theory M| = n > 0`.

Pick `F(sigma) ∈ L ∩ F_unresolved_theory M`.

By deduction: `L \ {F(sigma)} ⊢ neg(F(sigma)) = G(neg(sigma))`.

**Case A**: `|L' ∩ F_unresolved_theory M| < n` where `L' = L \ {F(sigma)}`.
Then `L' ⊆ f_preserving_seed M phi` with fewer F-formulas.

We need to show `L' ⊢ bot` to apply IH. But we only have `L' ⊢ G(neg(sigma))`.

**Transform to bot**: Since `F(sigma) ∈ M` and we're deriving `G(neg(sigma)) = neg(F(sigma))`:
- `L' ∪ {F(sigma)} ⊢ bot` (by adding F(sigma) back and using neg-elimination)
- But `L' ∪ {F(sigma)} = L`, which is circular!

**Alternative Case Analysis**:

If `phi ∈ M`: Entire seed ⊆ M, consistency immediate.

If `phi ∉ M`: We need a different argument.

**The Missing Piece**: When `phi ∉ M`, we need to show that the combination of `{phi}` with F-formulas from `F_unresolved_theory M` doesn't create new inconsistencies beyond what `{phi} ∪ temporal_box_seed M` already has.

Since `{phi} ∪ temporal_box_seed M` IS consistent (by `temporal_theory_witness_consistent`), and F-formulas are logically weaker than their G-negations (which we'd need for contradiction), the F-formulas cannot "combine" with phi to derive bot.

**This needs formal proof**, but the intuition is:
- F-formulas make existential claims about the future
- The seed has no G-formulas that would contradict these claims
- Therefore, adding F-formulas cannot create inconsistency

---

## Confidence Level and Risks

**Confidence**: 65%

**Key Risks**:
1. The "redundancy" argument may be harder to formalize than expected
2. Strong induction may not provide the right structure
3. The case `phi ∉ M` remains mathematically subtle

**Recommended Next Steps**:
1. **Study existing working proof** (`forward_temporal_witness_seed_consistent` in WitnessSeed.lean) to understand the exact mechanism that avoids the `neg(phi)` problem
2. **Prove the trivial case**: `phi ∈ M` implies seed consistency (direct)
3. **Focus on phi ∉ M case**: This is where the mathematical content lies
4. **Consider weakening the goal**: Instead of proving full consistency, prove a weaker property sufficient for Lindenbaum extension

---

## References

- [Canonical Models for Normal Logics](https://www.doc.ic.ac.uk/~mjs/teaching/ModalTemporal499/CanonicalNormal_499_v0809_2up.pdf)
- [Completeness in Modal Logic (Open Logic Project)](https://builds.openlogicproject.org/content/normal-modal-logic/completeness/completeness.pdf)
- [Modal Logic Completeness (Chicago REU)](https://math.uchicago.edu/~may/REU2020/REUPapers/Hebert.pdf)
- [Lindenbaum's Lemma](https://builds.openlogicproject.org/content/normal-modal-logic/completeness/lindenbaums-lemma.pdf)
- [Temporal Logic (Stanford Encyclopedia)](https://plato.stanford.edu/entries/logic-temporal/)
- [Temporal Logic Handbook Chapter (Yde Venema)](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- [Model Theory of Modal Logic](https://www2.mathematik.tu-darmstadt.de/~otto/papers/mlhb.pdf)
