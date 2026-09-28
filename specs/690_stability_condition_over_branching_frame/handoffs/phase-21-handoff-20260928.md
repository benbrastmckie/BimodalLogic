# Phase 21 Handoff — Non-vacuity and the deterministic diagonal

- **Written**: 2026-09-28
- **Dispatch**: seq 12, session `sess_1790617342_e2d44f`
- **Phase status**: 21 [COMPLETED]; 16 remains [BLOCKED]; 17–20, 22 [NOT STARTED]

## Immediate next action

Phase 16's measurement-gate decision is still open (three options recorded in the plan's
Phase 16 blocker entry). Nothing in Phase 21 bears on it. The next reachable unit of work after
that decision is Phase 16 itself; Phase 22 (registration) is the only other phase whose
dependencies are otherwise satisfied, and it is deliberately left for last because it edits
files in tasks 623/684's declared territory.

## What landed

`FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean` (≈400 lines), green under
`lake build FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples`, zero sorries.

- `stabFaithful_diagonal` — (C5) degenerates to `⊡φ ↔ φ` under the `hdet` hypothesis that every
  `skeleton.share u` is equality. Stated at the hypothesis rather than at a constructed L⁺
  `toSharing`, which is Phase 20's work.
- `stabFamily (p : Atom)` — two lassos over the closure of `⊡Fp`. Lasso `0` carries
  `{⊡Fp, Fp, p}` at every time except `u = 0`, where it carries `{Fp}` alone; lasso `1` carries
  `∅` everywhere. The representative window is `repBack = [id]`, `repMid = [const 0]`,
  `repFwd = [id]`, so the two indices share a state at `u = 0` and only there.
- `stabFamily_separates` — (C5) holds on the family, `Fp ∈ L mainIdx 0`, `⊡Fp ∉ L mainIdx 0`.
- `#guard` on `decidableStabFaithful (stabFamily (Atom.mkBase "p"))` — the decision procedure
  accepts the family by computation.

Both theorems' axiom sets are `[propext, Classical.choice, Quot.sound]`.

## Key decisions

1. **The witness's `p` placement deviates from the plan's wording.** The plan asks for `p` on
   lasso `0` "at `t = 1` and nowhere on lasso `1`". A lasso's labels are periodic, so a single
   time is not expressible on a singleton cycle. `p` is labelled everywhere except the origin
   instead. This also makes (C0) atom coherence hold across the one shared class, which the
   plan's wording would have broken.
2. **`⊡Fp` is kept out of the origin label by (C5) itself**, not by fiat: the shared class at
   `u = 0` contains lasso `1`, which lacks `Fp`. That is what makes the family a genuine
   separation rather than a stipulated one.
3. **Phase 21 was executed out of plan order.** Its declared `Depends on: 20` was wrong; its real
   dependencies are Phases 12 and 15, both complete. The plan's Phase 16 blocker entry and Phase
   21 dependency line both record this.

## Territory / build notes

- The module is **not yet registered** in `FormalSystem.lean` or `Decidability.lean` — that is
  Phase 22's job, and the whole `PlusWitnessFamily/` subtree is unregistered for the same reason.
  A plain `lake build` therefore does not compile it; verify with the explicit module target.
- `lake-build-guard.sh` will **replay** a previous result for a differently-scoped build if
  `--no-share` is omitted. Every build in this dispatch used `--no-share`; the first one that did
  not reported a false green.
