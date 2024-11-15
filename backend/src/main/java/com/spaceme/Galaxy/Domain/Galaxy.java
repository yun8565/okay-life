package com.spaceme.Galaxy.Domain;

import com.spaceme.Planet.Domain.Planet;
import com.spaceme.User.Domain.User;
import jakarta.persistence.*;

import java.util.Date;
import java.util.List;

@Entity
public class Galaxy {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "galaxy_id")
    private Long galaxy_id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user_id;

    @ManyToOne
    @JoinColumn(name = "galaxy_theme_id")
    private GalaxyTheme galaxy_theme_id;

    private String title;
    private Date start_date;
    private Date end_date;

    @OneToMany(mappedBy = "galaxy")
    private List<Planet> planets;
}
