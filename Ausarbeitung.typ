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
Dies lässt sich am Beispiel der Automobilindustrie veranschaulichen, in der Firmen wie KUKA, bereits weit verbreitet mit ihren Automatisierungslösung sind.
Dort werden hochautomatisierte Produktionsketten als Lösung angeboten, die hauptsächlich auf _"Flexible Robotik"_ setzen, in denen Roboterarme Aufgaben wie Montage, Schweißen oder Lackierung übernehmen @noauthor_kr_nodate.
Laut einer Analyse der International Federation of Robotics (IFR) erreichte der weltweite operative Bestand an Industrierobotern zuletzt mit rund einer Million Einheiten einen neuen Höchststand (2023) @robotics_international_nodate.

Trotz der guten Etablierung weisen diese Lösungen dennoch Nachteile in Feinmotorik und kontaktreicher dynamischer Aufgaben auf. Die oben genannten Lösungen basieren meist auf statischen Regelwerken und gehen von
deterministischen Abläufen aus. Tauchen in der Produktionskette kleinere Fehler auf, müssen diese meist durch Eingriffe von Menschen behoben werden, da klassische Robotiksysteme keine "intelligente" Reaktion auf derartige Probleme geben.
Eine Lösung zur statischen Programmierung und festen Regelwerken, könnte die Informatik liefern. Die vorliegende Arbeit untersucht das Paper von Sichao Liu und Lihui Wang und liefert eine Lösung, die Konzepte aus der Informatik wie
Markov-Decision-Processes (MDP), Reinforcement Learning (RL) und neuronale Netze verwendet @liu_vision_2025. Alle genannten Konzepte sind in der Informatik moderne Technologien und erfordern tiefes Wissen aus der Informatik.

Das Paper postuliert eine mögliche Lösung eines Lernprozesses für Roboter, in der Präzisionsarbeit durch intelligente visuelle Verarbeitung von räumlicher Umgebung und "Human-in-the-Loop" Reinforcement Learning erzielt wird. Dabei werden
neuronale Netze, lernende Algorithmen und intelligente Impedanzcontroller verwendet. Demonstriert wird die Methode anhand der Montage von Computer-Hardware-Komponenten (konkret: RAM-Module und Kühlsystem auf einem Mainboard).
Die Montage solcher kontaktreicher Komponenten mit der Kombination von Schrauben, korrektes Einsetzen und Widerstandserkennung beim RAM, würde einen großen Implementierungsaufwand beim klassisch statischen Programmieren aufweisen.
Zusätzlich dazu wäre die Fehlerquote trotzdem hoch, da Abweichungen in Millimeterbereich bereits in Schäden an Bauteilen resultieren könnte (ein RAM-Riegel, der 1mm daneben liegt, wird nicht passen).
Trotz dieser Herausforderungen, erreichten die Autoren eine nahezu perfekte Erfolgsquote von über 98%.

Im Folgenden wird tiefer auf die Informatik des Papers eingegangen. Zuerst wird das eigentliche Problem als ein Markov Decision Process (MDP) modelliert. Dies ist nötig, da Reinforcement Learning Algorithmen auf solche MDP operieren.
Des weiteren wird dann noch die verteilte Architektur, das Actor-Learner-Modell kurz erklärt und übergeleitet zur Umsetzung des lernenden Algorithmus. Der im Paper vorgestellte RLPD (Reinforcement Learning with Prior Data) bietet eine
dateneffiziente Lösung an, die von Liu & Wang aufgegriffen und zum Teilen umgesetzt wird. Dabei wird die Umsetzung im Paper genauer beleuchtet und analysiert unter Bezugnahme des Papers von Ball et. al. @ball_efficient_nodate. 
Abgeschlossen wird die Ausarbeitung mit einer Diskussion und Evaluation der gesamten Umsetzung der Informatik-Ansätze und Kritikwürdigung.

= Systemarchitektur & Problemmodellierung

== Markov Decision Process (MDP)

Das Paper modelliert das Montageproblem als einen Markov-Decission-Process (MDP). Dabei handelt es sich um eine formale, mathematische Definition eines Entscheidungsproblems, welches hier zur Optimierung der Montage verwendet wird. 
Ein MDP lässt sich als gerichteter Graph modellieren, wobei die Knoten als Zustände und die Kanten als Zustandsübergänge (Transitionen) interpretiert werden, die durch Handlungen ausgelöst werden. 
Zum besseren Verständnis wird ein bekanntes Beispiel aus der Vorlesung von David Silver (DeepMind / UCL) betrachtet: Der beschriebene Graph [Abbildung 1] modelliert den Studienalltag @google_deepmind_rl_2015.

#figure(
  image("1_Pc0d35FGiksR31ySXoXv5A.png", width: 80%),
  caption: [
    Optimal Action-Value Function for Student MDP - David Silver @google_deepmind_rl_2015.
  ],
) <fig-mpd-graph>

Um seinen Kurs bestehen zu können, müssen Studenten alle drei "Class"-Zustände erfolgreich durchlaufen. Die Kreise repräsentieren hierbei die Zustände, wobei der Zustand "Class 1" hier als Start-Zustand dient. 
In diesem Zustand kann der Agent (Student) nun eine Handlung wählen, entweder "Facebook" oder "Study". Wählt er "Study", folgt eine Transition, die mit einer Wahrscheinlichkeit behaftet ist (in dem Fall implizit 1.0/100%). 
Der Reward (R) ist der Wert, den der Agent für das Ausführen einer Aktion erhält. In "Class 1" kostet jeder Zeitschritt beispielsweise $R = −2$ (negativer Reward / Bestrafung). 
Sobald sich der Agent in "Class 3" befindet, kann er sich für "Pub" entscheiden. Von da aus landet er mit unterschiedlichen Wahrscheinlichkeiten in "Class" 1-3 [@fig-mpd-graph]. Der Zustand "Sleep" ist ein terminierender Zustand, der das Ende markiert.

Das Ziel (die Optimierung) in einem MDP besteht darin, eine Strategie (Policy) zu finden, die die Summe der erwarteten Rewards maximiert.

Um dies auf das Paper zu übertragen, nutzen wir dessen formale Definition eines MDPs @liu_vision_2025: *$ M = {S, A, P, p, R, gamma} $*

- *$S$ (State Space)*: Beschreibt die Menge aller Zustände. In unserem Beispiel ist $S$ alle dargestellten Knoten, wobei $s in S$ ein konkreten Knoten beschreibt
- *$A$ (Action Space)*: Beschreibt die Menge aller verfügbarer Aktionen. Im Zustand "Class 1" wäre das "Facebook" oder "Study".
- *$P$ und $p$ (Wahrscheinlichkeiten)*: Das große $P$ beschreibt die *Startverteilung* (Initial State Distribution). Da es praktisch unendlich viele Startkonfigurationen geben kann, gibt $P$ an, wie wahrscheinlich es ist, in
  einem bestimmten Zustand $s_0$ zu starten. Im Beispiel wäre "Class 1" unser Start-Zustand mit $P(C l a s s 1) = 1.0$. Das kleine $p$ beschreibt die *Systemdynamik*. 
  Es gibt die Erfolgswahrscheinlichkeit einer gewählten Aktion an. Im Beispiel: Wenn man "Pub" in "Class 3" wählt, ist $p = 0.4$ für den Übergang zu "Class 2". Diese Defintion unterscheidet sich
  mit der von David Silvers Vorlesung. Um auf weiteres Vorgehen aufzubauen, wird sich an die Definition des Papers gehalten @liu_vision_2025.
- *$R$ (Reward Function)*: Bewertet die Qualität der Entscheidung. Im Beispiel erhält man $R=−2$ für "Study". Dieser Wert ist der entscheidene Parameter, an dem die Optimierung gemessen wird.
- *$gamma$ (Discount Factor)*: Dies ist der Gewichtungsfaktor $(0 ≤ γ < 1)$, der bestimmt, wie wichtig zukünftige Belohnungen im Vergleich zu sofortigen sind. Ein $γ$ nahe 0 beschreibt eine "kurzsichtige" Strategie (nur der nächste Reward zählt),     
  während ein $γ$ nahe 1 die Strategie "weitsichtig" macht (langfristige Ziele wie "Pass" werden wichtiger als kurzes Facebook-Vergnügen). 
  In der Vorlesung von David Silver wurden beide Beispiele einmal gezeigt, wobei das ($gamma = 0$)-Beispiel in einer Facebook-Schleife verfiel und ($gamma = 1$) in "Pass" überging.

Hat man nun ein MDP formuliert, gilt es dieses zu lösen, wobei die Lösung bei einem Optimierungs-/Maximierungsproblem der höchstmögliche erreichbare Wert beschreibt, in unserem Fall der Reward $R$. Die gängiste Vorgehensweise bei dem lösen von MDPs ist
das Aufstellen einer Strategie, einer sogenannten *Policy $(pi)$*. Nach einem bekannten Theorem gilt, dass es für jeden MDP eine optimale Policy $(pi)$ gibt, die besser oder gleich aller anderen Policies ist, also $pi_* >= pi, forall pi$ @google_deepmind_rl_2015. 
Auf unser Bespiel bezogen, wird eine Policy $(pi_*)$ gesucht, die den höchstmöglichen Wert für $ E [ sum_(t=0)^h gamma^t R(s_t, a_t) ] $ findet.
Da die Übergänge zwischen den Zuständen stochastisch und dementsprechend Unsicherheiten vorhanden sind, bilden wir den Erwartungswert aller möglichen Verläufe.
Das $gamma$ dient hier wie bereits angedeutet als Diskontierungsfaktor, der je nach Wahl über Zeitschritte $t$ die Gewichtung immer kleiner bis nahe 0 einfließen lässt.
Die Rewardfunktion mit $R(s_t, a_t)$ definiert für den derzeitigen Zustand $s_t$ unter der Handlung $a_t$ den Reward $R$. Dieser wird dann bis zum angegebenen Horizont $h$ akkumuliert. 

Für das Beispiel eines Studentenleben ist eine optimale Policy $(pi_*)$ einfach zu bestimmen. 
Mithilfe der *optimale Action-Value Function* $Q_*(s, a)$ können wir bestimmen, welchen maximalen akkumulierten Reward man erwarten kann, wenn man im Zustand $s$ die Aktion $a$ wählt und danach optimal weitermacht.
Ein Blick auf [@fig-mpd-graph] verdeutlicht dies am Zustand "Class 3":
- Der Wert für Lernen ist $Q_*("Class 3", "Study") = 10$.
- Der Wert für die Kneipe ist $Q_*("Class 3", "Pub") = 8.4$.
Da $10 > 8.4$ ist, ist die Handlung "Study" hier die optimale Wahl. Die Policy $(pi_*)$ wählt also stets gierig ("greedy") das Maximum über $Q_*$. Ein bekanntes Vorgehen für das bestimmen von $Q_*$ in allen Zuständen ist der Beginn am Ende und zurückschauen
in Vorgängerzuständen @google_deepmind_rl_2015. Nachdem vereinfacht ausgedrückten Bellmann'schen Optimalitätsprinzip gilt nämlich, dass jede Teilpolicy $pi_"sub"$ einer optimalen Policy $pi_*$, auch optimal ist @google_deepmind_rl_2015. 
Zur Veranschaulichung: Wenn die kürzeste ICE Strecke von Berlin nach München, über Leipzig ist, dann ist die kürzeste Strecke von Leipzig nach München, die gleiche. 
Aufgrund dieser Eigenschaft können wir das Problem beginnend vom Ende lösen, da die kürzeste Strecke von München nach München trivial und bekannt ist. 
Man beginnt in den terminierenden Zuständen (z.B. "Sleep" mit Wert 0) und berechnet die Werte der davorliegenden Zustände rekursiv rückwärts.
Dabei gilt für jeden Schritt: Der Wert eines Zustands ist der sofortige Reward plus der (bereits berechnete) maximale Wert des Nachfolgezustands. 
So propagieren sich die korrekten $Q_*$-Werte von hinten nach vorne durch den gesamten Graphen, bis für alle Zustände $s in S$ die optimale Entscheidung feststeht. Daraus leiten wir dann unsere optimale Policy $pi_*(a|s)$ ab, also mit welcher Wahrscheinlichkeit wir
Handlung $a$ in Zustand $s$ wählen.

== MDP zur Modellierung eines Montageproblems

Da nun eine gewisse Grundlage für Verständnis von MDPs geschaffen wurde, wird nun das einfache Beispiel von David Silver mit dem des Montageproblems im Paper verglichen @liu_vision_2025. 
Es existieren nämlich starke Unterschiede in der Bestimmung einer optimalen Policy $(pi_*)$.
Die Autoren modellieren ihr Montageproblem als ein Markov-Decision-Process (MDP) mit $M = {S, A, P, p, R, gamma}$. Während im Prinzip die Elemente des MDPs konzeptionell gleich bleiben, unterscheiden sie sich in der Umsetzung.

- *$S$ (State Space)*: Die Zustandsmenge wird in dem Paper definiert als *State Observation Space*, also der gesamte beobachtbare Bereich der Montage über die Kameras und Zustand des Armes. 
  Die Kameras nehmen Bilder auf, die über ein ResNet-10 (ein Convolutional Neuronal Network @gong_resnet10_2022) in Vektoren übersetzt werden. Dadruch wird die Dateneffizienz gesteigert, da 
  ResNet-10 die strukturellen Merkmale absthrahiert und deutlich komprimierter, ohne relevanten Informationsverlust aufbereitet.
- *$A$ (Action Space)*: Die Handlungsmöglichkeiten werden über die kartesische Koordinatenposition des Roboterarms und Griff-Zustand definiert.
- *$P$ und $p$ (Wahrscheinlichkeiten)*: Der Roboterarm wird kaum immer von der gleichen Stelle aus Anfangen, zu montieren, noch wird das Mainboard immer im exakten Millimeterbereich gleich liegen. Deshalb muss eine
  Wahrscheinlichkeitsverteilung $P(s)$ definiert werden, die unterschiedliche Start-Zustände modelliert. Zudem stellt $p$ nicht mehr einfache Wahrscheinlichkeiten an einer Transition dar, sondern die gesamte Dynamik des Systems wird durch $p$ repräsentiert. 
  Der Roboterarm wird egal wie präsize er ist, sich mit einer gewissen physikalischen Schwankung von der angegebenen Trajektorie abweichen. Aufgrund der physikalischen Komplexität, ist $p$ uns nicht bekannt, sondern wird durch Reinforcement Learning approximiert.
- *$R$ (Reward Function)*: Die Autoren haben für $R$ ein binäres Klassifizierungssystem gewählt, dass anhand von vorher tranierten Demos beurteilt, ob eine Montage erfolgreich, oder fehlgeschlagen ist.
- *$gamma$ (Discount Factor)*: Erfüllt den exakt selben Zweck wie in vorher aufgeführten Beispiel [@fig-mpd-graph].

Bei näherer Betrachtung der Komponenten $S$ und $p$ zeigen sich die zentralen Herausforderungen dieses Ansatzes: die *stochastische Systemdynamik* (Nicht-Determinismus) und die *enorme Dimensionalität* des Zustandsraums. 
// Letztere wird besonders bei den Sensordaten deutlich: Die beiden Handgelenkskameras (RealSense D405) liefern einen kontinuierlichen Strom an RGB-Bilddaten. 
// Bei einer Frequenz von 30 Hz und einem Crop von 128×128 Pixeln müssen pro Sekunde knapp 1 Million Bildpunkte verarbeitet werden. Unter der Annahme einer Standard-Farbtiefe (8-Bit pro Kanal) entspricht dies einem Datenvolumen von ca. 3 MB/s.
Anhand dieser Grundlage ist es nicht möglich, eine _"wahre"_ optimale Policy $(pi_*)$ zu finden, stadessen wird diese durch Reinforcement approximiert. 
Um sich aber einer optimalen Policy überhaupt annähren zu können, muss eine *parametrisierte Funktionsapproximation* erfolgen. 
Das Paper nutzt hierfür einen sogenannten *Soft-Actor-Critic-Ansatz (SAC)* mit signifikaten Designerweiterungen, der zum gewählten Reinforcement Learning with Prior Date (RLPD) führt. 
Dabei wird das komplexe Optimierungsproblem auf zwei neuronale Netze aufgeteilt, die gegenseitig voneinander lernen. Im folgendes wird der Kern, das Zusammenspiel und die formale Definition vom Actor und Critc (SAC) veranschaulicht @haarnoja_soft_2018. 

== Actor-Critic-Modell
Die analytische Lösung eines MDPs basiert @google_deepmind_rl_2015, auf der *Bellman-Gleichung*. Diese besagt, dass der Wert eines Zustands genau dem Erwartungswert aus dem Reward und dem Wert des Folgezustands entspricht:
$Q_*(s, a) = E [ R(s, a) + gamma max_(a') Q^*(s', a') ]$. Im klassischen Fall wird diese Gleichung iterativ gelöst, bis die Werte konvergieren. Für das Montageproblem im Paper ist dies aufgrund der hochdimensionalen Bilddaten und Systemdynamik nicht möglich.
Daher müssen wir die analytische Funktion $Q^*$ durch ein neuronales Netz $Q_phi$ approximieren. Ein künstliches neuronales Netz (KNN) ist ein Modell des maschinellen Lernens, das in seiner Funktionsweise grob dem menschlichen Gehirn nachempfunden ist.
Es dient dazu, Muster in Daten zu erkennen und Entscheidungen zu treffen. 
Der einfachhaltshalber nehmen wir folgendes an: Ein neuronales Netz $Q_phi$ lernt eine Funktion $f(X)$ durch Zuordnung eines Eingabevektors $X = (x_1, x_2, x_3, ...)$ um eine Reaktion $Y$ vorherzusagen. 
Dabei besteht ein Neuronales Netz aus unterschiedlichen Schichten, einem Input Layer für $X$, mehrschichtigen versteckten Layer, das hauptsächlich für das Lernen von $f(X)$ zuständig ist und einem Output Layer, indem $Y$ ausgegeben wird @noauthor_was_2021.

#figure(
  image("neural_network.jpg", width: 50%),
  caption: [
    Neuronales Netzt mit drei Layer Ebene - @yau_estimation_2024
  ],
)

Die Autoren des Papers nutzen zwei Neuronale Netzwerke, eines für den Actor und eines für den Critic. Im folgenden wird tiefer auf die einzelnen Netzwerke eingegangen und ihre Wechselwirkung aufeinander analysiert.

=== Critic

Der Critic bewertet eine derzeitige Einschätzung des Netzwerks und vergleicht diese mit der tatsächlichen Situation und Zukunft. Dafür wurde folgende Loss-Funktion $cal(L_Q)$ aufgestellt:

$ cal(L)_Q (phi) = E_(s,a,s') [ ( Q_phi (s, a) - (R (s, a) + gamma E_(a' ~ pi_theta) [Q_(overline(phi)) (s', a')]) )^2 ] $ <eq:critic>

Die Funktion $cal(L)_Q$ bestimmt die Fehlerquote der Parameter $phi$ im neuronalen Netzwerk $Q_phi$, indem es anhand einer Stichprobe (einem Batch aus dem Replay Buffer) den *mittleren quadratischen Fehler* (Mean Squared Error) zwischen zwei Werten berechnet.
Dafür nimmt es einmal den Wert der eigenen Vorhersage $Q_phi (s, a)$, also eine Einschätzung des Netzwerks über die Handlung $a$ in Zustand $s$ und zum anderen dem *Bellman-Zielwert* (Target), 
der sich zusammen aus dem tatsächlich erhaltenen Reward $R(s, a)$ und der diskontierten Prognose, also $gamma times Q_(overline(phi)) (s', a')$, des *Target-Networks* $Q_(overline(phi))$ für den Folgezustand ergibt. 
Wichtig zu beachten ist, dass es sich beim Target-Network um ein anderes Network handelt als $Q_phi$. Das liegt daran, dass eine sofortige Aktualisierung der Werte zum gleichzeitigen
Veränderung des Netzwerkes und Zieles führen würde. Deshalb wird eine Kopie $Q_overline(phi)$ erstellt, wodurch das Training stabilisiert wird. 
Dadurch wird verhindert, dass das Ziel ("Moving Target") während des Updates zu stark schwankt, indem die Parameter $overline(phi)$ nicht direkt optimiert werden, 
sondern den Hauptparametern $phi$ folgen und über einen gleitenden Durchschnitt (Soft Update) aktualisert werden @haarnoja_soft_2018.

Der Critic dient als Leiter für den Actor, der die tatsächlichen Bewegungen ausführt bzw. die Policy $(phi_theta)$ aktualisert, auf dem die Bewegungen basieren.

=== Actor

Der Actor steuert den Roboter, da er die tatsächliche Policy $(phi_theta)$ definiert, die das Montageproblem löst. Dafür wurde folgende Loss-Funktion $cal(L_pi)$ aufgestellt:

$ cal(L)_pi (theta) = -E_s [ E_(a ~ pi_theta (theta)) [Q_phi (s, a)] + tau Phi(pi_theta ( . | s)) ] $ <eq:actor>

Die Funktion $cal(L)_pi$ setzt sich aus zwei Zielen zusammen: Einmal Gierig (Exploitation) zu sein und andereseits Neugierig (Exploration). 
Das $(-)$ zu beginn der Funktion wandelt das Maximierungsproblem in ein Minimierungsproblem um, da Computer besser darin sind, Fehler zu minimieren.
Denn die Maximierung vom Reward, also dem Suchen eines globalen Optimus einer Funktion $f(x)$ ist für uns gleichbedeutend wie das Duchen des globalen Minimums $-f(x)$, nur einfacher für Computer umzusetzen.
Der Teil, der die Gier des Actors steuert, ist in diesem Teil enthalten: $E_(a ~ pi_theta (theta)) [Q_phi (s, a)]$. Das $a ~ pi_theta (theta)$ hat dabei eine relativ wichtige Bedeutung. 
Es ist mathematisch nicht möglich, Rückpropagierung (Backpropagation) in einem neuronalen Netz zu betreiben, wenn Stochastik zugrundeliegt. 
Denn aus einem Sample $a$ können keine Rückschlüsse zur Zufallsverteilung gezogen und plausible Anpassungen am Neuronalen Netz vorgenommen werden. 
Die Autoren bedienen sich hier dem Trick der *Reparametrisierung (Reparameterization)*, indem grob gesagt der Zufall in ein Standard-Rauschen $epsilon.alt$ ausgelagert wird, wodurch der stochatischen Sample, differenzierbar wird @kingma_auto-encoding_2022. 
Durch diesen Trick kann über dem Critic $Q_phi$, der Actor $Q_pi$ lernen, sich anzupassen. Der zweite Teil der Funktion $tau Phi(pi_theta ( . | s))$ ist zuständig für die Exploration. 
Damit wird vorgebeut, dass sich der Actor nicht zu früh in einer approximierten Lösung festsetzt, sondern nach anderen, eventuell besseren sucht. 
Der Hyperparameter $tau$ (Temperatur) steuert dabei die Balance: Ein hohes $tau$ fördert Exploration, während ein niedriges $tau$ die Policy stärker auf die Nutzung des besten bekannten Weges (Exploitation) fokussiert. 
Die Entropie $Phi$ gibt die Standardabweichung $sigma$ vor, also wie "Experimentierfreudig" der Actor ist. 
Diese Exploration wenden wir auf unseren Zustand $s$ an unter der Berücksichtigung aller möglichen Handlungen $a$ (hier gekennzeichnet durch $(.|s)$, innerhalb der Policy $(pi_theta)$).

Der Actor leitet den Roboter unter der Berücksichtigung des Critics und eigenem _"Neugierfaktor"_.  

= Effizientes Online Reinforcement Learning mit offline Daten - RLPD

Deep Reinforcement Learning (RL) konnte in vielen Feldern bereits Erfolge verzeichnen wie in Atari oder Go @tsividis_human_nodate @silver_mastering_2016.
In diesen Beispielen werden hohe Erfolge durch Reinforcement Learning und viele Online Interaktionen erzielt, dass durch Simulationen gut umsetzbar ist. 
Leider sind Probleme, wie das Montageproblem von Liu & Wang, in der Realität oft deutlich komplexer, als in einer Simulation @liu_vision_2025. Reward sind meist absthrahiert, während sie in der Realität schwer greifbar und hochdimensional sind. 
Die Autoren des Papers Ball et. al. postulieren den Ansatz von *RLPD* @ball_efficient_nodate. Dieser Unterscheidet sich von Deep RL und SAC + Offline Daten. 
Liu & Wang stützen sich stark mit ihrer Architektur auf den Ansatz aus dem Paper, wobei in RLPD drei erweiterte Designentscheidungen den Ansatz prägen. 
Im folgenden werden wir die Motivation hinter diesen Erweiterungen anschauen und deren Umsetzung von Liu & Wang.

== Hybrides Buffer-System und Replay Ratio

Beim klassischen Deep Reinforcement Learning kommt die Dauer des Lernprozesses vor allem aus der Anfangsphase, in denen der Algorithmus erst eine gewisse Richtung ermitteln muss, in der sich die optimale Policy befindet. 
Die Richtungfindung, kann aber minimiert werden, indem beim Deep RL im vorraus bereits suboptimale Policies oder menschliche Demonstrationen die Richtung vorgeben. Mit einher gehen jedoch Probleme mit diesen Demonstrationen. 
Während der RL-Algorithmus lernt, werden in kurzer Zeit bereits eine Vielzahl von Druchläufen in den Replay-Buffer, den Speicher, in dem alle Epochen gespeichert werden, geladen und überwiegen schnell die Anzahl an selbstgelandener Daten. 
Die Autoren Ball et. al. erkannten das ebenfalls und entwarfen basierend auf Ross & Bagnell (2012) eine symmetrische Replay-Buffer Architeuktur @ross_agnostic_2012. 
Dabei werden statt nur einem Replay-Buffer, zwei Buffer angelegt, wobei einer die Online Daten des RL-Algorithmus speichert und aufnimmt und einem Offline Buffer, der als Beispiel die eben genannten menschlichen Demonstrationen, speichert. 
Das hat vor allem den Vorteil, dass unter der schnell groß werdenen Menge an RL-Abläufen, die vorgefertigten Richtungsgeber nicht untergehen. 
Damit aber auch beim Samplen die Gewichtung erhalten bleibt, wird aus beiden Buffern die gleiche Menge an Daten entnommen, genau genommen jeweils 50%. 
Diese Designentscheidung erweist sich als besonders effektiv, wie in der Evaluation zu erkennen ist, auch wenn alleine nicht ausreichend @ball_efficient_nodate.

Dieses Vorgehen des symmetrischen Samples wird auch von Liu & Wang verwendet, wie zu erkennen in [@fig-arctor-critc-architecture] ist.

#figure(
  image("1-s2.0-S0007850625000642-gr3_lrg.jpg", width: 80%),
  caption: [
    Arctor-Learner Architektur mit zwei Buffern - @liu_vision_2025
  ],
) <fig-arctor-critc-architecture>

Näher wird auch erklärt, dass es sich um menschliche Demonstrationen handelt, die im vorraus erstellt wurden. Dabei wurden für jede Montageaufgabe (CPU-Kühlkörper, RAM, Lüfter) jeweils 30 erfolgreiche Trajektorien, also volle Bewegungsabläufe einer Montage, verwendet. 
Hierbei wird "Erfolgreich" druch zwei Kritierien definiert. Zum einen darf sich das zu montierende Objekt nicht mehr als $0.1"mm"$ der Zielposition entfernt befinden.
 Zum anderen, sollte Ersteres erfüllt sein, muss der vorher tranierte *Binary Classifier*, ebenfalls mit einer Wahrscheinlichkeit von min. 97% die Montage als "1", also erfolgreich bewerten. 
 Hier wurde sich dazu entschieden, hoch qualitative menschliche Abläufe als Offline Daten zu verwenden. 
 Die genaue Vor- und Nachteile varrieren stark nach zu optimierenden Problem. Unter der Grundlage jedoch, dass Liu & Wang das Modell in der Realität tranieren, ist dieses vorgehen wenn auch aufwendig, 
 durchaus sinnvoll und erfolgreich, wie der Evaluation der Versuchsabläufe zu entnehmen ist.

== Layer Normalization 

Eine fundamentale Schwäche von Deep Reinforcement Learning ist der Umgang mit unbekannten Daten, das sogenannte *Out-of-Distribution (OOD)* Problem. Bei Actor-Critic-Architekturen mit OOD Daten sind Diese meist nicht definiert während dem Lernprozess von RL. 
Dabei passiert es, dass der Critic die neuen eingehenden Daten stark "überschätzt", da dieser die Daten mit den Offline Daten aus dem Demo-Buffer in Beziehung bringt. 
Folge daraus in der Praxis sind Instabilitäten im Traning und *Divergierung des Critics (Overestimation)*, während er versucht den immer größer werdenen Werten zu folgen @thrun_issues_1994. 
Die Lösung von Ball et al. nutzt Normalisierung der Werte innerhalb des Neuronalen Netzes, damit Werte innerhalb eines Zahlenbereiches (meist mit einem Mittelwert $mu = 0$ und Standardabweichung $sigma = 1$) bleiben. 
Dabei ist es möglich, dass der RL-Ansatz mit Layer Normalization trotzdem neues lernen kann, ohne zu stark von den Demo Daten limitiert zu sein @ba_layer_2016. 
Mathematisch wurde das wie folgt bewiesen und umgesetzt: $norm(Q(s, a)) <= norm(w)$ @ball_efficient_nodate. 
Dies bedeutet, dass der vorhergesagte $Q$-Wert niemals größer werden kann als die Norm der Netzwerkgewichte $w$.


Die Umsetzung von Liu & Wang der Layer Normalization ist Anzunehmen, da ansonsten eine Umsetzung von RLPD nicht möglich wäre. Wie die Gleichung der $Q$-Loss Funktion zeigt, nutzen die Autoren die standardmäßige Soft-Bellman-Optimierung des SAC-Algorithmus:

$ cal(L)_Q (phi) = E_(s,a,s') [ ( Q_phi (s, a) - (R (s, a) + gamma E_(a' ~ pi_theta) [Q_(overline(phi)) (s', a')]) )^2 ] $ <eq:critic>

Diese Funktion minimiert lediglich die Differenz zwischen der Vorhersage $Q_phi$ und dem Zielwert $Q_pi$. Sie beinhaltet jedoch keinen Mechanismus, der das Netzwerk vor der erwähnten *Overestimation* bei unbekannten Daten schützt. 
Die Stabilisierung muss daher strukturell innerhalb der Funktion $Q_phi (s, a)$ selbst erfolgen. 
Während Ball et al. hierfür explizit *Layer Normalization* vor der letzten Ausgabeschicht vorschreiben ($norm(Q) <= norm(w)$), lassen Liu und Wang die genaue Innenarchitektur ihres Critics im Paper unerwähnt. 
Es ist möglich, dass die Autoren sich hier implizit auf die Beschaffenheit des *Reward Classifiers* verlassen, der den Reward hart auf das Intervall $[0, 1]$ begrenzt. 
Unter der Annahme, dass sie die RLPD-Methodik vollständig adaptiert haben, ist der Einsatz dieser Normalisierungsschichten zwingend erforderlich, da der Critic sonst bei der Verarbeitung der Daten aus den zwei Buffern zur Divergenz neigen würde. 

== Sample Efficient RL

Die Designentscheidung eines zweiten Offline Buffers führt dazu, dass Sampling aufwendiger wird. Zur Minimierung des Aufwands wird die Geschwindigkeit der Lernprozesses modifiziert, um Effizienz beizubehalten. 
Eine Möglichkeit dabei ist es den UTP-Wert zu erhöhen, den Wert der vorgibt, wie viele Lernschritte (Critic passt Gewichte an) pro Arbeitsschritt (Actor führt Handlung aus) durchführt werden. 
Jedoch läuft man damit Gefahr, dass der RL-Algorithmus in *Überanpassung (Overfitting)* verfällt. Die Überanpassung beschreibt einen Zustand, indem ein Modell sich zu stark an einem lokalen Optimum angepasst hat und irrelevante Faktoren berücksichtigt @noauthor_what_2021.
Zum besseren Verständnis wird als veranschaulichtes Beispiel oft der Unterschied zwischen "Verstehen" und "Auswendig lernen" aufgewiesen. 
Wenn ein RL-Algorithmus zu exakt gerlernt hat, eine Aufgabe zu lösen, sorgt der Zustand der Überanpassung dafür, dass die spezifisch gelernte Aufgabe mit einer hohen Genaugikeit gelöst wird, jedoch bei leichten Änderungen bereits scheitert. 
Als Lösung dafür nennen Ball et. at. einige Möglichkeiten, wobei sie sich für die Methoden mit *Random Ensemble Distillation* und *Random Shift Augmentations* entscheiden. 
Ersters beschreibt die Verwendung mehrer Critics, die in Wechselwirkung zueinander sich vor Divergenz schützen. Zweiteres wird genutzt, da Ball et. al. ebenfalls Bilder zum Traning verwendet. 
Dabei werden die Bilder um wenige Pixel zufällig verschoben, wodurch ein Art _"wackeln"_ imitiert wird. 
Das ist besonders nützlich, da so der RL-Algorithmus lernt den RAM-Sockel wirklich als RAM-Sockel zu erkennen und sich nicht statisch auf Pixelpositionen versteift (Overfitting).

Indizien für Overfittingprävention im Paper von Liu & Wang geht vor allem hervor bei der Extraktion von Daten aus Bildern. 
Sie nutzen dafür ein vortraniertes ResNet-10 Netzwerk zur Bilderkennung, dass bereits schon auf Millionen von Daten traniert wurde, wodurch davon auszugehen ist, dass dieses bereits gegen Overfitting besteht. 
ResNet-10 ist eine vereinfachte Version des bekannten ResNet, dass Bilder auf relevante Daten extrahiert, mit denen viele RL-Algorithmen arbeiten können @gong_resnet10_2022. 
Im Paper werden die Kamerabilder des Robters ins ResNet gesetzt, wodurch das Problem der geringen Datenmenge aus 1400 Bildern, vorgebeugt wird. 
Diese Daten werden dann in den Binary Classifier eingespeist, der dann Abläufe des Actors bewertet und mit in die Learner-Architektur liefert. Die Actor-Learner-Architektur ist gut aus @fig-arctor-learner-classifier zu entnehmen.

#figure(
  image("1-s2.0-S0007850625000642-gr1_lrg.jpg", width: 80%),
  caption: [
    Arctor-Learner Architektur und Binary/Reward Classifier - @liu_vision_2025
  ],
) <fig-arctor-learner-classifier>

Zusätzlich dazu wird *"Image Cropping"* verwendet, wodurch Bilder auf 128×128 in relevante Bereiche verkleinert werden. 
Jedoch geht keine direkte Nutzung von *Random Shift Augmentations*,  *Random Ensemble Distillation* oder anderer genannter Methoden aus dem Paper von Ball et. al. hervor, die als essenzielle Designentscheidung postuliert wurden, 
um RLPD umzusetzen und Overfitting vorzubeugen. Besonders die *Random Shift Augmentation* wäre eine robuste Verbesserung und würde die Statik, die in den Bildern von Liu & Wang gegeben ist, vorbeugen.

= Diskussion und Evaluation

Die im Paper präsentierte Ergebnisse und Methodik zur Lösung eines Montageproblems, indem Feinmotorik, Schrauben und präzise Kraftverhältnisse benötigt werden, wurden mit Technologien und modernen Ansätzen der Informatik beeindruckend angegangen. 
Die wissenschaftliche Grundlage der Problematik, die zuerst Formal mit einem MDP formuliert und anschließend per RLPD approximiert wurde, ist technisch anspruchsvoll und schneidet stark mit Transfergebieten wie Maschinenbau, Elektortechnik, Physik und der Informatik. 
Der als Kern gewählte RLPD Ansatz, wurde aus Gründen der Dateneffizienz und Lerngeschwindigkeit gewählt. 
Die Umsetzung des RLPDs wurde in der Ausarbeitung einmal anhand des genutzten Papers von Bell et. al. für RLPD grundlegend erklärt und anschließen mit der Umsetzung von Liu & Wang verglichen. 
Dabei spielt die Reproduzierbarkeit von Arbeiten eine wichtige Rolle in der Wissenschaft. Es fällt auf, dass Liu & Wang auf eine detaillierte Spezifikation ihrer Critic-Architektur verzichten und diese Designentscheidung unerwähnt lassen. 
Da der Standard-SAC-Algorithmus ohne diese Modifikation in einem hybriden Setting zu Instabilitäten neigt, bleibt unklar, durch welchen Mechanismus die Autoren die hohe Erfolgsquote des Modells sicherstellen. 
Diese Intransparenz erschwert nicht nur die Reproduktion der Ergebnisse, sondern lässt auch offen, ob der Erfolg auf einer robusten Architektur oder auf der Verwendung von Human-in-the-Loop (HIL) zurückzuführen ist. 

Die Verwendung von HIL in den Paper ist an vielen stellen sehr diskret und geht nicht in Tiefe darauf ein, wie diese menschlichen Eingriffe aussahen. 
In vielen Passagen werden die Eingriffe angesprochen und erwähnt, aber wie viele tatsächlich es sind und diese aussehen, wird offen gelassen, obwohl grade die Menge menschlicher Einwirkungen die Qualität der konstruierten RLPDs unterstreichen würden. 
Das die Lerngeschwindkeit deutlich erhöht wird, ist beim mehrfachen Eingreifen und korrigieren des Menschen selbstverständlich. 
Dementsprechend ist der Vergleich zwischen anderen RL-Ansätzen wie BC, SAC und DP unzureichend, wenn der RLPD + HIL verglichen wird. 
Eine Ausnahme scheint hier der HG-Dagger Vergleich zu sein. Beim HG-Dagger wurde die "gleiche Anzahl an Eingriffen wie RL" vorgenommen, wobei auch hier wieder die vage Äußerung von "Interventions" problematisch bei der Validierung des Lernprozesses ist. 

Zudem fehlt es an Variantion im Lernprozess und Test-Abläufen. Während des Lernprozesses werden identische Bauteile mehrmals unter gleicher Ausgangs- und Montageposition montiert. 
Bilder werden statisch ins System geladen, wodurch Overfitting eine Begründung für die hohen Erfolgsergebnisse sein könnte. 
In der Literatur zum visuellen Reinforcement Learning with Prior Data gilt Datenaugmentation als Standard, um zu verhindern, dass das neuronale Netz lediglich statische Pixel-Konstellationen auswendig lernt @ball_efficient_nodate. 
Da der Versuchsaufbau in einer kontrollierten Laborumgebung stattfand, besteht der begründete Verdacht, dass die Policy $pi_theta$ weniger eine intelligente Reaktionsfähigkeit auf Systemdynamiken erlernt hat, 
sondern vielmehr eine Überanpassung an die fixe Kameraperspektive und Beleuchtung angenommen hat.

Der Ansatz der Autoren stützt sich zudem auf einen Demo-Buffer, der mit 30 erfolgreichen, menschlichen Trajektorien gefüllt ist. 
Während dieses Vorgehen die Dateneffizienz des Lernprozesses zweifellos steigert, verschiebt es den Aufwand lediglich vom Training auf die Datenerhebung. 
Ein System, das auf hochpräzise menschliche Abläufe angewiesen ist, widerspricht teilweise dem Ziel der autonomen Robotik, die auch mit imperfekten Daten umgehen sollte. 
Verstärkt wird dieser Argument durch den "Human-in-the-Loop" (HIL) Ansatz, der ebenfalls während der Traningsphase, hohe menschliche Aufmerksamkeit und Expertenwissen fordert, wobei hier die Häufigkeit der Eingriffe deutlichen Aufschluss liefern würde. 

== Fazit

Die vorliegende Arbeit untersuchte die Anwendung von hybriden Lernstrategien im Kontext der Präzisionsmontage. 
Die Modellierung des Montageproblems als Markov Decision Process (MDP) und die Nutzung von RLPD zeigen das Potenzial auf, starre Regelwerke durch lernfähige Algorithmen zu ersetzen. 
Für zukünftige Arbeiten an der Schnittstelle von Informatik und Maschinenbau bleibt die Herausforderung bestehen, solche Systeme transparent zu postulieren um Rekonstruierbarkeit zu fördern.
Grundsätzlich ist die hohe Erfolgsquote der Arbeit von Liu & Wang in Bezug auf den HG-Dagger Lernprozess Vergleich eindeutig. Die darauffolgenden Testläufe sprechen ebenfalls für sich und liefern eindeutig die Erfolgreiche Umsetzung der Montage nach dem Lernen.
Jedoch ist es nicht eindeutig, ob diese Erfolgsquote wirklich durch den RLPD erreicht wurde, oder die Hohe Anzahl an HIL-Eingriffen zurückzuführen ist. Grund dafür ist die mangelnde Dokumentation der Eingriffe unter menschliches Wirken. 
Zudem geht hervor, dass der Impedanz-Controller ein fundamentaler Faktor bei der Erfolgsquote darstellt. Aufgrund des fehlenden Aufbereitung des Vergleiches beim Lernprozess zwischen anderen Algorithmen, wird nicht klar, ob diese auch den Impedanz-Controller nutzen.
Ohne einen Impedanz-Controller sind die Vergleiche nicht tragfähig, da ein deutlicher Vorteil gegenüber den _"rohen"_ Algorithmen vorliegt. Eine bessere Aufbereitung und Transparenz des Vergleiches wäre hier ausschlaggebend für die Validierung der Ergebnisse.

// ==========================================
// LITERATURVERZEICHNIS
// ==========================================
#pagebreak()
#bibliography("quellen2.bib") // Du brauchst eine Datei namens literatur.bib


// Wie bereits ausführlich erklärt, ist es nicht möglich einem Roboter, der derart feinmotorische und milimetergenaue Montageaufgaben bewältigen soll, statisch zu programmieren. Deshalb wurde im Paper Reinforcement Learning als Lösung genommen, in der ein Algorithmus selbständig lernt eine Strategie (Policy) zu entwickeln, die ihm vorgibt in einer Situation (Zustand) eine nahezu ideale Aktion vorzunehmen. Jedoch sind selbst klassische RL-Ansätze, wie auch der hier zugrundeliegende *SAC-Ansatz (Soft Actor Critc)* meist nicht ausreichend, um praxistauglich eingesetzt werden zu können. Grund dafür ist das das Erlernen einer Strategie oft Wochen von Laufzeit erfordert. Dateneffizienz ist bereits seit langer Zeit ein Problem beim Reinforcement Learning. Die Autoren bedienen sich dafür einer Erweiterung des SAC-Ansatzes, der sich rund um die Nutzung von Demonstrationen dreht. Der Algorithmus *RLPD (Reinforcement Learning with Prior Data)*, der in diesem Paper verwendet wurde, addressiert das Problem der Dateneffizienz, indem es bereits mit Vorkenntnissen der angepeilten Lösung arbeitet. Der größte Vorteil dabei ist, dass der RL-Algorithmus nicht von selbst die Richtung der Strategie erlernen muss, sondern bereits durch die Demos, in die Richtung der gewollten Strategie gedrückt wird. Die Struktur des Actor-Critic-Ansatzes wurde bereits ausführlich im MDP-Abschnitt behandelt. Im folgenden wollen wir uns mit den hier genutzten Besonderheiten des RLPD mit menschlichen Eingriffen beschäftigen. Zuerst wird  Dafür wird zuerst der allgemeine RLPD Ansatz aus einem Paper [Quelle] betrachtet, auf den sich auch die Autoren stützen. Aufbauend darauf wird die Umsetzung betrachtet, darunter fällt die Bereitstellung der Demos und wie diese in den RLPD eingebunden werden und anschließend auf die "Human-in-the-Loop" Umsetzung eingenagen.

// == Effizientes Reinforcement Learning mit offline Daten [Quelle]

// Aufbauend auf diesem theoretischen Gerüst implementieren Liu und Wang spezifische Komponenten, um den Algorithmus für die Montageaufgabe nutzbar zu machen. Dies umfasst eine visuelle Belohnungsfunktion und die Einbindung menschlicher Korrekturen.

// == Reward Classifier

// Der Reward oder *Binary Classifier* ist zuständig für die Bewertung von Montageabläufen, sowohl vor, als auch während dem RLPD. Der Classifier selbst ist ebenfalls ein Neuronales Netz, dass mit einer Wahrscheinlichkeit, eine binäre Zuweisung von Erfolg (1) und Misserfolg (0) bewertet. 

// Der Classifier selbst wird mit 100 erfolgreichen und 1300 fehlgeschlagen Datenpunkten traniert. Datenpunkte beschreibt hier die visuelle Übersetzung eines RGB-Bildes über ResNet-10 (Convolutional Neural Network) in räumliche Merkmale, in Form von Vektoren. Mit diesen Vektoren wird der Classifier über 100 Epochen und einem Adam Optimiser traniert, worauf hin dateneffizient und mit hoher Genaugikeit (nahe 100%), wie in [Abbildung 3.b] zu erkennen ist. 
// #figure(
//   image("1-s2.0-S0007850625000642-gr2_lrg.jpg", width: 80%),
//   caption: [
//     Arbeitsablauf der Bildverarbeitung und RL-Architektur
//   ],
// )
// Daraufhin wurde mithilfe des tranierten Classifiers, der offline Buffer mit menschlichen Demos geladen. Dafür wird der offline Buffer für jede Montageaufgabe (Kühlkörper, RAM und Lüftermontage) mit jeweils 30 Trajektorien, in denen menschlich manuell die Aufgabe erfüllt wurde, geladen. Dabei muss eine Trajektorie zwei Bedingungen erfüllen. Einmal wird eine harte Grenze für tatsächlichen Erfolg und Misserfolg bei einer Montage definiert. Sollte sich die Zielposition des Bauteils um $x > 0.1"mm"$ mit der tatsächlichen Position unterscheiden, gilt der Montageablauf als Fehler. Zudem muss der vorher tranierte Classifier bei erfolgreicher Montage (also $x <= 0.1"mm"$), den Montageablauf ebenfalls mit einer Wahrscheinlichkeit von über 97% als "1", also Erfolgreich auswerten. So werden nicht erkennbare Szenarien für den Classifier präventiert.