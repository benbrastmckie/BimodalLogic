# Phase 1 Handoff: Z1 Infrastructure and Helper Lemmas

## Status: BLOCKED

## What was accomplished

1. **Two sorry-free helper lemmas added** to `ChronicleToCountermodel.lean`:
   - `limit_f_some_future_of_lt`: If psi in limit_f(y) and x < y, then F(psi) in limit_f(x). Uses C4 contradiction.
   - `limit_f_not_G_neg_of_mem`: If psi in limit_f(y) and x < y, then G(psi.neg) not in limit_f(x). Contrapositive of limit_forward_G.

2. **Docstring updated** on `chronicle_gap_contradiction` documenting 6 investigated approaches and their failure modes.

3. **File builds** with only the original sorry remaining at `chronicle_gap_contradiction`.

## What was tried and failed

### Approach 1: Z1 with next_top
- Z1(next_top) is vacuous because next_top is in every MCS
- G(next_top) already known via discrete_propagate_fwd

### Approach 2: Z1 with distinguishing formula (Case A)
- Pick psi in limit_f(b) minus limit_f(a)
- Problem: G(G(psi)->psi) in limit_f(a) requires G(psi)->psi at all future points
- G(psi)->psi fails at points where psi is false but G(psi) is true (accumulation boundary)
- Cannot verify the Z1 hypothesis without already knowing the orbit structure

### Approach 3: Pred/succ cancellation descent  
- succ^n(a) < b implies succ^n(a) <= pred(b) implies succ^n(a) < pred(b)
- Same problem with pred(b) as upper bound -- circular

### Approach 4: Dom(N) stage counting
- At stage N with K+1 points in [a,b], monotonicity gives succ^K(a) <= b
- But NOT succ^K(a) >= b -- orbit may advance slower due to intermediate insertions

### Approach 5: Model surgery / contemp_equiv
- Confirmed by research: contemp_equiv trivially true for bounded intervals at any EF depth k
- gap_contradicts_prior inapplicable

### Approach 6: Boneyard expressive completeness
- US_expressively_complete_over_prior could express orbit membership as temporal formula
- But requires semantic Prior-UZ/SZ for orbit-cut structure
- Circular: the proof needs the orbit structure we're trying to establish

## Root cause

The fundamental gap is that orbit membership (succ-reachability from a) is a second-order property not expressible in the first-order temporal language. The standard model-theoretic proof of Z1 implies IsSuccArchimedean uses a CHOSEN valuation encoding orbit membership, but in the MCS/chronicle setting, the valuation is fixed by limit_f.

## Immediate next action

Three possible paths forward:
1. Novel chronicle-specific argument: Show that semantic Prior-UZ/SZ holds for the orbit-cut structure directly from the omega-chain construction
2. Strategy B completion: Prove ReynoldsBridge.lean:489 sorry (Z-interval to TaskModel conversion), bypassing chronicle_gap_contradiction entirely
3. Fundamentally new technique: Perhaps using the Kamp/Stavi theorem differently, or a computational argument about the counterexample enumeration

## Files modified
- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean (helper lemmas + docstring)
- specs/273_chronicle_gap_contradiction_proof/plans/01_gap-contradiction-plan.md (Phase 1 marked BLOCKED)
