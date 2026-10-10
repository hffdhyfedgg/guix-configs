#import "preambule.typ" : conf
#import "std.typ": *

#import "@preview/codly:1.1.1": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
#import "@preview/touying:0.6.1": *

// Из шаблона для отчётов
// #show: doc => conf(doc)

#import themes.university: *

// Настройка темы с кастомными отступами и выравниваниями
#show: university-theme.with(
  aspect-ratio: "16-9",
  
  // Настройка отступов (это заменяет #set page(margin: ...))
  config-page(
    margin: (x: 5em, y: 2em), // увеличенные отступы
    header-ascent: 45%, // высота заголовка
    footer-descent: 10%, // высота футера
    footer: [Футер]
  ),
  
  // Информация о презентации
  config-info(
    title: [Какой-то заголовок презентации],
    subtitle: [Какой-то подзаголовок],
    author: [Авторы],
    date: datetime.today(),
    institution: [МИНОБР "МОЙ ГОСУДАРСТВЕННЫЙ ИНСТИТУТ"],
    logo: scale(150%)[#image("media/logogs/polytech_ru.svg")], // уменьшаем логотип
  ),
  
  // Настройка прогресс-бара (если нужно убрать)
  progress-bar: true,
  
  // Кастомизация хедера
  // Оба варианта не работают
  // header-right: self => place(top + right + (dx: -1em, dy: 1em), self.info.logo),
  // или полностью кастомное позиционирование:
  // header-right: self => place((x: 80%, y: 5%), self.info.logo),
  
  // Настройка футера - кастомные колонки
  footer-columns: (30%, 40%, 30%),
  footer-a: self => self.info.author,
  footer-b: self => self.info.institution,
  footer-c: self => {
    h(1fr)
    utils.display-info-date(self)
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
    h(1fr)
  },
  
  // Глобальные настройки стилей
  config-methods(
    init: (self: none, body) => {
      // Здесь можно добавить глобальные стили
      set text(size: 20pt) // размер текста по умолчанию
      set par(justify: true) // выравнивание текста по ширине
      
      body
    },
  ),
)


= ABC

== Слайд в первой секции

#place(top + right)[Margin→]

= Section

== Title

Hello, Touying!

// Пауза для анимации, вроде
#pause

// Пустой заголовок
== <touying:hidden> 

Ещё один слайд


// Библиография
// #bibliography("./src.bib"/* , full: true */, style: "../gost_style/gost-r-7-0-100-2018-numeric-alphabetical.csl", title: "СПИСОК ИСПОЛЬЗОВАННЫХ ИСТОЧНИКОВ")

// #counter(page).update(n => n - 1)
// #include "appendix.typ"








