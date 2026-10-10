АККУРАТНО, ОФОРМЛЕНО С ПОМОЩЬЮ ИИ!
МОЖЕТ СОДЕРЖАТЬ ОШИБКИ!

`abf_mattrix_applies.py`:
```py

import marimo

__generated_with = "0.23.13"
app = marimo.App()


@app.cell
def _():
    import marimo as mo
    import sympy as sp
    import numpy as np
    from itertools import product

    return mo, sp


@app.cell
def _():
    # Импортируем функции из модуля abf_primitives
    import sys
    from pathlib import Path

    current_dir = Path.cwd()
    if str(current_dir) not in sys.path:
        sys.path.insert(0, str(current_dir))

    try:
        from abf_primitives import compute_m_block, compute_full_M, print_block_structure
        import_success = True
        error_msg = ""
    except ImportError as e:
        import_success = False
        error_msg = str(e)
    return compute_m_block, error_msg, import_success


@app.cell(hide_code=True)
def _(error_msg, import_success, mo):
    # Проверяем импорт
    if not import_success:
        msg1 = f"""
        ## Ошибка импорта

        Не удалось импортировать модуль `abf_primitives`:

        ```
        {error_msg}
        ```

        Убедитесь, что файл `abf_primitives.py` находится в той же директории, что и этот ноутбук.
        """
    else:
        msg1 = r"""
        # От матрицы M к локальной матрице жесткости

        В предыдущей заметке мы вывели матрицу перехода \(M\) для элементов Арнольда-Боффи-Фалка. Теперь разберёмся, как эта матрица используется для построения локальной матрицы жесткости.

        ## План заметки

        1. **Связь M с базисными функциями:** как из коэффициентов мономов получить базисные функции через \(M^{-1}\)
        2. **Матрица Грамма G:** попарные скалярные произведения мономов
        3. **Локальная матрица жесткости A:** формула \(A = (M^{-1})^T G M^{-1}\)
        4. **Интерактивные примеры** для разных степеней \(k\)
        """

    mo.md(msg1)
    return


@app.cell(hide_code=True)
def _(mo):
    msg2 = r"""
    ## 1. От коэффициентов мономов к базисным функциям

    ### Что мы знаем?

    У нас есть пространство полиномов для компоненты \(v_x\):

    \[
    v_x(x_1, x_2, \dots, x_d) = \sum_{\alpha} c_\alpha \cdot \psi_\alpha(\mathbf{x})
    \]

    где:
    - \(c_\alpha\) — коэффициенты мономов (наши \(p[i_1, i_2, \dots, i_d]\))
    - \(\psi_\alpha(\mathbf{x})\) — мономы (например, \(x_1^2 x_2\))

    И есть степени свободы \(\sigma_i\) (интегралы по граням и внутри ячейки).

    ### Связь через матрицу M

    Матрица \(M\) выражает степени свободы через коэффициенты:

    \[
    \vec{\sigma} = M \cdot \vec{c}
    \]

    Обращая эту матрицу, мы получаем коэффициенты через степени свободы:

    \[
    \vec{c} = M^{-1} \cdot \vec{\sigma}
    \]

    ### Базисные функции

    Теперь подставим это выражение в полином:

    \[
    v_x(\mathbf{x}) = \sum_{\alpha} \left( \sum_i (M^{-1})_{\alpha, i} \cdot \sigma_i \right) \cdot \psi_\alpha(\mathbf{x})
    \]

    Меняем порядок суммирования:

    \[
    v_x(\mathbf{x}) = \sum_i \sigma_i \cdot \underbrace{\left( \sum_{\alpha} (M^{-1})_{\alpha, i} \cdot \psi_\alpha(\mathbf{x}) \right)}_{\phi_i(\mathbf{x})}
    \]

    **Вот они — базисные функции!**

    \[
    \phi_i(\mathbf{x}) = \sum_{\alpha} (M^{-1})_{\alpha, i} \cdot \psi_\alpha(\mathbf{x})
    \]

    Каждая базисная функция \(\phi_i\) — это линейная комбинация мономов с коэффициентами из \(i\)-го столбца матрицы \(M^{-1}\).

    ### Свойство Кронекера

    Благодаря построению матрицы \(M\), базисные функции обладают свойством:

    \[
    \sigma_j(\phi_i) = \begin{cases} 1, & \text{если } i = j \\ 0, & \text{если } i \neq j \end{cases}
    \]

    То есть каждая базисная функция "откликается" только на свою степень свободы.
    """

    mo.md(msg2)
    return


@app.cell
def _(mo):
    sldr_k = mo.ui.slider(0, 2, value=0, label="Степень элемента k")
    sldr_dim = mo.ui.slider(2, 3, value=2, label="Размерность пространства dim")
    return sldr_dim, sldr_k


@app.cell(hide_code=True)
def _(mo, sldr_dim, sldr_k):
    mo.md(f"""
    {sldr_k}
    {sldr_dim}
    """)
    return


@app.cell(hide_code=True)
def _(mo, sldr_dim, sldr_k):
    k_elem = sldr_k.value
    d_dim = sldr_dim.value  # работаем в 2D для простоты

    mo.md(rf"""
    ## 2. Интерактивный пример для ABF\(_{k_elem}\) в 2D

    **Степень элемента:** \(k = {k_elem}\)

    **Размерность:** \(d = {d_dim}\)
    """)
    return d_dim, k_elem


@app.cell
def _(compute_m_block, d_dim, k_elem):
    # Вычисляем блок матрицы M для выбранного k
    M_block, coeffs_list, dofs_list = compute_m_block(k=k_elem, d=d_dim)
    return M_block, coeffs_list


@app.cell(hide_code=True)
def _(M_block, mo, sp):
    # Для больших k матрица слишком громоздкая
    matrix_size_1 = M_block.shape[0]

    if matrix_size_1 <= 12:
        msg3 = rf"""
        ### Матрица перехода \(M\) (блок для \(v_x\))

        Размер: {matrix_size_1} × {matrix_size_1}

        $$
        M = {sp.latex(M_block)}
        $$
        """
    else:
        msg3 = f"""
        ### Матрица перехода \(M\) (блок для \(v_x\))

        Размер: {matrix_size_1} × {matrix_size_1} (слишком большая для отображения)

        Матрица имеет следующую структуру:
        - Первые \(2(k+1)\) строк: граничные DOF (левая и правая грани)
        - Остальные \((k+1)^2\) строк: внутренние DOF
        """

    mo.md(msg3)
    return


@app.cell
def _(M_block):
    # Обращаем матрицу M
    M_inv_block = M_block.inv()
    return (M_inv_block,)


@app.cell(hide_code=True)
def _(M_inv_block, mo, sp):
    matrix_size_2 = M_inv_block.shape[0]

    if matrix_size_2 <= 12:
        msg4 = rf"""
        ### Обратная матрица \(M^{{-1}}\)

        Эта матрица содержит коэффициенты для построения базисных функций.

        $$
        M^{{-1}} = {sp.latex(M_inv_block)}
        $$

        **Интерпретация:** \(i\)-й столбец этой матрицы содержит коэффициенты для базисной функции \(\phi_i(\mathbf{{x}})\).
        """
    else:
        msg4 = f"""
        ### Обратная матрица \(M^{{-1}}\)

        Размер: {matrix_size_2} × {matrix_size_2} (слишком большая для отображения)

        Эта матрица содержит коэффициенты для построения базисных функций.
        """

    mo.md(msg4)
    return


@app.cell(hide_code=True)
def _(M_inv_block, coeffs_list, mo, sp):
    # Функция для извлечения индексов из символа
    def extract_indices_from_coeff(coeff_sym):
        coeff_name = str(coeff_sym)
        indices_str = coeff_name.replace('p_', '').split('_')
        return tuple(int(idx) for idx in indices_str)

    # Функция для построения выражения базисной функции
    def build_basis_expression(basis_coeffs, coeffs_list_local):
        x_sym, y_sym = sp.symbols('x y')
        basis_expr = sp.Integer(0)

        for i, coeff_sym in enumerate(coeffs_list_local):
            if basis_coeffs[i] != 0:
                indices = extract_indices_from_coeff(coeff_sym)
                if len(indices) == 2:
                    i_idx, j_idx = indices
                    basis_expr += basis_coeffs[i] * x_sym**i_idx * y_sym**j_idx

        return sp.simplify(basis_expr)

    # Показываем пример базисной функции для первой степени свободы
    if len(coeffs_list) > 0 and M_inv_block.shape[0] > 0:
        # Берём первый столбец M_inv (коэффициенты для phi_0)
        first_basis_coeffs = [M_inv_block[i, 0] for i in range(M_inv_block.shape[0])]
        basis_expr = build_basis_expression(first_basis_coeffs, coeffs_list)

        msg5 = rf"""
        ### Пример: базисная функция \(\phi_0\)

        Первая базисная функция (соответствует первой степени свободы — левой грани):

        $$
        \phi_0(x, y) = {sp.latex(basis_expr)}
        $$

        Эта функция построена как линейная комбинация мономов с коэффициентами из первого столбца \(M^{{-1}}\).
        """
    else:
        msg5 = """
        ### Пример базисной функции

        Недостаточно данных для отображения.
        """

    mo.md(msg5)
    return


@app.cell(hide_code=True)
def _(mo):
    msg6 = r"""
    ## 3. Матрица Грамма мономов \(G\)

    ### Определение

    Матрица Грамма \(G\) содержит попарные скалярные произведения мономов:

    \[
    G_{\alpha, \beta} = \int_{\hat{K}} \psi_\alpha(\mathbf{x}) \cdot \psi_\beta(\mathbf{x}) \, d\mathbf{x}
    \]

    где \(\hat{K} = [0, 1]^d\) — эталонный куб.

    ### Зачем она нужна?

    Для вычисления скалярных произведений базисных функций нам нужно интегрировать:

    \[
    \int_{\hat{K}} \phi_i(\mathbf{x}) \cdot \phi_j(\mathbf{x}) \, d\mathbf{x}
    \]

    Подставляя выражение через мономы:

    \[
    \int_{\hat{K}} \left( \sum_\alpha (M^{-1})_{\alpha, i} \psi_\alpha \right) \cdot \left( \sum_\beta (M^{-1})_{\beta, j} \psi_\beta \right) d\mathbf{x}
    \]

    Выносим константы:

    \[
    = \sum_\alpha \sum_\beta (M^{-1})_{\alpha, i} \cdot (M^{-1})_{\beta, j} \cdot \underbrace{\int_{\hat{K}} \psi_\alpha \cdot \psi_\beta \, d\mathbf{x}}_{G_{\alpha, \beta}}
    \]

    В матричном виде:

    \[
    \boxed{A = (M^{-1})^T \cdot G \cdot M^{-1}}
    \]

    где \(A\) — локальная матрица жесткости.

    ### Вычисление матрицы Грамма

    Для мономов вида \(\psi_\alpha(\mathbf{x}) = x_1^{i_1} x_2^{i_2} \cdots x_d^{i_d}\) интеграл распадается в произведение:

    \[
    \int_{\hat{K}} \psi_\alpha \cdot \psi_\beta \, d\mathbf{x} = \prod_{m=1}^{d} \int_0^1 x_m^{i_m + j_m} \, dx_m = \prod_{m=1}^{d} \frac{1}{i_m + j_m + 1}
    \]

    где \(j_m\) — степени в мономе \(\psi_\beta\).
    """

    mo.md(msg6)
    return


@app.cell
def _(coeffs_list, sp):
    # Функция для извлечения индексов
    def extract_indices(coeff_sym):
        coeff_name = str(coeff_sym)
        indices_str = coeff_name.replace('p_', '').split('_')
        return tuple(int(idx) for idx in indices_str)

    coeff_indices = [extract_indices(c) for c in coeffs_list]
    n_coeffs = len(coeffs_list)

    # Строим матрицу Грамма
    G_block = sp.zeros(n_coeffs, n_coeffs)

    for row, idx_alpha in enumerate(coeff_indices):
        for col, idx_beta in enumerate(coeff_indices):
            # Скалярное произведение мономов
            integral_value = sp.Integer(1)
            for i_alpha, i_beta in zip(idx_alpha, idx_beta):
                # ∫_0^1 x^(i_alpha + i_beta) dx = 1 / (i_alpha + i_beta + 1)
                integral_value *= sp.Rational(1, i_alpha + i_beta + 1)

            G_block[row, col] = integral_value
    return (G_block,)


@app.cell(hide_code=True)
def _(G_block, mo, sp):
    matrix_size_G = G_block.shape[0]

    if matrix_size_G <= 12:
        msg7 = rf"""
        ### Матрица Грамма \(G\)

        Размер: {matrix_size_G} × {matrix_size_G}

        $$
        G = {sp.latex(G_block)}
        $$

        **Свойства:**
        - Симметричная: \(G_{{ij}} = G_{{ji}}\)
        - Положительно определённая
        - Элементы убывают с ростом степеней мономов
        """
    else:
        msg7 = f"""
        ### Матрица Грамма \(G\)

        Размер: {matrix_size_G} × {matrix_size_G} (слишком большая для отображения)

        **Свойства:**
        - Симметричная: \(G_{{ij}} = G_{{ji}}\)
        - Положительно определённая
        - Элементы убывают с ростом степеней мономов
        """

    mo.md(msg7)
    return


@app.cell(hide_code=True)
def _(mo):
    msg8 = r"""
    ## 4. Локальная матрица жесткости \(A\)

    ### Формула

    Локальная матрица жесткости (массовая матрица для потока) вычисляется как:

    \[
    A_{ij} = \int_{\hat{K}} \phi_i(\mathbf{x}) \cdot \phi_j(\mathbf{x}) \, d\mathbf{x}
    \]

    Используя связь с матрицей Грамма:

    \[
    \boxed{A = (M^{-1})^T \cdot G \cdot M^{-1}}
    \]

    ### Смысл матрицы \(A\)

    В смешанной формулировке уравнения Лапласа:

    \[
    \begin{cases}
    \mathbf{q} + \nabla u = 0 \\
    \nabla \cdot \mathbf{q} = f
    \end{cases}
    \]

    матрица \(A\) образует верхний левый блок глобальной системы:

    \[
    \begin{pmatrix} A & B^T \\ B & 0 \end{pmatrix} \begin{pmatrix} \mathbf{q} \\ u \end{pmatrix} = \begin{pmatrix} 0 \\ f \end{pmatrix}
    \]

    где:
    - \(A\) — массовая матрица для потока \(\mathbf{q}\)
    - \(B\) — матрица оператора дивергенции
    - \(\mathbf{q}\) — вектор степеней свободы потока
    - \(u\) — вектор степеней свободы давления

    ### Вычисление на эталонном элементе

    Матрица \(A\) вычисляется **один раз** для эталонного куба \([0, 1]^d\) и хардкодится в библиотеку. Для реальных ячеек сетки применяется преобразование Пиолы.
    """

    mo.md(msg8)
    return


@app.cell
def _(G_block, M_inv_block):
    # Вычисляем локальную матрицу жесткости: A = (M^(-1))^T * G * M^(-1)
    A_block = M_inv_block.T * G_block * M_inv_block
    return (A_block,)


@app.cell(hide_code=True)
def _(A_block, mo, sp):
    matrix_size_A = A_block.shape[0]

    eigen_vals = A_block.eigenvals()
    eigen_vals_str = ','.join(
        f"{el.evalf():.2f}" for el in eigen_vals
    )

    if matrix_size_A <= 12:
        msg9 = rf"""
        ### Локальная матрица жесткости \(A\)

        Размер: {matrix_size_A} × {matrix_size_A}

        $$
        A = {sp.latex(sp.simplify(A_block))}
        $$

        **Свойства:**
        - Симметричная: \(A_{{ij}} = A_{{ji}}\)
        - Положительно определённая (собственные числа: ${eigen_vals_str}$)
        - Связывает степени свободы потока с самими собой
        """
    else:
        msg9 = f"""
        ### Локальная матрица жесткости \(A\)

        Размер: {matrix_size_A} × {matrix_size_A} (слишком большая для отображения)

        **Свойства:**
        - Симметричная: \(A_{{ij}} = A_{{ji}}\)
        - Положительно определённая (собственные числа: ${eigen_vals_str}$)
        - Связывает степени свободы потока с самими собой
        """

    mo.md(msg9)
    return


@app.cell(hide_code=True)
def _(A_block, G_block, M_block, M_inv_block, k_elem, mo):
    msg10 = rf"""
    ## 5. Сводка матриц

    Для элемента ABF\(_{k_elem}\) в 2D:

    | Матрица | Размер | Описание |
    |---------|--------|----------|
    | \(M\) | {M_block.shape[0]} × {M_block.shape[1]} | Переход от коэффициентов к степеням свободы |
    | \(M^{{-1}}\) | {M_inv_block.shape[0]} × {M_inv_block.shape[1]} | Коэффициенты базисных функций |
    | \(G\) | {G_block.shape[0]} × {G_block.shape[1]} | Скалярные произведения мономов |
    | \(A\) | {A_block.shape[0]} × {A_block.shape[1]} | Локальная матрица жесткости |

    ### Формула сборки

    $$
    A = (M^{{-1}})^T \cdot G \cdot M^{{-1}}
    $$

    ### Вычислительная сложность

    - Обращение \(M\): \(O(n^3)\), где \(n\) — размер блока
    - Умножение матриц: \(O(n^3)\)
    - Для малых \(k\) (0, 1, 2) это мгновенно
    - Вычисляется **один раз** при инициализации элемента
    """

    mo.md(msg10)
    return


@app.cell(hide_code=True)
def _(mo):
    msg11 = r"""
    ## 6. От эталонного элемента к реальной сетке

    ### Преобразование Пиолы

    Все наши вычисления сделаны для эталонного куба \(\hat{K} = [0, 1]^d\). Но в реальной сетке у нас тысячи кривых ячеек!

    При переходе от эталонного элемента \(\hat{K}\) к реальному элементу \(K\) базисные функции преобразуются по правилу **контравариантного отображения Пиолы**:

    \[
    \mathbf{v}(\mathbf{x}) = \frac{1}{\det(J)} J \cdot \hat{\mathbf{v}}(\hat{\mathbf{x}})
    \]

    где:
    - \(J\) — матрица Якоби отображения \(\hat{K} \to K\)
    - \(\det(J)\) — определитель якобиана
    - \(\hat{\mathbf{v}}\) — базисная функция на эталонном элементе
    - \(\mathbf{v}\) — базисная функция на реальном элементе

    ### Локальная матрица на реальном элементе

    Локальная матрица жесткости на реальном элементе вычисляется как:

    \[
    A^K_{ij} = \int_K \mathbf{v}_i \cdot \mathbf{v}_j \, d\mathbf{x} = \int_{\hat{K}} \left( \frac{1}{\det J} J \hat{\phi}_i \right) \cdot \left( \frac{1}{\det J} J \hat{\phi}_j \right) \det(J) \, d\hat{\mathbf{x}}
    \]

    Упрощая:

    \[
    A^K_{ij} = \int_{\hat{K}} \frac{1}{\det(J)} (J \hat{\phi}_i) \cdot (J \hat{\phi}_j) \, d\hat{\mathbf{x}}
    \]

    ### Как это работает в FEniCSx?

    1. **На этапе разработки Basix:** мы один раз вычисляем \(\hat{A} = (M^{-1})^T G M^{-1}\) (то, что мы сделали в этой заметке)

    2. **На этапе решения задачи:** для каждой реальной ячейки сетки FEniCSx:
       - Вычисляет матрицу Якоби \(J\) по координатам вершин
       - Применяет преобразование Пиолы к базисным функциям
       - Через квадратурные формулы пересчитывает локальную матрицу \(A^K\)

    ### Красота метода

    - Матрица \(G\) зависит **только от геометрии** эталонного куба
    - Матрица \(M^{-1}\) зависит **только от выбора семейства** (ABF, RT, BDM)
    - Мы можем переиспользовать код: один раз вычисляем \(G\), дальше меняем только \(M^{-1}\)
    """

    mo.md(msg11)
    return


@app.cell(hide_code=True)
def _(mo):
    msg12 = r"""
    ## 7. Ключевые выводы

    ### Цепочка вычислений

    1. **Задаём пространство полиномов** \(ABF_k = \mathcal{Q}_{k+2,k} \times \mathcal{Q}_{k,k+2}\) (в 2D)

    2. **Определяем степени свободы** \(\Sigma\): интегралы по граням и внутри ячейки

    3. **Строим матрицу перехода** \(M\): выражает степени свободы через коэффициенты мономов

    4. **Обращаем матрицу** \(M^{-1}\): коэффициенты базисных функций

    5. **Вычисляем матрицу Грамма** \(G\): скалярные произведения мономов

    6. **Собираем локальную матрицу жесткости** \(A = (M^{-1})^T G M^{-1}\)

    7. **Хардкодим** \(A\) в библиотеку Basix

    ### Что мы получили?

    - **Базисные функции** с нужными свойствами (непрерывность нормальных компонент)
    - **Локальную матрицу жесткости** для сборки глобальной системы
    - **Физический смысл** степеней свободы (потоки через грани)
    - **Оптимальную сходимость** метода на кривых сетках (благодаря "лишним" полиномам в ABF)

    ### Следующие шаги

    Для полной реализации элемента ABF в Basix нужно:

    1. ✅ Вывести матрицу \(M\) (сделано)
    2. ✅ Вычислить матрицу \(A\) (сделано)
    3. ⏭️ Вывести матрицу дивергенции \(B\) (для смешанной формулировки)
    4. ⏭️ Реализовать преобразование Пиолы для реальных ячеек
    5. ⏭️ Добавить апостериорные оценки погрешности
    """

    mo.md(msg12)
    return


@app.cell(hide_code=True)
def _(mo):
    msg13 = r"""
    ---

    ## Приложение: Проверка свойства Кронекера

    Давайте убедимся, что наши базисные функции действительно обладают свойством:

    \[
    \sigma_j(\phi_i) = \delta_{ij}
    \]

    Для этого нужно применить операторы степеней свободы к базисным функциям и проверить, что получается единичная матрица.
    """

    mo.md(msg13)
    return


@app.cell
def _(M_block, M_inv_block, sp):
    # Проверяем, что M * M^(-1) = I (единичная матрица)
    identity_check = sp.simplify(M_block * M_inv_block)
    is_identity = identity_check == sp.eye(M_block.shape[0])
    return identity_check, is_identity


@app.cell(hide_code=True)
def _(identity_check, ij, is_identity, mo, sp):
    matrix_size = identity_check.shape[0]

    if is_identity:
        if matrix_size <= 12:
            msg14 = f"""
            ### ✅ Проверка пройдена!

            Произведение \(M \cdot M^{{-1}}\) даёт единичную матрицу:

            $$
            M \cdot M^{{-1}} = {sp.latex(identity_check)}
            $$

            Это гарантирует, что базисные функции обладают свойством Кронекера:

            $$
            \sigma_j(\phi_i) = \delta_{{ij}}
            $$

            То есть каждая базисная функция "откликается" единицей только на свою степень свободы и нулём на все остальные.
            """
        else:
            msg14 = f"""
            ### ✅ Проверка пройдена!

            Произведение \(M \cdot M^{{-1}}\) даёт единичную матрицу размера {matrix_size} × {matrix_size}.

            Это гарантирует, что базисные функции обладают свойством Кронекера:

            $$
            \sigma_j(\phi_i) = \delta_{ij}
            $$

            То есть каждая базисная функция "откликается" единицей только на свою степень свободы и нулём на все остальные.
            """
    else:
        msg14 = """
        ### ❌ Ошибка!

        Произведение \(M \cdot M^{-1}\) не даёт единичную матрицу. Проверьте правильность вычислений.
        """

    mo.md(msg14)
    return


if __name__ == "__main__":
    app.run()
```
`abf_start.p`:
```py
import marimo

__generated_with = "0.23.13"
app = marimo.App()


@app.cell
def _():
    import marimo as mo
    import sympy as sp
    import numpy as np

    return mo, sp


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## Построение матрицы перехода $M$ для элементов Арнольда-Боффи-Фалка

    ### Что такое матрица $M$?

    Матрица $M$ — это **матрица перехода от коэффициентов мономов к степеням свободы**:

    $$
    \vec{\sigma} = M \cdot \vec{c}
    $$

    где:
    - $\vec{c}$ — вектор всех коэффициентов мономов (например, $p_{i,j}$ для $v_x$)
    - $\vec{\sigma}$ — вектор всех степеней свободы (интегралы по ребрам и внутри ячейки)

    **Ключевая идея:** Каждая строка матрицы $M$ соответствует одной степени свободы. Каждый столбец — одному коэффициенту монома. Элемент $M_{row, col}$ — это числовой коэффициент, показывающий, с каким весом данный моном входит в данную степень свободы.

    ### Симметрия блоков

    Благодаря структуре пространства $ABF_k$:
    - $v_x$ зависит только от коэффициентов $p_{i,j}$
    - $v_y$ зависит только от коэффициентов $s_{i,j}$
    - Граничные DOF для $v_x$ (левое/правое ребра) используют только $v_x$
    - Граничные DOF для $v_y$ (верхнее/нижнее ребра) используют только $v_y$

    Матрица $M$ распадается на **два независимых блока**:

    $$
    M = \begin{pmatrix} M_x & 0 \\ 0 & M_y \end{pmatrix}
    $$

    где $M_x$ связывает степени свободы для $v_x$ с коэффициентами $p_{i,j}$, а $M_y$ — для $v_y$ с коэффициентами $s_{i,j}$.

    **Более того:** Из-за симметрии квадрата $M_y$ имеет **точно такую же структуру**, как $M_x$, только с заменой $x \leftrightarrow y$. Поэтому достаточно построить один блок $M_x$ и скопировать его.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Формулы для коэффициентов матрицы $M_x$

    #### Граничные DOF на левом ребре ($x=0$, нормаль $-1$):

    $$
    \sigma_{left, m} = \int_0^1 -v_x(0, y) \cdot y^m \, dy \quad \text{для } m = 0, 1, \dots, k
    $$

    Подставляем $v_x(x,y) = \sum_{i=0}^{k+2} \sum_{j=0}^{k} p_{i,j} x^i y^j$. При $x=0$ все слагаемые с $i>0$ зануляются:

    $$
    \sigma_{left, m} = -\sum_{j=0}^{k} \frac{p_{0,j}}{j+m+1}
    $$

    **Коэффициент при $p_{0,j}$:** $-\frac{1}{j+m+1}$
    **Коэффициент при $p_{i,j}$ для $i>0$:** $0$

    #### Граничные DOF на правом ребре ($x=1$, нормаль $+1$):

    $$
    \sigma_{right, m} = \int_0^1 v_x(1, y) \cdot y^m \, dy \quad \text{для } m = 0, 1, \dots, k
    $$

    При $x=1$ имеем $1^i = 1$ для всех $i$:

    $$
    \sigma_{right, m} = \sum_{i=0}^{k+2} \sum_{j=0}^{k} \frac{p_{i,j}}{j+m+1}
    $$

    **Коэффициент при любом $p_{i,j}$:** $\frac{1}{j+m+1}$ (не зависит от $i$)

    #### Внутренние DOF:

    $$
    \sigma_{int, (a,b)} = \int_0^1 \int_0^1 v_x(x,y) \cdot x^a y^b \, dx \, dy
    $$

    $$
    \sigma_{int, (a,b)} = \sum_{i=0}^{k+2} \sum_{j=0}^{k} \frac{p_{i,j}}{(i+a+1)(j+b+1)}
    $$

    **Коэффициент при $p_{i,j}$:** $\frac{1}{(i+a+1)(j+b+1)}$

    Для обеспечения унисольвентности используем тестовые функции $x^a y^b$, где $a=0,\dots,k$ и $b=0,\dots,k$. Это дает $(k+1)^2$ внутренних DOF.
    """)
    return


@app.cell
def _(mo):
    sldr = mo.ui.slider(0, 3, value=0, label="Степень элемента k")
    return (sldr,)


@app.cell(hide_code=True)
def _(mo, sldr):
    mo.md(rf"""
    {sldr} {sldr.value}
    """)
    return


@app.cell
def _(sldr):

    k_elem = sldr.value

    ## Размерность пространства для v_x
    n_coeffs_x_calc = (k_elem + 3) * (k_elem + 1)

    ## Количество степеней свободы для v_x
    n_edge_dofs = 2 * (k_elem + 1)  ## левое + правое ребро
    n_int_dofs = (k_elem + 1)**2     ## внутренние
    n_dofs_x_calc = n_edge_dofs + n_int_dofs
    return k_elem, n_coeffs_x_calc, n_dofs_x_calc, n_edge_dofs, n_int_dofs


@app.cell(hide_code=True)
def _(k_elem, mo, n_coeffs_x_calc, n_dofs_x_calc, n_edge_dofs, n_int_dofs):
    mo.md(rf"""
    ### Интерактивный выбор степени элемента

    **Степень элемента:** $k = {k_elem}$

    **Для компоненты $v_x$:**
    - Количество коэффициентов мономов: $(k+3)(k+1) = {n_coeffs_x_calc}$
    - Граничных DOF (левое + правое ребро): $2(k+1) = {n_edge_dofs}$
    - Внутренних DOF: $(k+1)^2 = {n_int_dofs}$
    - **Всего степеней свободы для $v_x$:** {n_dofs_x_calc}

    **Для полной матрицы $M$:**
    - Размер: $(2 \times {n_dofs_x_calc}) \times (2 \times {n_coeffs_x_calc}) = {2*n_dofs_x_calc} \times {2*n_coeffs_x_calc}$
    """)
    return


@app.cell
def _(k_elem, sp):
    ## Определяем символы
    x, y = sp.symbols('x y')

    ## Коэффициенты мономов для v_x
    p = sp.symarray('p', (k_elem + 3, k_elem + 1))

    ## Выражение для v_x
    vx = sum(p[i,j] * x**i * y**j for i in range(k_elem + 3) for j in range(k_elem + 1))

    ## Список всех коэффициентов (в порядке обхода)
    coeffs_x = [p[i,j] for i in range(k_elem + 3) for j in range(k_elem + 1)]
    return coeffs_x, p, vx


@app.cell(hide_code=True)
def _(mo, sp, vx):
    mo.md(rf"""
    #### Пространство полиномов для $v_x$

    $$
    v_x(x, y) = {sp.latex(vx)}
    $$
    """)
    return


@app.cell
def _(k_elem, p):
    ## Строим список степеней свободы для v_x

    def _(dofs_x = [], dof_names = []):
        ## 1. Левое ребро: m от 0 до k_elem
        for m in range(k_elem + 1):
            dof_expr = -sum(p[0, j] / (j + m + 1) for j in range(k_elem + 1))
            dofs_x.append(dof_expr)
            dof_names.append(f"Левое ребро, m={m}")

        ## 2. Правое ребро: m от 0 до k_elem
        for m in range(k_elem + 1):
            dof_expr = sum(p[i, j] / (j + m + 1)
                           for i in range(k_elem + 3)
                           for j in range(k_elem + 1))
            dofs_x.append(dof_expr)
            dof_names.append(f"Правое ребро, m={m}")

        ## 3. Внутренние DOF: a от 0 до k_elem, b от 0 до k_elem
        for a in range(k_elem + 1):
            for b in range(k_elem + 1):
                dof_expr = sum(p[i, j] / ((i + a + 1) * (j + b + 1))
                              for i in range(k_elem + 3)
                              for j in range(k_elem + 1))
                dofs_x.append(dof_expr)
                dof_names.append(f"Внутренняя, a={a}, b={b}")
        return dofs_x, dof_names

    dofs_x, dof_names = _()
    return dof_names, dofs_x


@app.cell(hide_code=True)
def _(dof_names, mo):
    mo.md(r"""
    #### Список степеней свободы для $v_x$
    """)

    dof_list = "\n".join([f"{i+1}. {name}" for i, name in enumerate(dof_names)])
    mo.md(dof_list)
    return


@app.cell
def _(coeffs_x, dofs_x, sp):
    ## Строим блок M_x
    n_dofs_x = len(dofs_x)
    n_coeffs_x = len(coeffs_x)

    M_x = sp.zeros(n_dofs_x, n_coeffs_x)

    for row, dof_expr in enumerate(dofs_x):
        for col, coeff in enumerate(coeffs_x):
            ## Извлекаем коэффициент при данном мономе
            M_x[row, col] = sp.simplify(dof_expr.coeff(coeff))
    return M_x, n_coeffs_x, n_dofs_x


@app.cell(hide_code=True)
def _(M_x, mo, n_coeffs_x, n_dofs_x, sp):
    mo.md(rf"""
    ### Матрица $M_x$ (блок для компоненты $v_x$)

    **Размер:** {n_dofs_x} × {n_coeffs_x}

    $$
    M_x = {sp.latex(M_x)}
    $$

    #### Анализ матрицы

    **Первые строки (левое ребро):**
    - Ненулевые элементы только в столбцах, соответствующих $p_{{0,j}}$ (мономы без $x$)
    - Отрицательные коэффициенты (из-за нормали $-1$)

    **Следующие строки (правое ребро):**
    - Все коэффициенты положительные (нормаль $+1$)
    - Коэффициенты не зависят от степени $i$ при $x$ (так как $1^i = 1$)

    **Последние строки (внутренние DOF):**
    - Все коэффициенты положительные
    - Убывают с ростом степеней мономов (интегралы от высоких степеней дают меньшие значения)
    """)
    return


@app.cell
def _(M_x, n_coeffs_x, n_dofs_x, sp):
    ## Строим полную матрицу M
    M_full = sp.zeros(2 * n_dofs_x, 2 * n_coeffs_x)

    ## Блок X (верхний левый)
    M_full[:n_dofs_x, :n_coeffs_x] = M_x

    ## Блок Y (нижний правый) - идентичен блоку X
    M_full[n_dofs_x:, n_coeffs_x:] = M_x
    return (M_full,)


@app.cell(hide_code=True)
def _(M_full, mo, sp):


    disp_str = ""
    disp_str += r"""
    ### Полная матрица $M$

    Полная матрица имеет блочно-диагональную структуру:

    $$
    M = \begin{pmatrix} M_x & 0 \\ 0 & M_y \end{pmatrix}
    $$

    где $M_y = M_x$ (из-за симметрии квадрата).

    """

    ## Показываем матрицу только для малых k (для больших слишком громоздко)
    if M_full.shape[0] <= 12:
        disp_str += rf"""
        \[
            M = {sp.latex(M_full)}
        \]
        """
    else:
        disp_str += rf"""
    Матрица имеет размер {M_full.shape[0]} × {M_full.shape[1]} (слишком большая для отображения).

    Блочная структура: верхний левый блок {M_full.shape[0]//2} × {M_full.shape[1]//2} — это $M_x$,
    нижний правый блок такого же размера — это $M_y = M_x$."""

    mo.md(disp_str)

    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Как использовать эту матрицу?

    1. **Найти обратную матрицу:** $M^{-1}$
    2. **Выразить коэффициенты мономов через степени свободы:** $\vec{c} = M^{-1} \cdot \vec{\sigma}$
    3. **Подставить в полином:** получить базисные функции $\phi_i(x,y)$
    4. **Вычислить матрицу Грама мономов:** $G_{kl} = \int_{\hat{K}} \psi_k \cdot \psi_l \, dx \, dy$
    5. **Собрать локальную матрицу жесткости:** $A = (M^{-1})^T \cdot G \cdot M^{-1}$

    Все эти операции выполняются **один раз** для эталонного квадрата $[0,1]^2$ и хардкодятся в библиотеку Basix.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Ключевые выводы

    1. **Матрица $M$ зависит только от $k$** — степени элемента. Не нужно знать конкретные значения коэффициентов, только структуру пространства.

    2. **Достаточно построить один блок $M_x$** — второй блок $M_y$ получается автоматически благодаря симметрии.

    3. **Каждый коэффициент матрицы — это результат интегрирования** мономов от 0 до 1 (или двойного интеграла для внутренних DOF).

    4. **Для левого ребра** многие коэффициенты зануляются (так как $0^i = 0$ для $i>0$).

    5. **Для правого ребра** все коэффициенты ненулевые (так как $1^i = 1$).

    6. **Для внутренних DOF** коэффициенты убывают с ростом степеней мономов (интеграл $\int_0^1 x^n dx = \frac{1}{n+1}$).
    """)
    return


if __name__ == "__main__":
    app.run()
```


`qk_and_abf.py`:
```py
import marimo

__generated_with = "0.23.13"
app = marimo.App()


@app.cell
def _():
    from itertools import product

    import marimo as mo
    import matplotlib.pyplot as plt
    import numpy as np
    import sympy as sp

    return mo, np, plt, product, sp


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Пространства ABF и \(Q_k\): полная теория через матрицы M и G

    В этой заметке мы разберёмся с пространством давления \(Q_k\) и покажем, как **все операции**
    с элементами ABF (дивергенция, скалярные произведения, интегралы) можно выразить через
    матрицы \(M\) и \(G\).

    ## План заметки

    1. **Зачем нужно \(Q_k\)?** — роль пространства давления в смешанной формулировке
    2. **Определение \(Q_k\)** — тензорное произведение полиномов
    3. **Степени свободы для \(Q_k\)** — как измерить давление
    4. **Матрица \(M\) для \(Q_k\)** — явный вывод с формулами
    5. **Матрица Грамма \(G\) для \(Q_k\)** — скалярные произведения мономов
    6. **Связь \(\text{ABF}_k\) и \(Q_k\)** — операция дивергенции
    7. **Матрица дивергенции \(B\)** — финальная формула
    8. **Интерактивная демонстрация** — визуализация всех матриц
    9. **Практическое применение** — сборка системы МКЭ

    > **Ключевая идея:** Вся информация о базисных функциях закодирована в матрицах \(M\) и \(G\).
    > Любую операцию (дивергенция, интеграл, скалярное произведение) можно выразить через матричные
    > операции с этими матрицами.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## 1. Зачем нужно пространство \(Q_k\)?

    ### Смешанная формулировка уравнения Пуассона

    В смешанной формулировке мы ищем **две неизвестные функции**:

    \[
    \begin{cases}
    \mathbf{q} + \nabla u = 0 & \text{(закон Дарси/Фурье)} \\
    \nabla \cdot \mathbf{q} = f & \text{(закон сохранения)}
    \end{cases}
    \]

    где:
    - \(\mathbf{q} \in H(\text{div}, \Omega)\) — векторное поле (поток, скорость)
    - \(u \in L^2(\Omega)\) — скалярное поле (давление, температура)

    ### Дискретизация

    Для численного решения мы аппроксимируем обе функции:

    \[
    \mathbf{q}_h \in V_h \subset H(\text{div}, \Omega), \quad u_h \in W_h \subset L^2(\Omega)
    \]

    **Выбор пространств:**
    - Для потока: \(V_h = \text{ABF}_k\) (элементы Арнольда–Боффи–Фалка)
    - Для давления: \(W_h = Q_k\) (тензорное произведение полиномов)

    ### Почему именно \(Q_k\)?

    **Условие inf-sup (условие ЛББ):**

    Для устойчивости смешанного метода необходимо:

    \[
    \inf_{w_h \in W_h} \sup_{\mathbf{v}_h \in V_h} \frac{\int_\Omega w_h (\nabla \cdot \mathbf{v}_h) \, dx}{\|w_h\| \cdot \|\mathbf{v}_h\|_{H(\text{div})}} \geq \beta > 0
    \]

    **Ключевое свойство ABF:**

    \[
    \nabla \cdot \text{ABF}_k = Q_k
    \]

    Это означает, что **дивергенция любого элемента из ABF_k является полиномом из \(Q_k\)**, и наоборот —
    для любого полинома из \(Q_k\) существует элемент из ABF_k с такой дивергенцией.

    > **Аналогия:** ABF_k — это "пространство скоростей", а Q_k — "пространство дивергенций".
    > Они идеально подходят друг к другу, как ключ к замку.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## 2. Определение пространства \(Q_k\)

    ### Тензорное произведение полиномов

    Пространство \(Q_k\) на эталонном квадрате \(\hat{K} = [0,1]^2\) определяется как:

    \[
    Q_k = \mathcal{P}_k \otimes \mathcal{P}_k = \text{span} \{ x_1^{i_1} x_2^{i_2} : 0 \leq i_1, i_2 \leq k \}
    \]

    где \(\mathcal{P}_k\) — пространство полиномов степени не выше \(k\).

    ### В размерности \(d\)

    \[
    Q_k^{(d)} = \underbrace{\mathcal{P}_k \otimes \mathcal{P}_k \otimes \cdots \otimes \mathcal{P}_k}_{d \text{ раз}} = \text{span} \{ x_1^{i_1} x_2^{i_2} \cdots x_d^{i_d} : 0 \leq i_l \leq k \}
    \]

    ### Размерность

    Количество базисных мономов:

    \[
    \dim(Q_k^{(d)}) = (k+1)^d
    \]

    ### Примеры

    **\(Q_0\) (константы):**
    \[
    Q_0 = \text{span}\{1\}, \quad \dim(Q_0) = 1
    \]

    **\(Q_1\) (билинейные):**
    \[
    Q_1 = \text{span}\{1, x, y, xy\}, \quad \dim(Q_1) = 4
    \]

    **\(Q_2\) (биквадратичные):**
    \[
    Q_2 = \text{span}\{1, x, y, x^2, xy, y^2, x^2y, xy^2, x^2y^2\}, \quad \dim(Q_2) = 9
    \]

    ### Сравнение с полным полиномиальным пространством

    Полное пространство \(\mathcal{P}_k^{(2)}\) включает все мономы степени \(\leq k\):

    \[
    \mathcal{P}_k^{(2)} = \text{span}\{x^i y^j : i + j \leq k\}
    \]

    Размерность: \(\dim(\mathcal{P}_k^{(2)}) = \frac{(k+1)(k+2)}{2}\)

    | \(k\) | \(\dim(Q_k)\) | \(\dim(\mathcal{P}_k^{(2)})\) |
    |-------|---------------|-------------------------------|
    | 0 | 1 | 1 |
    | 1 | 4 | 3 |
    | 2 | 9 | 6 |

    > **Важно:** \(Q_k\) содержит "лишние" мономы (например, \(xy\) при \(k=1\)),
    > но это необходимо для согласованности с ABF_k.
    """)
    return


@app.cell
def _(mo):
    k_slider_def = mo.ui.slider(0, 3, value=1, label="Степень k для Q_k")
    return (k_slider_def,)


@app.cell(hide_code=True)
def _(k_slider_def, mo):
    mo.md(f"""
    {k_slider_def}
    """)
    return


@app.cell
def _(k_slider_def, mo, product):
    k_1 = k_slider_def.value

    # Мономы для Q_k
    def _():
        monomials = [
            "1",
        ]
        for i_1, i_2 in product(range(k_1 + 1), repeat=2):
            mon = (f"x^{i_1}" if i_1 != 0 else "") + (f"y^{i_2}" if i_2 != 0 else "")

            if mon:
                monomials.append(mon)
        return monomials

    mo.md(rf"""
    ### Интерактивный пример: \(Q_{k_1}\)

    **Пространство \(Q_{k_1}\):**

    \[
    Q_{k_1} = {"+".join(_())}
    \]

    **Размерность:** \((k+1)^2 = {(k_1 + 1) ** 2}\)
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## 3. Степени свободы для \(Q_k\)

    ### Два способа описать полином

    У нас есть поле \(u(x,y)\), которое мы хотим аппроксимировать полиномом из \(Q_k\).

    #### Способ 1: Через коэффициенты мономов

    \[
    u(x,y) = \sum_{i_1, i_2} c_{i_1, i_2} \cdot x^{i_1} y^{i_2}
    \]

    где \(c_{i_1, i_2}\) — **коэффициенты**, показывающие "вклад" каждого монома.

    > **Аналогия:** Рецепт пирога. Коэффициенты — это сколько граммов муки, сахара, яиц нужно взять.

    #### Способ 2: Через степени свободы (DOF)

    Степени свободы — это **линейные функционалы**, которые "измеряют" поле:

    \[
    \sigma_\alpha(u) = \text{некоторая характеристика поля } u
    \]

    > **Аналогия:** Характеристики готового пирога. Степени свободы — это вес, объём, сладость, калорийность.

    ### Зачем нужны степени свободы?

    В методе конечных элементов мы работаем именно со степенями свободы, потому что:

    1. **Физический смысл:** DOF часто имеют физическую интерпретацию (поток, давление, температура)
    2. **Сборка на сетке:** DOF на общих гранях автоматически "сшиваются"
    3. **Граничные условия:** граничные значения задаются как значения DOF
    4. **Апостериорные оценки:** невязка выражается через DOF

    ### Связь между коэффициентами и DOF

    Матрица \(M\) связывает эти два взгляда:

    \[
    \vec{\sigma} = M \cdot \vec{c}
    \]

    где:
    - \(\vec{c}\) — вектор коэффициентов мономов
    - \(\vec{\sigma}\) — вектор степеней свободы
    - \(M\) — матрица перехода

    Если \(M\) обратима, мы можем выразить коэффициенты через DOF:

    \[
    \vec{c} = M^{-1} \cdot \vec{\sigma}
    \]

    ### Базисные функции

    Подставляя это в разложение полинома:

    \[
    u(x,y) = \sum_{\alpha} c_\alpha \psi_\alpha(x,y) = \sum_{\alpha} \left( \sum_j (M^{-1})_{\alpha, j} \sigma_j \right) \psi_\alpha(x,y)
    \]

    Меняем порядок суммирования:

    \[
    u(x,y) = \sum_j \sigma_j \cdot \underbrace{\left( \sum_{\alpha} (M^{-1})_{\alpha, j} \psi_\alpha(x,y) \right)}_{\phi_j(x,y)}
    \]

    **Вот они — базисные функции!**

    \[
    \phi_j(x,y) = \sum_{\alpha} (M^{-1})_{\alpha, j} \cdot \psi_\alpha(x,y)
    \]

    ### Свойство Кронекера

    Благодаря построению, базисные функции обладают свойством:

    \[
    \sigma_i(\phi_j) = \delta_{ij} = \begin{cases} 1 & \text{если } i = j \\ 0 & \text{если } i \neq j \end{cases}
    \]

    То есть каждая базисная функция "откликается" единицей только на свою степень свободы.

    ### Сравнение с ABF

    Для элементов ABF степени свободы имели **физический смысл**:

    | Тип DOF | Формула | Физический смысл |
    |---------|---------|------------------|
    | Граничные | \(\int_{\text{ребро}} \mathbf{q} \cdot \mathbf{n} \, ds\) | Поток через ребро |
    | Внутренние | \(\int_{\text{ячейка}} \mathbf{q} \cdot \mathbf{v}_{\text{test}} \, dx\) | Моменты внутри ячейки |

    Для \(Q_k\) мы выбираем **моментные DOF** — интегралы от функции, умноженной на тестовые мономы:

    \[
    \sigma_{(m_1, m_2)}(u) = \int_{\hat{K}} u(\hat{\mathbf{x}}) \cdot x^{m_1} y^{m_2} \, d\hat{x}
    \]

    где \(0 \leq m_1, m_2 \leq k\).

    ### Почему именно интегралы?

    1. **Совместимость с ABF:** внутренние DOF элементов ABF имеют такую же структуру
    2. **Унисольвентность:** система функционалов однозначно определяет функцию
    3. **Физический смысл:** интеграл = среднее значение функции с весом
    4. **Матричная простота:** матрица \(M\) получается симметричной и положительно определённой

    ### Количество DOF

    Количество тестовых мономов = \((k+1)^2\), что совпадает с размерностью \(Q_k\).

    Это необходимо для **унисольвентности** — однозначного определения функции по её DOF.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Наглядный пример: \(Q_0\) (константы)

    Рассмотрим простейший случай: \(k=0\), пространство констант.

    **Полином:**
    \[
    u(x,y) = c_0 \cdot 1 = c_0
    \]

    **Коэффициент:** \(c_0\) — это просто значение константы.

    **Степень свободы:**
    \[
    \sigma_0(u) = \int_0^1 \int_0^1 u(x,y) \cdot 1 \, dx \, dy = \int_0^1 \int_0^1 c_0 \, dx \, dy = c_0
    \]

    **Матрица \(M\):**
    \[
    M = [1] \quad \text{(скаляр, равный 1)}
    \]

    **Связь:**
    \[
    \sigma_0 = M \cdot c_0 = 1 \cdot c_0 = c_0
    \]

    **Базисная функция:**
    \[
    \phi_0(x,y) = 1
    \]

    **Проверка свойства Кронекера:**
    \[
    \sigma_0(\phi_0) = \int_0^1 \int_0^1 1 \cdot 1 \, dx \, dy = 1 \quad \checkmark
    \]

    **Физический смысл:** Для константного давления степень свободы — это просто среднее значение давления по ячейке, которое совпадает с самим значением.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Более сложный пример: \(Q_1\) (билинейные функции)

    **Полином:**
    \[
    u(x,y) = c_{00} \cdot 1 + c_{10} \cdot x + c_{01} \cdot y + c_{11} \cdot xy
    \]

    **Коэффициенты:** \(c_{00}, c_{10}, c_{01}, c_{11}\) — это "вклады" каждого монома.

    **Степени свободы (4 штуки):**

    \[
    \sigma_{00}(u) = \int_0^1 \int_0^1 u(x,y) \cdot 1 \, dx \, dy
    \]

    \[
    \sigma_{10}(u) = \int_0^1 \int_0^1 u(x,y) \cdot x \, dx \, dy
    \]

    \[
    \sigma_{01}(u) = \int_0^1 \int_0^1 u(x,y) \cdot y \, dx \, dy
    \]

    \[
    \sigma_{11}(u) = \int_0^1 \int_0^1 u(x,y) \cdot xy \, dx \, dy
    \]

    **Физический смысл:**
    - \(\sigma_{00}\) — среднее значение давления
    - \(\sigma_{10}\) — "центр тяжести" по \(x\)
    - \(\sigma_{01}\) — "центр тяжести" по \(y\)
    - \(\sigma_{11}\) — корреляция \(x\) и \(y\)

    **Матрица \(M\) (4×4):**

    Связывает коэффициенты \(c_{00}, c_{10}, c_{01}, c_{11}\) со степенями свободы \(\sigma_{00}, \sigma_{10}, \sigma_{01}, \sigma_{11}\).

    **Базисные функции (4 штуки):**

    Каждая базисная функция \(\phi_j(x,y)\) "откликается" единицей только на свою степень свободы:

    \[
    \sigma_i(\phi_j) = \delta_{ij}
    \]

    Например, \(\phi_{00}(x,y)\) — это такая билинейная функция, что:
    - Её среднее значение = 1
    - Её "центр тяжести" по \(x\) = 0
    - Её "центр тяжести" по \(y\) = 0
    - Её корреляция \(xy\) = 0

    **Ключевая идея:** Базисные функции — это не мономы \(1, x, y, xy\), а специальные комбинации мономов, которые обладают свойством Кронекера относительно выбранных DOF.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## 4. Матрица перехода \(M\) для \(Q_k\)

    ### Что такое матрица перехода?

    Матрица перехода \(M\) связывает **два способа описания** одного и того же поля \(u \in Q_k\):

    1. **Через коэффициенты мономов:** \(\vec{c} = (c_{00}, c_{10}, c_{01}, \dots)\)
    2. **Через степени свободы:** \(\vec{\sigma} = (\sigma_{00}, \sigma_{10}, \sigma_{01}, \dots)\)

    Связь:
    \[
    \vec{\sigma} = M \cdot \vec{c}
    \]

    Каждый элемент матрицы \(M_{\beta, \alpha}\) показывает: **какой вклад коэффициент \(c_\alpha\) вносит в степень свободы \(\sigma_\beta\)**.

    ### Вывод формулы для элементов матрицы

    #### Шаг 1: Записываем определение DOF

    Степень свободы — это интеграл:

    \[
    \sigma_{(m_1, m_2)}(u) = \int_0^1 \int_0^1 u(x,y) \cdot x^{m_1} y^{m_2} \, dx \, dy
    \]

    где \((m_1, m_2)\) — **мультииндекс** (пара чисел), обозначающий тестовый моном.

    #### Шаг 2: Подставляем разложение через коэффициенты

    \[
    u(x,y) = \sum_{i_1=0}^{k} \sum_{i_2=0}^{k} c_{i_1, i_2} \cdot x^{i_1} y^{i_2}
    \]

    Подставляем в интеграл:

    \[
    \sigma_{(m_1, m_2)}(u) = \int_0^1 \int_0^1 \left( \sum_{i_1, i_2} c_{i_1, i_2} \cdot x^{i_1} y^{i_2} \right) \cdot x^{m_1} y^{m_2} \, dx \, dy
    \]

    #### Шаг 3: Меняем порядок суммирования и интегрирования

    \[
    \sigma_{(m_1, m_2)}(u) = \sum_{i_1, i_2} c_{i_1, i_2} \cdot \underbrace{\int_0^1 \int_0^1 x^{i_1 + m_1} y^{i_2 + m_2} \, dx \, dy}_{M_{(m_1, m_2), (i_1, i_2)}}
    \]

    **Вот она — матрица \(M\)!**

    #### Шаг 4: Вычисляем интеграл

    Интеграл распадается в произведение:

    \[
    \int_0^1 \int_0^1 x^{i_1 + m_1} y^{i_2 + m_2} \, dx \, dy = \left( \int_0^1 x^{i_1 + m_1} \, dx \right) \cdot \left( \int_0^1 y^{i_2 + m_2} \, dy \right)
    \]

    Используем формулу \(\int_0^1 x^n \, dx = \frac{1}{n+1}\):

    \[
    \boxed{M_{(m_1, m_2), (i_1, i_2)} = \frac{1}{(i_1 + m_1 + 1)(i_2 + m_2 + 1)}}
    \]
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Почему 4 индекса? Это не тензор!

    Ты заметил, что у матрицы \(M\) четыре индекса: \((m_1, m_2)\) и \((i_1, i_2)\).

    **Это не тензор четвёртого ранга!** Это обычная двумерная матрица, но мы используем **мультииндексы** для нумерации строк и столбцов.

    #### Что такое мультииндекс?

    В 2D каждый моном характеризуется **парой степеней**:
    - \(1 = x^0 y^0\) → индекс \((0, 0)\)
    - \(x = x^1 y^0\) → индекс \((1, 0)\)
    - \(y = x^0 y^1\) → индекс \((0, 1)\)
    - \(xy = x^1 y^1\) → индекс \((1, 1)\)

    #### Превращение в обычную матрицу

    Мы просто **нумеруем** мультииндексы линейно:

    | Мультииндекс | Линейный номер |
    |--------------|----------------|
    | \((0, 0)\) | 0 |
    | \((1, 0)\) | 1 |
    | \((0, 1)\) | 2 |
    | \((1, 1)\) | 3 |

    Тогда матрица \(M\) становится обычной двумерной матрицей:

    \[
    M = \begin{pmatrix}
    M_{0,0} & M_{0,1} & M_{0,2} & M_{0,3} \\
    M_{1,0} & M_{1,1} & M_{1,2} & M_{1,3} \\
    M_{2,0} & M_{2,1} & M_{2,2} & M_{2,3} \\
    M_{3,0} & M_{3,1} & M_{3,2} & M_{3,3}
    \end{pmatrix}
    \]

    где, например:
    - \(M_{1,2}\) — это элемент на пересечении строки \((1,0)\) и столбца \((0,1)\)
    - \(M_{1,2} = M_{(1,0), (0,1)} = \frac{1}{(0+1+1)(1+0+1)} = \frac{1}{4}\)

    #### Аналогия

    Пред Excel-таблицу с именами колонок A, B, C, D.

    Можно обратиться к ячейке как `B3` (колонка B, строка 3), или как `2,3` (колонка 2, строка 3).
    Это **одна и та же ячейка**, просто разные способы адресации.

    Так же и с мультииндексами: \((m_1, m_2)\) — это "имя" строки, \((i_1, i_2)\) — "имя" столбца.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Почему \(M\) — это матрица Грамма?

    #### Определение матрицы Грамма

    Матрица Грамма \(G\) содержит **попарные скалярные произведения** базисных функций:

    \[
    G_{\alpha, \beta} = \langle \psi_\alpha, \psi_\beta \rangle = \int_{\hat{K}} \psi_\alpha(\mathbf{x}) \cdot \psi_\beta(\mathbf{x}) \, d\mathbf{x}
    \]

    #### А теперь смотрим на нашу матрицу \(M\)

    \[
    M_{(m_1, m_2), (i_1, i_2)} = \int_0^1 \int_0^1 \underbrace{x^{m_1} y^{m_2}}_{\psi_\beta} \cdot \underbrace{x^{i_1} y^{i_2}}_{\psi_\alpha} \, dx \, dy = \langle \psi_\alpha, \psi_\beta \rangle
    \]

    **Это точно матрица Грамма!**

    #### Почему так получилось?

    Потому что для \(Q_k\) мы выбрали **моментные DOF** — интегралы от функции, умноженной на тестовые мономы:

    \[
    \sigma_\beta(u) = \int u \cdot \psi_\beta \, d\mathbf{x}
    \]

    Подставляя \(u = \sum c_\alpha \psi_\alpha\):

    \[
    \sigma_\beta(u) = \sum_\alpha c_\alpha \int \psi_\alpha \cdot \psi_\beta \, d\mathbf{x} = \sum_\alpha c_\alpha \cdot G_{\alpha, \beta}
    \]

    То есть:
    \[
    \vec{\sigma} = G \cdot \vec{c}
    \]

    **Вывод:** Для \(Q_k\) матрица перехода \(M\) **совпадает** с матрицей Грамма \(G\):

    \[
    M = G
    \]
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Сравнение с ABF: почему там \(M \neq G\)?

    Для элементов ABF степени свободы были **другими**:

    | Тип DOF | Формула для ABF |
    |---------|-----------------|
    | Левое ребро | \(\sigma_{\text{left}} = \int_{x=0} \mathbf{q} \cdot \mathbf{n} \cdot \psi \, ds\) |
    | Правое ребро | \(\sigma_{\text{right}} = \int_{x=1} \mathbf{q} \cdot \mathbf{n} \cdot \psi \, ds\) |
    | Внутренние | \(\sigma_{\text{int}} = \int_{\text{ячейка}} \mathbf{q} \cdot \psi \, d\mathbf{x}\) |

    #### Матрица \(M\) для ABF

    Содержит интегралы **по граням** и **по объёму**:

    \[
    M_{\text{left}} = \int_{x=0} \psi_\alpha \cdot \psi_\beta \, dy \quad \text{(интеграл по ребру)}
    \]

    \[
    M_{\text{right}} = \int_{x=1} \psi_\alpha \cdot \psi_\beta \, dy \quad \text{(интеграл по ребру)}
    \]

    \[
    M_{\text{int}} = \int_{\text{ячейка}} \psi_\alpha \cdot \psi_\beta \, dx \, dy \quad \text{(интеграл по объёму)}
    \]

    #### Матрица Грамма \(G\) для ABF

    Содержит **только** интегралы по объёму:

    \[
    G_{\alpha, \beta} = \int_{\text{ячейка}} \psi_\alpha \cdot \psi_\beta \, dx \, dy
    \]

    #### Вывод

    Для ABF:
    \[
    M \neq G
    \]

    потому что DOF включают интегралы по граням, а матрица Грамма — только интегралы по объёму.

    Для \(Q_k\):
    \[
    M = G
    \]

    потому что DOF — это только интегралы по объёму.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Конкретный пример: \(Q_1\) в 2D

    #### Мономы

    Пространство \(Q_1\) содержит 4 монома:

    | Номер | Мультииндекс | Моном |
    |-------|--------------|-------|
    | 0 | \((0, 0)\) | \(1\) |
    | 1 | \((1, 0)\) | \(x\) |
    | 2 | \((0, 1)\) | \(y\) |
    | 3 | \((1, 1)\) | \(xy\) |

    #### Коэффициенты

    \[
    u(x,y) = c_0 \cdot 1 + c_1 \cdot x + c_2 \cdot y + c_3 \cdot xy
    \]

    #### Степени свободы

    \[
    \sigma_0(u) = \int_0^1 \int_0^1 u(x,y) \cdot 1 \, dx \, dy
    \]

    \[
    \sigma_1(u) = \int_0^1 \int_0^1 u(x,y) \cdot x \, dx \, dy
    \]

    \[
    \sigma_2(u) = \int_0^1 \int_0^1 u(x,y) \cdot y \, dx \, dy
    \]

    \[
    \sigma_3(u) = \int_0^1 \int_0^1 u(x,y) \cdot xy \, dx \, dy
    \]

    #### Вычисляем элементы матрицы \(M = G\)

    Используем формулу:

    \[
    M_{\beta, \alpha} = \frac{1}{(i_1 + m_1 + 1)(i_2 + m_2 + 1)}
    \]

    **Пример 1:** \(M_{0, 0}\) (строка \((0,0)\), столбец \((0,0)\))

    \[
    M_{0,0} = \int_0^1 \int_0^1 1 \cdot 1 \, dx \, dy = \frac{1}{(0+0+1)(0+0+1)} = 1
    \]

    **Пример 2:** \(M_{0, 1}\) (строка \((0,0)\), столбец \((1,0)\))

    \[
    M_{0,1} = \int_0^1 \int_0^1 1 \cdot x \, dx \, dy = \frac{1}{(1+0+1)(0+0+1)} = \frac{1}{2}
    \]

    **Пример 3:** \(M_{1, 2}\) (строка \((1,0)\), столбец \((0,1)\))

    \[
    M_{1,2} = \int_0^1 \int_0^1 x \cdot y \, dx \, dy = \frac{1}{(0+1+1)(1+0+1)} = \frac{1}{4}
    \]

    **Пример 4:** \(M_{3, 3}\) (строка \((1,1)\), столбец \((1,1)\))

    \[
    M_{3,3} = \int_0^1 \int_0^1 xy \cdot xy \, dx \, dy = \frac{1}{(1+1+1)(1+1+1)} = \frac{1}{9}
    \]

    #### Полная матрица \(M\) для \(Q_1\)

    \[
    M = G = \begin{pmatrix}
    1 & \frac{1}{2} & \frac{1}{2} & \frac{1}{4} \\[6pt]
    \frac{1}{2} & \frac{1}{3} & \frac{1}{4} & \frac{1}{6} \\[6pt]
    \frac{1}{2} & \frac{1}{4} & \frac{1}{3} & \frac{1}{6} \\[6pt]
    \frac{1}{4} & \frac{1}{6} & \frac{1}{6} & \frac{1}{9}
    \end{pmatrix}
    \]

    #### Проверка: симметричность

    Заметим, что \(M_{1,2} = M_{2,1} = \frac{1}{4}\). Матрица **симметрична**, что характерно для матриц Грамма.

    #### Проверка: положительная определённость

    Все диагональные элементы положительны:
    - \(M_{0,0} = 1\)
    - \(M_{1,1} = \frac{1}{3}\)
    - \(M_{2,2} = \frac{1}{3}\)
    - \(M_{3,3} = \frac{1}{9}\)

    Это необходимо для того, чтобы матрица была обратима.
    """)
    return


@app.cell
def _(mo):
    k_slider_M = mo.ui.slider(0, 3, value=1, label="Степень k для Q_k")
    return (k_slider_M,)


@app.cell(hide_code=True)
def _(k_slider_M, mo):
    mo.md(f"""
    {k_slider_M}
    """)
    return


@app.cell
def _(k_slider_M, product, sp):
    k_2 = k_slider_M.value

    # Индексы мономов
    indices = list(product(range(k_2 + 1), repeat=2))
    n_coeffs = len(indices)

    # Матрица M_Q (она же G_Q)
    def _():

        M_Q = sp.zeros(n_coeffs, n_coeffs)
        for row, (m_1, m_2) in enumerate(indices):
            for col, (i_1, i_2) in enumerate(indices):
                M_Q[row, col] = sp.Rational(1, (i_1 + m_1 + 1) * (i_2 + m_2 + 1))
        return M_Q

    M_Q = _()
    # Вычисляем обратную матрицу
    M_Q_inv = M_Q.inv()
    return M_Q, M_Q_inv, k_2, n_coeffs


@app.cell(hide_code=True)
def _(M_Q, M_Q_inv, k_2, mo, n_coeffs, sp):
    # 1. Сохраняем заголовок в переменную
    header = mo.md(rf"""
    #### Интерактивный пример: матрица \(M\) для \(Q_{k_2}\)

    **Размер:** {n_coeffs} × {n_coeffs}
    """)

    # 2. Условную логику также сохраняем в переменную
    if n_coeffs <= 9:
        matrix_display = mo.md(rf"""
        **Матрица \(M = G\):**

        \[
        M = {sp.latex(M_Q)}
        \]

        **Обратная матрица \(M^{{-1}}\):**

        \[
        M^{{-1}} = {sp.latex(M_Q_inv)}
        \]

        **Проверка:** \(M \cdot M^{{-1}} = I\) (единичная матрица)
        """)
    else:
        matrix_display = mo.md(rf"""
        Матрица слишком большая для отображения ({n_coeffs} × {n_coeffs}).
        """)

    # 3. Собираем все элементы в единый блок.
    # Это последнее выражение ячейки, именно оно будет отрисовано в браузере.
    mo.vstack([header, matrix_display])
    return


@app.cell(hide_code=True)
def _(k_slider_M, mo):
    mo.md(f"""
    ### Интерактивный вывод матрицы \(M\) для \(Q_k\)

    {k_slider_M}
    """)
    return


@app.cell
def _(k_slider_M, product, sp):

    def _():
        k = k_slider_M.value

        # Символьные переменные
        x, y = sp.symbols("x y")

        # Коэффициенты мономов
        c = sp.symarray("c", (k + 1, k + 1))

        # Полином u(x,y)
        u = sum(c[i, j] * x**i * y**j for i in range(k + 1) for j in range(k + 1))

        # Список всех коэффициентов
        coeffs_list = [c[i, j] for i in range(k + 1) for j in range(k + 1)]

        # Степени свободы
        dofs_list = []
        dof_names = []

        for m_1, m_2 in product(range(k + 1), repeat=2):
            # Интеграл от u * x^{m_1} * y^{m_2}
            dof_expr = sp.integrate(
                sp.integrate(u * x**m_1 * y**m_2, (x, 0, 1)), (y, 0, 1)
            )
            dofs_list.append(dof_expr)
            dof_names.append(f"\\sigma_{{({m_1},{m_2})}}")

        # Строим матрицу M
        n_dofs_2 = len(dofs_list)
        n_coeffs_2 = len(coeffs_list)
        M_Q_2 = sp.zeros(n_dofs_2, n_coeffs_2)

        for row, dof_expr in enumerate(dofs_list):
            for col, coeff in enumerate(coeffs_list):
                M_Q_2[row, col] = sp.simplify(dof_expr.coeff(coeff))
        return M_Q_2, dof_names, u

    M_Q_2, dof_names, u = _()
    return M_Q_2, dof_names, u


@app.cell(hide_code=True)
def _(M_Q_2, dof_names, k_slider_M, mo, sp, u):
    k1 = k_slider_M.value

    def _():
        part1 = mo.md(rf"""
        #### Полином давления

        \[
        u(x, y) = {sp.latex(u)}
        \]

        #### Список степеней свободы

        """)

        dof_str = "\n".join(
            [rf"{i + 1}. \({name}\)" for i, name in enumerate(dof_names)]
        )
        md_dof_str = mo.md(dof_str)

        part2 = mo.md(rf"""
        #### Матрица перехода \(M\) для \(Q_{k1}\)

        **Размер:** {M_Q_2.shape[0]} × {M_Q_2.shape[1]}

        """)

        part3 = None

        if M_Q_2.shape[0] <= 9:
            part3 = mo.md(rf"""
            \[
            M = {sp.latex(M_Q_2)}
            \]
            """)
        else:
            part3 = mo.md(f"""
            Матрица слишком большая для отображения ({M_Q_2.shape[0]} × {M_Q_2.shape[1]}).
            """)
        return (part1, md_dof_str, part2, part3)

    mo.vstack(_())
    return


@app.cell(hide_code=True)
def _(M_Q_2, mo, sp):
    mo.md(rf"""
    ### Проверка: свойство унисольвентности

    Матрица \(M\) должна быть **невырожденной**, чтобы степени свободы однозначно определяли функцию.

    **Проверка:** \(\det(M) = {sp.latex(M_Q_2.det())} \neq 0\)

    Если \(M\) обратима, мы можем выразить коэффициенты через DOF:

    \[
    \vec{{c}} = M^{{-1}} \cdot \vec{{\sigma}}
    \]

    Это даёт нам **базисные функции**:

    \[
    \phi_j(\hat{{\mathbf{{x}}}}) = \sum_{{\alpha}} (M^{{-1}})_{{\alpha, j}} \cdot \psi_\alpha(\hat{{\mathbf{{x}}}})
    \]

    Базисные функции обладают свойством Кронекера:

    \[
    \sigma_i(\phi_j) = \delta_{{ij}} = \begin{{cases}} 1 & \text{{если }} i = j \\ 0 & \text{{если }} i \neq j \end{{cases}}
    \]
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## 5. Матрица Грамма \(G\) для \(Q_k\)

    ### Определение

    Матрица Грамма содержит попарные скалярные произведения базисных мономов:

    \[
    G_{\alpha, \beta} = \int_{\hat{K}} \psi_\alpha(\hat{\mathbf{x}}) \cdot \psi_\beta(\hat{\mathbf{x}}) \, d\hat{x}
    \]

    где \(\psi_\alpha(\hat{\mathbf{x}}) = x_1^{i_1} x_2^{i_2}\) и \(\psi_\beta(\hat{\mathbf{x}}) = x_1^{j_1} x_2^{j_2}\).

    ### Вывод формулы

    \[
    G_{(i_1, i_2), (j_1, j_2)} = \int_0^1 \int_0^1 x_1^{i_1} x_2^{i_2} \cdot x_1^{j_1} x_2^{j_2} \, dx_1 \, dx_2
    \]

    \[
    = \int_0^1 \int_0^1 x_1^{i_1 + j_1} x_2^{i_2 + j_2} \, dx_1 \, dx_2
    \]

    \[
    = \left( \int_0^1 x_1^{i_1 + j_1} \, dx_1 \right) \cdot \left( \int_0^1 x_2^{i_2 + j_2} \, dx_2 \right)
    \]

    \[
    \boxed{G_{(i_1, i_2), (j_1, j_2)} = \frac{1}{(i_1 + j_1 + 1)(i_2 + j_2 + 1)}}
    \]

    ### Сравнение с матрицей \(M\)

    Заметим, что формулы для \(M\) и \(G\) **совпадают**:

    \[
    M_{(m_1, m_2), (i_1, i_2)} = G_{(m_1, m_2), (i_1, i_2)} = \frac{1}{(i_1 + m_1 + 1)(i_2 + m_2 + 1)}
    \]

    **Почему так?**

    Потому что для \(Q_k\) мы выбрали **моментные DOF** — интегралы от функции, умноженной на тестовые мономы.
    Это означает, что матрица перехода \(M\) **совпадает** с матрицей Грамма \(G\):

    \[
    M = G
    \]

    > **Важно:** Это специфично для \(Q_k\). Для ABF_k матрицы \(M\) и \(G\) разные,
    > потому что DOF включают интегралы по граням.

    ### Свойства матрицы \(G\)

    1. **Симметричность:** \(G_{\alpha, \beta} = G_{\beta, \alpha}\)
    2. **Положительная определённость:** \(\vec{v}^T G \vec{v} > 0\) для \(\vec{v} \neq 0\)
    3. **Убывание элементов:** коэффициенты убывают с ростом степеней
    """)
    return


@app.cell
def _(k_slider_M, product, sp):
    def _():
        k = k_slider_M.value

        # Индексы мономов
        indices_2 = list(product(range(k + 1), repeat=2))
        n_coeffs_2 = len(indices_2)

        # Матрица Грамма G_Q
        G_Q = sp.zeros(n_coeffs_2, n_coeffs_2)

        for row, (i_1, i_2) in enumerate(indices_2):
            for col, (j_1, j_2) in enumerate(indices_2):
                G_Q[row, col] = sp.Rational(1, (i_1 + j_1 + 1) * (i_2 + j_2 + 1))
        return G_Q

    G_Q = _()
    return (G_Q,)


@app.cell(hide_code=True)
def _(G_Q, M_Q_2, k_slider_M, mo, sp):
    def _():
        k = k_slider_M.value

        part1 = mo.md(rf"""
        #### Матрица Грамма \(G\) для \(Q_{k}\)

        **Размер:** {G_Q.shape[0]} × {G_Q.shape[1]}

        """)

        part2 = None
        if G_Q.shape[0] <= 9:
            if G_Q == M_Q_2:
                part2 = mo.md(rf"""
                \[
                G = {sp.latex(G_Q)} \quad M = {sp.latex(M_Q_2)}
                \]

                **Заметим:** \(M = G\) для пространства \(Q_k\)!
                """)
            else:
                part2 = mo.md("*МАТРИЦЫ НЕ РАВНЫ*")
        else:
            part2 = mo.md("""
            Матрица слишком большая для отображения.
            """)
        return (part1, part2)

    mo.vstack(_())
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## 6. Связь \(\text{ABF}_k\) и \(Q_k\): операция дивергенции

    ### Ключевое свойство элементов ABF

    Элементы ABF обладают важным свойством **точной коммутативности**:

    \[
    \nabla \cdot \text{ABF}_k = Q_k
    \]

    Это означает:
    1. Дивергенция любого элемента из \(\text{ABF}_k\) является полиномом из \(Q_k\)
    2. Для любого полинома из \(Q_k\) существует элемент из \(\text{ABF}_k\) с такой дивергенцией

    ### Структура элемента ABF

    Элемент \(\mathbf{q} \in \text{ABF}_k\) в 2D:

    \[
    \mathbf{q}(x, y) = \begin{pmatrix} v_x(x, y) \\ v_y(x, y) \end{pmatrix}
    \]

    где:
    - \(v_x \in \mathcal{Q}_{k+2, k}\) (степень \(k+2\) по \(x\), степень \(k\) по \(y\))
    - \(v_y \in \mathcal{Q}_{k, k+2}\) (степень \(k\) по \(x\), степень \(k+2\) по \(y\))

    ### Дивергенция

    \[
    \nabla \cdot \mathbf{q} = \frac{\partial v_x}{\partial x} + \frac{\partial v_y}{\partial y}
    \]

    **Анализ степеней:**

    - \(v_x \in \mathcal{Q}_{k+2, k}\) → \(\frac{\partial v_x}{\partial x} \in \mathcal{Q}_{k+1, k}\)
    - \(v_y \in \mathcal{Q}_{k, k+2}\) → \(\frac{\partial v_y}{\partial y} \in \mathcal{Q}_{k, k+1}\)

    **Сумма:**

    \[
    \nabla \cdot \mathbf{q} \in \mathcal{Q}_{k+1, k} + \mathcal{Q}_{k, k+1}
    \]

    Но \(\mathcal{Q}_{k+1, k} \subset \mathcal{Q}_{k+1, k+1}\) и \(\mathcal{Q}_{k, k+1} \subset \mathcal{Q}_{k+1, k+1}\), поэтому:

    \[
    \nabla \cdot \mathbf{q} \in \mathcal{Q}_{k+1, k+1}
    \]

    Однако на самом деле дивергенция лежит в **меньшем** пространстве:

    \[
    \nabla \cdot \text{ABF}_k = Q_k
    \]

    Это достигается благодаря специальной структуре полиномов в ABF (наличие "лишних" мономов).

    ### Почему это важно?

    Для **условия inf-sup** необходимо, чтобы оператор дивергенции был **сюръективным**:

    \[
    \nabla \cdot : V_h \to W_h
    \]

    Если \(\nabla \cdot V_h \subsetneq W_h\), то для некоторых \(w_h \in W_h\) не существует \(\mathbf{v}_h \in V_h\) с \(\nabla \cdot \mathbf{v}_h = w_h\),
    и условие inf-sup нарушается.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## 7. Матрица дивергенции \(B\)

    ### Определение

    В смешанной формулировке матрица \(B\) связывает DOF потока с DOF давления:

    \[
    B_{ij} = \int_{\hat{K}} u_i (\nabla \cdot \mathbf{q}_j) \, d\hat{x}
    \]

    где:
    - \(u_i\) — \(i\)-я базисная функция давления
    - \(\mathbf{q}_j\) — \(j\)-я базисная функция потока

    ### Выражение через матрицы \(M\) и \(G\)

    #### Шаг 1: Разложение базисных функций

    Базисные функции выражаются через мономы:

    \[
    u_i(\hat{\mathbf{x}}) = \sum_{\alpha} (M_u^{-1})_{\alpha, i} \cdot \psi_\alpha^u(\hat{\mathbf{x}})
    \]

    \[
    \mathbf{q}_j(\hat{\mathbf{x}}) = \sum_{\beta} (M_q^{-1})_{\beta, j} \cdot \boldsymbol{\psi}_\beta^q(\hat{\mathbf{x}})
    \]

    где:
    - \(\psi_\alpha^u\) — мономы из \(Q_k\)
    - \(\boldsymbol{\psi}_\beta^q\) — векторные мономы из \(\text{ABF}_k\)

    #### Шаг 2: Подстановка в интеграл

    \[
    B_{ij} = \int_{\hat{K}} \left( \sum_{\alpha} (M_u^{-1})_{\alpha, i} \psi_\alpha^u \right) \cdot \left( \nabla \cdot \sum_{\beta} (M_q^{-1})_{\beta, j} \boldsymbol{\psi}_\beta^q \right) \, d\hat{x}
    \]

    Выносим константы:

    \[
    B_{ij} = \sum_{\alpha} \sum_{\beta} (M_u^{-1})_{\alpha, i} \cdot (M_q^{-1})_{\beta, j} \cdot \int_{\hat{K}} \psi_\alpha^u \cdot (\nabla \cdot \boldsymbol{\psi}_\beta^q) \, d\hat{x}
    \]

    #### Шаг 3: Матрица Грамма дивергенции

    Вводим матрицу \(G_{\text{div}}\):

    \[
    (G_{\text{div}})_{\alpha, \beta} = \int_{\hat{K}} \psi_\alpha^u(\hat{\mathbf{x}}) \cdot (\nabla \cdot \boldsymbol{\psi}_\beta^q(\hat{\mathbf{x}})) \, d\hat{x}
    \]

    #### Шаг 4: Матричная форма

    \[
    \boxed{B = M_u^{-T} \cdot G_{\text{div}} \cdot M_q^{-1}}
    \]

    где \(M_u^{-T} = (M_u^{-1})^T\) — транспонированная обратная матрица.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Вычисление матрицы \(G_{\text{div}}\)

    #### Структура мономов

    Для компоненты \(v_x\) в пространстве \(\text{ABF}_k\):

    \[
    \boldsymbol{\psi}_\beta^q = x^{i_1} y^{i_2} \cdot \mathbf{e}_x
    \]

    где \(i_1 \in [0, k+2]\), \(i_2 \in [0, k]\).

    Дивергенция:

    \[
    \nabla \cdot \boldsymbol{\psi}_\beta^q = \frac{\partial}{\partial x} (x^{i_1} y^{i_2}) = i_1 \cdot x^{i_1 - 1} y^{i_2}
    \]

    Для мономов давления \(Q_k\):

    \[
    \psi_\alpha^u = x^{m_1} y^{m_2}
    \]

    где \(m_1, m_2 \in [0, k]\).

    #### Интеграл

    \[
    (G_{\text{div}})_{\alpha, \beta} = \int_0^1 \int_0^1 x^{m_1} y^{m_2} \cdot i_1 \cdot x^{i_1 - 1} y^{i_2} \, dx \, dy
    \]

    \[
    = i_1 \cdot \left( \int_0^1 x^{m_1 + i_1 - 1} \, dx \right) \cdot \left( \int_0^1 y^{m_2 + i_2} \, dy \right)
    \]

    \[
    \boxed{(G_{\text{div}})_{(m_1, m_2), (i_1, i_2)} = \frac{i_1}{(m_1 + i_1)(m_2 + i_2 + 1)}}
    \]

    **Особый случай:** если \(i_1 = 0\), то \(\nabla \cdot \boldsymbol{\psi}_\beta^q = 0\), поэтому \((G_{\text{div}})_{\alpha, \beta} = 0\).

    #### Для компоненты \(v_y\)

    Аналогично, для \(v_y \in \mathcal{Q}_{k, k+2}\):

    \[
    \boldsymbol{\psi}_\beta^q = x^{i_1} y^{i_2} \cdot \mathbf{e}_y
    \]

    \[
    \nabla \cdot \boldsymbol{\psi}_\beta^q = i_2 \cdot x^{i_1} y^{i_2 - 1}
    \]

    \[
    (G_{\text{div}})_{(m_1, m_2), (i_1, i_2)} = \frac{i_2}{(m_1 + i_1 + 1)(m_2 + i_2)}
    \]

    #### Полная матрица \(G_{\text{div}}\)

    Для полного векторного поля \(\mathbf{q} = (v_x, v_y)\):

    \[
    G_{\text{div}}^{\text{full}} = [G_{\text{div}}^x, G_{\text{div}}^y]
    \]

    где \(G_{\text{div}}^x\) и \(G_{\text{div}}^y\) — блоки для компонент \(v_x\) и \(v_y\).
    """)
    return


@app.cell
def _(k_slider_M, product, sp):
    k = k_slider_M.value

    # Индексы мономов давления Q_k
    u_indices = list(product(range(k + 1), repeat=2))
    n_u = len(u_indices)

    # Индексы мономов потока для v_x (ABF_k, компонента x)
    q_x_indices = list(product(range(k + 3), range(k + 1)))
    n_q_x = len(q_x_indices)

    # Матрица G_div для компоненты v_x
    G_div_x = sp.zeros(n_u, n_q_x)

    for row, (m_1, m_2) in enumerate(u_indices):
        for col, (i_1, i_2) in enumerate(q_x_indices):
            if i_1 == 0:
                G_div_x[row, col] = sp.Integer(0)
            else:
                G_div_x[row, col] = sp.Rational(i_1, (m_1 + i_1) * (m_2 + i_2 + 1))
    return n_q_x, n_u


app._unparsable_cell(
    """
    k = k_slider_M.value

    mo.md(rf\"\"\"
    #### Матрица \\(G_{\\text{{div}}}^x\\) для компоненты \\(v_x\\)

    **Размер:** {n_u} × {n_q_x}

    \"\"\")

    if G_div_x.shape[0] <= 9 and G_div_x.shape[1] <= 9:
        mo.md(rf\"\"\"
        \\[
        G_{{\\text{{div}}}}^x = {sp.latex(G_div_x)}
        \\]
        \"\"\")
    else:
        mo.md(f\"\"\"
        Матрица слишком большая для отображения.
        \"\"\")
    return


    # === ЧАСТЬ 8: ФИНАЛЬНАЯ ФОРМУЛА ДЛЯ B ===
    """,
    name="_",
)


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Финальная формула для матрицы \(B\)

    #### Для одной компоненты потока

    \[
    B^x = M_u^{-T} \cdot G_{\text{div}}^x \cdot M_q^{-1}
    \]

    #### Для полного векторного поля

    Полная матрица \(B\) имеет блочную структуру:

    \[
    B^{\text{full}} = \begin{pmatrix} B^x & B^y \end{pmatrix}
    \]

    где:
    - \(B^x\) — блок для компоненты \(v_x\) (размер \(n_u \times n_{q_x}\))
    - \(B^y\) — блок для компоненты \(v_y\) (размер \(n_u \times n_{q_y}\))

    #### Специальный случай: \(M_u = G_u\)

    Для пространства \(Q_k\) мы показали, что \(M_u = G_u\) (матрица перехода совпадает с матрицей Грамма).

    Поэтому:

    \[
    B^x = G_u^{-T} \cdot G_{\text{div}}^x \cdot M_q^{-1} = G_u^{-1} \cdot G_{\text{div}}^x \cdot M_q^{-1}
    \]

    (так как \(G_u\) симметрична, \(G_u^{-T} = G_u^{-1}\))

    ### Физический смысл

    Матрица \(B\) отвечает за **закон сохранения** в смешанной формулировке:

    \[
    B \cdot \mathbf{Q} = \mathbf{F}_f
    \]

    где \(\mathbf{Q}\) — вектор DOF потока, \(\mathbf{F}_f\) — правая часть от источника \(f\).

    Каждая строка матрицы \(B\) соответствует одной базисной функции давления и выражает
    интеграл от дивергенции потока, взвешенный этой функцией.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## 8. Интерактивная демонстрация всех матриц

    Давайте визуализируем все матрицы для выбранной степени \(k\).
    """)
    return


@app.cell
def _(mo):
    k_slider_demo = mo.ui.slider(0, 2, value=0, label="Степень k для демонстрации")
    return (k_slider_demo,)


@app.cell(hide_code=True)
def _(k_slider_demo, mo):
    mo.md(f"""
    {k_slider_demo}
    """)
    return


@app.cell
def _(k_slider_demo, np, product, sp):
    k = k_slider_demo.value

    # === Матрицы для Q_k ===
    # M_Q = G_Q
    u_indices = list(product(range(k + 1), repeat=2))
    n_u = len(u_indices)

    G_u = sp.zeros(n_u, n_u)
    for row, (i_1, i_2) in enumerate(u_indices):
        for col, (j_1, j_2) in enumerate(u_indices):
            G_u[row, col] = sp.Rational(1, (i_1 + j_1 + 1) * (i_2 + j_2 + 1))

    M_u = G_u  # Для Q_k они совпадают

    # === Матрицы для ABF_k (компонента v_x) ===
    q_x_indices = list(product(range(k + 3), range(k + 1)))
    n_q_x = len(q_x_indices)

    # M_q для v_x (упрощённо, только для демонстрации)
    # В реальности это более сложная структура
    M_q_x = sp.zeros(n_q_x, n_q_x)
    for row, (m_1, m_2) in enumerate(q_x_indices):
        for col, (i_1, i_2) in enumerate(q_x_indices):
            # Упрощённая формула
            M_q_x[row, col] = sp.Rational(1, (i_1 + m_1 + 1) * (i_2 + m_2 + 1))

    # G_div_x
    G_div_x = sp.zeros(n_u, n_q_x)
    for row, (m_1, m_2) in enumerate(u_indices):
        for col, (i_1, i_2) in enumerate(q_x_indices):
            if i_1 == 0:
                G_div_x[row, col] = sp.Integer(0)
            else:
                G_div_x[row, col] = sp.Rational(i_1, (m_1 + i_1) * (m_2 + i_2 + 1))

    # Вычисляем B_x = M_u^{-1} * G_div_x * M_q_x^{-1}
    M_u_inv = M_u.inv()
    M_q_x_inv = M_q_x.inv()
    B_x = M_u_inv * G_div_x * M_q_x_inv
    B_x = sp.simplify(B_x)

    # Конвертируем в numpy для визуализации
    G_u_np = np.array(G_u.tolist(), dtype=float)
    G_div_x_np = np.array(G_div_x.tolist(), dtype=float)
    B_x_np = np.array(B_x.tolist(), dtype=float)
    return B_x_np, G_div_x_np, G_u_np, n_q_x, n_u


@app.cell(hide_code=True)
def _(B_x_np, G_div_x_np, G_u_np, k_slider_demo, mo, n_q_x, n_u, plt):
    k = k_slider_demo.value

    mo.md(rf"""
    ### Визуализация матриц для \(Q_{k}\) и \(\text{{ABF}}_{k}\) (компонента \(v_x\))

    """)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Матрица G_u (матрица Грамма для давления)
    im1 = axes[0].imshow(G_u_np, cmap="viridis", aspect="auto")
    axes[0].set_title(f"Матрица Грамма $G_u$ для $Q_{k}$\nРазмер: {n_u} × {n_u}")
    axes[0].set_xlabel("Моном j")
    axes[0].set_ylabel("Моном i")
    plt.colorbar(im1, ax=axes[0])

    # Матрица G_div_x (матрица Грамма дивергенции)
    im2 = axes[1].imshow(G_div_x_np, cmap="RdBu_r", aspect="auto")
    axes[1].set_title(f"Матрица $G_{{\\text{{div}}}}^x$\nРазмер: {n_u} × {n_q_x}")
    axes[1].set_xlabel("Моном потока j")
    axes[1].set_ylabel("Моном давления i")
    plt.colorbar(im2, ax=axes[1])

    # Матрица B_x (матрица дивергенции)
    im3 = axes[2].imshow(B_x_np, cmap="RdBu_r", aspect="auto")
    axes[2].set_title(f"Матрица дивергенции $B^x$\nРазмер: {n_u} × {n_q_x}")
    axes[2].set_xlabel("DOF потока j")
    axes[2].set_ylabel("DOF давления i")
    plt.colorbar(im3, ax=axes[2])

    plt.tight_layout()
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## 9. Практическое применение: сборка системы МКЭ

    ### Полная система уравнений

    В смешанной формулировке уравнения Пуассона мы получаем систему:

    \[
    \begin{pmatrix} A & B^T \\ B & 0 \end{pmatrix} \begin{pmatrix} \mathbf{Q} \\ \mathbf{U} \end{pmatrix} = \begin{pmatrix} \mathbf{F}_D \\ \mathbf{F}_f \end{pmatrix}
    \]

    где:
    - \(A\) — матрица масс для потока (\(\int \mathbf{q} \cdot \mathbf{v} \, dx\))
    - \(B\) — матрица дивергенции (\(\int u (\nabla \cdot \mathbf{v}) \, dx\))
    - \(\mathbf{Q}\) — вектор DOF потока
    - \(\mathbf{U}\) — вектор DOF давления
    - \(\mathbf{F}_D\) — правая часть от граничных условий Дирихле
    - \(\mathbf{F}_f\) — правая часть от источника \(f\)

    ### Роль каждой матрицы

    | Матрица | Формула | Физический смысл |
    |---------|---------|------------------|
    | \(A\) | \((M_q^{-1})^T G_q M_q^{-1}\) | Кинетическая энергия потока |
    | \(B\) | \(M_u^{-T} G_{\text{div}} M_q^{-1}\) | Закон сохранения массы |
    | \(G_q\) | \(\int \boldsymbol{\psi}_\alpha \cdot \boldsymbol{\psi}_\beta \, dx\) | Скалярные произведения мономов потока |
    | \(G_{\text{div}}\) | \(\int \psi_\alpha (\nabla \cdot \boldsymbol{\psi}_\beta) \, dx\) | Связь давления и дивергенции |

    ### Алгоритм сборки

    1. **Вычислить локальные матрицы** на эталонном элементе:
       - \(M_q, G_q\) для потока (из `abf_primitives`)
       - \(M_u, G_u\) для давления (выведены в этой заметке)
       - \(G_{\text{div}}\) (выведена в этой заметке)

    2. **Собрать локальные матрицы:**
       - \(A = (M_q^{-1})^T G_q M_q^{-1}\)
       - \(B = M_u^{-T} G_{\text{div}} M_q^{-1}\)

    3. **Применить преобразование Пиолы** для реальных ячеек

    4. **Собрать глобальную систему** по всем элементам

    5. **Применить граничные условия**

    6. **Решить систему** (итерационными методами для седловой точки)

    ### Преимущества матричного подхода

    1. **Модульность:** можно независимо разрабатывать элементы для потока и давления
    2. **Переиспользование:** матрицы \(G\) вычисляются один раз и хардкодятся
    3. **Автоматизация:** код генерируется автоматически для любой степени \(k\)
    4. **Проверяемость:** легко проверить свойства (симметричность, положительная определённость)
    5. **Обобщаемость:** подход работает для любых смешанных элементов (RT, BDM, ABF)
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ## 10. Ключевые выводы

    ### Что мы узнали

    1. **Пространство \(Q_k\)** — тензорное произведение полиномов, используемое для давления
    2. **Связь \(\text{ABF}_k\) и \(Q_k\):** \(\nabla \cdot \text{ABF}_k = Q_k\) (точная коммутативность)
    3. **Для \(Q_k\) матрицы \(M\) и \(G\) совпадают** (из-за моментных DOF)
    4. **Все операции с базисными функциями** можно выразить через матрицы \(M\) и \(G\)
    5. **Матрица дивергенции:** \(B = M_u^{-T} G_{\text{div}} M_q^{-1}\)

    ### Сводная таблица формул

    | Матрица | Формула | Назначение |
    |---------|---------|------------|
    | \(M_q\) | \(\sigma = M_q \cdot c\) | DOF потока через коэффициенты |
    | \(G_q\) | \(G_{ij} = \int \psi_i \cdot \psi_j\) | Скалярные произведения мономов потока |
    | \(A\) | \(A = M_q^{-T} G_q M_q^{-1}\) | Матрица масс для потока |
    | \(M_u\) | \(\sigma = M_u \cdot c\) | DOF давления через коэффициенты |
    | \(G_u\) | \(G_{ij} = \int \psi_i \cdot \psi_j\) | Скалярные произведения мономов давления |
    | \(G_{\text{div}}\) | \(\int \psi_i (\nabla \cdot \psi_j)\) | Связь давления и дивергенции |
    | \(B\) | \(B = M_u^{-T} G_{\text{div}} M_q^{-1}\) | Матрица дивергенции |

    ### Почему это важно для диплома

    1. **Полная теория:** вы понимаете, как работают элементы ABF на фундаментальном уровне
    2. **Автоматическая генерация:** код для любой степени \(k\) генерируется автоматически
    3. **Оптимизация:** матрицы вычисляются один раз и хардкодятся
    4. **Апостериорные оценки:** можно выразить невязку через матричные операции
    5. **Обобщение:** подход работает для других смешанных элементов

    ### Следующие шаги

    1. Добавить функции `compute_gram_div_block` и `compute_divergence_block` в `abf_primitives`
    2. Реализовать сборку на полной сетке с учётом ориентации рёбер
    3. Добавить обработку граничных условий (Дирихле, Неймана, Робина)
    4. Реализовать итерационный решатель для седловой точки
    5. Добавить апостериорные оценки погрешности
    """)
    return


if __name__ == "__main__":
    app.run()
```
