# Teammate B Findings: Well-Founded Induction on F-Nesting Depth

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Angle**: F-nesting depth as alternative induction measure for forward_F

---

## 1. Key Findings

### 1.1 The Circularity Restated

The `deterministic_forward_F` sorry requires proving:

```
F(psi) in chain(t)  ==>  exists s > t, psi in chain(s)
```

The only known proof route goes through `temporal_backward_G_with_fwd_F`:

```
Backward G: (forall s > t, phi in chain(s)) ==> G(phi) in chain(t)
```

which itself requires `forward_F` for `neg(phi)`:

```
forward_F(neg(phi)): F(neg(phi)) in chain(t) ==> exists s > t, neg(phi) in chain(s)
```

So to prove `forward_F(psi)`, we need `backward_G(neg(psi))`, which needs `forward_F(neg(neg(psi)))`.

### 1.2 F-Nesting Depth: Precise Definition

Define `Fd : Formula -> Nat` as follows:

```
Fd(atom p) = 0
Fd(bot)    = 0
Fd(imp phi psi) = max(Fd(phi), Fd(psi))
Fd(box phi) = Fd(phi)
Fd(all_past phi) = Fd(phi)
Fd(all_future phi) = Fd(phi)
Fd(untl phi psi) = 1 + max(Fd(phi), Fd(psi))  [see Section 2.4]
Fd(snce phi psi) = max(Fd(phi), Fd(psi))       [past, not future]
```

Crucially:
- **Negation is transparent**: `Fd(neg(phi)) = Fd(phi.imp bot) = max(Fd(phi), Fd(bot)) = Fd(phi)`
- **Double negation is transparent**: `Fd(neg(neg(phi))) = Fd(phi)`
- **Box is transparent**: `Fd(box(phi)) = Fd(phi)`
- **G is transparent**: `Fd(all_future(phi)) = Fd(phi)`
- **H is transparent**: `Fd(all_past(phi)) = Fd(phi)`
- **F is transparent** since `F(phi) = neg(all_future(neg(phi)))`: `Fd(F(phi)) = Fd(phi)`
- **P is transparent** since `P(phi) = neg(all_past(neg(phi)))`: `Fd(P(phi)) = Fd(phi)`

**Wait** -- this is the critical observation. Under this definition, `F(psi)` has the **same** F-nesting depth as `psi`. The F-nesting depth does not decrease through the dependency chain:

```
forward_F(psi): need backward_G(neg(psi))
  Fd(neg(psi)) = Fd(psi)
backward_G(neg(psi)): need forward_F(neg(neg(psi)))
  Fd(neg(neg(psi))) = Fd(psi)
```

The measure is **constant**, not decreasing. This does NOT give a well-founded induction.

### 1.3 Alternative: Counting Explicit F-Occurrences

One might try counting the number of `all_future` constructors in the formula (since F is derived via `neg . all_future . neg`). Define `Fc(phi)` = number of `all_future` nodes in the syntax tree.

But this also fails:
- `F(psi) = neg(all_future(neg(psi)))` has `Fc(F(psi)) = 1 + Fc(psi)`
- The backward_G argument needs `forward_F(neg(psi))` where `neg(psi) = psi.imp bot`
- `Fc(neg(psi)) = Fc(psi.imp bot) = Fc(psi) + Fc(bot) = Fc(psi)`
- So `Fc(F(neg(psi))) = 1 + Fc(psi) = Fc(F(psi))`

Again constant, not decreasing.

---

## 2. The Induction Argument: Detailed Attempt

### 2.1 Reformulation Using Until

In this codebase, `F(psi) <=> top U psi` (by `F_until_equiv` axiom and its converse). So `forward_F(psi)` is equivalent to resolving `(top U psi)` in the chain.

Define **Until-nesting depth** `Ud`:

```
Ud(atom p) = 0
Ud(bot)    = 0
Ud(imp phi psi) = max(Ud(phi), Ud(psi))
Ud(box phi) = Ud(phi)
Ud(all_past phi) = Ud(phi)
Ud(all_future phi) = Ud(phi)
Ud(untl phi psi) = 1 + max(Ud(phi), Ud(psi))
Ud(snce phi psi) = max(Ud(phi), Ud(psi))
```

This counts only Until-nesting. Now:
- `Ud(top U psi) = 1 + Ud(psi)` (since `top = neg(bot)` has `Ud = 0`)
- Resolving `top U psi` at time t gives `psi` at some `s > t`
- If `psi` contains a sub-Until `phi' U psi'`, then `Ud(phi' U psi') < Ud(top U psi)` (strictly)
- **Good**: the inner Until obligations have strictly smaller depth

### 2.2 The Induction Hypothesis

**Attempt**: Prove `forward_F` by strong induction on `Ud(top U psi)` (equivalently, `1 + Ud(psi)`).

**Base case** (`Ud(psi) = 0`): `psi` contains no Until subformulas. Need to show that if `F(psi)` is in `chain(t)`, then `psi` appears at some `s > t`.

Even the base case is problematic. The issue is NOT that `psi` has inner F-obligations -- it does not (since `Ud(psi) = 0` means no Until, hence no F-equivalent formulas). The issue is establishing `G(neg(psi)) in chain(t)` from "neg(psi) at all future times".

For the base case, we need `backward_G(neg(psi))`. The backward_G proof goes:
1. Assume `G(neg(psi)) not in chain(t)`
2. Then `neg(G(neg(psi))) in chain(t)`, i.e., `F(psi) in chain(t)` (we already have this)
3. By `forward_F`, exists `s > t` with `psi in chain(s)` -- **this is what we are trying to prove**

So even the base case is circular. The circularity is between `forward_F(psi)` and `backward_G(neg(psi))`, and this circularity exists for ANY formula `psi`, regardless of its Until-nesting depth.

### 2.3 Trying to Break the Circularity at the Base Case

Could we prove `forward_F` for `Ud(psi) = 0` WITHOUT using backward_G?

The finite deferral infrastructure (sorry-free in `FiniteDeferral.lean`) gives us:
1. `F(psi) in chain(t)` implies `(top U psi) in chain(t)`
2. `(top U psi)` persists forward until `psi` appears
3. Restricted theories must cycle within `2^|deferralClosure(psi)|` steps
4. If `G(neg(psi)) in chain(t)`, then `(top U psi) not in chain(t)` -- contradiction

The gap is step 4: we need `G(neg(psi)) in chain(t)`, which requires backward_G, which requires forward_F.

**Could a direct contradiction from the cycle suffice?** The pigeonhole gives us positions `i < j` where `restrictedTheory(chain(t+i)) = restrictedTheory(chain(t+j))`. Both contain `(top U psi)` (by persistence) and `neg(psi)` (by assumption that `psi` never appears). The cycle length is `j - i`.

The key question: can we derive a contradiction from a cycle in the restricted theory WITHOUT invoking backward_G?

**Analysis**: The Until Induction axiom states:
```
G(psi -> chi) /\ G((phi /\ X(chi)) -> chi)  ->  ((phi U psi) -> X(chi))
```

To get a contradiction from `(top U psi)` persisting forever with `neg(psi)` everywhere, we'd instantiate with `chi = bot`:
```
G(psi -> bot) /\ G((top /\ X(bot)) -> bot)  ->  ((top U psi) -> X(bot))
```

The second conjunct `G((top /\ X(bot)) -> bot)` is derivable (since `X(bot) = bot U bot` is absurd). The first conjunct `G(psi -> bot) = G(neg(psi))` is exactly what we cannot derive.

**Conclusion**: Even with Until Induction, the base case requires `G(neg(psi)) in chain(t)`, which requires backward_G, which requires forward_F. The circularity persists at every level.

### 2.4 Why Until Gets Fd = 1 + max(...)

In Section 1.2 I gave `Fd(untl phi psi) = 1 + max(Fd(phi), Fd(psi))`. The rationale: `phi U psi` is semantically equivalent to `F(psi)` (modulo the phi-holding condition), so it carries an implicit future existential. Under the F-nesting interpretation, Until represents one level of future obligation.

However, this assignment is somewhat arbitrary. We could also define `Fd(untl phi psi) = max(Fd(phi), Fd(psi))` if we view Until as a "structured F" rather than an additional nesting level. This doesn't help -- the circularity is independent of how we measure Until.

---

## 3. Critical Gaps

### 3.1 The Circularity is Measure-Independent

The dependency chain:
```
forward_F(psi)  --->  backward_G(neg(psi))  --->  forward_F(neg(neg(psi)))
```

Under ANY measure `mu`:
- `mu(neg(neg(psi)))` = ... depends on how negation is encoded
- Since `neg(phi) = phi.imp bot`, we get `mu(neg(neg(psi))) = mu((psi.imp bot).imp bot)`
- For `Fd`: `Fd(neg(neg(psi))) = Fd(psi)` -- constant
- For `complexity`: `complexity(neg(neg(psi))) = 3 + complexity(psi) > complexity(psi)` -- INCREASING
- For `Ud`: `Ud(neg(neg(psi))) = Ud(psi)` -- constant
- For `temporalDepth`: `temporalDepth(neg(neg(psi))) = temporalDepth(psi)` -- constant
- For `modalDepth`: `modalDepth(neg(neg(psi))) = modalDepth(psi)` -- constant

No natural measure decreases. The `complexity` measure actually INCREASES, which is why formula-size induction was explored and failed. The other measures are all constant, which means they fail to provide a well-founded ordering.

**The fundamental issue**: The circularity `forward_F(psi) <-> backward_G(neg(psi)) <-> forward_F(neg(neg(psi)))` involves a fixed point, not a descent. The formula `neg(neg(psi))` is logically equivalent to `psi` (by DNE in classical logic) but syntactically different. Any measure that respects logical equivalence (i.e., gives the same value to logically equivalent formulas) will be constant along this chain, providing no descent. Any measure that does NOT respect logical equivalence (like `complexity`) will see the chain as increasing.

### 3.2 Could We Quotient by Logical Equivalence?

If we worked with formulas modulo provable equivalence (the Lindenbaum algebra), then `neg(neg(psi))` and `psi` are the same element, and the circularity becomes:
```
forward_F([psi]) needs backward_G([neg(psi)])
backward_G([neg(psi)]) needs forward_F([neg(psi)])
```

Now `[neg(neg(psi))] = [psi]`, so the chain is:
```
forward_F([psi]) -> forward_F([neg(psi)])
```

And `[neg(psi)] != [psi]` in general (unless `psi` is a contradiction/tautology). Could we induct on something here? The Lindenbaum algebra is a Boolean algebra, so `[neg(psi)]` is the complement of `[psi]`. There's no natural well-ordering on Boolean algebra elements that makes complement strictly smaller.

### 3.3 The G-Across-Chain Problem is the Real Blocker

The true problem is not the measure -- it's the semantic gap between:
- **Pointwise truth**: `neg(psi) in chain(s)` for all `s > t` (provable from assumption)
- **G-membership**: `G(neg(psi)) in chain(t)` (needed for contradiction)

In a semantically complete model, these are equivalent (by G semantics). But in the syntactic chain construction, `G(neg(psi)) in chain(t)` means that the specific formula `all_future(neg(psi))` was placed into `chain(t)` during construction. The deterministic chain builds `chain(t) = x_content(chain(t-1))`, and `G(neg(psi)) in x_content(M)` requires `X(G(neg(psi))) = bot U G(neg(psi)) in M`. This is a very specific syntactic requirement that cannot be derived from pointwise membership.

**This gap exists regardless of the induction measure.**

---

## 4. Comparison with Previous Approaches

| Approach | Measure | Why It Fails |
|----------|---------|-------------|
| Formula complexity | `complexity(phi)` | Increases: `complexity(neg(neg(psi))) > complexity(psi)` |
| F-nesting depth (this report) | `Fd(phi)` | Constant: `Fd(neg(neg(psi))) = Fd(psi)` |
| Until-nesting depth | `Ud(phi)` | Constant: `Ud(neg(neg(psi))) = Ud(psi)` |
| Temporal depth | `temporalDepth` | Constant along the dependency chain |
| Modal depth | `modalDepth` | Zero for purely temporal formulas |
| Deficiency | #unresolved F-obligations | Cannot be computed syntactically |
| Multiset ordering | Collection of F-subformulas | Does not decrease through backward_G |
| Cycle/deferral | Pigeonhole + Until Induction | Needs `G(neg(psi))` -- same circularity |

**All approaches converge on the same wall**: the pointwise-to-G gap in the deterministic chain.

---

## 5. Does the Codebase Already Have an F-Nesting Measure?

The codebase defines `temporalDepth` (lines 259-267 of `Formula.lean`) which counts ALL temporal operators equally:
```
temporalDepth(all_past phi)  = 1 + temporalDepth(phi)
temporalDepth(all_future phi) = 1 + temporalDepth(phi)
temporalDepth(untl phi psi) = 1 + max(temporalDepth(phi), temporalDepth(psi))
temporalDepth(snce phi psi) = 1 + max(temporalDepth(phi), temporalDepth(psi))
```

This is NOT an F-nesting measure -- it counts G, H, Until, and Since equally. An F-only measure would need to count only `all_future` and `untl` (forward temporal operators), treating `all_past`, `snce`, `box`, `imp` as transparent.

However, as shown in Section 3.1, **no** measure (F-only, temporal, or otherwise) can break the circularity because the circularity goes through logical negation which is measure-preserving for any sensible measure.

---

## 6. Could F-Nesting Depth Help in a Non-Canonical-Model Approach?

### 6.1 Quasimodel Approach (GHR 1994)

In the quasimodel approach, one builds a "quasimodel" (a structure satisfying local consistency conditions) and then extracts a real model. F-nesting depth could potentially serve as the termination measure for the quasimodel construction: resolving F-obligations at depth n only creates obligations at depth < n (the inner formula of `F(psi)` has smaller F-nesting depth than `F(psi)` itself... **but wait**, `F(psi) = neg(all_future(neg(psi)))` and the inner formula is `psi`, not `neg(psi)`).

Actually, in the quasimodel approach the resolution is different: you witness `F(psi)` by placing `psi` at a future point. The formula `psi` may contain `F(chi)` subformulas, but those have `Ud(chi) < Ud(psi)` if we measure Until-nesting. So the quasimodel construction CAN use Until-nesting depth as a termination measure, because it does NOT go through the backward_G -> forward_F(neg(neg(...))) chain.

**This is the key insight**: F-nesting depth works as a measure IF you avoid the backward_G dependency. The canonical model / deterministic chain approach forces the backward_G dependency. The quasimodel approach does not.

### 6.2 Decidability-Based Approach

The decidability pipeline (Tableau -> Correctness -> ProofExtraction) bypasses canonical models entirely. F-nesting depth is irrelevant there.

---

## 7. Confidence Level

**LOW (15%)** that F-nesting depth induction can close `forward_F` within the current deterministic chain architecture.

**MEDIUM (50%)** that F-nesting depth / Until-nesting depth is a viable termination measure in an alternative construction (quasimodel approach) that avoids the backward_G dependency.

**Key conclusion**: The problem with F-nesting depth induction is not the measure itself -- it's the architecture. The deterministic chain forces `forward_F` and `backward_G` to be mutually dependent, and no measure on formulas can break a dependency that goes through logical negation (which preserves all natural measures). An architecture that does not require backward_G (quasimodel, decidability) could potentially use F-nesting depth as a viable termination argument.

---

## 8. Recommendation

1. **Do not pursue F-nesting depth induction within the deterministic chain** -- it is provably unable to break the circularity (Section 3.1).

2. **Investigate the decidability-based completeness path** (Report 29, Section 2.1) -- this completely bypasses the forward_F/backward_G circularity.

3. **If staying within canonical models**, the quasimodel approach (GHR 1994) is the only known viable path. F-nesting depth / Until-nesting depth CAN serve as a termination measure there, because quasimodel construction resolves F-obligations by witnessing and does NOT require backward_G.

4. **The observation from Report 29 that "F(neg(neg(psi))) has the same F-nesting depth as F(psi)" is correct but does not help** -- it merely confirms the circularity is a fixed point, not a descent.
