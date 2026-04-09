# Teammate D Findings: Strategic Horizons and ROADMAP.md Update

**Task**: 86 — Close BXCanonical completeness sorries
**Date**: 2026-04-09
**Role**: Teammate D (Horizons)
**Assignment**: Strategic assessment of completeness proof direction and ROADMAP.md update proposals

---

## Key Findings

### 1. The Codebase Has Three Parallel Completeness Architectures — All Active

The sorry count (137 in Metalogic/, but only ~20 on critical path) is spread across:

| Architecture | Files | Active Sorries | Status |
|---|---|---|---|
| Bundle/BFMCS (Lindenbaum chain) | SuccChainFMCS.lean, TemporalCoherence.lean, Bundle/ | ~7 critical | ACTIVE (primary path) |
| Algebraic/UltrafilterChain | UltrafilterChain.lean, DovetailedChain.lean | ~5 critical | ACTIVE (secondary path) |
| BXCanonical | Frame.lean, CanonicalEmbedding.lean, Completeness.lean | ~6 critical | PARTIAL (USF fragment only) |
| FMP/Decidability | TruthPreservation.lean | 0 | SORRY-FREE (weak completeness) |

**The project is NOT spreading too thin** — BXCanonical is a fundamentally different completeness claim (USF fragment only), while Bundle and Algebraic are two implementations of the same claim. The FMP path is independently valuable.

### 2. The Real Sorry Picture After Tasks 83, 84, 86

The ROADMAP.md is outdated — it was written during task 83 planning and does not reflect the current state after extensive task 84 restructuring. Current actual state:

**Root Cause 1 (dominant)**: Until/Since forward coherence — G-lift incompatibility
- `G(φ U ψ) ∉ M` in general; Lindenbaum construction cannot preserve Until obligations
- Manifests as ~12 sorry sites across Bundle + Algebraic paths
- All standard approaches (dovetailing, fuel, restricted deferral, bidirectional witness) have been exhaustively investigated (tasks 83: 39 rounds, task 84: 4 rounds with definitive consensus)

**Root Cause 2**: BXCanonical Until/Since forward/backward witnesses (4 sorries in Frame.lean)
- Same underlying issue: Until formulas are not G-liftable; BXPoint ordering is not linear
- BXCanonical Port was evaluated at task 83 round 39 as **mathematically impossible** (95% confidence, 3-teammate consensus)
- BUT: USF fragment completeness (the BXCanonical specific goal) IS achievable via a different approach (chain history construction, not Frame.lean witness proofs)

**Root Cause 3**: Dense canonical model (1 sorry)
- Completely independent; needs Rat canonical model; no infrastructure

**Root Cause 4**: SuccChain infrastructure cleanup (3 sorries in SuccChainFMCS.lean)
- Partially redundant with dovetailed path; non-critical

**Root Cause 5**: BX temp_4 derivation (4 sorries across Algebraic + Bundle)
- Should be derivable from BX1 via standard tense logic; low-effort fix not yet attempted

### 3. The BXCanonical USF Fragment Path Is the Lowest-Hanging Fruit

The current implementation strategy (task 86 reports 01-04) targets `usf_completeness` in `CanonicalEmbedding.lean:409` — the imp Case B sorry. The research (reports 03, 04) reaches high consensus:

- The sorry IS closeable (95% confidence)
- The current proof structure (validity reduction) is wrong for the imp case
- Standard approach: bidirectional truth lemma with non-constant chain histories
- Fragment completeness (formulas without Until/Since) is achievable NOW because G/H witnesses exist via `bx_G_backward` / `bx_H_backward` (sorry-free in Frame.lean)
- This gives a **real, publishable completeness result** for a meaningful fragment

This has NOT been recognized clearly in ROADMAP.md — it should be elevated.

### 4. The FMP Path Is Sorry-Free and Fully Independent

`Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean` has **zero actual sorry tactics** (confirmed by grep). This means the FMP decidability track is clean. Task 82 (close 2 FMP TruthPreservation sorries) was scoped under old reflexive semantics — under strict semantics the theorem statements may need revision, but the infrastructure exists.

The ROADMAP.md correctly classifies FMP as "decidability track only" and excludes it from the representation theorem. This is the right call. However, FMP's sorry-free status deserves more prominent acknowledgment as it represents a publishable weak completeness result today.

### 5. Are We Spreading Too Thin?

The concern is valid but the answer is nuanced:

**NOT spreading thin** on the representation theorem: Bundle and Algebraic are parallel implementations of the same Henkin construction. They share the same fundamental blocker (G-lift incompatibility for Until/Since coherence). Closing one would make the other redundant — this is fine.

**IS spreading thin** in a different sense: BXCanonical, Bundle, and Algebraic each have different proof obligations and different sorry counts, and the team keeps switching between them (tasks 83, 84, 86 all touched different files). The right response is to **declare the scope of each architecture** explicitly in ROADMAP.md and fix BX temp_4 derivations across all files (low effort, removes 4 sorries).

### 6. "Declare Victory With What We Have" Strategy

The project can declare PARTIAL victory RIGHT NOW:

1. **FMP decidability**: Zero sorries. TM is decidable. This is publishable.
2. **Soundness**: Zero sorries. Full soundness across all frame classes.
3. **Modal completeness**: Sorry-free. Box/diamond direction is complete.
4. **USF fragment completeness** (BXCanonical): Within reach (task 86 current focus, 1 remaining sorry). Would give completeness for the temporal-operator-free fragment.
5. **Full representation theorem**: Blocked on Until/Since forward coherence. Requires a novel enriched-chain construction (estimated 600-1000 LOC, 70-85% confidence per task 83 report 39).

### 7. Ruled-Out Approaches Not Documented in ROADMAP.md

The ROADMAP.md documents dead ends in the "Dead Ends (Archived)" section but is missing several important ruled-out paths that were definitively established in tasks 83-84:

1. **BXCanonical Port** (port chain construction into BXCanonical): Mathematically impossible because BXPoint ordering is not linear and Until formulas are not G-liftable. BXPoint universal quantifiers cannot be satisfied by chain members alone.

2. **BX axiom 4 (Burgess-Xu)**: Semantically invalid. Cannot be added to BX axiom set.

3. **Forward Until coherence via fuel/bounded depth**: Conflates F-nesting depth (bounded) with persistence count (unbounded). All fuel-based approaches fail for this reason.

4. **Simultaneous well-founded induction for forward_F**: The `forward_F`/`backward_G` circularity cannot be broken by mutual induction because formula size grows through G-wrapping.

5. **DRM-based (restricted MCS) chains**: All 6 Boneyard chain files used DRM chains; they fail because x_content collapses in DRM chains. Only full-MCS enriched chains avoid this.

---

## ROADMAP.md Proposed Updates

### Section 1: Add "Fragment Completeness" as Priority Track

After the "Overview" table, add a new subsection under "The Completeness Gap (Priority 1)":

```markdown
### Fragment Completeness: Available NOW

**USF Fragment (BXCanonical)**: Completeness for `untilSinceFree` formulas is within reach via task 86.
The BXCanonical path proves: if `phi` is valid and `untilSinceFree phi`, then `phi` is derivable.
This covers all formulas using only `atom, bot, imp, box, G, H` — a substantial fragment including
all S5 modal logic and pure tense logic without Until/Since.

**Status**: One sorry remains (`usf_completeness` imp Case B). The fix requires restructuring
`CanonicalEmbedding.lean` to use a chain history approach with non-constant histories.
See task 86 reports 03-04 for detailed proof architecture.

**Publication value**: Fragment completeness is a publishable result. It establishes that BX
axiomatizes the valid USF formulas, independent of the Until/Since coherence blocker.
```

### Section 2: Update "Recommended Priority Order"

Replace:
```
1. **Task 83** (in progress): Representation theorem via canonical completeness
```

With:
```
1. **Task 86** (in progress): USF fragment completeness via BXCanonical chain history approach
   - Close `usf_completeness` imp Case B: restructure from validity-reduction to canonical model approach
   - Requires chain history builder (non-constant histories for G/H witnesses)
   - Estimated: 200-400 LOC in CanonicalEmbedding.lean or new ChainTruthLemma.lean

2. **Fix BX temp_4 derivations** (4 sites): Derive temp_4 from BX1 in SuccChainFMCS.lean,
   UltrafilterChain.lean, DovetailedChain.lean, CanonicalFrame.lean. Low effort, independent.

3. **Task 82**: FMP TruthPreservation — needs review under strict semantics (may need restatement)

4. **Enriched chain construction** (representation theorem final push):
   - Create `EnrichedChain.lean` in Bundle/ with dovetailed scheduling over subformula closure
   - Resolves `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P`
   - 600-1000 LOC; 70-85% confidence (task 83 round 39 assessment)
   - This is the ONLY viable path to full Until/Since forward coherence

5. **Task 58**: Wire completeness to FrameConditions (unblocked once enriched chain done)

6. **Task 68**: Dense completeness via Rat canonical model (independent)

7. **Task 60**: Remove `discrete_Icc_finite_axiom` (independent)
```

### Section 3: Expand "Dead Ends (Archived)" Section

Add to the existing "Dead Ends" list:

```markdown
6. **BXCanonical Port** (task 83, round 39): Proved mathematically impossible. BXPoint ordering
   is not linear; two BXPoints above w can be incomparable under bx_le. Until formulas are not
   G-liftable (semantically invalid: G(φ U ψ) does not follow from φ U ψ). Chain members
   cannot satisfy universal quantification over all BXPoints.

7. **BX axiom 4 (Burgess-Xu addition)** (task 83, report 37): Semantically invalid in BX frames.
   No variant strong enough to establish interval linearity exists.

8. **Simultaneous mutual induction for forward_F/backward_G**: The circularity cannot be broken
   because G-wrapping increases formula size without bound, preventing well-founded induction.

9. **DRM-based (restricted MCS) chains** (all 6 Boneyard chain files): x_content collapses
   in DRM chains. Full-MCS enriched chains (not yet attempted) avoid this failure mode.

10. **Forward Until coherence via fuel** (tasks 48, 67, 81 plan v13, various): Confirmed failure.
    Fuel conflates F-nesting depth (bounded by deferralClosure) with persistence count (unbounded
    even for finite formula sets). The sorry at `succ_chain_restricted_forward_F` persists for
    this reason — see tasks 83-84 for exhaustive analysis.
```

### Section 4: Add "Current Completeness Landscape" Summary Block

Near the top of ROADMAP.md, after the table, add:

```markdown
## Current Completeness Landscape (as of 2026-04-09)

| Result | Status | Path |
|--------|--------|------|
| Soundness (all frame classes) | SORRY-FREE | Soundness.lean |
| Modal completeness (Box/diamond) | SORRY-FREE | Bundle/CanonicalConstruction.lean |
| FMP / Decidability | SORRY-FREE | Decidability/FMP/ |
| USF Fragment Completeness | 1 sorry remaining | BXCanonical/CanonicalEmbedding.lean |
| Full Representation Theorem | Blocked (Until/Since coherence) | Bundle/SuccChainFMCS.lean |
| Dense Completeness | 1 sorry (Rat model needed) | FrameConditions/Completeness.lean |

**Bottom line**: TM has sorry-free decidability and modal completeness. USF fragment completeness
is one restructuring task away. Full representation theorem requires the enriched chain construction.
```

---

## Recommended Strategic Direction

**Short term (task 86)**: Finish USF fragment completeness. This is within reach, the math is sound, and it delivers a publishable result. Do NOT get distracted by Frame.lean Until/Since sorries — they are unfillable and irrelevant to the main `usf_completeness` goal (which only covers USF formulas, so Until/Since cases never arise in the truth lemma).

**Medium term**: Fix BX temp_4 derivations (4 sites, low effort). Then evaluate enriched chain construction viability with a small proof-of-concept.

**Long term**: The enriched chain construction (700-1000 LOC) is the only viable path to full representation theorem. It should NOT be started until the USF fragment completeness is closed — partial results matter and prevent the project from appearing to have made no progress.

**Strategic pivot recommendation**: The project should formally adopt a "fragment-first" publication strategy. Rather than waiting for full completeness (which may require months more work), document:
1. Sorry-free decidability (FMP path) — ready NOW
2. USF fragment completeness (BXCanonical path) — ready after task 86
3. Full representation theorem — in progress, enriched chain construction

This gives the project a clean story: TM is known to be decidable and sound; completeness is established for the temporal-operator-free fragment; full completeness for the Until/Since fragment is an active research direction.

**Do NOT pivot to FMP for the representation theorem**. ROADMAP.md's exclusion of decidability-based completeness from the representation theorem goal is correct. The scientific contribution is the structural correspondence (MCS ↔ worlds, truth lemma), not just the bare validity fact.

---

## Confidence Level

**High** for:
- Sorry inventory accuracy (confirmed by grep, cross-checked with task 83/84/86 reports)
- Strategic assessment of BXCanonical USF fragment path (convergent across 4 research rounds)
- "Fragment-first" publication strategy being viable
- BXCanonical Port being ruled out (95% consensus, task 83 round 39)

**Medium** for:
- Enriched chain construction feasibility (70-85% per task 83 round 39 — backward direction has medium risk)
- ROADMAP.md change impact (some items in the priority list may shift based on teammate findings)

**Low** for:
- Exact LOC and timeline estimates (the project has a history of estimates being wrong)
- Whether the enriched chain backward direction derivation holds in Lean (needs formal verification before committing to implementation)
