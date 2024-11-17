package com.spaceme.Galaxy.Service;

import com.spaceme.Galaxy.DTO.GalaxyDTO;
import com.spaceme.Galaxy.Domain.Galaxy;
import com.spaceme.Galaxy.Domain.GalaxyTheme;
import com.spaceme.Galaxy.Repository.GalaxyRepository;
import com.spaceme.User.Domain.User;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class GalaxyService {

    private final GalaxyRepository galaxyRepository;

    public GalaxyService(GalaxyRepository galaxyRepository) {
        this.galaxyRepository = galaxyRepository;
    }

    public List<GalaxyDTO> getAllGalaxies() {
        return galaxyRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<GalaxyDTO> getUserGalaxies(Long userId) {
        return galaxyRepository.findByUserId(userId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public GalaxyDTO createGalaxy(GalaxyDTO galaxyDTO) {
        Galaxy galaxy = convertToEntity(galaxyDTO);
        Galaxy savedGalaxy = galaxyRepository.save(galaxy);
        return convertToDTO(savedGalaxy);
    }

    public GalaxyDTO updateGalaxy(Long galaxyId, GalaxyDTO galaxyDTO) {
        Galaxy galaxy = galaxyRepository.findById(galaxyId)
                .orElseThrow(() -> new RuntimeException("Galaxy not found"));
        galaxy.setTitle(galaxyDTO.getTitle());
        galaxy.setStartDate(galaxyDTO.getStartDate());
        galaxy.setEndDate(galaxyDTO.getEndDate());
        Galaxy updatedGalaxy = galaxyRepository.save(galaxy);
        return convertToDTO(updatedGalaxy);
    }

    public void deleteGalaxy(Long galaxyId) {
        galaxyRepository.deleteById(galaxyId);
    }

    private GalaxyDTO convertToDTO(Galaxy galaxy) {
        GalaxyDTO galaxyDTO = new GalaxyDTO();
        galaxyDTO.setGalaxyId(galaxy.getGalaxyId());
        galaxyDTO.setUserId(galaxy.getUserId().getUserId()); // User 엔티티의 ID 추출
        galaxyDTO.setGalaxyThemeId(galaxy.getGalaxyThemeId().getGalaxyThemeId()); // GalaxyTheme 엔티티의 ID 추출
        galaxyDTO.setTitle(galaxy.getTitle());
        galaxyDTO.setStartDate(galaxy.getStartDate());
        galaxyDTO.setEndDate(galaxy.getEndDate());
        return galaxyDTO;
    }

    private Galaxy convertToEntity(GalaxyDTO galaxyDTO) {
        Galaxy galaxy = new Galaxy();
        galaxy.setTitle(galaxyDTO.getTitle());
        galaxy.setStartDate(galaxyDTO.getStartDate());
        galaxy.setEndDate(galaxyDTO.getEndDate());

        User user = new User(); // UserRepository 또는 Service에서 조회해야 함
        user.setUserId(galaxyDTO.getUserId());
        galaxy.setUserId(user);

        GalaxyTheme galaxyTheme = new GalaxyTheme(); // GalaxyThemeRepository에서 조회 필요
        galaxyTheme.setGalaxyThemeId(galaxyDTO.getGalaxyThemeId());
        galaxy.setGalaxyThemeId(galaxyTheme);
        return galaxy;
    }
}
