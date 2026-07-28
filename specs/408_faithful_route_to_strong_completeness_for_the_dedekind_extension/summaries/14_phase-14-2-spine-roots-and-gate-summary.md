# Phase 14.2 — the spine's two roots, and the gate discharged

**Status**: `[PARTIAL]` — landed slice green and sorry-free, remainder chartered as Phase 14.3.
**Build**: full `lake build` green at 1921 jobs. Census delta zero. All new declarations
axiom-clean at `[propext, Classical.choice, Quot.sound]`.

## The gate, and its answer

The phase's charter made one thing a gate before any other work: *does `aggOdPopFold_iff` bottom
out at `VVecEA2.negFix_iff` — in which case the whole phase is mechanical — or at some other
attained-only consumer, in which case report `[BLOCKED]`?* The charter said to verify rather than
assume, and to record the answer.

**It bottoms out at `VVecEA2.negFix_iff`.** Verified by reading `AggregateOffDiagK1.lean:1226-1258`
rather than inferring it from the docstring: `h_INF`/`h_SUP` appear in that proof at exactly one
line, `:1253`. The nil case (`VVecEA2.trivialTrue_holds`), the cons rewrite
(`VVecEA2.conjFull_iff`) and the bit-true branch are all carrier-free. Both consuming sites,
`aggPop1_correct` (`:1288`) and `aggPop1F_correct` (`:1381`), reach it the same way.

`VVecEA2.negFixFaithful_iff` (`EANegationFixFaithful/VecEANegFixFaithful.lean:244`) supplies
exactly that at the faithful carrier, and needs `HasFaithfulDedekindINF` **alone**.

The obligation was therefore not merely answered but **discharged**: `aggOdPopFold_iff_faithful` is
landed and sorry-free. **The spine re-base now has no remaining proof content.** Everything left is
restatement.

## What landed

622 lines, three new modules, zero edits to any existing Lean declaration.

| Module | Contents |
|---|---|
| `NfMultiAnchorBridge/PriorInterfaceFaithful.lean` | `ExistProvidersFaithful`, `.toExistProviders`, `BracketCarrierCorrectVPriorFaithful`, `.toBracketCarrierCorrectVPrior`, the two `k ≤ 1` lifts |
| `NfMultiAnchorBridge/OuterGateFaithful.lean` | `bracketEndChar_kvE2_hck_faithful`, `_complete_two_prior_faithful`, `_correct_two_prior_frag_faithful`, `…_covers_prior` |
| `NfMultiAnchorBridge/AggregateOffDiagK1Faithful.lean` | `aggOdPopFold_iff_faithful`, `…_covers_attained`, `…_on_prior` |

`PriorInterface.lean` and `OuterGate.lean` were the right slice because they are the **only two
roots** of the bridge's UZ/SZ subgraph: `PriorInterface` imports only `CarrierKv` and `OuterGate`
only `SharedWitness`, neither of which mentions a completeness carrier, while every other
UZ/SZ-carrying bridge module sits above one of them.

The only edit outside those three files is `kampFaithfulExpressiveCompleteness_open`'s own
docstring, which the phase charter explicitly permits.

## Findings

1. **`bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean:297`) is already carrier-free.**
   Despite the `_prior` in its name it binds no `SemanticPriorUZ` at all — `hfrag` plus the four
   provider obligations carry the whole ⇒ direction. It needed no faithful sibling and is reused
   verbatim. A `_prior` name in this tree does not reliably indicate a carrier binder; the next
   dispatch should size by reading bodies, not names.

2. **`private` is the real obstruction to the new-modules-only strategy, and it is
   module-specific.** A faithful sibling can live in a new module only when everything it consumes
   is visible there. `ExteriorBracket.lean`'s carrier-consuming path runs through
   `kvE2_extGate_anyBit_iff` (`:837`), which is `private` — so its sibling must be added inside the
   original module, duplicating roughly 265 lines of body. That is a phase-sized deliverable, so it
   was diagnosed and chartered rather than started. Across the remainder, `private` declarations
   exist in 7 of the 15 remaining modules and are absent from the other 8 — **including
   `KampPrior.lean`, the single biggest chunk at 26 binder lines**, which is therefore re-basable
   with no edit to any existing file and should be scheduled early.

3. **The `SUP` half is still never consumed.** As at the ζ wire, `negFix_iff` needs attained INF
   *and* SUP whereas `negFixFaithful_iff` needs faithful INF alone. Threaded as `_h_SUP` for
   shape-parallelism, matching `ZetaUniformExtractFaithful.lean`'s deliberate decision. Deleting it
   would strengthen every faithful result; that remains an orchestrator-level call, now backed by
   two independent measurements.

## Scope correction

Plan v8 recorded the scope as **110 binder sites across 22 live modules**. That figure is **not
reproducible by the grep the plan itself cites**. Re-measured with
`grep -cE '(_?h_UZ|hUZ) *: *SemanticPriorUZ'` over the live tree, Boneyard excluded, the baseline
is **85 lines**. Of those:

- **5 re-based this dispatch** (`PriorInterface` 2, `OuterGate` 3);
- **8 are not re-base targets at all** — `PriorINF` (2) and `DedekindINF` (1) are the *suppliers*
  `prior_hasAttained*` / `prior_hasDedekind*`; `ZetaPriorTransfer` (2) already has faithful siblings
  in `ZetaUniformExtractFaithful.lean`; and `Lemma53Faithful` (2), `Lemma53FaithfulPast` (1) and
  `Prop42Faithful` (1) are the exclusion results that consume `HasAttainedINF.first_occ`'s attained
  conclusion and provably do **not** carry over;
- leaving **72 lines across 15 modules** as the genuine remainder, which Phase 14.3 inherits.

## Verification

| Check | Result |
|---|---|
| Full `lake build` | green, 1921 jobs |
| Live-tree sorry terms | 2 — `PriorExpressivenessDense.lean:286` (strategic, unchanged) and `Transfer.lean:1242` (pre-existing, out of scope) |
| Census delta | 0 |
| Sorries in new modules | 0 |
| Vacuous definitions | 1, unchanged (pre-existing) |
| `axiom` declarations | 2, unchanged (pre-existing) |
| `#print axioms`, all 11 new declarations | `[propext, Classical.choice, Quot.sound]` |
| Removals / renames | 0 / 0 |
| Existing Lean declarations edited | 0 |

## Literature grounding

Every statement rides its original's citations — Rabinovich, *A Proof of Kamp's Theorem* (2014):
Lemma 3.2(2) (PDF p.4) plus the §5 bracket notation `[α_0, …, α_n](z_0, z_1)` (PDF p.7) for the
two-fixed-endpoint framing; Prop 3.5 (PDF p.5) for the ∃-witness → Until/Since folding mechanism;
Cor 5.4 (PDF p.7/p.9) for per-round provider threading and the bounded interior witnesses; Lemma
3.4 (PDF p.5) for the ∧-closure and Prop 4.2 (PDF p.6, quoted verbatim in
`VecEANegFixFaithful.lean`) for the negated clauses.

**The re-basing itself has no source, and each new module says so.** Rabinovich draws no
distinction between the attained first-occurrence property and his own eq (5.2) dichotomy (PDF
p.8) — eq (5.2) *is* his stated property, and the attained strengthening is this tree's artifact.
Reynolds states no such separation either. The choice of carrier is therefore original work
answering `KampFaithfulExpressiveCompleteness` (`PriorExpressivenessDense.lean:169`), recorded
under the honesty charter rather than attributed to a source.
