package de.eq3.hackathon.kreisverwaltung;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class KreisverwaltungApplication {

	public static void main(String[] args) {
		System.out.println("Starting Kreisverwaltung Application...");
		SpringApplication.run(KreisverwaltungApplication.class, args);
	}

}
