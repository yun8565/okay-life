package com.spaceme.auth.domain;

import org.springframework.web.client.RestClient;

public interface OauthClient {
    RestClient restClient = RestClient.create();

    ProviderType getType();

    OauthUser requestUserInfo(String accessToken);
}
