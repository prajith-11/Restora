package com.restora.restora_backend.domain;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "patients")
public class Patient {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "first_name", nullable = false)
    private String firstName;

    @Column(name = "last_name", nullable = false)
    private String lastName;

    @Column(name = "surgery_date", nullable = false)
    private LocalDate surgeryDate;

    // Standard Boilerplate Constructors
    public Patient() {}

    public Patient(String email, String firstName, String lastName, LocalDate surgeryDate) {
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.surgeryDate = surgeryDate;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public LocalDate getSurgeryDate() { return surgeryDate; }
    public void setSurgeryDate(LocalDate surgeryDate) { this.surgeryDate = surgeryDate; }
}
