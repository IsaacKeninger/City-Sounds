package com.citysounds.controllers;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller; 
import org.springframework.web.bind.annotation.RequestMapping;

// This tells spring that this class is a web controller
@Controller // these are like a label or tag to give instructions or context to the compiler.
public class HomeController {

    @Value("${spring.application.name}")// inside the brackets is a key in application.properties. (for example the name) just Testing this out
    private String appName;

    @RequestMapping("/") // The "/" means that when a request is to the root("/") of the website, return the html 
    public String index() {
        return "index.html";
    }
}
