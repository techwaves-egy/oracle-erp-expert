# Universal AI Agent Integration & Deployment Guide

This document outlines how to load, configure, and use the **Oracle ERP & Database Center of Excellence (CoE)** across all major AI agent platforms, CLI tools, IDE extensions, and orchestration frameworks.

---

## 🌐 Supported AI Agent Ecosystems

```
                       [ Oracle ERP & Database CoE ]
                                    │
       ┌───────────────┬────────────┴───┬──────────────┬───────────────┐
       ▼               ▼                ▼              ▼               ▼
Google Antigravity  Claude Code     Cursor IDE     Windsurf IDE    Custom Agent
& Gemini CLI       & Desktop        & VS Code      & Codeium       Frameworks
(AGENTS.md /       (CLAUDE.md)      (.cursorrules) (.windsurfrules)(LangChain/CrewAI/
 GEMINI.md)                                                        SYSTEM_PROMPT.md)
```

---

## 1. Google Antigravity & Gemini CLI
* **Discovery Paths**: `.agents/skills/oracle-erp-database-expert/SKILL.md`, `GEMINI.md`, `AGENTS.md`.
* **Behavior**: Automatically discovered and loaded during session initialization. Progressive disclosure loads `SKILL.md` when Oracle or ERP tasks are presented.

---

## 2. Anthropic Claude Code & Claude Desktop
* **Configuration File**: `CLAUDE.md`.
* **Usage**:
  * **Claude Code CLI**: Automatically reads `CLAUDE.md` from the project root.
  * **Claude Desktop Projects**: Add this folder as a Project Knowledge folder and set `prompts/SYSTEM_PROMPT.md` as the Project Custom Instructions.

---

## 3. Cursor IDE
* **Configuration File**: `.cursorrules`.
* **Usage**: Automatically injected into every Cursor AI chat/composer session within this workspace.

---

## 4. Windsurf IDE (Codeium Cascade)
* **Configuration File**: `.windsurfrules`.
* **Usage**: Automatically loaded by Windsurf Cascade to govern autonomous coding and terminal commands.

---

## 5. OpenAI ChatGPT, Custom GPTs & OpenAI Assistants API
* **Configuration File**: `prompts/SYSTEM_PROMPT.md`.
* **Usage**: Copy the contents of `prompts/SYSTEM_PROMPT.md` into the **Instructions / System Message** field. Upload `playbooks/`, `templates/`, and `scripts/` as knowledge base files or code interpreter files.

---

## 6. LangChain, LangGraph, AutoGen, CrewAI & OpenDevin
* **System Message**: Load `prompts/SYSTEM_PROMPT.md` as the agent's base system prompt.
* **Tools / Functions**: Map scripts in `scripts/sql/` and `scripts/shell/` as agent callable tools/functions.
* **State Management**: Persist agent step state to `docs/SESSION_STATE.md` and `docs/WORK_LOG.md`.
