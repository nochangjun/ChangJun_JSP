package project;

import java.sql.Timestamp;

public class InqCommentBean {
    private int inq_comment_id;
    private String inq_content;
    private Timestamp inq_comment_at;
    private String member_id;
    private int inq_id;

    public int getInq_comment_id() {
        return inq_comment_id;
    }

    public void setInq_comment_id(int inq_comment_id) {
        this.inq_comment_id = inq_comment_id;
    }

    public String getInq_content() {
        return inq_content;
    }

    public void setInq_content(String inq_content) {
        this.inq_content = inq_content;
    }

    public Timestamp getInq_comment_at() {
        return inq_comment_at;
    }

    public void setInq_comment_at(Timestamp inq_comment_at) {
        this.inq_comment_at = inq_comment_at;
    }

    public String getMember_id() {
        return member_id;
    }

    public void setMember_id(String member_id) {
        this.member_id = member_id;
    }

    public int getInq_id() {
        return inq_id;
    }

    public void setInq_id(int inq_id) {
        this.inq_id = inq_id;
    }
}
