# Research Report — Task 335: Outer-Gate Assembly Engine (`kvE2_body` / `bracketEndChar_kvE2`)

**Task type**: lean4
**Session**: sess_1783546987_0faeae_335
**Date**: 2026-07-08
**File scope**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/`
**Status**: researched

## Executive Summary

The outer gate has **no live definition** in the source tree — the only actual `def`s of
`kvE2_body` / `bracketEndChar_kvE2` live in the quarantined Boneyard
(`Theories/Bimodal/Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean`), and they
encode the **superseded** task-321-v4 two-level "navigated" carrier that failed-closer history
NS:423-435 documents as un-assembled. Task 334 delivered a **re-architected faithful carrier**
`kvE2_sepBody` (in `SharedWitness.lean`) that is verified sorry-free and axiom-clean, together
with the exact structural lemmas (`kvE2_sepBody_holds_iff`, `kvE2_sepBody_extract`) that
directly **disarm** the four historical failed closers. This task assembles that verified
carrier into the do-not-edit interface `BracketCarrierCorrectVPrior` at `k = 2`.

The carrier is a **verified INPUT** — it must not be re-proved. All axiom checks below were run
live via `lean_verify`.

---

## (1) Current State of `kvE2_body` / `bracketEndChar_kvE2` — NO LIVE DEF

**Confirmed: no live definition exists.** A full grep over `Theories/` for
`kvE2_body` / `bracketEndChar_kvE2` finds actual `def`/`theorem` bodies **only** in the Boneyard:

| Symbol | Location (Boneyard, quarantined) |
|--------|----------------------------------|
| `kvE2_body` (def) | `MergedBracketQuarantine.lean:814` |
| `kvE2_body_gate_fail` (thm) | `:901` |
| `bracketEndChar_kvE2` (def) | `:918` |
| `bracketEndChar_kvE2_two_eq` (thm) | `:933` |

The Boneyard `kvE2_body` (:814) is the **two-level** carrier: `let`-bound `S_L`/`S_R`/`mkDisjunct`
build a doubly-nested `S_L.permutations.flatMap (S_R.permutations.map ...)` product, with the
per-sub joint slot spliced via `kvE_subChain2V`. This is the shape that F4 blocked and that the
four failed closers (below) could not assemble.

**Every other occurrence in the live tree is doc/decision-record prose, not a live path**:
- `NavigatedSpine.lean:385-449` — the RESCOPE decision record (Phase-7 "genuine unbuilt ENGINE").
- `NavigatedSpine.lean:200-219`, `SubBracket.lean:218-239`, `SubBracket2V.lean` — narrative refs.

Confirmed via `git`: the live tree's most recent carrier work is task 334
(`76f3fbe2f task 334 phase 8: … kvE2_sepBody_complete`).

---

## (2) Verified Carrier Inputs (task 334, all in `SharedWitness.lean`)

The faithful carrier replacing the Boneyard `kvE2_body` is **`kvE2_sepBody`** — a flat
order-type disjunction (one flat bracket per valid weak order), *not* a two-level product.

**Type compatibility (key)**: `kvE2_sepBody charBase charK : NormalForm sig 2 3 → VVecEA2`,
which is **definitionally** `BracketEndCharCarrierV sig 2` (`CarrierK1V.lean:365`:
`abbrev BracketEndCharCarrierV sig k := NormalForm sig k 3 → VVecEA2`). So the wrapper into the
gate is a direct delegation — no shape adaptation needed.

Carrier + correctness inputs (signatures grounded in source):

| Symbol | Line | Role |
|--------|------|------|
| `kvE2_sepBody (charBase) (charK) (qnf : NormalForm sig 2 3) : VVecEA2` | :806 | The faithful carrier; gate-true → `(kvE2_sepArr' qnf).map (kvE2_sepDisjunct …)`, gate-false → empty. |
| `kvE2_sepBody_gate_fail` | :825 | Gate-false branch = `{ disjuncts := [] }`. |
| `kvE2_sepBody_holds_iff` | :840 | **O2 collapse**: on gate-true, `holds ↔ ∃ wo ∈ kvE2_sepArr' qnf, (kvE2_sepDisjunct …).2.holds`. Proven by `rw [dif_pos]` because the builder/sets are top-level (fixes failed-closer #3). |
| `kvE2_sepBody_nonvacuous` | :1382 | **⇒ non-vacuity**: honest realization + `x<w<t` + `kvE2_sepDisjValid (modelOrder) = true` ⟹ `disjuncts ≠ []`. |
| `kvE2_sepBody_complete` | :1531 | **⇐ completeness**: honest realization + `x<w<t` + `hL : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3` (all positive owners **left-interior**) ⟹ `kvE2_sepArr' qnf ≠ []` (via the coincidence order). |
| `kvE2_sepBody_extract` | :1955 | **O3 soundness extraction**: `holds` ⟹ `epL@x ∧ epR@t ∧ ∃w, x<w<t ∧ ptW@w ∧ (∀ left-interior σ, bundleL) ∧ (∀ right-interior σ, bundleR)`. |
| `kvE2_sepArr'_sound` | :2536 | ⇒ order-type: a held `wo ∈ kvE2_sepArr'` carries every per-owner validity bit. |
| `kvE2_sepHonestBundleL/R` | :1207/:1259 (private) | Honest bundle builders (⇐ realization content). |
| `kvE2_sepBundleL/R_parts` | :1634/:1656 | Unpack a bundle into the 5-tuple `kvE_subBracket2V_sound_of_parts` consumes. |

**Axiom-cleanliness (verified live this session with `lean_verify`)** — all return
`{"axioms":["propext","Classical.choice","Quot.sound"],"warnings":[]}` (no `sorryAx`):
- `kvE2_sepBody_complete` ✓
- `kvE2_sepBody_nonvacuous` ✓
- `kvE2_sepBody_extract` ✓

No bare `sorry`/`admit` tactic occurs in `SharedWitness.lean` or `NavigatedSpine.lean` (all
matches are `sorry-free` doc prose). Matches task-334 plan acceptance criterion (line 408).

---

## (3) Outer-Gate Interface KampPrior Consumes

**The interface is `BracketCarrierCorrectVPrior`** (`PriorInterface.lean:60`):

```
def BracketCarrierCorrectVPrior (atomMap) {k} (carrier : BracketEndCharCarrierV sig k) : Prop :=
  ∀ (qnf : NormalForm sig k 3)
    (h_xy … h_tx : «6 bracket-zone order-atom hypotheses»)   -- x<w<t zone (PriorInterface:63-68)
    (M) (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap) (x t : M.carrier),
    (carrier qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

The **k = 2 target** (per NS:389 and the RESCOPE record) is:
`BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2 atomMap h_surj P)`, with
`P : ExistProviders sig atomMap 1` (`PriorInterface:38`) and standard instantiation
`charBase = nf_depth0_char_formula atomMap h_surj`, `charK = fun χ => P.existF 0 χ`.

**Landed pattern to mirror** (k ≤ 1, `PriorInterface`): `bracketEndChar_kv_correct_zero_prior`
(:80) and `bracketEndChar_kv_correct_one_prior` (:95) both discharge the predicate for the
general `bracketEndChar_kv` carrier by lifting the landed unconditional `_zero`/`_one`
correctness lemmas. The k = 2 gate is the missing rung.

**`KampPrior.lean:351` is the consumer** — the `| 1 =>` `sorry` inside
`nf_nvar_exist_all_depths` (`KampPrior.lean:347-354`):

```
| 1 =>   -- n = 1: ∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf  (critical case)
    sorry          -- line 351
| n + 2 => sorry   -- line 354, off critical path
```

The depth-2 evaluation `nf_eval_nf M 2 3 …` unfolds (NormalForm:203-207, per NS:408-409) to the
atom layer plus the outer quant layer
`∀ sub : NormalForm sig 1 4, (∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] sub) ↔ qnf.2 sub = true`.

**Important integration note (grounded)**: `KampPrior.lean` does **not yet reference**
`bracketEndChar_kvE2` or `BracketCarrierCorrectVPrior` anywhere (grep-0). The `:351` sorry is
currently free-standing. This task's deliverable is the **gate itself** (the live
`bracketEndChar_kvE2` + the k=2 `BracketCarrierCorrectVPrior` proof). **Wiring the gate into the
`:351` sorry** (threading `ExistProviders` through KampPrior's `Nat.rec`) is a distinct downstream
integration step, not part of the outer-gate assembly — flag it for the planner as a separate
phase or follow-on task.

---

## (4) Failed-Closer History (NavigatedSpine:423-435)

Captured crux (soundness/mp direction, after `intro qnf … M h_UZ h_SZ x t; constructor; intro
hcarrier`):

```
hcarrier : VVecEA2.holds M atomMap (bracketEndChar_kvE2 atomMap h_surj P qnf) x t
⊢ ∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x fun x ↦ t)) qnf
```

Four failed closers on the OLD Boneyard `kvE2_body` (≥2 required by task-327 evidence style):

1. `exact kvE_subBracket2V_sound_of_outer … qnf.2` → **type mismatch**: `qnf.2 : NormalForm sig 1
   (3+1) → Bool` vs expected `NormalForm sig 1 4`. **Lesson**: the interior closer is PER-SUB (one
   `σ`); the *connector* — not the closer — must range over subs.
2. `simp only [bracketEndChar_kvE2, kvE2_body, VVecEA2.holds, VecEA2.holds] at hcarrier` → unfolds
   to the full two-level arrangement-disjunct existential; goal unsolved (no bridge from disjunct
   to depth-2 eval).
3. `rw [VVecEA2.holds_flatMap_map] at hcarrier` → **pattern not found**: the OLD `kvE2_body`'s
   `let`-bound `S_L`/`S_R`/`mkDisjunct` are not externally nameable (Phase-4 scope note). **This
   is the crucial lesson the task-334 carrier fixes**: `kvE2_sepBody`'s builder + enumeration are
   TOP-LEVEL defs, and `kvE2_sepBody_holds_iff` (:840) already performs the collapse via
   `rw [dif_pos]` — the docstring explicitly cites "crux failed-closer-3 lesson: no `let`-buried
   `S_L`/`S_R`/`mkDisjunct`".
4. `aesop` → failed after exhaustive search.

Consequence (NS:441-449): honest RESCOPE — **no `sorry`**, **no gate-modulo-assumed-`hgate`**
committed. The deferred engine was named `kvE2_outer_fold` (the two-level quant-layer fold).

The five-part connector obligation the RESCOPE named (NS:414-419): (a) unpack the arrangement
disjunct, (b) build the outer witness `w` at the `ptW` slot, (c) type each depth-1 witness via
`ExistProviders.correct`, (d) discharge each positive sub's inner `∃ x1` via its navigated
sub-chain + per-sub `hgate`, (e) thread the depth-2 quant-layer fold.

---

## (5) Concrete Assembly Strategy

**Why this is now tractable**: the task-334 carrier `kvE2_sepBody` structurally disarms failed
closers #2/#3 (top-level builder → `kvE2_sepBody_holds_iff` collapse works), and `kvE2_sepBody_extract`
already lands obligations (a)+(b) plus the per-σ bundles for (d). The flat one-bracket-per-weak-order
shape removes the two-level `S_L × S_R` nesting entirely, so failed closer #1's level mismatch does
not recur.

**Placement**: a new file `NfMultiAnchorBridge/OuterGate.lean` importing `…SharedWitness` (which
transitively imports `PriorInterface`, so `BracketCarrierCorrectVPrior`/`ExistProviders`/
`BracketEndCharCarrierV` are in scope), then added to the `NfMultiAnchorBridge.lean` aggregator.
Appending to the end of `SharedWitness.lean` also works but a sibling file keeps the task isolated.

**Phase 1 — live wrapper def + rfl bridge** (mirror Boneyard :918/:933 but delegate to the
*faithful* carrier):
```
noncomputable def bracketEndChar_kvE2 (atomMap) (h_surj) (P : ExistProviders sig atomMap 1)
    : BracketEndCharCarrierV sig 2 :=
  fun qnf => kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) (fun χ => P.existF 0 χ) qnf
-- plus bracketEndChar_kvE2_two_eq : … = kvE2_sepBody … := rfl
```

**Phase 2 — ⇒ soundness half** of `BracketCarrierCorrectVPrior` (`holds → ∃w realization`):
- `rw [bracketEndChar_kvE2_two_eq]`; apply `kvE2_sepBody_extract` → `epL@x, epR@t, ∃w (x<w<t),
  ptW@w, per-σ bundleL/R`.
- Per positive `σ`: `kvE2_sepBundleL/R_parts` → 5-tuple → `kvE_subBracket2V_sound_of_parts`
  (`SubBracket2V.lean:1290`) reconstructs σ's inner realization.
- Type each depth-1 witness via `P.correct` (`ExistProviders.correct`, PriorInterface:41), then
  assemble the outer witness `w` and discharge the depth-2 quant layer
  `∀ sub, (∃x1, nf_eval_nf M 1 4 [x1,w,x,t] sub) ↔ qnf.2 sub` (obligations (c)+(d)+(e)). This is
  the substantive connector, but with (a)/(b)/(d-inputs) pre-landed by `_extract`.

**Phase 3 — ⇐ completeness half** (`∃w realization → holds`), LEFT-INTERIOR class:
- From the realization + `x<w<t`, `kvE2_sepGate_holds_of_honest` gives the gate; `kvE2_sepBody_complete`
  (needs `hL` left-interior) gives a present valid disjunct `wo ∈ kvE2_sepArr'`.
- Build that disjunct's realization at `(x,t)` from `kvE2_sepHonestBundleL/R` + `kvE2_sepArr'_sound`,
  then close via `kvE2_sepBody_holds_iff` (mpr).

**Phase 4 — right-interior generalization / scope decision** (see Risk below).

### Risks & Open Sub-Obligations (zero-debt — flag, do not `sorry`)

- **R-A (⇐ generality)**: `kvE2_sepBody_complete` currently requires `hL` (all positive owners
  left-interior; `nf0_zoneSpec σ.1 = kvE2_sep_zXW3`). Right-interior owners' honest closed bit
  `zAtX1R` is proved (`kvE2_sepCoincidentAnchor_discharge_R`) but **not yet read** by the validity
  channel (`kvE2_sepDisjValidOwner`) — a tracked carrier-redefinition follow-up (SW:1527-1530;
  334-plan lines 417-419). Two zero-debt options for the planner: (i) restrict the k=2 gate target
  to the left-interior class the carrier serves and prove full `BracketCarrierCorrectVPrior` only
  there; or (ii) extend `kvE2_sepDisjValidOwner` to the placement-generic self-zone first (a
  carrier-input redefinition — would touch the "verified INPUT", so must be scoped carefully). This
  is a genuine scoping decision, **not** a blocker for Phase 1-3.
- **R-B (KampPrior wiring)**: producing the gate does not by itself close `KampPrior:351`; the
  `ExistProviders` threading through `nf_nvar_exist_all_depths`'s `Nat.rec`/`n=1` case is a further
  integration step (see §3). Decide whether it is in scope for task 335 or a follow-on.
- **R-C (soundness connector size)**: Phase 2 (c)+(e) is the real engine work; keep it in one phase
  bounded to a single agent run, verifying with `lean_goal` at each `have`.

### Faithfulness (F1–F7)
The carrier inputs already satisfy F1–F7 (task 334, plan line 411). The assembly must **preserve**
them: no vacuous placeholders (F2 non-vacuity via `kvE2_sepBody_complete`/`_nonvacuous`), no
conflation of open/closed zone keys (F5), no `x1 < e_i` relative-position literal (LITMUS — NS:437),
witness bounds from the bracket range not a chain.

---

## Sources (all line numbers grounded in current source)

- `NfMultiAnchorBridge/SharedWitness.lean` — `kvE2_sepBody` :806, `_holds_iff` :840, `_nonvacuous`
  :1382, `_complete` :1531, `_extract` :1955, `kvE2_sepArr'_sound` :2536, honest bundles :1207/:1259.
- `NfMultiAnchorBridge/PriorInterface.lean` — `ExistProviders` :38, `BracketCarrierCorrectVPrior`
  :60, k≤1 lifts :80/:95.
- `NfMultiAnchorBridge/CarrierK1V.lean:365` — `BracketEndCharCarrierV`.
- `NfMultiAnchorBridge/SubBracket2V.lean:1290` — `kvE_subBracket2V_sound_of_parts`.
- `NfMultiAnchorBridge/NavigatedSpine.lean:200-219` (holds_flatMap_map + scope), `:385-449` (RESCOPE
  + failed closers :423-435).
- `Kamp/KampPrior.lean:340-354` — `nf_nvar_exist_all_depths` `n=1` sorry (`:351`).
- `Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean:814/901/918/933` — superseded defs.
- `specs/334_faithful_carrier/plans/03_faithful-carrier-regrounding.md` — Risks R3/R4 (lines
  135-136), scope note (line 419, 428-430), acceptance (line 408).
