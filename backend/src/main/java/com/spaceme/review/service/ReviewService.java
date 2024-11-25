package com.spaceme.review.service;

import com.spaceme.common.exception.NotFoundException;
import com.spaceme.mission.service.MissionService;
import com.spaceme.planet.domain.Planet;
import com.spaceme.review.domain.Review;
import com.spaceme.review.dto.request.ReviewRequest;
import com.spaceme.review.dto.response.ReviewResponse;
import com.spaceme.review.repository.ReviewRepository;
import com.spaceme.user.domain.User;
import com.spaceme.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final MissionService missionService;
    private final UserRepository userRepository;
    private final ReviewRepository reviewRepository;


    public ReviewResponse getQuestionBasedOnRatio(Planet planet) {
        double clearRatio = missionService.getClearRatio(planet);
        String question;

        if (clearRatio == 1.0) {
            question = "축하합니다! 모든 미션을 완료했습니다. 다음 행성으로 이동하시겠습니까?";
        } else if (clearRatio >= 0.5) {
            question = "좋은 진행 속도입니다! 남은 미션을 완료하시겠습니까?";
        } else {
            question = "아직 미션이 많이 남아 있습니다. 미션을 시작해보세요!";
        }

        return new ReviewResponse(question);
    }

    public void saveAnswer(Long userId, ReviewRequest reviewRequest) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("유저를 찾을 수 없습니다."));

        String content = reviewRequest.answer();

        Review review = Review.builder()
                .user(user)
                .content(content)
                .build();

        reviewRepository.save(review);
    }


}
