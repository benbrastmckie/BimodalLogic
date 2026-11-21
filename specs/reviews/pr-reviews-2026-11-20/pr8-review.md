Thanks. The rule statements match their docstrings and the frame gates are in the right places. `keeping` is done correctly: it carries `G P` and not `P`, takes its direction from the step, and rejects wrong-direction and current-only facts. Splitting unfolding (ZTime) from folding (every frame class) is better than what I had planned, and I will adopt it.

Requesting changes. The records and the two design choices described on #7 apply here.

**Requests**

1. **Rebase onto `main` once #7 is merged.**
2. **Split `TemporalComposition.lean` by family.**
   - `Temporal`: Until and Since introduction, `futureKeep`, `reflectContext`.
   - `TemporalZTime`: folding, unfolding, `nextKeep`.
   - `TemporalBoolean`: the leads-to rules.
   - Tactic modules, tests and guide pages follow the same names.
3. **Move the views out.** The inclusive Until/Since definitions and `ltemporal_dual view` belong to the views tier, as rows of the view table behind the `lunfold` / `lfold` pair requested on #7.
4. **Induction.** `linduction` is backward induction, which is useful, but `forwardInvariantRule` is not an instance of it. The generalizing Until/Since rule is still open. M4 of `records/proof-mode.md` has a proposed statement, not yet derived; if you see a flaw in it or a better one, that would be the most useful addition.
5. **Leads-to.** Please label the three rules as the strict layer. The named leads-to is present-inclusive and will be proved from them.
6. **`lapply`.** The reordering is fine. Make an unresolved instance an error at the call (`Basic.lean:80`), document the goal order, and pin it with a test.
7. **One frame gate.** Use one helper for `lstep`, `linvariant` and the new routes, with one policy on local `ZTime ≤ fc` certificates and its own messages. Today `luntil unfold` at `Dense` reports a rewrite-rule error.
8. **Fewer forms.**
   - The five `… using` forms are each `lapply` plus a shape check; make that one form.
   - Build `keeping` over a table of carrying rules, so that `□` facts by 4, 5, MF and TF are later rows.
9. **Smaller fixes.**
   - Make `keeping` a non-reserved keyword (`&"keeping"`).
   - `ltime_reflect using t` should fail when `t` is not a derivation.
   - Reject an undetermined formula in `keeping`.
   - Print the user-facing operator, not `allFuture`.
10. **Tests.**
    - Assert messages with `#guard_msgs`.
    - Nothing yet tests `lsince`, `linduction`, `lprogress`, `luntil intro`, or `keeping` on `lstep`.
    - The past direction and TM⁺ have one test each.
11. **Wording.** Describe the tactics as they are: drop "(P3)", "unchanged", "original", "legacy" and "New …" from source and guide.
12. **Name clients.** Re-prove a few declarations from `TemporalDerived`, `ConnectDerived` or `LinearityDerived` with these rules.
13. **Revise the records.** Update M4 and the rows of "Where the work sits" for what lands.

**On timing.** The plan held linear-time rules until the first measurement of the mode (gate one). I am willing to take these now. Only `keeping` and `ltime_reflect` can enter that first measurement; the rest are measured at gate two.

**A question.** `luntil unfold` / `fold` are derivation steps, while `lunfold` / `lfold` name views. I lean towards renaming the keywords `expand` / `contract` so that fold and unfold belong to views alone. What is your view?
