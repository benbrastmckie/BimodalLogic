# Phase 10b-ii Handoff — `liftPair` family landed; `efSat_negation_general` assembly blueprint

**Dispatch:** lean-implementation-hard-agent, single-phase focus (Phase 10, sub_phase 10b-i,
hard mode).
**Status:** Phase 10b-i **[COMPLETED]** — the full `liftPair`/`liftSentence` family is landed green +
axiom-clean. Phase 10b-ii (`efSat_negation_general` assembly) **[NOT STARTED]** — its 10b-i
dependencies are now all present; blueprint below. No `sorry`, no vacuous placeholder. `hCapture`
untouched (never reached — it belongs to the assembly and to Phase 10P/ζ).

## What landed this dispatch (green, sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]`)

All in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/LiftPair.lean` (orphan, off the live import
path — grep-audited; now also imports `VeeConj` for `veeSat_flatMap`).

1. `LiftMergePair (nξ r K)` — `eξ`/`eS` embeddings; `Fintype`/`DecidableEq`. `valid` (StrictMono
   both, jointly surjective, pin coincidence **only at `k,l`**: `eS k = eξ (ξ.pin 0)`,
   `eS l = eξ (ξ.pin 1)`); `validS` (the same minus coincidence, for the sentence lift);
   `crossConsistent ξ m σ` (inserted-point completions `ξ`-interval-admissible). All decidable.
2. `liftMergedPointType` + `liftMergedPointType_xi`/`_skel` (readback: `ξ.pointType i` at `ξ`-points,
   `σ j` at inserted points); `liftMergedFormula` (pin = `eS`; interval = `chainIntervalType ξ eξ`,
   single source — skeleton ⊤ drops out). **Generalized to arbitrary source arity `s`** (none use
   `ξ.pin`) so the arity-0 sentence lift reuses them.
3. `liftPair ξ k l` + `liftMergedFormula_mem_liftPair` + `exists_liftMergePair_of_mem`;
   `liftPair_forward`, `liftPair_backward`, **`liftPair_iff`** (the target):
   `veeSat N env (liftPair ξ k l) ↔ efSat N ![env k, env l] ξ` for `StrictMono env`, `k < l`.
4. `liftPairV Ψ k l := Ψ.flatMap (liftPair · k l)` + **`liftPairV_iff`**:
   `veeSat N env (liftPairV Ψ k l) ↔ veeSat N ![env k, env l] Ψ` (`StrictMono env`, `k < l`).
5. `liftSentence ξ` (arity-0 → arity-`r`, no pins) + membership + `exists_liftMergePairS_of_mem` +
   `liftSentence_forward`/`_backward` + **`liftSentence_iff`**:
   `veeSat N env (liftSentence ξ) ↔ efSat N ![] ξ` (`StrictMono env`).

**Verification:** full `lake build` EXIT 0 at **1770 jobs**; `completeness_discrete` axioms
byte-identical to baseline `[propext, sorryAx, Classical.choice, Lean.ofReduceBool,
Lean.trustCompiler, Quot.sound]` (sole `sorryAx` = pre-existing `KampPrior.lean:562`, Phase 13,
untouched). Every new lemma `#print axioms = [propext, Classical.choice, Quot.sound]` (no `sorryAx`).

## Continuation blueprint for `efSat_negation_general` (Phase 10b-ii)

**Target (plan lines 956-966, signature UNCHANGED — thread `hCapture`, never discharge):**
```lean
theorem efSat_negation_general … (hCapture : …) {r : Nat} (ψ : ExistsForallFormula sig F r) :
    ∃ Φ : VeeExistsForall sig F r, ∀ env : Fin r → N.carrier, StrictMono env →
      (¬ efSat N env ψ ↔ veeSat N env Φ)
```

**Decomposition of `¬ efSat` (LANDED, `EFSatNegation.lean`):** `efSat_negation_demorgan` gives
```
¬ efSat N env ψ ↔ (∃ p ∈ pairwiseProjections ψ, ¬ efSat N ![env p.1, env p.2.1] p.2.2)
                    ∨ ¬ efSat N ![] (existenceSentence ψ)
```
`pairwiseProjections ψ` (`ExistsForallLemmas.lean:139`) ranges over **ALL** ordered pairs
`(k,l) ∈ Fin r × Fin r` (diagonal and reversed included); each `pairProject ψ k l : …2` has
`pin = ![ψ.pin k, ψ.pin l]`, `pointType = ψ.pointType`, `intervalType = ψ.intervalType`
(`ExistsForallLemmas.lean:130`).

**Three pair classes — each needs different handling (this is why the assembly is NOT pure glue):**

- **`k < l` (the main case):** `efSat_negation_pair` (LANDED) gives `Φ_{k,l} : VeeExistsForall …2`
  with `∀ env2, env2 0 < env2 1 → (veeSat N env2 Φ_{k,l} ↔ ¬ efSat N env2 (pairProject ψ k l))`.
  Then `liftPairV Φ_{k,l} k l` is the arity-`r` disjunct:
  `veeSat N env (liftPairV Φ_{k,l} k l)  ↔[liftPairV_iff, needs k<l]  veeSat N ![env k,env l] Φ_{k,l}
   ↔[efSat_negation_pair, gate env k<env l from StrictMono env + k<l]  ¬ efSat N ![env k,env l] (pairProject ψ k l)`.
- **`k > l` (redundant — fold by symmetry):** `efSat N ![env k,env l] (pairProject ψ k l) ↔
  efSat N ![env l,env k] (pairProject ψ l k)` (both unfold to the SAME `∃ x, env k = x(ψ.pin k) ∧
  env l = x(ψ.pin l) ∧ …` — `pointType`/`intervalType` are `k,l`-independent). Prove a one-line
  `pairProject_swap_efSat` lemma; then the `k>l` pair's content is already carried by its `l<k`
  counterpart's disjunct. So **Φ only needs the `k<l` pairs** (plus diagonal + existence).
- **`k = l` (diagonal — needs a NEW 1-pin lift + arity-1 negation):** `¬ efSat N ![env k,env k]
  (pairProject ψ k k)` is a genuine **1-free-variable** condition (`env k = x(ψ.pin k)`, both pins
  equal). It is NOT subsumed by the `k<l` disjuncts. Two sub-tasks:
  1. **Arity-1 negation object.** Negate the 1-free-variable `∃∀`-object to a `VeeExistsForall …1`
     (`¬ efSat N env1 · ↔ veeSat N env1 ·`). Route through Prop 3.5 (`Prop35Assembly.lean` /
     `Prop35ExistsForall.lean` / `Prop35VeeLift.lean` — MAP THESE FIRST) or, if the negation engine
     `prop42_efSat_negation_general` already covers arity 1 with a `env`-order gate, reuse it. This
     is the one genuinely-unmapped piece — do a short research pass before coding.
  2. **`liftSingle` (a THIRD lift variant, ~1-pin).** Mirror `liftPair`/`liftSentence`: a
     `valid1 (pinξ1 : Fin 1 → Fin (nξ+1)) (k : Fin r)` with a single coincidence `eS k = eξ (ξ.pin 0)`.
     `liftMergedFormula`/`crossConsistent`/`liftMergedPointType` are ALREADY arity-generic, so only a
     new `valid1` predicate + `liftSingle`/`liftSingleV` def + forward/backward (near-verbatim copies
     of `liftPair_forward`/`_backward` keeping one coincidence) are needed (~150 lines). `liftSingle_iff:
     veeSat N env (liftSingle ξ k) ↔ efSat N ![env k] ξ` (no `k<l` hypothesis — diagonal has no order gate).
- **Existence sentence (`r=0` object):** `existenceSentence ψ : …0` (`ExistsForallLemmas.lean:327`).
  Negate it to a `VeeExistsForall …0` (arity-0 negation — same engine/bridge "at arity 0/2" per the
  plan note; MAP the arity-0 path), then lift with `liftSentence` (LANDED) to `VeeExistsForall …r`.
  `liftSentence_iff` gives `veeSat N env (liftSentence …) ↔ efSat N ![] (neg-object) ↔ ¬ efSat N ![]
  (existenceSentence ψ)`.

**Assembly (`veeSat_append`, `VeeExistsForall.lean:72`; `veeSat_flatMap`, `VeeConj.lean:37`):**
```
Φ := ((pairs with k<l).flatMap (fun (k,l) => liftPairV Φ_{k,l} k l))
     ++ ((diagonal k).flatMap (fun k => liftSingleV Φ_{k,k} k))
     ++ liftSentence (existence-neg-object)
```
Chain the iffs: `veeSat N env Φ ↔[veeSat_append ×2 + veeSat_flatMap]` (∃ k<l, veeSat (liftPairV …))
∨ (∃ k, veeSat (liftSingleV …)) ∨ veeSat (liftSentence …) `↔[the three class lemmas above]`
(∃ k<l, ¬efSat proj_{k,l}) ∨ (∃ k, ¬efSat proj_{k,k}) ∨ ¬efSat existence `↔[symmetry folds k>l;
re-expand to all pairs]` (∃ p ∈ pairwiseProjections, ¬efSat proj_p) ∨ ¬efSat existence
`↔[efSat_negation_demorgan]` ¬efSat ψ. Thread `hCapture` into every `efSat_negation_pair`/arity-1/
arity-0 call; never discharge.

**Estimated size/risk:** `pairProject_swap_efSat` ~15 lines (Low); `liftSingle` family ~150 lines
(Low-Med — near-copy of landed `liftPair_forward`/`_backward`); arity-1 + arity-0 negation objects
(**Med — needs the Prop 3.5 mapping research first**); assembly glue ~120-200 lines (Med — the
pair-class bookkeeping over `pairwiseProjections`, and the `k>l` symmetry fold, are fiddly). Recommend
splitting: (i) `pairProject_swap_efSat` + `liftSingle` family (green commit); (ii) arity-1/arity-0
negation objects (green commit); (iii) the `efSat_negation_general` assembly (green commit).

## Reuse anchors (all verified this dispatch)

- LANDED this dispatch (consume, do NOT re-prove): `liftPair`/`liftPair_iff`, `liftPairV`/
  `liftPairV_iff`, `liftSentence`/`liftSentence_iff`, and the generic `liftMergedFormula` /
  `liftMergedPointType`(`_xi`/`_skel`) / `crossConsistent` / `LiftMergePair` (`LiftPair.lean`).
- LANDED precursors: `efSat_negation_pair`, `efSat_negation_demorgan` (`EFSatNegation.lean`).
- Assembly glue: `veeSat_append` (`VeeExistsForall.lean:72`), `veeSat_flatMap` (`VeeConj.lean:37`),
  `pairwiseProjections`/`pairProject`/`existenceSentence`/`augTarget_iff` (`ExistsForallLemmas.lean`).
- Merge helpers (already used inside the lift; not needed again for the assembly):
  `mergedSet`-style sorted-union, rank round-trip, `strictMono_lt_iff_val_lt_filterCard`,
  `chain_interval_clause`, `regions_of_pointSlot`, `chainIntervalType_eq_pointSlot`,
  `intervalSlot_eq_pointSlot` (`ConjInterleave.lean`).
- **UNMAPPED — research first:** the arity-1 (Prop 3.5) and arity-0 negation objects
  (`Prop35Assembly.lean`, `Prop35ExistsForall.lean`, `Prop35VeeLift.lean`,
  `Prop42NegationGeneral.lean`). Do a short read pass before coding class (c) and the existence sentence.
- Faithfulness: Rabinovich 2014 Lemma 3.2(1) (PDF p.4), Def 3.3 (p.4), Prop 4.3 ¬-case (p.6). Cite by
  PDF page (`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`;
  companion `.md` corrupt).
