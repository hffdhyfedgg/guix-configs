
#import "@local/std:0.0.1":*
#import "@local/modern-g7-32:0.2.0": abstract, gost


#show: doc => conf(doc);

#show: gost.with(
  ministry: "МИНОБРНАУКИ РОССИИ",
  organization: (
      full: "Санкт-Петербургский политехнический университет Петра Великого",
      short: "СПбПУ"
  ),
  performers: (
      (name: "Шептухин П.В.", position: "Студент\nгр. 5040102/50101 п/г 01", title: "Выполнил:"),
  ),
  report-type: "Отчёт",
  about: "...",
  subject: "...",
  bare-subject: false,
//   manager: (
//       name: "Фролов М.Е.",
//       position: "д-р физ. мат. наук, доцент",
//       title: "Руководитель практики",
//   ),
  city: "Санкт-Петербург\n",
)

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
// #show: codly-init.with()






#include "1_part.typ"

#outline()


#include "2_part.typ"
// #include "3_results.typ"
// #include "4_conclusion.typ"
// #include "blacknotes/equilibrium_of_flow.typ"
