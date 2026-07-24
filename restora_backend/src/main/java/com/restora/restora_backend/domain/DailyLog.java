package com.restora.restora_backend.domain;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Set;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Table(name = "daily_logs")
public class DailyLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Links the log to a specific patient. The Patient table handles the email.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    @JsonIgnore // Prevents infinite recursion during JSON output
    private Patient patient;

    @JsonProperty("createdAt")
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @JsonProperty("transcript")
    @Column(name = "transcript", columnDefinition = "TEXT")
    private String transcript;

    @JsonProperty("selectedZones")
    @ElementCollection
    @CollectionTable(name = "daily_log_pain_zones", joinColumns = @JoinColumn(name = "daily_log_id"))
    @Column(name = "pain_zone")
    private Set<String> painZones;

    public DailyLog() {}

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public String getTranscript() { return transcript; }
    public void setTranscript(String transcript) { this.transcript = transcript; }
    
    public Set<String> getPainZones() { return painZones; }
    public void setPainZones(Set<String> painZones) { this.painZones = painZones; }
}