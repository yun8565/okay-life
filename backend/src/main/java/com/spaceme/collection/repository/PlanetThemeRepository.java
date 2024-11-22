package com.spaceme.collection.repository;

import com.spaceme.collection.domain.PlanetTheme;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface PlanetThemeRepository extends JpaRepository<PlanetTheme, Integer> {
    @Query("select coalesce(sum(p.weight),0) from PlanetTheme p")
    int getTotalWeight();
}
