# Teammate D: Literature & Strategic Horizons

**Session**: sess_1776435423_f21d0d (round 36)
**Date**: 2026-04-17
**Focus**: Temporal logic completeness literature survey and strategic architecture analysis

---

## Literature Survey

### Standard Approaches to Until/Since Eventuality Resolution

The standard academic literature on temporal logic completeness uses several distinct
techniques. After surveying the primary sources, here is what is known and how it
compares to the codebase's approach:

#### 1. Burgess (1982/1984) Defect-Discharge

Burgess provided the first complete axiomatization for the Since-Until logic on
reflexive linear orderings, simplified by Xu (1988). The key technique is:

- Build a model from **maximal consistent sets** (MCS) with a forward relation
- Handle Until-defects (`φ U ψ ∈ M, ψ ∉ M`) via a **one-step discharge**: find a
  successor MCS where the defect is resolved
- The chain structure is essentially: for each defect, take ONE step that includes ψ
- The completeness proof works **over arbitrary linear orderings** (not specifically Z)

The Burgess approach is NOT a round-robin over multiple F-obligations. It handles
one Until-defect at a time in a single resolution step.

**Relevance to codebase**: The `hintikka_step` relation in
`Quasimodel/Construction.lean` mirrors exactly this one-step defect discharge:
```
-- Until defect propagation
(∀ φ ψ, φ U ψ ∈ h1 → ψ ∉ h1 → φ ∈ h1 ∧ φ U ψ ∈ h2)
```
This is the correct design. The `defect_count` decreasing termination argument is
also standard and mirrors what Burgess's proof does.

#### 2. Gabbay-Hodkinson-Reynolds (1994) "Temporal Logic: Mathematical Foundations"

The standard textbook treatment of temporal logic completeness over multiple time
flows. Key findings:

- Completeness over **(Z, <)** (integers with strict order) is more complex than
  over **(N, <)** because of the infinite past
- Standard completeness proofs for tense logic with Until/Since use **backward and
  forward chain construction** from a root MCS
- The F-obligation discharge is handled by the **Henkin chain** approach: extend
  the MCS one step at a time, targeting specific eventualities
- The technique for integers requires building **both** a forward chain (for F) and
  a backward chain (for P), then combining them at a root point

**Key insight**: The literature does NOT combine S5 modal with linear temporal logic
in a single canonical construction — these are treated as separate sub-problems with
a combination theorem.

#### 3. Reynolds (1996, 2003) Quasimodel Technique

Reynolds developed the "quasimodel" method specifically for decidability and
completeness of temporal logics with Until/Since. The technique:

- Defines a **quasimodel** as a finite structure that locally satisfies all axioms
  except the eventuality-discharge conditions
- Proves: if a formula is satisfiable, it is satisfiable in a quasimodel, then
  in a full model
- The key insight: **finite quasimodels** are enough to witness satisfiability;
  the chain building is finite (bounded by the number of subformulas)

Reynolds's quasimodel is the theoretical basis for the code's `Quasimodel/`
directory. The `defect_count` decreasing measure and `QuasimodelChain` structure
directly reflect this.

**How Reynolds handles multiple eventualities simultaneously**: The quasimodel
termination argument counts TOTAL defects across the chain. Each step either
discharges one Until-defect (ψ appears) or propagates it (φ holds, (φ U ψ) carries
forward). Since the formula set is finite, the chain terminates.

**Critical observation**: Reynolds's quasimodel produces a **FINITE** chain (bounded
by |Sigma|). This chain witnesses SATISFIABILITY, not the MCS-level forward_F
property needed for completeness.

#### 4. Marx-Mikulas-Reynolds (2000) Mosaic Method

The mosaic method is a more general technique that:
- Defines "mosaics" as partial models satisfying local consistency conditions
- Proves that if enough mosaics exist to tile the domain, a model can be assembled
- Can handle Until and Since with eventualities by requiring "discharge mosaics"
- Applied to bimodal logics (including S5-like modalities + temporal) in later work

The 2012 Logica Universalis paper "On the Mosaic Method for Many-Dimensional Modal
Logics: A Case Study Combining Tense and Modal Operators" applies this to combined
S5+temporal logics. Key finding: the mosaic method handles the S5 and temporal
components **separately** and then verifies joint consistency — it does NOT require
a single unified chain.

#### 5. Finger-Gabbay (1996) "Combining Temporal Logic Systems"

This paper establishes that for "temporalization" (adding temporal operators to a
base logic), if the base logic is complete and the temporal axioms are complete over
the chosen time flow, the combined system is complete. The proof uses:

- **Transfer of completeness** via separate canonical models for each component
- The temporal part gets its own chain; the modal part gets its own equivalence
  classes
- This is NOT a joint canonical model — it's a **product construction**

**Critical relevance**: BX = S5 + LTL(Until/Since) over Z. The Finger-Gabbay
transfer theorem suggests the right architecture is:
1. Build completeness for the pure temporal part (LTL over Z)
2. Build completeness for S5
3. Combine via a product or two-dimensional construction

The codebase's current approach tries to handle both S5 and temporal in a single
chain, which is harder than the product approach.

#### 6. Standard LTL Completeness (Pnueli, Sistla-Clarke, Manna-Pnueli)

The computer science literature on LTL completeness (for model checking and
verification) uses a different approach:

- Build a **Büchi automaton** from the formula's Fischer-Ladner closure
- States are atoms (consistent and complete subsets of the closure)
- Eventualities are handled by **acceptance conditions** (fairness constraints)
- The Büchi automaton corresponds to an omega-sequence of MCS states where each
  eventuality appears **infinitely often** on any accepting run

The key insight from this literature: **F-obligations can be discharged by an
accepting CYCLE**, not just by a linear chain. Any omega-sequence where each
eventuality appears infinitely often is a valid witness.

**This suggests an important alternative**: Instead of proving that a specific chain
satisfies forward_F, prove that there EXISTS an omega-sequence (possibly different
from the current chain) where all F-obligations are fulfilled, then use it as the
countermodel.

---

### Comparison with the Codebase

#### What the Standard Literature Says About Chain Construction

1. **Standard Henkin/canonical-model construction** for temporal logic builds the chain
   by **sequential targeting**: at step k, target a SPECIFIC eventuality Eₖ and ensure
   it is satisfied at step k+1. The round-robin over eventualities is a standard technique.

2. The BX11 fold (simultaneous multi-defect resolution) is **NOT standard**. Standard
   constructions target one eventuality per step. The BX11 fold tries to resolve all
   F-formulas at once via a "fold" over the formula list — this is the root of the
   perpetual deferral problem.

3. **F-obligation persistence** in the standard approach: The standard construction
   does NOT rely on F(ψ) persisting across steps for non-target ψ. Instead, it relies
   on the fact that at ψ's designated step, F(ψ) is in the current MCS (because the
   standard construction includes f_carry in the seed). The codebase's `enriched_fwd_step`
   was intended to capture this, but the BX11 fold prevents any single formula from
   being targeted.

4. **The depth-stratified insight** in the codebase is sound and standard: the induction
   on F-nesting depth with FF_imp_F_mcs for depth ≥ 1 is a natural simplification
   that is consistent with how these proofs work in the literature.

---

## Strategic Analysis

### What the Codebase Gets Right

1. **BX axiom design** is appropriate. The BX11/BX12 axioms for Until/Since are
   variants of Burgess-Xu axioms, and BX12 (`F(φ) → ⊤ U φ`) is a crucial bridge.
   The codebase's recognition of this bridge (from Round 35) is correct.

2. **The Quasimodel infrastructure** (`Construction.lean`, `HintikkaPoint.lean`,
   `SubformulaClosure.lean`) is well-designed and mirrors the Reynolds quasimodel
   approach. The defect_count termination argument is standard.

3. **The F-nesting depth induction** (depth ≥ 1 handled by FF_imp_F) is a clean
   and correct simplification.

4. **The two-directional chain** (forward for F, backward for P) is the standard
   approach for integer-time temporal logic.

### Where It Diverges from Standard Techniques

#### Divergence 1: The BX11 Fold (CRITICAL)

The original round-robin chain uses `enriched_fwd_step` which applies BX11 as a
"fold" over all F-formulas simultaneously. Standard completeness proofs use a
simpler approach:

- Target ONE formula per step
- Use `f_carry` in the seed to preserve non-target F-obligations
- The consistency of `{target} ∪ g_content(M) ∪ f_carry(M)` must be proved

The BX11 fold was an attempt to handle all F-obligations at once — a non-standard
technique that introduced the perpetual deferral problem (one formula can always be
prioritized over another).

**What the literature does instead**: In standard temporal completeness proofs for
F-operators, the seed for a resolving step is `{ψ} ∪ g_content(M) ∪ f_carry(M)`,
and the consistency follows from `F(ψ) ∈ M` plus the axiom system. The f_carry
is included to preserve other F-obligations.

However, the codebase analysis (ProofSketch Sections 1-30) correctly identifies that
`{target} ∪ g_content(M) ∪ f_carry(M)` consistency is NOT provable in general when
`F(G(¬ψ)) ∈ M` for some ψ ∈ f_carry (Case 4 analysis). This is a genuine obstacle
that the standard literature sidesteps by working over time flows where such
counterexamples cannot arise, OR by using a different approach entirely.

#### Divergence 2: Product vs. Unified Chain

Standard completeness for S5 + temporal uses a **product construction** (modal
equivalence classes + temporal sequence), not a single unified chain. The codebase's
`dd_bfmcs` tries to handle both S5-accessibility (via `families`) and temporal
structure (via `mcs : Int → Set Formula`) in a single structure. This is technically
correct but requires proving interactions that a product construction avoids.

#### Divergence 3: Until/Since vs. F/P as Primary Objects

The literature treats Until/Since as PRIMARY and derives F/P as abbreviations or
special cases. The codebase works primarily with F/P chains and then tries to
recover Until/Since coherence via BX12. This is backwards relative to the standard
approach.

**Consequence**: The round-robin F-obligation chain is the wrong primary structure.
The right primary structure (from literature) is an Until-defect discharge chain
where F is handled via `F(φ) = ⊤ U φ`.

### Recommended Corrections

#### Short-Term: BX12 + Full Until/Since Coherence (Round 36 Goal)

The correct approach, consistent with the literature, is:

1. **Use the quasimodel chain** to prove Until/Since coherence directly (this is what
   the Reynolds quasimodel is designed for)
2. **Derive F/P coherence from Until/Since coherence via BX12/BX12'**
3. The closure alignment gap (⊤ U ψ not in subformulaClosure) is a mechanical issue:
   prove **full** (unrestricted) Until/Since coherence, which covers all Until/Since
   formulas including BX12-derived ones

The critical remaining gap is the **HintikkaStepOracle**: constructing a function that,
given a HintikkaPoint with an Until-defect, produces the next HintikkaPoint. This
requires using `bx_forward_witness` from Frame.lean.

**Why `bx_forward_witness` can provide the oracle**:
- `bx_forward_witness` exists in Frame.lean (lines 164-171)
- Given a `BXPoint w` and `(Formula.neg φ).diamond ∈ w.formulas`, it provides a
  successor BXPoint
- This is exactly what Burgess's one-step defect discharge needs at the MCS level
- The oracle maps this to the Hintikka level via restriction to Sigma

#### Long-Term: Reformulate to Follow Literature Pattern

The most robust architecture change would be to:

1. **Make Until/Since primary**: Build the main chain as an Until/Since defect chain
   (not F/P round-robin)
2. **Use product construction for S5**: Handle S5-accessibility via equivalence
   classes over BXPoints, separately from the temporal chain
3. **Derive F/P from Until/Since via BX12/BX12'**: F and P become derived operators

This restructuring would align the codebase with the standard literature and avoid
the F-persistence obstacle entirely.

---

## Long-Term Architecture Recommendations

### Priority 1: Complete the Oracle (Immediate Blocker)

The single most important missing piece is the HintikkaStepOracle. Without it,
the quasimodel chain cannot run and none of the Until/Since coherence proofs
can be completed. Estimated ~200-300 LOC.

**Constructive path**:
```lean
def hintikka_step_oracle_from_bxpoint (Sigma : Finset Formula)
    (h : HintikkaPoint Sigma) (φ ψ : Formula)
    (h_defect : UntilDefect h φ ψ) : HintikkaPoint Sigma :=
  -- Use until_F_mcs (BX10): (φ U ψ) ∈ h → F(ψ) ∈ h
  -- Use BX12 backwards: F(ψ) ∈ h → (⊤ U ψ) ∈ h
  -- Use bx_forward_witness to get a successor BXPoint
  -- Restrict to Sigma to get a HintikkaPoint
```

### Priority 2: Full Until/Since Coherence (Avoids Closure Gap)

Instead of `restricted_forward_until_since_coherent`, prove:
```lean
theorem dd_bfmcs_full_fuc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) :
    ∀ fam ∈ (dd_bfmcs M₀ h₀ sigma_list).families,
      ∀ t : Int, ∀ φ ψ : Formula,
        Formula.untl φ ψ ∈ fam.mcs t →
        ∃ s ≥ t, ψ ∈ fam.mcs s ∧ ∀ r : Int, t ≤ r → r < s → φ ∈ fam.mcs r
```
This avoids the `subformulaClosure` restriction entirely.

### Priority 3: Reconcile with Filtration/Small Model Infrastructure

The `Filtration/` directory contains `DefectChain.lean` and `SigmaOrdering.lean`
which appear to be a different approach to the same problem. The strategic question:

- Are the Filtration files for decidability (finite model property) or completeness?
- If for decidability: they can remain separate from the completeness proof
- If for completeness: consolidate with the Quasimodel approach

The literature distinguishes: quasimodels → satisfiability, filtration → finite model
property, canonical models → completeness. These are different proof techniques with
different goals.

### Priority 4: Consider F-Depth Induction as Primary Strategy

The codebase's F-nesting depth induction is sound for depth ≥ 1. For depth 0 (the
only problematic case), the literature suggests:

- **Automata approach**: Any formula with F(ψ) ∈ M₀ where ψ has depth 0 can be
  discharged in ONE step via `fwd_succ(M₀, ψ)`. This is the "single-step resolution"
  from Section 4 of ProofSketch_Sections1to30.lean.
- **The problem**: This one-step resolution is for a FRESH chain, not the fixed
  `rr_fwd_chain`.

**Resolution**: The FMCS framework allows choosing the FAMILY (via `dd_bfmcs.families`).
Each family in `dd_bfmcs` is a `shifted_dd_fmcs N h_N sigma_list s`. For the forward_F
property, we need it to hold for ANY starting MCS N. If we can prove forward_F for
a freshly constructed chain targeting ψ, then wire that into the BFMCS family structure
differently (e.g., define one family per depth-0 F-obligation), that might work.

However, this restructures the BFMCS definition, which is a large change.

### Priority 5: Consider Whether omega-Indexed vs Z-Indexed Matters

The literature for S5+temporal over Z (integers) is sparse. Most completeness results
are for omega (natural numbers). The backward chain (for the past) adds significant
complexity. Strategic question: does the project need full Z-time, or could it work
with omega-time and symmetric axioms?

If omega-time suffices, the backward chain complexity drops dramatically: there is no
infinite past to worry about, and all backward-P obligations can be handled by the
initial state.

---

## BX11 Fold vs. Sequential Targeting: The Core Divergence

After reviewing 35+ rounds of analysis and the literature, the fundamental divergence
is clear:

**Standard literature approach** (Burgess, Reynolds, Gabbay-Hodkinson-Reynolds):
- Target EXACTLY ONE formula per step
- Include f_carry in the seed to preserve other F-obligations
- The consistency of `{target} ∪ g_content(M) ∪ f_carry(M)` is proved via the
  axiom system (specifically: if F(target) ∈ M, and F(χ) ∈ M for each χ ∈ f_carry,
  then the seed is consistent because it is a subset of a SUCCESSOR MCS)
- Each formula gets resolved at its own dedicated step

**BX system obstacles** (documented in codebase reports):
- Extended seed consistency `{target} ∪ g_content(M) ∪ f_carry(M)` is NOT provable
  in general (Case 4: F(G(¬ψ)) ∈ M creates an inconsistency)
- This is the ONLY case where the standard approach would fail

**Case 4 analysis**: If `F(G(¬ψ)) ∈ M`, then the seed {target, F(ψ), ...} where
`F(ψ) ∈ f_carry(M)` could be inconsistent because F(G(¬ψ)) ∈ M implies "eventually
always ¬ψ", which is incompatible with "ψ holds now" (the seed includes ψ after
resolution). But wait — the issue is that f_carry may contain BOTH F(ψ) and
related G-formulas that are inconsistent with resolving the target.

**The BX12 bypass**: Instead of fighting the extended seed consistency problem, use
BX12 to convert F-obligations to Until-obligations, then use the quasimodel/Reynolds
technique which handles Until-defects without needing f_carry. The quasimodel step
only propagates `(φ U ψ)` formulas, not arbitrary F-formulas. This sidesteps the
Case 4 obstacle entirely.

---

## Answers to Key Questions

1. **Standard chain construction (sequential vs. simultaneous)?**
   Sequential, one-at-a-time targeting. The BX11 fold (simultaneous) is non-standard
   and is the root cause of perpetual deferral.

2. **Does standard construction face perpetual deferral?**
   No, because sequential targeting with f_carry ensures each formula gets its own
   step. The standard proof schedules each formula at a DEDICATED step and includes
   f_carry in the seed so other obligations are preserved.

3. **What is the literature quasimodel technique?**
   Reynolds's technique: finite chains where defect_count decreases monotonically.
   The codebase's `Quasimodel/` files are a faithful implementation. The gap is the
   oracle construction.

4. **Known completeness proof for S5+LTL(Until,Since) over Z?**
   Not found in the literature survey. Most results are for pure temporal logic over
   specific time flows (Q, R, N, Z separately) or for epistemic+temporal combinations.
   The Finger-Gabbay "combining" approach is the closest standard reference.

5. **Would omega instead of Z simplify the construction?**
   Yes, significantly. The backward chain (for P-obligations) is the major source of
   added complexity. With omega-time, there is no infinite past and backward_P is
   trivially handled at the initial state.

---

## Confidence Level

**MEDIUM-HIGH**

Justification:
- The literature survey confirms the BX12 reduction strategy is sound and well-motivated
- The sequential-vs-simultaneous distinction is confirmed by the literature
- The oracle gap is well-understood and the path to closing it via `bx_forward_witness`
  is clear
- The main uncertainty is whether the closure alignment gap (full vs. restricted
  Until/Since coherence) has hidden obstacles
- The Case 4 obstacle with extended seed consistency is genuine and documented
- Strategic recommendation: pursue BX12 + full Until/Since coherence via oracle
  construction, estimated 600-900 LOC at 65-75% success probability

---

## Sources Consulted

- [Burgess-Xu Axiomatic System - Stanford Encyclopedia](https://seop.illc.uva.nl/entries/logic-temporal/burgess-xu.html)
- [Temporal Logic - Stanford Encyclopedia](https://plato.stanford.edu/entries/logic-temporal/)
- [Hodkinson & Reynolds - Temporal Logic Chapter 11](https://cgi.csc.liv.ac.uk/~frank/MLHandbook/11.pdf)
- [Gabbay, Hodkinson, Reynolds - Temporal Logic (OUP)](https://global.oup.com/academic/product/temporal-logic-9780198537694)
- [Separation paper - Hodkinson & Reynolds](https://www.doc.ic.ac.uk/~imh/papers/sep.pdf)
- [Marx, Mikulas, Reynolds - The Mosaic Method for Temporal Logics](https://www.researchgate.net/publication/221342978_The_Mosaic_Method_for_Temporal_Logics)
- [Finger & Gabbay - Combining Temporal Logic Systems](https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/volume-37/issue-2/Combining-Temporal-Logic-Systems/10.1305/ndjfl/1040046087.pdf)
- [On the Mosaic Method for Many-Dimensional Modal Logics - Logica Universalis](https://link.springer.com/article/10.1007/s11787-012-0074-5)
- [LTL to Büchi automaton - Wikipedia](https://en.wikipedia.org/wiki/Linear_temporal_logic_to_B%C3%BCchi_automaton)
- Codebase: ProofSketch_Sections1to30.lean (exhaustive analysis)
- Codebase: Quasimodel/Construction.lean (Reynolds implementation)
- Codebase: RootScopedChain.lean (sorry sites and obstruction analysis)
- Codebase: Round 35 team research synthesis
