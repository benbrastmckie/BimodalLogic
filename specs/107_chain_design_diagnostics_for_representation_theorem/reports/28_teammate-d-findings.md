# Teammate D Findings: Holistic Resolution -- What's the Simplest Path to Sorry-Free?

**Date**: 2026-04-25
**Focus**: Inventory all sorry sites, assess bypass paths, compare resolution options

---

## 1. Actual Sorry Site Inventory

### Explicit `sorry` keywords in Chronicle directory

| # | File | Line | Context | On Critical Path? |
|---|------|------|---------|-------------------|
| 1 | `CounterexampleElimination.lean` | 329 | C4 hard sub-case: G(gamma) in f(x) AND H(gamma) in f(y) | YES (contaminates omega chain) |
| 2 | `CounterexampleElimination.lean` | 439 | C4' hard sub-case (mirror of #1) | YES (contaminates omega chain) |
| 3 | `ChronicleToCountermodel.lean` | 536 | `chronicle_fmcs.forward_G` (legacy dead code) | NO (dead code) |
| 4 | `ChronicleToCountermodel.lean` | 541 | `chronicle_fmcs.backward_H` (legacy dead code) | NO (dead code) |
| 5 | `ChronicleToCountermodel.lean` | 713 | `chronicle_bfmcs_restricted_tc` forward (legacy dead code) | NO (dead code) |
| 6 | `ChronicleToCountermodel.lean` | 716 | `chronicle_bfmcs_restricted_tc` backward (legacy dead code) | NO (dead code) |
| 7 | `ChronicleToCountermodel.lean` | 735 | `chronicle_bfmcs_restricted_buc` forward (legacy dead code) | NO (dead code) |
| 8 | `ChronicleToCountermodel.lean` | 738 | `chronicle_bfmcs_restricted_buc` backward (legacy dead code) | NO (dead code) |
| 9 | `ChronicleToCountermodel.lean` | 767 | `chronicle_bfmcs_restricted_fuc` forward (legacy dead code) | NO (dead code) |
| 10 | `ChronicleToCountermodel.lean` | 770 | `chronicle_bfmcs_restricted_fuc` backward (legacy dead code) | NO (dead code) |
| 11 | `ChronicleToCountermodel.lean` | 964 | `cantor_bfmcs_restricted_fuc` forward Until | YES (directly blocks dd_countermodel) |
| 12 | `ChronicleToCountermodel.lean` | 968 | `cantor_bfmcs_restricted_fuc` forward Since | YES (directly blocks dd_countermodel) |

**Total**: 12 explicit sorry sites. **4 on the critical path**, 8 in legacy dead code (`chronicle_fmcs`, `chronicle_bfmcs` -- nothing routes through them).

### CRITICAL FINDING: Sorry Contamination via omega_chain

The handoff documents describe `cantor_bfmcs_restricted_buc` and `cantor_bfmcs_restricted_tc` as "sorry-free." **This is incorrect at the `#print axioms` level.** Verified:

```
#print axioms cantor_bfmcs_restricted_buc  -- depends on sorryAx
#print axioms cantor_bfmcs_restricted_tc   -- depends on sorryAx
#print axioms cantor_bfmcs_restricted_fuc  -- depends on sorryAx
#print axioms cantor_fmcs                  -- depends on sorryAx
#print axioms limit_satisfies_c4           -- depends on sorryAx
#print axioms limit_satisfies_c5_weak      -- depends on sorryAx
#print axioms limit_forward_G              -- depends on sorryAx
```

**Root cause**: `eliminate_potential_counterexample` handles ALL counterexample types (C4, C4', C5, C5', density) in a single function. The 2 C4 hard-case sorries contaminate the entire function, which contaminates `omega_chain`, which contaminates ALL limit lemmas.

Even definitions the handoff calls "sorry-free" (like `cantor_fmcs.forward_G`, `cantor_bfmcs_restricted_buc`) depend on `sorryAx` because they go through `limit_satisfies_c4` or `limit_satisfies_c5_weak`, which flow through the sorry-contaminated omega chain.

**PointInsertion.lean is genuinely sorry-free** (confirmed: `g_propagation_witness` has no `sorryAx` dependency).

---

## 2. What dd_countermodel_chronicle Actually Needs

`dd_countermodel_chronicle` (line 994) calls:
1. `cantor_bfmcs_restricted_tc` -- F/P resolution (sorry-contaminated via C4, but proof logic is complete)
2. `cantor_bfmcs_restricted_buc` -- backward Until/Since (sorry-contaminated via C4, but proof logic is complete)
3. `cantor_bfmcs_restricted_fuc` -- **2 explicit sorry sites** (lines 964, 968)

All three depend on `sorryAx` due to C4 contamination. **To achieve truly sorry-free `dd_countermodel_chronicle`, all 4 critical-path sorry sites must be resolved.** There is no bypass path.

---

## 3. The Guard Convention Mismatch

### Discovery: Truth semantics uses half-open guard [t, s)

The codebase's truth_at (Truth.lean:127-128):
```lean
| Formula.untl phi psi => exists s, t < s /\ truth_at ... s psi /\
    forall r, t <= r -> r < s -> truth_at ... r phi
```

Guard includes the base point `t` itself (`t <= r`). This is half-open `[t, s)`.

### Burgess uses open guard (t, s)

Burgess 1982 Section 1.2:
```
V(U(alpha, beta)) = {x : exists y(x < y, y in V(alpha), forall z(x < z < y -> z in V(beta)))}
```

Guard excludes the base point (`x < z`). This is open `(x, y)`.

### Consequences of this mismatch

1. **BX9 (`until_elim: U(phi,psi) -> phi or psi`) is sound** under half-open guard because `t <= t` gives `phi@t`. Under open guard, BX9 would NOT be sound.

2. **`U(phi,psi) -> phi` is valid** under half-open guard (take `r = t` in the guard). This is STRONGER than BX9 but is **not derivable** from the current BX axioms (which were designed for Burgess's open guard).

3. **The FUC base-point gap**: The chronicle's C5 + C3 gives `phi in f(r)` for intermediate `r` with `x < r < y` (open guard from Burgess). But the coherence condition needs `phi in f(t)` (for `r = t`, base point). This cannot be proved from BX axioms alone when `psi in f(t)` and `phi not in f(t)`.

### Why Option C (change to open guard) is IMPOSSIBLE

Changing truth_at to open guard `(t, s)` would make BX9 unsound. BX9's soundness proof (Soundness.lean:757-763) explicitly uses `h_guard t le_rfl hts` -- it takes `r = t` using `t <= t`. Removing the base point breaks this.

---

## 4. Cost Comparison of Resolution Options

### Option A: Add `until_guard` axiom (NEW -- simplest for FUC)

Add `until_guard : U(phi, psi) -> phi` and mirror `since_guard : S(phi, psi) -> phi` as new BX axioms. These are sound under the half-open semantics (trivially: take `r = t` in the guard, since `t <= t` and `t < s`).

**Impact on FUC**: From `U(phi, psi) in f(t)`, `until_guard` gives `phi in f(t)` directly. Combined with C5 + C3 (which give `phi in f(r)` for `t < r < s`), the full guard `[t, s)` is established.

**Effort**: ~2-4 hours total
- Add axiom constructors to Axioms.lean: 30 min
- Prove soundness (trivial -- take r = t): 30 min
- Close `cantor_bfmcs_restricted_fuc` using until_guard + C5 + C3: 2-3 hours
- Note: `until_guard` subsumes BX9 (since `phi -> phi or psi`), but keeping BX9 is fine

**Risk**: Low. The axiom is semantically valid. It strengthens the proof system without breaking anything. Every existing derivation remains valid.

**Does NOT resolve C4 contamination.** Only closes the 2 FUC sorry sites.

### Option B: Populate g-values in the omega chain (addresses C4 contamination)

Modify each case of `eliminate_potential_counterexample` to also define `g'` (not just `f'`). Currently every elimination passes `chi.g` unchanged, keeping g empty forever. To implement Burgess's construction properly, each point insertion must set g-values for the new point and update g for non-adjacent pairs via C3.

**What this enables**: A proper `limit_g` that retrieves `g_n(x,y)` from the first stage where both x,y are domain points. With C3, `g(x,z) subset f(y)` for intermediate y, giving the guard.

**Effort**: 15-20 hours
- Redesign `EliminationResult` to include g-agreement: 2 hours
- Modify C5 elimination (Lemma 2.10) to produce proper g-values using Lemma 2.4: 4 hours
- Modify C4 elimination (Lemma 2.9) to produce proper g-values using Lemma 2.6: 4 hours
- Prove g-immutability (values don't change once set): 2 hours
- Define proper `limit_g` as union of finite-stage g-values: 1 hour
- Prove C3 at the limit: 2 hours
- Wire through to FUC: 2-3 hours

**Risk**: High. This is a deep refactoring of the omega chain. Many intermediate lemmas need updating.

### Option C: Change truth semantics to open guard -- RULED OUT

**Cannot be done.** BX9 soundness depends on half-open guard. See Section 3 above.

### Option D: Fix C4 hard case directly (resolves contamination)

The C4 hard sub-case (G(gamma) in f(x) AND H(gamma) in f(y)) is the source of contamination. The handoff 01 proves this case is contradictory using forward_G (from C4 + C0), but this creates a circularity since forward_G is proved via C4.

However, `limit_forward_G` was proved independently (handoff 27 says it's sorry-free in proof logic, though sorry-contaminated via omega chain). If the C4 hard case could be resolved, the contamination breaks.

**Resolution paths for C4 hard case** (from handoff 27):
1. Show configuration is unreachable -- unlikely, G(gamma) does not imply any Until formula
2. Use interval function g(x,y) via R3Maximal -- requires C2' access in elimination function
3. Defer (but contamination persists)

Path 2 (g-based approach) requires passing `ChronicleInvariant` into the elimination function, not just C0. The key insight from handoff 27: if g(x,y) is an MCS (via R3Maximal), case split on `gamma in g(x,y)`:
- gamma not in g(x,y): gamma.neg in g(x,y) (MCS), use as f(z). Done.
- gamma in g(x,y): still open. This sub-sub-case may require Burgess Lemma 2.9's induction argument.

**Effort**: 8-12 hours (uncertain -- the gamma-in-g(x,y) sub-case may be a deep blocker)

### Option E: Split omega chain to isolate C4 contamination

Factor `eliminate_potential_counterexample` into separate functions for C5 and C4 counterexample types. Build TWO omega chains:
1. A C5-only omega chain (processes only C5/C5'/density counterexamples)
2. A C4 omega chain (processes C4/C4' counterexamples on top of the C5 chain output)

The C5-only chain would be sorry-free. `limit_satisfies_c5_weak`, `limit_forward_G`, `cantor_fmcs`, `cantor_bfmcs`, `cantor_bfmcs_restricted_tc`, and `cantor_bfmcs_restricted_buc` would then be genuinely sorry-free.

Only `limit_satisfies_c4` (used by `cantor_bfmcs_restricted_buc`) would still depend on the C4 chain.

Wait -- `cantor_bfmcs_restricted_buc` uses `limit_satisfies_c4`. So splitting doesn't help BUC. But it would decontaminate TC and FUC (assuming FUC's other blocker is resolved).

**Effort**: 6-8 hours for the split. Does NOT close any sorry sites by itself.

**Risk**: Medium. Significant refactoring but mechanically straightforward.

---

## 5. The Minimum Path to Sorry-Free dd_countermodel_chronicle

### Verdict: Option A + Option D (or A + E + D)

**Phase 1: Add `until_guard` axiom (Option A) -- 2-4 hours**

This closes the 2 FUC sorry sites (lines 964, 968) by providing `phi in f(t)` at the base point. Combined with C5_weak (endpoint witness) and the yet-to-be-proved full C5 guard, the FUC is complete.

However, FUC also needs `phi in f(r)` for intermediate `r` with `t < r < s`. This requires EITHER:
- A proper `limit_g` with C3 (Option B), OR
- `limit_forward_G` to propagate phi from f(t) forward (already available via C4+C0)

Actually, `limit_forward_G` is NOT what we need. Forward_G says G(phi) in f(x) implies phi in f(y) for y > x. What we need for the Until guard is: phi in g(x,y) implies phi in f(z) for x < z < y (C3). Without a real g, we can't do this.

But wait -- can we use forward_G + backward_H to establish the guard? If `U(phi, psi) in f(t)`, then by BX5 self-accumulation: `U(phi /\ U(phi,psi), psi) in f(t)`. This means at all intermediate points r, `phi /\ U(phi,psi) in f(r)`. By induction on the Until structure... no, this is the standard approach but it requires the guard to already be established.

**The real requirement for FUC**: We need the full C5 (with guard), not just C5_weak (endpoint only). The guard at intermediate points comes from either:
(a) The interval function g via C3
(b) BX axiom manipulation (BX5 self-accumulation + structural induction)

For (b): BX5 gives `U(phi, psi) -> U(phi /\ U(phi,psi), psi)`. In the MCS f(t), this means the enriched Until formula is also present. When C5_weak gives a witness y with psi in f(y), the omega chain's C5 elimination (via Lemma 2.10) should also have placed `phi /\ U(phi,psi)` at intermediate domain points. But does it?

Looking at the C5 elimination: it uses `lemma_2_4_controlled` to produce `B, C` with `eta in B, xi in C`. In Burgess's convention (adapted), `xi = psi` (event), `eta = phi` (guard). So `phi in B = g(x,y)`. Via C3, `phi in f(z)` for intermediate z.

But this requires a REAL g. The current code passes `chi.g` unchanged, so g is empty. There is no C3 to use.

**Revised assessment**: Option A alone is NOT sufficient for FUC. We need EITHER:
- Proper g-values (Option B) -- 15-20 hours
- OR a completely different proof of the intermediate guard

**Actually, let me reconsider.** The `cantor_bfmcs_restricted_buc` proof (sorry-contaminated but logically complete) works by CONTRADICTION: assume not-U, then C4 gives an intermediate point where the guard fails, contradicting the hypothesis. This proof does NOT need the interval function g -- it uses C4 at the limit level.

Can FUC be proved similarly, without g? FUC needs: `U(phi,psi) in f(t) -> exists s > t, psi in f(s), phi at all r in [t,s)`.

From C5_weak: exists y > t with psi in f(y). Good for the endpoint.
For the guard: we need `phi in f(r)` for all `t <= r < y`.

At `r = t`: from `until_guard` (Option A), `phi in f(t)`. Done.
At `t < r < y`: Need `phi in f(r)` for domain points r between t and y.

Claim: `phi in f(r)` for `t < r < y` follows from BX5 + C4 + forward_G at the limit.

Proof sketch: `U(phi, psi) in f(t)`. By BX5: `U(phi /\ U(phi,psi), psi) in f(t)`. This means the C5 witness y also has the enriched guard: `phi /\ U(phi,psi)` at all intermediate points (via the enriched Until formula). But how do we establish this at intermediate points without g?

By contradiction: suppose `phi not in f(r)` for some `t < r < y`. Then `phi.neg in f(r)` (MCS). But `neg(U(phi,psi)) not in f(t)` (since `U(phi,psi) in f(t)` and MCS). Now consider: `neg(U(phi,psi)) in f(r)` or `U(phi,psi) in f(r)`.

If `U(phi,psi) in f(r)`: by `until_guard`, `phi in f(r)`. Contradiction with `phi.neg in f(r)`.
If `neg(U(phi,psi)) in f(r)`: and `psi in f(y)` with `r < y`. Then C4 gives z with `r < z < y` and `phi.neg in f(z)`. But this just pushes the problem to z. By induction on the finite domain between t and y... this is Burgess's Lemma 2.9 induction!

Actually, this CAN work without g: at the limit, there are infinitely many domain points between any two points (by density of the limit domain). So the finite induction argument doesn't apply directly. We need C4 to give us SOME z, then propagate the argument.

Hmm, but at the limit level, we can argue:

1. `U(phi, psi) in f(t)` and `psi in f(y)` for y > t.
2. Suppose `phi.neg in f(r)` for some `t < r < y`.
3. Then `neg(U(phi,psi))` might or might not be in f(r).
4. If `U(phi,psi) in f(r)`: `until_guard` gives `phi in f(r)`, contradiction.
5. If `neg(U(phi,psi)) in f(r)`: C4 gives z with `r < z < y` and `phi.neg in f(z)`. But we also need to handle this z.

The issue is that step 5 produces z with `phi.neg in f(z)`, not necessarily with `neg(U(phi,psi)) in f(z)`. If `U(phi,psi) in f(z)`, then `until_guard` gives `phi in f(z)`, contradicting `phi.neg in f(z)`. So z must also have `neg(U(phi,psi)) in f(z)`.

But C4 tells us `phi.neg in f(z)`, not `neg(U(phi,psi)) in f(z)`. We know `phi.neg in f(z)`, and by MCS completeness either `U(phi,psi) in f(z)` or `neg(U(phi,psi)) in f(z)`. If the former, `until_guard` gives contradiction. So `neg(U(phi,psi)) in f(z)`.

Now repeat: `neg(U(phi,psi)) in f(z)` and `psi in f(y)` with `z < y`. C4 gives w with `z < w < y` and `phi.neg in f(w)`. By the same argument, `neg(U(phi,psi)) in f(w)`.

This produces an infinite descending sequence of domain points `r > z > w > ...` in `(t, y)` all with `phi.neg`. But the limit domain is a COUNTABLE dense linear order. There IS room for infinitely many such points. So there's no contradiction from density alone.

**This approach does NOT work without the interval function g.**

**Revised verdict**: We NEED either proper g-values (Option B) or a fundamentally different proof of the intermediate guard.

### Phase 1 (minimum): Option A + prove g at finite stages propagates to limit

The critical insight from Burgess's construction is that g-values are SET at each elimination step (Lemmas 2.4, 2.6, 2.7) and NEVER CHANGED. The codebase chose not to populate g. The simplest fix is:

1. Add `until_guard` axiom (base-point guard) -- 2 hours
2. Fix the C4 hard case (decontaminate omega chain) -- 8-12 hours
3. Populate g in the elimination functions and define proper limit_g -- 10-15 hours
4. Prove C3 at limit and wire through FUC -- 3-4 hours

**Total: 23-33 hours.** This is the correct but expensive path.

### Alternative: Can BUC's contradiction strategy prove FUC?

BUC's proof works by CONTRADICTION: "if not-U(phi,psi) in f(t), then C4 at any intermediate witness point with psi gives phi.neg somewhere, contradicting the guard hypothesis."

For FUC, we don't have a guard hypothesis -- we're PRODUCING the guard. So the contradiction strategy doesn't directly apply.

However, there's a hybrid approach: prove the CONTRAPOSITIVE of the guard failure. If the guard `phi in f(r)` fails at some r with `t < r < y`, then show a contradiction with `U(phi,psi) in f(t)`.

From `U(phi,psi) in f(t)` and `phi.neg in f(r)` with `t < r`:
- BX4 (connect_future): `phi.neg -> G(P(phi.neg))`. So `G(P(phi.neg)) in f(r)`.
- forward_G (limit level): `P(phi.neg) in f(r')` for all `r' > r`.
- In particular, `P(phi.neg) in f(y)`. This means `exists s < y, phi.neg in f(s)`.

But we already have `phi.neg in f(r)` with `r < y`, so this is consistent. No contradiction yet.

From `U(phi,psi) in f(t)` and `phi.neg in f(r)`:
- `neg(U(phi,psi)) not in f(t)` (MCS)
- Consider the formula `neg(phi) U psi` evaluated at r... no, this is mixing syntax and semantics.

I don't see a way to derive contradiction from `U(phi,psi) in f(t)` and `phi.neg in f(r)` using only BX axioms and C4/C5. The interval function g is essential for the forward Until guard.

---

## 6. EliminationResult and g-value Reconstruction

The `EliminationResult` type (CounterexampleElimination.lean:683) contains:
- `val : Chronicle` (the extended chronicle)
- `dom_sub`, `c0`, `f_agrees` (domain extension, MCS property, f-agreement)
- `c5_forward_witness`, `c5_backward_witness` (C5 witnesses)
- `c4_forward_witness`, `c4_backward_witness` (C4 witnesses)
- `density_witness`

**It does NOT contain g-agreement or g-construction fields.** Every elimination function passes `chi.g` unchanged:

```lean
refine { f := fun q => if q = z then D else chi.f q, g := chi.g, dom := insert z chi.dom }
```

This appears on lines 185, 230, 337, 358, 373, 388, 447, 468, 483, 498, 549, 589, 628, 929.

**To populate g**, each case must:
1. Compute g-values for the new point z using Lemmas 2.4/2.6/2.7 (which produce R3Maximal DCS)
2. Define g'(x,z) and g'(z,y) for adjacent pairs
3. Define g'(w,z) and g'(z,w) for non-adjacent pairs via C3
4. Add g-agreement field to EliminationResult

The Burgess construction explicitly defines g-values at each step. The PointInsertion lemmas already produce the R3Maximal DCS needed -- they just aren't stored in the Chronicle's g field.

---

## 7. Is There a Single Architectural Change That Solves Everything?

**Yes: populate g-values in the omega chain.**

This single change resolves:
- **FUC (2 sorry sites)**: C5 with guard via g + C3
- **C4 hard case (2 sorry sites)**: With proper g, R3Maximal_is_mcs gives g(x,y) as MCS. Case split on gamma in g(x,y) vs gamma.neg in g(x,y) resolves the hard case
- **Sorry contamination**: Once both are fixed, the entire omega chain becomes sorry-free

The `until_guard` axiom (Option A) is still needed as an ADDITIONAL fix for the base-point guard at `r = t`.

### Recommended Plan

| Phase | Action | Effort | Resolves |
|-------|--------|--------|----------|
| 0 | Add `until_guard` / `since_guard` axioms + soundness | 2 hours | Base-point guard gap |
| 1 | Extend `EliminationResult` with g-agreement | 2 hours | Infrastructure |
| 2 | Populate g in C5/C5' elimination (Lemma 2.10) | 4 hours | g at C5 witnesses |
| 3 | Populate g in C4/C4' elimination (Lemma 2.9) + close hard case | 6-8 hours | C4 sorry sites + g at C4 witnesses |
| 4 | Define proper `limit_g`, prove C3 at limit | 3 hours | Limit infrastructure |
| 5 | Close `cantor_bfmcs_restricted_fuc` via C5 + C3 + until_guard | 3 hours | FUC sorry sites |
| **Total** | | **20-22 hours** | **All 4 critical sorry sites + decontamination** |

### What if we skip the C4 hard case?

If we populate g but leave the C4 hard case sorry'd:
- FUC can be closed (Phase 5 works with sorry-contaminated but logically sound C5)
- BUC remains sorry-contaminated (uses limit_satisfies_c4)
- TC remains sorry-contaminated
- dd_countermodel_chronicle remains sorry-dependent

**Not a viable shortcut.** The C4 contamination must be resolved.

### What about Option D (defer with 4 sorries)?

The representation theorem structure is complete. The 4 remaining sorries are in well-understood locations with clear resolution paths. Shipping with 4 sorries is pragmatically acceptable if the goal is to demonstrate the architecture and return to close them later. But "sorry-free dd_countermodel_chronicle" -- the stated ROADMAP milestone -- requires all 4 to be closed.

---

## Summary

1. **12 sorry sites total**, 4 on the critical path, 8 legacy dead code
2. **Sorry contamination is broader than reported**: the 2 C4 sorries contaminate the entire omega chain, so ALL limit lemmas (including ones described as "sorry-free") depend on `sorryAx`
3. **The FUC base-point gap** is caused by a mismatch between the half-open guard convention `[t,s)` in truth_at (which BX9 depends on for soundness) and Burgess's open guard `(t,s)`. Resolution: add `until_guard : U(phi,psi) -> phi` axiom (sound under half-open semantics)
4. **The FUC intermediate guard** requires the interval function g with C3. Cannot be proved without g
5. **The single architectural change that solves everything**: populate g-values in the omega chain elimination functions. Combined with `until_guard`, this closes all 4 sorry sites and decontaminates the omega chain
6. **Estimated total effort**: 20-22 hours
7. **No shortcut exists** that avoids populating g. The intermediate guard fundamentally requires C3
