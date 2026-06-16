# Research Report: Task #738

**Task**: 738 - Refactor BimodalLogic specs/literature/ to sources/ structure and remove blackburn_2001
**Started**: 2026-06-16T00:00:00Z
**Completed**: 2026-06-16T00:15:00Z
**Effort**: ~1h (straightforward filesystem + index.json surgery)
**Dependencies**: None
**Sources/Inputs**: Codebase exploration of ~/Projects/BimodalLogic/specs/literature/, ~/Projects/Literature/
**Artifacts**: - This report
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- The BimodalLogic `specs/literature/` directory is already deprecated (superseded by `~/Projects/Literature/` per DEPRECATED.md); the refactor aligns the fallback directory with the central repo's `sources/` structure.
- The root `index.json` has exactly 30 entries; NONE reference `blackburn_2001` (only `blackburn_2002`). The `blackburn_2001/` directory has its own sub-`index.json` with 33 chapters—these are not in the root index.
- Five sources need new `sources/{id}/` directories created; the remaining 25 correspond to existing subdirectories that get moved into `sources/`.
- The global `~/Projects/Literature/.literature.db` is already present and the retrieve script uses it (Tier 1 mode), so the legacy path resolution in `literature-retrieve.sh` is NEVER exercised—no retrieve script changes needed.

---

## Context & Scope

The BimodalLogic project at `~/Projects/BimodalLogic/` has a `specs/literature/` directory that was migrated to the centralized `~/Projects/Literature/` repo on task 710. A `DEPRECATED.md` was written at that time noting that `specs/literature/` is now a read-only fallback. The central repo already uses a `sources/{id}/` subdirectory layout. This task refactors the local fallback to match that layout, removes the `blackburn_2001/` directory (which was never referenced from the root `index.json` and has been superseded by `blackburn_2002/` in the central repo), and updates index paths.

---

## Findings

### Q1: How many index.json entries reference blackburn_2001?

**Answer: Zero.** The root `specs/literature/index.json` has exactly 30 entries. None have an `id` or `path` starting with `blackburn_2001`. The one blackburn entry is:
- `id: "blackburn_2002"`, `path: "Blackburn_deRijke_Venema_2002_Modal_Logic.md"`

The `blackburn_2001/` directory has its own `index.json` (different schema: `book`, `chapters[]` array format with 33 chapter entries, not the `entries[]` format). These chapter entries are discovered by the legacy retrieve script via the `find -maxdepth 2 -name "index.json"` scan, but since Tier 1 (global DB) is always active, this code path is not used in practice.

### Q2: Full inventory of loose markdown files needing individual sources/ dirs

The 30 loose markdown files (excluding README.md and DEPRECATED.md) and their target `sources/` directory names:

| Loose File | Target sources/{id}/ dir | Existing subdir? |
|-----------|--------------------------|-----------------|
| Blackburn_deRijke_Venema_2002_Modal_Logic.md | `sources/blackburn_2002/` | NO — create new |
| Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md | `sources/burgess_1982/` | YES — move into |
| Burgess_1982b_Axioms_for_tense_logic_II_Time_periods.md | `sources/burgess_1982b/` | YES — move into |
| Burgess_1984_Basic_Tense_Logic.md | `sources/burgess_1984/` | YES — move into |
| Caleiro_Vigano_Volpe_2013_Mosaic_Method_Tense_Modal.md | `sources/caleiro_2013/` | YES — move into |
| deRijke_Venema_1995_Sahlqvist_BAOs.md | `sources/derijke_1995/` | YES — move into |
| Doets_1987_Completeness_and_Definability_thesis.md | `sources/doets_1987/` | YES — move into |
| Doets_1989_Monadic_Pi11_Theories.md | `sources/doets_1989/` | YES — move into |
| Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md | `sources/gabbay_1993/` | YES — move into |
| Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md | `sources/gabbay_1994/` | YES — move into |
| Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md | `sources/gabbay_1994/` | YES — move into |
| Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md | `sources/gabbay_1994/` | YES — move into |
| Goldblatt_Hodkinson_Venema_2003_BAOs_Modal_Logic.md | `sources/goldblatt_2003/` | YES — move into |
| Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.md | `sources/hodkinson_2006/` | NO — create new |
| Libkin_2004_Elements_Finite_Model_Theory_ch3_ch7.md | `sources/libkin_2004_ch3_ch7/` | NO — create new |
| Obendrauf_2024_Lean_Formalization_Coalition_Logic.md | `sources/obendrauf_2024/` | YES — move into |
| Rabinovich_2014_Proof_of_Kamps_Theorem.md | `sources/rabinovich_2014/` | NO — create new |
| Reynolds_1992_Axiomatization_Until_Since_without_IRR.md | `sources/reynolds_1992/` | YES — move into |
| Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md | `sources/reynolds_1994/` | YES — move into |
| Reynolds_2001_Axiomatization_Full_CTL_star.md | `sources/reynolds_2001/` | YES — move into |
| Thomas_1997_EF_Games_Composition_Monadic.md | `sources/thomas_1997/` | NO — create new |
| Thomason_1984_Combinations_of_Tense_and_Modality.md | `sources/thomason_1984/` | YES — move into |
| Venema_1991_Many_Dimensional_Modal_Logics_ch2.md | `sources/venema_1991/` | YES — move into |
| Venema_1991_Many_Dimensional_Modal_Logics_app_A_B.md | `sources/venema_1991/` | YES — move into |
| Venema_1993_Derivation_Rules_Anti_Axioms.md | `sources/venema_1993/` | YES — move into |
| Venema_1993_Since_and_Until.md | `sources/venema_1993_since/` | YES — move into |
| Venema_1997_Atom_Structures_Sahlqvist.md | `sources/venema_1997/` | YES — move into |
| Venema_2001_Temporal_Logic_Survey.md | `sources/venema_2001/` | YES — move into |
| Verbrugge_2004_Completeness_by_construction.md | `sources/verbrugge_2004/` | YES — move into |
| Xu_1988_On_some_US_tense_logics.md | `sources/xu_1988/` | YES — move into |

**New directories to create (5):**
- `sources/blackburn_2002/`
- `sources/hodkinson_2006/`
- `sources/libkin_2004_ch3_ch7/`
- `sources/rabinovich_2014/`
- `sources/thomas_1997/`

**Existing subdirs to move into sources/ (22, excluding blackburn_2001):**
burgess_1982, burgess_1982b, burgess_1984, caleiro_2013, derijke_1995, doets_1987, doets_1989, gabbay_1993, gabbay_1994, goldblatt_2003, obendrauf_2024, reynolds_1992, reynolds_1994, reynolds_2001, thomason_1984, venema_1991, venema_1993, venema_1993_since, venema_1997, venema_2001, verbrugge_2004, xu_1988

### Q3: Which loose markdown files correspond to which subdirectories (PDF co-location)

Three loose PDFs need to move alongside their markdown files:

| Loose PDF | Target dir |
|-----------|-----------|
| `Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.pdf` | `sources/hodkinson_2006/` |
| `Libkin_2004_Elements_Finite_Model_Theory_ch3_ch7.pdf` | `sources/libkin_2004_ch3_ch7/` |
| `Rabinovich_2014_Proof_of_Kamps_Theorem.pdf` | `sources/rabinovich_2014/` |

These three PDFs currently live loose at `specs/literature/` root (gitignored via `specs/literature/*.pdf` pattern, which will need updating since after the move PDFs will be at `specs/literature/sources/*/*.pdf`).

### Q4: References from other BimodalLogic files into specs/literature/

Files outside `specs/literature/` that reference `specs/literature/`:
- **`.claude/` scripts and skills**: `literature-retrieve.sh`, `literature-search.sh`, `skill-researcher/SKILL.md`, `skill-implementer/SKILL.md`, `skill-planner/SKILL.md`, `skill-cite/SKILL.md`, `skill-literature/SKILL.md`, `literature-agent.md`, `commands/cite.md`, `commands/literature.md`, `extensions/literature/manifest.json` — all reference the *directory* `specs/literature/`, not specific file paths inside it.
- **`specs/` task artifacts**: worktree copies and old plan files reference specific paths, but these are historical records and don't need updating.
- **`specs/state.json`**: references `specs/literature/` as the directory.
- **`.gitignore`**: has `specs/literature/*.pdf` — this pattern covers the 3 loose PDFs currently but will NOT cover `specs/literature/sources/*/*.pdf` after the move. The gitignore will need `specs/literature/sources/**/*.pdf` added.

**No references to specific file paths within `specs/literature/`** from active non-deprecated scripts. All references are to the directory itself, which doesn't change.

### Q5: What does the BimodalLogic .gitignore say about literature files?

```
# Literature PDFs (large binary files)
literature/*.pdf
specs/literature/*.pdf
```

These glob patterns only cover PDFs directly under `specs/literature/`. After the refactor, PDFs will be at `specs/literature/sources/hodkinson_2006/*.pdf` etc. The `.gitignore` will need a new pattern: `specs/literature/sources/**/*.pdf`.

### Critical Compatibility Finding: Tier 1 Mode Always Active

The `literature-retrieve.sh` script operates in two modes:
- **Tier 1** (FTS5 database present): Uses `~/.literature.db` or global `~/Projects/Literature/.literature.db`
- **Tier 2** (legacy): Reads `index.json` files directly from `specs/literature/`

Since `~/Projects/Literature/.literature.db` exists, BimodalLogic's `literature-retrieve.sh` ALWAYS operates in Tier 1 mode. The legacy Tier 2 code (which discovers subdirectory `index.json` files at `maxdepth 2`) is never executed. This means:
1. The `maxdepth 2` limitation (would fail to find `sources/{id}/index.json` at depth 3) is irrelevant.
2. No changes to `literature-retrieve.sh` or `literature-search.sh` are needed.
3. The root `index.json` path updates are still needed as it's the primary metadata source for non-DB operations and human reference.

---

## Implementation Plan Summary

The refactor is a mechanical filesystem move + index.json path update:

### Step 1: Create sources/ directory
```bash
mkdir -p specs/literature/sources/
```

### Step 2: Move 22 existing subdirs into sources/
```bash
for dir in burgess_1982 burgess_1982b burgess_1984 caleiro_2013 derijke_1995 \
  doets_1987 doets_1989 gabbay_1993 gabbay_1994 goldblatt_2003 obendrauf_2024 \
  reynolds_1992 reynolds_1994 reynolds_2001 thomason_1984 venema_1991 venema_1993 \
  venema_1993_since venema_1997 venema_2001 verbrugge_2004 xu_1988; do
  mv specs/literature/$dir specs/literature/sources/$dir
done
```

### Step 3: Remove blackburn_2001/
```bash
rm -rf specs/literature/blackburn_2001/
```

### Step 4: Create 5 new source directories and move loose files + PDFs
- `sources/blackburn_2002/`: move `Blackburn_deRijke_Venema_2002_Modal_Logic.md`
- `sources/hodkinson_2006/`: move `Hodkinson_Reynolds_2006...md` + `.pdf`
- `sources/libkin_2004_ch3_ch7/`: move `Libkin_2004...md` + `.pdf`
- `sources/rabinovich_2014/`: move `Rabinovich_2014...md` + `.pdf`
- `sources/thomas_1997/`: move `Thomas_1997...md`

### Step 5: Move 25 loose MDs into their respective sources/{id}/ dirs
(Each loose MD moves into the corresponding existing sources/ subdir, per the table in Q2.)

### Step 6: Update root index.json paths
All 30 `path` values in the root `index.json` need `sources/` prefix. Examples:
- `"Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md"` → `"sources/burgess_1982/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md"`
- `"Blackburn_deRijke_Venema_2002_Modal_Logic.md"` → `"sources/blackburn_2002/Blackburn_deRijke_Venema_2002_Modal_Logic.md"`

Note: The root index.json has NO `blackburn_2001` entries to remove.

### Step 7: Update README.md
Update any path references in `README.md` table (file column uses bare filenames without directory prefix — these would need updating if the README links to specific files).

### Step 8: Update .gitignore
Add `specs/literature/sources/**/*.pdf` to cover PDFs in new structure.

---

## Decisions

- **README.md**: The README file column currently lists bare filenames like `Burgess_1982_Axioms_for_tense_logic_Since_and_Until`. After the refactor, these are still valid as human-readable identifiers (not paths), so README may not need path updates—the plan should verify whether README uses these as paths or just descriptions.
- **subdir index.json files**: No changes needed; they stay within their moved directories and use file-relative paths.
- **`obendrauf_2024/` directory**: Has no PDF (open access HTML only). Its loose MD moves into `sources/obendrauf_2024/` alongside the existing chunked content.
- **`gabbay_1994/` directory**: Has a large PDF + Vol2 PDF inside. All stay within the moved `sources/gabbay_1994/` dir.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| gitignore not covering PDFs in sources/ | Add `specs/literature/sources/**/*.pdf` to `.gitignore` |
| README references to paths becoming stale | Check README file column entries; they use bare filenames as descriptions, likely not actual paths |
| Loose MDs landing in wrong sources/ dir for multi-file sources (gabbay_1994 has 3 MDs) | All 3 gabbay_1994 chapter MDs move to `sources/gabbay_1994/` (one dir, three files) |
| venema_1991 has 2 loose MDs | Both move to `sources/venema_1991/` alongside the existing chunked content |
| blackburn_2001 removal being irreversible | Confirm task intent; it's gitignored (no PDF in git) and only has ch*.md chunks + PDF not in git |

---

## Appendix: File Counts

- Loose MDs to distribute: 30
- Existing subdirs to move: 22 (excluding blackburn_2001)
- blackburn_2001 to delete: 1 dir with 36 files (34 ch*.md + index.json + PDF, PDF not tracked)
- New dirs to create: 5 (blackburn_2002, hodkinson_2006, libkin_2004_ch3_ch7, rabinovich_2014, thomas_1997)
- root index.json entries to update: 30 (add `sources/{dir}/` prefix to each path)
- root index.json entries to remove: 0 (blackburn_2001 not in root index)
- .gitignore lines to add: 1
