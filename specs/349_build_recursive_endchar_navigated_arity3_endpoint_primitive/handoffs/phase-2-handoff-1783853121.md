# Task 349 v6 — Phase 2 Handoff (Carrier retype + statement freeze + k=0 base)

## Immediate Next Action (Phase 3)
Define `endIntervalStep` body: generalize the green `bracketEndChar_k1v` (CarrierK1V.lean:433)
from concrete `k=1` to arbitrary `k`, threading the depth-`k` IH carrier `rec : BracketEndCharCarrierV sig k`
(VVecEA2) for sub-piece characteristics; anchors FIXED at `{x,t}`, witnesses in disjunct slots (G2/G4);
Step-A reduce-first via `nfEval_le2_reduction`/`endCharStep_quant_reduceA`. Replace the Phase-2
empty-disjunction placeholder `fun _ => ⟨[]⟩` (CarrierK1V.lean, `endIntervalStep`).

## Current State
- Phase 2 COMPLETED. Scoped build `Bimodal.…CarrierK1V` GREEN (1006 jobs). Sorry-free.
- New decls (all in CarrierK1V.lean, additive, namespace `Bimodal.Metalogic.WeakCanonical.Kamp`):
  - `VVecEA2.singleton {n} (vea : VecEA2 n) : VVecEA2` — singleton-disjunct embedding.
  - `VVecEA2.singleton_holds` — `.holds` unfolds to the wrapped `VecEA2.holds`.
  - `endIntervalStep {sig} {k} (atomMap) (h_surj) (rec) : … (k+1)` — Phase-3 HOLE (empty `⟨[]⟩`).
  - `endInterval (atomMap) (h_surj) : (k) → BracketEndCharCarrierV sig k` — `Nat.rec` skeleton.
  - `EndIntervalCorrect (atomMap) (h_surj) : Prop` — FROZEN statement (report 06 §4.5).
  - `endInterval_zero_correct` — k=0 base (consumes `bracketEndChar_k0_correct`).

## Key Decisions
- Frozen statement encoded as a Prop-valued `def EndIntervalCorrect` (NOT a theorem-with-sorry) so the
  freeze compiles sorry-free per Phase-2 acceptance. Phase 6 proves
  `theorem endInterval_correct : EndIntervalCorrect atomMap h_surj` by induction on k.
- Six order bits use the uniform `NormalForm.atom_assgn` accessor (NormalForm.lean:151): at k=0 it is
  `qnf (.order …)`, at k+1 it is `qnf.1 (.order …)` — one signature covers `bracketEndChar_k0_correct`
  and `bracketEndChar_k1v_correct` shapes.
- `endInterval` via explicit `Nat.rec` so `endInterval … 0 = base` and
  `endInterval … (k+1) = endIntervalStep … (endInterval … k)` hold by `rfl` (Phase 6's literal check).
- Phase-3 hole is the empty disjunction `⟨[]⟩` — a real total function, not `sorry`/vacuous;
  invisible to sorry census by design (tracked here + in `.orchestrator-handoff.json` `deferred_defs`).

## Sorry Inventory
EMPTY — zero sorries. (`endIntervalStep` is a deferred def with a real empty-disjunction body, tracked
under `deferred_defs` in `.orchestrator-handoff.json`, discharged in Phase 3.)

## Axioms
`endInterval_zero_correct`, `endInterval`, `VVecEA2.singleton_holds` all =
`[propext, Classical.choice, Quot.sound]`.

## Guards honored
G1 no arity-1 collapse; G2/G4 anchors {x,t} fixed, witnesses in disjuncts; G3 (segments) untouched in
Phase 2; G5 no simp/omega/aesop chain steps (base is a direct `exact`). No forbidden single-point
`→TemporalPred` carrier, no `navPieceForm`, no `h_res` in additions. Frozen providers / KampPrior /
Lemma32Reduction / `nf_nvar_exist_all_depths` signature untouched.
