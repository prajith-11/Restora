package com.restora.restora_backend.service;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.file.*;
import java.util.UUID;

@Service
public class StorageService {

    // Target directory located right within the project workspace
    private final Path rootLocation = Paths.get("uploads/audio");

    public StorageService() {
        try {
            Files.createDirectories(rootLocation);
        } catch (IOException e) {
            throw new RuntimeException("Could not initialize storage directories", e);
        }
    }

    public String store(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return null;
        }
        try {
            // Generate unique name to eliminate overwrite hazards
            String extension = file.getOriginalFilename() != null && file.getOriginalFilename().contains(".") 
                ? file.getOriginalFilename().substring(file.getOriginalFilename().lastIndexOf(".")) 
                : ".m4a";
            String filename = UUID.randomUUID().toString() + extension;
            
            Path destinationFile = this.rootLocation.resolve(Paths.get(filename)).toAbsolutePath().normalize();
            
            file.transferTo(destinationFile);
            return destinationFile.toString();
        } catch (IOException e) {
            throw new RuntimeException("Failed to store file layout binary stream", e);
        }
    }
}