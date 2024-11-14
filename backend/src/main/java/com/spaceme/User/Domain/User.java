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
    private UserType user_type;

    @Enumerated(EnumType.STRING)
    @Column(name = "auth_type")
    private AuthType auth_type;

    private Long point;
    private String nickname;

    @Enumerated(EnumType.STRING)
    @Column(name = "alien_theme")
    private AlienType alien_theme;

    @OneToMany(mappedBy = "user")
    private List<Galaxy> galaxies;
}
