# Implementation Summary: Task #832

**Completed**: 2026-02-03
**Duration**: ~15 minutes

## Changes Made

Updated artifact formats and Lean agent definitions for consistent sorry handling. Added conditional "Sorry Characterization" sections to report-format.md and plan-format.md with explicit guidance on framing. Made sorry-debt-policy.md mandatory context for both Lean agents and added explicit prohibition against "acceptable sorry" framing in Critical Requirements.

## Files Modified

- `.claude/context/core/formats/report-format.md` - Added "Sorry Characterization (Lean reports only)" section with applicability statement, required elements (Current State, Transitive Impact, Remediation Path, Publication Blockers), framing rules, and example
- `.claude/context/core/formats/plan-format.md` - Added entry to Structure list and detailed "Sorry Characterization (Lean plans only)" section with applicability, required elements (Pre-existing Sorries, Expected Resolution, New Sorries, Remaining Debt), framing rules, and example
- `.claude/agents/lean-research-agent.md` - Moved sorry-debt-policy.md to Always Load with "(REQUIRED for correct characterization)" annotation, added MUST NOT item 12 prohibiting "acceptable sorry" framing
- `.claude/agents/lean-implementation-agent.md` - Moved sorry-debt-policy.md to Always Load with "(REQUIRED for correct characterization)" annotation, added MUST NOT item 14 prohibiting "acceptable sorry" framing

## Verification

- Both format files contain Sorry Characterization section with "(Lean ... only)" qualifier
- Both format files contain identical prohibited phrases: "acceptable sorry", "acceptable limitation", "sorry is fine", "okay to have sorry", "N acceptable sorries"
- Both format files contain identical required phrases: "tolerated during development", "technical debt requiring remediation", "blocks publication", "inherited by dependents", "remediation priority: high/medium/low"
- Both Lean agents have sorry-debt-policy.md in Always Load section
- Both Lean agents have MUST NOT prohibition with consistent text
- All markdown formatting verified correct

## Notes

- Format file sorry sections are clearly marked as Lean-only to avoid confusion for non-Lean tasks
- Framing rules are consistent across all updated files and align with sorry-debt-policy.md (task 831)
- The "Load for Sorry Handling" section was removed from both agents since sorry-debt-policy.md is now mandatory
