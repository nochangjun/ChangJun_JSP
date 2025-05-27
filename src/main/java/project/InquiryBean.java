package project;

import java.sql.Timestamp;

public class InquiryBean {
    private int inq_id;
    private String inq_type;
    private String inq_title;
    private String inq_content;
    private Timestamp inq_create_at;
    private String inq_status;
    private String member_id;

    // 추가 정보 표시용 (작성자 이름, 이메일 등)
    private String member_name;
    private String member_email;
    private String member_phone;
    private String member_nickname;

    public int getInq_id() {
        return inq_id;
    }

    public void setInq_id(int inq_id) {
        this.inq_id = inq_id;
    }

    public String getInq_type() {
        return inq_type;
    }

    public void setInq_type(String inq_type) {
        this.inq_type = inq_type;
    }

    public String getInq_title() {
        return inq_title;
    }

    public void setInq_title(String inq_title) {
        this.inq_title = inq_title;
    }

    public String getInq_content() {
        return inq_content;
    }

    public void setInq_content(String inq_content) {
        this.inq_content = inq_content;
    }


    public Timestamp getInq_create_at() {
		return inq_create_at;
	}

	public void setInq_create_at(Timestamp inq_create_at) {
		this.inq_create_at = inq_create_at;
	}

	public String getInq_status() {
        return inq_status;
    }

    public void setInq_status(String inq_status) {
        this.inq_status = inq_status;
    }

    public String getMember_id() {
        return member_id;
    }

    public void setMember_id(String member_id) {
        this.member_id = member_id;
    }

    public String getMember_name() {
        return member_name;
    }

    public void setMember_name(String member_name) {
        this.member_name = member_name;
    }

    public String getMember_email() {
        return member_email;
    }

    public void setMember_email(String member_email) {
        this.member_email = member_email;
    }

    public String getMember_phone() {
        return member_phone;
    }

    public void setMember_phone(String member_phone) {
        this.member_phone = member_phone;
    }
    
	public String getMember_nickname() {
		return member_nickname;
	}

	public void setMember_nickname(String member_nickname) {
		this.member_nickname = member_nickname;
	}
}
