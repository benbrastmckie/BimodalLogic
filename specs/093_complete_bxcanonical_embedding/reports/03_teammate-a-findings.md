# Teammate A Findings: Biased Lindenbaum Approach

**Task**: 93 - Complete BXCanonical embedding (forward_F blocker)
**Angle**: Biased Lindenbaum
**Date**: 2026-04-13

## Key Findings

### 1. The Existing Lindenbaum Uses Zorn's Lemma (Not Enumeration)

The current `set_lindenbaum` in `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` (lines 291-340) uses `zorn_subset_nonempty` from Mathlib. It finds a maximal element in `ConsistentSupersets S` -- the set of all consistent supersets of the base set S. The proof is clean (50 lines) and non-constructive. There is no enumeration of formulas.

This matters because a "biased Lindenbaum" that enumerates formulas and greedily adds from a bias set P is a fundamentally different construction from the Zorn-based approach. A Zorn-based biased variant would need to constrain the partial order differently (e.g., prefer extensions containing more of P), which is harder to formalize.

### 2. Individual F-Formula Consistency with the Resolving Seed CANNOT Be Proven

The most natural biased Lindenbaum would try to preserve each `F(psi)` from `M` through the resolving step for `sigma`. This requires showing:

> If `F(sigma) in M` and `F(psi) in M`, then `{sigma} union g_content(M) union {F(psi)}` is consistent.

**This does not hold in general.** Here is the detailed argument for why:

Suppose `{sigma} union g_content(M) union {F(psi)}` is inconsistent. Then `{sigma} union g_content(M) |- not F(psi) = G(not psi)`. By deduction on sigma: `g_content(M) |- sigma -> G(not psi)`. By generalized temporal K: `G(g_content(M)) |- G(sigma -> G(not psi))`. Since each `G(chi)` from `G(g_content(M))` is in M, by MCS closure: `G(sigma -> G(not psi)) in M`.

Now from `G(sigma -> G(not psi)) in M` and `F(sigma) in M`, we derive `F(G(not psi)) in M` (using the theorem `G(alpha -> beta) -> (F(alpha) -> F(beta))`, which is derivable from temp_k_dist and duality).

Can we derive a contradiction from `F(psi) in M` and `F(G(not psi)) in M`? **No.** These are semantically compatible: psi can hold at some time s, and G(not psi) can hold at a later time t > s (meaning not psi holds at all times >= t). Using BX11 (temporal linearity):

```
F(psi) and F(G(not psi)) -> F(psi and G(not psi)) or F(psi and F(G(not psi))) or F(F(psi) and G(not psi))
```

- First disjunct: `F(psi and G(not psi))` -- contradictory (by BX1 reflexivity: `G(not psi) -> not psi`, so `psi and G(not psi) -> bot`, hence `F(bot)` which is `not G(top)`, contradicting the theorem `G(top)`).
- Third disjunct: `F(F(psi) and G(not psi))` -- contradictory (at the witness time s, `F(psi)(s)` means exists `t >= s` with `psi(t)`, but `G(not psi)(s)` means `not psi(t)` for all `t >= s`).
- **Second disjunct: `F(psi and F(G(not psi)))` -- NOT contradictory.** This says: at some future time, psi holds AND at an even later time, G(not psi) starts. Perfectly consistent.

So BX11 forces us into the second disjunct, which is satisfiable. Therefore `{sigma} union g_content(M) union {F(psi)}` CAN be inconsistent even when both `F(sigma)` and `F(psi)` are in M.

### 3. The G-Lifting Argument Does Not Extend

The existing proof of `forward_temporal_witness_seed_consistent` (WitnessSeed.lean lines 81-179) shows that `{psi} union g_content(M)` is consistent when `F(psi) in M`. The argument: if inconsistent, then by generalized temporal K, `G(not psi) in M`, contradicting `F(psi) = not G(not psi) in M`.

This argument is specific to the RESOLVING formula psi. It works because the contradiction involves the SAME formula under both F and G(not ...). For a NON-resolving F-formula F(chi), the contradiction would require showing `G(not chi) in M'` (the new MCS), but we only have `F(chi) in M` (the OLD MCS), not `F(chi) in M'`.

### 4. Biased Lindenbaum Formalization: What It Would Look Like

A biased Lindenbaum in the Zorn framework would need something like:

```lean
theorem biased_set_lindenbaum (S : Set Formula) (hS : SetConsistent S)
    (P : Set Formula) :
    exists M, S subseteq M and SetMaximalConsistent M and
      forall phi in P, SetConsistent (M union {phi}) -> phi in M
```

The last clause says: if adding phi to M would be consistent, then phi is already in M. But this is TRIVIALLY TRUE for any MCS M! Because if `phi notin M` and M is MCS, then `insert phi M` is inconsistent (by maximality). So `SetConsistent (M union {phi}) -> phi in M` reduces to `not SetConsistent (insert phi M) or phi in M`, which is exactly the MCS property.

In other words, **every MCS already satisfies the biased Lindenbaum condition** -- the bias set P has no effect. The issue is not about "trying harder to include" formulas; it's that the Lindenbaum extension is unique up to the choice in Zorn's lemma, and we cannot control which maximal element Zorn picks.

### 5. An Enumeration-Based Biased Lindenbaum

An alternative would bypass Zorn entirely: enumerate all formulas, and at each step, check whether adding the next formula is consistent. When processing a formula from P, add it preferentially. This gives:

```lean
theorem enum_biased_lindenbaum (S : Set Formula) (hS : SetConsistent S)
    (P : Set Formula) (hP : Finite P) :
    exists M, S subseteq M and SetMaximalConsistent M and
      P inter M = {phi in P | SetConsistent (S union P_before(phi) union {phi})}
```

where `P_before(phi)` is the set of P-elements processed before phi.

But the formalization cost is high (enumeration requires `Denumerable Formula`, explicit construction of the chain, well-ordering arguments), and it STILL doesn't solve the problem: we cannot prove `SetConsistent (S union {F(psi)})` for the resolving seed S when other choices have already been made.

### 6. What Biased Lindenbaum CAN Do

The biased Lindenbaum IS useful for non-resolving steps. In the current code, `fwd_succ` already uses `g_content(M) union f_carry(M)` as the seed for non-resolving steps (lines 72-78 of CanonicalModel.lean). Since `g_content(M) union f_carry(M) subseteq M` (proven in `enriched_seed_consistent`), this seed IS consistent, and the standard Lindenbaum already preserves f_carry through non-resolving steps. No biased variant is needed here.

The issue is exclusively with resolving steps, and biased Lindenbaum does not help there.

## Recommended Approach

**The biased Lindenbaum approach is NOT viable for solving the forward_F blocker.** The fundamental obstacle is that `{sigma} union g_content(M) union {F(psi)}` can be genuinely inconsistent in the logic, and no amount of preferential inclusion can fix an inconsistency.

Instead, I recommend investigating:

1. **Restricted temporal coherence** (mitigation path 3 from the plan): Use `BFMCS.restricted_temporally_coherent` which only requires forward_F for formulas in a finite `deferralClosure`. With finitely many F-obligations, a priority-based schedule (e.g., round-robin over the finite closure set) can ensure each F-formula gets resolved before it can be killed. The key insight: with finitely many obligations, at each resolving step for sigma, the seed `{sigma} union g_content(M)` only needs to coexist with finitely many other F-formulas, and we can schedule them so each gets resolved in turn.

2. **Canonical frame approach** (mitigation path 2): Use the canonical frame's accessibility relation where each F-obligation gets a fresh successor MCS. This avoids the dovetailing chain entirely and may be simpler, though it requires restructuring the BFMCS construction.

3. **Two-phase chain**: First resolve F(psi) at a step where psi is scheduled, producing an MCS containing psi. THEN extend with g_content. This reverses the seed order and may be more tractable, though it requires proving g_content can be added to {psi} consistently.

## Evidence/Examples

### Concrete Counterexample Sketch

Consider an MCS M containing: F(p), F(q), G(p -> G(not q)).

- g_content(M) contains all phi such that G(phi) in M, including `p -> G(not q)`.
- The resolving seed for p: `{p} union g_content(M)`.
- From `{p, p -> G(not q)}` we derive `G(not q)`.
- So `{p} union g_content(M) |- G(not q)`, meaning `{p} union g_content(M) |- not F(q)`.
- Therefore `{p} union g_content(M) union {F(q)}` is inconsistent.
- The Lindenbaum extension of `{p} union g_content(M)` MUST contain `G(not q)`, so `F(q)` is killed.

This is consistent: semantically, M is at a time where F(p) and F(q) both hold, and the commitment G(p -> G(not q)) means "whenever p becomes true, q stays false forever after". So p and q can both hold eventually, but p must hold AFTER q (or simultaneously). The resolving step for p puts us at a world where p holds but G(not q) also holds, so F(q) is dead.

### Why This Doesn't Block Correctness (Semantically)

In the counterexample, F(q) in M means q holds at some future time. If we resolve p first and kill F(q), that's fine IF q was already resolved at an earlier step. The schedule just needs to target q before p. This is what the restricted/priority approach exploits: with finitely many obligations, we can order the resolutions correctly.

## Confidence Level

**High confidence** that biased Lindenbaum alone does NOT solve the forward_F blocker. The counterexample in the Evidence section is concrete and the impossibility argument is rigorous.

**Medium confidence** that restricted temporal coherence (finite deferral closure) is the most promising path. This depends on whether the existing `restricted_temporally_coherent` infrastructure is sufficient and whether the finite scheduling argument can be formalized.
