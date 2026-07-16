package com.restora.restora_backend.repository;

import com.restora.restora_backend.domain.DailyLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DailyLogRepository extends JpaRepository<DailyLog, Long> {
}
