package com.spaceme.user.domain;

import com.spaceme.common.exception.BadRequestException;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.util.Arrays;

@Getter
@RequiredArgsConstructor
public enum NotificationPreference {
    OFF(-1),
    HOUR_0(0),
    HOUR_1(1),
    HOUR_2(2),
    HOUR_3(3),
    HOUR_4(4),
    HOUR_5(5),
    HOUR_6(6),
    HOUR_7(7),
    HOUR_8(8),
    HOUR_9(9),
    HOUR_10(10),
    HOUR_11(11),
    HOUR_12(12),
    HOUR_13(13),
    HOUR_14(14),
    HOUR_15(15),
    HOUR_16(16),
    HOUR_17(17),
    HOUR_18(18),
    HOUR_19(19),
    HOUR_20(20),
    HOUR_21(21),
    HOUR_22(22),
    HOUR_23(23);

    private final int hour;

    public static NotificationPreference from(int preferredHour) {
        return Arrays.stream(values())
                .filter(it -> it.hour == preferredHour)
                .findFirst()
                .orElseThrow(() -> new BadRequestException("알림 수신 희망 시간 설정 과정에서 오류가 발생했습니다."));
    }
}
