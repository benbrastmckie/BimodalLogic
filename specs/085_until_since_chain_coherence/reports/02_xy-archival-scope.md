# X/Y Archival Scope for Boneyard

**Task**: 85 — Until/Since Chain Coherence
**Artifact**: 02 (Round 2 Research)
**Date**: 2026-04-08
**Session**: sess_1775684156_a84db6

## Executive Summary

The X/Y operator footprint in the active codebase is concentrated in **3 files** with material X/Y-dependent code and **~8 files** with comments or dead references. The primary impact is:

- **4 sorry sites** directly from removed X/Y axioms (x_k_dist, x_det, y_k_dist, y_det) in `TemporalContent.lean`
- **2 sorry sites** from removed `until_induction`/`since_induction` in `WitnessSeed.lean`
- **1 sorry site** from removed `discreteness_forward` in `Discreteness.lean`
- Several theorems in `TemporalDerived.lean` that are purely X/Y but also serve as building blocks for kept Until/Since infrastructure

The cleanup is surgical: most X/Y code can be excised from files that also contain valuable non-X/Y code. Only `Discreteness.lean` is a candidate for complete archival.

---

## 1. X/Y Definition Inventory

### 1.1 X/Y Abbreviations (Private)

| File | Line | Definition | Type |
|------|------|-----------|------|
| `Theorems/TemporalDerived.lean` | 54 | `private abbrev X (a : Formula) := Formula.untl Formula.bot a` | X(a) = bot U a |
| `Theorems/TemporalDerived.lean` | 55 | `private abbrev Y (a : Formula) := Formula.snce Formula.bot a` | Y(a) = bot S a |

These are **private abbreviations**, not exported. They provide readability within TemporalDerived.lean only.

### 1.2 x_content / y_content Definitions

| File | Line | Definition |
|------|------|-----------|
| `Metalogic/Bundle/TemporalContent.lean` | 119 | `def x_content (M : Set Formula) := {phi \| Formula.untl Formula.bot phi in M}` |
| `Metalogic/Bundle/TemporalContent.lean` | 128 | `def y_content (M : Set Formula) := {phi \| Formula.snce Formula.bot phi in M}` |

---

## 2. x_content/y_content Usage Inventory

### 2.1 Definitions and Theorems in TemporalContent.lean (Lines 112-441)

All of the following are X/Y-specific infrastructure:

| Line | Name | Purpose | Sorry? |
|------|------|---------|--------|
| 119 | `x_content` | Definition | No |
| 128 | `y_content` | Definition | No |
| 150-151 | `mem_x_content_iff` | Simp lemma | No |
| 153-155 | `mem_y_content_iff` | Simp lemma | No |
| 225-230 | `x_nec` | X-necessitation | No |
| 238-243 | `y_nec` | Y-necessitation | No |
| 255-282 | `x_lift_derivation` | X-lifting in MCS | **1 sorry** (x_k_dist) |
| 288-311 | `y_lift_derivation` | Y-lifting in MCS | **1 sorry** (y_k_dist) |
| 320-330 | `x_content_set_consistent` | Consistency proof | No (uses X_bot_absurd) |
| 340-365 | `x_content_maximal` | Maximality proof | **1 sorry** (x_det) |
| 376-378 | `x_content_mcs` | Main theorem | No (combines above) |
| 386-396 | `y_content_set_consistent` | Consistency proof | No (uses Y_bot_absurd) |
| 404-429 | `y_content_maximal` | Maximality proof | **1 sorry** (y_det) |
| 437-439 | `y_content_mcs` | Main theorem | No (combines above) |

**Total**: 4 sorry sites in TemporalContent.lean, ALL from removed X/Y axioms.

### 2.2 Usage Sites Outside TemporalContent.lean

| File | Lines | Usage | Nature |
|------|-------|-------|--------|
| `Metalogic/Algebraic/Algebraic.lean` | 13-14, 40, 99-100 | Commented-out imports for DeterministicChain/FMCS | **Comment only** |
| `Metalogic/Algebraic/DovetailedChain.lean` | 627-648 | Comments about x_content blocker | **Comment only** |
| `Metalogic/Bundle/UntilSinceCoherence.lean` | 30-31 | Comment about deterministic chain | **Comment only** |
| `Metalogic/Bundle/TemporalCoherence.lean` | 442, 450-451 | Comments about x_content chain | **Comment only** |
| `Metalogic/Bundle/SuccRelation.lean` | 557 | Comment about X(alpha) equivalence | **Comment only** |
| `FrameConditions/Completeness.lean` | 328, 599, 621 | Comments about x_content chains | **Comment only** |

**No active code** outside TemporalContent.lean references x_content or y_content.

---

## 3. Theorems Using X/Y

### 3.1 Theorems in TemporalDerived.lean

**PURELY X/Y (candidates for removal)**:

| Line | Name | Statement | Used By |
|------|------|-----------|---------|
| 154-166 | `G_implies_G_step` | G(a) -> G((top ^ X(a)) -> a) | Nothing active |
| 187-189 | `G_implies_X` | G(a) -> X(a) | TemporalContent.lean (x_nec) |
| 195-197 | `H_implies_Y` | H(a) -> Y(a) | TemporalContent.lean (y_nec) |
| 253-255 | `YX_identity` | Y(X(phi)) -> phi | Boneyard only |
| 259-261 | `XY_identity` | X(Y(phi)) -> phi | Boneyard only |
| 264-268 | `y_nec'` (private) | If proves phi then proves Y(phi) | Internal only |
| 271-275 | `x_nec'` (private) | If proves phi then proves X(phi) | Internal only |
| 278-280 | `YG_implies_self` | Y(G(phi)) -> phi | Boneyard only |
| 283-285 | `XH_implies_self` | X(H(phi)) -> phi | Boneyard only |
| 385-389 | `x_implies_id` | X(alpha) -> alpha | `until_intro`, `until_unfold_X` |
| 392-396 | `y_implies_id` | Y(alpha) -> alpha | `since_intro`, `since_unfold_Y` |

**X/Y-DERIVED BUT USED BY KEPT CODE**:

| Line | Name | Statement | Used By |
|------|------|-----------|---------|
| 204-210 | `X_bot_absurd` | (bot U bot) -> bot | WitnessSeed.lean, TemporalContent.lean |
| 215-218 | `Y_bot_absurd` | (bot S bot) -> bot | WitnessSeed.lean, TemporalContent.lean |
| 238-242 | `X_elim` (private) | (bot U a) -> a | x_implies_id, YX_identity |
| 244-249 | `Y_elim` (private) | (bot S a) -> a | y_implies_id, XY_identity |
| 460-463 | `until_unfold_X` | (phi U psi) -> X(psi v (phi ^ (phi U psi))) | SuccRelation.lean |
| 466-469 | `since_unfold_Y` | (phi S psi) -> Y(psi v (phi ^ (phi S psi))) | SuccRelation.lean |
| 474-477 | `until_intro` | X(psi v (phi ^ (phi U psi))) -> (phi U psi) | SuccRelation.lean, UntilSinceCoherence |
| 480-483 | `since_intro` | Y(psi v (phi ^ (phi S psi))) -> (phi S psi) | SuccRelation.lean, UntilSinceCoherence |

**IMPORTANT SUBTLETY**: `X_bot_absurd`, `until_unfold_X`, `since_unfold_Y`, `until_intro`, `since_intro`, `x_implies_id`, and `y_implies_id` are expressed in terms of X/Y notation but are mathematically just theorems about `(bot U phi)` and `(bot S phi)`. Under reflexive semantics, these reduce to simpler statements. They are **used by active code** (SuccRelation, WitnessSeed, UntilSinceCoherence).

### 3.2 Theorems in WitnessSeed.lean Using X/Y

| Line | Theorem | X/Y Usage |
|------|---------|-----------|
| 419-425 | `until_witness_seed_consistent` | Uses `X_bot_absurd` (sorry-free derivation) |
| 446-450 | same | Uses `until_induction` (**sorry: removed in BX**) |
| 537-544 | `since_witness_seed_consistent` | Uses `Y_bot_absurd` (sorry-free derivation) |
| 569 | same | Uses `since_induction` (**sorry: removed in BX**) |

### 3.3 Theorems in SuccRelation.lean Using X/Y

| Line | Theorem | X/Y Usage |
|------|---------|-----------|
| 510-516 | `until_unfold_in_mcs` | Uses `until_unfold_X` (bot U ...) |
| 518-524 | `since_unfold_in_mcs` | Uses `since_unfold_Y` (bot S ...) |
| 542-548 | `until_persists_through_succ` | **sorry**: needs X-content propagation |

### 3.4 Removed Axiom Validity Theorems (Soundness.lean)

Lines 715-728: Comment block documenting removed validity theorems:
- `x_k_dist_valid`, `x_det_valid`, `y_k_dist_valid`, `y_det_valid`
- `yx_identity_valid`, `xy_identity_valid`
- `next_implies_some_future_valid`
- `until_unfold_valid`, `until_intro_valid`, `until_induction_valid`
- `since_unfold_valid`, `since_intro_valid`, `since_induction_valid`

These are **already removed** (only the comment remains).

---

## 4. Files to Move to Boneyard/

### 4.1 Complete Files for Archival

| File | Reason | Sorry Count |
|------|--------|-------------|
| `Theorems/Discreteness.lean` | Entirely about discrete axiom DF/DP, which depend on X/Y successor structure. Single sorry from `discreteness_forward removed in BX`. No active callers. | 1 |

**Note**: DeterministicChain.lean and DeterministicFMCS.lean are already in Boneyard/.

### 4.2 Files Already in Boneyard (No Action Needed)

- `Boneyard/ChainCompleteness/Algebraic/DeterministicChain.lean`
- `Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean`
- `Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean`

---

## 5. Files to Edit (Not Move)

### 5.1 TemporalContent.lean — Remove x_content/y_content Section

**File**: `Metalogic/Bundle/TemporalContent.lean`

**Remove** (lines 112-441):
- `x_content`, `y_content` definitions
- `mem_x_content_iff`, `mem_y_content_iff` simp lemmas
- `x_nec`, `y_nec` (X/Y necessitation)
- `x_lift_derivation`, `y_lift_derivation`
- `x_content_set_consistent`, `y_content_set_consistent`
- `x_content_maximal`, `y_content_maximal`
- `x_content_mcs`, `y_content_mcs`

**Keep** (lines 1-111, 131-215):
- `g_content`, `h_content` definitions and membership lemmas
- `f_content`, `p_content` definitions and membership lemmas
- `u_content`, `s_content` definitions and membership lemmas
- `f_content_iff_not_neg_in_g_content`, `p_content_iff_not_neg_in_h_content`

**Update**: Module docstring (lines 5-41) to remove x_content/y_content references.

**Sorry impact**: Removes 4 sorry sites (x_k_dist, y_k_dist, x_det, y_det).

### 5.2 TemporalDerived.lean — Remove Purely X/Y Theorems

**File**: `Theorems/TemporalDerived.lean`

**Remove**:
- Line 54-55: `private abbrev X` and `private abbrev Y`
- Lines 154-166: `G_implies_G_step` (references X in its type)
- Lines 184-197: `G_implies_X`, `H_implies_Y`
- Lines 251-261: `YX_identity`, `XY_identity`
- Lines 263-275: `y_nec'`, `x_nec'` (private)
- Lines 278-285: `YG_implies_self`, `XH_implies_self`

**KEEP (but rename/rephrase)**:
- Lines 200-218: `X_bot_absurd` -> rename to `bot_until_bot_absurd` or similar
- Lines 236-249: `X_elim` (private), `Y_elim` (private) -> rename to `bot_until_elim`, `bot_since_elim`
- Lines 385-396: `x_implies_id`, `y_implies_id` -> rename to `bot_until_id`, `bot_since_id`
- Lines 458-483: `until_unfold_X`, `since_unfold_Y`, `until_intro`, `since_intro` -> rename to remove X/Y language

These theorems about `bot U phi` and `bot S phi` are mathematically valid (they use only BX8 + BX9), sorry-free, and used by active infrastructure. They just happen to be named after the X/Y operators.

### 5.3 SuccRelation.lean — Update Comments and Names

**File**: `Metalogic/Bundle/SuccRelation.lean`

**Edit**:
- Lines 510-524: `until_unfold_in_mcs`, `since_unfold_in_mcs` — update comments to remove X/Y references; update to use renamed TemporalDerived theorems
- Lines 542-548: `until_persists_through_succ` — update comment to remove X-content language (sorry remains, it's a real gap)
- Lines 550-560: Comment block about X/Y replacement — rewrite

### 5.4 WitnessSeed.lean — Update Comments

**File**: `Metalogic/Bundle/WitnessSeed.lean`

**Edit**:
- Lines 409-463: `until_witness_seed_consistent` — update comments referencing X(bot), X_bot_absurd
- Lines 537-580: `since_witness_seed_consistent` — update comments referencing Y(bot), Y_bot_absurd
- Code references to `X_bot_absurd`/`Y_bot_absurd` must be updated to new names

### 5.5 Other Files — Comment Cleanup

These files have X/Y references only in comments (no code changes needed for correctness, but should be cleaned for clarity):

| File | Lines | Comment Content |
|------|-------|----------------|
| `Metalogic/Algebraic/Algebraic.lean` | 13-14, 40, 99-100 | Commented imports and architecture diagram |
| `Metalogic/Algebraic/DovetailedChain.lean` | 39, 627-648 | x_content discussion |
| `Metalogic/Bundle/UntilSinceCoherence.lean` | 30-31 | DeterministicFMCS x_content reference |
| `Metalogic/Bundle/TemporalCoherence.lean` | 442, 450-451 | x_content/until_intro discussion |
| `Metalogic/Bundle/SuccRelation.lean` | 533, 557 | next_implies_some_future, X(alpha) |
| `FrameConditions/Completeness.lean` | 6, 328, 599, 621 | DovetailedChain reference, x_content |
| `Metalogic/Soundness.lean` | 715-728 | Removed axiom list |
| `Metalogic/Algebraic/README.md` | 47-48, 52, 85-87 | DeterministicChain/FMCS references |

### 5.6 Theorems.lean — Remove Discreteness Import

**File**: `Theorems.lean` (the barrel import file)

Must remove `import Bimodal.Theorems.Discreteness` after archiving Discreteness.lean.

---

## 6. Dependency Analysis

### 6.1 What Breaks When X/Y Infrastructure Is Removed

**Direct breakage** (code references removed definitions):

1. `TemporalContent.lean`: `x_content_mcs`/`y_content_mcs` are removed — but nothing in active code imports them.
2. `TemporalDerived.lean`: `G_implies_X`, `H_implies_Y` are removed — used only by `x_nec` in TemporalContent.lean (also removed).
3. `TemporalDerived.lean`: `X_bot_absurd`, `Y_bot_absurd` renamed — WitnessSeed.lean and TemporalContent.lean import by name.
4. `TemporalDerived.lean`: `x_implies_id`, `y_implies_id` renamed — `until_intro`/`since_intro` use them internally.
5. `TemporalDerived.lean`: `until_unfold_X`, `since_unfold_Y` renamed — SuccRelation.lean imports by name.

**Transitive dependencies** (files that import affected files):

```
TemporalContent.lean
  <- SuccRelation.lean (imports TemporalContent)
  <- SuccExistence.lean (imports SuccRelation)
  <- SuccChainFMCS.lean (imports SuccExistence)
  <- many downstream files

TemporalDerived.lean
  <- TemporalContent.lean (imports TemporalDerived)
  <- WitnessSeed.lean (imports TemporalDerived)
  <- SuccRelation.lean (imports TemporalDerived indirectly)
  <- UntilSinceCoherence.lean (imports TemporalDerived)
```

**All breakage is from renamed symbols**, not removed functionality. The mathematical content (bot U bot -> bot, bot U phi -> phi, etc.) is preserved under new names.

### 6.2 What Does NOT Break

- All `g_content`, `h_content`, `f_content`, `p_content`, `u_content`, `s_content` — unchanged.
- All BX axioms (Axioms.lean) — no X/Y axioms exist.
- All Succ relation definitions and core theorems — no X/Y dependency.
- All SuccChainFMCS construction — uses Succ, not x_content.
- All BFMCS/FMCS definitions — no X/Y dependency.
- All soundness proofs — X/Y validity already removed.
- All decidability/FMP code — no X/Y dependency.
- All BXCanonical completeness — uses box_content, not x_content.

---

## 7. Impact Assessment

### 7.1 Sorry Sites in X/Y-Dependent Code

| File | Count | Sorry Text |
|------|-------|------------|
| `TemporalContent.lean` | 4 | x_k_dist, y_k_dist, x_det, y_det |
| `WitnessSeed.lean` | 2 | until_induction, since_induction |
| `Discreteness.lean` | 1 | discreteness_forward |
| **Total** | **7** | |

### 7.2 Sorry Sites After Archival

Removing the x_content/y_content section from TemporalContent.lean removes 4 sorries.
Moving Discreteness.lean to Boneyard removes 1 sorry.
The 2 WitnessSeed.lean sorries (`until_induction removed in BX`) are **NOT X/Y-specific** — they use the `until_induction` axiom which is about Until generally, not X/Y. These remain.

**Net sorry reduction**: 5 (from 289 total active sorries to 284).

### 7.3 What Remains After Archival

The 2 `until_induction`/`since_induction` sorries in WitnessSeed.lean remain. These are legitimate proof gaps: the BX axiom system does not include `until_induction` as a primitive, and it needs to be derived from the existing axioms or the proof approach needs restructuring. This is separate from the X/Y cleanup.

---

## 8. Recommended Archival Plan

### Phase 1: Rename X/Y Theorems in TemporalDerived.lean (Non-Breaking)

1. Rename in TemporalDerived.lean:
   - `X_bot_absurd` -> `bot_until_bot_absurd`
   - `Y_bot_absurd` -> `bot_since_bot_absurd`
   - `X_elim` -> `bot_until_elim`
   - `Y_elim` -> `bot_since_elim`
   - `x_implies_id` -> `bot_until_id`
   - `y_implies_id` -> `bot_since_id`
   - `until_unfold_X` -> `until_unfold_wrapped`
   - `since_unfold_Y` -> `since_unfold_wrapped`
   - (until_intro, since_intro keep their names)

2. Update all call sites:
   - WitnessSeed.lean: X_bot_absurd -> bot_until_bot_absurd, Y_bot_absurd -> bot_since_bot_absurd
   - SuccRelation.lean: until_unfold_X -> until_unfold_wrapped, since_unfold_Y -> since_unfold_wrapped
   - TemporalContent.lean: X_bot_absurd -> bot_until_bot_absurd, Y_bot_absurd -> bot_since_bot_absurd

3. `lake build` to verify no regressions.

### Phase 2: Remove Purely X/Y Code from TemporalDerived.lean

1. Remove the `private abbrev X` and `private abbrev Y` lines.
2. Remove theorems only used by X/Y infrastructure:
   - `G_implies_G_step`
   - `G_implies_X`, `H_implies_Y`
   - `YX_identity`, `XY_identity`
   - `y_nec'`, `x_nec'` (private)
   - `YG_implies_self`, `XH_implies_self`
3. Update module docstring.
4. `lake build` to verify.

### Phase 3: Remove x_content/y_content from TemporalContent.lean

1. Remove definitions: `x_content`, `y_content`
2. Remove simp lemmas: `mem_x_content_iff`, `mem_y_content_iff`
3. Remove all X/Y MCS infrastructure (x_nec, y_nec, x_lift_derivation, y_lift_derivation, x_content_set_consistent, x_content_maximal, x_content_mcs, y_content_set_consistent, y_content_maximal, y_content_mcs)
4. Update module docstring.
5. `lake build` to verify. Eliminates 4 sorry sites.

### Phase 4: Archive Discreteness.lean

1. Move `Theorems/Discreteness.lean` to `Boneyard/DiscreteXY/Discreteness.lean`
2. Remove `import Bimodal.Theorems.Discreteness` from `Theorems.lean` (or any barrel file)
3. `lake build` to verify. Eliminates 1 sorry site.

### Phase 5: Clean Up Comments

1. Update comments in:
   - Algebraic.lean
   - DovetailedChain.lean
   - UntilSinceCoherence.lean
   - TemporalCoherence.lean
   - SuccRelation.lean
   - FrameConditions/Completeness.lean
   - Soundness.lean
   - Algebraic/README.md
2. Remove references to DeterministicChain, DeterministicFMCS, x_content chains from active code comments.

### Phase 6: Verify and Document

1. `lake build` full project
2. Count remaining sorry sites
3. Update sorry summary in plan

---

## 9. What Should NOT Be Moved

### 9.1 Theorems About bot U phi (Renamed, Not Removed)

- `bot_until_bot_absurd` (was X_bot_absurd): `(bot U bot) -> bot` — used by WitnessSeed
- `bot_since_bot_absurd` (was Y_bot_absurd): `(bot S bot) -> bot` — used by WitnessSeed
- `bot_until_id` (was x_implies_id): `(bot U a) -> a` — used by until_intro
- `bot_since_id` (was y_implies_id): `(bot S a) -> a` — used by since_intro
- `until_intro`: `(bot U (psi v (phi ^ (phi U psi)))) -> (phi U psi)` — used by SuccRelation, UntilSinceCoherence
- `since_intro`: mirror — used by SuccRelation, UntilSinceCoherence

These are general Until/Since theorems that happen to use `bot U phi` pattern. They are sorry-free and used by active completeness infrastructure.

### 9.2 BX8/BX9/BX10 Axioms and Derived Theorems

Everything involving `psi_imp_until`, `psi_imp_since`, `until_imp_or`, `since_imp_or`, `until_imp_F`, `since_imp_P`, `or_until_imp`, `or_since_imp`, `until_unfold_thm`, `since_unfold_thm` — these are pure Until/Since theorems with no X/Y dependency. They MUST be kept.

### 9.3 u_content / s_content

`u_content` and `s_content` in TemporalContent.lean extract Until/Since pairs from MCS. These are NOT X/Y-related and must be kept.

### 9.4 SuccRelation.lean (Entire File)

The Succ relation and its core theorems use g_content/f_content, not x_content/y_content. The file has one sorry (`until_persists_through_succ`) but that's a genuine proof gap about Until propagation, not an X/Y artifact. Keep entirely.

### 9.5 DovetailedChain.lean

Despite having X/Y-related comments, this file's core construction uses g_content-based seeds and Lindenbaum extension. It has 2 sorries from removed `F_until_equiv` and `P_since_equiv` which are NOT X/Y axioms (they're Until/F equivalence). Keep, but update comments.

### 9.6 WitnessSeed.lean

Uses X_bot_absurd/Y_bot_absurd (to be renamed) for legitimate proofs. The 2 `until_induction`/`since_induction` sorries are about Until generally, not X/Y specifically. Keep entirely.

---

## 10. Appendix: Files Affected Summary

| File | Action | Sorry Delta |
|------|--------|-------------|
| `Theorems/TemporalDerived.lean` | Edit: rename, remove X/Y-only defs | 0 |
| `Metalogic/Bundle/TemporalContent.lean` | Edit: remove x/y_content section | -4 |
| `Theorems/Discreteness.lean` | Move to Boneyard | -1 |
| `Metalogic/Bundle/WitnessSeed.lean` | Edit: update names in code + comments | 0 |
| `Metalogic/Bundle/SuccRelation.lean` | Edit: update names + comments | 0 |
| `Metalogic/Bundle/UntilSinceCoherence.lean` | Edit: update comments | 0 |
| `Metalogic/Bundle/TemporalCoherence.lean` | Edit: update comments | 0 |
| `Metalogic/Algebraic/Algebraic.lean` | Edit: update comments | 0 |
| `Metalogic/Algebraic/DovetailedChain.lean` | Edit: update comments | 0 |
| `FrameConditions/Completeness.lean` | Edit: update comments | 0 |
| `Metalogic/Soundness.lean` | Edit: update comments | 0 |
| `Metalogic/Algebraic/README.md` | Edit: remove DeterministicChain refs | 0 |
| `Theorems.lean` | Edit: remove Discreteness import | 0 |
| **Total** | | **-5** |
