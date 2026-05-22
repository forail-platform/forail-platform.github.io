#!/bin/bash
# Build User & Admin docs (deployment, features, operations, assistant)
set -euo pipefail

SITE_DIR="/home/krle/repos/forge-platform/forgeplatform.github.io"
DOCS_DIR="$SITE_DIR/docs"

python3 -c "import markdown" 2>/dev/null || pip install markdown

declare -A DOCS
# Getting Started
DOCS["forge-deploy/docs/01-architecture-overview.md"]="architecture.html|Architecture Overview"
DOCS["forge-deploy/docs/07-docker-deployment.md"]="deployment.html|Docker Deployment"
# Features
DOCS["forge-backend/docs/13-dynamic-surveys.md"]="dynamic-surveys.html|Dynamic Surveys"
DOCS["forge-backend/docs/14-audit-trail.md"]="audit-trail.html|Audit Trail"
DOCS["forge-backend/docs/15-event-driven-automation.md"]="event-driven.html|Event-Driven Automation"
DOCS["forge-backend/docs/16-drift-detection.md"]="drift-detection.html|Drift Detection"
DOCS["forge-backend/docs/17-self-service-portal.md"]="self-service.html|Self-Service Portal"
DOCS["forge-backend/docs/18-oidc-webauthn.md"]="oidc-webauthn.html|OIDC + WebAuthn"
DOCS["forge-backend/docs/19-policy-as-code.md"]="policy-as-code.html|Policy-as-Code (OPA)"
DOCS["forge-backend/docs/20-iac-scanning.md"]="iac-scanning.html|IaC Scanning"
DOCS["forge-backend/docs/21-observability.md"]="observability.html|Observability"
DOCS["forge-backend/docs/22-multi-tenancy.md"]="multi-tenancy.html|Multi-Tenancy"
DOCS["forge-backend/docs/23-recommendations.md"]="recommendations.html|Recommendations Engine"
# AI Assistant
DOCS["forge-assistant/docs/architecture.md"]="assistant-architecture.html|AI Assistant Architecture"
DOCS["forge-assistant/docs/api-reference.md"]="assistant-api.html|AI Assistant API"
DOCS["forge-assistant/docs/configuration.md"]="assistant-config.html|AI Assistant Configuration"
DOCS["forge-assistant/docs/deployment.md"]="assistant-deploy.html|AI Assistant Deployment"
# Operations
DOCS["forge-deploy/docs/HANDBOOK.md"]="user-handbook.html|User Handbook"
DOCS["forge-deploy/docs/ADMIN_HANDBOOK.md"]="admin-handbook.html|Administrator Handbook"
# Release Notes
DOCS["forge-deploy/docs/RELEASE_NOTES_v2026.03.0.md"]="release-2026.03.0.html|Release Notes v2026.03.0"
DOCS["forge-deploy/docs/RELEASE_NOTES_v2026.04.0.md"]="release-2026.04.0.html|Release Notes v2026.04.0"
DOCS["forge-deploy/docs/RELEASE_NOTES_v2026.05.0.md"]="release-2026.05.0.html|Release Notes v2026.05.0"

generate_page() {
  local src="$1" out="$2" title="$3"
  local src_path="/home/krle/repos/forge-platform/$src"
  [ ! -f "$src_path" ] && echo "SKIP: $src_path" && return

  local content
  content=$(python3 -c "
import markdown, sys
with open('$src_path', 'r') as f:
    text = f.read()
html = markdown.markdown(text, extensions=['tables', 'fenced_code', 'codehilite', 'toc'])
sys.stdout.write(html)
")

  cat > "$DOCS_DIR/$out" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title} — Forge Platform Docs</title>
  <meta name="description" content="${title} — documentation for the Forge infrastructure automation platform.">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="https://forgeplatform.github.io/docs/${out}">
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
      Forge
    </a>
    <ul class="nav-links">
      <li><a href="index.html" style="color: var(--primary);">User Docs</a></li>
      <li><a href="../dev/index.html">Dev Docs</a></li>
    </ul>
    <a href="https://github.com/forgeplatform" class="nav-cta">GitHub</a>
    <button class="nav-toggle" aria-label="Menu">
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12h18M3 6h18M3 18h18"/></svg>
    </button>
  </div>
</nav>
<div class="docs-layout" style="padding: 2rem;">
  <aside class="docs-sidebar">
    <h4>Getting Started</h4>
    <a href="architecture.html">Architecture</a>
    <a href="deployment.html">Deployment (Docker)</a>
    <a href="kubernetes.html">Kubernetes</a>
    <a href="operator-v1.html">Operator v1.0.0</a>
    <h4>Features</h4>
    <a href="event-driven.html">Event-Driven Automation</a>
    <a href="drift-detection.html">Drift Detection</a>
    <a href="policy-as-code.html">Policy-as-Code</a>
    <a href="self-service.html">Self-Service Portal</a>
    <a href="multi-tenancy.html">Multi-Tenancy</a>
    <a href="oidc-webauthn.html">OIDC + WebAuthn</a>
    <a href="iac-scanning.html">IaC Scanning</a>
    <a href="observability.html">Observability</a>
    <a href="dynamic-surveys.html">Dynamic Surveys</a>
    <a href="audit-trail.html">Audit Trail</a>
    <a href="recommendations.html">Recommendations</a>
    <h4>AI Assistant</h4>
    <a href="assistant-architecture.html">Architecture</a>
    <a href="assistant-api.html">API Reference</a>
    <a href="assistant-config.html">Configuration</a>
    <a href="assistant-deploy.html">Deployment</a>
    <h4>Operations</h4>
    <a href="user-handbook.html">User Handbook</a>
    <a href="admin-handbook.html">Admin Handbook</a>
    <h4>Release Notes</h4>
    <a href="release-2026.05.0.html">v2026.05.0</a>
    <a href="release-2026.04.0.html">v2026.04.0</a>
    <a href="release-2026.03.0.html">v2026.03.0</a>
    <h4>&nbsp;</h4>
    <a href="../dev/index.html">Developer Docs</a>
    <a href="../index.html">Home</a>
  </aside>
  <main class="docs-content">
${content}
  </main>
</div>
<footer class="footer">
  <div class="footer-links">
    <a href="../index.html">Home</a>
    <a href="../dev/index.html">Dev Docs</a>
    <a href="https://github.com/forgeplatform">GitHub</a>
  </div>
  <p>Forge Platform — Apache License 2.0</p>
</footer>
<script src="../assets/js/main.js"></script>
</body>
</html>
HTMLEOF
  echo "OK: $out"
}

echo "Building user/admin docs..."
for src in "${!DOCS[@]}"; do
  IFS='|' read -r out title <<< "${DOCS[$src]}"
  generate_page "$src" "$out" "$title"
done
echo "Done!"
