# Структура комплекта

```text
llm-project-docs/
├── AGENTS.md
├── README.md
├── AUDIT.md
├── CHANGELOG.md
├── STRUCTURE.md
├── requirements-dev.txt
├── design_docs/                 # мета-уровень: правила процесса
│   ├── 00-principles.md … 11-subprojects.md
│   ├── README.md
│   ├── templates/
│   ├── examples/
│   ├── prompts/
│   └── scripts/
├── design/                      # содержание конкретного проекта
│   ├── human/
│   ├── floor1/
│   ├── floor2/
│   └── trace/
├── src/                         # код текущего уровня (появляется при реализации)
└── subs/                        # подпроекты (появляются при выделении)
    └── <name>/
        ├── design/
        ├── src/
        └── subs/
```

`design_docs/` обычно не меняется. Его изменение выполняется Треком B.

Для работы после этажа 1: `design/floor2/README.md` → `design_docs/10-workflows.md` → `design_docs/prompts/p-start-floor2.md` → согласование плана → `p-create-requirement.md` → `p-review.md` + валидатор.
