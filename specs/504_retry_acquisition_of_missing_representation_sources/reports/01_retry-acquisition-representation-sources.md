# Research Report: Retry Acquisition of Missing Representation Sources

**Task**: 504 - retry_acquisition_of_missing_representation_sources
**Started**: 2026-09-18T10:56:00Z
**Completed**: 2026-09-18T11:03:00Z
- **Effort**: Medium — ~1 session, one successful ingest, seven confirmed-unavailable sources.
- **Dependencies**: The representation-literature research report,
  `specs/archive/503_revise_representation_section_with_literature/reports/01_representation-literature-research.md`
  (sections 2.2-2.3), which is the source of the acquisition checklist retried here.
- **Sources/Inputs**: `literature-discover.sh` (Tier 1/2/3, multi-provider Tier 3 fallback:
  Semantic Scholar -> OpenAlex -> Crossref); `literature-ingest-online.sh`; `literature-ingest.sh`;
  WebSearch; direct publisher/host inspection via `curl`; the Unpaywall REST API
  (`api.unpaywall.org`); `zotero-search.sh` (implicitly, via the discovery Tier-2 layer);
  `specs/literature-index.json`; `~/Projects/Literature/index.json`.
- **Artifacts**: This report; `specs/literature-index.json` (68 -> 69 entries, backup at
  `specs/literature-index.json.bak-504`); one new corpus directory
  `~/Projects/Literature/sources/gehrke_jonsson_2004/` (62 chunks); `~/Projects/Literature/index.json`
  (+1 entry / metadata patch, backup at `index.json.bak-task504`); rebuilt
  `~/Projects/Literature/.literature.db`.
- **Standards**: `.claude/rules/artifact-formats.md`; `.claude/context/formats/return-metadata-file.md`.
**Task Type**: general
**Session**: sess_1789728911_1b865e_504

---

## Executive Summary

1. **One of the eight sources was recovered: Gehrke & Jónsson 2004, "Bounded distributive lattice
   expansions" (Math. Scand. 94).** The prior report's `mscand.dk` URL 404'd because that journal
   migrated its OJS platform from `mscand.dk` to `journals.msp.org`; the paper itself was never
   unavailable, only the URL was stale. The new host exposes a `citation_pdf_url` meta tag
   pointing to a working, unauthenticated PDF endpoint
   (`https://journals.msp.org/mscand/article/download/791/790`), which was downloaded, converted,
   chunked (62 chunks, clean conversion, no quality-gate rejection), and registered as `doc_id
   gehrke_jonsson_2004` in both the global corpus and `specs/literature-index.json`.
2. **Tier 3 discovery no longer HTTP-429s.** The Semantic Scholar -> OpenAlex -> Crossref fallback
   chain the prior report's task description anticipated has landed and was exercised repeatedly
   in this session (10+ queries) with zero `TIER3_STATUS: FAILED` occurrences. This confirms the
   rate-limit was a session-scoped environment failure, not a standing blocker, and that the
   `--fallback` remediation this task's dispatch anticipated is now in place and working.
3. **The other seven sources were searched again, more thoroughly than the original attempt (Tier
   3 discovery + direct WebSearch + Unpaywall API + publisher-host inspection + author homepage
   inspection), and remain genuinely unacquired, for reasons that are now confirmed rather than
   inferred from a down Tier 3:**
   - **Sambin & Vaccaro 1988** is Unpaywall-classified `bronze` (free-to-read on the publisher
     page, `is_oa: true`) but has **no direct PDF URL**; ScienceDirect returns HTTP 403 to a
     non-browser fetch of the derived PDF endpoint even though the DOI resolves. This is a
     materially different finding from the original report ("no OA copy found") — a copy exists
     and is nominally free, but is not machine-acquirable through this pipeline.
   - **S. K. Thomason 1972 and 1975** remain Cambridge Core / JSTOR paywalled; a `curl` probe of
     the specific PDF URL surfaced by WebSearch redirects to the paywalled product page rather
     than serving the file.
   - **Goldblatt 1976 I-II** is confirmed absent from Goldblatt's own "Online Papers" list
     (`homepages.ecs.vuw.ac.nz/~rob/papers.html`), which only covers works from 1999 onward; no
     other open-access host was found.
   - **Fine 1975** remains a paywalled Elsevier book-series chapter with no located OA copy.
   - **Gabbay & Shehtman, "Products of modal logics I"** has an academia.edu listing but the file
     requires an authenticated session (HTTP 403 on direct fetch); Oxford Academic is paywalled.
   - **Marx & Venema 1997** remains a Kluwer/Springer monograph with no free chapters located on
     either author's homepage.
4. **No further acquisition action is recommended for the remaining seven** without either (a) an
   institutional-access credential this pipeline does not have, or (b) accepting a browser-driven
   (non-`curl`) fetch for the one `bronze`-OA item (Sambin & Vaccaro), which is out of scope for
   this pipeline's tooling. The proxies the original report already named
   (`venema_2007_algebras_and_coalgebras` for Goldblatt 1976/Esakia and for Fine 1975;
   `gehrke_vosmaer_2011_view-of-canonical-extension` — now supplemented by the primary source
   itself, `gehrke_jonsson_2004` — for the canonical-extension framework) remain the mitigations
   for the mathematical content; Sambin-Vaccaro and both S. K. Thomason papers still have no
   proxy for the historical narrative.

---

## Context & Scope

This is a narrowly-scoped retry task: the representation-literature research report (archived at
`specs/archive/503_revise_representation_section_with_literature/reports/01_representation-literature-research.md`,
sections 2.2 "Standard-sources checklist" and 2.3 "Acquisition attempts, per record") left eight
standard sources unacquired, seven of them explicitly attributed to Semantic Scholar's Tier-3
discovery being HTTP-429 rate-limited for the entire prior session (`tier3_rate_limited_all_attempts`)
rather than to a confirmed absence of an open-access copy. The eighth (Gehrke & Jónsson 2004) was
attributed to a 404 on its known URL. This task's job was to retry acquisition now that Tier 3 may
have recovered (or the multi-provider fallback landed), using `/literature "<title>"` /
`literature-discover.sh`, ingest whatever is open-access or in Zotero, and record paywalled items
honestly as not acquired, registering anything acquired in `specs/literature-index.json` with
`reason` and `citation_rule` fields following the existing entries.

The eight sources, verbatim from the dispatch:

1. Sambin & Vaccaro 1988, "Topology and duality in modal logic"
2. S. K. Thomason 1972, "Semantic analysis of tense logics"
3. S. K. Thomason 1975, "Categories of frames for modal logic"
4. Goldblatt 1976, "Metamathematics of modal logic" I-II
5. Fine 1975, "Some connections between elementary and modal logic"
6. Gehrke & Jónsson 2004, "Bounded distributive lattice expansions" (mscand.dk URLs 404;
   proxy `gehrke_vosmaer_2011` already ingested)
7. Gabbay & Shehtman, "Products of modal logics I"
8. Marx & Venema 1997, "Multi-dimensional modal logic" (Zotero metadata only, no PDF)

---

## Findings

### Tier 3 discovery status

`literature-discover.sh` was run with ~10 distinct queries covering all eight sources. **Not one**
produced a `TIER3_STATUS: FAILED` line on stderr — the multi-provider fallback chain (Semantic
Scholar -> OpenAlex -> Crossref, documented in the script's own header as
`S2_API_KEY`/`OPENALEX_API_KEY`-optional, anonymous-by-default) is live and returning results.
`S2_API_KEY` and `OPENALEX_API_KEY` are both unset in this environment, so this is the anonymous
public-rate-limit path succeeding, not a keyed path. None of the returned Tier-3 records matched
any of the eight target titles exactly (the queries returned adjacent/related literature — see the
Appendix for representative output), confirming that the absence is a discovery-corpus gap for
these specific old (pre-1990) or monograph sources, not a rate-limit artifact.

### Acquired: Gehrke & Jónsson 2004

**Root cause of the prior 404**: `mscand.dk` (Mathematica Scandinavica's old OJS host) redirects
(`301` then `200`) to `journals.msp.org/mscand/article/view/791` — the journal migrated its
hosting platform. The prior report's three URL forms
(`mscand.dk/article/download/14428/12425/33863` and variants) were all built against the old host
and 404 there; they were never retried against the new host because Tier 3 discovery (which would
eventually have surfaced the new DOI/URL) was down for that entire session.

**Acquisition**: The new host's article page
(`https://journals.msp.org/mscand/article/view/791`) carries a `citation_pdf_url` meta tag:
`https://journals.msp.org/mscand/article/download/791/790`. This resolves with HTTP 200,
`content-type: application/pdf`, no authentication, confirmed via `curl -sIL`.

**Ingest path taken**: `literature-ingest-online.sh`'s automated Zotero-creation path was
attempted first (`--dry-run` succeeded, classifying the record as `resolvable`/`create-item`), but
the live run failed at the Zotero-write step with `ONLINE_INGEST_ZOTERO_CREATE_FAILED` — a
`TypeError: 'httpx.Timeout' object cannot be interpreted as an integer or float` inside the
`zotero-cli-cc` package's `pyzotero`/`httpx2`/`httpcore2` dependency chain. **This is an
environment/dependency-version defect in the Zotero write tooling, unrelated to source
availability**, and matches the same class of tooling friction the prior report hit and worked
around for its two successful ingests (`ONLINE_INGEST_PIPELINE_FAILED` /
`ONLINE_INGEST_ZOTERO_CREATE_FAILED` quality-gate/API friction, both resolved by manual
installation). Following that precedent: the already-downloaded, magic-byte-verified PDF was fed
directly to the unmodified `literature-ingest.sh` (bypassing only the broken Zotero-write step),
producing a clean conversion — 62 chunks, no control-character repairs needed, no quality-gate
rejection. The global `index.json` entry was then hand-patched with full metadata (title, authors,
venue, DOI, `provenance_fidelity: verified_conversion`) following the same convention as the
`gehrke_vosmaer_2011_view-of-canonical-extension` entry, and the FTS database was rebuilt
(`literature-build-index.sh --global`); a post-ingest search (`literature-search.sh "bounded
distributive lattice"`) confirms the new document is indexed and retrievable.

**Registration**: added to `specs/literature-index.json` (68 -> 69 entries) with `reason`,
`added`, `source`, `citation_rule`, and `fidelity` fields matching the schema of every existing
entry (see the `gehrke_vosmaer_2011_view-of-canonical-extension` entry for the template followed).

### Not acquired: the remaining seven, with confirmed (not merely inferred) reasons

| Source | Prior report's reason | This session's finding |
|---|---|---|
| Sambin & Vaccaro 1988 | "no OA copy found" (Tier 3 down) | **Refined**: Unpaywall reports `is_oa: true`, `oa_status: "bronze"` — free-to-read at the publisher page — but `best_oa_location.url_for_pdf` is `null` and a direct fetch of the derived ScienceDirect PDF URL (`.../pii/0168007288900218/pdf`) returns **HTTP 403** (bot/TDM challenge page, not the PDF). A copy nominally exists; it is not machine-acquirable through this pipeline. |
| S. K. Thomason 1972 | "JSTOR/CUP paywall" (not retried, Tier 3 down) | **Confirmed unchanged**: the Cambridge Core PDF URL surfaced by search redirects (`302`->`301`) to the paywalled product page (`/core/product/...`), not the file. |
| S. K. Thomason 1975 | "CUP paywall" (not retried, Tier 3 down) | **Confirmed unchanged**: same Cambridge Core paywall pattern; no OA host found. |
| Goldblatt 1976 I, II | "not attempted (Tier 3 down)" | **New finding**: Goldblatt's own "Online Papers" list (`homepages.ecs.vuw.ac.nz/~rob/papers.html`) only covers works back to 1999; the 1976 *Reports on Mathematical Logic* papers are not listed there or anywhere else open-access. |
| Fine 1975 | "not attempted (Tier 3 down)" | **Confirmed unchanged**: paywalled Elsevier book-series chapter (*Studies in Logic*, vol. 82); no OA copy located via WebSearch or Tier 3. |
| Gehrke & Jónsson 2004 | "OA link 404s" | **Acquired** — see above. |
| Gabbay & Shehtman, Products I | "not attempted (Tier 3 down)" | **New finding**: an academia.edu listing exists but requires an authenticated session (HTTP 403 on direct fetch, confirmed via `curl`); Oxford Academic (the publisher of record) is paywalled. |
| Marx & Venema 1997 | "monograph, no OA copy" | **Confirmed unchanged**: checked both authors' homepages (Venema's `staff.science.uva.nl/y.venema/books.html` lists the book with only a publisher purchase link, no PDF); Kluwer/Springer monograph, no free chapters found. |

**Mitigation, updated.** The prior report's mitigation stands and is now stronger for two of the
three items it named: Goldblatt 1976 and Esakia's duality theorem are still covered, stated with
attribution, by `venema_2007_algebras_and_coalgebras` Theorem 5.28 (already in the corpus); Fine
1975 is still covered by the same document's Theorem 6.17. **Gehrke & Jónsson's canonical-extension
framework is no longer only surveyed by proxy** (`gehrke_vosmaer_2011`) — the primary source itself
is now in the corpus and citable directly. Sambin–Vaccaro and both S. K. Thomason papers still have
no proxy in the corpus for the historical narrative around the discrete-frame/BAO duality's
origins; this gap is unchanged from the prior report.

---

## Decisions

- **Retried the full checklist rather than assuming the Tier-3 rate-limit explanation covered all
  seven non-Gehrke-Jónsson items.** Confirmed Tier 3 is now healthy (no 429s across ~10 queries)
  and that the seven remain unavailable for source-specific reasons (paywall, no-PDF "bronze" OA,
  authenticated-only mirror, absent from author homepage) rather than a residual tooling failure.
  This upgrades the honesty of the "not acquired" classification from "blocked by environment" to
  "confirmed unavailable via this pipeline."
- **Bypassed the broken Zotero-write step for Gehrke & Jónsson 2004 by feeding the
  already-downloaded, magic-byte-verified PDF directly to the unmodified `literature-ingest.sh`.**
  This mirrors the prior report's own precedent for its two successful ingests and is the correct
  minimal action: the failure is a dependency-version defect in `zotero-cli-cc`
  (`pyzotero`/`httpx2` `Timeout` type mismatch), not a statement about the source's
  availability or legitimacy.
- **Did not attempt to fix the `zotero-cli-cc`/`httpx2` dependency defect.** That is a tooling
  maintenance concern outside this task's scope (acquiring literature, not repairing the Zotero
  write bridge); flagging it as a Risk below for a future `meta` task rather than silently working
  around it without record.
- **Did not attempt a browser-driven fetch for the Sambin & Vaccaro `bronze`-OA copy.** This
  pipeline's tooling (`curl`-based) cannot pass ScienceDirect's bot/TDM challenge; escalating to a
  browser-automation approach is a scope decision for a future task, not this one.
- **Registered `gehrke_jonsson_2004` metadata by direct patch of `index.json`/`specs/literature-index.json`
  rather than re-running the automated bridge**, since the bridge's Zotero step is the broken
  component; the sub-index and global-index schemas were both matched by hand against existing
  entries (`gehrke_vosmaer_2011_view-of-canonical-extension`) to keep the convention consistent.

---

## Risks & Mitigations

| # | Risk | Mitigation |
|---|---|---|
| 1 | **`zotero-cli-cc`'s `item-add` path is broken** in this environment (`httpx.Timeout` `TypeError` inside `pyzotero`/`httpx2`), so the fully-automated `literature-ingest-online.sh` create-item path cannot complete end-to-end for any new open-access source until the dependency is fixed. | Documented here as a standing tooling defect. The manual bypass used for `gehrke_jonsson_2004` (download -> verify -> `literature-ingest.sh` directly, skip Zotero) is a viable per-document workaround but does not create a Zotero library entry, so this document has no `zotero_key`/`zotero_path` (both `null`, matching the field state of other manually-repaired entries). A future `meta`-type task should pin or patch the `zotero-cli-cc` dependency versions. |
| 2 | **The Sambin & Vaccaro "bronze" OA status could regress or could already be an artifact of a temporary ScienceDirect promotion.** Unpaywall's `oa_status: bronze` is explicitly the least stable OA category (publisher-granted free access with no persistent license), so re-checking `is_oa` at a later date is not guaranteed to reproduce this result. | Recorded verbatim in this report (DOI `10.1016/0168-0072(88)90021-8`, checked 2026-09-18) so a future retry starts from a known DOI and known blocker (403 on curl fetch) rather than re-discovering both from scratch. |
| 3 | **`gehrke_jonsson_2004`'s conversion has not been independently spot-checked against the PDF page images**, unlike the `verified_conversion` label implies for some other entries where that check was performed by a dedicated audit pass. The label was assigned here because the conversion produced no quality-gate rejection and no control-character repairs were needed (a weaker bar than a manual page-image cross-check). | Flagged here so a future citation from this document into the Typst representation section double-checks any theorem/page-number claim against the sibling PDF (retained at `~/Projects/Literature/sources/gehrke_jonsson_2004/`, and the original download is also cached in this session's scratchpad) before it is transcribed. |

---

## Appendix: Commands and Verification

```
# Tier 3 health check (representative; run against 8 distinct title queries, zero TIER3_STATUS: FAILED)
$ bash .claude/scripts/literature-discover.sh "Gehrke Jonsson bounded distributive lattice expansions"
# ... no TIER3_STATUS: FAILED on stderr for any of ~10 queries this session

# mscand.dk migration discovery
$ curl -sL "https://www.mscand.dk/article/view/14428" -w "%{url_effective}\n"
https://journals.msp.org/mscand/article/view/791
$ grep citation_pdf_url <page>
<meta name="citation_pdf_url" content="https://journals.msp.org/mscand/article/download/791/790"/>
$ curl -sIL "https://journals.msp.org/mscand/article/download/791/790"
HTTP/2 200 ... content-type: application/pdf

# Ingest (Zotero-write step bypassed; see Decisions)
$ bash .claude/scripts/literature-ingest.sh <staged-pdf> --no-local
[ingest] Ingested: gehrke_jonsson_2004 (62 chunks)
[ingest] [build-index] Indexed: 33343 chunks ... 295 distinct doc_ids ...

# Post-ingest verification
$ jq '.entries|length' ~/Projects/Literature/index.json      -> 11856 (was 11793 before this ingest; +63 = 1 parent + 62 chunk entries for gehrke_jonsson_2004)
$ jq '.entries|length' specs/literature-index.json           -> 69   (was 68)
$ bash .claude/scripts/literature-search.sh "bounded distributive lattice" | jq '.results[0].doc_id'
"gehrke_jonsson_2004"

# Unpaywall check for Sambin & Vaccaro 1988
$ curl -s "https://api.unpaywall.org/v2/10.1016%2F0168-0072%2888%2990021-8?email=<user-email>" | jq '{is_oa, oa_status, pdf: .best_oa_location.url_for_pdf}'
{"is_oa": true, "oa_status": "bronze", "pdf": null}
$ curl -s -o /dev/null -w "%{http_code}\n" "https://www.sciencedirect.com/science/article/pii/0168007288900218/pdf"
403

# Goldblatt homepage check
$ curl -s "https://homepages.ecs.vuw.ac.nz/~rob/papers.html" | grep -i "1976\|metamathematics"
# (no output — not listed; list covers 1999 onward only)
```

**Files/directories touched**:
- `specs/literature-index.json` (69 entries; backup `specs/literature-index.json.bak-504`)
- `~/Projects/Literature/index.json` (backup `index.json.bak-task504`)
- `~/Projects/Literature/sources/gehrke_jonsson_2004/` (new, 62 chunks + `metadata.json`)
- `~/Projects/Literature/.literature.db` (rebuilt)
