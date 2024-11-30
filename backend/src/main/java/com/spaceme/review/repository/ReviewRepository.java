package com.spaceme.review.repository;

import com.spaceme.review.domain.Review;
import com.spaceme.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByUser(User user);
    Optional<Review> findByUserAndPlanetId(User user, Long planetId);
}
