# Tests/fixtures/

Committed data files that a test reads with `include_str`, or that a consumer outside this
repository compares against.

The distinction from `data/` matters: `data/` is gitignored in its entirety (the datasets it holds
are large and are distributed through Hugging Face Hub instead), so nothing in it can serve as a
shared artifact. A conformance fixture has to be obtainable from git by whoever is conforming to it,
so it lives here.

**A shared artifact that cannot be obtained from git is not a shared artifact.** The ignore rules
are `data/*.jsonl` and `/data`; between them nothing under `data/` is trackable, so a fixture
placed there could never have been committed, however the plan that placed it was worded. The
alternative of punching a hole in the ignore rule — adding a negation so that one named file under
`data/` becomes trackable — was considered and **rejected**. The ignore rule is shared
configuration read by everyone who adds a file under `data/`, and an exemption buried in it is
invisible at exactly that moment: the next person to drop a dataset beside the exempted path gets
no signal that the directory is no longer uniformly ignored. A tracked path beside its reader
costs nothing by comparison, and it makes the fixture's audience — a consumer outside this
repository — legible from the location alone. A cross-repository fixture therefore lives here,
beside the test that reads it, and never under `data/`.

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
