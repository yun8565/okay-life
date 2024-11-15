package com.spaceme.User.Domain;

import com.spaceme.Galaxy.Domain.Galaxy;
import jakarta.persistence.*;


import java.util.List;

@Entity
public class User {
    @Id
    @Column(name = "user_id")
    private String userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "user_type")
    private UserType userType;

    @Enumerated(EnumType.STRING)
    @Column(name = "auth_type")
    private AuthType authType;

    private Long point;
    private String nickname;

    @Enumerated(EnumType.STRING)
    @Column(name = "alien_theme")
    private AlienType alienTheme;

    @OneToMany(mappedBy = "user")
    private List<Galaxy> galaxies;
}
