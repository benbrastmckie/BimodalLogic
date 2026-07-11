# Task 335 v5 — Post-345 Continuation Handoff (Phase B LANDED, Phase C NO-GO, Phase D BLOCKED)

- **Session**: sess_1783723095_edd5a7_335
- **Date**: 2026-07-10
- **Status**: partial — Phases 1/2/3/A/B COMPLETED (green, committed); Phase C `hexcl` = **NO-GO**
  (machine-confirmed); Phase D BLOCKED on C.
- **Build**: `lake build …NfMultiAnchorBridge.OuterGate` green. `SharedWitness.lean` /
  `SubBracket2V.lean` byte-unchanged (341 frozen-file gate intact). Zero sorries on live paths.
  Axiom-clean `{propext, Classical.choice, Quot.sound}`.

## What changed since 02_continuation.md (the pre-345 blocker)

Task 345 landed the SYMMETRIC gate (Rabinovich Cor 5.4, clause (v)), dissolving `hInnerR` and
delivering the pin-anchored fold `kvE2_outer_fold_frag` (`SharedWitness.lean:12529`). The pre-345
four-family wall (`hgateL`/`hgateR` FORWARD conjunct) is GONE: `hgateL`/`hgateR`/`hbdry` are now
internal to the fold, discharged inside `kvE2_sepBody_kit_sound_frag` (SW:12487) under `hfrag`. The
fold's only obligations beyond the provider shape are `hfrag` + `hcorrK` + `hexcl`.

## Per-phase outcome

| Phase | Status | Notes |
|-------|--------|-------|
| 1 (def + `rfl` bridge) | COMPLETED (carryover) | untouched |
| 2 (⇐ completeness) | COMPLETED (carryover) | untouched |
| 3 (retire note + citation) | COMPLETED (carryover) | untouched |
| A (fragment predicate + shells) | COMPLETED (carryover) | `kvE2_sepFragment` committed green |
| **B (⇒ soundness half)** | **COMPLETED (this session)** | `bracketEndChar_kvE2_sound_two_prior_frag` landed green + axiom-clean over `kvE2_outer_fold_frag`; `hcorrK` discharged inline; `hexcl` threaded as hypothesis |
| **C (`hexcl` GO/NO-GO)** | **BLOCKED — NO-GO** | machine-confirmed; see below |
| D (assemble + 309-v8 note) | BLOCKED | gated on C |

## Phase B — LANDED (committed `c508e2a48`)

`bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean`): provider shape (6 order bits + `M` +
`h_UZ`/`h_SZ` + `x t`) + `hfrag : kvE2_sepFragment qnf` + `hexcl` (negative-sub exclusion) ⟹
`.holds → ∃ w, nf_eval_nf M 2 3 [w,x,t] qnf`. Proof:
```
intro h_holds; rw [bracketEndChar_kvE2_two_eq] at h_holds
exact kvE2_outer_fold_frag atomMap h_surj (fun χ => P.existF 0 χ) qnf
  h_xy h_yt h_xt h_yx h_ty h_tx M x t h_holds hfrag
  (fun σ a hσa => (bracketEndChar_kvE2_hck atomMap P M h_UZ h_SZ (nfk_projFresh σ) a).mp hσa)
  hexcl
```
- `hfrag : kvE2_sepFragment qnf` passes as the fold's `kvE2_sepFragment_frag qnf` by defeq (identical
  body, SW:10219).
- `hcorrK` discharged inline from `bracketEndChar_kvE2_hck` (`.mp`); `TemporalPred.eval_at` unfolds to
  `temporal_truth` so the anonymous-constructor hypothesis matches.
- Order bits defeq `qnf.atom_assgn = qnf.1` at depth 2.

## Phase C — `hexcl` NO-GO (machine-confirmed, bounded one-dispatch probe)

The `hexcl` obligation, stated exactly as the fold consumes it, after
`intro w hxw hwt hptW σ hσneg x1 hreal` reduces to (verbatim `lean_goal`):

```
hptW  : TemporalPred.eval_at M atomMap (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj)
          (fun χ => P.existF 0 χ) qnf) w
hσneg : qnf.2 σ = false
hreal : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x fun x => t))) σ
⊢ False
```
No `.holds`, no disjunct, no per-σ realization in context — only `hptW` (constrains `w`).

**Failed closers (verbatim `lean_multi_attempt`):**
1. `kvE2_sepSegForm_excludes … x1 … hσneg hreal` → **type mismatch**: expects
   `kvE2_sepBits σ ?zs ?χ = false` (a per-zone bit, NOT the quant-layer `qnf.2 σ = false`), and an
   unfilled goal `TemporalPred.eval_at ⟨kvE2_sepSegForm … σ ?zs⟩ x1` (the segment form at `x1`, which
   lives inside the frozen `kvE2_sepDisjunct'` and is not provided). This is O4 failed-closer #4
   (SW:6899-6904) reproduced at the goal level.
2. `aesop` → failed after exhaustive search.
3. `obtain ⟨σ0, hpos, hz0⟩ := hfrag; aesop` → both zone cases `⊢ False` unsolved.
4. `tauto` → failed.
5. `simp_all` variants → unsolved.

**Root cause.** `hexcl` receives only `hptW` (w's point type), so nothing constrains an arbitrary
`x1`; excluding a negative sub's realization at `x1` is information-theoretically impossible from the
fold's hypotheses. The model priors `h_UZ`/`h_SZ` are first/last-occurrence well-foundedness
(`PriorDefs.lean:22/33`), NOT type-exclusion. The provider `P.existF 0` gives only the arity-1
projected type — the `(outer zone, projected 1-type)` information ceiling machine-certified by
`bracketEndChar_kv_factors` (`CarrierKv.lean:422`). This is the SAME root cause as the pre-345
blocker (report 04, adjudicated REFUTED), now isolated to the single `hexcl` family: the symmetric
gate dissolved the interior-gate families but `hexcl` remains genuinely provider-conditional (A1
sense, fold docstring SW:10033-10037). Exhaustive grep found NO landed producer
(`qnf.2 σ = false → ¬ nf_eval_nf`, `_hexcl`, `_excl` — only hypothesis positions + the segment
machinery that needs the frozen disjunct).

## Resume options (design decision for the user / successor — NOT an implementation retry)

1. **SharedWitness-territory segment-coverage extractor**: land a PUBLIC lemma exposing the frozen
   `kvE2_sepDisjunct'` segment forms so `kvE2_sepSegForm_excludes` fires at every non-witness point,
   plus type-exclusivity at the finite witness points (under single-positive, the O4 residue-vanish
   SW:6785-6791). This is branch (a) — REFUTED per report 04 as an UNCONDITIONAL reshape, but the
   single-positive-restricted extractor was never separately built; it would renegotiate 341's
   frozen-file gate. NOTE: even this needs `.holds` (the disjunct) threaded into `hexcl`, which the
   current fold signature does NOT pass — so it also needs a fold-signature change in SharedWitness.
2. **Successor carrier redefinition** (the 321-N2-named deferred task): bit-compatibility filtering
   of the interleaving enumeration (O4 SW:6763-6770), with O1b/O2/O3 knock-on rework. The faithful
   repair; a large multi-task effort.

Do NOT re-attempt `hexcl` from the current inputs — machine-confirmed NO-GO, not merely hard. Do NOT
edit `SharedWitness.lean` from 335's OuterGate-only territory. Do NOT commit a conditional gate
carrying `hexcl` as the final deliverable (fails 309's provider-unconditional requirement).

## What 335 leaves for 309 (partial)

- ⇐ completeness: `bracketEndChar_kvE2_complete_two_prior` (Phase 2, UNCONDITIONAL, green).
- ⇒ soundness modulo `hexcl`: `bracketEndChar_kvE2_sound_two_prior_frag` (Phase B, green, carries
  `hexcl`).
- The fragment predicate `kvE2_sepFragment` (Phase A, green).
- MISSING for the full GO gate: `hexcl` discharge → then assemble
  `bracketEndChar_kvE2_correct_two_prior_frag`.
