package com.spaceme.galaxy.domain;

import com.spaceme.planet.domain.Planet;
import com.spaceme.User.Domain.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

@Entity
@Getter
@Setter
public class Galaxy {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "galaxy_id")
    private Long galaxyId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "galaxy_theme_id")
    private GalaxyTheme galaxyTheme;

    private String title;
    private Date startDate;
    private Date endDate;

}
