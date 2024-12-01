package com.spaceme.review.service;

import com.spaceme.common.exception.NotFoundException;
import com.spaceme.planet.domain.Planet;
import com.spaceme.planet.repository.PlanetRepository;
import com.spaceme.review.domain.Review;
import com.spaceme.review.dto.request.ReviewRequest;
import com.spaceme.review.dto.response.ReviewPlanetResponse;
import com.spaceme.review.dto.response.ReviewResponse;
import com.spaceme.review.repository.ReviewRepository;
import com.spaceme.user.domain.User;
import com.spaceme.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReviewService {

    private final UserRepository userRepository;
    private final ReviewRepository reviewRepository;
    private final PlanetRepository planetRepository;

    @Transactional
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

    public List<ReviewPlanetResponse> findCompletedPlanets(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("유저를 찾을 수 없습니다."));

        return reviewRepository.findByUser(user).stream()
                .map(Review::getPlanet)
                .filter(planet -> planet.getStatus() != null && planet.getStatus().isPast())
                .map(planet -> new ReviewPlanetResponse(
                        planet.getTitle(),
                        planet.getId(),
                        planet.getPlanetTheme().getName(),
                        planet.getStatus()
                ))
                .collect(Collectors.toList());
    }

    public ReviewResponse findReviewByPlanet(Long userId, Long planetId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("유저를 찾을 수 없습니다."));

        Review review = reviewRepository.findByUserAndPlanetId(user, planetId)
                .orElseThrow(() -> new NotFoundException("해당 유저의 리뷰를 찾을 수 없습니다."));

        Planet planet = planetRepository.findById(planetId)
                .orElseThrow(() -> new NotFoundException("해당 행성을 찾을 수 없습니다."));

        return new ReviewResponse(
                planet.getTitle(),
                review.getKeep(),
                review.getProblem(),
                review.getTryNext()
        );
    }
}
