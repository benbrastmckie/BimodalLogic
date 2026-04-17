# Teammate D: Literature + Strategic Horizons

## Key Findings

### Part 1: Literature Review -- How Standard Completeness Proofs Handle F-Eventuality

#### 1.1 The Standard Henkin-Style Construction for Temporal Logic

The standard completeness proof for temporal logics (G, H, F, P over linear time) follows the Henkin paradigm adapted by Goldblatt (1992), Burgess (1984), and Gabbay-Hodkinson-Reynolds (1994):

1. **Start with an MCS w0 containing the target formula.**
2. **Enumerate all eventuality demands.** Since the language is countable, the set of F-formulas and Until-formulas appearing in w0's closure is countable. Fix an enumeration: e0, e1, e2, ...
3. **Build the chain by dovetailing/round-robin.** At step n, the construction addresses eventuality e_{n mod k} (where k is the number of outstanding eventualities). If the current MCS w_n contains F(psi), extend to w_{n+1} containing psi (using Lindenbaum extension from a consistent seed).
4. **The fairness property is built into the enumeration.** Because the construction cycles through all eventualities in round-robin fashion, every F(psi) eventually gets its turn. When it does, psi appears in w_{n+1}, and since psi implies F(psi) (by the T-axiom for reflexive G), F(psi) persists.

**Critical insight**: In the standard construction, F-eventuality discharge happens DURING chain construction, not before. The chain is built step-by-step, and the round-robin scheduling over a COUNTABLE enumeration of formulas ensures fairness. This is fundamentally different from the quasimodel approach, which operates on a FINITE graph.

#### 1.2 The Quasimodel Method (Reynolds 1996, 2003)

Reynolds' quasimodel approach is used primarily for DECIDABILITY rather than completeness. The technique:

1. **Atoms**: Define "atoms" as maximal propositionally consistent subsets of a finite closure set Sigma. These are analogous to Hintikka sets.
2. **Quasimodel**: A finite directed graph on atoms with edges satisfying temporal coherence (G-propagation, H-backward).
3. **Defect discharge**: For Until formulas (phi U psi), the quasimodel tracks "defects" -- atoms where phi U psi holds but psi does not. The construction ensures that following edges from any defective atom, one eventually reaches an atom where psi holds. This is guaranteed by a FINITE defect-counting argument: at each step, either a defect is discharged (decreasing the count) or the target is reached.
4. **Unfolding**: The finite quasimodel is unfolded into an omega-chain. The key theorem: the quasimodel has the "finite quasimodel property" -- any satisfiable formula is satisfiable in a finite quasimodel.

**Key difference from F-eventuality**: The quasimodel defect discharge is designed for UNTIL formulas, where the defect count (bounded by |Sigma|) provides a well-founded termination measure. For F(psi), the situation is simpler: F(psi) is equivalent to (true U psi) in many temporal logics with Until. If the logic has Until, F-eventuality reduces to Until-eventuality.

**However**: In the BX system, F is NOT defined as (true U psi). F(psi) = neg(G(neg(psi))). The BX axioms treat F and Until as independent operators. This means the quasimodel Until-defect discharge does NOT automatically handle F-defects.

#### 1.3 Gabbay-Hodkinson-Reynolds (GHR 1994)

The monograph "Temporal Logic: Mathematical Foundations and Computational Aspects" (OUP 1994) provides the most comprehensive treatment. Key contributions:

- **Separation property**: Gabbay proved that Until and Since are expressively complete over (N, <) -- the "separation theorem." This means any temporal property can be expressed using Until/Since alone.
- **Completeness via step-by-step construction**: GHR use a variant of the Henkin construction where the omega-chain of MCS is built one step at a time, with explicit scheduling of eventuality obligations.
- **The Gabbay Irreflexivity Rule**: For branching time logics, Burgess (1980) used this rule. For linear time, the construction is more direct.

#### 1.4 Filtration Techniques

Filtration is used for DECIDABILITY (finite model property) rather than completeness. The standard filtration for temporal logic:

1. Take the canonical model (infinite, omega-chain of MCS).
2. Define equivalence classes: w ~ v iff w and v agree on all Sigma-formulas.
3. The quotient model is finite (bounded by 2^|Sigma|).

Filtration does NOT directly help with F-eventuality discharge. The issue is that filtration can collapse distinct time points, potentially destroying the witness ordering. For F-eventuality, filtration requires additional care: one must show that the filtrated model preserves the existence of witnesses.

The codebase's `SigmaOrdering.lean` implements sigma-restricted ordering on BXPoints -- this is precisely the filtration infrastructure. But as noted in the obstruction analysis, this does not solve the chain construction problem.

#### 1.5 The Mosaic Method (Marx, Mikulas, Reynolds 2000)

The mosaic method is an alternative to quasimodels for proving decidability and completeness:

1. **Mosaics**: Small fragments (typically pairs or triples) of time points with their temporal relationships.
2. **Mosaic sets**: Collections of mosaics that are "saturated" -- every eventuality demand in a mosaic is satisfiable by extending with another mosaic from the set.
3. **Model existence theorem**: A formula is satisfiable iff there exists a saturated mosaic set containing a mosaic with that formula.

**Crucial extension**: Marx and colleagues extended the mosaic method to BIMODAL logics combining tense operators with S5. Published in Logica Universalis (2012), this work by Hodkinson and others shows:

- Mosaics can capture the interaction between temporal and modal dimensions.
- Model existence equates to the existence of mosaic sets.
- This enables decidability proofs AND completeness of Hilbert axiomatizations for combined temporal-modal logics.

**Relevance to ProofChecker**: This is directly relevant. The TM logic combines S5 with linear temporal logic -- exactly the setting of the extended mosaic method. However, formalizing the mosaic method would be substantial new infrastructure, and the codebase already has quasimodel infrastructure.

### Part 2: Codebase Mapping

#### 2.1 Correspondence Table

| Literature Concept | Codebase Entity | File | Status |
|---|---|---|---|
| Atom / Hintikka set | `HintikkaPoint Sigma` | Quasimodel/HintikkaPoint.lean | Complete |
| Quasimodel step relation | `hintikka_step` | Quasimodel/Construction.lean:45 | Complete |
| Until-defect | `UntilDefect`, `defect_count` | Quasimodel/Construction.lean:58-79 | Complete |
| Since-defect | `SinceDefect`, `since_defect_count` | Quasimodel/Construction.lean:62, 310 | Complete |
| Defect-discharge chain | `QuasimodelChain` | Quasimodel/Construction.lean:382 | Structure complete, existence proof incomplete |
| Step oracle | `HintikkaStepOracle` | Quasimodel/Construction.lean:477 | Type complete |
| Sigma-restricted ordering | `sigma_le`, `sigma_strict` | Filtration/SigmaOrdering.lean:54-64 | Complete |
| Sigma-defect count | `sigma_defect_count` | Filtration/DefectChain.lean:47 | Complete |
| FMCS (time-indexed MCS family) | `FMCS D` | Bundle/FMCSDef.lean:99 | Complete |
| Temporally coherent family | `TemporalCoherentFamily D` | Bundle/TemporalCoherence.lean:147 | Structure complete, construction needs forward_F/backward_P |
| Until eventuality resolution | `bx_until_eventuality_resolution'` | Quasimodel/LocusControl.lean:32 | Complete (delegates to Frame) |
| Realization lifting | `until_eventuality_resolution` | Quasimodel/Realization.lean | Complete |
| F-eventuality in chain | `forward_F` field | Bundle/TemporalCoherence.lean:149 | **THE SORRY** |
| P-eventuality in chain | `backward_P` field | Bundle/TemporalCoherence.lean:152 | **THE SORRY** |

#### 2.2 What Is Already Built

The quasimodel infrastructure is substantial and handles UNTIL/SINCE eventuality discharge:
- `HintikkaPoint` with formula sets restricted to finite `Sigma`
- `hintikka_step` relation with G-propagation and Until-defect propagation
- `defect_count` providing the well-founded termination measure
- `QuasimodelChain` structure with target defect tracking
- `HintikkaStepOracle` abstraction for modular chain construction
- `hintikka_step_target_decrease` proving defect count strictly decreases

The FMCS and TemporalCoherentFamily structures are also complete, with the backward lemmas (temporal_backward_G, temporal_backward_H) proven via contraposition FROM forward_F/backward_P.

#### 2.3 What Is Missing

The gap is specifically between the Until/Since quasimodel infrastructure and the F/P eventuality requirements:

1. **No F-defect tracking**: The quasimodel tracks Until-defects and Since-defects, but NOT F-defects. There is no `FDefect` type, no `f_defect_count`, and no `FDefectChain`.

2. **No bridge from Until-discharge to F-discharge**: Even though the quasimodel can discharge Until(phi, psi) (producing a chain where psi appears), this does not automatically produce F(psi) witnesses. The BX axioms give `Until(phi, psi) -> F(psi)` (BX10), but the chain construction needs to go the OTHER direction: given F(psi), produce a chain point where psi holds.

3. **No omega-chain unfolding**: The quasimodel produces finite chains (for each Until defect). There is no mechanism to unfold these into an infinite omega-chain indexed by Int (as required by `FMCS Int`).

#### 2.4 Where the Codebase Diverges from the Standard Approach

The standard approach (Goldblatt, GHR) constructs the omega-chain of MCS DIRECTLY via Henkin enumeration with round-robin scheduling. The codebase instead:

1. Built the BXCanonical canonical model (BXPoint = MCS with bx_le preorder).
2. Attempted to construct the chain via BX11-fold (`resolving_enriched_fwd_exists`), processing multiple defects simultaneously.
3. This led to the perpetual-deferral obstruction: BX11's disjunctive case analysis allows the target formula to be F-wrapped indefinitely.

The literature avoids this problem by NOT trying to resolve multiple defects simultaneously. Instead, it uses SEQUENTIAL targeting: at each step, exactly ONE eventuality is targeted, and the construction cycles through all of them.

### Part 3: Strategic Horizons

#### 3.1 The Quasimodel Bridge: Benefits Beyond forward_F

If implemented, the quasimodel bridge would provide:

1. **Decidability infrastructure**: The finite quasimodel property gives a decision procedure for satisfiability. This is separate from completeness but valuable.
2. **Reusable for other logics**: The quasimodel + mosaic framework generalizes to many temporal logics. If the project extends to CTL*, branching time, or metric temporal logic, this infrastructure transfers.
3. **Cleaner architecture**: The quasimodel approach separates concerns: finite graph construction (combinatorial) from model extraction (logical). This makes the proof more modular.

#### 3.2 Simpler Alternative: Direct Henkin Chain with Round-Robin

The literature suggests a SIMPLER alternative that the project has not fully explored:

**Proposal**: Instead of the quasimodel bridge, build the omega-chain directly using the standard Henkin technique:

1. **Enumerate** all F-formulas in the subformula closure: F(psi_1), F(psi_2), ..., F(psi_k).
2. **Build chain(n)** using round-robin: at step n, target defect is psi_{n mod k}.
3. **Use `self_resolving_fwd_step`** (already proved, line ~1961): given F(psi) in M, build M' with psi in M' AND F(psi) in M' AND g_content(M) subset of M'.
4. **The key**: `self_resolving_fwd_step` resolves the target AND preserves the target's F-obligation. But it does NOT preserve OTHER F-obligations.

**Why this might work where previous attempts failed**: The previous round-robin attempts (rejected approach #4 in the obstruction analysis) used `enriched_fwd_step` or `fwd_succ`, which do NOT preserve F-obligations for non-target formulas. But `self_resolving_fwd_step` has a STRONGER guarantee: it preserves F(psi) for the TARGET. The question is whether we can modify the construction to cycle through targets while preserving all obligations.

**Critical question**: When targeting psi_i at step n, does the construction preserve F(psi_j) for j != i? If `self_resolving_fwd_step` kills F(psi_j), then after k steps (one full cycle), psi_j's F-obligation may have been killed at steps not targeting it. This is the SAME obstruction as before.

**Resolution via the literature**: The standard Henkin construction avoids this by noting that in a CONSISTENT MCS, if F(psi) is derivable, it PERSISTS under g_content propagation. The key lemma is: if F(psi) in M and g_content(M) subset M', then F(psi) in M' (because G(P(F(psi))) in M by BX4, so P(F(psi)) in M', and... no, this does not give F(psi) in M').

Actually, the codebase already proves `defect_fwd_chain_F_obligation_persists`: F(psi) in chain(n) implies F(psi) in chain(n+1), for the CURRENT chain construction. The problem is not persistence but DISCHARGE.

**Revised understanding**: The round-robin approach DOES preserve all F-obligations (by `F_obligation_persists`). The problem is that when we TARGET psi_i, we need the chain construction to actually PUT psi_i into the next MCS. `self_resolving_fwd_step` does this for a SINGLE defect (singleton case, proved at line ~2155). The multi-defect obstruction is that `defect_fwd_step_choice` uses Classical.choice to select which defect to resolve, and we cannot force it to choose our target.

**The fix**: Replace `defect_fwd_step_choice` with a TARGETED step that resolves a SPECIFIC defect. This is exactly what `self_resolving_fwd_step` does! The round-robin chain would be:

```
chain(0) = M_0
chain(n+1) = self_resolving_fwd_step(chain(n), psi_{n mod k})
             if F(psi_{n mod k}) in chain(n)
           = enriched_fwd_step(chain(n))
             otherwise
```

This construction targets each defect in turn. When F(psi_i) is in chain(n) and n mod k = i, `self_resolving_fwd_step` puts psi_i into chain(n+1). Since F-obligations persist (already proved), F(psi_i) is still in chain(n) when step n arrives (it was put there at some earlier step and persisted).

**The remaining question**: Does `self_resolving_fwd_step` preserve the FMCS structure? Specifically, does it preserve g_content propagation? The obstruction report says it does (g_content(M) subset of M' is part of the guarantee). So the chain still satisfies forward_G.

#### 3.3 Most Mathematically Elegant Long-Term Solution

The most elegant approach combines insights from multiple directions:

1. **Short term** (close forward_F): Use the round-robin construction with `self_resolving_fwd_step` as described above. This requires:
   - Defining the round-robin chain (~50 LOC)
   - Proving F-obligation persistence across targeted steps (~30 LOC, may already follow from existing `F_obligation_persists`)
   - Proving forward_F by construction (~30 LOC)
   - Total: ~110 LOC

2. **Medium term**: Extend the quasimodel infrastructure to also handle F-defects. This unifies the Until-discharge and F-discharge mechanisms.

3. **Long term**: Formalize the mosaic method for bimodal S5+temporal logics. This provides a general framework applicable to logic extensions.

## Recommended Approach

**Primary recommendation**: The round-robin construction with `self_resolving_fwd_step` is the most direct path. It leverages existing sorry-free infrastructure:
- `self_resolving_fwd_step` (line ~1961, sorry-free)
- `defect_fwd_chain_F_obligation_persists` (line ~2061, sorry-free)
- `defect_fwd_chain_F_obligation_constant` (line ~2077, sorry-free)

The key insight from the literature is that the standard Henkin construction does NOT try to resolve all defects simultaneously. It uses sequential targeting with round-robin scheduling, relying on the PERSISTENCE of untargeted F-obligations. The codebase already has the persistence lemmas. What is missing is the targeted chain construction that cycles through defects one at a time.

**If the round-robin approach fails** (because `self_resolving_fwd_step` does not preserve F(psi_j) for non-target j): Fall back to the quasimodel bridge (Path A), which is the standard technique with highest confidence but higher LOC cost.

**Critical verification needed**: Check whether `self_resolving_fwd_step` preserves F-obligations for NON-TARGET formulas. If F(psi_j) in M and we target psi_i (i != j), does M' = self_resolving_fwd_step(M, psi_i) still contain F(psi_j)? This depends on whether f_carry is included in the seed. The existing `F_obligation_persists` is for the CURRENT chain construction (which uses `defect_fwd_step_choice`), not for `self_resolving_fwd_step`.

## Evidence/Examples

### Literature Sources

1. **Goldblatt (1992)**: "Logics of Time and Computation" -- canonical model construction for temporal logic, Henkin-style chain building
2. **Burgess (1984)**: "Basic tense logic" -- defect-discharge construction for Until, axiom system BX
3. **Reynolds (1996, 2003)**: Quasimodel technique for decidability, one-pass tableau for LTL
4. **Gabbay, Hodkinson, Reynolds (1994)**: "Temporal Logic: Mathematical Foundations and Computational Aspects" -- comprehensive completeness proofs
5. **Marx, Mikulas, Reynolds (2000)**: "The Mosaic Method for Temporal Logics" -- alternative to quasimodels
6. **Logica Universalis (2012)**: Extended mosaics for bimodal logics combining tense with S5
7. **Verbrugge (2004)**: "Completeness by Construction for Tense Logics of Linear Time" -- step-by-step completeness proofs for Lin, P, D, Z, Q, R
8. **Xu (1988)**: "On some U,S-tense logics" -- axiomatization results for the Burgess system

### Codebase Evidence

- `self_resolving_fwd_step` (RootScopedChain.lean ~1961): Proven sorry-free. Takes F(psi) in M, produces M' with psi in M', F(psi) in M', g_content(M) subset M'.
- `defect_fwd_chain_F_obligation_persists` (RootScopedChain.lean ~2061): F(psi) in chain(n) implies F(psi) in chain(n+1). Sorry-free.
- `defect_fwd_step_choice_singleton` (RootScopedChain.lean ~2155): Single-defect forward_F proved. Obstruction is ONLY multi-defect.
- `TemporalCoherentFamily` (Bundle/TemporalCoherence.lean:147): Requires forward_F and backward_P fields. These are the exact sorries we need to close.
- `temporal_backward_G` / `temporal_backward_H` (Bundle/TemporalCoherence.lean:166-205): Already proven FROM forward_F/backward_P by contraposition.

## Confidence Level

**Medium-High** (70%)

Justification:
- The literature strongly supports the round-robin / sequential-targeting approach. It is the standard technique.
- The codebase has the essential building blocks (self_resolving_fwd_step, F_obligation_persists).
- The remaining risk is whether `self_resolving_fwd_step` preserves non-target F-obligations. This needs verification by reading the exact implementation.
- If non-target preservation fails, the quasimodel bridge (Path A) remains viable but requires more work (~800-1200 LOC vs ~110 LOC).
- The mosaic method for bimodal logics is theoretically the most general approach but would require substantial new infrastructure not justified for closing a single sorry.
