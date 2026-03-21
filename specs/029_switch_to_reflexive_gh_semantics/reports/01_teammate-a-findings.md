# Teammate A Findings: Axiom System Analysis Under Reflexive Semantics

**Task**: 29 - Switch to Reflexive G/H Semantics
**Focus**: Axiom-by-axiom analysis of what changes when G/H switch from strict (t < s) to reflexive (t ≤ s)

---

## Background

**Current system (strict semantics)**:
- `Gφ` at t: `∀ s, t < s → φ(s)` (strictly future times only)
- `Hφ` at t: `∀ s, s < t → φ(s)` (strictly past times only)
- Truth definition in `Theories/Bimodal/Semantics/Truth.lean`, lines 121-122

**Proposed system (reflexive semantics)**:
- `Gφ` at t: `∀ s, t ≤ s → φ(s)` (now and all future times)
- `Hφ` at t: `∀ s, s ≤ t → φ(s)` (now and all past times)

The task note in `CanonicalIrreflexivityAxiom.lean` confirms the system already **anticipates** reflexive semantics: it describes the T-axiom as valid and used in the canonical irreflexivity proof. The historical note there says reflexive semantics was adopted in Task 967 specifically to make the T-axiom valid for the canonical model proof. However, the `Truth.lean` file still shows strict `<` operators, with a note "as of Task 991" reverting back to strict. This report analyzes what switching back to reflexive would entail.

---

## Key Findings: Axiom-by-Axiom Analysis

### 1. Propositional Axioms (unchanged)

- **prop_k**: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` — purely propositional, unaffected. **Unchanged.**
- **prop_s**: `φ → (ψ → φ)` — purely propositional. **Unchanged.**
- **ex_falso**: `⊥ → φ` — purely propositional. **Unchanged.**
- **peirce**: `((φ → ψ) → φ) → φ` — purely propositional. **Unchanged.**

### 2. S5 Modal Axioms (unchanged)

- **modal_t**: `□φ → φ` — reflexive accessibility for □, independent of temporal semantics. **Unchanged.**
- **modal_4**: `□φ → □□φ` — transitivity of □. **Unchanged.**
- **modal_b**: `φ → □◇φ` — symmetry of □. **Unchanged.**
- **modal_5_collapse**: `◇□φ → □φ` — S5 collapse. **Unchanged.**
- **modal_k_dist**: `□(φ → ψ) → (□φ → □ψ)` — distribution. **Unchanged.**

### 3. Temporal K Distribution (unchanged)

- **temp_k_dist**: `G(φ → ψ) → (Gφ → Gψ)` — under reflexive semantics, if (φ → ψ) holds at all s ≥ t and φ holds at all s ≥ t, then ψ holds at all s ≥ t. The distribution argument is identical. **Unchanged (still valid).**

### 4. Temporal 4 — Gφ → GGφ (CHANGES MEANING, REMAINS VALID)

**Current proof (strict)**: `h_future s hts r hsr`: given s > t and r > s, r > t by transitivity of <. So Gφ at t means ∀ r > t, φ(r), and we pick any r > s to show φ(r).

**Under reflexive semantics**: GGφ at t means `∀ s ≥ t, ∀ r ≥ s, φ(r)`. Gφ at t means `∀ s ≥ t, φ(s)`.

Proof: Assume Gφ at t. Take any s ≥ t and r ≥ s. Then r ≥ t (by transitivity of ≤), so φ(r) by Gφ. Hence GGφ.

**Status**: **Unchanged (still valid).** The proof argument is essentially identical.

### 5. Temporal A — φ → G(Pφ) (CHANGES MEANING, REMAINS VALID)

**Current (strict)**: If φ at t, then for all s > t, there exists r < s with φ(r) (namely t, since t < s).

**Under reflexive**: If φ at t, then for all s ≥ t, there exists r ≤ s with φ(r) (namely t, since t ≤ s).

The witness t still works. **Unchanged (still valid).**

### 6. Temporal L — △φ → G(Hφ) (CHANGES MEANING, SIMPLIFIES)

**Current (strict)**: △φ = Hφ ∧ φ ∧ Gφ encodes φ at all times past, present, future. The proof requires trichotomy on r vs t.

**Under reflexive**: △φ would still hold at all times. G(Hφ) at t means: for all s ≥ t, for all r ≤ s, φ(r). With △φ (φ at all times), this follows trivially since φ holds everywhere.

**Status**: **Unchanged (still valid, proof even simpler).**

### 7. NEW AXIOM: Temporal T Future — Gφ → φ (BECOMES VALID)

**Current (strict)**: INVALID. Gφ at t means ∀ s > t, φ(s). This says nothing about t itself.

**Under reflexive**: Gφ at t means ∀ s ≥ t, φ(s). Setting s = t: φ(t). VALID.

**This is the key new axiom that becomes valid under reflexive semantics.**

The file `CanonicalIrreflexivityAxiom.lean` explicitly mentions this axiom and its importance: it's used in Step 7 of the canonical irreflexivity proof.

### 8. NEW AXIOM: Temporal T Past — Hφ → φ (BECOMES VALID)

**Current (strict)**: INVALID. Hφ at t means ∀ s < t, φ(s). Says nothing about t.

**Under reflexive**: Hφ at t means ∀ s ≤ t, φ(s). Setting s = t: φ(t). VALID.

**Status**: **NEW valid axiom under reflexive semantics.**

### 9. Modal-Future Interaction — □φ → □(Gφ) (CHANGES MEANING, REMAINS VALID)

**Current**: □φ → □(Gφ) where Gφ = future holds at s > t.

**Under reflexive**: □φ → □(Gφ) where Gφ at s means φ at all r ≥ s. The time-shift invariance proof in `Soundness.lean` (lines 232-237) uses `WorldHistory.time_shift` to relate truth at different times, and this argument is independent of whether temporal quantification is strict or reflexive.

**Status**: **Unchanged (still valid).**

### 10. Temporal-Future — □φ → G(□φ) (CHANGES MEANING, REMAINS VALID)

**Under reflexive**: □φ → G(□φ) where G is reflexive. If □φ at t, need □φ at all s ≥ t. The time-shift proof is unchanged.

**Status**: **Unchanged (still valid).**

### 11. Temporal Linearity — F(φ) ∧ F(ψ) → ... (CHANGES MEANING)

**Current (strict)**: F = some_future = ∃ s > t, φ(s).

**Under reflexive**: F would use ∃ s ≥ t, φ(s), meaning t itself is a witness.

The linearity proof uses trichotomy on witnesses s1, s2 (lines 274). This argument still holds with ≤ instead of <, since linearity of the order holds regardless.

However, the formula statement uses `some_future` which is derived as `¬G¬φ`. Under reflexive semantics, `some_future φ` at t would mean `∃ s ≥ t, φ(s)`, which includes t itself.

**Status**: **Unchanged (still valid), but meaning shifts.**

---

## Density Extension (DN Axiom)

### DN: GGφ → Gφ

**Current (strict)**: GGφ at t means ∀ r > t, ∀ s > r, φ(s). To prove Gφ at t (∀ s > t, φ(s)): given s > t, by density get r with t < r < s, then GGφ gives Gφ at r, so φ(s) since s > r.

**Under reflexive**: GGφ at t means ∀ r ≥ t, ∀ s ≥ r, φ(s). Setting r = t and s = t: GGφ at t gives φ(t) directly (from r=t, s=t). For any s ≥ t: take r = t, then ∀ q ≥ t, φ(q), so φ(s).

**Critical finding**: Under reflexive semantics, GGφ → Gφ becomes **trivially valid on ANY linear order** (not just dense ones). Here's why:

Proof: Assume GGφ at t. Take any s ≥ t. Set r = t. Since r = t ≥ t, we have ∀ q ≥ r, φ(q) by GGφ. Since s ≥ t = r, we get φ(s).

The density frame condition is **no longer needed** for DN under reflexive semantics. DN becomes a base axiom.

**Furthermore**: Under reflexive semantics, GGφ ↔ Gφ (they are equivalent!):
- GGφ → Gφ: trivially as above (set r = t)
- Gφ → GGφ: this is exactly `temp_4` (Temporal 4 axiom)

**So DN becomes derivable from T4 (which holds universally) under reflexive semantics.**

---

## Discrete Extension Axioms

### DF: (F⊤ ∧ φ ∧ Hφ) → F(Hφ)

**Current (strict)**: F⊤ means ∃ s > t (there is a strictly future time). φ ∧ Hφ means φ now and at all strictly past times. Goal: ∃ s > t such that ∀ r < s, φ(r).

The proof (lines 319-343 in Soundness.lean) uses `Order.succ t` as the witness. For r < succ(t), either r < t (covered by Hφ) or r = t (covered by φ).

**Under reflexive semantics**:
- F⊤ becomes ∃ s ≥ t (which is trivially witnessed by t itself — so F⊤ is always valid!)
- Hφ means ∀ r ≤ t, φ(r) (includes t)
- F(Hφ) means ∃ s ≥ t such that ∀ r ≤ s, φ(r)

The premise F⊤ is now trivially satisfied. The real content of DF is: if φ ∧ Hφ (i.e., φ holds at t and all past times), then there exists a future time s ≥ t such that Hφ(s) (φ holds at all r ≤ s).

Under reflexive, take s = t: then Hφ(t) = ∀ r ≤ t, φ(r), which is exactly the premise φ ∧ Hφ under reflexive semantics (since Hφ includes t now).

**Critical finding**: Under reflexive semantics, DF becomes trivially valid:
- F⊤ is trivially true (s = t is a witness)
- If φ ∧ Hφ holds (at t), then Hφ_reflexive holds at t (since it includes t)
- So take s = t as the witness for F(Hφ)
- DF becomes a base axiom (valid on all linear orders), requiring no SuccOrder

**The SuccOrder (immediate successor) frame condition for DF is no longer needed.**

### SF (Seriality Future): Gφ → Fφ

**Current (strict)**: Gφ = ∀ s > t, φ(s). Fφ = ∃ s > t, φ(s). This requires NoMaxOrder (existence of a strictly future time) to go from universal to existential.

**Under reflexive**: Gφ = ∀ s ≥ t, φ(s). Fφ = ∃ s ≥ t, φ(s).

The witness s = t immediately satisfies Fφ! SF becomes trivially valid with just the reflexive T-axiom (Gφ → φ), which gives φ(t), making t a witness for Fφ.

**Critical finding**: SF becomes a **tautology** under reflexive semantics, derivable from the T-axiom. It no longer requires NoMaxOrder.

### SP (Seriality Past): Hφ → Pφ

**Same analysis as SF**: Under reflexive semantics, Pφ = ∃ s ≤ t, φ(s), and s = t is a witness. SP is trivially valid, requiring no NoMinOrder.

---

## Axioms That Change Status

### Invalid → Valid (Newly Valid Under Reflexive)

| Axiom | Formula | Reason |
|-------|---------|--------|
| **Temporal T Future** | `Gφ → φ` | Reflexive G includes now (s = t) |
| **Temporal T Past** | `Hφ → φ` | Reflexive H includes now (s = t) |

### Valid Only on Special Frames → Universally Valid (Base Axioms)

| Axiom | Old Frame Class | New Frame Class | Reason |
|-------|-----------------|-----------------|--------|
| **DN (Density)** | Dense (DenselyOrdered) | **Base** | GGφ → Gφ trivially by taking r = t |
| **DF (Discreteness Forward)** | Discrete (SuccOrder) | **Base** | F(Hφ) witnessed by s = t |
| **SF (Seriality Future)** | Discrete (NoMaxOrder) | **Base** | T-axiom gives t as witness |
| **SP (Seriality Past)** | Discrete (NoMinOrder) | **Base** | T-axiom gives t as witness |

### Still Valid, Unchanged

All 16 base axioms of the current system remain valid under reflexive semantics:
- prop_k, prop_s, ex_falso, peirce (purely propositional)
- modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist (purely modal)
- temp_k_dist, temp_4, temp_a, temp_l (temporal base)
- modal_future, temp_future (interaction)
- temp_linearity (linearity)

### May Become Invalid

The temporal linearity axiom uses `some_future` which under reflexive semantics includes t itself as a witness. This changes the interpretation but the axiom should remain valid (the linearity argument holds regardless).

---

## Impact on Frame Conditions

### Dense Extension Collapse

Under reflexive semantics, the density frame class **collapses into base**:
- DN (GGφ → Gφ) becomes universally valid
- DenselyOrdered is no longer needed for DN
- The "Dense" variant of TM logic is indistinguishable from Base

**Consequence**: The `density_valid` proof would no longer need `DenselyOrdered.dense` (the intermediate point r). A simpler proof uses r = t directly.

### Discrete Extension Collapse

Under reflexive semantics, the discrete frame class also **collapses into base**:
- DF becomes trivially valid (take s = t as witness)
- SF, SP become trivially valid (T-axiom gives t as witness)
- SuccOrder, PredOrder, NoMaxOrder, NoMinOrder are no longer needed

**Consequence**: The `discreteness_forward_valid` proof would simplify dramatically — no need for `Order.succ t`, no case split on r < t vs r = t.

### New Frame Architecture

Under reflexive semantics:
- All axioms (including DN, DF, SF, SP) become base axioms
- There would be only one "frame class" (Base)
- The FrameClass enum becomes degenerate
- Extensions for dense/discrete no longer add expressive power

This is a major architectural change: the three-variant structure (Base, Dense, Discrete) would collapse to a single logic.

---

## Canonical Model Impact

The most important impact is on the canonical model construction. The current system uses:

1. **Strict semantics** to make G/H irreflexive definitionally (no proof needed)
2. **IRR rule** (Gabbay's Irreflexivity Rule) for completeness
3. The T-axiom is NOT in the proof system (correctly, since it's not valid under strict)

Under reflexive semantics:
1. **T-axiom becomes valid** and should be added to the proof system
2. **Canonical irreflexivity proof** changes: as documented in `CanonicalIrreflexivityAxiom.lean`, the proof USES the T-axiom — this is the key that makes canonical irreflexivity provable without atom freshness
3. The canonical order relation CanonicalR would need to use ≤ instead of <

The file `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` already documents the reflexive approach as the intended design (Task 967) before it was overridden by Task 991 which switched back to strict.

---

## Additional New Valid Axioms

Beyond Gφ → φ and Hφ → φ, these become valid:

1. **G reflexivity for F**: `Fφ → φ` where F is the existential future `¬G¬φ`. Under reflexive, F at t includes t as a witness, but this is just the T-axiom for F.

2. **Idempotency of G**: `Gφ ↔ GGφ` (from T4 + DN which both become base axioms).

3. **G self-reflection**: `Gφ → G(Gφ)` (same as T4, unchanged).

4. **H strengthening**: Under reflexive, `Hφ` is strictly stronger than under strict semantics (it additionally asserts φ at t).

5. **Convergence**: `Gφ ∧ Hφ → φ` (trivially from T-axiom for both G and H).

---

## Confidence Level

**High confidence** on:
- T-axiom validity under reflexive (definitional)
- DN triviality under reflexive (simple proof sketch above)
- SF/SP triviality under reflexive (T-axiom witness)
- DF triviality under reflexive (t as witness for F)
- All base axioms remain valid (arguments unchanged)

**Medium confidence** on:
- The precise impact on the completeness proof strategy
- Whether temp_linearity axiom needs re-examination with reflexive F
- The impact on the IRR rule and temporal duality

**Low confidence** on:
- Whether any axiom becomes INVALID under reflexive (I found none, but may have missed edge cases)
- The interaction between reflexive G/H and the modal axioms MF, TF under the new semantics

---

## Summary Table

| Axiom | Under Strict | Under Reflexive | Change |
|-------|-------------|-----------------|--------|
| prop_k, prop_s, ex_falso, peirce | Base valid | Base valid | None |
| modal_t, modal_4, modal_b | Base valid | Base valid | None |
| modal_5_collapse, modal_k_dist | Base valid | Base valid | None |
| temp_k_dist, temp_4, temp_a, temp_l | Base valid | Base valid | None |
| modal_future, temp_future | Base valid | Base valid | None |
| temp_linearity | Base valid | Base valid | None |
| **Gφ → φ (temp_t_future)** | **INVALID** | **BASE VALID** | **NEW** |
| **Hφ → φ (temp_t_past)** | **INVALID** | **BASE VALID** | **NEW** |
| density DN (GGφ → Gφ) | Dense valid only | **BASE VALID** | **Promoted** |
| discreteness_forward DF | Discrete valid only | **BASE VALID** | **Promoted** |
| seriality_future SF | Discrete valid only | **BASE VALID** | **Promoted** |
| seriality_past SP | Discrete valid only | **BASE VALID** | **Promoted** |

**Key architectural finding**: Switching to reflexive semantics collapses all three frame classes (Base, Dense, Discrete) into a single class, since DN, DF, SF, SP all become universally valid. The extension structure of TM logic would need to be rethought.
