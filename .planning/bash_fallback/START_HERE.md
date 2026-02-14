# 🚀 START HERE: Bash Fallback Installation Plans

**Status:** ✅ Ready for Execution  
**Total Documentation:** ~2000 lines across 7 files  
**Estimated Total Time:** 90-120 minutes (for both sessions)  
**Difficulty:** Moderate (straightforward changes, detailed guidance provided)

---

## 📋 What's in This Package?

You have received **complete execution plans** to make `bash ./install.sh` a production-ready pure-bash installer without requiring Node.js or npx.

### The Problem We're Solving
- Both `install.sh` and `install.js` are broken (look for `command/` instead of `commands/`)
- install.js lacks proper error handling
- install.sh could be more robust

### The Solution
- **SESSION 1:** Fix critical bugs (30-45 min) - MUST DO FIRST
- **SESSION 2:** Add defensive measures (45-60 min) - Recommended for production

---

## 🎯 Quick Navigation

### Read These First (In Order)

1. **[INDEX.md](INDEX.md)** ← Read this first (2 min)
   - Overview of all documents
   - How to use the plans
   - Quick FAQ

2. **[README.md](README.md)** ← Read this second (5-10 min)
   - Problem overview
   - Detailed execution steps
   - Completion checklist

3. **[SESSION_1_CRITICAL_FIXES.md](SESSION_1_CRITICAL_FIXES.md)** ← Execute this first
   - Fixes blocking bugs in both scripts
   - 5 specific changes to 2 files
   - Verification tests included

4. **[SESSION_2_DEFENSIVE_ENHANCEMENTS.md](SESSION_2_DEFENSIVE_ENHANCEMENTS.md)** ← Execute after SESSION 1
   - Makes install.sh production-ready
   - 8 enhancements (optional but recommended)
   - Edge case handling

### Reference While Executing

- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** ← Use while implementing
  - Code snippets for fast lookup
  - Before/after comparisons
  - Color codes and examples

### Deep Dive (Optional)

- **[ANALYSIS_REPORT.md](ANALYSIS_REPORT.md)** ← For understanding the "why"
  - Detailed findings from analysis
  - Root cause analysis
  - Code quality comparison

---

## ⏱️ Time Breakdown

| Phase | Duration | What | Status |
|-------|----------|------|--------|
| Read overview | 5-10 min | This file + INDEX.md | Do first |
| Read SESSION 1 plan | 15-20 min | Full plan + context | Then this |
| Execute SESSION 1 | 30-45 min | Make 5 changes | Then execute |
| Read SESSION 2 plan | 15-20 min | Full plan + context | After S1 |
| Execute SESSION 2 | 45-60 min | Make 8 enhancements | Optional but recommended |
| **TOTAL** | **90-120 min** | Both sessions | End state |

---

## ✅ What You'll Get

### After SESSION 1 (Critical Fixes)
- ✅ Both install.sh and install.js work
- ✅ Scripts find source directories correctly
- ✅ Basic installation completes successfully
- ✅ VERSION file created correctly

### After SESSION 2 (Enhancements)
- ✅ Production-ready pure-bash installer
- ✅ Robust error handling with clear messages
- ✅ Colored, user-friendly output
- ✅ Handles edge cases (spaces, special chars)
- ✅ Enhanced path expansion
- ✅ Installation summary report
- ✅ No Node.js dependency

---

## 🚦 How to Get Started

### Option A: Quick Execution (2 hour session)
```
1. Skim this file (2 min)
2. Read SESSION_1 plan (15 min)
3. Execute SESSION_1 changes (30 min)
4. Read SESSION_2 plan (15 min)
5. Execute SESSION_2 changes (45 min)
6. Test and commit (10 min)
✓ Done!
```

### Option B: Detailed Approach (3 sessions)
```
Session 1 (Day 1):
  1. Read INDEX.md
  2. Read README.md
  3. Read SESSION_1 plan
  4. Execute SESSION_1

Session 2 (Day 2):
  1. Review SESSION_1 changes
  2. Read SESSION_2 plan
  3. Execute SESSION_2

Session 3 (Later):
  1. Optional: Review ANALYSIS_REPORT
  2. Optional: Plan SESSION_3 for full alignment
```

---

## 📁 File Organization

```
.planning/bash_fallback/
├── START_HERE.md                    ← YOU ARE HERE
├── INDEX.md                         ← Overview & map
├── README.md                        ← Setup & completion checklist
├── QUICK_REFERENCE.md               ← Code snippets
├── SESSION_1_CRITICAL_FIXES.md      ← Execute first
├── SESSION_2_DEFENSIVE_ENHANCEMENTS.md  ← Execute second
└── ANALYSIS_REPORT.md               ← Deep analysis (optional)
```

---

## 🎓 Key Concepts

### What Changes Will Be Made?

**SESSION 1: 5 Changes**
- Change `command/gsd` → `commands/gsd` in install.sh (2 locations)
- Change `command` → `commands` in install.js (1 location)
- Add source directory validation to install.js (1 block)

**SESSION 2: 8 Enhancements**
- Improved tilde expansion
- File operation error checking
- Directory creation validation
- Color codes and better messages
- Special character handling
- Installation summary

### Files That Get Modified

```
gsd-opencode/bin/install.sh    ← ~10 changes across 8 functions
gsd-opencode/bin/install.js    ← 3 changes (2 lines + 1 validation block)
```

### Files That DON'T Change
- No changes to gsd.js, gsd-install.js
- No changes to package.json
- No changes to source directories (agents, commands, get-shit-done)

---

## ⚠️ Important Notes

### Prerequisites
- Bash 4.0+ (already have on any modern system)
- Standard Unix tools (sed, grep, find, mkdir, cp)
- No Node.js required for SESSION 1 & 2
- Optional: Node.js if testing install.js

### Safety
- All changes are non-destructive
- You can undo with git if needed
- Test installations use temp directories
- No system-wide modifications

### Time Investment
- Worth it: Pure-bash fallback means no Node.js dependency
- Reusable: These patterns useful for other bash scripts
- Maintainable: Better error handling = fewer bugs

---

## 🎯 Success Criteria

### After SESSION 1, All These Must Pass:
```bash
✅ bash install.sh --help         # Runs without error
✅ bash install.sh --local        # Creates .opencode directory
✅ ls .opencode/command/gsd       # Files exist
✅ cat .opencode/get-shit-done/VERSION  # Shows version
```

### After SESSION 2, All These Must Pass:
```bash
✅ Colored output appears in terminal
✅ Error messages are clear and helpful
✅ Works with paths containing spaces
✅ Tilde expansion works for ~user/ patterns
✅ Installation summary displayed at end
```

---

## 💡 Pro Tips

1. **Read the whole plan before executing** - Context matters
2. **Make one change at a time** - Test each individually  
3. **Use QUICK_REFERENCE.md while coding** - Copy/paste from there
4. **Follow exact line numbers** - They won't shift if you go in order
5. **Run all verification tests** - Don't skip them
6. **Keep git clean** - Commit after each session

---

## 🤔 Common Questions

**Q: Do I have to do SESSION 2?**  
A: No, SESSION 1 is critical. SESSION 2 is recommended but optional.

**Q: Can I do SESSION 2 without SESSION 1?**  
A: No, SESSION 2 requires SESSION 1 to be complete first.

**Q: Will this break anything?**  
A: No, these are bug fixes. Current scripts are already broken.

**Q: How long does each session take?**  
A: SESSION 1: 30-45 min, SESSION 2: 45-60 min

**Q: Do I need to understand all the code?**  
A: No, instructions are step-by-step. Understanding helps but isn't required.

**Q: What if I make a mistake?**  
A: Just undo with git and try again. Each step is reversible.

---

## 🚀 Ready? Start Here:

1. **Next Step:** Read [INDEX.md](INDEX.md) (2 min)
2. **Then:** Read [README.md](README.md) (5-10 min)
3. **Then:** Open [SESSION_1_CRITICAL_FIXES.md](SESSION_1_CRITICAL_FIXES.md)
4. **Execute:** Follow instructions in SESSION 1
5. **Repeat:** Steps 3-4 for SESSION 2 (optional)

---

## 📞 Need Help?

Each plan file includes:
- ✅ Detailed problem descriptions
- ✅ Exact file locations and line numbers
- ✅ Before/after code examples
- ✅ Step-by-step instructions
- ✅ Verification tests
- ✅ Success criteria
- ✅ Notes and tips

If something is unclear, see the relevant SESSION file for full context.

---

## 📊 Documentation Summary

| File | Lines | Purpose | Priority |
|------|-------|---------|----------|
| START_HERE.md | ~200 | This overview | READ FIRST |
| INDEX.md | ~226 | Navigation guide | READ SECOND |
| README.md | ~259 | Setup & checklist | BEFORE SESSION |
| SESSION_1 | ~191 | Critical fixes | EXECUTE FIRST |
| SESSION_2 | ~448 | Enhancements | EXECUTE SECOND |
| QUICK_REFERENCE.md | ~215 | Code snippets | USE WHILE EXECUTING |
| ANALYSIS_REPORT.md | ~374 | Deep analysis | REFERENCE (optional) |

**Total: ~1900 lines of detailed guidance**

---

## ⚡ TL;DR (Too Long; Didn't Read)

**Problem:** install.sh and install.js are broken (look for wrong directory)

**Solution:** 
- SESSION 1: Fix the bugs (5 changes, 30-45 min)
- SESSION 2: Add improvements (8 enhancements, 45-60 min)

**Result:** Production-ready pure-bash installer without Node.js

**Start:** Read [INDEX.md](INDEX.md) now

---

**Last Updated:** 2026-02-14  
**Status:** ✅ Ready for Execution  
**Next Step:** Open INDEX.md →
