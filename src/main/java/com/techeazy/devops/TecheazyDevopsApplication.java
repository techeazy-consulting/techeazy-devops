package com.techeazy.devops;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.IOException;

import org.json.JSONObject;

@SpringBootApplication
public class TecheazyDevopsApplication {

    public static void main(String[] args) {
        SpringApplication.run(TecheazyDevopsApplication.class, args);

        try {
            // Load config.json
            String configContent = new String(Files.readAllBytes(Paths.get("configs/config.json")));
            JSONObject config = new JSONObject(configContent);

            // Print config values
            System.out.println("== Loaded Config ==");
            System.out.println("Stage: " + config.getString("stage"));
            System.out.println("Debug Mode: " + config.getBoolean("debug"));
        } catch (IOException e) {
            System.out.println("Could not load config.json: " + e.getMessage());
        }
    }
}
