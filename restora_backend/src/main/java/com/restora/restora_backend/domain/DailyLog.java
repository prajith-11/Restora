package com.restora.restora_backend.domain;


import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "daily_logs")
public class DailyLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @Column(name = "log_timestamp", nullable = false)
    private LocalDateTime logTimestamp;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "audio_file_path")
    private String audioFilePath;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "daily_log_pain_zones", joinColumns = @JoinColumn(name = "daily_log_id"))
    @Column(name = "zone_id")
    private Set<String> painZones = new HashSet<>();

    public DailyLog() {}

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }
    public LocalDateTime getLogTimestamp() { return logTimestamp; }
    public void setLogTimestamp(LocalDateTime logTimestamp) { this.logTimestamp = logTimestamp; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public String getAudioFilePath() { return audioFilePath; }
    public void setAudioFilePath(String audioFilePath) { this.audioFilePath = audioFilePath; }
    public Set<String> getPainZones() { return painZones; }
    public void setPainZones(Set<String> painZones) { this.painZones = painZones; }
}