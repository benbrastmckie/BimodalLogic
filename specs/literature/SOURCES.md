# Literature Sources

Discovered via `/literature` Mode A (three-tier source discovery). Status progression:
`[PENDING]` -> `[IN_ZOTERO]` -> `[FOUND]` -> `[RESOLVED]`. Entries marked `[PAYWALL]` require
manual acquisition. `[RESOLVED]` means fully imported: Zotero item + PDF + corpus chunks +
sub-index entry.

| Title | Authors | Year | DOI | Status | Notes |
|-------|---------|------|-----|--------|-------|
| Boolean Algebras with Operators. Part I | Jónsson, Tarski | 1951 | 10.2307/2372123 | [RESOLVED] | doc_id: `j_nsson_and_tarski_-_1951_-_boolean_algebras_with_operators._part_i` (ingested via online-ingest bridge; 85 chunks). Amer. J. Math. 73, 891-939. Primary source for the representation theorem. |
| Boolean Algebras with Operators. Part II | Jónsson, Tarski | 1952 | 10.2307/2372074 | [RESOLVED] | doc_id: `j_nsson_and_tarski_-_1952_-_boolean_algebras_with_operators._part_ii` (ingested via online-ingest bridge; 82 chunks). Amer. J. Math. 74, 127-162. |
| Mathematical modal logic: A view of its evolution | Goldblatt | 2006 | 10.1016/S1874-5857(06)80027-0 | [RESOLVED] | doc_id: `goldblatt_-_mathematical_modal_logic_a_view_of_its_evolution` (199 chunks). Required the fallback converter (`LITERATURE_CONVERTER=pymupdf`); the default pymupdf4llm tier failed the quality gate. Spot-checked: word ratio 0.979 vs pdftotext over 98 pages, symbols and footnotes preserved, zero genuine fusion artifacts. |
| Many-Dimensional Modal Logics: Theory and Applications | Gabbay, Kurucz, Wolter, Zakharyaschev | 2003 | — | [BLOCKED] | zotero: `Kurucz2003` (item key XYYBJH2N), North-Holland. **The PDF is not text-extractable by any available tool** — it carries a broken/custom font encoding with no usable ToUnicode CMap. pdftotext yields scrambled glyphs (69.5% printable); pymupdf4llm was rejected by the quality gate; the pymupdf fallback tier produced control-character mojibake that PASSED the gate and had to be removed from the corpus. Needs OCR (or a different copy of the PDF) before it can be ingested. Do NOT retry with the fallback converter. |
