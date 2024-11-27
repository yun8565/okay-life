package com.spaceme.notification;

import com.spaceme.common.exception.BadRequestException;
import com.spaceme.notification.domain.Device;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.core.MethodParameter;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class FCMArgumentResolver implements HandlerMethodArgumentResolver {

    private final static String DEVICE = "X-Auth-Token";

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(Device.class);
    }

    @Override
    public String resolveArgument(
            MethodParameter parameter,
            ModelAndViewContainer mavContainer,
            NativeWebRequest webRequest,
            WebDataBinderFactory binderFactory
    ) {
        HttpServletRequest request = Optional.ofNullable(webRequest.getNativeRequest(HttpServletRequest.class))
                .orElseThrow(() -> new BadRequestException("요청이 유효하지 않습니다."));

        String deviceToken = Optional.ofNullable(request.getHeader(DEVICE))
                .orElseThrow(() -> new BadRequestException("FCM 토큰 헤더가 누락되었습니다."));

        return deviceToken;
    }
}
