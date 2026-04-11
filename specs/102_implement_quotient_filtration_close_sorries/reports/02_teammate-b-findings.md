# Teammate B Findings: Alternative Approaches for Closing Until/Since Sorries

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Focus**: Alternative approaches that bypass the bx_le non-totality blocker
- **Date**: 2026-04-11

## Key Findings

### Alternative 1: Finite Linear Model Construction

**Assessment**: This is the most viable approach, but requires significant new infrastructure.

The codebase already has extensive quasimodel infrastructure:

- `HintikkaPoint Sigma` (in `Quasimodel/HintikkaPoint.lean`): Finite, locally consistent, locally maximal subsets of a Sigma-closure. These are effectively the Sigma-equivalence classes of BXPoints.
- `sigma_signature` (line 143 of HintikkaPoint.lean): Projects a BXPoint to its HintikkaPoint by intersecting with Sigma.
- `hintikka_step` (line 45 of Construction.lean): One-step relation between HintikkaPoints capturing G-propagation, H-backward, and Until defect propagation.
- `defect_count` / `untilDefectSet` (lines 75, 235 of Construction.lean): Termination measure for chain construction, bounded by `|Sigma|`.
- `hintikka_step_target_decrease` (line 275 of Construction.lean): When a defect is discharged, the defect count strictly decreases.

There is NO existing `TaskModel` or finite linear model construction. The completeness theorem in `Completeness.lean` has a sorry for the TaskModel embedding (separate task 93).

**Construction path**: Build a `DefectChain` structure -- a finite list of BXPoints `w0, w1, ..., wk` where:
- Each consecutive pair satisfies `bx_le`
- `phi in wi` for all `i < k` (guard)
- `psi in wk` (goal)
- Defect count decreases along the chain (termination)

The chain construction itself is feasible via well-founded recursion on `sigma_defect_count`. The building blocks exist:
- BX9 gives `phi or psi` at each step
- BX10 gives `F(psi)` for finding forward witnesses
- BX5 (self-accumulation) enriches the guard with `phi U psi`
- `bx_forward_witness` constructs the next BXPoint

**The fundamental obstacle**: Even with a chain in hand, the guard property for ARBITRARY intermediate BXPoints `u` (not just chain members) remains unresolvable. The chain proves the guard for its own members, but the Frame.lean sorry signatures require `phi in u` for ANY `u` satisfying `bx_le w u`, `bx_le u v`, `not bx_le v u`. An arbitrary `u` need not be a chain member, and its Sigma-signature need not match any chain member.

**Resolution path**: The finite linear model approach would require RESTRUCTURING the truth lemma to avoid the problematic universal guard quantification. Instead of proving the existing Frame.lean sorry signatures, one would:
1. Build a finite linear `TaskModel` from the defect-discharge chain
2. Prove the truth lemma directly in that finite model
3. Prove completeness via the finite model, bypassing Frame.lean entirely

This is architecturally clean but requires:
- A new `TaskModel` instance (Filtration/FiltrationModel.lean)
- A linear ordering proof on realized HintikkaPoints (using BX7/BX11)
- A separate truth lemma for the filtration model
- Rewiring the completeness theorem to use the finite model

**Estimated effort**: 30-50 hours. High confidence (80%) but high cost.

### Alternative 2: Until-Induction Axiom

**Assessment**: A formerly present axiom was removed. Restoring it is unsound under reflexive semantics.

Git history reveals the following:
- Commit `a34643e49` (task 83) FIXED `until_induction` with G-wrapped premises
- Commit `1d9bd6160` (task 83 phase 1) REMOVED `until_induction` entirely when switching from strict to reflexive Until/Since semantics

The old axiom was:
```
G(psi -> chi) and G(phi and X(chi) -> chi) -> (phi U psi -> X(chi))
```

This was a DISCRETE axiom (requiring X = next-time operator, defined as `bot U chi`) and was classified as `FrameClass.Discrete`. It is fundamentally incompatible with the current reflexive semantics on dense/continuous linear orders.

**Could we formulate a reflexive variant?** A candidate reflexive induction axiom would be:
```
G(psi -> chi) and G(phi and G(chi) -> chi) -> (phi U psi -> chi)
```

Analysis: Under reflexive semantics, `phi U psi` at time t means there exists s >= t with psi(s) and phi holds on [t, s). If G(psi -> chi) holds (psi implies chi at all times) and G(phi and G(chi) -> chi) holds (phi with always-chi implies chi), then:
- At s: psi(s), so chi(s) (by the base case)
- At s: G(chi) holds at s iff chi holds at all t' >= s. But we only know chi(s), not chi at later times.

This does NOT validate straightforwardly. The induction needs to proceed backward from s to t, but the step case `phi and G(chi) -> chi` requires `G(chi)` which means chi at ALL future times, not just from the current point to s. This makes the axiom too strong -- it would not be sound on general reflexive linear orders.

**Verdict**: No sound reflexive Until-induction axiom that directly closes the sorries has been identified. The discrete version requires X/Y operators not present in the current system.

### Alternative 3: Model Existence (Direct Witness Construction)

**Assessment**: Promising direction but hits the same bx_le propagation gap.

The idea: construct the witness v directly from MCS properties without going through the problematic guard quantification. Specifically:

Given `phi U psi in w` and `psi not in w`:
1. BX10 gives `F(psi) in w`, so `bx_forward_witness` gives v with `bx_le w v` and `psi in v` (Stage 1 -- already in the code at Realization.lean line 478-479)
2. For the guard: BX4 gives `G(P(phi U psi)) in w`, so `P(phi U psi) in u` for any u with `bx_le w u` (already in code at line 491)
3. Backward witness: u' with `bx_le u' u` and `phi U psi in u'` (line 494)
4. BX9: `phi or psi in u'` (line 495)

The gap (documented at lines 496-504 of Realization.lean): `phi in u'` does NOT give `phi in u` because `bx_le u' u` only propagates G-content, and phi is an arbitrary formula.

**Could we construct a SPECIAL witness v such that the guard is trivially satisfied?**

One approach: use the enriched seed `{psi} union g_content(w) union {G(phi)}` (adding `G(phi)` to force phi propagation). But `G(phi)` is NOT derivable from `phi U psi` -- the Until formula says phi holds up to the witness, not that phi ALWAYS holds. So this seed may be inconsistent.

Another approach: construct v via a seed that includes ALL formulas of the form `G(f)` for `f` that must hold at intermediate points. But we don't know which f's those are until we know the intermediate points, creating circularity.

**Verdict**: Direct witness construction cannot avoid the guard gap without either restructuring the proof or finding a new derivation principle.

### Alternative 4: Textbook Reference Check

**Assessment**: Critical finding -- the standard literature uses a DIFFERENT canonical ordering.

**Burgess 1984 ("Basic Tense Logic")**:
- Uses a defect-discharge construction on FINITE Hintikka structures (not infinite MCS)
- The ordering is built INTO the finite structure by the construction itself
- The chain of Hintikka points IS the linear order; there is no ambient preorder to contend with

**Goldblatt 1992 ("Logics of Time and Computation", Ch. 5)**:
- Defines the canonical ordering via `w <= v iff {phi : G(phi) in w} subset v`
- BUT then immediately works in a FILTRATION (finite quotient model) where the ordering becomes total
- The guard proof in the filtration uses the finiteness of the quotient: there are only finitely many possible "intermediate" points, and BX7/BX11 constrain them to be linearly ordered
- The filtration ordering is NOT defined as the quotient of `bx_le`; it is defined independently using the hintikka-step relation

**Blackburn, de Rijke, Venema 2001 ("Modal Logic", Ch. 4)**:
- Uses filtration to obtain the finite model property
- The filtration ordering for temporal logic uses both smallest and largest filtration techniques
- The Until truth lemma is proved in the FILTRATION model, where the ordering is total by construction

**Reynolds 2003 ("An Axiomatization of Full CTL")**:
- Uses axioms that include an explicit induction principle for Until
- The completeness proof directly builds a finite model with a tree structure
- Does not use the g_content-based canonical ordering at all

**Key insight from the literature**: The codebase's `bx_le := g_content subset` is a valid PREORDER on MCSs, but it is NOT the ordering used in standard completeness proofs. Standard proofs either:
(a) Work in a finite model where the ordering is total by construction (Burgess, Goldblatt, BdRV), or
(b) Use an induction axiom that makes the guard provable directly (Reynolds)

The codebase's approach of trying to prove the guard property for arbitrary MCSs under the g_content preorder is non-standard and appears to be fundamentally blocked.

### Alternative 5: Rewriting bx_le

**Assessment**: Technically feasible but very high cost and risk.

**Current definition** (Frame.lean line 61):
```lean
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas
```

**Properties used elsewhere** (159 occurrences across 8 files):
- `bx_le_refl` (from BX1): Used in TruthLemma.lean for reflexive witness cases
- `bx_le_trans` (from temp_4): Used in backward witness construction
- `bx_G_forward` / `bx_H_forward`: Core propagation used ~50 times
- `bx_G_backward` / `bx_H_backward`: Lindenbaum construction for G/H truth
- `bx_forward_witness` / `bx_backward_witness`: F/P witness construction
- `bx_modal_witness`: Modal equivalence witness (separate concern)
- All Until/Since infrastructure in Realization.lean (68 occurrences)
- SigmaOrdering.lean (27 occurrences) defines sigma_le as restriction of bx_le

**What a total ordering would look like**: One could define:
```lean
def bx_le_total (w v : BXPoint) : Prop :=
  ∀ φ, φ ∈ w.formulas → (φ ∈ v.formulas ∨ ∃ ψ, G(ψ) ∈ v.formulas ∧ ψ ∉ w.formulas)
```
But this is not a standard ordering and would require reproving ALL existing lemmas.

Alternatively, one could define an ordering via Until-witness chains:
```lean
def bx_le_chain (w v : BXPoint) : Prop :=
  ∃ chain : List BXPoint, chain.head? = some w ∧ chain.getLast? = some v ∧
    List.Chain' (fun a b => g_content a.formulas ⊆ b.formulas) chain
```
This is equivalent to the transitive closure of `bx_le` (which IS `bx_le` since it's already transitive), so it doesn't help.

**Estimated impact**: Replacing `bx_le` would require modifying all 8 files with 159+ occurrences. The G/H truth lemma (fully proved) uses `bx_le` extensively and would need to be reverified. Estimated effort: 20-40 hours with HIGH risk of introducing new bugs.

**Verdict**: Not recommended. The cost/risk ratio is poor compared to the finite model approach.

## Recommended Approach (Ranked)

### Rank 1: Finite Linear Model Construction (Alternative 1 + insights from Alternative 4)

**Confidence**: Medium-High (75%)

This combines the finite model insight from the textbook analysis with the existing quasimodel infrastructure. The approach:

1. **Do NOT try to prove the existing Frame.lean sorry signatures.** The task 101 research (section 6.4) and the blocker analysis both confirm these signatures are unprovable under the current `bx_le` definition.

2. **Build an independent finite linear model** from a defect-discharge chain:
   - Use existing `HintikkaPoint` infrastructure
   - Define a `LinearOrder` on chain members by position in the chain
   - Prove the Until truth lemma in this finite model directly

3. **Restructure the completeness proof** to use the finite model:
   - Either modify the Frame.lean signatures to use the finite model
   - Or bypass Frame.lean entirely and prove completeness via the finite model

**Key new infrastructure needed**:
- `Filtration/FiltrationModel.lean`: Define the finite model type
- `Filtration/FiltrationOrdering.lean`: Linear ordering on chain members
- `Filtration/FiltrationTruth.lean`: Truth lemma for the finite model
- Modified `Completeness.lean`: Wire through the finite model

**Why this works**: In the finite model, the ordering IS total by construction (it's a finite chain with a position-based ordering). The guard property becomes: for any point at position i with 0 <= i < k, phi holds at position i. This follows directly from the defect-discharge construction (BX9 gives phi at each non-terminal point).

### Rank 2: Signature Restructuring (modify Frame.lean sorries)

**Confidence**: Medium (60%)

Instead of proving the existing sorry signatures, CHANGE THEM to use sigma_strict instead of bx_lt:

```lean
-- Current (unprovable):
∀ u, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u

-- Restructured (possibly provable):
∀ u, bx_le w u → sigma_strict Sigma u v → φ ∈ u
```

The `sigma_strict` guard (from `Filtration/SigmaOrdering.lean`) is weaker than `bx_lt`, meaning fewer u's need to be checked. However, as noted in the blocker summary (section 3 of 01_defect-discharge-summary.md), this makes the forward direction easier but the backward direction harder.

This approach requires careful analysis of whether the TruthLemma.lean consumers can be updated to use the new signatures. The `until_iff_mcs` theorem (TruthLemma.lean line 281) would need to be restated.

### Rank 3: Hybrid BX7 + Finite Model (plan v5 Phase 5, with finite model fallback)

**Confidence**: Low-Medium (40%)

Continue the direct BX7 proof approach from plan v5, but with a hard 15-hour gate. If the BX7 approach does not close `bx_until_eventuality_resolution` in 15 hours, pivot to the finite model construction.

This is essentially the existing plan v5 strategy. The risk is that 15 hours may be wasted on an approach that the mathematical analysis suggests is blocked.

### Not Recommended

- **Until-induction axiom** (Alternative 2): No sound reflexive variant identified. Adding an unsound axiom would invalidate the entire formalization.
- **Rewriting bx_le** (Alternative 5): Cost/risk too high for uncertain benefit.
- **Direct witness construction** (Alternative 3): Hits the same bx_le propagation gap.

## Evidence/Examples

### Code references supporting the blocker diagnosis

1. **Realization.lean lines 496-504**: The exact gap documented in code comments:
   ```
   -- GAP: bx_le u' u only propagates G-content.
   -- φ ∈ u' does NOT imply G(φ) ∈ u', so φ ∈ u is not derivable.
   -- Closing this requires Until-monotonicity or bx_le totality.
   sorry
   ```

2. **Frame.lean line 61**: The bx_le definition that causes non-totality:
   ```lean
   def bx_le (w v : BXPoint) : Prop :=
     g_content w.formulas ⊆ v.formulas
   ```

3. **Construction.lean lines 75-78**: Existing defect_count infrastructure:
   ```lean
   noncomputable def defect_count {Sigma : Finset Formula} (h : HintikkaPoint Sigma) : Nat :=
     (Sigma.filter (fun f => match f with
       | Formula.untl _φ ψ => f ∈ h.formulas ∧ ψ ∉ h.formulas
       | _ => False)).card
   ```

4. **Git history**: Until-induction axiom removed at commit `1d9bd6160` (task 83 phase 1) when switching to reflexive semantics. The axiom was discrete-only, requiring X (next-time) operator.

5. **Task 101 research report section 6.4**: "The standard completeness proofs in the literature do NOT use g_content inclusion as the canonical ordering."

### Existing infrastructure reusable for finite model approach

| Component | File | Status | Reusability |
|-----------|------|--------|-------------|
| HintikkaPoint | Quasimodel/HintikkaPoint.lean | Complete | Direct reuse as finite model points |
| sigma_signature | Quasimodel/HintikkaPoint.lean | Complete | Projects BXPoints to finite model |
| defect_count | Quasimodel/Construction.lean | Complete | Termination measure for chain |
| hintikka_step | Quasimodel/Construction.lean | Complete | One-step relation for chain |
| hintikka_step_target_decrease | Quasimodel/Construction.lean | Complete | Defect decrease proof |
| enrichedClosure | Quasimodel/EnrichedClosure.lean | Complete | Sigma construction |
| sigma_le / sigma_strict | Filtration/SigmaOrdering.lean | Complete | Sigma-restricted ordering |
| sigma_defect_count | Filtration/DefectChain.lean | Complete | Sigma-restricted defect count |
| enriched_seed_consistent_until | Quasimodel/Realization.lean | Complete | Seed consistency for chain steps |

## Confidence Level

- **Diagnosis of the blocker**: HIGH (95%). The bx_le non-totality is well-established through mathematical analysis, code-level documentation, and literature cross-reference. The existing sorry signatures are unprovable under the current framework.

- **Finite model approach (Rank 1)**: MEDIUM-HIGH (75%). This follows the standard textbook construction (Burgess 1984, Goldblatt 1992) and has extensive existing infrastructure to build on. The main risk is the effort required (30-50 hours) and the need to restructure the completeness proof.

- **BX7 direct approach (Rank 3)**: LOW (25%). Multiple rounds of analysis (task 98 plan v5, task 101 research, this investigation) have failed to find a way to close the BX7 disjunction into the guard property. The mathematical structure appears to prevent this approach.
