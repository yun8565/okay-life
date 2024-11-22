package com.spaceme.auth.infrastructure;

import com.spaceme.auth.domain.OauthClient;
import com.spaceme.auth.domain.OauthUser;
import com.spaceme.auth.domain.ProviderType;
import com.spaceme.auth.infrastructure.dto.KakaoUserInfo;
import com.spaceme.common.exception.InternalServerException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class KakaoOauthClient implements OauthClient {

    private static final String USER_INFO_URI = "https://kapi.kakao.com/v2/user/me";

    @Override
    public ProviderType getType() {
        return ProviderType.KAKAO;
    }

    @Override
    public OauthUser requestUserInfo(String accessToken) {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);

        return fetchUserInfo(headers);
    }

    private OauthUser fetchUserInfo(HttpHeaders headers) {
        return restClient.get()
                .uri(USER_INFO_URI)
                .headers(httpHeaders -> httpHeaders.addAll(headers))
                .retrieve()
                .onStatus(status -> !status.is2xxSuccessful(), (request, response) -> {
                    throw new InternalServerException("카카오 유저 정보 불러오기에 실패했습니다.");
                })
                .body(KakaoUserInfo.class);
    }
}
