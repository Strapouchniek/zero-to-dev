# Zero to Dev

One-command setup for non-tech folks — installs the dev prerequisites so you don't have to.

This script installs everything your Mac needs before you can use tools like **Cursor**, **Claude Code**, or collaborate on **GitHub**. It handles Xcode, Homebrew, Git, Node.js, and Oh My Zsh so you don't have to figure it out yourself.

## How to use

Open **Terminal** on your Mac and paste this command:

```bash
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Strapouchniek/zero-to-dev/main/install.sh)"
```

That's it. The script will guide you through every step.

> **Don't know how to open Terminal?** Press `Cmd + Space`, type `Terminal`, press Enter.

> **On a managed Mac (e.g. Sanofi)?** The script will detect if you need to elevate your privileges and guide you automatically.

## What gets installed

| # | Tool | What it does |
|---|------|--------------|
| 1 | Xcode Command Line Tools | Apple developer essentials |
| 2 | Homebrew | Lets you install developer tools easily |
| 3 | Git | Tracks changes in your code |
| 4 | Node.js | Runs JavaScript (needed by many tools) |
| 5 | Oh My Zsh | Makes your terminal nicer to use |

Once done, your Mac is ready for **Cursor**, **Claude Code**, **GitHub**, and any tool that needs Git or Node.js.

## Requirements

- A Mac running **macOS Sonoma (14) or later**
- An internet connection
- Admin rights (the script will tell you if you don't have them)

## FAQ

**Do I need a GitHub account?**
No. The command above works without any account.

**Does this only work with Cursor?**
No. The dev environment this script installs is universal — it works with Cursor, Claude Code, VS Code, or any tool that needs Git and Node.js.

**What if some tools are already installed?**
The script detects what you already have, skips what's up to date, and upgrades what's outdated.

**Will it break my existing settings?**
No. Git identity (`user.name`, `user.email`) is left untouched if already configured.

**Can I run it again?**
Yes, as many times as you want. It only installs or upgrades what's needed.

**My Terminal closed when I elevated my privileges!**
That's expected on managed Macs. The script prepared iTerm2 for you — open it (Spotlight: `Cmd + Space` → `iTerm`) and paste the command shown on screen.

---

## For contributors

### Run from a local clone

```bash
git clone https://github.com/Strapouchniek/zero-to-dev.git
cd zero-to-dev
zsh setup.sh
```

### Project structure

```
zero-to-dev/
├── install.sh         ← bootstrap: downloads everything, runs setup.sh
├── setup.sh           ← main entry point
└── modules/
    ├── utils.sh       ← colors, logging, spinner, confetti
    ├── admin.sh       ← admin rights check, iTerm2 migration
    ├── xcode.sh       ← Xcode CLT installer
    ├── homebrew.sh    ← Homebrew installer
    ├── git.sh         ← Git install + config
    ├── node.sh        ← Node.js installer
    └── omz.sh         ← Oh My Zsh installer
```

### Installation order

The tools are installed in sequence — each depends on the previous:

1. **Xcode CLT** → required by Homebrew and Git
2. **Homebrew** → installs Git and Node.js
3. **Git** → installed via Homebrew
4. **Node.js** → installed via Homebrew
5. **Oh My Zsh** → modifies `.zshrc`, so goes last

### Limitations

Homebrew requires **macOS Sonoma (14) or later**. The script checks this at startup and exits with a clear message if the requirement is not met.
