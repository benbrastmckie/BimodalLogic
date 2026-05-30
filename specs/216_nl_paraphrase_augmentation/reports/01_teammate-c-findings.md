# Teammate C (Critic) Findings: Task 216

**Task**: Natural-language paraphrase augmentation for bmlogic-bench
**Date**: 2026-05-29
**Angle**: Gaps, shortcomings, and blind spots
**Confidence Level**: High

---

## Key Findings

### 1. Semantic Faithfulness Is the Central Challenge

**Strict Until semantics vs. English "until"**: The project's Until operator U(event, guard) has *strict* semantics: the event must occur at a *strictly future* time, and the guard must hold at *all intermediate* times. English "until" is ambiguous:

- "q until r" in ordinary English often implies r eventually happens (strong until), but doesn't specify whether q holds at the moment r happens.
- The formal semantics is open-interval: guard holds on the *open* interval (now, witness), excluding both endpoints.
- A naive NL paraphrase "q holds until r occurs" fails to communicate: (a) r *must* eventually occur (strong until), (b) q is NOT required at the current moment, (c) q is NOT required at the moment r occurs.

**Recommendation**: The paraphrase must use precise phrasing like "at some strictly future time r holds, and at every time strictly between now and then, q holds." Shorter versions ("q holds until r") sacrifice faithfulness for readability — the task description doesn't specify which to prioritize.

**S5 necessity vs. English "necessarily"**: The box operator □ quantifies over ALL world-histories sharing the same time point under S5 semantics. English "necessarily" is philosophically loaded and ambiguous between metaphysical, logical, and epistemic necessity. For a benchmark aimed at training AI systems, this ambiguity could contaminate the training signal.

**Bimodal interaction** (239 records, 33% of benchmark): Formulas mixing □ with U/S like `U(q, □S(p, r))` require paraphrases that correctly nest temporal and modal scopes. This is the hardest category — "at some future time q holds, and until then, it is necessarily the case that at some past time p held and since then r has held" is technically faithful but barely readable.

### 2. The Depth Threshold Is Misleading

The task description states "modalDepth + temporalDepth ≤ 2" covers ~75% of records. Actual measurement shows **87.3%** (635/727), so the task description understates coverage.

More critically, **depth is not the right complexity measure for NL difficulty**:

- **152 records** have impCount ≥ 3 but depth ≤ 2. Example: `((r → (r → r)) → ⊥)` has depth 0 but 3 nested implications. The NL paraphrase "it is not the case that if r then if r then r" requires careful scope disambiguation despite low modal/temporal depth.
- **Complexity ranges up to 63** for depth ≤ 2 records (median 7). A formula with complexity 63 and depth 2 may be harder to paraphrase than a formula with complexity 6 and depth 3.
- **141 records** at depth ≤ 2 have complexity ≥ 9. These are NOT trivially rule-based.

**Recommendation**: The rule-based vs. LLM-assisted boundary should be based on *complexity* (or a combination of depth + impCount + atomCount), not depth alone.

### 3. Derived Operator Recognition Is Undertreated

The AST stores formulas in primitive form — derived operators like F, G, P, H, ◇, X, Y appear as their definitions:

| Derived | AST Pattern | Occurrences |
|---------|------------|-------------|
| Y (previous moment) | `snce(φ, bot)` | 56 |
| F (eventually) | `untl(φ, ¬⊥)` i.e. `untl(φ, imp(bot,bot))` | 53 |
| X (next moment) | `untl(φ, bot)` | 52 |
| ◇ (possibly) | `imp(box(imp(φ,bot)),bot)` | 26 |
| P (previously) | `snce(φ, imp(bot,bot))` | 8 |

A naive AST-walker would paraphrase `F(p)` as "there is some future time when p holds, and at all times between now and then, it is not the case that falsum" — technically correct but absurd. The implementation MUST include a derived-operator recognition pass before NL generation.

**The task description doesn't mention this at all.** It's a significant implementation requirement.

### 4. Falsum (⊥) Appears in 465 Records (64%)

⊥ is pervasive and appears in many structural roles:

- **As negation**: `imp(φ, bot)` = ¬φ (359 occurrences of single negation)
- **In vacuous implications**: `imp(bot, φ)` = ⊥ → φ (179 records, always valid). Paraphrase: "if falsum then φ" or "vacuously, φ" — both awkward.
- **As double negation**: `imp(imp(φ, bot), bot)` (5 occurrences). Should this be rendered as "it is not the case that it is not the case that φ" or simplified to "φ"?
- **As conjunction/disjunction**: ∧ and ∨ are defined through ⊥. The AST walker must recognize `imp(imp(φ, imp(ψ, bot)), bot)` as "φ and ψ".

**The choice of how to handle ⊥ in various positions is not addressed in the task description but affects every aspect of the paraphrase quality.**

### 5. Acceptance Criteria Are Underspecified

**"Grammatically correct for depth ≤ 2"**: 
- Who judges? Automated grammar checkers (LanguageTool, Grammarly API) catch surface errors but not semantic awkwardness. Human review is expensive for 635 records.
- What counts as "grammatically correct"? "If it is the case that if p then q then r" is grammatically correct but incomprehensible.

**"Spot-checked for depth ≥ 3"**:
- No sample size specified. Is 5% adequate? 20%?
- No protocol: random sample, stratified by operator type, worst-case selection?
- No pass/fail criteria for individual spot checks.

**Semantic equivalence verification is entirely absent**:
- There is no proposed method for verifying that the NL paraphrase is semantically faithful to the formula.
- Round-trip testing (NL → formula → compare) requires an NL-to-formula parser that doesn't exist.
- Human verification of semantic equivalence requires logic expertise.

### 6. Propositional Variables: An Unresolved Design Decision

The task description doesn't address whether atomic variables (p, q, r) should:

**(a) Stay abstract**: "p holds" — faithful but uninformative, reads like a textbook exercise.

**(b) Get assigned generic meanings**: "it rains" for p, "it is cold" for q — more natural but potentially misleading (suggests empirical rather than logical content).

**(c) Use a hybrid**: "proposition p holds" — explicit about the abstract nature.

This decision affects every single paraphrase and should be made before implementation, not during.

### 7. Multiple Valid Readings Are Not Addressed

Many formulas have genuinely different but equally valid NL readings:

- `□(p → q)` can be read as:
  - "Necessarily, if p then q"
  - "It is necessary that p implies q"  
  - "In every possible scenario, p entails q"

- `U(p, q)` can be read as:
  - "q holds until p occurs"
  - "At some future time p holds, and q holds at all times between now and then"
  - "p will eventually happen, and q is true throughout the wait"

The task specifies a single `nl_paraphrase` field. Should there be a canonical reading, or should the schema support multiple variants?

## Recommended Approach

1. **Before implementation**: Resolve the design decisions about variable naming, derived operator handling, ⊥ rendering, and the single-vs-multiple paraphrase question.

2. **Replace depth threshold with complexity-based cutoff**: Use `complexity ≤ 9 AND impCount ≤ 3` as the rule-based boundary instead of `modalDepth + temporalDepth ≤ 2`.

3. **Add a derived-operator recognition pass**: Pattern-match the AST for F, G, P, H, X, Y, ◇, ¬, ∧, ∨ before NL generation. This is non-optional.

4. **Specify acceptance criteria precisely**:
   - Automated grammar check (LanguageTool) for all records
   - Human review of 100% of bimodal-interaction records (239)
   - Semantic faithfulness spot-check: 30% sample stratified by operator type
   - Define "correct" paraphrase: must preserve logical strength (valid paraphrases should sound necessarily true; invalid ones should sound possibly false)

5. **Add `nl_paraphrase_variants` field**: Allow 1-3 variants per record at different formality levels, rather than committing to a single canonical reading.

## Evidence/Examples

### Example: Vacuous Implication
Formula: `(⊥ → U(q, □r))`
Naive: "If falsum then q until necessarily r"
Better: "Vacuously true: if a contradiction held, then r would necessarily hold until q occurs"
Best: "This formula is trivially valid because the antecedent is a contradiction"

### Example: Bimodal Interaction  
Formula: `U(q, □S(p, r))`
Depth: 2 (temporal 1 + modal 1) — within rule-based range
Faithful: "At some future time q holds, and at every time strictly between now and then, it is necessarily the case that at some past time p held and r held at every time strictly between that past time and now"
Readable: "q will eventually happen, and until then, it must always have been the case that p happened sometime in the past with r holding since"
Neither version is both faithful AND readable.

### Example: Derived Operator
Formula AST for F(p): `{"tag": "untl", "event": {"tag": "atom", "name": "p"}, "guard": {"tag": "imp", "left": {"tag": "bot"}, "right": {"tag": "bot"}}}`
Without recognition: "p holds at some future time, and at all intermediate times, if falsum then falsum"
With recognition: "Eventually, p holds"

## Unasked Questions That Need Answers

1. **Downstream use case**: If paraphrases will train NL→formula translation, they need to be unambiguous and invertible — this conflicts with readability goals.
2. **Negation scope in English**: "It is not the case that necessarily p" vs. "Necessarily it is not the case that p" — English word order creates scope ambiguity that formal notation avoids.
3. **Temporal reference frame**: "At some future time" future relative to what? The evaluation point? Should the paraphrase make the reference point explicit?
4. **Consistency across records**: Will the same subformula always get the same paraphrase? If `□p` appears in 100 records, must it always be rendered identically?
5. **How to handle the valid/invalid label**: Should the paraphrase read differently for valid vs. invalid formulas, or should it be neutral?
