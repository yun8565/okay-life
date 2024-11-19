package com.spaceme.galaxy.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
public class GalaxyDTO {
    private Long galaxyId;
    private String userId;
    private Long galaxyThemeId;
    private String title;
    private Date startDate;
    private Date endDate;
}
