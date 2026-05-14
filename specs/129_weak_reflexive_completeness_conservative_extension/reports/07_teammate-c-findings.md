# Teammate C (Critic) Findings: Task 129

**Task**: 129 — weak_reflexive_completeness_conservative_extension
**Date**: 2026-05-14
**Role**: Critic — identify gaps, blind spots, and errors in report 06 and overall research

---

## Key Findings

### Finding 1: The "Fatal Flaw" in Path 2 Is Real — But Report 06 Overstates Confidence

Report 06 is correct that `Gψ ∈ x` does not imply `ψ ∧ Gψ ∈ x` in strict TM (no `temp_t` axiom). I checked whether Z1, BX5, or other axioms could provide an indirect bridge. They cannot:

- **Z1** (`FGψ → Gψ`): This operates on the *box-class level* via the maximum principle; it doesn't help at a single point x where `Gψ ∈ x` but `ψ ∉ x`.
- **BX5** (self-accumulation for Until): This is specific to Until/Since, not G.
- **temp_4** (`Gψ → GGψ`): This gives `GGψ ∈ x` from `Gψ ∈ x`, but cannot recover `ψ ∈ x`.

**However**, report 06 is wrong to claim 95% confidence. The correct confidence is closer to 85-90% because:

1. **The plan text is internally contradictory** (line 108: "by definition of R using g_content, not g_w_content"). It's possible the plan *intended* R to be defined via `g_content` (making R non-reflexive) and relied on a *separate* reflexivity argument. The plan says "R is reflexive (defined via G_w)" in the Overview, but the G-case discussion says "using g_content, not g_w_content." If the plan meant a hybrid — R defined via g_content for truth purposes but with a separately proved reflexivity property — this is still impossible (g_content doesn't give reflexivity), but the plan author may have had a different mental model than what report 06 analyzes.

2. **The backward direction** for Path 2 deserves more credit than report 06 gives. Report 06 §4.5 worries about `y ≠ x` in the Lindenbaum extension. But in practice: if `Gψ ∉ x`, we extend `{¬ψ} ∪ g_content(x)` to MCS y. Then `¬ψ ∈ y`. If additionally `ψ ∈ x`, we have `y ≠ x` immediately (since y contains ¬ψ, x contains ψ). If `ψ ∉ x`, then we can construct y with `¬ψ ∈ y` and we need some other formula to distinguish y from x. For Path 2, the *backward* direction actually works in most cases — the difficulty is specifically the *forward* direction.

**Verdict**: Path 2 forward direction IS fatally flawed. Report 06's core analysis is sound. The confidence downgrade is minor.

### Finding 2: CRITICAL — `until_backward_mcs` Has the Wrong Type Signature

The theorem at TruthLemma.lean:450 states:

```lean
theorem until_backward_mcs (x : ReflCanDomain) (ψ₁ ψ₂ : Formula)
    (_h_not_until : Formula.untl ψ₁ ψ₂ ∉ x.val) :
    ∃ (y : ReflCanDomain), tempR_fwd x y ∧ ψ₁ ∈ y.val ∧
      (∀ (z : ReflCanDomain), tempR_fwd x z → tempR_fwd z y → ψ₂ ∈ z.val)
```

This says: "if U(ψ₁,ψ₂) ∉ x, then there EXISTS y with ψ₁ ∈ y and all intermediate z have ψ₂ ∈ z." **This is the FORWARD direction restated with the wrong hypothesis!** The backward direction should show:

"If U(ψ₁,ψ₂) ∉ x, then ¬∃ y with the Until witness condition" — i.e., it should show the NEGATION of the semantic condition.

What the truth lemma actually needs for the `untl` backward case (lines 541-551) is:
```
reflCanTruth x (untl φ ψ) → untl φ ψ ∈ x.val
```

Which requires: given `∃ y, tempR_fwd x y ∧ φ ∈ y.val ∧ ...`, prove `U(φ,ψ) ∈ x.val`. This is a **constructive backward** direction: from the semantic witness, recover the syntactic membership. The current `until_backward_mcs` with hypothesis `U(φ,ψ) ∉ x` cannot serve this purpose — it would need to be used in a proof by contradiction, but its conclusion has the same shape as what you're trying to prove, creating a circular dependency.

Report 06 lists this as sorry #2 but doesn't flag the type mismatch. **This is a genuine implementation bug, not just an unfilled sorry.**

**Confidence**: HIGH. The type signature is plainly visible in the source.

### Finding 3: Missing Past-Direction Bridge Lemma

`ReflexiveCanonical.lean` proves `tempR_fwd_imp_reflCanR` (line 168): strict future implies weak future. But there is NO analogous `tempR_bwd_imp_reflCanR_bwd` lemma.

For the Reynolds construction, you need the frame preorder to capture BOTH temporal directions. Currently:

- `reflCanR` is defined via `g_w_content` (future direction only)
- There is no backward preorder analogous to `reflCanR` defined via `h_w_content`

This means the frame's preorder only tracks the forward direction. The Reynolds Theorem 15 construction needs a TOTAL preorder on the domain. Report 06 doesn't discuss how the backward temporal relation connects to the frame preorder at all.

**Question**: Is `reflCanR` intended to be a total order on the domain? The plan says "reflexive preorder" but for the Reynolds construction you need a LINEAR preorder (total + transitive + reflexive). The linearity proof (`reflCanR_linear`) is listed in the plan (Phase 1 tasks) but is NOT implemented — and no report discusses whether it's actually provable.

**Confidence**: HIGH that this is a gap. MEDIUM on whether it's a showstopper.

### Finding 4: Actual Sorry Count Is 9, Not 6

Report 06 §3 lists 9 sorries total (6 in TruthLemma, 1 in ReflexiveCanonical, 1 in IntegerModel, 1 in NEquivalence). Grepping the actual source reveals:

| File | Sorry Count | Location |
|------|-------------|----------|
| TruthLemma.lean | 6 | lines 426, 454, 490, 497, 551, 566 |
| ReflexiveCanonical.lean | 1 | line 337 (canS5R_symm) |
| IntegerModel.lean | 1 | line 100 (canonical_model_is_good) |
| NEquivalence.lean | 1 | line 67 (ktype_finite) |

**Total: 9 sorry statements in the codebase.** Report 06's count of 9 is accurate.

However, report 06 UNDERCOUNTS the effective sorry burden:

- IntegerModel.lean has definitions like `good := True`, `very_good := True`, `contemp_equiv := True`, `k_equiv := True`. These aren't marked sorry but they're vacuous — every theorem about them is trivially true and proves nothing. The file has 6 `by trivial` proofs that are effectively sorries.
- OrderedSum.lean has `doets_lemma_1_4` and `doets_lemma_1_5` proved by `trivial` against `k_equiv := True` — these are phantom proofs.
- Table.lean has `table` returning `.atom` for everything — another phantom definition.

The TRUE sorry burden (counting vacuous definitions + explicit sorries) is approximately **19 non-trivial gaps**, not 9. Report 06 correctly identifies this in §3.2-3.4 as "Phase 2/3 infrastructure" but the 9-sorry headline is misleading.

**Confidence**: HIGH.

### Finding 5: The Multi-Relation Approach Has a Coherence Problem With Reynolds

Report 06 correctly identifies that `reflCanR` is needed for the frame preorder (Reynolds's structural argument) while `tempR_fwd`/`tempR_bwd` are needed for the truth lemma. But there's a subtle issue:

Reynolds's Theorem 15 proof works on a model M with a SINGLE linear order. The "good/very good" framework defines k-equivalence over intervals of this order. In the multi-relation setup:

1. `reflCanR` defines the frame preorder (reflexive, transitive — proved)
2. `tempR_fwd` defines what "G is true" means
3. The truth lemma connects MCS membership to semantic truth via `tempR_fwd`

**The coherence question**: When Reynolds says "the interval [a,b] is good if it's k-equivalent to a Z-interval," what order defines the interval? It must be `reflCanR` (the frame preorder). But the k-type of a point is determined by which formulas are TRUE at that point, and truth is determined by `tempR_fwd`/`tempR_bwd`. So the k-type depends on `tempR_fwd` while the interval structure depends on `reflCanR`.

For this to work, you need: **the temporal truth at a point (determined by `tempR_fwd`/`tempR_bwd` relationships to OTHER points) is consistent with the frame ordering (determined by `reflCanR`)**. Specifically, you need that if `reflCanR x y`, then the temporal formulas true at x and y are "compatible" in the sense that an ordered-sum replacement of the interval [x,y] preserves truth.

The bridge lemma `tempR_fwd_imp_reflCanR` only goes ONE direction. It says: points that are temporally related are also frame-preorder related. But it doesn't say: the frame preorder accurately captures ALL temporal relationships. There could be points x, y with `reflCanR x y` but `¬tempR_fwd x y` — meaning x is "before" y in the frame order, but G-formulas at x don't propagate to y. If such points exist in an interval, the k-type of the interval (as computed from temporal truth) might not match what the frame order suggests.

**This gap is not analyzed in any report.** It could be harmless (if the Reynolds argument only ever uses the frame order for interval boundaries and never needs temporal truth to respect the frame order in the converse direction), but it needs to be explicitly addressed.

**Confidence**: MEDIUM. The issue is real but may not be a blocker.

### Finding 6: The S5 Box Modality Is Unaffected — But untested

The multi-relation approach doesn't affect `canS5R` at all — it's defined independently as `∀φ, □φ ∈ x.val → φ ∈ y.val`. The box forward and box backward proofs in the truth lemma are sorry-free and work with `canS5R` directly. No report flags any issue here, and I confirm there is none.

**However**: no report discusses the interaction between box and temporal modalities in the canonical model. For compound formulas like `□G(ψ)`, the truth lemma recurses: box backward builds an S5-accessible MCS y, then G forward at y uses `tempR_fwd`. This works because the induction is on formula structure, and each modality uses its own relation. The multi-relation design is actually cleaner here than a single-relation design would be.

**Confidence**: HIGH that box modality is fine.

### Finding 7: The "Between" Condition for Until/Since Is Non-Standard

The semantic definition of Until in `reflCanTruth` (line 60-62):
```lean
∃ (y : ReflCanDomain), tempR_fwd x y ∧ reflCanTruth y ψ₁ ∧
    (∀ (z : ReflCanDomain), tempR_fwd x z → tempR_fwd z y → reflCanTruth z ψ₂)
```

This says "z is between x and y" iff `tempR_fwd x z ∧ tempR_fwd z y`. But the real semantics (Truth.lean:127) says `t < r ∧ r < s`. The `tempR_fwd` relation is NOT guaranteed to be a linear order, nor even transitive. So "between" in terms of `tempR_fwd` could be subtly different from "between" in terms of an actual strict order.

In particular:
- `tempR_fwd x z ∧ tempR_fwd z y` requires `g_content x ⊆ z.val` AND `g_content z ⊆ y.val`
- This is NOT the same as `tempR_fwd x y` (which is `g_content x ⊆ y.val`)
- There could be z with `tempR_fwd x z` and `tempR_fwd z y` but NOT `tempR_fwd x y` (if g_content is not monotone through z)

Actually wait — `tempR_fwd x z ∧ tempR_fwd z y` DOES imply `tempR_fwd x y` by transitivity of subset inclusion: `g_content x ⊆ z.val` means every ψ with Gψ ∈ x has ψ ∈ z. Then for such ψ, if also `g_content z ⊆ y.val`, we need Gψ ∈ z to get ψ ∈ y. But `ψ ∈ z` does NOT give `Gψ ∈ z`. So `tempR_fwd` is NOT transitive.

This means the "between" condition is using a non-transitive relation to define intervals. This is mathematically unusual and could cause problems when trying to match the standard Until semantics (which uses a linear order where betweenness is well-defined).

**This is not discussed in any report and could be a significant issue for the truth transfer step (Phase 3).**

**Confidence**: MEDIUM-HIGH that this is a real issue. The truth lemma might still work because the inductive proof doesn't need global transitivity, but the Reynolds construction DOES need intervals defined by a single linear order.

---

## Recommended Approach (Areas Needing More Work)

1. **Fix `until_backward_mcs` type signature** — this is a straightforward bug, not a research gap.

2. **Prove or discuss `reflCanR` linearity** — the plan claims this should be provable from BX11 (temporal linearity axiom). No one has attempted it. This is critical for the Reynolds construction.

3. **Address the coherence question** (Finding 5) — either prove that `tempR_fwd`/`tempR_bwd` are "compatible" with `reflCanR` in the sense needed by Reynolds, or restructure the Reynolds argument to not depend on this compatibility.

4. **Address the non-transitivity of `tempR_fwd`** (Finding 7) — either prove that the "between" condition in `reflCanTruth` is equivalent to the standard one (using the frame order), or justify why the difference doesn't matter for the truth lemma.

5. **Acknowledge the true sorry burden** — the headline "9 sorries" should be contextualized with the ~19 vacuous definitions.

6. **Add `tempR_bwd_imp_reflCanR_bwd` or equivalent** — the backward direction of the temporal-to-frame bridge is completely missing.

---

## Evidence/Examples

### `until_backward_mcs` bug (Finding 2)

The truth lemma for `untl` backward (line 541-551) says:
```lean
| untl φ ψ ih_φ ih_ψ =>
    constructor
    · -- reflCanTruth x (untl φ ψ) → untl φ ψ ∈ x.val
      intro h_truth
      rcases h_truth with ⟨y, h_fwd, h_truth_y_φ, h_guard⟩
      have h_φ_y : φ ∈ y.val := (ih_φ y).mp h_truth_y_φ
      sorry  -- needs: from tempR_fwd x y, φ ∈ y, ∀z intermediate ψ∈z → U(φ,ψ) ∈ x
```

But `until_backward_mcs` (line 450) provides:
```lean
theorem until_backward_mcs (x : ReflCanDomain) (ψ₁ ψ₂ : Formula)
    (_h_not_until : Formula.untl ψ₁ ψ₂ ∉ x.val) :
    ∃ (y : ReflCanDomain), tempR_fwd x y ∧ ψ₁ ∈ y.val ∧ ...
```

The hypothesis is `U(ψ₁,ψ₂) ∉ x` but the truth lemma needs to prove `U(φ,ψ) ∈ x` from semantic witnesses — completely opposite use case.

### Non-transitivity of `tempR_fwd` (Finding 7)

Consider MCS x, z, y where:
- `Gψ ∈ x` (so ψ ∈ g_content x), and g_content x ⊆ z.val (so tempR_fwd x z)
- `Gχ ∈ z` for some χ with Gχ ∉ x. Then χ ∈ g_content z but g_content z ⊄ y.val unless y also contains χ.
- If g_content z ⊆ y.val (tempR_fwd z y), we need g_content x ⊆ y.val for tempR_fwd x y.
- But g_content x ⊆ z.val does NOT imply g_content x ⊆ y.val. We'd need: for all ψ with Gψ ∈ x, ψ ∈ y.val. We have ψ ∈ z.val, but that only helps if Gψ ∈ z (which gives ψ ∈ g_content z ⊆ y.val). But Gψ ∈ x does not imply Gψ ∈ z — we'd need GGψ ∈ x for that (via temp_4 and then extraction).

Actually, wait. Gψ ∈ x means ψ ∈ g_content x. tempR_fwd x z means g_content x ⊆ z.val. So ψ ∈ z.val. But for tempR_fwd x y (g_content x ⊆ y.val), we need ψ ∈ y.val for each such ψ. We have ψ ∈ z.val, and we need ψ ∈ y.val. If tempR_fwd z y means g_content z ⊆ y.val, we need ψ ∈ g_content z, i.e., Gψ ∈ z.val.

Now: from Gψ ∈ x, by temp_4, GGψ ∈ x, so Gψ ∈ g_content x ⊆ z.val. Therefore Gψ ∈ z, so ψ ∈ g_content z ⊆ y.val. Therefore ψ ∈ y.val.

**Actually, `tempR_fwd` IS transitive!** The argument: if Gψ ∈ x, then GGψ ∈ x (by temp_4), so Gψ ∈ g_content x ⊆ z.val, so Gψ ∈ z, so ψ ∈ g_content z ⊆ y.val.

I was wrong about Finding 7. `tempR_fwd` is transitive via temp_4. This should be proved as a lemma. Similarly `tempR_bwd` should be transitive via the past version of temp_4.

**CORRECTION**: Finding 7 is retracted. `tempR_fwd` IS transitive (via temp_4). However, this transitivity lemma is NOT proved anywhere in the codebase, which is itself a gap worth noting.

---

## Confidence Level

**Overall confidence in report 06's core recommendation (multi-relation is correct)**: HIGH (90%).

**Confidence in implementation completeness**: LOW (40%). There are significant gaps:
- Type signature bug in `until_backward_mcs`
- Missing linearity proof for `reflCanR`
- Missing transitivity proof for `tempR_fwd`/`tempR_bwd`
- Missing backward bridge lemma (`tempR_bwd_imp_reflCanR_bwd` or equivalent)
- Coherence between frame preorder and temporal relations for Reynolds is unaddressed
- True sorry burden is ~19, not 9

**Confidence that the overall approach (multi-relation + Reynolds) will work**: MEDIUM-HIGH (75%). The mathematical foundations are sound, but the gap between "mathematically sound" and "fully formalized in Lean 4" is substantial, and several structural questions remain unaddressed.
