# Restora — Requirements & Scope

## 1. Project Overview
Restora is a mobile post-surgical recovery tracking and trajectory analysis system that bridges the unmonitored gap between clinical appointments for patients undergoing physiotherapy-guided rehabilitation. Patients complete a low-friction daily check-in (under 2 minutes) logging pain, range of motion, mobility milestones, sleep quality, and medication adherence. A backend trajectory analysis engine compares each patient's logged progression against a literature-calibrated recovery baseline, surfacing meaningful deviations as discussion points for the patient's next physiotherapy appointment — never as diagnostic alerts.

**Stack:** Flutter (mobile frontend), Java Spring Boot (backend, layered service architecture), PostgreSQL (relational persistence).

---

## 2. User Roles & Scope Boundaries
*   **Patient (Mobile Interface):** Logs daily physical recovery data using highly accessible voice-to-text or interactive tools.
*   **Clinician/Physiotherapist (Dashboard View):** Reviews data-rich visual summaries of patient recovery trajectories before or during appointments.
*   **Clinical Guardrail:** Restora is explicitly **not** a diagnostic tool. The system identifies pattern deviations and surfaces them as structured discussion topics for the patient's next appointment. It does not provide real-time medical advice or clinical alerts.

---

## 3. Functional Scope (The Core Loop)

### 3.1 Daily Check-In Interface
To maximize compliance, the daily entry must be completable in under two minutes using two main inputs:
1.  **Voice-First Interaction:**
    *   The app prompts the user with recovery questions (e.g., *"Describe your mobility and any stiffness today"*).
    *   The patient taps/holds a single record button to log their response.
    *   **Architecture Choice:** Speech-to-text runs **on-device** in the Flutter app (via a package such as `speech_to_text`), converting the patient's voice directly into text locally. The resulting text is sent to the Java Spring Boot backend as a standard JSON payload — no raw audio is transmitted or stored.
    *   *(Changed from an earlier server-side-STT approach; reverted due to Dart SDK incompatibility with the audio-recording package needed for that path.)*
    *   The backend processes the transcribed text using rule-based/lexicon Natural Language Processing (NLP) to extract medical symptoms, range-of-motion metrics, and pain markers.
2.  **Text Fallback:** A clean, accessible standard text field is always available if the user prefers to type their daily entry.

### 3.2 Spatial Pain Mapping (Interactive Body Map)
*   The UI displays a simplified front/back human silhouette on the mobile screen.
*   **Architecture Choice:** The silhouette uses predefined geometric hitboxes (using SVGs or layered canvas rendering) mapping to distinct anatomical sections.
*   When a user taps an area (e.g., the operated knee), the system logs a standardized, queryable string marker (`zone_id` = `KNEE_LEFT` or `KNEE_RIGHT`) instead of arbitrary screen coordinates ($X/Y$ pixels) which skew across varying screen sizes.

---

## 4. Target Procedure

**Supported procedure (v1):** ACL Reconstruction only.

This project scopes to a single surgical procedure so that baseline modeling and anomaly detection can be built against accurate, literature-backed recovery data rather than generic, unvalidated assumptions. All schema defaults, baseline curves, and deviation logic are built specifically around ACL reconstruction recovery timelines.

---

## 5. Out of Scope (v1)
The following are explicitly deferred and will not be built in this phase:
- Support for additional surgical procedures (e.g., hip/knee replacement, rotator cuff repair)
- Multi-tenant clinician portals or multi-clinic support
- LLM-based or deep-learning NLP (voice-input parsing will use rule-based/lexicon matching against on-device-transcribed text, not a trained model)
- Server-side speech-to-text / raw audio upload (STT runs on-device in Flutter; the backend never receives or stores audio files)
- Wearable/IoT device integration (e.g., Apple Health, Google Fit, BLE sensors)
- Personalized baseline adjustment via trained regression models (v2 uses simple rule-based multipliers on age/fitness/comorbidities, not a learned model)
- Push notifications / reminder systems
- Payment, billing, or clinic administration features

---

## 6. Analytical Scope & The Trajectory Engine

### 6.1 Target Procedure: ACL Reconstruction Baseline
The analytical engine compares patient check-ins against a literature-backed recovery baseline curve. For ACL Reconstruction, the baseline milestones include:
*   **Weeks 1–2:** Swelling reduction, achieving full passive knee extension ($0^\circ$).
*   **Weeks 3–4:** Controlled knee flexion progression ($90^\circ$ to $120^\circ$), gradual weaning off assistive crutches.
*   **Week 6:** Reaching full weight-bearing capacity and normalized gait patterns; target full range of motion by this point.
*   **Weeks 8–12:** Quadriceps/hamstring strength symmetry targets (≥70% limb symmetry index before light jogging is cleared, typically introduced around weeks 10–12).
*   **Months 3–6:** Near-normal range of motion sustained; progression toward sport-specific strength work (out of scope for v1 tracking, noted for context only).

> **Open item:** citations for each milestone still need to be attached inline (source list started in §6.3 below).
> **Open item:** weeks 8–12 and months 3+ are sparser than weeks 1–6 and should be filled in further before seeding `baseline_curves`, since the app is meant to track the full post-surgical window, not just the first 6 weeks.

### 6.2 Trajectory Deviation Definition
To mimic how a clinician evaluates longitudinal data over time, an anomaly or "Trajectory Deviation" is flagged by the backend using a consecutive-days trend logic rather than single-day spikes:
*   **Pain Metric:** A deviation is flagged if the extracted pain score increases or remains completely stagnant for **3 consecutive days**.
*   **Mobility Metric:** A deviation is flagged if physical milestones or range-of-motion observations show zero improvement across **4 consecutive days**.

> **Open item:** sleep quality and medication adherence are logged but currently have no deviation rule defined. Decide explicitly whether they (a) get their own trend logic, (b) feed into pain/mobility deviations as context only, or (c) are excluded from anomaly detection entirely for v1 — and state that decision here rather than leaving it implicit.

### 6.3 Literature Sources (draft — confirm against final bibliography)
- Recovery Stages After ACL Reconstruction — PubMed (phased, criterion-based rehab overview; early-phase ROM/quad strength targets)
- ACL Reconstruction Rehabilitation: Clinical Data, Biologic Healing, and Criterion-Based Milestones — PMC
- Jeremy Burnham, MD — ACL Surgery Recovery Timeline (criterion-based benchmarks: full ROM by week 6, normalized gait by week 8, strength symmetry thresholds before running/agility)
- Additional clinic-sourced timelines used as supplementary, non-primary references

---

## 7. Acceptance Criteria

### Check-in Flow
- [ ] Patient can log pain, ROM, mobility milestone, sleep quality, and medication adherence in a single session
- [ ] Voice input path (record → upload → NLP extraction) works end-to-end
- [ ] Text fallback is always available and functionally equivalent to voice
- [ ] Full flow completes in under 2 minutes (validated via usability timing test)
- [ ] Data persists correctly to `check_ins` table with all fields populated

### Body Map
- [ ] Patient can tap a region on the body silhouette to indicate pain location
- [ ] Selection maps to a structured `zone_id` value and persists to `pain_locations`

### Trajectory Engine
- [ ] Baseline curve for ACL reconstruction is fully seeded across the tracked window (not just weeks 1–6)
- [ ] Deviation logic correctly flags pain/mobility stagnation per the rules in §6.2
- [ ] Deviations surface in the UI as neutrally-framed discussion points, never as diagnostic language

### Clinician Dashboard
- [ ] Displays a patient's full logged trajectory over time
- [ ] Surfaces flagged deviations clearly within the pre-appointment briefing view

### Security
- [ ] Patient and clinician roles are separated via authentication (JWT-based)
- [ ] Sensitive health data is encrypted at rest and in transit (HTTPS)

---

## 8. Data Signals Tracked
| Signal | Field | Type |
|---|---|---|
| Pain level | `pain_score` | INT (1–10) |
| Pain location | `zone_id` (via `pain_locations`) | VARCHAR |
| Range of motion | flexion/extension degrees | derived from milestone logic |
| Mobility milestone | milestone flag/observation | per §6.1 |
| Sleep quality | `sleep_rating` | INT (1–5) |
| Medication adherence | `medication_taken` | BOOLEAN |
| Voice transcript | `transcript` | TEXT (raw, pre-NLP extraction) |