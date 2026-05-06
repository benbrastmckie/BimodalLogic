# C5 Guard Exposure Fix Handoff

## What Was Done

### Problem
The C5 forward elimination (CE:725) and C5' backward elimination (CE:839) placed new
witness points AFTER (resp. BEFORE) all domain points. This created an adjacent pair
(max_old, y) (resp. (y, min_old)) requiring BurgessR3Maximal(f(max_old), B, C), but B
and C were constructed from f(pc.x) via lemma_2_4. When pc.x != max_old, the
BurgessR3Maximal was unprovable.

### Fix (Burgess 2.10 Induction)
Restructured both C5 and C5' elimination into two cases:

**Case n=0 (pc.x = max/min)**: Keep existing construction. The only new adjacent pair
uses lemma_2_4's output directly. No sorry needed.

**Case n>=1 (pc.x != max/min)**: Insert the witness z BETWEEN pc.x and its immediate
successor x' (resp. predecessor x''). Split the adjacent pair (pc.x, x') using
`lemma_2_6_splitting` or `lemma_2_7`:

- **eta in g**: Use lemma_2_6_splitting(beta=eta.neg). Since eta in g(pc.x, x') and g
  is consistent, eta.neg is NOT in g. The splitting gives D with (eta.neg).neg in D,
  and double negation elimination gives eta in D.

- **eta.neg not in g**: Use lemma_2_6_splitting(beta=eta.neg) directly. Same result.

- **xi not in g** (forward only): Use lemma_2_7 directly. Gives eta in D.

- **xi in g AND eta.neg in g AND eta not in g**: This is the Burgess 2.8 case.
  Requires a separate lemma (lemma_2_8 or Since variant of lemma_2_7). Left as sorry.

### Key Insight
For the immediate successor x' of pc.x: since (pc.x, x') is adjacent, x' would be a
C5 witness if eta in f(x'). Since h_no_wit excludes this, eta not in f(x'). Therefore
eta.neg in f(x') by MCS. This gives the necessary formula relationships for the
splitting.

## Remaining Sorries

### In CounterexampleElimination.lean (2 new sorries, replacing 2 old)

1. **Line 862**: C5 forward, Burgess 2.8 case
   - Conditions: xi in g(pc.x, x'), eta.neg in g(pc.x, x'), eta not in g(pc.x, x')
   - Needs: lemma_2_8 (Burgess 1982 p.372, "slight modification of 2.7")
   - Effort: ~400 lines (adapt lemma_2_7_seed_consistent proof)

2. **Line 1170**: C5' backward, requires Since variant of lemma_2_7
   - Conditions: eta not in g(x'', pc.x), eta.neg in g(x'', pc.x)
   - Needs: lemma_2_7_since (mirror of lemma_2_7 for snce formulas)
   - Effort: ~200 lines (straightforward mirror using Since axioms)

### In ChronicleToCountermodel.lean (2 pre-existing, NOT MODIFIED)

3. **Line 634**: FUC (forward Until coherence)
4. **Line 638**: FSC (forward Since coherence)

## Net Progress
- Old sorries (CE:725, CE:839): ELIMINATED for all cases except Burgess 2.8
- New sorries: 2 (narrower scope than originals)
- All 3 non-2.8 sub-cases are now sorry-free
- Build passes with 2 sorries (same count as before, but different locations)

## Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`

## Next Steps
1. Implement `lemma_2_8` in PointInsertion.lean (Burgess 2.8 consistency proof)
2. Implement `lemma_2_7_since` (Since mirror of lemma_2_7)
3. Apply both to close the 2 remaining sorries
