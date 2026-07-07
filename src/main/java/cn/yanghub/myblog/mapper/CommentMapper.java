package cn.yanghub.myblog.mapper;

import cn.yanghub.myblog.entity.Comment;
import cn.yanghub.myblog.vo.CommentVO;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface CommentMapper extends BaseMapper<Comment> {

    @Select("SELECT c.*, u.nickname, u.avatar_url AS avatarUrl " +
            "FROM comments c " +
            "LEFT JOIN users u ON c.user_id = u.id " +
            "WHERE c.post_id = #{postId} AND c.status = 'approved' " +
            "ORDER BY c.created_at ASC")
    List<CommentVO> selectCommentsByPostId(@Param("postId") Long postId);

    @Select("SELECT c.*, u.nickname, u.avatar_url AS avatarUrl " +
            "FROM comments c " +
            "LEFT JOIN users u ON c.user_id = u.id " +
            "WHERE c.id = #{id}")
    CommentVO selectCommentVOById(@Param("id") Long id);
}
