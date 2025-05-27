package project;

public class BoardBean {
    private int board_id;
    private String board_title;
    private String board_content;
    private String board_at;
    private String member_id;
    private int board_views;  // Changed from view_count to match table
    private Integer board_like;  // Added field from table (nullable)
    
    // 추가 필드
    private String member_nickname;
    private int comment_count;

    // --- Getter / Setter ---
    public int getBoard_id() {
        return board_id;
    }
    public void setBoard_id(int board_id) {
        this.board_id = board_id;
    }

    public String getBoard_title() {
        return board_title;
    }
    public void setBoard_title(String board_title) {
        this.board_title = board_title;
    }

    public String getBoard_content() {
        return board_content;
    }
    public void setBoard_content(String board_content) {
        this.board_content = board_content;
    }

    public String getBoard_at() {
        return board_at;
    }
    public void setBoard_at(String board_at) {
        this.board_at = board_at;
    }

    public String getMember_id() {
        return member_id;
    }
    public void setMember_id(String member_id) {
        this.member_id = member_id;
    }
    
    public int getBoard_views() {
        return board_views;
    }
    public void setBoard_views(int board_views) {
        this.board_views = board_views;
    }
    
    public Integer getBoard_like() {
        return board_like;
    }
    public void setBoard_like(Integer board_like) {
        this.board_like = board_like;
    }
    
    public String getMember_nickname() {
        return member_nickname;
    }
    public void setMember_nickname(String member_nickname) {
        this.member_nickname = member_nickname;
    }
    
    public int getComment_count() {
        return comment_count;
    }
    public void setComment_count(int comment_count) {
        this.comment_count = comment_count;
    }
}