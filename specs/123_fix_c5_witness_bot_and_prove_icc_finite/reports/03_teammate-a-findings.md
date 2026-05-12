# Teammate A Findings: Collapse Quotient Bypass Assessment (Option A)

Task: 123 | Date: 2026-05-11

## Key Findings

1. **`collapseClass_orderIso_int` does NOT exist.** The task description stated there is "already a sorry-free collapse quotient: CollapseClass with collapseClass_orderIso_int : CollapseClass ≃o Z." This is incorrect. `CollapseClass` exists (line 1287) and has a sorry-free `LinearOrder` (lines 1459-1538), but there is NO order isomorphism to Z. The quotient infrastructure was deliberately abandoned in favor of the direct embedding approach -- see the comment at lines 1540-1555 which explicitly explains this decision.

2. **The collapse approach was already investigated and rejected (twice).** The plan's history documents this clearly:
   - **First attempt** (Phase 1 of original plan): Tried to build `CollapseClass ≃o Z` via `orderIsoIntOfLinearSuccPredArch`. Failed because proving `NoMaxOrder` on `CollapseClass` requires showing succ-orbits are bounded -- the exact same cofinality problem. Six sorry stubs were created (`collapseClass_succOrder`, `collapseClass_predOrder`, `collapseClass_isSuccArchimedean`, etc.) and all were abandoned.
   - **Second attempt** (report 07, round 4 research): Thorough 800-line analysis concluded "the collapse-based approach from the delegation context is unnecessary and would be a regression."

3. **TC and FUC are already structurally complete.** Both proofs exist (lines 2345-2389 for TC, lines 2400-2469 for FUC) and compile. They are sorry-free in their own logic -- the only sorry flows transitively through `succ_embed_surjective`. The proofs work by:
   - TC: Invoke `limit_F_resolution` / `limit_P_resolution` to get a witness `y` in `limit_dom`, then use `succ_embed_surjective` to map it to an integer.
   - FUC: Invoke `limit_satisfies_c5_strong` / `c5'_strong` to get a witness `y`, then use `succ_embed_surjective` to map it to an integer, plus `succ_embed_squeeze_strict` to verify the guard condition.

4. **BUC is already sorry-free.** The proof (lines 2269-2334) does NOT use `succ_embed_surjective`. It works by contraposition: assume the BUC condition fails, derive a C4 counterexample witness `z`, then use `succ_embed_squeeze_strict` to map `z` back to an integer. This works because both endpoints of the interval are known embedded points.

5. **The actual blocking sorry has exactly 2 sites at lines 2053 and 2056.** Both are in `succ_embed_surjective` (lines 2005-2088), specifically the "above all old points" and "below all old points" subcases of the stage induction. The "between old points" subcase is sorry-free (lines 2057-2088).

## Code Analysis

### The TC Proof (lines 2345-2389) -- How `succ_embed_surjective` Is Used

```
obtain ⟨y, hy, hlt, hφy⟩ := limit_F_resolution N h_N
  (succ_embed N h_N h_discrete_N (t + offset)).val
  (succ_embed N h_N h_discrete_N (t + offset)).property φ h_F
obtain ⟨m, hm⟩ := succ_embed_surjective N h_N h_discrete_N ⟨y, hy⟩   -- <-- THE CALL
```

TC needs surjectivity because `limit_F_resolution` produces a witness `y` that is an arbitrary `limit_dom` point. TC needs to name it as `succ_embed(m)` for some integer `m` to present it in the Z-indexed FMCS.

### The FUC Proof (lines 2400-2469) -- Same Pattern

```
obtain ⟨y, hy, hxty, hφy, h_guard⟩ := limit_satisfies_c5_strong N h_N ...
obtain ⟨m, hm⟩ := succ_embed_surjective N h_N h_discrete_N ⟨y, hy⟩   -- <-- THE CALL
```

FUC additionally uses `succ_embed_squeeze_strict` for the guard (that intermediate points satisfy the guard formula), but that only applies to already-embedded points.

### The BUC Proof (lines 2269-2334) -- Why It Does NOT Need Surjectivity

BUC works by *contraposition*: it takes a hypothesized Until pattern with known endpoints (both are `succ_embed(t + offset)` and `succ_embed(u + offset)`) and derives a contradiction via `limit_satisfies_c4`. The C4 witness `z` sits *between* two known embedded points, so `succ_embed_squeeze_strict` suffices -- no surjectivity needed.

### The Dense Case TC (lines 595-637) -- For Comparison

In the dense case, the Cantor isomorphism `iso : LimitDomSubtype ≃o Q` is a full bijection. TC uses `iso` to convert any limit_dom witness directly to a rational:
```
obtain ⟨y, hy, hlt, hφy⟩ := limit_F_resolution ...
refine ⟨iso ⟨y, hy⟩ - offset, ...⟩
```

The discrete case TC is the exact analogue, but needs `succ_embed_surjective` instead of the Cantor isomorphism because `succ_embed` is not a bijection until surjectivity is proved.

### Collapse Infrastructure Present (lines 1082-1538) -- All Sorry-Free

| Component | Lines | Status |
|-----------|-------|--------|
| `collapse_equiv` | 1104-1108 | Sorry-free |
| `collapse_equiv_refl/symm/trans` | 1113-1268 | Sorry-free |
| `collapse_setoid` | 1273-1281 | Sorry-free |
| `CollapseClass` (quotient type) | 1287-1289 | Sorry-free |
| `collapse_equiv_succ_congr` | 1296-1300 | Sorry-free |
| `collapse_orbit_convex` | 1325-1348 | Sorry-free |
| `collapse_orbit_bounded` | 1355-1364 | Sorry-free |
| `collapse_class_sep` | 1387-1432 | Sorry-free |
| `collapseClass_linearOrder` | 1459-1538 | Sorry-free |

The `CollapseClass` has `LinearOrder` but no `SuccOrder`, no `PredOrder`, no `IsSuccArchimedean`, no `NoMaxOrder`, no `NoMinOrder`, and no order isomorphism to Z.

## Refactoring Assessment

### Could TC/FUC Be Proved via CollapseClass -> Z -> LimitDomSubtype?

**Short answer: No, not without first solving the exact same problem.**

The proposed approach is: build `CollapseClass ≃o Z`, then for any `y : LimitDomSubtype` from `limit_F_resolution`, compute `collapse_map(y) : CollapseClass`, apply the order iso to get `m : Z`, and use that integer.

**Obstacle 1: The isomorphism doesn't exist.** Building `CollapseClass ≃o Z` requires `IsSuccArchimedean` on `CollapseClass`, which requires showing each succ-orbit (collapse class) is bounded above and below. This is equivalent to proving that the root's orbit is cofinal -- the exact same problem as `succ_embed_surjective`.

**Obstacle 2: Representative problems.** Even if we had the isomorphism, `collapse_iso.symm(m)` gives a `CollapseClass` element, not a `LimitDomSubtype` element. To evaluate `limit_f`, we'd need `Quotient.out` to get a representative. Then:
- We'd need `limit_f(repr) = limit_f(y)` for `repr ~ y`, which is FALSE in general (limit_f is not constant on equivalence classes -- different points in the same orbit have different MCS assignments due to C4/C5 processing).
- Alternatively, we'd need to show that for the specific formulas involved (the phi from TC/FUC), the formula membership is preserved within orbits. This requires proving that forward_G and backward_H transfer formulas along succ-steps within an orbit, which is true but adds ~100-200 lines of representative transfer lemmas.

**Obstacle 3: Guard transfer for FUC.** FUC requires showing that for any integer `r` between `t` and the witness, the guard formula holds. With the current succ_embed approach, this is straightforward: `succ_embed(r + offset)` is a known point. With the collapse approach, we'd need to show that `repr(collapse_iso.symm(r))` satisfies the guard condition, which requires relating the representative to the original C5 witness interval -- much more complex.

### Estimated LOC for Collapse Refactoring

| Component | Lines | Difficulty |
|-----------|-------|------------|
| `SuccOrder` on `CollapseClass` | ~80 | Medium |
| `PredOrder` on `CollapseClass` | ~60 | Medium |
| `IsSuccArchimedean` on `CollapseClass` | ~100 | **Hard** (same cofinality problem) |
| `NoMaxOrder` / `NoMinOrder` on `CollapseClass` | ~60 | **Hard** (same cofinality problem) |
| `CollapseClass ≃o Z` (via orderIsoIntOfLinearSuccPredArch) | ~20 | Easy (if above exist) |
| Representative transfer lemmas | ~150 | Hard |
| Rewrite TC via quotient | ~80 | Medium |
| Rewrite FUC via quotient (with guard transfer) | ~120 | Hard |
| **Total** | **~670** | **Harder than current approach** |

Compare: closing `succ_embed_surjective` requires ~100-200 lines (the cofinality argument).

### New Lemmas Needed for Collapse Approach

1. `collapseClass_succOrder : SuccOrder (CollapseClass A h_mcs h_discrete)` -- Lift succ from LimitDomSubtype to quotient.
2. `collapseClass_predOrder : PredOrder (CollapseClass A h_mcs h_discrete)` -- Lift pred.
3. `collapseClass_isSuccArchimedean : IsSuccArchimedean (CollapseClass A h_mcs h_discrete)` -- The hard one.
4. `collapseClass_noMaxOrder : NoMaxOrder (CollapseClass A h_mcs h_discrete)` -- Also hard.
5. `collapseClass_noMinOrder : NoMinOrder (CollapseClass A h_mcs h_discrete)` -- Also hard.
6. `collapse_orderIso_int : CollapseClass A h_mcs h_discrete ≃o Z` -- Automatic from 1-5.
7. `collapse_repr_forward_G_transfer` -- If `a ~ b` and `a < b`, then `G(phi) in limit_f(a) -> phi in limit_f(b)`.
8. `collapse_repr_backward_H_transfer` -- Symmetric.
9. `collapse_repr_c5_guard_transfer` -- Guard formula preservation along orbits.

## Mathematical Elegance Assessment

### Is the quotient approach mathematically correct?

Yes, in principle. The mathematics is clean: each collapse class is one succ-orbit, the quotient is Z (since there are no accumulation points in a discrete domain), and formulas can be transferred along orbits via forward_G/backward_H. This is the "Burgess construction" approach from the literature.

### Does it introduce loss of information?

Yes. The quotient forgets which specific domain point in an orbit a formula holds at, keeping only the equivalence class. Since limit_f is not constant on classes, you need representative transfer lemmas to recover the information. This is strictly more work than the current approach, which never forgets -- it evaluates limit_f directly at each embedded point.

### Is it "the right proof"?

No. The current succ_embed approach IS the right proof. It is the direct formalization of: "the limit domain, in the discrete case, is a single succ-orbit isomorphic to Z, so just embed Z into it directly." The quotient approach is a detour through abstract algebra that introduces unnecessary complexity.

The right proof of `succ_embed_surjective` is: show the succ-orbit of root is cofinal (unbounded above and below) in `LimitDomSubtype`, then apply `succ_embed_squeeze`. This is a ~100-200 line argument about bounded monotone sequences in Q, not a quotient-level refactoring.

## Recommended Approach

**Do NOT refactor TC/FUC to use the collapse quotient.** Instead, prove `succ_embed_surjective` directly.

The current architecture is clean and nearly complete:
- BUC: sorry-free
- TC: structurally complete, needs only `succ_embed_surjective`
- FUC: structurally complete, needs only `succ_embed_surjective`
- `succ_embed_surjective`: needs the cofinality argument (~100-200 lines)

The collapse quotient was a reasonable initial idea but was investigated and correctly rejected. The codebase comment at lines 1540-1555 explicitly documents the decision:

> Rather than proving the full quotient order infrastructure on `CollapseClass`
> (which requires establishing that succ-orbits are bounded -- a property deep in
> the omega-chain construction), we take a simpler approach: embed Z directly into
> `LimitDomSubtype` using `NoMaxOrder` / `NoMinOrder` to pick witnesses.

The focus should be on the cofinality lemma (`succ_orbit_cofinal_above` / `succ_orbit_cofinal_below`), which is the genuine mathematical core. The plan (v3, Phase 4) correctly identifies this.

## Confidence Level

**HIGH** -- I have read all 2541 lines of ChronicleToCountermodel.lean, the plan (v3), seven prior research reports, and the relevant ChronicleConstruction.lean definitions. The analysis is based on the actual code, not on the task description's assumptions (which were incorrect about the existence of `collapseClass_orderIso_int`).

### Summary of Confidence by Claim

| Claim | Confidence | Basis |
|-------|------------|-------|
| `collapseClass_orderIso_int` does not exist | Certain | grep + full file read |
| Collapse approach requires ~670 new lines | High | Component-level estimation from existing code |
| Collapse approach faces same cofinality problem | Certain | `IsSuccArchimedean` on quotient = cofinality |
| TC/FUC are structurally complete | Certain | Read both proofs end-to-end |
| BUC is sorry-free | Certain | Read proof, confirmed no sorry dependency |
| Cofinality is the only blocking problem | Certain | Traced all sorry dependencies |
| Direct surjectivity proof (~100-200 lines) is better | High | Compared effort and complexity |
