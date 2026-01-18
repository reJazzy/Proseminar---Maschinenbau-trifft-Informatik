// Metropolyst Theme - Presentation Template
// A highly configurable Metropolis-style theme for Touying

#import "@preview/metropolyst:0.1.0": *

// Theme setup with default configuration
// See README.md for all available options
#show: metropolyst-theme.with(
  // Uncomment to customize:
  font: ("Inter",),
  // accent-color: rgb("#eb811b"),
  // header-background-color: rgb("#23373b"),
  config-info(
    title: [Hybride Lernstrategien für dateneffiziente Robotik],
    author: [Jesse Marekwica],
    date: datetime.today(),
    institution: [Proseminar: Infromatik trifft Maschinenbau],
    logo: emoji.robot,
  ),
)

#show figure.caption: set text(size: 0.6em, fill: gray)
#set figure(numbering: none)

// Title slide
#title-slide()

== Inhalt

- Vorstellung des Papers
- Markov-Decision-Process (MDP)
- Reinforcment Learning with Prior Data (RLPD)
- Fazit zum Paper

= Flexible und intelligente Montage

== Problem der modernen Montage
#slide()[
  - Autonome Montageprozesse sind weit verbeitet in der Industrie

  - Prozesse sind jedoch meist statisch und unflexibel

  - Roboter mit menschlichen Montagefähigkeiten sind eine Herausforderung
][
  #figure(
  image("fotos/KUKA_Production_2021_300_dpi_WEB-full.jpg"),
  caption: [
    Fertigungsstraße in der Automobilindustrie mit KUKA-Robotern 
    ]
  )
]

// Focus slide for emphasis
#focus-slide[
  Sind autonome und präzise Montagen möglich?
]

== Configuration options, and a long slide title with font size automatically scaled to fit on one line

These are the default styles for *bold*, #alert[alert], and #link("https://typst.app")[hyperlink] text.

View the #link("https://github.com/benzipperer/metropolyst")[documentation] for all configuration options.

=== Example

```typst
#show: metropolyst-theme.with(
  font: ("Roboto",),                       // Modern sans-serif
  font-size: 22pt,                         // Slightly larger text
  accent-color: rgb("#10b981"),            // Emerald accent
  hyperlink-color: rgb("#0ea5e9"),         // Sky blue links
  header-background-color: rgb("#0f172a"), // Slate dark header
)
#set strong(delta: 300)                    // Bolder bold text
```

#text(
  font: "Inter",
  size: 22pt,
)[These are the custom styles for #text(weight: "bold")[*bold*], #text(fill: rgb("#10b981"))[alert], and #link("https://typst.app")[#text(fill: rgb("#0ea5e9"))[hyperlink]] text.]