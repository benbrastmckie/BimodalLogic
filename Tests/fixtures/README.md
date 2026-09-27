# Tests/fixtures/

Committed data files that a test reads with `include_str`, or that a consumer outside this
repository compares against.

The distinction from `data/` matters: `data/` is gitignored in its entirety (the datasets it holds
are large and are distributed through Hugging Face Hub instead), so nothing in it can serve as a
shared artifact. A conformance fixture has to be obtainable from git by whoever is conforming to it,
so it lives here.

## Contents

| File | Lines | Read by | Purpose |
|------|------:|---------|---------|
| `sentence-translation-fixtures.jsonl` | 26 | `../BimodalToolsTest/SentenceCodecTest.lean` | The source-sentence elimination's cross-repository conformance list: `surface`, `kind`, `sentence`, `formula` per line. The wire schema and the hand-off contract are in `../../BimodalTools/README.md`; the elimination table is in `../../FormalSystem/SourceLanguage/README.md` |

## Regenerating `sentence-translation-fixtures.jsonl`

The file is **generated**, never hand-edited: every line's `sentence` and `formula` fields are the
output of `FormalSystem.SourceLanguage.Sentence.toJson` and `Formula.toJson` on the same term, so
the file is byte-canonical with respect to those two serializers by construction, and
`SentenceCodecTest.lean` asserts exactly that (its Row 5 rebuilds each line from the parsed parts
and compares bytes).

To add a row, extend the fixture list and re-emit with `Sentence.toJson` / `Formula.toJson` rather
than writing JSON by hand, then update the count `#guard` in `SentenceCodecTest.lean`.

---

*Last verified: 2026-09-27*
