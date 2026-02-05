package com.citysounds.services;

import java.util.Map;
import java.util.Random;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import com.citysounds.repository.CityArtistRepository;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

/*
    This is kind of a lot to break down but i'll break it down

    SpotifyService: The primary service for accessing the spotify API, Get an Artist, and Get an Artists Top Track (or one of)

    Methods: 
        Spotify Authentication Methods
            - GetAccessToken()
            - createAuthHeaders
            - 
*/

@Service
public class SpotifyService { 

    // Dependency Injections (ClientId, clientSecret; from application.properties)
    @Value("${spotify.client-id}")
    private String clientId;
    
    @Value("${spotify.client-secret}")
    private String clientSecret;

    private final CityArtistRepository cityArtistRepository;
    private final RestTemplate restTemplate = new RestTemplate();
    private final Gson gson = new Gson();
    private final Random random = new Random();

    private static final String TOKEN_URL = "https://accounts.spotify.com/api/token";
    private static final String SEARCH_URL = "https://api.spotify.com/v1/search";
    private static final String ARTIST_TOP_TRACKS_URL = "https://api.spotify.com/v1/artists/%s/top-tracks";

    private String cachedAccessToken = null;
    private long tokenExpirationTime = 0;

    // Constructor (SpotifyService(Parameter: cityArtistRepository))
    public SpotifyService(CityArtistRepository cityArtistRepository) {
        this.cityArtistRepository = cityArtistRepository;
    }

    // Authentication for Spotify API Methods (getAccessToken())
    private String getAccessToken() {
        long currentTime = System.currentTimeMillis();

        // if it is cached just use that token
        if (cachedAccessToken != null && currentTime < tokenExpirationTime) {
            return cachedAccessToken;
        }

        // otherwise create one
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        headers.setBasicAuth(clientId, clientSecret);

        MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
        body.add("grant_type", "client_credentials");

        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(body, headers);

        ResponseEntity<Map<String, Object>> response = restTemplate.postForEntity(TOKEN_URL, request,
            (Class<Map<String, Object>>)(Class<?>)Map.class);

        Map<String, Object> responseBody = response.getBody();
        if (responseBody == null) {
            System.out.println("Error: Spotify token response body is null");
            return null;
        }

        cachedAccessToken = (String) responseBody.get("access_token");
        if (cachedAccessToken == null) {
            System.out.println("Error: No access token in response");
            return null;
        }

        Integer expiresIn = (Integer) responseBody.get("expires_in");
        tokenExpirationTime = currentTime + ((expiresIn - 300) * 1000L);

        return cachedAccessToken;
    }

    // Primary Method (getCuratedCityTrack())
    public String getCuratedCityTrack(Long cityId, String countryCode) {
        try {
            System.out.println("Looking for artists for city ID: " + cityId);
            List<CityArtist> artists = cityArtistRepository.findByCityId(cityId); // This searches the database and finds a city by ID via springboots repository interface connection to db. Puts them into an array of ID's
            System.out.println("Found " + (artists !=null ? artists.size() : 0) + " artists"); // if artist is no null, call artists size and reutnr that, else return 0

            if (artists == null) {
                System.out.println("Fault In Database: No  artists found for city ID: " + cityId); // if no artists in the DB
                return null;
            }

            // Print all found artists
            for (CityArtist artist : artists) { // for each loop printing out each artist name found
                System.out.println("Artist - " + artist.getArtistName());
            }

            CityArtist randomArtist = artists.get(random.nextInt(artists.size())); // This gets a random artist from the artists array, all of the artists in the db and puts into a cityArtists object
            System.out.println("Selected Artist: " + randomArtist.getArtistName());

            String artistName = randomArtist.getArtistName();

            // Find Artist ID, the call to return a top track
            System.out.println("Searching for " + artistName + "'s' top tracks via Spotify API.");
            String artistId = searchArtistId(artistName); // get their artists ID
            if (artistId == null) {
                System.out.println("Could not find " +  artistName);
                return null;
            }

            return getArtistTopTrack(artistId, countryCode); // returns the top track for that artist via thei artist ID

        } catch (Exception e) { // handle error if couldnt find a track
            System.out.println("Error getting track: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    private HttpHeaders createAuthHeaders() { //boring authentication stuff
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + getAccessToken());
        return headers;
    }
    // Helper Methods (searchArtistID(), getArtistTopTrack())
    private String searchArtistId(String artistName) {
        try {
            String url = SEARCH_URL + "?q=" + artistName + "&type=artist&limit=1"; // create URL for spotify api, only top result
            HttpEntity<String> entity = new HttpEntity<>(createAuthHeaders()); // set up auth headers
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class); //send get request to spotify via exchange and return json 

            JsonObject jsonResponse = gson.fromJson(response.getBody(), JsonObject.class); // convert JSON text to a java object 
            if (jsonResponse == null || !jsonResponse.has("artists")) { // validates the response, makes sure it has artists
                System.out.println("Error: Invalid response from Spotify artist search");
                return null;
            }

            JsonArray artists = jsonResponse.getAsJsonObject("artists").getAsJsonArray("items");  // parses the artists array from the json to array

            // get the artists ID
            if (artists != null && artists.size() > 0) {
                String artistId = artists.get(0).getAsJsonObject().get("id").getAsString();
                System.out.println("Found artist ID: " + artistId + " for artist: " + artistName);
                return artistId;
            }

            System.out.println(artistName + "not found...");
            return null;
        } catch (Exception e) {
            System.out.println("Error searching for artist: " + e.getMessage());
            return null;
        }
    }
    private String getArtistTopTrack(String artistId, String countryCode) {

        try {
            String market = (countryCode != null && !countryCode.isEmpty()) ? countryCode : "US"; // if artist has no coutnrycode, juse use US market, else use their actual one.
            String url = String.format(ARTIST_TOP_TRACKS_URL, artistId) + "?market=" + market; // create url for spotify api
            HttpEntity<String> entity = new HttpEntity<>(createAuthHeaders());
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class); // call spotify api

            JsonObject jsonResponse = gson.fromJson(response.getBody(), JsonObject.class); // get response into a java object
            if (jsonResponse == null || !jsonResponse.has("tracks")) { // check if actually ghas tracks
                System.out.println("Invalid response from Spotify - no tracks array");
                return null;
            }

            JsonArray tracks = jsonResponse.getAsJsonArray("tracks"); // turn into array
            // 
            if (tracks != null && tracks.size() > 0) {
                int randomIndex = random.nextInt(tracks.size()); // get random track within the list
                String trackId = tracks.get(randomIndex).getAsJsonObject().get("id").getAsString(); // get track id
                System.out.println("Found top track ID: " + trackId + " (index " + randomIndex + " of " + tracks.size() + ")");
                return trackId;
            }

            System.out.println("No tracks returned from Spotify for artist: " + artistId);
            return null;
        } catch (Exception e) {
            System.out.println("Error getting artist top tracks: " + e.getMessage());
            return null;
        }
    }

}