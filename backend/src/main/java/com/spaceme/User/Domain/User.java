package com.spaceme.user.domain;

import com.spaceme.auth.domain.ProviderType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    private String nickname;

    private String deviceToken;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProviderType authType;
}
