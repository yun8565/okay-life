package com.spaceme.auth.service;

import com.spaceme.auth.domain.OauthClient;
import com.spaceme.auth.domain.OauthProviderComposite;
import com.spaceme.auth.domain.OauthUser;
import com.spaceme.auth.domain.ProviderType;
import com.spaceme.auth.dto.request.LoginRequest;
import com.spaceme.auth.dto.response.AccessTokenResponse;
import com.spaceme.user.domain.User;
import com.spaceme.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class AuthService {

    private final UserRepository userRepository;
    private final OauthProviderComposite oauthProviderComposite;
    private final JwtProvider jwtProvider;

    public AccessTokenResponse login(String providerType, LoginRequest loginRequest) {
        OauthClient provider = oauthProviderComposite.matchProvider(providerType);
        OauthUser oauthUser = provider.requestUserInfo(loginRequest.accessToken());
      
        User user = findOrRegister(
                oauthUser.email(),
                oauthUser.nickname(),
                ProviderType.from(providerType)
        );

        return AccessTokenResponse.of(jwtProvider.createToken(user.getId().toString()));
    }

    private User findOrRegister(String email, String nickname, ProviderType providerType) {
        return userRepository.findByEmailAndAuthType(email, providerType)
                .orElseGet(() -> registerUser(email, nickname, providerType));
    }

    private User registerUser(String email, String nickname, ProviderType providerType) {
        User user = User.builder()
                .email(email)
                .nickname(nickname)
                .authType(providerType)
                .build();

        return userRepository.save(user);
    }
}
