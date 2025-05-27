package project;

public class MemberBean {
	
	private String member_id;
	private String member_pwd;
	private String member_name;
	private String member_phone;
	private String member_email;
	private String member_nickname;
	private String member_image;
	private String member_create_at;
	private String member_role;

	private int review_count; //db에 저장X
	
	public MemberBean() {}
	
	public MemberBean(String member_id, String member_pwd, String member_name, String member_phone,	String member_email, 
			String member_nickname, String member_image, String member_create_at, String member_role, int review_count)
	{
		this.member_id = member_id;
		this.member_pwd = member_pwd;
		this.member_name = member_name;
		this.member_phone = member_phone;
		this.member_email = member_email;
		this.member_nickname = member_nickname;
		this.member_image = member_image;
		this.member_create_at = member_create_at;	
		this.member_role = member_role;
		this.review_count = review_count;
	}
	
	public String getMember_id() {
		return member_id;
	}
	public void setMember_id(String member_id) {
		this.member_id = member_id;
	}
	public String getMember_pwd() {
		return member_pwd;
	}
	public void setMember_pwd(String member_pwd) {
		this.member_pwd = member_pwd;
	}
	public String getMember_name() {
		return member_name;
	}
	public void setMember_name(String member_name) {
		this.member_name = member_name;
	}
	public String getMember_phone() {
		return member_phone;
	}
	public void setMember_phone(String member_phone) {
		this.member_phone = member_phone;
	}
	public String getMember_email() {
		return member_email;
	}
	public void setMember_email(String member_email) {
		this.member_email = member_email;
	}
	public String getMember_nickname() {
		return member_nickname;
	}
	public void setMember_nickname(String member_nickname) {
		this.member_nickname = member_nickname;
	}
	public String getMember_image() {
		return member_image;
	}
	public void setMember_image(String member_image) {
		this.member_image = member_image;
	}
	public String getMember_create_at() {
		return member_create_at;
	}
	public void setMember_create_at(String member_create_at) {
		this.member_create_at = member_create_at;
	}
	public String getMember_role() {
		return member_role;
	}
	public void setMember_role(String member_role) {
		this.member_role = member_role;
	}
	

	public int getReview_count() {
	    return review_count;
	}

	public void setReview_count(int review_count) {
	    this.review_count = review_count;
	}

	
}
