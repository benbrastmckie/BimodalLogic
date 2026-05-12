# Handoff: Backward G Truth Lemma Proved, Z1 Derivation Needed

**Session**: sess_1778605493_67cee2
**Date**: 2026-05-12
**Agent**: lean-implementation-agent

## Progress

### Completed: backward_G (Backward G Truth Lemma)

The key mathematical breakthrough identified in the task has been proved:

```
backward_G : forall (psi : Formula) (x : LimitDomSubtype A h_mcs),
    (forall (y : LimitDomSubtype A h_mcs), x < y -> psi in limit_f A h_mcs y.val) ->
    psi.all_future in limit_f A h_mcs x.val
```

**Proof technique**: By contradiction. Assume G(psi) not in limit_f(x). By negation_complete, neg(G(psi)) in limit_f(x). Build a DerivationTree for `neg(G(psi)) -> F(neg(psi))` using:
1. `double_negation psi` : `psi.neg.neg -> psi`
2. `temporal_necessitation` : `G(psi.neg.neg -> psi)`
3. `temp_k_dist` : `G(psi.neg.neg -> psi) -> (G(psi.neg.neg) -> G(psi))`
4. `modus_ponens` : `G(psi.neg.neg) -> G(psi)`
5. `contrapositive` : `neg(G(psi)) -> neg(G(psi.neg.neg))` = `neg(G(psi)) -> F(neg(psi))`

Then `F(neg(psi)) in limit_f(x)`. By `limit_F_resolution`: exists y > x with `neg(psi) in limit_f(y)`. But `psi in limit_f(y)` by hypothesis. Contradiction via `set_consistent_not_both`.

This proof does NOT require IsSuccArchimedean, breaking the circularity.

### Completed: backward_F (Backward F Truth Lemma)

Also proved:

```
backward_F : forall (phi : Formula) (x y : LimitDomSubtype A h_mcs),
    x < y -> phi in limit_f A h_mcs y.val -> phi.some_future in limit_f A h_mcs x.val
```

**Proof technique**: If G(neg(phi)) in limit_f(x), then by forward_G, neg(phi) in limit_f(y), contradicting phi in limit_f(y). So G(neg(phi)) not in limit_f(x). By negation_complete, neg(G(neg(phi))) = F(phi) in limit_f(x).

### Together: Complete G/F Truth Lemma

backward_G + limit_forward_G give: `G(psi) in limit_f(x) <-> psi in limit_f(y) for all y > x`.
backward_F + limit_F_resolution give: `F(psi) in limit_f(x) <-> exists y > x, psi in limit_f(y)`.

These are the COMPLETE truth lemmas for G and F, proved WITHOUT IsSuccArchimedean.

## Remaining: Z1 DerivationTree from Prior-UZ

### What's Needed

Derive the Z1 axiom (Doets's modified Lob) as a `DerivationTree`:

```
Z1 : DerivationTree [] (G(Gp -> p) -> (FGp -> Gp))
```

This is derivable from `Prior-UZ : F(phi) -> U(phi, neg(phi))` combined with the BX Until axioms.

### How Z1 Closes the Gap (Doets Claim 10)

From Doets (1987), Chapter 7, Claim 10:

Any bounded non-empty definable set has a maximum. Proof sketch:
1. Let phi^N = {n in N : phi(n)} be bounded above and non-empty.
2. At m < n (where phi(n) holds): F(phi) and F(G(neg(phi))) hold at m.
3. Z1 with neg(phi) for p: G(G(neg(phi)) -> neg(phi)) -> (FG(neg(phi)) -> G(neg(phi))).
4. Contrapositive: neg(G(neg(phi))) -> (G(G(neg(phi)) -> neg(phi)) -> neg(FG(neg(phi)))).
5. Since F(phi) = neg(G(neg(phi))) holds: G(G(neg(phi)) -> neg(phi)) -> neg(FG(neg(phi))).
6. Since FG(neg(phi)) holds: neg(G(G(neg(phi)) -> neg(phi))).
7. I.e., F(G(neg(phi)) and phi) at m. The witness k has both phi and G(neg(phi)), making k the maximum.

In the gap scenario: the orbit set is bounded above but has no maximum. A discriminating formula (from the MCS difference between orbit and pred-chain points, or from the Z1 consequence) gives the contradiction.

### Derivation Strategy

The Z1 derivation from Prior-UZ likely uses:
- `Prior-UZ(Gp)` : `F(Gp) -> U(Gp, neg(Gp))`
- BX2G (left_mono_until_G) : guard monotonicity under G
- BX5 (self_accum_until) : self-accumulation
- BX10 (until_F) : eventuality extraction
- `temp_k_dist` : G-distribution
- `temp_4` : G-transitivity
- `contrapositive` : propositional

See Reynolds (1994) for the derivation in the US/Z system.

### Key References

- Doets (1987), Chapter 7, Claim 10 (pp. 91-92)
- Reynolds (1994), Section 7 on Prior structures and definable gaps
- Both available in `/home/benjamin/Projects/ProofChecker/literature/`

## File Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
  - backward_G proved (lines ~1683-1724)
  - backward_F proved (lines ~1728-1754)
  - Sorry remains at line 1778 (gap elimination)

## Proof State at Sorry

```
backward_G : forall (psi : Formula) (x : LimitDomSubtype A h_mcs),
    (forall (y : LimitDomSubtype A h_mcs), x < y -> psi in limit_f A h_mcs y.val) ->
    psi.all_future in limit_f A h_mcs x.val
backward_F : forall (phi : Formula) (x y : LimitDomSubtype A h_mcs),
    x < y -> phi in limit_f A h_mcs y.val -> phi.some_future in limit_f A h_mcs x.val
|- False
```

Plus all the gap scenario hypotheses (h_lt_pred_chain, h_pred_chain_strict, h_pred_chain_ge_L, orbit_below_L, etc.).
