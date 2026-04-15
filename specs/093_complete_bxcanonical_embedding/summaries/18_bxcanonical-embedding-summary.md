# Implementation Summary: Close BXCanonical Embedding (v18)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: PARTIAL (Phase 1 completed, Phases 2-7 blocked)
- **Session**: sess_1776219044_febe15
- **Plan**: plans/18_bxcanonical-embedding.md

## Completed Work

### Phase 1: ROAD_MAP.md Update [COMPLETED]
- Added 9 dead ends (13-21) to the Dead Ends section, documenting all failed
  approaches from task 93 investigation across plans v5-v17
- Added "Task 93: Progress and Infrastructure" section documenting six
  sorry-free helper lemmas and the core finding about `.choose` in
  `set_lindenbaum`
- Updated active-path sorry inventory from 1 (Completeness.lean:154) to 6
  (all in RootScopedChain.lean), since the Completeness.lean sorry was
  resolved via `dd_countermodel` which depends on the 6 RootScopedChain
  sorries
- Updated task 93 cross-reference to [IMPLEMENTING]

### Infrastructure: rrSchedule_visits lemma
- Added `rrSchedule_visits` theorem to RootScopedChain.lean: for any
  formula in sigma_list and any starting index, there exists a later visit
  step. This is necessary infrastructure for any forward_F proof approach.
- Build passes with zero new sorries introduced.

## Blocking Analysis

### The Core Mathematical Obstruction

The primary blocker `rr_fwd_chain_forward_F` (line 1295) requires proving:
given F(psi) in chain(n), there exists s > n with psi in chain(s).

The existing chain uses `enriched_fwd_step` which provides:
1. **F-preservation** (disjunctive): F(chi) in chain(n) implies chi in
   chain(n+1) OR F(chi) in chain(n+1)
2. **Some formula resolved**: at each visit step, at least one formula with
   F-obligation is directly placed in chain(n+1)

The gap: property (2) does not guarantee that the SPECIFIC formula psi is
ever the one directly resolved. The `.choose` in `set_lindenbaum` (called
via `resolving_enriched_fwd_exists`) is non-deterministic and can
perpetually select MCS extensions where psi is F-protected rather than
directly present.

### Why Chain Replacement Also Fails

The plan proposed replacing `enriched_fwd_step` with
`target_resolving_fwd_step` using `discharge_single_step` to guarantee
target in M'. Analysis reveals this approach has a fatal F-propagation gap:

- `discharge_single_step` gives: target in M' and g_content(M) subset M'
- F(chi) in M does NOT imply F(chi) in M' (the Lindenbaum extension from
  seed {target} union g_content(M) can add G(neg chi), killing F(chi))
- Once F(chi) is killed (G(neg chi) in chain(k+1)), chi can NEVER appear
  in any future chain step (neg chi propagates via g_content)
- Therefore forward_F fails for any formula whose F-obligation is killed

### Why the Combined Approach Also Fails

Attempting to include F(chi) in the seed alongside target:
- Dead end 13 proves {target} union g_content(M) union f_carry(M) is
  inconsistent in general
- Even individual {target, F(chi)} union g_content(M) can be inconsistent
  when BX11 ordering has chi "later" than target (case 3 gives
  F(chi and F(target)) in M, and G(neg(target and chi)) in M forces
  neg(F(chi)) via the conjunction with target in the extension)

### The Fundamental Tension

BX11 temporal linearity creates a partial ordering on F-obligations. At
each step, the "earliest" formula can be deterministically resolved (via
`target_stays_direct_in_fold`), but "later" formulas' F-obligations may be
killed. Resolving any formula can permanently destroy F-obligations for
formulas that are "later" in the BX11 ordering at that step.

Standard completeness proofs (Burgess 1984, Goldblatt 1992, GHR 1994) avoid
this issue entirely by working semantically: they construct canonical models
where F-witnesses are placed at arbitrary future times without concern for
chain step ordering.

## Recommendations

1. **Research a semantic approach**: Rather than proving forward_F at the
   syntactic chain level, investigate whether the parametric representation
   theorem can be reformulated to avoid the chain construction entirely,
   using BXPoint witnesses directly.

2. **Investigate tree-based canonical models**: Instead of a linear chain
   (Int-indexed), use a tree structure where each F-obligation spawns its
   own branch. The BFMCS families provide enough structure for this.

3. **Consider domain change**: Using a denser domain (e.g., Rat instead of
   Int) might allow inserting witness worlds between chain steps.

## Artifacts

| Artifact | Status |
|----------|--------|
| `specs/ROAD_MAP.md` | Updated (dead ends 13-21, sorry inventory, cross-ref) |
| `RootScopedChain.lean` | `rrSchedule_visits` lemma added; 6 sorries unchanged |
| `plans/18_bxcanonical-embedding.md` | Phase 1 COMPLETED, Phases 2-7 BLOCKED |
