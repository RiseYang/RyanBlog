package cn.yanghub.myblog.mapper;

import cn.yanghub.myblog.entity.Post;
import cn.yanghub.myblog.vo.PostVO;
import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Constants;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface PostMapper extends BaseMapper<Post> {

    @Select("SELECT p.*, u.nickname as authorName, u.avatar_url as authorAvatar, " +
            "c.name as categoryName, c.slug as categorySlug, c.color as categoryColor " +
            "FROM posts p " +
            "LEFT JOIN users u ON p.author_id = u.id " +
            "LEFT JOIN categories c ON p.category_id = c.id " +
            "WHERE p.id = #{id} AND p.deleted_at IS NULL")
    PostVO selectPostVOById(Long id);

    @Select("SELECT p.*, u.nickname as authorName, u.avatar_url as authorAvatar, " +
            "c.name as categoryName, c.slug as categorySlug, c.color as categoryColor " +
            "FROM posts p " +
            "LEFT JOIN users u ON p.author_id = u.id " +
            "LEFT JOIN categories c ON p.category_id = c.id " +
            "WHERE p.slug = #{slug} AND p.status = 'published' " +
            "AND (p.visibility = 'public' OR p.visibility IS NULL) AND p.deleted_at IS NULL")
    PostVO selectPostVOBySlug(String slug);

    int countBySlug(@Param("slug") String slug, @Param("excludeId") Long excludeId);

    @Insert("INSERT INTO post_tags (post_id, tag_id) VALUES (#{postId}, #{tagId})")
    int insertPostTag(@Param("postId") Long postId, @Param("tagId") Long tagId);

    @Delete("DELETE FROM post_tags WHERE post_id = #{postId}")
    int deletePostTags(@Param("postId") Long postId);

    IPage<PostVO> selectPostVOPage(IPage<PostVO> page, @Param(Constants.WRAPPER) Wrapper<Post> wrapper);

    List<PostVO> selectFeaturedPosts(@Param("limit") Integer limit);

    List<PostVO> selectTopPosts(@Param("limit") Integer limit);

    void incrementViewCount(@Param("id") Long id);

    void incrementLikeCount(@Param("id") Long id);

    void incrementCommentCount(@Param("id") Long id);

    void decrementCommentCount(@Param("id") Long id);
}
