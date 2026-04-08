# Teammate C: Critical Analysis of BXCanonical Completeness Approaches

## Sorry Census

### BXCanonical Path (5 executable sorry sites)

| # | File | Line | Definition | Dependency |
|---|------|------|-----------|------------|
| 1 | Frame.lean | 562 | `bx_until_eventuality_resolution` | Root blocker |
| 2 | Frame.lean | 584 | `bx_until_backward` | Root blocker |
| 3 | Frame.lean | 599 | `bx_since_eventuality_resolution` | Mirror of #1 |
| 4 | Frame.lean | 613 | `bx_since_backward` | Mirror of #2 |
| 5 | Completeness.lean | 144 | `bx_completeness` | Downstream of #1-4 |

**Dependency structure**: Sorry #5 (completeness) is downstream of all four Frame.lean sorries. The TruthLemma calls the Frame.lean helpers; completeness calls the TruthLemma. The four Frame.lean sorries are the ROOT cause. Sorries #3-4 are exact mirrors of #1-2 (Since vs Until). So the problem reduces to TWO independent proof obligations:

- **Forward eventuality resolution**: `phi U psi in w, psi not in w` implies there exists `v >= w` with `psi in v` and guard `phi` on `[w, v)`.
- **Backward Until**: Given a semantic witness `v >= w` with `psi in v` and guard, derive `phi U psi in w`.

### Bundle/Algebraic Path (NOT part of BXCanonical; separate sorry sites)

| File | Line | Note |
|------|------|------|
| Bundle/CanonicalFrame.lean | 259 | `temp_4` sorry (BXCanonical uses temp_4 directly as axiom, unaffected) |
| Bundle/WitnessSeed.lean | 450, 569 | `until_induction` / `since_induction` removed in BX |
| Bundle/SuccRelation.lean | 548 | `until_persists_through_succ` (X-content propagation) |
| Algebraic/InteriorOperators.lean | 83 | `temp_k_dist` sorry |
| Algebraic/DovetailedChain.lean | 648, 898, 953, 1016, 1112, 1125, 1297, 1305 | All DEPRECATED |
| Algebraic/TenseS5Algebra.lean | 195, 278, 320 | `temp_a`, `temp_l` removed in BX |

These are all in the old Bundle/Algebraic path, not the BXCanonical path. They are irrelevant to the BXCanonical approach.

### FMP Path (0 sorry sites)

Zero sorries found in `Theories/Bimodal/Metalogic/Decidability/` and all FMP submodules. The entire FMP infrastructure compiles sorry-free.

### Soundness (0 sorry sites)

`Theories/Bimodal/Metalogic/Soundness.lean` is completely sorry-free.

---

## bx_le Redefinition Assessment

### What bx_le Currently Does

`bx_le w v := g_content w.formulas subset v.formulas`

This means: `w <= v` iff for all `phi`, `G(phi) in w` implies `phi in v`. This is the standard "universal future" ordering from Goldblatt/Burgess canonical models.

### What Breaks If Redefined

The truth lemma for G and H (`G_iff_mcs`, `H_iff_mcs` in TruthLemma.lean) depends directly on bx_le being defined via g_content. These proofs work because:

- **G forward**: `G(phi) in w` and `g_content(w) subset v` directly gives `phi in v`.
- **G backward**: Constructs a seed `{neg phi} union g_content(w)` and shows consistency. This uses g_content closure properties.

If bx_le is redefined via Until-witness ordering, the G/H truth lemma would need to be reproved. Specifically:

1. **bx_le_refl** (uses BX1: `G(phi) -> phi`) -- would need: Until-ordering is reflexive.
2. **bx_le_trans** (uses temp_4: `G(phi) -> G(G(phi))`) -- would need: Until-ordering is transitive.
3. **bx_G_forward** (direct from g_content definition) -- would need: a NEW proof that `G(phi) in w` and `w <= v` (Until-ordering) implies `phi in v`.
4. **bx_G_backward** -- would need: a NEW consistency argument using Until-witness seeds instead of g_content seeds.
5. **bx_H_forward/backward** -- dual, same issue.

**Verdict**: Redefining bx_le is a MAJOR structural change that invalidates the 300+ lines of proved G/H/Box infrastructure. The cost is extremely high.

### Could We Add a Parallel Ordering?

Instead of replacing bx_le, we could add `bx_until_le` for Until-witness ordering and keep bx_le for G/H. The question is: what is the relationship?

**Mathematical relationship**:
- `bx_le w v` (g_content ordering) means: every formula that always holds at w also holds at v. This is a WEAK relation: many MCS pairs are bx_le-related.
- An Until-witness ordering would be STRONGER: it would capture the specific temporal succession of eventuality witnesses.

The problem is that the truth lemma for Until needs BOTH:
- The g_content ordering (for the G/H cases that feed into Until's guard)
- The Until-witness ordering (for the eventuality resolution)

These would need to be COMPATIBLE: if `bx_until_le w v` then also `bx_le w v`. The question is whether this can be guaranteed.

**BX4 (connect_future)**: `phi -> G(P(phi))`. This says: if phi holds now, then at all future times, P(phi) holds. This connects the g_content world (G) with the Until/Since world (P). It suggests g_content ordering and temporal ordering are compatible but does NOT prove they coincide.

**BX7 (linearity)**: Until witnesses are linearly ordered. But this is about ordering WITHIN the Until-witness world, not about the g_content ordering.

**Assessment**: A dual-ordering approach is theoretically possible but adds significant complexity. The two orderings must be shown compatible, and the Until truth lemma must be restated in terms of the combined structure. This is not simpler than the current approach.

---

## FMP Bridge Assessment

### What FMP Proves

`fmp_contrapositive` (FMP.lean line 206):
```
theorem fmp_contrapositive (phi : Formula)
    (h_all_mcs : forall (S : ClosureMCSBundle phi), phi in S.carrier) :
    Nonempty (DerivationTree [] phi)
```

This says: if phi is a member of every closure MCS for phi, then phi is provable.

### What Completeness Needs

`bx_completeness` (Completeness.lean line 124):
```
theorem bx_completeness (phi : Formula) :
    valid phi -> Nonempty (DerivationTree [] phi)
```

### The Gap

The bridge requires:
```
valid phi -> forall (S : ClosureMCSBundle phi), phi in S.carrier
```

This is a TRUTH LEMMA for closure MCS: if phi is valid (true in ALL models), then phi is in every closure MCS. The standard approach is:

1. Embed each closure MCS into a finite TaskModel (constructing a concrete model).
2. Show the truth lemma: membership in the MCS = truth in the model.
3. Since phi is valid, phi is true in this model, hence phi is in the MCS.

**Hidden obstacle**: The FMP filtration approach constructs `FilteredWorld phi` as a quotient type and proves finiteness. But TruthPreservation.lean (lines 7-37) explicitly states: "The full filtration lemma proof for all formula cases (atom, bot, imp, box, past, future) requires additional work on modal/temporal MCS properties."

So the truth preservation lemma -- the key ingredient linking MCS membership to model truth -- is NOT complete. It is infrastructure-only (definitions and basic lemmas for bot/negation).

### Detailed Obstacle Analysis

1. **No sorry sites but incomplete coverage**: The FMP path has 0 sorries because it states results about MCS membership directly (`phi in S.carrier`) rather than about semantic truth. The bridge to `valid phi` requires connecting MCS membership to semantic truth, which is exactly what TruthPreservation aims to do but has not finished.

2. **Model construction gap**: There is no concrete `TaskModel` built from `FilteredWorld`. The types `BundledFilteredFrame` and `filteredFiniteFrame` exist (FMP.lean lines 157-167) but the actual model (valuation function, world histories) is not constructed.

3. **Until/Since in filtered model**: Even if the model were constructed, the Until/Since truth lemma would require showing that the filtered ordering correctly captures Until witness structure. This is the SAME fundamental problem as in BXCanonical: the Until truth lemma is the hard part.

### Honest Assessment of FMP Path

The FMP path has zero sorry sites because it operates entirely at the MCS-membership level. It proves: "not provable implies exists closure MCS not containing phi." This is essentially the Lindenbaum lemma restricted to closure. It does NOT prove anything about semantic models.

To bridge FMP to `valid phi -> provable phi`, you need a semantic embedding of closure MCS into actual TaskModels. This requires:
- Constructing a concrete TaskModel from closure MCS data
- Proving truth preservation (the same hard problem as the BXCanonical truth lemma)
- Handling Until/Since (the same fundamental obstacle)

**The FMP path does not avoid the Until/Since problem. It merely defers it to a different stage.**

---

## Novel Approaches

### Approach 1: Direct Proof of Frame.lean Sorries Without Redefining bx_le

The key question is: can we prove `bx_until_eventuality_resolution` using the EXISTING g_content-based `bx_le` and the BX axioms?

**Available tools**:
- BX5 (self-accumulation): `phi U psi -> (phi and (phi U psi)) U psi`
- BX6 (absorption): `phi U (phi and (phi U psi)) -> phi U psi`
- BX7 (linearity): Until witnesses are linearly ordered
- BX9 (elimination): `phi U psi -> phi or psi`
- BX10 (eventuality): `phi U psi -> F(psi)`
- BX4 (connectedness): `phi -> G(P(phi))`

**The core difficulty re-examined**: `phi U psi in w` and `psi not in w`. By BX9, `phi in w`. By BX10, `F(psi) in w`, so there exists `v >= w` with `psi in v` (via `bx_forward_witness`).

The guard condition requires: for all `u` with `w <= u < v`, `phi in u`. The problem is that an arbitrary `u` with `bx_le w u` might have nothing to do with the Until witness `v`.

**Attempted novel argument using BX4+BX5**:

1. From `phi U psi in w`, get `(phi and (phi U psi)) U psi in w` by BX5.
2. From BX4 applied to `phi U psi in w`: `G(P(phi U psi)) in w`.
3. For any `u` with `bx_le w u`: `P(phi U psi) in u` (by step 2).
4. So there exists `u' <= u` with `phi U psi in u'`.
5. By BX9 on `u'`: `phi or psi in u'`.

But we need `phi in u`, not `phi in u'`. And `u'` might equal `u` (if `bx_le u u'`), but we cannot conclude this. The g_content ordering does not give us `u' = u`.

**The fundamental gap**: g_content ordering says "all G-formulas transfer." But `phi U psi` is NOT a G-formula. So `phi U psi in w` does NOT imply `phi U psi in u` for `bx_le w u`. The axiom system gives us `G(P(phi U psi)) in w`, which means `P(phi U psi) in u`, but P gives us a BACKWARD witness `u'`, and we lose control of where `u'` is.

**Can BX7 help?** BX7 says that if `alpha U beta` and `gamma U delta` both hold, their witnesses are ordered. But we need ordering of POINTS, not just Until witnesses. The linearity of Until witnesses does not directly give linearity of the g_content ordering between two arbitrary points.

**Conclusion**: A direct proof using the existing bx_le appears genuinely blocked. The g_content ordering is too coarse to capture the temporal succession structure needed for the Until guard. This is not a gap in ingenuity but a structural mismatch in the definitions.

### Approach 2: Algebraic Completeness via Lindenbaum Algebra

Could we prove completeness algebraically by showing the Lindenbaum algebra of provable equivalence classes is representable as a bimodal algebra?

**Assessment**: The codebase already has `Algebraic/TenseS5Algebra.lean` and `Algebraic/InteriorOperators.lean`, but both have sorry sites related to removed BX axioms (`temp_a`, `temp_l`, `temp_k_dist`). The algebraic path was attempted and abandoned due to the BX refactoring removing several axioms. Furthermore, algebraic completeness for temporal logic with Until/Since is considerably harder than for pure tense logic (G/H only), because Until/Since are not standard interior/closure operators.

**Verdict**: Not viable without major new development. The existing algebraic infrastructure is stale and incomplete.

### Approach 3: Bootstrapping from Soundness

Soundness gives: `provable phi -> valid phi`. Could we use this for completeness?

Completeness is the CONVERSE: `valid phi -> provable phi`. Soundness alone cannot establish its converse. However, soundness + decidability = completeness (if the logic is decidable and sound, then completeness follows: if phi is valid and not provable, then by decidability, `neg phi` is provable, then by soundness, `neg phi` is valid, contradicting `phi` valid).

The decidability path (`Decidability/DecisionProcedure.lean`) exists. If decidability is sorry-free, then soundness + decidability gives completeness.

**Checking decidability**:

This requires investigation. The FMP is sorry-free and provides finite model size bounds. If the decision procedure is also sorry-free, this is a viable route.

### Approach 4: Fragment Completeness

Prove completeness for the G/H fragment (without Until/Since), then extend.

**Assessment**: The G/H truth lemma is ALREADY complete in the BXCanonical path. `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs` are all proved. The ONLY remaining obstacle is Until/Since. So "fragment completeness" for G/H/Box is essentially done modulo the model embedding (sorry #5 in Completeness.lean).

This is actually a useful observation: completeness for the {bot, imp, box, G, H}-fragment could be stated and proved NOW by:
1. Restricting `valid` to this fragment
2. Using the existing MCS truth lemma (which is complete for these connectives)
3. Constructing a canonical model WITHOUT Until/Since

This would give a PARTIAL result that has independent mathematical value and could serve as a stepping stone.

**Difficulty**: The model construction (sorry #5) is the same gap. We still need to embed BXPoints into a TaskModel. But for the G/H/Box fragment, we do NOT need Until/Since truth, so the Until/Since frame sorries (#1-4) are irrelevant.

---

## Cross-Approach Comparison

| Criterion | BXCanonical (bx_le redefine) | FMP Bridge | Fragment Completeness | Decidability Route |
|-----------|------------------------------|------------|----------------------|-------------------|
| Root sorry count | 2 (Until fwd/bwd) | 0 explicit, but needs new code | 1 (model embedding) | Needs investigation |
| Avoids Until problem? | No | No (deferred) | YES | Possibly (if decidable) |
| New code needed | ~200 lines redefine + re-prove | ~500+ lines model construction + truth preservation | ~150 lines model construction | ~100 lines composition |
| Risk of failure | HIGH (G/H re-proof might break) | MEDIUM (truth preservation for Until is hard) | LOW (only needs G/H model) | LOW-MEDIUM (depends on decidability status) |
| Mathematical value | Full completeness | Full completeness | Partial completeness | Full completeness |

---

## Confidence Levels

| Approach | Confidence of Success | Timeline | Risk |
|----------|----------------------|----------|------|
| Direct proof (no redefine) | **5%** | N/A | Structurally blocked |
| bx_le redefinition | **25%** | 3-5 tasks | High: breaks G/H infrastructure |
| FMP bridge | **30%** | 3-4 tasks | Medium: truth preservation for Until still needed |
| Fragment completeness (G/H/Box) | **80%** | 1-2 tasks | Low: avoids Until entirely |
| Decidability route | **60%** if decidability is sorry-free | 1-2 tasks | Medium: needs decidability audit |
| Algebraic route | **10%** | 5+ tasks | High: stale infrastructure |

---

## Recommendation

### Primary: Fragment Completeness (G/H/Box)

The highest-confidence, lowest-risk path is to prove completeness for the temporal-modal fragment WITHOUT Until/Since. This:

1. Requires only the model embedding (sorry #5), not the Until/Since eventuality resolution (sorries #1-4).
2. Has the G/H/Box truth lemma already proved.
3. Has independent mathematical value.
4. Can be stated as a theorem about the sublanguage.

### Secondary: Investigate Decidability Route

If the decision procedure in `Decidability/DecisionProcedure.lean` is sorry-free, then `soundness + decidability` gives full completeness as a corollary. This avoids the canonical model construction entirely.

### Tertiary: FMP Bridge for Full Completeness

For full completeness (including Until/Since), the FMP bridge is the best long-term path, but it requires completing the truth preservation lemma for Until/Since in filtered models, which is a non-trivial research problem.

### DO NOT Pursue

- **bx_le redefinition**: Too destructive to existing infrastructure, uncertain payoff.
- **Direct proof of Frame.lean sorries**: Structurally blocked by g_content/Until mismatch.
- **Algebraic route**: Stale infrastructure, high cost, uncertain feasibility.
