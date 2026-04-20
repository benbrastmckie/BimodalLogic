# Implementation Summary: Task #93 (v49) - BXCanonical Sorry Closure

## Outcome: PARTIAL

Only Phase 2 (dead code removal) was completed. Phases 1, 3, and 4 are blocked by fundamental mathematical issues discovered during implementation.

## Phase Results

### Phase 1: Fix Guard Convention and Soundness [BLOCKED]

**Blocker**: The plan proposed changing the Until/Since guard from open `(t, s)` to half-open `[t, s)` to make BX9 (until_elim) sound. However, implementation revealed that the half-open guard makes BX2 (left_mono_until: `G(phi -> chi) -> (phi U psi -> chi U psi)`) INVALID because `G(phi -> chi)` only covers strictly future times (r > t), while the half-open guard requires the implication at t itself (r = t). Similarly, BX3, BX5, and other axioms break.

The fundamental tension: the open guard `(t, s)` makes BX2-BX7 valid but BX9 invalid; the half-open guard `[t, s)` makes BX9 valid but BX2 invalid. Resolving this requires reformulating the axiom system (e.g., changing BX2 to use pointwise implication instead of G-guarded implication), which is outside the scope of this plan.

The serial_future/serial_past sorries in Soundness.lean also cannot be closed because `valid` quantifies over ALL ordered additive groups, and general ordered groups need not have NoMaxOrder. A frame-class constraint is needed.

### Phase 2: Remove phi_imp_F_phi Infrastructure [COMPLETED]

Successfully removed all dead code related to `phi -> F(phi)` and `phi -> P(phi)`:

**Deleted definitions** (all sorry'd or depending on sorry'd code):
- `phi_imp_F_phi_early` (private, unused)
- `phi_in_mcs_imp_F_phi_early` (private, unused)
- `phi_imp_F_phi` (sorry'd, not derivable under irreflexive semantics)
- `phi_in_mcs_imp_F_phi` (unused by chain construction)
- `phi_imp_P_phi` (sorry'd, not derivable under irreflexive semantics)
- `phi_in_mcs_imp_P_phi` (unused by chain construction)
- `and_self_intro`, `phi_imp_phi_and_F_phi`, `F_and_self_F`, `F_and_self_F_mcs`
- `self_resolving_fwd_step` and all 5 property theorems
- `P_mono`, `phi_imp_phi_and_P_phi`, `P_and_self_P`, `P_and_self_P_mcs`
- `defect_fwd_step_choice`, `defect_fwd_step_choice_spec`

**Net effect**: Removed 2 sorry sites (phi_imp_F_phi, phi_imp_P_phi) and ~140 lines of dead code. Confirmed via `lake build` that no downstream breakage occurred.

### Phase 3: Close fwd_chain_forward_F and restricted_tc [BLOCKED]

**Blocker**: `fwd_chain_forward_F` requires proving that every formula with an F-obligation eventually gets resolved in the chain. The current `preserving_fwd_step` uses `defect_step_choice_early` which guarantees SOME defect is resolved at each step, but:
1. The same defect can be re-resolved repeatedly (Lindenbaum extension is non-deterministic)
2. New F-obligations can appear via the Lindenbaum extension
3. The defect count is not monotonically decreasing
4. No pigeonhole argument works because formulas can re-enter the active defects list

A proof would require either: (a) a redesigned chain that targets specific formulas deterministically, (b) a monotonicity property preventing F-obligation re-entry, or (c) a quasimodel semantic rewrite (~500-800 LOC per research estimate).

### Phase 4: Close restricted_buc and restricted_fuc [BLOCKED]

**Blocker**: Depends on Phase 3 (restricted_tc).

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- removed dead code (~140 LOC deleted, 2 sorry sites eliminated)

## Sorry Site Inventory (Post-Implementation)

### RootScopedChain.lean (5 active sorry sites, 2 correctly sorry'd)
1. `fwd_chain_forward_F` (line 1065) -- needs termination argument
2. `dd_bfmcs_restricted_tc` forward backward case (line 1092) -- needs fwd_chain_forward_F
3. `dd_bfmcs_restricted_tc` backward P-direction (line 1099) -- needs symmetric infrastructure
4. `dd_bfmcs_restricted_buc` (line 1107) -- depends on restricted_tc
5. `dd_bfmcs_restricted_fuc` (line 1114) -- depends on restricted_tc
6. `g_content_subset_self` (line 631 comment) -- correctly sorry'd (false under irreflexive semantics)
7. `h_content_subset_self` (line 659 comment) -- correctly sorry'd (false under irreflexive semantics)

### Soundness.lean (7 sorry sites, pre-existing)
- serial_future_axiom_valid, serial_past_axiom_valid (need NoMaxOrder/NoMinOrder constraint)
- temporal interaction proof (line 448, needs successor structure)
- until_step_valid, since_step_valid (need density or successor)
- until_elim_valid, since_elim_valid (need half-open guard which breaks BX2)

## Recommendations

1. **Guard convention**: The BX axiom system as currently formulated is NOT fully sound under ANY single guard convention. A system redesign is needed: either reformulate BX2/BX3 to use pointwise implication, or adopt the standard Xu (1988) formulation where Until uses reflexive witnesses with open guards.

2. **fwd_chain_forward_F**: Consider the quasimodel approach (500-800 LOC) as an alternative to proving termination of the current defect-driven chain. The quasimodel builds a finite pre-model that is then unraveled to an omega-chain, avoiding the termination issue entirely.

3. **Soundness frame classes**: Add a `serial` frame class (NoMaxOrder + NoMinOrder) for the serial axioms, and a `dense_or_discrete` class for until_step/since_step. This separates validity by frame condition rather than trying to prove universal validity.
