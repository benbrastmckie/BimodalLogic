# Phase 14a Summary — (E2) Since-navigated w-package `navPackLeft` (task 350)

**Status**: Phase 14a COMPLETED. Single-phase hard-mode dispatch (`phase_number=14a`);
stopped at the phase boundary per contract. Session `sess_1784009176_e5245f`.

## Delivered

New leaf module
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean`
(488 lines), namespace `Bimodal.Metalogic.WeakCanonical.Kamp`, imports only
`ExteriorFiberKitK1` (Phase-13 kit) + upstream `Kamp.Translation`. Aggregator import + NOTE
added to `NfMultiAnchorBridge.lean` after `ExteriorFiberKitK1`.

| Asset | Content |
|---|---|
| `navLProjW` | position-0 predicate projection of the arity-3 atom row (the profile at `w`) |
| `navLPastLit` (+ `navL_pastLit_iff`) | native past Since-lit `S(charF χ, ⊤)` = "some strict-past point realizes χ" |
| `navL_bitGroup_iff` | generic polarity-group reading (conjunction of bit-directed literals over all profiles) |
| `navLAtWPack` (+ `navL_atWPack_iff`) | the w-point package: atoms-at-w characteristic ∧ `v=w` fiber literals ∧ `v<w` Since-lits |
| `navLBitTrueList` / `navLSegGuard` (+ readings) | bit-TRUE `w<v<x` profile inventory / exclusion segment (disjunction of bit-true characteristics) |
| `navLChain` | nested-Since arrangement chain (Lemma 7.10 shape; `buildLeft` technique anchored at the w-package) |
| `navL_chain_sound` | chain at `u` ⇒ anchor `w<u` + package + per-slot witnesses + guarded interior |
| `navL_listMax` / `navL_chain_complete` | maximum-extraction witness threading ⇒ SOME arrangement's chain holds |
| **`navPackLeft`** | THE E2 deliverable: `TemporalPred` = disjunction over `(navLBitTrueList σ).permutations` of `navLChain` |
| **`navPackLeft_correct`** | THE fold iff: predicate at pin `x` ↔ `∃ w < x` ∧ the four w-dependent clause groups of `extZoneFiber_k1`, stated verbatim in the Phase-13 kit shapes; NO ambient hypothesis (the fold introduces `w`) |

## Device record (per fiber class — Phase 14a dispatch requirement)

- **atoms at w**: `nf_depth0_char_formula` on `navLProjW σ.1`.
- **v = w, bit-true / bit-false**: characteristic conjunct / negated characteristic.
- **v < w, bit-true / bit-false**: native Since-lit `S(charF χ, ⊤)` / negated Since-lit (native `.snce`).
- **w < v < x, bit-true**: arrangement slots inside the fold — one disjunct per permutation of
  the bit-true profile list; witnesses threaded descending by maximum extraction + profile
  uniqueness.
- **w < v < x, bit-false**: exclusion segment — guard = disjunction of bit-TRUE
  characteristics; profiles exhaustive+exclusive (`navL_profile_exists`/`_unique`) force every
  interior point onto a bit-true profile.
- **Phase-11 `negFix`: NOT consumed** — the exclusion-segment device sufficed at every fiber.

## Verification

- Scoped module build 1034 jobs, aggregator 1046 jobs, full `lake build` 1749 jobs — all green.
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.navPackLeft_correct` = exactly
  `[propext, Classical.choice, Quot.sound]`, no warnings.
- Sorry census over `NfMultiAnchorBridge/`: 0. New file: 0 sorries, 0 vacuous patterns.
- Vacuous (1) / axiom (2) repo counts identical to HEAD baseline.
- Guards: FORBIDDEN `nf_char3_deeper_split` not referenced; the seven frozen provider files,
  `KampPrior.lean`, and task-358 territory untouched (diff = new leaf + aggregator + plan).

## Plan deviations

None. Module ran 488 lines vs the ~300-400 estimate (the completeness induction and the
generic polarity-group helper account for the overage); all listed deliverables landed.
