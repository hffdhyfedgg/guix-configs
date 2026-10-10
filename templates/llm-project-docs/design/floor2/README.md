# Этаж 2: требования, ограничения и диаграммы

Этаж 2 заполняется не ручным «раскидыванием ограничений», а в два прохода: **планирование → создание**.

## 1. Что где хранится

| Артефакт | Путь | Создаётся из |
|---|---|---|
| `REQ-NNN` | `design/floor2/requirements/REQ-NNN.yaml` | `design_docs/templates/requirement.yaml` |
| `CON-NNN` | `design/floor2/constraints/CON-NNN.yaml` | `design_docs/templates/constraint.yaml` |
| `COMM-NNN` | `design/floor2/diagrams/comm/COMM-NNN.yaml` | `design_docs/templates/comm-diagram.yaml` |
| `STR-NNN` | `design/floor2/diagrams/string/STR-NNN.yaml` | `design_docs/templates/string-diagram.yaml` |

## 2. Как заполнять после этажа 1

1. Передай LLM `AGENTS.md`, `design/human/`, `design/floor1/`, `design/trace/`, правила `design_docs/00–04,07–09`, шаблоны и `design_docs/prompts/p-start-floor2.md`.
2. Запусти `p-start-floor2.md`. **Файлы этажа 2 на этом проходе не создаются.**
3. Получи матрицу `US → candidate REQ → candidate CON/diagram` и список блокирующих вопросов.
4. Ответь на блокирующие вопросы/скорректируй план.
5. Передай тот же вход + согласованный план в `p-create-requirement.md`.
6. Создай `REQ`, затем применимые `CON`, затем только необходимые диаграммы.
7. Запусти `p-review.md` и `python design_docs/scripts/validate_docs.py`.

## 3. Что считать готовым

Этаж 2 не обязан содержать все четыре типа артефактов. Он достаточно заполнен, когда:

- все известные `must`-истории покрыты `REQ` или явно отмечены открытым пробелом;
- каждое `REQ` имеет понятный источник и аргументированное покрытие;
- каждое формализованное `CON` имеет сигнатуру, предикат и способ проверки;
- диаграммы созданы только там, где они добавляют проверяемую точность;
- блокирующие вопросы разрешены или явно зарегистрированы;
- ссылки и YAML проходят автоматическую проверку.
