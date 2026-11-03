DROP TRIGGER IF EXISTS `trg_comment_delete_count`;
DROP TRIGGER IF EXISTS `trg_post_tag_delete`;
DROP TRIGGER IF EXISTS `trg_post_update_category_count`;
DROP TRIGGER IF EXISTS `trg_post_delete_category_count`;

DELIMITER $$

CREATE TRIGGER `trg_comment_delete_count` AFTER DELETE ON `comments` FOR EACH ROW BEGIN
    IF OLD.status = 'approved' THEN
        UPDATE `posts` SET `comment_count` = IF(`comment_count` > 0, `comment_count` - 1, 0) WHERE `id` = OLD.post_id;
    END IF;
END$$

CREATE TRIGGER `trg_post_tag_delete` AFTER DELETE ON `post_tags` FOR EACH ROW BEGIN
    UPDATE `tags` SET `post_count` = IF(`post_count` > 0, `post_count` - 1, 0) WHERE `id` = OLD.tag_id;
END$$

CREATE TRIGGER `trg_post_update_category_count` AFTER UPDATE ON `posts` FOR EACH ROW BEGIN
    IF OLD.status != 'published' AND NEW.status = 'published' THEN
        IF NEW.category_id IS NOT NULL THEN
            UPDATE `categories` SET `post_count` = `post_count` + 1 WHERE `id` = NEW.category_id;
        END IF;
    ELSEIF OLD.status = 'published' AND NEW.status != 'published' THEN
        IF OLD.category_id IS NOT NULL THEN
            UPDATE `categories` SET `post_count` = IF(`post_count` > 0, `post_count` - 1, 0) WHERE `id` = OLD.category_id;
        END IF;
    ELSEIF OLD.status = 'published' AND NEW.status = 'published' AND NOT (OLD.category_id <=> NEW.category_id) THEN
        IF OLD.category_id IS NOT NULL THEN
            UPDATE `categories` SET `post_count` = IF(`post_count` > 0, `post_count` - 1, 0) WHERE `id` = OLD.category_id;
        END IF;
        IF NEW.category_id IS NOT NULL THEN
            UPDATE `categories` SET `post_count` = `post_count` + 1 WHERE `id` = NEW.category_id;
        END IF;
    END IF;
END$$

CREATE TRIGGER `trg_post_delete_category_count` AFTER DELETE ON `posts` FOR EACH ROW BEGIN
    IF OLD.category_id IS NOT NULL AND OLD.status = 'published' THEN
        UPDATE `categories` SET `post_count` = IF(`post_count` > 0, `post_count` - 1, 0) WHERE `id` = OLD.category_id;
    END IF;
END$$

DELIMITER ;
