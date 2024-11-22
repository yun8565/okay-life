package com.spaceme.collection.service;

import com.spaceme.collection.domain.GalaxyTheme;
import com.spaceme.collection.domain.PlanetTheme;
import com.spaceme.collection.repository.GalaxyThemeRepository;
import com.spaceme.collection.repository.PlanetThemeRepository;
import com.spaceme.common.exception.InternalServerException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Random;
import java.util.function.Function;
import java.util.function.Supplier;

@Service
@RequiredArgsConstructor
public class DynamicProbabilityGenerator {

    private final GalaxyThemeRepository galaxyThemeRepository;
    private final PlanetThemeRepository planetThemeRepository;
    private final Random random = new Random();

    private <T> T getRandomTheme(int totalWeight, Supplier<List<T>> themeSupplier, Function<T, Integer> weightFunction) {
        List<T> themes = themeSupplier.get();

        if (totalWeight == 0)
            throw new InternalServerException("테마에 저장된 가중치 정보가 없습니다.");

        int randomValue = random.nextInt(totalWeight) + 1;

        return themes.stream()
                .reduce((selected, next) -> {
                    int cumulativeWeight = weightFunction.apply(selected) + weightFunction.apply(next);
                    return randomValue <= cumulativeWeight ? next : selected;
                })
                .orElseThrow(() -> new InternalServerException("테마를 선택하는 과정에서 오류가 발생했습니다."));
    }

    public GalaxyTheme getRandomGalaxyTheme() {
        return getRandomTheme(
                galaxyThemeRepository.getTotalWeight(),
                galaxyThemeRepository::findAll,
                GalaxyTheme::getWeight
        );
    }

    public PlanetTheme getRandomPlanetTheme() {
        return getRandomTheme(
                planetThemeRepository.getTotalWeight(),
                planetThemeRepository::findAll,
                PlanetTheme::getWeight
        );
    }
}
