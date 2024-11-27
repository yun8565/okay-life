package com.spaceme.auth.infrastructure.google;

import com.spaceme.auth.domain.OauthClient;
import com.spaceme.auth.domain.OauthUser;
import com.spaceme.auth.domain.ProviderType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class GoogleOauthClient extends OauthClient {

    private static final String USER_INFO_URI = "https://www.googleapis.com/userinfo/v2/me";

    @Override
    public String getUserInfoUri() {
        return USER_INFO_URI;
    }

    @Override
    public ProviderType getType() {
        return ProviderType.GOOGLE;
    }

    @Override
    public Class<? extends OauthUser> getUserClass() {
        return GoogleUserInfo.class;
    }
}
