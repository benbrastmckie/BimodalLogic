# Handoff: Phase 1 - Burgess Lemma 2.6 for BurgessR3Maximal

## Session
- **Session ID**: sess_1777313875_bfebeb
- **Date**: 2026-04-27
- **Branch**: irr_until
- **Status**: PARTIAL (Phase 1 tasks 1.1-1.4 incomplete; infrastructure lemmas completed)

## What Was Done (Sorry-Free)

Four new sorry-free theorems were added to `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`:

### 1. `dc_delta_B_controlled` (line ~548)
**Purpose**: Shows elements of `deductiveClosure({delta} union B)` are "controlled" by single B-elements plus delta.

**Statement**: If `L` is a subset of `{delta} union B` (B a DCS), and `L` derives `phi`, then either `phi in B` or there exists `beta in B` with `[] derives (beta AND delta) implies phi`.

**Key technique**: Filters L into B-elements and delta. If delta is in L, uses deduction theorem to extract `L_B derives delta implies phi`. If L_B is empty, uses top as beta. If L_B is nonempty, uses DCS closure to get `(delta implies phi) in B` as the beta witness.

### 2. `BurgessR3Maximal_extension_fails` (line ~579)
**Purpose**: Direct consequence of BurgessR3Maximal definition -- any proper DCS extension violating maximality.

**Statement**: If `BurgessR3Maximal(A, B, C)`, `delta not in B`, and `{delta} union B` is consistent, then `deductiveClosure({delta} union B)` does NOT satisfy `burgessR3(A, -, C)`.

### 3. `dc_delta_B_burgessR3` (line ~590)
**Purpose**: Shows that if both Until and Since extension conditions hold for delta, then `DC({delta} union B)` satisfies `burgessR3(A, -, C)`.

**Statement**: Given `burgessR3(A, B, C)`, if for all `beta in B, gamma in C: untl(beta AND delta, gamma) in A`, and for all `beta in B, alpha in A: snce(beta AND delta, alpha) in C`, then `burgessR3(A, DC({delta} union B), C)`.

**Key technique**: Uses `dc_delta_B_controlled` to decompose elements of the deductive closure, then applies `untl_left_mono_thm` (BX2) and `snce_left_mono_thm` (BX2') for the non-B case.

### 4. `BurgessR3Maximal_maximality_combined` (line ~614)
**Purpose**: The key maximality witness -- negation of the combined Until+Since extension conditions.

**Statement**: If `BurgessR3Maximal(A, B, C)` and `delta not in B`, then NOT both:
- for all `beta in B, gamma in C: untl(beta AND delta, gamma) in A`
- for all `beta in B, alpha in A: snce(beta AND delta, alpha) in C`

**Key technique**: Two cases on `delta.neg in B`:
- If `delta.neg in B`: derives `untl(bot, gamma) in A` via BX2, then `bot in A` via `until_guard`, contradiction.
- If `delta.neg not in B`: shows `{delta} union B` is consistent (via DCS closure argument), then applies `dc_delta_B_burgessR3` to get `burgessR3(A, DC({delta} union B), C)`, contradicting maximality via `BurgessR3Maximal_extension_fails`.

## What Remains (Phase 1 Tasks 1.1-1.4)

The maximality witness (theorem 4 above) establishes that the extension conditions FAIL. The remaining work is to use this failure to construct the actual splitting:

### Task 1.1: Seed Consistency for D (the new MCS)

Need to prove that `B union {neg(delta)}` (or a richer seed) is consistent, then extend to MCS D via Lindenbaum. The key challenge: Burgess's proof uses A4a (not valid under strict semantics) to show the seed `D_0 = {S(alpha,beta) : alpha in A, beta in B} union B union {neg(delta)} union {U(gamma,beta) : gamma in C, beta in B}` is consistent.

**Mathematical challenge**: Replacing A4a with BX axiom chains (BX5+BX6+BX7) in the consistency argument. The existing `lemma_2_4` uses BX4+BX5 successfully for a similar (simpler) seed. The Lemma 2.6 seed is harder because it involves BOTH Until and Since components.

**Possible approach**: 
- The maximality witness gives `neg(untl(beta0 AND delta, gamma0)) in A` for some `beta0 in B, gamma0 in C` (Until direction fails), OR `neg(snce(beta0 AND delta, alpha0)) in C` (Since direction fails).
- In the Until-failure case: `neg(untl(beta0 AND delta, gamma0)) in A` combined with `untl(beta0, gamma0) in A` (from burgessR3) gives, via BX7 linearity analysis, that `F(beta0 AND neg(delta)) in A` (or similar), providing seed consistency for `{neg(delta)} union B`.
- In the Since-failure case: symmetric argument.

This is the crux of the mathematical work and likely requires 10+ hours of careful axiom chain construction.

### Task 1.2: Construct MCS D
Once seed consistency is proved, this is mechanical: Lindenbaum extension. Derive `neg(delta) in D` from the seed.

### Task 1.3: Construct B' and B''
Need seeds for `burgessR3Maximal_extension_exists`:
- For B' (left interval): need `eta'` with `burgessR(A, eta', D)` AND `burgessRSince(D, eta', A)`
- For B'' (right interval): need `eta''` with `burgessR(D, eta'', C)` AND `burgessRSince(C, eta'', D)`

The seed construction depends on what D contains (which depends on how D_0 is built).

### Task 1.4: Assemble the full theorem
Combine Tasks 1.1-1.3 into `burgess_lemma_2_6_content`.

## Key Insights Discovered

1. **BurgessR3 is anti-monotone in B**: Unlike the obligation-based `r3Relation` (which is monotone and forces R3Maximal to be MCS), the content-based `burgessR3` is anti-monotone. This means `BurgessR3Maximal` DCS are genuinely non-MCS, requiring the full Lemma 2.6 splitting argument.

2. **Extension control via dc_delta_B_controlled**: Elements of `DC({delta} union B)` can be decomposed into "from B" (use existing burgessR3) or "from (beta AND delta)" (use BX2 left monotonicity). This is the key technical insight enabling the burgessR3 transfer.

3. **Two-case structure of the maximality witness**: The `delta.neg in B` case is independently contradictory (derives `bot in A`), while the `delta.neg not in B` case uses the full extension machinery. This means the maximality witness holds regardless of whether B has negation completeness for delta.

4. **A4a replacement is the core difficulty**: Burgess's A4a gives `(phi U psi) AND neg(phi U (psi AND chi)) -> (psi AND neg(chi)) U psi`. Under strict semantics, this must be replaced by BX5+BX6+BX7 chains, which is possible but intricate.

## Build State
- `lake build` succeeds (1097 jobs)
- Zero sorries in PointInsertion.lean
- All existing sorry-free lemmas remain sorry-free
- All new theorems verify clean (no `sorryAx`)

## Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- 4 new theorems added (~120 lines), all sorry-free. File was rewritten to fix corrupted unicode from a previous edit. All existing theorems preserved exactly.
