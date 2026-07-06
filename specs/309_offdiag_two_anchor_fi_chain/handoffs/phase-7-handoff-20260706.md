# Phase 7 Handoff — task 309 (offdiag_two_anchor_fi_chain), plan v2

## Immediate Next Action
Dispatch **Phase 8**: recursive navigated endpoint primitive `endChar` + `endChar_correct`
(recursion on `k`). Base = Phase-6 `endChar0`; step = navigable-brick flatten of each sub's `∃w'`
with Phase-7 `seg` for the interior and Phase-6/8 endpoints for the exteriors, arity ≤ 3.

## Current State
- Phase 7 COMPLETE, sorry-free. `phases_completed = 7 / 9`.
- Module `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge` builds GREEN (995 jobs).
- Sorry count in module: 1 (pre-existing Phase-6 `endChar0_correct` strategic sorry, :1066).
  0 new sorries this phase.
- Both new `_correct` lemmas: axioms exactly `[propext, Classical.choice, Quot.sound]`.

## Delivered (NfMultiAnchorBridge.lean, after `endChar0_correct`)
- `seg {sig k} (endChar : EndCharCarrier sig k) (qnf : NormalForm sig k 3) : BracketFormula 0`
  := `BracketFormula.trivial (endChar qnf)` — the Rabinovich `β_i` non-trivial interior segment
  (G3: interval type is the genuine `endChar qnf`, not `⊤`).
- `seg_holds_correct` (sorry-free): `(seg endChar qnf).holds M atomMap x t ↔
  ∀ y, x < y → y < t → (endChar qnf).eval_at M atomMap y`. Via `BracketFormula.trivial_holds`.
- `seg_holds_coupled`: under hook `h_endChar : ∀ y, (endChar qnf).eval_at y ↔
  nf_eval_nf M k 3 (zoneEnv3 y x t) qnf`, gives `(seg …).holds x t ↔
  ∀ y, x < y → y < t → nf_eval_nf M k 3 (zoneEnv3 y x t) qnf`. The `nf_eval_nf`-coupled interior
  form; coupling is a hook (NOT a sorry), discharged in Phase 8 via `endChar_correct`.

## Key Decisions
- **`BracketFormula 0` is a universal, not an existential.** Its `.holds` is definitionally
  `∀ y ∈ (x,t), segType y` (ExistsForallNF `IntervalPattern.holds` at `n=0`). This IS Rabinovich's
  `β_i` (the interval type holding throughout the open interval). The `∃w` interior existential
  named in the plan's deliverable is supplied by the enclosing `bracketBuildLeft` witness in the
  Phase-8 assembly, not by `seg`. Hence the split: `seg_holds_correct` (universal `β_i`, sorry-free)
  + `seg_holds_coupled` (`nf_eval_nf` coupling via a deferred hook, mirroring how Phases 4/5 defer
  `h_quant`).
- The Phase-6 `endChar0_correct` strategic sorry is **carried forward, not discharged**. Phase 7
  does not redefine `endChar0`; the base's anchor under-definition (closed navigated-`w` pred can't
  read free anchors) is Phase-8 base-wiring (recursion pins `a=x, b=t` via the enclosing bracket
  witnesses) or the dedicated base-case task.

## Sorry Inventory (carried)
See `.orchestrator-handoff.json` `sorry_inventory` — one entry, `endChar0_correct` :1066,
`strategic: true`, `follow_up_task` = Phase-8 base-wiring / dedicated base-case discharge.

## Guards Verified
- G3: `seg`'s interval type is the real `endChar qnf`, not trivial-top.
- G4: anchors `{x,t}=2`; `y` is a bracket witness; `endChar` keeps arity ≤ 3. No third anchor.
- G5: `holds` reduction via `BracketFormula.trivial_holds`; coupling bridge is manual
  `constructor`/`intro`; no `simp`/`omega`/`aesop` chain-step shortcut.

## Commit
`901484b9c task 309 phase 7: non-trivial interior segment builder`
