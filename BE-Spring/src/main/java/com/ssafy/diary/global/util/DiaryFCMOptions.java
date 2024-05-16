package com.ssafy.diary.global.util;

import lombok.Builder;
import lombok.Getter;

@Getter
public class DiaryFCMOptions {
    private String tag;
    private Long androidTtlSec;
    private Boolean renotify;
    @Builder
    public DiaryFCMOptions(Long androidTtlSec, Boolean renotify, String tag) {
        this.androidTtlSec = androidTtlSec;
        this.renotify = renotify;
        this.tag=tag;
    }

}
