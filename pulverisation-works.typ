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
  title: "Pulverisation Platform",
  // subtitle: "Activities Summary",
  author: "Nicolas Farabegoli, PhD Student @ UNIBO",
  date: datetime.today().display("[day] [month repr:long] [year]"),
)

#new-section-slide("Pulverization")

#slide(title: "Infrastructure heterogeneity problem")[
  _Macro_-programs are typically deployed on mostly *homogeneous* infrastructures.

  The *ECC* is characterized by a wide range of _devices_ with different _*capabilities*_ and _*constraints*_ complicating the deployment of the full program on a _single device_. 

  // #quote[Which partitioning model can be used to deploy a program on _heterogeneous infrastructures_?]

  #pad(
    top: 0.75em,
    figure(
      image("figs/ecc.svg"),
    )
  )
]

#focus-slide("Which partitioning model?")

#slide(title: "Pulverization Partitioning")[
  #figure(
    image("figs/pulverization-model.svg"),
    // caption: "Logic device partitioned into five components and its links to neighbour devices."
  )
]

#slide(title: "Application and Infrastructure Mapping")[
  #figure(
    image("figs/two-layer-pulverization.svg")
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

#slide(title: "Pulverization DSL: System Definition (1)")[
  ```kt
  object HighCPU by Capability
  object LowLatencyComm by Capability
  object EmbeddedDevice by Capability

  val smartphone = Host("smartphone", embeddedDevice)
  val server = Host("server", highCpu, LowLatencyComm)

  val infrastructure = setOf(smartphone, server)

  object HighLoad : ReconfigurationEvent<Double>() {
    override val predicate = { it > 0.90 }
    override val events = cpuLoad()
  }

  object LowBattery : ReconfigurationEvent<Double>() {
    override val predicate = { it < 0.20 }
    override val events = batteryLevel()
  }
  ```
]

#slide(title: "Pulverization DSL: System Definition (2)")[
  ```kotlin
  val configuration = pulverization {
    val controlCenter by logicDevice {
      withBehavior<ControlBehavior> requires HighCPU
      withCommunication<ControlComm> requires LowLatencyComm
      withSensors<ControlSensors> requires EmbeddedDevice
    }
    val iotDevice by logicDevice {
      withBehavior<DeviceBehavior> requires setOf(HighCPU, EmbeddedDevice)
      withCommunication<DeviceComm> requires LowLatencyComm
      withSensors<DeviceSensor> requires EmbeddedDevice
    }
  // ... continue
  ```
]

#slide(title: "Pulverization DSL: Runtime Setup")[
  ```kotlin
      deployment(infrastructure, Protocol()) {
        device(controlCenter) {
          ControlBehavior() startsOn server
          ControlComm() startsOn server
          ControlSensors() startsOn smartphone
          reconfigurationRules {
            onDevice { HighLoad reconfigures { ControlBehavior movesTo smartphone } }
            onDevice { LowBattery reconfigures { ControlBehavior movesTo server } }
          }
        }
        device(iotDevice) { /* configuration */ }
    }
  }

  val outcome = either {
    val config = configuration.bind()
    val runtime = PulvreaktRuntime(config, "controlCenter", infrastructure).bind()
    runtime.start()
  }
  // ... error handling with outcome
  ```
]

// #slide(title: "Large-Scale Scenario: Collective Computation at a Urban Event")[
//   To show the potential of the automatic reconfiguration of the system, we simulated a large-scale scenario.

//   We simulated a _City Event_ where the participants are involved in a collective activity whose computational weight is relevant (similar to Pokemon Go#footnote[https://pokemongolive.com/]).

//   The application requires physically moving into the city reaching _Points of Interest_ (PoI) and performs some operations there.

//   We suppose the application to be pulverised and its behaviour to be able to run either on a _Smartphone_ or in the _Cloud_.
// ]

// #slide(title: "Metrics")[
//   For each simulated scenario, we define two changing threshold at which the system is reconfigured: $italic(v)$ and $italic(lambda)$ (stable configuration have $italic(v) > italic(lambda)$)

//   When $italic(v), italic(lambda) < 0$ force the behaviour to be always in the cloud,
//   and when $italic(v) < 0, italic(lambda)$ forcing the behaviour to be always on the smartphone.

//   We are interested in the following metrics:

//   - $P#sub[device]  (op("kW"))$, the average power consumption of the device
//   - $P#sub[cloud]  (op("kW"))$, the average power consumption of the cloud
//   - $op("Distance") (op("km"))$, the total distance travelled by the participants
//   - $op("$")#sub[cloud] (op("$"))$, the price paid to keep the required cloud instances up and running
// ]

// #slide(title: "Energy and Cost Models")[
//   We assume that the power consumption of the device is linearly dependent on the CPU usage, and we thus decided to estimate the Energy Per Instruction (EPI) for the _Smartphone_ and the _Cloud_.

//   In this scenario we considered a Qualcomm Snapdragon 888 (5W) and an Intel Xeon Platinum P-8124 (220W).

//   To estimate the EPI we divided the TDP by the CPU score obtained from PassMark#footnote[https://www.cpubenchmark.net/] and then used these ratios to estimate the relative EPI of the two CPUs, obtaining an $op("EPI")#sub[ratio]$ close to $1:18$.

//   We take the EPI estimation for the server CPU from approximately $10 J$ per instruction#cite(<6629328>).

//   #figure(
//     image("figs/simulation-screenshot.png", height: 78%),
//     caption: "A snapshot of the large-scale simulation."
//   )
// ]

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

// #bibliography("bibliography.bib")
