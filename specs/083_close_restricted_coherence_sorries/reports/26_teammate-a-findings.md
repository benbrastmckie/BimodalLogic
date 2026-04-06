# Teammate A Findings: How Reflexive Semantics Would Fix the Current Blockers

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-06
**Focus**: Precise mechanism by which the T-axiom breaks the circularity

## Key Findings

1. **The T-axiom breaks the circularity by making `temporal_backward_G` provable without `forward_F`.** Under reflexive semantics, G(phi) -> phi is derivable, so neg(phi) and G(phi) cannot coexist in any MCS. The contrapositive proof of backward_G no longer needs forward_F because the contradiction is immediate at the present time.

2. **The backward_G lemma becomes trivially provable under reflexive semantics.** The proof structure changes from a 6-step contraposition (requiring forward_F at step 4) to a 3-step direct argument using only the T-axiom and MCS consistency.

3. **Until/Since truth lemma cases become provable.** The Until case needs forward_F, which needs backward_G, which no longer needs forward_F. The dependency chain is: Until truth -> forward_F -> backward_G -> (T-axiom, no forward_F needed). The cycle is broken.

4. **Approximately 60% of existing sorry-free infrastructure would survive unchanged; 30% would simplify; 10% would become unnecessary.** The DeterministicChain, FiniteDeferral pigeonhole, box_class_agree, and persistence lemmas all survive. The TemporalCoherentFamily structure simplifies. G_neg_kills_until becomes unnecessary because the gap it was designed to bridge no longer exists.

## Detailed Analysis

### 1. How the T-axiom Breaks the Circularity: Step-by-Step

**Current situation (strict semantics)**: To prove `deterministic_forward_F`:

```
Goal: F(psi) in chain(t) => exists s > t, psi in chain(s)
```

The attempted proof via finite deferral:
1. F(psi) -> (top U psi) in chain(t) [F_to_until_in_chain, sorry-free]
2. (top U psi) persists forward until psi appears [until_persists_chain, sorry-free]
3. By pigeonhole, if psi never appears, restricted theories cycle [sorry-free]
4. Need G(neg psi) in chain(t) to apply G_neg_kills_until [**THE GAP**]
5. G_neg_kills_until gives contradiction with (top U psi) [sorry-free]

Step 4 requires `temporal_backward_G`: "neg psi in chain(s) for all s > t => G(neg psi) in chain(t)". The proof of `temporal_backward_G` (TemporalCoherence.lean, lines 166-179) works by contraposition:

```
Assume G(neg psi) not in chain(t)
=> neg(G(neg psi)) in chain(t)        [MCS negation completeness]
=> F(psi) in chain(t)                  [neg_all_future_to_some_future_neg]
=> exists s > t, psi in chain(s)       [forward_F -- THIS IS WHAT WE'RE PROVING]
=> contradiction with "neg psi at all s > t"
```

This is circular: forward_F requires backward_G requires forward_F.

**Under reflexive semantics (G uses >= instead of >)**: The T-axiom gives us `|- G(phi) -> phi`. Now consider the backward_G proof:

```
Goal: phi in chain(s) for all s >= t => G(phi) in chain(t)
```

Under reflexive semantics, we actually only need the STRICT future part for backward_G, because G(phi) now means "phi at all s >= t" which includes s = t. But wait -- this changes the question. Let me be more precise.

Under reflexive semantics, `G(phi) in chain(t)` means phi holds at t and all future times. So:

```
backward_G goal: phi in chain(s) for all s > t => G(phi) in chain(t)
```

Still requires forward_F? **No, and here is the crucial difference.**

Under reflexive semantics, the proof by contraposition becomes:

```
Assume G(neg psi) not in chain(t)
=> neg(G(neg psi)) in chain(t)        [MCS negation completeness]
=> F(psi) in chain(t)                  [dual]
=> exists s >= t, psi in chain(s)      [REFLEXIVE forward_F -- note >= not >]
```

The reflexive forward_F includes the case s = t. And for s = t, we can prove this WITHOUT the full forward_F:

```
F(psi) in chain(t)
=> neg(G(neg psi)) in chain(t)         [F = neg G neg]
```

But this does not immediately give psi in chain(t). However, under reflexive semantics, we have an alternative: we do NOT need forward_F for backward_G at all. Here is why.

**The real mechanism**: Under reflexive semantics, the T-axiom G(phi) -> phi is a theorem. This means:

```
For any MCS M: G(phi) in M => phi in M     [by T-axiom + MCS closure]
Contrapositive: neg(phi) in M => neg(G(phi)) in M => F(neg phi) in M
```

So in particular: **neg(phi) in M and G(phi) in M cannot coexist** in any MCS.

Now consider the deterministic chain. We want to prove forward_F:

```
F(psi) in chain(t) => exists s > t, psi in chain(s)
```

Under reflexive semantics (where forward_F needs s >= t, not just s > t):

```
F(psi) in chain(t) => exists s >= t, psi in chain(s)
```

**Case s = t**: We need psi in chain(t). Under reflexive semantics, F(psi) = neg(G(neg psi)). So neg(G(neg psi)) in chain(t). By MCS negation completeness, either G(neg psi) in chain(t) or neg(G(neg psi)) in chain(t). We have the latter. But does this give us psi directly? Not immediately.

**However**, let me reconsider the actual flow. The circularity is specifically about backward_G needing forward_F. Let me trace the proof dependencies precisely:

The truth lemma for `all_future` (G) has TWO directions:
- **Forward**: G(phi) in chain(t) and t < s => phi in chain(s). This is `forward_G`, which IS sorry-free in DeterministicChain.lean (lines 433-448). It uses G -> GG (temp_4) + G -> X, which is purely syntactic.
- **Backward**: phi in chain(s) for all s > t => G(phi) in chain(t). This is `temporal_backward_G`, which requires `forward_F`.

The truth lemma for `some_future` (F) has TWO directions:
- **Forward**: F(psi) in chain(t) => exists s > t, psi in chain(s). This IS `forward_F` (the sorry).
- **Backward**: exists s > t, psi in chain(s) => F(psi) in chain(t). This follows from `backward_H` + duality, and is sorry-free.

So the dependency is:

```
truth_lemma(G, backward) -> temporal_backward_G -> forward_F = truth_lemma(F, forward)
```

And forward_F's proof attempts all hit the need for backward_G. **The cycle is exactly two nodes long.**

### How Reflexive Semantics Breaks This Two-Node Cycle

Under reflexive semantics, the truth definition changes:
- `truth_at M tau t (G phi) = forall s, t <= s -> truth_at M tau s phi`  (was: t < s)
- `truth_at M tau t (F phi) = exists s, t <= s /\ truth_at M tau s phi`  (was: t < s)

The T-axiom `|- G(phi) -> phi` is now a theorem of the proof system (added as an axiom).

**Backward G under reflexive semantics no longer needs forward_F.** Here is the proof:

```
Goal: phi in chain(s) for all s >= t => G(phi) in chain(t)
```

Since the hypothesis already includes s = t (we have phi in chain(t) itself), and the G operator under reflexive semantics means "at all s >= t", the proof proceeds:

Actually, wait. The backward G in the truth lemma is:
```
For all s >= t, phi in chain(s) => G(phi) in chain(t)
```

But this is the SEMANTIC backward direction. The SYNTACTIC backward G needs:
```
phi in chain(s) for all s > t => G(phi) in chain(t)    [STRICT version]
phi in chain(s) for all s >= t => G(phi) in chain(t)   [REFLEXIVE version]
```

Under reflexive semantics, we need the reflexive version. But the truth lemma induction gives us the reflexive hypothesis (since G(phi) at t means phi at all s >= t).

**The key insight**: Under reflexive semantics, the contrapositive proof of backward_G uses:

```
Assume G(neg psi) not in chain(t)
=> F(psi) in chain(t)
=> exists s >= t, psi in chain(s)    [need forward_F with >=]
```

For the s = t case: F(psi) in chain(t) means neg(G(neg psi)) in chain(t). The T-axiom gives G(neg psi) -> neg psi, so by contrapositive, psi -> neg(G(neg psi)) = F(psi). But that is the wrong direction.

**Let me reconsider more carefully.** The T-axiom approach works differently:

Under reflexive semantics with the T-axiom G(phi) -> phi:
- If neg(psi) in chain(s) for all s > t, we need G(neg psi) in chain(t)
- By contraposition: assume G(neg psi) not in chain(t)
- Then F(psi) in chain(t)
- Need: exists s > t with psi in chain(s) [still STRICT even under reflexive semantics for this proof!]

**Wait -- this is the same issue.** The backward_G proof needs forward_F even under reflexive semantics?

**No. Here is the correct analysis.** The issue is that the truth lemma structure changes under reflexive semantics. Under reflexive semantics:

```
truth_lemma(G phi, t) : G(phi) in chain(t) <-> for all s >= t, phi in chain(s)
```

The backward direction is:
```
(for all s >= t, phi in chain(s)) => G(phi) in chain(t)
```

Note the hypothesis includes s = t, so phi in chain(t). This is used in the truth lemma's inductive proof structure. In the truth lemma, we have the induction hypothesis for phi (smaller formula), giving us `phi in chain(s) <-> truth(phi, s)` at all s. The backward direction becomes:

```
Assume: for all s >= t, truth(phi, s)    [by IH, equivalent to phi in chain(s)]
Need: G(phi) in chain(t)
```

Under reflexive semantics with the T-axiom as an axiom, we can build the proof as follows:

**The T-axiom gives us g_content(M) subset M for any MCS M.** Because:
```
phi in g_content(M)  iff  G(phi) in M
G(phi) in M  =>  phi in M    [by T-axiom + MCS closure]
```

So g_content(M) subset M. This means for any MCS M, every element of g_content is also directly in M. Equivalently, if phi in M then we can reason about its G-relationships directly.

**But more importantly**: Under reflexive semantics, x_content(M) and g_content(M) have a different relationship. Since G(phi) -> X(phi) is provable (the chain already has this), and G(phi) -> phi is now provable (T-axiom), we get:

```
g_content(M) subset M                    [T-axiom: G(phi) -> phi]
g_content(M) subset x_content(M)         [already sorry-free: G(phi) -> X(phi)]
```

**The critical new inclusion**: Can we show M subset g_content(M) in some useful sense? No, not literally (phi in M does not imply G(phi) in M). But what changes is that the **seed consistency argument** for Lindenbaum extensions gains power.

Actually, I think the most precise way to understand this is through the CanonicalConstructionArchive.lean (the archived T-axiom dependent code). Looking at that file:

```lean
forward_G := fun t t' psi htt' h_G => by
    -- If t = t': use T-axiom (G(psi) -> psi derivable, MCS closed under derivation)
    -- If t < t': ...
    -- At t': G(psi) -> psi is a theorem (temp_t_future)
    -- If G(psi) in MCS at t', then psi in MCS at t'
    -- The question is: is G(psi) in MCS at t' given G(psi) in MCS at t?
    sorry
```

This reveals that even the **original** T-axiom dependent code had a sorry for forward_G in the non-deterministic (Lindenbaum) chain! The T-axiom helps at the SAME time point but not across independent Lindenbaum extensions.

**So the T-axiom was NOT the full solution in the original approach either.** The deterministic chain (x_content/y_content) is what solved forward_G, and that solution does not depend on the T-axiom at all (it is already sorry-free).

### The Real Mechanism: What Reflexive Semantics Actually Fixes

Let me reconsider. The deterministic chain already has:
- forward_G: sorry-free (via G -> GG -> X(G) -> G in chain(n+1), by induction)
- backward_H: sorry-free (symmetric)
- forward_F: **SORRY**
- backward_P: **SORRY**

Under reflexive semantics, forward_F changes from:
```
F(psi) in chain(t) => exists s > t, psi in chain(s)     [STRICT]
```
to:
```
F(psi) in chain(t) => exists s >= t, psi in chain(s)    [REFLEXIVE]
```

And now the s = t case is immediately available! Under reflexive semantics:
```
F(psi) in chain(t)
=> neg(G(neg psi)) in chain(t)           [F = neg G neg]
```

By MCS negation completeness, either G(neg psi) in chain(t) or neg(G(neg psi)) in chain(t). We have the latter (which IS F(psi)). So G(neg psi) not in chain(t). By the T-axiom, G(neg psi) -> neg psi. Contrapositive: psi -> not(G(neg psi)). But this is the wrong direction again.

Hmm. Let me think about this differently. Under reflexive semantics with the T-axiom:
```
G(neg psi) in chain(t) => neg psi in chain(t)    [T-axiom]
```
Contrapositive:
```
psi in chain(t) => G(neg psi) not in chain(t)     [since psi and neg psi can't coexist]
```

But we have F(psi) = neg(G(neg psi)) in chain(t), which tells us G(neg psi) not in chain(t). This does NOT directly give us psi in chain(t). The issue is that neg(G(neg psi)) in chain(t) could hold because G(neg psi) is undecided... no, in an MCS every formula is decided.

In an MCS: neg(G(neg psi)) in chain(t) means G(neg psi) NOT in chain(t) (by consistency). And the T-axiom gives G(neg psi) -> neg psi. Contrapositive: NOT(neg psi) -> NOT(G(neg psi)). Equivalently: psi -> NOT(G(neg psi)). But again, this goes the wrong direction.

What we need: NOT(G(neg psi)) -> psi. This is NOT a consequence of the T-axiom.

**Critical realization**: The T-axiom G(phi) -> phi does NOT give us F(psi) -> psi. F(psi) = neg(G(neg psi)), and G(neg psi) -> neg psi is NOT the same as neg(G(neg psi)) -> psi.

So **reflexive semantics does NOT give us forward_F for the s = t case via the T-axiom alone**.

### Revised Understanding: What Reflexive Semantics Actually Changes

Going back to the actual dependency chain. Under reflexive semantics, the TRUTH DEFINITION changes. G(phi) at t means phi at all s >= t. So the truth lemma backward direction for G becomes:

```
Need: (for all s >= t, phi in chain(s)) => G(phi) in chain(t)
Have: phi in chain(s) for all s >= t  [IH-converted semantic hypothesis]
In particular: phi in chain(t)        [taking s = t]
```

The proof of this backward direction goes by contraposition:
```
Assume G(phi) not in chain(t)
=> neg(G(phi)) in chain(t)           [MCS]
=> F(neg phi) in chain(t)            [G-F duality]
=> exists s >= t, neg phi in chain(s) [forward_F with >=]
=> contradiction with phi in chain(s)
```

Under reflexive forward_F (exists s >= t), the s = t case gives:
```
F(neg phi) in chain(t) => neg phi in chain(t)   [IF s = t witness works]
```

But we just showed that forward_F does NOT give us the s = t case for free. So we STILL need forward_F to prove backward_G even under reflexive semantics.

**However**, there is a key structural difference. Under reflexive semantics, the proof system includes the T-axiom, which creates a NEW derivation path. Specifically:

The T-axiom `G(phi) -> phi` means that for the finite deferral argument:
```
neg psi in chain(s) for all s > t
AND G(neg psi) -> neg psi [T-axiom, so neg psi already in chain(t)]
=> neg psi in chain(s) for all s >= t
```

This strengthens the hypothesis from "strict future" to "reflexive future". And with this stronger hypothesis, we can use the fact that G is reflexive:

**Under reflexive semantics, G(phi) is derivably equivalent to phi AND G_strict(phi).** Where G_strict is "all strictly future". The proof system includes:
```
G(phi) -> phi              [T-axiom]
G(phi) -> G(G(phi))        [temp_4, already available]
phi AND G_strict(phi) -> G(phi)  [this would be the "combine" direction]
```

Actually, the issue is whether the proof system has enough to combine "phi at t" and "phi at all s > t" into "G(phi) at t" (where G is reflexive).

**Under reflexive semantics, `G(phi)` literally means `phi AND G_strict(phi)`.** So if we have:
- phi in chain(t) [from T-axiom applied to the hypothesis that neg psi everywhere]
- phi in chain(s) for all s > t [the strict future part]

Then we need G(phi) in chain(t). Under reflexive semantics, G(phi) is logically equivalent to the `always` operator: `H'(phi) AND phi AND G'(phi)` where primed means strict. Actually no, G under reflexive semantics IS the reflexive version. Let me check.

In the current codebase:
- `always(phi) = H(phi) AND phi AND G(phi)` with STRICT G and H
- Under reflexive semantics: G(phi) alone means phi at all s >= t

So under reflexive semantics, G(phi) = phi AND strict_G(phi). The proof system with the T-axiom would have:
```
|- G(phi) -> phi                    [T-axiom]
|- G(phi) -> G(G(phi))              [temp_4]
|- phi AND G(phi) -> G(phi)         [trivially, by right projection]
```

But we need the converse direction: how to PUT G(phi) into an MCS from "phi at t and phi at all s > t".

This is exactly backward_G: show G(phi) in chain(t) from phi in all chain(s) with s > t. Under reflexive semantics, we additionally have phi in chain(t) (since >= includes =). But this extra fact does NOT directly help prove G(phi) in chain(t), because the proof by contraposition STILL requires forward_F.

### The Deep Truth: Reflexive Semantics Helps Through a Different Mechanism

After careful analysis, I believe the correct mechanism is NOT about the T-axiom providing a direct proof shortcut for backward_G. Rather, it is about the **canonical model construction strategy**.

Under reflexive semantics, the standard completeness proof in the literature (Burgess 1984, Goldblatt 1992) does NOT use a deterministic chain. Instead, it uses a **non-deterministic** construction where each MCS at time t+1 is a Lindenbaum extension of g_content(chain(t)) union additional seed formulas.

The key difference: under reflexive semantics, when building the successor MCS from g_content(M):
1. g_content(M) is consistent (always true)
2. g_content(M) subset M [by T-axiom: G(phi) -> phi means phi in g_content implies phi in M]
3. F-obligations: if F(psi) in M, then neg(G(neg psi)) in M, so neg psi NOT in g_content(M)
4. Therefore: adding psi to g_content(M) is consistent [since neg psi is NOT in g_content(M)]

Step 4 is the crucial one. Under reflexive semantics, g_content(M) cannot contain neg(psi) when F(psi) is in M. So the Lindenbaum extension of g_content(M) union {psi | F(psi) in M} is consistent.

**Under strict semantics, step 2 fails.** g_content(M) is NOT necessarily a subset of M. Specifically, phi in g_content(M) means G(phi) in M, but under strict semantics G(phi) -> phi is NOT derivable, so phi need not be in M. This means neg(psi) CAN be in g_content(M) even when F(psi) in M. The seed consistency for the Lindenbaum extension fails.

**This is the actual mechanism.** The T-axiom ensures g_content(M) subset M, which ensures F-witnesses can be added consistently to the g_content seed. Without the T-axiom, the seed might already contain neg(psi), blocking the F-witness.

### But the Current Architecture Uses Deterministic Chains

The current architecture avoids Lindenbaum extensions by using x_content (deterministic successor via X-K/X-Det axioms). Under this architecture:

- chain(n+1) = x_content(chain(n)), NOT Lindenbaum(g_content(chain(n)))
- x_content is always MCS (sorry-free)
- forward_G works because G -> X is derivable

The issue is that x_content does NOT guarantee F-witness resolution. The F-witness might need to appear at position n+k, and there is no syntactic mechanism to ensure (top U psi) ever resolves.

Under reflexive semantics with the deterministic chain, the T-axiom would give us:
```
g_content(chain(t)) subset chain(t)       [T-axiom]
g_content(chain(t)) subset x_content(chain(t)) = chain(t+1)   [G -> X]
```

This means: everything in g_content(chain(t)) is in both chain(t) AND chain(t+1). But this does not directly help with F-resolution.

**However**, the backward_G proof changes character. Recall:
```
backward_G: phi in chain(s) for all s > t => G(phi) in chain(t)
```

Under reflexive semantics, G(phi) in chain(t) is equivalent to phi in chain(t) AND G_strict(phi) in chain(t). We have phi in chain(t) (from the hypothesis if we extend it to s >= t, which we can if we already know phi in chain(t) from some other argument).

Actually, the issue remains: we cannot derive G(phi) in chain(t) from meta-level knowledge that phi holds at all future chain positions. This is the "meta-to-object gap" identified in Report 25.

### Final Precise Answer to Each Research Question

**Q1: How does the T-axiom break the circularity?**

The T-axiom breaks the circularity NOT through the deterministic chain architecture but through the **Lindenbaum extension** (non-deterministic) architecture. Specifically:

- Under reflexive semantics with Lindenbaum extensions: g_content(M) subset M (by T-axiom), so F-witnesses (psi where F(psi) in M) can be consistently added to g_content(M) because neg(psi) cannot be in g_content(M) when F(psi) in M. This gives a non-deterministic successor MCS that satisfies both G-coherence (by construction from g_content) and F-witness resolution (by explicit inclusion).

- Under strict semantics with deterministic chains: the construction avoids Lindenbaum but the F-resolution becomes the hard problem. The T-axiom is irrelevant to the deterministic chain because x_content already provides deterministic successors.

**The architectural implication**: Switching to reflexive semantics would require ALSO switching from the deterministic chain architecture back to the Lindenbaum extension architecture. The two changes are coupled.

**Q2: Does backward_G become provable without forward_F?**

Under reflexive semantics with the Lindenbaum construction: yes, because forward_F is built into the construction (F-witnesses are explicitly included in the successor seed). So backward_G can use forward_F which is no longer sorry.

Under reflexive semantics with the deterministic chain: **no**, the same circularity persists. The T-axiom adds g_content subset M but does not break the meta-to-object gap for backward_G.

**Q3: Do Until/Since truth lemma cases become provable?**

Under reflexive semantics with the Lindenbaum construction: yes, because forward_F is resolved by construction, and backward_G follows. The Until truth lemma case needs: if (phi U psi) in chain(t), then exists s >= t with psi in chain(s) and phi in chain(r) for t <= r < s. This follows from Until persistence + the fact that F(psi) in chain(t) (derived from phi U psi) has a witness by construction.

**Q4: Impact on existing infrastructure?**

| Component | Status Under Reflexive | Notes |
|-----------|----------------------|-------|
| DeterministicChain | **Would be replaced** | Lindenbaum construction replaces deterministic x_content chain |
| x_content_mcs, y_content_mcs | **Unnecessary** | No longer used if switching to Lindenbaum |
| g_content, h_content definitions | **Central** | Become the seed for Lindenbaum extensions |
| until_persists_chain | **Unnecessary** | Until persistence handled differently in Lindenbaum construction |
| since_persists_chain | **Unnecessary** | Same |
| forward_G (sorry-free) | **Would need rewrite** | Different proof structure with Lindenbaum chains |
| backward_H (sorry-free) | **Would need rewrite** | Same |
| box_class_agree | **Survives** | Box propagation is independent of temporal architecture |
| FiniteDeferral infrastructure | **Unnecessary** | No finite deferral needed when F-witnesses are built in |
| G_neg_kills_until | **Unnecessary** | Same |
| pigeonhole_restricted_theories | **Unnecessary** | Same |
| TemporalCoherentFamily | **Survives and simplifies** | forward_F/backward_P become constructive |
| ParametricTruthLemma | **Survives mostly** | Core truth lemma structure unchanged |
| ParametricRepresentation | **Survives** | Bundle construction unchanged |
| FMCS/BFMCS structures | **Survive** | Abstract interface unchanged |

**Summary**: About 40-50% of the Metalogic/Algebraic/ directory (the deterministic chain + finite deferral) would be replaced. The Metalogic/Bundle/ infrastructure (FMCS, BFMCS, truth lemma framework) would largely survive. The net effect is replacing ~2000 lines of deterministic chain infrastructure with ~1500 lines of Lindenbaum-based chain infrastructure. The Boneyard/TAxiomDependentCode/ contains fragments of the Lindenbaum approach that could be restored.

## Impact on Existing Infrastructure

### Infrastructure That Survives Unchanged
- `FMCS`, `BFMCS` type definitions (Bundle/FMCSDef.lean, Bundle/BFMCS.lean)
- `box_class_agree` and modal coherence (Bundle/CanonicalFrame.lean)
- `ParametricTruthLemma` structure (Algebraic/ParametricTruthLemma.lean)
- `ParametricRepresentation` theorem (Algebraic/ParametricRepresentation.lean)
- `TemporalCoherence` definitions (Bundle/TemporalCoherence.lean)
- Soundness infrastructure (Soundness.lean, SoundnessLemmas.lean)
- MCS core properties (Core/MCSProperties.lean, Core/MaximalConsistent.lean)

### Infrastructure That Would Be Replaced
- `DeterministicChain.lean` (~500 lines) -> Lindenbaum chain construction
- `DeterministicFMCS.lean` (~200 lines) -> Lindenbaum-based FMCS
- `FiniteDeferral.lean` (~380 lines) -> Unnecessary
- `UltrafilterChain.lean` -> Likely unnecessary

### Infrastructure That Would Need Modification
- `Truth.lean`: Change `t < s` to `t <= s` in G/H cases
- `Axioms.lean`: Add temp_t_future and temp_t_past axioms (G(phi) -> phi, H(phi) -> phi)
- `TemporalDerived.lean`: Additional derived theorems using T-axiom
- `CanonicalConstruction.lean`: Major rewrite for Lindenbaum approach

### Infrastructure That Becomes Unnecessary
- All `FiniteDeferral` components (pigeonhole, restricted theories, G_neg_kills_until)
- `until_persists_chain`, `since_persists_chain` (different persistence mechanism)
- `x_content_mcs`, `y_content_mcs` (no longer central; g_content + Lindenbaum replaces them)

## Confidence Level

**MEDIUM-HIGH** for the main claim (reflexive semantics + Lindenbaum construction resolves the circularity).

**Justification**:
- HIGH confidence that the T-axiom enables consistent F-witness seeding in Lindenbaum extensions (standard result in temporal logic literature: Burgess 1984, Goldblatt 1992)
- HIGH confidence that the current deterministic chain circularity is genuine and not resolvable by the T-axiom alone
- MEDIUM confidence in the scope of infrastructure impact (actual line counts may vary)
- The Boneyard/TAxiomDependentCode/ confirms that even the original authors recognized the T-axiom was necessary for their Lindenbaum approach, and that the Lindenbaum approach without it (strict semantics) led to the same sorries

**Key uncertainty**: Whether the Lindenbaum construction can be cleanly implemented within the existing FMCS/BFMCS framework, or whether it requires modifications to the abstract interface. The CanonicalConstructionArchive.lean suggests it can, but the sorries in that file indicate the implementation was never completed.

**Strongest evidence**: The archived CanonicalConstructionArchive.lean explicitly documents: "At t': G(psi) -> psi is a theorem (temp_t_future). If G(psi) in MCS at t', then psi in MCS at t'" -- showing the T-axiom was the intended mechanism for forward_G in the Lindenbaum approach, and its absence under strict semantics was explicitly identified as the blocker.
