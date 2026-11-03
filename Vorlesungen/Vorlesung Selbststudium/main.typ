#import "Template/template.typ": *
#import "Template/hszg.typ": *

#let notes-position = if sys.inputs.at("notes", default: "none") == "bottom" {
  bottom
} else if sys.inputs.at("notes", default: "none") == "right" {
  right
} else {
  none
}

#show: hszg-theme.with(
  config-info(
    title: [Selbstudium],
    subsubtitle: [Vorlesung 11],
    course: [Web Engineering 1],
    coursenumber: [319300],
    author: [M.Sc. Christopher-Manuel Hilgner],
    date: datetime(day: 01, month: 01, year: 2027),
    institution: [Hochschule Zittau/Görlitz],
    contact: [christopher.hilgner\@stud.hszg.de]
  ),
  config-common(
    show-notes-on-second-screen: notes-position,
  ),
)

#show: frame-style(styles.boxy)

#show raw.where(block: false): it => box(
  fill: rgb("#ece2cd"),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
  it,
)

#set text(lang: "de")

#title-slide()
#include "Content/content.typ"
