package com.spaceme.review.controller;

import com.spaceme.auth.domain.Auth;
import com.spaceme.review.dto.request.ReviewRequest;
import com.spaceme.review.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
}

