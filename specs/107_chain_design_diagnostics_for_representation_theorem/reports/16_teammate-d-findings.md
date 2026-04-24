# Teammate D (Horizons): Strategic Synthesis and Recommendation

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-24
**Role**: Synthesize all prior research and recommend the single best path forward

## The Honest Assessment

### What We Have Spent

- **6+ research rounds** on task 107 (reports 01-15), plus 1 round on task 112
- **~2,863 lines** of chronicle code across 6 files
- **14 sorry sites** in the chronicle (up from the original 11, after Phase 1 added 3 infrastructure placeholders)
- **3 sorry sites** remaining in RootScopedChain.lean (the Int-chain pathway)
- **14 sorry sites** in the irreflexive-consequence category (Frame, TruthLemma, Construction, Realization, SigmaOrdering)
- **36 documented dead ends** in the ROADMAP
- **Multiple false lemma discoveries**: 4/4 PointInsertion lemmas, extended_limit_f making forward_G provably FALSE
- **Plan v5 estimates 55 hours remaining** -- but plan v5 was written BEFORE the Phase 1 implementation revealed that extended_limit_f is provably false

### What We Have Learned

The research has been productive in one crucial sense: it has systematically eliminated approaches and converged on a clear diagnosis. The three-layer problem (trivial g-function, guard convention mismatch, density/domain) is well-understood. The task 112 literature study added a fourth insight: the g-function may be theoretically misplaced (it belongs to period semantics, not the basic chronicle).

## Evaluating the Four Options

### Option A: Continue with Chronicle (Plan v5)

**Estimated remaining cost**: 55+ hours (plan v5 estimate, likely an undercount given the extended_limit_f falsity discovery)

**What is actually broken**:
1. The g-function is trivial and never updated -- Layer 1 is unresolved
2. extended_limit_f makes forward_G provably FALSE -- discovered during Phase 1
3. Guard convention mismatch -- Layer 2 is unresolved
4. C4 sub-case 1a may be false -- unknown
5. The g-function's theoretical origin is unclear (task 112: period semantics vs. instant semantics)

**Honest risk assessment**: Plan v5 Phase 1 was attempted. It produced 3 new sorry sites rather than closing any. The implementation summary explicitly states: "The entire ChronicleToCountermodel approach (Path B) as currently structured cannot work." This is not a recoverable setback -- it is a structural falsity in the approach.

**Verdict**: The chronicle in its current form is a dead end for Path B. Path A (direct truth lemma over sparse X) was always contingent on Path B infrastructure (plan v5 explicitly says "Phase 5 depends on Phase 4"). With Path B provably broken, Path A as designed is also blocked.

### Option B: Pivot to a Different Approach Entirely

**What the literature says**: Task 112 identified Venema 1993's model-replacement technique via Doets' theorem as the strongest alternative. Build any linear model, then replace it with a model of the correct type. Burgess 1984 confirms the chronicle is for pure tense logic; bimodal interaction requires additional conditions.

**What this would mean**: Abandon the 2,863 lines of chronicle code. Design a new proof strategy from scratch. Possible approaches:
- Venema-style: build definably-well-ordered model, replace via Doets' theorem
- Semantic completeness: build the canonical model with semantic witnesses (Goldblatt/GHR style) rather than syntactic Lindenbaum chains
- Deterministic chain hybrid (ROADMAP recommendation #1)

**Risk**: Starting over means another 3-6 research rounds to validate the new approach, plus 40-80 hours of implementation. There is no guarantee a new approach avoids the same Lindenbaum opacity obstruction that has killed every syntactic chain approach.

**Verdict**: Too expensive and too uncertain without a concrete alternative already validated.

### Option C: Modular Approach -- Separate Temporal and Modal

**What works now**: The Int chain (CanonicalModel.lean) is sorry-free. It provides FMCS over Z with forward_G, backward_H, and Box stability. The parametric truth lemma and representation theorem are sorry-free. The quasimodel infrastructure (2,228 lines) handles Until/Since eventuality resolution and is sorry-free.

**What is missing**: The bridge between these two sorry-free components. The Int chain has no Until/Since coherence. The quasimodel produces BXPoint chains that are not Int-indexed. RootScopedChain.lean sits exactly at this gap -- its 3 sorry sites (restricted_tc, restricted_buc, restricted_fuc) are precisely the missing bridge.

**The insight**: This is not really "separating temporal and modal." The modal part (Box) is already handled. The temporal G/H is already handled. The ONLY unsolved problem is Until/Since coherence on the Int chain. Everything else -- the chronicle, the domain type debates, the g-function -- has been an attempt to solve this one problem by building a different chain. But the Int chain is the one that actually works for G/H/Box.

**Verdict**: This is the correct framing of the problem, but it is not a solution by itself. It clarifies what needs to happen.

### Option D: Accept Partial Result (G/H/Box Completeness Only)

**What this gives**: Completeness for the modal-temporal fragment WITHOUT Until/Since. This is a genuine mathematical result. The axioms for G, H, Box (layers 1-2 of BX plus the interaction axioms) are complete with respect to S5 over linear orders. This result already exists sorry-free in the codebase, modulo the irreflexive-consequence sorries.

**What it costs**: Accepting that Until/Since completeness is a separate, harder problem. The 14 irreflexive-consequence sorries (bx_le_refl, sigma_le_refl, etc.) would need to be cleaned up -- either by removing them (they are intentionally invalid under irreflexive semantics) or by restructuring the module to not depend on them.

**What it does NOT give**: The full BX completeness theorem. The representation theorem. The scientific contribution described in the ROADMAP ("what TM *is*").

**Verdict**: Tempting as a milestone, but the irreflexive-consequence sorries are entangled with the Until/Since infrastructure (Construction.lean, Realization.lean). Shipping G/H/Box-only requires either (a) a separate completeness theorem that does not flow through the Until/Since-infected modules, or (b) cleaning up all 14 irreflexive-consequence sorries, which is itself non-trivial.

## My Recommendation: Option C+D Hybrid -- Ship What Works, Then Focus the Remaining Problem

### The Strategy

**Phase 1: Formalize what is already proved (1-2 weeks)**

The codebase has two sorry-free subsystems that have never been connected:
1. The Int chain (CanonicalModel.lean) with sorry-free G/H/Box
2. The quasimodel (2,228 lines) with sorry-free Until/Since eventuality resolution

The 14 irreflexive-consequence sorries are mostly in modules that bridge these two subsystems (or are intentionally invalid like bx_le_refl). Rather than fixing them, **create a clean G/H/Box completeness theorem** that routes through CanonicalModel + ParametricRepresentation WITHOUT touching the Until/Since modules:

- State `bx_GHBox_completeness` for the fragment `{atom, bot, imp, box, all_future, all_past}`
- This avoids RootScopedChain.lean entirely (no Until/Since coherence needed)
- The parametric truth lemma already handles G/H/Box cases sorry-free
- restricted_tc for G/H only requires forward_G and backward_H (already sorry-free on the Int chain)
- The Until/Since coherence requirements (restricted_buc, restricted_fuc) become vacuous when the formula contains no Until/Since

This is a genuine publishable result: **completeness of S5 + irreflexive linear temporal logic (G/H operators) over ordered abelian groups**.

**Phase 2: Focus the Until/Since problem precisely (2-4 weeks)**

With G/H/Box shipped, the remaining problem is precisely: given an MCS containing phi U psi, construct an Int-indexed chain where the Until obligation is eventually discharged.

The quasimodel already solves this for abstract BXPoint chains. The gap is embedding quasimodel witnesses into the Int chain. This is a cleaner problem statement than "fix the chronicle" because:
- The domain type is fixed (Int, with AddCommGroup)
- Forward_G and backward_H are already proved
- The only question is: can we insert Until/Since witnesses into the Int chain family?

Two sub-approaches:
- **Direct embedding**: Show that the quasimodel's BXPoint witnesses can be assigned Int indices compatible with the existing FMCS family. This requires showing the witnesses are box-equivalent to the root (they should be, by the quasimodel construction).
- **Model replacement** (Venema 1993): Build the Int chain model (which satisfies G/H/Box but not Until/Since), then argue by Doets' theorem or a direct transfer that an equivalent model with Until/Since witnesses exists.

**Phase 3: Chronicle as optional optimization (deferred)**

If the direct approach in Phase 2 succeeds, the chronicle code becomes unnecessary for completeness. It could be retained as an alternative proof or archived to Boneyard. If Phase 2 fails, the chronicle's problems are at least better understood and the 55+ hours estimated in plan v5 can be re-evaluated.

### Why This Is Better Than the Alternatives

1. **It produces a result within 1-2 weeks** (G/H/Box completeness), not 55+ hours from now
2. **It does not throw away existing sorry-free code** -- it routes around the broken parts
3. **It reframes the remaining problem** from "fix the chronicle" (a known quagmire) to "bridge two sorry-free subsystems" (a cleaner engineering problem)
4. **It is honest about the sunk cost**: 2,863 lines of chronicle code with 14 sorry sites and a provably false extended_limit_f is not an asset -- it is a liability that generates more research rounds
5. **It aligns with the ROADMAP**: the critical path is task 109 (close BXCanonical sorries), not task 107 (the chronicle). G/H/Box completeness directly advances task 109 by resolving the non-Until/Since subset of those sorries

### Concrete Next Steps

1. **Verify** that restricted_tc with no Until/Since in the root formula reduces to just forward_G + backward_H on the Int chain (should be straightforward -- read the definition)
2. **State** `bx_GHBox_completeness` as a theorem about the G/H/Box fragment
3. **Prove** it by routing through CanonicalModel + ParametricRepresentation, skipping RootScopedChain
4. **Audit** with `#print axioms` to confirm no sorryAx
5. **Then** focus on Until/Since as a clean, well-scoped problem

### Risks of This Recommendation

- The G/H/Box fragment completeness theorem may require proving that Until/Since-free formulas make the restricted coherence conditions vacuous. If the coherence conditions are entangled (e.g., restricted_tc requires Until/Since witnesses even for G/H-only formulas), this approach needs adjustment.
- Shipping a fragment result before the full result may reduce motivation for the harder Until/Since problem.
- The "bridge two sorry-free subsystems" framing may turn out to be just as hard as the chronicle approach once the details are examined.

### The Bottom Line

The chronicle has consumed 6+ research rounds and produced 14 sorry sites, 3 new sorry sites from the most recent implementation attempt, and a provably false extended_limit_f. Continuing to invest in it without first shipping what already works is the definition of sunk cost fallacy.

Ship the G/H/Box result. Then attack Until/Since with fresh eyes and a clean problem statement.
