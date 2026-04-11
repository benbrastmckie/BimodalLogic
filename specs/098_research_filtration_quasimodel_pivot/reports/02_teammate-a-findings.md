# Teammate A Findings: bx_le Non-Totality Gap Analysis

- **Task**: 98 — Research filtration / quasimodel pivot for Until/Since truth lemma
- **Angle**: Primary — BX11 and bx_le totality
- **Artifact number**: 02a
- **Date**: 2026-04-10

---

## Key Findings

### 1. bx_le is Definitionally Incapable of Totality

`bx_le` is defined in `Frame.lean:61–62` as:

```lean
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas
```

This means `bx_le w v` holds iff `∀ φ, G(φ) ∈ w.formulas → φ ∈ v.formulas`. The relation says nothing at all about formulas that are NOT of the form `G(φ)`. In particular:

- If `p ∈ w.formulas` (where `p` is an atom) but `G(p) ∉ w.formulas`, then `bx_le w v` gives no information about whether `p ∈ v.formulas`.
- Two MCSs can simultaneously satisfy: `G(p) ∈ w`, `p ∉ v`, `G(q) ∈ v`, `q ∉ w` (for distinct atoms `p`, `q`). Then `¬bx_le w v` AND `¬bx_le v w`, so `bx_le` is provably not total.

This is a structural limitation of the definition — no amount of axioms about `G` or `F` changes this, because MCS construction (Lindenbaum) can always independently assign arbitrary formulas not of the form `G(χ)`.

### 2. BX11 (temp_linearity) Does NOT Make bx_le Total

BX11 states:
```
F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)
```

This talks about **F-witnesses** being linearly ordered: if there is a future-φ-witness and a future-ψ-witness, at least one ordering relationship among them holds (they coincide, or the φ-witness precedes the ψ-witness, or vice versa).

At the MCS level, this means: for any MCS w, if `F(φ) ∈ w.formulas` and `F(ψ) ∈ w.formulas`, then one of the three F-disjuncts is also in `w.formulas`.

**Critical observation**: BX11 talks about F, but `bx_le` is defined via G. The relation between F and bx_le is:
- `bx_forward_witness` (Frame.lean:164–171): If `F(ψ) ∈ w`, there exists a BXPoint `v` with `bx_le w v` and `ψ ∈ v`.
- This gives **existential** witnesses, not totality of `bx_le`.

To derive `bx_le w v ∨ bx_le v w` (totality), we would need: either `g_content(w) ⊆ v.formulas` or `g_content(v) ⊆ w.formulas`. BX11 only tells us that future witnesses for different formulas are ordered; it says nothing about which of the two G-content inclusions holds. Even combining BX11 with BX12 (`F(φ) → ⊤ U φ`) does not bridge this gap, because the Until witnesses produced by BX12 are BXPoints with bx_le ordering from the current world, not a total order relation on all pairs of MCSs.

**Conclusion**: BX11 cannot be used to prove `bx_le` is total. The Realization.lean file's docstring (lines 26–33) is correct: "BX11 (temporal linearity) constrains F-witnesses to be ordered but does not force g_content inclusion to be total."

### 3. What BX11 Actually Gives at the MCS Level

Applying BX11 at an MCS `w`:

**If** `F(φ) ∈ w.formulas` and `F(ψ) ∈ w.formulas`, **then** one of:
1. `F(φ ∧ ψ) ∈ w.formulas` — there is a future point with both φ and ψ
2. `F(φ ∧ F(ψ)) ∈ w.formulas` — there is a future point with φ where ψ still holds in the further future
3. `F(F(φ) ∧ ψ) ∈ w.formulas` — there is a future point with ψ where φ still holds in the further future

Using `bx_forward_witness`, each disjunct gives an existential BXPoint. But these are witnesses for existential statements in `w`, not statements about the structure of `bx_le` between arbitrary pairs of points.

### 4. Why the Guard-Lifting Steps Fail

The 6 sorry locations are in two clusters:

**Cluster A — Eventuality resolution (sorries in `until_eventuality_resolution`, `since_eventuality_resolution`):**
The proof gets a backward witness `u'` with `bx_le u' u` and either `φ ∈ u'` or `ψ ∈ u'`. To discharge the guard (show `φ ∈ u`), we need to transfer a formula from `u'` to `u` across `bx_le u' u`. But `bx_le u' u` only says `g_content(u') ⊆ u.formulas`. Unless `φ = G(χ)` for some χ, or unless `G(φ) ∈ u'`, this gives nothing.

One could ask: does `φ U ψ ∈ u'` imply `G(φ) ∈ u'` somehow? No: `φ U ψ` is not a G-formula, and `G(φ U ψ)` is not provable from `φ U ψ` in BX. Furthermore, even if it were, that would give `φ U ψ ∈ u` (not `φ ∈ u`).

**Cluster B — Backward direction (sorries in `until_backward`, `since_backward`):**
The proof constructs a BXPoint `u` with `bx_le w u`, `bx_le u v`, and `¬(φ U ψ) ∈ u`. To apply the guard and derive a contradiction, we need `¬bx_le v u` (so the guard says `φ ∈ u`) and then use `φ ∈ u ∧ ¬(φ U ψ) ∈ u`. But even if `¬bx_le v u` held, `φ ∈ u ∧ ¬(φ U ψ) ∈ u` is NOT a contradiction in general: `φ` can hold at `u` while `φ U ψ` fails if `ψ` never arrives. The comment at Realization.lean:344 notes this: we also need `F(ψ) ∈ u`, and from `bx_le u v` and `ψ ∈ v` we CAN derive `F(ψ) ∈ u` (via `F_from_above`). But then BX7 (or BX12) would be needed to connect `F(ψ) ∈ u` with `φ U ψ ∈ u` — and that chain also fails without additional structure.

### 5. Is There a Weaker Property That Suffices?

The guard-lifting steps need, at minimum, one of:

**(A) Until-monotonicity / propagation**: Something like `(φ U ψ) ∈ u' ∧ bx_le u' u → φ U ψ ∈ u`. This would follow if `φ U ψ` were expressible as `G(χ)` for some χ (i.e., Until is "globally" true). It is NOT provable in BX.

**(B) A different canonical ordering** where the order relation propagates Until-formulas, not just G-formulas. This is the "restructured canonical model" option: define `bx_le` using Until-witness ordering so that the guard clause is directly encoded.

**(C) A formula φ ∈ u' implies G(φ) ∈ u'** (so that φ propagates). This would hold if u' were a "stable" world where everything in it also holds at all future worlds. But an arbitrary MCS is not of this form.

**(D) Totality of bx_le** (sufficient but likely false as shown above).

**(E) A finite quasimodel intermediate layer** where the ordering IS defined to be total/well-founded on a finite set of Hintikka points, and the Until/Since truth lemma is proved there, then lifted back. This is the quasimodel approach.

**(F) Additional axioms** (e.g., an Until-induction schema) that directly give closure of MCSs under Until-forward reasoning.

### 6. Why BX7 (linear_until) Also Doesn't Close the Gap

BX7 states:
```
(φ U ψ) ∧ (χ U θ) → ((φ ∧ χ) U (ψ ∧ θ)) ∨ ((φ ∧ χ) U (ψ ∧ χ)) ∨ ((φ ∧ χ) U (φ ∧ θ))
```

When applied with `φ U ψ` and `⊤ U ψ` (from BX12), this gives three sub-cases. The Realization.lean comment (lines 342–345) traces this: case 3 gives `φ U (φ ∧ (φ U ψ))`, which via BX6 (absorb_until) would give `φ U ψ`. So in principle, IF we can show that case 3 of the BX7 disjunction holds in the current context, we could derive `φ U ψ ∈ u` and contradict `¬(φ U ψ) ∈ u`.

The problem: BX7 gives a disjunction, but we cannot force case 3. The disjunction lands in an MCS, so one disjunct IS in `u.formulas`, but we don't know which one. Cases 1 and 2 give `φ U ψ` and `φ U ψ` respectively (both involve ψ as the goal), so actually ALL three cases give something useful... wait: let me check carefully.

BX7 with `φ U ψ` and `⊤ U ψ` (χ = ⊤, θ = ψ): the disjunction is:
- `(φ ∧ ⊤) U (ψ ∧ ψ)` = `φ U ψ` (case 1 — witnesses coincide)
- `(φ ∧ ⊤) U (ψ ∧ ⊤)` = `φ U ψ` (case 2 — first Before second, but since θ = ψ ∧ ⊤ = ψ at χ = ⊤, this is also `φ U ψ`)
- `(φ ∧ ⊤) U (φ ∧ ψ)` (case 3)

Only case 3 doesn't directly give `φ U ψ`. Cases 1 and 2 DO directly give `φ U ψ`. But the MCS disjunction might land in case 3 without giving `φ U ψ`. And `φ U (φ ∧ ψ) → φ U ψ` is provable by BX3 (right-monotonicity, since `φ ∧ ψ → ψ`). So actually **all three cases give `φ U ψ` by right-monotonicity**!

This is a potential path for the `until_backward` sorry: IF `F(ψ) ∈ u` (which CAN be derived via `F_from_above` from `bx_le u v` and `ψ ∈ v`), AND `bx_le u v` implies `φ U ψ ∈ u` via the BX7/BX12 chain, then the contradiction with `¬(φ U ψ) ∈ u` follows.

Let me trace this more carefully:
1. `F(ψ) ∈ u` from `F_from_above h_uv h_ψv` (this is proved in Realization.lean lines 342–343)
2. By BX12: `F(ψ) → ⊤ U ψ`, so `⊤ U ψ ∈ u`
3. We need `φ U ψ ∈ u`. But we only know `¬(φ U ψ) ∈ u` (that's what we're contradicting).
4. From `h_neg_until_u` and the goal is to derive a contradiction.

Hmm — the BX7 approach for `until_backward` would require: from `⊤ U ψ ∈ u` and `φ U ψ ∉ u`, derive a contradiction. The BX7 combination of `⊤ U ψ` and `φ U ψ` (but we don't have `φ U ψ ∈ u`!) so this does not directly work. What we DO have is from the guard (if `¬bx_le v u`): `φ ∈ u`. Then `φ ∈ u` and `F(ψ) ∈ u`:

Using BX7 with `⊤ U ψ` (which we have) and trying to get `φ U ψ`: BX7 needs TWO Until-formulas. We only have one (`⊤ U ψ`). The other Until formula would need to come from somewhere. So BX7 doesn't directly apply.

A different angle: from `φ ∈ u`, `F(ψ) ∈ u`, and BX12 giving `⊤ U ψ ∈ u`, and `refl_intro_until_mcs` giving `φ U ψ ∈ u` ONLY IF `ψ ∈ u`. But `ψ ∉ u` (we're in the `until_backward` proof where `h_not_psi` is given). So that doesn't work either.

The BX7/BX12 chain has promise but faces the same fundamental obstacle: we cannot derive `φ U ψ ∈ u` from `φ ∈ u` and `F(ψ) ∈ u` without an Until-induction axiom or equivalent.

---

## Recommended Approach

### Primary Recommendation: Local Hintikka Quasimodel (Confirm Report 01's Verdict)

The analysis strongly confirms Report 01's recommendation. The `bx_le` non-totality gap is a **structural impossibility** given the current definition — no derivable consequences of BX1–BX12 can make `bx_le` total, and BX11 in particular only addresses F-witness ordering, not G-content-inclusion ordering.

The correct approach is a **local quasimodel layer**:

1. For the Until/Since truth lemma steps, use a finite Hintikka-point quasimodel where the temporal ordering IS defined to propagate Until-formulas (not just G-formulas).
2. The existing BXPoint infrastructure for Box/G/H is kept verbatim.
3. The quasimodel is a side-structure used only at the realization steps (Realization.lean).

This is exactly the approach the Construction.lean and Realization.lean files already anticipate — they define `hintikka_step` (Construction.lean:44–51) with an explicit "Until defect propagation" clause that propagates `φ U ψ` across the one-step relation when `ψ` is not yet present.

### Secondary Investigation: BX7 + BX12 Chain for until_backward

There is a **partial path** for the `until_backward` sorry (1 of the 6 sorries) that does not require quasimodels:

If `bx_le w u`, `bx_le u v`, `ψ ∈ v`, `¬(φ U ψ) ∈ u`, and either `bx_le v u` or some additional structural fact:

From `bx_le u v` and `ψ ∈ v`, by `F_from_above`: `F(ψ) ∈ u`. But then by BX8: `φ U (⊤) → φ U ψ`? No, BX8 gives `ψ → φ U ψ`, not useful here. The problem is that `ψ ∉ u`.

The BX7 + BX12 chain cannot close `until_backward` without `ψ ∈ u` or `φ U ψ ∈ u`, which is exactly what we're trying to prove.

**Conclusion**: There is no shortcut derivation for any of the 6 sorries using existing BX axioms. All 6 require the quasimodel infrastructure.

---

## Evidence / Examples

### Evidence 1: Countermodel for bx_le totality

Explicit model showing `bx_le` is not total even in a BX-consistent system:

Let `Σ = {p, q, G(p), G(q)}`. Consider two MCSs:
- `w = {p, G(p), ¬q, ¬G(q), G(¬q), ...}` — p holds and always holds; q does not hold and never will
- `v = {q, G(q), ¬p, ¬G(p), G(¬p), ...}` — q holds and always holds; p does not hold and never will

Then `g_content(w) = {G(p)-content} = {p, ...}` and `v.formulas` does not contain `p` (since `¬p ∈ v`). So `bx_le w v` fails. Symmetrically `bx_le v w` fails. BX11 says nothing about this pair.

### Evidence 2: BX11 At an MCS with F(p) and F(q)

At an MCS `w` with `F(p) ∈ w` and `F(q) ∈ w`, BX11 says one of `{F(p ∧ q), F(p ∧ F(q)), F(F(p) ∧ q)} ∈ w`. By `bx_forward_witness`, each disjunct yields a BXPoint `v` with `bx_le w v` and the corresponding formula. But this witnesses that *some* future point (reachable from `w`) has the appropriate formula — it says nothing about whether `bx_le` between arbitrary other MCSs is total.

### Evidence 3: The hintikka_step Relation Has the Right Shape

From Construction.lean:44–51:
```lean
def hintikka_step {Sigma : Finset Formula} (h1 h2 : HintikkaPoint Sigma) : Prop :=
  -- G-propagation
  (∀ χ : Formula, Formula.all_future χ ∈ h1.formulas → χ ∈ h2.formulas) ∧
  -- H-backward
  (∀ χ : Formula, Formula.all_past χ ∈ h2.formulas → χ ∈ h1.formulas) ∧
  -- Until defect propagation
  (∀ φ ψ : Formula, Formula.untl φ ψ ∈ h1.formulas → ψ ∉ h1.formulas →
    φ ∈ h1.formulas ∧ Formula.untl φ ψ ∈ h2.formulas)
```

The "Until defect propagation" clause directly provides `φ ∈ h1.formulas` when `φ U ψ ∈ h1.formulas` and `ψ ∉ h1.formulas`. This is exactly the guard-lifting requirement: `hintikka_step h1 h2` plus `φ U ψ ∈ h1` plus `ψ ∉ h1` gives `φ ∈ h1`. The quasimodel approach has the correct structure built in.

---

## Confidence Level

**High confidence** in the following:

1. `bx_le` with `g_content ⊆` definition is structurally non-total, and BX11 cannot fix this. (Confidence: **~99%** — this is a simple definitional argument.)

2. None of the 6 sorries can be closed by any combination of BX1–BX12 axioms without additional structure. (Confidence: **~95%** — the argument above is complete for 5 of the 6; the `until_backward` case has a plausible BX7+BX12 chain that I traced to failure, but have not proved the chain is definitively blocked.)

3. The Hintikka quasimodel approach (already partially scaffolded in Construction.lean) provides the correct mechanism for closing all 6 sorries. (Confidence: **~90%** — this is the established mathematical approach from Burgess 1984 / Reynolds 1996, and the Construction.lean infrastructure already defines the key `hintikka_step` relation with the right properties.)

4. Report 01's "local quasimodel" recommendation is the right architectural choice (vs. full quasimodel pivot). (Confidence: **~85%** — depends on how smoothly the Realization.lean proofs can be restructured to use Hintikka points for the guard-lifting steps while keeping BXPoints for Box/G/H.)

**Lower confidence**:

5. Whether the BX7+BX12 chain might close `until_backward` specifically (the 1 backward sorry per Until/Since). I traced it and found it fails, but did not verify that NO combination of BX axioms applied at an MCS with `bx_le u v` and `ψ ∈ v` and `¬(φ U ψ) ∈ u` leads to contradiction. (Confidence in claim "it fails": **~80%**.)
