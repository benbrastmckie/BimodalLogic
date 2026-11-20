Thanks for this. The congruence kernel is the right design: `Step` makes the demand at each position explicit, and the polarity and demand statements check out for every operator. A current-only fact cannot be used under a modal position unless it is exposed as a goal, which is the property that matters.

Requesting changes. This is the base of the stack, so the next section applies to #8 and #9 too.

**Where the design now lives**

Since you opened the stack I have written the direction down on `main`, in three records under `records/`:

- `proof-mode-architecture.md`: the principles, tiers and module scheme. Please read this one first.
- `proof-mode.md`: milestones and the two measurement gates.
- `theorem-library.md`: `BimodalLib`, the library of theorems and countermodels the mode is measured against.

Two choices there shape all three PRs:

- **Three tiers, kept apart.** Views (folding and unfolding defined operators), derivation (the proof mode) and semantic (truth at a point). No tactic name serves two tiers.
- **Fragments stack.** Rules are filed by operator family: `Boolean`, `Modal`, `Temporal`. Interactions always include Boolean: `ModalBoolean`, `TemporalBoolean`, `ModalTemporalBoolean`. Frame class is a suffix (`TemporalZTime`). The same names are used for rule modules, tactic modules, tests, guide pages, interface classes and library fragments, so a language extension adds modules and changes none.

I would like the design for this work to live in those records, not in a separate plan. Please propose edits to them in the PR (here, M17 and the "Logical rewriting" row of "Where the work sits").

**Requests**

1. **Rebase onto `main`.** The red check is not yours; it is fixed on `main`. Regenerate `typst/generated/status.typ` afterwards.
2. **Split views from rewriting.** This is a condition of merging. `lrewrite` with a formula equality is a cast; with an implication or equivalence it builds a derivation. Move the equality path out into a views pair, `lunfold` / `lfold`, each taking a view name over one table of views. `lrewrite` and `lsimp` keep logical steps only.
3. **File by family.**
   - Split the steps in `Congruence.lean` by family and keep `Kit`, `Step.comp` and path composition generic.
   - Move the `lsimp` seed rules to `ModalBoolean`.
   - Move `□` to `G`/`H` conversions to `ModalTemporalBoolean`.
   - Use one test file and one guide page per family, in place of the shared `ProofModeExtensionsTest.lean`.
4. **One step for `□` and `⊡`.** State the S5 step once over a structure with the necessity operator as a field, instantiated for TM at `□` and TM⁺ at `□` and `⊡`. Please add no further `tmX` / `plusX` name pairs; TM and TM⁺ should become instances of one interface.
5. **Stop swallowing errors.**
   - `lsimp` sends every per-rule error to a trace (`Simplification.lean:87-120`), so a typo in a rule name ends as "made no decreasing change".
   - `lrewrite` has the same problem (`Meta.lean:260`, `Rewriting.lean:517-519`).
   - Plan on formula syntax first, then elaborate the rule once and build one certificate, so that elaboration errors propagate.
6. **Behaviour.**
   - Expose `lsimp`'s attempt and scope budgets as options.
   - `lrewrite` should fail on a no-op.
   - When traversal stops at a wrapper with no registered step, say so.
7. **Tests.**
   - Assert messages with `#guard_msgs`; `fail_if_success` passes on the wrong failure.
   - Add the past direction (H, Prev, Since), TM⁺ `lsimp`, and goal-side polarity.
   - Move the soundness test (`:102-114`) to the PR it belongs to.
8. **Name a client.** Show one existing proof, say from `Theorems/Perpetuity/` or `TemporalDerived`, made shorter with these tactics. Also record term size and elaboration time for one nested rewrite.
9. **Documents.** Nothing outside `specs/` may link into it, so please drop the plan and review transcripts from the PR. Remove plan labels ("P0's…", "Proposed …") from source, tests and docs.
