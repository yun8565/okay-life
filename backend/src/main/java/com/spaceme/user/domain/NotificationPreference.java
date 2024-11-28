package com.spaceme.user.domain;

import com.spaceme.common.exception.BadRequestException;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.util.Arrays;

@Getter
@RequiredArgsConstructor
public enum NotificationPreference {
    OFF("알림 수신 거부"),
    HOUR_0("00:00"),
    HOUR_1("01:00"),
    HOUR_2("02:00"),
    HOUR_3("03:00"),
    HOUR_4("04:00"),
    HOUR_5("05:00"),
    HOUR_6("06:00"),
    HOUR_7("07:00"),
    HOUR_8("08:00"),
    HOUR_9("09:00"),
    HOUR_10("10:00"),
    HOUR_11("11:00"),
    HOUR_12("12:00"),
    HOUR_13("13:00"),
    HOUR_14("14:00"),
    HOUR_15("15:00"),
    HOUR_16("16:00"),
    HOUR_17("17:00"),
    HOUR_18("18:00"),
    HOUR_19("19:00"),
    HOUR_20("20:00"),
    HOUR_21("21:00"),
    HOUR_22("22:00"),
    HOUR_23("23:00");

    private final String description;

    public static NotificationPreference from(String preferredHour) {
        return Arrays.stream(values())
                .filter(it -> it.description.equals(preferredHour))
                .findFirst()
                .orElseThrow(() -> new BadRequestException("알림 수신 희망 시간 설정 과정에서 오류가 발생했습니다."));
    }
}
