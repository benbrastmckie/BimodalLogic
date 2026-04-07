# Research Report: F_until_equiv Resolution — What Needs to Change

**Task**: 83 — Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Author**: Teammate A (Research Round 31)
**Focus**: Exhaustive analysis of all viable options for resolving the F_until_equiv unsoundness

## Executive Summary

The axiom `F_until_equiv`: `F(psi) -> T U psi` is unsound under the current mixed semantics (G/H reflexive, U/S strict). This report analyzes five resolution options with codebase-level specificity. **Option A (make Until/Since reflexive) is the recommended path**, with Option E (add F-unfold axiom) as a viable alternative. Options B, C, and D are not viable.

---

## 1. Current Semantics (Baseline)

From `Truth.lean:125-130`:
```
all_past phi  := forall s, s <= t -> truth_at ... s phi    -- H: reflexive
all_future phi := forall s, t <= s -> truth_at ... s phi    -- G: reflexive
untl phi psi  := exists s, t < s /\ truth_at ... s psi /\  -- U: strict
                 forall r, t < r -> r < s -> truth_at ... r phi
snce phi psi  := exists s, s < t /\ truth_at ... s psi /\  -- S: strict
                 forall r, s < r -> r < t -> truth_at ... r phi
```

Key derived semantics:
- `F(psi) = neg(G(neg(psi)))` = `exists s >= t, psi(s)` — **includes present** (s=t)
- `P(psi) = neg(H(neg(psi)))` = `exists s <= t, psi(s)` — **includes present** (s=t)
- `T U psi` = `exists s > t, psi(s)` — **strictly future**
- `T S psi` = `exists s < t, psi(s)` — **strictly past**
- `X(phi) = bot U phi` = `exists s > t, phi(s) /\ forall r, t < r -> r < s -> False` — **next time**
- `Y(phi) = bot S phi` = `exists s < t, phi(s) /\ forall r, s < r -> r < t -> False` — **previous time**

The gap: `F(psi)` allows witness s=t, but `T U psi` requires s > t. When the ONLY witness for F(psi) is the present, there is no strictly future witness for Until.

---

## 2. Option A: Make Until/Since Reflexive

### Change: `t < s` to `t <= s` in truth_at

**Specific change in Truth.lean (lines 127-130)**:
```lean
-- FROM:
| Formula.untl phi psi => exists s : D, t < s /\ truth_at M Omega tau s psi /\
    forall r : D, t < r -> r < s -> truth_at M Omega tau r phi
| Formula.snce phi psi => exists s : D, s < t /\ truth_at M Omega tau s psi /\
    forall r : D, s < r -> r < t -> truth_at M Omega tau r phi

-- TO:
| Formula.untl phi psi => exists s : D, t <= s /\ truth_at M Omega tau s psi /\
    forall r : D, t < r -> r < s -> truth_at M Omega tau r phi
| Formula.snce phi psi => exists s : D, s <= t /\ truth_at M Omega tau s psi /\
    forall r : D, s < r -> r < t -> truth_at M Omega tau r phi
```

Note: The guard clause `forall r, t < r -> r < s -> phi(r)` stays with STRICT bounds for `r`. This is correct: when `s = t`, the interval `(t, s)` is empty, so the guard is vacuously true.

### Impact on F_until_equiv (the target)

**RESOLVES the sorry at Soundness.lean:770.** Proof sketch:
- Given `F(psi)` at t: exists s >= t, psi(s)
- Under reflexive Until: `T U psi` at t means exists s >= t, psi(s) (guard vacuously true for T)
- The same witness works. QED.

The sorry at line 786 (P_since_equiv) is also resolved symmetrically.

### Impact on X (Next) = bot U phi

**CRITICAL CONCERN**: Under reflexive Until, `X(phi) = bot U phi` becomes:
```
exists s >= t, phi(s) /\ forall r, t < r -> r < s -> False
```

When `s = t`: `phi(t)` must hold, and the guard `forall r, t < r -> r < t -> False` is vacuously true.
When `s > t`: must have `phi(s)` and no `r` with `t < r < s`, i.e., `s = succ(t)`.

So X(phi) becomes: **phi(t) OR phi(succ(t))** — it now includes the present!

This is a **major semantic change**. X should mean "at the next time step", not "now or at the next time step". All axioms involving X (next) would need revision:

| Axiom | Current Meaning | Meaning with Reflexive U | Status |
|-------|-----------------|--------------------------|--------|
| `until_unfold` | `phi U psi -> X(psi \/ (phi /\ phi U psi))` | X now includes present | **Remains valid** (weaker conclusion) |
| `until_intro` | `X(psi \/ (phi /\ phi U psi)) -> phi U psi` | X now includes present | **Becomes too strong** (stronger premise) |
| `until_induction` | `G(...) -> (phi U psi -> X(chi))` | X includes present | **May break** (conclusion too weak) |
| `x_k_dist` | `X(phi -> psi) -> (X(phi) -> X(psi))` | Distributes over present+next | **Remains valid** |
| `x_det` | `neg(X(phi)) -> X(neg(phi))` | Determinism includes present | **BREAKS** |
| `yx_identity` | `Y(X(phi)) -> phi` | Y(X(phi)) with reflexive = different | **BREAKS** |
| `xy_identity` | `X(Y(phi)) -> phi` | Same | **BREAKS** |

**x_det analysis**: `neg(X(phi)) -> X(neg(phi))` becomes `neg(phi(t) \/ phi(succ(t))) -> neg(phi)(t) \/ neg(phi)(succ(t))` which is `neg(phi)(t) /\ neg(phi)(succ(t)) -> neg(phi)(t) \/ neg(phi)(succ(t))`. This is still valid (trivially). Wait — let me reconsider.

Actually, `neg(X(phi))` under reflexive Until = `neg(exists s >= t, phi(s) /\ guard)`. This means `forall s >= t` with the guard, `neg(phi(s))`. But `X(neg(phi))` = `exists s >= t, neg(phi)(s) /\ guard`. So `neg(X(phi))` implies `neg(phi)(t)` which gives `X(neg(phi))` with witness `s = t`. So **x_det actually remains valid under reflexive Until**.

**yx_identity analysis**: `Y(X(phi)) -> phi`. Y is `bot S X(phi)` = `exists s <= t, X(phi)(s) /\ forall r, s < r -> r < t -> False`. With reflexive S, this becomes `exists s <= t, X(phi)(s) /\ guard`. When `s = t`: `X(phi)(t)`, which means `phi(t) \/ phi(succ(t))`. This does NOT imply `phi(t)`. **BREAKS.**

Actually wait, under reflexive S, Y also changes. Let me redo:
- `Y(chi) = bot S chi` where S is now reflexive: `exists s <= t, chi(s) /\ forall r, s < r -> r < t -> False`
- With `s = t`: chi(t) holds (guard vacuous). So Y(chi) includes present: Y(chi) at t holds whenever chi(t) holds.
- `Y(X(phi))` at t: `X(phi)(t)` holds (taking s=t in Y), which means `phi(t)` holds (taking s=t in X). So `phi(t)`. **Actually VALID!**

Let me be more careful. Y(X(phi)) at t:
- Exists s <= t with X(phi)(s) and no r with s < r < t
- Case s = t: X(phi)(t). X(phi)(t) = exists q >= t with phi(q) and guard. Taking q = t: phi(t). But X(phi)(t) does NOT require phi(t) — it could be phi(succ(t)) with q = succ(t).
- So Y(X(phi)) at t gives X(phi)(t) which gives phi(t) OR phi(succ(t)), NOT necessarily phi(t). **BREAKS.**

### Impact on Y (Yesterday) = bot S phi

Same analysis as X. Y(phi) now includes the present. `Y(phi)` at t means `phi(t) \/ phi(pred(t))`.

### Impact on until_unfold soundness

`phi U psi -> X(psi \/ (phi /\ phi U psi))`:
Under reflexive Until: `phi U psi` at t means exists s >= t with psi(s) and guard.
- If s = t: psi(t). X(psi \/ ...) at t: take witness q = t, (psi \/ ...)(t) = True. Valid.
- If s > t: same as before (shift to succ(t)).
**Remains valid.**

### Impact on until_intro soundness

`X(psi \/ (phi /\ phi U psi)) -> phi U psi`:
Under reflexive Until: X(chi) at t means exists q >= t with chi(q) and guard.
- If q = t: (psi \/ (phi /\ phi U psi))(t). If psi(t): take s = t in Until. If phi(t) /\ phi U psi at t: already have phi U psi.
**Remains valid** (both cases work).

### Impact on until_induction

`G(psi -> chi) /\ G((phi /\ X(chi)) -> chi) -> (phi U psi -> X(chi))`:
Under reflexive: phi U psi at t gives witness s >= t. If s = t: psi(t), G says psi(t) -> chi(t), so chi(t), thus X(chi)(t) (take q=t). If s = succ(t): need to induct. The induction base gives chi(s) from psi(s), then step gives chi(s-1) from phi(s-1) /\ X(chi)(s-1). X(chi)(s-1) holds because chi(s) (with witness q = s which is s-1+1 = succ(s-1)). So chi(succ(t)), giving X(chi)(t) with witness succ(t). **Remains valid.**

### Impact on yx_identity

As analyzed above: **BREAKS**. Y(X(phi)) at t gives X(phi)(t) which is phi(t) \/ phi(succ(t)), not necessarily phi(t).

### Impact on xy_identity

`X(Y(phi)) -> phi`: X(Y(phi)) at t means exists q >= t with Y(phi)(q) and guard. Taking q = t: Y(phi)(t) = phi(t) \/ phi(pred(t)). Not necessarily phi(t). **BREAKS.**

### Impact on G_implies_X (TemporalDerived.lean)

G(a) -> X(a). This uses F_until_equiv to get G(a) -> T U a, then until_induction to get T U a -> X(a). Under reflexive semantics, G(a) at t gives a(t), and X(a) at t (reflexive) includes a(t). So this becomes **trivially valid** (too easy, which is fine).

### Published Literature Compatibility

**Burgess 1984**: Uses strict Until. The standard "Burgess axiomatization" assumes strict Until with `phi U psi := exists s > t, psi(s) /\ forall r in (t,s), phi(r)`.

**GHR 1994 (Gabbay, Hodkinson, Reynolds)**: Also uses strict Until. Their completeness proof for Until logic over Z uses strict semantics.

**Prior convention**: Most temporal logic literature uses strict Until. Making Until reflexive is non-standard.

**However**: The combination of **reflexive G/H** with **strict U/S** is ALSO non-standard. Most literature either has everything strict or everything reflexive. The current mixed approach is the source of the problem.

### Summary for Option A

| Metric | Assessment |
|--------|------------|
| Files changed | Truth.lean (2 lines), Soundness.lean (multiple proofs), all until/since soundness proofs |
| Axioms that break | `yx_identity`, `xy_identity` definitively break |
| Axioms that become trivial | `seriality_future`, `seriality_past` (already trivial) |
| Sorries resolved | F_until_equiv (line 770), P_since_equiv (line 786) |
| Estimated effort | 200-400 lines changed across Soundness.lean, plus cascading changes |
| Confidence | **40%** — the yx_identity/xy_identity breakage is a dealbreaker unless those can be reformulated |
| Literature match | **Non-standard** — no major reference uses reflexive Until |

---

## 3. Option B: Make G/H Strict

### Change: `t <= s` to `t < s` in truth_at for all_future/all_past

**Specific change in Truth.lean (lines 125-126)**:
```lean
-- FROM:
| Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
| Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi

-- TO:
| Formula.all_past phi => forall (s : D), s < t -> truth_at M Omega tau s phi
| Formula.all_future phi => forall (s : D), t < s -> truth_at M Omega tau s phi
```

### Immediate Consequences: T-Axiom Breakage

**temp_t_future** (`G(phi) -> phi`): Under strict G, `G(phi)` at t means `forall s > t, phi(s)`. This says NOTHING about phi(t). **UNSOUND. Axiom must be removed.**

**temp_t_past** (`H(phi) -> phi`): Same. **UNSOUND. Axiom must be removed.**

### Cascading Impact

T-axioms are **base axioms** (classified as `Axiom.isBase = true` at Axioms.lean:792-793). They are valid on ALL linear orders. Removing them would restructure the entire axiom system.

Downstream dependencies of T-axioms (via grep for `temp_t_future` and `temp_t_past` in the codebase):

1. **Soundness.lean**: `temp_t_future_valid`, `temp_t_past_valid` — these proofs would be deleted
2. **SuccChainFMCS.lean**: T-axiom constructors used for temporal coherence
3. **UltrafilterChain.lean**: T-axioms used in BFMCS construction
4. **DovetailedChain.lean**: Uses G -> phi (T-axiom) for content propagation
5. **DeterministicChain.lean**: `g_content_propagates_to_x_content` uses `G_implies_X` which uses T-axiom transitively (via seriality_future -> F_until_equiv chain, but also separately)

Additionally, `F(phi) = neg(G(neg(phi)))` under strict G means `exists s > t, phi(s)` — strictly future. This would make F_until_equiv valid (both sides strictly future), BUT at the cost of losing T-axioms, which are **load-bearing** for the entire completeness architecture.

### Effort Estimate

Every place that uses `G(phi) -> phi` or `H(phi) -> phi` would need restructuring. The entire approach to temporal coherence in the algebraic completeness depends on being able to extract present-time truth from G formulas. This is **not viable** without a complete architectural rewrite.

### Summary for Option B

| Metric | Assessment |
|--------|------------|
| Files changed | Truth.lean (2 lines), plus 10+ files with T-axiom dependencies |
| Axioms that break | `temp_t_future`, `temp_t_past` — the most fundamental temporal axioms |
| Sorries resolved | F_until_equiv, P_since_equiv |
| New sorries created | Dozens — every use of T-axioms |
| Estimated effort | 2000+ lines — complete rewrite of algebraic completeness |
| Confidence | **2%** — not viable |
| Literature match | Standard strict semantics (Burgess, GHR), but T-axiom loss is fatal |

---

## 4. Option C: Redefine F/P with Strict Semantics

### The Idea

Make F(psi) mean `exists s > t, psi(s)` explicitly, rather than deriving it as `neg(G(neg(psi)))`.

### The Problem: Duality Breakage

Currently, F is a **defined** operator:
```lean
-- Formula.lean:406
def some_future (phi : Formula) : Formula := phi.neg.all_future.neg
```

F(psi) = `neg(G(neg(psi)))`. Under reflexive G:
- `G(neg(psi))` at t = `forall s >= t, neg(psi)(s)`
- `neg(G(neg(psi)))` at t = `exists s >= t, psi(s)` — includes present

To make F strict, we'd need either:
1. **Add F as a primitive operator** to the Formula type — fundamental change to the entire syntax
2. **Define F differently** — but there's no way to define `exists s > t` using only G (which is reflexive)

If we add F as a primitive:
- Formula type changes (Syntax/Formula.lean)
- Every match on Formula needs a new case (40+ pattern matches across the codebase)
- SubformulaClosure, DerivationTree, everything needs updating
- The classical duality `F = neg G neg` would become a derived theorem rather than a definition

### Effort Estimate

Adding a primitive operator to the Formula type is one of the most invasive changes possible. Every file that pattern-matches on Formula would need updating. This is estimated at 3000+ lines across 20+ files.

### Summary for Option C

| Metric | Assessment |
|--------|------------|
| Files changed | Syntax/Formula.lean, plus every file matching on Formula (20+ files) |
| Axioms that break | None inherently, but all existing F-based axioms/theorems need restatement |
| Sorries resolved | F_until_equiv, P_since_equiv |
| Estimated effort | 3000+ lines |
| Confidence | **5%** — technically correct but prohibitively expensive |
| Literature match | Non-standard (no standard system has F as primitive with G reflexive) |

---

## 5. Option D: Drop F_until_equiv Axiom

### Direct Dependencies

Searching the codebase for `F_until_equiv` and `Axiom.F_until_equiv`:

1. **TemporalDerived.lean** (lines 56-62): `G_implies_topUntil` chains `seriality_future` with `F_until_equiv` to derive `G(a) -> T U a`. This is used by `G_implies_X` (line 110) which is **critical infrastructure**.

2. **FiniteDeferral.lean** (lines 43-55): `F_to_until_in_mcs` and `F_to_until_in_chain` use F_until_equiv to convert F-obligations to Until-obligations for the pigeonhole argument.

3. **DovetailedChain.lean** (lines 567-574): `F_implies_until_in_mcs` — same conversion for dovetailed chain.

4. **DeterministicChain.lean** (line 317): Comment indicates `g_content_propagates_to_x_content` is proven via `G_implies_X` which depends on F_until_equiv.

### The G_implies_X Problem

`G_implies_X` (`G(a) -> X(a)`) is **the most critical derived theorem** in the system. It's what allows G-content to propagate through the chain. Its proof (TemporalDerived.lean:110) goes:

1. `G(a) -> F(a)` via `seriality_future`
2. `F(a) -> T U a` via `F_until_equiv`
3. `T U a -> X(a)` via `until_induction`
4. Chain: `G(a) -> X(a)`

**Without F_until_equiv, step 2 fails**, and there's no obvious alternative derivation.

**Can G_implies_X be proven without F_until_equiv?** Under the current semantics:
- `G(a)` at t: forall s >= t, a(s). In particular, a(t) and a(succ(t)).
- `X(a)` at t: exists s > t, a(s) and no r with t < r < s. On discrete frames, s = succ(t).
- Semantically: `G(a) -> X(a)` IS valid (take s = succ(t)).
- But can it be DERIVED without F_until_equiv?

Alternative derivation ideas:
- `G(a) -> G(a)` (trivial), then `G(a)` gives a at all future times, including succ(t). But how to extract X(a) syntactically?
- Need: `G(a) -> bot U a`. One route: `G(a) -> a` (T-axiom) gives a(t). `G(a) -> G(G(a))` (temp_4) gives G(a) at future times. But converting to Until format requires exactly the F-to-Until bridge.
- Another route: use `disc_next` axiom. `disc_next` is `G(phi) -> X(G(phi))` — already gets us X of something from G. But we need X(a), not X(G(a)). Then `X(G(a)) -> X(a)` via x_k_dist + temp_t_future... Actually:
  - `G(a) -> a` is temp_t_future (a T-axiom)
  - `X(G(a) -> a)` is X-necessitation of temp_t_future... but X-necessitation requires `G_implies_X` (circular!)
  - Alternative: `x_k_dist` gives `X(G(a) -> a) -> (X(G(a)) -> X(a))`. We have `X(G(a))` from `disc_next`. We need `X(G(a) -> a)`.
  - `G(a) -> a` is a theorem. X-necessitation of theorems: if `|- phi` then `|- X(phi)`. This uses temporal necessitation `|- G(phi)` then `G_implies_X` to get `X(phi)`. **CIRCULAR.**

Wait, let me check disc_next more carefully.

<checking Axioms.lean for disc_next>

```lean
| disc_next : Axiom (Formula.all_future φ |>.imp (Formula.untl Formula.bot φ.all_future))
```

Wait, that's not right. Let me check the actual definition...

Actually from the grep output: `disc_next` is in the Discrete axiom set. Let me find its exact formula.

### Can G_implies_X be derived differently?

The key question: can we derive `|- G(a) -> X(a)` without going through `F_until_equiv`?

**Attempt via disc_next**: If disc_next is `G(phi) -> X(G(phi))`, then:
1. `G(a) -> X(G(a))` (disc_next)
2. We need `X(G(a)) -> X(a)`. This requires `X(G(a) -> a) /\ X(G(a)) -> X(a)` by x_k_dist.
3. For `X(G(a) -> a)`: this is `X(temp_t_future)`. Getting X of a theorem requires X-necessitation, which requires G_implies_X. **CIRCULAR.**

**Attempt via until_induction directly**: Without `T U a`, we can't apply until_induction to get `X(a)`.

**Conclusion**: Dropping F_until_equiv without providing an alternative route to G_implies_X would be **catastrophic**. The entire chain infrastructure depends on G-to-X conversion.

### Alternative Completeness Strategy Without F-to-U Conversion

One could try to avoid the F-to-U conversion entirely:
- Instead of converting F(psi) to (T U psi) and using Until persistence, work directly with F(psi) = neg(G(neg(psi))).
- But F(psi) in an MCS means neg(G(neg(psi))) in MCS, which means G(neg(psi)) not in MCS. This is a NEGATIVE fact — we know G(neg(psi)) is absent, but this doesn't propagate forward through Lindenbaum extensions.

This is exactly the "F-persistence" problem identified in DovetailedChain.lean:644: "F(psi) = neg(G(neg(psi))) not preserved through Lindenbaum extensions (G(neg(psi)) can enter freely)."

### Summary for Option D

| Metric | Assessment |
|--------|------------|
| Files changed | Axioms.lean (remove 2 constructors), Soundness.lean, TemporalDerived.lean |
| Axioms that break | G_implies_X (derived theorem) — entire chain infrastructure |
| Sorries resolved | F_until_equiv, P_since_equiv (by deletion) |
| New blockers | G_implies_X has no known alternative derivation |
| Estimated effort | If G_implies_X can be reproved: 100-200 lines. If not: unrecoverable. |
| Confidence | **10%** — G_implies_X seems unprovable without F-U bridge or a new axiom |

---

## 6. Option E: Add an F-Unfold Axiom

### The Idea

Instead of `F(psi) -> T U psi`, add `F(psi) -> psi \/ X(F(psi))` (or equivalently `F(psi) -> psi \/ (T U psi)`).

### Semantic Validity

`F(psi) -> psi \/ X(F(psi))`:
- `F(psi)` at t: exists s >= t, psi(s)
- If s = t: psi(t). First disjunct.
- If s > t: exists s > t, psi(s). At succ(t), exists s >= succ(t), psi(s) (since s > t implies s >= succ(t) on discrete frames). So F(psi) at succ(t). X(F(psi)) at t holds.

**VALID** under current mixed semantics on discrete frames.

### Alternative Formulation: `F(psi) -> psi \/ (T U psi)`

- If s = t: psi(t). First disjunct.
- If s > t: T U psi at t (take the same witness, guard vacuously true for T). Second disjunct.

**ALSO VALID** and more directly useful.

### Can This Replace F_until_equiv?

The current usage of F_until_equiv is to convert F(psi) to (T U psi) for Until persistence/pigeonhole arguments. With the new axiom `F(psi) -> psi \/ (T U psi)`, the proof of G_implies_X would change:

**New derivation of G_implies_topUntil**: `G(a) -> T U a`:
1. `G(a) -> F(a)` (seriality_future, trivially valid)
2. `F(a) -> a \/ (T U a)` (new axiom)
3. `G(a) -> a \/ (T U a)` (chain 1+2)
4. `G(a) -> a` (temp_t_future)
5. If a: need to show T U a. From G(a), we get a at all future times. On discrete frames, a(succ(t)), so T U a holds with witness succ(t)... But this still needs the F-to-U bridge for the second case!

Wait, let me think again. We need `G(a) -> T U a`. With the new axiom:
1. `G(a) -> F(a)` (seriality)
2. `F(a) -> a \/ (T U a)` (new axiom)
3. So `G(a) -> a \/ (T U a)`.

But we need just `T U a`, not `a \/ (T U a)`. In the case where only `a` holds (not `T U a`):
- `G(a)` gives `a(t)` and `a(succ(t))` and `a(succ(succ(t)))`, etc.
- We need `T U a` at t: exists s > t with a(s). Take s = succ(t). But we need to DERIVE this, not just argue semantically.

The derivation needs: from `G(a)` and `a` (but not `T U a`), derive `T U a`. This is:
- `G(a) -> F(a)` (seriality)
- `F(a) -> a \/ (T U a)` (new axiom)
- In the `a` branch: we already have `G(a)`, so `G(G(a))` by temp_4, so `F(G(a))` by seriality on G(a), so `G(a) \/ (T U G(a))` by new axiom. In the `T U G(a)` branch: `T U G(a)` gives a witness s > t with G(a)(s), so a(s), giving T U a. In the `G(a)` branch... we're cycling.

This seems circular. Let me try a different approach.

**Alternative: Use disc_next directly.** If we can show `disc_next` gives `G(a) -> X(G(a))`, and we have the new F-unfold axiom, can we close G_implies_X?

Actually, wait. Let me re-examine what disc_next actually is.

### Checking disc_next

From Axioms.lean, searching for `disc_next`:

```lean
| disc_next : Axiom (...)
```

Let me check the exact formula.

After re-reading the axiom, disc_next represents discreteness: `G(phi) -> X(phi)` is NOT necessarily disc_next. The actual disc_next might be something different. Let me check.

From the comment in the axiom file: "disc_next", "disc_prev" — these relate to the discreteness of the order. In many formulations, disc_next is `G(phi) -> phi /\ X(G(phi))` (G unfolds to present-and-next-G).

Under reflexive G: `G(phi)` at t = forall s >= t, phi(s). This unfolds to phi(t) /\ (forall s >= succ(t), phi(s)) = phi(t) /\ G(phi)(succ(t)). And G(phi)(succ(t)) can be expressed as X(G(phi))(t) under appropriate semantics. So `G(phi) -> phi /\ X(G(phi))` should be disc_next under reflexive G.

If disc_next is `G(phi) -> X(G(phi))` or `G(phi) -> phi /\ X(G(phi))`:
1. `G(a) -> X(G(a))` (disc_next, dropping the phi part if conjoined)
2. With G(a) at succ(t) (inside X), we have a(succ(t)) by T-axiom.
3. But getting from X(G(a)) to X(a) requires X to be monotone (distribute over implication): `X(G(a) -> a) -> (X(G(a)) -> X(a))` by x_k_dist. Need `X(G(a) -> a)`.
4. `G(a) -> a` is a theorem. X-necessitation of a theorem gives `X(G(a) -> a)`... IF we have X-necessitation.
5. X-necessitation uses temporal necessitation + G_implies_X. **CIRCULAR.**

Unless we add X-necessitation as a primitive rule or add a different axiom that gives it.

### The Real Fix with Option E

The cleanest version of Option E: replace `F_until_equiv` with the axiom:

**`F_unfold_disc`: `F(psi) <-> psi \/ X(F(psi))`**

Or at minimum the forward direction: `F(psi) -> psi \/ X(F(psi))`.

This is semantically valid. To derive G_implies_X from it:

1. `G(a) -> F(a)` (seriality)
2. `F(a) -> a \/ X(F(a))` (new axiom)
3. `G(a) -> a \/ X(F(a))` (chain)
4. Case a: `G(a) -> a` by T-axiom (redundant, already have a)
5. Need: from `G(a)` and `a`, derive `X(a)`. Still stuck here.

From `G(a)` and the above:
- `G(a) -> G(G(a))` (temp_4)
- `G(G(a)) -> F(G(a))` (seriality on G(a))
- `F(G(a)) -> G(a) \/ X(F(G(a)))` (new axiom on G(a))
- In the G(a) branch: cycling.
- In the X(F(G(a))) branch: `X(F(G(a)))` at t means F(G(a)) at succ(t), means exists s >= succ(t) with G(a)(s), means a at all times >= s >= succ(t), so a(succ(t)). But we need to DERIVE X(a) from X(F(G(a))), which requires:
  - `F(G(a)) -> a` is derivable (F(G(a)) means G(a) at some point, G(a) gives a)
  - `X(F(G(a)) -> a) -> X(F(G(a))) -> X(a)` by x_k_dist
  - Need `X(F(G(a)) -> a)` — again needs X-necessitation.

**This is fundamentally the same circularity.** Without an independent path to X-necessitation or G_implies_X, Option E alone cannot derive G_implies_X.

### Breaking the Circularity: Add disc_next as G(a) -> X(a) Directly

What if we check whether `disc_next` IS actually `G(a) -> X(a)` (where X = bot U)?

Let me look more carefully at disc_next.

Actually, I realize I should just read the axiom definition directly.

### Summary for Option E (Preliminary)

| Metric | Assessment |
|--------|------------|
| Files changed | Axioms.lean (modify 1 constructor), Soundness.lean (new validity proof) |
| Axioms that break | None inherently |
| Sorries resolved | F_until_equiv (line 770), P_since_equiv (line 786) — by replacement |
| New issue | G_implies_X derivation may need additional new axioms |
| Estimated effort | 100-300 lines if G_implies_X works out, much more if not |
| Confidence | **35%** — semantically sound but derivation completeness uncertain |

---

## 7. Comprehensive Comparison and Recommendation

### Viability Matrix (Updated)

| Option | Resolves sorry | T-axioms | X/Y identity | G_implies_X | Effort | Confidence |
|--------|---------------|----------|--------------|-------------|--------|------------|
| A: Reflexive U/S | Yes | OK | **BREAKS** | Trivial | 200-400 | 30% |
| B: Strict G/H | Yes | **BREAKS** | OK | Rework | 2000+ | 2% |
| C: Primitive F | Yes | OK | OK | Rework | 3000+ | 5% |
| D: Drop axiom | Yes (delete) | OK | OK | **BLOCKED** | 100-2000+ | 10% |
| E: F-unfold only | Yes (replace) | OK | OK | **CIRCULAR** | 100-300 | 25% |
| **E': F-unfold + G_to_X** | **Yes** | **OK** | **OK** | **Axiom** | **150-250** | **75%** |

### The Fundamental Tension

1. **G/H are reflexive** (s >= t / s <= t) — needed for T-axioms `G(phi) -> phi`
2. **U/S are strict** (s > t / s < t) — needed for X/Y to mean "next/previous"
3. **F = neg(G(neg))** is a definition, so F inherits G's reflexivity (includes present)
4. **T U psi** requires strictly future witness

No single-point change resolves all of these. The correct approach is to **accept the mixed semantics** and provide axioms that bridge the gap rather than trying to eliminate it.

### Recommended Path: Option E' (F-unfold + G_to_X)

Replace the 2 unsound axioms with 4 sound axioms:

| Remove | Add | Valid Under Mixed Semantics |
|--------|-----|---------------------------|
| `F_until_equiv`: `F(psi) -> T U psi` | `F_unfold_disc`: `F(psi) -> psi \/ (T U psi)` | Yes (case split on present vs future witness) |
| `P_since_equiv`: `P(psi) -> T S psi` | `P_unfold_disc`: `P(psi) -> psi \/ (T S psi)` | Yes (symmetric) |
| (derived G_implies_X via F_until_equiv) | `G_to_X`: `G(phi) -> bot U phi` | Yes (G gives phi(succ(t)), take witness) |
| (derived H_implies_Y via P_since_equiv) | `H_to_Y`: `H(phi) -> bot S phi` | Yes (symmetric) |

This preserves every existing axiom and theorem except the 2 removed, breaks no sound infrastructure, and provides direct replacements for the critical `G_implies_X` / `H_implies_Y` derived theorems.

### CRITICAL FINDING: disc_next Definition

I have now verified `disc_next` (Axioms.lean:621-631):
```lean
| disc_next :
    Axiom ((Formula.neg Formula.bot).some_future.imp
      (Formula.untl Formula.bot (Formula.neg Formula.bot)))
```

This is `F(T) -> X(T)` — "if there exists a future time, there exists a next time." It is NOT `G(a) -> X(a)`. It is much weaker and does NOT directly help derive G_implies_X.

### Revised Option E Assessment

Since disc_next cannot substitute for the F_until_equiv chain in deriving G_implies_X, Option E (replacing F_until_equiv with `F(psi) -> psi \/ (T U psi)`) still has the G_implies_X circularity problem.

**However**, there is another approach: replace `F_until_equiv` with a STRONGER axiom that directly gives `G(a) -> X(a)`:

**Option E': Add `G_to_X` as a new axiom**: `G(phi) -> X(phi)`

This is semantically valid under mixed semantics:
- G(phi) at t: forall s >= t, phi(s). In particular phi(succ(t)).
- X(phi) at t: exists s > t, phi(s) and no r with t < r < s. Take s = succ(t) on discrete frames.

This would:
1. Replace F_until_equiv (remove the unsound axiom)
2. Directly provide G_implies_X (no derivation needed — it IS the axiom)
3. Allow H_implies_Y to be added as the dual `H(phi) -> Y(phi)`
4. The FiniteDeferral/DovetailedChain consumers would need `F -> T U` conversion, which could be derived: `F(psi) -> psi \/ (T U psi)` as a THEOREM from existing axioms + G_to_X.

**Can we derive `F(psi) -> psi \/ (T U psi)` from existing axioms + G_to_X?**
- F(psi) = neg(G(neg(psi))). By classical logic: either psi or neg(psi) at t.
- If psi(t): first disjunct, done.
- If neg(psi)(t): F(psi) gives exists s >= t with psi(s). Since neg(psi)(t), s > t. So T U psi with witness s (guard vacuous for T). **Semantically valid.**
- Derivation: classical case split on psi. In the neg(psi) case: F(psi) and neg(psi) implies... we need to extract a strict future witness. F(psi) = neg(G(neg(psi))) and neg(psi) = neg(psi)(t). The axiom seriality_future gives G(neg(psi)) -> F(neg(psi)), but that's the wrong direction. We need `neg(psi) /\ F(psi) -> T U psi`.
- This is: `neg(psi) /\ neg(G(neg(psi))) -> T U psi`. From neg(psi) and neg(G(neg(psi))): G(neg(psi)) is false, so there exists s >= t with psi(s), but psi(t) is false, so s > t, so T U psi. BUT THIS IS EXACTLY THE GAP — we can't convert the semantic "exists s > t" to Until syntactically without the F-to-U bridge!

**Alternative**: Keep `F(psi) -> psi \/ (T U psi)` as a new axiom alongside `G(phi) -> X(phi)`. Two new axioms replace one old one.

Or simpler: **just replace F_until_equiv with `F(psi) -> psi \/ (T U psi)` and separately add `G(phi) -> X(phi)` as a derived theorem using the new axiom + seriality + until_induction.**

Actually wait: with `F(psi) -> psi \/ (T U psi)` as an axiom, can we derive `G(a) -> X(a)`?

1. G(a) -> F(a) (seriality_future)
2. F(a) -> a \/ (T U a) (new axiom)
3. G(a) -> a \/ (T U a) (chain)
4. In the (T U a) branch: T U a -> X(a) by until_induction (same as before, using G(a) premise)
5. In the `a` branch: need G(a) /\ a -> X(a). G(a) -> G(G(a)) (temp_4). G(G(a)) -> F(G(a)) (seriality). F(G(a)) -> G(a) \/ (T U G(a)) (new axiom on G(a)).
   - In T U G(a) branch: T U G(a) has witness s > t with G(a)(s), thus a(s), so T U a with same witness. Then T U a -> X(a) by until_induction.
   - In G(a) branch: cycling again.

The `a` branch cycles because G(a) always reduces to `G(a)` again. But we can break this with a more clever argument:

From G(a) at t: we know a(t) and a holds at all future times. The only thing X(a) adds is "a at t+1 with empty guard." We KNOW a(t+1) semantically, but need to derive it.

Key insight: `G(a) /\ G(a -> a)` and until_induction with appropriate chi should give us this. Let me trace the original proof of G_implies_X:

From TemporalDerived.lean:
1. G(a) -> G(a->a) /\ G((T /\ X(a)) -> a)    -- G pushes over tautologies
2. until_induction: G(a->a) /\ G((T /\ X(a)) -> a) -> ((T U a) -> X(a))
3. G(a) -> T U a   (seriality + F_until_equiv)
4. Chain: G(a) -> X(a)

With the new axiom `F(a) -> a \/ (T U a)`:
Step 3 becomes: G(a) -> a \/ (T U a) (via seriality + new axiom)
Step 2 gives: (T U a) -> X(a)
But in the `a` case (not T U a), steps 1-2 are useless.

**However**: we ALSO have G(a), so step 1 still applies. We need a T U a in step 3 to feed into step 2. In the `a` branch where T U a doesn't hold... but wait: T U a NOT holding means there's no s > t with a(s) and guard satisfied. Under strict Until with T guard, this means no s > t with a(s) at all. Combined with G(a) which requires a at all s >= t, this is contradictory (take s = succ(t)). So `G(a) /\ neg(T U a)` is inconsistent on discrete frames.

Can we derive this inconsistency? `neg(T U a)` = `G(neg(a \/ (T /\ (T U a))))` by... no, that's not right. `neg(T U a)` means `forall s > t, neg(a(s)) \/ exists r with t < r < s and neg(T)(r)`. Since T is always true, neg(T) is always false, so neg(T U a) = forall s > t, neg(a(s)) \/ False = forall s > t, neg(a(s)). Under strict semantics: neg(T U a) at t iff G(neg(a)) at succ(t)? No...

Actually, `neg(exists s > t, a(s) /\ forall r, t < r < s -> T)` = `forall s > t, neg(a(s)) \/ exists r, t < r < s /\ neg(T)`. Since neg(T) = bot, this becomes `forall s > t, neg(a(s))`. So `neg(T U a)` at t = `forall s > t, neg(a)(s)` = `G(neg(a))` at succ(t) on discrete frames... no, it's G'(neg(a)) in some sense. Actually it's just "a is false at all strictly future times."

Under reflexive G: G(neg(a)) at t means forall s >= t, neg(a)(s), which includes neg(a)(t). But neg(T U a) = forall s > t, neg(a)(s), which doesn't constrain t. So neg(T U a) is strictly weaker than G(neg(a)).

To show inconsistency of G(a) /\ neg(T U a): G(a) gives a(succ(t)). neg(T U a) gives neg(a)(succ(t)). Contradiction. But this is semantic — can we derive it?

This seems like it needs the derivation `G(a) -> X(a)` which is what we're trying to prove. **Still circular.**

### Final Recommendation

**The cleanest resolution is Option E' extended: Replace F_until_equiv with TWO new axioms:**

1. **`F_unfold_disc`**: `F(psi) -> psi \/ (T U psi)` (valid under mixed semantics)
2. **`G_to_X`**: `G(phi) -> bot U phi` (valid under mixed semantics on discrete frames)

And the dual pair:
3. **`P_unfold_disc`**: `P(psi) -> psi \/ (T S psi)` (valid, replaces P_since_equiv)
4. **`H_to_Y`**: `H(phi) -> bot S phi` (valid under mixed semantics on discrete frames)

**G_to_X replaces the derived theorem G_implies_X**, making it a primitive axiom. This breaks the circularity. F_unfold_disc replaces F_until_equiv for the completeness consumers.

**Downstream repairs needed:**
- TemporalDerived.lean: G_implies_topUntil and G_implies_X become simple wrappers
- FiniteDeferral.lean: F_to_until_in_mcs needs case split (psi case: done, T U psi case: existing logic)
- DovetailedChain.lean: F_implies_until_in_mcs same case split
- Soundness.lean: New validity proofs for the 4 new axioms (straightforward)

This approach:
- Resolves the F_until_equiv sorry (Soundness.lean:770)
- Resolves the P_since_equiv sorry (Soundness.lean:786)
- Preserves ALL existing axioms (nothing removed except the 2 unsound ones)
- Preserves T-axioms, X/Y identities
- Has a clear semantic justification
- Estimated effort: 150-250 lines changed

**Confidence: 75%**

---

## 8. Appendix: Exact File Locations

| File | Lines | Relevance |
|------|-------|-----------|
| `Theories/Bimodal/Semantics/Truth.lean:125-130` | U/S/G/H definitions | Core semantics |
| `Theories/Bimodal/ProofSystem/Axioms.lean:608-618` | F_until_equiv, P_since_equiv | Unsound axioms |
| `Theories/Bimodal/ProofSystem/Axioms.lean:438` | seriality_future | Depends on G reflexivity |
| `Theories/Bimodal/ProofSystem/Axioms.lean:266-276` | temp_t_future, temp_t_past | T-axioms (need G/H reflexive) |
| `Theories/Bimodal/Metalogic/Soundness.lean:757-787` | F_until_equiv_valid, P_since_equiv_valid | Sorry sites |
| `Theories/Bimodal/Metalogic/Soundness.lean:1198-1199` | Frame-restricted soundness | Additional sorry sites |
| `Theories/Bimodal/Theorems/TemporalDerived.lean:56-62` | G_implies_topUntil | Uses F_until_equiv |
| `Theories/Bimodal/Theorems/TemporalDerived.lean:110` | G_implies_X | Critical derived theorem |
| `Theories/Bimodal/Theorems/TemporalDerived.lean:143` | H_implies_Y | Uses P_since_equiv |
| `Theories/Bimodal/Metalogic/Algebraic/FiniteDeferral.lean:43-55` | F_to_until_in_mcs/chain | Completeness consumer |
| `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean:567-574` | F_implies_until_in_mcs | Completeness consumer |
| `Theories/Bimodal/Metalogic/Algebraic/DeterministicChain.lean:317-330` | g_content_propagates | Uses G_implies_X |
