package com.spaceme.auth.infrastructure;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "oauth2.kakao")
public record KakaoProperties(
    String grantType,
    String clientId,
    String tokenUri,
    String userInfoUri,
    String redirectUri
) {

}
