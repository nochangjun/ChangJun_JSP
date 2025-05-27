package project;

import java.sql.Timestamp;

public class CommentBean {
    private int comment_id;
    private int board_id;
    private String member_id;
    private String comment_content;
    private String comment_at;
    private int comment_like;
    private Integer parent_comment_id;
    
    // 추가 필드
    private String member_nickname;

    // 기본 생성자
    public CommentBean() {}
    
    // 댓글 작성용 생성자
    public CommentBean(int board_id, String member_id, String comment_content) {
        this.board_id = board_id;
        this.member_id = member_id;
        this.comment_content = comment_content;
        this.comment_like = 0; // 기본값 설정
    }
    
    // 대댓글 작성용 생성자
    public CommentBean(int board_id, String member_id, String comment_content, int parent_comment_id) {
        this.board_id = board_id;
        this.member_id = member_id;
        this.comment_content = comment_content;
        this.parent_comment_id = parent_comment_id;
        this.comment_like = 0; // 기본값 설정
    }

    // --- Getter / Setter ---
    public int getComment_id() {
        return comment_id;
    }
    public void setComment_id(int comment_id) {
        this.comment_id = comment_id;
    }

    public int getBoard_id() {
        return board_id;
    }
    public void setBoard_id(int board_id) {
        this.board_id = board_id;
    }

    public String getMember_id() {
        return member_id;
    }
    public void setMember_id(String member_id) {
        this.member_id = member_id;
    }

    public String getComment_content() {
        return comment_content;
    }
    public void setComment_content(String comment_content) {
        this.comment_content = comment_content;
    }

    public String getComment_at() {
        return comment_at;
    }
    public void setComment_at(String comment_at) {
        this.comment_at = comment_at;
    }
    
    public int getComment_like() {
        return comment_like;
    }
    public void setComment_like(int comment_like) {
        this.comment_like = comment_like;
    }
    
    public Integer getParent_comment_id() {
        return parent_comment_id;
    }
    public void setParent_comment_id(Integer parent_comment_id) {
        this.parent_comment_id = parent_comment_id;
    }
    
    public String getMember_nickname() {
        return member_nickname;
    }
    public void setMember_nickname(String member_nickname) {
        this.member_nickname = member_nickname;
    }
    
    @Override
    public String toString() {
        return "CommentBean [comment_id=" + comment_id + ", board_id=" + board_id + ", member_id=" + member_id 
               + ", comment_content=" + comment_content + ", comment_at=" + comment_at 
               + ", comment_like=" + comment_like + ", parent_comment_id=" + parent_comment_id 
               + ", member_nickname=" + member_nickname + "]";
    }
}