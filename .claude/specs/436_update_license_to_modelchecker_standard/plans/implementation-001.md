# Implementation Plan: Task #436

**Task**: Update license to ModelChecker standard
**Version**: 001
**Created**: 2026-01-12
**Language**: general

## Overview

Replace the current MIT License with GPL-3.0 to align with the ModelChecker project standard. This involves updating the LICENSE file content and modifying README.md references from MIT to GPL-3.0.

## Phases

### Phase 1: Update LICENSE File

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Replace MIT License text with GPL-3.0 text matching ModelChecker format
2. Update copyright year to 2025
3. Use full name "Benjamin Brast-McKie"

**Files to modify**:
- `LICENSE` - Complete replacement of content

**Steps**:
1. Replace the entire LICENSE file content with GPL-3.0 text
2. Format matches `/home/benjamin/Projects/ModelChecker/Code/LICENSE` structure:
   - Header: "GNU GENERAL PUBLIC LICENSE"
   - Version line: "Version 3, 29 June 2007"
   - Copyright line with full name
   - Standard GPL-3.0 short-form notice
   - Links to full license text

**New LICENSE content**:
```
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (c) 2025 Benjamin Brast-McKie

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

For the full GPL-3.0 license text, see: https://www.gnu.org/licenses/gpl-3.0.txt
```

**Verification**:
- LICENSE file contains GPL-3.0 header
- Copyright year is 2025
- Full name "Benjamin Brast-McKie" appears

---

### Phase 2: Update README.md License References

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update Table of Contents entry from "MIT License" to "GPL-3.0 License"
2. Update License section text to reference GPL-3.0

**Files to modify**:
- `README.md` - Two edits required

**Steps**:
1. Update line 63 (TOC entry):
   - From: `- [License](#license) - MIT License`
   - To: `- [License](#license) - GPL-3.0 License`

2. Update line 301 (License section):
   - From: `MIT License - see [LICENSE](LICENSE) for details.`
   - To: `This project is licensed under GPL-3.0. See [LICENSE](LICENSE) for details.`

**Verification**:
- TOC entry shows "GPL-3.0 License"
- License section references "GPL-3.0"
- LICENSE link remains functional

---

## Dependencies

None - this is a standalone documentation update.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| License change affects existing forks | Low | MIT forks remain valid for their snapshots; new work under GPL-3.0 |
| Missed license references | Low | Research identified only two README.md locations |

## Success Criteria

- [ ] LICENSE file contains GPL-3.0 text with correct copyright
- [ ] README.md TOC entry shows "GPL-3.0 License"
- [ ] README.md License section references GPL-3.0
- [ ] Format matches ModelChecker LICENSE structure
- [ ] All existing links remain functional

## Total Estimated Effort

25-30 minutes (task estimate: 1 hour with buffer)
