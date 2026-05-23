#!/bin/bash
# Build User & Admin docs (deployment, features, operations, assistant)
set -euo pipefail

SITE_DIR="/home/krle/repos/forge-platform/forgeplatform.github.io"
DOCS_DIR="$SITE_DIR/docs"

python3 -c "import markdown" 2>/dev/null || pip install markdown

# Format: ["source.md"]="output.html|Title|SEO description"
declare -A DOCS
# Getting Started
DOCS["forge-deploy/docs/01-architecture-overview.md"]="architecture.html|Architecture Overview|Forge Platform architecture: Django REST API, Celery task engine, Receptor mesh networking, React UI, PostgreSQL, Redis. Component diagram, request flow, and deployment topology for the open-source AWX alternative."
DOCS["forge-deploy/docs/07-docker-deployment.md"]="deployment.html|Docker Deployment|Deploy Forge Platform with Docker Compose: install, configure, scale, and operate the open-source Ansible automation platform on a single host. Production-ready compose stack with PostgreSQL, Redis, Nginx, and OpenTelemetry."
# Features
DOCS["forge-backend/docs/13-dynamic-surveys.md"]="dynamic-surveys.html|Dynamic Surveys|Dynamic surveys in Forge Platform — define per-job-template input forms with regex validation, conditional fields, and prompt-on-launch parameters for Ansible playbook execution."
DOCS["forge-backend/docs/14-audit-trail.md"]="audit-trail.html|Audit Trail|Audit trail in Forge Platform — every state change is recorded with actor, resource, before/after diff. Compliance-ready audit logging for Ansible automation and infrastructure changes."
DOCS["forge-backend/docs/15-event-driven-automation.md"]="event-driven.html|Event-Driven Automation|Event-driven automation in Forge Platform — webhook receivers trigger Ansible jobs from GitHub, GitLab, Prometheus Alertmanager, and external systems. EDA without Ansible Rulebook."
DOCS["forge-backend/docs/16-drift-detection.md"]="drift-detection.html|Drift Detection|Drift detection in Forge Platform — periodic comparison of declared inventory vs actual cloud state, with alert rules and remediation workflows. Built-in alternative to standalone drift tools."
DOCS["forge-backend/docs/17-self-service-portal.md"]="self-service.html|Self-Service Portal|Self-service portal in Forge Platform — end users request access and resources via approval workflows, without admin intervention. Reduces ops toil and shortens cycle time."
DOCS["forge-backend/docs/18-oidc-webauthn.md"]="oidc-webauthn.html|OIDC + WebAuthn|OIDC and WebAuthn authentication in Forge Platform — native support for Keycloak, Authentik, Auth0, Okta, Azure AD, plus passkeys and hardware security keys for MFA."
DOCS["forge-backend/docs/19-policy-as-code.md"]="policy-as-code.html|Policy-as-Code (OPA)|Policy-as-code in Forge Platform with Open Policy Agent (OPA) — enforce job execution policies, mandatory tags, time windows, blast-radius limits, and compliance rules."
DOCS["forge-backend/docs/20-iac-scanning.md"]="iac-scanning.html|IaC Scanning|IaC scanning in Forge Platform — Terraform, CloudFormation, and Pulumi static analysis with Checkov integration. Catch misconfigurations and security issues before deployment."
DOCS["forge-backend/docs/21-observability.md"]="observability.html|Observability|OpenTelemetry observability in Forge Platform — distributed traces, metrics, and structured logs from API to Celery task workers to Receptor execution, all correlated by trace ID."
DOCS["forge-backend/docs/22-multi-tenancy.md"]="multi-tenancy.html|Multi-Tenancy|Multi-tenancy in Forge Platform — hard tenant isolation, per-tenant resource quotas, separated audit trails. Run multiple organizations on a single Forge instance securely."
DOCS["forge-backend/docs/23-recommendations.md"]="recommendations.html|Recommendations Engine|Recommendations engine in Forge Platform — surfaces optimization suggestions for job templates, schedules, and resource utilization. Data-driven hints for automation hygiene."
# AI Assistant
DOCS["forge-assistant/docs/architecture.md"]="assistant-architecture.html|AI Assistant Architecture (Preview)|Forge AI Assistant (UNDER ACTIVE DEVELOPMENT — not production-ready) — FastAPI service with embedded Ollama LLM runtime and ChromaDB vector store. Fully self-hosted preview, runs on CPU or GPU."
DOCS["forge-assistant/docs/api-reference.md"]="assistant-api.html|AI Assistant API (Preview)|Forge AI Assistant API reference (UNDER ACTIVE DEVELOPMENT — not production-ready). HTTP endpoints for chat completion, RAG queries, model management. Preview only, APIs may change."
DOCS["forge-assistant/docs/configuration.md"]="assistant-config.html|AI Assistant Configuration (Preview)|Forge AI Assistant configuration (UNDER ACTIVE DEVELOPMENT — not production-ready). Model selection (Ollama-compatible), system prompts, RAG knowledge sources. Settings may change in future releases."
DOCS["forge-assistant/docs/deployment.md"]="assistant-deploy.html|AI Assistant Deployment (Preview)|Deploy Forge AI Assistant (UNDER ACTIVE DEVELOPMENT — not production-ready) — all-in-one container with Ollama and ChromaDB. Preview release for early adopters, not recommended for production."
# Operations
DOCS["forge-deploy/docs/HANDBOOK.md"]="user-handbook.html|User Handbook|Forge Platform User Handbook — how to launch jobs, manage inventories, configure surveys, schedule recurring runs, and use the self-service portal. Step-by-step guide for end users."
DOCS["forge-deploy/docs/ADMIN_HANDBOOK.md"]="admin-handbook.html|Administrator Handbook|Forge Platform Administrator Handbook — system administration, user and RBAC management, scaling, backup/restore, troubleshooting, monitoring, and security hardening best practices."
# Release Notes
DOCS["forge-deploy/docs/RELEASE_NOTES_v2026.03.0.md"]="release-2026.03.0.html|Release Notes v2026.03.0|Forge Platform v2026.03.0 release notes — new features, bug fixes, breaking changes, dependency updates, and upgrade guide for the open-source Ansible automation platform."
DOCS["forge-deploy/docs/RELEASE_NOTES_v2026.04.0.md"]="release-2026.04.0.html|Release Notes v2026.04.0|Forge Platform v2026.04.0 release notes — new features, bug fixes, breaking changes, and step-by-step upgrade guide for production deployments."
DOCS["forge-deploy/docs/RELEASE_NOTES_v2026.05.0.md"]="release-2026.05.0.html|Release Notes v2026.05.0|Forge Platform v2026.05.0 release notes — operator v1.0.0 with 9 CRDs and multi-cluster routing, k3s deployment scale-up, backend migration fix, public ghcr.io image distribution."

generate_page() {
  local src="$1" out="$2" title="$3" description="$4"
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

  local canonical="https://forgeplatform.github.io/docs/$out"
  local og_image="https://forgeplatform.github.io/assets/img/screenshots/dashboard-hero.png"

  # Escape double quotes in description for HTML attribute safety
  local description_safe="${description//\"/&quot;}"
  local title_safe="${title//\"/&quot;}"

  cat > "$DOCS_DIR/$out" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title_safe} — Forge Platform Docs</title>
  <meta name="description" content="${description_safe}">
  <meta name="keywords" content="Forge Platform, AWX alternative, Ansible automation, open source DevOps, Kubernetes operator, Helm chart, self-hosted, infrastructure automation">
  <meta name="author" content="Krstan Vjestica">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="${canonical}">
  <meta property="og:type" content="article">
  <meta property="og:title" content="${title_safe} — Forge Platform Docs">
  <meta property="og:description" content="${description_safe}">
  <meta property="og:url" content="${canonical}">
  <meta property="og:site_name" content="Forge Platform">
  <meta property="og:locale" content="en_US">
  <meta property="og:image" content="${og_image}">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${title_safe} — Forge Platform Docs">
  <meta name="twitter:description" content="${description_safe}">
  <meta name="twitter:image" content="${og_image}">
  <script type="application/ld+json">
  {"@context":"https://schema.org","@type":"TechArticle","headline":"${title_safe}","description":"${description_safe}","url":"${canonical}","author":{"@type":"Person","name":"Krstan Vjestica"},"publisher":{"@type":"Organization","name":"Forge Platform","url":"https://forgeplatform.github.io/"},"image":"${og_image}","inLanguage":"en"}
  </script>
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
  IFS='|' read -r out title description <<< "${DOCS[$src]}"
  generate_page "$src" "$out" "$title" "$description"
done
echo "Done!"
