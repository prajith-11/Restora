package com.restora.restora_backend.controller;

import com.restora.restora_backend.domain.DailyLog;
import com.restora.restora_backend.domain.Patient;
import com.restora.restora_backend.repository.DailyLogRepository;
import com.restora.restora_backend.repository.PatientRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/api/logs")
@CrossOrigin(origins = "*")
public class DailyLogController {

    private final DailyLogRepository dailyLogRepository;
    private final PatientRepository patientRepository;

    public DailyLogController(DailyLogRepository dailyLogRepository, 
                              PatientRepository patientRepository) {
        this.dailyLogRepository = dailyLogRepository;
        this.patientRepository = patientRepository;
    }

    /**
     * POST /api/logs/checkin
     * Accepts JSON payload or URL-encoded form data
     */
    @PostMapping(
        value = "/checkin",
        consumes = { MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_FORM_URLENCODED_VALUE, MediaType.ALL_VALUE }
    )
    public ResponseEntity<?> createCheckIn(
            @RequestParam(value = "email", required = false) String paramEmail,
            @RequestParam(value = "transcript", required = false) String paramTranscript,
            @RequestParam(value = "selectedZones", required = false) Set<String> paramPainZones,
            @RequestBody(required = false) Map<String, Object> body) {
        
        try {
            // Extract values from JSON body if present, fallback to request params
            String email = (body != null && body.containsKey("email")) 
                    ? (String) body.get("email") 
                    : paramEmail;

            String transcript = (body != null && body.containsKey("transcript")) 
                    ? (String) body.get("transcript") 
                    : paramTranscript;

            if (email == null || email.trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("Patient email is required to submit a check-in.");
            }

            // 1. Fetch the patient context from database
            Patient patient = patientRepository.findByEmail(email)
                    .orElseThrow(() -> new IllegalArgumentException("Patient not found with email: " + email));

            // 2. Construct DailyLog record
            DailyLog log = new DailyLog();
            log.setPatient(patient);
            log.setCreatedAt(LocalDateTime.now());
            log.setTranscript(transcript);

            if (paramPainZones != null && !paramPainZones.isEmpty()) {
                log.setPainZones(paramPainZones);
            } else if (body != null && body.containsKey("selectedZones")) {
                @SuppressWarnings("unchecked")
                List<String> zonesList = (List<String>) body.get("selectedZones");
                if (zonesList != null) {
                    log.setPainZones(Set.copyOf(zonesList));
                }
            }

            // 3. Persist to DB
            DailyLog savedLog = dailyLogRepository.save(log);

            return ResponseEntity.status(HttpStatus.CREATED).body(savedLog);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("An error occurred while saving the check-in: " + e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<List<DailyLog>> getLogs(
            @RequestParam(value = "email", required = false) String email) {
        
        List<DailyLog> logs;

        if (email != null && !email.trim().isEmpty()) {
            logs = dailyLogRepository.findByPatient_EmailOrderByCreatedAtDesc(email);
        } else {
            logs = dailyLogRepository.findAll();
        }

        return ResponseEntity.ok(logs);
    }
}