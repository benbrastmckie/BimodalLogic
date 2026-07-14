# Phase 15 Handoff — (E5 + E6) future-exterior mirror `CExtFut(_correct)` (task 350)

**Status**: Phase 15 COMPLETED. Single-phase dispatch (phase_number=15); stopped at phase
boundary per contract. Session `sess_1784009176_e5245f`.

## Immediate Next Action (Phase 16a — zone classifier + per-qnf dispatcher `C(qnf)`)

Create `Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean` (imports per plan: `VecEAConjFull`,
`EANegationFix` shim, `AggregatePointMergeK1`, `ExteriorNavPastK1`, `ExteriorNavFutK1`,
`AggregateHookDischarge`) + aggregator import line. Zone-classifier totality for arity 3
(order bits at pairs (0,1),(0,2) of `qnf.1`): every qnf routes to exactly one of
3-int / 3-pt(w=x) / 3-pt(w=t) / 3-ext(w<x) / 3-ext(t<w) / 3-bot given ambient x < t; then the
per-qnf dispatcher `C(qnf) : VVecEA2` + clause iff casing on the classifier.

**Classifier keying (both exterior channels now delivered)**: the past channel's gate keys on
`navDOrderRow` (bits (0,1)T,(0,2)T,(1,2)T + reverses F — pattern w<x<t); the future channel's
on `navROrderRow` (bits (1,2)T,(1,0)T,(2,0)T + reverses F — pattern x<t<w). The 3-bot route
for exterior-shaped rows failing both patterns has BOTH eval-side falsity lemmas
(`navD_inconsistent_eval_false` / `navR_inconsistent_eval_false`) and carrier-side off-gate
falsity (`CExtPast_offGate_false` / `CExtFut_offGate_false` — stated WITHOUT ambient, which is
what the dispatcher wants when routing inconsistent σ).

## Current State

- Phases 1-13 + 14a + 14b + 14c + 15 COMPLETED (19 phase headings done of the plan's
  22-heading inventory; remaining: 16a, 16b, 17).
- Full `lake build` green: 1750 jobs. Scoped module 1036.
- Sorry census over `NfMultiAnchorBridge/`: 0. Sorry inventory: EMPTY.
- `lean_verify` on `CExtFut_correct`, `navPackRight_correct`, `navDistribRight`,
  `navR_inconsistent_eval_false`, `CExtFut_offGate_false`, `CExtFut_inconsistent_false`:
  exactly `[propext, Classical.choice, Quot.sound]`, no warnings.
- No frozen-file / KampPrior / task-358 edits (diff = new ExteriorNavFutK1.lean (1484 lines) +
  aggregator import + plan file). `nf_char3_deeper_split` not referenced.
- Incremental commits: 15.1 (zone kit), 15.2 (w-package), 15.3 (distribution), 15.4 (carrier),
  15 final (aggregator + wrap-up).

## E6 DECISION (BINDING RECORD): duplication fallback

`extDuality` NOT landed. Probe: no `M`-reversal / OrderDual `OrderedMonadicStructure`
machinery exists anywhere in `WeakCanonical`; a genuine duality would need (a) an OrderDual
structure instance, (b) Since/Until formula-duality truth transport, (c) σ order-atom +
env-position reindexing — strictly more machinery than the mirror itself. Codebase precedent
(`ExteriorNegationPast.lean`) mirrors by explicit duplication. E5 therefore duplicates the
E1-E4 shapes time-reversed, per the plan's prescribed fallback. Recorded also in the module
docstring.

## Phase-15 delivered names (BINDING — consume, never rebuild)

All in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNavFutK1.lean`
(new module, 1484 lines; imports ONLY `ExteriorNavPastK1`), namespace
`Bimodal.Metalogic.WeakCanonical.Kamp`, section variables `(atomMap) (h_surj)`:

| Asset | Content |
|---|---|
| `extFZBelowX/extFZAtX/extFZIntXT/extFZAtT/extFZIntTW/extFZAtW/extFZAboveW` | the 7 order-consistent zones of `x<t<w` over env `[w,x,t]` (FRESH constants — the future-channel fibers of σ live at these specs, NOT at the past channel's `extZ*`, because a ZoneSpec encodes v's relation to the witness w) |
| `extFZ_*_holds_iff` ×7 | per-zone monadic readings under ambient `x<t`, `t<w` |
| `extFZone_consistent_lt` / `extFZone_inconsistent_false` | future-ambient routing + inconsistent-fiber falsity |
| **`extZoneFiberFut_k1`** | the 7-zone partition of the depth-1 fold at n=3, env `[w,x,t]`, ambient `x<t<w` (the E1 mirror Phase 13 did not deliver) |
| `navRAtWPack` | future w-point package: atoms-at-w (`navLProjW` reused) + v=w chars (`extFZAtW`) + w<v Until-lits (`navDFutLit` over `extFZAboveW`) |
| `navRBitTrueList` / `navRSegGuard` | bit-TRUE `t<v<w` profiles (`extFZIntTW`) + `(t,w)` exclusion segment |
| `navRChain` | nested-Until arrangement chain (bottom slot nearest t first; completeness threads witnesses ASCENDING by min extraction) |
| **`navPackRight` / `navPackRight_correct`** | Until-navigated w-package TemporalPred at pin `t`; fold iff = `∃ w > t` of the four w-dependent clause groups; no ambient needed |
| `navRAtXPack` / `navR_atXPack_iff` (public) | endpointLeft content: atoms-at-x + v=x chars (`extFZAtX`) + v<x Since-lits (`navLPastLit` over `extFZBelowX`) |
| `navRAtTPack` / `navR_atTPack_iff` (public) | endpointRight conjunct: atoms-at-t + v=t chars (`extFZAtT`) |
| `navRXTBitTrueList` / `navRXTSegGuard` / `navRXTBracket` / **`navRXTBracket_arrangements_iff`** | `(x,t)` bracket arrangement over the FUTURE-channel interior fibers `extFZIntXT` |
| `navROrderRow` | the six order bits of pattern `x<t<w`: (1,2)T,(1,0)T,(2,0)T,(0,1)F,(0,2)F,(2,1)F |
| **`navDistribRight`** | under ambient `x<t`: `∃ w>t, nf_eval [w,x,t] σ` ↔ `navPackRight`@t ∧ `navRAtTPack`@t ∧ (x,t)-arrangement ∃L ∧ `navRAtXPack`@x ∧ `navROrderRow` ∧ inconsistent-falsity ∧ off-honesty |
| `navRGate σ : Prop` | the three pure σ-side conjuncts of `navDistribRight` |
| **`CExtFut σ : VVecEA2`** | on-gate: one VecEA2 per `L ∈ (navRXTBitTrueList σ).permutations`, `endpointLeft = ⟨navRAtXPack σ⟩`, `endpointRight = ⟨(navPackRight σ).formula.and (navRAtTPack σ)⟩`, `bracket = navRXTBracket σ L`; off-gate `⟨[]⟩` |
| **`CExtFut_correct M σ x t (hxt : x < t)`** | `(CExtFut σ).holds M atomMap x t ↔ ∃ w, t < w ∧ nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ` |
| `navR_inconsistent_eval_false` / `CExtFut_offGate_false` / `CExtFut_inconsistent_false` | 3-bot falsity trio (off-gate stated WITHOUT ambient) |

## Key Decisions

1. **E6 duplication fallback** (see binding record above).
2. **Env convention unchanged**: the future channel keeps env `[w,x,t]` =
   `Fin.cons w (Fin.cons x (fun _ => t))` with the witness at position 0 (the 14c handoff's
   "[x,t,w]" was shorthand for the ORDERING x<t<w, not a different env vector) — this is what
   the Phase-16a dispatcher needs (order bits at pairs (0,1),(0,2) of `qnf.1`).
3. **The E1 mirror was in-scope**: Phase 13's kit covers only the `w<x<t` ambient; the future
   channel's 7 zones are DIFFERENT ZoneSpecs (v-vs-witness coordinate flips), so
   `extZoneFiberFut_k1` + fresh `extFZ*` constants had to land here. This is why the module is
   1484 lines vs the plan's 350-450 estimate — content, not scope creep.
4. **Endpoint roles mirror**: past channel glued the w-package into `endpointLeft` (at x);
   future channel glues `navPackRight ∧ navRAtTPack` into `endpointRight` (at t), with
   `navRAtXPack` alone as `endpointLeft`. `temporal_truth_and` is again the only splitter.
5. **Private helpers re-derived locally** (`navR_profile_*`, `navR_char_correct`,
   `navR_bitGroup_iff`, `navR_listMin`/`navR_listMax`, `navR_futLit_iff`/`navR_pastLit_iff`,
   `extF_zs_ext`) — the past module's are `private`; the established idiom (14a did the same
   vs ExteriorNegation.lean) is copy, not de-privatize (frozen-adjacent files not touched).

## Sorry Inventory

[] (empty — module and all consumed assets sorry-free)

## References

- Plan: `specs/350_.../plans/03_negfix-refactor-exterior-carriers.md` Phase 15 (now
  [COMPLETED], line ~759) and Phase 16a (line ~805).
- Consumed: Phase-13 `ext3Mk`/`ext3_zoneHolds_cons_iff`/`agg2*z`/`k1v_bool_eq_false`;
  Phase-14a `navLProjW`/`navLPastLit`; Phase-14b `navDProjX`/`navDProjT`/`navDFutLit`;
  `BracketFormula.snoc_holds_iff`/`trivial_holds` (VecEAConjFull, via ExteriorNavPastK1);
  `CExtPast` dite gate pattern.
- Rabinovich 2014: Lemma 7.8(2) TL(Until,K⁻) (chunk_0022); Lemma 7.10/Prop 3.5 (chunks
  0023, 0010); Lemma 7.6 (chunk_0021).
