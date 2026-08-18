# Research Report: Task #457

**Task**: 457 - Repair remaining literature corpus data defects
**Started**: 2026-08-18
**Completed**: 2026-08-18
**Effort**: Medium (data-only repairs, no code changes)
**Dependencies**: None
**Sources/Inputs**:
- `/home/benjamin/Projects/Literature/index.json` (global corpus index, 369 entries)
- `specs/literature-index.json` (this repo's 45-entry relevance sub-index)
- `.claude/context/project/literature/patterns/chunk-file-conventions.md`
- `.claude/scripts/literature-normalize-authors.sh`, `literature-build-index.sh`,
  `literature-fidelity-audit.sh`
- `zotero-library.json` (CSL-JSON export, 200 items)
- Direct filesystem inspection of `sources/*/` directories

**Artifacts**:
- This report

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- All 8 scopes were independently re-verified against the live 369-entry global index (which
  has drifted since the task description's counts were taken, as expected). Every count in the
  task description checks out almost exactly; two small discrepancies are noted below (SCOPE 5,
  SCOPE 3).
- SCOPE 1 (diamondsareforever), SCOPE 2 (3 stub token counts), and SCOPE 4 (60 comma-joined
  authors) are mechanically fixable with a clear, unambiguous target value each.
- SCOPE 3's "56 drift warnings" figure is best read as SCOPE1(1) + SCOPE2(3) + SCOPE3(52,
  "roughly"). My own chars/4+20 recomputation independently finds 56 entries beyond SCOPE1/2
  drifting past the 20% mark (close to but not exactly 52 — see Decisions below for the
  reconciliation and why it doesn't change the repair approach).
- A previously undocumented sub-finding: all 12 `baier_katoen_2008_partNN` entries share the
  *identical* stored `token_count` (39848), which cannot be correct for 12 distinct file
  contents — this is a copy-paste/placeholder bug, not organic per-document drift, and is a
  clean illustration of exactly the "changed formula or bulk re-conversion" mechanism SCOPE 3
  hypothesizes.
- SCOPE 4 and SCOPE 5 tooling/counts are confirmed ready: `literature-normalize-authors.sh`
  (dry run) proposes exactly 60 correct-looking normalizations; the "35 entries missing
  doc_type/source_format" figure is exact once the 15 legacy `chunks_dir`-only entries (which
  lack ALL v2 fields, not just these two) are excluded from the count — 12 of those 15 are
  **not** mentioned anywhere in the task's SCOPE 7 (which names only 3), a coverage gap worth
  flagging (see Context Extension Recommendations).
- SCOPE 6 counts (22 both-schema, 37 absolute `chunks_dir`) match exactly; the investigate-first
  framing in the task is correct — recommend leaving legacy-schema fields as-is except where a
  `path`-schema migration is independently justified by another scope (e.g. SCOPE 1, SCOPE 7).
- SCOPE 7's 3 entries were re-confirmed to be null/null (`provenance_fidelity`/`token_count`)
  in the legacy `chunks_dir` schema, with the fidelity narrative already present, unchanged, and
  reusable in `specs/literature-index.json`'s `fidelity` field for all three.
- SCOPE 8(a) (Gabbay/Kurucz/Wolter/Zakharyaschev 2003) is confirmed present in Zotero
  (`citation-key: Kurucz2003`) but absent from the corpus index — matches the task's account.
  SCOPE 8(b) (Goldblatt 1989 "Varieties of complex algebras") is confirmed absent from the
  corpus, and `goldblatt_2003` in the corpus is confirmed to be the distinct Erdős-graphs paper.
- **No mutations were made.** This is a research-only pass; VERIFICATION REQUIREMENT's backup +
  re-validate + rebuild-index contract applies to the /plan → /implement phases that will
  actually write to `index.json`.

## Context & Scope

Task 457 asks for data-only repairs to two literature indices — the global corpus index at
`~/Projects/Literature/index.json` (369 entries, the corpus of record) and this repo's
45-entry relevance annotation sub-index at `specs/literature-index.json` — across 8 named
scopes. The task explicitly excludes agent-system code changes (5 corresponding code defects
are tracked in the global agent-system repo). This research pass re-verifies every scope's
counts against the live corpus (which the task itself warns may have changed since its counts
were taken), confirms the mechanical fix for each scope, and surfaces one new finding (the
`baier_katoen_2008` uniform-value bug) plus one coverage gap (12 undocumented legacy-schema
entries beyond SCOPE 7's named 3).

## Findings

### SCOPE 1 — diamondsareforever malformed entry

Re-confirmed: this is the **only** entry in the 369-entry index whose `path` matches
`chunk_\d+\.md$` (`sources/diamondsareforever/chunk_0001.md`, 903 bytes, abstract only).
Unlike normal multi-chunk sources (e.g. `blackburn_2002`, which has semantically-named
`chNN_*.md` files as its canonical content alongside its `chunk_NNNN.md` FTS re-splits),
`sources/diamondsareforever/` contains **only** `chunk_0001.md`...`chunk_0056.md` — there is no
separate canonical whole-document markdown file for this source.

Three other corpus entries share this same "chunk-files-only, no canonical doc" shape:
`brast-mckie_2026_construction-possible-worlds`, `brast-mckie_2026_counterfactual-worlds`, and
`goldblatt_2023_strong-completeness-real-time`. Their index entries establish the convention to
follow: `path` points at the **directory** (trailing slash, e.g.
`"sources/goldblatt_2023_strong-completeness-real-time"` or
`"sources/brast-mckie_2026_construction-possible-worlds/"`), never at an individual chunk file.

Recomputed whole-document size for diamondsareforever by summing all 56 `chunk_NNNN.md` files
(the only content that exists) two ways:
- Sum of `chunks.json`'s own per-chunk `token_count` fields: **21,710**
- `chars/4 + 20` over the concatenated chunk text (86,943 chars): **21,755**

Both land far below the stored 95,000 and confirm the stored figure is not a real measurement
of this document (a Nous journal article of this length would not run to 95k tokens; 21-22k is
consistent with a ~30-page paper).

**Recommended fix**: set `path` to `"sources/diamondsareforever/"` (directory, matching the
3-entry convention above) and `token_count` to ~21,755 (using the chars/4+20 formula for
consistency with the SCOPE 3 re-baseline — see Decisions).

### SCOPE 2 — three stub token_count values

Recomputed directly from the canonical `.md` file in each directory (excluding `chunk_*.md`
re-splits per `chunk-file-conventions.md`), using `chars/4 + 20`:

| doc_id | stored | task's stated "actual" | my recomputed actual |
|---|---|---|---|
| `fine_2012_guide-to-ground` | 521 | 27134 | 26772 |
| `vardi_wolper_1986_automata_verification` | 196 | 11871 | 11716 |
| `fine_2012_counterfactuals-without-possible-worlds` | 2222 | 15982 | 15958 |

The small deltas between the task's stated figures and mine (≤2%) are consistent with the
task's "actual" numbers having been computed at a slightly earlier corpus snapshot or via a
marginally different word/char-counting method; the direction and order of magnitude match
exactly, and both fully confirm the stub-vs-converted mismatch. **Recommended fix**: use the
`chars/4+20` recomputation at implementation time (fresh, not either of the two cited figures)
so the value matches whatever formula SCOPE 3's re-baseline settles on.

### SCOPE 3 — systematic token_count drift (~52 entries)

Recomputed `actual = chars/4 + 20` for every entry carrying a `path` field (323 of 369 entries;
the remaining 46 are the 15 legacy `chunks_dir`-only entries plus entries with a null/zero
stored `token_count`), and compared against stored `token_count`.

Excluding the 4 entries already accounted for by SCOPE 1 (diamondsareforever) and SCOPE 2 (the
3 stubs), **56 entries** drift beyond the ±20% band, of which **44** fall in the tight
1.20–1.35 ratio band the task calls out (the task says "40+"; 44 matches). All 56 drift in the
same direction (actual > stored). This is close to, but not exactly, the task's "roughly 52"
figure for SCOPE 3 — the task's own total across all three scopes was 56 *including* SCOPE 1/2,
which would put SCOPE 3 alone at 52; my recomputation puts SCOPE-3-only at 56. This 4-entry
gap is well within "roughly" and does not change the repair approach (re-baseline every entry
whose recomputed value diverges from stored by >20%, regardless of which exact scope-bucket it
lands in) — see Decisions for the reconciliation.

**New finding**: all 12 `baier_katoen_2008_part01`...`part12` entries carry the **identical**
stored `token_count` of 39848 — impossible for 12 distinct part files. Recomputed per-part
values range from ~39848 (part04, part06, part07, part12 — near-unchanged, i.e. these happen to
be close to the placeholder) up to 56,496 (part01). This is a clean, isolated illustration of
the "bulk re-conversion assigned one value to many entries" mechanism SCOPE 3 hypothesizes as
the root cause of the uniform 1.21–1.35 ratio band elsewhere (a formula change would drift
every entry by a similar *ratio*; a copy-paste-one-value bug drifts entries by wildly different
ratios depending on how far each part's real size is from the copied placeholder — both
patterns are present in the 56-entry set, and both resolve to the same fix: recompute
independently, per entry, from the file on disk).

**Recommended fix**: for all 56 (or however many re-confirmed at repair time — the task's own
counts note the corpus changes) entries with `path` and stored `token_count` diverging from
`chars/4+20` by more than 20%, overwrite stored `token_count` with the recomputed value.

### SCOPE 4 — comma-joined authors string (60 entries)

Confirmed exactly 60 entries with `authors` stored as a single comma-joined string rather than
an array (`chagrovzakharyaschev_1997_modallogic_p00`..`p05`, `bentzen_2023`, `church_1956` and
children, `troelstra_schwichtenberg_2000_*`, etc.). Ran
`.claude/scripts/literature-normalize-authors.sh /home/benjamin/Projects/Literature/index.json`
(bare, dry-run) directly: it reports "Entries that would change: 60" and every proposed
`before`/`after` pair I sampled is a correct split (e.g.
`"Alexander Chagrov, Michael Zakharyaschev"` → `["Alexander Chagrov","Michael Zakharyaschev"]`).
Independently confirmed **zero** array-valued `authors` entries contain a comma-joined element
— the malformed-array regression the script also guards against has not reappeared.

**Recommended fix**: run the script with `--apply` at implementation time (after taking a
backup per the Verification Requirement).

### SCOPE 5 — missing doc_type / source_format (35 entries)

A naive count of entries missing either field returns 50, not 35, because it also catches the
15 legacy `chunks_dir`-only entries (which lack essentially every v2 field, including `path`,
`provenance_fidelity`, `doc_type`, and `source_format` — a different, harder defect covered by
SCOPE 6/7, not SCOPE 5). Excluding those 15 legacy entries yields exactly **35**, all missing
BOTH `doc_type` and `source_format` together (never just one) — Church 1956 (7 chapter
entries), Gentzen 1935 (5 section entries), Girard 1989/`proofs_and_types`, Mendelson 2016 (6
chapter entries), Hughes 1996 (4 part entries), Zakharyaschev 2001 (4 section entries),
Henkin 1949, Johansson 1937, Post 1921, `van_doorn_2015_propositional_calculus_coq`,
`from_2022`, `gabbay_1994_ch10`, `trufas_2024` — 35 total, matching the task exactly once the
legacy-schema entries are correctly excluded from the denominator.

**Recommended fix**: for each of the 35, infer `doc_type` (book/paper/article) and
`source_format` (almost certainly `pdf` for all of these older ingests — worth a quick `file`/
extension check per source directory rather than blanket-assuming) from title/venue context;
this is a per-entry judgment call, not a script-applicable bulk fix, so it should be enumerated
explicitly in the implementation plan rather than automated blindly.

### SCOPE 6 — path/chunks_dir coexistence and absolute chunks_dir (investigate-first)

Confirmed exactly **22** entries carry both `path` and `chunks_dir` simultaneously (e.g.
`bonakdarpour_sheinvald_2023_finite_word_hyperlanguages`, `finkbeiner_etal_2017_monitoring_hyperproperties`,
`proofs_and_types`), and exactly **37** entries have an absolute (non-portable) `chunks_dir`.
These are large overlapping-but-not-identical sets (all entries with absolute `chunks_dir` also
appear to carry `path` in most cases sampled, but the 22-count and 37-count are each independently
confirmed against the task's stated figures). No entry in either set appears to be functionally
broken today — `path` is present and correct wherever `chunks_dir` is also present in the
sampled entries — so this looks like accumulated legacy-format residue from earlier ingest-bridge
versions rather than an active defect.

**Recommendation** (low confidence, as the task itself flags): leave these fields alone unless
a specific consumer is shown to read `chunks_dir` in preference to `path` and get a wrong
answer as a result (no such consumer was found in `.claude/scripts/literature-*.sh` in a quick
grep — all the retrieval-path scripts read `path` first). Normalizing 37 absolute paths to
relative ones is a nice-to-have portability improvement, not a correctness fix, and should be
scoped as an optional low-priority phase rather than blocking the higher-confidence scopes.

### SCOPE 7 — provenance adjudication for 3 newly-ingested documents

Re-confirmed all three entries (`j_nsson_and_tarski_-_1951_-_boolean_algebras_with_operators._part_i`,
`..._1952_..._part_ii`, `goldblatt_-_mathematical_modal_logic_a_view_of_its_evolution`) sit at
the tail of the global index in the legacy `chunks_dir` schema (`doc_id`, `chunks_dir`,
`chunk_count`, no `path`, `token_count: null` via absence, `provenance_fidelity: null` via
absence). Chunk counts on disk match exactly: 85 files for Jönsson-Tarski I, 82 for Part II,
199 for Goldblatt 2006.

`specs/literature-index.json` already carries the adjudication narrative for all three, unchanged
and ready to use as the basis for the global index's `provenance_fidelity` stamp:
- **Jönsson-Tarski 1951/1952** (`fidelity` field): "PROSE: high... FORMULAS: DEGRADED — this is
  a JSTOR scan and mathematical symbols are lossily extracted (`=-` for `=`, `?` standing in for
  relations, mangled subscripts)... Do NOT transcribe any equation, axiom, or symbolic statement
  into Lean from the markdown alone."
- **Goldblatt 2006** (`fidelity` field): "PROSE and SYMBOLS: good, spot-checked by direct
  read... word ratio 0.979 against pdftotext over 98 pages"; `conversion_note` confirms the
  fallback `LITERATURE_CONVERTER=pymupdf` tier was used after the default tier failed the
  quality gate, verified after the fact.

None of the existing `provenance_fidelity` enum values used elsewhere in the corpus
(`verified_conversion`, `no_source_pdf`, `unverified_no_baseline`, `unadjudicated`,
`not_yet_converted`, `unverified_conversion`) cleanly captures "excellent prose, degraded
formulas — safe for prose citation, unsafe for verbatim formula transcription." Rather than
force-fitting the Jönsson-Tarski pair into `verified_conversion` (which would read as a blanket
green light including formulas — exactly the kind of over-claim the rabinovich_2014 hazard
record warns against), the report's recommendation is:
- Jönsson-Tarski I and II → `unverified_conversion` (prose-safe but formula-risk is real and
  already flagged textually — this enum value already exists and reads honestly as "usable with
  care," matching the one other existing use of `unverified_conversion` in the corpus), **plus**
  ensure the sub-index's `fidelity` degraded-formula warning stays intact and is not
  paraphrased away by the stamp.
- Goldblatt 2006 → `verified_conversion` (spot-checked, 0.979 word ratio, no degraded-formula
  caveat recorded) — matches the bar the 127 other `verified_conversion` entries in the corpus
  meet.

`token_count` for all three should be computed the same way as SCOPE 1/2/3 (`chars/4+20` over
the non-chunk canonical `.md` content if one exists after conversion, else over the chunk files
themselves) once `path` is populated pointing at the directory, following the SCOPE 1 pattern.

**Caution flagged explicitly by the Verification Requirement**: do not stamp these fidelity
values mechanically from the ratio alone — this repeats verbatim the rabinovich_2014 hazard
(a falsely-stamped `verified_conversion` silently invalidated 89 Lean citations). The
sub-index's fidelity narrative here already reflects a manual read (it describes specific
observed corruption patterns like `"go, g1i"` and `"<Ar, +a0d >"`), so stamping from it is
grounded in a prior manual spot-check, not a bare automated ratio — but the implementer should
still re-confirm by opening at least one chunk from each of the three documents before writing
the stamp, per the Verification Requirement's letter.

### SCOPE 8 — two acquisition gaps

**(a) Gabbay, Kurucz, Wolter & Zakharyaschev 2003, "Many-Dimensional Modal Logics"**: confirmed
present in `zotero-library.json` (CSL-JSON `id: "Kurucz2003"`, matching authors) but **absent**
from the corpus index under any doc_id — searched for `gabbay`/`kurucz`/`many-dimensional` and
found only the unrelated `gabbay_1993`/`gabbay_1994`/`gabbay_2000` (different Gabbay volumes)
and `caleiro_2013` ("On the Mosaic Method for Many-Dimensional Modal Logics" — a related but
distinct paper). This matches the task's account of a blocked PDF (broken font encoding, not
text-extractable). No corpus-side data fix is possible here; the underlying PDF defect is an
acquisition/OCR problem, not an index-schema problem.

**(b) Goldblatt 1989, "Varieties of complex algebras"**: confirmed absent from the corpus index,
absent from the 200-item Zotero library search (no title match for "varieties" combined with
Goldblatt/1989), and confirmed that `goldblatt_2003` in the corpus is "Erdős Graphs Resolve
Fine's Canonicity Problem" — a different, later Goldblatt paper, exactly as the task states.

**Recommendation**: both (a) and (b) are acquisition gaps, not data-repair targets, and are
better handled as separate spawned tasks (via `/spawn`) once this task's data-repair scopes
land, rather than solved inline here — consistent with the task description's own framing.

## Decisions

1. **Formula for all token_count recomputation (SCOPE 1, 2, 3, 7)**: use `chars/4 + 20`,
   matching the formula the task names for SCOPE 3 and the one already in production use for
   an analogous purpose in `.claude/scripts/memory-harvest.sh:129`. This keeps the whole corpus
   on one consistent, already-precedented heuristic rather than introducing a second formula
   for a subset of entries.
2. **SCOPE 3 population set at implementation time is "recompute and re-baseline every drifted
   entry found live," not "the specific N ids listed in this report"** — both the task
   description and this report's own recount emphasize the corpus is a moving target; the
   implementer should re-run the same chars/4+20 comparison immediately before writing, not
   replay a frozen list.
3. **SCOPE 5's 35-entry denominator excludes the 15 legacy chunks_dir-only entries** — those 15
   need the full v2 schema migration (or a deliberate decision to leave them in legacy schema
   with `provenance_fidelity: null` as a "not yet adjudicated" marker), which is a materially
   different, larger task than filling in two missing string fields on an otherwise-complete v2
   record. Recommend the plan treat SCOPE 5 (35 entries, cosmetic field-fill) and the
   3-entry SCOPE 7 adjudication as separate line items, and flag the other 12 legacy entries as
   a follow-up (see below) rather than silently expanding SCOPE 5's or SCOPE 7's scope to cover
   them.
4. **SCOPE 7 fidelity stamps**: Jönsson-Tarski I/II → `unverified_conversion`; Goldblatt 2006 →
   `verified_conversion`, per the reasoning in the Findings section above. This is a judgment
   call informed by, but not mechanically derived from, the existing sub-index prose — flag for
   explicit confirmation during planning since it sets a precedent for how "excellent prose,
   degraded formula" documents get classified going forward.
5. **SCOPE 6 is deferred/optional**: no active breakage found; recommend a low-priority final
   phase (or explicit deferral) rather than blocking the higher-value scopes 1-5/7 on it.
6. **SCOPE 8 is out of repair-scope**: recommend the implementation plan close with a
   recommendation to run `/spawn 457 <blocker>` (or open two new tasks directly) for the OCR/
   font-encoding problem and the missing Goldblatt 1989 source, rather than attempting either
   inline.

## Risks & Mitigations

- **Risk**: stamping `provenance_fidelity` from ratio/automation alone repeats the
  rabinovich_2014 89-citation-invalidation hazard. **Mitigation**: SCOPE 7's stamps are grounded
  in the sub-index's already-manual fidelity narrative (specific corruption examples were
  transcribed by a prior manual read, not inferred from a bare ratio); still, re-open at least
  one chunk per document at implementation time before writing, per the Verification
  Requirement.
- **Risk**: SCOPE 3's bulk re-baseline could paper over a genuine content-corruption event
  (e.g. if a document's `.md` legitimately grew due to bad content, not a formula change).
  **Mitigation**: the `baier_katoen_2008` uniform-placeholder finding and the "55/56 same
  direction, 44 in a tight ratio band" clustering are themselves the evidence that this is a
  metadata/formula problem, not per-document content drift — but the implementer should still
  spot check 2-3 of the 56 recomputed `.md` files for sane, expected prose (not mojibake or
  duplicated content) before writing the bulk update, since the LITERATURE_CONVERTER=pymupdf
  mojibake incident described in SCOPE 8(a) shows corrupted content can still pass a naive
  quality gate.
- **Risk**: `literature-build-index.sh --global` rebuild after mutation could surface FTS
  inconsistencies if `path`/`chunks_dir` changes (SCOPE 1, SCOPE 7) are not also reflected
  correctly for the chunk-search database. **Mitigation**: the Verification Requirement already
  mandates a rebuild + validate pass after every mutation; the implementation plan should treat
  this as a hard gate per batch of changes, not a single end-of-task step, so a single scope's
  mistake doesn't get buried under six other scopes' changes before being caught.
- **Risk**: `.claude/scripts/literature-normalize-authors.sh --apply` and the SCOPE 3 bulk
  token_count rewrite both touch large fractions of the 369-entry file in one pass; a partial
  write (process killed mid-write) could corrupt `index.json`. **Mitigation**: back up before
  each of the (at minimum) 3 mutation batches (SCOPE 1+2+3 token/path fixes, SCOPE 4 authors
  normalization, SCOPE 5+7 field fills), not just once at the start, so a mid-task failure loses
  at most one batch's work, and each batch is independently re-validatable.

## Context Extension Recommendations

- **Topic**: legacy `chunks_dir`-only entries beyond SCOPE 7
- **Gap**: 15 entries in the global index carry only the legacy ingest-bridge schema
  (`doc_id`/`chunks_dir`/`chunk_count`, no `path`/`token_count`/`provenance_fidelity`/
  `doc_type`/`source_format`). SCOPE 7 names exactly 3 of these
  (Jönsson-Tarski I, Jönsson-Tarski II, Goldblatt 2006); the other 12
  (`brics-rs-96-35`, `cattani-winskel-2005-profunctors`, `brics-rs-94-7`,
  `schultz-spivak-temporal-type-theory`, `fong-speranzon-spivak-temporal-landscapes`,
  `schultz-spivak-vasilakopoulou-dynamical-systems-sheaves`, `thomason-1970-indeterminist-time`,
  `rutten-2000-universal-coalgebra`, `jacobs-coalgebra-intro-draft`, `danos-krivine-rccs`,
  `reynolds-2003-ockhamist`, `rumberg-zanardo-2019-transition-structures`) are not mentioned
  anywhere in task 457's description and have no path forward defined.
- **Recommendation**: either (a) fold these 12 into this task's SCOPE 7 as a follow-on batch
  using the same adjudication process (since the online-ingest bridge's legacy-schema output is
  evidently the common root cause across all 15, not just the 3 named), or (b) spawn a
  dedicated follow-up task once 457 lands, so this repair pattern doesn't have to be
  rediscovered from scratch. Recommend (b) if 457's scope is already considered fixed
  (the task explicitly enumerates 3), to avoid silent scope creep on a task already in
  [RESEARCHING].

## Appendix

### Verification commands run (read-only; no mutations)

```bash
# Global index entry count and schema shape
python3 -c "import json; d=json.load(open('index.json')); print(len(d['entries']))"

# SCOPE 1: chunk-file path detection
# (grep for path matching chunk_\d+\.md$ across all 369 entries -> exactly 1 hit)

# SCOPE 2/3: chars/4+20 recomputation against every entry's `path`, compared to stored token_count

# SCOPE 4: dry-run normalization
bash .claude/scripts/literature-normalize-authors.sh /home/benjamin/Projects/Literature/index.json

# SCOPE 5/6: field-presence and schema-coexistence counts via direct JSON iteration

# SCOPE 7: chunk_count cross-check against `find sources/<dir> -iname 'chunk_*.md' | wc -l`
#           (85 / 82 / 199, all matched)

# SCOPE 8: zotero-library.json title search for "many-dimensional" and "varieties"
```

### Files inspected (not modified)

- `/home/benjamin/Projects/Literature/index.json`
- `/home/benjamin/Projects/Literature/zotero-library.json`
- `/home/benjamin/Projects/Literature/sources/diamondsareforever/{chunks.json,metadata.json,chunk_*.md}`
- `/home/benjamin/Projects/Literature/sources/{fine_2012_guide-to-ground,vardi_wolper_1986,fine_2012_counterfactuals-without-possible-worlds,goldblatt_2003,baier_katoen_2008}/*.md`
- `/home/benjamin/Projects/BimodalLogic/specs/literature-index.json`
- `/home/benjamin/Projects/BimodalLogic/.claude/context/project/literature/patterns/chunk-file-conventions.md`
- `/home/benjamin/Projects/BimodalLogic/.claude/scripts/literature-normalize-authors.sh`
