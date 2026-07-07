# Implementation Summary: k2 Outer Quant-Layer Fold — Provability GATE

- **Task**: 327 (P1 provability GATE for `nf_quant_layer_fold_k2_gate`)
- **Session**: sess_1783465547_adec63
- **Mode**: lean4, hard mode (H2 anti-analysis, H9 sorry-inventory), literature-grounded
- **Verdict**: **WHOLE-TASK NO-GO** (machine-grounded). A NO-GO is a fully valid, successful
  gate deliverable per the plan's DECISION-GATE contract.

## Verdict

**NO-GO for all three routes (a) naive `nfk`-split-kit factorization, (b) constant-arity E[Σ]
`efold_of_nfk`, and (c) any new argument at constant arity-1 χ.**

The depth-2 outer quant-layer fold `nf_quant_layer_fold_k2_gate` does NOT fold cleanly into
per-(zone,χ) monadic obligations at constant arity. Both the naive factor and the E[Σ] outer fold
bottom out on the same depth-1 per-witness factorization `nf_eval_nf1_cons_factor`, which is FALSE
in clean form. The E[Σ] constant-arity representation (Rabinovich Def 4.1 / Prop 4.3) does **not**
dodge the barrier — its constant arity is arity-1, precisely the arity that cannot carry the
inner-witness joint content.

## Phases executed

| Phase | Status | Outcome |
|-------|--------|---------|
| 1 — Route (a) barrier reproduction | COMPLETED | route-(a) NO-GO (a2, expected): arity-1 monadic projection `nfk_projFresh` drops the inner witness's coupling to {w,x,t}; factorization is lossy, not a clean biconditional. Not a whole-task NO-GO. |
| 2 — Route (b) E[Σ] efold make-or-break probe | COMPLETED | route-(b) NO-GO (b2) → WHOLE-TASK NO-GO. Reconstruction crux goal reproduces the arity-4 residual (NO-GO exit criterion). |
| 3 — Certify (NO-GO branch) | COMPLETED | Additive, inert NO-GO record appended to `NfMultiAnchorBridge.lean`; transient probe removed; no `sorry`/no partial carrier committed; `lake build` green. |

## Machine evidence (the exact failing goal state)

Route-(b) reconstruction probe, after `nf_eval_depth1_fold_iff`, with the constant-arity monadic
channel `hmon : nf_eval_nf M 1 1 (fun _ => x1) (nfk_projFresh sub)` supplied, the crux inner-fold
goal is:

```
zs' : ZoneSpec 4
χ'  : NormalForm sig 0 1
⊢ (∃ v, zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x fun _ ↦ t))) zs' v ∧
      nf_eval_nf M 0 1 (fun _ ↦ v) χ') ↔
    sub.2 (nf0_assemble zs' χ' sub.1) = true
```

The goal's `zs' : ZoneSpec 4` demands the inner witness `v`'s zone against the full arity-4 env
`[x1,w,x,t]`; the only witness hypothesis `hmon` supplies `ZoneSpec 1` (`v`-vs-`x1` only). The
`v`-vs-{w,x,t} coupling is irrecoverable — the irreducible arity-4 residual of
`NfMultiAnchorBridge.lean:1622-1646` (the G6 barrier), now resurfacing at the OUTER quant layer.

### Failed `lean_multi_attempt` closers (five captured; ≥2 required)

1. `exact hmon.2.1 zs' χ'` → **Application type mismatch: argument `zs'` has type `ZoneSpec 4` but
   is expected to have type `ZoneSpec 1`.** (Decisive: the constant-arity channel is arity-1.)
2. `exact hmon.2.1 _ χ'` → type mismatch: `zoneHolds M (fun _ ↦ x1) ?m v` (arity 1) vs required
   `zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x fun _ ↦ t))) zs' v` (arity 4).
3. `simp_all [nf_eval_nf, zoneHolds]` → unsolved: goal's `∀ i : Fin 4` four-point order constraints
   vs `hmon`'s single `(v < x1) ∧ (x1 < v)` pair.
4. `constructor <;> intro <;> tauto` → tauto fails both directions; `mpr` leaves the unfillable
   witness obligation `⊢ M.carrier`.
5. `aesop` → failed after exhaustive search.

### LITMUS

No `x1 < e_i` relative-position literal was introduced. The certification rests on the arity-4
residual clause of the NO-GO exit criterion, not the LITMUS clause.

## Verification

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge` → **green** (1005 jobs, exit 0).
- Live `sorry` introduced: **0** (the NO-GO record is a `/-! -/` doc comment; the transient probe
  scaffolding was removed before any commit).
- New axioms: 0 (baseline 2, unchanged). New vacuous definitions: 0.
- Diff: additive-only (67 insertions, 0 deletions) to the single sanctioned file; all Preserved
  Assets / DO-NOT-EDIT regions byte-identical.

## Recommendation (next actions)

- **Do NOT start P2 (task 328, engine) or P3 (task 329, dischargers).** They are gated on a P1 GO,
  which did not occur.
- The whole k=2 carrier route as specified (constant-arity E[Σ] outer fold) is BLOCKED. Any viable
  path must carry the inner-witness joint content, which the ≤2-free-variable / constant-arity
  design (Lemma 3.2(2)) forbids. Reconsider the carrier route at a fundamental level (e.g. a
  representation that admits arity-growing per-round content, accepting the navigated-characteristic
  cost the current design was chosen to avoid), or re-scope the k=2 completeness target.
