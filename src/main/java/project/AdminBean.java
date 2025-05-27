package project;

public class AdminBean {
	private String admin_id;
	private String admin_pwd;
	private String admin_nickname;
	private String admin_phone;
	private String admin_email;
	private String admin_image;
	
	public AdminBean() {}
	
	public AdminBean(String admin_id, String admin_pwd, String admin_nickname, String admin_phone,
			String admin_email, String admin_image)
	{
		this.admin_id = admin_id;
		this.admin_pwd = admin_pwd;
		this.admin_nickname = admin_nickname;
		this.admin_phone = admin_phone;
		this.admin_email = admin_email;
		this.admin_image = admin_image;
	}
	
	public String getAdmin_id() {
		return admin_id;
	}
	public void setAdmin_id(String admin_id) {
		this.admin_id = admin_id;
	}
	public String getAdmin_pwd() {
		return admin_pwd;
	}
	public void setAdmin_pwd(String admin_pwd) {
		this.admin_pwd = admin_pwd;
	}
	public String getAdmin_nickname() {
		return admin_nickname;
	}
	public void setAdmin_nickname(String admin_nickname) {
		this.admin_nickname = admin_nickname;
	}
	public String getAdmin_phone() {
		return admin_phone;
	}
	public void setAdmin_phone(String admin_phone) {
		this.admin_phone = admin_phone;
	}
	public String getAdmin_email() {
		return admin_email;
	}
	public void setAdmin_email(String admin_email) {
		this.admin_email = admin_email;
	}
	public String getAdmin_image() {
		return admin_image;
	}
	public void setAdmin_image(String admin_image) {
		this.admin_image = admin_image;
	}
	
	
}
