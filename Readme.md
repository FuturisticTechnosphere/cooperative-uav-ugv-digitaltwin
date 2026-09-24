# Autonomous Multi-Robot System: UAV-UGV Digital Twin & Collaborative Mapping

Questo progetto implementa l'architettura di simulazione e controllo per una missione collaborativa terra-aria (UAV-UGV) all'interno di un ambiente Digital Twin sviluppato in ambiente **MATLAB / Simulink**.

Il framework modella una missione in due fasi:
1. **Fase Aerea (UAV):** Ricognizione ad alta quota tramite quadricottero con controllo non lineare in **Backstepping**, generazione dinamica del Field of View (FOV) della camera a terra e mappatura dell'area operativa.
2. **Fase Terrestre (UGV):** Navigazione autonoma di un veicolo terrestre tramite pianificazione di traiettoria basata su **Campi di Potenziali Artificiali** e controllo cinematico di inseguimento percorso mediante algoritmo **Pure Pursuit**.

---

## 🛠️ Architettura di Controllo & Modelli

### 1. Quadricottero (UAV)
* **Modello Dinamico:** Modello a 6 DOF con dinamiche traslazionali e rotazionali accoppiate.
* **Controllo in Backstepping:** Algoritmo non lineare a cascata basato sulla teoria di Lyapunov.
* **FOV Dinamico:** Calcolo in tempo reale dell'impronta a terra della telecamera.

### 2. Veicolo Terrestre (UGV)
* **Modello Cinematico:** Modello uniciclo a guida differenziale vincolato da moto non olonomo.
* **Pianificazione:** Algoritmo a campi di potenziale attrattivi/repulsivi per l'evitamento ostacoli.
* **Path Following Pure Pursuit:** Inseguimento geometrico della traiettoria generata con regolazione dinamica del look-ahead distance.
