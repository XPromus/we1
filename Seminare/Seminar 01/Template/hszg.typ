#import "colors.typ": *
#import "packages.typ": *

#let hszg-theme(
  course: "Kurs 1",
  course-number: "000000",
  lecturer: "Max Mustermann",
  title: "Seminar",
  date: datetime.today(),
  summary: [Zusammenfassung des Lernziels],
  doc
) = {
  set text(size: 11pt, fill: dark, lang: "de")
  
  set heading(numbering: none)
  show heading.where(level: 1): set text(secondary)
   show heading.where(level: 2): set text(secondary)

  set figure(gap: 15pt)

  set table(
    inset: 10pt,
    stroke: hszg-green,
    fill: (x, y) => {
      if y == 0 {
        return hszg-green
      } else {
        return background
      }
    }
  )

  show table.cell: it => {
    if it.y == 0 {
      set text(black)
      strong(it)
    } else {
      it
    }
  }

  show: codly-init.with()
  codly(languages: codly-languages)

  let marginX = 1cm
  set page(
    numbering: "1",
    margin: (top: 3cm, x: 1cm),
    header: context {
      move(dx: -marginX)[
        #rect(
          fill: hszg-green, 
          width: page.width, 
          height: 100%, 
          inset: (x: 25pt, y: 10pt)
        )[
          #grid(
            columns: (1fr, 1fr),
            grid.cell(align: left)[
              #image("Images/logo_full_white.svg")
            ], grid.cell(align: right + horizon)[
              #text(fill: light, weight: "bold")[#course - #course-number]
            ]
          )
          
        ]
      ]
    },
    footer: context [
      #line(length: 100%, stroke: dark.lighten(40%))
      #move(dy: -5pt)[
        #grid(
          columns: (1fr,  auto),
          [
            #text(fill: dark.lighten(40%))[
              Hochschule Zittau/Görlitz - #lecturer
            ]
          ], [
            #text(fill: dark.lighten(40%))[
              Seite #counter(page).display()
            ]
          ]
        )
      ]
    ]
  )

  [
    = #title #h(1fr) #text(fill: secondary, size: 13pt, weight: "regular")[#date.display("[day].[month].[year]")]
    #line(length: 100%)

    #box(stroke: hszg-green, inset: 10pt, fill: hszg-green.lighten(80%), width: 1fr)[
      *Lernziel*: #summary
    ]
  ]

  set heading(numbering: "1.")
  
  doc
}

#let task(name: str, content) = block(breakable: false)[
  = #name
  #content
]
