package cn.yanghub.myblog.service;

import cn.yanghub.myblog.vo.LikeState;

public interface LikeService {
    LikeState getPostLike(Long postId, String clientId);

    LikeState togglePostLike(Long postId, String clientId);

    LikeState getPageLike(String pageKey, String clientId);

    LikeState togglePageLike(String pageKey, String clientId);
}
