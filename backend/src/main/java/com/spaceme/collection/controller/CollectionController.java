package com.spaceme.collection.controller;

import com.spaceme.auth.domain.Auth;
import com.spaceme.collection.dto.GalaxyThemeResponse;
import com.spaceme.collection.service.CollectionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("/collections")
public class CollectionController {

    private final CollectionService collectionService;

    @GetMapping
    public ResponseEntity<List<GalaxyThemeResponse>> getThemeCollection(@Auth Long userId) {
        return ResponseEntity.ok(collectionService.getThemeCollection(userId));
    }
}
