// Metropolyst Theme - Presentation Template
// A highly configurable Metropolis-style theme for Touying
#import "@preview/metropolyst:0.1.0": *
#show strong: set text(font: "Inter", weight: "bold")
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

= Motivation

== Problem der modernen Montage
#slide()[
  - Autonome Montageprozesse sind weit verbeitet in der Industrie

  - Prozesse sind jedoch meist statisch und unflexibel

  - Roboter mit menschlichen Montagefähigkeiten sind eine Herausforderung
][
  #figure(
  image("fotos/KUKA_Production_2021_300_dpi_WEB-full.jpg"),
  caption: [
    Fertigungsstraße in der Automobilindustrie - @noauthor_kr_nodate
    ]
  )
]

// Focus slide for emphasis
#focus-slide[
  Sind autonome, flexible und präzise Montagen möglich?
]

= Lösung des Papers

== Präzisionsmontage mit RL & Bilder

#slide()[
  #align(center)[
    #figure(
      image("/assets/1-s2.0-S0007850625000642-gr5_lrg.jpg", width: 70%),
      caption: [
        Montageaufbau (Montiert wird RAM, Kühlkörper und Lüfter) - @liu_vision_2025
      ]
    )
  ]
]

#slide()[
  #align(center)[
    #figure(
      image("/assets/1-s2.0-S0007850625000642-gr7_lrg.jpg", width: 100%),
      caption: [
        Montageablauf (Einsetzen und Ausrichten) - @liu_vision_2025
      ]
    )
  ]
]

#slide(composer: (1fr, auto, 1fr, auto, 1fr))[
  // Spalte 1: Inhalt
  
  #align(center + horizon)[*Datenerhebung*]

  - Menschliche Demos

  - Extraktion von Daten

  - Einbettung in System

  #image("/assets/{5ACD7CCA-29D6-431D-BBA0-684A514D3E8E}.png")
  #v(1fr)
][
  // Spalte 2: Die Linie
  // Wir machen sie grau und mittig
  #align(center + horizon)[
    #line(angle: 90deg, length: 80%, stroke: 1pt + gray)
  ]
][
  // Spalte 3: Inhalt
  #align(center + horizon)[*Reinforcement Learning*]

  - RLPD + HIL

  - Actor & Critic

  - Policy Optimierung

  #image("/assets/{40C84E70-F758-4A87-B8D3-928527F9E2E0}.png")

  #v(1fr)
][
  // Spalte 4: Die Linie
  #align(center + horizon)[
    #line(angle: 90deg, length: 80%, stroke: 1pt + gray)
  ]
][
  // Spalte 5: Inhalt
  #align(center + horizon)[*Impedanzcontroller*]

  - Nachgiebigkeit

  - $F = k dot e$

  - RL + Physik

  #align(center)[#image("/assets/{AE2EB6C5-9C71-4E24-AF1E-0C6ACB3153BD}.png", height: 6.3cm, width: 80%, fit: "stretch")]

  #v(1fr)
]

#focus-slide[
  Wie formulieren wir eine vage Problemstellung in etwas algorithmisch berechenbares?
]

= Markov-Decision-Process (MDP)

== Markov-Decision-Process

#slide()[
- Vage Probleme werden zu berechenbare Mathematik 

- $M = {S, A, P, R, gamma}$ 

  - $S$ - Zustand
  - $A$ - Entscheidung/Handlung
  - $P$ - Wahrscheinlichkeit
  - $R$ - Belohnung
  - $gamma$ - Diskontfaktor

- Ziel: Optimale Strategie $(pi)$ finden
][
  #align(center)[
    #figure(
      image("/assets/1_Pc0d35FGiksR31ySXoXv5A.png"),
      caption: [
        MDP als Graph eines Studentenlebens - @khandelwal_introduction_2022
      ]
    )
  ]
]

#slide()[
  #align(top)[$M = {S, A, P, R, gamma}$]

  - $S$ (State): 2x RGB-Bilder + Roboter-Gelenkdaten + Griffstärke

  - $A$ (Action): 6D-Pose (Position & Rotation) + Greifer-Status (Auf/Zu)

  - $P$ (Probability): Sensorrauschen + Reibung + Widerstand + Toleranz

  - $R$ (Reward): Neuronales Netz (Binary Classifier) + Menschliche Demos

  - $gamma$ (Discount): Verhindert Divergenz + Weitsichtigkeit

  #block(
    fill: rgb("#f0f0f0"), // Ein leichter grauer Kasten
    inset: 1em,
    radius: 5pt,
    width: 100%
  )[
    _Warum Reinforcement Learning für Policy $(pi)$?_ \

    Da die Kontaktphysik $(P)$ und Bilddaten $(S)$ zu komplex für Formeln sind, muss der Roboter die Lösung *erlernen*.
  ]
]

#focus-slide[
  Wie ist es möglich bei so hoher Datenkomplexität trotzdem Effizient bleiben?
]

= Reinforcement Learning with Prior Data (RLPD)

== RLPD
#slide()[
  #align(top)[#block(
    fill: rgb("#f0f0f0"), // Ein leichter grauer Kasten
    inset: 1em,
    radius: 5pt,
    width: 100%
  )[RLPD entspringt dem Ansatz von Soft-Actor-Critic (SAC) mit essenziellen Designerweiterungen.]

  1. Eine einfache und effiziente Methode zur Einbindung von Offline-Daten

  2. Normalisierung von Ebenen zur Milderung von Überschätzungen

  3. Effiziente Entnahme von Datenpunkten (Sample-Efficiency)
  ]

  #figure(
      image("/assets/{1C8502F8-55F7-44E6-8D8C-887914087B67}.png", width: 75.8%),
      caption: [
        Vergleich verschiedener Algorithmen gegen RLPD von Ball et al. - @ball_efficient_nodate
      ]
    )
]

== RLPD - Zwei Buffer System

#slide()[
  - Richtungsfindung zu Beginn bei RL sehr Zeit- und Rechenintensiv

  - Menschliche Demonstrationen oder suboptimale Policies können Richtung vorgeben (PD)

  - Offline und Online Daten trennen

    - Zwei Buffer + 50/50 Datenpunkte

  - Umsetzung im Paper: Vorhanden
][
  #figure(
      image("/Ausarbeitung/1-s2.0-S0007850625000642-gr3_lrg.jpg", width: 105%),
      caption: [
        Lui & Wang verwenden ebenfalls zwei Buffer - @liu_vision_2025
      ]
    )
]

== RLPD - Normalisierung

#slide()[
  - Out-of-Distribution (OOD) Daten bereiten RL-Algorithmen Probelme

  - OOD-Daten können vom Critic stark "überschätzt" werden $arrow$ Divergenz

  - Normalisierung in Ebenen von Neuronalen Netzen verhindert dies

  - $norm(Q(s, a)) <= norm(w)$ - Netzwerkgewichte limitieren $Q$-Wert

  - Umsetung im Paper: Implizit
][
  #figure(
      image("/assets/{D8495648-5795-43D2-9027-671E9F83F38A}.png"),
      caption: [
        Reward Classifier gibt 1 und 0 aus - @liu_vision_2025
      ]
    )
]

== RLPD - Effizientes Samplen

#slide()[
  - Nutzung von zwei Buffern erhöht deutlich Aufbereitung von Daten

  - Mögliche Gegenwirkungen 
    - Erhöhung der Lerngeschwindikeit

    - Qualitätsteigerung der Daten 

  - Gefahr: Überanpassung (Overfitting)

  - Präventionsmethoden nutzen

    - Random Shift Augmentations

    - Random Ensemble Distillation

  - Umsetzung im Paper: Unklar
][
  #align(center)[
    #figure(
      image("/assets/2-3-2-augmentation_7_1.png", width: 80%),
      caption: [
        Beispiel für Random Shift Augmentations - @thrun_issues_1994
      ]
    )

  #figure(
      image("/assets/unnamed.jpg", width: 80%),
      caption: [
        Beispiel für Image Cropping - Nano Banana Pro
      ]
    )
  ]
]

#focus-slide[
  Wenn Code zur Bewegung wird
]

= Fazit

== Ergebnisse

#slide()[
- Ergebnisse sind eindeutig

- Über 98% erfolgreiche Montage mit RLPD + HIL

- Verglichen wurde:
  - Behaviour cloning (BC)
  - Soft actor critic (SAC)
  - Diffusion policy (DP)
  - HG-Dagger

- Alle wurden mit 100 "human demonstrations" trainiert, bis auf HG und RLPD $arrow$ "same number of interventions"
][
  #align(center)[
    #figure(
      image("/assets/1-s2.0-S0007850625000642-gr6_lrg.jpg", width: 100%),
      caption: [
        Ergebnisse erfolgreicher Montage während Lernprozess - @liu_vision_2025
      ]
    )

  #figure(
      image("/assets/{2EE64C7D-C5FB-4178-9851-FAF5A96ACBC6}.png"),
      caption: [
        Benötigte Zeit und Ressorucen von RLPD zum Erlernen - @liu_vision_2025
      ]
    )
  ]
]

== Würdigung

#slide()[
  - Informatik wird in interdisziplinären Bereichen immer relevanter

  - "Über der Computerwelt heraus Dinge bewegen" 

  - Paper ist ein wunderbares Beispiel für Relevanz von Infromatik in Robotik

  - Andere Bereiche benötigen ebenfalls qualifizierte Informatiker
][
  #align(center)[
    #figure(
      image("/assets/image1-4.png", width: 70%),
      caption: [
        AlphaFold entschlüsselte 200 Millionen Proteine - @cheng_accurate_2023
      ]
    )

  #figure(
      image("/assets/1856x1040.jpg", width: 70%),
      caption: [
        DeepMind steuert Tokamak zur Plasmaerzeugung - @noauthor_deepmind_2022
      ]
    )
  ]
]

== Kritik

#slide()[
  - Erschwerte Validierung und Reproduzierbarkeit durch Informationslücken
    - _Wann und wie wurde "Human-in-the-Loop" umgesetzt?_
    - _Wie wurde "Layer Normalization" umgesetzt?_
    - _Wie wurde "Overfitting" präventiert?_
    - _Wie genau wurden die Algorithmen verglichen (Unterschiede)?_

  #block(
    fill: rgb("#f0f0f0"), // Ein leichter grauer Kasten
    inset: 1em,
    radius: 5pt,
    width: 100%
  )[
    [...] used to compare the training performance over these tasks and perform ablation studies with the same number of human demonstrations but different interventions. Specifically, BC, SAC and DP are trained with 100 human demonstrations, while HG-Dagger has the same number of interventions as RL @liu_vision_2025.
  ]
]

// These are the default styles for *bold*, #alert[alert], and #link("https://typst.app")[hyperlink] text.

// View the #link("https://github.com/benzipperer/metropolyst")[documentation] for all configuration options.

// === Example

// ```typst
// #show: metropolyst-theme.with(
//   font: ("Roboto",),                       // Modern sans-serif
//   font-size: 22pt,                         // Slightly larger text
//   accent-color: rgb("#10b981"),            // Emerald accent
//   hyperlink-color: rgb("#0ea5e9"),         // Sky blue links
//   header-background-color: rgb("#0f172a"), // Slate dark header
// )
// #set strong(delta: 300)                    // Bolder bold text
// ```

// #text(
//   font: "Inter",
//   size: 22pt,
// )[These are the custom styles for #text(weight: "bold")[*bold*], #text(fill: rgb("#10b981"))[alert], and #link("https://typst.app")[#text(fill: rgb("#0ea5e9"))[hyperlink]] text.]
// 

#bibliography("quellen4.bib")