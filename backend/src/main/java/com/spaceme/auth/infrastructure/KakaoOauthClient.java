package com.spaceme.auth.infrastructure;

import com.spaceme.auth.domain.OauthClient;
import com.spaceme.auth.domain.OauthUser;
import com.spaceme.auth.domain.ProviderType;
import com.spaceme.auth.infrastructure.dto.KakaoTokenResponse;
import com.spaceme.auth.infrastructure.dto.KakaoUserInfo;
import com.spaceme.common.exception.InternalServerException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.BodyInserters;

import java.util.Optional;

import static org.springframework.http.MediaType.APPLICATION_FORM_URLENCODED;

@Component
@RequiredArgsConstructor
public class KakaoOauthClient implements OauthClient {

    private final KakaoProperties properties;

    @Override
    public ProviderType getType() {
        return ProviderType.KAKAO;
    }

    @Override
    public OauthUser requestUserInfo(String authorizationCode) {
        String accessToken = requestAccessToken(authorizationCode);

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);

        return fetchUserInfo(headers);
    }

    private OauthUser fetchUserInfo(HttpHeaders headers) {
        return restClient.get()
                .uri(properties.userInfoUri())
                .headers(httpHeaders -> httpHeaders.addAll(headers))
                .retrieve()
                .onStatus(status -> !status.is2xxSuccessful(), (request, response) -> {
                    throw new InternalServerException("카카오 유저 정보 불러오기에 실패했습니다.");
                })
                .body(KakaoUserInfo.class);
    }

    @Override
    public String requestAccessToken(String authorizationCode) {
        MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
        body.add("grant_type", properties.grantType());
        body.add("client_id", properties.clientId());
        body.add("redirect_uri", properties.redirectUri());
        body.add("code", authorizationCode);

        return fetchAccessToken(body);
    }

    private String fetchAccessToken(MultiValueMap<String, String> body) {
        return Optional.ofNullable(restClient.post()
                        .uri(properties.tokenUri())
                        .contentType(APPLICATION_FORM_URLENCODED)
                        .body(BodyInserters.fromFormData(body))
                        .retrieve()
                        .onStatus(status -> !status.is2xxSuccessful(), (request, response) -> {
                            throw new InternalServerException("카카오 토큰 발급에 실패했습니다.");
                        })
                        .body(KakaoTokenResponse.class))
                .orElseThrow(() -> new InternalServerException("카카오 토큰 발급에 실패했습니다."))
                .getAccessToken();
    }
}
