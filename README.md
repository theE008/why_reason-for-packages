# `why` — The Package Reason Manager

**`why`** is a context-aware wrapper for any package manager (`pacman`, `npm`, `cargo`, `pip`, etc.). It prevents system and project bloat by forcing you to declare an **intent** for every dependency change.

It turns your package history into a self-documenting journal. Whether you are managing your global Arch Linux packages or a specific Rust project, you’ll never have to ask, *"Why did I install this?"* ever again.

---

## 1. Core Logic: Dual-Mode Operation

`why` intelligently detects your environment to keep concerns separated:

### 🌍 Global Mode (System-wide)
If you run `why` anywhere else, it logs to its own home directory (e.g., `~/.config/why`). It maintains a hidden `.git` folder here to provide an invisible, automatic audit trail of your system's evolution.

### 📁 Local Mode (Project-specific)
If the current directory contains a `reasons/` folder, `why` automatically switches to **Local Mode**. 
* **Database:** Stored inside `./reasons/`.
* **Git:** `why` stays quiet and does **not** auto-commit. It leaves the changes staged/unstaged so they can be part of your project's main git commits.
* **Config:** Uses `./reasons/why.conf` to simplify commands.

---

## 2. Command Structure

### Basic Usage
`why <action> [command] <packages> <reason>`

### Simplified Usage (with `why.conf`)
If a `why.conf` exists in your project's `reasons/` folder, you can skip the command string:
```bash
$ why install "serde" "Need JSON parsing for the API"
```

---

## 3. Key Actions

### `install` / `add`
Executes the installation. If (and only if) the command succeeds, it logs the reason.
* **Manual:** `why install "sudo pacman -S" "gimp" "Need to edit thumbnails"`
* **Config-based:** `why install "reqwest" "Async HTTP client"`

### `uninstall` / `remove`
Removes the package and logs the removal reason, appending it to the package's lifecycle history.
```bash
$ why remove "requests" "Switching to httpx for trio support"
```

### `reason` / `history`
Shows the full "birth-to-death" timeline of a package.
```bash
$ why reason nvim
> [2024-05-10] nvim: [INSTALLED] Trying out Neovim for coding
> [2024-06-12] nvim: <REMOVED> Too much configuration overhead
```

### `iterate` / `audit`
Used to bring an existing system under control. It loops through your installed packages and asks for reasons for anything not yet in the `why` database.
```bash
$ why iterate "cargo install --list" "cargo"
```

### `status`
Check your current mode (Global vs Local) and see active configuration defaults.

---

## 4. Configuration (`why.conf`)
To avoid typing the same package manager commands over and over, place a `why.conf` inside your `reasons/` folder:

```ini
install: cargo add
remove: cargo rm
iterate: cargo tree --depth 1
```

---

## 5. Setup

1.  **Clone & Link:**
    ```bash
    git clone git@github.com:theE008/why_reason-for-packages.git ~/.config/why
    ln -s ~/.config/why/why.sh ~/.local/bin/why
    ```
2.  **Initialize Project (Optional):**
    In any project where you want local tracking:
    ```bash
    mkdir reasons
    touch reasons/why.conf
    ```

---

## What makes it "Solid"?

| Feature | Benefit |
| :--- | :--- |
| **Command Agnostic** | Works with anything: `apt`, `npm`, `go`, `pip`, etc. |
| **Atomic Logging** | Only logs if the command exit code is `0`. No junk logs for typos. |
| **Context Aware** | Keeps system logs out of your projects and project logs out of your system. |
| **Audit Trail** | In Global mode, use `git log` in the `why` dir to see a timeline of your life. |

---
