# Autonomous Multi-Robot System: UAV-UGV Digital Twin & Collaborative Mapping

Questo progetto implementa l'architettura di simulazione e controllo per una missione collaborativa terra-aria (UAV-UGV) all'interno di un ambiente Digital Twin sviluppato in ambiente **MATLAB / Simulink**.

Il framework modella una missione in due fasi:
1. **Fase Aerea (UAV):** Ricognizione ad alta quota tramite quadricottero con controllo non lineare in **Backstepping**, generazione dinamica del Field of View (FOV) della camera a terra e mappatura dell'area operativa.
2. **Fase Terrestre (UGV):** Navigazione autonoma di un veicolo terrestre tramite pianificazione di traiettoria basata su **Campi di Potenziali Artificiali** e controllo cinematico di inseguimento percorso mediante algoritmo **Pure Pursuit**.

---

## 🎬 Dimostrazione Digital Twin

> L'animazione completa della missione (rendering 720p @ 30 FPS) mostra il coordinamento temporale, la copertura FOV della camera del quadricottero e la navigazione terrestre con orientamento dinamico del veicolo.

---

## 🛠️ Architettura di Controllo & Modelli

### 1. Quadricottero (UAV)
* **Modello Dinamico:** Modello a 6 DOF con dinamiche traslazionali e rotazionali accoppiate.
* **Controllo in Backstepping:** Algoritmo non lineare a cascata basato sulla teoria di Lyapunov per garantire convergenza asintotica dell'errore di posizione $(x, y, z)$ e dell'angolo di imbardata ($\psi$).
* **FOV Dinamico:** Calcolo in tempo reale dell'impronta a terra della telecamera:
  $$L_{\text{fov}} = 2 \cdot z_u \cdot \tan\left(\frac{\text{FOV}}{2}\right)$$

### 2. Veicolo Terrestre (UGV)
* **Modello Cinematico:** Modello uniciclo a guida differenziale vincolato da moto non olonomo.
* **Pianificazione:** Algoritmo a campi di potenziale attrattivi/repulsivi per l'evitamento ostacoli e raggiungimento dei waypoint/HQ.
* **Path Following Pure Pursuit:** Inseguimento geometrico della traiettoria generata con regolazione dinamica del look-ahead distance.

---

## 📂 Struttura del Repository

```plaintext
├── models/
│   └── uav_ugv_digital_twin.slx   # Modello Simulink completo del sistema
├── src/
│   ├── init_params.m              # Script parametri fisici e guadagni di controllo
│   ├── animate_digital_twin.m     # Rendering Digital Twin ed esportazione MP4/video
│   └── Mappa.m                    # Definizione geometrica del layer ambientale
├── docs/
│   └── Missione_UAV_UGV_Altis.mp4 # Video renderizzato della simulazione
└── README.md