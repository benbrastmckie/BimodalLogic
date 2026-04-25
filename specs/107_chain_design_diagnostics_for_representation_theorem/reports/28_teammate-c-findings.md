# Teammate C Findings: The Guard Convention -- Open vs Closed Interval

## Executive Summary

The codebase uses a **half-open guard** `[t, s)` for Until, while Burgess 1982 uses an **open guard** `(t, s)`. This mismatch creates a real proof obligation at the base point `r = t` in `restricted_fuc`. The half-open guard is *semantically consistent* with the BX axiom system (BX9 is sound under it), but it creates a burden that Burgess's completeness proof does not face. I identify three resolution paths and recommend one.

---

## 1. The Two Guard Conventions Compared

### Burgess 1982 (line 39): Open guard `(x, y)`

```
V(U(alpha, beta)) = {x : exists y (x < y AND y in V(alpha) AND
                       forall z (x < z < y => z in V(beta)))}
```

The guard beta holds on the **open interval** `(x, y)`. Neither endpoint `x` nor `y` is required to satisfy beta.

### Codebase (Truth.lean:127-128): Half-open guard `[t, s)`

```lean
Formula.untl phi psi => exists s, t < s AND truth_at s psi AND
    forall r, t <= r -> r < s -> truth_at r phi
```

The guard phi holds on the **half-open interval** `[t, s)`. The base point `t` IS required to satisfy phi (via `t <= r`), but the witness point `s` is not (via `r < s`).

### Key difference

| Convention | Guard at t | Guard at intermediates | Guard at s |
|---|---|---|---|
| Burgess open `(x,y)` | NO | YES | NO |
| Codebase half-open `[t,s)` | **YES** | YES | NO |

---

## 2. BX9 (until_elim) Under Both Conventions

**BX9**: `(phi U psi) -> (phi OR psi)`

Under the **half-open guard**, the soundness proof (Soundness.lean:757-763) works by:
- Given witness `s > t` with `psi(s)` and `phi` on `[t, s)`.
- Since `t <= t` and `t < s`, the guard gives `phi(t)`.
- Therefore `phi OR psi` holds (via the left disjunct).

Under **Burgess's open guard**, this reasoning would NOT work -- there is no `z` with `x < z < y` that equals `x` itself. Burgess does not have BX9 as an axiom. His A5a (self_accum_until) plays a different structural role.

**Critical observation**: BX9 is SOUND under the half-open guard. The axiom `(phi U psi) -> phi OR psi` is semantically valid because the half-open guard forces `phi(t)`. But BX9 only gives the disjunction `phi OR psi`, not `phi` alone. When `psi` holds at `t` (i.e., `psi in f(t)` and `phi not in f(t)`), BX9 is satisfied by the right disjunct, but the half-open guard's requirement of `phi(t)` is NOT met.

---

## 3. Impact on restricted_fuc

The sorry site at `ChronicleToCountermodel.lean:964` needs:

> Given `untl(phi, psi) in f(t)`, produce `s > t` with `psi in f(s)` AND `phi in f(r)` for all `r` with `t <= r < s`.

The guard condition decomposes into:
1. **Endpoint**: `exists s > t, psi in f(s)` -- available via `limit_satisfies_c5_weak`
2. **Strict intermediates**: `phi in f(r)` for `t < r < s` -- available via C3/g-content (Burgess 2.11 uses `g(x,y) subset f(z)` for `x < z < y`)
3. **Base point**: `phi in f(t)` -- **THIS IS THE PROBLEM**

For item (3), we need `phi in f(t)` given `untl(phi, psi) in f(t)`. BX9 gives `phi OR psi in f(t)`. If `phi in f(t)`, we are done. But if `phi not in f(t)`, then `psi in f(t)` (by MCS properties and BX9). The question is whether `untl(phi, psi) in f(t)` with `phi not in f(t)` is BX-consistent.

---

## 4. Is `untl(phi, psi) AND neg(phi)` BX-Consistent?

**Claim: YES, it is BX-consistent under the half-open guard.**

Proof by exhibiting a model: Take the rationals. Let `phi` be false everywhere except at time 2. Let `psi` be true at time 2, false elsewhere. Then at time 1:
- Under the half-open guard: `phi U psi` at time 1 requires `psi(2)` (check) and `phi(r)` for `1 <= r < 2`. But `phi(1)` is false. So `phi U psi` is FALSE at time 1. This is not a counterexample.

Let me try again: Let `phi` be true at times in `[1, 2)` and `psi` true at time 2. Then `phi U psi` holds at time 1 under the half-open guard. And `phi(1)` is true. No contradiction here.

The real question is whether `untl(phi, psi) AND neg(phi)` is satisfiable. Under the half-open guard it is NOT, because:
- `untl(phi, psi)` at `t` gives witness `s > t` with `phi` on `[t, s)`.
- `t in [t, s)`, so `phi(t)` must hold.
- `neg(phi)(t)` contradicts `phi(t)`.

So `untl(phi, psi) -> phi` IS semantically valid under the half-open guard! And BX9 gives only `phi OR psi`, which is weaker.

**This means the BX axiom system is incomplete with respect to the half-open guard unless `untl(phi, psi) -> phi` is derivable from the existing axioms.**

---

## 5. Can `untl(phi, psi) -> phi` Be Derived from BX Axioms?

### Attempt via BX5 (self_accum_until)

BX5: `(phi U psi) -> ((phi AND (phi U psi)) U psi)`

From `phi U psi`, we get `(phi AND (phi U psi)) U psi`. Under the half-open guard, this new Until formula requires `phi AND (phi U psi)` at the base point. In particular, `phi` at the base point!

But wait -- this is circular. We are trying to derive `phi U psi -> phi`. BX5 gives us `(phi AND X) U psi` where `X = phi U psi`. The half-open guard of this NEW formula gives `(phi AND X)(t)`, which includes `phi(t)`. But this is a SEMANTIC consequence of the new formula, not a syntactic one. The BX axiom system cannot "look inside" the semantics of the new Until formula it just derived.

To make this work syntactically, we would need:
1. `phi U psi -> (phi AND (phi U psi)) U psi` (BX5)
2. `(phi AND (phi U psi)) U psi -> (phi AND (phi U psi)) OR psi` (BX9 applied to new formula)
3. From (2): `phi AND (phi U psi)` or `psi` holds at `t`.
4. If `phi AND (phi U psi)` holds: extract `phi`. Done.
5. If `psi` holds: we only get `psi`, not `phi`.

So this derivation gives: `phi U psi -> phi OR psi` -- which is just BX9 again. We cannot escape the disjunction.

### Attempt via BX5 iterated

No matter how many times we apply BX5, we get deeper nesting `((phi AND ...) U psi)`, and BX9 always peels off the same disjunction `(guard at t) OR psi`.

### Attempt via BX10 + BX4

BX10: `phi U psi -> F(psi)`. This gives the endpoint but no guard.
BX4: `phi -> G(P(phi))`. This connects but does not extract the guard.

### Conclusion

**`untl(phi, psi) -> phi` is NOT BX-derivable.** The axiom system can only derive `phi OR psi` at the base point. This is precisely Finding 5 from the handoff analysis.

---

## 6. Three Resolution Paths

### Path A: Switch to Open Guard (Change Truth.lean)

Change Truth.lean:127-128 from:
```lean
Formula.untl phi psi => exists s, t < s AND truth_at s psi AND
    forall r, t <= r -> r < s -> truth_at r phi
```
to:
```lean
Formula.untl phi psi => exists s, t < s AND truth_at s psi AND
    forall r, t < r -> r < s -> truth_at r phi
```

**Impact analysis**:

1. **BX9 soundness BREAKS.** The current proof of `until_elim_valid` (Soundness.lean:757-763) uses `h_guard t le_rfl hts` which relies on `t <= t`. With `t < r`, we cannot instantiate at `r = t`. BX9 as stated (`phi U psi -> phi OR psi`) would no longer be sound under the open guard.

2. **BX9 must be removed or weakened.** Under Burgess's open guard, `phi U psi` does NOT imply `phi` at the base point. In fact, Burgess does not have BX9. He derives the needed properties from A5a-A6a (self-accumulation and absorption).

3. **Other soundness proofs need review.** Any proof that uses the guard at the base point would break. This is a major refactoring task affecting Soundness.lean, SoundnessLemmas.lean, and potentially other files.

4. **The restricted_fuc proof becomes trivial at the base point** (no longer needed).

5. **The restricted_buc proof (backward direction) also needs review.** `cantor_bfmcs_restricted_buc` uses `h_guard z_rat (le_of_lt hz_rat_gt) hz_rat_lt` which has `le_of_lt` producing `t <= z_rat`. With open guard, this becomes `t < z_rat` which is exactly `hz_rat_gt`. So backward coherence is unaffected.

6. **F_until_equiv (BX12)**: `F(phi) <-> top U phi`. Under open guard, `top U phi` at `t` means `exists s > t, phi(s) AND forall r, t < r < s, top(r)`. The guard is vacuous. So `F(phi) <-> top U phi` remains valid. OK.

**Verdict**: Path A removes the base-point problem but requires removing BX9 and reworking soundness. This is a significant change touching the axiom system itself.

### Path B: Add `untl(phi, psi) -> phi` as a New Axiom

Add a new axiom BX9s: `(phi U psi) -> phi`.

This is sound under the half-open guard (proven above in section 4). It is strictly stronger than BX9 (`phi U psi -> phi OR psi`), and in fact BX9 becomes derivable from BX9s.

**Impact analysis**:

1. **Soundness proof**: Trivial. The half-open guard at `r = t` immediately gives `phi(t)`.

2. **restricted_fuc base point**: Resolved. From `untl(phi, psi) in f(t)`, BX9s gives `phi in f(t)`.

3. **No other proofs affected**: BX9s is strictly stronger than BX9. Every theorem using BX9 still holds. No soundness proofs break.

4. **Completeness unaffected**: The completeness proof constructs models over dense linear orders (rationals). Under the half-open guard, `phi U psi -> phi` is valid on ALL linear orders (not just dense ones). Adding a valid axiom cannot break completeness.

5. **Axiom file change**: Add one constructor to the `Axiom` inductive type, one soundness case, one `isDenseCompatible` / `isDiscreteCompatible` case.

**Verdict**: Path B is the minimal, surgical fix. One new axiom, one soundness lemma, and the base-point sorry dissolves.

### Path C: Switch to Strict Guard `(t, s)` at Both Endpoints

Change the Until guard to `t < r AND r < s` (fully open). Then:
- Neither base point nor witness point is guarded.
- The Since guard becomes `s < r AND r < t` (fully open).
- BX9 becomes unsound and must be removed.
- Same as Path A in terms of impact.

**Verdict**: Path C is equivalent to Path A. No additional benefit over A.

---

## 7. Detailed Comparison: Open Guard vs Half-Open Guard

The Burgess completeness proof (section 2.11, Until case) works as follows:

> If `alpha = U(beta, gamma)` and `alpha in f(x)`, then by C5a there is `y in X` with `x < y` and `gamma in f(y)` and `beta in g(x,y)`. If `z in X` and `x < z < y`, then by C3 we have `g(x,y) subset f(z)`, whence `beta in f(z)`.

The guard `beta` is checked only at `z` with `x < z < y` (open interval). Burgess never needs `beta in f(x)`.

Under the half-open guard, the completeness proof (truth lemma direction "membership implies truth") would additionally need `phi in f(t)`. This is where BX9s (Path B) would be used:
- From `untl(phi, psi) in f(t)`, BX9s gives `phi in f(t)`.
- The intermediate guard follows from C3/g-content as in Burgess.
- The endpoint follows from C5.

Under the open guard (Path A), the proof follows Burgess exactly with no base-point issue.

---

## 8. Recommendation

**Path B (add BX9s) is the recommended resolution.**

Rationale:
1. **Minimal code change**: One new axiom constructor, one soundness case, approximately 20-30 lines of new code total.
2. **No existing proofs break**: BX9s is strictly stronger than BX9. Everything that depends on BX9 continues to work.
3. **Semantically correct**: `phi U psi -> phi` IS valid under the half-open guard on ALL linear orders.
4. **No need to change Truth.lean**: The half-open guard convention stays. All existing soundness proofs remain valid.
5. **The restricted_fuc sorry site gains a direct proof path**: From `untl(phi, psi) in f(t)`, apply BX9s in the MCS to get `phi in f(t)`.

Path A (switch to open guard) is a larger refactoring that touches the axiom system, the soundness proof, and potentially many downstream files. It aligns with Burgess but is not necessary for correctness.

---

## 9. Impact on Other Sorry Sites

The `restricted_fuc` sorry site (ChronicleToCountermodel.lean:964) has TWO components:
1. **Base point guard**: `phi in f(t)` -- resolved by BX9s (Path B)
2. **Intermediate guard**: `phi in f(r)` for `t < r < s` -- still requires the g-function / C3 property

Adding BX9s resolves component (1) but does NOT resolve component (2). The intermediate guard is the OTHER missing piece, which requires either:
- The real interval function `g` with C3 (`g(x,y) subset f(z)` for `x < z < y`), OR
- Strengthening `EliminationResult.c5_forward_witness` to carry guard information from the elimination step.

Both of these are identified in the handoff (Finding 5 / Step 3) and are independent of the base-point issue analyzed here.

---

## 10. Summary Table

| Question | Answer |
|---|---|
| Does Burgess use open or half-open guard? | Open: `(x, y)` |
| Does the codebase use open or half-open guard? | Half-open: `[t, s)` |
| Is BX9 sound under half-open guard? | YES |
| Is `phi U psi -> phi` valid under half-open guard? | YES |
| Is `phi U psi -> phi` BX-derivable? | NO (only `phi OR psi`) |
| Does the mismatch block restricted_fuc? | YES (at base point) |
| Recommended fix? | Path B: add BX9s axiom `phi U psi -> phi` |
| Does BX9s fix the entire restricted_fuc sorry? | NO (intermediate guard still needed) |
