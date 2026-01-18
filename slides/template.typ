#import "@preview/polylux:0.4.0": *

#set text(tracking: -0.5pt)

#let bright = state("metropolis-bright", rgb("#eb811b"))
#let brighter = state("metropolis-brighter", rgb("#d6c6b7"))

#let slide-title-header = toolbox.next-heading(h => {
  //show: toolbox.full-width-block.with(fill: rgb("#639A00"), inset: 1em)
  show: toolbox.full-width-block.with(stroke: rgb("#639A00"), inset: 1em)
  set align(horizon)
  set text(fill: page.fill, size: 1.2em)
  strong(text(h,fill: rgb("#639A00")))
})

#let the-footer(content) = {
  set text(size: 0.8em)
  show: pad.with(.5em)
  set align(bottom)
  context text(fill: text.fill.lighten(40%), content)
  h(1fr)
  toolbox.slide-number
}

#let outline = toolbox.all-sections((sections, _current) => {
  enum(tight: false, ..sections)
})

#let progress-bar = toolbox.progress-ratio(ratio => {
  set grid.cell(inset: (y: .03em))
  grid(
    columns: (ratio * 100%, 1fr),
    grid.cell(fill: bright.get())[],
    grid.cell(fill: brighter.get())[],
  )
})

#let new-section(name) = slide({
  set page(header: none, footer: none)
  show: pad.with(20%)
  set text(size: 1.5em)
  name
  toolbox.register-section(name)
  progress-bar
})

#let focus(body) = context {
  set page(header: none, footer: none, fill: text.fill, margin: 2em)
  set text(fill: page.fill, size: 1.5em)
  set align(center)
  body
}

#let divider = context {
  line(length: 100%, stroke: .1em + bright.get())
}

#let setup(
  footer: none,
  text-font: "Fira Sans",
  math-font: "Fira Math",
  code-font: "Fira Code",
  text-size: 28pt,
  bright-color: rgb("#F28E00"),
  brighter-color: rgb("#d6c6b7"),
  fill-color: rgb("#84B818"),
  body,
) = {
  set page(
    paper: "presentation-16-9",
    fill: white.darken(2%),
    margin: (top: 3em, rest: 1em),
    footer: the-footer(footer),
    header: slide-title-header,
  )
  set text(
    font: "Fira Sans",
    size: text-size,
    fill: fill-color,
  )

  bright.update(bright-color)
  brighter.update(brighter-color)

  set strong(delta: 100)
  set align(horizon)
  show math.equation: set text(font: math-font)
  show heading.where(level: 1): _ => none

  body
}
