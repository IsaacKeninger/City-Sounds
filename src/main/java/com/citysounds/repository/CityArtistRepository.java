package com.citysounds.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.citysounds.models.CityArtist;

@Repository
public interface CityArtistRepository extends JpaRepository<CityArtist, Long> {
    List<CityArtist> findByCityId(Long cityId);
}
