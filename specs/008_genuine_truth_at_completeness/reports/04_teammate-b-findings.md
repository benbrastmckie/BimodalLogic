# Research Findings: Dense/Discrete as Primary Targets

**Teammate**: B
**Focus**: Dense/discrete extensions vs base TM completeness
**Date**: 2026-03-20

## Key Findings

### 1. Dense/Discrete Naturalness

**Dense completeness is more mathematically natural than base TM — but for a structural
reason, not a proof-theoretic one.**

For *base TM*, the axiom system provides no characterization of the canonical timeline.
Any linearly ordered abelian group D works; the code deliberately uses `D = Int` as a
concrete default because "any LOAG works; Int is simple and well-tested"
(`BaseCompleteness.lean`, lines 83–86). There is no canonical D to aim for.

For *dense TM*, the density axiom DN enables the DFromCantor construction:
`TimelineQuot ≃o Rat` is provable (sorry-free via `CantorApplication.lean`). This gives
a *canonical* domain: the syntactically constructed timeline quotient IS order-isomorphic
to Rat. Dense completeness therefore has a concrete, motivated D rather than an arbitrary one.

For *discrete TM*, the axioms DF + seriality imply the canonical timeline is
`DiscreteTimelineQuot ≃o Int` (via Mathlib's `orderIsoIntOfLinearSuccPredArch`), but the
SuccOrder/PredOrder instances for DiscreteTimelineQuot are blocked by task 974 sorries in
`DiscreteTimeline.lean`.

**Summary**:
| Extension | Canonical D | Domain Characterization Status |
|-----------|-------------|-------------------------------|
| Base TM   | None (any LOAG) | N/A — no axiom forces a specific D |
| Dense TM  | `TimelineQuot ≃o Rat` | Proven sorry-free (CantorApplication.lean) |
| Discrete TM | `DiscreteTimelineQuot ≃o Int` | Blocked by task 974 |

Dense is the most natural primary target because it has a proven canonical domain.
Discrete is the second-most natural but is additionally blocked. Base TM is the least
natural because it has no canonical domain.

### 2. TaskFrame-Compliant Construction

**The parametric infrastructure (`ParametricRepresentation.lean`) is the correct
architectural foundation for all three completeness theorems.**

`TaskFrame D` requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.
The parametric infrastructure (`ParametricCanonical.lean`,
`ParametricHistory.lean`, `ParametricTruthLemma.lean`) is entirely sorry-free for any
D satisfying these constraints.

The key design insight is `parametric_to_history`: it maps an `FMCS D` to a
`WorldHistory` using `domain = True` (the full domain), making convexity trivially
satisfied. This completely sidesteps the convexity problem that killed the earlier
FlagBFMCSRatBundle approach (which attempted to prove convexity for a shifted sub-domain
of Rat).

The construction chain is:
1. Assume `phi` is not provable
2. `not_provable_implies_neg_extends_to_mcs`: get MCS M with `phi.neg ∈ M`
3. `construct_bfmcs`: construct a temporally coherent `BFMCS D` containing M at time 0
4. `parametric_algebraic_representation_conditional`: give the BFMCS, get a countermodel
5. Contradiction with `valid phi` / `valid_dense phi` / `valid_discrete phi`

For **dense completeness** (`D = Rat`), step 3 needs a `BFMCS Rat` with:
- Temporal coherence: forward_F and backward_P for `FMCS Rat`
- Modal coherence: modal_forward (proven) and modal_backward (blocked)

For **discrete completeness** (`D = Int` with SuccOrder), step 3 needs a `BFMCS Int`
with the same plus the discreteness structure present in the MCSs.

The `DenseInstantiation.lean` and `DiscreteInstantiation.lean` files already provide
the typeclass verification (Rat and Int satisfy all required constraints) and the
conditional representation theorems — everything EXCEPT the `construct_bfmcs` function.

### 3. Existing Constructions Analysis

#### 3.1 TimelineQuotCompleteness.lean (Dense)

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`

Contains the correctly-structured dense completeness theorem (`dense_completeness_theorem`)
with the proof skeleton complete. The single remaining sorry is in:

```lean
theorem timelineQuot_not_valid_of_neg_consistent
    (φ : Formula) (h_cons : ContextConsistent [φ.neg]) :
    ¬@valid_over D acg inferInstance oam φ := by
  sorry  -- line 127
```

This sorry is the central gap. To fill it, one needs to construct:
1. A `TaskFrame` over `TimelineQuot M₀ h_M₀_mcs`
2. A `TaskModel` with valuation = MCS membership
3. An `Omega` set containing a witness history
4. A history τ and time t where φ evaluates to false

The `TimelineQuotCanonical.lean` provides `ParametricCanonicalTaskFrame` instantiated
at `D = TimelineQuot` (which satisfies AddCommGroup+LinearOrder+IsOrderedAddMonoid via
`TimelineQuotAlgebra.lean`). The gap is connecting this to the truth lemma.

#### 3.2 ClosureSaturation.lean

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`

Attempts to build a modally saturated BFMCS over TimelineQuot directly. Has four sorries:
- Lines 659, 664: `timelineQuotFMCS_forward_F` — the staged construction's witness may not
  be the same as `canonical_forward_F`'s witness, which is an arbitrary MCS not guaranteed
  to be in the staged timeline. Comment at line 649: "canonical_forward_F gives an arbitrary
  witness, but the staged timeline contains only MCSs reachable from the root."
- Line 679: `timelineQuotFMCS_backward_P` — symmetric gap
- Line 724: `modal_backward` for singleton BFMCS — the fundamental degenerate case

This approach is fighting on two fronts simultaneously (temporal coherence + modal coherence)
for D = TimelineQuot, which is the hardest possible case.

#### 3.3 IntFMCSTransfer / IntBFMCS (Base and Discrete)

The Int chain approach (`IntBFMCS.lean`) has sorries at `intFMCS_forward_F` and
`intFMCS_backward_P`. The comment at line 1157–1174 of IntBFMCS.lean explains:
"Linear chain constructions cannot satisfy forward_F because F-formulas don't persist
through generic Lindenbaum extensions."

`IntFMCSTransfer.lean` also has `modal_backward` sorry (line 134) for single-family BFMCS.

#### 3.4 FlagBFMCSRatBundle

**Does not exist** — the DenseCompleteness.lean module mentions it in comments
(lines 55–57) as a former approach with sorries at convexity (line 364) and shifted
truth lemma (line 438), but the file is not in the current Bundle/ or StagedConstruction/
directories. It has been superseded by the parametric approach.

#### 3.5 CanonicalFMCS / ParametricRepresentation (Working Foundation)

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`

The only **sorry-free** temporal coherence construction is `FMCS CanonicalMCS`
(canonicalMCSBFMCS). This works because the domain contains ALL MCS, so F/P witnesses
trivially exist as domain elements. It uses only Preorder on CanonicalMCS, not AddCommGroup.

**File**: `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean`

The sorry-free conditional representation theorem. Given a `construct_bfmcs` function for
a specific D, proves completeness for that D. This is the architecturally correct bridge.

### 4. Trivial vs Non-Trivial Constructions

**The CanonicalFMCS construction is explicitly described as a "proof-theoretic technique"
and is entirely legitimate — this is not a bug but a feature.**

From `CanonicalFMCS.lean` (lines 19–30), the architectural note distinguishes:

| Aspect | Standard FMCS | FMCS CanonicalMCS |
|--------|---------------|-------------------|
| Indexing Type | Int, Rat, TimelineQuot | CanonicalMCS |
| Structure | AddCommGroup + LinearOrder | Preorder only |
| mcs Function | Maps time points to worlds | Identity: mcs(w) = w.world |
| F/P Witnesses | Must be constructed | Trivial (every MCS is in domain) |
| Purpose | Semantic model | TruthLemma proof |

The document explicitly states: "This construction is **legitimate and necessary** for the
completeness proof pipeline."

The characterization as "trivial" in the task description is accurate in a technical sense
(the mcs function is the identity, making F/P witness obligations vanish), but this is NOT
a problem. Standard Henkin/Lindenbaum completeness proofs are precisely this pattern:
build a canonical model where worlds = MCS, and truth = membership. The identity mapping
IS the canonical model.

A "non-trivial" construction — building an FMCS Int where mcs(n) is a specifically
constructed chain of MCSs — is harder and introduces the F/P witness problem.
The CanonicalMCS approach deliberately avoids this by making the domain large enough
to contain all witnesses a priori.

**The real question is not trivial vs non-trivial, but how to connect the CanonicalMCS
construction (which has F/P for free) to a TaskFrame D that has AddCommGroup.**

The answer is the ParametricRepresentation approach: build the TaskFrame over D = Int (or
Rat) using `ParametricCanonicalTaskFrame D`, which uses WorldState = MCS (not Int), and
history = FMCS D (indexed by D but mapping to MCS worlds). The CanonicalMCS preorder
is used for the BFMCS F/P witnesses, and D's group structure is used for the frame axioms.

This is the architecture already present in `AlgebraicBaseCompleteness.lean`, which calls
`construct_bfmcs_from_mcs_Int` — the only missing piece.

### 5. Two-Logic Strategy

**Dense + Discrete completeness would be MORE than base TM completeness — each captures
formulas valid in specific frame classes.**

From `DiscreteCompleteness.lean` (lines 222–240), dense and discrete are incompatible:
- Dense requires DenselyOrdered (no immediate successors)
- Discrete requires SuccOrder (immediate successors exist)
- No domain satisfies both

The relationship between validity predicates:
- `valid φ` (all linear orders) implies `valid_dense φ` (dense orders only)
- `valid φ` implies `valid_discrete φ` (discrete orders only)
- But `valid_dense φ` does NOT imply `valid_discrete φ` and vice versa

**Formulas valid in base TM but not in extensions**: The density axiom DN is valid in
dense models but not discrete. The discreteness axiom DF is valid in discrete models but
not dense. These provide concrete examples of non-overlap.

**Formulas that need both extensions**: There would be formulas valid on all linear orders
(hence base-TM-valid) but not derivable without both DN and DF — though in practice base
TM completeness implies such formulas are base-derivable.

**What proving dense + discrete completeness gives us**:
- Dense: `valid_dense φ → ⊢_dense φ` — completeness for a specific class of infinite
  structures (countable dense orders ≅ Rat)
- Discrete: `valid_discrete φ → ⊢_discrete φ` — completeness for a specific class of
  structures (countable discrete orders ≅ Int)
- But we would NOT automatically get base TM completeness from either

**However**, the infrastructure needed for dense completeness (BFMCS Rat with temporal
coherence) is essentially the same infrastructure needed for base completeness (BFMCS Int
with temporal coherence). The forward_F/backward_P and modal_backward problems appear in
BOTH. So dense completeness is not easier than base completeness — it requires the same
core constructions plus the Cantor isomorphism (which is already proven).

## Recommended Approach

**Target: dense completeness first, using the parametric infrastructure.**

Rationale:
1. Dense has the most complete existing infrastructure (`TimelineQuotCompleteness.lean`
   already has the correct proof structure with a single sorry)
2. The Cantor isomorphism `TimelineQuot ≃o Rat` is already proven sorry-free
3. The `ParametricCanonicalTaskFrame Rat` is already verified
4. The proof reduces to filling one sorry:
   `timelineQuot_not_valid_of_neg_consistent`

**The single sorry to fill** requires:
- Building a `BFMCS Rat` (or `BFMCS (TimelineQuot M₀ h)`) that is temporally coherent
- The temporal coherence requires forward_F and backward_P for FMCS Rat
- Modal coherence requires modal_backward (currently blocked for singleton)

**Most promising path for BFMCS Rat construction**:
Use the CanonicalMCS → Rat **transfer** approach via `IntFMCSTransfer`/`FMCSTransfer`:

1. Start with `canonicalMCSBFMCS` (sorry-free temporal coherence over CanonicalMCS)
2. The `ParametricCanonicalTaskFrame Rat` uses WorldState = MCS (not Rat), with histories
   indexed by Rat but tracking MCS worlds
3. The key insight from `ParametricHistory.lean`: `domain = True` means histories are
   full functions D → WorldState, removing all domain restriction problems
4. Construct the BFMCS Rat by picking an enumeration of "witness positions" in Rat and
   assigning MCSs from the CanonicalMCS construction

For modal coherence, the `SaturatedBFMCSConstruction.lean` file (in Bundle/) provides
machinery for building multi-family modally saturated bundles from ClosedFlagSets.
The `ClosedFlagBundle.lean` already proves that the set of all Flags is closed under
modal witnesses. This is the foundation for a sorry-free `modal_backward`.

**Concrete plan**:
- Phase 1: Prove `BFMCS CanonicalMCS` with modal_backward using SaturatedBFMCSConstruction
- Phase 2: Transfer to `BFMCS Int` using the parametric construction with `D = Int`
- Phase 3: Transfer to `BFMCS Rat` (same construction, different D)
- Phase 4: Wire into `timelineQuot_not_valid_of_neg_consistent`

Do NOT target discrete completeness next — it is blocked by Task 974 (DiscreteTimeline
SuccOrder/PredOrder instances) which is an independent obstruction.

## Evidence/Examples

**Dense proof structure exists and is complete except for one sorry**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`
  lines 151–186: `dense_completeness_theorem` — correct proof skeleton, one sorry

**Parametric infrastructure (sorry-free)**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean`
  lines 255–272: `parametric_algebraic_representation_conditional` — sorry-free

**Rat typeclass verification (sorry-free)**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`
  lines 61–65: all required instances confirmed for Rat

**CanonicalMCS F/P witnesses (sorry-free)**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`
  lines 240–269: `canonicalMCS_forward_F` and `canonicalMCS_backward_P` — no sorries

**The sorry inventory for dense completeness** reduces to:
1. `modal_backward` for BFMCS (1 sorry in IntFMCSTransfer.lean or ClosureSaturation.lean)
2. `timelineQuot_not_valid_of_neg_consistent` (1 sorry, depends on #1)

The `forward_F`/`backward_P` sorries for Int/Rat BFMCS (from ClosureSaturation.lean lines
659, 664, 679) are the same problem: staged construction witnesses may not match
canonical_forward_F witnesses. These are resolved by switching to the CanonicalMCS → D
transfer approach where F/P are trivially sorry-free.

**Dense vs Discrete incompatibility** (confirms separate proofs are needed):
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/DiscreteCompleteness.lean`
  lines 222–240: explicit documentation of incompatibility

## Confidence Level

**High** for the structural analysis:
- The code is extensively documented and cross-referenced
- The parametric infrastructure is clearly sorry-free
- The sorry inventory is precise and confirmed by code inspection

**Medium** for the recommended approach:
- The CanonicalMCS → Rat transfer is not yet implemented; it requires new code
- The `SaturatedBFMCSConstruction.lean` file exists but its current state of completeness
  for modal_backward has not been fully verified in this investigation
- The claim that `domain = True` resolves all WorldHistory convexity issues rests on
  `ParametricHistory.lean` using `domain = True` — confirmed by Report 01

**Low** for discrete completeness timeline:
- Task 974 (SuccOrder/PredOrder for DiscreteTimelineQuot) is an independent blocker
- The `succ_le_of_lt` lemma in DiscreteTimeline.lean is documented as requiring a complex
  proof involving canonical model theory
- No clear timeline for resolution exists
