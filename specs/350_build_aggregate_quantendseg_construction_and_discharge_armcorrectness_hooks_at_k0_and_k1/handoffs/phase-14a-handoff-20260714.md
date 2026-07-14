# Phase 14a Handoff — (E2) Since-navigated w-package `navPackLeft` (task 350)

**Status**: Phase 14a COMPLETED. Single-phase dispatch (phase_number=14a); stopped at phase
boundary per contract. Session `sess_1784009176_e5245f`.

## Immediate Next Action (Phase 14b — E3 `navDistribLeft`)

In the SAME module `Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean`: distribute the
w-INDEPENDENT parts out of the `∃w`. Rabinovich anchor: Lemma 7.6 gluing decomposition
(chunk_0021). Per the plan: `v=x` char → `endpointLeft` conjunct; `x<v<t` fibers → (x,t)
bracket arrangement slots + exclusion segment; `v=t`, `t<v`, atoms at `t` → `endpointRight`.
This peeling avoids both refutations (no monadic re-fibering of joint depth-1 content (F1);
no single predicate carrying t-reads (world-locality)). No new file — extend
ExteriorNavPastK1.lean; no new import line needed.

## Current State

- Phases 1-13 + 14a COMPLETED (16 of 18 plan phases counting R1, 12a, 12b; remaining:
  14b, 14c, 15, 16a, 16b, 17).
- Full `lake build` green: 1749 jobs. Scoped module 1034, aggregator 1046.
- Sorry census over `NfMultiAnchorBridge/`: 0. Sorry inventory: EMPTY.
- KampPrior sorry count still exactly 2 (:361, :364) — task-358 territory, untouched.

## Phase-14a delivered names (BINDING — consume, never rebuild)

All in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNavPastK1.lean`,
namespace `Bimodal.Metalogic.WeakCanonical.Kamp`, section variables `(atomMap) (h_surj)`:

| Asset | Content |
|---|---|
| `navLProjW row` | position-0 predicate projection `NormalForm sig 0 3 → NormalForm sig 0 1` |
| `navLPastLit χ` | `S(charF χ, ⊤)` (native `.snce` past-lit) |
| `navLAtWPack σ` | w-point package: atoms-at-w char ∧ v=w fiber literals ∧ v<w Since-lits |
| `navLBitTrueList σ` | `(univ.filter fun χ => σ.2 (nf0_assemble extZIntWX χ σ.1) = true).toList` |
| `navLSegGuard σ` | exclusion segment: disjList of bit-true characteristics |
| `navLChain σ L` | nested-Since arrangement chain, guard `navLSegGuard`, anchor `navLAtWPack` |
| `navPackLeft σ : TemporalPred` | disjList over `(navLBitTrueList σ).permutations` of `navLChain σ` |
| **`navPackLeft_correct M σ x`** | `(navPackLeft atomMap h_surj σ).eval_at M atomMap x ↔ ∃ w < x, (∀ p, M.interp p w ↔ σ.1 (.pred p ⟨0,_⟩)) ∧ (∀ χ, χ@w ↔ atW-bit) ∧ (∀ χ, (∃ v<w, χ@v) ↔ belowW-bit) ∧ (∀ χ, (∃ v∈(w,x), χ@v) ↔ intWX-bit)` — clause shapes verbatim from `extZoneFiber_k1`; NO ambient hypothesis |

Private helpers (NOT exported; re-derive locally if 14b needs them): `navL_profile_iff`,
`navL_profile_unique`, `navL_profile_exists`, `navL_char_correct`, `navL_pastLit_iff`,
`navL_bitGroup_iff`, `navL_atWPack_iff`, `navL_bitTrueList_mem`, `navL_bitTrueList_nodup`,
`navL_segGuard_iff`, `navL_chain_sound`, `navL_listMax`, `navL_chain_complete`. (14b/14c
extend the SAME file, so these privates ARE in scope there — reuse directly.)

## Key Decisions

1. **Device per fiber class** (dispatch requirement): atoms-at-w = char of `navLProjW`
   projection; v=w = characteristic literal (negated on bit-false); v<w = native Since-lit
   `S(charF χ, ⊤)` (negated on bit-false); w<v<x bit-TRUE = arrangement slots
   (permutation-disjunct nested-Since chain); w<v<x bit-FALSE = exclusion segment.
   **Phase-11 `negFix` NOT needed at any fiber** — profiles are exhaustive+exclusive, so
   the segment guard (disjunction of bit-true chars) excludes every bit-false profile.
2. **Fold iff is ambient-free**: `navPackLeft_correct` takes NO `w < x < t` hypothesis —
   the `∃ w < x` binder is produced by the Since fold itself. 14c's `∃w` glue consumes it
   by direct rewriting against `extZoneFiber_k1`'s clauses (which DO carry the ambient).
3. **Chain completeness technique**: strong induction on the profile-list length; at each
   step extract the profile with MAXIMAL chosen witness (`navL_listMax` over `T.attach`
   with Classical choice), strict decrease from witness distinctness via
   `navL_profile_unique`; permutation bookkeeping via `List.perm_cons_erase` +
   `List.mem_permutations`.
4. **Chain soundness invariant**: every interior point of `(w, u)` is EITHER guard-true or
   a listed witness (trichotomy against the head witness) — the witness case collapses
   into the guard at the top level because listed profiles are bit-true.
5. **Lean 4.27 gotchas hit**: `List.not_mem_nil` no longer takes the element explicitly;
   `intro -` is not valid (use `intro _`); unused section variables (`h_surj`) are
   auto-omitted from helper signatures — call sites must match.

## Sorry Inventory

[] (empty — module and all consumed assets sorry-free)

## References

- Plan: `specs/350_.../plans/03_negfix-refactor-exterior-carriers.md` Phase 14a (line ~654,
  now [COMPLETED]) and Phase 14b (line ~690).
- Consumed: `extZoneFiber_k1` kit names (Phase-13 handoff), `nf_depth0_char_formula{_correct}`
  (Separation/KampTranslation.lean), `formula_{conj,disj}List_iff` (same),
  `temporal_truth_{and,neg,top}` (Kamp/Translation.lean), `buildLeft` technique
  (Translation.lean:298 — cited, not consumed; own recursion used for the clean base case).
