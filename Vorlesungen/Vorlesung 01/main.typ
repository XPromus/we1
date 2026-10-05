#import "Template/template.typ": *
#import "Template/hszg.typ": *

#show: hszg-theme.with(
  config-info(
    title: [Wie das Web funktioniert],
    subsubtitle: [Vorlesung 01],
    course: [Web Engineering 1],
    coursenumber: [319300],
    author: [M.Sc. Christopher-Manuel Hilgner],
    date: datetime(day: 6, month: 10, year: 2026),
    institution: [Hochschule Zittau/Görlitz],
    contact: [christopher.hilgner\@stud.hszg.de]
  )
)

#show: frame-style(styles.boxy)

#set text(lang: "de")

#title-slide()
#include "Content/content.typ"
