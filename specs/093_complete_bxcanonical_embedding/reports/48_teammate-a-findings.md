# Teammate A Findings: Detailed Codebase Impact Analysis of Irreflexive Semantics Switch

**Task**: 93 — Close remaining BXCanonical sorries
**Round**: 48
**Focus**: Exhaustive enumeration of every file, definition, axiom, and theorem affected by switching to irreflexive (strict) temporal semantics

---

## Key Findings

The switch to irreflexive semantics is a **major architectural change** that touches every layer of the codebase. The impact is not limited to the 5 sorry sites in RootScopedChain.lean; it propagates through:

1. The axiom system (Axiom.lean) — 4 axioms must be removed, 2–4 added
2. The semantic definitions (Truth.lean) — 2–3 inequality flips
3. Soundness proofs (Soundness.lean) — 4 proof sites break, 2 are trivially fixed
4. The canonical frame infrastructure (Frame.lean) — reflexivity proof and all uses of BX1 break
5. The canonical model chain (CanonicalModel.lean) — 6 uses of BX1/BX1' must change
6. The chain completeness infrastructure (RootScopedChain.lean) — 10+ uses of BX1/BX1'
7. Derived theorems (Theorems/TemporalDerived.lean) — 8 theorems break
8. The Quasimodel subsystem — partially affected

**Total estimated affected lines**: ~300–400 LOC across 10+ files.

---

## File-by-File Analysis

### 1. `Theories/Bimodal/ProofSystem/Axioms.lean` (325 LOC)

**Axioms that must CHANGE or be REMOVED under irreflexive semantics**:

| Axiom | Constructor | Current formula | Status under irreflexive |
|-------|-------------|-----------------|--------------------------|
| BX1 | `temp_t_future` | `G(φ) → φ` | **REMOVE** — not valid when G uses strict `<` |
| BX1' | `temp_t_past` | `H(φ) → φ` | **REMOVE** — not valid when H uses strict `<` |
| BX8 | `refl_intro_until` | `ψ → (φ U ψ)` | **REMOVE** — uses reflexive witness s = t; strict U needs s > t |
| BX8' | `refl_intro_since` | `ψ → (φ S ψ)` | **REMOVE** — mirror of BX8 |
| BX9 | `until_elim` | `(φ U ψ) → (φ ∨ ψ)` | **CHANGE** — the disjunction `φ ∨ ψ` used the s = t case; under strict semantics, the current-time case is harder. Under strict U semantics, φ U ψ at t means ∃ s > t, ψ(s) ∧ ∀ t ≤ r < s, φ(r). We cannot conclude φ ∨ ψ at t without also having the guard kick in at t. Actually BX9 may still be provable differently if the guard still covers t. **Needs careful analysis.** |
| BX9' | `since_elim` | `(φ S ψ) → (φ ∨ ψ)` | Mirror of BX9 — same issue |

**Axioms that must be ADDED**:

| New Axiom | Formula | Reason |
|-----------|---------|--------|
| `serial_future` | `F(⊤)` or `¬G(⊤)` | Seriality: every time has a strict future point |
| `serial_past` | `P(⊤)` or `¬H(⊤)` | Seriality: every time has a strict past point |

Note: Under the reflexive system, seriality was guaranteed by BX1 (take s = t for G(⊤)). Under strict semantics, this must be asserted directly. However, for the **integer frame**, seriality holds trivially because Z has no endpoints.

**What is preserved**: BX2–BX7, BX10–BX12, temp_k_dist, temp_4, connect_future/past, linear_until/since, all modal axioms, all interaction axioms.

**Estimated LOC to fix**: ~30–50 LOC in Axioms.lean (remove 4–6 constructors, add 2, update comments and doc strings).

---

### 2. `Theories/Bimodal/Semantics/Truth.lean` (649 LOC)

**Semantic clause changes**:

| Connective | Current definition | Change needed |
|------------|-------------------|---------------|
| `all_future φ` | `∀ s : D, t ≤ s → truth_at ... s φ` (reflexive, line 127) | Change `t ≤ s` to `t < s` |
| `all_past φ` | `∀ s : D, s ≤ t → truth_at ... s φ` (reflexive, line 126) | Change `s ≤ t` to `s < t` |
| `untl φ ψ` | `∃ s, t ≤ s ∧ ψ(s) ∧ ∀ r, t ≤ r → r < s → φ(r)` (reflexive witness, line 128) | Change witness `t ≤ s` to `t < s` (strict witness) |
| `snce φ ψ` | `∃ s, s ≤ t ∧ ψ(s) ∧ ∀ r, s < r → r ≤ t → φ(r)` (reflexive witness, line 131) | Change witness `s ≤ t` to `s < t` (strict witness) |

**What is preserved**: atom, bot, imp, box definitions — all unchanged.

**Docstring updates needed**: The extensive module header (lines 1–84) documents reflexive semantics. The `past_iff` and `future_iff` lemmas at lines 213–234 are currently labeled correctly as reflexive; they must be relabeled as strict.

**TimeShift proofs (lines 267–646)**: The time_shift preservation proofs use `le_trans` and `le_refl` in the past/future cases. These must be updated to use `lt_trans` and similar for strict inequalities. This is **mechanical** but extensive (~200 LOC of proof text needs touching).

**Estimated LOC to fix**: ~20 LOC of definitions + ~200 LOC of TimeShift proofs (mostly mechanical inequality replacements).

---

### 3. `Theories/Bimodal/Metalogic/Soundness.lean` (1331 LOC)

**Proofs that BREAK under irreflexive semantics**:

| Theorem | Location | Reason | Fix |
|---------|----------|--------|-----|
| `temp_t_future_valid` | line 200 | Uses `h_future t (le_refl t)` — reflexive step | **Delete** (axiom removed) |
| `temp_t_past_valid` | line 208 | Uses `h_past t (le_refl t)` — reflexive step | **Delete** (axiom removed) |
| `refl_intro_until_valid` | ~line 690 | Uses reflexive witness s = t (BX8) | **Delete** |
| `refl_intro_since_valid` | ~line 700 | Mirror | **Delete** |
| `until_elim_valid` | ~line 750 | The current-time disjunct `ψ` requires s = t; under strict semantics, need to verify φ ∨ ψ is still provable | **Rewrite** |
| `temp_a_valid` | line 216 | Uses strict `hts` for connect_future; currently correct under mixed semantics but needs re-verification | Check |

The `axiom_base_valid` match at line 820 handles all axioms — removing `temp_t_future`/`temp_t_past` cases would shrink it by 2 branches. Adding `serial_future`/`serial_past` requires 2 new validity proofs.

**Seriality validity**: `F(⊤)` is valid on Z (integers) since Z is without endpoints. The validity proof needs: `∀ t, ∃ s > t, True` — trivially `s = t + 1`.

**Estimated LOC to fix**: ~60 LOC (mostly deletions, plus 2 new seriality validity proofs).

---

### 4. `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (673 LOC)

**Critical impact**: This file's architecture is fundamentally based on reflexive semantics.

| Definition/Theorem | Line | Dependency on BX1 | Impact |
|-------------------|------|-------------------|--------|
| `g_content_set_consistent` | 122 | Uses `Axiom.temp_t_future` to derive `G(⊥) → ⊥` | **Rewrite**: under irreflexive semantics, need a different proof that g_content(S) is consistent |
| `bx_le_refl` | 140 | Directly uses `Axiom.temp_t_future φ` to show G(φ) ∈ w → φ ∈ w | **DELETED**: ordering is now STRICT, not reflexive |
| `bx_H_backward` (line 313) | 313 | Uses `Axiom.temp_t_past Formula.bot` | **Rewrite** |
| `enriched_seed_consistent` usage | Frame.lean references it | Indirectly uses BX1 | Cascades |

**The bx_le_refl deletion is the most impactful change**. Under strict semantics:
- `bx_le w w` is NO LONGER valid
- The canonical ordering becomes STRICT: `bx_le w v` means `g_content(w) ⊆ v.formulas` AND `w ≠ v`
- This changes the canonical frame from a preorder to a strict partial order

However, for the **completeness proof specifically**, `bx_le_refl` is used in:
- `until_backward_refl_mcs` (TruthLemma.lean line 287): `ψ ∈ w → (φ U ψ) ∈ w` via BX8
- `since_backward_refl_mcs` (TruthLemma.lean): mirror
- These also break since BX8 is removed

**Structural consequence**: The canonical frame loses reflexivity. The truth lemma for `all_future` changes from:
```
G(φ) ∈ w ↔ ∀ v, bx_le w v → φ ∈ v
```
to the same structure but with strict `bx_le`. This is sound, but the proof that `G(φ) ∉ w → ∃ v > w, φ ∉ v` (bx_G_backward) still works via `{¬φ} ∪ g_content(w)` construction.

**Estimated LOC to fix**: ~80 LOC (delete `bx_le_refl` proof, rewrite `g_content_set_consistent` and `bx_H_backward`).

---

### 5. `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` (498 LOC)

**All uses of BX1/BX1' must change**:

| Location | Line | Use | Impact |
|----------|------|-----|--------|
| `enriched_seed_consistent` | 56 | `Axiom.temp_t_future` to show g_content(M) ⊆ M | **Structural rewrite**: Under strict semantics, g_content(M) ⊆ M is no longer guaranteed by BX1. Need seriality or a different seed |
| `enriched_past_seed_consistent` | 123 | `Axiom.temp_t_past` | Same issue |
| `h_content_consistent` | 137 | `Axiom.temp_t_past Formula.bot` | **Rewrite** |
| `g_content_subset_self` | 222 | `Axiom.temp_t_future` | **Delete/rewrite** |
| `h_content_subset_self` | 229 | `Axiom.temp_t_past` | **Delete/rewrite** |
| `fwd_chain_g_content_trans` base case | 253 | `Axiom.temp_t_future` | **Rewrite** |
| `bwd_chain_h_content_trans` base case | 277 | `Axiom.temp_t_past` | **Rewrite** |

**Critical issue for enriched seeds**: The enriched seed `g_content(M) ∪ f_carry(M)` was consistent because g_content(M) ⊆ M (from BX1) and f_carry(M) ⊆ M. Without BX1, g_content(M) ⊈ M in general. Under strict semantics, we need:
- Either seriality axioms (`F(⊤) ∈ M` for all MCS M) to ensure the chain can always step forward
- Or a different construction of the enriched seed

**The `fwd_chain_g_content_trans` base case** (m = n = 0) currently uses BX1 to prove `g_content(chain(0)) ⊆ chain(0)` — reflexivity. Under strict semantics this fails. The fix depends on whether we adopt strict ordering throughout or add seriality.

**Estimated LOC to fix**: ~60 LOC (7 sites, mostly mechanical rewrites with new seriality lemmas).

---

### 6. `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (1681 LOC)

This file contains all 5 current sorry sites. Under irreflexive semantics, the impact is **additional** on top of existing sorrries.

| Location | Line | Use of BX1 | Impact |
|----------|------|-----------|--------|
| F-persistence | 474 | `Axiom.temp_t_future (Formula.neg φ)` | **Rewrite** |
| Backward F-resolution | 649, 655 | `Axiom.temp_t_future φ` | **Rewrite** |
| Backward H-resolution | 682, 688 | `Axiom.temp_t_past φ` | **Rewrite** |
| `fwd_chain_forward_F` (sorry at line 1111) | 1111 | Termination under strict U | **New proof needed** |
| `dd_bfmcs_restricted_tc` backward case (line 1138) | 1138 | Backward F in strict chain | **Same sorry, different argument** |
| `dd_bfmcs_restricted_tc` past direction (line 1145) | 1145 | P-resolution | **Same sorry** |
| `dd_bfmcs_restricted_buc` (line 1153) | 1153 | Backward Until/Since coherence | **Same sorry** |
| `dd_bfmcs_restricted_fuc` (line 1160) | 1160 | Forward Until/Since coherence | **Same sorry** |

**Key insight for the sorrys**: Under irreflexive semantics, the sorry structure actually changes:
- `fwd_chain_forward_F` (line 1111): The termination argument for F-resolution requires that if F(φ) is in the chain, then φ is eventually realized. Under strict semantics, F(φ) means ∃ s > t, φ(s), and the chain steps are strictly ordered, which should make the termination argument **easier**, not harder.
- `dd_bfmcs_restricted_buc` (line 1153): The backward Until/Since coherence was blocked under reflexive semantics because the Lindenbaum step didn't preserve the interval guard condition (due to the reflexive witness s = t being vacuous). Under strict semantics with a strict witness, this may actually be **easier to prove** because the guard condition is non-trivial.

**Estimated LOC to fix**: ~120 LOC (10 sites, mix of mechanical and structural rewrites).

---

### 7. `Theories/Bimodal/Theorems/TemporalDerived.lean` (~450 LOC)

**Theorems that break under irreflexive semantics**:

| Theorem | Line | Dependency | Impact |
|---------|------|-----------|--------|
| `G_bot_absurd` | 63 | `Axiom.temp_t_future Formula.bot` | **Delete** (axiom gone) |
| `H_bot_absurd` | 69 | `Axiom.temp_t_past Formula.bot` | **Delete** |
| `density_derivable` | 130 | `Axiom.temp_t_future φ.all_future` | **Delete/rewrite**: Under strict G, density GG(φ) → G(φ) needs a different proof |
| `past_density_derivable` | 138 | `Axiom.temp_t_past φ.all_past` | **Delete/rewrite** |
| `G_implies_topUntil` | 161 | `Axiom.temp_t_future a` + `Axiom.refl_intro_until` | **Delete** (both axioms gone) |
| `bot_until_elim (private)` | 204 | `Axiom.until_elim` | **Rewrite**: Under strict Until, `(⊥ U a) → a` changes meaning |
| `bot_since_elim (private)` | 211 | `Axiom.since_elim` | **Rewrite** |
| All callers of `until_elim`/`since_elim` | lines 249, 257 | | Cascade |

**Density under strict semantics**: `G(G(φ)) → G(φ)` under strict G is `(∀ s > t, ∀ r > s, φ(r)) → (∀ s > t, φ(s))`. This is valid — given strict s > t, take r between t and s (possible on dense/serial orders). The proof does NOT follow from BX1; it requires seriality or density. This means density_derivable is NO LONGER a free theorem under strict semantics.

**Estimated LOC to fix**: ~40 LOC.

---

### 8. `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean`

The comment at lines 165–191 already **anticipates** the strict semantics switch and notes that G and H are not interior operators under strict semantics. This file is **already prepared** for the switch.

**Impact**: Informational only. No proof changes needed; the note was written in anticipation.

---

### 9. `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/` directory

The Quasimodel files use BX1 in several places:

| File | Usage | Impact |
|------|-------|--------|
| `OracleStep.lean` line 76 | `Axiom.temp_t_future f` for g-content membership | **Rewrite** |
| `OracleStep.lean` line 141 | `Axiom.temp_t_past f` | **Rewrite** |
| `Realization.lean` line 67 | `Axiom.temp_t_future (Formula.neg ψ)` | **Rewrite** |
| `Realization.lean` line 84 | `Axiom.temp_t_past (Formula.neg ψ)` | **Rewrite** |
| `Realization.lean` lines 213, 268 | BX1 in seed consistency proofs | **Rewrite** |

However, the Quasimodel files have their own sorry infrastructure and are **not on the critical completeness path** (which goes through RootScopedChain.lean). Changes here are needed for consistency but don't block the main completeness proof.

**Estimated LOC to fix**: ~30 LOC.

---

### 10. `Theories/Bimodal/Metalogic/Bundle/` directory

Several Bundle files use BX1:

| File | Usage |
|------|-------|
| `SuccRelation.lean` line 617, 628 | `temp_t_future`/`temp_t_past` for g/h-content |
| `SuccExistence.lean` lines 468, 775, 851 | Same |

These are in the Bundle completeness path (separate from BXCanonical) and would need updating for consistency. They are not on the immediate sorry-closing path.

---

### 11. `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`

Uses `temp_t_future`/`temp_t_past` in 4 locations (lines 559, 564, 1138, 1142, 1539, 1544, 1771, 1775). All are in axiom validity dispatches. Removing the axiom cases removes the branches; no new proofs needed at these sites.

---

## What Can Be PRESERVED vs What Must Be REWRITTEN

### PRESERVED (no change needed):
- All propositional axioms (prop_k, prop_s, ex_falso, peirce)
- All S5 modal axioms (modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist)
- BX2–BX7 (monotonicity, connectedness, self-accumulation, absorption, linearity)
- BX10–BX12 (eventuality extraction, linearity, F-Until bridge)
- Modal-temporal interaction axioms (modal_future, temp_future)
- Box semantics (unchanged)
- ShiftClosed Omega infrastructure
- TimeShift.time_shift_preserves_truth (mechanical inequality replacements needed)
- bx_le_trans (still uses temp_4, unchanged)
- bx_modal_witness (unchanged — S5 modal, unaffected)
- box_preserved_along_bx_le (uses temp_future, unchanged)
- All S5 negative introspection infrastructure

### MUST BE REWRITTEN (structural change):
- BX1, BX1': Remove from Axiom.lean
- BX8, BX8': Remove from Axiom.lean (reflexive Until introduction)
- BX9, BX9': Revise (until_elim under strict semantics)
- `bx_le_refl`: Delete — canonical frame loses reflexivity
- `g_content_subset_self`, `h_content_subset_self`: Delete
- `enriched_seed_consistent`, `enriched_past_seed_consistent`: Rewrite without BX1
- All `G_bot_absurd`, `H_bot_absurd`, `density_derivable` derived theorems
- Soundness proofs for the removed axioms

### BECOMES EASIER (unexpected benefit):
- `dd_bfmcs_restricted_buc` (line 1153): The backward Until/Since coherence sorry was blocked because under reflexive semantics, the BX8 reflexive witness made the interval guard [t, s] trivially satisfiable at t = s. Under strict semantics, the guard is non-trivial and the Lindenbaum extension argument may work properly.
- `fwd_chain_forward_F`: Termination under strict ordering may be provable via well-founded induction since the strict order is irreflexive.

---

## Recommended Approach

### Phase 1: Semantics switch (mechanical, ~2 hours)
1. Change `≤` to `<` in `truth_at` for `all_future`, `all_past`, `untl` witness, `snce` witness (Truth.lean lines 126–131)
2. Update TimeShift proofs (mechanical inequality replacements, ~200 LOC)

### Phase 2: Axiom system update (mechanical, ~1 hour)
1. Remove `temp_t_future`, `temp_t_past`, `refl_intro_until`, `refl_intro_since` from Axiom.lean
2. Revise `until_elim`, `since_elim` or remove if unsound under strict semantics
3. Add `serial_future`, `serial_past` (needed for Int frame)

### Phase 3: Soundness updates (mechanical, ~1 hour)
1. Remove validity proofs for removed axioms
2. Add validity proofs for new seriality axioms

### Phase 4: Canonical frame repair (structural, ~4 hours)
1. Delete `bx_le_refl` from Frame.lean
2. Rewrite `g_content_set_consistent` using seriality instead of BX1
3. Fix `g_content_subset_self`, `h_content_subset_self` in CanonicalModel.lean
4. Rewrite chain base cases

### Phase 5: Close sorrys (new proofs, ~8 hours)
1. `fwd_chain_forward_F` (line 1111): Prove termination under strict ordering using well-founded induction on defect count
2. `dd_bfmcs_restricted_tc` backward case (line 1138): P-resolution in backward chain
3. `dd_bfmcs_restricted_buc` (line 1153): Backward Until/Since coherence — may become easier
4. `dd_bfmcs_restricted_fuc` (line 1160): Forward Until/Since coherence

---

## Evidence and Examples

### BX1 dependency chain (critical path):

```
Axiom.temp_t_future
  ↓ used in
g_content_set_consistent (Frame.lean:122)     -- consistency gate for canonical points
g_content_subset_self (CanonicalModel.lean:222) -- g_content(M) ⊆ M
bx_le_refl (Frame.lean:140)                   -- canonical ordering reflexivity
enriched_seed_consistent (CanonicalModel.lean:51) -- forward step seed
enriched_past_seed_consistent (CanonicalModel.lean:118) -- backward step seed
fwd_chain_g_content_trans base case (CanonicalModel.lean:253) -- chain ordering
```

### BX8 dependency chain (Until backward direction):
```
Axiom.refl_intro_until
  ↓ used in
until_backward_refl_mcs (TruthLemma.lean:287)  -- ψ ∈ w → (φ U ψ) ∈ w
psi_imp_until_mcs (CanonicalChain.lean:46)     -- BX8 at MCS level
psi_imp_since_mcs (CanonicalChain.lean:53)     -- BX8' at MCS level
```
Both `until_backward_refl_mcs` and its callers become invalid under strict semantics since ψ at t no longer witnesses (φ U ψ) at t when witness must be strictly > t.

### The Density Loss (non-trivial consequence):
Under reflexive semantics: `G(G(φ)) → G(φ)` is `BX1 with ψ = G(φ)` — a free theorem.
Under strict semantics: This requires: `∀ s > t, ∀ r > s, φ(r)) → ∀ s > t, φ(s)`.
Given strict s > t, we need r between t and s. On Z (integers), this is NOT generally possible (no strict between t and t+1). This means density `G(G(φ)) → G(φ)` is **NOT derivable under strict semantics on Z** without additional density assumptions.

This could affect `temp_4` (G → GG) vs. density (GG → G): Under strict semantics on Z, temp_4 (G → GG) holds but GG → G (density) does NOT. The axiom system must be verified to not implicitly assume density.

---

## Confidence Level: **HIGH**

The analysis is based on:
- Direct code reading of all key files
- Grep analysis of all 30+ sites using `temp_t_future`/`temp_t_past`
- Verification of the dependency chain from axioms through proofs
- Cross-referencing with `StrictSemanticsLegacy/README.md` which confirms prior work under strict semantics was architecturally incompatible (107 sorries) — these were not all sorry-fixable, they were structurally wrong

The main uncertainty is whether `until_elim`/`since_elim` (BX9/BX9') remain valid under strict semantics. Under strict Until `∃ s > t, ψ(s) ∧ ∀ t ≤ r < s, φ(r)`, if s = t+ε then the guard interval [t, t+ε) requires φ at t. If we take the guard to be open at t (i.e., ∀ r, t < r < s), then BX9 `(φ U ψ) → (φ ∨ ψ)` may fail: we have neither φ(t) nor ψ(t) guaranteed. The guard semantics for strict Until requires precise specification.

**Recommendation**: Before committing to the full switch, resolve the BX9/BX9' question by checking what the strict Until guard in the existing `StrictSemanticsLegacy` files assumes. This is the single most consequential semantic design choice.
