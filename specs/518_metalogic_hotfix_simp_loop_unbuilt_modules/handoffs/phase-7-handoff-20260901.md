# Phase 7 handoff — task 518

Landed as one green commit (`Commit Mode: atomic-batch`), pre-declared file set honored:
`FormalSystem/Automation/AesopRules.lean` plus the *conditional* new module the plan reserved,
`FormalSystem/Automation/AesopRuleSet.lean`.

**Probe first (mandatory, per plan)**: the `register_simp_attr` import-boundary caveat **does**
apply to `declare_aesop_rule_sets`. A single-file probe fails with `no such rule set:
'TMLogicProbe'`; Aesop's error text says declared rule sets "only become visible once you import
the declaring file". So the conditional module was needed, and the fallback layout required no
re-scoping — exactly what pre-declaring it in the batch was for.

**Done**: `AesopRuleSet.lean` declares `declare_aesop_rule_sets [TMLogic]`; `AesopRules.lean`
imports it and retags all 21 attributes (`safe apply` x10, `safe forward` x7, `norm unfold` x4)
into `(rule_sets := [TMLogic])`. The `:50-53` docstring that documented the defect verbatim was
rewritten in the same change, as was `:27-28`'s "This module defines the TMLogic rule set" claim.
The `:16-22` deprecation notice was left alone — still accurate.

**Verification**: `lake build` exit 0 (2521 jobs); `lake build BimodalTest` exit 0 (2572 jobs);
`grep 'DEFAULT rule set'` returns nothing. Behavioural check on one TM goal — plain `aesop` now
reports "made no progress"; `aesop (rule_sets := [TMLogic])` loads the rules and searches to goal
501 before the pre-existing `DerivationTree` reconstruction failure documented at
`Automation/Tactics/Helpers.lean:136`. No live call site depended on the default set.

**Next**: Phase 8 — final acceptance gate on the combined tree.
