# AI Sales Pipeline for Construction

An autonomous business-development workflow that finds construction projects, qualifies them with a local AI, drafts personalized outreach, and routes it through human approval before sending — built end-to-end in [n8n](https://n8n.io), fully self-hosted and free to run.

> **What it is:** An AI-driven sales automation pipeline with a human-in-the-loop checkpoint. The AI finds, filters, and drafts; a person approves before anything is sent. It's built as a controlled, auditable pipeline rather than a fully autonomous agent — for outreach to real businesses, reliability and oversight matter more than full autonomy.

---

## What it does

The system runs a construction company's outbound sales as a nine-stage pipeline. Each stage does one job and passes work to the next by updating a shared status in the database:

```
new  →  qualified  →  enriched  →  drafted  →  approved  →  sent
                 ↘ rejected
```

1. **Finds projects** — pulls real federal construction opportunities from a public government API
2. **Qualifies them** — a local LLM reads each project and decides whether it fits the company's trade
3. **Finds contacts** — attaches a company and decision-maker to each qualified project
4. **Drafts outreach** — a local LLM writes a personalized cold email referencing the specific project and contact
5. **Human approval** — a web page lists every AI-written draft with Approve / Reject buttons; nothing sends without sign-off
6. **Sends** — approved emails go out via SMTP
7. **Handles replies** — a local LLM classifies incoming replies (interested / question / not interested / unsubscribe / out-of-office) and routes them
8. **Syncs to CRM** — contacts are pushed to a CRM record with full context
9. **Daily report** — a scheduled job emails a summary of the pipeline every morning

---

## Architecture

The core design principle is a **status-driven state machine**. There is no orchestrator calling workflows in sequence. Instead, every project row carries a `status`, and each workflow independently polls for rows in the status it handles, does its job, and writes the next status.

This makes the system:

- **Self-healing** — if one stage fails or a batch drops, the next scheduled run picks up whatever wasn't processed, because each workflow only grabs rows still in its input status.
- **Debuggable** — any stage can be run, tested, or rebuilt in isolation.
- **Auditable** — the full history of every lead is visible in the database at any point.

```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│  WF-01   │   │  WF-02   │   │  WF-03   │   │  WF-04   │
│  Ingest  │──▶│ Qualify  │──▶│  Enrich  │──▶│  Draft   │
│          │   │  (LLM)   │   │          │   │  (LLM)   │
└──────────┘   └──────────┘   └──────────┘   └────┬─────┘
                                                   │
      ┌──────────┐   ┌──────────┐   ┌──────────┐  │
      │  WF-06   │   │  WF-05   │   │  drafts  │◀─┘
      │   Send   │◀──│ Approve  │◀──│  in DB   │
      │          │   │ (human)  │   │          │
      └────┬─────┘   └──────────┘   └──────────┘
           │
           ▼
      ┌──────────┐   ┌──────────┐   ┌──────────┐
      │  WF-07   │   │  WF-08   │   │  WF-09   │
      │ Replies  │   │   CRM    │   │  Daily   │
      │  (LLM)   │   │   Sync   │   │  Report  │
      └──────────┘   └──────────┘   └──────────┘
```

---

## Tech stack

| Component | Role |
|-----------|------|
| **n8n** | Workflow engine — all nine workflows |
| **PostgreSQL** | System of record — projects, companies, contacts, messages, replies, suppressions, CRM log |
| **Ollama** | Local LLM inference (`llama3.2`, `dolphin3`) — qualification, drafting, reply classification |
| **MailHog** | Local SMTP capture — safe email testing with zero real sends |
| **Docker Compose** | Runs Postgres and MailHog in containers |

Everything runs locally. No API keys, no per-message costs, no data leaving the machine.

---

## The nine workflows

| # | Workflow | What it does | AI? |
|---|----------|--------------|-----|
| 01 | **Ingest** | Fetches construction projects from the USAspending API, deduplicates, stores as `new` | — |
| 02 | **Qualify** | LLM classifies each project as a fit for the company's trade | ✅ |
| 03 | **Enrich** | Attaches a company and contact to each qualified project | — |
| 04 | **Draft** | LLM writes a personalized outreach email per project | ✅ |
| 05 | **Approve** | Webhook-served HTML page with Approve / Reject buttons — the human gate | — |
| 06 | **Send** | Sends approved emails via SMTP | — |
| 07 | **Replies** | LLM classifies inbound replies and routes them; auto-suppresses opt-outs | ✅ |
| 08 | **CRM Sync** | Pushes contacts into a CRM record with full context | — |
| 09 | **Daily Report** | Scheduled job that emails a pipeline summary each morning | — |

---

## Running it locally

**Prerequisites:** Docker Desktop, and [Ollama](https://ollama.com) installed with a model pulled (`ollama pull llama3.2`).

```bash
# 1. Start Postgres and MailHog
docker compose up -d

# 2. Create the pipeline database and schema
docker compose exec postgres psql -U n8n -d pipeline < schema.sql

# 3. Start n8n (adjust to your setup) and import the workflows
#    from the /workflows folder via the n8n UI

# 4. Make Ollama reachable from Docker
setx OLLAMA_HOST "0.0.0.0"   # then restart Ollama
```

Open the interfaces:

- **n8n** — http://localhost:5678
- **MailHog inbox** — http://localhost:8025
- **Approval page** — http://localhost:5678/webhook/Approve

In n8n, set the Postgres credential (host `host.docker.internal`, db `pipeline`, user `n8n`), the Ollama credential (`http://host.docker.internal:11434`), and the SMTP credential (host `host.docker.internal`, port `1025`, no auth — MailHog).

---

## Design decisions & lessons

A few choices that matter, and would change for a production deployment:

- **Human-in-the-loop over full autonomy.** The approval gate (WF-05) is deliberate. An agent that sends emails to real contractors without review is a liability; a pipeline with a sign-off step is not.
- **Local LLM for cost and privacy.** Ollama runs everything free and offline. The tradeoff is accuracy — the small local models occasionally misjudge. **For production, swap the LLM nodes for GPT-4o-mini or Claude** for materially better classification and drafting, at a fraction of a cent per call.
- **Defensive parsing.** LLM output is never trusted directly — a parser node normalizes and defaults every response, so a shaky classification still routes sensibly.
- **Safe email testing.** All sends go to MailHog, never real inboxes. A production build would add warmed sending domains and SPF/DKIM/DMARC for deliverability.
- **Practice data sources.** This uses the free, open USAspending API. A commercial build would integrate paid platforms (Dodge, ConstructConnect) — but only the ingest node changes; the rest of the pipeline transfers directly.

---

## Status

All nine workflows are built and functioning. In testing, ~200 real projects were ingested, filtered to 65 qualified leads, enriched with contacts, drafted into personalized emails, approved through the web gate, sent to MailHog, and summarized in an automated daily report.

---

*Built as a full end-to-end implementation of an autonomous sales-agent brief — from data ingestion to reply handling — using entirely free, self-hosted tooling.*
