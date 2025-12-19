# Maintenance System - Quick Reference

**Version**: 1.0.0  
**Last Updated**: 2025-12-19

---

## Quick Links

- **Schema Guide**: [STATE_SCHEMA_GUIDE.md](../STATE_SCHEMA_GUIDE.md)
- **Workflow**: [maintenance-workflow.md](../../context/lean4/processes/maintenance-workflow.md)
- **Template**: [maintenance-report-template.md](../../context/lean4/templates/maintenance-report-template.md)
- **Migration**: [MIGRATION.md](MIGRATION.md)
- **Implementation Plan**: [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)

---

## File Locations

### State Files
```
.opencode/specs/
├── state.json                          # Global state
├── archive/state.json                  # Archive tracking
└── maintenance/state.json              # Maintenance tracking
```

### Reports
```
.opencode/specs/maintenance/
└── report-YYYYMMDD.md                  # Standardized reports
```

### Templates & Workflows
```
.opencode/context/lean4/
├── templates/
│   └── maintenance-report-template.md  # Report template
└── processes/
    └── maintenance-workflow.md         # Workflow guide
```

---

## Common Commands

### Query Archive State

**List all archived projects**:
```bash
jq -r '.archived_projects[] | "\(.project_number) - \(.project_name)"' \
  .opencode/specs/archive/state.json
```

**Find projects by type**:
```bash
jq '.archived_projects[] | select(.type == "documentation")' \
  .opencode/specs/archive/state.json
```

**Get archive statistics**:
```bash
jq '.statistics' .opencode/specs/archive/state.json
```

**Count archived projects**:
```bash
jq '.archive_metadata.total_projects' .opencode/specs/archive/state.json
```

### Query Maintenance State

**List all operations**:
```bash
jq -r '.operations[] | "\(.operation_id) - \(.date)"' \
  .opencode/specs/maintenance/state.json
```

**Get latest operation**:
```bash
jq '.operations[0]' .opencode/specs/maintenance/state.json
```

**Get health trends**:
```bash
jq '.health_trends' .opencode/specs/maintenance/state.json
```

**Get technical debt**:
```bash
jq '.technical_debt' .opencode/specs/maintenance/state.json
```

**Get last maintenance date**:
```bash
jq -r '.maintenance_metadata.last_maintenance' \
  .opencode/specs/maintenance/state.json
```

### Validate State Files

**Check JSON syntax**:
```bash
jq empty .opencode/specs/state.json
jq empty .opencode/specs/archive/state.json
jq empty .opencode/specs/maintenance/state.json
```

**Verify schema version**:
```bash
jq '.schema_version' .opencode/specs/archive/state.json
jq '.schema_version' .opencode/specs/maintenance/state.json
```

---

## Naming Conventions

### Reports
- **Format**: `report-YYYYMMDD.md`
- **Location**: `.opencode/specs/maintenance/`
- **Example**: `report-20251219.md`

### Operation IDs
- **Format**: `maintenance-YYYYMMDD`
- **Example**: `maintenance-20251219`

### Project Numbers
- **Format**: `NNN` (3 digits, zero-padded)
- **Example**: `052`, `061`, `062`

### Timestamps
- **Format**: ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`)
- **Example**: `2025-12-19T10:00:00Z`

---

## State File Schemas

### archive/state.json

**Required Fields**:
- `schema_version`: "1.0.0"
- `archive_metadata`: { total_projects, last_updated, retention_policy }
- `archived_projects[]`: Array of project objects
- `statistics`: { by_type, by_priority, by_complexity }
- `search_indices`: { by_date, by_impact, by_module }

**Project Object**:
```json
{
  "project_number": "NNN",
  "project_name": "project_name",
  "type": "documentation | bugfix | feature | verification | maintenance",
  "archived_date": "YYYY-MM-DDTHH:MM:SSZ",
  "timeline": { /* ... */ },
  "summary": { /* ... */ },
  "artifacts": { /* ... */ },
  "deliverables": { /* ... */ },
  "impact": { /* ... */ },
  "verification": { /* ... */ },
  "references": { /* ... */ },
  "tags": [],
  "lessons_learned": []
}
```

### maintenance/state.json

**Required Fields**:
- `schema_version`: "1.0.0"
- `maintenance_metadata`: { last_maintenance, next_scheduled, frequency }
- `operations[]`: Array of operation objects
- `scheduled_maintenance`: { /* ... */ }
- `health_trends[]`: Array of health snapshots
- `technical_debt`: { sorries, axioms }
- `quality_gates`: { build, test, linter, documentation }

**Operation Object**:
```json
{
  "operation_id": "maintenance-YYYYMMDD",
  "date": "YYYY-MM-DDTHH:MM:SSZ",
  "type": "scheduled | ad-hoc | post-milestone",
  "coordinator": "reviewer",
  "subagents": [],
  "scope": { /* ... */ },
  "execution": { /* ... */ },
  "activities": { /* ... */ },
  "metrics": { /* ... */ },
  "findings": { /* ... */ },
  "artifacts": { /* ... */ },
  "health_snapshot": { /* ... */ },
  "recommendations": { /* ... */ }
}
```

---

## Workflow Stages

1. **Preparation**: Load state files, determine scope
2. **TODO.md Maintenance**: Clean up completed tasks
3. **Project Archiving**: Archive completed projects
4. **Codebase Scanning**: Scan for sorry/axioms
5. **Status Document Updates**: Update IMPLEMENTATION_STATUS.md, etc.
6. **State Synchronization**: Update all state files
7. **Report Generation**: Create comprehensive report
8. **Verification**: Run verification commands
9. **Return Results**: Return summary to orchestrator

---

## Agent Roles

### Reviewer (Orchestrator)
- Coordinates entire maintenance workflow
- Delegates to specialists
- Updates all state files
- Generates comprehensive report

### Verification Specialist
- Scans codebase for sorry/axioms
- Verifies against standards
- Identifies discrepancies
- Returns verification results

### TODO Manager
- Cleans up completed tasks
- Updates task priorities
- Reorganizes TODO.md
- Returns summary of changes

---

## Common Tasks

### Archive a Project

1. **Collect project metadata**:
   - Project number, name, type
   - Timeline (created, completed, duration)
   - Summary (title, description)
   - Artifacts (plans, summaries, reports)
   - Deliverables (files created/modified)
   - Impact (before/after metrics)

2. **Add to archive/state.json**:
   ```bash
   # Edit archive/state.json
   # Add project object to archived_projects array
   # Update archive_metadata.total_projects
   # Update statistics
   # Update search_indices
   ```

3. **Update state.json**:
   ```bash
   # Edit state.json
   # Update archive_summary.total_archived
   # Update archive_summary.last_archived
   ```

4. **Optionally move directory**:
   ```bash
   mv .opencode/specs/NNN_project_name .opencode/specs/archive/
   ```

### Record Maintenance Operation

1. **Create operation object** with all required fields

2. **Add to maintenance/state.json**:
   ```bash
   # Edit maintenance/state.json
   # Add operation object to operations array (at beginning)
   # Update maintenance_metadata.last_maintenance
   # Add health snapshot to health_trends
   # Update technical_debt if changed
   # Update metrics_history
   ```

3. **Update state.json**:
   ```bash
   # Edit state.json
   # Add to recent_activities
   # Update maintenance_summary.last_maintenance
   # Update repository_health if changed
   ```

4. **Generate report**:
   ```bash
   # Use maintenance-report-template.md
   # Save as .opencode/specs/maintenance/report-YYYYMMDD.md
   ```

### Generate Maintenance Report

1. **Use template**: `maintenance-report-template.md`

2. **Fill in all sections**:
   - Executive Summary
   - Operations Performed
   - Discrepancies Found
   - Project Health Snapshot
   - State Updates
   - Recommendations
   - Artifacts Created
   - Verification Commands
   - Next Steps
   - Conclusion

3. **Save as**: `report-YYYYMMDD.md`

4. **Reference in state**: Add to maintenance/state.json operation

---

## Troubleshooting

### State files out of sync
**Solution**: Run verification commands, identify discrepancies, update state files

### JSON syntax error
**Solution**: Use `jq empty <file>` to find error, fix syntax

### Missing required field
**Solution**: Check STATE_SCHEMA_GUIDE.md for required fields, add missing fields

### Timestamp format wrong
**Solution**: Use ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ)

### Query returns no results
**Solution**: Check search_indices are populated, verify query syntax

---

## Best Practices

### State Management
- ✅ Always update state files atomically
- ✅ Verify state consistency after updates
- ✅ Use ISO 8601 timestamps consistently
- ✅ Include operation IDs for traceability

### Report Generation
- ✅ Use standard template for all reports
- ✅ Include all required sections
- ✅ Provide verification commands
- ✅ Link to state files for details

### Archiving
- ✅ Archive projects immediately upon completion
- ✅ Preserve all artifacts in archive
- ✅ Update archive/state.json atomically
- ✅ Verify archive integrity

### Documentation
- ✅ Keep status documents synchronized
- ✅ Document all discrepancies found
- ✅ Provide rationale for all changes
- ✅ Include before/after comparisons

---

## Migration Status

### Completed ✅
- [x] State file schemas created
- [x] Documentation created
- [x] Templates and workflows created
- [x] Migration guide created

### In Progress ⏳
- [ ] Migrate remaining projects to archive/state.json
- [ ] Consolidate existing reports
- [ ] Deprecate ARCHIVE_INDEX.md

### Pending ⏸️
- [ ] Update agents (reviewer, todo-manager, verification-specialist)
- [ ] Update commands (todo, review)
- [ ] Full testing and validation

---

## Resources

### Documentation
- **STATE_SCHEMA_GUIDE.md**: Comprehensive schema documentation
- **maintenance-workflow.md**: Detailed workflow guide
- **MIGRATION.md**: Migration from ARCHIVE_INDEX.md
- **IMPLEMENTATION_PLAN.md**: Full implementation plan

### Templates
- **maintenance-report-template.md**: Standard report template

### Examples
- **archive/state.json**: 3 example projects (052, 056, 061)
- **maintenance/state.json**: 2 example operations (20251218, 20251219)

---

## Support

### Questions?
- See STATE_SCHEMA_GUIDE.md for schema details
- See maintenance-workflow.md for workflow details
- See examples in state.json files

### Issues?
- Check troubleshooting section above
- Verify state files with `jq empty`
- Check git history for recent changes
- Report issues with specific context

---

**Quick Reference Version**: 1.0.0  
**Last Updated**: 2025-12-19  
**Next Review**: After Phase 3 completion
