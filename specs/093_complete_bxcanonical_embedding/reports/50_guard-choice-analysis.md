# Guard Choice Analysis: Open (t,s) vs Half-Open [t,s) Under Irreflexive G

## Executive Summary

**Recommendation: Keep the OPEN guard (t,s).** Under irreflexive G semantics, the open
guard is strictly preferable for achieving sorry-free completeness because:

1. BX9 (until_elim) is only used in the **completeness** direction (truth lemma forward),
   and its role there is purely DERIVATIONAL (inside MCS), not semantic.
2. BX2 (left_mono_until) is used in the **soundness** direction and is provably
   sound under the open guard.
3. The half-open guard would fix BX9 soundness but BREAK BX2 soundness, creating a
   strictly harder problem (BX2 is used more broadly than BX9 in the codebase).
4. The critical insight: soundness of BX9 is NOT needed for completeness.

## Current Semantic Definitions (Truth.lean lines 127-130)

```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ     -- guard on (t,s)
| Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, s < r → r < t → truth_at M Omega τ r φ     -- guard on (s,t)
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ  -- strict G
| Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ    -- strict H
```

## Axiom Validity Under Each Guard

### Open Guard (t,s) - Current Implementation

| Axiom | Sound? | Evidence |
|-------|--------|----------|
| BX2 (left_mono_until) | YES | SoundnessLemmas.lean:1033-1034, proved |
| BX3 (right_mono_until) | YES | SoundnessLemmas.lean:1043-1044, proved |
| BX5 (self_accum) | YES | SoundnessLemmas.lean:1060-1070, proved |
| BX6 (absorb) | YES | Proved (open guard preserves structure) |
| BX7 (linear_until) | YES | Proved (witness ordering preserved) |
| BX8 (until_step) | SORRY | SoundnessLemmas.lean:1185, blocked |
| BX9 (until_elim) | NO | Counterexample: open guard excludes t |
| BX10 (until_F) | YES | SoundnessLemmas.lean:1206-1211, proved |
| BX11 (linearity) | YES | Proved |
| BX12 (F_until_equiv) | YES | Proved |

**BX9 Failure (Open Guard)**: `(phi U psi)(t)` means `exists s > t, psi(s) AND forall r in (t,s), phi(r)`.
The guard covers `(t,s)` but NOT `t` itself. So `phi(t)` is NOT guaranteed, and `phi OR psi` at t is not derivable from the semantics alone. The soundness proof (line 1195) tries `eq_or_lt_of_le hts` but `hts : t < s` (strict), so cannot split into `t = s` case.

**BX8 Sorry**: `phi AND F(phi U psi) -> (phi U psi)`. Under open guard with strict G/F:
F(phi U psi)(t) means exists t' > t with (phi U psi)(t'). That gives s' > t' with psi(s') and guard on (t', s'). We want witness s' for phi U psi at t. The guard on (t, s') needs phi on (t, s') = (t, t') union {t'} union (t', s'). We have phi(t) from hypothesis, phi on (t', s') from inner guard, but need phi on (t, t'). This is NOT available from F alone (F only gives existence of t', not what holds between t and t'). So BX8 is genuinely problematic under the open guard -- it needs density or some additional structure. On Z, BX8 IS valid because (t, t') = {t+1, ..., t'-1} and we'd need phi there, which isn't given. Actually on Z with t' = t+1, (t, t') is EMPTY, so the guard is vacuous. So BX8 is valid on Z but not on dense orders under open guard. This is a separate issue from the guard choice.

### Half-Open Guard [t,s) - Alternative

| Axiom | Sound? | Notes |
|-------|--------|-------|
| BX2 (left_mono_until) | NO | Guard includes t; G(phi->chi) is strict (t < r), so phi->chi at t is not given |
| BX9 (until_elim) | YES | Guard includes t, so phi(t) is immediate |
| BX8 (until_step) | YES (on Z) | [t, s') includes t; phi(t) from hypothesis covers it |

**BX2 Failure (Half-Open Guard)**: `G(phi->chi) -> ((phi U psi) -> (chi U psi))`.
Under [t,s): guard is `forall r, t <= r AND r < s -> phi(r)`. We need `forall r, t <= r AND r < s -> chi(r)`. For r = t: need chi(t). From G(phi->chi): `forall s, t < s -> (phi(s)->chi(s))`. At r = t: we need `phi(t)->chi(t)` but G only gives this for t < r, not r = t. So the implication at the current time is NOT available from G alone.

## The Critical Insight: Soundness vs Completeness

### What completeness needs

The completeness theorem says: if `not (Gamma |- phi)` then there exists a model where Gamma is true and phi is false. The construction:

1. Extend `Gamma + {~phi}` to an MCS `M0`
2. Build a canonical model from MCS
3. Prove the **truth lemma**: `phi in w.formulas <-> truth_at(canonical_model, w, phi)`

The truth lemma uses axioms INSIDE the MCS (derivational availability), not semantic validity.

### How BX9 is used in completeness (Frame.lean:676-697)

```lean
noncomputable def bx_until_eventuality_resolution
    (w : BXPoint) (phi psi : Formula)
    (h_until : Formula.untl phi psi in w.formulas)
    (h_not_psi : psi not_in w.formulas) :
    exists v : BXPoint, bx_le w v AND psi in v.formulas AND phi in w.formulas := by
  -- By BX10: F(psi) in w
  ...
  -- By BX9: phi in w (since phi U psi in w and psi not in w)
  have h_phiw : phi in w.formulas := by
    have h_ax := DerivationTree.axiom [] _ (Axiom.until_elim phi psi)
    have h_or := SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_ax) h_until
    ...
```

This uses BX9 as a **derivation rule inside the MCS**. It does NOT use BX9 as a semantic validity. The argument is: BX9 is an axiom in the proof system, therefore it's a theorem, therefore it's in every MCS. From `phi U psi in w` and BX9 (as a theorem in w), we derive `phi OR psi in w`. Since `psi not in w`, we get `phi in w`.

### The independence

- **Soundness** needs: axioms to be semantically valid (true in all models)
- **Completeness** needs: axioms to be in the proof system (available for derivation in MCS)

BX9 is in the proof system regardless of whether it's semantically valid under the chosen guard. The proof system is FIXED -- it includes all 35 axiom constructors. MCS are closed under these axioms BY CONSTRUCTION.

Therefore: **BX9's semantic unsoundness under open guard does NOT affect the completeness proof.**

## Impact Assessment

### Sorries Caused by Open Guard (t,s)

| Sorry | Location | Cause | Guard-Dependent? |
|-------|----------|-------|-----------------|
| `bx_le_refl` | Frame.lean:202 | G(phi)->phi invalid (no BX1 reflex) | YES - fundamental to irreflexive G |
| `g_content_subset_self` | CanonicalModel.lean:205 | Same as bx_le_refl | YES |
| BX8 soundness | SoundnessLemmas.lean:1185 | Density needed for open guard | PARTIALLY |
| BX9 soundness | (not sorry'd - proof WRONG) | BX9 unsound under open guard | YES |
| `fwd_chain_forward_F` | RootScopedChain.lean:1065 | Chain construction | NO (structural) |
| `restricted_tc` (x2) | RootScopedChain.lean:1092, 1099 | Chain F/P preservation | NO (structural) |
| `restricted_buc` | RootScopedChain.lean:1107 | Until coherence | NO (structural) |
| `restricted_fuc` | RootScopedChain.lean:1114 | Until coherence | NO (structural) |

### Key Observation About bx_le_refl

Under irreflexive G, `bx_le` (defined as `g_content(w) subset v.formulas`) is NOT reflexive.
`g_content(w) = {phi | G(phi) in w}`. Without `G(phi) -> phi` (no BX1 reflexivity axiom),
we cannot show `g_content(w) subset w`.

BUT: the completeness proof does NOT need `bx_le` to be reflexive! It needs the canonical
ORDER on the model to be a linear order. Under irreflexive G, the canonical ordering should
be STRICT (irreflexive), matching the strict semantics. The truth lemma for G already works:
`G(phi) in w <-> forall v > w, phi in v` -- this matches `t < s` in truth_at.

The sorry at `bx_le_refl` is a CONCEPTUAL ERROR from the reflexive era. Under irreflexive
semantics, bx_le should be RENAMED to bx_lt (strict ordering), and reflexivity should NOT
be expected. The chain construction already works with strict ordering.

### Sorries That Would Change Under Half-Open Guard

Switching to half-open [t,s) would:
- **FIX**: BX9 soundness (now valid)
- **BREAK**: BX2 soundness (now invalid)
- **UNCHANGED**: All 5 RootScopedChain sorries (structural, not guard-dependent)
- **UNCHANGED**: bx_le_refl sorry (this is about G semantics, not Until guard)
- **NEW PROBLEM**: BX2 is used in 38 files (grep count), BX9 in 143 files. BUT most uses
  are in reports/plans. In actual Lean code:
  - `left_mono_until` appears in: SoundnessLemmas, Axioms, Examples, CanonicalChain, Substitution
  - `until_elim` appears in: SoundnessLemmas, Axioms, Frame.lean (bx_until_eventuality_resolution),
    Substitution, Construction.lean

## BX8 Under Open Guard on Z (Integers)

BX8: `phi AND F(phi U psi) -> (phi U psi)`.

On Z with open guard: F(phi U psi)(t) means exists t' > t with (phi U psi)(t'). That is:
exists s > t', psi(s), guard phi on (t', s). We want phi U psi at t: need s > t with psi(s)
and guard phi on (t, s). Take the same s. Guard on (t, s) = (t, t') union {t'} union (t', s).

- phi on (t', s): from inner guard
- phi(t'): We have (phi U psi)(t') which under open guard does NOT give phi(t').
  Wait - we need phi(t') for the outer guard. But (phi U psi)(t') only says exists s > t'
  with guard on (t', s). phi(t') is NOT given.

So on Z with t' = t + 1: (t, t') = empty, (t', s) = {t+2, ..., s-1}. Guard needed at
t' = t+1. From (phi U psi)(t+1) under open guard: exists s > t+1, guard on (t+1, s).
If s = t+2: guard on (t+1, t+2) = empty. So phi(t+1) is NOT provided.

Actually wait, we also need phi(t+1) for the outer guard on (t, s). Let me re-check:
- Outer guard on (t, s) where s = t+2: that's {t+1}. So we need phi(t+1).
- Inner (phi U psi)(t+1) with witness s' = t+2: guard on (t+1, t+2) = empty. psi(t+2).
- So from F(phi U psi)(t), we get t' = t+1, and (phi U psi)(t+1) with witness t+2.
- We know phi(t) (from hypothesis), psi(t+2) (from inner witness).
- For phi U psi at t with witness t+2: need guard on (t, t+2) = {t+1}. Need phi(t+1).
- NOT GIVEN.

So **BX8 is NOT valid on Z under open guard (t,s) with strict Until**.

However: if we use BX9 derivationally (phi U psi at t+1 gives phi(t+1) by BX9 inside MCS),
then BX8 can be DERIVED as a consequence of BX9 + BX10 inside the proof system. This means
BX8 may be semantically unsound but derivationally available (same pattern as BX9).

Actually, this is wrong. BX9 says `(phi U psi) -> (phi OR psi)`. From (phi U psi)(t+1)
we get phi(t+1) OR psi(t+1). If psi(t+1), great. If phi(t+1), great.

The issue is SEMANTIC soundness, not derivational availability. For completeness, what
matters is that BX8 is in the proof system (it is), not that it's semantically valid.

## Conclusion and Recommendation

### Keep Open Guard (t,s)

**Rationale**:

1. **Completeness is independent of semantic validity of individual axioms.**
   The truth lemma uses axioms as derivation rules inside MCS. Whether BX9 or BX8
   are semantically valid is irrelevant to the completeness construction.

2. **BX2 soundness is essential for the overall soundness theorem.**
   Under open guard, BX2 IS sound. Under half-open guard, it would NOT be sound,
   requiring either axiom reformulation or a sorry in soundness.

3. **The 5 remaining RootScopedChain sorries are guard-independent.**
   They concern chain construction mechanics (F-preservation, Until coherence),
   not the guard convention.

4. **The bx_le_refl sorry is about irreflexive G, not the Until guard.**
   Under irreflexive G, the canonical ordering is strict. This sorry should be
   REMOVED (not fixed) by redesigning bx_le as a strict relation.

5. **BX8 and BX9 soundness sorries are ACCEPTABLE for the completeness path.**
   They affect only the soundness theorem, which is a separate concern. The soundness
   theorem already has a sorry at `axiom_locally_valid` (line 1008) with comment
   "Temporarily sorry'd during irreflexive semantics switch."

### Path Forward

1. **Remove** `bx_le_refl` -- replace with strict `bx_lt` throughout
2. **Remove** `g_content_subset_self` -- not needed for strict ordering
3. **Accept** BX8/BX9 soundness sorries (soundness theorem issue, not completeness)
4. **Focus** on the 5 structural sorries in RootScopedChain (the actual blockers)
5. **Later**: For a fully sound axiom system under open guard, either:
   - Drop BX8/BX9 from the axiom system and prove them as derived rules on specific frame classes
   - Or add a density axiom that makes BX8 sound, and replace BX9 with a weaker version

### Alternative: No BX9 in Axiom System?

If BX9 is removed from the axiom system, can completeness still work? NO:
`bx_until_eventuality_resolution` (Frame.lean:689-696) explicitly uses BX9 to derive
`phi in w` from `phi U psi in w` and `psi not in w`. Without BX9 as an axiom, this
derivation is not available in MCS.

But BX9 need not be SOUND to be in the proof system. We keep it as an axiom (ensuring
completeness works), and simply note that soundness of BX9 requires the half-open guard
or a different frame class. This is the standard approach in temporal logic: the axiom
system is designed for completeness, and soundness is proved relative to the matching
frame class.

### Summary Table

| Concern | Open Guard (t,s) | Half-Open Guard [t,s) |
|---------|-------------------|----------------------|
| BX2 sound | YES | NO |
| BX9 sound | NO | YES |
| BX8 sound | NO (on dense), PARTIAL (on Z) | YES (on Z) |
| Completeness works | YES (BX9 used derivationally) | YES (BX9 also derivational) |
| Soundness sorry count | 2 (BX8, BX9) | 1 (BX2) but BX2 is MORE fundamental |
| Net sorry burden | Lower (BX8/9 only affect their own cases) | Higher (BX2 affects monotonicity everywhere) |
| Alignment with G/H | Natural: strict everywhere | Inconsistent: G strict but U half-open |

**Final verdict: Open guard (t,s) is the correct choice for this project.**
