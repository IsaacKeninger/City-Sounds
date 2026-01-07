package com.citysounds.controllers;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller; // Annotation is defined here
import org.springframework.web.bind.annotation.RequestMapping;

// tells spring that this class is a web controller for web traffic
@Controller // these are like a label or tag to give instructions or context to the compiler.
public class HomeController {

    //
    @Value("${spring.application.name}")// inside the brackets is a key in application.properties. (for example the name)
    private String appName;

    @RequestMapping("/") // The "/" means that when a request is to the root("/") of the website, use this method
    public String index() {
        System.out.println("appName: " + appName);
        return "index.html";
    }
}
