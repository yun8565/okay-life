package com.spaceme.galaxy.domain;

import com.spaceme.collection.domain.GalaxyTheme;
import com.spaceme.user.domain.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class Galaxy {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private LocalDate startDate;

    @Column(nullable = false)
    private LocalDate endDate;

    @ElementCollection
    @Column(nullable = false)
    private List<String> days;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    private GalaxyTheme galaxyTheme;

    public void updateTitle(String title) {
        this.title = title;
    }

    public void updateGalaxyTheme(GalaxyTheme galaxyTheme) {
        this.galaxyTheme = galaxyTheme;
    }
}
