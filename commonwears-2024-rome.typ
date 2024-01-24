#import "@preview/polylux:0.3.1": *

#import themes.metropolis: *

#set page(paper: "presentation-16-9")
#show raw: set text(size: 11pt)
#show math.equation: set text(font: "Fira Math")
#show figure.caption: set text(size: 16pt)

#set text(font: "Fira Sans", weight: "light", size: 20pt)
#set strong(delta: 100)
#set par(justify: true)

#title-slide(
  title: "COMMON-WEARS Meeting @ Rome",
  // subtitle: "TBD",
  author: "Nicolas Farabegoli",
  date: "January 25, 2024",
)

#new-section-slide("Pulverization: Reconfig. at Runtime")

#slide[
  = RQs

  / RQ1: How can a pulverised deployment be reconfigured at runtime in a decentralised way to adapt to changing conditions (load, energy, etc.)?

  / RQ2: How can such adaptation be designed to providerelevant benefits over a static allocation?

  = Main contributions

  + Extend the theoretical framework of pulverisation by adding support for _runtime configuration rules_
  + Provide a practical framework (called _PulvReAKt_) developed in Kotlin
  + Validate the proposed framework both by simulation and real deployment
]

// #slide(title: "Middleware architecture")[
//   #figure(
//     image("figs/pulverization-example.png")
//   )
// ]

#slide(title: "Pulverization DSL: System Definition")[
  ```kt
  object HighCPU : Capability
  object LowLatencyComm : Capability
  object EmbeddedDevice : Capability

  val configuration = pulverizedSystem {
    device("control-center") {
      Behavior and State deployableOn HighCPU
      Communication deployableOn LowLatencyComm
      Sensors deployableOn EmbeddedDevice
    }
    device("iot-sensor") {
      Behavior deployableOn setOf(HighCPU, EmbeddedDevice)
      Communication deployableOn LowLatencyComm
      Sensors and Actuators deployableOn EmbeddedDevice
    }
  }
  ```
]

#slide(title: "Pulverization DSL: Runtime Setup")[
  ```kt
  object HighLoad : ReconfigurationEvent<Double>() {
    override val predicate = { it > 0.90 }
    override val events = cpuLoad()
  }
  object LowBattery : ReconfigurationEvent<Double>() {
    override val predicate = { it < 0.20 }
    override val events = batteryLevel()
  }
  val runtime = pulverizationRuntime(configuration, "iot-sensor", setOf(...)) {
    DeviceBehaviour() startsOn Server
    DeviceCommunication() startsOn Server
    DeviceSensors() startsOn Smartphone
    DeviceActuators() startsOn Smartphone
    reconfigurationRules {
      onDevice {
          HighLoad reconfigures { Behaviour movesTo Smartphone }
          LowBattery reconfigures { Behaviour movesTo Server }
      }
    }
  }
  ```
]

#slide(title: "Small-Scale Scenario: Crowd Alert in a Lab")[
  We want to avoid situations where too many people are too close to each other in the same room for safety reasons.

  To do so, we equiped each people with a _wearable device_ that can detect other devices via Bluetooth.

  The _Received Signal Strenght Indicator_ (RSSI) is used to estimate the distance between two devices:
  #align(center)[
    $d = 10^frac(R#sub[ref] minus R, 10 dot n)$
  ]

  The system is composed of: _Smartphones_, a _Monitor_, and a _Server_.

  The _Behaviour_ of the devices is moved to the _Smartphones_ when the _CPU load_ is too high and to the _Server_ when the _Battery level_ is too low.
]

#slide(title: "Representation of the system in action")[
  #figure(
    image("figs/crow-laboratory-demo.drawio.svg")
  )
]

#slide(title: "Large-Scale Scenario: Collective Computation at a Urban Event")[
  To show the potential of the automatic reconfiguration of the system, we simulated a large-scale scenario.

  We simulated a _City Event_ where the participants are involved in a collective activity whose computational weight is relevant (similar to Pokemon Go#footnote[https://pokemongolive.com/]).

  The application requires physically moving into the city reaching _Points of Interest_ (PoI) and performs some operations there.

  We suppose the application to be pulverised  and its behaviour to be able to run either on a _Smartphone_ or in the _Cloud_.
]

#slide(title: "Metrics")[
  For each simulated scenario, we define two changing threshold at which the system is reconfigured: $italic(v)$ and $italic(lambda)$ (stable configuration have $italic(v) > italic(lambda)$)

  When $italic(v), italic(lambda) < 0$ force the behaviour to be always in the cloud,
  and when $italic(v) < 0, italic(lambda)$ forcing the behaviour to be always on the smartphone.

  We are interested in the following metrics:

  - $P#sub[device]  (op("kW"))$, the average power consumption of the device
  - $P#sub[cloud]  (op("kW"))$, the average power consumption of the cloud
  - $op("Distance") (op("km"))$, the total distance travelled by the participants
  - $op("$")#sub[cloud] (op("$"))$, the price paid to keep the required cloud instances up and running
]

#slide(title: "Energy and Cost Models")[
  We assume that the power consumption of the device is linearly dependent on the CPU usage, and we thus decided to estimate the Energy Per Instruction (EPI) for the _Smartphone_ and the _Cloud_.

  In this scenario we considered a Qualcomm Snapdragon 888 (5W) and an Intel Xeon Platinum P-8124 (220W).

  To estimate the EPI we divided the TDP by the CPU score obtained from PassMark#footnote[https://www.cpubenchmark.net/] and then used these ratios to estimate the relative EPI of the two CPUs, obtaining an $op("EPI")#sub[ratio]$ close to $1:18$.

  We take the EPI estimation for the server CPU from approximately $10 J$ per instruction

  #figure(
    image("figs/simulation-screenshot.png", height: 78%),
    caption: "A snapshot of the large-scale simulation."
  )
]

#slide(title: "Results")[
  #figure(
    image("figs/cloud_cost-device_consumption-cloud_consumption-distance-device=1000.0.png"),
    caption: "Simulation results with 1000 devices"
  )
]

#new-section-slide("AC for Dynamic Reconfiguration")

#slide[
  = RQs

  / RQ1: How can a pulverised system be effectively deployed and managed in complex infrastructures like the Edge-to-Cloud Continuum?
  / RQ2: How can a pulverised system be dynamically reconfigured in a decentralised way using global policies?
  / RQ3: What are the benefits and limitations of using decentralised policies?

  = Main contributions

  + A _middleware architecture_ for managing pulverised systems in the E-CC
  + The use of _AC_ as a solution for the _dynamic reconfiguration_ of the system
  + An evaluation of the proposed reconfiguration approach comparing the _adaptive_ solution with a _non-adaptive_ counterpart.
]

#slide(title: "Middleware architecture")[
  #figure(
    image("figs/new-pulv-arch.png"),
    caption: "Middleware layers and the mapping between them in the architectural model."
  )

  #figure(
    image("figs/middleware-example-ac.png"),
    caption: "Representation of a simple system composed of four logical devices."
  )
]

#slide(title: "AC for Dynamic Reconfiguration")[

  We show how Aggregate Computing can provide a suitable programming model for implementing runtime reconfiguration rules for pulverised systems from a global stance.

  We consider a system composed of _thin_ and _thick_ devices, where the former are able to offload their behaviour to the latter.

  The objective is to dynamically relocate the behaviour adapting to changing conditions (e.g., load, latency, bettery etc.).

  A reconfiguration policy can be defined as a _function_ returning `Set[Component]` to be executed locally.
]

#slide(title: "SCR approach")[
  ```scala
  def isThick: Boolean = ... // true if the device is thick
  def offloadWeight: Int = ... // the offload weight
  def cpuCost(): Int = if (isThick) /* cpu load */ else offloadWeight

  def behavior = ... // the local behavior component
  def main(): Set[Component] = {
    val potential =
      G(source = isThick, field = cpuCost(), acc = _ + _, metric = cpuCost)
    val managed: Set[Behavior] = C(potential, _ ++ _, Set(behavior))
    var load = cpuCost()
    val runOnThick: Set[Behavior] =
      if (isThick) managed.takeWhile { load += offloadWeight; load < 100 }
      else Set()
    val onLeader = G(isThick, runOnThick, identity(), cpuCost)
    if (isThick) onLeader
    else Set(behavior) -- onLeader ++ Set(Sensor, Actuator)
  }
  ```
]

#slide(title: "Evaluation")[
  We have exercised the proposed approach in two network topologies: _Lobster Network_ and _Scale-free Network_.

  For each topology we have considered different _device load_, and _device failure_.

  In all the experiments we have measured the $"QoS" = frac(tau#sub("0"), tau)$ of the system where $tau$ is the _thin_ and _thick_ device that have successfully offloaded their behaviour. The set of device that have failed to offload their behaviour is $tau#sub[0] subset.eq tau$.

  The baseline we compare with is a system where offloading is pre-defined: every thin host offloads its behaviour component to the nearest thick host.
]

#slide(title: "Results - Varaible Load")[
  #figure(
    image("figs/dynamic-load.svg"),
    caption: "Comparison between the baseline and the proposed approach with variable load."
  )
]

#slide(title: "Results - Graceful Degradation")[
  #figure(
    image("figs/constant-load.svg"),
    caption: "Comparison between the baseline and the proposed approach in a degradation condition."
  )
]
