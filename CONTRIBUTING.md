# Contributing to Red Magic Room

First off, thanks for taking the time to contribute! 🎉

This document guides you through the contribution process, from setting up your environment to understanding our automated release pipeline.

## 🛠 Prerequisites

- **macOS 14.0** or later.
- **Swift 5.9** or later (included with Xcode Command Line Tools).
- **Git**.

## 🚀 Development Workflow

### 1. Clone & Branch
Always create a new branch for your work. We use the `main` branch for production releases.

```bash
git checkout -b feat/my-new-feature
# or
git checkout -b fix/bug-fix
```

### 2. Build & Run
We have a helper script to build and assemble the `.app` bundle.

```bash
# Build only
./build.sh

# Build and launch the app immediately
./build.sh --run
```

The app will be built into the `dist/` directory.

### 3. Commit Messages (Crucial!) 🚨

This project uses **[Conventional Commits](https://www.conventionalcommits.org/)** to automate versions and changelogs. **Your commit message determines the next version number.**

| Commit Type | Effect on Version | Example |
|-------------|-------------------|---------|
| `fix:`      | **Patch** (0.0.x) | `fix: prevent crash when timer ends` |
| `feat:`     | **Minor** (0.x.0) | `feat: add new 'Dark Noise' type` |
| `perf:`     | **Patch** (0.0.x) | `perf: reduce cpu usage` |
| `docs:`     | No Release        | `docs: update readme installation` |
| `chore:`    | No Release        | `chore: update dependencies` |

**Please strictly follow this format.** If you don't, your changes will be merged but a release might not be triggered.

### 4. Pull Requests
1. Push your branch to GitHub.
2. Open a Pull Request (PR) against `main`.
3. The **CI** workflow will run to verify:
   - The project builds successfully.
   - Tests pass (if any).

## 📦 Release Process

We use an automated pipeline (Release Please). You generally **do not** need to manually tag releases.

1. **Merge to Main**: When a PR with `feat:` or `fix:` commits is merged to `main`, a "Release PR" is automatically created/updated by a bot.
2. **Review Release PR**: This PR (usually named `chore(main): release x.y.z`) contains the changelog and version bump.
3. **Approve & Merge Release PR**: Merging *this* specific PR triggers the deployment:
   - **Tag**: A git tag (e.g., `v1.0.1`) is created.
   - **Build**: The app is built, signed, and notarized (Apple-verified).
   - **Publish**: A GitHub Release is created with the `.zip` attached.
   - **Homebrew**: The `warike/homebrew-tools` tap is automatically updated.

## 🔒 Security

- **Secrets**: Never commit `.p12`, `.p8`, or `.key` files. Use GitHub Secrets.
- **Signing**: The `build.sh` script will skip signing if no certificate is found locally (safe for contributors).

## 📄 License
By contributing, you agree that your contributions will be licensed under its MIT License.
