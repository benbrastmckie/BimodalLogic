# Teammate B: Literature on Conservative Extension / Translation Between Reflexive and Irreflexive Temporal Logics

## Key Findings

### 1. Irreflexivity Does Not Yield New Validities (for Basic Tense Logic) -- HIGH CONFIDENCE

For the basic tense logic Kt (with operators F, G, P, H only), the set of formulas valid on all frames equals the set valid on all irreflexive frames. This is a well-established result in the modal logic literature (Venema, Blackburn-de Rijke-Venema).

The intuition: irreflexivity is not modally definable (no modal formula characterizes exactly the irreflexive frames), and via bounded morphism (p-morphism) arguments, any irreflexive frame can be mapped to a reflexive frame preserving all valid formulas. Venema's "Derivation Rules as Anti-Axioms" (JSL 1993) shows that "K itself is complete for the class of irreflexive frames."

**Implication for the project**: For the G/H fragment (without Until/Since), proving completeness on reflexive linear orders immediately gives completeness on irreflexive linear orders, because the valid formulas are identical.

### 2. The Until/Since Language Changes the Picture Significantly -- HIGH CONFIDENCE

The situation is fundamentally different when Until and Since operators are included:

- **Non-strict (reflexive) U can be defined from strict U**: `phi U_ref psi := psi \/ (phi /\ phi U psi)` (and symmetrically for Since). This is well-documented in the SEP notes on temporal logic.

- **Strict U CANNOT generally be defined from non-strict U**: This is explicitly stated in the literature. The strict versions are more expressive than their reflexive counterparts.

- **Exception on discrete frames**: On discrete linear frames, strict Until IS definable from non-strict via the Next operator: `phi U psi := X(phi U_ref psi)`.

**Critical consequence**: Because the two Until operators have different expressive power, the "no new validities" result does NOT trivially transfer to the Until/Since language. The reflexive and irreflexive Until/Since are genuinely different operators, and a formula valid under one interpretation may not be valid under the other.

### 3. The Burgess-Xu Axiomatization is for REFLEXIVE Until/Since -- HIGH CONFIDENCE

The Burgess (1982) / Xu (1988) axiom system is explicitly for reflexive versions of S and U on the class of all reflexive linear orderings. Its axioms include:

1. `G(phi) -> phi` (the T-axiom / reflexivity axiom)
2. `G(phi -> psi) -> (phi U chi) -> (psi U chi)` (left monotonicity)
3. `G(phi -> psi) -> (chi U phi) -> (chi U psi)` (right monotonicity)
4. `phi /\ chi U psi -> chi U (psi /\ chi S phi)` (U-S interaction / connectedness)
5. `phi U psi -> (phi /\ phi U psi) U psi` (self-accumulation)
6. `phi U (phi /\ phi U psi) -> phi U psi` (absorption)
7. Linearity schema (complex disjunction)

Plus mirror images (swapping G/H, U/S) and inference rules NEC_G, NEC_H.

### 4. Venema's Extension to Strict Until/Since -- MEDIUM-HIGH CONFIDENCE

Venema (1993, "Completeness via Completeness") translated the Burgess-Xu axiomatization to strict versions of S and U. The SEP article says "the translation of this axiomatization for the strict versions" was extended with additional axioms for specific frame classes:

- **Discrete linear orderings**: Add `F(T) -> bot U T` and its dual `P(T) -> bot S T`
- **Well-orderings**: Further add `H(bot) \/ P(H(bot))` and `F(phi) -> (not phi) U phi`
- **Natural numbers**: Further add `F(T)` (seriality)

The precise nature of the "translation" (what changes in the base axioms) is not fully detailed in the available secondary sources. However, the key modification is almost certainly:
- **Remove** `G(phi) -> phi` (the T-axiom, not sound under strict G)
- **Replace** with seriality axioms: `T -> F(T)` and `T -> P(T)`
- **Modify** the U-S interaction axiom (axiom 4) to account for strict witness semantics

### 5. The IRR Rule -- HIGH CONFIDENCE

The Gabbay Irreflexivity Rule is formulated as:

> From `(p /\ H(not p)) -> phi`, infer `phi`, provided `p` does not occur in `phi`.

The intuition: if phi can be proved under the assumption that we are at an irreflexive point (there exists a proposition p true only here -- ensured by `p /\ H(not p)` forcing p to be a "name" for the current time), then phi is a theorem.

Burgess (1980) used this rule for the Peircean branching-time logic. Zanardo (1990) showed it can be replaced by infinitely many axioms.

**For the project**: The IRR rule is NOT needed if working with the Until/Since language on linear orders, because the Burgess-Xu system (and Venema's strict extension) achieves completeness without it. The IRR rule is primarily needed for branching-time logics where irreflexivity interacts with the branching structure.

### 6. Density's Role in the Reflexive/Irreflexive Relationship -- MEDIUM CONFIDENCE

On **dense** linear orders, the distinction between strict and non-strict universal quantification partially collapses for the basic operators:
- If G(phi) holds at t (for all s >= t, phi(s)), and the order is dense, then for any s > t, there exists r with t < r <= s, so phi holds at all points strictly after t.
- However, this only shows `G_refl(phi) -> phi /\ G_strict(phi)`, not the reverse.

For Until/Since, density does NOT eliminate the distinction because the witness condition (existential) differs: strict Until requires a strictly future witness, while reflexive Until allows the current time as witness.

**Important**: The project's temporal domain is an arbitrary `AddCommGroup D` with `LinearOrder D`. This is general enough to cover both dense and discrete orders. No density assumption should be baked in.

### 7. No Direct Conservative Extension Result Exists -- HIGH CONFIDENCE

There is NO standard result in the literature that says "the reflexive Until/Since system is a conservative extension of the irreflexive Until/Since system" or vice versa. This is because:

1. The two systems have different primitive operators (reflexive U vs strict U)
2. The reflexive operator is definable from the strict one but not vice versa
3. The axiom systems differ (T-axiom present/absent, different interaction axioms)
4. The valid formulas differ between the two semantics

The relationship is not one of conservative extension but rather one of **separate axiomatizations for different semantics**.

### 8. Reynolds' Approach: Avoiding the IRR Rule -- MEDIUM CONFIDENCE

Reynolds (1992, "An axiomatization for until and since over the reals without the IRR rule") showed that for the reals specifically, one can axiomatize strict Until/Since without using the IRR rule. This is significant because:
- It shows the IRR rule is avoidable for linear orders
- The approach uses density of the reals
- The system is "orthodox" (only standard inference rules)

## Literature Summary Table

| Author(s) | Year | Result | Semantics | Frame Class |
|-----------|------|--------|-----------|-------------|
| Burgess | 1982 | Complete axiom system for U/S | Reflexive | All linear orders |
| Xu | 1988 | Simplified Burgess system | Reflexive | All linear orders |
| Gabbay-Hodkinson | 1990 | Axiomatization of U/S over reals | Strict | Real numbers |
| Reynolds | 1992 | U/S over reals without IRR rule | Strict | Real numbers |
| Venema | 1993a | "Completeness via Completeness" -- extends B-X to strict U/S | Strict | Discrete, well-orders, naturals |
| Venema | 1993b | "Derivation Rules as Anti-Axioms" -- IRR rule metatheorem | Both | General frames |
| Reynolds | 1994, 1996 | Extensions for strict linear orderings | Strict | Various |
| Blackburn-de Rijke-Venema | 2001 | Textbook: irreflexivity not modally definable, no new validities for basic ML | Both | General frames |

## Recommended Translation Strategy

Based on the literature review, I recommend the following approach for the ProofChecker project:

### Option A: Independent Completeness Proofs (RECOMMENDED)

The reflexive and irreflexive systems are genuinely different axiom systems with different semantics. The cleanest approach is:

1. **Prove completeness for the irreflexive system directly** on the `irr_until` branch, since this is the paper's intended semantics.
2. Do NOT attempt to derive irreflexive completeness from reflexive completeness -- no clean transfer theorem exists in the literature for the Until/Since language.
3. The proof structure (canonical model construction, MCS properties, etc.) is largely parallel between the two systems, so code can be shared at the infrastructure level.

### Option B: Reflexive-First with Manual Transfer (POSSIBLE BUT COMPLEX)

If completeness is easier to prove for reflexive semantics:

1. Prove reflexive completeness on the `until` branch.
2. For each irreflexive axiom, establish that it is valid on all irreflexive linear orders. This requires:
   - Showing the modified axioms (seriality replacing T-axiom, etc.) are sound
   - The irreflexive completeness proof follows the same pattern but with different base cases
3. The transfer is NOT automatic -- it requires reproving the Lindenbaum-Henkin construction with the new axiom set.

### Option C: Shared Core with Parametric Semantics (CLEANEST FOR FORMALIZATION)

Design the Lean formalization with a parameter that switches between reflexive and irreflexive semantics:
- Parametrize truth evaluation by `<=` vs `<`
- Share all proof infrastructure that doesn't depend on this choice
- Prove completeness twice, reusing shared lemmas
- This is essentially what the codebase already supports via the `Truth.lean` definitions

### Why Option A is Recommended

The current `irr_until` branch already has the correct irreflexive semantics implemented. The axiom system (in `Axioms.lean`) already removes BX1 (T-axiom) and BX8 (until_step) and adds seriality axioms. This matches Venema's approach of modifying the Burgess-Xu system for strict operators.

Attempting to go through reflexive completeness first would:
- Require building a second axiom system and truth definition
- Require a transfer theorem that doesn't exist off-the-shelf
- Double the proof burden rather than halving it

## Confidence Level

**Overall confidence: HIGH** for the main findings (no conservative extension exists, the two systems are genuinely different, irreflexivity doesn't yield new validities for basic tense logic but the Until/Since language changes things).

**MEDIUM** for the specific details of Venema's translation (the secondary sources don't fully detail the modifications to the base axioms).

## Critical Observation for the Project

The project's current approach on `irr_until` is actually well-aligned with the literature:
- The axiom system already matches the expected structure for strict Until/Since (seriality replacing reflexivity, appropriate guard conventions)
- The truth evaluation in `Truth.lean` correctly uses strict `<` for temporal operators
- The completeness proof should proceed directly for this system, not via a detour through reflexive semantics

The key challenge is not the reflexive/irreflexive distinction but rather the **chain construction** for the canonical model (building actual linear orders from maximal consistent sets), which is the same challenge regardless of which semantics is chosen.
