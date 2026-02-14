# Bash Fallback Installation - Execution Plans

This directory contains detailed execution plans for making `install.sh` a complete, production-ready pure-bash fallback that doesn't depend on npx or Node.js.

## 📋 Overview

The goal is to ensure `bash ./install.sh` provides identical functionality to `npx gsd-opencode install` but with pure bash - no external dependencies except standard Unix tools (sed, grep, find, etc.).

## 🗂️ Files in This Directory

### 1. [SESSION_1_CRITICAL_FIXES.md](SESSION_1_CRITICAL_FIXES.md)
**Status:** Ready to Execute  
**Duration:** 30-45 minutes  
**Priority:** 🔴 **CRITICAL**

Fixes critical bugs that prevent both scripts from working:
- Fix wrong source directory reference (`command/` → `commands/`)
- Add source directory validation to `install.js`
- Verify both scripts can find and copy source files

**Must complete this session first before any other work.**

**Output after completion:**
- Both scripts work without "Source directory not found" errors
- Both can perform test installations successfully
- Clear, actionable error messages

---

### 2. [SESSION_2_DEFENSIVE_ENHANCEMENTS.md](SESSION_2_DEFENSIVE_ENHANCEMENTS.md)
**Status:** Ready to Execute  
**Duration:** 45-60 minutes  
**Priority:** 🟡 **MEDIUM** (optional but recommended)  
**Prerequisite:** Complete SESSION 1 first

Improves `install.sh` robustness and error handling:
- Enhanced tilde expansion for all path patterns
- Error checking on all file operations
- Improved error messages with color output
- Better validation and sanity checks
- Installation summary report

**Recommended for production use.**

**Output after completion:**
- Production-ready pure-bash installer
- Better error diagnostics
- Improved user experience with colored output
- Handles edge cases (spaces, special chars in paths)

---

### 3. [SESSION_3_ALIGN_BEHAVIOR.md](SESSION_3_ALIGN_BEHAVIOR.md) *(Optional, Future)*
**Status:** Not yet created  
**Priority:** 🟢 **LOW** (optional)  
**Prerequisite:** Complete SESSION 1 first

Would align `install.js` behavior with enhanced `install.sh`:
- Fix path prefix logic bug in `install.js`
- Improve `install.js` error handling
- Ensure side-by-side tests produce identical results

---

## 🚀 Quick Start Guide

### First Time Setup
```bash
# Clone/navigate to repository
cd /path/to/gsd-opencode

# Read the first session plan
cat .planning/bash_fallback/SESSION_1_CRITICAL_FIXES.md

# Follow the plan step-by-step
# (All specific file locations and line numbers are provided)
```

### Executing Session 1
1. Read `.planning/bash_fallback/SESSION_1_CRITICAL_FIXES.md` completely
2. Make the 5 changes specified (2 files, multiple line changes)
3. Run verification tests
4. Confirm all success criteria are met

### Executing Session 2 (After Session 1)
1. Read `.planning/bash_fallback/SESSION_2_DEFENSIVE_ENHANCEMENTS.md` completely
2. Make the 8 enhancements specified (1 file, multiple functions)
3. Run verification tests
4. Confirm all success criteria are met

---

## 📊 Issues Being Addressed

### Critical Issues (Session 1)
| Issue | Severity | Impact |
|-------|----------|--------|
| Wrong source directory path | 🔴 CRITICAL | Scripts can't find files to install |
| No source validation in JS | 🟠 MEDIUM | Errors appear late, unclear messages |

### Robustness Issues (Session 2)
| Issue | Severity | Impact |
|-------|----------|--------|
| Limited tilde expansion | 🟡 LOW | Won't work with `~user/` paths |
| No file operation error checking | 🟡 LOW | Silent failures possible |
| Unclear error messages | 🟡 LOW | Harder to debug |
| No handling of special chars | 🟡 LOW | Fails with spaces/special chars in paths |

---

## ✅ Completion Checklist

### Session 1: Critical Fixes
- [ ] Read SESSION_1_CRITICAL_FIXES.md completely
- [ ] Make changes to install.sh (3 locations)
- [ ] Make changes to install.js (2 locations + 1 validation block)
- [ ] Run verification Test 1 (--help works)
- [ ] Run verification Test 2 (--local installs)
- [ ] Run verification Test 3 (output looks correct)
- [ ] Verify all success criteria are met
- [ ] Commit changes with message: "fix(install): correct source directory path commands vs command"

### Session 2: Defensive Enhancements
- [ ] Complete Session 1 first
- [ ] Read SESSION_2_DEFENSIVE_ENHANCEMENTS.md completely
- [ ] Make enhancements to install.sh (8 tasks)
- [ ] Run verification Test 1-5
- [ ] Verify all success criteria are met
- [ ] Test with edge cases (spaces, special chars)
- [ ] Commit changes with message: "enhance(install): add defensive checks and better error handling"

---

## 🔍 Key Differences Between install.sh and install.js

| Feature | install.sh | install.js |
|---------|-----------|-----------|
| Language | Pure bash | Node.js |
| Dependencies | Standard Unix tools | Node.js runtime |
| Tilde expansion | Basic | Minimal |
| Error checking | Will be enhanced | Not yet added |
| Color output | Will be added | Has it (chalk) |
| Source validation | Has it | Missing |
| Error messages | Will be enhanced | Basic |

---

## 📝 File Locations Reference

All files are relative to repository root:

```
gsd-opencode/
├── bin/
│   ├── install.sh          ← Main pure-bash installer
│   ├── install.js          ← Node.js installer (npx target)
│   ├── gsd.js
│   └── gsd-install.js
├── commands/               ← Commands directory (note: plural)
│   └── gsd/
├── agents/
├── get-shit-done/
├── package.json
└── ...

.planning/
└── bash_fallback/          ← This directory
    ├── SESSION_1_CRITICAL_FIXES.md
    ├── SESSION_2_DEFENSIVE_ENHANCEMENTS.md
    ├── SESSION_3_ALIGN_BEHAVIOR.md  ← Future
    └── README.md           ← You are here
```

---

## 🎯 Goals

### Primary Goal
Make `bash ./install.sh` a complete, reliable pure-bash alternative to `npx gsd-opencode install`.

### Session 1 Goal
Fix blocking bugs that prevent the installer from working at all.

### Session 2 Goal
Make the bash installer production-ready with robust error handling and user-friendly output.

### Session 3 Goal (Optional)
Ensure `install.js` is equally robust and all tests prove both installers produce identical results.

---

## 💡 Best Practices While Executing Plans

1. **Read the entire plan** before making any changes
2. **Make one change at a time**, test, then proceed
3. **Follow exact file paths and line numbers** provided
4. **Run all verification tests** before moving to next task
5. **Keep git clean** - commit after each major task
6. **Document any issues** found and differences from plan

---

## 🐛 Reporting Issues

If you encounter issues while executing these plans:

1. **Note the exact error** message and context
2. **Check the line numbers** haven't shifted (they shouldn't if following in order)
3. **Verify file content** matches what's shown in plan
4. **Test individual changes** before combining them
5. **Document findings** for potential future improvements

---

## 🔄 Future Improvements

After all sessions are complete:

- [ ] Add `--dry-run` mode to preview changes
- [ ] Add `--log-file` option to save installation transcript
- [ ] Add progress indicators during file copying
- [ ] Create rollback capability
- [ ] Add integrity checking (checksums) for installed files
- [ ] Create uninstall script
- [ ] Add shell auto-completion installation

---

## 📞 Questions or Clarifications?

Each session plan includes:
- ✅ Detailed problem description
- ✅ Exact file locations and line numbers
- ✅ Before/after code snippets
- ✅ Verification tests to confirm changes work
- ✅ Success criteria checklist

If something is unclear:
1. Re-read the relevant section of the session plan
2. Check the "Notes" section at plan end
3. Review the problem description for context
4. Follow the exact code examples provided

---

## 📈 Progress Tracking

```
Session 1: ████░░░░░░ (Ready to start)
Session 2: ░░░░░░░░░░ (After Session 1)
Session 3: ░░░░░░░░░░ (Optional future)
```

Update this as you complete each session.

---

**Last Updated:** 2026-02-14  
**Status:** Ready for Session 1 execution
