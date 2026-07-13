# Task 356 Implementation Summary — General-k `hexclExt` Exterior-Adjacency Discharge

- **Task**: 356 (lean4) — Deliver the general-`k` `hexclExt` exterior-adjacency discharge lemma
- **Plan**: `specs/356_discharge_depthk_hexclext_exterior_adjacency/plans/01_hexclext-discharge-exterior-gate.md`
- **Status**: Implemented (green, sorry-free) with one documented Phase-4 deviation (see below)
- **New file**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorGateAssembleK.lean`

## What landed

A new purely-additive leaf module delivering the three planned artifacts, all green and sorry-free:

1. `bracketEndChar_kvExt` (def) — the general-`k` enriched composed gate: the interior carrier
   `bracketEndChar_kv … (k+2) qnf` with the two adjacent exterior brackets
   `kvE_extBracketPast Pbr` / `kvE_extBracketFut Pbr` conjoined at the anchors via `enrichEndpoints`.
2. `bracketEndChar_kvExt_holds_iff` (lemma) — the anchor-semantics bridge; a one-line reuse of
   `VVecEA2.enrichEndpoints_holds`.
3. `bracketEndChar_kvExt_correct_prior` (theorem) — the DoD discharge biconditional
   `holds ↔ ∃ w, nf_eval_nf M (k+2) 3 [w,x,t] qnf`, **both directions green**.

## Definition of Done — status

| DoD item | Status |
|----------|--------|
| General-`k` `hexclExt` discharge lemma green, sorry-free | MET (both directions) |
| `hexclExt` discharged **internally** (⇒) | MET — guard split `¬(x ≤ x1 ∧ x1 ≤ t) → x1 < x ∨ t < x1` → per-side `kvE_extBracket{Past,Fut}_sound` |
| axioms exactly `[propext, Classical.choice, Quot.sound]` | MET (`lean_verify`) |
| full-tree `lake build` GREEN | MET (1724 jobs, exit 0) |
| no new axioms / no vacuous defs / 0 sorries in file | MET |
| Consumability shape for task 357 | PARTIAL — see deviation |

## `hpos` escalation site — RESOLVED (not blocked)

The single flagged escalation risk (⇐ positive-witness positioning, k=2 zone bits → general-`k`
order predicate) went through cleanly: from `kvE_{fut,past}Admissible σ = true` extract conjunct-1
`nf0_zoneSpec σ.1 = kvE2_sep_z{Fut,Past}T3` (`Bool.and_eq_true` + `of_decide_eq_true`), then apply
the verbatim k=2 order-bit read `hx1.1 (.order …)`. No block.

## Phase-4 DEVIATION (altered) — exterior bracket realization interface threaded outward

The ⇐ direction hit a **different, deeper** obstacle than the flagged `hpos` site. The general-`k`
`kvE_extBracket{Past,Fut}_complete` (`ExteriorBracketAssembleK.lean:168/210`) carry an arity-5
realization interface `hreal`/`hsat` that the frozen **k=2** `kvE2_extBracket_complete` did NOT
(k=2 took the zone-determinacy pins `henv`/`hbelow`, both derivable from the qnf realizer `h` via
`kvE2_futAnyBit_correct`). Task 349/354's refactor replaced those derivable pins with realization
obligations whose exact goal (recorded via `lean_goal`) is:

```
∀ σ, kvE_futAdmissible σ = true → qnf.2 σ = false →
  ∀ x1, t < x1 → ∀ s, σ.2 s = true → ∃ v, nf_eval_nf M k 5 [v,x1,w,x,t] s
```

This is **not derivable from `h`**: an unmarked σ (`qnf.2 σ = false`) is realized at NO `x1`
(`(h.2 σ) : (∃ x1, nf_eval_nf …) ↔ qnf.2 σ = true`), so no realizer exists to feed
`kvE_futBundle_of_realizer`. Per the AssembleK design (`ExteriorBracketAssembleK.lean:25-30`,
154-163) these are a **DISCHARGED interface**, "discharged one level up… NOT discharged here" — the
exterior analog of the interior `hreal`/`hexcl` that the plan's Non-Goals already thread outward.

Resolution (no `sorry`, no vacuous def): the four obligations
`hbrPastReal`/`hbrPastSat`/`hbrFutReal`/`hbrFutSat` (∀-`w`-gated) are **threaded outward** exactly
as the interior `hreal`/`hexcl`, to be discharged by task 357's provider instantiation via
`kvE_{fut,past}Bundle_of_realizer` when the outer recursion produces a genuine exterior realizer.

**Consequence for task 357**: `bracketEndChar_kvExt_correct_prior` carries **four extra**
exterior-bracket realization hypotheses beyond the DoD's literal list
(`P, hcharK, Pbr, h_UZ, h_SZ, hreal, hexcl` + six order bits). The ⇒ direction (the DoD-critical
`hexclExt` discharge) still discharges `hexclExt` internally and does **not** use these four; they
are consumed only by the ⇐ completeness half. Task 357, which discharges all realization
obligations at the KampPrior provider instantiation, discharges these identically.

## Depth-index resolution

Stated at interior depth `(k+2)` (`qnf : NormalForm sig (k+2) 3`), so bracket subs
`σ : NormalForm sig (k+1) 4` match the AssembleK lemmas with no reindex. The interior carrier uses
`bracketEndChar_kv_step_sound` (⇒) and `bracketEndChar_kv_step_complete` (⇐) at their implicit
`{k} := k+1`. Two provider bundles are carried: `P : ExistProviders … (k+1)` (interior) and
`Pbr : ExistProviders … k` (brackets). The k=2 discharge is the `k=0` member of this family.

## Plan Deviations

- **Phase 4 (altered)**: exterior bracket `hreal`/`hsat` obligations threaded outward (four extra
  `hbr*` hypotheses) instead of discharged internally — not derivable from the qnf realizer; a
  carried interface per AssembleK design. Full detail above and in the plan's Phase 4 block.
- All other phases followed the plan.

## Verification

- `lake build` (full tree): GREEN, 1724 jobs, exit 0.
- `lean_verify bracketEndChar_kvExt_correct_prior`: axioms `[propext, Classical.choice, Quot.sound]`.
- New file: 0 `sorry`/`admit` tactics, 0 vacuous defs, 0 new axioms.
- Import chain acyclic (imports only `InteriorGateGeneralK` + `ExteriorBracketAssembleK`).

## Follow-up for task 357

When wiring `bracketEndChar_kvExt_correct_prior` into `KampPrior.lean:351`, discharge the four
`hbr*` exterior-bracket obligations via `kvE_{fut,past}Bundle_of_realizer` at the point where the
outer recursion selects the genuine exterior witness (the same site that discharges the interior
`hreal`/`hexcl`). This is the exterior-realizer analog of the interior provider discharge already
anticipated by the plan's Non-Goals.
