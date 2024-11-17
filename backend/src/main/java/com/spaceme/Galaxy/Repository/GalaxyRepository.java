package com.spaceme.Galaxy.Repository;

import com.spaceme.Galaxy.Domain.Galaxy;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GalaxyRepository extends JpaRepository<Galaxy, Long> {
    List<Galaxy> findByUserId(Long userId);
}