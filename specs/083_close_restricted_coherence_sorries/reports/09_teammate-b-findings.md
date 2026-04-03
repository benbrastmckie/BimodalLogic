# Teammate B Findings: Theoretical Analysis of Strict Temporal Semantics

**Task**: 83 - Close Restricted Coherence Sorries
**Focus**: Logic-theoretic analysis of the ideal end state for TM with strict G/H + Since/Until
**Date**: 2026-04-03

## Standard Literature Conventions (Strict vs Weak in Temporal Logic)

The temporal logic literature has a clear split:

**Philosophical/mathematical tradition (strict is standard)**: Kamp (1968), Burgess (1982), Xu (1988), Venema (1993), Gabbay-Hodkinson-Reynolds (1994) all use **strict** semantics as the default:
- `G phi` at t := for all s with t < s, phi(s)
- `H phi` at t := for all s with s < t, phi(s)
- `phi U psi` at t := exists s > t such that psi(s) and for all u with t < u < s, phi(u)
- `phi S psi` at t := exists s < t such that psi(s) and for all u with s < u < t, phi(u)

**Computer science tradition (reflexive is standard)**: Pnueli (1977), Manna-Pnueli, standard LTL model checking all use **reflexive** semantics:
- `G phi` at t := for all s >= t, phi(s)
- `phi U psi` at t := exists i >= 0 such that psi at position t+i and for all 0 <= k < i, phi at position t+k

**Key fact from SEP**: "The strict versions of S and U are more expressive than their reflexive counterparts." This is a theorem, not merely a convention.

The Burgess-Xu axiomatization was originally stated for REFLEXIVE Since/Until over all reflexive linear orders. Venema (1993) then extended it to STRICT Since/Until for discrete linear orderings, well-orderings, and the natural numbers.

**Confidence**: HIGH

## Definability Relationships Under Strict Semantics

Under **strict** semantics, the definability chain is clean and standard:

### From Since/Until to F/P (strict)
- `F phi := top U phi` (exists s > t with phi(s) and top at all intermediate u -- vacuously true)
- `P phi := top S phi` (exists s < t with phi(s) and top at all intermediate u -- vacuously true)

### From F/P to G/H (via duality)
- `G phi := neg F neg phi` (no future time has neg phi)
- `H phi := neg P neg phi` (no past time has neg phi)

### Critical difference from reflexive
Under reflexive semantics: `F phi := top U phi` where U uses t <= s, so F means "exists s >= t with phi(s)" which includes the present. Under strict: F means "exists s > t with phi(s)" -- genuinely future only.

### What G does NOT imply under strict semantics
- `G phi` does NOT imply `phi` (the T-axiom fails for temporal operators)
- `H phi` does NOT imply `phi`
- Instead: `phi` is a separate assertion about the present moment

### What IS valid under strict semantics on Int (no endpoints, linear)
- `phi -> H F phi`: At t, phi(t). For any s < t, need F phi at s, i.e., exists u > s with phi(u). Take u = t. Valid because t > s when s < t. YES, VALID on Int.
- `phi -> G P phi`: At t, phi(t). For any s > t, need P phi at s, i.e., exists u < s with phi(u). Take u = t. Valid because t < s when s > t. YES, VALID on Int.
- `G phi -> G G phi`: Transitivity of <. VALID.
- `H phi -> H H phi`: Transitivity of <. VALID.
- `phi -> G P phi` and `phi -> H F phi` serve as **replacements for the T-axiom** -- they express that the present is always recoverable from the past-of-the-future and the future-of-the-past.

**Note on branching time**: The SEP notes that `phi -> H F phi` fails in BRANCHING (Peircean) time. But for LINEAR time (as in TM over Int), it is valid. This is important: the TM logic is over linear Int, so both bridge axioms hold.

**Confidence**: HIGH

## Ideal Axiom System for TM with Strict G/H + Since/Until

The ideal axiom system for TM over Int combines three layers:

### Layer 1: S5 Modal Logic (unchanged)
- K: `Box(phi -> psi) -> (Box phi -> Box psi)`
- T: `Box phi -> phi`
- 4: `Box phi -> Box Box phi`
- B: `phi -> Box Diamond phi`

### Layer 2: Strict Temporal Logic (Burgess-Xu adapted for strict, per Venema)

**Basic temporal axioms for strict G/H**:
- TK_G: `G(phi -> psi) -> (G phi -> G psi)` (K-distribution for G)
- TK_H: `H(phi -> psi) -> (H phi -> H psi)` (K-distribution for H)
- T4_G: `G phi -> G G phi` (transitivity for G, valid for strict <)
- T4_H: `H phi -> H H phi` (transitivity for H)
- TA: `phi -> G P phi` (present is past-of-future, valid on linear orders without right endpoint)
- TA_dual: `phi -> H F phi` (present is future-of-past, valid on linear orders without left endpoint)

**Note**: The T-axioms `G phi -> phi` and `H phi -> phi` are DROPPED (invalid under strict semantics). The axioms TA and TA_dual replace them conceptually.

**Since/Until axioms (Burgess-Xu core, adapted for strict)**:
- U-Unfold: `phi U psi -> psi v (phi ^ G(phi U psi))`
- U-Intro: `psi v (phi ^ G(phi U psi)) -> phi U psi`
- U-Induction: `G(psi -> chi) ^ G(phi ^ chi -> G chi) -> (phi U psi -> chi)`
- U-Linearity: `(phi U psi) ^ (phi' U psi') -> (phi U (psi ^ (phi' U psi'))) v (phi' U (psi' ^ (phi U psi)))`
- U-S-Connectedness: `phi ^ (chi U psi) -> chi U (psi ^ (chi S phi))`
- Mirror axioms for Since (S-Unfold, S-Intro, S-Induction, S-Linearity, S-U-Connectedness)

**Discrete axioms (Venema 1993 extension for strict discrete orders)**:
- Disc-F: `F top -> bot U top` (if there is a future, there is an immediate successor)
- Disc-P: `P top -> bot S top` (if there is a past, there is an immediate predecessor)

These are the KEY axioms that distinguish discrete from dense orders under strict semantics. `bot U top` means "exists s > t with top(s) and bot at all u in (t,s)" -- the bot guard forces s to be the immediate successor (no u exists between t and s).

**Seriality (no endpoints, specific to Int)**:
- Ser-F: `F top` (there always exists a future moment)
- Ser-P: `P top` (there always exists a past moment)

**F-Until and P-Since bridges**:
- `F psi -> top U psi`
- `P psi -> top S psi`
- (converses derivable from U-Induction/S-Induction)

**Linearity axiom**:
- `F phi ^ F psi -> F(phi ^ psi) v F(phi ^ F psi) v F(F phi ^ psi)`

**Modal-temporal interaction** (unchanged from current):
- MF: `Box phi -> Box F phi`
- TF: `Box phi -> F Box phi`

### Layer 3: Inference Rules
- Modus Ponens: from `phi` and `phi -> psi`, derive `psi`
- Necessitation-Box: from `phi`, derive `Box phi`
- Necessitation-G: from `phi`, derive `G phi`
- Necessitation-H: from `phi`, derive `H phi`

**Confidence**: HIGH for the structure, MEDIUM for whether this exact set is complete (the completeness of Burgess-Xu + Venema discrete extension for strict Int is well-established in the literature, but adapting it to the bimodal S5+temporal setting requires care).

## Operator Coordination Design

### The Central Design Principle

Under strict semantics, the operators decompose into three temporal layers:

1. **Present**: bare `phi` (no operator)
2. **Strict future/past**: `G`, `H`, `F`, `P` (exclude the present)
3. **Binary temporal**: `U`, `S` (express complex temporal patterns)

The key coordination insight is:

**With strict G/H, the unfold axiom `phi U psi -> psi v (phi ^ G(phi U psi))` has a clean reading**: "Either psi holds NOW (base case), or phi holds NOW and phi-until-psi holds at ALL STRICTLY FUTURE times." The G here means genuinely future -- it does NOT include the present. This means:
- The first disjunct (`psi`) handles the case where the witness is at the current time
- The second disjunct (`phi ^ G(phi U psi)`) handles the case where the witness is strictly in the future
- There is NO overlap between the two cases

**Contrast with reflexive G**: Under reflexive semantics, `G(phi U psi)` includes `phi U psi` at the present, making the second disjunct partially redundant with the whole formula. This creates the circularity that plagues the current codebase's backward truth lemma proof.

### The Until Semantics Question: Strict vs Reflexive Witness

There are two natural choices for Until under strict G/H:

**(A) Fully strict Until** (Kamp/philosophical standard):
```
phi U psi at t := exists s > t, psi(s) ^ for all u, t < u < s -> phi(u)
```
Here the witness `s` is STRICTLY future. Present is excluded from both the witness range and the guard.

**(B) Half-open Until** (what the codebase currently uses after the recent change):
```
phi U psi at t := exists s >= t, psi(s) ^ for all u, t <= u < s -> phi(u)
```
Here the witness can be the present, and the guard covers `[t, s)`.

**Analysis of (A) vs (B)**:

Under (A), `F phi = top U phi` because `top U phi` means "exists s > t with phi(s)" which is exactly F under strict semantics. Clean.

Under (B), `F phi = top U phi` means "exists s >= t with phi(s)" which is `phi v F phi` under strict F. This makes F reflexive even though G is strict -- an inconsistency.

**The ideal choice is (A): fully strict Until**, coordinating with strict G/H. This gives:
- `F phi <-> top U phi` (exact equivalence, both strict)
- `P phi <-> top S phi` (exact equivalence, both strict)
- `G phi <-> neg(top U neg phi)` (exact duality)
- `H phi <-> neg(top S neg phi)` (exact duality)

Under (A), the unfold axiom becomes:
```
phi U psi -> psi_at_succ v (phi_at_succ ^ G(phi U psi))
```
Wait -- this is wrong. Under fully strict Until with witness s > t:
- If s = t+1: psi(t+1) and guard interval (t, t+1) is empty -- vacuously true
- If s > t+1: psi(s) and phi at all u in (t, s)

The unfold should be: `phi U psi -> F psi ^ (F neg psi -> phi ^ G(phi U psi))` ... no, the standard Burgess-Xu unfold IS `phi U psi -> psi v (phi ^ G(phi U psi))`, but under STRICT Until the first disjunct `psi` means psi holds NOW. But strict Until requires the witness s > t, so psi at the current time does NOT directly follow from `phi U psi`.

**Critical realization**: Under fully strict Until, the unfold axiom takes a DIFFERENT form:

```
phi U psi -> phi ^ G(psi v (phi U psi))
```

This says: if phi-until-psi holds at t, then phi holds at t (since the witness is strictly future, phi must hold at t as part of the guard -- wait, the guard is (t, s), which EXCLUDES t). Actually no: under fully strict (A), the guard is `t < u < s`, so phi is NOT required at t.

Let me reconsider. Under fully strict (A):
- `phi U psi` at t means: exists s > t with psi(s) and phi at all u in (t, s)
- The formula says NOTHING about the present moment t
- phi need not hold at t, psi need not hold at t

The unfold would be: `phi U psi -> G(psi v phi U psi)` -- at all strictly future times, either psi or phi-until-psi holds. This is weaker than the reflexive version.

**This changes the axiomatics significantly.** The Burgess-Xu axioms as standardly stated (with `psi v (phi ^ G(phi U psi))`) assume that `psi` can serve as the base case (witness at present). Under fully strict Until, there IS no base case at the present.

### Resolution: The codebase's half-open (B) is actually the right choice

After this analysis, I realize that choice **(B) -- half-open Until with reflexive witness range and strict guard** -- is actually the ideal coordination:

```
phi U psi at t := exists s >= t, psi(s) ^ for all u, t <= u < s -> phi(u)
```

This is "half-open" in the sense that:
- Witness range: `s >= t` (reflexive -- includes present)
- Guard interval: `[t, s)` (half-open -- excludes the witness point)

**Why this is ideal**:
1. When s = t: psi(t) holds, guard interval [t,t) is empty. So `psi -> phi U psi` (until_intro first disjunct) is sound.
2. When s > t: psi(s) at a strictly future time, phi holds at [t, s). So phi holds at t (present is in the guard).
3. `F phi = top U phi` gives: exists s >= t with phi(s). This is `phi v F_strict phi`. Under strict G: `F phi = neg G neg phi = neg(forall s > t, neg phi(s))`. So `top U phi` is NOT the same as strict F -- it also includes the present.

Hmm, this creates a mismatch. **The definability relationship depends on G being reflexive or strict**:
- If G is strict (t < s) but U has reflexive witness (s >= t), then `top U phi` = `phi v F phi`, not `F phi`.
- To get `F phi = top U phi`, we need EITHER both strict OR both reflexive.

### The Three Consistent Designs

| Design | G/H | U/S witness | U/S guard | F = top U? | T-axiom? | Unfold clean? |
|--------|-----|-------------|-----------|------------|----------|---------------|
| Fully reflexive (current) | s >= t | s >= t | [t, s] | Yes (refl F) | Yes | No (until_intro unsound) |
| Half-open (plan v7) | s >= t | s >= t | [t, s) | F = phi v F_strict | Yes | Yes (vacuous guard at s=t) |
| Fully strict | s > t | s > t | (t, s) | Yes (strict F) | No | Different axioms needed |
| **Mixed strict** | **s > t** | **s >= t** | **[t, s)** | **F = phi v F_strict** | **No** | **Yes** |

**The plan v7 (half-open) keeps reflexive G/H.** My assignment is to analyze what happens under STRICT G/H.

### Ideal Design: Strict G/H + Half-Open Until (Mixed Strict)

The most elegant design that uses strict G/H while keeping the Burgess-Xu axioms workable is:

- **G phi at t := for all s > t, phi(s)** (strict)
- **H phi at t := for all s < t, phi(s)** (strict)
- **phi U psi at t := exists s >= t, psi(s) ^ for all u, t <= u < s -> phi(u)** (half-open)
- **phi S psi at t := exists s <= t, psi(s) ^ for all u, s < u <= t -> phi(u)** (half-open)

Under this design:
- `until_intro` first disjunct: `psi -> phi U psi` is SOUND (witness s = t, empty guard)
- `until_intro` second disjunct: `phi ^ G(phi U psi) -> phi U psi` -- G means strictly future. So `G(phi U psi)` means `phi U psi` at all s > t. Combined with `phi` at t: need to construct a witness. Take ANY witness s' > t from `phi U psi at t+1` (guaranteed by `G(phi U psi)`). Then: psi(s') with phi at [t+1, s'). We also have phi(t). So phi holds at [t, s') and psi(s'). But wait -- we need psi(s') at some s' >= t. We have s' >= t+1 > t, so s' >= t. And phi at [t, s'): phi(t) from the premise, phi at [t+1, s') from the Until at t+1. **This is SOUND.**
- `until_unfold`: `phi U psi -> psi v (phi ^ G(phi U psi))`. At t with witness s >= t: if s = t, psi(t) (first disjunct). If s > t, phi(t) (from guard, t in [t,s)), and for all s' > t, `phi U psi` at s' (same witness s works since s >= s' for... no, we need s >= s', but s' could be > s). **This is where the problem emerges.** `G(phi U psi)` at t means `phi U psi` at ALL s' > t, not just some. We only have the witness for s' <= s. For s' > s, we have no witness. **until_unfold is UNSOUND even with half-open Until + strict G.**

This is exactly the same problem the codebase already has. The unfold axiom with strict G is fundamentally too strong.

**The resolution in the literature**: Under fully strict semantics, the unfold axiom takes a different form, or is replaced by a different axiom set. Specifically, in the Burgess-Xu system as presented in the SEP, the axioms use the REFLEXIVE G (since the system was designed for reflexive operators). For strict operators, Venema's extension modifies the axiomatics.

**Confidence**: HIGH for the analysis, MEDIUM for the specific axiom modifications needed.

## Expressiveness Gains from Strict Semantics

### Strict S/U are strictly more expressive than reflexive S/U

This is a theorem from the literature (stated in SEP): "the strict versions of S and U are more expressive than their reflexive counterparts."

Specifically:
1. Over dense linear orders: strict S/U can distinguish the current moment from "arbitrarily close" moments. Reflexive S/U cannot separate "now" from "now or just after now."
2. Over discrete linear orders (like Int): the difference is less dramatic because the next-step operator X is definable from strict Until: `X phi := bot U phi` (exists s > t with phi(s) and bot at all u in (t,s) -- forces s = t+1 on discrete orders).

### What strict semantics makes definable on Int

Under strict G/H + strict Until/Since on Int:
- **Next**: `X phi := bot U phi` (the immediate successor operator)
- **Previous**: Y phi := bot S phi (the immediate predecessor operator)
- **Strict F**: `F phi := top U phi`
- **Strict P**: `P phi := top S phi`
- **Weak Until**: `phi W psi := (phi U psi) v G phi`
- **Release**: `phi R psi := neg(neg phi U neg psi)`

Under REFLEXIVE G/H + half-open Until:
- X is NOT directly definable from Until (since `bot U phi` with reflexive witness means exists s >= t with phi(s) and bot at [t, s) -- if s = t, guard is empty, so this gives `phi(t)`, not `phi(t+1)`!)

Wait, let me reconsider. With half-open Until (witness s >= t, guard [t, s)):
- `bot U phi` at t = exists s >= t, phi(s) ^ forall u, t <= u < s -> bot(u)
- If s = t: phi(t), guard empty. So `bot U phi` at t iff phi(t). NOT the next-step operator.
- If s > t: phi(s), and bot at all u in [t, s). But bot is always false. So [t, s) must be empty, meaning s = t. Contradiction with s > t.
- Therefore: `bot U phi` at t iff phi(t). This is just `phi`, not `X phi`.

Under fully strict Until (witness s > t, guard (t, s)):
- `bot U phi` at t = exists s > t, phi(s) ^ forall u, t < u < s -> bot(u)
- The interval (t, s) must be empty (bot can't hold anywhere). On Int, this forces s = t + 1.
- So `bot U phi` at t iff phi(t+1). This IS the next-step operator!

**This is a significant expressiveness gain**: fully strict Until on discrete orders gives definability of the next-step operator, which half-open Until does not.

### Kamp's theorem

Kamp (1968) proved that strict Since + strict Until are **expressively complete** for first-order monadic logic of order (FOMLO) over continuous strict linear orders. Extensions by Stavi (using two additional operators) and by Gabbay-Hodkinson-Reynolds cover all linear orders.

On Int specifically: strict S + U express everything that FOMLO can express over (Z, <). This is a strong result -- it means the logic with just S and U (plus propositional connectives) is as expressive as first-order logic restricted to monadic predicates and the order relation.

**Confidence**: HIGH

## Since/Until Semantics Interaction with Strict G/H

### The core tension

The Burgess-Xu axioms (as stated in the SEP supplement) use REFLEXIVE G in the unfold and intro axioms:
- U-Intro: `psi v (phi ^ G(phi U psi)) -> phi U psi`
- U-Unfold: `phi U psi -> psi v (phi ^ G(phi U psi))`

These axioms are designed for a system where G includes the present (`G phi at t := forall s >= t, phi(s)`). Under strict G (`forall s > t`), the unfold direction becomes unsound as analyzed above.

### For the codebase: the pragmatic answer

The codebase currently uses reflexive G/H (with `t <= s`). The plan v7 proposes switching Until/Since to half-open guards while keeping G/H reflexive. This is a **consistent and workable** design:

- Reflexive G + half-open Until: the Burgess-Xu axioms remain valid (they were designed for reflexive operators)
- `until_intro` becomes sound (the specific fix needed)
- `until_unfold` remains sound (reflexive G at t includes `phi U psi` at t itself, which is what we're decomposing)
- T-axioms `G phi -> phi` and `H phi -> phi` remain valid

### If we switch to strict G/H: what changes

1. **T-axioms must be dropped**: `G phi -> phi` and `H phi -> phi` are invalid
2. **TA must change**: Currently `phi -> G P phi`. Under strict G: `G P phi` at t means for all s > t, P phi at s. Under strict P, this means for all s > t, exists u < s with phi(u). Take u = t when s > t. Valid on Int. **TA remains valid under fully strict semantics on Int.**
3. **Unfold/Intro axioms must change**: With strict G, the standard Burgess-Xu unfold/intro become unsound. The axioms need to be reformulated, likely using the discrete next-step operator approach:
   - `phi U psi <-> psi v (phi ^ X(phi U psi))` (where X is next-step, definable as `bot U` under strict Until)
4. **Numerous downstream changes**: Every lemma using `G phi -> phi` breaks. The canonical model construction changes fundamentally.

### The half-open Until + strict G challenge for backward truth lemma

The plan v7's extensive analysis (Phase 4) identifies that the backward truth lemma for Until is extremely difficult under the current axiom system. The root issue: `until_intro`'s second disjunct uses `G(phi U psi)`, which requires `phi U psi` at ALL future times, but the semantic witness only provides information up to time s.

Under strict G, this problem is WORSE: `G(phi U psi)` means `phi U psi` at all s > t, still requiring coverage of all future times beyond the witness.

Under strict G + strict Until + discrete order, the natural axiom is:
```
phi U psi <-> psi v (phi ^ X(phi U psi))
```
where `X(phi U psi)` means `phi U psi` at t+1 only. This makes backward induction TRIVIAL: from `phi U psi` at t+1 and `phi` at t, derive `phi U psi` at t. This is exactly what the plan v7 identifies as the missing piece (a "next-step Until introduction axiom").

**Confidence**: HIGH

## Recommendations for the Ideal Logic

### If redesigning from scratch (the ideal end state)

The ideal TM logic over Int would use:

1. **Fully strict temporal semantics**:
   - `G phi at t := forall s > t, phi(s)`
   - `H phi at t := forall s < t, phi(s)`
   - `phi U psi at t := exists s > t, psi(s) ^ forall u, t < u < s -> phi(u)` (fully strict)
   - `phi S psi at t := exists s < t, psi(s) ^ forall u, s < u < t -> phi(u)` (fully strict)

2. **Discrete axioms via definable next/previous**:
   - `X phi := bot U phi` (next-step, definable)
   - `Y phi := bot S phi` (previous-step, definable)
   - `phi U psi <-> psi v (phi ^ X(phi U psi))` (discrete unfold -- derivable, not an axiom)
   - `phi S psi <-> psi v (phi ^ Y(phi S psi))` (discrete unfold for Since)

3. **Complete axiom set**: Burgess-Xu base + Venema discrete extension + S5 modal + interaction axioms

4. **Benefits**:
   - Maximum expressiveness (Kamp's theorem, next-step definability)
   - Clean definability: `F = top U`, `P = top S`, `X = bot U`, `Y = bot S`
   - Backward truth lemma becomes straightforward via discrete induction with X
   - No T-axiom complications (present is always handled separately)
   - Standard in the philosophical/mathematical logic literature

5. **Costs**:
   - Massive refactoring: every use of `G phi -> phi` must be replaced
   - The TA axiom `phi -> G P phi` changes meaning but remains valid
   - temp_a (`phi -> G(some_past phi)` under strict G) is `phi -> forall s > t, exists u < s, phi(u)`. Valid on Int by taking u = t.
   - All soundness proofs for temporal axioms must be redone
   - The canonical model construction changes significantly

### If making minimal changes (pragmatic recommendation)

Keep reflexive G/H and switch to half-open Until/Since (plan v7). This is the path of least resistance and matches the current axiom system's design assumptions.

**However**, consider adding a DERIVED lemma for the backward truth lemma:

The key insight from the strict semantics analysis: the natural backward induction axiom for discrete Until is `phi ^ X(phi U psi) -> phi U psi`. Under the current reflexive system with half-open Until:
- `X` is not primitive, but the Succ relation in the canonical construction provides its equivalent
- The derivation `phi ^ F(phi U psi) -> phi U psi` is NOT valid in general (F is too weak)
- BUT: in the canonical model over Int, the Succ relation gives exactly the discrete step-by-step structure

The backward truth lemma should use the contradiction approach identified in Phase 4 of the plan, leveraging `forward_F` and the minimality of the witness.

### The missing piece for plan v7

After thorough analysis, the backward truth lemma difficulty stems from a fundamental axiom design choice: using `G` (all future) in `until_intro` instead of `X` (next step). On a discrete order, these are very different strengths.

**Two options to resolve this**:
1. **Add the axiom `phi ^ F(phi U psi) -> phi U psi` for discrete orders**: This is derivable from `until_intro` + discreteness IF `F(phi U psi) -> G(phi U psi)` were valid (it's not in general). But in a DISCRETE order with NO endpoints, this specific instance can be derived via a more complex argument using `until_induction` + `discreteness_forward`.
2. **Use the U-Induction axiom directly in the backward truth lemma**: Instantiate `chi` in `G(psi -> chi) ^ G(phi ^ chi -> G chi) -> (phi U psi -> chi)` with a formula that encodes "phi U psi is witnessed by now or later." The right instantiation is the key insight the plan is missing.

**Confidence**: HIGH for the analysis, MEDIUM for the specific implementation path.

## Summary Table

| Aspect | Reflexive G/H + Closed U/S (current) | Reflexive G/H + Half-Open U/S (plan v7) | Strict G/H + Strict U/S (ideal) |
|--------|---------------------------------------|------------------------------------------|----------------------------------|
| T-axiom (G phi -> phi) | Valid | Valid | INVALID |
| until_intro sound | NO | YES | YES (with X-based variant) |
| until_unfold sound | NO | Partially (G version still problematic) | YES (with X-based variant) |
| F = top U | Yes (reflexive F) | No (top U = phi v F phi) | Yes (strict F) |
| X definable | No | No | Yes (bot U) |
| Kamp expressiveness | Weaker | Weaker | Full FOMLO |
| Backward truth lemma | Blocked | Hard (G too strong) | Easy (X gives discrete induction) |
| Refactoring cost | None | ~380 lines | ~2000+ lines |
| Literature alignment | CS standard | Hybrid | Math/philosophy standard |

## References

- Burgess, J. (1982). "Axioms for tense logic I: Since and Until"
- Xu, M. (1988). "On some U,S-tense logics"
- Kamp, H. (1968). "Tense Logic and the Theory of Linear Order"
- Venema, Y. (1993). "Completeness via Completeness" (extensions for strict discrete orders)
- Reynolds, M. (1994, 1996). Extensions for strict linear orderings
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic: Mathematical Foundations and Computational Aspects"
- Stanford Encyclopedia of Philosophy, "Temporal Logic" and Burgess-Xu supplement
