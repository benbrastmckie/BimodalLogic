# Research Report: Task #88 — Teammate A (Primary Approach, Round 2)

**Task**: 88 — Close 6 remaining BXCanonical sorries
**Date**: 2026-04-09
**Focus**: Chain extraction approach — feasibility assessment after Phase 1 failure
**Context**: Phase 1 of plan 01 added BX11/BX12 axioms (temp_linearity, F_until_equiv) but
Phase 2 (bx_le linearity) was blocked. This report reassesses the chain extraction approach.

---

## Key Findings

### Finding 1: The Axioms Already Exist — Phase 2 Was the Real Blocker

The Phase 1 summary correctly identifies the problem: `bx_le` forms a **tree** (partial order),
not a linear order. Adding `temp_linearity` constrains F-witnesses **within** a single MCS but
does NOT constrain the G-content relationship **between** arbitrary MCS pairs. Two MCSs can have
incomparable G-content even when both contain `F(phi) and F(psi)` with the linearity schema
satisfied locally.

This means:
- `temp_linearity` → "within a single MCS, future eventualities are linearly ordered"
- `bx_le_total` would require → "between ANY two MCSs, one's G-content is subset of the other"

These are fundamentally different claims. The existing plan's Phase 2 approach was mathematically
incorrect from the start.

**What this means for the chain extraction approach**: The chain extraction approach is CORRECT
in recognizing this and proposing to work with a SPECIFIC linear chain rather than proving
global linearity.

### Finding 2: The Chain Extraction Approach Is the Standard Technique — And Is Viable

The Burgess (1984) / Xu (1988) approach works as follows:

1. Start with an MCS `w₀` containing `¬φ`
2. Build a chain `c : Int → BXPoint` by:
   - Forward direction: at each step n, use `bx_forward_witness` to find a successor `c(n+1)`
     with `g_content(c(n)) ⊆ c(n+1).formulas` (this is exactly `bx_le c(n) c(n+1)`)
   - Backward direction: symmetrically using `bx_backward_witness`
   - **Fair scheduling**: use a dovetailing enumeration to ensure each F-obligation
     `F(psi) ∈ c(n)` is eventually resolved by finding `m > n` with `psi ∈ c(m)`
3. Build a `TaskModel` using the chain as the world history
4. Prove the truth lemma for chain points: `psi ∈ c(n).formulas ↔ truth_at ... (n) psi`

**Key difference from the current BXCanonical approach**: The current `bx_until_eventuality_resolution`
quantifies over ALL BXPoints (`∀ u : BXPoint, bx_le w u → ...`). The chain approach restricts
quantification to chain points only, where linearity holds **by construction**.

### Finding 3: The X-vs-G Mismatch Is the Fundamental Technical Blocker

The `DovetailedChain.lean` analysis (lines 618–648) precisely identifies why naive chain
construction fails for Until formulas:

**The mismatch**:
- Chain steps use `{psi_target} ∪ g_content(c(n))` as the Lindenbaum seed
- `g_content(c(n))` = `{phi | G(phi) ∈ c(n)}`
- Until persistence requires: `(top U psi) ∈ c(n)` → `(top U psi) ∈ c(n+1)`
- But `(top U psi) ∉ g_content(c(n))` unless `G(top U psi) ∈ c(n)`
- `G(top U psi) ∈ c(n)` would require `(top U psi) → G(top U psi)`, which is **semantically false**
  (Until is existential, G is universal; an Until formula can hold now without holding at all
  future times)

This is the **X-vs-G mismatch**: Until content (X-content) and G-content are not the same,
and X-content does not propagate through g_content seeds.

**The same mismatch in both architectures**:
- `DovetailedChain.lean`: wants `(top U psi) ∈ chain(n)` to give `(top U psi) ∈ chain(n+1)`
- `BXCanonical/Frame.lean:637`: wants `phi ∈ u` for all `bx_le w u` with `bx_lt u v`

### Finding 4: Two Distinct Sub-Problems Within the Chain Approach

**Sub-problem A (Forward direction — eventuality resolution)**:

Given `phi U psi ∈ w` with `psi ∉ w`, find a chain point `v` with `psi ∈ v.formulas`.

Status: **SOLVABLE**. By BX10, `F(psi) ∈ w`. Use `bx_forward_witness` to get `v ≥ w` with
`psi ∈ v`. For the chain, fair scheduling ensures such a `v` eventually appears. The forward
eventuality resolution (finding the witness) does not require linearity or Until propagation.

**Sub-problem B (Guard condition — the hard part)**:

Given the eventuality witness `v`, show that `phi ∈ c(n)` for all chain points `c(n)`
strictly between `w` and `v`.

Status: **HARD**. This requires showing that the Until formula PROPAGATES to intermediate
points, AND that intermediate points satisfy the guard. Two approaches:

**Approach B1 (Until propagation via BX5 self-accumulation)**:
- BX5: `phi U psi → (phi ∧ (phi U psi)) U psi`
- This gives a new Until formula where the guard explicitly tracks `phi U psi`
- If we can show `(phi ∧ (phi U psi)) U psi ∈ c(n)` implies `phi ∈ c(n)` and
  `(phi ∧ (phi U psi)) U psi` propagates forward, we have the guard
- **Blocker**: same X-vs-G mismatch — BX5 gives a new Until formula, not a G-formula

**Approach B2 (Use BX4 connectedness)**:
- BX4: `phi U psi → G(P(phi U psi))` (forward: `phi U psi` holds at present, so it held
  at every past time too)
- At any chain point `c(n)` with `bx_le w c(n)`: `P(phi U psi) ∈ c(n)`
- So there exists `u ≤ c(n)` with `phi U psi ∈ u`
- **Problem**: `u` might not be on the chain; this only gives a backward witness in the tree

**Approach B3 (Proof-theoretic guard via BX9)**:
- BX9: `phi U psi → phi ∨ psi`
- At each intermediate point, if `phi U psi` is in the MCS and `psi` is not, then `phi` is
- **Blocker**: Need `phi U psi ∈ c(n)` at intermediate points, which requires propagation

### Finding 5: A Viable Path Using the BXCanonical Infrastructure

The current `bx_until_eventuality_resolution` has an incorrectly stated signature. It requires:

```lean
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → phi ∈ u.formulas
```

This quantifies over ALL BXPoints in the interval, which requires global linearity. But for the
truth lemma in Completeness.lean, we only need this to hold for points ON THE CANONICAL MODEL's
world history.

**The key insight**: The 4 Frame.lean sorries are stated for ALL BXPoints but ONLY NEED TO HOLD
for points on the specific world history used in the completeness proof. If we build the
completeness proof around a chain model instead of the full canonical model, we can:

1. **Bypass Frame.lean sorries entirely** — they remain sorry'd but become dead code
2. **Build a chain-based world history** where Until truth holds by the chain's construction
3. **Use the existing TruthLemma.lean infrastructure** for atom, bot, imp, box, G, H cases
4. **Prove Until/Since cases directly for chain points** using chain properties

This is the architectural shift: instead of fixing Frame.lean and using the existing
Completeness.lean approach, build an alternative completeness path through a chain model.

### Finding 6: CanonicalEmbedding.lean Sorry Is Orthogonal But Has a Clean Fix

The sorry at line 418 (imp Case B in `usf_completeness`) fails because:
- Case B: `¬(psi → chi)` in MCS `w`, so `psi ∈ w` and `chi ∉ w`
- Need to build a countermodel where `psi → chi` is false
- On a **constant history**, `truth_at G(alpha)` collapses to `truth_at alpha`
- So the backward truth bridge gives `flatten(chi) ∈ w` not `chi ∈ w` when chi contains G/H

**Available fix using BX1 (reflexivity)**:

For `untilSinceFree` formulas, G and H have the T-axiom: `G(alpha) → alpha` and `H(alpha) → alpha`.
This means in any MCS: `G(alpha) ∈ w → alpha ∈ w`. Therefore, `G(alpha) ∉ w` does NOT mean
`alpha ∉ w`; conversely, `alpha ∉ w` implies `G(alpha) ∉ w` by contrapositive of T-axiom
(since `G(alpha) ∈ w → alpha ∈ w`).

The actual gap is: given `chi ∉ w`, we need to show `truth_at chi` is false in SOME model.
For `chi = G(alpha)` with `G(alpha) ∉ w`: either `alpha ∉ w` (and we can use a countermodel
for `alpha`), OR `alpha ∈ w` but `G(alpha) ∉ w` (which means some future point lacks `alpha`).

For the Case B `imp` sorry specifically: `chi ∉ w`, so the backward truth bridge needs to
show the countermodel makes `chi` false. For `chi = G(alpha)`:
- `G(alpha) ∉ w` → by `bx_G_backward`, there exists `v ≥ w` with `alpha ∉ v`
- A two-point history `h(0) = w, h(1) = v` (with appropriate temporal structure) would
  make `G(alpha)` false at time 0
- This **requires constructing non-constant histories**, which needs the chain construction

**Alternative**: For the `untilSinceFree` fragment specifically, one can prove a weaker
countermodel lemma that only needs constant or two-point histories, avoiding the full chain.

### Finding 7: The ReDefinition-of-bx_le Approach

One clean architectural option: redefine `bx_le` so that the canonical model's temporal ordering
is built from the chain construction rather than from G-content inclusion.

**Proposal**: Instead of `bx_le w v := g_content(w) ⊆ v.formulas`, define the canonical model
ordering via an explicit chain construction indexed by an ordinal or `Int`. This would:
- Make linearity **definitional** (the chain index provides the linear order)
- Allow the truth lemma to be proved for the specific chain points
- Still satisfy reflexivity and transitivity (from BX1 and BX4)

**Cost**: Would require rewriting most of `Frame.lean`, `TruthLemma.lean`, and `CanonicalEmbedding.lean`.

---

## Recommended Approach

### Primary Recommendation: Build a Standalone Chain Completeness Module

Rather than modifying the existing BXCanonical files, create a new module
`Theories/Bimodal/Metalogic/BXCanonical/ChainCompleteness.lean` that proves completeness
using a chain model, bypassing the 4 Frame.lean sorries entirely.

**Architecture**:

```
ChainCompleteness.lean
├── Type: ChainPoint (wraps BXPoint + chain index)
├── chain_le: Int ordering on ChainPoints (LINEAR by definition)
├── chain_truth_lemma: truth ↔ membership for all formula cases including Until/Since
│   ├── Until: uses chain linearity for the guard condition
│   └── Since: mirror
├── chain_model: builds TaskModel from ChainPoints with canonical valuation
└── chain_bx_completeness: proves bx_completeness using chain_model
```

**Key lemma to prove**:

```lean
-- Until forward: phi U psi ∈ c(n) → truth_at_chain n (phi U psi)
-- Proof: BX10 gives F(psi), dovetailed scheduling gives m > n with psi ∈ c(m)
-- For intermediate k ∈ [n, m): psi ∉ c(k), so by BX9: phi ∈ c(k) (from phi U psi ∈ c(k))
-- Until persistence step: phi U psi ∈ c(k) → phi U psi ∈ c(k+1) when psi ∉ c(k)
--   Proof: use F_until_equiv: phi U psi ∈ c(k) → F(psi) ∈ c(k)
--           F(psi) ∈ c(k) → psi ∈ g_content... NO — same mismatch
```

**The Until persistence problem remains**: The above approach still hits the X-vs-G mismatch.

### Revised Primary Recommendation: Enriched Lindenbaum Seeds

The dovetailed chain fails because Until formulas don't propagate through g_content seeds.
The fix: **include Until formulas in the Lindenbaum seed** using their consistency proof.

**Multi-target Until seed consistency** (claimed by Teammate B in round 1):

Given MCS `w` and Until formulas `phi_1 U psi_1, ..., phi_k U psi_k ∈ w`, the set
`g_content(w) ∪ {phi_1 U psi_1, ..., phi_k U psi_k}` is consistent.

**Proof sketch**: If `g_content(w) ∪ {U_1, ..., U_k} ⊢ ⊥`, split on which U_i contributed.
Each U_i ∈ w by hypothesis. By `g_content_closed_derivation`, if the derivation uses only
G-formulas, `G(⊥) ∈ w`. If U_i contributes: by BX9, `U_i → phi_i ∨ psi_i`, so phi_i or psi_i
can be extracted. The consistency proof needs more analysis.

**If the multi-target seed is consistent**: Build forward chain steps as:
```
chain(n+1) = Lindenbaum_extension(g_content(chain(n)) ∪ {all until formulas of chain(n)} ∪ {target_psi})
```

This would ensure all Until formulas from `chain(n)` are also in `chain(n+1)`, providing
Until persistence automatically.

**However**: The `g_content_closed_derivation` argument would fail for the Until formulas.
The consistency proof would need a new argument not using G-lifting.

### Backup Recommendation: Proof-Theoretic Guard via BX9 + BX4

For the 4 Frame.lean sorries, there may be a direct proof-theoretic approach:

**For `bx_until_eventuality_resolution`**:
1. `phi U psi ∈ w` with `psi ∉ w`
2. By BX9: `phi U psi → phi ∨ psi`, so `phi ∈ w` (since `psi ∉ w`)
3. By BX10: `F(psi) ∈ w`. Use `bx_forward_witness` to get `v ≥ w` with `psi ∈ v`
4. **For the guard**: At any `u` with `bx_le w u` and `bx_lt u v`:
   - Need `phi ∈ u`
   - By BX4 connectedness on `u`: `phi U psi ∈ w` and `bx_le w u` means... we need `P(phi U psi) ∈ u`
   - BX4: `alpha → G(P(alpha))` in any MCS. So at `w`: `phi U psi → G(P(phi U psi))`
   - `G(P(phi U psi)) ∈ w` → since `bx_le w u`: `P(phi U psi) ∈ u`
   - `P(phi U psi) ∈ u` → ∃ `q ≤ u` with `phi U psi ∈ q`
   - This doesn't directly give `phi ∈ u` — need to connect `q` to the guard

**The unresolved gap**: Even with BX4 giving `P(phi U psi) ∈ u`, the backward witness `q` may
not equal `w`. Without linearity, we can't conclude `q = w` or that the chain passes through `q`.

**Conclusion**: The proof-theoretic approach without linearity is blocked by the same fundamental
gap as identified in task 85/86.

---

## Evidence/Examples

### The g_content propagation argument (Frame.lean lines 79-94)

The existing `g_content_closed_derivation` works for G-formulas only:
```lean
-- If L ⊆ g_content(S) and L ⊢ phi, then G(phi) ∈ S
-- Key: apply generalized_temporal_k to get G(L) ⊢ G(phi)
-- Each G(psi) ∈ S for psi ∈ L (by definition of g_content)
```

Until formulas are NOT in g_content. So the Lindenbaum seed `{psi} ∪ g_content(w)` does NOT
include Until formulas. The forward witness `bx_forward_witness` (Frame.lean lines 164-171)
uses exactly this seed:

```lean
have h_seed_cons := forward_temporal_witness_seed_consistent w.formulas w.is_mcs psi h_F
obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum _ h_seed_cons
exact ⟨⟨M, hM_mcs⟩,
  fun chi hchi => hM_sup (Set.mem_union_right _ hchi),
  hM_sup (Set.mem_union_left _ (Set.mem_singleton psi))⟩
```

This witness preserves G-content but NOT Until content.

### The DovetailedChain.lean analysis (lines 618-648)

The most thorough existing analysis of why Until persistence fails:
```
-- BLOCKER: chain(n+1) ⊇ g_content(chain(n)) but not the bot-Until content.
-- The formula ψ ∨ (⊤ ∧ (⊤ U ψ)) is accessible via bot-Until, not g_content.
-- For it to be in g_content, we'd need G(ψ ∨ (⊤ ∧ (⊤ U ψ))) ∈ chain(n),
-- which requires G(⊤ U ψ) ∈ chain(n). But (⊤ U ψ) → G(⊤ U ψ) is NOT
-- derivable (semantically false: Until is existential, G is universal).
```

### BX4 connectedness (Axioms.lean line 142)
```lean
/-- BX4: Temporal connectedness (future): `φ → G(P(φ))`. -/
| connect_future (φ : Formula) :
    Axiom (φ.imp (Formula.all_future (Formula.some_past φ)))
```

This gives `phi U psi → G(P(phi U psi))`, which is how `P(phi U psi) ∈ u` can be derived
for any `u ≥ w`. But it yields a backward witness in the tree, not necessarily on the chain.

### The multi-target Until seed approach (Teammate B, round 1 findings)

From `01_teammate-b-findings.md` (round 1): "The multi-target Until seed
`g_content(w) ∪ {φ₁ U ψ₁, ..., φₖ U ψₖ}` IS consistent (proved via
g_content_closed_derivation + BX1 + MCS disjunction)." This is the key enabler for
enriched-seed chain construction.

---

## Confidence Level

**MEDIUM-HIGH** for the chain extraction approach in principle.

**LOW** for any approach that tries to use the existing `bx_until_eventuality_resolution`
signature as stated (it requires linearity of all BXPoints, not just chain points).

**MEDIUM** for the enriched-seed approach (multi-target Until seed + dovetailed chain).

**MEDIUM-HIGH** for a standalone `ChainCompleteness.lean` that proves the truth lemma
only for chain points rather than all BXPoints. The main technical question is whether
Until persistence through chain steps can be proved with enriched seeds.

---

## Estimated Effort

| Sub-task | Effort | Confidence |
|----------|--------|------------|
| Verify multi-target Until seed consistency | 2-4 hours | MEDIUM |
| Build enriched-seed forward chain | 4-6 hours | MEDIUM |
| Prove Until persistence through enriched chain steps | 4-8 hours | LOW-MEDIUM |
| Build `ChainCompleteness.lean` truth lemma | 6-12 hours | MEDIUM |
| Close CanonicalEmbedding sorry (two-point history) | 3-5 hours | MEDIUM-HIGH |
| Close Completeness.lean sorry | 2-4 hours | HIGH (if above complete) |
| **Total** | **21-39 hours** | MEDIUM |

---

## Appendix: Current Architecture Assessment

### What CAN be reused

- `BXPoint`, `bx_le`, `bx_le_refl`, `bx_le_trans` — keep as-is
- `bx_forward_witness`, `bx_backward_witness` — keep as-is (form chain steps)
- `bx_G_forward`, `bx_G_backward`, `bx_H_forward`, `bx_H_backward` — keep as-is
- `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs` — keep as-is
- All of `TruthLemma.lean` except Until/Since cases
- All of `CanonicalEmbedding.lean` except the imp Case B sorry

### What needs NEW infrastructure

- A chain construction: `Int → BXPoint` with dovetailed F-resolution
- `chain_bx_le_linear`: chain index gives linear order (definitional)
- `chain_until_iff`: Until truth lemma for chain points (requires Until persistence)
- A modified `Completeness.lean` that uses the chain model

### What can be BYPASSED

- `bx_until_eventuality_resolution` (Frame.lean:632) — leave sorry'd, not used in chain path
- `bx_until_backward` (Frame.lean:664) — same
- `bx_since_eventuality_resolution` (Frame.lean:683) — same
- `bx_since_backward` (Frame.lean:704) — same

The Frame.lean sorries would remain but become dead code when the chain completeness path
is established.

---

## Open Questions for Further Research

1. **Multi-target Until seed**: Can `g_content(w) ∪ {phi_1 U psi_1, ..., phi_k U psi_k}`
   be proved consistent using BX1 + BX9 + MCS properties? This is the key enabler.

2. **Until persistence with enriched seeds**: If chain steps use the enriched seed, does
   `phi U psi ∈ chain(n)` guarantee `phi U psi ∈ chain(n+1)` (when `psi ∉ chain(n)`)?

3. **Backward Until on chains**: Even with forward Until, proving
   `truth_at_chain n (phi U psi) → phi U psi ∈ chain(n)` is the hardest direction.
   The standard proof requires: if `phi U psi` is true at n, then `psi ∈ chain(m)` for some
   m ≥ n and `phi ∈ chain(k)` for all n ≤ k < m. The backward direction needs: given this
   witness pattern, conclude `phi U psi ∈ chain(n)`. This uses BX8 (reflexive case) and
   induction on m-n using a step transfer property. The step transfer (pulling `phi U psi`
   from `chain(k+1)` to `chain(k)` given `phi ∈ chain(k)`) needs `phi U psi ∈ chain(k+1)`
   AND some "connection" between chain steps — exactly what Until persistence provides.

4. **CanonicalEmbedding Case B alternative**: For the `untilSinceFree` fragment, is there
   a proof-theoretic argument showing `flatten(chi) ∈ w ↔ chi ∈ w` for untilSinceFree chi?
   Under BX reflexive semantics, G(alpha) → alpha and H(alpha) → alpha. So G(alpha) ∈ w implies
   alpha ∈ w. The converse (alpha ∈ w → G(alpha) ∈ w) is false in general. The flatten
   direction goes: `chi ∈ w → flatten(chi) ∈ w` (since G-formulas imply their subformulas).
   The unflatten direction: `flatten(chi) ∈ w → chi ∈ w` would need G-necessitation-like
   properties that don't hold. **Conclusion**: proof-theoretic fix is unlikely; two-point
   history construction is the right approach for Case B.
