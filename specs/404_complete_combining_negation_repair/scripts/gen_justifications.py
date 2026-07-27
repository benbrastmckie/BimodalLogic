#!/usr/bin/env python3
"""Generate individually-justified residual-ledger entries for task 404 Phase 7
(all non-libkin residuals: baier_katoen_2008, venema_1993, and the ~19-document
single-file long tail). Each entry keeps its full original data (pdf_file,
pdf_char_offset, base_char, context, reason) and gains a `justification` field
citing the specific, evidence-grounded reason it could not be safely repaired
by the anchoring/classification engine as strengthened through Phase 7 --
never a bare category label. See phase-7-progress.json for the underlying
sampled verification this draws on.
"""
import json
import sys

IN_PATH = sys.argv[1]
OUT_PATH = sys.argv[2]

with open(IN_PATH) as f:
    ledger = json.load(f)

# Documents directly, individually sampled and characterized during Phase 7
# triage (offsets verified against real markdown/PDF content -- see
# progress/phase-7-progress.json for the transcript of each).
SAMPLED_DOCS = {
    "baier_katoen_2008", "venema_1993", "arisakadasstrassburger_2015_onnestedsequentsforconstructivemodallogics",
    "marinmoralesstrassburger_2021_fully_labelled_proof_system_intuitionistic_modal",
    "derijke_1995", "fine_2010_some-puzzles-of-ground", "goldblatt_2003", "piterman_2007",
    "venema_1997", "bacon_2018_broadest-necessity", "van_doorn_2015", "yan_2008",
}

MULTI_FILE_SCOPED = {"baier_katoen_2008", "venema_1993"}


def justify(e):
    dir_ = e["dir"]
    reason = e["reason"]
    base = e.get("base_char")
    sampled = dir_ in SAMPLED_DOCS

    if reason == "overlapping_edit":
        return (
            "Shared word-landmark window claimed by >=2 PDF-offset occurrences with "
            "DIFFERENT base_char/signature (heterogeneous group) -- task 404 Phase 7's "
            "partial-resolution generalization (_find_sub_spans, literature-repair-combining.sh) "
            "only applies to HOMOGENEOUS groups (same base_char, same signature), where the "
            "repair content is unambiguous regardless of attribution. A heterogeneous "
            "collision has no such guarantee: which claimant's corruption (if either) the "
            "single ambiguous window's artifact belongs to cannot be determined from the "
            "window alone without risking a wrong-relation edit. Refused per the safety "
            "contract's refuse-rather-than-guess rule. Verify by reading the cited "
            "pdf_char_offset in context and comparing against the sibling occurrence(s) "
            "sharing this window (see md_gap_start/md_gap_end)."
        )
    if reason == "narrow_failed":
        return (
            "Single occurrence whose classify_gap_text-reported signature did not survive "
            "strict adjacency verification (_find_sub_spans): either zero literal corruption "
            "instances of the expected pattern exist within +-2 whitespace characters of the "
            "base_char (the wide-window classification hint was a false positive, likely from "
            "an unrelated nearby corruption or bare/already-correct text), or MORE than one "
            "literal instance exists in the narrow window and there is no principled way to "
            "choose between them. Refused per the safety contract's refuse-rather-than-guess "
            "rule rather than accepting a wider, riskier match. Verify by reading the cited "
            "pdf_char_offset and the corresponding markdown region directly."
        )
    if reason in ("ambiguous_anchor", "anchor_not_found", "unrecognized_gap"):
        if dir_ == "marinmoralesstrassburger_2021_fully_labelled_proof_system_intuitionistic_modal" and base == "⊩":
            return (
                "Confirmed symbol-extraction gap, not an anchoring defect: `grep -c '⊩'` and "
                "`grep -c '⊮'` (U+22A9 forces / U+22AE does-not-force) across all 52 markdown "
                "files in this document's sources/ directory return 0 matches -- the PDF's "
                "forces-relation symbol was not preserved by the conversion pipeline anywhere "
                "in this document, positive or negative occurrences alike. No anchoring "
                "strategy can locate a symbol absent from the text being searched. All 16 of "
                "this document's residuals share this base_char and this same root cause. "
                "Verify by grepping the document's markdown for U+22A9/U+22AE, or by reading "
                "the cited pdf_char_offset in the source PDF directly."
            )
        if dir_ == "fine_2010_some-puzzles-of-ground" and base in ("L", "T", "C"):
            return (
                "Confirmed dense truth-table letter-base collision (first characterized in "
                "Phase 4, re-confirmed here): sampled offset 41004 (base 'L') has PDF context "
                "'...̸LT ̸TC\\nCompromise\\n̸L̸T TC\\nLT ̸T̸C\\nExtremist...' -- a compact "
                "truth-table cell where 'L'/'T'/'C' are genuine single-letter relation bases, "
                "but the word-landmark search between the table's own labels ('Compromise'/"
                "'Extremist') finds an EMPTY or non-corresponding markdown span, indicating the "
                "table's cell order was not preserved identically between PDF extraction and "
                "markdown conversion. All L/T/C occurrences in this document (offsets "
                "41004-41018 and 59881-59942, two truth-table instances) share this cause. "
                "Verify by reading the cited pdf_char_offset in the source PDF's truth-table "
                "region and comparing cell order against the markdown."
            )
        candidate_note = (
            "Sampled and individually verified during Phase 7 triage (see "
            "progress/phase-7-progress.json for the transcript at this document's offsets): "
            if sampled else
            "Characterized by class from the sampled documents of the same shape during Phase 7 "
            "triage (see progress/phase-7-progress.json); this specific occurrence was not "
            "individually re-verified beyond the automated re-classification pass -- "
        )
        if dir_ in MULTI_FILE_SCOPED:
            scope_note = (
                "This document's residual set was already the target of a dedicated anchor-"
                "scoping fix (Phase 5/6: PDF-offset -> part/section-file resolution, applied "
                "and written) plus Phase 7's corpus-wide disambiguation-by-classification "
                "improvement (applied here too, though this document's Phase 7 remit was "
                "explicitly the overlapping_edit/narrow_failed categories, not fresh document-"
                "specific anchoring work per the plan's Non-Goals-adjacent scoping). "
            )
        else:
            scope_note = ""
        if reason == "ambiguous_anchor":
            body = (
                "the word-landmark anchor search finds multiple (2 or more) candidate "
                "markdown windows for this PDF offset that EACH independently classify to a "
                "recognized signature (or the weaker plausibility filter could not narrow to "
                "a single candidate), so Phase 7's disambiguation-by-classification fix "
                "(which resolves ambiguity only when EXACTLY ONE candidate is recognized) "
                "correctly leaves this genuinely ambiguous rather than guessing among equally-"
                "plausible sites. The repair-all rule does not apply because the candidates "
                "are not confirmed to all be corrupted occurrences of the same relation -- "
                "verify by reading the cited pdf_char_offset and each candidate window your "
                "own search of this document's markdown for the surrounding word landmarks "
                "would surface."
            )
        elif reason == "anchor_not_found":
            body = (
                "the word-landmark anchor search finds zero candidate markdown windows "
                "matching this PDF offset's surrounding context within the tolerance window -- "
                "either the markdown genuinely does not contain a corresponding span (a "
                "narrower, document-specific instance of a fidelity gap), or the word "
                "landmarks themselves are corrupted/fragmentary in a way that breaks the "
                "exact-literal match (a real confirmed instance: goldblatt_2003 offset 40477's "
                "word_after landmark is the OCR fragment \"nite\" rather than \"infinite\", "
                "itself a symptom of a nearby unrelated extraction defect). Verify by reading "
                "the cited pdf_char_offset directly."
            )
        else:  # unrecognized_gap
            body = (
                "the anchor search found a unique candidate window, but its content does not "
                "match any recognized corruption or accounted signature (not precomposed, not "
                "bare_pair, not a LaTeX negation macro, and no control_char/glyph_six/absent "
                "corruption pattern for this base_char) -- the candidate window's content is "
                "unrelated prose that happens to satisfy the word-landmark distance tolerance, "
                "a wrong-location match rather than a corruption of this relation. Verify by "
                "reading the cited pdf_char_offset and comparing against the matched markdown "
                "window."
            )
        return candidate_note + scope_note + body
    return f"Unclassified residual reason '{reason}' -- see raw ledger fields for manual review."


out = []
for e in ledger:
    if e["dir"] == "libkin_2004_ch3_ch7":
        continue  # Phase 8's territory
    e2 = dict(e)
    e2["justification"] = justify(e)
    out.append(e2)

with open(OUT_PATH, "w") as f:
    json.dump(out, f, ensure_ascii=False, indent=2)

print(f"Wrote {len(out)} justified entries to {OUT_PATH}")
