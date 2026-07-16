# Restora Mobile Application - UI Wireframes & Navigation

## 1. Application Navigation Flow
Login Page
 └── Success -> Home Screen
                 ├── Drawer (Profile, Settings, History) (TBD)
                 └── "Log Today" Button -> Question & Check-In Page
                                            └── Action: Submit -> Home Screen (State: "Already Logged")

---

## 2. Detailed Screen Content Blueprints

### Screen A: Login Page
*   **Header:** Restora Branding / Logo.
*   **Inputs:** Email/Username/Mobile No. Field, Password Field.
*   **Actions:** "Login" Button (Routes to Home Screen).

### Screen B: Home Screen (Main Hub)
*   **Top:** AppBar with structural title ("Welcome Back User").
*   **Navigation:** Hamburger icon opening a lateral Drawer menu.
*   **Status Block:** Dynamic text tracker showing current day (e.g., "Day 3 of Recovery").
*   **Summary Card:** "Your Last Log Summary" - displaying pain score and recovery metrics from yesterday.
*   **Primary Action Area:** Dynamic State Button:
    *   *State 1:* "Log Today" (Clickable -> opens Questions Page).
    *   *State 2:* "Already Logged Today" (Disabled gray button / checkmark icon).

### Screen C: Question & Check-In Page (Unified Flow)
*   **Section 1: The Conversational Voice Loop (Top)**
    *   *Text Prompt:* "Describe your knee mobility, extension, or any stiffness you are experiencing today."
    *   *Input A (Voice):* Oversized Microphone Button (Idle / Recording / Processing states).
    *   *Input B (Text Fallback):* Expandable TextBox ("Or type your notes here instead...").
*   **Section 2: Interactive Body Mapping (Middle/Bottom Transition)**
    *   *Text Prompt:* "Please select the specific location on your body where the pain is located:"
    *   *Visual Interactive Zone:* Front/Back Human Silhouette graphic containing explicit hitbox markers mapped directly to database string constants (`KNEE_LEFT`, `KNEE_RIGHT`). Tapping toggles a visual highlight color.
*   **Section 3: Completion (Footer)**
    *   *Action:* Sticky full-width "Submit Check-In" button at the very bottom.