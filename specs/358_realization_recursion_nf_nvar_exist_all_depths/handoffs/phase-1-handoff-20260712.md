# Task 358 — Phase 1 Handoff (2026-07-12)

## Immediate Next Action

Dispatch **Phase 2**: construct the realizer `hσ` (Cor 5.4(1) ⇐ base + one Until-link, n=1,
arity 4) in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`. First step: run
`kvE_futChainDestructG` / `kvE_pastChainDestructG` to obtain the exterior anchor `x1`, then apply
the Until-witness extraction pattern verified in Phase 1 (see "Verified extraction pattern" below).

## Current State

- Phase 1 **[COMPLETED]** — verification-only escalation gate. **Verdict: GO.**
- Zero proof edits made; zero sorries introduced; KampPrior.lean untouched.
- Build state unchanged (no Lean files modified this dispatch).
- Sorries in task scope: KampPrior.lean:361 (`| 1 =>` arm) and :364 (`| n+2 =>` arm) — both
  inherited, both are the Phase 2–4 targets.

## GO Verdict Evidence

1. **All nine Preserved-Asset interfaces resolve by name** (full signature table recorded in the
   plan, "Phase 1 Findings" block). One relocation: `kampPrior_existProviders_of_ih` is a 3-lemma
   family now at KampPrior.lean:989 (`_correct`), :1013 (`_existF0_char`), :1043 (`_exist1`)
   (plan table said :972). All other locations match the plan exactly.
2. **Until/Since truth-lemma located**: it is DEFINITIONAL — the `.untl` case of
   `Bimodal.Metalogic.WeakCanonical.temporal_truth` (Table.lean:182; `.untl` at :190–191):
   `∃ s, t < s ∧ temporal_truth M atomMap s φ ∧ ∀ r, t < r → r < s → temporal_truth M atomMap r ψ`
   — exactly the Rabinovich `∃ y2 > y1, α(y2) ∧ β on (y1,y2)` shape. `.snce` dual at :192–193.
   No separate named lemma exists or is needed.
3. **Constructive-viability machine-verified**: probe theorem `until_witness_probe`
   (lean_run_code, not landed in tree) transcribed the exact Cor 5.4(1) ⇐ inductive step
   (extraction + two-way `y2 ≤ xn+1` case-split) and compiled green with axiom closure
   `[propext, Classical.choice, Quot.sound]` — IDENTICAL to the ambient baseline (a bare
   `Exists.intro` over these types shows the same closure) and to all nine preserved assets.
   The realizer step adds NO new axiom and no choice-based selection: extraction is Prop-level
   `Exists.elim`; case-split via `le_total`/`le_or_gt` on the bundled `LinearOrder`
   (`OrderedMonadicStructure.carrier_order`, MonadicFO.lean:103–109).
4. **Literature-grounded** (per orchestrator policy update): Rabinovich 2014 chunk 0015 lines
   25–35 read directly — witness selection and min/case-split match the transcription verbatim.
   Chunk 0016 confirms the ONLY Dedekind-completeness/`inf` appeal is eq (5.3) `INF` first-point
   (Lemma 5.1 Case 3), separate from the realizer recursion and already formalized at k=1.

## Verified extraction pattern (for Phase 2)

The landed k=1 template consumes Until definitionally — mirror it:

```
simp only [TemporalPred.eval_at, Formula.and, Formula.neg, temporal_truth] at h_untl
obtain ⟨y2, hy2_gt, hy2_alpha, hy2_beta⟩ := h_untl
rcases le_or_gt y2 xn1 with hle | hlt
· -- z := y2 (y2 ≤ xn1)
· -- z := xn1; β at xn1 from hy2_beta xn1 hx hlt
```

Reference instances: EANegation.lean:594–611 (`bracket_implies_fChainPred` base), :637–647 (step).

## Key Decisions

- GO — Phase 2 may proceed; no spawn, no blocker.
- Phase-2 axiom bar clarified: `lean_verify` acceptance is "closure == `[propext,
  Classical.choice, Quot.sound]`, no `sorryAx`, no NEW axiom" — NOT literal absence of
  `Classical.choice`, which is baked into the Mathlib `LinearOrder`-bundled types themselves
  (proved by the bare-`Exists.intro` baseline probe).

## Toolchain gotchas found

- `le_or_lt` is deprecated → use `le_or_gt`.
- `LinearOrder.decidableLE` is not projectable off `M.carrier_order` in this Mathlib —
  use `le_total`/`le_or_gt`/`inferInstance`.

## Sorry Inventory

| file | line | statement | strategic | assumption | why_deferred | follow_up |
|------|------|-----------|-----------|------------|--------------|-----------|
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 361 | `nf_nvar_exist_all_depths` `\| 1 =>` arm (n=1 critical) | yes (inherited, task-309 R1 scope) | arity-2 existential char formula at depth k+1 | Phase 2–3 deliverable of THIS task | task 358 Phases 2–3 |
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 364 | `nf_nvar_exist_all_depths` `\| n+2 =>` arm (footprint) | yes (inherited) | arity-(n+1) existential at depth k+1 | Phase 4 deliverable of THIS task | task 358 Phase 4 |

No sorry introduced in Phase 1.

## References

- Plan: specs/358_realization_recursion_nf_nvar_exist_all_depths/plans/02_realizer-recursion-implementation.md
  (Phase 1 Findings block has the full nine-interface signature table)
- Rabinovich source: ~/Projects/Literature/sources/rabinovich_2014/chunk_0015.md, chunk_0016.md
