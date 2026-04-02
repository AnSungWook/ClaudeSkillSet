#!/usr/bin/env node

const { execSync, spawn } = require("child_process");
const path = require("path");
const fs = require("fs");

const REPO = "https://github.com/AnSungWook/ClaudeSkillSet.git";
const TMP_DIR = path.join(require("os").tmpdir(), "claude-skills-kit-" + Date.now());
const PROJECT_ROOT = process.cwd();

function main() {
  console.log("");
  console.log("==========================================");
  console.log(" Claude Skills Kit");
  console.log("==========================================");
  console.log("");
  console.log(`Project root: ${PROJECT_ROOT}`);
  console.log("");

  // Check if we're running from npx (package is already local)
  const packageDir = path.resolve(__dirname, "..");
  const setupSh = path.join(packageDir, "setup.sh");

  if (fs.existsSync(setupSh)) {
    // Running from npm package — setup.sh is bundled
    console.log("Running installer...");
    console.log("");
    const child = spawn("bash", [setupSh], {
      cwd: PROJECT_ROOT,
      stdio: "inherit",
      env: { ...process.env },
    });
    child.on("close", (code) => process.exit(code));
  } else {
    // Fallback: clone and run
    console.log("Downloading Claude Skills Kit...");
    try {
      execSync(`git clone --depth 1 ${REPO} "${TMP_DIR}"`, { stdio: "pipe" });
    } catch (e) {
      console.error("Failed to clone repository. Check your network connection.");
      process.exit(1);
    }

    console.log("");
    const child = spawn("bash", [path.join(TMP_DIR, "setup.sh")], {
      cwd: PROJECT_ROOT,
      stdio: "inherit",
      env: { ...process.env },
    });

    child.on("close", (code) => {
      // Cleanup
      try {
        fs.rmSync(TMP_DIR, { recursive: true, force: true });
      } catch (_) {}
      process.exit(code);
    });
  }
}

main();
