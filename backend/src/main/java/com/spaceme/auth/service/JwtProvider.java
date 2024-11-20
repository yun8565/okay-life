package com.spaceme.auth.service;

import com.spaceme.common.exception.UnauthorizedException;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import javax.crypto.SecretKey;
import java.util.Date;

import static java.nio.charset.StandardCharsets.UTF_8;

@Component
public class JwtProvider {

    private final SecretKey secretKey;
    private final Long accessExpiration;
    private final Long refreshExpiration;

    public JwtProvider(
            @Value("${security.jwt.secret-key}") final String secretKey,
            @Value("${security.jwt.access-expiration}") final Long accessExpiration,
            @Value("${security.jwt.refresh-expiration}") final Long refreshExpiration
    ) {
        this.secretKey = Keys.hmacShaKeyFor(secretKey.getBytes(UTF_8));
        this.accessExpiration = accessExpiration;
        this.refreshExpiration = refreshExpiration;
    }

    public String createToken(final String subject) {
        Date now = new Date();
        Date expiration = new Date(now.getTime() + accessExpiration);

        return Jwts.builder()
                .setSubject(subject)
                .setIssuedAt(now)
                .setExpiration(expiration)
                .signWith(secretKey, SignatureAlgorithm.HS256)
                .compact();
    }

    public void validateToken(String token) {
        try {
            parseToken(token);
        } catch (ExpiredJwtException e) {
            throw new UnauthorizedException("토큰 기한이 만료되었습니다.");
        } catch (JwtException | IllegalArgumentException e) {
            throw new UnauthorizedException("올바르지 않은 형식의 토큰입니다.");
        }
    }

    public String getSubject(String token) {
        return parseToken(token)
                .getBody()
                .getSubject();
    }

    private Jws<Claims> parseToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(secretKey)
                .build()
                .parseClaimsJws(token);
    }
}
