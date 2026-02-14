# Bash Fallback Installation Plans - Index

**Location:** `.planning/bash_fallback/`  
**Status:** Ready for execution  
**Last Updated:** 2026-02-14

---

## 📑 Documents in This Directory

### 🎯 Start Here
- **[README.md](README.md)** - Complete overview and setup guide
  - What problem are we solving?
  - How to execute the plans
  - Progress tracking checklist
  - Best practices

---

### 📋 Execution Plans (Follow in Order)

#### Phase 1: Critical Bug Fixes
- **[SESSION_1_CRITICAL_FIXES.md](SESSION_1_CRITICAL_FIXES.md)**
  - 🔴 CRITICAL priority
  - 30-45 minutes
  - Fixes `command/` vs `commands/` directory issue
  - Adds source directory validation
  - Must complete FIRST before anything else
  - 5 specific changes to 2 files

#### Phase 2: Production Enhancements
- **[SESSION_2_DEFENSIVE_ENHANCEMENTS.md](SESSION_2_DEFENSIVE_ENHANCEMENTS.md)**
  - 🟡 MEDIUM priority (optional but recommended)
  - 45-60 minutes
  - Requires SESSION 1 completion
  - Enhanced tilde expansion
  - Better error handling and validation
  - Colored output and improved messages
  - 8 enhancements to install.sh

#### Phase 3: Alignment (Future)
- **[SESSION_3_ALIGN_BEHAVIOR.md](SESSION_3_ALIGN_BEHAVIOR.md)** *(Not yet created)*
  - 🟢 LOW priority
  - Optional: Align install.js with enhanced install.sh
  - For future implementation

---

### 🚀 Quick Reference
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Code snippets for fast lookup
  - All changes condensed for quick reference during execution
  - Before/after code blocks
  - Verification commands
  - Not a substitute for full plans - use alongside them

---

## 🗺️ How to Use These Plans

### First Time?
1. Read **README.md** (5-10 minutes) for overview
2. Then read **SESSION_1_CRITICAL_FIXES.md** completely (15-20 minutes)
3. Execute Session 1 following the exact instructions
4. Verify success with provided tests

### Ready for Production?
1. Complete SESSION 1 first
2. Read **SESSION_2_DEFENSIVE_ENHANCEMENTS.md** completely
3. Execute Session 2 enhancements
4. Verify success with provided tests

### Need Quick Lookup?
- Use **QUICK_REFERENCE.md** while implementing
- Cross-reference back to full session plans for context

---

## 🔧 What Gets Fixed

### SESSION 1 (Critical)
| Issue | File | Fix |
|-------|------|-----|
| Wrong source path | install.sh, install.js | Change `command/` to `commands/` |
| No validation | install.js | Add source directory checks |

### SESSION 2 (Enhancements)
| Issue | File | Fix |
|-------|------|-----|
| Limited tilde | install.sh | Support ~user/ patterns |
| No error checks | install.sh | Add validation on all operations |
| Plain output | install.sh | Add colors and formatting |
| Unclear errors | install.sh | Improve error messages |
| No edge case handling | install.sh | Handle spaces/special chars |

---

## 📊 Execution Checklist

```
Session 1: [ ] Read plan [ ] Execute [ ] Verify [ ] Commit
Session 2: [ ] Read plan [ ] Execute [ ] Verify [ ] Commit
Session 3: (Future)
```

---

## 📂 Related Files in Repository

```
gsd-opencode/
├── bin/
│   ├── install.sh          ← Pure bash installer (MAIN FOCUS)
│   ├── install.js          ← Node.js installer (npx target)
│   ├── gsd-install.js      ← Legacy shim
│   └── gsd.js              ← Main CLI
├── commands/               ← Commands directory (source)
├── agents/                 ← Agents directory (source)
├── get-shit-done/          ← Skill directory (source)
└── package.json

.planning/bash_fallback/    ← YOU ARE HERE
├── README.md
├── SESSION_1_CRITICAL_FIXES.md
├── SESSION_2_DEFENSIVE_ENHANCEMENTS.md
├── QUICK_REFERENCE.md
└── INDEX.md                ← This file
```

---

## 🎯 Goals

### Goal 1: Make Scripts Work (SESSION 1)
- Both scripts can find source files
- Both can copy files to destination
- Both perform complete installation

### Goal 2: Make Bash Production-Ready (SESSION 2)
- Robust error handling
- User-friendly output
- Edge case handling
- Clear diagnostic messages

### Goal 3: Ensure Parity (SESSION 3)
- install.js equals install.sh in robustness
- Side-by-side tests prove identical behavior
- Both are suitable for production use

---

## 💡 Tips for Success

1. **Read the entire plan before starting** - Don't skip to "just the code"
2. **Make one change at a time** - Test each change individually
3. **Follow exact line numbers** - They won't shift if you do things in order
4. **Run all verification tests** - Don't skip them
5. **Keep notes on any issues** - For future reference or troubleshooting
6. **Commit after each session** - Good version control hygiene

---

## ❓ FAQ

**Q: Can I do SESSION 2 without SESSION 1?**  
A: No. SESSION 1 fixes blocking bugs. SESSION 2 requires those to be working first.

**Q: How long does each session take?**  
A: SESSION 1: 30-45 min, SESSION 2: 45-60 min, SESSION 3: 30-45 min (optional)

**Q: Can I skip SESSION 2?**  
A: Yes. SESSION 1 makes scripts work. SESSION 2 just makes them better.

**Q: Do I need Node.js to execute these plans?**  
A: Only if testing install.js. The main goal is making install.sh work without Node.js.

**Q: What if I encounter issues?**  
A: Check the problem description in the session plan for context. Verify file line numbers haven't shifted. Test changes one at a time.

---

## 🔗 Key Sections to Know

- **Problem Overview:** README.md + each SESSION file intro
- **Exact Changes:** SESSION files have before/after code blocks
- **Verification:** Each SESSION file has "Verification Steps" section
- **Success Criteria:** End of each SESSION file
- **Quick Lookup:** QUICK_REFERENCE.md for code snippets

---

## 📞 Support

All plans include:
- ✅ Detailed problem description
- ✅ Exact file and line number references
- ✅ Before/after code examples
- ✅ Step-by-step execution instructions
- ✅ Verification tests with expected output
- ✅ Success criteria checklist
- ✅ Notes and tips

If something is unclear:
1. Re-read the section in the relevant SESSION file
2. Check Notes at the end of the section
3. Review the problem description for context

---

## 🎓 Learning Outcomes

After completing these plans, you will have:
- ✅ Fixed critical installer bugs
- ✅ Enhanced bash script error handling
- ✅ Improved user experience with colored output
- ✅ Robust pure-bash installer without external deps
- ✅ Understanding of installation process
- ✅ Best practices for bash script development

---

**Ready to begin?**

Start with: [README.md](README.md)  
Then execute: [SESSION_1_CRITICAL_FIXES.md](SESSION_1_CRITICAL_FIXES.md)

Good luck! 🚀
