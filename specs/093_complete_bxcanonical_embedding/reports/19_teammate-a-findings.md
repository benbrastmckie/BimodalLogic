# Teammate A Findings: Bilateral Pairs — Primary Approach Analysis

## Key Findings

### 1. Does Bilateral Pairs Avoid the forward_F Problem?

The bilateral pairs proposal does NOT solve the forward_F problem as stated. It relocates the problem but does not eliminate it. Here is why:

**The root cause of the forward_F gap** is not the absence of an explicit falsity set — it is that Lindenbaum extension (via `.choose`) is unconstrained. The current `enriched_fwd_step` (RootScopedChain.lean:561) already uses a sophisticated BX11 fold (`enriched_fwd_fold_with_witness`) to compute a compound formula β' such that F(β') ∈ M, then extends `{β'} ∪ g_content(M)` to an MCS via `set_lindenbaum`. The fold guarantees that at least one formula w with F(w) ∈ M ends up directly in M' (`enriched_fwd_step_resolves_one`). But the step for OTHER formulas in `sigma_list` only guarantees the disjunction: χ ∈ M' ∨ F(χ) ∈ M'. The `.choose` in Lindenbaum can perpetually select the F(χ) horn, never placing χ itself in the chain.

**With bilateral pairs**, the construction would instead extend `{β'} ∪ g_content(M)` to a balanced pair ⟨V, F⟩. The `.choose` for Lindenbaum-like extension to a balanced pair still exists — we need some maximal pair extending the seed. The disjunction χ ∈ V ∨ ¬χ ∈ V (i.e., χ ∈ F or χ ∈ V) gives the same non-determinism. The explicit falsity set F tells us whether χ is true or false at the new node, but the choice between "χ is false" and "χ is true" is still unconstrained by the pair extension.

### 2. How Would the Balanced Extension Work?

A balanced pair ⟨V, F⟩ satisfies:
- V and F are disjoint (no formula in both)
- V ∪ F = all formulas (every formula is either verified or falsified) — this is totality
- Negation closure: ¬φ ∈ V iff φ ∈ F
- MP closure: if φ ∈ V and φ → ψ ∈ V, then ψ ∈ V

This is simply an alternative presentation of a maximal consistent set. The verification set V is exactly the MCS (the consistent set of all "true" formulas), and F is its complement. Balanced extension = Lindenbaum extension. They are definitionally equivalent:
- MCS M corresponds to ⟨M, complement(M)⟩
- balanced pair ⟨V, F⟩ corresponds to the MCS V (which must be consistent and deductively closed)

**Consequence**: Bilateral pairs do NOT provide more control over which formulas end up in V than MCS construction provides over which formulas end up in the MCS. The `.choose` is exactly the same axiom of choice application in both cases. No advantage over Lindenbaum.

### 3. Could Negation Closure Help Control forward_F?

The negation closure property (¬φ ∈ V iff φ ∈ F) is already implicit in the MCS framework: SetMaximalConsistent already guarantees that for each formula φ, exactly one of φ ∈ M or ¬φ ∈ M holds (by `negation_complete`). So there is literally no new information in the explicit falsity set F of a bilateral pair — it is entirely determined by V.

The proposal suggests that "explicit falsity sets help control what ends up in the chain." This would require that F(ψ) ∈ V (i.e., ψ ∈ F for some later node) implies ψ ∈ V' for V' at a later step. But this is exactly the forward_F property we cannot prove. The bilateral framing does not provide a new proof route because:

- F(ψ) ∈ V means ψ ∉ G(¬ψ) content, i.e., ¬ψ ∉ V means ψ ∈ F (falsity set), which means ψ is false... wait, this is backwards. F(ψ) ∈ V means "some future time has ψ true," which means ψ ∈ V' for some future V'. But proving this is EXACTLY forward_F. The bilateral frame makes this semantic; it does not make it syntactically constructive from the MCS chain.

### 4. BX Axiom Interaction with Bilateral Pairs

The BX11 axiom (temporal linearity, the key source of difficulty) states that for any φ, ψ with F(φ) ∈ M and F(ψ) ∈ M, exactly one of three holds:
- F(φ ∧ ψ) ∈ M (both realized at same future time)
- F(φ ∧ F(ψ)) ∈ M (φ earlier than ψ)
- F(F(φ) ∧ ψ) ∈ M (ψ earlier than φ, i.e., φ later)

In Case 3, the BX11 fold currently changes the direct witness from the target to χ (see RootScopedChain.lean:338-360). This is the Case 3 displacement that makes forward_F unprovable for the displaced formula.

In a bilateral framework, BX11 would appear as the same three cases applied to the "verified" set V. The fold computation and its displacement behavior are identical. The bilateral framing adds no leverage here.

### 5. What Would Bilateral Pairs Require in Terms of Re-Implementation?

If the bilateral pairs approach were pursued despite the above analysis, it would require:
- Defining `BiPair` structure (V : Set Formula, F : Set Formula) with closure axioms
- Proving that balanced pairs correspond bijectively to MCS (this is straightforward but tedious)
- Redefining BXPoint, bx_le, bx_modal_equiv in terms of BiPair
- Rewiring the canonical frame infrastructure (~200+ definitions/theorems in Frame.lean and downstream)
- The chain construction would still need `set_lindenbaum`-equivalent for BiPairs

**Estimated cost**: 20-40 hours with no improvement in the forward_F probability, because the core obstruction — unconstrained Lindenbaum choice — is identical.

### 6. The Real Gap and Why the Literature Handles It Differently

The team research (report 18) correctly identifies that Burgess 1984, Goldblatt 1992, and GHR 1994 handle forward_F semantically: the integer temporal domain ℤ provides well-founded ordering, so F(ψ) at time t semantically forces ψ at some finite future time t' > t. The canonical model's chain is built to mirror this semantic structure.

The syntactic construction in this codebase lacks this semantic anchor: each Lindenbaum step is independent. The ordered-discharge chain with "never-resolved count" termination (from team research report 18, Teammate D) is the right direction because it forces STRUCTURAL guarantees into the chain definition itself, making the chain witness the well-foundedness rather than relying on unconstrained choice.

## Recommended Approach

**Do not pursue bilateral pairs.** They are isomorphic to the existing MCS approach and provide no new proof leverage for forward_F. The approach would require significant re-implementation (20-40 hours) with zero improvement in the forward_F probability.

**Recommended instead**: The ordered-discharge chain with "never-resolved count" as a well-founded termination measure (Teammate D's approach from report 18). This is the only strategy that:
1. Provides structural guarantees that each formula with F-obligation is eventually resolved
2. Is consistent with the existing 6,400+ lines of sorry-free infrastructure
3. Has a concrete mathematical justification (finite sigma_list, strictly decreasing count)

If pursuing the ordered-discharge chain, the key step is proving that the seed `{target} ∪ g_content(M) ∪ f_carry(M)` is consistent when F(target) ∈ M. The comment at RootScopedChain.lean:1256-1268 identifies this as the immediate goal. The obstacle is that `G(F(χ)) ∈ M` is not guaranteed from `F(χ) ∈ M`, so the standard generalized temporal K argument does not extend. This requires a specialized consistency argument — possibly using the BX4 axiom `φ → H(F(φ))` or the interaction between f_carry and g_content.

**Secondary recommendation**: Investigate whether `enriched_fwd_step` can be modified to process `target` LAST in the BX11 fold (so Case 3 cannot fire for target, guaranteeing target ∈ M'). This is noted in team research report 18 as an uninvestigated variant. If this works, it would solve forward_F for the specifically-scheduled formula at each step, which may be sufficient.

## Evidence/Examples

### Why Bilateral = MCS (Formal Equivalence)

In the existing framework, `SetMaximalConsistent M` means:
- `¬ SetConsistent_derives_bot M` (consistency: no finite subset derives ⊥)
- `∀ φ, φ ∈ M ∨ ¬φ ∈ M` (completeness/totality)
- `SetMaximalConsistent.negation_complete` proves this directly

A balanced pair ⟨V, F⟩ satisfies:
- V ∩ F = ∅ (disjointness)
- V ∪ F = {all formulas} (totality, same as completeness above)
- φ ∈ F iff ¬φ ∈ V (negation closure, which is equivalent to `negation_complete`)
- MP closure (equivalent to `closed_under_derivation`)

The correspondence is: V = M, F = complement(M). The definitions are the same object described differently.

### Why forward_F Remains Unprovable in Bilateral Framework

Concretely: suppose sigma_list = [ψ, χ] and F(ψ), F(χ) ∈ chain(0) = M₀.

Under the current construction: at step 1 (target = ψ), BX11 is applied to (ψ, χ). If Case 3 fires: F(F(ψ) ∧ χ) ∈ M₀. The compound becomes β' = F(ψ) ∧ χ. Lindenbaum extends {F(ψ) ∧ χ} ∪ g_content(M₀) to M₁. Then χ ∈ M₁ (resolved), but ψ ∉ M₁ and F(ψ) ∈ M₁.

Under bilateral pairs: the same fold gives β' = F(ψ) ∧ χ. Balanced-pair extension of {F(ψ) ∧ χ} ∪ g_content(M₀) gives V₁ with χ ∈ V₁ and F(ψ) ∈ V₁, but ψ ∈ F₁ (falsity set, i.e., ψ ∉ V₁). The falsity set makes this explicit, but the same outcome obtains: ψ is not resolved.

The bilateral representation does not change the mathematical content — it only renames "not in the MCS" to "in the falsity set."

### Why Ordered-Discharge Is Different

The ordered-discharge approach would define the chain so that at step n targeting ψ, the seed is `{ψ} ∪ g_content(chain(n))`. This seed is consistent when F(ψ) ∈ chain(n) (needs proof), which guarantees ψ ∈ chain(n+1). The "never-resolved count" (`|{χ ∈ sigma_list | F(χ) ∈ chain(n) ∧ ∀ m < n, χ ∉ chain(m)}|`) decreases at each step because ψ is newly resolved. Since sigma_list is finite, the count reaches 0 in at most |sigma_list| steps, after which all F-obligations have been resolved at least once. forward_F then follows from the periodicity of the schedule.

## Confidence Level

**High confidence (90%)** that bilateral pairs do not solve the forward_F problem.

**Justification**:
1. The mathematical equivalence between bilateral pairs and MCS is tight and well-known in the proof-theoretic literature (bilateral calculi like Negri-von Plato are equivalent to standard Gentzen systems for classical logic).
2. The specific obstruction (unconstrained Lindenbaum choice, Case 3 displacement in BX11 fold) is present in both frameworks identically.
3. Report 18 (4-teammate analysis, consensus finding) already identified that the gap is at the construction level, not the representational level. Bilateral pairs change representation, not construction.
4. The false dichotomy between "verified" and "falsified" in bilateral pairs does not help because the BX axioms force exactly that dichotomy already (via `negation_complete`).

**Medium confidence (55-65%)** that the ordered-discharge chain approach (Teammate D's recommendation) can succeed, consistent with report 18 synthesis.
