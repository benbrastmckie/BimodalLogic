# Phase 20.5 — D16 closure: the `PriorExpressiveness.lean` page-range correction

**Status**: COMPLETED. **Owns**: `FormalSystem/Metalogic/WeakCanonical/PriorExpressiveness.lean`,
comment bytes only. **Sorry delta**: zero. **Removals/renames**: zero.

## What D16 was

The last open documentation ticket from Block D/F, and the only one that appeared in no phase's
`Owns` list from 20 through 30 — so the sequence as written would never have picked it up. Phase 17
had already closed the substantive half of it: `uSExpressivelyCompleteOverPrior`'s citation of
*Reynolds 1994, Theorem 5* is correct, verified against the page image, and the file was rightly
left byte-identical rather than having a correction manufactured to close a ticket. One residual
imprecision was reported and deliberately not edited then: the cited range `pp.123-124` looked one
page too wide. That, and nothing else, is what this phase closed.

## The verification

Re-verified against the **page image**, per the standing literature-fidelity directive — not
against another docstring in this tree, and not from memory. `pdftoppm -f 7` of
`Reynolds_1994_Axiomatising_U_and_S_over_integer_time.pdf` in the local corpus, read as an image:

- The page carries the printed running header **123**.
- Theorem 5 — *"The language with `U` and `S` is expressively complete for the class of Prior
  structures."* — and its **complete proof**, down to *"The case of `S'` is similar."*, both sit
  wholly on that page.
- The §7 heading *"No gaps between equivalence classes"* begins immediately afterwards, on the
  same page. Printed p.124 (PDF page 8) opens with §7's body and contains nothing of Theorem 5.

So the charter's confirmation branch applied: the range genuinely was one page too wide, and the
narrowing is a real correction rather than one invented to retire a ticket.

**Offset re-measured, not inherited.** Printed = PDF page **+ 116** here (123 = 7 + 116). The
`+164` measured for §6 in the 1992 material does **not** carry over — the standing directive to
re-measure at each new citation site was warranted and is now confirmed twice. Worth carrying
forward: this corpus has no single global offset.

**Corpus note.** The markdown chunks for `reynolds_1994` are heavily OCR-degraded — no theorem
headings survive the conversion, and "Theorem 5" renders as `T h e o r e m 5` in the layout text,
which is why a text grep for it comes up empty. The page image was the operative evidence, which
is what the charter asked for regardless.

## What changed

Three comment lines, all in the owned file, all the same correction `pp.123-124` -> `p.123`:

| Site | Context |
|------|---------|
| `:39` | module-header `## References` list |
| `:209` | `flatten_stavi_correct_prior`'s docstring `Reference:` line |
| `:355` | `uSExpressivelyCompleteOverPrior`'s `References:` list — the D16 ticket's own site |

**Deviation from the estimate, reported not absorbed**: the plan estimated ~1 changed line, because
only `:355` was named on the ticket. All three sites carried the identical wrong range and all three
are comment bytes inside the owned file, so all three were narrowed. Three changed lines, one
correction.

## No conflict with `PriorExpressivenessDense.lean`

Recorded as the charter's third task required. That file's header cites *Reynolds **1992**,
"Continuous Temporal Models", §5 Theorem 3, printed p.176* (at `:15`, `:125`, `:190`, `:284`). This
file cites *Reynolds **1994**, Theorem 5, printed p.123*. Two papers, two numberings, both citations
correct. The two files were **not** made to agree, because they are not about the same theorem.

## Verification

- `git diff -U0` is exactly three single-line `-`/`+` pairs, every one inside a `/-! … -/` or
  `/-- … -/` block. This is the check that covers the `prose` tier's blind spot (an edit crossing
  out of the comment region).
- `#print axioms uSExpressivelyCompleteOverPrior` unchanged: `[propext, Classical.choice,
  Quot.sound]`, no `sorryAx`, no warnings.
- Scoped `lake build FormalSystem.Metalogic.WeakCanonical.PriorExpressiveness` green, 1234 jobs.
  A full build was deliberately not run: three comment lines in one file whose scoped build is
  green and whose axiom set is unchanged cannot break anything downstream, and a full build would
  only have exercised the concurrent decidability session's live-edited `Decidability/Verified/
  Bridge/` files — foreign territory, and the same files that broke Phase 20.4's full build for
  reasons that were not that phase's either.
- Owned-file sorry count zero. Its two `sorry` string matches are prose (*"sorry-tainted"*,
  *"sorry chain"*), not code. The three live foreign sorries were not touched, not counted, and
  not staged.

## Left alone on purpose

Two `Boneyard/` files still carry the old range — `BXPipelineDeadCode/ReynoldsModelSurgery.lean:41`
and `BXPipelineGapAnalysis/ChronicleNoGaps.lean:72`. Both are outside this phase's `Owns` list and
were deliberately not swept in as a convenient extension. They are dead code; if consistency there
is wanted it is a separate, trivially small ticket.

## Carry-forward

**D16 is CLOSED** and should be dropped from the chain. D7, D11 and D13 are untouched: zero
removals, zero renames, no `kplusOpen_of_kplus` contact, D13 not re-opened. The honest caveat is
unaffected and unweakened — every §6 lemma below Lemma 2 remains **conditional**, with
`IsContempEquivDense ε` plus Prior-U/Prior-S as hypotheses, the only exhibitable `ε` being `epsTop`
(for which `EndsInGapOnRight` is empty), and no live non-trivial instance until Phase 22. This
phase touched no §6 material.
