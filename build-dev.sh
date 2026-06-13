#!/bin/bash
set -euo pipefail

SITE_DIR="/home/krle/repos/forail-platform/forail-platform.github.io"
DEV_DIR="$SITE_DIR/dev"

python3 -c "import markdown" 2>/dev/null || pip install markdown

declare -A DOCS
DOCS["forail-backend/docs/02-backend-django.md"]="backend.html|Backend (Django)"
DOCS["forail-backend/docs/04-task-engine.md"]="task-engine.html|Task Engine"
DOCS["forail-backend/docs/05-authentication-rbac.md"]="auth-rbac.html|Authentication & RBAC"
DOCS["forail-backend/docs/06-database-schema.md"]="database.html|Database Schema"
DOCS["forail-backend/docs/09-testing-guide.md"]="testing.html|Testing Guide"
DOCS["forail-backend/docs/11-api-reference.md"]="api-reference.html|API Reference"
DOCS["forail-backend/docs/12-configuration-reference.md"]="dev-configuration.html|Configuration Reference"
DOCS["forail-deploy/docs/10-contributing-guide.md"]="contributing.html|Contributing Guide"
DOCS["forail-deploy/docs/08-ci-cd-pipeline.md"]="ci-cd.html|CI/CD Pipeline"
DOCS["forail-frontend/docs/03-frontend-react.md"]="frontend.html|Frontend (React)"

generate_page() {
  local src="$1" out="$2" title="$3"
  local src_path="/home/krle/repos/forail-platform/$src"
  [ ! -f "$src_path" ] && echo "SKIP: $src_path" && return

  local content
  content=$(python3 -c "
import markdown, sys
with open('$src_path', 'r') as f:
    text = f.read()
html = markdown.markdown(text, extensions=['tables', 'fenced_code', 'codehilite', 'toc'])
sys.stdout.write(html)
")

  cat > "$DEV_DIR/$out" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title} — Forail Developer Docs</title>
  <meta name="description" content="${title} — developer documentation for the Forail infrastructure automation platform.">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="https://forail-platform.github.io/dev/${out}">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>
<nav class="nav">
  <div class="nav-inner">
    <a href="../index.html" class="nav-logo">
      <svg viewBox="0 0 32 32" fill="none"><rect width="32" height="32" rx="8" fill="#7c6cf0"/><path d="M8 10h16v2H8zm0 5h12v2H8zm0 5h14v2H8z" fill="#fff"/></svg>
      Forail
    </a>
    <ul class="nav-links">
      <li><a href="../docs/index.html">User Docs</a></li>
      <li><a href="index.html" style="color: var(--primary);">Dev Docs</a></li>
    </ul>
    <a href="https://github.com/forail-platform" class="nav-cta">GitHub</a>
    <button class="nav-toggle" aria-label="Menu">
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12h18M3 6h18M3 18h18"/></svg>
    </button>
  </div>
</nav>
<div class="docs-layout" style="padding: 2rem;">
  <aside class="docs-sidebar">
    <h4>Architecture</h4>
    <a href="backend.html">Backend (Django)</a>
    <a href="frontend.html">Frontend (React)</a>
    <a href="task-engine.html">Task Engine</a>
    <a href="auth-rbac.html">Authentication &amp; RBAC</a>
    <h4>Reference</h4>
    <a href="database.html">Database Schema</a>
    <a href="api-reference.html">API Reference</a>
    <a href="dev-configuration.html">Configuration</a>
    <h4>Workflow</h4>
    <a href="testing.html">Testing Guide</a>
    <a href="ci-cd.html">CI/CD Pipeline</a>
    <a href="contributing.html">Contributing</a>
    <h4>&nbsp;</h4>
    <a href="../docs/index.html">User &amp; Admin Docs</a>
    <a href="../index.html">Home</a>
  </aside>
  <main class="docs-content">
${content}
  </main>
</div>
<footer class="footer">
  <div class="footer-links">
    <a href="../index.html">Home</a>
    <a href="../docs/index.html">User Docs</a>
    <a href="https://github.com/forail-platform">GitHub</a>
  </div>
  <p>Forail Platform — Apache License 2.0</p>
</footer>
<script src="../assets/js/main.js"></script>
</body>
</html>
HTMLEOF
  echo "OK: $out"
}

echo "Building developer docs..."
for src in "${!DOCS[@]}"; do
  IFS='|' read -r out title <<< "${DOCS[$src]}"
  generate_page "$src" "$out" "$title"
done
echo "Done!"
