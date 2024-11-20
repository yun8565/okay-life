package com.spaceme.auth.domain;

import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Set;

import static java.util.function.Function.identity;
import static java.util.stream.Collectors.toMap;

@Component
public class OauthProviderComposite {

    private final Map<ProviderType, OauthClient> providers;

    public OauthProviderComposite(Set<OauthClient> providers) {
        this.providers = providers.stream()
                .collect(toMap(OauthClient::getType, identity()));
    }

    public OauthClient matchProvider(String providerType) {
        return providers.get(ProviderType.from(providerType));
    }
}
