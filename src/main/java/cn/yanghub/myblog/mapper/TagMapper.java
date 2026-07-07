package cn.yanghub.myblog.mapper;

import cn.yanghub.myblog.entity.Tag;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface TagMapper extends BaseMapper<Tag> {

    List<Tag> selectHotTags(@Param("limit") Integer limit);

    List<Tag> selectFeaturedTags(@Param("limit") Integer limit);

    List<Tag> selectTagsByPostId(@Param("postId") Long postId);
}
