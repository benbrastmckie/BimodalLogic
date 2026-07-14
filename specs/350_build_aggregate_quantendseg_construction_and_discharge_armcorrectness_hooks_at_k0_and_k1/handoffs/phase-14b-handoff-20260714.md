# Phase 14b Handoff — (E3) w-independent distribution `navDistribLeft` (task 350)

**Status**: Phase 14b COMPLETED. Single-phase dispatch (phase_number=14b); stopped at phase
boundary per contract. Session `sess_1784009176_e5245f`.

## Immediate Next Action (Phase 14c — E4 `CExtPast(_correct)` + ∃w pin glue + 3-bot falsity)

Assemble E1-E3 into the per-qnf past-exterior carrier `CExtPast (qnf) : VVecEA2` in the SAME
module `Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean`. Rabinovich anchors: Lemma 7.6
`(∃z1)_{z0}^{z2}(ϕ1∧ϕ2)` closure (chunk_0021) for the ∃w glue at the pin x; Lemma 7.8(1)
(chunk_0022). Assembly is now PURE PLUMBING against `navDistribLeft`:
- Disjuncts: one `⟨L.length, VecEA2⟩` per `L ∈ (navDXTBitTrueList qnf).permutations` with
  `endpointLeft = ⟨Formula.and (navPackLeft qnf).formula (navDAtXPack qnf)⟩`,
  `endpointRight = ⟨navDAtTPack qnf⟩`, `bracket = navDXTBracket qnf L`.
- `VVecEA2.holds x t` unfolds to `∃ vea ∈ disjuncts, epL@x ∧ epR@t ∧ bracket.holds x t`;
  with the shared endpoints this is epL@x ∧ epR@t ∧ (∃ L ∈ perms, bracket L holds) — exactly
  the first four conjuncts of `navDistribLeft`'s RHS.
- The three pure σ-conditions (`navDOrderRow`, inconsistent-zone falsity, off-fiber honesty)
  are DECIDABLE in qnf: gate the disjunct list on them (empty list `⟨[]⟩` when any fails —
  its holds is False) and derive the failing directions from `extZone_inconsistent_false` /
  the atom layer, giving `CExtPast_correct` under ambient x < t:
  `(CExtPast qnf).holds M atomMap x t ↔ ∃ w, w < x ∧ nf_eval_nf M 1 3 [w,x,t] qnf`.
- 3-bot falsity lemmas for order-channel-inconsistent qnf (arity-3 `agg2_zone_consistent_*`
  technique — `extZone_inconsistent_false` is already the fold-bit form).

## Current State

- Phases 1-13 + 14a + 14b COMPLETED (17 of 18 plan phases; remaining: 14c, 15, 16a, 16b, 17
  per the plan's phase inventory — handoff counts phases_completed=17, phases_total=18 per
  dispatch DoD convention).
- Full `lake build` green: 1749 jobs. Scoped module 1035, aggregator 1046.
- Sorry census over `NfMultiAnchorBridge/`: 0. Sorry inventory: EMPTY. (Compiler cross-check
  shows 30 project-wide sorry warnings — ALL pre-existing, outside territory: KampPrior 2 at
  :361/:364 = task-358; rest are long-standing Bundle/TruthLemma/EFGames/BXCanonical debt.)
- `lean_verify` on `navDistribLeft`, `navDXTBracket_arrangements_iff`: exactly
  `[propext, Classical.choice, Quot.sound]`, no warnings.
- No frozen-file / KampPrior / task-358 edits. `nf_char3_deeper_split` not referenced.

## Phase-14b delivered names (BINDING — consume, never rebuild)

All in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean`
(module now 976 lines; new import: `Kamp.VecEAConjFull` for `BracketFormula.snoc` kit),
namespace `Bimodal.Metalogic.WeakCanonical.Kamp`, section variables `(atomMap) (h_surj)`:

| Asset | Content |
|---|---|
| `navDProjX / navDProjT row` | position-1 / position-2 predicate projections |
| `navDFutLit χ` | `U(charF χ, ⊤)` native future Until-lit (dual of `navLPastLit`) |
| `navDAtXPack σ : Formula` | endpointLeft conjunct: atoms-at-x char ∧ v=x char bitGroup |
| **`navD_atXPack_iff`** | at x ↔ position-1 atom layer ∧ extZAtX fiber biconditionals (public) |
| `navDAtTPack σ : Formula` | endpointRight content: atoms-at-t char ∧ v=t bitGroup ∧ t<v futLit bitGroup |
| **`navD_atTPack_iff`** | at t ↔ position-2 atom layer ∧ extZAtT ∧ extZAboveT biconditionals (public) |
| `navDXTBitTrueList σ` | bit-true extZIntXT profile inventory |
| `navDXTSegGuard σ : TemporalPred` | (x,t) exclusion segment (disjunction of bit-true chars) |
| `navDXTBracket σ L : BracketFormula L.length` | snoc-recursive arrangement, head = slot nearest t, guard on every gap |
| **`navDXTBracket_arrangements_iff`** | (∃ L ∈ perms, bracket holds on (x,t)) ↔ extZIntXT fiber biconditionals verbatim; NO ambient hypothesis (public) |
| `navDOrderRow σ : Prop` | the six w-independent order-row bit conditions |
| **`navDistribLeft M σ x t (hxt : x < t)`** | `(∃ w < x, nf_eval [w,x,t] σ)` ↔ navPackLeft@x ∧ navDAtXPack@x ∧ arrangement disjunct ∧ navDAtTPack@t ∧ navDOrderRow ∧ inconsistent-falsity ∧ off-fiber honesty |

Private helpers (in scope for 14c, same file): `navD_futLit_iff`, `navD_xtBitTrueList_mem`,
`navD_xtBitTrueList_nodup`, `navD_xtSegGuard_iff`, `navD_bracket_sound`,
`navD_bracket_complete`, `navD_atomBit_false`, `navD_atomBit_iff_false`, `navD_atomLayer_iff`.

## Key Decisions

1. **Fin bridge via snoc, not bespoke plumbing**: the (x,t) arrangement is built by
   `BracketFormula.snoc` recursion (`VecEAConjFull`) so sound/complete are LIST inductions
   peeling one witness at a time through `snoc_holds_iff` (last witness = head of L, nearest
   t) and `trivial_holds` ([] case = pure guard) — no Fin-indexed witness-sequence plumbing
   (the `k1v_bracket_extract`/`construct` machinery in CarrierK1V is private and two-region;
   not consumed).
2. **Completeness by maximum extraction, verbatim 14a**: `navL_listMax` + Classical choice +
   `navL_profile_unique` strict decrease — identical induction to `navL_chain_complete`.
3. **Order row as a pure σ-condition**: the six order bits are constant across all `w < x`
   given ambient `x < t`, so they distribute out of the ∃w as `navDOrderRow` (a Prop on σ,
   not a formula slot). 14c gates the disjunct list on them (decidable).
4. **`navDistribLeft` stated formula-level** (not clause-level): RHS conjuncts are the actual
   predicates at their slots, so 14c's `CExtPast_correct` is direct rewriting — no re-peeling.
5. **Lean 4.27 elaboration gotchas hit**: (a) `by omega` proofs inside VALUE-position
   `Fin.mk`s create synthetic-opaque metavariables that block `Fin.cons` iota reduction during
   unification — use `(0 : Fin 3)` OfNat literals or let the expected type drive the atom via
   `(h _)`; (b) two-discriminant `match i, j` on Fin 3 literals needs `⟨_ + 3, hn⟩` catch-all
   arms (single-discriminant does not); (c) multi-line match-arm tactic bodies mis-parse —
   keep arms single-line (helper lemma `navD_atomBit_iff_false`).

## Sorry Inventory

[] (empty — module and all consumed assets sorry-free)

## References

- Plan: `specs/350_.../plans/03_negfix-refactor-exterior-carriers.md` Phase 14b (line ~690,
  now [COMPLETED]) and Phase 14c (line ~723).
- Consumed: Phase-14a `navPackLeft`/`navPackLeft_correct` + privates (same file);
  Phase-13 `extZoneFiber_k1` clause shapes (ExteriorFiberKitK1.lean);
  `BracketFormula.{snoc, snoc_holds_iff, trivial, trivial_holds}` (VecEAConjFull.lean /
  VecEAFormula.lean); `nf_depth0_char_formula{_correct}` (Separation/KampTranslation.lean).
- Rabinovich 2014: Lemma 7.6 gluing decomposition (chunk_0021).
