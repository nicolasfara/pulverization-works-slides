#import "@preview/polylux:0.3.1": *
#import "@preview/fontawesome:0.1.0": *

#import themes.metropolis: *

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  // footer: [Optional Footnote]
)

#set text(font: "Inter", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")
#set strong(delta: 150)
#set par(justify: true)

#set quote(block: true)
#show quote: set align(left)
#show quote: set pad(x: 5em)

#set raw(tab-size: 4)
#show raw.where(block: true): block.with(
  fill: luma(240),
  inset: 1em,
  radius: 0.7em,
  width: 100%,
)

// #set page(paper: "presentation-16-9")
// #show raw: set text(size: 10pt)
// #show math.equation: set text(font: "Fira Math")
// #show figure.caption: set text(size: 16pt)

// #set text(font: "Fira Sans", weight: "light", size: 21pt)
// #set strong(delta: 500)
// #set par(justify: true)

#title-slide(
  title: "Opportunistic Deployment and Runtime Execution in the Edge-Cloud Continuum",
  // subtitle: "Activities Summary",
  author: "Nicolas Farabegoli, PhD Student @ UNIBO",
  date: datetime.today().display("[day] [month repr:long] [year]"),
)

#new-section-slide("What is the Edge-Cloud Continuum?")

#slide(title: [Cloud Continuum: The Definition #cite(label("DBLP:journals/access/MoreschiniPLNHT22"))])[
  #quote(attribution: [Gupta et al. #cite(label("DBLP:journals/corr/GuptaNCG16"))])[
    "_A continuum of resources available from the network edge to the cloud/datacenter_"
  ]

  #quote(attribution: [Balouek-Thomert et al. #cite(label("DBLP:conf/sc/Balouek-Thomert21"))])[
    "_Aggregation of heterogeneous resources along the data path from Edge to the Cloud_"
  ]

  #align(center)[
    #pad(x: 1.5em)[
      #text(size: 24pt)[
        "*_Heterogeneous computational resources opportunistically exploitable from the Edge to the Cloud_*"
      ]
    ]
  ]
]

#slide(title: "Infrastructure heterogeneity problem")[
  _Macroprograms_ #cite(label("DBLP:journals/csur/Casadei23")) are typically deployed on mostly *homogeneous* infrastructures.

  *ECC* resources are _heterogeneous_ imposing different _*capabilities*_ and _*constraints*_.

  #pad(
    top: 0.7em,
    figure(
      image("figs/ecc.svg"),
    )
  )
]

#slide(title: "One size does not fit all")[
  It is not always possible to deploy the same _macroprogram_ on a *single device*.

  #h(0.2em)

  #figure(
    image("figs/from-macro-to-components.svg", width: 70%),
  )
]

#focus-slide("Which partitioning model?")

#slide(title: "Pulverization Partitioning")[
  #figure(
    image("figs/pulverization-model.svg"),
    // caption: "Logic device partitioned into five components and its links to neighbour devices."
  )
]

#slide(title: "Layers Mapping")[
  #figure(
    image("figs/system-abstraction-layer.svg")
  )
]

#slide(title: "PulvReAKt")[
  #align(center)[#fa-icon("github", fa-set: "Brands", size: 2em) *PulvReAKt*]
  #align(center)[_Pulverization with Reconfigurable Adaptation in Kotlin_]

  Features:
  - _DSL_ for system definition
  - _Runtime engine_ for _*dynamic components relocation*_
  - _Multiplatform_ support --- #fa-icon("java", fa-set: "Brands") #fa-icon("js", fa-set: "Brands") #fa-icon("android", fa-set: "Brands") #fa-icon("apple", fa-set: "Brands")
]

#slide(title: "Capabilities and Host Definition")[
  === Capability Definition

  ```kt
  object HighMemory by Capability
  object MqttBroker by Capability
  object WithTemperatureSensor by Capability
  ```

  === Host Definition

  ```kt
  val embeddedDevice = Host("raspberry", WithTemperatureSensor)
  val cloudServer = Host("AWS", HighMemory, MqttBroker)
  ```
]

#slide(title: "Pulverized System")[

  === System Definition

  ```kt
  class TemperatureCollector : Behavior { ... }
  class PeerToPeerComm : Communication { ... }
  class TemperatureSensor : Sensor { ... }

  val configuration = pulverized {
    val temperatureDevice by logicDevice {
      withBehavior<TemperatureCollector> requires HighCPU
      withCommunication<PeerToPeerComm> requires LowLatencyComm
      withSensors<TemperatureSensor> requires WithTemperatureSensor
    }
  }
  ```
]

#focus-slide("What about dynamic changing conditions?")

#slide(title: "Local Reconfiguration Rules")[
  === Rules Definition

  ```kt
  object HighLoad : ReconfigurationEvent<Double>() {
    override val reconfigureWhen = { it > 0.90 }
    override val events = cpuLoad()
  }

  object LowBattery : ReconfigurationEvent<Double>() {
    override val reconfigureWhen = { it < 0.20 }
    override val events = batteryLevel()
  }
  ```
]

#slide(title: "TODO")[
  ```kt
  val configuration = pulverized {
    val temperatureDevice by { ... } // as before
    deployment {
      device(temperatureDevice) {
        TemperatureCollector() startsOn embeddedDevice
        PeerToPeerComm() startsOn cloudServer
        TemperatureSensor() startsOn embeddedDevice
        HighLoad reconfigures { TemperatureCollector to embeddedDevice }
        LowBattery reconfigures { TemperatureCollector to cloudServer }
      }
    }
  }
  ```
]


#slide(title: "City Event Simulated Scenario")[
  #figure(
    image("figs/simulation-screenshot.png"),
    // caption: "A snapshot of the large-scale simulation."
  )

]

#slide(title: "Simulation Results")[
  #figure(
    image("figs/cloud_cost-device_consumption-cloud_consumption-distance-device=1000-1.svg"),
    // caption: "Simulation results with 1000 devices"
  )
]

#new-section-slide("AC for Reconfiguration")

#slide(title: "From Local to Global Reconfiguration Rules")[
  Local reconfiguration rules:
  - May lead to *oscillatory* conditions
  - Decisions based on *local* conditions

  Global _AC-based_ reconfiguration rules:
  - If properly designed, no *oscillatory* conditions
  - _Perturbations_ tolerated due to their *self-stabilizing* nature
  - Reconfigurations occur based on *global* conditions
]

#slide(title: "Middleware architecture")[
  #figure(
    image("figs/new-pulverization-architecture.svg"),
    // caption: "Middleware layers and the mapping between them in the architectural model"
  )
  // #figure(
  //   image("figs/middleware-example-ac.png"),
  //   caption: "Representation of a simple system composed of four logical devices."
  // )
]

// #slide(title: "AC for Dynamic Reconfiguration")[

//   We show how Aggregate Computing can provide a suitable programming model for implementing runtime reconfiguration rules for pulverised systems from a global stance.

//   We consider a system composed of _thin_ and _thick_ devices, where the former are able to offload their behaviour to the latter.

//   The objective is to dynamically relocate the behaviour adapting to changing CPU loads of the _thick host_.

//   A reconfiguration policy can be defined as a _function_ returning `Set[Component]` to be executed locally.
// ]

// #slide(title: "SCR approach")[
//   Reconfiguration approach based on SCR pattern #cite(<PIANINI202144>).

//   ```scala
//   def isThick: Boolean = ... // true if the device is thick
//   def offloadWeight: Int = ... // the offload weight
//   def cpuCost(): Int = if (isThick) /* cpu load */ else offloadWeight

//   def behavior = ... // the local behavior component
//   def main(): Set[Component] = {
//     val potential =
//       G(source = isThick, field = cpuCost(), acc = _ + _, metric = cpuCost)
//     val managed: Set[Behavior] = C(potential, _ ++ _, Set(behavior))
//     var load = cpuCost()
//     val runOnThick: Set[Behavior] =
//       if (isThick) managed.takeWhile { load += offloadWeight; load < 100 }
//       else Set()
//     val onLeader = G(isThick, runOnThick, identity(), cpuCost)
//     if (isThick) onLeader
//     else Set(behavior) -- onLeader ++ Set(Sensor, Actuator)
//   }
//   ```
// ]

#slide(title: "SCR-based Reconfiguration Rules")[
  _*Self-organising Coordination Regions*_ (SCR) pattern for reconfiguration.

  - Infrastructure division into *regions*
  - Regions coordinated by a *leader*
  - Leaders computation of *Region-based* components allocation
  - Propagation of the *actual configuration* to region devices

  #figure(
    image("figs/scr-pattern-reconfiguration.svg"),
  )
]

#slide(title: "SCR pattern - Variable Load")[
  #figure(
    stack(
      dir: ltr,
      spacing: 2em,
      image("figs/ac-reconfiguration-1-variable.png"),
      image("figs/ac-reconfiguration-2-variable.png"),
    )
  )
]

#slide(title: "SCR pattern - Node Failures")[
  #figure(
    stack(
      dir: ltr,
      spacing: 2em,
      image("figs/ac-reconfiguration-1-drop.png"),
      image("figs/ac-reconfiguration-2-drop.png"),
    )
  )
]

#slide(title: "SCR approach")[
  Reconfiguration approach based on SCR pattern:

  ```scala
  def isThick: Boolean = ... // true if the device is thick
  def offloadWeight: Int = ... // the offload weight
  def cpuCost(): Int = if (isThick) /* cpu load */ else offloadWeight

  def behavior = ... // the local behavior component
  def main(): Set[Component] = {
    val potential = G(isThick, cpuCost(), _ + _, cpuCost)
    val managed: Set[Behavior] = C(potential, _ ++ _, Set(behavior))
    var load = cpuCost()
    val runOnThick: Set[Behavior] = localDecision(load)
    val onLeader = G(isThick, runOnThick, identity(), cpuCost)
    if (isThick) onLeader
    else Set(behavior) -- onLeader ++ Set(Sensor, Actuator)
  }
  ```
]

// #slide(title: "Evaluation")[
//   We have exercised the proposed approach in two network topologies: _Lobster Network_ #cite(<Zhou2013>) and _Scale-free Network_ #cite(<Barabasi1999>).

//   For each topology we have considered different _device load_, and _device failure_.

//   In all the experiments we have measured the $"QoS" = frac(tau#sub("0"), tau)$ of the system where $tau$ is the _thin_ and _thick_ device that have successfully offloaded their behaviour. The set of device that have failed to offload their behaviour is $tau#sub[0] subset.eq tau$.

//   The baseline we compare with is a system where offloading is pre-defined: every thin host offloads its behaviour component to the nearest thick host.
// ]

#slide(title: "Results - Varaible Load")[
  #figure(
    image("figs/dynamic-load.svg"),
    // caption: "Comparison between the baseline and the proposed approach with variable load."
  )
]

#slide(title: "Results - Graceful Degradation")[
  #figure(
    image("figs/constant-load.svg"),
    // caption: "Comparison between the baseline and the proposed approach in a degradation condition."
  )
]

#new-section-slide("Work in Progress")

#slide(title: "Coordination of Multi-tier Field-based Applications")[
  #figure(
    image("figs/macro-system-definition.svg")
  )
]

#slide(title: "Deployment Mapping")[
  #figure(
    image("figs/deployment-mapping-diagram-img.svg")
  )
]

#slide[
  #bibliography("bibliography.bib")
]
