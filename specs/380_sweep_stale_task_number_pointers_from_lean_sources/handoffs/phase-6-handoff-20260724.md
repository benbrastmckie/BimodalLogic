# Phase 6 Handoff — Metalogic remainder pointer sweep (task 380)

- **Session**: sess_1784922600_phase6
- **Status**: Phase 6 COMPLETED (phases 1-6 complete)

## Immediate Next Action

Phase 7: hand-edit everything outside `Metalogic/` — `Automation/` (187: `FormulaEnumerator.lean`
68, `DatasetGenerator.lean` 52, `DatasetExport.lean` 20, misc), `Syntax/` (12, incl. Formula.lean's
three "Complexity verification" headings needing content-based disambiguation per Settled decision
6), `Theorems/` (11, incl. TemporalDerived.lean), `ProofSystem/` (5), and ALL Boneyard-path files'
post-Phase-2 remainder — per `worklists/handedit-phase7.md` (266 entries).

**Protected spans for Phase 7**: the three sorry-carrying theorems in
`Kamp/Boneyard/EANegationVBracketBackward.lean` — `neg_bracket_zero_is_vbracket`,
`neg_bracket_is_vbracket`, `neg_partialBracketExist_is_vbracket`. Resolve BY DECLARATION NAME via
`scripts/protected-decls.txt`, never by line number. That file's `:8` docstring-prose `sorry` is
covered by the never-touch-sorry-lines guard.

**Boneyard stance (Postmortem, binding)**: mechanical number-drops ONLY. No truth-checks, no prose
curation, keep archival dates. `-- Archived: 2026-07-08 (task NNN)` → `-- Archived: 2026-07-08`;
"Resolution: <numbers>" → named routes; plan-phase labels like `(Task 3.4)` dropped.

**DatasetGenerator.lean**: comment edits only. The pre-existing `:2174` unused-variable 'q' warning
must be byte-identical before/after (Postmortem: no unrelated fixes).

## Current State

- All **144** Phase-6 worklist entries dispositioned across **48 files**: **140 edited**, **4
  DEFERRED** as NON-COMMENT string literals (see below).
- Territory **LIVE** recount (comment, non-sorry) = **0** for all of non-Boneyard `Metalogic/`.
- specs-path (`specs/[0-9]{3}_`) recount = **0** in all Phase-6 territory files. Nine plan/report
  path bullets were restated as design-provenance statements or deleted per Settled decision 3.
- Global recount: **273** (408 on Phase-6 entry → 273; −135 this phase).
- Gates: `--check-diff` → 48 changed `.lean` files, **0 failures** (comment-span-only);
  `lake build` **EXIT 0, 1789 jobs**; census exactly **906 raw / 820 non-comment / 26 sorryAx**;
  `git diff -U0` changed lines containing `sorry`: **0**; `^axiom ` count **2** = baseline;
  vacuous-definition count **1** = pre-existing baseline (`Examples/TemporalStructures.lean:269`,
  `:= trivial` on a goal that genuinely IS `True`; outside territory, unchanged);
  `git diff --stat` confined to the 48 territory files.
- **Protected spans honoured**: `protected-span exclusions: 0` — no sweep match falls inside any of
  the four named protected decls. `EANegation.lean` has ZERO sweep-pattern matches and is NOT among
  the 48 changed files, so `:1090` / `:1249` were never approached.

## DEFERRED — 4 NON-COMMENT string literals requiring a supervised human decision

All four are in `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`, inside `#eval` test
harness match arms. They are **runtime output strings**, not comments or docstrings, so editing
them falls outside this task's binding comment/docstring-only constraint. Left byte-identical.

| Site | Exact string |
|---|---|
| `Saturation.lean:855` | `\| some (.hasOpen _ _ _ _) => return "INFO: □p → always p open branch (blocking refinement needed, task 237)"` |
| `Saturation.lean:856` | `\| none => return "INFO: □p → always p fuel exhausted (blocking refinement needed, task 237)"` |
| `Saturation.lean:865` | `\| some (.hasOpen _ _ _ _) => return "INFO: □(□p) → G(□p) open branch (blocking refinement needed, task 237)"` |
| `Saturation.lean:866` | `\| none => return "INFO: □(□p) → G(□p) fuel exhausted (blocking refinement needed, task 237)"` |

**Recommendation**: authorise a narrow follow-up that drops the `, task 237` fragment from all four
strings, yielding `"INFO: □p → always p open branch (blocking refinement needed)"` etc. Rationale:
(i) the durable content — "blocking refinement needed" — is already the whole informative payload,
and the same rewrite was applied to the sibling COMMENT at `:848` in this phase, so leaving the
strings creates an inconsistency inside one file; (ii) these are `#eval` diagnostic banners with no
programmatic consumer (no test asserts on the text), so the blast radius is a developer-visible
message only; (iii) leaving them means the Phase 8 repo-wide `Theories/` recount = 0 goal cannot be
met and the proposed PreToolUse hook would flag this file forever. The counter-argument for leaving
them is strictly scope discipline, not risk. Either way Phase 8 must state the outcome explicitly —
these must not silently become a permanent exemption.

The 2 remaining NON-COMMENT matches from Phase 1's counts.md (`IO.println` banners in
`Automation/`) land in **Phase 7's** territory and need the same treatment decision.

## Carried-Forward Awareness for Phase 7

- **Sorry-line DEFERRED residuals (do NOT touch)** now number **10** across Phases 3-6 territory —
  the 8 recorded at Phase 5 plus **2 NEW** in Phase 6's territory:
  - `NfMultiAnchorBridge/Base.lean`: :971, :1054, :1077, :1175, :1761
  - `NfMultiAnchorBridge/InteriorGateGeneralK.lean`: :1044
  - `NfMultiAnchorBridge/SubBracket2V.lean`: :2104
  - `NfMultiAnchorBridge/CarrierK1V.lean`: :79
  - **NEW** `WeakCanonical/Transfer.lean`: :1179 (`… is now sorry-free (task 155, plan v52).`)
  - **NEW** `WeakCanonical/Transfer.lean`: :1274 (`-- Replaced with direct sorry (task 255). …`)

  These are part of the 14 global sorry-line deferrals in `worklists/counts.md` and constitute the
  documented recount floor, NOT a per-file miss. Phase 7 will meet the remaining ~4 of the same
  class (2 already identified in Boneyard: `NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean:102`
  and `NfMultiAnchorBridgeRetired/Lemma32Reduction.lean:15`). Leave every sorry-line untouched and
  record it.
- **`SharedWitness.lean` still has 2 `specs/321_…` path citations** (`:9`, `:10`) — Phase 3's
  exclusive territory, still untouched. Phase 8's specs-path = 0 check fails on them unless Phase 8
  runs the sanctioned micro-repeat of Phase 3's rules. **Still a Phase 8 item, not Phase 7.**
- **Case sensitivity matters for the sorry guard**: the script's guard is the lowercase substring
  `'sorry' in line`, so prose using capital `SORRY` / `Sorry-free` does NOT trip it. Two such lines
  were legitimately edited in Phase 6 (`ChronicleToCountermodel.lean` ~:167 under a `**Status**:
  SORRY` banner, `NfDepth0Generalized.lean` :309 under `Sorry-free/axiom-free assets`). Neither
  changed any `sorry` token and the census stayed exact — but Phase 7 should apply the same care in
  the Boneyard, where capitalised sorry-prose is common.
- **Bare numbers / non-matching artifact paths left in place** (the Phase-3/4/5 convention): only
  ones *contiguous to an edited token in the same comment fold* were cleaned (4 this phase — see
  the plan's Phase 6 deviation 3). Isolated ones stay.

## Key Decisions / Style Precedents Applied

Durable-anchor vocabulary, extended from the Phase 4-5 tables:

| Ephemeral pointer | Durable anchor used |
|---|---|
| task 113 | "the open-guard refactor" (the named refactor itself) |
| task 343 | "the runtime-only cancellable `IO` mirror" / `CancellableExpansion.lean` decl names |
| task 298 | "global branch counter limit" (prefix dropped — the feature names itself) |
| task 290 | "proportional fuel allocation" (likewise) |
| task 261 / 261 v3 | "eventuality-aware blocking" / "box-valid fast path" (likewise) |
| task 237 (WIP) | "refinement still pending" |
| task 164 round 5 | attribution dropped; the FALSE finding kept |
| task 277 | `tableau_rule_firing_traces` / `_tracedImpl` precedent (Saturation.lean:368) |
| task 264 | attribution dropped; the c3-c8 bimodal finding kept |
| task 191 | "the propositional decision procedure" / "this module's niche" |
| task 155 plan Phase N (EFGames) | bullet deleted — the sibling GHR93 citation is the anchor |
| task 155 handoff §5 | the d-consistency restructure, restated inline |
| task 98 Phase N | file-local `Phase N` designator kept, task token dropped |
| task 99 | "the BXPoint-backed strengthening" (its own subject, already named in-fold) |
| task 101 | "`sigma_strict`" → corrected to `Boneyard/FiltrationOrdering/SigmaOrdering.lean` |
| task 102 / 102 v5 | "chain-member quantification" / "the chain-member guard (v5)" |
| task 107 | file-local `Phase 3` / `Phase 5` designators kept |
| task 115 | "the Xu 1988 Lemma 3.2.2 approach" (named in the same sentence) |
| task 122 | dropped; "Until/Since coherence on ℤ" is the durable subject |
| task 129 | "the Henkin-model route" / "the chronicle → Reynolds completeness route" |
| task 143 / 145 / 154 | "the Doets Lemma 1.1 NormalForm/KType redesign" / "the NEquivalence split" |
| task 268 | "the strategy-B route for the Reynolds pipeline bridge" |
| task 305 | "the v35 Phase 1 pass" / "Route A′ (the revised zone-split …)" |
| task 306 / 326 / 350 | `VecEAClosure.lean` / `List.mem_permutations` / file-local `Phase N` |
| task 307 / 308 | "the bound-anchor zone converter" / "deliverable 2" |
| task 309 / 310 / 311 | "the k=1 gate" / "the E[Σ]-fold encoding" / "the downstream RHS discharge" |
| task 327 NO-GO | "the arity-1 NO-GO" |
| task 348 / 349 | file-local `Phase N` designators kept, task token dropped |
| task 977/978/982 | "the earlier fixed-domain completeness attempts" |
| `specs/NNN_…` plan or report path | a design-provenance statement naming the design, no path |

**New convention established this phase (recommend Phase 7 follow it)**: a References-section
bullet whose ENTIRE content is a plan/task/report pointer, sitting directly beneath a durable
literature citation (GHR93 / Burgess / Goldblatt / Doets / Reynolds), is **deleted** — the sibling
citation is the durable anchor and there is no other substance to preserve. This is the
Phase-4 precedent (the two `specs/357_…` bullets deleted after restating content) applied at scale:
13 such bullets across EFGames / Expressiveness / StaviConnectives / DefectChain /
OrderedSeedConsistency / PointInsertion. Bullets that DID carry independent content were restated
inline instead, never deleted.

Section headings were disambiguated by content, never deleted or duplicated (Settled decision 6);
where a heading already led with its own `Phase N` designator, the trailing `(task NNN, Phase N)`
parenthetical was dropped whole rather than duplicating the designator. Internal cross-references
citing `:line` anchors were left byte-identical so they still resolve.

## Sorry Inventory

Empty. No sorry introduced, none resolved, no sorry-line touched (906/820/26 invariant exact).

## Deferred

1. The 10 sorry-line residuals listed above (never-touch-sorry-lines guard).
2. The 4 NON-COMMENT string literals in `Saturation.lean` (full table + recommendation above) —
   requires a supervised human decision.
3. `SharedWitness.lean`'s 2 `specs/321_…` citations (Phase 3 territory — Phase 8 item).

All 144 worklist entries handled.
