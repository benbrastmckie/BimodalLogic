# Research Summary: .opencode/ README Documentation

**Project**: #066_opencode_readme_documentation  
**Date**: December 20, 2025  
**Status**: Research Complete

---

## Key Findings

1. **Current State**: .opencode/ has 4 existing READMEs (top-level and context/) but is
   missing 8 critical navigation READMEs in subdirectories, most notably
   agent/subagents/specialists/ with 31 files and no organization guide.

2. **Documentation Philosophy**: Research from Google, GitHub, and Write the Docs
   emphasizes "fresh and minimal" documentation over "comprehensive but stale" - docs
   should be "alive but frequently trimmed, like a bonsai tree".

3. **AI Optimization**: LLMs benefit from hierarchical organization with consistent
   patterns, explicit cross-references, and clear navigation paths at each directory
   level.

4. **Recommended Approach**: Add 8 strategic READMEs using 4 standard templates,
   prioritized as High (4), Medium (3), and Low (1) based on navigation value.

5. **Implementation Complexity**: LOW - Estimated 4 hours total effort with well-defined
   templates and straightforward content (navigation and organization only).

6. **Specialist Organization**: Propose organizing 31 specialists into 10 logical
   categories (Proof Development, Code Quality, Documentation, Research, Analysis,
   Workflow, Testing, Learning, Optimization, Task Management).

7. **Maintenance Strategy**: Monthly review cycle with updates triggered by code changes,
   following documentation-standards.md quality checklist for consistency.

---

## Most Relevant Resources

### Internal Documentation
- `.opencode/context/repo/documentation-standards.md` - Core documentation principles
- `.opencode/README.md` - Excellent example of comprehensive top-level README
- `.opencode/context/README.md` - Excellent example of domain organization README
- `Documentation/Development/DIRECTORY_README_STANDARD.md` - LEAN 4 project conventions

### External Best Practices
- **Google Style Guide**: "Minimum viable documentation" principle
- **Diátaxis Framework**: Four documentation types (Tutorial, How-to, Reference,
  Explanation)
- **Write the Docs**: "Docs as Code" philosophy and community standards
- **GitHub Documentation**: Official README placement and structure guidance

---

## Recommendations

### Immediate Actions (High Priority)
1. Create `.opencode/agent/README.md` - Agent system overview (30 min)
2. Create `.opencode/agent/subagents/specialists/README.md` - Organize 31 specialists
   into 10 categories (45 min)
3. Create `.opencode/command/README.md` - Command reference guide (30 min)
4. Create `.opencode/specs/README.md` - Task workflow documentation (45 min)

### Short-Term Actions (Medium Priority)
5. Create `.opencode/context/lean4/README.md` - LEAN 4 context navigation (30 min)
6. Create `.opencode/context/logic/README.md` - Logic context navigation (30 min)
7. Create `.opencode/context/math/README.md` - Math context navigation (30 min)

### Optional Actions (Low Priority)
8. Create `.opencode/agent/subagents/README.md` - Only if 12 subagent files become
   difficult to navigate (30 min)

### Maintenance
- Monthly review of all READMEs for accuracy
- Update READMEs with code changes (same commit)
- Use documentation-standards.md quality checklist
- Implement automated link checking (future enhancement)

---

## Subdirectories Needing README Files

### High Priority (4)
1. `.opencode/agent/` - 1 file + 1 subdirectory, needs system overview
2. `.opencode/agent/subagents/specialists/` - 31 files, desperately needs organization!
3. `.opencode/command/` - 12 files, needs reference guide
4. `.opencode/specs/` - Multiple projects, needs workflow documentation

### Medium Priority (3)
5. `.opencode/context/lean4/` - 2 subdirectories, needs navigation
6. `.opencode/context/logic/` - 5 subdirectories, needs navigation
7. `.opencode/context/math/` - 4 subdirectories, needs navigation

### Low Priority (1)
8. `.opencode/agent/subagents/` - 12 files, optional

### Not Recommended
- `.opencode/context/repo/` - Only 4 files, parent README sufficient
- `.opencode/context/physics/` - Only 1 subdirectory, parent README sufficient

---

## Recommended Standard Template Structure

### Template A: Agent/Command Directory (60-100 lines)
- Purpose and overview
- Directory structure listing
- Quick reference table
- Usage guidelines
- Related documentation
- Contributing guidelines

**Use for**: agent/, command/

### Template B: Specialist Catalog (100-150 lines)
- Purpose and overview
- Available specialists by category
- Category explanations
- Using specialists
- Adding new specialists
- Related documentation

**Use for**: agent/subagents/specialists/

### Template C: Context Domain (80-120 lines)
- Purpose and overview
- Organization by subdirectory
- Quick reference table (concept → file)
- Usage by agents
- Adding new context
- Related context

**Use for**: context/lean4/, context/logic/, context/math/

### Template D: Specs Directory (100-150 lines)
- Purpose and overview
- Directory structure (NNN_task_name/ pattern)
- Special directories (TODO.md, state.json, archive/)
- Task lifecycle
- Project numbering
- Archive policy
- Related documentation

**Use for**: specs/

---

## Implementation Priority Order

### Week 1: High Priority READMEs
1. agent/README.md
2. agent/subagents/specialists/README.md (most critical - 31 files!)
3. command/README.md
4. specs/README.md

**Estimated Effort**: 2.5 hours

### Week 2: Medium Priority READMEs
5. context/lean4/README.md
6. context/logic/README.md
7. context/math/README.md

**Estimated Effort**: 1.5 hours

### As Needed: Low Priority READMEs
8. agent/subagents/README.md (optional)

**Estimated Effort**: 30 minutes

**Total Effort**: 4 hours

---

## Blockers or Questions Identified

**None**. Implementation is straightforward with well-defined templates and clear
requirements.

**Open Questions** (non-blocking):
1. Specialist categorization - Is 10 categories optimal? (Recommend: start with 10,
   consolidate if needed)
2. README length limits - Enforce strict limits? (Recommend: use target ranges with
   flexibility)
3. Update frequency - How often to review? (Recommend: monthly review cycle)
4. Automation - Automate generation/validation? (Recommend: start manual, add automation
   later)
5. Project-specific READMEs - Required for all projects? (Recommend: create as needed
   for complex projects)

---

## Full Report

See: `.opencode/specs/066_opencode_readme_documentation/reports/research-001.md`

**Report Contents**:
- Complete .opencode/ directory structure map
- Analysis of documentation-standards.md requirements
- Existing documentation patterns and best practices
- Gap analysis (what's missing, what needs improvement)
- Detailed implementation recommendations
- Template specifications
- Specialist categorization reference
- Success metrics and maintenance strategy

**Web Research Findings**:
See: `.opencode/specs/066_opencode_readme_documentation/findings/web-research-findings.md`

---

**Research Complete**: December 20, 2025  
**Status**: ✅ Ready for Implementation  
**Next Step**: Create high-priority READMEs following recommended templates
