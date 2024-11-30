package com.spaceme.review.controller;

import com.spaceme.auth.domain.Auth;
import com.spaceme.planet.domain.Planet;
import com.spaceme.review.dto.request.ReviewRequest;
import com.spaceme.review.dto.response.ReviewPlanetResponse;
import com.spaceme.review.dto.response.ReviewResponse;
import com.spaceme.review.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("/reviews")
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping
    public ResponseEntity<Void> saveReview(
            @Auth Long userId,
            @RequestBody ReviewRequest reviewRequest
    ) {
        reviewService.saveReview(userId, reviewRequest);
        return ResponseEntity.noContent().build();
    }

    @GetMapping
    public ResponseEntity<List<ReviewPlanetResponse>> findCompletedPlanets(@Auth Long userId) {
        return ResponseEntity.ok(reviewService.findCompletedPlanets(userId));
    }

    @GetMapping("/{planetId}")
    public ResponseEntity<ReviewResponse> findReviewByPlanet(
            @Auth Long userId,
            @PathVariable Long planetId
    ) {
        return ResponseEntity.ok(reviewService.findReviewByPlanet(userId, planetId));
    }
}

