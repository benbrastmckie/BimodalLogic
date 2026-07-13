# Task 358 — Phase 2 Handoff (2026-07-12)

## Immediate Next Action

Dispatch **Phase 3**: discharge the eleven obligations + wire the `| 1 =>` arm (KampPrior.lean:361).
First step: at the `| k+1 =>` recursion body, instantiate the provider shim
(`kampPrior_existProviders_of_ih` fed the recursion's own IH family) and route the four exterior
obligations of `kampPrior_site_rungK_gate_match` (`hbrPastReal`/`hbrPastSat`/`hbrFutReal`/`hbrFutSat`,
KampPrior.lean:845–870) through `kvE_{past,fut}Bundle_of_realizer hσ .1/.2` at the SELECTED anchor,
with `hσ` produced by the Phase-2 drivers (see Interface below).

## Current State

- Phase 2 **[COMPLETED]** — the Cor 5.4(1) ⇐ realizer core is landed sorry-free.
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior`: **Build completed successfully (1032 jobs)**.
- Sorries in task scope: KampPrior.lean:361 (`| 1 =>`) and :364 (`| n+2 =>`) — both inherited,
  unchanged (new code appended at END of file; line citations stable).
- `lean_verify` on `kampPrior_fChain_realize_bracket`, `kampPrior_futRealizer_of_pos`,
  `kampPrior_pastRealizer_of_pos`: axiom closure exactly `[propext, Classical.choice, Quot.sound]`
  — identical to the ambient floor; no `sorryAx`, no new axiom (Phase-1 bar met).

## What Phase 2 landed (all at the end of KampPrior.lean, task-358 section)

| Theorem | Content |
|---------|---------|
| `kampPrior_fChain_realize_cons` | Fin.cons prepend transfer (shared assembly of both case-split branches) |
| `kampPrior_fChain_realize_from` | **THE HARD CORE**: Cor 5.4(1) ⇐ suffix induction — per-link Until-witness extraction (`fChainFrom_step`) + two-way `rcases le_or_gt y (x (i+1))` case-split, invariant `w a ≤ x (i+a)` |
| `kampPrior_fChain_realize` | arity-generic chain realizer (every `BracketFormula (n+1)`; i=0 instance) |
| `kampPrior_fChain_realize_bracket` | partial-bracket form: second endpoint case-split `le_or_gt s z1` → `∃ z, z0 < z ∧ z ≤ z1 ∧ bf.holds z0 z` — bounded resolution of the EANegation.lean:1249 Until-unboundedness obstruction |
| `kampPrior_futRealizer_assemble` / `kampPrior_pastRealizer_assemble` | σ-level `hσ` fold at the anchor via `nf_eval_nfk_iff_efold` + `kvE_*Atom_of_bundle` + `kvE_*Admissible_offFiber`; exact inverses of `kvE_*Bundle_of_realizer` |
| `kampPrior_futRealizer_of_pos` / `kampPrior_pastRealizer_of_pos` | **drivers**: from `kvE_{fut,past}Pos P σ` firing, run the landed destructor `kvE_{fut,past}ChainDestructG`, emit `∃ x1` (selected anchor) with `t < x1` (resp. `x1 < x`), `temporal_truth x1 (kvE_{fut,past}End P σ)`, and `hσ : nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` |

## Interface note for Phase 3 (the one seam to know)

The drivers thread the at-anchor fiber transfer as hypotheses `hreal`/`hsat` — the EXACT shapes
`kvE_futBundle_of_realizer`/`kvE_pastBundle_of_realizer` prove sound (ExteriorConverterK.lean:192–207
"discharge template" comment: these are dischargeable interfaces, not debt). Phase 3's
reconciliation task (plan Phase 3, task 2: ∀x1 vs selected-x1) supplies them at the selected anchor:
`hbrFutSat`'s binder already carries `temporal_truth x1 (kvE_futEnd Pbr σ)` (KampPrior.lean:863–870),
which is what `hsat` consumes; the off-fiber/exclusion reading discharges the non-selected antecedent.
The `hσ`-production loop is: gate obligations → (hreal/hsat shapes) → drivers → `hσ` → bundles →
gate obligations discharged. Phase 3 closes this loop at the recursion site.

## Key decisions

- The chain realizer is stated at the `BracketFormula` level (mirrors `fChainFrom` explicitly, per
  contract) and is ARITY-GENERIC (every `n`), so Phase 4's route (a) reuses it verbatim.
- The conclusion of `kampPrior_fChain_realize_bracket` is `z ≤ z1` (closed right end), matching the
  Rabinovich endpoint convention where the interior-witness convention would be false (the :1249
  impossibility); consumers with strict interiors use the `w i ≤ x i < z1` domination directly.
- Until-witness extraction goes through the landed `fChainFrom_step`/`fChainFrom_base`
  characterizations (the definitional `.untl` truth-lemma in the k=1 template's packaged form) —
  recorded as an "altered" deviation on plan sub-task 2; same definitional content.

## Toolchain gotchas found (Phase 2 additions)

- omega does NOT reduce `(⟨e, h⟩ : Fin n).val` in statement-position bound proofs: normalize with
  `by show <reduced form>; omega` (defeq `show` works; bare `omega` and `omega` after `ext` fail).
- Non-dependent arrow antecedents (`P → Q` in a theorem statement) are NOT visible to `by omega`
  inside `Q`'s elaboration — name the binder (`∀ (_hd : P), Q`) when statement-level `by omega`
  needs the fact.
- `simp only [Fin.val_mk]` triggers the unusedSimpArgs linter yet its dsimp proj-reduction is
  load-bearing; replace with explicit `show` normalization, not by dropping the simp.

## Sorry Inventory

| file | line | statement | strategic | assumption | why_deferred | follow_up |
|------|------|-----------|-----------|------------|--------------|-----------|
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 361 | `nf_nvar_exist_all_depths` `\| 1 =>` arm (n=1 critical) | yes (inherited, task-309 R1 scope) | arity-2 existential char formula at depth k+1 | Phase 3 deliverable of THIS task | task 358 Phase 3 |
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 364 | `nf_nvar_exist_all_depths` `\| n+2 =>` arm (footprint) | yes (inherited) | arity-(n+1) existential at depth k+1 | Phase 4 deliverable of THIS task | task 358 Phase 4 |

No sorry introduced in Phase 2.

## References

- Plan: specs/358_realization_recursion_nf_nvar_exist_all_depths/plans/02_realizer-recursion-implementation.md
  (Phase 2 Findings block lists the seven landed theorems)
- Phase-1 handoff: handoffs/phase-1-handoff-20260712.md (interface table, extraction pattern)
- Rabinovich source: ~/Projects/Literature/sources/rabinovich_2014/chunk_0015.md (the ⇐ induction
  transcribed: "If y2 ≤ xn+1 then the required z ∈ (z0, z1) equals to y2 … Otherwise, xn+1 < y2 …
  the required z equals to xn+1")
