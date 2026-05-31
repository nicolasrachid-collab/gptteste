CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TYPE source_system AS ENUM ('outlook', 'calendar', 'teams', 'jira', 'manual', 'shortcut', 'dashboard', 'rag');
CREATE TYPE priority_level AS ENUM ('critical', 'high', 'medium', 'low', 'informational');
CREATE TYPE work_status AS ENUM ('open', 'in_progress', 'waiting', 'blocked', 'done', 'cancelled');
CREATE TYPE recommendation_status AS ENUM ('proposed', 'accepted', 'rejected', 'completed');

CREATE TABLE executives (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  timezone TEXT NOT NULL DEFAULT 'America/Sao_Paulo',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE integration_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID NOT NULL REFERENCES executives(id),
  provider source_system NOT NULL,
  tenant_id TEXT,
  account_ref TEXT NOT NULL,
  scopes TEXT[] NOT NULL DEFAULT '{}',
  token_secret_ref TEXT NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT true,
  last_sync_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE raw_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID NOT NULL REFERENCES executives(id),
  source source_system NOT NULL,
  external_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL,
  payload JSONB NOT NULL,
  content_hash TEXT NOT NULL,
  ingested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (source, external_id, content_hash)
);

CREATE TABLE email_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID NOT NULL REFERENCES executives(id),
  outlook_message_id TEXT NOT NULL UNIQUE,
  subject TEXT NOT NULL,
  sender_email TEXT NOT NULL,
  recipients JSONB NOT NULL DEFAULT '[]',
  received_at TIMESTAMPTZ NOT NULL,
  is_unread BOOLEAN NOT NULL DEFAULT true,
  importance TEXT,
  ai_priority priority_level,
  ai_category TEXT,
  requires_response BOOLEAN NOT NULL DEFAULT false,
  waiting_on TEXT,
  suggested_reply TEXT,
  follow_up_at TIMESTAMPTZ,
  summary TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE calendar_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID NOT NULL REFERENCES executives(id),
  outlook_event_id TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  organizer_email TEXT,
  attendees JSONB NOT NULL DEFAULT '[]',
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ NOT NULL,
  location TEXT,
  teams_join_url TEXT,
  conflict_group UUID,
  preparation_brief TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE teams_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID NOT NULL REFERENCES executives(id),
  teams_message_id TEXT NOT NULL UNIQUE,
  team_name TEXT,
  channel_name TEXT,
  chat_id TEXT,
  sender_email TEXT,
  sent_at TIMESTAMPTZ NOT NULL,
  mentions_executive BOOLEAN NOT NULL DEFAULT false,
  ai_importance priority_level,
  summary TEXT,
  permalink TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE jira_issues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID NOT NULL REFERENCES executives(id),
  issue_key TEXT NOT NULL UNIQUE,
  project_key TEXT NOT NULL,
  issue_type TEXT NOT NULL,
  summary TEXT NOT NULL,
  assignee_email TEXT,
  reporter_email TEXT,
  status work_status NOT NULL DEFAULT 'open',
  priority priority_level,
  due_date DATE,
  sprint_name TEXT,
  story_points NUMERIC(8,2),
  blockers JSONB NOT NULL DEFAULT '[]',
  dependencies JSONB NOT NULL DEFAULT '[]',
  risk_score NUMERIC(5,2),
  updated_at_source TIMESTAMPTZ,
  synced_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE meetings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID NOT NULL REFERENCES executives(id),
  calendar_event_id UUID REFERENCES calendar_events(id),
  title TEXT NOT NULL,
  meeting_date DATE NOT NULL,
  transcript_uri TEXT,
  transcript_text TEXT,
  summary TEXT,
  decisions JSONB NOT NULL DEFAULT '[]',
  action_items JSONB NOT NULL DEFAULT '[]',
  risks JSONB NOT NULL DEFAULT '[]',
  published_to_teams BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE decisions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID NOT NULL REFERENCES executives(id),
  source source_system NOT NULL,
  source_ref UUID,
  title TEXT NOT NULL,
  decision_text TEXT NOT NULL,
  approver TEXT,
  decided_at TIMESTAMPTZ,
  rationale TEXT,
  confidence NUMERIC(4,3),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE daily_briefings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID NOT NULL REFERENCES executives(id),
  briefing_date DATE NOT NULL,
  executive_summary TEXT NOT NULL,
  top_priorities JSONB NOT NULL DEFAULT '[]',
  risks JSONB NOT NULL DEFAULT '[]',
  recommendations JSONB NOT NULL DEFAULT '[]',
  free_slots JSONB NOT NULL DEFAULT '[]',
  source_counts JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (executive_id, briefing_date)
);

CREATE TABLE pmo_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID NOT NULL REFERENCES executives(id),
  period_type TEXT NOT NULL CHECK (period_type IN ('daily', 'weekly', 'monthly', 'quarterly')),
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  health_summary TEXT NOT NULL,
  metrics JSONB NOT NULL DEFAULT '{}',
  risks JSONB NOT NULL DEFAULT '[]',
  decisions_needed JSONB NOT NULL DEFAULT '[]',
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE agent_recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID NOT NULL REFERENCES executives(id),
  recommendation_type TEXT NOT NULL,
  title TEXT NOT NULL,
  recommendation TEXT NOT NULL,
  evidence JSONB NOT NULL DEFAULT '[]',
  explanation TEXT NOT NULL,
  impact_score NUMERIC(5,2) NOT NULL,
  urgency_score NUMERIC(5,2) NOT NULL,
  status recommendation_status NOT NULL DEFAULT 'proposed',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE knowledge_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID NOT NULL REFERENCES executives(id),
  source source_system NOT NULL,
  source_id TEXT NOT NULL,
  title TEXT NOT NULL,
  document_uri TEXT,
  content_text TEXT NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}',
  retention_until DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (source, source_id)
);

CREATE TABLE knowledge_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES knowledge_documents(id) ON DELETE CASCADE,
  chunk_index INTEGER NOT NULL,
  chunk_text TEXT NOT NULL,
  qdrant_point_id UUID NOT NULL DEFAULT gen_random_uuid(),
  embedding_model TEXT NOT NULL,
  token_count INTEGER,
  metadata JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (document_id, chunk_index)
);

CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  executive_id UUID REFERENCES executives(id),
  actor TEXT NOT NULL,
  action TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id TEXT,
  metadata JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_raw_events_exec_source_time ON raw_events (executive_id, source, occurred_at DESC);
CREATE INDEX idx_email_items_exec_received ON email_items (executive_id, received_at DESC);
CREATE INDEX idx_calendar_events_exec_start ON calendar_events (executive_id, starts_at);
CREATE INDEX idx_jira_issues_exec_status_due ON jira_issues (executive_id, status, due_date);
CREATE INDEX idx_daily_briefings_exec_date ON daily_briefings (executive_id, briefing_date DESC);
CREATE INDEX idx_knowledge_chunks_point ON knowledge_chunks (qdrant_point_id);
CREATE INDEX idx_audit_log_exec_created ON audit_log (executive_id, created_at DESC);
