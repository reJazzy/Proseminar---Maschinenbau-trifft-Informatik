#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  numbering: "1",
)
#set text(
  font: "Times New Roman", // Der klassische "Wissenschafts-Look"
  size: 11pt,
  lang: "de",
)
#set heading(numbering: "1.1.")
#set par(justify: true)

// Titelblatt-Simulation
#align(center)[
  #text(size: 17pt, weight: "bold")[
    Hybride Lernstrategien für dateneffiziente Robotik
  ]
  #v(1em)
  #text(size: 12pt)[
    Ausarbeitung zum Proseminar "Informatik trifft Maschinenbau"
  ]
  #v(1em)
  #text(size: 12pt)[
    Zugeteiltes Paper:

    Vision intelligence-conditioned reinforcement learning for precision assembly
  ]
  #v(2em)
  Jesse Marekwica \
  Matrikelnummer: 238530 \
  #datetime.today().display()
]

#v(2cm)
#outline(title: "Inhaltsverzeichnis")
#pagebreak()

// ==========================================
// Hier geht der Text los
// ==========================================

= Einleitung & Motivation
Roboter in der Industrie, insbesondere der Fertigungstechnik, sind für Unternehmen essenziell geworden und reduzieren hohe Kosten durch Fachkräfte, erhöhen die Zeiteffizienz und sind in Zeiten der Industrie 4.0 weit etabliert.
Dies lässt sich am Beispiel der Automobilindustrie veranschaulichen, in der Firmen wie KUKA bereits weit verbreitet mit ihren Automatisierungslösung sind.
Dort werden hochautomatisierte Produktionsketten als Lösung angeboten, die hauptsächlich auf Flexible Robotik setzen, in denen Roboterarme Aufgaben wie Montage, Schweißen oder Lackierung übernehmen [Quelle].
Laut einer Analyse der International Federation of Robotics (IFR) erreichte der weltweite operative Bestand an Industrierobotern zuletzt mit rund einer Million Einheiten einen neuen Höchststand (2023) @robotics_international_nodate.

Trotz der guten Etablierung weisen diese Lösungen dennoch Nachteile bezüglich Feinmotorik, kontaktreicher und dynamischer Aufgaben auf. Die oben genannten Lösungen basieren meist auf statischen Regelwerken und gehen von
deterministischen Abläufen aus. Tauchen in der Produktionskette kleinere Fehler auf, müssen diese meist durch Eingriffe von Menschen behoben werden, da klassische Robotiksysteme keine "intelligente" Reaktion auf derartige Probleme geben.
Eine Lösung zur statischen Programmierung und festen Regelwerken, könnte die Informatik liefern. Die vorliegende Arbeit untersucht das [Quelle] liefert eine Lösung, die Konzepte aus der Informatik wie
Markowsche-Entscheidungsprobleme, Reinforcement Learning und neuronale Netze verwendet. Alle genannten Konzepte sind in der Informatik moderne Technologien und erfordern tiefes Wissen aus der Informatik.

Das Paper postuliert eine mögliche Lösung von Robotern, in der Präzisionsarbeit durch intelligente visuelle Verarbeitung von räumlicher Umgebung und "Human-in-the-Loop" Reinforcement Learning erzielt wird. Dabei werden
neuronale Netze, lernende Algorithmen und intelligente Impedanzcontroller verwendet, die gewisse Informatikkenntnisse voraussetzen. Demonstriert wird die Methode anhand der Montage von Computer-Hardware-Komponenten (konkret: RAM-Module und Kühlsystem auf einem Mainboard).
Die Montage solcher kontaktreichen Komponenten mit der Kombination von Schrauben, korrektes Einsetzen und Widerstandserkennung beim RAM, würde einen großen Implementierungsaufwand beim klassisch statischen Programmieren aufweisen.
Zusätzlich dazu wäre die Fehlerquote wahrscheinlich trotzdem hoch, da Abweichungen in Millimeterbereich bereits schwerwiegend sein könnten (ein RAM-Riegel, der 1mm daneben liegt, wird nicht passen).
Trotz dieser Herausforderungen, erreichten die Autoren eine nahezu perfekte Erfolgsquote von über 98%.

Im Folgenden wird tiefer auf die Informatik des Papers eingegangen. Zuerst wird das eigentliche Problem als ein Markov Decision Process (MDP) modelliert. Dies ist nötig, da Reinforcement Learning Algorithmen auf solche MDP operieren.
Des weiteren wird dann noch die verteilte Architektur, das Actor-Learner-Modell kurz erklärt und übergeleitet zur Umsetzung des lernenden Algorithmus. Der im Paper vorgestellte RLPD (Reinforcement Learning with Prior Data) bietet eine
dateneffiziente Lösung an, die menschliches Eingreifen ermöglicht und einen Vision-Encoder verwendet, der auf ResNet-10, ein Convolutional Neural Network (CNN) basiert. Aufbauend wird noch kurz die Impedanzregelung vorgestellt. Abgeschlossen wird die Ausarbeitung mit einem Vergleich zu anderen Lösungen, kurzer Einschätzung und Folgerung für den Maschinenbau.

= Systemarchitektur & Problemmodellierung

== Markov Decision Process (MDP)
Das Paper modelliert das Montageproblem als einen Markov-Decission-Process (MDP). Dabei handelt es sich um eine formale, mathematische Definition eines Entscheidungsproblems, welches hier zur Optimierung der Montage verwendet wird. 
Ein MDP lässt sich als gerichteter Graph modellieren, wobei die Knoten als Zustände und die Kanten als Zustandsübergänge (Transitionen) interpretiert werden, die durch Handlungen ausgelöst werden. Zum besseren Verständnis wird ein bekanntes Beispiel aus der Vorlesung von David Silver (DeepMind / UCL) betrachtet: Der beschriebene Graph [Abbildung 1] modelliert den Studienalltag.

#figure(
  image("student_mdp.png", width: 80%),
  caption: [
    Optimal Action-Value Function for Student MDP - David Silver.
  ],
)

Um seinen Kurs bestehen zu können, müssen Studenten alle drei "Class"-Zustände erfolgreich durchlaufen. Die Kreise repräsentieren hierbei die Zustände. "Class 1" dient hier als Start-Zustand. 
In diesem Zustand kann der Agent (Student) nun eine Handlung wählen: Entweder "Facebook" oder "Study". Wählt er "Study", folgt eine Transition, die mit einer Wahrscheinlichkeit behaftet ist (in dem Fall implizit 1.0/100%). 
Der Reward (R) ist der Wert, den der Agent für das Verweilen in einem Zustand oder das Ausführen einer Aktion erhält. In "Class 1" kostet jeder Zeitschritt beispielsweise $R = −2$ (negativer Reward / Bestrafung). 
Sobald sich der Agent in "Class 3" befindet, kann er sich für "Pub" entscheiden. Von da aus landet er mit unterschiedlichen Wahrscheinlichkeiten in "Class" 1-3 (siehe Graph). "Sleep" ist ein terminierender Zustand, der das Ende markiert.

Das Ziel (die Optimierung) in einem MDP besteht darin, eine Strategie (Policy) zu finden, die die Summe der erwarteten Rewards maximiert.

Um dies auf das Paper zu übertragen, nutzen wir dessen formale Definition eines MDPs: *$ M = {S, A, P, p, R, gamma} $*

- *$S$ (State Space)*: Beschreibt die Menge aller Zustände. In unserem Beispiel ist $S$ alle dargestellten Knoten, wobei $s in S$ ein konkreten Knoten beschreibt
- *$A$ (Action Space)*: Beschreibt die Menge aller verfügbarer Aktionen. Im Zustand "Class 1" wäre das "Facebook" oder "Study".
- *$P$ und $p$ (Wahrscheinlichkeiten)*: Das große $P$ beschreibt die *Startverteilung* (Initial State Distribution). Da es praktisch unendlich viele Startkonfigurationen geben kann, gibt $P$ an, wie wahrscheinlich es ist, in
  einem bestimmten Zustand $s_0$ zu starten. Im Beispiel wäre "Class 1" unser Start-Zustand mit $P(C l a s s 1) = 1.0$. Das kleine $p$ beschreibt *Systemdynamik* (Transition Probabilities). 
  Es gibt die Erfolgswahrscheinlichkeit einer gewählten Aktion an. Im Beispiel: Wenn man "Pub" in "Class 3" wählt, ist $p = 0.4$ für den Übergang zu "Class 2" oder in "Class 1" für "Facebook" $p = 1.0$. Diese Defintion unterscheidet sich
  mit der von David Silvers Vorlesung. Um auf weiteres Vorgehen aufzubauen, wird sich an die Definition des Papers gehalten.
- *$R$ (Reward Function)*: Bewertet die Qualität der Entscheidung. Im Beispiel erhält man $R=−2$ für "Study". Dieser Wert ist der entscheidene Parameter, an dem die Optimierung gemessen wird.
- *$gamma$ (Discount Factor)*: Dies ist der Gewichtungsfaktor $(0 ≤ γ < 1)$, der bestimmt, wie wichtig zukünftige Belohnungen im Vergleich zu sofortigen sind. Ein $γ$ nahe 0 macht den Agenten "kurzsichtig" (nur der nächste Reward zählt),     
  während ein $γ$ nahe 1 den Agenten "weitsichtig" macht (langfristige Ziele wie "Pass" werden wichtiger als kurzes Facebook-Vergnügen). Im der Vorlesung von David Silver wurden beide Beispiele einmal gezeigt, wobei ein $gamma = 0$ in einer Facebook-Schleife verfiel und ein $gamma = 1$ in "Pass" überging.

Hat man nun ein MDP formuliert, gilt es dieses zu lösen, wobei die Lösung bei einem Optimierungs-/Maximierungsproblem der höchstmögliche erreichbare Wert beschreibt, in unserem Fall der Reward $R$. Die gängiste Vorgehensweise bei dem lösen von MDP ist
das Aufstellen einer Strategie, einer sogenannten *Policy $(pi)$*. Eine Policy $(pi)$ hat den Vorteil, an jeder Stelle des Graphen ein klares Regelwerk zu besitzen, während "feste Routen" viele Nachteile aufweisen (Graph zu groß/unendlich, mehrere Startpunkte = mehrere Routen). Genau genommen wird eine optimale Policy $(pi)$ gesucht.
Auf unser Bespiel bezogen, wird versucht eine Policy $(pi)$ gesucht, die den höchstmöglichen Wert in $ E [ sum_(t=0)^h gamma^t R(s_t, a_t) ] $ findet.
Da die Übergänge zwischen den Zuständen stochastisch und dementsprechend Unsicherheiten vorhanden sind, bilden wir den Erwartungswert aller möglichen Verläufe.
Das $gamma$ dient hier wie bereits angedeutet als Diskontierungsfaktor, der je nach Wahl über Zeitschritte $t$ die Gewichtung immer kleiner bis nahe 0 einfließen lässt.
Die Rewardfunktion mit $R(s_t, a_t)$ definiert für den derzeitigen Zustand $s_t$ unter der Handlung $a_t$ den Reward $R$. Dieser wird dann bis zum Angegebenen Horizont $h$ akkumuliert. 

Für das Beispiel eines Studentenleben ist eine optimale Policy $(pi)$ einfach zu bestimmen. Mithilfe vom Bellman'sche Optimalitätsprinzip kann mit Backtracking ein eindeutiger optimaler Pfad bestimmt werden. Das Prinzip besagt, dass sich bei einigen Optimierungsproblemen jede Optimallösung aus optimalen Teillösungen zusammensetzt [Quelle]. Daraus folgt, dass der optimale Pfad das strikte lernen von "Class 1" bis "Pass". 

== Actor-Learner-Modell
Kurze Erklärung des Modells: Der Actor interagiert mit der Welt, der Learner optimiert das Netz im Hintergrund. Effizienz und Stabilität.

= Der Lernalgorithmus: RL mit "Human-in-the-Loop"
- RL -> RLPD
- Wie mischt der Algorithmus zwei Datenquellen (Prior Data/Offline Daten/Demos und Eigene Erfahrung/Online Daten)

== Mensch als Korrektiv

== Vision-Encoder
Kurz auf ResNet-10 eingehen und das ein CNN zugrunde liegt. Verwandelt Pixel der Kamera in kompakte Vektoren, die das RL Netz verwerten kann.

= Schnittstelle zur Physik: Impedanzregelung
Neuronales Netz steuert Roboter nicht hart, sondern gibt Ziele vor. Ein Impedance Controller beobachtet und gleicht Position und Kraft ab, damit nichts kaputt geht.
Dient als Sicherheitslayer.

Besonders wichtig ist die *Impedance Control*, die den Roboter "weich" macht. Die Formel für die Kraft $F$ ist:

$ F = k_p (p_c - p_t) + k_d (v_c - v_t) $

Dabei ist $k_p$ die Federsteifigkeit (Stiffness).

= Evaluation
Ehrlich gesagt kauf ich das Paper nicht ganz ab. Aber mal schauen.

// ==========================================
// LITERATURVERZEICHNIS
// ==========================================
#pagebreak()
#bibliography("Proseminar.bib") // Du brauchst eine Datei namens literatur.bib