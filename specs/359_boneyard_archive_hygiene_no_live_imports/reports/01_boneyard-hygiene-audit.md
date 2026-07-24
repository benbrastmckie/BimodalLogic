# Research Report: Boneyard Archive Hygiene — No Live Imports (Task 359)

- **Task**: 359 `boneyard_archive_hygiene_no_live_imports`
- **Session**: sess_1784886673_059c3f_359
- **Agent**: lean-research-hard-agent (H2/H3/H4 active; H5 not triggered — no `focus_prompt`, no churn history: this is the task's first research round)
- **Date**: 2026-07-24
- **Reference grounding tier**: Tier 3 (implementation-backed — grounded in fresh greps over the current tree, the lakefile, `lean_verify`, task-385 artifacts, and `specs/reviews/review-2026-07-24-metalogic-cleanup.md` treated as a hypothesis list, not as evidence)
- **Literature (`--lit`)**: briefing loaded (12 docs, Kamp/Rabinovich expressive-completeness corpus). **Not load-bearing for this repo-hygiene task.** Only tangential relevance: the two EANegation theorems slated for retirement carry Rabinovich-2014 provenance labels ("Lemma 5.1", "Corollary 5.4") in their docstrings, which the retirement spec below preserves verbatim with the archived code.

## Executive Summary

All charter obligations were recomputed against the current tree (post-385, HEAD f67b72c89):

1. **NO LIVE IMPORTS INVARIANT: already holds — the promotion list is EMPTY.** Fresh greps (3 patterns, `Theories/` + `Tests/`, both Boneyards) find **zero** import lines referencing any Boneyard module from outside a `Boneyard/` directory. The charter's "~3 remaining live imports (via Prop43 and NavigatedEndChar)" is stale: task 385 archived both importers into `Kamp/Boneyard/`. No declaration needs promotion out of either Boneyard.
2. **Dead-inline-code archival**: the chartered items are fully specified below — the CarrierK1V `endInterval` skeleton (4 decls, lines 2144–2216, zero live consumers) and the EANegation sorried pair plus its 3-decl dead support closure. An extended Tier-2 sweep (~16 more dead sorried decls in 7 live files, from review §2.1) is included with destinations; each requires a per-decl consumer re-grep at implementation time.
3. **Boneyard tidy**: fresh census — top-level Boneyard 83 `.lean` files (19 `#exit`-before-imports, 24 after-imports, 40 none), Kamp Boneyard 60 files (zero `#exit`). Header + `#exit` normalization policy specified below. The top-level README's inventory total (67 files / ~39,619 lines) disagrees with the measured 83 files; 9 subdirectories contain only a README (tombstones). Reconciliation is a tidy work item.
4. **Build-participation**: `lakefile.lean` has only `lean_lib Bimodal` and `lean_lib BimodalTest` (no globs → root-module closure only); no target covers either Boneyard. No surprises.
5. **Axiom baseline** (gate for the implementer): `Bimodal.Metalogic.BXCanonical.completeness_discrete` axioms = `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`, no `sorryAx` (measured via `lean_verify` this session). Must be byte-identical after implementation.

Division-of-labor constraint honored (task-385 report §"Division of Labor"): this plan works at **declaration level inside live files** plus Boneyard-internal tidying; it moves no whole files, and none of the files 385 moved are touched.

## Findings

### (a) Live-import inventory and promotion spec — EMPTY

Fresh evidence (this session, current tree):

| Grep pattern | Scope | Hits outside `Boneyard/` dirs |
|---|---|---|
| `import.*Kamp\.Boneyard` | `Theories/`, `Tests/` | **0** |
| `import Bimodal\.Boneyard` | `Theories/`, `Tests/` | **0** |
| `^import.*Boneyard` | `Theories/`, `Tests/` | **0** |

Therefore: **no declarations to promote**; charter part (1) is closed by verification alone. Boneyard files importing *live* modules exist (e.g. `Kamp/Boneyard/EndpointNegation.lean:1` imports live `Kamp.EANegation`) — that direction is permitted and harmless (Boneyard is never compiled).

### (b) Dead-inline-code archival list with destinations

Destination shorthand: **KB** = `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/`, **TB** = `Theories/Bimodal/Boneyard/`.

#### Tier 1 — chartered, fully verified this session (MANDATORY)

**B1. CarrierK1V `endInterval` skeleton** (file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean`, 2216 lines total; the dead block is the file tail, :2144–:2216):

| Decl | Line | Status |
|---|---|---|
| `endIntervalStep` | :2144 | The `⟨[]⟩` empty-disjunction placeholder; superseded by `endIntervalStepPrior` (`EndIntervalConsumerK.lean:55`) |
| `endInterval` | :2159 | Recursion skeleton over the placeholder; sole in-file consumer of `endIntervalStep` (:2166) |
| `EndIntervalCorrect` | :2179 | Frozen correctness statement over the dead skeleton |
| `endInterval_zero_correct` | :2199 | k=0 instance of the dead statement; zero references anywhere |

- **Consumer verification**: repo-wide grep for `endIntervalStep` / `endInterval` / `EndIntervalCorrect` outside CarrierK1V yields **comment/docstring mentions only** (`Base.lean:989,:1005-1006` — which itself states "`EndIntervalCorrect` is superseded dead code"; `InteriorGateGeneralK.lean:18,:59`; `EndIntervalConsumerK.lean:8,:14,:49,:323` — ":323 … is NOT on" the live path). Zero code consumers.
- **NOT dead / keep in place**: `VVecEA2.singleton` (:2122) and `VVecEA2.singleton_holds` (:2128) — consumed by live `EndIntervalConsumerK.lean` (:78,:230-231,:332).
- **Destination**: new file `KB/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean` (fits the existing retired-escalation-path subdirectory). Carry the Phase-framing doc block (~:2100–:2143) with it; leave a 3–5 line breadcrumb comment at the excision site in CarrierK1V pointing to the Boneyard file and to `EndIntervalConsumerK.endIntervalPrior` as the live replacement. Update the stale prose in `InteriorGateGeneralK.lean:18` ("can fill the `endIntervalStep` body") to reference the consumer-side reshape instead.
- **Build risk**: zero — the block is the file tail with no downstream in-file references (verified: no `endInterval`/`EndIntervalCorrect` mention after :2215).

**B2. EANegation sorried-orphan pair + dead support closure** (file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean`, 1251 lines — note: under `Kamp/`, not directly under `WeakCanonical/` as the charter path suggests):

Removal set (all verified zero consumers outside the removal set itself, this session):

| Decl | Lines (approx span) | Sorries | Why it goes |
|---|---|---|---|
| `neg_bracket_is_vbracket` | :820 (docstring) – :1120 | 1 (`:1090`) | Chartered orphan; unprovable as stated (B.1 beta_0(r0) sub-case); superseded by sorry-free `VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean:177`, 9 live consumer files) and by model-dependent `neg_interval_formula` in `EANegationClosure.lean` |
| `neg_partialBracketExist_is_vbracket` | :1118 (docstring) – :1251 (EOF) | 1 (`:1249`) | Chartered orphan; same supersession |
| `neg_bracket_zero_is_vbracket` | :770 | 0 | Sole consumer is `neg_bracket_is_vbracket:845` — dead after excision |
| `neg_partialBracketExist_sufficient` | :725 | 0 | Sole consumer is `neg_partialBracketExist_is_vbracket:1213` — dead after excision |
| `BracketFormula.partialBracketExist` | :573 | 0 | Consumers are only the two rows above — dead after excision |

- **Zero-consumer evidence**: repo-wide grep (`Theories/`, `Tests/`, `docs/`, `.lean`+`.md`+`.typ`) for both theorem names excluding the defining file: **0 hits**. For the 3 support decls: 0 external files; in-file consumers enumerated above are all inside the removal set.
- **KEEP (live, do not touch)**: `fChainFrom`, `fChainPred`, `fChainFrom_base`, `fChainFrom_step`, `bracket_implies_fChainPred`, `BracketFormula.prepend`, `prepend_holds`, `prepend_holds_inv`, `orderedPointsExist`, `orderedPointsExist_decompose`, `VBracketFormula.prependAll`, `neg_orderedPointsExist_is_vbracket`, `IntervalPattern.allBetaTrue`, `BracketFormula.allTrue` — each has 1–8 external consumer files (measured).
- **Impossibility-note preservation (charter requirement)**: the inline impossibility comment at **:1047–:1090** (inside `neg_bracket_is_vbracket`: "This sorry is UNPROVABLE at the BracketFormula level…") and the two docstrings (:820–:833 "Lemma 5.1 (Rabinovich 2014, pp.7-11)… Sorry status… Does NOT block completeness"; :1118–:1128 "Corollary 5.4… F-chain Until-unboundedness issue") MUST move verbatim with the archived code so the refutation is not lost.
- **Destination**: new file `KB/EANegationVBracketBackward.lean` (flat in Kamp Boneyard; it is Kamp-pipeline Section-5 material). Header states: retired because the backward direction is unprovable at the `BracketFormula` level; superseded by `VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean`) and the model-dependent closure lemmas in `EANegationClosure.lean`; keep the Rabinovich labels.
- **Side benefit**: `EANegation.lean` becomes **sorry-free** (its only 2 sorry tokens are :1090 and :1249). Update its module docstring accordingly and add a short breadcrumb note pointing to the Boneyard file.
- **Importers of `EANegation.lean`** (unchanged by the excision): `EANegationFix/OnBuilder.lean:2`, `EANegationClosure.lean:1` (live), `KB/EndpointNegation.lean:1` (archived). Neither live importer references any removed decl (covered by the zero-consumer greps).

**B3. Optional micro-tier (same file, recommend including)**: the sorry-free warm-up trio `neg_orderedPointsExist_zero_false` (:74, zero references anywhere), `neg_orderedPointsExist_one` (:82) + `neg_orderedPointsExist_one_is_bracket` (:106) (a dead pair: `_one`'s only consumer is `_one_is_bracket:111`, which has zero consumers). Archive into the same `EANegationVBracketBackward.lean` or leave as pedagogical warm-ups — planner's choice; zero build risk either way.

#### Tier 2 — extended dead-sorried-decl sweep (from review §2.1; spot-verified sample this session; implementer MUST re-run a per-decl consumer grep immediately before each excision)

| Source file (live) | Decls (sorry lines) | Fresh spot-check | Destination |
|---|---|---|---|
| `WeakCanonical/OrderedSum.lean` | `doets_lemma_1_5` (:57) | Verified this session: only non-def mentions are the file's own docstring (:11,:15); `doets_lemma_1_4` in same file IS live — keep it | TB, new `SorriedDeclExcisions/OrderedSumDoets15.lean` |
| `BXCanonical/Frame.lean` | `bx_le_refl` (:205) | Verified this session: only non-def mention is the file's own header (:22) | TB `SorriedDeclExcisions/` |
| `WeakCanonical/TruthLemma.lean` | `truth_lemma` (:540,:556), `until_backward_mcs`, `since_forward_mcs`, `since_backward_mcs`, +1 (5 decls) | Review-verified (BXCanonical same-name hits are shadowing, not consumption); re-grep required | TB `SorriedDeclExcisions/` |
| `WeakCanonical/EFGames/StaviCompleteness.lean` | `nf_2var_existential_transfer`, `nf_exist_sf_guarded_backward` | Fresh grep: 2–3 live mentions each, def + docstring only | TB `StaviDiscretePath/` (existing thematic subdir) |
| `WeakCanonical/Expressiveness/CaseAnalysis.lean` | `ghr93_cases_III_IV` (6 sorries) | Fresh grep: def + 1 doc mention; `ghr93_case_I`/`_II` in same file ARE live (`Transfer.lean:833,:841`) — keep them | TB `SorriedDeclExcisions/` |
| `BXCanonical/Chronicle/ChronicleToCountermodel.lean` | `chronicle_gap_contradiction` (4 sorries), `succ_reaches_dom_N` (2 sorries) | Fresh grep shows 14/5 mentions — mostly same-file + comments per review (`Completeness.lean:364` declares them dead); **most re-grep-sensitive rows, verify carefully** | TB `BXPipelineDeadCode/` or `DeadChronicleGapElimination/` (existing subdirs) |
| `Bundle/SuccExistence.lean` | 3 sorried seed-consistency decls (:446,:749,:823) | Review-verified 0 consumers; re-grep required | TB `SorriedDeclExcisions/` |
| `Bundle/UntilSinceCoherence.lean` | `backward_until_reflexive` (:85), `backward_since_reflexive` (:96) | Fresh grep: def + doc mentions only | TB `SorriedDeclExcisions/` |

**MUST NOT touch** (verified KEEP rows): `WeakCanonical/Transfer.lean:countermodel_discrete` (:1277) — the only load-bearing sorry in Metalogic, consumed by general `completeness` (`BXCanonical/Completeness.lean:165`); `Bundle/SuccRelation.lean` (7 sorries) — `until/since_unfold_in_mcs` is consumed by live `Bundle/TemporalCoherence.lean`; review routes its audit elsewhere.

**Explicitly out of scope (recommend defer)**: Fin/non-Fin twin consolidation (`efSat`/`efSatFin`, `veeSat`/`veeSatFin`, `intervalHolds`/`intervalHoldsFin` — review §2.3 "Drift-Register #7") — the non-Fin totals still carry live consumers (k=0/k=1 legacy arms); consolidation is live-code refactoring, not dead-code archival, and the review itself warns it "should NOT be done casually". Same for the per-k `kampPrior_case1_arm_k0`/`_k1` arms (live at `KampPrior.lean:491-492`).

### (c) Boneyard tidy spec

**Fresh census (this session, post-385 tree)**:

| Boneyard | `.lean` files | `#exit` before imports | `#exit` after imports | no `#exit` |
|---|---|---|---|---|
| TB `Theories/Bimodal/Boneyard/` | 83 | 19 | 24 | 40 |
| KB `Kamp/Boneyard/` | 60 | 0 | 0 | 60 |

**Header convention (proposed)**: every Boneyard `.lean` file starts with a module docstring whose first line marks archival status, e.g.:

```
/-!
ARCHIVED (Boneyard) — never compiled. <one-line reason: superseded by X / retired path Y>.
See <Boneyard README> for the inventory entry. Do not import from live code.
-/
```

Files that already have informative headers keep their content; the sweep only ensures the `ARCHIVED (Boneyard)` first line is present.

**`#exit` normalization policy (proposed)**: uniform placement **immediately after the import block** (before the first declaration) in all 143 files.
- Rationale for after-imports (not before): `import` must lexically precede all commands in Lean 4, so `#exit` before imports is a header syntax error in the 19 TB files that have it — harmless in never-built files but wrong as a convention; after-imports is syntactically valid and still guarantees that any accidental `import` of a Boneyard module or direct `lake build Bimodal.Boneyard.X` elaborates zero declarations, producing a loud downstream failure instead of silently compiling archived proofs. This is defense-in-depth on top of the never-built policy (which alone already keeps them out of `lake build`).
- Work: add `#exit` to 100 files (40 TB + 60 KB), relocate it in 19 TB files. Mechanical/scriptable; no semantic content changes; imports (including stale ones) are NOT repaired, per the standing policy in both READMEs ("stale imports in never-built code are cosmetic").

**README/inventory reconciliation**:
- TB `README.md:67` claims **Total 67 files / ~39,619 lines**; measured: **83 `.lean` files**. Recount and fix the inventory table (per-subdir measured counts are in this session's transcript; e.g. `ChainCompleteness/` 12, `KampBypassArchive/` 13, `StrictSemanticsLegacy/` 9).
- **9 TB subdirectories contain only a `README.md`** (tombstones — code deleted historically): `BundleTemporalCoherence/`, `BX1DependentCode/`, `ClosedGuardLegacy/`, `NonBurgessSeed/`, `OpenGuardInvalid/`, `StageInductionGapAnalysis/`, `TAxiomDependentCode/`, `UltrafilterDeadCode/`, `XuLemma321Legacy/`. Tidy action: mark each tombstone README's first line as "TOMBSTONE — code deleted; README retained as historical record" (do NOT delete, per the permanent-archive charter), and list them in a Tombstones section of the top README.
- KB `README.md` (created by 385) already states the never-built policy; extend its inventory with the new files this task creates (`EANegationVBracketBackward.lean`, `NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean`, and any Tier-2 KB additions — none currently).
- **Build participation**: `lakefile.lean` contains exactly `lean_lib Bimodal` (:19) and `lean_lib BimodalTest` (:24), no `globs`, no Boneyard mention (verified) — default-glob root-closure semantics; nothing to change.

### (d) EANegation retirement spec

Covered in full under (b) Tier 1 item B2 — removal set, keep set, impossibility-note preservation (:1047–:1090 + both docstrings), destination file, and the sorry-free side effect. Executable without re-research; the only implementation-time checks are (i) `lake build` green after the excision and (ii) the axiom-baseline gate below.

### (e) Definition-of-done gates for the implementer

1. `grep -rn "^import.*Boneyard" Theories/ Tests/ --include="*.lean" | grep -v "/Boneyard/"` → empty (holds today; must still hold).
2. Full-tree `lake build` (and `lake build BimodalTest`) green.
3. `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_discrete` (`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:242`) returns exactly `["propext","Classical.choice","Lean.ofReduceBool","Lean.trustCompiler","Quot.sound"]`, no warnings — measured baseline this session. (The `Lean.ofReduceBool`/`Lean.trustCompiler` entries are the known `native_decide` caveat noted in the task annotations; they are part of the baseline, not a regression.)
4. No whole-file moves of 385-moved files; no edits to `Transfer.lean:countermodel_discrete` or `Bundle/SuccRelation.lean`.
5. Boneyard contents never deleted (tombstone READMEs and all archived code retained).

## Literature Proof Structure

Not applicable — Tier 3 task (repo hygiene). The Rabinovich-2014 provenance labels on the retired theorems are preserved textually with the archived code; no mathematical claims from the literature are load-bearing.

## Tactic Survey Results

Not applicable — no proof construction in scope. Lean-tool work was `lean_verify` (axiom baseline) only; all other evidence is grep/filesystem/lakefile-based, which is the appropriate toolset for an import-graph and dead-code audit.

## Adversarial Self-Verification

Contract check: no forbidden outputs ("mathlib likely has X" — no Mathlib claims made; no sorry-deferral or axiom-introduction recommendations — the spec *removes* 2 sorries from the live tree and the axiom baseline is frozen). Verified-evidence bar met within the first tool calls (fresh greps + task-385 artifacts).

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| Zero live imports into either Boneyard (promotion list empty) | 3 grep patterns over `Theories/`+`Tests/`, all 0 hits outside `Boneyard/` dirs | fresh grep this session (not inherited from 385/review) | High |
| Charter's "~3 live imports via Prop43/NavigatedEndChar" is stale | Both importers now at `KB/Prop43.lean`, `KB/NfMultiAnchorBridgeRetired/NavigatedEndChar.lean` (385 phase 2, commit 835ab8272) | fresh grep + 385 summary cross-check | High |
| `neg_bracket_is_vbracket` (:834, sorry :1090) and `neg_partialBracketExist_is_vbracket` (:1129, sorry :1249) exist with exactly those sorries; file has no other sorry tokens | grep of today's `Kamp/EANegation.lean` (note: charter's path `WeakCanonical/EANegation.lean` is wrong — file is under `Kamp/`) | fresh grep against today's file | High |
| Both theorems have zero consumers repo-wide | grep over `Theories/`, `Tests/`, `docs/` (`.lean`/`.md`/`.typ`) excluding the defining file: 0 hits | fresh grep | High |
| Support closure `partialBracketExist`, `neg_partialBracketExist_sufficient`, `neg_bracket_zero_is_vbracket` becomes dead after the excision; `fChainFrom` family stays live | per-decl external-file counts (0/0/0 vs 3–8 external files for the keep set) + in-file reference line map | fresh per-decl grep loop | High |
| Superseding lemma `VVecEA2.negFix_iff` is sorry-free and live | `EANegationFix/VecEANegFix.lean:177`; no sorry token in file; 9 external consumer files incl. `DedekindINF.lean`, `Section5Correspondence.lean` | fresh grep (sorry scan + consumer list) | High |
| `endIntervalStep`/`endInterval`/`EndIntervalCorrect`/`endInterval_zero_correct` (CarrierK1V :2144–:2216, file tail) have zero code consumers; all external mentions are docs/comments, incl. `Base.lean:1006` calling it "superseded dead code" | grep inside + outside CarrierK1V; no mentions after :2215 in-file | fresh grep | High |
| `VVecEA2.singleton`/`singleton_holds` must NOT move (counterexample to a naive "move the whole tail block from :2122") | live uses in `EndIntervalConsumerK.lean:78,:230-231,:332` | fresh grep | High |
| `completeness_discrete` axiom baseline = `propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound`, no sorryAx | `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_discrete` (namespace read from `Completeness.lean`) | lean_verify-confirmed (domain method) | High |
| Boneyard census: TB 83 files (19/24/40 exit-before/after/none), KB 60 files (0 `#exit`) | scripted per-file first-`#exit`-vs-first-`import` classification | scripted recomputation | High |
| TB README total (67 files) is wrong vs tree (83); 9 subdirs are README-only tombstones | `README.md:67` vs `find` count; `ls` of 3 sample tombstone dirs | fresh count + directory listing | High |
| No lakefile target builds either Boneyard | `lakefile.lean` grep: only `lean_lib Bimodal`/`BimodalTest`, no globs, no Boneyard | lakefile read | High |
| Tier-2 rows `doets_lemma_1_5`, `bx_le_refl`, `ghr93_cases_III_IV`, `backward_until/since_reflexive`, StaviCompleteness pair have no live code consumers | fresh grep: only defs + same-file docstring mentions (e.g. `OrderedSum.lean:11,:15`; `Frame.lean:22`) | fresh spot-check grep | High |
| Remaining Tier-2 rows (TruthLemma 5 decls, ChronicleToCountermodel, SuccExistence) are dead | review §2.1 consumer analysis (shadowing/comment classification not independently re-derived here) | review-verified only; per-decl re-grep mandated at implementation time | Medium |
| `#exit` before imports is a Lean 4 header syntax error (basis for after-imports placement) | Lean 4 module grammar: `import` header must precede commands | language-knowledge claim, not machine-checked in this repo (files are never compiled, so it has zero build impact either way) | Medium |

### Contradiction Log

1. **Task-359 charter ("~3 remaining live imports into Boneyard") vs fresh grep (zero).** Precedence: direct tool observation over charter prose. The charter predates task 385, which archived both importing files. RESOLVED — promotion scope is empty; the charter's own instruction ("verify the exact current set with a fresh grep") anticipated this.
2. **Charter path "WeakCanonical/EANegation.lean" vs actual `WeakCanonical/Kamp/EANegation.lean`.** Filesystem outranks charter text. RESOLVED — spec uses the real path.
3. **TB `README.md` inventory (67 files / ~39,619 lines, written by 385 phase 4) vs measured 83 `.lean` files.** Direct count outranks the README. RESOLVED as a work item, not a blocker: the README undercounts (plausibly omitting pre-existing subdir contents from its totals row); tidy spec includes recount + tombstone-section fix.
4. **385-report claim "only 14/73 TB files have `#exit` before imports" vs this session's 19/83.** Both are point-in-time measurements of different trees (pre- vs post-385 moves). No conflict; the fresh numbers govern the tidy spec.

### Recommendations modified after verification

- Naive charter reading "promote Prop43/NavigatedEndChar declarations" dropped entirely — nothing to promote (fresh grep).
- The `endIntervalStep` archival was widened to the 4-decl tail block (:2144–:2216) and explicitly *narrowed* to exclude `VVecEA2.singleton`/`singleton_holds` after finding live consumers.
- The EANegation excision was widened from the chartered 2 theorems to a 5-decl closure (3 support decls become dead), avoiding leaving fresh orphans behind — the exact defect class this hygiene task exists to remove.
- `#exit` normalization changed from "match the existing before-imports pattern" to after-imports placement after recognizing the before-imports form is a header syntax error.

## Memory Candidates

1. **Pattern (lean4/repo-hygiene)**: when excising a dead declaration, compute its in-file dead *closure* first (support lemmas whose only consumers are the excised decl) — otherwise the excision manufactures new zero-consumer orphans; a per-decl external-file count plus an in-file reference line map is sufficient evidence.
2. **Fact (this repo)**: `completeness_discrete` axiom baseline is `propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound` (native_decide accounts for the two `Lean.*` entries); any Metalogic hygiene change must leave this list byte-identical.
3. **Pattern (lean4)**: `#exit` placed after the import block (never before — that is a header syntax error) makes an archived module export zero declarations if accidentally imported, a cheap defense-in-depth on top of a never-built Boneyard policy.
