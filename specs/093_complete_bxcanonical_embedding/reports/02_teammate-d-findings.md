# Teammate D: Horizons -- Strategic Direction and Extensibility

## Key Findings

1. **The parametric infrastructure is already D-generic.** `ParametricCanonicalTaskFrame D`, `ParametricCanonicalTaskModel D`, `parametric_to_history`, `ShiftClosedParametricCanonicalOmega`, and `parametric_canonical_truth_lemma` are all parametric in `D : Type*` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. Extending to Rat requires zero changes to this layer.

2. **The bottleneck is BFMCS construction, not the frame/truth machinery.** The `parametric_algebraic_representation_conditional` theorem at `ParametricRepresentation.lean:254` requires a `construct_bfmcs` callback. This callback must produce a temporally coherent, Until/Since coherent BFMCS over D from any MCS. This is D-specific: the chain construction that populates F/P witnesses depends on the order-theoretic properties of D.

3. **Discrete and dense completeness are architecturally independent tracks.** The roadmap (ROAD_MAP.md:633-648, 700-743) treats them as separate tasks (93 for base/Int, 68 for dense/Rat). The codebase already has `valid`, `valid_dense`, and `valid_discrete` as separate definitions in `Validity.lean:73, 160, 178`.

4. **The Int guard-interval trick is the decisive simplification for base completeness.** For D = Int, the Until forward coherence guard interval [t, s) with s = t+1 is vacuous (no integers strictly between t and t+1). This eliminates the hardest part of the BFMCS construction.

5. **Dense completeness (D = Rat) faces a fundamentally harder guard-interval problem** that requires genuinely different chain construction techniques.

## Discrete vs Dense Landscape

### What Exists for Discrete (D = Int)

The active completeness path in `BXCanonical/` is implicitly oriented toward D = Int:
- `bx_completeness` at `Completeness.lean:124` proves `valid phi -> Nonempty (DerivationTree [] phi)` where `valid` quantifies over ALL D.
- The `DiscreteSoundness.lean` provides `axiom_discrete_valid` for the extra discrete axiom DF.
- The legacy `DiscreteCompleteness.lean` (now in Boneyard) documents the discrete completeness infrastructure and its blocked components (SuccOrder/PredOrder for DiscreteTimelineQuot).
- **Important**: The BX base logic (without DF) is complete over ALL linear orders, not just discrete ones. So `bx_completeness` proving `valid phi -> provable phi` already covers the discrete case implicitly. Task 93 is about the base logic.

### What Exists for Dense (D = Rat)

- `DenseSoundness.lean` proves `axiom_dense_valid` for the density axiom DN = `F(phi) -> F(F(phi))`.
- The legacy `DenseCompleteness.lean` (Boneyard) documents the infrastructure and the "domain mismatch" problem: the truth lemma is proved for D = Int but `valid_dense` quantifies over all `D` with `DenselyOrdered D`.
- Task 68 is `[RESEARCHED]` -- research exists but no plan or implementation.
- The `ParametricRepresentation.lean:64-68` documents the intended approach: instantiate with D = Rat for dense, add `[DenselyOrdered D]`.

### Key Difference: Guard Interval Population

The critical difference between discrete and dense completeness is the **Until guard interval**:

**Until forward coherence** (`BFMCS.forward_until_since_coherent`, `TemporalCoherence.lean:518`):
```
phi U psi in fam.mcs t ->
  exists s, t <= s /\ psi in fam.mcs s /\ forall r, t <= r -> r < s -> phi in fam.mcs r
```

**For D = Int**: If we place the Until witness at `s = t + 1`, the guard `{r : Int | t <= r /\ r < t+1}` equals `{t}`. So the guard condition reduces to `phi in fam.mcs t`, which follows from `(phi U psi) in fam.mcs t` via BX9 (`until_elim: (phi U psi) -> (phi \/ psi)`). This is almost trivial.

**For D = Rat**: The guard `{r : Rat | t <= r /\ r < s}` for any `s > t` is an infinite set. Every rational in `[t, s)` must have `phi in fam.mcs r`. The chain must be constructed so that `phi` persists throughout the open interval, which requires either:
1. A constant-on-intervals construction (all MCS in `[t, s)` are the same), or
2. A density-aware chain that ensures `phi` propagation at every intermediate point, or
3. An order-theoretic argument that `phi` membership is "closed" in some topology.

This is the fundamental reason dense completeness is a separate, harder problem.

## Architecture for Generality

### Should TaskModel be parameterized by `LinearOrder D` from the start?

**It already is.** The `TaskFrame D` structure (`TaskFrame.lean:93`) requires:
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

This three-typeclass constraint is the minimal interface that both Int and Rat (and Real) satisfy. The parametric infrastructure (`ParametricCanonical.lean`, `ParametricTruthLemma.lean`, `ParametricHistory.lean`) works uniformly over this constraint. No additional `TemporalDomain` class is needed.

### What separates discrete from dense?

| Constraint | Int | Rat | Where Used |
|-----------|-----|-----|------------|
| `AddCommGroup D` | Yes | Yes | TaskFrame, duration arithmetic |
| `LinearOrder D` | Yes | Yes | TaskFrame, temporal ordering |
| `IsOrderedAddMonoid D` | Yes | Yes | TaskFrame, order + group compatibility |
| `DenselyOrdered D` | No | Yes | `valid_dense` definition, DN soundness |
| `SuccOrder D` | Yes | No | `valid_discrete` definition, DF soundness |
| `Nontrivial D` | Yes | Yes | Dense/discrete validity (avoids degenerate case) |

The additional constraints only appear in the validity definitions and soundness proofs, never in the core frame/model/truth infrastructure. This separation is correct and elegant.

### Could a `TemporalDomain` class help?

A unified class like:
```lean
class TemporalDomain (D : Type*) extends AddCommGroup D, LinearOrder D, IsOrderedAddMonoid D where
  witness_placement : ... -- method for Until guard population
```

would add no value. The existing typeclass decomposition is standard Lean/Mathlib practice and already achieves full generality. The discrete vs dense distinction is precisely captured by `DenselyOrdered` vs `SuccOrder` at the point of use.

The only place where a custom interface might help is in the **BFMCS construction** -- specifically, the chain construction for Until witness placement. But this is better handled by having separate construction lemmas for Int and Rat, since the techniques genuinely differ.

## Code Reuse Assessment

### Shared Infrastructure (D-parametric, fully reusable)

| Module | Lines | Reusable for Rat? |
|--------|-------|-------------------|
| `ParametricCanonical.lean` | 244 | Yes (unchanged) |
| `ParametricHistory.lean` | 173 | Yes (unchanged) |
| `ParametricTruthLemma.lean` | ~300 | Yes (unchanged) |
| `ParametricRepresentation.lean` | 300 | Yes (unchanged) |
| `BFMCS.lean` | ~160 | Yes (D-parametric) |
| `FMCSDef.lean` | ~120 | Yes (D-parametric) |
| `TemporalCoherence.lean` | ~530 | Yes (D-parametric) |
| `ModalSaturation.lean` | -- | Yes (D-parametric) |

**Total shared**: ~1,800+ lines of sorry-free infrastructure.

### BXCanonical-specific (not directly reusable for Rat)

| Module | Lines | Why not reusable |
|--------|-------|-----------------|
| `Frame.lean` | 673 | Uses BXPoint ordering specific to base logic |
| `TruthLemma.lean` | 320 | MCS-level truth, complementary to parametric |
| `Quasimodel/` | 1,816 | Defect-discharge uses finite sigma-closure |
| `Filtration/` | 316 | Sigma-restricted ordering |

These modules are specific to the **MCS-level truth lemma** (connecting formula membership to BXPoint properties). They are NOT needed for the parametric truth lemma, which operates at the FMCS/BFMCS level. Both Int and Rat completeness use the parametric path.

### What's D-specific (must be written per domain)

The only D-specific component is `construct_bfmcs`:
```lean
construct_bfmcs : (M : Set Formula) -> SetMaximalConsistent M ->
  Sigma' (B : BFMCS D) (h_tc : B.temporally_coherent)
         (h_buc : B.backward_until_since_coherent)
         (h_fuc : B.forward_until_since_coherent)
         (fam : FMCS D) (hfam : fam in B.families) (t : D),
         M = fam.mcs t
```

For D = Int, this requires the dovetailed chain construction (~400-650 lines per the prior report).
For D = Rat, this requires a density-aware chain construction (estimated 600-1000 lines, more complex).

## Parametric Framework Flexibility

### Is `ParametricCanonicalTaskFrame D` already parameterized over arbitrary D?

**Yes, fully.** The definition at `ParametricCanonical.lean:198`:
```lean
def ParametricCanonicalTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] : TaskFrame D
```

works for any D satisfying the three typeclasses. The task relation uses `ExistsTask` (g_content inclusion) for positive durations, equality for zero, and converse for negative -- all of which are D-independent (they depend only on MCS structure, not on the specific D).

### What constraints does D carry?

The truth lemma requires `B.temporally_coherent`, `B.backward_until_since_coherent`, and `B.forward_until_since_coherent`. These are properties of the BFMCS B, not of D itself. However, *constructing* a BFMCS satisfying these conditions depends on D:

- **temporally_coherent** requires `forward_F` and `backward_P`: existence of F/P witnesses in the same family. For D = Int, the dovetailed chain places witnesses at integer offsets. For D = Rat, witnesses must be placed at rational offsets while maintaining density properties.

- **forward_until_since_coherent** requires Until/Since witnesses with guard intervals populated. For D = Int, the guard is trivially empty (adjacent integers). For D = Rat, the guard is a non-empty open interval.

### Would extending to Rat require new truth lemma proofs?

**No.** The `parametric_canonical_truth_lemma` and `parametric_shifted_truth_lemma` are D-parametric. Once a BFMCS over Rat is constructed satisfying the three coherence conditions, the truth lemma applies unchanged. Parametricity gives this for free.

### What about Real?

Real also satisfies `AddCommGroup + LinearOrder + IsOrderedAddMonoid`. If someone constructs a BFMCS over Real, the truth lemma applies. However, Real is complete (order-complete), which is strictly stronger than dense. The standard result is that TM is complete over all linear orders, so Real adds no new completeness challenges beyond those of Rat.

## Until/Since in Dense Time

### The Core Challenge

In dense time (D = Rat), the Until guard interval `[t, s)` for `t < s` is always non-empty (contains infinitely many rationals). The chain construction must ensure `phi in fam.mcs r` for ALL `r in [t, s)`.

### Standard Mathematical Approaches

**Approach 1: Controlled witness placement.** Place the Until witness at a specific `s > t` and construct the chain so that all MCS in `[t, s)` contain `phi`. This requires:
- Either making `fam.mcs` constant on `[t, s)` (all map to the same MCS, which contains `phi`), or
- Ensuring that `phi` is in the g_content of every MCS constructed in that interval.

The first option (constant on intervals) is the simplest. If `phi U psi in fam.mcs t`, we can set `fam.mcs r = fam.mcs t` for all `r in [t, s)` and `fam.mcs s` to a new MCS witnessing `psi`. The challenge is that other formulas may impose conflicting requirements (other Until obligations with different guard formulas).

**Approach 2: Cantor-domain construction.** Build the chain over a countable dense linear order (isomorphic to Rat by Cantor's theorem) by interleaving obligation resolution with density-fill steps. This is the approach hinted at in the legacy `DFromCantor.lean` and the SuccChain architecture.

**Approach 3: Topological/order-theoretic.** Show that the set `{r : D | phi in fam.mcs r}` is clopen in the order topology, using the fact that MCS membership of `phi` is determined by the chain's monotonicity properties. This is more abstract but may give a cleaner proof.

### Does this fundamentally change the architecture?

**No.** The frame, model, truth lemma, and representation theorem are unchanged. Only the BFMCS construction is different. The architecture already accommodates this via the `construct_bfmcs` callback pattern in `parametric_algebraic_representation_conditional`.

The difference is entirely contained in the construction of the temporally coherent, Until/Since coherent BFMCS over D. For Int, the dovetailed chain is relatively straightforward. For Rat, it requires a more sophisticated construction, but the downstream machinery is identical.

### BX8 and reflexive Until help

Under the codebase's reflexive semantics, `psi -> (phi U psi)` (BX8, `Axioms.lean:202`). This means the witness `s = t` is always available: if `psi in fam.mcs t`, then `phi U psi in fam.mcs t` with the trivially empty guard. This simplifies the base case for both Int and Rat.

For dense time, the non-trivial case is when the Until witness must be strictly in the future (`s > t`). Here, BX5 (self-accumulation: `(phi U psi) -> ((phi /\ (phi U psi)) U psi)`) ensures that the Until formula enriches its own guard. Combined with BX10 (`(phi U psi) -> F(psi)`) and the chain's F-resolution, we eventually reach a point `s > t` with `psi in fam.mcs s`. The guard `[t, s)` is handled because every intermediate point contains `phi /\ (phi U psi)` by self-accumulation.

The key insight: **self-accumulation (BX5) propagates the Until formula itself through the guard interval**, which is what makes the guard-population problem tractable even in dense time. At every intermediate point `r in [t, s)`, we have `phi U psi in fam.mcs r`, which by BX9 (`until_elim`) gives `phi \/ psi in fam.mcs r`. If `psi in fam.mcs r`, we found an earlier witness. If `phi in fam.mcs r`, the guard is satisfied at `r`. By well-ordering of the witness set, we find the earliest witness, and the guard is satisfied everywhere before it.

## Publication Alignment

### What would reviewers expect?

For a publication-quality completeness proof of BX (Burgess-Xu) axioms:

1. **Completeness over all linear orders** (the Burgess 1982 / Xu 1988 result). The base BX axioms are complete for ALL reflexive linear temporal orders, not just Int or Rat. The codebase's `valid phi` definition quantifies over ALL D, which is the strongest possible formulation. Closing task 93 with D = Int suffices because `valid phi` being false (exhibited by the Int countermodel) contradicts the hypothesis.

2. **Discrete completeness** (adding DF axiom) is a follow-up but not essential for the core result. Reviewers would view it as a nice extra.

3. **Dense completeness** (adding DN axiom) is similarly a follow-up. The Burgess 1982 paper does handle dense/discrete extensions but typically as separate theorems.

4. **Generality of the parametric infrastructure** would impress reviewers. The fact that the truth lemma is proved once for arbitrary D and reused for all domain types is a strength of the formalization.

### Is proving completeness only for Int sufficient?

**Yes, for the base logic.** The `bx_completeness` theorem states `valid phi -> Nonempty (DerivationTree [] phi)`. Since `valid phi` quantifies over ALL D, exhibiting a countermodel for ANY specific D (even Int) suffices to prove `not (valid phi)`. The contrapositive gives the completeness theorem.

The key insight: we are not proving "completeness over Int" (which would be `valid_over_Int phi -> provable phi`). We are proving "completeness over ALL D" by showing that non-provability gives a countermodel over Int. Since Int is one of the possible D values, this countermodel witnesses `not (valid phi)`.

### How does this compare to published formalizations?

To my knowledge, there is no published Lean formalization of BX completeness for Since/Until temporal logic. Published temporal logic formalizations in proof assistants include:
- LTL completeness in Coq (various)
- CTL* model checking in Isabelle/HOL
- Basic tense logic (G/H only) in Lean (partial)

A complete formalization of the full BX system with Until/Since, including the quasimodel/defect-discharge technique for eventuality resolution, would be a novel contribution. The parametric D approach and the reflexive semantics with half-open guards are additional points of interest.

## Strategic Recommendations

### Recommendation 1: Close task 93 with D = Int (immediate priority)

The base completeness theorem needs exactly one thing: `construct_bfmcs` for D = Int. The Int guard-interval trick makes this tractable. The dovetailed chain construction from the prior research report (Section 5.3) is the right approach. Estimated ~400-650 lines.

**Do not attempt to solve both Int and Rat simultaneously.** The Int case is strictly simpler and is sufficient for the publication-quality base completeness theorem.

### Recommendation 2: Factor `construct_bfmcs` as a separate module

Create `BXCanonical/CanonicalModel.lean` (or `Algebraic/IntBFMCS.lean`) containing the Int-specific BFMCS construction. This keeps the D-parametric infrastructure clean and makes it obvious where the Rat construction would plug in later.

### Recommendation 3: Dense completeness as a separate follow-up (task 68)

After task 93 closes, tackle task 68 (dense completeness) as a separate effort. The approach:
1. Construct a BFMCS over Rat using a Cantor-domain chain construction.
2. Prove the three coherence conditions for the Rat BFMCS.
3. Instantiate `parametric_algebraic_representation_conditional` with D = Rat and the construction.
4. Prove `valid_dense phi -> Nonempty (DerivationTree_dense [] phi)` using the Rat countermodel.

This builds on the same parametric infrastructure with no changes needed to the shared layer.

### Recommendation 4: Do NOT introduce a `TemporalDomain` class or other abstraction

The existing typeclass decomposition (`AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`) is precisely right. Additional abstraction would add complexity without enabling any code sharing that doesn't already exist. The Int and Rat constructions genuinely differ in technique; abstracting over them would create a leaky abstraction.

### Recommendation 5: Discrete completeness (adding DF) is lowest priority

The `valid_discrete` path requires SuccOrder/PredOrder instances and the discrete axiom DF. This adds complexity without scientific payoff beyond the base theorem. The base BX completeness over all linear orders is the headline result.

### Recommendation 6: Preserve the parametric architecture for the paper

The paper should emphasize:
- The truth lemma is proved ONCE for arbitrary D (not separately for Int and Rat).
- The representation theorem is conditional on BFMCS construction, which is the only D-specific component.
- This architectural separation enables independent extensibility.

This is a genuine contribution to the formalization methodology literature.

## Confidence Level

**High confidence** on all findings. The analysis is based on direct reading of:
- All parametric infrastructure files (`ParametricCanonical.lean`, `ParametricHistory.lean`, `ParametricTruthLemma.lean`, `ParametricRepresentation.lean`)
- All BFMCS/FMCS definitions (`BFMCS.lean`, `FMCSDef.lean`, `TemporalCoherence.lean`)
- Validity definitions (`Validity.lean:73, 160, 178`)
- Soundness files (`Soundness.lean`, `DenseSoundness.lean`, `DiscreteSoundness.lean`)
- Legacy completeness files (`DenseCompleteness.lean`, `DiscreteCompleteness.lean` in Boneyard)
- The sorry at `Completeness.lean:154` and its surrounding context
- The full roadmap (`ROAD_MAP.md`)
- The prior research report (`01_taskmodel-embedding.md`)

The guard-interval analysis for Int vs Rat is mathematically precise. The reuse assessment is based on reading the actual module signatures and type constraints.

## References

- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` -- D-parametric TaskFrame (lines 198-205)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- D-parametric truth lemma
- `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` -- D-parametric history conversion and shift-closure
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` -- Conditional representation theorem (lines 254-269)
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` -- BFMCS structure definition (line 84)
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` -- FMCS structure (line 99)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` -- Coherence conditions (lines 265, 503, 518)
- `Theories/Bimodal/Semantics/Validity.lean` -- `valid` (line 73), `valid_dense` (line 160), `valid_discrete` (line 178)
- `Theories/Bimodal/Semantics/TaskFrame.lean` -- TaskFrame structure (line 93)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- The sorry at line 154
- `Theories/Bimodal/Metalogic/DenseSoundness.lean` -- DN soundness
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` -- DF soundness
- `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/DenseCompleteness.lean` -- Legacy dense infrastructure
- `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/DiscreteCompleteness.lean` -- Legacy discrete infrastructure
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- BX axiom system (BX1-BX12)
- `specs/ROAD_MAP.md` -- Project roadmap (tasks 93, 68, 95)
- `specs/093_complete_bxcanonical_embedding/reports/01_taskmodel-embedding.md` -- Prior research
