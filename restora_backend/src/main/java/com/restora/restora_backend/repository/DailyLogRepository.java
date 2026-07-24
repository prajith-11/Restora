package com.restora.restora_backend.repository;

import com.restora.restora_backend.domain.DailyLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DailyLogRepository extends JpaRepository<DailyLog, Long> {

    // Spring Data maps DailyLog.patient -> Patient.email, sorted by DailyLog.createdAt
    List<DailyLog> findByPatient_EmailOrderByCreatedAtDesc(String email);

}