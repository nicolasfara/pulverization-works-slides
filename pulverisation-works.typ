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
#set raw(syntaxes: "Kotlin.sublime-syntax")
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


#slide(title: "Middleware Architecture")[
  #figure(
    image("figs/new-pulverization-architecture.svg"),
    // caption: "Middleware layers and the mapping between them in the architectural model"
  )
  // #figure(
  //   image("figs/middleware-example-ac.png"),
  //   caption: "Representation of a simple system composed of four logical devices."
  // )
]

#slide(title: "Capabilities and Host Definition")[
  === Capability Definition

  ```kt
  object MqttBroker by Capability
  object WithTemperatureSensor by Capability
  ```

  === Host Definition

  ```kt
  val embeddedDevice = Host("raspberry", WithTemperatureSensor)
  val cloudServer = Host("AWS", MqttBroker)
  ```
]

#slide(title: "Mapping Components Over Device Types")[

  === System Definition

  ```kotlin
  class TemperatureCollector : Behavior { ... }
  class PeerToPeerComm : Communication { ... }
  class TemperatureSensor : Sensor { ... }

  val configuration = pulverized {
    val temperatureDevice by logicDevice {
      withBehavior<TemperatureCollector>
      withCommunication<PeerToPeerComm> requires MqttBroker
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

#slide(title: "Initial Configuration and Reconfiguration Rules")[
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
  #align(center)[
    #alert[
      Can we _tradeoff_ between *cloud costs* and *device consumption* via relocation?
    ]
  ]

  #figure(
    image("figs/simulation-screenshot.png", width: 55%),
    // caption: "A snapshot of the large-scale simulation."
  )
]

#slide(title: "Simulation Results")[
  #figure(
    image("figs/cloud_cost-device_consumption-cloud_consumption-distance-device=1000-1.svg"),
    // caption: "Simulation results with 1000 devices"
  )
]

#slide(title: "Oscillatory Conditions")[
  #table(
    columns: (1fr, auto),
    align: horizon,
    stroke: none,
    inset: 1em,
    [
      #alert[
        What happens when the server is *overloaded* and a device is running *out of battery*?
      ]

      #uncover("2")[
        The _behavior_ component starts to be *continuously* relocated between the `EmbeddedDevice` and the `CloudServer`.
      ]
    ],
    [
      #figure(
        image("figs/s-unstable.gif")
      )
    ]
  )
]

#new-section-slide("Global Reconfiguration Rules")

#slide(title: "From Local to Global Reconfiguration Rules")[
  Local reconfiguration rules:
  - May lead to *oscillatory* conditions
  - Decisions based on *local* conditions

  Global _AC-based_ reconfiguration rules:
  - If properly designed, no *oscillatory* conditions
  - _Perturbations_ tolerated due to their *self-stabilizing* nature
  - Reconfigurations occur based on *global* conditions
]

#slide(title: "Self-Integration")[
  Global reconfiguration rules via *Self-integration* #cite(label("DBLP:journals/fgcs/BellmanDT21")) by using the _Self-organising Coordination Regions_ pattern #cite(label("PIANINI202144")):

  - Structure interacting heterogeneous resources into groups (regions)
  - Each region solves _cooperatively_ a specific problem (e.g., load balancing)
  - We ensure continuous and context-sensitive adaptation of the system

  #figure(
    image("figs/scr-pattern-reconfiguration.svg"),
  )
]

#slide(title: "Global Reconfiguration Rule: Variable Load")[
  #table(
    columns: (1fr, 1fr),
    inset: 0.5em,
    stroke: none,
    [
      #figure(
        image("figs/dynamic-load-vertical.svg"),
      )
    ],
    [
      #stack(dir: ttb)[
        #figure(image("figs/barabasi-albert.png", width: 40%))
        #figure(image("figs/lobster.png", width: 40%))
      ]
    ]
  )
]

#slide(title: "Global Reconfiguration Rule: Graceful Degradation")[
  #table(
    columns: (1fr, 1fr),
    inset: 0.5em,
    stroke: none,
    [
      #figure(
        image("figs/constant-load-vertical.svg"),
      )
    ],
    [
      #stack(dir: ttb)[
        #figure(image("figs/barabasi-albert.png", width: 40%))
        #figure(image("figs/lobster.png", width: 40%))
      ]
    ]
  )
]

// #new-section-slide("Work in Progress")

// #slide(title: "Coordination of Multi-tier Field-based Applications")[
//   #figure(
//     image("figs/macro-system-definition.svg")
//   )
// ]

// // #slide(title: "Deployment Mapping")[
// //   #figure(
// //     image("figs/deployment-mapping-diagram-img.svg")
// //   )
// // ]

#slide[
  #bibliography("bibliography.bib")
]
