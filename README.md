# Executive AI Operating System

Blueprint completo para um **Executive AI Operating System** voltado a um executivo de tecnologia que atua como Tech Lead, Product Leader, Consultor Salesforce, Empreendedor e Gestor de Projetos.

A documentação principal está em [`docs/executive-ai-operating-system.md`](docs/executive-ai-operating-system.md) e cobre as fases 0 a 9, incluindo arquitetura, n8n, dados, prompts, segurança, custos, roadmap, riscos, ROI e critérios de aceite.

## Artefatos

| Arquivo | Descrição |
| --- | --- |
| `docs/executive-ai-operating-system.md` | Documento enterprise detalhado da solução, fases e operação. |
| `docker-compose.yml` | Stack base com n8n, PostgreSQL, Qdrant, Redis, Prometheus, Grafana, Loki e Promtail. |
| `database/schema.sql` | Modelo relacional base para briefings, reuniões, inbox, Jira, PMO, decisões, RAG, agentes e auditoria. |

## Uso sugerido

1. Revisar a arquitetura e ajustar domínios, usuários, políticas de retenção e conectores Microsoft/Jira.
2. Copiar `.env.example` para `.env` quando for criado no ambiente real e preencher segredos fora do Git.
3. Subir a infraestrutura base com Docker Compose.
4. Importar workflows n8n por fase, priorizando Fase 1, Fase 2 e Fase 7.
5. Validar critérios de aceite por fase antes de ampliar automações executivas.
