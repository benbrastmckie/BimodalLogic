# Handoff: existPart_succ_n1_bypass_k0 Decomposition

## What Was Done

Decomposed the monolithic sorry at `existPart_succ_n1_bypass_k0` (KampBypass.lean) into three
zone-specific helper theorems based on the x-t order booleans in sub_nf:

1. **Both orders (true, true)**: PROVED. Existential is impossible since t < x and x < t
   are contradictory.

2. **existPart_succ_n1_bypass_k0_eq** (line 644, sorry at line 670):
   Equality case (x = t). Deferred. The existential reduces to nf_eval_nf M 1 2 [t,t] sub_nf.
   Approach: check predicate compatibility, then build formula from char_1(nf_x) + depth-0
   3-var quantifier conditions (via zone decomposition projecting 3-var to 2-var).

3. **existPart_succ_n1_bypass_k0_until** (line 787, sorry at line 856):
   Until case (t < x). THE KEY PROOF. Formula witness is `enriched_bypass_until`, which
   constructs a VVecEA2 and returns its translateLeft. The biconditional needs:
   - Forward: VVecEA2.holdsLeft -> exists x > t with nf_eval
   - Backward: exists x > t with nf_eval -> VVecEA2.holdsLeft
   Both directions are sorry'd.

4. **existPart_succ_n1_bypass_k0_since** (line 861, sorry at line 884):
   Since case (x < t). Mirror of the Until case. Deferred.

## Current State

- File: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`
- Builds cleanly (no errors, 4 sorry warnings in KampBypass.lean)
- The main theorem `existPart_succ_n1_bypass_k0` (line 865) is now sorry-free
  (it delegates to the three helper theorems)
- Pre-existing sorry at `existPart_succ_n1_bypass` k > 0 case (line 972)

## Key Decisions

1. Chose to decompose by x-t order booleans (matching enriched_bypass_formula_zone structure)
2. Until case witnesses with `enriched_bypass_until` (not a new formula construction)
3. Equality case needs 3-var to 2-var projection for quantifier conditions

## Sorry Inventory

| File | Line | Statement | Why Deferred | Next Dispatch |
|------|------|-----------|--------------|---------------|
| KampBypass.lean | 670 | existPart_succ_n1_bypass_k0_eq | Complex 3-var -> 2-var projection + char_1 + NF uniqueness | Build formula from char_1 + classically chosen ssn formulas |
| KampBypass.lean | 856 | existPart_succ_n1_bypass_k0_until (biconditional) | VecEA2.holdsLeft <-> nf_eval semantic equivalence is 200+ lines | Prove backward direction first (easier), then forward |
| KampBypass.lean | 884 | existPart_succ_n1_bypass_k0_since | Mirror of Until case | After Until case is done, mirror the proof |
| KampBypass.lean | 972 | existPart_succ_n1_bypass k > 0 | General depth, requires depth-k IH for 3-var conditions | Separate task |

## Immediate Next Action

Focus on `existPart_succ_n1_bypass_k0_until` (line 856). The proof needs:

1. Unfold `enriched_bypass_until` to get the VVecEA2 structure
2. Apply `VVecEA2.translateLeft_correct` to get holdsLeft <-> temporal_truth
3. Prove `holdsLeft <-> exists x > t, nf_eval_nf M 1 2 [x,t] sub_nf`

For step 3 backward direction:
- Given x > t with nf_eval, get nf_x = nf_characteristic M 1 1 [x]
- Use nf_x_compat_of_nf_eval to show nf_x is in the disjunction
- endpointLeft: use t_compat_holds + pre_conditions_at_t construction
- endpointRight: use char_1_correct + zone condition matching
- bracket: for each positive between_tx ssn, the 3-var existential gives a witness y in (t,x)

For step 3 forward direction:
- Given holdsLeft, extract x from the existential
- endpointRight gives char_1(nf_x) -> nf_eval_nf M 1 1 [x] nf_x
- bracket witnesses give depth-0 3-var existentials for positive between_tx ssns
- pre-conditions give depth-0 3-var existentials for y<t and y=t ssns
- Combine to reconstruct nf_eval_nf M 1 2 [x,t] sub_nf
