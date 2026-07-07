package cn.yanghub.myblog.config;

import cn.yanghub.myblog.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class UserDataInitializer {

    private final UserMapper userMapper;

    @EventListener(ApplicationReadyEvent.class)
    public void normalizeLegacyUsers() {
        int updated = userMapper.normalizeDeletedAt();
        if (updated > 0) {
            log.info("Normalized deleted_at for {} legacy user(s)", updated);
        }
    }
}
