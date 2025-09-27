package de.eq3.hackathon.kreisverwaltung.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class RootController {

    @GetMapping({
            "/",
            "/catalog",
            "/catalog/**",
            "/datasources",
            "/datasources/**",
            "/user",
            "/user/**",
            "/certificates/pending",
            "/certificates/**",
            "/dataRequests",
            "/dataRequests/**",
            "/myDatasets",
            "/myDatasets/**"
    })
    public String index() {
        return "forward:/index.html";
    }
}