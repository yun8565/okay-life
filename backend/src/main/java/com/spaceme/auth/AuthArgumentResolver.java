package com.spaceme.auth;

import com.spaceme.auth.domain.Auth;
import com.spaceme.auth.service.JwtProvider;
import com.spaceme.common.exception.BadRequestException;
import com.spaceme.common.exception.UnauthorizedException;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.core.MethodParameter;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

import java.util.Optional;

import static org.springframework.http.HttpHeaders.AUTHORIZATION;

@Component
@RequiredArgsConstructor
public class AuthArgumentResolver implements HandlerMethodArgumentResolver {

    private static final String BEARER_TYPE = "Bearer ";

    private final JwtProvider jwtProvider;

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(Auth.class);
    }

    @Override
    public Long resolveArgument(
            MethodParameter parameter,
            ModelAndViewContainer mavContainer,
            NativeWebRequest webRequest,
            WebDataBinderFactory binderFactory
    ) {
        HttpServletRequest request = Optional.ofNullable(webRequest.getNativeRequest(HttpServletRequest.class))
                .orElseThrow(() -> new BadRequestException("요청이 유효하지 않습니다."));

        String accessToken = extractAccessToken(request.getHeader(AUTHORIZATION));
        jwtProvider.validateToken(accessToken);

        return Long.valueOf(jwtProvider.getSubject(accessToken));
    }

    private String extractAccessToken(String header) {
        if(StringUtils.hasText(header) && header.startsWith(BEARER_TYPE)) {
            return header.substring(BEARER_TYPE.length()).trim();
        }
        throw new UnauthorizedException("엑세스 토큰이 유효하지 않습니다.");
    }
}
