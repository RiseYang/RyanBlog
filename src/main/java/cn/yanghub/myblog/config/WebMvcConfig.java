package cn.yanghub.myblog.config;

import cn.yanghub.myblog.entity.Post;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;
import org.springframework.format.FormatterRegistry;
import org.springframework.lang.NonNull;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addFormatters(FormatterRegistry registry) {
        registry.addConverter(new StringToPostStatusConverter());
        registry.addConverter(new StringToVisibilityConverter());
    }

    private static class StringToPostStatusConverter implements Converter<String, Post.PostStatus> {
        @Override
        public Post.PostStatus convert(@NonNull String source) {
            return Post.PostStatus.fromValue(source);
        }
    }

    private static class StringToVisibilityConverter implements Converter<String, Post.Visibility> {
        @Override
        public Post.Visibility convert(@NonNull String source) {
            return Post.Visibility.fromValue(source);
        }
    }
}
