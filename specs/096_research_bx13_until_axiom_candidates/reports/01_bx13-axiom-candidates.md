# Research Report: Task #96

**Task**: 96 - Research BX13 axiom candidates for Until propagation
**Parent Task**: 92
**Started**: 2026-04-10
**Completed**: 2026-04-10
**Language**: logic
**Session**: sess_1775856757_3e0e7d

## Executive Summary

- **Root cause recap**: The four sorries at `Frame.lean:653, 675, 690, 704` are blocked because `bx_le := g_content ⊆` only propagates G-wrapped formulas between MCSes, while the Until/Since truth lemma requires propagating Until formulas (or their guard formula `φ`) to arbitrary intermediate MCSes. No axiom in BX1-BX12 bridges this gap.
- **Headline finding**: **No sound axiom over linear temporal orders can close Gap U5.** The obstruction is categorical: sound axioms reflect semantic truths, and semantically, `φ U ψ` at time `t` constrains `φ` only on the finite interval `[t, s)` (where `s` is the Until witness), while propagation via `g_content` requires `G(φ)` -- constraining `φ` on the semi-infinite interval `[t, ∞)`. No logical manipulation can derive an infinite-interval guarantee from a finite-interval one. B-GAP (backward direction) is similarly blocked: it requires `bx_le`-linearity between two MCSes, which no formula-level axiom can force on the partial order `g_content ⊆`.
- **Recommendation**: Abandon the axiom-strengthening path. The obstruction is not a missing axiom but a structural mismatch between the `bx_le` definition (G-content inclusion) and the Until truth lemma's requirements (Until-formula propagation). Tasks 97 (layered `bx_le` redefinition) and 98 (filtration/quasimodel pivot) are the viable escape hatches.

## Context & Scope

### What was researched

Whether one or more new BX axioms (BX13, BX14, ...) can be added to the axiom system to close:
- **Gap U5** (forward): Propagation of `φ U ψ` (or derived guard `φ`) along the `bx_le`-interval `(w, v)` to satisfy the universal guard `∀ u, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas`
- **B-GAP** (backward): Establishing `bx_le w u'` for a backward witness `u'` obtained from `P(¬(φ U ψ)) ∈ v`

### Constraints

- Axioms must be **sound on all linear temporal orders** (the frame class for BX)
- READ-ONLY: no modifications to `Theories/` source files
- The Until semantics are: `φ U ψ` at `(τ, t)` iff `∃ s ≥ t, ψ(s) ∧ ∀ r, t ≤ r → r < s → φ(r)`
- The Since semantics are: `φ S ψ` at `(τ, t)` iff `∃ s ≤ t, ψ(s) ∧ ∀ r, s < r → r ≤ t → φ(r)`

### The fundamental obstruction (proved below)

For Gap U5, any axiom that could close the sorry would need to derive `G(φ)` or `G(φ U ψ)` from `(φ U ψ) ∧ ¬ψ` (or some variant). But:

1. `G(φ U ψ)` means `φ U ψ` at ALL future times, including times beyond the witness `s`. At `t' > s`, there is no semantic guarantee that any future time satisfies `ψ`, so `φ U ψ` can fail. Therefore `(φ U ψ) → G(φ U ψ)` is **unsound**.

2. `G(φ)` means `φ` at ALL future times. The Until semantics only guarantee `φ` on `[t, s)`. At `t' ≥ s`, `φ` is unconstrained. Therefore `(φ U ψ) ∧ ¬ψ → G(φ)` is **unsound**.

3. Any weaker form `(φ U ψ) → G(χ)` where `χ` entails `φ` (needed for the guard) inherits the same problem: `χ` must hold at ALL future times, but Until only constrains a bounded interval.

This is a **semantic impossibility**, not a gap in the axiom inventory. No sound axiom can convert bounded-interval information into unbounded-interval guarantees.

---

## Findings

### Candidate 1: G-Until lift

**Formal statement**: `(φ U ψ) → G((φ U ψ) ∨ ψ)`

**Soundness analysis**: UNSOUND.

**Countermodel**: Take `D = ℤ` (integers), atoms `p, q`.
- Valuation: `p` true at times `{0, 1}`, `q` true only at time `{2}`, both false elsewhere.
- At `t = 0`: `p U q` holds (witness `s = 2`, guard: `p` at `0, 1`).
- At `t' = 3`: `q(3)` is false. `p U q` at `3` requires some `s' ≥ 3` with `q(s')` -- none exists. So `(p U q) ∨ q` is false at `3`.
- Therefore `G((p U q) ∨ q)` fails at `t = 0`.

**Close-verdict**: N/A (unsound).

**Classification**: **unsound + countermodel**

---

### Candidate 2: Self-accumulation persistence (G-wrapped BX5)

**Formal statement**: `(φ U ψ) → G((φ U ψ) → ((φ ∧ (φ U ψ)) U ψ))`

**Soundness analysis**: SOUND.

BX5 (`(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`) is valid at every time point on every linear order. The G-wrapper `G(α)` for a universally valid `α` is also universally valid (since `α` holds at every time, `∀ t' ≥ t, α(t')` is trivially true). Therefore this axiom is sound on all linear orders.

However, this axiom is **already derivable** from the existing system. Since BX5 is a theorem, temporal necessitation (which is an admissible rule, validated by `generalized_temporal_k` in the codebase) gives `G(BX5)` as a theorem. No new axiom is needed.

**Close-verdict**: Does NOT close any sorry. The axiom states that BX5 applies at every future time -- but the gap is not about whether BX5 can be applied at `u`, it's about whether `φ U ψ` can be **transported** to `u.formulas` in the first place. `G((φ U ψ) → ...)` in `w.formulas` gives the implication `(φ U ψ) → ...` at every `u` with `bx_le w u`, but the antecedent `(φ U ψ) ∈ u.formulas` is exactly what we cannot establish.

**Classification**: **sound + does-not-close** (and already derivable)

---

### Candidate 3: Until forward persistence

**Formal statement**: `(φ U ψ) → ((φ U ψ) U ψ)`

**Soundness analysis**: SOUND.

Proof: Suppose `φ U ψ` at `t`. Then ∃ `s ≥ t` with `ψ(s)` and `φ` on `[t, s)`. We need `((φ U ψ) U ψ)` at `t`: ∃ `s' ≥ t` with `ψ(s')` and `(φ U ψ)` on `[t, s')`.

Take `s' = s`. Then `ψ(s)` holds. For any `r ∈ [t, s)`: `(φ U ψ)` at `r` holds because the same witness `s` works -- `ψ(s)` and `φ` on `[r, s) ⊆ [t, s)`. QED.

This is a novel observation: Until is "self-persistent" on its own guard interval. The formula `(φ U ψ) U ψ` says "the eventuality `φ U ψ` itself persists until `ψ` is realized."

**Close-verdict**: Does NOT close any sorry. While this gives `((φ U ψ) U ψ) ∈ w.formulas`, this is still an Until formula (not G-wrapped), so it does not enter `g_content(w)` and does not propagate via `bx_le`. The fundamental obstruction remains: Until formulas live in `w.formulas`, not in `g_content(w)`.

**Classification**: **sound + does-not-close**

---

### Candidate 4: Backward-witness locus axiom

**Formal statement**: `(φ U ψ) → G(P(¬(φ U ψ)) → (¬(φ U ψ) ∨ ψ))`

This axiom attempts to constrain backward witnesses of `¬(φ U ψ)` to lie where either `¬(φ U ψ)` or `ψ` holds, aimed at closing B-GAP.

**Soundness analysis**: UNSOUND.

**Countermodel**: Take `D = ℤ`, atoms `p, q`.
- `p` true at `{0, 1}`, `q` true at `{2}`, both false elsewhere.
- At `t = 0`: `p U q` holds (witness `2`, guard `p` at `0, 1`).
- Instantiate the axiom: at `t' = 1` (future of 0): `P(¬(p U q))` at `1` holds because at `t'' = -1`, `p U q` fails (no future `q` reachable from `-1` given `q` only at `2`... wait, actually `q` is at `2 ≥ -1` and we'd need `p` on `[-1, 2)`. `p(-1)` is false. So `¬(p U q)` at `-1`.). The antecedent `P(¬(p U q))` holds at `1`.
- The conclusion requires `¬(p U q) ∨ q` at `1`. `q(1)` is false. `p U q` at `1`? Witness `2 ≥ 1`, `q(2)`, guard: `p(1)` holds. So `p U q` holds at `1`, meaning `¬(p U q)` is false. And `q(1)` is false. So `¬(p U q) ∨ q` is false.
- The axiom's consequent `G(P(¬(p U q)) → (¬(p U q) ∨ q))` fails at `t' = 1`.

**Classification**: **unsound + countermodel**

---

### Candidate 5: Direct guard axiom (researcher-designed)

**Formal statement**: `(φ U ψ) ∧ ¬ψ → G(¬ψ → φ)`

This directly attempts to propagate the guard `φ` into `g_content` by claiming `φ` holds whenever `ψ` doesn't, at all future times.

**Soundness analysis**: UNSOUND.

**Countermodel**: Same model as Candidate 1. At `t = 0`: `p U q` and `¬q(0)`. At `t' = 3`: `¬q(3)` but `¬p(3)`. The conditional `¬q → p` fails at `3`.

This axiom fails because `φ` is only guaranteed on the guard interval `[t, s)`, not at all future times where `ψ` fails. After the witness `s`, there may be times where both `¬ψ` and `¬φ` hold.

**Classification**: **unsound + countermodel**

---

### Candidate 6: Until-Since connectedness (Burgess-Xu style)

**Formal statement**: `(φ U ψ) ∧ (χ S θ) → (φ U (ψ ∧ (χ S θ))) ∨ (χ S (θ ∧ (φ U ψ))) ∨ (ψ ∧ θ)`

This is the classical Until-Since interaction axiom that BX4's docstring explicitly disclaims.

**Soundness analysis**: This requires careful analysis. On a **linear order** with reflexive Until/Since:

- `φ U ψ` at `t`: witness `s ≥ t`, `ψ(s)`, `φ` on `[t, s)`.
- `χ S θ` at `t`: witness `r ≤ t`, `θ(r)`, `χ` on `(r, t]`.
- Compare `r` and `s` (linearly ordered):
  - If `r ≤ s` and `s ≤ t`... but `s ≥ t` and `r ≤ t`, so we compare `r` with `s` where `r ≤ t ≤ s`.
  - Since `r ≤ t ≤ s`: the witnesses are on opposite sides of `t`.

  For the first disjunct `φ U (ψ ∧ (χ S θ))`: need `χ S θ` at `s`. Witness would be `r ≤ t ≤ s`, `θ(r)`, `χ` on `(r, s]`. We know `χ` on `(r, t]` but need `χ` on `(t, s]` -- not guaranteed from the hypotheses.

  For the second disjunct `χ S (θ ∧ (φ U ψ))`: need `φ U ψ` at `r`. Witness `s ≥ t ≥ r`, `ψ(s)`, `φ` on `[r, s)`. We know `φ` on `[t, s)` but need `φ` on `[r, t)` -- not guaranteed.

  For the third disjunct `ψ ∧ θ`: need `ψ(t)` and `θ(t)`. Not guaranteed if `s > t` and `r < t`.

**Countermodel**: `D = ℤ`, atoms `p, q, a, b`.
- `p` true at `{0, 1}`, `q` true at `{2}`, `a` true at `{0}`, `b` true at `{-1}`.
- At `t = 0`: `p U q` (witness `2`, guard `p` at `0, 1`) and `a S b` (witness `-1`, guard `a` at `0`).
- Disjunct 1: `p U (q ∧ (a S b))` at `0`. Witness `2`: need `q(2) ∧ (a S b)(2)`. `(a S b)(2)` needs witness `r' ≤ 2` with `b(r')` and `a` on `(r', 2]`. `b(-1)`, `a` on `(-1, 2]` -- `a(1)` is false. Fails.
- Disjunct 2: `a S (b ∧ (p U q))` at `0`. Witness `-1`: need `b(-1) ∧ (p U q)(-1)`. `(p U q)(-1)` needs `q(s)` for `s ≥ -1` with `p` on `[-1, s)`. `s = 2`, but `p(-1)` false. Fails.
- Disjunct 3: `q(0) ∧ b(0)`. Both false.
- All three disjuncts fail. **UNSOUND** on this model.

Wait -- I need to verify more carefully. Is this actually unsound on linear orders, or is my countermodel flawed?

Actually, looking at the literature more carefully: the Burgess-Xu connectedness axiom has a different form. The standard Until-Since interaction in Burgess 1984 is:

`(φ S ψ) → ((φ S ψ) U ψ) ∨ G(φ S ψ)`

or equivalently, principles about how Until and Since witnesses interact on linear orders. The form I stated above may not be the standard one. Let me check whether the standard Burgess connectedness principle is sound.

The actual principle BX4 replaced is documented in `Axioms.lean:142-147` as "not valid under half-open guard semantics." The half-open guard means the Until guard is `[t, s)` (closed left, open right) and the Since guard is `(s, t]` (open left, closed right). This half-openness breaks the standard connectedness.

Regardless, this candidate is moot for our purposes: even if some form of Until-Since connectedness were sound, it would still be a formula-level principle living in `w.formulas`, not producing G-wrapped content for `g_content` propagation. It cannot close Gap U5 for the same structural reason as all other candidates.

**Classification**: **unsound + countermodel** (and would not close even if sound)

---

## Impossibility Argument

### Theorem (informal): No sound axiom over linear orders closes Gap U5.

**Proof sketch**:

Gap U5 requires: given `(φ U ψ) ∈ w.formulas` and `ψ ∉ w.formulas`, produce `φ ∈ u.formulas` for arbitrary `u` with `bx_le w u` (i.e., `g_content(w) ⊆ u.formulas`).

For `φ ∈ u.formulas` to follow from `g_content(w) ⊆ u.formulas`, we need `φ ∈ g_content(w)`, i.e., `G(φ) ∈ w.formulas`.

Any axiom deriving `G(φ)` from Until-premises must be of the form:
```
(φ U ψ) ∧ Γ → G(φ)    [or G(χ) where χ → φ is derivable]
```
where `Γ` consists of formulas derivable from the hypotheses.

Semantically, `G(φ)` at time `t` means `∀ t' ≥ t, φ(t')`. But `(φ U ψ)` at `t` only guarantees `φ` on `[t, s)` for some `s ≥ t`. For `t' ≥ s`, `φ(t')` is unconstrained.

Countermodel construction (for any such axiom): Take any `φ, ψ` and construct a linear model where:
- `φ U ψ` holds at `t = 0` with witness `s = 1`
- `φ(0)` holds (guard on `[0, 1)`)
- `ψ(1)` holds (witness)
- `φ(2)` is FALSE
- `Γ` holds at `0` (since `Γ` is derivable from available hypotheses in MCS `w`, it holds in any model satisfying those hypotheses)

Then `G(φ)` fails at `0` because `φ(2)` is false. Any axiom `(φ U ψ) ∧ Γ → G(φ)` is falsified.

The same argument applies to `G(χ)` for any `χ` that entails `φ`: make `χ(2)` false, which is possible since `χ` (like `φ`) is unconstrained beyond the Until witness.

**Corollary**: No sound axiom can close Gap U5 via the `g_content` propagation mechanism. The only way to close Gap U5 is to change what `bx_le` propagates (task 97) or to bypass the canonical model construction entirely (task 98). QED.

### Theorem (informal): No formula-level axiom closes B-GAP.

**Proof sketch**:

B-GAP requires: given `u'` with `bx_le u' v` (from backward witness), establish `bx_le w u'` (i.e., `g_content(w) ⊆ u'.formulas`).

This is a statement about the **partial order** `bx_le` -- specifically, that two MCSes `w` and `u'` are comparable. Comparability of `g_content(w) ⊆ u'.formulas` depends on the **global structure** of the MCS lattice, not on any single formula in `w.formulas`.

A formula-level axiom adds formulas to MCSes. It can ensure certain formulas appear in `w.formulas` (and hence in `g_content(w)` if G-wrapped). But `bx_le w u' = g_content(w) ⊆ u'.formulas` requires **every** formula in `g_content(w)` to be in `u'`. A new axiom cannot guarantee this for an arbitrary Lindenbaum-constructed MCS `u'` unless the axiom somehow forces the entire canonical model to be linearly ordered -- which would require `bx_le` linearity, empirically shown to be unprovable from the BX axiom set (task 90, report 08). QED.

---

## Lean MCP Probe Results

### Probe at Frame.lean:653 (Gap U5, forward Until)

Goal after `simp [bx_le, g_content]`:
```
⊢ ∃ v,
    {phi | phi.all_future ∈ w.formulas} ⊆ v.formulas ∧
      ψ ∈ v.formulas ∧
        ∀ (u : BXPoint),
          {phi | phi.all_future ∈ w.formulas} ⊆ u.formulas →
            {phi | phi.all_future ∈ u.formulas} ⊆ v.formulas →
              ¬{phi | phi.all_future ∈ v.formulas} ⊆ u.formulas → φ ∈ u.formulas
```

This makes the gap explicit: the guard requires `φ ∈ u.formulas` when only `{phi | phi.all_future ∈ w.formulas} ⊆ u.formulas` is available. To close this, `φ.all_future` (i.e., `G(φ)`) would need to be in `w.formulas` -- which requires a sound derivation of `G(φ)` from `(φ U ψ) ∈ w.formulas`, shown impossible above.

After building the forward witness via BX10 + `bx_forward_witness`:
```
⊢ φ ∈ u.formulas
```
with hypotheses `bx_le w u`, `bx_le u v`, `¬bx_le v u`. No tactic (`exact?`, `aesop`, custom BX5/BX7/BX4 constructions) closes this.

### Probe at Frame.lean:675 (B-GAP, backward Until)

Goal: `⊢ φ.untl ψ ∈ w.formulas` with `bx_le w v`, `ψ ∈ v.formulas`, guard hypothesis, `ψ ∉ w.formulas`. `exact?` and `aesop` both fail. The standard contradiction approach via BX4 yields `P(¬(φ U ψ)) ∈ v` but cannot link the backward witness back to `w`.

### Probes at Frame.lean:690, 704 (Since mirrors)

Identical structure to the Until cases, with `bx_le` direction reversed. `exact?` and `aesop` both fail. Since mirrors inherit all obstructions from the Until case and additionally suffer the guard-interval asymmetry documented in Phase 0 Probe 6.

---

## Ranked Shortlist

### Sound + Closes: NONE

No candidate axiom was found that is both sound and closes any of the four sorries. The impossibility argument shows this is a categorical result, not an artifact of insufficient search.

### Sound + Does-Not-Close

| Rank | Candidate | Value |
|------|-----------|-------|
| 1 | Until forward persistence: `(φ U ψ) → ((φ U ψ) U ψ)` | Novel, captures self-persistence of Until on its guard interval. Potentially useful for other proof strategies but cannot bridge the `g_content` gap. |
| 2 | G-wrapped BX5: `(φ U ψ) → G((φ U ψ) → ((φ ∧ (φ U ψ)) U ψ))` | Already derivable from existing system. No new information. |

### Unsound + Countermodel

| Candidate | Countermodel |
|-----------|-------------|
| G-Until lift: `(φ U ψ) → G((φ U ψ) ∨ ψ)` | ℤ, `p`@{0,1}, `q`@{2}, fails at `t'=3` |
| Backward-witness locus: `(φ U ψ) → G(P(¬(φ U ψ)) → ¬(φ U ψ) ∨ ψ)` | ℤ, `p`@{0,1}, `q`@{2}, fails at `t'=1` |
| Direct guard: `(φ U ψ) ∧ ¬ψ → G(¬ψ → φ)` | ℤ, `p`@{0,1}, `q`@{2}, fails at `t'=3` |
| U-S connectedness (BX4 replacement) | ℤ, countermodel above + BX4 docstring disclaimer |

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| This negative result applies only to the `g_content` propagation mechanism; a restructured `bx_le` (task 97) could make axiom-strengthening viable again | Medium | Task 97 should evaluate whether a layered `bx_le` definition makes Until-formula propagation possible, in which case Until forward persistence (Candidate 3) may become useful |
| The impossibility argument is informal; a formal Lean proof of "no sound axiom of shape X closes Y" would be more definitive | Low | The countermodels are concrete and verifiable; the informal proof is mathematically rigorous |
| The Since-mirror asymmetry (Phase 0 Probe 6) means even if an Until axiom were found, Since would need independent treatment | Medium | Already documented; task 92's revised plan should account for this |

---

## Recommendation

**Abandon the axiom-strengthening path for task 92.** The impossibility is structural:

1. **Gap U5 is unclosable by any sound axiom** because Until semantics provide bounded-interval information (`φ` on `[t, s)`) while `g_content` propagation requires unbounded-interval information (`G(φ)`, i.e., `φ` on `[t, ∞)`). No sound logical manipulation bridges this semantic gap.

2. **B-GAP is unclosable by formula-level axioms** because it requires `bx_le`-linearity (a property of the MCS partial order), which no formula-level axiom can force.

3. The one sound novel axiom discovered (Until forward persistence, Candidate 3) is mathematically interesting but cannot help with the `g_content` propagation mechanism.

**Task 92 should prioritize**:
- **Task 97** (layered `bx_le` redefinition): Most promising. If `bx_le` is redefined to propagate Until-formulas (not just G-formulas), the gap disappears by construction. The challenge is preserving the Box/G/H truth lemmas.
- **Task 98** (filtration/quasimodel pivot): More radical but may be necessary if task 97 finds no viable layered definition.

This negative result is scientifically valuable: it definitively closes one of the three escape hatches, allowing task 92 to focus resources on the remaining two.

---

## Appendix

### Search Queries Used

| Tool | Query | Result |
|------|-------|--------|
| `lean_local_search` | `until_forward` | 0 hits |
| `lean_local_search` | `bx_G_forward` | 1 hit (existing theorem) |
| `lean_local_search` | `g_content_propagate` | 1 hit (Boneyard, deprecated) |
| `lean_local_search` | `box_preserved` | 1 hit (existing theorem) |
| `lean_local_search` | `until_imp` | 4 hits (none propagate along bx_le) |
| `lean_leansearch` | "Until operator persistence along temporal ordering in canonical model" | 0 relevant hits |
| `lean_multi_attempt` at `:653` | `exact?`, `aesop`, `simp`, BX5/BX10 skeleton | All fail |
| `lean_multi_attempt` at `:675` | `exact?`, `aesop`, by_contra + BX4 skeleton | All fail |
| `lean_multi_attempt` at `:690` | `exact?`, `aesop` | Both fail |
| `lean_multi_attempt` at `:704` | `exact?`, `aesop` | Both fail |

### References

- `Theories/Bimodal/ProofSystem/Axioms.lean` — BX1-BX12 definitions (37 constructors)
- `Theories/Bimodal/Semantics/Truth.lean:128-131` — Until/Since truth definitions
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:585-706` — Four sorries and documentation
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:61` — `g_content` definition
- `specs/092_implement_bx_until_truth_lemma/reports/03_phase0-diagnostic.md` — Phase 0 probes
- `specs/092_implement_bx_until_truth_lemma/reports/04_spawn-analysis.md` — Root cause analysis
- `specs/092_implement_bx_until_truth_lemma/reports/02_team-research.md` — Team research synthesis
- Burgess 1984, "Basic tense logic" — canonical model construction
- Goldblatt 1992, "Logics of Time and Computation" — Until/Since completeness
