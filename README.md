
# `why` — The Package Reason Manager

**`why`** is a generic wrapper for any package manager (`pacman`, `npm`, `pip`, `cargo`, etc.). It prevents system bloat by forcing you to declare an intent for every package you install or remove.

It turns your package history into a self-documenting git-journal, ensuring you never look at a package and think, *"What does this even do and why is it here?"*

## 1. The Core Philosophy
The main goal is a **forced nudge**. The command will refuse to execute unless you provide a reason. It stores these reasons in a local database and tracks every change using an internal Git repository.

## 2. Command Structure
The tool is designed to be flexible. It follows a standard pattern:
`why <action> <command string> <packages> <reason>`

### Install / Add (`install`, `-S`, `add`)
```bash
$ why install "sudo pacman -S" "nvim tree git" "Need a lighter dev environment for CS course"
```
* **What happens:** Executes the pacman command. If successful, it logs the reason to `.rmm.db`, appends to `install.bash`, and commits the change to the internal `.git` folder.

### Uninstall / Remove (`uninstall`, `-Rs`, `-R`, `remove`)
```bash
$ why uninstall "pip uninstall" "requests" "Finished the API scraping project"
```
* **What happens:** Removes the items and updates the reason in the DB by concatenating the removal reason with the install history.

### Reason / Query (`reason`, `why`, `history`)
```bash
$ why reason nvim
> nvim: [INSTALLED] Need a lighter dev environment for CS course <REMOVED> i quit my course :( <REINSTALLED> i love CS now
```
* **What happens:** Shows the full lifecycle of a package. Even if you are currently installing a package, `why` will show you its previous history so you know why you deleted it last time.

### Iterate / Audit (`iterate`, `audit`)
Useful for bringing an existing system under the control of `why`.
```bash
$ why iterate "pacman -Qqe" "pacman"
```
* **What happens:** Runs the listing command, checks each package against the DB, and prompts you for a reason for any "unknown" packages found in that registry.

---

## 3. Technical Implementation
To keep `why` "solid" and portable, it relies on three pillars:

* **Registry Awareness:** The database stores packages paired with their manager (e.g., `pacman|nvim` vs `npm|nvim`) to avoid collisions.
* **Internal Git Audit:** The application folder contains a hidden `.git` directory. Every time you change your system, `why` makes an automatic commit with your reason as the message.
* **The "Install Bash":** A flat file (`install.bash`) that records every successful installation command, allowing you to replicate your setup on a new machine easily.

## 4. Setup
1. Clone the repository to a folder of your choice (e.g., `~/.config/why`).
2. Link the executable to your path:
   ```bash
   ln -s ~/.config/why/why.sh ~/.local/bin/why
   ```
3. Initialize the repo:
   ```bash
   cd ~/.config/why && git init
   ```

---

## What makes it "Solid"?

| Feature | Benefit |
| :--- | :--- |
| **Command Agnostic** | Works with `pacman`, `yay`, `pip`, `npm`, `cargo`, `go`, etc. |
| **Atomic Logging** | The reason is only saved if the installation command returns an exit code of `0`. |
| **History Confrontation** | You are forced to see *why* you uninstalled something before you reinstall it. |
| **Audit Trail** | Use `git log` inside the `why` directory to see a perfect timeline of your system's evolution. |

---
