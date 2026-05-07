# Handoff: Guard Threading Analysis and Corrected Approach

## Status: NOT STARTED -- plan Phase 1 requires correction before implementation

## Session: sess_1778114001_749277

## Summary

The plan's Phase 1 proposes strengthening `c5_forward_witness` to return `pc.xi in val.g pc.x y`. Through detailed analysis of all case sites in CounterexampleElimination.lean, I determined that this return type is mathematically incorrect for Walk A (when pc.x < max_old) and Walk B (eta-shortcut). The correct approach uses an adjacent-pair guard condition and requires prerequisite work in PointInsertion.lean.

## Analysis Findings

### 1. The plan's return type `pc.xi in val.g pc.x y` is WRONG

The Chronicle's g function at finite stages is only meaningful for adjacent pairs. For non-adjacent pairs (a, b), g(a, b) is inherited from the singleton chronicle's `g _ _ = empty`. So `xi in g(x, y)` for non-adjacent (x, y) is impossible.

In Walk A with pc.x < max_old: the witness y is beyond max_old. Between pc.x and y in the new domain there are intermediate old points. So (pc.x, y) is NOT adjacent in dom_{n+1}. Therefore `xi in g'(pc.x, y) = chi.g(pc.x, y) = empty` -- the guard claim is False.

In Walk B eta-shortcut: val = chi (unchanged chronicle), witness = u_next. The h_no_wit check says `not-exists y in dom, pc.x < y and eta in f(y) and xi in g(pc.x, y)`. Since eta in f(u_next) and pc.x < u_next, we get `xi not-in g(pc.x, u_next)`. So the guard is provably FALSE.

### 2. The correct return type is the adjacent-pair guard condition

From the earlier handoff (burgess-c5a-alignment.md, line 66-70):

```lean
c5_forward_witness : ... ->
    exists y in val.dom, pc.x < y and pc.eta in val.f y and
      forall a b, Adjacent val.dom a b -> pc.x <= a -> b <= y -> pc.xi in val.g a b
```

This says: xi is in the g-value of EVERY adjacent pair between pc.x and y. Combined with `adj_g_mem_limit_f`, this covers any w in the limit domain between x and y.

### 3. Case-by-case analysis for the adjacent-pair guard

| Case | Witness | Adjacent pairs between x and y | Guard source |
|------|---------|-------------------------------|--------------|
| n=0 forward | y beyond max_old, (pc.x, y) adjacent | Only (pc.x, y) | xi in B from lemma_2_4_with_guard |
| Walk A, pc.x = max_old | y beyond max_old, (max_old, y) adjacent | Only (max_old, y) | xi in B_l24 from lemma_2_4_with_guard |
| Walk A, pc.x < max_old | y beyond max_old | Multiple: (pc.x, x'), ..., (w_last, max_old), (max_old, y) | FAILS -- walk invariant needed |
| Walk B eta-shortcut | u_next, val = chi | Possibly multiple | FAILS -- h_no_wit contradicts guard |
| Walk B splitting | z = midpoint(u_max, u_next) | (u_max, z) and (z, u_next) | Need xi in B' from splitting |
| Not-cond(i) splitting | z = midpoint(pc.x, x') | (pc.x, z) and (z, x') | Need xi in B' from splitting |
| Not-actual forward | y from push_neg | Only (pc.x, y) -- must be adjacent | xi in g(pc.x, y) from push_neg |

### 4. Walk A with pc.x < max_old: restructure to split

When condition (i) holds at (pc.x, x'), we have:
- xi in g(pc.x, x') (from condition (i))
- xi-and-U(xi,eta) in f(x') (from condition (i))
- eta not-in f(x') (from h_no_wit + xi in g(pc.x, x') -- any y with eta in f(y) and xi in g(pc.x, y) would be a witness, contradiction)
- eta.neg in f(x') (from MCS completeness)

This is EXACTLY the setup for the splitting lemmas (2.6, 2.7, 2.8) at (pc.x, x'). So instead of walking to max_old and using lemma_2_4, we should SPLIT at (pc.x, x').

The splitting gives B', D, B'' with:
- eta in D
- g(pc.x, x') subset B' (from splitting)
- xi in g(pc.x, x') (from condition (i))
- Therefore xi in B'!

The new witness z = midpoint(pc.x, x') with f'(z) = D and g'(pc.x, z) = B'. The only adjacent pair between pc.x and z is (pc.x, z) itself, and xi in B' = g'(pc.x, z).

**Action**: Replace Walk A (pc.x < max_old) with splitting at (pc.x, x'). Keep Walk A (pc.x = max_old) which is equivalent to n=0.

### 5. Walk B eta-shortcut: REMOVE

When eta in f(u_next) and val = chi (unchanged), the guard is provably false. The fix: REMOVE the eta-shortcut case and always fall through to splitting at (u_max, u_next).

But splitting at (u_max, u_next) needs xi in g'(u_max, z) = B'. The splitting gives g(u_max, u_next) subset B'. To get xi in B':
- If xi in g(u_max, u_next): then xi in B' from g subset B'. But we don't know this in general (walk invariant issue).
- If xi not-in g(u_max, u_next): need the strengthened lemma_2_7 to guarantee xi in B'.

**Key**: If u_max = pc.x (walk didn't advance), then xi in g(pc.x, x') from condition (i), and u_next = x'. So xi in g(u_max, u_next). Good.

If u_max > pc.x: the walk advanced, and xi in g(u_max, u_next) is NOT guaranteed. The splitting at (u_max, u_next) uses lemma_2_7 with xi not-in g(u_max, u_next), and the STRENGTHENED lemma_2_7 returns xi in B'.

**Action**: Remove Walk B eta-shortcut. Always split at (u_max, u_next). Use strengthened lemma_2_7 when xi not-in g(u_max, u_next).

### 6. Splitting cases ("not condition (i)"): need xi in B'

In the not-condition(i) branch, xi might or might not be in g(pc.x, x').

- If xi in g(pc.x, x'): then g subset B' gives xi in B'. Done.
- If xi not-in g(pc.x, x'): need the STRENGTHENED lemma_2_7 (which returns xi in B' even when xi not-in B).

For sub-cases using lemma_2_6: when xi not-in g, lemma_2_6 does NOT guarantee xi in B'. These cases need to be redirected to use lemma_2_7 instead, or lemma_2_6 needs a different Zorn seed.

Actually, looking at the case analysis more carefully: lemma_2_6 is used when the splitting formula is eta.neg (not xi). The cases that use lemma_2_7 already have xi not-in B as a hypothesis. So the key is: strengthen lemma_2_7 to additionally return xi in B'.

For the lemma_2_6 cases where xi in g: xi in B' follows from g subset B'. No change needed.
For the lemma_2_6 cases where xi not-in g: these need restructuring to use lemma_2_7 instead, or use a combined Zorn seed DC(B union {xi, eta.neg}).

### 7. Prerequisite: Strengthen lemma_2_7 in PointInsertion.lean

The strengthening requires:
1. A guard conjunction theorem: U(beta, delta) and U(xi, delta) implies U(beta-and-xi, delta) for all beta in B, delta in D
2. Use BX7 (linearity of Until) to derive this
3. Apply dc_delta_B_burgessR3 with delta=xi to get burgessR3(A, DC(B union {xi}), D)
4. Start the Zorn from DC(B union {xi}) instead of B

**Guard conjunction from BX7**: BX7 says U(phi, psi) and U(chi, theta) -> U(phi-and-chi, psi-and-theta) or U(phi-and-chi, psi-and-chi) or U(phi-and-chi, phi-and-theta). Setting psi=theta=delta: all three disjuncts give U(phi-and-chi, something containing delta). By right monotonicity, each gives U(phi-and-chi, delta).

So: `U(beta, delta) and U(xi, delta) -> U(beta-and-xi, delta)`. This is derivable from BX7 + BX3 (right mono).

**dc_delta_B_burgessR3 requirements**:
- h_until_all: forall beta in B, forall delta in D, untl(beta-and-xi, delta) in A -- from guard conjunction applied to h_rSet_A and h_burgessR_xi
- h_since_all: forall beta in B, forall alpha in A, snce(beta-and-xi, alpha) in D -- ALREADY EXISTS at line 3669 (h_snce_conj_xi_D)

### 8. Prerequisite: Strengthen lemma_2_8 similarly

Same approach as lemma_2_7 but with different seed consistency proof. Mirror for Since variants.

## Corrected Implementation Plan

### Prerequisite Phase 0: Guard Conjunction Theorem (~30 lines)
File: PointInsertion.lean (or Theorems)
- Prove: U(alpha, gamma) and U(beta, gamma) -> U(alpha-and-beta, gamma)
- Uses BX7 (linear_until) + BX3 (right_mono_until)
- Both derivation-level and MCS-level versions needed

### Corrected Phase 1: Strengthen lemma_2_7/2_8 (~60 lines each)
File: PointInsertion.lean
- Add guard conjunction theorem to derive `untl(beta-and-xi, delta) in A`
- Apply dc_delta_B_burgessR3 to get burgessR3(A, DC(B union {xi}), D)
- Start B' Zorn from DC(B union {xi}) instead of B
- Return additional `xi in B'` (from DC(B union {xi}) subset B')
- Mirror for lemma_2_8, lemma_2_7_since, lemma_2_8_since

### Corrected Phase 2: Strengthen EliminationResult (~30 lines)
File: CounterexampleElimination.lean
- Change c5_forward_witness to adjacent-pair guard condition:
  `forall a b, Adjacent val.dom a b -> pc.x <= a -> b <= y -> pc.xi in val.g a b`
- Same for c5_backward_witness (Since mirror)
- All non-C5 cases: unchanged (absurd still works)

### Corrected Phase 3: Fix C5 forward cases (~400 lines)
File: CounterexampleElimination.lean
- n=0: trivial (only one adjacent pair, guard from lemma_2_4_with_guard)
- Walk A, pc.x = max_old: same as n=0
- Walk A, pc.x < max_old: REPLACE with splitting at (pc.x, x')
  - Condition (i) gives xi in g(pc.x, x')
  - Splitting gives g subset B', so xi in B'
  - Witness z is adjacent to pc.x, guard at (pc.x, z) = B'
- Walk B eta-shortcut: REMOVE entirely
- Walk B splitting (u_max, u_next):
  - If xi in g(u_max, u_next): g subset B' gives guard
  - If xi not-in g: strengthened lemma_2_7 gives xi in B'
- Not-condition(i) splitting:
  - If xi in g: g subset B' gives guard
  - If xi not-in g: strengthened lemma_2_7 gives xi in B'
  - Cases using lemma_2_6 where xi not-in g: redirect to lemma_2_7
- Not-actual: push_neg gives guard directly (y is adjacent)

### Corrected Phase 4: Fix C5 backward cases (~400 lines)
Mirror of Phase 3 for Since

### Corrected Phase 5: Strengthen omega_chain_c5_witness and close sorries (~100 lines)
File: ChronicleConstruction.lean
- Strengthen omega_chain_c5_witness to return adjacent-pair guard
- In limit_satisfies_c5_strong: for any w between x and y in limit_dom,
  find the adjacent pair at stage n+1 that contains w, apply adj_g_mem_limit_f
- Mirror for Since

## Key Files
- `PointInsertion.lean` -- guard conjunction theorem, strengthen lemma_2_7/2_8
- `CounterexampleElimination.lean` -- restructure Walk A/B, fix all cases
- `ChronicleConstruction.lean` -- close the 2 sorry sites

## Convention Reminder
Our `untl(guard=xi, event=eta)` = Burgess `U(event=xi, guard=eta)`. SWAPPED.
Our `snce(guard=xi, event=eta)` = Burgess `S(event=xi, guard=eta)`. SWAPPED.

## Effort Estimate
- Prerequisite Phase 0: 2-3 hours
- Phase 1 (PointInsertion): 4-6 hours (lemma_2_7/2_8 strengthening is delicate)
- Phase 2 (type change): 1 hour
- Phase 3 (forward cases): 8-12 hours (Walk restructuring + case analysis)
- Phase 4 (backward cases): 6-8 hours (mirror of Phase 3)
- Phase 5 (close sorries): 2-3 hours
- Total: 23-34 hours

## Blocker: Plan Phase 1 Type is Wrong

The plan at `specs/107_chain_design_diagnostics_for_representation_theorem/plans/64_implementation-plan.md` specifies `pc.xi in val.g pc.x y` as the return type. This is incorrect as shown above. The plan needs revision via `/revise 107` before implementation can proceed.

Specific corrections needed:
1. Phase 1: change return type to adjacent-pair guard condition
2. Phase 2: add Walk A restructuring (split instead of walk) and Walk B removal
3. Phase 3: mirror the restructuring for Since
4. Add prerequisite Phase 0 for guard conjunction theorem and lemma_2_7 strengthening
5. Update effort estimate from 28-40 hours to 35-50 hours
