package com.spaceme.user.repository;

import com.spaceme.auth.domain.ProviderType;
import com.spaceme.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmailAndAuthType(String email, ProviderType authType);
}
