package com.spaceme.review.controller;

import com.spaceme.auth.domain.Auth;
import com.spaceme.planet.domain.Planet;
import com.spaceme.planet.dto.response.PlanetResponse;
import com.spaceme.planet.service.PlanetService;
import com.spaceme.review.dto.request.ReviewRequest;
import com.spaceme.review.dto.response.ReviewResponse;
import com.spaceme.review.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/reviews")
public class ReviewController {

    private final ReviewService reviewService;
    private final PlanetService planetService;

    @GetMapping("/{planetId}")
    public ResponseEntity<ReviewResponse> getQuestion(@PathVariable Long planetId) {
        Planet planet = planetService.getPlanetById(planetId);
        return ResponseEntity.ok(reviewService.getQuestionBasedOnRatio(planet));
    }

    @PostMapping("/answer")
    public ResponseEntity<Void> saveAnswer(@Auth Long userId, @RequestBody ReviewRequest reviewRequest) {
        reviewService.saveAnswer(userId, reviewRequest);
        return ResponseEntity.noContent().build();
    }
}

