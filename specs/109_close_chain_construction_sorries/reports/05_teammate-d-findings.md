# Teammate D: Strategic Horizons -- Architecture Alternatives and Roadmap Alignment

**Task**: 109 -- Close chain construction sorries
**Role**: Strategic alternatives, architectural reframing, literature comparison
**Date**: 2026-04-20

## Key Findings

### 1. The Hybrid Architecture IS the Problem

The current codebase maintains two parallel proof architectures:

- **Path 1 (RootScopedChain.lean)**: Direct BFMCS chain construction over `Int`, using iterated Lindenbaum extensions (`fwd_chain_of_sigma`, `bwd_chain`). This is the active completeness path. It has 5 critical sorry sites.

- **Path 2 (Quasimodel/)**: Hintikka-set quasimodel with defect-discharge (`Construction.lean`, `Realization.lean`). This has sorry-free defect-count termination (`hintikka_chain_exists`). It was used to close Until/Since eventuality obligations in Frame.lean (tasks 98, 102). But it has 6 sorry sites of its own (4 in Realization.lean, 2 in Construction.lean), all irreflexive-consequence artifacts.

**The fundamental tension**: Path 1 cannot prove `fwd_chain_forward_F` because Lindenbaum extensions are opaque (`Classical.choice`). Path 2 has sorry-free termination but produces abstract BXPoint chains, not Int-indexed FMCS families. Neither path alone suffices, and the bridge between them does not exist.

The handoff document (04_fwd-chain-analysis.md) confirms this after exhaustive analysis: 9 approaches were tried and all are blocked by the same root cause -- the gap between semantic temporal reasoning and syntactic MCS membership in Lindenbaum-based chains.

### 2. Literature: How Standard References Handle This Step

The standard completeness proofs for tense logic with Until/Since handle F-resolution differently from our current approach:

**Burgess (1984) / Goldblatt (1992)**: Use a semantic canonical model construction where the canonical frame consists of ALL maximally consistent sets, ordered by `g_content` inclusion. F-resolution is handled semantically: if `F(phi) in w`, then `{phi} union g_content(w)` is consistent (by `F(phi) in w`), so a Lindenbaum extension `v` exists with `phi in v` and `g_content(w) subset v`, giving `w < v`. The key insight: they do NOT build an Int-indexed chain and then prove F-resolution on it. Instead, they define the canonical model over the FULL set of MCS points (uncountably many), and F-resolution is immediate from the MCS existence lemma.

**Reynolds (1996)**: Uses quasimodels with defect-discharge (similar to our Path 2) but constructs the final model by a separate step that "unravels" the quasimodel into an omega-chain. The unraveling uses the finite model property to bound the construction.

**GHR (1994, Gabbay/Hodkinson/Reynolds)**: "Temporal Logic: Mathematical Foundations and Computational Aspects" Volume 1. Uses a step-by-step canonical construction where the chain is built by explicit defect targeting -- at each step, a specific defect is chosen for resolution. The termination argument uses the finite subformula closure, not a counting argument on active defects.

**Key insight from literature comparison**: Our current approach conflates two distinct steps:
1. **Existence of witnesses** (any MCS with `phi` and `g_content(w)`): This is EASY and already proved (`bx_forward_witness`, `discharge_single_step`).
2. **Organizing witnesses into an Int-indexed family**: This is where the difficulty lies.

Standard references avoid this problem by either (a) using the full MCS space as the model (Burgess/Goldblatt), or (b) using finite model property + unraveling (Reynolds).

### 3. Lean/Coq/Isabelle Formalizations

I am not aware of completed Lean 4 formalizations of tense logic completeness with Until/Since in Mathlib or public repositories. However:

- **Coq**: van Benthem's modal logic formalization in Coq addresses basic modal completeness but not tense logic with Until.
- **Isabelle/HOL**: Schimpf/Smolka "Adequacy of Modal Logic" and related AFP entries cover basic modal completeness. None cover Until/Since to my knowledge.
- **Lean 4**: The Mathlib `ModelTheory` module covers first-order completeness (Henkin construction) but not modal/temporal logic.

This means we are likely the first formalization of Burgess-Xu tense logic completeness in a proof assistant. There is no reference implementation to follow.

### 4. Architectural Alternatives Analysis

#### Alternative A: Full MCS Canonical Model (Burgess/Goldblatt style)

**Idea**: Instead of building an Int-indexed chain and proving F-resolution on it, define the canonical model over ALL MCS points. The temporal ordering is `bx_le` (g_content inclusion). F-resolution is immediate: `F(phi) in w` implies `{phi} union g_content(w)` is consistent, so an MCS `v` exists with `phi in v` and `w < v`.

**Why this was not done**: The parametric representation theorem requires a `BFMCS D` structure with `D = Int` (or another `AddCommGroup` with `LinearOrder`). The full MCS space is not linearly ordered by `bx_le`, and it does not form an `AddCommGroup`. The representation theorem machinery is deeply wired to Int-indexed families.

**Feasibility**: Would require rewriting the parametric representation theorem to work over an arbitrary partial order (the MCS space). This is a MAJOR architectural change (estimated 40-80 hours) and would effectively rebuild the completeness proof from scratch.

**Verdict**: Not viable as a fix for task 109. Could be a long-term architectural improvement for a v2 completeness proof.

#### Alternative B: Filtration-Based Completeness

**Idea**: Prove completeness via decidability + finite model property. If `phi` is not derivable, the FMP gives a finite countermodel.

**Why this was rejected**: The ROADMAP explicitly states "Decidability-based completeness is explicitly excluded as a path to the representation theorem." The project goal is a structural representation theorem (MCS <-> worlds, truth lemma), not just `valid -> derivable`. An FMP-based proof provides no canonical model construction. This is a scientific/methodological choice, not a technical limitation.

**Verdict**: Explicitly excluded by project goals.

#### Alternative C: Commit to Quasimodel Path End-to-End

**Idea**: Instead of building a Lindenbaum chain and trying to prove F-resolution on it, use the quasimodel infrastructure (`hintikka_chain_exists`) to construct the ENTIRE chain. The quasimodel already has sorry-free defect termination. Build a bridge from Hintikka chains to Int-indexed FMCS families.

**This IS Plan v4's Path D.** The plan proposes:
1. Fix Realization.lean oracle gap (replace `g_content` with `g_content_sigma`)
2. Build run-composition layer
3. Wire Hintikka chains into `dd_bfmcs`

**Assessment**: This is the most mathematically sound approach. The Hintikka chain infrastructure already works (sorry-free `hintikka_chain_exists` for Until, `hintikka_chain_exists_since` for Since). The gap is in the bridge layer. However, this bridge faces a structural problem: the Hintikka chain produces a FINITE sequence of BXPoints, while the BFMCS needs an INFINITE Int-indexed family. The Hintikka chain resolves ONE eventuality at a time; the BFMCS needs ALL eventualities resolved simultaneously.

**Key technical challenge**: Composing multiple Hintikka chains (one per eventuality) into a single coherent Int-indexed family. The chains may disagree on intermediate MCS points.

#### Alternative D: Weaker Completeness First (Fragment without F/P)

**Idea**: Prove completeness for the fragment `{atom, bot, imp, box, G, H}` (no F, P, Until, Since) first. This fragment only needs G/H coherence, which is already proved (`int_chain_forward_G`, `int_chain_backward_H`).

**Assessment**: This fragment completeness IS already essentially proved. The `bx_fmcs` in CanonicalModel.lean provides an Int-indexed FMCS with G/H coherence. The only gap is modal coherence (box). But `F = neg(G(neg _))` and `P = neg(H(neg _))` are definable, so F/P resolution IS needed even for formulas containing only G/H (because the truth lemma for G includes quantification over all future points). The fragment without temporal operators at all (pure S5 modal logic) is trivially complete.

**Verdict**: Not useful as a milestone. The difficult part IS the temporal operators with eventualities.

#### Alternative E: Deterministic Chain + Lindenbaum Hybrid

**Idea**: The deterministic chain (DeterministicFMCS, in Boneyard) has provable backward Until coherence via bot-Until content linking (`bot U alpha in chain(r) iff alpha in chain(r+1)`). Under irreflexive semantics, the deterministic chain is NOT constant (unlike reflexive semantics where `bot U alpha = alpha`). Could we use a hybrid: deterministic chain for Until/Since coherence + Lindenbaum extensions for F/P resolution?

**Assessment**: This is intriguing but unexplored. The deterministic chain gives backward Until coherence for free, which is sorry #4 (the hardest non-keystone sorry). The question is whether the deterministic chain can be combined with Lindenbaum F-resolution. The deterministic chain's successor is uniquely determined by the formula `bot U alpha`, so there is no freedom to choose which defect to resolve. F-resolution would need to emerge from the deterministic structure itself.

**Technical detail**: Under irreflexive semantics, `bot U phi at t` means `exists s > t, phi(s) and forall r in (t,s), False`, i.e., `phi` at the immediate successor. So `F(phi) in w` means `neg G(neg phi) in w`. If `bot U phi in w` then `phi` at successor, giving F-resolution for `phi`. But `F(phi) in w` does NOT imply `bot U phi in w` (that would require `phi -> X(phi)` which is not generally derivable).

**Verdict**: Partially viable for sorry #4 (backward Until). Not a complete solution for F-resolution.

### 5. The Irreflexive Semantics Advantage (Not Yet Exploited)

The ROADMAP notes a critical insight that has not been fully exploited:

> Under irreflexive semantics, `phi -> F(phi)` is NOT derivable because `G(neg phi) -> neg phi` (BX1) is removed. This means resolved defects do NOT re-enter as F-obligations.

The file `RootScopedChain.lean` already has:
- `fwd_chain_defect_one_step` (line 1045): At each step, either `chi in chain(n+1)` (resolved) or `F(chi) in chain(n+1)` (still pending).
- `fwd_chain_F_obligation_monotone` (line 1057): Once `F(chi)` leaves the chain, it NEVER returns. The F-obligation set is non-increasing.
- `fwd_chain_F_set_nonincreasing` (line 1095): The set `{chi | F(chi) in chain(k)}` is non-increasing.

These three lemmas together establish that the F-obligation set stabilizes. The missing piece is: **in the stabilized state, every remaining F-obligation is eventually resolved**.

The gap (documented at line 1127): "In the stabilized phase, every resolved defect w has both w in chain(k+1) AND F(w) in chain(k+1), preventing the F-obligation count from decreasing further."

Wait -- this is the reflexive case intuition. Under irreflexive semantics, resolved `w in chain(k+1)` does NOT imply `F(w) in chain(k+1)` (because `phi -> F(phi)` is NOT derivable). So the stabilization argument should actually WORK:

- At each step with active defects (F(chi) in chain(k), chi not in chain(k)), at least one defect is resolved (chi in chain(k+1)).
- Under irreflexive semantics, resolved chi in chain(k+1) does NOT generate F(chi) in chain(k+1).
- Therefore, the number of active F-obligations STRICTLY DECREASES at each resolution step.
- After finitely many steps, all F-obligations are resolved.

**THIS IS THE KEY STRATEGIC INSIGHT**. The handoff analysis (04_fwd-chain-analysis.md) may have been conducted partially under reflexive-semantics assumptions. The "Lindenbaum opacity" blocker applies to reflexive semantics where `phi -> F(phi)` regenerates defects. Under irreflexive semantics, this regeneration does NOT happen.

**However**: The handoff document DOES acknowledge this (line 117-120 of ROADMAP). The remaining gap is more subtle: when defect w is resolved (w in chain(k+1)), it is true that `F(w)` is not FORCED into chain(k+1). But the Lindenbaum extension could STILL place `F(w)` in chain(k+1) by accident (Classical.choice is unconstrained). The non-derivability of `phi -> F(phi)` means it is not FORCED, but it is not FORBIDDEN either.

So the question becomes: can we prove that the F-obligation count EVENTUALLY decreases, even if individual steps might not decrease it?

The F-set is finite (bounded by sigma_list), non-increasing (`fwd_chain_F_set_nonincreasing`), and at each step where the F-set is non-empty, at least one defect is resolved. The resolved defect MIGHT re-enter (Lindenbaum could add F(w)), but the F-set is non-increasing, so if F(w) re-enters, some other F-obligation must have left. This is a swapping argument, not a strict decrease.

But wait: `fwd_chain_F_obligation_monotone` says once F(chi) LEAVES, it never returns. So if F(w) re-enters chain(k+1), it was already there at chain(k). The F-set is non-increasing means: any chi with F(chi) in chain(k+1) also had F(chi) in chain(k). So no NEW F-obligations appear. At each step, at least one defect is resolved (w in chain(k+1)). The question is: does w remain resolved?

If w in chain(k+1) but F(w) in chain(k+1) (because F(w) was already in chain(k) and persisted), then w is "resolved but still an active defect" because F(w) is present. But w is IN chain(k+1), so the `active_defects_corrected` definition (chi not in M AND F(chi) in M) would NOT count it as active. The corrected definition requires BOTH F(chi) in M AND chi NOT in M.

So with the corrected `active_defects` definition:
- At step k: `active_defects = {chi | F(chi) in chain(k) AND chi not in chain(k)}`
- At step k+1: some w is resolved (w in chain(k+1)), so w leaves active_defects(k+1)
- F(w) might still be in chain(k+1), but w IS in chain(k+1), so w is NOT in active_defects(k+1)
- No new F-obligations appear (F-set non-increasing)
- But some chi with F(chi) in chain(k) and chi in chain(k) (not active at k) might have chi NOT in chain(k+1), making chi active at k+1

This is the "juggling problem" identified in the handoff: resolved defects can re-enter active_defects when they leave the chain at the next step. This is the REAL blocker, and it applies under irreflexive semantics too.

### 6. The Juggling Problem is the Core Obstruction

The juggling problem: resolving defect w (putting w in chain(k+1)) can cause previously resolved defect w' (that was in chain(k)) to leave chain(k+1) (because chain(k+1) is a NEW Lindenbaum extension that might not contain w'). So active_defects can fluctuate.

**But**: `fwd_chain_F_obligation_monotone` gives that F(w') either persists or vanishes. If F(w') vanishes at step k+1, then w' can never be an active defect again (F(w') gone forever). If F(w') persists at step k+1, then w' might be active at step k+1 (if w' left the chain).

The F-set is finite and non-increasing. At each step with active defects, at least one is resolved. Over time, the F-set can only shrink. Once F(chi) leaves, it never returns. So the F-set eventually stabilizes to some fixed set S. For the remaining formulas in S, at each step one is resolved (chi in chain(k+1)), but chi might leave at step k+2. The question is whether ALL formulas in S are eventually resolved.

**Potential resolution via amortized analysis**: Consider the sum `sum_{chi in S} (number of future steps where chi is NOT in chain)`. This is bounded by `|S| * infinity` which is not helpful. But if we track which formulas are IN the chain vs OUT, we might be able to show that the "out time" is bounded.

**Actually, the resolution is simpler**. Once the F-set stabilizes to S, for each chi in S, F(chi) persists at every future step. At each step, `defect_step_choice_early` resolves some w in S (w in chain(k+1)). Now w might leave at step k+2. But w's resolution means w was in chain(k+1). If we could show that w stays in the chain for at least 2 steps (so it's in chain(k+1) AND chain(k+2)), then when w leaves at step k+3, a different defect has been resolved at step k+2, and so on.

This doesn't work either -- the Lindenbaum extension provides no guarantees about what stays.

### 7. Recommended Path

**Primary recommendation: Path D (Quasimodel Run-Composition) with targeted optimizations.**

Rationale:
1. The Hintikka chain infrastructure (`hintikka_chain_exists`) is sorry-free and handles the termination argument correctly at the abstract level.
2. The juggling problem is an artifact of the Lindenbaum-based chain construction. The Hintikka chain avoids it because defect_count is defined on the finite sigma-closure, not on the full MCS.
3. The irreflexive-consequence sorries in Realization.lean (F_of_mem, P_of_mem, g_content in seed) are fixable by replacing `g_content` with `g_content_sigma` per Teammate C's analysis.
4. The run-composition bridge is the minimal new infrastructure needed.

**Secondary recommendation: Investigate the "direct BXPoint witness" approach as a shortcut for sorry #1 (fwd_chain_forward_F).**

The idea: instead of proving F-resolution on the existing chain, REPLACE the chain construction. At each index `n` where `F(phi) in chain(n)`, use `bx_forward_witness` to get a BXPoint v with `phi in v` and `g_content(chain(n)) subset v`. Then define `chain(n+1) = v`. This gives a non-deterministic chain where each step resolves a specific defect. The problem is that this chain doesn't preserve F-obligations for OTHER formulas.

But under irreflexive semantics with the F-set non-increasing property: if we build the chain by resolving defects in a round-robin order, and F-obligations never re-enter once gone, then each defect is eventually resolved. The round-robin ensures every defect gets a turn. The F-set shrinks at each resolution.

Wait -- this is essentially what `preserving_fwd_step` already does. The gap is that the step resolves SOME defect (opaque via BX11 fold), not a SPECIFIC targeted defect.

**The real recommendation**: Build a chain variant where at each step, the TARGETED defect is chosen deterministically (round-robin through sigma_list). Use `discharge_single_step` (already sorry-free) for the targeted defect. The question is F-preservation for non-targeted defects. Under irreflexive semantics, `discharge_single_step` gives `{phi} union g_content(M)` as the seed. F(chi) for chi != phi persists if `G(neg chi)` is NOT in the seed. Since `g_content(M) subset seed`, and F(chi) in M means `G(neg chi) not in M` (MCS), we need `G(neg chi) not in chain(n+1)`. But chain(n+1) extends the seed, so it could add `G(neg chi)` via Lindenbaum. This is the same opacity problem.

**Final recommendation**: Path D (quasimodel composition) is the best available approach, despite its estimated 15-20 hours. The direct chain approaches are blocked by the irreducible Lindenbaum opacity obstruction, which is structural and not fixable by technique improvements. The quasimodel approach sidesteps this by working at the Hintikka level where the termination argument is provable.

### 8. Roadmap Alignment

**How this advances project goals**:
- Task 109 is the SOLE blocker for sorry-free `bx_completeness` (the project's primary scientific contribution)
- Task 95 (axiom audit) is blocked on 109
- Tasks 104, 105 (cleanup) are independent but less important
- The representation theorem goal requires sorry-free completeness

**What completing task 109 does NOT give**:
- Dense completeness (task 68) -- independent, uses Rat not Int
- FMP completeness (task 998) -- independent track
- The 14 irreflexive-consequence sorries across 6 files -- these are NOT on the critical path for `bx_completeness` and can be addressed separately

**Fastest path to sorry-free bx_completeness**:
1. Close sorry #1 (fwd_chain_forward_F) -- the keystone
2. Sorries #2-3 (backward chain F/P) follow by symmetric argument
3. Sorries #4-5 (Until/Since coherence) are the hardest remaining ones after #1
4. Path D provides handles on all 5 simultaneously

### 9. Risk Assessment

| Path | Confidence | Hours | Risk |
|------|-----------|-------|------|
| Path D (Quasimodel composition) | 60% | 15-20 | Realization.lean oracle gap; run-composition complexity |
| Path A' (Corrected active defects) | 35% | 8-12 | Juggling problem not resolved by irreflexive semantics alone |
| Full MCS canonical model (Alt A) | 20% | 40-80 | Complete rewrite of representation theorem |
| Direct chain with targeted discharge | 25% | 10-15 | F-preservation for non-targeted formulas |
| Deterministic chain hybrid (Alt E) | 15% | 15-25 | Unexplored territory; deterministic chain structure unclear under irreflexive semantics |

## Confidence Level

**Medium** (60%) for Path D succeeding. The mathematical foundations are sound (sorry-free Hintikka chain termination), and the irreflexive semantics removes the worst regeneration problems. The main risk is the bridge layer complexity.

**Low** (35%) for Path A' succeeding. The juggling problem is real and not resolved by the semantics switch alone. An amortized or state-space argument might work but no concrete proof sketch exists.

## Summary Recommendations

1. **Pursue Path D (quasimodel run-composition)** as the primary strategy per plan v4
2. **Fix active_defects definition** as a universal prerequisite (needed regardless of path)
3. **Fix Realization.lean sorries** by replacing g_content with g_content_sigma (Phase 1 of plan v4)
4. **Do not attempt** Alternative A (full MCS canonical model) or Alternative B (filtration) -- too expensive or excluded by project goals
5. **Keep Alternative E** (deterministic chain hybrid) in mind as a potential handle for sorry #4 (backward Until coherence) specifically
6. **After closing task 109**: the 14 irreflexive-consequence sorries should be a separate task, as they are not on the critical path
