package com.spaceme.auth.domain;

import com.spaceme.common.exception.InternalServerException;
import org.springframework.http.HttpHeaders;
import org.springframework.web.client.RestClient;

public abstract class OauthClient {

    public static final RestClient restClient = RestClient.create();

    public abstract String getUserInfoUri();

    public abstract ProviderType getType();

    public abstract Class<? extends OauthUser> getUserClass();

    public OauthUser requestUserInfo(String accessToken) {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);

        return fetchUserInfo(headers);
    }

    private OauthUser fetchUserInfo(HttpHeaders headers) {
        return restClient.get()
                .uri(getUserInfoUri())
                .headers(httpHeaders -> httpHeaders.addAll(headers))
                .retrieve()
                .onStatus(status -> !status.is2xxSuccessful(), (request, response) -> {
                    throw new InternalServerException(getType() + "{} 유저 정보 불러오기에 실패했습니다.");
                })
                .body(getUserClass());
    }
}
