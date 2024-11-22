package com.spaceme.collection.domain;

import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Getter
public class PlanetTheme {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private int weight;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    private GalaxyTheme galaxyTheme;
}
