package project;

public class AdminCourseBean {
	private int courseId;
    private String courseTitle;
    private String description;
    private String courseTag; // 예: 콤마(,)로 연결된 태그 문자열
    private String stores;    // 코스에 포함되는 음식점 목록 (JSON 문자열로 저장)
    private int courseWatch;
    private int courseLike;
    private String imagePath;
    
    public int getCourseId() {
		return courseId;
	}
	public void setCourseId(int courseId) {
		this.courseId = courseId;
	}
	public String getCourseTitle() {
        return courseTitle;
    }
    public void setCourseTitle(String courseTitle) {
        this.courseTitle = courseTitle;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public String getCourseTag() {
        return courseTag;
    }
    public void setCourseTag(String courseTag) {
        this.courseTag = courseTag;
    }
    public String getStores() {
        return stores;
    }
    public void setStores(String stores) {
        this.stores = stores;
    }
    public int getCourseWatch() {
        return courseWatch;
    }
    public void setCourseWatch(int courseWatch) {
        this.courseWatch = courseWatch;
    }
    public int getCourseLike() {
        return courseLike;
    }
    public void setCourseLike(int courseLike) {
        this.courseLike = courseLike;
    }
    public String getImagePath() {
        return imagePath;
    }
    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }
}
