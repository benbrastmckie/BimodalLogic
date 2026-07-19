# Phase 10b-i Handoff — `skelR` landed; `liftPair` spike complete, blueprint ready

**Dispatch:** lean-implementation-hard-agent, single-phase focus (Phase 10, sub_phase 10b-i, hard mode).
**Status:** Phase 10b-i **[PARTIAL]** — the reuse-viability spike is complete and the
type-disjunction skeleton (`skelR`) is landed green + axiom-clean. `liftPair`/`liftPair_iff` is
**not** landed: it is a full custom order-preserving-merge construction (spike finding below), too
large to complete sorry-free in this dispatch without risking a RED module. No `sorry`, no vacuous
placeholder introduced. `hCapture` untouched (not yet reached).

## What landed this dispatch (green, sorry-free, axiom-clean)

New file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/LiftPair.lean` (orphan, off the live
import path — grep-audited, nothing imports it). Axioms of `skelR_sat` =
`[propext, Classical.choice, Quot.sound]` (no `sorryAx`).

1. **`charType` / `unaryHolds_charType` / `exists_unaryHolds`** — the characteristic complete
   unary type of a model point (`nf_characteristic N 0 1 (fun _ => y)`) and the fact that every
   point realizes it, hence realizes *some* complete type. Reusable at every inserted context
   point of `liftPair` (the inserted point's complete type is not static — range over completions).
2. **`intervalHolds_top`** — the ⊤ interval type `intervalTop = univ` is satisfied at every point.
   Reusable for the split-interval / skeleton interval slots of `liftPair`.
3. **`skelDisjunct` / `skelR` / `skelR_sat`** — the universally-satisfiable arity-`m+1` skeleton
   as a `VeeExistsForall`, satisfied by every `StrictMono env` (via the characteristic-type
   disjunct).

## Spike result (report-12 flagged Medium-risk driver) — RESOLVED

**Question:** are `ConjInterleave.lean`'s `MergePair`/`mergedFormula` internals cleanly reusable
for `liftPair`? **Findings (concrete, from reading the landed code):**

- **`conjInterleave` top-level: NOT reusable.** `conjInterleave_iff` proves
  `veeSat (conjInterleave ψ₁ ψ₂ …) ↔ efSat ψ₁ ∧ efSat ψ₂` — a **conjunction of two fixed
  arity-`r` formulas**. `liftPair` lifts a **single** arity-2 `ξ`; there is no second conjunct
  whose `efSat` is universally true *and* that carries the other `r-2` variables' pins without
  fixing their model-dependent interleaving order. Any attempt to build such a second formula (a
  padded ξ, a skeleton) hits total-pin over-constraint.
- **`mergedFormula` / `MergePair.valid`: NOT directly reusable.** `mergedFormula`'s `pin` field is
  `fun v => e₁ (pin₁ v)` and `MergePair.valid` demands pin-compatibility `e₁(pin₁ v) = e₂(pin₂ v)`
  for **all** `r` variables. `liftPair` needs pin coincidence only at `k, l` (the two ξ-pinned
  variables); the other `r-2` variables pin freely to inserted skeleton points. So a **custom**
  merge datum + merged-formula is required (call it `LiftMergePair` / `liftMergedFormula`).
- **Scalar helper lemmas: FULLY reusable (this is the win).** All the order-theoretic/realization
  machinery generalizes verbatim to the custom merge:
  - `mergedSet` (sorted union of two witness chains) + `mergedSet_card_succ`;
  - `orderEmbOfFin_symm_apply`, `strictMono_rank`, `rank_orderEmbOfFin` (rank round-trip);
  - `strictMono_lt_iff_val_lt_filterCard` (the rank↔slot crux);
  - `belowCount` / `intervalSlot` / `chainIntervalType` / `chainIntervalType_eq_pointSlot` /
    `intervalSlot_eq_pointSlot`;
  - `chain_interval_clause` (three `efSat` region clauses → point-slot clause) and its inverse
    `regions_of_pointSlot`;
  - `intervalHolds_conj_of_both`, `intervalHolds_inter_left/right`.
- **Complete-point-type subtlety (new, decisive).** There is **no ⊤ complete point type**
  (`unaryHolds` fixes every atom; `nf_eval_unique`). So report-12's `skelR : ExistsForallFormula`
  with "⊤ point types" is **not constructible** as a single formula. The faithful skeleton is a
  `VeeExistsForall` disjoining over point-type assignments (landed as `skelR` this dispatch). The
  same device is mandatory inside `liftPair`: each inserted context point must range over **all**
  complete point-type completions (`charType`/`Finset.univ : Finset (UnaryType)`), else the forward
  direction fails on an arbitrary env value (this is exactly the blocked handoff's "trivial
  inserted point gives forward but not reverse" — resolved by the type-disjunction).

## Precise continuation blueprint for `liftPair` (next dispatch)

**Target (report 12 §c):**
```lean
noncomputable def liftPair (ξ : ExistsForallFormula sig F 2) (k l : Fin r) : VeeExistsForall sig F r
theorem liftPair_iff (N) (env : Fin r → N.carrier) (h : StrictMono env)
    (ξ : ExistsForallFormula sig F 2) (k l : Fin r) (hkl : k < l) :
    veeSat N env (liftPair ξ k l) ↔ efSat N ![env k, env l] ξ
```

**Definition (custom merge, mirrors `conjInterleave` §3–5):**
1. `structure LiftMergePair (n₂ K : Nat)` with `eξ : Fin (n₂+1) → Fin (K+1)` (ξ-chain embedding,
   here `n₂ = ξ.n`) and `eS : Fin r → Fin (K+1)` (skeleton embedding). `deriving DecidableEq`;
   `Fintype` via `equivProd` (copy `MergePair.equivProd`/instance verbatim, two functions).
2. `LiftMergePair.valid`: `StrictMono eξ ∧ StrictMono eS ∧ jointSurjective ∧ eS k = eξ (ξ.pin 0)
   ∧ eS l = eξ (ξ.pin 1)` (pin coincidence ONLY at `k,l` — the sole change from `MergePair.valid`).
   Decidable by `infer_instance`.
3. `liftMergedFormula ξ (σ : Fin (K+1) → UnaryType) (m : LiftMergePair ξ.n K) : ExistsForallFormula
   sig F r` where
   - `n := K`; `pin := m.eS` (each context variable → its skeleton point);
   - `pointType j := if j ∈ image eξ then ξ.pointType (preimage) else σ j`
     (ξ's complete type at ξ-points; the ranged-over completion `σ j` at inserted points);
   - `intervalType t := chainIntervalType ξ m.eξ t` (ξ's interval slot containing `t`; the
     skeleton contributes ⊤ = `univ`, and `intervalConj S univ = S`, so no `∩` needed — just ξ's).
4. `liftPair ξ k l := (List.range (ξ.n + r + 1)).flatMap fun K =>
      (Finset.univ.filter (·.valid …)).toList.flatMap fun m =>
        (Finset.univ : Finset (Fin (K+1) → UnaryType)).toList.map (liftMergedFormula ξ · m)`
   (disjoin over merged size `K`, valid merges, AND point-type assignments `σ`). Enumeration bound:
   `K+1 ≤ (ξ.n+1) + r`.

**`liftPair_iff` proof (both directions, ≈ adapt `conjInterleave_forward`/`_backward`):**
- **Forward** (`efSat ![env k,env l] ξ → veeSat env liftPair`): let `xξ` be ξ's witness chain
  (`efSat` on `![env k,env l]`, so `env k = xξ (ξ.pin 0)`, `env l = xξ (ξ.pin 1)`). Set
  `S := mergedSet N xξ env` (sorted union); `w := S.orderEmbOfFin`; `eξ, eS` the rank maps.
  `valid`: `strictMono_rank`, joint-surjectivity (`rank_orderEmbOfFin` + `S = image xξ ∪ image
  env`), and `eS k = eξ (ξ.pin 0)` from `env k = xξ (ξ.pin 0)` (rank of equal values equal),
  `eS l = eξ (ξ.pin 1)` likewise (uses `hkl`/`h` to keep ranks well-defined). Choose
  `σ := fun j => charType N (w j)` (the ranged-over disjunct). Point types: ξ-points via ξ's
  clause; inserted points via `unaryHolds_charType`. Intervals: ξ's three region clauses placed by
  `chainIntervalType_eq_pointSlot` + `chain_interval_clause` (no `intervalHolds_conj_of_both`
  needed — single source). Membership via a `liftMergedFormula_mem_liftPair` lemma (copy
  `mergedFormula_mem_conjInterleave` bookkeeping, add the `σ`-`map` layer).
- **Reverse** (`veeSat env liftPair → efSat ![env k,env l] ξ`): from a satisfied disjunct
  `liftMergedFormula ξ σ m` with witness `w`, project `xξ i := w (eξ i)`. `env k = w (eS k) =
  w (eξ (ξ.pin 0)) = xξ (ξ.pin 0)` (by `valid`'s `eS k = eξ (ξ.pin 0)` + pin field `pin = eS`);
  same for `l`. Point types at ξ-points read back (the `if j ∈ image eξ` branch is `ξ.pointType`,
  need `eξ` injective ⇒ preimage is the right one — copy `mergedPointType_left`). Interval regions
  via `regions_of_pointSlot` fed by a point-slot clause proved with `chainIntervalType_eq_pointSlot`
  (inserted points are ⊤/irrelevant to ξ). The `σ`/inserted types are **discarded** (ξ doesn't see
  them). Assemble `efSat ![env k, env l] ξ` (note `pairProject`-style `![·,·]` pin via
  `Fin.forall_fin_two`, as in `lemma_32_2_forward`).

**Then wrap for the assembly (Phase 10b-ii):**
- `liftPairV (Ψ : VeeExistsForall sig F 2) (k l) := Ψ.flatMap (liftPair · k l)`, with
  `liftPairV_iff : veeSat env (liftPairV Ψ k l) ↔ veeSat ![env k, env l] Ψ` (per-disjunct
  `liftPair_iff` + `veeSat_flatMap` from `VeeConj.lean:40`).
- `liftSentence (ξ : ExistsForallFormula sig F 0) : VeeExistsForall sig F r` = degenerate `liftPair`
  (no fixed pins; all `r` context points inserted, all typed by the `σ`-disjunction). `liftSentence_iff`
  analogous (no `k,l` coincidence constraints; simplest merge case).
- `efSat_negation_general` assembly (report 12 §c chain): `efSat_negation_demorgan` →
  `efSat_negation_pair` (per pair, LANDED) → `liftPairV` to arity r → diagonal `pin k = pin l`
  routes to arity-1 Prop 3.5 negation (orthogonal) → existence-sentence negation via `liftSentence`
  → flatten same-arity-r disjuncts via `veeSat_append` (`VeeExistsForall.lean:72`). Signature
  UNCHANGED (plan lines 956–966); thread `hCapture`, do NOT discharge.

**Size/risk (revised down from report 12 for the helper-reuse, up for the type-disjunction):**
`LiftMergePair` + `liftMergedFormula` + `liftPair` def ≈ 80–140 lines; `liftPair_iff` ≈ 220–340
lines (forward+backward, mostly adapted from the two landed `conjInterleave` directions);
`liftPairV`/`liftSentence`/assembly ≈ 120–200 lines. **Recommend splitting**: land the def +
forward first (green commit), then backward (green commit), then the assembly — three green
milestones, one per sub-dispatch if needed.

## Verification at handoff

- Full `lake build` **EXIT 0 at 1770 jobs** (baseline).
- `completeness_discrete` axioms **byte-identical to baseline**:
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
  (sole `sorryAx` = pre-existing `KampPrior.lean:562`, Phase 13; untouched).
- `skelR_sat` (`LiftPair.lean`) = `[propext, Classical.choice, Quot.sound]` (no `sorryAx`).
- No new `sorry`, no vacuous defs, no new axioms. `LiftPair.lean` is an orphan (grep-audited).

## Reuse anchors (verified this dispatch)

- LANDED this dispatch (consume, do NOT re-prove): `charType`, `unaryHolds_charType`,
  `exists_unaryHolds`, `intervalHolds_top`, `skelDisjunct`, `skelR`, `skelR_sat` (`LiftPair.lean`).
- LANDED precursors (consume): `efSat_negation_pair`, `efSat_negation_demorgan`
  (`EFSatNegation.lean`).
- Merge helpers to reuse inside `liftPair` (`ConjInterleave.lean`): `mergedSet`,
  `mergedSet_card_succ`, `orderEmbOfFin_symm_apply`, `strictMono_rank`, `rank_orderEmbOfFin`,
  `strictMono_lt_iff_val_lt_filterCard`, `belowCount`, `intervalSlot`, `chainIntervalType`,
  `chainIntervalType_eq_pointSlot`, `intervalSlot_eq_pointSlot`, `chain_interval_clause`,
  `regions_of_pointSlot`, `mergedPointType_left` (as a template). Do NOT reuse `conjInterleave`,
  `mergedFormula`, `MergePair` verbatim (all-`r` pin-compat — see spike).
- `veeSat_flatMap` (`VeeConj.lean:40`), `veeSat_append` (`VeeExistsForall.lean:72`) for the wrap.
- Faithfulness: Rabinovich 2014 Lemma 3.2(1) (PDF p.4), Def 3.3 (p.4), Prop 4.3 ¬-case (p.6).
  Companion `.md` corrupt — cite PDF page
  (`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`).
