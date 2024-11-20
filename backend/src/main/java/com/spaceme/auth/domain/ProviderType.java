package com.spaceme.auth.domain;

import com.spaceme.common.exception.NotFoundException;
import java.util.Arrays;

public enum ProviderType {
    KAKAO,
    APPLE;

    public static ProviderType from(String type) {
        return Arrays.stream(values())
                .filter(providerType -> providerType.name().equals(type.toUpperCase()))
                .findFirst()
                .orElseThrow(() -> new NotFoundException("지원하지 않는 로그인 방식입니다."));
    }
}
