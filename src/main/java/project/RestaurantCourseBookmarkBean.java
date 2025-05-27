package project;

public class RestaurantCourseBookmarkBean {
	private int course_bookmark_id;
	private String course_bookmark_at;
	private String member_id;
	private int course_id;

	public int getCourse_bookmark_id() {
		return course_bookmark_id;
	}

	public void setCourse_bookmark_id(int course_bookmark_id) {
		this.course_bookmark_id = course_bookmark_id;
	}

	public String getCourse_bookmark_at() {
		return course_bookmark_at;
	}

	public void setCourse_bookmark_at(String course_bookmark_at) {
		this.course_bookmark_at = course_bookmark_at;
	}

	public String getMember_id() {
		return member_id;
	}

	public void setMember_id(String member_id) {
		this.member_id = member_id;
	}

	public int getCourse_id() {
		return course_id;
	}

	public void setCourse_id(int course_id) {
		this.course_id = course_id;
	}
}
