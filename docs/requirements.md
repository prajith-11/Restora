# Restora — Minimum Viable Product (MVP) Requirements Specification

## 1. Project Overview & Objective
Restora is a mobile post-surgical recovery tracking and trajectory analysis system designed to bridge the unmonitored gap between clinical appointments for patients undergoing physiotherapy-guided rehabilitation. The MVP targets a single clinical procedure: **ACL Reconstruction (Knee)**. 

The core focus is providing a low-friction daily check-in loop that transforms subjective patient experiences into structured data records, enabling time-series anomaly detection at a trend/trajectory level rather than isolated instances.

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
    *   **Architecture Choice:** The Flutter mobile application records raw audio (e.g., `.wav` or `.m4a`) and streams/uploads it via a multipart POST request directly to the Java Spring Boot backend. 
    *   The backend processes the audio using Natural Language Processing (NLP) to extract medical symptoms, range-of-motion metrics, and pain markers.
2.  **Text Fallback:** A clean, accessible standard text field is always available if the user prefers to type their daily entry.

### 3.2 Spatial Pain Mapping (Interactive Body Map)
*   The UI displays a simplified front/back human silhouette on the mobile screen.
*   **Architecture Choice:** The silhouette uses predefined geometric hitboxes (using SVGs or layered canvas rendering) mapping to distinct anatomical sections.
*   When a user taps an area (e.g., the operated knee), the system logs a standardized, queryable string marker (`zone_id` = `KNEE_LEFT` or `KNEE_RIGHT`) instead of arbitrary screen coordinates ($X/Y$ pixels) which skew across varying screen sizes.

---

## 4. Analytical Scope & The Trajectory Engine

### 4.1 Target Procedure: ACL Reconstruction Baseline
The analytical engine compares patient check-ins against a literature-backed recovery baseline curve. For ACL Reconstruction, the baseline milestones include:
*   **Weeks 1–2:** Swelling reduction, achieving full passive knee extension ($0^\circ$).
*   **Weeks 3–4:** Controlled knee flexion progression ($90^\circ$ to $120^\circ$), gradual weaning off assistive crutches.
*   **Week 6:** Reaching full weight-bearing capacity and normalized gait patterns.

### 4.2 Trajectory Deviation Definition
To mimic how a clinician evaluates longitudinal data over time, an anomaly or "Trajectory Deviation" is flagged by the backend using a consecutive-days trend logic rather than single-day spikes:
*   **Pain Metric:** A deviation is flagged if the extracted pain score increases or remains completely stagnant for **3 consecutive days**.
*   **Mobility Metric:** A deviation is flagged if physical milestones or range-of-motion observations show zero improvement across **4 consecutive days**.

---

## 5. Technical Stack Architecture
*   **Frontend Mobile Client:** Flutter (iOS/Android) leveraging audio recording frameworks and canvas/SVG interaction packages.
*   **Backend Services:** Java Spring Boot hosting independent, testable service layers for file management, NLP extraction adapters, and trajectory comparison logic.
*   **Database:** Relational Database (SQL) to structure longitudinal post-surgical histories across the full recovery window.