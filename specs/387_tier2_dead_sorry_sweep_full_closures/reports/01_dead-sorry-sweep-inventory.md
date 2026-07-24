# Research Report: Tier-2 Dead-Sorry Sweep — Verified Excision Inventory

- **Task**: 387 `tier2_dead_sorry_sweep_full_closures`
- **Session**: sess_1784905408_b56b5c
- **Agent**: lean-research-hard-agent (H2/H3/H4 contracts active)
- **Date**: 2026-07-24
- **Reference grounding tier**: Tier 3 (implementation-backed — every deadness claim re-verified
  by fresh repo-wide `grep` this session; the archived audit
  `specs/archive/359_boneyard_archive_hygiene_no_live_imports/reports/01_boneyard-hygiene-audit.md`
  and `specs/reviews/review-2026-07-24-post-cleanup.md` were treated as hypothesis lists, not
  evidence)

## Summary

Fresh consumer greps across `Theories/` and `Tests/` (Boneyard excluded) verify **7 excision
groups** and **demote 2 rows**. The ghr93 chain (a) is confirmed dead as the review specified,
with one addition: `gap_cut_exists_gt` would be freshly orphaned and must join the closure, and
`Theorem6.lean` is left with **zero declarations** after excision. The Algebraic pair (b) is
confirmed dead with a 5-declaration closure. Of the Tier-2 archived-audit rows (c): OrderedSum,
Frame, TruthLemma (enlarged closure), StaviCompleteness (substantially enlarged closure, 16
decls), UntilSinceCoherence (enlarged, whole 6-decl file), and `succ_reaches_dom_N` are
verified excisable; the `chronicle_gap_contradiction`/`succ_cofinal` pair is **DEMOTED TO
KEEP** (live compile chain into `succ_embed_surjective`, contradicting the file's own header),
and the SuccExistence 3-decl row is **DEMOTED TO SKIP** (the three sorried decls have long
in-file consumer chains; only whole-file archival would be safe, which exceeds this sweep's
scope). Axiom baseline captured by `lean_verify`: exactly
`[propext, Classical.choice, Quot.sound]`.

## Findings

### 1. Verified excision inventory table

Consumer counts are **code consumers** (definition lines, docstrings, and `--`/`/- -/` comment
mentions excluded), from fresh whole-repo greps this session. Anchor by declaration name; line
numbers below are current as of this session and will rot.

| Declaration | File | Current line anchor | Consumers found (fresh grep) | Verdict |
|---|---|---|---|---|
| `ghr93_cases_III_IV` (private, 7 sorries) | `WeakCanonical/Expressiveness/CaseAnalysis.lean` | :2162 | 1 — `CaseAnalysis.lean:3647`, inside `ghr93_cases_II_III_IV` | **excise** (in closure) |
| `ghr93_cases_II_III_IV` (private) | `CaseAnalysis.lean` | :3604 | 1 — `:3745`, inside `ghr93_inductive_step` | **excise** (in closure) |
| `ghr93_inductive_step` | `CaseAnalysis.lean` | :3660 | 2 — `Theorem6.lean:124` (inside `_core`), `:413` (inside `_rank_varying`); Transfer.lean hits are comments or the distinct decl `ghr93_inductive_step_discrete` (:760, live) | **excise** (in closure) |
| `ghr93_forward_to_backward_core` (private) | `WeakCanonical/Expressiveness/Theorem6.lean` | :54 | 1 — `Theorem6.lean:178`, inside `ghr93_forward_to_backward` | **excise** (in closure) |
| `ghr93_forward_to_backward` | `Theorem6.lean` | :160 | 0 (word-boundary grep; only own def + docstring mention `CaseAnalysis.lean:3655`) | **excise** |
| `ghr93_forward_to_backward_rank_varying` | `Theorem6.lean` | :207 | 0 (only own def) | **excise** |
| `gap_cut_exists_gt` (private, sorry-free) | `CaseAnalysis.lean` | :18 | 2 — `:2384`, `:3082`, both inside `ghr93_cases_III_IV` | **excise** (would be freshly orphaned — MUST join closure) |
| `G_monotone` (1 sorry :83) | `Algebraic/InteriorOperators.lean` | :73 | 0 (comment mentions :35, :180 only) | **excise** |
| `provEquiv_all_future_congr` (2 sorries :177,:182) | `Algebraic/LindenbaumQuotient.lean` | :169 | 1 — `:316`, inside `G_quot` | **excise** (in closure) |
| `G_quot` | `LindenbaumQuotient.lean` | :314 | 3 — `G_monotone` (dead), `sigma_quot_G_H` (:411), `sigma_quot_H_G` (:422,:425), all dead | **excise** (in closure) |
| `sigma_quot_G_H` (sorry-free) | `LindenbaumQuotient.lean` | :410 | 0 | **excise** (in closure) |
| `sigma_quot_H_G` (sorry-free) | `LindenbaumQuotient.lean` | :421 | 0 | **excise** (in closure) |
| `doets_lemma_1_5` (1 sorry :57) | `WeakCanonical/OrderedSum.lean` | :51 | 0 (docstring :11,:15 only; `doets_lemma_1_4` :34 is separately live — GoodStructures.lean — KEEP it) | **excise** |
| `bx_le_refl` (1 sorry :205) | `BXCanonical/Frame.lean` | :202 | 0 (header :22 only) | **excise** |
| `truth_lemma` (2 sorries :540,:556) | `WeakCanonical/TruthLemma.lean` | :510 | 0 repo-wide (not even comment hits outside its file) | **excise** (closure below) |
| `until_forward_mcs` (1 sorry :431) | `TruthLemma.lean` | :402 | 1 — `:543`, inside `truth_lemma` | **excise** (in closure) |
| `until_backward_mcs` (1 sorry :448) | `TruthLemma.lean` | :444 | 0 | **excise** |
| `since_forward_mcs` (1 sorry :483) | `TruthLemma.lean` | :456 | 1 — `:559`, inside `truth_lemma` | **excise** (in closure) |
| `since_backward_mcs` (1 sorry :497) | `TruthLemma.lean` | :493 | 0 | **excise** |
| `nf_2var_existential_transfer` (2 sorries :2428,:2510) | `WeakCanonical/EFGames/StaviCompleteness.lean` | :2289 | 1 — `:2594`, inside `nf_2var_from_interval_data` | **excise** (in enlarged closure, section 4) |
| `nf_exist_sf_guarded_backward` (1 sorry :2884) | `StaviCompleteness.lean` | :2856 | 1 — `:2909`, inside `nf_2var_exist_sf_classical` | **excise** (in enlarged closure, section 4) |
| `succ_reaches_dom_N` (private, 2 sorries :221,:377) | `BXCanonical/Chronicle/ChronicleToCountermodel.lean` | :83 | 0 (comment mentions :64,:218,:374,:484 only) | **excise** (first decl in file; orphans nothing) |
| `chronicle_gap_contradiction` (private, 4 sorries :513,:527,:768,:788) | `ChronicleToCountermodel.lean` | :505 | 1 — `:807`, inside `succ_cofinal` (LIVE chain, section 5) | **KEEP — demoted** |
| `succ_cofinal` (private) | `ChronicleToCountermodel.lean` | :800 | 1 — `:830`, inside `limitDomSubtype_isSuccArchimedean` (LIVE chain) | **KEEP — demoted** |
| `constrained_successor_seed_consistent` (1 sorry :446) | `Bundle/SuccExistence.lean` | :436 | 1 — `:497`, inside `constrained_successor_from_seed` (chain of 7 more in-file) | **SKIP — demoted** (section 6) |
| `successor_deferral_seed_consistent_axiom` (1 sorry :749) | `SuccExistence.lean` | :742 | 1 — `:789`, inside `successor_deferral_seed_consistent` (chain of 8 more) | **SKIP — demoted** |
| `predecessor_deferral_seed_consistent_axiom` (1 sorry :823) | `SuccExistence.lean` | :816 | 1 — `:872`, inside `predecessor_deferral_seed_consistent` (chain of 10 more) | **SKIP — demoted** |
| `backward_until_reflexive` (1 sorry :85) | `Bundle/UntilSinceCoherence.lean` | :81 | 1 — `:132`, inside `backward_until_from_step` | **excise** (whole-file closure, section 7) |
| `backward_since_reflexive` (1 sorry :96) | `UntilSinceCoherence.lean` | :92 | 1 — `:166`, inside `backward_since_from_step` | **excise** (whole-file closure, section 7) |

### 2. Group (a) — ghr93 full transitive closure (7 declarations)

The review-corrected 4-decl chain is confirmed, and the fresh closure analysis adds
`gap_cut_exists_gt` (freshly-orphaned guard) and `ghr93_forward_to_backward_core` (the "any
Theorem6.lean decl exclusively consumed by those two"):

```
gap_cut_exists_gt (CaseAnalysis:18)                    [orphan-guard: only uses at :2384,:3082]
ghr93_cases_III_IV (CaseAnalysis:2162)   7 sorries
  -> ghr93_cases_II_III_IV (CaseAnalysis:3604)
    -> ghr93_inductive_step (CaseAnalysis:3660)
      -> ghr93_forward_to_backward_core (Theorem6:54)
        -> ghr93_forward_to_backward (Theorem6:160)     0 call sites repo-wide
      -> ghr93_forward_to_backward_rank_varying (Theorem6:207)   0 call sites repo-wide
```

**Theorem6.lean consequence**: the file contains exactly 3 declarations (`:54`, `:160`,
`:207`; 422 lines total) — after excision it has ZERO declarations. `WeakCanonical.lean:19`
and `Transfer.lean:9` import it; an empty (docstring-only) module still compiles, so the
imports may stay or be dropped — planner's choice. `Transfer.lean:760`'s
`ghr93_inductive_step_discrete` is a distinct, live declaration (used at `Transfer.lean:922`)
and MUST NOT be touched.

**Keep set (verified live)**: `ghr93_case_I` (CaseAnalysis:61; live consumer
`Transfer.lean:833`), `ghr93_case_II` (CaseAnalysis:1368; live consumer `Transfer.lean:841`).
Their dead-chain call sites (`:3742`, `:3646`) disappear with the excision; the Transfer
consumers keep them live.

**Pre-existing dead pair (optional bundle, NOT freshly orphaned)**: `ghr93_construct_en`
(CaseAnalysis:1268) has zero consumers already today; `ghr93_untl_transfer` (CaseAnalysis:1191)
is consumed only by `ghr93_construct_en` (:1295). Both are sorry-free. They are outside the
dead-sorry charter and are not orphaned by this excision (their status does not change);
planner may bundle them for hygiene or leave them.

### 3. Group (b) — Algebraic dead closure (5 declarations)

```
provEquiv_all_future_congr (LindenbaumQuotient:169)   2 sorries
  -> G_quot (LindenbaumQuotient:314)                  [sole consumer of _congr, at :316]
    -> G_monotone (InteriorOperators:73)              1 sorry, 0 consumers
    -> sigma_quot_G_H (LindenbaumQuotient:410)        sorry-free, 0 consumers
    -> sigma_quot_H_G (LindenbaumQuotient:421)        sorry-free, 0 consumers
```

- `BooleanStructure.lean` references NONE of `G_quot`/`H_quot`/`sigma_quot*`/`provEquiv_all*`
  (fresh grep: zero hits).
- **Keep set**: `H_quot` (:321, consumed by sorry-free `H_monotone` InteriorOperators:96),
  `provEquiv_all_past_congr` (:190, sorry-free, consumed by `H_quot`), `H_monotone` (sorry-free;
  note it has zero external consumers today — pre-existing orphan, out of the sorry-sweep
  charter). `sigma_quot` keeps live consumers (`sigma_quot_involution:378`, `_neg:387`,
  `_sup:398`, `_box:432`) after the two G/H sigma lemmas go.
- Orphan check: the excised decls consume only shared live infrastructure (`Derives` lemmas,
  `toQuot`, `sigma_quot`) — nothing becomes freshly orphaned.

### 4. StaviCompleteness — enlarged dead-tail closure (16 declarations)

The archived audit's "def + docstring only" claim is stale: both sorried decls have real
in-file consumers. The full chain terminates at `stavi_expressive_completeness` (:3270), which
has **zero code consumers** — `PriorExpressiveness.lean:24` states the "sorry-tainted
`stavi_expressive_completeness` chain" is bypassed "entirely", and `:339` states its sole
former consumer was removed (both comment-only hits; word-boundary grep confirms no code use).
The flagship Prior chain kernel-verifies clean, so it cannot depend on this sorried chain.

Verified dead closure (excise together; excising only the 2 sorried decls would BREAK the
build since their consumers reference them):

| Declaration | Anchor | Notes |
|---|---|---|
| `nf_base_sf_correct` | :1438 | pre-tail orphan-guard: only consumers in tail |
| `nf_exist_sf_forward` (private) | :1666 | pre-tail orphan-guard: 3 tail uses only |
| `nf_fraisse_compression` | :2029 | sole consumer `:2593` (in `nf_2var_from_interval_data`) |
| `atom_agree_from_pointwise` | :2239 | zero consumers outside tail |
| `nf_2var_existential_transfer` | :2289 | sorries :2428, :2510 |
| `nf_2var_from_interval_data` | :2523 | consumer `:2627` (in `nf_2var_transfer`) |
| `nf_2var_transfer` | :2599 | 0 code consumers (dead top of chain A) |
| `interval_guard_sf` | :2654 | tail-only consumers |
| `interval_guard_sf_true` | :2660 | tail-only consumers |
| `nf_exist_sf_guarded` | :2680 | consumers :2737, :2763, :2872, :2907 — all in tail |
| `nf_exist_sf_guarded_forward` | :2720 | tail-only |
| `nf_exist_sf_guarded_backward` | :2856 | sorry :2884 |
| `nf_2var_exist_sf_classical` | :2889 | consumer `:3138` (in `..._characterizable`) |
| `nf_2var_existence_characterizable` | :2927 | consumers :3184, :3192 (in `nf_characterizable_by_stavi`) |
| `nf_characterizable_by_stavi` | :3159 | external hits are comments only (CharacteristicFormula.lean:8, KampPrior.lean:570) |
| `stavi_expressive_completeness` | :3270 | 0 code consumers (dead top of chain B) |

A scripted scan of all pre-:2029 declarations found exactly the two orphan-guards above
(`nf_base_sf_correct`, `nf_exist_sf_forward`) whose only consumers sit in the tail; all other
pre-tail decls retain non-tail consumers. Destination per audit: existing thematic subdir
`Boneyard/StaviDiscretePath/` remains appropriate. Implementer MUST re-run per-decl greps
immediately before excision (file is under active line-rot).

### 5. ChronicleToCountermodel — row DEMOTED to KEEP (except `succ_reaches_dom_N`)

The file's own header (:63-:67) lists `chronicle_gap_contradiction`, `succ_cofinal`, and
`limitDomSubtype_isSuccArchimedean` as "Dead declarations", and :814 claims
"`succ_embed_surjective` now uses the axiom instead of this definition". **Fresh code evidence
contradicts both comments**:

- `ChronicleToCountermodel.lean:1700`: `letI := limitDomSubtype_isSuccArchimedean fc A h_mcs
  h_fc h_discrete` INSIDE `succ_embed_surjective` (:1693), whose proof then invokes
  `exists_succ_iterate_of_le` (:1721) requiring that instance.
- `succ_embed_surjective` is live: used at :2039, :2055, :2092, :2123 inside
  `cantor_bfmcs_discrete_restricted_tc` (:2019) and `_fuc`, which are consumed by live code at
  `:2185` and `Transfer.lean:1245`.

Therefore `chronicle_gap_contradiction` → `succ_cofinal` → `limitDomSubtype_isSuccArchimedean`
are **compile-live** (mathematically dead-ended, but load-bearing for elaboration). Excising
any of them breaks `lake build`. Verdict: **KEEP all three; excise only `succ_reaches_dom_N`**
(:83, 2 sorries, zero consumers, first declaration in the file — its removal orphans nothing).
`limit_f_some_future_of_lt` (:436) and `limit_f_not_G_neg_of_mem` (:463) stay consumed by the
kept `chronicle_gap_contradiction`.

### 6. SuccExistence — row DEMOTED to SKIP

The audit's "Review-verified 0 consumers" is false at declaration granularity. Fresh greps:

- `constrained_successor_seed_consistent` (:436) → `constrained_successor_from_seed` (:492) →
  `{_mcs:502, _extends:511, _satisfies_g_persistence:520, _satisfies_f_step:530,
  constrained_successor_succ:551, successor_p_step:571}`
- `successor_deferral_seed_consistent_axiom` (:742) → `successor_deferral_seed_consistent`
  (:785) → `successor_from_deferral_seed` (:886) → 6 downstream theorems incl.
  `successor_exists` (:975)
- `predecessor_deferral_seed_consistent_axiom` (:816) → `predecessor_deferral_seed_consistent`
  (:868) → `predecessor_from_deferral_seed` (:998) → 9 downstream theorems incl.
  `predecessor_exists` (:1120), `predecessor_satisfies_p_step` (:1146)

A scripted external-consumer sweep over EVERY top-level declaration in the file found **zero
external code consumers for the entire file** (the only hits — `Pred`,
`predecessor_satisfies_p_step` — are comment mentions in NEquivalence.lean,
ChronicleToCountermodel.lean, SuccRelation.lean:510, CanonicalTaskRelation.lean:688). The sole
importer, `Core/RestrictedMCS/Basic.lean:7`, references none of its names. The file is a
**dead island (~70 decls, ~1,160 lines)**, but excising just the 3 sorried decls would freshly
orphan the entire upper-half helper apparatus (seeds, deferral disjunctions, blocking-formula
lemmas) and break the in-file consumer chains. The only safe excision is whole-file archival —
out of scope for a Tier-2 row. **Verdict: SKIP in this sweep; recommend a dedicated follow-up
task for whole-file archival of `Bundle/SuccExistence.lean`** (drop the unused import in
`Core/RestrictedMCS/Basic.lean:7`).

### 7. UntilSinceCoherence — enlarged whole-file closure (6 declarations)

The audit's "def + doc mentions only" is stale; both sorried decls have in-file consumers. The
file contains exactly 6 declarations forming two 3-link dead chains with sorry-free upper
links and zero external code consumers at every level:

```
backward_until_reflexive (:81, sorry :85) -> backward_until_from_step (:113) -> backward_until_coherent (:187, 0 consumers)
backward_since_reflexive (:92, sorry :96) -> backward_since_from_step (:147) -> backward_since_coherent (:201, 0 consumers)
```

Excise all 6 together (partial excision breaks the build). The file is then declaration-empty;
its sole importer `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:3` uses none of the
6 names (its `:649` hit `restricted_backward_until_since_coherent` is a different identifier —
a structure field). Import may stay (empty module compiles) or be dropped.

### 8. SorriedDeclExcisions/ never-built policy conventions

`Theories/Bimodal/Boneyard/SorriedDeclExcisions/` **does not exist yet** — the implementer
must create it (finding: the task description presumes it exists). Conventions documented from
existing exemplars (`Boneyard/BXPipelineGapAnalysis/ChronicleNoGaps.lean`,
`Boneyard/BXPipelineGapAnalysis/HenkinDiscreteChain.lean`, and the freshest excision-style file
`Metalogic/WeakCanonical/Kamp/Boneyard/EANegationVBracketBackward.lean`):

1. **Imports first** — copy the source file's import block verbatim (stale imports are
   cosmetic in never-built files; standing policy says do NOT repair them).
2. **ARCHIVED module docstring** immediately after imports, first line pattern:
   `ARCHIVED (Boneyard) — never compiled. <one-line reason>.` followed by: what superseded it,
   preserved provenance labels, an inventory of the moved declarations by name, and the closing
   sentence `Do not import from live code.`
3. **`#exit` immediately after the docstring** (before the first declaration) — after-imports
   placement is the normalized convention (a pre-import `#exit` is a syntax error in Lean 4).
4. **Code moved verbatim** below the `#exit`.
5. **README inventory** — add a row + section to `Theories/Bimodal/Boneyard/README.md`'s
   Directory Inventory table for the new subdirectory.
6. **Never built**: `lakefile.lean` has exactly `lean_lib Bimodal` / `lean_lib BimodalTest`
   with no globs (root-closure semantics) — Boneyard files never participate in `lake build`;
   verified in the archived audit and unchanged.

### 9. Gate baselines

**Axiom baseline (tool-verified this session)** — `lean_verify` on
`Bimodal.Metalogic.BXCanonical.completeness_discrete`
(`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:288`):

```
["propext", "Classical.choice", "Quot.sound"]
```

Byte-identical to the post-cleanup review's recorded baseline. This is the gate: re-run after
each excision phase and require the identical list.

**Sorry census baseline (statement-position sorries, per touched file, current anchors)**:

| File | Count | Lines |
|---|---|---|
| `WeakCanonical/Expressiveness/CaseAnalysis.lean` | 7 | :3376,:3380,:3383,:3403,:3405,:3407,:3417 (all inside `ghr93_cases_III_IV`) |
| `WeakCanonical/Expressiveness/Theorem6.lean` | 0 | (sorry-taint arrives via `ghr93_inductive_step` dependency) |
| `WeakCanonical/TruthLemma.lean` | 6 | :431,:448,:483,:497,:540,:556 |
| `WeakCanonical/OrderedSum.lean` | 1 | :57 |
| `BXCanonical/Frame.lean` | 1 | :205 |
| `WeakCanonical/EFGames/StaviCompleteness.lean` | 3 | :2428,:2510,:2884 |
| `BXCanonical/Chronicle/ChronicleToCountermodel.lean` | 6 | :221,:377 (excisable) + :513,:527,:768,:788 (kept, in `chronicle_gap_contradiction`) |
| `Bundle/SuccExistence.lean` | 3 | :446,:749,:823 (skipped) |
| `Bundle/UntilSinceCoherence.lean` | 2 | :85,:96 |
| `Algebraic/InteriorOperators.lean` | 1 | :83 |
| `Algebraic/LindenbaumQuotient.lean` | 2 | :177,:182 |
| **In-scope total** | **32** | |

**Projected removal if all excise verdicts are implemented**: 25 sorries removed
(7 ghr93 + 6 TruthLemma + 1 OrderedSum + 1 Frame + 3 Stavi + 2 `succ_reaches_dom_N` +
2 UntilSinceCoherence + 1 `G_monotone` + 2 `provEquiv_all_future_congr`); 7 remain in-scope
(4 in kept `chronicle_gap_contradiction`, 3 in skipped SuccExistence).

### 10. TruthLemma enlarged closure detail (for the plan)

Minimal safe excision set = 5 sorried decls + 7 sorry-free helpers exclusively consumed by
them (verified: every use line of each helper falls inside the excised set):

- Sorried: `truth_lemma:510`, `until_forward_mcs:402`, `until_backward_mcs:444`,
  `since_forward_mcs:456`, `since_backward_mcs:493`
- Exclusively-consumed helpers (would be freshly orphaned otherwise): `reflCanTruth:58`
  (uses :61,:73,:86,:239,:511,:530 — all in-closure), `atom_truth_iff:72` (:514),
  `bot_truth_false:75` (:515), `imp_truth_iff:85` (:517), `imp_mcs_iff:88` (:517),
  `box_forward_mcs:120` (:526), `box_backward_mcs:136` (:524)
- **KEEP**: `bot_not_in_mcs:78` — 15 external code consumers (live).
- Note: `G_forward_mcs:246`, `G_backward_mcs:259`, `H_forward_mcs:318`, `H_backward_mcs:332`
  are sorry-free with zero consumers ALREADY today (pre-existing orphans, not freshly orphaned
  by this excision; not used by `truth_lemma`). Planner's choice to bundle or leave.

## Adversarial Self-Verification

Every load-bearing deadness claim below was verified by executing the stated grep this
session; counts are code consumers after excluding Boneyard, definition lines, and comment/
docstring mentions.

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `ghr93_forward_to_backward` has 0 call sites | `grep -rnw "ghr93_forward_to_backward" Theories/ Tests/` → 2 hits: own def `Theorem6.lean:160`, docstring `CaseAnalysis.lean:3655` | word-boundary grep (substring hits for `_core`/`_rank_varying` excluded by `-w`) | High |
| `ghr93_forward_to_backward_rank_varying` has 0 call sites | same grep form → 1 hit: own def :207 | word-boundary grep | High |
| `ghr93_inductive_step`'s only consumers are the two dead Theorem6 exports | grep → code hits exactly `Theorem6.lean:124`, `:413`; `Transfer.lean:922` calls the DIFFERENT decl `ghr93_inductive_step_discrete` | grep + enclosing-decl resolution via awk | High |
| `gap_cut_exists_gt` would be freshly orphaned | grep → uses only :2384, :3082, both within `ghr93_cases_III_IV` (:2162–:3603) | grep + decl-boundary awk | High |
| `G_monotone`, `sigma_quot_G_H`, `sigma_quot_H_G` have 0 consumers; `G_quot`'s consumers are exactly those three | per-name repo greps; `BooleanStructure.lean` grep for `G_quot\|H_quot\|sigma_quot\|provEquiv_all` → 0 hits | grep | High |
| `chronicle_gap_contradiction`/`succ_cofinal` are compile-LIVE | COUNTEREXAMPLE to audit + file header: `ChronicleToCountermodel.lean:1700` `letI := limitDomSubtype_isSuccArchimedean …` inside live `succ_embed_surjective` (:1693), consumed at :2039/:2055/:2092/:2123 by `cantor_bfmcs_discrete_restricted_tc/fuc`, consumed at `Transfer.lean:1245` | Read of :1693-:1722 + consumer greps | High |
| `succ_reaches_dom_N` has 0 consumers and orphans nothing | grep → comments only (:64,:218,:374,:484); it is the FIRST declaration in the file, so no earlier in-file decl can depend on it | grep + decl census | High |
| `stavi_expressive_completeness` (chain top) has 0 code consumers | grep -rnw → hits are comments: `PriorExpressiveness.lean:24` ("bypasses the sorry-tainted … chain entirely"), `:324`,`:339` (docstring, "the sole consumer … was this theorem" — removed), `KampPrior.lean:652` (docstring) | word-boundary grep + hit-by-hit classification | High |
| Stavi pre-tail orphan-guards are exactly `nf_base_sf_correct`, `nf_exist_sf_forward` | scripted scan of ALL pre-:2029 decls: external==0 AND in-file-before-:2029 uses==def-only AND tail uses>0 | scripted per-decl grep loop | Medium (comment-line filtering in the script is heuristic; implementation-time re-grep mandated) |
| SuccExistence is a whole-file dead island | scripted sweep of every top-level decl name → 0 external code hits (only comment mentions of `Pred`, `predecessor_satisfies_p_step`); sole importer `Core/RestrictedMCS/Basic.lean` references no SuccExistence name | scripted per-decl grep loop + importer grep | High |
| UntilSinceCoherence closure is the whole 6-decl file, externally dead | per-name greps: `backward_until_coherent`/`backward_since_coherent` 0 consumers; `ChronicleToCountermodelBasic.lean:649`'s `restricted_backward_until_since_coherent` is a distinct identifier (structure field) | grep + identifier comparison | High |
| `truth_lemma` cluster external deadness; `bot_not_in_mcs` live | per-name greps over all 17 decls of `WeakCanonical/TruthLemma.lean`: only `bot_not_in_mcs` has external hits (15); BXCanonical same-name `until_forward_mcs`/`since_forward_mcs` hits are that file's own distinct decls (shadowing, as audit predicted) | per-decl grep loop | High |
| Axiom baseline `[propext, Classical.choice, Quot.sound]` | `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_discrete` returned exactly that list, no warnings | lean_verify (kernel axiom check) | High |
| `doets_lemma_1_4` must be kept | grep → live use documented in `IntegerModel/GoodStructures.lean:392,:405` | grep | High |

### Contradiction Log

1. **`ChronicleToCountermodel.lean` header/comments vs. code**: header :63-:67 labels
   `chronicle_gap_contradiction`/`succ_cofinal`/`limitDomSubtype_isSuccArchimedean` "Dead
   declarations"; :814 claims `succ_embed_surjective` "uses the axiom instead of this
   definition". Code at :1700 shows the definition IS bound and consumed. **Resolution
   (precedence: current code > comments)**: the three are compile-live; comments are stale.
   Row demoted to KEEP. Recommend the plan also fix the stale header (cosmetic).
2. **Archived audit rows vs. fresh greps**: audit claimed "def + doc mentions only" /
   "0 consumers" for the StaviCompleteness pair, UntilSinceCoherence pair, and SuccExistence
   trio. Fresh greps show real in-file consumer chains for all three rows. **Resolution
   (precedence: fresh grep > archived report)**: closures enlarged (sections 4, 7) or row
   skipped (section 6). This is exactly the failure mode the review's Finding 1 predicted for
   the ghr93 row, recurring in three more rows.

### Recommendations modified after verification

- ChronicleToCountermodel row: excise-pair → KEEP pair, excise only `succ_reaches_dom_N`.
- SuccExistence row: excise-3 → SKIP (whole-file archival as separate task).
- StaviCompleteness row: excise-2 → excise-16 (full tail closure + 2 orphan-guards).
- UntilSinceCoherence row: excise-2 → excise-6 (whole file's declaration set).
- TruthLemma row: excise-5 → excise-12 (5 sorried + 7 exclusively-consumed helpers), keep
  `bot_not_in_mcs`.
- Group (a): excise-4 → excise-7 (add `_core`, `gap_cut_exists_gt`; Theorem6.lean emptied).

## Next Steps

Run `/plan 387` to create the implementation plan. Suggested phase shape: one phase per
excision group (a, b, OrderedSum+Frame micro-group, TruthLemma, Stavi, USC,
`succ_reaches_dom_N`), each ending with scoped `lake build` + fresh-orphan grep + axiom-gate
`lean_verify`, with the SorriedDeclExcisions/ directory + README inventory created in phase 1.
