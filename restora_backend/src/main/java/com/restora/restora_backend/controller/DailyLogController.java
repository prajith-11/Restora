package com.restora.restora_backend.controller;

import com.restora.restora_backend.domain.*;
import com.restora.restora_backend.repository.*;
import com.restora.restora_backend.service.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/logs")
@CrossOrigin(origins = "*") // Allows your mobile emulator/browser interface to communicate seamlessly
public class DailyLogController {

    private final DailyLogRepository dailyLogRepository;
    private final PatientRepository patientRepository;
    private final StorageService storageService;

    public DailyLogController(DailyLogRepository dailyLogRepository, 
                              PatientRepository patientRepository, 
                              StorageService storageService) {
        this.dailyLogRepository = dailyLogRepository;
        this.patientRepository = patientRepository;
        this.storageService = storageService;
    }

    @PostMapping("/checkin")
    public ResponseEntity<?> createCheckIn(
            @RequestParam("email") String email,
            @RequestParam(value = "notes", required = false) String notes,
            @RequestParam(value = "painZones", required = false) Set<String> painZones,
            @RequestParam(value = "audioFile", required = false) MultipartFile audioFile) {
        
        try {
            // 1. Fetch the patient context from the database
            Patient patient = patientRepository.findByEmail(email)
                    .orElseThrow(() -> new IllegalArgumentException("Patient not found with email: " + email));

            // 2. Stream and write the audio payload to local disk
            String savedAudioPath = null;
            if (audioFile != null && !audioFile.isEmpty()) {
                savedAudioPath = storageService.store(audioFile);
            }

            // 3. Construct and map the new DailyLog record
            DailyLog log = new DailyLog();
            log.setPatient(patient);
            log.setLogTimestamp(LocalDateTime.now());
            log.setNotes(notes);
            log.setAudioFilePath(savedAudioPath);
            
            if (painZones != null) {
                log.setPainZones(painZones);
            }

            // 4. Persist to relational storage
            DailyLog savedLog = dailyLogRepository.save(log);

            return ResponseEntity.status(HttpStatus.CREATED).body(savedLog);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("An error occurred while compiling the check-in data: " + e.getMessage());
        }
    }
}