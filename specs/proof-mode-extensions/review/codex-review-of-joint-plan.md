# Codex review of the joint revision

Written before reading Opus's final review. The archived proposals keep their original scores.
This review concerns the integrated plan, not an implemented tactic suite.

| Category | Score / 10 | Evidence and remaining deduction |
| --- | --- | --- |
| Correctness and grounding | 9 | Goal/fact polarity, strict intervals, the Base/ZTime asymmetry, semantic cover witnesses, soundness premises and one-way transport are explicit. P0 must still verify the proposed closed native combinators and their actual telescopes. |
| Compositionality | 8.5 | Demand composition is typed; Plus transfer is stepwise; providers stay opaque; Γ is stable; repeated advances retain persistent guarantees. The semantic counterpart of the positional demand kernel needs a more explicit implementation contract before P4. |
| Reusability | 9 | Reuses the clause API, transport and locality theorems, separates layers, and avoids a second Plus planner or a universal replacement framework. Derived Plus wrapper availability remains a deliberate unresolved API decision. |
| Automation | 8.5 | Exact initial scope routes, deterministic phases, actual-instance decrease, counted attempts, rollback and frame-gate policy are specified. Exact budget defaults and derived-view elaboration await measured prototypes. |
| Implementation clarity | 8 | Files, milestones, go/no-go gates and a small mechanism-driven suite are provided. The theorem inventory and registered telescope validators are still P0 deliverables, rather than checked artifacts accompanying this design. |

**Weighted total: 27 + 21.25 + 18 + 12.75 + 8 = 87 / 100.**

No identified soundness blocker. Accept as a staged design, beginning with P0. This does not
authorize assuming the prototype theorems, or implementing all later stages before their gates.

## Follow-up specification before the corresponding stage

1. **Missing specification, before P4; resolved in the review closeout:** spell out how semantic positional rewriting consumes
   point/range-indexed implications through □, ⊡ and temporal clauses. It must preserve the
   same polarity table without treating a current-point equivalence as a universally scoped
   one. Section 6.1 now specifies indexed predicate transformers, their monotonicity, composition
   and evidence discharge. A mixed world/time prototype remains a P4 gate. The recorded score
   above is the independent pre-closeout grade; it is not retroactively raised.
2. **Legitimate prototype work, P0:** type-check the closed signed transfer composition,
   arbitrary-Plus substitution telescope, conditional Base Next and reflected Since fold.
   Failure must narrow the supported routes, not introduce semantic extraction into native rules.
3. **Legitimate API decision, before P3:** choose whether Plus gains the derived dual aliases,
   or whether the first release documents only primitive views. Do not advertise absent names.
4. **Measurement work, before P2 freezes defaults:** record one nested example's expression size,
   attempt counters and elaboration baseline. No provider-body inspection and atomic rollback
   are firm requirements; runtime numbers must be measured.

The initial reviews' main objections have been resolved in the design: typed native demands,
directional rewriting, conditional Next, mixed Plus paths, explicit scoped capture, soundness
layering, fact/goal transport, correct temporal collapse directions and compact validation.
The remaining points above are bounded work, not grounds for inflating the plan into a new
logic framework or proof-search engine.
