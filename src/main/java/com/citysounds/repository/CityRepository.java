package com.citysounds.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.citysounds.models.City;

// DATABASE ACCESS LAYER
//  Allows me to access the db, comes with premade methods for access 
@Repository
public interface CityRepository extends JpaRepository<City, Long> {
}
