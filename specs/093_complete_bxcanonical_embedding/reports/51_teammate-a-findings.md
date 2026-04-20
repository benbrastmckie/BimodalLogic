# Teammate A Findings: Serial Axiom Necessity for Completeness

**Task 93** | Teammate A | Focus: Serial axioms (BX1/BX1') in BXCanonical completeness

---

## Key Findings

1. **Serial axioms (BX1/BX1') are ESSENTIAL for completeness** at three distinct sites in the canonical construction.

2. **Two concrete sorry sites exist in Soundness.lean** (`serial_future_axiom_valid` and `serial_past_axiom_valid`), but these are a separate (solvable) problem from the completeness uses.

3. **The completeness proof depends on serial axioms in Frame.lean**, specifically in `g_content_set_consistent` and `h_content_set_consistent`, which are called by nearly every downstream lemma.

4. **A build-breaking error exists in OracleStep.lean**: `Axiom.temp_t_future` and `Axiom.temp_t_past` (old reflexivity axioms, `G(φ)→φ` and `H(φ)→φ`) are referenced at lines 76 and 141, but these constructors were removed from `Axioms.lean` when the semantics switched to irreflexive. The build fails with `Unknown constant` errors.

5. **bx_le_refl is sorried and structurally false** under irreflexive semantics: `bx_le w w` requires `g_content(w) ⊆ w`, i.e., `G(φ)→φ` for all φ, which is precisely the reflexivity axiom that was removed.

---

## Evidence / Examples

### Site 1: `g_content_set_consistent` and `h_content_set_consistent` in Frame.lean (lines 148-162, 186-195)

These are the most critical uses. The proof that `g_content(S)` and `h_content(S)` are consistent as sets uses serial axioms directly:

```lean
-- g_content_set_consistent (Frame.lean ~line 148):
-- If L ⊆ g_content(S) and L ⊢ ⊥, then G(⊥) ∈ S.
-- Derives G(¬⊤) ∈ S, then uses Axiom.serial_future to get F(⊤) ∈ S.
-- F(⊤) = ¬G(¬⊤) contradicts G(¬⊤) ∈ S.
have h_serial : DerivationTree [] ((Formula.bot.imp Formula.bot).imp
    (Formula.some_future (Formula.bot.imp Formula.bot))) :=
    DerivationTree.axiom [] _ Axiom.serial_future

-- h_content_set_consistent (Frame.lean ~line 186): mirrors with Axiom.serial_past
```

**These consistency lemmas are the foundation for**:
- `bx_G_backward` (finding a BXPoint v ≥ w with φ ∉ v) — critical for truth lemma backward direction
- `bx_H_backward` (mirror for past) — critical for truth lemma backward direction
- The entire oracle Lindenbaum extension infrastructure

### Site 2: `qm_oracle_seed_subset_mcs` and `qm_oracle_seed_bwd_subset_mcs` in OracleStep.lean (lines 76, 141)

The oracle seed consistency proofs require that `g_content(w) ⊆ w.formulas`:

```lean
-- OracleStep.lean line 76:
exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs (DerivationTree.axiom [] _ (Axiom.temp_t_future f))) h_g
```

This calls `Axiom.temp_t_future` — the OLD reflexivity axiom `G(φ)→φ` — which no longer exists in `Axioms.lean`. This causes the current build failure.

Under irreflexive semantics, `G(φ)→φ` is NOT an axiom. The relation `g_content(w) ⊆ w` does NOT hold in general for a BXPoint. This is semantically correct: in a world `w`, `G(φ)` means "at all strict future times φ holds" — it says nothing about `w` itself.

### Site 3: `F_of_mem` and `P_of_mem` in Realization.lean (lines 54-73)

The lemmas that F(ψ) ∈ w follows from ψ ∈ w (and their duals) are sorried with the comment:

```lean
-- Under irreflexive semantics, BX1 (G(φ) → φ) is removed.
-- F_of_mem no longer follows from BX1. Sorry'd (non-critical Quasimodel path).
sorry
```

These used to follow from BX1 (G(¬ψ)→¬ψ, contradicting ψ ∈ w). Under irreflexive semantics, G(¬ψ)→¬ψ does not hold, so this route is blocked. The comment says "non-critical Quasimodel path" but this requires verification.

### Site 4: `enriched_seed_consistent_until/since` in Realization.lean (lines 189-199, 241-249)

The g_content and h_content subset inclusions in enriched seed consistency are sorried:

```lean
· -- α ∈ g_content(w): G(α) ∈ w → α ∈ w (BX1 removed under irreflexive semantics)
  -- Sorry'd (non-critical Quasimodel path)
  sorry
```

Again, `G(α)→α` (BX1 under reflexive semantics) was removed.

### Site 5: `bx_le_refl` in Frame.lean (line 202)

```lean
theorem bx_le_refl (w : BXPoint) : bx_le w w := by
  -- Under irreflexive semantics, bx_le is NOT reflexive.
  -- G(φ) → φ is no longer valid.
  sorry
```

This is sorried and the comment correctly identifies that it is structurally FALSE under irreflexive semantics with the current definition of `bx_le`. `bx_le w w` means `g_content(w) ⊆ w`, which requires `G(φ)→φ`, exactly the axiom that was removed.

---

## Analysis: What Serial Axioms Actually Do

The serial axioms BX1/BX1' in the current system are:
- `serial_future`: `⊤ → F(⊤)` (every time has a strict successor)
- `serial_past`: `⊤ → P(⊤)` (every time has a strict predecessor)

These are NOT the same as the old `temp_t_future`: `G(φ)→φ` (reflexivity). The codebase has conflated two separate role assignments:

1. **Reflexivity role** (needed in oracle and truth lemma): `G(φ)→φ` gives `g_content(w) ⊆ w`. This was BX1 under the OLD reflexive semantics. It is now ABSENT from the axiom system.

2. **Seriality role** (needed for g_content consistency): `F(⊤)` guarantees every MCS has a strict future witness. This is the CURRENT BX1 (`serial_future`). It is used in `g_content_set_consistent`.

The two Soundness.lean sorry sites (`serial_future_axiom_valid`, `serial_past_axiom_valid`) require proving `⊨ ⊤→F(⊤)` for all linear orders, which fails on a single-point order. The fix is to add `[Nontrivial D]` to the `valid` definition or use `valid_dense`/`valid_discrete` which already have nontriviality.

---

## What is Needed for Completeness

The completeness proof requires:

1. **For `g_content_set_consistent`**: The serial axiom `⊤→F(⊤)` (present in the axiom system as `serial_future`) is used to derive a contradiction from `G(¬⊤) ∈ S`. This USE is valid — `serial_future` is in the axiom system and every MCS contains it. The code at Frame.lean lines 148-162 is CORRECT.

2. **For the oracle seed**: `g_content(w) ⊆ w.formulas` is needed. This requires `G(φ)→φ` for MCS members, which is the OLD `temp_t_future` axiom. Under irreflexive semantics this is FALSE. The oracle seed must be redesigned to not include g_content in this way, OR the seed consistency must be proved differently.

3. **For `bx_le_refl`**: This is simply false under irreflexive semantics and the current `bx_le` definition. The relation `bx_le` is an ordering but it is NOT reflexive. The canonical model needs a strict (irreflexive) ordering.

---

## Recommended Approach

### Problem Decomposition

There are three separate problems being conflated:

**Problem A (Soundness — fixable)**: `serial_future_axiom_valid` fails because `valid` quantifies over all linear orders including single-point ones. Fix: add `[Nontrivial D]` assumption to `valid` or use the existing `valid_discrete`/`valid_dense` variants which already include nontriviality.

**Problem B (OracleStep build failure — fixable)**: `Axiom.temp_t_future` and `Axiom.temp_t_past` are referenced but don't exist. The proof that `g_content(w) ⊆ w.formulas` at MCS level needs to use the CURRENT serial axiom + a different argument. Specifically: `G(φ) ∈ w` and the serial axiom give `F(⊤) ∈ w`. But `G(φ)→φ` itself is not derivable. The oracle seed needs to be redesigned to not include raw `g_content` of `w` without the reflexivity guarantee.

**Problem C (bx_le_refl — structurally incorrect)**: Under irreflexive semantics `bx_le` cannot be reflexive. The canonical model uses `bx_le` as a preorder for `G`/`H`, but with strict temporal semantics `G(φ)` does not imply `φ` at the current time. The canonical model needs a strict preorder (the canonical strict order `bx_lt`) or the truth lemma for `G` must be restated to use strict ordering.

### Serial Axioms for Completeness: Literature Perspective

In the standard completeness literature for tense logic over linear orders (Burgess 1984, Goldblatt 1992):

- Over **Q** (rationals) or **R** (reals): density is assumed, and seriality (`∀t ∃s>t`) follows from density. Serial axioms are not needed separately.
- Over **Z** (integers): discrete order is assumed, and SuccOrder gives seriality. Serial axioms follow from the order type.
- The serial axiom `F(⊤)` (or `G(φ)→F(φ)`) is typically treated as a frame condition, not as a standalone axiom, because it follows from the frame property `∀t ∃s>t` (no maximum element).

The BX axiom system as encoded takes `⊤→F(⊤)` as an explicit axiom schema. This is needed precisely because the completeness proof uses a GENERIC canonical model over all linear orders (including potentially trivial ones). The canonical model being constructed is ℤ or Q (via Hintikka chains), so seriality holds for the intended models.

**Conclusion on necessity**: The serial axioms BX1/BX1' ARE necessary for completeness over their intended frame class (serial linear orders). Without them, completeness would hold only for systems that don't include these axioms, which would fail to characterize serial frames. The proof obligation in `g_content_set_consistent` is genuine and correct.

---

## Confidence Level

**High (95%)** on the following:
- Serial axioms ARE needed for completeness; the `g_content_set_consistent` usage is legitimate and irreplaceable
- `Axiom.temp_t_future`/`temp_t_past` must be replaced — these constructors don't exist anymore and the implication `G(φ)→φ` is false under irreflexive semantics
- `bx_le_refl` is false as stated and needs redesign
- Problem A (Soundness.lean sorry sites) is fixable by adding `[Nontrivial D]` to `valid`

**Medium (70%)** on:
- Whether `F_of_mem`, `P_of_mem`, and the enriched seed consistency sorries are truly "non-critical" or block the completeness path — further examination of the downstream call sites is needed
- Whether the oracle seed can be redesigned without `g_content(w) ⊆ w` — the alternate approach using the serial axiom differently needs investigation

---

## Summary of Sorry Sites Involving Serial/BX1

| File | Lemma | Reason Sorried | Critical? |
|------|-------|----------------|-----------|
| Soundness.lean:201 | `serial_future_axiom_valid` | `valid` allows single-point orders | Yes (soundness) |
| Soundness.lean:214 | `serial_past_axiom_valid` | Same | Yes (soundness) |
| Frame.lean:202 | `bx_le_refl` | `G(φ)→φ` removed from axioms | Structural issue |
| OracleStep.lean:76 | `qm_oracle_seed_subset_mcs` | `Axiom.temp_t_future` doesn't exist | BUILD FAILURE |
| OracleStep.lean:141 | `qm_oracle_seed_bwd_subset_mcs` | `Axiom.temp_t_past` doesn't exist | BUILD FAILURE |
| Realization.lean:67 | `F_of_mem` | `G(¬ψ)→¬ψ` removed | Quasimodel path |
| Realization.lean:73 | `P_of_mem` | `H(¬ψ)→¬ψ` removed | Quasimodel path |
| Realization.lean:197 | `enriched_seed_consistent_until` | `G(α)→α` removed | Quasimodel path |
| Realization.lean:249 | `enriched_seed_consistent_since` | `H(α)→α` removed | Quasimodel path |

The two BUILD FAILURE sorries in OracleStep.lean are the most urgent: they prevent the file from compiling at all.
