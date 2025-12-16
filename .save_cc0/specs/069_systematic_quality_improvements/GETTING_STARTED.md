# Getting Started with Quality Improvements

Quick guide to begin implementing the systematic quality improvements.

## 📋 Review the Plan

1. **Read the overview**: [`README.md`](README.md)
2. **Review the detailed plan**: [`plans/001-systematic-quality-improvements-plan.md`](plans/001-systematic-quality-improvements-plan.md)
3. **Check the summary**: [`summaries/001-plan-overview.md`](summaries/001-plan-overview.md)
4. **Use the checklist**: [`CHECKLIST.md`](CHECKLIST.md)

## 🎯 Recommended Approach

### Option 1: Full Implementation (4 weeks)
Follow the plan week-by-week as designed:
- **Week 1**: High ROI improvements (READMEs, CI, metrics, TODO cleanup)
- **Week 2**: Foundation refactoring (axioms, file splitting, imports)
- **Week 3**: Documentation & structure (docstrings, more splitting, dependency graph)
- **Week 4**: Testing & sustainability (tests, inference rules)

### Option 2: Incremental Implementation
Pick individual phases based on priority:
- **Highest ROI**: Phases 1, 2, 3 (READMEs, CI, metrics) - 9-13 hours
- **Quick wins**: Phase 4 (TODO cleanup) - 4-6 hours
- **Foundation**: Phases 5, 13 (axiom/rule refactoring) - 20-28 hours
- **Structure**: Phases 6, 9, 10 (file splitting) - 16-24 hours
- **Documentation**: Phases 7, 8, 11 (imports, docstrings, graph) - 11-15 hours
- **Testing**: Phase 12 (comprehensive tests) - 8-10 hours

### Option 3: Cherry-Pick
Start with the easiest, highest-impact improvements:
1. **Phase 1**: Add 8 directory READMEs (4-6 hours) ⭐
2. **Phase 3**: Create quality metrics dashboard (3-4 hours) ⭐
3. **Phase 2**: Add CI quality gates (2-3 hours) ⭐
4. **Phase 4**: Clean up documentation TODOs (4-6 hours)
5. **Phase 8**: Add docstrings (6-8 hours)

## 🚀 Quick Start: Week 1 (High ROI)

If you want to start immediately with maximum impact:

### Day 1-2: Phase 1 - Directory READMEs (4-6 hours)

```bash
# Create README template
cat > /tmp/readme-template.md << 'EOF'
# [Directory Name]

## Purpose
[1-2 sentence description]

## Contents
[List of files with brief descriptions]

## Key Exports
[Public API - main types, theorems, tactics]

## Usage Examples
[2-3 code examples]

## Dependencies
[What this module imports]

## Related Documentation
[Cross-references]
EOF

# Create each README using the template
# Start with Logos/Core/README.md
```

**Files to create**:
1. `Logos/Core/README.md`
2. `Logos/Core/Syntax/README.md`
3. `Logos/Core/ProofSystem/README.md`
4. `Logos/Core/Semantics/README.md`
5. `Logos/Core/Metalogic/README.md`
6. `Logos/Core/Theorems/README.md`
7. `Logos/Core/Theorems/Perpetuity/README.md`
8. `Logos/Core/Automation/README.md`

### Day 3: Phase 2 - CI Quality Gates (2-3 hours)

```bash
# Create docstring coverage script
cat > scripts/docstring-coverage.sh << 'EOF'
#!/bin/bash
DOCSTRINGS=$(rg '^/--' Logos/Core --type lean -c | awk -F: '{s+=$2}END{print s}')
DEFINITIONS=$(rg 'theorem|def|axiom' Logos/Core --type lean -c | awk -F: '{s+=$2}END{print s}')
COVERAGE=$(echo "scale=0; $DOCSTRINGS / $DEFINITIONS * 100" | bc)
echo $COVERAGE
EOF
chmod +x scripts/docstring-coverage.sh

# Test it
scripts/docstring-coverage.sh
```

**Edit** `.github/workflows/ci.yml` to add quality gates (see Phase 2 in plan).

### Day 4: Phase 3 - Quality Metrics (3-4 hours)

```bash
# Create quality metrics script
cat > scripts/quality-metrics.sh << 'EOF'
#!/bin/bash
set -e

echo "=== Logos Quality Metrics ==="
echo "Generated: $(date)"
echo ""

# Source metrics
SLOC=$(find Logos/Core -name '*.lean' -exec wc -l {} + | tail -1 | awk '{print $1}')
echo "Source lines: $SLOC"

# Test metrics
TLOC=$(find LogosTest/Core -name '*.lean' -exec wc -l {} + | tail -1 | awk '{print $1}')
echo "Test lines: $TLOC"

# Test ratio
RATIO=$(echo "scale=2; $SLOC / $TLOC" | bc)
echo "Test-to-code ratio: $RATIO:1"

# Technical debt
SORRY=$(rg 'sorry' Logos/Core --type lean -c | awk -F: '{s+=$2}END{print s}')
echo "Sorry count: $SORRY"

AXIOM=$(rg '^axiom ' Logos/Core --type lean -c | awk -F: '{s+=$2}END{print s}')
echo "Axiom count: $AXIOM"

# Documentation
DOCSTRINGS=$(rg '^/--' Logos/Core --type lean -c | awk -F: '{s+=$2}END{print s}')
echo "Docstrings: $DOCSTRINGS"

DEFINITIONS=$(rg 'theorem|def|axiom' Logos/Core --type lean -c | awk -F: '{s+=$2}END{print s}')
echo "Definitions: $DEFINITIONS"

COVERAGE=$(echo "scale=2; $DOCSTRINGS / $DEFINITIONS * 100" | bc)
echo "Docstring coverage: $COVERAGE%"

# File size distribution
echo ""
echo "File size distribution:"
echo "  <200 lines: $(find Logos/Core -name '*.lean' -exec wc -l {} \; | awk '$1<200{count++}END{print count}')"
echo "  200-500 lines: $(find Logos/Core -name '*.lean' -exec wc -l {} \; | awk '$1>=200 && $1<500{count++}END{print count}')"
echo "  500-800 lines: $(find Logos/Core -name '*.lean' -exec wc -l {} \; | awk '$1>=500 && $1<800{count++}END{print count}')"
echo "  >800 lines: $(find Logos/Core -name '*.lean' -exec wc -l {} \; | awk '$1>=800{count++}END{print count}')"
EOF
chmod +x scripts/quality-metrics.sh

# Run it
scripts/quality-metrics.sh
```

### Day 5: Phase 4 - Documentation TODOs (4-6 hours)

```bash
# Extract all TODOs
rg "FIXME|TODO|HACK|XXX|BUG" Documentation --type md -n > doc-todos.txt

# Review and categorize manually
# Then systematically resolve each category
```

## 📊 Track Progress

Use the checklist to track your progress:

```bash
# View checklist
cat .claude/specs/069_systematic_quality_improvements/CHECKLIST.md

# Update checklist as you complete items
# Change [ ] to [x] for completed items
```

## ✅ Validate Success

After each phase, run validation:

```bash
# Build succeeds
lake build

# Tests pass
lake test

# Quality metrics
scripts/quality-metrics.sh
```

After Week 1, you should see:
- ✅ 8 new directory READMEs
- ✅ CI with 5 quality gates
- ✅ Quality metrics dashboard
- ✅ <20 documentation TODOs (from 85)

## 🆘 Need Help?

- **Detailed instructions**: See the full plan in `plans/001-systematic-quality-improvements-plan.md`
- **Quick reference**: Use `CHECKLIST.md` to track progress
- **Questions**: Each phase has detailed acceptance criteria and file lists

## 📈 Expected Timeline

- **Week 1**: 13-19 hours (high ROI, low risk)
- **Week 2**: 19-28 hours (foundation refactoring)
- **Week 3**: 16-23 hours (documentation & structure)
- **Week 4**: 20-26 hours (testing & sustainability)

**Total**: 60-80 hours over 4 weeks

## 🎉 Success Criteria

You'll know you're done when:
- [x] All 8 directory READMEs exist
- [x] CI has 5 quality gates enforcing standards
- [x] Quality metrics dashboard is operational
- [x] Documentation TODOs <20 (from 85)
- [ ] Docstring coverage ≥60% (from 28%)
- [ ] No files >800 lines (from 3)
- [ ] Test-to-code ratio ≤3:1 (from 4:1)
- [ ] All tests pass
- [ ] Zero `#lint` warnings

---

**Ready to start?** Begin with Phase 1 (Directory READMEs) - it's the easiest and has immediate impact!
