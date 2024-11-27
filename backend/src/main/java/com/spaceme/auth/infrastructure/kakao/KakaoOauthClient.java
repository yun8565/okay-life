package com.spaceme.auth.infrastructure.kakao;

import com.spaceme.auth.domain.OauthClient;
import com.spaceme.auth.domain.OauthUser;
import com.spaceme.auth.domain.ProviderType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class KakaoOauthClient extends OauthClient {

    private static final String USER_INFO_URI = "https://kapi.kakao.com/v2/user/me";

    @Override
    public String getUserInfoUri() {
        return USER_INFO_URI;
    }

    @Override
    public ProviderType getType() {
        return ProviderType.KAKAO;
    }

    @Override
    public Class<? extends OauthUser> getUserClass() {
        return KakaoUserInfo.class;
    }
}
