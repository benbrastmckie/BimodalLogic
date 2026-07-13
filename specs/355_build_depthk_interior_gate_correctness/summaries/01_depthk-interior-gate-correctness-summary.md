# Implementation Summary: Task #355 — depth-k interior gate correctness

- **Status**: BLOCKED — Phases 1-5 + 6.1 GREEN; Phase 6 ∀-`k` clean close BLOCKED (frozen target
  shape / F1); Phase 7 not reached.
- **Latest dispatch**: Phase 5 (⇒ soundness) + Phase 6.1 (step biconditional) — see the "Phase 5-6
  dispatch" section immediately below.

---

## Phase 5-6 dispatch (this dispatch — F1-critical soundness + block)

- **Module**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean` (additive, +~200 lines)
- **Build**: scoped GREEN (1020 jobs) AND full-tree `lake build` GREEN (1724 jobs).
- **Axioms**: both new theorems at EXACTLY `[propext, Classical.choice, Quot.sound]` (verified).
- **Frozen files**: all 13 byte-identical (only `open private` + import-only adds; no edits).
- **Debt**: 0 `sorry`/`admit`/vacuous defs; forbidden `nf_char3_deeper_split` grep clean.

### Delivered GREEN

**`bracketEndChar_kv_step_sound`** (Phase 5 — the F1-critical ⇒ soundness half). From
`(bracketEndChar_kv … (k+1) qnf).holds M atomMap x t`, under three NAMED depth-`k` provider
obligations, reconstructs `∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf`. Route: `bracketEndChar_kv_succ_holds_iff.mp`
(Phase 3) → destructure gate + arrangement disjunct → (open private) `k1v_bracket_extract` yields the
bracket witness `w` (`x<w<t`) + its raw `igPtW` eval → endpoint/witness char heads via
`interiorGate_hcb` → (open private) `k1v_reconstruct_nf3` rebuilds the depth-0 atom layer → the per-sub
fold biconditional (defeq via `nf_eval_nfk_iff_efold`'s internal `Iff.rfl`, `NfEFold.lean:643`) is
`hreal` forward (marked→realizable) and `hexcl`+`hexclExt` backward (unmarked→realized-nowhere, cone ∪
exterior covering all `x1`). The lossy fold BITS are never read (F1 channel intact — the obligations,
not a pointwise collapse, supply the fiber content). Mirrors the k=2 template
`bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean:268`) but is NOT fragment-restricted (the
full `S_L`/`S_R` permutation arrangement is admissible under the named obligations).

**`bracketEndChar_kv_step_correct`** (Phase 6.1 — step biconditional). `⟨sound (Phase 5),
complete (Phase 4)⟩` at symbolic `k+1`, carrying the union of both halves' hypotheses
(`P`/`hcharK`/UZ/SZ + `hreal`/`hexcl`/`hexclExt`). Mirrors the k=2 assembly
`bracketEndChar_kvE2_correct_two_prior_frag` (`OuterGate.lean:359`).

### Why BLOCKED at the Phase 6 ∀-`k` close

The frozen `InteriorGateTarget` (Phase 1) = `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`)
is the CLEAN, obligation-FREE biconditional. It is F1-refuted at `k ≥ 2`: `bracketEndChar_kv_factors`
(`CarrierKv.lean:422`) shows the fiber-existential fold determines `.holds` but NOT the realizer, and
the carrier only builds `P.existF 0` (1-type) literals — it never invokes `P.existF 3` (arity-4), so
`.holds` + `P` alone has no channel to the arity-4 fiber content the ⇒ direction needs. The captured
stuck `lean_goal` (context has NO `P`, NO `hcharK`, NO `hreal`/`hexcl`/`hexclExt`;
goal `⊢ ∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf` from `h_holds` alone) is recorded verbatim in the plan
Phase 6 BLOCKER. Even at k=2 only the obligation-carrying `_correct_two_prior_frag` exists — a clean
`BracketCarrierCorrectVPrior` was NEVER delivered at k ≥ 2. The base rungs k=0/k=1 discharge the clean
target only because their fibers are trivial / pointwise-lossless.

**Rabinovich-faithfulness (2014, Lemma 7.6 + Cor 5.4)**: the block is FAITHFUL to the paper, NOT a
divergence. The interior gate is the single-bracket `[x,t]` characterization (Cor 5.4 / Lemma 5.1
`¬[α0,…,αn](z0,z1)` chain; §5 bracket). Recovering the F1-lossy fiber content from provider
obligations IS the paper's move WITHIN one bracket — `P.existF n` is exactly Rabinovich's ∨→∃∀
existential converter (Cor 5.4), and `hreal`/`hexcl` are the within-`[x,t]` ∃-placement + segment
exclusions. But `hexclExt` (an unmarked sub realized OUTSIDE `[x,t]`) is NOT a within-bracket move: it
is precisely Lemma 7.6's ADJACENCY COMPOSITION — `(∃z1)^{<z2}_{>z0}(φ1∧φ2)` composing a `(z0,z1)`
bracket with an adjacent `(z1,z2)` bracket across the shared endpoint. The paper handles exterior
witnesses via this SEPARATE lemma (adjacent brackets), never within a single bracket. The formalization
faithfully mirrors that division: interior gate = task 355; exterior adjacency = tasks 348/351/352/354
(the exterior-bracket layer, an explicit task-355 NON-goal). Consequently the clean
`InteriorGateTarget` is STRONGER than the paper's single-bracket result; the provable, faithful
deliverable is the obligation-carrying `bracketEndChar_kv_step_correct` (delivered).

### What is needed to unblock (plan decision, not more interior-gate code)

(a) **Revise the deliverable shape**: re-freeze task 355's DoD as the obligation-carrying general-`k`
biconditional (the `_correct_two_prior_frag` analog, already delivered as `bracketEndChar_kv_step_correct`
at symbolic `k+1`; a ∀-`k` wrapper carries the obligations uniformly), and verify the task-349 consumer
`EndIntervalCorrectPrior` accepts it (the k=2 consumer KampPrior:351 supplies exactly these
obligations, so it very likely does). — OR —
(b) **`/spawn 355`** a dedicated exterior-adjacency sub-task to discharge the `hexclExt` residue via
Rabinovich Lemma 7.6 (adjacent-bracket composition), enabling a clean obligation-free ∀-`k` close.
This is the exterior-bracket layer, out of interior-gate scope. Recommended atomic sub-lemma:
`bracketEndChar_kv_hexclExt_discharge` — "an unmarked depth-`k` arity-4 sub is realized at no
strictly-exterior `x1`", via the exterior adjacency composition.

---

## (Historical) Phases 1-2 dispatch
- **Module**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean` (NEW, additive)
- **Build**: scoped `lake build …InteriorGateGeneralK` GREEN (1015/1015)
- **Axioms**: all four new theorems at exactly `[propext, Classical.choice, Quot.sound]`
- **Frozen files**: all 13 byte-identical (verified via `git diff --stat`)

## Phases executed

### Phase 1 — statement freeze + base-rung reconciliation [COMPLETED]
- Created the additive sibling module importing `PriorInterface` + `OuterGate`.
- `InteriorGateTarget atomMap h_surj charF k := BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv atomMap h_surj charF k)` — the frozen provider-guarded deliverable shape (F1-mandated; the unconditional k≥2 variant is refuted by `bracketEndChar_kv_factors`, CarrierKv.lean:422).
- `interiorGateTarget_zero` / `interiorGateTarget_one`: validate the freeze by discharging the k=0/k=1 instances against the landed `bracketEndChar_kv_correct_zero_prior`/`_one_prior` (PriorInterface.lean:80/95). Freeze confirmed correct before any step proof.

### Phase 2 — depth-k provider / char truth bridges [COMPLETED]
- `interiorGate_hck`: general-k analog of `bracketEndChar_kvE2_hck` (OuterGate.lean:123) — `temporal_truth M atomMap u (P.existF 0 χ) ↔ nf_eval_nf M k 1 (fun _ => u) χ` via `ExistProviders.correct` at n=0 + the `insertEnv`/`Fin.elim0` env collapse.
- `interiorGate_hcb`: depth-0-general char-base bridge (re-export of `bracketEndChar_kvE2_hcb`, fold-depth-independent).

## Theorems delivered (all sorry-free, axiom-clean)
`InteriorGateTarget` (def), `interiorGateTarget_zero`, `interiorGateTarget_one`, `interiorGate_hck`, `interiorGate_hcb`.

## Why stopped at Phase 2 (green milestone)

Phase 3 (holds_iff destructuring) is the start of the ~700-1300-line open construction and hits a **verified structural obstacle**: `kv_body` — which holds the successor carrier's internal `S_L`/`S_R`/gate/`mkDisjunct` structure — is `private` in the frozen (uneditable) `CarrierKv.lean:152` and referenced nowhere outside it. No public holds-unfold lemma exists, and `RefutationF2.lean` only ever touches the k=2 carrier's `.holds` via the public congruence `bracketEndChar_kv_factors` + concrete computation (not a general destructuring). Phase 3 therefore requires a public body-replica + `rfl` defeq bridge before any semantics. Per the orchestrator no-red/no-sorry-stop mandate, work stopped at the Phase-2 phase boundary rather than leave the module in a red or sorry state.

## Continuation
See `.orchestrator-handoff.json` `continuation_context` for the grounded Phase-3 obstacle, the recommended body-replica-plus-`VVecEA2.holds_flatMap_map` path, and the Phase 4-5 open-construction note.

## Guard compliance
G1-G5 respected on delivered lemmas; FORBIDDEN `nf_char3_deeper_split` grep-clean; no vacuous defs; additive-only (frozen diffs EMPTY).

---

## Phase 4 dispatch (⇐ completeness) — COMPLETED

Resumed from HEAD `954132d10` (Phases 1-3 green). Phase 3 already delivered
`bracketEndChar_kv_succ_holds_iff` (the successor-carrier `.holds` destructuring). Phase 4 proves the
completeness half of the k→k+1 step, delivered as four green sub-commits.

**Deliverables (all axiom-clean `[propext, Classical.choice, Quot.sound]`):**

- `igZone3_consistent` — generic seven-zone order trichotomy over `[w,x,t]` (analog of the k=2
  private `kvE2_sep_zone3_consistent`).
- `bracketEndChar_kv_step_gate` (4a) — the honest gate `igGate (igOffFiber qnf) (igFoldBit qnf)` from
  a genuine realizer. Off-fiber conjunct = the off-fiber clause of the generic
  `nf_eval_nfk_iff_efold`; seven-zone conjunct via `nf_eval_nf_atom_layer` + `igZone3_consistent`.
- `igFoldBit_realize_iff` (4b fiber bits) — the fold-realization biconditional
  `igFoldBit qnf zs χ = true ↔ ∃ u, zoneHolds M [w,x,t] zs u ∧ nf_eval_nf M k 1 (fun _ => u) χ`.
  ⇒ via `nf_eval_projFresh`; ⇐ via `nf_characteristic_satisfies` + `nf_eval_unique`. Kept
  FIBER-EXISTENTIAL (F1 channel preserved).
- `igk_sorted_realization` (4b sort) — general-`k` arrangement selection over `NormalForm sig k 1`.
- `bracketEndChar_kv_step_complete` (4b main) — from the arity-3 realizer, the successor carrier
  `.holds` at `(x,t)`, via `bracketEndChar_kv_succ_holds_iff`'s RHS. Faithful depth-`k` transcription
  of the depth-1 engine `bracketEndChar_k1v_complete`.

**Key techniques:** (1) `open private` (Batteries.Tactic.OpenPrivate) pulls the depth-agnostic k1v
completeness helpers (`k1v_sorted_insert`, `k1v_bracket_construct`, `k1v_extract_x/t/y_nf3`,
`k1v_zoneHolds_cons_iff`) from the frozen `CarrierK1V.lean` — consumption only, no edit. (2) A new
import of the frozen `ExteriorBracketK.lean` (import-only, byte-identical) for `nf_eval_projFresh`.

**Design deviation:** the completeness direction realizes the arity-1 interior 1-types via the
PROVIDER (`interiorGate_hck` under `hcharK : charF k = fun χ => P.existF 0 χ`), NOT via the arity-3
IH. `bracketEndChar_kv_step_complete` carries `(P : ExistProviders sig atomMap k)`, `hcharK`, and
UZ/SZ, mirroring the k=2 template `bracketEndChar_kvE2_complete_two_prior`.

**Verification:** scoped + full-tree `lake build` GREEN (1724 jobs); all new theorems axiom-clean;
0 sorry/admit, 0 vacuous defs, 0 forbidden `nf_char3_deeper_split`; all 13 frozen files byte-identical.

**Remaining:** Phase 5 (⇒ soundness, F1-critical open construction — no drop-in template; a clean
`[BLOCKED]` under the guarded statement is an acceptable terminus, never a sorry), Phase 6 (step
biconditional + `∀k` `Nat.rec`), Phase 7 (final audit + consumability). See `.orchestrator-handoff.json`.
