# Phase 4 handoff — forward decomposition COMPLETE; resume at Phase 5 (backward)

**Status: Phases 2, 3, 4 COMPLETE and committed green.** Spine green: full `lake build` EXIT 0 at
**1769 jobs**; `completeness_discrete` axiom trace unchanged
`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` (the sole
`sorryAx` is the pre-existing `KampPrior.lean:562` sorry, NOT added to). All new work is in the
off-path `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean`; **0 sorries, no
vacuous placeholder**. Nothing live imports the file.

## What landed (committed)

- **Phase 2 (faithfulness gate) — PASSED.** Read Rabinovich PDF pp.4-11 directly. The TL-level
  decomposition faithfully restates his Section-5 three-piece chain split `ψ ≡ ψ₀(z₀) ∧ φ(z₀,z₁) ∧
  ψ₁(z₁)` piece-for-piece (below↔formula(1)/ψ₀, above↔formula(2)/ψ₁, middle↔formula(3)=Lemma 5.1,
  reassembly↔`¬ψ₀∨¬φ∨¬ψ₁`; cap-absorption↔Prop 3.5 `◫B₀`/`□B_{n+1}` terminals). No structural drift.
  Report: `reports/02_rabinovich-faithfulness-crosscheck.md`.
- **Phase 3 (constructors)**: `belowFormula`, `aboveFormula`, `middleBracket`.
- **Phase 4 (forward)**: `belowFormula_of_efSat`, `aboveFormula_of_efSat`, `middleBracket_of_efSat`,
  `efSat_decompose_tl_forward` — all for `hlt : (ψ.pin 0).val < (ψ.pin 1).val`.

## Resume: Phase 5 — backward (`three-piece → efSat`), then degenerate/wlog, then the full iff

### 5a. `efSat_of_decompose_tl` (the crux remaining piece, `m < k`)

Statement (mirror the forward lemmas' param convention):
```
theorem efSat_of_decompose_tl (N atomMap h_surj env ψ)
    (hlt : (ψ.pin 0).val < (ψ.pin 1).val)
    (hb : temporal_truth N atomMap (env 0) (belowFormula atomMap h_surj ψ))
    (hm : (middleBracket atomMap h_surj ψ).holds N atomMap (env 0) (env 1))
    (ha : temporal_truth N atomMap (env 1) (aboveFormula atomMap h_surj ψ)) :
    efSat N env ψ
```

**Template**: the BACKWARD direction of `translateProp35_correct` (`Prop35Assembly.lean:232-367`)
already glues TWO Nat-chains (`x''` below-of-pin, `x'` above-of-pin) into one `Fin (n+1)` witness via
`x j := if j.val ≤ k.val then x'' (k.val - j.val) else x' (j.val - k.val)`, discharging all six
`efSat` clauses (StrictMono, pin, pointType, before/between/after). Your case extends this to a
**THREE-way** glue with two pins `m = (ψ.pin 0).val < k = (ψ.pin 1).val`:
```
x j := if j.val ≤ m then xb (m - j.val)          -- below chain (xb 0 = env 0 = x_m, antitone)
       else if j.val < k then w (j.val - m - 1)   -- middle interior (from middleBracket witnesses)
       else xa (j.val - k)                        -- above chain (xa 0 = env 1 = x_k, monotone)
```

**Chain extraction recipe** (each mirrors the forward lemmas' `set alphaL/betaL … + hleft_eq/hright_eq
congruence`, run in reverse):
- Below: `simp only [belowFormula] at hb; rw [temporal_truth_and] at hb; obtain ⟨hb_pt, hb_chain⟩ := hb;
  rw [buildLeft_correct] at hb_chain`, then rewrite the pair-list via the same `hleft_eq` congruence
  used in `belowFormula_of_efSat`, then `rw [buildLeft_spec_iff_chain] at hb_chain` to obtain
  `xb : Nat → carrier` with `xb 0 = env 0`, antitone on `[0,m]`, the `αL/βL` realized, and the
  before-cap `∀ y < xb m, (intervalType ⟨0⟩) y`.
- Above: symmetric with `aboveFormula`, `buildRight_correct`, `hright_eq`, `buildRight_spec_iff_chain`
  → `xa : Nat → carrier`, `xa 0 = env 1`, monotone on `[0, n-k]`, after-cap `∀ y > xa (n-k), …`.
- Middle: `simp only [middleBracket, VVecEA2.holds, List.mem_singleton, exists_eq_left] at hm;
  rw [VecEA2.holds] at hm; obtain ⟨_,_,hm_br⟩ := hm; simp only [BracketFormula.holds,
  BracketFormula.toIntervalPattern] at hm_br`. Then `by_cases` on the interior count
  `(ψ.pin 1).val - (ψ.pin 0).val - 1 = 0` exactly as `middleBracket_of_efSat` does, using
  `IntervalPattern.holds_eq_zero`/`holds_eq_succ` (`ExistsForallNF.lean:188,200`) to unpack. Extend
  the `Fin (k-m-1)` witnesses to a total `w : Nat → carrier` (dummy `env 0` past the range; the
  `m < j < k` branch is vacuous when the count is 0).

**Clause discharge** (follow the template's case structure, `lt_trichotomy` on region boundaries,
now with two split points `m` and `k` giving ~6 region cases for `between`): StrictMono from the three
pieces' mono/antitone + `env 0 < interior < env 1` (middle witnesses in `(env0,env1)`) + below `<`
env0 `<` above; pins `x ⟨m⟩ = env 0`, `x ⟨k⟩ = env 1`; pointTypes from the three pieces' α's; before-cap
from `xb`'s cap; after-cap from `xa`'s cap; between from the responsible piece per region (boundary
segments `(x_m, x_{m+1})` and `(x_{k-1}, x_k)` come from the middle bracket's end segments `β_{m+1}`,
`β_k`; the `Fin.succ.castSucc` interval index lives in `Fin (ψ.n + 2)`, not `Fin (ψ.n+1)` — a fix that
cost a rebuild in Phase 4).

### 5b. Degenerate `k = m` (Rabinovich p.7)
`ψ ≡ z₀ = z₁ ∧ ψ'(z₀)`, a single one-free-var piece; `¬ψ ≡ z₀ < z₁ ∨ z₁ < z₀ ∨ (z₀ = z₁ ∧ ¬ψ')`.
Since Phase 6 negates on the hypothesis `env 0 < env 1`, the `k=m` (⇒ `env 0 = env 1`) branch is
handled by the `z₀ < z₁` disjunct being false — decide how the full `efSat_decompose_tl` iff or the
Phase-6 output threads `env 0 < env 1` (the Phase-6 signature already carries it).

### 5c. `wlog m > k`
Symmetry wrapper normalizing `(ψ.pin 0).val > (ψ.pin 1).val` to the `<` case (swap the roles of the
two pins / mirror below↔above). Rabinovich's "w.l.o.g. m < k".

### 5d. Full `efSat_decompose_tl` iff
`⟨efSat_decompose_tl_forward, fun ⟨hb,hm,ha⟩ => efSat_of_decompose_tl …⟩` for `m<k`, plus the `k=m`
and `wlog` branches.

## Phase 6 (assembly) recipe
`prop42_efSat_negation_general`: build `v' := VVecEA2.disj (VVecEA2.disj negBelow negMiddle) negAbove`.
- `negBelow`/`negAbove`: the below/above factors are the **raw** TL formulas `belowFormula`/`aboveFormula`
  (NOT 1-var `efSat` objects), so introduce thin siblings `negLeftClauseTL`/`negRightClauseTL` wrapping
  `⟨Formula.neg (belowFormula …)⟩` / `⟨Formula.neg (aboveFormula …)⟩` at the endpoint, proven by the
  SAME technique as Phase-1 `negLeftClause_holds` (`temporal_truth_neg` + `BracketFormula.trivial_holds`
  + `TemporalPred.eval_at_top`). Their `holds (z₀,z₁) ↔ ¬ temporal_truth (belowFormula) z₀` etc.
- `negMiddle`: `(middleBracket …).negFix` via `VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean:177`),
  threading `h_INF`/`h_SUP` and `z₀ < z₁`; `holds ↔ ¬ (middleBracket …).holds`.
- Combine via `VVecEA2.disj_holds` (`VecEAFormula.lean:286`) + De Morgan + the full `efSat_decompose_tl`
  iff: `v'.holds ↔ ¬below ∨ ¬middle ∨ ¬above ↔ ¬(below ∧ middle ∧ above) ↔ ¬ efSat`. Output shape:
  `∃ v' : VVecEA2, ∀ env, env 0 < env 1 → (v'.holds N atomMap (env 0) (env 1) ↔ ¬ efSat N env ψ)`.

## Phase 7 (wire) — seam located afresh
The v1-assumed `pairProject → prop42_veeSat_negation` seam does NOT exist (confirmed). The **actual**
reduction the parent's Phase-7 negation consumes is `augTarget_iff` (`ExistsForallLemmas.lean:696`):
`efSat N env ψ ↔ augConjSat N env (augTarget ψ)`, whose docstring states "Phase 7's Negation case
consumes the biconditional." `augTarget ψ` is a conjunction of **pairwise 2-free-variable projections**
(each an arbitrary-pin 2-var `∃∀` object). Negating `augConjSat` (a conjunction) → disjunction of the
2-var projections' negations → each supplied by `prop42_efSat_negation_general`. Locate the exact live
declaration where this negation is currently unfilled (grep `augTarget`/`augConjSat` live uses; the
KampPrior/Prop43 route) and wire with a single import + minimal call site; combine per-object negations
by `VVecEA2.disj` only (verdict A6, no conjunction closure).

## Phase 8 audit
`lake build` EXIT 0 @ 1769; `completeness_discrete` axiom trace unchanged (verify with `lean_verify`);
zero new sorry/placeholder/`Prop43Structural.lean` hole; per-piece PDF grounding present; durable
anchors only (no task numbers) in `Theories/`.

## Key gotchas already discovered
- `gluedChain` and its `gluedChain_*` lemmas (`ExistsForallLemmas.lean:580-688`) are **`private`** —
  cannot be reused from `Prop42NegationGeneral.lean`; the backward glue must be written inline
  (the `translateProp35_correct` 2-way template IS reusable in spirit but is a different declaration).
- `efSat`'s interior-interval conjunct uses `ψ.intervalType i.succ.castSucc` with the index in
  `Fin (ψ.n + 2)`; `i.castSucc < y < i.succ` are the segment bounds. `Fin.coe_castSucc` is deprecated →
  use `Fin.val_castSucc`.
- `translateProp35_correct` (`Prop35Assembly.lean:92-367`) is the master template for both directions.
