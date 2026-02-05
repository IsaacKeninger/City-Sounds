package com.citysounds.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.citysounds.models.CityArtist;

// DATABASE ACCESS LAYER
//  Allows me to access the db, comes with premade methods for access 
@Repository
public interface CityArtistRepository extends JpaRepository<CityArtist, Long> {
    List<CityArtist> findByCityId(Long cityId);
}
