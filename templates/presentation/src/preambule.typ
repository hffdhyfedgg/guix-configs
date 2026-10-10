
#let conf(doc) = {


/*=== Оформление всего документа ===*/


set par(
  // first-line-indent: 1.25cm,
  hanging-indent: -1.25cm,
  leading: 17pt,
  justify: true,
  linebreaks: "optimized",
)

set text(
  font: "Times New Roman",
  size: 14pt, 
  lang: "ru", 
  hyphenate: false,
  costs: (
    hyphenation: 0%,
    runt: 1000%,
    widow: 100%,
    orphan: 100%),
);
set page(margin: (
  top: 2cm,
  right: 1.5cm,
  bottom: 2cm,
  left: 3cm+1.25cm,
  ),
  numbering: "1",
)


/*=== Оформление заголовков ===*/


set heading(numbering: "1.1")

show heading: it => {
  set text(hyphenate: false);
  set par(first-line-indent:0cm,
  hanging-indent: 0cm,
  leading: 1.3em,
  justify: false,
  linebreaks: "optimized",
  )
  it
}

show heading.where(level: 1): it =>{
  pagebreak();
  set align(center);
  set text(size: 14pt);
  set block(below: 2.6em);
  counter(math.equation).update(0);
  upper(it)
};
show heading.where(level: 2): it =>{
  set align(left);
  set text(size: 14pt);
  set block(below: 1.3em, above: 1.3em+10pt);
  it
};
show heading.where(level: 3): it =>{
  set align(left);
  set text(size: 14pt, weight: "regular");
  set block(below: 1.3em, above: 1.3em+10pt);
  it
};


/*=== Оформление оглавления ===*/


set outline(
  depth: 3,
  indent: 0.5cm
);
show outline: it => {  
  set text(hyphenate: false);
  set par(first-line-indent:0cm,
  hanging-indent: 0cm,
  leading: 1.5em,
  justify: true,
  linebreaks: "optimized",
  );
  set page(margin: (
    top: 2cm,
    right: 1.5cm,
    bottom: 2cm,
    left: 3cm,
  ),
    numbering: "1",
  );
  it
};
show outline.entry.where(level: 1): it => {
  it // strong
};


/*=== Оформление фигур и ссылок на них ===*/

set figure.caption(separator: [ -- ]);
set figure(supplement: [Рисунок]);

/* show figure.where(kind: image):it => {
  set figure(supplement: [Рисунок]);
  align(center)[#it]
};

show image: it =>{
  align(center)[#it]
} */

set image(width: 80%);

show figure.where(kind: image): it => {
  set par(first-line-indent: 0pt, hanging-indent: 0pt);
  block(width: 21cm, outset: (left: 2cm), below: 1.3em+10pt)[  

  // #h(-2.5cm)#h(1fr)#box(width: auto, fill:red, inset: 2pt)[#it.body]#h(1fr)
  
  #h(-2.25cm)#box()[#it.body]

  #h(-2.25cm)#box(height: auto, width: 16.5cm)[#it.caption]
]};

/*
h(-1.25cm)Таблица  
show figure.where(kind: table): it => block[
  #it.counter.display() --- #it.caption#h(1fr)

  #it.body
]; */
show figure.where(kind: table): set figure(supplement: [Таблица]);
show figure.where(kind: table): it => {  
  box(width: 100%)[
    #align(left)[
    #box(inset: (left: 0cm))[#it.caption ]
    ]
    #it.body
  ]
};



/* === Оформление ссылок ===*/

set ref(
  supplement: none
);


/*=== Оформление таблиц ===*/


show table: it => {
    set par(
    first-line-indent:0cm,
    hanging-indent: 0cm,
    leading: 1.3em,
    justify: true,
    linebreaks: "optimized",
  );
  set text(size: 12pt)
  it
};


/*=== Оформление формул ===*/


set math.equation( numbering: num => {
    "(" + str(counter(heading).get().at(0)) + "." + str(num) + ")"
  },
  supplement: none
);


/*=== Списки ===*/

// set enum(indent: -17pt, numbering: n =>[#h(17pt)#n]);
show enum.item: it => [#it.number. #it.body];
show list.item: it =>[-- #it.body];


/*=== Оформление кода===*/
show raw: it => {
  set text(size: 9pt)
  it
};

doc
}