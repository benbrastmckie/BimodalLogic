# Teammate D Findings: Strategic Analysis and Alternative Architectures

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-13
**Focus**: Long-term alignment, literature connections, and strategic alternatives
**Session**: sess_1776115200_d4strt

## Key Findings

### 1. The Scheduling Chain Architecture Is Fundamentally Wrong for This Problem

After reviewing 8 rounds of research, 5 implementation plans, and the exhaustive
analysis in Report 08, the evidence is overwhelming: **the scheduling chain
construction (`fwd_succ`/`bwd_pred` with Lindenbaum extensions) cannot prove
the three remaining sorry sites without either replacing the chain or enriching
it with root-dependent seed modifications.**

The root cause is architectural, not technical:

- **The scheduling chain makes irrevocable Lindenbaum choices.** At each step,
  `set_lindenbaum` extends the seed to an MCS via Zorn's lemma. This extension
  is non-deterministic and may include or exclude any formula not forced by the
  seed. F-formulas not in the seed can be excluded at resolving steps.

- **The chain is one-directional.** Forward construction builds `chain(n+1)`
  from `chain(n)`. Backward properties like step transfer
  (`(phi U psi) in chain(n+1) -> (phi U psi) in chain(n)`) cannot be built
  into a forward construction.

- **The chain is root-agnostic.** The current `int_chain` knows nothing about
  which formula `root` is being evaluated. Restricted coherence needs
  root-specific formula preservation, but the chain treats all formulas
  uniformly.

### 2. The FMP Path Already Provides Sorry-Free "Closure MCS Completeness"

A strategically critical discovery: the `Decidability/` path is **entirely
sorry-free** (0 sorries across all files) and proves:

```
theorem fmp_completeness (phi : Formula) :
    (forall (S : ClosureMCSBundle phi), phi in S.carrier) ->
    Nonempty (DerivationTree [] phi)
```

This is completeness with respect to closure MCS membership. The gap between
this and full semantic completeness (`valid phi -> ...`) is the gap between
"truth in all closure MCS worlds" and "truth in all semantic models." This gap
is bridged by **soundness + the representation theorem**: if `valid phi`, then
in particular phi is true at every closure MCS world (since each closure MCS
induces a model via the canonical construction), so `fmp_completeness` applies.

**Strategic implication**: If we can show that every closure MCS world embeds
into a semantic model where truth is preserved, we get full completeness via
the FMP path without needing `bx_countermodel` at all.

### 3. Three Viable Alternative Architectures

#### Architecture A: Root-Parameterized Chain (Minimal Change)

**Estimated effort**: 300-500 lines, 10-15 hours

Modify `fwd_succ`/`bwd_pred` to take `root : Formula` and include
`restrictedUntilCarry(M, root)` in both resolving and non-resolving seeds.
The crux is proving consistency of the enriched resolving seed
`{psi} union g_content(M) union restrictedUntilCarry(M, root)`.

Report 08 exhaustively analyzed this and found the temporal K argument does
not extend to untilCarry. The BX7/BX11 linearity route is novel and
unproven. **Risk: 40-60% of hitting another blocker.**

#### Architecture B: FMP-to-Semantic Bridge (Novel, Potentially Simplest)

**Estimated effort**: 200-400 lines, 8-12 hours

Instead of building `bx_countermodel` via BXCanonical, bridge the existing
sorry-free FMP completeness to full semantic completeness:

1. `valid phi` implies phi is true in all models, including any model built
   from closure MCS
2. Show that each `ClosureMCSBundle phi` world corresponds to a state in some
   semantic model where truth = membership
3. Apply `fmp_completeness`

The key lemma needed: a **truth lemma for closure MCS** showing that
membership in a closure MCS corresponds to truth in some semantic model.
This is essentially the truth lemma the FMP path already uses but lifted
to full semantic validity.

**Risk: 20-30%.** The FMP truth preservation (`TruthPreservation.lean`) is
already sorry-free. The gap is showing that the filtered model's truth
evaluation matches the closure MCS membership for the formula being tested.

#### Architecture C: Full Quasimodel Replacement (Textbook, Highest Confidence)

**Estimated effort**: 500-800 lines, 15-25 hours

Replace `int_chain` entirely with a quasimodel-based construction per
Burgess 1984 / Reynolds 1996. The key steps:

1. For each temporal demand (Until/Since/F/P formula in `subformulaClosure(root)`),
   build a finite Hintikka chain that discharges it (partially implemented in
   `Quasimodel/Construction.lean`)
2. Combine via dovetailed unraveling into a Z-indexed chain
3. All coherence holds by construction

The existing infrastructure (`hintikka_step`, `defect_count`,
`hintikka_chain_exists`, `bx_until_eventuality_resolution`) covers about 40%
of the needed work.

**Risk: 15-25%.** This is the textbook approach with known mathematics. The
main risk is Lean formalization difficulty, not mathematical correctness.

### 4. Literature Connections

**Burgess 1984 ("Basic Tense Logic")**: The original completeness proof for
tense logic with Until uses a quasimodel construction with defect discharge.
The current `Quasimodel/Construction.lean` implements the defect count
mechanism but stops short of the full chain assembly.

**Reynolds 1996/2003**: Formalized the quasimodel approach for Until-enriched
temporal logics. Key insight: forward_F is derivable from forward Until via
`F(psi) = (top U psi)` (BX12), so only Until coherence needs direct proof.
This was noted in Report 08 Section 2.2 but dismissed because `(top U psi)`
may not be in `subformulaClosure(root)`.

**Reynolds' enriched closure solution**: Reynolds explicitly addresses this by
defining an **enriched subformula closure** that includes `(top U psi)` whenever
`F(psi)` appears. The codebase already has `EnrichedClosure.lean` which may
serve this purpose. If `(top U psi)` is added to the closure, the BX12
reduction becomes viable within the restricted coherence framework.

**Xu 1988**: Proved completeness for BX axioms over all linear orders. The
proof uses a canonical model with quasimodel witnesses. The key technique:
build the chain so that at each step, ALL Until defects are tracked and
resolved within bounded time. This is the approach Architecture C follows.

**Verbrugge 2007 ("Completeness by Construction")**: Advocates building models
that satisfy coherence conditions by construction rather than proving coherence
after the fact. This is precisely the philosophical shift from the scheduling
chain (build first, prove coherence later) to the quasimodel approach (build
coherence in).

### 5. The `(top U psi)` Closure Gap Is Solvable

Report 08 dismissed the BX12 reduction (`F(psi) -> (top U psi)`) because
`(top U psi)` may not be in `subformulaClosure(root)`. But:

1. `EnrichedClosure.lean` (158 lines) already exists and appears designed to
   extend the closure with derived formulas
2. `deferralClosure(root)` is defined separately from `subformulaClosure(root)`
   and includes F/P targets
3. The restricted temporal coherence uses `deferralClosure(root)` for F/P
   obligations and `subformulaClosure(root)` for Until/Since obligations
4. If we define an **augmented closure** that includes `(top U psi)` for each
   `psi in deferralClosure(root)`, the BX12 reduction works within the
   restricted framework

This is a 30-50 line definition change plus ~50 lines of closure property
proofs. It eliminates forward_F as an independent obligation entirely.

### 6. The Step Transfer Problem Has a Known Solution via Enriched Seeds

The backward Until step transfer
(`(phi U psi) in chain(r+1) and phi in chain(r) -> (phi U psi) in chain(r)`)
is needed for `bx_bfmcs_restricted_buc`. Report 08 shows this is not derivable
from BX axioms at the single-MCS level.

**However**, if the chain construction preserves Until formulas from
`subformulaClosure(root)` in the forward direction (via untilCarry in the
non-resolving seed), then the step transfer becomes trivial:

- `(phi U psi) in chain(r+1)` came from either the seed or Lindenbaum extension
- If from untilCarry: `(phi U psi) was in chain(r)` by definition of untilCarry
- If from Lindenbaum: the formula was consistent with the seed, meaning it
  COULD be in chain(r) but we can't prove it IS

So untilCarry in the non-resolving seed gives step transfer ONLY for formulas
that were already carried. This is sufficient if we can show that relevant
Until formulas are never introduced fresh by Lindenbaum at resolving steps
and then needed backward -- which is guaranteed by the restricted scope
(only formulas in `subformulaClosure(root)` matter).

## Strategic Recommendations

### Primary Recommendation: Architecture B (FMP Bridge)

**Rationale**: This leverages 100% of existing sorry-free infrastructure.
The FMP path already proves a form of completeness. The gap to full semantic
completeness is a representation theorem connecting closure MCS to semantic
models -- which is structurally similar to what `bx_countermodel` does but
without temporal coherence obligations.

**Steps**:
1. Show `valid phi` implies `phi in S.carrier` for all `ClosureMCSBundle phi`
   worlds S (this follows from soundness applied to the closure MCS model)
2. Apply `fmp_completeness`
3. Done -- no temporal coherence needed

**The key question**: Does the FMP path's truth preservation already establish
that closure MCS membership corresponds to truth in a semantic model? If yes,
then `valid phi` instantly gives membership in all closure MCS, and
`fmp_completeness` gives derivability.

### Secondary Recommendation: Architecture C (Quasimodel) with Enriched Closure

If Architecture B doesn't pan out (because the FMP truth preservation doesn't
bridge to full `valid`), fall back to:

1. Define augmented closure including `(top U psi)` for F-targets (30-50 lines)
2. Build quasimodel chain using existing `Quasimodel/` infrastructure (300-500 lines)
3. Prove all coherence by construction
4. Wire into `bx_countermodel`

### Not Recommended: Architecture A (Root-Parameterized Chain)

After 8 rounds of research all pointing to the same seed consistency blocker,
continuing to modify the scheduling chain is the definition of insanity. The
consistency of `{psi} union g_content(M) union untilCarry(M, root)` remains
genuinely open and may be false. Architecture A has a 40-60% failure risk.

## Literature Connections

| Reference | Relevance | Key Technique |
|-----------|-----------|---------------|
| Burgess 1984 | Direct | Quasimodel, defect discharge |
| Reynolds 1996/2003 | Direct | F-to-Until reduction via enriched closure |
| Xu 1988 | Direct | BX axiom completeness over linear orders |
| Verbrugge 2007 | Philosophical | Completeness by construction |
| Blackburn et al. | Background | Filtration, FMP, canonical models |
| Gore 1999 | Background | Tableau-based completeness (decidability path) |

## Confidence Level

**Medium-High** for the strategic analysis and Architecture B recommendation.

- **High confidence** that the scheduling chain approach (Architecture A) will
  continue to fail. 8 rounds of evidence.
- **Medium-high confidence** that Architecture B is viable. The FMP path is
  sorry-free and the gap is narrow, but the exact formulation of the bridge
  lemma needs verification.
- **High confidence** that Architecture C works mathematically. The
  formalization effort is the only risk.
- **Low confidence** in any specific timeline estimate. Each prior round
  underestimated difficulty.

## Long-term Considerations

### 1. Completeness Is Not the End Goal

The roadmap shows completeness as a milestone, not the terminus. The real
value is in the **decidability + proof extraction** pipeline, which is
already sorry-free. Completeness connects the syntactic proof system to the
semantic models, providing mathematical confidence, but the automated theorem
prover works regardless.

### 2. A Restricted Completeness Theorem May Suffice

If full `valid phi -> Nonempty (DerivationTree [] phi)` proves too difficult,
a restricted version scoped to specific frame classes (e.g., `valid_discrete`)
or specific formula shapes may be publishable and useful. The BX axiom system
axiomatizes ALL linear orders, so completeness over Z (integers) is a special
case that may be easier.

### 3. The Sorry Count Matters for Publication

The roadmap notes "1 sorry blocking bx_completeness." For a publication,
having 0 sorries is qualitatively different from having 1. If the
completeness proof is too difficult, it may be worth:

- Publishing the decidability result (sorry-free) as the main contribution
- Stating completeness as a theorem with proof sketch
- Including the formal proof modulo the temporal coherence gap

### 4. Adjacent Roadmap Benefits

Architecture C (quasimodel) would simultaneously provide:

- Reusable infrastructure for completeness of extensions (e.g., CTL*, PDL)
- A template for other temporal logic completeness proofs in Lean
- Demonstration of the Burgess-Xu proof method in a proof assistant

Architecture B (FMP bridge) would provide:

- A cleaner proof architecture (FMP -> completeness is standard in the
  literature)
- Separation of concerns (decidability/FMP separate from completeness)
- A simpler story for the paper

### 5. The Existing 3,473 Lines of BXCanonical Are Not Wasted

Even if we switch architectures, the BXCanonical module provides:

- `Frame.lean` (673 lines, sorry-free): BX point ordering, witness lemmas
- `TruthLemma.lean` (320 lines, sorry-free): Truth = membership for MCS
- `Quasimodel/` (1,816 lines): Hintikka machinery reusable for Architecture C
- All modal coherence proofs in `bx_bfmcs` (sorry-free)

Only the temporal coherence proofs and their chain construction dependencies
would change.
