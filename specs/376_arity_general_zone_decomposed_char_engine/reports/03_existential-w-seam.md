# Task 376 — Existential-`w` / Single-Witness Completeness Seam Certification

**Session**: sess_1784138518_4af6d5 · **Agent**: lean-research-hard-agent (H2/H3/H4) · **Date**: 2026-07-15
**Mode**: lean4 `--hard --lit` · bounded certification probe (Phase-1-style refutation-or-clearance)
**Focus**: certify existential-`w` single-witness completeness seam
**Machine artifact**: `specs/376_arity_general_zone_decomposed_char_engine/reports/03_existential-w-probe.lean`
— compiled `lake env lean`, exit 0. Three refutation theorems, all axiom-clean
(`#print axioms` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`); one elaboration
`example` (`sorry`-bodied by design, the signature-elaboration artifact bar).

---

## VERDICT: **REFUTED**

**The existential-`w` / single-witness completeness seam is NOT dischargeable.** It is genuinely
refutation-safe *at the point of use* (`step_complete` fires the seam at exactly one `w`, verified
below) and it *preserves exclusion-dischargeability* (the seam's only body-use is single-`w`). But
the `∀ w → ∃ w` weakening does **not** escape the cross-render refutation — it merely relocates it
one level up, to the discharge obligation `∃ w, render(w) ∧ iff_at(w)`, where **render-symmetry
(order-automorphism invariance) collapses the `∃` back onto the `∀`-orbit** and re-supplies the
second iff for free. The existential form dies in the same order-homogeneous models, under the
**identical** residual assumption reports/02 already isolated. No new assumption reduces the burden.

This is the **third** distinct additive-seam design machine-refuted under the frozen-surface
constraint:

| Design | Where it dies |
|--------|---------------|
| Guard BOTH A and B (Phase-2 plan) | Block A guard breaks the 7 exclusion sites (Phase-2 blocker) |
| Split-seam: guard B, unguard A (reports/02) | Unguarded `∀ w` Block A refuted by cross-render (`unguardedBlockA_crossRender_refutation`) |
| **Existential-`w` / single-witness (this audit)** | **`∃ w, render ∧ iff_at(w)` refuted by render-symmetry (`existentialSeam_form_refuted`)** |

Because three additive designs over the frozen carrier are now down, the mandated
`## Frozen-Constraint Assessment` (below) is the operative deliverable: the frozen-surface
constraint itself is what forces the contradiction. This is an architectural decision that only
the user can authorize — this dispatch does not, and must not, edit a frozen surface to escape it.

---

## The compiled refutation

### The two structural facts that make the candidate *look* safe (both verified)

1. **`step_complete` is single-`w`.** `bracketEndChar_kvFib_step_complete` (IGGK:1769) takes
   `(∃ w, render(w))` as its antecedent (IGGK:1783), destructures it (`rintro ⟨w, hw⟩`, IGGK:1785),
   and applies the seam ONCE: `have hchar := hcharFib w hw` (IGGK:1799). A source scan confirms
   `hcharFib` occurs in the body at exactly ONE line (1799); every one of the 14 downstream uses —
   including the 7 frozen-carrier exclusion sites (IGGK:1932, 1946, 1968, 1984, 2009, 2022, 2046) —
   goes through the single-`w` `hchar σ _`, never through `hcharFib` at a second `w`.

2. **Exclusion-dischargeability is preserved.** Folding the `(∃ w, render(w))` antecedent and the
   separate `hcharFib : ∀ w, render → iff` binder into ONE existential antecedent
   `∃ w, render(w) ∧ (∀ σ u, iff_at(w))` lets the body re-thread verbatim: `rintro ⟨w, hw, hchar⟩`
   yields `hchar` of the SAME type as the former `have hchar := hcharFib w hw`, so the 7 exclusion
   sites discharge byte-for-byte. The re-signed signature `ELABORATES` in the production context —
   probe `example existentialW_step_complete_elaborates` (line 170, `sorry`-bodied by design).

These two facts are exactly why reports/02 recommended this candidate. They are true. They are not
enough.

### `crossRender_from_two_iffs` (probe, sorry-free) — the collision, decoupled from `∀ w`

Reports/02 `Theorem 1` restated with the completeness iff supplied at TWO explicit render points
`w0 ≠ w'` (relative to shared anchors `x,t`) instead of extracted from a `∀ w` binder:

```
iff_w0 : ∀ σ u, temporal_truth u (charFib σ) ↔ nf_eval[u,w0,x,t] σ
iff_w' : ∀ σ u, temporal_truth u (charFib σ) ↔ nf_eval[u,w',x,t] σ
⟹ False
```

Mechanism verbatim from reports/02: diagonal fiber `σ* := char[w',w0,x,t]`, shared point `u := w'`.
`iff_w0.mpr` forces `truth(w', charFib σ*)` TRUE (RHS is `σ*` at its own tuple); `iff_w'.mp` forces
`nf_eval[w',w',x,t] σ*` TRUE; but `σ*`'s order bit `(w'?w0)` demands `w' < w'` over the diagonal —
`lt_irrefl`.

### `existentialSeam_refuted_of_render_symmetry` (probe, sorry-free) — the surviving refutation

The single-`w` form supplies `iff_w0` at ONE render. The seam quantifies over ALL
`M : OrderedMonadicStructure sig` with **no rigidity restriction** (binder read at EGA:571,
IGGK:1776, KampPrior:1070 — all quantify `M` freely). That range CONTAINS order-homogeneous models
(e.g. `(ℚ,<)`). In such an `M`, an order-automorphism `α` fixing `x,t` with `α(w0)=w'` — a SECOND
render, `w'≠w0` — **transports** `iff_at(w0)` to `iff_at(w')`:

- `temporal_truth M atomMap u (charFib σ)` is the truth of a FIXED formula, so it is
  automorphism-invariant: `truth(u, φ) ↔ truth(α u, φ)`.
- `nf_eval_nf` is built from `atom_eval` (order + `interp`), both `α`-preserved, so
  `nf_eval[u,w0,x,t] σ ↔ nf_eval[α u, w', x, t] σ`.
- Composing (substitute `u ↦ α⁻¹ v`) turns `iff_at(w0)` into `iff_at(w')`.

The probe takes this transport as the hypothesis `htransport` and closes via
`crossRender_from_two_iffs`. Because homogeneity supplies BOTH the distinct render `w'` AND the
automorphism, the `∀→∃` weakening buys nothing.

### `existentialSeam_form_refuted` (probe, sorry-free) — the candidate, refuted directly

The packaged candidate seam `∃ w, render(w) ∧ iff_at(w)` (`hExist`), given a render-symmetry
supplier `hSym` (for any render `w`, a distinct render `w2` exists to which the iff transports),
reduces to `False`. Destructure the existential witness `w0`; `hSym` yields `w' ≠ w0` and the
transport; `crossRender_from_two_iffs` closes it.

### Disclosed residual (H4, identical to reports/02)

`htransport` / `hSym` (render-symmetry via order-automorphism) is the **single non-compiled leg**,
exactly the `(ℚ,<)` automorphism-invariance reports/02 flagged (its `hchar_eq` non-vacuity). It is
discharged by the density-homogeneity automorphism of `(ℚ,<)` fixing `(-∞,t]` pointwise and moving
`w0↦w'`, together with the routine formula-induction that `temporal_truth` is automorphism-invariant.
It does not soften the verdict: the seam's `∀ M` range **provably contains** a homogeneous model
where two distinct renders exist and the automorphism acts, so a uniform discharge is impossible —
the same standard reports/02's accepted REFUTED rests on.

---

## Why the `∀→∃` weakening cannot work — root cause

The refutation of the `∀ w` form (reports/02 Theorem 1) proved `iff_at(w0) ∧ iff_at(w') → False`:
in a homogeneous model, the completeness iff holds at **at most one** render. The existential asks:
does it hold at **at least one**? The answer is **no**, and the reason is symmetry, not counting:

- `charFib σ` is a `w`-independent formula, so `{u : truth(u, charFib σ)}` is a FIXED set,
  invariant under any anchor-fixing automorphism `α`.
- If `iff_at(w0)` held, that fixed set would equal the `w0`-fiber of `nf_eval`. Applying `α`
  (which fixes the set, fixes `x,t`, and moves `w0↦w'`) forces it to ALSO equal the `w'`-fiber —
  i.e. `iff_at(w')` holds too.
- Two iffs → `False`. So it holds at NEITHER render.

The `w`-independence that makes the seam refutation-safe at a single application (only one `w` in
scope) is the SAME `w`-independence that makes it undischarge-able at a specific render (the fixed
truth-set cannot single out one render's fiber when the model is symmetric across renders). The two
properties are two faces of one fact; you cannot have one without the other.

---

## Frozen-Constraint Assessment

**Is there ANY additive `*Fib`-sibling seam that is simultaneously refutation-safe AND discharges
the 7 frozen-carrier exclusion obligations, without editing a FROZEN surface? — No. The
frozen-surface constraint itself forces the contradiction.**

Root-cause chain, source-verified:

1. **The 7 exclusion obligations require the `.mp` transport at a specific render.** Each
   `| false =>` exclusion branch (IGGK:1932, 1946, 1968, 1984, 2009, 2022, 2046) fires
   `(hchar σ pt).mp hch : nf_eval[pt, w, x, t] σ` from `hch : temporal_truth pt (charFib σ)`, on an
   UNMARKED σ, to contradict a false fold bit. This is the `truth → nf_eval-at-the-render-`w``
   direction.

2. **`charFib` is frozen-`w`-independent.** The carrier exclusion predicates that GENERATE these
   obligations — `igPtWFib`, the `igSeg*/igEp*/igPtW*` family (FROZEN carrier trio:
   `Base/CarrierK1V/CarrierKv.lean`; `bracketEndChar_kv` defeq bridges IGGK:339-351,
   CarrierKv:294-351) — consume `charFib (k+1)` as a `w`-independent family (EGA:583-608 threads
   `(charFib (k+1))` with no `w` argument). So `temporal_truth pt (charFib σ)` is a `w`-agnostic
   truth value.

3. **The required direction is exactly the refutable one.** Transporting a `w`-agnostic truth to a
   `w`-SPECIFIC realization `nf_eval[pt,w,x,t] σ` is precisely the direction Theorem 1 /
   `existentialSeam_form_refuted` prove is false across renders in homogeneous models. Any additive
   seam over the frozen `w`-independent `charFib` inherits this refutable `.mp` direction — guarding
   it away (Phase-2) removes the direction the exclusions need; leaving it (`∀ w` or `∃ w`) is
   refuted.

4. **The only structural escape edits a frozen surface.** Making the transport refutation-safe
   requires `w`-indexing the char family (`charFib w σ`, so each render gets its own formula and
   cross-render transport is ill-typed by construction — reports/02 candidate #2). But `igPtWFib`
   and the `igSeg*` carriers are typed on the `w`-independent `charFib (k+1)`; re-indexing changes
   their type — an edit to the FROZEN carrier trio. Likewise reworking the exclusion argument to
   avoid the `.mp` transport (reports/02 #3) touches the frozen `igSeg*/igEp*/igPtW*` predicates
   where the obligation originates.

**Conclusion for the user (architectural, not an edit this dispatch may make):** the arity-4
completeness char seam cannot be discharged by any additive `*Fib` sibling while `charFib` remains
the frozen `w`-independent family. The exclusion obligations fundamentally require the `.mp`
transport at a specific render, and that transport is refutable exactly as long as the carrier
predicate (hence `charFib`) is `w`-independent (frozen). The contradiction is a property of the
frozen boundary, not of any particular seam signature. **The decision the user must authorize is
one of:**

- **(A) Unfreeze to `w`-index the char engine** — re-type `charFib`/`igPtWFib`/`igSeg*` to carry
  the anchor `w` (reports/02 #2). Refutation-safe by construction; but edits the frozen carrier
  trio and re-threads the whole `*Fib` chain + the engine that builds `charFib`. Largest blast
  radius; the only route that makes the char seam anchor-aware.
- **(B) Rework the exclusion argument off the `.mp` transport** (reports/02 #3) — also touches the
  frozen `igSeg*/igEp*/igPtW*` origin of the obligations.
- **(C) Restrict the model class** — add a rigidity / render-uniqueness hypothesis to the seam's
  `∀ M` (removing homogeneous models from range). This makes the `∃ w` form dischargeable
  (unique render ⟹ no symmetry ⟹ `iff_at` at that render is classical char-correctness), but it
  weakens the completeness theorem's model class and must be checked against the downstream
  soundness/completeness statement's intended generality. Least code-invasive; changes the theorem.

Only the user can choose among (A)/(B)/(C); each trades blast radius against theorem generality.
This dispatch's finding is that no zero-frozen-edit additive seam exists — not that one route is
best.

---

## Landed assets — status under this REFUTED (unchanged from reports/02)

The refutation is confined to Block A (completeness). It does not touch the Phase-2 green milestone
(`3b75fc880`) or the Phase-1 CLEARED soundness result:

- Guarded soundness **Block B** (`ZoneSeamCrossContextProbe.lean`,
  `crossContext_wGate_blocks_attack`) — CLEARED, unaffected.
- `bracketEndChar_kvFib_realize_{futT,pastX}` (zone-guarded, IGGK) and `kampPrior_hreal_supply`
  (via public `ext3_zoneHolds_cons_iff`) — consistent with the guarded soundness seam, survive
  regardless of how Block A is redesigned. KampPrior census stays exactly 2 sorries (:519, :522).

No re-implementation of these is needed under any of routes (A)/(B)/(C).

---

## Reference grounding (Tier 1)

| Source | Prop / Location | Lean identifier | Type signature / fact | Status |
|--------|-----------------|-----------------|-----------------------|--------|
| Original completeness seam | `ExteriorGateAssembleK.lean:574-578` | `hcharFib` binder (in `correct_prior`) | `∀ w, render(w) → ∀ σ u, temporal_truth u (charFib σ) ↔ nf_eval[u,w,x,t] σ` | `lean_goal`/Read-confirmed, byte-mirrored into probe |
| Completeness consumer (single-`w`) | `InteriorGateGeneralK.lean:1769-1799` | `bracketEndChar_kvFib_step_complete` | antecedent `(∃ w, render(w))`, destructured :1785, seam used ONCE :1799 | Read-confirmed (grep: `hcharFib` body-occurrences = {1799}) |
| Exclusion sites (7) | `IGGK:1932,1946,1968,1984,2009,2022,2046` | `hsegL/hsegR/hepL/hepR/hptW` `\| false =>` | `(hchar σ pt).mp hch` — `truth → nf_eval-at-render-w`, unmarked σ | Read-confirmed |
| Discharge thread (never discharges) | `KampPrior.lean:1058-1181` | `kampPrior_site_rungKFib_gate_match` | threads `hcharFib` into `correct_prior` (:1174), does NOT discharge | Read-confirmed |
| `∀ M` range (no rigidity) | EGA:571, IGGK:1776, KampPrior:1070 | `(M : OrderedMonadicStructure sig)` | free `∀ M`; homogeneous models in range | Read-confirmed |
| Cross-render collision | reports/02 `Theorem 1` | `crossRender_from_two_iffs` (probe) | `iff_w0 ∧ iff_w' → False` | **compiled sorry-free, axiom-clean** |
| Existential refutation | this report | `existentialSeam_form_refuted` (probe) | `∃w(render∧iff) + render-symmetry → False` | **compiled sorry-free, axiom-clean** |
| Re-signed seam signature | this report | `existentialW_step_complete_elaborates` (probe) | existential-antecedent `step_complete` | **elaborates** (sorry-bodied artifact bar) |
| nf semantics | `NormalForm.lean:198-227` | `nf_eval_nf`, `nf_characteristic`, `nf_characteristic_satisfies`, `nf_eval_nf_atom_layer` | recursive atom+existential match | Read-confirmed + used in probe |
| Render-symmetry residual | reports/02 §Non-vacuity | `(ℚ,<)` automorphism | `α` fixes `(-∞,t]`, moves `w0↦w'`; `temporal_truth`/`nf_eval` α-invariant | argued, single non-compiled leg (disclosed) |
| §Q2.3 family = this attack | report 01 §Q2.3 | cross-context `(w,x,t)` vs `(w',x,t)` | the two-anchor transport; generalized by render-symmetry here | corroborated |

---

## Adversarial Self-Verification

Attacking the REFUTED verdict hardest (per H4 — the risk here is a FALSE refutation that wrongly
closes a viable design; but note the symmetric risk of a FALSE clearance is the one that has burned
three prior designs, so the bar is calibrated to catch optimism).

| Claim | Source/Counterexample |
|-------|------------------------|
| The cross-render collision holds from two explicit iffs (no `∀ w` needed) | `crossRender_from_two_iffs`, probe compiled `lake env lean` exit 0, `#print axioms` = `[propext, Classical.choice, Quot.sound]` (no `sorryAx`) |
| The existential seam form `∃ w, render ∧ iff_at(w)` reduces to `False` under render-symmetry | `existentialSeam_form_refuted`, compiled sorry-free, axiom-clean |
| `step_complete` uses the seam at exactly one `w` (so the form IS refutation-safe at the use site, and exclusions DO discharge) | grep of IGGK:1769-2110: `hcharFib` body-occurrences = {1799 only}; 14 downstream uses all via single-`w` `hchar` |
| The re-signed existential `step_complete` signature elaborates | `existentialW_step_complete_elaborates` elaborates (probe compiles; the only `sorry` is this intended elaboration artifact, warning line 170) |
| The seam's `∀ M` range contains homogeneous models (so the refutation bites the discharge, not a pathology) | binder read EGA:571, IGGK:1776, KampPrior:1070 — free `∀ M : OrderedMonadicStructure sig`, no rigidity; `(ℚ,<)` ∈ range |
| Render-symmetry transport `iff_at(w0) → iff_at(w')` is valid | `temporal_truth` of a FIXED formula and `nf_eval_nf` (built from `atom_eval` = order+interp) are automorphism-invariant; `α` fixes `x,t`, moves `w0↦w'` — standard modal-truth automorphism invariance |
| The `∀→∃` weakening reduces NO assumption | the residual (`htransport`/`hSym`) is the SAME `(ℚ,<)` automorphism leg reports/02's `∀`-form refutation rested on; homogeneity supplies both the distinct render and the transport |
| No zero-frozen-edit additive seam is both refutation-safe and exclusion-dischargeable | root-cause chain §Frozen-Constraint Assessment steps 1-4: the `.mp` transport the exclusions need is refutable exactly while `charFib` is frozen-`w`-independent; escape routes (A)/(B) edit frozen carriers, (C) changes the theorem |

**Contradiction Log.**
1. **reports/02 recommendation ("existential-`w` is the least-invasive path, probe it first;
   dischargeable — no cross-`w` promise") vs. this audit (REFUTED).** RESOLVED against the reports/02
   recommendation (precedence: compiled probe > prior recommendation). reports/02 correctly saw that
   `step_complete` is single-`w` and that the FORM is refutation-safe at the use site — both true. It
   did NOT account for render-symmetry re-supplying the second iff at the DISCHARGE level: the `∃ w`
   discharge over the free `∀ M` range must hold in homogeneous models, where the automorphism
   collapses `∃` onto the `∀`-orbit. reports/02 itself flagged "dischargeable" as UNVERIFIED ("for
   the next research/plan dispatch, NOT part of the verdict") — this dispatch IS that verification,
   and it returns REFUTED.

2. **"Refutation-safe at the use site" vs. "REFUTED".** NOT a contradiction, RESOLVED by level
   separation: the seam FORM is refutation-safe where `step_complete` USES it (one `w`), and the
   exclusions DO discharge — but the DISCHARGE obligation `∃ w, render ∧ iff_at(w)`, proven one level
   up over `∀ M`, is false. The verdict is about dischargeability of the whole design, which is the
   binding question for the plan.

**Residual (non-compiled) leg, disclosed:** render-symmetry (`(ℚ,<)` automorphism-invariance of
`temporal_truth`/`nf_eval_nf`). Argued, not compiled — a routine formula-induction plus an explicit
`(ℚ,<)` order-iso, out of scope for a bounded dispatch and IDENTICAL to reports/02's disclosed
residual. It does not affect the verdict: the seam's `∀ M` range demonstrably contains a homogeneous
model with two renders and an anchor-fixing automorphism between them. If the user wants this leg
compiled before acting on the Frozen-Constraint Assessment, that is a ~1-phase EF/automorphism probe
(`temporal_truth` α-invariance + a `(ℚ,<)` render pair) — but it is not required to conclude REFUTED.

---

## References

- `specs/376_.../reports/03_existential-w-probe.lean` — this session's compiled artifact
  (`crossRender_from_two_iffs`, `existentialSeam_refuted_of_render_symmetry`,
  `existentialSeam_form_refuted`, `existentialW_step_complete_elaborates`)
- `specs/376_.../reports/02_split-seam-certification.md` + `02_split-seam-probe.lean` — the `∀ w`
  refutation this builds on (`unguardedBlockA_crossRender_refutation`, Theorem 1)
- `specs/376_.../reports/01_zone-decomposed-seam-interface.md` §Q2.2 (Gap A homogeneity), §Q2.3
  (cross-context family = render-symmetry attack)
- `.../NfMultiAnchorBridge/InteriorGateGeneralK.lean:1769-2110` (`step_complete`, single-`w`,
  7 exclusion sites)
- `.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean:559-660` (`correct_prior`, `hcharFib` binder)
- `.../Kamp/KampPrior.lean:1058-1181` (`kampPrior_site_rungKFib_gate_match`, threads not discharges)
- `.../WeakCanonical/NormalForm.lean:198-227` (`nf_eval_nf`, `nf_characteristic`,
  `nf_eval_nf_atom_layer`)
