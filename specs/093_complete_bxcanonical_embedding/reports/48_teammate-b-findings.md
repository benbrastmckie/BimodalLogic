# Teammate B Findings: Round 48 — Axiom System Redesign for Irreflexive Semantics

**Task**: 93 - Complete BXCanonical Embedding
**Date**: 2026-04-19
**Focus**: Exact axiom system under strict/irreflexive temporal semantics

---

## Key Findings

### Finding 1: BX1 (Temporal T) Must Be Removed

Current BX1: `G(φ) → φ` (`temp_t_future`) is **unsound** under irreflexive G
(G quantifies over strictly future times s > t). The axiom claims "what holds
at all strictly future times holds now" — false in general, since the present
is excluded.

Consequence: `bx_le_refl` in Frame.lean falls immediately. The canonical
ordering `bx_le w v := g_content(w) ⊆ v.formulas` is no longer reflexive
under strict G. This is ~30 downstream theorems.

Replacement: The ordering becomes a strict preorder (transitive but NOT
reflexive). We need `g_content(w) ⊆ v.formulas` to hold for v strictly
greater than w, which aligns with a strict canonical ordering.

### Finding 2: Complete Axiom Comparison Table

| Axiom | Statement | Status Under Irreflexive | Notes |
|-------|-----------|--------------------------|-------|
| `prop_k` | `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` | **KEEP** | Propositional, unaffected |
| `prop_s` | `φ → (ψ → φ)` | **KEEP** | Propositional, unaffected |
| `ex_falso` | `⊥ → φ` | **KEEP** | Propositional, unaffected |
| `peirce` | `((φ → ψ) → φ) → φ` | **KEEP** | Propositional, unaffected |
| `modal_t` | `□φ → φ` | **KEEP** | S5 reflexivity for modal; unaffected by temporal |
| `modal_4` | `□φ → □□φ` | **KEEP** | S5 transitivity |
| `modal_b` | `φ → □◇φ` | **KEEP** | S5 symmetry |
| `modal_5_collapse` | `◇□φ → □φ` | **KEEP** | S5 characteristic |
| `modal_k_dist` | `□(φ → ψ) → (□φ → □ψ)` | **KEEP** | Modal K |
| `temp_k_dist` | `G(φ → ψ) → (Gφ → Gψ)` | **KEEP** | K holds under strict G |
| `temp_4` | `Gφ → G(Gφ)` | **KEEP** | Transitivity; valid under strict G on linear orders |
| `temp_t_future` (BX1) | `Gφ → φ` | **REMOVE** | UNSOUND under strict G |
| `temp_t_past` (BX1') | `Hφ → φ` | **REMOVE** | UNSOUND under strict H |
| `left_mono_until` (BX2) | `G(φ → χ) → ((φ U ψ) → (χ U ψ))` | **KEEP** | Valid under strict U |
| `left_mono_since` (BX2') | `H(φ → χ) → ((φ S ψ) → (χ S ψ))` | **KEEP** | Valid under strict S |
| `right_mono_until` (BX3) | `G(φ → ψ) → ((χ U φ) → (χ U ψ))` | **KEEP** | Valid under strict U |
| `right_mono_since` (BX3') | `H(φ → ψ) → ((χ S φ) → (χ S ψ))` | **KEEP** | Valid under strict S |
| `connect_future` (BX4) | `φ → G(P(φ))` | **REMOVE/VERIFY** | Needs checking under strict G/H |
| `connect_past` (BX4') | `φ → H(F(φ))` | **REMOVE/VERIFY** | Needs checking under strict G/H |
| `self_accum_until` (BX5) | `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)` | **KEEP** | Valid under strict U |
| `self_accum_since` (BX5') | `(φ S ψ) → ((φ ∧ (φ S ψ)) S ψ)` | **KEEP** | Valid under strict S |
| `absorb_until` (BX6) | `(φ U (φ ∧ (φ U ψ))) → (φ U ψ)` | **KEEP** | Valid under strict U |
| `absorb_since` (BX6') | `(φ S (φ ∧ (φ S ψ))) → (φ S ψ)` | **KEEP** | Valid under strict S |
| `linear_until` (BX7) | Linearity of Until | **KEEP** | Valid under strict U |
| `linear_since` (BX7') | Linearity of Since | **KEEP** | Valid under strict S |
| `refl_intro_until` (BX8) | `ψ → (φ U ψ)` | **REMOVE** | UNSOUND under strict U (see §Finding 3) |
| `refl_intro_since` (BX8') | `ψ → (φ S ψ)` | **REMOVE** | UNSOUND under strict S |
| `until_elim` (BX9) | `(φ U ψ) → (φ ∨ ψ)` | **MODIFY** | Character changes; see §Finding 4 |
| `since_elim` (BX9') | `(φ S ψ) → (φ ∨ ψ)` | **MODIFY** | Character changes |
| `until_F` (BX10) | `(φ U ψ) → F(ψ)` | **KEEP** | Still valid under strict U |
| `since_P` (BX10') | `(φ S ψ) → P(ψ)` | **KEEP** | Still valid under strict S |
| `temp_linearity` (BX11) | `F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ∧F(ψ)) ∨ F(F(φ)∧ψ)` | **KEEP** | Valid under strict F |
| `temp_linearity_past` (BX11') | Past dual of BX11 | **KEEP** | Valid under strict P |
| `F_until_equiv` (BX12) | `F(φ) → (⊤ U φ)` | **KEEP** | Valid under strict U (see §Finding 7) |
| `P_since_equiv` (BX12') | `P(φ) → (⊤ S φ)` | **KEEP** | Valid under strict S |
| `modal_future` | `□φ → □(Gφ)` | **KEEP** | Unaffected by temporal semantic change |
| `temp_future` | `□φ → G(□φ)` | **KEEP** | Unaffected |

**New axioms needed**: Seriality (see §Finding 6).

### Finding 3: BX8 (`ψ → φ U ψ`) Is UNSOUND Under Strict Until

Under strict Until (s > t), `φ U ψ` at t requires ∃ s > t with ψ(s) and
φ holds on (t, s). If ψ holds at t, we cannot choose s = t (strict), so
we need ∃ s > t with ψ(s) — which is not guaranteed. A model where ψ holds
only at t and not at any strictly later point falsifies `ψ → φ U ψ`.

**What replaces BX8?** Nothing direct. Under strict Until, there is no "reflexive
introduction" axiom. Instead, the standard characterization becomes:

- **Strict Until unfolding** (two-direction): `(φ U ψ) ↔ ψ ∨ (φ ∧ F(φ U ψ))`
  - Forward (LEFT to RIGHT): This is the REPLACEMENT for BX9 (see §Finding 4)
  - Backward (RIGHT to LEFT): `ψ ∨ (φ ∧ F(φ U ψ)) → (φ U ψ)` — this is provable

The backward direction of the unfolding (`ψ → φ U ψ` is gone, but
`ψ → φ U ψ` as a CONSEQUENCE of F-seriality + ψ → F(ψ)` is not standard).

**Conclusion**: BX8 has no direct replacement. The strict system does NOT have
`ψ → φ U ψ`. This is by design — strict Until is strictly stronger than the
proposition ψ.

### Finding 4: BX9 (`(φ U ψ) → φ ∨ ψ`) — Character Change Under Strict Until

Under reflexive Until, BX9 follows because the witness can be s = t (so ψ at t),
or s > t (so φ at t from the guard). Under strict Until:
- The witness s > t always exists (strictly future)
- If ψ ∉ w, then s > t means the guard (t, s) must hold φ at t
- But BX9 as stated `(φ U ψ) → φ ∨ ψ` is actually:

Under strict Until with `φ U ψ` at t:
- Witness s > t with ψ(s) and φ on (t, s)
- The open interval (t, s) is used for φ, but φ at t (i.e., the endpoint) is NOT required
- Wait: the standard definition is φ holds at all t' with t < t' < s, and ψ at s
- If s is the immediate successor of t (in discrete case), (t, s) is empty → φ holds vacuously
- So φ at t is NOT derived from `φ U ψ` at t

**BX9 is UNSOUND under strict Until**. The standard replacement is:

```
strict_until_elim: (φ U ψ) → F(ψ)
```
This is just BX10. No additional elim axiom is needed — BX10 already captures it.

The UNFOLDING axiom replaces BX9:
```
until_unfold: (φ U ψ) ↔ ψ ∨ (φ ∧ F(φ U ψ))
```

Or equivalently as two directed implications:
```
until_unfold_fwd: (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))
until_unfold_bwd: ψ ∨ (φ ∧ F(φ U ψ)) → (φ U ψ)
```

**Soundness of `until_unfold_fwd`**: Under strict Until at t, if ψ(t) then done (left
disjunct). If ψ ∉ t, then the witness s > t has φ on (t,s), so F(φ U ψ) holds at
t (the witness for F is s itself, where ψ holds, and φ on (t,s) is the guard for
the inner `φ U ψ` at... wait, inner `φ U ψ` needs a witness from t, but if s is
the same witness, that requires t' > t with ψ(t') and φ on (t,t') — which is just
`φ U ψ` at t itself). The correct formulation is:

`(φ U ψ) → ψ ∨ F(φ U ψ)` (not requiring φ in the second disjunct).

This is the STRICT unfolding: either ψ now, or there's a strictly future time where
`φ U ψ` holds (i.e., the entire eventuality "advances forward").

The guard condition `φ ∧ F(φ U ψ)` is for INDUCTIVE characterization — for the
truth lemma's backward direction — not for the forward direction.

**Summary**: BX9 (`(φ U ψ) → φ ∨ ψ`) is REMOVED. Replacement:
```
until_unfold_fwd: (φ U ψ) → ψ ∨ F(φ U ψ)
```
(no φ required in the second disjunct under strict Until).

### Finding 5: Strict Until Unfolding — Exact Form

The correct strict Until unfolding is:

**Forward**: `(φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))`

Wait — I need to be careful. Let me re-examine:

Under STRICT Until at t: ∃ s > t, ψ(s) ∧ ∀ t', t < t' < s → φ(t')

Case 1: s is the immediate next time after t (in discrete case, s = t+1; in dense
case, infimum exists). Then the interval (t, s) is empty (no t' with t < t' < s),
so φ holds vacuously. ψ holds at s = t+1. Does this give us φ at t? NO.

Case 2: s > t but there's some t' with t < t' < s. Then φ(t'). Still no φ at t.

So `(φ U ψ) → φ ∨ ψ` is indeed WRONG. The standard strict unfolding in the literature
(Burgess 1982, GHR 1994 for linear temporal logic) is:

```
(φ U ψ) ↔ ψ ∨ (φ ∧ F(φ U ψ))     -- Standard LTL unfolding
```

This holds because: `φ U ψ` at t iff ψ at t (base case: s = t in LTL REFLEXIVE
convention) or φ at t and at some strictly future t', `φ U ψ` at t'.

**Under STRICT Until**, the unfolding is different:

```
(φ U ψ) ↔ F(ψ) ∧ ... (complex)
```

The correct strict Until characterization from Burgess/GHR is:

```
(φ U ψ) ↔ ∃ s > t, [ψ(s) ∧ ∀ t', t < t' < s → φ(t')]
```

The AXIOM SYSTEM captures this through the combination:
1. `until_F` (BX10): `(φ U ψ) → F(ψ)` — the witness exists
2. `until_unfold_fwd`: `(φ U ψ) → ψ ∨ F(φ ∧ (φ U ψ))` — at t, either ψ now
   or at strictly next time φ holds AND the eventuality continues

Actually the **correct strict unfolding** (Burgess-Xu for irreflexive) is:

```
until_unfold_fwd: (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))
```

Soundness: Given witness s > t for `φ U ψ` at t:
- If ψ holds at t: left disjunct satisfied
- If ψ does not hold at t: since s > t and ψ(s) and φ on (t, s), we have:
  - φ at t? Not necessarily (t is an endpoint, not in the open interval (t, s))
  - UNLESS we use: the guard is φ at t' for t < t' < s, NOT necessarily at t itself

**This is the key issue**: Under strict Until with OPEN guard (t < t' < s), φ at t
is NOT part of the guard. So `(φ U ψ) → φ` is NOT valid.

The correct axiom depends on the precise GUARD CONVENTION:

**Convention A (Half-open, standard in GHR 1994)**: Guard is φ at t' for t ≤ t' < s.
This means φ at t IS part of the guard. Then `(φ U ψ) → φ ∨ ψ` holds (BX9 analogue
`(φ U ψ) → φ ∨ ψ` holds under this convention too! Just not with reflexive witness).

Looking at the current code comment for BX9: "Under reflexive Until semantics, `φ U ψ`
at t has witness s ≥ t with ψ(s). If s = t, then ψ(t) holds. If s > t, then φ(t)
holds (from guard [t,s))." The guard is [t, s) — LEFT-CLOSED, RIGHT-OPEN.

**Under STRICT Until (s > t) with guard [t, s)** (half-open, left-closed):
- Witness s > t with ψ(s) and φ at all t' with t ≤ t' < s
- φ at t ∈ [t, s) → φ at t is REQUIRED
- So `(φ U ψ) → φ ∨ ψ` still holds! (φ holds at t from the guard)

**Conclusion**: Whether BX9 survives depends on the GUARD CONVENTION:

| Convention | Guard for (φ U ψ) at t with witness s | BX8 valid? | BX9 valid? |
|------------|---------------------------------------|------------|------------|
| Reflexive, half-open guard [t, s) | t ≤ t' < s | YES (s=t works) | YES |
| Strict, half-open guard [t, s) | t < s; t ≤ t' < s | NO (s=t excluded) | YES |
| Strict, open guard (t, s) | t < s; t < t' < s | NO | NO |

The current code uses **reflexive witness (s ≥ t) with half-open left-closed guard
[t, s)**. Switching to **strict witness (s > t) with same guard [t, s)** is
Sub-option A2 from report 47 — which preserves BX9 but NOT BX8.

Switching to **strict witness with open guard (t, s)** is Sub-option A1 — loses both
BX8 and BX9. Report 47 (Finding 2) says Sub-option A1 makes step transfer provable,
while A2 preserves `(⊥ U α) ↔ α` and may make the chain trivial.

### Finding 6: Seriality Axioms Required

Under irreflexive semantics without BX1, the frame becomes non-serial by default.
We need:

**Future Seriality**: `¬G(⊥)`, equivalently `⊤ → F(⊤)`, i.e., there always exists
a strictly future time. This corresponds to `no_max_order` on the temporal domain.

**Past Seriality**: `¬H(⊥)`, equivalently `⊤ → P(⊤)`, i.e., there always exists
a strictly past time. This corresponds to `no_min_order`.

In Lean form:
```lean
-- Future seriality
| serial_future : Axiom ((Formula.bot.imp Formula.bot).imp
    (Formula.some_future (Formula.bot.imp Formula.bot)))
-- i.e., ⊤ → F(⊤)

-- Past seriality
| serial_past : Axiom ((Formula.bot.imp Formula.bot).imp
    (Formula.some_past (Formula.bot.imp Formula.bot)))
-- i.e., ⊤ → P(⊤)
```

**Soundness**: On any linear order without endpoints (ℤ, ℚ, ℝ), both hold.
Under `NoMaxOrder` and `NoMinOrder` constraints (which are standard in this
codebase, see e.g. `FrameConditions.lean` and the `DenseCompletenessStatement`
which requires `[NoMaxOrder D] [NoMinOrder D]`).

**Alternative**: The IRR rule from GHR 1994 (which report 47 showed is unsound under
reflexive H, but SOUND under strict H) is:
```
IRR: (H(¬p) ∧ p) → φ
```
where p is a fresh propositional atom. This is an inference rule, not an axiom schema.
Under strict H, `H(¬p)` means ¬p at all STRICTLY past times. So `H(¬p) ∧ p`
means "p holds now for the first time." The IRR rule says: from any formula
derivable when some fixed past-exclusive atom holds for the first time, we can
derive it unconditionally. This is used to prove `φ_imp_F_phi` (Finding 8).

### Finding 7: BX12 (`F(φ) → (⊤ U φ)`) — Still Valid Under Strict Until

Under strict Until, `⊤ U φ` at t requires ∃ s > t with φ(s) and ⊤ on (t, s).
Since ⊤ holds everywhere, this reduces to ∃ s > t with φ(s), which is exactly F(φ).

**BX12 is VALID and KEPT under strict Until.**

Soundness sketch: If F(φ) holds at t, then ∃ s > t with φ(s). Take that s as the
witness for `⊤ U φ`. Guard: ⊤ holds at all t' in (t, s). Done.

### Finding 8: phi_imp_F_phi Under Strict Semantics

Under reflexive G: `φ → G(φ)` can be derived (or its consequences). Under irreflexive
G, this fails. The report 47 question asks about `phi_imp_F_phi` — this is the theorem
`φ → F(φ)` (perpetuity: what is true now will always be true in the future).

Under reflexive semantics: `φ → G(φ)` (perpetuity) was potentially derivable via BX1
composition. Under irreflexive semantics: `φ → F(φ)` is FRAME-DEPENDENT:
- It holds on dense orders (between any two points there's another)
- It does NOT hold on discrete orders with a maximum element
- It DOES hold on ℤ, ℚ, ℝ (which are serial)

With the seriality axiom `⊤ → F(⊤)` added, we get `F(⊤)` and hence "there exists
a future time." But `φ → F(φ)` is stronger — it requires φ to hold SOMEWHERE in
the future, not just that some future time exists.

**`phi_imp_F_phi` is NOT an axiom of the irreflexive system and NOT derivable from
seriality alone.** This is a feature, not a bug — the theorem depended on
reflexivity (`G(φ) → φ` + `G(φ) → G(G(φ))` compositional argument).

Under irreflexive semantics, the correct "perpetuity" notion is via G:
`G(φ)` means φ holds at ALL strictly future times.

### Finding 9: Is BX12 Still Valid? (`□(φ → G(φ)) → (φ → G(φ))`)

The question in the prompt was about BX12 meaning `□(φ → G(φ)) → (φ → G(φ))`.
In the CURRENT CODE, BX12 is `F_until_equiv`: `F(φ) → (⊤ U φ)`. The numbered
axiom `□(φ → G(φ)) → (φ → G(φ))` is not a BX axiom in the code.

However, in GHR 1994 terminology, this type of axiom says "if it's necessarily the
case that φ persists forever, then φ persists forever" — which under S5 modal (□
is S5) and any semantics, this holds by modal_t: `□ψ → ψ` where `ψ = φ → G(φ)`.
**This holds regardless of temporal semantics change.** KEEP.

### Finding 10: IRR Rule Interaction with Other Axioms

The IRR rule `(H(¬p) ∧ p) → φ` (as a meta-rule or constructor) under STRICT H:

1. **Does not interact with BX1-BX9** directly — it's a global side condition rule
2. **Requires seriality** (past): If there's no strictly past time, then `H(¬p)` is
   vacuously true for any p, making `H(¬p) ∧ p` satisfiable. With past seriality
   `P(⊤)` (there always is a past), we ensure H is non-trivial.
3. **Modal interaction**: The IRR rule is used in completeness proofs to ensure
   any "history" has an infinite past. This interacts with `modal_future`/`temp_future`
   only indirectly (through the canonical model construction).
4. **SOUNDNESS under strict H (CONFIRMED)**: Since strict H excludes the present,
   `H(¬p) ∧ p` at t means: ¬p at all times s < t, AND p at t. This is consistent
   on any linear order (p holds for the first time at t). The rule says any φ
   derivable from this assumption is valid — which is the standard "irreflexivity"
   rule from modal logic (an axiom schema that forces irreflexivity of the frame).

### Finding 11: Burgess 1982 / GHR 1994 Comparison

From code comments and inline references in `Axioms.lean`:
- **Burgess 1982/84**: Provides Until-Since temporal logic axiomatization
- **Xu 1988**: Completeness for Until-Since on linear orders
- **GHR 1994** (Gabbay-Hodkinson-Reynolds): The standard source for `IRR` rule

The BX axiom system in this codebase is a **REFLEXIVE** version inspired by Burgess-Xu.
The **STRICT/IRREFLEXIVE** version from GHR 1994 uses:
- Strict G/H (< instead of ≤)
- Strict Until/Since (> instead of ≥ for witness)
- IRR rule for irreflexivity of temporal order
- Seriality axioms for future/past

Key differences from current code:
1. No T-axioms (`Gφ → φ`) in the irreflexive system
2. IRR rule replaces reflexivity in completeness proof
3. BX8 (`ψ → φ U ψ`) is absent
4. BX9 character changes (see §Finding 5)

---

## Recommended Approach

### Approach: Strict Until with Half-Open Guard [t, s) — Sub-option A2

Based on the evidence, I recommend **Sub-option A2** from report 47:
- Strict witness (s > t) for Until/Since
- Half-open left-closed guard [t, s) for Until (same as current)
- Strict G/H (s > t quantification)

**Rationale**:
1. BX9 is preserved (`(φ U ψ) → φ ∨ ψ` holds because guard includes t)
2. BX8 is removed (correct — reflexive intro fails)
3. Step transfer becomes provable: given `(φ U ψ) ∈ fam(r+1)`, the witness
   s > r+1 works at r too (s > r since s > r+1 > r), and the guard [r+1, s)
   ∪ {r} = [r, s) — **wait**, this requires φ at r, which we have from the
   step hypothesis `φ ∈ fam(r)`. So the guard [r, s) is satisfied: φ at r
   from hypothesis, φ on [r+1, s) from the original guard. ✓

This resolves the backward Until coherence sorry!

**Axioms to ADD**:
```lean
-- BX8 REMOVED (refl_intro_until, refl_intro_since)
-- BX1/BX1' REMOVED (temp_t_future, temp_t_past)

-- NEW: Future seriality
| serial_future (φ : Formula) :
    Axiom ((Formula.bot.imp Formula.bot).imp
           (Formula.some_future (Formula.bot.imp Formula.bot)))

-- NEW: Past seriality
| serial_past (φ : Formula) :
    Axiom ((Formula.bot.imp Formula.bot).imp
           (Formula.some_past (Formula.bot.imp Formula.bot)))
```

**Truth.lean changes needed**:
- `all_future φ`: change `∀ s, t ≤ s → truth_at M τ s φ` to `∀ s, t < s → ...`
- `all_past φ`: change `∀ s, s ≤ t → ...` to `∀ s, s < t → ...`
- `untl φ ψ`: change witness from `∃ s ≥ t` to `∃ s > t`
- `snce φ ψ`: change witness from `∃ s ≤ t` to `∃ s < t`

**Note on guard convention**: If Until guard changes from [t, s) to (t, s) (Sub-option A1),
BX9 is also removed. Report 47 suggested A1 is necessary for the most direct step
transfer proof. I now believe A2 ALSO works for step transfer (see rationale above),
while preserving more axioms and reducing blast radius.

---

## Evidence and Examples

### Evidence for BX8 Unsoundness Under Strict Until

Model: D = {0, 1}, temporal order 0 < 1, φ holds at 0, ψ holds only at 0.
At time 0: `ψ` holds. Does `φ U ψ` hold? Under strict Until, need s > 0 with ψ(s).
Only s = 1 is available but ψ ∉ 1. So `φ U ψ` is FALSE at 0 while ψ is TRUE at 0.
This falsifies `ψ → φ U ψ`. ✓

### Evidence for Step Transfer Under Sub-option A2

Claim: Under strict Until with half-open guard [t, s), backward step transfer holds.

Given: `(φ U ψ) ∈ fam(r+1)` and `φ ∈ fam(r)`.
Semantically: ∃ s > r+1, ψ(s) ∧ φ on [r+1, s).
To show: `(φ U ψ) ∈ fam(r)`.
Semantically: need ∃ s' > r, ψ(s') ∧ φ on [r, s').
Take s' = s. Then s > r+1 > r ✓.
Guard: φ on [r, s) = {r} ∪ [r+1, s).
  - φ at r: given by hypothesis `φ ∈ fam(r)` ✓
  - φ on [r+1, s): given by original guard ✓

At the PROOF SYSTEM level: this becomes the axiom `(φ U ψ) ∧ ¬ψ → F(φ U ψ)`,
derived from the unfolding. Under reflexive semantics this failed because the
witness could be s = r+1 in fam(r+1) itself (not strictly after r in fam(r+1)).
Under strict Until, s > r+1 ≥ r+1 → s > r, giving the strict gap needed.

### Evidence for BX12 Soundness Under Strict Until

F(φ) holds at t iff ∃ s > t with φ(s).
(⊤ U φ) at t requires ∃ s > t with φ(s) and ⊤ on [t, s).
Since ⊤ holds everywhere, (⊤ U φ) ↔ F(φ). ✓

### Evidence for Seriality Necessity

On a linear order with maximum element (e.g., {0, 1} with 1 maximal):
- G(⊥) holds at 1 (vacuously, no strictly future time)
- So ¬G(⊥) fails at 1
- Without `serial_future` (¬G(⊥)), the frame may have maximum elements

The canonical BXCanonical model uses Int, which has NoMaxOrder and NoMinOrder.
The seriality axioms are sound on Int (and ℤ, ℚ, ℝ, ℚ) and force this in
general frame validity.

---

## Confidence Level

| Finding | Confidence |
|---------|------------|
| BX1/BX1' unsound under strict G/H | HIGH (95%) |
| BX8/BX8' unsound under strict Until | HIGH (95%) |
| BX9/BX9' valid under A2 (half-open guard) | HIGH (90%) |
| BX9/BX9' unsound under A1 (open guard) | HIGH (85%) |
| BX10-BX12 valid under strict Until | HIGH (95%) |
| Seriality axioms needed | HIGH (90%) |
| Step transfer provable under A2 | MEDIUM-HIGH (80%) |
| IRR rule sound under strict H | HIGH (95%) — confirmed by round 47 |
| BX12 (`F(φ) → ⊤ U φ`) valid under strict Until | HIGH (95%) |
| phi_imp_F_phi not derivable from new system | HIGH (90%) |

**Overall confidence for the A2 approach**: MEDIUM-HIGH (75%). The key uncertainty
is whether A2 provides all the infrastructure needed for the BXCanonical completeness
proof, specifically whether the restricted temporal coherence sorry (#2-3: backward
chain) can also be resolved, or only #4-5 (backward Until step transfer).

---

## Summary for Team Lead

1. **Remove**: `temp_t_future` (BX1), `temp_t_past` (BX1'), `refl_intro_until` (BX8),
   `refl_intro_since` (BX8')

2. **Keep as-is**: All propositional, all S5 modal, BX2-BX7, BX10-BX12, modal-temporal interaction

3. **Modify `until_elim` (BX9)**: Keep if using A2 (half-open guard); remove if using A1

4. **Add**: `serial_future` (`⊤ → F(⊤)`) and `serial_past` (`⊤ → P(⊤)`)

5. **Truth.lean**: Change ≤ to < for G/H quantification; change ≥ to > for Until/Since witness

6. **Sorry sites resolved by switch**: #4 `restricted_buc` and #5 `restricted_fuc` (backward
   Until/Since coherence) are directly resolved by strict Until step transfer under A2

7. **Sorry sites NOT resolved by switch alone**: #1 `fwd_chain_forward_F` (F-eventuality
   resolution), #2-3 (backward chain for restricted_tc) — these need additional work

8. **Blast radius**: ~150+ compilation failures on the branch (per round 47 findings),
   but all on the dedicated branch `until` — trivial rollback
