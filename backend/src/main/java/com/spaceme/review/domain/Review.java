package com.spaceme.review.domain;

import com.spaceme.planet.domain.Planet;
import com.spaceme.user.domain.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class Review {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    private User user;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(unique = true)
    private Planet planet;

    @Column(nullable = false)
    private String keep;

    @Column(nullable = false)
    private String problem;

    @Column(nullable = false)
    private String tryNext;

    @Override
    public String toString() {
        return "Keep: "+keep+", Problem: "+problem+", Try: "+tryNext;
    }
}
