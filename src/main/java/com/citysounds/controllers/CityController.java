package com.citysounds.controllers;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.citysounds.models.City;
import com.citysounds.repository.CityRepository;
import com.citysounds.services.SpotifyService;


// This is the primary RESTAPI for citySounds
/*
REPOSITORY -> cityRepository
SERVICE -> SpotifyService
ENDPOINTS -> 
    /api/cities: Calls getAllCities()
        - returns all city objects for initiazation of the cites on the globe
    /api/cities/{id}: calls getCityviaID(parameter: id)
        - When City is clicked on -> return city object
    /api/cities{id}/music: calls GetMusicForCity(parameter: id)
        - Fetches the music track using the spotify Service; else, return an error
*/

@RestController
public class CityController {

    private final CityRepository cityRepository;
    private final SpotifyService spotifyService;

    public CityController(CityRepository cityRepository, SpotifyService spotifyService){
        this.cityRepository = cityRepository;
        this.spotifyService = spotifyService;
    }

    // This recieves a request from app.js and returns all of the city objects. for initializatiuon of the globe
    @GetMapping("/api/cities")
    public List<City> getAllCities(){
        return cityRepository.findAll();
    }

    // This recieves a fetch from when you click on a city andi t will return that city object
    @GetMapping("/api/cities/{id}")
    public City getCityviaID(@PathVariable Long id) {
        return cityRepository.findById(id).orElse(null);
    }

    // This fetches the music for the city once it is clicked on
    @GetMapping("/api/cities/{id}/music")
    public ResponseEntity<String> GetMusicForCity(@PathVariable Long id){
        City city = cityRepository.findById(id).orElse(null);

        if (city == null) {
            return ResponseEntity.notFound().build();
        }

        try {
            String trackId = spotifyService.getCuratedCityTrack(city.getId(), city.getCountryCode());
            return ResponseEntity.ok(trackId != null && !trackId.isEmpty() ? trackId : "");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("");
        }
    }

}
