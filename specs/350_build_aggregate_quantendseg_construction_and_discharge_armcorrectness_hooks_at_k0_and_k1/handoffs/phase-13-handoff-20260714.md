# Phase 13 Handoff — (E1) exterior fiber kit + single-fiber R3 probe (task 350)

**Status**: Phase 13 COMPLETED. Single-phase dispatch (phase_number=13); stopped at phase
boundary per contract. Session `sess_1784009176_e5245f`.

## Immediate Next Action (Phase 14a — E2 `navPackLeft`)

Create `Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean` (new module + aggregator import).
Fold the w-dependent fibers (atoms at w; zones `v<w`, `v=w`, `w<v<x`) into a single
`endpointLeft : TemporalPred` at x. Rabinovich anchor: Lemma 7.10 / Prop 3.5 (chunks 0023,
0010). Consume the Phase-13 kit by name (below); bit-true inner fibers = arrangement slots
inside the fold; bit-false = exclusion segments / negated Since-lits (native `.snce`); may
consume Phase-11 `negFix` for bit-false inner fibers (record which device each fiber uses).

## Current State

- Phases 1-13 COMPLETED (15 of 18 plan phases counting R1, 12a, 12b; remaining: 14a, 14b,
  14c, 15, 16a, 16b, 17).
- Full `lake build` green: 1748 jobs. Scoped module 1033, aggregator 1045.
- Sorry census over `NfMultiAnchorBridge/`: 0. Sorry inventory: EMPTY.
- KampPrior sorry count still exactly 2 (:361, :364) — task-358 territory, untouched.
- Commits: `8b4cafcc0` (phase 13.1, R3 probe green), phase-13 completion commit (this one).

## Phase-13 delivered names (BINDING — consume, never rebuild)

All in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberKitK1.lean`,
namespace `Bimodal.Metalogic.WeakCanonical.Kamp`, env `[w,x,t]` = `Fin.cons w (Fin.cons x
(fun _ => t))`, ambient `w < x < t`:

| Asset | Content |
|---|---|
| `ext3Mk` | arity-3 zone-spec builder from three `Bool × Bool` pairs |
| `extZBelowW/extZAtW/extZIntWX/extZAtX/extZIntXT/extZAtT/extZAboveT` | the 7 order-consistent `ZoneSpec 3` constants of `w<x<t` |
| `ext3_zoneHolds_cons_iff` / `ext3_zs_ext` | arity-3 pointwise zoneHolds reading / zone-spec builder |
| `extZ_{belowW,atW,intWX,atX,intXT,atT,aboveT}_holds_iff` | per-zone monadic readings (`u<w`, `u=w`, `w<u∧u<x`, `u=x`, `x<u∧u<t`, `u=t`, `t<u`) |
| `extZone_consistent_lt` | routing: realized zone spec ∈ 7 consistent zones |
| `extZone_inconsistent_false` | fold bit of inconsistent fiber forced false under any realizer |
| `extZoneFiber_k1` | THE E1 kit: depth-1 fold at n=3 ↔ atom layer ∧ 7 per-zone monadic fiber clauses ∧ inconsistent falsity ∧ off-fiber honesty |
| `extProbeRow/Chi/Target/Quant/Qnf`, `extProbe_bit_true`, `extProbe_bit_false_of_ne`, `extProbe_quant_off`, `extProbe_clause_iff`, `extProbe_bitTrue_realized`, `extProbe_bitFalse_excluded` | R3 probe artifacts (risk retired) |

## Key Decisions

1. **R3 probe design**: unconditional iff (12a precedent — satisfiability not required;
   engine plumbing is what is probed). Quant layer = Classical `if τ = target` single true
   bit; other-fiber falsity via `nf0_zoneSpec_assemble`/`nf0_projFresh_assemble` round-trip
   injectivity; off-fiber honesty via `nf0_dropFresh_assemble`.
2. **Zone constants reuse `agg2Ltz/agg2Eqz/agg2Gtz`** (AggregateHookDischarge) — no new pair
   constants; the kit imports only `AggregateHookDischarge` (acyclic leaf).
3. **Point-zone clauses are stated at the anchor** (`nf_eval_nf M 0 1 (fun _ => w) χ`),
   not as `∃ v, v = w ∧ …` — cleaner for the 14a fold.
4. **defeq-transport gotcha** (recorded for 14a): `rw` cannot see through `extProbeQnf.2`/
   `.1` projections of a pair literal — introduce a `have h' : <unfolded form> := h`
   defeq-cast first, then `rw` at `h'`. Fin.cases at literal `⟨0, _⟩` does not reduce under
   `simp only [Fin.cons]` on zone-constant EQUALITIES — use `absurd (congrFun hz ⟨0, by
   omega⟩) (by decide)` for zone distinctness.
5. **Only the w<x-channel ambient (`w<x<t`) is delivered** per the phase letter; the future
   mirror (`x<t<w` zones) is Phase-15 (E5) territory.

## Sorry Inventory

[] (empty — module and all consumed assets sorry-free)

## References

- Plan: `specs/350_.../plans/03_negfix-refactor-exterior-carriers.md` Phase 14a (line ~646)
- Kit template consumed: `nf_eval_depth1_fold_iff` (CarrierKv.lean:466), `agg2_*`
  (AggregateHookDischarge.lean), split kit (NfEFold.lean:153-260)
