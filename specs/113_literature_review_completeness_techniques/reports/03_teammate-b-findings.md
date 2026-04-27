# Teammate B Findings: Correct BX Axiom Set Under Open Guard Semantics

## Summary

Under open guard (t, s) semantics for U/S, four axioms in the current codebase are
**unsound** and must be removed. The six Burgess-Xu core axioms (plus linearity A7)
cover the minimal complete set for all linear orders. The lemma
`until_guard_in_mcs` used heavily in the chronicle construction must be replaced
using Xu Lemma 2.3(i). BX5 (self_accum_until) is sound under open guard with
`lt_trans` replacing `le_trans` at two points.

---

## 1. Literature: Semantics Agreement

All four papers use the **same open-interval guard**:

**Burgess 1982** (Section 1.2):
```
V(U(α,β)) = { x : ∃y (x < y ∧ y ∈ V(α) ∧ ∀z (x < z < y ⊃ z ∈ V(β))) }
```
Guard is the open interval (x, y) — neither x nor y is in the guard zone.

**Xu 1988** (Section 1, clauses (iv)/(v)):
```
⊨ U(β,γ)[t] iff ∃t' (t < t' ∧ β(t') ∧ ∀t''(t < t'' < t' → γ(t'')))
```
Same open guard. t itself is NOT covered by γ.

**Reynolds 1992** (Section 2):
```
⊨ U(A,B)(t) iff ∃s > t (A(s) ∧ ∀u ∈ T, if t < u < s then B(u))
```
Same open guard.

**Venema 1993** (Section 2.2):
```
⊨ U(φ,ψ) at t iff ∃v > t (v ⊨ φ ∧ ∀u (t < u < v → u ⊨ ψ))
```
Same open guard.

**Conclusion**: The literature is unanimous. Open guard is the correct semantics.

---

## 2. Current Codebase Axiom Classification

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean`

The codebase has 37 axiom constructors. Classification under open guard:

### Layer 1: Propositional (4) — ALL KEEP

| Axiom | Status | Reason |
|-------|--------|--------|
| `prop_k` | KEEP | Pure propositional |
| `prop_s` | KEEP | Pure propositional |
| `ex_falso` | KEEP | Pure propositional |
| `peirce` | KEEP | Pure propositional |

### Layer 2: S5 Modal (5) — ALL KEEP

| Axiom | Status | Reason |
|-------|--------|--------|
| `modal_t` | KEEP | S5, no temporal content |
| `modal_4` | KEEP | S5, no temporal content |
| `modal_b` | KEEP | S5, no temporal content |
| `modal_5_collapse` | KEEP | S5, no temporal content |
| `modal_k_dist` | KEEP | S5, no temporal content |

### Layer 3: BX Temporal — MIXED

#### Burgess-Xu Core (from Burgess 1982 A1a/A2a):

| Axiom | Codebase Name | Status | Reason |
|-------|---------------|--------|--------|
| A1a | `left_mono_until` (BX2) | KEEP | Sound under open guard; G(φ→χ) covers (t,s) |
| A1b | `left_mono_since` (BX2') | KEEP | Mirror of A1a |
| A2a | `right_mono_until` (BX3) | KEEP | G(φ→ψ) covers open guard; standard |
| A2b | `right_mono_since` (BX3') | KEEP | Mirror |
| A3a | `connect_future` (BX4) | KEEP | φ→G(P(φ)); sound, no guard issue |
| A3b | `connect_past` (BX4') | KEEP | Mirror |
| A5a (Burgess) | `self_accum_until` (BX5) | KEEP | See Section 5 below |
| A5b | `self_accum_since` (BX5') | KEEP | Mirror |
| A6a (Burgess) | `absorb_until` (BX6) | KEEP | Sound; see Section 5 |
| A6b | `absorb_since` (BX6') | KEEP | Mirror |
| A7a (Burgess) | `linear_until` (BX7) | KEEP | Linearity of witnesses; sound |
| A7b | `linear_since` (BX7') | KEEP | Mirror |

#### Seriality:

| Axiom | Codebase Name | Status | Reason |
|-------|---------------|--------|--------|
| BX1 | `serial_future` | KEEP | ⊤→F(⊤); valid on strict orders |
| BX1' | `serial_past` | KEEP | Mirror |

#### Temporal distribution:

| Axiom | Codebase Name | Status | Reason |
|-------|---------------|--------|--------|
| — | `temp_k_dist` | KEEP | G distribution; standard |
| — | `temp_4` | KEEP | G transitivity; standard |

#### Eventuality extraction:

| Axiom | Codebase Name | Status | Reason |
|-------|---------------|--------|--------|
| BX10 | `until_F` | KEEP | (φUψ)→F(ψ); under open guard, witness s>t gives F(ψ) |
| BX10' | `since_P` | KEEP | Mirror |

#### Linearity (F-level):

| Axiom | Codebase Name | Status | Reason |
|-------|---------------|--------|--------|
| BX11 | `temp_linearity` | KEEP | F(φ)∧F(ψ)→...; no guard dependency |
| BX11' | `temp_linearity_past` | KEEP | Mirror |

#### F-Until bridge:

| Axiom | Codebase Name | Status | Reason |
|-------|---------------|--------|--------|
| BX12 | `F_until_equiv` | KEEP | F(φ)→(⊤Uφ); sound under open guard |
| BX12' | `P_since_equiv` | KEEP | Mirror |

#### UNSOUND AXIOMS — REMOVE:

| Axiom | Codebase Name | Why Unsound Under Open Guard |
|-------|---------------|------------------------------|
| BX9 | `until_elim` | Claims (φUψ)→(φ∨ψ). Under open guard, t∉guard zone, so φ(t) not required |
| BX9' | `since_elim` | Same reason for Since |
| — | `until_guard` | Claims (φUψ)→φ. Directly asserts t∈guard; FALSE under open guard |
| — | `since_guard` | Same reason for Since |

**Counterexample for `until_guard`**: Under open guard, take t=0, s=2, guard=(0,2). φ holds on (0,2) but NOT at t=0. So (φUψ)(0) can hold without φ(0).

**Note**: `until_elim` is also unsound: it is implied by `until_guard` (since φ∨ψ follows from φ). Under open guard, neither guard⊃φ(t) nor ψ(t) is forced.

### Layer 4: Modal-Temporal Interaction (2) — ALL KEEP

| Axiom | Status | Reason |
|-------|--------|--------|
| `modal_future` | KEEP | □φ→□(Gφ); no temporal guard |
| `temp_future` | KEEP | □φ→G(□φ); no temporal guard |

---

## 3. Summary of Changes

**REMOVE (4 axioms)**:
- `until_guard` (φUψ)→φ
- `since_guard` (φSψ)→φ
- `until_elim` (φUψ)→(φ∨ψ) — implied by until_guard, also unsound
- `since_elim` (φSψ)→(φ∨ψ) — same

**KEEP (33 axioms)**: All others.

**ADD**: None required. The six Burgess-Xu axioms (A1a/A2a×2 + A5a/A6a + A7a, plus duals) are precisely what Reynolds 1992 calls "the six Burgess-Xu axioms" forming the minimal complete set for all linear orders.

Reynolds (p. 93-94) explicitly states: "The six Burgess-Xu axioms first appeared in [Burgess 1982] along with **another one** [A4a = until_elim-style]. In [Xu 1988] we are rid of the extra one." This confirms A4a (until_elim in Burgess's notation) is not needed in the minimal system. Xu's Σ₄ = {(7),(8),(9),(10),(11)} for linear orders uses no guard axiom.

---

## 4. Xu Lemma 2.3(i) Replacement for `until_guard_in_mcs`

### Current situation

`until_guard_in_mcs` (RRelation.lean lines 86-93) states:
```
γUδ ∈ A → γ ∈ A
```
This is used at:
- **RRelation.lean line 1193**: `burgessR3Maximal_exists_from_seed` — extracting η ∈ A from
  `burgessR(A, η, C)` (which gives `untl(η, γ₀) ∈ A`), then concluding η ∈ A.
- **PointInsertion.lean line 673**: Using `until_guard_in_mcs` on `untl(bot, gamma) ∈ A`
  to derive `bot ∈ A` (contradiction proof).
- **RRelation.lean lines 1235-1236**: `untl_absorb_nested` uses `Axiom.until_guard` to build
  a derivation `untl(γ,δ)→γ`.

### Why it's FALSE under open guard

Under open (t, s) guard: `γUδ ∈ A` does not imply `γ ∈ A`. A maximally consistent set A
at time t can contain `γUδ` even when `γ(t)` is false — the witness s>t has δ(s) and
γ holds on the open interval (t,s), but γ need not hold AT t.

**Xu Lemma 2.3(i)** provides the correct replacement:

> **Lemma 2.3(i)**: If R(A, B, C), then S(α, ⊤) ∈ B for every α ∈ A.

In Burgess/Xu notation: if R(A,B,C) holds (B is the R-maximal intermediate set
between A and C), then for every formula α in A, the formula `S(α, ⊤) = P(α)` is
in B. Intuitively: the intermediate period "remembers" everything from A via Since.

The dual (Lemma 2.3(ii)): `U(γ, ⊤) ∈ B` for every γ ∈ C — the intermediate
period also "anticipates" everything in C via Until.

### Replacement design

**For `burgessR3Maximal_exists_from_seed`** (the main consumer):
The proof needs η ∈ A from `burgessR(A, η, C)`.

`burgessR(A, η, C)` means: for all γ ∈ C, `untl(η, γ) ∈ A`.

Under open guard, this no longer gives η ∈ A directly. Instead:
- Take any MCS C with some γ₀ ∈ C.
- We have `untl(η, γ₀) ∈ A` by hypothesis.
- Apply Xu Lemma 2.3(i): if R(A, B, C) then `snce(α, ⊤) ∈ B` for all α ∈ A.

But the seed construction needs η ∈ A *before* building B. This is the core
difficulty. The solution from Xu's proof (Lemma 2.2, p. 4) is:

**Lemma 2.2**: If `r(A, β, C)` holds, then `snce(α, β) ∈ C` for every α ∈ A.

This means: if `untl(η, γ₀) ∈ A` for all γ₀ ∈ C (i.e., `burgessR(A, η, C)` holds),
then for every α ∈ A, `snce(α, η) ∈ C`.

The seed construction should be revised: instead of extracting η ∈ A directly,
use the deductive closure of {η} seeded via `burgessR` directly (η appears as the
"beta" in r(A, η, C)), leveraging that η itself is the intermediate formula.

**For `untl_absorb_nested`** (uses `Axiom.until_guard` to build `untl(γ,δ)→γ`):
The derivation `untl(γ,δ)→γ` no longer holds. The nested absorption
`untl(γ, untl(γ,δ)) → untl(γ,δ)` must be re-derived without this step.

Alternative: use BX6 (absorb_until) differently, or establish via BX5+BX6 chain:
- `untl(γ, untl(γ,δ))`: witness s gives `untl(γ,δ)(s)` and γ on (t,s)
- At s: `untl(γ,δ)(s)` means ∃r>s, δ(r) and γ on (s,r)
- So δ(r) with γ on (t,s)∪(s,r); under transitivity of strict linear order,
  we need to handle the point s itself.

This is the tricky part: under open guard, the gap at s (where neither (t,s)
nor (s,r) covers s) means γ(s) is not directly asserted. However, since
`untl(γ,δ)(s) ∈ MCS` and BX5 gives `(γ∧untl(γ,δ))Uδ ∈ MCS`, the MCS
approach remains valid via the r-relation machinery.

**For `PointInsertion.lean` line 673** (`until_guard_in_mcs h_mcs_A h_utl_bot`):
The proof derives `untl(bot, gamma) ∈ A` and then concludes `bot ∈ A` via
`until_guard`. Under open guard, `until_guard` is gone. However:
- `untl(bot, gamma)` under open guard means ∃s>t, γ(s) ∧ ∀r∈(t,s), bot(r).
- bot never holds, so ∀r∈(t,s), bot(r) is vacuously true.
- Therefore `untl(bot, gamma)` is equivalent to `F(gamma)` under open guard.
- The key question is whether `untl(bot, gamma) ∈ A` leads to contradiction.
- Under open guard: `bot ∉ guard` at t, so no direct contradiction from guard.
- Need to use BX10 (until_F): `untl(bot, gamma) → F(gamma)` — this doesn't
  give bot. The contradiction strategy must be reworked.

The contradiction in that context comes from `delta.neg AND delta ⊢ bot` in the
GUARD position, not at the base point. Under open guard the same contradiction
still works because the guard formula `bot` holds vacuously on the empty interval
(when t and s are adjacent with nothing between). The entire argument depends on
whether the *intermediate DCS* inherits inconsistency — this is a separate question
for the PointInsertion analysis.

---

## 5. BX5 Soundness Under Open Guard

### Current proof (SoundnessLemmas.lean lines 608-617, `self_accum_since` case)

The code proves the Until direction (via swap_temporal) at lines 608-617:
```lean
| self_accum_since φ ψ =>
    -- Until semantics: ∃ s > t, ψ'(s) ∧ ∀ r ∈ [t,s), φ'(r)
    intro ⟨s, hts, h_ψs, h_guard⟩
    refine ⟨s, hts, h_ψs, fun r htr hrs => ?_⟩
    intro h_neg
    exact h_neg (h_guard r htr hrs)
      ⟨s, hrs, h_ψs, fun q hqr hqs => h_guard q (le_trans htr hqr) hqs⟩
```

This uses `le_trans htr hqr` where `htr : t ≤ r` and `hqr : r ≤ q` to get `t ≤ q`.

### Under open guard `(t, s)`:

The guard condition changes from `t ≤ r < s` (half-open) to `t < r < s` (open).

For BX5 `(φUψ) → (φ∧(φUψ))Uψ`:
- Assume `φUψ` at t: ∃s>t, ψ(s) ∧ ∀r∈(t,s), φ(r)
- Must show `(φ∧(φUψ))Uψ` at t: ∃s>t, ψ(s) ∧ ∀r∈(t,s), (φ∧(φUψ))(r)
- For r∈(t,s): φ(r) holds (from guard). Must also show (φUψ)(r).
- (φUψ)(r): need ∃q>r, ψ(q) ∧ ∀p∈(r,q), φ(p).
- Take q=s: ψ(s) ✓. For p∈(r,s): since t<r<p<s, p∈(t,s), so φ(p) ✓.

**Key step**: `∀p∈(r,q), φ(p)` needs `t < p` (strict). Under open guard we have
`r < p` and `t < r`, so `t < p` follows by `lt_trans htr hrp` (strict transitivity).

This means `le_trans` at line 607 (for the Since direction) should be `lt_trans`:
```lean
-- Current:
fun q hqs hqr => h_guard q hqs (le_trans hqr hrt)
-- Corrected (open guard):
fun q hqs hqr => h_guard q hqs (lt_trans hqr hrt)
-- where hqr : q < r and hrt : r < t (Since direction uses reversed inequalities)
```

Similarly for the Until direction (line 617):
```lean
-- Current:
fun q hqr hqs => h_guard q (le_trans htr hqr) hqs
-- Corrected (open guard):
fun q hqr hqs => h_guard q (lt_trans htr hqr) hqs
-- where htr : t < r and hqr : r < q
```

**Conclusion**: BX5 IS sound under open guard. The proof needs `lt_trans` in two
places replacing `le_trans`, reflecting that the guard is now strictly open.
Both transitions remain valid because we're propagating strict inequalities.

The Since direction at lines 598-607 uses the half-open Since guard `(s,t]` (guard
covers s < r ≤ t). Under the proposed open guard `(s,t)`, the `le_rfl` for the
endpoint `r ≤ t` becomes `r < t`, changing the guard condition throughout.

---

## 6. Additional Observations

### Xu's Σ₄ for Linear Orders

Xu's complete axiom set for linear frames `C₄` (Theorem, Section 3) is:
```
Σ₄ = { (7), (8), (9), (10), (11) }
```
where:
- (7): `U(p,q) → U(p, q∧U(p,q))` = BX5 (self_accum_until)
- (8): `S(p,q) → S(p, q∧S(p,q))` = BX5' (self_accum_since)
- (9): `U(q∧U(p,q), q) → U(p,q)` = BX6 (absorb_until)
- (10): `U(p,q)∧U(r,s) → U(p∧r,q∧s)∨U(p∧s,q∧s)∨U(q∧r,q∧s)` = BX7 (linear_until)
- (11): mirror of (10) = BX7' (linear_since)

These are added to the minimal logic `TL_US(∅)` which contains axioms (1)-(4):
- (1) = `G(p→q) → (U(r,p)→U(q,r)) ∧ (U(r,p)→U(r,q))` = combined BX2+BX3
- (2) = mirror of (1) = BX2'+BX3'
- (3) = `p ∧ U(q,r) → U(q∧S(p,r), r)` = Burgess A3a (connectedness, now BX4-style)
- (4) = mirror of (3)

**Critically**: No guard axiom appears in Σ₄ or in axioms (1)-(4). Xu explicitly
omits it; this is the "another one" Reynolds refers to as being "rid of" in Xu 1988.

### Reynolds' Six Burgess-Xu Axioms

Reynolds (p. 93-94) lists exactly:
1. `G(p→q) → (U(p,r) → U(q,r))`
2. `G(p→q) → (U(r,p) → U(r,q))`
3. `p∧U(q,r) → U(q∧S(p,r),r)`
4. `U(p,q) → U(p, q∧U(p,q))`
5. `U(q∧U(p,q),q) → U(p,q)`
6. `U(p,q)∧U(r,s) → U(p∧r,q∧s)∨...`

Plus their duals. **No guard axiom**. Reynolds confirms this is the minimal set
for strong completeness over all linear orders.

### Venema's Axiom System B

Venema's system **B** (Definition 3.2/3.4) lists A1a-A7a and their mirrors.
A4a is `U(p,q)∧¬U(p,r) → U(q∧¬r, q)` — this is Burgess's original A4a, NOT a
guard axiom. Venema also has no guard axiom.

---

## 7. Conclusions

### Correct BX axiom set under open guard (33 axioms total)

Remove the 4 guard-dependent axioms:
- `until_guard`, `since_guard`, `until_elim`, `since_elim`

All other 33 axioms are sound under open guard and match the literature.

### Xu Lemma 2.3(i) replacement strategy

The key infrastructure lemma `until_guard_in_mcs` (γUδ ∈ A → γ ∈ A) is FALSE
under open guard and must be replaced. Three usage sites identified:

1. **`burgessR3Maximal_exists_from_seed`** (RRelation.lean ~1193): Needs η ∈ A from
   `burgessR(A, η, C)`. Must be redesigned — `η` no longer follows from the seed
   formula. The seed may need to be constructed differently (not from a single η,
   but from the r-relation structure directly).

2. **`untl_absorb_nested`** (RRelation.lean ~1232-1260): Uses `until_guard` in a
   derivation. Must be re-proved without it. Likely provable via BX5+BX6 alone.

3. **`PointInsertion.lean` line 673**: Contradiction proof using `untl(bot,γ)→bot∈A`.
   Under open guard, `untl(bot,γ)` is satisfiable (guard holds vacuously on empty
   interval). Contradiction strategy needs revision.

### BX5 soundness

BX5 and BX5' ARE sound under open guard. The proofs in SoundnessLemmas.lean need
`lt_trans` replacing `le_trans` at the guard propagation steps (lines 607 and 617),
corresponding to the change from half-open to open guard.

### Recommendation

The guard axioms (`until_guard`, `since_guard`) should be removed from `Axioms.lean`.
The derived lemmas `until_elim` and `since_elim` (which were implied by `until_guard`)
must also be removed as they are independently unsound. The `rRelation` and
`BurgessR3` machinery that depended on `until_guard_in_mcs` needs redesign using
Xu Lemmas 2.1-2.3 directly, particularly Lemma 2.3(i): R(A,B,C) → S(α,⊤) ∈ B for
all α ∈ A.
