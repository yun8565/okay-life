package com.spaceme.auth.infrastructure.google;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.spaceme.auth.domain.OauthUser;

@JsonIgnoreProperties(ignoreUnknown = true)
public class GoogleUserInfo implements OauthUser {

    @JsonProperty("email")
    private String email;

    @JsonProperty("name")
    private String name;

    @Override
    public String nickname() {
        return name;
    }

    @Override
    public String email() {
        return email;
    }
}
