#import "colors.typ": *

#let textbox(content) = rect(
  width: 100%,
  stroke: hszg-green + 2pt,
  fill: hszg-green.lighten(80%),
  inset: 15pt,
)[#content]
