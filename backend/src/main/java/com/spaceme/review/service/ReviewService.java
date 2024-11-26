package com.spaceme.review.service;

import com.spaceme.common.exception.NotFoundException;
import com.spaceme.planet.domain.Planet;
import com.spaceme.planet.repository.PlanetRepository;
import com.spaceme.review.domain.Review;
import com.spaceme.review.dto.request.ReviewRequest;
import com.spaceme.review.repository.ReviewRepository;
import com.spaceme.user.domain.User;
import com.spaceme.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final UserRepository userRepository;
    private final ReviewRepository reviewRepository;
    private final PlanetRepository planetRepository;

    public void saveReview(Long userId, ReviewRequest reviewRequest) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("유저를 찾을 수 없습니다."));

        Planet planet = planetRepository.findById(reviewRequest.planetId())
                .orElseThrow(() -> new NotFoundException("행성을 찾을 수 없습니다"));

        Review review = Review.builder()
                .user(user)
                .keep(reviewRequest.keep())
                .problem(reviewRequest.problem())
                .tryNext(reviewRequest.tryNext())
                .planet(planet)
                .build();

        reviewRepository.save(review);
    }
}
