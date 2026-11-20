Thanks for the amount of work here. The mathematics reads correctly, and the boundary is one-way as claimed: I found no path by which a semantic fact produces a derivation, and `luse_derivation` requires what it should.

I am not going to merge this as it stands. The semantic tier is a separate mode (see "Tiers" in `records/proof-mode-architecture.md`, and my notes on #7). This PR instead overloads about twenty derivation tactics to act on truth goals by goal shape. A reader can then no longer tell from a script whether it builds a derivation, and that is the one promise the derivation mode makes. The semantic handlers also read the native syntax by raw index and share its registry, so the two are coupled in code.

**What I am asking for**

1. **The lemmas first, as their own PR.** These go under `FormalSystem/Semantics/` with tests: covering-time Next/Previous, G/H persistence, F/P bind, the inclusive and weak Until/Since clauses, `rank_progress`, and the transport structures. They are worth having whatever happens to the tactics.
2. **A record before the mode.** Please open `records/semantic-proof-mode.md` as a PR. It should give the aim, the existing proofs the mode shortens (named by declaration), how it is measured, and its milestones. Ordinary Lean tactics already work on truth goals, so the case to make is what a tactic language adds. The countermodels in `BimodalLib` are a candidate client, with a control run using the lemmas alone. I would like to agree the record before reviewing code against it.
3. **Then the mode, as a separate PR.**
   - Its own directory under `FormalSystem/Semantics/`.
   - Its own tactic prefix and rule registry.
   - No handlers on the `l*` syntax.
   - No import of `FormalSystem/Automation/ProofMode/`.
   - It shares only the views tier and the position and polarity planner with the derivation mode.
4. **One bridge.** `luse_derivation` and the soundness lemma go in a single module under `FormalSystem/Metalogic/`, the only place the two modes meet.
5. **Its own guide and tests**, named by the family scheme.

**When the code comes back**

- Parse with quotation patterns, not raw indices.
- Let elaboration errors propagate, as on #7.
- Either restrict which transport certificates are accepted or say plainly that any function between truth judgments is.
- `resolveSemanticParameters` searches hypotheses while the comment in `SemanticCore.lean:407` says they are never searched.
- Tests:
  - Assert messages with `#guard_msgs`.
  - The refusal that matters most has no test: a semantic fact offered against a derivation goal.
  - Most of the modal and temporal tactics have no test, nor does any past variant.
- Remove plan labels ("(P4)", "branch-2 shapes", "plan §3.1") from source.
