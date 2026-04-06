# Teammate A Findings: Can Until Define "Durations" That Overcome the Transfer Lemma Gap?

**Task**: 83 -- Close Restricted Coherence Sorries
**Focus**: Until as duration, task semantics structure, seed enhancement, inductive tracking, Until Induction axiom
**Date**: 2026-04-05

---

## Key Findings

### 1. Until as Duration: Formalization and Limitations

The formula `phi U psi` naturally defines a duration: the interval `[t+1, s)` where `phi` holds, terminated by `psi` at time `s`. We can formalize:

```
Duration(phi, psi, M) := { M is an MCS with (phi U psi) in M }
```

A "duration" is not a single object but a *commitment* carried by an MCS -- a promise that `psi` will eventually hold, with `phi` holding in the interim. The question is whether treating this as a first-class tracking object helps the chain construction.

**Finding**: Durations cannot be tracked through Lindenbaum extensions without solving the same fundamental problem. The duration `D = (phi U psi)` at step `n` guarantees `X(psi or (phi and D))` via Until Unfold. This X-formula lands in `x_content(M_n)`. But `M_{n+1}` in the dovetailed chain is a Lindenbaum extension of `{target} union temporal_box_g_seed(M_n)`, which contains `g_content(M_n)` but NOT `x_content(M_n)`. The duration concept, however elegant, does not change the X-vs-G mismatch.

**The core issue restated**: A "duration" is an X-local property (it unfolds one step at a time via X), whereas the dovetailed chain's propagation mechanism is G-global (it inherits formulas under G). No amount of repackaging the concept of duration changes this mismatch.

### 2. Task Semantics Advantages: What Is Unique Here

The MCSes in the dovetailed chain are not arbitrary -- they are constructed by Lindenbaum extension from specific seeds. This gives several structural properties:

**(a) Seed membership is guaranteed**: `M_{n+1}` is guaranteed to contain everything in `{target} union temporal_box_g_seed(M_n)`. This is the entry point for any solution.

**(b) G-liftability of seed elements**: Every element `x` of `temporal_box_g_seed(M_n)` satisfies `G(x) in M_n`. This is the consistency proof mechanism: if `L subset seed` derives `bot`, then G-lifting gives `G(bot) in M_n`, contradicting `F(target) in M_n`.

**(c) The Lindenbaum extension is maximal**: `M_{n+1}` is an MCS, so it decides every formula. If we could show `neg(top U psi)` is inconsistent with the seed, the Lindenbaum extension would have to include `(top U psi)`.

**(d) The Succ relation structure**: The `Succ` relation (SuccRelation.lean) requires both `g_content(u) subset v` AND `f_content(u) subset v union f_content(v)`. The second condition -- the F-step condition -- is exactly what the deferral disjunction seed approach uses. This suggests the dovetailed chain could be enhanced with F-deferral disjunctions.

**Critical observation**: The Succ relation's F-step condition `f_content(u) subset v union f_content(v)` is proved via deferral disjunctions `{phi or F(phi) | F(phi) in u}` included in the seed. The consistency proof for this seed in `SuccExistence.lean` is currently BLOCKED under strict semantics (it requires `g_content(u) subset u`, which needs the T-axiom). However, the `temporal_theory_witness_with_g_exists` approach avoids this by using G-wrapping instead.

### 3. Until-Based Seed Enhancement: The Precise Obstruction

The proposal: define an enhanced seed
```
enhanced_seed(M_n) = temporal_box_g_seed(M_n)
                   union { psi or (top U psi) | (top U psi) in M_n, psi not in M_n }
```

The deferral disjunction `psi or (top U psi)` is included so that the Lindenbaum extension must contain either `psi` (resolving the Until) or `(top U psi)` (preserving it).

**Consistency proof attempt**: Suppose `L subset {target} union enhanced_seed(M_n)` with `L |- bot`. Partition L into:
- `L_g`: elements from `temporal_box_g_seed(M_n)` -- these are G-liftable
- `L_d`: elements of the form `psi_i or (top U psi_i)` -- deferral disjunctions

**Case 1**: `L_d` is empty. Then `L subset {target} union temporal_box_g_seed(M_n)`, and the standard G-lift argument (already proven in `temporal_theory_witness_with_g_consistent`) gives a contradiction.

**Case 2**: `L_d` is nonempty. Write `L_d = {d_1, ..., d_k}` where `d_i = psi_i or (top U psi_i)`. From `L_g union L_d union {target} |- bot`, we can use propositional reasoning to get:
```
L_g union {target} |- neg(d_1 and ... and d_k)
```
i.e., `L_g union {target} |- neg(d_1) or ... or neg(d_k)`.

Now `neg(d_i) = neg(psi_i or (top U psi_i)) = neg(psi_i) and neg(top U psi_i)`.

So some `neg(d_i)` is implied, meaning `neg(psi_i) and neg(top U psi_i)` is implied. This gives `L_g union {target} |- neg(top U psi_i)` for at least one `i`.

Extracting target: `L_g |- target -> neg(top U psi_i)` or `L_g |- neg(target) or neg(top U psi_i)`.

Actually, the argument is more subtle. We need to extract the target dependence. Two sub-cases:

**Sub-case 2a**: `target not in L`. Then `L subset temporal_box_g_seed(M_n) union L_d`, and we have `L_g union L_d |- bot`. By propositional reasoning, for each assignment of `d_j`, at least one branch leads to contradiction with `L_g`. Since `d_j = psi_j or (top U psi_j)`, we try both branches. In the branch where all `d_j` resolve to `(top U psi_j)`, we need `L_g union {(top U psi_1), ..., (top U psi_k)} |- bot`.

G-lifting `L_g` gives `G(neg of conjunction of (top U psi_i)) in M_n`. But this gives `G(neg(top U psi_i)) in M_n` for some `i`, which does NOT contradict `(top U psi_i) in M_n` under strict semantics (G excludes the present).

**This is exactly the obstruction identified in report 20, Section 5.4.** The G-lift argument produces `G(neg(top U psi_i)) in M_n`, and under strict semantics this coexists with `(top U psi_i) in M_n`.

**Sub-case 2b**: `target in L`. Then the deduction theorem gives `L \ {target} |- neg(target)`, and the analysis proceeds similarly but with `neg(target)` mixed into the formula. The G-lift still produces a G-wrapped negation that does not contradict the positive formula at the current time.

**Conclusion**: The enhanced seed with deferral disjunctions has the same consistency proof failure as the direct enhancement. The deferral disjunctions `psi_i or (top U psi_i)` are not G-liftable, because neither `G(psi_i)` nor `G(top U psi_i)` is guaranteed to be in `M_n`.

### 4. A Potential Bypass: Derivability of Deferral Disjunctions from G-Content

**Key question**: Is `psi or (top U psi)` derivable from `g_content(M_n)`?

If `(top U psi) in M_n`, then by F_until_equiv (reverse direction): `F(psi) in M_n`. So `neg(G(neg(psi))) in M_n`, meaning `G(neg(psi)) not in M_n`.

Now consider: is `psi or F(psi)` derivable from anything in g_content? We have `F(psi) in M_n`, so `neg(G(neg(psi))) in M_n`. But `F(psi)` is NOT the same as `G(F(psi))`. We do NOT have `G(F(psi)) in M_n` in general. The formula `F(psi) -> G(F(psi))` (i.e., `neg(G(neg(psi))) -> G(neg(G(neg(psi))))`) is NOT derivable -- it would require that "if psi holds at some future time, then at all future times, psi holds at some (further) future time." This is semantically false (psi could hold at exactly one future time).

**However**, there is a partial result: if `G(top U psi) in M_n`, then `(top U psi) in g_content(M_n) subset M_{n+1}`, and we are done. The question is: when does `G(top U psi)` hold?

`G(top U psi)` at time `t` means: for all `s > t`, `(top U psi)` holds at `s`. Semantically, this requires that at every future time, psi will eventually be true at some even later time. This is strictly stronger than `(top U psi)` at `t`, which only requires psi to hold at some `s > t`.

**The formula `G(top U psi)` is equivalent to `G(F(psi))`** (since `top U psi` iff `F(psi)` by F_until_equiv). And `G(F(psi))` means "psi occurs infinitely often" in the standard sense. This is a much stronger property than `F(psi)`.

### 5. Until Induction Axiom: Can It Help?

The Until Induction axiom:
```
G(psi -> chi) and G((phi and X(chi)) -> chi) -> ((phi U psi) -> X(chi))
```

For `phi = top`, this becomes:
```
G(psi -> chi) and G((top and X(chi)) -> chi) -> ((top U psi) -> X(chi))
```

Simplifying `top and X(chi) = X(chi)`:
```
G(psi -> chi) and G(X(chi) -> chi) -> ((top U psi) -> X(chi))
```

**Instantiation 1**: Set `chi = (top U psi)`. Then:
- Premise 1: `G(psi -> (top U psi))` -- This requires that `psi` at any future time implies `top U psi` there. But `psi` at time `s` does NOT imply `top U psi` at time `s` (psi might not hold at any `s' > s`). This premise is **not provable** in general.

**Instantiation 2**: Set `chi = psi or (top U psi)`. Then:
- Premise 1: `G(psi -> (psi or (top U psi)))` -- This IS provable (left disjunction introduction, under G by necessitation).
- Premise 2: `G(X(psi or (top U psi)) -> (psi or (top U psi)))` -- This says: if at the next time we have `psi or (top U psi)`, then currently we have `psi or (top U psi)`. Under strict semantics, `X(alpha) -> alpha` is NOT valid (no T-axiom for X). So premise 2 is **not provable**.

**Instantiation 3**: Set `chi = F(psi)`. Then:
- Premise 1: `G(psi -> F(psi))` -- Under strict semantics, `psi -> F(psi)` is NOT valid. `F(psi) = neg(G(neg(psi)))` says psi holds at some *strictly* future time. Having psi now does not mean psi holds at a strictly future time. **Not provable.**

If we had reflexive semantics, instantiation 3 would work beautifully: `psi -> F(psi)` would be trivially true, and `X(F(psi)) -> F(psi)` would also hold. This is precisely the "T-axiom safety net" that strict semantics removes.

**Conclusion on Until Induction**: All natural instantiations fail under strict semantics. The axiom produces `X(chi)` as output, which would land in `x_content` -- the right place for the deterministic chain but the wrong place for the dovetailed chain.

### 6. Inductive Duration Tracking: A Formal Framework

Define the **active Until set** at step `n`:
```
AU(n) = { psi | (top U psi) in M_n and psi not in M_n }
```

Properties we need:
- **Resolution**: If `schedule_formula(n) = psi` and `psi in AU(n)` and `F(psi) in M_n`, then `psi in M_{n+1}` (by construction of forward_step).
- **Persistence**: If `psi in AU(n)` and `psi not in AU(n+1)` implies either `psi in M_{n+1}` (resolution) or `psi not in AU(n+1)` because `(top U psi) not in M_{n+1}` (loss).

The problem is preventing "loss" -- we need `(top U psi) in M_{n+1}` whenever it was in `M_n` and `psi` has not yet appeared.

**What inductive tracking gives us**: At step `n`, we know `(top U psi) in M_n`. Until Unfold gives `X(psi or (top U psi)) in M_n`, so `psi or (top U psi) in x_content(M_n)`. The chain step gives `g_content(M_n) subset M_{n+1}`. We need to show `(top U psi) in M_{n+1}` or `psi in M_{n+1}`.

The inductive tracker adds no new information beyond what Until Unfold already provides. The tracking is already implicit in the chain.

### 7. The Succ Deferral Seed as Inspiration: A New Seed Design

The Succ existence proof (SuccExistence.lean) uses a seed that includes **deferral disjunctions**:
```
g_content(u) union { phi or F(phi) | F(phi) in u }
```

Each `phi or F(phi)` ensures the MCS either resolves or defers the F-obligation. The consistency proof requires `g_content(u) subset u` (the T-axiom), which fails under strict semantics.

**However**, the `temporal_theory_witness_with_g_exists` approach uses a different consistency technique: the G-wrapping argument. The question is whether we can combine G-wrapping with deferral disjunctions.

**Proposed seed for combined approach**:
```
combined_seed(M_n, target) = {target}
  union G_theory(M_n)
  union box_theory(M_n)
  union g_content(M_n)
  union { psi or (top U psi) | (top U psi) in M_n, psi not in M_n }
```

The first four components form `{target} union temporal_box_g_seed(M_n)`, whose consistency is proven by G-wrapping.

Adding the fifth component (deferral disjunctions for Until) breaks the G-wrapping argument because `G(psi or (top U psi))` is not guaranteed to be in `M_n`.

**But wait**: each deferral disjunction `d_i = psi_i or (top U psi_i)` IS derivable from `x_content(M_n)`. Specifically, `d_i in x_content(M_n)` because Until Unfold gives `X(d_i) in M_n` (since `(top U psi_i) in M_n`). And `x_content(M_n)` is an MCS.

**So `x_content(M_n)` is a consistent set containing ALL of `g_content(M_n)` (since `g_content subset x_content`) AND all deferral disjunctions.** If `target in x_content(M_n)`, we could just use `x_content(M_n)` directly. But `target` might not be in `x_content(M_n)`.

**Key lemma needed**: Is `{target} union x_content(M_n)` consistent when `F(target) in M_n`?

`x_content(M_n)` is an MCS, so `{target} union x_content(M_n)` is consistent iff `neg(target) not in x_content(M_n)` iff `X(neg(target)) not in M_n`. But we only know `F(target) = neg(G(neg(target))) in M_n`, which says `G(neg(target)) not in M_n`. This does NOT imply `X(neg(target)) not in M_n`. In fact, `F(target)` can coexist with `X(neg(target))` (target might not hold at the next step but does hold at some further future step).

**So `{target} union x_content(M_n)` is NOT necessarily consistent.** The G-wrapping argument works for `temporal_box_g_seed` precisely because G-wrapping gives `G(neg(target))`, which contradicts `F(target)`. X-wrapping would give `X(neg(target))`, which does NOT contradict `F(target)`.

### 8. The Fundamental Impossibility for Seed-Based Approaches

Collecting all the above analysis, the obstruction can be stated precisely:

**Theorem (informal)**: No seed-based Lindenbaum approach can simultaneously:
1. Include a resolution target `target` where `F(target) in M_n` but possibly `X(neg(target)) in M_n`
2. Include Until obligations `(top U psi_i)` where `G(top U psi_i)` is not in `M_n`
3. Prove consistency via any lifting argument available in the proof system

The reason: the only lifting arguments available are:
- **G-lift**: Produces `G(neg(alpha)) in M_n`, contradicts `F(alpha) in M_n`. Works for (1) but not (2).
- **X-lift**: Produces `X(neg(alpha)) in M_n`, does NOT contradict `F(alpha)` or `(top U alpha)`.
- **No lift**: Without any lift, there is no way to derive a contradiction in `M_n` from an inconsistency in the seed.

This is a **structural limitation of the incremental chain + Lindenbaum approach** under strict semantics.

---

## Recommended Approach

Based on this analysis, **Using Until to define durations does NOT resolve the gap.** The obstruction is not a matter of how Until obligations are packaged or tracked -- it is a fundamental mismatch between the X-local nature of Until unfolding and the G-global nature of the Lindenbaum seed's consistency argument.

The viable paths remain those identified in report 19:

1. **FMP-based completeness** (HIGH confidence, 85%): Bypass the infinite chain entirely by working with finite models where Until obligations are bounded. This sidesteps the transfer lemma completely.

2. **Global canonical model (GHR/Burgess style)** (MEDIUM confidence, 60%): Build a global model from all MCSes in the box class, define the temporal ordering via the Succ relation, and extract integer-indexed paths. Until persistence is a property of the Succ relation itself, not of incremental construction. The Succ relation's definition already handles F-deferral (`f_content(u) subset v union f_content(v)`), and Until coherence follows from the x_content relationship between Succ-linked MCSes.

3. **Hybrid deterministic + family switching**: Use the deterministic chain (where Until persistence is sorry-free) as the base, and handle F-obligations by switching to witness families at the BFMCS level. This exploits the fact that BFMCS already bundles multiple families.

**My recommendation**: Path 1 (FMP-based) is the most pragmatic. Path 2 is the most mathematically natural but requires significant new infrastructure.

---

## Evidence/Examples

### Evidence 1: G-lift cannot handle Until formulas

Counter-model showing `(top U psi)` and `G(neg(top U psi))` coexist under strict semantics:

Timeline: `..., -1, 0, 1, 2, 3, ...`
- `psi` holds at time 1 only
- At time 0: `(top U psi)` holds (witness: time 1)
- At time 0: `G(neg(top U psi))` holds? Check: at time 2, does `neg(top U psi)` hold? Yes, because psi does not hold at any time > 2. At time 1, does `neg(top U psi)` hold? Yes, because psi does not hold at any time > 1. So `G(neg(top U psi))` holds at time 0 (all strictly future times satisfy `neg(top U psi)` vacuously at t=1 since psi at t=1 does not help -- we need psi at some s > 1 for top U psi at time 1... wait).

Let me reconsider. At time 1: `(top U psi)` requires psi at some s > 1. Psi only holds at time 1. So `neg(top U psi)` holds at time 1. At time 2: similarly, `neg(top U psi)`. So `G(neg(top U psi))` holds at time 0 (for all s > 0, neg(top U psi) at s). But `(top U psi)` at time 0 holds because psi holds at time 1 > 0 and top holds at all t' with 0 < t' < 1 (vacuously). So both `(top U psi)` and `G(neg(top U psi))` hold at time 0. This confirms the obstruction.

### Evidence 2: Until Induction fails for all useful instantiations

For `chi = (top U psi)`:
- Premise `G(psi -> (top U psi))` fails: at time 1 in the model above, psi holds but `(top U psi)` fails.

For `chi = psi or (top U psi)`:
- Premise `G(X(psi or (top U psi)) -> (psi or (top U psi)))` fails: at time 0, `X(psi or (top U psi))` holds (since at time 1, psi holds), but this doesn't help at time 2 where `X(psi or (top U psi))` holds (at time 3, top U psi fails and psi fails, so X(psi or (top U psi)) at time 2 depends on what happens at time 3).

Actually the premise asks for this to hold at ALL future times. At time 1: `X(psi or (top U psi))` at time 1 means `psi or (top U psi)` at time 2. `psi` at time 2? No. `(top U psi)` at time 2? No. So `X(psi or (top U psi))` is false at time 1. The premise `X(chi) -> chi` at time 1 is vacuously true. But at time 0: `X(psi or (top U psi))` at time 0 means `psi or (top U psi)` at time 1. `psi` at time 1? Yes. So the antecedent holds. The consequent: `psi or (top U psi)` at time 0. `(top U psi)` at time 0? Yes. So the implication holds at time 0. The full `G` premise requires it at ALL strictly future times. At time 1: vacuously true. At times >= 2: `X(chi)` at time k means chi at time k+1; chi = `psi or (top U psi)` at time k+1 = false; so antecedent false, implication vacuously true. So premise 2 DOES hold in this model.

Premise 1: `G(psi -> chi)` at time 0 means at all s > 0, `psi -> (psi or (top U psi))` holds. This is trivially true (left intro). So premise 1 holds.

Conclusion: `(top U psi) -> X(chi)` means `(top U psi) -> X(psi or (top U psi))`. At time 0: `(top U psi)` holds, so `X(psi or (top U psi))` should hold. At time 1: `psi or (top U psi)` = `psi` = true. Yes, this holds.

So Until Induction with `chi = psi or (top U psi)` gives us `(top U psi) -> X(psi or (top U psi))`, which we already knew from Until Unfold! The axiom adds no new information for this instantiation.

### Evidence 3: x_content(M_n) union {target} is inconsistent in general

Model: M_0 is an MCS containing `{F(A), neg(A), X(neg(A)), F(top)}`. Then `neg(A) in x_content(M_0)`. So `{A} union x_content(M_0)` contains both `A` and `neg(A)`, which is inconsistent. Yet `F(A) in M_0`. This confirms that the resolution target cannot simply be added to x_content.

---

## Confidence Level

**HIGH** -- The impossibility of seed-based approaches for Until transfer under strict semantics is well-established by the analysis above and consistent with 17+ prior research rounds. The counter-models are concrete and verifiable. The recommended alternative paths (FMP-based or global canonical model) are grounded in published proof techniques with known mathematical validity.
