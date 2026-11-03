package cn.yanghub.myblog.controller;

import cn.yanghub.myblog.common.Result;
import cn.yanghub.myblog.dto.LikeRequest;
import cn.yanghub.myblog.service.LikeService;
import cn.yanghub.myblog.vo.LikeState;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/public/likes")
@RequiredArgsConstructor
public class LikeController {

    private final LikeService likeService;

    @GetMapping("/posts/{postId}")
    public Result<LikeState> postLike(@PathVariable Long postId,
                                      @RequestParam(required = false) String clientId) {
        return Result.success(likeService.getPostLike(postId, clientId));
    }

    @PostMapping("/posts/{postId}")
    public Result<LikeState> togglePost(@PathVariable Long postId,
                                        @RequestBody(required = false) LikeRequest request) {
        String clientId = request == null ? null : request.getClientId();
        return Result.success(likeService.togglePostLike(postId, clientId));
    }

    @GetMapping("/pages/{pageKey}")
    public Result<LikeState> pageLike(@PathVariable String pageKey,
                                      @RequestParam(required = false) String clientId) {
        return Result.success(likeService.getPageLike(pageKey, clientId));
    }

    @PostMapping("/pages/{pageKey}")
    public Result<LikeState> togglePage(@PathVariable String pageKey,
                                        @RequestBody(required = false) LikeRequest request) {
        String clientId = request == null ? null : request.getClientId();
        return Result.success(likeService.togglePageLike(pageKey, clientId));
    }
}
