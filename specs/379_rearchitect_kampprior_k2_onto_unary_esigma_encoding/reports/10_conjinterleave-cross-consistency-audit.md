# Divergence Audit — point-vs-interval cross-consistency filter for `conjInterleave_iff` / Phase 9

- **Task**: 379 — rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Mode**: H5 divergence audit / design adjudication (research-only; NO `Theories/**` edits)
- **Type**: lean4 (hard mode: H2/H3/H4/H5)
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, PDF page cites only;
  companion `.md` is corrupt and was not used)
- **Inputs read**: `ConjInterleave.lean` (full), `ExistsForallFormula.lean`
  (`efSat`/`unaryHolds`/`intervalHolds`/`IntervalType`/`ExistsForallFormula`), `IntervalType.lean`
  (`intervalConj`/`intervalHolds_mono`/`intervalHolds_inter_left/right/iff`/`intervalHolds_bot`),
  phase-9 handoff (`phase-9-handoff-20260718T131753.md`), prior audit
  (`reports/09_conjinterleave-interval-type-audit.md`). Rabinovich PDF page cites inherited from the
  report-09 page-image reads + delegation-supplied pages.

## Verdict Summary (front-loaded)

1. **VERIFY the backward obstruction — CONFIRMED.** On the current point-consistency-only merge, the
   backward direction of `conjInterleave_iff` is UNSOUND. A chain-`k` existential point interior to a
   chain-`(3-k)` interval is recorded in `mergedFormula` only as a complete *point* (`mergedPointType`
   = that chain's `pointType`); nothing forces its complete type into the *other* chain's interval
   admissible set covering it. The handoff's micro-counterexample reproduces against the real
   `efSat`/`intervalHolds`/`mergedFormula` declarations.
2. **Faithful cross-consistency filter.** Add a decidable `MergePair.crossConsistent` conjunct: for
   every merged point pinned by chain `k` and *interior* to chain `(3-k)`, require the chain-`k`
   complete point type to lie in chain-`(3-k)`'s interval admissible set at that slot —
   `ψ_k.pointType i ∈ ψ_{3-k}.intervalType (intervalSlot e_{3-k} (e_k i))`. This is the point-vs-interval
   case of Rabinovich's "conjoin both chains' constraints at every merged position" (Lemma 3.2(1),
   p.4; Def 3.1 objects, p.4). NO novel mathematics, NO Feferman-Vaught — the interval-vs-interval
   case is already `intervalConj = ∩`, the point-vs-point case is already `pointConsistent`; this is
   the missing third, orthogonal case.
3. **Forward preservation — PRESERVED (CRITICAL CHECK PASSES).** Adding this filter does NOT break
   the true forward direction. A genuine `efSat ψ₁ ∧ efSat ψ₂` witness pair *automatically* satisfies
   cross-consistency: an interior chain-`k` point `x_k i` is a REAL model point that simultaneously
   realizes `ψ_k.pointType i` (from `efSat ψ_k`) and lies in the other chain's open interval, so
   `efSat ψ_{3-k}`'s interval clause gives `intervalHolds (ψ_{3-k}.intervalType slot) (x_k i)`; by
   `nf_eval_unique` the admissible completion realized there IS `ψ_k.pointType i`, forcing membership.
   The Phase-2 full-consistency filter broke forward because it constrained possibly-EMPTY open
   intervals (no witness); this filter constrains only real existential POINTS (always a witness) via
   `∈` (not equality), so it cannot over-constrain.
4. **Bounded vs re-scope — BOUNDED (no plan revision / no new task).** Unlike report 09 (a field-type
   change rippling through ~3,000 lines of landed proof → RE-SCOPE), this change is purely additive
   and *orphan-local*: `grep` confirms `conjInterleave`/`MergePair`/`pointConsistent` have **zero**
   external consumers (only a docstring mention in `IntervalType.lean`), `VeeConj.lean` does not yet
   exist, and no field type or landed signature changes. It fits the existing plan's Phase 9
   continuation → Phases 10-13, one implement agent per phase (with the forward/backward green
   sub-step split the handoff already prescribes).
5. **Corrected Phase 9 continuation target** in §5: the `crossConsistent` definition + Decidable
   instance, the folded `conjInterleave` filter, the `crossConsistent_of_holds` forward-preservation
   lemma, and the full `conjInterleave_iff` biconditional — precise enough to execute without
   re-litigating the design.

## H3 Reference-Grounding Table (Tier 1 — 5-column; code cited by declaration name)

| Source | Prop/Location | Lean Identifier | Type Signature (as landed / as needed) | Status |
|---|---|---|---|---|
| Rabinovich Def 3.1 (∃∀ objects; αⱼ complete point 1-types, βⱼ qf interval 1-formulas) | PDF p.4 | `ExistsForallFormula`, `efSat`, `UnaryType`, `IntervalType`, `intervalHolds` | `pointType : Fin(n+1)→UnaryType`, `intervalType : Fin(n+2)→Finset UnaryType`; `intervalHolds N S y := ∃ τ ∈ S, unaryHolds N τ y` | LANDED (partial intervals in place, Phases 3-8) |
| "a point realizes at most one complete 1-type" | — (Lean) | `nf_eval_unique` | `NormalForm.lean` — realizes-`nf1` → realizes-`nf2` → `nf1 = nf2` | LANDED — the engine of both point-consistency AND forward-preservation |
| Lemma 3.2(1) conjunction of ∃∀ ≡ disjunction of ∃∀ (merge two chains, **conjoin per-position constraints**) | PDF p.4 | `conjInterleave`, `mergedFormula`, `MergePair.valid`, `MergePair.pointConsistent` | merge enumerator + per-slot `intervalConj`, point-consistency filter | PARTIAL — filter incomplete: point-vs-interval case missing (this audit) |
| Lemma 3.2(1) per-position conjunction, **point-vs-interval case** (a complete point type ∧ a qf interval formula) | PDF p.4 | `MergePair.crossConsistent` (NEW), `crossConsistent_of_holds` (NEW) | `ψ_k.pointType i ∈ ψ_{3-k}.intervalType (intervalSlot e_{3-k} (e_k i))` at interior points | NOT STARTED — the corrected Phase 9 target |
| Lemma 3.4 closure under ∧ | PDF p.5 | `veeConj`, `veeConj_iff` | `veeSat (veeConj Φ₁ Φ₂) ↔ veeSat Φ₁ ∧ veeSat Φ₂` | NOT STARTED — consumes full `conjInterleave_iff` |
| Prop 3.5 (αᵢ/βᵢ Boolean/qf, "do not even use Until/Since") | PDF p.5 | `translateProp35` (later phase) | translate admissible-completion sets | LANDED/later — unaffected by this filter |

## Findings

### 1. VERIFY the backward obstruction — CONFIRMED

**Machine-grounded merge semantics (real declarations).** `mergedFormula ψ₁ ψ₂ pin₁ e₁ e₂`
(`ConjInterleave.lean`) sets, for merged size `k`:
- `pointType j := mergedPointType ψ₁ ψ₂ e₁ e₂ j` — a **complete** `UnaryType`, chain-1 preferred
  (`mergedPointType`, `dif` on `∃ i, e₁ i = j` then `∃ i, e₂ i = j`);
- `intervalType t := intervalConj (chainIntervalType ψ₁ e₁ t) (chainIntervalType ψ₂ e₂ t) = S₁ ∩ S₂`.

`conjInterleave` filters merges by `m.valid pin₁ pin₂ ∧ MergePair.pointConsistent ψ₁ ψ₂ m.e₁ m.e₂`
only. `MergePair.pointConsistent` (real def) is `∀ i₁ i₂, e₁ i₁ = e₂ i₂ → ψ₁.pointType i₁ = ψ₂.pointType i₂`
— it constrains merged positions where **both** chains pin a point, and is *silent* on positions
pinned by one chain and interior to the other.

**Backward failure, against the real `efSat`.** `efSat` (`ExistsForallFormula.lean`) requires a
witness chain `w` with (i) each `w j` realizing `pointType j` and (ii) each **open** interval `(w
i.castSucc, w i.succ)` (plus before-first/after-last) satisfying `intervalHolds (intervalType slot)`.
To recover `efSat ψ₁` from a satisfied `mergedFormula` one projects `x₁ i := w (e₁ i)`. `efSat ψ₁`
then demands that **every** model point strictly inside a ψ₁-interval `(x₁ i, x₁ (i+1))` satisfy
`intervalHolds (ψ₁.intervalType (i+1))`. That region decomposes into:
- **merged open sub-intervals** — each carries `S₁ ∩ S₂ ⊆ S₁`, so `intervalHolds (S₁∩S₂) y →
  intervalHolds S₁ y` by `intervalHolds_inter_left` / `intervalHolds_mono`. **Discharged.**
- **merged interior POINTS** = chain-2 existential points `e₂ i'` sitting inside this ψ₁-interval.
  At such a point `mergedFormula` records only `mergedPointType (e₂ i') = ψ₂.pointType i'` (a complete
  type). `efSat ψ₁` needs `intervalHolds (ψ₁.intervalType (i+1)) (w (e₂ i'))` = `∃ τ ∈ ψ₁.intervalType
  (i+1), unaryHolds τ (w (e₂ i'))`. Since `w (e₂ i')` realizes exactly one complete type
  (`ψ₂.pointType i'`, by `nf_eval_unique`), this holds **iff `ψ₂.pointType i' ∈ ψ₁.intervalType
  (i+1)`** — which the point-consistency-only filter never forces. **NOT discharged → backward
  UNSOUND.**

**Micro-counterexample reproduced (handoff's, verified against declarations).** `ψ₁` = "point `α`;
after `α`, interval type `{β}`" (i.e. `ψ₁.intervalType (after) = {β} : Finset UnaryType`). `ψ₂` =
"single point `γ`" with `γ ≠ β` as complete types, and unconstrained intervals
(`ψ₂.intervalType _ = Finset.univ`). The size-2 merge placing `γ` after `α` is `valid` and
`pointConsistent` (no shared pinned point ⇒ the point-consistency ∀ is vacuous). Its `mergedFormula`
has the open slot between `α` and `γ` carrying `{β} ∩ univ = {β}`, but the **point** `γ` carrying
`mergedPointType = γ`. A model `w` realizing this merged disjunct puts `γ` (complete type `γ ∉ {β}`)
after `α`; then `efSat ψ₁` fails because `intervalHolds {β} γ = unaryHolds β γ = False` (via
`intervalHolds_bot`-style reasoning: `γ ∉ {β}`). So `veeSat (conjInterleave ψ₁ ψ₂) ↛ efSat ψ₁`.
**CONFIRMED.**

The prior audit's §5 backward sketch ("`intervalHolds (S₁∩S₂)` at every point of every ψₖ-interval
gives `intervalHolds Sₖ`") silently assumed every point of a ψₖ-interval is a merged *open*-interval
point; it does not cover merged interior *existential* points of the other chain. This audit closes
that gap.

### 2. The faithful cross-consistency filter (specification)

Add to `ConjInterleave.lean`, using the already-defined `intervalSlot` / `belowCount` (§1 of the
module) and `Finset` membership:

```lean
/-- **Point-vs-interval cross-consistency** (Rabinovich Lemma 3.2(1), p.4 — the point-vs-interval
case of the per-position conjunction). At a merged point pinned by one chain and *interior* to the
other chain's interval, the conjoined constraint is (that chain's complete point type) ∧ (the other
chain's qf interval formula); it is satisfiable iff the complete point type is an admissible
completion of the interval formula, i.e. lies in the other chain's interval admissible set. -/
def MergePair.crossConsistent {r k : Nat} (ψ₁ ψ₂ : ExistsForallFormula sig F r)
    (e₁ : Fin (ψ₁.n + 1) → Fin (k + 1)) (e₂ : Fin (ψ₂.n + 1) → Fin (k + 1)) : Prop :=
  (∀ i₁ : Fin (ψ₁.n + 1), (∀ i₂, e₂ i₂ ≠ e₁ i₁) →
      ψ₁.pointType i₁ ∈ ψ₂.intervalType (intervalSlot e₂ (e₁ i₁)))
  ∧
  (∀ i₂ : Fin (ψ₂.n + 1), (∀ i₁, e₁ i₁ ≠ e₂ i₂) →
      ψ₂.pointType i₂ ∈ ψ₁.intervalType (intervalSlot e₁ (e₂ i₂)))

instance … : Decidable (MergePair.crossConsistent ψ₁ ψ₂ e₁ e₂) := by
  unfold MergePair.crossConsistent; infer_instance   -- finite ∀ + DecidableEq Fin + Finset ∈
```

Notes on faithfulness and correctness:
- **`intervalSlot e₂ (e₁ i₁) : Fin (ψ₂.n + 2)`** is exactly the ψ₂-interval slot containing merged
  position `e₁ i₁` (`belowCount e₂ (e₁ i₁) = card {i₂ | e₂ i₂ < e₁ i₁}`), matching the module's slot
  convention "slot 0 = before x₀, slot i = (x_{i-1}, xᵢ), slot n+1 = after xₙ".
- **Guarded by interiority** (`∀ i₂, e₂ i₂ ≠ e₁ i₁`): shared merged points are already handled by
  `pointConsistent`; the filter fires only at genuinely-interior positions (point-vs-interval, not
  point-vs-point).
- **Symmetric** (both conjuncts): the biconditional must recover BOTH chains, so both "chain-1 point
  interior to chain-2 interval" and "chain-2 point interior to chain-1 interval" are constrained.
- **Membership `∈`, not equality**: it asserts only that the complete point type is *one of* the
  admissible completions — it never demands the interval set be a singleton or equal anything. This
  is what keeps forward true (§3).
- **This is the third orthogonal axis**: point-vs-point = `pointConsistent` (equality via
  `nf_eval_unique`); interval-vs-interval = `intervalConj = ∩` (already in `mergedFormula`);
  point-vs-interval = `crossConsistent` (membership). All three are instances of the single
  Lemma-3.2(1) principle "the merged formula at each merged position is the conjunction of both
  chains' constraints there." No new mathematics is introduced.

Fold into the enumerator (one added conjunct):

```lean
noncomputable def conjInterleave … :=
  … (Finset.univ.filter fun m : MergePair ψ₁.n ψ₂.n k =>
        m.valid pin₁ pin₂
        ∧ MergePair.pointConsistent ψ₁ ψ₂ m.e₁ m.e₂
        ∧ MergePair.crossConsistent ψ₁ ψ₂ m.e₁ m.e₂).toList.map …
```

### 3. Forward preservation — PRESERVED (the critical check)

**Claim.** For genuine witnesses `h₁ : efSat N env ψ₁`, `h₂ : efSat N env ψ₂`, the realized rank
merge (as built in `conjInterleave_forward`) satisfies `MergePair.crossConsistent`. Equivalently,
there is a `crossConsistent_of_holds` lemma parallel to the landed `pointConsistent_of_holds`.

**Machine-grounded argument (first conjunct; second is symmetric).** Let `w` be the merged chain,
`e₁ i₁` an interior chain-1 point (`∀ i₂, e₂ i₂ ≠ e₁ i₁`), and `slot := intervalSlot e₂ (e₁ i₁)`.
Write `p := w (e₁ i₁) = x₁ i₁` (the rank round-trip). Then:
- From `h₁` (point clause of `efSat`): `unaryHolds N (ψ₁.pointType i₁) p`.
- `p` is strictly between the two consecutive chain-2 witness points bounding ψ₂-interval `slot`
  (strictly, since `e₁ i₁` is not a chain-2 point and `w`, `x₂` are strictly monotone), so from `h₂`
  (the matching before / between / after interval clause of `efSat`):
  `intervalHolds N (ψ₂.intervalType slot) p`, i.e. `∃ τ ∈ ψ₂.intervalType slot, unaryHolds N τ p`.
- Take that `τ`. Both `τ` and `ψ₁.pointType i₁` are realized at the SAME point `p`, so by
  `nf_eval_unique N 0 1 (fun _ => p) …`, `τ = ψ₁.pointType i₁`. Hence `ψ₁.pointType i₁ ∈
  ψ₂.intervalType slot`. ∎

**Why this filter is safe where the Phase-2 filter was not.** The Phase-2 interval-vs-interval
full-consistency filter constrained merged **open intervals**, which can be EMPTY (order-adjacent
merged points, no interior model point). With no witness point, demanding interval-set agreement /
nonempty intersection was unsatisfiable-yet-required ⇒ forward FALSE (report 09 §1, CONFIRMED there).
`crossConsistent` constrains only merged **existential points**, which are real model points — the
witness `p` itself always exists. And it uses membership `∈`, satisfied exactly by `p`'s unique
complete type. There is no empty-witness failure mode. **Forward cannot break.** Confidence: High
(every step reduces to a landed declaration: `efSat` clauses, `intervalHolds` def, `nf_eval_unique`).

**Falsification attempt (adversarial).** Could a genuine witness pair violate cross-consistency if
`p` coincided with a chain-2 point? No — the guard `∀ i₂, e₂ i₂ ≠ e₁ i₁` excludes exactly that case.
Could `p` fail to lie strictly inside the ψ₂-interval? Only if `p` equalled a chain-2 endpoint, again
excluded by the guard + strict monotonicity. No counterexample found.

### 4. Bounded vs re-scope — BOUNDED

**Blast radius = orphan-local.** `grep` over `Theories/`:
- `conjInterleave` / `MergePair` / `pointConsistent` / `crossConsistent`: **zero** references outside
  `ConjInterleave.lean` (sole hit is a docstring mention of `conjInterleave_iff` in
  `IntervalType.lean`).
- No file imports `Kamp.ConjInterleave`; it is **not** in the root `Bimodal` target (orphan; verify
  with `lake build Bimodal.Metalogic.WeakCanonical.Kamp.ConjInterleave`).
- `VeeConj.lean` does not exist yet (no stub).

**Nothing is disturbed.** The filter adds a `def` + `instance` + one filter conjunct + one
forward-preservation lemma, all internal to the orphan module. It changes **no field type, no landed
signature, no migrated asset** (`efSat`, `ExistsForallFormula`, `Prop42NegationGeneral`,
`ExistsForallLemmas`, `Prop35*`, `Prop42ExistsForall` are all untouched). This is the decisive
contrast with report 09, whose interval-type field-type change forced a RE-SCOPE across ~3,000 lines.

**Verdict: BOUNDED — fits the existing plan, one implement agent per phase, no revision / no new
task.** Recommended green sub-step split (already anticipated by the handoff: "forward rank
bookkeeping and backward projection as separate green sub-steps"):
- **9(cont)-a**: `crossConsistent` def + Decidable instance + `crossConsistent_of_holds`
  (forward-preservation lemma, §3) + fold conjunct into `conjInterleave`. Scoped build green.
- **9(cont)-b**: retire the `conjInterleave_forward` sorry (sorted-union rank realization — the large
  order-theoretic build, independent of the filter; now must also discharge `crossConsistent` via
  `crossConsistent_of_holds`).
- **9(cont)-c**: backward direction + assemble `conjInterleave_iff` (points via
  `mergedPointType_left/right`; open sub-intervals via `intervalHolds_inter_left/right`+`_mono`;
  interior points via `crossConsistent` membership + `nf_eval_unique`).
- **Phases 10-13 (β/γ/δ/ζ)**: `veeConj` / `veeConj_iff` (Lemma 3.4-∧) then the spine consumers —
  unchanged in shape; they consume the now-full `conjInterleave_iff`.

If a single agent run cannot land 9(cont)-b (the forward bookkeeping is genuinely large), keeping it
as its own dispatch is within-plan and does not require re-scoping.

**Consumers of `conjInterleave`/`MergePair`/`pointConsistent` disturbed by the filter change: NONE.**
The only future consumer is the not-yet-written `veeConj_iff`, which is a NEW build, not a
disturbance.

### 5. Corrected Phase 9 (continuation) target

Implement, in `ConjInterleave.lean` only (orphan; verify with the scoped build), in this order:

1. **`MergePair.crossConsistent`** (def, exactly as §2) + **Decidable instance**.
2. **Fold the conjunct** into `conjInterleave`'s `Finset.univ.filter` (as §2): filter becomes
   `m.valid pin₁ pin₂ ∧ MergePair.pointConsistent … ∧ MergePair.crossConsistent …`.
3. **`crossConsistent_of_holds`** (forward-preservation lemma; the CRITICAL invariant):
   ```lean
   theorem crossConsistent_of_holds {r k} (N) (ψ₁ ψ₂ : ExistsForallFormula sig F r)
       (e₁ …) (e₂ …) (w : Fin (k+1) → N.carrier)
       (hpt₁ : ∀ i, unaryHolds N (ψ₁.pointType i) (w (e₁ i)))
       (hpt₂ : ∀ i, unaryHolds N (ψ₂.pointType i) (w (e₂ i)))
       (hiv₁ : ∀ i₁ i₂, e₂ i₂ ≠ e₁ i₁ → «w (e₁ i₁) inside ψ₂-slot» →
                 intervalHolds N (ψ₂.intervalType (intervalSlot e₂ (e₁ i₁))) (w (e₁ i₁)))
       (hiv₂ : … symmetric …) :
       MergePair.crossConsistent ψ₁ ψ₂ e₁ e₂
   ```
   proved by `nf_eval_unique` collapsing the realized interval completion to the point's complete
   type (§3). (In `conjInterleave_forward`, `hiv₁`/`hiv₂` are supplied by the `efSat ψ₂`/`efSat ψ₁`
   interval clauses at the merged interior point; a small locate-the-slot lemma tying
   `intervalSlot e₂ (e₁ i₁)` to the `efSat` before/between/after case may be factored out.)
4. **Retire `conjInterleave_forward`** — the realized rank merge now additionally discharges
   `crossConsistent` via `crossConsistent_of_holds`. (The sorted-union bookkeeping is otherwise
   exactly the plan already in the theorem docstring.)
5. **Full biconditional** (the corrected target statement):
   ```lean
   theorem conjInterleave_iff {r} (N : OrderedMonadicStructure (sigE sig F))
       (env : Fin r → N.carrier) (ψ₁ ψ₂ : ExistsForallFormula sig F r) :
       veeSat N env (conjInterleave ψ₁ ψ₂ ψ₁.pin ψ₂.pin) ↔ efSat N env ψ₁ ∧ efSat N env ψ₂
   ```
   - **Forward**: `conjInterleave_forward` (now filter-aware).
   - **Backward**: from a disjunct `mergedFormula` + witness `w`, project `x_k i := w (e_k i)`;
     points via `mergedPointType_left`/`mergedPointType_right`; each ψ_k-interval region split into
     (a) merged open sub-intervals discharged by `intervalHolds_inter_left`/`_right` + `intervalHolds_mono`,
     and (b) merged interior points of the other chain discharged by the new **`crossConsistent`**
     membership (`ψ_{3-k}.pointType i' ∈ ψ_k.intervalType slot`) collapsed through `nf_eval_unique`
     to `intervalHolds (ψ_k.intervalType slot) (w (e_{3-k} i'))`.
6. **`veeConj` / `veeConj_iff`** (Lemma 3.4-∧, p.5), now a provable biconditional resting on
   `conjInterleave_iff`. Create `VeeConj.lean` only at this point (no earlier stub).

**Knock-on to Phases 10-13 (β/γ/δ/ζ): NONE structural.** `veeConj_iff`'s statement is unchanged; γ's
`⋀ᵢ ¬φᵢ` reassembly and δ's `translate` `and`-case consume the same full `veeConj_iff` the plan
already assumed. The only change vs the plan-as-written is that `conjInterleave`'s filter now has
three conjuncts instead of two, and the backward proof has one extra (interior-point) case — both
absorbed inside the existing Phase 9 continuation.

## Adversarial Self-Verification (H4)

Claim Verification Bar applied to every load-bearing claim. Verification methods: direct `Read` of
the declaration; `grep`/reference scan; model-theoretic argument reduced to landed lemmas; Rabinovich
PDF page (inherited from report-09 page-image reads + delegation-supplied pages).

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `efSat` interval clauses use `intervalHolds N S y := ∃ τ ∈ S, unaryHolds N τ y` over open intervals | `ExistsForallFormula.lean` `efSat`, `intervalHolds` | Direct Read of both decls | High |
| `mergedFormula` records interior merged points only as complete `mergedPointType`, with no interval-membership constraint | `ConjInterleave.lean` `mergedFormula`, `mergedPointType`, `MergePair.pointConsistent` | Direct Read | High |
| point-consistency-only filter is silent on point-vs-interval positions ⇒ backward UNSOUND | `MergePair.pointConsistent` def (`∀ i₁ i₂, e₁ i₁ = e₂ i₂ → …`) + `efSat` interior-point obligation | Direct Read + `efSat` clause inspection | High |
| Micro-counterexample (`γ ∉ {β}` after `α`) breaks backward | Constructed against `mergedFormula`/`intervalHolds {β} γ = False` | Hand model + `intervalHolds`/`Finset.mem_singleton` inspection | High |
| Cross-consistency filter = membership `ψ_k.pointType i ∈ ψ_{3-k}.intervalType (intervalSlot e_{3-k} (e_k i))` at interior points | Rabinovich Lemma 3.2(1) p.4 (per-position conjunction; point-vs-interval case); `intervalSlot`/`belowCount` landed | PDF page (inherited) + Read of `intervalSlot`/`belowCount` | High |
| Filter is faithful transcription (NOT novel / NOT Feferman-Vaught) — the third axis of one merge principle | Rabinovich Def 3.1 p.4 objects + Lemma 3.2(1) p.4; parallels landed `intervalConj` (∩) and `pointConsistent` (=) | Structural reading vs landed `intervalConj`/`pointConsistent` | High |
| **Forward PRESERVED**: genuine witnesses auto-satisfy cross-consistency via `nf_eval_unique` | `efSat ψ₁` point clause + `efSat ψ₂` interval clause at the same real point `p`; `nf_eval_unique` | Model-theoretic argument reduced to landed `efSat`/`nf_eval_unique`; adversarial falsification found none | High |
| Forward-preservation asymmetry vs Phase-2 filter: this constrains always-occupied POINTS (witness exists), Phase-2 constrained empty-able OPEN intervals | report 09 §1 (Phase-2 forward FALSE, CONFIRMED) vs §3 here | Cross-read of report 09 + `efSat` clause structure | High |
| Blast radius = orphan-local; zero external consumers; no field-type change | `grep` `conjInterleave`/`MergePair`/`pointConsistent`/import `Kamp.ConjInterleave`; root `Bimodal` scan | grep + Read | High |
| Filter is decidable | finite ∀ over `Fin`, `DecidableEq (UnaryType)`, `Finset ∈` — all landed | Read (existing `pointConsistent` Decidable instance uses the same machinery) | High |
| BOUNDED (fits Phases 9(cont)-13, one agent/phase) not RE-SCOPE | orphan-local + additive-only, contrasted with report 09 field-type RE-SCOPE | Comparison of change surface vs report 09 blast radius | Medium-High |

**Contradiction Log.** One resolved: report 09 §5's backward sketch implies the point-consistency
merge suffices for backward; the phase-9 handoff and this audit show it does not (interior-point
case). **Resolution (precedence: newer machine-checked finding on the now-landed partial
representation > earlier sketch written before the partial merge existed):** report 09 correctly
mandated *partial interval types* (landed), but its backward sketch predated the partial
`conjInterleave` and omitted the point-vs-interval case; this audit supplies the missing
`crossConsistent` conjunct. The two are complementary, not contradictory — report 09 fixed the
interval *representation*, this audit fixes the merge *filter*. No UNRESOLVED contradiction remains.

**Forbidden-output check.** No "mathlib likely has this" (this is a local-declaration audit, no
mathlib lemma is load-bearing). No type-mismatch claim without the declaration. Every claim traces to
a Read declaration, a grep, or a reduced model-theoretic step. No `sorry` deferral or axiom
introduction recommended (research-only audit; the one existing `conjInterleave_forward` sorry is
gate-permitted and its retirement is scoped in §5).

## Recommendation to the orchestrator

**Resume Phase 9 continuation as corrected (BOUNDED — no `/revise`, no new task).** Adjudication of
the design finding: **ADD** the `MergePair.crossConsistent` conjunct (§2), grounded in Rabinovich
Lemma 3.2(1) (p.4) as the point-vs-interval case of the per-position merge conjunction. Backward
becomes provable; **forward is preserved** (§3, the critical check — genuine witnesses auto-satisfy
it via `nf_eval_unique`, unlike the Phase-2 interval filter which constrained empty-able intervals).
Execute §5 steps 1-6 in `ConjInterleave.lean` only, one implement agent per green sub-step, verifying
with the scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.ConjInterleave`. No landed asset,
field type, or spine module is touched.
