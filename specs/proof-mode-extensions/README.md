# Proof-mode extension design

Development proposal for checked rewriting, richer temporal rules and a pointed semantic
backend for the public TM/TM⁺ proof mode. No tactics are implemented by these documents.

- [Implementation plan](plan.md): interfaces, source reuse, proof obligations, milestones and
  a compact acceptance suite.
- [Mutual review](review.md): independent scores, findings, their resolution and final review.

The source baseline is `81ae7a6c09807630b5000992a8bb5f689e051fa6` on Lean v4.33.0-rc1.
For currently supported commands, see the
[derivation proof-mode guide](../../docs/user-guide/derivation-proof-mode.md).

The [archived independent proposals and reviews](review/README.md) preserve the reasoning
behind the joint revision. They are historical drafts; the plan above is the current proposal.

Last verified: 2026-11-19 (source audit and documentation only).
