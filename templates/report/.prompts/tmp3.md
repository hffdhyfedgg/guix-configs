```typst


#import "std.typ":*
#import "@preview/lilaq:0.5.0" as lq
#import "@preview/oxifmt:0.3.0": strfmt


/*
Настройки отображения lq
*/
#show: lq.set-legend(position: bottom+left);
#show lq.selector(lq.tick-label): set text(0.6em)
#show lq.selector(lq.label): set text(0.8em)
#show lq.selector(lq.legend): it => {
  set text(0.6em);

  it
}

// return 2 * x * (1 - x) + 2 * y * (1 - y)
#let vecr = $arrow(r)$
Уравнение:
$
    cases(
        Omega equiv (0,1) times (0,1),
        - laplace u(vecr) = f","&       quad vecr in Omega,
        u(vecr) = 0","&                 quad vecr in partial ,
    )
$

Положим $u = sin(pi x) sin(pi y)$, тогда:
$
    laplace u = (dd^2 u)/(dd x^2) + (dd^2 u)/(dd y^2) =\
    = - pi^2 sin(pi x) sin(pi y) - pi^2 sin(pi x) sin(pi y) = - 2 pi^2 sin(pi x) sin(pi y), \
    f = 2 pi^2 sin(pi x) sin(pi y).
$


/*
#align(center)[#upper()[*Лабораторные работы 3 и 4*]]

== Лабораторная работа 3

#let csv_data = csv(
  "../data/iterations_K0.3.csv",
  row-type: dictionary
  );

#figure(
table(
  columns: csv_data.at(0).len(),
  table.header(
    [Итерации],[x],[y],[$||Delta||$],[$e_a$],[$e_"real"$],
  ),
  ..csv_data.map(
    row => {
      (row.iteration,
      strfmt("{:.2e}", float(row.x)),
      strfmt("{:.2e}", float(row.y)),
      strfmt("{:.2e}", float(row.diff_norm)),
      strfmt("{:.2e}", float(row.posterior_error)),
      strfmt("{:.2e}", float(row.real_error)))
    }
  ).flatten()
),
caption: [Результаты расчётов]
)
*/

```
