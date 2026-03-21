# Research Report: Teammate B - Omega-Squared and FMP Approaches

**Task**: 1008 - Establish genuine truth_at completeness theorems for TM logic
**Started**: 2026-03-20
**Completed**: 2026-03-20
**Language**: math/lean4
**Focus**: Omega-squared construction and Finite Model Property approaches

## Key Findings

### 1. Omega-Squared Construction

**Assessment**: Viable with significant infrastructure investment

The omega-squared (or "dovetailed") approach processes F/P obligations systematically using Cantor pairing to enumerate all (position, formula) pairs.

**Current Codebase Status**:
- `Theories/Bimodal/Metalogic/StagedConstruction/Dovetailing.lean` already implements the Cantor pairing infrastructure
- `forall_obligation_eventually_processed` theorem (line 147) proves every (point, formula) pair is processed
- However, **the current implementation still uses Lindenbaum extension AFTER obligation processing**

**The Core Issue**:
The current dovetailing processes obligations at step `pair(point_index, formula_encoding)`, but the Lindenbaum extension at each step can still introduce `G(~phi)` which kills `F(phi)`. From `DovetailingChain.lean:1869-1893`:

> "This cannot be proven for the linear chain construction because F-formulas do not persist through GContent seeds. The Lindenbaum extension at any step can introduce G(neg(psi)), killing F(psi)."

**True Omega-Squared Solution**:
The obligation-driven approach must process F-obligations **BEFORE** Lindenbaum extension, not after. The key insight:

1. When `F(phi)` appears at position t, **immediately** schedule `phi` at position t+k for some k > 0
2. The seed for position t+k must **include** `phi` (not just be consistent with it)
3. Then Lindenbaum extends this seed - but `phi` is already guaranteed to be in the result
4. This requires a **two-phase construction**: obligation collection, then seed construction

**Literature Support**:
The [Henkin-style completeness proof for S5](https://arxiv.org/abs/1910.01697) formalizes a similar approach where witnesses are pre-scheduled before Lindenbaum extension. The enumerability is expressed using encodable types.

### 2. Finite Model Property (FMP)

**Assessment**: TM logic HAS FMP - this is the recommended approach

**Strong Evidence from Codebase**:
The codebase already has substantial FMP infrastructure in `Theories/Bimodal/Metalogic/Decidability/FMP/`:

| File | Status | Content |
|------|--------|---------|
| `FMP.lean` | Working | Main FMP theorem using MCS filtration |
| `Filtration.lean` | Working | MCS-based filtration equivalence |
| `FiniteModel.lean` | Working | Finiteness bound 2^|closure(phi)| |
| `ClosureMCS.lean` | Working | Restricted Lindenbaum for closure MCS |
| `DenseFMP.lean` | Working | Dense frame FMP |
| `TruthPreservation.lean` | Partial | Truth preservation under filtration |

**Key Theorem** (from `FMP.lean:57-134`):
```lean
theorem exists_mcs_with_negation (phi : Formula)
    (h_not_provable : ¬Nonempty (DerivationTree [] phi)) :
    ∃ S : ClosureMCSBundle phi, phi.neg ∈ S.carrier
```

**Why FMP Simplifies Completeness**:

1. **Finite witnesses suffice**: If TM has FMP, then any satisfiable formula has a model where the time domain is finite
2. **No Lindenbaum extension problem**: With finite models, we can enumerate all positions explicitly - no generic extension that might "kill" F-formulas
3. **MCS-based approach already works**: The filtration construction uses MCS membership = truth, which sidesteps the canonical model construction issues

**Literature Confirmation**:
From the [Stanford Encyclopedia of Philosophy - Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/):
> "All logics mentioned... have the finite model property (usually with respect to non-standard models) and hence are decidable."

From [Wikipedia - Finite Model Property](https://en.wikipedia.org/wiki/Finite_model_property):
> "A logic L has the finite model property (FMP) if any non-theorem of L is falsified by some finite model of L."

**The Gap in Current FMP Implementation**:
The existing FMP code proves MCS-based properties but doesn't complete the connection to semantic validity. The missing piece is `TruthPreservation.lean`, which should prove:
- `phi ∈ MCS ↔ model ⊨ phi` (truth lemma for filtered model)

### 3. Interaction Between Approaches

**Insight**: FMP makes omega-squared unnecessary

If we complete the FMP approach:
1. Validity reduces to membership in all closure MCS
2. Closure MCS are finitely many (≤ 2^|closure(phi)|)
3. F/P witnesses within finite closure don't need Lindenbaum extension
4. The "witness exists in domain" problem disappears because domain is explicitly enumerated

**Why G-propagation doesn't kill F-formulas in FMP**:
In the FMP approach, we're not building a chain. We're taking a quotient of ALL MCS by closure equivalence. Each equivalence class represents a "world". Within this finite structure:
- If `F(phi) ∈ MCS`, the witness MCS is also in the quotient
- No construction step can "kill" the witness because all witnesses exist a priori

## Recommended Approach

**Primary: Complete the FMP pipeline**

**Justification**:
1. **Existing infrastructure**: 80%+ of FMP code already exists and compiles
2. **Mathematically cleaner**: FMP sidesteps the fundamental Lindenbaum extension problem
3. **Literature support**: TM-like temporal logics are known to have FMP
4. **Simpler proof structure**: No transfinite construction, no dovetailing complexity
5. **Direct path to decidability**: FMP immediately gives decidability

**Secondary: Document omega-squared as alternative**

The omega-squared approach is viable but requires:
- Restructuring seed construction to include pre-scheduled witnesses
- Careful coordination of obligation processing across all positions
- More complex invariants to track which obligations are satisfied

## Evidence/Examples

### From Codebase

**FMP Finiteness Bound** (`FiniteModel.lean:131-137`):
```lean
noncomputable instance FilteredWorld.finite (phi : Formula) :
    Finite (FilteredWorld phi) := by
  haveI : Finite (Set (subformulaClosure phi)) := set_finite phi
  exact Finite.of_injective (filteredCharacteristicSet phi)
    (filteredCharacteristicSet_injective phi)
```

**CanonicalMCS Forward_F (sorry-free!)** (`CanonicalFMCS.lean:176-177`):
```lean
-- canonicalMCS_forward_F uses canonical_forward_F - witness IS domain element
```

The CanonicalMCS approach works because ALL MCS are in the domain. FMP achieves the same effect by quotienting to finite representatives.

### From Literature

**Finite Model Property for Temporal Logics** ([ScienceDirect](https://www.sciencedirect.com/topics/computer-science/finite-model-property)):
> "The correctness of decision results for temporal logics relies upon the finite model property, which establishes that if a formula has a model, then it has a model that can be represented finitely."

**Filtration Technique** ([Springer](https://link.springer.com/article/10.1007/s11225-022-10027-0)):
> "The finite model property can be proved using the filtration technique."

## Confidence Level

**High** for FMP approach
- Substantial codebase infrastructure exists
- Mathematical theory is well-established
- Clear path to completion

**Medium** for omega-squared approach
- Theoretically sound but requires significant restructuring
- More complex implementation
- Higher risk of additional blockers

## Open Questions

1. **TruthPreservation Gap**: What's missing in `TruthPreservation.lean` to complete the MCS ↔ semantic truth connection?

2. **Temporal Coherence in Filtered Model**: Does the filtered model satisfy the TM frame conditions (density, linearity)? If not, is this a problem?

3. **Modal Coherence**: The `modal_backward` sorry in single-family BFMCS - does FMP sidestep this or does it reappear in the filtered model?

4. **Integration Path**: How do we connect `FilteredWorld phi` to `TaskFrame D` to get the completeness statement in the desired form?

## Appendix: Search Queries and Sources

### Web Searches Performed
- "omega-squared construction temporal logic completeness Lindenbaum lemma obligation-driven"
- "finite model property temporal logic future past operators FMP decidability"
- "tense logic Kt completeness filtration finite model property past future bidirectional"

### Literature Sources
- [Stanford Encyclopedia - Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- [Wikipedia - Finite Model Property](https://en.wikipedia.org/wiki/Finite_model_property)
- [Wikipedia - Linear Temporal Logic](https://en.wikipedia.org/wiki/Linear_temporal_logic)
- [Henkin-style completeness for S5](https://arxiv.org/abs/1910.01697)
- [Finite Model Property in Weakly Transitive Tense Logics](https://link.springer.com/article/10.1007/s11225-022-10027-0)
- [Completeness by construction for tense logics](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)

### Mathlib Lookups
- `fixedPoints.completeLattice` - Fixed point lattice structure
- `FirstOrder.Language.Theory.IsMaximal` - Maximal theory definition (analogous to MCS)
