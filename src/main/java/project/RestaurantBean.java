package project;

public class RestaurantBean {
	private int rst_id;
	private String rst_status; // 승인 상태 (예: '대기', '승인')
	private String rst_name; // 가게 이름
	private String rst_introduction; // 가게 소개
	private String rst_address; // 도로명 주소
	private String rst_phonenumber; // 연락처
	private double rst_rating; // 평점 (기본값 0)
	private double rst_lat; // 위도
	private double rst_long; // 경도
	private String rst_tag; // 태그
	private String regionLabel; // 지역1
	private String region2Label; // 지역2
	private String imgpath; // 대표 이미지 경로
	private Integer rst_like; // 좋아요 수 (nullable)
	private String created_at;
	private String member_id; // 가게 주인(member_id)

	public int getRst_id() {
		return rst_id;
	}

	public void setRst_id(int rst_id) {
		this.rst_id = rst_id;
	}

	public String getRst_status() {
		return rst_status;
	}

	public void setRst_status(String rst_status) {
		this.rst_status = rst_status;
	}

	public String getRst_name() {
		return rst_name;
	}

	public void setRst_name(String rst_name) {
		this.rst_name = rst_name;
	}

	public String getRst_introduction() {
		return rst_introduction;
	}

	public void setRst_introduction(String rst_introduction) {
		this.rst_introduction = rst_introduction;
	}

	public String getRst_address() {
		return rst_address;
	}

	public void setRst_address(String rst_address) {
		this.rst_address = rst_address;
	}

	public String getRst_phonenumber() {
		return rst_phonenumber;
	}

	public void setRst_phonenumber(String rst_phonenumber) {
		this.rst_phonenumber = rst_phonenumber;
	}

	public double getRst_rating() {
		return rst_rating;
	}

	public void setRst_rating(double rst_rating) {
		this.rst_rating = rst_rating;
	}

	public double getRst_lat() {
		return rst_lat;
	}

	public void setRst_lat(double rst_lat) {
		this.rst_lat = rst_lat;
	}

	public double getRst_long() {
		return rst_long;
	}

	public void setRst_long(double rst_long) {
		this.rst_long = rst_long;
	}

	public String getRst_tag() {
		return rst_tag;
	}

	public void setRst_tag(String rst_tag) {
		this.rst_tag = rst_tag;
	}

	public String getRegionLabel() {
		return regionLabel;
	}

	public void setRegionLabel(String regionLabel) {
		this.regionLabel = regionLabel;
	}

	public String getRegion2Label() {
		return region2Label;
	}

	public void setRegion2Label(String region2Label) {
		this.region2Label = region2Label;
	}

	public String getImgpath() {
		return imgpath;
	}

	public void setImgpath(String imgpath) {
		this.imgpath = imgpath;
	}

	public Integer getRst_like() {
		return rst_like;
	}

	public void setRst_like(Integer rst_like) {
		this.rst_like = rst_like;
	}

	public String getCreated_at() {
		return created_at;
	}

	public void setCreated_at(String created_at) {
		this.created_at = created_at;
	}

	public String getMember_id() {
		return member_id;
	}

	public void setMember_id(String member_id) {
		this.member_id = member_id;
	}

	public String getResolvedImgPath(String contextPath) {
		if (imgpath == null || imgpath.trim().isEmpty()) {
			return contextPath + "/images/photoready.png"; // 기본 이미지
		}
		if (imgpath.startsWith("http://") || imgpath.startsWith("https://")) {
			return imgpath;
		}
		if (imgpath.startsWith("/")) {
			return contextPath + imgpath;
		}
		return contextPath + "/" + imgpath;
	}

}
