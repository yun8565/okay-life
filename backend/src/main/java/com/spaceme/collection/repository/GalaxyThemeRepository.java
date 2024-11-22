package com.spaceme.collection.repository;

import com.spaceme.collection.domain.GalaxyTheme;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface GalaxyThemeRepository extends JpaRepository<GalaxyTheme, Long> {
    @Query("select coalesce(sum(g.weight),0) from GalaxyTheme g")
    int getTotalWeight();
}
