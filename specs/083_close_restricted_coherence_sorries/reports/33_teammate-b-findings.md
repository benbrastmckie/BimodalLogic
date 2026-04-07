# Teammate B Findings: Unsoundness Resolution and Axiom System Design for Purely Reflexive Logic

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Focus**: Complete unsoundness audit, replacement axiom system design, theorem survival analysis

---

## 1. Key Findings

### 1.1 Complete Unsoundness Audit

**Two axioms are unsound** under the current mixed semantics (reflexive G/H, strict U/S):

| Axiom | Location | Sorry | Root Cause |
|-------|----------|-------|------------|
| `F_until_equiv` | Axioms.lean:608, Soundness.lean:770 | Yes | F(psi) includes witness s=t but U requires s>t |
| `P_since_equiv` | Axioms.lean:617, Soundness.lean:786 | Yes | P(psi) includes witness s=t but S requires s<t |

**All other axioms are sound.** The remaining axioms in Soundness.lean that show sorry (lines 1182-1205) are in `axiom_valid_base_fc` which expects base-frame validity for discrete-only axioms -- these are frame-class categorization issues, not soundness failures. The discrete axioms (until_unfold, until_intro, until_induction, until_linearity, etc.) are proven sound in `axiom_valid_discrete` (with sorry only for F_until_equiv/P_since_equiv).

**Confidence: HIGH**

### 1.2 Dependency Chain from Unsound Axioms

The unsoundness propagates through a specific chain:

```
F_until_equiv (UNSOUND)
  -> G_implies_topUntil (TemporalDerived.lean:58)
     -> G_implies_X (TemporalDerived.lean:110)  [CRITICAL -- uses F_until_equiv + until_induction + seriality]
        -> g_content_propagates_to_x_content (DeterministicChain.lean:323)
           -> forward_G_int (DeterministicChain.lean:~413)
           -> forward_G (DeterministicChain.lean:~440)
           -> many chain infrastructure theorems
        -> x_nec' (TemporalDerived.lean:345)
           -> XH_implies_self (TemporalDerived.lean:373)
        -> X_bot_absurd (TemporalDerived.lean:237)
           -> until_implies_some_future (TemporalDerived.lean:261)
        -> UltrafilterChain.lean (uses G_implies_X)
        -> Bundle/TemporalContent.lean (uses G_implies_X)
        -> Bundle/WitnessSeed.lean (uses G_implies_X)

P_since_equiv (UNSOUND)
  -> H_implies_Y (TemporalDerived.lean:143)  [CRITICAL -- mirror of G_implies_X]
     -> h_content_propagates_to_y_content (DeterministicChain.lean:335)
        -> backward_H_int, backward_H, many chain theorems
     -> y_nec' (TemporalDerived.lean:338)
        -> YG_implies_self (TemporalDerived.lean:353)
     -> Y_bot_absurd (TemporalDerived.lean:250)
        -> since_implies_some_past (TemporalDerived.lean:294)

F_until_equiv also used directly in:
  -> F_to_until_in_mcs (FiniteDeferral.lean:44)
  -> F_to_until_in_chain (FiniteDeferral.lean:52)
  -> DovetailedChain.lean:573, 694
```

**The single most critical dependency**: `G_implies_X` (and its mirror `H_implies_Y`). These are used pervasively throughout the entire chain construction infrastructure. They are the load-bearing theorems that enable the deterministic chain to propagate G-formulas forward through successor steps.

**Confidence: HIGH**

### 1.3 What is NOT Affected by Unsoundness

The following are **sound regardless**:
- All propositional axioms and theorems (Propositional.lean, Combinators.lean)
- All S5 modal axioms and theorems (ModalS5.lean, ModalS4.lean)
- Perpetuity theorems (Perpetuity.lean)
- GeneralizedNecessitation (GeneralizedNecessitation.lean)
- All G/H-only temporal axioms: temp_t_future, temp_t_past, temp_a, temp_a_dual, temp_4, temp_k_dist, temp_l, temp_linearity
- Modal-temporal interaction: modal_future, temp_future
- Discreteness (Discreteness.lean) -- only uses discreteness_forward
- Until/Since axioms that do NOT convert between F/U or P/S: until_unfold, until_intro, until_induction, until_linearity, since_unfold, since_intro, since_induction, since_linearity, until_connectedness, since_connectedness
- Discrete X/Y axioms: disc_next, disc_prev, x_k_dist, x_det, y_k_dist, y_det, yx_identity, xy_identity, next_implies_some_future

---

## 2. Recommended Approach: Hybrid (Option E' + Burgess-Xu Foundation)

### 2.1 Recommendation Summary

I recommend a **two-phase approach**:

**Phase 1 (Immediate)**: Apply Option E' -- replace 2 unsound axioms with 4 sound ones. Minimal change, restores soundness, keeps discrete infrastructure.

**Phase 2 (Strategic)**: Switch U/S semantics from strict to reflexive (Burgess-Xu style). This is a minimal semantic change (only `t < s` to `t <= s` for the witness condition) that eliminates the root cause.

### 2.2 Why NOT Full Burgess-Xu Immediately

The full Burgess-Xu system (report 32) replaces ALL discrete axioms with 14 BX temporal axioms. This would:
- **Remove** all X/Y-based axioms (until_unfold, until_intro, until_induction, x_k_dist, x_det, yx_identity, etc.)
- **Destroy** the entire deterministic chain infrastructure (DeterministicChain.lean, DeterministicFMCS.lean, FiniteDeferral.lean)
- Require a completely new completeness proof architecture
- Estimated effort: 3000-5000 LOC rewrite

The BX system is the right long-term target, but it is not needed to fix soundness.

### 2.3 Why NOT Option E' Alone

Option E' (from report 31) replaces F_until_equiv/P_since_equiv with F_unfold_disc/P_unfold_disc/G_to_X/H_to_Y. This is correct and minimal, but:
- It keeps the mixed semantics (reflexive G/H, strict U/S) which is non-standard
- It means F(phi) <-> top U phi is NOT a theorem (only the implication top U phi -> F(phi) holds; the reverse needs the present-time case)
- Future completeness work will keep hitting the mixed-semantics issue

### 2.4 The Recommended Hybrid

**Phase 1: Option E' (immediate, ~200 LOC)**

Remove:
- `F_until_equiv` axiom constructor
- `P_since_equiv` axiom constructor

Add:
- `F_unfold_disc`: `F(psi) -> psi \/ (top U psi)` -- sound because F(psi) means exists s >= t with psi(s); if s=t then psi holds now, if s>t then top U psi holds
- `P_unfold_disc`: `P(psi) -> psi \/ (top S psi)` -- mirror
- `G_to_X`: `G(phi) -> bot U phi` -- sound because G(phi) means phi at all s > t, in particular at succ(t), which is X(phi) = bot U phi
- `H_to_Y`: `H(phi) -> bot S phi` -- mirror

This directly provides `G_implies_X` and `H_implies_Y` as axioms (via `G_to_X` and `H_to_Y`), breaking the circularity through F_until_equiv.

**Phase 2: Reflexive U/S semantics (optional, ~500 LOC)**

Change Truth.lean:
- `Formula.untl`: `t < s` to `t <= s` (witness only; guard stays `t < r` and `r < s`)
- `Formula.snce`: `s < t` to `s <= t` (witness only; guard stays `s < r` and `r < t`)

This makes F(phi) <-> top U phi a semantic theorem, and F_until_equiv becomes sound again (though no longer needed as an axiom if Phase 1 is done).

### 2.5 Mathematical Justification

**Why Phase 1 axioms are sound under current (mixed) semantics:**

1. **F_unfold_disc**: `F(psi) -> psi \/ (top U psi)`
   - F(psi) at t means exists s >= t with psi(s)
   - Case s = t: psi(t) holds, so left disjunct
   - Case s > t: exists s > t with psi(s) and top holds on (t,s), so top U psi at t
   - **Sound.** Confidence: HIGH

2. **P_unfold_disc**: `P(psi) -> psi \/ (top S psi)` -- symmetric. **Sound.** Confidence: HIGH

3. **G_to_X**: `G(phi) -> bot U phi`
   - G(phi) at t means phi at all s >= t (reflexive G)
   - On discrete frames: take s = succ(t). s > t. phi(s) holds. Guard (t, s) is empty.
   - So bot U phi holds at t.
   - **Sound on discrete frames.** Confidence: HIGH

4. **H_to_Y**: `H(phi) -> bot S phi` -- symmetric. **Sound on discrete frames.** Confidence: HIGH

Note: G_to_X/H_to_Y are discrete-only axioms (they need an immediate successor/predecessor). They belong in the discrete extension category alongside disc_next, disc_prev, etc. This is consistent with the existing architecture.

---

## 3. Axiom-by-Axiom Soundness Analysis (All Proposed Axioms)

### 3.1 Retained Axioms (All Sound Under Current Semantics)

| Axiom | Formula | Sound? | Guard Interval |
|-------|---------|--------|----------------|
| prop_k | `(phi -> (psi -> chi)) -> ((phi -> psi) -> (phi -> chi))` | Yes | N/A |
| prop_s | `phi -> (psi -> phi)` | Yes | N/A |
| ex_falso | `bot -> phi` | Yes | N/A |
| peirce | `((phi -> psi) -> phi) -> phi` | Yes | N/A |
| modal_t | `Box(phi) -> phi` | Yes | Reflexive access |
| modal_4 | `Box(phi) -> Box(Box(phi))` | Yes | Transitive access |
| modal_b | `phi -> Box(Diamond(phi))` | Yes | Symmetric access |
| modal_5_collapse | `Diamond(Box(phi)) -> Box(phi)` | Yes | Euclidean access |
| modal_k_dist | `Box(phi -> psi) -> Box(phi) -> Box(psi)` | Yes | K axiom |
| temp_k_dist | `G(phi -> psi) -> (G(phi) -> G(psi))` | Yes | forall s >= t |
| temp_4 | `G(phi) -> G(G(phi))` | Yes | s >= t, u >= s gives u >= t |
| temp_t_future | `G(phi) -> phi` | Yes | t >= t (reflexive) |
| temp_t_past | `H(phi) -> phi` | Yes | t <= t (reflexive) |
| temp_a | `phi -> G(P(phi))` | Yes | Standard connectedness |
| temp_a_dual | `phi -> H(F(phi))` | Yes | Mirror |
| temp_l | `always(phi) -> G(H(phi))` | Yes | Standard |
| modal_future | `Box(phi) -> Box(G(phi))` | Yes | Standard interaction |
| temp_future | `Box(phi) -> G(Box(phi))` | Yes | Standard interaction |
| temp_linearity | F-based linearity | Yes | Standard |
| density | `G(G(phi)) -> G(phi)` | Yes | Trivial under reflexive G (= BX1 applied) |
| discreteness_forward | DF axiom | Yes | Discrete frame property |
| seriality_future | `G(phi) -> F(phi)` | Yes | Reflexive G gives phi(t), which witnesses F |
| seriality_past | `H(phi) -> P(phi)` | Yes | Mirror |
| disc_next | `F(top) -> X(top)` | Yes | Discrete successor |
| disc_prev | `P(top) -> Y(top)` | Yes | Discrete predecessor |
| until_unfold | `phi U psi -> psi \/ (phi /\ X(phi U psi))` | Yes | Strict U, discrete |
| until_intro | `psi \/ (phi /\ X(phi U psi)) -> phi U psi` | Yes | Mirror |
| until_induction | Induction schema for Until | Yes | Standard |
| until_linearity | Linearity for Until | Yes | Standard |
| since_unfold/intro/induction/linearity | Mirrors | Yes | Standard |
| until_connectedness | `phi /\ (chi U psi) -> chi U (psi /\ (chi S phi))` | Yes | Standard |
| since_connectedness | Mirror | Yes | Standard |
| next_implies_some_future | `X(phi) -> F(phi)` | Yes | s > t implies s >= t |
| x_k_dist, x_det, y_k_dist, y_det | X/Y distribution and determinism | Yes | Discrete |
| yx_identity, xy_identity | Y(X(phi)) -> phi, X(Y(phi)) -> phi | Yes | Discrete |

### 3.2 New Axioms (All Sound)

| New Axiom | Formula | Sound? | Proof Sketch |
|-----------|---------|--------|-------------|
| F_unfold_disc | `F(psi) -> psi \/ (top U psi)` | **Yes** | Case split on witness: s=t gives psi; s>t gives top U psi |
| P_unfold_disc | `P(psi) -> psi \/ (top S psi)` | **Yes** | Mirror |
| G_to_X | `G(phi) -> bot U phi` | **Yes (discrete)** | G(phi) -> phi(succ(t)) -> X(phi) |
| H_to_Y | `H(phi) -> bot S phi` | **Yes (discrete)** | Mirror |

### 3.3 Soundness Under Reflexive U/S (Phase 2)

If U/S semantics are changed to reflexive (witness `t <= s` instead of `t < s`, guard stays open `(t,s)`):

- **F_until_equiv becomes sound**: F(psi) at t = exists s >= t, psi(s). Top U psi at t = exists s >= t, psi(s) and top on (t,s). These are identical.
- **All existing Until/Since axioms remain sound**: The guard interval is the same open interval (t,s) in both strict and reflexive versions. The only difference is whether s=t is allowed as witness. The until_unfold, until_intro, until_induction axioms use X(phi) = bot U phi, which under reflexive semantics means "bot on (t,s) and phi at s with s >= t". When s = t, the guard is empty and bot is vacuously true, so bot U phi at t iff phi(t). This means **X(phi) collapses to phi under reflexive semantics**.
- **X-collapse consequence**: This is exactly the catastrophe identified in report 31. Under reflexive U/S, X(phi) = bot U phi = phi (at the current time). All X-based axioms become trivial. The disc_next, x_k_dist, x_det, yx_identity, xy_identity axioms become either trivially true or vacuous.

**This means Phase 2 CANNOT be done without also removing X/Y-based axioms.** The X-collapse makes the discrete axiom layer meaningless. Phase 2 would effectively require moving to a Burgess-Xu style system without Next/Previous.

**Revised recommendation**: Phase 2 (reflexive U/S) should only be undertaken as part of a full BX transition, not independently.

**Confidence: HIGH**

---

## 4. Theorem Survival Analysis

### 4.1 Theorems That SURVIVE Phase 1 Unchanged

| File | Theorem | Status | Reason |
|------|---------|--------|--------|
| Propositional.lean | All | Survive | No temporal dependency |
| Combinators.lean | All | Survive | No temporal dependency |
| ModalS5.lean | All | Survive | No temporal dependency |
| ModalS4.lean | All | Survive | No temporal dependency |
| Perpetuity.lean | All | Survive | Uses only G/H axioms |
| GeneralizedNecessitation.lean | All | Survive | Uses only inference rules |
| Discreteness.lean | discreteness_past | Survives | Uses only discreteness_forward |

### 4.2 Theorems That NEED NEW PROOFS After Phase 1

| File | Theorem | Current Dependency | New Proof Strategy |
|------|---------|-------------------|-------------------|
| TemporalDerived.lean | `G_implies_topUntil` | F_until_equiv | **Replace with**: G(a) -> a (temp_t) gives a; separately G(a) -> top U a via F_unfold_disc + seriality: G(a)->F(a)->a\/(top U a), and G(a)->a, so top U a by disjunction analysis. OR simply use `G_to_X` directly and bypass this lemma. |
| TemporalDerived.lean | `G_implies_X` | G_implies_topUntil + until_induction | **Replace with**: Direct axiom application of `G_to_X`. Becomes trivial. |
| TemporalDerived.lean | `H_implies_Y` | P_since_equiv + since_induction | **Replace with**: Direct axiom application of `H_to_Y`. Becomes trivial. |
| DeterministicChain.lean | `g_content_propagates_to_x_content` | G_implies_X | Survives -- uses G_implies_X which gets new (simpler) proof |
| DeterministicChain.lean | `h_content_propagates_to_y_content` | H_implies_Y | Survives -- mirror |
| FiniteDeferral.lean | `F_to_until_in_mcs` | F_until_equiv directly | **Replace with**: Use `F_unfold_disc` to get psi \/ (top U psi). Need case analysis. If psi holds, then top U psi also holds (take witness s=t... but that needs reflexive Until). Under strict Until, need to use seriality + discrete structure to get a strictly future witness. This is more complex -- may need `disc_next` or similar. |
| FiniteDeferral.lean | `F_to_until_in_chain` | F_to_until_in_mcs | Depends on above |
| DovetailedChain.lean | F_to_until uses | F_until_equiv directly | Same as FiniteDeferral |

### 4.3 Theorems That May BECOME FALSE

No currently-provable theorem becomes false, because:
1. The replacement axioms (F_unfold_disc, P_unfold_disc, G_to_X, H_to_Y) are strictly weaker than (or equivalent to) what F_until_equiv + seriality_future provided
2. G_implies_X was always semantically valid on discrete frames; only its proof route through F_until_equiv was unsound
3. The only thing lost is the direct F(psi) -> top U psi implication (replaced by F(psi) -> psi \/ top U psi), which is weaker but still sufficient for the key use cases

**However**: `F_to_until_in_mcs` (FiniteDeferral.lean:44) directly converts F(psi) to top U psi. With only F_unfold_disc, we get F(psi) -> psi \/ (top U psi). The case where psi holds NOW but top U psi does not (under strict U) creates a gap. This means the finite deferral infrastructure needs adjustment:

- When F(psi) and psi both hold at time t, the F-obligation is already satisfied at the current time. No Until tracking needed.
- When F(psi) and ~psi hold at time t, then F_unfold_disc gives top U psi.
- The finite deferral argument should case-split on whether psi is already in chain(t).

**Confidence: HIGH**

### 4.4 Critical Path: G_implies_X Reconstruction

The most important theorem to reconstruct is `G_implies_X`. With the new `G_to_X` axiom, this becomes:

```lean
def G_implies_X (a : Formula) : ⊢ a.all_future.imp (X a) :=
  DerivationTree.axiom [] _ (Axiom.G_to_X a)
```

This is a one-line replacement. All downstream consumers (g_content_propagates_to_x_content, forward_G_int, forward_G, etc.) continue to work unchanged because they only depend on the TYPE of G_implies_X, not its proof.

Similarly for H_implies_Y:

```lean
noncomputable def H_implies_Y (a : Formula) : ⊢ a.all_past.imp (Y a) :=
  DerivationTree.axiom [] _ (Axiom.H_to_Y a)
```

**Confidence: HIGH**

---

## 5. Proof System Changes: Exact Specifications

### 5.1 Changes to Axioms.lean

**Remove** (2 constructors):
```lean
-- DELETE: F_until_equiv (line 608)
-- DELETE: P_since_equiv (line 617)
```

**Add** (4 constructors, in the discrete extension section):
```lean
/-- F-unfold (discrete): F(psi) -> psi \/ (top U psi).
Case split: F(psi) at t witnesses some s >= t with psi(s).
If s = t: psi holds now (left disjunct).
If s > t: top U psi holds (right disjunct). -/
| F_unfold_disc (ψ : Formula) :
    Axiom (Formula.some_future ψ |>.imp
      (Formula.or ψ (Formula.untl (Formula.neg Formula.bot) ψ)))

/-- P-unfold (discrete): P(psi) -> psi \/ (top S psi). Mirror. -/
| P_unfold_disc (ψ : Formula) :
    Axiom (Formula.some_past ψ |>.imp
      (Formula.or ψ (Formula.snce (Formula.neg Formula.bot) ψ)))

/-- G-to-X (discrete): G(phi) -> X(phi) = bot U phi.
On discrete frames, G(phi) at t gives phi(succ(t)), and the
guard interval (t, succ(t)) is empty, so bot U phi holds. -/
| G_to_X (φ : Formula) :
    Axiom (φ.all_future.imp (Formula.untl Formula.bot φ))

/-- H-to-Y (discrete): H(phi) -> Y(phi) = bot S phi. Mirror. -/
| H_to_Y (φ : Formula) :
    Axiom (φ.all_past.imp (Formula.snce Formula.bot φ))
```

**Update** classification functions (isBase, isDenseCompatible, isDiscreteCompatible):
- Remove F_until_equiv/P_since_equiv cases
- Add F_unfold_disc/P_unfold_disc/G_to_X/H_to_Y as Discrete

**Update** frame class assignment:
- Remove: `| Axiom.F_until_equiv _ => .Discrete` and `| Axiom.P_since_equiv _ => .Discrete`
- Add: `| Axiom.F_unfold_disc _ => .Discrete`, `| Axiom.P_unfold_disc _ => .Discrete`, `| Axiom.G_to_X _ => .Discrete`, `| Axiom.H_to_Y _ => .Discrete`

### 5.2 Changes to Soundness.lean

**Remove**: `F_until_equiv_valid` (line 757) and `P_since_equiv_valid` (line 775) -- both have sorry

**Add** (all sorry-free):
```lean
theorem F_unfold_disc_valid (ψ : Formula) :
    valid_discrete (Formula.some_future ψ |>.imp
      (Formula.or ψ (Formula.untl (Formula.neg Formula.bot) ψ))) := by
  -- Case split on witness s: if s = t then left disjunct; if s > t then right
  ...

theorem P_unfold_disc_valid (ψ : Formula) :
    valid_discrete (Formula.some_past ψ |>.imp
      (Formula.or ψ (Formula.snce (Formula.neg Formula.bot) ψ))) := by
  -- Mirror
  ...

theorem G_to_X_valid (φ : Formula) :
    valid_discrete (φ.all_future.imp (Formula.untl Formula.bot φ)) := by
  -- Take witness s = succ(t), guard (t, succ(t)) empty on discrete frames
  ...

theorem H_to_Y_valid (φ : Formula) :
    valid_discrete (φ.all_past.imp (Formula.snce Formula.bot φ)) := by
  -- Mirror
  ...
```

**Update** all match statements that handle F_until_equiv/P_since_equiv to handle the new axioms instead.

### 5.3 Changes to Substitution.lean

Replace the F_until_equiv/P_since_equiv cases (lines 363-368) with:
```lean
| F_unfold_disc a => exact Axiom.F_unfold_disc (a.subst q r)
| P_unfold_disc a => exact Axiom.P_unfold_disc (a.subst q r)
| G_to_X a => exact Axiom.G_to_X (a.subst q r)
| H_to_Y a => exact Axiom.H_to_Y (a.subst q r)
```

### 5.4 Changes to TemporalDerived.lean

Replace the complex G_implies_X proof (110 lines) with:
```lean
def G_implies_X (a : Formula) : ⊢ a.all_future.imp (X a) :=
  DerivationTree.axiom [] _ (Axiom.G_to_X a)
```

Replace H_implies_Y similarly:
```lean
noncomputable def H_implies_Y (a : Formula) : ⊢ a.all_past.imp (Y a) :=
  DerivationTree.axiom [] _ (Axiom.H_to_Y a)
```

`G_implies_topUntil` is no longer needed (or can be derived differently if desired).

`G_bot_absurd` and `H_bot_absurd` remain valid -- they use seriality_future/past which are sound.

`X_bot_absurd` and `Y_bot_absurd` remain valid -- they use next_implies_some_future which is sound.

`until_implies_some_future` and `since_implies_some_past` remain valid -- they use until_induction/since_induction which are sound.

### 5.5 Changes to FiniteDeferral.lean

Replace `F_to_until_in_mcs` with a version that handles the case split:
```lean
theorem F_to_until_or_now (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h_F : Formula.some_future ψ ∈ M) :
    ψ ∈ M ∨ Formula.untl (Formula.neg Formula.bot) ψ ∈ M := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.F_unfold_disc ψ)
  have h_disj := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_ax) h_F
  exact mcs_or_cases h_mcs h_disj
```

The finite deferral argument then needs a case split: if psi already holds, the F-obligation is resolved; if not, proceed with Until tracking as before.

### 5.6 Changes to DovetailedChain.lean

Same pattern as FiniteDeferral.lean -- replace direct F_until_equiv uses with F_unfold_disc + case analysis.

### 5.7 Changes to SoundnessLemmas.lean

Replace the F_until_equiv/P_since_equiv absurdity cases with the new axiom cases.

### 5.8 Files Requiring Match Exhaustiveness Updates

Any file with a match on `Axiom` constructors will need updating:
- `Axioms.lean` (classification functions)
- `Soundness.lean` (validity proofs)
- `SoundnessLemmas.lean` (frame-specific validity)
- `Substitution.lean` (substitution lemma)
- `FrameConditions/Compatibility.lean` (compatibility instances)

### 5.9 Files NOT Requiring Changes

- `Derivation.lean` -- no match on axiom constructors
- `Propositional.lean`, `Combinators.lean`, `ModalS5.lean`, `ModalS4.lean` -- no temporal
- `Perpetuity.lean`, `GeneralizedNecessitation.lean` -- no U/S
- `Discreteness.lean` -- uses only discreteness_forward
- `DeterministicChain.lean` -- depends on G_implies_X which keeps its type signature
- `DeterministicFMCS.lean` -- depends on chain infrastructure, no direct axiom use

---

## 6. Confidence Levels

| Section | Confidence | Rationale |
|---------|-----------|-----------|
| Unsoundness audit (Section 1) | **HIGH** | Confirmed by sorry locations in Soundness.lean, semantic analysis |
| Dependency chain (Section 1.2) | **HIGH** | Traced through grep of all source files |
| Phase 1 axiom soundness (Section 3) | **HIGH** | Standard semantic arguments, well-established |
| X-collapse under reflexive U/S (Section 3.3) | **HIGH** | Confirmed by all 4 teammates in report 31 |
| Theorem survival (Section 4) | **HIGH** | Type-level analysis -- downstream theorems depend on signatures not proofs |
| G_implies_X reconstruction (Section 4.4) | **HIGH** | Trivial one-line proof from new axiom |
| FiniteDeferral adjustment (Section 5.5) | **MEDIUM** | Case split is straightforward but needs careful MCS reasoning |
| Effort estimate (~200 LOC for Phase 1) | **MEDIUM** | Match exhaustiveness updates add boilerplate |

---

## 7. Summary of Recommended Actions

1. **Add 4 axiom constructors** to Axioms.lean: F_unfold_disc, P_unfold_disc, G_to_X, H_to_Y
2. **Remove 2 axiom constructors**: F_until_equiv, P_since_equiv
3. **Add 4 soundness proofs** (sorry-free) to Soundness.lean
4. **Remove 2 sorry-laden soundness proofs**: F_until_equiv_valid, P_since_equiv_valid
5. **Simplify** G_implies_X and H_implies_Y in TemporalDerived.lean to one-line axiom applications
6. **Update** FiniteDeferral.lean and DovetailedChain.lean to use F_unfold_disc with case split
7. **Update** all match statements across ~5 files for exhaustiveness
8. **Do NOT change semantics** in Truth.lean (Phase 2 deferred -- requires full BX transition)

**Net effect**: 2 sorry proofs eliminated, 0 new sorries introduced. Sound axiom system. All existing sorry-free theorems remain sorry-free with potentially simpler proofs.
