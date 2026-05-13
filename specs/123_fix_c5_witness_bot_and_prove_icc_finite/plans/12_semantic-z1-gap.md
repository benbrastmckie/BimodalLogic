# Implementation Plan: Z1 Derivation and Gap Elimination (v14)

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [IN PROGRESS]
- **Effort**: 6-10 hours
- **Dependencies**: None (all prerequisite infrastructure exists sorry-free)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/14_z1-derivation-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/15_stage-walk-revised.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-a-irr-rule.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-b-z1-proofs.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-c-construction-dynamics.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/13_teammate-d-online-search.md
  - All prior reports from rounds 04-12 (integrated in plans v4-v10)
- **Artifacts**: plans/12_semantic-z1-gap.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

### Research Integration

**Reports integrated in this plan version (v14):**
- `14_z1-derivation-research.md` (integrated in v12)
- `15_stage-walk-revised.md` (integrated in v12)
- All reports from v4-v11 preserved
- v12 implementation findings (backward_P, gap analysis)
- v13 exhaustive stage-induction analysis (confirmed blocked)
- Session research findings: Z1 derivation approach, Doets maximum principle, Reynolds fallback

### Why Plan v14 Supersedes Plan v13

Plan v13 attempted stage-induction restructuring (`succ_reaches_dom_N` boundary cases, N_max induction, Finset.card measures). Exhaustive analysis proved ALL stage-induction approaches are blocked by the same fundamental obstruction: the succ function on limit_dom can jump to points entering at arbitrarily later stages, making stage-based induction measures non-decreasing.

**Confirmed blocked approaches (do NOT attempt):**
1. Stage-induction on N in `succ_reaches_dom_N` (boundary cases unprovable)
2. N_max(a,b) induction (intermediate succ points enter at later stages)
3. Finset.card measures (same stage-jumping problem)
4. Z1-as-axiom (circular: soundness proof requires IsSuccArchimedean)
5. Direct semantic gap contradiction (constant-MCS case is consistent with all temporal axioms)

**New strategy**: Two-track approach using syntactic derivation:

1. **Primary (Phase 2)**: Derive Z1 = `G(Gp -> p) -> (FGp -> Gp)` as a `DerivationTree [] Z1` from Prior-UZ + BX axioms. This is a SYNTACTIC proof, not a new axiom, so no soundness proof is needed and no circularity arises. Once Z1 is derived, `theorem_in_mcs` puts it into every MCS.

2. **Gap closure (Phase 3)**: With Z1 in every MCS, apply the Doets maximum principle argument to eliminate the gap in `succ_cofinal`. The argument is ~15-20 lines using existing backward_G/F infrastructure.

3. **Fallback (Phase 4)**: If Phase 2 proves intractable, adapt Reynolds 1994's contemporaneous equivalence argument, which uses a different (more infrastructure-heavy) path to the same conclusion.

## Overview

Close the remaining sorry site at line 1816 in `succ_cofinal` (and downstream IsSuccArchimedean) by deriving the Z1 axiom syntactically from Prior-UZ and existing BX axioms. Z1 is `G(Gp -> p) -> (FGp -> Gp)`, the syntactic correspondent of the IsSuccArchimedean frame condition. Once Z1 is a theorem (DerivationTree), `theorem_in_mcs` places it in every MCS, enabling the Doets maximum principle argument to show every definable bounded set has a maximum, which contradicts the gap scenario.

**Definition of done**: `succ_cofinal` sorry-free. `limitDomSubtype_isSuccArchimedean` sorry-free. `dd_countermodel_chronicle_discrete` sorry-free. Full `lake build` passes.

## Goals & Non-Goals

**Goals:**
- Derive Z1 as a `DerivationTree [] (G(Gp -> p) -> (FGp -> Gp))` from Prior-UZ + BX axioms
- Use Z1 + Doets maximum principle to close the sorry at line 1816 in `succ_cofinal`
- Make `limitDomSubtype_isSuccArchimedean` sorry-free
- Make `dd_countermodel_chronicle_discrete` sorry-free
- Preserve Phase 1 work (already COMPLETED)

**Non-Goals:**
- Fixing stage-induction boundary cases (confirmed blocked)
- Adding Z1 as a new axiom (circular with soundness)
- Fixing the nondense/mixed sorry stubs (lines 839, 3268)
- Modifying the construction internals (ChronicleConstruction.lean, CounterexampleElimination.lean)
- Modifying the axiom system

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Z1 derivation tree is large/complex (50-100 lines) | M | M | Break into 3-4 helper lemmas. Use existing Propositional/TemporalDerived infrastructure. Start with simplest sub-derivation. |
| Derivation uses proof steps not available in the current axiom system | H | L | The axiom system includes Prior-UZ, temp_k_dist, temporal_necessitation, propositional tautologies, and modus ponens -- sufficient per published proofs. |
| Doets maximum principle argument requires additional backward lemmas | M | L | backward_G, backward_F, backward_P all proved. limit_F_resolution and limit_P_resolution available. |
| Reynolds fallback requires 200-300 lines of new infrastructure | H | L | Only needed if Phase 2 fails. Well-documented in Reynolds 1994. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 (fallback, only if 2 fails) |
| 5 | 5 | 3 or 4 |

### Phase 1: Add Imports and Prove Order.succ Equality [COMPLETED]

**Goal**: Add Mathlib imports and prove `Order.succ` equals `limitDomSubtype_succ`.

**Tasks**:
- [x] Add Mathlib imports (lines 11-12)
- [x] Prove `order_succ_eq` (line 1006, `rfl`)
- [x] Prove `order_pred_eq` (line 1017, `rfl`)

**Timing**: Completed
**Depends on**: none
**Completed**: 2026-05-11

---

### Phase 2: Z1 Derivation from Prior-UZ [BLOCKED]

**Goal**: Construct a `DerivationTree [] z1_formula` where `z1_formula = G(Gp -> p) -> (FGp -> Gp)`.

This is the critical phase. Z1 must be derived purely syntactically from the existing BX axiom system (including Prior-UZ). The derivation tree will be 50-100 lines of Lean code.

#### Sub-step 2.1: Define Z1 formula and helper abbreviations

Create a section in ChronicleToCountermodel.lean (or a new helper file if cleaner) with:

```lean
-- Z1: G(Gp -> p) -> (FGp -> Gp)
-- Using a fixed propositional variable, say Formula.atom 0
private def z1_var : Formula := Formula.atom 0
private def z1_formula : Formula :=
  (z1_var.all_future.imp z1_var).all_future.imp
    (z1_var.all_future.some_future.imp z1_var.all_future)
```

Note: The derivation must work for ALL formulas (universally), not just a fixed atom. Since `theorem_in_mcs` needs `DerivationTree [] (z1_formula_for phi)` for each phi, we need a parametric derivation: `def z1_derivation (phi : Formula) : DerivationTree [] (z1_formula_of phi)`.

#### Sub-step 2.2: Derive key intermediate lemmas

The derivation strategy from Prior-UZ:

**Lemma A**: `⊢ F(phi) -> U(phi, neg(phi))` -- this IS Prior-UZ (`Axiom.prior_UZ phi`), available directly.

**Lemma B**: `⊢ G(phi -> psi) -> (G(phi) -> G(psi))` -- this IS temp_k_dist, available directly.

**Lemma C (key step)**: `⊢ G(G(neg phi) -> neg phi) -> (F(G(neg phi)) -> G(neg phi))`

Derivation sketch for Lemma C:
1. From Prior-UZ with `G(neg phi)`: `⊢ F(G(neg phi)) -> U(G(neg phi), neg(G(neg phi)))`
2. From temp_4: `⊢ G(neg phi) -> G(G(neg phi))` (i.e., G(neg phi) is self-reinforcing)
3. From temp_k_dist with `(G(neg phi) -> neg phi)`: `⊢ G(G(neg phi) -> neg phi) -> (G(G(neg phi)) -> G(neg phi))`
4. Combine: if `G(G(neg phi) -> neg phi)` holds and `F(G(neg phi))` holds:
   - By (1), `U(G(neg phi), neg(G(neg phi)))` holds
   - The Until gives a witness s > t where `G(neg phi)` holds at s, with `neg(G(neg phi))` at all intermediate points
   - By (2), `G(neg phi)` at s gives `G(G(neg phi))` at s
   - By (3) + hypothesis, `G(neg phi)` at s gives `neg phi` at all points beyond s (and also at s itself by the G premise)
   - The Until witness with `neg(G(neg phi))` guard is vacuous when the event `G(neg phi)` is self-propagating
   - Result: `G(neg phi)` propagates from the witness to all future points

**Alternative derivation strategy (contrapositively)**:

Z1 is `G(Gp -> p) -> (FGp -> Gp)`. Contrapositive of the consequent gives:
`G(Gp -> p) -> (neg(Gp) -> neg(FGp))`, i.e., `G(Gp -> p) -> (Fp' -> G(Fp'))` where `p' = neg p`.

This says: under the hypothesis `G(Gp -> p)`, if `Fp'` holds, then `G(Fp')` holds. This is a form of "persistence of eventuality" under the well-ordering hypothesis.

Yet another way: `G(Gp -> p) -> (FGp -> Gp)` is equivalent to `G(Gp -> p) ∧ FGp -> Gp`.

Assume `G(Gp -> p)` and `FGp`. Need `Gp`.
- By Prior-UZ on `Gp`: `F(Gp) -> U(Gp, neg(Gp))`
- So `U(Gp, neg(Gp))`.
- Until gives: exists s > t with `Gp` at s, `neg(Gp)` at all r in (t,s).
- `Gp` at s means `p` at all r > s.
- For any r in (t,s): `neg(Gp)` at r, so `F(neg p)` at r. But `Gp` at s means `p` at s, and all q > s have `p` at q. So `neg p` must occur in (r, s).
- Hmm, let r be the last point in (t,s) (if discrete). Then `neg(Gp)` at r means `F(neg p)` at r. The next point after r is s (no points between r and s by "last point" + discreteness). So `neg p` must hold at some q > r, and the nearest such q is s or beyond s. But `p` holds at s (from `Gp` at s). So `neg p` doesn't hold at s.
- Actually, from `Gp` at s, p holds at all points strictly after s, AND the hypothesis `G(Gp -> p)` gives: at s, `Gp -> p`, so if `Gp` at s then `p` at s. Wait -- `G(Gp -> p)` means "for all r > t, Gp -> p at r". At s > t, `Gp` at s implies `p` at s.
- Now `neg(Gp)` at r means there exists q > r with `neg p` at q. Since r < s, and `p` holds at s and all points > s, `neg p` must hold at some q with r < q < s. But in the discrete case, if r is pred(s), there are no points between r and s, contradiction.

This sketch shows the derivation needs discreteness (U(top,bot)) to work. The full derivation should use:
1. Prior-UZ on `Gp`: gives Until witness structure
2. The until guard `neg(Gp)` at intermediate points
3. Discreteness: between r and s (adjacent), no intermediate points exist
4. `G(Gp -> p)` hypothesis: converts `Gp` at s to `p` at s
5. Contradiction: `neg(Gp)` at pred(s) needs `neg p` between pred(s) and s, but no such point exists

#### Sub-step 2.3: Build the DerivationTree

The derivation tree uses these constructors:
- `DerivationTree.axiom [] phi (Axiom.prior_UZ psi)` -- introduces Prior-UZ instance
- `DerivationTree.axiom [] phi (Axiom.temp_k_dist a b)` -- introduces G-distribution
- `DerivationTree.axiom [] phi (Axiom.temp_4 a)` -- introduces G-transitivity
- `DerivationTree.modus_ponens [] a b d1 d2` -- applies modus ponens
- `DerivationTree.temporal_necessitation phi d` -- from `[] ⊢ phi` derive `[] ⊢ G(phi)`
- `DerivationTree.weakening [] [] phi d h` -- weakening (usually identity)

Available propositional helpers from `Bimodal.Theorems.Propositional`:
- `double_negation (phi)` : `⊢ neg(neg(phi)) -> phi`
- `contrapositive` from TemporalDerived: `⊢ (A -> B) -> (neg B -> neg A)`
- `raa (A B)` : `⊢ A -> (neg A -> B)`
- `ecq (A B)` : `[A, neg A] ⊢ B`
- `classical_merge (P Q)` : `⊢ (P -> Q) -> ((neg P -> Q) -> Q)`

Available temporal helpers from `Bimodal.Theorems.TemporalDerived`:
- `G_distribution (phi psi)` : `⊢ G(phi -> psi) -> (G(phi) -> G(psi))`
- `G_transitivity (phi)` : `⊢ G(phi) -> G(G(phi))`
- `G_bot_absurd` : `⊢ G(bot) -> bot`
- `until_implies_some_future (phi psi)` : `⊢ U(phi, psi) -> F(phi)`
- `psi_imp_until (phi psi)` : `⊢ psi -> U(phi, psi)` (event immediately -> Until)
- `until_imp_or (phi psi)` : `⊢ U(phi, psi) -> phi ∨ F(psi)`
- `until_imp_F (phi psi)` : `⊢ U(phi, psi) -> F(phi)`

The derivation should be structured as a `def` returning `DerivationTree [] (z1_formula_of phi)`.

**Critical implementation note**: The derivation does NOT need to go through the full generality of Reynolds or Doets. It only needs to produce a well-typed `DerivationTree` term. The Lean type checker verifies correctness. So the implementer should:
1. State the goal type precisely
2. Use `lean_goal` to inspect what's needed at each step
3. Build bottom-up from axiom instances

#### Sub-step 2.4: Register Z1 as a theorem

After building the derivation tree:

```lean
def z1_theorem (phi : Formula) : DerivationTree [] (z1_formula_of phi) := ...

-- Then in the succ_cofinal proof:
have h_z1_in_mcs : z1_formula_of phi ∈ limit_f A h_mcs x.val :=
  theorem_in_mcs (limit_c0 A h_mcs x.val x.property) (z1_theorem phi)
```

**Tasks:**
- [ ] Define `z1_formula_of (phi : Formula)` abbreviation
- [ ] Build helper derivation: Prior-UZ instance for `G(neg phi)` (1 line)
- [ ] Build helper derivation: temp_4 instance (1 line)
- [ ] Build helper derivation: combine Prior-UZ + temp_4 + temp_k_dist into Z1 (30-80 lines)
- [ ] Test with `lean_verify` that the derivation type-checks
- [ ] Verify `theorem_in_mcs` can consume the derivation

**Timing**: 3-5 hours
**Depends on**: Phase 1

---

### Phase 3: Doets Maximum Principle and Gap Elimination [NOT STARTED]

**Goal**: Use Z1 in every MCS to close the sorry at line 1816 in `succ_cofinal`.

#### The Doets Argument (Claim 10)

With Z1 = `G(Gp -> p) -> (FGp -> Gp)` in every MCS, the gap scenario leads to contradiction:

**Setup**: In the gap scenario of `succ_cofinal`, we have:
- Orbit points `s^[n](a)` converging upward to limit L
- Pred-chain points `pred^[k](b)` above L
- All orbit points < all pred-chain points
- No limit_dom point equals L (it's a real limit, not a rational in limit_dom)

**Proof sketch** (to be formalized at line 1816):

Pick any formula phi that "discriminates" -- but wait, in the constant-MCS case, no discriminating formula exists. The Z1 approach avoids needing a discriminating formula. Instead:

1. Let `phi` be any formula. Consider two cases:
   - Case A: `G(neg phi)` is in the MCS of some orbit point `s^[n](a)`. Then `neg phi` holds at all points above `s^[n](a)`, including all pred-chain points. And `phi` either holds or doesn't at `s^[n](a)`.
   - Case B: `neg(G(neg phi))` = `F(phi)` is in the MCS of every orbit point.

Actually, the correct argument uses Z1 more directly:

**Correct Doets argument**: Given a "bounded definable set" -- a set S of limit_dom points defined by a formula phi, bounded above -- the set has a maximum.

In the gap scenario:
1. Pick `x` = any orbit point `s^[n](a)`.
2. Pick `phi` = any formula in the MCS of `x` that is NOT in the MCS of some point above.
   - In the constant-MCS case, no such phi exists. ALL formulas in the MCS of x are in the MCS of every other point.
3. In the constant-MCS case: all limit_dom points have identical MCS. Then for every orbit point `s^[n](a)` and every pred-chain point `pred^[k](b)`, the MCS are equal. Consider `G(neg(bot)) = G(top)`. This is always in every MCS (it's a theorem). Not helpful.

**The key insight**: Z1 doesn't help with the CONSTANT-MCS case directly. Z1 helps by enabling the following argument:

In the gap scenario, consider the formula `phi_gap := neg(G(neg phi))` = `F(phi)` for some phi. The issue is that Z1 enables proving that certain Until/Since formulas have witnesses at specific locations, ruling out the gap geometry.

**Revised argument using Z1 directly in the gap case**:

The gap scenario has orbit `{s^[n](a) | n}` below L and pred-chain `{pred^[k](b) | k}` above L.

For any orbit point `x = s^[n](a)` and any pred-chain point `y = pred^[k](b)`:
- `y > x` (all pred-chain above all orbit)
- `succ(x) = s^[n+1](a)` is also an orbit point
- Between `x` and `succ(x)`, no other limit_dom point exists (immediate successor)
- Between the supremum of orbit and infimum of pred-chain, no limit_dom point exists (the gap)

The contradiction comes from the UNTIL semantics:
- `next_top = U(top, bot)` is in every MCS (discrete case hypothesis `h_discrete`)
- At the LAST orbit point before the gap... but there is no last orbit point (the orbit is infinite, converging to L)

**Alternative direct argument**: Consider any orbit point `x = s^[n](a)`. We have `F(phi)` at x for any phi in the MCS of any point y > x (by `backward_F`). We also have `G(phi)` at x for phi that holds at ALL points above x (by `backward_G`).

In the constant-MCS case, let M be the common MCS. For every phi in M:
- phi is in the MCS of x (orbit point) and of y (pred-chain point)
- `G(phi)` is in the MCS of x (by `backward_G`, since phi holds at all points above x -- but wait, phi holds at all LIMIT_DOM points above x, and G semantics is over strict future in the MODEL, which means all points > x in limit_dom)

Actually, let me reconsider. The model truth for `G(phi)` at x is: for all y > x in limit_dom, phi is in limit_f(y). Since limit_f(y) = MCS for all y (constant case), and phi in M, we get phi at all y > x. So `G(phi)` at x for all phi in M (by `backward_G`).

Similarly `G(G(phi))` at x, by the same argument (since `G(phi)` at all y > x).

Now consider `G(G(phi) -> phi)` at x. For any y > x: `G(phi) -> phi` at y. Is `G(phi) -> phi` in M? Since both `G(phi)` and `phi` are in M: if `G(phi)` in M then `phi` in M, so `G(phi) -> phi` is in M (by `implication_property` direction -- actually, we need: if the implication is NOT in M, then `G(phi)` is in M and `neg(phi)` is in M, contradiction). So `G(phi) -> phi` in M for all phi in M.

And `FG(phi)` at x: since `G(phi)` holds at `s^[n+1](a)` (an orbit point > x), `F(G(phi))` holds at x (by `backward_F`).

By Z1: `G(G(phi) -> phi) -> (FG(phi) -> G(phi))`. With `G(G(phi) -> phi)` at x and `FG(phi)` at x, we get `G(phi)` at x.

But we ALREADY have `G(phi)` at x. So Z1 gives nothing new in the constant-MCS case.

**The real issue**: In the constant-MCS case, Z1 is trivially satisfied and provides no contradiction.

**Revised understanding**: The gap scenario with constant MCS IS contradicted, but not by temporal formulas alone. It's contradicted by the CONSTRUCTION: if all points have the same MCS M, then M is consistent with all temporal axioms, and the construction would not have created any counterexample-resolution points (no C4/C5 counterexamples exist when all MCS are equal). But the construction starts from a single root MCS and extends. If the root MCS satisfies all temporal formulas (which it does, being an MCS), then no counterexamples arise and the domain stays as the initial chain. The initial chain IS isomorphic to Z, so IsSuccArchimedean holds trivially.

So the constant-MCS case is actually fine -- it can't arise in a non-trivial gap scenario because the construction wouldn't create separate orbit/pred-chain components.

**The non-constant MCS case**: There EXISTS a discriminating formula phi (holds at some point, fails at another). With Z1 in every MCS:

1. Pick discriminating phi: phi in MCS of point `a0` (orbit), neg(phi) in MCS of point `b0` (pred-chain).
2. At `a0`: `F(phi)` holds (phi at a0, and there are future points... actually F means "some future point has phi". Since a0 has phi, we need a FUTURE point with phi. Next orbit point `s(a0)` has the same phi? Not necessarily.)

Hmm, this still needs careful handling. Let me reconsider the CORRECT Doets argument:

**Doets' Claim 10 (adapted)**: Every definable bounded subset of limit_dom has a maximum.

Let S = {x in limit_dom | phi in limit_f(x)} for some formula phi. Suppose S is nonempty and bounded above (there exists y with y > x for all x in S, and neg(phi) in limit_f(y)).

Claim: S has a maximum (there exists m in S such that for all x > m, neg(phi) in limit_f(x)).

Proof using Z1:
1. Pick any m in S (so phi at m). Let n be an upper bound (neg(phi) at n, n > m).
2. Since neg(phi) at n and n > m: `F(neg phi)` at m (by `backward_F` or direct definition).
3. Since neg(phi) at n and at all points above n (by `backward_G` if G(neg phi) at n -- but we only know neg(phi) at n, not G(neg phi)):
   - Actually, we need to pick our bound more carefully. Let n be such that `G(neg phi)` at n (not just neg(phi) at n). Does such n exist? In the gap scenario with non-constant MCS: if phi holds at orbit points and neg(phi) at pred-chain points, then eventually all sufficiently large points have neg(phi), giving `G(neg phi)` at some pred-chain point by `backward_G`.
   - Specifically: if neg(phi) holds at ALL pred-chain points pred^[k](b) for k >= 0, then at pred^[1](b): neg(phi) at pred^[1](b) and at all points above pred^[1](b) in limit_dom (which are pred^[0](b) = b and above, all with neg(phi)). So `G(neg phi)` at pred^[1](b) by `backward_G`.
4. So `F(G(neg phi))` at m (by `backward_F`, since `G(neg phi)` at some point above m).
5. Also at m: `F(phi)` holds (phi at m, and there exist future orbit points with phi? Not necessarily. But phi at m itself -- F means STRICT future. If phi at some `s^[j](a) > m`, yes.)
   - Actually, m is in S, so phi at m. But F(phi) at m requires phi at some point STRICTLY AFTER m. If m is an orbit point and the next orbit point also has phi, then F(phi) at m. But we don't know this.
   - Wait: `neg(G(neg phi))` at m iff `F(phi)` at m (by definition of F as neg G neg). We have phi at m. Is `neg(G(neg phi))` at m? `G(neg phi)` at m would mean neg(phi) at all points > m. But phi at m itself doesn't help (G is strict future). However, if m = s^[j](a) and phi is also at s^[j+1](a), then phi at some point > m, so `neg(G(neg phi))` at m.
   - If phi is ONLY at m and no other point above m has phi: then G(neg phi) at m (neg phi at all strict future points). Then F(G(neg phi)) at m (since G(neg phi) at m, and m is in the strict future of earlier points... wait, F(G(neg phi)) at m means G(neg phi) at some point > m. But we have G(neg phi) at m -- does that give G(neg phi) at succ(m)? By temp_4: G(phi) -> G(G(phi)), so G(neg phi) at m -> G(G(neg phi)) at m -> G(neg phi) at all points > m. So yes, G(neg phi) at succ(m), giving F(G(neg phi)) at m.)
   - OK so either F(phi) or G(neg phi) at m (by negation_complete on G(neg phi)).

Let me just present the clean argument:

For any m in limit_dom, either `G(neg phi)` or `F(phi)` (= neg G(neg phi)) at m.

Case 1: `G(neg phi)` at m. Then neg(phi) at all points > m, so no point > m is in S. m is the maximum of S (assuming S intersects the points <= m).

Case 2: `F(phi)` at m AND `F(G(neg phi))` at m (we have FG(neg phi) because G(neg phi) holds at the upper bound n and `backward_F` gives FG(neg phi) at m).
- Z1 with `neg phi`: `G(G(neg phi) -> neg phi) -> (FG(neg phi) -> G(neg phi))`
- By modus tollens: `neg G(neg phi) ∧ FG(neg phi) -> neg G(G(neg phi) -> neg phi)`
- i.e., `F(phi) ∧ FG(neg phi) -> F(G(neg phi) ∧ phi)`
  (negating `G(G(neg phi) -> neg phi)` gives `F(neg(G(neg phi) -> neg phi))` = `F(G(neg phi) ∧ phi)`)
- So there exists k > m with `G(neg phi) ∧ phi` at k. This k has phi (so k in S) and G(neg phi) (so no point > k has phi).
- Therefore k is the maximum of S.

THIS is the Doets argument. It works for both constant and non-constant MCS cases because it's purely about limit_f membership.

For the gap scenario contradiction:
- The orbit points form an infinite set with `next_top` in every MCS. Consider using the formula `phi_gap` where we can pick phi = some formula related to the gap structure.
- Actually, the gap scenario directly contradicts the Doets maximum principle: the orbit {s^[n](a)} is an infinite set of limit_dom points where `next_top` is in every MCS (h_discrete). Consider phi = some formula that's in the MCS of ALL orbit points but fails at some pred-chain point (non-constant case) or consider the orbit itself as unbounded from above within orbit (constant case won't have a gap as argued above).

**Wait**: The gap case in `succ_cofinal` has orbit points bounded above by any pred-chain point. If we can find a phi that defines the orbit (holds at orbit points), then S = orbit is nonempty and bounded. By Doets, S has a maximum. But the orbit is infinite with no maximum (every orbit point has a successor orbit point). Contradiction.

The challenge: we need a formula phi that holds at all orbit points but fails at all pred-chain points. In the non-constant MCS case, such a discriminating phi exists. In the constant-MCS case, the gap cannot arise (as argued above).

So the proof structure in `succ_cofinal`:
1. Assume gap scenario (for contradiction).
2. Case split: constant MCS or non-constant MCS.
3. Constant MCS: derive contradiction from construction properties (the omega chain with constant MCS would not create distinct orbit/pred-chain components).
4. Non-constant MCS: find discriminating phi. Apply Doets maximum principle. Orbit is bounded and definable but has no maximum. Contradiction.

#### Detailed formalization plan for Phase 3

In ChronicleToCountermodel.lean, at line 1816 (the sorry site):

```lean
-- We are in the `else` branch: L ≤ pred(b).val
-- Contradiction via Doets maximum principle using Z1

-- Step 1: Show MCS are not all constant (or handle constant case)
-- Step 2: Find discriminating formula
-- Step 3: Show the discriminating formula defines a bounded set with no maximum
-- Step 4: Z1 + Doets gives maximum exists -> contradiction

-- For the non-constant case:
-- There exist orbit point x and pred-chain point y with different MCS
-- So there exists phi with phi ∈ limit_f(x) and phi ∉ limit_f(y)
-- (or vice versa; take negation if needed)
-- The set S = {z | phi ∈ limit_f(z)} contains x and is bounded above
-- (y is a bound, since neg(phi) ∈ limit_f(y))

-- Apply the Doets maximum principle helper lemma:
-- ∀ phi, ∀ m with phi ∈ limit_f(m), ∀ n > m with G(neg phi) ∈ limit_f(n),
--   ∃ k, phi ∈ limit_f(k) ∧ G(neg phi) ∈ limit_f(k)
-- (from Z1 + backward reasoning)

-- This k is the maximum: phi at k, neg(phi) at all points > k
-- But in the gap scenario, the orbit continues above k (succ(k) is an orbit point with phi)
-- Contradiction: phi at succ(k) but neg(phi) at succ(k) (from G(neg phi) at k)
```

**Tasks:**
- [ ] Define helper lemma `doets_maximum_principle`: for phi, m (with phi at m), n > m (with G(neg phi) at n), produce k with phi and G(neg phi) at k
- [ ] Prove the helper using Z1 in MCS + backward_F + implication_property + negation_complete
- [ ] Handle the constant-MCS case (show it cannot produce a gap)
- [ ] Handle the non-constant-MCS case using the discriminating formula + Doets
- [ ] Close the sorry at line 1816
- [ ] Verify `succ_cofinal` is sorry-free
- [ ] Verify `limitDomSubtype_isSuccArchimedean` is sorry-free

**Timing**: 2-3 hours
**Depends on**: Phase 2

---

### Phase 4: Reynolds Contemporaneous Equivalence (Fallback) [NOT STARTED]

**Goal**: If Phase 2 (Z1 derivation) proves intractable, use Reynolds 1994's alternative argument.

This phase is a FALLBACK. Only attempt if Phase 2 cannot be completed.

#### Reynolds Argument Summary

Reynolds 1994 (Section 7-8, Theorem 14) proves that in Prior structures (models satisfying Prior-UZ/SZ), contemporaneous equivalence classes don't end at gaps.

1. Define "good": a finite subinterval is k-equivalent to an interval of Z (same k-types)
2. Define "very good": every finite subinterval is good
3. Define ~M: contemporaneous equivalence (x ~ y iff for all formulas phi, phi at x iff phi at y)
4. Prove ~M classes don't end at gaps (Theorem 14, uses Prior-UZ/SZ + expressive completeness)
5. If M is not very good: ∃ a < b in different classes
6. a's class can't end at a gap, so it includes c but not c+1 (adjacent points in different classes)
7. But {c, c+1} is finite and trivially very good (2 points), so c ~ c+1 -- contradiction

**Infrastructure needed** (200-300 lines):
- Contemporaneous equivalence definition and basic properties
- "Good" and "very good" definitions
- Theorem 14 (main technical content)
- Final contradiction argument

**Tasks:**
- [ ] Define contemporaneous equivalence ~M on limit_dom
- [ ] Define "good" and "very good" predicates
- [ ] Prove Theorem 14: ~M classes don't end at gaps (using Prior-UZ/SZ)
- [ ] Prove Lemma 16: countable + very good -> isomorphic to Z-submodel
- [ ] Derive contradiction in gap scenario
- [ ] Close the sorry at line 1816

**Timing**: 4-6 hours
**Depends on**: Phase 1 (only if Phase 2 fails)

---

### Phase 5: Verification and Cleanup [NOT STARTED]

**Goal**: Verify compilation and sorry elimination downstream. Clean up dead code.

**Tasks**:
- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `succ_cofinal` -- no sorry
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `succ_embed_surjective` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry
- [ ] Grep for sorry confirms only nondense/mixed stubs remain
- [ ] Full `lake build` passes
- [ ] Remove dead code from failed approaches (stage-induction comments, convergence analysis)
- [ ] Remove or consolidate analysis comments at the sorry site

**Timing**: 0.5-1 hour
**Depends on**: Phase 3 (or Phase 4 if fallback used)

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `succ_cofinal` -- no sorry
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `succ_embed_surjective` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry
- [ ] Grep for sorry shows only nondense and mixed stubs
- [ ] Full `lake build` passes

## Artifacts & Outputs

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/12_semantic-z1-gap.md` (this file, v14)
- **Modified/created files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- Z1 derivation tree, Doets maximum principle, close sorry in `succ_cofinal`
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/12_semantic-z1-gap-summary.md` (after implementation)

## Rollback/Contingency

Theorem statements unchanged. Rollback: `git checkout` the modified files.

If Phase 2 (Z1 derivation) proves intractable:
1. **Phase 4 (Reynolds)**: Adapt Reynolds 1994 contemporaneous equivalence argument (200-300 lines, 4-6 hours)
2. **Last resort**: Leave sorry with detailed documentation and the Z1 derivation attempt preserved for future work

## Implementation Guidance for the Agent

### Phase 2 Guidance: Building the Z1 DerivationTree

**File location**: Add the Z1 derivation in ChronicleToCountermodel.lean, in a new section before `succ_cofinal` (around line 1750, after the backward_P lemma).

**Step-by-step construction approach**:

1. First, define the target formula:
```lean
/-- Z1 axiom schema: G(Gφ→φ) → (FGφ→Gφ) -/
private def z1_formula (φ : Formula) : Formula :=
  ((φ.all_future.imp φ).all_future).imp
    (φ.all_future.some_future.imp φ.all_future)
```

2. Build the derivation bottom-up. Start by placing a `sorry` at the top level and use `lean_goal` to see what's needed:
```lean
private def z1_derivation (φ : Formula) : DerivationTree [] (z1_formula φ) := by
  sorry
```

3. The derivation needs the following axiom instances:
   - `Axiom.prior_UZ (φ.all_future)` gives `⊢ F(Gφ) → U(Gφ, ¬Gφ)`
   - `Axiom.temp_4 φ` gives `⊢ Gφ → GGφ`
   - `Axiom.temp_k_dist` for distribution
   - Propositional tautologies from `Bimodal.Theorems.Propositional`

4. The key derivation structure (outline for the implementer):
   ```
   Goal: ⊢ G(Gφ→φ) → (FGφ → Gφ)
   
   By deduction theorem, suffices: [G(Gφ→φ), FGφ] ⊢ Gφ
   
   From FGφ, by Prior-UZ(Gφ): get U(Gφ, ¬Gφ)
   U(Gφ, ¬Gφ) means: ∃ s > t with Gφ at s, ¬Gφ at all r ∈ (t,s)
   
   From Gφ at s and G(Gφ→φ):
     - Gφ at s → GGφ at s (by temp_4)
     - G(Gφ→φ) at t → G(Gφ→φ) at s (by temp_4 on the hypothesis)
     - G(Gφ→φ) at s + GGφ at s → Gφ at s (by temp_k_dist)
     - Wait, this is circular. We already have Gφ at s.
   
   The key: G(Gφ→φ) + Gφ at s → φ at s (by the hypothesis applied at s).
   And Gφ at s → φ at all r > s.
   And G(Gφ→φ) → at all r > t, Gφ→φ at r.
   Combined with Gφ at s: φ at s and at all r > s.
   
   Now for r ∈ (t,s): ¬Gφ at r (from Until guard).
   But do we need φ at r? Not directly.
   
   Actually we need to show Gφ at t. For Gφ at t: φ at all r > t.
   - For r > s: φ at r (from Gφ at s).
   - For r = s: φ at s (from G(Gφ→φ) at s + Gφ at s).
   - For r ∈ (t,s): need φ at r.
   
   For r ∈ (t,s): ¬Gφ at r means ∃ q > r with ¬φ at q.
   But from G(Gφ→φ) at r: (Gφ→φ) at r, so if Gφ at r then φ at r.
   We have ¬Gφ at r (from guard), but G(Gφ→φ) is at ALL points > t.
   
   This looks like it needs induction over the discrete points in (t,s).
   In the formal derivation, this is encoded using Until/Since reasoning.
   
   ALTERNATIVE: Work contrapositively.
   
   Z1 contrapositive: ¬Gφ ∧ FGφ → ¬G(Gφ→φ)
   i.e., Fφ' ∧ FGφ → F(Gφ ∧ φ')  where φ' = ¬φ
   i.e., ¬Gφ ∧ FGφ → F(Gφ ∧ ¬Gφ) -- but that's contradictory.
   
   Hmm wait. ¬G(Gφ→φ) = F(¬(Gφ→φ)) = F(Gφ ∧ ¬φ).
   So: ¬Gφ ∧ FGφ → F(Gφ ∧ ¬φ).
   
   That says: if F(¬φ) (since ¬Gφ = F(¬φ)) and FGφ, then F(Gφ ∧ ¬φ).
   This is: there exists a point where both Gφ and ¬φ hold.
   
   Proof of this: From FGφ, by Prior-UZ: U(Gφ, ¬Gφ). 
   From U(Gφ, ¬Gφ): either Gφ now (then Gφ ∧ maybe ¬φ), or F(Gφ) with guard.
   The event point s has Gφ. If ¬φ at s, done (F(Gφ ∧ ¬φ) witnessed at s).
   If φ at s: then from ¬Gφ at t: F(¬φ) at t. Some point r > t has ¬φ.
   If r < s: by Until guard, ¬Gφ at r. Since ¬φ at r and r < s, and Gφ at s → φ at all q > s.
   But ¬Gφ at r means ∃ q > r with ¬φ at q. q could be in (r,s) or beyond s.
   If q > s: ¬φ at q contradicts Gφ at s (φ at q). So q ∈ (r,s).
   Continue: ¬Gφ at q (by guard), ¬φ somewhere in (q,s), etc.
   In the DISCRETE case with finitely many points in (t,s), this terminates.
   
   The FORMAL derivation doesn't reason about points -- it manipulates formulas.
   ```

5. **Practical advice**: Rather than trying to construct the full DerivationTree manually, consider:
   - Using `Bimodal.Metalogic.Core.deduction_theorem` to convert between `[hyp] ⊢ concl` and `⊢ hyp → concl`
   - Building the proof in contextual form first (`[G(Gφ→φ), FGφ] ⊢ Gφ`), then apply deduction theorem twice
   - Using `lean_goal` extensively to see what the type checker expects

6. **If the full general derivation is too hard**: Consider deriving Z1 for a specific formula instance that suffices for the gap elimination. Since the Doets argument uses Z1 with a specific discriminating formula, we only need one instance.

### Phase 3 Guidance: Doets Maximum Principle

**Location**: At the sorry site, line 1816 in `succ_cofinal`.

**Helper lemma** (define before `succ_cofinal`):

```lean
/-- Doets maximum principle: if φ holds at m and G(¬φ) holds at some n > m,
    then there exists k with φ at k and ¬φ at all points above k. -/
private lemma doets_maximum
    (φ : Formula) (m n : LimitDomSubtype A h_mcs) (hmn : m < n)
    (h_phi_m : φ ∈ limit_f A h_mcs m.val)
    (h_Gneg_n : φ.neg.all_future ∈ limit_f A h_mcs n.val) :
    ∃ k : LimitDomSubtype A h_mcs, 
      φ ∈ limit_f A h_mcs k.val ∧ 
      φ.neg.all_future ∈ limit_f A h_mcs k.val := by
  -- By negation_complete on G(¬φ) at m:
  -- Case 1: G(¬φ) at m → k := m (but φ at m and ¬φ at m → contradiction, unless...)
  -- Actually G(¬φ) at m means ¬φ at all points > m, not at m itself.
  -- So φ at m and G(¬φ) at m is consistent.
  -- In that case k := m works.
  
  -- Case 2: ¬G(¬φ) at m, i.e. F(φ) at m.
  -- Also F(G(¬φ)) at m (since G(¬φ) at n > m, backward_F gives F(G(¬φ)) at m).
  -- Z1 with ¬φ: G(G(¬φ)→¬φ) → (FG(¬φ) → G(¬φ)).
  -- Modus tollens: ¬G(¬φ) ∧ FG(¬φ) → ¬G(G(¬φ)→¬φ).
  -- ¬G(G(¬φ)→¬φ) = F(G(¬φ) ∧ φ).
  -- So ∃ k > m with G(¬φ) at k and φ at k.
  sorry
```

**At the sorry site (line 1816)**: Use doets_maximum + discriminating formula to derive contradiction.

```lean
-- In the gap scenario:
-- 1. MCS are not all constant (argue from construction properties), OR
-- 2. Find discriminating φ between orbit and pred-chain points
-- 3. S = {x | φ ∈ limit_f(x)} is bounded above, contains orbit points
-- 4. doets_maximum gives k with φ and G(¬φ) at k
-- 5. k is the maximum of S (φ at k, ¬φ at all above)
-- 6. But succ(k) is also in S (orbit continues), contradiction
```

**Key available lemmas**:
- `backward_G`: φ at all y > x → G(φ) at x
- `backward_F`: φ at y, y > x → F(φ) at x
- `limit_F_resolution`: F(φ) at x → ∃ y > x, φ at y
- `theorem_in_mcs h_mcs d`: derivable φ → φ ∈ MCS
- `SetMaximalConsistent.implication_property`: φ→ψ ∈ S, φ ∈ S → ψ ∈ S
- `SetMaximalConsistent.negation_complete`: φ ∈ S ∨ ¬φ ∈ S
- `set_consistent_not_both`: ¬(φ ∈ S ∧ ¬φ ∈ S) when S consistent

### General Notes

- Use `Classical.em`, `by_contra`, `Classical.choice` freely
- The code is already in a noncomputable section
- `lean_goal` at every step to see what the type checker expects
- Test partial results with `lean_verify` frequently
- If the derivation tree approach gets stuck, insert a focused `sorry` and move on to Phase 3 to test the overall structure
