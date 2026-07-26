# Execution Summary: SharedWitness Declaration-Anchored Module Split

- **Task**: 341 - structural_refactor_sharedwitness_carrier_layer
- **Plan**: `plans/03_declaration-anchored-module-split.md` (v03, declaration-anchored)
- **Status**: COMPLETED — all 20 phases
- **Type**: lean4
- **Session**: sess_1785103409_6af9e1_341

## Outcome

`NfMultiAnchorBridge/SharedWitness.lean` — 13,386 lines / 462 top-level declarations — is now a
**86-line re-export hub holding zero declarations**. All 462 declarations live in ten sibling
modules under `NfMultiAnchorBridge/SharedWitness/`, cut into a strict backward-import tower.

| Module | LOC | Decls | Imports |
|---|---|---|---|
| `Slots.lean` | 924 | 79 | `SubBracket2V`, `NavigatedSpine` |
| `OrderGate.lean` | 1552 | 98 | `Slots` |
| `Carrier.lean` | 783 | 24 | `OrderGate` |
| `Completeness.lean` | 1139 | 42 | `Carrier` |
| `EngineInputs.lean` | 1405 | 64 | `Completeness` |
| `Soundness.lean` | 1618 | 51 | `EngineInputs` |
| `DisjunctionSpikes.lean` | 1302 | 37 | `Soundness` |
| `Assembly.lean` | 1658 | 40 | `DisjunctionSpikes` |
| `KitFold.lean` | 1814 | 17 | `Assembly` |
| `FragmentFoldRight.lean` | 1392 | 10 | `KitFold` |
| `SharedWitness.lean` (hub) | 86 | **0** | all ten |

Declaration counts match the plan's partition exactly (79/98/24/42/64/51/37/40/17/10 = 462).

## Verification

- **Content conservation proven exactly**: the concatenation of the ten modules' bodies is
  **byte-identical, line-for-line and in order**, to the pre-split file body — 12,730 non-blank
  lines on both sides, with the hub retaining zero. This was machine-checked, not sampled.
- **Full-tree `lake build` GREEN** after every one of the 13 commits; `BimodalTest` GREEN.
- **Axioms unchanged**: `completeness_discrete`, `kvE2_sepBody`, `kvE2_outer_fold_frag`, and
  `kvE2_sepPosI` all depend on exactly `{propext, Classical.choice, Quot.sound}` — identical to
  the Phase-1 baseline.
- **Zero sorries introduced**; zero axioms introduced. The repository's sole live `sorry`
  remains the single one in `countermodel_discrete` (`Transfer.lean:1242`, located by content).
- **Import equivalence**: a tripwire referencing all 27 externally-consumed symbols through the
  hub alone elaborates clean.
- **Downstream byte-unchanged**: the only files modified under `Theories/` are
  `SharedWitness.lean` and the ten new modules. `KampPrior.lean`, `OuterGate.lean`,
  `ExteriorZoneTriage.lean`, `ExteriorNegation(Past).lean`, `ExteriorGateAssembleK.lean`, the
  aggregator, `NavigatedSpine.lean` and `CarrierK1V.lean` are all untouched — so the
  `bracketEndChar_kvE2` LITMUS record and the F1-F7 invariants are preserved by
  non-modification.

## Plan Deviations

1. **Phase 3 — privatize-first was inverted (altered).** The plan's central sequencing premise
   does not hold: Lean `private` is *file*-scoped, so a symbol privatized in the monolith
   becomes invisible to every later module of the tower. Privatizing more symbols before the
   cut would have had to be undone during extraction. Measurement found the converse problem
   already present — **19 existing `private` declarations are consumed across the planned module
   bands** and had to be made module-public for the split to build at all. This phase
   de-privatized those 19 (each with a one-line provenance comment) instead of adding privates.
   Re-privatizing per-module is now correct and cheap, and is the recommended follow-up.
2. **Phase 5 — `md:NN` register moot (skipped).** Commit `e70535a2a` (*re-anchor 89 dangling
   md:NN citations to PDF page references*), landed by a concurrent dispatch between this plan's
   baseline and the first code move, already converted all 89. Zero `md:NN` remain in the tower.
   One stale `` `md:` `` preamble pointer survived in the hub docstring and was re-cited to PDF
   pages.
3. **Phases 5/17 — CarrierK1V placeholder already resolved (skipped, no-op).** Task 349's
   completed execution had already archived the `endIntervalStep`/`endInterval` skeleton to
   `Kamp/Boneyard/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean` and left an adequate
   supersession NOTE. `CarrierK1V.lean` was not modified.
4. **Phase 13/16 — G/H boundary correction (altered).** The first cut placed
   `kvE2_sepSlotGIdx_honestOrder'` at the tail of module G (38/39 rather than 37/40): the
   anchor-matching regex's word boundary after the primed name's apostrophe matched
   `kvE2_sepSlotGIdx_honestOrder'_mono`. Corrected in Phase 16 by moving the declaration and its
   section banner to the head of `Assembly.lean`.
5. **Phase 18 — deleted-symbol residues reviewed, not rewritten (altered).** Of the 23 residues,
   all but one already frame the removed symbols explicitly as removed or replaced; several
   apparent hits are the *live* `kvE2_sepValid_tie_of_nodup` matching on a name prefix. The one
   genuinely misleading case — the "DELIBERATELY not yet wired" banner in `OrderGate.lean`,
   which documents live definitions but whose wiring narrative names removed symbols — was
   PRESERVED with a `NOTE:`, per the preserve-over-delete direction.
6. **Phase 18 — `hgate` residue dropped (skipped).** The candidate could not be located as dead
   code: the region between `kvE2_sepBody_complete_holds'` and `kvE2_sepDisjunct_extract` is a
   live docstring. Dropped per the plan's own "unlocatable items are dropped, not guessed" rule.
   The O4 CRUX RECORD banner was likewise preserved unchanged — it is self-labelled "inert;
   decision-gate input", a deliberate decision record rather than dead code.
7. **Phase 18 — 22 stale `SW:NNNN` pointers stripped (added, unplanned).** The split made the
   monolith line pointers doubly stale. Spot-checking showed they no longer resolved to the
   declarations their own prose names, so they were removed rather than re-anchored: re-resolving
   would have fabricated citations, the same hazard the plan identifies for `md:NN`.
8. **Phase 19 — docstrings written inline (altered).** Per-module docstrings were authored during
   each extraction rather than in a separate pass. No `section` structure was added: the modules
   already carry `/-! ## ` banners throughout, and `section` would have been the one
   non-behaviour-preserving structural risk for no navigational gain.

## Citation Discipline

Every citation authored in this refactor names Rabinovich by **PDF page only** (e.g. "Rabinovich
Lemma 3.2(1), PDF p.3"), never `md:NN`. The pre-existing `md:NN` citations had already been
re-anchored upstream, so nothing was propagated as if valid.

## Out-of-Scope Follow-Up (recorded, NOT executed)

Ten sibling files in `NfMultiAnchorBridge/` now exceed 1,000 lines and are candidates for their
own split tasks. Recording only, per the plan's scope bar:

| File | LOC | File | LOC |
|---|---|---|---|
| `InteriorGateGeneralK.lean` | 2552 | `AggregateOffDiagK1.lean` | 1561 |
| `SubBracket2V.lean` | 2263 | `ExteriorNavFutK1.lean` | 1503 |
| `Base.lean` | 2237 | `ExteriorPinnedConverseK.lean` | 1389 |
| `AggregateHookDischarge.lean` | 2191 | `ExteriorBracket.lean` | 1208 |
| `CarrierK1V.lean` | 2167 | `ExteriorNavPastK1.lean` | 1102 |

**Additional recommended follow-up**: a per-module re-privatization pass. 84 declarations were
file-private in the monolith and 19 had to be de-privatized for the cut. Now that the tower
exists, `private` scoped to a 750-1800 line module carries the meaning the plan originally
wanted, and the external contract is known to be just 27 symbols — so a large fraction of the
remaining 435 public declarations can be privatized module-locally.

## Commits

13 commits, each full-tree green: `task 341 phase 3` (de-privatization), `phase 6`-`phase 15`
(the ten extractions), `phase 16` (hub + G/H correction), `phases 17-19` (comment re-grounding).
